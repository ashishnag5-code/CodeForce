@isTest
public class MultipleFileUploadControllerTest {
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
        
        List<Document_Master__c> docMasterList = new List<Document_Master__c>();
        Document_Master__c  docMaster1 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Bank Statement'
            
        ),false);
        docMasterList.add(docMaster1);
        Document_Master__c  docMaster2 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0009',
            Document_Name__c = 'ITR Statement'
        ),false);
        docMasterList.add(docMaster2);
       
        insert docMasterList;
        
        List<Document_Checklist__c> docCheckList = new List<Document_Checklist__c>();
        Document_Checklist__c   docChecklst1 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterList[0].Id,
            Applicant__c    = appl.Id
        ),false);
        docCheckList.add(docChecklst1);
        Document_Checklist__c   docChecklst2 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterList[1].Id,
            Applicant__c    = appl.Id
        ),false);
        docCheckList.add(docChecklst2);
        insert docCheckList;
        
       Bank_Account_Records__c bankAccount = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId(),
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual',
            CASARelationshipDetails__c = '[{"Relationship":"SOW","MobileNo":"1022570632","JointHolderName":"Vaishali Jain","CustomerID":"22570632"}]',
            Account_Number__c = '9990009999009',
            Applicant__c = appl.Id,
            Cart_Request_Id__c='IC001001001',
            Analysis_Data__c='{"monthlyCreditsDetailsGrandTotal":{"Salary Credit":18560.48,"Month-Year":null,"Credit":51986.201428571425},"monthlyBalancesDetailsGrandTotal":{"averageBalanceOn5th":1459.7242857142858,"averageBalanceOn25th":567.16,"Month-Year":null,"averageBalanceOn20th":2256.781428571429,"AMB":1963.5269122229531,"averageBalanceOn10th":368.4385714285714,"Average of Custom Day":3333.8328571428574,"averageBalanceOn15th":296.6385714285715,"averageBalanceOn1st":15054.254285714285},"monthlyCreditsDetails":[{"Salary Credit":23435.52,"Month-Year":"Dec-2022","Credit":24845.52},{"Salary Credit":20029.27,"Month-Year":"Jan-2023","Credit":56333.32},{"Salary Credit":20168.75,"Month-Year":"Feb-2023","Credit":60168.75},{"Salary Credit":20150.69,"Month-Year":"Mar-2023","Credit":78575.69},{"Salary Credit":22468.14,"Month-Year":"Apr-2023","Credit":59809.14},{"Salary Credit":23670.99,"Month-Year":"May-2023","Credit":58670.990000000005},{"Salary Credit":0,"Month-Year":"Jun-2023","Credit":25500}],"monthlyBalancesDetails":[{"averageBalanceOn5th":47.47999999999999,"averageBalanceOn25th":588.48,"Month-Year":"Dec-2022","averageBalanceOn20th":387.48,"AMB":985.3677419354837,"averageBalanceOn10th":147.48,"Average of Custom Day":294.31333333333333,"averageBalanceOn15th":547.48,"averageBalanceOn1st":47.47999999999999},{"averageBalanceOn5th":6725,"averageBalanceOn25th":205.05,"Month-Year":"Jan-2023","averageBalanceOn20th":153.4,"AMB":2648.9909677419364,"averageBalanceOn10th":74,"Average of Custom Day":5194.308333333333,"averageBalanceOn15th":453.4,"averageBalanceOn1st":23555},{"averageBalanceOn5th":2070.23,"averageBalanceOn25th":4.23,"Month-Year":"Feb-2023","averageBalanceOn20th":24.23,"AMB":1776.831428571428,"averageBalanceOn10th":1277.23,"Average of Custom Day":2189.078333333333,"averageBalanceOn15th":274.23,"averageBalanceOn1st":9484.32},{"averageBalanceOn5th":45.09,"averageBalanceOn25th":11.09,"Month-Year":"Mar-2023","averageBalanceOn20th":41.09,"AMB":1445.086129032255,"averageBalanceOn10th":470.09,"Average of Custom Day":3463.5716666666667,"averageBalanceOn15th":361.09,"averageBalanceOn1st":19852.98},{"averageBalanceOn5th":965.19,"averageBalanceOn25th":2926.19,"Month-Year":"Apr-2023","averageBalanceOn20th":14956.19,"AMB":4030.999333333333,"averageBalanceOn10th":355.19,"Average of Custom Day":4260.19,"averageBalanceOn15th":185.19,"averageBalanceOn1st":6173.19},{"averageBalanceOn5th":136.49,"averageBalanceOn25th":6.49,"Month-Year":"May-2023","averageBalanceOn20th":6.49,"AMB":1859.2264516129014,"averageBalanceOn10th":26.49,"Average of Custom Day":3832.1300000000015,"averageBalanceOn15th":26.49,"averageBalanceOn1st":22790.33},{"averageBalanceOn5th":228.59,"averageBalanceOn25th":228.59,"Month-Year":"Jun-2023","averageBalanceOn20th":228.59,"AMB":998.1863333333334,"averageBalanceOn10th":228.59,"Average of Custom Day":4103.238333333334,"averageBalanceOn15th":228.59,"averageBalanceOn1st":23476.48}]}'
            ),true); 
        
        
        Integration_Master__c integrationMast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Cart Upload Service',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);
        Integration_Master__c integrationMast1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza ITR Service',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);
        
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001001',
            Integration_Master__c = integrationMast.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message": "call back request message","status":"Processed"}'
        ),true);
        
        Applicant_Financials_Details__c afdParent = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Type_Of_Employment__c  = 'Salaried - Private',
            applicant__c  = appl.Id,
            isActive__c = true,
            RecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Documented_With_Audited_financial').getRecordTypeId()
        ),true);
        
        Applicant_Financials_Details__c afdChild1 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Type_Of_Employment__c  = 'Salaried - Private',
            applicant__c  = appl.Id,
            Average_Monthly_Salary__c = 12000,
            isActive__c = true,
            RecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Documented_Without_Audited_financial').getRecordTypeId()
        ),true);
        
        Deviation__c deviation = new Deviation__c(
            Active__c = true,
            Source__c = 'BRE',
            Loan_Application__c = loanAppl.Id,
            Archived__c = false,
            Deviation_Type__c ='FOIR NORM'
        );
        insert deviation;
       
        
    }
    
    @isTest
    public static void getApplicableDocumentMastersTest(){
        Test.startTest();
        MultipleFileUploadController ctlr=new MultipleFileUploadController();
        Document_Master__c docMaster = MultipleFileUploadController.getDocumentMaster('ITR Statement');
        List<Document_Master__c> objDocuments = MultipleFileUploadController.getApplicableDocumentMasters('Electricity_Bill');
        System.assert(docMaster != null);
        Test.stopTest();
    }

    /*
    @isTest
    public static void getcalculateAverageSalaryTest(){
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c appl  = (Applicant__c) TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',            
            KYC_Type__c     = 'Aadhaar - Biometric',
            KYC_Status__c  = 'Pending',
            Loan__c       =  loanAppl.Id           
        ),true);
        Bank_Account_Records__c bankAccount1 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Name = 'Test',
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId(),
            Loan_Amount__c = 1000,
            Total_Outstanding__c = 10,
            Amount_Overdue__c = 10,
            Account_Opening_Date__c = Date.today(),
            Owenership_Indicator__c = 'Individual',
            CASARelationshipDetails__c = '[{"Relationship":"SOW","MobileNo":"1022570632","JointHolderName":"Vaishali Jain","CustomerID":"22570632"}]',
            Account_Number__c = '9990009999009',
            Applicant__c = appl.Id,
            Cart_Request_Id__c='IC001001002'
            ),true); 
        Integration_Master__c integrationMast = [SELECT Id FROM Integration_Master__c WHERE Name = 'Cart Upload Service'];
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001002',
            Integration_Master__c = integrationMast.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message": "call back request message","status":"Processed"}'
        ),true);
        List<Applicant__c> applList=[Select Id from Applicant__c];
        Test.startTest();
        List<MultipleFileUploadController.AverageSalary> avSalList = MultipleFileUploadController.calculateAverageSalary(applList[0].Id);
        List<MultipleFileUploadController.AverageSalary> avSalList1 = MultipleFileUploadController.calculateAverageSalary(applList[1].Id);
        System.assert(avSalList.size() != 0);
        Test.stopTest();
    }
    */

    
     @isTest
    public static void cartCalloutOnSubmitMobileTest(){
        Applicant__c appl=[Select Id from Applicant__c LIMIT  1];
        Document_Master__c  docMaster=[Select Id from Document_Master__c Where Name='AUWheels0006' LIMIT  1];
        Document_Checklist__c docChecklist=[Select Id from Document_Checklist__c Where Document_Master__c=:docMaster.Id LIMIT  1]; 
        
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        newFile.Request_Id__c = 'IC001001001';
        insert newFile;
        ContentVersion contentVersion = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=docCheckList.Id, 
                                                                 ContentDocumentId=contentVersion.ContentDocumentId);
        //insert linkedFile;
        Test.setMock(HttpCalloutMock.class, new MultipleFileUploadCalloutMock());
        Test.startTest();
        try{
          	String cartResponse = MultipleFileUploadController.cartCalloutOnSubmitMobile(appl.Id,'',1000,docCheckList.Id);
        	System.assert(cartResponse != '');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    @isTest
    public static void cartCalloutOnSubmitMobileTest1()
    {
        Applicant__c appl=[Select Id from Applicant__c LIMIT  1];
        Document_Master__c docMaster=[Select Id from Document_Master__c Where Name='AUWheels0009' LIMIT 1];
        Document_Checklist__c docChecklist=[Select Id from Document_Checklist__c Where Document_Master__c=:docMaster.Id LIMIT  1];     
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        ContentVersion contentVersion = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=docCheckList.Id, 
                                                                 ContentDocumentId=contentVersion.ContentDocumentId);
        insert linkedFile;
        Test.setMock(HttpCalloutMock.class, new MultipleFileUploadCalloutMock());
        Test.startTest();
        String cartResponse = MultipleFileUploadController.cartCalloutOnSubmitMobile(appl.Id,'',1000,docCheckList.Id);
        System.assert(cartResponse != '');
        Test.stopTest();
    }
    
    @isTest
    public static void cartCalloutOnSubmitMobileTest2()
    {
        Applicant__c appl=[Select Id from Applicant__c LIMIT  1];
        Document_Master__c docMaster=[Select Id from Document_Master__c Where Name='AUWheels0006' LIMIT 1];
        Document_Checklist__c docChecklist=[Select Id from Document_Checklist__c Where Document_Master__c=:docMaster.Id LIMIT  1];     
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        ContentVersion contentVersion = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=docCheckList.Id, 
                                                                 ContentDocumentId=contentVersion.ContentDocumentId);
        insert linkedFile;
        Test.setMock(HttpCalloutMock.class, new MultipleFileUploadCalloutMock());
        Test.startTest();
        String cartResponse = MultipleFileUploadController.cartCalloutOnSubmit(null, docChecklist.Id, '', 'Bank Statement', 1000, contentVersion.Id);
        System.assert(cartResponse != '');
        Test.stopTest();
    }
    
    @isTest
    public static void updateBankStmtTest()
    {
        //CARTAddressMatchCalloutQueueable.doChainJob = false;
        //handling in after update IntegrationChecklistTriggerService
        Integration_Checklist__c intCheckList = [SELECT Id,Callback_Request__c FROM Integration_Checklist__c LIMIT 1];
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        try{
            Test.startTest();
            intCheckList.Callback_Request__c = '{"message": "call back request message","status":"Processed","data":[{"address":"Test Address","bsaCreditData":{"accountHolderName":"Test","accountNumber":"TEST001","ifsc":"SBL009867","bankName":"State Bank","branchName":"Adayar","accountType":"savings","odCcLimit":"1000000","startDate":"01/01/2022","endDate":"01/01/2030","totalCreditCount":12000.00,"totalDebitCount":1000.00,"avgMonthlyBalance":10000.00,"avgMonthlyCredits":120000.00,"inwardChequeBounce":100.00,"outwardChequeBounce":100.00,"totalEMICount":12000.00,"totalEMIAmount":1900.00,"totalSalaryAmount":190000,"monthlyBalancesDetails":[{"salary":"100000"}],"monthlyCreditsDetails":[{"creditAmount":"12000"}],"monthlyBalancesDetailsGrandTotal":{"Balance":"10000"},"monthlyCreditsDetailsGrandTotal":{"CreditAmt":10000}}}]}';
            update intCheckList;
            intCheckList.Callback_Request__c = '{"message": "call back request message","status":"Rejected"}';
            update intCheckList;
            MultipleFileUploadController.futureCalloutForSplit('Address',appl.Id,'TestNameForAddressMatch');
            MultipleFileUploadController.callNameMatchForCart('Address',appl.Id,'TestNameForNameMatch');
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }
    
    @isTest
	public static void fileuploadTest()
    {
        Document_Checklist__c docChecklist=[Select Id from Document_Checklist__c LIMIT 1];
        String str = 'Content value';
        Blob newBlob = Blob.valueOf(str);
        String contentValue = EncodingUtil.base64Encode(newBlob);
        MultipleFileUploadController.contentVersionType cvObject = new MultipleFileUploadController.contentVersionType();
        cvObject.fileName = 'PNG_Bill_Response.txt';
        cvObject.base64 = contentValue;
        cvObject.size = '10MB';
        cvObject.key = 123446;
        Test.startTest();
        ContentDocumentLink contentDocLink = MultipleFileUploadController.uploadFile(cvObject, docCheckList.Id);
        System.assert(contentDocLink != null);
        Test.stopTest();
    }
    
    @isTest
    public static void testCalculateAverageSalary(){
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        try{
            Test.startTest();
            MultipleFileUploadController.calculateAverageSalary(appl.Id);
            List<Bank_Account_Records__c> bankRecords = [SELECT Id,Analysis_Data__c FROM Bank_Account_Records__c where Applicant__c=:appl.Id];
            bankRecords[0].Analysis_Data__c = null;
            update bankRecords;
            MultipleFileUploadController.calculateAverageSalary(appl.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('Exception'+ex.getMessage());
        }
    }
}