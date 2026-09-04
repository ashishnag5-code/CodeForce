@isTest
public class Ausfb_RelatedApplicantTest {
    @testSetup static void setup() {
        //Loan Application Insertion
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
            Loan_Amount__c  = 1000000,
            Product__c='10201',//Auto Loan (New)',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Total_Loan_Amount__c =1000000
        ),true);

        Loan_Application__c loanApplTractor = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'TR-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000000,
            Product__c='10201',//Auto Loan (New)',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            Total_Loan_Amount__c =1000000,
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId()
        ),true);

        Applicant__c applTractor = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Advik',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanApplTractor.Id,
            DOB__c = Date.newInstance(1998,09,09),
            Bureau_Score__c = '728',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Applicant_Financials_Details__c applFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c = applTractor.Id,
            Agri_Land_in_Acres__c = 3,
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId()
        ),true);
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        insert lstLoanAppApproval;
         
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id
        ),false);
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Applicant__c coAppl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Nishant',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanApplTractor.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true);

         Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
         
         AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = accInstance.id, Active__c = true, UserId =usr.id
        ),true);
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        /*Id collateralNewRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
    	Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Collateral__c coll2 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralNewRecordTypeId , Manufacture_year_month__c='202304'
        ),true);
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralUsedRecordTypeId,Manufacture_year_month__c='202304'
        ),true);*/
    } 
 
    @isTest
    public static void getLADetailsTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, RecordType.DeveloperName FROM Loan_Application__c WHERE RecordType.DeveloperName!='Tractor' limit 1];
                Ausfb_RelatedApplicantController.getApplicants(loan.Id);
                System.assertNotEquals('Tractor', loan.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

    @isTest
    public static void getApplicantTest(){
        Test.startTest();
        Applicant__c app = [SELECT Id FROM Applicant__c limit 1];
        Ausfb_RelatedApplicantController.getApplicant(app.Id);
        //System.assertNotEquals('Tractor', loan.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

    @isTest
    public static void deleteApplicantTest(){
        Test.startTest();
        Applicant__c app = [SELECT Id, RecordType.DeveloperName FROM Applicant__c WHERE RecordType.DeveloperName='Co_Applicant'];
        Ausfb_RelatedApplicantController.deleteApplicant(app.Id);
        System.assertEquals('Co_Applicant', app.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

    @isTest
    public static void coApplicantValidationForTractorTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, RecordType.DeveloperName FROM Loan_Application__c WHERE RecordType.DeveloperName='Tractor' limit 1];
        Ausfb_RelatedApplicantController.coApplicantValidationForTractor(loan.Id);
        Applicant__c app = [SELECT Id FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName='Primary_Applicant' limit 1];
        ApplicantTriggerHandler.byPassApplicantTrigger=true;
        app.Bureau_Score__c='278';
        update app;
        Applicant__c coApp = [SELECT Id FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName='Co_Applicant' limit 1];
        ApplicantTriggerHandler.byPassApplicantTrigger=true;
        delete coApp;
        Ausfb_RelatedApplicantController.coApplicantValidationForTractor(loan.Id);
        System.assertEquals('Tractor', loan.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

    @isTest
    public static void getApplicantsByProductTypeTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, RecordType.DeveloperName FROM Loan_Application__c WHERE RecordType.DeveloperName!='Tractor' limit 1];
        Ausfb_RelatedApplicantController.getApplicantsByProductType(loan.Id);
        System.assertNotEquals('Tractor', loan.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

    @isTest
    public static void checkMandatoryDocumentsTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, RecordType.DeveloperName FROM Loan_Application__c WHERE RecordType.DeveloperName='Tractor' limit 1];
        Applicant__c app = [SELECT Id FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName='Primary_Applicant' limit 1];
        app.Customer_Type__c='Non Individual';
        ApplicantTriggerHandler.byPassApplicantTrigger=true;
        update app;
        Applicant__c coApp = [SELECT Id FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName='Co_Applicant' limit 1];
        Ausfb_RelatedApplicantController.checkMandatoryDocuments(coApp.Id);
        System.assertEquals('Tractor', loan.RecordType.DeveloperName,'test');
        Test.stopTest();
    }

}