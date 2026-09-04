@isTest
public with sharing class BalanceTransferControllerTest {
    
    @TestSetup
    static void makeData(){

        List<Generic_Master__c> financialInstitutes = new List<Generic_Master__c>();
        financialInstitutes.add(createFinancialInstituteRecords('HDFC'));
        financialInstitutes.add(createFinancialInstituteRecords('CANARA'));
        insert financialInstitutes;
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Total_Exposure__c  = 12000
        ),true); 

        Collateral__c collateral = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Vehicle_Cost__c  = 100000,
            Loan__c=loanAppl.Id
        ),true);

        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            Total_Exposure__c  = 12000
        ),true);

        List<Payment__c> payments = new List<Payment__c>();
        payments.add(createBTRecords('Fore Closure Refinance',loanAppl.Id));
        payments.add(createBTRecords('Fore Closure Refinance',loanAppl.Id));
        payments.add(createBTRecords('Top Up',loanAppl.Id));
        insert payments;
    }

    public static Generic_Master__c createFinancialInstituteRecords(String name){
        Generic_Master__c financialInstitute1 = new Generic_Master__c();
        //financialInstitute1.name=name;
        return financialInstitute1;
    }

    public static Payment__c createBTRecords(String status,Id loanId){
        Payment__c pay = new Payment__c();
        pay.POS__c='1000';
        pay.BT_Loan_Status__c=status;
        pay.Loan_Number__c='98765';
        pay.BT_Type__c='Internal';
        pay.Inactive__c=false;
        pay.Loan_Application__c=loanId;
        pay.RecordtypeId=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Balance_Transfer').getRecordTypeId();
        return pay;
    }

    @isTest
    public static void testgetFinancialInstitutes(){
        Test.startTest();
        BalanceTransferController.getFinancialInstitutes();
        Test.stopTest();
    }

    @isTest
    public static void testupsertData(){
        Test.startTest();
        Id loanId = [select id from Loan_Application__c limit 1].id;
        Id collateralId = [select id from Collateral__c limit 1].id;
        List<Payment__c> payments = [select id, POS__c, BT_Loan_Status__c, Loan_Number__c, BT_Type__c, Inactive__c, Loan_Application__c, RecordtypeId from Payment__c];
        List<Id> payId = new List<Id>();
        payId.add(payments[0].id);
        BalanceTransferController.upsertData(payments, loanId, 'Internal', collateralId);
        BalanceTransferController.getInternalBTDetails(loanId,'Internal');
        BalanceTransferController.deleteBT(payId,loanId,'Internal');
        Test.stopTest();
    }
}