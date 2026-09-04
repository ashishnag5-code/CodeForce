@isTest
public class LosKYCConsentTest {
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
            Dob__c = System.today().addYears(-30),
            Education_qualification__c='GRADUATE',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    }
    testmethod static void getAadhaaeConsent(){
        LosKYCConsent.getAadhaaeConsent();
    }
    testmethod static void getContentVersion(){
        Contentversion objCVLoanApp = new Contentversion(Title = 'getContentVersion', isActive__c=true,PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Loan_Application__c='Kuch Bhi', VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCVLoanApp;
        Try{
            LosKYCConsent.getContentVersion(new List<String>{'getContentVersion'});
        } catch(Exception exp){}
        
    }
    testmethod static void getStaticResource(){
        StaticResource sr = [SELECT Id, Name FROM StaticResource limit 1];
        LosKYCConsent.getStaticResource(new List<String>{sr.Name});
    }
    testmethod static void initLanguage(){
        LosKYCConsent.initLanguage();
    }
    testmethod static void saveDocUrl(){
        //Applicant Insertion
        Applicant__c appl = [SELECT Id FROM Applicant__c limit 1];
        LosKYCConsent.saveDocUrl(appl.Id,'https://www.google.com/');
    }
}