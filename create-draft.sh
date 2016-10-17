#!/bin/bash

set -e 

TMPDIR="tmp/"
RESULTDIR="drafts/"
CARDSUFFIX="-card.jpg"
CACHEDIR="cache/"

FILE=""
function getFile {
  FILEURL=$1
  FILE=${CACHEDIR}$(echo "${FILEURL}" | md5sum | awk '{ print $1 }')

  if [ ! -f ${FILE} ]; then
    curl --silent "${FILEURL}" > ${FILE}
  fi;
}

if [ $# -eq 0  ]; then
  echo "One argument expected: the draft id"
  exit 1
else
  URL="http://gatherer.wizards.com/magic/draftools/draftviewer.asp?draftid=$1"
fi

if [ "$#" -ge 2 ]; then
  ROWS="$2"
else
  ROWS=15
fi

RESULTFILE="${RESULTDIR}$1-${ROWS}.jpg"

for pl in {1..8}; do
  for pi in $(eval echo {1..${ROWS}}); do
    getFile "${URL}&player=${pl}&pack=1&pick=${pi}&showpick=true"
    if (( ${pl} == 1 && $pi == 1 ));
    then
      iconv -f windows-1252 -t ascii//TRANSLIT "${FILE}" | grep Player | sed -e "s/.*option value='\([^']*\)'[^>]*>Player: \([^<]*\)<.*/\1 \2/" | sort | uniq | sed -e 's/[0-9] //' > players
    fi
    CARDURL=$(iconv -f windows-1252 -t ascii//TRANSLIT "${FILE}" | grep "class='pickedcardimage'" | sed -e "s/.*src='\([^']*\)'.*/\1/")

    # We need to go from player 8 to 1, since players pass to the higher player 
    # number, and we want the packs to be in the columns, and player picks from
    # top left to lower right. So player 8 is in column 0, and his second pick
    # comes from column 1.

    p=$(( 8 - ${pl} ))  # 0 based player
    k=$(( ${pi} - 1 ))  # 0 based pick

    row=${k}
    col=$(( ( ${p} + ${k} ) % 8 ))


    LOCALFILE="${TMPDIR}$(( ( 8 * ${row} ) + ${col} ))${CARDSUFFIX}"

    getFile "${CARDURL}"
    cp "${FILE}" "${LOCALFILE}"
  done
done

CARDS=$(eval echo ${TMPDIR}{0..$(( ( 8 * ${ROWS}) - 1))}${CARDSUFFIX})

montage -background black -geometry 200x285+1+1 -verbose -tile 8x${ROWS} ${CARDS} ${RESULTFILE}

i=1
while read p; do
  convert -background white -fill black  -font Arial -size 202x20 "label:${p}" ${i}.gif
  i=$((${i} + 1))
done < players

convert 8.gif 7.gif 6.gif 5.gif 4.gif 3.gif 2.gif 1.gif +append players.gif
convert players.gif ${RESULTFILE} -append annotated.jpg

mv annotated.jpg ${RESULTFILE}
rm *.gif

rm players
rm ${CARDS} 
