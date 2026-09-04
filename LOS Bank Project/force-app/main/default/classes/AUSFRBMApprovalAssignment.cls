/*****
 * Class Name: AUSFRBMApprovalAssignment
 * Description: AUSFRBMApprovalAssignmentTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-04-2023          -   Mohit M.            -   Remove !Test.isRunningTest
 * Dec-20-2023          -   Mohit M.            -   SFAU-5622 - Add User.isActive check
 */
public class AUSFRBMApprovalAssignment {

    public static String RBM_DO_APPROVAL_TYPE = 'DO 1';
    public static String requiredApprovalType = RBM_DO_APPROVAL_TYPE; //SFAU-4471
    public static final String[] BRANCH_HEAD_ROLES = new String[]{ 'Branch Manager', 'Team Lead' };
    public static final String[] HUB_HEAD_ROLES = new String[]{ 'Hub Head (CBM)' };
    public static final String[] REGION_HEAD_ROLES = new String[]{ 'Region Head (RBM)' };
    public static final String[] ZONE_HEAD_ROLES = new String[]{ 'Zonal Head (ZBM)' };
    public static final String[] NATIONAL_HEAD_ROLES = new String[]{ 'National Head (NBM/ NPM)' };

    public static final map<String, String> HEAD_ROLE_TO_TYPE = new map<String, String>{
        'Branch Manager' => 'Branch',
        'Team Lead' => 'Branch',
        'Hub Head (CBM)' => 'Hub',
        'Region Head (RBM)' => 'Region',
        'Zonal Head (ZBM)' => 'Zone',
        'National Head (NBM/ NPM)' => 'National'
    };

