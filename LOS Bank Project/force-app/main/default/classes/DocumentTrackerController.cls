/*Adding 500 Limit Count as Part of 5674*/
/*Making the class as With Sharing from Without Sharing */
public with sharing class DocumentTrackerController {// change the sharing mode of the class

    @AuraEnabled
    public static List<loanWrapper> searchLoanApplication(String searchKey, String searchBy, String type, String userProfile, String buttonName){
        List<Loan_Application__c> loanApps;
        List<loanWrapper> loanWrapperList = new List<loanWrapper>();
        try {
            searchKey = '%' + searchKey + '%';

            String query = '';
            if(searchBy != null){
                if(userProfile=='RPCCPC' || buttonName == 'View Status'){
                    List<Document_Tracker__c> docList;
                    if(buttonName.contains('Received at RPC')){
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Dispatch to RPC\')';   
                  //      docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Dispatch to RPC')];
                    }
                    else if(buttonName.contains('Received at CPC')){
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Dispatch to CPC from RPC/COM\')';   
                     //   docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Dispatch to CPC from RPC/COM')];
                    }
                    else if(buttonName=='Received at Store' || buttonName=='Disbursed File not received at Store'){
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Send to Store\')';   
                      //  docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Send to Store')];
                    }
                    else if(buttonName.contains('Disbursed')){
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Dispatch to RPC\',\'Dispatch to CPC from RPC/COM\')';   
                     //   docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Dispatch to RPC','Dispatch to CPC from RPC/COM')];
                    }
                    else if(buttonName.contains('Store')){
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Received at RPC\',\'Received at CPC\')';   
                     //   docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Received at RPC','Received at CPC')];
                    }
                    else{
                        query = 'SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\' AND Application_Status__c IN ( \'Received at RPC\')';   
                     //   docList = [SELECT Id,Loan_Application__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name FROM Document_Tracker__c WHERE Loan_Application__r.Loan_Number__c LIKE :searchKey AND RecordType.DeveloperName=:type AND Application_Status__c IN ('Received at RPC')];
                    }
                    
                    
                    if(buttonName == 'View Status'){
                        if(searchBy == 'AWB Number'){
                            query = 'SELECT Id,Loan_Application__c, Application_Status__c, Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE (RO_AWB_Number__c  LIKE  \''+searchKey + '\' OR RPC_AWB_Number__c  LIKE  \''+searchKey +'\' OR CPC_AWB_Number__c  LIKE  \''+searchKey +'\') AND RecordType.DeveloperName= \''+type +'\'';   
                        }else{
                            query = 'SELECT Id,Loan_Application__c, Application_Status__c,Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name  FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\' AND RecordType.DeveloperName= \''+type +'\'';   
                        }
                    }

                    System.debug('query===='+query);

                    if(buttonName == 'View Status'){
                        docList = (List<Document_Tracker__c>) AUSFLoanApplication_WithoutSharing.getRecords(query);
                    }else{
                        docList = Database.query(query);
                    }
                    List<Id> loanIds = new List<Id>();
                    for(Document_Tracker__c doc: docList){
                        loanIds.add(doc.Loan_Application__c);
                    }
                    if(loanIds!=null){
                        loanApps = [SELECT Id,Loan_Number__c,Application_Id__c, Mobile__c, Name, Application_Number__c,LAN__c, Name_of_Customer__c, Customer_Name__c ,toLabel(Product__c) ,Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c, Branch_Master__r.State__r.Account_Name__c, Branch_Master__r.State_Code__c,(SELECT AWB_Number__c,Application_Status__c,Assigned_RO_COM__c,Assigned_RO_COM__r.EmployeeNumber, Assigned_RO_COM__r.Name FROM Document_Tracker__r WHERE RecordType.DeveloperName=:type),Stage__c,Loan_Amount__c,Owner.Name,Branch_Master__r.RPC_FT_RIT_Queue__c,FirstEMI_Status__c,Document_Type__c FROM Loan_Application__c WHERE Id IN :loanIds];
                    }
                }
                else{
                    /*query = 'SELECT Id,Loan_Application__c FROM Document_Tracker__c WHERE ' + GlobalConstants.Get_Field_Name_From_Search_By.get(searchBy) + ' LIKE  \''+searchKey +'\'';
                    List<Document_Tracker__c> docList = Database.query(query);
                    System.debug('doclist '+docList);
                    //  List<Document_Tracker__c> docList = [SELECT Id,Loan_Application__c FROM Document_Tracker__c WHERE Loan_Application__r.Name LIKE :searchKey];
                    List<Id> loanIds = new List<Id>();
                    for(Document_Tracker__c doc: docList){
                        loanIds.add(doc.Loan_Application__c);
                    }
                    System.debug('loanList '+loanIds);
                    String loanIdVals = '(';
                    if(!loanIds.isEmpty()){
                         for(Id recId : loanIds){
                            loanIdVals += '\'' + recId + '\',';
                        }
                        loanIdVals = loanIdVals.subString(0,loanIdVals.length()-1);
                        loanIdVals += ')';
                    }*/
                    String loanQuery = '';
                   if(type=='Physical_File_Tracker'){
                    loanQuery = 'SELECT Id, Loan_Number__c,Application_Id__c, Mobile__c, Application_Number__c,LAN__c , Name, Name_of_Customer__c, Customer_Name__c, toLabel(Product__c),Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c,Branch_Master__r.State__r.Account_Name__c, Branch_Master__r.State_Code__c,Stage__c,Loan_Amount__c,Owner.Name,Disbursement_Date__c,Branch_Master__r.RPC_FT_RIT_Queue__c,FirstEMI_Status__c,Document_Type__c FROM Loan_Application__c WHERE ' +   GlobalConstants.Get_Field_Name_From_Loan_App.get(searchBy) + ' LIKE  \''+searchKey +'\' AND Physical_File_Tracker__c=null AND Disbursement_Date__c!=null AND Is_Loan_Disbursed__c=true Order By LastModifiedDate Desc LIMIT 500'; //AND Id NOT IN ' + loanIdVals;  
                      //  loanApps = [SELECT Id, Loan_Number__c,Application_Id__c, Application_Number__c,LAN__c , Name, Customer_Name__c, toLabel(Product__c),Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c, Branch_Master__r.State_Code__c,Stage__c,Loan_Amount__c,Owner.Name,Disbursement_Date__c FROM Loan_Application__c WHERE Name LIKE :searchKey AND Physical_File_Tracker__c=null AND Disbursement_Date__c!=null AND Is_Loan_Disbursed__c=true AND Id NOT IN :loanIds];
                      loanApps = Database.query(loanQuery);
                    }
                    else
                    {
                        loanQuery = 'SELECT Id, Loan_Number__c,Application_Id__c, Application_Number__c,LAN__c , Name, Name_of_Customer__c, Customer_Name__c, toLabel(Product__c),Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c, Branch_Master__r.State__r.Account_Name__c, Branch_Master__r.State_Code__c,Stage__c,Loan_Amount__c,Owner.Name,Disbursement_Date__c,Mobile__c,Branch_Master__r.RPC_FT_RIT_Queue__c,FirstEMI_Status__c,Document_Type__c FROM Loan_Application__c WHERE ' +   GlobalConstants.Get_Field_Name_From_Loan_App.get(searchBy) + ' LIKE  \''+searchKey +'\' AND Repayment_Instrument_Tracker__c=null AND Disbursement_Date__c!=null AND Is_Loan_Disbursed__c=true'; //AND Id NOT IN ' + loanIdVals;  
                        loanApps = Database.query(loanQuery);
                        // loanApps = [SELECT Id, Loan_Number__c,Application_Id__c, Application_Number__c,LAN__c , Name, Customer_Name__c, toLabel(Product__c),Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c, Branch_Master__r.State_Code__c,Stage__c,Loan_Amount__c,Owner.Name,Disbursement_Date__c FROM Loan_Application__c WHERE Name LIKE :searchKey AND Repayment_Instrument_Tracker__c=null AND Disbursement_Date__c!=null AND Is_Loan_Disbursed__c=true AND Id NOT IN :loanIds];
                    } 
                    System.debug('loanApps '+loanApps);
                } 
            } /*else{
                List<Applicant__c> appList = [SELECT Id,Loan__c, Mobile_Number__c FROM Applicant__c WHERE Mobile_Number__c LIKE :searchKey];
                List<Id> loanIds = new List<Id>();
                for(Applicant__c app: appList){
                    loanIds.add(app.Loan__c);
                }
                if(loanIds!=null){
                    loanApps = [SELECT Id, Loan_Number__c,Application_Id__c, Name, Application_Number__c,LAN__c , Name_of_Customer__c, Customer_Name__c ,Product__c ,Dealer_Master__r.Name,Branch_Master__r.Name, Branch_Master__r.Hub_Code__c, Branch_Master__r.State__r.Account_Name__c,Branch_Master__r.State_Code__c,(SELECT Mobile_Number__c FROM Applicants__r WHERE Mobile_Number__c LIKE :searchKey),Owner.Name,Stage__c,Loan_Amount__c, Mobile__c  FROM Loan_Application__c WHERE Id IN :loanIds];
                }
            }*/
            System.debug('loanApps '+loanApps);
            for(Loan_Application__c obj: loanApps){
                loanWrapper wrap = new loanWrapper();
                wrap.LoanNumber = obj.Loan_Number__c;
                wrap.Name = obj.Name;
                if(searchBy=='AWB Number' && (obj.Document_Tracker__r).size()>0){
                    if(obj.Document_Tracker__r!=null){
                        wrap.AWBNumber = (obj.Document_Tracker__r)[0].AWB_Number__c;
                    }
                }
                if(searchBy == 'Phone Number'){
                    //wrap.MobileNumber = (obj.Applicants__r)[0].Mobile_Number__c;
                    wrap.MobileNumber = obj.Mobile__c;
                }

                wrap.RODetails = obj.Owner.Name;
                wrap.Id = obj.Id;
                wrap.LAN = obj.LAN__c;
                wrap.AccountNumber = obj.LAN__c;
                wrap.CustomerName = obj.Name_of_Customer__c;
                wrap.Product = obj.Product__c;
                wrap.ApplicationId = obj.Application_Id__c;
                wrap.Stage = obj.Stage__c;
                wrap.LoanAmount = String.valueOf(obj.Loan_Amount__c);
                if(obj.Dealer_Master__c!=null){
                   wrap.DealerName = (obj.Dealer_Master__r).Name; 
                }
                if(obj.Branch_Master__c!=null ){
                    wrap.Branch = obj.Branch_Master__r.Name;
                    wrap.BranchHub = obj.Branch_Master__r.Hub_Code__c;
                    wrap.BranchState = obj.Branch_Master__r.State__r.Account_Name__c;
                    wrap.RPCQueueName = obj.Branch_Master__r.RPC_FT_RIT_Queue__c;
                }
                
                if(obj.Document_Tracker__r !=null && !obj.Document_Tracker__r.isEmpty()){
                    wrap.applicationStatus = obj.Document_Tracker__r[0].Application_Status__c;
                }
                wrap.docType = obj.Document_Type__c;
                wrap.firstEMIStatus = obj.FirstEMI_Status__c;

                loanWrapperList.add(wrap);
            }
        } 
        catch (Exception e) {
            System.debug('error '+e.getMessage()+' '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' Line '+e.getStackTraceString() );
        }
        return loanWrapperList;
    }
    
    @AuraEnabled
    public static string saveRecords(List<SObject> loanAppsList,Map<String,String> docTrackerObj,String userProfile){
        try {
            List<Document_Tracker__c> docList = new List<Document_Tracker__c>(); 
            Map<Id,Document_Tracker__c> mapOfLoanIdToDoc = new Map<Id,Document_tracker__c>();
            List<Id> loanIdList = new List<Id>();
            for(SObject obj:loanAppsList){
                loanIdList.add((Id)obj.get('Id'));
            }
            //Map<Id,Loan_Application__c> mapOfIdtoLoan = new Map<Id,Loan_Application__c>([SELECT Id, Name,Physical_File_Tracker__c,Repayment_Instrument_Tracker__c FROM Loan_Application__c WHERE Id in :loanIdList]);
            List<Document_Tracker__c> docTrackerList = [SELECT Loan_Application__c, Assigned_RO_COM__c, Application_Status__c FROM Document_Tracker__c WHERE Loan_Application__c IN : loanIdList AND RecordType.DeveloperName=:docTrackerObj.get('RecordType')];
            for(Document_Tracker__c doc:docTrackerList ){
                mapOfLoanIdToDoc.put(doc.Loan_Application__c,doc);
            }
            System.debug('mapOfLoanIdToDoc '+mapOfLoanIdToDoc);
            Map<String,String> assignmentMap = new Map<String,String>();
            Map<Id,Group> queueMap = new Map<Id,Group>([SELECT Id,DeveloperName,Name FROM Group WHERE Type = 'Queue']);
            Map<String,Group> queueMapByName = new Map<String,Group>();
            for(Id grp: queueMap.keySet()){
                queueMapByName.put(queueMap.get(grp).Name,queueMap.get(grp));
            }
            System.debug('queue list --- '+queueMapByName);
            if(userProfile=='RO' && docTrackerObj.get('Application_Status__c')=='Dispatch to RPC'){
                List<Id> loanIds = new List<Id>();
                for(SObject obj: loanAppsList){
                    loanIds.add((Id)obj.get('Id'));
                }
                List<Loan_Application__c> loanList = [SELECT Id,Branch_Master__r.RPC_FT_RIT_Queue__c FROM Loan_Application__c WHERE Id IN :loanIds];
                System.debug('RPC queue list --- '+loanList);
                for(Loan_Application__c obj: loanList){
                    if(obj.Branch_Master__r!=null && obj.Branch_Master__r.RPC_FT_RIT_Queue__c!=null){
                        assignmentMap.put(obj.Id,queueMapByName.get((obj.Branch_Master__r).RPC_FT_RIT_Queue__c).Id);
                    }
                }
            }
            Map<Id,Loan_Application__c> loanIdtoObjMap;
            //List<FeedItem> chatterList = new List<FeedItem>();
            if(docTrackerObj!=null && docTrackerObj.get('Application_Status__c')=='Disbursed File not received at RPC/CPC'){
                List<Id> loanIds = new List<Id>();
                for(SObject obj: loanAppsList){
                    loanIds.add((Id)obj.get('Id'));
                }
                loanIdtoObjMap = new Map<Id,Loan_Application__c>([SELECT Id,OwnerId FROM Loan_Application__c WHERE Id IN :loanIds]);
            }
            List<Loan_Application__c> loanObjToUpdate = new List<Loan_Application__c>();
            for(SObject obj: loanAppsList){
                Document_Tracker__c docObj = new Document_Tracker__c();
                //Map<String,Object> mapObj =(map<String,Object>)obj;
                docObj.Loan_Application__c = (String)obj.get('Id');
                //docObj.Name = mapOfIdtoLoan.get(docObj.Loan_Application__c).Name;
                System.debug('docObj '+mapOfLoanIdToDoc.get(docObj.Loan_Application__c));
                if(!docTrackerObj.get('Application_Status__c').contains('Received') && !docTrackerObj.get('Application_Status__c').contains('Disbursed')){
                    docObj.Courier_Date__c = Date.valueOf(docTrackerObj.get('Courier_Date__c'));
                    docObj.AWB_Number__c = docTrackerObj.get('AWB_Number__c');
                }
                docObj.Application_Status__c = docTrackerObj.get('Application_Status__c');
                System.debug('record type '+Schema.SObjectType.Document_Tracker__c.getRecordTypeInfosByName().get(docTrackerObj.get('RecordType')));
                docObj.RecordTypeId = Schema.SObjectType.Document_Tracker__c.getRecordTypeInfosByDeveloperName().get(docTrackerObj.get('RecordType')).getRecordTypeId();
                //docObj.Dispatch_To__c = docTrackerObj.get('Dispatch_To__c');
                docObj.Document_Tracker_Identifier__c = (String)obj.get('Id')+'_'+docTrackerObj.get('RecordType');
                if(userProfile=='RO'){
                    docObj.RO_Dispatched_Date__c = System.today();
                    if(docTrackerObj.get('Application_Status__c')=='Dispatch to RPC'){
                        docObj.OwnerId = assignmentMap.get((Id)obj.get('Id'));
                        //docObj.Assigned_RPC__c = queueMap.get(assignmentMap.get((Id)obj.get('Id'))).Name;
                    }
                    else if(docTrackerObj.get('Application_Status__c')=='Dispatch to CPC from RPC/COM' ){
                        docObj.OwnerId = queueMapByName.get('CPC Queue - File Tracking/ RIT').Id;
                    }
                    else if(docTrackerObj.get('Application_Status__c')=='Send to Store'){
                        docObj.OwnerId = queueMapByName.get('Store Queue - File Tracking/ RIT').Id;
                    }
                    docObj.Assigned_RO_COM__c = UserInfo.getUserId();
                    
                    //When RO moves file, awb number for RO used to stamp on document tracker. 
                    docObj.RO_AWB_Number__c = docTrackerObj.get('AWB_Number__c');
                    /** 3131**/
                    docObj.Assigned_RPC__c = docTrackerObj.get('Assigned_RPC__c') != null ? docTrackerObj.get('Assigned_RPC__c') : '';
                    docObj.Courier_Name__c = docTrackerObj.get('Courier_Name__c') != null  ? docTrackerObj.get('Courier_Name__c') : '';
                    docObj.Remarks__c = docTrackerObj.get('Remarks__c') != null ? docTrackerObj.get('Remarks__c') :'';

                }
                else if(userProfile=='RPCCPC'){
                    if(docTrackerObj.get('Application_Status__c')=='Dispatch to CPC from RPC/COM' ){
                        docObj.RPC_Dispatched_Date__c = System.today();
                        docObj.OwnerId = queueMapByName.get('CPC Queue - File Tracking/ RIT').Id;

                         //When RPC moves file, awb number for RPC used to stamp on document tracker. 
                         docObj.RPC_AWB_Number__c = docTrackerObj.get('AWB_Number__c');
                    }
                    else if(docTrackerObj.get('Application_Status__c')=='Received at RPC' ){
                        docObj.RPC_Received_Date__c = System.today();
                    }
                    else if(docTrackerObj.get('Application_Status__c')=='Send to Store'){
                        docObj.OwnerId = queueMapByName.get('Store Queue - File Tracking/ RIT').Id;
                        if(mapOfLoanIdToDoc.get((Id)obj.get('Id')).Application_Status__c=='Dispatch to RPC'){
                            docObj.RPC_Dispatched_Date__c = System.today();
                            //When RPC moves file, awb number for RPC used to stamp on document tracker. 
                            docObj.RPC_AWB_Number__c = docTrackerObj.get('AWB_Number__c');
                        }
                        else if(mapOfLoanIdToDoc.get((Id)obj.get('Id')).Application_Status__c=='Dispatch to CPC from RPC/COM'){
                            docObj.CPC_Dispatched_Date__c = System.today();
                        }else if(mapOfLoanIdToDoc.get((Id)obj.get('Id')).Application_Status__c=='Received at CPC'){
                            //When CPC moves file, awb number for CPC used to stamp on document tracker. 
                            docObj.CPC_AWB_Number__c = docTrackerObj.get('AWB_Number__c');
                            /** 3131**/
                            docObj.Assigned_RPC__c = docTrackerObj.get('Assigned_RPC__c') != null ? docTrackerObj.get('Assigned_RPC__c') : '';
                            docObj.Courier_Name__c = docTrackerObj.get('Courier_Name__c') != null  ? docTrackerObj.get('Courier_Name__c') : '';
                            docObj.Remarks__c = docTrackerObj.get('Remarks__c') != null ? docTrackerObj.get('Remarks__c') :'';
                        }
                    }
                }
                
                
                docList.add(docObj);
            }
            upsert docList Document_Tracker_Identifier__c;
            System.debug('docList '+docList);
            List<Id> docIdList = new List<Id>();
            List<Document_Tracker__Share> docShareList = new List<Document_Tracker__Share>();
            for(Document_Tracker__c doc: docList){
                docIdList.add(doc.Id);
                if(doc.Application_Status__c=='Dispatch to RPC' || doc.Application_Status__c=='Dispatch to CPC from RPC/COM'){
                    Document_Tracker__Share shareObj = new Document_Tracker__Share();
                    shareObj.ParentId = doc.Id;
                    shareObj.UserOrGroupId = UserInfo.getUserId();
                    shareObj.AccessLevel = 'Read';
                    System.debug('shareObj '+shareObj);
                    docShareList.add(shareObj);
                }
            }
            System.debug('docIdList '+docIdList);
            /*if(docShareList.size()>0){
                insert docShareList;
            }*/

            List<Loan_Application__c> loanList = new List<Loan_Application__c>();
            List<Document_Tracker__c> docTrackList = [SELECT Id,Loan_Application__c,RecordType.Name,Application_Status__c,Loan_Application__r.OPS_PDD_Action__c FROM Document_Tracker__c WHERE Id IN:docIdList];
            System.debug('docTrackList '+docTrackList);
            
            for(Document_Tracker__c doc: docTrackList){
                Loan_Application__c loanObj = new Loan_Application__c(Id=doc.Loan_Application__c);
                if(doc.RecordType.Name=='Physical File Tracker'){
                    if(doc.Application_Status__c=='Dispatch to RPC' || doc.Application_Status__c=='Dispatch to CPC from RPC/COM'){
                        loanObj.Physical_File_Tracker__c = doc.Id;
                        loanList.add(loanObj);
                    }
                    
                    if((doc.Application_Status__c=='Received at CPC' || doc.Application_Status__c=='Received at Store') && (doc.Loan_Application__r.OPS_PDD_Action__c!=null && doc.Loan_Application__r.OPS_PDD_Action__c=='Approve')){
                        loanObj.Stage__c = 'Complete';
                        loanList.add(loanObj);
                    }
                }
                else{
                    if(doc.Application_Status__c=='Dispatch to RPC' || doc.Application_Status__c=='Dispatch to CPC from RPC/COM'){
                        loanObj.Repayment_Instrument_Tracker__c = doc.Id;
                        loanList.add(loanObj);
                    }
                    
                    if(doc.Application_Status__c=='Received at CPC'  && (doc.Loan_Application__r.OPS_PDD_Action__c!=null && doc.Loan_Application__r.OPS_PDD_Action__c=='Approve')){
                        loanObj.Stage__c = 'Complete';
                        loanList.add(loanObj);
                    }
                }
            }
            System.debug('loanList '+loanList);
            update loanList;
        } 
        catch (Exception e) {
            System.debug('error '+e.getMessage()+' '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' '+e.getLineNumber());
        }
        return 'Success';
    }
    @AuraEnabled
    public static List<String> checkForLoanDispatch(List<sObject> loanAppsList){
        system.debug('loanAppsList --- '+ loanAppsList);
        List<Id> loanIdList = new List<Id>();
        List<String> loanNames = new List<String>();
            for(SObject obj:loanAppsList){
                loanIdList.add((Id)obj.get('Id'));
            }
        
        for(Loan_Application__c loan: [SELECT ID,Application_Id__c,FirstEMI_Status__c, Document_Type__c, EMI_Options__c FROM Loan_Application__c WHERE ID IN: loanIdList]){
            system.debug('Status == '+ loan.FirstEMI_Status__c +'Doc type-- '+loan.Document_Type__c +'EMI--- '+loan.EMI_Options__c);
            if(String.isBlank(loan.FirstEMI_Status__c) || String.isBlank(loan.Document_Type__c) || String.isBlank(loan.EMI_Options__c))
                loanNames.add(loan.Application_Id__c);
        }
        system.debug('loanNames-- '+ loanNames);
            return loanNames;
    }
    public class loanWrapper{
        @AuraEnabled public String LoanNumber;
        @AuraEnabled public String Name;
        @AuraEnabled public String MobileNumber;
        @AuraEnabled public String AWBNumber;
        @AuraEnabled public String Id;
        @AuraEnabled public String AccountNumber;
        @AuraEnabled public String CustomerName;
        @AuraEnabled public String Product;
        @AuraEnabled public String DealerName;
        @AuraEnabled public String RODetails;
        @AuraEnabled public String Branch;
        @AuraEnabled public String BranchHub;
        @AuraEnabled public String BranchState;
        @AuraEnabled public String ApplicationId;
        @AuraEnabled public String LoanAmount;
        @AuraEnabled public String Stage;
        @AuraEnabled public String LAN;
        @AuraEnabled public String applicationStatus;
        @AuraEnabled public String RPCQueueName;
        @AuraEnabled public String firstEMIStatus;
        @AuraEnabled public String docType;
    }
}