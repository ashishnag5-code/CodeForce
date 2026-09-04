public class AUSFOEMApprovalAssignment {
    public static final String[] REGION_HEAD_ROLES = new String[]{ 'Region Head (RBM)' };
    
    public static final map<String, String> HEAD_ROLE_TO_TYPE = new map<String, String>{
        'Region Head (RBM)' => 'Region'
    };
    
    public static void getListOfRBMApprovals(List<String> loanIds){
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        Map<String,List<AccountTeamMember>> mapOfAccountTeamMembers = new Map<String,List<AccountTeamMember>>();
        Set<String> listOfRegionIds = new Set<String>();
        Map<String,String> mapOfRegionIds = new Map<String,String>();
        for(Loan_Application__c loanApp:[
            SELECT Id,Branch_Master__c, Branch_Master__r.Business_HUB__c,
            Branch_Master__r.State__c,
            Branch_Master__r.Region__c,
            Branch_Master__r.Zone__c,
            Branch_Master__r.National__c
            FROM Loan_Application__c
            WHERE Id=:loanIds AND Branch_Master__c!=null
            WITH SECURITY_ENFORCED
        ]){
            mapOfRegionIds.put(loanApp.Id,loanApp.Branch_Master__r.Region__c);
            listOfRegionIds.add(loanApp.Branch_Master__r.Region__c);
            //listOfRegionIds.add( AUSFLoanApplicationAssignmentHelper.getAccountId('Region', loanApp ) );
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(loanIds);
        system.debug('wrap '+wrap);
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        //Map<String,AccountTeamMember> mapOfLevelVsAccountTeamBranch = new Map<String,AccountTeamMember>();
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        mapOfAccountTeamMembers = getAccountTeamMembers(listOfRegionIds,loanIds,mapOfFieldVsListOfValues);
        insertListOfApprovals.addAll(getListOfApprovals(mapOfAccountTeamMembers,mapOfRegionIds));
        if(!insertListOfApprovals.isEmpty()){
            if(!Test.isRunningTest()){
                //insert insertListOfApprovals;
                DatabaseUtility.createRecords(insertListOfApprovals, 'Loan_Application_Approval__c');
            }
        }
    }
    
    public static List<Loan_Application_Approval__c> getListOfApprovals(Map<String,List<AccountTeamMember>> mapApproverAtm, Map<String,String> mapLoanvsRegionIds){
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        if(mapLoanvsRegionIds != null){
            for(String loanId : mapLoanvsRegionIds.keySet()){
                Boolean boolIsAssigned = false;
                if(mapApproverAtm != null && mapApproverAtm.containsKey(mapLoanvsRegionIds.get(loanId))){
                    for(AccountTeamMember approverAtm : mapApproverAtm.get(mapLoanvsRegionIds.get(loanId))){
                        Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
                        loanApproval.Approver__c = approverAtm.UserId;
                        loanApproval.Approver_Level__c = approverAtm.Approver_Level__c?.split(';')[0];
                        loanApproval.Approval_Type__c ='OEMApproval';
                        if(!boolIsAssigned){
                            boolIsAssigned = true;
                            loanApproval.Is_Assigned_Approver__c = true;
                        }
                        loanApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
                        loanApproval.Loan_Application__c = loanId;
                        loanApproval.Type__c = 'Base';
                        loanApproval.Remarks__c = '';
                        insertListOfApprovals.add(loanApproval);
                    }
                }
            }
        }
        return insertListOfApprovals;
    }
    
    public static Map<String,List<AccountTeamMember>> getAccountTeamMembers(Set<String> listOfBranchIds,List<String> loanIds,
                                                                Map<String,List<String>> mapOfFieldVsListOfValues){
        List<String> customerGradeList = new List<String>();
        customerGradeList = mapOfFieldVsListOfValues.get('Customer_Grade__c');
        List<String> typeOfEmploymentList = new List<String>();
        typeOfEmploymentList = mapOfFieldVsListOfValues.get('Type_Of_Employment__c');
        List<String> collateralList = new List<String>();
        collateralList = mapOfFieldVsListOfValues.get('Collateral_Name__c');
        List<String> productList = new List<String>();
        productList = mapOfFieldVsListOfValues.get('Product__c');
        String teamRole= System.Label.PricingTeamMemberRoles;//'Cancellation';
        //List<String> teamMemberRoles = teamRole.split(',');
        List<String> teamMemberRoles = new List<String>();
        teamMemberRoles.add('Region Head (RBM)'); 
        // system.debug('team roles '+teamMemberRoles);                                                           
                                                                    
        String queryString = 'Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Approver_Level__c, Account.RecordType.DeveloperName, RBM_Approval_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c From AccountTeamMember Where Product__c!=null AND Customer_Grade__c!=null AND Collateral__c!=null AND Type_Of_Employment__c!=null AND Active__c= true AND TeamMemberRole IN:teamMemberRoles and AccountId In:listOfBranchIds';
        if(customerGradeList.size()>0){
            queryString +=' AND Customer_Grade__c INCLUDES(';
            for(String includeValue :customerGradeList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            system.debug('queryString '+queryString);
            queryString = queryString.removeEnd(',') +')';
            system.debug('queryString '+queryString);  
        }
        
        if(typeOfEmploymentList.size()>0){
            queryString +=' AND Type_Of_Employment__c INCLUDES(';
            for(String includeValue :typeOfEmploymentList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            system.debug('queryString '+queryString);
            queryString = queryString.removeEnd(',') +')';
            system.debug('queryString '+queryString); 
        }
        
        if(collateralList.size()>0){
            queryString +=' AND Collateral__c INCLUDES(';
            for(String includeValue :collateralList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            system.debug('queryString '+queryString);
            queryString = queryString.removeEnd(',') +')';
            system.debug('queryString '+queryString);
        }
        
        if(productList.size()>0){
            queryString +=' AND Product__c INCLUDES(';
            for(String includeValue :productList){
                queryString += +'\''+includeValue +'\''+ ',';
            }
            system.debug('queryString '+queryString);
            queryString = queryString.removeEnd(',') +')';
            system.debug('queryString '+queryString);
        }
        
        Map<String,List<AccountTeamMember>> mapAccountTeamMembers = new Map<String,List<AccountTeamMember>>();
        List<AccountTeamMember> listOfAccountTeamMembers = (List<AccountTeamMember>)Database.query(queryString);
        for(AccountTeamMember objAccountTeamMember : listOfAccountTeamMembers){
            if(mapAccountTeamMembers.keySet().contains(objAccountTeamMember.AccountId)){
                List<AccountTeamMember> lstAccountTeam = mapAccountTeamMembers.get(objAccountTeamMember.AccountId);
                lstAccountTeam.add(objAccountTeamMember);
                mapAccountTeamMembers.put(objAccountTeamMember.AccountId, lstAccountTeam);
            }
            else{
                mapAccountTeamMembers.put(objAccountTeamMember.AccountId, new List<AccountTeamMember>{objAccountTeamMember});
            }
        }
        return mapAccountTeamMembers;
    }
}