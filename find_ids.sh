#!/bin/bash

DATEFORMAT="+%-m_%-d_%Y"

if [[ $# > 0 ]]; then
  current="$1"
else
  current=$(date)
fi;

while true; do
  formatted=$(date --date="${current}" ${DATEFORMAT})

  i=1
  good=1
  until [[ ${good} == 0 ]]; do
    id="${formatted}_${i}" 
    curl --silent http://gatherer.wizards.com/magic/draftools/draftviewer.asp?draftid=${id}| grep XML &> /dev/null
    good=$?

    if [[ ${good} > 0 ]]; then
      echo ${id}
    fi

    let i+=1
  done

  current=$(date --date="${current} -1 day")
  sleep 5
done
