public with sharing class LOSKarzaAddressMatchController {
    @AuraEnabled
    public static String validateAddressMatch(List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddresses, List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddresses, String strApplicantId, String typeOfSource, String type) {
        String respBody;
        try{     
            Applicant__c applicant = [Select DOB__c,First_Name__c, Middle_Name__c, Last_Name__c FROM Applicant__c where ID=:strApplicantId]; 
            
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza Multiple Address Match');

            Map<String,LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper> reqParam = new Map<String,LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper>();
            LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper newWrapper = new LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper();
            newWrapper.requestId=IntegrationUtility.getReferenceId();
            newWrapper.channel= Label.LOSKarzaAddressMatchController_Channel ;
            newWrapper.consent='y';

            newWrapper.source = new LOSKarzaAddressMatchIntHandler.AddressMatchSourceRequestWrapper();
            newWrapper.source.name=new LOSKarzaAddressMatchIntHandler.NameRequestWrapper();
            newWrapper.source.name.first=applicant.First_Name__c;
            newWrapper.source.name.middle=applicant.Middle_Name__c!=null?applicant.Middle_Name__c:'';
            newWrapper.source.name.last=applicant.Last_Name__c;
            newWrapper.source.relationNames=new List<LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper>();
            LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper newRelation1 = new LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper();
            newRelation1.name=newWrapper.source.name;
            newRelation1.relationReference='SELF';
            newWrapper.source.relationNames.add(newRelation1);
            newWrapper.source.addresses = sourceAddresses;
            newWrapper.source.dob=String.valueOf(applicant.DOB__c);

            newWrapper.target = new LOSKarzaAddressMatchIntHandler.AddressMatchTargetRequestWrapper();
            newWrapper.target.referenceId = IntegrationUtility.getReferenceId();
            newWrapper.target.name = new LOSKarzaAddressMatchIntHandler.NameRequestWrapper();
            newWrapper.target.name.first=applicant.First_Name__c;
            newWrapper.target.name.middle=applicant.Middle_Name__c!=null?applicant.Middle_Name__c:'';
            newWrapper.target.name.last=applicant.Last_Name__c;
            newWrapper.target.relationNames = new List<LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper>();
            LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper newRelation2 = new LOSKarzaAddressMatchIntHandler.RelationNameRequestWrapper();
            newRelation2.name=newWrapper.target.name;
            newRelation2.relationReference='SELF';
            newWrapper.target.relationNames.add(newRelation2);
            newWrapper.target.dob = String.valueOf(applicant.DOB__c);
            newWrapper.target.addresses = targetAddresses;
    
            newWrapper.clientData=new LOSKarzaAddressMatchIntHandler.ClientDataWrapper(); 

            String requestBody = JSON.serialize(newWrapper); 

            LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper requestWrapper = (LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper)
            JSON.deserialize(requestBody, LOSKarzaAddressMatchIntHandler.AddressMatchRequestWrapper.class);
            String objectId = '';
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

            LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper responseWrapper = (LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper) 
            JSON.deserialize(respBody, LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper.class);

            system.debug('responseWrapper '+responseWrapper);
            List<sObject> sObjectListToUpdate = new List<sObject>();
            if(typeOfSource == 'CIBIL'){
                system.debug('Inside Cibil');
                List<Address__c> sourceAddressList = [SELECT Id , Oldest_Cibil_Address_Match_Score__c, Latest_Cibil_Address_Match_Score__c FROM Address__c 
                            where Applicant__c=:strApplicantId and Address_Type__c =:type
                            AND Source_Type__c=null WITH SECURITY_ENFORCED LIMIT 1];

                system.debug('Scores '+responseWrapper.result.flags[0].address.scores);
                if(responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
                    for(LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapperScore score: responseWrapper.result.flags[0].address.scores){
                        if(score.refernce2 == 'TARGET_0'){
                            sourceAddressList[0].Oldest_Cibil_Address_Match_Score__c = score.score*100;
                        }
                        if(score.refernce2 == 'TARGET_1'){
                            sourceAddressList[0].Latest_Cibil_Address_Match_Score__c = score.score*100;
                        }
                    }
                    sObjectListToUpdate.add(sourceAddressList[0]);
                }
            }
            if(typeOfSource == 'CPV'){
                /*List<Document_Checklist__c> docCheckListRecords = [SELECT Id,Address_Match_Score__c, Document_Number__c, Document_Master__c,Status__c,
                                                                            Document_Master__r.Document_Name__c, Applicant__c, Applicant__r.Loan__c,
                                                                            Applicant__r.RecordTypeId, Applicant__r.RecordType.DeveloperName
                                                                            FROM Document_Checklist__c WHERE 
                                                                            Applicant__c=:strApplicantId AND
                                                                            Document_Master__r.Document_Name__c=:type
                                                                            ORDER BY CreatedDate DESC LIMIT 1];
                if(responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
                    docCheckListRecords[0].Address_Match_Score__c=responseWrapper.result.flags[0].address.scores[0].score * 100;
                    sObjectListToUpdate.add(docCheckListRecords[0]);
                }else{
                    docCheckListRecords[0].Address_Match_Score__c = null;
                    sObjectListToUpdate.add(docCheckListRecords[0]);
                }*/

                
            }
            if(typeOfSource == 'AADHAR'){
                if(responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
                    List<Address__c> addresses = [SELECT Id , ETB_Address_Match_Score__c FROM Address__c 
                            where Applicant__c=:strApplicantId and Address_Type__c =:type
                            AND Source_Type__c=null  WITH SECURITY_ENFORCED LIMIT 1];
                    if(addresses!=null && addresses.size()>0){
                        addresses[0].ETB_Address_Match_Score__c=responseWrapper.result.flags[0].address.scores[0].score * 100;
                        sObjectListToUpdate.add(addresses[0]);
                    }
                    
                }
                
            }
            if(typeOfSource == 'CART'){
                if(responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
                    List<Address__c> addresses = [SELECT Id , CART_Address_Match_Score__c FROM Address__c 
                            where Applicant__c=:strApplicantId and Address_Type__c =:type
                            AND Source_Type__c=null  WITH SECURITY_ENFORCED LIMIT 1];
                    if(addresses!=null && addresses.size()>0){
                        addresses[0].CART_Address_Match_Score__c=responseWrapper.result.flags[0].address.scores[0].score * 100;
                        /*Address__c newAddress = new Address__c();
                        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper copyfrom = targetAddresses[0];
                        newAddress.Address_Line_1__c = copyfrom.addressLine1;
                        newAddress.Address_Line_2__c = copyfrom.addressLine2;
                        newAddress.Address_Line_3__c = copyfrom.locality;
                        newAddress.City__c = copyfrom.city;
                        newAddress.State__c = copyfrom.state;
                        newAddress.Pincode__c = copyfrom.pincode;
                        newAddress.Source_Type__c = 'Cart';
                        newAddress.Applicant__c = strApplicantId;
                        //insert newAddress;*/
                        sObjectListToUpdate.add(addresses[0]);
                        //sObjectListToUpdate.add(newAddress);

                    }
                    
                }
                
            }
            if( typeOfSource == 'RCOIdentification'){
                if(responseWrapper.result.flags[0].address.scores!=null && responseWrapper.result.flags[0].address.scores.size()>0){
                    Boolean rcoEnabled = false;
                    for(LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapperScore score: responseWrapper.result.flags[0].address.scores){
                        Decimal scorePercentage = score.score*100;
                        Decimal minPercentage = Decimal.valueOf(System.label.RCO_Percentage);
                        if(scorePercentage>=minPercentage){
                            rcoEnabled = true;
                        }else{
                            rcoEnabled = false;
                        }
                        
                    }
                    //if(rcoEnabled == true){
                        Applicant__c applicantInstance = new Applicant__c();
                        applicantInstance.Id = strApplicantId;
                        applicantInstance.Risk_Identification__c = rcoEnabled;
                        applicantInstance = AddressComponentHandler.getRiskCategoryBasedOnRiskIdentification(applicantInstance, 'Risk_Identification__c');
                        sObjectListToUpdate.add(applicantInstance);
                    //}  
                }
            }

            if(sObjectListToUpdate!=null && sObjectListToUpdate.size()>0){
                //update sObjectListToUpdate;
                upsert sObjectListToUpdate;

            }

        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return respBody;
    }

    public static void callAddressParsingMethod(Set<Id> cibilTargetAddressIds, String applicantId){
            addressParsingMethod(cibilTargetAddressIds,applicantId,'Current');
            addressParsingMethod(cibilTargetAddressIds,applicantId,'Permanent');
    }

    @future(callout=true)
    public static void addressParsingMethod(Set<Id> cibilTargetAddressIds, String applicantId, String addressType){

            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> newAddressTargetWrapper = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();

            List<Address__c> cibilTargetAddresses = [SELECT Id , Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c,
            Applicant__c, State__c, City__c, Pincode__c FROM Address__c 
            where Id in :cibilTargetAddressIds WITH SECURITY_ENFORCED ORDER BY Date_reported__c];

            for(Address__c address: cibilTargetAddresses){
                newAddressTargetWrapper.add(createAddressWrapper(address));
            }

            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressListToBePassed = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
            if(newAddressTargetWrapper!=null && newAddressTargetWrapper.size()>0){
                targetAddressListToBePassed.add(newAddressTargetWrapper[0]);
                Integer position = newAddressTargetWrapper.size()-1;
                targetAddressListToBePassed.add(newAddressTargetWrapper[position]);
            }
            List<Address__c> sourceAddressList = [SELECT Id , Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c,
                            Applicant__c, State__c, City__c, Pincode__c FROM Address__c 
                            where Applicant__c=:applicantId and Address_Type__c =:addressType
                            AND Source_Type__c != 'Cibil' WITH SECURITY_ENFORCED LIMIT 1];
            
            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressWrapper = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
            if(sourceAddressList!=null && sourceAddressList.size()>0){
                sourceAddressWrapper.add(createAddressWrapper(sourceAddressList[0]));
            }
            validateAddressMatch(sourceAddressWrapper,targetAddressListToBePassed,applicantId,'CIBIL',addressType);

    }

    @AuraEnabled
    public static void addressMatchForAadhar(String response, String recordId){
        try {
            List<Address__c> etbAddress = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c,  State__c, Pincode__c
            FROM Address__c where Source_Type__c = 'CBS' and Applicant__c =: recordId and Address_Type__c='Permanent' WITH SECURITY_ENFORCED Order By CreatedDate Desc];

            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressWrapperList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressWrapperList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();

            if(etbAddress!=null && etbAddress.size()>0){
                sourceAddressWrapperList.add(createAddressWrapper(etbAddress[0]));
                LOSAdharKycInfoData kycData = (LOSAdharKycInfoData) JSON.deserialize(response, LOSAdharKycInfoData.class);
                LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapper = new LOSKarzaAddressMatchIntHandler.AddressRequestWrapper();
                wrapper.addressLine1 = kycData.loc;
                wrapper.state = kycData.state;
                targetAddressWrapperList.add(wrapper);                
                validateAddressMatch(sourceAddressWrapperList,targetAddressWrapperList,recordId,'AADHAR','Permanent');
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void addressMatchForCART(String recordId, String address){
        try {
            
            List<Address__c> currentAddress = [SELECT Id, Address_Line_1__c, Source_Type__c, Address_Line_2__c, Address_Line_3__c, City__c,  State__c, Pincode__c
            FROM Address__c where Applicant__c =: recordId and Source_Type__c not in ('CBS','Cart','Cibil') and Address_Type__c='Current' WITH SECURITY_ENFORCED Order By CreatedDate Desc];
            
            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressWrapperList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
            List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressWrapperList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();

            if(currentAddress!=null && currentAddress.size()>0){
                sourceAddressWrapperList.add(createAddressWrapper(currentAddress[0]));
                targetAddressWrapperList.add(createAddressWrapper((Address__c) JSON.deserialize(address, Address__c.class)));                
                validateAddressMatch(sourceAddressWrapperList,targetAddressWrapperList,recordId,'CART','Current');
            }

        } catch (Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),recordId);
        }
    }

    public static LOSKarzaAddressMatchIntHandler.AddressRequestWrapper createAddressWrapper(Address__c objAddress){
        LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapper = new LOSKarzaAddressMatchIntHandler.AddressRequestWrapper();
        wrapper.addressLine1 = objAddress.Address_Line_1__c;
        wrapper.addressLine2 = objAddress.Address_Line_2__c;
        wrapper.locality = objAddress.Address_Line_3__c;
        wrapper.city = objAddress.City__c;
        wrapper.state = objAddress.State__c;
        wrapper.pincode = objAddress.Pincode__c; 
        return wrapper;
    }
}