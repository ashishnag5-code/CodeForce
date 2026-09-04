/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-07-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public without sharing class DocumentChecklistService {
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-13-2022 
    * SFAU-5652: updated by Samridhi | Fetch Document Category and Sub Category
    * @return String 
    **/
    public static String createQuery() {
        return 'SELECT Id,Document_Name__c,Applicant__r.Existing_Customer__c,Applicant__r.Bureau_Score__c,Applicant__c,Document_Tracker_Id__c, Loan_Application__c,Collateral__c,Document_Master__r.Gallery_Restrict__c,Document_Master__r.No_of_Pages__c,Document_Master__r.Not_Supported_In_Desktop__c,Document_Master__r.OCR_Needed__c,Document_Master__r.OCR_Document_Type__c, Document_Master__r.Name,Document_Master__r.Document_Name__c,Document_Master__r.Password_Needed__c,Document_Master__r.Automerge__c,Document_Master__r.Auto_Zip__c,Document_Master__r.Amount_Required__c,Document_Master__r.Cart_Callout_Required__c,Document_Verification_Status__c,Ops_Action__c,Ops_Remark__c,Status__c,Mode__c,Document_Master__r.Ownership__c,Document_Master__r.System_Generated__c,Document_Master__r.File_Size__c,Document_Master__r.Consider_for_E_Sign__c,Document_Master__r.Enable_Upload__c,Document_Master__r.Download_by_Credit__c,Document_Master__r.Download_by_Ops__c,Document_Master__r.Download_by_RO_COM_TCU__c,Document_Master__r.Pdf_Direct_Upload__c,Loan_Application__r.Stage__c,Document_Master__r.Multiple_Upload__c,Loan_Application__r.E_Mandate_Status__c,Document_Master__r.Document_Category__c,Document_Master__r.Document_Sub_Category__c from Document_Checklist__c ';
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-13-2022 
    * @param whereClause 
    * @return List<Document_Checklist__c> 
    **/
    public static List<Document_Checklist__c> getDoucmentChecklist(String whereClause){
        String queryString ='';
        if(String.isNotBlank(whereClause)){
            queryString = createQuery() + whereClause+' limit 50000';
        }else{
            queryString = createQuery() +' limit 50000';
        }
        system.debug('queryString'+queryString);
        List<Document_Checklist__c> checkLists = Database.query(queryString);
        System.debug('checkLists: '+checkLists);
        return checkLists;
        
        

    }
}