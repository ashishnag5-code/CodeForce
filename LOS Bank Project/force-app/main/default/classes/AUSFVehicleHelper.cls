public without sharing class AUSFVehicleHelper {
    
    public static String getPicklistLabel(String product){
        String picklistLabel;
        Schema.DescribeFieldResult fieldResult = Loan_Application__c.Product__c.getDescribe(); 
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
        for(Schema.PicklistEntry v : values){ 
            if(product ==v.getValue()){
                picklistLabel = v.getLabel();
            System.debug('Picklist Value Label:' + v.getLabel()); 
            System.debug('Picklist API Name:' + v.getValue()); 
            }
        }
        return picklistLabel;
    }
    
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile, String typeOfWheeler) {
        List<Stage_Profile_Data_Configuration__mdt> lstStageProfileData = [Select Id,Fields__c,Loan_Stage__c,Object__c,
                                Profile__c,Screen__c from Stage_Profile_Data_Configuration__mdt where Screen__c=:strScreen 
                                    AND Loan_Stage__c =:strStage AND Profile__c =:strProfile AND Vehicle_Type__c=:typeOfWheeler];
        List<String> strFields = new List<String>();
        strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        return strFields;
    }
    
    
    /**
    NOT  IN USE
    @AuraEnabled(cacheable=true)
    public static  Map<string,List<PicklistWrapper>> getUsedProductPickListValues(String productValue,String manufacturer) {
        List<PicklistWrapper> statesLst = new List<PicklistWrapper>();
        map<string,List<PicklistWrapper>>  mapOfLocations = new  map<string,List<PicklistWrapper>>();
        Map<String,Map<string,List<PicklistWrapper>>>  mapOfManfacturerToMake = new  Map<String,Map<string,List<PicklistWrapper>>>();
        try{
            mapOfLocations.put(System.Label.Product,new List<PicklistWrapper>());
            Set<String> myset = new Set<String>();
            Set<String> modelset = new Set<String>();
            String myQuery;
            //if(productValue.contains(System.label.AUSFUsedScreen) || productValue.contains(System.label.AUSFCowScreen)){
            if(productValue!=null && (System.label.AUSFUsedScreen.contains(productValue) || System.label.AUSFCowScreen.toUpperCase().contains(productValue.toUpperCase()) || System.label.AUSFCowScreenR2.toUpperCase().contains(productValue.toUpperCase()))){//R2-2634
                system.debug('in else '+productValue);
                Id usedRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Used CoW MMV Master').getRecordTypeId();
                List<String> collateralCodeList = new List<String>();
                for(Product_vs_Collateral_Master__mdt prdVsColCode:[SELECT Collateral_Code__c FROM Product_vs_Collateral_Master__mdt WHERE Product_Name__c =:productValue]){
                    
                    system.debug('in for loop');
                    if(prdVsColCode.Collateral_Code__c!=null){
                        system.debug('in if 2');
                        collateralCodeList.add(prdVsColCode.Collateral_Code__c);
                    }
                }
                system.debug('collateralCodeList>> '+collateralCodeList);
                myQuery = 'SELECT id,Make__c,Model__c FROM Generic_Master__c WHERE  recordTypeId=:usedRecordTypeId AND Collateral_Code__c IN :collateralCodeList AND Manufacturer__c=:manufacturer WITH SECURITY_ENFORCED'; 
                if(String.isNotBlank(myQuery)){
                    String actualQuery = String.escapeSingleQuotes(myQuery);
                    for(Generic_Master__c obj:Database.query(actualQuery)){
                        List<PicklistWrapper> pickValues = new List<PicklistWrapper>();
                        if(obj.Make__c!=null){
                            if (myset.add(obj.Make__c)) {
                                mapOfLocations.get(System.Label.Product).add(new PicklistWrapper(obj.Make__c,obj.Make__c)) ;
                                
                            }
                            system.debug('obj.Make__c1>> '+obj.Make__c);
                            if(mapOfLocations.containsKey(obj.Make__c)){
                                if(modelset.add(obj.Make__c)){
                                    system.debug('obj.Make__c2>> '+obj.Make__c);
                                	mapOfLocations.get(obj.Make__c).add(new PicklistWrapper(obj.Model__c,obj.Model__c));
                                }
                                
                            }else{
                                system.debug('obj.Make__c3>> '+obj.Make__c);
                                modelset.add(obj.Model__c);
                                pickValues.add(new PicklistWrapper(obj.Model__c,obj.Model__c));
                                mapOfLocations.put(obj.Make__c,pickValues);
                            }
                            
                        }
                    }
                } 
            }
            
        }   
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return mapOfLocations; 
        
    }
    
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }*/

}