/*****
 * Class Name: AUSFDocumentVerificationController
 * Description: 
 * Test Class Name: AUSFDocumentVerificationControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-27-2023          -   Mohit M.            -   remove dob from static value
 */
public class AUSFDocumentVerificationController {

    @AuraEnabled
    public static List<Document_Checklist__c> getDetails(Id applicantId){
        
        List<Document_Checklist__c> docChecklist = [SELECT Id,Applicant__c,Applicant__r.Dob__c, Document_Expiry_Date__c,Api_Response__c,Retry_Count__c,//Added Retry Count Field || START || 20 SEP || ASHISH
                Document_Number__c,Document_Verification_Status__c,Passport_File_Number__c,Document_Master__r.Document_Name__c
                FROM Document_Checklist__c Where Applicant__c=: applicantId  AND Document_Number__c !=null
                AND Document_Master__r.Document_Name__c in ('Voter id Card','Driving Licence','Passport','GST Document', 'Udyam Document', 'CIN Document')];
        return docChecklist;
    }

    @AuraEnabled
    public static List<Applicant__c> getLoanDetails(Id applicantId){
        
        List<Applicant__c> loanApp = [SELECT Id,loan__r.RecordType.Name
                FROM Applicant__c Where Id=: applicantId];
        return loanApp;
    }
    
    @AuraEnabled
    public static String verifyVoterId(String voterId,String objectId,String msterRecordName) {
        IntegrationUtility.ResponseWrapper calloutResponse = getVoterCardResponse(voterId,msterRecordName,'','','',objectId);
        AUSFVoterResponseWrapper.UIResponse resp = new AUSFVoterResponseWrapper.UIResponse();
        AUSFVoterResponseWrapper wrapper = new AUSFVoterResponseWrapper();
        Object[] metadata;
        if(calloutResponse.statusCode==200){
            wrapper = AUSFVoterResponseWrapper.parse(calloutResponse.response);        
            resp.Response = wrapper.result;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = getMetadataRecord('VoterId');
        }else{
            resp.Response = wrapper.result;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = metadata;
            resp.errorMessage = Utility.getApiCustomError(
                calloutResponse.checklistNumber,
                calloutResponse.response,
                'Unexpected response recieved',
                calloutResponse.statusCode,
                'AUSFDocumentVerificationController.verifyDL'
            );
        }
        system.debug('return Response: '+resp.Response);
        system.debug('return metadata: '+resp.metadata);
        return JSON.serialize(resp);
    }
    
