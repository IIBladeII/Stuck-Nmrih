#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_NAME         "NMRIH Stuck Fix"
#define PLUGIN_AUTHOR       "Erreur 500 (Modified for NMRIH)"
#define PLUGIN_DESCRIPTION  "Fix stuck players in NMRIH"
#define PLUGIN_VERSION      "1.5"
#define PLUGIN_CONTACT      "erreur500@hotmail.fr"

#define MAX_NMRIH_PLAYERS 9
#define COOLDOWN_TIME 20 // Cooldown of 20 seconds between uses

ConVar g_cvCooldownTime;
ConVar g_cvStepSize;
ConVar g_cvRadiusSize;

int g_Countdown[MAX_NMRIH_PLAYERS+1];

float g_Step = 20.0;
float g_RadiusSize = 200.0;
float g_Ground_Velocity[3] = {0.0, 0.0, -300.0};

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = PLUGIN_CONTACT
};

public void OnPluginStart()
{
    CreateConVar("nmrih_stuck_version", PLUGIN_VERSION, "Stuck plugin version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
    
    g_cvCooldownTime = CreateConVar("sm_stuck_cooldown", "20", "Cooldown time in seconds between uses of the stuck command", 0, true, 0.0, true, 600.0);
    g_cvStepSize = CreateConVar("sm_stuck_step", "20.0", "Step size for radial unstuck method", 0, true, 5.0, true, 50.0);
    g_cvRadiusSize = CreateConVar("sm_stuck_radius", "200.0", "Maximum radius for radial unstuck method", 0, true, 50.0, true, 500.0);
    
    RegConsoleCmd("sm_stuck", Command_Stuck, "Stuck? Use !stuck");
    RegConsoleCmd("sm_unstuck", Command_Stuck, "Stuck? Use !unstuck");
    
    AutoExecConfig(true, "nmrih_stuck");
    
    CreateTimer(1.0, Timer_Cooldown, INVALID_HANDLE, TIMER_REPEAT);
}

public void OnConfigsExecuted()
{
    g_Step = g_cvStepSize.FloatValue;
    g_RadiusSize = g_cvRadiusSize.FloatValue;
}

public Action Timer_Cooldown(Handle timer)
{
    for(int i = 1; i <= MAX_NMRIH_PLAYERS; i++)
    {
        if(g_Countdown[i] > 0)
        {
            g_Countdown[i]--;
        }
    }
    return Plugin_Continue;
}

public Action Command_Stuck(int client, int args)
{
    if(!IsValidClient(client) || !IsPlayerAlive(client))
    {
        ReplyToCommand(client, "[Stuck] You need to be alive to use this command!");
        return Plugin_Handled;
    }
    
    if(g_Countdown[client] > 0)
    {
        ReplyToCommand(client, "[Stuck] Please wait %d seconds before using this command again.", g_Countdown[client]);
        return Plugin_Handled;
    }
    
    g_Countdown[client] = g_cvCooldownTime.IntValue;
    AttemptUnstuck(client);
    
    return Plugin_Handled;
}

void AttemptUnstuck(int client)
{
    float vecOrigin[3], vecMins[3], vecMaxs[3];
    GetClientAbsOrigin(client, vecOrigin);
    GetClientMins(client, vecMins);
    GetClientMaxs(client, vecMaxs);
    
    // Try various positions to unstuck the player
    float testPositions[][] = {
        {0.0, 0.0, 25.0},    // Up
        {0.0, 0.0, -25.0},   // Down
        {25.0, 0.0, 0.0},    // Forward
        {-25.0, 0.0, 0.0},   // Back
        {0.0, 25.0, 0.0},    // Right
        {0.0, -25.0, 0.0}    // Left
    };
    
    bool unstuckSuccess = false;
    
    for(int i = 0; i < sizeof(testPositions); i++)
    {
        float testPos[3];
        AddVectors(vecOrigin, testPositions[i], testPos);
        
        if(IsValidPosition(testPos, vecMins, vecMaxs))
        {
            TeleportEntity(client, testPos, NULL_VECTOR, g_Ground_Velocity);
            unstuckSuccess = true;
            break;
        }
    }
    
    if(!unstuckSuccess)
    {
        // If no valid position found, try the radial method
        unstuckSuccess = TryRadialUnstuck(client);
    }
    
    if(unstuckSuccess)
    {
        PrintToChat(client, "\x04[Stuck]\x01 Position corrected successfully!");
    }
    else
    {
        PrintToChat(client, "\x04[Stuck]\x01 Unable to find a safe position. Please try again.");
    }
}

bool TryRadialUnstuck(int client)
{
    float vecOrigin[3], vecAngle[3];
    GetClientAbsOrigin(client, vecOrigin);
    GetClientEyeAngles(client, vecAngle);
    
    float vecMins[3], vecMaxs[3];
    GetClientMins(client, vecMins);
    GetClientMaxs(client, vecMaxs);
    
    for(float radius = g_Step; radius <= g_RadiusSize; radius += g_Step)
    {
        for(float degree = 0.0; degree < 360.0; degree += 10.0)
        {
            float testPos[3];
            testPos[0] = vecOrigin[0] + radius * Cosine(degree * FLOAT_PI / 180.0);
            testPos[1] = vecOrigin[1] + radius * Sine(degree * FLOAT_PI / 180.0);
            testPos[2] = vecOrigin[2];
            
            if(IsValidPosition(testPos, vecMins, vecMaxs))
            {
                TeleportEntity(client, testPos, vecAngle, g_Ground_Velocity);
                return true;
            }
        }
    }
    
    return false;
}

bool IsValidPosition(float position[3], float mins[3], float maxs[3])
{
    TR_TraceHullFilter(position, position, mins, maxs, MASK_PLAYERSOLID, TraceEntityFilterSolid);
    return !TR_DidHit();
}

public bool TraceEntityFilterSolid(int entity, int contentsMask) 
{
    return entity > MAX_NMRIH_PLAYERS || !entity;
}

bool IsValidClient(int client)
{
    return (client > 0 && client <= MAX_NMRIH_PLAYERS && IsClientConnected(client) && IsClientInGame(client));
}