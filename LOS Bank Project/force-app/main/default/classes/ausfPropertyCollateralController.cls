public with sharing class ausfPropertyCollateralController {

    /*
    @description :  Method to get the Collateral details from Loan Application record id
    @param :  Id  recordId
    @return : propertyCollateralWrapper
    */
    @AuraEnabled
    public static propertyCollateralWrapper getPropertyCollaterals(Id recId,String collateralType){
        Id existingCollRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        propertyCollateralWrapper wrapperInstance = new propertyCollateralWrapper();
        try{
        List<Collateral__c > collateralList =[SELECT id,FD_Number__c,FD_amount__c,Registration_Number__c,Manual_Collateral__c,Manual_Model__c,Manual_Variant__c,Current_Owner_Name__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,State__c,
                                              City__c,Pincode__c,Manual_Make__c,Estimated_market_value__c,Apportioned_Loan_Amount__c,Additional_collateral_valid_till_date__c,
                                              Collateral_ID__c
                                       FROM Collateral__c
                                       WHERE Loan__c=:recId 
                                       AND recordTypeId =: existingCollRecordTypeId
                                       AND Type_Of_Existing_Collateral__c = 'Manual' AND Collateral_Type__c=:collateralType  WITH SECURITY_ENFORCED];
        wrapperInstance.propertyCollateralList = collateralList;
        wrapperInstance.recCount = collateralList.size();
    }
    catch(Exception objException) {
      //  Log.error(objException,Log.SeverityType.valueOf('High'));
    }

    return wrapperInstance;
        
    }
    
    /*
    @description :  Method to upsert the Collateral details
    @param :  Collateral__c  collateral
    @return : Collateral__c
    */
    @AuraEnabled
    public static Collateral__c  upsertManualCollateral(Collateral__c  collateral){
        List<Collateral__c> collateralList = new List<Collateral__c>();
        Id existingCollRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        List<Collateral__c> upsertCollateralList = new List<Collateral__c>();
        Collateral__c  appObj = new Collateral__c ();
        appObj = collateral;
        appObj.RecordTypeId = existingCollRecordTypeId;
        upsertCollateralList.add(appObj);
        try{
            system.debug('vehicle data is >'+appObj);
            system.debug('vehicle data is >'+appObj.loan__c);
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, upsertCollateralList);
            System.debug('securityDecision '+securityDecision.getRemovedFields());
            upsert securityDecision.getRecords();
        } catch(DmlException objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),null);
        }
        return upsertCollateralList[0];
    }
    
    public class propertyCollateralWrapper{
        @AuraEnabled public List<Collateral__c > propertyCollateralList{get;set;}
        @AuraEnabled public Integer recCount{get;set;}
   
        public propertyCollateralWrapper(){
            propertyCollateralList = new List<Collateral__c >();
            
        }
    }
}