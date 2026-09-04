public class BRERequestWrapper {
    public String RequestId = '';
    public String OriginatingChannel = 'SFDC';
    public cls_message message;
    public class cls_message {
        public String requestTime;  //2023-02-02T00:01:17Z
        public String decisionService;  //DS_TW
        public String callType; //DP_ELIGIBILITY
        public cls_application application;
        public String productType = '';
    }
    public class cls_application {
        public BREApplicationInfo applicationInfo;
        public BREApplicants[] applicants;
        public BREProduct[] product = null;
        public cls_documentsReceived[] documentsReceived = NULL;
        public cls_fleetDetails[] fleetDetails = NULL;
        public Integer randomNumber;    //0
    }
    /*
    class cls_applicants {
        public String applicantType;    //PRIMARY
        public String applicantId;  //196655438
        public boolean isFinancialApplicant;
        public String customerType; //I
        public String customerSegment;  //SALARIED
        public String customerSegmentSubType;   //DOCUMENTED
        public String customerGrade;    //IB
        public Integer landInAcres; //0
        public String agriLandType; //IRRIGATED
        public String constitution; //INDIVIUDAL
        public boolean existingCustomer;
        public String etbType;  //NORMAL
        public String dateOfBirth;  //2003-05-04
        public Integer age; //20
        public String gender;   //MALE
        public String nationality;  //INDIAN
        public String maritalStatus;    //SINGLE
        public Integer noOfDependents;  //0
        public String relationWithApplicant;    //SELF
        public Integer shareholdingPercent; //0
        public String residentType; //Resident Indian
        public String customerRiskProfile;  //NORMAL
        public boolean isAUEmployee;
        public cls_auEmployeeDetails auEmployeeDetails;
        public boolean isPhysicallyChallenged;
        public Integer internalRiskScore;   //2
        public boolean isBiometricAddressNotChanged;
        public boolean isETBAddressnotChanged;
        public String cfrStatus;    //NO_MATCH
        public String amlStatus;    //NO_MATCH
        public String relatedPartyStatus;   //NO_MATCH
        public String negativePartyStatus;  //NO_MATCH
        public Integer totalRelationshipValue;  //0
        public boolean isLeadToLeadFullMatch;
        public boolean isLeadToLeadPartialMatch;
        public boolean isLeadToCustomerPartialMatch;
        public String ekycType; //BIO_METRIC
        public cls_employmentDetails employmentDetails;
        public cls_idDetails[] idDetails;
        public cls_emailDetails[] emailDetails;
        public cls_address[] address;
        public cls_incomeData incomeData;
        public cls_finaicialDetails finaicialDetails;
        public cls_bankAccountDetails[] bankAccountDetails;
        public cls_existingLoanAccountDetails[] existingLoanAccountDetails;
        public cls_existingCardAccountDetails[] existingCardAccountDetails;
        public cls_existingCASADetails[] existingCASADetails;
        public cls_karzaData[] karzaData;
        public cls_bureauResponse bureauResponse;
    }
    class cls_auEmployeeDetails {
        public String auEmployeeStatus; //ACTIVE
        public String auEmloyeeGrade;   //A1
        public String dateOFJoining;    //2022-01-01
        public String pmsRating;    //3
    }
    class cls_employmentDetails {
        public String employmentType;   //SALARIED_PRIVATE
        public String employerName; //XXXX
        public Integer timeWithCurrentEmployer; //6
        public Integer totalWorkExperience; //6
        public String sector;   //
        public String industry; //
        public String subIndustry;  //
        public String occupation;   //
        public String companyCategory;  //CAT_A
    }
    class cls_idDetails {
        public String idType;   //PAN
        public boolean isVerified;
    }
    class cls_emailDetails {
        public String emailType;    //PERSONAL
        public boolean isEmailIdVerified;
    }
    class cls_address {
        public String addressType;  //PERMANENT
        public String pinCode;  //400029
        public String district; //Mumbai
        public String city; //Mumbai
        public String state;    //MH
        public String country;  //IN
        public Integer timeAtCurrentAddress;    //4
        public String ownershipStatus;  //PARENTAL
        public String propertyType; //BUNGALOW
        public Integer distanceFromBranch;  //5
        public boolean isNegativeArea;
        public boolean isResiCumOffice;
        public String pinCodeCategory;  //WORKING
    }
    class cls_incomeData {
        public Integer documentIncome;  //100000
        public Integer assessedIncome;  //100000
        public Integer totalMonthlyIncome;  //200000
        public Integer monthlyObligation;   //1000000
    }
    class cls_finaicialDetails {
        public cls_currentYearFinancials currentYearFinancials;
        public cls_previousYearFinancials previousYearFinancials;
    }
    class cls_currentYearFinancials {
        public String curFinancialYears;    //2021-22
        public String curDateOfFilingITR;   //2022-05-04
        public boolean isCurYearFinancialAudited;
        public Integer curItrIncome;    //1000000
    }
    class cls_previousYearFinancials {
        public String prevFinancialYears;   //2020-21
        public String prevDateOfFilingITR;  //2021-05-04
        public boolean isPrevYearFinancialAudited;
        public Integer prevItrIncome;   //600000
    }
    class cls_bankAccountDetails {
        public String bankName; //ICICI
        public String accountType;  //SAVING
        public String accountNumber;    //XXXXXX
        public String accountOpeningDate;   //2020-05-04
        public boolean toBeConsidered;
        public Integer odLimit; //0
        public String status;   //OTHERS
        public cls_monthlyBankDetails[] monthlyBankDetails;
    }
    class cls_monthlyBankDetails {
        public String bankStatementDate;    //2023-01-04
        public Integer month;   //1
        public Integer year;    //2023
        public String accountType;  //SAVING
        public Integer monthlySalary;   //0
        public boolean isSalaryCredited;
        public Integer totalDebitTransactions;  //0
        public Integer totalCreditTransactions; //0
        public Integer numberOfDebits;  //0
        public Integer numberOfCredits; //0
        public Integer inwardChequeBounces; //0
        public Integer outwardChequeBounces;    //0
        public Integer numberOfStopPayments;    //0
        public Integer averageBalanceOn5th; //100000
        public Integer averageBalanceOn15th;    //100000
        public Integer averageBalanceOn25th;    //100000
        public Integer averageMonthlyBalance;   //100000
        public Integer technicalChequeBounces;  //0
        public Integer noOfEMIBounce;   //0
        public Integer drawingPowerLimit;   //0
        public Integer avgUtilization;  //0
    }
    class cls_existingLoanAccountDetails {
        public String productCode;  //TW
        public String productName;  //TWO WHEELER
        public String branchName;   //BANGALORE
        public Integer loanAmount;  //100000
        public Integer principalOutstandingBalance; //900000
        public String ownership;    //SELF
        public Integer tenure;  //0
        public Integer noOfEmiPaid; //0
        public Integer emiAmount;   //0
        public Integer overdueEMI;  //0
        public Integer interestRate;    //0
        public String status;   //ACTIVE
        public boolean isNPAL12M;
        public String openDate; //2022-05-04
        public Integer noOfBounces; //0
        public Integer currentDPD;  //0
        public Integer currentPDDRCAgening; //0
        public Integer avgDelay;    //0
        public Integer peakDelay;   //0
        public boolean toBeConsidered;
    }
    class cls_existingCardAccountDetails {
        public String productCode;  //PL
        public String cardStatus;   //cardStatus0
        public String blockCode1;   //blockCode10
        public String blockCode2;   //blockCode20
        public String accountOpenDate;  //2020-05-04
        public Integer outsatandingBalance; //18000
        public Integer creditLimit; //180000
        public Integer highBalanceUtilization;  //0
        public cls_dpdValue dpdValue;
        public cls_odAmount odAmount;
    }
    class cls_dpdValue {
    }
    class cls_odAmount {
    }
    class cls_existingCASADetails {
        public String accountType;  //CURRENT
        public String branchName;   //DELHI
        public String accountOpeningDate;   //2020-05-04
        public Integer currentBalance;  //1000000
        public String currentStatus;    //OPEN
    }
    class cls_karzaData {
        public String karzaVerificationType;    //CIBIL
        public String subType;  //CURRENT_ADDRESS
        public Integer scoreOrValue;    //90
        public String reportedDate; //2006-05-04
    }
    class cls_bureauResponse {
        public cls_cibilResponse[] cibilResponse;
    }
    class cls_cibilResponse {
        public cls_accountList[] accountList;
        public cls_addressList[] addressList;
        public cls_employmentList employmentList;
        public cls_enquiryList[] enquiryList;
        public cls_header header;
        public cls_idList[] idList;
        public cls_name name;
        public cls_phoneList[] phoneList;
        public cls_scoreList[] scoreList;
        public cls_enqActNoList[] enqActNoList;
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
    class cls_addressList {
        public String addressCategory;  //02
        public String pinCode;  //500049
        public String dateReported; //10112021
        public String addressLine1; //RANGAREDDY
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
    class cls_header {
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
    class cls_name {
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
    class cls_phoneList {
        public String enrichEnquiryForPhone;    //string
        public String telephoneExtention;   //string
        public String telephoneNumber;  //9642270850
        public String telephoneType;    //03
    }
    class cls_scoreList {
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
*/
    public class cls_documentsReceived {
        public String documentId = 'AADHAAR';   //AADHAAR
        public String documentName = 'AADHAAR'; //AADHAAR
        public String documentDescription = 'AADHAAR CARD'; //AADHAAR CARD
        public Date documentDate = Date.Today().addMonths(-6);  //2020-05-04
        public boolean isVerified = true;
        public Date stabilityDate = Date.Today().addYears(1);   //2022-12-30
    }   
    
    public class cls_fleetDetails {
        public String ownerName = '';
        public String vehicleMakeModel = '';
        public String typeOfVehicle = '';
        public String vehicleNumber = '';
        public String mfgYear = '';
        public String hpnStatus = '';
        public String financialInstitutionName = '';
        public Integer loanTenure = 0;
        public Integer installmentPaid = 0;
        public String relationshipWithBorrower='';
        
    }

    public static BRERequestWrapper parse(String json){
        return (BRERequestWrapper) System.JSON.deserialize(json, BRERequestWrapper.class);
    }


}