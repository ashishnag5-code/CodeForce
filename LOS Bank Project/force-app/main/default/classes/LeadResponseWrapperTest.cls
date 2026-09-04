@isTest
public class LeadResponseWrapperTest {
    @isTest static void leadWrapperTest(){
        LeadResponseWrapper.Address addressWrapper=  new LeadResponseWrapper.Address();
        addressWrapper.addresstype='testtype';
        addressWrapper.addressid='testid';
        addressWrapper.status='teststatus';
        
        LeadResponseWrapper.DocumentDetail documentWrapper = new LeadResponseWrapper.DocumentDetail();
        documentWrapper.documentId='documentId';
        documentWrapper.documentname='testname';
        documentWrapper.status='teststatus';
        
        LeadResponseWrapper.FinanceSalary financeSalary = new LeadResponseWrapper.FinanceSalary();
        financeSalary.recordid = 'testRecord';
        financeSalary.status = 'teststatus';
        
        LeadResponseWrapper.FinanceAssessedNodocument financeAssess = new LeadResponseWrapper.FinanceAssessedNodocument();
        financeAssess.recordid = 'test';
        financeAssess.status = 'teststatus';
        
        LeadResponseWrapper.FinanceDocumentWithAudit financeAudit = new LeadResponseWrapper.FinanceDocumentWithAudit();
        financeAudit.recordid = 'testid';
        financeAudit.status = 'teststatus';
        
        LeadResponseWrapper.FinanceDocumentWithoutAudit financeWithoutAudit = new LeadResponseWrapper.FinanceDocumentWithoutAudit();
        financeWithoutAudit.recordid = 'testid';
        financeWithoutAudit.status = 'teststatus';
        
        LeadResponseWrapper.FinanceAgriOwnorRentLand financeRent = new LeadResponseWrapper.FinanceAgriOwnorRentLand();
        financeRent.recordid = 'testid';
        financeRent.status = 'teststatus';
        
        LeadResponseWrapper.FinanceFarmerCommercial financeCommer = new LeadResponseWrapper.FinanceFarmerCommercial();
        financeCommer.recordid = '';
        financeCommer.status = '';
        
        LeadResponseWrapper.FinanceDairyBusiness financeBusiness = new LeadResponseWrapper.FinanceDairyBusiness();
        financeBusiness.recordid = 'testid';
        financeBusiness.status = 'teststatus';
        
        LeadResponseWrapper.FinanceOtherIncome financeIncome = new LeadResponseWrapper.FinanceOtherIncome();
        financeIncome.recordid = 'testid';
        financeIncome.status = 'teststatus';
        
        LeadResponseWrapper.Finance financeWrapper = new LeadResponseWrapper.Finance();
        financeWrapper.recordid = '';
        financeWrapper.status = '';
        financeWrapper.finotherIncome=null;
        financeWrapper.findairybusiness=null;
        financeWrapper.finfarmercommercial=null;
        financeWrapper.finagriownorrentland=null;
        financeWrapper.findocumentwithaudit=null;
        financeWrapper.findocumentwithoutaudit=null;
        financeWrapper.finaddresswithoutdocument=null;
        financeWrapper.finsalary=null;
        
        
        
        
        
        
        LeadResponseWrapper.Vehicle vehicleWrapper = new LeadResponseWrapper.Vehicle();
        vehicleWrapper.recordid = '';
        vehicleWrapper.status ='';
        vehicleWrapper.detailsvaluation= null;
        
        LeadResponseWrapper.Valuations valuations = new LeadResponseWrapper.Valuations();
        valuations.recordid = '';
        valuations.status='';
        
        LeadResponseWrapper.Charge chargeWrapper= new  LeadResponseWrapper.Charge();
        chargeWrapper.recordid = '';
        chargeWrapper.status='';
        
        LeadResponseWrapper.Document doc = new LeadResponseWrapper.Document();
        doc.recordid = '';
        doc.status='';
        
        LeadResponseWrapper.Applicant applicantWrapp = new  LeadResponseWrapper.Applicant();
        applicantWrapp.applicantId='';
        applicantWrapp.applicanttype='';
        applicantWrapp.detailsaddress=null;
        applicantWrapp.detailsapplicantdocument=null;
        applicantWrapp.detailsfinance=null;
        
        LeadResponseWrapper.response respoWrapp = new LeadResponseWrapper.response();
        respoWrapp.status = 'test';
        respoWrapp.loanId = 'test';
        respoWrapp.leadId='';
        respoWrapp.errormsg='';
        respoWrapp.detailsapplicant=null;
        respoWrapp.detailsvehicle=null;
        respoWrapp.detailscharge=null;
        respoWrapp.detailsappdocument=null;
        respoWrapp.duration=0;
        

        
    }
    
