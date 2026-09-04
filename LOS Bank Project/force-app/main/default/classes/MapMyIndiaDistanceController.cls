/**
 * Name: MapMyIndiaDistanceController
 * Test Class: MapMyIndiaDistanceControllerTest
 * CreatedBy: Mohit M.
 * Description: Get the distance b/w current location (lattitude and longitude) and Address
 * Logs:
 * Last Modified By     -   Date            -   Bug/User Story
 * Mohit M.             -   June-1-2023     -   SFAU-2205
 */
public with sharing class MapMyIndiaDistanceController implements IntegrationHandlerInterface {

    public static List<String> generateRequest(List<Object> recordList){
     	return null;
    }
    public static String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    /*
    @ method : getLatLongAddressDistance
    @ param1: strCurrentLatandLong - current latitude and longitude
    @ param2: recordId - Record Id
    @ param3: strAddress - Address
    @ param4: integrationChecklistId
    @ return: Distance in KM
    */
    @AuraEnabled  
    public static MMIDWrapper getLatLongAddressDistance(String strCurrentLatandLong, String recordId ,String strAddress,Id integrationChecklistId) {
        Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.Map_My_India_Distance_Integration_Name);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
        checklistRecord.Field_Investigation__c = recordId;
        String strResponse;
        MMIDWrapper wrap = new MMIDWrapper();
        wrap.blnError = false;
        wrap.strMsg = '';
        MapMyIndiaDistanceResponseWrap MMIDresponse;
        try {
            if (String.isBlank(strCurrentLatandLong) || String.isBlank(strAddress)){
                throw new CustomException(Label.MapMyIndiaDistanceLocationBlankMessage);
            }
            strCurrentLatandLong = strCurrentLatandLong.replace('Lat:','');
            strCurrentLatandLong = strCurrentLatandLong.replace('Long:','');
            String strRequest = generateRequest(strCurrentLatandLong, strAddress, objIntMaster);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = strRequest;
            calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMaster;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            strResponse = calloutResponseWrapper.response;
            if(strResponse != null) {
                strResponse = strResponse.replace('[[','[');
				strResponse = strResponse.replace(']]',']');
                MMIDresponse = (MapMyIndiaDistanceResponseWrap) JSON.deserialize(strResponse, MapMyIndiaDistanceResponseWrap.class);
                if (MMIDresponse.responseCode == '200' && MMIDresponse.results != NULL && MMIDresponse.results.distances != NULL && MMIDresponse.results.distances.size()>1) {
                    wrap.dblDistance = MMIDresponse.results.distances[1] != NULL ? (Decimal.valueOf(MMIDresponse.results.distances[1])/ 1000).setscale(3) : NULL;
                }
                else {
                    wrap.blnError = true;
                    wrap.strMsg = Label.MapMyIndiaDistance_Integration_Error_Message;
                }
            }
            else{
                wrap.blnError = true;
                wrap.strMsg = Label.MapMyIndiaDistance_Integration_Error_Message;
            }
            wrap.MMIDresponse = MMIDresponse;
        } catch(Exception objException) {
            System.debug(LoggingLevel.Error,'MMIDresponse---'+objException);
            System.debug(LoggingLevel.Error,'MMIDresponse-Line--'+objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return wrap;
    }
    
    @TestVisible
    private static String generateRequest(String strCurrentLatandLong, String strAddress, Integration_Master__c objIntMaster){
        MMIndiaDistanceRequest objRequest = new MMIndiaDistanceRequest();
        objRequest.Channel = objIntMaster.Channel__c;
        objRequest.RequestId = IntegrationUtility.getReferenceId();
        objRequest.SourceLocation = strCurrentLatandLong;
        objRequest.Address  = strAddress;//'17ZUL7';//strAddress;
        return JSON.serialize(objRequest);
    }
    
    public class MMIndiaDistanceRequest {
        public string Channel {get;set;}
        public String RequestId {get;set;}
        public String SourceLocation {get;set;}
        public String Address {get;set;}
    }
    
    public class MMIDWrapper {
        @AuraEnabled
        public MapMyIndiaDistanceResponseWrap MMIDresponse {get;set;}
        @AuraEnabled
        public String strMsg {get;set;}
        @AuraEnabled
        public Boolean blnError {get;set;}
        @AuraEnabled
        public Double dblDistance {get;set;}
    }
    
    public class CustomException extends Exception{}
}