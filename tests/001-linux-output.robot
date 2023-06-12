# This is my first CXTA test suite
*** Settings ***
Library        CXTA
Resource       cxta.robot

Suite Setup    load testbed "testbed.yaml"

*** Variables ***
${hostname}     staging

*** Keywords ***
check command-output of "${command}" for "${pattern}"
    connect to device "${hostname}"
    ${output}=   execute command "${command}" on device "${hostname}"
    Should Contain   ${output}  ${pattern}

#*** Test Cases ***
#Check for specific output
#    connect to device "${hostname}"
#    ${output}=   execute command "ls /" on device "${hostname}"
#    Should Contain   ${output}  tmpxx

*** Test Cases ***

Check ls command
    check command-output of "ls /" for "tmp"

Check ps command
    check command-output of "ps -ef" for "init"

Check env command
    check command-output of "env" for "HOME="
