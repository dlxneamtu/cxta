*** Settings ***
Resource     ../dneamtu_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# dneamtu iosxr verify evpn vpws xconnect group is up
#
################################################################################


dneamtu iosxr verify evpn vpws xconnect group is up
    [Documentation]  Verify that a EVPN VPWS xconnect group is up for the given group in command 'show l2vpn xconnect group $group_name'.
    ...
    ...              *Arguments:*
    ...              - ``group_name`` The xconnect group name
    ...              - ``device`` Optional. Use if you want this keyword to switch to the given device. If not used, then the currently connected device is used.
    ...
    ...              *Returns:* ${TRUE} or ${FALSE}
    ...
    ...              *Examples:*
    ...              | dneamtu iosxr verify evpn vpws xconnect group is up | device=ROUTER_A | group_name=BLACK_L2 |
    [Arguments]  ${group_name}  ${device}=${EMPTY}
    IF  "${device}" == "${EMPTY}"
      ${device}=  Get Current Device
    ELSE
      select device "${device}"
    END
    run "show l2vpn xconnect group ${group_name}"
    ${status}=  Run Keyword And Return Status  extract pattern "UP + .* + UP + .* + UP"
    IF  ${status}
      sp set test pass  [ PASS ] Check that VPWS group '${group_name}' is up on device '${device}' : Check passed, group is shown as up in 'show l2vpn xconnect group ${group_name}'
    ELSE
      sp set test fail  [ FAIL ] Check that VPWS group '${group_name}' is up on device '${device}' : Check failed, group is not shown as up in 'show l2vpn xconnect group ${group_name}'
    END
    [Return]  ${status}
