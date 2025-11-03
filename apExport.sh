#!/bin/sh
export PATH="/usr/local/bin:/usr/bin:/bin"

# working AP piggyback Configuration
COMMUNITY="BkejGc3hslt1" SWITCHES="10.0.0.2 10.0.0.3 10.0.0.4 10.39.93.18 10.0.0.6"
# LLDP MIBs
LLDP_REM_SYSNAME_OID="1.0.8802.1.1.2.1.4.1.1.9"
LLDP_REM_SYSDESC_OID="1.0.8802.1.1.2.1.4.1.1.10"
LLDP_REM_MANADDR_OID="1.0.8802.1.1.2.1.4.2.1.4"

for SW in $SWITCHES; do
    switchName=$(snmpget -v2c -c "$COMMUNITY" -Oqv "$SW" sysName.0 2>/dev/null)
    [ -z "$switchName" ] && switchName="$SW"

    descArray=$(snmpwalk -v2c -c "$COMMUNITY" -Oqv "$SW" "$LLDP_REM_SYSDESC_OID" 2>/dev/null)
    nameArray=$(snmpwalk -v2c -c "$COMMUNITY" -Oqv "$SW" "$LLDP_REM_SYSNAME_OID" 2>/dev/null)
    ipArray=$(snmpwalk -v2c -c "$COMMUNITY" -On "$SW" "$LLDP_REM_MANADDR_OID" 2>/dev/null \
        | sed -nE 's/.*\.1\.4\.([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) =.*/\1/p')

    IFS='
'
    set -f
    set -- $nameArray
    nameList="$*"
    nameCount=$#

    descList=$(echo "$descArray" | awk NF)
    ipList=$(echo "$ipArray" | awk NF)

    idx=1
    echo "$nameArray" | while IFS= read -r name; do
        desc=$(echo "$descList" | sed -n "${idx}p")
        ip=$(echo "$ipList" | sed -n "${idx}p")

        # Strip surrounding double quotes if present
        cleanName=$(echo "$name" | sed 's/^"//; s/"$//')

        case "$desc" in
            *AP*|*ap*|*Cambium*|*WiFi*)
                echo "${cleanName}, ${ip:-N/A}, ${desc:-N/A}, ${switchName}, ${SW}"
                ;;
        esac
        idx=$((idx + 1))
    done
done
