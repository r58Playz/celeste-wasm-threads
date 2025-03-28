#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

which ilspycmd &> /dev/null || {
	echo "Please install ilspycmd."
	exit 1
}

ILSPY="ilspycmd: 9.0.0.7889"
if ! [[ "$(ilspycmd --version | head -1)" =~ ^"$ILSPY" ]]; then
	echo "Incorrect ilspycmd version: '$(ilspycmd --version | head -1)' != '$ILSPY'"
	exit 1
fi

if ! [[ "$#" -eq "1" ]]; then
	echo "usage: bash tools/decompile.sh <celeste.exe>"
	exit 1
fi

rm -r celeste/Decompiled celeste/{Celeste,Celeste.Editor,Celeste.Pico8,Monocle,FMOD,FMOD.Studio} || true
ilspycmd -lv CSharp11_0 -p -o celeste/Decompiled "$1"
cp -r celeste/Decompiled/{Celeste,Celeste.Editor,Celeste.Pico8,Monocle,FMOD,FMOD.Studio} celeste/
rm celeste/Decompiled/Celeste.csproj
cp celeste/Decompiled/app.ico public/
