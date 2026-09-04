public class AUSFLEICreditController {

    @AuraEnabled
    public static Wrapper getLEIWrapper(String loanAppId){
        Wrapper wrap = new Wrapper();
        Integer cibilScore;
        Integer actResult;
        //Applicant	
        //UFCE Changes - sadhana
        wrap.loanApp = [Select Id,Security_Status__c,Final_Exposure__c ,Unhedged_Foreign_Currency_Exposure__c ,LEI_Status__c,LEI_No__c,Type_Of_Banking__c,Realestate_Exposure__c,
                        Capital_Market_Exposure__c,Foreign_Curreny_Exposure__c,Three_years_average_turnover__c FROM Loan_Application__c Where Id=:loanAppId];
        
        Id appRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id usedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
		//UFCE Changes - sadhana
        Applicant__c app = [SELECT Id,Bureau_Score__c, Customer_Type__c  FROM Applicant__c WHERE loan__c=:loanAppId AND recordTypeId=:appRecordTypeId WITH SECURITY_ENFORCED LIMIT 1];
        if(app!=null && app.Bureau_Score__c!=null){
            cibilScore = Integer.valueOf(app.Bureau_Score__c);
        }
        
        //UFCE Changes start- sadhana
        if(app!=null && app.Customer_Type__c == 'Non Individual'){
            wrap.isUFCE = true;
        }
        else{
            wrap.isUFCE = false;
        }
        //UFCE Changes end- sadhana
        //updated Bureau_Results__c to List<Bureau_Results__c> to avoid list exception in case empty rows
       List<Bureau_Results__c> bureauRes = [SELECT Id,Account_High_Credit_Amount__c  FROM Bureau_Results__c WHERE Applicant__c =:app.Id WITH SECURITY_ENFORCED LIMIT 1];
        if(bureauRes!=null && bureauRes.size()>0 && bureauRes[0].Account_High_Credit_Amount__c!=null){
            wrap.cibilExposure = Integer.valueOf(bureauRes[0].Account_High_Credit_Amount__c);
        }
        
        List<Applicant_Financials_Details__c> applicantFinaanceDetailList = [SELECT id,Annual_Turnover__c,Type_Of_Employment__c,Method_Of_Assesment__c,RecordType.Name FROM Applicant_Financials_Details__c WHERE Applicant__c=:app.Id];
		List<Collateral__c> collateralList = [SELECT Id,Total_Collateral_Value__c,POS__c,Loan__r.Loan_Amount__c,Apportioned_Loan_Amount__c FROM Collateral__c WHERE loan__c=:loanAppId AND recordTypeId=:usedRecordTypeId];        
        system.debug('coll list is '+collateralList.size());
        if(collateralList.size()>0){
           actResult = Integer.valueof(collateralList[0].Total_Collateral_Value__c) -(Integer.valueof(collateralList[0].POS__c)+Integer.valueof(collateralList[0].Apportioned_Loan_Amount__c));
        }
        wrap.cibilScore = cibilScore;
        wrap.applicantFinaanceDetailList = applicantFinaanceDetailList;
        wrap.posResult = actResult;
        system.debug('@@wrap'+wrap);
        return wrap; 
    }
    
    //UFCE Changes - sadhana
    @AuraEnabled
    Public Static Void generateDocChecklists(String loanAppId){
        system.debug('@@enter'+loanAppId);
        String insertDoc = '';
        List<Document_Checklist__c> upsertList = new List<Document_Checklist__c>();
        List<Document_Checklist__c> inactiveList = new List<Document_Checklist__c>();
        List<Document_Checklist__c> activeList = new List<Document_Checklist__c>();
        Map<String,Document_Master__c> docMstrMap = new Map<String,Document_Master__c>();
        Map<String,Document_Checklist__c> checklistMap = new Map<String,Document_Checklist__c>();
        List<String> documentNames = new List<String>{'UFCE Certificate','UFCE Declaration'};
            for(Document_Master__c docMaster : [SELECT Id, Document_Name__c, Document_Category__c, Document_Sub_Category__c FROM Document_Master__c WHERE Document_Name__c in: documentNames]){
                docMstrMap.put(docMaster.Document_Name__c,docMaster);
            }
         system.debug('@@docMstrMap'+docMstrMap);
        List<Loan_Application__c> loanApp = [SELECT Id,Final_Exposure__c ,Primary_Applicant__r.Complete_Name__c , Unhedged_Foreign_Currency_Exposure__c, (SELECT Id,Active__c,Document_Master__r.Document_Name__c FROM Document_Checklists__r WHERE Document_Master__r.Document_Name__c in:documentNames) FROM Loan_Application__c WHERE Id=:loanAppId]; 
        if(loanApp[0].Document_Checklists__r!=null && loanApp[0].Document_Checklists__r.size()>0){
            for(Document_Checklist__c dc : loanApp[0].Document_Checklists__r){
                checklistMap.put(dc.Document_Master__r.Document_Name__c,dc);
            }                        
        }
        system.debug('@@checklistMap'+checklistMap);
        if(loanApp[0].Unhedged_Foreign_Currency_Exposure__c == 'Yes'){
            NotificationHandler.sendNotification('UFCE Certificate',loanAppId,loanApp[0].Primary_Applicant__r.Complete_Name__c );
            if(checklistMap != null){
                if(checklistMap.containsKey('UFCE Declaration')){
                    system.debug('@@declare inactive');
                    inactiveList.add(checklistMap.get('UFCE Declaration'));
                }
                if(!checklistMap.containsKey('UFCE Certificate')){
                    system.debug('@@creat cert');
                    insertDoc = 'UFCE Certificate';
                } 
                else{
                    activeList.add(checklistMap.get('UFCE Certificate'));
                }
            }
            else{
                system.debug('@@create cert');
                insertDoc = 'UFCE Certificate';
            }
        }
        else if(loanApp[0].Unhedged_Foreign_Currency_Exposure__c == 'No' && loanApp[0].Final_Exposure__c>= Decimal.valueOf(System.Label.Final_Exposure)){
            NotificationHandler.sendNotification('UFCE Declaration',loanAppId,loanApp[0].Primary_Applicant__r.Complete_Name__c );
            if(checklistMap != null){
                if(checklistMap.containsKey('UFCE Certificate')){
                    system.debug('@@cert inactive');
                    inactiveList.add(checklistMap.get('UFCE Certificate'));
                }
                if(!checklistMap.containsKey('UFCE Declaration')){
                    system.debug('@@create dec');
                    insertDoc = 'UFCE Declaration';
                }  
                else{
                    activeList.add(checklistMap.get('UFCE Declaration'));
                }
            }
            else{
                system.debug('@@create dec');
                insertDoc = 'UFCE Declaration';
            }
            
        }
        if(!inactiveList.isEmpty()){
            for(Document_Checklist__c doc : inactiveList){
                doc.Active__c = false;
                upsertList.add(doc);
            }
        }
        if(!activeList.isEmpty()){
            for(Document_Checklist__c doc : activeList){
                doc.Active__c = true;
                upsertList.add(doc);
            }
        }
        if(String.isNotBlank(insertDoc)){
            Document_Checklist__c docCheck = new Document_Checklist__c();
            docCheck.Loan_Application__c = loanAppId;
            docCheck.Document_Master__c = docMstrMap.get(insertDoc).Id;
            docCheck.Document_Name__c = docMstrMap.get(insertDoc).Document_Name__c;
            docCheck.Category__c = docMstrMap.get(insertDoc).Document_Category__c;
            docCheck.Sub_Category__c = docMstrMap.get(insertDoc).Document_Sub_Category__c;
            docCheck.Active__c = true;
            upsertList.add(docCheck);
            
        }
        system.debug('@@upsertList'+upsertList);
        if(!upsertList.isEmpty()){
            upsert upsertList;
        }
    }
    
     
    public class Wrapper{
        @AuraEnabled 
        public Integer cibilScore;
        @AuraEnabled 
        public Integer cibilExposure;
        @AuraEnabled
        public List<Applicant_Financials_Details__c> applicantFinaanceDetailList;
        @AuraEnabled
        public Integer posResult;
        @AuraEnabled 
        public Loan_Application__c loanApp;
        //UFCE Changes - sadhana
        @AuraEnabled 
        public Boolean isUFCE;
    }
}