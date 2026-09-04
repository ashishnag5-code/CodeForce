/*******************************************************************************************
* @Name         AddressTriggerService
* @Author       Gaurav Gaur
* @Description  Service class for Address Trigger - common methods across all portfolios
*               are written in this class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Gaurav Gaur        06/02/2023        Initial Creation 
*******************************************************************************************/
public without sharing class AddressTriggerService implements ServiceInterface {
    public static Boolean isFirstTime = true;
    
    public void beforeInsert(List<sObject> newRecordList){
        
        // SFAU-5203 - Kunal
        addHouingNumberInLine1(newRecordList);
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        
    }

    private static void addHouingNumberInLine1(List<Address__c> newList){
        for(Address__c address : newList){
            if( (String.isBlank(address.Address_Line_1__c) || address.Address_Line_1__c.length() < 3) && address.Pincode__c != null){
                address.Address_Line_1__c = 'HNo ' + (String.isBlank(address.Address_Line_1__c) ? '' : address.Address_Line_1__c);
            }
        }
    }
    
    private static void updateSameAsAddreses(Map<Id, Address__c> oldAddressMap, Map<Id, Address__c> newAddressMap ){
        Map<String, List<Address__c>> updateApplicantAddressMap = new Map<String, List<Address__c>>();
        Map<String, Set<String>> updatedAddressTypeMap = new Map<String, Set<String>>();
        for(Id addrId : newAddressMap.keySet()){
            if(String.isBlank(newAddressMap.get(addrId).Source_Type__c)){
                if(!updateApplicantAddressMap.containsKey(newAddressMap.get(addrId).Applicant__c )){
                    updateApplicantAddressMap.put(newAddressMap.get(addrId).Applicant__c , new List<Address__c>());
                    updatedAddressTypeMap.put(newAddressMap.get(addrId).Applicant__c , new Set<String>());
                }
                updateApplicantAddressMap.get(newAddressMap.get(addrId).Applicant__c).add(newAddressMap.get(addrId));
                updatedAddressTypeMap.get(newAddressMap.get(addrId).Applicant__c).add(newAddressMap.get(addrId).Address_Type__c );
            }
        }
        
        List<Address__c> addressRecords = [SELECT ID, Address_Line_1__c , Address_Line_2__c , Address_Line_3__c , Pincode__c, Applicant__c, 
                                           Same_As__c, State__c, City__c, District__c, Area_Name__c, Taluka__c, Area_Type__c,
                                           Land_mark__c, Stability__c, Address_Source__c  ,Status__c , Type__c
                                           FROM
                                           Address__c WHERE Applicant__c IN :updatedAddressTypeMap.keySet() AND
                                           Source_Type__c = ''];
        for(Address__c relatedAddress : addressRecords){
            Set<String> addressTypes = updatedAddressTypeMap.get(relatedAddress.Applicant__c);
            if(addressTypes.contains(relatedAddress.Same_As__c)){
                for(Address__c addr : updateApplicantAddressMap.get(relatedAddress.Applicant__c)){
                    if(addr.Address_Type__c == relatedAddress.Same_As__c){
                        relatedAddress.Address_Line_1__c = newAddressMap.get(addr.Id).Address_Line_1__c;
                        relatedAddress.Address_Line_2__c = newAddressMap.get(addr.Id).Address_Line_2__c;
                        relatedAddress.Address_Line_3__c = newAddressMap.get(addr.Id).Address_Line_3__c;
                        relatedAddress.Pincode__c = newAddressMap.get(addr.Id).Pincode__c;
                        relatedAddress.State__c  = newAddressMap.get(addr.Id).State__c ;
                        
                        relatedAddress.City__c  = newAddressMap.get(addr.Id).City__c ;
                        relatedAddress.District__c  = newAddressMap.get(addr.Id).District__c ;
                       // relatedAddress.Area_Name__c  = newAddressMap.get(addr.Id).Area_Name__c ;
                        relatedAddress.Taluka__c  = newAddressMap.get(addr.Id).Taluka__c ;
                        relatedAddress.Area_Type__c   = newAddressMap.get(addr.Id).Area_Type__c;
                        
                        relatedAddress.Land_mark__c  = newAddressMap.get(addr.Id).Land_mark__c;
                       // relatedAddress.Stability__c   = newAddressMap.get(addr.Id).Stability__c  ;
                        relatedAddress.Address_Source__c   = newAddressMap.get(addr.Id).Address_Source__c  ;
                       relatedAddress.Status__c  = newAddressMap.get(addr.Id).Status__c ;
                      // relatedAddress.Type__c   = newAddressMap.get(addr.Id).Type__c;
                    }
                }
            }
        }
        
        isFirstTime = false;
        update addressRecords;
        
        
       
    }
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
        if(isFirstTime){
            Map<Id, Address__c> oldAddRecordMap = (Map<Id, Address__c>)oldRecordMap;
            system.debug('oldAddRecordMap'+oldAddRecordMap);
            Set<Id> setOfAppIds = new Set<Id>();
            for(Address__c add : (List<Address__c>)newRecordList){

                if( (String.isBlank(add.Address_Line_1__c) || add.Address_Line_1__c.length() < 3) && add.Pincode__c != null){  // SFAU-5203 - Kunal
                    add.Address_Line_1__c = 'HNo ' + (String.isBlank(add.Address_Line_1__c) ? '' : add.Address_Line_1__c);
                }

                system.debug('add.Address_Line_1__c'+add.Address_Line_1__c);
                system.debug('oldAddRecordMap.get(add.Id).Address_Line_1__c'+oldAddRecordMap.get(add.Id).Address_Line_1__c);
                // if any of the paramters of Address which goes to CIBIL get's updated, set rerun Cibil as true
                if((oldAddRecordMap.get(add.Id).Address_Line_1__c != add.Address_Line_1__c) || (oldAddRecordMap.get(add.Id).Address_Line_2__c != add.Address_Line_2__c) 
                   || (oldAddRecordMap.get(add.Id).Address_Line_3__c != add.Address_Line_3__c) || (oldAddRecordMap.get(add.Id).Address_Type__c != add.Address_Type__c)
                   || (oldAddRecordMap.get(add.Id).City__c != add.City__c) || (oldAddRecordMap.get(add.Id).Pincode__c != add.Pincode__c)
                   || (oldAddRecordMap.get(add.Id).State__c != add.State__c)){
                       setOfAppIds.add(add.applicant__c);
                   }
            } 
            // Do not set CIBIL Rerun as true of Loan Application is Pre-approved --> Kunal [9th Sept]
            if(!setOfAppIds.isEmpty() && setOfAppIds.size() > 0){
                List <Applicant__c> applicantListToUpdate = new List <Applicant__c>();
                for(Applicant__c app: [SELECT Id, CIBIL_Rerun__c, CIBIL_Status__c, Last_CIBIL_Run_Date__c FROM Applicant__c WHERE Id IN: setOfAppIds AND Loan__r.Pre_Approved_Flag__c = False AND CIBIL_Status__c != null WITH SECURITY_ENFORCED]){
                    app.CIBIL_Rerun__c = true;
                    app.CIBIL_Status__c = null;
                    app.Last_CIBIL_Run_Date__c = null;
                    applicantListToUpdate.add(app);
                }
                if(!applicantListToUpdate.isEmpty() && applicantListToUpdate.size() > 0){
                    update applicantListToUpdate;
                }
                
            }
            
        }
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        if(isFirstTime){
            updateSameAsAddreses((Map<Id, Address__c>)oldRecordMap, (Map<Id, Address__c>)newRecordMap);
        }
        
        
        
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }   
    
    
}