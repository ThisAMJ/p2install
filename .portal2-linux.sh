#!/bin/bash
clear

COMMONDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
GAMEROOT="$PWD"
GAMEPATH="$GAMEROOT"
GAMENAME=$(basename "$PWD")
GAMENAME_RAW=$GAMENAME
GAMENAMEROOT_RAW="$GAMEROOT"

fixgamename() {
	if [[ "$GAMENAME" == "mebuild05" ]]; then GAMENAME="Mind Escape"; fi
}
fixgamename

echo $(date) >> "$COMMONDIR/p2install.log"

WINDOWS=0
LINUX=0
MACOSX=0
PROTON=0
PLATFORM=`uname`
if   [[ "$PLATFORM" == *"Darwin"* ]]; then
	PLATFORM="MacOSX"
	MACOSX=1
	echo "MacOSX not yet supported. Sorry!" >> "$COMMONDIR/p2install.log"
	echo "In launch of: $@" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
elif [[ "$PLATFORM" == *"Linux"* ]]; then
	PLATFORM="Linux"
	LINUX=1
	GAMEEXE="$7"
elif [[ "$PLATFORM" == *"Windows"* || "$PLATFORM" == *"NT"* ]]; then
	PLATFORM="Windows"
	WINDOWS=1
	GAMEEXE="$1"
	HOME=$USERPROFILE
else
	echo "Unknown platform: $PLATFORM" >> "$COMMONDIR/p2install.log"
	echo "In launch of: $@" >> "$COMMONDIR/p2install.log"
	echo "Let AMJ know!" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi
if [[ "$7" == *"/common/SteamLinuxRuntime"* ]]; then
	PLATFORM="Proton"
	PROTON=1
	GAMEEXE="${12}"
fi

if [[ ! -f "$GAMEEXE" ]]; then
	echo "Malformed launch command: $@" >> "$COMMONDIR/p2install.log"
	echo "Launch option should be in the form of:" >> "$COMMONDIR/p2install.log"
	echo "$COMMONDIR/portal2.bat %command%" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi

GAMEEXE=$(basename "$GAMEEXE")

STEAM="$HOME/.steam/steam"
if [[ -f "$COMMONDIR/steam-location.txt" ]]; then
	STEAM="$(cat "$COMMONDIR/steam-location.txt")"
fi
if ! [[ -d "$STEAM" ]]; then STEAM="$HOME/.local/share/Steam"; fi
if ! [[ -d "$STEAM" ]]; then STEAM="$(printenv "ProgramFiles(x86)")/Steam"; fi
if ! [[ -d "$STEAM" ]]; then
	echo ERROR! STEAM NOT FOUND! >> "$COMMONDIR/p2install.log"
	echo In launch of: $@ >> "$COMMONDIR/p2install.log"
	echo "Put the path to Steam in steam-location.txt (or yell at AMJ idk)" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi

GAMEARG="portal2"
EXTRA_ARGS="-novid +mat_motion_blur_enabled 0 -background 5 -condebug -console"
if [[ -f "$COMMONDIR/extra-args.txt" ]]; then
	EXTRA_ARGS="$(cat "$COMMONDIR/extra-args.txt")"
fi

# Vulkan seems to crash Mel, Reloaded, and Aptag upon launch
EXTRA_ARGS="$(echo "$EXTRA_ARGS" | sed 's/-vulkan//g')" # The user doesn't do this, let us
VULKAN=1
if [[ "$LINUX" -eq 1 ]]; then
	if [[ "$GAMENAME" == "Portal Stories Mel" || "$GAMENAME" == "Portal Reloaded" || "$GAMENAME" == "Aperture Tag" ]]; then VULKAN=0; fi
fi
if [[ "$VULKAN" -eq 1 ]]; then EXTRA_ARGS="$EXTRA_ARGS -vulkan"; fi

