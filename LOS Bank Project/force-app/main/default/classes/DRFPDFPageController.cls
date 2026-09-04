public class DRFPDFPageController {
    
    public static DRFPDFReturnWrapper getPDFWrapperData(){
        DRFPDFReturnWrapper returnWrapper = new DRFPDFReturnWrapper();
        try{
            String loanApplicationId = System.currentPagereference().getParameters().get('id');
            if(String.isBlank(loanApplicationId)) {
                return null;
            }
            List<Loan_Application__c> loanApplication = [SELECT Id,Application_Id__c, Name, Branch_Master__r.Name, Total_Loan_Amount__c, Loan_Amount_In_Words__c ,
                                                         Dealer_Master__r.Name, Dealer_Master__r.Dealer_State__c, CreatedBy.FirstName, CreatedBy.LastName, Total_Charges__c, Dealer_Master__r.Dealer_Type__c,
                                                         Loan_Amount__c, Dealer_Master__r.Dealer_Class__c,Dealer_Master__r.Purchase_City__c, CreatedDate,
                                                         (SELECT Id, Total_Amount__c FROM Charges__r)
                                                         FROM Loan_Application__c WHERE ID =:loanApplicationId LIMIT 1
                                                        ];
            List<Payment__c> payments = new List<Payment__c>();
            returnWrapper.paymentRecords = new List<Payment__c>();
            payments = [SELECT Id, Name__c, Net_Amount__c, Bank_Name_PMT__c, IFSC_Code__c, Account_Number__c FROM  Payment__c WHERE RecordType.DeveloperName = 'Payment_Favouring' AND Loan_Application__c=:loanApplicationId];
            returnWrapper.paymentRecords = payments;
            if(!loanApplication.isEMpty()){
                returnWrapper.branchName = nullCheckAndSetPDFData(String.valueOf(loanApplication[0].Branch_Master__r.Name));
                returnWrapper.consentDate = setDate(Date.valueOf(loanApplication[0].CreatedDate));
                returnWrapper.totalAmount = nullCheckAndSetPDFData(String.valueOf(loanApplication[0].Total_Loan_Amount__c));
                returnWrapper.totalAmountInWords = removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) loanApplication[0].Total_Loan_Amount__c));
                returnWrapper.applicationNumber = nullCheckAndSetPDFData(String.valueOf(loanApplication[0].Application_Id__c));
            }
            
            
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        return returnWrapper;
    }
    
    public class DRFPDFReturnWrapper{
        public String branchName{get;set;}
        public String consentDate{get;set;}
        public String totalAmount{get;set;}
        public String applicationNumber{get;set;}
        public String totalAmountInWords{get;set;}
        public String bankNumber{get;set;}
        public String bankIFSC{get;set;}
        public String bankName{get;set;}
        public String amountInWords{get;set;}
        public List<Payment__c> paymentRecords{get;set;}
    }
    
     private static String nullCheckAndSetPDFData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
    }
    
    private static String setDate(Date dateVal) {
        Date todaysDate = dateVal;
        return (String.valueOf(todaysDate.day())+'/'+String.valueOf(todaysDate.month())+'/'+String.valueOf(todaysDate.year()));
    }
    
    private static String removeRupeesKeywordFromAmount(String amtInWords){
        if(amtInWords.startsWith(' Rupess Only')){
            amtInWords = 'Zero Only';
        }
        else if(amtInWords.endsWith('Rupess Only')){
            amtInWords = amtInWords.replace('Rupess Only','Only');
        }
        return amtInWords;
        
    }

}