public with sharing class GenericWizardController {

    @AuraEnabled
    public static Loan_Application__c getRecordtypeName(String strRecordId) {
        try {
            List<Loan_Application__c> objLoan = [Select Id,RecordType.Name,toLabel(Product__c) from Loan_Application__c where Id =:strRecordId];
            if(!objLoan.isEmpty()){
                return objLoan[0];
            }
            else{
                return null;
            }
            //return objLoan.RecordType.Name;
        } catch(Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static GenericWizardWrapper getWizardSettings(String strWizardName, String strStageName, String strProductName) {
        GenericWizardWrapper objGenericWizardWrapper = new GenericWizardWrapper();
        try {
            Generic_Wizard_Flow_Config__mdt objWizardConfig = [Select Id,Flow_Name__c,DeveloperName,MasterLabel,Stage__c,
                                                               Screen_Config_Json_Long__c,(Select Id,DeveloperName,Current_Page__c,Flow_Name__c,Start_Page__c from Generic_Wizard_Current_Page_Configs__r)
                                                               from Generic_Wizard_Flow_Config__mdt 
                                                               where Stage__c=:strStageName AND Flow_Name__c=:strWizardName AND Product__c=:strProductName limit 1];
            objGenericWizardWrapper.objGenericWizard = objWizardConfig;
            Map<String,String> mapProdCodevsProduct = new Map<String,String>();
            Map<String,String> mapProdCodevsWizardProdName = new Map<String,String>();
            //List<ProductRTMap__mdt> objProd
            //for(ProductRTMap__mdt objProdMap : [Select Id,Product__c,Product_Name_for_Wizard__c,Product_Name__c from ProductRTMap__mdt where Product_Name_for_Wizard__c !='']){
            Map<String,ProductRTMap__mdt> mapProdRTMap = ProductRTMap__mdt.getAll();
            for(ProductRTMap__mdt objProdMap : mapProdRTMap.values()){
                if(objProdMap.Product_Name_for_Wizard__c != ''){
                    mapProdCodevsProduct.put(objProdMap.Product__c ,objProdMap.Product_Name__c);
                    mapProdCodevsWizardProdName.put(objProdMap.Product__c ,objProdMap.Product_Name_for_Wizard__c);
                }
            }
            objGenericWizardWrapper.mapProdCodevsProduct = mapProdCodevsProduct;
            objGenericWizardWrapper.mapProdCodevsWizardProdName = mapProdCodevsWizardProdName;
            return objGenericWizardWrapper;
        } catch(Exception e) {
            return null;
        }
        //return Generic_Wizard_Flow_Config__mdt.getAll();
    }
    
    public class GenericWizardWrapper {
        @AuraEnabled public Generic_Wizard_Flow_Config__mdt objGenericWizard{get;set;}   //25479697
        @AuraEnabled public Map<String,String> mapProdCodevsProduct{get;set;}
        @AuraEnabled public Map<String,String> mapProdCodevsWizardProdName{get;set;}
    }
    
    @AuraEnabled
    public static GenericWizardState fetchWizardState(String strLoanAppId){
        Id myRecordId = Id.valueOf(strLoanAppId);
        String sObjName = myRecordId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Applicant__c'){
            Applicant__c objApplicant = [Select Id,Loan__c from Applicant__c where Id=:strLoanAppId WITH SECURITY_ENFORCED limit 1];
            strLoanAppId = objApplicant.Loan__c;
        }
        Id addMatchId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),'Additional_Match');
        Id boId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),'BO');
        GenericWizardState objGenericWizardState = new GenericWizardState();
        if(!String.isBlank(strLoanAppId)){
            Loan_Application__c objLoanApp = [SELECT Id, Name, Sourcing_channel__c, Application_Id__c, Draft_Stage__c, Product__c,
            (SELECT PAN__c, RecordTypeId, Loan__c, Aadhaar_Number__c, Mobile_Number__c, Id, Name, Customer_Type__c, KYC_Status__c FROM Applicants__r where RecordTypeId != :addMatchId) FROM Loan_Application__c 
            where Id = :strLoanAppId WITH SECURITY_ENFORCED limit 1];
            
            ProductRTMap__mdt objProdRTMap = [Select Id,Product__c,Product_Name__c,Product_Name_for_Wizard__c from ProductRTMap__mdt where Product__c =:objLoanApp.Product__c limit 1];
            
            objGenericWizardState.objLoanApp = objLoanApp;
            objGenericWizardState.objProdRTMap = objProdRTMap;
            return objGenericWizardState;
        }
        else{
            return null;
        }
    }
    
    public class GenericWizardState {
        @AuraEnabled public Loan_Application__c objLoanApp{get;set;}   //25479697
        @AuraEnabled public ProductRTMap__mdt objProdRTMap{get;set;}
    }
    
    @AuraEnabled
    public static StageFlowWrapper fetchDraftStage(String strLoanAppId){
        StageFlowWrapper objStageFlowWrapper = new StageFlowWrapper();
        if(!String.isBlank(strLoanAppId)){
            Loan_Application__c objLoanApplication = [SELECT Id, Name, Sourcing_channel__c ,Stage__c, Application_Id__c, Draft_Stage__c, RecordTypeId, Product__c FROM Loan_Application__c 
            where Id = :strLoanAppId WITH SECURITY_ENFORCED limit 1];
            
            //added for Convert To Loan on Lead stage
            
            if(objLoanApplication.Stage__c == 'Lead'){
               objLoanApplication.Stage__c = 'QDE';
               String recordTypeName = LosQuickLoanController.getRecordTypeName(objLoanApplication.Product__c);
               objLoanApplication.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
               update objLoanApplication;
            }

            if(objLoanApplication.Stage__c == 'PSD'){
                objLoanApplication.Draft_Stage__c = 'Repayment';
                update objLoanApplication;
             }
             if((objLoanApplication.Stage__c == 'DDE' || objLoanApplication.Stage__c == 'QDE') && objLoanApplication.Draft_Stage__c == 'Repayment'){
                objLoanApplication.Draft_Stage__c = '';
                update objLoanApplication;
             }
            
            if(objLoanApplication != null && objLoanApplication.Stage__c != null && objLoanApplication.Draft_Stage__c != null){
                String likeQuery= '%'+objLoanApplication.Draft_Stage__c+'%';
                Generic_Wizard_Flow_Config__mdt objWizardConfig = [Select Id,DeveloperName,MasterLabel,Stage__c,Flow_Name__c,
                  Screen_Config_Json_Long__c,(Select Id,DeveloperName,Flow_Name__c,Current_Page__c,Start_Page__c,Draft_Stages__c from Generic_Wizard_Current_Page_Configs__r where Draft_Stages__c like :likeQuery limit 1)
                  from Generic_Wizard_Flow_Config__mdt 
                  where Stage__c=:objLoanApplication.Stage__c AND Draft_Stages__c like :likeQuery limit 1];
                if(objWizardConfig != null){
                    objStageFlowWrapper.strFlowName = objWizardConfig.Flow_Name__c;
                    Generic_Wizard_Current_Page_Config__mdt objCurrentPage = objWizardConfig.Generic_Wizard_Current_Page_Configs__r;
                    objStageFlowWrapper.strChildtoFlowName = objCurrentPage.Flow_Name__c;
                    objStageFlowWrapper.strStageName = objLoanApplication.Stage__c;
                }
            }
            else if(objLoanApplication != null && objLoanApplication.Stage__c != null){
                objStageFlowWrapper.strFlowName = 'Parent_Flow';
                objStageFlowWrapper.strChildtoFlowName = 'Default';
                objStageFlowWrapper.strStageName = objLoanApplication.Stage__c;
            }
            return objStageFlowWrapper;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveDraftStage(String strLoanAppId, String currentStage){
        List<Loan_Application__c> lstLoanApptoUpdate = new List<Loan_Application__c>();
        Loan_Application__c objLoanApplication = new Loan_Application__c();
        objLoanApplication.Id = strLoanAppId;
        objLoanApplication.Draft_Stage__c = currentStage;
        lstLoanApptoUpdate.add(objLoanApplication);
        DatabaseUtility.updateRecords(lstLoanApptoUpdate,'');
    
    }
    
    @AuraEnabled(cacheable=true)
    public static Generic_Wizard_Flow_Config__mdt getWizardSettingsWire(String WizardName, String StageName) {
        //try {
            system.debug('%%% '+WizardName);
            system.debug('%%% '+StageName); 
            Generic_Wizard_Flow_Config__mdt objWizardConfig = [Select Id,DeveloperName,MasterLabel,Stage__c,Flow_Name__c,
                  Screen_Config_Json_Long__c,(Select Id,DeveloperName,Current_Page__c,Start_Page__c,Flow_Name__c from Generic_Wizard_Current_Page_Configs__r)
                  from Generic_Wizard_Flow_Config__mdt 
                  where Stage__c=:StageName AND Flow_Name__c=:WizardName limit 1];
            return objWizardConfig;
        //return Generic_Wizard_Flow_Config__mdt.getAll();
    }
    
    public class StageFlowWrapper{
        @AuraEnabled
        public String strFlowName{get; set;}
        @AuraEnabled
        public String strChildtoFlowName{get; set;}
        @AuraEnabled
        public String strStageName{get; set;}
    }
    
}