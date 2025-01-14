#!/bin/zsh --no-rcs

favouritesFile="${alfred_workflow_data}/${persistentID}.favourites"

newFavourites=$(awk -v favourite="$1" '
    /^mode/ {
        item=$2; sub(/:$/, "", item)
        if (item != favourite) { print $0 }
    }
' "${favouritesFile}")

echo "${newFavourites}" > "${favouritesFile}"
# Remove second line from file when favourites are empty
[[ $(wc -w <<< "${newFavourites}") -eq 0 ]] && > "${favouritesFile}"