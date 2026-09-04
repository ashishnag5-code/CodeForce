@isTest
public class EmailVerificationThroughLinkCntrlTest{
@testSetup 
    static void testDataSetup() {
    Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        Purchase_City__c='Jaipur'),true);
        
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
            Dealer_Master__c = dealerMaster.Id
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
            KYC_Type__c='Aadhaar - Biometric',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE'
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
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        
         Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c (
            Name ='Verify OTP For Email',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
            Integration_Master__c CanDOIntegrationMaster2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c (
            Name ='Generate OTP For Email',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Integration_Master__c CanDOIntegrationMaster1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c (
            Name ='Email Notification',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
            
    }
    
    @isTest
    public static void saveVerifiedEmailStatusTest(){
    Address__c  addr = [SELECT id from Address__c LIMIT 1];
    EmailVerificationThroughLinkControiller.saveVerifiedEmailStatus('Verified',addr);
    }
    
    @isTest
    public static void emailOtpVerificationHandlerTest(){
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
    Map<Object, String> params = new Map<Object, String>();
    Applicant__c appl1 = [SELECT id from Applicant__c LIMIT 1];
    params.put('applcntId',appl1.Id);
    params.put('masterRecordName','Verify OTP For Email');
    params.put('masterRecordName','Generate OTP For Email');
    EmailVerificationThroughLinkControiller.emailOtpVerificationHandler(params);
    Test.stopTest();
    }
    
    @isTest
    public static void emailOtpVerificationHandlerTest2(){
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new EmailVerificationCallout());
    Map<Object, String> params = new Map<Object, String>();
    Applicant__c appl1 = [SELECT id from Applicant__c LIMIT 1];
    params.put('applcntId',appl1.Id);
    params.put('masterRecordName','Verify OTP For Email');
    EmailVerificationThroughLinkControiller.emailOtpVerificationHandler(params);
    Test.stopTest();
    }
}