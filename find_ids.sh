#!/bin/bash

DATEFORMAT="+%-m_%-d_%Y"

current=$(date)

while true; do
  formatted=$(date --date="${current}" ${DATEFORMAT})

  i=1
  failed=0
  until [ not ${good} ]; do
    id="${formatted}_${i}" 
    curl --silent http://gatherer.wizards.com/magic/draftools/draftviewer.asp?draftid=${id}| grep XML &> /dev/null
    good=$?
    
    if [[ ${good} ]]; then
      echo ${id}
    fi

    let i+=1
  done

  current=$(date --date="${current} -1 day")
  sleep 5
done
