/*****
 * Class Name: CreditApprovalHandler
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-18-2023          -   Mohit M.            -   SFAU-5179 and SFAU-5201 change sharing control due to FI Agent getting error
 * Nov-16-2023          -   Sachin              -   R2-2010 - Credit Hierarchy assignment for Tractor & Commercials
 * Dec-20-2023          -   Mohit M.            -   SFAU-5622 - Add User.IsActive check
 */

 public without sharing class CreditApprovalHandler {
    public static final String[] CREDIT_APPROVAL_INELIGIBLE_STAGES = new String[]{ GlobalConstants.REJECTED };

    public static void insertCreditApproval(Map<Id,sObject> newApprovalMap,Map<Id, sObject> oldRecordMapApr){
        Map<Id, Loan_Application__c> newListApprovalMap = (Map<Id, Loan_Application__c>) newApprovalMap;
        Map<Id, Loan_Application__c> oldRecordMap = (Map<Id, Loan_Application__c>) oldRecordMapApr;
        Map<String,String> mapOfLoanAppVsLevel = new Map<String,String>();  
        Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();

        SObjectType loanSObj = SObjectType.Loan_Application__c.getSObjectType();
        // R2-2010
        Set<Id> queueBasedLoanTypes = new Set<Id>{
            Utility.getRecordTypeId( loanSObj, GlobalConstants.TWOWHEELER )
        };

        // Loans that follow Hierarchy based Credit Assignments - Four Wheeler / Tractor / Commercial
        Set<Id> hierarchyBasedLoanTypes = new Set<Id>{
            Utility.getRecordTypeId(loanSObj, GlobalConstants.FOURWHEELER ),
            Utility.getRecordTypeId(loanSObj, GlobalConstants.TRACTOR ),
            Utility.getRecordTypeId(loanSObj, GlobalConstants.COMMERCIALVEHICLE ),
            Utility.getRecordTypeId(loanSObj, GlobalConstants.CONSTRUCTIONEQUIP )
        };

        // Id fourWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
        Set<String> listOfBranchIds = new Set<String>();
        List<String> listOfLoanAppIds = new List<String>();
        List<String> listOfSchemeIds = new List<String>();
        List<AccountTeamMember> listOfAccountTeamMembers = new List<AccountTeamMember>();
        List<Id> listOfQueueBasedLoanApplicationIds = new List<Id>();
        List<Id> listOfHierarchyBasedLoanApplicationIds = new List<Id>();
        List<Loan_Application__c> listOfQueueBasedLoanApplications = new List<Loan_Application__c>();
        List<Loan_Application__c> listOfHierarchyBasedLoanApplications = new List<Loan_Application__c>();
        List<String> loanIds = new List<String>(); 
        Set<Id> branchIds = new Set<Id>();
        // SFAU-4827 - 04/09/23
        for( Loan_Application__c application: (Loan_Application__c[])newApprovalMap.values() ){
            branchIds.add(application.Branch_Master__c);
        }
        branchIds.remove( null );

        map<Id, Account> branchHierarchy = new map<Id, Account>( [ SELECT Business_HUB__c, State__c, Region__c, Zone__c, National__c FROM Account WHERE Id IN: branchIds ] );

        for(Loan_Application__c loanApp:newListApprovalMap.values()){

            // Cases sent back has to skip re-assignment
            if( loanApp.Is_Rework__c ) continue;
            
            // When Loan is moved from Rejected to Credit again - skip assignment again
            // SFAU-5083 - 11/08/23 | When BRE Re runs at Credit stage, Credit reassignment has to be done based on BRE Approval Level received from BRE
            // 1 AND ( 2 OR 3 ) AND 4
            if(loanApp.Stage__c=='Credit' && // 1
                ( ( oldRecordMap.get(loanApp.Id).Stage__c == 'Credit' && loanApp.BRE_Approval_Level__c != oldRecordMap.get(loanApp.Id).BRE_Approval_Level__c ) || //2
                ( oldRecordMap.get(loanApp.Id).Stage__c != 'Credit' && !CREDIT_APPROVAL_INELIGIBLE_STAGES.contains(oldRecordMap.get(loanApp.Id).Stage__c) ) ) && //3
                loanApp.BRE_Approval_Level__c!=null && loanApp.BRE_Decision__c=='NSTP') //4
            {

                if(loanApp.BRE_Approval_Level__c!=null){
                    mapOfLoanAppVsLevel.put(loanApp.Id,loanApp.BRE_Approval_Level__c);
                }
                loanIds.add(loanApp.Id);

                // Loans that are assigned to Queue - Two Wheeler
                if( queueBasedLoanTypes.contains( loanApp.RecordTypeId ) ){
                    system.debug('loanApp>>> '+loanApp.Branch_Master__r.Business_HUB__c);
                    listOfQueueBasedLoanApplicationIds.add(loanApp.Id);
                } else if( hierarchyBasedLoanTypes.contains(loanApp.RecordTypeId) ){ //Loans that follow Hierarchy based Credit Assignments - Four Wheeler / Tractor / Commercial
                    listOfHierarchyBasedLoanApplicationIds.add(loanApp.Id);
                }
                //listOfLoanApplications.add(loanApp);
                listOfBranchIds.add( loanApp.Branch_Master__c );
                listOfBranchIds.add( branchHierarchy.get(loanApp.Branch_Master__c)?.Business_HUB__c );
                listOfBranchIds.add( branchHierarchy.get(loanApp.Branch_Master__c)?.State__c );
                listOfBranchIds.add( branchHierarchy.get(loanApp.Branch_Master__c)?.Region__c );
                listOfBranchIds.add( branchHierarchy.get(loanApp.Branch_Master__c)?.Zone__c );
                listOfBranchIds.add( branchHierarchy.get(loanApp.Branch_Master__c)?.National__c );
                listOfBranchIds.remove( null );
                if(loanApp.Scheme__c!=null){
                    listOfSchemeIds.add(loanApp.Scheme__c);
                }
                
            }
            if(loanApp.Stage__c=='Pricing' && oldRecordMap.get(loanApp.Id).Stage__c!='Pricing'){
                listOfLoanAppIds.add(loanApp.Id);
            }
        }
        if( !listOfHierarchyBasedLoanApplicationIds.isEmpty() ){
            listOfHierarchyBasedLoanApplications = getLoanApplications( listOfHierarchyBasedLoanApplicationIds );
        }
        
        if( !listOfQueueBasedLoanApplicationIds.isEmpty() ){
            listOfQueueBasedLoanApplications = getLoanApplications( listOfQueueBasedLoanApplicationIds );
        }
        
        
        if(listOfBranchIds.size()>0 && loanIds.size()>0){
            wrapper wrap =getListOfFilterValues(loanIds);
            system.debug('wrap '+wrap);
            mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
            mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
            mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
            mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
            mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
            /*List<String> customerGradeList = new List<String>();
customerGradeList = mapOfFieldVsListOfValues.get('Customer_Grade__c');
List<String> typeOfEmploymentList = new List<String>();
typeOfEmploymentList = mapOfFieldVsListOfValues.get('Type_Of_Employment__c');
List<String> collateralList = new List<String>();
collateralList = mapOfFieldVsListOfValues.get('Collateral_Name__c');
String queryString = 'Select Id, UserId, AccountId, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c From AccountTeamMember Where Active__c= true and AccountId In:listOfBranchIds';
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
}*/
            
            //listOfAccountTeamMembers = (List<AccountTeamMember>)Database.query(queryString);
            
            listOfAccountTeamMembers = getAccountTeamMembers(listOfBranchIds,loanIds,mapOfFieldVsListOfValues,'Credit');
            /*for(AccountTeamMember act:[select Id, UserId, AccountId, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c 
from AccountTeamMember 
Where Type_of_Employment__c INCLUDES:typeOfEmployment AND Customer_Grade__c INCLUDES:(customerGrade) AND Collateral__c INCLUDES:(collateralName)  AND Approver_Level__c!=null AND Scheme_Master__c=:listOfSchemeIds AND AccountId in :listOfBranchIds AND TeamMemberRole='Credit' WITH SECURITY_ENFORCED]){
listOfAccountTeamMembers.add(act);
} */
        }
        
        
        if(listOfHierarchyBasedLoanApplicationIds.size()>0){
            updateLoanApprovals( listOfHierarchyBasedLoanApplicationIds );
            /*AUSFLoanApplicationAssignmentHelper cs = new AUSFLoanApplicationAssignmentHelper(GlobalConstants.APPROVAL_TYPE_CREDIT, null);
            AUSFLoanApplicationAssignmentHelper.loanAppIdVsKey = mapOfLoanAppVsLevel;
            AUSFLoanApplicationAssignmentHelper.approvalType = GlobalConstants.APPROVAL_TYPE_CREDIT;
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade;
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = mapOfLoanIdVsCollateralName;
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
            AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = mapOfFieldVsListOfValues;
            AUSFLoanApplicationAssignmentHelper.breTrigger = false;
            AUSFLoanApplicationAssignmentHelper.mainMethod(listOfAccountTeamMembers,listOfFourLoanApplications);*/

            // SFAU-4827 - 04/09/23 -- Credit / Pricing assignments to be level priortized rather than branch type
            Loan_Application__c loanApplication = listOfHierarchyBasedLoanApplications[0];
            CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_CREDIT, listOfAccountTeamMembers, loanApplication, loanApplication.BRE_Approval_Level__c );
        } 
        
        if(listOfQueueBasedLoanApplications.size()>0){
            X2W_Approval_Assignem_Switch__mdt  sw =X2W_Approval_Assignem_Switch__mdt.getInstance('Queue_Based_Assignment');
            if(sw.Assignment_Switch__c){
                updateLoanApprovals( listOfQueueBasedLoanApplicationIds );
                assignLoanApprovalsToQueue(listOfQueueBasedLoanApplications,sw.QueueId__c);
            }else{
                updateLoanApprovals( listOfQueueBasedLoanApplicationIds );
                /*AUSFLoanApplicationAssignmentHelper cs = new AUSFLoanApplicationAssignmentHelper(GlobalConstants.APPROVAL_TYPE_CREDIT, null);
                AUSFLoanApplicationAssignmentHelper.loanAppIdVsKey = mapOfLoanAppVsLevel;
                AUSFLoanApplicationAssignmentHelper.approvalType = GlobalConstants.APPROVAL_TYPE_CREDIT;
                AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade;
                AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
                AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = mapOfLoanIdVsCollateralName;
                AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
                AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = mapOfFieldVsListOfValues;
                AUSFLoanApplicationAssignmentHelper.breTrigger = false;
                AUSFLoanApplicationAssignmentHelper.mainMethod(listOfAccountTeamMembers,listOfTwoLoanApplications);*/

                // SFAU-4827 - 04/09/23 -- Credit / Pricing assignments to be level priortized rather than branch type
                Loan_Application__c loanApplication = listOfQueueBasedLoanApplications[0];
                CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_CREDIT, listOfAccountTeamMembers, loanApplication, loanApplication.BRE_Approval_Level__c );
            } 
        }
        if(listOfLoanAppIds.size()>0){
            updatePricingApprovals(listOfLoanAppIds);
        }
    }
    
    public static List<AccountTeamMember> getAccountTeamMembers(Set<String> listOfBranchIds,List<String> loanIds,Map<String,List<String>> mapOfFieldVsListOfValues, String approvalType){
        /*Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
Map<String,String> mapOfLoanIdVsCollateralName = new Map<String,String>();
Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
wrapper wrap =getListOfFilterValues(loanIds);
system.debug('wrap '+wrap);
mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; */
        List<String> customerGradeList = new List<String>();
        customerGradeList = mapOfFieldVsListOfValues.get('Customer_Grade__c');
        List<String> typeOfEmploymentList = new List<String>();
        typeOfEmploymentList = mapOfFieldVsListOfValues.get('Type_Of_Employment__c');
        List<String> collateralList = new List<String>();
        collateralList = mapOfFieldVsListOfValues.get('Collateral_Name__c');
        List<String> productList = new List<String>();
        productList = mapOfFieldVsListOfValues.get('Product__c');
        
        String queryString = 'Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c From AccountTeamMember Where Product__c!=null AND Approver_Level__c!=null AND Customer_Grade__c!=null AND Collateral__c!=null AND Type_Of_Employment__c!=null AND Active__c= true AND User.IsActive != FALSE and AccountId In:listOfBranchIds';
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

        if(approvalType == GlobalConstants.APPROVAL_TYPE_CREDIT){
            queryString +=' AND TeamMemberRole=\'Credit\'';
            system.debug('queryString '+queryString);
        }

        if(approvalType == GlobalConstants.APPROVAL_TYPE_PRICING){
            List<String> pricingTeamMemberRoles = System.Label.PricingTeamMemberRoles.split(',');
            queryString +=' AND TeamMemberRole IN: pricingTeamMemberRoles';
            system.debug('queryString '+queryString);
        }
        
        List<AccountTeamMember> listOfAccountTeamMembers = (List<AccountTeamMember>)Database.query(queryString);
        return listOfAccountTeamMembers;
    }
    
    public static List<Loan_Application__c> getLoanApplications(List<Id> loanIds){
        return [
            SELECT Id,RecordTypeId, RecordType.Name, Branch_Master__c,
            BRE_Approval_Level__c,Branch_Master__r.Business_HUB__c,
            Branch_Master__r.Zone__c,Branch_Master__r.National__c,
            Branch_Master__r.Region__c,Branch_Master__r.State__c
            FROM Loan_Application__c
            WHERE Id=:loanIds
        ];
    }
    public static void assignLoanApprovalsToQueue(List<Loan_Application__c> newListOfApplications,String queueId){
        List<Loan_Application_Approval__c> listOfApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppr;
        for(Loan_Application__c loanApp:newListOfApplications){
            loanAppr = new Loan_Application_Approval__c();
            loanAppr.Loan_Application__c = loanApp.Id; 
            loanAppr.Approver_Level__c = loanApp.BRE_Approval_Level__c;
            loanAppr.Approval_Type__c = 'Credit';
            loanAppr.Approval_Status__c = 'Pending';
            loanAppr.Assigned_to_Queue__c = true;
            listOfApprovals.add(loanAppr);
        }
        
        insert listOfApprovals;
    }
    
    public static void updatePricingApprovals(List<String> newListOfIds){
        List<Loan_Application_Approval__c> listOfApprovals = new List<Loan_Application_Approval__c>();
        //Id recordTypeIdValue = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('Pricing Approver').getRecordTypeId();
        for(Loan_Application__c loanApp:[SELECT Id,Approval_Status__c,(SELECT ID,Type__c,Is_Assigned_Approver__c FROM Loan_Application_Approvers__r WHERE (Type__c ='Base' OR Type__c='Middle') AND Approval_Type__c='Pricing' AND Archived__c = FALSE order by Type__c) FROM Loan_Application__c WHERE Id In :newListOfIds WITH SECURITY_ENFORCED]){
            List<Loan_Application_Approval__c> loanApprovals = new List<Loan_Application_Approval__c>();
            loanApprovals = loanApp.Loan_Application_Approvers__r;
            Boolean isBasePresent = false;
            if(loanApprovals.size()>0){
                for(Loan_Application_Approval__c appr:loanApprovals){
                    if(appr.Type__c=='Base'){
                        isBasePresent = true;
                        appr.Is_Assigned_Approver__c = true;
                        listOfApprovals.add(appr);
                    }else if(appr.Type__c=='Middle' && isBasePresent==false){
                        appr.Is_Assigned_Approver__c = true;
                        listOfApprovals.add(appr);
                    }
                }
            }
        }
        if(listOfApprovals.size()>0){
        //NotificationHandler.sendNotification('Credit Submission(N)','','approvers');
        // Approval.unlock(new List<Id>((new map<Id, Loan_Application_Approval__c>(listOfApprovals)).keySet()));
        update listOfApprovals;
        }
    }
    
    public static wrapper getListOfFilterValues(List<String> loanIds){
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Id collateralNewRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Map<String,String> mapOfLoanIdVsCollName = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsCustGrade = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsTypeOfEmpl = new Map<String,String>();
        Map<String,String> mapOfLoanIdVsProduct = new Map<String,String>();
        Map<String,List<String>> mapOfFieldVsListOfValues = new Map<String,List<String>>();
        mapOfFieldVsListOfValues.put('Customer_Grade__c',new List<String>());
        mapOfFieldVsListOfValues.put('Type_Of_Employment__c',new List<String>());
        mapOfFieldVsListOfValues.put('Collateral_Name__c',new List<String>());
        mapOfFieldVsListOfValues.put('Product__c',new List<String>());
        wrapper wrap = new wrapper();
        // R2-2010 | Customer Grade is moved to loan
        for(Applicant__c app:[SELECT Id,Loan__c,Loan__r.Product__c,Loan__r.Customer_Grade__c,Type_Of_Employment__c FROM Applicant__c Where recordTypeId=:applicantRecordTypeId and Loan__c=:loanIds WITH SECURITY_ENFORCED]){
            mapOfFieldVsListOfValues.get('Customer_Grade__c').add(app.Loan__r.Customer_Grade__c);
            mapOfFieldVsListOfValues.get('Type_Of_Employment__c').add(app.Type_Of_Employment__c);
            mapOfFieldVsListOfValues.get('Product__c').add(app.Loan__r.Product__c);
            mapOfLoanIdVsProduct.put(app.Loan__c,app.Loan__r.Product__c);
            mapOfLoanIdVsCustGrade.put(app.Loan__c,app.Loan__r.Customer_Grade__c);
            mapOfLoanIdVsTypeOfEmpl.put(app.Loan__c,app.Type_Of_Employment__c);
        }
        for(Collateral__c coll:[SELECT Id,Loan__c,Collateral_Name__c FROM Collateral__c Where (recordTypeId =:collateralUsedRecordTypeId OR recordTypeId =:collateralNewRecordTypeId) AND Is_Deleted__c = false AND Loan__c=:loanIds WITH SECURITY_ENFORCED]){
            mapOfFieldVsListOfValues.get('Collateral_Name__c').add(coll.Collateral_Name__c);
            mapOfLoanIdVsCollName.put(coll.Loan__c,coll.Collateral_Name__c);
        }
        wrap.mapOfFieldVsValues=mapOfFieldVsListOfValues;
        wrap.mapOfLoanIddVsCollateralName = mapOfLoanIdVsCollName;
        wrap.mapOfLoanIdVsCustGrade = mapOfLoanIdVsCustGrade; 
        wrap.mapOfLoanIdVsTypeOfEmpl = mapOfLoanIdVsTypeOfEmpl;
        wrap.mapOfLoanIdVsProduct = mapOfLoanIdVsProduct;
        return wrap;
    }
    
    public static void createRBMTatkalApprovers(Set<Id> newListIds){
        List<Loan_Application__c> newList = new List<Loan_Application__c>();
        List<Loan_Application_Approval__c> insertRBMApprovalList = new List<Loan_Application_Approval__c>();
        Map<String,String> mapOfAccountIdVsBranchManagerId = new Map<String,String>();
        Set<Id> accountIds = new Set<Id>();
        for(Loan_Application__c loanApp:[SELECT Id,Branch_Master__c,Branch_Master__r.Region__c FROM Loan_Application__c WHERE Id=:newListIds AND Stage__c='Credit'  WITH SECURITY_ENFORCED]){
            if(loanApp.Branch_Master__c!=null){
                accountIds.add(loanApp.Branch_Master__c);
                if(loanApp.Branch_Master__r.Region__c!=null){
                    accountIds.add(loanApp.Branch_Master__r.Region__c); 
                }
            }
            newList.add(loanApp);
        }
        system.debug('accountIds '+accountIds);
        // SFAU-5622 - Add User.IsActive check
        for(AccountTeamMember acc:[SELECT Id,AccountId,UserId,TeamMemberRole FROM AccountTeamMember Where AccountId=:accountIds AND TeamMemberRole='Branch Manager' AND User.IsActive = true WITH SECURITY_ENFORCED]){
            mapOfAccountIdVsBranchManagerId.put(acc.AccountId,acc.UserId );
            system.debug('acc');
        }
        for(Loan_Application__c loanApp:newList){
            Loan_Application_Approval__c loanApproval = new Loan_Application_Approval__c();
            system.debug('loanApproval.Approver__c '+loanApproval.Approver__c);
            system.debug('mapOfAccountIdVsBranchManagerId '+mapOfAccountIdVsBranchManagerId);
            if(mapOfAccountIdVsBranchManagerId.containsKey(loanApp.Branch_Master__c)){
                loanApproval.Approver__c = mapOfAccountIdVsBranchManagerId.get(loanApp.Branch_Master__c);
            }else if(mapOfAccountIdVsBranchManagerId.containsKey(loanApp.Branch_Master__r.Region__c)){
                loanApproval.Approver__c = mapOfAccountIdVsBranchManagerId.get(loanApp.Branch_Master__r.Region__c);
            }
            
            loanApproval.Loan_Application__c = loanApp.Id;
            //loanApproval.RecordTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByDeveloperName().get('RBM').getRecordTypeId();
            loanApproval.Approval_Type__c ='RBMTatkal';
            loanApproval.Approval_Status__c  ='Pending';
            insertRBMApprovalList.add(loanApproval);
        }
        insert insertRBMApprovalList;
    }

    // Create asyn method due to record lock issue
    // SFAU-4471 - AND Approval_Type__c != 'RBMTatkal' - Skip RBM Approvals from getting archived 
    // @future
    public static void updateLoanApprovals(Id[] listOfLoanApp){
        // Changes as per SFAU-3335 - Update Record Lock Issue - Mohit
        Set<Id> approvalsToArchive = new map<Id, Loan_Application_Approval__c>([SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c IN:listOfLoanApp AND Approval_Type__c != 'RBMTatkal' AND Archived__c=false]).keySet();

        if(!approvalsToArchive.isEmpty()){
            archiveApprovalsAsync(approvalsToArchive);
        }
    }

    /**
     * Marks Archived__c true for records that were created with last BRE assignment
     * Changes as per SFAU-3335 - Update Record Lock Issue - Mohit
     */
    @future
    public static void archiveApprovalsAsync(Set<Id> approvalIds){
        Loan_Application_Approval__c[] approvalRecordToArchive = new Loan_Application_Approval__c[0]; 

        for(Id approvalId: approvalIds){
            approvalRecordToArchive.add(
                new Loan_Application_Approval__c(
                    Id = approvalId,
                    Archived__c = true
                )
            );
        }
        System.debug(' === approvalRecordToArchive ==> ' + JSON.serializePretty(approvalRecordToArchive));
        update approvalRecordToArchive;
    }
    
    public class wrapper{
        public Map<String,List<String>> mapOfFieldVsValues;
        public Map<String,String> mapOfLoanIddVsCollateralName;
        public Map<String,String> mapOfLoanIdVsCustGrade;
        public Map<String,String> mapOfLoanIdVsTypeOfEmpl;
        public Map<String,String> mapOfLoanIdVsProduct;
    }
}