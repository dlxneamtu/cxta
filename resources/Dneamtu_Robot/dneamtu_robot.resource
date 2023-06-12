*** Settings ***
Library     CXTA
Resource    cxta.robot
Library     OperatingSystem
Library     DateTime
Library     String
Library     Collections
Library     RequestsLibrary
#Library     DebugLibrary

#Resource    keywords/sp_utility.resource
Resource    textfsm/textfsm.resource
Resource    keywords/dneamtu_iosxr_srte.resource
Resource    keywords/dneamtu_iosxr_l2vpn.resource
Resource    keywords/dneamtu_iosxr_l3vpn.resource


#*** Keywords ***
#sp set test pass
#    [Arguments]  ${comment}
#    Log     ${comment}    console=yes
#    Run Keyword And Ignore Error  add report comment "${comment}"
#
#sp set test fail
#    [Arguments]  ${comment}
#    IF  "Comparing parsed outputs" in """${comment}"""
#      Run Keyword And Continue On Failure    Fail    ${comment.split('Comparision analysis:')[0]}Differences found, recommend test engineer to check logs.
#    ELSE
#      Run Keyword And Continue On Failure    Fail    ${comment}
#    END
#    Run Keyword And Ignore Error  add report comment "${comment}"
#    Log     ${comment}    console=yes
#
#sp set test warn
#    [Arguments]  ${comment}
#    IF  "Comparing parsed outputs" in """${comment}"""
#      #${reduced_comment}=  Remove String Using Regexp  ${comment}  \\[PASS\\][ \\S]+[\\r\\n]+
#      #${reduced_comment}=  Remove String Using Regexp  ${reduced_comment}  \\[INFO\\][ \\S]+[\\r\\n]+
#      #Log     ${reduced_comment}    WARN    console=yes
#      Log     ${comment.split('Comparision analysis:')[0]}Differences found, recommend test engineer to check logs.    WARN    console=yes
#      Log     ${comment}    console=yes
#    ELSE
#      Log     ${comment}    WARN    console=yes
#    END
#    Run Keyword And Ignore Error  add report comment "${comment}"
#
#sp set test comment
#    [Arguments]  ${comment}
#    Log     ${comment}    console=yes
#    Run Keyword And Ignore Error  add report comment "${comment}"
#
#sp set test title
#    [Arguments]  ${title}
#    Log     ${title}
#    Run Keyword And Ignore Error  add report line break
#    Run Keyword And Ignore Error  add report title "${title}"
#    Log To Console     \n========== ${title} ==========\n
#
