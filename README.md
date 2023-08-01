# p2install

The idea of this repo is to generalise the speedrunning install process for Portal 2 and its mods as much as possible.

Once the launch option is added, almost everything will be automatically installed.

Credit goes to [@mlugg](https://github.com/mlugg) for the original Linux script this has been adapted from.

## Installation

1. Download the source code of the repository (green `Code` button -> `Download Zip`)

2. Extract the zip file to a folder of your choice

3. Go to the game's properties in steam and set the following launch option: (replacing **[path to]** with the path to the folder you extracted the zip to)

    > **[path to]**/p2install/portal2.bat %command%

4. Launch the game

## Stuff I'm leaving here for my records

### You don't need to read any of this stuff! It's just some documentation about how Steam launches the games and mods

Windows %command% is generally:
> "**[path to]**\\common\\**[game]**\\portal2.exe" **[args]**

Linux %command% is generally:
> "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=**[appid]** -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/**[game]**/**[gameexec]**" **[args]**

Linux %command% with Proton is generally:
> "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=**[appid]** -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/**[game]**/**[gameexec]**" **[args]**

|            Game            | %command% Windows                                                                                                      | %command% Linux                                                                                                                                                                                                                                       | %command% Linux Proton
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---
| Aperture Tag               |"**[path to]**\common\Aperture Tag\portal2.exe" -game aperturetag -steam                                                | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=280740  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Aperture Tag/portal2_linux" -game aperturetag -steam                                            | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=280740  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Aperture Tag/portal2.exe" -game aperturetag -steam
| Portal 2                   |"**[path to]**\common\Portal 2\portal2.exe" -game portal2 -steam                                                        | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=620     -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Portal 2/portal2.sh" -game portal2 -steam                                                       | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=620     -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Portal 2/portal2.exe" -game portal2 -steam
| Portal 2 Speedrun Mod      |"**[path to]**\common\Portal 2\portal2.exe" -game portal2 -steam -game "**[path to]**\sourcemods\Portal 2 Speedrun Mod" | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=620     -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Portal 2/portal2.sh" -game portal2 -steam -game "**[path to]**/sourcemods/Portal 2 Speedrun Mod"| "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=620     -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Portal 2/portal2.exe" -game portal2 -steam -game "**[path to]**/sourcemods/Portal 2 Speedrun Mod"
| Portal Reloaded            |"**[path to]**\common\Portal Reloaded\portal2.exe" +r_hunkalloclightmaps 0                                              | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=1255980 -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Portal Reloaded/portal2.sh" -game portal2 -steam +r_hunkalloclightmaps 0 +r_dynamic 0           | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=1255980 -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Portal Reloaded/portal2.exe" +r_hunkalloclightmaps 0
| Portal Stories: Mel        |"**[path to]**\common\Portal Stories Mel\portal2.exe" -game portal_stories -steam -condebug                             | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=317400  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Portal Stories Mel/portal2.sh" -game portal_stories -steam                                      | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=317400  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Portal Stories Mel/portal2.exe" -game portal_stories -steam -condebug
| Thinking with Time Machine |"**[path to]**\common\Thinking with Time Machine\portal2.exe" -game TWTM -steam                                         | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=286080  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/Thinking with Time Machine/TWTM.sh" -game TWTM -steam                                           | "**[path to]**/Steam/ubuntu12_32/reaper" SteamLaunch AppId=286080  -- "**[path to]**/Steam/ubuntu12_32/steam-launch-wrapper" -- "**[path to]**/common/SteamLinuxRuntime_sniper/_v2-entry-point" --verb=waitforexitandrun -- "**[path to]**/common/Proton - Experimental/proton" waitforexitandrun "**[path to]**/common/Thinking with Time Machine/portal2.exe" -game TWTM -steam
