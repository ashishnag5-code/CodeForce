public without sharing class LosLeadCreateWizardController {
    
    /*  Change - Branch Master moved to Account
*  @AuraEnabled(cacheable=true)
public static List<Branch_Master__c> fetchBranchMasterRecord(){

String userBranchCode = [Select Branch_Code__c  From User Where Id = :UserInfo.getUserId()][0].Branch_Code__c;
system.debug('userBranchCode'+userBranchCode);
return [Select Id, Name, Location_Name__c,State__c from Branch_Master__c  where Name =: userBranchCode WITH SECURITY_ENFORCED];

}*/
     @AuraEnabled	
    public static ProductCampaignWrapper getCampaigns(){	
        ProductCampaignWrapper wrapper = new ProductCampaignWrapper();	
        wrapper.campaigns = [SELECT Id, Campaign_Id__c, Campaign_Name__c, Linked_with__c, Applicable_Products_for_Campaign__c FROM Generic_Master__c	
            WHERE RecordType.DeveloperName='Campaign_Master' WITH SECURITY_ENFORCED];	
        wrapper.productDetails = ProductRTMap__mdt.getAll();	
        return wrapper;	
    }	
    public class ProductCampaignWrapper{	
        @AuraEnabled public List<Generic_Master__c> campaigns;	
        @AuraEnabled public Map<String, ProductRTMap__mdt> productDetails;	
    }
    
    @AuraEnabled
    public static Account fetchBranchMasterRecord(String recordTypeName, String sourcingChannel, String product, String vehicleUse, String purchasingCity){
        system.debug('recordTypeName'+recordTypeName);
        String productType = getProductTypeName(product);
        List<Account> lstBranchMaster = new List<Account>();
        String userBranchCode;
        String userDealerCode;
        User usrObj = [Select Branch_Code__c, Dealer_Code__c From User Where Id = :UserInfo.getUserId()][0];
        userBranchCode = usrObj.Branch_Code__c != null ? usrObj.Branch_Code__c : '';
        userDealerCode = usrObj.Dealer_Code__c != null ? usrObj.Dealer_Code__c : '';
        Set<String> setAccountCode = new Set<String>();
        if(recordTypeName == 'Dealer'){
        setAccountCode.addAll(userDealerCode.split(','));
        lstBranchMaster = [Select Id, Name, Account_Name__c, State__r.Account_Name__c from Account where Account_Code__c IN: setAccountCode and Recordtype.DeveloperName =: recordTypeName and Dealer_Class__c =: sourcingChannel and (Product__c =: productType OR Product__c = 'All') and (Vehicle_use__c =: vehicleUse OR Vehicle_use__c = 'All') and Purchase_City__c =: purchasingCity WITH SECURITY_ENFORCED Limit 1];
        }
        else if(recordTypeName == 'Branch'){
        setAccountCode.addAll(userBranchCode.split(','));
        lstBranchMaster = [Select Id, Account_Name__c, State__r.Account_Name__c from Account where Account_Code__c IN: setAccountCode and Recordtype.DeveloperName =: recordTypeName WITH SECURITY_ENFORCED Limit 1];
        }
        system.debug('setAccountCode'+setAccountCode);
        system.debug('lstBranchMaster'+lstBranchMaster);
        if(lstBranchMaster.size()>0){
            return lstBranchMaster[0];
        }
        else{
            return null;
        }
        
    }
    
    //method is used to get the productTypeName from the custom metadata ProductRTMap__mdt
    public static String getProductTypeName(String product){
        String productTypeName = '';
        ProductRTMap__mdt[] prtList = [Select Product__c, Product_Type__c from ProductRTMap__mdt where Product__c  =:  product and Active__c = true];
        if(prtList.size()>0){
            productTypeName = prtList[0].Product_Type__c;
        }
        return productTypeName;
    }
    
    // method is used to create the Loan Application record as Lead stage
    @AuraEnabled()
    public static Id createLeadRecord(Loan_Application__c loanApplication){
        loanApplication.Stage__c = 'Lead';
        loanApplication.Is_Converted_From_Lead__c = true;
        loanApplication.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        if( String.isBlank(loanApplication.Branch_Master__c) && Utility.fetchBranchMasterRecord() != null) {
            loanApplication.Branch_Master__c = Utility.fetchBranchMasterRecord().Id;
        }

        // R2-28 | 10-Oct-2023 - Commercial leads to be checked for duplicate
        loanApplication.Is_Duplicate__c = LeadDedupeController.validateLeadDedupe( loanApplication );

        //:TODO - R2-12 - Tractor leads( created under Other - Home loan / Credit Card ) has to be pushed to external CRM System
        ProductRTMap__mdt productType = ProductRTMap__mdt.getInstance('A_' + loanApplication.Product__c );
        if( productType.RecordType__c == 'Other'){
            map<String, Object> result = AUSFLeadToCRMInt.validateAndCallCRMApi( loanApplication, true );
            if( result.get('isSuccess') != 'true' ){
                throw new AUSFLeadToCRMInt.LeadToCRMApiException( String.join((String[])result.get('message'), ', ') );
            } else {
                loanApplication.Lead_Id_Ext__c = (String)result?.get('leadIdExt');
            }
        }

        upsert loanApplication;
        if(loanApplication.Follow_Up_Date__c != null){
            createTaskRecord(loanApplication.Follow_Up_Date__c, loanApplication.Follow_Up_Time__c, loanApplication.Id);
        }

        return loanApplication.Id;
    }
    
    // method is used to create the follow up Task
    public static void createTaskRecord(Date followUpDate, Time followUpTime, Id realtedTo){
        List<Task> lsttskObj = new List<Task>();
        Task tskObj = new Task();
        tskObj.Subject = 'Follow up';
        if(followUpDate != null){
            tskObj.ActivityDate = followUpDate;
        }
        if(followUpDate != null && followUpTime != null){
            tskObj.ReminderDateTime = DateTime.valueOf(String.valueOf(followUpDate)+' '+String.valueOf(followUpTime));
            tskObj.IsReminderSet = true;
        }
        tskObj.WhatId = realtedTo;
        //insert tskObj;
        lsttskObj.add(tskObj);
        DatabaseUtility.createRecords(lsttskObj, '');
    }

    /**
     * R2-18
     */
    @AuraEnabled( cacheable = true )
    public static map<String, AUSFVehicleController.PicklistWrapper[]> getVehicleUsageOptions( String product, String collateralType ){
        if( String.isBlank (product)){
            return new map<String, AUSFVehicleController.PicklistWrapper[]>();
        }
        
        AUSFVehicleController.PicklistWrapper[] options = new AUSFVehicleController.PicklistWrapper[0];
        for( Product_vs_Vehicle_Usage__mdt option : Utility.getVehicleUsageOptionsByProduct( product )){
            if( String.isBlank( option.Collateral_Type__c ) || option.Collateral_Type__c.split(';').contains( collateralType ) ){
                options.add(
                    new AUSFVehicleController.PicklistWrapper(
                        option.Vehicle_Usages__c,
                        option.Vehicle_Usages__c
                    )
                );
            }
        }
        return new map<String, AUSFVehicleController.PicklistWrapper[]>{
            'Vehicle_use__c' => options,
            'Collateral_Name__c' => AUSFVehicleController.getCollateralNames( product )?.collateralNames?.get('Collateral_Name__c')
        };
    }


    @AuraEnabled( cacheable = true )
    public static map<String, AUSFVehicleController.PicklistWrapper[]> getCollateralTypeOptions( String product ){
        if( String.isBlank (product)){
            return new map<String, AUSFVehicleController.PicklistWrapper[]>();
        }

        return new map<String, AUSFVehicleController.PicklistWrapper[]>{
            'Collateral_Name__c' => AUSFVehicleController.getCollateralNames( product )?.collateralNames?.get('Collateral_Name__c')
        };
    }
}