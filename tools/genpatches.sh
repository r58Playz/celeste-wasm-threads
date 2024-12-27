#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

which diff &> /dev/null || {
	echo "Please install diff."
	exit 1
}

if ! [[ -d "celeste/Decompiled" ]]; then
	echo "Please run tools/decompile.sh first"
fi

rm -r celeste/Patches

DECOMPDIR="celeste/Decompiled/"
find "$DECOMPDIR"{Celeste,Celeste.Editor,Celeste.Pico8,Monocle} -type f -name "*.cs" | while read -r file; do
	file="${file#${DECOMPDIR}}"
	patch="celeste/Patches/Code/$file.patch"


	mkdir -p "$(dirname "$patch")"
	diff=$(diff -u "$DECOMPDIR/$file" "celeste/$file" || true)

	echo -e "$diff"

	if [ -n "$diff" ]; then
		echo "writing diff for $file"
		echo -n "$diff" > "$patch"
	fi
done
