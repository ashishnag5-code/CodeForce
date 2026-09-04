/**
@ Class Name: Utility
* Created by ngundurao on 08/11/22.
@ Logs:
@   Last Modified Date  -   Last Modified By    -   Bug
@   Aug-23-2023         -   Mohit M.            -   SFAU-4983 - Use Database.Insert for FI Share record
@   Sep-27-2023         -   Mohit M.            -   change in getSObjectDirtyFields mtehod - null check
*   4th Oct-2023        -   Sachin              -   Case sent back from Credit or Pricing will be reassigned to all the Credit / Pricing Hierarchy
*   Oct-18-2023         -   Mohit M.            -   SFAU-5419 - Maruti Lead | In case of Physical Journey case is not moving to next page.         
*   Dec-20-2023         -   Mohit M.            -   SFAU-5622 - "Sorry to interrupt" error on BRE run- Reason:- credit user is inactive
*   Dec-23-2023         -   Mohit M.            -   SFAU-5795 - BRE rerun button is not available on Pricing and credit stage, while system is asking to run BRE.
*/
public without sharing class Utility {
    
    /* Change - Branch Master moved to Account
* public static Branch_Master__c fetchBranchMasterRecord(){
List<Branch_Master__c> lstBranchMaster = new List<Branch_Master__c>();
String userBranchCode = [Select Branch_Code__c  From User Where Id = :UserInfo.getUserId()][0].Branch_Code__c;
lstBranchMaster = [Select Id, Name, Location_Name__c from Branch_Master__c  where Name =: userBranchCode WITH SECURITY_ENFORCED LIMIT 1];
if(!lstBranchMaster.isEmpty()) {
return lstBranchMaster[0];
}
return null; 
}*/


    public static String getRestrictProfile(String userProfileName){
        if(GlobalConstants.userProfile_RestrictProfileMap.containsKey(userProfileName)){
            return GlobalConstants.userProfile_RestrictProfileMap.get(userProfileName);
        }
        else{
            return '';
        }
        
    }
    
    public static Account fetchBranchMasterRecord(){
        List<Account> lstBranchMaster = new List<Account>();
        String userBranchCode = [Select Branch_Code__c  From User Where Id = :UserInfo.getUserId()][0].Branch_Code__c;
        lstBranchMaster = [Select Id, Account_Name__c from Account  where Account_Code__c =: userBranchCode and Recordtype.Name = 'Branch' WITH SECURITY_ENFORCED LIMIT 1];
        if(!lstBranchMaster.isEmpty()) {
            return lstBranchMaster[0];
        }
        return null;
    }

    public static String getTypeOfWheeler(String productCode) {
        String typeOfWhelr = '';
        if (productCode != null) {
            ProductRTMap__mdt prdRTP = ProductRTMap__mdt.getInstance('A_' + productCode);
            if (prdRTP.RecordType__c == 'Four Wheeler') {
                typeOfWhelr = 'Four Wheeler';
            }  else if(prdRTP.RecordType__c == 'Commercial Vehicle'){
                  typeOfWhelr = 'Commercial Vehicle';
            }
            else if(prdRTP.RecordType__c == 'Construction Equipment'){
                  typeOfWhelr = 'Construction Equipment';
            }
            else if(prdRTP.RecordType__c == 'Tractor'){
                  typeOfWhelr = 'Tractor';
            }
            else {
                if (prdRTP.RecordType__c == 'Two Wheeler') {
                    typeOfWhelr = 'Two Wheeler';
                }
            }
           
        }
        return typeOfWhelr;
    } 
    
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile) {
        List<Stage_Profile_Data_Configuration__mdt> lstStageProfileData = [Select Id,Fields__c,Loan_Stage__c,Object__c,
                                                                           Profile__c,Screen__c from Stage_Profile_Data_Configuration__mdt where Screen__c=:strScreen 
                                                                           AND Loan_Stage__c =:strStage AND Profile__c =:strProfile];
        List<String> strFields = new List<String>();
        strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        return strFields;
    }
    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile,  String typeOfWheeler, String customerType) {
        List<Stage_Profile_Data_Configuration__mdt> lstStageProfileData = [Select Id,Fields__c,Loan_Stage__c,Object__c,
                                                                           Profile__c,Screen__c from Stage_Profile_Data_Configuration__mdt where Screen__c=:strScreen 
                                                                           AND Loan_Stage__c =:strStage AND Profile__c =:strProfile AND Vehicle_Type__c=:typeOfWheeler
                                                                           AND Customer_Type__c =: customerType];
        List<String> strFields = new List<String>();
        strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        return strFields;
    }
    

    @AuraEnabled
    public static List<String> getMaterialFields(String strScreen,String strLoanId) {
        List<Loan_Application__c> lstLoanApp = [Select Id,RecordType.Name,Product__c,Stage__c, Collateral_Type__c from Loan_Application__c where Id=:strLoanId limit 1];
        User objUser = [Select Id,Profile.Name from User where Id=:UserInfo.getUserId() limit 1];
        List<String> strFields = new List<String>();
        if(!lstLoanApp.isEmpty()){
            ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+lstLoanApp[0].Product__c);
            if(lstLoanApp[0].RecordType.Name == 'Tractor'){
                strScreen = strScreen + '_Tractor';
            }
            if(lstLoanApp[0].RecordType.Name == 'Construction Equipment'){
                strScreen = strScreen + '_CE';
            }
            if(strScreen.contains('Vehicle') && lstLoanApp[0].RecordType.Name == 'Commercial Vehicle' && productRT.Product_Name__c == 'Car Taxi'){
                strScreen = strScreen + '_CarTaxi';
            }
            else if(lstLoanApp[0].RecordType.Name == 'Commercial Vehicle'){
                strScreen = strScreen + '_CV';
            }
            String strProfile = '%'+objUser.Profile.Name+'%';
            List<Material_Field_Settings__mdt> lstMaterialFields = new List<Material_Field_Settings__mdt>();
            if(lstLoanApp[0].Stage__c == 'Credit'){
                lstMaterialFields = [Select Id,Field_API__c,Can_Credit_Edit__c,Can_PSD_Edit__c,Profile__c,
                                     Product_Type__c,Screen__c from Material_Field_Settings__mdt where Screen__c=:strScreen 
                                     AND Can_Credit_Edit__c='No' AND Profile__c like :strProfile];
            }
            if(lstLoanApp[0].Stage__c == 'PSD'){
                lstMaterialFields = [Select Id,Field_API__c,Can_Credit_Edit__c,Can_PSD_Edit__c,Profile__c,
                                     Product_Type__c,Screen__c from Material_Field_Settings__mdt where Screen__c=:strScreen 
                                     AND Can_PSD_Edit__c='No' AND Profile__c like :strProfile];
            }
            if(!lstMaterialFields.isEmpty()){
                for(Material_Field_Settings__mdt objMaterial : lstMaterialFields){
                    strFields.add(objMaterial.Field_API__c);
                }
            }
        }
        system.debug('%% '+strFields);
        //strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        return strFields;
    }
    
    public static List<String> getVisibleFieldsForCustomer(String strScreen, String strStage, String strProfile, String strCutsomerType) {
        List<Stage_Profile_Data_Configuration__mdt> lstStageProfileData = [Select Id,Fields__c,Loan_Stage__c,Object__c,
                                                                           Profile__c,Screen__c, Customer_Type__c from Stage_Profile_Data_Configuration__mdt where Screen__c=:strScreen 
                                                                           AND Loan_Stage__c =:strStage AND Profile__c =:strProfile AND Customer_Type__c =: strCutsomerType];
        List<String> strFields = new List<String>();
        strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        return strFields;
    }
    
    @AuraEnabled
    public static Generic_Wizard_Flow_Config__mdt getWizardSettings(String WizardName, String StageName) {
        try {
            Generic_Wizard_Flow_Config__mdt objWizardConfig = [Select Id,Flow_Name__c,DeveloperName,MasterLabel,Stage__c,
                                                               Screen_Config_Json_Long__c,(Select Id,DeveloperName,Current_Page__c,Flow_Name__c,Start_Page__c from Generic_Wizard_Current_Page_Configs__r)
                                                               from Generic_Wizard_Flow_Config__mdt 
                                                               where Stage__c=:StageName AND Flow_Name__c=:WizardName limit 1];
            return objWizardConfig;
        } catch(Exception e) {
            return null;
        }
        //return Generic_Wizard_Flow_Config__mdt.getAll();
    }

    @AuraEnabled
    public static list<String> getMandatoryDocsInOptionals(String loanId,String stage){
        
        system.debug('loanId:::'+loanId);
         system.debug('stage:::'+stage);
        
        List<String> docsNames = new list<String>();
        Id applicantId=null;
        Id vehicleId =null;
        Set<Id> applicantIds = new Set<Id>();
        Set<Id> lookupIds = new Set<Id>();
        List<String> bankDocNames = new List<String>{'Bank Statement','ITR','Salary Slip','Form 16','Income statement or Balance sheet'};
            List<Loan_Application__c> loanApps = [SELECT Id,(SELECT Id,Customer_Grade__c,Cart_Statement_Service_Done__c FROM Applicants__r WHERE RecordType.DeveloperName IN: GlobalConstants.APPLICANTS_RECORD_TYPES_ON_DOC AND IsInactive__c != true ),(SELECT Id FROM Collaterals__r), Product__c FROM Loan_Application__c Where Id=: loanId WITH SECURITY_ENFORCED];
        system.debug('loanApps:::'+loanApps);
        if(loanApps !=null && !loanApps.isEmpty()){
            applicantId= loanApps[0].Applicants__r != null && !loanApps[0].Applicants__r.isEmpty() ?  loanApps[0].Applicants__r[0].Id : null;
            
            
            for(Applicant__c app : loanApps[0].Applicants__r){
                applicantIds.add(app.Id);
            } 
        }
        Boolean isIBCustomer=null;
        if(loanApps !=null && !loanApps.isEmpty()){
            vehicleId  = loanApps[0].Collaterals__r != null && !loanApps[0].Collaterals__r.isEmpty()? loanApps[0].Collaterals__r[0].Id : null;
            isIBCustomer = loanApps[0].Applicants__r != null && loanApps[0].Applicants__r[0].Customer_Grade__c == 'IB' ? true : false;
            lookupIds.add(loanId);
        }
        List<Address__c> addresses;
        String sourceDoc ='';
        if(!applicantIds.isEmpty()){
            lookupIds.addAll(applicantIds);
            addresses = [SELECT Id,Address_Source__c FROM Address__c Where Applicant__c IN: applicantIds AND Address_Type__c = 'Current' Order by Createddate desc];
        }
        if(vehicleId != null){
            lookupIds.add(vehicleId);
        }
        
        sourceDoc = addresses != null && !addresses.isEmpty() && String.isNotBlank(addresses[0].Address_Source__c) ? addresses[0].Address_Source__c : '';
        String newSearchText = '%'+sourceDoc+'%';
        Boolean twoWheeler =false;
        if(loanApps!=null && !loanApps.isEmpty())
            twoWheeler = loanApps[0].Product__c.contains('Two Wheeler');
        Map<String,Document_Checklist__c> docIdToDocMap =  new Map<String,Document_Checklist__c>();
        Map<String,Document_Checklist__c> bankDocIdToDocMap =  new Map<String,Document_Checklist__c>();
        
        Set<Id> linkedCheckListIds = new Set<Id>();
        List<Document_Checklist__c> docCheckLists =  new List<Document_Checklist__c>();
        String query = 'SELECT Id,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c FROM Document_Checklist__c Where (';
        if(String.isNotBlank(loanId)){
            query += 'Loan_Application__c = \''+loanId +'\' ';
        }
        if(!applicantIds.isEmpty()){
            String appIds = '(';
            for(Id appId : applicantIds){
                appIds += '\'' + appId + '\',';
            }
            appIds = appIds.subString(0,appIds.length()-1);
            appIds += ')';
            query += 'OR Applicant__c IN' + appIds ;
        }
        if(String.isNotBlank(vehicleId)){
            query += ' OR Collateral__c =\''+vehicleId +'\' ';
        }
        if(twoWheeler){
            query+=') And Document_Master__r.X2W_Stage__c = \''+stage +'\' ';
            //                docCheckLists = [SELECT Id,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c FROM Document_Checklist__c Where (Loan_Application__c =: loanId OR Applicant__c =: applicantId OR Collateral__c =: vehicleId) And (Document_Master__r.Mandatory__c = true OR Document_Master__r.Document_Name__c LIKE: newSearchText) And Document_Master__r.X2W_Stage__c =: stage WITH SECURITY_ENFORCED];
        }else{
            query+=') And Document_Master__r.X4W_Stage__c = \''+stage +'\' AND ';
            //               docCheckLists = [SELECT Id,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c FROM Document_Checklist__c Where (Loan_Application__c =: loanId OR Applicant__c =: applicantId OR Collateral__c =: vehicleId) And (Document_Master__r.Mandatory__c = true OR Document_Master__r.Document_Name__c LIKE: newSearchText) And Document_Master__r.X4W_Stage__c =: stage WITH SECURITY_ENFORCED];
        }
        if(String.isNotBlank(sourceDoc) && isIBCustomer){
            query += '(Document_Master__r.Mandatory__c = true OR Document_Master__r.Document_Name__c LIKE \''+newSearchText +'\' OR Document_Master__r.Document_Name__c IN (\'Bank Statement\', \'ITR\',\'Salary Slip\',\'Pan Card/Form 60\',\'Income statement or Balance sheet\'))';
        }else if(String.isNotBlank(sourceDoc)){
            query += '(Document_Master__r.Mandatory__c = true OR Document_Master__r.Document_Name__c LIKE \''+newSearchText +'\')';
        }else if(isIBCustomer!=null && isIBCustomer){
            query += '(Document_Master__r.Mandatory__c = true OR Document_Master__r.Document_Name__c IN (\'Bank Statement\', \'ITR\',\'Salary Slip\',\'Pan Card/Form 60\',\'Income statement or Balance sheet\'))';
        }else{
            query += '(Document_Master__r.Mandatory__c = true)';
        }
        
        System.debug('Query-->' + query);
        docCheckLists = Database.query(query);
        
        
        if(docCheckLists.isEmpty()){
            
            return new list<String>();
        }
        
        for(Document_Checklist__c docCheck : docCheckLists){
            docIdToDocMap.put(docCheck.Id,docCheck);
            if(isIBCustomer && bankDocNames.contains(docCheck.Document_Master__r.Document_Name__c)){
                bankDocIdToDocMap.put(docCheck.Id,docCheck);
            }
        }
        
        for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docIdToDocMap.keySet() AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE]) {
            linkedCheckListIds.add(each.LinkedEntityId);
        }
        Boolean bankDocPresent = false;
        
        for(Document_Checklist__c docCheck : docCheckLists){
            if(!linkedCheckListIds.contains(docCheck.Id) && !bankDocIdToDocMap.containsKey(docCheck.Id)){
                docsNames.add(docIdToDocMap.get(docCheck.Id).Document_Master__r.Document_Name__c);
            }
        }
        
        return docsNames;
        
    }
    
    
    public static void storeMatchResults(String strMatchType, String strMatchFrom, String strMatchTo, Double dbMatchPercentage, String strApplicantId, Boolean faceMatch) {
        try {
            List<Document_Checklist__c> lstDocChecklisttoUpdate = new List<Document_Checklist__c>();
            List<Document_Checklist__c> lstDocChecklist = [Select Id,Document_Master__c,Document_Master__r.Document_Name__c,Applicant__c from Document_Checklist__c
                                                           where Document_Master__r.Document_Name__c = :strMatchTo and Applicant__c =:strApplicantId WITH SECURITY_ENFORCED];
            if(!lstDocChecklist.isEmpty()){
                Document_Checklist__c objDocChecklist = lstDocChecklist[0];
                objDocChecklist.Match_Type__c = strMatchType;
                objDocChecklist.Match_Percentage__c = dbMatchPercentage;
                objDocChecklist.Match_From__c = strMatchFrom;
                if(strMatchType == 'Face'){
                    objDocChecklist.Face_Match__c = faceMatch;
                }
                lstDocChecklisttoUpdate.add(objDocChecklist);
            }
            DatabaseUtility.updateRecords(lstDocChecklisttoUpdate,'');
        } catch(Exception e) {
            //return null;
        }
    }
    
    public static Id getRecordTypeId(SObjectType entity, String recordTypeName) {
        try {
            return entity
                .getDescribe()
                .getRecordTypeInfosByName()
                .get(recordTypeName)
                .getRecordTypeId();
        } catch(Exception e) {
            return null;
        }
    }

    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId)
    {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }
    
    public static Deviation__c getDeviation(String strExistingDeviationId, String strType, String strDetails, String strLevel, String strLoanId, String strLookupId, Boolean boolIsActive) {
        try {
            Deviation__c objDeviation = new Deviation__c();
            if(!String.isBlank(strExistingDeviationId)){
                objDeviation.Id = strExistingDeviationId;
                
            }else{
                objDeviation.Loan_Application__c = strLoanId;
            }
            objDeviation.Level__c = strLevel;
            objDeviation.Details__c = strDetails;
            objDeviation.Deviation_Type__c = strType;
            objDeviation.Active__c = boolIsActive;
            return objDeviation;
        } catch(Exception e) {
            return null;
        }
        
    }
    @AuraEnabled
    public static void createDeviation(List<Deviation__c> lstDeviation) {
        try {
            DatabaseUtility.upsertRecords(lstDeviation,'');
        } catch(Exception e) {
            //return null;
        }        
    }

       /*
        @description :  Get Applicants based on Applicant Id or Loan Application Id
        @param :  Id 
        @return :  List<Applicant__c>
       */
       @AuraEnabled
       public static List < Applicant__c > getApplicants(Id applicantId) {
           List < Applicant__c > applicantList = new List < Applicant__c > ();
           try {
               applicantList = [SELECT Id,Customer_Name__c, Existing_Customer__c, Bureau_Score__c, First_Name__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, AU_Employee__c, Name_of_Employee_AU__c, Customer_Type__c, Loan__r.EMI__c, Total_Monthly_Income__c,Total_Monthly_Income_Sum__c, Current_Obligation__c, Free_Monthly_Cashflow__c, Total_Loan_Amount__c, FOIR__c, Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName, RecordType.Name,Wheels_Exposure__c,Total_Exposure__c,
                   Relationship_with_applicant__c, KYC_Status__c, CIF_No__c
                   FROM Applicant__c
                   WHERE(Loan__c =: applicantId OR Id =: applicantId)
                   AND RecordType.DeveloperName != 'Additional_Match'
                   AND RecordType.DeveloperName != 'BO'
                   AND RecordType.DeveloperName != 'Nominee' 
                   AND IsInactive__c = false
                   WITH SECURITY_ENFORCED
               ];

           } catch (Exception e) {
               Log.error(e, Log.SeverityType.valueOf('High'), '');
           }
           return applicantList;
       }
       /**
     * Sachin
     * get applications from loan application
     */
    public static Applicant__c[] getApplicantsByLoanId( Id loanId ) {
        return [
            SELECT Id,Customer_Name__c,IsInactive__c, Existing_Customer__c, Bureau_Score__c,
            First_Name__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, AU_Employee__c, Name_of_Employee_AU__c,
            Customer_Type__c, Loan__r.EMI__c, Total_Monthly_Income__c, Current_Obligation__c, Free_Monthly_Cashflow__c, Total_Loan_Amount__c,
            FOIR__c, Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName, RecordType.Name,Wheels_Exposure__c,Total_Exposure__c,
            Relationship_with_applicant__c, KYC_Status__c, CIF_No__c, Applicant_Name__c
            FROM Applicant__c
            WHERE Loan__c =: loanId
            AND RecordType.DeveloperName IN: GlobalConstants.APPLICANTS_RECORD_TYPES_ON_DOC
            AND IsInactive__c = false
            
        ];
    }

        /**
        * @description 
        * @author Harshit Goyal | Salesforce | 02-01-2023 
        * @param labelString 
        * @return set<string> 
        **/
        public static set<string> splitCustomLabel(String labelString){
            Set<String> setToReturn=new Set<String>();
            String[] arrTest = labelString.split(',');
            setToReturn.addAll(arrTest);
            return setToReturn;
        }


        @AuraEnabled
        public static Result checkUploadedDocs(Id loanId,String stage){
            
            Result res = new Result();
            Set<Id> lookupIds = new Set<Id>();
            set<Id> NIAppIds = new set<Id>();
        
        list<Address__c> permAddress = new list<Address__c>();
        
            //Added by naga for multiple collateral issue.
            Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
            Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();  
            Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
            List<String> bankDocNames = new List<String>{'Bank Statement','ITR','Salary Slip','Form 16','Income statement or Balance sheet'};
            List<Loan_Application__c> loanApps = [SELECT Id,recordtype.name,Customer_Type__c,Repayment_Mode__c,Dealer_Master__c, Dealer_Master__r.Dealer_Class__c, (SELECT Id,RecordType.Name, RecordType.DeveloperName,Cart_Statement_Service_Done__c,First_Name__c,Last_Name__c,Customer_Type__c,Customer_Grade__c,CBS_Status__c,Existing_Customer__c FROM Applicants__r WHERE RecordType.DeveloperName IN: GlobalConstants.APPLICANTS_RECORD_TYPES_ON_DOC AND IsInactive__c != true),
            (SELECT Id,Vehicle_Delivery__c ,LTV_Enhancer__c,HPN_With_Financiers_Name__c,Registration_City__c,Customer_equity__c,Vehicle_Usage__c,Original_Vehicle_Usage__c FROM Collaterals__r Where Is_Deleted__c != true AND recordTypeId IN: colRecordTypeIds ), toLabel(Product__c) FROM Loan_Application__c Where Id=: loanId];
            Boolean paymentModeEmandate = loanApps[0].Repayment_Mode__c == 'E mandate without PDC' || loanApps[0].Repayment_Mode__c == 'E mandate with PDC';
            Id applicantId = loanApps[0].Applicants__r != null && !loanApps[0].Applicants__r.isEmpty() ?  loanApps[0].Applicants__r[0].Id : null;
            Map<Id,Applicant__c> applicantIds = new Map<Id,Applicant__c>();
            Map<Id,Address__c> appIdToAddress = new Map<Id,Address__c>();
            List<Payment__c> paymentsToCustomer = [SELECT Id FROM Payment__c Where RecordType.DeveloperName = 'Payment_Favouring' AND Inactive__c = false AND Payment_Recipient__c = 'Customer' AND Loan_Application__c =: loanId ];
            Boolean isAgriDocMandatory = false;
            id primaryApplicantId;
            for(Applicant__c app : loanApps[0].Applicants__r){
                if(app.RecordType.DeveloperName == GlobalConstants.APPLICANT_RECORD_TYPE){
                    primaryApplicantId = app.Id;
                }
                applicantIds.put(app.Id,app);
                if(app.Customer_Type__c=='non individual')
                    NIAppIds.add(app.Id);
            } 
            if(primaryApplicantId != null){
                List<Applicant_Financials_Details__c> appFinancials = [SELECT Id FROM Applicant_Financials_Details__c Where RecordType.DeveloperName = 'Financial_Parent' AND isActive__c = true AND Type_Of_Employment__c = 'Farmer' AND Applicant__c =: primaryApplicantId]; 
                isAgriDocMandatory = appFinancials.IsEmpty() ? false : true;    
            }

    
            Id vehicleId  = loanApps[0].Collaterals__r != null && !loanApps[0].Collaterals__r.isEmpty()? loanApps[0].Collaterals__r[0].Id : null;
            Collateral__c vehicle = loanApps[0].Collaterals__r != null && !loanApps[0].Collaterals__r.isEmpty() ? loanApps[0].Collaterals__r[0] : null;
            Boolean caseDeferral = vehicle != null && String.isNotBlank(vehicle.HPN_With_Financiers_Name__c) && vehicle.HPN_With_Financiers_Name__c?.containsIgnoreCase('AU') ? true : false;
    
            lookupIds.add(loanId);
            List<Address__c> addresses = new List<Address__c>();
            if(!applicantIds.keySet().isEmpty()){
                lookupIds.addAll(applicantIds.keySet());
                addresses = [SELECT Id,Address_Source__c,Applicant__c FROM Address__c Where Applicant__c IN: applicantIds.keySet() AND Address_Type__c = 'Current'  Order by Createddate desc];
            }
            if(vehicleId != null){
                lookupIds.add(vehicleId);
            }
    
            for(Address__c add : addresses){
                appIdToAddress.put(add.Applicant__c,add);
            }
            Boolean twoWheeler=false;
            if(loanApps[0].Product__c!=null){
                   twoWheeler = loanApps[0].Product__c.contains('Two Wheeler');
            }
            Map<String,Document_Checklist__c> docIdToDocMap =  new Map<String,Document_Checklist__c>();
            Map<String,Document_Checklist__c> bankDocIdToDocMap =  new Map<String,Document_Checklist__c>();
    
            Set<Id> linkedCheckListIds = new Set<Id>();
            List<Document_Checklist__c> docCheckLists =  new List<Document_Checklist__c>();
            String query = 'SELECT Id,Document_Master__r.name,Applicant__r.Cart_Statement_Service_Done__c,Document_Master__r.Document_Sub_Category__c,Applicant__r.Existing_Customer__c,Applicant__r.CBS_Status__c, Applicant__c,Loan_Application__c,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c, Applicant__r.Applicant_Name__c FROM Document_Checklist__c Where (';    // Applicant__r.Applicant_Name__c added    
            if(String.isNotBlank(loanId)){
                query += 'Loan_Application__c = \''+loanId +'\' ';
            }
    
            if(!applicantIds.keySet().isEmpty()){
                query += 'OR (';
                Integer i = 0;
                for(Id appId : applicantIds.keySet()){
                    Applicant__c app = applicantIds.get(appId);
                    String customerType  = app.Customer_Type__c == 'Non Individual' ? 'NI' : 'I' ;
                    Boolean isIBCustomer = app.Customer_Grade__c == 'IB';
                    String kycDoc = 'KYC';
                    String sourceDoc = appIdToAddress != null && !appIdToAddress.keySet().isEmpty() && appIdToAddress.get(appId) != null && String.isNotBlank(appIdToAddress.get(appId).Address_Source__c) ? appIdToAddress.get(appId).Address_Source__c : '';
                    String newSearchText = '%'+sourceDoc+'%';
                    
                    if(i > 0){
                        query += ' OR ';
                    }
                
                    if(String.isNotBlank(sourceDoc)){
                      //   query += ' OR Document_Master__r.Document_Name__c LIKE  \''+newSearchText +'\'';
                      query += '(Applicant__c = \''+appId +'\' AND (Document_Master__r.Document_Sub_Category__c Not IN  (\'Income document\', \'KYC\',\'Resident Document\') OR Document_Master__r.Document_Name__c LIKE  \''+newSearchText +'\') AND (  Document_Master__r.Individual_NI__c = \'All\' OR Document_Master__r.Individual_NI__c =  \''+customerType +'\' ' ;

                    }else{
                        query += '(Applicant__c = \''+appId +'\' AND Document_Master__r.Document_Sub_Category__c  Not IN  (\'Income document\', \'KYC\',\'Resident Document\') AND (  Document_Master__r.Individual_NI__c = \'All\' OR Document_Master__r.Individual_NI__c =  \''+customerType +'\' ' ;
                    }
                
    
                    if(isIBCustomer){
                        query += ' OR Document_Master__r.Document_Name__c IN (\'Bank Statement\', \'ITR\',\'Salary Slip\',\'Form 16\',\'Income statement or Balance sheet\')';
                    }
   					system.debug('app:::'+app);
               		system.debug((app.Existing_Customer__c == 'No' && app.Customer_Type__c !='Non Individual') || (app.Existing_Customer__c == 'Yes' && app.CBS_Status__c != GlobalConstants.COMPLETE));
                    if( (app.Existing_Customer__c == 'No' && app.Customer_Type__c !='Non Individual') || (app.Existing_Customer__c == 'Yes' && app.CBS_Status__c != GlobalConstants.COMPLETE && app.Customer_Type__c !='Non Individual')){
                        query += ' OR Document_Master__r.Document_Name__c = \'Customers Signature\'';
                    }
    
                    query += ' ) ) ';
    
                    i++;
                }
                query += ' )';
            }
    
            if(String.isNotBlank(vehicleId)){
                query += ' OR Collateral__c =\''+vehicleId +'\' ';
            }
            if(twoWheeler){
                query+=') And Document_Master__r.X2W_Stage__c = \''+stage +'\' AND ';
            }else{
                query+=') And Document_Master__r.X4W_Stage__c = \''+stage +'\' AND ';
            }
    
            query += '(Document_Master__r.Mandatory__c = true AND Active__c = true)';
      
            System.debug('Query-->' + query);
            docCheckLists = Database.query(query);

            List<Document_Checklist__c> docCheckListRecs = new List<Document_Checklist__c>();

            if(twoWheeler){
                docCheckListRecs = [SELECT Id,Document_Master__r.name,Applicant__r.Cart_Statement_Service_Done__c,Document_Master__r.Document_Sub_Category__c,Applicant__r.Existing_Customer__c,Applicant__r.CBS_Status__c, Applicant__c,Loan_Application__c,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c, Applicant__r.Applicant_Name__c FROM Document_Checklist__c Where Applicant__r.Loan__c =: loanId AND Document_Number__c != null AND Document_Master__r.Document_Name__c IN: GlobalConstants.KYC_DOCS AND Applicant__r.IsInactive__c = false AND Document_Master__r.X2W_Stage__c =: stage];
            }else{
                docCheckListRecs = [SELECT Id,Document_Master__r.name,Applicant__r.Cart_Statement_Service_Done__c,Document_Master__r.Document_Sub_Category__c,Applicant__r.Existing_Customer__c,Applicant__r.CBS_Status__c, Applicant__c,Loan_Application__c,Document_Master__r.Document_Name__c,Document_Master__r.Document_Id__c, Applicant__r.Applicant_Name__c FROM Document_Checklist__c Where Applicant__r.Loan__c =: loanId AND Document_Number__c != null AND Document_Master__r.Document_Name__c IN: GlobalConstants.KYC_DOCS AND Applicant__r.IsInactive__c = false AND Document_Master__r.X4W_Stage__c =: stage];
            }

            docCheckLists.addAll(docCheckListRecs);

            // Using map to remove duplicate records - Start
            Map<Id,Document_Checklist__c> docCheckMap = new Map<Id,Document_Checklist__c>();
            docCheckMap.putAll(docCheckLists);
            docCheckLists = docCheckMap.values();
            // Using map to remove duplicate records - End
    
            Set<String> docIds = new Set<String>();
            if(stage == 'PSD' && caseDeferral && loanApps[0].Dealer_Master__c != null && String.isNotBlank(loanApps[0].Dealer_Master__r.Dealer_Class__c) &&  loanApps[0].Dealer_Master__r.Dealer_Class__c.contains('NO RC LIMIT')){
                docIds.addAll(new Set<String>{'AUWheels0031,AUWheels0032'} );
            }
    
            if(stage == 'PSD' && paymentModeEmandate){ 
                docIds.add('AUWheels0136'); // If Payment mode E-Mandate so E-Mandate will be Mandatory.
            }
    
            if(stage == 'PSD' && vehicle != null && vehicle.Customer_equity__c != null  && vehicle.Customer_equity__c > 0 ){
                docIds.add('AUWheels0008'); // If Customer Equity > 0 so Margin money receipt will be Mandatory.
            }

            if(stage == 'PSD' && !paymentsToCustomer.isEmpty()){
                docIds.add('AUWheels0114'); // If Payment Recipient is customer, then Payment favouring Cheque (Customer) is Mandatory.  
            }

            if(stage == 'PSD' && isAgriDocMandatory){
                docIds.add('AUWheels0039'); // If Applicant Finanical is farmer so Agri Documents will be Mandatory.
            }
    
        if(loanApps.size() >= 0 && loanApps[0]!=null && (loanApps[0].recordtype.name == 'Commercial Vehicle' || loanApps[0].recordtype.name == 'Construction Equipment')){ // For commercial and CE check for udyam certificate enable validation on stamp charge record
            List<Charge__c> stampChargeCheck = [SELECT Udyam_Certificate_Available__c FROM Charge__c WHERE SC_Code__c ='1005' AND Loan_Application__c= :loanApps[0].Id WITH SECURITY_ENFORCED];
            if(stampChargeCheck.size() > 0){
                if(stampChargeCheck[0].Udyam_Certificate_Available__c){
                    docIds.add('AUWheels0038'); // If udyam certificate is enable in the charges screen the document becomes mandatory
                }
            }
        }
        system.debug('loanApps[0].recordtype.name::'+loanApps[0].recordtype.name);
        if(loanApps[0]!=null && loanApps[0].recordtype.name == 'Tractor'){
            list<Applicant_Financials_Details__c> applicantFinlist = [select Size_of_Agri_Land__c from Applicant_Financials_Details__c where applicant__c =:applicantIds.keyset() and Applicant__r.Loan__c =:loanApps[0].Id];
            boolean isLandOwned = false;
            for(Applicant_Financials_Details__c appFin:applicantFinlist){
                if(appFin.Size_of_Agri_Land__c >0)
                    isLandOwned = true;
            }
            system.debug('vehicle.Original_Vehicle_Usage__c::'+vehicle.Original_Vehicle_Usage__c);
            if(stage == 'DDE' && vehicle!=null && vehicle.Original_Vehicle_Usage__c == 'Agri' && !isLandOwned){
                system.debug('vehicle.inside::'+vehicle.Original_Vehicle_Usage__c);
                docIds.add('AUWheels0365');
            }
        }
        if(stage == 'PSD'){
                        permAddress = [SELECT Id,City__c FROM Address__c Where Applicant__c IN: applicantIds.keySet() AND Address_Type__c = 'Permanent' Order by Createddate desc];
            if(permAddress!=null && !permAddress.isEmpty() && vehicle.Registration_City__c != permAddress[0].city__c){
                docIds.add('AUWheels0063');	
            }
                    }
        
        if(loanApps[0]!=null && (loanApps[0].recordtype.name == 'Construction Equipment') && Stage == 'QDE'){
            list<Applicant_Financials_Details__c> applicantFinlist = [select Customer_Grade__c,Sub_Grade__c from Applicant_Financials_Details__c where applicant__c =:applicantIds.keyset() and Applicant__r.Loan__c =:loanApps[0].Id];
            Integer fleetCount = [select count() from fleet__c where loan_application__c =:loanApps[0].id];
           system.debug('fleetCount::'+fleetCount);
            
            for(Applicant_Financials_Details__c appFin:applicantFinlist){
                system.debug('appFin.Customer_Grade__c::'+appFin.Customer_Grade__c);
            system.debug('appFin.appFin.Sub_Grade__c::'+appFin.Sub_Grade__c);
                if(appFin.Customer_Grade__c == 'Contractor' && appFin.Sub_Grade__c=='Small-1' && fleetCount==0){
                    docIds.add('Wheelsdoc0154');
                }
                if(appFin.Customer_Grade__c == 'Mine Owner' && appFin.Sub_Grade__c=='Small-1' && fleetCount==0){
                    docIds.add('Wheelsdoc0155');
                }
                
            }
            
        }
        
        if(loanApps[0]!=null && loanApps[0].recordtype.name == 'Tractor' && Stage == 'DDE'){    
            Map<String, String> mitigationMap = new Map<String, String>();  
          	string[] mitigateValues;
            List<MitigationSettings__mdt> mitigationSettings = [SELECT MasterLabel, Key__c, Value__c FROM MitigationSettings__mdt]; 
            for (MitigationSettings__mdt setting : mitigationSettings) {
                mitigationMap.put(setting.Key__c, setting.Value__c);
            }
            for( Collateral__c vehicleVar :loanApps[0].Collaterals__r){
                if(vehicleVar.LTV_Enhancer__c !=null){
                   mitigateValues = vehicleVar.LTV_Enhancer__c.split(';');
                } 
            }
            if(mitigateValues !=null){
                for(String mitVar : mitigateValues){
                    String docId = mitigationMap.get(mitVar);
                    docIds.add(docId);
                }
            }
            
        }
        
            List<Document_Checklist__c> docCheckList2 = new List<Document_Checklist__c>();
            if(vehicle != null){
                docCheckList2 = [SELECT Id,Applicant__c,Loan_Application__c,Document_Master__r.Document_Sub_Category__c,Document_Master__r.Document_Name__c,
                                 Applicant__r.Existing_Customer__c, Applicant__r.CBS_Status__c, Applicant__r.Cart_Statement_Service_Done__c, Document_Master__r.Name,
                                 Document_Master__r.Document_Id__c, Applicant__r.Applicant_Name__c FROM Document_Checklist__c WHERE Document_Master__r.Document_Id__c IN: docIds AND Active__c = true AND (Loan_Application__c =: loanApps[0].Id OR (Collateral__c != null AND Collateral__c =: vehicle.Id))];
            }else{
                docCheckList2 = [SELECT Id,Applicant__c,Loan_Application__c,Document_Master__r.Document_Sub_Category__c,Document_Master__r.Document_Name__c,
                                 Applicant__r.Existing_Customer__c, Applicant__r.CBS_Status__c, Applicant__r.Cart_Statement_Service_Done__c, Document_Master__r.Name,
                                 Document_Master__r.Document_Id__c, Applicant__r.Applicant_Name__c FROM Document_Checklist__c WHERE Document_Master__r.Document_Id__c IN: docIds AND Active__c = true AND (Loan_Application__c =: loanApps[0].Id OR (Collateral__c != null))];
            }
            
            if(!docCheckList2.isEmpty()){
                docCheckLists.addAll(docCheckList2);
            }
            
            System.debug('docCheckLists::'+docCheckLists);
            res.messages = new List<String>();
            if(docCheckLists.isEmpty()){
                res.status = 'Success';
                res.messages.add('All Documents are Recieved');
                return res;
            }
    
            Map<Id,Applicant__c> ibApplicants = new Map<Id,Applicant__c>();
            for(Document_Checklist__c docCheck : docCheckLists){
                docIdToDocMap.put(docCheck.Id,docCheck);
                                Boolean isIBCustomer = docCheck.Applicant__c != null &&  applicantIds.get(docCheck.Applicant__c) != null && applicantIds.get(docCheck.Applicant__c).Customer_Grade__c == 'IB';
                if(isIBCustomer && bankDocNames.contains(docCheck.Document_Master__r.Document_Name__c)){
                    bankDocIdToDocMap.put(docCheck.Id,docCheck);
                    ibApplicants.put(docCheck.Applicant__c,applicantIds.get(docCheck.Applicant__c));
                }
            }
    
            for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docIdToDocMap.keySet() AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED]) {
                linkedCheckListIds.add(each.LinkedEntityId);
            }
           Boolean bankDocPresent = false;
           boolean skipAnnexure = hasUploadedTwoKYCRecords(NIAppIds);
            for(Document_Checklist__c docCheck : docCheckLists){
                if(!linkedCheckListIds.contains(docCheck.Id) && !bankDocIdToDocMap.containsKey(docCheck.Id)){
                    if(skipAnnexure && docCheck.Document_Master__r.name == 'AUWheels0088')
                        continue;
                if((stage == 'DDE' && vehicle != null && vehicle.Vehicle_Delivery__c == 'NO') && (docCheck.Document_Master__r.name == 'AUWheels0011' || docCheck.Document_Master__r.name == 'AUWheels0135'))
                   continue;
                    if((docCheck.Document_Master__r.Document_Sub_Category__c == 'KYC' && docCheck.Applicant__c != null && docCheck.Applicant__r.Existing_Customer__c == 'Yes' && docCheck.Applicant__r.CBS_Status__c == GlobalConstants.COMPLETE) || (docCheck.Applicant__r.Cart_Statement_Service_Done__c && docCheck.Document_Master__r.Name=='AUWheels0107')){ //OR condition added for SFAU-4075
                        continue;
                    }
                    if(res.messages.isEmpty()){
                        res.messages.add('Following mandatory documents are missing : ' + docIdToDocMap.get(docCheck.Id).Document_Master__r.Document_Name__c+(String.isNotBlank(docCheck.Applicant__r.Applicant_Name__c)?' - '+docCheck.Applicant__r.Applicant_Name__c:''));
                    }else{
                    res.messages.add(', ' + docIdToDocMap.get(docCheck.Id).Document_Master__r.Document_Name__c+(String.isNotBlank(docCheck.Applicant__r.Applicant_Name__c)?' - '+docCheck.Applicant__r.Applicant_Name__c:''));
                    }
                    res.status = 'error';
                }else if(bankDocIdToDocMap.containsKey(docCheck.Id) && linkedCheckListIds.contains(docCheck.Id)){
                    bankDocPresent = true;
                }
            }
    
    
            if(!bankDocPresent  && !bankDocIdToDocMap.isEmpty() && !ibApplicants.keySet().isEmpty()){
                for(Applicant__c app : ibApplicants.values()){
                    if(!app.Cart_Statement_Service_Done__c){
                        String appName = String.isNotBlank( app.First_Name__c ) ?  app.First_Name__c + ' ' : ' ';
                        appName += String.isNotBlank( app.Last_Name__c ) ?  app.Last_Name__c : '';
                        if(res.messages.isEmpty()){
                            res.messages.add('Atleast one Document is mandatory (Bank Statement,ITR,Salary Slip,Form 16,Income statement or Balance sheet) on Applicant : ' + appName);
                        }else{
                            res.messages.add(', Atleast one Document is mandatory (Bank Statement,ITR,Salary Slip,Form 16,Income statement or Balance sheet) on Applicant : ' + appName);
                        }
                        res.status = 'error';
                    }
                    
                }
                //res.status = 'error';
            }
    
            System.debug('messages-->' + res.messages);
    
            if(res.status == null){
                res.status = 'Success';
                res.messages.add('All Documents are Recieved');
            }
            return res;
    
        }
    
    // Function to check if a user has uploaded two KYC records
    public static Boolean hasUploadedTwoKYCRecords(set<id> appIds) {
        
        if(appIds.size()==0)
            return false;
        
        Integer kycRecordCount = [SELECT COUNT() FROM Document_Checklist__c WHERE Applicant__c  = :appIds AND Document_Master__r.Document_Sub_Category__c = 'KYC' ];

        // Check if the user has uploaded at least two KYC records
        if (kycRecordCount >= 2) {
            return true;
        } else {
            return false;
        }
    }

        public static Map<String,String> getPageNameByDocName(){
            Map<String,String> response = new Map<String,String>();
            for(System_Generated_Documents__mdt record : [SELECT Id,Document_Name__c,VF_Page__c FROM System_Generated_Documents__mdt]){
                response.put(record.Document_Name__c.toUppercase(),record.VF_Page__c);
            }
            return response;
        }

        public class Result{
            @AuraEnabled public String status;
            @AuraEnabled public List<String> messages; 
        }
    
    /***
     * BSR Assignments
     * param1:
     * param2: 
     */     
    public static void createBSRAssignment(List<sObject> loanAppList, Boolean boolIsApprovalReqd){
        Map<String,String> mapOfLoanAppVsLevel = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        List<Loan_Application__c> listOfLoanApplication = new List<Loan_Application__c>();
        List<Id> loanIds = new List<Id>();
        Set<String> listOfBranchIds = new Set<String>();
        for(sObject loanObj: loanAppList	){
            if(loanObj.get('BRE_Decision__c')!=null && (loanObj.get('BRE_Decision__c')=='STP' || loanObj.get('BRE_Decision__c')=='NSTP')){
                loanIds.add((Id)loanObj.get('Id'));
                listOfBranchIds.add((String)loanObj.get('Branch_Master__c'));
                if(loanObj.get('Stage__c')=='Credit' && loanObj.get('BRE_Approval_Level__c')!=null){ 
                    mapOfLoanAppVsLevel.put((String)loanObj.get('Id'),(String)loanObj.get('BRE_Approval_Level__c'));
                }
                listOfLoanApplication.add((Loan_Application__c)loanObj);
            }
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(loanIds);
        system.debug(LoggingLevel.Info,'wrap '+wrap);
        mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        
        listOfAccountTeamMembers = CreditApprovalHandler.getAccountTeamMembers(listOfBranchIds,loanIds,mapOfFieldVsListOfValues,'Credit');
        
        AUSFLoanApplicationAssignmentHelper cs = new AUSFLoanApplicationAssignmentHelper(GlobalConstants.APPROVAL_TYPE_CREDIT, null);
        AUSFLoanApplicationAssignmentHelper.loanAppIdVsKey = mapOfLoanAppVsLevel;
        AUSFLoanApplicationAssignmentHelper.approvalType = GlobalConstants.APPROVAL_TYPE_CREDIT;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = mapOfLoanIdVsCollateralName;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
        AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = mapOfFieldVsListOfValues;
        if(boolIsApprovalReqd){
            AUSFLoanApplicationAssignmentHelper.isSTPwithConditions = true;
            AUSFLoanApplicationAssignmentHelper.breTrigger = true;
        }
        else{
            AUSFLoanApplicationAssignmentHelper.isSTPwithConditions = false;
            AUSFLoanApplicationAssignmentHelper.breTrigger = true;
        } 
        AUSFLoanApplicationAssignmentHelper.mainMethod(listOfAccountTeamMembers,listOfLoanApplication);
    }

   /* @AuraEnabled
    public static void checkMaterialFields(String strScreen,String strLoanId,List<String> lstFieldsAPI) {
        List<Loan_Application__c> lstLoanApp = [Select Id,RecordType.Name,Product__c,Stage__c from Loan_Application__c where Id=:strLoanId limit 1];
        Loan_Application__c objLoanApplication = new Loan_Application__c();
        
        User objUser = [Select Id,Profile.Name from User where Id=:UserInfo.getUserId() limit 1];
        List<String> strFields = new List<String>();
        if(!lstLoanApp.isEmpty()){
            objLoanApplication = lstLoanApp[0];
            String strProfile = '%'+objUser.Profile.Name+'%';
            List<Material_Field_Settings__mdt> lstMaterialFields = new List<Material_Field_Settings__mdt>();
            //if(lstLoanApp[0].Stage__c == 'Credit'){
                lstMaterialFields = [Select Id,Field_API__c,Can_Credit_Edit__c,Can_PSD_Edit__c,Profile__c,BRE_Run_Required__c,
                                     Product_Type__c,Screen__c from Material_Field_Settings__mdt where Screen__c=:strScreen 
                                     AND Field_API__c=:lstFieldsAPI AND (Product_Type__c =: lstLoanApp[0].RecordType.Name OR Product_Type__c = 'ALL' OR Product_Type__c = '') ];
            
            if(!lstMaterialFields.isEmpty()){
                for(Material_Field_Settings__mdt objMaterial : lstMaterialFields){
                    if(objMaterial.BRE_Run_Required__c == 'Yes'){
                        objLoanApplication.BRE_ReRun_Required__c = true;
                    }
                }
            }
        }
        update objLoanApplication;
        system.debug('%% '+strFields);
        //strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        //return strFields;
    }*/
    @AuraEnabled
    public static void checkMaterialFields(String strScreen,String strLoanId,List<String> lstFieldsAPI) {
        Id stLoanId= (Id)strLoanId;
        system.debug('stLoanId '+stLoanId);
        String sObjName = stLoanId.getSObjectType().getDescribe().getName();
        String requiredId;
        system.debug('sObjName '+sObjName);
        if(sObjName == 'Loan_Application__c'){
            requiredId = strLoanId;
        }else if(sObjName == 'Applicant__c'){
            Applicant__c applicant = [SELECT id,Loan__c  FROM Applicant__c WHERE Id =:strLoanId LIMIT 1 ];
            if(applicant!=null){
                requiredId = applicant.Loan__c;
            }
           
        }

        LisT<String> lstStages = new List<String>();
        lstStages.addAll(Label.BRE_ReRun_Stage.split(';'));
        List<Loan_Application__c> lstLoanApp = [Select Id,RecordType.Name,Product__c,Stage__c,BRE_ReRun_Required__c,Collateral_Type__c from Loan_Application__c where Id=:requiredId and BRE_ReRun_Required__c=false limit 1];
        Loan_Application__c objLoanApplication = new Loan_Application__c();
        User objUser = [Select Id,Profile.Name from User where Id=:UserInfo.getUserId() limit 1];
        List<String> strFields = new List<String>();
        if(!lstLoanApp.isEmpty()){
            ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+lstLoanApp[0].Product__c);
            if(lstLoanApp[0].RecordType.Name == 'Tractor'){
                strScreen = strScreen + '_Tractor';
            }
            if(lstLoanApp[0].RecordType.Name == 'Construction Equipment'){
                strScreen = strScreen + '_CE';
            }
            if(strScreen.contains('Vehicle') && lstLoanApp[0].RecordType.Name == 'Commercial Vehicle' && productRT.Product_Name__c == 'Car Taxi'){
                strScreen = strScreen + '_CarTaxi';
            }
            else if(lstLoanApp[0].RecordType.Name == 'Commercial Vehicle'){
                strScreen = strScreen + '_CV';
            }
            system.debug('lstLoanApp[0] '+lstLoanApp[0]);
            objLoanApplication = lstLoanApp[0];
            String strProfile = '%'+objUser.Profile.Name+'%';
            List<Material_Field_Settings__mdt> lstMaterialFields = new List<Material_Field_Settings__mdt>();
            if(!lstStages.isEmpty() && lstStages.contains(lstLoanApp[0].Stage__c)){
                lstMaterialFields = [Select Id,Field_API__c,Can_Credit_Edit__c,Can_PSD_Edit__c,Profile__c,BRE_Run_Required__c,
                                     Product_Type__c,Screen__c from Material_Field_Settings__mdt where Screen__c=:strScreen 
                                     AND Field_API__c=:lstFieldsAPI AND (Product_Type__c =: lstLoanApp[0].RecordType.Name OR Product_Type__c = 'ALL' OR Product_Type__c = '') ];
            }
            /*
            if(lstLoanApp[0].Stage__c == 'PSD'){
                lstMaterialFields = [Select Id,Field_API__c,Can_Credit_Edit__c,Can_PSD_Edit__c,Profile__c,
                                     Product_Type__c,Screen__c from Material_Field_Settings__mdt where Screen__c=:strScreen 
                                     AND Field_API__c=:lstFieldsAPI];
            }*/
            if(!lstMaterialFields.isEmpty()){
                for(Material_Field_Settings__mdt objMaterial : lstMaterialFields){
                    if(objMaterial.BRE_Run_Required__c == 'Yes'){
                        objLoanApplication.BRE_ReRun_Required__c = true;
                    }
                }
            }
            system.debug('objLoanApplication '+objLoanApplication);
        }
        //update objLoanApplication;
        //bug fix - SFAU-3379
        if(objLoanApplication.BRE_ReRun_Required__c==true){
            update objLoanApplication;
        }
        system.debug('%% '+strFields);
        //strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        //return strFields;
    }

    /*
    * @description - validates Live Photo and Customer Signature size - SFAU-5841
    */
    public static Boolean checkCifDocSize(Loan_Application__c loanApplication){
        Map<Id,Document_Checklist__c> docChecks = new Map<Id,Document_Checklist__c> ([SELECT Id,Document_Master__r.Document_Name__c,Applicant__r.Name,Applicant__c FROM Document_Checklist__c Where Applicant__r.Loan__c =: loanApplication.Id AND Applicant__r.IsInactive__c = false AND Applicant__r.RecordTypeId IN: GlobalConstants.APPLICANTS_RECORD_TYPES_IDS AND Document_Master__r.Document_Id__c IN ('AUWheels0089','AUWheels0134')]);
        Map<Id, ContentDocumentLink> contentDocList= new Map<Id,ContentDocumentLink> ([SELECT Id,ContentDocument.LatestPublishedVersion.ContentSize, ContentDocumentId from ContentDocumentLink WHERE 
            LinkedEntityId in :docChecks.keySet()]);
        for(ContentDocumentLink cdl : contentDocList.values()){
            if(cdl.ContentDocument.LatestPublishedVersion.ContentSize >= Integer.valueOf(Label.Photo_Signature_Max_Size)){ // 120Kb
                return true;
            } 
        }    
        return false;
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
    
     //method is used to get the subProductName from the custom metadata ProductRTMap__mdt
    public static String getSubProductName(String product){
        String subProductName = '';
        ProductRTMap__mdt[] prtList = [Select Product__c, Sub_Product__c from ProductRTMap__mdt where Product__c  =:  product and Active__c = true];
        if(prtList.size()>0){
            subProductName = prtList[0].Sub_Product__c;
        }
        return subProductName;
    }
    
    /**
* @param - productCode{String} - Product Code 
*/
    public static String getProductNameByCode( String productCode ){
        return ProductRTMap__mdt.getInstance( 'A_' + productCode )
            ?.Product_Name__c;
    }
    
    /**
     * @date - 30st May 2023
     * @author - Sachin Hooda
     * @description - calculates percentage difference b/w two numbers
     * @param numA - {Decimal} - 1st Number 
     * @param numB - {Decimal} - 2nd Number
     * @return High_Risk_Profile__mdt[] - High Risk Profiles by Vehicle type
     */
    public static Decimal calculatePercentageDiff(Decimal numA, Decimal numB){
        Decimal difference = ( numA - numB ),
            avg = ( numA + numB ) / 2;
        return ( (difference < 0 ? (-1) * difference : difference) / avg ) * 100;
    }

    /**
     * @date - 31st May 2023
     * @author - Sachin Hooda
     * @param applicantRecord - {Applicant__c} - Applicant record with High_Risk_Profile__c, Risk_Identification__c, Type_Of_Employment__c
     * @return High_Risk_Profile__mdt[] - High Risk Profiles by Vehicle type
     */
    public static String getApplicantRiskCategoryBy(Applicant__c applicantRecord){
        String highRiskProfile = applicantRecord.High_risk_Profile__c, 
            vehicleType = applicantRecord.Loan__r?.RecordType.Name;
        High_Risk_Profile__mdt[] riskProfiles = [ SELECT Category__c FROM High_Risk_Profile__mdt WHERE Profile__c =: highRiskProfile AND Vehicle_Type__c =: vehicleType AND Category__c LIKE: (GlobalConstants.TW_RISK_CATEGORY_HRP + '%') ];
        if(highRiskProfile != NULL && !riskProfiles.isEmpty()){
            return riskProfiles[0].Category__c;
        } else if( GlobalConstants.APPLICANT_EMPLOYMENT_TYPE_AGRI.contains( applicantRecord.Type_Of_Employment__c ) ){
            return GlobalConstants.TW_RISK_CATEGORY_AGRI;
        } else if(applicantRecord.Risk_Identification__c){
            return GlobalConstants.TW_RISK_CATEGORY_RCO;
        }
        return GlobalConstants.TW_RISK_CATEGORY_NORMAL;
    }

    /**
     * @date - 31st May 2023
     * @author - Sachin Hooda
     * @param vehicleType - Type of Vehcle - {Two Wheeler | Four Wheeler}
     * @return High_Risk_Profile__mdt[] - High Risk Profiles by Vehicle type
     */
    public static High_Risk_Profile__mdt[] getHighRiskProfilesByVehicleType(String vehicleType){
        return [
            SELECT Profile__c, Vehicle_Type__c, Category__c, Sequence_Order__c
            FROM High_Risk_Profile__mdt
            WHERE Vehicle_Type__c =: vehicleType
            ORDER BY Sequence_Order__c ASC NULLS LAST, Profile__c
        ];
    }

    /**
     * @date - 6th June 2023
     * @author - Sachin Hooda
     * @param SObject - oldRecord - with details from db
     * @param SObject - newRecord - with dirty field values
     * @return String[] - fields that were updated
     */
    public static String[] getSObjectDirtyFields(SOBject oldRecord, SOBject newRecord, String[] fields){
        String[] dirtyFields = new String[0];
        for(String field: fields){
            if(oldRecord != NULL && oldRecord.get(field) != newRecord.get(field) ){
                dirtyFields.add(field);
            }
        }
        return dirtyFields;
    }
    
    /*
    * @description - validates BRE Rerun required status before approving application on Credit
    */
     public static Boolean getCurrentBREStatus(Loan_Application__c loanApplication){
        // SFAU-5795 - Issue for BRE ReRun for Pre-Approved
        BRE_Response__c[] breResponses = [ SELECT Is_Confirmed__c FROM BRE_Response__c WHERE Loan_Application__c =: loanApplication.Id  ORDER BY CreatedDate DESC LIMIT 1 ];
       
        if (loanApplication.Pre_Approved_Flag__c && loanApplication.BRE_Run_for_PreApproved_Offer__c) return true;
        if (loanApplication.BRE_ReRun_Required__c && !loanApplication.Pre_Approved_Flag__c) return true;
        if (loanApplication.BRE_ReRun_Required__c && loanApplication.Pre_Approved_Flag__c && breResponses.isEmpty()) return true;
        if (loanApplication.BRE_ReRun_Required__c && loanApplication.Pre_Approved_Flag__c && !breResponses.isEmpty() && !breResponses[0].Is_Confirmed__c) return true;
        return loanApplication.BRE_ReRun_Required__c;
        /*            
            BRE_Response__c[] breResponses = [ SELECT Is_Confirmed__c FROM BRE_Response__c WHERE Loan_Application__c =: loanApplication.Id  ORDER BY CreatedDate DESC LIMIT 1 ];
            return breResponses.isEmpty() || (!breResponses.isEmpty() && !breResponses[0].Is_Confirmed__c);
        */
    }

    /**
    * Loan Application approvals based on Type
    */
    public static map<String, Loan_Application_Approval__c[]> getApproverTypeToApproval(Loan_Application_Approval__c[] approvalRecords){
        map<String, Loan_Application_Approval__c[]> approverTypeVsApprovals = new map<String, Loan_Application_Approval__c[]>();
        for(Loan_Application_Approval__c approval: approvalRecords){
            String key = approval.Approval_Type__c + (approval.Type__c != null ? approval.Type__c : '');
            if(!approverTypeVsApprovals.containsKey(key)){
                approverTypeVsApprovals.put(key, new Loan_Application_Approval__c[0]);
            }
            approverTypeVsApprovals.get(key).add(approval);
        }
        return approverTypeVsApprovals;
    }

    /**
    * Sachin
    * Adds Rework flag on Approval records that CM has to relook again
    * NOTE - The caller has to do the DML
    * 14th Aug 23 - SFAU-4670 - Case returned from DDE stage will have Credit Approved approval record
    * 20th Aug - CUG | 3062 - Case can also come from Credit to DDE | when it goes back to Credit it has been assigned for rework
    * 4th Oct - CUG | **** - Case sent back from Credit or Pricing will be reassigned to all the Credit / Pricing Hierarchy
    */
    public static Loan_Application_Approval__c[] getApprovalRecordsToRework( Loan_Application__c loanApplication, String approvalType ){
        List<Loan_Application_Approval__c> approvalsToRework = new List<Loan_Application_Approval__c>();
        Set<String> applicableReworkStages = new Set<String>{ GlobalConstants.STAGE_CREDIT, GlobalConstants.STAGE_PRICING, GlobalConstants.STAGE_PSD };
        Set<String> applicableApprovalStatus = new Set<String>{ 'Send Back to RO' }; // Removed 'Approved' status as per SFAU-5636
        // if(loanApplication == null || !loanApplication.BRE_ReRun_Required__c) return approvalsToRework;
        // SFAU-5622 - Add Approver__r.IsActive field in query
        Loan_Application_Approval__c[] approvals = [
            SELECT Id, Loan_Application__c, Approver__c, Type__c, Approver_Level__c, Approval_Type__c, Deviation_Level__c, Approver__r.IsActive, Is_Rework__c, Is_Assigned_Approver__c  
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =: loanApplication.Id AND 
                ( (( Approval_Status__c IN: applicableApprovalStatus) AND Loan_Application_Stage__c =: GlobalConstants.QDE AND Loan_Previous_Stage__c =: applicableReworkStages ) OR
                ( (Approval_Status__c IN: applicableApprovalStatus) AND Loan_Application_Stage__c =: GlobalConstants.STAGE_DDE AND Loan_Previous_Stage__c IN: applicableReworkStages ) ) AND
            Approval_Type__c =: approvalType AND
            Archived__c = FALSE
            WITH USER_MODE
            ORDER BY SystemModStamp DESC
        ];
        List<Loan_Application_Approval__c> lstApprovalsToDelete = new List<Loan_Application_Approval__c>();
        List<Loan_Application_Approval__c> lstApprovalsToUnlock = new List<Loan_Application_Approval__c>();
        Set<Id> setApprovalId = new Set<Id>();
        for(Loan_Application_Approval__c approval: approvals){
            // SFAU-5622
            if (approval.Approver__c != NULL && approval.Approver__r.IsActive == false) {
                Loan_Application_Approval__c objInActiveApproval = new Loan_Application_Approval__c();
                objInActiveApproval.Id = approval.Id;
                objInActiveApproval.Is_Rework__c = false;
                objInActiveApproval.Is_Assigned_Approver__c = false;
                objInActiveApproval.Archived__c = true;
                lstApprovalsToUnlock.add(objInActiveApproval);
                approvalsToRework.add(objInActiveApproval);
                continue;
            }
            // Archived the duplicate records to Rework
            if (setApprovalId.contains(approval.Approver__c)) {
                Loan_Application_Approval__c objInActiveApproval = new Loan_Application_Approval__c();
                objInActiveApproval.Id = approval.Id;
                objInActiveApproval.Archived__c = true;
                approvalsToRework.add(objInActiveApproval);
                lstApprovalsToUnlock.add(approval);
                continue;
            }
            lstApprovalsToUnlock.add(approval);
            Loan_Application_Approval__c approvalToRework = approval.clone( false, false, false, false );
            approvalToRework.Is_Rework__c = true;
        approvalToRework.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            setApprovalId.add(approval.Approver__c);
            approvalsToRework.addAll(
                new List<Loan_Application_Approval__c>{
                    new Loan_Application_Approval__c(
                        Id = approval.Id,
                        Archived__c = true
                        ),
                        approvalToRework
                    }
            );
        }
        Approval.unlock(new List<Id>((new map<Id, Loan_Application_Approval__c>(lstApprovalsToUnlock)).keySet()));
        return approvalsToRework;
    }

    public static Loan_Application_Approval__c[] getFinalApproval(String[] approvalHierarchy, String approvalType, map<String, Loan_Application_Approval__c[]> typeToApproval){
        for(String type: approvalHierarchy){
            String key = approvalType + (type != null ? type : '');
            if(typeToApproval.containsKey( key ) && !typeToApproval.get( key ).isEmpty()){
                System.debug(' ==== Key--'+ key + '\n'+ JSON.serializePretty(typeToApproval.get( key )));
                return typeToApproval.get( key );
            }
        }
        return new Loan_Application_Approval__c[0];
    }
    public static Decimal getLTVOfferedOnRoadPrice(Collateral__c collateral){
        Decimal ltvOfferedOnRoadPrice = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            vehicleCost = collateral.Vehicle_Cost__c != null ? collateral.Vehicle_Cost__c : 0;

        if( vehicleCost > 0 ){
                ltvOfferedOnRoadPrice = ( loanAmount / vehicleCost ) * 100;
                ltvOfferedOnRoadPrice = ltvOfferedOnRoadPrice.setScale(2);
        }
        return ltvOfferedOnRoadPrice;
    }

    public static Decimal getLTVOfferedOnRoadPriceNew(Collateral__c collateral){
        Decimal ltvOnRoadPrice = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            lsCost = collateral.LS_Value__c != null ? Integer.valueOf(collateral.LS_Value__c) : 0,
            onRoadPrice = collateral.On_Road_Price__c != null ? Integer.valueOf(collateral.On_Road_Price__c) : 0;

        if( loanAmount < lsCost ) return ltvOnRoadPrice;

        if( onRoadPrice != 0 ){
            ltvOnRoadPrice = ( ( loanAmount - lsCost ) / onRoadPrice ) * 100;
        } else {
            ltvOnRoadPrice = ( loanAmount - lsCost ) * 100;
        }
        return ltvOnRoadPrice.setScale(2);
    }

    public static Decimal getLTVOfferedExshowroomPrice(Collateral__c collateral){
        Decimal ltvExshowroomPrice = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            lsCost = collateral.LS_Value__c != null ? Integer.valueOf(collateral.LS_Value__c) : 0,
            nodPrice = collateral.Net_of_Discount_Price__c != null ? Integer.valueOf(collateral.Net_of_Discount_Price__c) : 0;

        if( loanAmount < lsCost ) return ltvExshowroomPrice;

        if( nodPrice != 0 ){
            ltvExshowroomPrice = ( ( loanAmount - lsCost ) / nodPrice ) * 100;
        } else {
            ltvExshowroomPrice = ( loanAmount - lsCost ) * 100;
        }
        return ltvExshowroomPrice.setScale(2);
    }
    
    public static Decimal getLTVOffered(Collateral__c collateral){
        Decimal finalValue = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
                costToConsider = collateral.Cost_to_be_Consider__c != null ? Integer.valueOf(collateral.Cost_to_be_Consider__c) : 0,
                    nodPrice = collateral.Net_of_Discount_Price__c != null ? Integer.valueOf(collateral.Net_of_Discount_Price__c) : 0;
        
        if (collateral.Collateral_Name__c != Label.Implement_Collateral_Code && loanAmount != 0 && costToConsider != 0) {
            finalValue = loanAmount / costToConsider;
            finalValue = finalValue * 100;
        }
        else if (collateral.Collateral_Name__c == Label.Implement_Collateral_Code && loanAmount != 0 && nodPrice != 0) {
            finalValue = loanAmount / nodPrice;
            finalValue = finalValue * 100;
        }
        return finalValue.setScale(2);
    }
    
    /**
     * SFAU-4476
     * Calculation updated on 1st Aug 23 as per SFAU-4476
     * old - Apportioned / finalCost
     * 1/8/23 - Total Loan Amount / Final Cost
     */
    public static Decimal getLTVOfferedOnFinalCost(Collateral__c collateral){
        Decimal ltvOnFinalCost = 0,
            totalLoanAmount = collateral.Loan__r.Total_Loan_Amount__c != null ? collateral.Loan__r.Total_Loan_Amount__c : 0,
                finalCost = collateral.Final_Cost__c != null ? collateral.Final_Cost__c : 0;
        
        if( finalCost > 0 ){
            ltvOnFinalCost = ( totalLoanAmount / finalCost ) * 100;
        }
        return ltvOnFinalCost.setScale(2);
    }

    public static Decimal getLTVOfferedOnFinalCostNew(Collateral__c collateral){
        Decimal ltvOnFinalCost = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            finalCost = collateral.Final_Cost__c != null ? collateral.Final_Cost__c : 0;

        if( finalCost > 0 ){
            ltvOnFinalCost = ( loanAmount / finalCost ) * 100;
        } else {
            ltvOnFinalCost = ( loanAmount ) * 100;
        }
        return ltvOnFinalCost.setScale(2);
    }

    public static Decimal getCustomerEquity(Collateral__c collateral){
        Decimal customerEquity = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            vehicleCost = collateral.Vehicle_Cost__c != null ? collateral.Vehicle_Cost__c : 0;

        if( vehicleCost > loanAmount ){
                customerEquity = ( vehicleCost - loanAmount );
        }
        return customerEquity.setScale(2);
    }

    public static Decimal getLoanEligibility(Collateral__c collateral){
        Decimal loanEligibility = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            approvedLTV = collateral.Approved_LTV__c != null ? Decimal.valueOf(collateral.Approved_LTV__c) : 0;

        if( approvedLTV > 0 ){
            loanEligibility = ( approvedLTV / loanAmount ) * 100; //SFAU-4328
        }
        return loanEligibility.setScale(2);
    }

    public static Decimal getLoanEligibilityNewVehicle( Collateral__c collateral ){
        Decimal loanEligibility = 0,
            nodPrice = collateral.Net_of_Discount_Price__c != null ? collateral.Net_of_Discount_Price__c : 1,
            approvedLTV = collateral.Approved_LTV__c != null ? Decimal.valueOf(collateral.Approved_LTV__c) : 0;

        if( approvedLTV > 0 ){
            loanEligibility = ( approvedLTV / nodPrice ) * 100; //SFAU-4328
        }
        return loanEligibility.setScale(2);
    }

    public static Decimal getLTVOfferedOnExShowroom(Collateral__c collateral){
        Decimal ltvOnExShowroom = 0,
            loanAmount = collateral.Apportioned_Loan_Amount__c != null ? collateral.Apportioned_Loan_Amount__c : 0,
            lsCost = collateral.LS_Value__c != null ? Integer.valueOf(collateral.LS_Value__c) : 0,
            nodPrice = collateral.Net_of_Discount_Price__c != null ? Integer.valueOf(collateral.Net_of_Discount_Price__c) : 0;

        if( nodPrice != 0 ){
            ltvOnExShowroom = ( ( loanAmount - lsCost ) / nodPrice ) * 100;
        } else {
            ltvOnExShowroom = ( loanAmount - lsCost ) * 100;
        }
        return ltvOnExShowroom.setScale(2);
    }
    
    public static String getLTVOfferedBasedGradeTractorNew(Collateral__c collateral, Loan_Application__c objLoanApp){
        
        if(collateral.LTV_Record__c==null)
            return '';
        //Decimal dApprovedLTV;
        LTV_Master__c ltvMasterRecord = (LTV_Master__c) JSON.deserialize(collateral.LTV_Record__c, LTV_Master__c.class);
        String strApprovedLTV = getLTVOfferedTractorNew(objLoanApp.Original_Vehicle_Usage__c, objLoanApp.Net_Land_Holding_in_Acre__c, objLoanApp.Customer_Grade__c, ltvMasterRecord);
        //dApprovedLTV = !String.isBlank(strApprovedLTV) ? Decimal.valueOf(strApprovedLTV) : 0;
        return strApprovedLTV;
    }
    
    public static String getLTVOfferedTractorNew(String strVehicleUsage, Decimal landHolding, String strCustomerGrade, LTV_Master__c ltvMasterRecord){
        String strApprovedLTV;
        if(strVehicleUsage== 'Agri'){
            if(landHolding == 0.00){
                strApprovedLTV = ltvMasterRecord.Agri_0_Land__c;
            }
            if(landHolding < 3){
                strApprovedLTV = ltvMasterRecord.Agri_Less_than_3_Land__c;
            }
            if(landHolding >= 3){
                strApprovedLTV = ltvMasterRecord.Agri_More_than_3_Land__c;
            }
        }
        if(strVehicleUsage == 'Commercial'){
            if(strCustomerGrade == 'FTU'){
                strApprovedLTV = ltvMasterRecord.Commercial_FTU__c;
            }
            if(strCustomerGrade == 'FTB'){
                strApprovedLTV = ltvMasterRecord.Commercial_FTB__c;
            }
            if(strCustomerGrade == 'Transporter'){
                strApprovedLTV = ltvMasterRecord.Commercial_Transporter__c;
            }
            if(strCustomerGrade == 'Captive'){
                strApprovedLTV = ltvMasterRecord.Commercial_Captive__c;
            }
        }
        return strApprovedLTV;
    }
    
    public static String getLTVOfferedTractorUsed(String strVehicleUsage, Decimal landHolding, String strCustomerGrade, Depreciated_Grid__c ltvMasterRecord){
        String strApprovedLTV;
        if(strVehicleUsage== 'Agri'){
            if(landHolding == 0){
                strApprovedLTV = ltvMasterRecord.Agri_0_Land__c;
            }
            if(landHolding < 3){
                strApprovedLTV = ltvMasterRecord.Agri_Less_than_3_Land__c;
            }
            if(landHolding >= 3){
                strApprovedLTV = ltvMasterRecord.Agri_More_than_3_Land__c;
            }
        }
        if(strVehicleUsage == 'Commercial'){
            if(strCustomerGrade == 'FTU'){
                strApprovedLTV = ltvMasterRecord.Commercial_FTU__c;
            }
            if(strCustomerGrade == 'FTB'){
                strApprovedLTV = ltvMasterRecord.Commercial_FTB__c;
            }
            if(strCustomerGrade == 'Transporter'){
                strApprovedLTV = ltvMasterRecord.Commercial_Transporter__c;
            }
            if(strCustomerGrade == 'Captive'){
                strApprovedLTV = ltvMasterRecord.Commercial_Captive__c;
            }
        }
        return strApprovedLTV;
    }
    
    
    public static String getLTVOfferedBasedGradeTractorUsed(Collateral__c collateral, Loan_Application__c objLoanApp){
        //Decimal dApprovedLTV;
        String strApprovedLTV;
        if(collateral.LTV_Record__c!=null){
            Depreciated_Grid__c ltvMasterRecord = (Depreciated_Grid__c) JSON.deserialize(collateral.LTV_Record__c, Depreciated_Grid__c.class);
            strApprovedLTV = getLTVOfferedTractorUsed(objLoanApp.Original_Vehicle_Usage__c, objLoanApp.Net_Land_Holding_in_Acre__c, objLoanApp.Customer_Grade__c, ltvMasterRecord);
            //dApprovedLTV = !String.isBlank(strApprovedLTV) ? Decimal.valueOf(strApprovedLTV) : 0;
        }
        return strApprovedLTV;
    }
    
    public static String getLoanEligibilityBasedGradeTractor(Collateral__c collateral, String strApprovedLTV){
        String strLoanEligibility;
        if(!String.isBlank(strApprovedLTV)){
            //collateral.Approved_LTV__c = dApprovedLTV;
            Decimal approvedLtvAmount = Decimal.valueOf(strApprovedLTV);
            Decimal costToConsider = !String.isBlank(collateral.Cost_to_be_Consider__c) ? Decimal.valueOf(collateral.Cost_to_be_Consider__c) : 0;
            Decimal netOfDiscountPrice = !String.isBlank(String.valueOf(collateral.Net_of_Discount_Price__c)) ? collateral.Net_of_Discount_Price__c : 0;
            Decimal maxFunding = !String.isBlank(collateral.Max_Funding_Cap__c) ? Decimal.valueOf(collateral.Max_Funding_Cap__c) : 0;
            Decimal finalValue = 0;
            if (collateral.Collateral_Name__c != Label.Implement_Collateral_Code && costToConsider != 0) {
                finalValue = (approvedLtvAmount / 100) * costToConsider;
            }
            else if (collateral.Collateral_Name__c == Label.Implement_Collateral_Code && netOfDiscountPrice != 0) {
                finalValue = (approvedLtvAmount / 100) * netOfDiscountPrice;
                if(maxFunding != 0 && maxFunding < finalValue){
                    finalValue = maxFunding;
                }
            }
            strLoanEligibility = String.valueOf(finalValue.setScale(2));
        }
        return strLoanEligibility;
    }
    
    
    public static String getLTVBasedGradeCommercialNew(Collateral__c collateral, Loan_Application__c objLoanApp){
        //Decimal dApprovedLTV;
        String strApprovedLTV;
        if(collateral.LTV_Record__c != null){
            LTV_Master__c ltvMasterRecord = (LTV_Master__c) JSON.deserialize(collateral.LTV_Record__c, LTV_Master__c.class);
            if(collateral.Loan__r.RecordType.Name == 'Commercial Vehicle'){
                strApprovedLTV = getLTVCVNew(collateral.Assessment_Method__c, objLoanApp.Customer_Grade__c, objLoanApp.Sub_Grade__c, ltvMasterRecord);
            }
            if(collateral.Loan__r.RecordType.Name == 'Construction Equipment'){
                strApprovedLTV = getLTVCENew(collateral.Assessment_Method__c, objLoanApp.Customer_Grade__c, objLoanApp.Sub_Grade__c, ltvMasterRecord);
            }
        }
        //dApprovedLTV = !String.isBlank(strApprovedLTV) ? Decimal.valueOf(strApprovedLTV) : 0;
        return strApprovedLTV;
    }
    
    public static String getLTVBasedGradeCommercialUsed(Collateral__c collateral, Loan_Application__c objLoanApp){
        //Decimal dApprovedLTV;
        String strApprovedLTV;
        Depreciated_Grid__c ltvMasterRecord = new Depreciated_Grid__c(); //(Depreciated_Grid__c) JSON.deserialize(collateral.LTV_Record__c, Depreciated_Grid__c.class);
        if(collateral.Loan__r.RecordType.Name == 'Commercial Vehicle'){
            ltvMasterRecord = AUSFCommercialVehicleController.getDepreciatedMaster(collateral,objLoanApp);
            strApprovedLTV = ltvMasterRecord.LTV_Approved__c;
        }
        if(collateral.Loan__r.RecordType.Name == 'Construction Equipment'){
            ltvMasterRecord = AUSFCommercialVehicleController.getDepreciatedMaster(collateral,objLoanApp);
            strApprovedLTV = ltvMasterRecord.LTV_Approved__c;
        }
        //dApprovedLTV = !String.isBlank(strApprovedLTV) ? Decimal.valueOf(strApprovedLTV) : 0;
        return strApprovedLTV;
    }
    
    public static String getLTVCENew(String strAssesmentMethod, String strCustomerGrade, String strCustomerSubGrade, LTV_Master__c ltvMasterRecord){
        String strApprovedLTV;
        if(strAssesmentMethod == 'CE'){
            
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'FTB'){
            strApprovedLTV = ltvMasterRecord.CE_FTB__c;
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'FTU'){
            strApprovedLTV = ltvMasterRecord.CE_FTU__c;
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Hirer'
                && strCustomerSubGrade == 'Small'){
                    strApprovedLTV = ltvMasterRecord.CE_Plant_Hirer_Small__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Hirer'
                && strCustomerSubGrade == 'Medium'){
                    strApprovedLTV = ltvMasterRecord.CE_Plant_Hirer_Medium__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Hirer'
                && strCustomerSubGrade == 'Large'){
                    strApprovedLTV = ltvMasterRecord.CE_Plant_Hirer_Large__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Mine Owner'
                && strCustomerSubGrade == 'Small-1'){
                    strApprovedLTV = ltvMasterRecord.CE_Mine_owner_Small__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Mine Owner'
                && strCustomerSubGrade == 'Medium-2-5'){
                    strApprovedLTV = ltvMasterRecord.CE_Mine_owner_Medium__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Mine Owner'
                && strCustomerSubGrade == 'Large-6+'){
                    strApprovedLTV = ltvMasterRecord.CE_Mine_owner_Large__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Contractor'
                && strCustomerSubGrade == 'Small-1'){
                    strApprovedLTV = ltvMasterRecord.CE_Contractor_Small__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Contractor'
                && strCustomerSubGrade == 'Medium-2-5'){
                    strApprovedLTV = ltvMasterRecord.CE_Contractor_Medium__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Contractor'
                && strCustomerSubGrade == 'Large-6+'){
                    strApprovedLTV = ltvMasterRecord.CE_Contractor_Large__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Captive'
                && strCustomerSubGrade == 'With financials'){
                    strApprovedLTV = ltvMasterRecord.CE_Captive_With_Financial__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Captive'
                && strCustomerSubGrade == 'Without financials'){
                    strApprovedLTV = ltvMasterRecord.CE_Captive_Without_Financial__c;
                }
        return strApprovedLTV;
    }
    
    
    public static String getLTVCVNew(String strAssesmentMethod, String strCustomerGrade, String strCustomerSubGrade, LTV_Master__c ltvMasterRecord){
        String strApprovedLTV;
        if(strAssesmentMethod == 'CE'){
            
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'FTB'){
            strApprovedLTV = ltvMasterRecord.Commercial_FTB__c;
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'FTU'){
            strApprovedLTV = ltvMasterRecord.Commercial_FTU__c;
        }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Transporter'
                && strCustomerSubGrade == 'SFO'){
                    strApprovedLTV = ltvMasterRecord.Commercial_Transporter_SFO__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Transporter'
                && strCustomerSubGrade == 'MFO'){
                    strApprovedLTV = ltvMasterRecord.Commercial_Transporter_MFO__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Transporter'
                && strCustomerSubGrade == 'LFO'){
                    strApprovedLTV = ltvMasterRecord.Commercial_Transporter_LFO__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Captive'
                && strCustomerSubGrade == 'With financials'){
                    strApprovedLTV = ltvMasterRecord.Commercial_Captive_With_financials__c;
                }
        else if((strAssesmentMethod == 'LTVInPercent' || strAssesmentMethod == 'Absolute') && strCustomerGrade == 'Captive'
                && strCustomerSubGrade == 'Without financials'){
                    strApprovedLTV = ltvMasterRecord.Commercial_Captive_Without_financials__c;
                }
        return strApprovedLTV;
    }
    
    /**
     * Sachin
     * Share Loan Application and related records to the user who accepted the application
     */
    public static void shareLoanApplicationsAndRelatedRecords( Set<Id> loanIds, Id approverId ){
        Loan_Application__Share[] applicationShares = new Loan_Application__Share[0];
        for(Id loanId: loanIds){
            applicationShares.add(
                new Loan_Application__Share(
                    ParentId = loanId,
                    UserOrGroupId = approverId,
                    AccessLevel = 'edit',
                    RowCause = Schema.Loan_Application__Share.RowCause.Sharing_To_Approver__c
                ));
        }
        insert applicationShares;
        // * Already md to loan application
        // Collateral__share[] collateralShares = new Collateral__share[0];
        // for(Collateral__c collateral: [ SELECT Id FROM Collateral__c WHERE Loan__c =: loanId ]){
        //     collateralShares.add(
        //         new Collateral__share(
        //             ParentId = collateral.Id,
        //             UserOrGroupId = approverId,
        //             AccessLevel = 'edit',
        //             RowCause = Schema.Loan_Application__Share.RowCause.Sharing_To_Approver__c
        //         )
        //     );
        // }
        // insert collateralShares;

        Field_Investigation__share[] fiShares = new Field_Investigation__share[0];
        for(Field_Investigation__c fi: [ SELECT Id FROM Field_Investigation__c WHERE Loan_Application__c IN: loanIds ]){
            fiShares.add(
                new Field_Investigation__share(
                    ParentId = fi.Id,
                    UserOrGroupId = approverId,
                    AccessLevel = 'edit',
                    RowCause = Schema.Field_Investigation__share.RowCause.Sharing_To_Approver__c
                )
            );
        }
        //SFAU-4983 - Use Database.Insert for FI Share record
        database.insert(fiShares,false);

        BSR_PSL_Details__share[] bsrPslShares = new BSR_PSL_Details__share[0];
        for(BSR_PSL_Details__c bsrDet: [ SELECT Id FROM BSR_PSL_Details__c WHERE Loan_Application__c IN: loanIds ]){
            bsrPslShares.add(
                new BSR_PSL_Details__share(
                    ParentId = bsrDet.Id,
                    UserOrGroupId = approverId,
                    AccessLevel = 'edit',
                    RowCause = Schema.BSR_PSL_Details__share.RowCause.Sharing_To_Approver__c
                )
            );
        }
        //:TODO - Sachin - Verify if not sharing BSR PSL affects functionality ( insufficient on cross-referenece )
        insert bsrPslShares;

        //SFAU-3838 share applicant related document checklist with Credit user
        Map<Id, Applicant__c> applicants = new Map<Id,Applicant__c>([SELECT Id FROM Applicant__c WHERE Loan__c IN :loanIds AND RecordType.DeveloperName IN 
            ('Primary_Applicant','Co-Applicant','BO','Guarantor') AND IsInactive__c=false]);
        Document_Checklist__share[] docChecklistShares = new Document_Checklist__share[0];
        for(Document_Checklist__c doc: [ SELECT Id FROM Document_Checklist__c WHERE (Loan_Application__c IN: loanIds OR Applicant__c IN :applicants.keySet())]){
            docChecklistShares.add(
                new Document_Checklist__share(
                    ParentId = doc.Id,
                    UserOrGroupId = approverId,
                    AccessLevel = 'edit'
                )
            );
        }
        insert docChecklistShares;

        Notepad__share[] notepadShares = new Notepad__share[0];
        for(Notepad__c noteRecord: [ SELECT Id FROM Notepad__c WHERE Loan_Application__c IN: loanIds ]){
            notepadShares.add(
                new Notepad__share(
                    ParentId = noteRecord.Id,
                    UserOrGroupId = approverId,
                    AccessLevel = 'edit'
                )
            );
        }
        insert notepadShares;

        // Public read / write
        // Reference__share[] referencesShares = new Reference__share[0];
        // for(Reference__c ref: [ SELECT Id FROM Reference__c WHERE Loan__c =: loanId ]){
        //     referencesShares.add(
        //         new Reference__share(
        //             ParentId = ref.Id,
        //             UserOrGroupId = approverId,
        //             AccessLevel = 'edit'
        //         )
        //     );
        // }
        // insert referencesShares;

        // Public read / write
        // Loan_Application_Assignment__share[] assignmentShares = new Loan_Application_Assignment__share[0];
        // for(Loan_Application_Assignment__c assigment: [ SELECT Id FROM Loan_Application_Assignment__c WHERE Loan__c =: loanId ]){
        //     assignmentShares.add(
        //         new Loan_Application_Assignment__share(
        //             ParentId = assigment.Id,
        //             UserOrGroupId = approverId,
        //             AccessLevel = 'edit'
        //         )
        //     );
        // }
        // insert assignmentShares;
    }
    public static Boolean canCreditUserEdit( Loan_Application__c application, Id approverId ){
        if(application.Stage__c != GlobalConstants.STAGE_CREDIT) return true;

        return [ SELECT COUNT() FROM Loan_Application_Approval__c
                WHERE Loan_Application__c =: application.Id AND
                Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND
                Approver__c =: approverId AND
                Archived__c = FALSE
                WITH SYSTEM_MODE
            ] > 0;
    }

        /**
     * Sachin - 
     * String checklistNumber
     *  String errorMessage
     *  String apiError
     *  Integer apiStatusCode
     *  String exceptionPath
     */
    public static String getApiCustomError( String checklistNumber, String errorMessage, String apiError, Integer apiStatusCode, String exceptionPath ){
        return GlobalConstants.API_ERROR_MESSAGE_FORMAT
            .replace('{IntegrationChecklistNumber}', checklistNumber )
            .replace('{ErrorMessage}', errorMessage + (String.isNotBlank( exceptionPath ) ? (' at ' + exceptionPath) : '') )
            .replace('{APIStatusCode}', String.valueOf(apiStatusCode) )
            .replace('{APIErrorMessage}', apiError );
    }

    public static Loan_Application_Approval__c[] getApproalsForRework( Loan_Application__c loanApplication ){
        Id loanId = loanApplication?.Id;
        if( loanId == NULL || loanApplication.RecordType.Name != GlobalConstants.TWOWHEELER ){
            return new Loan_Application_Approval__c[0];
        }

        return [
            SELECT Id, Approver__c, Approver_Level__c, Approver__r.Name, Type__c, Approval_Type__c, Is_Assigned_Approver__c, Loan_Application__c, Assigned_to_Queue__c
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =: loanId
            AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT
            AND ( Approver__r.Profile.Name != 'Sales' OR ( Approver__c = NULL AND Assigned_to_Queue__c = TRUE ) )
            AND Archived__c = false 
        ];
    }

    /**
     * Sachin
     * Get Applicants by their Customer Type - Individual / Non-Individual
     * @param - applicants - Applicant__c[] - applicants to be mapped
     */
    public static map<String, Applicant__c[]> getApplicantByCustomerType( Applicant__c[] applicants ){
        map<String, Applicant__c[]> applicantsByType = new map<String, Applicant__c[]>();
        for( Applicant__c applicant: applicants ){
            if( !applicantsByType.containsKey( applicant.Customer_Type__c ) ){
                applicantsByType.put( applicant.Customer_Type__c, new Applicant__c[0] );
            }
            applicantsByType.get( applicant.Customer_Type__c ).add( applicant );
        }
        return applicantsByType;
    }

     /**
     * Kunal
     * Get Related Individual applicants from Non Individual Applicants
     * @param - applicants - Applicant__c[] - applicants to be mapped
     */
    public static Map<String, Applicant__c> getApplicantByNonInd( String nonIndAppId ){
        
        Map<String,Applicant__c> individualApplicantsWithRelation = new Map<String,Applicant__c>();
        /* Commenting till not moving to prod.
        List<Applicant_Relation__c> applicantRelations = [ SELECT
            Ind_Applicant__c,
            Ind_Applicant__r.Applicant_Name__c,
            NI_Applicant__c,
            NI_Applicant__r.Applicant_Name__c,
            Relationship__c
            FROM Applicant_Relation__c
            WHERE  NI_Applicant__c =: nonIndAppId
        ];
        Map<Id,Applicant_Relation__c> individualApplicantIds = new Map<Id,Applicant_Relation__c>();
        for(Applicant_Relation__c appRel : applicantRelations){
            individualApplicantIds.put(appRel.Ind_Applicant__c,appRel);
        }

        List<Applicant__c> individualApplicants = [SELECT Id, Director_Identification_Number__c ,CIF_No__c, Name, Relationship_with_applicant__c, Title__c, First_Name__c, Middle_Name__c, Last_Name__c, Father_Name__c, Spouse_Name__c, Dob__c, Gender__c, PAN__c, Pan_Form60__c,
        Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, KYC_Type__c, Mobile_Number__c, NPR__c, NREGA__c FROM Applicant__c WHERE Customer_Type__c = 'Individual' AND Id IN: individualApplicantIds.keySet()];

        for(Applicant__c app : individualApplicants){
            individualApplicantsWithRelation.put(individualApplicantIds.get(app.Id).Relationship__c,app);
        }
       */ 
      return individualApplicantsWithRelation;

    }
    public static Loan_Application_Approval__c[] assignApprovalsForRework( Loan_Application_Approval__c[] approvals ){
        Loan_Application_Approval__c[] approvalsToUpdate = new Loan_Application_Approval__c[0];
        for( Loan_Application_Approval__c approval: approvals ){
            Loan_Application_Approval__c newApproval = approval.clone( false, false, false, false );
            newApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;

            approvalsToUpdate.addAll(
                new Loan_Application_Approval__c[]{
                    newApproval, new Loan_Application_Approval__c( Id = approval.Id , Archived__c = true )
                }
            );
        }
        return approvalsToUpdate;
    }
    // SFAU-4471
    public static map<String, Charge__c> getChargesMappedByScCode( Charge__c[] charges ){
        map<String, Charge__c> chargesMap = new map<String, Charge__c>();
    
        for( Charge__c charge : charges ){
            chargesMap.put( charge.SC_Code__c, charge );
        }
        return chargesMap;
    }

    // SFAU-4471
    public static map<String, AccountTeamMember[]> getTeamMembersByRole( AccountTeamMember[] teamMembers ){
        map<String, AccountTeamMember[]> membersByRole = new map<String, AccountTeamMember[]>();
        for( AccountTeamMember atm: teamMembers ){
            if( !membersByRole.containsKey( atm.TeamMemberRole ) ){
                membersByRole.put( atm.TeamMemberRole, new AccountTeamMember[0] );
            }
            membersByRole.get( atm.TeamMemberRole ).add( atm );
        }
        return membersByRole;
    }

    public static Loan_Application_Approval__c[] archiveRBMApprovals( Set<Id> loanIds ){
        if( loanIds.isEmpty() ) return new Loan_Application_Approval__c[0];
        
        Loan_Application_Approval__c[] approvalsToArchive = [
            SELECT Id FROM Loan_Application_Approval__c
            WHERE Loan_Application__c IN: loanIds AND Approval_Type__c = 'RBMTatkal' AND
            Document_Name__c = NULL AND Archived__c = FALSE
        ];


        for( Loan_Application_Approval__c approval: approvalsToArchive ){
            approval.Archived__c = true;
        }
        return approvalsToArchive;
    }
    /**
     * SFAU-4471 - LS Charges to be archived when reassignment happens
     */
    public static void archiveDeviations( Deviation__c[] oldDeviations ){
        for( Deviation__c deviation: oldDeviations ){
            deviation.Archived__c = true;
        }
        update oldDeviations;
    }

    /**
     * SFAU-5208 - Share BSR PSL records with credit users when they are created
     */
    public static void shareBSRPSLRecords( BSR_PSL_Details__c[] bsrPslData, Id loanId ){
        BSR_PSL_Details__share[] bsrPslShares = new BSR_PSL_Details__share[0];
        Loan_Application_Approval__c[] creditApprovals = [
            SELECT Approver__c
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =:loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE
        ];
    
        for( BSR_PSL_Details__c item: bsrPslData ){
            for( Loan_Application_Approval__c approval: creditApprovals ){
                bsrPslShares.add(
                    new BSR_PSL_Details__share(
                        ParentId = item.Id,
                        UserOrGroupId = approval.Approver__c,
                        AccessLevel = 'edit',
                        RowCause = Schema.BSR_PSL_Details__share.RowCause.Sharing_To_Approver__c
                    )
                );
            }
        }
        
        Database.SaveResult[] saveResults = Database.insert( bsrPslShares, false );

        String errorMessage = '';
        Id[] failedIds = new Id[0];
        for(Database.SaveResult sr: saveResults){
            if( !sr.isSuccess() ){
                for(Database.Error err : sr.getErrors()) {
                    errorMessage += (err.getStatusCode() + ': ' + err.getMessage() + '\n');
                }
                failedIds.add( sr.getId() );
            }
        }
        Log.error(errorMessage, failedIds, Log.SeverityType.valueOf('High'), loanId );
    }

    /*
    @ method: changeDocumentChecklistOwner
    @ Param1: Object API Name
    @ Param2: Map of RecordId With OwnerId
    @ User Story | Bug Id : SFAU-5419
    @ description : Change Document Checklist record owner when parent record owner change
    */
    public static UtilityWrapper changeDocumentChecklistOwner (String strObject, Map<Id,Id> mapRecordWithOwnerId) {
        UtilityWrapper objWrap = new UtilityWrapper();
        Set<Id> setRecordIds = mapRecordWithOwnerId.keySet();
        String strQuery = 'SELECT Id, Loan_Application__c, Collateral__c, Applicant__c, Related_Loan_Application__c, OwnerId FROM Document_Checklist__c ';
        Boolean blnMatchObject = false;
        List<Document_Checklist__c> lstDoc = new List<Document_Checklist__c>();
        try {
            if (strObject == 'Loan_Application__c') {
                strQuery = strQuery + ' WHERE (Loan_Application__c in: setRecordIds OR Collateral__r.Loan__c in: setRecordIds OR Applicant__r.Loan__c in: setRecordIds) ';
                blnMatchObject = true;
            }
            else if (strObject == 'Applicant__c') {
                strQuery = strQuery + ' WHERE (Applicant__c in: setRecordIds) ';
                blnMatchObject = true;
            }
            else if (strObject == 'Collateral__c') {
                strQuery = strQuery + ' WHERE (Collateral__c in: setRecordIds)';
                blnMatchObject = true;
            }
            lstDoc = blnMatchObject ? Database.query(strQuery) : new List<Document_Checklist__c>();
            system.debug(LoggingLevel.Info, ' lstDoc : ' + lstDoc.size());
            if (!lstDoc.isEmpty()) {
                for (Document_Checklist__c objDoc : lstDoc) {
                    Id applicationId = Id.valueOf(objDoc.Related_Loan_Application__c);
                    if (strObject == 'Applicant__c' && objDoc.Applicant__c != NULL && mapRecordWithOwnerId.containsKey(applicationId) && objDoc.OwnerId != mapRecordWithOwnerId.get(applicationId)) {
                        objDoc.OwnerId = mapRecordWithOwnerId.get(applicationId);
                        blnMatchObject = true;
                    }
                    else if (strObject == 'Collateral__c' && objDoc.Collateral__c != NULL && mapRecordWithOwnerId.containsKey(applicationId) && objDoc.OwnerId != mapRecordWithOwnerId.get(applicationId)) {
                        objDoc.OwnerId = mapRecordWithOwnerId.get(applicationId);
                        blnMatchObject = true;
                    }
                    else if (strObject == 'Loan_Application__c' && (objDoc.Loan_Application__c != NULL || objDoc.Applicant__c != NULL || objDoc.Collateral__c != NULL) && mapRecordWithOwnerId.containsKey(applicationId) && objDoc.OwnerId != mapRecordWithOwnerId.get(applicationId)) {
                        objDoc.OwnerId = mapRecordWithOwnerId.get(applicationId);
                        blnMatchObject = true;
                    }
                }
                if (blnMatchObject) {
                    update lstDoc;
                }
                objWrap.blnSuccess = true;
            }
        }
        catch (Exception ex) {
            objWrap.strMessage = ex.getMessage();
            Log.error('Error in Utility changeDocumentChecklistOwner :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        return objWrap;
    }

    // Check if payment is made based on payment Id - 23rd Nov
    @AuraEnabled
    public static Map<String,Boolean> checkIfPaymentAlreadyReleased(List<String> paymentIds){
        Map<String,Boolean> responseMap = new Map<String,Boolean>();
        
        Map<Id,Payment__c> paymentFavourings = new Map<Id,Payment__c>([SELECT Id, Payment_Favouring_Status__c, Is_Payment_Triggered__c FROM Payment__c WHERE Id IN: paymentIds AND RecordType.DeveloperName='Payment_Favouring' AND Inactive__c=false]);
        for(Payment__c record : paymentFavourings.values()){
            responseMap.put(record.Id,record.Is_Payment_Triggered__c);
        }
        List<Integration_Checklist__c> icRecords =[SELECT Id,Response__c,Integration_Master_Name__c,Payment__c FROM Integration_Checklist__c Where Payment__c IN: paymentIds AND Integration_Master_Name__c IN: GlobalConstants.RELEASE_PAYMENT_INTEGRATION_MASTERS AND Status__c = 'Completed' AND Call_Type__c = null  Order by Createddate desc];
        if(icRecords.isEmpty()){
            return responseMap;
        }
        try{
            
            for(Integration_Checklist__c record : icRecords){
                responseMap.put(record.Payment__c,true);
                /*if(record.Integration_Master_Name__c == GlobalConstants.PAYMENT_NEFT && String.isNotBlank(record.Response__c)){
                  
                    PaymentNEFTAPIHandler.PaymentNEFTAPIResponseWrappper wrapper = (PaymentNEFTAPIHandler.PaymentNEFTAPIResponseWrappper) JSON.deserialize(record.Response__c, PaymentNEFTAPIHandler.PaymentNEFTAPIResponseWrappper.Class);
                    if(wrapper.SettlementResponse != null && wrapper.SettlementResponse.Status == 'Success' &&  wrapper.SettlementResponse.IPHREF != null){
                        responseMap.put(record.Payment__c,true);
                    }
                    
                }else if(record.Integration_Master_Name__c == GlobalConstants.PAYMENT_IFT && String.isNotBlank(record.Response__c)){
                    
                    PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper wrapper = (PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper) JSON.deserialize(record.Response__c, PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper.Class);
                    if(wrapper.TransactionStatus!=null && wrapper.TransactionStatus.ResponseMessage == 'Success' && wrapper.TransactionReferenceNo != null){
                        responseMap.put(record.Payment__c,true);
                    }
                    
                }else if(record.Integration_Master_Name__c == GlobalConstants.PAYMENT_RTGS && String.isNotBlank(record.Response__c)){
                    
                    PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper wrapper = (PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper) JSON.deserialize(record.Response__c, PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper.Class);
                    if(wrapper.SettlementResponse != null && wrapper.SettlementResponse.Status == 'Success' &&  wrapper.SettlementResponse.IPHREF != null){
                        responseMap.put(record.Payment__c,true);
                    }
                    
                }else if(record.Integration_Master_Name__c == GlobalConstants.PAYMENT_IMPS && String.isNotBlank(record.Response__c)){
                    
                    PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper wrapper = (PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper) JSON.deserialize(record.Response__c, PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper.Class);
                    if(wrapper.TransactionStatusType!=null && wrapper.TransactionStatusType.ResponseMessage == 'Success' && wrapper.RetrievalReferenceNumber != null){
                        responseMap.put(record.Payment__c,true);
                    }
                    
                }
                */
            }
             return responseMap;
        }catch(Exception e){
            Log.error('Error in Utility method checkIfPaymentAlreadyReleased :: ' + e.getMessage(),Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),paymentIds[0]);
            return null;
        }
    }

    /* User Story | Bug Id : SFAU-5419 */
    public class UtilityWrapper {
        public Boolean blnSuccess = false;
        public String strMessage = '';
    }

    /**
* R2-18 - Vehicle Usage to be based on Product
* Sachin - 22/08/23
*/
    public static Product_vs_Vehicle_Usage__mdt[] getVehicleUsageOptionsByProduct( String product ){
        
        Product_vs_Vehicle_Usage__mdt[] options = [
            SELECT Vehicle_Usages__c, Collateral_Type__c
            FROM Product_vs_Vehicle_Usage__mdt
            WHERE Product_Code__c =: product
        ];
        
        if( !options.isEmpty() ){
            return options;
        }
        
        return [
            SELECT Vehicle_Usages__c, Collateral_Type__c
            FROM Product_vs_Vehicle_Usage__mdt
            WHERE Product_Name__c =: product
        ];
    }
    
    /**
* R2-765 - Common_Picklist__mdt - Picklist values based on Product, Field Api and Collateral Type
*/
public static AUSFVehicleController.PicklistWrapper[] getPicklistValuesByProductAndCollateralType( String fieldName, String productCode, String collateralType ){
    AUSFVehicleController.PicklistWrapper[] picklistOptions = new AUSFVehicleController.PicklistWrapper[0];
    
    Common_Picklist__mdt[] options = [ //NOPMD ApexCRUDViolation - false positive | Query on Custommetadata
        SELECT Id, Field_Value__c, Customer_Type__c, Product__c
        FROM Common_Picklist__mdt
        WHERE Field_Name__c =: fieldName
        AND ( Product__c =: productCode OR Product__c = 'All' )
        AND Collateral_Type__c =: collateralType
        LIMIT 1
    ];
    
    if( ( options.isEmpty() || String.isBlank(options[0].Field_Value__c)) ){
        return picklistOptions;
    }
    
    for( String option: options[0].Field_Value__c.split(',')){
        picklistOptions.add(
            new AUSFVehicleController.PicklistWrapper(
                option,
                option
            )
        );
    }
    
    return picklistOptions;
}

public static map<String, String> getPicklistApiToLabel( String objectName, String fieldName ){
    map<String, String> picklistValues = new map<String, String>();
    
    Schema.DescribeFieldResult fieldDesc = ((SOBject)Type.forName('Schema.' + objectName ).newInstance())
        ?.getSObjectType()
        .getDescribe()
        .fields
        .getMap()
        .get( fieldName )
        ?.getDescribe();
    
    if( fieldDesc == null ){
        return picklistValues;
    }
    
    
    Schema.PicklistEntry[] ple = fieldDesc.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple ){
        picklistValues.put(
            pickListVal.getValue(),
            pickListVal.getLabel()
        );
    }
    return picklistValues;
}
}