    @AuraEnabled
    public static String updateDocumentChecklist(Document_Checklist__c doc,String docStatus, String address){
        try{
            system.debug('doc '+doc);
            SObjectAccessDecision decision;
            /*Document_Checklist__c  docChecklist = [SELECT Id,Document_Number__c,Document_Verification_Status__c  
                FROM Document_Checklist__c Where Applicant__c=: applicantId AND Document_Master__r.Document_Name__c=:documentName Limit 1];*/
            Document_Checklist__c docChecklist = doc;
            docChecklist.Document_Verification_Status__c = docStatus;
            docChecklist.Address__c = address;
            if(String.isNotBlank(doc.Api_Response__c)){
                docChecklist.Api_Response__c = doc.Api_Response__c;
            }
            decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{docChecklist});
            update decision.getRecords();
            system.debug('docChecklist '+docChecklist);
            return 'Success';
        }
        catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }


     // Retry Logic || START || 20 SEP || ASHISH
     @AuraEnabled
     public static String updateDocumentRetryChecklist(Document_Checklist__c doc,String docStatus, String address){
         try{
             Decimal Count =0;
             system.debug('doc '+doc);
             SObjectAccessDecision decision;
             
             Document_Checklist__c docChecklist = doc;

             
             //Query the existing retry count
             Document_Checklist__c  checklistList = [SELECT Id,Retry_Count__c,Applicant__c,Document_Master__c 
                                                    FROM Document_Checklist__c WHERE Applicant__c =: doc.Applicant__c AND Document_Master__c=:doc.Document_Master__c Limit 1];
            
             docChecklist.Address__c = address;
             if(docStatus == 'Not Verified'){
              //Existing Count + 1;
              Count = checklistList.Retry_Count__c + 1;
              docChecklist.Retry_Count__c = Count;
                 if(Count >=3){
                 docChecklist.Document_Verification_Status__c = 'Not Verified';
                 }
             }else{
                 docChecklist.Document_Verification_Status__c = docStatus;
             }
             
            
         
             if(String.isNotBlank(doc.Api_Response__c)){
                 docChecklist.Api_Response__c = doc.Api_Response__c;
             }
             decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{docChecklist});
             update decision.getRecords();
             system.debug('docChecklist '+docChecklist);
             return 'Success';
         }
         catch(Exception e){
             System.debug('error: '+e);
             return 'Error:'+e.getMessage();
         }
     }

     @AuraEnabled
     public static Decimal getCount(Document_Checklist__c doc){
        try {
             //Query the existing retry count
             Document_Checklist__c  checklistList = [SELECT Id,Retry_Count__c,Applicant__c ,Document_Master__c
                                                    FROM Document_Checklist__c WHERE Applicant__c =: doc.Applicant__c AND Document_Master__c=:doc.Document_Master__c Limit 1];

            System.debug('checklistListrecord-->' +checklistList);
            if(checklistList!=null ){
                return checklistList.Retry_Count__c;
            }else{
                return 0;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     }
     // Retry Logic || END || 20 SEP || ASHISH
    
    @AuraEnabled
    public static void mapUdhyamAddress(Document_Checklist__c doc,String docStatus, UdyamAuthHandler.OfficialAddress address){
        try {
            system.debug('address '+address);
            Address__c newAddress = new Address__c();
            if(newAddress != null){
            newAddress.City__c = address.city;
            newAddress.State__c = address.state;
            newAddress.Pincode__c = address.pincode;
            newAddress.District__c = address.district;
            newAddress.Address_Line_1__c = address.flat+','+address.premises;
            newAddress.Address_Line_2__c = address.block+','+address.road;
            newAddress.Address_Line_3__c = address.village;
            String serializedAddress= JSON.serializePretty(newAddress, true);
            updateDocumentChecklist(doc, docStatus, serializedAddress);
        }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void mapVoterIdAddress(Document_Checklist__c doc,String docStatus, AUSFVoterResponseWrapper.Result result){
        try {
            system.debug('result '+result);
            Address__c newAddress = new Address__c();
            newAddress.Address_Line_1__c = result.house_no;
            newAddress.District__c = result.district;
            newAddress.State__c = result.state;            
            newAddress.Pincode__c = result.pin;
            String serializedAddress= JSON.serializePretty(newAddress, true);
            updateDocumentChecklist(doc, docStatus, serializedAddress);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void mapAddresses(Document_Checklist__c doc,String docStatus, String address, String applicantId, String docType){
        try {
            system.debug('address '+address);
            Address__c newAddress = LOSAddressSplitController.callAddressSplitApi(address, applicantId);
            String serializedAddress= JSON.serializePretty(newAddress, true);
            updateDocumentChecklist(doc, docStatus, serializedAddress);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String verifyDL(String drivingId,String objectId,String msterRecordName,String dob) {
        IntegrationUtility.ResponseWrapper calloutResponse = getVoterCardResponse(drivingId,msterRecordName,'',dob,'',objectId);
        AUSFDrivingLicenseResponseWrapper wrapper = new AUSFDrivingLicenseResponseWrapper();
        AUSFDrivingLicenseResponseWrapper.UIResponse resp = new AUSFDrivingLicenseResponseWrapper.UIResponse(); 
        Object[] metadata;
        Map<String, String> replacements = new Map<String, String> {
            'non-transport' => 'nontransport',
            'father/husband' => 'fatherhusband',
            'status-code' => 'statuscode'
        };
        if(calloutResponse.statusCode==200){
            String actualResp = IntegrationUtility.mogrifyJSON(calloutResponse.response,replacements);
            system.debug('actualResp>> '+actualResp);       
            wrapper = AUSFDrivingLicenseResponseWrapper.parse(actualResp);        
            resp.Response = wrapper.result;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = getMetadataRecord('Driving License');
            resp.errorMessage = wrapper.result?.dl_number == null ? Utility.getApiCustomError(
                calloutResponse.checklistNumber,
                calloutResponse.response,
                'Unexpected response recieved',
                calloutResponse.statusCode,
                'AUSFDocumentVerificationController.verifyDL'
            ) : '';
        }else{
            resp.Response = wrapper.result;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = metadata;
            resp.errorMessage = Utility.getApiCustomError(
                calloutResponse.checklistNumber,
                calloutResponse.response,
                'Unexpected response recieved',
                calloutResponse.statusCode,
                'AUSFDocumentVerificationController.verifyDL'
            );
        }
        system.debug('return Response: '+JSON.serializePretty(resp));
        return JSON.serialize(resp);
    }
    
    @AuraEnabled
    public static String verifyPassport(String fileNum,String passportNum,String dob,String objectId,String msterRecordName) {
        IntegrationUtility.ResponseWrapper calloutResponse = getVoterCardResponse('',msterRecordName,fileNum,dob,passportNum,objectId);
        Object[] metadata;
        AUSFPassportResponseWrapper.UIResponse resp = new AUSFPassportResponseWrapper.UIResponse();    
        AUSFPassportResponseWrapper.PassPortResponse passResp = new AUSFPassportResponseWrapper.PassPortResponse();
        if(calloutResponse.statusCode==200){
            AUSFPassportResponseWrapper wrapper = AUSFPassportResponseWrapper.parse(calloutResponse.response); 
            passResp.nameFromPassport = wrapper?.result?.name?.nameFromPassport;
            passResp.surnameFromPassport = wrapper?.result.name?.surnameFromPassport;
            passResp.passportNumberFromSource = wrapper?.result?.passportNumber?.passportNumberFromSource;
            passResp.dispatchedOnFromSource = wrapper?.result?.dateOfIssue?.dispatchedOnFromSource;
            passResp.applicationDate = wrapper.result?.applicationDate;
            resp.Response = passResp;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = getMetadataRecord('Passport');
        }else{
            resp.Response = passResp;
            resp.statusCode = calloutResponse.statusCode;
            resp.metadata = metadata;
            resp.errorMessage = Utility.getApiCustomError(
                calloutResponse.checklistNumber,
                calloutResponse.response,
                'Unexpected response recieved',
                calloutResponse.statusCode,
                'AUSFDocumentVerificationController.verifyDL'
            );
        }
        
       
        system.debug('return: '+resp.Response);
        system.debug('return: '+resp.metadata);
        return JSON.serialize(resp);
    }
    
    @AuraEnabled
    public static String verifyGST(String gstNum, String applicantId) {

        String response = KarzaGSTAuthController.karzaGSTCallOut(gstNum, applicantId);       
        GSTAuthHandler.GSTResponseWrapper wrapper = GSTAuthHandler.parse(response);       
        GSTAuthHandler.UIResponse resp = new GSTAuthHandler.UIResponse();       
        resp.Response = wrapper.result;
        resp.metadata = getMetadataRecord('GST');
        return JSON.serialize(resp);
    }

    @AuraEnabled
    public static String verifyCIN(String cmpName, String applicantId) {

        String response = KarzaCINAuthController.karzaCINCallOut(cmpName, applicantId);      
        CINAuthHandler.CINResponseWrapper wrapper = CINAuthHandler.parse(response);        
        CINAuthHandler.UIResponse resp = new CINAuthHandler.UIResponse();       
        resp.Response = wrapper.result;
        resp.metadata = getMetadataRecord('CIN');
        return JSON.serialize(resp);
    }
   /* @AuraEnabled
    public static String getDirectorDetails(String Cinnum) {

        String response = KarzaCINAuthController.karzaCINCallOut(cmpName, applicantId);      
        CINAuthHandler.CINResponseWrapper wrapper = CINAuthHandler.parse(response);        
        CINAuthHandler.UIResponse resp = new CINAuthHandler.UIResponse();       
        resp.Response = wrapper.result;
        resp.metadata = getMetadataRecord('CIN');
        return JSON.serialize(resp);
    }*/
    @AuraEnabled
    public static String verifyCmpName(String cmpName, String applicantId) {

        String response = KarzaCINAuthController.karzaCINCallOut(cmpName, applicantId);    
        String CinNum = CINAuthHandler.parseCmpResponse(response);        
        return CinNum;
    }

    @AuraEnabled
    public static String fetchDirectorsData(String cinNumber, String applicantId) {

        String response = KarzaCINAuthController.karzaDirectorDetailsCallOut(cinNumber,applicantId);    
        CINAuthHandler.DirectorDetailsResponse directorDetails = CINAuthHandler.parseDirResponse(response);        
        return JSON.serialize(directorDetails);
    }

    @AuraEnabled
    public static String verifyUdyam(String udyamNum, String applicantId) {

        String response = KarzaUdyamAuthController.karzaUdyamCallOut(udyamNum, applicantId);      
        UdyamAuthHandler.UdyamResponseWrapper wrapper = UdyamAuthHandler.parse(response);       
        UdyamAuthHandler.UIResponse resp = new UdyamAuthHandler.UIResponse();       
        resp.Response = wrapper.result;
        resp.metadata = getMetadataRecord('Udyam');
        return JSON.serialize(resp);
    }
    
    public static IntegrationUtility.ResponseWrapper getVoterCardResponse(String voterOrDrivinglId,String msterRecordName,String fileNum,String dob,String passportNum,String objectId) {
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
        system.debug('objIntMapper>> '+objIntMapper);
        system.debug('dob In call>> '+dob);
        String respBody;
        String endPointUrl;
        Map<String,String> mapURLQueryParams;
        if(msterRecordName=='VoterCard API'){
            mapURLQueryParams = new Map<String,String>();
            mapURLQueryParams.put('consent','Y');
            mapURLQueryParams.put('epic_no',voterOrDrivinglId);
            mapURLQueryParams.put('ReqId',IntegrationUtility.getReferenceId());
            mapURLQueryParams.put('Channel',+objIntMapper.Apiuser__c);
           //endPointUrl = objIntMapper.End_Point_URL__c+voterOrDrivinglId+'&ReqId='+IntegrationUtility.getReferenceId()+'&Channel='+objIntMapper.Apiuser__c;
        }
        if(msterRecordName=='PassportVerification'){
            mapURLQueryParams = new Map<String,String>();
            mapURLQueryParams.put('ReqId',IntegrationUtility.getReferenceId());
            mapURLQueryParams.put('passportNo',passportNum);
            mapURLQueryParams.put('fileNo',fileNum);
            mapURLQueryParams.put('Channel',+objIntMapper.Apiuser__c);
            mapURLQueryParams.put('consent','Y');
            mapURLQueryParams.put('dob',dob);
            //mapURLQueryParams.put('dob','17/08/1987');
           //endPointUrl = objIntMapper.End_Point_URL__c+IntegrationUtility.getReferenceId()+'&Channel='+objIntMapper.Apiuser__c+'&passportNo='+passportNum+'&fileNo='+fileNum+'&consent=Y&dob='+dob;
        }
        
        If(msterRecordName=='DrivingLicenseVerification'){
            mapURLQueryParams = new Map<String,String>();
            mapURLQueryParams.put('consent','Y');
            mapURLQueryParams.put('dl_no',voterOrDrivinglId);
            mapURLQueryParams.put('dob',dob);
            //mapURLQueryParams.put('dob','17-07-1988');
            mapURLQueryParams.put('ReqId',IntegrationUtility.getReferenceId());
            mapURLQueryParams.put('Channel',+objIntMapper.Apiuser__c);
           //endPointUrl = objIntMapper.End_Point_URL__c+'dl_no='+voterOrDrivinglId+'&dob='+dob+'&ReqId='+IntegrationUtility.getReferenceId()+'&Channel='+objIntMapper.Apiuser__c;

        }
        system.debug('endPointUrl>> '+endPointUrl);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objectId);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        //calloutRequestWrapper.endpointURL=endPointUrl;
        calloutRequestWrapper.urlParamsMap=mapURLQueryParams;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        System.debug('request '+calloutRequestWrapper);
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody=calloutResponseWrapper.response;
        System.debug('response '+respBody);
        return calloutResponseWrapper;
        
    } 
    
    public static List<Display_Data__mdt> getMetadataRecord(String rType){
        return [SELECT Id, DeveloperName, MasterLabel, Display_on_UI__c, JSON_Key__c, API_Name__c, Order__c FROM Display_Data__mdt where Type__c =: rType WITH SECURITY_ENFORCED Order by Order__c];
    }
    
    @AuraEnabled
    public static void updateKYCDetails(String result,String applicantId){ 
        AUSFVoterResponseWrapper.Result response = (AUSFVoterResponseWrapper.Result) JSON.deserialize(result,AUSFVoterResponseWrapper.Result.Class);
        Applicant__c appObj = [SELECT Id, KYC_Status__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Aadhaar_Number__c, First_Name__c, Last_Name__c, Middle_Name__c, Father_Name__c FROM Applicant__c WHERE Id=:applicantId];
        List<Address__c> addList = [SELECT Id,Address_Type__c FROM Address__c WHERE Applicant__c=:appObj.id AND Address_Type__c='Permanent'];
        System.debug('response '+response);
        String preference = System.Label.KYC_Preference;
        Boolean flag = false;
        if(appObj.Aadhaar_Number__c!=null){
            flag = false;
        }
        else if((preference.contains('Driving') &&preference.indexOf('Driving')>preference.indexOf('Voter')) || appObj.Driving_License_Id__c==null){
            flag = true;
        }
        else{ 
            if((preference.contains('Passport') &&preference.indexOf('Passport')>preference.indexOf('Voter')) || appObj.Passport_Number__c==null){
                    flag = true;
            }
        }
        if(flag){
            List<String> nameList = response?.name?.split(' ');
            if(appObj.First_Name__c==null){
                appObj.First_Name__c = nameList[0];
            }
            if(nameList.size() == 2){
                if(appObj.Last_Name__c==null){
                    appObj.Last_Name__c = nameList[1];
                }
            }else if(nameList.size() > 2){
                if(appObj.Middle_Name__c==null){
                    appObj.Middle_Name__c = nameList[1];
                }
                if(appObj.Last_Name__c==null){
                    appObj.Last_Name__c = nameList[2];
                }
            }
            if(appObj.Father_Name__c==null){
                appObj.Father_Name__c = response.rln_name;
            }
            if(response.gender!=null && appObj.Gender__c==null && response.gender!=''){
               appObj.Gender__c = (response.gender=='M'?'Male':(response.gender=='F'?'Female':'Transgender')); 
            }
            if(response.dob!=null && appObj.Dob__c==null && response.dob!=''){
                String dob = response.dob.replaceAll('-','/');
                appObj.Dob__c = Date.parse(dob); 
            }
            if(appObj.KYC_Status__c != 'Complete' && addlist.size()==0){
                Address__c add = new Address__c();
                add.Address_Line_1__c = response.house_no;
                add.District__c = response.district;
                add.State__c = response.state;            
                add.Pincode__c = response.pin;
                add.Applicant__c = applicantId;
                add.Address_Type__c = 'Permanent';
                add.Address_Source__c = 'Voter ID';
                insert add;
            }
 
            appObj.KYC_Status__c = 'Complete';
            appObj.KYC_Type__c = 'Voter Id';
            System.debug('applicant details '+appObj);
            update appObj;
               
        }
    }
    
    @AuraEnabled
    public static void updateDLKYCDetails(String result,String applicantId){ 
        AUSFDrivingLicenseResponseWrapper.Result response = (AUSFDrivingLicenseResponseWrapper.Result) JSON.deserialize(result,AUSFDrivingLicenseResponseWrapper.Result.Class);
        Applicant__c appObj = [SELECT Id, KYC_Status__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Voter_Id__c, Aadhaar_number__c, First_Name__c, Middle_Name__c, Last_Name__c, Father_Name__c  FROM Applicant__c WHERE Id=:applicantId];
        System.debug('response '+response);
        String preference = System.Label.KYC_Preference;
        Boolean flag = false;
        if(appObj.Aadhaar_number__c != null){
            flag = false;
        }
        else if((preference.contains('Voter') &&preference.indexOf('Voter')>preference.indexOf('Driving')) || appObj.Voter_Id__c==null){
            flag = true;
        }
        else{ 
            if((preference.contains('Passport') &&preference.indexOf('Passport')>preference.indexOf('Driving')) || appObj.Passport_Number__c==null){
                    flag = true;
            }
        }
        if(flag){
            List<String> nameList = response?.name?.split(' ');
            if(appObj.First_Name__c==null){
                appObj.First_Name__c = nameList[0];
            }
            if(nameList.size() == 2 && appObj.Last_Name__c==null){
                appObj.Last_Name__c = nameList[1];
            }else if(nameList.size() > 2){
                if(appObj.Middle_Name__c == null){
                    appObj.Middle_Name__c = nameList[1];
                }
                if(appObj.Last_Name__c == null){
                    appObj.Last_Name__c = nameList[2];
                }
            }
            if(appObj.Father_Name__c == null){
                appObj.Father_Name__c = response.fatherhusband;
            }
            if(response.dob!=null){
                String dob = response.dob.replaceAll('-','/');
                if(appObj.Dob__c == null){
                    appObj.Dob__c = Date.parse(dob);
                }
            }

            appObj.KYC_Status__c = 'Complete';
            appObj.KYC_Type__c = 'Driving License';
            System.debug('applicant details '+appObj);
            if(String.isBlank( response.issue_date )){
                update appObj;
            }
            /*Address__c add = new Address__c();
            add.Address_Line_1__c = response.address;
            add.Applicant__c = applicantId;
            add.Address_Type__c = 'Permanent';
            add.Address_Source__c = 'Driving Licence';
            insert add;*/   
        }
        // R2-788 - Date of Issue of DL - Make sure the user has en_IN locale
        String dlIssueDate = response.issue_date?.replaceAll( '-', '/' );
        if( dlIssueDate != null ){
            appObj.Driving_License_Issue_Date__c = Date.parse( dlIssueDate );
            update appObj;
        }
    }
    
    @AuraEnabled
    public static void updatePassportKYCDetails(String result,String applicantId){ 
        AUSFPassportResponseWrapper.Result response = (AUSFPassportResponseWrapper.Result) JSON.deserialize(result,AUSFPassportResponseWrapper.Result.Class);
        Applicant__c appObj = [SELECT Id, KYC_Status__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Voter_Id__c, Aadhaar_Number__c, First_Name__c, Last_Name__c  FROM Applicant__c WHERE Id=:applicantId];
        System.debug('response '+response);
        String preference = System.Label.KYC_Preference;
        Boolean flag = false;
        if(appObj.Aadhaar_number__c!=null){
            flag = false;
        }
        else if((preference.contains('Voter') &&preference.indexOf('Voter')>preference.indexOf('Driving')) || appObj.Voter_Id__c==null){
            flag = true;
        }
        else{ 
            if((preference.contains('Passport') &&preference.indexOf('Passport')>preference.indexOf('Driving')) || appObj.Passport_Number__c==null){
                    flag = true;
            }
        }
        if(flag){
            if(appObj.First_Name__c==null){
                appObj.First_Name__c = response?.name?.nameFromPassport;
            }
            if(appObj.Last_Name__c==null){
                appObj.Last_Name__c = response?.name?.surnameFromPassport;
            }
            appObj.KYC_Status__c = 'Complete';
            appObj.KYC_Type__c = 'Passport';
            System.debug('applicant details '+appObj);
            update appObj;
            /*Address__c add = new Address__c();
            add.Address_Line_1__c = response.address;
            add.Applicant__c = applicantId;
            add.Address_Type__c = 'Permanent';
            add.Address_Source__c = 'Driving Licence';
            insert add;*/   
        }
    }

    @AuraEnabled
    public static String updateResponseOnDocument(String doc){
        try{
            Document_Checklist__c docChecklist = (Document_Checklist__c) JSON.deserialize(doc,Document_Checklist__c.class);
            Document_Checklist__c panCheckListRecord = [SELECT Id, Document_Verification_Status__c, Applicant__r.PAN_verification_Status__c, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE Id = :docChecklist.Id AND 
                                                        Document_Master__r.Document_Name__c = 'Pan Card/Form 60' LIMIT 1
                                                    ];
            if(panCheckListRecord!=null){
                docChecklist.Document_Verification_Status__c = (panCheckListRecord.Applicant__r.PAN_verification_Status__c);
            }
            SObjectAccessDecision decision;
            decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{docChecklist});
            update decision.getRecords();
            return 'Success';
        }
        catch(Exception e){
            System.debug('error: '+e);
            return 'Error:'+e.getMessage();
        }
    }
    
}