/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class LOSOCRIntegrationCtr {
        
    public static String respBody;
    public static String requestBody;
    @AuraEnabled
    public static OCRAadharResponseWrapper initiateAdharOCR(String applicantId, String base64, String docType) {
        
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Adhar OCR');
        requestBody = createOCRRequestBody(docType,base64);
        system.debug('requestBody @@@@@@@@');
       // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applicantId);
       
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        // Added by hasrhit due to error -START
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;
        // Added by hasrhit due to error -END
        calloutRequestWrapper.masterRecord = objIntMapper;
        
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        
        respBody=calloutResponseWrapper.response;
        
        system.debug('respBody @@@@@@@@ ');
        if(calloutResponseWrapper.statusCode != 200){
            throw new CustomException('API Error: ' +  calloutResponseWrapper.checklistNumber + ' Response: ' +  calloutResponseWrapper.statusCode + ' - ' + respBody);
        }
        OCRAadharResponseWrapper ocrResponseParse = OCRAadharResponseWrapper.parse(respBody);
        system.debug('ocrResponseParse');
        return ocrResponseParse;
    }
    
    @AuraEnabled
    public static OCRVoterIdResponseWrapper initiateVoterIdOCR(String applicantId, String base64, String docType) {
        
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Voter ID OCR');
        requestBody = createOCRRequestBody(docType,base64);
       // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applicantId);
       
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;

        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;

        calloutRequestWrapper.masterRecord = objIntMapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody=calloutResponseWrapper.response;
        if(calloutResponseWrapper.statusCode != 200){
            throw new CustomException('API Error: ' +  calloutResponseWrapper.checklistNumber + ' Response: ' +  calloutResponseWrapper.statusCode + ' - ' + respBody);
        }
        OCRVoterIdResponseWrapper ocrResponseParse = OCRVoterIdResponseWrapper.parse(respBody);
        return ocrResponseParse;
    }
    
    
    
    
    
    @AuraEnabled
    public static OCRPassportResponseWrapper initiatePassportOCR(String applicantId, String base64, String docType) {
        
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Passport OCR');
        requestBody = createOCRRequestBody(docType,base64);
        //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applicantId);
       
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;

        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;

        calloutRequestWrapper.masterRecord = objIntMapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody=calloutResponseWrapper.response;
        if(calloutResponseWrapper.statusCode != 200){
            throw new CustomException('API Error: ' +  calloutResponseWrapper.checklistNumber + ' Response: ' +  calloutResponseWrapper.statusCode + ' - ' + respBody);
        }
        OCRPassportResponseWrapper ocrResponseParse = OCRPassportResponseWrapper.parse(respBody);
        return ocrResponseParse;
    }
    
    @AuraEnabled
    public static OCRPanCardResponseWrapper initiatePanCardOCR(String applicantId, String base64, String docType) {
        
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Pan Card OCR');
        String respBody;
        String requestBody;
        requestBody = createOCRRequestBody(docType,base64);
        //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applicantId);
        
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;

        calloutRequestWrapper.masterRecord = objIntMapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody=calloutResponseWrapper.response;
        String value1 = JSONReservedSerializer_AUSF.replaceJSONKeywords(respBody);
        if(calloutResponseWrapper.statusCode != 200){
            throw new CustomException('API Error: ' +  calloutResponseWrapper.checklistNumber + ' Response: ' +  calloutResponseWrapper.statusCode + ' - ' + respBody);
        }
        OCRPanCardResponseWrapper ocrResponseParse = OCRPanCardResponseWrapper.parse(value1);
        return ocrResponseParse;
    }
    @AuraEnabled
    public static OCRDLResponseWrapper initiateDLOCR(String applicantId, String base64, String docType) {
        
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('Driving License OCR');
        String respBody;
        String requestBody;
        requestBody = createOCRRequestBody(docType,base64);
        //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applicantId);
        
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;

        calloutRequestWrapper.masterRecord = objIntMapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody=calloutResponseWrapper.response;
        if(calloutResponseWrapper.statusCode != 200){
            throw new CustomException('API Error: ' +  calloutResponseWrapper.checklistNumber + ' Response: ' +  calloutResponseWrapper.statusCode + ' - ' + respBody);
        }
        OCRDLResponseWrapper ocrResponseParse = OCRDLResponseWrapper.parse(respBody);
        return ocrResponseParse;
    }
    public static String createOCRRequestBody(String docType, String base64){
        OCRReqWrapper objNSDLReq = new OCRReqWrapper();
        objNSDLReq.file = '';
        objNSDLReq.fileBase64 = base64;
        objNSDLReq.pdfPassword = '';
        objNSDLReq.requiredOcr = true;
        objNSDLReq.requiredConfidence = true;
        objNSDLReq.responseType = 'BASE64';
        objNSDLReq.responseFormat= 'DOCUMENT';
        objNSDLReq.maskAadhaarImage='EIGHT_DIGITS';
        objNSDLReq.maskAadhaarText= null;
        objNSDLReq.responseFormat= 'DOCUMENT';
        objNSDLReq.returnQualityChecks = new List<String>{'ALL'};
        objNSDLReq.docTypes = new List<String>{docType};
        return JSON.serialize(objNSDLReq);
    }
    public class CustomException extends Exception{}
    
    
}