public with sharing class RelatedReferencesComponentController {
    
    @AuraEnabled
    public static List<Address__c> getApplicantAddress(String applicantId, String addressType) {

        List<Address__c> addressList = [SELECT Id, Status__c
                                        FROM Address__c 
                                        WHERE Applicant__c =: applicantId and Address_Type__c =: addressType WITH SECURITY_ENFORCED];
        return addressList;
    }

    @AuraEnabled
    public static List<Applicant__c> getApplicant(String loanApplId, String recordType) {

        List<Applicant__c> applcntLst = [SELECT Id 
                                         FROM Applicant__c 
                                         WHERE Loan__c =: loanApplId and RecordType.Name =: recordType WITH SECURITY_ENFORCED];
        return applcntLst;
    }

    @AuraEnabled
    public static List<Applicant_Financials_Details__c> getApplicantFinancial(String applcId, String industry) {

        List<Applicant_Financials_Details__c> applcntFinLst = [SELECT Id, Industry__c
                                                               FROM Applicant_Financials_Details__c 
                                                               WHERE Applicant__c =: applcId and Industry__c =: industry WITH SECURITY_ENFORCED];
        return applcntFinLst;
    }

    @AuraEnabled
    public static List<Common_Picklist__mdt> getCommonPicklistByFldName(String fldName) {

        List<Common_Picklist__mdt> commonPicklistLst = [SELECT id, Field_Value__c
                                                        FROM Common_Picklist__mdt where Field_Name__c =: fldName WITH SECURITY_ENFORCED];
        return commonPicklistLst;
    }

    @AuraEnabled
    public static ApplicantHandlerWrapper applicantHandler(String loanApplId) {

        List<Loan_Application__c> loanApplList = [SELECT Name, RecordType.Name FROM Loan_Application__c where id =: loanApplId WITH SECURITY_ENFORCED];

        List<Applicant__c> applList   = getApplicant(loanApplId, 'Applicant');
        String applcntId              = applList.size() > 0 ? applList[0].Id : '';
        List<Address__c> addressList  = getApplicantAddress(applcntId, 'Current');
        String status          = addressList.size() > 0 ? addressList[0].Status__c : '';
        List<Applicant_Financials_Details__c> appLFinList  = getApplicantFinancial(applcntId, 'Defence/Police/Paramilitary');
        String indstry                = appLFinList.size() > 0 ? appLFinList[0].Industry__c : '';

        ApplicantHandlerWrapper obj  = new ApplicantHandlerWrapper();
        obj.residenceStatus          = status;
        obj.industry                 = indstry;
        obj.recordTypeName           = loanApplList.size() > 0 ? loanApplList[0].RecordType.Name : '';

        Common_Picklist__mdt commonPicklist = getCommonPicklistByFldName('Relationship_with_applicant__c').size() > 0 ? getCommonPicklistByFldName('Relationship_with_applicant__c')[0] : new Common_Picklist__mdt();
        obj.relationshipWithBorrower = commonPicklist != null ? commonPicklist.Field_Value__c : '';
        obj.twLoanAmountLimit = Decimal.valueOf(Threshold_Value__mdt.getInstance('TW_Reference_Loan_Amount_Limit').Value__c);//R2-2166
        return obj;
    }

    public class ApplicantHandlerWrapper {
        @AuraEnabled public String residenceStatus;
        @AuraEnabled public String industry;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String relationshipWithBorrower;
        @AuraEnabled public Decimal twLoanAmountLimit;//R2-2166
    }
}