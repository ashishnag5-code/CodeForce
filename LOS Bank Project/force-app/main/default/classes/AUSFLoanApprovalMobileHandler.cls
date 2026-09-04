public without sharing class AUSFLoanApprovalMobileHandler {

    @AuraEnabled
    public static String getLoanAppRecord(String strApprovalId){
        try{
            Boolean boolCreateShareRecord;
            List<Loan_Application_Approval__c> objAssignment = [Select Id,Loan_Application__c from Loan_Application_Approval__c where Id = :strApprovalId 
                                            WITH SECURITY_ENFORCED limit 1];
            
            return objAssignment[0].Loan_Application__c;
        }
         catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            return null;
        }
    }
}