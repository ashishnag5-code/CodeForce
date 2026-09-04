/*****
 * Class Name: CIFCreationController
 * Description: CIFCreation and Modification Logic
 * Test Class Name: CIFCreationControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-20-2023          -   Mohit M.            -   SFAU-5602 - Save CIF Creation and Modification Details
 */
public with sharing class CIFCreationController {
    
    @AuraEnabled
    public static String getUserType(Id recordId){
        String userType='NA';
        try {
            List<Loan_Application__c> loanApps = [SELECT Id, OwnerId, Owner.Type FROM Loan_Application__c WHERE Id=:recordId];
            if(loanApps!=null && loanApps.size()>0){
                if(loanApps[0].Owner.Type!='User'){
                    userType='NA';
                }else{
                    List<User> users = [SELECT Id, Ops_User_Type__c FROM User WHERE Id=:UserInfo.getUserId()];
                    if(users!=null && users.size()>0){
                        if(users[0].Ops_User_Type__c =='Ops Maker'){
                            userType = 'User';
                        }else{
                            userType = 'NA';
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return userType;
    }
    
    @AuraEnabled
    public static String getLoanId(Id recordId){
        Id loanId;
        try {
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Assignment__c'){
                List<Assignment__c> assignmentRecord = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE id=:recordId WITH SECURITY_ENFORCED];
                loanId = assignmentRecord[0].Loan_Application__c;
            }
            if(sObjName == 'Loan_Application__c'){
                loanId = recordId;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return loanId;
    }

    @AuraEnabled
    public static List <Applicant__c> getApplicants(Id loanId) {
        List < Applicant__c > applicantList = new List <Applicant__c> ();
        try {
            applicantList = [SELECT Id,Customer_Name__c, Existing_Customer__c, Loan__r.LAN__c, Loan__r.OPS_KYC_Action__c, Bureau_Score__c, First_Name__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, AU_Employee__c, Name_of_Employee_AU__c, Customer_Type__c, Loan__r.EMI__c, Total_Monthly_Income_Sum__c, Current_Obligation__c, Free_Monthly_Cashflow__c, Total_Loan_Amount__c, FOIR__c, Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName, RecordType.Name,Wheels_Exposure__c,Total_Exposure__c,
                Relationship_with_applicant__c, KYC_Status__c, CIF_Modification_Successful__c, CIF_No__c, CBS_Signature_Available__c, CBS_Image_Available__c, KYC_Type__c, loan__r.Dpd_Checked_Date__c, loan__r.Dpd_Found__c, Credit_Approved_Exposure__c, Education_Qualification__c, Loan__r.OwnerId
                FROM Applicant__c
                WHERE Loan__c =: loanId
                AND RecordType.DeveloperName != 'Additional_Match'
                AND RecordType.DeveloperName != 'Nominee' 
                AND IsInactive__c=false
                WITH SECURITY_ENFORCED
            ];

        } catch (Exception e) {
            Log.error(e, Log.SeverityType.valueOf('High'), '');
        }
        return applicantList;
    }  

    @AuraEnabled
    public static Applicant__c getApplicant(Id appId) {
        List <Applicant__c > applicantList = new List <Applicant__c> ();
        try {
            applicantList = [SELECT Id,Customer_Name__c, Loan__r.Dpd_Found__c, Loan__r.Pre_Approved_Flag__c, Existing_Customer__c, Bureau_Score__c, First_Name__c, Middle_Name__c, Last_Name__c, Name, Loan__c, Loan_Stage__c, AU_Employee__c, Name_of_Employee_AU__c, Customer_Type__c, Loan__r.EMI__c, Total_Monthly_Income_Sum__c, Current_Obligation__c, Free_Monthly_Cashflow__c, Total_Loan_Amount__c, FOIR__c, Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName, RecordType.Name,Wheels_Exposure__c,Total_Exposure__c,
                Relationship_with_applicant__c, KYC_Status__c, CIF_Modification_Successful__c, CIF_No__c, CBS_Signature_Available__c, CBS_Image_Available__c, KYC_Type__c, loan__r.Dpd_Checked_Date__c, Credit_Approved_Exposure__c, Education_Qualification__c
                FROM Applicant__c
                WHERE Id =: appId AND IsInactive__c=false
                WITH SECURITY_ENFORCED
            ];

        } catch (Exception e) {
            Log.error(e, Log.SeverityType.valueOf('High'), '');
        }
        if(applicantList.size()>0){
            return applicantList[0];
        }else{
            return null;
        }
    }  

    @AuraEnabled
    public static String callCIFCreationCallout(Id recordId){
        CIFCreationApiHandler.CIFCreationApiResponseWrapper cifCreationResponseWrapper = new CIFCreationApiHandler.CIFCreationApiResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CIF Creation');

            
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('ApplicantId',recordId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody= CIFCreationApiHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            /*String respBody = calloutResponseWrapper.response;
            if(respBody.contains('[ null ]')){
                respBody = respBody.replace('[ null ]','null');
            }
            system.debug('respBody '+respBody);
            if(calloutResponseWrapper.statusCode!=504){
                cifCreationResponseWrapper = (CIFCreationApiHandler.CIFCreationApiResponseWrapper) JSON.deserialize(respBody, CIFCreationApiHandler.CIFCreationApiResponseWrapper.class);
            }*/
            /*if(calloutResponseWrapper.statusCode==200 || calloutResponseWrapper.statusCode==201 || calloutResponseWrapper.statusCode==202 || calloutResponseWrapper.statusCode==203 || calloutResponseWrapper.statusCode==204){
            }*/
        }catch(Exception e) {
            system.debug('eeeee- '+e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);
            return JSON.serialize(e);
        }
        return JSON.serialize(calloutResponseWrapper);//return cifCreationResponseWrapper;
    }

    @AuraEnabled
    public static String callCIFModifyCallout(Id recordId){
        CIFModificationHandler.CIFModificationApiResponseWrapper cifModificationResponseWrapper = new CIFModificationHandler.CIFModificationApiResponseWrapper();
        String respBody;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CIF Modification');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('ApplicantId',recordId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody= CIFModificationHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            /*respBody = calloutResponseWrapper.response;
    
            system.debug('respBody '+respBody);
            cifModificationResponseWrapper = (CIFModificationHandler.CIFModificationApiResponseWrapper) JSON.deserialize(respBody, CIFModificationHandler.CIFModificationApiResponseWrapper.class);
            */
        }catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);
            return JSON.serialize(e);
        }
        return JSON.serialize(calloutResponseWrapper);//cifModificationResponseWrapper;
    }

    //SFAU-2751
    @AuraEnabled
    public static Boolean handleExposureDPD(String loanId){

       

        // If Profile RO same logic continue if Profile Ops Maker then we need to check the emi due date based on the product if emi date has not passed then keep it as disabled only and if emi date has passed then keep it as active
        Loan_Application__c loanInstance = [SELECT id,Dpd_Checked_Date__c,Product__c 
                                            FROM Loan_Application__c 
                                            WHERE id=:loanId];

        List<EMI_Date_Master__mdt> emiMasterList = [SELECT id,Due_Date__c,Product_Name__c 
                                                    FROM EMI_Date_Master__mdt ];

        List<Decimal> dueDatesList = new List<Decimal>();
        Date checkedDate = loanInstance.Dpd_Checked_Date__c!= null ? loanInstance.Dpd_Checked_Date__c : null;
        Date todayDate = Date.today();
        Boolean buttonActive = false;
        Decimal checkedInDate = checkedDate != null ? checkedDate.day() : null;
        Decimal todayDateInstance = todayDate.day();
        if(checkedInDate == todayDateInstance){
            buttonActive = false;
        }else{
            for(EMI_Date_Master__mdt emiInstance : emiMasterList){
                if(emiInstance.Product_Name__c.contains('Wheels')){ // Later need to be changed based on the product as of now in this release we have only wheeler
                    if(checkedDate!=null){
                       if( (checkedInDate <= emiInstance.Due_Date__c) && (todayDateInstance >= emiInstance.Due_Date__c)){
                            buttonActive = true;
                        }
                    }
                }
            }
        }
        
       
        if(checkedDate == null){
            buttonActive = true;
        }
        System.debug('buttonActive-->' +buttonActive);
        return buttonActive;
       
    }

    /* START - SFAU-5602 - CIF Creation and Modification Date */
    @AuraEnabled
    public static CIFOutputWrapper updateRecordServer(String jsoAppObj, Boolean blnModifyCIF){
        CIFOutputWrapper objWrap = new CIFOutputWrapper();
        String strAppId = '';
        try {
            Applicant__c objApp = (Applicant__c)JSON.deserialize(jsoAppObj, Applicant__c.class);
            strAppId = objApp.Id;
            if (!blnModifyCIF && objApp != NULl  && String.isNotBlank(objApp.CIF_No__c)) {
                objApp.CIF_Creation_Date__c = Date.today();
                objApp.CIF_Created_By__c = UserInfo.getUserId();
            }
            else if (blnModifyCIF && objApp != NULl) {
                objApp.CIF_Modification_Date__c = Date.today();
                objApp.CIF_Modification_By__c = UserInfo.getUserId();
            }
            else {
                throw new CustomException('Error in CIF ' + (!blnModifyCIF ? 'creation' : 'modification'));
            }
            update objApp;
            objWrap.blnSuccess = true;
            objWrap.strMsg = blnModifyCIF ? Label.CIF_Modification_Successful_Msg : Label.CIF_Creation_Successful_Msg;
        }
        catch (Exception ex) {
            objWrap.blnSuccess = false;
            objWrap.strMsg = ex.getMessage();
            Log.error('CIFCreationController method updateRecordServer :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strAppId);
        }
        return objWrap;
    }
    /* END - SFAU-5602 - CIF Creation and Modification Date */

    // SFAU-5602
    public class CIFOutputWrapper {
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMsg = '';
    }

    public Class CustomException extends Exception {}

}