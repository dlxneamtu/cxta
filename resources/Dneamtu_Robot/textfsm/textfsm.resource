*** Settings ***

*** Variables ***
${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}=  ${CURDIR}/xr_show_route_vrf_summary.textfsm
${XR_SHOW_BGP_SUMMARY_TEMPLATE}=  ${CURDIR}/xr_show_bgp_summary.textfsm
${XR_SHOW_BGP_VRF_SUMMARY_TEMPLATE}=  ${CURDIR}/xr_show_bgp_vrf_summary.textfsm
${XR_SHOW_CONFIG_COMMIT_LIST_TEMPLATE}=  ${CURDIR}/xr_show_configuration_commit_list.textfsm
${XR_SHOW_MPLS_LDP_NEIGHBOR_BRIEF_TEMPLATE}=  ${CURDIR}/xr_show_mpls_ldp_neighbor_brief.textfsm
${XR_SHOW_SRTE_POLICY_TABULAR_TEMPLATE}=  ${CURDIR}/xr_show_srte_policy_tabular.textfsm
${XR_SHOW_OSPF_VRF_NEIGHBOR}=  ${CURDIR}/xr_show_ospf_vrf_neighbor.textfsm
${XR_SHOW_NV_SATELLITE_STATUS_BRIEF}=  ${CURDIR}/xr_show_nv_satellite_status_brief.textfsm
${XR_SHOW_PIM_VRF_NEIGHBOR}=  ${CURDIR}/xr_show_pim_vrf_neighbor.textfsm
${XR_SHOW_PIM_NEIGHBOR}=  ${CURDIR}/xr_show_pim_neighbor.textfsm

${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}=  ${CURDIR}/xe_show_isis_neighbors.textfsm
${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}=  ${CURDIR}/xe_show_ip_route_summary.textfsm
${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}=  ${CURDIR}/xe_show_ipv6_route_summary.textfsm

${SHOW_INVENTORY_TEMPLATE}=  ${CURDIR}/show_inventory.textfsm
*** Keywords ***

################################################################################
#
#     Examples how to use these textfsm templates
#
# ${parsed}=   run parsed "show route vrf xxxx summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
# ${parsed}=   run parsed "show bgp vpnv4 unicast summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
# ${parsed}=   run parsed "show configuration commit list" with template "${XR_SHOW_CONFIG_COMMIT_LIST_TEMPLATE}"
# ${parsed}=   run parsed "show mpls ldp neighbor brief" with template "${XR_SHOW_MPLS_LDP_NEIGHBOR_BRIEF_TEMPLATE}"
# ${parsed}=   run parsed "show segment-routing traffic-eng policy tabular" with template "${XR_SHOW_SRTE_POLICY_TABULAR_TEMPLATE}"
#
# ${parsed}=   run parsed "show isis neighbors" with template "${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}"
# ${parsed}=   run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
#
# ${parsed}=   run parsed "show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
# ${parsed}=   run parsed "admin show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
#
################################################################################
