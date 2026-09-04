public class AusfLoanApprovalEmailTemplate
{
    public Id accountId {get;set;}
    public Id applicantId {get;set;}
    public pricingEmailTemplateWrapper getVehicle()
    {
        pricingEmailTemplateWrapper pr = new pricingEmailTemplateWrapper();
        Id collateralNewRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        system.debug('accountId '+accountId);
        for(Charge__c ch :[SELECT Id,Charge_Amount__c,Charges_Name__c 
                           FROM Charge__c WHERE Loan_Application__c=:accountId]){
                               if(ch.Charges_Name__c.contains('Documentation Charges')){
                                   pr.documentationCharge = ch.Charge_Amount__c;
                               }else if(ch.Charges_Name__c.contains('Processing Fees')){
                                   pr.processingFees = ch.Charge_Amount__c;
                               }else if(ch.Charges_Name__c.contains('Loan Suraksha Charges')){
                                   pr.loanSurakshaCharge = ch.Charge_Amount__c;
                               }else if(ch.Charges_Name__c.contains('Other Charges')){
                                   pr.otherCharges = ch.Charge_Amount__c;
                               }
        } 
        
        List<Collateral__c> conList = new List<Collateral__c>();
        conList = [SELECT Id,recordTypeId,tolabel(Loan__r.Product__c),Make__c,Model__c,MMV_Master__r.Name,Manufacture_year_month__c,LTV_offered_Ex_showroom__c,LTV_offered_On_final_cost__c   FROM Collateral__c Where (recordTypeId =:collateralUsedRecordTypeId OR recordTypeId =:collateralNewRecordTypeId) AND Is_Deleted__c=false AND Loan__c=:accountId];
        if(conList.size()>0){
            pr.product = conList[0].Loan__r.Product__c;
            pr.make = conList[0].Make__c;
            pr.model = conList[0].Model__c;
            pr.manufacturer = conList[0]?.MMV_Master__r?.Name;
            pr.manufacturerYear = conList[0].Manufacture_year_month__c.substring(0, 4);
            if(conList[0].recordTypeId==collateralNewRecordTypeId){
                pr.ltvCost = conList[0].LTV_offered_Ex_showroom__c;
            }
            if(conList[0].recordTypeId==collateralUsedRecordTypeId){
                pr.ltvCost = conList[0].LTV_offered_On_final_cost__c;
            } 
        }
        String strLoanId;
        List<Loan_Application__c> loanApp =[SELECT Id,Owner.Name,Owner.Phone,Branch_Master__c, ( SELECT Department__c, Deviation_Type__c, Policy_Value__c, Actual_Value__c, Variance__c, Level__c, Mitigates__c FROM Deviations__r WHERE Archived__c = FALSE AND Department__c = 'Pricing' AND Deviation_Type__c != 'Charges - Min Level Breached') FROM Loan_Application__c WHERE Id=:accountId];
        if(!loanApp.isEmpty()){
            strLoanId = loanApp[0].Id;
            pr.roName = loanApp[0].Owner.Name;
            pr.roMobileNumber = loanApp[0].Owner.Phone;
        }
        List<AccountTeamMember> accTeamList = [SELECT Id,User.Name, User.Phone FROM AccountTeamMember WHERE TeamMemberRole='Branch Manager' AND accountId=:loanApp[0].Branch_Master__c AND Active__c = true];
        if(!accTeamList.isEmpty()){
            pr.branchManagerName = accTeamList[0].User.Name;
            pr.branchManagerMobileNumber = accTeamList[0].User.Phone;
        }
        List<Address__c> add = [select Type__c,Stability__c from Address__c Where Applicant__c=:applicantId];
        if(!add.isEmpty()){
            pr.residence  = add[0].Type__c;
            pr.stability  = add[0].Stability__c;
        }
        
        SummaryPageWrapperController.PSD_DDEPricingInformation returnWrapper = PricingSummaryPageController.getPricingPerformanceDetails(strLoanId);
        system.debug('returnWrapper '+returnWrapper);
        PricingPerformanceWrapper wirr = new PricingPerformanceWrapper();
        if(returnWrapper.aggregateBranchWIRRCurrMonth!=null){
            wirr.branchCurrentWIRR = returnWrapper.aggregateBranchWIRRCurrMonth;}
        if(returnWrapper.aggregateBranchWIRRPrevMonth!=null){
            wirr.branchLastWIRR = returnWrapper.aggregateBranchWIRRPrevMonth;}
        if(returnWrapper.aggregateROWIRRCurrMonth!=null){
            wirr.roWIRRCurrent = returnWrapper.aggregateROWIRRCurrMonth;}
        if(returnWrapper.aggregateROWIRRPrevMonth!=null){
            wirr.roWIRRLast = returnWrapper.aggregateROWIRRPrevMonth;}
        pr.wirr = wirr;
        
        /*List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList = loanApp[0].Deviations__r;
        if(deviationList.size()>0){
            pr.pricingDeviations = loanApp[0].Deviations__r;
        }  */      
        return pr;
    }
    
    public class pricingEmailTemplateWrapper{
        public String product {get; set;}
        public String make {get; set;}
        public String model {get; set;}
        public String manufacturer {get; set;}
        public String manufacturerYear {get; set;}
        public Decimal ltvCost {get; set;}
        public Decimal documentationCharge {get; set;}
        public Decimal processingFees {get; set;}
        public Decimal loanSurakshaCharge {get; set;}
        public Decimal otherCharges {get; set;}
        //Bank Manager
        public String branchManagerName {get; set;}
        public String branchManagerMobileNumber {get; set;}
        //RO 
        public String roName {get; set;}
        public String roMobileNumber {get; set;}
        public String residence {get; set;}
        public String stability {get; set;}
        public PricingPerformanceWrapper wirr {get;set;}
        public Deviation__c[] pricingDeviations {get;set;}
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