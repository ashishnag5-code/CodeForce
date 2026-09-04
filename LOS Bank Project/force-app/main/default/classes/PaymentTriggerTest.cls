/*******************************************************************************************
 * @Name         PaymentTriggerTest
 * @Author       Samridhi
 * @Description  TestClass for PaymentTrigger Service and Handler
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Samridhi        19/10/2023         Initial Creation
 *                  Mohit M.        Nov-03-2023        SFAU-5483 - Invalid Account Number - Add before Insert and Before Update
 */ 
@isTest
public class PaymentTriggerTest {
    @testSetup static void setup() {
        // Create test data
        
        
        IFSC_Master__c ifscMaster = new IFSC_Master__c (Name = 'Test IFSC', ifsc__c = 'TEST01234');
        insert ifscMaster;
        
        Location_Master__c locMaster = new Location_Master__c(Name = '441601', State__c = 'MAHARASHTRA');
        insert locMaster;
        
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account account = new Account (RecordTypeId = AccRecordTypeId, Account_Name__c = 'Account Test', 
                                       Name = 'Account Test', Bank_Name__c = 'Test Bank LoanApp Acc', 
                                       IFSC_Code__c = 'TEST01234', Pincode__c = locMaster.Id);
        insert account;
        
        //Dealer_Master__c dealMaster = new Dealer_Master__c(Name = 'Test DM');
        //insert dealMaster;
        
        Id GMRecordTypeIdpf = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Generic_Master__c genericMasterpf = new Generic_Master__c(RecordTypeId = GMRecordTypeIdpf, Bank_Name__c  = 'Test Bank', Type__c = 'CSD',State__c = 'MAHARASHTRA');
        insert genericMasterpf;
        
        Id GMRecordTypeIdbm = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId();
        Generic_Master__c genericMasterbm = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank LoanApp Acc');
        insert genericMasterbm;
        
        Generic_Master__c genericMasterbm1 = new Generic_Master__c(RecordTypeId = GMRecordTypeIdbm, Bank_Name__c  = 'Test Bank');
        insert genericMasterbm1;
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        Id LoanAppRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanApp1 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 1', Product__c = '10301', Loan_Amount__c = 10000, Sourcing_Channel__c = 'Commercial Associate Without Rc Limit' ,
            Total_Charges__c = 2500, Dealer_Master__c = account.Id, Branch_Master__c = account.Id,
            Promo_Code__c = genericMasterpf.Id);
        loanApps.add(loanApp1);
        
        Loan_Application__c loanApp2 = new Loan_Application__c(
            Customer_Name__c = 'Test Customer 2', Product__c = '10303', Loan_Amount__c = 10000,Sourcing_Channel__c = 'Commercial Associate Without Rc Limit' ,
            Dealer_Master__c = account.Id, Branch_Master__c = account.Id, Promo_Code__c = genericMasterpf.Id);
        loanApps.add(loanApp2);
        insert loanApps;
        
        Loan_Application_Approval__c loanAppAppr = new Loan_Application_Approval__c();
        loanAppAppr.Loan_Application__c = loanApp2.Id;
        loanAppAppr.Archived__c = false;
        loanAppAppr.Approval_Type__c = 'OEMApproval';
        insert loanAppAppr;

        Id newColl = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();        
        Collateral__c objCollaterals = new Collateral__c();
        objCollaterals.Loan__c = loanApp2.Id;
        objCollaterals.Collateral_Name__c = '10133';
        objCollaterals.RecordTypeId = newColl;
        insert objCollaterals;
        
        Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c pf = new Payment__c(
            RecordTypeId = PaymentRecordTypeId3, 
            Name__c = 'Test Payment', 
            Net_Amount__c = 123.45,
            Payment_Recipient__c = 'Customer',
            Loan_Application__c = loanApp2.Id,
            Inactive__c = false);
        Database.SaveResult sr3 = Database.insert(pf);
        insert new Trigger_Deactivation_Settings__c(Payment_Trigger__c = false);
    }
    
    @IsTest
    static void testGetPaymentFavouringsTest2() {
        List<Payment__c> payments = [SELECT Id FROM Payment__c where RecordType.Name = 'Payment Favouring'];
        Test.startTest();
            String payFavId = payments[0].Id;
            update new Payment__c(Id = payFavId, Payment_Mode__c = 'TA');
            PaymentTriggerService obj = new PaymentTriggerService();
            obj.afterInsert( new List<sObject>() ,new Map<Id,sObject>());
            obj.beforeDelete(new Map<Id,sObject>());
            obj.afterDelete(new Map<Id,sObject>());
            obj.afterUndelete(new Map<Id,sObject>());
        Test.stopTest();
    }

    @IsTest
    static void testGetPaymentFavouringsTest() {
        List<Payment__c> payments = [SELECT Id FROM Payment__c where RecordType.Name = 'Payment Favouring'];
        Test.startTest();
            String payFavId = payments[0].Id;
            update new Payment__c(Id = payFavId, Payment_Mode__c = 'NEFT');
        Test.stopTest();
    }

    @IsTest
    static void testInsertPaymentFavouringsTest() {
        Test.startTest();
            List<Loan_Application__c> lstLA = [Select Id from Loan_Application__c limit 1];
            Id PaymentRecordTypeId3 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
            Payment__c pf = new Payment__c(
                RecordTypeId = PaymentRecordTypeId3, 
                Name__c = 'Test Payment', 
                Net_Amount__c = 123.45,
                Payment_Recipient__c = 'Customer',
                Loan_Application__c = lstLA[0].Id,
                Account_Number__c = '\'07862560001756',
                Inactive__c = false);
            insert pf;
            Payment__c objPayment = [Select Id, Account_Number__c from Payment__c where Id =: pf.Id];
            
            system.assertEquals('07862560001756',objPayment.Account_Number__c);
            objPayment.Account_Number__c = '\'07862560001757';
            update objPayment;
            objPayment = [Select Id, Account_Number__c from Payment__c where Id =: pf.Id];
            system.assertEquals('07862560001757',objPayment.Account_Number__c);
        Test.stopTest();
    }
    
    @IsTest
    static void testOEMPaymentFavouringsTest2() {
        List<Payment__c> payments = [SELECT Id FROM Payment__c where RecordType.Name = 'Payment Favouring'];
        Test.startTest();
            String payFavId = payments[0].Id;
            update new Payment__c(Id = payFavId, Payment_Recipient__c = 'Dealer');
            update new Payment__c(Id = payFavId, Payment_Recipient__c = 'Dealer', Inactive__c = true);
            PaymentTriggerService obj = new PaymentTriggerService();
            obj.afterInsert( new List<sObject>() ,new Map<Id,sObject>());
            obj.beforeDelete(new Map<Id,sObject>());
            obj.afterDelete(new Map<Id,sObject>());
            obj.afterUndelete(new Map<Id,sObject>());
            Set<Id> setId = new Set<Id>();
            setId.add(payments[0].Id);
            PaymentTriggerService.archiveOEMApprovals(setId);
        Test.stopTest();
    }
}