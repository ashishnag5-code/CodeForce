@isTest
public class LosLeadCreateWizardControllerTest {
    public static String branchMasterName='1111';
    public static String orgId = UserInfo.getOrganizationId();
    
    @testSetup 
    static void testDataSetup() {
        Profile prof = [select id from profile where name LIKE '%TCU%' limit 1];
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = prof.id,
            username = 'test'+orgId+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = branchMasterName
        ),true);
        
        /*
        Branch_Master__c brMaster = (Branch_Master__c)TestFactory.createSObject(new Branch_Master__c(
            Name = branchMasterName,
            Location_Name__c = 'Test Location'
        ),true);
        */
        
        Account brMaster = (Account)TestFactory.createSObject(new Account(
            Name = branchMasterName,
            Account_Code__c = branchMasterName,
            Account_Name__c = 'Test Location'
        ),true);
    }
    
    @isTest 
    static void getBranchMasterTest(){
        //User usr = [Select Id from User limit 1];
        
        test.startTest();
         System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
        }
        test.stopTest();
        
    }
    
    @isTest 
    static void createLeadRecordTest(){
        //User usr = [Select Id from User limit 1];
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Follow_Up_Date__c = System.today(),
            Follow_Up_Time__c = Time.newInstance(1, 2, 3, 4),
            RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.FOURWHEELER ),
            Mobile__c = '98749837493',
            Product__c = '10201'
        ),false);
        
        test.startTest();
         System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
            LosLeadCreateWizardController.createLeadRecord(loanAppl);
            LosLeadCreateWizardController.getCampaigns();
            LosLeadCreateWizardController.fetchBranchMasterRecord('Dealer', 'New Dealer', '10201', 'Personal', 'Delhi');
        }
        test.stopTest();
    }

    @isTest static void verifyVehicleCollateralTypeOptions(){ //NOPMD - dependent on custom mdt
        Test.startTest();
        LosLeadCreateWizardController.getCollateralTypeOptions( '10201' );
        Test.stopTest();
    }

    @isTest static void verifyVehicleUsageOptions(){ //NOPMD - dependent on custom mdt
        Test.startTest();
        LosLeadCreateWizardController.getVehicleUsageOptions( '10201', '10108' );
        Test.stopTest();
    }

    
}