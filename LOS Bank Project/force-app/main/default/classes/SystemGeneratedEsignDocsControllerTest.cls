@isTest
public class SystemGeneratedEsignDocsControllerTest {

    @testSetup static void setup() {  
        List<Generic_Master__c> lstGenMaster = new List<Generic_Master__c>();
        Generic_Master__c genericMaster = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'Hey', Letter_Content__c = 'Hey', Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking'),false);
        lstGenMaster.add(genericMaster);
        
        Generic_Master__c genericMaster1 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'MITC', Letter_Content__c = 'MITC', Letter_Name__c = 'Loan Agreement'),false);
        lstGenMaster.add(genericMaster1);
        Generic_Master__c genericMaster2 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'Third Part Loan Agreement', Letter_Content__c = 'Third Part Loan Agreement', Letter_Name__c = 'Loan Agreement'),false);
        lstGenMaster.add(genericMaster2);
        
        Generic_Master__c genericMaster3 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'Declaration', Letter_Content__c = 'Declaration', Letter_Name__c = 'Loan Agreement'),false);
        lstGenMaster.add(genericMaster3);
        
        Generic_Master__c genericMaster4 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'Loan Cum Hypothecation', Letter_Content__c = 'Loan Cum Hypothecation', Letter_Name__c = 'Loan Agreement'),false);
        lstGenMaster.add(genericMaster4);
        
        Generic_Master__c genericMaster5 = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
            RecordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Auto Generated Letters Content').getRecordTypeId(), 
            Name__c = 'Hiii', Letter_Content__c = 'Hiii', Letter_Name__c = 'Loan Agreement'),false);
        lstGenMaster.add(genericMaster5);
        
        insert lstGenMaster;
        
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
          	Customer_Name__c = 'Test Customer', Stage__c = 'Pricing', Product__c = '10301', Total_Loan_Amount__c = 10000.0,EMI_Date__c = '10',
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId(),
        First_EMI_Date__c = system.today()),true);
        
        Payment__c payment = (Payment__c)TestFactory.createSObject(new Payment__c(
            RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId(), 
            Name__c = 'Test Payment', Net_Amount__c = 123.45, Loan_Application__c = loanApp.Id, Inactive__c = false, 
        	Beneficiary_Name__c = 'Test Beneficiary Name'),true);
        
        List<Applicant__c> lstApp = new List<Applicant__c>();
        Applicant__c applicant1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test', Last_Name__c = 'User 2', Loan__c = loanApp.Id, isInactive__c = false, 
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()),false);
        lstApp.add(applicant1);
        Applicant__c applicant2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test', Last_Name__c = 'User 2', Loan__c = loanApp.Id, isInactive__c = false, 
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId()),false);
        lstApp.add(applicant2);
        Applicant__c applicant3 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test', Last_Name__c = 'User 3', Loan__c = loanApp.Id, isInactive__c = false, 
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId()),false);
        lstApp.add(applicant3);
        insert lstApp;
        List<MMV_Master__c> lstMMVMaster = new List<MMV_Master__c>();
        MMV_Master__c mmvMake = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
        	Name = 'Test Make', RecordTypeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Make').getRecordTypeId()),true);
        MMV_Master__c mmvModel = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
        	Name = 'Test Model', RecordTypeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Model').getRecordTypeId()),true);
        MMV_Master__c mmvMaster = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
        	Name = 'Test MMV Master', Make__c = mmvMake.Id, Model__c = mmvModel.Id, 
            RecordTypeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByName().get('Variant').getRecordTypeId()),true);
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Loan__c = loanApp.Id, MMV_Master__c = mmvMaster.Id),true);
        Charge__c chrg1 = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanApp.Id, Charges_Name__c = 'Processing Fees', Total_Amount__c = 100.0, Charge_Amount__c = 100),true);
    	
        List<Charge__c> lstCharge = new List<Charge__c>();
        Charge__c chrg2 = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanApp.Id, Charges_Name__c = 'Stamp duty', Total_Amount__c = 100.0),false);
        lstCharge.add(chrg2);
    
        Charge__c chrg3 = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanApp.Id, Charges_Name__c = 'Documentation Charges', Total_Amount__c = 100.0),false);
        lstCharge.add(chrg3);
    
        Charge__c chrg4 = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanApp.Id, Charges_Name__c = 'RC Charges', Total_Amount__c = 100.0),false);
        lstCharge.add(chrg4);
    	
        Charge__c chrg5 = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanApp.Id, Charges_Name__c = 'Cibil charges', Total_Amount__c = 100.0),false);
        lstCharge.add(chrg5);
        insert lstCharge;
        
        List<Document_Master__c> docMasterList = new List<Document_Master__c>();
        List<String> lstStr = new List<String>{'AUWheels0073','AUWheels0030','AUWheels0031','AUWheels0032','AUWheels0035','AUWheels0041',
            'AUWheels0052','AUWheels0051','AUWheels0025','AUWheels0026','AUWheels0117'};
        for(String str: lstStr){
            Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
                Name = str, Document_Name__c = 'Test Doc 1', Consider_for_E_Sign__c = true),false);
            docMasterList.add(docMaster);
        }
        insert docMasterList;
        List<Document_Checklist__c> docchkList = New List<Document_Checklist__c>();
        for(Document_Master__c doc: docMasterList){
        Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c = LoanApp.Id, Document_Master__c = doc.Id, Collateral__c = collat.Id),false);
            docchkList.add(docChecklist);
        }
		insert docchkList;
    }	
    
    /* Create a mock PageReference with parameters
        Map<String, String> pageParameters = new Map<String, String>();
        pageParameters.put('id', recordId);
        Test.setCurrentPageReference(new PageReference('/apex/yourPageName', null, pageParameters));*/

    @isTest
    static void testSystemGeneratedEsignDocumentsController() {

        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        // Instantiate the SystemGeneratedEsignDocumentsController
        Test.startTest();
        apexpages.currentpage().getparameters().put('id' , loanApp.Id);
        SystemGeneratedEsignDocumentsController controller = new SystemGeneratedEsignDocumentsController();
        Test.stopTest();
    }
    
    @isTest
    static void testGetObjGenericMaster() {

        // Call the getObjGenericMaster method
        Test.startTest();
        SystemGeneratedEsignDocumentsController.getObjGenericMaster();
        Test.stopTest();
    }

    @isTest
    static void testGetLoanAgreementContentsName() {

        // Call the getLoanAgreementContentsName method
        Test.startTest();
        SystemGeneratedEsignDocumentsController.getLoanAgreementContentsName();
        Test.stopTest();
    }

    @isTest
    static void testGetLoanDetails() {

        // Call the getLoanDetails method
        Test.startTest();
        SystemGeneratedEsignDocumentsController.getLoanDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testcoverage() {

        // Call the getLoanDetails method
        Test.startTest();
        Charge__c charg = [Select id,Charges_Name__c, Charge_Amount__c,Total_Amount__c,Tax_Percentage__c from Charge__c limit 1];
        SystemGeneratedEsignDocumentsController.ChargesWrapper chargw = New SystemGeneratedEsignDocumentsController.ChargesWrapper(charg);
        SystemGeneratedEsignDocumentsController.calculateEMIDate('10', 10, true, system.today());
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        PageReference pageRef = Page.SystemGeneratedDocumentsForEsign;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(loanApp);
        ApexPages.currentPage().getParameters().put('Id',loanApp.id);
        SystemGeneratedEsignDocumentsController ctrl = new SystemGeneratedEsignDocumentsController(new ApplicationFormPDFController()); 
        Test.stopTest();
    }
}