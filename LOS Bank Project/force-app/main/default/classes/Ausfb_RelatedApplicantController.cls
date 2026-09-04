public with sharing class Ausfb_RelatedApplicantController {
    
    @AuraEnabled
    public static List<Applicant__c> getApplicants(Id loanAppRecId){
        return [Select Id, KYC_Status__c, KYC_Type__c, Name, Mobile_Number__c, IsInactive__c,Relationship_with_applicant__c, Customer_Name__c, Applicant_Name__c, Bureau_Score__c , RecordType.Name, RecordTypeId, Loan__r.Customer_type__c, Customer_type__c, Loan__r.Stage__c, Loan__r.RecordType.Name, Is_Customer_Details_Saved__c, Aadhaar_Number__c, CIF_No__c, PAN__c, Voter_Id__c, Driving_License_Id__c, Passport_Number__c, NPR__c, NREGA__c, CKYC__c, Is_BO__c, Constitution_Type__c from  Applicant__c where Loan__c  =: loanAppRecId AND RecordType.Name !='Additional Match' AND RecordType.Name !='Nominee'WITH SECURITY_ENFORCED ORDER BY CreatedDate];// Removing Inactive check criteria for 3548
    }

    @AuraEnabled
    public static Map<String,Object> getApplicantsByProductType(Id loanAppRecId){
        Map<String,Object> response = new Map<String,Object>();
        List<Applicant__c> applicants =  [Select Id, Name, IsInactive__c,Relationship_with_applicant__c, Customer_Name__c, Applicant_Name__c, Bureau_Score__c , RecordType.Name, RecordTypeId, Loan__r.Customer_type__c, Customer_type__c, Loan__r.Stage__c,Loan__r.Product__c, Loan__r.RecordType.Name, Is_Customer_Details_Saved__c, Aadhaar_Number__c, CIF_No__c, PAN__c, Voter_Id__c, Driving_License_Id__c, Passport_Number__c, NPR__c, NREGA__c, CKYC__c from  Applicant__c where Loan__c  =: loanAppRecId AND RecordType.Name !='Additional Match' AND RecordType.Name !='Nominee'WITH SECURITY_ENFORCED ORDER BY CreatedDate];// Removing Inactive check criteria for 3548
        if(!applicants.IsEmpty()){
            response.put('applicants',applicants);
            response.put('product',AUSFVehicleController.getTypeOfWheeler(applicants[0].Loan__r.Product__c));
        }
        return response;
    }
    
    @AuraEnabled
    public static Applicant__c getApplicant(Id recId){
        return [Select Id, Customer_Name__c,Relationship_with_applicant__c, Bureau_Score__c , RecordType.Name, RecordTypeId, PAN_verification_Status__c, Customer_type__c from  Applicant__c where Id  =: RecId WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled
    public static List<DocumentMasterWrapper> checkMandatoryDocuments(Id recId){
        List<DocumentMasterWrapper> wrapperObjList = new List<DocumentMasterWrapper>();
        List<Mandatory_Document__mdt> mandDocsList = new List<Mandatory_Document__mdt>();
        //If record id is Loan Application
        Schema.SObjectType loanApplicationObject = Schema.Loan_Application__c.getSObjectType();
        Schema.SObjectType record = recId.getsobjecttype();
        List<Applicant__c> applicants = [SELECT Id, Total_Monthly_Income_Sum__c, Loan__c, Loan__r.Loan_Amount__c, Loan__r.Final_Exposure__c, Loan__r.Product__c, 
                                         RecordType.DeveloperName, Loan__r.RecordType.DeveloperName FROM Applicant__c WHERE Id=:recId WITH SECURITY_ENFORCED];
        //R2-389
        if(!applicants.isEmpty()){
            Applicant__c applicant = applicants[0];
            List<Applicant__c> primaryApplicants = [SELECT Id, Total_Monthly_Income_Sum__c, Loan__c, Loan__r.Loan_Amount__c, Loan__r.Final_Exposure__c, Loan__r.Product__c, Customer_Type__c
                                            FROM Applicant__c WHERE Loan__c=:applicant.Loan__c AND recordType.DeveloperName='Primary_Applicant' 
                                            AND IsInactive__c=false WITH SECURITY_ENFORCED];
            
            Decimal monthlyInc = applicant.Total_Monthly_Income_Sum__c!=null?applicant.Total_Monthly_Income_Sum__c:0;
            Decimal exposure = applicant.Loan__r.Final_Exposure__c!=null?applicant.Loan__r.Final_Exposure__c:0;
            Decimal amount = applicant.Loan__r.Loan_Amount__c!=null?applicant.Loan__r.Loan_Amount__c:0;
            List<Mandatory_Document__mdt> mandDocsListMdt = [SELECT Id, Is_PAN_mandatory__c, Is_Form60_mandatory__c, Customer_Type__c, Loan_Amount__c,
            Exposure__c, Income__c, Is_PAN_Mand_if_App_NI_CoApp_I__c FROM Mandatory_Document__mdt WHERE 
            Product__c = :applicant.Loan__r.Product__c]; 
            for(Mandatory_Document__mdt metadata: mandDocsListMdt){
                //commenting below condition as per requirement under bug R2-1865
                //if((amount > metadata.Loan_Amount__c) || (metadata.Exposure__c!=null && exposure>metadata.Exposure__c) || ((monthlyInc*12)>metadata.Income__c)){
            if((amount > metadata.Loan_Amount__c)){
                    if(!primaryApplicants.isEmpty() && primaryApplicants[0].Customer_Type__c == 'Non Individual' && applicant.RecordType.DeveloperName=='Co_Applicant' && applicant.Loan__r.RecordType.DeveloperName=='Tractor'){
                        metadata.Is_PAN_mandatory__c = metadata.Is_PAN_Mand_if_App_NI_CoApp_I__c;
                        mandDocsList.add(metadata);
                    }else{
                        mandDocsList.add(metadata);
                    }
                    
                }
            }

        }
        /*If(record == loanApplicationObject){
            Loan_Application__c loanAppRec = [Select Id, Loan_Amount__c, Product__c  from  Loan_Application__c where Id  =: RecId WITH SECURITY_ENFORCED];
            mandDocsList = [Select Id, Is_PAN_mandatory__c, Is_Form60_mandatory__c, Customer_Type__c from Mandatory_Document__mdt where (Product__c =: loanAppRec.Product__c and Loan_Amount__c <: loanAppRec.Loan_Amount__c) WITH SECURITY_ENFORCED]; 
            
        }else
        //If record id is Applicant
        {
            Applicant__c appRec = [Select Id, RecordType.Name, PAN_verification_Status__c, Loan__r.Loan_Amount__c, Loan__r.Product__c  from  Applicant__c where Id  =: RecId];
            mandDocsList = [Select Id, Is_PAN_mandatory__c, Is_Form60_mandatory__c, Customer_Type__c from Mandatory_Document__mdt where (Product__c =: appRec.Loan__r.Product__c and Loan_Amount__c <: appRec.Loan__r.Loan_Amount__c) WITH SECURITY_ENFORCED]; 
        }*/
        
        system.debug('mandDocsList'+mandDocsList);
        for(Mandatory_Document__mdt md: mandDocsList){
            DocumentMasterWrapper dmObj = new DocumentMasterWrapper();
            dmObj.isPanRequired = md.Is_PAN_mandatory__c;
            dmObj.isForm60Required = md.Is_Form60_mandatory__c;
            dmObj.customerType = md.Customer_Type__c;
            wrapperObjList.add(dmObj);
        }    

        return wrapperObjList;
    }
    
    //R2-36
    @AuraEnabled
    public static ResponseWrapper coApplicantValidationForTractor(String applicantId){
        ResponseWrapper response = new ResponseWrapper();
        try {
            List<Applicant__c> applicants = [SELECT Id, Total_Monthly_Income_Sum__c, Loan__c, Loan__r.Loan_Amount__c, 
                Loan__r.Final_Exposure__c, Loan__r.Product__c, Bureau_Score__c, Age__c,
                (SELECT Id, Agri_Land_in_Acres__c FROM Applicant_Financials__r WHERE RecordType.DeveloperName='Financial_Parent'
                AND isActive__c=true) FROM Applicant__c WHERE (Id=:applicantId OR Loan__c=:applicantId)
                AND IsInactive__c=false AND RecordType.DeveloperName='Primary_Applicant' AND 
                Loan__r.RecordType.DeveloperName='Tractor' WITH SECURITY_ENFORCED];
            if(!applicants.isEmpty()){
                Applicant__c appl = applicants[0];
                Boolean ageCriteriaSatisfied = appl.Age__c!=null && appl.Age__c>=25 && appl.Age__c<=60?true:false;
                Boolean landCriteriaSatisfied = false;
                if(!appl.Applicant_Financials__r.isEmpty()){
                    landCriteriaSatisfied = appl.Applicant_Financials__r[0].Agri_Land_in_Acres__c>=3?true:false;
                }
                Boolean cibilScoreSatisfied = appl.Bureau_Score__c!=null && Integer.valueOf(appl.Bureau_Score__c)>725?true:false;
                System.debug(LoggingLevel.DEBUG, 'ageCriteriaSatisfied'+ageCriteriaSatisfied);
                System.debug(LoggingLevel.DEBUG, 'cibilScoreSatisfied'+cibilScoreSatisfied);
                System.debug(LoggingLevel.DEBUG, 'landCriteriaSatisfied'+landCriteriaSatisfied);
                if(ageCriteriaSatisfied && landCriteriaSatisfied && cibilScoreSatisfied){
                    response.status = 'success';
                    response.message = 'Hurray! No Co-Applicant Required';
                }else{
                    List<Applicant__c> coAppls = [SELECT Id FROM Applicant__c WHERE Loan__c=:appl.Loan__c AND IsInactive__c=false 
                        AND RecordType.DeveloperName='Co_Applicant' WITH SECURITY_ENFORCED];
                    if(coAppls.isEmpty()){
                        response.status = 'error';
                        response.message = 'Please add Co-Applicant';
                    }
                }
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteApplicant(String applicantRecId){
        Applicant__c app = new Applicant__c();
        app.id = applicantRecId;
        app.IsInactive__c = true;
        update app;
        return app.Id;
    }

    @TestVisible
    public class ResponseWrapper{
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }
    
    public class DocumentMasterWrapper{
        @AuraEnabled
        public Boolean isPanRequired{get;set;}
        @AuraEnabled
        public Boolean isForm60Required{get;set;}
        @AuraEnabled
        public String customerType{get;set;}
        
        public DocumentMasterWrapper(){
            isPanRequired = false;
            isForm60Required = false;        
        }
        
    }
    
    
    
}