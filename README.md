# p2install

The idea of this repo is to generalise the speedrunning install process for Portal 2 and its mods as much as possible.

Once the launch option is added, almost everything will be automatically installed.

Credit goes to mlugg for the original Linux script this has been adapted from.

## Launch options

On Windows, the following launch option now works for all (supported) games and mods:

> **[path to]**/.p2-common/portal2.bat %command%

For Linux, you still need to specify the game as seen below for now.

|   Game   | Launch option
| -------- | --------------
| Aperture Tag               | **[path to]**/.p2-common/portal2.bat aperturetag %command%
| Portal 2                   | **[path to]**/.p2-common/portal2.bat portal2 %command%
| Portal 2 Speedrun Mod      | **[path to]**/.p2-common/portal2.bat "**[path to]**\\sourcemods\\Portal 2 Speedrun Mod" %command%
| Portal Reloaded            | **[path to]**/.p2-common/portal2.bat portal2 %command%
| Portal Stories: Mel        | **[path to]**/.p2-common/portal2.bat portal_stories %command%
| Thinking with Time Machine | **[path to]**/.p2-common/portal2.bat TWTM %command%

## Stuff I'm leaving here for my records

| Game | %command% Windows
| - | -
| Aperture Tag               |"**[path to]**\Steam\steamapps\common\Aperture Tag\portal2.exe" -game aperturetag -steam
| Portal 2                   |"**[path to]**\Steam\steamapps\common\Portal 2\portal2.exe" -game portal2 -steam
| Portal 2 Speedrun Mod      |"**[path to]**\Steam\steamapps\common\Portal 2\portal2.exe" -game portal2 -steam -game "**[path to]**\Steam\steamapps\sourcemods\Portal 2 Speedrun Mod"
| Portal Reloaded            |"**[path to]**\Steam\steamapps\common\Portal Reloaded\portal2.exe" +r_hunkalloclightmaps 0
| Portal Stories: Mel        |"**[path to]**\Steam\steamapps\common\Portal Stories Mel\portal2.exe" -game portal_stories -steam -condebug
| Thinking with Time Machine |"**[path to]**\Steam\steamapps\common\Thinking with Time Machine\portal2.exe" -game TWTM -steam
