@isTest
public class RelatedFleetControllerTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
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
            Branch_Master__c = accInstance.Id
        ),true);
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Loan_Application__c  = loanAppl.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',Aadhaar_Number__c = '123412341234',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Customer Collateral Enquiry',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralSearchService/CollEnquiry',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        //CBS Loan Type
        Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Loan_Amount__c =10000,
            Product__c='10101',
            Maturity_Date__c = System.today() +2,
            EMI_Amount__c =2000,
            Source__c ='CBS',
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()-368
        ),true);
        
        
        Id fiRecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Financial Institution Name').getRecordTypeId();
        Generic_Master__c genericMaster = (Generic_Master__c) TestFactory.createSObject(new Generic_Master__c(
            Bank_Name__c = 'Au Small Finance Bank Limited',            
            RecordTypeId = fiRecordTypeId
        ),true);
        
        
        
    }
    
    
    @isTest
    static void testGetFleets() {
        // Create a test loan application
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Application_Number__c='AP-12345';
        loanApp.Product__c = '10104';
        insert loanApp;
        
        // Create test fleets
        List<Fleet__c> testFleets = new List<Fleet__c>();
        for (Integer i = 0; i < 5; i++) {
            Fleet__c fleet = new Fleet__c(
                Name = 'Fleet ' + i,
                Loan_Application__c = loanApp.Id,
                Inactive__c = false
            );
            testFleets.add(fleet);
        }
        insert testFleets;
        
        Test.startTest();
        // Call the getFleets method
        RelatedFleetController.RelatedFleetControllerWrapper result = RelatedFleetController.getFleets(loanApp.Id);
        Test.stopTest();
        
        // Verify the returned wrapper object
        System.assertEquals(testFleets.size(), result.fltLst.size());
        
        // Verify the fleet records in the wrapper object
        for (Integer i = 0; i < testFleets.size(); i++) {
            Fleet__c testFleet = testFleets[i];
            Fleet__c resultFleet = result.fltLst[i];
            System.assertEquals(testFleet.Id, resultFleet.Id);
            System.assertEquals(testFleet.Name, resultFleet.Name);
        }
    }
    
    @isTest
    static void testSaveFleet() {
        // Create a test fleet record
        Fleet__c testFleet = new Fleet__c(
            Name = 'Test Fleet'
        );
        
        Test.startTest();
        // Call the saveFleet method
        String fleetId = RelatedFleetController.saveFleet(testFleet);
        Test.stopTest();
        
        // Retrieve the saved fleet record
        Fleet__c savedFleet = [SELECT Id, Name/*, Relationship_with_borrower__c, Vehicle_Number__c,Loan_Application__c*/  FROM Fleet__c WHERE Id = :fleetId];
        
        // Verify the fleet record was saved
        System.assertNotEquals(null, savedFleet);
        System.assertEquals(testFleet.Name, savedFleet.Name);
    }
    
    @isTest
    static void testUpdateFleet() {
        // Create a test fleet record
        Fleet__c testFleet = new Fleet__c(
            Name = 'Test Fleet'
        );
        insert testFleet;
        
        // Update the test fleet record
        testFleet.Name = 'Updated Fleet';
        
        Test.startTest();
        // Call the updateFleet method
        Id updatedFleetId = RelatedFleetController.updateFleet(testFleet.Id, 'edit', testFleet);
        Id deletedFleetId = RelatedFleetController.updateFleet(testFleet.Id, 'delete', testFleet);
        Test.stopTest();
        
        // Retrieve the updated fleet record
        Fleet__c updatedFleet = [SELECT Id, Name FROM Fleet__c WHERE Id = :updatedFleetId];
        
        // Retrieve the deleted fleet record
        Fleet__c deletedFleet = [SELECT Id, Name FROM Fleet__c WHERE Id = :deletedFleetId];
        
        // Verify the fleet record was updated
        System.assertNotEquals(null, updatedFleet);
        System.assertEquals(testFleet.Name, updatedFleet.Name);
        
        // Verify the fleet record was deleted
        System.assertNotEquals(null, deletedFleet);
        System.assertEquals(testFleet.Name, deletedFleet.Name);
    }
    
    @isTest
    static void testGetFleet() {
        // Create a test fleet record
        Fleet__c testFleet = new Fleet__c(
            Name = 'Test Fleet'
        );
        insert testFleet;
        
        Test.startTest();
        // Call the getFleet method
        Fleet__c resultFleet = RelatedFleetController.getFleet(testFleet.Id);
        Test.stopTest();
        
        // Verify the returned fleet record
        System.assertNotEquals(null, resultFleet);
        System.assertEquals(testFleet.Id, resultFleet.Id);
        System.assertEquals(testFleet.Name, resultFleet.Name);
    }
    
    @isTest
    static void csvTest() {
        Id masterId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Financial Institution Name').getRecordTypeId();
        Generic_Master__c master = new Generic_Master__c();
        master.Bank_Name__c = 'Canara Bank';
        master.RecordTypeId = masterId;
        insert master;
        
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Application_Number__c='AP-12345';
        loanApp.Product__c = '10104';
        insert loanApp;
        
        String data = '[{"Name":"Ramakrishna K","Relationship_with_borrower__c":"SELF","Vehicle_Number__c":"AU1321","Vehicle_Make_Model__c":"TESTMODEL","MFG_Year__c":2010,"HPN_Status__c":"Financed","Loan_Tenure__c":10,"Installment_Paid__c":20,"Loan_Amount__c":1000000,"Financial_Institution__c":"Tata Capital Financial Services","Type_of_Vehicle__c":"Body Funding"},{"Name":"Amala Krishnamurthy","Relationship_with_borrower__c":"BROTHER","Vehicle_Number__c":"AU13211","Vehicle_Make_Model__c":"MAHINDRA","MFG_Year__c":2020,"HPN_Status__c":"Financed","Loan_Tenure__c":50,"Installment_Paid__c":11,"Loan_Amount__c":300000,"Financial_Institution__c":"SBM Bank (India) Limited*","Type_of_Vehicle__c":"Construction Equipment"},{"Name":"Ashish","Relationship_with_borrower__c":"HUSBAND","Vehicle_Number__c":"A121321","Vehicle_Make_Model__c":"EICHER","MFG_Year__c":2021,"HPN_Status__c":"Free","Loan_Tenure__c":20,"Installment_Paid__c":19,"Loan_Amount__c":50000,"Financial_Institution__c":"Canara Bank","Type_of_Vehicle__c":"Two Wheeler"},{"Name":"Krishnamurthy B","Relationship_with_borrower__c":"MOTHER","Vehicle_Number__c":"AUASD1321","Vehicle_Make_Model__c":"HONDA","MFG_Year__c":2022,"HPN_Status__c":"Financed","Loan_Tenure__c":31,"Installment_Paid__c":21,"Loan_Amount__c":700000,"Financial_Institution__c":"State Bank of India","Type_of_Vehicle__c":"Three Wheeler"}]';
        //String testCSVData = 'Name,Fleet_owned_by__c,Relationship_with_borrower__c,Vehicle_Number__c,Vehicle_Make_Model__c,MFG_Year__c,HPN_Status__c,Loan_Tenure__c,Installment_Paid__c,Financial_Institution__c,Type_of_Vehicle__c\r\nCSVFileName3,Applicant,Self,PB91A9556,BMW,1981,Free,5,2,Canara Bank,Tractor\n';
        
        //Blob csvFileBody = Blob.valueOf(testCSVData);
        //String s = EncodingUtil.base64Encode(csvFileBody);
        Test.startTest();
        // Call the getFleet method
        RelatedFleetController.createCSVFleetRecords(data,loanApp.Id);
       // System.assertEquals('Canara Bank', master.Bank_Name__c);
        Test.stopTest();
    }
    
    @isTest static void createRecords(){
        Applicant__c appRec = [SELECT Id from Applicant__c LIMIT 1];
        Loan_Application__c loanRec = [SELECT Id,Application_Number__c from Loan_Application__c LIMIT 1];
        Fleet__c fleetInstance = new Fleet__c();
        fleetInstance.Account_Number__c = '9001060130308777';
        fleetInstance.Loan_Application__c = loanRec.Id;
        fleetInstance.Loan_Tenure__c =9;
        fleetInstance.Installment_Paid__c = 7;
        fleetInstance.Relationship_with_borrower__c = 'OTHERS';
        fleetInstance.MFG_Year__c ='2022';
        insert fleetInstance;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new CollateralSerachServiceMock());
        //CustomCollateralEnquiryController.getCollateralEnquiryList(appRec.Id);
        RelatedFleetController.createCollateralFleetRecords(loanRec.Id,appRec.Id);
        System.assertEquals('AP-12345', loanRec.Application_Number__c);
        Test.StopTest();        
    }
    @isTest static void createBankRecords(){
        Loan_Application__c loanRec = [SELECT Id,Application_Number__c from Loan_Application__c LIMIT 1 ];
        Test.StartTest();
        System.assertEquals('AP-12345', loanRec.Application_Number__c);
        RelatedFleetController.getBankRecords(loanRec.Id);
        Test.StopTest();        
    }
    @isTest static void fleetFinanceRation(){
        Loan_Application__c loanRec = [SELECT Id,Application_Number__c from Loan_Application__c LIMIT 1 ];
        Fleet__c  fleetRecord1 = new Fleet__c();
        fleetRecord1.Loan_Application__c = loanRec.Id;
        fleetRecord1.HPN_Status__c = 'Financed';
        fleetRecord1.Loan_Tenure__c = 12;
        fleetRecord1.Installment_Paid__c = 9;
        fleetRecord1.MFG_Year__c ='2019';
        fleetRecord1.Relationship_with_borrower__c ='MOTHER';
        insert fleetRecord1;
        
        Fleet__c  fleetRecord = new Fleet__c();
        fleetRecord.Loan_Application__c = loanRec.Id;
        fleetRecord.HPN_Status__c = 'Free';
        fleetRecord.Loan_Tenure__c = 12;
        fleetRecord.Installment_Paid__c = 9;
        fleetRecord1.MFG_Year__c ='2019';
        fleetRecord1.Relationship_with_borrower__c ='MOTHER';
        insert fleetRecord;
        Test.StartTest();
        RelatedFleetController.calculateFreeFinanceRatio(loanRec.Id);
        System.assertEquals('AP-12345', loanRec.Application_Number__c,'test');
        Test.StopTest();    
    }
    
}