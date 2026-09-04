@isTest
public with sharing class CPVWaiverDocumentHandlerTest {
   
    /*

    @TestSetup
    static void makeData(){

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            Promo_Code__c='HYTR'
        ),true); 

        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes'
        ),true);

        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Electricity Bill');
        insert master;


        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Document_Verification_Status__c=GlobalConstants.VERIFIED,
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = master.Id
        ),true);

        Integration_Master__c intmassearch = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza Electricity Bill',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaElectricityBill?',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza Address Match',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        Address__c add = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'A',
            Address_Line_2__c = 'B',
            Address_Line_3__c = 'C',
            Address_Type__c = 'Current',
            Applicant__c = applicant.Id,
            State__c = 'Goa',
            City__c = 'Ponda',
            Pincode__c='403404'
            
        ),true);
    }

    @isTest
    static void testgetApplicants(){
        Test.startTest();
        Loan_Application__c loan=[SELECT Id FROM Loan_Application__c];
        CPVWaiverDocumentsController.getApplicants(loan.Id);
        Test.stopTest();
    }

    @isTest
    static void testcheckIfAlreadyUploaded(){
        Test.startTest();
        Applicant__c applicant=[SELECT Id FROM Applicant__c];
        List<String> docTypes = new List<String>{'Electricity Bill'};
        CPVWaiverDocumentsController.checkIfAlreadyUploaded(applicant.Id, 'Electricity Bill');
        CPVWaiverDocumentsController.markVerified(applicant.Id, 'Electricity Bill','89327482643');
        CPVWaiverDocumentsController.getVerifiedRecords(applicant.Id, docTypes);
        Test.stopTest();
    }
    
    @isTest 
    static void testaddressmatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AddressMatchCalloutMock());
        Applicant__c objApp = [Select Id, loan__c from Applicant__c limit 1];
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper response0 = new KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper();
        response0.result = new KarzaElectricityBillHandler.KarzaElectricityBillResult();
        response0.result.address = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper objWrapper = KarzaElectricityBillController.addressmatch(response0,objApp.Id, objApp.Loan__c);
        *KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response1 = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        response1.result = new KarzaLPGBillHandler.KarzaLPGBillResult();
        response1.result.ConsumerAddress = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        objWrapper = KarzaLPGBillController.addressmatch(response1,objApp.Id, objApp.Loan__c);
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper response2= new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        response2.result = new KarzaPNGBillHandler.KarzaPNGBillResult();
        response2.result.Customer_Address = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        objWrapper = KarzaPNGBillController.addressmatch(response2,objApp.Id, objApp.Loan__c);*
        Test.stopTest();
    }

    /*@isTest 
    static void testkarzaElectricityBillCallOut(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ElectricityBillCalloutMock());
        Applicant__c objApp = [Select Id, loan__c from Applicant__c limit 1];
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper response = KarzaElectricityBillController.karzaElectricityBillCallOut('111111',objApp.Id,objApp.loan__c);
        Test.stopTest();

        
    }*/
    
}