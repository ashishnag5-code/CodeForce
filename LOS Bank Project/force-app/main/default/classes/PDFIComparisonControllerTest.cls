@isTest
public class PDFIComparisonControllerTest {
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
        
        Account dealerAccount =(Account )TestFactory.createSObject(new Account (
            Name ='Dealer Account',
            Account_Code__c='2105',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            EMI_Frequency__c = 'MONTHLY',
            Dealer_Master__c=dealerAccount.Id,
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Address__c addressCurrent = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Type__c = 'Current',
            Source_Type__c = null,
            Applicant__c = appl.Id
        ),true);
        
        Field_Investigation__c fieldInvestigationObj= (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c( 
            Name = appl.First_Name__c,
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='POSITIVE',
            Proposed_vehicle__c=GlobalConstants.AUTOLOANNEW,
            Applicant_Type__c='Applicant',
            Re_Trigger__c = false,
            Type_of_Address__c='Current',
            Address_lookup__c = addressCurrent.Id
        ),true);
        
        String pdDetails = '[{"name":"Type_of_Accommodation","value":"Katcha"},{"name":"Asset_Delivery_Status","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"label\":\"Asset\",\"fieldName\":\"assetLabel\"},{\"editable\":\"true\",\"type\":\"picklist\",\"label\":\"Details\",\"fieldName\":\"inputField\",\"options\":\"Yes;No\"}],\"tableData\":[{\"id\":\"a2IHE0000000sA52AI\",\"assetLabel\":\"0000019386\",\"inputField\":\"Yes\"},{\"id\":\"a2IHE000000138j2AA\",\"assetLabel\":\"0000019478\",\"inputField\":\"Yes\"}]}}},{"name":"Asset_Delivery_Status_FI","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"label\":\"Asset\",\"fieldName\":\"assetLabel\"},{\"editable\":\"true\",\"type\":\"picklist\",\"label\":\"Details\",\"fieldName\":\"inputField\",\"options\":\"Yes;No\"}],\"tableData\":[{\"id\":\"a2IHE0000000sA52AI\",\"assetLabel\":\"0000019386\",\"inputField\":\"Yes\"},{\"id\":\"a2IHE000000138j2AA\",\"assetLabel\":\"0000019478\",\"inputField\":\"Yes\"}]}}},{"name":"SECTION_B_Tractor","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"fieldName\":\"secAsset1\",\"label\":\"Asset ( Movable)\"},{\"editable\":\"true\",\"type\":\"text\",\"fieldName\":\"secApproxVal2\",\"label\":\"Approx Value (Rs.)\"}],\"tableData\":[{\"id\":\"1\",\"secAsset1\":\"Milch Animals\",\"secNo1\":\"2\",\"secApproxVal1\":\"10\",\"secAsset2\":\"House / Building\",\"secNo2\":\"\",\"secApproxVal2\":\"\"},{\"id\":\"8\",\"secAsset1\":\"Other asset/Farm\",\"secNo1\":\"\",\"secApproxVal1\":\"\",\"secAsset2\":\"Any other immovable assets\",\"secNo2\":\"\",\"secApproxVal2\":\"\"},{\"id\":\"9\",\"secAsset1\":\"Implements\",\"secNo1\":\"\",\"secApproxVal1\":\"\",\"secAsset2\":\"\",\"secNo2\":\"\",\"secApproxVal2\":\"\"}]}}},{"name":"SECTION_B_Tractor_FI","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"fieldName\":\"secAsset1\",\"label\":\"Asset ( Movable)\"},{\"editable\":\"true\",\"type\":\"text\",\"fieldName\":\"secApproxVal2\",\"label\":\"Approx Value (Rs.)\"}],\"tableData\":[{\"id\":\"1\",\"secAsset1\":\"Milch Animals\",\"secNo1\":\"2\",\"secApproxVal1\":\"10\",\"secAsset2\":\"House / Building\",\"secNo2\":\"\",\"secApproxVal2\":\"\"},{\"id\":\"8\",\"secAsset1\":\"Other asset/Farm\",\"secNo1\":\"\",\"secApproxVal1\":\"\",\"secAsset2\":\"Any other immovable assets\",\"secNo2\":\"\",\"secApproxVal2\":\"\"},{\"id\":\"9\",\"secAsset1\":\"Implements\",\"secNo1\":\"\",\"secApproxVal1\":\"\",\"secAsset2\":\"\",\"secNo2\":\"\",\"secApproxVal2\":\"\"}]}}},{"name":"LAND_HOLDING_DETAILS_ACRE","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"fieldName\":\"landHeadRow\",\"label\":\"Category\"},{\"editable\":\"true\",\"type\":\"text\",\"fieldName\":\"landAnotherTwoRow\",\"label\":\"Details\"}],\"tableData\":[{\"id\":\"1\",\"landHeadRow\":\"Name of Land Holder\",\"landAnotherOneRow\":\"10\",\"landAnotherTwoRow\":\"\"},{\"id\":\"7\",\"landHeadRow\":\"Source of Irrigation\",\"landAnotherOneRow\":\"\",\"landAnotherTwoRow\":\"20\"}]}}},{"name":"LAND_HOLDING_DETAILS_ACRE_FI","value":{\"value\":{\"tableDefinition\":[{\"editable\":\"false\",\"type\":\"text\",\"fieldName\":\"landHeadRow\",\"label\":\"Category\"},{\"editable\":\"true\",\"type\":\"text\",\"fieldName\":\"landAnotherTwoRow\",\"label\":\"Details\"}],\"tableData\":[{\"id\":\"1\",\"landHeadRow\":\"Name of Land Holder\",\"landAnotherOneRow\":\"10\",\"landAnotherTwoRow\":\"\"},{\"id\":\"7\",\"landHeadRow\":\"Source of Irrigation\",\"landAnotherOneRow\":\"\",\"landAnotherTwoRow\":\"20\"}]}}},{"name":"Tractor_Attachment_Implement_Photo_FI","value":["Cultivator","Loader"]}]';
            ContentVersion contentVersion = new ContentVersion(
            Title = 'Personal Discussion',
            PathOnClient = 'Personal Discussion.txt',
            Document_Type__c = 'Personal Discussion',
            Request_id__c ='Req1',
            VersionData = Blob.valueOf(pdDetails),
            Origin = 'H'
        );
        insert contentVersion; 
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = loanAppl.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        cdlList.add(cdl);
        
        ContentDocumentLink cdlFI = New ContentDocumentLink();
        cdlFI.LinkedEntityId = fieldInvestigationObj.Id;
        cdlFI.ContentDocumentId = conDocId;
        cdlFI.shareType = 'V';
        cdlList.add(cdlFI);
        insert cdlList;
        
    }
    
    @isTest
    public static void testFetchDetails() {
        Loan_Application__c loanApp = [SELECT Id from Loan_Application__c];
        Test.startTest();
        PDFIComparisonController.ReturnWrapper rw = PDFIComparisonController.fetchDetails(loanApp.Id);
        Test.stopTest();
        System.AssertEquals(null,rw.errorMessage);
    }

}