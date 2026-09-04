@isTest
public class AusfLoanApprovalEmailTemplateTest {
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
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 100;
        charge1.Loan_Application__c = loanAppl.Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        insert charge1;
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppl.Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        insert charge2;
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'Loan Suraksha Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 100;
        charge3.Loan_Application__c = loanAppl.Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        insert charge3;
            
        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Other Charges';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 100;
        charge4.Loan_Application__c = loanAppl.Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        insert charge4;
        
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
        Id collateralNewRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
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
        ),true);
    } 
 
    @isTest
    public static void getLADetailsTest(){
        AusfLoanApprovalEmailTemplate objLoanApp = new AusfLoanApprovalEmailTemplate();
        
        Loan_Application__c loan = [SELECT id FROM Loan_Application__c limit 1];
        objLoanApp.accountid= loan.Id;
        AccountTeamMember accTeamMember = [SELECT ID FROM AccountTeamMember LIMIT 1];
        objLoanApp.getVehicle();
    }
}