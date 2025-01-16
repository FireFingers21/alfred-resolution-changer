#!/bin/zsh --no-rcs

displayList=$(displayplacer list)
displayCount=$(echo ${displayList} | grep "Serial screen id:" | wc -l)
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
        /^Serial screen id:/ { screenId=substr($NF, 2) }
        /^Type:/ {
            if ($NF=="MacBook built in screen") {type="Mac built in screen"} else {type=$NF}
        }
        /^Resolution:/ { resolution=$NF }
        /^Hertz:/ { hertz="@" $NF "Hz" }
        /^Scaling:/ { if ($NF=="on") {scaled="(Scaled)"} else {scaled=""} }
        /^Enabled:/ { if ($NF=="true") run="true" }
        /current mode$/ {
            if (run=="true") {
                if (sort_displays==1) {uid="\"uid\": \"" screenId "\", "} else {uid=""}
                subtitle=$0; sub(" <-- current mode", "", subtitle)
                mode=substr($1, 3); sub("mode ", "", mode)
                metadata=type; gsub(/ /, "_", metadata)
                printf "{%s\"title\": \"%s\", \"subtitle\": \"Current Resolution: %s%s %s\", \"icon\": {\"path\": \"images/external.png\"}, \"variables\": {\"serialID\": \"%s\", \"deviceName\": \"%s\", \"currentTitle\": \"Current resolution: Mode %s — %s%s %s\", \"currentSubtitle\": \"%s\"}},", uid, type, resolution, hertz, scaled, screenId, metadata, mode, resolution, hertz, scaled, substr(subtitle, 3)
            }
        }
        END {
            print "]}"
        }
    ' <<< "${displayList}"
fi