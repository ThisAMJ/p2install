#!/bin/bash
COMMONDIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
GAMEROOT="$PWD"

GAMEPATH="$1"
GAME=$(basename "$PWD")
if [[ "$GAMEPATH" =~ Portal\ 2\ Speedrun\ Mod$ ]]; then
    GAME="Portal 2 Speedrun Mod"
fi

shift

STEAM_RT="$HOME/.local/share/Steam/ubuntu12_32/steam-runtime"
REAPER="$STEAM_RT/../reaper"

echo ""
echo STEAM
echo $STEAM_RT
echo $GAMEROOT
echo $COMMONDIR
echo $GAMEPATH
echo $GAME

echo ""
echo LB_LIBRARY_PATH_INITIAL $LD_LIBRARY_PATH
export LD_LIBRARY_PATH=""
export LD_LIBRARY_PATH="$GAMEROOT/bin/linux32:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$GAMEROOT/bin:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$STEAM_RT/pinned_libs_32:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$STEAM_RT/lib/i386-linux-gnu:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$STEAM_RT/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$STEAM_RT/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$STEAM_RT/usr/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/lib32:$LD_LIBRARY_PATH"
echo LD_LIBRARY_PATH $LD_LIBRARY_PATH

echo ""
echo LD_PRELOAD_INITIAL $LD_PRELOAD
export LD_PRELOAD=""
export LD_PRELOAD="$STEAM_RT/../gameoverlayrenderer.so:$LD_PRELOAD"
echo LD_PRELOAD $LD_PRELOAD

GAMEEXE=portal2

EXTRA_ARGS="-novid +mat_motion_blur_enabled 0 -background 4 -condebug"

# Vulkan seems to crash Mel, Reloaded, and Aptag upon launch
if ! [[ "$GAME" == "Portal Stories Mel" || "$GAME" == "Portal Reloaded" || "$GAME" == "Aperture Tag" ]]; then
    EXTRA_ARGS="$EXTRA_ARGS -vulkan"
fi

if [[ "$GAME" == "Portal Reloaded" ]]; then
    EXTRA_ARGS="$EXTRA_ARGS -console"
fi

if [[ "$GAME" == "Thinking with Time Machine" ]]; then
    GAMEEXE=TWTM
fi

echo ""
echo ARGS
echo $EXTRA_ARGS

# Repair gameinfo with p2common
if [[ -f "$COMMONDIR/.util/gameinfo/$GAME.txt" ]]; then
    echo "Installing p2common..."
    ESCAPED_GAMEROOT=$(printf '%s\n' "$GAMEROOT" | sed -e 's/[\/&]/\\&/g')
    ESCAPED_COMMONDIR=$(printf '%s\n' "$COMMONDIR" | sed -e 's/[\/&]/\\&/g')
    cp -f  "$COMMONDIR/.util/gameinfo/$GAME.txt"     "$GAMEROOT/$GAMEPATH/gameinfo.txt"
    sed -i "s/GAMEROOTGOESHERE/$ESCAPED_GAMEROOT/"   "$GAMEROOT/$GAMEPATH/gameinfo.txt"
    sed -i "s/COMMONDIRGOESHERE/$ESCAPED_COMMONDIR/" "$GAMEROOT/$GAMEPATH/gameinfo.txt"
fi

# Remove Portal Reloaded's default autoexec.cfg if we have a common one
if [[ "$GAME" == "Portal Reloaded" ]]; then
    if [[ -f "$COMMONDIR/cfg/autoexec.cfg" ]]; then
        if [[ -f "$GAMEROOT/portalreloaded/cfg/autoexec.cfg" ]]; then
            if cmp --silent -- "$GAMEROOT/portalreloaded/cfg/autoexec.cfg" "$COMMONDIR/.util/reloaded-original-autoexec1.cfg" ||
            cmp --silent -- "$GAMEROOT/portalreloaded/cfg/autoexec.cfg" "$COMMONDIR/.util/reloaded-original-autoexec2.cfg"; then
                echo "Removing Portal Reloaded default autoexec.cfg ($GAMEROOT/portalreloaded/cfg/autoexec.cfg)..."
                rm "$GAMEROOT/portalreloaded/cfg/autoexec.cfg"
            fi
        fi
    fi
fi

# Pack VPKs for DLCs
highest_dlc=3 # TODO: Is this different for any games?
while [[ -d "portal2_dlc$highest_dlc" ]]; do
    cd "portal2_dlc$highest_dlc"
    if [[ -d ".root" ]]; then
        echo ""
        echo "VPK packing portal2_dlc$highest_dlc/.root"
        zvpk .root/
    fi
    cd ..
    ((highest_dlc++))
done

GAMEEXE+=_linux

ulimit -n 2048

cd "$GAMEROOT"

STATUS=42
while [ $STATUS -eq 42 ]; do
    if [ "$GAME_DEBUGGER" == "gdb" ]; then
        ARGSFILE="$(mktemp /tmp/portal2.gdb.XXXX)"
        echo "run $@ -steam $EXTRA_ARGS -game \"$GAMEPATH\"" > "$ARGSFILE"
        echo show args >> "$ARGSFILE"
        "$REAPER" -- $GAME_DEBUGGER "$GAMEROOT/$GAMEEXE" -x "$ARGSFILE"
        rm "$ARGSFILE"
    else
        echo ""
        echo "ALLARGS"
        echo "\"$REAPER\" -- $GAME_DEBUGGER \"$GAMEROOT/$GAMEEXE\" \"\" -steam $EXTRA_ARGS -game \"$GAMEPATH\""
        echo ""
        "$REAPER" -- $GAME_DEBUGGER "$GAMEROOT/$GAMEEXE" "" -steam $EXTRA_ARGS -game "$GAMEPATH"
    fi
	STATUS=$?
done
exit $STATUS
