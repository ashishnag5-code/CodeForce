/*****
 * Class Name: LoanApplicationApprovalTriggerHandler
 * Description: 
 * Test Class Name: LoanApplicationApprovalTriggerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-04-2023          -   Mohit M.            -   SFAU-5677 - Credit Issues - Credit Approval Level
 * Dec-13-2023          -   Sachin.            -   R2-666 - Commercial / Tractor - Move to PSD after Pricing approval
 * Dec-19-2023          -   Mohit M.            -   SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
 */
public without sharing class LoanApplicationApprovalTriggerHandler {
    public static Set<String> loanTypesToMovePSDAfterBMApproval = new Set<String>{ GlobalConstants.FOURWHEELER, GlobalConstants.TRACTOR, GlobalConstants.COMMERCIALVEHICLE, GlobalConstants.CONSTRUCTIONEQUIP };
    public static Id tarRecType = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('TAR').getRecordTypeId();

    public static void populateAdditionalFields(Loan_Application_Approval__c[] approvals){
        LoanApplicationApprovalTriggerHelper.populateAdditionalFieldsFromLoanApp(approvals);
    }

    public static void getBaseApprover(List<Loan_Application_Approval__c> newListLoanApp){
        Map<String,List<loan_Application_Approval__c>> mapOfLoanAppVsApprover = new Map<String,List<loan_Application_Approval__c>>();
        Set<String> loanAppId = new Set<String>();
        Set<String> allLoandIds = new Set<String>();
        for(Loan_Application_Approval__c loanApp:newListLoanApp){
            allLoandIds.add(loanApp.Loan_Application__c);
            if( /*loanApp.type__c=='Base' &&*/ loanApp.Approval_Type__c =='Credit' && !loanApp.Archived__c && loanApp.Approval_Status__c == GlobalConstants.APPROVAL_STATUS_PENDING ){
                if(mapOfLoanAppVsApprover.containsKey(loanApp.Loan_Application__c)){
                    mapOfLoanAppVsApprover.get(loanApp.Loan_Application__c).add(loanApp);
                    loanAppId.add(loanApp.Loan_Application__c);
                }else{
                    List<loan_Application_Approval__c> listOfApproverIds = new List<loan_Application_Approval__c>();
                    listOfApproverIds.add(loanApp);
                    mapOfLoanAppVsApprover.put(loanApp.Loan_Application__c,listOfApproverIds);
                }
            } 
            
        }
        
        Map<String,Integer> mapOfApproverVsCount = new Map<String,Integer>();
        for(AggregateResult appr:[select count(Id)cnt, Approver__c from loan_Application_Approval__c where Loan_Application__c In :loanAppId AND Archived__c=false group by Approver__c]){
            String approver =(String)appr.get('Approver__c');
            Integer count = Integer.valueOf(appr.get('cnt'));
            mapOfApproverVsCount.put(approver,count);
        } 
        List<loan_Application_Approval__c> listOfLoanAppr = new List<loan_Application_Approval__c>();
        for(String lp:mapOfLoanAppVsApprover.keySet()){
            List<loan_Application_Approval__c> listOfApprovers = mapOfLoanAppVsApprover.get(lp);
            if(listOfApprovers.size()>1){
                Integer count;
                loan_Application_Approval__c approvalObj;
                for(loan_Application_Approval__c lApp: listOfApprovers){
                    if(lApp.Approver__c!=null){
                        if(count ==null){
                            count = mapOfApproverVsCount.get(lApp.Approver__c);
                            approvalObj = lApp;
                            system.debug('count >>'+count);
                            system.debug('approvalObj count in null>>'+approvalObj);
                        }
                        if(count!=null && count>mapOfApproverVsCount.get(lApp.Approver__c)){
                            count = mapOfApproverVsCount.get(lApp.Approver__c);
                            approvalObj = lApp;
                            system.debug('count >>'+count);
                            system.debug('approvalObj count not null >>'+approvalObj);
                        }
                    }
                }
                listOfLoanAppr.add(approvalObj);
                system.debug('count >>'+count);
            }else{
                listOfLoanAppr.addAll(mapOfLoanAppVsApprover.get(lp));
            }
            system.debug('listOfLoanAppr >>'+listOfLoanAppr);
        }
        if(!mapOfLoanAppVsApprover.isEmpty()){
            LoanApplicationApprovalTriggerHelper.updateBaseApprover(mapOfLoanAppVsApprover);
        }
        
        // if(allLoandIds.size()>0){
        //     LoanApplicationApprovalTriggerHelper.stampProductLabelAndApplicant(allLoandIds,newListLoanApp);
        // }
        LoanApplicationApprovalTriggerHelper.updateComments(newListLoanApp);
    }
    
    public static void updateLoanApplicationApproved(List<Loan_Application_Approval__c> newListApproval, Map<Id,Loan_Application_Approval__c> oldMap){
        LoanApplicationApprovalTriggerHelper.assignNextApprover(oldMap,newListApproval);
        Set<String> settOfCreditApproverIds = new Set<String>();
        Set<String> settOfPricingApproverIds = new Set<String>();
        Set<String> settOf2WPricingApproverIds = new Set<String>();
        Set<String> settOfRejectedApproverIds = new Set<String>();
        List<String> settOfRejectedPricingApproverIds = new List<String>();
        Set<String> setOfPendingApprovalIds = new Set<String>();
        Set<String> setOfCancelledApprovedLoanIds = new Set<String>();
        Map<String, STring> approvedLoanRemarks = new Map<String, String>();
        // Set<Id> loanApplicationsToRework = new Set<Id>();
        for(Loan_Application_Approval__c loanApr :newListApproval){
            if(!loanApr.Archived__c && loanApr.Approval_Status__c =='Approved' && oldMap.get(loanApr.Id).Approval_Status__c !='Approved'){
                // SFAU - 3500 - RCM Approval needed at PSD
                if(loanApr.Approval_Type__c=='Credit' && loanApr.Loan_Application_Stage__c != GlobalConstants.STAGE_PSD){
                    settOfCreditApproverIds.add(loanApr.Loan_Application__c);
                }else if(loanApr.Approval_Type__c=='Pricing' && loanTypesToMovePSDAfterBMApproval.contains( loanApr.Loan_Type__c ) ){
                    settOfPricingApproverIds.add(loanApr.Loan_Application__c);
                }
                else if(loanApr.Approval_Type__c=='Pricing' && loanApr.Loan_Type__c == 'Two Wheeler'){
                    settOf2WPricingApproverIds.add(loanApr.Loan_Application__c);
                }
                if(String.isNotBlank(loanApr.Remarks__c) || loanApr.Remarks__c!=null){
                    approvedLoanRemarks.put(loanApr.Loan_Application__c, loanApr.Remarks__c); // Updating the comments
                }
                
                
                
            }
            //Pricing Reject from Email
            if(loanApr.Approval_Status__c =='Rejected' && oldMap.get(loanApr.Id).Approval_Status__c !='Rejected' && loanApr.Loan_Application_Stage__c == 'Pricing'){
                settOfRejectedPricingApproverIds.add(loanApr.Loan_Application__c);
            }
            // SFAU - 3500 - RCM Approval needed at PSD
            if(loanApr.Approval_Status__c =='Rejected' && oldMap.get(loanApr.Id).Approval_Status__c !='Rejected' && String.isBlank(loanApr.Document_Name__c) && loanApr.Loan_Application_Stage__c != GlobalConstants.STAGE_PSD && loanApr.Loan_Application_Stage__c != 'Pricing'){
                settOfRejectedApproverIds.add(loanApr.Loan_Application__c);
            }
            if(loanApr.Is_Assigned_Approver__c ==true && oldMap.get(loanApr.Id).Is_Assigned_Approver__c ==false && 
               loanApr.Approval_Status__c =='Pending'){
                setOfPendingApprovalIds.add(loanApr.Id);
            }
            /*if(loanApr.Loan_Type__c == GlobalConstants.TWO_WHEELER && loanApr.Approval_Status__c == GlobalConstants.PENDING && loanApr.Is_Rework__c && loanApr.Is_Rework__c != oldMap.get(loanApr.Id).Is_Rework__c){
                loanApplicationsToRework.add( loanApr.Loan_Application__c );
            }*/
        }
        
        
        if(setOfPendingApprovalIds.size()>0){
            system.debug('setOfPendingApprovalIds '+setOfPendingApprovalIds);
            //LoanApplicationApprovalTriggerHelper.submitForApproval(setOfPendingApprovalIds);//Pricing Approved
        }
        if(settOfCreditApproverIds.size()>0){
           // LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOfCreditApproverIds,'Credit Approved','Pricing','Credit');//Pricing Approved
            LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOfCreditApproverIds,'Credit Approved','Pricing','Credit',approvedLoanRemarks);
        }
        if(settOfPricingApproverIds.size()>0){
            //LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOfPricingApproverIds,'Pricing Approved','PSD','Pricing');
            LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOfPricingApproverIds,'Pricing Approved','PSD','Pricing',approvedLoanRemarks);
        }
        if(settOf2WPricingApproverIds.size()>0){
           // LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOf2WPricingApproverIds,'Pricing Approved','DDE','Pricing');
           LoanApplicationApprovalTriggerHelper.updateLoanApplications(settOf2WPricingApproverIds,'Pricing Approved','DDE','Pricing', approvedLoanRemarks);
        }
        if(settOfRejectedApproverIds.size()>0){
            LoanApplicationApprovalTriggerHelper.rejectLoanApplications(settOfRejectedApproverIds);
        }
        if(settOfRejectedPricingApproverIds.size()>0){
            AUSFApproverController.sendBackToRoLoanApplication(settOfRejectedPricingApproverIds[0],'');
        }
        /*if(!loanApplicationsToRework.isEmpty()){
            LoanApplicationApprovalTriggerHelper.sendLoanApplicationForReWork(loanApplicationsToRework);
        }*/
        LoanApplicationApprovalTriggerHelper.populateComments( newListApproval, oldMap );
    }

    @future
    public static void updateLoanApprovals(List<Id> listOfLoanApp){
        List<Loan_Application_Approval__c> listOfApprovals = new List<Loan_Application_Approval__c>(); 
        For(Loan_Application_Approval__c loanApp:[SELECT Id,Archived__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:listOfLoanApp AND Archived__c=false WITH SECURITY_ENFORCED]){
            loanApp.Archived__c = true;
            listOfApprovals.add(loanApp);
        }
        
        update listOfApprovals;
    }

    public static void createBSRAssignmentRecord(List<Loan_Application_Approval__c> loanApprovalList){
        List<Id> loanIds = new List<Id>();
        
        List<Id> loanAppsToBeDeleted = new List<Id>();
        List<Assignment__c> assignmentList = new List<Assignment__c>();
        Map<String,String> mapOfLoanIdToAssignmentId = new Map<String,String>();
        for(Loan_Application_Approval__c loanApp : loanApprovalList){
            loanIds.add(loanApp.Loan_Application__c);
        }
        Map<Id,Loan_Application__c> mapOfIdToLoan = new Map<Id,Loan_Application__c>([SELECT Id,Application_Id__c,Product__c FROM Loan_Application__c WHERE Id IN :loanIds]);
        List<Assignment__c> listOfExistingAssignment = [SELECT Id,Loan_Application__c FROM Assignment__c WHERE Loan_Application__c IN :loanIds AND RecordType.Name='Credit - BSR/ PSL'];
        for(Assignment__c obj: listOfExistingAssignment){
            mapOfLoanIdToAssignmentId.put(obj.Loan_Application__c,obj.Id);
        }

        for(Loan_Application_Approval__c loanApp : loanApprovalList){
            if(loanApp.BSR_PSL__c==true){
                loanAppsToBeDeleted.add(loanApp.Id);
                Assignment__c assignment = new Assignment__c();
                assignment.Status__c = 'Pending';
                assignment.Loan_Application__c = loanApp.Loan_Application__c;
                assignment.Name = mapOfIdToLoan.get(loanApp.Loan_Application__c).Application_Id__c;
                ProductRTMap__mdt objProductRTMap = ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+mapOfIdToLoan.get(loanApp.Loan_Application__c).Product__c);
                assignment.Product__c = objProductRTMap.Label;
                assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Credit - BSR/ PSL').getRecordTypeId();
                assignment.OwnerId = loanApp.Approver__c;
                if(mapOfLoanIdToAssignmentId.containsKey(loanApp.Loan_Application__c)){
                    assignment.Id = mapOfLoanIdToAssignmentId.get(loanApp.Loan_Application__c);
                }
                assignmentList.add(assignment);
            }
        }
        try{
            upsert assignmentList;
            deleteApprovalRecord(loanAppsToBeDeleted);
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
        }
        
    }

    @future
    public static void deleteApprovalRecord(List<Id> listToBeDeleted){
        try{
            List<Loan_Application_Approval__c> loanAppList = [SELECT Id FROM Loan_Application_Approval__c WHERE Id IN :listToBeDeleted];
            delete loanAppList;
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
        }
    }

    public static void handleTAT(List<Loan_Application_Approval__c> newRecords, Map<Id, Loan_Application_Approval__c> oldRecordsMap) {
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        for (Loan_Application_Approval__c each : newRecords) {
            if (oldRecordsMap == null || (each.Approval_Status__c != oldRecordsMap.get(each.Id).Approval_Status__c ||
                each.Approver__c != oldRecordsMap.get(each.Id).Approver__c || each.Assigned_to_Queue__c != oldRecordsMap.get(each.Id).Assigned_to_Queue__c ||
                each.Is_Assigned_Approver__c != oldRecordsMap.get(each.Id).Is_Assigned_Approver__c)) {
                Loan_Application_Approval__c newLoanApp = new Loan_Application_Approval__c(Id = each.Id, Approver__c = each.Approver__c, Assigned_to_Queue__c = each.Assigned_to_Queue__c,
                    Approval_Status__c = each.Approval_Status__c, Loan_Application__c = each.Loan_Application__c, Remarks__c = each.Remarks__c, Is_Assigned_Approver__c = each.Is_Assigned_Approver__c,
                    Approval_Type__c = each.Approval_Type__c, Document_Name__c = each.Document_Name__c, Forwarded_By__c = each.Forwarded_By__c, Forwarded_By_Remarks__c = each.Forwarded_By_Remarks__c);
                Loan_Application_Approval__c oldLoanApp = null;
                if (oldRecordsMap != null) {
                    oldLoanApp = new Loan_Application_Approval__c(Id = each.Id, Approver__c = oldRecordsMap.get(each.Id).Approver__c, Assigned_to_Queue__c = oldRecordsMap.get(each.Id).Assigned_to_Queue__c,
                        Approval_Status__c = oldRecordsMap.get(each.Id).Approval_Status__c, Loan_Application__c = oldRecordsMap.get(each.Id).Loan_Application__c,
                        Remarks__c = oldRecordsMap.get(each.Id).Remarks__c, Is_Assigned_Approver__c = oldRecordsMap.get(each.Id).Is_Assigned_Approver__c, Approval_Type__c = oldRecordsMap.get(each.Id). Approval_Type__c, Document_Name__c = oldRecordsMap.get(each.Id). Document_Name__c,
                        Forwarded_By__c = oldRecordsMap.get(each.Id).Forwarded_By__c, Forwarded_By_Remarks__c = oldRecordsMap.get(each.Id).Forwarded_By_Remarks__c);
                }
                tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(newLoanApp), Object_API_Name__c = 'Loan_Application_Approval__c',
                    Old_Records_Payload__c = oldLoanApp == null ? null : JSON.serialize(oldLoanApp), Event_Date_Time__c = Datetime.now(), Logged_In_User__c = UserInfo.getUserId()));
            }
        }
        System.debug(' === TAT Events ===> ' + JSON.serializePretty(tatEvents));
        if (!tatEvents.isEmpty()) {
            Eventbus.publish(tatEvents);
        }
    }
    /**
    * Sachin - Give edit access to the approver to whom the approval has been assigned
     */
    public static void allowApproverEditAccess( Loan_Application_Approval__c[] approvals, map<Id, Loan_Application_Approval__c> approvalMap ){
        Loan_Application_Approval__c[] approvalsToShare = new Loan_Application_Approval__c[0];
        Set<Id> loanId4WSet = new Set<Id>();
        List<Loan_Application_Approval__c> approvals4W = new List<Loan_Application_Approval__c>();
        for(Loan_Application_Approval__c approval: approvals){
            if( approval.Approval_Type__c == GlobalConstants.APPROVAL_TYPE_CREDIT && approval.Is_Assigned_Approver__c && approval.Is_Assigned_Approver__c != approvalMap.get(approval.Id).Is_Assigned_Approver__c ){
                approvalsToShare.add( approval );
                if( loanTypesToMovePSDAfterBMApproval.contains( approval.Loan_Type__c ) ){
                    loanId4WSet.add(approval.Loan_Application__c);
                    approvals4W.add(approval);
                }
            }
        }
        if( !approvalsToShare.isEmpty() ){
            LoanApplicationApprovalTriggerHelper.shareLoanApplicationWithApprover( approvalsToShare );
        }
        //3838
        if(!approvals4W.isEmpty()){
            try{
                LoanApplicationApprovalTriggerHelper.shareRecordsWithCreditApprovers(loanId4WSet,approvals4W);
            }catch(Exception objException){
                Log.error(objException,Log.SeverityType.valueOf('High'),null);
            }
            
        }
    }
    public static void delegateApproval(Loan_Application_Approval__c[] newApprovals, map<Id, Loan_Application_Approval__c> oldAppprovals){
        Set<Id> loanIds = new Set<Id>();
        for( Loan_Application_Approval__c approval: newApprovals ){
            loanIds.add( approval.Loan_Application__c );
        }

        Set<Id> userIdsWithDelegation = new Set<Id>();
        for(Loan_Application_Approval__c approval: newApprovals){
            userIdsWithDelegation.add(approval.Approver__c);
        }
        userIdsWithDelegation.remove( null );

        map<Id, Id> usersWithdelegations = new map<Id, Id>();
        for(User usr: [ SELECT Id, DelegatedApproverId FROM User WHERE Id IN: userIdsWithDelegation AND DelegatedApproverId != NULL AND IsActive != FALSE ]){
            usersWithdelegations.put( usr.Id, usr.DelegatedApproverId );
        }

        if(usersWithDelegations.isEmpty()) return;

        map<Id, AccountTeamMember> delegatedApprovers = new map<Id, AccountTeamMember>();
        for( AccountTeamMember atm: [ SELECT UserId, Approver_Level__c, Deviation_Level__c FROM AccountTeamMember WHERE UserId IN: usersWithDelegations.values() AND User.IsActive = true ]){
            delegatedApprovers.put( atm.UserId, atm );
        }
        Loan_Application_Approval__c[] delegatedApprovals = new Loan_Application_Approval__c[0],
            approvalsToDelegate = new Loan_Application_Approval__c[0];
        map<Id, Loan_Application_Approval__c[]> pricingApprovals = new map<Id, Loan_Application_Approval__c[]>();
        map<Id, Loan_Application_Approval__c[]> loanApplicationApprovals = new map<Id, Loan_Application_Approval__c[]>();
        map<Id, Loan_Application_Approval__c[]> rbmTatkalApprovals = new map<Id, Loan_Application_Approval__c[]>();
        for( Loan_Application_Approval__c approval: [ SELECT Id, Loan_Application_Stage__c, Loan_Application__c, Approver_Level__c, Deviation_Level__c, Type__c, Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIds AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE ORDER BY Approver_Level__c, Deviation_Level__c NULLS LAST ]){
            String approvalType = approval.Approval_Type__c;
            if( approvalType == GlobalConstants.APPROVAL_TYPE_PRICING ){
                if( !pricingApprovals.containsKey( approval.Loan_Application__c ) ){
                    pricingApprovals.put( approval.Loan_Application__c, new Loan_Application_Approval__c[0] );
                }
                pricingApprovals.get( approval.Loan_Application__c ).add( approval );
            }

            if( approvalType == 'RBMTatkal' ){
                if( !rbmTatkalApprovals.containsKey( approval.Loan_Application__c ) ){
                    rbmTatkalApprovals.put( approval.Loan_Application__c, new Loan_Application_Approval__c[0] );
                }
                rbmTatkalApprovals.get( approval.Loan_Application__c ).add( approval );
            }

            // keeps approvals needed based on type of approval being delegated
            // if(approval.Approval_Type__c != approvalType) continue;
    
            if(!loanApplicationApprovals.containsKey( approval.Loan_Application__c )){
                loanApplicationApprovals.put( approval.Loan_Application__c, new Loan_Application_Approval__c[0] );
            }
            loanApplicationApprovals.get( approval.Loan_Application__c ).add ( approval );
        }

        // SFAU-
        map<String, map<Id, Loan_Application_Approval__c[]>> approvalsByType = new map<String, map<Id, Loan_Application_Approval__c[]>>{
            GlobalConstants.APPROVAL_TYPE_PRICING => pricingApprovals,
            'RBMTatkal' => rbmTatkalApprovals
        };

        if( !usersWithdelegations.isEmpty() ){
            Boolean isInsert = oldAppprovals == NULL;
            for( Loan_Application_Approval__c approval: newApprovals ){
                if((isInsert || approval.Approver__c != oldAppprovals.get(approval.Id).Approver__c) && usersWithdelegations.containsKey(approval.Approver__c) ){
                    Loan_Application_Approval__c approvalToDelegate = new Loan_Application_Approval__c( Id = approval.Id, Is_Delegated__c = true ); // mark approval as delegated

                    Loan_Application_Approval__c delegatedApproval = approval.clone( false, false, false, false );
                    delegatedApproval.Approver__c = usersWithdelegations.get(approval.Approver__c);
                    delegatedApproval.Delegated_Approval__c = approval.Id;
                    // Delegated authority can approve based on his level
                    // SFAU-3828 - 19/07/2023 | 4W - Map correct approval level to delegated approval
                    if( delegatedApprovers.containsKey(usersWithdelegations.get(approval.Approver__c))){
                        String approvalType = approval.Approval_Type__c;
                        AccountTeamMember delegatedMember = delegatedApprovers.get(usersWithdelegations.get(approval.Approver__c));
                        delegatedApproval.Approver_Level__c = delegatedMember.Approver_Level__c;
                        delegatedApproval.Deviation_Level__c = delegatedMember.Deviation_Level__c;
                        // SFAU-5677 - Credit Issues - Credit Approval Level
                        delegatedApproval.Type__c = AUSFApproverController.getApproverApprovalAuthority(
                            approvalsByType.containsKey( approvalType ) ? approvalsByType.get( approvalType ).get( approval.Loan_Application__c ) : loanApplicationApprovals.containsKey( approval.Loan_Application__c ) ? loanApplicationApprovals.get( approval.Loan_Application__c ) : new Loan_Application_Approval__c[0],
                            // loanApplicationApprovals.containsKey( approval.Loan_Application__c ) ? approvalType == GlobalConstants.APPROVAL_TYPE_CREDIT ? loanApplicationApprovals.get( approval.Loan_Application__c ) : pricingApprovals.get( approval.Loan_Application__c ): new Loan_Application_Approval__c[0],
                            approval.Approval_Type__c == GlobalConstants.APPROVAL_TYPE_CREDIT ? GlobalConstants.APPROVAL_TYPE_CREDIT : GlobalConstants.APPROVAL_TYPE_PRICING,
                            delegatedMember.Approver_Level__c + ( String.isNotBlank(delegatedMember.Deviation_Level__c) ? delegatedMember.Deviation_Level__c : '' ), false, NULL
                        );
                        delegatedApproval.Remarks__c = null;
                    }
                    delegatedApprovals.addAll(
                        new Loan_Application_Approval__c[]{
                            delegatedApproval, // Approval for delegated user with lookup to the actual approval
                            approvalToDelegate
                        }
                    );
                }
            }
            upsert delegatedApprovals;

        }
    }


    //Notification on Credit Base [DDE Submission]
    public static void sendNotificationtoCreditBase(List<Loan_Application_Approval__c> newRecords){
        String loanId='';
        List<Loan_Application_Approval__c> creditBaseApprovalRecords =  new List<Loan_Application_Approval__c>();
        for (Loan_Application_Approval__c approvalInstance : newRecords) {
            loanId = approvalInstance.Loan_Application__c;
            if( approvalInstance.Approval_Type__c == 'Credit' && approvalInstance.Type__c == 'Base'){
                creditBaseApprovalRecords.add(approvalInstance);
            }
        }
        
        String record = (!creditBaseApprovalRecords.isEmpty() &&  creditBaseApprovalRecords.size()>0 ) ? JSON.serialize(creditBaseApprovalRecords) :null;
        if(String.isNotBlank(record)){
           // NotificationHandler.sendNotification('DDE Submission',loanId,'');
            Notification_Event__e notificationEvent2 = new Notification_Event__e();
            notificationEvent2.sObjectId__c = loanId;
            notificationEvent2.Trigger_Point__c = 'DDE Submission';
            EventBus.publish(notificationEvent2);
        }

    }

    //SFAU-5179
    public static void validateSubmitForApproval (Map<Id,Loan_Application_Approval__c> oldMap,  List<Loan_Application_Approval__c> newRecords) {
        Set<String> approvalIds = new Set<String>();
        Set<Id> setLoanAppId = new Set<Id>();
        for (Loan_Application_Approval__c objApproval : newRecords) {
            if (objApproval.Is_Assigned_Approver__c && oldMap.get(objApproval.Id).Is_Assigned_Approver__c != objApproval.Is_Assigned_Approver__c && objApproval.Assigned_to_Queue__c == false && objApproval.Archived__c == false && objApproval.Approval_Status__c == 'Pending') {
                approvalIds.add( objApproval.Id );
                setLoanAppId.add(objApproval.Loan_Application__c);
            }
        }

        if(!approvalIds.isEmpty()){
            LoanApplicationApprovalTriggerHelper.submitForApproval( approvalIds, setLoanAppId );
        }
    }

    public static void populateApproverforTAR(List<Loan_Application_Approval__c> newRecords, 
        Map<Id,Loan_Application_Approval__c> oldMap){
        for(Loan_Application_Approval__c laa: newRecords){
            if(laa.RecordTypeId == tarRecType && laa.Approval_Status__c <> oldMap.get(laa.id).Approval_Status__c && (laa.Approval_Status__c == 'Approved' || laa.Approval_Status__c == 'Rejected')){
                laa.Approver__c = UserInfo.getUserId();
            }
        }
    }

    // SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
    public static void afterInsert (List<Loan_Application_Approval__c> lstApproval) {
        Map<Id,List<Id>> mapShareSanctionedWithLoan = new Map<Id,List<Id>>();
        for (Loan_Application_Approval__c objApproval : lstApproval) {
            if (objApproval.Approver__c != NULL){
                if (!mapShareSanctionedWithLoan.containsKey(objApproval.Loan_Application__c)) {
                    mapShareSanctionedWithLoan.put(objApproval.Loan_Application__c,new List<Id>());
                }
                mapShareSanctionedWithLoan.get(objApproval.Loan_Application__c).add(objApproval.Approver__c);
            }
        }
        if (!mapShareSanctionedWithLoan.isEmpty()) {
            shareSanctionCondition (mapShareSanctionedWithLoan,'Credit');
        }
    }

    // SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
    public static void afterUpdate (List<Loan_Application_Approval__c> lstApproval, Map<Id,Loan_Application_Approval__c> mapOldApproval) {
        Map<Id,List<Id>> mapShareSanctionedWithLoan = new Map<Id,List<Id>>();
        for (Loan_Application_Approval__c objApproval : lstApproval) {
            if (objApproval.Approver__c != NULL && mapOldApproval.get(objApproval.Id).Approver__c != objApproval.Approver__c){
                if (!mapShareSanctionedWithLoan.containsKey(objApproval.Loan_Application__c)) {
                    mapShareSanctionedWithLoan.put(objApproval.Loan_Application__c,new List<Id>());
                }
                mapShareSanctionedWithLoan.get(objApproval.Loan_Application__c).add(objApproval.Approver__c);
            }
        }
        if (!mapShareSanctionedWithLoan.isEmpty()) {// Mayur check
            shareSanctionCondition (mapShareSanctionedWithLoan,'Credit');
        }
    }
    
    // SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
    public static void shareSanctionCondition (Map<Id,List<Id>> mapShareSanctionedWithLoan, String strSanctiontype) {
        List<Sanction_Condition__c> lstSanCondition = new List<Sanction_Condition__c>();
        List<Sanction_Condition__Share> shareRecords = new List<Sanction_Condition__Share>();
        lstSanCondition = [Select Id, Loan_Application__c from Sanction_Condition__c where Loan_Application__c in: mapShareSanctionedWithLoan.keySet() AND Sanction_Type__c =: strSanctiontype];
        for (Sanction_Condition__c objSanCondition : lstSanCondition) {
            for (Id objId : mapShareSanctionedWithLoan.get(objSanCondition.Loan_Application__c)) {
                Sanction_Condition__Share shareRec = SanctionTriggerHelper.shareSanctionRecords (objSanCondition.Id, objId);
                shareRecords.add(shareRec);
            }
        }
        if(!shareRecords.isEmpty()){
            if(!Test.isRunningTest()){
                database.insert(shareRecords,false);
            }
        }
    }
}