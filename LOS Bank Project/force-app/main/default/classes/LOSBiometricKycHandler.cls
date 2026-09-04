public class LOSBiometricKycHandler implements IntegrationHandlerInterface{
    public List<String> generateRequest(Object reqParam){
        
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        //LOSAdharKycRequestWrapper losAdhar;
        List<String> result;
        if(String.valueOf(paramsMap.get('requestType')) =='Aadhaar - Biometric'){
            result = getBiometricReqBody(paramsMap);
        }
        return result;
        //return new List<String>{JSON.serialize(losAdhar,true)};
    }
    public static List<String> getBiometricReqBody(Map<String,Object> paramsMap){
        LOSBiometricKYCReqWrapper.headers generateWrap = new LOSBiometricKYCReqWrapper.headers();
        LOSBiometricKYCReqWrapper.request generateWrap2 = new LOSBiometricKYCReqWrapper.request();
        LOSBiometricKYCReqWrapper.Modalities modalities = new LOSBiometricKYCReqWrapper.Modalities();
        LOSBiometricKYCReqWrapper.Meta meta = new LOSBiometricKYCReqWrapper.Meta();
        LOSBiometricKYCReqWrapper.Pid pid = new LOSBiometricKYCReqWrapper.Pid();
        LOSBiometricKYCReqWrapper.Skey skey = new LOSBiometricKYCReqWrapper.Skey();
        
        system.debug('ss >'+String.valueOf(paramsMap.get('sub_client_code')));
        system.debug('ss>'+String.valueOf(paramsMap.get('function_sub_code')));
        generateWrap.sub_client_code = String.valueOf(paramsMap.get('sub_client_code'));
        generateWrap.actor_type = String.valueOf(paramsMap.get('actor_type'));
        generateWrap.channel = Label.LOSBiometricKycHandler_Channel;//String.valueOf(paramsMap.get('channel'));
        generateWrap.operation_mode = String.valueOf(paramsMap.get('operation_mode'));
        generateWrap.channel_code = String.valueOf(paramsMap.get('channel_code'));
        generateWrap.channel_version = String.valueOf(paramsMap.get('channel_version'));
        generateWrap.function_sub_code = String.valueOf(paramsMap.get('function_sub_code'));
        generateWrap.function_code = String.valueOf(paramsMap.get('function_code'));
        generateWrap.run_mode = String.valueOf(paramsMap.get('run_mode'));
        generateWrap.requestId = IntegrationUtility.getReferenceId();
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
        skey.value = String.valueOf(paramsMap.get('skeyValue'));
        //skey.value = '';
        
        modalities.pi  = String.valueOf(paramsMap.get('pi'));
        modalities.pa  = String.valueOf(paramsMap.get('pa'));
        modalities.pfa  = String.valueOf(paramsMap.get('pfa'));
        modalities.bio = String.valueOf(paramsMap.get('bio'));
        modalities.bt = String.valueOf(paramsMap.get('bt'));
        modalities.otp = String.valueOf(paramsMap.get('otp'));
        
        meta.rds_id = String.valueOf(paramsMap.get('rds_id'));
        meta.rds_ver = String.valueOf(paramsMap.get('rds_ver'));
        meta.dp_id = String.valueOf(paramsMap.get('dp_id'));
        meta.dc = String.valueOf(paramsMap.get('dc'));
        meta.mi = String.valueOf(paramsMap.get('mi'));
        meta.mc = String.valueOf(paramsMap.get('mc'));
        
        generateWrap2.modalities = modalities;
        generateWrap2.skey = skey;
        generateWrap2.pid = pid;
        generateWrap2.meta = meta;
        
        LOSBiometricKYCReqWrapper losAdhar = new LOSBiometricKYCReqWrapper();
        losAdhar.Headers = generateWrap;
        losAdhar.Request =generateWrap2;
        system.debug('losAdhar>>'+losAdhar);
        return new List<String>{JSON.serialize(losAdhar,true)};
            }
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
}