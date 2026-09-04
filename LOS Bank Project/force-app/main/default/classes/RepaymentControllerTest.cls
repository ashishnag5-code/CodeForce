@isTest
public class RepaymentControllerTest {
	@testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Repayment_Account_Number__c = '9990009999009'
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Bank_Account_Records__c bankAccount = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId(),
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual',
            CASARelationshipDetails__c = '[{"Relationship":"SOW","MobileNo":"1022570632","JointHolderName":"Vaishali Jain","CustomerID":"22570632"}]',
            Account_Number__c = '9990009999009',
            Applicant__c = appl.Id
            ),true);
        
        IFSC_Master__c ifscObj = (IFSC_Master__c)TestFactory.createSObject(new IFSC_Master__c(
            IFSC__c = 'SBIN0000111',
            Bank_Name__c = 'STATE BANK OF INDIA',
            MICR_Code__c = '1234'
        ),true);
        
        Generic_Master__c bankObj = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            Bank_Name__c = 'STATE BANK OF INDIA',
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Bank Master').getRecordTypeId()
        ),true);
        
        Document_Master__c docObj = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name='AUWheels0078'
        ),true);
        
        Document_Master__c docObj2 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name='AUWheels0045'
        ),true);
        
        Document_Checklist__c docCheck = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c= loanAppl.Id,
            Document_Master__c=docObj.Id
        ),true);
        
        Document_Checklist__c docCheck2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c= loanAppl.Id,
            Document_Master__c=docObj2.Id
        ),true);
        
        Assignment__c assignObj = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            Loan_Application__c= loanAppl.Id
            
        ),true);
    }
    
    @isTest
    public static void getCASADetailsTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String result = RepaymentController.getCASADetails(loanObj.Id);
        System.assertEquals('[{"Relationship":"SOW","MobileNo":"1022570632","JointHolderName":"Vaishali Jain","CustomerID":"22570632"}]', result);
    }
    
    @isTest
    public static void getDocumentRecordsDataTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Assignment__c assign = [select id from Assignment__c limit 1];
        String result = RepaymentController.getDocumentRecordsData(loanObj.Id);
        String result1 = RepaymentController.getDocumentRecordsData(assign.Id);
    }
    
    @isTest
    public static void uploadSIFormTest(){
		Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String result = RepaymentController.uploadSIForm(loanObj.Id);        
    }
    
    @isTest
    public static void uploadACHFormTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String result = RepaymentController.uploadACHForm(loanObj.Id);
        RepaymentController.sendSIotification(loanObj.Id);
    }
    
    @isTest
    public static void getBankNameTest(){
        try{
            String result = RepaymentController.getBankName(null);
        }catch(exception e){
            system.debug('error');
        }
        String result = RepaymentController.getBankName('SBIN0000111');
        System.assertEquals('STATE BANK OF INDIA', result);
    }
    
    @isTest
    public static void getValidBankNameAndIFSCTest(){
        List<String> listOfIfsc = new List<String>();
        List<IFSC_Master__c> result1 = RepaymentController.getValidBankNameAndIFSC(listOfIfsc);
        listOfIfsc.add('SBIN0000111');
        List<IFSC_Master__c> result = RepaymentController.getValidBankNameAndIFSC(listOfIfsc);
        System.assertEquals('STATE BANK OF INDIA', result[0].Bank_Name__c);
    }
    
    @isTest
    public static void getApplicantInitDataTest(){
        try{
        String result2 = RepaymentController.getRecordInfo(null);
        }catch(exception e){
            system.debug('error');
        }
       	Assignment__c assignObj = [SELECT Id FROM Assignment__c LIMIT 1];
       	Assignment__c result = RepaymentController.getApplicantInitData(assignObj.Id);
        String result1 = RepaymentController.getRecordInfo(assignObj.Id);
    }
    
    @isTest
    public static void getMICRCodeTest(){
        String result = RepaymentController.getMICRCode('SBIN0000111');
        System.assertEquals('1234', result);
    }
}