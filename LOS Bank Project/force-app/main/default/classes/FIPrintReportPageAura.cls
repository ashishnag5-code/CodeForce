public class FIPrintReportPageAura
{
    @AuraEnabled public string formFactor {get;set;}
    @AuraEnabled public Id docId {get;set;}
    @AuraEnabled public string profileName {get;set;}

    @AuraEnabled
    public static FIPrintReportPageAura generatePDF(String fiRecID)
    {
        FIPrintReportPageAura obj = new FIPrintReportPageAura();
        obj.formFactor = UserInfo.getUiThemeDisplayed();

        Id currentUserProfileId = UserInfo.getProfileId();
        obj.profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;

        //String contDocId = '';
        //String fiRecId = Apexpages.currentPage().getParameters().get('passRecId');
        system.debug('fiRecId**' +fiRecId);

        map<Id,Id> cdlDocMap = new map<Id,Id>();
        for(ContentDocumentLink eachCDL : [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId =: fiRecId]){
            if(eachCDL != null){
                cdlDocMap.put(fiRecId, eachCDL.ContentDocumentId);
            }
        }

        PageReference myPage = Page.FIPrintReportPage_V3;
        myPage.getParameters().put('id', fiRecId);
        myPage.setRedirect(true);

        Blob body=null;
		if(Test.isRunningTest()){
            Body = blob.valueOf('Unit.Test');
        }else{
               body = myPage.getContent();}

        //map<Id,Id> thecdlDocMap = checkExistingFile(fiRecId);
        if(cdlDocMap.isEmpty()){
            // Create First File
            ContentVersion conVer = new ContentVersion();

            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce
            conVer.PathOnClient = 'FieldInvestigationReportPage.pdf'; 
            conVer.Title = 'FieldInvestigationReportPage';
            conVer.VersionData = body;
            insert conVer;    //Insert ContentVersion

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = fiRecId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'I';
            //cdl.Visibility = 'InternalUsers';
            insert cdl;

            cdlDocMap.put(fiRecId,conDocId);
            system.debug(':: CDL Automatically Created??'+cdlDocMap);
            system.debug(':: End Save PDF');

            obj.docId = cdlDocMap.get(fiRecId);
        }
        else{
            obj.docId = cdlDocMap.get(fiRecId);    
        }
        return obj;
    }
}