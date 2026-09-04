@isTest
public class LosKYCControllerTest {
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
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0006',
            Document_Name__c = 'Aadhaar Card',
            Consider_for_E_Sign__c = true
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Loan_Application__c = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Aadhaar Card',
            Document_Number__c = '123112311231'
        ),true);
        
        Document_Master__c  docMaster2 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name = 'EKYC PDF',
            Document_Name__c = 'EKYC PDF',
            Consider_for_E_Sign__c = true
        ),true);
        
        Document_Checklist__c docChkRecord2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Loan_Application__c = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster2.Id,
            Document_Name__c ='EKYC PDF',
            Document_Number__c = '123112311231'
        ),true);
        
        //Address Insertion
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='302026',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Permanent',
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        
        Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
            Name ='302026',
            Area_Name__c ='JAGJIT NAGAR',
            Area_Type__c ='Urban',  
            City__c ='Jaipur',
            State__c ='RAJASTHAN',
            Taluka__c ='NA',
            Zip_Code__c = '302026',
            Working_Area__c = 'Yes'
        ),true);
        
    }
    testmethod static void updateRecords(){
        Applicant__c applicant = [Select Id,First_Name__c,Last_Name__c,DOB__c from Applicant__c limit 1];
        Test.startTest();
        LosKYCController.updateRecords(JSON.serialize(applicant),'{"vtc":"213","status":"Completed", "house":"123","street":"123", "state":"213", "pc":"30206","loc":"213","dist":"213","country":"IN", "tkn":"tkn","uid":"123112311231","gender":"M","name":"Hello Kumar World","co":"W/O XMan"}');
        Test.stopTest();
    }
    testmethod static void updatePAN(){
        Applicant__c applicant = [Select Id,First_Name__c,Last_Name__c,DOB__c from Applicant__c limit 1];
        Test.startTest();
        LosKYCController.updatePAN(JSON.serialize(applicant));
        Test.stopTest();
    }
    testmethod static void updatePANException(){
        Applicant__c applicant = [Select Id,First_Name__c,Last_Name__c,DOB__c from Applicant__c limit 1];
        Test.startTest();
        applicant.Id = null;
        LosKYCController.updatePAN(JSON.serialize(applicant));
        Test.stopTest();
    }
    testmethod static void updateLoanApp(){
        Loan_Application__c applicant = [Select Id from Loan_Application__c limit 1];
        Test.startTest();
        LosKYCController.updateLoanApp(JSON.serialize(applicant));
        Test.stopTest();
    }
    testmethod static void updateLoanAppDDE(){
        Loan_Application__c applicant = [Select Id,Stage__c from Loan_Application__c limit 1];
        Test.startTest();
        applicant.Stage__c = 'DDE';
        LosKYCController.updateLoanApp(JSON.serialize(applicant));
        Test.stopTest();
    }
    testmethod static void updateLoanAppException(){
        Loan_Application__c applicant = [Select Id from Loan_Application__c limit 1];
        Test.startTest();
        applicant.id= null;
        LosKYCController.updateLoanApp(JSON.serialize(applicant));
        Test.stopTest();
    }
    testmethod static void getApplicantData(){
        Applicant__c applicant = [Select Id from Applicant__c limit 1];
        Test.startTest();
        LosKYCController.getApplicantData(applicant.Id);
        Test.stopTest();
    }
    testmethod static void verifyKYC(){
        Applicant__c applicant = [Select Id from Applicant__c limit 1];
        Test.startTest();
        LosKYCController.verifyKYC(applicant.Id);
        Test.stopTest();
    }
}