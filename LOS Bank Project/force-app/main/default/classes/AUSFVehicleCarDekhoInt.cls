public with sharing class AUSFVehicleCarDekhoInt {
    public static final String CAR_DEKHO_INT_MASTER_NAME = 'Car Dekho Pricing';

    public static CarDekhoResponseWrapper callCarDekhoAPI(String variantId, String cityId){
        CarDekhoResponseWrapper pricingInfo = new CarDekhoResponseWrapper();
        try{
            Integration_Checklist__c checklist = new Integration_Checklist__c();
            Integration_Master__c integrationMaster = IntegrationUtility.getIntegrationMasterRecord(CAR_DEKHO_INT_MASTER_NAME);
            Map<String,Object> inputParams = new Map<String,Object>{
                'variantId' => 
                variantId, 
                //'8095',
                'cityId' =>
                cityId
                // '49'
            };
            //:TODO remove hardcodes
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = AUSFVehicleCarDekhoIntHandler.generateRequest(inputParams)[0];
            calloutRequestWrapper.method = integrationMaster.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = integrationMaster;
            calloutRequestWrapper.checklistRecord = checklist;
            IntegrationUtility.ResponseWrapper response = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper '+response);

            AUSFVehicleCarDekhoIntHandler.CarDekhoFailureResponseWrapper failureResponse = (AUSFVehicleCarDekhoIntHandler.CarDekhoFailureResponseWrapper)JSON.deserialize(
                response.response,
                AUSFVehicleCarDekhoIntHandler.CarDekhoFailureResponseWrapper.class
            );
            System.debug(JSON.serializePretty(failureResponse));
            if( failureResponse.errors == NULL || failureResponse.errors.isEmpty() ){
                pricingInfo.pricing = ((AUSFVehicleCarDekhoIntHandler.CarDekhoResponseWrapper)JSON.deserialize(
                    response.response,
                    AUSFVehicleCarDekhoIntHandler.CarDekhoResponseWrapper.class
                ))?.data;
            } else {
                pricingInfo.errorMessage = (String)failureResponse.errors.get('displayMessage');
            }
            pricingInfo.statusCode = response.statusCode;
        }
        
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),'');
        }
        return pricingInfo;
    }

    public class CarDekhoResponseWrapper{
        @AuraEnabled public AUSFVehicleCarDekhoIntHandler.CarDekhoResponseWrapper pricing;
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String errorMessage;
    }
}