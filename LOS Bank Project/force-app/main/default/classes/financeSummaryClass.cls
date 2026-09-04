public with sharing class financeSummaryClass {
    
    
    @AuraEnabled
    public static List<summaryWrapper> getSummaryDetails(String loanId){
        List<summaryWrapper> wrapperList = new List<summaryWrapper>();                                                          
        
        try {
            List<Applicant_Financials_Details__c> financeDetails = [SELECT Id,Applicant__c,isActive__c,Applicant__r.Loan__r.Stage__c,Applicant__r.Loan__c,Applicant__r.First_Name__c ,Applicant__r.Last_Name__c,Applicant__r.RecordType.Name,Method_Of_Assesment__c,Monthly_Income__c,Monthly_Obligation__c,Other_Income__c,RecordType.DeveloperName
                                                                    FROM Applicant_Financials_Details__c
                                                                    WHERE Applicant__r.Loan__c=:loanId 
                                                                    AND RecordType.DeveloperName='Financial_Parent'
                                                                    AND isActive__c = true
                                                                    WITH SECURITY_ENFORCED];
                                                                     
        if(!financeDetails.isEmpty()){
            for(Applicant_Financials_Details__c financeInstance : financeDetails){
                summaryWrapper wrapperInstance = new summaryWrapper();     
                wrapperInstance.applicantId = (financeInstance.Applicant__c!=null)?financeInstance.Applicant__c:'';
                wrapperInstance.applicantName = ((financeInstance.Applicant__r.First_Name__c!=null)?financeInstance.Applicant__r.First_Name__c :'') +' ' + ((financeInstance.Applicant__r.Last_Name__c!=null? financeInstance.Applicant__r.Last_Name__c :''));
                wrapperInstance.Ownership = (financeInstance.Applicant__r.RecordType.Name!=null)?financeInstance.Applicant__r.RecordType.Name :'';
                wrapperInstance.MtAssessment = (financeInstance.Method_Of_Assesment__c!=null)?financeInstance.Method_Of_Assesment__c :'';
                wrapperInstance.TotalMonthlyIncome = ((financeInstance.Monthly_Income__c!=null)?financeInstance.Monthly_Income__c :0) + ((financeInstance.Other_Income__c!=null)?financeInstance.Other_Income__c :0);
                wrapperInstance.MonthlyObligation = (financeInstance.Monthly_Obligation__c!=null)?financeInstance.Monthly_Obligation__c :0;
                wrapperList.add(wrapperInstance);
            }
        }                                                                    
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperList;
    }


    public class summaryWrapper{
        @AuraEnabled public String applicantId{get;set;}
        @AuraEnabled public String applicantName{get;set;}
        @AuraEnabled public String Ownership{get;set;}
        @AuraEnabled public String MtAssessment{get;set;}
        @AuraEnabled public Decimal TotalMonthlyIncome{get;set;}
        @AuraEnabled public Decimal MonthlyObligation{get;set;}
        
        public summaryWrapper(){
            applicantId='';
            applicantName ='';
            Ownership ='';
            MtAssessment ='';
            TotalMonthlyIncome =0;
            MonthlyObligation =0;
        }
    }
}