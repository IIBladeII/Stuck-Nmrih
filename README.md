# NMRIH Stuck Fix Plugin

## Overview
The NMRIH Stuck Fix plugin is designed for No More Room in Hell (NMRIH) servers to help players who find themselves stuck in the game environment. It provides a simple command that attempts to reposition players to nearby safe locations.

## Features
- Command to unstuck players (!stuck or !unstuck)
- Cooldown system to prevent abuse
- Configurable settings for cooldown time, step size, and maximum radius
- Multiple unstuck methods:
  1. Checks six directions around the player
  2. Radial search for a safe position

## Requirements
- SourceMod 1.10 or higher
- No More Room in Hell dedicated server

## Installation
1. Download the `stuck2.0.sp` file.
2. Compile the plugin using the SourceMod compiler.
3. Upload the compiled `.smx` file to your server's `addons/sourcemod/plugins/` directory.
4. Restart your server or load the plugin using the `sm plugins load` command.

## Usage
Players can use the following commands when stuck:
- `!stuck`
- `!unstuck`

The plugin will attempt to move the player to a safe position.

## Configuration
The plugin creates a configuration file at `cfg/sourcemod/nmrih_stuck.cfg` with the following options:

- `sm_stuck_cooldown` (default: 20) - Cooldown time in seconds between uses of the stuck command
- `sm_stuck_step` (default: 20.0) - Step size for radial unstuck method
- `sm_stuck_radius` (default: 200.0) - Maximum radius for radial unstuck method

You can modify these values to adjust the plugin's behavior.

## Compilation
To compile the plugin, use the following command:


## Developer Information
- Version: 1.5
- Author: IIBladeII
- Contact: bladeghost07@gmail.com
- GitHub: https://github.com/IIBladeII

## License
This plugin is released under the GNU General Public License v3.0. See the `LICENSE` file for more details.

## Contributing
Contributions to improve the plugin are welcome. Please submit pull requests or open issues on the project's GitHub repository.

## Support
For support, bug reports, or feature requests, please use the GitHub issues system or contact the author directly.