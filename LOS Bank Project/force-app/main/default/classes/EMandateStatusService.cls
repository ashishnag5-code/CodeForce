public class EMandateStatusService {
    public static void checkCallbackStatus(List<Integration_Checklist__c > newRecordList){
        System.debug('--In status Service '+newRecordList);
        List<Loan_Application__c> loanList = new List<Loan_Application__c>();
        for(Integration_Checklist__c ic: newRecordList){
            if(ic.Integration_Master_Name__c=='E-Mandate Registration Without User' || ic.Integration_Master_Name__c=='E-Mandate Registration'){
                System.debug('Step 2');
                if(ic.Callback_Request__c!=null){
                    Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped(ic.Callback_Request__c);
                    System.debug('map '+requestMap);
                    //ic.Loan_Application__r.E_Mandate_Status__c = (String)requestMap.get('Accptd');
                    Loan_Application__c loanObj = new Loan_Application__c(Id=ic.Loan_Application__c);
                    if((String)requestMap.get('Accptd')=='false'){
                        loanObj.E_Mandate_Status__c = 'Rejected';
                    }
                    else if((String)requestMap.get('Accptd')=='true'){
                        loanObj.E_Mandate_Status__c = 'Accepted';
                    }
                    loanObj.Callback_Date_Time__c = System.Now().formatLong();
                    //loanObj.E_Mandate_Status__c = (String)requestMap.get('Accptd');
                    loanList.add(loanObj);
                    System.debug('Step 3');
                }
           	}
        }
        update loanList;
    }
}