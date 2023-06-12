# CNC Lab Test Suite
*** Settings ***
Library        CXTA
Resource       cxta.robot
Library        Collections
Library        OperatingSystem
Library        RequestsLibrary
Library        CXTA.robot.platforms.iosxr.routing
Resource       ${EXECDIR}/resources/project.resource
Variables      ${EXECDIR}/data/common.yaml
Variables      ${EXECDIR}/data/cnc_config.yaml
Variables      ${EXECDIR}/data/lab_topology.yaml


Suite Setup    setup-cnc

*** Variables ***
@{sr_policies_brief_list}=
@{pce_sr_policies_brief_list}=

*** Keywords ***
setup-cnc
    use testbed "testbed.yaml"

check command-output of "${command}" for "${pattern}"
    ${output}=   execute command "${command}" on device "${cnc}"
    Should Contain   ${output}  ${pattern}

check command-output of "${command}" for absence of "${pattern}"
    ${output}=   execute command "${command}" on device "${cnc}"
    Should Not Contain   ${output}  ${pattern}

build topology node data
    ${topo_nodes}=  Create Dictionary
    ${topo_nodes_items}=  Create Dictionary
    ${topology_resp}=  GET  https://${cnc_ip}:${cnc_port}/crosswork/nbi/optima/v2/restconf/data/ietf-network-state:networks  headers=${headers}  verify=${False}  
    Should Be Equal As Strings  ${topology_resp.status_code}  200
    ${topology_resp_json}=  Evaluate   json.loads($topology_resp.content)

    FOR    ${node}    IN    @{topology_resp_json["ietf-network-state:networks"]}[network][0][node]
        ${topo_nodes_subitems}=  Create Dictionary
        ${if_ip_dict}=  Create Dictionary

        FOR  ${node_details}    IN   @{node}[ietf-network-topology-state:termination-point]
            ${if_dict}=  Create Dictionary
            ${if}  Set Variable  ${node_details}[tp-id]     
            ${if_ip}  Set Variable   ${node_details}[cisco-crosswork-topology-state:termination-point-attributes][l3-termination-point-attributes][ip-address][0] 
            Set To Dictionary    ${if_ip_dict}  ${if}  ${if_ip}
        END
        
        ${node_name}  Set Variable   ${node}[node-id] 
        ${router_id}  Set Variable  ${node}[ietf-l3-unicast-topology-state:l3-node-attributes][router-id][0]  
        Set To Dictionary  ${topo_nodes_subitems}  router-id  ${router_id}
        Set To Dictionary  ${topo_nodes_subitems}  interfaces  ${if_ip_dict}
        Set To Dictionary  ${topo_nodes_items}  ${node_name}  ${topo_nodes_subitems}
    END
    Set To Dictionary  ${topo_nodes}  returned_topo_nodes  ${topo_nodes_items}
    RETURN  ${topo_nodes}  

build topology link data
    ${topo_links}=  Create Dictionary
    ${topology_resp}=  GET  https://${cnc_ip}:${cnc_port}/crosswork/nbi/optima/v2/restconf/data/ietf-network-state:networks  headers=${headers}  verify=${False}  
    Should Be Equal As Strings  ${topology_resp.status_code}  200
    ${topology_resp_json}=  Evaluate   json.loads($topology_resp.content)

    FOR    ${link}    IN    @{topology_resp_json["ietf-network-state:networks"]}[network][0][ietf-network-topology-state:link]
        ${topo_links_items}=  Create Dictionary
        ${link_id}  Set Variable  ${link}[link-id]  
        ${system_id}  Set Variable  ${link}[ietf-l3-unicast-topology-state:l3-link-attributes][cisco-crosswork-isis-topology:isis-link-attributes][net][system-id]
        ${isis_level}  Set Variable  ${link}[ietf-l3-unicast-topology-state:l3-link-attributes][cisco-crosswork-isis-topology:isis-link-attributes][level]
        ${igp_metric}  Set Variable  ${link}[ietf-l3-unicast-topology-state:l3-link-attributes][metric1]
        ${te_metric}  Set Variable  ${link}[ietf-l3-unicast-topology-state:l3-link-attributes][metric2]
        Set To Dictionary  ${topo_links_items}  system-id  ${system_id}
        Set To Dictionary  ${topo_links_items}  isis_level  ${isis_level}
        Set To Dictionary  ${topo_links_items}  igp_metric  ${igp_metric}
        Set To Dictionary  ${topo_links_items}  te_metric  ${te_metric}
        Set To Dictionary  ${topo_links}  ${link_id}  ${topo_links_items}
    END
    RETURN  ${topo_links}
      
