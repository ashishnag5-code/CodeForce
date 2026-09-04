public without sharing class LOSPDDApprovalCtrl {
    public String loanAppId {get; set;}
    public String requestId {get; set;}
    public Boolean showTable {get; set;}
    public Boolean showSuccess{get; set;}
    public Boolean showAccept{get; set;}
    public String loanNumber{get; set;}
    public String customerName{get; set;}
    public String branchName{get; set;}
    public Boolean showAlreadySubmitted{get; set;}
    public Loan_Application__c loanApplication {get; set;}
    public List<Document_Checklist__c> docCheckRecords {get; set;}
    public void  doInit() {
        this.showSuccess = false;
        // this.loanAppId = Apexpages.currentPage().getParameters().get('loanId');
        this.requestId = Apexpages.currentPage().getParameters().get('reqId');
        // Details detail  = getLoanApplicationDetails(this.loanAppId);
        // loanApplication = detail.loan;
        // List<Applicant__c> applicantList =  getApplicants(loanAppId); 
	  List<Loan_Application__c> loanApps = new List<Loan_Application__c> ();
        List<Deferral_Register__c> defRefs = [SELECT Id,Collateral__r.Loan__c FROM Deferral_Register__c Where Id =: this.requestId];  
        if(defRefs!=null && !defRefs.isEmpty())
       loanApps = [SELECT Id,Name,Name_of_Customer__c,Branch_Name__c FROM Loan_Application__c Where Id =: defRefs[0].Collateral__r.Loan__c];
        docCheckRecords = [SELECT Id,Document_Master__r.Document_Name__c,Deferral_Register__r.Collateral__r.Loan__r.Name,Deferral_Register__r.Collateral__r.Loan__r.Name_of_Customer__c,Deferral_Register__r.Collateral__r.Loan__r.Branch_Name__c  from Document_Checklist__c WHERE  Document_Master__r.Document_Category__c = 'Vehicle Document'
                           AND Document_Master__r.Stage__c = 'PDD' AND Document_Verification_Status__c = 'Verified' AND Deferral_Register__c =: requestId AND Deferral_Register__r.Confirmation_Recieved__c != 'Yes'
                           ORDER By Document_Master__r.Document_Id__c];
        
        this.showAlreadySubmitted = docCheckRecords.isEmpty() ? true : false;
        this.showTable = this.showAlreadySubmitted ? false : true;
        this.showAccept = this.showTable;
        if(!loanApps.isEmpty()){
            this.loanNumber = loanApps[0].Name;
            this.customerName = loanApps[0].Name;
            this.branchName = loanApps[0].Branch_Name__c;
        }
        
        
    }
    
    public  void acceptDocuments(){
        //   Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
        //   Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
        //   Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
        
        // List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=: this.loanAppId AND recordTypeId IN: colRecordTypeIds WITH SECURITY_ENFORCED];
        
        List<Deferral_Register__c> deferralRegisters = [SELECT Id  FROM Deferral_Register__c Where Id =: requestId AND Confirmation_Recieved__c != 'Yes'];
        
        Deferral_Register__c register =null;
        if(deferralRegisters!=null && !deferralRegisters.isEmpty()){
         register = deferralRegisters[0];
        
        register.Confirmation_Recieved__c = 'Yes';
        register.Confirmation_Recieved_Date__c = Date.today();
        
        update register;
        this.showSuccess = true;
        this.showTable = false;
        this.showAlreadySubmitted = false;
        }
        
    }
    
    public static List<Applicant__c> getApplicants(Id recordId){
        List<Applicant__c> applicantList = [SELECT Id, First_Name__c, Last_Name__c FROM Applicant__c WHERE Loan__c=:recordId AND 
                                            RecordType.DeveloperName!=:GlobalConstants.ADDITIONAL_MATCH_RECORDTYPE WITH SECURITY_ENFORCED];
        return applicantList;
    }
    
    
    public class Details{
        @AuraEnabled public Loan_Application__c loan{get;set;}
        @AuraEnabled public String productType{get;set;}
    }
    public static Details getLoanApplicationDetails(Id loanAppId){
        Details loanAppDetails = new Details();
        List<Loan_Application__c> loanApplications = new List<Loan_Application__c>();
        try {
            loanApplications = [SELECT Id,Product__c, Name, Stage__c, LAN__c, Loan_Number__c 
                                FROM Loan_Application__c WHERE Id=:loanAppId];
            if(loanApplications!=null && loanApplications.size()>0){
                loanAppDetails.loan = loanApplications[0];
                String prod = 'A_'+loanApplications[0].Product__c;
                ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
                if(prodRecordType!=null){
                    loanAppDetails.productType = prodRecordType.Sub_Product__c;
                }
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return loanAppDetails;
    }
    
}