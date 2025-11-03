[200~#!/bin/sh
export PATH="/usr/local/bin:/usr/bin:/bin"

# working AP piggyback Configuration
COMMUNITY="" SWITCHES=""
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
                echo "<<<<${cleanName}>>>>"
                echo "<<<local>>>"
                echo "0 IP-Address - IP: ${ip:-N/A}"
                echo "0 AP-Info - ${desc:-N/A}"
                echo "0 Parent-Device - Name: ${switchName}  IP: ${SW}"
                echo "<<<<>>>>"
                ;;
        esac
        idx=$((idx + 1))
    done
done
