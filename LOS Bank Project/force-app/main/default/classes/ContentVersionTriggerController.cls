/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-16-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentVersionTriggerController {
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-13-2023 
    * @param newList 
    * @param newMap 
    **/
    public static void hanlderFileSize(List<ContentVersion> newList, Map<Id,ContentVersion> newMap){
        for(ContentVersion versionRecord :newList){
            if(versionRecord.ContentSize > Integer.valueOf(System.Label.MAXFILESIZE)){
                //versionRecord.addError('Size is more then 8Mb!!');
            }
        }
    }

        /**
    * @description 
    * @author Kunal Srivastava | Salesforce | 06-19-2023 
    * @param newList 
    **/
    public static void restrictSharingFile(List<ContentVersion> newList){
        for(ContentVersion versionRecord :newList){
            versionRecord.SharingOption = 'R'; //SFAU-2885 by Kunal
        }
    }

    
    /**
    * @description :  
    * @author Harshit Goyal | Salesforce | 01-13-2023 
    * @param newList 
    * @param newMap 
    **/
    public static void afterInsertHandler(List<ContentVersion> newList, Map<Id,ContentVersion> newMap){
        
        for(ContentVersion versionRecord :newList){
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            if(versionRecord.ContentSize > Integer.valueOf(System.Label.MAXFILESIZE)){
                //versionRecord.addError('Size is more then 8Mb!!');
            }
            else if (versionRecord.Is_Compress__c && versionRecord.API_Source__c == 'Lead' && String.isNotBlank(versionRecord.Request_Id__c)) {
                ContentDocumentLink cdlRecord = new ContentDocumentLink();
                cdlRecord.ContentDocumentId = versionRecord.ContentDocumentId;
                cdlRecord.LinkedEntityId = versionRecord.Request_Id__c.subString(0,18);
                lstCDL.add(cdlRecord);
            }
            if (!lstCDL.isEmpty()) {
                insert lstCDL;
            }
        }
    }
}