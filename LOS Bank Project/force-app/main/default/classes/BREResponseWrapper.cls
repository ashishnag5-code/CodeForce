public class BREResponseWrapper {
    
    public cls_message message;
    
    public class cls_message {
        public String requestTime;  //2023-02-13T00:01:17Z
        public String responseTime; //2023-02-13T00:01:17Z
        public Double elapsedTime;  //10
        public String dmRequestTime;    //Feb 13, 2023 5:27:30.847 PM UTC
        public String dmResponseTime;   //Feb 13, 2023 5:27:30.862 PM UTC
        public Double dmElapsedTime;    //15
        public String decisionService;  //DS_TW
        public String callType; //DP_ELIGIBILITY
        public String responseStatus;   //SUCCESS
        public cls_application application;
        public cls_Error[] error;
    }
    
    public class cls_application {
        public cls_applicationInfo applicationInfo;
        public cls_applicants[] applicants;
        public cls_product[] product;
        public Integer randomNumber;    //0
        public cls_applicationDecision applicationDecision;
    }
    
    public class cls_applicationInfo {
        public String applicationId;    //196655438X
        public String leadId;   //leadId0
        public String transactionId;    //transactionId0
        public String branchCode;   //branchCode0
        public String branchName;   //branchName
        public String branchHub;    //hub code
        public String branchRegion; //region code
        public String applicationDate;  //2023-02-13T18:13:51Z
        public String applicationStage; //QDE
        public Integer applicationCounter;  //1
        public String roName;   //roName0
        public String roCode;   //roCode0
        public String rmName;   //rmName0
        public String rmCode;   //rmCode0
    }
    
    public class cls_applicants {
        public String applicantType;    //PRIMARY
        public String applicantId;  //196655438
        public String customerGrade;    //IB
        public cls_applicantDecision applicantDecision;
        public String cpvWaivedOff;
    }
    
    public class cls_applicantDecision {
        public cls_calculatedVariables[] calculatedVariables;
        public cls_fiInitiationDetails[] fiInitiationDetails;
        public cls_uwCriterias[] uwCriterias ;
    }
    
    public class cls_calculatedVariables {
        public String fieldName;    //LATEST_AMB_AT_APPLICATION_LEVEL
        public String fieldType;    //Double
        public String fieldValue;   //100000
        public String level;    //APPLICATION
        public Decimal variance;
        
    }
    
    public class cls_fiInitiationDetails {
        public String fiType;   //TOUCHPOINT
        public boolean isFIRequired = false;
        public String pinCodeCategory;  //WORKING
    }
    
    public class cls_uwCriterias {
        public String ruleId;   //BIOMETRIC_EXISTING_LIABILITY_CUSTOMER_CATEGORY_A
        public String rulesetName;  //RS_STDCPVWaiverRules
        public String reasonCode;   //CPV Waived on Biometric
        public String reasonText;   //CPV Waived on Biometric
        public String ruleLevel;    //AADHAR_BIOMETRIC_CPV_WAIVER
        public String applicantId;  //196655438
        public String applicantType;    //PRIMARY
    }
    
    public class cls_product {
        public String productType;  //TW_NEW
        public String productCode;  //11703
        public String subProductType;   //BIKE
        public String schemeId; //schemeId0
        public String loanPurpose;  //BUY
        public String loanType; //NEW
        public String natureOfLoan; //BUY
        public String emiFrequency; //12
        public String scheduleType; //12
        public Double requestedLoanAmount;  //100000
        public Double requestedInstallmentAmount;   //5000
        public Double requestedTenor;   //24
        public Double requestedROI; //10
        public String rateType; //VARIABLE
        public Integer noOfTopUp;   //0
        public cls_productDecision productDecision;
    }
    
    public class cls_productDecision {
        public String productDecision;  //STP
        public cls_schemeDecision[] schemeDecision;
    }
    
    public class cls_schemeDecision {
        public String schemeId; //CIBIL_HIT_NORMAL_STP
        public String schemeName;   //CIBIL_HIT_NORMAL_STP
        public String schemeType;   //STP
        public String schemDecision;    //STP
        public boolean isEligible;
        public Double maxEligibileLoanAmount;   //100000
        public Double maxEligibileTenure;   //24
        public Double maxLTV;   //90
        public Double finalIRR; //18.99
        public Double finalProcessingFee;   //1000
        public cls_subjectivityMessages[] subjectivityMessages;
        public cls_deviationsDetails[] deviationsDetails;
        public cls_calculatedVariables[] calculatedVariables;
        public Boolean blnSchemeSelectedByRO = false;
        public String strSchemeNameWithWOEligible = '';
        public String strSchemeCodeWithWOEligible = '';
    }
    
    public class cls_subjectivityMessages {
        public String message; //Sub to OHP
        public String type; //OPS
    }
    
    public class cls_deviationsDetails {
        public String ruleId;   //APPLICANT_AGE_CHECK
        public String rulesetName;  //RS_NormalSchemeRules
        public String ruleDescription; //
        public String outcome;  //NSTP
        public String reasonCode;   //Age norms not met
        public String reasonText;   //applicant age < 21 years
        public String ruleLevel;    //AGE_NORM_DEVIATION
        public String overrideAuthority;    //L3
        public String applicantId;  //19665543
        public String applicantType;    //PRIMARY
        public cls_calculatedVariables[] calculatedVariables = NULL;
        public Decimal variance;
    }
    
    public class cls_applicationDecision {
        public String systemDecision;   //STP
        public String systemDecisionDate;   //2023-02-13
        public String strategyUsed; //CHAMPION
        public String uwAuthority ; //L1
        public cls_calculatedVariables[] calculatedVariables;
    }
    
    public class cls_Error {
        public String errorCode = '';
        public String description = '';
        //public String stackTrace = '';
    }
    
    
    
    
    public static BREResponseWrapper parse(String json){
        return (BREResponseWrapper) System.JSON.deserialize(json, BREResponseWrapper.class);
    }
    
    
}