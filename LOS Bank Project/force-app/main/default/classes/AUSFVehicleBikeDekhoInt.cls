public with sharing class AUSFVehicleBikeDekhoInt {
    @AuraEnabled  
    public static BikeDekhoResponseWrapper callBikeDekhoAPI(String variantId,String cityId){
        BikeDekhoResponseWrapper wrap = new BikeDekhoResponseWrapper();
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Bike Dekho Pricing');
            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('variantId',variantId);
            reqParam.put('cityId',cityId);
            String requestBody = AUSFVehicleBikeDekhoIntHandler.generateRequest(reqParam)[0];

            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper '+calloutResponseWrapper);
            wrap.statusCode = calloutResponseWrapper.statusCode;
            AUSFVehicleBikeDekhoIntHandler.BikeDekhoFailureResponse failureResponse = (AUSFVehicleBikeDekhoIntHandler.BikeDekhoFailureResponse)JSON.deserialize(calloutResponseWrapper.response, AUSFVehicleBikeDekhoIntHandler.BikeDekhoFailureResponse.class);
            if( failureResponse.errors == NULL || failureResponse.errors.isEmpty() ){
                AUSFVehicleBikeDekhoIntHandler.BikeDekhoResponseWrapper responseWrapper = (AUSFVehicleBikeDekhoIntHandler.BikeDekhoResponseWrapper)JSON.deserialize(calloutResponseWrapper.response, AUSFVehicleBikeDekhoIntHandler.BikeDekhoResponseWrapper.class);
                wrap.pricing = responseWrapper.data;
            } else {
                wrap.errorMessage = (String)failureResponse?.errors.get('displayMessage');
            }

        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),'');
        }
        return wrap;
    }
    
    public class BikeDekhoResponseWrapper{
        @AuraEnabled public AUSFVehicleBikeDekhoIntHandler.BikeDekhoResponseData pricing;
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String errorMessage;
    }
}