public with sharing class SummaryPageWrapperController {
    
    public class ApplicationDetailWrapper {
        @AuraENabled
        public String loanType{get;set;}
        @AuraEnabled
        public String sourcingChannel{get;set;}
        @AuraENabled
        public String loanAmount{get;set;}
        @AuraENabled
        public String model{get;set;}
        @AuraENabled
        public String scheme{get;set;}
        @AuraENabled
        public Boolean preapproved{get;set;}
        @AuraENabled
        public String vehicleType{get;set;}
        @AuraENabled
        public String customerType{get;set;}
        @AuraENabled
        public String dealerName{get;set;}
        @AuraENabled
        public String methodOfAssessment{get;set;}
        @AuraENabled
        public String manufacturingYear{get;set;}
        @AuraENabled
        public String campaign{get;set;}

        @AuraEnabled public String applicationId{get;set;}
        @AuraENabled public String opsFTR{get;set;}
        @AuraENabled public String creditFTR{get;set;}
        @AuraENabled public String applicationDate{get;set;}
        public ApplicationDetailWrapper(){
            this.loanType = '';
            this.sourcingChannel = '';
            this.loanAmount = '';
            this.model = '';
            this.scheme = '';
            this.preapproved = false;
            this.vehicleType = '';
            this.customerType = '';
            this.dealerName = '';
            this.methodOfAssessment = '';
            this.campaign = '';
            this.manufacturingYear = '';
        }
        
    }

    public class ApplicantDetailWrapper {
        @AuraEnabled
        public String applicantId{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String mobileNumber{get;set;}
        @AuraEnabled
        public String cibil{get;set;}
        @AuraEnabled
        public String cfr{get;set;}
        @AuraEnabled
        public String aml{get;set;}
        @AuraEnabled
        public String negativeCheck{get;set;}
        @AuraEnabled
        public String pendingDocuments{get;set;}
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String address{get;set;}
        @AuraEnabled
        public String fi{get;set;}
        @AuraEnabled
        public String allValidation{get;set;}
        @AuraEnabled
        public String valuationStatus{get;set;}
        @AuraEnabled
        public String fatherName{get;set;}
        @AuraEnabled
        public String customerEntity{get;set;}
        @AuraEnabled
        public String insuranceType{get;set;}
        @AuraEnabled
        public String psl{get;set;}
        @AuraEnabled
        public String caseCategory{get;set;}
        @AuraEnabled
        public String valuationType{get;set;}
        @AuraEnabled
        public String cif{get;set;}
        @AuraEnabled
        public Boolean disableFetchButton{get;set;}
        @AuraEnabled public Boolean displayValuationStatus{get;set;}
        @AuraEnabled public String cibilUrl{get;set;}
        @AuraEnabled public String fiLink{get;set;}
        @AuraEnabled public String fiFieldName{get;set;}
        
        public ApplicantDetailWrapper(){
            this.applicantId = '';
            this.name = '';
            this.mobileNumber = '';
            this.cibil = '';
            this.cfr = '';
            this.pendingDocuments = '';
            this.type = '';
            this.address = '';
            this.fi = '';
            this.allValidation = '';
            this.valuationStatus = '';
            this.disableFetchButton = true;
            this.fatherName = '';
            this.customerEntity = '';
            this.insuranceType = '';
            this.psl = '';
            this.caseCategory = '';
            this.valuationType = '';
            this.cif = '';
            this.aml = '';
            this.negativeCheck = '';
            this.displayValuationStatus = false;
            this.fiLink = '';
            this.fiFieldName = '';
            
        }


    }
    
    public class ApprovalDetailWrapper {
        @AuraEnabled
        public Boolean isTwoWheeler{get;set;}
        @AuraEnabled
        public String twoWheelerLevel{get;set;}
        @AuraEnabled
        public ApprovalInnerWrapper[] creditApprover{get;set;}
        @AuraEnabled
        public ApprovalInnerWrapper[] pricingApprover{get;set;}
        public ApprovalDetailWrapper() {
            this.creditApprover = new ApprovalInnerWrapper[0];
            this.pricingApprover = new ApprovalInnerWrapper[0];
            this.isTwoWheeler = false;
            this.twoWheelerLevel = '';
        }
    }
    
    public class ApprovalInnerWrapper {
        @AuraEnabled
        public String approverId{get;set;}
        @AuraEnabled
        public String approverName{get;set;}
        @AuraEnabled
        public String approverLevel{get;set;}
        public ApprovalInnerWrapper() {
            this.approverId = '';
            this.approverName = '';
            this.approverLevel = '';
        }
    }
    
    public class PSD_DDEPricingInformation{
        @AuraEnabled public String roi{get;set;}
        @AuraEnabled public String wirrCurrentMonth{get;set;}
        @AuraEnabled public String policyRate{get;set;}
        @AuraEnabled public String wirrLastMonth{get;set;}
        @AuraEnabled public String rateVariance{get;set;}
        @AuraEnabled public String emiDate{get;set;}
        @AuraEnabled public String emiFrequency{get;set;}
        @AuraEnabled public String emiAmount{get;set;}
        @AuraEnabled public String rbp{get;set;}
        @AuraEnabled public String overall4_2WPrevMonth{get;set;}
        @AuraEnabled public String overall4_2WCurrMonth{get;set;}
        @AuraENabled public String aggregateBranchWIRRPrevMonth{get;set;}
        @AuraENabled public String aggregateBranchWIRRCurrMonth{get;set;}
        @AuraENabled public String aggregateROWIRRPrevMonth{get;set;}
        @AuraENabled public String aggregateROWIRRCurrMonth{get;set;}
        @AuraENabled public String branchLoanLabel{get;set;}
        @AuraEnabled public String branchOverallLoanLabel{get;set;}
        @AuraEnabled public String collateralType{get;set;}//1780,82
        
        public PSD_DDEPricingInformation(){
            this.roi='';
            this.wirrCurrentMonth='';
            this.policyRate='0.00';
            this.wirrLastMonth='';
            this.rateVariance='0.00';
            this.emiDate='';
            this.emiFrequency='';
            this.emiAmount='';
            this.overall4_2WPrevMonth = '';
            this.overall4_2WCurrMonth = '';
            this.aggregateBranchWIRRPrevMonth = '';
            this.aggregateBranchWIRRCurrMonth = '';
            this.aggregateROWIRRPrevMonth = '';
            this.aggregateROWIRRCurrMonth = '';
            this.branchLoanLabel = '';
            this.branchOverallLoanLabel = '4WH Overall';
            this.collateralType = '';//1780,82
        }
        
        
        
    }
    
    public class PricingApplicantDetails {
        @AuraEnabled
        public String applicationNo{get;set;}
        @AuraEnabled
        public String branchHub{get;set;}
        @AuraEnabled
        public String customerName{get;set;}
        @AuraEnabled
        public String employmentType{get;set;}
        @AuraEnabled
        public String residenceState{get;set;}
        @AuraEnabled
        public String customerGrade{get;set;}
        @AuraEnabled
        public String cibil{get;set;}
        @AuraEnabled public String opsFTR{get;set;}
        @AuraEnabled public String creditFTR{get;set;}
        @AuraEnabled public String cibilUrl{get;set;}
        @AuraEnabled public String applicantId{get;set;}
        @AuraEnabled public String areaType{get;set;}
        public PricingApplicantDetails() {
            this.applicationNo = '';
            this.branchHub = '';
            this.customerName = '';
            this.employmentType = '';
            this.residenceState = '';
            this.cibil = '';
            this.customerGrade = '';
            this.cibilUrl = '';
            this.applicantId = '';
            this.areaType = '';
        }
    }
    
    public class PricingVehicleDetails {
        @AuraEnabled
        public String productType{get;set;}
        @AuraEnabled
        public String make_model{get;set;}
        
        public PricingVehicleDetails() {
            this.productType = '';
            this.make_model = '';
            
        }
    }
    
    public class PricingLoanDetails {
        @AuraEnabled
        public String schemeName{get;set;}
        @AuraEnabled
        public String loanAmount{get;set;}
        @AuraEnabled
        public String rbp{get;set;}
        @AuraEnabled
        public String ltvOnRoad{get;set;}
        @AuraEnabled
        public String pf{get;set;}
        @AuraEnabled
        public String dc{get;set;}
        @AuraEnabled
        public String otherCharges{get;set;}
        @AuraEnabled
        public String ls{get;set;}
        @AuraEnabled public String lsChargeNames{get;set;}
        @AuraEnabled public String motorInsuranceChargeName{get;set;}
        public PricingLoanDetails() {
            this.schemeName = ' ';
            this.loanAmount = ' ';
            this.rbp = ' ';
            this.ltvOnRoad = '';
            this.pf = ' ';
            this.dc = ' ';
            this.otherCharges = ' ';
            this.ls = ' ';
            this.lsChargeNames = '';
            this.motorInsuranceChargeName = 'No';
        }
    }
    
    public class PricingSourcingDetails {
        @AuraEnabled
        public String sourcingChannel{get;set;}
        @AuraEnabled
        public String dealerName{get;set;}
        @AuraEnabled
        public String roName_Mobile{get;set;}
        @AuraEnabled
        public String bmName_Mobile{get;set;}
        @AuraEnabled public STring dealerSchemePayout{get;set;}
        @AuraEnabled public String dsmPayout{get;set;}
        @AuraEnabled public String dsePayout{get;set;}
        @AuraEnabled public String payOutOnDeal{get;set;}
        public PricingSourcingDetails(){
            this.sourcingChannel = '';
            this.dealerName = '';
            this.roName_Mobile = '';
            this.bmName_Mobile = '';
            this.dealerSchemePayout = '';
            this.dsmPayout = '';
            this.dsePayout = '';
            this.payOutOnDeal = '';
        }
    }
    
    public class PricingPerformanceDetails {
        @AuraEnabled
        public String branch{get;set;}
        @AuraEnabled
        public String hub{get;set;}
        @AuraEnabled
        public String region{get;set;}
        @AuraEnabled
        public PricingPerformanceWrapper performanceObjectDetails{get;set;}
        public PricingPerformanceDetails(){
            this.branch = '';
            this.hub = '';
            this.region = '';
            this.performanceObjectDetails = new PricingPerformanceWrapper();
        }
    }
    
    public class OpsCaseCategory {
        @AuraENabled
        public String applicationId{get;set;}
        @AuraENabled
        public String hub{get;set;}
        @AuraENabled
        public String applicantName{get;set;}
        @AuraENabled
        public String dealApprovedBy{get;set;}
        @AuraENabled
        public String deliveryOrderDate{get;set;}
        @AuraENabled
        public String irr{get;set;}
        @AuraENabled
        public String state{get;set;}
        @AuraENabled
        public String branch{get;set;}
        @AuraENabled
        public String fatherName{get;set;}
        @AuraENabled
        public String spouseName{get;set;}
        @AuraENabled
        public String loanAmount{get;set;}
        @AuraENabled
        public String totalCharges{get;set;}
        @AuraENabled
        public String creditApprovalDate{get;set;}
        @AuraEnabled 
        public String physicalCustodyName{get;set;}
        @AuraEnabled 
        public String opsOutput{get;set;}
        @AuraEnabled
        public Decimal discrepancyCount{get;set;}

        @AuraEnabled public String dealApprover{get;set;} //jul 18
        //@AuraEnabled public String physicalCustodyName{get;set;}
        //@AuraEnabled public String opsOutput{get;set;}
        public OpsCaseCategory(){
            this.applicationId = '';
            this.hub = '';
            this.applicantName = '';
            this.dealApprovedBy = '';
            this.deliveryOrderDate = '';
            this.irr = '';
            this.state = '';
            this.branch = '';
            this.fatherName = '';
            this.loanAmount = '';
            this.totalCharges = '';
            this.creditApprovalDate = '';
            this.dealApprover = '';
            this.physicalCustodyName = '';
            this.dealApprover = '';
            this.opsOutput = '';
            this.discrepancyCount =0; //jul 18
        }
        
    }
    
    public class OpsAssetDetails{
        @AuraENabled
        public String product{get;set;}
        @AuraENabled
        public String manufacture{get;set;}//model
        @AuraENabled
        public String make{get;set;}
        @AuraENabled
        public String vehicleNumber{get;set;}
        @AuraENabled
        public String loanType{get;set;}
        @AuraENabled
        public String year{get;set;}
        @AuraENabled
        public String model{get;set;}//variant
        @AuraENabled
        public String collateralType{get;set;}
        @AuraEnabled public STring defRegister{get;set;}
        @AuraEnabled
        public  string vahaanPdf{get;set;}        
        
        public OpsAssetDetails(){
            this.product = '';
            this.manufacture = '';
            this.make = '';
            this.vehicleNumber = '';
            this.loanType = '';
            this.year = '';
            this.model = '';
            this.collateralType = '';
            this.vahaanPdf = '';
        }
    }
    
    public class OpsSourcingDetails{
        @AuraEnabled public String sourceChannel{get;set;}
        @AuraEnabled public String dealerName{get;set;}
        @AuraEnabled public String roCode{get;set;}
        @AuraEnabled public String repaymentMode{get;set;}
        @AuraEnabled public String psl{get;set;}
        @AuraEnabled public String dob{get;set;}
        @AuraEnabled public String applicantName{get;set;}
        @AuraEnabled public String applicantAddress{get;set;}
        @AuraEnabled public String loanNumber{get;set;}
        @AuraEnabled public String kycStatus{get;set;}
        @AuraEnabled public String schemeName{get;set;}
        @AuraEnabled public STring roName{get;set;}
        @AuraEnabled public STring repaymentBank{get;set;}
        @AuraEnabled public STring nach_si{get;set;}
        @AuraEnabled public String sourceName_DealerName{get;set;}
        @AuraEnabled public String balanceTransfer{get;set;}
        @AuraEnabled public Boolean exteralNOCStatusBT{get;set;}
        @AuraEnabled public Boolean renderBTNOCStatus{get;set;}
        @AuraEnabled public String esignStatus{get;set;}
        //@AuraEnabled public String roCode{get;set;}
        public OpsSourcingDetails(){
            this.sourceChannel = '';
            this.dealerName = '';
            this.roCode = '';
            this.repaymentMode = '';
            //this.psl = '';
            this.dob = '';
            this.applicantName = '';
            this.applicantAddress = '';
            this.loanNumber = '';
            this.kycStatus = '';
            this.schemeName = '';
            this.roName = '';
            this.sourceName_DealerName = '';
            this.balanceTransfer = '';
            this.renderBTNOCStatus = false;
            this.exteralNOCStatusBT = false;
            this.repaymentBank = '';
            this.repaymentMode='';
            this.nach_si = '';
            this.esignStatus = '';
        }
        
    }
    
    public class PricingPerformanceWrapper {
        @AuraEnabled
        public STring branchCurrentWIRR{get;set;}
        @AuraEnabled
        public String branchLastWIRR{get;set;}
        @AuraEnabled
        public STring hubCurrentWIRR{get;set;}
        @AuraEnabled
        public STring hubLastWIRR{get;set;}
        @AuraEnabled
        public STring regionCurrentWIRR{get;set;}
        @AuraEnabled
        public STring regionLastWIRR{get;set;}
        @AuraEnabled
        public String roWIRRCurrent{get;set;}
        @AuraEnabled
        public String roWIRRLast{get;set;}
        public PricingPerformanceWrapper() {
            this.branchCurrentWIRR = '';
            this.branchLastWIRR = '';
            this.hubCurrentWIRR ='';
            this.hubLastWIRR = '';
            this.regionCurrentWIRR = '';
            this.regionLastWIRR = '';
            this.roWIRRCurrent ='';
            this.roWIRRLast = '';
        }
    }

}