@isTest
public class AddressTriggerTest {
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
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id
            
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
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow',
            Same_As__c ='Permanent'
        ),true);
    
        Address__c  addInstanc2 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline112',
            Address_Line_2__c ='TestAddressline222',
            Address_Line_3__c ='TestAddressline332',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Office',
            Type__c='Bungalow',
            Same_As__c ='Office'
        ),true);
        Address__c  addInstanc3 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline112',
            Address_Line_2__c ='TestAddressline222',
            Address_Line_3__c ='TestAddressline332',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Touch Point',
            Type__c='Bungalow'
        ),true);
        
        
       
        
      
        
    }


    @isTest static void getAddress() {
        Address__c addInstance = [SELECT id,Address_Line_1__c,Same_As__c FROM Address__c WHERE Address_Line_1__c='TestAddressline1'];
        Test.startTest();
        addInstance.Address_Line_1__c='TestLine1';
        update addInstance;
        AddressTriggerService ats=new AddressTriggerService();        
        ats.beforeInsert(new List<sObject>() );
        ats.afterUpdate(new List<sObject>() , new Map<Id,sObject>() ,new Map<Id,sObject>() );
        ats.beforeDelete(new Map<Id,sObject>() );
        ats.afterDelete(new Map<Id,sObject>() );
        ats.afterUndelete(new Map<Id,sObject>() );        
       // System.assertEquals('TestAddressline1', addInstance.Address_Line_1__c,'AssertMsg');
        Test.stopTest();
    }

    
}