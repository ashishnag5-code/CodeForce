/**
** @author        Joshna
** @date          08/08/2022
** @description   Controller for integration container component on loan and applicant
** Modification Log:
** --------------------------------------------------------------------------------------------
** Developer               Date            Description
** --------------------------------------------------------------------------------------------
** Joshna Palla            08/08/2022      Original Version
*/
public with sharing class IntegrationContainerController {
    /* Method to fetch integration status records for a loan/applicant. Depending on the parameter object name a dynamic query is created to
    * initiate status query. Related mapper fields are also part of the query as these are used for display on integration container component.
    * Before returning the integration status records, this method also removes the status records which aren't relevant for the stage.
    * Display only on Applicable Stages field on mapper indicates if a status record is relevant to any stage. For loan related integrations, the
    * stage name is derived by opportunity stage field. For applicants, stage is derived from all related loan applicants */
    @AuraEnabled
    public static Map<String, List<Integration_Checklist__c>> fetchIntegrationStatusDetails(List<String> recordIdList, String objectName) {
        Set<String> loanStages = new Set<String>();
        List<Integration_Checklist__c> applicableRecords = new List<Integration_Checklist__c>();
        Map<String, List<Integration_Checklist__c>> recIdstoIntStatusMap = new Map<String, List<Integration_Checklist__c>>();
        
        String queryString = 'SELECT Id, Response_Received_At__c, Status__c, Applicant__c, Loan__c, Integration_Master__r.Allow_Manual_Initiate_After__c, Integration_Master__r.Display_Level__c, '
            + 'Integration_Master__r.Allow_Refresh_After__c, Integration_Master__r.Component_Reference__c, Integration_Master__r.Is_Mandatory__c, '
            + 'Integration_Master__r.Dependent_Integration__c, CreatedDate, Integration_Master__r.Allow_User_to_Print_Results__c, Integration_Master__r.Is_Fintech_API__c, '
            + 'Integration_Master__r.User_Friendly_Label__c, Loan__r.StageName, LastModifiedBy.Name, Missing_Pre_requisites__c, Request_Initiated_At__c, Is_Auto__c, Integration_Master__r.Allow_PE_Retry__c '
            + 'FROM Integration_Checklist__c '
            + 'WHERE ';
            //+ 'WHERE Is_Latest__c = true AND Integration_Master__r.User_Friendly_Label__c != NULL AND '
            //+ 'Integration_Master__r.Component_Reference__c != NULL AND ';
        if (objectName == 'Opportunity') {
            queryString += 'Loan__c IN: recordIdList';
        } 
        else if (objectName == 'Loan_Application__c')
            queryString += 'Applicant__r.Loan__c IN:recordIdList';
        else {
            queryString += 'Applicant__c IN:recordIdList';
            //Not required as of now
            /*
            for (Applicant__c each : [SELECT Id, Loan__r.StageName FROM Applicant__c WHERE Id IN :recordIdList WITH SECURITY_ENFORCED]) {
               loanStages.add(each.Loan__r.StageName);
            }
            */
        }
        system.debug(LoggingLevel.Info,'objectName ' + objectName);
		system.debug(LoggingLevel.Info,'Int Record Query ' + queryString.substringBetween('WHERE'));
        List<Integration_Checklist__c> statusRecords = Database.query(String.escapeSingleQuotes(queryString));
        system.debug(LoggingLevel.Info,'Int Record Query ' + statusRecords);
        for (Integration_Checklist__c each : statusRecords) {
            // add this after Rule Engine deployment
            /*if (each.Integration_Master__r.Display_only_on_Applicable_Stages__c) {
                if (objectName == 'Opportunity') {
                    if (recIdstoIntStatusMap.get(each.Loan__c) == null){
                        recIdstoIntStatusMap.put(each.Loan__c, new List<Integration_Checklist__c>{each});
                    } else {
                        recIdstoIntStatusMap.get(each.Loan__c).add(each); 
                    }
                } else if (objectName == 'Applicant__c') {
                    List<String> applicableStages = each.Integration_Master__r.Applicable_Stages__c != null ? each.Integration_Master__r.Applicable_Stages__c.split(';'): new List<String>();
                    for (String eachStage : applicableStages) {
                        if (loanStages.contains(eachStage)) {
                            if(recIdstoIntStatusMap.get(each.Applicant__c) == null){
                                recIdstoIntStatusMap.put(each.Applicant__c,new List<Integration_Checklist__c>{each});
                            }else{
                                recIdstoIntStatusMap.get(each.Applicant__c).add(each); 
                            }
                            break;
                        }
                    }
                }
            } else {*/
                if (objectName == 'Opportunity') {
                    if(recIdstoIntStatusMap.get(each.Loan__c) == null){
                        recIdstoIntStatusMap.put(each.Loan__c,new List<Integration_Checklist__c>{each});
                    }else{
                        recIdstoIntStatusMap.get(each.Loan__c).add(each); 
                    }
                } else{
                    if(recIdstoIntStatusMap.get(each.Applicant__c) == null){
                        recIdstoIntStatusMap.put(each.Applicant__c,new List<Integration_Checklist__c>{each});
                    }else{
                        recIdstoIntStatusMap.get(each.Applicant__c).add(each); 
                    }
                }
            //}              
        }
        return recIdstoIntStatusMap;
    }
    
    @AuraEnabled
    public static Integration_Checklist__c fetchIntegrationStatusRecord(String recordId) {
        for (Integration_Checklist__c each : [SELECT Id, Response_Received_At__c, Status__c, Applicant__c, Loan__c, Integration_Master__r.Allow_Manual_Initiate_After__c,
                                           Integration_Master__r.Allow_Refresh_After__c, Integration_Master__r.Component_Reference__c,
                                           Integration_Master__r.Dependent_Integration__c, Integration_Master__r.Display_only_on_Applicable_Stages__c, CreatedDate,
                                           Integration_Master__r.User_Friendly_Label__c, Loan__r.StageName, LastModifiedBy.Name, Missing_Pre_requisites__c, Request_Initiated_At__c, Is_Auto__c,
                                           Integration_Master__r.Allow_PE_Retry__c FROM Integration_Checklist__c WHERE Id = :recordId WITH SECURITY_ENFORCED]) {
            return each;
        }
        return null;
    }
    
    @AuraEnabled
    public static ResponseWrapper fetchIntegrationStatusRecords(String recordId, String objectName) {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.commonStatusRecords = new List<Integration_Checklist__c>();
        responseWrapper.individualStatusRecords = new List<StatusWrapper>();
        Map<String, List<Integration_Checklist__c>> recIdstoIntStatusMap = new Map<String, List<Integration_Checklist__c>>();
        List<StatusWrapper> statusWrapperList = new List<StatusWrapper>();
        Map<String,String> recIdtoNameMap = new Map<String,String>();
        List<String> recIdsList = new List<String>();
        Boolean showIntegrationSplit = false;
        Id parentLoanId;
        recIdsList.add(recordId);
        User objUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        if (objectName == 'Opportunity') {
            //Not Required as of now
           // Opportunity loan = [Select Id, Name, Customer_Requested_Loan_Amount__c, OwnerId from Opportunity where id = :recordId];
           Opportunity loan = [Select Id, Name, OwnerId from Opportunity where id = :recordId WITH SECURITY_ENFORCED];
           responseWrapper.isOwner = UserInfo.getUserId() == loan.OwnerId;
        } 
        else {
            //for (Applicant__c each : [SELECT Id, Loan__r.OwnerId FROM Applicant__c WHERE Id = :recordId WITH SECURITY_ENFORCED]) {
            for (Applicant__c each : [SELECT Id, Loan__r.OwnerId FROM Applicant__c WHERE (Loan__c = :recordId OR Id =: recordId) WITH SECURITY_ENFORCED]) {
                  if (each.Loan__r.OwnerId == UserInfo.getUserId() || objUser.Profile.Name == 'System Administrator' || objUser.Profile.Name == 'Integration Admin') {
                  	recIdsList.add(each.Id);
                    responseWrapper.isOwner = true;
                    break;
                }
            }
        }
		/*
        for (User each : [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED]) {
            if (each.Profile.Name == 'System Administrator' || each.Profile.Name == 'Integration Admin') {
                responseWrapper.isOwner = true;
            }
        }
		*/
        /*
        if (objUser.Profile.Name == 'System Administrator' || objUser.Profile.Name == 'Integration Admin') {
            responseWrapper.isOwner = true;
        }
		*/
		system.debug(LoggingLevel.Info,'Before :  recIdstoIntStatusMap');
        recIdstoIntStatusMap = fetchIntegrationStatusDetails(recIdsList, objectName);
        system.debug(LoggingLevel.Info,'After :  recIdstoIntStatusMap ' + recIdstoIntStatusMap);
        
        if (recIdstoIntStatusMap.isEmpty()) {
            responseWrapper.noRecords = true;
            return responseWrapper;
        }

        for(String recId : recIdstoIntStatusMap.keySet()){
            StatusWrapper statusWrap = new StatusWrapper();
            statusWrap.recordId = recId;
            statusWrap.statusRecords = new List<Integration_Checklist__c>();
            for (Integration_Checklist__c each : recIdstoIntStatusMap.get(recId)) {
                if (showIntegrationSplit && each.Integration_Master__r.Display_Level__c == 'Common') {
                    if (parentLoanId == recId) {
                        responseWrapper.commonStatusRecords.add(each);
                    }
                } else {
                    statusWrap.statusRecords.add(each);
                }
            }
            statusWrap.objectName = objectName;
            statusWrap.recordName = recIdtoNameMap.get(recId);
            responseWrapper.individualStatusRecords.add(statusWrap);
        }
        system.debug(LoggingLevel.Info,'Response : ' + responseWrapper);
        return responseWrapper;
    }
    
    public class StatusWrapper{
        @AuraEnabled public String recordId;
        @AuraEnabled public List<Integration_Checklist__c> statusRecords;
        @AuraEnabled public String recordName;
        @AuraEnabled public String objectName;
    }

    public class ResponseWrapper {
        @AuraEnabled public List<Integration_Checklist__c> commonStatusRecords;
        @AuraEnabled public List<StatusWrapper> individualStatusRecords;
        @AuraEnabled public Boolean noRecords = false;
        @AuraEnabled public Boolean isOwner = false;
    }
}