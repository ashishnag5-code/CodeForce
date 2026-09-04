/*******************************************************************************************
* @Name         cibilScoreViwerUsingLinkController
* @Author       Salesforce
* @Description  class to read and display cibil data in the UI
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Salesfoce        12/07/2023         Initial Creation
*******************************************************************************************/
public without sharing class cibilScoreViwerUsingLinkController {
    //Method to get cibil data from the file
    @AuraEnabled(cacheable=true)
    public static String contentData(String value) {
        if(value<> null){
            ContentVersion cv = [select id,VersionData from ContentVersion where ContentDocumentId =: value];
            return cv.VersionData.toString();
        }
        return null;
    }

    //Method to create chatter post of Cibil Link
    @AuraEnabled
    public static string postFeed(String contentId, String userId){
        try{
            string bureau = '';
            for(ContentDocumentLink cdl: [select id,LinkedEntityId, LinkedEntity.type 
                from ContentDocumentLink where ContentDocumentId =:contentId]){
                if(cdl.LinkedEntity.type == 'Bureau_Results__c'){
                    bureau = cdl.LinkedEntityId;
                }
            }
            Bureau_Results__c bResult = [select Applicant__r.Applicant_Name__c from 
                Bureau_Results__c where id =: bureau limit 1];
            String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String body = 'Please view '+bResult.Applicant__r.Applicant_Name__c+' CIBIL here  ' +sfdcBaseURL+'/lightning/n/View_Cibil_Report?c__conDocumentId='+contentId;
            FeedItem post = new FeedItem();
            post.ParentId = userId;
            post.Body = body;
            insert post;
            return 'success';
        }catch(Exception ex){ return 'error';
        }
    }
}