ARGIDX=1
for var in "$@"; do
	if [[ "$var" == "-game" ]]; then
		GAMENEXT=1
	elif [[ "$GAMENEXT" -eq 1 ]]; then
		GAMEARG="$var"
		GAMENEXT=0
		if [[ "$GAMEARG" == *"/sourcemods/"* ]]; then
			SOURCEMOD=1
			GAMENAME=$(basename "$GAMEARG")
			fixgamename
			GAMEPATH="$GAMEARG"
		fi
	else
		ARG_COMPARE=0
		if [[ "$WINDOWS"  -eq 1 ]]; then ARG_COMPARE=1
		elif [[ "$PROTON" -eq 1 ]]; then ARG_COMPARE=12
		elif [[ "$LINUX"  -eq 1 ]]; then ARG_COMPARE=7; fi
		if [[ "$ARGIDX" -gt "$ARG_COMPARE" ]]; then EXTRA_ARGS="$EXTRA_ARGS $var"; fi
	fi
	((ARGIDX++))
done

# Ensure GAMEEXE makes sense
if [[ "$GAMEEXE" == *".sh" ]]; then GAMEEXE="${GAMEEXE::-3}"; fi
if [[ "$GAMEEXE" == *".exe" || "$GAMEEXE" == *"_osx" ]]; then GAMEEXE="${GAMEEXE::-4}"; fi
if [[ "$GAMEEXE" == *"_linux" ]]; then GAMEEXE="${GAMEEXE::-6}"; fi
if   [[ "$LINUX" -eq 1 && "$PROTON" -eq 0 ]]; then
	GAMEEXE="${GAMEEXE}_linux"
elif [[ "$MACOSX" -eq 1 ]]; then
	GAMEEXE="${GAMEEXE}_osx"
elif [[ "$WINDOWS" -eq 1 || "$PROTON" -eq 1 ]]; then
	GAMEEXE="${GAMEEXE}.exe"
fi

P2PATH="$COMMONDIR/.dirs/Portal 2" # lol this is a silly thing

