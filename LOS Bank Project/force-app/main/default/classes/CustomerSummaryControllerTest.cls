/*
@ Name: CustomerSummaryControllerTest
@ Description: CustomerSummaryController
@ Logs
@ Last Modified Date        -       Last Modified By            -       Description
@ Dec-27-2023               -       Mohit M.                    -       
*/
@isTest
public with sharing class CustomerSummaryControllerTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
            Total_Loan_Amount__c=2000
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
            Credit_Approved_Exposure__c=10000,
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
        
        //LOAN OD Detail Integration Master
        Integration_Master__c loanIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Loan OD Detail',
            End_Point_URL__c='https://service.aubank.in/GetLoanODDetailsService',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Account_Number__c='9001070530341114',
            Loan_Amount__c =10000,
            EMI_Amount__c =2000,
            Product_Code__c='10201',
            POS__c=222,
            Include_In_Exposure__c ='Yes',
            RecordTypeId = cbsRecordTypeId,
            Sanctioned_Amount__c =10,
            Account_Opening_Date__c = System.today()-368
        ),true);
        Bank_Account_Records__c cbsAccountInstance1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'Loan',
            Account_Number__c='3434343433434',
            Loan_Amount__c =10000,
            EMI_Amount__c =2000,
            Product_Code__c='10201',
            Include_In_Exposure__c ='Yes',
            RecordTypeId = cbsRecordTypeId,
            Sanctioned_Amount__c =10,
            Account_Opening_Date__c = System.today()-368,
            POS__c =232
        ),true);
        
        Bank_Account_Records__c odccAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            Include_In_Exposure__c ='Yes',
            RecordTypeId = cbsRecordTypeId,
             Product_Code__c='10201',
            Account_Number__c='9001070530341114',
            OD_Limit_Sanctioned__c =200000,
            Account_Opening_Date__c = System.today(),
            Sanctioned_Amount__c =10,
            POS__c =232
        ),true);
        
         Bank_Account_Records__c casaAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'CASA',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Account_Opening_Date__c = System.today(),
            Sanctioned_Amount__c =10,
             POS__c =232
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
            Include_In_Exposure__c ='Yes',
            Account_Number__c='0001691011219289823',
            Account_Opening_Date__c = System.today(),
            POS__c =232
        ),true);
        
         Bank_Account_Records__c ccAccountInstance1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'CC',
            Loan_Amount__c =5000,
            EMI_Amount__c =200,
            RecordTypeId = cbsRecordTypeId,
            Sanctioned_Amount__c=100,
            Product_Code__c='10201',
            Include_In_Exposure__c ='Yes',
            Account_Number__c='324234324324',
             OD_Limit_Sanctioned__c=2000,
             POS__c =232,
            
            Account_Opening_Date__c = System.today()
        ),true);
    }
    
    @isTest
    public static void applicantDetails(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Test.startTest();
        CustomerSummaryController.getApplicantDetails(loanInstance.Id);
        Test.stopTest();
        
    }
    
    @isTest 
    public static void loanODDetails(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LoanODCalloutMock());
        CustomerSummaryController.getLoanODDetails('27972650',appl.Id,loanInstance.Id);
         CustomerSummaryController.applicantUpdation(appl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void handleCredit(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String creditRecord='{\"CreditCardResponse\":[{\"AccountNumber\":\"0001691011219289823\",\"AccountOpenDate\":\"2022-02-28\",\"AccountStatus\":\"ACCOUNTOPENREGULAR\",\"CustomerAccountRelation\":\"SoleOwner\",\"CustomerFullName\":\"SULOCHANADAHARIYA\",\"CustomerID\":\"25139814\",\"Decode\":\"ALTURA\",\"DPDValue\":\"58\",\"LastStatementBalance\":\"49,520.69\",\"LoanStatus\":\"Standard\",\"ProductCode\":\"101\",\"SanctionedAmount\":\"45000\"}]}';
        Test.startTest();
        try{
        CustomerSummaryController.handleCCExposure('27972650',appl.Id,creditRecord);
        }
        Catch(exception e){
            
            system.debug('Inside catch::'+e);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void handleCredit1(){
         Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String creditRecord='{\"CreditCardResponse\":[{\"AccountNumber\":\"234242424242424224242\",\"AccountOpenDate\":\"2022-02-28\",\"AccountStatus\":\"ACCOUNTOPENREGULAR\",\"CustomerAccountRelation\":\"SoleOwner\",\"CustomerFullName\":\"SULOCHANADAHARIYA\",\"CustomerID\":\"25139814\",\"Decode\":\"ALTURA\",\"DPDValue\":\"58\",\"LastStatementBalance\":\"49,520.69\",\"LoanStatus\":\"Standard\",\"ProductCode\":\"101\",\"SanctionedAmount\":\"45000\"}]}';
        Test.startTest();
        CustomerSummaryController.handleCCExposure('27972650',appl.Id,creditRecord);
        Test.stopTest();
    }

    @isTest
    public static void createDeviationTest(){
        Test.startTest();
         RecordType rd=[select id from RecordType where name='Tractor' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10502',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Deviation__c coll= new Deviation__c(Loan_Application__c = loanAppl.Id);
        coll.Deviation_Type__c = 'S5-DPD Deviation';     
        insert coll;
        
        CustomerSummaryController.createDeviation(loanAppl.Id);
        CustomerSummaryController.exposureWrapper objexposureWrapper = new CustomerSummaryController.exposureWrapper();
        Test.stopTest();
    }
    
    @isTest
    public static void handleCreditAnotherScenario(){
        
        
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String creditRecord1='{\"CreditCardResponse\":[{\"AccountNumber\":\"33443\",\"AccountOpenDate\":\"2022-02-28\",\"AccountStatus\":\"ACCOUNTOPENREGULAR\",\"CustomerAccountRelation\":\"SoleOwner\",\"CustomerFullName\":\"SULOCHANADAHARIYA\",\"CustomerID\":\"25139814\",\"Decode\":\"ALTURA\",\"DPDValue\":\"58\",\"LastStatementBalance\":\"49,520.69\",\"LoanStatus\":\"Standard\",\"ProductCode\":\"101\",\"SanctionedAmount\":\"45000\"}]}';
        Test.startTest();
        CustomerSummaryController.handleCCExposure('27972650',appl.Id,creditRecord1);
       
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void handleBREHandler(){
        
        
        List<Applicant__c> appl =[SELECT id,First_Name__c FROM Applicant__c WHERE IsInactive__c= false];
        Test.startTest();
            Boolean bln = CustomerSummaryController.handleBRE(appl);
            CustomerSummaryController.exposureWrapper obj = new CustomerSummaryController.exposureWrapper();
       
        Test.stopTest();
        
        
    }
}