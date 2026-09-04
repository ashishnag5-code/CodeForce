/**
 * @author        Joshna
 * @date          19-Jul-2023
 * @description   Controller class for CBS PSL/BSR
 * @reference     API Calls
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * -----------------------------------------------------------------------------------------------------
 * Joshna                  19-Jul-2023     Initial creation - added submitCIFDetails & submitLANDetails
 */
public without sharing class CBSBSRPSLAPIController {
    public static final String CBS_BSR_PSL = 'CBS PSL/BSR Creation';

    @AuraEnabled
    public static String submitCIFDetails(String applicantId) {
        CBSBSRPSLAPIHandler.InputWrapper inputWrapperInst = new CBSBSRPSLAPIHandler.InputWrapper();
        try {
            inputWrapperInst.requestMode = 'CIF';
            inputWrapperInst.applicantRecord = [SELECT Id, CIF_No__c, PAN__c, Loan__r.Branch_Master__r.Account_Code__c, UDYAM_Registration_Number__c, Pan_Form60__c, CIN__c, Risk_Category__c,
            Passport_Number__c, Voter_Id__c, Driving_License_Id__c, Deemed_KYC__c, Loan__r.Three_years_average_turnover__c
            FROM Applicant__c WHERE Id = :applicantId];
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, isActive__c, Sector__c, Industry__c, Sub_Industry__c, Occupation__c, Type_Of_Employment__c  FROM Applicant_Financials_Details__c
                WHERE Applicant__c = :applicantId AND RecordType.DeveloperName = 'Financial_Parent'];
            if (applicantFinancials != null && !applicantFinancials.isEmpty()) {
                inputWrapperInst.applicantFinancials = applicantFinancials[0];

                Applicant_Financials_Details__c applicantParentFinancial = applicantFinancials[0];
                List<Profiling_Master__c> profilingMasterRecords = new List<Profiling_Master__c>();   
                profilingMasterRecords = [SELECT Name,Code__c,Risk__c,Sector__c, Sector__r.Code__c, Industry__c, Industry__r.Code__c,
                Sub_Industry__c, Sub_Industry__r.Code__c, Occupation__c, Occupation__r.Code__c, Employment_Type__c, 
                Employment_Type__r.Code__c 
                FROM Profiling_Master__c WHERE RecordType.DeveloperName = 'RT_Employment_Type' AND
                Sector__r.Name =:applicantParentFinancial.Sector__c AND Industry__r.Name=:applicantParentFinancial.Industry__c 
                AND Sub_Industry__r.Name =:applicantParentFinancial.Sub_Industry__c AND 
                Occupation__r.Name =:applicantParentFinancial.Occupation__c AND Name=:applicantParentFinancial.Type_Of_Employment__c];
                if (profilingMasterRecords != null && !profilingMasterRecords.isEmpty()) {
                    inputWrapperInst.strRiskCategory = profilingMasterRecords[0].Risk__c;
                }

            } else {
                inputWrapperInst.applicantFinancials = new Applicant_Financials_Details__c();
            }
        
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(CBSBSRPSLAPIController.CBS_BSR_PSL);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId, Integration_Master__c = objIntMapper.Id);
            List<String> requestStrings = CBSBSRPSLAPIHandler.generateRequest(inputWrapperInst);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestStrings[0];
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.response != null && calloutResponseWrapper.response.contains('Success')) {
                return calloutResponseWrapper.checklistRecord.Status__c;
            } else {
                calloutResponseWrapper.checklistRecord.Status__c = 'Failed';
                // ideally this should be in response callback but since DML is always performed in Integration Utility, setting this to failed in case of genuine failures
                update calloutResponseWrapper.checklistRecord;
            }
            return calloutResponseWrapper.checklistRecord.Status__c;
        } catch (Exception ex) {
            AuraHandledException auraEx = new AuraHandledException(ex.getMessage());
            auraEx.setMessage(ex.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static String submitLANDetails(String loanId) {
        CBSBSRPSLAPIHandler.InputWrapper inputWrapperInst = new CBSBSRPSLAPIHandler.InputWrapper();
        inputWrapperInst.loanRecord = [SELECT Id, LAN__c, Branch_Master__r.Account_Code__c,
            (SELECT Id, Activity__c, PSL_Segment__c, PSL_Classification_Category__c, RecordType.Name FROM BSR_PSL_Details__r where RecordType.Name = 'PSL' LIMIT 1),
            (SELECT Id, Internal_Risk_Score__c, Caste__c, Religion__c FROM Applicants__r WHERE RecordType.DeveloperName = 'Primary_Applicant')
            FROM Loan_Application__c WHERE Id = :loanId];
        if (inputWrapperInst.loanRecord.Applicants__r != null && !inputWrapperInst.loanRecord.Applicants__r.isEmpty()) {
            inputWrapperInst.applicantRecord = inputWrapperInst.loanRecord.Applicants__r[0];
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, isActive__c, Sector__c, Industry__c, Sub_Industry__c, Occupation__c, Type_Of_Employment__c  FROM Applicant_Financials_Details__c
                WHERE Applicant__c = :inputWrapperInst.loanRecord.Applicants__r[0].Id AND RecordType.DeveloperName = 'Financial_Parent'];
            if (applicantFinancials != null && !applicantFinancials.isEmpty()) {
                inputWrapperInst.applicantFinancials = applicantFinancials[0];

                Applicant_Financials_Details__c applicantParentFinancial = applicantFinancials[0];
                List<Profiling_Master__c> profilingMasterRecords = new List<Profiling_Master__c>();   
                profilingMasterRecords = [SELECT Name,Code__c,Risk__c,Sector__c, Sector__r.Code__c, Industry__c, Industry__r.Code__c,
                Sub_Industry__c, Sub_Industry__r.Code__c, Occupation__c, Occupation__r.Code__c, Employment_Type__c, 
                Employment_Type__r.Code__c 
                FROM Profiling_Master__c WHERE RecordType.DeveloperName = 'RT_Employment_Type' AND
                Sector__r.Name =:applicantParentFinancial.Sector__c AND Industry__r.Name=:applicantParentFinancial.Industry__c 
                AND Sub_Industry__r.Name =:applicantParentFinancial.Sub_Industry__c AND 
                Occupation__r.Name =:applicantParentFinancial.Occupation__c AND Name=:applicantParentFinancial.Type_Of_Employment__c];
                if (profilingMasterRecords != null && !profilingMasterRecords.isEmpty()) {
                    inputWrapperInst.strRiskCategory = profilingMasterRecords[0].Risk__c;
                }

            } else {
                inputWrapperInst.applicantFinancials = new Applicant_Financials_Details__c();
            }
        } else {
            inputWrapperInst.applicantRecord = new Applicant__c();
            inputWrapperInst.applicantFinancials = new Applicant_Financials_Details__c();
        }

        if (inputWrapperInst.loanRecord.BSR_PSL_Details__r != null && !inputWrapperInst.loanRecord.BSR_PSL_Details__r.isEmpty()) {
            inputWrapperInst.bsrPSLRecord = inputWrapperInst.loanRecord.BSR_PSL_Details__r[0];
        }
        try {
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(CBSBSRPSLAPIController.CBS_BSR_PSL);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanId, Integration_Master__c = objIntMapper.Id);
            List<String> requestStrings = CBSBSRPSLAPIHandler.generateRequest(inputWrapperInst);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestStrings[0];
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.response != null && calloutResponseWrapper.response.contains('Success')) {
                return calloutResponseWrapper.checklistRecord.Status__c;
            } else {
                calloutResponseWrapper.checklistRecord.Status__c = 'Failed';
                // ideally this should be in response callback but since DML is always performed in Integration Utility, setting this to failed in case of genuine failures
                update calloutResponseWrapper.checklistRecord;
            }
            return calloutResponseWrapper.checklistRecord.Status__c;
        } catch (Exception ex) {
            AuraHandledException auraEx = new AuraHandledException(ex.getMessage());
            auraEx.setMessage(ex.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isComplete(String loanId, String applicantId) {
        if (String.isNotBlank(loanId)) {
            for (Integration_Checklist__c each : [SELECT Status__c FROM Integration_Checklist__c WHERE Loan__c = :loanId AND Integration_Master__r.Name = :CBS_BSR_PSL ORDER BY CreatedDate DESC LIMIT 1]) {
                return each.Status__c == 'Completed';
            }
        } else if (String.isNotBlank(applicantId)) {
            for (Integration_Checklist__c each : [SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c = :applicantId AND Integration_Master__r.Name = :CBS_BSR_PSL ORDER BY CreatedDate DESC LIMIT 1]) {
                return each.Status__c == 'Completed';
            }
        }
        return false;
    }
}