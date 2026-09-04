/**
* @author        Joshna Palla
* @date          25/09/2021
* @description   Publisher class for callout events
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer            Date            Description
  --------------------------------------------------------------------------------------------
  Joshna Palla         25/09/2021      Initial Version
*/
public without sharing class CommonCalloutEventPublisher  {
    List<Integration_Checklist__c> statusRecords;

    public CommonCalloutEventPublisher() {
        statusRecords = new List<Integration_Checklist__c>();
    }

    public CommonCalloutEventPublisher(List<Integration_Checklist__c> integrationStatusRecords) {
        statusRecords = integrationStatusRecords;
    }

    /* Overriding the PEPublisher virtual method. This method collects all the integration mapper, loan, applicant and status records related to the
     * integration status record that is initiating the event. A wrapper instance is created for each status record that needs an auto integration.
     * The wrapper instance is then passed on to each integration's individual handler class to generate and return platform events
     * This class doesn't publish the platform event. PEPublisher which is part of platform event framework will take care of the publishing */
    public void createPEs() {
        Set<Id> loanIds = new Set<Id>();
        Set<Id> applicantIds = new Set<Id>();
        Set<Id> mapperIds = new Set<Id>();
        for (Integration_Checklist__c each : statusRecords) {
            if (String.isNotBlank(each.Loan__c)) {
                loanIds.add(each.Loan__c);
            }
            if (String.isNotBlank(each.Integration_Master__c)) {
                mapperIds.add(each.Integration_Master__c);
            }
            if (String.isNotBlank(each.Applicant__c)) {
                applicantIds.add(each.Applicant__c);
            }
        }

      //  Map<Id, Applicant_Financials__c> applicantFinancialsMap = new Map<Id, Applicant_Financials__c>();
        Set<Id> allApplicantIds = new Set<Id>();
        Set<Id> allPropertyIds = new Set<Id>();
        Map<Id, Opportunity> opportunityRecordMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :loanIds]);
            
        Map<Id, Applicant__c> applicantRecordMap = new Map<Id, Applicant__c>([SELECT Id
            FROM Applicant__c WHERE Id IN :applicantIds]);

       /* 
        for (Applicant_Financials__c each : [SELECT Id, Applicant__c FROM Applicant_Financials__c
            WHERE Applicant__c IN :allApplicantIds]) {
            applicantFinancialsMap.put(each.Applicant__c, each);
        }
*/
        Map<Id, Integration_Master__c> integrationMasterRecordMap = new Map<Id, Integration_Master__c>(
            [SELECT Id, Name, Apex_Class_Name__c, End_Point_URL__c
            FROM Integration_Master__c WHERE Id IN :mapperIds]);
        Map<String, List<AutoIntegrationsInputWrapper>> statusRecordsByHandlerClass = new Map<String, List<AutoIntegrationsInputWrapper>>();
        for (Integration_Checklist__c each : statusRecords) {
            AutoIntegrationsInputWrapper wrapperRec = new AutoIntegrationsInputWrapper();
            List<Document_Checklist__c> allDocs = new List<Document_Checklist__c>();
            wrapperRec.integrationChecklistRecord = each;
            if (String.isNotBlank(each.Integration_Master__c)) {
                wrapperRec.integrationMasterRecord = integrationMasterRecordMap.get(each.Integration_Master__c);
            }
            if (String.isNotBlank(each.Applicant__c)) {
                wrapperRec.applicantRecord = applicantRecordMap.get(each.Applicant__c);
            }
            if (statusRecordsByHandlerClass.containsKey(wrapperRec.integrationMasterRecord.Apex_Class_Name__c)) {
                statusRecordsByHandlerClass.get(wrapperRec.integrationMasterRecord.Apex_Class_Name__c).add(wrapperRec);
            } else {
                statusRecordsByHandlerClass.put(wrapperRec.integrationMasterRecord.Apex_Class_Name__c, new List<AutoIntegrationsInputWrapper>{wrapperRec});
            }
        }
        for (String className : statusRecordsByHandlerClass.keySet()) {
            if (String.isBlank(className)) {
                continue;
            }
            IntegrationHandlerInterface service = (IntegrationHandlerInterface) Type.forName(className).newInstance();
            System.debug('statusRecordsByHandlerClass.get(className)'+statusRecordsByHandlerClass.get(className));
          /*  List<sObject> platformEventList = service.generatePlatformEvents(statusRecordsByHandlerClass.get(className));
            if (platformEventList != null) {
                this.newPEs.addAll(platformEventList);
            }
*/
        }
    }

    // Wrapper class used for all generate platform events methods in integration handlers
    public class AutoIntegrationsInputWrapper {
        public Applicant__c applicantRecord;
        public Integration_Checklist__c integrationChecklistRecord;
        public Integration_Master__c integrationMasterRecord;
        public Opportunity loanRecord;
        public Object dynamicQueryInput;
        public List<Applicant__c> relatedApplicants;
        public Map<String, Set<String>> objectToInterfaceInputsMap; // added for comparing which field is blank from object records
    }

    public AutoIntegrationsInputWrapper constructInputWrapper(Integration_Master__c masterRecord, Integration_Checklist__c checklistRecord, Id entityId) {
        if (masterRecord.Interface_Inputs__r.isEmpty()) {
            throw new HandledException('There are no interface inputs defined to construct data');
        }
        if (String.isBlank(entityId)) {
            throw new HandledException('Entity Id is mandatory to fetch interface inputs');
        }
        if (String.isBlank(masterRecord.Source_of_Entry__c)) {
            throw new HandledException('Source entity is mandatory to fetch interface inputs');
        }

        AutoIntegrationsInputWrapper inputWrapper = new AutoIntegrationsInputWrapper();
        inputWrapper.integrationMasterRecord = masterRecord;
        inputWrapper.integrationChecklistRecord = checklistRecord;
        Map<String, Set<String>> objectToInterfaceInputsMap = new Map<String, Set<String>>();
        String key = '';
        String query = '';
        List<String> fieldValues = new List<String>();

        // using entity id which is of type source entity, fetch related record details and pass as input
        // any explicit logic/inputs will be set by respective controllers or auto interface handler
        for (Interface_Inputs__c each : masterRecord.Interface_Inputs__r) {
            system.debug('each'+each);
            key = String.isNotBlank(each.Child_Relationship_Name__c) ? each.Child_Relationship_Name__c : masterRecord.Source_of_Entry__c;
            system.debug('key'+key);
            if (!objectToInterfaceInputsMap.containsKey(key.toLowerCase())) {
                objectToInterfaceInputsMap.put(key.toLowerCase(), new Set<String>{'Id'});
            }
            objectToInterfaceInputsMap.get(key.toLowerCase()).add(each.Field_Name__c);
            system.debug('objectToInterfaceInputsMap'+objectToInterfaceInputsMap);
        }
        inputWrapper.objectToInterfaceInputsMap = objectToInterfaceInputsMap;

        fieldValues.addAll(objectToInterfaceInputsMap.get(masterRecord.Source_of_Entry__c.toLowerCase()));
        system.debug('fieldValues'+fieldValues);
        query = 'SELECT ' + String.join(fieldValues, ',');
        for (String each : objectToInterfaceInputsMap.keySet()) {
            if (each.equalsIgnoreCase(masterRecord.Source_of_Entry__c)) {
                continue;
            }
            fieldValues.clear();
            fieldValues.addAll(objectToInterfaceInputsMap.get(each));
            query += ', (SELECT ' + String.join(fieldValues, ',') + ' FROM ' + each + ')';
        }
        query += ' FROM ' + masterRecord.Source_of_Entry__c + ' WHERE Id = :entityId';
        system.debug('Dynamic query'+query);
        for (sObject each : Database.query(String.escapeSingleQuotes(query))) {
            inputWrapper.dynamicQueryInput = each;
            break;
        }
        
        return inputWrapper;
    }
}