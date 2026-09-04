/*******************************************************************************************
 * @Name         SanctionPDFController
 * @Author       Yash Shukla
 * @Description   Controller class to handle the Mapping of Sanction PDF
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Yash Shukla        14/03/2023         Initial Creation 
 *******************************************************************************************/
public with sharing class SanctionPDFController {

    public static PDFReturnWrapper getPDFWrapperData() { 
        PDFReturnWrapper returnWrapper = new PDFReturnWrapper();
        try {
            returnWrapper.staticContentMaster = [SELECT Id,Letter_Name__c, Name, Letter_Content__c from Generic_Master__c WHERE Letter_Name__c = 'Sanction letter'];
            returnWrapper.renderEMISanctionSection = (System.Label.ToRenderEMISection.toUpperCase() == 'TRUE');
            if(System.Label.ToRenderEMISection.toUpperCase() != 'TRUE'){
                returnWrapper.styleClassDetails = 'margin-bottom : 29% !important';
            }
            String loanApplicationId = System.currentPagereference().getParameters().get('applicationId');
            if(String.isBlank(loanApplicationId)) {
                return null;
            }
            returnWrapper.dateValue = setTodaysDate();
            List<Loan_Application__c> loanApplication = [SELECT Application_Id__c, Id, Branch_Master__r.Name, Tenure__c,
                                                         Dealer_Master__r.Name, Total_Loan_Amount__c, EMI__c, ROI__c, Type_of_Rate__c,
                                                         (SELECT Id, Total_Amount__c FROM Charges__r)
                                                         from Loan_Application__c WHERE 
                                                         Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1
            ];
            if(!loanApplication.isEmpty()) {
                returnWrapper.loanApplication = setLoanApplicationPdfDetails(loanApplication[0]);
                List<Collateral__c> collateral = [SELECT Id, DO_Number__c, Loan__c, Model__c, Make__c, Variant__c, Collateral_Type__c, Registration_Number__c, Ex_Showroom_Price__c,
                                                  Discount__c, Net_of_Discount_Price__c, Final_Cost__c, LTV_offered_On_final_cost__c, Apportioned_Loan_Amount__c, Vehicle_Number__c,
                                                  Final_Vehicle_Cost__c, RTO_Taxes__c, MMV_Master__r.Name, Insurance__c, Accessories_Funding__c, Accessories__c, RecordTypeId, RecordType.Name, On_Road_Price__c, Vehicle_Cost__c
                                                  FROM Collateral__c 
                                                  WHERE Loan__c = :loanApplication[0].Id AND Is_Deleted__c = false AND (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels')
                                                  WITH SECURITY_ENFORCED LIMIT 1
                                                 ];
                List<Applicant__c> applicant = [SELECT First_Name__c, Middle_Name__c, Last_Name__c, Father_Name__c FROM Applicant__c
                    WHERE Loan__c =:loanApplication[0].Id AND RecordType.Name = 'Applicant' WITH SECURITY_ENFORCED LIMIT 1
                ];
                if(!applicant.isEmpty()) {
                    returnWrapper.applicant = setApplicantPdfDetails(applicant[0]);
                    List<Address__c> address =[SElECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c, Pincode__c, Applicant__c, Address_Type__c, Source_Type__c
                        FROM Address__c WHERE Applicant__c =:applicant[0].Id AND Address_Type__c = 'Current' AND Source_Type__c != 'Cibil' WITH SECURITY_ENFORCED LIMIT 1
                    ];
                    if(!address.isEmpty()) {
                        returnWrapper.address = setAddressPDFDetails(address[0]);
                    }
                }
                if(!collateral.isEmpty()) {
                    returnWrapper.collateral = setCollateralPDFDetails(collateral[0]);
                }
            }
        }catch (Exception ex) {
            system.debug('error'+ex.getMessage());
            returnWrapper.isRenderSuccess = false;
            returnWrapper.failMessage = ex.getMessage();
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        return returnWrapper;
    }

    public class PDFReturnWrapper {
        public List<Generic_Master__c> staticContentMaster{get;set;}
        public LoanApplicationWrapper loanApplication{get;set;}
        public ApplicantWrapper applicant{get;set;}
        public AddressWrapper address{get;set;}
        public CollateralWrapper collateral{get;set;}
        public Boolean isRenderSuccess{get;set;}
        public String failMessage{get;set;}
        public String dateValue{get;set;}
        public String styleClassDetails{get;set;}
        public Boolean renderEMISanctionSection{get;set;}
        public Boolean renderCustomerCare{get;set;}
        public PDFReturnWrapper() {
            staticContentMaster = new List<Generic_Master__c>();
            loanApplication = new LoanApplicationWrapper();
            applicant = new ApplicantWrapper();
            address = new AddressWrapper();
            isRenderSuccess = true;
            failMessage = '';
            dateValue = String.valueOf(System.today());
            styleClassDetails = 'margin-bottom : 22% !important';
            renderEMISanctionSection = false;
            renderCustomerCare = false;
        }
    }

    public class LoanApplicationWrapper {
        public String applicationNo{get;set;}
        public String branchName{get;set;}
        public String dealerName{get;set;}
        public String loanAmount{get;set;}
        public String tenure{get;set;}
        public String emi{get;set;}
        public String effectiveROI{get;set;}
        public String interestRate{get;set;}
        public String lessCharges{get;set;}
        public String netPayable{get;set;}
        
    }

    public class ApplicantWrapper {
        public String customerName{get;set;}
        public String fatherName{get;set;}
    }

    public class AddressWrapper {
        public String address{get;set;}
        
    }

    public class CollateralWrapper {
        public String doNumber{get;set;}
        public String model{get;set;}
        public String vehicleType{get;set;}
        public String vehicleNo{get;set;}
        public String exShowRoomValue{get;set;}
        public String discount{get;set;}
        public String deduction{get;set;}
        public String finalAmount{get;set;}
        public String ltv{get;set;}
        public String loanAmount{get;set;}
        public Boolean showVehicleNumber{get;set;}
        public String assetCostLabel{get;set;}
        public String assetCost{get;set;}
    }

    private static LoanApplicationWrapper setLoanApplicationPdfDetails(Loan_Application__c loanApplicationRecord) {
        LoanApplicationWrapper returnWrapper = new LoanApplicationWrapper();
        returnWrapper.applicationNo = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Application_Id__c));
        returnWrapper.branchName = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Branch_Master__r.Name));
        returnWrapper.dealerName = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Dealer_Master__r.Name));
        returnWrapper.loanAmount = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Total_Loan_Amount__c));
        returnWrapper.tenure = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Tenure__c));
        returnWrapper.emi = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.EMI__c));
        returnWrapper.effectiveROI = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.ROI__c));
        returnWrapper.interestRate = nullCheckAndSetPDFData(String.valueOf(loanApplicationRecord.Type_of_Rate__c));
        returnWrapper.lessCharges = (!loanApplicationRecord.Charges__r.isEmpty())?setLessCharges(loanApplicationRecord.Charges__r):'0.00';
        returnWrapper.netPayable = String.valueOf(Decimal.valueOf(returnWrapper.loanAmount) - Decimal.valueOf(returnWrapper.lessCharges));
        return returnWrapper;

    }
    
    private static String setAssetCost(Collateral__c collateralRecord){
        if(collateralRecord.RecordType.Name == 'Used/Cash on Wheels'){
            return nullCheckAndSetPDFData(String.valueOf(collateralRecord.Final_Cost__c));
        }
        else{
            Decimal assetCostRetValue = 0.00;
            assetCostRetValue+=collateralRecord.Ex_Showroom_Price__c+collateralRecord.RTO_Taxes__c+
                collateralRecord.Insurance__c+((collateralRecord.Accessories_Funding__c=='Yes')?Decimal.valueOf(collateralRecord.Accessories__c):0.00);
            return String.valueOf(assetCostRetValue);
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

    private static String nullCheckAndSetPDFData(String dataValue) {
        return (String.isBlank(dataValue)? '' : dataValue);
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

    private static CollateralWrapper setCollateralPDFDetails(Collateral__c collateralRecord) {
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
        returnWrapper.model = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Make__c))+' '+nullCheckAndSetPDFData(String.valueOf(collateralRecord.Model__c))+' '+nullCheckAndSetPDFData(String.valueOf(collateralRecord.MMV_Master__r.Name));
        system.debug('yash '+returnWrapper.model);
        returnWrapper.vehicleType = collateralRecord.RecordType.Name == 'Used/Cash on Wheels'?'Used':'New';//nullCheckAndSetPDFData(String.valueOf(collateralRecord.Collateral_Type__c));
        returnWrapper.showVehicleNumber = (returnWrapper.vehicleType!='New');
        returnWrapper.vehicleType = (returnWrapper.vehicleType!='New')?'Used':returnWrapper.vehicleType;
        returnWrapper.vehicleNo = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Vehicle_Number__c));
        //returnWrapper.exShowRoomValue = setAssetCost(collateralRecord);//nullCheckAndSetPDFData(String.valueOf(collateralRecord.Ex_Showroom_Price__c));
        returnWrapper.discount = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Discount__c));
        returnWrapper.deduction = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Net_of_Discount_Price__c));
        returnWrapper.finalAmount = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Final_Cost__c));
        returnWrapper.ltv = nullCheckAndSetPDFData(String.valueOf(collateralRecord.LTV_offered_On_final_cost__c));
        returnWrapper.loanAmount = nullCheckAndSetPDFData(String.valueOf(collateralRecord.Apportioned_Loan_Amount__c));
        return returnWrapper;
    }

    private static String setTodaysDate() {
        Date todaysDate = System.today();
        return (String.valueOf(todaysDate.day())+'/'+String.valueOf(todaysDate.month())+'/'+String.valueOf(todaysDate.year()));
    }

}