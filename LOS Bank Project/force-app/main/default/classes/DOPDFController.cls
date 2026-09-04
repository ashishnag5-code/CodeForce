public with sharing class DOPDFController {
    
    public static DOReturnWrapper getPDFWrapperData() {
        DOReturnWrapper returnWrapper = new DOReturnWrapper();
        try {
            returnWrapper.staticContentMaster = [SELECT Id,Letter_Name__c, Name, Letter_Content__c from Generic_Master__c WHERE Letter_Name__c = 'DO letter'];
            String loanApplicationId = System.currentPagereference().getParameters().get('applicationId');
            if(String.isBlank(loanApplicationId)) {
                return null;
            }
            returnWrapper.dateValue = setTodaysDate();
            List<Loan_Application__c> loanApplication = [SELECT Id,Application_Id__c, Name, Branch_Master__r.Name, Total_Loan_Amount__c, Scheme__r.Name,  Scheme__r.Scheme_Name__c,
                                                         Dealer_Master__r.Name, Dealer_Master__r.Dealer_State__c, CreatedBy.FirstName, CreatedBy.LastName, Total_Charges__c, Dealer_Master__r.Dealer_Type__c,
                                                         Loan_Amount__c, Dealer_Master__r.Dealer_Class__c,Dealer_Master__r.Purchase_City__c,
                                                         (SELECT Id, Total_Amount__c FROM Charges__r)
                                                         FROM Loan_Application__c WHERE ID =:loanApplicationId WITH SECURITY_ENFORCED LIMIT 1
                                                        ];
            if(!loanApplication.isEmpty()) {
                returnWrapper.loanApplication = setLoanApplicationPdfDetails(loanApplication[0]);
                List<Collateral__c> collateral = [SELECT Id, DO_Number__c, Engine_Category__c, Final_Vehicle_Cost__c, Case_In_Deferral__c, Final_Cost__c, Vehicle_Number__c ,
                                                  Make__c, Model__c, Variant__c, Manufacture_Year__c, RecordType.Name, Ex_Showroom_Price__c, RTO_Taxes__c, Vehicle_Cost__c ,
                                                  Insurance__c, Accessories__c, Accessories_Funding__c, MMV_Master__r.Name, Is_Deleted__c, On_Road_Price__c
                                                  FROM Collateral__c WHERE Loan__c = :loanApplication[0].Id AND Is_Deleted__c = false 
                                                  AND (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels') WITH SECURITY_ENFORCED LIMIT 1
                                                 ];
                
                List<Applicant__c> applicant = [SELECT First_Name__c, Middle_Name__c, Last_Name__c, Father_Name__c FROM Applicant__c
                                                WHERE Loan__c =:loanApplication[0].Id AND RecordType.Name = 'Applicant' WITH SECURITY_ENFORCED LIMIT 1
                                               ];
                
                List<Payment__c> paymentRec = [SELECT Id,Payment_Mode__c, Dealer_Payout__c, Dealer_Payout_amt__c FROM Payment__c WHERE Loan_Application__c=:loanApplication[0].Id
                                               AND RecordType.Name = 'Dealer Payout' WITH SECURITY_ENFORCED LIMIT 1
                                              ];
                if(!applicant.isEmpty()) {
                    returnWrapper.applicant = setApplicantPdfDetails(applicant[0]);
                    List<Address__c> address =[SElECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c, Pincode__c, Applicant__c, Address_Type__c
                                               FROM Address__c WHERE Applicant__c =:applicant[0].Id AND Address_Type__c = 'Current' AND (Source_Type__c = null OR Source_Type__c = 'CBS')  WITH SECURITY_ENFORCED LIMIT 1
                                              ];
                    if(!address.isEmpty()) {
                        returnWrapper.address = setAddressPDFDetails(address[0]);
                    }
                }
                if(!collateral.isEmpty()) {
                    returnWrapper.headingValue = (collateral[0].RecordType.Name == 'Used/Cash on Wheels')?collateral[0].Vehicle_Number__c : 'NEW';
                    returnWrapper.collateral = setCollateralPDFDetails(collateral[0], loanApplication[0]);
                }
                if(!paymentRec.isEmpty()){
                    returnWrapper.payment = setPaymentPDFDetails(paymentRec[0]);
                }
            }
        }catch(Exception ex){
            system.debug('error at line '+ex.getStackTraceString());
            returnWrapper.isRenderSuccess = false;
            returnWrapper.failMessage = ex.getMessage();
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        return returnWrapper;
    }
    
    public class DOReturnWrapper {
        public List<Generic_Master__c> staticContentMaster{get;set;}
        public LoanApplicationWrapper loanApplication{get;set;}
        public ApplicantWrapper applicant{get;set;}
        public AddressWrapper address{get;set;}
        public CollateralWrapper collateral{get;set;}
        public PaymentWrapper payment{get;set;}
        public Boolean isRenderSuccess{get;set;}
        public String failMessage{get;set;}
        public String dateValue{get;set;}
        public String headingValue{get;set;}
        public DOReturnWrapper() {
            staticContentMaster = new List<Generic_Master__c>();
            loanApplication = new LoanApplicationWrapper();
            applicant = new ApplicantWrapper();
            address = new AddressWrapper();
            isRenderSuccess = true;
            failMessage = '';
            dateValue = String.valueOf(System.today());
            headingValue = 'New';
        }
    }
    
    public class LoanApplicationWrapper {
        public String applicationNumber{get;set;}
        public String dealerName{get;set;}
        public String dealerLocation{get;set;}
        public String branchName{get;set;}
        public String loanAmount{get;set;}
        public String scheme{get;set;}
        public String salesExecutive{get;set;}
        public String lessCharges{get;set;}
        public Decimal netPayable{get;set;}
        public String dealerClass{get;set;}
    }
    
    public class AddressWrapper {
        public String address{get;set;}
    }
    
    public class ApplicantWrapper {
        public String customerName{get;set;}
        public String fatherName{get;set;}
    }
    
    public class CollateralWrapper {
        public String doNumber{get;set;}
        public String engineCategory{get;set;}
        public String assetCost{get;set;}
        public String deferralAmount{get;set;}
        public String model_make{get;set;}
        public String assetCostLabel{get;set;}
    }
    
    public class PaymentWrapper{
        public String paymentMode{get;set;}
        public String dealerPayout{get;set;}
    }
    
    private static LoanApplicationWrapper setLoanApplicationPdfDetails(Loan_Application__c loanApplicationRecord) {
        LoanApplicationWrapper wrapperData = new LoanApplicationWrapper();
        wrapperData.applicationNumber = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Name));
        wrapperData.branchName = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Branch_Master__r.Name));
        wrapperData.dealerName = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Dealer_Master__r.Name));
        wrapperData.dealerLocation = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Dealer_Master__r.Purchase_City__c));
        wrapperData.loanAmount = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Total_Loan_Amount__c));
        wrapperData.scheme = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Scheme__r.Scheme_Name__c));
        wrapperData.lessCharges = (!loanApplicationRecord.Charges__r.isEmpty())?setLessCharges(loanApplicationRecord.Charges__r):'0.00';
        system.debug('test '+wrapperData.loanAmount+' '+wrapperData.lessCharges);
        wrapperData.netPayable = Decimal.valueOf(wrapperData.loanAmount) - Decimal.valueOf(wrapperData.lessCharges);
        wrapperData.dealerClass = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Dealer_Master__r.Dealer_Type__c));//setModeOfPaymentValue(nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Dealer_Master__r.Dealer_Class__c)));
        wrapperData.salesExecutive = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.CreatedBy.FirstName))+' '+nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.CreatedBy.LastName));
        return wrapperData;
        
    }
    
    private static String setModeOfPaymentValue(String dealerClass){
        if(String.isBlank(dealerClass) || dealerClass != 'TA DEALER'){
            return 'NON-TA';
        }
        else{
            return 'TA';
        }
    }

    private static String setLessCharges(List<Charge__c> charges){
        Decimal amt = 0.00;
        for(Charge__c chg : charges){
            if(STring.isNotBlank(String.valueOf(chg.Total_Amount__c))){
                amt+=chg.Total_Amount__c;
            }
        }
        return String.valueOf(amt);
    }
                                   
                                   
    
    private static ApplicantWrapper setApplicantPdfDetails(Applicant__c applicantRecord) {
        ApplicantWrapper returnWrapper = new ApplicantWrapper();
        returnWrapper.customerName = setApplicantName(String.valueOf(applicantRecord.First_Name__c), 
                                                      String.valueOf(applicantRecord.Middle_Name__c), 
                                                      String.valueOf(applicantRecord.Last_Name__c)
                                                     );
        returnWrapper.fatherName = nullCheckAndSetPDFData(String.valueOf(applicantRecord.Father_Name__c));
        return returnWrapper;
    }
    
    private static String setApplicantName(String firstName, String middleName, String lastName) {
        return ((String.isBlank(firstName) ? '' : firstName+' ') +(String.isBlank(middleName) ? '' : middleName+' ')+(String.isBlank(lastName) ? '' : lastName+' '));
    }
    
    private static AddressWrapper setAddressPDFDetails(Address__c addressRecord) {
        AddressWrapper returnWrapper = new AddressWrapper();
        String streetName = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_1__c))+' '+nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_2__c))+' '+nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_3__c));
        String city = nullCheckAndSetPDFData(String.valueOf(addressRecord.City__c));
        String state = nullCheckAndSetPDFData(String.valueOf(addressRecord.State__c));
        String pincode = nullCheckAndSetPDFData(String.valueOf(addressRecord.Pincode__c));
        returnWrapper.address = streetName+' '+city+' '+state+' '+pincode;
        return returnWrapper;
    }
    
    private static CollateralWrapper setCollateralPDFDetails(Collateral__c collateralRecord, Loan_Application__c application) {
        CollateralWrapper returnWrapper = new CollateralWrapper();
        if(collateralRecord.RecordType.Name == 'Used/Cash on Wheels'){
            returnWrapper.assetCostLabel = 'Vehicle Cost';
            returnWrapper.assetCost = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Vehicle_Cost__c));
        }
        else{
            returnWrapper.assetCostLabel = 'On Road Price';
            returnWrapper.assetCost = nullCheckAndSetPDFData(String.valueOf(collateralRecord.On_Road_Price__c));
        }
        returnWrapper.doNumber = nullCheckAndSetPDFData(String.valueOf(collateralRecord.DO_Number__c));
        returnWrapper.engineCategory = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Engine_Category__c));
        //returnWrapper.assetCost = nullCheckAndSetPDFData(String.valueOf(collateralRecord.On_Road_Price__c	));//setAssetCost(collateralRecord);//nullCheckAndSetPDFData(String.valueOf(collateralRecord.Final_Vehicle_Cost__c));
        returnWrapper.deferralAmount = (collateralRecord.Case_In_Deferral__c == 'Yes')?String.valueOf(application.Total_Loan_Amount__c):'';
        returnWrapper.model_make = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Make__c))+' '+nullCheckAndSetPDFData(String.valueOf(collateralRecord.Model__c))+' '+nullCheckAndSetPDFData(String.valueOf(collateralRecord.MMV_Master__r.Name));
        return returnWrapper;
    }
    
    private static String setAssetCost(Collateral__c collateralRecord){
        if(collateralRecord.RecordType.Name == 'Used/Cash on Wheels'){
            return nullCheckAndSetPDFData(String.valueOf(collateralRecord.Final_Cost__c));// Updating to Final_Cost__c
        }
        else{
            Decimal assetCostRetValue = 0.00;
            assetCostRetValue+=collateralRecord.Ex_Showroom_Price__c+collateralRecord.RTO_Taxes__c+
                collateralRecord.Insurance__c+((collateralRecord.Accessories_Funding__c=='Yes')?Decimal.valueOf(collateralRecord.Accessories__c):0.00);
            return String.valueOf(assetCostRetValue);
        }
    }
    
    private static PaymentWrapper setPaymentPDFDetails(Payment__c paymentRecord) {
        PaymentWrapper returnWrapper = new PaymentWrapper();
        returnWrapper.paymentMode = nullCheckAndSetPDFData(String.valueOf(paymentRecord.Payment_Mode__c));
        returnWrapper.dealerPayout = checkAndSetDealerPayout(paymentRecord);//nullCheckAndSetPDFData(String.valueOf(paymentRecord.Dealer_Payout__c));
        return returnWrapper;
    }
    
    
    private static String checkAndSetDealerPayout(Payment__c paymentRecord){
        if(String.isNotBlank(paymentRecord.Dealer_Payout__c)){
            return paymentRecord.Dealer_Payout__c;
        }
        else{
            if(String.isBlank(paymentRecord.Dealer_Payout_amt__c) || paymentRecord.Dealer_Payout_amt__c == '0' || paymentRecord.Dealer_Payout_amt__c == '0.00'){
                return 'No';
            }
            else{
                return 'Yes';
            }
        }
    }
    
    
    private static String nullCheckAndSetPDFData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
    }
    
    private static String setTodaysDate() {
        Date todaysDate = System.today();
        return (String.valueOf(todaysDate.day())+'/'+String.valueOf(todaysDate.month())+'/'+String.valueOf(todaysDate.year()));
    }
    
}