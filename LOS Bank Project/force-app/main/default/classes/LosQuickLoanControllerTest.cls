@isTest
public class LosQuickLoanControllerTest {
    @testSetup
    static void testDataSetup(){
         Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            Vehicle_use__c = 'Personal'
            
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            Customer_Type__c = 'Non Individual',
            Constitution_Type__c = 'Sole Proprietary'
            
        ),true);
       
        Document_Master__c   docuMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = Label.DcumentMasterAadharPicture,
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWHEEL0001',
            Individual_NI__c = 'NI',
            Constitiution__c = 'Sole Proprietary'
        ),true);
        
        Document_Master__c   docuMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name = Label.DcumentMasterAadharPicture,
            Document_Category__c = 'Application Document',
            Document_Sub_Category__c = 'KYC', 
            Document_Name__c = Label.DcumentMasterAadharPicture,
            Document_ID__c = 'AUWHEEL0002',
            Individual_NI__c = 'NI',
            Constitiution__c = 'Sole Proprietary'
        ),true);
        
        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = appl.Id,
            Document_Master__c = docuMaster.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanAppl.Id,Vehicle_Usage__c='Personal', Is_Deleted__c = false),true);
        
        Blocked_List__c objBlockList = new Blocked_List__c();
        objBlockList.Mobile__c = '9999999999';
        insert objBlockList;
     
    }
    
    @isTest
    static void createLoanApplicationTest(){
        Loan_Application__c loanApplUsed = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10203',
            Vehicle_use__c = 'Personal'
            
        ),true);
        Loan_Application__c loanAppl = [Select Id, Product__c, Sourcing_channel__c, Loan_Amount__c, Mobile__c,Branch_Master__c,Dealer_Master__c, Vehicle_use__c from Loan_Application__c limit 1];
        Applicant__c Appl = [Select Id, Loan__c, Customer_Type__c, Constitution_Type__c from Applicant__c limit 1];
        
        Test.startTest();
        LosQuickLoanController.createLoanApplication(loanAppl, Appl.Id, 'Non Individual');
        LosQuickLoanController.createLoanApplication(loanApplUsed, Appl.Id, 'Non Individual');
        LosQuickLoanController.getVisibleFieldsForLosAddIndNonInd('losAddIndNonInd', loanAppl.Id, 'Non Individual');
        LosQuickLoanController.getVisibleFieldsForLosAddIndNonInd('losAddIndNonInd', Appl.Id, 'Non Individual');
        LosQuickLoanController.getLoanApplication(loanAppl.Id);
        LosQuickLoanController.getLoanApplicationData(loanAppl.Id);
        LosQuickLoanController.getApplicant(Appl.Id);
        LosQuickLoanController.createApplicant(loanAppl, Appl.Id, 'Non Individual');
        LosQuickLoanController.fetchDefaultValues();
        LosQuickLoanController.getDealerClassNames();
        LosQuickLoanController.getRecordTypeNames();
        LosQuickLoanController.UpdateLeadToLoanWrapper returnWrapper = LosQuickLoanController.updateLeadToLoan(loanAppl.Id);
        LosQuickLoanController.updateDocChecklistRec(Appl, '');
        LosQuickLoanController.updateDocVerification(Appl, 'Not Verified');
        try{
             LosQuickLoanController.createApplicant(loanAppl, '', 'Non Individual');
        }catch(Exception e){
            
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void getVehicleUsageListTest(){
        Loan_Application__c loanAppl = [Select Id, Product__c, Sourcing_channel__c, Loan_Amount__c, Mobile__c,Branch_Master__c,Dealer_Master__c from Loan_Application__c limit 1];
        Applicant__c Appl = [Select Id, Loan__c, Customer_Type__c, Constitution_Type__c from Applicant__c limit 1];
        
        Test.startTest();
            LosQuickLoanController.getVehicleUsageList ('Auto Loan','New',loanAppl.Id);
            LosQuickLoanController.validateMobile ('9999999999');
            LosQuickLoanController.validateMobile ('9999999988');
            LosQuickLoanController.ApplicantWrapper objAppWrap = new LosQuickLoanController.ApplicantWrapper();
            objAppWrap.la = loanAppl;
            objAppWrap.app = Appl;
            
            LosQuickLoanController.CustomerTypeFieldsWrapper objCustWrap = new LosQuickLoanController.CustomerTypeFieldsWrapper();
            objCustWrap.visibleFields = new List<String>();
            objCustWrap.customerType = 'Individual';
        Test.stopTest();
        
    }
    
   

}