*** Test Cases ***

cnc authentication
    ${auth}=  Create List  ${rest_user}   ${rest_password}
    Create Session    cncsession    https://${cnc_ip}:${cnc_port}    auth=${auth}
    ${ticket1_resp}=  POST On Session  cncsession  /crosswork/sso/v1/tickets   data=${ticket1_data}
    Should Be Equal As Strings  ${ticket1_resp.status_code}  201
    ${ticket2_resp}=  POST On Session  cncsession  /crosswork/sso/v1/tickets/${ticket1_resp.content}   data=${ticket2_data}
    Should Be Equal As Strings  ${ticket2_resp.status_code}  200
    ${bearer}=  set variable  ${ticket2_resp.content}
    set global variable  ${bearer}
    ${headers}=  Create Dictionary  Content-Type=application/json  Authorization=Bearer ${bearer}
    set global variable  ${headers}

get cluster health
    Skip
    ${cluster_health_resp}=  GET  https://${cnc_ip}:${cnc_port}/crosswork/platform/v2/cluster/app/health/list  headers=${headers}  verify=${False}  
    Should Be Equal As Strings  ${cluster_health_resp.status_code}  200
    Should Not Match Regexp  ${cluster_health_resp.content.decode('utf-8')}  ("degraded":(?!0)\d{1})|("down":(?!0)\d{1})

get SR Policies from CNC
    Skip
    ${sr_policies_resp}=  GET  https://${cnc_ip}:${cnc_port}/crosswork/nbi/optima/v2/restconf/data/cisco-crosswork-segment-routing-policy:sr-policies  headers=${headers}  verify=${False}  
    Should Be Equal As Strings  ${sr_policies_resp.status_code}  200
    ${sr_policies_resp_json}=  Evaluate   json.loads($sr_policies_resp.content)
    FOR    ${policy}    IN    @{sr_policies_resp_json["cisco-crosswork-segment-routing-policy:sr-policies"]["policy"]}
        @{temp_list}=    Create List 
        Append To List  ${temp_list}  ${policy}[headend]  ${policy}[endpoint]  ${policy}[color]          
        Append To List  ${sr_policies_brief_list}  ${temp_list}
    END
    LOG  ${sr_policies_brief_list}

get SR Policies from SR-PCE
    Skip
    ${pce_auth}=  Create List  ${rest_pce_user}   ${rest_pce_password}
    Create Session    pcesession    http://${pce_ip}:${pce_port}    auth=${pce_auth}
    ${pce_sr_policies_resp}=  GET On Session  pcesession  http://${pce_ip}:${pce_port}/lsp/subscribe/txt
    Should Be Equal As Strings  ${pce_sr_policies_resp.status_code}  200
    ${pce_sr_policies_resp_json}=  Evaluate   json.loads($pce_sr_policies_resp.content)
    FOR    ${item}   IN      @{pce_sr_policies_resp_json["data_gpbkv"]}[1:]
            @{temp_list}=    Create List 
            FOR    ${subitem}   IN      ${item}[fields][1][fields]  
                Append To List  ${temp_list}  ${subitem}[8][fields][0][fields][0][string_value]  ${subitem}[8][fields][0][fields][1][string_value]  ${subitem}[5][uint32_value]    
            END
            Append To List  ${pce_sr_policies_brief_list}  ${temp_list}
    END
    LOG  ${pce_sr_policies_brief_list}
   
compare SR Policies
    Skip
    ${output}=   Run Keyword And Ignore Error  Lists Should Be Equal  ${sr_policies_brief_list}  ${pce_sr_policies_brief_list}
    #LOG  ${output}[0]  

verify expected nodes are present in topology
    Skip
    ${returned_topo_nodes}=  build topology node data
    @{expected_topo_nodes_keys} =  Get Dictionary Keys  ${expected_topo_nodes}
    @{returned_topo_nodes_keys} =  Get Dictionary Keys  ${returned_topo_nodes}[returned_topo_nodes]
    FOR  ${expected_node}  IN  @{expected_topo_nodes_keys}
        Run Keyword And Continue On Failure   List Should Contain Value    ${returned_topo_nodes_keys}    ${expected_node}
    END

