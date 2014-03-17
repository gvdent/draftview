#!/bin/bash

set -e 

if [ -z "$1" ]; then
  echo "One argument expected: the base draft url"
  exit 1
else
  URL=$1
fi;

for pl in {1..8}; do
  for pi in {1..4}; do
    CARDURL=$(curl --silent "${URL}&player=${pl}&pack=1&pick=${pi}&showpick=true" | grep "class='pickedcardimage'" | sed -e "s/.*src='\([^']*\)'.*/\1/")

    LOCALFILE=card-$(( ( ( ${pl} + ${pi} - 2 ) % 8) + ( ( ${pi} - 1) * 8) + 1 )).jpg
    echo ${LOCALFILE}

    curl --silent ${CARDURL} > ${LOCALFILE}
  done
done
