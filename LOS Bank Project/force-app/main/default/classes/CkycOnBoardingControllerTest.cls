@isTest
public class CkycOnBoardingControllerTest {
    
    public static Applicant__c insertApplcnt() {
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
            Customer_Type__c = 'Individual',
            Loan__c        =  loanAppl.Id           
        ),true);
        
        Integration_Checklist__c  integChec  = (Integration_Checklist__c ) TestFactory.createSObject(new Integration_Checklist__c (
            Applicant__c   =  appl.Id           
        ),true);
        
        Document_Master__c    docMaster  = (Document_Master__c   ) TestFactory.createSObject(new Document_Master__c  (
             Document_Name__c    =  'Customer Image'
        ),true);
        
         Document_Master__c    docMaster2  = (Document_Master__c   ) TestFactory.createSObject(new Document_Master__c  (
             Document_Name__c    =  'Aadhaar Card'
        ),true);
        
        Document_Checklist__c   docChec  = (Document_Checklist__c  ) TestFactory.createSObject(new Document_Checklist__c (
            Applicant__c   =  appl.Id,
             Document_Master__c  = docMaster.Id
        ),true);
    
        Document_Checklist__c   docChec2  = (Document_Checklist__c  ) TestFactory.createSObject(new Document_Checklist__c (
            Applicant__c   =  appl.Id,
            Document_Master__c  = docMaster2.Id,
            Document_Number__c  = '02012323442'  
        ),true);        
        return appl;
    }
    
    public static Applicant__c insertApplcntForNonInd() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        
        Applicant__c appl  = (Applicant__c) TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Ramesh',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Sharma',
            Customer_Type__c = 'Non Individual',
            Loan__c        =  loanAppl.Id           
        ),true);
        
        Integration_Checklist__c  integChec  = (Integration_Checklist__c ) TestFactory.createSObject(new Integration_Checklist__c (
            Applicant__c   =  appl.Id           
        ),true);
        
        return appl;
    }
    
    public static void insDocumentMaster() {
        Integration_Master__c   integMasterInd  = (Integration_Master__c  ) TestFactory.createSObject(new Integration_Master__c  (
            Active__c = true,
            Name = 'CKYC Authentication',
            HTTP_Method__c = 'POST',
            End_Point_URL__c  = 'https://serviceuatsfdc.aubankuat.in/SFDCCKYCSearch'
        ),true);
    }
    
    public static void insDocumentMasterForNonInd() {
        Integration_Master__c   integMasterInd  = (Integration_Master__c  ) TestFactory.createSObject(new Integration_Master__c  (
            Active__c = true,
            Name = 'CKYC Non Individual Authentication',
            HTTP_Method__c = 'POST',
            End_Point_URL__c  = 'https://serviceuatsfdc.aubankuat.in/SFDCCKYCLegalService/Search'
        ),true);
    }
    
    public static void insIntegMasterForCkycDownload() {
        Integration_Master__c   insIntegMasterForCkycDown  = (Integration_Master__c  ) TestFactory.createSObject(new Integration_Master__c  (
            Active__c = true,
            Name = 'CKYC Download Authentication',
            HTTP_Method__c = 'POST',
            End_Point_URL__c  = 'https://serviceuatsfdc.aubankuat.in/SFDCCKYCService/download'
        ),true);
    }
    
    @isTest
    public static void searchCkycResultTestMethod() {
        
        Test.setMock(HttpCalloutMock.class, new SearchCkycResultCalloutMock('searchCkyc'));
        
        Applicant__c applcnt = insertApplcnt();
        insDocumentMaster();
        Applicant__c applcntNonInd = insertApplcntForNonInd();
        insDocumentMasterForNonInd();
        
        Test.startTest();
            CkycOnBoardingController.searchCkycResult(applcnt.Id, 'Test Search 1', 'Z', 'CKYC Authentication', '23-10-1996');
            //CkycOnBoardingController.searchCkycResult(applcntNonInd.Id, 'Test Search 2', 'A', 'Aadhaar Card', '23-10-1996');
        Test.stopTest();
    }

    @isTest
    public static void searchCkycResultTestMethod2() {
        
        Test.setMock(HttpCalloutMock.class, new SearchCkycResultCalloutMock('searchCkyc'));
        
        Applicant__c applcnt = insertApplcnt();
        insDocumentMaster();
        Applicant__c applcntNonInd = insertApplcntForNonInd();
        insDocumentMasterForNonInd();
        
        Test.startTest();
            //CkycOnBoardingController.searchCkycResult(applcnt.Id, 'Test Search 1', 'Z', 'CKYC Authentication', '23-10-1996');
            CkycOnBoardingController.searchCkycResult(applcntNonInd.Id, 'Test Search 2', 'A', 'Aadhaar Card', '23-10-1996');
        Test.stopTest();
    }
    
    @isTest
    public static void updatAndCallDownApiTestMethod() {
        
        Test.setMock(HttpCalloutMock.class, new SearchCkycResultCalloutMock('CKYCDownloadApi'));
        
        Applicant__c applData = insertApplcnt();
        insIntegMasterForCkycDownload();
        
        Test.startTest();
            CkycOnBoardingController.updatAndCallDownApi(applData, '10201301401501', 'CKYC Download Authentication', '15-06-1964');
        Test.stopTest();       
    }
    
    @isTest
    public static void remainingTestMethod() {
        
        Applicant__c appl = insertApplcnt();
        List<String> docMstrList = new List<String>{'Aadhaar Card', 'Customer Image'};
            
        CkycOnBoardingController.getCkycOptions(appl.Id);
        CkycOnBoardingController.getDocumentMaster(docMstrList);
        CkycOnBoardingController.initConsType();
    }
}