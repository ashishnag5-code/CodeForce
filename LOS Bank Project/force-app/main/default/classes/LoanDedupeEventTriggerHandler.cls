/**
    @ Class Name: LoanDedupeEventTriggerHandler
    @ Logs:
    @   Last Modified Date  -   Last Modified By    -   Description
    *   12th Oct-2023       -   Sachin              -   R2-28 ( Validates a new lead coming in the system with any of the existing leads / loans if its a duplicate )
*/
public with sharing class LoanDedupeEventTriggerHandler {
    public static void validateLeadDedupe( Loan_Dedupe__e[] loanDedupes ){
        Set<Id> leadIds = new Set<Id>();
        for( Loan_Dedupe__e ld: loanDedupes ){
            // Currently we do dedupe based on Mobile number only later it can be extended
            if( ld.Type__c == 'Mobile' ){
                leadIds.add( ld.Record_Id__c );
            }
        }

        map<String, Id[]> mobileToLoanIds = new map<String, Id[]>();
        for( Loan_Application__c loan: [
            SELECT Id, Mobile__c
            FROM Loan_Application__c WHERE Id IN: leadIds WITH SYSTEM_MODE
        ]){
            if( !mobileToLoanIds.containsKey( loan.Mobile__c ) ){
                mobileToLoanIds.put( loan.Mobile__c, new Id[0] );
            }
            mobileToLoanIds.get( loan.Mobile__c ).add( loan.Id );
        }

        Set<Loan_Application__c> duplicateLeads = new Set<Loan_Application__c>();
        Set<String> mobileNumbers = mobileToLoanIds.keySet();

        // Existing Loan Parties - Applicant, Co-Applicant, Guarantor, BO etc
        for(Applicant__c applicant: [ SELECT Id, Mobile_Number__c FROM Applicant__c WHERE IsInactive__c = FALSE AND Mobile_Number__c IN: mobileNumbers AND Loan__c NOT IN: leadIds WITH SYSTEM_MODE ] ){
            for( String loanId :  mobileToLoanIds.get( applicant.Mobile_Number__c ) ){    
                duplicateLeads.add(
                    new Loan_Application__c(
                        Id = loanId,
                        Is_Duplicate__c = true
                    )
                );
            }
        }

        // Existing leads with same mobile number
        for( Loan_Application__c loanApp: [ SELECT Mobile__c FROM Loan_Application__c WHERE Mobile__c IN: mobileNumbers AND Id NOT IN: leadIds WITH SYSTEM_MODE ] ){
            for( String loanId :  mobileToLoanIds.get( loanApp.Mobile__c ) ){    
                duplicateLeads.add(
                    new Loan_Application__c(
                        Id = loanId,
                        Is_Duplicate__c = true
                    )
                );
            }
        }

        Database.SaveResult[] results = Database.update( new List<Loan_Application__c>( duplicateLeads ), false );
        Object[] errors = new Object[0];

        for( Database.SaveResult sr: results ){
            if( !sr.isSuccess() ){
                for( Database.Error er: sr.getErrors() ){
                    errors.add(
                        new map<Id, String>{
                            sr.getId() => er.getMessage()
                        }
                    );
                }
            }
        }

        if( !errors.isEmpty() ){
            Log.error( JSON.serialize(errors), Log.SeverityType.valueOf( GlobalConstants.SEVERITYTYPE_HIGH ), null );
        }
    }
}