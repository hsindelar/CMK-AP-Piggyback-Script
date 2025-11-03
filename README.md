# APPiggyScript

CheckMK agent plugin scripts for discovering and monitoring wireless access points (APs) through SNMP/LLDP queries to network switches, using CheckMK's piggyback mechanism.

## Overview

These scripts query network switches via SNMP to discover connected access points using LLDP (Link Layer Discovery Protocol) data. The discovered APs are then reported to CheckMK as piggyback hosts, allowing centralized monitoring without requiring direct agent installation on the APs themselves.

## Scripts

### `apPiggy.sh`
Main plugin script that generates CheckMK piggyback data for discovered access points.

**Output format:** CheckMK piggyback data with local checks for each discovered AP
- IP address
- Device description
- Parent switch information

### `apExport.sh`
Utility script that exports discovered AP information in CSV format for inventory and reporting purposes.

**Output format:** `APName, IP, Description, SwitchName, SwitchIP`

## Requirements

- CheckMK agent installed on the monitoring host
- SNMP client tools (`snmpget`, `snmpwalk`)
- Network switches with:
  - SNMP v2c enabled
  - LLDP enabled and populated with neighbor data
- Read-only SNMP community string

## Configuration

Edit the scripts to configure your environment:

```bash
COMMUNITY="your_snmp_community"
SWITCHES="10.0.0.1 10.0.0.2 10.0.0.3"
```

**Variables:**
- `COMMUNITY`: SNMP community string for authentication
- `SWITCHES`: Space-separated list of switch IP addresses to query

## Installation

1. Copy `apPiggy.sh` to the CheckMK agent plugins directory:
   ```bash
   sudo cp apPiggy.sh /usr/local/lib/check_mk_agent/plugins/
   sudo chmod +x /usr/local/lib/check_mk_agent/plugins/apPiggy.sh
   ```

2. Configure your SNMP community and switch IPs in the script

3. Test the script manually:
   ```bash
   /usr/local/lib/check_mk_agent/plugins/apPiggy.sh
   ```

4. Perform service discovery in CheckMK to see the piggyback hosts

## How It Works

1. Script iterates through configured switches
2. For each switch, queries LLDP MIBs via SNMP:
   - `LLDP_REM_SYSNAME_OID` - Remote device hostname
   - `LLDP_REM_SYSDESC_OID` - Remote device description
   - `LLDP_REM_MANADDR_OID` - Remote device management IP
3. Filters results for devices matching AP patterns (AP, Cambium, WiFi)
4. Outputs piggyback data in CheckMK format with local checks

## AP Detection

The scripts identify access points by matching keywords in the LLDP system description:
- `*AP*` or `*ap*`
- `*Cambium*`
- `*WiFi*`

Modify the case statement in the scripts to match your specific AP models.

## CheckMK Piggyback Format

The `apPiggy.sh` script outputs data in CheckMK's piggyback format:

```
<<<<APHostname>>>>
<<<local>>>
0 IP-Address - IP: 10.0.0.100
0 AP-Info - Device Description
0 Parent-Device - Name: SwitchName  IP: 10.0.0.1
<<<<>>>>
```

This creates three local checks per AP in CheckMK with status 0 (OK).

## Use Cases

- Automated discovery of wireless access points
- Centralized AP monitoring without individual agents
- Inventory management and reporting
- Parent-child relationship tracking (AP to switch)

## Troubleshooting

**No output:**
- Verify SNMP community string is correct
- Check network connectivity to switches
- Ensure LLDP is enabled on switches
- Verify APs are properly connected and advertising LLDP

**Partial results:**
- Check SNMP permissions on switches
- Verify LLDP data is populated (`snmpwalk` manually)
- Review AP detection patterns in case statement

## License

MIT License - Feel free to modify and distribute

## Contributing

Pull requests welcome! Please test thoroughly in your environment before submitting.
