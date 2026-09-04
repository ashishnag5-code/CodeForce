public with sharing class CAMReportLWCController {

    public static void createCAMReportOnStageChange(Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap){
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>(); 
        Map<Id, Loan_Application__c> oldRecordMapTemp = (Map<Id, Loan_Application__c>) oldRecordMap;
        Map<Id, Loan_Application__c> newRecordMapTemp = (Map<Id, Loan_Application__c>) newRecordMap;
        for(Loan_Application__c loan: newRecordMapTemp.values()){
            if((loan.Stage__c == GlobalConstants.STAGE_CREDIT || loan.Stage__c == GlobalConstants.STAGE_PRICING || loan.Stage__c == GlobalConstants.STAGE_PSD) && oldRecordMapTemp.get(loan.Id).Stage__c=='DDE'){
                loanApps.add(loan);
            }
            system.debug('loanApps------ '+loanApps);
        }
        if(loanApps!=null && loanApps.size()==1){
            runCAMReportFromFutureMethod(loanApps[0].Id);
        }
    }

    @future(callout=true)
    public static void runCAMReportFromFutureMethod(Id recordId){
        runCAMReport(recordId);
    }

    @AuraEnabled
    public static ContentVersion runCAMReport(Id recordId){
        String fileId;
        ContentVersion contentVerRecord = new ContentVersion();
        try {
            List<Loan_Application__c> loans= [SELECT Id, Name, RecordType.DeveloperName FROM Loan_Application__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
            PageReference pdf;
            if(!loans.isEmpty()){
                if(loans[0].RecordType.DeveloperName == 'Two_Wheeler' || loans[0].RecordType.DeveloperName == 'Four_Wheeler'){
                    pdf = new pagereference('/apex/CAMReportPDFPage?id='+recordId);
                }else if(loans[0].RecordType.DeveloperName == 'Tractor'){
                    pdf = new pagereference('/apex/TractorCAMPDFPage?id='+recordId);
                }else{
                    pdf = new pagereference('/apex/CAMReportPDFPage?id='+recordId);
                }
            }else{
                pdf = new pagereference('/apex/CAMReportPDFPage?id='+recordId);
            }
            //PageReference pdf = new pagereference('/apex/CAMReportPDFPage?id='+recordId);
            pdf.getParameters().put('id', recordId);
            Blob body;
            Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
            Integer delayInMilliseconds = 3000; // One-second delay
            while (System.now().getTime() - startingTime < delayInMilliseconds)  {
                        // Do nothing until desired delay has passed
            }
            try {
                // returns page as a PDF
                if(Test.isRunningTest()){
                    body = Blob.valueOf('Some Content');
                }else{
                    body = pdf.getContentAsPdf();
                }
                DateTime dt = DateTime.now();



                
                ContentVersion cv = new ContentVersion();
                cv.VersionData = body;
                cv.Title = 'CAM_Report.pdf';
                cv.PathOnClient = 'CAM_Report.pdf';
                cv.isActive__c=true;
                cv.Loan_Application__c=loans[0].Name;
                if(SObjectType.ContentVersion.isCreateable() && SObjectType.ContentVersion.isUpdateable()){
                    insert cv;
                    fileId=cv.id;
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
                    cdl.LinkedEntityId = recordId;
                    if(SObjectType.ContentDocumentLink.isCreateable()){
                        insert cdl; 
                        List<ContentVersion> cvList = [SELECT Id, isActive__c, Title FROM ContentVersion WHERE Id !=:cv.Id AND  Title='CAM_Report.pdf' AND Loan_Application__c=:loans[0].Name AND isActive__c=true WITH SECURITY_ENFORCED];
                        for(ContentVersion cvTemp: cvList){
                            cvTemp.isActive__c=false;
                        }
                        update cvList;
                        contentVerRecord = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id AND  Title='CAM_Report.pdf' AND Loan_Application__c=:loans[0].Name AND isActive__c=true WITH SECURITY_ENFORCED];

                    }
                }else{
                    throw new AuraHandledException('Object Access Denied');
                }
                
            } catch (Exception e) {
                system.debug('Exception occured '+e);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contentVerRecord;
    }
    
    @AuraEnabled
    public static ContentVersion getLatestCAMReport(Id recordId){
        List<ContentVersion> cv = new List<ContentVersion>();
        try {
            List<Loan_Application__c> loans= [SELECT Id, Name FROM Loan_Application__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
            if(loans.size()>0)
                cv = [SELECT Id, isActive__c, VersionData, Title, ContentDocumentId FROM ContentVersion WHERE Title='CAM_Report.pdf' AND Loan_Application__c=:loans[0].Name AND isActive__c=true WITH SECURITY_ENFORCED Order by CreatedDate DESC LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        if(cv!=null && cv.size()>0)
            return cv[0];
        else
            return new ContentVersion();
    }

    @AuraEnabled
    public static List<Applicant__c> getActivePrimaryApplicants(String loanId){
        try {
            List<Applicant__c> applicantList = [SELECT Id, Loan__c, Loan__r.RecordType.DeveloperName FROM Applicant__c WHERE RecordType.DeveloperName=:GlobalConstants.APPLICANT_RECORD_TYPE AND isInactive__c=false AND Loan__c=:loanId];
            if(applicantList!=null && applicantList.size()>0){
                return applicantList;
            }else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static AUSFVehicleHandler.CollateralResponseWrapper getCollaterals(Id recordId){
        List<Integration_Checklist__c> newList = [SELECT Id, Response__c,Status_Code__c from Integration_Checklist__c WHERE Loan_Application__c=:recordId AND Integration_Master__r.Name='Collateral Dedupe API' WITH SECURITY_ENFORCED order by CreatedDate Desc];
        CollateralDedupeResponseWrapper objWrapper = new CollateralDedupeResponseWrapper();
        AUSFVehicleHandler.CollateralResponseWrapper resp = new AUSFVehicleHandler.CollateralResponseWrapper();
        if(newList!=null && newList.size()>0 && newList[0].Status_Code__c != '400'){
            objWrapper = (CollateralDedupeResponseWrapper) System.JSON.deserialize(newList[0].Response__c, CollateralDedupeResponseWrapper.class);
            resp.collaterals = AUSFVehicleHandler.mapSearchIntWraptoUIWrap(objWrapper);
            //resp.responseMessage=obj2.TransactionStatus.ResponseMessage;
            //resp.responseCode =obj2.TransactionStatus.ResponseCode;
            //resp.message =obj2.TransactionStatus.ExtendedErrorDetails.messages[0].message;
        }
        
        return resp;
    }

    @AuraEnabled
    public static DocumentDetailWrapper getAPIResponse(Id recordId){
        DocumentDetailWrapper wrapper = new DocumentDetailWrapper();
        try {
            List<Document_Checklist__c> docChecklists = [SELECT Id, Address_Match_Score__c, API_Response__c, Applicant__r.First_Name__c, Applicant__r.Last_Name__c, Document_Master__r.Name FROM Document_Checklist__c
                WHERE Id=:recordId WITH SECURITY_ENFORCED];
            if(!docChecklists.isEmpty()){
                Document_Checklist__c doc = docChecklists[0];
                wrapper.documentChecklist = doc;
                String documentName = doc.Document_Master__r.Name;
                String metadataType;
                if(documentName == 'AUWheels0005'){
                    metadataType='Passport';
                }else if(documentName=='AUWheels0002'){
                    metadataType='VoterId';
                }else if(documentName=='AUWheels0004'){
                    metadataType='Driving License';
                }else if(documentName=='AUWheels0093'){
                    metadataType='Electricity Bill';
                }/*else if(documentName=='AUWheels0004'){
                    metadataType='Gas Bill';
                }*/else if(documentName=='AUWheels0091'){
                    metadataType='PNG Bill';
                }
                wrapper.displayMetadata = LOSNsdlController.getMetadataRecord(metadataType);
                return wrapper;
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DocumentDetailWrapper{
        @AuraEnabled public Document_Checklist__c documentChecklist{get;set;}
        @AuraEnabled public List<Display_Data__mdt> displayMetadata{get;set;}
    }
}