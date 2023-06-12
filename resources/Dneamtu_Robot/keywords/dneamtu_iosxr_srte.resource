*** Settings ***
Resource     ../dneamtu_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# dneamtu iosxr verify segment routing pcc ipv4 peer is up
#
################################################################################


dneamtu iosxr verify segment routing pcc ipv4 peer is up
    [Documentation]  Verify that a PCC IPv4 peer is up for the given peer in command 'show segment-routing traffic-eng pcc ipv4 peer brief'.
    ...
    ...              *Arguments:*
    ...              - ``peer`` The IP address of the PCC peer to check
    ...              - ``device`` Optional. Use if you want this keyword to switch to the given device. If not used, then the currently connected device is used.
    ...
    ...              *Returns:* ${TRUE} or ${FALSE}
    ...
    ...              *Examples:*
    ...              | dneamtu iosxr verify segment routing pcc ipv4 peer is up | device=ROUTER_A | expected_peer=1.1.1.1 |
    [Arguments]  ${peer}  ${device}=${EMPTY}
    IF  "${device}" == "${EMPTY}"
      ${device}=  Get Current Device
    ELSE
      select device "${device}"
    END
    run "show segment-routing traffic-eng pcc ipv4 peer brief"
    ${status}=  Run Keyword And Return Status  extract pattern "${peer} + .* + up"
    IF  ${status}
      sp set test pass  [ PASS ] Check that SR PCC ipv4 peer '${peer}' is up on device '${device}' : Check passed, peer is shown as up in 'show segment-routing traffic-eng pcc ipv4 peer brief'
    ELSE
      sp set test fail  [ FAIL ] Check that SR PCC ipv4 peer '${peer}' is up on device '${device}' : Check failed, peer is not shown as up in 'show segment-routing traffic-eng pcc ipv4 peer brief'
    END
    [Return]  ${status}
