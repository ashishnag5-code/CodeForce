@isTest
public class AUSFLEICreditControllerTest {
   @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            Unhedged_Foreign_Currency_Exposure__c = 'Yes',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Bureau_Score__c = '10',
            Loan__c =loanAppl.Id
            
        ),true);
       Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
           Applicant__c = appl.id,
           Account_High_Credit_Amount__c = 100
       ),true);
       
       Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'UFCE Declaration',
            Document_Name__c = 'UFCE Declaration'
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='UFCE Declaration',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),true);
        
        Document_Master__c  docMasterDL = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'UFCE Certificate',
            Document_Name__c = 'UFCE Certificate'
        ),true);
        
        Document_Checklist__c docChkRecordDL = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Document_Master__c = docMasterDL.Id,
            Document_Name__c ='UFCE Certificate',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),true);
   }
       @IsTest
    static void getLEIWrapperTest() {
         Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
         Test.startTest();
        AUSFLEICreditController.Wrapper result = AUSFLEICreditController.getLEIWrapper(loanObj.Id);
        Test.stopTest();
    }
    @IsTest
    static void generateDocChecklistsTest() {
         Loan_Application__c loanObj = [SELECT Id,Unhedged_Foreign_Currency_Exposure__c FROM Loan_Application__c LIMIT 1];
         Test.startTest();
        AUSFLEICreditController.generateDocChecklists(loanObj.Id);
        loanObj.Unhedged_Foreign_Currency_Exposure__c = 'No';
        update loanObj;
        AUSFLEICreditController.generateDocChecklists(loanObj.Id);
        Test.stopTest();
    }
    @IsTest
    static void existingDocChecklistsTest() {
        List<Document_Checklist__c> docList = [Select Id, Loan_Application__c FROM Document_Checklist__c];
        
         Loan_Application__c loanObj = [SELECT Id,Unhedged_Foreign_Currency_Exposure__c FROM Loan_Application__c LIMIT 1];
         Test.startTest();
        for(Document_Checklist__c dc : docList){
            dc.Loan_Application__c = loanObj.Id;
        }
        update docList;
        AUSFLEICreditController.generateDocChecklists(loanObj.Id);
        loanObj.Unhedged_Foreign_Currency_Exposure__c = 'No';
        update loanObj;
        AUSFLEICreditController.generateDocChecklists(loanObj.Id);
        Test.stopTest();
    }
}