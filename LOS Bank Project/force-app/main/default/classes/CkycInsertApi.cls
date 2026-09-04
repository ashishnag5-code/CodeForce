public with sharing class CkycInsertApi extends CkycInsertWrapper {
    
    public Static Applicant__c appicantRec;  
    public Static Address__c   permanentAdd;
    public Static Address__c   currentAddress;
    public Static Loan_Application__c loanApplRec;
    public Static String idProofSUBIMGData;
    public Static String addresProofPOIPOAIMGData;
    public Static String addressProofCurrentAddressIMGData;
    public Static String imageData; 
    public Static Map<String, Object> entireRequest;
    public static List<String> mandatoryTagList = new List<String>();
    public static Map<String, Object> addressDetailImg = new Map<String, Object>();
    public static String permanentDocMster = '';
    public static String currentDocMster = '';
    public static Map<String, Object> identityDetails = new Map<String, Object>();
    public static String docMasterName = '';

    
    public static List<Loan_Application__c> getLoanAppList(String loanApplId) {
        
        List<Loan_Application__c> loanApplLst = [SELECT id, Branch_Master__r.Account_Code__c, Branch_Master__c,LAN_Created_By__c,LAN_Created_By__r.Name,LAN_Created_By__r.UserRole.Name,LAN_Creation_Date__c,Branch_Master__r.City__c
                                                 FROM Loan_Application__c
                                                 WHERE id = :loanApplId WITH SECURITY_ENFORCED];
        
        return loanApplLst;
    }
    
    @AuraEnabled
    public static List<Applicant__c> getApplicant(String applcntRecordId) {
        List<Applicant__c> applicantList = [SELECT Id, Title__c, Dob__c, Gender__c, First_Name__c, Middle_Name__c, Last_Name__c, Email__c,NPR__c,NREGA__c, 
                                            Mobile_Number__c, PAN__c, CIF_No__c, Father_Name__c, Spouse_Name__c, Mother_Name__c,Utility_Bills_Electricity__c,Utility_Bills_Landline_Phone__c,Utility_Bills_Water__c,
                                            Aadhaar_Number__c,Passport_Number__c,Voter_Id__c,Driving_License_Id__c,KYC_Type__c, Pan_Form60__c                                          
                                            FROM Applicant__c WHERE Id =:applcntRecordId WITH SECURITY_ENFORCED];
        return applicantList;
    }
    
    public Static List<Address__c> getAddress(String applcntId, String addressType) {
        List<Address__c> addressList = [SELECT Id,Name,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                        State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,
                                        Address_Source__c,Type__c, District__c, Same_As__c
                                        FROM Address__c 
                                        WHERE (Applicant__c =:applcntId AND Address_Type__c = :addressType AND (Source_Type__c = null OR Source_Type__c = 'CBS') ) WITH SECURITY_ENFORCED];
        
        return addressList;
    }
    
    public Integration_Checklist__c ckycInsertApi(String applcntId, String masterRecord) {
        String respBody;
        String errorMessage = 'The mandatory tags';
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
        
        String requestBody = generateRequest(applcntId);
        if(mandatoryTagList.size()>0){
            for(String s : mandatoryTagList){
                errorMessage = errorMessage +' '+ s;
            }
            errorMessage = errorMessage + ' are not populated';
            system.debug('@@errorMessage'+errorMessage);
            //throw new HandledException(errorMessage);
        }
        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        system.debug('calloutResponseWrapper '+calloutResponseWrapper);
        respBody = calloutResponseWrapper.response;
        if (calloutResponseWrapper.response != null && calloutResponseWrapper.response.contains('Successfully Inserted')) {
            return calloutResponseWrapper.checklistRecord;
        } else {
            calloutResponseWrapper.checklistRecord.Status__c = 'Failed';
            // ideally this should be in response callback but since DML is always performed in Integration Utility, setting this to failed in case of genuine failures
            update calloutResponseWrapper.checklistRecord;
        }
        return calloutResponseWrapper.checklistRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isCKYCComplete(String loanId, String applicantId) {
        if (String.isNotBlank(loanId)) {
            for (Integration_Checklist__c each : [SELECT Status__c FROM Integration_Checklist__c WHERE Loan__c = :loanId AND Integration_Master__r.Name = 'CKYC Insert' ORDER BY CreatedDate DESC LIMIT 1]) {
                return each.Status__c == 'Completed';
            }
        } else if (String.isNotBlank(applicantId)) {
            for (Integration_Checklist__c each : [SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c = :applicantId AND Integration_Master__r.Name = 'CKYC Insert' ORDER BY CreatedDate DESC LIMIT 1]) {
                return each.Status__c == 'Completed';
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static void delegateCKYCAPICall(String applicantId, String loanApplicationId) {
        if (String.isBlank(applicantId) || String.isBlank(loanApplicationId)) {
            return;    
        }
        Applicant__c applicantData = [SELECT Customer_Type__c FROM Applicant__c WHERE Id = :applicantId];
        if (applicantData.Customer_Type__c == 'Individual') {
            ckycInsertApiHandler(applicantId, loanApplicationId);
        } else {
            //  CkycInsertNonIndApi.ckycInsertNonIndApiHandler(applicantId, loanApplicationId);
        }
    }
    
    @AuraEnabled
    public static String ckycInsertApiHandler(String applcntId, String loanApplId) {
        appicantRec = getApplicant(applcntId).size() > 0 ? getApplicant(applcntId)[0] : new Applicant__c();
        loanApplRec = getLoanAppList(loanApplId)[0];
        permanentAdd = getAddress(applcntId, 'Permanent')[0];
        currentAddress = getAddress(applcntId, 'Current')[0];
        
        CkycInsertApi obj = new CkycInsertApi();
        Integration_Checklist__c statusRecord = obj.ckycInsertApi(applcntId, 'CKYC Insert');
        CkycUtil.createCkycFaildRecord(entireRequest, 'Individual', idProofSUBIMGData, addresProofPOIPOAIMGData, addressProofCurrentAddressIMGData, imageData);
        if (statusRecord.Status__c != 'Completed' && statusRecord.Response__c != null && statusRecord.Response__c.startsWith('{')) {
            CKYCResponseWrapper responseInst = (CKYCResponseWrapper) JSON.deserialize(statusRecord.Response__c, CKYCResponseWrapper.class);
            return responseInst.Data_Error;
        }
        return statusRecord.Status__c;
    }
    
    
    public static String generateRequest(String applcntId) {
        
        Map<String, Object> kycVerification = new Map<String, Object>();
        String branchMasterId = loanApplRec.Branch_Master__c;
        
        //commented by naga for CKYC branch code issue.
        /*
List<AccountTeamMember> accountTeamMemberList = [SELECT Id, User.Name, User.Title, User.Branch_Code__c, User.Employee_Code__c, User.Employee_Id__c,Account.City__c
FROM AccountTeamMember 
WHERE UserId =: loanApplRec.LAN_Created_By__c and AccountId = :loanApplRec.Branch_Master__c WITH SECURITY_ENFORCED];

AccountTeamMember accountTeamMemb = accountTeamMemberList.size() > 0 ? accountTeamMemberList[0] : new AccountTeamMember();*/
        
        list<user> userList = [SELECT Id, Name, Title, Branch_Code__c, Employee_Code__c, Employee_Id__c FROM User WHERE Id =: loanApplRec.LAN_Created_By__c WITH SECURITY_ENFORCED];
        User userRec = userList.size() > 0 ? userList[0] : new User();
        
        
        Date todayDate = Date.today();
        //String todayDateFormated = todayDate != null ? todayDate.day() + '-' + todayDate.month() + '-' + todayDate.year() : '';
        String todayDateFormated = todayDate != null ? todayDate.year() + '-' + todayDate.month() + '-' + todayDate.day() : '';
        
        kycVerification.put('DATE_OF_DECLARATION', todayDateFormated);
        kycVerification.put('PLACE_OF_DECLARATION', String.isNotBlank(loanApplRec.Branch_Master__r.City__c) ? loanApplRec.Branch_Master__r.City__c : '');
        kycVerification.put('KYC_VERIFICATION_DATE',loanApplRec.LAN_Creation_Date__c != null ? loanApplRec.LAN_Creation_Date__c : null);
        kycVerification.put('TYPE_OF_DOC_SUBMITTED', '01');
        if(userRec.Name == null){
            mandatoryTagList.add('KYC_VERIFICATION_NAME');
        }
        kycVerification.put('KYC_VERIFICATION_NAME', loanApplRec.LAN_Created_By__c != null ? loanApplRec.LAN_Created_By__r.Name : '');
        kycVerification.put('KYC_VERIFICATION_DESIGNATION', loanApplRec.LAN_Created_By__c != null ? loanApplRec.LAN_Created_By__r.UserRole.Name : '');
        if(userRec.Branch_Code__c == null){
            mandatoryTagList.add('KYC_VERIFICATION_BRANCH');
        }
        kycVerification.put('KYC_VERIFICATION_BRANCH', userRec.Branch_Code__c);
        if(userRec.Employee_Id__c == null){
            mandatoryTagList.add('KYC_VERIFICATION_EMP_CODE');
        }
        kycVerification.put('KYC_VERIFICATION_EMP_CODE', userRec.Employee_Id__c);
        kycVerification.put('ORGANISATION_NAME', 'AU Small Finance Bank LTD');
        kycVerification.put('ORGANISATION_CODE', 'IN1519');
        kycVerification.put('CUSTOMER_IDENTIFICATION_FLAG', '01');
        kycVerification.put('SRC_APPLICATION', 'SFDC');
        
        
        ContentVersion contentVer;       
        try {
            contentVer = getRelatedFile(applcntId, 'Live Photo')[0];
            system.debug('applcntId::'+applcntId);
        }
        catch(exception e){
            throw new AuraHandledException('Error while fetching the Live Photo document');
        }
        Blob versionDataOfCustomerImg = contentVer.VersionData;
        
        Map<String, Object> imageDetails = new Map<String, Object>();
        imageDetails.put('IMAGE_TYPE', 'Photograph');
        //SFAU-5576
        imageDetails.put('IMAGE_EXTENTION', contentVer.FileExtension);
        imageDetails.put('IMAGE_CODE', '02');
        imageDetails.put('IMAGE_DATA', EncodingUtil.base64Encode(versionDataOfCustomerImg));
        imageData = contentVer.Id;
                
        String permanentAddressSource = permanentAdd.Address_Source__c;
        String currentAddressSource = currentAddress.Address_Source__c;

        ContentVersion permanentContentVer;

        setAddressProof(permanentAddressSource, 'ADDRESS_PROOF_POI_POA_NUMBER', 'Permanent');
        
        try {
            permanentContentVer = getRelatedFile(applcntId, permanentDocMster)[0]; 
        }
        catch(exception e){
            throw new AuraHandledException('Error while fetching the '+permanentDocMster+' document');
        }
        
        //SFAU-5576 : Samridhi
        addressDetailImg.put('ADDRESS_PROOF_POI_POA_IMG_TYPE', permanentContentVer.FileExtension);
        addressDetailImg.put('ADDRESS_PROOF_POI_POA_IMGDATA', EncodingUtil.base64Encode(permanentContentVer.VersionData));
        addresProofPOIPOAIMGData = permanentContentVer.Id; 
        
        setAddressProof(currentAddressSource, 'ADDRESS_PROOF_CURRENT_ADDRESS_NUMBER', 'Current');

        ContentVersion currentContentVer;
         try {
            currentContentVer = getRelatedFile(applcntId, currentDocMster)[0]; 
        }
        catch(exception e){
            throw new AuraHandledException('Error while fetching the '+currentDocMster+' document');
        }
        addressDetailImg.put('ADDRESS_PROOF_CURRENT_ADDRESS_IMG_TYPE', currentContentVer.FileExtension);
        addressDetailImg.put('ADDRESS_PROOF_CURRENT_ADDRESS_IMGDATA', EncodingUtil.base64Encode(currentContentVer.VersionData));
        addressProofCurrentAddressIMGData = currentContentVer.Id;
                
        String kycType = appicantRec.KYC_Type__c;
        
        setIdentityDetails(kycType);
        
        ContentVersion contVer;
          
         try {
            contVer = getRelatedFile(applcntId, docMasterName)[0];
        }
        catch(exception e){
            throw new AuraHandledException('Error while fetching the '+docMasterName+' document');
        }
        
        String versionDataIdentityDet = EncodingUtil.base64Encode(contVer.VersionData);
        identityDetails.put('IDPROOF_SUB_IMG_TYPE', contVer.FileExtension);
        identityDetails.put('IDPROOF_SUB_IMG_DATA',versionDataIdentityDet);
        idProofSUBIMGData = contVer.Id;
        
        Map<String, Object> relatedPersonImgDetails = new Map<String, Object>();
        relatedPersonImgDetails.put('R_IMG_PHOTOGRAPH_TYPE', '');
        relatedPersonImgDetails.put('R_IMG_PHOTOGRAPH', '');
        relatedPersonImgDetails.put('R_IMG_POI_POA_TYPE', '');
        relatedPersonImgDetails.put('R_IMG_POI_POA', '');
        relatedPersonImgDetails.put('R_IMG_CURR_POA_TYPE', '');
        relatedPersonImgDetails.put('R_IMG_CURR_POA', '');
        
        Map<String, Object> relatedPersonDetails = new Map<String, Object>();
        relatedPersonDetails = createMapOfRelPersonDet();
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        contactDetails.put('RESIDENCE_TEL_NO_STDCODE', '');
        contactDetails.put('RESIDENCE_TEL_NO', '');
        contactDetails.put('OFFICE_TEL_NO_STDCODE', '');
        contactDetails.put('OFFICE_TEL_NO', '');
        contactDetails.put('MOBILE_NO_ISDCODE', '');
        contactDetails.put('MOBILE_NO', appicantRec.Mobile_Number__c);
        
        List<String> lolValLst = new List<String>{'Aadhar Card', 'Driving Licence', 'Voter ID', 'Passport', 'NREGA Job Card', 'NPR Card'};
            String selfDecl = '';
        if(currentAddress.Same_As__c != 'Permanent' && !(lolValLst.contains(currentAddress.Address_Source__c))) {
            selfDecl = 'Y';
        }
        
        Map<String, Object> addressDetails = new Map<String, Object>();
        if(permanentAdd == null || permanentAdd.Address_Line_1__c == null){
            mandatoryTagList.add('POI_POA_ADDRESS_LINE1');
        }
        /* SFAU-5858 Start - Kunal */
        String perAddressLine1 = permanentAdd.Address_Line_1__c != null && permanentAdd.Address_Line_1__c.length() > 55 ? permanentAdd.Address_Line_1__c.subString(0,55) : permanentAdd.Address_Line_1__c;
        String perAddressLine2 = permanentAdd.Address_Line_2__c != null && permanentAdd.Address_Line_2__c.length() > 55 ? permanentAdd.Address_Line_2__c.subString(0,55) : permanentAdd.Address_Line_2__c;
        String perAddressLine3 = permanentAdd.Address_Line_3__c != null && permanentAdd.Address_Line_3__c.length() > 55 ? permanentAdd.Address_Line_3__c.subString(0,55) : permanentAdd.Address_Line_3__c;

        String currAddressLine1 = currentAddress.Address_Line_1__c != null && currentAddress.Address_Line_1__c.length() > 55 ? currentAddress.Address_Line_1__c.subString(0,55) : currentAddress.Address_Line_1__c;
        String currAddressLine2 = currentAddress.Address_Line_2__c != null && currentAddress.Address_Line_2__c.length() > 55 ? currentAddress.Address_Line_2__c.subString(0,55) : currentAddress.Address_Line_2__c;
        String currAddressLine3 = currentAddress.Address_Line_3__c != null && currentAddress.Address_Line_3__c.length() > 55 ? currentAddress.Address_Line_3__c.subString(0,55) : currentAddress.Address_Line_3__c;


        addressDetails.put('POI_POA_ADDRESS_LINE1', perAddressLine1);
        addressDetails.put('POI_POA_ADDRESS_LINE2', perAddressLine2);
        addressDetails.put('POI_POA_ADDRESS_LINE3', String.isNotBlank(perAddressLine3) ? perAddressLine3 : '');
         /* SFAU-5858 - Kunal */
        if(permanentAdd != null && permanentAdd.City__c == null){
            mandatoryTagList.add('POI_POA_ADDRESS_C_T_V');
        }
        addressDetails.put('POI_POA_ADDRESS_C_T_V', permanentAdd.City__c);
        if(permanentAdd != null && permanentAdd.District__c == null){
            mandatoryTagList.add('POI_POA_ADDRESS_DISTRICT');
        }
        addressDetails.put('POI_POA_ADDRESS_DISTRICT', permanentAdd.District__c);
        if(permanentAdd != null && permanentAdd.State__c == null){
            mandatoryTagList.add('POI_POA_ADDRESS_STATE');
        }
        addressDetails.put('POI_POA_ADDRESS_STATE', permanentAdd.State__c);
        addressDetails.put('POI_POA_ADDRESS_COUNTRY', 'INDIA');
        if (permanentAdd != null && permanentAdd.Pincode__c == null){
            mandatoryTagList.add('POI_POA_ADDRESS_PINCODE');
        }
        addressDetails.put('POI_POA_ADDRESS_PINCODE', permanentAdd.Pincode__c);
        if(permanentAdd.Address_Source__c !=null && permanentAdd.Address_Source__c.contains('Aadhaar')){
            permanentAdd.Address_Source__c = 'Aadhar Card';
        }else if(permanentAdd.Address_Source__c == 'Voter Id'){
            permanentAdd.Address_Source__c = 'Voter ID';
        }else if(permanentAdd.Address_Source__c == 'NREGA'){
            permanentAdd.Address_Source__c = 'NREGA Job Card';
        }else if(permanentAdd.Address_Source__c == 'NPR'){
            permanentAdd.Address_Source__c = 'NPR Card';
        }

        if(currentAddress.Address_Source__c !=null && currentAddress.Address_Source__c.contains('Aadhaar')){
            currentAddress.Address_Source__c = 'Aadhar Card';
        }else if(currentAddress.Address_Source__c == 'Voter Id'){
            currentAddress.Address_Source__c = 'Voter ID';
        }else if(currentAddress.Address_Source__c == 'NREGA'){
            currentAddress.Address_Source__c = 'NREGA Job Card';
        }else if(currentAddress.Address_Source__c == 'NPR'){
            currentAddress.Address_Source__c = 'NPR Card';
        }

        String addressSource;
        if (permanentAdd.Address_Source__c == null) {
            mandatoryTagList.add('ADDRESS_PROOF_POI_POA');
        }else{
            addressSource = GlobalConstants.ADDRESS_SOURCE_CKYC_MAP.containsKey(permanentAdd.Address_Source__c) ? GlobalConstants.ADDRESS_SOURCE_CKYC_MAP.get(permanentAdd.Address_Source__c) : permanentAdd.Address_Source__c;
        }

        addressDetails.put('ADDRESS_PROOF_POI_POA', addressSource);
        addressDetails.put('ADDRESS_PROOF_POI_POA_OTHERS', '');
        if (currentAddress.Same_As__c == null){
            mandatoryTagList.add('FLAG_POI_POA_ADDR_SAME_CURRENT_ADDR');
        }

        //SFAU-5590 : Added by Samridhi to modify Same As logic
       // String currentAddKey = currentAddress.Address_Line_1__c+'~'+currentAddress.Address_Line_2__c+'~'+currentAddress.Address_Line_3__c+'~'+currentAddress.State__c+'~'+currentAddress.City__c+'~'+currentAddress.District__c+'~'+currentAddress.Address_Source__c;
       // String permanentAddKey = permanentAdd.Address_Line_1__c+'~'+permanentAdd.Address_Line_2__c+'~'+permanentAdd.Address_Line_3__c+'~'+permanentAdd.State__c+'~'+permanentAdd.City__c+'~'+permanentAdd.District__c+'~'+permanentAdd.Address_Source__c;

       //SFAU-5603 : Added by Samridhi to modify Same As Logic
        addressDetails.put('FLAG_POI_POA_ADDR_SAME_CURRENT_ADDR', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? 'N' : 'Y');
        if(currentAddress.Address_Line_1__c == null){
            mandatoryTagList.add('CURRENT_ADDRESS_LINE1');
        }
        //SFAU-5652: Updated by Samridhi to set values from permanant address if address source is same as current address
        /* SFAU-5858 - Kunal */
        addressDetails.put('CURRENT_ADDRESS_LINE1', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currAddressLine1 : perAddressLine1);
        addressDetails.put('CURRENT_ADDRESS_LINE2', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currAddressLine2 : perAddressLine2);
        addressDetails.put('CURRENT_ADDRESS_LINE3', String.isNotBlank(currentAddress.Address_Line_3__c) && currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currAddressLine3 : (String.isNotBlank(perAddressLine3) && currentAddress.Address_Source__c == permanentAdd.Address_Source__c ? perAddressLine3 : ''));
        /* SFAU-5858 - Kunal */
        if(currentAddress.City__c == null){
            mandatoryTagList.add('CURRENT_ADDRESS_C_T_V');
        }
        addressDetails.put('CURRENT_ADDRESS_C_T_V', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currentAddress.City__c : permanentAdd.City__c);
        addressDetails.put('CURRENT_ADDRESS_DISTRICT', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currentAddress.District__c : permanentAdd.District__c);
        if(currentAddress.State__c == null){
            mandatoryTagList.add('CURRENT_ADDRESS_STATE');
        }
        addressDetails.put('CURRENT_ADDRESS_STATE', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currentAddress.State__c : permanentAdd.State__c);
        addressDetails.put('CURRENT_ADDRESS_COUNTRY', 'INDIA');
        if(currentAddress.Pincode__c == null){
            mandatoryTagList.add('CURRENT_ADDRESS_PINCODE');
        }
        addressDetails.put('CURRENT_ADDRESS_PINCODE', currentAddress.Address_Source__c != permanentAdd.Address_Source__c ? currentAddress.Pincode__c : permanentAdd.Pincode__c);
        
        if(currentAddress.Address_Source__c == null){
            mandatoryTagList.add('ADDRESS_PROOF_CURRENT_ADDRESS');
            addressSource = null;
        }else{
            addressSource = GlobalConstants.ADDRESS_SOURCE_CKYC_MAP.containsKey(currentAddress.Address_Source__c) ? GlobalConstants.ADDRESS_SOURCE_CKYC_MAP.get(currentAddress.Address_Source__c) : currentAddress.Address_Source__c;
        }
        
        addressDetails.put('ADDRESS_PROOF_CURRENT_ADDRESS', addressSource);
        addressDetails.put('SELF_DECLARATION', selfDecl);
        
        
        Map<String, Object> personalEntityDetails = new Map<String, Object>();
        personalEntityDetails.put('CONSTI_TYPE', 'Individual');
        personalEntityDetails.put('ACC_TYPE', '01');
        personalEntityDetails.put('CKYC_FI_REF_NO', '1');
        personalEntityDetails.put('PREFIX', String.isNotBlank(appicantRec.Title__c) ? appicantRec.Title__c : '');
        personalEntityDetails.put('FNAME', appicantRec.First_Name__c);
        personalEntityDetails.put('MNAME', String.isNotBlank(appicantRec.Middle_Name__c) ? appicantRec.Middle_Name__c : '');
        personalEntityDetails.put('LNAME', appicantRec.Last_Name__c);
        personalEntityDetails.put('NAME_OF_THE_ENTITY', '');
        
        
        if(String.isNotBlank(appicantRec.Father_Name__c)) {
            personalEntityDetails.put('FATHER_SPOUSE_FLAG', '1');
            personalEntityDetails.put('FATHER_SPOUSE_PREFIX', 'Mr');
            personalEntityDetails.put('FATHER_SPOUSE_FNAME', appicantRec.Father_Name__c);
            personalEntityDetails.put('FATHER_SPOUSE_MNAME', '');
            personalEntityDetails.put('FATHER_SPOUSE_LNAME', '');
        }
        else if (String.isNotBlank(appicantRec.Spouse_Name__c)) {
            personalEntityDetails.put('FATHER_SPOUSE_FLAG', '2');
            personalEntityDetails.put('FATHER_SPOUSE_PREFIX', '');
            personalEntityDetails.put('FATHER_SPOUSE_FNAME', appicantRec.Spouse_Name__c);
            personalEntityDetails.put('FATHER_SPOUSE_MNAME', '');
            personalEntityDetails.put('FATHER_SPOUSE_LNAME', '');
        }
        if(personalEntityDetails.get('FATHER_SPOUSE_FLAG') == '1' || (personalEntityDetails.get('FATHER_SPOUSE_FLAG') == '2')) {
            personalEntityDetails.put('MOTHER_PREFIX', '');
            personalEntityDetails.put('MOTHER_FNAME', '');
            personalEntityDetails.put('MOTHER_MNAME', '');
            personalEntityDetails.put('MOTHER_LNAME', '');
        }
        else {
            personalEntityDetails.put('MOTHER_PREFIX', 'Mrs');
            personalEntityDetails.put('MOTHER_FNAME', appicantRec.Mother_Name__c);
            personalEntityDetails.put('MOTHER_MNAME', '');
            personalEntityDetails.put('MOTHER_LNAME', '');
        }
        
        if(appicantRec.Gender__c == 'Male') {
            personalEntityDetails.put('GENDER', 'M');
        }
        else if(appicantRec.Gender__c == 'Female') {
            personalEntityDetails.put('GENDER', 'F');
        }
        else if(appicantRec.Gender__c == 'Transgender') {
            personalEntityDetails.put('GENDER', 'T');
        }else{
            personalEntityDetails.put('GENDER', '');
        }
        
        Date dt = appicantRec.Dob__c;
        String monthName = lookupMonthName(dt);
        String dob = dt.day() + '-' + monthName + '-' + dt.year();
        String pan = String.isNotBlank(appicantRec.PAN__c) ? appicantRec.PAN__c : 'FORM60';
        
        personalEntityDetails.put('DOB', dob);
        personalEntityDetails.put('PAN_FORM60', pan);
        
        if(String.isNotBlank(appicantRec.Aadhaar_Number__c)) {
            personalEntityDetails.put('AADHAR', 'XXXXXXXX' + appicantRec.Aadhaar_Number__c.right(4));
        }
        else {
            personalEntityDetails.put('AADHAR', '');
        }
        
        personalEntityDetails.put('NUMBER_OF_RELATED_PERSON', '');
        
        Map<String, Object> updationModule = new Map<String, Object>();
        updationModule.put('APPLICANT_ENTITY_UPDATE_FLAG', '02');       
        updationModule.put('PERSONAL_ENTITY_DETAILS_UPDATE_FLAG', '02');       
        updationModule.put('ADDRESS_DETAILS_UPDATE_FLAG', '02');
        updationModule.put('CONTACT_DETAILS_UPDATE_FLAG', '02');                
        updationModule.put('REMARKS_UPDATE_FLAG', '02');          
        updationModule.put('KYC_VERIFICATION_UPDATE_FLAG', '02');        
        updationModule.put('IDENTITY_DETAILS_UPDATE_FLAG', '02');       
        updationModule.put('RELATED_PERSON_DETAILS_UPDATE_FLAG', '02');        
        updationModule.put('IMAGE_DETAILS_UPDATE_FLAG', '02');
        
        Map<String, Object> systemUse = new Map<String, Object>();
        systemUse.put('APPLICATION_TYPE', Label.CKYC_ApplicationType);
        systemUse.put('BRANCH_CODE', '2011');
        systemUse.put('CKYCNumber', '');
        
        Map<String, Object> customerDetails = new Map<String, Object>();
        
        customerDetails.put('CUSTOMER_ID', appicantRec.CIF_No__c);
        customerDetails.put('MOD_FLAG', 'N');
        customerDetails.put('SYSTEM_USE', systemUse);
        customerDetails.put('UPDATION_MODULE', updationModule);
        customerDetails.put('PERSONAL_ENTITY_DETAILS', personalEntityDetails);
        customerDetails.put('ADDRESS_DETAILS', addressDetails);
        customerDetails.put('CONTACT_DETAILS', contactDetails);
        customerDetails.put('RELATED_PERSON_DETAILS', relatedPersonDetails);
        customerDetails.put('RELATED_PERSON_IMAGES_DETAILS', relatedPersonImgDetails);
        customerDetails.put('IDENTITY_DETAILS', identityDetails);
        customerDetails.put('ADDRESS_DETAILS_IMG', addressDetailImg);
        customerDetails.put('IMAGE_DETAILS', imageDetails);
        customerDetails.put('KYC_VERIFICATION', kycVerification);
        
        
        entireRequest = new Map<String, Object>{
            'UNIQUE_REQUEST_ID' => IntegrationUtility.getReferenceId(),
                'CUSTOMERS_DETAILS' => customerDetails           
                };
                    
                    String jsonString = '{';
        
        for (String key : entireRequest.keySet()) {
            if(key == 'CUSTOMERS_DETAILS') {
                jsonString += '"' + key + '":' + createJSONRequest(entireRequest.get(key)) +','; 
            } 
            else {   
                jsonString +='"' + key + '":"' + entireRequest.get(key) + '",';      
            }       
        }
        
        jsonString = jsonString.removeEnd(',') + '}';
        
        System.debug('My JSON Request::'+jsonString);
        return jsonString;
    }

    public static void setAddressProof(String addressSource, String key, String type){
                
        String returnValue = '';
        if(addressSource.containsIgnoreCase('Aadhaar')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Aadhaar_Number__c) ? appicantRec.Aadhaar_Number__c : '');
            returnValue = 'Aadhaar Card';
        }
        else if(addressSource.containsIgnoreCase('Voter')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Voter_Id__c) ? appicantRec.Voter_Id__c : '');
            returnValue = 'Voter ID Card';
        }
        else if(addressSource.containsIgnoreCase('Passport')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Passport_Number__c) ? appicantRec.Passport_Number__c : '');
            returnValue = 'Passport';
        }
        else if(addressSource.containsIgnoreCase('Driving')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Driving_License_Id__c) ? appicantRec.Driving_License_Id__c : '');
            returnValue = 'Driving Licence';
        }
        else if(addressSource.containsIgnoreCase('Electricity Bill')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Utility_Bills_Electricity__c) ? appicantRec.Utility_Bills_Electricity__c : '');
            returnValue = 'Electricity Bill';
        }
        else if(addressSource.containsIgnoreCase('Telephone Bill')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Utility_Bills_Landline_Phone__c) ? appicantRec.Utility_Bills_Landline_Phone__c : '');
            returnValue = 'Telephone Bill';
        }
        else if(addressSource.containsIgnoreCase('Water Bill')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.Utility_Bills_Water__c) ? appicantRec.Utility_Bills_Water__c : '');
            returnValue = 'Water Bill';
        }
        else if(addressSource.containsIgnoreCase('NPR')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.NPR__c) ? appicantRec.NPR__c : '');
            returnValue = 'NPR document';
        }
        else if(addressSource.containsIgnoreCase('NREGA')) {
            addressDetailImg.put(key, String.isNotBlank(appicantRec.NREGA__c) ? appicantRec.NREGA__c : '');
            returnValue = 'NREGA document';
        }
        else if(addressSource.containsIgnoreCase('Property Tax')) {
            addressDetailImg.put(key, '');
            returnValue = 'House Tax Receipt';
        }else if(addressSource.containsIgnoreCase('Rent Agreement')){
            addressDetailImg.put(key, '');
            returnValue = 'Rent agreement';
        }else if(addressSource.containsIgnoreCase('Accommodation Allotment Letter')){
            addressDetailImg.put(key, '');
            returnValue = 'Accommodation allotment letter';
        }else if(addressSource.containsIgnoreCase('Piped Gas Bill')){
            addressDetailImg.put(key, '');
            returnValue = 'PNG bill';
        }
        

        if(type == 'Current'){
            currentDocMster = returnValue;
        }else{
            permanentDocMster = returnValue;
        }
    }

    public static void setIdentityDetails(String kycType){
        if(kycType.containsIgnoreCase('Aadhaar')) {
            identityDetails.put('IDENT_TYPE', 'Aadhar Card');
            
            if(String.isNotBlank(appicantRec.Aadhaar_Number__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.Aadhaar_Number__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM', '');
            }    
            
            identityDetails.put('IDPROOF_SUBMITTED', 'Aadhar Card'); 
            docMasterName = 'Aadhaar Card';
        }
        else if(kycType.containsIgnoreCase('Voter')) {
            identityDetails.put('IDENT_TYPE', 'Voter ID'); 
            
            if(String.isNotBlank(appicantRec.Voter_Id__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.Voter_Id__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM', '');
            } 
            
            identityDetails.put('IDPROOF_SUBMITTED', 'Voter ID Card');
            docMasterName = 'Voter ID Card';
        }
        else if(kycType.containsIgnoreCase('Passport')) {
            identityDetails.put('IDENT_TYPE', 'Passport');
            
            if(String.isNotBlank(appicantRec.Passport_Number__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.Passport_Number__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM', '');
            }
            
            identityDetails.put('IDPROOF_SUBMITTED', 'Passport'); 
            docMasterName = 'Passport';
        }
        else if(kycType.containsIgnoreCase('Driving')) {
            identityDetails.put('IDENT_TYPE', 'Driving Licence'); 
            
            if(String.isNotBlank(appicantRec.Driving_License_Id__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.Driving_License_Id__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM',  '');
            }
            
            identityDetails.put('IDPROOF_SUBMITTED', 'Driving Licence'); 
            docMasterName = 'Driving Licence';
        }else if(kycType == 'NPR'){
            identityDetails.put('IDENT_TYPE', 'NPR Card'); 
            if(String.isNotBlank(appicantRec.NPR__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.NPR__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM',  '');
            }
            identityDetails.put('IDPROOF_SUBMITTED', 'NPR Card'); 
            if(String.isNotBlank(appicantRec.NPR__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.NPR__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM',  '');
            }
            docMasterName = 'NPR document';
        }else if(kycType == 'NREGA'){
            identityDetails.put('IDENT_TYPE', 'NREGA Job Card'); 
            docMasterName = 'NREGA document';
            if(String.isNotBlank(appicantRec.NREGA__c)) {
                identityDetails.put('IDENT_NUM', 'XXXXXXXX' + appicantRec.NREGA__c.right(4));
            }
            else {
                identityDetails.put('IDENT_NUM',  '');
            }
            identityDetails.put('IDPROOF_SUBMITTED', 'NREGA Job Card'); 
        }else if(kycType == 'Property Tax receipt'){
            identityDetails.put('IDENT_TYPE', 'Proprty_MuncipleRecpt'); 
            docMasterName = 'House Tax Receipt';
            identityDetails.put('IDENT_NUM',  '');
            identityDetails.put('IDPROOF_SUBMITTED', 'Proprty_MuncipleRecpt'); 
        }else if(kycType == 'Rent agreement'){
            identityDetails.put('IDPROOF_SUBMITTED', ''); 
            docMasterName = 'Rent agreement';
            identityDetails.put('IDENT_NUM',  '');
        }
    }
    
    public static String createJSONRequest(Object param){
        
        Map<String, Object> paramsMap =  (Map<String, Object>) param;        
        String jsonString = '{';
        
        for (String key : paramsMap.keySet()) {            
            if(key == 'SYSTEM_USE' || key == 'UPDATION_MODULE' || key == 'PERSONAL_ENTITY_DETAILS' || key == 'ADDRESS_DETAILS' || key == 'CONTACT_DETAILS'
               || key == 'RELATED_PERSON_DETAILS' || key == 'RELATED_PERSON_IMAGES_DETAILS' || key == 'IDENTITY_DETAILS' || key == 'ADDRESS_DETAILS_IMG'
               || key == 'IMAGE_DETAILS' || key == 'KYC_VERIFICATION') {
                   
                   if(key=='IMAGE_DETAILS' ||key == 'IDENTITY_DETAILS')
                   {
                       jsonString = jsonString + '"' + key + '":[' + createJSONRequest(paramsMap.get(key)) +']'+','; 
                   } else{
                       jsonString = jsonString + '"' + key + '":' + createJSONRequest(paramsMap.get(key)) +','; 
                   }
               } else {
                   
                   jsonString =jsonString + '"' + key + '":"' + paramsMap.get(key) + '",';      
               }       
        }   
        
        
        jsonString = jsonString.removeEnd(',') + '}';
        
        return jsonString;      
    }
    
    public Static String lookupMonthName(Date d) {
        Map<Integer,String> monthNames = new Map<Integer,String>{
            1 => 'January',
                2 => 'February',
                3 => 'March',
                4 => 'April',
                5 => 'May',
                6 => 'June',
                7 => 'July',
                8 => 'August',
                9 => 'September',
                10 => 'October',
                11 => 'November',
                12 => 'December'
                };
                    return monthNames.get(d.month());
    }
    
    public Static List<ContentVersion> getRelatedFile(String applcntId, String docMasterName) {
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        List<ContentVersion> contVersionList     = new List<ContentVersion>();
        
        List<Document_Checklist__c> docCheckList = [SELECT id FROM Document_Checklist__c WHERE Applicant__c =: applcntId and Document_Master__r.Document_Name__c =:docMasterName];
        if(docCheckList.size() > 0) {
            contentDocList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:docCheckList[0].id  AND ContentDocument.LatestPublishedVersion.isActive__c = true Order By ContentDocument.CreatedDate DESC]; // Check to add the latest date
            
        }
        //SFAU-5652: Update to fetch latest doc
        if(contentDocList.size() > 0) {
            contVersionList = [SELECT id, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId =:contentDocList[0].ContentDocumentId and isActive__c = true order by LastModifiedDate desc limit 1];
            
        }
        
        return contVersionList;
    }
    
    public static Map<String, Object> createMapOfRelPersonDet() {
        
        Map<String, Object> relatedPersonDetailMap = new Map<String, Object>();
        relatedPersonDetailMap.put('R_TYPE_OF_RELATIONSHIP','');
        relatedPersonDetailMap.put('R_KYC_NUMBER','');
        relatedPersonDetailMap.put('R_ADD_DEL_RELATED_PERSON','');
        relatedPersonDetailMap.put('R_PREFIX','');
        relatedPersonDetailMap.put('R_FNAME','');
        relatedPersonDetailMap.put('R_MNAME','');
        relatedPersonDetailMap.put('R_LNAME','');
        relatedPersonDetailMap.put('R_FLAG_FATHER_SPOUSE','');
        relatedPersonDetailMap.put('R_FATHER_SPOUSE_NAME_PREFIX','');
        relatedPersonDetailMap.put('R_FATHER_SPOUSE_FNAME','');
        relatedPersonDetailMap.put('R_FATHER_SPOUSE_MNAME','');
        relatedPersonDetailMap.put('R_FATHER_SPOUSE_LNAME','');
        relatedPersonDetailMap.put('R_MOTHER_NAME_PREFIX','');
        relatedPersonDetailMap.put('R_MOTHER_FNAME','');
        relatedPersonDetailMap.put('R_MOTHER_MNAME','');
        relatedPersonDetailMap.put('R_MOTHER_LNAME','');
        relatedPersonDetailMap.put('R_DOB','');
        relatedPersonDetailMap.put('R_GENDER','');
        relatedPersonDetailMap.put('R_PAN_FORM60','');
        relatedPersonDetailMap.put('R_AADHAR','');
        relatedPersonDetailMap.put('R_VOTERID','');
        relatedPersonDetailMap.put('R_NREGA_JCARD','');
        relatedPersonDetailMap.put('R_PASSPORT','');
        relatedPersonDetailMap.put('R_DRIVING_LICENCE','');
        relatedPersonDetailMap.put('R_NPR_LTTER','');
        relatedPersonDetailMap.put('R_EKYC_AUTH','');
        relatedPersonDetailMap.put('R_OFF_VERIFICATION_AADHAR','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_LINE1','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_LINE2','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_LINE3','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_C_T_V','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_DISTRICT','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_PINCODE','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_STATE','');
        relatedPersonDetailMap.put('R_POI_POA_ADDR_COUNTRY','');
        relatedPersonDetailMap.put('R_PROOF_POI_POA','');
        relatedPersonDetailMap.put('R_FLAG_POI_POA_ADDR_SAME_CURR_ADDR','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_LINE1','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_LINE2','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_LINE3','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_C_T_V','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_DISTRICT','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_STATE','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_COUNTRY','');
        relatedPersonDetailMap.put('R_CURRENT_ADDR_PINCODE','');
        relatedPersonDetailMap.put('R_PROOF_CURRENT_ADDR','');
        relatedPersonDetailMap.put('R_RESI_TEL_NO_STD','');
        relatedPersonDetailMap.put('R_RESI_TEL_NO','');
        relatedPersonDetailMap.put('R_OFFICE_TEL_NO_STD','');
        relatedPersonDetailMap.put('R_OFFICE_TEL_NO','');
        relatedPersonDetailMap.put('R_MOBILE_ISD','');
        relatedPersonDetailMap.put('R_MOBILE_NO','');
        relatedPersonDetailMap.put('R_TYPE_OF_DOC_SUBMITTED','');
        relatedPersonDetailMap.put('R_PERSON_TYPE_OTHER_DESC','');
        relatedPersonDetailMap.put('R_SELF_DECLARATION','');
        
        return relatedPersonDetailMap;
    }
    
    public class CKYCResponseWrapper {
        public String Data_Error;
    }
}