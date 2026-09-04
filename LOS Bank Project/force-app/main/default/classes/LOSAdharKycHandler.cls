public class LOSAdharKycHandler implements IntegrationHandlerInterface{
    
    public List<String> generateRequest(Object reqParam){
        
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        //LOSAdharKycRequestWrapper losAdhar;
        List<String> result;
        if(String.valueOf(paramsMap.get('requestType')) == 'Adhar - Generate OTP' || String.valueOf(paramsMap.get('requestType')) == 'Mobile Resend OTP'){
            result = getGenerateOtpReqBody(paramsMap);
        }else if(String.valueOf(paramsMap.get('requestType')) =='Adhar - Validate OTP'){
            result = getValidateOtpReqBody(paramsMap);
        }
        return result;
        //return new List<String>{JSON.serialize(losAdhar,true)};
            }
    
    public static List<String> getGenerateOtpReqBody(Map<String,Object> paramsMap){
       
        LOSAdharKycRequestWrapper.headers generateWrap = new LOSAdharKycRequestWrapper.headers();
        LOSAdharKycRequestWrapper.request generateWrap2 = new LOSAdharKycRequestWrapper.request();
        system.debug('ss >'+String.valueOf(paramsMap.get('sub_client_code')));
        generateWrap.sub_client_code = String.valueOf(paramsMap.get('sub_client_code'));
        generateWrap.actor_type = String.valueOf(paramsMap.get('actor_type'));
        generateWrap.channel = String.valueOf(paramsMap.get('channel'));
        generateWrap.operation_mode = String.valueOf(paramsMap.get('operation_mode'));
        generateWrap.channel_code = String.valueOf(paramsMap.get('channel_code'));
        generateWrap.channel_version = String.valueOf(paramsMap.get('channel_version'));
        generateWrap.function_sub_code = String.valueOf(paramsMap.get('function_sub_code'));
        generateWrap.function_code = String.valueOf(paramsMap.get('function_code'));
        generateWrap.run_mode = String.valueOf(paramsMap.get('run_mode'));
        generateWrap.requestId = String.valueOf(paramsMap.get('sub_client_code'));
        generateWrap.stan = String.valueOf(paramsMap.get('stan'));
        generateWrap.user_handle_value = String.valueOf(paramsMap.get('user_handle_value'));
        generateWrap.client_ip = String.valueOf(paramsMap.get('client_ip'));  
        generateWrap.location  = String.valueOf(paramsMap.get('location'));
        generateWrap.user_handle_type  = String.valueOf(paramsMap.get('user_handle_type'));
        generateWrap.client_code  = String.valueOf(paramsMap.get('client_code'));
        generateWrap.transmission_datetime  = String.valueOf(paramsMap.get('transmission_datetime'));
        
        generateWrap2.notification_channel  = String.valueOf(paramsMap.get('notification_channel'));
        generateWrap2.client_ref_number  = String.valueOf(paramsMap.get('client_ref_number'));
        generateWrap2.environment  = String.valueOf(paramsMap.get('environment'));
        generateWrap2.purpose  = String.valueOf(paramsMap.get('purpose'));
        generateWrap2.remark  = String.valueOf(paramsMap.get('remark'));
        generateWrap2.consent  = String.valueOf(paramsMap.get('consent'));
        generateWrap2.transaction_ref_number  = String.valueOf(paramsMap.get('transaction_ref_number'));
        generateWrap2.uid = String.valueOf(paramsMap.get('uid'));
        LOSAdharKycRequestWrapper losAdhar = new LOSAdharKycRequestWrapper();
        losAdhar.Headers = generateWrap;
        losAdhar.Request =generateWrap2;
        system.debug('losAdhar>>'+losAdhar);
        return new List<String>{JSON.serialize(losAdhar,true)};
    }
    public static List<String> getValidateOtpReqBody(Map<String,Object> paramsMap){
        LOSAdhaKycValidateOtpReqWrapper.headers generateWrap = new LOSAdhaKycValidateOtpReqWrapper.headers();
        LOSAdhaKycValidateOtpReqWrapper.request generateWrap2 = new LOSAdhaKycValidateOtpReqWrapper.request();
        LOSAdhaKycValidateOtpReqWrapper.Modalities modalities = new LOSAdhaKycValidateOtpReqWrapper.Modalities();
        LOSAdhaKycValidateOtpReqWrapper.Pid pid = new LOSAdhaKycValidateOtpReqWrapper.Pid();
        LOSAdhaKycValidateOtpReqWrapper.Skey skey = new LOSAdhaKycValidateOtpReqWrapper.Skey();
        
        system.debug('ss >'+String.valueOf(paramsMap.get('sub_client_code')));
        generateWrap.sub_client_code = String.valueOf(paramsMap.get('sub_client_code'));
        generateWrap.actor_type = String.valueOf(paramsMap.get('actor_type'));
        generateWrap.channel = 'SFDC';//String.valueOf(paramsMap.get('channel'));
        generateWrap.operation_mode = String.valueOf(paramsMap.get('operation_mode'));
        generateWrap.channel_code = String.valueOf(paramsMap.get('channel_code'));
        generateWrap.channel_version = String.valueOf(paramsMap.get('channel_version'));
        generateWrap.function_sub_code = String.valueOf(paramsMap.get('function_sub_code'));
        generateWrap.function_code = String.valueOf(paramsMap.get('function_code'));
        generateWrap.run_mode = String.valueOf(paramsMap.get('run_mode'));
        generateWrap.requestId = IntegrationUtility.getReferenceId();//String.valueOf(paramsMap.get('sub_client_code'));
        generateWrap.stan = String.valueOf(paramsMap.get('stan'));
        generateWrap.user_handle_value = String.valueOf(paramsMap.get('user_handle_value'));
        generateWrap.client_ip = String.valueOf(paramsMap.get('client_ip'));  
        generateWrap.location  = String.valueOf(paramsMap.get('location'));
        generateWrap.user_handle_type  = String.valueOf(paramsMap.get('user_handle_type'));
        generateWrap.client_code  = String.valueOf(paramsMap.get('client_code'));
        generateWrap.transmission_datetime  = String.valueOf(paramsMap.get('transmission_datetime'));
        
        generateWrap2.notification_channel  = String.valueOf(paramsMap.get('notification_channel'));
        generateWrap2.client_ref_number  = String.valueOf(paramsMap.get('client_ref_number'));
        generateWrap2.environment  = String.valueOf(paramsMap.get('environment'));
        generateWrap2.purpose  = String.valueOf(paramsMap.get('purpose'));
        generateWrap2.remark  = String.valueOf(paramsMap.get('remark'));
        generateWrap2.consent  = String.valueOf(paramsMap.get('consent'));
        generateWrap2.transaction_ref_number  = String.valueOf(paramsMap.get('transaction_ref_number'));
        generateWrap2.uid = String.valueOf(paramsMap.get('uid'));
        generateWrap2.hmac = String.valueOf(paramsMap.get('hmac'));
        
        generateWrap2.remark  = String.valueOf(paramsMap.get('remark'));
        generateWrap2.consent  = String.valueOf(paramsMap.get('consent'));
        generateWrap2.transaction_ref_number  = String.valueOf(paramsMap.get('transaction_ref_number'));
        generateWrap2.uid = String.valueOf(paramsMap.get('uid'));
        
        pid.type  = String.valueOf(paramsMap.get('type'));
        pid.value  = String.valueOf(paramsMap.get('value'));
        
       	skey.ci  = String.valueOf(paramsMap.get('ci'));
        skey.value = String.valueOf(paramsMap.get('value'));
        
        modalities.pi  = String.valueOf(paramsMap.get('pi'));
        modalities.pa  = String.valueOf(paramsMap.get('pa'));
        modalities.pfa  = String.valueOf(paramsMap.get('pfa'));
        modalities.bio = String.valueOf(paramsMap.get('bio'));
        modalities.bt = String.valueOf(paramsMap.get('bt'));
        modalities.otp = String.valueOf(paramsMap.get('otp'));
        
        generateWrap2.modalities = modalities;
        generateWrap2.skey = skey;
        generateWrap2.pid = pid;
        
        LOSAdhaKycValidateOtpReqWrapper losAdhar = new LOSAdhaKycValidateOtpReqWrapper();
        losAdhar.Headers = generateWrap;
        losAdhar.Request =generateWrap2;
        system.debug('losAdhar>>'+losAdhar);
        return new List<String>{JSON.serialize(losAdhar,true)};
    }
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
}