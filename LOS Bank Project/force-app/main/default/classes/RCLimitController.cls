/**
 * @description       : 
 * @author            : Yash
 * @group             : 
 * @last modified on  : 12-12-2023
 * @last modified by  : Ajitesh
**/
public without sharing class RCLimitController {
    public static Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
    public static Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
    public static Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
    private static final Set<String> USED_AMOUNT_DECREMENT_STAGE_NAME = new Set<STring>{'Rejected','PDD'};
    private static final Set<String> USED_AMOUNT_INCREMENT_STAGE_NAME = new Set<STring>{'PSD'};
    
    public static String getValidLoanIdsAndUpdateRCLimit(Map<Id, Loan_Application__c> loanApplicationMap, String stage){
        
        List<Collateral__c> collaterals = [SELECT Id,Deferral_Category__c, HPN_With_Financiers_Name__c, Loan__c FROM Collateral__c WHERE Loan__c IN:loanApplicationMap.keySet() 
                                           AND RecordTypeId IN: colRecordTypeIds WITH SECURITY_ENFORCED];
        Map<Id,Loan_Application__c> validLoanMap = new Map<Id,Loan_Application__c>();
        if(!collaterals.isEmpty()){
            for(Collateral__c collateral : collaterals) {
                if(String.isNotBlank(collateral.Deferral_Category__c) && collateral.Deferral_Category__c == 'RC Limit Deferral'){
                    validLoanMap.put(collateral.Loan__c,loanApplicationMap.get(collateral.Loan__c));
                }
            }
        }
        if(!validLoanMap.isEmpty()){
            return updateDealerRCLimits(validLoanMap, stage);
        }
        else{
            return 'Success';
        }
        

    }
    
    public static void checkAndUpdateRCLimitCheckBox(Map<Id,Account> oldAccMap, Map<Id,Account> newAccMap){
        for(Id accId : newAccMap.keySet()){
            if(oldAccMap.get(accId).RC_Limit_Amount__c < newAccMap.get(accId).RC_Limit_Amount__c){
                newAccMap.get(accId).RC_Limit_Increased__c = true;
            }
        }
        
    }
    
    public static String updateDealerRCLimits(Map<Id,Loan_Application__c> loanMap, String stageName) {
        String respMessage = 'Success';
        system.debug('inside');
        try{
            Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
            Map<Id, Set<Id>> dealer_LoanIdsMap = new Map<Id, Set<Id>>();
            Date todaysDate = System.today();
            if(!loanMap.isEmpty()){
                loanApplicationMap = loanMap;
                if(!loanApplicationMap.isEmpty()){
                    for(Loan_Application__c appl : loanApplicationMap.values()){
                        if(String.isNotBlank(String.valueOf(appl.Sourcing_Channel_Name__c))){
                            if(!dealer_LoanIdsMap.containsKey(appl.Sourcing_Channel_Name__c)){
                                dealer_LoanIdsMap.put(appl.Sourcing_Channel_Name__c, new Set<Id>());
                            }
                            dealer_LoanIdsMap.get(appl.Sourcing_Channel_Name__c).add(appl.Id);
                        }
                    }
                    if(!dealer_LoanIdsMap.isEmpty()){
                        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, RC_Balance_Limit_Count__c , RC_Balance_Limit_Amount__c , RC_Limit_Used_Amount__c, 
                                                                      RC_Limit_Used_Count__c, Ad_Hoc_Balance_Limit_Amount__c, Ad_Hoc_Balance_Limit_Count__c,RC_Limit_Amount__c,Ad_Hoc_Limit_Amount__c,
                                                                      Ad_Hoc_Limit_Used_Amount__c, Ad_Hoc_Limit_Used_Count__c, Ad_Hoc_Date__c FROM Account 
                                                                      WHERE Id IN:dealer_LoanIdsMap.keySet()]);
                        for(Id accId : accMap.keySet()){
                            for(Id loanId : dealer_LoanIdsMap.get(accId)){
                                Account accData = accMap.get(accId);
                                system.debug('accData.RC_Limit_Amount__c '+accData.RC_Limit_Amount__c +' '+accData.RC_Limit_Used_Amount__c);
                                Loan_Application__c applicationRecord = loanApplicationMap.get(loanId);
                                Decimal totalAmount = (String.isBlank(String.valueOf(applicationRecord.Total_Loan_Amount__c)))?0.00:applicationRecord.Total_Loan_Amount__c;
                                Decimal rcBalanceAmount = accData.RC_Limit_Amount__c - accData.RC_Limit_Used_Amount__c;
                                Decimal adHocBalanceAmount = accData.Ad_Hoc_Limit_Amount__c - accData.Ad_Hoc_Limit_Used_Amount__c;
                                Decimal totalBalance = rcBalanceAmount+adHocBalanceAmount;
                                
                                if(USED_AMOUNT_INCREMENT_STAGE_NAME.contains(stageName)){
                                    if(rcBalanceAmount >= applicationRecord.Total_Loan_Amount__c && accData.RC_Balance_Limit_Count__c>0){
                                        system.debug('i amhere '+rcBalanceAmount+' '+applicationRecord.Total_Loan_Amount__c);
                                        accData.RC_Limit_Used_Amount__c+=totalAmount;
                                        accData.RC_Limit_Used_Count__c+=1;
                                        accMap.put(accId, accData);
                                    }
                                    else if(todaysDate<=accData.Ad_Hoc_Date__c){
                                        if(adHocBalanceAmount >= 0){
                                            if(totalBalance>=applicationRecord.Total_Loan_Amount__c){
                                                if(rcBalanceAmount!=0){
                                                    accData.RC_Limit_Used_Amount__c = accData.RC_Limit_Used_Amount__c+(rcBalanceAmount);
                                                    accData.RC_Limit_Used_Count__c+=1;
                                                }
                                                accData.Ad_Hoc_Limit_Used_Amount__c+=(applicationRecord.Total_Loan_Amount__c-rcBalanceAmount);
                                                accData.Ad_Hoc_Limit_Used_Count__c+=1;
                                                accMap.put(accId, accData);
                                            }
                                            else if(totalBalance<applicationRecord.Total_Loan_Amount__c){
                                                //applicationRecord.addError('Please take Approval as RC Amount Limit exceeded');
                                                applicationRecord.RC_Limit_On_Hold__c  = true;
                                                applicationRecord.PSD_Submission_Date__c = System.Now();
                                                respMessage = System.Label.RC_Limit_Error_Message ;
                                            }
                                        }
                                        else if(accData.Ad_Hoc_Balance_Limit_Count__c<=0){
                                            //applicationRecord.addError('Please take Approval as RC Count Limit exceeded');
                                            applicationRecord.RC_Limit_On_Hold__c  = true;
                                            applicationRecord.PSD_Submission_Date__c = System.Now();
                                            respMessage = System.Label.RC_Limit_Error_Message;
                                        }
                                       
                                    }
                                    else if(accData.RC_Balance_Limit_Count__c<=0){
                                        //applicationRecord.addError('Please take Approval as RC Count Limit exceeded');
                                        applicationRecord.RC_Limit_On_Hold__c  = true;
                                        applicationRecord.PSD_Submission_Date__c = System.Now();
                                        respMessage = System.Label.RC_Limit_Error_Message;
                                    }
                                    else if(rcBalanceAmount < applicationRecord.Total_Loan_Amount__c){
                                        //applicationRecord.addError('Please take Approval as RC Amount Limit exceeded');
                                        applicationRecord.RC_Limit_On_Hold__c  = true;
                                        applicationRecord.PSD_Submission_Date__c = System.Now();
                                        respMessage = System.Label.RC_Limit_Error_Message ;

                                    }
                                }
                                /*else if(USED_AMOUNT_DECREMENT_STAGE_NAME.contains(stageName)){
                                    if(accData.RC_Limit_Used_Amount__c>=totalAmount){
                                        accData.RC_Limit_Used_Amount__c-=totalAmount;
                                        accData.RC_Limit_Used_Count__c-=1;
                                        accMap.put(accId, accData);
                                    }
                                    else{
                                        Decimal rcLimitAmount = accData.RC_Limit_Used_Amount__c;
                                        if(rcLimitAmount>=0){
                                            accData.RC_Limit_Used_Amount__c = 0;
                                            accData.RC_Limit_Used_Count__c-=1;
                                        }
                                        accData.Ad_Hoc_Limit_Used_Amount__c-=(totalAmount-rcLimitAmount);
                                        accdata.Ad_Hoc_Limit_Used_Count__c-=1;
                                        accMap.put(accId, accData);
                                    }
                                    
                                }*/
                            }
                        }
                        system.debug('map '+accMap);
                        update accMap.values();
                        update loanApplicationMap.values();
                    }
                }
            }
            
        }catch(Exception ex){
            system.debug('exception ex'+ex.getMessage()+' '+ex.getStackTraceString());
            respMessage = ex.getMessage();
        }
        return respMessage;
    }
    
    public static void releaseRCLimit(Map<Id,Loan_Application__c> loanMap, String stageName){
        Map<Id, Set<Id>> dealer_LoanIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
        Date todaysDate = System.today();
        if(!loanMap.isEmpty()){
                loanApplicationMap = loanMap;
                if(!loanApplicationMap.isEmpty()){
                    for(Loan_Application__c appl : loanApplicationMap.values()){
                        if(String.isNotBlank(String.valueOf(appl.Sourcing_Channel_Name__c))){
                            if(!dealer_LoanIdsMap.containsKey(appl.Sourcing_Channel_Name__c)){
                                dealer_LoanIdsMap.put(appl.Sourcing_Channel_Name__c, new Set<Id>());
                            }
                            dealer_LoanIdsMap.get(appl.Sourcing_Channel_Name__c).add(appl.Id);
                        }
                    }
                    if(!dealer_LoanIdsMap.isEmpty()){
                        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, RC_Balance_Limit_Count__c , RC_Balance_Limit_Amount__c , RC_Limit_Used_Amount__c, 
                                                                      RC_Limit_Used_Count__c, Ad_Hoc_Balance_Limit_Amount__c, Ad_Hoc_Balance_Limit_Count__c,RC_Limit_Amount__c,Ad_Hoc_Limit_Amount__c,
                                                                      Ad_Hoc_Limit_Used_Amount__c, Ad_Hoc_Limit_Used_Count__c, Ad_Hoc_Date__c FROM Account 
                                                                      WHERE Id IN:dealer_LoanIdsMap.keySet()]);
                        for(Id accId : accMap.keySet()){
                            for(Id loanId : dealer_LoanIdsMap.get(accId)){
                                Account accData = accMap.get(accId);
                                accData.RC_Limit_Used_Amount__c = accData.RC_Limit_Used_Amount__c!=null?accData.RC_Limit_Used_Amount__c:0.00;
                                accData.RC_Limit_Used_Count__c = accData.RC_Limit_Used_Count__c!=null?accData.RC_Limit_Used_Count__c:0;
                                accData.Ad_Hoc_Limit_Used_Amount__c = accData.Ad_Hoc_Limit_Used_Amount__c!=null?accData.Ad_Hoc_Limit_Used_Amount__c:0.00;
                                accdata.Ad_Hoc_Limit_Used_Count__c = accdata.Ad_Hoc_Limit_Used_Count__c!=null?accdata.Ad_Hoc_Limit_Used_Count__c:0;
                                Loan_Application__c applicationRecord = loanApplicationMap.get(loanId);
                                Decimal totalAmount = (String.isBlank(String.valueOf(applicationRecord.Total_Loan_Amount__c)))?0.00:applicationRecord.Total_Loan_Amount__c;
                                Decimal rcLimitAmount1 = (String.isBlank(String.valueOf(accData.RC_Limit_Amount__c)))?0.00:accData.RC_Limit_Amount__c;
                                Decimal rcLimitUsedAmount = (String.isBlank(String.valueOf(accData.RC_Limit_Used_Amount__c)))?0.00:accData.RC_Limit_Used_Amount__c;
                                Decimal adHocLimitAmount = (String.isBlank(String.valueOf(accData.Ad_Hoc_Limit_Amount__c)))?0.00:accData.Ad_Hoc_Limit_Amount__c;
                                Decimal adHocLimitUsedAmount = (String.isBlank(String.valueOf(accData.Ad_Hoc_Limit_Used_Amount__c)))?0.00:accData.Ad_Hoc_Limit_Used_Amount__c;
                                Decimal rcBalanceAmount = rcLimitAmount1 - rcLimitUsedAmount;//accData.RC_Limit_Amount__c - accData.RC_Limit_Used_Amount__c;
                                Decimal adHocBalanceAmount = adHocLimitAmount - adHocLimitUsedAmount;//accData.Ad_Hoc_Limit_Amount__c - accData.Ad_Hoc_Limit_Used_Amount__c;
                                Decimal totalBalance = rcBalanceAmount+adHocBalanceAmount;
                                if(USED_AMOUNT_DECREMENT_STAGE_NAME.contains(stageName)){
                                    Loan_Application__c loanApp = loanApplicationMap.get(loanId);
                                    // R2-2658
                                    if((Trigger.isExecuting && !Trigger.isAfter) || !Trigger.isExecuting) 
                                    // R2-2658
                                        loanApp.RC_Limit_On_Hold__c = false; // To disable hold flag so that new application are able to submit again R2-1671
                                    if(accData.RC_Limit_Used_Amount__c>=totalAmount){
                                        accData.RC_Limit_Used_Amount__c-=totalAmount;
                                        accData.RC_Limit_Used_Count__c-=1;
                                        accMap.put(accId, accData);
                                    }
                                    else{
                                        Decimal rcLimitAmount = accData.RC_Limit_Used_Amount__c!=null?accData.RC_Limit_Used_Amount__c:0.00;
                                        if(rcLimitAmount>=0){
                                            accData.RC_Limit_Used_Amount__c = 0;
                                            accData.RC_Limit_Used_Count__c-=1;
                                        }
                                        accData.Ad_Hoc_Limit_Used_Amount__c-=(totalAmount-rcLimitAmount);
                                        accdata.Ad_Hoc_Limit_Used_Count__c-=1;
                                        accMap.put(accId, accData);
                                    }
                                    
                                }
                            }
                        }
                        system.debug('map '+accMap);
                        if(!accMap.isEmpty()){
                            update accMap.values();
                            // R2-2658
                            if((Trigger.isExecuting && !Trigger.isAfter) || !Trigger.isExecuting) 
                            // R2-2658
                                update loanApplicationMap.values(); // To disable hold flag so that new application are able to submit again R2-1671
                        }
                        
                        //update loanApplicationMap.values();
                    }
                }
            }
        
    }
    

}