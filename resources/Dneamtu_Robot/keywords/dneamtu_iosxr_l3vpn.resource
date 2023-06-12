*** Settings ***
Resource     ../dneamtu_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# dneamtu iosxr verify l3vpn BGP routes are present
#
################################################################################


dneamtu iosxr verify l3vpn BGP routes are present
    [Documentation]  Verify that for a given L3VPN there is at least one BGP route being received as in command 'show ip route vrf $vpn_name'.
    ...
    ...              *Arguments:*
    ...              - ``group_name`` The xconnect group name
    ...              - ``device`` Optional. Use if you want this keyword to switch to the given device. If not used, then the currently connected device is used.
    ...
    ...              *Returns:* ${TRUE} or ${FALSE}
    ...
    ...              *Examples:*
    ...              | dneamtu iosxr verify evpn vpws xconnect group is up | device=ROUTER_A | group_name=BLACK_L2 |
    [Arguments]  ${vpn_name}  ${device}=${EMPTY}
    IF  "${device}" == "${EMPTY}"
      ${device}=  Get Current Device
    ELSE
      select device "${device}"
    END
    run "sho ip route vrf ${vpn_name}"
    ${status}=  Run Keyword And Return Status  extract pattern "B + (?:[0-9]{1,3}\.){3}[0-9]{1,3}"
    IF  ${status}
      sp set test pass  [ PASS ] Check that there is at least one L3VPN '${vpn_name}' BGP route in the RT on device '${device}' : Check passed, there is at least one BGP route as per 'show ip route vrf ${vpn_name}'
    ELSE
      sp set test fail  [ FAIL ] Check that there is at least one L3VPN '${vpn_name}' BGP route in the RT on device '${device}' : Check failed, there is no BGP route as per 'show ip route vrf ${vpn_name}'
    END
    [Return]  ${status}