# Repair gameinfo with p2common
# Case insensitive rename of gameinfo.txt
for x in "$GAMEARG"/*.txt; do if [[ "$(basename "$x" | tr '[:upper:]' '[:lower:]')" == "gameinfo.txt" && "$(basename "$x")" != "gameinfo.txt" ]]; then mv "$x" "$GAMEARG/gameinfo.txt"; fi; done
if [[ -f "$COMMONDIR/.util/gameinfo/$GAMENAME.txt" ]]; then
	ESCAPED_GAMEROOT=$(printf '%s\n' "$GAMEROOT" | sed -e 's/[\/&]/\\&/g')
	ESCAPED_COMMONDIR=$(printf '%s\n' "$COMMONDIR" | sed -e 's/[\/&]/\\&/g')
	ESCAPED_P2PATH=$(printf '%s\n' "$P2PATH" | sed -e 's/[\/&]/\\&/g')
	cp -f  "$COMMONDIR/.util/gameinfo/$GAMENAME.txt" "$GAMEARG/gameinfo.txt"
	sed -i "s/GAMEROOTGOESHERE/$ESCAPED_GAMEROOT/"   "$GAMEARG/gameinfo.txt"
	sed -i "s/COMMONDIRGOESHERE/$ESCAPED_COMMONDIR/" "$GAMEARG/gameinfo.txt"
	sed -i "s/P2PATHGOESHERE/$ESCAPED_P2PATH/"       "$GAMEARG/gameinfo.txt"
fi

if ! [[ -d "$COMMONDIR/cfg" ]]; then mkdir "$COMMONDIR/cfg"; fi

# Remove any cfgs that are common from the game's cfg folder(s)
MAIN_DIR=""
ESCAPED_GAMEARG=$(printf '%s\n' "$GAMEARG" | sed -e 's/[\/&]/\\&/g')
while read -r line; do
	if [[ "$line" != $(echo "$line" | sed -e 's/^Game[ \t][ \t"]*\([^"\r\n\t]*\).*$/\1/') ]]; then
		line=$(echo "$line" | sed -e 's/^Game[ \t][ \t"]*\([^"\r\n\t]*\).*$/\1/')/
		line=$(echo "$line" | sed -e "s/|gameinfo_path|/$ESCAPED_GAMEARG\//g")
		line=$(echo "$line" | sed -e 's/\/\.\//\//g')
		line=$(cd "$line" && pwd)
		if [[ "$MAIN_DIR" == "" ]]; then MAIN_DIR="$line"; fi
		if [[ "$line" != "$COMMONDIR" ]]; then
			for commonCfg in "$COMMONDIR/cfg/"*; do
				if [[ -f "$line/cfg/$(basename "$commonCfg")" ]]; then
					mkdir -p "$line/cfg/.p2-common-backup"
					mv -f "$line/cfg/$(basename "$commonCfg")" "$line/cfg/.p2-common-backup/$(basename "$commonCfg")"
				fi
			done
		fi
	fi
done < "$GAMEARG/gameinfo.txt"

# Make symlinks to the game's directories for convenience and install things
# Debatable whether svars should be common
mkdir -p "$COMMONDIR/.dirs"; rm -f "$COMMONDIR/.dirs/$GAMENAME"; ln -s "$GAMEPATH" "$COMMONDIR/.dirs/$GAMENAME"
mkdir -p "$COMMONDIR/.tas/$GAMENAME_RAW"
mkdir -p "$COMMONDIR/.crash_reports"
mkdir -p "$COMMONDIR/.demos/$GAMENAME"
mkdir -p "$COMMONDIR/.saves"; rm -f "$COMMONDIR/.saves/$GAMENAME"; ln -s "$MAIN_DIR/SAVE" "$COMMONDIR/.saves/$GAMENAME"
if [[ -d "$MAIN_DIR/crosshair" ]];     then rm -rf "$MAIN_DIR/crosshair";  fi; ln -s "$COMMONDIR/.util/crosshair" "$MAIN_DIR/crosshair"
if [[ -d "$GAMEROOT/ihud" ]];          then rm -rf "$GAMEROOT/ihud";       fi; ln -s "$COMMONDIR/.util/ihud" "$GAMEROOT/ihud"
if [[ -d "$GAMEROOT/tas" ]];           then mv "$GAMEROOT/tas/"*           "$COMMONDIR/.tas/$GAMENAME_RAW"; rm -rf "$GAMEROOT/tas";           fi; ln -s "$COMMONDIR/.tas/$GAMENAME_RAW" "$GAMEROOT/tas"
if [[ -d "$GAMEROOT/crash_reports" ]]; then mv "$GAMEROOT/crash_reports/"* "$COMMONDIR/.crash_reports";     rm -rf "$GAMEROOT/crash_reports"; fi; ln -s "$COMMONDIR/.crash_reports"     "$GAMEROOT/crash_reports"
if [[ -d "$MAIN_DIR/demos" ]];         then mv "$MAIN_DIR/demos/"*         "$COMMONDIR/.demos/$GAMENAME";   rm -rf "$MAIN_DIR/demos";         fi; ln -s "$COMMONDIR/.demos/$GAMENAME"   "$MAIN_DIR/demos"
if [[ -f "$MAIN_DIR/console.log" ]];   then rm -f "$MAIN_DIR/console.log"; fi; ln -s "$COMMONDIR/p2console.log" "$MAIN_DIR/console.log"
if [[ -f "$GAMEROOT/svars_persist" ]]; then mv -f "$GAMEROOT/svars_persist" "$COMMONDIR"; fi; ln -s "$COMMONDIR/svars_persist" "$GAMEROOT/svars_persist"

# platform.cfg
echo "svar_set gameplatform $PLATFORM"            > "$COMMONDIR/cfg/platform.cfg"
echo "svar_set windows $WINDOWS"                 >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set linux   $LINUX"                   >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set proton  $PROTON"                  >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set macos   $MACOSX"                  >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamearg \"$(basename $GAMEARG)\"" >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamename \"$GAMENAME\""           >> "$COMMONDIR/cfg/platform.cfg"

# Pack VPKs for DLCs
highest_dlc=3 # TODO: Is this different for any games?
while [[ -d "portal2_dlc$highest_dlc/.root" ]]; do
	cd "portal2_dlc$highest_dlc"
	"$COMMONDIR/.util/zvpk" ".root/"
	cd ..
	((highest_dlc++))
done

# Install CM maplist and fast taunt for Portal 2
if [[ "$GAMENAME" == "Portal 2" ]]; then
	cp -f "$COMMONDIR/.util/gamefile-mods/challenge_maplist.txt" "$GAMEROOT/portal2_dlc1"
	cp -f "$COMMONDIR/.util/gamefile-mods/scripts/talker/"* "$GAMEROOT/portal2/scripts/talker"
fi

# Install saves for any games that have them
# Just copy into every steamid lol
if [[ -d "$COMMONDIR/.util/saves/$GAMENAME" ]]; then
	for steamid in "$MAIN_DIR/SAVE/"*; do
		if [[ -d "$steamid" ]]; then
			cp -fr "$COMMONDIR/.util/saves/$GAMENAME/"* "$steamid"
		fi
	done
fi
# Ditto for speedrun mods
if [[ -d "$COMMONDIR/.util/srmods/$GAMENAME" ]]; then
	cp -fr "$COMMONDIR/.util/srmods/$GAMENAME/"* "$MAIN_DIR"
fi

if [[ "$LINUX" -eq 1 ]]; then
	STEAM_RT="$STEAM/ubuntu12_32/steam-runtime"
	REAPER="$STEAM_RT/../reaper"
	if ! [[ -f "$REAPER" ]]; then REAPER="$1"; fi
	if ! [[ -f "$REAPER" ]]; then
		echo ERROR! REAPER NOT FOUND AT $REAPER! >> "$COMMONDIR/p2install.log"
		echo In launch of: $@ >> "$COMMONDIR/p2install.log"
		echo "" >> "$COMMONDIR/p2install.log"
		exit 1
	fi
	LD_LIBRARY_PATH_INITIAL=$LD_LIBRARY_PATH
	LD_PRELOAD_INITIAL=$LD_PRELOAD
	if [[ "$PROTON" == 0 ]]; then
		export LD_LIBRARY_PATH=""
		export LD_LIBRARY_PATH="$GAMEROOT/bin/linux32:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$GAMEROOT/bin:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$STEAM_RT/pinned_libs_32:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$STEAM_RT/lib/i386-linux-gnu:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$STEAM_RT/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$STEAM_RT/lib:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="$STEAM_RT/usr/lib:$LD_LIBRARY_PATH"
		export LD_LIBRARY_PATH="/usr/lib32:$LD_LIBRARY_PATH"
		export LD_PRELOAD=""
		export LD_PRELOAD="$STEAM_RT/../gameoverlayrenderer.so:$LD_PRELOAD"
	fi
fi

echo "    PLATFORM: $PLATFORM" >> "$COMMONDIR/p2install.log"
echo "    GAMEROOT: $GAMEROOT (GAME $GAMEARG)" >> "$COMMONDIR/p2install.log"
echo "     GAMEEXE: $GAMEEXE" >> "$COMMONDIR/p2install.log"
echo "INITIAL_ARGS: $@" >> "$COMMONDIR/p2install.log"
echo "  EXTRA_ARGS: $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
echo "    GAMENAME: $GAMENAME (PROTON $PROTON)" >> "$COMMONDIR/p2install.log"
echo "   COMMONDIR: $COMMONDIR" >> "$COMMONDIR/p2install.log"
echo "" >> "$COMMONDIR/p2install.log"

cd "$GAMEROOT"

if [[ "$WINDOWS" -eq 1 ]]; then
	"$GAMEROOT/$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS
	exit $ERRORLEVEL
elif [[ "$LINUX" -eq 1 ]]; then

	STATUS=42
	while [ $STATUS -eq 42 ]; do
		if [[ "$PROTON" == 1 ]]; then
			"$REAPER" SteamLaunch "$3" -- "$5" -- "$7" --verb=waitforexitandrun -- "${10}" waitforexitandrun "$GAMEROOT/$GAMEEXE" "" -game "$GAMEARG" $EXTRA_ARGS
		else
			ulimit -n 2048 # Limit the game to at most 2048 files open at once (why?)
			"$REAPER" SteamLaunch "$3" -- $GAME_DEBUGGER "$GAMEROOT/$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS
		fi
		STATUS=$?
	done
	exit $STATUS
fi
