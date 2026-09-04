@isTest
public class RtrScreenControllerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        Purchase_City__c='Jaipur'),true);
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
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE'
        ),true);

        Bureau_Results__c  brRslt = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c(
            Name = 'CIBIL Score',
            Bureau__c = 'CIBIL',
            Applicant__c = appl.Id,
            Bureau_Response__c = 'Pass'
        ),true);

        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId();
        //CART Account
        Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            Is_Enquiry_Type__c = false,
            RecordTypeId = cartRecordTypeId,
            Analysis_Data__c = '{"monthlyBalancesDetails":"","monthlyCreditsDetails":"","bankName":"AU","accountType":"SAVING","toBeConsidered":false,"status":"OTHERS"}',
            Account_Opening_Date__c = System.today(),
            Bureau_Results__c = brRslt.Id,
            Type_of_Loan__c='Housing Loan'
        ),true);

        Applicant_Financials_Details__c objFDSD = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=100, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Type_Of_Employment__c='Self Employed Professional',
            isActive__c=true,
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId()),true);
    }
    static testmethod void testGetPicklistOptions(){
        Test.startTest();
        RtrScreenController.getPicklistOptions();
        Test.stopTest();
    }

    static testmethod void testGetBankAccountRecords(){
        Test.startTest();
        Applicant__c applicant = [Select Id from Applicant__c];
        RtrScreenController.getBankAccountRecords(applicant.Id);
        Test.stopTest();
    }

    static testmethod void testUpsertBankAccountRecords(){
        Test.startTest();
        Bank_Account_Records__c objBank = [Select Id from Bank_Account_Records__c];
        Applicant__c applicant = [Select Id from Applicant__c];
        Bureau_Results__c bureauResult = [Select Id from Bureau_Results__c];
        RtrScreenController.upsertBankAccountRecords(new List<Bank_Account_Records__c>{objBank},applicant.Id,bureauResult.Id);
        Test.stopTest();
    }

    static testmethod void testReCalculateFoir(){
        Test.startTest();
        Bank_Account_Records__c objBank = [Select Id,EMI_Amount__c from Bank_Account_Records__c];
        objBank.EMI_Amount__c = 10;
        objBank.EMI_Considered_for_Obligation__c = 'No';
        objBank.Current_Balance__c = 1000;
        update objBank;
        RtrScreenController.reCalculateFoir(new List<String>{objBank.Id});
        Test.stopTest();
    }
}