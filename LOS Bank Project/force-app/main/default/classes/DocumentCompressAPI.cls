/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-16-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class DocumentCompressAPI {


    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-12-2023 
    * @param base64String 
    * @param filename 
    * @param loanApplicationId 
    * @param loanId 
    * @return DocumentCompressReqResWrapper.LOSDocCompressResWrapper 
    **/
    public static DocumentCompressReqResWrapper.LOSDocCompressResWrapper getCompresssedDocument(String base64String, String filename,String loanApplicationId,String loanId){
        String respBody;
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('DocumentCompressService');
        Map<String,Object> requestBodyMap = new Map<String,Object>();
        filename = String.isNotBlank(filename) ? filename.replaceAll(' ','') : '';
        String requestBody = generateRequestBody(base64String,filename);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = 'POST';
        calloutRequestWrapper.captureRequestInAttachment =true;
        calloutRequestWrapper.captureResponseInAttachment = true;
        calloutRequestWrapper.masterRecord = objIntMapper;
        Integration_Checklist__c checklistRecord;
        if(String.isNotBlank(loanId) && loanId != null){
            checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanId);
        }else{
            checklistRecord = new Integration_Checklist__c(Applicant__c = loanApplicationId);
        }
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        // Uncomment below line for actual response.
        respBody = calloutResponseWrapper.response;
        DocumentCompressReqResWrapper.LOSDocCompressResWrapper parseData = new DocumentCompressReqResWrapper.LOSDocCompressResWrapper();
        parseData.checklistRecord = calloutResponseWrapper.checklistRecord;
        if(calloutResponseWrapper.statusCode==200 || calloutResponseWrapper.statusCode==201 || calloutResponseWrapper.statusCode==202 || calloutResponseWrapper.statusCode==203 || calloutResponseWrapper.statusCode==204){
            parseData = DocumentCompressReqResWrapper.LOSDocCompressResWrapper.parse(respBody);
        }
        //DocumentCompressReqResWrapper.LOSDocCompressResWrapper parseData = DocumentCompressReqResWrapper.LOSDocCompressResWrapper.parse(respBody);
        return parseData;
    }
        
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-15-2022 
    * @param base64String 
    * @param filename 
    * @return String 
    **/
    public static String generateRequestBody(String base64String, String filename){
        DocumentCompressReqResWrapper.LOSDocCompressReqWrapper wrap = new DocumentCompressReqResWrapper.LOSDocCompressReqWrapper();
        wrap.RequestId =IntegrationUtility.getReferenceId();
        wrap.OriginatingChannel = Label.Document_Channel;
        wrap.Filename = filename;
        wrap.Base64string = base64String;
        return JSON.serialize(wrap,true);
    }
}