/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @TestClass         : LOSBiometricKycControllerTest
 * @group             : 
 * @last modified on  : 02-14-2023
 * @last modified by  : Harshit Goyal | Salesforce
 * Modified Date        -   Modified By             -   Comments
 * 01-Aug-2023          -   Mohit M.                -   Add Custom Labels
**/
public class LOSBiometricKycController {
    
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param adharNumber 
    * @param loanApplicationId 
    * @param msterRecordName 
    * @param bioMetricDataMap 
    * @return String 
    **/
    @AuraEnabled 
    public static String biometricKychMethod(String adharNumber,String loanApplicationId,String msterRecordName,Map<String,String> bioMetricDataMap){
        try
        {
            Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
            system.debug('objIntMapper'+objIntMapper);
            LOSBiometricInfoData adharData = new LOSBiometricInfoData();
            String respBody;
            String requestBody;
            LOSBiometricKycHandler objHandler=new LOSBiometricKycHandler(); 
            
            
            if( msterRecordName == GlobalConstants.AADHAAR_BIO_SERVICE){
                requestBody = objHandler.generateRequest(getBiometricReqBodyKeyValueMap(adharNumber,objIntMapper.Encryption_Key__c,objIntMapper.IV__c,bioMetricDataMap))[0];
            }
            system.debug('requestBody@@@'+requestBody);
            
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = 'POST';
            calloutRequestWrapper.masterRecord = objIntMapper;
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = loanApplicationId);
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            // Uncomment below line for actual response.
            respBody = calloutResponseWrapper.response;
            system.debug('respBodyFinal'+respBody);
            return respBody;
        }catch(Exception objException){
            system.debug('Exception line '+objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf('High'),loanApplicationId);
            return null;
        }
    }  
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param adharNumber 
    * @param encryptionKey 
    * @param iv 
    * @param bioMetricDataMap 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getBiometricReqBodyKeyValueMap(String adharNumber,String encryptionKey,String iv,Map<String,String> bioMetricDataMap){
        system.debug('adharNumber'+adharNumber);
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('requestType',GlobalConstants.AADHAAR_BIO_SERVICE);
        paramMap.put('encryptionKey',encryptionKey);
        paramMap.put('iv',iv);
        paramMap.put('channel',Label.Biometric_Channel);
        paramMap.put('requestId',IntegrationUtility.getReferenceId());
        paramMap.put('client_code',Label.Biometric_Client_Code);
        paramMap.put('sub_client_code',Label.Biometric_Sub_Client_Code);
        paramMap.put('channel_code',Label.Biometric_Channel_Code);
        paramMap.put('channel_version',Label.Biometric_Channel_Version);
        paramMap.put('stan',IntegrationUtility.getReferenceId());
        paramMap.put('client_ip','');
        paramMap.put('transmission_datetime',Label.Biometric_Transition_DateTime);
        paramMap.put('operation_mode',Label.Biometric_Operation_Mode);
        paramMap.put('run_mode',Label.Biometric_Run_Code);
        paramMap.put('actor_type',Label.Biometric_Actor_Type);
        paramMap.put('user_handle_type',Label.Biometric_User_Handle_Type);
        paramMap.put('user_handle_value',adharNumber);
        paramMap.put('location',Label.Biometric_Location);
        paramMap.put('function_code',Label.Biometric_Function_Code);
        paramMap.put('function_sub_code',Label.Biometric_Function_Sub_Code);
        paramMap.put('notification_channel',Label.Biometric_Notification_Channel);
        paramMap.put('client_ref_number',IntegrationUtility.getReferenceId());
        paramMap.put('transaction_ref_number','');
        paramMap.put('remark',Label.Biometric_Remark);
        paramMap.put('environment',Label.Biometric_Environment);
        paramMap.put('purpose',Label.Biometric_Purpose);
        paramMap.put('consent',Label.Biometric_Consent);
        paramMap.put('hmac',bioMetricDataMap.get('hmac'));
        paramMap.put('uid',adharNumber);
        paramMap.put('pdf','');
        paramMap.put('lr','');
        
        paramMap.put('ci',bioMetricDataMap.get('skeyCI'));
        paramMap.put('skeyValue',bioMetricDataMap.get('skeyValue'));
        
        paramMap.put('type', bioMetricDataMap.get('dataType'));
        paramMap.put('value',bioMetricDataMap.get('dataValue'));
        
        paramMap.put('pi',Label.Biometric_PI_Value);
        paramMap.put('pa',Label.Biometric_PA_Value);
        paramMap.put('pfa',Label.Biometric_PFA_Value);
        paramMap.put('bio',Label.Biometric_Bio_Value);
        paramMap.put('bt',Label.Biometric_bt_value); // FMR | FIR- This is invalid value
        paramMap.put('otp',Label.Biometric_OTP_Value);
        
        paramMap.put('rds_id',bioMetricDataMap.get('rds_id'));
        paramMap.put('rds_ver',bioMetricDataMap.get('rds_ver'));
        paramMap.put('dp_id',bioMetricDataMap.get('dp_id'));
        paramMap.put('dc',bioMetricDataMap.get('dc'));
        paramMap.put('mi',bioMetricDataMap.get('mi'));
        paramMap.put('mc',bioMetricDataMap.get('mc'));
        
        system.debug('paramMap'+paramMap);
        system.debug('ss####123>'+paramMap.get('function_sub_code'));
        system.debug('ss####456>'+String.valueOf(paramMap.get('function_sub_code')));
        return paramMap;
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param respBody 
    * @return LOSBiometricInfoData 
    **/
    public static LOSBiometricInfoData parseResponseXML(String respBody){
        LOSBiometricKycResponseWrapper parseData = LOSBiometricKycResponseWrapper.parse(respBody);
        LOSBiometricInfoData adharData = new LOSBiometricInfoData();
        if(parseData?.response_status?.status  =='SUCCESS'){
            Blob xmlResponseData = EncodingUtil.base64Decode(parseData.response_data.data);
            system.debug('resValue>>'+xmlResponseData.toString());
            Dom.Document doc = new Dom.Document();  
            doc.load(xmlResponseData.toString());  
            dom.XmlNode root= doc.getRootElement();

            list<Dom.XmlNode> childs = root.getChildElements();
            adhardata.status = parseData.response_status.status;
            adhardata.message = parseData.response_status.message;
            for(Dom.XmlNode c:childs){
                if(c.getName()=='UidData'){
                    adhardata.tkn = c.getAttribute('tkn', null);
                    //adhardata.uid = c.getAttribute('uid', null);
                    //system.debug('att '+ c.getAttribute('tkn', null) +'uad '+c.getAttribute('uid', null));
                    //system.debug('name is '+c.getName() +'text is '+c.getText());
                    for(Dom.XmlNode ch:c.getChildElements()){
                        //system.debug('in inner for lop>> '+ch.getName());
                        if(ch.getName()=='Poi'){
                            //system.debug('dob '+ ch.getAttribute('dob', null) +' gender '+ch.getAttribute('gender', null) +' name '+ch.getAttribute('name', null));
                            adhardata.dob = ch.getAttribute('dob', null);
                            adhardata.gender = ch.getAttribute('gender', null);
                            adhardata.name = ch.getAttribute('name', null);
                            //system.debug('name is '+c.getName() +'text is '+c.getText());
                        }else if(ch.getName()=='Poa'){
                            //co co="D/O Rajendra Adhal" country="India" dist="Yavatmal" loc="Chintamani Nagar Waad - 6" pc="445401" state="Maharashtra" vtc="Kalamb"
                            //system.debug('co '+ ch.getAttribute('co', null) +' country '+ch.getAttribute('country', null) +' dist '+ch.getAttribute('dist', null) + ' loc '+ch.getAttribute('loc', null) + ' state '+ch.getAttribute('state', null) + ' vtc '+ch.getAttribute('vtc', null));
                            adhardata.co = ch.getAttribute('co', null);
                            adhardata.country = ch.getAttribute('country', null);
                            adhardata.dist = ch.getAttribute('dist', null);
                            adhardata.loc = ch.getAttribute('loc', null);
                            adhardata.state = ch.getAttribute('state', null);
                            adhardata.vtc = ch.getAttribute('vtc', null);
                            adharData.pc = ch.getAttribute('pc', null);
                            adharData.house = ch.getAttribute('house', null);
                            adharData.street = ch.getAttribute('street', null);
                            adharData.lm = ch.getAttribute('lm', null);
                        }else if(ch.getName()=='Pht'){
                            adhardata.aadhaarimage=ch.getText();
                        }
                    }
                } 
            }
            system.debug('adhardataJSON'+JSON.serialize(adhardata) );
            return adharData;
        }else{
            adharData.status = 'FAIL';
            adharData.message = parseData?.response_status?.message;
            return adharData;
        }
    }

    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param recordId 
    * @return String 
    **/
    @AuraEnabled
    public static String getApplicantDetails(String recordId){
        try
        {
            system.debug('recordId'+recordId);
            String msterRecordName = GlobalConstants.AADHAAR_BIO_SERVICE;
            Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
            List<Integration_Checklist__c> checkList =  [SELECT Id,Response__c from Integration_Checklist__c WHERE Applicant__c = :recordId AND is_Latest__c = true
                                                         AND Integration_Master__c = :objIntMapper.Id WITH SECURITY_ENFORCED Order by CreatedDate DESC];
                                                         
            LOSBiometricInfoData wrapData = parseResponseXML(checkList[0]?.Response__c);
            createAddharImage(wrapData.aadhaarimage,recordId);
            return JSON.serialize(wrapData);
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf('High'),recordId);
            LOSBiometricInfoData adharData = new LOSBiometricInfoData();
            adharData.status = 'FAIL';
            adharData.message = 'Something went wrong, please try after sometime.';
            return JSON.serialize(adharData);
        }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param applicant 
    * @param address 
    * @return String 
    **/
    @AuraEnabled
    public static String updateRecords(String applicant, String address, String dob){
        try{
            SObjectAccessDecision decision;
            
            Map<String, Object> applicantDetails = (Map<String, Object>) JSON.deserializeUntyped( applicant  );
            Map<String, Object> applicantDetails2 = applicantDetails;
    
            for(String key : applicantDetails.keySet()){
              if(applicantDetails.get(key) == null || String.isBlank( String.valueOf(applicantDetails.get(key)) )){
                applicantDetails2.remove(key);
              }
            }

            Applicant__c app = (Applicant__c)JSON.deserialize(JSON.serialize(applicantDetails2), Applicant__c.class);
            app.KYC_Status__c ='Complete';
            app.KYC_Type__c = 'Aadhaar - Biometric';
            
            app.Dob__c = String.isNotBlank(dob) ? Date.parse(dob) : null;
            System.debug('applicant: '+app);
            
            if(Schema.sObjectType.Applicant__c.isUpdateable() && Schema.sObjectType.Applicant__c.isCreateable()){
                upsert app;
            }
            List<Address__c> lstAddress = [Select Id, Applicant__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Source__c, Address_Type__c, City__c, District__c, Land_mark__c, Pincode__c, State__c from Address__c where Address_Type__c = 'Permanent' and Applicant__c =: app.Id ];
       
            System.debug('address: '+address);
            Address__c add = (Address__c)JSON.deserialize(address, Address__c.class);
            add.Address_Source__c = 'Aadhaar Card';
            if(!lstAddress.isEmpty()){
                add.Id = lstAddress[0].Id;
            }
            System.debug('address: '+add);
            
            if(add.Source_Type__c==null && add.Address_Type__c!=null && add.Pincode__c!=null){
                List<Location_Master__c> negativeAreaMasterRecords = [Select Id, Zip_Code__c, Area_Status__c, Working_Area__c FROM Location_Master__c WHERE Zip_Code__c=: add.Pincode__c AND Area_Name__c=:add.Area_Name__c];
                
                if(negativeAreaMasterRecords!=null && negativeAreaMasterRecords.size()>0){
                    if(negativeAreaMasterRecords[0].Working_Area__c.equalsIgnoreCase('Yes')){
                        add.Geo_Limit__c = 'Acceptable';
                    }
                    if(negativeAreaMasterRecords[0].Working_Area__c.equalsIgnoreCase('No')){
                        add.Geo_Limit__c = 'Not Acceptable';
                    }
                    if(negativeAreaMasterRecords[0].Area_Status__c.equalsIgnoreCase('Positive')){
                        add.Negative_Area_Status__c = 'Positive';
                        //app.Negative_Area_Status__c='Posititve';
                    }
                    if(negativeAreaMasterRecords[0].Area_Status__c.equalsIgnoreCase('Negative')){
                        add.Negative_Area_Status__c = 'Negative';
                        //app.Negative_Area_Status__c='Negative';
                    }
                } 
            }
            
            upsert add;
            
            System.debug('applicant: '+app);
            System.debug('address: '+add.Id);
            
            List<Document_Checklist__c> docChckLst = getDocumentCheckList(app, 'Aadhaar Card');
            if(docChckLst.size() > 0) {
                docChckLst[0].Document_Verification_Status__c = 'Verified';
                if (Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
                    DatabaseUtility.updateRecords(docChckLst, 'Document_Checklist__c');
                }
            }
            
            
            
            
            return 'Success';
        }catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }
    
    public static List<Document_Checklist__c> getDocumentCheckList(Applicant__c app, String docmasterName) {
        List<Document_Checklist__c> docCheckLst = [SELECT Id, Document_Verification_Status__c
                                                   FROM Document_Checklist__c where (Applicant__c =: app.Id and Document_Master__r.Document_Name__c =: docmasterName)  WITH SECURITY_ENFORCED];
        
        return docCheckLst;
    }
    
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-31-2023 
    * @param addharImage 
    * @param applicantId 
    **/
    public static void createAddharImage(String addharImage, String applicantId){
        try
        {
            List<Document_Checklist__c> docList = [SELECT Id FROM Document_Checklist__c 
                                                    WHERE Applicant__c =:applicantId AND Document_Master__r.Name=:Label.DcumentMasterAadharPicture WITH SECURITY_ENFORCED];
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(addharImage);
            cv.Title = 'Aadhar Image';
            cv.PathOnClient = 'Aadhar Image'+'.png';
            if(Schema.sObjectType.ContentVersion.isCreateable()){
            insert cv;
            }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: cv.Id
            ].ContentDocumentId;
            cdl.LinkedEntityId = docList[0].Id;
            cdl.ShareType = 'V';
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
            insert cdl;
            }
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf('High'),applicantId);
        }
    }
}