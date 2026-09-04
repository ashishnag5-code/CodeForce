/*
@ Class Name: AUSFLoanApplicationAssignmentHelper
@ Test Class: AUSFLoanApplicationAssignmentHelperTest
@ Code Coverage: 
@ Description: Loan Assignment
@ Logs:
@   Last Modified Date  -   Last Modified By    -   Bug
@   Dec-15-2023         -   Yash S              -   SFAU-5747 - 
@   Dec-18-2023         -   Mohit M.            -   SFAU-5664 - STP Case Credit
@   Jan-01-2024         -   Yash S .            -   SFAU-5797 - Duplicate CHeck


*/
public without sharing class AUSFLoanApplicationAssignmentHelper {
    
    public static Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
    public static Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
    public static Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
    public static Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
    public static Map<String,String> mapOfNextKey = new Map<String,String>();
    public static Map<String,String> mapOfPreviousKey = new Map<String,String>();
    public static Boolean breTrigger = false;
    public static Boolean isSTPwithConditions = false;
    public static Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
    private static List<Loan_Application__c> listOfLoanApplication = new List<Loan_Application__c>(); 
        private static Map<String,List<Loan_Application__c>> mapOfBranchVsLoanApp = new Map<String,List<Loan_Application__c>>();
    public static Map<String,String> loanAppIdVsKey = new Map<String,String>();
        private static Map<String,List<String>> mapOfBranchVsHighestApprover = new Map<String,List<String>>();
    private static Map<String,List<String>> mapOfBranchVsMiddleApprover = new Map<String,List<String>>(); 
    private static Map<String,List<String>> mapOfBranchVsLowestApprover = new Map<String,List<String>>();
    private static Loan_Application_Approval__c[] finalApprovers = new loan_Application_Approval__c[0];
    static map<Id, Id> ncmAvailableByBranch;
    // STP ISSUE
    public static Integer intMiddleLevel = null;

    /**
     */
    public static Boolean isCalledFromFI = false;


    public static String approvalType;
    public AUSFLoanApplicationAssignmentHelper(){
        getMapOfNextKeys();
        //getTwoWheelerKeys();
    }

    public AUSFLoanApplicationAssignmentHelper(String approvalTypeParam, Map<String,String> mapOfLoanAppIdVsKey){

        approvalType = approvalTypeParam;
        if(approvalTypeParam == GlobalConstants.APPROVAL_TYPE_CREDIT){
            getMapOfNextKeys();
        }
        if(approvalTypeParam == GlobalConstants.APPROVAL_TYPE_PRICING){
            loanAppIdVsKey = mapOfLoanAppIdVsKey;
            getMapOfNextKeysForPricing();
        }
        
        //getTwoWheelerKeys();
    }

    
    public Static void getTwoWheelerKeys(){
        List<String> listOfApproval = new List<String>();
        String strAppAsc = Approver_Deviation_Level_Mapping__mdt.getInstance('ApprovalLevel4W').Level_Mapping__c;
        system.debug('strAppAsc '+strAppAsc);
        listOfApproval = strAppAsc.split(',');
        system.debug('listOfApproval '+listOfApproval);
        Map<String,String> mapOfNextKeyTwoWheeler = new Map<String,String>();
        Map<String,String> mapOfPreviousKeyTwoWheeler = new Map<String,String>();
        for (Integer i = 0; i < listOfApproval.size()-1; i++){
            mapOfNextKeyTwoWheeler.put(listOfApproval[i], listOfApproval[i+1]);
            mapOfPreviousKeyTwoWheeler.put(listOfApproval[i+1], listOfApproval[i]);
            
        }
        system.debug('mapOfNextKeyTwoWheeler '+mapOfNextKeyTwoWheeler);
        system.debug('mapOfPreviousKeyTwoWheeler '+mapOfPreviousKeyTwoWheeler);
    }
    
    public Static void getMapOfNextKeys(){
        List<String> listOfApproval = new List<String>();
        List<String> listOfDeviation = new List<String>();
        String strAppAsc = Approver_Deviation_Level_Mapping__mdt.getInstance('ApprovalLevel4W').Level_Mapping__c;
        String strDevDesc = Approver_Deviation_Level_Mapping__mdt.getInstance('DeviationLevel4W').Level_Mapping__c;
        system.debug('strAppAsc '+strAppAsc);
        system.debug('strDevDesc '+strDevDesc);
        listOfApproval = strAppAsc.split(',');
        listOfDeviation = strDevDesc.split(',');
        system.debug('listOfApproval '+listOfApproval);
        system.debug('listOfDeviation '+listOfDeviation);
        Map<String,String> mapOfKeys = new Map<String,String>();
        for (Integer i = 0; i < listOfApproval.size(); i++){
            if(i < listOfApproval.size()-1){
                mapOfNextKey.put(listOfApproval[i], listOfApproval[i+1]);
                mapOfPreviousKey.put(listOfApproval[i+1], listOfApproval[i]); 
            }
            
            for (Integer j = 0; j < listOfDeviation.size(); j++){
                if(j==listOfDeviation.size()-1 && i < listOfApproval.size()-1){
                    mapOfNextKey.put(listOfApproval[i]+listOfDeviation[j],listOfApproval[i+1]+listOfDeviation[0]);
                    mapOfPreviousKey.put(listOfApproval[i+1]+listOfDeviation[0],listOfApproval[i]+listOfDeviation[j]);
                    system.debug('in inner if');
                    system.debug('mapOfKeys '+mapOfKeys);
                    system.debug('j is '+j +'i is '+i);
                }else{
                    system.debug('j is '+j +'i is '+i);
                    if(i!=listOfApproval.size()-1){
                        mapOfNextKey.put(listOfApproval[i]+listOfDeviation[j],listOfApproval[i]+listOfDeviation[j+1]);
                        mapOfPreviousKey.put(listOfApproval[i]+listOfDeviation[j+1],listOfApproval[i]+listOfDeviation[j]);
                    } else if(i == listOfApproval.size() - 1 && j < listOfDeviation.size() - 1){ //Sachin - L5* Assignments are not working
                        mapOfNextKey.put(listOfApproval[i] + listOfDeviation[j], listOfApproval[i] + listOfDeviation[j + 1]);
                        mapOfPreviousKey.put(listOfApproval[i] + listOfDeviation[j + 1], listOfApproval[i] + listOfDeviation[j]);
                    }
                }
            }
        }
        system.debug('mapOfKeys '+JSON.serializePretty(mapOfNextKey));
        system.debug('mapOfKeys '+JSON.serializePretty(mapOfPreviousKey));
        //return mapOfKeys;
    }

    public static void getMapOfNextKeysForPricing(){
        List<String> listOfApproval = new List<String>();
        String strAppAsc = Approver_Deviation_Level_Mapping__mdt.getInstance('PricingApprovalLevel').Level_Mapping__c;
        system.debug('strAppAsc '+strAppAsc);
        listOfApproval = strAppAsc.split(',');
        system.debug('listOfApproval '+listOfApproval);
        Map<String,String> mapOfKeys = new Map<String,String>();
        for (Integer i = 0; i < listOfApproval.size(); i++){
            if(i < listOfApproval.size()-1){
                mapOfNextKey.put(listOfApproval[i], listOfApproval[i+1]);
                mapOfPreviousKey.put(listOfApproval[i+1], listOfApproval[i]); 
            }
        }
        system.debug('mapOfKeys '+mapOfNextKey);
        system.debug('mapOfKeys '+mapOfPreviousKey);
    }
    
    public static void mainMethod(List<AccountTeamMember> lisOfAccountTeamMembers, List<Loan_Application__c> loanApplicationList){

        // SFAU-5664 - STP Case Credit
        mainMethod(approvalType, lisOfAccountTeamMembers, loanApplicationList[0], loanApplicationList[0].BRE_Approval_Level__c);

        /* Commented as part of STP ISSUE - SFAU-5664 - STP Case Credit
        Map<String,List<Loan_Application__c>> returnMap = new Map<String,List<Loan_Application__c>>();
        returnMap = getListOfApprovals('Branch',lisOfAccountTeamMembers,loanApplicationList,null);
        if(returnMap == null){
            returnMap = new Map<String,List<Loan_Application__c>>();
        }
        Map<String,List<Loan_Application__c>> returnHubMap = new Map<String,List<Loan_Application__c>>();
        List<Loan_Application__c> allLoanApplications = new List<Loan_Application__c>();
        
        if(returnMap.containsKey('Highest') && returnMap.get('Highest').size()>0){
            allLoanApplications.addAll(returnMap.get('Highest'));
        }
        if(returnMap.containsKey('Middle') && returnMap.get('Middle').size()>0){
            allLoanApplications.addAll(returnMap.get('Middle'));
        }
        if(returnMap.containsKey('Base') && returnMap.get('Base').size()>0 && approvalType!=GlobalConstants.APPROVAL_TYPE_PRICING){
            allLoanApplications.addAll(returnMap.get('Base'));
        }
        if(returnMap==null || returnMap.keySet().size()==0){
            allLoanApplications.addAll(loanApplicationList);
            returnMap.put('Highest',loanApplicationList);
            returnMap.put('Middle',loanApplicationList);
            returnMap.put('Base',loanApplicationList);
        }
        system.debug('allLoanApplications >>'+allLoanApplications);
        if(allLoanApplications.size()>0){
            Set<String> listOfHubIds = new Set<String>();
            List<String> loanHubIds = new List<String>();
            for(Loan_Application__c lapp:allLoanApplications){
                listOfHubIds.add(lapp.Branch_Master__r.Business_HUB__c);
                loanHubIds.add(lapp.Id);
            } 
            system.debug('listOfHubIds >>'+listOfHubIds);
            List<AccountTeamMember> listOfHubAccountTeamMember = CreditApprovalHandler.getAccountTeamMembers(listOfHubIds,loanHubIds,mapOfFieldVsListOfValues,approvalType);//getAccountTeamMembers(listOfHubIds);
            system.debug('listOfHubAccountTeamMember >>'+listOfHubAccountTeamMember);         
            if(allLoanApplications.size()>0){
                returnHubMap = getListOfApprovals('Hub',listOfHubAccountTeamMember,allLoanApplications,returnMap);
            }
            if(returnHubMap == null){
                returnHubMap = new Map<String,List<Loan_Application__c>>();
            }
            
            List<Loan_Application__c> allLoanHubApplications = new List<Loan_Application__c>();
            if(returnHubMap.containsKey('Highest') && returnHubMap.get('Highest').size()>0){
                allLoanHubApplications.addAll(returnMap.get('Highest'));
            }
            if(returnHubMap.containsKey('Middle') && returnHubMap.get('Middle').size()>0){
                allLoanHubApplications.addAll(returnMap.get('Middle'));
            }
            if(returnHubMap.containsKey('Base') && returnHubMap.get('Base').size()>0 && approvalType!=GlobalConstants.APPROVAL_TYPE_PRICING){
                allLoanHubApplications.addAll(returnMap.get('Base'));
            }
            if(returnHubMap==null || returnHubMap.keySet().size()==0){
                allLoanHubApplications.addAll(allLoanApplications);
                returnHubMap.put('Highest',allLoanApplications);
                returnHubMap.put('Middle',allLoanApplications);
                returnHubMap.put('Base',allLoanApplications);
            }
            system.debug('allLoanHubApplications >>'+allLoanHubApplications);
            if(allLoanHubApplications.size()>0){
                Set<String> listOfRegionIds = new Set<String>();
                List<String> loanRegionIds = new List<String>();
                for(Loan_Application__c lapp:allLoanApplications){
                    listOfRegionIds.add(lapp.Branch_Master__r.Region__c);
                    loanRegionIds.add(lapp.Id);
                }
                system.debug('listOfRegionIds >>'+listOfRegionIds);
                List<AccountTeamMember> listOfRegionAccountTeamMember =CreditApprovalHandler.getAccountTeamMembers(listOfRegionIds,loanRegionIds,mapOfFieldVsListOfValues,approvalType);//getAccountTeamMembers(listOfRegionIds);
                system.debug('listOfRegionAccountTeamMember >>'+listOfRegionAccountTeamMember);        
                if(allLoanHubApplications.size()>0){
                    Map<String,List<Loan_Application__c>> returnRegionMap = getListOfApprovals('Region',listOfRegionAccountTeamMember,allLoanApplications,returnHubMap);
                    if(returnRegionMap == null){
                        returnRegionMap = new Map<String,List<Loan_Application__c>>();
                    }        
                    List<Loan_Application__c> allLoanRegionApplications = new List<Loan_Application__c>();
                    if(returnRegionMap.containsKey('Highest') && returnRegionMap.get('Highest').size()>0){
                        allLoanRegionApplications.addAll(returnRegionMap.get('Highest'));
                    }
                    if(returnRegionMap.containsKey('Middle') && returnRegionMap.get('Middle').size()>0){
                        allLoanRegionApplications.addAll(returnRegionMap.get('Middle'));
                    }
                    if(returnRegionMap.containsKey('Base') && returnRegionMap.get('Base').size()>0 && approvalType!=GlobalConstants.APPROVAL_TYPE_PRICING){
                        allLoanRegionApplications.addAll(returnRegionMap.get('Base'));
                    }
                    if(returnRegionMap==null || returnRegionMap.keySet().size()==0){
                        allLoanRegionApplications.addAll(allLoanHubApplications);
                        returnRegionMap.put('Highest',allLoanHubApplications);
                        returnRegionMap.put('Middle',allLoanHubApplications);
                        returnRegionMap.put('Base',allLoanHubApplications);
                    }
                    system.debug('allLoanRegionApplications >>'+allLoanRegionApplications);
                    if(allLoanRegionApplications.size()>0){
                        Set<String> listOfZoneIds = new Set<String>();
                        for(Loan_Application__c lapp:allLoanApplications){
                            listOfZoneIds.add(lapp.Branch_Master__r.Zone__c);
                        }
                        system.debug('listOfZoneIds >>'+listOfZoneIds);
                        List<AccountTeamMember> listOfZoneAccountTeamMember =CreditApprovalHandler.getAccountTeamMembers(listOfZoneIds,loanRegionIds,mapOfFieldVsListOfValues,approvalType); //getAccountTeamMembers(listOfStateIds);
                        system.debug('listOfZoneAccountTeamMember >>'+listOfZoneAccountTeamMember);        
                        if(allLoanRegionApplications.size()>0){
                            Map<String,List<Loan_Application__c>> returnZoneMap = getListOfApprovals('Zone',listOfZoneAccountTeamMember,allLoanApplications,returnRegionMap);
                            if(returnZoneMap == null){
                                returnZoneMap = new Map<String,List<Loan_Application__c>>();
                            }    
                            List<Loan_Application__c> allLoanZoneApplications = new List<Loan_Application__c>();
                            if(returnZoneMap.containsKey('Highest') && returnZoneMap.get('Highest').size()>0){
                                allLoanZoneApplications.addAll(returnZoneMap.get('Highest'));
                            }
                            if(returnZoneMap.containsKey('Middle') && returnZoneMap.get('Middle').size()>0){
                                allLoanZoneApplications.addAll(returnZoneMap.get('Middle'));
                            }
                            if(returnZoneMap.containsKey('Base') && returnZoneMap.get('Base').size()>0 && approvalType!=GlobalConstants.APPROVAL_TYPE_PRICING){
                                allLoanZoneApplications.addAll(returnZoneMap.get('Base'));
                            }
                            if(returnZoneMap==null || returnZoneMap.keySet().size()==0){
                                allLoanZoneApplications.addAll(allLoanRegionApplications);
                                returnZoneMap.put('Highest',allLoanRegionApplications);
                                returnZoneMap.put('Middle',allLoanRegionApplications);
                                returnZoneMap.put('Base',allLoanRegionApplications);
                            }
                            
                            if(allLoanZoneApplications.size()>0){
                                Set<String> listOfNationalIds = new Set<String>();
                                for(Loan_Application__c lapp:allLoanApplications){
                                    listOfNationalIds.add(lapp.Branch_Master__r.National__c);
                                }
                                system.debug('listOfNationalIds >>'+listOfNationalIds);
                                List<AccountTeamMember> listOfNationalAccountTeamMember =CreditApprovalHandler.getAccountTeamMembers(listOfNationalIds,loanRegionIds,mapOfFieldVsListOfValues,approvalType); //getAccountTeamMembers(listOfStateIds);
                                if(!listOfNationalAccountTeamMember.isEmpty()){
                                    // ncmAvailableByBranch = AUSFApproverController.getFallbackNationaCM( listOfNationalIds );
                                }
                                system.debug('listOfNationalAccountTeamMember >>'+listOfNationalAccountTeamMember); 
                                Map<String,List<Loan_Application__c>> returnNationalMap = getListOfApprovals('National',listOfNationalAccountTeamMember,allLoanApplications,returnZoneMap);

                            }
                        }
                    }
                }
            }
            
            
        }
        System.debug(' == =Final Approvals ==> ' + JSON.serializePretty(finalApprovers));
        Database.insert(finalApprovers);
        */
    }
    
    /* Commented as part of STP ISSUE - SFAU-5664 - STP Case Credit
    public static List<AccountTeamMember> getAccountTeamMembers(Set<String> accIds){
        return [SELECT Id,AccountId,UserId,Approver_Level__c,Deviation_Level__c FROM AccountTeamMember WHERE Deviation_Level__c!=null AND Approver_Level__c!=null AND AccountId =:accIds ORDER BY AccountId];
    }
    static map<String, map<String, AccountTeamMember[]>> approveLevelToTeamMembersHierarchy = new map<String, map<String, AccountTeamMember[]>>();
    
    public static Map<String,List<Loan_Application__c>> getListOfApprovals(String callType,List<AccountTeamMember> lisOfAccountTeamMembers,List<Loan_Application__c> loanApplicationList,Map<String,List<Loan_Application__c>> mapLevelVsLoanApp){
        
        Map<String,Map<String,List<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel = new Map<String,Map<String,List<AccountTeamMember>>>();
        Map<String,Map<String,List<AccountTeamMember>>> mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler = new Map<String,Map<String,List<AccountTeamMember>>>();
        Map<String,List<AccountTeamMember>> mapOfDeviationLevelVsAccountTeam ;
        Map<String,List<AccountTeamMember>> mapOfApproverLevelVsAccountTeam ;
        
        for(AccountTeamMember accTeam:lisOfAccountTeamMembers){
            String approverValue = accTeam.Approver_Level__c;
            String deviationValue;
            List<String> sepratedDeviationList = new List<String>();
            if(accTeam.Deviation_Level__c!=null){
               deviationValue = accTeam.Deviation_Level__c;
                system.debug('approverValue '+approverValue);
                sepratedDeviationList = deviationValue.split(';');
            }
            
            
            system.debug('deviationValue '+deviationValue);
            List<String> sepratedApproverList = approverValue.split(';');
            system.debug('sepratedApproverList '+sepratedApproverList);
            
            if(sepratedApproverList.size()>0){
                for(String app:sepratedApproverList){
                    //Two Wheeler
                    if(mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler.containsKey(accTeam.AccountId)){
                        if(mapOfApproverLevelVsAccountTeam.containsKey(app)){
                            mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler.get(accTeam.AccountId).get(app).add(accTeam);
                        }else{
                            List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                            listOfAccTeam.add(accTeam);
                            mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler.get(accTeam.AccountId).put(app,listOfAccTeam);
                        }
                    }else{
                        mapOfApproverLevelVsAccountTeam = new Map<String,List<AccountTeamMember>>();
                        if(mapOfApproverLevelVsAccountTeam.containsKey(app)){
                            mapOfApproverLevelVsAccountTeam.get(app).add(accTeam);
                        }else{
                            List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                            listOfAccTeam.add(accTeam);
                            mapOfApproverLevelVsAccountTeam.put(app,listOfAccTeam);
                        }
                        mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler.put(accTeam.AccountId,mapOfApproverLevelVsAccountTeam);
                    }
                    
                    //Four Wheeler Map
                    if(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(accTeam.AccountId)){ 
                        
                        if(mapOfDeviationLevelVsAccountTeam.containsKey(app)){
                            mapOfApproverLevelVsMapOfDeviationLevel.get(accTeam.AccountId).get(app).add(accTeam);
                        }else{
                            List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                            listOfAccTeam.add(accTeam);
                            mapOfApproverLevelVsMapOfDeviationLevel.get(accTeam.AccountId).put(app,listOfAccTeam);
                        }
                        
                        if(sepratedDeviationList.size()>0){
                            for(String dev:sepratedDeviationList){
                                if(mapOfDeviationLevelVsAccountTeam.containsKey(app+dev)){
                                    mapOfApproverLevelVsMapOfDeviationLevel.get(accTeam.AccountId).get(app+dev).add(accTeam);
                                }else{
                                    List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                                    listOfAccTeam.add(accTeam);
                                    mapOfApproverLevelVsMapOfDeviationLevel.get(accTeam.AccountId).put(app+dev,listOfAccTeam);
                                }
                            }
                        }
                    }else{
                        mapOfDeviationLevelVsAccountTeam = new Map<String,List<AccountTeamMember>>();
                        if(mapOfDeviationLevelVsAccountTeam.containsKey(app)){
                            mapOfDeviationLevelVsAccountTeam.get(app).add(accTeam);
                        }else{
                            List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                            listOfAccTeam.add(accTeam);
                            mapOfDeviationLevelVsAccountTeam.put(app,listOfAccTeam);
                        }
                        if(sepratedDeviationList.size()>0){
                            for(String dev:sepratedDeviationList){
                                if(mapOfDeviationLevelVsAccountTeam.containsKey(app+dev)){
                                    mapOfDeviationLevelVsAccountTeam.get(app+dev).add(accTeam);
                                }else{
                                    List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                                    listOfAccTeam.add(accTeam);
                                    mapOfDeviationLevelVsAccountTeam.put(app+dev,listOfAccTeam);
                                }
                            }
                        }
                        mapOfApproverLevelVsMapOfDeviationLevel.put(accTeam.AccountId,mapOfDeviationLevelVsAccountTeam);
                    }
                    
                    
                }
            }

            approveLevelToTeamMembersHierarchy.putAll(mapOfApproverLevelVsMapOfDeviationLevel);            
        }
        system.debug('mapOfApproverLevelVsMapOfDeviationLevel >>'+mapOfApproverLevelVsMapOfDeviationLevel);
        system.debug('mapOfAccTeamMemberVsMapOfApprLevelForTwoWheeler >>'+mapOfApproverLevelVsMapOfDeviationLevel.get('0016s00000Z0x1wAAB'));
        //List<Loan_Application__c> loanApplicationList =[SELECT Id,Branch_Master__c from Loan_Application__c where id='a016s000003bZs3AAE'];
        return findApprover(callType,loanApplicationList,mapOfApproverLevelVsMapOfDeviationLevel,mapLevelVsLoanApp);
    }
    
    
    
    static map<Id, String> loanToBaseApproval = new map<Id, String>();
    static map<Id, map<String, Boolean>> loanApprovalStatus = new map<Id, map<String, Boolean>>();
    
    public static Map<String,List<Loan_Application__c>> findApprover(String callType,List<Loan_Application__c> loanApplicationList, Map<String,Map<String,List<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel,Map<String,List<Loan_Application__c>> mapLevelVsLoanApp){
        if(mapOfApproverLevelVsMapOfDeviationLevel.isEmpty()) return mapLevelVsLoanApp; // Proceed to next level when there's no team member mapped on the branch / hub / state / region
        Id FourWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
        Id TwoWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        List<Loan_Application_Approval__c> listOfApprovers = new List<Loan_Application_Approval__c>();
        Map<String,List<Loan_Application__c>> mapOfLevelVsLoanId = new Map<String,List<Loan_Application__c>>();
        mapOfLevelVsLoanId.put('Highest',new List<Loan_Application__c>());
        mapOfLevelVsLoanId.put('Middle',new List<Loan_Application__c>());
        mapOfLevelVsLoanId.put('Base',new List<Loan_Application__c>());
        for(Loan_Application__c loanApp:loanApplicationList){
            List<AccountTeamMember> listOfAccountTeamMemberHigh = new List<AccountTeamMember>();
            List<AccountTeamMember> listOfAccountTeamMemberMiddle = new List<AccountTeamMember>();
            List<AccountTeamMember> listOfAccountTeamMemberBase = new List<AccountTeamMember>();
            List<String> listOfKeys = new List<String>();

            if(!loanApprovalStatus.containsKey(loanApp.Id)){
                loanApprovalStatus.put(loanApp.Id, new map<String, Boolean>{
                    'Base' => false,
                    'Middle' => false,
                    'Highest' => false
                });
            }
            String baseKey;
            String appKey;
            String middleKey;
            /*listOfKeys.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(loanApp.Branch_Master__c).keySet());
            listOfKeys.sort();
            listOfAccountTeamMemberBase.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(loanApp.Branch_Master__c).get(listOfKeys[0]));* /
            system.debug('mapOfApproverLevelVsMapOfDeviationLevel >>'+mapOfApproverLevelVsMapOfDeviationLevel);
            system.debug('loanApp '+loanApp);
            String accountId = getAccountId(callType,loanApp);
            if(accountId!=null && mapOfApproverLevelVsMapOfDeviationLevel.containsKey(accountId)){
            if((callType=='Branch' || mapLevelVsLoanApp.get('Base').contains(loanApp)) && approvalType!=GlobalConstants.APPROVAL_TYPE_PRICING){
                baseKey='';
                if(loanApp.RecordTypeId==FourWheelerRecordTypeId){
                    baseKey = Label.CreditBaseApprovalKey4W;
                }
                if(loanApp.RecordTypeId==TwoWheelerRecordTypeId){
                    baseKey = Label.CreditBaseApprovalKey2W;
                }
                
                if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).containsKey(baseKey)){
                    listOfAccountTeamMemberBase.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(baseKey));
                }else{
                    baseKey = getNextKey(baseKey,accountId,mapOfApproverLevelVsMapOfDeviationLevel,mapOfNextKey,'Base',loanApp.BRE_Approval_Level__c);
                    system.debug('appKey after do while '+baseKey);
                    loanApprovalStatus.get(loanApp.Id).put('Base', true);
                    if(baseKey!='NoData'){
                        if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(baseKey).size()>0){
                            loanToBaseApproval.put( loanApp.Id, baseKey );
                            listOfAccountTeamMemberBase.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(baseKey));
                            loanApprovalStatus.get(loanApp.Id).put('Base', true);
                        }
                    }else{
                        //mapOfLoanIdVsLevel.put(loanApp.Id,'Highest');
                        mapOfLevelVsLoanId.get('Base').add(loanApp);
                    }
                    
                }
            }
            if(breTrigger==false){
                    if(callType=='Branch' || mapLevelVsLoanApp.get('Highest').contains(loanApp)){
                        appKey = loanAppIdVsKey.get(loanApp.Id);
                        //String accountId = isBranch?loanApp.Branch_Master__c:loanApp.Branch_Master__r.Business_HUB__c;
                        if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).containsKey(loanAppIdVsKey.get(loanApp.Id))){
                            listOfAccountTeamMemberHigh.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(loanAppIdVsKey.get(loanApp.Id)));
                            loanAppIdVsKey.put(loanApp.Id, appKey);
                            loanApprovalStatus.get(loanApp.Id).put('Highest', true);
                        }else{
                            appKey = getNextKey(appKey,accountId,mapOfApproverLevelVsMapOfDeviationLevel,mapOfNextKey,'Highest',loanApp.BRE_Approval_Level__c);
                            system.debug('appKey after do while '+appKey);
                            if(appKey!='NoData'){
                                if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(appKey).size()>0){
                                    listOfAccountTeamMemberHigh.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(appKey));
                                    loanAppIdVsKey.put(loanApp.Id, appKey);
                                    loanApprovalStatus.get(loanApp.Id).put('Highest', true);
                                }
                            }/*else if( callType == 'National' && loanApprovalStatus.get(loanApp.Id).get('Highest') && ncmAvailableByBranch.containsKey(accountId)){
                                listOfAccountTeamMemberHigh.add(ncmAvailableByBranch.get(accountId));
                            }* / else {
                                //mapOfLoanIdVsLevel.put(loanApp.Id,'Highest');
                                mapOfLevelVsLoanId.get('Highest').add(loanApp);  
                            }
                        }
                        system.debug('listOfAccountTeamMemberHigh L1S5'+listOfAccountTeamMemberHigh);
                    }
                    System.debug(' == mapLevelVsLoanApp ==> ' + JSON.serializePretty(mapLevelVsLoanApp));
                    if(callType != 'Branch'){
                        System.debug(' == CallType == ' + callType);
                        // System.debug('Is Highest found ==> ' + !mapLevelVsLoanApp.get('Highest').contains(loanApp) + '\n is Middle found ==' + mapLevelVsLoanApp.get('Middle').contains(loanApp));
                    }
                    System.debug(' Approval Status ==> ' + JSON.serializePretty(loanApprovalStatus));
                    System.debug(' ===== App to Approval ==> ' + JSON.serializePretty(loanAppIdVsKey));
                    if(/*callType=='Branch' ||* / loanApprovalStatus.get(loanApp.Id).get('Highest') && !loanApprovalStatus.get(loanApp.Id).get('Middle')){ //highest approver has found
                    // if(callType=='Branch' || mapLevelVsLoanApp.get('Middle').contains(loanApp)){
                        middleKey = mapOfPreviousKey.get(loanAppIdVsKey.get(loanApp.Id));
                        System.debug(' === Remaining Middle Approvals ==> ' + JSON.serializePretty(listOfAccountTeamMemberMiddle) );
                        middleKey = getMiddleLevelApprover( loanApp, loanToBaseApproval.get(loanApp.Id), middleKey, approveLevelToTeamMembersHierarchy, mapOfLevelVsLoanId, listOfAccountTeamMemberMiddle );
                        System.debug(' === Remaining Middle Approvals After==> ' + JSON.serializePretty(listOfAccountTeamMemberMiddle) );
            
                        // if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).containsKey(middleKey)){
                        //     listOfAccountTeamMemberMiddle.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey));
                        // }else{
                        //     middleKey = getNextKey(middleKey,accountId,mapOfApproverLevelVsMapOfDeviationLevel,mapOfPreviousKey,'Middle',loanApp.BRE_Approval_Level__c);
                        //     system.debug('appKey after do while '+middleKey);
                        //     if(middleKey!='NoData'){
                        //         if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey).size()>0){
                        //             listOfAccountTeamMemberMiddle.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey));
                        //         }
                        //     }else{
                        //         //mapOfLoanIdVsLevel.put(loanApp.Id,'Middle');
                        //         mapOfLevelVsLoanId.get('Middle').add(loanApp);
                        //     }
                            
                            
                        // }
                        system.debug('listOfAccountTeamMemberMiddle L1S2 '+listOfAccountTeamMemberMiddle);
                    } else if( callType == 'National' && !loanApprovalStatus.get(loanApp.Id).get('Highest') && !loanApprovalStatus.get(loanApp.Id).get('Middle')){
                        middleKey = mapOfPreviousKey.get(loanAppIdVsKey.get(loanApp.Id));
                        middleKey = getMiddleLevelApprover( loanApp, loanToBaseApproval.get(loanApp.Id), middleKey, approveLevelToTeamMembersHierarchy, mapOfLevelVsLoanId, listOfAccountTeamMemberMiddle );
                    }
                }
            }
            System.debug('== Base ==' + JSON.serializePretty(listOfAccountTeamMemberBase) + '== High ==' +  JSON.serializePretty( listOfAccountTeamMemberHigh) + '==Middle ==' + JSON.serializePretty(listOfAccountTeamMemberMiddle));
            AssignmentWrapper wrap = insertListOfApprovers(listOfAccountTeamMemberBase, listOfAccountTeamMemberHigh,listOfAccountTeamMemberMiddle,loanApp.Id, baseKey, appKey, middleKey, loanApp);            
            if(wrap.listOfApprovers.size()>0){listOfApprovers.addAll(wrap.listOfApprovers);}
            if(wrap.levelVsLoanApp.containsKey('Middle')){mapOfLevelVsLoanId.get('Middle').add(loanApp);}
            if(wrap.levelVsLoanApp.containsKey('Base')){mapOfLevelVsLoanId.get('Base').add(loanApp);}
            if(wrap.levelVsLoanApp.containsKey('Highest')){mapOfLevelVsLoanId.get('Highest').add(loanApp);}
        }
        system.debug('listOfApprovers '+listOfApprovers);
        if(listOfApprovers.size()>0){
            // insert new List<Loan_Application_Approval__c>(new Set<Loan_Application_Approval__c>(listOfApprovers));
            finalApprovers.addAll(new Set<Loan_Application_Approval__c>(listOfApprovers)); //Sachin - Aggregated DML calls to avoid additional logic to assign application
        }
        return mapOfLevelVsLoanId;
        
    }
    
    
    public static AssignmentWrapper insertListOfApprovers(List<AccountTeamMember> baseList,List<AccountTeamMember> highList,List<AccountTeamMember> middleList, String loanId, String baseKey, String appKey, String middleKey, Loan_Application__c loanApp){
        Id recordTypeIdFour = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
        List<Loan_Application_Approval__c> listOfApprovers = new List<Loan_Application_Approval__c>();
        List<AccountTeamMember> allAccountTeams = new List<AccountTeamMember>();
        allAccountTeams.addAll(baseList);
        if(breTrigger==false){
            allAccountTeams.addAll(highList);
            allAccountTeams.addAll(middleList);
        }
        
        List<String> baseIds = new List<String>();
        List<String> highIds = new List<String>();
        List<String> middleIds = new List<String>();
        Map<String,Loan_Application__c> mapOfLevelVsLoanApp = new Map<String,Loan_Application__c>();
        for(AccountTeamMember ac:allAccountTeams){
            
            String customerGrade = ac.Customer_Grade__c;
            List<String> customerGradeList = customerGrade.split(';');
            
            String typeOfEmployment = ac.Type_Of_Employment__c;
            List<String> typeOfEmploymentList = typeOfEmployment.split(';');
            
            String collateral = ac.Collateral__c;
            List<String> collateralList = collateral.split(';');
            
            String product = ac.Product__c;
            List<String> productList = product.split(';');
            
            if(productList.contains(mapOfLoanIdVsProduct.get(loanId)) && customerGradeList.contains(mapOfLoanIdVsCustGrade.get(loanId)) && typeOfEmploymentList.contains(mapOfLoanIdVsTypeOfEmpl.get(loanId)) && collateralList.contains(mapOfLoanIdVsCollateralName.get(loanId))){
                Loan_Application_Approval__c lc = new Loan_Application_Approval__c();
                lc.Loan_Application__c = loanId;
                if(breTrigger==true){
                    if(!isSTPwithConditions){
                        lc.BSR_PSL__c = true;
                    }
                }
                // - Sachin: If we already have a record on Highest for an Approver don't create middle or base with same approver
                if(highIds.contains(ac.Id) || middleIds.contains(ac.Id) || baseIds.contains(ac.Id)) continue;

                // - Sachin: Reordered conditions so the first priority is (Highest > Middle > Base)

                if(highList.contains(ac) && !highIds.contains(ac.Id)){
                    lc.Type__c = 'Highest'; 
                    if(loanApp.RecordTypeId == recordTypeIdFour && approvalType==GlobalConstants.APPROVAL_TYPE_CREDIT){
                        lc.Approver_Level__c = appKey.subString(0,2);
                        lc.Deviation_Level__c = appKey.subString(2,4);
                    }else{
                        lc.Approver_Level__c = appKey;
                    }
                    highIds.add(ac.Id);
                }else if(middleList.contains(ac) && !middleIds.contains(ac.Id)){
                    lc.Type__c = 'Middle'; //loanApp.RecordType.DeveloperName == 'Four_Wheeler'
                    if(loanApp.RecordTypeId == recordTypeIdFour && approvalType==GlobalConstants.APPROVAL_TYPE_CREDIT){
                        lc.Approver_Level__c = middleKey.subString(0,2);
                        lc.Deviation_Level__c = middleKey.subString(2,4);
                    }else{
                        lc.Approver_Level__c = middleKey;
                    }
                    middleIds.add(ac.Id);
                } else if(baseList.contains(ac) && !baseIds.contains(ac.Id)){
                    lc.Type__c = 'Base'; 
                    if(loanApp.RecordTypeId == recordTypeIdFour && approvalType==GlobalConstants.APPROVAL_TYPE_CREDIT){
                        lc.Approver_Level__c = baseKey.subString(0,2);
                        lc.Deviation_Level__c = baseKey.subString(2,4);
                    }else{
                        lc.Approver_Level__c = baseKey;
                    }
                    baseIds.add(ac.Id);
                }
                
                lc.Approver__c = ac.UserId ;
                //lc.OwnerId = ac.UserId;
                lc.Approval_Type__c = approvalType ;
                
                //if(approvalType == GlobalConstants.APPROVAL_TYPE_PRICING){l
                    lc.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
                //}
                listOfApprovers.add(lc);
            }else{
                if(highList.contains(ac)){
                    mapOfLevelVsLoanApp.put('Highest',loanApp);
                }
                
                if(baseList.contains(ac)){
                    mapOfLevelVsLoanApp.put('Base',loanApp);
                }
                if(middleList.contains(ac)){
                    mapOfLevelVsLoanApp.put('Middle',loanApp);
                }
                
            }
        }
        AssignmentWrapper wrap = new AssignmentWrapper();
        wrap.listOfApprovers = listOfApprovers;
        wrap.levelVsLoanApp=mapOfLevelVsLoanApp;
        system.debug('listOfApprovers Base '+listOfApprovers);
        return wrap;
    }
    
    public class AssignmentWrapper{
        public List<Loan_Application_Approval__c> listOfApprovers;
        public Map<String,Loan_Application__c> levelVsLoanApp;
    }
    
    
    public static String getNextKey(String appKey,String branchId,Map<String,Map<String,List<AccountTeamMember>>> mapOfApproverLevelVsMapOfDeviationLevel,Map<String,String> mapOfKeys, String strApprovalLevel, String strBRELevelRequired){
        system.debug('appKey '+branchId);
        system.debug('appKey '+appKey);
        system.debug('appKey '+mapOfApproverLevelVsMapOfDeviationLevel);
        system.debug('appKey '+mapOfKeys);
        do{
            // if(appKey.contains('S') && strBRELevelRequired.contains('S')){
            //     Integer intSLevel = Integer.valueOf(appKey.subString(appKey.indexOf('S')+1,appKey.length()));
            //     Integer intbreLevel = Integer.valueOf(strBRELevelRequired.subString(strBRELevelRequired.indexOf('S')+1,strBRELevelRequired.length()));
            // }

            if(mapOfKeys.containsKey(appKey)){
                appKey = checkNextLevel(appKey ,mapOfKeys, strApprovalLevel, strBRELevelRequired);
            }else{
                appKey ='NoData';
                return appKey;
            }
            system.debug('appKey '+appKey);
            system.debug('key is '+(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(branchId) ? mapOfApproverLevelVsMapOfDeviationLevel.get(branchId).containsKey(appKey) : false));
        }
        while(!mapOfApproverLevelVsMapOfDeviationLevel.get(branchId).containsKey(appKey));
        System.debug(' == Exit === Approval TYpe' + strApprovalLevel + ' === Required Level ==> ' + strBRELevelRequired + ' = AppKey ==> ' + appKey);
        return appKey;
    }
    
    public static String checkNextLevel(String appKey ,Map<String,String> mapOfKeys, String strApprovalLevel, String strBRELevelRequired){
        if(mapOfKeys.containsKey(appKey)){
            appKey = mapOfKeys.get(appKey);
            if(appKey.contains('S')  && String.isNotBlank(strBRELevelRequired) && strBRELevelRequired.contains('S')){// 5747 New Empty STring check added
                Integer intSLevel = Integer.valueOf(appKey.subString(appKey.indexOf('S')+1,appKey.length()));
                Integer intbreLevel = Integer.valueOf(strBRELevelRequired.subString(strBRELevelRequired.indexOf('S')+1,strBRELevelRequired.length())),
                    approverLevel = Integer.valueOf(appKey.subString(1, 2)),
                    requiredApproverLevel = Integer.valueOf(strBRELevelRequired.subString(1, 2));
                if(strApprovalLevel == 'Highest' && intbreLevel <= intSLevel){
                    return appKey;
                }
                else if(strApprovalLevel == 'Middle' && intbreLevel >= intSLevel){
                    return appKey;
                }
                else if(strApprovalLevel == 'Base' && intbreLevel > intSLevel && (approverLevel <= requiredApproverLevel)){
                    return appKey;
                }
                else{
                    //appKey = mapOfKeys.get(appKey);
                    return checkNextLevel(appKey,mapOfKeys,strApprovalLevel,strBRELevelRequired);
                }
            }
            else{
                return appKey;
                //return null;
            }
        }
        else{
            appKey ='NoData';
            return 'NoData';
        }
    }
    

    static map<String, String> branchHierarchy = new map<String, String>{
        'Branch' => 'Hub',
        'Hub' => 'State',
        'State' => 'Region',
        'Region' => 'Zone',
        'Zone' => 'National',
        'National' => ''
    };
    Commented as part of STP ISSUE - SFAU-5664 - STP Case Credit */

    /* Commented by Mohit - as not in use - Dec-15
    static map<String, String> branchHierarchyFromTop = new map<String, String>{
        'National' => 'Zone',
        'Zone' => 'Region',
        'Region' => 'State',
        'State' => 'Hub',
        'Hub' => 'Branch',
        'Branch' => ''
    };
    */

    /* Commented by Mohit - as not in use - Dec-15
    * 26th Aug '23
    * First Traversal: 
    ** Starts from  L(i)S(j-1) from the same level where we found Highest / nth approver
    ** look for same L(i)S(j-1) at ( currentlevel - 1 ) & till branch
    *** If found in the traversal keep a track of at what level it was if we found same level at lower branch type override the previous entry
    *** Else go back to Current level of nth approver repeat with L(i)S(j-2)
    * Second traversal::
    ** Do L(i)S(j-2) from the same level where we found Highest / nth approver, looks for same L(i)S(j-2) at ( currentlevel -1 ) till branch
    * /
    public static String getClosestMiddleLevelApprover( String currentLevel, Loan_Application__c loanApp, String baseKey, String middleKey, map<String, map<String, AccountTeamMember[]>> mapOfApproverLevelVsMapOfDeviationLevel, map<String, Loan_Application__c[]> mapOfLevelVsLoanId, AccountTeamMember[] listOfAccountTeamMemberMiddle ){
        String traversalType = currentLevel;
        AccountTeamMember[] penultimateApprovers;
        System.debug(' === mapOfApproverLevelVsMapOfDeviationLevel ==> ' + JSON.serializePretty(mapOfApproverLevelVsMapOfDeviationLevel));


        // currentLevel -> Region || Highest - L6S6
        // middleKey => L6S5
        
        middleKey = mapOfPreviousKey.get( middleKey ); //L(i)S(j-1); - L6S5
        do{
            Id accountId = getAccountId( traversalType, loanApp ); // Region

            /**
             * 1. we found matching key at same level but it isnt the last level so we have to keep searching ... - if we've reached the branch level and still didnt found matching key
             * 2. We found at same level and it is the last level where this key exist - break; - it will be n-1 approver
             * /
            Boolean hasKey = mapOfApproverLevelVsMapOfDeviationLevel.containsKey( accountId ) && mapOfApproverLevelVsMapOfDeviationLevel.get( accountId ).containsKey( middleKey );
            
            
            traversalType = branchHierarchyFromTop.get( traversalType );
            if( hasKey && String.isBlank( traversalType ) ){
                listOfAccountTeamMemberMiddle.addAll( penultimateApprovers );
                loanApprovalStatus.get( loanApp.Id ).put( 'Middle', true );
                break;
            } else if( hasKey && penultimateApprovers != null ){
                penultimateApprovers = mapOfApproverLevelVsMapOfDeviationLevel.get( accountId ).get( middleKey );
            } else if( String.isBlank( traversalType ) ){
                middleKey = mapOfPreviousKey.get( middleKey ); //L(i)S(j-1);
                traversalType = currentLevel;
                penultimateApprovers = null;
            }

        } while( middleKey != 'NoData' && !loanApprovalStatus.get(loanApp.Id).get('Middle') );

        return middleKey;
    }


    public static String getMiddleLevelApprover( Loan_Application__c loanApp, String baseKey, String middleKey, map<String, map<String, AccountTeamMember[]>> mapOfApproverLevelVsMapOfDeviationLevel, map<String, Loan_Application__c[]> mapOfLevelVsLoanId, AccountTeamMember[] listOfAccountTeamMemberMiddle ){
        String currentLevel = 'Branch';
        System.debug(' === mapOfApproverLevelVsMapOfDeviationLevel ==> ' + JSON.serializePretty(mapOfApproverLevelVsMapOfDeviationLevel));
        do{
            System.debug('= === Current Level => ' + currentLevel);
            Id accountId = getAccountId( currentLevel, loanApp ); // L6S5
            System.debug(' === middleKey ==> ' + middleKey);
            System.debug(' ==== Members on Account == ' + JSON.serializePretty(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId)));
            if( middleKey != baseKey && mapOfApproverLevelVsMapOfDeviationLevel.containsKey(accountId) && mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).containsKey(middleKey)){
                System.debug(' ==== Found match === ' + JSON.serializePretty(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey)));
                listOfAccountTeamMemberMiddle.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey));
                loanApprovalStatus.get(loanApp.Id).put('Middle', true);
            } else if(mapOfApproverLevelVsMapOfDeviationLevel.containsKey(accountId)){
                middleKey = getNextKey(middleKey, accountId, mapOfApproverLevelVsMapOfDeviationLevel, mapOfPreviousKey, 'Middle', loanApp.BRE_Approval_Level__c);
                System.debug(' == Evaluated middle key ==> ' + middleKey + ' === Matching users on branch ==> ' + JSON.serializePretty(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey)));
                system.debug('appKey after do while '+middleKey);
                if( middleKey != 'NoData' && middleKey != baseKey ){
                    if(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey).size()>0){
                        listOfAccountTeamMemberMiddle.addAll(mapOfApproverLevelVsMapOfDeviationLevel.get(accountId).get(middleKey));
                        loanApprovalStatus.get(loanApp.Id).put('Middle', true);
                    }
                } else {
                    //mapOfLoanIdVsLevel.put(loanApp.Id,'Middle');
                    mapOfLevelVsLoanId.get('Middle').add(loanApp);
                }
            }
            currentLevel = branchHierarchy.get(currentLevel);
        } while( branchHierarchy.containsKey(currentLevel) && !loanApprovalStatus.get(loanApp.Id).get('Middle'));
        return middleKey;
    }
    */
    
    public static void mainMethod(String approvalType, List<AccountTeamMember> lisOfAccountTeamMembers, Loan_Application__c objLoanApp, String requiredApprovalLevel ){
        Map<Integer,List<AccountTeamMember>> mapIntegervsListACT = new Map<Integer,List<AccountTeamMember>>();
        Map<Integer,String> mapIntegervsStringLevel = new Map<Integer,String>();

        Boolean isCreditAssignment = approvalType != GlobalConstants.APPROVAL_TYPE_PRICING;
        map<Id, Integer> assigneeCountMap = AUSFApproverController.getTeamMemberBasedOnRoundRobin( lisOfAccountTeamMembers );

        for(AccountTeamMember accTeam : lisOfAccountTeamMembers){
            if( !isCreditAssignment ){
                if (accTeam.TeamMemberRole == 'Credit') continue;
                String[] lstAppLevel = accTeam.Approver_Level__c != null ? accTeam.Approver_Level__c.split(';') : new String[0];

                for(String strAppLevel : lstAppLevel){
                    Integer intAppLevel = CreditApprovalAssignmentHandler.getPricingAuthLevel(strAppLevel);
                    mapIntegervsStringLevel.put(intAppLevel, String.valueOf(CreditApprovalAssignmentHandler.getPricingAuthLevel(strAppLevel)));
                    if(!mapIntegervsListACT.containsKey(intAppLevel)){
                        mapIntegervsListACT.put(intAppLevel, new AccountTeamMember[0]);
                    }
                    mapIntegervsListACT.get(intAppLevel).add( accTeam );
                }
                continue;
            }

            // Credit Assignments for 2W / 4W
            if(objLoanApp.RecordType.Name == 'Two Wheeler'){
                List<String> lstAppLevel = new List<String>();
                if(accTeam.Approver_Level__c.contains(';')){
                    lstAppLevel = accTeam.Approver_Level__c.split(';');
                }
                else{
                    if (accTeam.TeamMemberRole != 'Credit') continue;
                    lstAppLevel.add(accTeam.Approver_Level__c);
                }
                for(String strAppLevel : lstAppLevel){
                    Integer intAppLevel = CreditApprovalAssignmentHandler.getCreditAuthLevel(strAppLevel);
                    if(mapIntegervsListACT.containsKey(intAppLevel)){
                        List<AccountTeamMember> lstAccTM = mapIntegervsListACT.get(intAppLevel);
                        lstAccTM.add(accTeam);
                        mapIntegervsListACT.put(intAppLevel, lstAccTM);
                    }
                    else{
                        mapIntegervsListACT.put(intAppLevel, new List<AccountTeamMember>{accTeam});
                    }
                }
            }
            if(objLoanApp.RecordType.Name == 'Four Wheeler'){
                List<String> lstAppLevel = new List<String>();
                List<String> lstDevLevel = new List<String>();
                if(accTeam.Approver_Level__c != null){
                    if(accTeam.Approver_Level__c.contains(';')){
                        lstAppLevel = accTeam.Approver_Level__c.split(';');
                    }
                    else{
                        lstAppLevel.add(accTeam.Approver_Level__c);
                    }
                }
                if(accTeam.Deviation_Level__c != null){
                    if(accTeam.Deviation_Level__c.contains(';')){
                        lstDevLevel = accTeam.Deviation_Level__c.split(';');
                    }
                    else{
                        lstDevLevel.add(accTeam.Deviation_Level__c);
                    }
                }
                for(String strAppLevel : lstAppLevel){
                    for(String strDevLevel : lstDevLevel){
                        Integer intAppLevel = Integer.valueOf(String.valueOf(CreditApprovalAssignmentHandler.getCreditAuthLevel(strAppLevel)) + '' + String.valueOf(CreditApprovalAssignmentHandler.getCreditDeviationLevel(strDevLevel)));
                        mapIntegervsStringLevel.put(intAppLevel, String.valueOf(CreditApprovalAssignmentHandler.getCreditAuthLevel(strAppLevel)) + ':' + String.valueOf(CreditApprovalAssignmentHandler.getCreditDeviationLevel(strDevLevel)));
                        if(mapIntegervsListACT.containsKey(intAppLevel)){
                            List<AccountTeamMember> lstAccTM = mapIntegervsListACT.get(intAppLevel);
                            lstAccTM.add(accTeam);
                            mapIntegervsListACT.put(intAppLevel, lstAccTM);
                        }
                        else{
                            mapIntegervsListACT.put(intAppLevel, new List<AccountTeamMember>{accTeam});
                        }
                    }
                }
                
            }
        }
        
        system.debug('mapIntegervsListACT '+ mapIntegervsListACT);
        system.debug('mapIntegervsStringLevel '+ mapIntegervsStringLevel);
        List<Integer> lstKeytoSort = new List<Integer>();
        lstKeytoSort.addAll(mapIntegervsListACT.keySet());
        lstKeytoSort.sort();
        system.debug('lstKeytoSort '+ lstKeytoSort);

        // No Credit / Pricing manager available in branch hierarchy
        if( lstKeytoSort.isEmpty() ) return;
        Set<Loan_Application_Approval__c> approvals = new Set<Loan_Application_Approval__c>();
        // :TODO skip base approval for Pricing assignments
        // SFAU-5043
        String strBREAppLevel;
        Integer baseApprovalLevel;
        Integer breAppLevel = isCreditAssignment ? CreditApprovalAssignmentHandler.getCreditAuthLevel( requiredApprovalLevel.split('S')[0] ) : CreditApprovalAssignmentHandler.getPricingAuthLevel( requiredApprovalLevel ),
        breDevLevel = isCreditAssignment && objLoanApp.RecordType.Name != 'Two Wheeler' ? CreditApprovalAssignmentHandler.getCreditDeviationLevel( requiredApprovalLevel.split('S')[1] ) : null;
        Integer requiredBRELevel = Integer.valueOf( breAppLevel + '' + (breDevLevel != null ? String.valueOf( breDevLevel ) : '') );
    
        if( isCreditAssignment && objLoanApp.RecordType.Name != 'Two Wheeler' ){
            //baseApprovalLevel = lstKeytoSort.remove(0);
            baseApprovalLevel = lstKeytoSort[0];
            if(baseApprovalLevel < requiredBRELevel){
                baseApprovalLevel = lstKeytoSort.size() == 1 ? lstKeytoSort[0] : lstKeytoSort.remove(0); 
                AccountTeamMember baseApprover = AUSFApproverController.getMemberWithLeastWork(
                    mapIntegervsListACT.get( baseApprovalLevel ),
                    assigneeCountMap
                );
                approvals.addAll( getApprovals( new AccountTeamMember[]{ baseApprover }, objLoanApp, 'Base', approvalType ) );
            }
            else{
                List<String> lstString = requiredApprovalLevel.split('S');
                strBREAppLevel = isCreditAssignment ? String.valueOf(CreditApprovalAssignmentHandler.getCreditAuthLevel(lstString[0])) + ':' + lstString[1] : String.valueOf( CreditApprovalAssignmentHandler.getPricingAuthLevel( lstString[0] ) );
                Map<String, List<AccountTeamMember>> mapMiddleHighest = CreditApprovalAssignmentHandler.getMiddleHighestWithAppDevLevel4W(isCreditAssignment, lstKeytoSort, mapIntegervsListACT,mapIntegervsStringLevel,strBREAppLevel);
                if( mapMiddleHighest.containsKey( 'Highest' ) ){
                    approvals.addAll( getApprovals( mapMiddleHighest.get( 'Highest' ), objLoanApp, 'Highest', approvalType ) );
                }
                if( mapMiddleHighest.containsKey( 'Middle' ) ){
                    approvals.addAll( getApprovals( mapMiddleHighest.get( 'Middle' ), objLoanApp, 'Middle', approvalType ) );
                }
                // SFAU-5338
                if (intMiddleLevel != NULL && baseApprovalLevel != NULL && baseApprovalLevel < intMiddleLevel) {
                    baseApprovalLevel = lstKeytoSort.remove(0);
                    AccountTeamMember baseApprover = AUSFApproverController.getMemberWithLeastWork(
                        mapIntegervsListACT.get( baseApprovalLevel ),
                        assigneeCountMap
                    );
                    approvals.addAll( getApprovals( new AccountTeamMember[]{ baseApprover }, objLoanApp, 'Base', approvalType ) );
                }
            }
        }

        system.debug('lstKeytoSort '+ lstKeytoSort);
        //String strBREAppLevel;
        //Integer breAppLevel = isCreditAssignment ? CreditApprovalAssignmentHandler.getCreditAuthLevel( requiredApprovalLevel.split('S')[0] ) : CreditApprovalAssignmentHandler.getPricingAuthLevel( requiredApprovalLevel ),
        //    breDevLevel = isCreditAssignment && objLoanApp.RecordType.Name != 'Two Wheeler' ? CreditApprovalAssignmentHandler. requiredApprovalLevel.split('S')[1] ) : null;
        //Integer requiredBRELevel = Integer.valueOf( breAppLevel + '' + (breDevLevel != null ? String.valueOf( breDevLevel ) : '') );
        if(objLoanApp.RecordType.Name == 'Two Wheeler'){
            System.debug(' == Two Wheeler Assignments === ' + JSON.serializePretty(mapIntegervsListACT) + '\n Keys ==' + JSON.serializePretty(lstKeytoSort));
            strBREAppLevel = isCreditAssignment ? String.valueOf(CreditApprovalAssignmentHandler.getCreditAuthLevel(requiredApprovalLevel)) : String.valueOf( CreditApprovalAssignmentHandler.getPricingAuthLevel(requiredApprovalLevel) );
            Map<Integer, List<AccountTeamMember>> mapMiddleHighest = CreditApprovalAssignmentHandler.getMiddleHighestWithAppLevel(lstKeytoSort, mapIntegervsListACT,strBREAppLevel);
            system.debug('mapMiddleHighest '+JSON.serializePretty(mapMiddleHighest));
            //:TODO - sort and pick the highest level found
            Integer[] approvalLevels = new List<Integer>( mapMiddleHighest.keySet() );
            approvalLevels.sort();
            AccountTeamMember[] lstHighestATM = mapMiddleHighest.get(approvalLevels[ approvalLevels.size() - 1 ]); // Highest Approver 
            System.debug(' == lstHighestATM == ' + JSON.serializePretty(lstHighestATM));
            if(lstHighestATM != null && !lstHighestATM.isEmpty()){
                approvals.addAll( getApprovals( lstHighestATM, objLoanApp, 'Highest', approvalType ) );
            }

        }
        if(objLoanApp.RecordType.Name == 'Four Wheeler' && (baseApprovalLevel < requiredBRELevel || !isCreditAssignment)){
            List<String> lstString = requiredApprovalLevel.split('S');
            strBREAppLevel = isCreditAssignment ? String.valueOf(CreditApprovalAssignmentHandler.getCreditAuthLevel(lstString[0])) + ':' + lstString[1] : String.valueOf( CreditApprovalAssignmentHandler.getPricingAuthLevel( lstString[0] ) );
            Map<String, List<AccountTeamMember>> mapMiddleHighest = CreditApprovalAssignmentHandler.getMiddleHighestWithAppDevLevel4W(isCreditAssignment, lstKeytoSort, mapIntegervsListACT,mapIntegervsStringLevel,strBREAppLevel);
            system.debug('mapMiddleHighest '+JSON.serializePretty(mapMiddleHighest));
            if( mapMiddleHighest.containsKey( 'Highest' ) ){
                approvals.addAll( getApprovals( mapMiddleHighest.get( 'Highest' ), objLoanApp, 'Highest', approvalType ) );
            }
            if( mapMiddleHighest.containsKey( 'Middle' ) ){
                approvals.addAll( getApprovals( mapMiddleHighest.get( 'Middle' ), objLoanApp, 'Middle', approvalType ) );
            }

        }
        // :TODO insert final approvals
        System.debug(' Approvals ==> ' + JSON.serializePretty(approvals));

        // SFAU-5797 CHanges Duplicate CHange add
        Map<String, Loan_Application_Approval__c> existingApprovalsMap = new Map<String, Loan_Application_Approval__c>();
        Map<String, Loan_Application_Approval__c> newApprovalsMap = new Map<String, Loan_Application_Approval__c>();
        //Check added for data skew error
        for(Loan_Application_Approval__c approvalRecord : [SELECT Id, Approver__c, Approval_Type__c, Archived__c, Loan_Application__c FROM Loan_Application_Approval__c WHERE Approval_Type__c =:approvalType AND Archived__c = false and Loan_Application__c=:objLoanApp.Id]){
            existingApprovalsMap.put(approvalRecord.Approver__c, approvalRecord);
        }
        for(Loan_Application_Approval__c newApprovalRecord : new List<Loan_Application_Approval__c>( approvals )){
            if(isCalledFromFI){
                if(!existingApprovalsMap.containsKey(newApprovalRecord.Approver__c) || existingApprovalsMap.isEMpty()){
                    newApprovalsMap.put(newApprovalRecord.Approver__c, newApprovalRecord);
                }
            }
            else{
                newApprovalsMap.put(newApprovalRecord.Approver__c, newApprovalRecord);
            }
            
        }
        insert newApprovalsMap.values();
        /**********SFAU-5797 End */
        //insert new List<Loan_Application_Approval__c>( approvals );

    }

    public static Loan_Application_Approval__c[] getApprovals( AccountTeamMember[] atms, Loan_Application__c loanApp, String approvalLevel, String approvalType ){
        Loan_Application_Approval__c[] approvals = new Loan_Application_Approval__c[0];
        for( AccountTeamMember atm: atms ){
            String[] levels = atm.Approver_Level__c.split(';');
            List<String> lstDeviationLevel = new List<String>();
            lstDeviationLevel = String.isNotBlank(atm.Deviation_Level__c) ? atm.Deviation_Level__c.split(';') : new List<String>();
            approvals.add(
                new Loan_Application_Approval__c(
                    Approver__c = atm.UserId,
                    Loan_Application__c = loanApp.Id,
                    Approver_Level__c = levels[levels.size() -1 ],
                    Deviation_Level__c = (!lstDeviationLevel.isEmpty() ? lstDeviationLevel[lstDeviationLevel.size()-1] : ''), // atm.Deviation_Level__c, // SFAU-5414- Split Deviation Level to create Approval records
                    Type__c = approvalLevel,
                    Approval_Type__c = approvalType,
                    Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                    BSR_PSL__c = breTrigger && !isSTPwithConditions
                )
            );
        }
        return approvals;
    }

    public static String getAccountId(String callType,Loan_Application__c loanApp){
        String accId;
        if(callType =='Branch' && loanApp.Branch_Master__c!=null){
            accId = loanApp.Branch_Master__c;
        }else if(callType =='Hub' && loanApp.Branch_Master__r?.Business_HUB__c!=null){
            accId = loanApp.Branch_Master__r.Business_HUB__c;
        }else if(callType =='State' & loanApp.Branch_Master__r?.State__c!=null){
            accId = loanApp.Branch_Master__r.State__c;
        }else if(callType =='Region' & loanApp.Branch_Master__r?.Region__c!=null){
            accId = loanApp.Branch_Master__r.Region__c;
        }else if(callType =='Zone' & loanApp.Branch_Master__r?.Zone__c!=null){
            accId = loanApp.Branch_Master__r.Zone__c;
        }else if(callType =='National' & loanApp.Branch_Master__r?.National__c!=null){
            accId = loanApp.Branch_Master__r.National__c;
        }
        return accId;
    }
    
}