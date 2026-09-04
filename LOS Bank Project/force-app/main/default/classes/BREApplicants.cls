public class BREApplicants {
    public String applicantType;    //PRIMARY
    public String applicantId;  //196655438
    public boolean isFinancialApplicant;
    public String customerType; //I
    public String customerSegment;  //SALARIED
    public String customerSegmentSubType;   //DOCUMENTED
    public String customerGrade;    //IB
    public Integer noOfCattle=0; 
    public Double freeToFinanceRatio=0;
    public Double expansionRatio=0;
    public Double fcsToEMIRatio=0;
    //public Integer landInAcres; // Optional   //0
    //public String agriLandType; // Optional
    public String constitution; //INDIVIUDAL
    public boolean existingCustomer;
    public String etbType;  //NORMALmsp
    public Date dateOfBirth;    //2003-05-04
    public Integer age; //20
    public String gender;   //MALE
    public String nationality;  //INDIAN
    public String maritalStatus;    //SINGLE
    public Integer noOfDependents;  //0
    public String relationWithApplicant;    //SELF
    //MM Optional public Double shareholdingPercent = 0.0;  //0
    //MM Optional public String residentType;   //Resident Indian
    public String customerRiskProfile;  //NORMAL
    public boolean isPDSubmitted =false;
    public boolean isAUEmployee;
    public BREAuEmployeeDetails auEmployeeDetails;
    public boolean isPhysicallyChallenged;
    public Integer internalRiskScore;   //2
    public boolean isBiometricAddressNotChanged;
    public boolean isETBAddressNotChanged;
    public String cfrStatus;    //NO_MATCH
    public String amlStatus;    //NO_MATCH
    public String relatedPartyStatus;   //NO_MATCH
    public String negativePartyStatus;  //NO_MATCH
    public Integer totalRelationshipValue;  //0
    public boolean isLeadToLeadFullMatch;
    public boolean isLeadToLeadPartialMatch;
    public boolean isLeadToCustomerPartialMatch;
    public String ekycType; //BIO_METRIC
    public BRELandDetails[] landDetails = NULL;
    
    public BREEmployeeDetails employmentDetails = null;
    public BRECompanyBusinessDetails companyBusinessDetails = null;
    public BREIdDetails[] idDetaiis = NULL;
    public BREEmailDetails[] emailDetails = NULL;
    public BREAddress[] address;
    public BREIncomeData incomeData;
    public BREBankAccountDetails[] bankAccountDetails = null;
    public cls_existingCCODDetails[] existingCCODDetails = null;
    public cls_existingLoanAccountDetails[] existingLoanAccountDetails = null;
    public cls_existingCardAccountDetails[] existingCardAccountDetails = null;
    public cls_existingCASADetails[] existingCASADetails = null;
    public cls_karzaData[] karzaData = null; // Optional
    public cls_bureauResponse bureauResponse = null;
    public cls_VerificationReportData [] verificationReportData = NULL; // Optional
    // Optional - Differences Missed
    public cls_EducationDetails educationDetails = NULL; // Optional
    public cls_FinancialDetails finaicialDetails; // Optional
    // Not for TW - Phase 2 // Temp
    public String customerSubGrade = '';// 'SFO' // Mohit M.;
    
    public class BRELandDetails {
        public String ownedBy = '';
        public Integer landSize = 0;
        public String irrigationSource = '';
        public List<BRECropDetails> cropDetails;
    }
    
    public class BRECropDetails {
        public String cropName;
        public Double msp=0;
        Public Double areaUnderCrop=0;
        public Integer sowingMonth=0;
        public Integer harvestingMonth=0;
        
    }
    
    public class BRECompanyBusinessDetails {
        // Optional public String sector = '';
        // Optional public String industry = '';
        // Optional public String subIndustry = '';
        // Optional public String occupation = '';
        public Date dateOfIncorporation = null;
        public Integer noOfYearsInBusiness = 0;
    }
    
    public class cls_FinancialDetails {
        public cls_currentYearFinancials currentYearFinancials; // Optional
        public cls_previousYearFinancials previousYearFinancials; // Optional
    }
    
    public class cls_currentYearFinancials {
        public String curFinancialYears = '2021-22';    //2021-22
        public Date curDateOfFilingITR = System.Today();    //2022-05-04
        public boolean isCurYearFinancialAudited = true;
        public double curItrIncome = 1000000;   //1000000
    }
    
    public class cls_previousYearFinancials {
        public String prevFinancialYears = '2020-21';   //2020-21
        public Date prevDateOfFilingITR = System.Today().addYears(-1);  //2021-05-04
        public boolean isPrevYearFinancialAudited = true;
        public Double prevItrIncome = 600000;   //600000
    }
    
    public class cls_EducationDetails {
        public String educationStatus = '';
        // public String verificationStatus = ''; // Optional
    }
    
    public class cls_VerificationReportData {
        public String verificationType = '';
        public String verificationStatus = '';
        public String verificationRemarks = '';
        public Date verificationDate = NULL;
        public String verificationResult = '';
        public String fiNegativeReason = '';
    }
    
    public class cls_existingCCODDetails {
        public String accountType = 'string';   
        public String limitAmount = 'string';
        public Double overLimitAmount = 0;
        public Integer overLimitDPD = 0;
        public Double drawingPower = 0;
        public Double fixedInterestRate = 0;
        public Date startDate = Date.Today().addDays(-20);
        public Date endDate = Date.Today().addDays(-3);
        public Date nextExpiryDate = Date.Today().addDays(5);
        public Boolean isSecured = false;
        public String renewalMode = 'string';
        public String ownership ='string';
    }
    
    public class cls_existingLoanAccountDetails {
        public String productCode = '10301';    //TW
        public String productName = 'string';   //TWO WHEELER
        public String branchName = 'string';    //BANGALORE
        public Double loanAmount = 0;   //100000
        public Double principalOutstandingBalance = 0;  //900000
        // Optional public String ownership = 'SOW'; // ENUM    //SELF
        public Integer tenure = 0;  //0
        public Integer noOfEmiPaid = 0; //0
        public Double emiAmount = 0;    //0
        public Double overdueEMI = 0;   //0
        public Double interestRate = 0; //0
        public String status = 'string';    //ACTIVE
        //public boolean isNPAL12M = false;
        public Date openDate = Date.Today().addDays(-35);   //2022-05-04
        public Integer noOfBounces = 0; //0
        public Integer currentDPD = 0;  //0
        // Optional public Integer currentPDDRCAgening = 0; // Optional //0
        public Integer avgDelay = 0;    //0 Optional
        public Integer peakDelay = 0;   //0 Optional
        public boolean toBeConsidered = true;
        public Date nextDueDate = Date.Today().addDays(10);
        public String installmentOverdue = 'string';
        // Optional public boolean isNPAL6LM = true; // Optional
        // Optional public Integer isNPAL3LM = 0; // Optional
        public Boolean isRCPending = true;
        // Optional public Boolean noOfBouncesL6M = false;
        // Optional public Integer noOfBouncesL3M = 0;
        public String accountNumber = '';
        public Integer avgDelayL12M=0;
        public Integer peakDelayL12M=0;
    }
    
    public class cls_existingCardAccountDetails {
        public String productCode = 'string';   //PL
        public String cardStatus = 'string';    //cardStatus0
        // Optional public String blockCode1 = 'string';    //blockCode10
        // Optional public String blockCode2 = 'string';    //blockCode20
        public Date accountOpenDate = System.today().addYears(-5);  //2020-05-04
        public Double outsatandingBalance = 0;  //18000
        public Double creditLimit = 0;  //180000
        // Optional public Double highBalanceUtilization = 0;   //0
        public String dpdValue = 'string';
        public String odAmount = 'string';
        public String ownership ='string';
    }
    
    public class cls_existingCASADetails {
        public String accountType = 'String';   //CURRENT
        public String branchName = 'String';    //DELHI
        public Date accountOpeningDate = Date.Today().addYears(-4); //2020-05-04
        public Double currentBalance = 0;   //1000000
        public String currentStatus = 'ACCOUNT BLOCKED';    //OPEN
    }
    
    public class cls_karzaData {
        public String karzaVerificationType;    //CIBIL
        public String subType;  //CURRENT_ADDRESS
        public Integer scoreOrValue;    //90
        public Date reportedDate;   //2006-05-04
        public String matchType = '';
    }
    
    public class cls_bureauResponse {
        public cls_cibilResponse[] cibilResponse = null;
    }
    
    public class cls_cibilResponse {
        //public cls_accountList[] accountList;
        public Object accountList;
        //public cls_addressList[] addressList;
        public Object addressList;
        //public cls_employmentList employmentList;
        public Object employmentList;
        //public cls_enquiryList[] enquiryList;
        public Object enquiryList;
        //public cls_header header;
        public Object header;
        //public cls_idList[] idList;
        public Object idList;
        //public cls_name name;
        public Object name;
        //public cls_phoneList[] phoneList;
        public Object phoneList;
        //public cls_scoreList[] scoreList;
        public Object scoreList;
        public cls_enqActNoList[] enqActNoList = NULL;
        public cls_disputeRemarks disputeRemarks;
        public String status;   //SUCCESS
        public boolean isAddtionalMatch;
    }
    class cls_accountList {
        
        public String dateReportedAndCertified; //31012022
        public String overdueAmount;    //2641
        public String dateOpenedOrDisbursed;    //10022020
        public String accountType;  //06
        public String currentBalance;   //784
        public String paymentHistoryEndDate;    //01022020
        public String paymentHistoryStartDate;  //01012022
        public String ownershipIndicator;   //1
        public String actualPaymentAmount;  //7200
        public String emiAmount;    //1245
        public String paymentFrequence; //03
        public String paymentHistory1;  //000000000000000000000000
        public String reportingMemberShortName; //TFSL
        public String repaymentTenure;  //15
        public String dateOfLastPayment;    //07052021
        public String highCreditOrSanctionedAmount; //37485
        public String paymentHistory2;  //000000000000000000
        
    }
    public class cls_addressList {
        public String addressCategory;  //02
        public String pinCode;  //500049
        public String dateReported; //10112021
        public String addressLine1; //RANGAREDDY
        public String addressLine2; //RANGAREDDY
        public String addressLine3; //RANGAREDDY
        public String stateCode;    //36
        public String addressLine4; //RANGAREDDY
        public String enrichedThroughtEnquiry;  //Y
    }
    class cls_employmentList {
        public String accountType;  //07
        public String dateReported; //28022022
        public String occupationCode;   //01
        public Integer income;  //0
        public String netGrossIndicator;    //string
        public String monthlyAnnuallyIndicator; //string
        public String dateOfEntryForErrorCode;  //string
        public String errorCode;    //string
        public String dateOfEntryForCibilRemarksCode;   //string
        public String cibilRemarkCode;  //string
        public String dateOfEntryForErrorOrDisputeRe;   //string
        public String errorOrDisputeRemarksCode1;   //string
        public String errorOrDisputeRemarksCode2;   //string
    }
    class cls_enquiryList {
        public String enquiryPurpose;   //10
        public String dateReported; //19122018
        public String reportingMemberShortName; //NOT DISCLOSED
        public String enquiryAmount;    //1000
    }
    public class cls_header {
        public String dateProceed;  //24032022
        public String enquiryControlNumber; //004509047455
        public String enquiryMemberUserID;  //NB66467777_C2C3
        public String memberReferenceNumber;    //241780519
        public String subjectReturnCode;    //1
        public String timeProceed;  //143226
        public String version;  //12
    }
    class cls_idList {
        public String idType;   //01
        public String idValue;  //BTCPG1141A
        public String issueDate;    //string
        public String expiryDate;   //string
        public String enrichedThroughtEnquiry;  //string
    }
    public class cls_name {
        public String dob;  //30011998
        public String gender;   //2
        public String name1;    //SHIVA KRISHNA PRASAD RAO
        public String name2;    //GUDLA SHIVA KRISHNA GUDLA
        public String name3;    //string
        public String name4;    //string
        public String name5;    //string
        public String dateOfEntryForErrorCode;  //string
        public String errorSegmentTag;  //string
        public String errorCode;    //string
        public String dateOfEntryForCibilRemarksCode;   //string
        public String cibilRemarkCode;  //string
        public String dateOfEntryForErrorOrDisputeRe;   //string
        public String errorOrDisputeRemarksCode1;   //string
        public String errorOrDisputeRemarksCode2;   //string
    }
    public class cls_phoneList {
        public String enrichEnquiryForPhone;    //string
        public String telephoneExtention;   //string
        public String telephoneNumber;  //9642270850
        public String telephoneType;    //03
    }
    public class cls_scoreList {
        public String scoreName;    //string
        public String scoreCardName;    //CIBILTUSC3
        public String scoreCardVersion; //10
        public String scoreDate;    //24032022
        public String score;    //00706
        public String exclusionCode1;   //string
        public String exclusionCode2;   //08
        public String exclusionCode3;   //03
        public String exclusionCode4;   //string
        public String exclusionCode5;   //string
        public String exclusionCode6;   //string
        public String exclusionCode7;   //string
        public String exclusionCode8;   //string
        public String exclusionCode9;   //string
        public String exclusionCode10;  //string
        public String reasonCode1;  //string
        public String reasonCode2;  //string
        public String reasonCode3;  //07
        public String reasonCode4;  //string
        public String reasonCode5;  //string
        public String scoreErrorCode;   //string
    }
    class cls_enqActNoList {
        public String accountNumber;    //string
    }
    class cls_disputeRemarks {
        public String dateOfEntry;  //string
        public String disputeRemarksLine1;  //string
        public String disputeRemarksLine2;  //string
        public String disputeRemarksLine3;  //string
        public String disputeRemarksLine4;  //string
        public String disputeRemarksLine5;  //string
        public String disputeRemarksLine6;  //string
    }
    class cls_product {
        public String productType;  //TW_NEW
        public String productCode;  //11703
        public String subProductType;   //BIKE
        public String schemeId; //schemeId0
        public String loanPurpose;  //BUY
        public String loanType; //NEW
        public String natureOfLoan; //BUY
        public String emiFrequency; //12
        public String scheduleType; //12
        public Integer requestedLoanAmount; //100000
        public Integer requestedInstallmentAmount;  //5000
        public Integer requestedTenor;  //24
        public Integer requestedROI;    //10
        public String rateType; //VARIABLE
        // public Integer noOfTopUp; // Optional
        public cls_dealerDetails dealerDetails;
        //public cls_sourcingDetails sourcingDetails;
        public cls_triggerDetails triggerDetails;
        public Integer existingWheelExposure;   //0
        public Integer existingTWExposure;  //0
        public Integer existingTotalExposure;   //0
        public Integer existingGroupExposure;   //0
        public cls_vehicleDetails vehicleDetails;
        public cls_fleetDetails fleetDetails;
    }
    class cls_dealerDetails {
        public String dealerName;   //dealerName0
        public String outletName;   //outlet name
        public String dealerCode;   //dealerCode0
        public String dealerCategory;   //FOCUSED
        public String dealerClass;  //WITH_RC_LIMIT
        public String dealerState;  //RAJASTHAN
        public String dealerCity;   //JAIPUR
        public double dealerRackRate=0;
        public boolean isDealerEligibleForFIBased=false;
    }
    /*
class cls_sourcingDetails {
public String sourcingChannel;  //DEALER
public String sourceName;   //dealerName0
public String sourceCode;   //dealerCode0
public String sourcingCategory; //FOCUSED
public String sourcingClass;    //WITH_RC_LIMIT
}
*/
    class cls_triggerDetails {
        public String roTrigerType; //NA
        public String branchTriggerType;    //NA
        public String dealerTriggerType;    //NA
        public String sourcingTriggerType;  //NA
    }
    class cls_vehicleDetails {
        public String make; //JAWA
        public String model;    //110
        public String variant;  //variant0
        public String vehicleColour;    //BLUE
        public String fuelType; //DIESEL
        public String vehicleCategory;  //A
        public String vehicleUsage; //PERSONAL
        public String manufactureMonth; //12
        public String manufactureYear;  //22
        public String engineCategory;   //BS4
        public Integer ltvExShowroom;   //90
        public Integer ltvOnRoad;   //80
        public Integer ltvOnFinalCost;  //70
        public String HPNFinanciersName;    //HPNFinanciersName0
        public String currentOwnerName; //currentOwnerName0
        public String ownerSerialNumber;    //123247239497234
        public String registrationCity; //DELHI
        public boolean isBlackListed;
        public Integer challanOverdueAmount;    //0
        public boolean isLuxaryVehicle;
        public boolean isAccessoriesFunding;
        
        //public cls_newVehicleCostDetails newVehicleCostDetails;
        //public cls_otherFundingItemsDetails otherFundingItemsDetails;
    }
    /*
* class cls_newVehicleCostDetails {
public Integer exShowroomPrice; //100000
public Integer discount;    //10000
public Integer netOfDiscountPrice;  //90000
public Integer priceVariance;   //10000
public Integer insurance;   //100000
public Integer rtoTaxes;    //0
public Integer assecessories;   //0
public Integer otherCosts;  //0
public Integer onRoadPrice; //0
public Integer finalCost;   //100000
}

class cls_otherFundingItemsDetails {
public Integer insuranceAmount; //100000
public Integer rtoAmount;   //0
public Integer assecessoriesAmount; //0
public Integer otherCosts;  //0
public Integer lsAmount;    //0
public Integer apportionedLoanAmount;   //0
}
*/
    class cls_fleetDetails {
    }
    
}