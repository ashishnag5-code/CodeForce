/*****
 * Class Name: CollateralModificationAPIController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-06-2023          -   Mohit M.            -   HotFix - CollateralCode in Modification API - Add field in Query Collateral_Code_in_CBS__c
 * Dec-08-2023          -   Mohit M.            -   SFAU-5665 - Add Vehicle_Cost__c in Query
 */
public with sharing class CollateralModificationAPIController {

    @AuraEnabled
    public static String callCollateralModificationCalloutPDD(Id recordId,String vahanData){
        CollateralModificationAPIHandler.CollateralModificationResponseWrapper modificationWrapper = new CollateralModificationAPIHandler.CollateralModificationResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Collateral Modification');
            Map<String,Loan_Application__c> reqParam = new Map<String,Loan_Application__c>();

            List<Loan_Application__c> loanApplicationList = [SELECT Id, Name, Branch_Master__c, Branch_Master__r.Account_Code__c,
                (SELECT Valuation_date__c, Valuation_Amount__c, Final_Cost__c, Collateral_Value__c, Collateral_Id_in_CBS__c, Collateral_ID__c, Product__c, Collateral_Name__c,Vahaan_Response__c, Collateral_Code_in_CBS__c, Vehicle_Cost__c 
                FROM Collaterals__r Where RecordTypeId IN: GlobalConstants.colRecordTypeIds AND Is_Deleted__c != true Order By CreatedDate Desc) FROM
                Loan_Application__c WHERE id=:recordId];

            if(loanApplicationList!=null && loanApplicationList.size()>0){
                reqParam.put('LoanApplication',loanApplicationList[0]);
            }

            String requestBody= CollateralModificationAPIHandler.generateRequest(reqParam)[0];
            if(loanApplicationList[0].Collaterals__r != null && String.isNotBlank(loanApplicationList[0].Collaterals__r[0].Vahaan_Response__c)){
                CollateralModificationAPIHandler.CollateralModificationRequestWrapper wrapperBody = (CollateralModificationAPIHandler.CollateralModificationRequestWrapper) JSON.deserialize(requestBody,CollateralModificationAPIHandler.CollateralModificationRequestWrapper.class);
                LOSPDDMakerController.VahaanWrapper vahanWrapper = (LOSPDDMakerController.VahaanWrapper) JSON.deserialize(vahanData, LOSPDDMakerController.VahaanWrapper.class);
                wrapperBody.AutomobileCollModDetails = new CollateralModificationAPIHandler.AutomobileCollModDetailsWrapper();
                wrapperBody.AutomobileCollModDetails.EngineNumber = vahanWrapper.engineNo;
                wrapperBody.AutomobileCollModDetails.ChassisNumber = vahanWrapper.chasisNumber;
                wrapperBody.AutomobileCollModDetails.RegistrationNumber = vahanWrapper.registrationNumber; //SFAU-4082 -- chassiNumber being passed in registration number
                requestBody = JSON.serialize(wrapperBody);
            }
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            /*String respBody = calloutResponseWrapper.response;
    
            system.debug('respBody '+respBody);
            modificationWrapper = (CollateralModificationAPIHandler.CollateralModificationResponseWrapper) JSON.deserialize(respBody, CollateralModificationAPIHandler.CollateralModificationResponseWrapper.class);
            */
        }catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);
            return JSON.serialize(e);

        }
        //return modificationWrapper;
        return JSON.serialize(calloutResponseWrapper);
    }
    
    @AuraEnabled
    public static String callCollateralModificationCallout(Id recordId,String parentCmp){
        CollateralModificationAPIHandler.CollateralModificationResponseWrapper modificationWrapper = new CollateralModificationAPIHandler.CollateralModificationResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Collateral Modification');
            Map<String,Loan_Application__c> reqParam = new Map<String,Loan_Application__c>();

            List<Loan_Application__c> loanApplicationList = [SELECT Id, Name, Branch_Master__c, Branch_Master__r.Account_Code__c,
                (SELECT Valuation_date__c, Valuation_Amount__c, Collateral_Value__c, Final_Cost__c, Collateral_Id_in_CBS__c, Collateral_ID__c, Product__c, Collateral_Name__c,Vahaan_Response__c, Collateral_Code_in_CBS__c,Vehicle_Cost__c 
                FROM Collaterals__r Where RecordTypeId IN: GlobalConstants.colRecordTypeIds AND Is_Deleted__c != true Order By CreatedDate Desc) FROM
                Loan_Application__c WHERE id=:recordId];

            if(loanApplicationList!=null && loanApplicationList.size()>0){
                reqParam.put('LoanApplication',loanApplicationList[0]);
            }

            String requestBody= CollateralModificationAPIHandler.generateRequest(reqParam)[0];
            if(parentCmp == 'pddMaker' && loanApplicationList[0].Collaterals__r != null && String.isNotBlank(loanApplicationList[0].Collaterals__r[0].Vahaan_Response__c)){
                CollateralModificationAPIHandler.CollateralModificationRequestWrapper wrapperBody = (CollateralModificationAPIHandler.CollateralModificationRequestWrapper) JSON.deserialize(requestBody,CollateralModificationAPIHandler.CollateralModificationRequestWrapper.class);
                LOSPDDMakerController.VahaanWrapper vahanWrapper = (LOSPDDMakerController.VahaanWrapper) JSON.deserialize(loanApplicationList[0].Collaterals__r[0].Vahaan_Response__c, LOSPDDMakerController.VahaanWrapper.class);
                wrapperBody.AutomobileCollModDetails = new CollateralModificationAPIHandler.AutomobileCollModDetailsWrapper();
                wrapperBody.AutomobileCollModDetails.EngineNumber = vahanWrapper.engineNo;
                wrapperBody.AutomobileCollModDetails.ChassisNumber = vahanWrapper.chasisNumber;
                wrapperBody.AutomobileCollModDetails.RegistrationNumber = vahanWrapper.registrationNumber; //SFAU-4082 -- chassiNumber being passed in registration number
                //wrapperBody.AutomobileCollModDetails.RegistrationNumber = vahanWrapper.chasisNumber;
                requestBody = JSON.serialize(wrapperBody);
            }
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            /*String respBody = calloutResponseWrapper.response;
    
            system.debug('respBody '+respBody);
            modificationWrapper = (CollateralModificationAPIHandler.CollateralModificationResponseWrapper) JSON.deserialize(respBody, CollateralModificationAPIHandler.CollateralModificationResponseWrapper.class);
            */
        }catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);
            return JSON.serialize(e);

        }
        //return modificationWrapper;
        return JSON.serialize(calloutResponseWrapper);
    }
}