@isTest
public class GenerateDocumentCheckListTest {
    
    @testsetup static void setup(){
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0010',
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10', 
            Tenure__c = 10
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Loan_Application__c= loanAppl.Id,
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'DocumentCompressService ',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://api.aubankuat.in/sfdc/DocumentCompressService/Compress',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        
    }
    
  
    @IsTest
    static void testSystemGeneratedDocumentFiles() {
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c checkList = [SELECT Id, Loan_Application__c, Document_Master__c, Document_Master__r.Name, Document_Name__c, Document_Master__r.Document_Name__c
                                           FROM Document_Checklist__c WHERE Loan_Application__c = :loanApp.Id];
        
        Test.setMock(PageReferenceWrapper.class, new MockPageReferenceWrapper());
        
        // Call the method under test
        Test.startTest();
        GenerateDocumentCheckList.systemGeneratedDocumentFiles(checkList,loanApp.Id);
        Test.stopTest();
    }

 // Wrapper class for PageReference
    public interface PageReferenceWrapper {
        Blob getContentAsPDF();
        // Add other methods you need to mock
    }

    // Mock PageReferenceWrapper implementation
    private class MockPageReferenceWrapper implements PageReferenceWrapper {
        public Blob getContentAsPDF() {
            // Return a mock PDF content as Blob
            return Blob.valueOf('Mock PDF content');
        }
        // Implement other mocked methods if needed
    }
}