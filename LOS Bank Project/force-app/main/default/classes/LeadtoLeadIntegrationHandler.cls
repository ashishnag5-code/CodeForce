public class LeadtoLeadIntegrationHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        if(reqParam instanceof Applicant__c){
            Applicant__c paramsMap=(Applicant__c)reqParam;
            LeadtoLeadRequestWrapper objLeadtoLeadRequestWrapper = new LeadtoLeadRequestWrapper();
            objLeadtoLeadRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
            objLeadtoLeadRequestWrapper.OriginatingChannel = Label.AUSF_Dedupe_Search_Channel;
            objLeadtoLeadRequestWrapper.SourceId = '10281';
            objLeadtoLeadRequestWrapper.CRMStringPair = new List<CRMStringPair>();
            CRMStringPair objCRMStringPair;
            objCRMStringPair = new CRMStringPair();
            objCRMStringPair.First = 'ProductCode';
            objCRMStringPair.Second = paramsMap.Loan__r.Product__c != null ? paramsMap.Loan__r.Product__c : '';
            objLeadtoLeadRequestWrapper.CRMStringPair.add(objCRMStringPair);
            
            objCRMStringPair = new CRMStringPair();
            objCRMStringPair.First = 'Phone';
            objCRMStringPair.Second = paramsMap.Mobile_Number__c != null ? paramsMap.Mobile_Number__c.replaceAll('\\D','') : '';
            objLeadtoLeadRequestWrapper.CRMStringPair.add(objCRMStringPair);
            
            objCRMStringPair = new CRMStringPair();
            objCRMStringPair.First = 'PanNumber';
            objCRMStringPair.Second = paramsMap.PAN__c != null ? paramsMap.PAN__c : '';
            objLeadtoLeadRequestWrapper.CRMStringPair.add(objCRMStringPair);
            
            objCRMStringPair = new CRMStringPair();
            objCRMStringPair.First = 'CIF';
            objCRMStringPair.Second = paramsMap.CIF_No__c != null ? paramsMap.CIF_No__c : '';
            objLeadtoLeadRequestWrapper.CRMStringPair.add(objCRMStringPair);
            
            objCRMStringPair = new CRMStringPair();
            objCRMStringPair.First = 'AAdharRef';
            objCRMStringPair.Second = paramsMap.Aadhaar_Number__c != null ? paramsMap.Aadhaar_Number__c : '';
            objLeadtoLeadRequestWrapper.CRMStringPair.add(objCRMStringPair);
            lstString.add(JSON.serialize(objLeadtoLeadRequestWrapper));
        }
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class LeadtoLeadRequestWrapper{
        public CRMStringPair[] CRMStringPair;
        public String RequestId;    //1112899
        public String OriginatingChannel;   //SFDC
        public String SourceId; //10281
    }
    
    public class CRMStringPair {
        public String Second;   //
        public String First;    //ProductCode
    }
    
    public class LeadtoLeadResponseWrapper {
        public cls_TransactionStatus TransactionStatus;
        public cls_CRMFetchResults[] CRMFetchResults;
    }
    
    public class cls_TransactionStatus {
        public String ResponseCode; //00
        public String ResponseMessage;  //Success
        public cls_ExtendedErrorDetails ExtendedErrorDetails;
    }
    
    public class cls_ExtendedErrorDetails {
        public cls_messages[] messages;
    }
    
    public class cls_messages {
        public cls_code code;
        public cls_message message;
    }
    
    public class cls_code {
    }
    
    public class cls_message {
    }
    
    public class cls_CRMFetchResults {
        public cls_NewDataSet[] NewDataSet;
    }
    
    public class cls_NewDataSet {
        public cls_Table1[] Table1;
    }
    
    public class cls_Table1 {
        public String Applicationstatus;    //Documents Collected
        public String BranchName;   //2011
        public String LeadId;   //2474
        public String CustomerName; //ASFASFASF ASFASFAS
        public String CustomerMobileNumber; //9679679679
        public String LeadCreationDate; //08-01-2021 14:13:43
        public String ProductName;  //Home Construction
        public String BranchCode;   //Jaipur_Central Office_Mansarovar
        public String LoanAmount;   //324124124
    }
    
    public static List<LeadDedupeWrapper.LeadtoLeadWrapper> mapIntWraptoUIWrap(LeadtoLeadResponseWrapper objLeadtoLeadWrapper, Applicant__c objApplicant){
        List<LeadDedupeWrapper.LeadtoLeadWrapper> lstLeadtoLeadUIWrapperRet = new List<LeadDedupeWrapper.LeadtoLeadWrapper>();
        LeadDedupeWrapper.LeadtoLeadWrapper objLeadtoLeadWrapperRet;
        if(objLeadtoLeadWrapper != null && !objLeadtoLeadWrapper.CRMFetchResults.isEmpty() && !objLeadtoLeadWrapper.CRMFetchResults[0].NewDataSet.isEmpty()
            && !objLeadtoLeadWrapper.CRMFetchResults[0].NewDataSet[0].Table1.isEmpty()){
            for(cls_Table1 objTable : objLeadtoLeadWrapper.CRMFetchResults[0].NewDataSet[0].Table1){
                objLeadtoLeadWrapperRet = new LeadDedupeWrapper.LeadtoLeadWrapper();
                objLeadtoLeadWrapperRet.strApplicationstatus = objTable.Applicationstatus;
                objLeadtoLeadWrapperRet.strBranchName = objTable.BranchName;
                objLeadtoLeadWrapperRet.strLeadId = objTable.LeadId;
                objLeadtoLeadWrapperRet.strApplicationNumber = objTable.LeadId;
                objLeadtoLeadWrapperRet.strCustomerName = objTable.CustomerName;
                objLeadtoLeadWrapperRet.strCustomerMobileNumber = objTable.CustomerMobileNumber;
                objLeadtoLeadWrapperRet.strLeadCreationDate = objTable.LeadCreationDate;
                objLeadtoLeadWrapperRet.strProductName = objTable.ProductName;
                objLeadtoLeadWrapperRet.strBranchCode = objTable.BranchCode;
                objLeadtoLeadWrapperRet.strLoanAmount = objTable.LoanAmount;
                lstLeadtoLeadUIWrapperRet.add(objLeadtoLeadWrapperRet);
            }
        }
        return lstLeadtoLeadUIWrapperRet;
    }

}