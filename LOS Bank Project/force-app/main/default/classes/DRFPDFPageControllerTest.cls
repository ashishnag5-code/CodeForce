@IsTest
public class DRFPDFPageControllerTest {
     @testsetup static void setup(){
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
            AccountId =accInstance.Id,
            UserId=UserInfo.getUserId(),
            TeamMemberRole = 'COM',
            RBM_Approval_Level__c  = 'DO 1'
        ),true);   
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Total_Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10', 
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0010',
            Document_Name__c = 'Rejection letter'
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Loan_Application__c= loanAppl.Id,
            Document_Name__c = 'Rejection letter'
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
    static void testDRFPDFControllerTest(){
        String loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        test.startTest();
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Loan_Application__c = loanId,
            Net_Amount__c = 1000,
            Name__c = 'Test',
            Bank_Name_PMT__c = 'Test Bank Name',
            Account_Number__c = '123456778890',
            IFSC_Code__c = 'SFDC'
            
        ),true);
        PageReference pageRef = Page.DRF_PDFPage; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(loanId));
        Test.setCurrentPage(pageRef);
        DRFPDFPageController.DRFPDFReturnWrapper returnWRapper = DRFPDFPageController.getPDFWrapperData();
        Test.stopTest();
    }
    
    @IsTest
    static void testWrapper(){
        Test.startTest();
        DRFPDFPageController.DRFPDFReturnWrapper returnWRapper = new DRFPDFPageController.DRFPDFReturnWrapper();
        returnWRapper.bankNumber = '111';
        returnWRapper.bankIFSC = '111';
        returnWRapper.bankName = '111';
        returnWRapper.amountInWords = '111';
        test.stopTest();
    }

}