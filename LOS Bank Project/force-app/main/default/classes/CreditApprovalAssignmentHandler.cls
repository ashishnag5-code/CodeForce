/*****
 * Class Name: CreditApprovalAssignmentHandler
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-18-2023          -   Mohit M.            -   change sharing control due to FI Agent getting error
 * Sep-29               -   Mayur               -   SFAU-5043
 * Oct-4                -   Mohit M.            -   SFAU-5338
 * Oct-16               -   Mohit M.            -   SFAU-5414- Split Deviation Level to create Approval records
 * Nov-16               -   Sachin              -   R2-2010 - Credit Assignments for Tractor and Commercials
*/
public without sharing class CreditApprovalAssignmentHandler {
    public static Boolean breTrigger = false;
    public static Boolean isSTPwithConditions = false;
    //SFAU-5338
    public static Integer intMiddleLevel = null;

    static String[] queueBasedLoanTypes = new String[]{ GlobalConstants.TWOWHEELER };
    static String[] hierarchyBasedLoanTypes = new String[]{ GlobalConstants.FOURWHEELER, GlobalConstants.TRACTOR, GlobalConstants.COMMERCIALVEHICLE, GlobalConstants.CONSTRUCTIONEQUIP };

    public static void mainMethod(String approvalType, List<AccountTeamMember> lisOfAccountTeamMembers, Loan_Application__c objLoanApp, String requiredApprovalLevel ){
        Map<Integer,List<AccountTeamMember>> mapIntegervsListACT = new Map<Integer,List<AccountTeamMember>>();
        Map<Integer,String> mapIntegervsStringLevel = new Map<Integer,String>();

        Boolean isCreditAssignment = approvalType != GlobalConstants.APPROVAL_TYPE_PRICING;
        map<Id, Integer> assigneeCountMap = AUSFApproverController.getTeamMemberBasedOnRoundRobin( lisOfAccountTeamMembers );

        for(AccountTeamMember accTeam : lisOfAccountTeamMembers){
            if( !isCreditAssignment ){
                String[] lstAppLevel = accTeam.Approver_Level__c != null ? accTeam.Approver_Level__c.split(';') : new String[0];

                for(String strAppLevel : lstAppLevel){
                    Integer intAppLevel = getPricingAuthLevel(strAppLevel);
                    mapIntegervsStringLevel.put(intAppLevel, String.valueOf(getPricingAuthLevel(strAppLevel)));
                    if(!mapIntegervsListACT.containsKey(intAppLevel)){
                        mapIntegervsListACT.put(intAppLevel, new AccountTeamMember[0]);
                    }
                    mapIntegervsListACT.get(intAppLevel).add( accTeam );
                }
                continue;
            }

            // Credit Assignments for 2W / 4W
            if( queueBasedLoanTypes.contains( objLoanApp.RecordType.Name ) ){
                List<String> lstAppLevel = new List<String>();
                if(accTeam.Approver_Level__c.contains(';')){
                    lstAppLevel = accTeam.Approver_Level__c.split(';');
                }
                else{
                    lstAppLevel.add(accTeam.Approver_Level__c);
                }
                for(String strAppLevel : lstAppLevel){
                    Integer intAppLevel = getCreditAuthLevel(strAppLevel);
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
            if( hierarchyBasedLoanTypes.contains( objLoanApp.RecordType.Name ) ){
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
                        Integer intAppLevel = Integer.valueOf(String.valueOf(getCreditAuthLevel(strAppLevel)) + '' + String.valueOf(getCreditDeviationLevel(strDevLevel)));
                        mapIntegervsStringLevel.put(intAppLevel, String.valueOf(getCreditAuthLevel(strAppLevel)) + ':' + String.valueOf(getCreditDeviationLevel(strDevLevel)));
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
        Integer breAppLevel = isCreditAssignment ? getCreditAuthLevel( requiredApprovalLevel.split('S')[0] ) : getPricingAuthLevel( requiredApprovalLevel ),
            breDevLevel = isCreditAssignment && !queueBasedLoanTypes.contains( objLoanApp.RecordType.Name ) ? getCreditDeviationLevel( requiredApprovalLevel.split('S')[1] ) : null;
        Integer requiredBRELevel = Integer.valueOf( breAppLevel + '' + (breDevLevel != null ? String.valueOf( breDevLevel ) : '') );

        if( isCreditAssignment && !queueBasedLoanTypes.contains(objLoanApp.RecordType.Name) ){
            //baseApprovalLevel = lstKeytoSort.remove(0);
            baseApprovalLevel = lstKeytoSort[0];
            if(baseApprovalLevel < requiredBRELevel){
                baseApprovalLevel = lstKeytoSort.remove(0);
                AccountTeamMember baseApprover = AUSFApproverController.getMemberWithLeastWork(
                    mapIntegervsListACT.get( baseApprovalLevel ),
                    assigneeCountMap
                );
                approvals.addAll( getApprovals( new AccountTeamMember[]{ baseApprover }, objLoanApp, 'Base', approvalType ) );
            }
            else{
                List<String> lstString = requiredApprovalLevel.split('S');
                strBREAppLevel = isCreditAssignment ? String.valueOf(getCreditAuthLevel(lstString[0])) + ':' + lstString[1] : String.valueOf( getPricingAuthLevel( lstString[0] ) );
                Map<String, List<AccountTeamMember>> mapMiddleHighest = getMiddleHighestWithAppDevLevel4W(isCreditAssignment, lstKeytoSort, mapIntegervsListACT,mapIntegervsStringLevel,strBREAppLevel);
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
        //Integer breAppLevel = isCreditAssignment ? getCreditAuthLevel( requiredApprovalLevel.split('S')[0] ) : getPricingAuthLevel( requiredApprovalLevel ),
        //    breDevLevel = isCreditAssignment && objLoanApp.RecordType.Name != 'Two Wheeler' ? getCreditDeviationLevel( requiredApprovalLevel.split('S')[1] ) : null;
        //Integer requiredBRELevel = Integer.valueOf( breAppLevel + '' + (breDevLevel != null ? String.valueOf( breDevLevel ) : '') );
        if( queueBasedLoanTypes.contains(objLoanApp.RecordType.Name) ){
            System.debug(' == Two Wheeler Assignments === ' + JSON.serializePretty(mapIntegervsListACT) + '\n Keys ==' + JSON.serializePretty(lstKeytoSort));
            strBREAppLevel = isCreditAssignment ? String.valueOf(getCreditAuthLevel(requiredApprovalLevel)) : String.valueOf( getPricingAuthLevel(requiredApprovalLevel) );
            Map<Integer, List<AccountTeamMember>> mapMiddleHighest = getMiddleHighestWithAppLevel(lstKeytoSort, mapIntegervsListACT,strBREAppLevel);
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
        if( hierarchyBasedLoanTypes.contains(objLoanApp.RecordType.Name) && (baseApprovalLevel < requiredBRELevel || !isCreditAssignment)){
            List<String> lstString = requiredApprovalLevel.split('S');
            strBREAppLevel = isCreditAssignment ? String.valueOf(getCreditAuthLevel(lstString[0])) + ':' + lstString[1] : String.valueOf( getPricingAuthLevel( lstString[0] ) );
            Map<String, List<AccountTeamMember>> mapMiddleHighest = getMiddleHighestWithAppDevLevel4W(isCreditAssignment, lstKeytoSort, mapIntegervsListACT,mapIntegervsStringLevel,strBREAppLevel);
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
        insert new List<Loan_Application_Approval__c>( approvals );

    }
    
    public static Map<Integer, List<AccountTeamMember>> getMiddleHighestWithAppLevel(List<Integer> lstKeytoSort, Map<Integer, List<AccountTeamMember>> mapIntegervsListACT, String strBREAppLevel){
        Map<Integer, List<AccountTeamMember>> mapIntegervsListACTtoReturn = new Map<Integer, List<AccountTeamMember>>();
        for(Integer intAppLevel : lstKeytoSort){
            if(intAppLevel >= Integer.valueOf(strBREAppLevel) && mapIntegervsListACT.containsKey(intAppLevel) && !mapIntegervsListACT.get(intAppLevel).isEmpty()){
                mapIntegervsListACTtoReturn.put(intAppLevel,mapIntegervsListACT.get(intAppLevel));
                //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                return mapIntegervsListACTtoReturn;
            } else if ( mapIntegervsListACT.containsKey(intAppLevel) && !mapIntegervsListACT.get(intAppLevel).isEmpty() ){
                mapIntegervsListACTtoReturn.put(intAppLevel,mapIntegervsListACT.get(intAppLevel));
                //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
            }
        }
        return mapIntegervsListACTtoReturn;
    }
    
    /*public static Map<Integer, List<AccountTeamMember>> getMiddleHighestWithAppDevLevel(List<Integer> lstKeytoSort, Map<Integer, List<AccountTeamMember>> mapIntegervsListACT, Map<Integer,String> mapIntegervsStringLevel, String strBREAppLevel){
        Map<Integer, List<AccountTeamMember>> mapIntegervsListACTtoReturn = new Map<Integer, List<AccountTeamMember>>();
        Integer intBreAppLevel = Integer.valueOf(strBREAppLevel.split(':')[0]);
        Integer intBreDevLevel = Integer.valueOf(strBREAppLevel.split(':')[1]);
        Boolean boolExitLoop = false;
        for(Integer intAppLeveltoGet : lstKeytoSort){
            if(!boolExitLoop){
                String strAppDevLevel = mapIntegervsStringLevel.get(intAppLeveltoGet);
                Integer intAppLevel = Integer.valueOf(strAppDevLevel.split(':')[0]);
                Integer intDevLevel = Integer.valueOf(strAppDevLevel.split(':')[1]);
                if(intAppLevel > intBreAppLevel && intDevLevel > intBreDevLevel){
                    mapIntegervsListACTtoReturn.put(intAppLeveltoGet,mapIntegervsListACT.get(intAppLevel + intDevLevel));
                    //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                    boolExitLoop = true;
                }
                else {
                    mapIntegervsListACTtoReturn.put(intAppLeveltoGet,mapIntegervsListACT.get(intAppLevel + intDevLevel));
                    //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                }
            }
        }
        
        
        return mapIntegervsListACTtoReturn;
    }*/
    
    
    public static Map<String, List<AccountTeamMember>> getMiddleHighestWithAppDevLevel4W(Boolean isCreditAssignment, List<Integer> lstKeytoSort, Map<Integer, List<AccountTeamMember>> mapIntegervsListACT, Map<Integer,String> mapIntegervsStringLevel, String strBREAppLevel){
        System.debug(' == Team members by level ==> ' + JSON.serializePretty(mapIntegervsListACT));
        Map<String, List<AccountTeamMember>> mapIntegervsListACTtoReturn = new Map<String, List<AccountTeamMember>>();
        Integer intBreAppLevel = Integer.valueOf(strBREAppLevel.split(':')[0]);
        Integer intBreDevLevel = isCreditAssignment ? Integer.valueOf(strBREAppLevel.split(':')[1]) : null;
        Boolean boolExitLoop = false;
        Integer intFoundLevel = null;
        Boolean blnFoundHigher = false;
        Boolean blnFoundMiddler = false;
        Integer intFoundSLevel = null;
        Boolean blnFoundSLevel = false;
        Integer intHighestLevel = null;
        Integer intSecondHighestLevel = null;
        Integer intSecondHighestDev = null;
        Integer intHighestDev = null;
        List<Integer> lstSordDes = new List<Integer>();
        for(Integer intAppLeveltoGet : lstKeytoSort){
            //if(!boolExitLoop){
                System.debug('intAppLeveltoGet: ' + intAppLeveltoGet + '\n mapIntegervsStringLevel: ' + JSON.serializePretty(mapIntegervsStringLevel));
                String strAppDevLevel = mapIntegervsStringLevel.get(intAppLeveltoGet);
                Integer intAppLevel = Integer.valueOf(strAppDevLevel.split(':')[0]);
                Integer intDevLevel = isCreditAssignment ? Integer.valueOf(strAppDevLevel.split(':')[1]) : null;
                if(isCreditAssignment && intAppLevel >= intBreAppLevel && intDevLevel >= intBreDevLevel && mapIntegervsListACT.containsKey(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel))) && !mapIntegervsListACT.get(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel))).isEmpty()){
                    List<AccountTeamMember> lstACT = mapIntegervsListACT.get(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel)));
                    mapIntegervsListACTtoReturn.put('Highest',lstACT);
                    //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                    blnFoundHigher = true;
                    intHighestLevel = intAppLevel;
                    intHighestDev = intDevLevel;
                    break;
                   // boolExitLoop = true;
                } else if(!isCreditAssignment && intAppLevel >= intBreAppLevel && mapIntegervsListACT.containsKey(intAppLevel) && !mapIntegervsListACT.get(intAppLevel).isEmpty()){
                    System.debug(' == is Pricing highesst ===' + intAppLevel);
                    mapIntegervsListACTtoReturn.put('Highest', mapIntegervsListACT.get(intAppLevel) );
                    blnFoundHigher = true;
                    intHighestLevel = intAppLevel;
                    break;
                } else {
                    //mapIntegervsListACTtoReturn.put(intAppLeveltoGet,mapIntegervsListACT.get(intAppLevel + intDevLevel));
                    lstSordDes.add(intAppLeveltoGet);
                    //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                }
            //}
        }
        system.debug('intHighestLevel '+intHighestLevel);
        system.debug('intHighestDev '+intHighestDev);
        system.debug('lstSordDes '+lstSordDes);
        
        if(!blnFoundHigher){
            blnFoundHigher = true;
            String strAppDevLevel = mapIntegervsStringLevel.get(lstSordDes[lstSordDes.size()-1]);
            Integer intAppLevel = Integer.valueOf(strAppDevLevel.split(':')[0]);
            Integer intDevLevel = isCreditAssignment ? Integer.valueOf(strAppDevLevel.split(':')[1]) : null;
            intHighestLevel = intAppLevel;
            intHighestDev = intDevLevel;
            mapIntegervsListACTtoReturn.put('Highest',mapIntegervsListACT.get(lstSordDes[lstSordDes.size()-1]));
            lstSordDes.remove(lstSordDes.size() -1);
        }
        
        system.debug('intHighestLevel '+intHighestLevel);
        system.debug('intHighestDev '+intHighestDev);
        system.debug('lstSordDes '+lstSordDes);
        //For Second Highest - Ex: Highest - L4S5, ATM L4S6, L4S7, L3S7
        for (Integer i=lstSordDes.size()-1; i>=0; i--) {
            /*if (!mapIntegervsStringLevel.containsKey(lstSordDes[i])) {
                continue;
            }*/
            system.debug('lstSordDes[i] '+lstSordDes[i]);
            
            String strAppDevLevel = mapIntegervsStringLevel.get(lstSordDes[i]);
            system.debug('strAppDevLevel '+strAppDevLevel);
            Integer intAppLevel = Integer.valueOf(strAppDevLevel.split(':')[0]);
            Integer intDevLevel = isCreditAssignment ? Integer.valueOf(strAppDevLevel.split(':')[1]) : null;
            system.debug('intAppLevel '+intAppLevel);
            system.debug('intDevLevel '+intDevLevel);
            if(isCreditAssignment && intAppLevel <= intHighestLevel && intDevLevel <= intHighestDev && mapIntegervsListACT.containsKey(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel))) && !mapIntegervsListACT.get(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel))).isEmpty()){
                List<AccountTeamMember> lstACT = mapIntegervsListACT.get(Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel)));
                mapIntegervsListACTtoReturn.put('Middle',lstACT);
                //mapIntegervsListACTtoReturn.put('Middle',mapIntegervsListACT.get(intAppLevel + intDevLevel));
                //lstAccTM.add(mapIntegervsListACT.get(intAppLevel));
                blnFoundMiddler = true;
                intSecondHighestLevel = intAppLevel;
                intSecondHighestDev = intDevLevel;
                //SFAU-5338
                intMiddleLevel = Integer.valueOf(String.valueOf(intAppLevel) + '' + String.valueOf(intDevLevel));
                break;
               // boolExitLoop = true;
            } else if( !isCreditAssignment && intAppLevel <= intHighestLevel && mapIntegervsListACT.containsKey(intAppLevel) && !mapIntegervsListACT.get(intAppLevel).isEmpty() ){
                mapIntegervsListACTtoReturn.put('Middle', mapIntegervsListACT.get(intAppLevel) );
                blnFoundMiddler = true;
                intSecondHighestLevel = intAppLevel;
                break;
            }
        }
        
        system.debug('intSecondHighestLevel '+intSecondHighestLevel);
        system.debug('intSecondHighestDev '+intSecondHighestDev);
        
        return mapIntegervsListACTtoReturn;
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

    public static Integer getPricingAuthLevel(String authLevel){
        return authLevel != null ? Integer.valueOf(authLevel.replace('P', '')) : -1;
    }

    public static Integer getCreditAuthLevel(String authLevel){
        return authLevel != null ? Integer.valueOf(authLevel.replace('L', '')) : -1;
    }

    public static Integer getCreditDeviationLevel(String deviationLevel){
        return deviationLevel != null ? Integer.valueOf(deviationLevel.replace('S', '')) : -1;
    }

}