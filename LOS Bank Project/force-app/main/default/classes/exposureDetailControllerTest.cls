@isTest
public with sharing class exposureDetailControllerTest {
    
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Individual',
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        //CBS Loan Type
        Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Loan_Amount__c =10000,
            EMI_Amount__c =2000,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()-368
        ),true);
        Bank_Account_Records__c cbsAccountInstance1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Loan_Amount__c =20000,
            Account_Number__c='AC-123',
            EMI_Amount__c =2000,
            POS__c=100,
            Sanctioned_Amount__c=100,
            Product_Code__c='10201',
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()-368
        ),true);
        
        //ODCC Account
        Bank_Account_Records__c odccAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()
        ),true);
        Bank_Account_Records__c odccAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()
        ),true);
        
        //CASA Account
        Bank_Account_Records__c casaAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'CASA',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()
        ),true);
        Bank_Account_Records__c casaAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'CASA',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()
        ),true);
        
        //CC Account
        Bank_Account_Records__c ccAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'CC',
            Loan_Amount__c =5000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Sanctioned_Amount__c=100,
            Product_Code__c='10201',
            Account_Number__c='CC-123',
            Account_Opening_Date__c = System.today()
        ),true);
        Bank_Account_Records__c ccAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Number__c ='9001070130327270',
            Account_Type__c = 'CC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today()
        ),true);
        
        //CASA Integration Master
        Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CASA SOA',
            End_Point_URL__c='https://service.aubank.in/CASAStatementService',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //LOAN SOA Integration Master
        Integration_Master__c loanIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Loan SOA',
            End_Point_URL__c='https://service.aubank.in/StatementOfAccountServiceV1',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //Loan Inquiry Integration Master
        Integration_Master__c loanInquiryIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Loan Inquiry',
            End_Point_URL__c='https://service.aubank.in/SFDCLoanAccountInquiryService',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        //OD Limit Equiry Integrarion Master
        Integration_Master__c ODLimitInquiryIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='OD Limit Equiry',
            End_Point_URL__c='https://service.aubank.in/CBSODLimitInquiryService',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
    }
    
    
    @isTest static void accountDetails(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String loanId = loanInstance.Id;
        Test.startTest();
        exposureDetailsController.getAccountDetails(loanId);
        System.assertEquals(loanInstance !=null,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void visibilityDetails(){
        Test.startTest();
        List<String> visibleList= exposureDetailsController.getVisibleFields('DDE Exposure CC  Details','DDE');
        System.assertEquals(visibleList !=null,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void casaDetails(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new exposureCASACalloutMock());
        exposureDetailsController.getCasaDetails('235233252352252',applicantId);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void LoanCalloutDetails(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new loanStatementCalloutMock());
        exposureDetailsController.getLoanDetails('235233252352252',applicantId);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void LoanInquiryCalloutDetails(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new loanInquiryCalloutMock());
        exposureDetailsController.getLoanInquiryDetails('9001070130327270',applicantId);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void ODLimitInquiryCalloutDetails(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Bank_Account_Records__c record1 =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                          FROM  Bank_Account_Records__c WHERE Account_Number__c ='CC-123' LIMIT 1];
         Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String applicantId = appl.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new odLimitInquiryCalloutMock());
        exposureDetailsController.getCCDetails('9001070130327270',applicantId,record1.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void accountDetailsUpdate(){
        Bank_Account_Records__c record =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =20000 LIMIT 1];
        
        Bank_Account_Records__c record1 =[SELECT id,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c
                                          FROM  Bank_Account_Records__c WHERE Account_Number__c ='CC-123' LIMIT 1];
        
        
        
        Loan_Application__c laonRecord = [SELECT Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Stage__c,Wheels_Exposure__c,Final_Exposure__c
                                          FROM Loan_Application__c WHERE Application_Number__c ='AP-12345'];
        
        exposureDetailsController.fullDetailsWrapper wrapperInstance = exposureDetailsController.getAccountDetails(laonRecord.Id);
        Test.startTest();
        exposureDetailsController.updateAccountDetails(record,laonRecord.Id,wrapperInstance);
        exposureDetailsController.updateAccountDetails(record1,laonRecord.Id,wrapperInstance);
        System.assertEquals(20000, record.Loan_Amount__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void exposureUpdation(){
        Bank_Account_Records__c record =[SELECT id,Applicant__r.Loan__r.Final_Exposure__c,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c,Applicant__r.Loan__r.Wheels_Exposure__c
                                         FROM  Bank_Account_Records__c WHERE Loan_Amount__c =20000 LIMIT 1];
        
        Bank_Account_Records__c record1 =[SELECT id,Applicant__r.Loan__r.Final_Exposure__c,Product_Code__c,POS__c,Sanctioned_Amount__c,  Applicant__c,Account_Number__c,Account_Type__c,Loan_Amount__c,EMI_Amount__c,Account_Opening_Date__c,Applicant__r.Loan__r.Wheels_Exposure__c
                                          FROM  Bank_Account_Records__c WHERE Account_Number__c ='CC-123' LIMIT 1];
        Test.startTest();
        exposureDetailsController.handleExposureUpdation(record,'No');
        exposureDetailsController.handleExposureUpdation(record1,'No');
        exposureDetailsController.handleExposureUpdation(record,'Yes');
        exposureDetailsController.handleExposureUpdation(record1,'Yes');
        System.assertEquals(20000, record.Loan_Amount__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void disbursedUpdation(){
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c,Customer_Type__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        Loan_Application__c laonRecord = [SELECT Application_Number__c,Adhar_Card__c,Loan_Amount__c,Product__c,Stage__c,Wheels_Exposure__c,Final_Exposure__c
                                          FROM Loan_Application__c WHERE Application_Number__c ='AP-12345'];
        
        Test.startTest();
        exposureDetailsController.handleDisbursedExposureUpdation(applicantRecord,'No',laonRecord.Id);
        exposureDetailsController.handleDisbursedExposureUpdation(applicantRecord,'Yes',laonRecord.Id);
        System.assertEquals('Vikash', applicantRecord.First_Name__c,'AssertMsg');
        Test.stopTest();        
        
    }
    
    
    
    
    
    
}