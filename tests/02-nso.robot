# NSO Lab Test Suite
*** Settings ***
Library        CXTA
Resource       cxta.robot
Library        Collections
Library        OperatingSystem
Library        CXTA.robot.platforms.iosxr.routing
Resource       ${EXECDIR}/resources/project.resource
Variables      ${EXECDIR}/data/common.yaml
Variables      ${EXECDIR}/data/nso_config.yaml

Suite Setup    setup-nso

*** Keywords ***
setup-nso
    use testbed "testbed.yaml"
    connect to device "${nso}"
    #${output}=   execute command "devices fetch-ssh-host-keys" on device "nso-576"
    #Should not contain   ${output}    result false
    #${output}=   execute command "devices check-sync" on device "nso-576"
    #Should not contain   ${output}    result false

collect "${state}" config from "${device}"
    connect to device "${device}"
    ${output}=   execute command "show running-config" on device "${device}"
    Create File   02-${device}-${state}.txt   ${output}

compare configs from "${device}"
    use ciscoconfdiff to compare ios configs "02-${device}-before.txt" and "02-${device}-after.txt"

diffs with "${expected_diffs}"
    compare latest ciscoconfdiff with reference diffs in "${expected_diffs}[0]" and "${expected_diffs}[1]"    
*** Test Cases ***

Create Service
    [Setup]     retrieve latest NSO rollback number from "${nso}"
    ${service_payload}=   render jinja2 template "${service_template}" with variables "${loopback_service}"
    collect "before" config from "${loopback_service.device}"
    via NSO REST API configure device "${nso}" at URI "/restconf/data/loopback-service:loopback-service" using "PATCH" with "xml" payload "${service_payload}"
    collect "after" config from "${loopback_service.device}"
    compare configs from "${loopback_service.device}" 
    diffs with "${diffs.src}"
    [Teardown]    Wait Until Keyword Succeeds    2x   100ms    rollback NSO "${nso}" to rollback retrieved

