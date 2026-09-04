/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class GlobalConstants {
    public GlobalConstants() {

    }

    
    public static string OWNLAND_RCL_RECORDTYPE_NAME = 'Agriculture Income';
    public static string COMMERCIAL_RECORDTYPE_NAME = 'Commercial Income';
    public static string ADDITIONAL_MATCH_RECORDTYPE = 'Additional_Match';
    public static string KARZA_ELECTRICITY_BILL = 'Electricity Bill';
    public static string KARZA_PNG_BILL = 'PNG Bill';
    public static string KARZA_WATER_BILL = 'Water Bill';
    public static string KARZA_TELEPHONE_BILL = 'Telephone Bill';
    public static string KARZA_PIPED_GAS_BILL = 'Piped Gas Bill';
    public static string KARZA_POSTPAID_BILL = 'Post Paid Mobile Bill';
    public static string KARZA_LPG_BILL = 'Gas Bill';
    public static string VERIFIED = 'Verified';
    public static string NOTVERIFIED = 'Not Verified';
    public static string APPLICANT_RECORD_TYPE = 'Primary_Applicant';
    public static string APPROVAL_TYPE_PRICING = 'Pricing';
    public static string APPROVAL_TYPE_CREDIT = 'Credit';
    public static string APPROVAL_STATUS_PENDING = 'Pending';
    public static string APPROVAL_STATUS_FORWARDED = 'Forwarded';
    public static string APPROVAL_STATUS_APPROVED = 'Approved';


    public static Set<String> APPLICANTS_RECORD_TYPES_ON_DOC = new Set<String>{'Primary_Applicant','Co_Applicant','Guarantor','BO'};
    public Static  Id APPLICANT_RECORD_TYPE_ID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
    public static  Id  CO_APPLICANT_RECORD_TYPE_ID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId();
    public static  Id  GUATANTOR_RECORD_TYPE_ID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Guarantor').getRecordTypeId();
    public static  Id  BO_RECORD_TYPE_ID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('BO').getRecordTypeId();

    public static Set<Id> APPLICANTS_RECORD_TYPES_IDS = new Set<Id>{APPLICANT_RECORD_TYPE_ID,CO_APPLICANT_RECORD_TYPE_ID,GUATANTOR_RECORD_TYPE_ID,BO_RECORD_TYPE_ID};


    // KYC Additional Documents 
    public static String KYC_ADDITIONAL_DOCS = '(\'Pan Card/Form 60\',\'Aadhaar Card\',\'Passport\', \'Voter ID Card\',\'Driving Licence\',\'NPR document\',\'NREGA document\',\'TIN Document\',\'CIN\',\'GST\',\'registration certificate\')';
    public static String KYC_NI_DOCS = '( \'TIN Document\',\'GST\',\'registration certificate\')';
    public static List<String> KYC_DOCS = new List<String>{'Pan Card/Form 60', 'Aadhaar Card','Passport','Voter ID Card','Driving Licence','NPR document','NREGA document','TIN Document','GST','registration certificate','CIN'};

    // BRIDGE APP RELATED - START
    public static FINAL string APPLICANT_ID = 'applicantId';
    public static FINAL string BODY_ERROR ='Request body is not in expected formate';
    public static FINAL string DATA_BLANK ='data is blank';
    public static FINAL string APPLICANT_MISSING='applicantId Missing';
    public static FINAL string APPLICANT_BLANK='applicantId is blank';
    public static FINAL string APPLICANT_INVALID='applicantId is invalid';
    public static FINAL string PIDATA_BLANK='PidData is blank';
    public static FINAL string DATA = 'data';
    public static FINAL string DEVICE_INFO = 'DeviceInfo';
    public static FINAL string RDS_ID = 'rds_id';
    public static FINAL String RDSID='rdsId';
    public static FINAL string RDS_VER = 'rds_ver';
    public static FINAL String RDSVER='rdsVer';
    public static FINAL string DP_ID = 'dp_id';
    public static FINAL string DPID = 'dpId';
    public static FINAL string DC = 'dc';
    public static FINAL string MI = 'mi';
    public static FINAL string MC = 'mc';
    public static FINAL string HMAC_CAPTITAL = 'Hmac';
    public static FINAL string HMAC_SMALL = 'hmac';
    public static FINAL string SKEY ='Skey';
    public static FINAL string CI ='ci';
    public static FINAL string SKEYCI ='skeyCI';
    public static FINAL string SKEYVALUE ='skeyValue';
    public static FINAL string DATA_CAPITAL ='Data';
    public static FINAL string DATA_TYPE ='dataType';
    public static FINAL string TYPE ='type';
    public static FINAL string DATA_VALUE ='dataValue';
    public static FINAL string STATUS_FAIL ='FAIL';
    public static FINAL string STATUS_SUCCESS ='SUCCESS';
    public static FINAL string ERROR ='Error';
    public static FINAL string SUCCESS ='Success';
    public static FINAL string HIGH ='High';
    public static FINAL string STATUS ='Status';
    public static FINAL string SFDC_TOKEN_SERVICE ='SFDCAadharVaultService';
    public static FINAL string AADHAAR_BIO_SERVICE ='Aadhaar - Biometric';
    public static FINAL string GUID_VALUE = 'guidValue';
    public static FINAL string TOKEN_VALUE = 'tokenValue';
    public static FINAL string FORMAT_VALUE = 'formatValue';
    public static FINAL string VALUE = 'value';
    public static FINAL string ENCRYPTION_KEY='encryptionKey';
    public static FINAL string IV='iv';
    public static FINAL string CHANNEL='channel';
    public static FINAL string LOS ='LOS';

    // BRIDGE APP RELATED - END
    
    public  static  FINAL   string  SEVERITYTYPE_HIGH = 'High';
    public  static  FINAL   string  LEADTOLEADDEDUPE    =   'Lead to Lead Dedupe';
    public  static  FINAL   string  CUSTOMERDEDUPE  =   'Customer Dedupe';
    public  static  FINAL   string  CUSTOMERDEDUPEDETAIL    =   'Customer Dedupe Detail';
    public  static  FINAL   string  CUSTOMERDEDUPECREDITCARD    =   'Customer Dedupe Credit Card';
    public  static  FINAL   string  LEADDEDUPESF    =   'Lead Dedupe SF';
    public  static  FINAL   string  APPLICANT   =   'Applicant';
    public  static  FINAL   string  COAPPLICANT =   'Co-Applicant';
    public  static  FINAL   string  GUARANTOR   =   'Guarantor';
    public  static  FINAL   string  QDE =   'QDE';
    public  static  FINAL   string  PDD =   'PDD';
    public  static  FINAL   string  CANCELLED   =   'Cancelled';
    public  static  FINAL   string  REJECTED    =   'Rejected';
    public  static  FINAL   string  CIF =   'CIF';
    public  static  FINAL   string  AADHAARPAN  =   'Aadhaar/Pan';
    public  static  FINAL   string  AADHAAR =   'Aadhaar';
    public  static  FINAL   string  PAN =   'Pan';
    public  static  FINAL   string  INDIVIDUAL  =   'Individual';
    public  static  FINAL   string  NON_INDIVIDUAL  =   'Non Individual';
    public  static  FINAL   string  SFDEDUPEDIFFERENTPRODUCT    =   'SF Dedupe - Different Product';
    public  static  FINAL   string  SAMECUSTOMERHASADIFFERENTLEAD1   =   'Same customer has a different Lead open for another product';
    public  static  FINAL   string  SFDEDUPESAMEPRODUCT =   'SF Dedupe - Same Product';
    public  static  FINAL   string  SAMECUSTOMERHASADIFFERENTLEAD2   =   'Same customer has a different Lead cancelled/rejected for same product';
    public  static  FINAL   string  NAME_MATCH_LESS_THAN_THRESHOLD   =   'Match Pan name and Aadhaar name';
    public  static  FINAL   string  S1  =   'S1';
    public  static  FINAL   string  COMPLETE    =   'Complete';
    public  static  FINAL   string  PENDING =   'Pending';
    public  static  FINAL   string  CBS =   'CBS';
    public  static  FINAL   string  CBS_Aadhaar =   'Aadhaar - Physical Document';
    public  static  FINAL   string  STATUS_PENDING =   'Pending';
    public  static  FINAL   string  DISBURSED   =   'Disbursed';
    public  static  FINAL   string  TWOWHEELER  =   'Two Wheeler';
    public  static  FINAL   string  FOURWHEELER =   'Four Wheeler';
    public  static  FINAL   string  TRACTOR =   'Tractor';
    public  static  FINAL   string  COMMERCIALVEHICLE =   'Commercial Vehicle';
    public  static  FINAL   string  CONSTRUCTIONEQUIP =   'Construction Equipment';
    public  static  FINAL   string  TWO_WHEELER =   'Two_Wheeler';
    public  static  FINAL   string  FOUR_WHEELER    =   'Four_Wheeler';
    public  static  FINAL   string  COMMERCIAL_VEHICLE    =   'Commercial_Vehicle';
    public  static  FINAL   string  CONSTRUCTION_EQUIP    =   'Construction_Equipment';
    public  static  FINAL   string  PREFIXPRODRTMAP =   'A_';
    public  static  FINAL   string  LOAN    =   'Loan';
    public  static  FINAL   string  ODCC    =   'ODCC';
    public  static  FINAL   string  CC  =   'CC';
    public  static  FINAL   string  CASA    =   'CASA';
    public  static  FINAL   string  FDRD    =   'FDRD';
    public  static  FINAL   string  BANK_ACCOUNT_RECORDS    =   'Bank_Account_Records__c';


    public static string CURRENT = 'CURRENT';
    public static string PERMANENT = 'PERMANENT';
    public static string TOUCHPOINT = 'TOUCH POINT';
    public static string OFFICE = 'OFFICE';
    public static string FI = 'FI';
    public static string OWNERID = 'OwnerId';
    public static string ASSIGNED = 'Assigned';
    
    public static string CLOSED = 'Closed';
    public static string INPROGRESS = 'In Progress';
    public static string NA = 'NA';
    public static string CIBIL = 'Cibil';
    public static string NEGATIVE = 'Negative';
    public static string FINALSTATUS = 'Final Status';

    public static string TWOWHEELERNEW ='Two Wheeler (New)';
    public static string TWOWHEELERUSED = 'Two Wheeler (Used)';
    public static string TWOWHEELERCASH ='Two Wheeler (Cash on Wheels)';
    public static string AUTOLOANNEW ='Auto Loan (New)';
    public static string AUTOLOANUSED ='Auto Loan (Used)';
    public static string AUTOLOANCASH ='Auto Loan (Cash on Wheels)';

    public static string AGRI_LOAN_SECURED ='Agri Loan Secured by Vehicle';
    public static string BUSINESS_LOAN_SECURED ='Business Loan Secured by Vehicle';
    public static string PERSONAL_LOAN_SECURED ='Personal Loan Secured by Vehicle';

    /* Used at User Trigger Level - Harshit -START */
    public static String SALES_PROFILE = 'Sales';
    public static String TYPE_QUEUE = 'Queue';
    public static String EDIT_ACCESS = 'Edit';
    /* Used at User Trigger Level - Harshit -END */

    public static String CART_RECORDTYPE_NAME = 'Cart';
    public static String STAGE_CREDIT = 'Credit';
    public static String STAGE_PRICING = 'Pricing';
    public static String STAGE_PSD = 'PSD';
    public static String STAGE_DDE = 'DDE';
    public static String STAGE_OPS_MAKER = 'Ops Maker';

    //Payment API 
    public static String NEFT_SOURCE = 'SFDC';
    public static String RTGS_SOURCE = 'SFDC';
    public static String IMPS_ORIGINATING_CHANNEL = Label.PaymentIMPSChannel;
    public static String IMPS_TRANSACTION_CURRENCY = '1';
    public static String IFT_TRANSACTION_TYPE = '5';
    public static String IFT_TO_ACCOUNT_CURRENCY = '1';
    public static String IFT_CHANNEL = Label.PaymentIFTChannel;
    public static String IFT_TRANSACTION_CURRENCY = '1';
    public static String IFT_FROM_ACCOUNT_CURRENCY = '1';
    public static String IMPS_TRANSACTION_REMARKS = 'Money Transfer';
    public static String PAYMENT_ACCOUNT_TYPE_SAVING = 'Saving Account';
    public static String PAYMENT_ACCOUNT_TYPE_CURRENT = 'Current Account';
    public static String PAYMENT_CALL_TYPE_NEFT = 'Payment Non Cheque';
    public static String PAYMENT_CALL_TYPE_CHEQUE = 'Payment Cheque';


    //LAN Creation Static Values
    public static String MISCLASS = 'DIVISION';
    public static Integer MISCODE = 0;
    public static Integer LAN_CREATION_REPAYMENT_MODE = 1;
    public static Integer ACCOUNT_DATE_BASIS = 2;
    public static Integer RATE_TYPE = 1;
    public static String RESCHEDULE_TYPE = 'N';
    public static String PRIMARY_SECONDARY_COLLATERAL = 'P';
    public static String FLAG_DEDUCTION = 'Y';
    public static Integer CUSTODY_STATUS = 0;
    public static String DEED_DETAILS = 'AUF';
    public static Integer TYPE_OF_CHARGE = 1;
    public static String INTEREST_VARIANCE_TYPE = 'A';
    public static String AUTOMOBILE_DESCRIPTION = 'test';

    //CREDIT/CAM
    public static String CREDIT_VF_PAGE_NAME = 'CreditSummary4W';

    //TeamMemberRoles
    public static String HUB_HEAD = 'Hub Head (CBM)';
    public static String REGION_HEAD = 'Region Head (RBM)';
    public static String ZONE_HEAD = 'Zonal Head (ZBM)';
    public static String NATIONAL_HEAD = 'National Head (NBM/ NPM)';

    public static String BRE_DECISION_STP = 'STP';
    public static String BRE_DECISION_NSTP = 'NSTP';

    public static String TW_RISK_CATEGORY_HRP = 'HRP';
    public static String TW_RISK_CATEGORY_AGRI = 'Agriculture';
    public static String TW_RISK_CATEGORY_RCO = 'RCO';
    public static String TW_RISK_CATEGORY_NORMAL = 'Normal';

    public static String[] APPLICANT_EMPLOYMENT_TYPE_AGRI = new String[] { 'Farmer' };

    public static final String DEFAULT_COLLATERAL_ENGINE_CATEGORY = 'BS6';
    public static final String DEFAULT_COLLATERAL_METHOD_OF_ASSESSMENT = 'LTV';
    
    public static Set<String> UTILITY_BILLS = new Set<String>{KARZA_ELECTRICITY_BILL,KARZA_WATER_BILL,KARZA_TELEPHONE_BILL,KARZA_PIPED_GAS_BILL,KARZA_POSTPAID_BILL};
    public static Map<String,String> ADDRESS_SOURCE_CKYC_MAP  =  new Map<String,String>{
        'Voter ID Card' => 'Voter ID',
        KARZA_ELECTRICITY_BILL => 'UtilityBill',
        KARZA_WATER_BILL => 'UtilityBill',
        KARZA_TELEPHONE_BILL => 'UtilityBill',
        KARZA_PIPED_GAS_BILL => 'UtilityBill',
        KARZA_POSTPAID_BILL => 'UtilityBill',
        'Accomodation Allotment Letter' => 'Letter_Agreement',
        'Property Tax receipt' => 'Proprty_MuncipleRecpt',
        'Rent agreement' => '15'
    };

    public static Map<String,String> Get_Field_Name_From_Search_By = new Map<String,String>{
        'Loan Number' => 'Loan_Application__r.Loan_Number__c',
        'LAN' => 'Loan_Application__r.LAN__c',
        'Application ID' => 'Loan_Application__r.Application_Id__c',
        'Customer Name' => 'Loan_Application__r.Name_of_Customer__c',
        'Phone Number' => 'Loan_Application__r.Mobile__c',
        'AWB Number' => 'AWB_Number__c'
    };

    public static Map<String,String> Get_Field_Name_From_Loan_App = new Map<String,String>{
        'Loan Number' => 'Name',
        'LAN' => 'LAN__c',
        'Customer Name' => 'Name_of_Customer__c',
        'Application ID' => 'Application_Id__c',
        'Phone Number' => 'Mobile__c'
    };

    public static Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
    public static Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
    public static Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};

    public static Map<String,String> userProfile_RestrictProfileMap = new Map<String,String>{
        'Sales' => 'RO',
        'COM' => 'COM',
        'Credit Manager' => 'Credit',
        'Operations' => 'Ops',
        'Sales Manager' => 'Sales Manager',
        'Ops Maker' => 'Ops Maker',
        'Ops Author' => 'Ops Author'
    };

    //Deviations
    public static String LS_CHARGE ='LS Charge';
    public static String LS_CHARGE_DEVIATION_NAME ='LS Charge - Min Level Breached';
    public static String PF_CHARGE ='Processing Fees';
    public static String PF_CHARGE_DEVIATION_NAME ='Processing Fees - Min Level Breached';
    public static String DC_CHARGE ='Documentation Charges';
    public static String DC_CHARGE_DEVIATION_NAME ='Documentation Charges - Min Level Breached';


    //Collateral Linkage API Details Start
    public static String LINKAGE_COLLATERAL_PRIORITY ='2';
    public static String LINKAGE_PRIMARY_OR_SECONDARY_COLLATERAL='P';
    public static String LINKAGE_FLAG_DEDUCTION='Y';

    //End
    public static final String API_ERROR_MESSAGE_FORMAT = '{IntegrationChecklistNumber} - {ErrorMessage} - API Error Response : {APIStatusCode} - {APIErrorMessage}';

    public static final Double POSITIVE_INFINITY = Math.pow(10, 300) / Math.pow(10, -300);
    public static final Double NEGATIVE_INFINITY = -POSITIVE_INFINITY;

    //Specific RecordType list of applicants. Do not alter the data
    public static List<String> APPLICANT_RECORD_TYPES = new List<String>{'Primary_Applicant','Co_Applicant','Guarantor','BO'};
    
    /*SEND BACK RESTRICTED STAGE*/
    public static final List<String> RESTRICTED_STAGES = new List<String>{'Ops Maker','Ops Author','PDD','Rejected','Completed'};
    
    // Fore Closure Refinance
    public static String FORE_CLOSURE_REFINANCE = 'Fore Closure Refinance';

    // Release Payment API's
    public static Set<String> RELEASE_PAYMENT_INTEGRATION_MASTERS = new Set<String>{'Payment IFT','Payment RTGS','Payment IMPS','Payment NEFT'};

    //Payment API's
    public static String PAYMENT_IFT = 'Payment IFT';
    public static String PAYMENT_RTGS = 'Payment RTGS';
    public static String PAYMENT_IMPS = 'Payment IMPS';
    public static String PAYMENT_NEFT = 'Payment NEFT';
    // SFAU-5665 - Change 'Y' to Blank
    public static String LINKAGE_FLAG_MODE='M';
}