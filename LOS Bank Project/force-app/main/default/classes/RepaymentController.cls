public class RepaymentController {
	/*@AuraEnabled
    public static List<Bank_Account_Records__c> getBankAccountRecords(String loanId,String repaymentMode){
        Applicant__c appObj = [SELECT Id, Mobile_Number__c  FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.DeveloperName='Primary_Applicant'];
        List<Bank_Account_Records__c> listOfBankAccounts;
        if(repaymentMode!=null && repaymentMode.contains('E mandate')){
            listOfBankAccounts = [SELECT Id, Bank_Name__c ,Account_Name__c,Account_Number__c,Branch_Name__c, Loan_Number__c,Name  FROM Bank_Account_Records__c WHERE Applicant__c=:appObj.Id AND RecordType.Name='Cart'];
        }
        else if(repaymentMode!=null){
            listOfBankAccounts = [SELECT Id, Bank_Name__c ,Account_Name__c,Account_Number__c,Branch_Name__c, Loan_Number__c,Name  FROM Bank_Account_Records__c WHERE Applicant__c=:appObj.Id AND RecordType.Name='CBS'];
        }
        return listOfBankAccounts;
    } 
    
    @AuraEnabled
    public static void saveRepaymentDetails(Bank_Account_Records__c obj,String loanId){
        if(obj!=null){
            Loan_Application__c loanObj = new Loan_Application__c(Id=loanId);
            loanObj.Repayment_Account_Number__c = obj.Account_Number__c;
            loanObj.Repayment_Bank_Name__c = obj.Bank_Name__c;
            System.debug('loanoBj '+loanObj);
            update loanObj;
        }
    }*/

    @AuraEnabled
    public static Assignment__c getApplicantInitData(String assignmentId){
        List<Assignment__c> assignmentRec = new List<Assignment__c>();
        assignmentRec = [SELECT Id, Loan_Application__c, Loan_Application__r.Name, Loan_Application__r.Loan_Number__c, Loan_Application__r.Loan_Amount__c,
                        Loan_Application__r.E_Mandate_Status__c, Loan_Application__r.EMI_Date__c, Loan_Application__r.EMI__c, Loan_Application__r.First_EMI_Date__c, Loan_Application__r.SPDC_Details__c,
                        Loan_Application__r.PDC_Details__c, Loan_Application__r.Repayment_Mode__c, Loan_Application__r.Count_of_ACH_SI__c,
                        Loan_Application__r.RecordTypeId, Loan_Application__r.Repayment_Bank_Name__c, Loan_Application__r.Repayment_Account_Number__c,
                        Loan_Application__r.Tenure__c, Loan_Application__r.Emandate_Journey__c, Loan_Application__r.Emandate_Payment_Type__c FROM Assignment__c WHERE 
                        Id=:assignmentId];
        return assignmentRec[0];
    }

    @AuraEnabled
    public static List<IFSC_Master__c> getValidBankNameAndIFSC(List<String> selectedPdcIfscCodes){
        try {
            Set<String> ifscSet = new Set<String>();
            ifscSet.addAll(selectedPdcIfscCodes);
            List<IFSC_Master__c> ifscMaster = [SELECT Id, Bank_Name__c, IFSC__c from IFSC_Master__c WHERE IFSC__c in: ifscSet];
            if(ifscMaster!=null && ifscMaster.size()>0){
                return ifscMaster;
            }else{
                return null;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getCASADetails(String loanId){
        Applicant__c appObj = [SELECT Id, Mobile_Number__c  FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.DeveloperName='Primary_Applicant'];
        Loan_Application__c loanObj = [SELECT Repayment_Account_Number__c FROM Loan_Application__c WHERE Id=:loanId];
        Bank_Account_Records__c bankAccountRecord;
        bankAccountRecord = [SELECT Id, CASARelationshipDetails__c  FROM Bank_Account_Records__c WHERE Applicant__c=:appObj.Id AND Account_Number__c=:loanObj.Repayment_Account_Number__c];
        return bankAccountRecord.CASARelationshipDetails__c;
    }
    @AuraEnabled
    public static String getDocumentRecordsData(String loanId){
        Id recId = (Id)loanId;

        String sObjName = recId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Assignment__c'){
            List<Assignment__c> assignmentRec = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:loanId];
            if(assignmentRec.size()>0)
            loanId = assignmentRec[0].Loan_Application__c;

        }
        Applicant__c appObj = [SELECT Id, Mobile_Number__c  FROM Applicant__c WHERE Loan__c=:loanId AND RecordType.DeveloperName='Primary_Applicant'];
            String response = LOSDocumentManagerController.getDocumentChecklist(appObj.Id,'repayment');
            System.debug('response-> + >' + response);
            return response;
    }

    @AuraEnabled
    public static String uploadSIForm(String loanId){
        ContentVersion contentVerRecord=new ContentVersion();
        Loan_Application__c loanObj = [SELECT Id, Name, (SELECT Id FROM Document_Checklists__r WHERE Document_Master__r.Name='AUWheels0045') FROM Loan_Application__c WHERE Id=:loanId LIMIT 1];
        PageReference pdf = new pagereference('/apex/RepaymentSIVFPage?recordid='+loanId);
        pdf.getParameters().put('recordid', loanId);
        Blob body;
        try {
            if(loanObj!=null && loanObj.Document_Checklists__r!=null && loanObj.Document_Checklists__r.size()>0){
                if(Test.isRunningTest()){
                    body = Blob.valueOf('Some Content');
                }else{
                    body = pdf.getContent();
                }
                ContentVersion cv = new ContentVersion();
                cv.VersionData = body;
                cv.Title = 'Repayment_SI.pdf';
                cv.PathOnClient = 'Repayment_SI.pdf';
                cv.isActive__c=true;
                cv.Loan_Application__c=loanObj.Name;
                if(SObjectType.ContentVersion.isCreateable() && SObjectType.ContentVersion.isUpdateable()){
                    insert cv;
                    Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
                    ContentDocumentLink cdl1 = new ContentDocumentLink();
                    cdl1.ContentDocumentId = contentDocumentId;
                    cdl1.LinkedEntityId = loanObj.Document_Checklists__r[0].Id;
                    if(SObjectType.ContentDocumentLink.isCreateable()){
                        insert cdl1; 
                        List<ContentVersion> cvList = [SELECT Id, isActive__c, Title FROM ContentVersion WHERE Id !=:cv.Id AND  Title='Repayment_SI.pdf' AND Loan_Application__c=:loanObj.Name AND isActive__c=true WITH SECURITY_ENFORCED];
                        for(ContentVersion cvTemp: cvList){
                            cvTemp.isActive__c=false;
                        }
                        update cvList;
                        contentVerRecord = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id AND  Title='Repayment_SI.pdf' AND Loan_Application__c=:loanObj.Name AND isActive__c=true WITH SECURITY_ENFORCED];

                    }else{
                        throw new AuraHandledException('Object Access Denied');
                    }
                }else{
                    throw new AuraHandledException('Object Access Denied');
                }
            }else{
                return contentVerRecord.ContentDocumentId+';SI Not Applicable';
            }
            
        } catch (Exception e) {
            system.debug('Exception occured '+e);
        }  
        return contentVerRecord.ContentDocumentId+';Success';        
    }

    @AuraEnabled
    public static String uploadACHForm(String loanId){
        ContentVersion contentVerRecord=new ContentVersion();
        Loan_Application__c loanObj = [SELECT Id, Name, (SELECT Id FROM Document_Checklists__r WHERE Document_Master__r.Name='AUWheels0078') FROM Loan_Application__c WHERE Id=:loanId LIMIT 1];
        //PageReference pdf = new pagereference('/apex/RepaymentACHVFPage?recordid='+loanId);
        PageReference pdf = new pagereference('/apex/nachPage?recordid='+loanId);
        pdf.getParameters().put('recordid', loanId);
        Blob body;
        try {
            //if(loanObj!=null && loanObj.Document_Checklists__r!=null && loanObj.Document_Checklists__r.size()>0){
                if(Test.isRunningTest()){
                    body = Blob.valueOf('Some Content');
                }else{
                    body = pdf.getContent();
                }
                ContentVersion cv = new ContentVersion();
                cv.VersionData = body;
                cv.Title = 'Repayment_ACH.pdf';
                cv.PathOnClient = 'Repayment_ACH.pdf';
                cv.isActive__c=true;
                cv.Loan_Application__c=loanObj.Name;
                if(SObjectType.ContentVersion.isCreateable() && SObjectType.ContentVersion.isUpdateable()){
                    insert cv;
                    System.debug('content id '+cv.id);
                    Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
                    contentVerRecord = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id AND  Title='Repayment_ACH.pdf' AND Loan_Application__c=:loanObj.Name AND isActive__c=true WITH SECURITY_ENFORCED];
                    /*ContentDocumentLink cdl1 = new ContentDocumentLink();
                    cdl1.ContentDocumentId = contentDocumentId;
                    cdl1.LinkedEntityId = loanObj.Document_Checklists__r[0].Id;
                    if(SObjectType.ContentDocumentLink.isCreateable()){
                        insert cdl1; 
                        List<ContentVersion> cvList = [SELECT Id, isActive__c, Title FROM ContentVersion WHERE Id !=:cv.Id AND  Title='Repayment_ACH.pdf' AND Loan_Application__c=:loanObj.Name AND isActive__c=true WITH SECURITY_ENFORCED];
                        for(ContentVersion cvTemp: cvList){
                            cvTemp.isActive__c=false;
                        }
                        update cvList;
                        contentVerRecord = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id AND  Title='Repayment_ACH.pdf' AND Loan_Application__c=:loanObj.Name AND isActive__c=true WITH SECURITY_ENFORCED];

                    }else{
                        throw new AuraHandledException('Object Access Denied');
                    }*/
                }else{
                    throw new AuraHandledException('Object Access Denied');
                }
            /*}
        else{
                return contentVerRecord.ContentDocumentId+';ACH Not Applicable';
            }*/
            
        } catch (Exception e) {
            system.debug('Exception occured '+e);
        }  
        return contentVerRecord.ContentDocumentId+';Success';        
    }
    
    @AuraEnabled
    public static String getBankName(String ifsc){
        try {
            IFSC_Master__c obj = [SELECT Id,Bank_Name__c FROM IFSC_Master__c WHERE IFSC__c=:ifsc];
            if(obj!=null){
                String bankName = obj.Bank_Name__c;
                Generic_Master__c genericObj = [SELECT Id,Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c =:bankName AND RecordType.Name='Bank Master' LIMIT 1];
                if(genericObj!=null){
                    return genericObj.Bank_Name__c;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static string getMICRCode(String ifsc){
        try {
            IFSC_Master__c obj = [SELECT Id,MICR_Code__c FROM IFSC_Master__c WHERE IFSC__c=:ifsc];
            if(obj!=null){
                return obj.MICR_Code__c;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return '';
    }

    @AuraEnabled
    public static string getRecordInfo(String id){
        try {
            Assignment__c assignObj = [SELECT Id,Loan_Application__c, RecordType.DeveloperName FROM Assignment__c WHERE Id=:id];    
            if(assignObj!=null){
                return assignObj.Loan_Application__c;
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Notification 
    @AuraEnabled
    public static void sendSIotification(String loanId){
        try {
            NotificationHandler.sendNotification('SI intiation',loanId,'');
        } catch (Exception e) {
           System.debug('exception-->' +e);
        }
    }
    //END
}