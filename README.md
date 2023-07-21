# p2install

The idea of this repo is to generalise the speedrunning install process for Portal 2 and its mods as much as possible.

Once the launch option is added, almost everything will be automatically installed.

Credit goes to mlugg for the original Linux script this has been adapted from.

## Launch options

On Windows, the following launch option now works for all (supported) games and mods:

> **[path to]**/.p2-common/portal2.bat %command%

For Linux, you still need to specify the game as seen below for now.

|            Game            | Launch option
| -------------------------- | -------------
| Aperture Tag               | **[path to]**/.p2-common/portal2.bat aperturetag %command%
| Portal 2                   | **[path to]**/.p2-common/portal2.bat portal2 %command%
| Portal 2 Speedrun Mod      | **[path to]**/.p2-common/portal2.bat "**[path to]**\\sourcemods\\Portal 2 Speedrun Mod" %command%
| Portal Reloaded            | **[path to]**/.p2-common/portal2.bat portal2 %command%
| Portal Stories: Mel        | **[path to]**/.p2-common/portal2.bat portal_stories %command%
| Thinking with Time Machine | **[path to]**/.p2-common/portal2.bat TWTM %command%

## Stuff I'm leaving here for my records

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