    public static void getListOfRBMApprovals(List<String> loanIds, Map<String,String> loanId_LetterTypeMap, String remarks, Boolean isRBMTatkal){
        Map<String,String> mapOfLoanAppVsLevel = new Map<String,String>();  
        Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        Set<String> listOfBranchIds = new Set<String>();
        Set<String> listOfHubIds = new Set<String>();
        Set<String> listOfRegionIds = new Set<String>();
        Set<String> listOfZoneIds = new Set<String>();
        Set<String> listOfNationalIds = new Set<String>();
        for(Loan_Application__c loanApp:[
            SELECT Branch_Master__c, Branch_Master__r.Business_HUB__c,
            Branch_Master__r.State__c,
            Branch_Master__r.Region__c,
            Branch_Master__r.Zone__c,
            Branch_Master__r.National__c
            FROM Loan_Application__c
            WHERE Id=:loanIds AND Branch_Master__c!=null
            WITH SECURITY_ENFORCED
        ]){
            if( requiredApprovalType == RBM_DO_APPROVAL_TYPE ){
                listOfBranchIds.add(loanApp.Branch_Master__c);
                listOfHubIds.add(loanApp.Branch_Master__r.Business_HUB__c);
                listOfRegionIds.add(loanApp.Branch_Master__r.Region__c);
            } else if( BRANCH_HEAD_ROLES.contains( requiredApprovalType ) ) {
                listOfBranchIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('Branch', loanApp ) );
            } else if( HUB_HEAD_ROLES.contains( requiredApprovalType ) ) {
                listOfHubIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('Hub', loanApp )  );
            } else if( REGION_HEAD_ROLES.contains( requiredApprovalType ) ) {
                listOfRegionIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('Region', loanApp ) );
            } else if( ZONE_HEAD_ROLES.contains( requiredApprovalType ) ) {
                listOfZoneIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('Zone', loanApp ) );
            } else if( NATIONAL_HEAD_ROLES.contains( requiredApprovalType ) ) {
                listOfNationalIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('National', loanApp ) );
            }
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(loanIds);
        mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        Map<String,AccountTeamMember> mapOfLevelVsAccountTeamBranch = new Map<String,AccountTeamMember>();
        listOfAccountTeamMembers = getAccountTeamMembers(listOfBranchIds,loanIds,mapOfFieldVsListOfValues);
        mapOfLevelVsAccountTeamBranch = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamBranch.get( requiredApprovalType ),loanIds,null,'Branch',loanId_LetterTypeMap, remarks, isRBMTatkal));
        
        if(insertListOfApprovals.isEmpty()){
            Map<String, AccountTeamMember> mapOfLevelVsAccountTeamHub = new Map<String, AccountTeamMember>();
            listOfAccountTeamMembers = getAccountTeamMembers(listOfHubIds,loanIds,mapOfFieldVsListOfValues);
            mapOfLevelVsAccountTeamHub = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
            insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamHub.get( requiredApprovalType ),loanIds,mapOfLevelVsAccountTeamBranch,'Hub',loanId_LetterTypeMap, remarks, isRBMTatkal));
            if(insertListOfApprovals.isEmpty()){
                Map<String, AccountTeamMember> mapOfLevelVsAccountTeamRegion = new Map<String, AccountTeamMember>();
                listOfAccountTeamMembers = getAccountTeamMembers(listOfRegionIds,loanIds,mapOfFieldVsListOfValues);
                mapOfLevelVsAccountTeamRegion = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
                insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamRegion.get( requiredApprovalType ),loanIds,mapOfLevelVsAccountTeamHub,'Region',loanId_LetterTypeMap, remarks, isRBMTatkal));
            }
            // Get Approvals from Branch / HUB / Region / National heads based on what's configured
            if( insertListOfApprovals.isEmpty() && HEAD_ROLE_TO_TYPE.containsKey(requiredApprovalType) ){
                map<String, Set<String>> branchTypeToIds = new map<String, Set<String>>{
                    'Branch' => listOfBranchIds,
                    'Hub' => listOfHubIds,
                    'Region' => listOfRegionIds,
                    'Zone' => listOfZoneIds,
                    'National' => listOfNationalIds
                };

                Map<String, AccountTeamMember> mapOfLevelVsAccountTeamRegion = new Map<String, AccountTeamMember>();
                //if(!Test.isRunningTest()){
                String strHeadRoleToType = HEAD_ROLE_TO_TYPE.containsKey(requiredApprovalType) ? HEAD_ROLE_TO_TYPE.get(requiredApprovalType) : '';
                Set<String> setBranchIds = String.isNotBlank(strHeadRoleToType) && branchTypeToIds.containsKey(strHeadRoleToType) ? branchTypeToIds.get(strHeadRoleToType) : new Set<String>();
                listOfAccountTeamMembers = getAccountTeamMembers(
                    setBranchIds,
                    loanIds,
                    mapOfFieldVsListOfValues
                );
    
                mapOfLevelVsAccountTeamRegion = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
                insertListOfApprovals.addAll(
                    getListOfApprovals(
                        mapOfLevelVsAccountTeamRegion.get( requiredApprovalType ),
                        loanIds,mapOfLevelVsAccountTeamHub,
                        HEAD_ROLE_TO_TYPE.get(requiredApprovalType),
                        loanId_LetterTypeMap,
                        remarks,
                        isRBMTatkal
                    )
                );
                //}
            }
        }
        insert insertListOfApprovals;
    }

    public static List<Loan_Application_Approval__c> getListOfApprovals(AccountTeamMember approverAtm,List<String> loanIds,Map<String,AccountTeamMember> mapOfLevelVsAccountTeamPrev,String accountType, 
        Map<String,String> loanId_LetterTypeMap, String remarks, Boolean isRBMTatkal){
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        if( approverAtm != null ){
            Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
            loanApproval.Approver__c = approverAtm.UserId;
            loanApproval.Approver_Level__c = approverAtm.Approver_Level__c?.split(';')[0];
            loanApproval.Approval_Type__c = (isRBMTatkal)?'RBMTatkal':'Sanction Tatkal';
            loanApproval.Is_Assigned_Approver__c = true;
            loanApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanApproval.Loan_Application__c = loanIds[0];
            loanApproval.Type__c = 'Base';
            loanApproval.Remarks__c = remarks;
            if(!loanId_LetterTypeMap.isEmpty() && loanId_LetterTypeMap.containsKey(loanIds[0])){
                loanApproval.Document_Name__c = loanId_LetterTypeMap.get(loanIds[0]);
            }
            insertListOfApprovals.add(loanApproval);
        }
        
        return insertListOfApprovals;
    }
        
    // :TODO -- Ideally this should return map<String, String[]>
    public static Map<String, AccountTeamMember> returnMapOfLevelVsAppr(List<AccountTeamMember> listOfAccountTeamMembers){
        Map<String, AccountTeamMember> mapOfLevelVsAccountTeam = new Map<String, AccountTeamMember>();
        Boolean isDoApproval = requiredApprovalType == RBM_DO_APPROVAL_TYPE;
        map<Id, String> approverIdToLevel = new map<Id, String>();
        for(AccountTeamMember acc:listOfAccountTeamMembers){
            if( isDoApproval ){
                mapOfLevelVsAccountTeam.put(acc.RBM_Approval_Level__c,acc);
            } else {
                approverIdToLevel.put( acc.UserId, acc.TeamMemberRole );
                // mapOfLevelVsAccountTeam.put( acc.TeamMemberRole, acc.UserId );
            }
        }

        Set<Id> userIds = approverIdToLevel.keySet();
        userIds.remove( null );

        if( isDoApproval || userIds.isEmpty() )
            return mapOfLevelVsAccountTeam;
        
        map<String, AccountTeamMember[]> membersByRole = Utility.getTeamMembersByRole( listOfAccountTeamMembers );
        AccountTeamMember[] applicableMembers = membersByRole.containsKey( requiredApprovalType ) ? membersByRole.get( requiredApprovalType ) : new AccountTeamMember[0];
        AccountTeamMember teamMember = AUSFApproverController.getMemberWithLeastWork(
            applicableMembers,
            AUSFApproverController.getTeamMemberBasedOnRoundRobin( applicableMembers )
        );

        if( teamMember != null ){
            mapOfLevelVsAccountTeam.put( requiredApprovalType, teamMember );
        }
        return mapOfLevelVsAccountTeam;
    }
    
    public static List<AccountTeamMember> getAccountTeamMembers(Set<String> listOfBranchIds,List<String> loanIds,
        Map<String,List<String>> mapOfFieldVsListOfValues){
        Set<String> customerGradeList = new Set<String>();
        if (mapOfFieldVsListOfValues.containsKey('Customer_Grade__c') && mapOfFieldVsListOfValues.get('Customer_Grade__c') != null && !mapOfFieldVsListOfValues.get('Customer_Grade__c').isEmpty()) {
            customerGradeList.addAll(mapOfFieldVsListOfValues.get('Customer_Grade__c'));
        }
        Set<String> typeOfEmploymentList = new Set<String>();
        if (mapOfFieldVsListOfValues.containsKey('Type_Of_Employment__c') && mapOfFieldVsListOfValues.get('Type_Of_Employment__c') != null && !mapOfFieldVsListOfValues.get('Type_Of_Employment__c').isEmpty()) {
            typeOfEmploymentList.addAll(mapOfFieldVsListOfValues.get('Type_Of_Employment__c'));
        }
        Set<String> collateralList = new Set<String>();
        if (mapOfFieldVsListOfValues.containsKey('Collateral_Name__c') && mapOfFieldVsListOfValues.get('Collateral_Name__c') != null && !mapOfFieldVsListOfValues.get('Collateral_Name__c').isEmpty()) {
            collateralList.addAll(mapOfFieldVsListOfValues.get('Collateral_Name__c'));
        }
        Set<String> productList = new Set<String>();
        if (mapOfFieldVsListOfValues.containsKey('Product__c') && mapOfFieldVsListOfValues.get('Product__c') != null && !mapOfFieldVsListOfValues.get('Product__c').isEmpty()) {
            productList.addAll(mapOfFieldVsListOfValues.get('Product__c'));
        }
        String teamRole= System.Label.PricingTeamMemberRoles;//'Cancellation';
        List<String> teamMemberRoles = teamRole.split(',');
        // SFAU-5622 - Add User.isActive check
        String queryString = 'Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Approver_Level__c, Account.RecordType.DeveloperName, RBM_Approval_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c From AccountTeamMember Where User.IsActive = true AND Product__c!=null ' + (requiredApprovalType == 'DO 1' ? 'AND RBM_Approval_Level__c!=null' : '') + ' AND Customer_Grade__c!=null AND Collateral__c!=null AND Type_Of_Employment__c!=null AND Active__c= true AND TeamMemberRole IN:teamMemberRoles and AccountId In:listOfBranchIds';
        if(customerGradeList.size()>0){
            queryString +=' AND Customer_Grade__c INCLUDES(';
            for(String includeValue :customerGradeList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            queryString = queryString.removeEnd(',') +')';
        }
        
        if(typeOfEmploymentList.size()>0){
            queryString +=' AND Type_Of_Employment__c INCLUDES(';
            for(String includeValue :typeOfEmploymentList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            queryString = queryString.removeEnd(',') +')';
        }
        
        if(collateralList.size()>0){
            queryString +=' AND Collateral__c INCLUDES(';
            for(String includeValue :collateralList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            queryString = queryString.removeEnd(',') +')';
        }
        
        if(productList.size()>0){
            queryString +=' AND Product__c INCLUDES(';
            for(String includeValue :productList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            queryString = queryString.removeEnd(',') +')';
        }
        List<AccountTeamMember> listOfAccountTeamMembers = (List<AccountTeamMember>)Database.query(queryString);
        /*
        Boolean hasCG;
        Boolean hasProduct;
        Boolean hasTypeOfEmp;
        Boolean hasCollateral;
        List<String> productListFromTeam;
        List<String> empListFromTeam;
        List<String> collListFromTeam;
        List<String> cgListFromTeam;
        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        for (AccountTeamMember each : [
            SELECT Id, UserId, Product__c, AccountId, TeamMemberRole, Approver_Level__c, Account.RecordType.DeveloperName, RBM_Approval_Level__c, Customer_Grade__c,
            Collateral__c, Type_Of_Employment__c FROM AccountTeamMember WHERE Active__c = true AND TeamMemberRole IN: teamMemberRoles and AccountId IN: listOfBranchIds AND User.IsActive = true
        ]) {
            productListFromTeam = String.isBlank(each.Product__c) ? new List<String>() : each.Product__c.split(';');
            empListFromTeam = String.isBlank(each.Type_Of_Employment__c) ? new List<String>() : each.Type_Of_Employment__c.split(';');
            collListFromTeam = String.isBlank(each.Collateral__c) ? new List<String>() : each.Collateral__c.split(';');
            cgListFromTeam = String.isBlank(each.Customer_Grade__c) ? new List<String>() : each.Customer_Grade__c.split(';');
            hasCG = customerGradeList.removeAll(cgListFromTeam);
            hasProduct = productList.removeAll(productListFromTeam);
            hasTypeOfEmp = typeOfEmploymentList.removeAll(empListFromTeam);
            hasCollateral = collateralList.removeAll(collListFromTeam);

            if (hasCG && hasProduct && hasTypeOfEmp && hasCollateral) {
                listOfAccountTeamMembers.add(each);
            }
        }
        */
        return listOfAccountTeamMembers;
    }
}