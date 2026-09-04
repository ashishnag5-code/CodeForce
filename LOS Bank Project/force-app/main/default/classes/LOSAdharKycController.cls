public class LOSAdharKycController {
    
    public static List<Display_Data__mdt> getMetadataRecord(String rType){
        List<Display_Data__mdt> dispData = [SELECT Id, DeveloperName, MasterLabel, Display_on_UI__c, JSON_Key__c, API_Name__c,Order__c
                                            FROM Display_Data__mdt 
                                            WHERE Type__c =: rType WITH SECURITY_ENFORCED 
                                            ORDER BY Order__c asc];
        return dispData;
    }

    @AuraEnabled
    public static string getAadhaarNum(String applicationId, String aadhaaarToken){
      //  String aadhaarNumberByToken = AadharTokenUtil.getAddharNumberViaToken(applicationId, aadhaaarToken);
      String response =  AadharTokenUtil.getAddharNumberViaToken(applicationId, aadhaaarToken);
      IntegrationUtility.ResponseWrapper wrapper = (IntegrationUtility.ResponseWrapper) JSON.deserialize(response,IntegrationUtility.ResponseWrapper.class);
   //   String aadhaarNumberByToken = wrapper.additionalResponse;

        return JSON.serialize(wrapper);         
    }

    @AuraEnabled 
    public static String adharKychMethod(String adharNumber,String applicationId,String masterRecordName, String transactionRefNo, String Otp) {
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(masterRecordName);
        LOSAdharKycInfoData adharData = new LOSAdharKycInfoData();
        String respBody;
        String requestBody;
        String aadhaarResp;

        system.debug('refNo--'+adharNumber);
      //  adharNumber = AadharTokenUtil.getAddharNumberViaToken(applicationId,'');
        String response =  AadharTokenUtil.getAddharNumberViaToken(applicationId,'');
        IntegrationUtility.ResponseWrapper wrapper = (IntegrationUtility.ResponseWrapper) JSON.deserialize(response,IntegrationUtility.ResponseWrapper.class);
        adharNumber = wrapper.additionalResponse;
        system.debug('adharNumber--'+adharNumber);
        LOSAdharKycHandler objHandler=new LOSAdharKycHandler();
        if(masterRecordName == 'Adhar - Generate OTP'){
            
            requestBody = objHandler.generateRequest(getReqBodyKeyValueMap(adharNumber,objIntMapper.Encryption_Key__c,objIntMapper.IV__c))[0];        
        }
        else if( masterRecordName =='Adhar - Validate OTP'){ 
            requestBody = objHandler.generateRequest(getValidateOtpReqBodyKeyValueMap(adharNumber,objIntMapper.Encryption_Key__c,objIntMapper.IV__c, transactionRefNo, Otp))[0];
        }
        system.debug('requestBody@@@'+requestBody);
       	 
         IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = 'POST';
        calloutRequestWrapper.masterRecord = objIntMapper;

        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicationId);
        calloutRequestWrapper.checklistRecord = checklistRecord;
          IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        
        HttpResponse res = new HttpResponse();
        res.setBody(respBody);
        res.setStatusCode(200);
        LOSAdharKycResponseWrapper parseData = LOSAdharKycResponseWrapper.parse(res.getBody());
        system.debug('parseData>>'+parseData.response_data);
        system.debug('status>>'+parseData.response_status);
        system.debug('respBody>>'+respBody);

        UIResponse respObj = new UIResponse();
        String respStatus = parseData.response_status.status;

        if(respStatus  =='SUCCESS' && masterRecordName =='Adhar - Validate OTP'){
            Blob resValue = EncodingUtil.base64Decode(parseData.response_data.data);
            system.debug('resValue>>'+resValue.toString());
            Dom.Document doc = new Dom.Document();
            doc.load(resValue.toString());
            dom.XmlNode root= doc.getRootElement();
            list<Dom.XmlNode> childs = root.getChildElements();
            adhardata.status = parseData.response_status.status;
            for(Dom.XmlNode c:childs){
                if(c.getName()=='UidData'){
                    adhardata.tkn = c.getAttribute('tkn', null);
                    adhardata.uid = c.getAttribute('uid', null);
                    system.debug('att '+ c.getAttribute('tkn', null) +'uad '+c.getAttribute('uid', null));
   
                    for(Dom.XmlNode ch:c.getChildElements()){
                        system.debug('in inner for lop>> '+ch.getName());
                        if(ch.getName()=='Poi'){
                            system.debug('dob '+ ch.getAttribute('dob', null) +' gender '+ch.getAttribute('gender', null) +' name '+ch.getAttribute('name', null));
                            adhardata.dob = ch.getAttribute('dob', null);
                            adhardata.gender = ch.getAttribute('gender', null);
                            adhardata.name = ch.getAttribute('name', null);
   
                        }else if(ch.getName()=='Poa'){
                            //co co="D/O Rajendra Adhal" country="India" dist="Yavatmal" loc="Chintamani Nagar Waad - 6" pc="445401" state="Maharashtra" vtc="Kalamb"
                            system.debug('co '+ ch.getAttribute('co', null) +' country '+ch.getAttribute('country', null) +' dist '+ch.getAttribute('dist', null) + ' loc '+ch.getAttribute('loc', null) + ' state '+ch.getAttribute('state', null) + ' vtc '+ch.getAttribute('vtc', null));
                            adhardata.co = ch.getAttribute('co', null);
                            adhardata.country = ch.getAttribute('country', null);
                            adhardata.dist = ch.getAttribute('dist', null);
                            adhardata.state = ch.getAttribute('state', null);
                            adhardata.vtc = ch.getAttribute('vtc', null);
                            adhardata.pc = ch.getAttribute('pc', null);
                            adhardata.house = ch.getAttribute('house', null);
                            adhardata.loc = ch.getAttribute('loc', null);
                            adhardata.street = ch.getAttribute('street', null);
                            adhardata.lm = ch.getAttribute('lm', null);
                        }else if(ch.getName()=='Pht'){
                           adhardata.aadhaarimage=ch.getText(); 
                        }
                    }
                } 
            }
            respBody = JSON.serialize(adhardata);          
            respObj.Response   = adhardata;
            respObj.metadata   = new List<Sobject>();
            respObj.metadata   = getMetadataRecord('Aadhaar');
            respObj.status     = adhardata.status;
            respBody           =  JSON.serialize(respObj);
        }else if(respStatus  !='SUCCESS' && masterRecordName == 'Adhar - Validate OTP') {       
            GenerateRespWrapper genResWrapObj = GenerateRespWrapper.parse(respBody);
            respObj.status = genResWrapObj.response_status.status;
            respObj.message = genResWrapObj.response_status.message;
            respBody = JSON.serialize(respObj);
        }
        system.debug('respObj is >>'+JSON.serialize(respObj));
        LOSBiometricKycController.createAddharImage(adhardata.aadhaarimage,applicationId);
        IntegrationUtility.updateIntegrationChecklist('',respBody,res.getStatusCode(),objIntMapper.Id,requestBody);

        system.debug('respBody is >>'+JSON.serialize(respBody));
        return respBody;        
    }
    
    public class UIResponse{  
          @AuraEnabled public LOSAdharKycInfoData Response;
          @AuraEnabled public List<Sobject> metadata;
          @AuraEnabled public String status;
          @AuraEnabled public String message;
    }
   
    public static Map<String,Object> getReqBodyKeyValueMap(String adharNumber,String encryptionKey,String iv){
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('requestType','Adhar - Generate OTP');
        paramMap.put('encryptionKey',encryptionKey);
        paramMap.put('iv',iv);
        paramMap.put('sub_client_code','AUBANK121');
        paramMap.put('actor_type','CUSTOMER');
        paramMap.put('channel',Label.LOSAdharKycController_Channel );
        paramMap.put('operation_mode','ASSISTED');
        paramMap.put('channel_code','MOBILE_APP');
        paramMap.put('channel_version','0.0.1');
        paramMap.put('function_sub_code','GENERATE_OTP');
        paramMap.put('function_code','EKYC');
        paramMap.put('run_mode','REAL');
        paramMap.put('requestId',IntegrationUtility.getReferenceId());
        paramMap.put('stan',IntegrationUtility.getReferenceId());
        paramMap.put('user_handle_value',adharNumber);
        paramMap.put('client_ip','');
        paramMap.put('location','LOCATION');
        paramMap.put('user_handle_type','AADHAAR');
        paramMap.put('client_code','AUBANK121');
        paramMap.put('transmission_datetime','1635854672');
        paramMap.put('notification_channel','');
        paramMap.put('client_ref_number',IntegrationUtility.getReferenceId());
        paramMap.put('uid',adharNumber);
        paramMap.put('environment','PREPROD');
        paramMap.put('purpose','GENERATING AADHAAR OTP');
        paramMap.put('remark','For generating OTP');
        paramMap.put('consent','Y');
        paramMap.put('transaction_ref_number','');
        return paramMap;
    }
   
    public static Map<String,Object> getValidateOtpReqBodyKeyValueMap(String adharNumber,String encryptionKey,String iv, String transactionRefNo, String Otp){
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('requestType','Adhar - Validate OTP');
        paramMap.put('encryptionKey',encryptionKey);
        paramMap.put('iv',iv);
        paramMap.put('channel', Label.LOSAdharKycController_Channel);
        paramMap.put('requestId ',IntegrationUtility.getReferenceId());
        paramMap.put('client_code','AUBANK121');
        paramMap.put('sub_client_code','AUBANK121');
        paramMap.put('channel_code','MOBILE_APP');
        paramMap.put('channel_version','0.0.1');
        paramMap.put('stan',IntegrationUtility.getReferenceId());
        paramMap.put('client_ip','');
        paramMap.put('transmission_datetime','1635854672');
        paramMap.put('operation_mode','ASSISTED');
        paramMap.put('run_mode','REAL');
        paramMap.put('actor_type','CUSTOMER');
        paramMap.put('user_handle_type','AADHAAR');
        paramMap.put('user_handle_value',adharNumber);
        paramMap.put('location','LOCATION');
        paramMap.put('function_code','EKYC');
        paramMap.put('function_sub_code','DEFAULT');
        
        paramMap.put('notification_channel','NA');
        paramMap.put('client_ref_number',IntegrationUtility.getReferenceId());
        paramMap.put('transaction_ref_number', transactionRefNo);
        paramMap.put('remark','For generating OTP');
        paramMap.put('environment','PREPROD');
        paramMap.put('purpose','VALIDATING AADHAAR OTP');
        paramMap.put('consent','Y');
        paramMap.put('hmac','imwAdejIq8rxWbDy+RRy7X2DfVwMV5wRaK+hyyfBYAQaEiPpzLBafJiOxhxyi+oH');
        paramMap.put('uid',adharNumber);
        paramMap.put('pdf','');
        paramMap.put('lr','');
        
        paramMap.put('ci','20221023');
        paramMap.put('value','U0elC2+l3wxcO0I4aXJygOpigsnuro8uepAzTW1k149F/eFXodqIlNJVXJhnEAYRdYc5QJtoDcVaFw1WIbZzoP51LSYnLr8DA4BWvujm30nADWcB9Lf6rzRSSbURsNSumz+gWGxJsKgYdKxL+mpdBR+NNIXGhFduN44bv4aFCgH8ZZhEZ+aotn3zQv4xDrfCI6VPpnUMBkWVxC/JqR0dljAtA+pzqd9YtZteGTBlqfOjeSVMJLQmMDQbgcuJrx84PnEGzQzmVpEujdwra53h5cvVvSOC4klsa9REuospIVNF/Dts1x7Y3Tk68Q2U0hshiCVmp47kYXsW6+A9ARhkzw==');
        
        paramMap.put('type','X');
        paramMap.put('value',Otp);
        
        paramMap.put('pi','n');
        paramMap.put('pa','n');
        paramMap.put('pfa','n');
        paramMap.put('bio','n');
        paramMap.put('bt','');
        paramMap.put('otp','y');
        return paramMap;
    }
}