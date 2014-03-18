#!/bin/bash

set -e 

TMPDIR="tmp/"
RESULTDIR="drafts/"
CARDSUFFIX="-card.jpg"

if [ -z "$1" ]; then
  echo "One argument expected: the draft id"
  exit 1
else
  URL="http://gatherer.wizards.com/magic/draftools/draftviewer.asp?draftid=$1"
fi;

RESULTFILE="${RESULTDIR}$1-4.jpg"

for pl in {1..8}; do
  for pi in {1..4}; do
    CARDURL=$(curl --silent "${URL}&player=${pl}&pack=1&pick=${pi}&showpick=true" | grep "class='pickedcardimage'" | sed -e "s/.*src='\([^']*\)'.*/\1/")

    # We need to go from player 8 to 1, since players pass to the higher player 
    # number, and we want the packs to be in the columns, and player picks from
    # top left to lower right. So player 8 is in column 0, and his second pick
    # comes from column 1.

    p=$(( 8 - ${pl} ))  # 0 based player
    k=$(( ${pi} - 1 ))  # 0 based pick

    row=${k}
    col=$(( ( ${p} + ${k} ) % 8 ))


    LOCALFILE="${TMPDIR}$(( ( 8 * ${row} ) + ${col} ))${CARDSUFFIX}"

    curl --silent "${CARDURL}" > "${LOCALFILE}"
  done
done

montage -background black -geometry 200x285+4+4 -verbose -tile 8x4 ${TMPDIR}{0..31}${CARDSUFFIX} ${RESULTFILE}

rm ${TMPDIR}{0..31}${CARDSUFFIX}
