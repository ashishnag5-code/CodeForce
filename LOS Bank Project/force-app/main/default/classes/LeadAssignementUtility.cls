/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : Harshit Goyal | Salesforce
 * @last modified by  : Mohit M.  
**/
public with sharing class LeadAssignementUtility {
    public static String dealerCode_CustomerPin = 'DealerCode_CustomerPin';
    public static String customerPin = 'CustomerPin';
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-06-2023 
    * @param leadList 
    * @param isCreate 
    * @return List<Loan_Application__c> 
    **/
    public static List<Loan_Application__c> populateLeadAssignment(List<Loan_Application__c> leadList, Boolean isCreate){
        if(isCreate){
            return null;
        }else{
            return leadList;
        }
    }
    public static LeadWrapper returnLeadAssignment(LeadWrapper leadWrapper){
        try{
            Set<String> pinCodeSet = new Set<String>();
            Set<String> dealerCode = new Set<String>();
            Set<Id> accountIdSetForQueueQuery = new Set<Id>();
            Map<String,String> mapLeadIdWithOwnerId = new Map<String,String>();
            Map<String,Map<String,Account>> dealerVsBranches = new Map<String,Map<String,Account>>();
            Map<String,Map<String,String>> dealerVsDealerPinOwnerMap = new Map<String,Map<String,String>>();
            Map<String,String> pinCodeVsBranchQueue = new Map<String,String>();
            Map<String,Lead_Assignment__mdt> channelSourceVsRecord = new Map<String,Lead_Assignment__mdt>();
            Set<String> queueNameSet = new Set<String>();
            Map<String,String> queueNameVsId = new Map<String,String>();
            Map<String,List<Account>> zipVsBranchRecord = new Map<String,List<Account>>();
            Map<String,Account> zipBranchVsBranchRecord = new Map<String,Account>();
            Map<String,String> branchCodeVsZip = new Map<String,String>();
            Map<Id, String> accountToQueueMap = new Map<Id, String>();
            Map<String, Integer> queueOwnerCountMap = new Map<String, Integer>();
            Map<String,Account> mapLeadWithBranch = new Map<String,Account>();
            for(Lead_Assignment__mdt leadAssignData : [SELECT Source_Channel__c,Source_Name__c,Id, Assignment_Required__c, isQueue__c, Priority1__c, Priority2__c, Queue_API_Field__c, Queue_Name__c FROM Lead_Assignment__mdt WHERE Assignment_Required__c =true WITH SECURITY_ENFORCED]){
                channelSourceVsRecord.put(leadAssignData.Source_Channel__c+'~'+leadAssignData.Source_Name__c,leadAssignData);
                if(leadAssignData.isQueue__c){
                    queueNameSet.add(leadAssignData.Queue_Name__c);
                }
            }
            // Add Centralize Queue Developer Name
            queueNameSet.add(Label.Centralize_Lead_Queue_DeveloperName);
            if(!queueNameSet.isEmpty()){
                for(Group groupRecord : [SELECT Id,DeveloperName FROM Group WHERE Type ='Queue' AND DeveloperName IN:queueNameSet WITH SECURITY_ENFORCED]){
                    queueNameVsId.put(groupRecord.DeveloperName,groupRecord.Id);
                }
            }
            system.debug(LoggingLevel.Info,'Queue Name Centralize ' + queueNameVsId.get(Label.Centralize_Lead_Queue_DeveloperName));
            for(LeadWrapper.LeadRecord leadRecord: leadWrapper.leadRecordList){
                if(String.isNotBlank(leadRecord.outletcode)) {
                    dealerCode.add(leadRecord.outletcode.toUpperCase());
                }
                else if(String.isNotBlank(leadRecord.dealerCode)){
                    dealerCode.add(leadRecord.dealerCode.toUpperCase());
                }
                if(String.isNotBlank(leadRecord.pinCode)){
                    pinCodeSet.add(leadRecord.pinCode);
                }
            }
            for(Branch_Mapping__c branchMapRecord : [SELECT Id,Branch__c,Branch__r.Account_Code__c,Branch__r.Name, Branch__r.Branch_Queue__c,Dealer__c,Dealer__r.Name, Dealer__r.Account_Code__c,Dealer__r.Outlet_code__c,Zip_Code__c FROM Branch_Mapping__c WHERE (Zip_Code__c IN:pinCodeSet OR Dealer__r.Account_Code__c IN:dealerCode) AND Is_Active__c =true WITH SECURITY_ENFORCED]){
                if(String.isNotBlank(branchMapRecord.Dealer__r.Account_Code__c) && String.isNotBlank(branchMapRecord.Branch__r.Account_Code__c)){
                    if(dealerVsBranches.containsKey(branchMapRecord.Dealer__r.Account_Code__c)){
                        dealerVsBranches.get(branchMapRecord.Dealer__r.Account_Code__c.toUpperCase()).put(branchMapRecord.Branch__r.Account_Code__c,branchMapRecord.Branch__r);
                    }else{
                        dealerVsBranches.put(branchMapRecord.Dealer__r.Account_Code__c.toUpperCase(),new Map<String,Account>{branchMapRecord.Branch__r.Account_Code__c => branchMapRecord.Branch__r});
                    }
                }
                if(String.isNotBlank(branchMapRecord.Zip_Code__c) && String.isNotBlank(branchMapRecord.Branch__r.Account_Code__c)){
                    zipBranchVsBranchRecord.put(branchMapRecord.Zip_Code__c+'~'+branchMapRecord.Branch__r.Account_Code__c.toUpperCase(),branchMapRecord.Branch__r);
                    List<Account> lstAcc = NULL;
                    if(zipVsBranchRecord.containsKey(branchMapRecord.Zip_Code__c)) {
                        lstAcc = zipVsBranchRecord.get(branchMapRecord.Zip_Code__c);
                        lstAcc.add(branchMapRecord.Branch__r);
                        accountIdSetForQueueQuery.add(branchMapRecord.Branch__c);
                    }
                    else {
                        lstAcc = new List<Account>();
                        lstAcc.add(branchMapRecord.Branch__r);
                        accountIdSetForQueueQuery.add(branchMapRecord.Branch__c);
                    }
                    zipVsBranchRecord.put(branchMapRecord.Zip_Code__c,lstAcc);
                    branchCodeVsZip.put(branchMapRecord.Branch__r.Account_Code__c.toUpperCase(),branchMapRecord.Zip_Code__c);
                }
                if(String.isNotBlank(branchMapRecord.Dealer__r.Account_Code__c)){
                    if(dealerVsBranches.containsKey(branchMapRecord.Dealer__r.Account_Code__c.toUpperCase())){
                        dealerVsBranches.get(branchMapRecord.Dealer__r.Account_Code__c.toUpperCase()).put(branchMapRecord.Branch__r.Account_Code__c.toUpperCase(),branchMapRecord.Branch__r);
                    }else{
                        dealerVsBranches.put(branchMapRecord.Dealer__r.Account_Code__c.toUpperCase(),new Map<String,Account>{branchMapRecord.Branch__r.Account_Code__c.toUpperCase() => branchMapRecord.Branch__r});
                    }
                }
            }
            // getting the account queue details for SFAU-3985
            for (Account each : [SELECT Id, Branch_Queue__c FROM Account WHERE Id IN :accountIdSetForQueueQuery]) {
                if (String.isBlank(each.Branch_Queue__c)) {
                    continue;
                }
                accountToQueueMap.put(each.Id, Id.valueOf(each.Branch_Queue__c));
                queueOwnerCountMap.put(Id.valueOf(each.Branch_Queue__c),0);
            }
            if (!accountToQueueMap.isEmpty()) {
                for (AggregateResult each : [SELECT OwnerId, count(Id) FROM Loan_Application__c WHERE Stage__c = 'Lead' AND OwnerId IN :accountToQueueMap.values() GROUP BY OwnerId]) {
                    queueOwnerCountMap.put((String) each.get('OwnerId'), (Integer) each.get('expr0'));
                }
            }
            for(LeadWrapper.LeadRecord leadRecord: leadWrapper.leadRecordList){
                Boolean blnFindOwner = false;
                String strOutletOrDealerCode = String.isNotBlank(leadRecord.outletcode) ? leadRecord.outletcode.toUpperCase() : String.isNotBlank(leadRecord.dealercode) ? leadRecord.dealercode.toUpperCase() : '';
                //String strBranchPinCode = String.isNotBlank(leadRecord.pincode) ? l
                system.debug(LoggingLevel.Info,'strOutletOrDealerCode ' + strOutletOrDealerCode);
                Lead_Assignment__mdt leadAssigRecord = channelSourceVsRecord.get(leadRecord.sourcechannel+'~'+leadRecord.sourcename);
                system.debug(LoggingLevel.Info,'leadAssigRecord : ' + leadAssigRecord);
                system.debug(LoggingLevel.Info,'leadRecord.loanId : ' + leadRecord.loanId);
                if (leadAssigRecord == NULL && queueNameVsId.containsKey(Label.Centralize_Lead_Queue_DeveloperName)) {
                	leadRecord.ownerId = queueNameVsId.get(Label.Centralize_Lead_Queue_DeveloperName);
                    mapLeadIdWithOwnerId.put(leadRecord.loanId,queueNameVsId.get(Label.Centralize_Lead_Queue_DeveloperName));
                    continue;
                }
                if(leadAssigRecord.isQueue__c){
                    system.debug(LoggingLevel.Info,'Queue leadAssigRecord : ' + leadAssigRecord);
                    system.debug(LoggingLevel.Info,'Queue leadRecord.loanId : ' + leadRecord.loanId);
                    leadRecord.ownerId = queueNameVsId.get(leadAssigRecord.Queue_Name__c);
                    mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                    blnFindOwner = true;
                }else{
                    if(String.isNotBlank(leadAssigRecord.Priority1__c)){
                        if(leadAssigRecord.Priority1__c == dealerCode_CustomerPin && dealerVsBranches != NULL && dealerVsBranches.containskey(strOutletOrDealerCode)){
                            Map<String,Account>dealerAccount =  dealerVsBranches.get(strOutletOrDealerCode);
                            system.debug(LoggingLevel.Info,'dealerAccount : ' + dealerAccount);
                            for(String accCode : dealerAccount.keySet()){
                                system.debug(LoggingLevel.Info,'accCode : ' + accCode);
                                leadRecord.branchcode = accCode;
                                if(zipBranchVsBranchRecord != NULL && zipBranchVsBranchRecord.containsKey(leadRecord.pinCode+'~'+accCode.toUpperCase())){
                                    Account accRecord = zipBranchVsBranchRecord.get(leadRecord.pinCode+'~'+accCode.toUpperCase());
                                    system.debug(LoggingLevel.Info,'accRecord ... ' + accRecord);
                                    if(String.isNotBlank(String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c)))){
                                        String ownerIdStr = String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c));
                                        leadRecord.ownerId = ownerIdStr;
                                        mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                                        mapLeadWithBranch.put(leadRecord.loanId,accRecord);
                                        blnFindOwner = true;
                                        system.debug(LoggingLevel.Info,'Owner Id ' + leadRecord.OwnerId);
                                        continue;
                                    }
                                }
                            }
                        }
                        if(leadAssigRecord.Priority1__c == customerPin && !blnFindOwner){
                            
                            if(zipBranchVsBranchRecord != NULL && String.isNotBlank(leadRecord.pinCode) && String.isNotBlank(leadRecord.branchcode.toUpperCase()) && zipBranchVsBranchRecord.containsKey(leadRecord.pinCode+'~'+leadRecord.branchcode.toUpperCase())){
                                system.debug('Here..... at line 215');
                                Account accRecord = zipBranchVsBranchRecord.get(leadRecord.pinCode+'~'+leadRecord.branchcode.toUpperCase());
                                if(String.isNotBlank(String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c)))){
                                    String ownerIdStr = String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c));
                                    leadRecord.ownerId = ownerIdStr;
                                    mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                                    mapLeadWithBranch.put(leadRecord.loanId,accRecord);
                                    blnFindOwner = true;
                                    system.debug(LoggingLevel.Info,'Owner Id ' + leadRecord.OwnerId);
                                    continue;
                                }
                            }
                            if(zipVsBranchRecord != NULL && zipVsBranchRecord.containsKey(leadRecord.pinCode) && !blnFindOwner){
                                system.debug('Here..... at line 228');
                                List<Account> accRecord = zipVsBranchRecord.get(leadRecord.pinCode);
                                //SFAU-3985 fixes
                                Id queueIdWithLeadOwnership;
                                Integer ownerShipCount;
                                for (Account each : accRecord) {
                                    if (accountToQueueMap.containsKey(each.Id) && queueOwnerCountMap.containsKey(accountToQueueMap.get(each.Id))) {
                                        if (ownerShipCount == null || ownerShipCount > queueOwnerCountMap.get(accountToQueueMap.get(each.Id))) {
                                            ownerShipCount = queueOwnerCountMap.get(accountToQueueMap.get(each.Id));
                                            queueIdWithLeadOwnership = accountToQueueMap.get(each.Id);
                                            mapLeadWithBranch.put(leadRecord.loanId,each);
                                            blnFindOwner = true;
                                        }
                                    }
                                }
                                leadRecord.OwnerId = queueIdWithLeadOwnership;
                                mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                                system.debug(LoggingLevel.Info,'Owner Id ' + leadRecord.OwnerId);
                            }
                        }
                    }
                    if(String.isNotBlank(leadAssigRecord.Priority2__c) && !blnFindOwner){
                        system.debug('Here..... at line 259');
                        
                        if (leadAssigRecord.Priority2__c == customerPin && !blnFindOwner) {
                            system.debug('Here..... at line 281');
                            if(zipBranchVsBranchRecord != NULL && String.isNotBlank(leadRecord.pinCode) && String.isNotBlank(leadRecord.branchcode.toUpperCase()) && zipBranchVsBranchRecord.containsKey(leadRecord.pinCode+'~'+leadRecord.branchcode.toUpperCase())){
                                system.debug('Here..... at line 283');
                                Account accRecord = zipBranchVsBranchRecord.get(leadRecord.pinCode+'~'+leadRecord.branchcode.toUpperCase());
                                if(String.isNotBlank(String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c)))){
                                    String ownerIdStr = String.valueOf(accRecord.get(leadAssigRecord.Queue_API_Field__c));
                                    leadRecord.ownerId = ownerIdStr;
                                    mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                                    mapLeadWithBranch.put(leadRecord.loanId,accRecord);
                                    blnFindOwner = true;
                                    system.debug(LoggingLevel.Info,'Owner Id ' + leadRecord.OwnerId);
                                    continue;
                                }
                            }
                            if(zipVsBranchRecord != NULL && zipVsBranchRecord.containsKey(leadRecord.pinCode) && !blnFindOwner){
                                system.debug('Here..... at line 296');
                                List<Account> accRecord = zipVsBranchRecord.get(leadRecord.pinCode);
                                system.debug('Here..... at line 299');
                                //SFAU-3985 fixes
                                Id queueIdWithLeadOwnership;
                                Integer ownerShipCount;
                                for (Account each : accRecord) {
                                    system.debug('Here..... at line 307' + each);
                                    system.debug('Here..... at line 308' + accountToQueueMap + ' :::: ' + accountToQueueMap.containsKey(each.Id));
                                    system.debug('Here..... at line 309' + accountToQueueMap.get(each.Id));
                                    system.debug('Here..... at line 310' + queueOwnerCountMap);
                                    system.debug('Here..... at line 311' + queueOwnerCountMap.get(accountToQueueMap.get(each.Id)));
                                    system.debug('Here..... at line 312' + queueOwnerCountMap.containsKey(accountToQueueMap.get(each.Id)));
                                    if (accountToQueueMap.containsKey(each.Id) && queueOwnerCountMap.containsKey(accountToQueueMap.get(each.Id))) {
                                        if (ownerShipCount == null || ownerShipCount > queueOwnerCountMap.get(accountToQueueMap.get(each.Id))) {
                                            ownerShipCount = queueOwnerCountMap.get(accountToQueueMap.get(each.Id));
                                            queueIdWithLeadOwnership = accountToQueueMap.get(each.Id);
                                            mapLeadWithBranch.put(leadRecord.loanId,each);
                                            blnFindOwner = true;
                                        }
                                    }
                                    else {

                                    }
                                }
                                leadRecord.OwnerId = queueIdWithLeadOwnership;
                                mapLeadIdWithOwnerId.put(leadRecord.loanId,leadRecord.ownerId);
                                system.debug(LoggingLevel.Info,'Owner Id ' + leadRecord.OwnerId);
                            }
                        }
                    }
                }
                if (!blnFindOwner && queueNameVsId.containsKey(Label.Centralize_Lead_Queue_DeveloperName)) {
                    mapLeadIdWithOwnerId.put(leadRecord.loanId,queueNameVsId.get(Label.Centralize_Lead_Queue_DeveloperName));
                }
            }
            system.debug(LoggingLevel.Debug,'queueNameVsId ' + queueNameVsId.containsKey(Label.Centralize_Lead_Queue_DeveloperName));
            system.debug(LoggingLevel.Debug,'queueName Id ' + queueNameVsId.get(Label.Centralize_Lead_Queue_DeveloperName));
            
            //leadWrapper.dealerCodeVsOwner = dealerVsDealerPinOwnerMap;
            leadWrapper.pinCodeVsOwner = pinCodeVsBranchQueue;
            leadWrapper.mapLeadIdWithOwnerId = mapLeadIdWithOwnerId;
            leadWrapper.mapLeadWithBranch = mapLeadWithBranch;
        }
        catch(Exception ex){
            system.debug('Exception line Error '+ 'Class : LeadAssignementUtility ' +  ex);
            system.debug('Exception line '+ex.getLineNumber());
            throw new CustomException (ex);
        }
        return leadWrapper;
    }
    
    public class CustomException extends Exception {}
}