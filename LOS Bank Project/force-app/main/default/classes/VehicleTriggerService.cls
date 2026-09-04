public with sharing class VehicleTriggerService {
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        system.debug('inapllicantservice>>>');
        createChecklists((Map<Id, Collateral__c>) newRecordMap);
    }
    public void createChecklists(Map<Id, Collateral__c> newApplicantsMap) {
        system.debug('checklist>>>');
        RuleEngineHandler getDocChecklists = new RuleEngineHandler();
        Set<String> vehicleIds = new Set<String>();
        List<Document_Checklist__c> checklistsToInsert = new List<Document_Checklist__c>();
        
        for (Id each : newApplicantsMap.keySet()) {
            vehicleIds.add(String.valueOf(each));
        }
        
        Map<Id, Set<String>> documentMasterIdsByApplicant = getDocumentIds(getDocChecklists.main('Collateral__c', vehicleIds, new Set<String>(), 'Document Checklist'));
        Map<String,Document_Master__c> docMasterMap = new Map<String,Document_Master__c>();
        System.debug('***doc Ids: '+documentMasterIdsByApplicant.keySet());
        
        for(Document_Master__c each : [SELECT Id,Name,Document_Category__c,
                                       Document_Sub_Category__c 
                                       FROM Document_Master__c
                                       WHERE Document_ID__c IN: documentMasterIdsByApplicant.keySet() WITH SECURITY_ENFORCED]){
                                           docMasterMap.put(each.Document_ID__c,each);                                 
                                       }
        
        for (Id each : documentMasterIdsByApplicant.keySet()) {
            for (String eachMasterId : documentMasterIdsByApplicant.get(each)) {
                Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) : 
                new Document_Master__c(); 
                checklistsToInsert.add(new Document_Checklist__c
                                       (Collateral__c = each, 
                                        Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                        Category__c = currentRec.Document_Category__c,
                                        Sub_Category__c = currentRec.Document_Sub_Category__c,
                                        Active__c = true
                                       )
                                      );
            }
        }
        
        if(Schema.sObjectType.Document_Checklist__c.isCreateable()) {
            insert checklistsToInsert;
        }       
    }
    private Map<Id, Set<String>> getDocumentIds(String breJSONString) {
        Map<Id, Set<String>> returnValue = new Map<Id, Set<String>>();
        Map<String, Object> applicantChecklists = (Map<String, Object>) JSON.deserializeUntyped(breJSONString);
        Map<String, Object> checklists = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if(checklists != null){
            for (String each : checklists.keySet()) {
                Set<String> masterIds = new Set<String>();
                List<Object> checklistsOfApp = (List<Object>) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject : checklistsOfApp) {
                    Map<String, Object> objProperties = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }

    public void afterUpdate(List < sObject > newRecordList, Map < Id, sObject > oldRecordMap, Map < Id, sObject > newRecordMap) {
        Map <Id, Collateral__c> collateralOldMap = (Map <Id, Collateral__c> ) oldRecordMap;
        Map <Id, Collateral__c> collateralNewMap = (Map <Id, Collateral__c> ) newRecordMap;
        Map<Id, String> loanIdVsVariant = new Map<Id, String>();
        for (Id collateralId: newRecordMap.keySet()) {
            if(collateralNewMap.get(collateralId).Variant__c!=collateralOldMap.get(collateralId).Variant__c
                && GlobalConstants.colRecordTypeIds.contains(collateralNewMap.get(collateralId).RecordTypeId)){
                loanIdVsVariant.put(collateralNewMap.get(collateralId).Loan__c, collateralNewMap.get(collateralId).Variant__c);
            }
        }
        List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Vehicle_Model__c, Applicant__r.Loan__c FROM Applicant_Financials_Details__c WHERE
            RecordType.DeveloperName IN ('Viability_Sheet_Commercial_Vehicle','Hire_VS_Buy') AND 
            Applicant__r.Loan__c=:loanIdVsVariant.keySet()];

        for(Applicant_Financials_Details__c financials: applicantFinancials){
            financials.Vehicle_Model__c = loanIdVsVariant.get(financials.Applicant__r.Loan__c);
        }
        update applicantFinancials;
        
    }
}