@IsTest
public class IntegrationContainerControllerTest {
    @testSetup static void setup() {  
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                        Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,
                                        Loan_Amount__c = 1000,Product__c='10201'),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanApp.Id,
                            Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        Opportunity opp = new Opportunity(Name='Opp',CloseDate=System.today().addDays(30),AccountId=branchMaster.Id,StageName='New');
        insert opp;
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
                                Loan__c = loanApp.Id,Vehicle_Usage__c='Personal'),true);
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
                                        Name = 'Test Document', Document_Category__c = 'Vehicle Document', 
                                        Document_Sub_Category__c = 'Vehicle Document', Document_ID__c = 'AUWheels0008'),true);
        Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
                                            Applicant__c = appl.Id, Collateral__c = collat.Id, Document_Master__c = docMaster.Id, 
                                            Loan_Application__c =loanApp.Id),true);
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        Integration_Master__c integrationMast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'EMI Schedule',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);
        
        Integration_Checklist__c intChild = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Loan__c  = opp.Id; 
        intChild.Integration_Master__c  = integrationMast.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild;
        
        Integration_Checklist__c intChild2 = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApp.Id; 
        intChild.Loan__c  = opp.Id; 
        intChild.Integration_Master__c  = intmassearch2.Id; 
        intChild.Request_Id__c = '644a0f30c76c5a00e823e11e';
        insert intChild2;

    }
    
    @IsTest
    static void testFetchIntegrationStatusDetails1() {
        List<Applicant__c> appList = [SELECT Id From Applicant__c WHERE First_Name__c = 'Vikash']; 
        List<String> records = new List<String>();
        for (Applicant__c each : appList) {
            records.add(each.Id);
        }
        Test.startTest();
        List<Integration_Checklist__c> intList = [SELECT Id From Integration_Checklist__c]; 
        String objectName = 'Applicant__c';
        IntegrationContainerController.fetchIntegrationStatusDetails(records,objectName);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchIntegrationStatusDetails2() {
        List<Loan_Application__c> oppList = [SELECT Id From Loan_Application__c LIMIT 1]; 
        List<String> records = new List<String>();
        for (Loan_Application__c each : oppList) {
            records.add(each.Id);
        }
        Test.startTest();
        List<Integration_Checklist__c> intList = [SELECT Id From Integration_Checklist__c]; 
        String objectName = 'Opportunity';
        IntegrationContainerController.fetchIntegrationStatusDetails(records,objectName);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchIntegrationStatusDetails3() {
        List<Loan_Application__c> laList = [SELECT Id From Loan_Application__c WHERE Application_Number__c = 'AP-12345']; 
        List<String> records = new List<String>();
        for (Loan_Application__c each : laList) {
            records.add(each.Id);
        }
        Test.startTest();
        List<Integration_Checklist__c> intList = [SELECT Id From Integration_Checklist__c]; 
        String objectName = 'Loan_Application__c';
        IntegrationContainerController.fetchIntegrationStatusDetails(records,objectName);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchIntegrationStatusRecord() {
        Integration_Checklist__c intList = [SELECT Id From Integration_Checklist__c WITH SECURITY_ENFORCED LIMIT 1]; 
        Test.startTest();
        //IntegrationContainerController.fetchIntegrationStatusRecord(intList.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchIntegrationStatusRecords1() {
        Opportunity oppList = [SELECT Id From Opportunity WHERE Name = 'Opp']; 
        Test.startTest();
        String objectName = 'Opportunity';
        IntegrationContainerController.fetchIntegrationStatusRecords(oppList.Id,objectName);
        Test.stopTest();
    }
    
    @IsTest
    static void testFetchIntegrationStatusRecords2() {
        Applicant__c appList = [SELECT Id From Applicant__c WHERE First_Name__c = 'Vikash']; 
        Test.startTest();
        String objectName = 'Applicant__c';
        IntegrationContainerController.fetchIntegrationStatusRecords(appList.Id,objectName);
        Test.stopTest();
    }
}