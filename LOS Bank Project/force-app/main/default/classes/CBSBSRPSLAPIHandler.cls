/**
 * @author        Joshna
 * @date          19-Jul-2023
 * @description   Handler class for CBS PSL/BSR
 * @reference     API Calls
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * -----------------------------------------------------------------------------------------------------
 * Joshna                  19-Jul-2023     Initial creation - added generateRequest
 * Mohit M.                05-Dec-2023     SFAU-5698 - ‘OVD Recieved' should be stopped sending in CBR API. Only 'Deemed OVD’ status to be sent. 
 */
public with sharing class CBSBSRPSLAPIHandler {
    public static Map<String, Map<String, String>> mappingValues = new Map<String, Map<String, String>>();

    static {
        for (Integration_Mappings__mdt each : [SELECT Id, Endpoint_Value__c, Interface__c, LOS_Value__c, Tag_Name__c FROM Integration_Mappings__mdt WHERE Interface__c = 'CBS - BSR/PSL']) {
            if (!mappingValues.containsKey(each.Tag_Name__c)) {
                mappingValues.put(each.Tag_Name__c, new Map<String, String>());
            }
            //Updated by Samridhi - SFAU-5087
            mappingValues.get(each.Tag_Name__c).put(each.LOS_Value__c.toUpperCase(), each.Endpoint_Value__c);
        }
    }

    public static List<String> generateRequest(Object reqParam) {
        List<String> requestWrappers = new List<String>();
        InputWrapper inputInstance = (InputWrapper) reqParam;
        RequestWrapper requestInst = new RequestWrapper();
        requestInst.ReferenceNumber = 'SFDC' + inputInstance.requestMode + String.valueOf(System.currentTimeMillis());
        requestInst.RequestId = requestInst.ReferenceNumber;
        requestInst.CustCASATDLoanCBRRequest = new CustCASATDLoanCBRRequestWrapper();
        if (inputInstance.requestMode == 'CIF') {
            requestInst.CustCASATDLoanCBRRequest.module = 'CUST';
            requestInst.TransactionBranch = inputInstance.applicantRecord.Loan__r.Branch_Master__r.Account_Code__c;
            requestInst.CustCASATDLoanCBRRequest.customerID = inputInstance.applicantRecord.CIF_No__c;
            requestInst.CustCASATDLoanCBRRequest.COD_37 = inputInstance.applicantRecord.UDYAM_Registration_Number__c;
             // SFAU-5485 Start - Kunal 
             requestInst.CustCASATDLoanCBRRequest.COD_38 = String.isBlank(inputInstance.applicantRecord.PAN__c) ? 'Yes' : 'No';
             // SFAU-5485 End - Kunal 
            requestInst.CustCASATDLoanCBRRequest.COD_39 = inputInstance.applicantRecord.CIN__c;
            requestInst.CustCASATDLoanCBRRequest.COD_6 = inputInstance.strRiskCategory != null ? inputInstance.strRiskCategory : '';
            requestInst.CustCASATDLoanCBRRequest.COD_7 = inputInstance.applicantRecord.Passport_Number__c;
            requestInst.CustCASATDLoanCBRRequest.COD_8 = inputInstance.applicantRecord.Voter_Id__c;
            requestInst.CustCASATDLoanCBRRequest.COD_9 = inputInstance.applicantRecord.Driving_License_Id__c;
            //SFAU-5698 - ‘OVD Recieved' should be stopped sending in CBR API. Only 'Deemed OVD’ status to be sent. 
            //requestInst.CustCASATDLoanCBRRequest.COD_32 = inputInstance.applicantRecord.Deemed_KYC__c ? 'Deemed OVD' : 'OVD Recieved';
            requestInst.CustCASATDLoanCBRRequest.COD_32 = inputInstance.applicantRecord.Deemed_KYC__c ? 'Deemed OVD' : '';
            requestInst.CustCASATDLoanCBRRequest.COD_43 = inputInstance.applicantRecord.Loan__r.Three_years_average_turnover__c != null ? 
                mappingValues.get('COD_43').get(inputInstance.applicantRecord.Loan__r.Three_years_average_turnover__c) : '';
        } else {
            requestInst.CustCASATDLoanCBRRequest.module = 'LOAN';
            requestInst.TransactionBranch = inputInstance.loanRecord.Branch_Master__r.Account_Code__c;
            requestInst.CustCASATDLoanCBRRequest.accountNumber = inputInstance.loanRecord.LAN__c;
            if (inputInstance.bsrPSLRecord.PSL_Segment__c != null && mappingValues.get('COD_1').containsKey(inputInstance.bsrPSLRecord.PSL_Segment__c)) {
                //Updated by Samridhi - SFAU-5087
                requestInst.CustCASATDLoanCBRRequest.COD_1 = mappingValues.get('COD_1').get(inputInstance.bsrPSLRecord.PSL_Segment__c.toUpperCase());
            } else if (inputInstance.bsrPSLRecord.PSL_Classification_Category__c != null && mappingValues.get('COD_1').containsKey(inputInstance.bsrPSLRecord.PSL_Classification_Category__c)) {
                //Updated by Samridhi - SFAU-5087
                requestInst.CustCASATDLoanCBRRequest.COD_1 = mappingValues.get('COD_1').get(inputInstance.bsrPSLRecord.PSL_Classification_Category__c.toUpperCase());
            }
            //Updated by Samridhi - SFAU-5087
            requestInst.CustCASATDLoanCBRRequest.COD_3 = inputInstance.applicantRecord.Caste__c != null && inputInstance.applicantRecord.Caste__c.toUpperCase() != 'GENERAL' && inputInstance.applicantRecord.Caste__c.toUpperCase() != 'MINORITY' ? mappingValues.get('COD_3').get(inputInstance.applicantRecord.Caste__c.toUpperCase()) : '';
            requestInst.CustCASATDLoanCBRRequest.COD_30 = inputInstance.applicantFinancials.Sub_Industry__c;
            system.debug('inputInstance.applicantRecord.Religion__c ::'+inputInstance.applicantRecord.Religion__c );
             system.debug('mappingValues.get'+mappingValues.get('COD_4').get(inputInstance.applicantRecord.Religion__c));
             //Updated by Samridhi - SFAU-5087
            requestInst.CustCASATDLoanCBRRequest.COD_4 = inputInstance.applicantRecord.Religion__c != null && inputInstance.applicantRecord.Religion__c != 'HINDU' ? mappingValues.get('COD_4').get(inputInstance.applicantRecord.Religion__c.toUpperCase()) : '';
            requestInst.CustCASATDLoanCBRRequest.COD_5 = inputInstance.applicantFinancials.Sector__c != null ? mappingValues.get('COD_5').get(inputInstance.applicantFinancials.Sector__c.toUpperCase()) : '';
            requestInst.CustCASATDLoanCBRRequest.COD_36 = inputInstance.applicantRecord.Internal_Risk_Score__c;
            requestInst.CustCASATDLoanCBRRequest.COD_39 = 'Secured';
        }
        requestWrappers.add(JSON.serialize(requestInst, true));
        return requestWrappers;
    }

    public class InputWrapper {
        public Loan_Application__c loanRecord;
        public Applicant__c applicantRecord;
        public Applicant_Financials_Details__c applicantFinancials;
        public BSR_PSL_Details__c bsrPSLRecord;
        public String requestMode;
        public String strRiskCategory;
    }

    public class RequestWrapper {
        public String ReferenceNumber;
        public String TransactionBranch;
        public String RequestId;
        public String OriginatingChannel = Label.CBS_Channel;
        public CustCASATDLoanCBRRequestWrapper CustCASATDLoanCBRRequest;
    }

    public class CustCASATDLoanCBRRequestWrapper {
        public String accountNumber;
        public String customerID;
        public String module;
        public String COD_37;
        public String COD_38;
        public String COD_39;
        public String COD_6;
        public String COD_7;
        public String COD_8;
        public String COD_9;
        public String COD_32;
        public String COD_43;
        public String COD_1;
        public String COD_3;
        public String COD_30;
        public String COD_4;
        public String COD_5;
        public Decimal COD_36;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
}