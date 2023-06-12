# CNC Lab Test Suite
*** Settings ***
Library        CXTA
Resource       cxta.robot
Library        Collections
Library        OperatingSystem
Library        RequestsLibrary
#Library        JSONLibrary
Resource       ${EXECDIR}/resources/project.resource
Variables      ${EXECDIR}/data/common.yaml
Variables      ${EXECDIR}/data/cnc_config.yaml


*** Variables ***
@{pce_sr_policies_brief_list}=
${json_path1}    $.data_gpbkv[1].fields[1].fields[0].name
${json_path2}    $.data_gpbkv[1].fields[1].fields[0].string_value


*** Test Cases ***

get SR Policies from SR-PCE
    ${pce_auth}=  Create List  ${rest_pce_user}   ${rest_pce_password}
    Create Session    pcesession    http://${pce_ip}:${pce_port}    auth=${pce_auth}
    ${pce_sr_policies_resp}=  GET On Session  pcesession  http://${pce_ip}:${pce_port}/lsp/subscribe/txt
    Should Be Equal As Strings  ${pce_sr_policies_resp.status_code}  200
    ${pce_sr_policies_resp_json}=  Evaluate   json.loads($pce_sr_policies_resp.content)
    ${json_items1}=  Get Value From Json  ${pce_sr_policies_resp_json}  ${json_path1}
    ${json_items2}=  Get Value From Json  ${pce_sr_policies_resp_json}  ${json_path2}
    Append To List  ${pce_sr_policies_brief_list}  ${json_items1}  ${json_items2}
    LOG  ${pce_sr_policies_brief_list} 

delete session
    Delete All Sessions