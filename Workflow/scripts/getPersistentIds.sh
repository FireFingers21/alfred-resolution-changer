#!/bin/zsh --no-rcs

readonly displayPlacerList=$(displayplacer list)

readonly screenResolution=$(awk -v persistentId="$persistentId" '
    BEGIN {FS=": "} $0 ~ persistentId {flag=1} flag && /^Resolution:/ {print $2; exit}
' <<< "${displayPlacerList}")
readonly screenType=$(awk -v persistentId="$persistentId" '
    BEGIN {FS=": "} $0 ~ persistentId {flag=1} flag && /^Type:/ {print $2; exit}
' <<< "${displayPlacerList}")

# awk -v persistentId="$persistentId" '
#     BEGIN {
#         # Array
#         modes[1]="54"
#         modes[2]="117"

#         FS=" "
#         print "{\"items\": ["
#     }
#     $0 ~ persistentId {flag=1} flag && /mode 54:/ {print $3}
#     /mode 117:/ {print $3; exit}
#     END {
#         print "]}"
#     }
# ' <<< "$(displayplacer list)"

# numbers=(10 20 30 40)

# Pass numbers as input to Awk
# awk '
# BEGIN {
#     a[1]
#     a[2]
#     a[3]
#     a[4]
#     for (i in a) {
#         print i
#     }
# }
# ' <<< "$(displayplacer list)"