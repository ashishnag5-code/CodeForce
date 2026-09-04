@isTest
public class RelatedReferencesComponentControllerTest {
    
     @testSetup 
    static void setup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        
        Applicant__c appl  = (Applicant__c) TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',            
            KYC_Type__c     = 'Aadhaar - Biometric',
            KYC_Status__c  = 'Pending',
            Loan__c       =  loanAppl.Id           
        ),true);
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        Document_Master__c  docMaster2 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0009',
            Document_Name__c = 'EKYC PDF'
            
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        
        Document_Checklist__c   docChecklst2 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster2.Id,
            Applicant__c    = appl.Id
        ),true);
        
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
        
        Applicant_Financials_Details__c appFinDetails=new Applicant_Financials_Details__c(Applicant__c=appl.Id,Industry__c='Defence/Police/Paramilitary');
         
    }
   
    
    @isTest
    public static void getApplicantAddressTest(){
        Applicant__c appl=[Select Id from Applicant__c LIMIT 1];
        Test.startTest();
        RelatedReferencesComponentController.getApplicantAddress(appl.Id, 'Current');
        Test.stopTest();
    }
    
    @isTest
    public static void getApplicantTest(){
        Applicant__c appl=[Select Id from Applicant__c LIMIT 1];
        Test.startTest();
        RelatedReferencesComponentController.getApplicant(appl.Id, 'Applicant');
        Test.stopTest();
        
    }
    
        @isTest
    public static void getApplicantFinancialTest(){
        Applicant__c appl=[Select Id from Applicant__c LIMIT 1];
        Test.startTest();
        RelatedReferencesComponentController.getApplicantFinancial(appl.Id, 'Defence/Police/Paramilitary');
        Test.stopTest();
        
    }
    
    @isTest
    public static void getCommonPicklistByFldNameTest(){
        Test.startTest();
        RelatedReferencesComponentController.getCommonPicklistByFldName('Relationship_with_applicant__c');
        Test.stopTest();
    }
    
    @isTest
    public static void applicantHandlerTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
        RelatedReferencesComponentController.applicantHandler(loanAppl.Id);
        Test.stopTest();
    }


}