public without sharing class BalanceTransferController {

    @TestVisible
    public class BTRecorddetails{
        @AuraEnabled public List<Payment__c> bTRecordList {get;set;}
        @AuraEnabled public List<Generic_Master__c> instituteList {get;set;}
    }

    @AuraEnabled
    public static List<Generic_Master__c> getFinancialInstitutes(){
        List<Generic_Master__c> financialInstitutes = [Select Id, Name__c, Bank_Name__c from Generic_Master__c where recordtype.DeveloperName='Financial_Institution_Name' WITH SECURITY_ENFORCED];
        return financialInstitutes;
    }


    @AuraEnabled
    public static BTRecorddetails upsertData(List<Payment__c> bt, Id loanId, String type, Id collateralId){
        Integer totalPOSForTopUp=0;
        Integer totalPOSForClosure=0;
        List<SObject> sobjectList = new List<SObject>();
        for(Payment__c pay: bt){
            if(pay.RecordTypeId==null)
            pay.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Balance_Transfer').getRecordTypeId();
            if(type=='Internal' && pay.BT_Loan_Status__c=='Top Up'){
                totalPOSForTopUp = totalPOSForTopUp+Integer.valueOf(pay.POS__c);
            }
            if(type=='Internal' && pay.BT_Loan_Status__c=='Fore Closure Refinance'){
                totalPOSForClosure = totalPOSForClosure+Integer.valueOf(pay.POS__c);
            }
        }

        if(totalPOSForTopUp>0){
            List<Collateral__c> collateral = [Select Id,Final_Vehicle_Cost__c,Vehicle_Cost__c from Collateral__c where id=:collateralId WITH SECURITY_ENFORCED];
            system.debug('collateral'+collateral[0]);
            if(collateral[0].Vehicle_Cost__c==null){
                collateral[0].Vehicle_Cost__c=0;
            }
            collateral[0].Final_Vehicle_Cost__c = collateral[0].Vehicle_Cost__c+totalPOSForTopUp;
            sobjectList.add(collateral[0]);
            
        }
        if(totalPOSForClosure>0 || totalPOSForTopUp>0){
            List<Loan_Application__c> loan = [Select Id,Final_Exposure__c,Total_Exposure__c from Loan_Application__c where id=:loanId WITH SECURITY_ENFORCED];
            if(loan[0].Total_Exposure__c==null){
                loan[0].Total_Exposure__c=0;
            }
            loan[0].Final_Exposure__c = (loan[0].Total_Exposure__c-totalPOSForClosure)+totalPOSForTopUp;
            sobjectList.add(loan[0]);
            Applicant__c applicant = [SELECT Id, Final_Exposure__c,Total_Exposure__c FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.Developername='Primary_Applicant' WITH SECURITY_ENFORCED LIMIT 1];
            if(applicant.Total_Exposure__c==null){
                applicant.Total_Exposure__c=0;
            }
            applicant.Final_Exposure__c = (applicant.Total_Exposure__c-totalPOSForClosure)+totalPOSForTopUp;
            sobjectList.add(applicant);

        }
        if(sobjectList!=null && sobjectList.size()>0){
            update sobjectList;
        }

        upsert bt;
        BTRecorddetails newRecordDetails = new BTRecorddetails();
        newRecordDetails = getInternalBTDetails(loanId, type);

        return newRecordDetails;
    }

    @AuraEnabled
    public static BTRecorddetails getInternalBTDetails(Id recordId, String type){
        BTRecorddetails newRecordDetails = new BTRecorddetails();
        newRecordDetails.bTRecordList = [select Id, Name, POS__c, BT_Loan_Status__c, Loan_Number__c, Loan_Application__c, BT_Amount__c, Financial_Institute_Name__c, NOC_before_Disbursement__c, BT_Type__c from Payment__c where Loan_Application__c=:recordId and Inactive__c=false and Recordtype.DeveloperName='Balance_Transfer' and BT_Type__c=:type WITH SECURITY_ENFORCED];
        newRecordDetails.instituteList = getFinancialInstitutes();
        return newRecordDetails;
    }
    
    @AuraEnabled
    public static List<Payment__c> getInternalBTTopupRecord(Id recordId, String type){
        List<Payment__c> newRecordDetails = [select Id, Name, POS__c, BT_Loan_Status__c, Loan_Number__c, Loan_Application__c, BT_Amount__c, Financial_Institute_Name__c, NOC_before_Disbursement__c, BT_Type__c from Payment__c where Loan_Application__c=:recordId and Inactive__c=false and Recordtype.DeveloperName='Balance_Transfer' and BT_Type__c=:type AND BT_Loan_Status__c = 'Top Up' WITH SECURITY_ENFORCED];
        return newRecordDetails;
    }


    @AuraEnabled
    public static BTRecorddetails deleteBT(List<Id> recordIds, Id loanId, String type){
        integer num=1;
        List<Payment__c> btList = [select Id, Inactive__c from Payment__c where  RecordType.Developername='Balance_Transfer' and Inactive__c=false and id in :recordIds WITH SECURITY_ENFORCED];
        for(Payment__c record:btList){
            record.Inactive__c=true;
        }
              
        update btList;
        BTRecorddetails newRecordDetails = new BTRecorddetails();
        newRecordDetails = getInternalBTDetails(loanId, type);
        return newRecordDetails;
    }
}