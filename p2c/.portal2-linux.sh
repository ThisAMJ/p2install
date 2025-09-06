#!/bin/bash
clear

DEBUG=0

# todo: kill existing processes

COMMONDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
GAMEROOT="$PWD"
GAMEROOT="${GAMEROOT%/}"
GAMEROOT="${GAMEROOT%/bin}"
GAMEPATH="$GAMEROOT"
GAMENAME=$(basename "$GAMEROOT")
SRCONFIGS=""
if [[ -f "$COMMONDIR/srconfigs.txt" ]]; then
	SRCONFIGS=$(cat "$COMMONDIR/srconfigs.txt")
fi

fixgamename() {
	if [[ "$GAMENAME" == "aperture_ireland" ]]; then GAMENAME="Aperture Ireland"; fi
	if [[ "$GAMENAME" == "mebuild05" ]]; then GAMENAME="Mind Escape"; fi
	if [[ "$GAMENAME" == "infra" ]]; then GAMENAME="INFRA"; fi
	if [[ "$GAMENAME" == "left 4 dead" ]]; then GAMENAME="Left 4 Dead"; fi
	if [[ "$GAMENAME" == "GarrysMod" ]]; then GAMENAME="Garrys Mod"; fi
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
	GAMEEXE="${12}"
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
if [[ "$7" == *"_sniper"* ]]; then
	PLATFORM="Proton"
	PROTON=1
	GAMEEXE="${12}"
fi
if [[ "$PLATFORM" == "Linux" ]]; then
	if [[ -f "$COMMONDIR/srconfigs-linux.txt" ]]; then
		SRCONFIGS=$(cat "$COMMONDIR/srconfigs-linux.txt")
	fi
fi
if [[ ! -f "$GAMEEXE" ]]; then
	echo "Malformed launch command: $@" >> "$COMMONDIR/p2install.log"
	echo "Launch option should be in the form of:" >> "$COMMONDIR/p2install.log"

	# one directory higher than commondir
	BATDIR=$(dirname "$COMMONDIR/../")
	echo "$BATDIR/portal2.bat %command%" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi

GAMEEXE=$(basename "$GAMEEXE")
EXENAME="${GAMEEXE%.sh}"
EXENAME="${EXENAME%.exe}"
EXENAME="${EXENAME%_linux}"

STEAM="$HOME/.steam/steam"
if [[ -f "$COMMONDIR/steam-location.txt" ]]; then
	STEAM="$(cat "$COMMONDIR/steam-location.txt")"
fi
if ! [[ -d "$STEAM" ]]; then STEAM="$HOME/.steam/steam"; fi
if ! [[ -d "$STEAM" ]]; then STEAM="$HOME/.local/share/Steam"; fi
if ! [[ -d "$STEAM" ]]; then STEAM="$(printenv "ProgramFiles(x86)")/Steam"; fi
if ! [[ -d "$STEAM" ]]; then
	echo ERROR! STEAM NOT FOUND! >> "$COMMONDIR/p2install.log"
	echo In launch of: $@ >> "$COMMONDIR/p2install.log"
	echo "Put the path to Steam in steam-location.txt (or yell at AMJ idk)" >> "$COMMONDIR/p2install.log"
	echo "" >> "$COMMONDIR/p2install.log"
	exit 1
fi

GAMEARG=$EXENAME
EXTRA_ARGS="-novid +mat_motion_blur_enabled 0 -console"
if [[ -f "$COMMONDIR/extra-args.txt" ]]; then
	EXTRA_ARGS="$EXTRA_ARGS $(cat "$COMMONDIR/extra-args.txt")"
fi

# Vulkan seems to crash Mel, Reloaded, and Aptag upon launch
EXTRA_ARGS="$(echo "$EXTRA_ARGS" | sed 's/-vulkan//g')" # The user doesn't do this, let us
VULKAN=1
if [[ "$LINUX" -eq 1 ]]; then
	if [[ "$GAMENAME" == "Portal Stories Mel" ]]; then VULKAN=0; fi
	if [[ "$GAMENAME" == "Portal Reloaded" ]]; then VULKAN=0; fi
	if [[ "$GAMENAME" == "Aperture Tag" ]]; then VULKAN=0; fi
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
		elif [[ "$LINUX"  -eq 1 ]]; then ARG_COMPARE=12; fi
		if [[ "$ARGIDX" -gt "$ARG_COMPARE" ]]; then EXTRA_ARGS="$EXTRA_ARGS $var"; fi
	fi
	((ARGIDX++))
done

# Remove gamearg if invalid
if ! [[ -d "$GAMEARG" ]]; then
	GAMEARG=""
fi

# Ensure GAMEEXE makes sense
if [[ "$GAMEEXE" == *".sh" ]]; then GAMEEXE="${GAMEEXE::-3}"; fi
if [[ "$GAMEEXE" == *".exe" || "$GAMEEXE" == *"_osx" ]]; then GAMEEXE="${GAMEEXE::-4}"; fi
if [[ "$GAMEEXE" == *"_linux" ]]; then GAMEEXE="${GAMEEXE::-6}"; fi
if   [[ "$LINUX" -eq 1 && "$PROTON" -eq 0 ]]; then
	if [[ -f "${GAMEEXE}_linux" ]]; then GAMEEXE="${GAMEEXE}_linux"
	elif [[ -f "${GAMEEXE}.sh" ]]; then GAMEEXE="${GAMEEXE}.sh"
	fi
elif [[ "$MACOSX" -eq 1 ]]; then
	GAMEEXE="${GAMEEXE}_osx"
elif [[ "$WINDOWS" -eq 1 || "$PROTON" -eq 1 ]]; then
	GAMEEXE="${GAMEEXE}.exe"
fi

P2PATH="$COMMONDIR/../.dirs/Portal 2" # lol this is a silly thing

# Repair gameinfo with p2common
# Case insensitive rename of gameinfo.txt
for x in "$GAMEARG"/*.txt; do if [[ "$(basename "$x" | tr '[:upper:]' '[:lower:]')" == "gameinfo.txt" && "$(basename "$x")" != "gameinfo.txt" ]]; then mv "$x" "$GAMEARG/gameinfo.txt"; fi; done
if [[ -f "$COMMONDIR/../.util/gameinfo/$GAMENAME.txt" ]]; then
	ESCAPED_GAMEROOT=$(printf '%s\n' "$GAMEROOT" | sed -e 's/[\/&]/\\&/g')
	ESCAPED_COMMONDIR=$(printf '%s\n' "$COMMONDIR" | sed -e 's/[\/&]/\\&/g')
	ESCAPED_P2PATH=$(printf '%s\n' "$P2PATH" | sed -e 's/[\/&]/\\&/g')
	ESCAPED_SRCONFIGS=$(printf '%s\n' "$SRCONFIGS" | sed -e 's/[\/&]/\\&/g')
	cp -f  "$COMMONDIR/../.util/gameinfo/$GAMENAME.txt" "$GAMEARG/gameinfo.txt"
	sed -i "s/GAMEROOTGOESHERE/$ESCAPED_GAMEROOT/"   "$GAMEARG/gameinfo.txt"
	sed -i "s/COMMONDIRGOESHERE/COMMONDIRGOESHERE\"\nGame \"$ESCAPED_SRCONFIGS/" "$GAMEARG/gameinfo.txt"
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
		if ! [[ -d "$line" ]]; then continue; fi
		line=$(cd "$line" && pwd)
		if [[ "$MAIN_DIR" == "" ]]; then MAIN_DIR="$line"; fi
		if [[ "$line" != "$COMMONDIR" && "$line" != "$SRCONFIGS" ]]; then
			for commonCfg in "$COMMONDIR/cfg/"*; do
				if [[ -f "$line/cfg/$(basename "$commonCfg")" ]]; then
					mkdir -p "$line/cfg/.p2install-backup"
					mv -f "$line/cfg/$(basename "$commonCfg")" "$line/cfg/.p2install-backup/$(basename "$commonCfg")"
				fi
			done
			for srconfCfg in "$SRCONFIGS/cfg/"*; do
				if [[ -f "$line/cfg/$(basename "$srconfCfg")" ]]; then
					mkdir -p "$line/cfg/.p2install-backup"
					mv -f "$line/cfg/$(basename "$srconfCfg")" "$line/cfg/.p2install-backup/$(basename "$srconfCfg")"
				fi
			done
		fi
	fi
done < "$GAMEARG/gameinfo.txt"

if [[ -f "$COMMONDIR/../.util/.sar-build.txt" ]]; then
	rm -f "$COMMONDIR/../.util/.sar-build.txt"
	DEBUG=1
fi

# Make symlinks to the game's directories for convenience and install things
# Debatable whether svars should be common
mkdir -p "$COMMONDIR/../.dirs"; rm -f "$COMMONDIR/../.dirs/$GAMENAME"; ln -s "$GAMEPATH" "$COMMONDIR/../.dirs/$GAMENAME"

# platform.cfg
echo "svar_set gameplatform $PLATFORM"            > "$COMMONDIR/cfg/platform.cfg"
echo "svar_set windows $WINDOWS"                 >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set linux   $LINUX"                   >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set proton  $PROTON"                  >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set macos   $MACOSX"                  >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamearg \"$(basename $GAMEARG)\"" >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set gamename \"$GAMENAME\""           >> "$COMMONDIR/cfg/platform.cfg"
echo "svar_set username \"$(whoami)\""           >> "$COMMONDIR/cfg/platform.cfg"

# Pack VPKs for DLCs
highest_dlc=3 # TODO: Is this different for any games?
while [[ -d "portal2_dlc$highest_dlc/.root" ]]; do
	cd "portal2_dlc$highest_dlc"
	"$COMMONDIR/../.util/zvpk" ".root/"
	cd ..
	((highest_dlc++))
done

# Install saves for any games that have them
# Just copy into every steamid lol
if [[ -d "$COMMONDIR/../.util/saves/$GAMENAME" ]]; then
	for steamid in "$MAIN_DIR/SAVE/"*; do
		if [[ -d "$steamid" ]]; then
			cp -fr "$COMMONDIR/../.util/saves/$GAMENAME/"* "$steamid"
		fi
	done
fi
# Ditto for speedrun mods
if [[ -d "$COMMONDIR/../.util/srmods/$GAMENAME" ]]; then
	cp -fr "$COMMONDIR/../.util/srmods/$GAMENAME/"* "$MAIN_DIR"
fi

# if the game folder contains steam_appid.txt, copy to common/.util/.sar-appid.txt
if [[ -f "$GAMEROOT/steam_appid.txt" ]]; then
	cp -f "$GAMEROOT/steam_appid.txt" "$COMMONDIR/../.util/.sar-appid.txt"
	if [[ "$GAMENAME" == "Thinking with Time Machine" ]]; then
		# TWTM's steam_appid.txt says 620, but it's actually 286080
		echo "286080" > "$COMMONDIR/../.util/.sar-appid.txt"
	fi
fi

if [[ "$LINUX" -eq 1 ]]; then
	STEAM_BIN="$STEAM/ubuntu12_32"
	STEAM_RT="$STEAM_BIN/steam-runtime"
	REAPER="$STEAM_BIN/reaper"
	WRAPPER="$STEAM_BIN/steam-launch-wrapper"
	if ! [[ -f "$WRAPPER" ]]; then WRAPPER="$1"; fi
	if ! [[ -f "$WRAPPER" ]]; then
		echo ERROR! LAUNCH WRAPPER NOT FOUND AT $WRAPPER! >> "$COMMONDIR/p2install.log"
		echo In launch of: $@ >> "$COMMONDIR/p2install.log"
		echo "" >> "$COMMONDIR/p2install.log"
		exit 1
	fi
	if ! [[ -f "$REAPER" ]]; then REAPER="$3"; fi
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

echo "    PLATFORM: $PLATFORM (PROTON $PROTON)" >> "$COMMONDIR/p2install.log"
echo "    GAMEROOT: $GAMEROOT (GAME $GAMEARG)" >> "$COMMONDIR/p2install.log"
echo "     GAMEEXE: $GAMEEXE" >> "$COMMONDIR/p2install.log"
echo "INITIAL_ARGS: $@" >> "$COMMONDIR/p2install.log"
echo "  EXTRA_ARGS: $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
echo "    GAMENAME: $GAMENAME" >> "$COMMONDIR/p2install.log"
echo "   COMMONDIR: $COMMONDIR" >> "$COMMONDIR/p2install.log"
echo "  FINAL_ARGS: \"./$GAMEEXE\" -game \"$GAMEARG\" $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
echo "" >> "$COMMONDIR/p2install.log"

cd "$GAMEROOT"

if [[ -f "$COMMONDIR/cfg/p2install-extra.sh" ]]; then
	"$COMMONDIR/cfg/p2install-extra.sh"
fi

if [[ "$WINDOWS" -eq 1 ]]; then
	"./$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS

	exit $ERRORLEVEL
elif [[ "$LINUX" -eq 1 ]]; then

	STATUS=42
	while [ $STATUS -eq 42 ]; do
		if [[ "$PROTON" == 1 ]]; then
			echo "FULL BOI ARGS: \"$WRAPPER\" -- \"$REAPER\" SteamLaunch \"$5\" -- \"$7\" --verb=waitforexitandrun -- \"${10}\" waitforexitandrun \"./$GAMEEXE\" -game \"$GAMEARG\" $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
			echo "" >> "$COMMONDIR/p2install.log"
			"$WRAPPER" -- "$REAPER" SteamLaunch "$5" -- "$7" --verb=waitforexitandrun -- "${10}" waitforexitandrun "./$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS
		else
			ulimit -n 2048 # Limit the game to at most 2048 files open at once (why?)
			echo "FULL BOI ARGS: \"$WRAPPER\" -- \"$REAPER\" SteamLaunch \"$5\" -- \"$7\" --verb=waitforexitandrun -- \"${10}\" -- \"./$GAMEEXE\" -game \"$GAMEARG\" $EXTRA_ARGS" >> "$COMMONDIR/p2install.log"
			echo "" >> "$COMMONDIR/p2install.log"
			# "$WRAPPER" -- "$REAPER" SteamLaunch "$5" -- "$7" --verb=waitforexitandrun -- "${10}" -- "./$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS
			"$WRAPPER" -- "$REAPER" SteamLaunch "$5" -- "${10}" -- "./$GAMEEXE" -game "$GAMEARG" $EXTRA_ARGS

			# if [[ "$DEBUG" -eq 1 ]]; then
			# 	gdb -p $(pgrep "$GAMEEXE")
			# fi
		fi
		STATUS=$?
	done
	exit $STATUS
fi
