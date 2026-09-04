public class WelcomeLetterPDFController {
    public static List<Generic_Master__c> objGenericMaster{get;set;}
    public Id applicationId {get;set;}    
    public RepaymentScheduleResponseWrapper EMISchedule {get;set;} //EMISchedulesWrapper
    public LoanDetailsWrapper loanData{get;set;}
    public CollateralWrapper collateralData{get;set;}
    public ApplicantDetailsWrapper applicantData{get;set;}
    public List<ChargeDetailsWrapper> chargesData{get;set;}
    public Decimal netDisbursementAmount{get;set;}
    public String dateString {get; set;}
    public static List<SOC_Charges_Metadata__mdt > socChargesData {get; set;}
    public static String socVehicleHeader{get;set;}
    public Static String lastRepaymentDate{get;set;}



    public WelcomeLetterPDFController() {
        dateString = Date.today().format();
        applicationId =ApexPages.currentPage().getParameters().get('applicationId');
        String sObjName = applicationId.getSObjectType().getDescribe().getName();
        System.debug('------sObjName: '+sObjName);
        if(sObjName == 'Payment__c'){
            List<Payment__c> payments = [SELECT Loan_Application__c, Loan_Application__r.Total_Charges__c, Disbursement_Amount__c, Tranche_Number__c FROM Payment__c WHERE Id=:applicationId];
            System.debug('------payments: '+payments);
            if(payments!=null && payments.size()>0){
                Payment__c tranche = payments[0];
                System.debug('------tranche.Disbursement_Amount__c: '+tranche.Disbursement_Amount__c);
                System.debug('------tranche.Tranche_Number__c: '+tranche.Tranche_Number__c);
                if(tranche.Tranche_Number__c == 1){
                    netDisbursementAmount = tranche.Disbursement_Amount__c-tranche.Loan_Application__r.Total_Charges__c;
                }else{
                    netDisbursementAmount = tranche.Disbursement_Amount__c;
                }
                applicationId = tranche.Loan_Application__c;
            }
            
        }

        objGenericMaster = getStaticConntent();
        EMISchedule = getWelcomeLetterContent(applicationId);
        System.debug('------EMISchedule: '+EMISchedule);
        System.debug('------objGenericMaster: '+objGenericMaster);
        List<Loan_Application__c> loanApplicationDetails = [SELECT id,Name,LAN__c ,Total_Loan_Amount__c, Disbursement_Date__c,
            RecordType.DeveloperName , 
            Total_Charges__c,Tenure__c, EMI__c, EMI_Date__c, Type_of_Rate__c, ROI__c,Repayment_Account_Number__c, toLabel(Product__c),
            Rate_Chart_Code__r.Rate_Type__c, RecordType.Name, First_EMI_Date__c FROM Loan_Application__c where Id =: applicationId LIMIT 1];
        System.debug('Final Data ' + loanApplicationDetails); 
        socChargesData = getSOCMetadataRecords(loanApplicationDetails[0].RecordType.DeveloperName);
        socVehicleHeader = (loanApplicationDetails[0].RecordType.Name == 'Four Wheeler') ? 'Car' : loanApplicationDetails[0].RecordType.Name; //R2-2862
        if(!loanApplicationDetails.isEmpty()){
            loanData = setLoanApplicationDetails(loanApplicationDetails[0]);
            if(netDisbursementAmount==null){
                loanData.loanDisbursalAmount = loanApplicationDetails[0].Total_Loan_Amount__c == null ? '0' : loanApplicationDetails[0].Total_Loan_Amount__c.format();
            }else{
                loanData.loanDisbursalAmount = netDisbursementAmount == null ? '0' : netDisbursementAmount.format();
            }
         System.debug('----loanData.loanDisbursalAmount: ' + loanData.loanDisbursalAmount); 

        }
        List<Collateral__c> collateralList =[SELECT Id, Registration_Number__c, Vehicle_Number__c, Model__c, Make__c, Variant__c FROM Collateral__c where Loan__c =: applicationId 
                                            AND Is_Deleted__c = false LIMIT 1];
        if(!collateralList.isEmpty()){
            collateralData=setCollateralDetails(collateralList[0]);
        }
        
        String applicantRecordTypeID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        List<Applicant__c > applicantlList =[SELECT Id, Title__c, First_Name__c ,Middle_Name__c,Last_Name__c, Mobile_Number__c, CIF_No__c FROM Applicant__c where Loan__c =: applicationId and RecordTypeId =: applicantRecordTypeID LIMIT 1];
        //system.debug('applicant data '+applicantlList);
        if(!applicantlList.isEmpty()){//( Address_Source__c=null or Address_Source__c = '')
            List<Address__c> addressList = [SELECT Address_Line_1__c,Address_Line_2__c,Address_Line_3__c, Address_Source__c ,Address_Type__c,Area_Name__c ,City__c,District__c,Land_mark__c,Pincode__c ,State__c  FROM Address__c where Applicant__c =: applicantlList and Address_Type__c = 'Current'   AND Address_Line_1__c <> null LIMIT 1];
            if(!addressList.isEmpty()) {
                applicantData = setApplicantDetails(applicantlList[0],addressList[0]);
            } else{
                //system.debug('I am here');
                applicantData = setApplicantDetails(applicantlList[0], null);
            }
  
        }
        
        List<Charge__c> chargeList = [SELECT Id,Charges_Name__c,Total_Amount__c  FROM Charge__c where Loan_Application__c =: applicationId  ORDER BY Sequence_Number__c ASC];
        System.debug('----chargeList: ' + chargeList); 
        if(!chargeList.isEmpty()) {
            chargesData = setChargeDetails(chargeList);
            /*for(Charge__c crg: chargeList){
                chargesData.add(setChargeDetails(crg));
            }*/
        } 
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
    
    private static RepaymentScheduleResponseWrapper getWelcomeLetterContent(Id applicationId){
        EMISchedulesWrapper GeneratedEMI_ScheduleList = new EMISchedulesWrapper();
        RepaymentScheduleResponseWrapper EMI_List = new RepaymentScheduleResponseWrapper();
        
        EMI_Schedule__c EMI_Data = new EMI_Schedule__c();
        if(!String.isBlank(applicationId)){
            String gsRecordTypeID = Schema.SObjectType.EMI_Schedule__c.getRecordTypeInfosByName().get('Generated EMI Schedule').getRecordTypeId();
            String repaymentRecordTypeID = Schema.SObjectType.EMI_Schedule__c.getRecordTypeInfosByName().get('Repayment Schedule').getRecordTypeId();
            List<String> validRecordTypeIds = new List<String>{gsRecordTypeID, repaymentRecordTypeID};
            
            for (EMI_Schedule__c each : [SELECT Id, Name, EMI_Response__c, RecordType.Name from EMI_Schedule__c where RecordTypeId IN:validRecordTypeIds  and Loan_Application__c =: applicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC]) {
                if(String.isNotBlank(each.EMI_Response__c)){
                    EMI_Data = each;
                    break;
                }
                
            }
            System.debug('-----EMI_Data.EMI_Response__c: ' + EMI_Data.EMI_Response__c);
            if (EMI_Data.EMI_Response__c != null) {
                if(EMI_Data.RecordType.Name == 'Generated EMI Schedule'){
                    GeneratedEMI_ScheduleList = (EMISchedulesWrapper) System.JSON.deserialize(EMI_Data.EMI_Response__c, EMISchedulesWrapper.class);
                }
                else{
                    EMI_List = (RepaymentScheduleResponseWrapper) System.JSON.deserialize(EMI_Data.EMI_Response__c, RepaymentScheduleResponseWrapper.class);
                }
                
            }
            System.debug('EMIList: >>>' + EMI_List);
            //if((EMI_List.Response).size()>0){
            if(EMI_List.RepaymentRecords != null && (EMI_List.RepaymentRecords).size()>0){
                for(EMIScheduleWrapper wrap: EMI_List.RepaymentRecords){
                    wrap.InterestRate=wrap.InterestRate.setScale(2);
                    wrap.PrincipalAmount=wrap.PrincipalAmount.setScale(2);
                    wrap.InterestAmount=wrap.InterestAmount.setScale(2);
                    wrap.SubsidyAmount=wrap.SubsidyAmount.setScale(2);
                    wrap.PremiumAmount=wrap.PremiumAmount.setScale(2);
                    wrap.ServiceChargeAmount=wrap.ServiceChargeAmount.setScale(2);
                    wrap.CapitalizedAmount=wrap.CapitalizedAmount.setScale(2);
                    wrap.InstallmentAmount=wrap.InstallmentAmount.setScale(2);
                    wrap.PrincipalBalanceAmount=wrap.PrincipalBalanceAmount.setScale(2);
                    wrap.InstallmentStartDate = wrap.InstallmentStartDate != null ? Date.valueOf(wrap.InstallmentStartDate).format() : '';
                    wrap.InstallmentDate = wrap.InstallmentDate != null ? Date.valueOf(wrap.InstallmentDate).format() : '';
                    lastRepaymentDate = wrap.InstallmentDate;
                }
                //WelcomeLetterPDFUtil.sortRecords(EMI_List.Response, WelcomeLetterPDFUtil.SortOrder.ASCENDING);
                WelcomeLetterPDFUtil.sortRecords(EMI_List.RepaymentRecords, WelcomeLetterPDFUtil.SortOrder.ASCENDING);
            }
            if(GeneratedEMI_ScheduleList.Response != null && (GeneratedEMI_ScheduleList.Response).size()>0){
                for(EMIScheduleWrapper wrap: GeneratedEMI_ScheduleList.Response){
                    wrap.InterestRate=wrap.InterestRate.setScale(2);
                    wrap.PrincipalAmount=wrap.PrincipalAmount.setScale(2);
                    wrap.InterestAmount=wrap.InterestAmount.setScale(2);
                    wrap.SubsidyAmount=wrap.SubsidyAmount.setScale(2);
                    wrap.PremiumAmount=wrap.PremiumAmount.setScale(2);
                    wrap.ServiceChargeAmount=wrap.ServiceChargeAmount.setScale(2);
                    wrap.CapitalizedAmount=wrap.CapitalizedAmount.setScale(2);
                    wrap.InstallmentAmount=wrap.InstallmentAmount.setScale(2);
                    wrap.PrincipalBalanceAmount=wrap.PrincipalBalanceAmount.setScale(2);
                    wrap.InstallmentStartDate = wrap.InstallmentStartDate != null ? Date.valueOf( WelcomeLetterPDFUtil.dateConversion(wrap.InstallmentStartDate)).format() : '';
                    wrap.InstallmentDate = wrap.InstallmentDate != null ? Date.valueOf(WelcomeLetterPDFUtil.dateConversion(wrap.InstallmentDate)).format() : '';
                    lastRepaymentDate = wrap.InstallmentDate;
                }
                //WelcomeLetterPDFUtil.sortRecords(EMI_List.Response, WelcomeLetterPDFUtil.SortOrder.ASCENDING);
                WelcomeLetterPDFUtil.sortRecords(GeneratedEMI_ScheduleList.Response, WelcomeLetterPDFUtil.SortOrder.ASCENDING);
            }
            
        }
        if(EMI_Data.RecordType.Name == 'Generated EMI Schedule'){
            EMI_List.RepaymentRecords = GeneratedEMI_ScheduleList.Response;
        }
        return EMI_List;
    }

    private static LoanDetailsWrapper setLoanApplicationDetails(Loan_Application__c loanApplicationRecord) {
        LoanDetailsWrapper returnWrapper = new LoanDetailsWrapper();
        returnWrapper.loanAccountNumber = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.LAN__c));
        returnWrapper.loanSanctionAmount = loanApplicationRecord.Total_Loan_Amount__c == null ? '0' : loanApplicationRecord.Total_Loan_Amount__c.format();
        returnWrapper.totalchargesdeducted = loanApplicationRecord.Total_Charges__c == null ? '0' : loanApplicationRecord.Total_Charges__c.format();
        returnWrapper.loanTenure = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Tenure__c));
        returnWrapper.PEMIEMIStartDate = loanApplicationRecord.EMI_Date__c == null ? '' : calculateEMIDate(loanApplicationRecord.EMI_Date__c, loanApplicationRecord.Tenure__c, false, loanApplicationRecord.First_EMI_Date__c);
        returnWrapper.EMIPayable = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.EMI__c));
        returnWrapper.maturityDate = loanApplicationRecord.EMI_Date__c == null ? '' : calculateEMIDate(loanApplicationRecord.EMI_Date__c, loanApplicationRecord.Tenure__c, true, loanApplicationRecord.First_EMI_Date__c);
        returnWrapper.interestType = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Type_of_Rate__c));
        returnWrapper.isFixedInterestType = returnWrapper.interestType == 'Fixed' || returnWrapper.interestType == 'FIXED';
        returnWrapper.roiLabel = returnWrapper.isFixedInterestType?'Rate of Interest':setVariableROILabel(loanApplicationRecord.ROI__c);
        returnWrapper.rateofInterest = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.ROI__c));
        returnWrapper.repaymentAccountNumber = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Repayment_Account_Number__c));
        returnWrapper.firstResetOfFrequencyDate = setFirstResetDate(loanApplicationRecord.Disbursement_Date__c);
        returnWrapper.netPaymentAmount = loanApplicationRecord.Total_Loan_Amount__c != null && loanApplicationRecord.Total_Charges__c != null ? 
            (loanApplicationRecord.Total_Loan_Amount__c - loanApplicationRecord.Total_Charges__c).format() : '0';
        returnWrapper.loanRecord = loanApplicationRecord;
        System.debug('-----returnWrapper: ' + returnWrapper);
        return returnWrapper;
    }

    private static String setVariableROILabel(Decimal roi){
        Decimal repoRate = Decimal.valueOf(Label.Repo_Rate);
        Decimal spreadRate = roi - repoRate;
        return 'Rate of Interest (Repo Rate '+repoRate+' % + Spread '+spreadRate+' %) ';
    }

    private static String setFirstResetDate(Date disbursementDate){
       if(disbursementDate!=null) {
        return (disbursementDate.addMonths(3)).format();
       }
       return '';
       
    }

    private static String calculateEMIDate(String dateParameter, Decimal tenure, Boolean returnMaturityDate) {
        if (dateParameter.length() != 2 || !dateParameter.isNumeric()) {
            return '';
        }
        Integer year = Date.today().year();
        Integer dateVal = Integer.valueOf(dateParameter);
        System.debug('----Date.today().day(): '+Date.today().day());
        System.debug('----Date.today().month(): '+Date.today().month());
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
    }

    private static String calculateEMIDate(String dateParameter, Decimal tenure, Boolean returnMaturityDate, Date emiFirstDate) {
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
            if(emiDate != null){
                Date maturityDate = emiDate.addMonths(Integer.valueOf(tenure));
                return maturityDate.format();
            }
            else{
                return '';
            }
        } else {
            if(emiDate != null){
                return emiDate.format();
            }
            else{
                return '';
            }
        }
    }

    private static CollateralWrapper setCollateralDetails(Collateral__c collateralRecord) {
        CollateralWrapper returnWrapper = new CollateralWrapper();
        returnWrapper.vehicleRegistrationNumber = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Vehicle_Number__c));
        returnWrapper.showVehicleNumber = (String.isNotBlank(returnWrapper.vehicleRegistrationNumber));
        returnWrapper.model = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Model__c));
        returnWrapper.make = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Make__c));
        returnWrapper.variant = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Variant__c));
        return returnWrapper;
    }
    
    
    private static ApplicantDetailsWrapper setApplicantDetails(Applicant__c applicantRecord,Address__c addressRecord) {
        ApplicantDetailsWrapper returnWrapper = new ApplicantDetailsWrapper();
        if(addressRecord != null){
            AddressWrapper address = new AddressWrapper();
            address.addressLine1 = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_1__c));
            address.addressLine2 = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_2__c));
            address.addressLine3 = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Line_3__c));
            address.addressSource = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Source__c));
            address.addressType = nullCheckAndSetPDFData(String.valueOf(addressRecord.Address_Type__c));
            address.areaName = nullCheckAndSetPDFData(String.valueOf(addressRecord.Area_Name__c));
            address.city = nullCheckAndSetPDFData(String.valueOf(addressRecord.City__c));
            address.districe = nullCheckAndSetPDFData(String.valueOf(addressRecord.District__c));
            address.landmark = nullCheckAndSetPDFData(String.valueOf(addressRecord.Land_mark__c));
            address.pinCode = nullCheckAndSetPDFData(String.valueOf(addressRecord.Pincode__c));
            address.state = nullCheckAndSetPDFData(String.valueOf(addressRecord.State__c));
            returnWrapper.address = address;
            
        }
        returnWrapper.fullName = setApplicantName(String.valueOf(applicantRecord.First_Name__c), 
                                                  String.valueOf(applicantRecord.Middle_Name__c), 
                                                  String.valueOf(applicantRecord.Last_Name__c)
                                                 );
        returnWrapper.phone = nullCheckAndSetPDFData(String.valueOf(applicantRecord.Mobile_Number__c));
        returnWrapper.cifNo = nullCheckAndSetPDFData(String.valueOf(applicantRecord.CIF_No__c));
        returnWrapper.applicant = applicantRecord;
        return returnWrapper;
        
    }
    
    private static List<ChargeDetailsWrapper> setChargeDetails(List<Charge__c> chargesRecord) {
        List<ChargeDetailsWrapper> returnWrapper = new List<ChargeDetailsWrapper>();
        
        for(Charge__c crg: chargesRecord){
            if (crg.Total_Amount__c != null && crg.Total_Amount__c > 0) {
                ChargeDetailsWrapper newCharge = new ChargeDetailsWrapper();
                newCharge.chargeName = nullCheckAndSetPDFData(String.valueOf(crg.Charges_Name__c));
                newCharge.totalAmount = crg.Total_Amount__c != null ? crg.Total_Amount__c.format() : '0';
                returnWrapper.add(newCharge);
            }
        }
        return returnWrapper;
    }
    
    private static String nullCheckAndSetPDFData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
    }
    
    private static String setApplicantName(String firstName, String middleName, String lastName) {
        return ((String.isBlank(firstName) ? '' : firstName+' ') +(String.isBlank(middleName) ? '' : firstName+' ')+(String.isBlank(lastName) ? '' : lastName));
    }
    
    public class LoanDetailsWrapper{
        public String loanAccountNumber{get;set;} //Loan Application
        public String loanSanctionAmount{get;set;} //Loan Application
        public String loanDisbursalAmount{get;set;} //Loan Application
        public String cumulativeDisbursementAmount{get;set;} //Loan Application
        public String totalchargesdeducted{get;set;} //Loan Application
        //public String netPaymentAmount{get;set;} //Loan Application
        //public String parentLinkedLoanNumber{get;set;} 
        public String loanTenure{get;set;} //Loan Application
        public String PEMIEMIStartDate{get;set;} //Loan Application
        public String EMIPayable{get;set;} //Loan Application
        public String interestType{get;set;} //Loan Application
        public String rateofInterest{get;set;} //Loan Application
        //public String dateofFirstResetofInterest{get;set;}
        //public String resetFrequency{get;set;}
        //public String loanMaturityDate{get;set;}
        public String repaymentAccountNumber{get;set;}
        public Loan_Application__c loanRecord {get;set;}
        public String netPaymentAmount {get; set;}
        public String maturityDate {get; set;}
        public Boolean isFixedInterestType{get;set;}
        public String roiLabel{get;set;}
        public String firstResetOfFrequencyDate{get;set;}
    }
    
    public class CollateralWrapper{
        public String vehicleRegistrationNumber{get;set;}
        public String model{get;set;}
        public String make{get;set;}
        public String variant{get;set;}
        public Boolean showVehicleNumber{get;set;}
    }
    
    public class ApplicantDetailsWrapper{
        public String fullName{get;set;}
        public String phone{get;set;}
        public String cifNo{get;set;}
        public AddressWrapper address{get;set;}
        public Applicant__c applicant {get;set;}
        //public String address{get;set;}
    }
    
    public class AddressWrapper{
        public String addressLine1{get;set;}
        public String addressLine2{get;set;}
        public String addressLine3{get;set;}
        public String addressSource{get;set;}
        public String addressType{get;set;}
        public String areaName{get;set;}
        public String city{get;set;}
        public String districe{get;set;}
        public String landmark{get;set;}
        public String pinCode{get;set;}
        public String state{get;set;}
    }
    
    public class ChargeDetailsWrapper{
        public String chargeName{get;set;}
        public String totalAmount{get;set;}
    }
    
    
    public static List<Generic_Master__c> getStaticConntent(){
        return [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where Letter_Name__c IN ('Welcome Letter Important Information','Welcome Letter Notes') ORDER BY Letter_Name__c ASC];
    }
    
    public class EMISchedulesWrapper{
        public cls_TransactionStatus TransactionStatus{get;set;}
        public String PostingDate{get;set;} //20230329
        public EMIScheduleWrapper[] Response{get;set;}
    }
    
    @TestVisible
    public class RepaymentScheduleResponseWrapper{
        @AuraEnabled public cls_TransactionStatus TransactionStatus {get;set;}
        @AuraEnabled public String SessionId{get;set;}
        @AuraEnabled public List<EMIScheduleWrapper> RepaymentRecords {get;set;}
    }
    
    public class cls_TransactionStatus {
        public String ResponseCode{get;set;}    //0
        public String ResponseMessage{get;set;} //Success
        public cls_ExtendedErrorDetails ExtendedErrorDetails{get;set;}
    }
    public class cls_ExtendedErrorDetails {
        public cls_messages[] messages{get;set;}
    }
    public class cls_messages {
        public String code{get;set;}    //0
        public String message{get;set;}
    }
    
    
    
    public class EMIScheduleWrapper {
        public Integer StageNumber{get;set;}
        public Integer InstallmentCounter{get;set;}
        public String InstallmentStartDate{get;set;}
        public String InstallmentDate{get;set;}
        public Decimal InterestRate{get;set;}
        public Decimal PrincipalAmount{get;set;}
        public Decimal InterestAmount{get;set;}
        public Decimal SubsidyAmount{get;set;}
        public Decimal PremiumAmount{get;set;}
        public Decimal ServiceChargeAmount{get;set;}
        public Decimal CapitalizedAmount{get;set;}
        public Decimal InstallmentAmount{get;set;}
        public Decimal PrincipalBalanceAmount{get;set;}
        public Decimal TotalInstallmentAmount{get;set;}
        public Integer NumberOfDays{get;set;}
    }
    
}