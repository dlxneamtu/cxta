# XRD Lab Test Suite
*** Settings ***
Library        CXTA
Resource       cxta.robot
Library        Collections
Library        CXTA.robot.platforms.iosxr.routing
Resource       ${EXECDIR}/resources/project.resource
Variables      ${EXECDIR}/data/common.yaml

Suite Setup    setup-my-environment


*** Keywords ***
setup-my-environment
    [Documentation]     load the yaml topology file and connect to all devices defined therein
    use testbed "testbed.yaml"
    connect to all devices
#    connect to devices "upe-1"
*** Test Cases ***

Check ISIS Neighbor
    [Documentation]    verify isis neighbors are "Up"
    FOR    ${DUT}    IN    @{ALL_ISIS_DUTS}
        FOR    ${INTERFACE}    IN    @{${DUT}_ISIS_INTERFACE_LIST}
            iosxr verify isis neighbor on interface is up  device=${DUT}	interface=${INTERFACE}
        END
    END

Check BGB IPv4 Unicast Neighbor Connection state
    [Documentation]    verify bgp ipv4 unicast neighbors are "Up"
    FOR    ${DUT}    IN    @{ALL_BGP_UNI_DUTS}
        FOR    ${NEIGHBOR}    IN    @{${DUT}_BGP_UNI_NBR_LIST}
            iosxr verify bgp neighbor in command is up  device=${DUT}	command=show bgp ipv4 unicast summary   neighbor_ip=${NEIGHBOR}
        END
    END

Check BGB VPNv4 Unicast Neighbor Connection state
    [Documentation]    verify bgp vpnv4 unicast neighbors are "Up"
    FOR    ${DUT}    IN    @{ALL_BGP_VPNv4_DUTS}
        FOR    ${NEIGHBOR}    IN    @{${DUT}_BGP_VPNv4_NBR_LIST}
            iosxr verify bgp neighbor in command is up  device=${DUT}	command=show bgp vpnv4 unicast summary   neighbor_ip=${NEIGHBOR}
        END
    END

Check PCC Peer Connection state - PCE View
    [Documentation]    verify SR-PCE peer is "Up" - from PCE view
    FOR    ${PCC}    IN    @{PCC_PEER_LIST}
        iosxr verify pce ipv4 peer is up  device=sr-pce-1  peer=${PCC}
    END


Check PCE Peer Connection state - PCC View
    [Documentation]    verify SR-PCE peer is "Up" - from PCC view
    FOR    ${DUT}    IN    @{ALL_PCEP_DUTS}
        dneamtu iosxr verify segment routing pcc ipv4 peer is up  device=${DUT}  peer=${SR-PCE_PEER}
    END

Check L3VPN Route presence in RT
    [Documentation]    verify L3VPN Route presence in RT
    FOR    ${DUT}    IN    @{ALL_L3VPN_DUTS}
        FOR    ${VPN}    IN    @{${DUT}_L3VPN_NAMES}
            dneamtu iosxr verify l3vpn BGP routes are present  device=${DUT}  vpn_name=${VPN}
        END
    END