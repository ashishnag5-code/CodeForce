@isTest
public class LightningPathLWCControllerTest {
    @testSetup
    static void setup(){
        
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
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        Integration_Master__c intMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'AML',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        
        Integration_Checklist__c intChecklist = new Integration_Checklist__c();
        intChecklist.Response__c  = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{},"ValidationErrors":[null]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChecklist.Loan_Application__c  = loanAppl.Id; 
        intChecklist.Integration_Master__c  = intMaster.Id; 
        intChecklist.Request_Id__c = '644a0f30c76c5a00e823e11e';
        intChecklist.Applicant__c=appl.Id;
        insert intChecklist;
        
        
    }
    @isTest
    public static void getLoanApplcationTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
        LightningPathLWCController.getLoanApplcation(loanAppl.Id);
        Test.stopTest();
        
    }
    @isTest
    public static void getRecordTypeVsStageMetadataRecTest(){
        Test.startTest();
        LightningPathLWCController.getRecordTypeVsStageMetadataRec('Four_Wheeler');
        Test.stopTest();
        
    }
    @isTest
    public static void getIntegrationCheckListTest(){
        Integration_Checklist__c   intChecklst=[Select Id from Integration_Checklist__c LIMIT 1];
        Test.startTest();
        LightningPathLWCController.getIntegrationCheckList(intCheckLst.Id,'AML');
        Test.stopTest();
        
    }
    
    @isTest
    public static void recordTypeVsStageMetadataHandlerTest(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Test.startTest();
        LightningPathLWCController.recordTypeVsStageMetadataHandler(loanAppl.Id);
        Test.stopTest();
        
    }
    
    
}