public with sharing class RejectPDFController {
    
    public static List<Generic_Master__c> objGenericMaster{get;set;}
    
    
    public static RejectPDFWrapper getPDFWrapperData() {
        //objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where 
                  //          Letter_Name__c = 'Reject Letter'];
        RejectPDFWrapper pdfData = new RejectPDFWrapper();
        String loanApplicationId = System.currentPagereference().getParameters().get('applicationId');
        if(String.isBlank(loanApplicationId)) {
            return null;
        }
        
        pdfData.currentDate = setTodaysDate();
        
        List<Applicant__c> loanApplicationApplicant = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Loan__c, Loan__r.Rejection_Reason__c, Loan__r.Name,
                                                       (SElECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c, Pincode__c, Applicant__c, Address_Type__c
                                                        FROM Addresses__r WHERE Address_Type__c = 'Current' LIMIT 1) FROM Applicant__c WHERE Loan__c=:loanApplicationId LIMIT 1
                                                      ];
                    pdfData.loanNumber = loanApplicationApplicant[0].Loan__r.Name;

        if(!loanApplicationApplicant.isEMpty()){
            pdfData.applicantName = setApplicantName(String.valueOf(loanApplicationApplicant[0].First_Name__c), 
                                                     String.valueOf(loanApplicationApplicant[0].Middle_Name__c), 
                                                     String.valueOf(loanApplicationApplicant[0].Last_Name__c));
            pdfData.loanNumber = loanApplicationApplicant[0].Loan__r.Name;
            if(!loanApplicationApplicant[0].Addresses__r.isEmpty()){
                pdfData.currentAddress = nullCheckAndSetPDFData(loanApplicationApplicant[0].Addresses__r[0].Address_Line_1__c);
                pdfData.currentAddressCity = nullCheckAndSetPDFData(loanApplicationApplicant[0].Addresses__r[0].City__c);
                pdfData.currentAddressState = nullCheckAndSetPDFData(loanApplicationApplicant[0].Addresses__r[0].State__c);
                
            }
            pdfData.rejectionReason = loanApplicationApplicant[0].Loan__r.Rejection_Reason__c;
        }
        return pdfData;
    } 
    
    
    public class RejectPDFWrapper{
        public String currentDate{get;set;}
        public String applicantName{get;set;}
        public String currentAddress{get;set;}
        public String currentAddressCity{get;set;}
        public String currentAddressState{get;set;}
        public String rejectionReason{get;set;}
        public String loanNumber{get;set;}
    }
    
    private static String setTodaysDate() {
        Date todaysDate = System.today();
        return (String.valueOf(todaysDate.day())+'/'+String.valueOf(todaysDate.month())+'/'+String.valueOf(todaysDate.year()));
    }
    
    private static String setApplicantName(String firstName, String middleName, String lastName) {
        return ((String.isBlank(firstName) ? '' : firstName+' ') +(String.isBlank(middleName) ? '' : firstName+' ')+(String.isBlank(lastName) ? '' : lastName+' '));
    }
    
     private static String nullCheckAndSetPDFData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
    }



}