global class RCIncreasedLimitBatch implements Database.batchable<sObject>, Database.Stateful{
    public Set<String> dealerIds = new Set<String>();
    
    public RCIncreasedLimitBatch(Set<String> dealerIds){
        this.dealerIds = dealerIds;
    }
    
    public RCIncreasedLimitBatch(){
        this.dealerIds = new Set<String>();
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'Select Id, RC_Limit_Amount__c,RC_Limit_Used_Amount__c ,RC_Limit_Count__c ,RC_Limit_Used_Count__c,RC_Limit_Increased__c, Ad_Hoc_Limit_Amount__c,Ad_Hoc_Limit_Used_Amount__c, Ad_Hoc_Limit_Count__c, Ad_Hoc_Limit_Used_Count__c,Ad_Hoc_Date__c From Account Where RC_Limit_Increased__c = true';
        if(!dealerIds.isEmpty()){
            queryString+=' AND Id IN :dealerIds';
        }
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> accRecords) {
        try{
            Map<Id,Account> dealerIdMap = new Map<Id, Account>();
            for(Account acc : (List<Account>)accRecords){
                dealerIdMap.put(acc.Id, acc);
            }
            Date todaysDate = System.today();
            List<Loan_Application__c> applications = [SELECT Id, Total_Loan_Amount__c, RC_Limit_On_Hold__c,PSD_Submission_Date__c,Dealer_Master__c FROM Loan_Application__c
                                                      WHERE  Dealer_Master__c IN :dealerIdMap.keySet() AND RC_Limit_On_Hold__c = true ORDER BY PSD_Submission_Date__c ASC
                                                     ];
            for(Loan_Application__c appl : applications){
                Decimal totalAmount = appl.Total_Loan_Amount__c;
                system.debug('total amount '+totalAmount);
                Account accData = dealerIdMap.get(appl.Dealer_Master__c);
                Decimal rcBalanceAmount = accData.RC_Limit_Amount__c - accData.RC_Limit_Used_Amount__c;
                Decimal adHocBalanceAmount = accData.Ad_Hoc_Limit_Amount__c - accData.Ad_Hoc_Limit_Used_Amount__c;
                Decimal rcBalanceCount = accData.RC_Limit_Count__c - accData.RC_Limit_Used_Count__c;
                Decimal adHocBalanceCount = accData.Ad_Hoc_Limit_Count__c - accData.Ad_Hoc_Limit_Used_Count__c;
                Decimal totalBalance = rcBalanceAmount+adHocBalanceAmount;
                system.debug('rc balance amount '+rcBalanceAmount+' '+adHocBalanceAmount+' '+totalBalance);
                if(rcBalanceAmount>=totalAmount){
                    system.debug('first check');
                    accData.RC_Limit_Used_Amount__c+=totalAmount;
                    accData.RC_Limit_Used_Count__c+=1;
                    dealerIdMap.put(appl.Dealer_Master__c,accData);
                    appl.RC_Limit_On_Hold__c = false;
                }
                else if(todaysDate<accData.Ad_Hoc_Date__c){
                    system.debug('second check');
                    if(totalBalance>=totalAmount){
                        if(rcBalanceAmount!=0){
                            accData.RC_Limit_Used_Amount__c+=rcBalanceAmount;
                            accData.RC_Limit_Used_Count__c+=1;
                        }
                        accData.Ad_Hoc_Limit_Used_Amount__c+=(totalAmount-rcBalanceAmount);
                        accData.Ad_Hoc_Limit_Used_Count__c+=1;
                        dealerIdMap.put(appl.Dealer_Master__c, accData);
                        appl.RC_Limit_On_Hold__c = false;
                    }
                }
            }
            update dealerIdMap.values();
            system.debug('map values '+dealerIdMap.values());
            update applications;
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
    }
    
    
    global void finish(Database.BatchableContext BC) {
        system.debug('batch completed');
    }

    
    
}