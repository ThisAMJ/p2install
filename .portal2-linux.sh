#!/bin/bash
clear

COMMONDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
GAMEROOT="$PWD"
GAMEPATH="$GAMEROOT"
GAMEEXE="$7"
GAMENAME=$(basename "$PWD")
GAMENAME_RAW=$GAMENAME
GAMENAMEROOT_RAW="$GAMEROOT"

LINUX=0
MACOSX=0
UNAME=`uname`
if [ "$UNAME" == "Darwin" ]; then
	MACOSX=1
elif [ "$UNAME" == "Linux" ]; then
	LINUX=1
fi

PROTON=0
if [[ "$7" == *"/common/SteamLinuxRuntime"* ]]; then
	PROTON=1
	GAMEEXE="${12}"
fi
GAMEEXE=$(basename "$GAMEEXE")

STEAM="$HOME/.steam/steam"
if [[ -f "$COMMONDIR/steam-location.txt" ]]; then
	STEAM="$(cat "$COMMONDIR/steam-location.txt")"
fi
if ! [[ -d "$STEAM" ]]; then STEAM="$HOME/.local/share/Steam"; fi
if ! [[ -d "$STEAM" ]]; then
	echo ERROR! STEAM NOT FOUND! >> "$COMMONDIR/p2install.log"
	echo In launch of: $@ >> "$COMMONDIR/p2install.log"
	echo Put the path to Steam in steam-location.txt >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi
STEAM_RT="$STEAM/ubuntu12_32/steam-runtime"
REAPER="$STEAM_RT/../reaper"
if ! [[ -f "$REAPER" ]]; then REAPER="$1"; fi
if ! [[ -f "$REAPER" ]]; then
	echo ERROR! REAPER NOT FOUND AT $REAPER! >> "$COMMONDIR/p2install.log"
	echo In launch of: $@ >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi


GAMEARG="portal2"
EXTRA_ARGS="-novid +mat_motion_blur_enabled 0 -background 5 -condebug -console" # -vulkan
if [[ -f "$COMMONDIR/extra-args.txt" ]]; then
	EXTRA_ARGS="$(cat "$COMMONDIR/extra-args.txt")"
fi
# Vulkan seems to crash Mel, Reloaded, and Aptag upon launch
if ! [[ "$GAMENAME" == "Portal Stories Mel" || "$GAMENAME" == "Portal Reloaded" || "$GAMENAME" == "Aperture Tag" ]]; then
	EXTRA_ARGS="$EXTRA_ARGS -vulkan"
fi
ARGIDX=1
for var in "$@"; do
	if [[ "$var" == "-game" ]]; then
		GAMENEXT=1
	elif [[ "$GAMENEXT" == 1 ]]; then
		GAMEARG="$var"
		GAMENEXT=0
		if [[ "$GAMEARG" == *"/sourcemods/"* ]]; then
			SOURCEMOD=1
			GAMENAME=$(basename "$GAMEARG")
			GAMEPATH="$GAMEARG"
		fi
	else
		if [[ "$PROTON" == 1 ]]; then
			if [[ "$ARGIDX" -gt 12 ]]; then EXTRA_ARGS+=" $var"; fi
		else
			if [[ "$ARGIDX" -gt 7 ]]; then EXTRA_ARGS+=" $var"; fi
		fi
	fi
	((ARGIDX++))
done

