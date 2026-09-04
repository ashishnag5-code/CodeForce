public without sharing class PDDDocumentChecklistCreate {
    
    public static void updateDocChkPDD(Map < Id, sObject > oldRecordMap, List < sObject > newRecordList, Map < Id, sObject > newRecordMap){
        Set<Id> loanIDSet = New Set<Id>();
        //get all loan application which are changed to PDD
        for(Loan_Application__c loan: (List<Loan_Application__c>)newRecordList){
            Loan_Application__c oldrec = (Loan_Application__c)oldRecordMap.get(loan.Id);
            if(oldrec.Stage__c!=loan.Stage__c && loan.Stage__c =='PDD'){
                loanIDSet.add(loan.Id);
            }
        }
        if(loanIDSet.size()>0){
            //get all applicants related to Loan application
            Map<Id,list<Id>> loandocmap = new Map<Id,list<Id>>();
            Map<Id,list<Id>> appdocmap = new Map<Id,list<Id>>();
            //get all documents which are related to loan application and applicant where master stage is PDD
            for(Document_Checklist__c doc: [select id, Collateral__r.Loan__c, Loan_Application__c, Applicant__c from Document_Checklist__c where 
                Collateral__r.Loan__c in :loanIDSet AND Document_Master__r.Stage__c = 'PDD']){
                if(loandocmap.containsKey(doc.Collateral__r.Loan__c)) {
                    List<Id> docId = loandocmap.get(doc.Collateral__r.Loan__c);
                    docId.add(doc.Id);
                    loandocmap.put(doc.Collateral__r.Loan__c, docId);
                } else {
                    loandocmap.put(doc.Collateral__r.Loan__c, new List<Id> { doc.Id });
                }
            }
            List<Document_Checklist__c> docChkUpdList = New List<Document_Checklist__c>();
            //get all loan records
            for(id loanId: loanIDSet){
                Integer seqNum = 1;
                set<Id> docSet = New Set<Id>();
                //get loan record related documents
                if(loandocmap.containsKey(loanId)){
                    for(id doci : loandocmap.get(loanId)){
                        Document_Checklist__c doc = new Document_Checklist__c();
                        doc.id = doci;
                        doc.Sequence__c = seqNum;
                        seqNum++;
                        docChkUpdList.add(doc);
                        docSet.add(doci);
                    }
                }
            }
            update docChkUpdList;
        }
    }
    
}