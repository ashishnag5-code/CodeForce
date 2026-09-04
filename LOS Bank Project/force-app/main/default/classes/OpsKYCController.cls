/*****
 * Class Name: OpsKYCController
 * Description: OPSKyc Process
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
* 30th Oct-2023         -   Mohit M.            -   SFAU-5464 - CUG||51239|| CIF creation error
* 18th Dec-2023         -   Yash S .            -   SFAU-5599 - KYC Response Screen Changes

*/
public without sharing class OpsKYCController {
    @AuraEnabled
    public static sObject getRecordInfo(String id){
        String query = 'SELECT Loan_Application__c,Status__c FROM Assignment__c WHERE Id=:id';
        sObject record = Database.query(query);
        return record;
    }
    
    /*New Method added for Getting FI status based on APplicant*/
    @AuraEnabled
    public static Map<String,FiSummaryViewWrapper> getFIDetailsAssociatedWithApplicant(String loanApplicationId){
        Set<Id> setRecordTypeId = new Set<Id>();
        setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.APPLICANT));
        setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.COAPPLICANT));
        setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.GUARANTOR));
        // Query on FI records
        String strQuery = '';
        strQuery = 'SELECT Id, RecordType.Name, Customer_Name__c, Loan__r.Name, Middle_Name__c, First_Name__c, Last_Name__c, ';
        strQuery = strQuery + '(SELECT ';
        strQuery = strQuery + 'Id,FI_Officer_Name_EMP_code_Agency_Name__c,Waive_Off_Reason__c,FI_Office_Name_Code_Agency_Name_Formula__c ,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c ';
        strQuery = strQuery + 'FROM Field_Investigations__r where Re_Trigger__c = false) ';
        strQuery = strQuery + 'FROM Applicant__c ';
        strQuery = strQuery + 'WHERE RecordTypeId in: setRecordTypeId AND Loan__c = \'' + loanApplicationId + '\' AND Applicant__r.IsInactive__c = false';
        List<Applicant__c> recordsList = Database.query(strQuery);
        Map<String,FiSummaryViewWrapper> mapSummary  = FieldInvestigationUtility.createFISummary(recordsList);
        return mapSummary;
    }
    
	@AuraEnabled
    public static List<Applicant__c> getApplicantList(String loanId){
        List<Applicant__c> applicantList = [SELECT Id,First_Name__c,Middle_Name__c, Last_Name__c, RecordType.Name, KYC_Type__c, Dob__c, AML_Status__c, CFR_Status__c, IsEmailVerified__c, IsInactive__c, Applicant_FI_Status__c, Negative_Check_Status__c,Customer_Type__c,Ops_KYC_Verified__c,Existing_Customer__c  FROM Applicant__c WHERE Loan__c = :loanId AND 
                                            (RecordType.Name='Applicant' OR RecordType.Name='Co-Applicant' OR RecordType.Name='Guarantor' OR RecordType.Name='BO') AND IsInactive__c = false];
        return applicantList;
    }
	
    @AuraEnabled
    public static List<Document_Checklist__c> getDocumentChecklistRecords(String applId){
        List<Document_Checklist__c> docList= [SELECT Id,Document_Number__c,Document__c,Document_Expiry_Date__c,Document_Master__c,Document_Name__c,Document_Verification_Status__c,Match_Percentage__c,Ops_Action__c,Ops_Remark__c,Document_Master__r.Document_Name__c,Document_Master__r.Name, Address_Match_Score__c, Api_Response__c 
          FROM Document_Checklist__c WHERE Applicant__c=:applId];
        return docList;
    }
    
    @AuraEnabled
    public static Map<String,String> getLinkedFiles(String applId){
        Map<Id,Document_Checklist__c> docMap = new Map<Id,Document_Checklist__c>([SELECT Id,Document_Master__c,Document_Name__c,Document_Master__r.Document_Name__c  FROM Document_Checklist__c WHERE Applicant__c=:applId]);
        List<ContentDocumentLink> contentList = [select Id, ContentDocumentId,ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.VersionDataUrl,LinkedEntityId from ContentDocumentLink  WHERE LinkedEntityId IN : docMap.keySet() AND  ContentDocument.LatestPublishedVersion.isActive__c = true];
        Map<String,String> linkedFilesMap = new Map<String,String>();
        for(ContentDocumentLink cdl: contentList){
            if(cdl.ContentDocumentId!=null && ContentDocument.LatestPublishedVersionId!=null){
               linkedFilesMap.put(docMap.get(cdl.LinkedEntityId).Document_Master__r.Document_Name__c, cdl.ContentDocument.LatestPublishedVersionId); 
            }
        }
        return linkedFilesMap;
    }

    @AuraEnabled
    public static List<Address__c> getAddresses(String applId){
        // SFAU-5464 - Add Query Filter - Address_Type__c and Pincode__c
        List<Address__c> docList= [SELECT Id,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Type__c,Source_Type__c, OPS_Action__c, OPS_Remark__c, Address_Source__c,District__c, State__c, City__c, Pincode__c  FROM Address__c WHERE Applicant__c=:applId AND Source_Type__c!='Cibil' and Source_Type__c!='Cart' AND Address_Type__c != '' AND Pincode__c != ''];
        return docList;
    }
    
    @AuraEnabled
    public static String updateRecords(Object data){
        List < Document_Checklist__c > docsForUpdate = ( List < Document_Checklist__c > ) JSON.deserialize(
            JSON.serialize( data ),
            List < Document_Checklist__c >.class
        );
        try {
            update docsForUpdate;
            return 'Success: Record(s) updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String updateAddressRecords(Object data){
        List < Address__c > addsForUpdate = ( List < Address__c > ) JSON.deserialize(
            JSON.serialize( data ),
            List < Address__c >.class
        );
        try {
            update addsForUpdate;
            return 'Success: Record(s) updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String updateLoanRecord(String opsAction, String opsRemark, String loanId, String assignmentId){
        //Loan_Application__c loanObj = new Loan_Application__c(Id=loanId,OPS_Action__c=opsAction,OPS_Remark__c=opsRemark);
        Loan_Application__c loanObj = [SELECT Id, OwnerId, OPS_KYC_Action__c, OPS_KYC_Remark__c,Stage__c FROM Loan_Application__c WHERE Id=:loanId];
        Assignment__c assignment = [SELECT RecordType.Name FROM Assignment__c WHERE Id=:assignmentId];
        loanObj.OPS_KYC_Action__c = opsAction;
        loanObj.OPS_KYC_Remark__c = opsRemark;
        Assignment__c opsAssignment = new Assignment__c(Id=assignmentId);
        try{
            if(opsAction=='Rework'){
                //loanObj.Stage__c = 'PSD';
                //opsAssignment.ownerId = loanObj.OwnerId;
                if(assignment.RecordType.Name=='Ops - KYC'){
                    opsAssignment.ownerId = loanObj.OwnerId;
                    update opsAssignment;
                }
                else if(assignment.RecordType.Name=='Ops - Disbursement'){
                    Assignment__c assignObj = new Assignment__c();
                    assignObj.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
                    assignObj.Loan_Application__c = loanId;
                    assignObj.ownerId = loanObj.OwnerId;
                    insert assignObj;
                }
            }
            else if(opsAction=='Approve' && assignment.RecordType.Name=='Ops - KYC'){
                opsAssignment.Status__c = 'Complete';
                update opsAssignment;
            }
            update loanObj;
            //update opsAssignment;
            return 'Success: Record updated successfully';
        }
        catch(Exception e){
        	return 'The following exception has occurred: ' + e.getMessage();  
        }
    }

    @AuraEnabled
    public static String reSubmitRecord(String loanId, String assignmentId, String remarks){
        //Loan_Application__c loanObj = new Loan_Application__c(Id=loanId,OPS_Action__c=opsAction,OPS_Remark__c=opsRemark);
        Loan_Application__c loanObj = [SELECT Id, OwnerId FROM Loan_Application__c WHERE Id=:loanId];
        loanObj.RO_KYC_Remarks__c = remarks;
        Assignment__c assignObj = [SELECT RecordType.Name FROM Assignment__c WHERE Id=:assignmentId];
        Assignment__c assignDisbursementObj = [SELECT Id,Status__c,RecordType.Name,Loan_Application__c FROM Assignment__c 
                                                WHERE RecordType.Name='Ops - Disbursement' AND Status__c='Pending' AND Loan_Application__c=:loanId];
        try{
            update loanObj;

            if(assignDisbursementObj!=null){
                delete assignObj;
            }
            else{
                OpsAssignementUtility.doOpsAssignment(loanObj,'Ops - KYC','');
            }
            return 'Success: Record submitted successfully';
        }
        catch(Exception e){
            return 'Error '+e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String updateApplicant(String applId, String loanId, Boolean verified){
        Applicant__c appObj = new Applicant__c(Id=applId);
        appObj.Ops_KYC_Verified__c = verified;
        try{
            update appObj;
            Loan_Application__c loanObj = [SELECT Id,(SELECT Id,Ops_KYC_Verified__c FROM Applicants__r WHERE Ops_KYC_Verified__c!=true AND (RecordType.Name='Applicant' OR RecordType.Name='Co-Applicant' OR RecordType.Name='Guarantor' OR RecordType.Name='BO')) 
                                        FROM Loan_Application__c WHERE Id=:loanId];
            if(loanObj.Applicants__r.size()>0){
                return 'Success';
            }
            return 'Success,Verified';

        }
        catch(Exception e){
            return 'Error '+e.getMessage();
        }
    }

    @AuraEnabled
    public static String checkOwnerUser(String recordId){
        try {
            Assignment__c assignObj = [SELECT Id, OwnerId FROM Assignment__c WHERE Id = :recordId];
            if(String.valueOf(assignObj.OwnerId).startsWith('005')){
                if(UserInfo.getUserId()==String.valueOf(assignObj.OwnerId)){
                    return 'Owner';
                }
                return 'User';
            }
            else{
                return 'Group';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<string,string> getAddressSourceMetadata(){
        try {
            List<Address_Source_to_Document_Name_mapping__mdt> mcs = Address_Source_to_Document_Name_mapping__mdt.getAll().values();
            Map<String,String> addressSrcToDocNameMap = new Map<String,String>();
            for(Address_Source_to_Document_Name_mapping__mdt m: mcs){
                addressSrcToDocNameMap.put(m.Address_Source__c,m.Document_Name__c);
            }
            return addressSrcToDocNameMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*5599 Apex Changes*/
    @AuraEnabled
    public static List<OpsKycDocumentsMetadata__mdt> getOpsResponseMetadataRecords(String documentName){
        List<OpsKycDocumentsMetadata__mdt> metadataRecords = new List<OpsKycDocumentsMetadata__mdt>();
        try {
            if(String.isBlank(documentName)){
                throw new CustomException('Please provide a valid document Name');
            }
            metadataRecords = [SELECT Id, DeveloperName__c, Display_On_UI__c, DocumentName__c, JSON_Key__c, MasterLabel__c, Order__c
                               FROM OpsKycDocumentsMetadata__mdt Where DocumentName__c = :documentName AND Display_On_UI__c = true ORDER BY Order__c
                              ];
            if(metadataRecords.isEMpty()){
                throw new CustomException('Please ask System Admin to create Records for Response');
            }
            return metadataRecords;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class CustomException extends Exception {}


    /**********************/
}