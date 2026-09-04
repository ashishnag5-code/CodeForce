public class EMandateRegistrationResponseWrapper {
    @AuraEnabled public String Status;
	@AuraEnabled public String Description;
	@AuraEnabled public String Code;
    @AuraEnabled public String ResponseCode;
   	@AuraEnabled public String ResponseMessage;
    @AuraEnabled public String Messgae;
    @AuraEnabled public String referenceId;
    @AuraEnabled public EMandateEnquiryResponseWrapper eMandateEnquiryResponseWrapper;
    public class EMandateEnquiryResponseWrapper{
       	@AuraEnabled public String MndtReqId;
        @AuraEnabled public String RejectBy;
        @AuraEnabled public String ReasonDesc;
        @AuraEnabled public String MerchantID;
        @AuraEnabled public String NpciRefMsgID;
        @AuraEnabled public String ReasonCode;
        @AuraEnabled public String MndtId;
        @AuraEnabled public String CycleDate;
        @AuraEnabled public String Accptd;
        @AuraEnabled public String ErrorDesc;
        @AuraEnabled public String ReferenceCode;
        @AuraEnabled public String ErrorCode;
        @AuraEnabled public String ReqInitDate;
        @AuraEnabled public String AccptRefNo;
        public EMandateEnquiryResponseWrapper(){
            MndtReqId = '';
            RejectBy = '';
            ReasonDesc = '';
            MerchantID = '';
            NpciRefMsgID = '';
            ReasonCode = '';
            MndtId = '';
            CycleDate = '';
            Accptd = '';
            ErrorDesc = '';
            ReferenceCode = '';
            ErrorCode = '';
            ReqInitDate = '';
            AccptRefNo = '';
            
        }
    }
}