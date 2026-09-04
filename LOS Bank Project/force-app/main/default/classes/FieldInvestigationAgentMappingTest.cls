/* 
* Source Class : FieldInvestigationAgentMappingController
* Last Modified : July-14-2023
*/

@isTest
public with sharing class FieldInvestigationAgentMappingTest {
        @testsetup
    static void testDataSetup(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10202',
            ROI__c = 17.0,
            EMI__c = 13
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Name__c = 'Vikash Kumar Mandal',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10
        ),true);
        
        Address__c testAddressRec = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Current'
            
        ),true);
        Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Address_lookup__c=testAddressRec.id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            FI_Agent__c = getFIUserId(),
            Applicant_Type__c='Applicant' )),true);
    }
    
    private static User getCreditUser(){
        return [SELECT Id FROM User Where Profile.Name = 'Credit Manager' and IsActive=true LIMIT 1];
    }
    
    private static String getFIUserId(){
        return [SELECT Id FROM User Where Profile.Name = 'Field Investigator' LIMIT 1].Id;
    }
    
    @IsTest
    public static void testUpdateOwner(){
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Field Investigator' LIMIT 1].Id;
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        User creditManager = getCreditUser();
        Id loanId = [SELECT Id FROm Loan_Application__c LIMIT 1].Id;
        Id fiId = [SELECT Id FROm Field_Investigation__c LIMIT 1].Id;
        System.runAs(creditManager){
            Test.startTest();
            system.debug('id->'+loanId+' '+fiId+' '+usr.Id);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapper = FieldInvestigationAgentMappingController.updateOwner(usr.Id, new List<String>{fiId}, null, loanId);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapperCM = FieldInvestigationAgentMappingController.updateOwner('', new List<String>{fiId}, creditManager.Id, loanId);
            system.assertEquals(retWRapper!=null, true);
            Test.stopTest();
            
        }        
    }

    @IsTest
    public static void testUpdateOwnerException(){
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Field Investigator' LIMIT 1].Id;
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        User creditManager = getCreditUser();
        Id loanId = [SELECT Id FROm Loan_Application__c LIMIT 1].Id;
        Id fiId = [SELECT Id FROm Field_Investigation__c LIMIT 1].Id;
        System.runAs(creditManager){
            Test.startTest();
            system.debug('id->'+loanId+' '+fiId+' '+usr.Id);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapper = FieldInvestigationAgentMappingController.updateOwner(usr.Id, new List<String>{fiId}, null, loanId);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapperCM = FieldInvestigationAgentMappingController.updateOwner('', new List<String>{fiId}, null, loanId);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapperCM1 = FieldInvestigationAgentMappingController.updateOwner('', new List<String>{fiId}, null, fiId);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapperCMError = FieldInvestigationAgentMappingController.updateOwner('', new List<String>{fiId}, null, null);
            system.assertEquals(retWRapper!=null, true);
            Test.stopTest();
            
        }        
    }
    
    @IsTest
    public static void testGetRelatedFI(){
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        //User creditManager = getCreditUser();
        Id loanId = [SELECT Id FROm Loan_Application__c LIMIT 1].Id;
        Id applicantId = [SELECT Id FROm Applicant__c LIMIT 1].Id;
        System.runAs(usr){
            Test.startTest();
            FieldInvestigationAgentMappingController.ResultWrapper retWRapper = FieldInvestigationAgentMappingController.getRelatedFI(loanId,'Loan_Application__c');
            system.assertEquals(retWRapper!=null, true);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapper2 = FieldInvestigationAgentMappingController.getRelatedFI(applicantId,'Applicant__c');
            system.assertEquals(retWRapper2!=null, true);
            FieldInvestigationAgentMappingController.ResultWrapper retWRapper3 = FieldInvestigationAgentMappingController.getRelatedFI(loanId,'Applicant__c');
            system.assertEquals(retWRapper3!=null, true);
            Test.stopTest();
            
        }    
        
    }
}