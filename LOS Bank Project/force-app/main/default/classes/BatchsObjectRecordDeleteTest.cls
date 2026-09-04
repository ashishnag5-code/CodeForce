/*****
 * Class Name: BatchsObjectRecordDelete
 * Description: Delete sObject Records Test coverage
 * Test Class Name: BatchsObjectRecordDeleteTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-07-2023          -   Mohit M.            -   
 */
@isTest
public with sharing class BatchsObjectRecordDeleteTest {
    @testSetup static void setup() {
        Document_Master__c  docMaster2 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0008',
            Document_Name__c = 'PAN',
            OCR_Document_Type__c = Label.KYC_OCR_Type_Aadhaar,
            Document_Sub_Category__c = Label.BRE_Karza_Verification_Type_KYC
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='Lead',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Disbursement_Date__c = System.today()-60,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId()
        ),true);

        Document_Checklist__c docChkRecord2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c   = loanAppl.Id,
            Document_Master__c = docMaster2.Id,
            Document_Name__c ='PAN',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100
        ), true);
    }
    
    @isTest static void batchDeleteRecordsWithAllValues() {
        Loan_Application__c loan =[SELECT id,Application_Number__c from Loan_Application__c WHERE Application_Number__c='AP-12345'];
        Test.startTest();
            String strQuery = 'Select Id from Document_Checklist__c ';
            Set<Id> setCreatedById = new Set<Id>();
            setCreatedById.add(UserInfo.getUserId());
            Set<Id> setOwnerId = new Set<Id>();
            setOwnerId.add(UserInfo.getUserId());
            Set<String> setStage = new Set<String>();
            setStage.add('Lead');
            strQuery = strQuery + 'where Related_Loan_Application_Stage__c in: setStage AND createdbyId in: setCreatedById AND OwnerId in: setOwnerId LIMIT 100000 ';
            BatchsObjectRecordDelete objBatchRun = new BatchsObjectRecordDelete(strQuery, setCreatedById, setOwnerId, setStage);
            Id jobid= Database.executeBatch(objBatchRun);
        Test.stopTest();
    }

    @isTest static void batchDeleteRecordsSingleQuery() {
        Loan_Application__c loan =[SELECT id,Application_Number__c from Loan_Application__c WHERE Application_Number__c='AP-12345'];
        Test.startTest();
            String strQuery = 'Select Id from Document_Checklist__c ';
            Set<Id> setCreatedById = new Set<Id>();
            setCreatedById.add(UserInfo.getUserId());
            Set<Id> setOwnerId = new Set<Id>();
            setOwnerId.add(UserInfo.getUserId());
            Set<String> setStage = new Set<String>();
            setStage.add('Lead');
            strQuery = strQuery + 'where Related_Loan_Application_Stage__c in: setStage AND createdbyId in: setCreatedById AND OwnerId in: setOwnerId LIMIT 100000 ';
            BatchsObjectRecordDelete objBatchRun = new BatchsObjectRecordDelete(strQuery);
            Id jobid= Database.executeBatch(objBatchRun);
        Test.stopTest();
    }
}