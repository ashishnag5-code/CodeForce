@isTest
public with sharing class CibilScoreViwerUsingLinkControllerTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Disbursement_Date__c = System.today()-60
        ),true);
        Collateral__c  collRec = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Collateral_ID__c ='102010000000001',
                    Loan__c   = loanAppl.Id
                ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIBIL_Status__c ='Completed',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Bureau_Results__c  brRslt = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c(
            Name = 'CIBIL Score',
            Bureau__c = 'CIBIL',
            Applicant__c = appl.Id
        ),true);

        ContentVersion contentVersionObj = (ContentVersion)TestFactory.createSObject(new 
            ContentVersion(VersionData = Blob.valueOf('Test Data'),Title = 'PDTelePD Questionare',ContentLocation= 's',
                PathOnClient='testCases.txt',
                FirstPublishLocationId = brRslt.Id), true);

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
            Same_As__c ='Permanent',
            Deemed__c = true
        ),true);
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'SMS Notification',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralModificationRestService/Modification',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }

    @isTest static void batchclass() {
        Applicant__c app = [SELECT id, Customer_Name__c, First_Name__c, 
        Middle_Name__c, Last_Name__c, 
        Mobile_Number__c, Email__c, Loan__c, RecordType.Name, CIF_No__c,IsEmailVerified__c
        FROM Applicant__c limit 1];
        Bureau_Results__c br = [Select id from Bureau_Results__c limit 1];
        contentdocumentLink cv = [select id, contentdocumentId from contentdocumentLink where linkedentityId =:br.Id];
        Test.startTest();
        string str = cibilScoreViwerUsingLinkController.contentData(cv.contentdocumentId);
        string str1 = cibilScoreViwerUsingLinkController.postFeed(cv.contentdocumentId,UserInfo.getUserId());
        Test.stopTest();
    }
}