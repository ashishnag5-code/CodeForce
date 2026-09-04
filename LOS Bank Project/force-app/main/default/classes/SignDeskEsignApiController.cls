public with sharing class SignDeskEsignApiController {

    @AuraEnabled
    public static Boolean checkIfEsignEnabled(){
        return Enable_Disable_Feature__mdt.getInstance('SignDeskEsign').isEnabled__c;	
    }

    @AuraEnabled
    public static List<String> requiredDocumentsUploadCheck(Id recordId){
        Map<Id, ContentVersion> cvList;
        Map<Id, Document_Checklist__c> idToBeRemoved = new Map<Id, Document_Checklist__c>();
        try {
            Map<Id,Document_Checklist__c> documentsForEsign = new Map<Id, Document_Checklist__c>([SELECT Id, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE
            Loan_Application__c=:recordId AND Document_Master__r.Consider_for_E_Sign__c=true WITH SECURITY_ENFORCED]);
            idToBeRemoved = documentsForEsign;
            if(documentsForEsign.keySet()!=null && documentsForEsign.keySet().size()>0){
                List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :documentsForEsign.keySet() WITH SECURITY_ENFORCED];
                if(cdlList!=null && cdlList.size()>0){
                    Map<Id, ContentDocumentLink> contentDocIds = new Map<Id, ContentDocumentLink>();
                    for(ContentDocumentLink cdl: cdlList){
                        contentDocIds.put(cdl.ContentDocumentId, cdl);
                    }
                    cvList = new Map<Id,Contentversion>([SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId in :contentDocIds.keySet() WITH SECURITY_ENFORCED]);
                    for(ContentVersion cv: cvList.values()){
                        if(documentsForEsign.keySet().contains(contentDocIds.get(cv.ContentDocumentId).LinkedEntityId)){
                            idToBeRemoved.remove(contentDocIds.get(cv.ContentDocumentId).LinkedEntityId);
                        }
                    }
                }
            }else{
                
                return (new List<String>{'NA'});
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        if(idToBeRemoved.size() == 0){
            List<Id> cvIds = new List<Id>();
            cvIds.addAll(cvList.keySet());
            return cvIds;
        }else{
            String error = 'Missing Documents: ';
            for(Document_Checklist__c doc: idToBeRemoved.values()){
                error = error + doc.Document_Master__r.Document_Name__c+'; ';
            }
            List<String> errorList = new List<String>();
            errorList.add(error);
            return errorList;
        }
    }

    @AuraEnabled
    public static Boolean fieldInvestigationStatusCheck(Id recordId){
        try{
        	Loan_Application__c loanAppRec = [SELECT Id,Application_FI_Status__c From Loan_Application__c WHERE Id =:recordId];
       	 	List<Loan_Application_Approval__c> approvalList = [SELECT id,Name,Approval_Status__c FROM Loan_Application_Approval__c WHERE Approval_Status__c ='Pending' AND Loan_Application__c =:loanAppRec.Id and Archived__c = false];
            String loanApplicantFI = String.isNotBlank(loanAppRec.Application_FI_Status__c) ? loanAppRec.Application_FI_Status__c :'';   
            //if(loanApplicantFI == 'In Progress' || loanApplicantFI == 'Assigned' || loanApplicantFI == 'New' || (loanApplicantFI=='Negative' && approvalList!=null && approvalList.size()>0)){
            if(loanApplicantFI == 'In Progress' || loanApplicantFI == 'Assigned' || loanApplicantFI == 'New'){
                return true;
            }
            else{
                return false;
            }
        }
        catch(Exception ex){
              throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String callSignDeskAPi(Id recordId, List<Id> cvIds, String journeyType, String esignType){
        EsignResponseWrapper esignData = new EsignResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper esignWrapper = new SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper();
        Map<String,String> signerVsName = new Map<String,String>();
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('ESignDesk');
            List<Applicant__c> applicantList = [SELECT Id, Customer_Name__c, Email__c, Mobile_Number__c, First_Name__c, Middle_Name__c, Last_Name__c,
                Gender__c, Aadhaar_Number__c, Dob__c, RecordType.Name, RecordType.DeveloperName from Applicant__c WHERE Loan__c=:recordId 
                AND RecordType.DeveloperName in ('Co_Applicant','Primary_Applicant','Guarantor') AND IsInactive__c != true  WITH SECURITY_ENFORCED];
            String applicants;
            Map<String,String> appVSRecordType = new map<String,String>();
            if(applicantList!=null && applicantList.size()>0){
                applicants = JSON.serialize(applicantList);
                for(Applicant__c app: applicantList){
                    String fullName;
                    if(app.Middle_Name__c!=null){
                        fullName = app.First_Name__c+' '+app.Middle_Name__c+' '+app.Last_Name__c;
                    }else{
                        fullName = app.First_Name__c+' '+app.Last_Name__c;
                    }
                    appVSRecordType.put(fullName, (fullName+' ('+app.RecordType.Name+')'));
                }
            }

            Map<String,String> reqParam = new Map<String,String>();
            String refId = IntegrationUtility.getReferenceId();
            reqParam.put('Id',recordId);
            reqParam.put('JourneyType',journeyType);
            reqParam.put('Applicants',applicants);
            reqParam.put('RequestId',refId);
            reqParam.put('EsignType','OTP');
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody= SignDeskEsignApiHandler.generateRequest(reqParam)[0];
                 
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=recordId, 
            Request_Id__c=refId, Esign_Type__c=esignType);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutRequestWrapper.captureRequestInAttachment = true;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            String respBody = calloutResponseWrapper.response;
            system.debug('respBody '+respBody);
            if(calloutResponseWrapper.statusCode ==200){
                esignWrapper = (SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper) JSON.deserialize(respBody, SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper.class);       
                /*Integration_Checklist__c icRecord = [SELECT Id, Request_Id__c FROM Integration_Checklist__c WHERE Loan_Application__c=:recordId AND Integration_Master__r.Name='' WITH SECURITY_ENFORCED Order By CreatedDate Desc Limit 1];
                icRecord.Request_Id__c = esignWrapper.docket_id;
                update icRecord;*/
    
                SignDeskEsignApiHandler.SignDeskEsignApiRequestWrapper requestWrapper = (SignDeskEsignApiHandler.SignDeskEsignApiRequestWrapper) JSON.deserialize(requestBody, SignDeskEsignApiHandler.SignDeskEsignApiRequestWrapper.class);
                for(SignDeskEsignApiHandler.SignersInfoWrapper temp: requestWrapper.signers_info){
                    signerVsName.put(temp.signer_ref_id, appVSRecordType.get(temp.signer_name));
                }
                if(esignWrapper.status == 'success'){
                    Loan_Application__c loan = new Loan_Application__c();
                    loan.Id = recordId;
                    loan.Esign_Status__c='Initiated';
                    loan.Esign_Type__c='Digital';
                    update loan;
                }
            }else{
                return JSON.serialize(calloutResponseWrapper);
            }
            
        }catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);

        }
        esignData.signerVsName = signerVsName;
        esignData.response = esignWrapper;
        return JSON.serialize(esignData);
    }

    public static void handleEsignSignDeskAPICallback(Map<Id, ContentVersion> contentVersionMap){
        String loanId =''; //29 AUG
        Map<String, ContentVersion> contentVersionRequestIds = new Map<String, ContentVersion>();
        List<ContentVersion> cvRecordList = [SELECT Id, ContentDocumentId, Request_Id__c FROM ContentVersion WHERE Id in :contentVersionMap.keySet() WITH SECURITY_ENFORCED];
        for(ContentVersion cv: cvRecordList){
            if(cv.Request_Id__c!=null){
                contentVersionRequestIds.put(cv.Request_Id__c, cv);
            }
        }

        List<sObject> sObjectListToUpsert = new List<sObject>();
        if(contentVersionRequestIds!=null && contentVersionRequestIds.size()>0){
            List<Integration_Checklist__c> icList = [SELECT Id, Loan_Application__c, Request_Id__c, Esign_Type__c FROM Integration_Checklist__c WHERE
            Request_Id__c in :contentVersionRequestIds.keySet() AND Integration_Master__r.Name='ESignDesk' WITH SECURITY_ENFORCED];
            List<Id> ids = new List<Id>();
            Map<Id,Id> loanVsSIMap = new Map<Id,Id>();
            Map<Id,Id> loanVsAgreementMap = new Map<Id,Id>();
            Map<Id,Id> loanVsAddendumMap = new Map<Id,Id>();
            loanId = !icList.isEmpty() &&  String.isNotBlank(icList[0].Loan_Application__c) ? String.valueOf(icList[0].Loan_Application__c) :''; //29 AUG
            for(Integration_Checklist__c ic: icList){
                ids.add(ic.Loan_Application__c);
            }
            List<Document_Checklist__c> docChecklists = [SELECT Id, Loan_Application__c, Document_Master__r.Name FROM Document_Checklist__c WHERE Document_Master__r.Name in ('AUWheels0045','AUWheels0073','AUWheels0300') AND Loan_Application__c IN :ids];
            for(Document_Checklist__c doc: docChecklists){
                if(doc.Document_Master__r.Name == 'AUWheels0045'){
                    loanVsSIMap.put(doc.Loan_Application__c, doc.Id);
                }
                if(doc.Document_Master__r.Name == 'AUWheels0073'){
                    loanVsAgreementMap.put(doc.Loan_Application__c, doc.Id);
                }
                if(doc.Document_Master__r.Name == 'AUWheels0300'){
                    loanVsAddendumMap.put(doc.Loan_Application__c, doc.Id);
                }
            }
            List<Assignment__c> assignmentRecords = [SELECT Id, Addendum_Status__c, Loan_Application__c FROM Assignment__c WHERE Loan_Application__c in :loanVsAddendumMap.keySet() AND Addendum_Status__c='Pending' AND RecordType.DeveloperName='Ops_Disbursement'];
            for(Assignment__c assignment: assignmentRecords){
                if(loanVsAddendumMap.keySet().contains(assignment.Loan_Application__c)){
                    Assignment__c assignmentToUpdate = new Assignment__c();
                    assignmentToUpdate.Id = assignment.Id;
                    assignmentToUpdate.Addendum_Status__c = 'Complete';
                    sObjectListToUpsert.add(assignmentToUpdate);
                }
            }
            for(Integration_Checklist__c ic: icList){
                ContentVersion cvRecord = contentVersionRequestIds.get(ic.Request_Id__c);
                ContentDocumentLink cdl1 = new ContentDocumentLink();
                cdl1.ContentDocumentId = cvRecord.ContentDocumentId;
                cdl1.LinkedEntityId = ic.Loan_Application__c;
                system.debug('cvRecord '+cvRecord);
                system.debug('cvRecord.ContentDocumentId '+cvRecord.ContentDocumentId);
                ContentDocumentLink cdl2 = new ContentDocumentLink();
                cdl2.ContentDocumentId = cvRecord.ContentDocumentId;
                cdl2.LinkedEntityId = ic.Id;
                sObjectListToUpsert.add(cdl1);
                sObjectListToUpsert.add(cdl2);
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id = ic.Loan_Application__c;
                loan.Esign_Date__c = Date.today();
                loan.Esign_Status__c = 'Completed';
                sObjectListToUpsert.add(loan);
                ContentDocumentLink cdl3 = new ContentDocumentLink();
                cdl3.ContentDocumentId = cvRecord.ContentDocumentId;
                if(ic.Esign_Type__c == 'SI'){
                    cdl3.LinkedEntityId = loanVsSIMap.get(ic.Loan_Application__c);
                    sObjectListToUpsert.add(cdl3);
                }else if(ic.Esign_Type__c == 'Addendum Document'){
                    cdl3.LinkedEntityId = loanVsAddendumMap.get(ic.Loan_Application__c);
                    sObjectListToUpsert.add(cdl3);
                }else{
                    cdl3.LinkedEntityId = loanVsAgreementMap.get(ic.Loan_Application__c);
                    sObjectListToUpsert.add(cdl3);
                }
                
            }
        }
        if(sObjectListToUpsert!=null && sObjectListToUpsert.size()>0){
            if(Schema.sObjectType.ContentDocumentLink.isCreateable() && Schema.sObjectType.Loan_Application__c.isUpdateable()){
                upsert sObjectListToUpsert;
            }
            
            //Calling Notification   //29 AUG adding notification
            if(String.isNotBlank(loanId)){
                NotificationHandler.sendNotification('E sign',loanId,'');
            }
           //END

        }
        

    }

    public class EsignResponseWrapper{
        @AuraEnabled public SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper response{get;set;} 
        @AuraEnabled public Map<String,String> signerVsName{get;set;} 

    }
}