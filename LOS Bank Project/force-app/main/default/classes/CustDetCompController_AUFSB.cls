/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-23-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/

public with sharing class CustDetCompController_AUFSB {

    @AuraEnabled
    public static List<Common_Picklist__mdt> getCommonPicklistByFldName(String fldName ,String strCustomerType) {
        List<Common_Picklist__mdt> commonPicklistLst = [SELECT id, Field_Value__c
                                                        FROM Common_Picklist__mdt where Field_Name__c =: fldName and Customer_Type__c =: strCustomerType];
        return commonPicklistLst;
    }
    @AuraEnabled()
    public static Boolean validateMobile(String emailId){
        
        List<Blocked_List__c > blockedlistMobile= [SELECT Email__c FROM Blocked_List__c where Email__c =:emailId  ];
        if(blockedlistMobile.size()>0)
            return true;
        
        return false;        
        
    }    

    @AuraEnabled
    public static ResponseWrapper getApplicant(ID recordId) {
        system.debug(LoggingLevel.WARN,'in getApplicant');
        Applicant__c applicantList = [SELECT Id,Recordtype.Name,Existing_Customer__c,Title__c,First_Name__c,KYC_Type__c,CreatedDate,CBS_Status__c,Cbs_Checked__c,Is_Customer_HIN_VIP__c,
                                      Middle_Name__c,Last_Name__c,Dob__c,Age__c,Gender__c,PAN__c,Aadhaar_Number__c,Place_of_Birth_Incorporation__c, PAN_verification_Status__c, //R2-2422
                                      Passport_Number__c,Voter_Id__c,Loan__c,Customer_Type__c,Loan__r.Customer_Type__c,Loan__r.Stage__c,Loan__r.OPS_KYC_Action__c,Father_Name__c,
                                      Spouse_Name__c,High_risk_Profile__c,AU_Employee_ID__c,Name_of_Employee_AU__c,
                                      AU_Employment_status__c,IsEmailVerified__c ,Mobile_Number__c,Email__c,AU_Employee__c,Residential_Status__c,
                                      Entity_Name__c, Date_of_Establishment__c, Key_Contact_Name__c, Marital_Status__c, Education_qualification__c,
                                      Mother_Name__c, No_of_Dependents__c, Caste__c, Religion__c, Politically_Exposed_Person__c,loan__r.Product__c,
                                      Phsically_challenged__c, Director_Identification_Number__c, Risk_Category__c, Key_Person__c, Relationship_with_applicant__c, Relation_with_Applicant_Other__c, Loan__r.Primary_Applicant__r.Gender__c, Loan__r.Primary_Applicant__r.Spouse_Name__c,  //R2-17
                                      Alternate_Mobile_Number__c , Type_Of_Employment__c, Risk_Identification__c, X2W_Risk_Category__c, Loan__r.RecordType.Name, Shareholding__c, (SELECT Id,Match_Percentage__c,Face_Match__c FROM Document_Checklists__r 
                                      WHERE Document_Master__r.Name=:Label.DcumentMasterCustomerImage)
                                      FROM Applicant__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
        if(applicantList.PAN__c!=null){
            applicantList = getAuEmployeeDetails(applicantList);
        }
        List<Common_Picklist__mdt> lstCommonPicklist = new List<Common_Picklist__mdt>();
        lstCommonPicklist = getCommonPicklistByFldName(
            'Relationship_with_applicant__c',
            applicantList.Customer_Type__c == GlobalConstants.INDIVIDUAL && applicantList.Loan__r.Customer_Type__c == GlobalConstants.INDIVIDUAL ? GlobalConstants.INDIVIDUAL : GlobalConstants.NON_INDIVIDUAL
        );
        Common_Picklist__mdt commonPicklist = !lstCommonPicklist.isEmpty() ? lstCommonPicklist[0] : new Common_Picklist__mdt();
        String loggedInUserProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()  LIMIT 1 ]?.Name;
        ResponseWrapper resp = new ResponseWrapper();
        resp.applicant = applicantList;
        resp.maxEstablishmentDate = Date.valueOf(applicantList.CreatedDate);
        resp.adharUrl = getVersionFiles(recordId);
        resp.customerUrl = getCustomerPhoto(recordId);
        resp.typeOfWheeler =AUSFVehicleController.getTypeOfWheeler(applicantList.loan__r.Product__c);
        resp.userProfile =loggedInUserProfileName;
        resp.relationShipWithApplOptions = commonPicklist != null ? commonPicklist.Field_Value__c : '';
        return resp;
    }
  
    @AuraEnabled
    public static  List<Stage_Profile_Data_Configuration__mdt> getCustomMetaRecStageProfle() {
        system.debug(LoggingLevel.WARN,'in getCustomMetaRecStageProfle');
        List<Stage_Profile_Data_Configuration__mdt> stageprofRecLst = [SELECT id, MasterLabel, Fields__c, Loan_Stage__c, Screen__c, Customer_Type__c
                                                                        FROM Stage_Profile_Data_Configuration__mdt];
        return stageprofRecLst;
    }

   /* @description :  Get Fetch Visible fields from custom metadata based on Screen Type, Stage, Profile  
@param :  String Screen Type, Stage, Profile
@return : List<String>
*/
    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile,String typeOfWheeler,String customerType) {
        return Utility.getVisibleFields(strScreen,strStage,strProfile,typeOfWheeler,customerType);
    } 

    
    public static Applicant__c getAuEmployeeDetails(Applicant__c app){
        String requestBody;
        String respBody;
        //Applicant__c app = new Applicant__c();
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = app.Id);
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('AU Employee HCM API');
        RequestWrapper req = new RequestWrapper();
        req.RequestId=IntegrationUtility.getReferenceId();
        req.OriginatingChannel = Label.AusfOriginatingChannel;
        req.EmployeeID='';
        req.PAN = app.PAN__c;
        requestBody = JSON.serializePretty(req);
        
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        respBody = calloutResponseWrapper.response;
        system.debug(LoggingLevel.WARN,'respBody--'+respBody);
        If(calloutResponseWrapper.statusCode==200){
        HCMResponseWrapper hcmResp = HCMResponseWrapper.parse(respBody);
            if(hcmResp.EmployeeDetails!=null){
                app.AU_Employee__c = 'Yes';
                app.AU_Employee_ID__c = hcmResp.EmployeeDetails.EmployeeCode;
                app.AU_Employment_status__c = getCurrentStatus(hcmResp.EmployeeDetails.CurrentStatus);
                app.Name_of_Employee_AU__c  = hcmResp.EmployeeDetails.EmployeeName;
                if(hcmResp.EmployeeDetails.Employment_Start_Date != null){
                    app.Date_of_Joining__c  = Date.valueOf(hcmResp.EmployeeDetails.Employment_Start_Date);
                }
            }else{
                app.AU_Employee__c = 'No';
            }
        }else if(calloutResponseWrapper.statusCode==400){
            
        }
        
        return app;
    }
    
    public static String getCurrentStatus(String status){
        String returnStatus;
        if(status!=null){
            if(status=='A'){
                returnStatus= 'Active';
            }
            
            if(status=='R'){
                returnStatus= 'Resigned';
            }
        }
        return returnStatus;
    }
    
    public class RequestWrapper{
        public String PAN;  //SFDC91872839712
        public String EmployeeID;   //2011
        public String RequestId;    //SFDC91872839712
        public String OriginatingChannel; 
    }
    
    public class ResponseWrapper{
        @AuraEnabled
        public Applicant__c applicant;
        @AuraEnabled
        public Date maxEstablishmentDate;
        @AuraEnabled
        public String adharUrl;
        @AuraEnabled
        public String customerUrl;
        @AuraEnabled
        public String relationShipWithApplOptions;
        @AuraEnabled public String userProfile; 
        @AuraEnabled public AUSFVehicleController.TypeOfWheeler typeOfWheeler;
    }

    @AuraEnabled(cacheable=true)
    Public Static String getVersionFiles(String recordId){
        try {
            String respUrl;
            Set<Id> docChecklistIdsSet = new Set<Id>();
            List<Document_Checklist__c> docList = [SELECT Id FROM Document_Checklist__c 
                                                   WHERE Applicant__c =:recordId AND Document_Master__r.Name=:Label.DcumentMasterAadharPicture];
            if(!docList.isEmpty()){
                for(Document_Checklist__c doc : docList){
                    docChecklistIdsSet.add(doc.Id);
                }
                Set<Id> contentDocumentIds = new Set<Id>();
                Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
                for(ContentDocumentLink each : [SELECT Id, ContentDocumentId,ContentDocument.LatestPublishedVersionId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN :docChecklistIdsSet AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE ORDER by ContentDocument.LatestPublishedVersion.CreatedDate desc Limit 1]) {
                                                    // respUrl = '/sfc/servlet.shepherd/document/download/' +each.ContentDocumentId;
                                                    respUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+each.ContentDocument.LatestPublishedVersionId;
                                                }
            }
            
            
            return respUrl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    Public Static String getCustomerPhoto(String recordId){
        try {
            String respUrl;
            Set<Id> docChecklistIdsSet = new Set<Id>();
            List<Document_Checklist__c> docList = [SELECT Id FROM Document_Checklist__c 
                                                   WHERE Applicant__c =:recordId AND Document_Master__r.Name=:Label.DcumentMasterCustomerImage];
            if(!docList.isEmpty()){
                for(Document_Checklist__c doc : docList){
                    docChecklistIdsSet.add(doc.Id);
                }
                Set<Id> contentDocumentIds = new Set<Id>();
                Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
                for(ContentDocumentLink each : [SELECT Id, ContentDocumentId,ContentDocument.LatestPublishedVersionId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN :docChecklistIdsSet AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED ORDER BY ContentDocument.CreatedDate desc limit 1]) {
                                                    //respUrl = '/sfc/servlet.shepherd/document/download/' +each.ContentDocumentId;
                                                    respUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+each.ContentDocument.LatestPublishedVersionId;
                                                }
            }
            
            
            return respUrl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Boolean getRestrictedDomains(String domainAddress){
        List<String> lstOfRestrictedDomain = new List<String>();
        boolean flag = false;
        if(String.isBlank(domainAddress)){
            return false;
        }
        String domain = domainAddress.substringAfter('@');        
        System.debug(LoggingLevel.WARN,'domain---'+domain);
        for(Generic_Master__c objgeneric : [SELECT id,Domain_Name__c from Generic_Master__c where Recordtype.Name='Restricted Domains' and Domain_Name__c =:domain WITH SECURITY_ENFORCED]){
            lstOfRestrictedDomain.add(objgeneric.Domain_Name__c);
        }
        if(lstOfRestrictedDomain.isEmpty()){
            flag = true;
        }
        System.debug(LoggingLevel.WARN,'lstOfRestrictedDomain---'+flag);
        
        return flag;
    }
    
    
    // method is used to create Applicant Record on Quick Loan screen
    @AuraEnabled
    public static Applicant__c updateApplicant(Applicant__c applicant){
        Applicant__c appObj = new Applicant__c();
        appObj = applicant;
        if(applicant.Loan__r.Stage__c == 'DDE'){
        appObj.Is_Customer_Details_Saved__c = true;
        }
        if(appObj.Customer_Type__c == 'Non Individual'){
            appObj.First_Name__c = String.isNotBlank(applicant.First_Name__c) ? applicant.First_Name__c : applicant.Entity_Name__c;
            appObj.Last_Name__c = ''; 
        }
        appObj.Customer_Name__c = (appObj.First_Name__c != null ?appObj.First_Name__c:'') + ' ' 
                                + (appObj.Middle_Name__c != null ?appObj.Middle_Name__c:'') + ' ' 
                                + (appObj.Last_Name__c != null ?appObj.Last_Name__c:''); 

        String riskCategory = Utility.getApplicantRiskCategoryBy(appObj);
        appObj.X2W_Risk_Category__c = riskCategory;
        appObj.X4W_Risk_Category__c = riskCategory;

        try{
            
            /*if(applicantId != null && String.isNotBlank(applicantId)){
appObj.id = applicantId;
}*/
            if(Schema.sObjectType.Applicant__c.isCreateable() || Schema.sObjectType.Applicant__c.isUpdateable()){
                upsert appObj;
            }
        } catch(DmlException e) {
            System.debug(LoggingLevel.WARN,'The following exception has occurred: ' + e.getMessage());
        }
        return appObj;
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-19-2023 
    * @param versionId1 
    * @param versionId2 
    * @param applicantId 
    **/
    @AuraEnabled
    public static String getFaceMatch(String versionId1, String versionId2, String applicantId){

        ContentVersion version1 =[SELECT Id,VersionData from ContentVersion WHERE Id =: versionId1 WITH SECURITY_ENFORCED LIMIT 1];
        ContentVersion version2 =[SELECT Id,VersionData from ContentVersion WHERE Id =: versionId2 WITH SECURITY_ENFORCED LIMIT 1];
        String responseString = LOSKarzaFaceMatchController.validateFaceMatch(EncodingUtil.base64Encode(version1.VersionData),EncodingUtil.base64Encode(version2.VersionData),applicantId);
        return responseString;
    }

    /**
     * @auther - Sachin Hooda 
     * @param loanId - Id of the loan Application record
     * @return High_Risk_Profile__mdt[] - 
     */
    @AuraEnabled(cacheable = true)
    public static map<String, Object> getHighRiskProfilesByVehicleType(Id loanId){
        Loan_Application__c application = [ SELECT Stage__c, RecordType.Name FROM Loan_Application__c WHERE Id =: loanId ];
        return new map<String, Object>{
            'isAccepted' => application.Stage__c == GlobalConstants.STAGE_CREDIT && application.RecordType.Name == GlobalConstants.TWOWHEELER ? [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: application.Id AND Approver__c =: UserInfo.getUserId() AND Archived__c = FALSE WITH SYSTEM_MODE ] > 0 : true,
            'hrpOptions' => Utility.getHighRiskProfilesByVehicleType(
                application.RecordType.Name==GlobalConstants.TWOWHEELER? GlobalConstants.TWOWHEELER : GlobalConstants.FOURWHEELER
            ),
            'disableHRP' => application.RecordType.Name==GlobalConstants.TWOWHEELER && application.Stage__c == GlobalConstants.STAGE_DDE?true:false
        };
    }
    //disableHRP - SFAU-5166

    @AuraEnabled
    public static Boolean checkKartaCondition(String appId){
        try {
            List<Applicant__c> appList = [SELECT Id FROM Applicant__c WHERE RecordType.Name='Applicant' AND Customer_Type__c='Non Individual' AND Constitution_Type__c='HUF' AND Loan__c=:appId WITH SECURITY_ENFORCED]; // added Loan__c check R2-1811 and removed additional Loan Query
            return !appList.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String checkPrimaryApplicant(String appId){
        List<Applicant__c> appList = new List<Applicant__c>();
        List<String> mandatory = new List<String>{'Public Limited','Private Limited','Limited Liability Partnership'};
        List<String> nonmandatory = new List<String>{'Partnership Firms','Trust','Society',' AOP'};
        List<String> noDin = new List<String>{'Sole Proprietary','HUF'};
        try {
            Applicant__c obj = [SELECT Loan__c FROM Applicant__c WHERE Id=:appId];
            appList = [SELECT Id,Constitution_Type__c ,Customer_Type__c FROM Applicant__c WHERE RecordType.Name='Applicant' AND Customer_Type__c='Non Individual' AND Loan__c=:obj.Loan__c limit 1];
            
            if(appList==null || appList.isEmpty() ){
                return 'No';
            }
            else if(mandatory.contains(appList[0].Constitution_Type__c)){
                return 'mandatory';
            }
            else if(nonmandatory.contains(appList[0].Constitution_Type__c)){
                return 'nonmandatory';
            }
            else if(noDin.contains(appList[0].Constitution_Type__c) || appList[0].Constitution_Type__c == null || String.isBlank(appList[0].Constitution_Type__c) || appList[0].Constitution_Type__c ==''){
                return 'No';
            }
            return 'No';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void callValidateNameMatch(Applicant__c applicantRecord){
        try {
            List<Document_Checklist__c> docCheckList = [SELECT Id, API_Response__c, Applicant__r.KYC_Type__c FROM Document_Checklist__c WHERE Applicant__c=:applicantRecord.Id AND Applicant__r.IsInactive__c=false AND Document_Master__r.Name='AUWheels0001'];
            if(docCheckList!=null && docCheckList.size()>0 && docCheckList[0].Applicant__r.KYC_Type__c==GlobalConstants.CBS_Aadhaar && docCheckList[0].API_Response__c!=null){
                system.debug(LoggingLevel.WARN,'docCheckList[0].API_Response__c '+docCheckList[0].API_Response__c);
                NSDLRespWrapper wrapper = (NSDLRespWrapper) JSON.deserialize(docCheckList[0].API_Response__c,NSDLRespWrapper.class);        
                cls_Response resp = wrapper.Response;
                String applicantName = (resp.FirstName!=null?resp.FirstName+' ':'')+(resp.MiddleName!=null?resp.MiddleName+' ':'')+(resp.LastName!=null?resp.LastName:'');
                system.debug(LoggingLevel.WARN,'applicantName '+applicantName);
                LOSKarzaNameMatchController.validateNameMatch(applicantName,'Pan',applicantRecord.Id,null);
            }
            
        } catch (Exception e) {
            system.debug(LoggingLevel.WARN,'Exception --- '+e);
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
    }

    //4291
    @AuraEnabled
    public static void karzaNameMatchCallout(String documentType, String applicantId){
        try {
            List<Document_Checklist__c> docChecklist = [SELECT Id, Api_Response__c FROM Document_Checklist__c WHERE Document_Master__r.Name=:documentType AND Applicant__c=:applicantId AND
                Document_Verification_Status__c='Verified' AND Document_Number__c!=null];
            if(docChecklist!=null && docChecklist.size()>0 && docChecklist[0].Api_Response__c!=null){
                String applicantName;
                String document;
                String response = docChecklist[0].Api_Response__c;
                if(documentType == 'AUWheels0001'){
                    document='Pan';
                    NSDLRespWrapper wrapper = (NSDLRespWrapper) JSON.deserialize(response,NSDLRespWrapper.class);        
                    cls_Response resp = wrapper.Response;
                    applicantName = (resp.FirstName!=null?resp.FirstName+' ':'')+(resp.MiddleName!=null?resp.MiddleName+' ':'')+(resp.LastName!=null?resp.LastName:'');
                }
                else if(documentType == 'AUWheels0005'){
                    document='Passport';
                    AUSFPassportResponseWrapper.PassPortResponse wrapper = (AUSFPassportResponseWrapper.PassPortResponse) JSON.deserialize(response, AUSFPassportResponseWrapper.PassPortResponse.class); 
                    applicantName = wrapper.nameFromPassport!=null?wrapper.nameFromPassport+' ':''+ wrapper.surnameFromPassport!=null?wrapper.surnameFromPassport:'';
                }else if(documentType == 'AUWheels0004'){
                    document='Driving Licence';
                    AUSFDrivingLicenseResponseWrapper.Result wrapper = (AUSFDrivingLicenseResponseWrapper.Result) JSON.deserialize(response,AUSFDrivingLicenseResponseWrapper.Result.Class);
                    applicantName = wrapper?.name;
                }else if(documentType == 'AUWheels0002'){
                    document='Voter ID Card';
                    AUSFVoterResponseWrapper.Result wrapper = (AUSFVoterResponseWrapper.Result) JSON.deserialize(response, AUSFVoterResponseWrapper.Result.class); 
                    applicantName = wrapper?.name;
                }
                system.debug('applicantId : '+applicantId);
                LOSKarzaNameMatchController.validateNameMatch(applicantName,document,applicantId,null);
            }         
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class NSDLRespWrapper{
        public cls_Response Response;
        public cls_metadata[] metadata;
        public cls_headers headers;
        public cls_error error;
    }
    public class cls_headers {
        public String responseMsg;  //Success
        public String responseCode; //0
    }
    public class cls_error {
    }
    public class cls_Response {
        public String Title;    //Kumari
        public String Status;   //Existing and Valid
        public String Seeding;  //Y
        public String MiddleName;   //R
        public String LastName; //PATIL
        public String FirstName;    //NEHA
    }
    public class cls_metadata {
        public cls_attributes attributes;
        public String Id;   //m0I71000000DagzEAC
        //public Integer Order__c;  //3
        public String DeveloperName;    //PAN
        public String MasterLabel;  //PAN
        //public boolean Display_on_UI__c;
        //public String JSON_Key__c;    //pan
    }
    public class cls_attributes {
        public String type; //Display_Data__mdt
        public String url;  ///services/data/v58.0/sobjects/Display_Data__mdt/m0I71000000DagzEAC
    }
}