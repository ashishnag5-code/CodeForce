/*****
 * Class Name: LoanDetailsController
 * Description: Save Loan Details
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-30-2023          -   Mohit Maheshwari    -   SFAU-5178 - add try catch in updateLoanApp method
 * Nov-07-2023          -   Ajitesh             -   Added validation metadata fetch for Tractor
*/
public without sharing class LoanDetailsController {

    // Metadata Tractor validation literals
    public static final String TRACTOR_VALIDATION_METADATA = 'Tractor';
    public static final String TRACTOR_RECORD_TYPE_DEVELOPER_NAME = 'Tractor';
    // Metadata Tractor validation literals
    
    /**
    * @description Fetching metadata config for Tractor validation
    * @author Ajitesh | 11-07-2023 
    * @return List<Loan_Details_Validation_Trac_Comm__mdt> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Loan_Details_Validation_Trac_Comm__mdt> getTractorValidations(){
        try {
            return [SELECT Collateral_Type__c, IRR_Range__c, Loan_Amount_Range__c, Product_Code_Applicable__c, Stage_Applicable__c, Tenure_Range__c, Error_Message__c FROM Loan_Details_Validation_Trac_Comm__mdt WHERE Component_Type__c = :TRACTOR_VALIDATION_METADATA WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description Fetching schemes for selection for tractor QDE
    * @author Ajitesh | 11-09-2023 
    * @param loanApp 
    * @param app 
    * @param category 
    * @param collCode 
    * @return SchemeWrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static AUSFVehicleController.SchemeWrapper getSchemePickListValues(Loan_Application__c loanApp,Applicant__c app,String category,String collCode) {
        AUSFVehicleController.SchemeWrapper scheme = new AUSFVehicleController.SchemeWrapper();
        Scheme_Master__c schemeMaster = new Scheme_Master__c();
        String typeOfEmp ;
        Map<Id, Scheme_Master__c> schemeMasterMap = new Map<Id, Scheme_Master__c>(); // Saving schemes to map to reuse for ROI, Amount, Tenure
        For(Income_Profiling__mdt  prof: Income_Profiling__mdt.getAll().values()){
            if(prof.Type_of_Employment__c  ==app.Type_Of_Employment__c){
                if(prof.Category__c!=null){
                    typeOfEmp = prof.Category__c;
                }else{
                    typeOfEmp = app.Type_Of_Employment__c;
                }
            }
        }
        Decimal  cibilScore = [SELECT Bureau_Score__c FROM Bureau_Results__c WHERE Applicant__c=:app.Id ORDER BY Bureau_Score_Date__c LIMIT 1]?.Bureau_Score__c;  
        if(cibilScore >= 0 && cibilScore <= 300){
            cibilScore = -1;
        }
        Map<string,List<AUSFVehicleController.PicklistWrapper>>  schemePickListValues = new  Map<string,List<AUSFVehicleController.PicklistWrapper>>();
        Map<String,Scheme_Master__c> mapOfLocationSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        Map<String,Scheme_Master__c> mapOfDealerSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        Map<String,Scheme_Master__c> mapOfMakeModelSepcificSchemVsRecord = new Map<String,Scheme_Master__c >();
        try{
            String loanType =AUSFVehicleController.getScreenType(AUSFVehicleHelper.getPicklistLabel(loanApp.Product__c),true);
            String typeOfCustomer = app.Existing_Customer__c=='Yes'?'ETB':'NTB';
            String custType = loanApp.Customer_Type__c=='Individual'?'I':'NI';
            schemePickListValues.put('Scheme',new List<AUSFVehicleController.PicklistWrapper>());
            Set<String> myset = new Set<String>();//AND Scheme__c='Normal'
            String query = 'SELECT Scheme_Name__c,MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c,Is_Location_General_Scheme__c,Is_Make_model_Scheme__c,Is_Dealer_Scheme__c,Scheme_Code__c FROM Scheme_Master__c WHERE Vehicle_Usage__c =:loanApp.Vehicle_use__c AND Vehicle_category__c=:coll.Vehicle_Category__c AND (Type_of_loan__c=:typeOfLoan OR Type_of_loan__c=:loanType) AND  Profile__c=:app.Customer_Grade__c AND Customer_Type__c=:loanApp.Customer_Type__c AND Type_of_Customer__c=:typeofCustomer AND (Type_of_employment__c=:app.Type_Of_Employment__c OR Type_of_employment__c=:typeOfLoan) AND Is_InActive__c =false';            
            String actualQuery =String.escapeSingleQuotes(query);
            for(Scheme_Master__c obj:[SELECT Vehicle_Usage__c,Collateral__c,Type_of_employment__c,Type_of_Customer__c,Customer_Type__c,Type_of_loan__c,Profile__c,Vehicle_category__c,Scheme_Name__c,MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c,Is_Location_General_Scheme__c,Is_Make_model_Scheme__c,Is_Dealer_Scheme__c,Scheme_Code__c, Land_holding_in_acres_greater_than__c
                                      FROM Scheme_Master__c WHERE Vehicle_Usage__c!=null AND Type_of_employment__c!=null AND Type_of_Customer__c!=null AND Customer_Type__c!=null 
                                      AND Type_of_loan__c!=null AND Profile__c!=null AND Vehicle_category__c!=null AND Is_InActive__c =false AND ((CIBIL_Min__c<=:cibilScore AND CIBIL_Max__c>=:cibilScore) OR Include__c=:cibilScore)]){
                if(obj!=null && ((loanApp.Net_Land_Holding_in_Acre__c == null || loanApp.Net_Land_Holding_in_Acre__c == 0 ) || (loanApp.Net_Land_Holding_in_Acre__c != null && obj.Land_holding_in_acres_greater_than__c !=null &&  obj.Land_holding_in_acres_greater_than__c <= loanApp.Net_Land_Holding_in_Acre__c))){
                    schemeMasterMap.put(obj.Id, obj); // Saving schemes to map to reuse for ROI, Amount, Tenure
                    List<String> vehicleUsage = obj.Vehicle_Usage__c.split(';');
                    List<String> vehicleCategory = obj.Vehicle_category__c.split(';');
                    List<String> typeOfLoan = obj.Type_of_loan__c.split(';');
                    List<String> profileValue = obj.Profile__c.split(';');
                    List<String> customerType = obj.Customer_Type__c.split(';');
                    List<String> typeOfEmployment = obj.Type_of_employment__c.split(';');
                    List<String> typeOfCustomerList = obj.Type_of_Customer__c.split(';');
                    List<String> typeOfCollateral = obj.Collateral__c.split(';');
                    
                        if(vehicleUsage.contains(loanApp.Vehicle_use__c) && vehicleCategory.contains(category) && typeOfLoan.contains(loanType) && profileValue.contains(loanApp.Customer_Grade__c) && customerType.contains(custType) && typeOfEmployment.contains(typeOfEmp) && typeOfCustomerList.contains(typeofCustomer) && typeOfCollateral.contains(collCode) ){
                            if(obj.Is_Location_General_Scheme__c=='False' && obj.Is_Make_model_Scheme__c=='False' && obj.Is_Dealer_Scheme__c=='False'){
                                if(obj.Scheme_Name__c!=null){
                                    if (myset.add(obj.Scheme_Name__c)) {
                                        schemeMaster =obj;
                                        schemePickListValues.get('Scheme').add(new AUSFVehicleController.PicklistWrapper(obj.Scheme_Name__c,obj.Id)) ;
                                    }
                                }
                            }else{
                                if(obj.Is_Location_General_Scheme__c=='True'){
                                    mapOfLocationSepcificSchemVsRecord.put(obj.Id ,obj);
                                }
                                if(obj.Is_Make_model_Scheme__c=='True'){
                                    //mapOfDealerSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                    mapOfMakeModelSepcificSchemVsRecord.put(obj.Id ,obj);
                                }
                                if(obj.Is_Dealer_Scheme__c=='True'){
                                    //mapOfMakeModelSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                    mapOfDealerSepcificSchemVsRecord.put(obj.Id ,obj);
                                }
                                /*if(obj.Is_Location_General_Scheme__c=='False' && obj.Is_Make_model_Scheme__c=='False' && obj.Is_Dealer_Scheme__c=='False'){
                                    mapOfMakeModelSepcificSchemVsRecord.put(obj.Scheme_Name__c ,obj);
                                }*/
                            }
                        } 
                    }
                }
                if(!mapOfMakeModelSepcificSchemVsRecord.isEmpty()){
                    schemePickListValues.putAll(AUSFVehicleController.getMasterJunctionMapping(mapOfMakeModelSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));
                }
                if(!mapOfLocationSepcificSchemVsRecord.isEmpty()){
                    schemePickListValues.putAll(AUSFVehicleController.getMasterJunctionMapping(mapOfLocationSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));   
                }
                if(!mapOfDealerSepcificSchemVsRecord.isEmpty()){
                    schemePickListValues.putAll(AUSFVehicleController.getMasterJunctionMapping(mapOfDealerSepcificSchemVsRecord.keyset(),loanApp,schemePickListValues));
                }
                
                                      
            
            if(schemePickListValues.get('Scheme').size()==0){
                for(Scheme_Master__c obj:[SELECT Scheme_Name__c,Id,Vehicle_Usage__c,Collateral__c,Type_of_employment__c,Type_of_Customer__c,Customer_Type__c,Type_of_loan__c,Profile__c,Vehicle_category__c,MAXROI__c,MINROI__c,MAXLOANAMOUNT__c,MINLOANAMOUNT__c,MAXTENURE__c,MINTENURE__c,Is_Location_General_Scheme__c,Is_Make_model_Scheme__c,Is_Dealer_Scheme__c,Scheme_Code__c, Land_holding_in_acres_greater_than__c FROM Scheme_Master__c WHERE Scheme_Name__c='Normal' Limit 1]){//Added additional fields in query as for normal scheme MIN and AX Tenure was not getting fetched - Neha
                    if(obj.Scheme_Name__c!=null){
                        schemeMasterMap.put(obj.Id, obj); // Saving schemes to map to reuse for ROI, Amount, Tenure
                        schemeMaster =obj;
                        schemePickListValues.get('Scheme').add(new AUSFVehicleController.PicklistWrapper(obj.Scheme_Name__c,obj.Id)) ;
                    }
                }
            }
            schemePickListValues.put('fullChargeRecord', new List<AUSFVehicleController.PicklistWrapper>{new AUSFVehicleController.PicklistWrapper('fullChargeRecord',JSON.serialize(schemeMasterMap))}); // For Tractor QDE Scheme fetching
            scheme.schemeValues = schemePickListValues;
            scheme.schemeMaster = schemeMaster; 
            return scheme; 
        }   
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     
    }

    /**
    * @description Update all applicant revist screen in case land details got changed R2-2042
    * @author Ajitesh | 12-06-2023 
    * @param loanId 
    **/
    @AuraEnabled
    public static void updateRevisitScreen(Id loanId){
        try {
            List<Applicant__c> applicants = [SELECT Id, Re_Visit_Screens__c FROM Applicant__c WHERE Loan__c = :loanId WITH SECURITY_ENFORCED];
            for(Applicant__c tempApp : applicants){
                if(tempApp.Re_Visit_Screens__c!=null){
                    Map<String,Boolean> screenVsRevisitTemp = (Map<String,Boolean>) JSON.deserialize(tempApp.Re_Visit_Screens__c, Map<String,Boolean>.class);
                    screenVsRevisitTemp.put('LoanDetails',false);
                    tempApp.Re_Visit_Screens__c = JSON.serialize(screenVsRevisitTemp);
                }
            }
            ApplicantTriggerHandler.byPassApplicantTrigger = true;
            //R2-2394
            if(!applicants.isEmpty() && Schema.sObjectType.Applicant__c.isUpdateable()){
                update applicants;
            }
            //Database.upsert(applicants);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getVisibleFieldsForLoanDetails(String strScreen, String strStage, String strProfile){

        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile);
        return visibleFields;

    }

    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile, String vehicleType){

        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile,vehicleType,'');
        return visibleFields;

    }

    @AuraEnabled
    public static List<Generic_Master__c> getBankMasterRecords(){

        List<Generic_Master__c> bankMasterRecords = [SELECT Id, Bank_Name__c, Bank_Code__c, Net_Banking__c, Debit_Card__c, is_Eligible_for_Emandate__c FROM Generic_Master__c WHERE RecordType.DeveloperName='Bank_Master' WITH SECURITY_ENFORCED];
        return bankMasterRecords;

    }

    @AuraEnabled
    public static List<Bank_Account_Records__c> getBankRecords(Id recordId){

        Applicant__c applicant = [SELECT Id FROM Applicant__c WHERE Loan__c=:recordId AND RecordType.Developername='Primary_Applicant' AND IsInactive__c = false LIMIT 1];
        List<Bank_Account_Records__c> bankAccountRecords = [SELECT Id, Bank_Name__c, Account_Number__c, CASARelationshipDetails__c,Account_Type__c,RecordType.DeveloperName FROM Bank_Account_Records__c WHERE Applicant__c=:applicant.Id AND RecordType.DeveloperName in ('CBS','Cart') AND Account_Type__c='CASA' WITH SECURITY_ENFORCED];
        return bankAccountRecords;

    }

    @AuraEnabled
    public static List<String> getFieldsToBeDisabled(){
        List<String> newList = new List<String>();
        newList.add('Repayment_Account_Number__c');
        newList.add('IFSC_Code__c');
        newList.add('Loan_Amount__c');

        return newList;
        
    }

    @AuraEnabled
    public static RecordDetails getDetails(Id recordId){

        RecordDetails recordDetails = new RecordDetails();
        recordDetails.loanApp = [SELECT Id, Name,  Pre_Approved_Flag__c, ReTrigger_EMI_Schedule__c, Repayment_By__c, Final_Exposure__c, First_EMI_Date__c, Promo_Code__c, Schedule_Name__c, Flat_ROI__c, RecordType.DeveloperName,
        Rate_Chart_Code__c, Schedule_Code__c, Total_Charges__c, Wheels_Exposure__c, Total_Exposure__c, RecordTypeId, BT_Type__c,
        Stage__c, Total_Loan_Amount__c, Type_of_Rate__c, RBP__c, Risk_Base_Pricing__c, Purpose_of_Loan__c, Nature_of_Loan__c, 
        Emi_Frequency__c, Schedule_Type__c, Repayment_By_User__c, Visited_Customer_for_PD__c,
        Disbursement_Category__c, EMI_Date__c, Repayment_Start_Date__c, Repayment_Bank_Name__c, Repayment_Account_Number__c, 
        Repayment_Account_Type__c, Repayment_Mode__c, IFSC_Code__c, SI_Mobile_Number__c, MICR_Code__c,
        Scheme__r.Scheme_Name__c, Loan_Amount__c, Branch_Master__r.Account_Code__c, Tenure__c, Product__c, EMI__c, ROI__c, Dealer_Master__c,  
        Dealer_Master__r.IRR__c, Net_Land_Holding_in_Acre__c, Vehicle_use__c, Customer_Type__c, Collateral_Type__c, Customer_Grade__c,
        (SELECT id, HPN_With_Financiers_Name__c,Current_Owner_Name__c, POS__c, Linked_Account_Number__c, Product__c, 
            Final_Cost__c, Collateral_Search_Results__c, RC_is_on_name_of_Applicant__c, Apportioned_Loan_Amount__c, 
            Other_Funding_Total__c, Collateral_Name__c, Vehicle_Category__c, SVSH_SVOH__c FROM Collaterals__r WHERE RecordType.DeveloperName IN ('Used_Cash_on_Wheels','New') AND 
            Is_Deleted__c=false Order BY CreatedDate DESC), 
        (SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Type_Of_Employment__c, Customer_Grade__c, Existing_Customer__c FROM Applicants__r WHERE  
            RecordType.Developername='Primary_Applicant' AND IsInactive__c=false) 
        FROM Loan_Application__c WHERE Id=:recordId LIMIT 1];
        recordDetails.rangeDetails = [SELECT Product_Id__c,Min_Tenure__c,Min_ROI_Value__c,Min_Loan_Value__c,Max_Tenure__c,Max_ROI_Value__c,Max_Loan_Value__c FROM Product_vs_Range_Mapping__mdt];
        recordDetails.productDetails = [SELECT Product__c, RecordType__c, Sub_Product__c FROM ProductRTMap__mdt];
       // if(recordDetails.loanApp.Stage__c=='QDE'){ // By Kunal - SFAU-5578 
            recordDetails.promocodes = new List<Generic_Master__c>();
            recordDetails.promocodes = [Select Product__c, Id, Promo_Name__c FROM Generic_Master__c WHERE 
            RecordType.DeveloperName='Promo_Code_Master' AND Product__c=:recordDetails.loanApp.product__c];
       // }
       if(recordDetails.loanApp.Stage__c=='QDE'){   
        // Tractor QDE UI updates
        if(recordDetails.loanApp.RecordType.DeveloperName == TRACTOR_RECORD_TYPE_DEVELOPER_NAME){
            Applicant__c applicant = [SELECT Id, (Select State__c from Addresses__r where Address_Type__c='Current' AND (Source_Type__c= null OR Source_Type__c = 'CBS') Order by Createddate desc) FROM Applicant__c WHERE Loan__c=:recordId AND RecordType.Developername='Primary_Applicant' AND isInactive__c=false WITH SECURITY_ENFORCED LIMIT 1];
            recordDetails.stateMappings=new List<State_wise_Mapping__mdt>();
            if(!applicant.Addresses__r.isEmpty()){
                recordDetails.stateMappings = [SELECT State__c, Two_Wheeler_EMI_Date__c, Four_Wheeler_EMI_Date__c, Tractor__c, HCV_LCV_ICV_CE_EMI_Date__c, SCV_CarTaxi_3W_EMI_Date__c FROM State_wise_Mapping__mdt where state__c=:applicant.Addresses__r[0].State__c];//R2-2045 added extra fields in query (CV and CE)
            }

            // For QDE Stage fetch Schedule names to assign from backend
            if(recordDetails.loanApp.Stage__c=='QDE'){
                List<Generic_Master__c> genericMasterRecords = [Select Product__c, Id, Rate_Type__c, Name__c, vpi_or_epi__c, schedule_code__c, 
                interest_frequency__c, RecordType.DeveloperName
                FROM Generic_Master__c WHERE 
                RecordType.DeveloperName in ('EMI_Schedule') AND 
                Product__c=:recordDetails.loanApp.product__c WITH SECURITY_ENFORCED];
                recordDetails.scheduleRecords = new List<Generic_Master__c>();
                for(Generic_Master__c master: genericMasterRecords){
                    recordDetails.scheduleRecords.add(master);
                }
            }
            // For QDE Stage fetch Schedule names to assign from backend
        }
        // Tractor QDE UI updates
        }
        if(recordDetails.loanApp.Stage__c!='QDE'){
            Applicant__c repaymentApplicant=new Applicant__c();
            List<Applicant__c> repaymentApplicants;
            if(recordDetails.loanApp.Repayment_By__c!=null){
                //List<String> name = recordDetails.loanApp.Repayment_By__c.split(' ');
                /*if(name.size() > 1){
                    repaymentApplicants = [SELECT Id FROM Applicant__c WHERE Loan__c=:recordId AND First_Name__c=:name[0] AND Last_Name__c=:name[1] WITH SECURITY_ENFORCED LIMIT 1];
                }else{
                    repaymentApplicants = [SELECT Id FROM Applicant__c WHERE Loan__c=:recordId AND First_Name__c=:name[0] WITH SECURITY_ENFORCED LIMIT 1];
                }  */
                if(recordDetails.loanApp.Repayment_By_User__c!=null){
                    repaymentApplicants = [SELECT Id FROM Applicant__c WHERE Loan__c=:recordId AND Id=:recordDetails.loanApp.Repayment_By_User__c AND IsInactive__c = false WITH SECURITY_ENFORCED LIMIT 1];              
                }
                if(repaymentApplicants!=null && repaymentApplicants.size()>0){
                    repaymentApplicant=repaymentApplicants[0];
                    recordDetails.loanApp.Repayment_By__c = repaymentApplicant.Id;
                }
            }
            else{
                repaymentApplicants = [SELECT Id FROM Applicant__c WHERE Loan__c=:recordId AND RecordType.Developername='Primary_Applicant' AND IsInactive__c = false WITH SECURITY_ENFORCED LIMIT 1];
                if(repaymentApplicants!=null && repaymentApplicants.size()>0){
                    repaymentApplicant=repaymentApplicants[0];
                    recordDetails.loanApp.Repayment_By__c = repaymentApplicant.Id;
                }
            }
            Applicant__c applicant = [SELECT Id, (Select State__c from Addresses__r where Address_Type__c='Current' AND (Source_Type__c= null OR Source_Type__c = 'CBS') Order by Createddate desc) FROM Applicant__c WHERE Loan__c=:recordId AND RecordType.Developername='Primary_Applicant' AND isInactive__c=false WITH SECURITY_ENFORCED LIMIT 1];
            recordDetails.bankAccountRecords = [SELECT Id, Bank_Name__c, Account_Number__c, Account_Type__c FROM Bank_Account_Records__c WHERE Applicant__c=:repaymentApplicant.Id AND RecordType.DeveloperName in ('CBS','Cart') AND Account_Type__c='CASA' WITH SECURITY_ENFORCED];
            recordDetails.stateMappings=new List<State_wise_Mapping__mdt>();
            if(!applicant.Addresses__r.isEmpty()){
            recordDetails.stateMappings = [SELECT State__c,Two_Wheeler_EMI_Date__c,Four_Wheeler_EMI_Date__c, Tractor__c, HCV_LCV_ICV_CE_EMI_Date__c, SCV_CarTaxi_3W_EMI_Date__c FROM State_wise_Mapping__mdt where state__c=:applicant.Addresses__r[0].State__c WITH SECURITY_ENFORCED];//R2-2045 added extra fields in query (CV and CE)
            }
        
        recordDetails.masterBank = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Bank_Master').getRecordTypeId();
            List<Generic_Master__c> genericMasterRecords = [Select Product__c, Id, Rate_Type__c, Name__c, vpi_or_epi__c, schedule_code__c, 
            interest_frequency__c, RecordType.DeveloperName
            FROM Generic_Master__c WHERE 
            RecordType.DeveloperName in ('EMI_Schedule','Rate_Chart_Code') AND 
            Product__c=:recordDetails.loanApp.product__c WITH SECURITY_ENFORCED];
            recordDetails.scheduleRecords = new List<Generic_Master__c>();
            recordDetails.rateChartCodeRecords = new List<Generic_Master__c>();
            for(Generic_Master__c master: genericMasterRecords){
                if(master.RecordType.DeveloperName == 'EMI_Schedule'){
                    recordDetails.scheduleRecords.add(master);
                }
                if(master.RecordType.DeveloperName == 'Rate_Chart_Code'){
                    recordDetails.rateChartCodeRecords.add(master);
                }
            }
            //recordDetails.scheduleRecords = [Select product__c, name__c, vpi_or_epi__c, schedule_code__c, interest_frequency__c from Generic_Master__c where RecordType.DeveloperName='EMI_Schedule' and product__c=:recordDetails.loanApp.product__c WITH SECURITY_ENFORCED];
        }
        recordDetails.typeOfWheeler = AUSFVehicleController.getTypeOfWheeler( recordDetails.loanApp.Product__c);
        //R2-606 - Change this logic to grid based logic in drop 2 for commercial
        recordDetails.isPDMandatory = recordDetails.loanApp.Stage__c == 'PSD' && isTractor(recordDetails.loanApp.Product__c);
        return recordDetails;
    }

    //R2-606
    private static Boolean isTractor(String productCode) {
        return productCode == '10501' || productCode == '10502' || productCode == '10503';
    }

    @TestVisible
    public class RecordDetails{
        @AuraEnabled public Loan_Application__c loanApp{get;set;}
        @AuraEnabled public List<Product_vs_Range_Mapping__mdt> rangeDetails{get;set;}
        @AuraEnabled public List<ProductRTMap__mdt> productDetails{get;set;}
        @AuraEnabled public List<State_wise_Mapping__mdt> stateMappings{get;set;}
        @AuraEnabled public List<Bank_Account_Records__c> bankAccountRecords{get;set;}
        @AuraEnabled public List<Generic_Master__c> scheduleRecords{get;set;}
        @AuraEnabled public List<Generic_Master__c> rateChartCodeRecords{get;set;}
        @AuraEnabled public List<Generic_Master__c> promocodes{get;set;}
        @AuraEnabled public Id masterBank{get;set;}
        @AuraEnabled public AUSFVehicleController.TypeOfWheeler typeOfWheeler;
        @AuraEnabled public Boolean isPDMandatory;
    }

    @AuraEnabled
    public static void markDataInactive(Loan_Application__c loanApp){
        List<SObject> newList = new List<SObject>();
        if(loanApp.Disbursement_Category__c == 'Full'){
            List<Payment__c> tranche = [select id, name, Inactive__c,Disbursement_Amount__c, Partial_Payment_Condition__c, Tranche_Number__c from Payment__c where  RecordType.Developername='Tranche' and Inactive__c=false and loan_application__c=:loanApp.Id WITH SECURITY_ENFORCED];
            if(tranche.size()>0){
                for(Payment__c pay:tranche){
                    pay.Inactive__c=true;
                    newList.add(pay);
                }
            }
        }
        if(loanApp.Schedule_Type__c != 'VPI'){
            List<EMI_Schedule__c> emiSchedule = [select id, isInactive__c,loan_application__c from emi_schedule__c where loan_application__c=:loanApp.Id and isInactive__c=false and RecordType.DeveloperName='VPI' WITH SECURITY_ENFORCED];
            if(emiSchedule.size()>0){
                for(EMI_Schedule__c emi:emiSchedule){
                    emi.isInactive__c=true;
                    newList.add(emi);
                }
            }
        }
        if(newList.size()>0){
            update newList;
        }
    }

    @AuraEnabled
    public static String updateLoanApp(String jsonString){
        system.debug(LoggingLevel.INFO,'jsonstr ' + jsonString);
        Loan_Application__c loanApp = NULL;
        String strMsg = 'success';
        try{
            if(String.isBlank(jsonString)){
                return 'failed: empty json';
            }
            system.debug(LoggingLevel.DEBUG,'jsonStr ' + jsonString);
            loanApp = (Loan_Application__c) JSON.deserialize(jsonString, Loan_Application__c.class);
            //loanApp.Base_Credit_Verification__c = CreditVerification.setCreditBaseVerification(loanApp.Id,'Loan Details',false);
            if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
                update loanApp;
            }
            system.debug(LoggingLevel.DEBUG,'after update ' + loanApp);
            List<Document_Checklist__c> insertDocChecks = new  List<Document_Checklist__c>();
            List<Document_Checklist__c> updateDocChecks = new  List<Document_Checklist__c>();
            List<Document_Checklist__c> docChecklists = [SELECT Id,Active__c FROM Document_Checklist__c Where Document_Master__r.Document_Id__c = 'AUWheels0051' AND Loan_Application__c =: loanApp.Id];
            Document_Checklist__c docCheck = docChecklists.isEmpty() ? new Document_Checklist__c() : docChecklists[0];
            Applicant__c repaymentByRec = new Applicant__c();
            if(loanApp.Repayment_By_User__c != null){
                repaymentByRec = [SELECT Id,RecordType.DeveloperName FROM Applicant__c Where Id =: loanApp.Repayment_By_User__c AND IsInactive__c = false];
            }


            if(repaymentByRec != null && (repaymentByRec.RecordType.DeveloperName == 'Co_Applicant' || repaymentByRec.RecordType.DeveloperName == 'Guarantor') && docChecklists.isEmpty()){
                List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Id__c = 'AUWheels0051']; // Consent Letter for Repayment taken from other than Borrower Account
                if(!docMaster.isEmpty()){
                    //docCheck.Loan__c = loanApp.Id;
                    docCheck.Loan_Application__c = loanApp.Id;
                    docCheck.Document_Master__c = docMaster[0].Id;
                    docCheck.Document_Name__c = docMaster[0].Document_Name__c;
                    docCheck.Category__c = docMaster[0].Document_Category__c;
                    docCheck.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
                    docCheck.Active__c = true;
                    insertDocChecks.add(docCheck);
                }
                }else if( repaymentByRec != null && (repaymentByRec.RecordType.DeveloperName == 'Co_Applicant' || repaymentByRec.RecordType.DeveloperName == 'Guarantor') ){
                    docCheck.Active__c = true;
                updateDocChecks.add(docCheck);
            }else if(!docChecklists.isEmpty()){
                docCheck.Active__c = false;
                updateDocChecks.add(docCheck);
            }

            List<Document_Checklist__c> docChecklists2 = [SELECT Id,Active__c FROM Document_Checklist__c Where Document_Master__r.Document_Id__c = 'AUWheels0045' AND Loan_Application__c =: loanApp.Id];
            Document_Checklist__c docCheck2 = docChecklists2.isEmpty() ? new Document_Checklist__c() : docChecklists2[0];
            Set<String> repaymentModes = new Set<String>{'NACH without PDC','NACH with PDC','Standing Instructions','Full PDC'};
            if(repaymentModes.contains(loanApp.Repayment_Mode__c) && docChecklists2.isEmpty()){
                List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Id__c = 'AUWheels0045']; 
                if(!docMaster.isEmpty()){
                    //docCheck2.Loan__c = loanApp.Id;
                    docCheck2.Loan_Application__c = loanApp.Id;
                    docCheck2.Document_Master__c = docMaster[0].Id;
                    docCheck2.Document_Name__c = docMaster[0].Document_Name__c;
                    docCheck2.Category__c = docMaster[0].Document_Category__c;
                    docCheck2.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
                    docCheck2.Active__c = true;
                    docCheck2.IsNACH__c = (loanApp.Repayment_Mode__c == 'NACH without PDC' || loanApp.Repayment_Mode__c == 'NACH with PDC' );
                    insertDocChecks.add(docCheck2);

                }
            }else if(repaymentModes.contains(loanApp.Repayment_Mode__c) && !docChecklists2.isEmpty()){
                docCheck2.Active__c = true;
                docCheck2.IsNACH__c = (loanApp.Repayment_Mode__c == 'NACH without PDC' || loanApp.Repayment_Mode__c == 'NACH with PDC' );
                updateDocChecks.add(docCheck2);
            }else if(!docChecklists2.isEmpty()){
                docCheck2.Active__c = false;
                updateDocChecks.add(docCheck2);
            }

                    // E Mandate Logic
                    List<Document_Checklist__c> docChecklists3 = [SELECT Id,Active__c FROM Document_Checklist__c Where Document_Master__r.Document_Id__c = 'AUWheels0136' AND Loan_Application__c =: loanApp.Id];
                    Document_Checklist__c eMandateDocChec = docChecklists3.isEmpty() ? new Document_Checklist__c() : docChecklists3[0];
                    Set<String> repaymentModesEMandate = new Set<String>{'E mandate without PDC','E mandate with PDC'};
                    if(repaymentModesEMandate.contains(loanApp.Repayment_Mode__c) && docChecklists3.isEmpty()){
                        List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Id__c = 'AUWheels0136']; 
                        if(!docMaster.isEmpty()){
                            //docCheck2.Loan__c = loanApp.Id;
                            eMandateDocChec.Loan_Application__c = loanApp.Id;
                            eMandateDocChec.Document_Master__c = docMaster[0].Id;
                            eMandateDocChec.Document_Name__c = docMaster[0].Document_Name__c;
                            eMandateDocChec.Category__c = docMaster[0].Document_Category__c;
                            eMandateDocChec.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
                            eMandateDocChec.Active__c = true;
                            insertDocChecks.add(eMandateDocChec);
            
                        }
                    }else if(repaymentModesEMandate.contains(loanApp.Repayment_Mode__c) && !docChecklists3.isEmpty()){
                        eMandateDocChec.Active__c = true;
                        updateDocChecks.add(eMandateDocChec);
                    }else if(!docChecklists3.isEmpty()){
                        eMandateDocChec.Active__c = false;
                        updateDocChecks.add(eMandateDocChec);
                    }

            insert insertDocChecks;
            upsert updateDocChecks;
        }
        catch (Exception ex) {
            Log.error('Error in LoanDetailsController method updateLoanApp :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApp != NULL ? loanApp.Id : NULL);
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                strMsg = ex.getMessage().substringBetween(',',':');
            }
            else{
                strMsg = ex.getMessage();
            }
        }
        return strMsg;
    }

    @AuraEnabled
    public static List<EMI_Schedule__c> upsertData(List<EMI_Schedule__c> schedule, Id recordId, Integer tenure){
        Decimal totalCount=0;
        system.debug('Tenure '+tenure);
        List<Id> idList=new List<Id>();
        for(EMI_Schedule__c emi:schedule){
            if(String.isBlank(String.valueOf(emi.RecordTypeId))){
                emi.RecordTypeId = Schema.SObjectType.EMI_Schedule__c.getRecordTypeInfosByDeveloperName().get('VPI').getRecordTypeId();
            }
        }
        upsert schedule;
        
        List<EMI_Schedule__c> emiSchedule = [select id, name, stage_number__c, installment_number__c, installment_amount__c, loan_application__c from emi_schedule__c where loan_application__c=:recordId and isInactive__c=false AND RecordType.DeveloperName='VPI' WITH SECURITY_ENFORCED order by installment_number__c];
        return emiSchedule;
    }

    @AuraEnabled
    public static List<EMI_Schedule__c> getEmiDetails(Id recordId){
        List<EMI_Schedule__c> emiList = [select id, name, stage_number__c, installment_number__c, installment_amount__c, loan_application__c from emi_schedule__c where loan_application__c=:recordId and isInactive__c=false AND RecordType.DeveloperName='VPI' WITH SECURITY_ENFORCED order by installment_number__c];
        return emiList;
    }

    @AuraEnabled
    public static List<EMI_Schedule__c> deleteEmiDetails(List<Id> recordIds, Id recordId){
        integer num=1;
        List<EMI_Schedule__c> emiList = [select id, isInactive__c from emi_schedule__c where loan_application__c=:recordId and isInactive__c=false AND RecordType.DeveloperName='VPI' WITH SECURITY_ENFORCED];
        for(EMI_Schedule__c record:emiList){
            if(recordIds.contains(record.Id)){
                record.isInactive__c=true;
            }else{
                record.Stage_Number__c=num;
                num++;
            }
        }
        update emiList;

        
        List<EMI_Schedule__c> emiListUpdated = getEmiDetails(recordId);
        return emiListUpdated;
    }

    public static List<EMI_Schedule__c> updateStageNumber(Id recordId){
        integer num=1;
        List<EMI_Schedule__c> emiList = [select id, isInactive__c from emi_schedule__c where loan_application__c=:recordId and isInactive__c=false AND RecordType.DeveloperName='VPI' WITH SECURITY_ENFORCED];
        for(EMI_Schedule__c record:emiList){
                record.Stage_Number__c=num;
                num++;
        }
        update emiList;
        List<EMI_Schedule__c> emiListUpdated = getEmiDetails(recordId);
        return emiListUpdated;
    }

    @AuraEnabled
    public static Generic_Master__c getBankName(String ifsc){
        try {
            List<IFSC_Master__c> ifscList = [SELECT Id,Bank_Name__c FROM IFSC_Master__c WHERE IFSC__c=:ifsc];
            if(ifscList!=null && ifscList.size()>0){
                IFSC_Master__c obj = ifscList[0];
              //  String bankName = '%'+obj.Bank_Name__c+'%';
                List<Generic_Master__c> genericObj = [SELECT Id,Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c = :obj.Bank_Name__c AND RecordType.Name='Bank Master' LIMIT 1];
                if(genericObj!=null && genericObj.size()>0){
                    return genericObj[0];
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static List<Applicant__c> getApplicants(String loanId){
        List<Applicant__c> appList;
        try {
            appList = [SELECT Id,RecordType.Name,First_Name__c,Last_Name__c,Existing_Customer__c, CIF_No__c FROM Applicant__c WHERE Loan__c =:loanId AND RecordType.DeveloperName in ('Guarantor','Co_Applicant','Primary_Applicant') AND IsInactive__c = false  WITH SECURITY_ENFORCED];
            return appList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Bank_Account_Records__c> getApplicantBankAccountRecords(String applId){
        try {
            List<Bank_Account_Records__c> bankAccountRecords = [SELECT Id, Bank_Name__c, Account_Number__c,Account_Type__c,RecordType.DeveloperName FROM Bank_Account_Records__c WHERE Applicant__c=:applId AND RecordType.DeveloperName in ('CBS','Cart') AND Account_Type__c='CASA' WITH SECURITY_ENFORCED];
            return bankAccountRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getMICRCode(String ifsc){
        try {
            IFSC_Master__c ifscObj = [SELECT Id,Bank_Name__c,MICR_Code__c FROM IFSC_Master__c WHERE IFSC__c=:ifsc LIMIT 1];
            if(ifscObj!=null){
                return ifscObj.MICR_Code__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    //EMI Amount Mismatch - Neha
    public static void updateEMIAmount(Map < Id, sObject > newRecordMap, Map < Id, sObject > oldRecordMap){
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        for(Loan_Application__c loanApp : loanApplicationNewMap.values()){
            if(loanApp.Total_Loan_Amount__c!=loanApplicationOldMap.get(loanApp.Id).Total_Loan_Amount__c){
                if(loanApp.Stage__c == 'QDE'){
                    loanApp.EMI__c = calculateEMIAmount(loanApp);
                }
                loanApp.ReTrigger_EMI_Schedule__c=true;
            }
        }
    }

    public static Decimal calculateEMIAmount(Loan_Application__c loanApp){
        Double appliedROIPerMonth = loanApp.ROI__c!=null?(loanApp.ROI__c/12)/100:0;
        Double tenureMonths = loanApp.Tenure__c!=null?Double.valueOf(loanApp.Tenure__c):0;
        Double totalLoanAmt = loanApp.Total_Loan_Amount__c!=null?Double.valueOf(loanApp.Total_Loan_Amount__c):0;
        Double numerator = totalLoanAmt * appliedROIPerMonth * Math.pow((1+appliedROIPerMonth), tenureMonths);
        Double denominator = Math.pow((1+appliedROIPerMonth), tenureMonths)-1;
        if(numerator == 0 || (denominator <= 0)){
            loanApp.EMI__c = 0;
        }
        else{
            loanApp.EMI__c = (numerator/denominator);
            loanApp.EMI__c = loanApp.EMI__c!=null ? Math.roundToLong(loanApp.EMI__c) : loanApp.EMI__c;
        }
        return loanApp.EMI__c;
    }
    //end

    @AuraEnabled
    public static List<Applicant__c> panVerification(Loan_Application__c loanApp){
        Map<String, Mandatory_Document__mdt> mandDocsMap = new Map<String, Mandatory_Document__mdt>();
        List<Applicant__c> applicantIds = new List<Applicant__c>();
        List<Applicant__c> applicants = [SELECT Id, Total_Monthly_Income_Sum__c, Loan__c, Loan__r.Loan_Amount__c, Loan__r.Final_Exposure__c, Loan__r.Product__c, 
                                         RecordType.DeveloperName, RecordType.Name, Loan__r.RecordType.DeveloperName, First_Name__c, Last_Name__c FROM Applicant__c WHERE Loan__c=:loanApp.Id
                                         AND RecordType.DeveloperName IN ('Primary_Applicant','Co_Applicant','Guarantor') AND IsInactive__c=false
                                         AND (Pan__c=null OR PAN_verification_Status__c!='Verified') WITH SECURITY_ENFORCED];
        //R2-1865
        if(!applicants.isEmpty()){
            List<Applicant__c> primaryApplicants = [SELECT Id, Total_Monthly_Income_Sum__c, Loan__c, Loan__r.Loan_Amount__c, Loan__r.Final_Exposure__c, Loan__r.Product__c, Customer_Type__c
                                            FROM Applicant__c WHERE Loan__c=:loanApp.Id AND recordType.DeveloperName='Primary_Applicant' 
                                            AND IsInactive__c=false WITH SECURITY_ENFORCED];

            List<Mandatory_Document__mdt> mandDocsListMdt = [SELECT Id, Is_PAN_mandatory__c, Is_Form60_mandatory__c, Customer_Type__c, Loan_Amount__c,
                                            Exposure__c, Income__c, Is_PAN_Mand_if_App_NI_CoApp_I__c FROM Mandatory_Document__mdt WHERE 
                                            Product__c = :loanApp.Product__c WITH SECURITY_ENFORCED]; 
            Decimal amount = loanApp.Loan_Amount__c!=null?loanApp.Loan_Amount__c:0;

            for(Mandatory_Document__mdt metadata: mandDocsListMdt){
                if((amount > metadata.Loan_Amount__c)){
                    if(!primaryApplicants.isEmpty() && primaryApplicants[0].Customer_Type__c == 'Non Individual' && metadata.Customer_Type__c=='Co_Applicant' && loanApp.RecordType.DeveloperName=='Tractor'){
                        metadata.Is_PAN_mandatory__c = metadata.Is_PAN_Mand_if_App_NI_CoApp_I__c;
                        mandDocsMap.put(metadata.Customer_Type__c, metadata);
                    }else{
                        mandDocsMap.put(metadata.Customer_Type__c, metadata);
                    }  
                }
            }

            for(Applicant__c appl: applicants){
                if(mandDocsMap.containsKey(appl.RecordType.Name) && mandDocsMap.get(appl.RecordType.Name).Is_PAN_mandatory__c==true){
                    applicantIds.add(appl);
                }
                
            }
        }
        return applicantIds;
    }
}