/*******************************************************************************************
* @Name         addressComponentHandler
* @Author       Ashish Nag K
* @Description   Controller Class for Address Screen
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Ashish Nag K         04/11/2022         Initial Creation 
*******************************************************************************************/
public without sharing class AddressComponentHandler {
    /*
@description :  Get Picklist Values based on Pincode
@param :  String Pincode
@return : Map<string,List<PicklistWrapper>> 
*/
@AuraEnabled(cacheable=true)
public static  map<string,List<PicklistWrapper>> getLocations(String pinCode, Id applicantId) {
    List<PicklistWrapper> statesLst = new List<PicklistWrapper>();
    map<string,List<PicklistWrapper>>  mapOfLocations = new  map<string,List<PicklistWrapper>>();
    try{
        System.debug('pinCode-->' +pinCode);
        mapOfLocations.put('State',new List<PicklistWrapper>());
        mapOfLocations.put('City',new List<PicklistWrapper>());
        mapOfLocations.put('Taluka',new List<PicklistWrapper>());
        mapOfLocations.put('Areaname',new List<PicklistWrapper>()); 
        mapOfLocations.put('AreaType',new List<PicklistWrapper>()); 
        mapOfLocations.put('Stability',new List<PicklistWrapper>());
        
        for(Location_Master__c obj:[SELECT id,State__c,Name,Taluka__c,City__c,Area_Name__c,Area_Type__c from Location_Master__c where name=:pinCode ]){
           System.debug('obj-->' +obj);
            if(obj.State__c!=null){
                mapOfLocations.get('State').add(new PicklistWrapper(obj.State__c,obj.State__c)) ;
            } 
            if(obj.City__c!=null){
                mapOfLocations.get('City').add(new PicklistWrapper(obj.City__c,obj.City__c));
            }
            if(obj.Taluka__c!=null){
                mapOfLocations.get('Taluka').add(new PicklistWrapper(obj.Taluka__c,obj.Taluka__c));
            }
            if(obj.Area_Name__c!=null){
                mapOfLocations.get('Areaname').add(new PicklistWrapper(obj.Area_Name__c,obj.Area_Name__c));
            }
            if(obj.Area_Type__c!=null){
                mapOfLocations.get('AreaType').add(new PicklistWrapper(obj.Area_Type__c,obj.Area_Type__c));
            }
            
        }
        
        List<String> pickList = getPicklistValues('Address__c','Stability__c');
        for(String pickInstance : pickList){
            mapOfLocations.get('Stability').add(new PicklistWrapper(pickInstance,pickInstance));
        }
        // String responseDistance =calculateDistance(pinCode,applicantId);
        //System.debug('responseDistance-->' +responseDistance);
        System.debug('mapOfLocations-->' +mapOfLocations);
        
    }   
    catch(Exception objException) {
        // Log.error(objException,Log.SeverityType.valueOf('High'));
    }
    return mapOfLocations; 
    
}
    
    /*
@description :  Method to get the Applicant details from applicant record id
@param :  Id  recordId
@return : addressApplicantWrapper
*/
    @AuraEnabled
    public static addressApplicantWrapper getApplicantAddress(Id recId){
        addressApplicantWrapper wrapperInstance = new addressApplicantWrapper();
        try{
          
            Set<String> uniqueAddressTypeSet = new Set<String>();
            List<Address__c> addressList = new List<Address__c>();
            Applicant__c applicantInstance = [SELECT id,Name,Customer_Type__c,NREGA__c,NPR__c,Loan__r.OPS_KYC_Action__c FROM Applicant__c WHERE id=:recId ];

            if(applicantInstance.Customer_Type__c == 'Individual'){
                 addressList =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c,Same_As__c,Office_Number__c,Office_Email_address__c,Applicant__r.KYC_Type__c,Village__c,Khata_Khasara_Survey_Number__c, Applicant__r.Existing_Customer__c,Source_Type__c // SFAU-5716
                FROM Address__c
                WHERE Applicant__c=:recId 
                AND Address_Type__c != null
                AND Source_Type__c != 'Cart'
                AND Source_Type__c != 'Cibil'  WITH SECURITY_ENFORCED];
            }else if(applicantInstance.Customer_Type__c == 'Non Individual'){
                addressList =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c,Same_As__c,Office_Number__c,Office_Email_address__c,Applicant__r.KYC_Type__c,Village__c,Khata_Khasara_Survey_Number__c, Source_Type__c // SFAU-5716
                FROM Address__c
                WHERE Applicant__c=:recId 
                AND Address_Type__c != null 
                AND Address_Type__c !='Permanent'
                AND Source_Type__c != 'Cart'
                AND Source_Type__c != 'Cibil'  WITH SECURITY_ENFORCED];
            }
          
    
            String strProduct;
            
            Applicant__c appObj = [SELECT Id,Loan__r.RecordType.Name,Residential_Status__c, RecordType.Name, Customer_Type__c,Constitution_Type__c,NREGA__c,NPR__c,Loan__r.Product__c,Loan__r.Id, Loan__r.Recordtype.DeveloperName  FROM Applicant__c WHERE Id =: recId  WITH SECURITY_ENFORCED];
            wrapperInstance.objApplicant = appObj;
            wrapperInstance.isTwoWheeler = appObj.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER ? true : false; // SFAU-5716
            if(appObj.Customer_Type__c == 'Non Individual'){
                wrapperInstance.constitutionType = appObj.Constitution_Type__c;
            }
            if(appObj.RecordType.Name == 'BO' && appObj.Customer_Type__c == 'Non Individual'){
                wrapperInstance.strCustomerType = 'Individual';  
            }
            else{
                wrapperInstance.strCustomerType = appObj.Customer_Type__c; 
            }
            if(appObj !=null && appObj.Residential_Status__c!=null){
                wrapperInstance.strResidentialStatus = appObj.Residential_Status__c;
            }
            List<Document_Checklist__c> docChkLst = [SELECT Id, Address__c FROM Document_Checklist__c WHERE Document_Master__r.Document_Name__c =: 'Udyam Document' AND Applicant__c =: recId  WITH SECURITY_ENFORCED LIMIT 1 ];
           
            if(docChkLst.size() > 0){
                wrapperInstance.strUdyamAddress = docChkLst[0].Address__c;
            }
            Set<String> addressTakenSet =  new Set<String>();

            //New code added for NREGA And NPR Scenario
            if(String.isNotBlank(appObj.NREGA__c)){
                addressTakenSet.add('NREGA');
            }
            if(String.isNotBlank(appObj.NPR__c)){
                addressTakenSet.add('NPR');
            }
            

            //Verifed Address taken from values
            List<Document_Checklist__c> checkList = [SELECT id,Document_Verification_Status__c, Document_Master__r.Document_Name__c 
                                                    FROM Document_Checklist__c
                                                    WHERE  Document_Master__r.Document_Name__c IN ('Passport','Voter ID Card','Driving Licence','Aadhaar Card','NREGA document','NPR document')
                                                    AND Applicant__c =: recId
                                                    AND Document_Verification_Status__c ='Verified'  WITH SECURITY_ENFORCED ];
            
            if(checkList.size()>0){
                for(Document_Checklist__c checkInstance : checkList){
                    if(checkInstance.Document_Master__r.Document_Name__c == 'Voter ID Card'){
                        addressTakenSet.add('Voter ID');
                    }else{
                        addressTakenSet.add(checkInstance.Document_Master__r.Document_Name__c );
                    }
                    
                }
                wrapperInstance.verifiedAddressTakenSet = addressTakenSet;
            }

            
            
            Map<String, Address__c> filteredAddresses = new Map<String, Address__c>(); //Added this check for SFAU 2924
            for(Address__c addInstance :addressList){
                String addressType = addInstance.Address_Type__c;
                if(!String.isEmpty(addInstance.Address_Type__c)){
                    uniqueAddressTypeSet.add(addInstance.Address_Type__c);
                }
                if(!String.isEmpty(addInstance.Product__c)){
                    strProduct = addInstance.Product__c;
                }
                if( (addressType == 'Current' || addressType =='Permanent' || addressType == 'Office' || addressType =='Touch Point' || addressType == 'Land') &&  !filteredAddresses.containsKey(addressType) ){ //Added this check for SFAU 2924 //R2-37 added Tractor check
                    filteredAddresses.put(addressType,addInstance);
                }

                if(addressType == 'Permanent' && addInstance.Source_Type__c == 'CBS'){ // SFAU-5716
                    wrapperInstance.addressTakenFromCBS = true;
                }
                
            }
            if((appObj.Loan__r.RecordType.DeveloperName!='Tractor' && uniqueAddressTypeSet.size() == 4) || (appObj.Loan__r.RecordType.DeveloperName=='Tractor' && uniqueAddressTypeSet.size() == 5)){//R2-37 added Tractor check
                wrapperInstance.boolIsAddressInsertionAllowed = false;
            }
            
            
            System.debug('addressList-->'+addressList);
            //wrapperInstance.applicantAddressList = addressList;
            wrapperInstance.applicantAddressList = filteredAddresses.values();
            wrapperInstance.strAddressTypes = uniqueAddressTypeSet;
            wrapperInstance.recCount = addressList.size();
            
        }
        catch(Exception objException) {
            //  Log.error(objException,Log.SeverityType.valueOf('High'));
            
        }
        
        return wrapperInstance;
        
    }

    @AuraEnabled
    public static String getApplicantCustomerType(String recordId){
        Applicant__c applicantInstance = [SELECT id,Name,Customer_Type__c,Loan__c FROM Applicant__c WHERE (id=:recordId OR Loan__c =:recordId)];

        String customerType = applicantInstance.Customer_Type__c!=null ?  applicantInstance.Customer_Type__c :'';
        return customerType;
    }
    
    /*
@description :  Method to get the Address details from address record id
@param :  Id  recordId
@return : List <Adress__c>
*/
    @AuraEnabled
    public static List<Address__c> getAddressInfo(Id recId){
        // R2 - 2360
        return [SELECT id,Name,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c,Same_As__c,Office_Number__c,Office_Email_address__c,Applicant__r.KYC_Type__c,Distance_from_Branch__c, Village__c, Khata_Khasara_Survey_Number__c
                FROM Address__c where id=:recId  WITH SECURITY_ENFORCED];
    }
    
    /*
@description :  Method to get the Picklist values from field
@param : String objectName ,String fieldName
@return :  List < String > 
*/
    public static List < String > getPicklistValues(String objectName, String fieldName) {
        List<String> fieldValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal: ple) {
                System.debug(pickListVal.getLabel() + ' ' + pickListVal.getValue());
                fieldValuesList.add(pickListVal.getValue());
            }
        }
        catch(Exception objException) {
            //   Log.error(objException,Log.SeverityType.valueOf('High'));
        }
        if(!fieldValuesList.isEmpty()){
            return fieldValuesList;
        }else{
            return new List<String>();
        }
    }
    /*
@description :  Method to get the dependent values from address type 
@param : String AddressType ,String Product
@return :  map<string,List<String>> 
*/
   /* @AuraEnabled
    public static map<string,List<String>> getProductMetadataValues(String AddressType,String Product,String customerType){
        // Query the product CustomMetadata
        
        map<string,List<String>>  mapOfLocations = new  map<string,List<String>>();
        try{
            
            mapOfLocations.put('ResidenceStatus',new List<String>());
            mapOfLocations.put('ResidenceType',new List<String>());
            mapOfLocations.put('AddressTakenFrom',new List<String>());
            
            List<Generic_Master__c> productMetadataList = [SELECT id,Address_Type__c,Product__c,Residence_Status__c ,Residence_Type__c
                                                           FROM Generic_Master__c
                                                           WHERE  Address_Type__c =:AddressType
                                                           AND Product__c =:Product  WITH SECURITY_ENFORCED];
            System.debug('productMetadataList-->' +productMetadataList);
            
            
            
            for(Generic_Master__c prodInstance : productMetadataList){
                if(prodInstance.Residence_status__c!=null && prodInstance.Residence_Type__c!=null){
                    List<String> ResidenceStatusList = prodInstance.Residence_status__c.split(',');
                    System.debug('ResidenceStatusList-->' +ResidenceStatusList);
                    List<String> ResidenceTypeList = prodInstance.Residence_Type__c.split(',');
                    mapOfLocations.put('ResidenceStatus',ResidenceStatusList);
                    mapOfLocations.put('ResidenceType',ResidenceTypeList);
                }
            }
            
            Map<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues( Address__c.Address_Source__c );
            mapOfLocations.put('AddressTakenFrom',dependValuesByControlValue.get(AddressType));
            System.debug('mapOfLocations-->' +dependValuesByControlValue);
        }
        catch(Exception objException) {
            //   Log.error(objException,Log.SeverityType.valueOf('High'));
        }
        return mapOfLocations;
    }*/
   	/*public static map<string,List<String>> getProductMetadataValues(String AddressType,String Product,String customerType){
        // Query the product CustomMetadata
        
        map<string,List<String>>  mapOfLocations = new  map<string,List<String>>();
        try{
            System.debug('customerType-->' +customerType);
            mapOfLocations.put('ResidenceStatus',new List<String>());
            mapOfLocations.put('ResidenceType',new List<String>());
            mapOfLocations.put('AddressTakenFrom',new List<String>());
            
            List<Generic_Master__c> productMetadataList = [SELECT id,Address_Type__c,Product__c,Residence_Status__c ,Residence_Type__c
                                                           FROM Generic_Master__c
                                                           WHERE  Address_Type__c =:AddressType
                                                           AND Product__c =:Product  WITH SECURITY_ENFORCED];
            System.debug('productMetadataList-->' +productMetadataList);
            
            
            
            for(Generic_Master__c prodInstance : productMetadataList){
                if(prodInstance.Residence_status__c!=null && prodInstance.Residence_Type__c!=null){
                    List<String> ResidenceStatusList = prodInstance.Residence_status__c.split(',');
                    System.debug('ResidenceStatusList-->' +ResidenceStatusList);
                    List<String> ResidenceTypeList = prodInstance.Residence_Type__c.split(',');
                    mapOfLocations.put('ResidenceStatus',ResidenceStatusList);
                    mapOfLocations.put('ResidenceType',ResidenceTypeList);
                }
            }
            
            Map<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues( Address__c.Address_Source__c );
            List<String> filteredValuesList = new List<String>();
            
            for(String valueInstance : dependValuesByControlValue.get(AddressType)){
                System.debug('valueInstance-->' +valueInstance);
                if(customerType == 'Non Individual'){
                    if(AddressType =='Current'){
                        if( valueInstance == 'CKYC'){
                            filteredValuesList.add(valueInstance);
                        }
                    } 
                    if(AddressType == 'Office'){
                        if( valueInstance == 'CKYC' || valueInstance == 'GST' || valueInstance == 'CIN' || valueInstance == 'Udyam' ){
                            filteredValuesList.add(valueInstance);
                        }
                    }
                    System.debug('filteredValuesList-->' +filteredValuesList);
                    mapOfLocations.put('AddressTakenFrom',filteredValuesList); 
                }else if(customerType == 'Individual'){
                    if(AddressType == 'Current'){
                        if( valueInstance != 'CKYC'){
                            filteredValuesList.add(valueInstance);
                        }
                    }else if(AddressType == 'Office'){
                        if(  valueInstance != 'CKYC' &&  valueInstance != 'GST' && valueInstance != 'CIN' && valueInstance != 'Udyam' ){
                            filteredValuesList.add(valueInstance);
                        }
                    }else{
                        filteredValuesList.add(valueInstance);
                    }
                    mapOfLocations.put('AddressTakenFrom',filteredValuesList); 
                }else{
                    mapOfLocations.put('AddressTakenFrom',dependValuesByControlValue.get(AddressType));
                }
                
                
            }
            //mapOfLocations.put('AddressTakenFrom',dependValuesByControlValue.get(AddressType));
            mapOfLocations.put('AddressTakenFrom',filteredValuesList);
            
            System.debug('mapOfLocations-->' +dependValuesByControlValue);
        }
        catch(Exception objException) {
            //   Log.error(objException,Log.SeverityType.valueOf('High'));
        }
        return mapOfLocations;
    }*/
    @AuraEnabled
    public static map<string,List<String>> getProductMetadataValues(String AddressType,String Product,String customerType){
        // Query the product CustomMetadata
        
        map<string,List<String>>  mapOfLocations = new  map<string,List<String>>();
        try{
            System.debug('customerType-->' +customerType);
            mapOfLocations.put('ResidenceStatus',new List<String>());
            mapOfLocations.put('ResidenceType',new List<String>());
            mapOfLocations.put('AddressTakenFrom',new List<String>());
            
            List<Generic_Master__c> productMetadataList = [SELECT id,Address_Type__c,Product__c,Residence_Status__c ,Residence_Type__c
                                                           FROM Generic_Master__c
                                                           WHERE  Address_Type__c =:AddressType
                                                           AND Product__c =:Product AND Customer_Type__c =:customerType WITH SECURITY_ENFORCED];
            System.debug('productMetadataList-->' +productMetadataList);
            if(productMetadataList.isEmpty()){
                productMetadataList = [SELECT id,Address_Type__c,Product__c,Residence_Status__c ,Residence_Type__c
                                                           FROM Generic_Master__c
                                                           WHERE  Address_Type__c =:AddressType
                                                           AND Product__c =:Product WITH SECURITY_ENFORCED];
            }
            System.debug('productMetadataList-->' +productMetadataList);
            
            for(Generic_Master__c prodInstance : productMetadataList){
                if(prodInstance.Residence_status__c!=null && prodInstance.Residence_Type__c!=null){
                    List<String> ResidenceStatusList = prodInstance.Residence_status__c.split(',');
                    System.debug('ResidenceStatusList-->' +ResidenceStatusList);
                    List<String> ResidenceTypeList = prodInstance.Residence_Type__c.split(',');
                    mapOfLocations.put('ResidenceStatus',ResidenceStatusList);
                    mapOfLocations.put('ResidenceType',ResidenceTypeList);
                }
            }
            
            Map<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues( Address__c.Address_Source__c );
            List<String> filteredValuesList = new List<String>();
            
            for(String valueInstance : dependValuesByControlValue.get(AddressType)){
                System.debug('valueInstance-->' +valueInstance);
                if(customerType == 'Non Individual'){
                    if(AddressType =='Current'){
                        if( valueInstance == 'CKYC'){
                            filteredValuesList.add(valueInstance);
                        }
                    } 
                    if(AddressType == 'Office'){
                        if( valueInstance == 'CKYC' || valueInstance == 'GST' || valueInstance == 'CIN' || valueInstance == 'Udyam' ){
                            filteredValuesList.add(valueInstance);
                        }
                    }
                    System.debug('filteredValuesList-->' +filteredValuesList);
                    mapOfLocations.put('AddressTakenFrom',filteredValuesList); 
                }else if(customerType == 'Individual'){
                    if(AddressType == 'Current'){
                        if( valueInstance != 'CKYC'){
                            filteredValuesList.add(valueInstance);
                        }
                    }else if(AddressType == 'Office'){
                        if(  valueInstance != 'CKYC' &&  valueInstance != 'GST' && valueInstance != 'CIN'  ){//&& valueInstance != 'Udyam'
                            filteredValuesList.add(valueInstance);
                        }
                    }else{
                        filteredValuesList.add(valueInstance);
                    }
                    mapOfLocations.put('AddressTakenFrom',filteredValuesList); 
                }else{
                    mapOfLocations.put('AddressTakenFrom',dependValuesByControlValue.get(AddressType));
                }
                
                
            }
            //mapOfLocations.put('AddressTakenFrom',dependValuesByControlValue.get(AddressType));
            mapOfLocations.put('AddressTakenFrom',filteredValuesList);
            
            System.debug('mapOfLocations-->' +dependValuesByControlValue);
        }
        catch(Exception objException) {
            //   Log.error(objException,Log.SeverityType.valueOf('High'));
        }
        return mapOfLocations;
    }
    /*
@description :  Method to get the dependent picklistvalues from dependentField
@param : String AddressType ,String Product
@return :  map<string,List<String>> 
*/
    public static Map<Object,List<String>> getDependentPicklistValues(Schema.sObjectField dependentField){
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        try{
            //Get dependent field result
            Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
            //Get dependent field controlling field 
            Schema.sObjectField controllerField = dependentFieldResult.getController();
            //Check controlling field is not null
            if(controllerField == null){
                return null;
            } 
            //Get controlling field result
            Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
            //Get controlling field picklist values if controlling field is not a checkbox
            List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
            
            //It is used to decode the characters of the validFor fields. 
            String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
            
            for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
                if (entry.isActive()){
                    //The PicklistEntry is serialized and deserialized using the Apex JSON class and it will check to have a 'validFor' field
                    List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                    for (Integer i = 0; i < controllerValues.size(); i++){
                        Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                        Integer bitIndex = i / 6;
                        Integer bitShift = 5 - Math.mod(i, 6 );
                        if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                            continue;
                        } 
                        if (!dependentPicklistValues.containsKey(controllerValue)){
                            dependentPicklistValues.put(controllerValue, new List<String>());
                        }
                        dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                    }
                }
            }
            
        }
        catch(Exception objException) {
            // Log.error(objException,Log.SeverityType.valueOf('High'));
        }
        return dependentPicklistValues;
    }
    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistWrapper(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
    
    public class addressApplicantWrapper{
        @AuraEnabled public List<Address__c> applicantAddressList{get;set;}
        @AuraEnabled public Boolean boolIsAddressInsertionAllowed{get;set;}
        @AuraEnabled public  Set<String> strAddressTypes{get;set;}
        @AuraEnabled public Integer recCount{get;set;}
        @AuraEnabled public Applicant__c objApplicant{get;set;}
        @AuraEnabled public String strCustomerType{get;set;}
        @AuraEnabled public String strResidentialStatus{get;set;}
        @AuraEnabled public String strUdyamAddress{get;set;}
        @AuraEnabled public Set<String> verifiedAddressTakenSet{get;set;}
        @AuraEnabled public String constitutionType{get;set;}
        @AuraEnabled public Boolean addressTakenFromCBS{get;set;} // SFAU-5716
        @AuraEnabled public Boolean isTwoWheeler{get;set;} // SFAU-5716
        public addressApplicantWrapper(){
            objApplicant = new Applicant__c();
            applicantAddressList = new List<Address__c>();
            boolIsAddressInsertionAllowed = true;
            strAddressTypes= new Set<String>();
            verifiedAddressTakenSet = new Set<String>();
        }
    }


    
    
    @AuraEnabled
    public static String calculateDistance(String toPincode, String strApplicantId,String addressType) {
        String respBody;
        try{
            if(toPincode.length()==6){
                
                
                Applicant__c objApplicant = [SELECT Id , Name, Loan__c, Loan__r.Branch_Master__c,
                                             Loan__r.Branch_Master__r.Pincode__r.Name FROM Applicant__c where Id=:strApplicantId  WITH SECURITY_ENFORCED limit 1];
                String fromPincode = objApplicant.Loan__r.Branch_Master__r.Pincode__r.Name;
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Calculate Distance');
                Map<String,Object> reqParam = new Map<String,Object>();
                reqParam.put('fromPincode',fromPincode);
                reqParam.put('toPincode',toPincode);
                String requestBody = AddressComponentIntHandler.generateRequest(reqParam)[0];
                String objectId = '';
                // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
                system.debug('%%'+requestBody);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
                if(String.isNotBlank(respBody)){
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);

                    // Access the "result" Map within the response
                    Map<String, Object> resultMap = (Map<String, Object>) responseMap.get('result');
    
                    // Get the "estDistance" value from the "result" Map
                    String estDistance = (String)resultMap.get('estDistance');
    
                    Address__c addressInstance  = [SELECT id,name,Address_Type__c,Applicant__c,Distance_from_Branch__c ,Source_Type__c
                                                    FROM Address__c 
                                                    WHERE Applicant__c=:strApplicantId 
                                                    AND  Address_Type__c=:addressType
                                                    AND Source_Type__c != 'Cibil'];
    
                    Address__c addressUpdateInstance = new Address__c();
                    addressUpdateInstance.Id = addressInstance.Id;
                    addressUpdateInstance.Distance_from_Branch__c = Decimal.valueof(estDistance);
    
                    update addressUpdateInstance;
                }
               
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return respBody;
    }
    
    @AuraEnabled
    public static List<Location_Master__c> getNegativeAreaMasterRecords(String pincode, String areaName){
        List<Location_Master__c> negativeAreaMasterRecords = new List<Location_Master__c>();
        try {
            negativeAreaMasterRecords = [Select Id, Zip_Code__c, Area_Status__c, Working_Area__c, Area_Name__c FROM Location_Master__c WHERE Zip_Code__c=:pincode AND Area_Name__c=:areaName];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return negativeAreaMasterRecords;
    }

    @AuraEnabled
    public static void getAddressMatchAPI (String applicantId){
      List<Address__c>  addressList =[SELECT id,Name,Distance_from_Branch__c,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,Address_Source__c,Type__c,District__c
                FROM Address__c
                WHERE Applicant__c=:applicantId 
                AND Address_Type__c != null
                AND Source_Type__c != 'Cibil'  WITH SECURITY_ENFORCED];
        System.debug('addressList-->' +addressList);
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> sourceAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();
        List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper> targetAddressList = new List<LOSKarzaAddressMatchIntHandler.AddressRequestWrapper>();

        //For the Source Address and Target Address Wrapper
        for(Address__c addressInstance : addressList){
            if(addressInstance.Address_Type__c == 'Office'){
                LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
                sourceAddressList.add(wrapperinstance);
            }else{
                LOSKarzaAddressMatchIntHandler.AddressRequestWrapper wrapperinstance = LOSKarzaAddressMatchController.createAddressWrapper(addressInstance);
                targetAddressList.add(wrapperinstance);
            }
        }
        String source ='RCOIdentification';
        String response = LOSKarzaAddressMatchController.validateAddressMatch(sourceAddressList,targetAddressList,applicantId,source,'');
        System.debug('sourceAddressList-->' +sourceAddressList);
        System.debug('targetAddressList-->' +targetAddressList);

    }

    @AuraEnabled( cacheable = true )
    public static Applicant__c getRiskCategoryBasedOnRiskIdentification(Applicant__c draftApplicantRecord, String fieldApi){
        Applicant__c applicantRecord = [ SELECT Id, Type_Of_Employment__c, High_Risk_Profile__c, Risk_Identification__c, Loan__r.RecordType.Name FROM Applicant__c WHERE Id =: draftApplicantRecord.Id WITH SECURITY_ENFORCED ];
        applicantRecord.put(fieldApi, draftApplicantRecord.get(fieldApi));

        //:TODO - can single field be used to capture Risk Category
        String riskCategory = Utility.getApplicantRiskCategoryBy(applicantRecord);
        applicantRecord.X2W_Risk_Category__c = riskCategory;
        applicantRecord.X4W_Risk_Category__c = riskCategory;
        return applicantRecord;
    }

    private static final Map<String, String> DOCUMENTNAME_VALIDATIONNAMEMAP = new Map<String, String>{
        'Voter ID Card' => 'Voter ID', 
        'Aadhaar Card' => 'Aadhar card',
        'Driving Licence' => 'Driving License',
        'Passport' => 'Passport'
        
    };
    @AuraEnabled
    public static List<String> getValidTakenFromValues(String applicantId){
        try {
            List<String> validAddressNames = new List<String>();
            List<Document_Checklist__c> docCheckLists = [SELECT Id, Document_Verification_Status__c, Document_Master__r.Document_Name__c,
                                                         Applicant__r.KYC_Status__c, Applicant__r.KYC_Type__c, Applicant__r.NREGA__c, Applicant__r.NPR__c
                                                         FROM Document_Checklist__c WHERE Applicant__c=:applicantId
                                                         AND Document_Master__r.Document_Name__c IN:DOCUMENTNAME_VALIDATIONNAMEMAP.keySet()
                                                        ];
            for(Document_Checklist__c docRec : docCheckLists){
                if(docRec.Document_Verification_Status__c == 'Verified'){
                    validAddressNames.add(docRec.Document_Master__r.Document_Name__c);
                }
                if(docRec.Applicant__r.KYC_Status__c=='Complete' && docRec.Applicant__r.KYC_Type__c=='Aadhaar - Physical Document' && docRec.Document_Master__r.Document_Name__c=='Aadhaar Card'){
                    validAddressNames.add(docRec.Document_Master__r.Document_Name__c);
                }
                if(String.isNotBlank(docRec.Applicant__r.NREGA__c)){
                    validAddressNames.add('NREGA');
                }
                if(String.isNotBlank(docRec.Applicant__r.NPR__c)){
                    validAddressNames.add('NPR');
                }
                /*else if(docRec.Applicant__r.KYC_Status__c=='Pending' && docRec.Applicant__r.KYC_Type__c=='Aadhaar - Physical Document'){
                    validAddressNames.add(docRec.Document_Master__r.Document_Name__c);
                }*/
            }
            return validAddressNames;
            
        } catch (Exception e) {
            return null;
            //throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled
    public static void sendDeemedNotification(String loanId){
        try {
            NotificationHandler.sendNotification('Deemed KYC',loanId,'');
        } catch (Exception e) {
           System.debug('exception-->' +e);
        }
    }

    //SFAU-4295
    @AuraEnabled
    public static Applicant__c getLoanApplicationDetails(String applicantId){
        try {
            List<Applicant__c> applicants = [SELECT Id, Loan__c,Loan__r.Stage__c, Loan__r.OPS_KYC_Action__c, Loan__r.Original_Vehicle_Usage__c, Loan__r.RecordType.DeveloperName, RecordType.DeveloperName FROM Applicant__c WHERE Id=:applicantId];
            if(applicants!=null && applicants.size()>0){
                return applicants[0];
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //R2-39
    @AuraEnabled
    public static String getCVDocumentValidation(Id loanId){
        try {
            List<Loan_Application__c> loanApp = [SELECT Id, Product__c, Collateral_Type__c FROM Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED];
            List<String> cvProducts = new List<String>{'10101','10102','10103','10104','10105','10106'};
            List<String> cvCollateralTypes = new List<String>{'10105','10106','10107'};
            if(cvProducts.contains(loanApp[0].Product__c) &&  cvCollateralTypes.contains(loanApp[0].Collateral_Type__c)){
                return 'No Co-applicant and Guarantor required if you provide Owned House Proof of the Current Address in the Name of Applicant';
            }else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //R2-37
    @AuraEnabled
    public static Address__c getLandAddressDetails(String applicantId){
        try {
            List<Address__c> landAddresses = [SELECT Id, State__c, District__c, Taluka__c, Village__c, Khata_Khasara_Survey_Number__c,
                Pincode__c, Land_mark__c, Survey_Number__c, Survey_Number__r.State__c, Survey_Number__r.District__c,
                Survey_Number__r.Tehsil__c, Survey_Number__r.Village__c, Survey_Number__r.Survey_Number__c,Same_As__c
                FROM Address__c WHERE Applicant__c=:applicantId AND Address_Type__c='Land'
                WITH SECURITY_ENFORCED Order By CreatedDate Desc];
            if(!landAddresses.isEmpty()){
                return landAddresses[0];
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AddressWrapper getCopyToLandAddressDetails(String applicantId, String type){
        AddressWrapper wrapper = new AddressWrapper();
        try {
            List<Address__c> addresses = [SELECT Id, State__c, District__c, Taluka__c, Village__c, Khata_Khasara_Survey_Number__c,
                Pincode__c, Land_mark__c, Survey_Number__c, Survey_Number__r.State__c, Survey_Number__r.District__c,
                Survey_Number__r.Tehsil__c, Survey_Number__r.Village__c, Survey_Number__r.Survey_Number__c
                FROM Address__c WHERE Applicant__c=:applicantId AND Address_Type__c=:type AND Source_Type__c=null
                WITH SECURITY_ENFORCED Order By CreatedDate Desc];
            if(!addresses.isEmpty()){
                wrapper = new AddressWrapper();
                Address__c address = addresses[0];
                wrapper.pincode = address.Pincode__c;
                wrapper.landmark = address.Land_mark__c;
                List<Village_Master__c> states = [SELECT Id, Name FROM Village_Master__c WHERE Name LIKE :'%'+address.State__c+'%' AND RecordType.DeveloperName='State' WITH SECURITY_ENFORCED];
                if(!states.isEmpty()){
                    
                    Village_Master__c state = states[0];
                    wrapper.stateId = state.Id;
                    wrapper.state = state.Name;
                    List<Village_Master__c> districts = [SELECT Id, Name FROM Village_Master__c WHERE Name LIKE :'%'+address.District__c+'%' AND State__c=:state.Id AND RecordType.DeveloperName='District' WITH SECURITY_ENFORCED];
                    if(!districts.isEmpty()){
                        Village_Master__c district = districts[0];
                        wrapper.districtId = district.Id;
                        wrapper.district = district.Name;
                        List<Village_Master__c> tehsils = [SELECT Id, Name FROM Village_Master__c WHERE Name LIKE :'%'+address.Taluka__c+'%' AND State__c=:state.Id AND District__c=:district.Id AND RecordType.DeveloperName='Tehsil' WITH SECURITY_ENFORCED];
                        if(!tehsils.isEmpty()){
                            Village_Master__c tehsil = tehsils[0];
                            wrapper.tehsilId = tehsil.Id;
                            wrapper.tehsil = tehsil.Name;    
                        }
                    }
                }
                
            }
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class AddressWrapper{
        @AuraEnabled public String stateId;
        @AuraEnabled public String state;
        @AuraEnabled public String districtId;
        @AuraEnabled public String district;
        @AuraEnabled public String tehsilId;
        @AuraEnabled public String tehsil;
        @AuraEnabled public String pincode;
        @AuraEnabled public String landmark;
    }

}