verify if topology has more nodes than expected
    Skip
    ${returned_topo_nodes}=  build topology node data
    @{expected_topo_nodes_keys} =  Get Dictionary Keys  ${expected_topo_nodes}
    @{returned_topo_nodes_keys} =  Get Dictionary Keys  ${returned_topo_nodes}[returned_topo_nodes]
    FOR  ${returned_node}  IN  @{returned_topo_nodes_keys}
        Run Keyword And Continue On Failure    List Should Contain Value    ${expected_topo_nodes_keys}    ${returned_node}
    END

verify router_id accuracy
    Skip
    ${returned_topo_nodes}=  build topology node data
    @{returned_topo_nodes_keys} =  Get Dictionary Keys  ${returned_topo_nodes}[returned_topo_nodes]
    FOR  ${node_key}  IN  @{returned_topo_nodes_keys}
        Run Keyword And Continue On Failure   Should Be Equal As Strings  ${returned_topo_nodes}[returned_topo_nodes][${node_key}][router-id]  ${expected_topo_nodes}[${node_key}][router-id]
    END

verify expected topology nodes interfaces are present in topology
    Skip
    ${returned_topo_nodes}=  build topology node data
    @{expected_topo_nodes_keys} =  Get Dictionary Keys  ${expected_topo_nodes}
    FOR  ${expected_node}  IN  @{expected_topo_nodes_keys}  
        @{returned_topo_nodes_keys} =  Get Dictionary Keys  ${returned_topo_nodes}[returned_topo_nodes][${expected_node}][interfaces]
        FOR  ${if_key}  IN  @{expected_topo_nodes}[${expected_node}][interfaces]
            Run Keyword And Continue On Failure   List Should Contain Value    ${returned_topo_nodes_keys}  ${if_key}
        END  
    END

verify if topology nodes have more interfaces than expected
    Skip
    ${returned_topo_nodes}=  build topology node data
    @{returned_topo_nodes_keys}=  Get Dictionary Keys  ${returned_topo_nodes}[returned_topo_nodes]
    FOR  ${returned_node}  IN  @{returned_topo_nodes_keys}
        @{expected_topo_nodes_keys} =  Run Keyword And Continue On Failure  Get Dictionary Keys  ${expected_topo_nodes}[${returned_node}][interfaces]
        FOR  ${if_key}  IN  @{returned_topo_nodes}[returned_topo_nodes][${returned_node}][interfaces]
            Run Keyword And Continue On Failure   List Should Contain Value    ${expected_topo_nodes_keys}  ${if_key}
        END  
    END

verify expected links are present in topology
    Skip
    ${returned_topo_links}=  build topology link data
    @{expected_topo_links_keys}=  Get Dictionary Keys  ${expected_topo_links}
    @{returned_topo_links_keys}=  Get Dictionary Keys  ${returned_topo_links}
    FOR  ${expected_link}  IN  @{expected_topo_links_keys}
        Run Keyword And Continue On Failure   List Should Contain Value    ${returned_topo_links_keys}    ${expected_link}
    END

verify if topology has more links than expected
    Skip
    ${returned_topo_links}=  build topology link data
    @{expected_topo_links_keys}=  Get Dictionary Keys  ${expected_topo_links}
    @{returned_topo_links_keys}=  Get Dictionary Keys  ${returned_topo_links}
    FOR  ${returned_link}  IN  @{returned_topo_links}
        Run Keyword And Continue On Failure   List Should Contain Value    ${expected_topo_links_keys}    ${returned_link}
    END

verify links details accuracy
    ${returned_topo_links}=  build topology link data
    @{returned_topo_links_keys}=  Get Dictionary Keys  ${returned_topo_links}
    FOR  ${returned_link}  IN  @{returned_topo_links}
        Run Keyword And Continue On Failure   Should Be Equal As Strings    ${returned_topo_links}[${returned_link}][system-id]    ${expected_topo_links}[${returned_link}][system-id]
        Run Keyword And Continue On Failure   Should Be Equal As Strings    ${returned_topo_links}[${returned_link}][isis_level]    ${expected_topo_links}[${returned_link}][level]
        Run Keyword And Continue On Failure   Should Be Equal As Strings    ${returned_topo_links}[${returned_link}][igp_metric]    ${expected_topo_links}[${returned_link}][igp_metric]
        Run Keyword And Continue On Failure   Should Be Equal As Strings    ${returned_topo_links}[${returned_link}][te_metric]    ${expected_topo_links}[${returned_link}][te_metric]    
    END
#test
delete session
    Delete All Sessions