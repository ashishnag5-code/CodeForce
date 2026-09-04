public class LOSMobileOtpHandler implements IntegrationHandlerInterface{
    
    
    public Static List<String> generateRequest(Object reqParam){
        
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        String mobileNumber =  String.valueOf(paramsMap.get('mobileNumber'));
        String otp =  String.valueOf(paramsMap.get('otp'));
        String encrytionKey = String.valueOf(paramsMap.get('encryptionKey'));
        String iv = String.valueOf(paramsMap.get('iv'));
        generateOTPWrapper generateWrap;
        //validateOTPWrapper validateWrap;
        if(otp!=null){
            String ref =  String.valueOf(paramsMap.get('custRef')); //JUL31
            Blob body = IntegrationUtility.encryptData('AES256',Blob.valueOf(encrytionKey),Blob.valueOf(iv),Blob.valueOf(otp));
            generateWrap = new generateOTPWrapper(mobileNumber, '',EncodingUtil.base64Encode(body),'4','120','','',ref,'');
        }else{
            generateWrap = new generateOTPWrapper(mobileNumber, '0','','4','120','','','','');
        }
        //reWrap.mobile=mobileNumber;
        return new List<String>{JSON.serialize(generateWrap)};
            }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }    
    
    public class ResponseWrapper{
        public String requestStatus;
        public String statusCode;
        public String statusDesc;
        public String custRef;
    }
    
    public class generateOTPWrapper{
        public String mobile;
        public String otptype;
        public String otplength;
        public String otptimeout;
        public String msgContent;
        public String requestId;
        public String custRef;
        public String channel;
        public String otp;
        
        public generateOTPWrapper(String mobile, String otptype,String otp,String otplength,String otptimeout,
                                  String msgContent,String requestId,String custRef,String channel){
                                    String requestIntId = IntegrationUtility.getReferenceId(); //31JUL
                                      this.mobile = mobile;
                                      this.otptype = otptype;
                                      this.otp = otp;
                                      this.channel = Label.Mobile_Channel;
                                      //this.custRef = mobile;
                                      if(String.isNotBlank(custRef)){ //JUL31
                                        this.custRef = custRef;
                                      }else{
                                        this.custRef = requestIntId.replace('_','');
                                      }//END
                                      this.requestId = requestIntId;
                                      //this.msgContent = msgContent;
                                      //this.msgContent = 'Confirmation code for your Vehicle Loan application is {0}. Click here to view the T&Cs: https://www.aubank.in/general_tc_latest-general-terms-conditions.pdf .- AU Bank'; //added by Ashish on June 12
                                      this.msgContent = System.label.Otp_Message;
                                      this.otplength = otplength;
                                      this.otptimeout = otptimeout;
                                  }
        
    }
    
}