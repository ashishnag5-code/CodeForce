@isTest
public class KarzaPennyDropControllerTest {
    
    @testSetup static void setup() {
        //Karza Integration Master
        Integration_Master__c KarzaPennyDrop = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Karza Penny Drop',
            End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/SFDCKarza/BankAccVerification?',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Account  accountInstance = (Account)TestFactory.createSObject(new Account(
            Name='ParentAccount',
            Grading__c ='Platinum-Certified',
            Certified_Value__c = 'Yes'
        ),true);
        
        Account  accountChildInstance = (Account)TestFactory.createSObject(new Account(
            Name='childAccount',
            State__c=accountInstance.Id
        ),true);
        
        //Scheme Insertion
        Scheme_Master__c scheme = (Scheme_Master__c )TestFactory.createSObject(new Scheme_Master__c (
            Scheme_Name__c ='Normal',
            Type_of_loan__c ='Used'
        ),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
            Branch_Master__c =accountChildInstance.Id,
            Scheme__c =scheme.Id,
            Dealer_Master__c = accountInstance.Id
        ),true);
        
    }
    
    @isTest
    public static void karzaCallout(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c,Branch_Master__r.State__r.Name,Scheme__r.Scheme_Name__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new KarzaPennyDropCalloutMock());
        KarzaPennyDropController.karzaPennyDropCallOut('AUBL0002493','352352',loanInstance.Id);
        System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        Test.stopTest();        
    }
}