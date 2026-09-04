/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class LOSKarzaFaceMatchController {
    @AuraEnabled
    public static String validateFaceMatch(String base64Image1, String base64Image2, String strApplicantId) {
        String respBody;
        try
        {
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza Face Match');
            String requestBody = generateRequestBody(base64Image1,base64Image2);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.captureRequestInAttachment =true;
            calloutRequestWrapper.captureResponseInAttachment = true;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            system.debug('respBody'+respBody);
            system.debug('calloutResponseWrapper'+calloutResponseWrapper);
            LOSKarzaFaceMatchResponseWrapper responseParse = LOSKarzaFaceMatchResponseWrapper.parse(respBody);
            if(responseParse.statusCode == 101){
                system.debug('Status'+responseParse.result.match);
                if(responseParse.result.match == 'yes'){
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.isSuccess =true;
                    wrap.isMatch =true;
                    wrap.matchScore = responseParse.result.matchScore;
                    wrap.reviewNeeded = responseParse.result.reviewNeeded;
                    Utility.storeMatchResults('Face','Application Aadhaar Picture','Live Photo' ,responseParse.result.matchScore,strApplicantId,wrap.isMatch);
                    return JSON.serialize(wrap,true);
                }else{
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.isSuccess =true;
                    wrap.isMatch =false;
                    wrap.matchScore = responseParse.result.matchScore;
                    wrap.reviewNeeded = responseParse.result.reviewNeeded;
                    Utility.storeMatchResults('Face','Application Aadhaar Picture','Live Photo' ,responseParse.result.matchScore,strApplicantId,wrap.isMatch);
                    return JSON.serialize(wrap,true);
                }
            }else{
                ResultWrapper wrap = new ResultWrapper();
                wrap.isSuccess =false;
                wrap.isMatch =false;
                Utility.storeMatchResults('Face','Application Aadhaar Picture','Live Photo' ,responseParse.result.matchScore,strApplicantId,wrap.isMatch);
                return JSON.serialize(wrap,true);
            }
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper wrap = new ResultWrapper();
            wrap.isSuccess =false;
            wrap.isMatch =false;
            return JSON.serialize(wrap,true);
        }

    }
    public static String generateRequestBody(String base64Image1,String base64Image2){
        LOSKarzaFaceMatchReqWrapper wrap = new LOSKarzaFaceMatchReqWrapper();
        wrap.RequestId =IntegrationUtility.getReferenceId();
        wrap.OriginatingChannel = Label.Karza_Face_Match_Channel;
        wrap.Image1B64 = base64Image1;
        wrap.Image2B64 = base64Image2;
        return JSON.serialize(wrap,true);
    }

    public class LOSKarzaFaceMatchReqWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public String Image1B64;
        public String Image2B64;
    }
    public class ResultWrapper{
        public Boolean isSuccess;
        public Boolean isMatch;
        public Double matchScore;
        public String reviewNeeded;
    }
}