public with sharing class AccountQueueAssignmentController {
    @AuraEnabled(cacheable = true)
    public static Account getAccountDetails(Id accId){
        try {
            return [SELECT Id,Name,X4WH_New_Disbursement_Author_Queue__c,X4WH_New_Disbursement_Maker_Queue__c,
            X4WH_Used_COW_Disbursement_Author_Queue__c,X4WH_Used_COW_Disbursement_Maker_Queue__c,
            Commercial_New_Disbursement_Author_Queue__c,Commercial_New_Disbursement_Maker_Queue__c,
            Commercial_Used_COW_Disburse_Maker_Queue__c,Commercial_Used_COW_Disburse_Auth_Queue__c,
             PDD_Author_Queue_All_Products__c,PDD_Maker_Queue_All_Products__c,
            Tractor_Used_COW_Disburse_Author_Queue__c,Tractor_Used_COW_Disburse_Maker_Queue__c,
            Tractor_New_Disbursement_Author_Queue__c,Tractor_New_Disbursement_Maker_Queue__c,
            TW_Disbursement_Author_Queue__c,TW_Disbursement_Maker_Queue__c,RPC_FT_RIT_Queue__c,KYC_All_Products__c FROM Account WHERE Id =: accId][0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled(cacheable = true)
    // public static Map<String,Group> getQueueDetails(List<String> queueName){
    //     try {
    //         Map<String,Group> queueMap = new Map<String,Group> ();
    //         for(Group gp : [SELECT Id,Name FROM Group WHERE Type='Queue' AND Name IN :queueName]){
    //             queueMap.put(gp.Name, gp);
    //         }
    //         return queueMap;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
}