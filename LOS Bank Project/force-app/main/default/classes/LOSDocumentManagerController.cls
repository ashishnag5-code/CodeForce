/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 12-18-2023
 * @last modified by  : Ajitesh
**/
public without sharing class LOSDocumentManagerController {
    public static Collateral__c collateral;
    public static String stage = '';
    public static String loanStage;

    public static List<Assignment__c> assignments;
    @AuraEnabled
    public static List<Applicant__c> getApplicants(Id recordId){
        List<Applicant__c> applicantList = [SELECT Id, First_Name__c, Last_Name__c,RecordTypeId, RecordType.Name FROM Applicant__c WHERE Loan__c=:recordId AND 
        RecordType.DeveloperName IN: GlobalConstants.APPLICANTS_RECORD_TYPES_ON_DOC AND IsInactive__c != true WITH SECURITY_ENFORCED];
        return applicantList;
    }
    @AuraEnabled
    public static List<Assignment__c> getAssignmentRecord(Id recordId){
       return [SELECT Id,Loan_Application__c FROM Assignment__c Where Id =: recordId];
    }
    @AuraEnabled
    public static String getDocumentChecklist(String recorIdStr,String objectApiName){
      try
      { //objectApiName='Field_investigation__c';
        Map<String,List<ResponseListWrapper>> docVsFilesMap= new Map<String,List<ResponseListWrapper>>();
        String whereClause ='';
        if(objectApiName == 'Loan_Application__c'){
            //whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\'';
            whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = false' ;
        }else if(objectApiName == 'System Generated'){
            //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
            whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = true AND Active__c = true' ;
        }
        else if(objectApiName == 'Field_investigation__c'){
            //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
            whereClause =' WHERE Field_investigation__c=\''+recorIdStr +'\' AND Loan_Application__c =null';
        }else if(objectApiName == 'pddMaker'){
            //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
            String vehicleDoc = 'Vehicle Document';
            String pdd = 'PDD';
            String verified = 'Verified';
            Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
            Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
            Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
           List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
           collateral = listOfColl[0];
            whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Category__c = \''+vehicleDoc +'\' AND Document_Master__r.Stage__c = \''+pdd +'\' Order by Document_Master__r.Document_Id__c';
        }else if(objectApiName == 'Vehicle Document'){
             Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
             Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
             Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
            List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
            collateral = listOfColl[0];
            String vehicleDoc = 'Vehicle Document';
            whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Document_Master__r.System_Generated__c = false Order by Document_Master__r.Document_Id__c';
        }else if(objectApiName == 'repayment'){
            whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Id__c IN (\'AUWheels0078\', \'AUWheels0079\',\'AUWheels0080\')';
        }else if(objectApiName == 'Assignment__c'){
            assignments = [SELECT Id,Loan_Application__c FROM Assignment__c Where Id =: recorIdStr];
            whereClause =' WHERE Loan_Application__c=\''+assignments[0].Loan_Application__c +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = false' ;
        }
        else{
            //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
            whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.System_Generated__c = false';
        }
          List<Document_Checklist__c> docChkList =  DocumentChecklistService.getDoucmentChecklist(whereClause);
          System.debug('docChkList: '+docChkList);
          Map<String,String> documentVsVersionId = new Map<String,String>();
          Map<String,String> documentVsConDocumentId = new Map<String,String>();
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = true;
          result.message = '';
          result.docChkList = docChkList;
          result.reponseWrapper = getVersionFiles(recorIdStr,objectApiName);
          for(ResponseListWrapper  versionRec: result.reponseWrapper){
            documentVsVersionId.put(versionRec.recordId,versionRec.contentVerId);
            documentVsConDocumentId.put(versionRec.recordId,versionRec.contentDocId);
            if(docVsFilesMap.containsKey(versionRec.recordId)){
                docVsFilesMap.get(versionRec.recordId).add(versionRec);
            }else{
                docVsFilesMap.put(versionRec.recordId, new List<ResponseListWrapper>{versionRec});
            }
          }
          List<Loan_Application__c> loanApps;

          if(objectApiName == 'System Generated'){
            loanApps = [SELECT Id,DO_Status__c,Sanction_Status__c FROM Loan_Application__c Where Id =: recorIdStr];
          }

          Profile objProfile = [ SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1];
          result.showVerification = objProfile.Name == 'Credit Manager' || objProfile.Name == 'Operations';
          result.showDocStatus = objProfile.Name == 'Sales';

          List<DocumentCheckListRecord> documentChlWrapList = new List<DocumentCheckListRecord>();
          for(Document_Checklist__c docRecord:docChkList){
            DocumentCheckListRecord docRecordWrp = new DocumentCheckListRecord();
            docRecordWrp.docName= docRecord;
            docRecordWrp.isReceived = docRecord.Document_Verification_Status__c == 'Verified' ? 'Received' : 'Not Received';
            docRecordWrp.isVerified = docRecord.Ops_Action__c == 'Ok' ? true : false;
            docRecordWrp.documentStatus = docRecord.Status__c;
            docRecordWrp.opsAction = docRecord.Ops_Action__c;
            docRecordWrp.opsRemark = docRecord.Ops_Remark__c;
            docRecordWrp.showVerified = getShowVerified(docRecord,objProfile,loanStage);
            docRecordWrp.canDownload =  getDownload(docRecord,objProfile);
            docRecordWrp.canDelete = getDelete(docRecord,objProfile,docRecordWrp.isVerified);
       
            docRecordWrp.documentTrackerId = docRecord.Document_Tracker_Id__c;
            if(stage == '' && docRecord.Loan_Application__c != null){
                stage = docRecord.Loan_Application__r.Stage__c;
                result.stage = stage;
            }
            docRecordWrp.isSystemGenerated =  docRecord.Document_Master__r.System_Generated__c;
            docRecordWrp.isDisabled = (docRecord.Document_Master__r.Document_Name__c == 'E Mandate') ? false : objectApiName == 'System Generated' && ((docRecord.Document_Master__r.Document_Name__c == 'Delivery Order' && loanApps[0].DO_Status__c == 'Issued') || (docRecord.Document_Master__r.Document_Name__c == 'Sanction letter' && loanApps[0].Sanction_Status__c == 'Issued')) ? true : false;
            docRecordWrp.isEmandate = docRecord.Document_Master__r.Document_Name__c == 'E Mandate';
            docRecordWrp.isESigned  = false;
            if(documentVsVersionId.containsKey(docRecord.Id)){
                docRecordWrp.isUploded = true;
                docRecordWrp.isReceived = 'Received';
                docRecordWrp.documentStatus = 'Received';
                docRecordWrp.contentVerId = documentVsVersionId.get(docRecord.Id);
                docRecordWrp.contentDocId = documentVsConDocumentId.get(docRecord.Id);
                docRecordWrp.filesList =docVsFilesMap.get(docRecord.Id);
                if(docRecordWrp.isSystemGenerated && docRecord.Document_Master__r.Consider_for_E_Sign__c){
                    for(ResponseListWrapper wrapper : docRecordWrp.filesList){
                            docRecordWrp.isESigned  = true;
                            break;
                        }
                    }
            }else{
                docRecordWrp.isUploded = false;
            }
            docRecordWrp.showUpload = docRecordWrp.isSystemGenerated && docRecord.Document_Master__r.Enable_Upload__c && docRecordWrp.isUploded ? true : docRecordWrp.isSystemGenerated ? false : true;
            docRecordWrp.showUpload = docRecordWrp.isVerified && docRecordWrp.documentStatus == 'Received'  && docRecordWrp.isSystemGenerated != true ? false : docRecordWrp.showUpload;
            if(objectApiName == 'pddMaker'){
                if(docRecord.Document_Master__r.Document_Name__c == 'Quotation/Performa Invoice' && result.invoiceChecklistRecord == null){
                    result.invoiceChecklistRecord = docRecordWrp;
                }else if(docRecord.Document_Master__r.Document_Name__c == 'Insurance' && result.insuranceChecklistRecord == null){
                    result.insuranceChecklistRecord = docRecordWrp;
                }else if(docRecord.Document_Master__r.Document_Name__c == 'Tax Clearance Certificate (TCC)' && result.taxChecklistRecord == null){
                    result.taxChecklistRecord = docRecordWrp;
                }else if(docRecord.Document_Master__r.Document_Name__c == 'RC Copy (Registration Certificate)' && result.rcChecklistRecord == null){
                    result.rcChecklistRecord = docRecordWrp;
                }else{
                    documentChlWrapList.add(docRecordWrp);
                }
            }else{
                documentChlWrapList.add(docRecordWrp);
            }
            }
            result.docChkRecords =documentChlWrapList;
            return JSON.serialize(result);
      }
      catch(Exception objException){
          Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
          ResultWrapper result = new ResultWrapper();
          result.isSuccess = false;
          result.message = objException.getMessage();
          result.docChkList = null;
          return JSON.serialize(result);
      }
       
      } 

      private static Boolean getShowVerified(Document_Checklist__c docCheck, Profile objProfile, String Stage){
         if((docCheck.Document_Master__r.Ownership__c == 'Credit / OPS' &&  (objProfile.Name == 'Credit Manager' && stage == 'Credit')) || (objProfile.Name == 'Operations' && (stage == 'Ops Maker' || stage == 'Ops Author'))){
            return true;
         }else if(docCheck.Document_Master__r.Ownership__c == 'Credit' && stage == 'Credit' && objProfile.Name == 'Credit Manager'){
            return true;
         }else if(docCheck.Document_Master__r.Ownership__c == 'Ops' && objProfile.Name == 'Operations' && (stage == 'Ops Maker' || stage == 'Ops Author')){
            return true;
         }
         return false;
      }

      private static Boolean getDownload(Document_Checklist__c docCheck, Profile objProfile){
        if(docCheck.Document_Master__r.System_Generated__c){
            return false;
        }
        else if(objProfile.Name == 'Credit Manager' && docCheck.Document_Master__r.Download_by_Credit__c){
           return true;
        }else if(objProfile.Name == 'Operations' && docCheck.Document_Master__r.Download_by_Ops__c){
            return true;
         }else if(objProfile.Name == 'Sales' && docCheck.Document_Master__r.Download_by_RO_COM_TCU__c){
            return true;
         }
          
        return false;
     }
     // Delete check added newly by yash to allow Deletion of Certain System generated Documents.
     private static Boolean getDelete(Document_Checklist__c docCheck, Profile objProfile,Boolean isVerified){
        //List<String> undeletableSystemGeneratedDocuments = System.Label.UndeletableSystemGeneratedDocuments.split(',');
        List<String> undeletableDocsList = System.Label.UndeletableSystemGeneratedDocuments.split(',');
         
        if((objProfile.Name == 'Sales' || objProfile.Name == 'System Administrator' || objProfile.Name == 'COM') && !isVerified){
            return true;
         }
        if(docCheck.Document_Master__r.System_Generated__c && !undeletableDocsList.contains(docCheck.Document_Master__r.Document_Name__c)){
            return true;
        }
                
         return false;
     }

     // New Method to check if User profile is valid to perform operations at the Stage
     @AuraEnabled
     public static Boolean isValidStageCheckProfileCheck(String loanId){
        if(String.isNotBlank(loanId)){
            List<Loan_Application__c> application = [SELECT Id, Stage__c FROM Loan_Application__c WHERE Id=:loanId LIMIT 1];
            Profile objProfile = [ SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
            List<DOC_Manager_Profile_Restriction__mdt> stageRecord = [SELECT Label,Id, Profile_Name__c, Stages__c FROM DOC_Manager_Profile_Restriction__mdt WHERE 
                                                              Profile_Name__c = :objProfile.Name LIMIT 1];
            if(!stageRecord.isEmpty()){
                List<String> availableStages = stageRecord[0].Stages__c.split(';');
                return availableStages.contains(application[0].Stage__c);
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
     }
     

      @AuraEnabled
      public static String saveDocList(String jsonStr){

        if(String.isblank(jsonStr)){
            return '';
        }
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(jsonStr);
        List<DocumentCheckListRecord> documentChlWrapList = (List<DocumentCheckListRecord>) JSON.deserialize(JSON.serialize(response.get('wrapper')),List<DocumentCheckListRecord>.class);
        List<Document_Checklist__c> docCheckList = new List<Document_Checklist__c>();
        List<Id> docIds = new List<Id>();
        for(DocumentCheckListRecord record : documentChlWrapList){
            docIds.add(record.docName.Id);
        }
        Map<Id,Document_Checklist__c> mapOfIdToDoc = new Map<Id,Document_Checklist__c>([SELECT Id, Credit_FTR_FTNR__c, Ops_FTR_FTNR__c, Mandatory__c FROM Document_Checklist__c WHERE Id IN :docIds ]);
        Boolean allESigned = true;
        String loanId = (String) response.get('loanId');
        Loan_Application__c loanObj = [SELECT Id,Stage__c FROM Loan_Application__c WHERE Id=:loanId];
        for(DocumentCheckListRecord record : documentChlWrapList){
          //  if(record.isVerified){
                if(record.isSystemGenerated && record.docName.Document_Master__r.Consider_for_E_Sign__c && !record.isESigned){
                    allESigned = false;
                }
                Document_Checklist__c doc = record.docName;
                doc.Ops_Action__c = record.isVerified ? 'Ok' : 'Not Ok';
                if(record.isVerified && mapOfIdToDoc.get(record.docName.Id).Credit_FTR_FTNR__c!='FTNR' && mapOfIdToDoc.get(record.docName.Id).Mandatory__c){
                    if(loanObj.Stage__c=='Credit'){
                        doc.Credit_FTR_FTNR__c = 'FTR';
                    }
                    else if(loanObj.Stage__c=='Ops Maker'){
                        doc.Ops_FTR_FTNR__c = 'FTR';
                    }
                }
                else if(!record.isVerified && mapOfIdToDoc.get(record.docName.Id).Mandatory__c){
                    if(loanObj.Stage__c=='Credit'){
                        doc.Credit_FTR_FTNR__c = 'FTNR';
                    }
                    else if(loanObj.Stage__c=='Ops Maker'){
                        doc.Ops_FTR_FTNR__c = 'FTNR';
                    }
                }
                doc.Status__c = record.documentStatus;
                docCheckList.add(doc);
           // }
            
        }
        update docCheckList;
        if(allESigned){
            //String loanId = (String) response.get('loanId');
            update new Loan_Application__c(Id = loanId, Esign_Status__c = 'Completed', Esign_Type__c = 'Physical' , Esign_Date__c = Date.Today() );
        }
        return 'success';
      }

      
      @AuraEnabled
      public static List<ResponseListWrapper> getVersionFiles(String recordId,String objectApiName){
          try {//objectApiName='Field_investigation__c';
              List<ResponseListWrapper> respWrapList = new List<ResponseListWrapper>();
              Set<Id> docChecklistIdsSet = new Set<Id>();
              Map<Id,String> docToMasterNameMap = new Map<Id,String>();
                List<Document_Checklist__c> docList;
                if(objectApiName == 'Loan_Application__c'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Loan_Application__c =:recordId AND Document_Master__r.System_Generated__c = false WITH SECURITY_ENFORCED];
                }else if(objectApiName == 'System Generated'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Loan_Application__c =:recordId AND Document_Master__r.System_Generated__c = true WITH SECURITY_ENFORCED];
                }
                else if(objectApiName == 'Field_investigation__c'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Field_investigation__c =:recordId WITH SECURITY_ENFORCED];
                }else if(objectApiName == 'pddMaker'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Collateral__c =: collateral.Id AND Document_Master__r.Document_Category__c = 'Vehicle Document' AND Document_Master__r.Stage__c = 'PDD'  WITH SECURITY_ENFORCED];
                }else if(objectApiName == 'Vehicle Document'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Collateral__c  =:collateral.Id  WITH SECURITY_ENFORCED];
                }else if(objectApiName == 'repayment'){  
                    Set<String> docsToFetch = new Set<String>{'AUWheels0078','AUWheels0079','AUWheels0080'};
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Applicant__c =:recordId AND Document_Master__r.Document_Id__c IN: docsToFetch WITH SECURITY_ENFORCED];
                }else if(objectApiName == 'Assignment__c'){
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Loan_Application__c =:assignments[0].Loan_Application__c AND Document_Master__r.System_Generated__c = false WITH SECURITY_ENFORCED];
                }
                else if(objectApiName == 'TAR'){
                    Set<String> documentIds = new Set<String>();
                    for(Tractor_TAR_Form_Config__mdt trackDoc : [SELECT Image_Field_To_Display__c FROM Tractor_TAR_Form_Config__mdt WHERE Collateral_Type__c != null WITH SECURITY_ENFORCED]){
                        for(String docId : trackDoc.Image_Field_To_Display__c.split(',')){
                            documentIds.add(docId.trim());
                        }
                    }
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Collateral__c =:recordId AND Document_Master__r.Document_Id__c IN: documentIds  WITH SECURITY_ENFORCED];
                }
                else{
                    docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Applicant__c =:recordId WITH SECURITY_ENFORCED];
                }
                  
                  if(!docList.isEmpty()){
                      for(Document_Checklist__c doc : docList){
                          docChecklistIdsSet.add(doc.Id);
                          docToMasterNameMap.put(doc.Id, doc.Document_Master__r.Document_Name__c);
                      }
                  }
                  Set<Id> contentDocumentIds = new Set<Id>();
                  Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
                  if(objectApiName == 'Field_investigation__c'){
                    for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet WITH SECURITY_ENFORCED]) {
                        contentDocumentIds.add(each.ContentDocumentId);
                        docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
                    }
                  }else if(objectApiName == 'System Generated'){
                    for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet AND (ContentDocument.LatestPublishedVersion.isActive__c=TRUE OR ContentDocument.Title LIKE '%eSigned%') WITH SECURITY_ENFORCED]) {
                        contentDocumentIds.add(each.ContentDocumentId);
                        docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
                    }
                  }
                  else{
                    for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED]) {
                        contentDocumentIds.add(each.ContentDocumentId);
                        docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
                    }
                   
                  }
                  
                  
  
                  List<ContentVersion> contVerList = [SELECT Id, Title,ContentDocumentId,FileType,FileExtension,FirstPublishLocationId FROM ContentVersion
                                                      WHERE ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED
                                                      ORDER BY CreatedDate DESC ];
                  for(ContentVersion cv : contVerList){
                      ResponseListWrapper resp = new ResponseListWrapper();
                      resp.fileName = cv.Title;
                      resp.docName = docToMasterNameMap.get(docIdToChecklistId.get(cv.ContentDocumentId));
                      resp.url = '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
                      resp.downloadurl= '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
                      //resp.url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+cv.Id;
                      resp.fileType = cv.FileExtension;
                      resp.recordId = docIdToChecklistId.get(cv.ContentDocumentId);//cv.Id;
                      resp.contentDocId = cv.ContentDocumentId;
                      resp.contentVerId = cv.Id;
                      respWrapList.add(resp);

                  }
              //}
              return respWrapList;
          } catch (Exception e) {
              throw new AuraHandledException(e.getMessage());
          }
      }
    
    
      Public class ResultWrapper{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public Boolean showVerification{get;set;}
        @AuraEnabled
        public Boolean showDocStatus{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public List<Document_Checklist__c> docChkList{get;set;}
        @AuraEnabled
        public List<DocumentCheckListRecord> docChkRecords{get;set;}
        @AuraEnabled
        public DocumentCheckListRecord invoiceChecklistRecord{get;set;}
        @AuraEnabled
        public DocumentCheckListRecord insuranceChecklistRecord{get;set;}
        @AuraEnabled
        public DocumentCheckListRecord taxChecklistRecord{get;set;}
        @AuraEnabled
        public DocumentCheckListRecord rcChecklistRecord{get;set;}
        @AuraEnabled
        public List<ResponseListWrapper> reponseWrapper {get;set;}
        @AuraEnabled
        public String stage{get;set;}
    }
    public class DocumentCheckListRecord{
        @AuraEnabled
        public Document_Checklist__c docName{get;set;}
        @AuraEnabled
        public List<ResponseListWrapper> filesList{get;set;}
        @AuraEnabled
        public Boolean isUploded{get;set;}
        @AuraEnabled
        public String contentVerId{get;set;}
        @AuraEnabled
        public String contentDocId{get;set;}
        @AuraEnabled
        public String isReceived{get;set;}
        @AuraEnabled
        public boolean isVerified{get;set;}
        @AuraEnabled
        public String documentStatus{get;set;}
        @AuraEnabled
        public String opsAction{get;set;}
        @AuraEnabled
        public String opsRemark{get;set;}
        @AuraEnabled
        public Boolean showVerified{get;set;}
        @AuraEnabled
        public Boolean canDownload{get;set;}
        @AuraEnabled
        public Boolean canDelete{get;set;}
        @AuraEnabled
        public Boolean isSystemGenerated{get;set;}
        @AuraEnabled
        public Boolean showUpload{get;set;}
        @AuraEnabled
        public Boolean isDisabled{get;set;}
        @AuraEnabled
        public Boolean isEmandate{get;set;}
        @AuraEnabled
        public Boolean isESigned{get;set;}
        @AuraEnabled
        public String documentTrackerId {get; set;}
@AuraEnabled
        public Boolean canGenerate{get;set;}
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
    @AuraEnabled
    public static String deactivateDocument(Id recordId){
        try{
            ContentVersion conRecord =new  ContentVersion();
            conRecord.Id = recordId;
            conRecord.isActive__c = false;
            if(Schema.sObjectType.ContentVersion.isUpdateable()){
                update conRecord;
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
    public static List<Loan_Application__c> getLoanDetails(Id recordId){
        return [SELECT Id,stage__c FROM Loan_Application__c Where Id =: recordId];
    }
    @AuraEnabled
    public static String getDocumentChecklistOptional(String recorIdStr,String objectApiName,Boolean dofetchOptionalDocs){
        
        system.debug('recorIdStr::'+recorIdStr);
        system.debug('objectApiName::'+objectApiName);
        system.debug('dofetchOptionalDocs::'+dofetchOptionalDocs);
        try
        { //objectApiName='Field_investigation__c';
            Map<String,List<ResponseListWrapper>> docVsFilesMap= new Map<String,List<ResponseListWrapper>>();
            String whereClause ='';
            if(dofetchOptionalDocs != null && dofetchOptionalDocs){
                if(objectApiName == 'Loan_Application__c'){
                    //whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =true' ;
                }else if(objectApiName == 'System Generated'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = true AND Document_Master__r.Mandatory__c =true' ;
                }
                else if(objectApiName == 'Field_investigation__c'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Field_investigation__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =true';
                }else if(objectApiName == 'pddMaker'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    String vehicleDoc = 'Vehicle Document';
                    String pdd = 'PDD';
                    String verified = 'Verified';
                    Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
                    Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
                    Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
                        List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
                    if(listOfColl!=null && !listOfColl.isEmpty()){
                        collateral = listOfColl[0];
                        whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Category__c = \''+vehicleDoc +'\' AND Document_Master__r.Stage__c = \''+pdd +'\' AND Document_Master__r.Mandatory__c =true Order by Document_Master__r.Document_Id__c';
                    }
                }else if(objectApiName == 'Vehicle Document'){
                    Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
                    Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
                    Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
                        List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
                    if(listOfColl!=null && !listOfColl.isEmpty()){
                        collateral = listOfColl[0];
                        String vehicleDoc = 'Vehicle Document';
                        whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =true Order by Document_Master__r.Document_Id__c';
                    }
                }else if(objectApiName == 'repayment'){
                    whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Id__c IN (\'AUWheels0078\', \'AUWheels0079\',\'AUWheels0080\') AND Document_Master__r.Mandatory__c =true ';
                }else if(objectApiName == 'Assignment__c'){
                    assignments = [SELECT Id,Loan_Application__c FROM Assignment__c Where Id =: recorIdStr];
                    whereClause =' WHERE Loan_Application__c=\''+assignments[0].Loan_Application__c +'\' AND Applicant__c = null AND Document_Master__r.Mandatory__c =true AND Document_Master__r.System_Generated__c = false' ;
                }
                else{
                    
                    list<applicant__C> applicantRec = [select id, Customer_Type__c from applicant__C where id =:recorIdStr];
                    system.debug('applicantRec:::'+applicantRec);
                    if(applicantRec!=null && (applicantRec[0].Customer_Type__c =='Individual'))
                    whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null  AND (  Document_Master__r.Mandatory__c =true OR Document_Master__r.Document_Sub_Category__c =\'KYC\') AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Individual_NI__c IN (\'ALL\', \'I\')';
                    else
                     whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null  AND Document_Master__r.Mandatory__c =true AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Individual_NI__c IN (\'NI\',\'ALL\')';
                }
            }
            else {
                
                if(objectApiName == 'Loan_Application__c'){
                    //whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =false' ;
                }else if(objectApiName == 'System Generated'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = true AND Document_Master__r.Mandatory__c =false' ;
                }
                else if(objectApiName == 'Field_investigation__c'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    whereClause =' WHERE Field_investigation__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =false';
                }else if(objectApiName == 'pddMaker'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    String vehicleDoc = 'Vehicle Document';
                    String pdd = 'PDD';
                    String verified = 'Verified';
                    Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
                    Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
                    Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
                        List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
                    if(listOfColl!=null && !listOfColl.isEmpty()){
                        collateral = listOfColl[0];
                        whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Category__c = \''+vehicleDoc +'\' AND Document_Master__r.Stage__c = \''+pdd +'\' AND Document_Master__r.Mandatory__c =false Order by Document_Master__r.Document_Id__c';
                    }
                }else if(objectApiName == 'Vehicle Document'){
                    Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
                    Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
                    Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
                        List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED];
                    system.debug('listOfColl:::'+listOfColl);
                    if(listOfColl!=null && !listOfColl.isEmpty()){
                        collateral = listOfColl[0];
                        String vehicleDoc = 'Vehicle Document';
                        whereClause =' WHERE Collateral__c=\''+collateral.Id +'\' AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =false Order by Document_Master__r.Document_Id__c';
                    }
                }else if(objectApiName == 'repayment'){
                    whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Document_Id__c IN (\'AUWheels0078\', \'AUWheels0079\',\'AUWheels0080\') AND Document_Master__r.Mandatory__c =false ';
                }else if(objectApiName == 'Assignment__c'){
                    assignments = [SELECT Id,Loan_Application__c FROM Assignment__c Where Id =: recorIdStr];
                    whereClause =' WHERE Loan_Application__c=\''+assignments[0].Loan_Application__c +'\' AND Applicant__c = null AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false' ;
                }
                else{
                    
                    list<applicant__C> applicantRec = [select id, Customer_Type__c from applicant__C where id =:recorIdStr];
                    system.debug('applicantRec::::'+applicantRec);
                    if(applicantRec!=null && (applicantRec[0].Customer_Type__c =='Individual'))
                    whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null  AND (  Document_Master__r.Mandatory__c =false AND Document_Master__r.Document_Sub_Category__c !=\'KYC\') AND Document_Master__r.System_Generated__c = false  AND Document_Master__r.Individual_NI__c IN (\'ALL\', \'I\')';
               		 else 
                     whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null  AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false  AND Document_Master__r.Individual_NI__c IN (\'NI\',\'ALL\')';   

                  
                   // whereClause =' WHERE Applicant__c=\''+recorIdStr +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Individual_NI__c IN (\'All\', \'I\')';
                }
                
            }
            
            
            List<Document_Checklist__c> docChkList =  DocumentChecklistService.getDoucmentChecklist(whereClause);
           
            system.debug('query string::'+whereClause);
            system.debug('docChkList::'+docChkList);
            Map<String,String> documentVsVersionId = new Map<String,String>();
            Map<String,String> documentVsConDocumentId = new Map<String,String>();
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = true;
            result.message = '';
            result.docChkList = docChkList;
            result.reponseWrapper = getVersionFiles(recorIdStr,objectApiName);
            for(ResponseListWrapper  versionRec: result.reponseWrapper){
                
                documentVsVersionId.put(versionRec.recordId,versionRec.contentVerId);
                documentVsConDocumentId.put(versionRec.recordId,versionRec.contentDocId);
                if(docVsFilesMap.containsKey(versionRec.recordId)){
                    docVsFilesMap.get(versionRec.recordId).add(versionRec);
                }else{
                    docVsFilesMap.put(versionRec.recordId, new List<ResponseListWrapper>{versionRec});
                }
            }
            List<Loan_Application__c> loanApps;
            
            if(objectApiName == 'System Generated'){
                loanApps = [SELECT Id,DO_Status__c,Sanction_Status__c,Stage__c FROM Loan_Application__c Where Id =: recorIdStr];
                loanStage = loanApps[0].Stage__c;
            }
            
if(objectApiName =='Applicant__c'){
                list<Applicant__c> appRecord= [select id,Loan__r.Stage__c from Applicant__c where Id =:recorIdStr];
                if(appRecord!=null && !appRecord.isEmpty())
                    loanStage = appRecord[0].Loan__r.Stage__c;
            }
            else if(objectApiName =='Loan_Application__c'){
                list<Loan_Application__c> loaRecord= [select id,Stage__c from Loan_Application__c where Id =:recorIdStr];
                if(loaRecord!=null && !loaRecord.isEmpty())
                    loanStage = loaRecord[0].Stage__c;
            }
            else if(objectApiName =='Vehicle Document'){
                list<Loan_Application__c> loaRecord= [select id,Stage__c from Loan_Application__c where Id =:recorIdStr];
                if(loaRecord!=null && !loaRecord.isEmpty())
                    loanStage = loaRecord[0].Stage__c;
            }
            
            Profile objProfile = [ SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1];
            result.showVerification = objProfile.Name == 'Credit Manager' || objProfile.Name == 'Operations';
            result.showDocStatus = objProfile.Name == 'Sales';
            
            List<DocumentCheckListRecord> documentChlWrapList = new List<DocumentCheckListRecord>();
            for(Document_Checklist__c docRecord:docChkList){
                DocumentCheckListRecord docRecordWrp = new DocumentCheckListRecord();
                docRecordWrp.docName= docRecord;
                docRecordWrp.isReceived = docRecord.Document_Verification_Status__c == 'Verified' ? 'Received' : 'Not Received';
                docRecordWrp.isVerified = docRecord.Ops_Action__c == 'Ok' ? true : false;
                docRecordWrp.documentStatus = docRecord.Status__c;
                docRecordWrp.opsAction = docRecord.Ops_Action__c;
                docRecordWrp.opsRemark = docRecord.Ops_Remark__c;
                docRecordWrp.showVerified = getShowVerified(docRecord,objProfile,loanStage);
                docRecordWrp.canDownload =  getDownload(docRecord,objProfile);
                docRecordWrp.canDelete = getDelete(docRecord,objProfile,docRecordWrp.isVerified);
                if(docRecord.Document_Master__r.Document_Name__c == 'Application form'){
               system.debug('Document_Name__c::'+docRecord.Document_Master__r.Document_Name__c);
               system.debug('docRecord.Ops_Action__c::'+docRecord.Ops_Action__c);
                    system.debug('docRecordWrp.canDelete::'+docRecordWrp.canDelete);
                      system.debug('docRecordWrp.isVerified)::'+docRecordWrp.isVerified);
                }
                docRecordWrp.documentTrackerId = docRecord.Document_Tracker_Id__c;
                if(stage == '' && docRecord.Loan_Application__c != null){
                    stage = docRecord.Loan_Application__r.Stage__c;
                    result.stage = stage;
                }
                docRecordWrp.isSystemGenerated = docRecord.Document_Master__r.System_Generated__c;
                docRecordWrp.isDisabled = (docRecord.Document_Master__r.Document_Name__c == 'E Mandate' && !docRecordWrp.isVerified) ? false : objectApiName == 'System Generated' && ((docRecord.Document_Master__r.Document_Name__c == 'Delivery Order' && loanApps[0].DO_Status__c == 'Issued') || (docRecord.Document_Master__r.Document_Name__c == 'Sanction letter' && loanApps[0].Sanction_Status__c == 'Issued')) ? true : false;
                docRecordWrp.isEmandate = docRecord.Document_Master__r.Document_Name__c == 'E Mandate';
                docRecordWrp.isESigned  = false;
                if(documentVsVersionId.containsKey(docRecord.Id)){
                    docRecordWrp.isUploded = true;
                    docRecordWrp.isReceived = 'Received';
                    docRecordWrp.documentStatus = 'Received';
                    docRecordWrp.contentVerId = documentVsVersionId.get(docRecord.Id);
                    docRecordWrp.contentDocId = documentVsConDocumentId.get(docRecord.Id);
                    docRecordWrp.filesList =docVsFilesMap.get(docRecord.Id);
                    if(docRecordWrp.isSystemGenerated && docRecord.Document_Master__r.Consider_for_E_Sign__c){
                        for(ResponseListWrapper wrapper : docRecordWrp.filesList){
                                docRecordWrp.isESigned  = true;
                                break;
                        }
                    }
                }else{
                    docRecordWrp.isUploded = false;
                }
                docRecordWrp.showUpload = docRecordWrp.isSystemGenerated && docRecord.Document_Master__r.Enable_Upload__c && docRecordWrp.isUploded ? true : docRecordWrp.isSystemGenerated ? false : true;
                docRecordWrp.showUpload = docRecordWrp.isVerified && docRecordWrp.documentStatus == 'Received'  && docRecordWrp.isSystemGenerated != true ? false : docRecordWrp.showUpload;               
                if(objectApiName == 'pddMaker'){
                    if(docRecord.Document_Master__r.Document_Name__c == 'Quotation/Performa Invoice' && result.invoiceChecklistRecord == null){
                        result.invoiceChecklistRecord = docRecordWrp;
                    }else if(docRecord.Document_Master__r.Document_Name__c == 'Insurance' && result.insuranceChecklistRecord == null){
                        result.insuranceChecklistRecord = docRecordWrp;
                    }else if(docRecord.Document_Master__r.Document_Name__c == 'Tax Clearance Certificate (TCC)' && result.taxChecklistRecord == null){
                        result.taxChecklistRecord = docRecordWrp;
                    }else if(docRecord.Document_Master__r.Document_Name__c == 'RC Copy (Registration Certificate)' && result.rcChecklistRecord == null){
                        result.rcChecklistRecord = docRecordWrp;
                    }else{
                        documentChlWrapList.add(docRecordWrp);
                    }
                }else{
                    documentChlWrapList.add(docRecordWrp);
                }
            }
            result.docChkRecords =documentChlWrapList;
            return JSON.serialize(result);
        }
        catch(Exception objException){
            system.debug('objException'+objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            result.docChkList = null;
            return JSON.serialize(result);
        }
        
    } 

    @AuraEnabled(cacheable=true)
    public static list<sObject> retrieveRecords(string searchKey , string sObjectApiName,String recorIdStr,String applicantRecord) {    
        List < sObject > returnList = new List < sObject > ();
        
        system.debug('searchKey::'+searchKey);
        system.debug('sObjectApiName::'+sObjectApiName);
        system.debug('recorIdStr::'+recorIdStr);
        system.debug('applicantRecord::'+applicantRecord);
        
        String conditions='';
        string sWildCardText = '%' + searchKey + '%';
        
        if(sObjectApiName == 'Loan_Application__c'){
            //whereClause =' WHERE Loan_Application__c=\''+recorIdStr +'\'';
            conditions =' AND Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =false  limit 50000' ;
        }
        else if(sObjectApiName == 'System Generated'){
                    //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
                    conditions =' AND Loan_Application__c=\''+recorIdStr +'\' AND Applicant__c = null AND Document_Master__r.System_Generated__c = true AND Document_Master__r.Mandatory__c =false  limit 50000' ;
                }
        else if(sObjectApiName == 'Vehicle Document'){
            Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
            Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
            Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
                List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:recorIdStr AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true WITH SECURITY_ENFORCED limit 50000];
            if(listOfColl!=null && !listOfColl.isEmpty()){
                collateral = listOfColl[0];
                String vehicleDoc = 'Vehicle Document';
                conditions =' AND Collateral__c=\''+collateral.Id +'\' AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Mandatory__c =false Order by Document_Master__r.Document_Id__c limit 50000';
            }
        }
        else{
            //whereClause =' WHERE Applicant__c=\''+recorIdStr +'\'';
List<Applicant__c> applicants = [SELECT Id,Customer_Type__c FROM Applicant__c Where Id =: applicantRecord AND IsInactive__c = false ];
            if(!applicants.isEmpty() && applicants[0].Customer_Type__c == 'Individual'){
                String customerType  = 'NI';
                conditions =' AND Applicant__c=\''+applicantRecord +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Document_Sub_Category__c !=\'KYC\' AND Document_Master__r.Individual_NI__c !=   \''+customerType +'\' limit 50000';
            }else if(!applicants.isEmpty() && applicants[0].Customer_Type__c == 'Non Individual'){
                String customerType  = 'I';
                conditions =' AND Applicant__c=\''+applicantRecord +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false AND Document_Master__r.Individual_NI__c !=  \''+customerType +'\'  limit 50000';
            }else{
            conditions =' AND Applicant__c=\''+applicantRecord +'\' AND Loan_Application__c =null AND Document_Master__r.Mandatory__c =false AND Document_Master__r.System_Generated__c = false  limit 50000';
}
        }
        
        string sQuery = 'Select id,Document_master__r.Document_Name__c From Document_Checklist__c Where Document_master__r.Document_Name__c Like : sWildCardText '+conditions;
        system.debug('sQuery::'+sQuery);
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        
        system.debug('returnList::'+returnList);
        return returnList;
    }

    @AuraEnabled
    public static String checkFTRStatus(String docCheckRecord, String loanId){
        if( String.isBlank(docCheckRecord) ) return null;
        try {
            //Document_Checklist__c documentRecToUpdate = (Document_Checklist__c)JSON.deserialize(docCheckRecord, Document_Checklist__c.class);
            //System.debug('docCheckRec '+documentRecToUpdate);
            Document_Checklist__c docChcklist = [SELECT Id,Document_Verification_Status__c,Mandatory__c,Credit_FTR_FTNR__c,Ops_FTR_FTNR__c FROM Document_Checklist__c WHERE Id=:docCheckRecord];
            Profile userProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
            Loan_Application__c loanObj = [SELECT Stage__c, Id FROM Loan_Application__c WHERE Id=:loanId];
            if(docChcklist.Document_Verification_Status__c=='Not Verified' && userProfile.Name=='Sales' && docChcklist.Mandatory__c){
                if(loanObj.Stage__c=='Credit'){
                    docChcklist.Credit_FTR_FTNR__c = 'FTNR';
                }
                else if(loanObj.Stage__c=='Ops Maker'){
                    docChcklist.Ops_FTR_FTNR__c = 'FTNR';
                }
            }
            update docChcklist;
            return 'Success';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static String updateEMandateStatus(String loanId){
        if(String.isBlank(loanId)){
            return '';
        }

        List<Loan_Application__c> loanApps = [SELECT Id,E_Mandate_Status__c FROM Loan_Application__c Where Id =: loanId Limit 1];
        if(!loanApps.isEmpty() && loanApps[0].E_Mandate_Status__c != 'Accepted'){
            loanApps[0].E_Mandate_Status__c = 'Accepted';
            update loanApps[0];
            
        }
        return 'success';
    }
    
}