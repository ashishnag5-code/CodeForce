public class EMandateRegistrationRequestWrapper {
    public String mbSvcProviderName;
	public String channel;
	public String mbDateFrom;
    public String callBackURL;
	public String mbCustMailId;
	public String mbCustFonCellNum;
	public String mbSvcProviderCode;
	public String mbSponserBankCode;
	public String mbFrequencyType;
	public String requestId;
	public String mbCustName;
	public String mbRefNumber;
	public String mbMandateCategory;
	public String mbDRAccountNumber;
	public String mbMandateType;
	public String mbDateTo;
	public String mbRelRefNumber;
	public String mbCustFonLandNum;
	public String mbDRBankCode;
	public String mbAmount;
	public String mbPaymentType;
	public String responseURL;
	public String mbDRAccountType;
	public String mbFrequencyCode;
	public String mbFixedAmount;
	public String referenceCode;
	public String mbCustPAN;
	public String username;
    
    public EMandateEnquiry eMandateEnquiry;
    public class EMandateEnquiry{
        public String RequestId;
        public String Channel;
        public String ReferenceCode;
        public EMandateEnquiry(){
            RequestId = '';
            Channel = '';
            ReferenceCode = '';
        }
        
    }
    
}