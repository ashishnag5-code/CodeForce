/**
 * @description       : Test class for LOSAdharKycController
 * @author            : Raviteja Vattikuti
 * @group             : 
 * @last modified on  : 06-23-2023
 * @last modified by  :	Raviteja Vattikuti
**/
@isTest
public class LOSAdharKycControllerTest {
@testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
           	Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Aadhaar_Number__c = '123456789012',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Adhar - Generate OTP',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Content_Type__c ='application/json'
            
        ),true);
    Integration_Master__c intmassearch3 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Adhar - Validate OTP',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Content_Type__c ='application/json'
            
        ),true);
    Integration_Master__c intmassearch4 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Aadhar Token Service',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Content_Type__c ='application/json'
            
        ),true);
    
    Integration_Master__c intmassearch5 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'SFDCAadharVaultService',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Content_Type__c ='application/json'
        ),true);
    }
     @isTest
    public static void getAadhaarNumApiTest(){
        Applicant__c appl = [SELECT ID,Aadhaar_Number__c FROM Applicant__c LIMIT 1];
        LOSAdharKycController.getMetadataRecord('test');
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new AadharTokenServiceMock());
        //try{
            LOSAdharKycController.getAadhaarNum(appl.Id,'TestAadhar');
        //}
        //catch(Exception e){
            
        //}
        Test.stopTest();  
    }
    @isTest
    public static void adharKychGenerateOTPMethodTest(){
        Test.startTest();
        Applicant__c appl = [SELECT ID,Aadhaar_Number__c FROM Applicant__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AadharKYCServiceMock.GenerateOTPResponse());
        try{
            LOSAdharKycController.adharKychMethod('1234',appl.Id,'Adhar - Generate OTP','2344','2344');
        }
        catch(Exception e){

        }
        Test.stopTest();
    }
    @isTest
    public static void adharKychValidateOTPMethodTest(){
        Test.startTest();
        Applicant__c appl = [SELECT ID,Aadhaar_Number__c FROM Applicant__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AadharKYCServiceMock.ValidateOTPResponse());
        try{
            LOSAdharKycController.adharKychMethod('1234',appl.Id,'Adhar - Validate OTP','2344','2344');
        }
        catch(Exception e){

        }
        Test.stopTest();
    }
}