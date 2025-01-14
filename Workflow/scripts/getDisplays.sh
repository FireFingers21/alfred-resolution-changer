#!/bin/zsh --no-rcs

displayList=$(displayplacer list)
displayCount=$(echo ${displayList} | grep "Persistent screen id:" | wc -l)
if [[ "${displayCount}" -eq 1 && "${runImmediately}" -eq 1 ]]; then
    osascript -e 'tell application id "com.runningwithcrayons.Alfred"
    	search text 1 thru -2 of (system attribute "alfred_workflow_keyword")
    	run trigger "showFavourites" in workflow "com.firefingers21.resolutionchanger"
    end tell'
else
    awk -v sort_displays="$sort_displays" '
        BEGIN {
            FS=": "
            print "{\"items\": ["
        }
        /^Persistent screen id:/ { screenId=$2 }
        /^Type:/ { type=$2 }
        /^Resolution:/ { resolution=$2 }
        /^Hertz:/ { hertz=$2 }
        /^Scaling:/ { if ($2=="on") {scaled="(Scaled)"} else {scaled=""} }
        /^Enabled:/ { if ($2=="true") run="true" }
        /current mode$/ {
            if (run=="true") {
                if (sort_displays==1) {uid="\"uid\": \"" screenId "\", "} else {uid=""}
                if (type ~ "MacBook") {
                    icon="images/macbook.png"
                } else {
                    icon="images/external.png"
                }
                subtitle=$0; sub(" <-- current mode", "", subtitle)
                mode=substr($1, 3); sub("mode ", "", mode)
                metadata=type; gsub(/ /, "_", metadata)
                printf "{%s\"title\": \"%s\", \"subtitle\": \"Current Resolution: %s@%sHz %s\", \"icon\": {\"path\": \"%s\"}, \"variables\": {\"persistentID\": \"%s\", \"deviceName\": \"%s\", \"currentTitle\": \"Current resolution: Mode %s — %s@%sHz %s\", \"currentSubtitle\": \"%s\"}},", uid, type, resolution, hertz, scaled, icon, screenId, metadata, mode, resolution, hertz, scaled, substr(subtitle, 3)
            }
        }
        END {
            print "]}"
        }
    ' <<< "${displayList}"
fi