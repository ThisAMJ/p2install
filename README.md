# p2install

The idea of this repo is to generalise the speedrunning install process for Portal 2 and its mods as much as possible.

Once the launch option is added, almost everything will be automatically installed.

Credit goes to mlugg for the original Linux script this has been adapted from.

## Launch options

WIP: in time this may come down to just one launch option,

```txt
[path to]/.p2-common/portal2.bat %command%
[path to]/.p2-common/portal2.sh %command%
```

I even wonder if there's some way to have a single file that works on both Windows and Linux.

| Game | Launch options<br>Windows | Launch options<br>Linux
| ---- | -------------- | --------------
| Portal 2 | [path to]/.p2-common/portal2.bat portal2 %command%                                                                                             | [path to]/.p2-common/portal2.sh portal2 %command%
| PS:Mel   | [path to]/.p2-common/portal2.bat portal_stories %command%                                                                                      | [path to]/.p2-common/portal2.sh portal_stories %command%
| SRM      | [path to]/.p2-common/portal2.bat "..\\..\\sourcemods\\Portal 2 Speedrun Mod" %command%<br>*Change path if Speedrun Mod is on a different drive*| [path to]/.p2-common/portal2.sh "../../sourcemods/Portal 2 Speedrun Mod" %command%<br>*Change path if Speedrun Mod is on a different drive*
| Reloaded | [path to]/.p2-common/portal2.bat portal2 %command%                                                                                             | [path to]/.p2-common/portal2.sh portal2 %command%
| Aptag    | [path to]/.p2-common/portal2.bat aperturetag %command%                                                                                         | [path to]/.p2-common/portal2.sh aperturetag %command%<br>*The use of Proton is recommended.*
| TWTM     | [path to]/.p2-common/portal2.bat TWTM %command%                                                                                                | [path to]/.p2-common/portal2.sh TWTM %command%<br>*The use of Proton is recommended.*
