public class IntegrationChecklistTriggerService implements ServiceInterface {
     
    public void beforeInsert(List<sObject> newRecordList){
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        system.debug('inside afterInsert IntegrationChecklistTriggerService>>>');    
        EMandateStatusService.checkCallbackStatus((List<Integration_Checklist__c >) newRecordList);
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
       List<Integration_Checklist__c> breIntgrationChkLst = new List<Integration_Checklist__c>();
       system.debug('after update IntegrationChecklistTriggerService>>>');
       updateApplcntAfterAMLCallback((List<Integration_Checklist__c >) newRecordList, (Map<Id,Integration_Checklist__c>) oldRecordMap);

       system.debug('Update Bank Account Records');
       MultipleFileUploadController.updateBankAccountStatementDetails((List<Integration_Checklist__c>)newRecordList, (Map<Id, Integration_Checklist__c>)oldRecordMap, (Map<Id, Integration_Checklist__c>)newRecordMap);
       AUSFValuationController.updateValuationDetails((List<Integration_Checklist__c>)newRecordList, (Map<Id, Integration_Checklist__c>)oldRecordMap, (Map<Id, Integration_Checklist__c>)newRecordMap);
    	EMandateStatusService.checkCallbackStatus((List<Integration_Checklist__c >) newRecordList);
        for(Integration_Checklist__c ic : (List<Integration_Checklist__c>)newRecordList){
            if(ic.Integration_Master_Name__c == 'FICO BRE')
                breIntgrationChkLst.add(ic);
        }
        system.debug('breIntgrationChkLst'+breIntgrationChkLst);
        if(breIntgrationChkLst.size() > 0){
        BREHandler.createBRERecord((List<Integration_Checklist__c>)breIntgrationChkLst, (Map<Id, Integration_Checklist__c>)oldRecordMap, (Map<Id, Integration_Checklist__c>)newRecordMap);
        }
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }
    
    public void updateApplcntAfterAMLCallback(List<Integration_Checklist__c > newRecordList, Map<Id,Integration_Checklist__c> oldRecordMap) {

        List<Integration_Checklist__c> integChkLst = [SELECT id, Integration_Master__r.Name, Applicant__c, Callback_Request__c, Response__c,Request__c
                                                      FROM Integration_Checklist__c where id =: oldRecordMap.keyset()];

        List<String> applcntIdLst = new List<String>();
        List<Applicant__c> updateApplcntLst = new List<Applicant__c>(); 
        system.debug('integChkLst--'+integChkLst);
        //Notification ||START
        String loanId;
        if(!integChkLst.isEmpty() && integChkLst.size()>0 && integChkLst[0].Applicant__c !=null){
          Applicant__c applicantInstance =[SELECT id,Loan__c FROM Applicant__c WHERE Id=:integChkLst[0].Applicant__c ];
          loanId= applicantInstance.Loan__c;
        }
        //Notification ||END
        for(Integration_Checklist__c integCheckRec : integChkLst) {
            if(integCheckRec.Integration_Master__r.Name == 'AML') {
                String applcntId = integCheckRec.Applicant__c;
                String oldResponseFldVal = oldRecordMap.get(integCheckRec.Id).Response__c;
                String newResponseFldVal = integCheckRec.Callback_Request__c;
                if(String.isNotBlank(oldResponseFldVal)  && String.isNotBlank(newResponseFldVal)) {
                    AMLWrapper oldDeserializeResponse = (AMLWrapper)JSON.deserialize(oldResponseFldVal, AMLWrapper.Class);
                    AMLWrapper newDeserializeResponse = (AMLWrapper)JSON.deserialize(newResponseFldVal, AMLWrapper.Class);
                                       
                    Applicant__c       applcntRec        = new Applicant__c(Id = applcntId);
                    String oldAmlAction  = oldDeserializeResponse.AML_ACTION;
                    String newAmlAction  = newDeserializeResponse.AML_ACTION;

                    if(oldAmlAction == 'Hold' && oldAmlAction != newAmlAction) {
                        applcntRec.AML_Status__c = newAmlAction;
                        updateApplcntLst.add(applcntRec);
                         //Notification ||START
                        Notification_Event__e notificationEvent2 = new Notification_Event__e();
                        notificationEvent2.sObjectId__c = loanId;
                        notificationEvent2.Trigger_Point__c = 'AML REVERT';
                        EventBus.publish(notificationEvent2);
                         //Notification ||END
                
                    }
                    if(oldAmlAction == 'Hold' && newAmlAction == 'Rejected') {
                        applcntIdLst.add(integCheckRec.Applicant__c);
                         //Notification ||START
                        Notification_Event__e notificationEvent3 = new Notification_Event__e();
                        notificationEvent3.sObjectId__c = loanId;
                        notificationEvent3.Trigger_Point__c = 'AML REVERT';
                        EventBus.publish(notificationEvent3);
                         //Notification ||END
                    } 
                }               
            }else if(integCheckRec.Integration_Master__r.Name == 'Email Verification'){
                String applcntId = integCheckRec.Applicant__c;
                String oldResponseFldVal = oldRecordMap.get(integCheckRec.Id).Response__c;
                Map<String,Object> request = (Map<String,Object>) JSON.deserializeUntyped(integCheckRec.Request__c); //28JUL
                String newResponseFldVal = integCheckRec.Callback_Request__c;
                if(String.isNotBlank(oldResponseFldVal)  && String.isNotBlank(newResponseFldVal)) {
                    Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(newResponseFldVal);
                    Applicant__c applcntRec = new Applicant__c(Id = applcntId);
                    applcntRec.IsEmailVerified__c = response.get('status') != null && String.valueOf(response.get('status')) == 'VERIFIED';
                    applcntRec.Email__c = String.valueOf(request.get('email')); //28JUL
                    updateApplcntLst.add(applcntRec);
                }
            }
        }        
        
        if(updateApplcntLst.size() > 0) {
            DatabaseUtility.updateRecords(updateApplcntLst, 'Applicant__c');
        }

        List<Applicant__c>  rejectedIntegCheckLst = [SELECT id, Loan__c, RecordTypeId, CFR_Status__c, Negative_Check_Status__c, Related_Party_Status__c 
                                                     FROM Applicant__c
                                                     WHERE id in :applcntIdLst];

        if(rejectedIntegCheckLst.size() > 0) {
            CFRNegativeCheckRelatedPartyAMLCheck.updateHandler(rejectedIntegCheckLst);
        }      
    }
}