#!/bin/zsh --no-rcs

awk -v currentTitle="$currentTitle" -v currentSubtitle="$currentSubtitle" -v persistentID="$persistentID" '
    BEGIN {
        print "{\"items\": ["
        printf "{\"title\": \"%s\", \"subtitle\": \"%s\", \"arg\": \"%s\", \"icon\": {\"path\": \"images/current.png\"}},", currentTitle, currentSubtitle, currentSubtitle
    }
    $0 ~ persistentID {flag=1} flag && /^Persistent screen id:/ { run="true" }
    /current mode$/ { next }
    /mode/ {
        if (run=="true") {
            subtitle=$0; sub($1, "", subtitle); sub($2, "", subtitle)
            mode=$2; sub(/:$/, "", mode)
            if ($6=="scaling:on") {scaled="(Scaled)"} else {scaled=""}
            printf "{\"title\": \"Mode %s — %s@%sHz %s\", \"subtitle\": \"%s\", \"arg\": \"%s\"},", mode, substr($3, 5), substr($4, 4), scaled, substr(subtitle, 5), substr($0, 3)
        }
    }
    /^$/ { if (run=="true") { exit } }
    END {
        print "]}"
    }
' <<< "$(displayplacer list)"