     @IsTest
    static void testLeadResponseWrapper() {
        // Create test data
        LeadResponseWrapper.response leadResponse = new LeadResponseWrapper.response();
        
        // Set response values
        leadResponse.success = true;
        leadResponse.error = false;
        leadResponse.status = 'Success';
        leadResponse.loanId = '123456';
        leadResponse.leadId = '7890';
        leadResponse.errormsg = '';
        leadResponse.detailsapplicant = new List<LeadResponseWrapper.Applicant>();
        leadResponse.detailsvehicle = new LeadResponseWrapper.Vehicle();
        leadResponse.detailscharge = new List<LeadResponseWrapper.Charge>();
        leadResponse.detailsappdocument = new List<LeadResponseWrapper.DocumentDetail>();
        leadResponse.duration = 12.5;
        
        // Set Applicant values
        LeadResponseWrapper.Applicant applicant = new LeadResponseWrapper.Applicant();
        applicant.applicantId = '5678';
        applicant.applicanttype = 'Individual';
        applicant.detailsaddress = new List<LeadResponseWrapper.Address>();
        applicant.detailsapplicantdocument = new List<LeadResponseWrapper.DocumentDetail>();
        applicant.detailsfinance = new LeadResponseWrapper.Finance();
        leadResponse.detailsapplicant.add(applicant);
        
        // Set Address values
        LeadResponseWrapper.Address address = new LeadResponseWrapper.Address();
        address.addresstype = 'Residential';
        address.addressid = '9876';
        address.status = 'Active';
        applicant.detailsaddress.add(address);
        
        // Set DocumentDetail values
        LeadResponseWrapper.DocumentDetail documentDetail = new LeadResponseWrapper.DocumentDetail();
        documentDetail.documentId = '6543';
        documentDetail.documentname = 'ID Proof';
        documentDetail.status = 'Submitted';
        applicant.detailsapplicantdocument.add(documentDetail);
        
        // Set Vehicle values
        leadResponse.detailsvehicle.recordid = '2345';
        leadResponse.detailsvehicle.status = 'Active';
        leadResponse.detailsvehicle.detailsvaluation = new List<LeadResponseWrapper.Valuations>();
        
        // Set Valuations values
        LeadResponseWrapper.Valuations valuations = new LeadResponseWrapper.Valuations();
        valuations.recordid = '8765';
        valuations.status = 'Approved';
        leadResponse.detailsvehicle.detailsvaluation.add(valuations);
        
        // Set Charge values
        LeadResponseWrapper.Charge charge = new LeadResponseWrapper.Charge();
        charge.recordid = '8765';
        charge.status = 'Pending';
        leadResponse.detailscharge.add(charge);
        
        // Set DocumentDetail values
        LeadResponseWrapper.DocumentDetail appDocument = new LeadResponseWrapper.DocumentDetail();
        appDocument.documentId = '4321';
        appDocument.documentname = 'Application Form';
        appDocument.status = 'Submitted';
        leadResponse.detailsappdocument.add(appDocument);
        
        // Verify response values
        System.assertEquals(true, leadResponse.success, 'success should be set correctly');
        System.assertEquals(false, leadResponse.error, 'error should be set correctly');
        System.assertEquals('Success', leadResponse.status, 'status should be set correctly');
        System.assertEquals('123456', leadResponse.loanId, 'loanId should be set correctly');
        System.assertEquals('7890', leadResponse.leadId, 'leadId should be set correctly');
        System.assertEquals('', leadResponse.errormsg, 'errormsg should be set correctly');
        
        // Verify Applicant values
        System.assertEquals(1, leadResponse.detailsapplicant.size(), 'detailsapplicant should have one item');
        LeadResponseWrapper.Applicant verifiedApplicant = leadResponse.detailsapplicant[0];
        System.assertEquals('5678', verifiedApplicant.applicantId, 'applicantId should be set correctly');
        System.assertEquals('Individual', verifiedApplicant.applicanttype, 'applicanttype should be set correctly');
        System.assertEquals(1, verifiedApplicant.detailsaddress.size(), 'detailsaddress should have one item');
        System.assertEquals(1, verifiedApplicant.detailsapplicantdocument.size(), 'detailsapplicantdocument should have one item');
        System.assertNotEquals(null, verifiedApplicant.detailsfinance, 'detailsfinance should not be null');
        
        // Verify Address values
        LeadResponseWrapper.Address verifiedAddress = verifiedApplicant.detailsaddress[0];
        System.assertEquals('Residential', verifiedAddress.addresstype, 'addresstype should be set correctly');
        System.assertEquals('9876', verifiedAddress.addressid, 'addressid should be set correctly');
        System.assertEquals('Active', verifiedAddress.status, 'status should be set correctly');
        
        // Verify DocumentDetail values
        LeadResponseWrapper.DocumentDetail verifiedDocument = verifiedApplicant.detailsapplicantdocument[0];
        System.assertEquals('6543', verifiedDocument.documentId, 'documentId should be set correctly');
        System.assertEquals('ID Proof', verifiedDocument.documentname, 'documentname should be set correctly');
        System.assertEquals('Submitted', verifiedDocument.status, 'status should be set correctly');
        
        // Verify Vehicle values
        System.assertEquals('2345', leadResponse.detailsvehicle.recordid, 'recordid should be set correctly');
        System.assertEquals('Active', leadResponse.detailsvehicle.status, 'status should be set correctly');
        System.assertEquals(1, leadResponse.detailsvehicle.detailsvaluation.size(), 'detailsvaluation should have one item');
        
        // Verify Valuations values
        LeadResponseWrapper.Valuations verifiedValuations = leadResponse.detailsvehicle.detailsvaluation[0];
        System.assertEquals('8765', verifiedValuations.recordid, 'recordid should be set correctly');
        System.assertEquals('Approved', verifiedValuations.status, 'status should be set correctly');
        
        // Verify Charge values
        System.assertEquals(1, leadResponse.detailscharge.size(), 'detailscharge should have one item');
        LeadResponseWrapper.Charge verifiedCharge = leadResponse.detailscharge[0];
        System.assertEquals('8765', verifiedCharge.recordid, 'recordid should be set correctly');
        System.assertEquals('Pending', verifiedCharge.status, 'status should be set correctly');
        
        // Verify DocumentDetail values
        System.assertEquals(1, leadResponse.detailsappdocument.size(), 'detailsappdocument should have one item');
        LeadResponseWrapper.DocumentDetail verifiedAppDocument = leadResponse.detailsappdocument[0];
        System.assertEquals('4321', verifiedAppDocument.documentId, 'documentId should be set correctly');
        System.assertEquals('Application Form', verifiedAppDocument.documentname, 'documentname should be set correctly');
        System.assertEquals('Submitted', verifiedAppDocument.status, 'status should be set correctly');
    }
}