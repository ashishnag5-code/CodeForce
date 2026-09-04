public with sharing class KarzaLPGBillController {

    @AuraEnabled
    public static String karzaLPGBillCallOut(String lpgId, Id recordId, Id loanAppId) {
        String respBody;
        KarzaLPGBillHandler.KarzaLPGBillResponseWrapper karzaResponse;
        try{                        
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c=recordId, Loan_Application__c=loanAppId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza LPG Bill');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('consent','Y');
            reqParam.put('lpg_id',lpgId);
            reqParam.put('ReqId',IntegrationUtility.getReferenceId());
            reqParam.put('Channel',objIntMapper.Channel__c);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;            
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.urlParamsMap = reqParam;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);  
            if(calloutResponseWrapper.statusCode!=200){
                return ('API Error: ' + calloutResponseWrapper.checklistNumber + ' Response: ' + calloutResponseWrapper.statusCode + '- ' + calloutResponseWrapper.status);
            }
            respBody = calloutResponseWrapper.response;
            karzaResponse = (KarzaLPGBillHandler.KarzaLPGBillResponseWrapper) JSON.deserialize (respBody, KarzaLPGBillHandler.KarzaLPGBillResponseWrapper.class);
            String karzaContentString = JSON.serialize(karzaResponse);
            Blob newBlob = Blob.valueOf(karzaContentString);
            String contentValue = EncodingUtil.base64Encode(newBlob);
            MultipleFileUploadController.contentVersionType cvObject = new MultipleFileUploadController.contentVersionType();
            cvObject.fileName = 'LPG_Bill_Response.txt';
            cvObject.base64 = contentValue;
            List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Document_Number__c, Document_Master__c,Status__c,
                                                                            Document_Master__r.Document_Name__c, Applicant__c, Applicant__r.Loan__c,
                                                                            Applicant__r.RecordTypeId, Applicant__r.RecordType.DeveloperName
                                                                            FROM Document_Checklist__c WHERE 
                                                                            Applicant__c=:recordId AND
                                                                            Document_Master__r.Document_Name__c=:GlobalConstants.KARZA_LPG_BILL WITH SECURITY_ENFORCED
                                                                            ORDER BY CreatedDate DESC LIMIT 1];
            /*docCheckListRecords[0].Document_Number__c=lpgId;
            update docCheckListRecords[0];      */                                            
            MultipleFileUploadController.uploadFile(cvObject, docCheckListRecords[0].Id);
        }
        catch(Exception objException) {
            system.debug('Exception occurred '+objException);
        }
        return JSON.serialize(karzaResponse);
    }

    /*@AuraEnabled
    public static LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper addressmatch(KarzaLPGBillHandler.KarzaLPGBillResponseWrapper karzaResponse, Id recordId, Id loanAppId){
        String address = karzaResponse.result.ConsumerAddress;
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper data = CPVWaiverDocumentsController.addressMatch(address, recordId, loanAppId, GlobalConstants.KARZA_LPG_BILL);
        return data;
    }*/
}