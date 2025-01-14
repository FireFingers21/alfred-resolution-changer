#!/bin/zsh --no-rcs

favouritesFile="${alfred_workflow_data}/${persistentID}.favourites"

duplicate=false
while IFS= read -r line; do
    [[ ${line} == ${1} ]] && duplicate=true
done < "${favouritesFile}"

[[ ${duplicate} != true ]] && echo "$1" >> "${favouritesFile}"