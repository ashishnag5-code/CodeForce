public class DocumentTrackerService {
	public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        shareRecordWithUser(newRecordList);
    }
    public void shareRecordWithUser(List<sObject> newRecordList){
        
        List<Document_Tracker__Share> docShareList = new List<Document_Tracker__Share>();
        for(sObject doc: newRecordList){
            Document_Tracker__c docObj = (Document_Tracker__c)doc;
            if(docObj.Application_Status__c=='Dispatch to RPC' || docObj.Application_Status__c=='Dispatch to CPC from RPC/COM'){
            	Document_Tracker__Share shareObj = new Document_Tracker__Share();
                shareObj.ParentId = docObj.Id;
                shareObj.UserOrGroupId = UserInfo.getUserId();
                shareObj.AccessLevel = 'Read';
                System.debug('shareObj '+shareObj);
                docShareList.add(shareObj);
            }
        }
        insert docShareList;
    }
}