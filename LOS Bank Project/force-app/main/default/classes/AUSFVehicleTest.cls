@isTest
public class AUSFVehicleTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
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
         Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
       	Id usedRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Used CoW MMV Master').getRecordTypeId();

        Generic_Master__c genericRec = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            make__c   = 'Test', Model__c = 'Test' , Manufacturer__c = 'Test', Collateral_Code__c ='10106', recordTypeId = usedRecordTypeId
        ),true);
    } 
 
    @isTest
    public static void getLADetailsTest(){
        Generic_Master__c genericRec = [SELECT make__c, Model__c , Manufacturer__c FROM Generic_Master__c LIMIT 1];
        AUSFVehicleHelper.getPicklistLabel('10201');
        // AUSFVehicleHelper.getUsedProductPickListValues ('CV Passenger (Used)' , 'Test'); // - Method not in use
        AUSFVehicleHelper.getVisibleFields ('Exposure CASA Details' , 'Credit','System Administrator' ,'');
    }
}