/**
    @ Class Name: AUSFLeadDedupeCRMController
    @ Logs:
    @   Last Modified Date  -   Last Modified By    -   Description
    *   12th Oct-2023       -   Sachin              -   R2-28 ( Duplicate loans to be shown on Lead record page )
*/
public without sharing class AUSFLeadDedupeCRMController {
    @AuraEnabled( cacheable = true )
    public static LeadDedupeController.LeadCRMDedupeWrapper[] getDuplicateLoans( String leadId ){
        LeadDedupeController.LeadCRMDedupeWrapper[] dedupeResponse = new LeadDedupeController.LeadCRMDedupeWrapper[0];
        Loan_Application__c leadRecord = [ SELECT Mobile__c, toLabel(Product__c) FROM Loan_Application__c WHERE Id =: leadId WITH SECURITY_ENFORCED ];
        Id currentUserId = UserInfo.getUserId();
        // [ SELECT Name, Branch__c, Owner.Name, toLabel(Product__c) FROM Loan_Application__c WHERE Id IN ( SELECT Loan__c FROM Applicant__c WHERE Mobile_Number__c =: leadRecord.Mobile__c AND Loan__r.Stage__c !=: GlobalConstants.DISBURSED AND IsInactive__c = FALSE ) WITH SYSTEM_MODE ]

        Set<Id> processedLoans = new Set<Id>();
        for( Applicant__c applicant: [
            SELECT Id, Name, Customer_Type__c,Aadhaar_Number__c,PAN__c,CIF_No__c,Voter_Id__c,Passport_Number__c,RecordType.Name,
            Driving_License_Id__c,Loan__r.Account__r.Name,Loan__r.Name,Loan__r.RecordType.Name, RecordTypeId,Loan_Stage__c,
            Loan__r.Loan_Number__c,Loan__r.Application_Number__c, toLabel(Loan__r.Product__c), Loan__r.CreatedDate, Loan__r.Stage__c,
            Loan__r.Loan_Amount__c,Loan__r.Total_Loan_Amount__c,Loan__r.Loan_Sanction_date__c, Loan__r.Branch_Name__c,Loan__r.Customer_Name__c,
            Customer_Name__c, Mobile_Number__c, KYC_Status__c, CreatedById, CreatedBy.MobilePhone,CreatedBy.Name,CreatedDate 
            FROM Applicant__c
            WHERE Mobile_Number__c =: leadRecord.Mobile__c AND Loan__r.Is_Loan_Disbursed__c != TRUE AND IsInactive__c = FALSE AND Loan__c !=: leadId
            WITH SYSTEM_MODE
        ]){
            LeadDedupeController.LeadCRMDedupeWrapper dedupeMatch = new LeadDedupeController.LeadCRMDedupeWrapper();
            dedupeMatch.applicant = applicant;
            dedupeMatch.boolIsSameProduct = applicant.Loan__r.Product__c == leadRecord.Product__c && applicant.CreatedById == currentUserId;
            dedupeMatch.boolIsDiffProductSameRO = applicant.Loan__r.Product__c == leadRecord.Product__c && applicant.CreatedById != currentUserId;

            processedLoans.add( applicant.Loan__c );
            dedupeResponse.add( dedupeMatch );
        }

        map<String, String> loanToApplicantFieldMapping = new map<String, String>{
            'Customer_Name__c' => 'Customer_Name__c',
            'Customer_Type__c' => 'Customer_Type__c',
            'Mobile__c' => 'Mobile_Number__c'
        };

        processedLoans.add( leadId );

        for( Loan_Application__c loanApp: [
            SELECT Id, Name, Loan_Number__c, Mobile__c, Customer_Type__c, Branch_Name__c,
            Customer_Name__c, toLabel( Product__c ), Stage__c, Loan_Amount__c,
            CreatedDate, CreatedBy.Name, CreatedBy.MobilePhone
            FROM Loan_Application__c
            WHERE Id NOT IN: processedLoans AND Mobile__c =: leadRecord.Mobile__c AND Is_Loan_Disbursed__c != TRUE
            WITH SYSTEM_MODE
        ]){
            
            LeadDedupeController.LeadCRMDedupeWrapper dedupeMatch = new LeadDedupeController.LeadCRMDedupeWrapper();
            dedupeMatch.applicant = mapAsApplicantObject( loanApp, loanApp.CreatedBy, loanToApplicantFieldMapping );
            dedupeMatch.boolIsSameProduct = loanApp.Product__c == leadRecord.Product__c && loanApp.CreatedById == currentUserId;
            dedupeMatch.boolIsDiffProductSameRO = loanApp.Product__c == leadRecord.Product__c && loanApp.CreatedById != currentUserId;

            dedupeResponse.add( dedupeMatch );
        }

        return dedupeResponse;
    }

    public static Applicant__c mapAsApplicantObject( Loan_Application__c loan, User ownerDetails, map<String, String> loanToApplicantMapping ){
        Applicant__c applicant = new Applicant__c();
        for(String field: loanToApplicantMapping.keySet() ){
            applicant.put( loanToApplicantMapping.get(field), loan.get( field ) );
        }
        applicant.Loan__r = loan;
        // applicant.CreatedBy = ownerDetails;
        return applicant;
    }
}