/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class LOSDocumentUploadController {


  /**
  * @description 
  * @author Harshit Goyal | Salesforce | 12-15-2022 
  * @param base64 
  * @param filename 
  * @param recordId 
  * @param applicantId
  * @return String 
  **/
   /*
    public static compressUploadFile(){
        DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData= DocumentCompressAPI.getCompresssedDocument(base64,filename,applicantId,loanId);
        ContentVersion cv = new ContentVersion();
        if(wrapData.OutputStatus == System.Label.LOS_DocCompress_Success){
            cv.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
        }else{
            cv.VersionData = EncodingUtil.base64Decode(base64);
        }
        cv.Title = filename;
        cv.PathOnClient = filename;
        if(Schema.sObjectType.ContentVersion.isCreateable()){
          insert cv;
        }
    }
    
   @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId,String applicantId,String loanId, String fieldInvestId) {
    try {
        if (fieldInvestId)
        compressUploadFile ();
        /*
         * DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData= DocumentCompressAPI.getCompresssedDocument(base64,filename,applicantId,loanId);
        ContentVersion cv = new ContentVersion();
        if(wrapData.OutputStatus == System.Label.LOS_DocCompress_Success){
            cv.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
        }else{
            cv.VersionData = EncodingUtil.base64Decode(base64);
        }
        cv.Title = filename;
        cv.PathOnClient = filename;
        if(Schema.sObjectType.ContentVersion.isCreateable()){
          insert cv;
        }
        * /
        if (cv.Id == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
          SELECT ContentDocumentId 
          FROM ContentVersion 
          WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
          insert cdl;
        }
        if (cv == null || cdl == null) { return null; }
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.successRecordId = cv.Id;
        return JSON.serialize(result);
      }catch(DMLException objException) {
          System.debug(objException);
          if(String.isNotBlank(loanId)){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
          }else{
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
          }
          
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = false;
          return JSON.serialize(result);
        }
  }
    */
    
  @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId,String applicantId,String loanId) {
    try {
        DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData;
        if(!Test.isRunningTest()){
           wrapData= DocumentCompressAPI.getCompresssedDocument(base64,filename,applicantId,loanId);
        }else{
            wrapData = new DocumentCompressReqResWrapper.LOSDocCompressResWrapper();
        }
        ContentVersion cv = new ContentVersion();
        if(wrapData.OutputStatus == System.Label.LOS_DocCompress_Success){
            cv.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
        }else{
            cv.VersionData = EncodingUtil.base64Decode(base64);
        }
        cv.Title = filename;
        cv.PathOnClient = filename;
        if(Schema.sObjectType.ContentVersion.isCreateable()){
          insert cv;
        }
        if (cv.Id == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
          SELECT ContentDocumentId 
          FROM ContentVersion 
          WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
          insert cdl;
        }
        if (cv == null || cdl == null) { return null; }
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.successRecordId = cv.Id;
        return JSON.serialize(result);
      }catch(DMLException objException) {
          System.debug(objException);
          if(String.isNotBlank(loanId)){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
          }else{
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
          }
          
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = false;
          return JSON.serialize(result);
        }
  }
    
  /**
  * @description 
  * @author Harshit Goyal | Salesforce | 12-13-2022 
  * @param whereClause 
  * @return List<Document_Checklist__c> 
  **/
  @AuraEnabled
  public static String getDocumentChecklist(String applicantId, String docName,String loanId, String fieldInvestId,String collateralId){
    try
    {
        String whereClause ='';
        if(String.isNotBlank(fieldInvestId)){
            whereClause =' WHERE Field_Investigation__c =\''+fieldInvestId +'\' AND Document_Master__r.Name =\''+docName+'\'';
        }
        else if(String.isNotBlank(loanId)){
            whereClause =' WHERE Loan_Application__c=\''+loanId +'\' AND Document_Master__r.Name =\''+docName+'\'';
        }else if(String.isNotBlank(collateralId)){
          whereClause =' WHERE Collateral__c=\''+collateralId +'\' AND Document_Master__r.Name =\''+docName+'\'';
      }else{
            whereClause =' WHERE Applicant__c=\''+applicantId +'\' AND Document_Master__r.Name =\''+docName+'\'';
        }
        
        List<Document_Checklist__c> docChkList =  DocumentChecklistService.getDoucmentChecklist(whereClause);
        system.debug('result '+docChkList);
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.message = '';
        result.docChkList = docChkList;
        return JSON.serialize(result);
    }
    catch(Exception objException){
        Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        system.debug('exception '+objException.getMessage());
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = objException.getMessage();
        result.docChkList = null;
        return JSON.serialize(result);
    }
    
    }

    Public class ResultWrapper{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String successRecordId{get;set;}
        @AuraEnabled
        public List<Document_Checklist__c> docChkList{get;set;}
        @AuraEnabled
        public String documentNumber{get;set;}
        @AuraEnabled
        public Map<String,String> ocrResultMap{get;set;}
        @AuraEnabled
        public Document_Checklist__c docChkRecord{get;set;}
        @AuraEnabled
        public Applicant__c applicantRecord{get;set;}
        @AuraEnabled
        public Boolean isAadhar{get;set;}
        @AuraEnabled
        public Boolean polarNeeded{get;set;}
        @AuraEnabled
        public String fileSize{get;set;}
        public List<ResponseListWrapper> reponseWrapper {get;set;}

    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-26-2022 
    * @param documentId 
    * @param documentType 
    * @param applicantId 
    * @return String 
    **/
    @AuraEnabled
    public static String getOCRData(String documentId,String documentType,String applicantId){
      try
      {
        Map<String,String> ocrResult = new Map<String,String>();
       
        List<ContentDocumentLink> conLinkList = [SELECT Id,ContentDocument.LatestPublishedVersionId,ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId =:documentId WITH SECURITY_ENFORCED Order By ContentDocument.CreatedDate DESC LIMIT 1];
        if(conLinkList.isEmpty()){
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = false;
          result.message = 'File upload pending!';
          result.documentNumber = null;
          return JSON.serialize(result);
        }
        ContentDocumentLink conLink = [SELECT Id,ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId =:documentId WITH SECURITY_ENFORCED Order By  ContentDocument.CreatedDate DESC LIMIT 1];
        ContentVersion contentVersions = [SELECT Id,VersionData from ContentVersion WHERE ContentDocumentId =: conLinkList[0].ContentDocumentId LIMIT 1];
        //System.debug('Base64Data'+EncodingUtil.base64Encode(contentVersions.VersionData));
        Document_Checklist__c docChkRecord = new Document_Checklist__c();
        docChkRecord.Id = documentId;
        Applicant__c applicantRecord = new Applicant__c();
        applicantRecord.Id = applicantId;
        String aadharNumber='';
        String strName = '';
        String strDob = '';
        String strYob = '';
        String strPhone = '';
        String strDobYob = '';
        String strAddress = '';
        String strGender = '';
        String strFatherName = '';
        String strMotherName = '';
        String strBuilding = '';
        String strCity = '';
        String strDistrict = '';
        String strPin = '';
        String strFloor = '';
        String strHouse = '';
        String strLocality = '';
        String strState = '';
        String strStreet = '';
        String strComplex = '';
        String strLandmark = '';
        String strUntagged = '';
        Boolean isInvalidDoc = false;
        String documentBase64 = '';

        //OCRAadharResponseWrapper wrapperData = LOSOCRIntegrationCtr.initiateAdharOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'AADHAAR');
        //OCRVoterIdResponseWrapper wrapperData = LOSOCRIntegrationCtr.initiateVoterIdOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'VOTER');
        
        //OCRPanCardResponseWrapper wrapperData = LOSOCRIntegrationCtr.initiatePanCardOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'PAN');
        //OCRPassportResponseWrapper wrapperData = LOSOCRIntegrationCtr.initiatePassportOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'PASSPORT');
        //OCRDLResponseWrapper wrapperData = LOSOCRIntegrationCtr.initiateDLOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'DL');
        switch on documentType {
          when 'AADHAAR' {
            OCRAadharResponseWrapper aadharWrapper = LOSOCRIntegrationCtr.initiateAdharOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'AADHAAR');
            // Validate for error/Failure
              if(aadharWrapper.statusCode != 101 && aadharWrapper.ServiceExecutionStatus == 'Error') {
                throw new CustomException('API Error: Response: ' +  aadharWrapper.statusCode);
              }
            //OCRAadharResponseWrapper.OcrData = aadharWrapper
            if(aadharWrapper.result.documents != null){
              for(OCRAadharResponseWrapper.Documents  pageRecord : aadharWrapper.result.documents){
                if(pageRecord.subType =='FRONT_TOP'){
                  
                  aadharNumber = String.isNotBlank(aadharNumber) ? aadharNumber : pageRecord?.OcrData?.aadhaar?.value;
                  strName = String.isNotBlank(strName) ? strName : pageRecord?.OcrData?.name?.value;
                  strPhone = String.isNotBlank(strPhone) ? strPhone : pageRecord?.OcrData?.phone?.value;
                  strAddress = String.isNotBlank(strAddress) ? strAddress : pageRecord?.OcrData?.address?.value;

                  strDob = String.isNotBlank(strDob) ? strDob : pageRecord?.OcrData?.dob?.value;
                  strYob = String.isNotBlank(strYob) ? strYob : pageRecord?.OcrData?.yob?.value;
                  strDobYob = String.isNotBlank(strDob) ? strDob : String.isNotBlank(strYob) ? strYob : '';
                  strFatherName = String.isNotBlank(strFatherName) ? strFatherName : pageRecord?.OcrData?.father?.value;
                  strMotherName = String.isNotBlank(strFatherName) ? strFatherName : pageRecord?.OcrData?.mother?.value;

                  strBuilding = String.isNotBlank(strBuilding) ? strBuilding : pageRecord?.additionalDetails?.addressSplit?.building;
                  strCity = String.isNotBlank(strCity) ? strCity : pageRecord?.additionalDetails?.addressSplit?.city;
                  strDistrict = String.isNotBlank(strDistrict) ? strDistrict : pageRecord?.additionalDetails?.addressSplit?.district;
                  strPin = String.isNotBlank(strPin) ? strPin : pageRecord?.additionalDetails?.addressSplit?.pin;
                  strFloor = String.isNotBlank(strFloor) ? strFloor : pageRecord?.additionalDetails?.addressSplit?.floor;
                  strHouse = String.isNotBlank(strHouse) ? strHouse : pageRecord?.additionalDetails?.addressSplit?.house;
                  strLocality = String.isNotBlank(strLocality) ? strLocality : pageRecord?.additionalDetails?.addressSplit?.locality;
                  strState = String.isNotBlank(strState) ? strState : pageRecord?.additionalDetails?.addressSplit?.state;
                  strStreet = String.isNotBlank(strStreet) ? strStreet : pageRecord?.additionalDetails?.addressSplit?.street;
                  strComplex = String.isNotBlank(strComplex) ? strComplex : pageRecord?.additionalDetails?.addressSplit?.complex;
                  strLandmark = String.isNotBlank(strLandmark) ? strLandmark : pageRecord?.additionalDetails?.addressSplit?.landmark;
                  strUntagged = String.isNotBlank(strUntagged) ? strUntagged : pageRecord?.additionalDetails?.addressSplit?.untagged;
                  documentBase64 = String.isNotBlank(documentBase64) ? documentBase64 : pageRecord?.documentBase64;
                }else if(pageRecord.subType =='FRONT_BOTTOM'){

                    aadharNumber = String.isNotBlank(aadharNumber) ? aadharNumber : pageRecord?.OcrData?.aadhaar?.value;
                    strName = String.isNotBlank(strName) ? strName : pageRecord?.OcrData?.name?.value;
                    strPhone = String.isNotBlank(strPhone) ? strPhone : pageRecord?.OcrData?.phone?.value;
                    strAddress = String.isNotBlank(strAddress) ? strAddress : pageRecord?.OcrData?.address?.value;
                    

                    strDob = String.isNotBlank(strDob) ? strDob : pageRecord?.OcrData?.dob?.value;
                    strYob = String.isNotBlank(strYob) ? strYob : pageRecord?.OcrData?.yob?.value;
                    strDobYob = String.isNotBlank(strDob) ? strDob : String.isNotBlank(strYob) ? strYob : '';
                    strGender = pageRecord?.OcrData?.gender?.value;
                    strFatherName = String.isNotBlank(strFatherName) ? strFatherName : pageRecord?.OcrData?.father?.value;
                    strMotherName = String.isNotBlank(strFatherName) ? strFatherName : pageRecord?.OcrData?.mother?.value;

                    strBuilding = String.isNotBlank(strBuilding) ? strBuilding : pageRecord?.additionalDetails?.addressSplit?.building;
                    strCity = String.isNotBlank(strCity) ? strCity : pageRecord?.additionalDetails?.addressSplit?.city;
                    strDistrict = String.isNotBlank(strDistrict) ? strDistrict : pageRecord?.additionalDetails?.addressSplit?.district;
                    strPin = String.isNotBlank(strPin) ? strPin : pageRecord?.additionalDetails?.addressSplit?.pin;
                    strFloor = String.isNotBlank(strFloor) ? strFloor : pageRecord?.additionalDetails?.addressSplit?.floor;
                    strHouse = String.isNotBlank(strHouse) ? strHouse : pageRecord?.additionalDetails?.addressSplit?.house;
                    strLocality = String.isNotBlank(strLocality) ? strLocality : pageRecord?.additionalDetails?.addressSplit?.locality;
                    strState = String.isNotBlank(strState) ? strState : pageRecord?.additionalDetails?.addressSplit?.state;
                    strStreet = String.isNotBlank(strStreet) ? strStreet : pageRecord?.additionalDetails?.addressSplit?.street;
                    strComplex = String.isNotBlank(strComplex) ? strComplex : pageRecord?.additionalDetails?.addressSplit?.complex;
                    strLandmark = String.isNotBlank(strLandmark) ? strLandmark : pageRecord?.additionalDetails?.addressSplit?.landmark;
                    strUntagged = String.isNotBlank(strUntagged) ? strUntagged : pageRecord?.additionalDetails?.addressSplit?.untagged;
                    documentBase64 = String.isNotBlank(documentBase64) ? documentBase64 : pageRecord?.documentBase64;

                }else if(pageRecord.subType =='BACK'){
                    ocrResult.put('Pin Code',pageRecord?.OcrData?.pin?.value);
                    strAddress = String.isNotBlank(strAddress) ? strAddress : pageRecord?.OcrData?.address?.value;
                    strBuilding = String.isNotBlank(strBuilding) ? strBuilding : pageRecord?.additionalDetails?.addressSplit?.building;
                    strCity = String.isNotBlank(strCity) ? strCity : pageRecord?.additionalDetails?.addressSplit?.city;
                    strDistrict = String.isNotBlank(strDistrict) ? strDistrict : pageRecord?.additionalDetails?.addressSplit?.district;
                    strPin = String.isNotBlank(strPin) ? strPin : pageRecord?.additionalDetails?.addressSplit?.pin;
                    strFloor = String.isNotBlank(strFloor) ? strFloor : pageRecord?.additionalDetails?.addressSplit?.floor;
                    strHouse = String.isNotBlank(strHouse) ? strHouse : pageRecord?.additionalDetails?.addressSplit?.house;
                    strLocality = String.isNotBlank(strLocality) ? strLocality : pageRecord?.additionalDetails?.addressSplit?.locality;
                    strState = String.isNotBlank(strState) ? strState : pageRecord?.additionalDetails?.addressSplit?.state;
                    strStreet = String.isNotBlank(strStreet) ? strStreet : pageRecord?.additionalDetails?.addressSplit?.street;
                    strComplex = String.isNotBlank(strComplex) ? strComplex : pageRecord?.additionalDetails?.addressSplit?.complex;
                    strLandmark = String.isNotBlank(strLandmark) ? strLandmark : pageRecord?.additionalDetails?.addressSplit?.landmark;
                    strUntagged = String.isNotBlank(strUntagged) ? strUntagged : pageRecord?.additionalDetails?.addressSplit?.untagged;
                    documentBase64 = String.isNotBlank(documentBase64) ? documentBase64 : pageRecord?.documentBase64;
                    aadharNumber = String.isNotBlank(aadharNumber) ? aadharNumber : pageRecord?.OcrData?.aadhaar?.value;
                }
                aadharNumber = String.isNotBlank(aadharNumber) ? aadharNumber : '';
                docChkRecord.Document_Number__c = String.isNotBlank(aadharNumber) ? aadharNumber : docChkRecord.Document_Number__c ;
                ocrResult.put('Aadhar Number',aadharNumber);
                ocrResult.put('Name',strName);
                ocrResult.put('Phone',strPhone);
                ocrResult.put('Address',strAddress);
                ocrResult.put('Date of Birth',strDobYob);
                ocrResult.put('Gender',strGender);
                ocrResult.put('Father Name',strFatherName);
                if(String.isNotBlank(strMotherName)){
                  ocrResult.put('Mother Name',strMotherName);
                }
               ocrResult.put('documentBase64',documentBase64);
                
              }
              /*
              * R2-2406 | Commenting this out because the date we get from aadhar ocr is valid for en_IN locale
              if(String.isNotBlank(strdob)){
                List<String> arrayDate = strdob.split('/');
                strdob = arrayDate[1] + '/' + arrayDate[0] + '/' + arrayDate[2];
              }*/
              applicantRecord.Aadhaar_Number__c = String.isNotBlank(aadharNumber) ? aadharNumber : applicantRecord.Aadhaar_Number__c ;
              applicantRecord.Aadhaar_Name__c  = String.isNotBlank(strName) ? strName : '';
              applicantRecord.Mobile_Number__c  = String.isNotBlank(strPhone) ? strPhone : applicantRecord.Mobile_Number__c;
              applicantRecord.Gender__c  = strGender;
              applicantRecord.Dob__c   = String.isNotBlank(strdob) ? Date.parse(strdob) : NULL;
              List<String> lstName = strName.split(' ');
              applicantRecord.Last_Name__c = !lstName.isEmpty() ? lstName.size()>2 ? lstName[2] : lstName.size() > 1 ? lstName[1] : '' : '';
              applicantRecord.Middle_Name__c = !lstName.isEmpty() ? lstName.size()>2 ? lstName[1] : '' : '';
              applicantRecord.First_Name__c = !lstName.isEmpty() ? lstName[0] : '' ;
              applicantRecord.Father_Name__c = String.isNotBlank(strFatherName) ? strFatherName : '';
              
              String strLine1 = (String.isNotBlank(strHouse) ? strHouse + ', ' : '') + (String.isNotBlank(strFloor) ? strFloor + ', ' : '') + (String.isNotBlank(strBuilding) ? strBuilding + ', ' : '') + (String.isNotBlank(strComplex) ? strComplex + ', ' : '') + '~';
              strLine1 = strLine1.replaceAll(', ~','');
              strLine1 = strLine1.replaceAll('~','');
              String strLine2 = (String.isNotBlank(strStreet) ? strStreet + ', ' : '') + (String.isNotBlank(strUntagged) ? strUntagged + ', ' : '') + '~';
              strLine2 = strLine2.replaceAll(', ~','');
              strLine2 = strLine2.replaceAll('~','');
              String strLine3 = (String.isNotBlank(strLandmark) ? strLandmark : '');
              applicantRecord.Aadhaar_Address__c = strLine1 + '~' + strLine2 + '~' + strLine3 + '~' + strCity + '~' + strDistrict + '~' + strPin + '~' + strState;
            }else{
              isInvalidDoc = true;
            }
          }
          when 'VOTER' {
            OCRVoterIdResponseWrapper voterWrapper = LOSOCRIntegrationCtr.initiateVoterIdOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'VOTER');
            if(voterWrapper.result.documents != null){
              String voterId = voterWrapper?.result?.documents[0]?.OcrData?.voterId?.value;
              voterId = String.isNotBlank(voterId) && voterId.contains('/') ? voterId.replaceAll('/','') : voterId;
              docChkRecord.Document_Number__c =voterId;
              applicantRecord.Voter_Id__c = voterId;
              ocrResult.put('Voter Id Number',voterId);
              ocrResult.put('Voter Name',voterWrapper?.result?.documents[0]?.OcrData?.name?.value);
              ocrResult.put('Date of Birth',voterWrapper?.result?.documents[0]?.OcrData?.dob?.value);
              ocrResult.put('Gender',voterWrapper?.result?.documents[0]?.OcrData?.gender?.value);
            }else{
              isInvalidDoc = true;
            }
          }
          when 'PAN' {
            OCRPanCardResponseWrapper panWrapper = LOSOCRIntegrationCtr.initiatePanCardOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'PAN');
            if(panWrapper.result.documents != null){

              docChkRecord.Document_Number__c = panWrapper?.result?.documents[0]?.OcrData?.pan?.value;
              applicantRecord.PAN__c = panWrapper?.result?.documents[0]?.OcrData?.pan?.value;
              ocrResult.put('PAN Number',panWrapper?.result?.documents[0]?.OcrData?.pan?.value);
              ocrResult.put('Name',panWrapper?.result?.documents[0]?.OcrData?.name?.value);
              ocrResult.put('Father Name',panWrapper?.result?.documents[0]?.OcrData?.father?.value);
              ocrResult.put('Date of Birth',panWrapper?.result?.documents[0]?.OcrData?.dob?.value);
            }else{
              isInvalidDoc = true;
            }
          }
          when 'PASSPORT' {
            OCRPassportResponseWrapper passportWrapper = LOSOCRIntegrationCtr.initiatePassportOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'PASSPORT');
            if(passportWrapper.result.documents != null){
              for(OCRPassportResponseWrapper.Documents  pageRecord : passportWrapper.result.documents){
                if(pageRecord.subType =='FRONT'){
                  docChkRecord.Document_Number__c = pageRecord?.OcrData?.passportNumber?.value;
                  applicantRecord.Passport_Number__c = pageRecord?.OcrData?.passportNumber?.value;
                  ocrResult.put('Passport Number',pageRecord?.OcrData?.passportNumber?.value);
                  ocrResult.put('Name',pageRecord?.OcrData?.givenName?.value);
                  ocrResult.put('Country',pageRecord?.OcrData?.countryCode?.value);
                  ocrResult.put('Date of Birth',pageRecord?.OcrData?.dob?.value);
                }else if(pageRecord.subType =='BACK'){
                  ocrResult.put('Fater Name',pageRecord?.OcrData?.father?.value);
                  ocrResult.put('Mother Name',pageRecord?.OcrData?.mother?.value);
                  ocrResult.put('Address',pageRecord?.OcrData?.address?.value);
                  
                }
              }

            }else{
              isInvalidDoc = true;
            }
          }
          when 'DL' {
            OCRDLResponseWrapper dlWrapper = LOSOCRIntegrationCtr.initiateDLOCR(applicantId,EncodingUtil.base64Encode(contentVersions.VersionData),'DL');
            if(dlWrapper.result.documents != null){
              docChkRecord.Document_Number__c = dlWrapper?.result?.documents[0]?.OcrData?.dlNo?.value;
              applicantRecord.Driving_License_Id__c = dlWrapper?.result?.documents[0]?.OcrData?.dlNo?.value;
              ocrResult.put('DL Number',dlWrapper?.result?.documents[0]?.OcrData?.dlNo?.value);
              ocrResult.put('DL Expiry',dlWrapper?.result?.documents[0]?.OcrData?.doe?.value);
              ocrResult.put('Name',dlWrapper?.result?.documents[0]?.OcrData?.name?.value);
              ocrResult.put('Husband/Father Name',dlWrapper?.result?.documents[0]?.OcrData?.relationName?.value);
              ocrResult.put('Date of Birth',dlWrapper?.result?.documents[0]?.OcrData?.dob?.value);

              //system.debug('wrapper Get Result @@@@@'+dlWarpper.get('result.documents[0].OcrData.dob.value'));
            }else{
              isInvalidDoc = true;
            }
          }
          when else {
              System.debug('NO OCR FOUND');
          }
       }
       if(isInvalidDoc){
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = 'Invalid Document Uploaded';
        result.documentNumber = null;
        return JSON.serialize(result);
       }
       //update docChkRecord;
       //update applicantRecord;
       ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.message = '';
        result.ocrResultMap=ocrResult;
        result.docChkRecord = docChkRecord;
        result.successRecordId =  conLinkList[0].ContentDocument.LatestPublishedVersionId;
        result.applicantRecord = applicantRecord;
        if(documentType =='AADHAAR'){
          result.documentNumber = aadharNumber;
          result.isAadhar = true;
        }else{
          result.documentNumber = docChkRecord.Document_Number__c;
          result.isAadhar = false;
        }
        
        return JSON.serialize(result);
      }catch(Exception objException){
          system.debug('Error :: ' + objException);
          system.debug('Error :: ' + objException.getLineNumber());
        Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = objException.getMessage();
        result.documentNumber = null;
        return JSON.serialize(result);
    }
    }
    @AuraEnabled
    public static String updateOCRData(String applicantRec,String documentChkRecord ,Boolean isAadhar,Boolean isOk,String contentVersionId){
      system.debug('applicantRec'+applicantRec);
      system.debug('documentChkRecord'+documentChkRecord);
      system.debug('contentVersionId'+contentVersionId);
      try
      {
        Map<String, Object> applicantDetails = (Map<String, Object>) JSON.deserializeUntyped( applicantRec  );
        Map<String, Object> applicantDetails2 = applicantDetails;
        String documentBase64 = '';
        for(String key : applicantDetails.keySet()){
          if(applicantDetails.get(key) == null || String.isBlank( String.valueOf(applicantDetails.get(key)) )){
            applicantDetails2.remove(key);
          }else if(key == 'documentBase64'){
            documentBase64 = String.valueOf(applicantDetails2.get('documentBase64'));
            applicantDetails2.remove(key);
          }
        }
        Document_Checklist__c documentRecToUpdate = (Document_Checklist__c)JSON.deserialize(documentChkRecord, Document_Checklist__c.class);
        ContentVersion version = [SELECT Id,ContentDocumentId, Title, VersionData FROM ContentVersion Where Id =: contentVersionId];
        ContentVersion versionToInsert = new ContentVersion();
        if(String.isNotBlank(documentBase64)){
          versionToInsert.VersionData = EncodingUtil.base64Decode(documentBase64);
          versionToInsert.Title = version.Title;
          versionToInsert.PathOnClient = version.Title;
        }
       
       

        Applicant__c applicantRecToUpdate = (Applicant__c)JSON.deserialize(JSON.serialize(applicantDetails2), Applicant__c.class);
        system.debug('applicantRecToUpdate'+applicantRecToUpdate);
        system.debug('documentRecToUpdate'+documentRecToUpdate);
        
        Id appId = applicantRecToUpdate.Id;
        List<Address__c> lstAddress = [Select Id, Applicant__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Source__c, Address_Type__c, City__c, District__c, Land_mark__c, Pincode__c, State__c from Address__c where Address_Type__c = 'Permanent' and Applicant__c =: appId ];
        Address__c objAddress = lstAddress != NULL && lstAddress.size()>0 ? lstAddress[0] : new Address__c(Applicant__c = appId);
          
        if(isAadhar){
         // String aadharToken = AadharTokenUtil.getTokenViaAddharNumber(applicantRecToUpdate.Id,applicantRecToUpdate.Aadhaar_Number__c);
         String response = AadharTokenUtil.getTokenViaAddharNumber(applicantRecToUpdate.Id,applicantRecToUpdate.Aadhaar_Number__c);
          IntegrationUtility.ResponseWrapper wrapper = (IntegrationUtility.ResponseWrapper) JSON.deserialize(response,IntegrationUtility.ResponseWrapper.class);
          String aadharToken = wrapper.additionalResponse;
          documentRecToUpdate.Document_Number__c = aadharToken;
          applicantRecToUpdate.Kyc_Status__c = 'Complete';
          if(String.isBlank(aadharToken) || !(aadharToken.length() == 12 || aadharToken.length() == 16)){
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = 'Invalid Aadhaar Number !!';
            return JSON.serialize(result);
          }
          applicantRecToUpdate.Aadhaar_Number__c = String.isNotBlank(aadharToken)  ? aadharToken : applicantRecToUpdate.Aadhaar_Number__c  ;
          if (String.isNotBlank(applicantRecToUpdate.Aadhaar_Address__c)){
            List<String> lstAddressSplit = applicantRecToUpdate.Aadhaar_Address__c.split('~');
            System.debug('lstAddressSplit-->' +lstAddressSplit);
            objAddress.Address_Line_1__c = lstAddressSplit[0];
            objAddress.Address_Line_2__c = lstAddressSplit[1];
            objAddress.Address_Line_3__c = lstAddressSplit[2];
            objAddress.Address_Source__c = 'Aadhaar Card';
            objAddress.Address_Type__c = 'Permanent';
            //objAddress.City__c = lstAddressSplit[3];
            objAddress.City__c = lstAddressSplit[4];
            objAddress.District__c = lstAddressSplit[4];
            objAddress.Pincode__c = lstAddressSplit[5];
            objAddress.State__c = lstAddressSplit.size() >= 7 ? lstAddressSplit[6] : '';
            objAddress.Land_mark__c = lstAddressSplit[2];
          }
        }
       
        delete new ContentDocument(Id = version.ContentDocumentId);
        if(Schema.sObjectType.Applicant__c.isUpdateable()){
          update applicantRecToUpdate;
        }
        if(Schema.sObjectType.Document_Checklist__c.isUpdateable()){
          update documentRecToUpdate;
        }
        if(Schema.sObjectType.Address__c.isUpdateable() && Schema.sObjectType.Address__c.isCreateable() && (objAddress.Pincode__c != 'null' && String.isNotBlank(objAddress.Pincode__c))){ // Added null check for SFAU-5401 - Kunal
          upsert objAddress;
        }

        if(versionToInsert.VersionData != null){
          insert versionToInsert;
          versionToInsert = [SELECT Id,ContentDocumentId FROM ContentVersion Where Id =: versionToInsert.Id];
          ContentDocumentLink cdl = new ContentDocumentLink();
          cdl.ContentDocumentId = versionToInsert.ContentDocumentId;
          cdl.LinkedEntityId = documentRecToUpdate.Id;
          insert cdl;
        }


        
        

        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.message = '';
        return JSON.serialize(result);
      }catch(Exception objException){
        Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = objException.getMessage();
        return JSON.serialize(result);
      }
    }
    @AuraEnabled
    public static String checkUploadDocumentBridgeApp(String docRecordId){
      List<ContentDocumentLink> contentDocLinkList = [SELECT Id,ContentDocument.LatestPublishedVersionId from ContentDocumentLink WHERE LinkedEntityId =: docRecordId AND ContentDocument.LatestPublishedVersion.isActive__c =TRUE WITH SECURITY_ENFORCED];
      //List<ContentDocumentLink> contentDocLinkList = [SELECT Id,ContentDocument.LatestPublishedVersionId from ContentDocumentLink WHERE LinkedEntityId =: docRecordId WITH SECURITY_ENFORCED];
      if(!contentDocLinkList.isEmpty()){
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.message = '';
        result.successRecordId = contentDocLinkList[0].ContentDocument.LatestPublishedVersionId;
        return JSON.serialize(result);
      }else{
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = '';
        return JSON.serialize(result);
      }
      
    }
    @AuraEnabled
    public static String checkUploadDocumentLargeFile(String docRecordId,String currentFileSize){
      Integer fileSize = Integer.valueOf(currentFileSize);
      List<ContentDocumentLink> contentDocLinkList = [SELECT Id,ContentDocument.LatestPublishedVersionId, ContentDocument.FileType from ContentDocumentLink WHERE LinkedEntityId =: docRecordId AND ContentDocument.LatestPublishedVersion.isActive__c =TRUE AND (ContentDocument.LatestPublishedVersion.ContentSize !=:fileSize OR (ContentDocument.LatestPublishedVersion.ContentSize =:fileSize AND ContentDocument.FileType='ZIP')) WITH SECURITY_ENFORCED ORDER BY ContentDocument.CreatedDate DESC ];
      if(!contentDocLinkList.isEmpty()){
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = true;
        result.message = '';
        result.successRecordId = contentDocLinkList[0].ContentDocument.LatestPublishedVersionId;
        return JSON.serialize(result);
      }else{
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        result.message = '';
        return JSON.serialize(result);
      }
    }
    @AuraEnabled
    public static Map<String,String> getVersionFiles(String recordId){
        try {
            Set<Id> docChecklistIdsSet = new Set<Id>();
            Map<String,String> docToMasterNameMap = new Map<String,String>();
            Map<String,String> docNameVsDocumentId = new Map<String,String>();
                
                for(Document_Checklist__c doc : [SELECT Id, Document_Master__r.Name FROM Document_Checklist__c WHERE Applicant__c =:recordId WITH SECURITY_ENFORCED]){
                    docChecklistIdsSet.add(doc.Id);
                    docToMasterNameMap.put(doc.Id, doc.Document_Master__r.Name);
                }
                Set<Id> contentDocumentIds = new Set<Id>();
                Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
                for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED]) {
                    docNameVsDocumentId.put( docToMasterNameMap.get(each.LinkedEntityId),each.ContentDocumentId);
                }
            //}
            return docNameVsDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String handleStandardUpload(String contentVersionId,String recordId,String applicantId,String loanId){
      ContentVersion conRecord = [SELECT Id,ContentSize,ContentDocumentId FROM ContentVersion WHERE Id=: contentVersionId WITH SECURITY_ENFORCED LIMIT 1];
      if(conRecord.ContentSize > Integer.valueOf(System.Label.MAXFILESIZE)){
        system.debug('File Size is more then 8MB!!');
          deleteDocument(conRecord.ContentDocumentId);
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = false;
          result.message ='File Size is more then 8MB!!';
          return JSON.serialize(result);
      }else if(conRecord.ContentSize < Integer.valueOf(System.Label.MAXFILESIZE) && conRecord.ContentSize > Integer.valueOf(System.Label.NOMRALFILESIZE)){
        //system.debug('File Size is more then 8MB!!');
        handleLargeFile(contentVersionId,recordId,applicantId,loanId);
        ResultWrapper result = new ResultWrapper();
        result.polarNeeded=true;
        result.fileSize = String.valueOf(conRecord.ContentSize);
        result.isSuccess = true;
        return JSON.serialize(result);

      }else if(conRecord.ContentSize <= Integer.valueOf(System.Label.NOMRALFILESIZE)){
        ContentVersion conRecordNormalSize = [SELECT Id,ContentSize,VersionData,PathOnClient,ContentDocumentId FROM ContentVersion WHERE Id=: contentVersionId WITH SECURITY_ENFORCED LIMIT 1];
        String responseUpload = uploadFile(EncodingUtil.base64Encode(conRecordNormalSize.VersionData),conRecordNormalSize.PathOnClient,recordId,applicantId,loanId);
        system.debug('%% '+responseUpload);
        ResultWrapper wrapperRecord =  (ResultWrapper) System.JSON.deserialize(responseUpload, ResultWrapper.class);
        if(wrapperRecord.isSuccess){
          deleteDocument(conRecordNormalSize.ContentDocumentId);
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = true;
          result.successRecordId = wrapperRecord.successRecordId;
          return JSON.serialize(result);
        }
      }
      return null;
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-16-2023 
    * @param docuemntId 
    **/
    @future
    public static void deleteDocument(String docuemntId){
      ContentDocument conDocRecord = new ContentDocument();
      conDocRecord.Id = docuemntId;
      if(Schema.sObjectType.ContentDocument.isDeletable()){
        delete conDocRecord;
      }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-16-2023 
    * @param contentVersionId 
    * @param recordId 
    * @param applicantId 
    * @param loanId 
    **/
    @future(callout=true)
    public static void handleLargeFile(String contentVersionId,String recordId,String applicantId,String loanId){
      ContentVersion conRecord = [SELECT Id,ContentSize,PathOnClient,ContentDocumentId,VersionData FROM ContentVersion WHERE Id=: contentVersionId WITH SECURITY_ENFORCED LIMIT 1];
      //DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData= DocumentCompressAPI.getCompresssedDocument(EncodingUtil.base64Encode(conRecord.VersionData),conRecord.PathOnClient,applicantId,loanId);
      String responseUpload = uploadFile(EncodingUtil.base64Encode(conRecord.VersionData),conRecord.PathOnClient,recordId,applicantId,loanId);
      ResultWrapper wrapperRecord =  (ResultWrapper) System.JSON.deserialize(responseUpload, ResultWrapper.class);
      if(wrapperRecord.isSuccess){
        ContentDocument conDocRecord = new ContentDocument();
        conDocRecord.Id = conRecord.ContentDocumentId;
        if(Schema.sObjectType.ContentDocument.isDeletable()){
          delete conDocRecord;
        }
      }
    }

    @AuraEnabled
    public static List<ResponseListWrapper> getVersionFilesByChecklistId(String recordId) {
      Set < Id > contentDocumentIds = new Set < Id > ();
      Map < Id, Id > docIdToChecklistId = new Map < Id, Id > ();
      Map<Id,String> docToMasterNameMap = new Map<Id,String>();
      List<ResponseListWrapper> respWrapList = new List<ResponseListWrapper>();
      List<Document_Checklist__c> docChecks = [SELECT Id FROM Document_Checklist__c Where Id =: recordId];
      try{
      for (ContentDocumentLink each: [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: docChecks[0].Id AND ContentDocument.LatestPublishedVersion.isActive__c = TRUE WITH SECURITY_ENFORCED]) {
        contentDocumentIds.add(each.ContentDocumentId);
        docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
      }
  
      List < ContentVersion > contVerList = [SELECT Id, Title, ContentDocumentId, FileType, FileExtension, FirstPublishLocationId FROM ContentVersion
        WHERE ContentDocumentId IN: contentDocumentIds WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
      ];
      for (ContentVersion cv: contVerList) {
        ResponseListWrapper resp = new ResponseListWrapper();
        resp.fileName = cv.Title;
        resp.docName = docToMasterNameMap.get(docIdToChecklistId.get(cv.ContentDocumentId));
        //resp.url = '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
        resp.downloadurl = '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
        resp.url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + cv.Id;
        resp.fileType = cv.FileExtension;
        resp.recordId = docIdToChecklistId.get(cv.ContentDocumentId); //cv.Id;
        resp.contentDocId = cv.ContentDocumentId;
        resp.contentVerId = cv.Id;
        respWrapList.add(resp);
  
      }
      return respWrapList;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    }

    @AuraEnabled
    public static List<ResponseListWrapper> getVersionFilesByChecklist(String recordId) {
      Set < Id > contentDocumentIds = new Set < Id > ();
      Map < Id, Id > docIdToChecklistId = new Map < Id, Id > ();
      Map<Id,String> docToMasterNameMap = new Map<Id,String>();
      List<ResponseListWrapper> respWrapList = new List<ResponseListWrapper>();
      List<Document_Checklist__c> docChecks = [SELECT Id FROM Document_Checklist__c Where Document_Master__r.Document_Id__c =: System.Label.DocumentPan AND Applicant__c =: recordId];
      try{
      for (ContentDocumentLink each: [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: docChecks[0].Id AND ContentDocument.LatestPublishedVersion.isActive__c = TRUE WITH SECURITY_ENFORCED]) {
        contentDocumentIds.add(each.ContentDocumentId);
        docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
      }
  
      List < ContentVersion > contVerList = [SELECT Id, Title, ContentDocumentId, FileType, FileExtension, FirstPublishLocationId FROM ContentVersion
        WHERE ContentDocumentId IN: contentDocumentIds WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
      ];
      for (ContentVersion cv: contVerList) {
        ResponseListWrapper resp = new ResponseListWrapper();
        resp.fileName = cv.Title;
        resp.docName = docToMasterNameMap.get(docIdToChecklistId.get(cv.ContentDocumentId));
        //resp.url = '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
        resp.downloadurl = '/sfc/servlet.shepherd/document/download/' + cv.ContentDocumentId;
        resp.url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + cv.Id;
        resp.fileType = cv.FileExtension;
        resp.recordId = docIdToChecklistId.get(cv.ContentDocumentId); //cv.Id;
        resp.contentDocId = cv.ContentDocumentId;
        resp.contentVerId = cv.Id;
        respWrapList.add(resp);
  
      }
      return respWrapList;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    }
    public class ResponseListWrapper{
      @AuraEnabled
      public String fileName{get;set;}
      @AuraEnabled
      public String docName{get;set;}
      @AuraEnabled
      public String url{get;set;}
      @AuraEnabled
      public String downloadurl{get;set;}
      @AuraEnabled
      public String fileType{get;set;}
      @AuraEnabled
      public String recordId{get;set;}
      @AuraEnabled
      public String contentDocId{get;set;}
      @AuraEnabled
      public String contentVerId{get;set;}
  }
    
    public class CustomException extends Exception{}
}