/**
* @description       : 
* @author            : Gaurav Gaur | Salesforce
* @group             : 
* @last modified on  : 05-01-2023
* @last modified by  : Gaurav Gaur | Salesforce
**/
@isTest
public class CIBIL_Summary_Controller_Test {
    @testSetup static void setup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Aadhaar_Number__c   ='847972755528',
            Loan__c =loanAppl.Id
            
        ),true);
        Bureau_Results__c  brRslt = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c(
            Name = 'CIBIL Score',
            Bureau__c = 'CIBIL',
            Applicant__c = appl.Id
        ),true);
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Stability__c='2',
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow',
            Source_Type__c = 'CIBIL',
            Bureau_Results__c = brRslt.id
        ),true);
        Bank_Account_Records__c barInstance1 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Unsecured',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual'
            
            ),true);
        Bank_Account_Records__c barInstance2 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Unsecured',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Joint'
            
            ),true);
         Bank_Account_Records__c barInstance3 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Unsecured',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Guarantor'
            
            ),true);
        Bank_Account_Records__c barInstance4 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Auto',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual'
            
            ),true);
        Bank_Account_Records__c barInstance5 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Auto',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Joint'
            
            ),true);
        Bank_Account_Records__c barInstance6 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Auto',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Guarantor'
            
            ),true);
        Bank_Account_Records__c barInstance7 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Housing',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual'
            
            ),true);
        Bank_Account_Records__c barInstance8 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Housing',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Joint'
            
            ),true);
        Bank_Account_Records__c barInstance9 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Housing',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Guarantor'
            
            ),true);
         Bank_Account_Records__c barInstance10 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Others',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual'
            
            ),true);
        Bank_Account_Records__c barInstance11 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Others',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Joint'
            
            ),true);
        Bank_Account_Records__c barInstance12 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Bureau_Results__c = brRslt.id,
            Type_of_Loan__c = 'Others',
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Guarantor'
            
            ),true);
        
    }
    
    @isTest 
    static void cibilSummaryTestMethod(){    
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        PageReference pageRef = Page.CIBIL_Summary;
        pageRef.getParameters().put('id', appl.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.standardController(appl);
        Test.startTest(); 
        CIBIL_Summary_Controller cblSummry = new CIBIL_Summary_Controller(standardController);
        cblSummry.getHighestDpdFromList(new List<String>{'100','200'});
        cblSummry.getHighestDpdFromList(new List<String>{'SMA','100','200'});
        Test.stopTest();
    }             
}