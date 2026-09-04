public class AUSFLoanApplicationAssignmentHandler {
    public static Map<String,String> mapOfApprovalLevel4W = new Map<String,String>();
    public static Map<String,String> mapOfDeviationLevel4W = new Map<String,String>();
    public static Map<String,String> mapOfApprovalLevel4WDesc = new Map<String,String>();
    public static Map<String,String> mapOfDeviationLevel4WDesc = new Map<String,String>();
    private static List<Loan_Application__c> listOfLoanApplication = new List<Loan_Application__c>();
    private static List<String> listOfBranch = new List<String>{'0016s00000Z0x1wAAB','0016s00000ZR0NjAAL'};
    private static Map<String,List<Loan_Application__c>> mapOfBranchVsLoanApp = new Map<String,List<Loan_Application__c>>();
    private static Map<String,List<String>> mapOfBranchVsHighestApprover = new Map<String,List<String>>();
    private static Map<String,List<String>> mapOfBranchVsMiddleApprover = new Map<String,List<String>>(); 
    private static Map<String,List<String>> mapOfBranchVsLowestApprover = new Map<String,List<String>>();
    private static String breApprovalValue ='L1';
    private static String breDeviationValue ='S2';
    public AUSFLoanApplicationAssignmentHandler(){
        String strApp = Approver_Deviation_Level_Mapping__mdt.getInstance('ApprovalLevel4W').Level_Mapping__c;
        String strDev = Approver_Deviation_Level_Mapping__mdt.getInstance('DeviationLevel4W').Level_Mapping__c;
        String strAppDesc = Approver_Deviation_Level_Mapping__mdt.getInstance('ApprovalLevel4WDesc').Level_Mapping__c;
        String strDevDesc = Approver_Deviation_Level_Mapping__mdt.getInstance('DeviationLevel4WDesc').Level_Mapping__c;
        mapOfApprovalLevel4W = (Map<String,String>)JSON.deserialize(strApp, Map<String,String>.class);
        mapOfDeviationLevel4W = (Map<String,String>)JSON.deserialize(strDev, Map<String,String>.class);
        mapOfApprovalLevel4WDesc = (Map<String,String>)JSON.deserialize(strAppDesc, Map<String,String>.class);
        mapOfDeviationLevel4WDesc = (Map<String,String>)JSON.deserialize(strDevDesc, Map<String,String>.class);
        
    }
    
    public static void getListOfApprovers(){
        Map<String,Map<String,Set<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel = new Map<String,Map<String,Set<AccountTeamMember>>>();
        Map<String,Set<AccountTeamMember>> mapOfDeviationLevelVsAccountTeam ;
        for(AccountTeamMember accTeam:[SELECT Id,AccountId,UserId,Approver_Level__c,Deviation_Level__c FROM AccountTeamMember WHERE Deviation_Level__c!=null AND Approver_Level__c!=null AND AccountId =:listOfBranch ORDER BY AccountId]){
            String approverValue = accTeam.Approver_Level__c;
            String deviationValue = accTeam.Deviation_Level__c;
            List<String> sepratedApproverList = approverValue.split(';');
            List<String> sepratedDeviationList = deviationValue.split(';');
            system.debug('sepratedApproverList '+sepratedApproverList);
            system.debug('sepratedDeviationList '+sepratedDeviationList);
            if(sepratedApproverList.size()>0){
                for(String app:sepratedApproverList){
                    if(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(app)){  
                        if(sepratedDeviationList.size()>0){
                            for(String dev:sepratedDeviationList){
                                if(mapOfDeviationLevelVsAccountTeam.containsKey(dev)){
                                    system.debug('in s1 '+mapOfApproverLevelVsMapOfDeviationLevel.get(app));
                                    mapOfApproverLevelVsMapOfDeviationLevel.get(app).get(dev).add(accTeam);
                                }else{
                                    Set<AccountTeamMember> listOfAccTeam = new Set<AccountTeamMember>();
                                    listOfAccTeam.add(accTeam);
                                    mapOfApproverLevelVsMapOfDeviationLevel.get(app).put(dev,listOfAccTeam);
                                }
                            }
                        }
                    }else{
                        mapOfDeviationLevelVsAccountTeam = new Map<String,Set<AccountTeamMember>>();
                        if(sepratedDeviationList.size()>0){
                            for(String dev:sepratedDeviationList){
                                if(mapOfDeviationLevelVsAccountTeam.containsKey(dev)){
                                    mapOfDeviationLevelVsAccountTeam.get(dev).add(accTeam);
                                }else{
                                    Set<AccountTeamMember> listOfAccTeam = new Set<AccountTeamMember>();
                                    listOfAccTeam.add(accTeam);
                                    mapOfDeviationLevelVsAccountTeam.put(dev,listOfAccTeam);
                                }
                            }
                        }
                        mapOfApproverLevelVsMapOfDeviationLevel.put(app,mapOfDeviationLevelVsAccountTeam);
                    }
                }
            }
        }
        
        system.debug('mapOfApproverLevelVsMapOfDeviationLevel '+mapOfApproverLevelVsMapOfDeviationLevel);
        getBaseLevelApproval(mapOfApproverLevelVsMapOfDeviationLevel,listOfLoanApplication);
    }
    public static void getListOfApprovals(Map<String,Map<String,Set<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel){
        List<AccountTeamMember> lowestApprovals = new List<AccountTeamMember>();
        List<AccountTeamMember> middleApprovals = new List<AccountTeamMember>();
        List<AccountTeamMember> highestApprovals = new List<AccountTeamMember>();
        Map<String,String> mapOfLoanAppIdVsBreLevels = new Map<String,String>{'a016s000003bdabAAA'=>'L1;S1'};
        for(Loan_Application__c loanApp:listOfLoanApplication){
            
        }
    }
    public static Set<AccountTeamMember> getMiddleLevelApproverList(Map<String,Map<String,Set<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel,String appBreKey, String devBreKey){
        Boolean allAppValid = false;
        Boolean allDevValid = false;
        system.debug('appBreKey '+appBreKey);
        system.debug('devBreKey '+devBreKey);
        system.debug('mapOfApprovalLevel4W '+mapOfApprovalLevel4W);
        system.debug('mapOfApprovalLevel4W '+mapOfDeviationLevel4W);
        Set<AccountTeamMember> accountTeamMemberList = new Set<AccountTeamMember>();
        if(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(appBreKey)){
            allAppValid = true;
            if(mapOfApproverLevelVsMapOfDeviationLevel.get(appBreKey).containsKey(devBreKey)){
                allDevValid = true;
                accountTeamMemberList.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(appBreKey).get(devBreKey));
            }
        }
        if(allAppValid && allDevValid){
            return accountTeamMemberList;
        }else if(!allAppValid){
            system.debug('in 1st if');
            if(mapOfApprovalLevel4WDesc.containsKey(appBreKey)){
               return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,mapOfApprovalLevel4WDesc.get(appBreKey),devBreKey);
            }else{
                return accountTeamMemberList;
            }
        }else if(allAppValid && !allDevValid){
            system.debug('in 2nd if');
            if(mapOfDeviationLevel4W.containsKey(devBreKey)){
                return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,appBreKey,mapOfDeviationLevel4WDesc.get(devBreKey));
            }else{
                return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,appBreKey,'S1');
            }
            
        }else{
            system.debug('in 3rd if');
            return getMiddleLevelApproverList(mapOfApproverLevelVsMapOfDeviationLevel,mapOfApprovalLevel4WDesc.get(appBreKey),mapOfDeviationLevel4WDesc.get(devBreKey));
        }
        
    }
    
    public static Set<AccountTeamMember> getHighestApproverList(Map<String,Map<String,Set<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel,String appBreKey, String devBreKey){
        Boolean allAppValid = false;
        Boolean allDevValid = false;
        system.debug('appBreKey '+appBreKey);
        system.debug('devBreKey '+devBreKey);
        system.debug('mapOfApprovalLevel4W '+mapOfApprovalLevel4W);
        system.debug('mapOfApprovalLevel4W '+mapOfDeviationLevel4W);
        Set<AccountTeamMember> accountTeamMemberList = new Set<AccountTeamMember>();
        if(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(appBreKey)){
            allAppValid = true;
            if(mapOfApproverLevelVsMapOfDeviationLevel.get(appBreKey).containsKey(devBreKey)){
                allDevValid = true;
                accountTeamMemberList.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(appBreKey).get(devBreKey));
            }
        }
        if(allAppValid && allDevValid){
            return accountTeamMemberList;
        }else if(!allAppValid){
            system.debug('in 1st if');
            if(mapOfApprovalLevel4W.containsKey(appBreKey)){
              return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,mapOfApprovalLevel4W.get(appBreKey),devBreKey);
            }else{
               return accountTeamMemberList;
            }
        }else if(allAppValid && !allDevValid){
            system.debug('in 2nd if');
            if(mapOfDeviationLevel4W.containsKey(devBreKey)){
                return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,appBreKey,mapOfDeviationLevel4W.get(devBreKey));
            }else{
                return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,appBreKey,'S1');
            }
            
        }else{
            system.debug('in 3rd if');
            return getHighestApproverList(mapOfApproverLevelVsMapOfDeviationLevel,mapOfApprovalLevel4W.get(appBreKey),mapOfDeviationLevel4W.get(devBreKey));
        }
        
    }
    
    public static void getBaseLevelApproval(Map<String,Map<String,Set<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel,List<Loan_Application__c> listOfLoanApplication){
        Set<String> approvalKeys = mapOfApproverLevelVsMapOfDeviationLevel.keySet();
        List<String> approvalKeysList = new List<String>();
        approvalKeysList.addAll(approvalKeys);
        system.debug('before sort approvalKeysList '+approvalKeysList);
        approvalKeysList.sort();
        system.debug('after sort approvalKeysList '+approvalKeysList);
        
        //for(Loan_Application__c app:listOfLoanApplication){       
        for(String key:approvalKeysList){
            //Map<String,Set<AccountTeamMember>> mapOfDeviationVsAccounTeam = mapOfApproverLevelVsMapOfDeviationLevel.get(key);
            Set<String> deviationKeys = mapOfApproverLevelVsMapOfDeviationLevel.get(key).keySet();
            List<String> deviationKeysList = new List<String>();
            deviationKeysList.addAll(deviationKeys);
            system.debug('before sort deviationKeysList '+deviationKeysList);
            deviationKeysList.sort();
            system.debug('after sort deviationKeysList '+deviationKeysList);
            for(String devKey:deviationKeysList){
                
                if(breApprovalValue == key && breDeviationValue == devKey){
                    for(AccountTeamMember acc:mapOfApproverLevelVsMapOfDeviationLevel.get(key).get(devKey)){
                        if(mapOfBranchVsHighestApprover.containsKey(acc.accountId)){
                            mapOfBranchVsHighestApprover.get(acc.accountId).add(acc.UserId);
                        }else{
                            List<String> listOfAccTeam = new List<String>();
                            listOfAccTeam.add(acc.UserId);
                            mapOfBranchVsHighestApprover.put(acc.accountId,listOfAccTeam);
                        }
                    }
                }
                
                if(mapOfBranchVsLowestApprover.size()==0){
                    for(AccountTeamMember acc:mapOfApproverLevelVsMapOfDeviationLevel.get(key).get(devKey)){
                        if(mapOfBranchVsLowestApprover.containsKey(acc.accountId)){
                            mapOfBranchVsLowestApprover.get(acc.accountId).add(acc.UserId);
                        }else{
                            List<String> listOfAccTeam = new List<String>();
                            listOfAccTeam.add(acc.UserId);
                            mapOfBranchVsLowestApprover.put(acc.accountId,listOfAccTeam);
                        }
                    } 
                }
                system.debug('mapOfBranchVsLowestApprover '+mapOfBranchVsLowestApprover);
            }
            
            system.debug('before ber value app '+ breApprovalValue);
            breApprovalValue = mapOfApprovalLevel4W.get(breApprovalValue);
            system.debug('after ber value app '+ breApprovalValue);
            
        } 
        //}
    }

    
}