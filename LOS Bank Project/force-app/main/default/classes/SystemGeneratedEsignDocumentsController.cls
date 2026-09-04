public without sharing class SystemGeneratedEsignDocumentsController {

    public SystemGeneratedEsignDocumentsController(ApplicationFormPDFController controller) {
        recordId  = ApexPages.CurrentPage().getparameters().get('id');
        if (recordId == null) {
            recordId  = ApexPages.CurrentPage().getparameters().get('applicationid');
        }
        List<Document_Checklist__c> docChecklists = [SELECT Id, Name, Document_Master__r.Name, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE
            Loan_Application__c=:recordId AND Document_Master__r.Consider_for_E_Sign__c=true];
        documentsToBeSigned = new List<String>();
        for(Document_Checklist__c doc: docChecklists){
            documentsToBeSigned.add(doc.Document_Master__r.Name);
        }
        for(String renderDoc : documentsToBeSigned){
            switch on renderDoc {
                when 'AUWheels0073' {
                    renderAUWheels0073=true; //Loan Agreement
                }   
                when 'AUWheels0030' {       
                    renderAUWheels0030=true; //Customer Request Letter for Deferral Amount Lien Marking
                }
                when 'AUWheels0031' {       
                    renderAUWheels0031=true; //Customer Consent Letter For RTO
                }
                when 'AUWheels0032' {
                    renderAUWheels0032=true; //Dealer Consent Letter For RTO
                }
                when 'AUWheels0035' {
                    renderAUWheels0035=true;//Authorization and Declaration Letter
                }
                when 'AUWheels0041' {
                    renderAUWheels0041=true; //Application Form
                }
                when 'AUWheels0052' {
                    renderAUWheels0052=true; //Loan Charges Deduction Letter
                }
                when 'AUWheels0051' {
                    renderAUWheels0051=true; //Consent Letter for Repayment taken from other than Borrower Account
                }
                when 'AUWheels0025' {
                    renderAUWheels0025=true; //Annexure Copy (For External BT)
                }
                when 'AUWheels0026' {
                    renderAUWheels0026=true; //Third Party Payment Consent Letter
                }
                when 'AUWheels0117' {
                    renderAUWheels0117=true;
                }
                when else {       // default block, optional
                    // code block 4
                }
            }
        }
        getLoanDetails();
    }

    
    /*Customer Request Letter for Deferral Amount Lien Marking - Annexure_12 - Customer Undertaking Letter for Deferral Amount Lien Mark in AUSFB CASA Account
Customer Consent Letter For RTO - Annexure_13 - Customer Consent Letter for RTO
Dealer Consent Letter For RTO - Annexure_14 - Dealer Consent Letter for RTO
Authorization & Declaration Letter (In Case Partnership Firm/Society/Trust) - Annexure_6-Authorization Letter _ In case of Partnership Firm
Board Resolution (Company Cases) - Annexure_7 - Board Resolution_Pvt. Ltd Firm and Annexure_8 - Board Resolution_Society & Trust Case
Application Form - Application Form
Loan Charges Deduction Letter - Annexure_5 - Charges Deduction Letter
Consent Letter for Repayment taken from other than Borrower Account - Repayment Consent Letter from Co-applicant and Gtr Account
Annexure Copy (For External BT) - Annexure_3 - Authorization for Loan Closure and NOC issue_BT Cases and Annexure_1 - Payment Favoring Letter
                    (External BT Cases) and Annexure_2 - Covering letter of Settlement Amount to Previous Bank or Financier in BT Cases
Third Party Payment Consent Letter - Annexure_4 - Payment Favoring Letter to Channels and Third party
Loan Agreement - Digital Wheels Loan Agreement - Final Copy March 2023
E-Annexure - Annexure AD - March 2023*/

    public static String recordId{get;set;} //loan Id sent from LWC
    public static List<String> documentsToBeSigned{get;set;} //loan Id sent from LWC
    public static Boolean renderAUWheels0073{get;set;}
    public static Boolean renderAUWheels0030{get;set;}
    public static Boolean renderAUWheels0031{get;set;}
    public static Boolean renderAUWheels0032{get;set;}
    public static Boolean renderAUWheels0035{get;set;}
    public static Boolean renderAUWheels0041{get;set;}
    public static Boolean renderAUWheels0052{get;set;}
    public static Boolean renderAUWheels0051{get;set;}
    public static Boolean renderAUWheels0025{get;set;}
    public static Boolean renderAUWheels0026{get;set;}
    public static Boolean renderAUWheels0117{get;set;}

    public static Map<String, Generic_Master__c> loanAgreementContents{get;set;}
    public static Set<String> loanAgreementContentsName;
    public static String mitcContent{get;set;}
    public static String thirdPartContent{get;set;}
    public static String declarationContent{get;set;}
    public static String loanCumHypoContent{get;set;}
    public static Generic_Master__c objGenericMaster;

    public static Loan_Application__c loan{get;set;}
    public static ProductRTMap__mdt productRT{get;set;}
    public static Applicant__c applicant{get;set;}
    public static List<Applicant__c> coapplicants{get;set;}
    public static List<Applicant__c> guarantors{get;set;}
    public static Collateral__c collateral{get;set;}
    public static List<Charge__c> charges{get;set;}
    public static Decimal otherChargesAmount{get;set;}
    public static String otherChargesAmountStr{get;set;}
    public static String otherChargesAmountInWords{get;set;}
    public static Decimal processingFeesAmount{get;set;}
    public static String processingFeesAmountStr {get;set;}
    public static String processingFeesAmountInWords {get;set;}
    public static String insuranceChargeAmtStr {get;set;}
    public static String insuranceChargeAmtInWords {get;set;}
    public static String processingFeesAmountGSTStr {get;set;}
    public static Decimal stampDutyAmount{get;set;}
    public static String stampDutyAmountStr{get;set;}
    public static String stampDutyAmountInWords{get;set;}
    public static Decimal documentationChargeAmount{get;set;}
    public static Decimal rcChargeAmount{get;set;}
    public static String todaysDate{get;set;}
    public static String createdDate {get; set;} 
    public static String sanctionedDate {get; set;}
    public static String beneficiaryName{get;set;}
    public static Map<Id, Map<String, Address__c>> addressMap {get; set;}
    public static String totalLoanAmountInWords {get; set;}
    public static String netDisbAmountStr {get; set;}
    public static String netDisbAmountInWords {get; set;}
    public static String totalChargesAmountInWords {get; set;}
    public static String emiDateStr {get; set;}
    public static String eSignDateStr {get; set;}
    public static EMI_Schedule__c emiSchedule {get; set;}
    public static String interestAmtStr {get; set;}
    public static String totalPayableAmtStr {get; set;}
    public static String totalPayableAmtInWords {get; set;}
    public static List<ChargesWrapper> chargeDetails {get; set;}
    public static String prodName {get; set;}
    public static Address__c applicantAddress {get; set;}
    public static Address__c customerCurrentAddress {get; set;}
    public static Payment__c dealerPayment {get; set;}
    public static List<PDCDetailsWrapper> chequeNumbers {get; set;}
    public static List<PDCDetailsWrapper> chequeNumbersSPDC {get; set;}
    public static List<Applicant__c> twoBOsList {get; set;}
    public static List<Applicant__c> allBOsList {get; set;}
    public static Officer_Details__mdt nodalOfficerDetails {get; set;}
    public static List<SOC_Charges_Metadata__mdt > socChargesData {get; set;}
    public static List<SOC_Interest_Rates__mdt > socInterestRateData{get;set;}
    public static String socNotes{get;set;} 
    public static Integer monotariumCount{get;set;}
    public static Date emiDateValue{get;set;}
    public static Boolean isRepaymentModeSI{get;set;}
    public static String socVehicleHeader{get;set;}

    public SystemGeneratedEsignDocumentsController() {
        recordId  = ApexPages.CurrentPage().getparameters().get('id');
        beneficiaryName = '';
        if (recordId == null) {
            recordId  = ApexPages.CurrentPage().getparameters().get('applicationid');
        }
        List<Document_Checklist__c> docChecklists = [SELECT Id, Name, Document_Master__r.Name, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE
            Loan_Application__c=:recordId AND Document_Master__r.Consider_for_E_Sign__c=true];
        documentsToBeSigned = new List<String>();
        for(Document_Checklist__c doc: docChecklists){
            documentsToBeSigned.add(doc.Document_Master__r.Name);
        }

        for(String renderDoc : documentsToBeSigned){
            switch on renderDoc {
                when 'AUWheels0073' {
                    renderAUWheels0073=true; //Loan Agreement
                }   
                when 'AUWheels0030' {       
                    renderAUWheels0030=true; //Customer Request Letter for Deferral Amount Lien Marking
                }
                when 'AUWheels0031' {
                    renderAUWheels0031=true; //Customer Consent Letter For RTO
                }
                when 'AUWheels0032' {
                    renderAUWheels0032=true; //Dealer Consent Letter For RTO
                }
                when 'AUWheels0035' {
                    renderAUWheels0035=true;//Authorization and Declaration Letter
                }
                when 'AUWheels0041' {
                    renderAUWheels0041=true; //Application Form
                }
                when 'AUWheels0052' {
                    renderAUWheels0052=true; //Loan Charges Deduction Letter
                }
                when 'AUWheels0051' {
                    renderAUWheels0051=true; //Consent Letter for Repayment taken from other than Borrower Account
                }
                when 'AUWheels0025' {
                    renderAUWheels0025=true; //Annexure Copy (For External BT)
                }
                when 'AUWheels0026' {
                    renderAUWheels0026=true; //Third Party Payment Consent Letter
                }
                when 'AUWheels0117' {
                    renderAUWheels0117=true;
                }
                when else {       // default block, optional
                    // code block 4
                }
            }
        }
        getLoanDetails();
    }

    public static Generic_Master__c getObjGenericMaster(){
        objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where Letter_Name__c = 'Customer Request Letter for Deferral Amount Lien Marking' limit 1];
        return objGenericMaster;
    }

    public static Set<String> getLoanAgreementContentsName(){
        loanAgreementContents = new Map<String, Generic_Master__c>();
        List<Generic_Master__c> documentContents = [SELECT Id, Name__c, Letter_Content__c FROM Generic_Master__c WHERE RecordType.DeveloperName='Auto_Generated_Letters_Content' AND Letter_Name__c='Loan Agreement' order by Name__c];
        system.debug('documentContents '+documentContents);
        if(documentContents!=null && documentContents.size()>0){
            for(Generic_Master__c content: documentContents){
                if(content.Name__c == 'MITC'){
                    mitcContent = content.Letter_Content__c;
                }else if(content.Name__c == 'Third Part Loan Agreement'){
                    thirdPartContent = content.Letter_Content__c;
                }else if(content.Name__c == 'Declaration'){
                    declarationContent = content.Letter_Content__c;
                }else if(content.Name__c == 'Loan Cum Hypothecation'){
                    loanCumHypoContent = content.Letter_Content__c;
                }else if(content.Name__c == 'SOC Notes'){
                    socNotes = content.Letter_Content__c;
                }
                else{
                    loanAgreementContents.put(content.Name__c, content);
                }
            }
            loanAgreementContentsName = loanAgreementContents.keySet();
        }
        return loanAgreementContentsName;
    }

    public class ChargesWrapper {
        public String chargeAmountStr {get; set;}
        public String taxAmountStr {get; set;}
        public String chargesInWords {get; set;}
        public String chargesName {get; set;}

        public ChargesWrapper(Charge__c chargeRecord) {
            chargesName = chargeRecord.Charges_Name__c;
            chargeAmountStr = chargeRecord.Charge_Amount__c == null ? '0' : chargeRecord.Charge_Amount__c.format();
            taxAmountStr = chargeRecord.Charge_Amount__c != null && chargeRecord.Tax_Percentage__c != null ? (chargeRecord.Charge_Amount__c * chargeRecord.Tax_Percentage__c).format() : '0';
            NumberToWord numToWordInst = new NumberToWord();
            chargesInWords = chargeRecord.Total_Amount__c == null ? 'Zero' : removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) chargeRecord.Total_Amount__c));
        }
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

    public static Loan_Application__c getLoanDetails(){
        monotariumCount = 0;
        isRepaymentModeSI = false;
        addressMap = new Map<Id, Map<String, Address__c>>();
        customerCurrentAddress = new Address__c();
        applicantAddress = new Address__c();
        dealerPayment = new Payment__c();
        twoBOsList = new List<Applicant__c>();
        allBOsList = new List<Applicant__c>();
        List<Loan_Application__c> loanApps = [SELECT Application_Id__c, toLabel(Product__c) prodLabel, Product__c, Total_Loan_Amount__c, Loan_Number__c, CreatedDate, Repayment_By__c, First_EMI_Date__c,
                Repayment_Account_Number__c, Repayment_Bank_Name__c, IFSC_Code__c, Branch_Master__r.Account_Name__c, Purpose_of_Loan__c, Sourcing_channel__c, RecordType.DeveloperName,
                Loan_Amount_In_Words__c, Tenure__c, ROI__c, EMI__c, EMI_Date__c, EMI_Frequency__c, Type_of_Rate__c, Total_Charges__c, Source_Name__c, RecordType.Name,
                Repayment_Mode__c, Esign_Date__c,Loan_Sanction_date__c , PDC_Details__c, SPDC_Details__c,
                (SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Entity_Name__c, Title__c, RecordType.DeveloperName, Marital_Status__c,
                Spouse_Name__c, Father_Name__c, PAN__c,     Mobile_Number__c, Email__c, GST_NO__c, Customer_Type__c, Gender__c
                FROM Applicants__r WHERE IsInactive__c = false),
                (SELECT Id, Total_Interest__c FROM EMI_Schedules__r WHERE RecordType.Name IN ('Generated EMI Schedule','Generated Repayment Schedule')
                ORDER BY CreatedDate DESC LIMIT 1),
                (SELECT Make__c, Model__c, Rto_Code__c, Chasis_Number__c, Registration_Number__c, Engine_Number__c, Current_Owner_Name__c,
                HPN_With_Financiers_Name__c, MMV_Master__r.Make_Model_Variant__c, Manufacture_year_month__c FROM Collaterals__r WHERE Is_Deleted__c = false AND RecordType.DeveloperName != 'Existing_Collateral'),
                (SELECT Charges_Name__c, Tax_Percentage__c, Total_Amount__c, Charge_Amount__c, Tax_Amount__c FROM Charges__r),
                (SELECT Id, Payment_Recipient__c, Beneficiary_Name__c, Name__c, RecordType.DeveloperName FROM Payments__r WHERE RecordType.DeveloperName='Payment_Favouring' OR RecordType.DeveloperName = 'Balance_Transfer' Order by CreatedDate Desc)
                FROM Loan_Application__c WHERE Id=:recordId];
        System.debug('------recordId: '+recordId);
        chargeDetails = new List<ChargesWrapper>();
        if(loanApps!=null && loanApps.size()>0){
            loan = loanApps[0];
            isRepaymentModeSI = (String.isNotBlank(loan.Repayment_Mode__c) && loan.Repayment_Mode__c == 'Standing Instructions');
            socVehicleHeader = (loan.RecordType.Name == 'Four Wheeler')?'Car':loan.RecordType.Name;
            if(loanApps.size()>0 && !String.isBlank(loanApps[0].Product__c))
                prodName = loanApps[0].Product__c;
            if(loan.Loan_Sanction_date__c != null)
                sanctionedDate = Date.valueOf(loan.Loan_Sanction_date__c).format();
            NumberToWord numToWordInst = new NumberToWord();
            totalLoanAmountInWords = loan.Total_Loan_Amount__c == null ? 'Zero' : removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) loan.Total_Loan_Amount__c));
            Decimal netDisbAmount = loan.Total_Loan_Amount__c != null && loan.Total_Charges__c != null ? (loan.Total_Loan_Amount__c - loan.Total_Charges__c) : 0;
            netDisbAmountStr = netDisbAmount.format();
            system.debug('netDisbAmountStr::'+netDisbAmountStr);
             system.debug('loan.Total_Charges__c::'+loan.Total_Charges__c);
            system.debug('loan.Total_Loan_Amount__c::'+loan.Total_Loan_Amount__c);
            eSignDateStr = loan.Esign_Date__c != null ? loan.Esign_Date__c.format() : '';
            netDisbAmountInWords = netDisbAmount == null ? 'Zero' : removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) netDisbAmount));
            totalChargesAmountInWords = loan.Total_Charges__c == null ? 'Zero' : removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) loan.Total_Charges__c));
            createdDate = Date.valueOf(loan.CreatedDate).format();
            chequeNumbers = new List<PDCDetailsWrapper>();

            if (String.isNotBlank(loan.PDC_Details__c) && loan.PDC_Details__c.startsWith('[')) {
                chequeNumbers = (List<PDCDetailsWrapper>) JSON.deserialize(loan.PDC_Details__c, List<PDCDetailsWrapper>.class);
            }
            if (String.isNotBlank(loan.SPDC_Details__c) && loan.SPDC_Details__c.startsWith('[')) {
                chequeNumbersSPDC = (List<PDCDetailsWrapper>) JSON.deserialize(loan.SPDC_Details__c, List<PDCDetailsWrapper>.class);
                chequeNumbers.addAll(chequeNumbersSPDC);
            }

            //todaysDate = Date.valueOf(system.Today()).format();
            emiDateStr = loan.EMI_Date__c == null ? '' : calculateEMIDate(loan.EMI_Date__c, loan.Tenure__c, false, loan.First_EMI_Date__c);
            if(String.isNotBlank(emiDateStr)){
                Date todaysDate = System.today();
                
                monotariumCount = todaysDate.daysBetween(emiDateValue);
            }
             
            emiSchedule = new EMI_Schedule__c(Total_Interest__c = 0);

            if (loan.EMI_Schedules__r != null && !loan.EMI_Schedules__r.isEmpty()) {
                emiSchedule = loan.EMI_Schedules__r.get(0);
                interestAmtStr = emiSchedule.Total_Interest__c == null ? 'Zero' : removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) emiSchedule.Total_Interest__c));
            }

            Decimal totalPayableAmt = (loan.Total_Loan_Amount__c == null ? 0 : loan.Total_Loan_Amount__c) + (emiSchedule.Total_Interest__c == null ? 0 : emiSchedule.Total_Interest__c);
            totalPayableAmtStr = totalPayableAmt.format();
            totalPayableAmtInWords = removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) totalPayableAmt));

            if(!loan.Payments__r.isEmpty()) {
                List<String> beneficiaryList = new List<String>();
                for (Payment__c each : loan.Payments__r) {
                    if (each.RecordType.DeveloperName == 'Payment_Favouring' && (each.Payment_Recipient__c == 'UCD' || each.Payment_Recipient__c == 'Dealer')) {
                        dealerPayment = each;
                    }
                    if (each.RecordType.DeveloperName == 'Payment_Favouring' && String.isNotBlank(each.Name__c)) {
                        system.debug('tte '+each.Name__c);
                        beneficiaryList.add(each.Name__c);
                    }
                }
                beneficiaryName = String.join(beneficiaryList, ',');
                system.debug('beneficiaryName'+beneficiaryName);
            }
            String product = 'A_'+loan.Product__c;
            productRT = ProductRTMap__mdt.getInstance(product);
            system.debug('***** collateral : ' + loan.Collaterals__r);
            if(loan.Collaterals__r!=null && loan.Collaterals__r.size()>0){
                collateral = loan.Collaterals__r[0];
            }
            system.debug('***** collateral : ' + collateral);
            if(loan.Charges__r!=null && loan.Charges__r.size()>0){
                charges = new List<Charge__c>();
                charges = loan.Charges__r;
                otherChargesAmount=0;
                processingFeesAmount=0;
                Decimal processingFeesAmountTotal = 0;
                Decimal processingFeesAmountGST = 0;
                Decimal insuranceChargeAmt = 0;
                stampDutyAmount=0;
                documentationChargeAmount=0;
                rcChargeAmount=0;
                for(Charge__c charge: charges){
                    if(charge.Charges_Name__c=='Processing Fees'){
                        processingFeesAmount = processingFeesAmount + charge.Charge_Amount__c;
                        processingFeesAmountGST = processingFeesAmountGST + (charge.Tax_Percentage__c != null && charge.Charge_Amount__c != null ?
                            charge.Tax_Percentage__c * charge.Charge_Amount__c : 0);
                        processingFeesAmountTotal = processingFeesAmountTotal + (charge.Total_Amount__c != null ? charge.Total_Amount__c : 0);
                    } else if(charge.Charges_Name__c=='Stamp duty'){
                        stampDutyAmount = stampDutyAmount+charge.Total_Amount__c;
                    } else if(charge.Charges_Name__c=='Documentation Charges'){
                        documentationChargeAmount = documentationChargeAmount+charge.Total_Amount__c;
                    } else if(charge.Charges_Name__c=='RC Charges'){
                        rcChargeAmount = rcChargeAmount+charge.Total_Amount__c;
                    } else if (charge.Charges_Name__c == 'Insurance Premium') {
                        insuranceChargeAmt += insuranceChargeAmt + (charge.Total_Amount__c != null ? charge.Total_Amount__c : 0);
                    } else if(charge.Charges_Name__c!='Processing Fee' && charge.Charges_Name__c!='Stamp duty' && charge.Charges_Name__c!='Cibil charges'){
                        otherChargesAmount = otherChargesAmount+charge.Total_Amount__c;
                    }
                    if (charge.Charges_Name__c != 'Processing Fees' && charge.Charges_Name__c != 'Insurance Premium' && charge.Charge_Amount__c > 0) {
                        chargeDetails.add(new ChargesWrapper(charge));
                    }
                }
                processingFeesAmountStr = processingFeesAmount.format();
                processingFeesAmountGSTStr = Math.round(processingFeesAmountGST).format();
                processingFeesAmountInWords = removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) processingFeesAmountTotal));
                insuranceChargeAmtStr = insuranceChargeAmt.format();
                insuranceChargeAmtInWords =removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) insuranceChargeAmt));
                otherChargesAmountStr = otherChargesAmount.format();
                otherChargesAmountInWords = removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) otherChargesAmount));
                stampDutyAmountStr = stampDutyAmount.format();
                stampDutyAmountInWords = removeRupeesKeywordFromAmount(NumberToWord.getNumberTOWord((Long) stampDutyAmount));
            }
            if(loan.Applicants__r!=null && loan.Applicants__r.size()>0){
                coapplicants=new List<Applicant__c>();
                guarantors=new List<Applicant__c>();
                Integer i = 0;
                for(Applicant__c app: loan.Applicants__r){
                    switch on app.RecordType.DeveloperName {
                        when 'Primary_Applicant' {
                            applicant = app;
                        }   
                        when 'Co_Applicant' {       
                            coapplicants.add(app);
                        }
                        when 'Guarantor' {
                            guarantors.add(app);
                        }
                        when 'BO' {
                            if (i < 2) {
                                twoBOsList.add(app);
                            } else {
                                allBOsList.add(app);
                            }
                            i++;
                        }
                    }
                    addressMap.put(app.Id, new Map<String, Address__c>{'Permanent' => new Address__c(), 'Current' => new Address__c(), 'Office' => new Address__c()});
                }
                if(applicant!=null){
                    List<Address__c> addresses = [SELECT Address_Line_1__c, District__c, Applicant__r.RecordType.DeveloperName, Address_Type__c, Address_Line_2__c, Address_Line_3__c, City__c, State__c, Pincode__c, Applicant__c
                    FROM Address__c
                    WHERE Source_Type__c IN (null, 'CBS', '') AND Address_Type__c IN ('Current','Office', 'Permanent') AND (Applicant__c in :addressMap.keySet())];
                    if(addresses!=null && addresses.size()>0){
                        for(Address__c add: addresses){
                            addressMap.get(add.Applicant__c).put(add.Address_Type__c, add);
                        }
                    }
                }
                customerCurrentAddress = addressMap.get(applicant.Id).get('Current');
                applicantAddress = customerCurrentAddress;
            }else{
                applicant = new Applicant__c();
                coapplicants = new List<Applicant__c>();
                guarantors = new List<Applicant__c>();
            }
        }
        todaysDate = System.Now().format('dd/MM/yyyy');
        nodalOfficerDetails = Officer_Details__mdt.getInstance('Nodal_Officer');
        if(!loanApps.isEMpty()){
            socChargesData = getSOCMetadataRecords(loanApps[0].RecordType.DeveloperName);
            socInterestRateData = getSOCInterestRates(loanApps[0].RecordType.DeveloperName);
        }
        
        return loan;
    }
    
    private Static List<SOC_Charges_Metadata__mdt > getSOCMetadataRecords(String productType){
        if(String.isNotBlank(productType)){
            return [SELECT Id, Label, Charge_Value__c, Order__c, Product_Type__c, Parameters__c FROM SOC_Charges_Metadata__mdt WHERE 
                   Product_Type__c = :productType ORDER BY Order__c];
        }
        else{
            return new List<SOC_Charges_Metadata__mdt>();
        }
    }
    
    private Static List<SOC_Interest_Rates__mdt  > getSOCInterestRates(String productType){
        if(String.isNotBlank(productType)){
            return [SELECT Id, Label, Interest_Type__c , Interest_Rate__c , Product_Type__c FROM SOC_Interest_Rates__mdt WHERE 
                   Product_Type__c = :productType];
        }
        else{
            return new List<SOC_Interest_Rates__mdt>();
        }
    }


    /*private static String calculateEMIDate(String dateParameter, Decimal tenure, Boolean returnMaturityDate) {
        if (dateParameter.length() != 2 || !dateParameter.isNumeric()) {
            return '';
        }
        Integer year = Date.today().year();
        Integer dateVal = Integer.valueOf(dateParameter);
        Integer month = dateVal < Date.today().day() ? Date.today().month() + 1 : Date.today().month();
        if (month > 12) {
            month = 1;
            year++;
        }
        Date emiDate = Date.newinstance(year, month, dateVal);
        if (returnMaturityDate) {
            if (tenure == null) {
                return '';
            }
            Date maturityDate = emiDate.addMonths(Integer.valueOf(tenure));
            return maturityDate.format();
        } else {
            return emiDate.format();
        }
    }*/

    public static String calculateEMIDate(String dateParameter, Decimal tenure, Boolean returnMaturityDate, Date emiFirstDate) {
        // if (dateParameter.length() != 2 || !dateParameter.isNumeric()) {
        //     return '';
        // }
        // Integer year = Date.today().year();
        // Integer dateVal = Integer.valueOf(dateParameter);
        // System.debug('----Date.today().day(): '+Date.today().day());
        // System.debug('----Date.today().month(): '+Date.today().month());
        // Integer month = dateVal < Date.today().day() ? Date.today().month() + 1 : Date.today().month();
        // if (month > 12) {
        //     month = 1;
        //     year++;
        // }
        // Date emiDate = Date.newinstance(year, month, dateVal);

        Date emiDate = emiFirstDate;
        if (returnMaturityDate) {
            if (tenure == null) {
                return '';
            }
            Date maturityDate = emiDate.addMonths(Integer.valueOf(tenure));
            emiDateValue = maturityDate;
            return maturityDate.format();
        } else {
            emiDateValue = emiDate;
            return emiDate.format();
        }
    }
}