@IsTest
public class LOSDocumentManagerControllerTest {
    @testsetup
    static void testDataSetup() {
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        
        Document_Master__c  docMaster2 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0045',
            Document_Name__c = 'Test Doc'
            
        ),true);
        
        Document_Master__c  docMaster3 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels00099',
            Stage__c = 'PDD',
            Document_Category__c = 'Vehicle Document',
            Document_Name__c = 'Quotation/Performa Invoice'
            
        ),true);
        
        
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Loan_Amount__c = 900000;
        loanApp.Is_Verified_Number__c = true;
        loanApp.Loan_Amount__c = 900000;
        loanApp.Customer_Type__c = 'Individual';
        loanApp.Mobile__c = '8209055749';
        loanApp.Loan_Amount__c = 900000;
        loanApp.Product__c = '10201';
        loanApp.Vehicle_use__c = 'Personal';
        loanApp.Sourcing_channel__c = 'Dealer New Vehicle';
        loanApp.Customer_Grade__c = 'IB';
        LosQuickLoanController.createLoanApplication(loanApp,null,'Individual');
        Assignment__c ass = new Assignment__c(Loan_Application__c = loanApp.Id);
        insert ass;
        Collateral__c collateral = new Collateral__c();
        collateral.Insurance__c =  75000;
        collateral.Insurance__c =  75000;
        collateral.LTV_offered_On_final_cost__c =  55.66;
        collateral.Other_Funding_Total__c =  0;
        collateral.RTO_Tax__c =  'No';
        collateral.LS__c =  'No';
        //   collateral.Scheme__c =  'a2xC30000001D3FIAU';
        collateral.LTV_offered_Ex_showroom__c =  61.22;
        collateral.Accessories__c =  '23000';
        collateral.Vehicle_Category__c =  'A';
        collateral.Quantity__c =  1;
        // collateral.MMV_Master__c =  'a2dC30000000wTrIAI';
        collateral.On_Road_Price__c =  1569000;
        collateral.Customer_equity__c =  669000;
        collateral.LTV_offered_On_road__c =  57.36;
        collateral.Accessories_Funding__c =  'No';
        collateral.Assessment_Method__c =  '12212';
        collateral.Final_Cost__c =  1617000;
        // collateral.Collateral_ID__c =  '102010000000649';
        collateral.Fuel_Type__c =  'PETROL';
        collateral.Manufacture_year_month__c =  '202302';
        collateral.Ex_Showroom_Price__c =  1500000;
        collateral.Collateral_Type__c =  'New';
        collateral.Vehicle_Color__c =  'Wine red';
        collateral.Insurance_Funding__c =  'No';
        collateral.Loan_Eligibilty__c =  '0.00';
        collateral.Other_Costs__c =  25000;
        collateral.Apportioned_Loan_Amount__c =  900000;
        collateral.Vehicle_Usage__c =  'Personal';
        collateral.Discount__c =  30000;
        collateral.Engine_Category__c =  'BS6';
        collateral.Collateral_Name__c =  '10101';
        collateral.Net_of_Discount_Price__c =  1470000;
        collateral.RTO_Taxes__c =  24000;
        collateral.Loan__c =  loanApp.Id;
        collateral.Body__c =  'No';
        AUSFVehicleController.upsertCollateral(collateral,'New',new List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>(),null);
        List<Applicant__c> apps = [SELECT Id FROM Applicant__c Where Loan__c =: loanApp.Id];
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = apps[0].Id
        ),true);
        
        Document_Checklist__c   docChecklst2 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster2.Id,
            Loan_Application__c    = loanApp.Id
        ),true);
        
        Document_Checklist__c   docChecklst3 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster3.Id,
            Collateral__c = collateral.Id
        ),true);
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChecklst.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
    }
    
    @isTest
    public static void testgetApplicants(){
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
        List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
        System.assertEquals(apps.isEmpty(), false);
    }
    
    @isTest
    public static void testgetDocumentChecklist(){
        Test.startTest();
            List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
            List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
            String result =  LOSDocumentManagerController.getDocumentChecklist(loanApps[0].Id,'Loan_Application__c');
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklist(apps[0].Id,'Applicant__c');
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklist(loanApps[0].Id,'pddMaker');
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklist(loanApps[0].Id,'Vehicle Document');
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklist(loanApps[0].Id,'pddMaker');
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklist(loanApps[0].Id,'pddMaker');
            Assignment__c ass = [SELECT Id FROM Assignment__c limit 1];
            result =  LOSDocumentManagerController.getDocumentChecklist(ass.Id,'Assignment__c');
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    
    
    @isTest
    public static void testgetDocumentChecklistOptional(){
        Test.startTest();
            List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
            List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
            String result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'Loan_Application__c',true);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(apps[0].Id,'Applicant__c',true);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',true);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'Vehicle Document',true);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',true);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',true);
            Assignment__c ass = [SELECT Id FROM Assignment__c limit 1];
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(ass.Id,'Assignment__c',true);
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    
        @isTest
    public static void testgetDocumentChecklistOptional2(){
        Test.startTest();
            List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
            List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
            String result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'Loan_Application__c',false);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(apps[0].Id,'Applicant__c',false);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',false);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'Vehicle Document',false);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',false);
            System.assertEquals(String.isBlank(result), false);
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(loanApps[0].Id,'pddMaker',false);
            Assignment__c ass = [SELECT Id FROM Assignment__c limit 1];
            result =  LOSDocumentManagerController.getDocumentChecklistOptional(ass.Id,'Assignment__c',false);
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    
    @isTest
    public static void testsaveDocumentChecklist(){
        Test.startTest();
        
            List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
            List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
            String result =  LOSDocumentManagerController.getDocumentChecklist(apps[0].Id,'Applicant__c');
            LOSDocumentManagerController.ResultWrapper wrapper = (LOSDocumentManagerController.ResultWrapper) JSON.deserialize(result, LOSDocumentManagerController.ResultWrapper.Class);
            Map<String,Object> response = new Map<String,Object>();
            response.put('wrapper',wrapper.docChkRecords);
            response.put('loanId',loanApps[0].Id);
            System.debug('JSON----->' + JSON.serialize(response));
            LOSDocumentManagerController.saveDocList(JSON.serialize(response));
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    
    @isTest
    public static void testdeactivateDocument(){
        Test.startTest();
            List<ContentVersion> cvs = [SELECT Id FROM ContentVersion Limit 1];
            String result = LOSDocumentManagerController.deactivateDocument(cvs[0].Id);
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    @isTest
    public static void testdeactivateDocumentNegetive(){
        Test.startTest();
            String result = LOSDocumentManagerController.deactivateDocument(null);
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetAssignment(){
        Test.startTest();
            Assignment__c ass = new Assignment__c();
            insert ass;
            List<Assignment__c> recordList = LOSDocumentManagerController.getAssignmentRecord(ass.Id);
            System.assertEquals(recordList != null, true);
        Test.stopTest();   
    }
    @isTest
    public static void testcheckFTRStatus(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Loan_Application__c FROM Document_Checklist__c Where Loan_Application__c != null Limit 1];
            String result = LOSDocumentManagerController.checkFTRStatus(String.valueOf(docs[0].Id),String.valueOf(docs[0].Loan_Application__c));
            System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }
    @isTest
    public static void testretrieveRecords(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Loan_Application__c FROM Document_Checklist__c Where Loan_Application__c != null Limit 1];
            list<sObject> result = LOSDocumentManagerController.retrieveRecords('Test','Loan_Application__c',String.valueOf(docs[0].Loan_Application__c),'');
            System.assertEquals(result.isEmpty(), false);
        Test.stopTest();
    }
    @isTest
    public static void testretrieveRecords2(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Loan_Application__c FROM Document_Checklist__c Where Loan_Application__c != null Limit 1];
            list<sObject> result = LOSDocumentManagerController.retrieveRecords('Quotation','Vehicle Document',String.valueOf(docs[0].Loan_Application__c),'');
           // System.assertEquals(result.isEmpty(), false);
        Test.stopTest();
    }
    @isTest
    public static void testretrieveRecords22(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Loan_Application__c FROM Document_Checklist__c Where Loan_Application__c != null Limit 1];
            list<sObject> result = LOSDocumentManagerController.retrieveRecords('Quotation','pddMaker',String.valueOf(docs[0].Loan_Application__c),'');
           // System.assertEquals(result.isEmpty(), false);
        Test.stopTest();
    }
     @isTest
    public static void testretrieveRecords4(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Loan_Application__c FROM Document_Checklist__c Where Loan_Application__c != null Limit 1];
            list<sObject> result = LOSDocumentManagerController.retrieveRecords('Quotation','pddMaker',String.valueOf(docs[0].Loan_Application__c),'');
           // System.assertEquals(result.isEmpty(), false);
        Test.stopTest();
    }
    @isTest
    public static void testretrieveRecords3(){
        Test.startTest();
            List<Document_Checklist__c> docs = [SELECT Id,Applicant__c FROM Document_Checklist__c Where Applicant__c != null Limit 1];
            list<sObject> result = LOSDocumentManagerController.retrieveRecords('Application','Applicant__c','',String.valueOf(docs[0].Applicant__c));
           // System.assertEquals(result.isEmpty(), false);
        Test.stopTest();
    }
    @isTest
    public static void testUpdateEMandateStatus(){
        Test.startTest();
		List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c Limit 1];
        String result = LOSDocumentManagerController.updateEMandateStatus(String.valueOf(loanApps[0].Id));
        System.assertEquals(String.isNotBlank(result), true);
        Test.stopTest();
    }
    @isTest
    public static void testisValidStageCheckProfileCheck(){
        Test.startTest();
		List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c Limit 1];
        Boolean result = LOSDocumentManagerController.isValidStageCheckProfileCheck(String.valueOf(loanApps[0].Id));
      //  System.assertEquals(String.isNotBlank(result), true);
        Test.stopTest();
    }
}