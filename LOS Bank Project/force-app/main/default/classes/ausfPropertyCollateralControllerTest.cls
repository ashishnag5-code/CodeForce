@isTest
public class ausfPropertyCollateralControllerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id
        ),true);
    }
    @isTest public static void getPropertyCollateralsTest(){
        
        	Loan_Application__c loanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
        	String collateralType = 'New';
        test.startTest();	
        	ausfPropertyCollateralController.getPropertyCollaterals(loanApplication.Id,collateralType);
        test.stopTest();
    }
    @isTest public static void upsertManualCollateralTest(){
        Loan_Application__c loanApplication = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Collateral__c collateralObj = new Collateral__c();
        collateralObj.Loan__c  = loanApplication.Id;
        insert collateralObj;
		test.startTest();
        	ausfPropertyCollateralController.upsertManualCollateral(collateralObj);
		test.stopTest();        
        
    }
    @isTest public static void upsertManualCollateralNegativeTest(){
       
        Collateral__c collateralObj = new Collateral__c();
		test.startTest();
        	ausfPropertyCollateralController.upsertManualCollateral(collateralObj);
		test.stopTest();        
        
    }
}