public without sharing class CustomerRequestLetterDeferralController {

    public CustomerRequestLetterDeferralController(SystemGeneratedEsignDocumentsController controller) {
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            RecordId =ApexPages.currentPage().getParameters().get('id');
            objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking' limit 1];

        }else if(ApexPages.currentPage().getParameters().get('applicationId')!=null){
            RecordId =ApexPages.currentPage().getParameters().get('applicationId');     
        }
        paramVar = true;
        getLoan();
    }

    public static Generic_Master__c objGenericMaster{get;set;}
    public static Id RecordId {get;set;}    
    public static Loan_Application__c loan{get;set;}
    public static Applicant__c applicant {get;set;}
    public static Collateral__c collateral {get;set;}    
    public static Loan_Application_Approval__c pricing {get;set;}  
    public static Account sourcingChannel {get;set;} 
    public static Account dealer {get;set;} 
    public static Loan_Application_Approval__c credit {get;set;}  
    public static List<Charge__c> chargeList {get;set;}  
    public static List<Applicant__c> applicants {get;set;}  
    public static BSR_PSL_Details__c bsrPsl {get;set;}    
    public static BSR_PSL_Details__c pslRecord {get;set;}    
    public static ProductRTMap__mdt productDetails {get;set;}
    public static Valuation__c valuation {get;set;} 
    public static User RO{get;set;}
    public static List<Payment__c> paymentFavourings {get;set;}  
    public static String todaysDate {get;set;}
    public static Payment__c dealerPayment {get; set;}
    public static String eSignDate {get; set;}
    public static String createdDate {get; set;}
    public static String totalLoanAmountInWords {get; set;}
    public static Address__c customerCurrentAddress {get; set;}
    public static List<PDCDetailsWrapper> chequeNumbers {get; set;}
    public static List<PDCDetailsWrapper> chequeNumbersSPDC {get; set;}
    public static List<Applicant__c> twoBOsList {get; set;}
    public static List<Applicant__c> allBOsList {get; set;}
    public static Payment__c btPayment {get; set;}
    public static Boolean paramVar {get;set;}
    public Static String currentAddress {get;set;}
    public Static String relationWithApplicant {get;set;}
    public static String bankName {get;set;}
    public static String repaymentBankName {get;set;}
    public static String bankCode {get;set;}
    public static String sponserBankCode {get;set;}
    public static String serviceProviderCode {get;set;}
    public static String custName {get;set;}
    public static String custMailId {get;set;}
    public static String fixedAmount {get;set;}
    public static String mandateCategory {get;set;}
    public static String mandateType {get;set;}
    public static String mbAmount {get;set;}
    public static String custMailTo {get;set;}
    public static String frequencyType {get;set;}
    public static String frequencyCode {get;set;}
    public static String refNumber {get;set;}
    public static String custNumber {get;set;}
    public static String pan {get;set;}
    public static String mandateReqId {get;set;}
    public static String Accptd {get;set;}
    public static String AccptRefNo {get;set;}
    public static String ReasonCode {get;set;}
    public static String ReasonDesc {get;set;}
    public static String RejectBy {get;set;}
    public static String callbackDate {get;set;}
    public static String callbackTime {get;set;}
    public static String status {get;set;}
    public static String umrn {get;set;}
    public static String Corporate_Utility_Code_Name {get;set;}
    public static String Service_Provider_ID {get;set;}
    public static String Mandate_Channel_Type {get;set;}
    public static String username {get;set;}
    public static String Mandate_Status_Active {get;set;}
    public static Decimal marginMoneyValue {get;set;}
    public static String mbDateTo {get;set;}
    public static String mbDateFrom {get;set;}

    public CustomerRequestLetterDeferralController() {
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            RecordId =ApexPages.currentPage().getParameters().get('id');
            objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking' limit 1];

        }else if(ApexPages.currentPage().getParameters().get('applicationId')!=null){
            RecordId =ApexPages.currentPage().getParameters().get('applicationId');     
        }
        paramVar = true;
        getLoan();
    } 

    public static Loan_Application__c getLoan(){       
        pricing = new Loan_Application_Approval__c(); 
        credit = new Loan_Application_Approval__c();
        todaysDate = Date.today().format();
        customerCurrentAddress = new Address__c();
        twoBOsList = new List<Applicant__c>();
        allBOsList = new List<Applicant__c>();
        btPayment = new Payment__c();
        dealerPayment = new Payment__c();
        marginMoneyValue = 0.00;
        String query = 'SELECT Id,IFSC_Code__c, Repayment_By__c ,Repayment_Bank_Name__c ,Primary_Applicant__c,Repayment_Account_Number__c,Repayment_Account_Type__c, Callback_Date_Time__c, Emandate_Payment_Type__c,Primary_Applicant__r.Mobile_Number__c,Repayment_Start_Date__c  , Branch__c ,Primary_Applicant__r.First_Name__c, Primary_Applicant__r.Last_Name__c , Primary_Applicant__r.Email__c,Primary_Applicant__r.PAN__c, ROI__c, LC_Code__c,RBP__c,Ops_Status__c, Ops_Output__c, BT_Type__c, Repayment_Mode__c, Esign_Type__c, Total_Charges__c, Emi_Frequency__c, BRE_Decision__c,' +
            'First_EMI_Date__c, Sourcing_channel__c, Sourcing_Channel_Name__c, Final_Exposure__c, LAN__c, Branch_Master__r.Region__r.Account_Name__c, Pre_Approved_Flag__c, OwnerId, PDC_Details__c, SPDC_Details__c,' +
            'BSR_PSL_Status__c, Mobile__c, Customer_Name__c, Purpose_of_Loan__c, Total_Loan_Amount__c, Vehicle_use__c, Loan_Amount__c, Name, CreatedDate, Scheme__c,Scheme__r.Scheme_Name__c,' +
            'Application_Id__c,toLabel(Product__c), Wheels_Exposure__c, Branch_Master__r.Business_HUB__r.Account_Name__c,Total_Exposure__c, Application_FI_Status__c, Application_Number__c,' +
            'Stage__c, Branch_Master__r.Account_Name__c, Branch_Master__r.State__r.Account_Name__C, Dealer_Master__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Account_Code__c,' +
            'Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.State__r.Account_Name__c, Purchase_City__c, Tenure__c, EMI__c, Esign_Date__c,'+
            '(Select Id, End_use_of_Vehicle__c, Industry__c, PSL_Classification_Type__c, RecordType.DeveloperName FROM BSR_PSL_Details__r Order By CreatedDate Desc),'+
            '(SELECT Customer_Type__c, Constitution_Type__c, Title__c, First_Name__c, Middle_Name__c, Last_Name__c, Customer_Grade__c, Marital_Status__c, Father_Name__c, Gender__c, Spouse_Name__c, Entity_Name__c ' +
            'FROM Applicants__r WHERE RecordType.DeveloperName=\'Primary_Applicant\' AND IsInactive__c=false),'+
            '(SELECT Name, Decision__c, Remarks__c, Approver__r.Name, Approval_Type__c, Approver__r.Username, Approver__r.Employee_Code__c, Approval_Status__c, Decision_Date_Time__c, Approver_Level__c, Deviation_Level__c, Type__c,' +
            'LastModifiedDate FROM Loan_Application_Approvers__r WHERE Type__c=\'Highest\' Order by CreatedDate Desc), '+
            '(SELECT Id, Make__c, RTO_Code__c, LTV__c, HPN_With_Financiers_Name__c, Existing_Policy_Type__c, toLabel(Collateral_Name__c), Vehicle_Number__c,Other_Funding_Total__c, Grid_Depreciated_Value__c, DO_Generation_Date__c,' +
            'SVSH_SVOH__c, Collateral_Type__c, Manufacturer__c, Final_Cost__c, LTV_offered_On_final_cost__c, IBB_Value__c, IDV__c, Vehicle_Category__c,Vehicle_Cost__c, Accessories__c, LS__c,' +
            'Model__c, Variant__c, Manufacture_year_month__c, Manufacture_Year__c, Fuel_Type__c, Ex_Showroom_Price__c, Discount__c, Insurance__c, RTO_Tax_Value__c,' +
            'On_Road_Price__c, Other_Costs__c, Apportioned_Loan_Amount__c, Customer_equity__c, Approved_LTV__c, LTV_offered_Ex_showroom__c, LTV_offered_On_road__c, Registration_Number__c,Net_of_Discount_Price__c,Certified_Value__c,' +
            'Current_Owner_Name__c, Engine_Number__c, Chasis_Number__c, Final_Vehicle_Cost__c,RecordType.Name, Valuation_Amount__c   FROM Collaterals__r WHERE ' +
            'RecordType.Developername in (\'New\',\'Used_Cash_on_Wheels\') AND Is_Deleted__c = false Order by CreatedDate Desc LIMIT 1), '+
            '(SELECT Id, Charges_Name__c, Total_Amount__c FROM Charges__r WHERE Total_Amount__c!=0 AND Total_Amount__c!=null Order by CreatedDate Desc),'+
            '(SELECT Id, Payment_Recipient__c, RecordType.DeveloperName, Bank_Name_PMT__c, IFSC_Code__c, Loan_Number__c, Net_Amount__c, Name__c, Beneficiary_Name__c, Account_Number__c, Payment_Mode__c, Bank_Name_Lookup__r.Branch_Name__c FROM Payments__r WHERE ' +
            '(RecordType.DeveloperName=\'Payment_Favouring\' OR RecordType.DeveloperName = \'Balance_Transfer\') AND Inactive__c = false Order by CreatedDate Desc)'+
            'FROM Loan_Application__c WHERE Id = :RecordId';
            
        loan = Database.query(query);
        createdDate = Date.valueOf(loan.CreatedDate).format();
        applicants = new List<Applicant__c>();
        if(applicants !=null && applicants.size()>0)
            relationWithApplicant = applicants[0].Relationship_with_applicant__c;
        else 
            relationWithApplicant = 'self';

        //SFAU-5156: Added by Samridhi
        DateTime dToday = loan.First_EMI_Date__c;
        if(dToday!= null){
            mbDateFrom = DateTime.newInstance(dToday.year() , dToday.month(),dToday.day()).format('dd/MM/yyyy');
            mbDateTo = DateTime.newInstance(dToday.year()+Integer.valueOf(Label.mbDateTo) , dToday.month(),dToday.day()).format('dd/MM/yyyy');
        }
        

        NumberToWord numToWordInst = new NumberToWord();
        totalLoanAmountInWords = loan.Total_Loan_Amount__c == null ? 'Zero' : NumberToWord.getNumberTOWord((Long)loan.Total_Loan_Amount__c);
        chequeNumbers = new List<PDCDetailsWrapper>();
        if (String.isNotBlank(loan.PDC_Details__c) && loan.PDC_Details__c.startsWith('[')) {
            chequeNumbers = (List<PDCDetailsWrapper>) JSON.deserialize(loan.PDC_Details__c, List<PDCDetailsWrapper>.class);
        }
        if (String.isNotBlank(loan.SPDC_Details__c) && loan.SPDC_Details__c.startsWith('[')) {
            chequeNumbersSPDC = (List<PDCDetailsWrapper>) JSON.deserialize(loan.SPDC_Details__c, List<PDCDetailsWrapper>.class);
            chequeNumbers.addAll(chequeNumbersSPDC);
        }

        applicant = loan.Applicants__r!=null && loan.Applicants__r.size()>0?loan.Applicants__r[0]:new Applicant__c();
        for (Address__c each : [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, District__c, City__c, State__c, Pincode__c FROM Address__c WHERE Source_Type__c IN ('CBS', null) AND Applicant__c = :applicant.Id AND Address_Type__c = 'Current']) {
            customerCurrentAddress = each;
        }
        applicants = [SELECT Id, RecordType.Name, Kyc_Type__c, CIF_No__c, Existing_Customer__c, First_Name__c, Middle_Name__c, Last_Name__c, Title__c FROM Applicant__c WHERE Loan__c=:loan.Id AND RecordType.DeveloperName in ('Primary_Applicant','Co_Applicant','Guarantor', 'BO') AND IsInactive__c=false Order by RecordType.Name];
        Integer i = 0;
        for (Applicant__c each : applicants) {
            if (each.RecordType.Name == 'BO') {
                if (i < 2) {
                    twoBOsList.add(each);
                } else {
                    allBOsList.add(each);
                }
                i++;
            }
        }
        
        collateral = loan.Collaterals__r!=null && loan.Collaterals__r.size()>0?loan.Collaterals__r[0]:new Collateral__c();
        
        if(collateral!=null && collateral.RecordType.Name == 'New'){
            marginMoneyValue = (collateral.Net_of_Discount_Price__c - (collateral.Apportioned_Loan_Amount__c - collateral.Other_Funding_Total__c));
            if(marginMoneyValue<0){
                marginMoneyValue = 0.00;
            }
        }
        bsrPsl = loan.BSR_PSL_Details__r!=null && loan.BSR_PSL_Details__r.size()>0?loan.BSR_PSL_Details__r[0]:new BSR_PSL_Details__c();
        if(loan.BSR_PSL_Details__r!=null && loan.BSR_PSL_Details__r.size()>0){
            for(BSR_PSL_Details__c psl: loan.BSR_PSL_Details__r){
                if(psl.RecordType.DeveloperName == 'PSL'){
                    pslRecord = psl;
                    break;
                }
            }
        }else{
            pslRecord = new BSR_PSL_Details__c();
        }
        

        List<Valuation__c> valuationDetails = [SELECT Valuer_Name_Code__c, Valuation_Amount__c FROM Valuation__c WHERE Collateral__c=:collateral.Id Order by CreatedDate desc Limit 1];
        valuation = valuationDetails!=null && valuationDetails.size()>0?valuationDetails[0]:new Valuation__c();
        system.debug('loan.Charges__r '+loan.Charges__r);
        chargeList = loan.Charges__r!=null && loan.Charges__r.size()>0?loan.Charges__r:new List<Charge__c>();
        paymentFavourings = loan.Payments__r!=null && loan.Payments__r.size()>0?loan.Payments__r:new List<Payment__c>();
        for (Payment__c each : paymentFavourings) {
            if (each.RecordType.DeveloperName == 'Payment_Favouring' && (each.Payment_Recipient__c == 'UCD' || each.Payment_Recipient__c == 'Dealer')) {
                dealerPayment = each;
            } else if (each.RecordType.DeveloperName == 'Balance_Transfer') {
                btPayment = each;
            }
        }
        eSignDate = loan.Esign_Date__c == null ? '' : loan.Esign_Date__c.format();
        if(loan.Loan_Application_Approvers__r!=null && loan.Loan_Application_Approvers__r.size()>0){
            for(Loan_Application_Approval__c app: loan.Loan_Application_Approvers__r){
                if(app.Approval_Type__c=='Pricing'){
                    pricing = app;
                }
                if(app.Approval_Type__c=='Credit'){
                    credit = app;
                }
            }
        }

        if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
            List<User> owners = [SELECT Id, Name, Employee_Code__c, MobilePhone FROM User WHERE Id=:loan.OwnerId];
            if(owners!=null && owners.size()>0){
                RO = owners[0];
            }
        }  

        List<ProductRTMap__mdt> products= new List<ProductRTMap__mdt>();
        // SFAU-5584 Start
        List<Loan_Application__c> records = [SELECT Id,Product__c FROM Loan_Application__c Where Id =: loan.Id];
        String productName = 'A_' +  records[0].Product__c;
        // SFAU-5584 end

        products = [SELECT Product__c, RecordType__c,MasterLabel , Sub_Product__c FROM ProductRTMap__mdt where DeveloperName= :productName WITH SECURITY_ENFORCED];
        if(products.size()>0){
            productDetails = products[0];
        }

        List<Account> channels = [SELECT Sourcing_channel__c, Account_Name__c, Bank_Name__c, Dealer_Type__c, Benificiary_Account_Number__c, IFSC_Code__c FROm Account WHERE Id=:loan.Sourcing_Channel_Name__c OR Id=:loan.Dealer_Master__c];
        if(channels!=null && channels.size()>0){
            for(Account acc: channels){
                if(acc.Id == loan.Sourcing_Channel_Name__c){
                    sourcingChannel=acc;
                }
                if(acc.Id == loan.Dealer_Master__c){
                    dealer=acc;
                }
            }
        }
        List<Address__c> lstAddress = [SELECT Address_Line_1__c, District__c, Applicant__r.RecordType.DeveloperName, Address_Type__c, Address_Line_2__c, Address_Line_3__c, City__c, State__c, Pincode__c, Applicant__c
           FROM Address__c WHERE Address_Type__c ='Current' AND Applicant__c =:loan.Primary_Applicant__c];
        if(!lstAddress.isEmpty() && lstAddress.size()>0){
            currentAddress = lstAddress[0].Address_Line_1__c + ' , ' +lstAddress[0].District__c +' , '+ lstAddress[0].City__c + ' , '+ lstAddress[0].State__c +' , '+lstAddress[0].Pincode__c;
        }
        system.debug('currentAddress-- '+ currentAddress);
        if(loan.Repayment_Bank_Name__c!=null){
            String bankName = '%'+loan.Repayment_Bank_Name__c+'%';
            Generic_Master__c bankObj = [SELECT Id,Bank_Name__c, Bank_Code__c FROM Generic_Master__c WHERE Bank_Name__c LIKE :bankName AND RecordType.Name='Bank Master' LIMIT 1];
            if(bankObj!=null){
                bankName = bankObj.Bank_Name__c;
                repaymentBankName = bankObj.Bank_Name__c;
                bankCode = bankObj.Bank_Code__c;
            }
        }
        sponserBankCode = Label.EMandate_mbSponserBankCode;
        serviceProviderCode = Label.EMandate_mbSvcProviderCode;
        refNumber = Label.EMandate_mbRefNumber;
        frequencyCode = Label.EMandate_mbFrequencyCode ;
        frequencyType = Label.EMandate_mbFrequencyType ;
        custName = loan.Primary_Applicant__r.First_Name__c+' '+loan.Primary_Applicant__r.Last_Name__c;
        custNumber = loan.Primary_Applicant__r.Mobile_Number__c;
        custMailId = loan.Primary_Applicant__r.Email__c;
        custMailTo = 'mailto:'+loan.Primary_Applicant__r.Email__c;
        fixedAmount = Label.EMandate_mbFixedAmount;
        mandateCategory = Label.EMandate_mbMandateCategory;
        mandateType = Label.EMandate_mbMandateType ;
        //SFAU-5156 : Added by Samridhi
        mbAmount = loan.Total_Loan_Amount__c<5000000 ? String.valueOf(loan.Total_Loan_Amount__c):'5000000';
        pan = loan.Primary_Applicant__r.PAN__c;
        List<Integration_Checklist__c> intObj = [SELECT Id,Callback_Request__c FROM Integration_Checklist__c WHERE Integration_Master_Name__c Like 'E-Mandate Registration%' AND Loan_Application__c=:loan.Id];
        if(intObj.size()>0){
            for(Integration_Checklist__c ic : intObj){
                if(ic.Callback_Request__c!=null){
                    Map<String, Object> callbackMap = (Map<String, Object>)JSON.deserializeUntyped(ic.Callback_Request__c);
                    mandateReqId = String.valueOf(callbackMap.get('MndtReqId'));
                    Accptd = String.valueOf(callbackMap.get('Accptd'));
                    AccptRefNo = String.valueOf(callbackMap.get('AccptRefNo'));
                    ReasonCode = String.valueOf(callbackMap.get('ReasonCode'));
                    ReasonDesc = String.valueOf(callbackMap.get('ReasonDesc'));
                    RejectBy = String.valueOf(callbackMap.get('RejectBy'));
                    if(callbackMap.get('MndtId')!=null){
                        umrn = String.valueOf(callbackMap.get('MndtId'));
                    }
                    else{
                        umrn = '';
                    }
                    if(loan.Callback_Date_Time__c!=null){
                        List<String> callbackDateTime = loan.Callback_Date_Time__c.split(',');
                        callbackDate = callbackDateTime[0];
                        callbackTime = callbackDateTime[1];
                    }
                    if(Accptd=='true'){
                        status = 'Active';
                    }
                    else if(Accptd=='false'){
                        status = 'Rejected';
                    }
                    break;
                }
            }
        }
        Corporate_Utility_Code_Name = Label.Corporate_Utility_Code_Name;
        Service_Provider_ID = Label.Service_Provider_ID;
        Mandate_Channel_Type = Label.Mandate_Channel_Type;
        username = Label.EMandate_Username;
        Mandate_Status_Active = Label.Mandate_Status_Active;
        return loan;
    }

    public class PDCDetails {
        public String spdcChequeNumberFrom {get; set;}
        public String spdcChequeNumberTo {get; set;}
        public String pdcChequeNumberFrom {get; set;}
        public String pdcChequeNumberTo {get; set;}
    }
}