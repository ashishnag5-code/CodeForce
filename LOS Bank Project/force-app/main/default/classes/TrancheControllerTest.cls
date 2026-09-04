@isTest
public with sharing class TrancheControllerTest {

    @TestSetup
    static void makeData(){

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345'
        ),true); 

        List<Payment__c> payments = new List<Payment__c>();
        payments.add(createTrancheRecords(1,loanAppl.Id));
        payments.add(createTrancheRecords(2,loanAppl.Id));
        payments.add(createTrancheRecords(3,loanAppl.Id));
        insert payments;
    }

    public static Payment__c createTrancheRecords(Integer trancheNo,Id loanId){
        Payment__c pay = new Payment__c();
        pay.Disbursement_Amount__c=1000;
        pay.Partial_Payment_Condition__c='Condition';
        pay.Tranche_Number__c=trancheNo;
        pay.Inactive__c=false;
        pay.Loan_Application__c=loanId;
        pay.RecordtypeId=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Tranche').getRecordTypeId();
        return pay;
    }

    @isTest
    public static void testTrancheFunctions(){
        Test.startTest();
        List<Payment__c> newList = [SELECT Id, Name, Disbursement_Amount__c, Partial_Payment_Condition__c, Tranche_Number__c, Inactive__c, Loan_Application__c, RecordtypeId FROM Payment__c];
        Id loanId = [SELECT Id from Loan_Application__c][0].Id;
        TrancheController.getVisibleFieldsForLoanDetails('Tranche Details', 'DDE', '');
        TrancheController.upsertData(newList, loanId);
        TrancheController.getTrancheDetails(loanId);
        List<Id> idList = new List<Id>();
        idList.add(newList[0].Id);
        TrancheController.deleteTranche(idList, loanId);
        Test.stopTest();
    }

}