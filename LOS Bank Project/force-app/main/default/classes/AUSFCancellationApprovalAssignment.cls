/*****
 * Class Name: AUSFCancellationApprovalAssignment
 * Description: 
 * Test Class Name: AUSFCancellationApprovalAssignmentTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-20-2023          -   Mohit M.            -   // SFAU-5622 Add User.IsActive Check
 */
public without sharing class AUSFCancellationApprovalAssignment {

    public static void getListOfCancellationApprovals(List<String> loanIds, Map<String,String> loanId_LetterTypeMap){
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
        for(Loan_Application__c loanApp:[SELECT Branch_Master__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.Region__c, DO_Cancellation_Approver_Name__c 
                                         FROM Loan_Application__c WHERE Id=:loanIds AND Branch_Master__c!=null WITH SECURITY_ENFORCED]){
            listOfBranchIds.add(loanApp.Branch_Master__c);
            listOfHubIds.add(loanApp.Branch_Master__r.Business_HUB__c);
            listOfRegionIds.add(loanApp.Branch_Master__r.Region__c);
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(loanIds);
        system.debug('wrap '+wrap);
        mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        Map<String,String> mapOfLevelVsAccountTeamBranch = new Map<String,String>();
        listOfAccountTeamMembers = getAccountTeamMembers(listOfBranchIds,loanIds,mapOfFieldVsListOfValues);
        system.debug('acc memebers '+listOfAccountTeamMembers);
        mapOfLevelVsAccountTeamBranch = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamBranch,loanIds,null,'Branch',loanId_LetterTypeMap));
        
        if(!mapOfLevelVsAccountTeamBranch.containsKey('Cancellation 2') && !mapOfLevelVsAccountTeamBranch.containsKey('Cancellation 3')){
            Map<String,String> mapOfLevelVsAccountTeamHub = new Map<String,String>();
            listOfAccountTeamMembers = getAccountTeamMembers(listOfHubIds,loanIds,mapOfFieldVsListOfValues);
            
            mapOfLevelVsAccountTeamHub = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
            system.debug('acct members hub '+mapOfLevelVsAccountTeamHub);
            insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamHub,loanIds,mapOfLevelVsAccountTeamBranch,'Hub',loanId_LetterTypeMap));
            if(!mapOfLevelVsAccountTeamHub.containsKey('Cancellation 2') && !mapOfLevelVsAccountTeamHub.containsKey('Cancellation 3')){
                Map<String,String> mapOfLevelVsAccountTeamRegion = new Map<String,String>();
                listOfAccountTeamMembers = getAccountTeamMembers(listOfRegionIds,loanIds,mapOfFieldVsListOfValues);
                mapOfLevelVsAccountTeamRegion = returnMapOfLevelVsAppr(listOfAccountTeamMembers);
                insertListOfApprovals.addAll(getListOfApprovals(mapOfLevelVsAccountTeamRegion,loanIds,mapOfLevelVsAccountTeamHub,'Region',loanId_LetterTypeMap));
            }
        }
        
        insert insertListOfApprovals;
        // Added By Yash
        
    }

    public static List<Loan_Application_Approval__c> getListOfApprovals(Map<String,String> mapOfLevelVsAccountTeam,List<String> loanIds,Map<String,String> mapOfLevelVsAccountTeamPrev,String accountType, Map<String,String> loanId_LetterTypeMap){
        List<Loan_Application_Approval__c> insertListOfApprovals = new List<Loan_Application_Approval__c>();
        if(mapOfLevelVsAccountTeam.containsKey('Cancellation 1') && (accountType=='Branch' || !mapOfLevelVsAccountTeamPrev.containsKey('Cancellation 1'))){
            Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
            loanApproval.Approver__c = mapOfLevelVsAccountTeam.get('Cancellation 1');
            loanApproval.Approver_Level__c = 'Cancellation 1';
            loanApproval.Approval_Type__c = 'Cancellation';
            loanApproval.Is_Assigned_Approver__c = true;
            loanApproval.Loan_Application__c = loanIds[0];
            loanApproval.Type__c = 'Base';
            if(!loanId_LetterTypeMap.isEmpty() && loanId_LetterTypeMap.containsKey(loanIds[0])){
                loanApproval.Document_Name__c = loanId_LetterTypeMap.get(loanIds[0]);
            }
            insertListOfApprovals.add(loanApproval);
        }
        
        if(mapOfLevelVsAccountTeam.containsKey('Cancellation 2')){
            Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
            loanApproval.Approver__c = mapOfLevelVsAccountTeam.get('Cancellation 2');
            loanApproval.Approver_Level__c = 'Cancellation 2';
            loanApproval.Approval_Type__c = 'Cancellation';
            if(!mapOfLevelVsAccountTeam.containsKey('Cancellation 1')){
                loanApproval.Is_Assigned_Approver__c = true;
            }else{
                loanApproval.Is_Assigned_Approver__c = false;
            }
            loanApproval.Loan_Application__c = loanIds[0];
            loanApproval.Type__c = 'Middle';
            if(!loanId_LetterTypeMap.isEmpty() && loanId_LetterTypeMap.containsKey(loanIds[0])){
                loanApproval.Document_Name__c = loanId_LetterTypeMap.get(loanIds[0]);
            }
            insertListOfApprovals.add(loanApproval);
        }else if(mapOfLevelVsAccountTeam.containsKey('Cancellation 3')){
            Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
            loanApproval.Approver__c = mapOfLevelVsAccountTeam.get('Cancellation 3');
            loanApproval.Approver_Level__c = 'Cancellation 3';
            loanApproval.Approval_Type__c = 'Cancellation';
            if(!mapOfLevelVsAccountTeam.containsKey('Cancellation 1')){
                loanApproval.Is_Assigned_Approver__c = true;
            }else{
                loanApproval.Is_Assigned_Approver__c = false;
            }
            loanApproval.Loan_Application__c = loanIds[0];
            loanApproval.Type__c = 'Middle';
            if(!loanId_LetterTypeMap.isEmpty() && loanId_LetterTypeMap.containsKey(loanIds[0])){
                loanApproval.Document_Name__c = loanId_LetterTypeMap.get(loanIds[0]);
            }
            insertListOfApprovals.add(loanApproval);
        }
        return insertListOfApprovals;
    }
	    
    public static Map<String,String> returnMapOfLevelVsAppr(List<AccountTeamMember> listOfAccountTeamMembers){
        Map<String,String> mapOfLevelVsAccountTeam = new Map<String,String>();
        for(AccountTeamMember acc:listOfAccountTeamMembers){
            if(acc.Cancellation_Level__c!=null){
                    mapOfLevelVsAccountTeam.put(acc.Cancellation_Level__c,acc.UserId);
            } 
        }
        return mapOfLevelVsAccountTeam;
    }
    
    public static List<AccountTeamMember> getAccountTeamMembers(Set<String> listOfBranchIds,List<String> loanIds,Map<String,List<String>> mapOfFieldVsListOfValues){
        List<String> customerGradeList = new List<String>();
        customerGradeList = mapOfFieldVsListOfValues.get('Customer_Grade__c');
        List<String> typeOfEmploymentList = new List<String>();
        typeOfEmploymentList = mapOfFieldVsListOfValues.get('Type_Of_Employment__c');
        List<String> collateralList = new List<String>();
        collateralList = mapOfFieldVsListOfValues.get('Collateral_Name__c');
        List<String> productList = new List<String>();
        productList = mapOfFieldVsListOfValues.get('Product__c');
        String teamRole= System.Label.PricingTeamMemberRoles;//'Cancellation';
        List<String> teamMemberRoles = teamRole.split(',');
        // SFAU-5622- Add User.isActive Check
        String queryString = 'Select Id, UserId, Product__c ,AccountId, Account.RecordType.DeveloperName, Cancellation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c From AccountTeamMember Where User.isActive = true AND Product__c!=null AND Cancellation_Level__c!=null AND Customer_Grade__c!=null AND Collateral__c!=null AND Type_Of_Employment__c!=null AND Active__c= true AND TeamMemberRole IN:teamMemberRoles and AccountId In:listOfBranchIds';
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
        
        system.debug('queryValue final '+queryString);
        List<AccountTeamMember> listOfAccountTeamMembers = (List<AccountTeamMember>)Database.query(queryString);
        return listOfAccountTeamMembers;
    }
}