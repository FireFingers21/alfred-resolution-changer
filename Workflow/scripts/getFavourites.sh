#!/bin/zsh --no-rcs

# Set variables if absent because runImmediately=1
if [[ -z "${serialID}" ]]; then
    displayList=$(displayplacer list)
    currentSubtitle=$(awk '/current mode$/ { subtitle=$0; sub(" <-- current mode", "", subtitle); print substr(subtitle, 3) }' <<< "${displayList}")
    serialID=$(awk '/^Serial screen id:/ { print substr($NF, 2) }' <<< "${displayList}")
fi

favouritesFile="${alfred_workflow_data}/${serialID}.favourites"
[[ -f "${favouritesFile}" ]] || (mkdir -p "${alfred_workflow_data}" && touch "${favouritesFile}" && xattr -w com.apple.metadata:kMDItemWhereFroms "${deviceName}" "${favouritesFile}")

awk -v serialID="$serialID" -v currentSubtitle="$currentSubtitle" -v sort_favourites="$sort_favourites" '
    BEGIN {
        print "{\"items\": ["
    }
    /^mode/ {
        mode=$2; sub(/:$/, "", mode)
        if (sort_favourites==1) {uid="\"uid\": \"" serialID "_" mode "\", "} else {uid=""}
        if ($4 ~ "hz") {
            hertz="@" substr($4, 4) "Hz"
            if ($6=="scaling:on") {scaled="(Scaled)"} else {scaled=""}
        } else {
            hertz=""
            if ($5=="scaling:on") {scaled="(Scaled)"} else {scaled=""}
        }
        if ($0 ~ currentSubtitle) {
            valid="false"
            icon="images/current.png"
            currentMode="<-- current mode"
        } else {
            valid="true"
            icon=""
            currentMode=""
        }
        printf "{%s\"title\": \"Mode %s — %s%s %s\", \"subtitle\": \"%s %s\", \"arg\": \"%s\", \"valid\": %s, \"icon\": {\"path\": \"%s\"}, \"mods\": {\"shift\": {\"valid\": true}, \"ctrl\": {\"arg\": \"%s\", \"valid\": true}}},", uid, mode, substr($3, 5), hertz, scaled, $0, currentMode, mode, valid, icon, mode
    }
    END {
        print "{\"title\": \"Add Favourites...\", \"arg\": \"addFavourite\", \"icon\": {\"path\": \"images/favourite.png\"}, \"mods\": {\"ctrl\": {\"subtitle\": \"\", \"valid\": false}}}]}"
    }
' "${favouritesFile}"