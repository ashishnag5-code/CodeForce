public with sharing class CustomCollateralEnquiryController {

    @AuraEnabled
    public static CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper getCollateralEnquiryList(String strApplicantId) {
        system.debug('strApplicantId '+strApplicantId);
        Id applRecordTypeIdValue = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper objCBSWrapper = new CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper();
        try{
            String respBody;
            Applicant__c objApplicant = [SELECT CIF_No__c,Loan__c,Id, Loan__r.Branch_Master__r.Account_Code__c FROM Applicant__c where Id=:strApplicantId WITH SECURITY_ENFORCED limit 1];//AND recordTypeId=:applRecordTypeIdValue  
            
            // Skip calling Collateral Enquiry search if CIF is not present
            if( String.isBlank(objApplicant.CIF_No__c) ){
                return objCBSWrapper;
            }

            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Customer Collateral Enquiry');
            String requestBody = CustomerEnquiryIntegrationHandler.generateRequest(objApplicant)[0];
            String objectId = '';
            // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            
            system.debug('%% '+respBody);
            if(calloutResponseWrapper.statusCode == 200){
                CollateralCustomerEnquiryResponseWrapper objResultWrapper
                    = (CollateralCustomerEnquiryResponseWrapper) System.JSON.deserialize(respBody, CollateralCustomerEnquiryResponseWrapper.DedupeSearchResultWrapper.class);
                //: SFAU-2568 - Error handling - search shows a  blank card even though there's an error
                if(objResultWrapper.TransactionStatus?.ResponseMessage == 'Success' && objResultWrapper.TransactionStatus?.ResponseCode != '99'){
                    objCBSWrapper = CustomerEnquiryIntegrationHandler.mapSearchIntWraptoUIWrap(objResultWrapper,objApplicant);
                }
            }
            system.debug('%% '+objCBSWrapper);
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return objCBSWrapper;
    }
    
    @AuraEnabled
    public static List<Collateral__c> getExistingCollaterals(String loanId){
        return[SELECT Id,Collateral_ID__c,Collateral_Name__c,Type_Of_Existing_Collateral__c,CustomerId__c FROM Collateral__c WHERE loan__c=:loanId and recordType.Name='Existing Collateral'];
    }
}