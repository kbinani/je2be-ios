#!/bin/bash

function cat_unused_translation {
	local world=$1
	local langfile=$2

	(
		cat "$langfile" | sed 's/^\"\([^"]*\)\".*/\1/g'
		cat "$words"
	) | sort | uniq -c | grep -v '[ ]*2'
}

(
cd "$(dirname "$0")/.."
set -ue

words=$(mktemp)
(git ls-files | grep swift) | xargs cat | grep gettext | grep -v func | sed 's/.*gettext("\([^"]*\)").*/\1/g' | sort | uniq > "$words"

src=$(mktemp)
echo "func gettext(_ s: String) -> String {" > "$src"
echo "    let language = NSLocale.preferredLanguages.first ?? \"en\"" >> "$src"
echo "    switch language {" >> "$src"
for langfile in $(ls -1 localization/*.lang); do
	lang=$(basename $langfile | sed 's/\.lang//g')
	echo "    case \"$lang\":" >> "$src"
	echo "        switch s {" >> "$src"
	while read word; do
		translated=$(cat "$langfile" | grep "^\"$word\"" | sed "s/^\"$word\"[ ]*=[ ]*\"\([^\"]*\)\";$/\\1/g")
		if [ -z "$translated" ]; then
			echo "error: no translation found for \"$word\""
			rm -f "$words" "$src"
			exit 1
		fi
		echo "        case \"$word\": return \"$translated\"" >> "$src"
	done < "$words"
	echo "        default:" >> "$src"
	echo "            return s" >> "$src"
	echo "        }" >> "$src"

	unused=$(cat_unused_translation "$words" "$langfile" | wc -l)
	if [ "$unused" -gt 0 ]; then
		echo "Unused translations found for lang: $lang"
		cat_unused_translation "$words" "$langfile"
	fi
done
echo "    default:" >> "$src"
echo "        return s" >> "$src"
echo "    }" >> "$src"
echo "}" >> "$src"

mv "$src" src/Localization.swift
rm -f "$words"
)
