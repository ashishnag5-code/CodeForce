public without sharing class AUSFLoanApplication_WithoutSharing {
    public static Loan_Application__c[] updateLoanApp( Loan_Application__c[] applications ){
        update applications;

        return applications;
    }
    public static void unlockApprovals( Loan_Application_Approval__c[] approvals ){
        Approval.unlock( approvals );
    }

    public static List<sObject> getRecords(String query){
        return Database.query(query);
    }

    // Update sObject List in Without Sharing
    public static SObject[] updateSObjectRecs( SObject[] sObjectsRecs){
        update sObjectsRecs;
        return sObjectsRecs;
    }
}