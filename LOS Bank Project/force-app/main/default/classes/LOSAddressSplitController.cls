public with sharing class LOSAddressSplitController {
    
    public static Address__c callAddressSplitApi(String address, String strApplicantId){
        Address__c newAddress = new Address__c();
        try{        
            String respBody;
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza Address Split');

            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('Address',address);
            String requestBody = LOSAddressSplitHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper '+calloutResponseWrapper);
            respBody = calloutResponseWrapper.response;
            system.debug('respBody '+respBody);
            LOSAddressSplitHandler.AddressSplitResponseWrapper responseWrapper = (LOSAddressSplitHandler.AddressSplitResponseWrapper) 
            System.JSON.deserialize(respBody, LOSAddressSplitHandler.AddressSplitResponseWrapper.class);
            if(responseWrapper!=null && responseWrapper.result!=null){
                responseWrapper.result.Care_Of = String.ValueOf(((Map<String, Object>)(((Map<String, Object>)JSON.deserializeUntyped(respBody)).get('result'))).get('C/O'));
                newAddress = mapAddressSplitToAddressObject(responseWrapper.result);
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return newAddress;
    }

    public static Address__c mapAddressSplitToAddressObject(LOSAddressSplitHandler.AddressSplitResponseResultWrapper address){

        Address__c newAddress = new Address__c();
        address.Care_Of = address.Care_Of!=''?address.Care_Of+' ':'';
        address.House = address.House!=''?address.House+' ':'';
        address.Floor = address.Floor!=''?address.Floor+' ':'';
        address.Building = address.Building!=''?address.Building+' ':'';
        address.Complex = address.Complex!=''?address.Complex+' ':'';
        address.Street = address.Street!=''?address.Street+' ':'';
        address.Untagged = address.Untagged!=''?address.Untagged+' ':'';
        address.Landmark = address.Landmark!=''?address.Landmark:'';
        String addressLine1 = address.Care_Of+address.House+address.Floor+address.Building+address.Complex;
        if(addressLine1.length()>35){
            newAddress.Address_Line_1__c = addressLine1.substring(0,34);
            newAddress.Address_Line_2__c = addressLine1.substring(35)+address.Street+address.Untagged;
        }else{
            newAddress.Address_Line_1__c = addressLine1;
            newAddress.Address_Line_2__c = address.Street+address.Untagged;
        }
        newAddress.Address_Line_3__c = address.Landmark;
        newAddress.City__c = address.City;
        newAddress.District__c = address.District;
        newAddress.State__c = address.State;
        newAddress.Pincode__c = String.valueOf(address.Pin);
        system.debug('Address__c '+newAddress);
        return newAddress;
    }
}