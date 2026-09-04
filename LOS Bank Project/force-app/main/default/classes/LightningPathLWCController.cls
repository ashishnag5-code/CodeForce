public with sharing class LightningPathLWCController {

    @AuraEnabled
    public static List<Loan_Application__c> getLoanApplcation(String recordId){
        List<Loan_Application__c> loanApplLst = [SELECT RecordType.Name, Stage__c, Application_FI_Status__c, Draft_Stage__c,
                                                    (SELECT id
                                                     FROM Applicants__r
                                                     WHERE RecordType.Name = 'Applicant'
                                                    )
                                                 FROM Loan_Application__c
                                                 WHERE id =: recordId WITH SECURITY_ENFORCED];   
        return loanApplLst;
    }

    @AuraEnabled
    public static List<RecordTypeVsStage__mdt> getRecordTypeVsStageMetadataRec(String recordType){
        List<RecordTypeVsStage__mdt> custmMetadataRecLst = [SELECT Id, MasterLabel, Record_Type__c, Stage__c
                                                            FROM RecordTypeVsStage__mdt 
                                                            WHERE Record_Type__c =: recordType WITH SECURITY_ENFORCED];   
        return custmMetadataRecLst;
    }

    @AuraEnabled
    public static List<Integration_Checklist__c> getIntegrationCheckList(String recordId, String docMasterName){
        List<Integration_Checklist__c> integrationChecklistRec = [SELECT Id, Callback_Request__c
                                                                    FROM Integration_Checklist__c 
                                                                    WHERE (Applicant__c =: recordId AND Integration_Master__r.Name = :docMasterName) WITH SECURITY_ENFORCED];   
        return integrationChecklistRec;
    }

    @AuraEnabled
    public static  WrapperForLoanAndCustomMetadat recordTypeVsStageMetadataHandler(String recordId) { 

        Map<String, List<sobject>> recmap                = new  Map<String, List<sobject>>();
        List<Loan_Application__c> loanApplLst            = getLoanApplcation(recordId);
        List<RecordTypeVsStage__mdt> custmMetadataRecLst = getRecordTypeVsStageMetadataRec(loanApplLst[0].RecordType.Name);
        String applcntId                                 = loanApplLst[0].Applicants__r[0].Id;
        List<Integration_Checklist__c> integCheckList    = getIntegrationCheckList(applcntId, 'AML');

        system.debug('loanApplLst--'+loanApplLst);
        system.debug('applcntId--'+applcntId);
        WrapperForLoanAndCustomMetadat obj = new WrapperForLoanAndCustomMetadat();

        for(Integration_Checklist__c intCheck : integCheckList) {
            if(String.isNotBlank(intCheck.Callback_Request__c)) {
                obj.callBackRequest = intCheck.Callback_Request__c;
                break;
            }
        }
        obj.loanApplcationRec    = new List<Loan_Application__c>();
        obj.loanApplcationRec    = loanApplLst;
        obj.custmMetadataRecLst  = new List<RecordTypeVsStage__mdt>();
        obj.custmMetadataRecLst  = custmMetadataRecLst;
      //  obj.integrationCheckList = new List<Integration_Checklist__c>();
     //   obj.integrationCheckList = integCheckList;

        return obj;
    }

    public class WrapperForLoanAndCustomMetadat {
        @AuraEnabled public List<Loan_Application__c>  loanApplcationRec {get;set;}
        @AuraEnabled public List<RecordTypeVsStage__mdt>  custmMetadataRecLst {get;set;}
     //   @AuraEnabled public List<Integration_Checklist__c>  integrationCheckList {get;set;}
        @AuraEnabled public String callBackRequest {get;set;}
    }
}