# If GAMEEXE ends with .sh, replace it with our platform
if [[ "$GAMEEXE" == *".sh" ]]; then
	if [[ "$LINUX" == 1 ]]; then
		GAMEEXE="${GAMEEXE::-3}_linux"
	elif [[ "$MACOSX" == 1 ]]; then
		GAMEEXE="${GAMEEXE::-3}_osx"
	fi
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
while read line || [[ -n $line ]]; do
	line=$(echo "$line" | sed -e "s/|gameinfo_path|/$GAMEARG\//")
	if [[ "$line" != $(echo "$line" | sed -e 's/^Game[ \t][ \t"]*\([^"\r\n]*\).*$/\1/') ]]; then
		line=$(echo "$line" | sed -e 's/^Game[ \t][ \t"]*\([^"\r\n]*\).*$/\1/')/
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
mkdir -p "$COMMONDIR/.dirs"; rm -f "$COMMONDIR/.dirs/$GAMENAME"; ln -s "$GAMEPATH" "$COMMONDIR/.dirs/$GAMENAME"
mkdir -p "$COMMONDIR/.tas/$GAMENAME_RAW"
mkdir -p "$COMMONDIR/.crash_reports"
mkdir -p "$COMMONDIR/.demos/$GAMENAME"
if [[ -d "$MAIN_DIR/crosshair" ]];     then rm -rf "$MAIN_DIR/crosshair";  fi; ln -s "$COMMONDIR/.util/crosshair" "$MAIN_DIR/crosshair"
if [[ -d "$GAMEROOT/ihud" ]];          then rm -rf "$GAMEROOT/ihud";       fi; ln -s "$COMMONDIR/.util/ihud" "$GAMEROOT/ihud"
if [[ -d "$GAMEROOT/tas" ]];           then mv "$GAMEROOT/tas/"*           "$COMMONDIR/.tas/$GAMENAME_RAW"; rm -rf "$GAMEROOT/tas";           fi; ln -s "$COMMONDIR/.tas/$GAMENAME_RAW" "$GAMEROOT/tas"
if [[ -d "$GAMEROOT/crash_reports" ]]; then mv "$GAMEROOT/crash_reports/"* "$COMMONDIR/.crash_reports";     rm -rf "$GAMEROOT/crash_reports"; fi; ln -s "$COMMONDIR/.crash_reports"     "$GAMEROOT/crash_reports"
if [[ -d "$MAIN_DIR/demos" ]];         then mv "$MAIN_DIR/demos/"*         "$COMMONDIR/.demos/$GAMENAME";   rm -rf "$MAIN_DIR/demos";         fi; ln -s "$COMMONDIR/.demos/$GAMENAME"   "$MAIN_DIR/demos"
if [[ -f "$MAIN_DIR/console.log" ]];   then rm -f "$MAIN_DIR/console.log"; fi; ln -s "$COMMONDIR/p2console.log" "$MAIN_DIR/console.log"
if [[ -f "$GAMEROOT/svars_persist" ]]; then mv -f "$GAMEROOT/svars_persist" "$COMMONDIR"; fi; ln -s "$COMMONDIR/svars_persist" "$GAMEROOT/svars_persist"

# platform.cfg
echo "svar_set gameplatform $UNAME"     > "$COMMONDIR/cfg/platform.cfg"
echo "svar_set linux $LINUX"           >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set windows 0"              >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set macos $MACOSX"          >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamearg \"$GAMEARG\""   >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamename \"$GAMENAME\"" >> "$COMMONDIR/cfg/platform.cfg"

# Pack VPKs for DLCs
highest_dlc=3 # TODO: Is this different for any games?
while [[ -d "portal2_dlc$highest_dlc/.root" ]]; do
	cd "portal2_dlc$highest_dlc"
	"$COMMONDIR/.util/zvpk" ".root/"
	cd ..
	((highest_dlc++))
done

# TODO: .util/saves/$GAMENAME (?)
# Just copy into every steamid lol
# Ditto for .util/maps (speedrun mods)

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

echo $(date) >> "$COMMONDIR/p2install.log"
echo "    PLATFORM: $UNAME" >> "$COMMONDIR/p2install.log"
echo "    GAMEROOT: $GAMEROOT (GAME $GAMEARG)" >> "$COMMONDIR/p2install.log"
echo "     GAMEEXE: $GAMEEXE" >> "$COMMONDIR/p2install.log"
echo "INITIAL_ARGS: $@" >> "$COMMONDIR/p2install.log"
echo "  EXTRA_ARGS: $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
echo "    GAMENAME: $GAMENAME (PROTON $PROTON)" >> "$COMMONDIR/p2install.log"
echo "   COMMONDIR: $COMMONDIR" >> "$COMMONDIR/p2install.log"
echo "" >> "$COMMONDIR/p2install.log"

ulimit -n 2048

cd "$GAMEROOT"

STATUS=42
while [ $STATUS -eq 42 ]; do
	if [[ "$PROTON" == 1 ]]; then
		"$REAPER" SteamLaunch "$3" -- "$5" -- "$7" --verb=waitforexitandrun -- "${10}" waitforexitandrun "$GAMEEXE" "" -game "$GAMEARG" $EXTRA_ARGS
	else
		"$REAPER" SteamLaunch "$3" -- $GAME_DEBUGGER "$GAMEROOT/$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS
	fi
	STATUS=$?
done
exit $STATUS
