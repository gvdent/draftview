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
    echo "${URL}&player=${pl}&pack=1&pick=${pi}&showpick=true"
  done
done
