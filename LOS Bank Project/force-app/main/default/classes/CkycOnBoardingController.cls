public without sharing class CkycOnBoardingController {

    public static Map<String, String> uiLabelToDocMasterNameMap;
    public static Map<String, String> labelTosearchCategoryMap;
    public static String customMetadataType;

    public List<Document_Checklist__c> getDocumentCheckLst(String applcantId, List<String> documentMasterNameLst) {
        List<Document_Checklist__c> docCheckList = [SELECT id, Document_Number__c, Document_Master__c, Document_Master__r.Document_Name__c
                                                     FROM Document_Checklist__c
                                                     WHERE (Applicant__c =: applcantId 
                                                     AND Document_Master__r.Document_Name__c IN :documentMasterNameLst)
                                                     WITH SECURITY_ENFORCED];

        return docCheckList;
    }

    public Static List<Document_Checklist__c> getDocumentCheckLst(List<String> documentMasterNameLst) {
        List<Document_Checklist__c> docCheckList = [SELECT id, Document_Number__c, Document_Master__c, Document_Master__r.Document_Name__c
                                                     FROM Document_Checklist__c
                                                     WHERE (Document_Master__r.Document_Name__c IN :documentMasterNameLst)
                                                     WITH SECURITY_ENFORCED];

        return docCheckList;
    }

    public Static List<Document_Master__c> getDocumentMaster(List<String> documentMasterNameLst) {
        List<Document_Master__c> docMaster = [SELECT id, Document_Name__c
                                                     FROM Document_Master__c
                                                     WHERE Document_Name__c IN :documentMasterNameLst
                                                     WITH SECURITY_ENFORCED];

        return docMaster;
    }

    @AuraEnabled
    public static List<Applicant__c> getApplicant(String applcntId) {
        List<Applicant__c> applicantList = [SELECT Id, Customer_Type__c, Dob__c, Gender__c, First_Name__c, Middle_Name__c, Last_Name__c, KYC_Status__c
                                            FROM Applicant__c WHERE Id =:applcntId WITH SECURITY_ENFORCED];
        
        return applicantList;
    }

    public static List<Display_Data__mdt> getMetadataRecord(String rType){
        List<Display_Data__mdt> dispData = [SELECT Id, DeveloperName, MasterLabel, Display_on_UI__c, JSON_Key__c, API_Name__c,Order__c
                                            FROM Display_Data__mdt 
                                            WHERE Type__c =: rType WITH SECURITY_ENFORCED 
                                            ORDER BY Order__c asc];
        return dispData;
    }

    @AuraEnabled
    public static String ckycCallOut(String applicantId, String ckycSearch, String searchCategory, String customerType, String docMasterName, String dob ) {
        String respBody;

        String masterRecord = '';
        if(customerType == 'Individual') {
            masterRecord = 'CKYC Authentication';
            customMetadataType = 'CKYC'; 
        }
        else if(customerType == 'Non Individual'){
            masterRecord = 'CKYC Non Individual Authentication';
            customMetadataType = 'CKYC Non Individual'; 
        }
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        
        String requestBody = generateRequest(applicantId, ckycSearch, searchCategory, docMasterName, dob);

        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        respBody = calloutResponseWrapper.response;
        system.debug('response--> '+respBody);
        return respBody;
    }

    public static String generateRequest(String applicantId, String ckycSearch, String searchCategory, String docMasterName, String dob){

        List<Applicant__c> applcLst = getApplicant(applicantId);
        String firstName            = String.isNotEmpty(applcLst[0].First_Name__c) ? applcLst[0].First_Name__c : '';
        String middleName           = String.isNotEmpty(applcLst[0].Middle_Name__c) ? applcLst[0].Middle_Name__c : '';
        String lastName             = String.isNotEmpty(applcLst[0].Last_Name__c) ? applcLst[0].Last_Name__c : '';
        String fullName             = firstName + middleName + lastName;

        String gender = applcLst[0].Gender__c;
        String customerType = applcLst[0].Customer_Type__c;

        CkycSearchRequestWrapper requestWrapper = new CkycSearchRequestWrapper();
        requestWrapper.SearchCategory = searchCategory;    

        if(docMasterName != 'Aadhaar Card') {
            requestWrapper.RequestId = IntegrationUtility.getReferenceId();       
            requestWrapper.Channel = Label.CKYC_Channel;     
            requestWrapper.Searchinput = ckycSearch;
            
        }
        else if(docMasterName == 'Aadhaar Card') {      
            requestWrapper.Name = fullName;
            requestWrapper.DOB  = dob;
            requestWrapper.Gender = String.isNotBlank(initGenderMap2().get(gender) ) ? initGenderMap2().get(gender)  : '';
            requestWrapper.Searchinput = ckycSearch.right(4);
        }
        String req = JSON.serialize(requestWrapper, true); 
        return req;
    }

    public static void initMap() {
        uiLabelToDocMasterNameMap = new Map<String, String>{
            'NPR document'     => 'NPR',
            'NREGA document'   => 'NREGA',
            'Voter ID Card'    => 'VoterId',
            'Passport'         => 'Passport',
            'Driving Licence'  => 'Driving Licence',
            'Pan Card/Form 60' => 'Pan Card',
            'CKYC document'    => 'CKYC',
            'Aadhaar Card'     => 'Aadhaar'
        };
    }

    public static void initMapOfSearchCategory() {
        labelTosearchCategoryMap = new Map<String, String>{
            'NREGA document'   => 'F',
            'Voter ID Card'    => 'B',
            'Passport'         => 'A',
            'Driving Licence'  => 'D',
            'Pan Card/Form 60' => 'C',
            'CKYC document'    => 'Z',
            'Aadhaar Card'     => 'E'
        };
    }

    public static Map<String, String> identityMasterMap() {
        return new Map<String, String>{
            'A'  => 'Passport',
            'B'  => 'Voter ID Card',
            'C'  => 'Pan Card/Form 60',
            'D'  => 'Driving Licence',
            'E'  => 'Aadhaar Card',
            'F'  => 'NREGA document',
            'G'  => 'NPR document'
        };
    }

    public static Map<String, String> getDocumentMasterMap() {
        return new Map<String, String>{
            '02'   => 'Customer Image',
            '05'  => 'Passport',
            '07'  => 'Voter ID Card',
            '03'  => 'Pan Card/Form 60',
            '06'  => 'Driving Licence',
            '04'  => 'Aadhaar Card',
            '08'  => 'NREGA document',
            '35'  => 'NPR document'
        };
    }

    public Static Map<String, String> initGenderMap() {
        return new Map<String, String>{
            'M' => 'Male',
            'F'  => 'Female',
            'T'  => 'Transgender'
          };
    }

    public Static Map<String, String> initGenderMap2() {
        return new Map<String, String>{
            'Male' => 'M',
            'Female'  => 'F',
            'Transgender'  => 'T'
          };
    }

    @AuraEnabled
    public static List<PopulateCkycOptionsWrapper> getCkycOptions(String applcntId){

        initMap();
        initMapOfSearchCategory();

        CkycOnBoardingController mainObj   = new CkycOnBoardingController();
        List<String> documentMasterNameLst = new List<String>{'NPR document','NREGA document','Voter ID Card','Passport','Driving Licence', 'Pan Card/Form 60', 'CKYC document', 'Aadhaar Card'};                                                     

        List<PopulateCkycOptionsWrapper> ckycOptionsWrapperLst = new List<PopulateCkycOptionsWrapper>();
        List<Document_Checklist__c> documentCheckLst           = mainObj.getDocumentCheckLst(applcntId, documentMasterNameLst); 
        
        for(Document_Checklist__c docCheck : documentCheckLst) {
            if(String.isNotBlank(docCheck.Document_Number__c) && String.isNotBlank(docCheck.Document_Master__c)) {
                PopulateCkycOptionsWrapper ckycOptionsWrapperObj   = new PopulateCkycOptionsWrapper();
                populateckycOptionsWrapperObj(docCheck, ckycOptionsWrapperObj, applcntId);
                ckycOptionsWrapperLst.add(ckycOptionsWrapperObj);
            }
        }
        return ckycOptionsWrapperLst;
    }

    public static void populateckycOptionsWrapperObj(Document_Checklist__c docCheck, PopulateCkycOptionsWrapper ckycOptionsWrapperObj, String applcntId){
     
        String docMasterName                    = docCheck.Document_Master__r.Document_Name__c;
        String uiLabel                          = uiLabelToDocMasterNameMap.get(docMasterName);
        String searchCateg                      = labelTosearchCategoryMap.get(docMasterName);

        ckycOptionsWrapperObj.label             = uiLabel;
        ckycOptionsWrapperObj.value             = docCheck.Id;
        ckycOptionsWrapperObj.docMasterName     = docMasterName;
    /*    if(docMasterName == 'Aadhaar Card') {
            ckycOptionsWrapperObj.docNumber     = docCheck.Document_Number__c; //   AadharTokenUtil.getAddharNumberViaToken(applcntId,'')
        }
        else { */
            ckycOptionsWrapperObj.docNumber     = docCheck.Document_Number__c;
       // }    
        ckycOptionsWrapperObj.searchCategory    = searchCateg;
    }

    @AuraEnabled
    public static UIResponse searchCkycResult(String applcntId, String searchValue, String searchCategory, String docMasterName, String dob){
        List<Applicant__c> applcntLst = getApplicant(applcntId);
        String customerType           = applcntLst[0].Customer_Type__c;
        String responseSearc          = ckycCallOut(applcntId, searchValue, searchCategory, customerType, docMasterName, dob);     
        
        if(String.isNotBlank(responseSearc)) {
            UIResponse uiResponsseObj                  = new UIResponse();
            CkycSearchResponseWrapper responseWrappObj = (CkycSearchResponseWrapper) System.JSON.deserialize(responseSearc, CkycSearchResponseWrapper.class);
            uiResponsseObj.metadata                    = new List<Sobject>();
            uiResponsseObj.metadata                    = getMetadataRecord(customMetadataType);
            uiResponsseObj.Response                    = responseWrappObj;
            return uiResponsseObj;
        }
        return null;
    }

    @AuraEnabled
    public Static String updatAndCallDownApi(Applicant__c applData, String docNum, String docMasterName, String dob) {

        String applcntId = applData.Id;
        List<Applicant__c> applcntLst = getApplicant(applcntId);
        String customerType           = applcntLst[0].Customer_Type__c;
        applcntLst[0].KYC_Status__c   = 'Complete';
        String ckycStatus             = applcntLst[0].KYC_Status__c;

        CkycDownloadController ckycDownloadOBj                   = new CkycDownloadController(customerType);
        CkycDownloadController.DownloasUiResponse downloadUiResp = ckycDownloadOBj.downloadCkycResult(docNum, dob, applcntId, customerType);
        system.debug('downloadUiResp '+JSON.serialize(downloadUiResp));
        CkycOnBoardingController mainObj   = new CkycOnBoardingController();

        if (Schema.sObjectType.Applicant__c.isUpdateable()) {
            update applData;
        }

        List<Document_Checklist__c> documentCheckLst = mainObj.getDocumentCheckLst(applcntId, new List<String>{docMasterName});

        if(documentCheckLst.size() > 0) {
            if (Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
                documentCheckLst[0].Document_Number__c = docNum;
                update documentCheckLst;
            }
        }
        String messag = downloadUiResp.message;

        if(applcntLst.size() > 0) {
            update applcntLst;
        }
        if(messag != 'Not Found.') {
            parseDownloadUiResp(downloadUiResp, applcntId, customerType);
        }
        else if(messag == 'Not Found.') {
            return messag;
        }

        if(ckycStatus == 'Complete') {
            return 'Verified';
        }
        return 'Success';

    }

    public Static Map<String, String> initConsType() {
        return new Map<String, String>{
            '01' => 'Individual',
            'A'  => 'Sole Proprietary',
            'B'  => 'Partnership Firms',
            'E'  => 'Public Limited',
            'D'  => 'Private Limited',
            'H'  => 'Trust',
            'C'  => 'HUF',
            'F'  => 'Society',
            'J'  => 'Limited Liability Partnership',
            'G'  => 'AOP'
          };
    }

    public static Date setStringToDateFormat(String myDate) {
        String[] strDate = myDate.split('-');
        Integer myIntDate = integer.valueOf(strDate[0]);
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);

        return d;
    }

    public Static void populateKycFldsOfApplcnt(CkycDownloadController.Identitydetails identDetail, Applicant__c applcnt) {
        if(identDetail.IDENT_TYPE == 'A') {
            applcnt.Passport_Number__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'B') {
            applcnt.Voter_Id__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'C') {
            applcnt.PAN__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'D') {
            applcnt.Driving_License_Id__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'E') {
            applcnt.Aadhaar_Number__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'F') {
            applcnt.NREGA__c = identDetail.IDENT_NUM;
        }
        else if(identDetail.IDENT_TYPE == 'G') {
            applcnt.NPR__c = identDetail.IDENT_NUM;
        }
    }

 /*   public Static Map<String, Document_Master__c> getMapOfDocNameVsDocMstrRec() {
        Map<String, Document_Master__c> mapOfDocNameVsDocMstrRec = new Map<String, Document_Master__c>();
        List<Document_Master__c> docMasterList = [SELECT id, Document_Name__c 
                                                 FROM Document_Master__c 
                                                 WITH SECURITY_ENFORCED];

        for(Document_Master__c docMastrRec : docMasterList) {
            mapOfDocNameVsDocMstrRec.put(docMastrRec.Document_Name__c, docMastrRec);
        }
        return mapOfDocNameVsDocMstrRec;
    }   */

    public Static void parseDownloadUiResp(CkycDownloadController.DownloasUiResponse downloadUiResp, String applcntId, String customerType) {
        String message = downloadUiResp.message;
        String imgData = '';
        Applicant__c applcnt = new Applicant__c();
        applcnt.Id           = applcntId;
        CkycOnBoardingController mainObj2   = new CkycOnBoardingController();

        if(message != 'Not Found.') {
            CkycDownloadController.DownloadResponseWrapper downloadResp = downloadUiResp.Response;
            system.debug('response- '+downloadResp);
            String downloadRespMessage = downloadResp.message;
            if(String.isNotBlank(downloadRespMessage)) {
                throw new AuraHandledException(downloadRespMessage);
            }
            List<Document_Checklist__c> docCheckListForCustImg = mainObj2.getDocumentCheckLst(applcntId, new List<String>{'Customer Image'});         

            Map<String,String> mapOfDocMstrNameToImgData = new Map<String,String>();
            List<String> docMasterNameLstForKyc = new List<String>();
            for(CkycDownloadController.Imagedetails imgDetail : downloadResp.imageDetails) {
                if(imgDetail.IMAGE_CODE == '02') {
                    imgData = imgDetail.IMAGE_DATA;
                }
                String docMsterName = getDocumentMasterMap().get(imgDetail.IMAGE_CODE);
                docMasterNameLstForKyc.add(docMsterName);
                mapOfDocMstrNameToImgData.put(docMsterName, imgDetail.IMAGE_DATA);
            }
            insertFile('S', 'Image.jpeg', 'Image', docCheckListForCustImg[0].Id, imgData);

            Map<String,String> mapOfDocMstrNameToDocCheckId = new Map<String,String>();
            List<Document_Checklist__c> docCheckListForKycProof = mainObj2.getDocumentCheckLst(applcntId, docMasterNameLstForKyc);
            for(Document_Checklist__c docChecRec : docCheckListForKycProof) {
                String imgDta = mapOfDocMstrNameToImgData.get(docChecRec.Document_Master__r.Document_Name__c);
                mapOfDocMstrNameToDocCheckId.put(docChecRec.Document_Master__r.Document_Name__c, docChecRec.Id);
            }

            if(mapOfDocMstrNameToDocCheckId.keyset().size() > 0) {
                insertKYCProof(mapOfDocMstrNameToDocCheckId, mapOfDocMstrNameToImgData);
            }         

            applcnt.Customer_Name__c = downloadResp.personalDetails.FULLNAME;
            applcnt.Dob__c = setStringToDateFormat(downloadResp.personalDetails.DOB);
            applcnt.Mobile_Number__c = downloadResp.personalDetails.MOB_NUM;
            applcnt.Email__c = downloadResp.personalDetails.EMAIL;

            List<String> docMstrNameListForIdentity = new List<String>();   
            Map<String,String> mapOfDocMstrNameToDocNumber = new Map<String,String>();     
            for(CkycDownloadController.Identitydetails identDetail : downloadResp.identityDetails) {
                populateKycFldsOfApplcnt(identDetail, applcnt);

                String docMsterName = identityMasterMap().get(identDetail.IDENT_TYPE);
                docMstrNameListForIdentity.add(docMsterName);
                mapOfDocMstrNameToDocNumber.put(docMsterName, identDetail.IDENT_NUM);
            }
           
            List<Document_Checklist__c> docCheckListForKyc = getDocumentCheckLst(docMstrNameListForIdentity);
            for(Document_Checklist__c docChecRec : docCheckListForKyc) {
                String docMasterName = docChecRec.Document_Master__r.Document_Name__c;
                docChecRec.Document_Number__c    = mapOfDocMstrNameToDocNumber.get(docMasterName);
            }

            if (Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
                update docCheckListForKyc;
            }

            List<Address__c> addressList = new List<Address__c>();
            Address__c corressAddress = new Address__c();
            corressAddress.Applicant__c = applcntId;
            corressAddress.Address_Type__c = 'Touch Point';
            corressAddress.Address_Line_1__c = downloadResp.personalDetails.CORRES_LINE1;
            corressAddress.Address_Line_2__c = downloadResp.personalDetails.CORRES_LINE2;
            corressAddress.Address_Line_3__c = downloadResp.personalDetails.CORRES_LINE3;
            corressAddress.City__c           = downloadResp.personalDetails.CORRES_CITY;
            corressAddress.District__c       = downloadResp.personalDetails.CORRES_DIST;
            corressAddress.State__c          = downloadResp.personalDetails.CORRES_STATE;
            corressAddress.Pincode__c        = downloadResp.personalDetails.CORRES_PIN;
            addressList.add(corressAddress);

            Address__c permanentAddress = new Address__c();
            permanentAddress.Applicant__c = applcntId;
            permanentAddress.Address_Type__c = 'Permanent';
            permanentAddress.Address_Line_1__c = downloadResp.personalDetails.PERM_LINE1;
            permanentAddress.Address_Line_2__c = downloadResp.personalDetails.PERM_LINE2;
            permanentAddress.Address_Line_3__c = downloadResp.personalDetails.PERM_LINE3;
            permanentAddress.City__c           = downloadResp.personalDetails.PERM_CITY;
            permanentAddress.District__c       = downloadResp.personalDetails.PERM_DIST;
            permanentAddress.State__c          = downloadResp.personalDetails.PERM_STATE;
            permanentAddress.Pincode__c        = downloadResp.personalDetails.PERM_PIN;
            addressList.add(permanentAddress);

            if (Schema.sObjectType.Address__c.isCreateable()) {
                insert addressList;
            }

            Applicant_Financials_Details__c applcntFinancial = new Applicant_Financials_Details__c();
            applcntFinancial.Applicant__c = applcntId;
            applcntFinancial.Occupation__c = downloadResp.personalDetails.OCCUPATION;

            if (Schema.sObjectType.Applicant_Financials_Details__c.isCreateable()) {
                insert applcntFinancial;
            }

            if(customerType == 'Individual') {
                applcnt.Gender__c         = initGenderMap().get(downloadResp.personalDetails.GENDER);
                applcnt.Father_Name__c    = downloadResp.personalDetails.FATHER_FULLNAME;
                applcnt.Mother_Name__c    = downloadResp.personalDetails.MOTHER_FULLNAME;
                applcnt.Marital_Status__c = downloadResp.personalDetails.MARITAL_STATUS;
            }
            if(customerType == 'Non Individual') {
                applcnt.Constitution_Type__c  = initConsType().get(downloadResp.personalDetails.CONSTI_TYPE);

                Address__c officeAddress = new Address__c();
                officeAddress.Applicant__c = applcntId;
                officeAddress.Address_Type__c = 'Office';
                officeAddress.Office_Number__c = downloadResp.personalDetails.OFF_TEL_NUM;

                if (Schema.sObjectType.Address__c.isCreateable()) {
                    insert officeAddress;
                }
            }
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                update applcnt;
            }
        }     
    }

    public Static void insertFile(String currLocation, String pathOnclient, String title, String linkedEntityId, String imgData) {

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = currLocation; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = pathOnclient; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = title; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(imgData); // converting your binary string to Blob
        insert conVer;    //Insert ContentVersion


        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = linkedEntityId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
    }

    public Static void insertKYCProof(Map<String,String> mapOfDocMstrNameToDocCheckId, Map<String,String> mapOfDocMstrNameToImgData) {
        
        List<ContentVersion> contVersionLst = new List<ContentVersion>();
        for(String docMstrNme : mapOfDocMstrNameToImgData.keyset()) {
            String imgDta = mapOfDocMstrNameToImgData.get(docMstrNme);
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'Image.jpg'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Image'; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(imgDta); // converting your binary string to Blob
            conVer.Type__c    = docMstrNme;
            contVersionLst.add(conVer);
        }
        if(contVersionLst.size() > 0) {
            insert contVersionLst;
        }      

        List<String> contVerIdLst = new List<String>();
        for(ContentVersion contVers : contVersionLst) {
            contVerIdLst.add(contVers.Id);
        }

        Map<String,String> mapOfDocMsterNmeToContentDocId = new Map<String,String>();
        List<ContentVersion> conVerList = [SELECT Type__c, ContentDocumentId FROM ContentVersion WHERE Id IN :contVerIdLst WITH SECURITY_ENFORCED];

        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        for(ContentVersion contVersRec : conVerList) {
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = mapOfDocMstrNameToDocCheckId.get(contVersRec.Type__c); // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = contVersRec.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            conDocLinkList.add(conDocLink);
        }
        if(conDocLinkList.size() > 0) {
            insert conDocLinkList;
        }     
    }

    public class PopulateCkycOptionsWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String docMasterName;
        @AuraEnabled public String docNumber;
        @AuraEnabled public String searchCategory;
    }

    public class CkycSearchRequestWrapper {
        @AuraEnabled public String RequestId;
        @AuraEnabled public String SearchCategory;
        @AuraEnabled public String Channel;
        @AuraEnabled public String Searchinput;
        @AuraEnabled public String Name;
        @AuraEnabled public String DOB;
        @AuraEnabled public String Gender;
    }

    public class UIResponse{
      //  @AuraEnabled public CombineSearchAndDownloadResp Response;
        @AuraEnabled public CkycSearchResponseWrapper Response;
        @AuraEnabled public List<Sobject> metadata;
        @AuraEnabled public String message;
    }

  /*  public class CombineSearchAndDownloadResp{
        @AuraEnabled public CkycSearchResponseWrapper responseSearch;
        @AuraEnabled public DownloadResponseWrapper   responseDownload;
    }  */

    public class CkycSearchResponseWrapper {
        @AuraEnabled public List<CkycDataInnerObj> ckyc_data;
        @AuraEnabled public String message;
        @AuraEnabled public String error_cd;
        
    }

    public class CkycDataInnerObj {
        @AuraEnabled public String kyc_date;
        @AuraEnabled public String image;
        @AuraEnabled public String full_name;
        @AuraEnabled public String father_name;
        @AuraEnabled public String DOB;
        @AuraEnabled public String Gender;
        @AuraEnabled public String age;
        @AuraEnabled public String update_date;
        @AuraEnabled public String ckyc_number;
        @AuraEnabled public String image_type;
        @AuraEnabled public String Constitution_type;
        @AuraEnabled public String Place_of_incorporation;
    }
}