/*****
 * Class Name: AUSFApproverController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Aug-23-2023          -   Mohit M.            -   SFAU-4968 | SFAU-4969
 * Sept-13-2023         -   Sachin              -   SFAU-4005 | 2W Approver can be till L7
 * Sept-22-2023         -   Mohit M.            -   SFAU-5014
 * Sept-25-2023         -   Sachin              -   SFAU-5014 - Removed additional changes added
 * 4th Oct 2023         -   Sachin              -   SFAU-5012 - The approval record for RO Rejection should get archived once the case has been relooked
 * 5th-OCT-2023         -   Sachin              -   Case when picked from authority less than highest gets incorrect Level
 * Dec-04-2023          -   Mohit M.            -   SFAU-5677 - Credit Issues - Credit Approval Level
 * 7th-DEC-2023         -   Sachin              -   Implemented Credit features for R2 Products ( Tractor / Commercial vehicles )
 * Dec-20-2023          -   Mohit M.            -   SFAU-5622 - Add User.IsActive check
 * Dec-20-2034          -   Mohit M.            -   SFAU-5636 - CUG || Send back and reversal view (Send Back / Forward )
 */
public without sharing class AUSFApproverController {
    public static final String[] TW_APPROVAL_LEVELS {
        // SFAU-4005
        get { return Approver_Deviation_Level_Mapping__mdt.getInstance('ApprovalLevel2W')?.Level_Mapping__c?.split(','); }
        set;
    }

    public static final String[] ELIGIBLE_ACCEPT_STATUS = new String[]{ 'Pending' };
    public static final String[] ELIGIBLE_APPROVAL_STAGES = new String[]{ 'Credit', 'PSD' };
    public static final String APPROVAL_TYPE_REASSIGN = 'Reassign';
    public static final String APPROVAL_TYPE_FORWARD = 'Forward';
    public static final String[] REJECTED_APPROVAL_STATUS = new String[]{
        'Credit Rejected',
        'Pricing Rejected'
    };
    public static String[] ELIGIBLE_RELOOK_STAGES = new String[]{ 'Rejected', 'Credit' };

    @AuraEnabled
    public static wrapperApprover getApproverList(String loanAppId, Loan_Application_Approval__c approvalRecord) {
        System.debug(' == approvalRecord ==> ' + JSON.serializePretty(approvalRecord));
        wrapperApprover wrap = new wrapperApprover();
        Map<String,List<Loan_Application_Approval__c>> mapOfTypeVsApprovers = new Map<String,List<Loan_Application_Approval__c>>();
        String typeOfCurrentApprover;
        String currentApproverId = userinfo.getUserId();
        User objCurrentUser = [Select Id,Authority_Level__c from User where Id=:currentApproverId limit 1];
        List<String> listOfType = new List<String>();
        List<String> approvalIds = new List<String>();
        List<Loan_Application_Approval__c> approverList = new List<Loan_Application_Approval__c>();
        List<Loan_Application_Approval__c> listOfAllApprovers = new List<Loan_Application_Approval__c>();
        String approvalType;
        Loan_Application__c loanApp =[SELECT Id,Stage__c,BRE_Decision__c,RecordType.Name FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];

        if(loanApp.Stage__c == GlobalConstants.REJECTED) throw new AUSFApproverException('This application has been rejected already. Please refresh and try again.');

        if(ELIGIBLE_APPROVAL_STAGES.contains(loanApp.Stage__c)){
            approvalType = 'Credit';
            //recordTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('Credit Approver').getRecordTypeId();
        }else if(loanApp.Stage__c=='Pricing'){
            approvalType = 'Pricing';
            //recordTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('Pricing Approver').getRecordTypeId();
        }
        Set<Id> tobeApprovedIds = new Set<Id>();
        // SFAU-5636 Add Is_Forward__c field
        For(Loan_Application_Approval__c lp:[SELECT Id,Type__c,Approver__r.Name,Is_Assigned_Approver__c,Approval_Status__c, Is_Forward__c  
                                             FROM Loan_Application_Approval__c WHERE Approval_Status__c!='Send Back To RO' AND Approval_Status__c!='Rejected' AND Approval_Status__c!='Approved' AND (Approval_Status__c !=: GlobalConstants.APPROVAL_STATUS_FORWARDED OR Is_Forward__c = true) AND loan_Application__c=:loanAppId AND Approval_Type__c =:approvalType AND Archived__c=false WITH SECURITY_ENFORCED]){
                                                 
                                                 if(lp.Approver__c == currentApproverId){
                                                    approvalIds.add(lp.Id);
                                                     if(lp.Type__c!=null){
                                                         listOfType.add(lp.Type__c);
                                                     }
                                                 }
                                                 if(lp.Is_Assigned_Approver__c == true && (lp.Approval_Status__c=='Pending')){
                                                    //  approvalIds.add(lp.Id);
                                                     approverList.add(lp);
                                                     //currentApproverRec.add(lp);                               
                                                 }
                                                     if(lp.Approval_Status__c!='Approved'){
                                                         listOfAllApprovers.add(lp);  
                                                     }
                                                  
                                                 system.debug('lp '+lp);
                                                 if(lp.Type__c!=null){
                                                     system.debug('in 1st if');
                                                     if(mapOfTypeVsApprovers.containsKey(lp.Type__c)){
                                                         mapOfTypeVsApprovers.get(lp.Type__c).add(lp);
                                                     }else{
                                                         List<Loan_Application_Approval__c> listOfApprover = new List<Loan_Application_Approval__c>();
                                                         listOfApprover.add(lp);
                                                         mapOfTypeVsApprovers.put(lp.Type__c,listOfApprover);
                                                     } 
                                                 }
                                                 
                                             }
        String leveType = getNextType(listOfType);
        if(loanApp.BRE_Decision__c == 'STP'){
            leveType = 'ALL';
        }
        String currentLevel = getCurrentUserType(listOfType);
        X2W_Approval_Assignem_Switch__mdt  sw =X2W_Approval_Assignem_Switch__mdt.getInstance('Queue_Based_Assignment');
        if(sw.Assignment_Switch__c && loanApp.RecordType.Name == 'Two Wheeler' && approvalType == 'Credit' && objCurrentUser.Authority_Level__c != null){
            Integer userLevel = Integer.valueOf(objCurrentUser.Authority_Level__c.subString(1,objCurrentUser.Authority_Level__c.length()));
            Loan_Application_Approval__c loanAppApproval = [SELECT Id,Type__c,Required_Approver_Level__c,Approver__r.Name,Is_Assigned_Approver__c,Approval_Status__c 
                                             FROM Loan_Application_Approval__c WHERE Approval_Status__c!='Send Back To RO' AND Approval_Status__c!='Rejected' AND Approval_Status__c!='Forwarded' 
                                             AND Approval_Status__c!='Approved' AND loan_Application__c=:loanAppId AND Approval_Type__c =:approvalType AND Archived__c=false WITH SECURITY_ENFORCED limit 1];
            Integer appovalLevel = Integer.valueOf(loanAppApproval.Required_Approver_Level__c.subString(1,objCurrentUser.Authority_Level__c.length()));            
            if(userLevel >= appovalLevel){
                loanAppApproval.Approval_Status__c = 'Approved';
                loanAppApproval.Button_Approval__c = true;
                loanAppApproval.Remarks__c = approvalRecord?.Remarks__c;
                wrap.isFinalApproval = true;

                Loan_Application_Approval__c[] delegatedApproval = [ SELECT Id FROM Loan_Application_Approval__c WHERE Delegated_Approval__c =: loanAppApproval.Id AND Archived__c = FALSE AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: approvalType ];
                if(!delegatedApproval.isEmpty()){
                    delegatedApproval[0].Approval_Status__c = GlobalConstants.APPROVAL_STATUS_APPROVED;
                    update delegatedApproval;
                }
                update loanAppApproval;
            } else {
                throw new AUSFApproverException( 'You don\'t have required Authority to approve this case (Your Authority Level is: ' + objCurrentUser.Authority_Level__c + ')' );
            }
        }
        else{
            if(approvalIds.isEmpty()) throw new AUSFApproverException('Please refresh and try again. The application may already have been approved.');

            if(leveType =='ALL'){
                system.debug('leveType');  
                wrap.isFinalApproval = true;
                approve(approvalIds,'Approve', approvalRecord);
                approveAction(listOfAllApprovers, approvalRecord, approvalIds);
                if(currentLevel=='Highest' && loanApp.Stage__c =='Credit'){
                    NotificationHandler.sendNotification('Credit Submission (N)',loanApp.Id,currentLevel); //credit -highest but pricing base/middle level we will need to check/query 
                    callCreditSanction(loanApp.Id);
                 }
                 if(currentLevel=='Highest' && loanApp.Stage__c =='Pricing'){
                    NotificationHandler.sendNotification('Pricing (N)',loanApp.Id,currentLevel); //credit -highest but pricing base/middle level we will need to check/query 
                 }
                
            }else {
                if(mapOfTypeVsApprovers.containsKey(leveType) && mapOfTypeVsApprovers.get(leveType).size()>1){
                    wrap.loanApprovals = mapOfTypeVsApprovers.get(leveType);  
                }else{
                    if(approvalIds.size()>0){
                        approve(approvalIds,'Approve', approvalRecord);
                    }
                    // Case gets stuck - if Multiple base approval are present
                    if( (new String[]{ 'Base', 'Middle' }).contains(currentLevel) ){
                        if(!approvalIds.contains(currentApproverId)){
                          approveAction(mapOfTypeVsApprovers.get(currentLevel), approvalRecord, approvalIds);
                        }
                    }
                    // - If there's no record with higher authority than the current one being approved ( it is a final approval )
                    if(!mapOfTypeVsApprovers.containsKey(leveType) || (mapOfTypeVsApprovers.containsKey(leveType) && mapOfTypeVsApprovers.get(leveType).isEmpty())){
                        leveType = getNextType( new String[]{ leveType } ); //CUG -- SFAU-4620 - Case not visible to Highest user when middle isn't available and approved by Base.
                        wrap.isFinalApproval = true;
                    }
                    //approveAction(currentApproverRec);
                    if(mapOfTypeVsApprovers.containsKey(leveType) && !mapOfTypeVsApprovers.get(leveType).isEmpty()){
                        Loan_Application_Approval__c loanAppr = mapOfTypeVsApprovers.get(leveType)[0];
                        loanAppr.Is_Assigned_Approver__c = true;
                        loanAppr.Forwarded_By_Remarks__c = approvalRecord?.Remarks__c;
                        // SFAU-5636
                        loanAppr.Is_Forward__c = false;
                        approverList.add(loanAppr);
                        //loanAppr.Approval_Status__c = 'Pending';
                        update loanAppr;
                        //submitForApproval(loanAppr);
                    }
                     //Call the Notification Handler 
                      String approvers = JSON.serialize(approverList);
                     if(approvalType == 'Credit'){
                        if(currentLevel=='Base'){
                            NotificationHandler.sendNotification('Credit Submission(L0)',loanApp.Id,approvers);
                         }
                         if(currentLevel=='Middle'){
                            NotificationHandler.sendNotification('Credit Submission (N-1)',loanApp.Id,approvers);
                         }
                         if(currentLevel=='Highest'){
                            NotificationHandler.sendNotification('Credit Submission (N)',loanApp.Id,currentLevel);
                            callCreditSanction(loanApp.Id); //credit -highest but pricing base/middle level we will need to check/query 
                         }
                     }

                     if(approvalType == 'Pricing'){
                        if(currentLevel=='Middle'){
                            NotificationHandler.sendNotification('Pricing (N-1)',loanApp.Id,currentLevel); //pricing - middle and highest level need to query
                         }
                         if(currentLevel=='Highest'){
                            NotificationHandler.sendNotification('Pricing (N)',loanApp.Id,currentLevel);
                         }
                     }

                    
                }
            }
        }
        system.debug('mapOfTypeVsApprovers '+mapOfTypeVsApprovers);
        system.debug('listOfType '+listOfType);
        
        wrap.currentId = currentApproverId;
        return wrap;
    }
    
    public static String getNextType(List<String> listOfType){
        String returnType;
        if(listOfType.contains('Highest')){
            returnType = 'All';
        }else if(listOfType.contains('Middle')){
            returnType = 'Highest';
        }else if(listOfType.contains('Base')){
            returnType = 'Middle';
        }
        return returnType;
    }
    
    public static String getCurrentUserType(List<String> listOfType){
        String returnType;
        if(listOfType.contains('Highest')){
            returnType = 'Highest';
        }else if(listOfType.contains('Middle')){
            returnType = 'Middle';
        }else if(listOfType.contains('Base')){
            returnType = 'Base';
        }
        return returnType;
    } 
    
    public class wrapperApprover{
        @AuraEnabled public List<Loan_Application_Approval__c> loanApprovals;
        @AuraEnabled public String currentId;
        @AuraEnabled public Boolean isFinalApproval;
    }
    
    public static void approve(List<String> recordIds,String action, Loan_Application_Approval__c currentApprovalRecord){
        List<Loan_Application_Approval__c> updateLoanApprovalList = new List<Loan_Application_Approval__c>();
        for(String ids:recordIds){
            Loan_Application_Approval__c loanApp = new Loan_Application_Approval__c();
            loanApp.Button_Approval__c = true;
            loanApp.Is_Approved_Record__c = true;
            loanApp.Remarks__c = currentApprovalRecord?.Remarks__c;
            loanApp.Id = Ids;
            updateLoanApprovalList.add(loanApp);
        }
        
        update updateLoanApprovalList;
        
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordIds 
        ];
        system.debug('workItems  '+workItems);
        if(workItems.size()>0){
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem workItem : workItems){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                //Valid values are: Approve, Reject, or Removed. 
                //Only system administrators can specify Removed.
                req.setAction(action);
                req.setComments(currentApprovalRecord?.Remarks__c);
                requests.add(req);
            }
            system.debug('requests  '+requests);
            
            Approval.ProcessResult[] processResults = Approval.process(requests);
        }
        
    }
    
    public static void approveAction( List<Loan_Application_Approval__c> listOfAllApprovers, Loan_Application_Approval__c currentApprovalRecord, String[] approvedIds ){
        List<Loan_Application_Approval__c> updateList = new List<Loan_Application_Approval__c>();
        for(Loan_Application_Approval__c loanApproval: listOfAllApprovers){
            loanApproval.Approval_Status__c ='Approved';
            loanApproval.Remarks__c = approvedIds.contains(loanApproval.Id) ? currentApprovalRecord?.Remarks__c : null;
            loanApproval.Button_Approval__c = true;
            updateList.add(loanApproval);
        }
        update updateList;
    }
    
    public static void assignNextApprover(String nextAprId, Loan_Application_Approval__c currentApprovalRecord){
        Loan_Application_Approval__c apr = new Loan_Application_Approval__c();
        apr.Id = nextAprId;
        //apr.Approval_Status__c = 'Pending';
        apr.Is_Assigned_Approver__c = true;
        apr.Forwarded_By_Remarks__c = currentApprovalRecord?.Remarks__c;
        update apr;
    }

    @AuraEnabled
    public static LevelApproverWrapper validateAndAssignForRelook( Id loanId ){
        Loan_Application_Approval__c[] approvalsToUpdate = new Loan_Application_Approval__c[0];
        Loan_Application_Approval__c[] approvals = [
            SELECT Id, Approver__c, Approver_Level__c, Approver__r.Name, Type__c, Approval_Type__c, Is_Assigned_Approver__c, Loan_Application__c, Assigned_to_Queue__c
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =: loanId
            AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT
            AND ( Approver__r.Profile.Name != 'Sales' OR ( Approver__c = NULL AND Assigned_to_Queue__c = TRUE ) )
            AND Archived__c = false
            ORDER BY CreatedDate DESC //: - Approval should go to the last credit user who worked on the case instead of the one who picked / forwarded it
        ];

        // Application has no active approval / RO should be given an option to assign this application to Credit User.
        // Cases when it has either passed credit or was with credit when it was rejected -- the application has to be sent back to the same users.
        if( approvals.isEmpty() ){
            return getLevelVsApprovers( loanId );
        }

        LevelApproverWrapper resp = new LevelApproverWrapper();
        resp.hasActiveApproval = true;

        for( Loan_Application_Approval__c approval: approvals ){
            Loan_Application_Approval__c newApproval = approval.clone( false, false, false, false );
            newApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;

            approvalsToUpdate.addAll(
                new Loan_Application_Approval__c[]{
                    newApproval, new Loan_Application_Approval__c( Id = approval.Id , Archived__c = true )
                }
            );
        }
        Loan_Application_Approval__c activeApproval = approvals[0];
        resp.levels = new String[]{ activeApproval.Approver_Level__c };
        resp.mapOfApproverLevelVsAccountTeam = new map<String, SObject[]>{
            activeApproval.Approver_Level__c => approvals
        };

        // SFAU-5012 | 4th Oct 2023 | The approval record for RO Rejection should get archived once the case has been relooked
        Loan_Application_Approval__c[] roRejectedApprovals = [ SELECT Id FROM Loan_Application_Approval__c WHERE Approver__r.Profile.Name = 'Sales' AND Archived__c = FALSE LIMIT 1 ];
        if( !roRejectedApprovals.isEmpty() ){
            approvalsToUpdate.add(
                new Loan_Application_Approval__c(
                    Id = roRejectedApprovals[0].Id,
                    Archived__c = true
                )
            );
        }
        upsert approvalsToUpdate;

        // CUG :: When the case goes from Rejected to Credit - BRE HAS TO RE RUN
        update new Loan_Application__c( Id = loanId, Stage__c = GlobalConstants.APPROVAL_TYPE_CREDIT, BRE_ReRun_Required__c = true );
        return resp;
    }

    @AuraEnabled
    public static void assignForRelook( Id loanAppId, Id assignTo, String assigneLevel ){
        if(loanAppId == NULL || assignTo == NULL || assigneLevel == NULL )
            throw new AUSFApproverException( 'Invalid details sent for relook. Please contact System Administrator' );

        String approvalType = [ SELECT Stage__c FROM Loan_Application__c WHERE Id =: loanAppId ].Stage__c;
        Loan_Application_Approval__c[] approvalsToRelook = new Loan_Application_Approval__c[0];

        /*for(Loan_Application_Approval__c approvalRecord: [
                SELECT Id, Type__c, Approver_Level__c, Deviation_Level__c, Approver__c, Loan_Application__c, Approval_Type__c, Assigned_to_Queue__c
                FROM Loan_Application_Approval__c
                WHERE Loan_Application__c =: loanAppId AND Approver__c =: assignTo AND Approval_Status__c =: GlobalConstants.REJECTED
                WITH SECURITY_ENFORCED
            ]){
                approvalsToRelook.addAll(
                    new List<Loan_Application_Approval__c>{
                        new Loan_Application_Approval__c( Id = approvalRecord.Id, Archived__c = true ), // old approval record that needs to be Archived
                        new Loan_Application_Approval__c( // new record so that CM can re-look again
                            Type__c = approvalRecord.Type__c,
                            Approver_Level__c = approvalRecord.Approver_Level__c,
                            Deviation_Level__c = approvalRecord.Deviation_Level__c,
                            Approver__c = approvalRecord.Approver__c,
                            Loan_Application__c = approvalRecord.Loan_Application__c,
                            Approval_Type__c = approvalRecord.Approval_Type__c,
                            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                            Assigned_to_Queue__c = false,
                            Is_Assigned_Approver__c = true
                        )
                    }
            );
        }*/
        Loan_Application_Approval__c[] rejectedApprovals = [
                SELECT Id, Type__c, Approver_Level__c, Deviation_Level__c, Approver__c, Loan_Application__c, Approval_Type__c, Assigned_to_Queue__c
                FROM Loan_Application_Approval__c
                WHERE Loan_Application__c =: loanAppId AND Approval_Status__c =: GlobalConstants.REJECTED AND Archived__c = FALSE
                WITH SECURITY_ENFORCED
        ];

        //sytsem.debug('assigneLevel>>>'+assigneLevel);
        approvalsToRelook.add(
            new Loan_Application_Approval__c( // new record so that CM can re-look again
                // Type__c = approvalRecord.Type__c,
                Approver_Level__c = getApprovalLevel( assigneLevel ),
                Approver__c = assignTo,
                Loan_Application__c = loanAppId,
                Approval_Type__c = GlobalConstants.APPROVAL_TYPE_CREDIT,
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                Assigned_to_Queue__c = false,
                Is_Assigned_Approver__c = true,
                RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application_Approval__c.getSObjectType(), 'Credit Approver' )
            )
        );
        System.debug(' === RElooks ===> ' + JSON.serializePretty(approvalsToRelook));

        if(!rejectedApprovals.isEmpty()){
            for( Loan_Application_Approval__c approval: [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanAppId AND Id IN: rejectedApprovals AND Archived__c = FALSE ] ){
                approvalsToRelook.add(
                    new Loan_Application_Approval__c(
                        Id = approval.Id,
                        Archived__c = true
                    )
                );
            }
        }
        upsert approvalsToRelook;

        // CUG :: When the case goes from Rejected to Credit - BRE HAS TO RE RUN
        AUSFLoanApplication_WithoutSharing.updateLoanApp( new Loan_Application__c[]{ new Loan_Application__c( Id = loanAppId, Stage__c = GlobalConstants.APPROVAL_TYPE_CREDIT, BRE_ReRun_Required__c = true ) } );
    }

    @AuraEnabled
    public static void selectNextApprover(String loanAppId,String nextAprId, Loan_Application_Approval__c approvalRecord){
        List<String> listOfType = new List<String>();
        List<String> approverProcessIds = new List<String>();
        String currentApproverId = Userinfo.getUserId();
        List<Loan_Application_Approval__c> listOfApprovers = new List<Loan_Application_Approval__c>();
        Map<String,List<Loan_Application_Approval__c>> mapOfTypeVsApprovers = new Map<String,List<Loan_Application_Approval__c>>();
        Loan_Application__c loanApp = [ SELECT Stage__c FROM Loan_Application__c WHERE Id =: loanAppId ];
        String[] approvedIds = new String[0];
        for (Loan_Application_Approval__c lp:[SELECT Id,Type__c,Approver__c,Approval_Status__c,Is_Assigned_Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:loanAppId AND Approval_Type__c =: loanApp.Stage__c AND Archived__c=false WITH SECURITY_ENFORCED]){
            system.debug('lp.Type__c '+lp.Type__c);
            if(lp.Approver__c == currentApproverId){
                approvedIds.add(lp.Id);
                if(lp.Type__c!=null){
                    listOfType.add(lp.Type__c);
                }
            }
            system.debug('types '+listOfType);
            if(lp.Is_Assigned_Approver__c == true && lp.Approval_Status__c=='Pending'){
                approverProcessIds.add(lp.Id);                               
            }
            if(lp.Type__c!=null && lp.Approval_Status__c!='Approved'){
                if(mapOfTypeVsApprovers.containsKey(lp.Type__c)){
                    mapOfTypeVsApprovers.get(lp.Type__c).add(lp);
                }else{
                    List<Loan_Application_Approval__c> listOfApprover = new List<Loan_Application_Approval__c>();
                    listOfApprover.add(lp);
                    mapOfTypeVsApprovers.put(lp.Type__c,listOfApprover);
                } 
            }
        }
        /**
         * // 13.09.23 || SFAU-4918 || approverProcessIds replaced with approvedIds since it approved all assigned records
         */
        String currentUserLevel = getCurrentUserType(listOfType);
        if(currentUserLevel == 'Middle'){
            if(mapOfTypeVsApprovers.containsKey('Base') && mapOfTypeVsApprovers.get('Base').size()>0){
                listOfApprovers.addAll(mapOfTypeVsApprovers.get('Base'));
            }
            if(mapOfTypeVsApprovers.containsKey('Middle') && mapOfTypeVsApprovers.get('Middle').size()>1){
                listOfApprovers.addAll(mapOfTypeVsApprovers.get('Middle'));
            }
            
            if(listOfApprovers.size()>0){
                approveAction(listOfApprovers, approvalRecord, approvedIds);
            }
            
            if(approvedIds.size()>0){
                approve(approvedIds,'Approve', approvalRecord);
            }
        }else if(currentUserLevel == 'Highest'){
            if(mapOfTypeVsApprovers.containsKey('Highest') && mapOfTypeVsApprovers.get('Highest').size()>1){
                listOfApprovers.addAll(mapOfTypeVsApprovers.get('Highest'));
            }
            if(listOfApprovers.size()>0){
                approveAction(listOfApprovers, approvalRecord, approvedIds);
            }
            if(approvedIds.size()>0){
                approve(approvedIds,'Approve', approvalRecord);
            }
        }else if(currentUserLevel == 'Base'){
            if(mapOfTypeVsApprovers.containsKey('Base') && mapOfTypeVsApprovers.get('Base').size()>1){
                listOfApprovers.addAll(mapOfTypeVsApprovers.get('Base'));
            }
            if(listOfApprovers.size()>0){
                approveAction(listOfApprovers, approvalRecord, approvedIds);
            }
            if(approvedIds.size()>0){
                approve(approvedIds,'Approve', approvalRecord);
            }
        }

        
        assignNextApprover(nextAprId, approvalRecord);// adding new parameter by Yash for decision History

         //Notification Part START
         if(loanApp.Stage__c == 'Credit'){
            if(currentUserLevel=='Base'){
                NotificationHandler.sendNotification('Credit Submission(L0)',loanApp.Id,'');
             }
             if(currentUserLevel=='Middle'){
                System.debug('Middle-> insideCreditSubmission N-1 called');
                NotificationHandler.sendNotification('Credit Submission (N-1)',loanApp.Id,'');
             }
             if(currentUserLevel=='Highest'){
                System.debug('Higesht-> insideCreditSubmission N called');
                NotificationHandler.sendNotification('Credit Submission (N)',loanApp.Id,currentUserLevel); 
                callCreditSanction(loanApp.Id);//credit -highest but pricing base/middle level we will need to check/query 
             }
         }

         if(loanApp.Stage__c == 'Pricing'){
            if(currentUserLevel=='Middle'){
                System.debug('MiddlePricing-> insidePricing N-1 called');
                NotificationHandler.sendNotification('Pricing (N-1)',loanApp.Id,currentUserLevel); //pricing - middle and highest level need to query
             }
             if(currentUserLevel=='Highest'){
                System.debug('HighestPricing-> insidePricing N called');
                NotificationHandler.sendNotification('Pricing (N)',loanApp.Id,currentUserLevel);
             }
         }
        //END
    }
    
    @AuraEnabled
    public static void rejectLoanApplication(String loanAppId, Loan_Application_Approval__c currentApprovalRecord){
        Id recordTypeIdTwo = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Id recordTypeIdFour = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
        Loan_Application__c loanApp = [Select Id,Stage__c,Approval_Status__c,RecordTypeId FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED LIMIT 1];
        String approvalType = loanApp.Stage__c;

        List<Loan_Application_Approval__c> appr = [Select Id,Approval_Status__c, Loan_Previous_Stage__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanAppId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: approvalType AND Approver__c =: UserInfo.getUserId() AND Archived__c = false WITH SECURITY_ENFORCED LIMIT 1];

        // if(appr.isEmpty() || loanApp.Stage__c == GlobalConstants.REJECTED) throw new AUSFApproverException('Can not reject an already rejected loan. Please refresh and try again.');

        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :appr[0].Id
        ];
        if(workItems.size()>0){
            List<String> rejectIds = new List<String>();
            rejectIds.add(appr[0].Id);
            approve(rejectIds,'Reject', currentApprovalRecord);  
        }else{
            appr[0].Approval_Status__c = 'Rejected';
            appr[0].Remarks__c = currentApprovalRecord?.Remarks__c;
            update appr;
        }
        
        
        if(loanApp.Stage__c=='Credit'){
           loanApp.Approval_Status__c = 'Credit Rejected'; 
        }
        if(loanApp.Stage__c=='Pricing'){
           loanApp.Approval_Status__c = 'Pricing Rejected'; 
        }
        
        // if(appr[0].Loan_Previous_Stage__c != GlobalConstants.STAGE_CREDIT){
            // loanApp.Stage__c = GlobalConstants.REJECTED;
            Map<String,String> mapOfLoanIdVsApplicantCaste = LoanApplicationApprovalTriggerHelper.getMapLoanIdVsApplicantCaste(new Set<String>{ loanAppId });
            // if(mapOfLoanIdVsApplicantCaste.containsKey( loanAppId )){
                update calculateLoanStagePostRejection(new Set<Id>{ loanAppId }, mapOfLoanIdVsApplicantCaste );
            // } else {
            //     update loanApp;
            // }
        // }
    }
    
    @AuraEnabled
    public static void sendBackToRoLoanApplication(String loanAppId, String creditManagerRemarks){
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
        
        List<Loan_Application_Approval__c> updateListApprovers = new List<Loan_Application_Approval__c>();
        List<Loan_Application__c> loanAppList = [Select Id,Stage__c,RecordTypeId,Approval_Status__c,Owner.Id, Send_Back_To_RO_Stage__c FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED LIMIT 1];

        String approvalType = loanAppList[0].Stage__c;

        for(Loan_Application_Approval__c appr :[Select Id,Approver__c,Approval_Status__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanAppId AND Approver__c=: UserInfo.getUserId() AND Archived__c=false AND Approval_Type__c =: approvalType WITH SECURITY_ENFORCED]){
            if(/*appr.Is_Assigned_Approver__c=true  &&*/ appr.Approval_Status__c =='Pending'){
                appr.Approval_Status__c = 'Send Back To RO';
                appr.Remarks__c = creditManagerRemarks;
                updateListApprovers.add(appr);
                break;
            }/*else{
                updateListApprovers.add(appr);
            }*/
          
        }
        if(updateListApprovers.size()>0){
             update updateListApprovers;
        }
        
        // SFAU-4968 | SFAU-4969
        if(loanAppList.size()>0){
             //Call the Notification Handler
             if(loanAppList[0].Stage__c=='Credit'){
                NotificationHandler.sendNotification('Credit sendback',loanAppList[0].Id,'');
             }
             if(loanAppList[0].Stage__c=='Pricing'){
                 NotificationHandler.sendNotification('Pricing send back',loanAppList[0].Id,'');
             }

            if(loanAppList[0].Stage__c=='Credit'){
                loanAppList[0].Approval_Status__c = 'Credit Send Back To RO';
                loanAppList[0].Send_Back_To_RO_Stage__c = 'Credit';
                loanAppList[0].Remarks__c = creditManagerRemarks;

            }
            if(loanAppList[0].Stage__c=='Pricing'){
                loanAppList[0].Approval_Status__c = 'Pricing Send Back To RO';
                loanAppList[0].Send_Back_To_RO_Stage__c = 'Pricing';
                loanAppList[0].Remarks__c = creditManagerRemarks;
            }
            if( queueBasedLoanTypes.contains( loanAppList[0].RecordTypeId ) ){
                loanAppList[0].Stage__c='QDE';
            } else if( hierarchyBasedLoanTypes.contains( loanAppList[0].RecordTypeId ) ){
                loanAppList[0].Stage__c='DDE';
            }

            update loanAppList; 

            String loanId = loanAppList[0].Id;
            String record = JSON.serialize(loanAppList);

            
            
        }    
    }
    
    /*@AuraEnabled
    public static List<Loan_Application_Approval__c> getRelookApprovers(String loanAppId){
        List<String> rejectedApprType = new List<String>();
        Set<Loan_Application_Approval__c> relookUsers = new Set<Loan_Application_Approval__c>();
        Map<String,List<Loan_Application_Approval__c>> mapOfTypeVsApprovers = new Map<String,List<Loan_Application_Approval__c>>();
        
        for(Loan_Application_Approval__c apr:[SELECT Id,Approver__r.Name,Approval_Status__c,Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED]){
            if(apr.Approval_Status__c=='Rejected'){
                rejectedApprType.add(apr.Type__c);
                relookUsers.add(apr);
            }
            if(apr.Type__c!=null){
                if(mapOfTypeVsApprovers.containsKey(apr.Type__c)){
                    mapOfTypeVsApprovers.get(apr.Type__c).add(apr);
                }else{
                    List<Loan_Application_Approval__c> listOfApprover = new List<Loan_Application_Approval__c>();
                    listOfApprover.add(apr);
                    mapOfTypeVsApprovers.put(apr.Type__c,listOfApprover);
                } 
            } 
            
        }
        String nextType = getNextType(rejectedApprType);
        if(mapOfTypeVsApprovers.containsKey(nextType)){
            relookUsers.addAll(mapOfTypeVsApprovers.get(nextType));
        }
        return new List<Loan_Application_Approval__c>(relookUsers);
    }*/
    
    @AuraEnabled
    public static LevelApproverWrapper getLevelVsApprovers(String loanAppId){
        SObjectType loanSObj = SObjectType.Loan_Application__c.getSObjectType();
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
        
        LevelApproverWrapper wrap = new LevelApproverWrapper();
        Loan_Application__c loanApp = [ SELECT
            Id,Branch_Master__c,
            Branch_Master__r.Business_HUB__c,
            Branch_Master__r.State__c,
            Branch_Master__r.Region__c,
            Branch_Master__r.Zone__c,
            Branch_Master__r.National__c,
            Stage__c,recordTypeId FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
        String[] teamRoles;
        if(ELIGIBLE_RELOOK_STAGES.contains(loanApp.Stage__c)){
            teamRoles = new String[]{ 'Credit' };
        }else if(loanApp.Stage__c=='Pricing'){
            teamRoles = Label.PricingTeamMemberRoles.split(',');
        }
        Map<String,List<SObject>> mapOfApproverLevelVsAccountTeam = new Map<String,List<SObject>>();

        // Sachin - pick two wheeler forward approvers from User.Authority_Level__c
        if( queueBasedLoanTypes.contains( loanApp.RecordTypeId ) && ELIGIBLE_RELOOK_STAGES.contains(loanApp.Stage__c) ){
            for( User eligibleApprover: [ SELECT Id, Name, Authority_Level__c FROM User WHERE Authority_Level__c IN: TW_APPROVAL_LEVELS AND User.IsActive = true AND Id NOT IN ( SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanAppId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE ) WITH SECURITY_ENFORCED ] ){
                if( !mapOfApproverLevelVsAccountTeam.containsKey( eligibleApprover.Authority_Level__c ) ){
                    mapOfApproverLevelVsAccountTeam.put( eligibleApprover.Authority_Level__c, new User[0] );
                }
                mapOfApproverLevelVsAccountTeam.get( eligibleApprover.Authority_Level__c ).add( eligibleApprover );
            }
            wrap.levels  = new List<String>(mapOfApproverLevelVsAccountTeam.keySet());
            wrap.mapOfApproverLevelVsAccountTeam = mapOfApproverLevelVsAccountTeam;
            return wrap;
        }

        Set<Id> branchIds = new Set<Id>{
            loanApp.Branch_Master__c,
            loanApp.Branch_Master__r.Business_HUB__c,
            loanApp.Branch_Master__r.State__c,
            loanApp.Branch_Master__r.Region__c,
            loanApp.Branch_Master__r.Zone__c,
            loanApp.Branch_Master__r.National__c
        };
        branchIds.remove(null);

        CreditApprovalHandler.Wrapper filterWrapper = CreditApprovalHandler.getListOfFilterValues( new String[]{ loanAppId });
        String[] gradeValues = filterWrapper.mapOfLoanIdVsCustGrade.values(),
            typeOfEmploymentValues = filterWrapper.mapOfLoanIdVsTypeOfEmpl.values(),
            productValues = filterWrapper.mapOfLoanIdVsProduct.values(),
            collateralValues = filterWrapper.mapOfLoanIddVsCollateralName.values();

        System.debug(' === Branch Ids ==' + JSON.serializePretty(branchIds));
        String pendingStatus = GlobalConstants.APPROVAL_STATUS_PENDING;

        String soql = 'Select Id,User.Name,Approver_Level__c,Deviation_Level__c, UserId FROM AccountTeamMember ' +
        'WHERE AccountId IN: branchIds AND Approver_Level__c != NULL AND User.IsActive=true AND TeamMemberRole IN: teamRoles AND ' +
        String.format(
            'Customer_Grade__c INCLUDES ({0}) AND Type_Of_Employment__c INCLUDES ({1}) AND Collateral__c INCLUDES ({2}) AND Product__c INCLUDES ({3})  ', // AND remove
            new String[]{
                '\'' + String.join(gradeValues, '\',\'') + '\'',
                '\'' + String.join(typeOfEmploymentValues, '\',\'') + '\'',
                '\'' + String.join(collateralValues, '\',\'') + '\'',
                '\'' + String.join(productValues, '\',\'') + '\''
        }) +
        ' WITH SECURITY_ENFORCED';
        /*
        +
        'UserId NOT IN ( SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanAppId AND Approval_Status__c =: pendingStatus AND Archived__c = FALSE ) WITH SECURITY_ENFORCED';
        */
        system.debug(LoggingLevel.Info,'Soql Query ' + soql);

        for(AccountTeamMember  accTeam:/*[
                Select Id,User.Name,Approver_Level__c,Deviation_Level__c FROM AccountTeamMember
                WHERE AccountId IN: branchIds AND Approver_Level__c != NULL AND User.IsActive=true AND TeamMemberRole IN: teamRoles AND
                // Customer_Grade__c INCLUDES: customerGradeValues AND Type_Of_Employment__c INCLUDES: typeOfEmplyomentValues AND Collateral__c INCLUDES: collateralValues AND Product__c INCLUDES: productValues AND
                UserId NOT IN ( SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanAppId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE ) WITH SECURITY_ENFORCED]*/
                Database.query(soql)
                )
        {
            system.debug(LoggingLevel.Info,'accTeam' + accTeam);
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
                    //two wheeler logic
                    if( queueBasedLoanTypes.contains( loanApp.recordTypeId ) || loanApp.Stage__c=='Pricing'){
                        if(mapOfApproverLevelVsAccountTeam.containsKey(app)){
                            mapOfApproverLevelVsAccountTeam.get(app).add(accTeam);
                        }else{
                            List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                            listOfAccTeam.add(accTeam);
                            mapOfApproverLevelVsAccountTeam.put(app,listOfAccTeam);
                        }
                    }
                    
                    //Four Wheeler Map
                        if(sepratedDeviationList.size()>0){
                            for(String dev:sepratedDeviationList){
                                if(mapOfApproverLevelVsAccountTeam.containsKey(app+dev)){
                                    mapOfApproverLevelVsAccountTeam.get(app+dev).add(accTeam);
                                }else{
                                    List<AccountTeamMember> listOfAccTeam = new List<AccountTeamMember>();
                                    listOfAccTeam.add(accTeam);
                                    mapOfApproverLevelVsAccountTeam.put(app+dev,listOfAccTeam);
                                }
                            }
                        }   
                    }
                }
            
            
        }
        system.debug('mapOfApproverLevelVsAccountTeam '+mapOfApproverLevelVsAccountTeam);
        Set<String> keys = mapOfApproverLevelVsAccountTeam.keySet();
        List<String> keyList = new List<String>();
        keyList.addAll(keys);
        wrap.levels  = keyList;
        wrap.mapOfApproverLevelVsAccountTeam = mapOfApproverLevelVsAccountTeam;
        return wrap;
    }

     // START  SFAU-4918 
     @AuraEnabled
     public static Boolean renderAcceptButton(String loanAppId){

        // If Current user already has a Pending record // 13.09.23 || SFAU-4918 || Removed Approval Status Pending filter since the user might already have approved it
        List<Loan_Application_Approval__c> currentUsersApprovalRecs = [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanAppId AND Approver__c =: UserInfo.getUserId() AND Archived__c = FALSE ];
        //if([ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanAppId AND Approver__c =: UserInfo.getUserId() AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE ] > 0 ){
        //commented above line for SFAU-3549 - List has no rows of assignment exception
        if(currentUsersApprovalRecs!=null && currentUsersApprovalRecs.size()>0){
            return false;
        }

         Boolean showAcceptButton = false;
         Loan_Application__c loanApp = [ SELECT
             Id,Branch_Master__c,
             Branch_Master__r.Business_HUB__c,
             Branch_Master__r.State__c,
             Branch_Master__r.Region__c,
             Branch_Master__r.Zone__c,
             Branch_Master__r.National__c,
             Stage__c,recordTypeId FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
 
             Set<Id> branchIds = new Set<Id>{
                 loanApp.Branch_Master__c,
                 loanApp.Branch_Master__r.Business_HUB__c,
                 loanApp.Branch_Master__r.State__c,
                 loanApp.Branch_Master__r.Region__c,
                 loanApp.Branch_Master__r.Zone__c,
                 loanApp.Branch_Master__r.National__c
             };
             branchIds.remove(null);
 
             String[] teamRoles;
             if(ELIGIBLE_RELOOK_STAGES.contains(loanApp.Stage__c)){
             teamRoles = new String[]{ 'Credit' };
             }else if(loanApp.Stage__c=='Pricing'){
             teamRoles = Label.PricingTeamMemberRoles.split(',');
             }
             //Level of logged in user 
             AccountTeamMember[]  loggedinTeamMembers = [ Select Id,User.Name,Approver_Level__c,Deviation_Level__c,User.Id FROM AccountTeamMember
                                             WHERE AccountId IN: branchIds AND Approver_Level__c != NULL AND User.IsActive=true AND TeamMemberRole IN: teamRoles AND  UserId=:UserInfo.getUserId()   WITH SECURITY_ENFORCED];
             System.debug('loggedinTeamMember-->' +loggedinTeamMembers);
             if(!loggedinTeamMembers.isEmpty() ){
                AccountTeamMember loggedinTeamMember = loggedinTeamMembers[0];
                String[] authorities = loggedinTeamMember.Approver_Level__c?.split(';');
                 Decimal decloggedinApprovalLevel = (loanApp.Stage__c=='Credit') ?  getCreditAuthLevel(authorities[authorities.size()-1]) : (loanApp.Stage__c=='Pricing') ? getPricingAuthLevel(authorities[authorities.size() -1]) : 0 ; 
                 Decimal decloggedinDeviationLevel = String.isNotBlank(loggedinTeamMember.Deviation_Level__c) ? getCreditDeviationLevel(loggedinTeamMember.Deviation_Level__c) : 0;
                 
     
                    //Level of assigned user 
                List<Loan_Application_Approval__c>  assignedCreditApprovals = [ Select Id,Approver__r.Name,Approver_Level__c,Deviation_Level__c,Approval_Status__c,Is_Assigned_Approver__c FROM Loan_Application_Approval__c  WHERE Loan_Application__c =:loanAppId AND Is_Assigned_Approver__c = TRUE AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: loanApp.Stage__c AND Archived__c = FALSE WITH SECURITY_ENFORCED ORDER BY SystemModStamp DESC LIMIT 1 ];
                if( assignedCreditApprovals.isEmpty() ){
                    assignedCreditApprovals = [ SELECT Id, Approver__r.Name, Approver_Level__c, Deviation_Level__c, Approval_Status__c, Is_Assigned_Approver__c FROM Loan_Application_Approval__c  WHERE Loan_Application__c =: loanAppId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: loanApp.Stage__c AND Archived__c = FALSE WITH SECURITY_ENFORCED ORDER BY SystemModStamp DESC LIMIT 1 ];
                }
                System.debug('assignedCreditApprovals-->' +assignedCreditApprovals);
                if(assignedCreditApprovals!=null && assignedCreditApprovals.size()>0){
                    Loan_Application_Approval__c  assignedCreditApproval = assignedCreditApprovals[0];
                    Decimal decassignedApprovalLevel = (loanApp.Stage__c=='Credit') ? getCreditAuthLevel(assignedCreditApproval.Approver_Level__c) : (loanApp.Stage__c=='Pricing') ? getPricingAuthLevel(assignedCreditApproval.Approver_Level__c) : 0 ;
                    Decimal decassignedDeviationLevel= String.isNotBlank(assignedCreditApproval.Deviation_Level__c) ? getCreditDeviationLevel(assignedCreditApproval.Deviation_Level__c) :0;
                    
        
                    //Compare the logged in user has higher authority or not 
                    if(decloggedinApprovalLevel == decassignedApprovalLevel){
                        if(decloggedinDeviationLevel > decassignedDeviationLevel){
                            showAcceptButton = true;
                        }
                    }else if(decloggedinApprovalLevel > decassignedApprovalLevel){
                        showAcceptButton = true;
                    }else{
                        showAcceptButton = false;
                    }
    
                    System.debug('decloggedinApprovalLevel-->' +decloggedinApprovalLevel);
                    System.debug('decassignedApprovalLevel-->' +decassignedApprovalLevel);
                    System.debug('showAcceptButton-->' +showAcceptButton);
                }
                 
             }
            
         
         return showAcceptButton;
     }
 
     @AuraEnabled
     public static void acceptApprovalHierarchyBased(String loanAppId){
 
         Loan_Application__c loanApp = [ SELECT
             Id,Branch_Master__c,
             Branch_Master__r.Business_HUB__c,
             Branch_Master__r.State__c,
             Branch_Master__r.Region__c,
             Branch_Master__r.Zone__c,
             Branch_Master__r.National__c,
             Stage__c,recordTypeId FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
 
             Set<Id> branchIds = new Set<Id>{
                 loanApp.Branch_Master__c,
                 loanApp.Branch_Master__r.Business_HUB__c,
                 loanApp.Branch_Master__r.State__c,
                 loanApp.Branch_Master__r.Region__c,
                 loanApp.Branch_Master__r.Zone__c,
                 loanApp.Branch_Master__r.National__c
             };
             branchIds.remove(null);
 
             String[] teamRoles;
             String strForStage = '';
             if(ELIGIBLE_RELOOK_STAGES.contains(loanApp.Stage__c)){
                teamRoles = new String[]{ 'Credit' };
                strForStage = 'Credit';
             }else if(loanApp.Stage__c=='Pricing'){
                teamRoles = Label.PricingTeamMemberRoles.split(',');
                strForStage = 'Pricing';
             }
             //Level of logged in user 
             AccountTeamMember  loggedinTeamMember = [ 
                SELECT Id, User.Name, Approver_Level__c,Deviation_Level__c,User.Id 
                FROM AccountTeamMember
                WHERE AccountId IN: branchIds AND Approver_Level__c != NULL AND User.IsActive = true AND 
                TeamMemberRole IN: teamRoles AND User.Id=:UserInfo.getUserId() AND Active__c = true 
                WITH SECURITY_ENFORCED LIMIT 1
                ];
                 
 
            String approvalType = loanApp.Stage__c;
            Loan_Application_Approval__c[]  lstAssgignedCreditApproval = [ SELECT Id,Type__c, Approver_Level__c, Deviation_Level__c, Approver__c, Approval_Type__c FROM Loan_Application_Approval__c  WHERE Loan_Application__c =: loanAppId AND Archived__c=false AND Approval_Status__c='Pending' WITH SECURITY_ENFORCED ORDER BY Approver_Level__c ASC ];
            /* START - SFAU-5677 - Credit Issues - Credit Approval Level */
            List<Loan_Application_Approval__c> assignedCreditApprovals = new List<Loan_Application_Approval__c>();
            for (Loan_Application_Approval__c obj : lstAssgignedCreditApproval) {
                if (strForStage == 'Credit' && obj.Approval_Type__c == 'Credit') {
                    assignedCreditApprovals.add(obj);
                }
                else if (strForStage == 'Pricing' && obj.Approval_Type__c == 'Pricing') {
                    assignedCreditApprovals.add(obj);
                }
            }
            assignedCreditApprovals = (strForStage == 'Credit' || strForStage == 'Pricing') ? assignedCreditApprovals : lstAssgignedCreditApproval;
            /* END - SFAU-5677 - Credit Issues - Credit Approval Level */
            // 5th-OCT-2023
            map<Integer, Loan_Application_Approval__c> approversOrderMap = getApprovalSortedByLevel( assignedCreditApprovals );
            Integer[] approversOrder = new List<Integer>( approversOrderMap.keySet() );
            approversOrder.sort();
            Loan_Application_Approval__c highestApprover = approversOrderMap.get( approversOrder[ approversOrder.size() - 1 ] );

            if(loggedinTeamMember!=null){
             Loan_Application_Approval__c approvalInstance = new Loan_Application_Approval__c();
             approvalInstance.Loan_Application__c = loanAppId;
             approvalInstance.Approver__c = loggedinTeamMember.User.Id;
             approvalInstance.Approval_Type__c = loanApp.Stage__c;
             approvalInstance.Is_Assigned_Approver__c = true;
             approvalInstance.Approver_Level__c =  loggedinTeamMember.Approver_Level__c;
             approvalInstance.Deviation_Level__c = loggedinTeamMember.Deviation_Level__c;
             approvalInstance.Approval_Status__c = 'Pending'; // SFAU-5014
             approvalInstance.Type__c = !isForwardedToHigherAuth( highestApprover.Approver__c, UserInfo.getUserId(), approvalType, loanAppId ) ? 'Middle' : 'Highest'; //Sachin - 5th-OCT-2023 | Case when picked from authority less than highest gets incorrect Level
             approvalInstance.RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application_Approval__c.getSObjectType(), approvalType + ' Approver' );
             insert approvalInstance;
             System.debug('approvalInstance-->' +approvalInstance);
           }
     }


     /**
      *  5th-OCT-2023 | Case when picked from authority less than highest gets incorrect Level
      */
    public static map<Integer, Loan_Application_Approval__c> getApprovalSortedByLevel( Loan_Application_Approval__c[] approvals ){

        map<Integer, Loan_Application_Approval__c> approversOrderMap = new map<Integer, Loan_Application_Approval__c>();
        Integer[] approversOrder = new Integer[0];
        map<String, Integer> approversPref = LoanApplicationApprovalTriggerHelper.APPROVERS_PREFERENCES;
        for(Integer i = 0; i < approvals.size(); i++){
            Loan_Application_Approval__c approval = approvals[i];
            Integer preference = approversPref.get(approval.Type__c) != null ? approversPref.get(approval.Type__c) : 0;

            approversOrder.add(preference);
            approversOrderMap.put(preference, approval);
        }

        return approversOrderMap;
    }


    // END  SFAU-4918 
    
    // :TODO - remove references from lwcs & remove this method
    /*@AuraEnabled
    public static LevelVsLoanApproverWrapper reAssignTwoWheeler(String loanAppId){
        Id recordTypeIdTwo = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Loan_Application__c loanApp = [SELECT Id,Branch_Master__c,Stage__c,recordTypeId FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
        LevelVsLoanApproverWrapper wrap = new LevelVsLoanApproverWrapper();
        Map<String,List<Loan_Application_Approval__c>> mapOfLevelVsApprovers = new Map<String,List<Loan_Application_Approval__c>>();
        for(Loan_Application_Approval__c  accTeam:[Select Id,Approver__r.Name,Approver_Level__c FROM Loan_Application_Approval__c  WHERE Loan_Application__c =:loanApp.Id AND Approver__r.IsActive=true AND Archived__c=false WITH SECURITY_ENFORCED]){
            if(recordTypeIdTwo ==loanApp.recordTypeId){
                if(mapOfLevelVsApprovers.containsKey(accTeam.Approver_Level__c)){
                    mapOfLevelVsApprovers.get(accTeam.Approver_Level__c).add(accTeam);
                }else{
                    List<Loan_Application_Approval__c> listOfAccTeam = new List<Loan_Application_Approval__c>();
                    listOfAccTeam.add(accTeam);
                    mapOfLevelVsApprovers.put(accTeam.Approver_Level__c,listOfAccTeam);
                }
            }
        }
        Set<String> keys = mapOfLevelVsApprovers.keySet();
        List<String> keyList = new List<String>();
        keyList.addAll(keys);
        wrap.levels  = keyList;
        wrap.mapOfApproverLevelVsAccountTeam = mapOfLevelVsApprovers;
        return wrap;
        return null;
    }*/
    
    @AuraEnabled
    public static void shareLoanApp(String loanAppId, String userId, String level, String action, Loan_Application_Approval__c approvalRecord){
        system.debug('loanAppId '+loanAppId);
        system.debug('userId '+userId);
        Loan_Application__c loanApp = [ SELECT Id, Stage__c, RecordType.Name FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED ];
            String type = loanApp.Stage__c == GlobalConstants.APPROVAL_TYPE_PRICING ? GlobalConstants.APPROVAL_TYPE_PRICING : GlobalConstants.APPROVAL_TYPE_CREDIT;
            Boolean isTwoWheeler = loanApp.RecordType.Name == GlobalConstants.TWOWHEELER;

            Loan_Application_Approval__c[] approvalsToUpdate = forwardApplicationApproval( loanApp, UserInfo.getUserId(), userId, level, approvalRecord, action );

            System.debug(' ==== approvalsToUpdate ==> ' + JSON.serializePretty(approvalsToUpdate));
            upsert approvalsToUpdate;
        
        /* Since the queue only has read only access to the loan application
        * it( + related private sobjects ) has to be shared to the credit user who accepts it
        */
        Utility.shareLoanApplicationsAndRelatedRecords( new Set<Id>{ loanAppId }, userId );

        String msg = userId +'@'+ level + '@' +UserInfo.getUserId();
        NotificationHandler.sendNotification('Credit Manual assignment', loanAppId, msg);

        /*
        List<Loan_Application__Share> loanAppShareList = new List<Loan_Application__Share>();
        Loan_Application__Share shareObj = new Loan_Application__Share();
        shareObj.parentId = loanAppId;
        shareObj.UserOrGroupId = userId;
        shareObj.AccessLevel = 'edit';
        shareObj.RowCause = Schema.Loan_Application__Share.RowCause.Sharing_To_Approver__c;
        loanAppShareList.add(shareObj);
        
        insert loanAppShareList;*/
    }

    public static Loan_Application_Approval__c[] forwardApplicationApproval(Loan_Application__c loanApplication, Id approverId, Id forwardedTo, String level, Loan_Application_Approval__c approvalRecord, String action){
        Loan_Application_Approval__c[] approvalsToUpdate = new Loan_Application_Approval__c[0];

        String approvalType = loanApplication.Stage__c == GlobalConstants.STAGE_CREDIT ? GlobalConstants.APPROVAL_TYPE_CREDIT : GlobalConstants.APPROVAL_TYPE_PRICING;

        SObjectType loanApprovalSObjType = SObjectType.Loan_Application_Approval__c.getSObjectType();

        map<String, Id> approvalTypeToRecordType = new map<String, Id>{
            GlobalConstants.APPROVAL_TYPE_CREDIT => Utility.getRecordTypeId( loanApprovalSObjType, 'Credit Approver' ),
            GlobalConstants.APPROVAL_TYPE_PRICING => Utility.getRecordTypeId( loanApprovalSObjType, 'Pricing Approver' )
        };
        // Approval record of the sender ( who's currently forwarding )
        // Add Is_Forward__c in query
        Loan_Application_Approval__c[] lstApprovals = [ SELECT Id, Approver__c, Approval_Status__c, Approval_Type__c, Type__c, Loan_Application__c, Deviation_Level__c, Approver_Level__c, Is_Forward__c 
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =: loanApplication.Id AND Archived__c = FALSE AND
            ((Approver__c = NULL OR Approver__c =: approverId) AND Approval_Status__c != 'Approved') AND Approval_Type__c =: approvalType
            ORDER BY Approver__c NULLS LAST // LIMIT 1
        ];
        List<Loan_Application_Approval__c> approvals = new List<Loan_Application_Approval__c>();
        List<Loan_Application_Approval__c> approvalsExtra = new List<Loan_Application_Approval__c>();
        for (Loan_Application_Approval__c objApproval : lstApprovals) {
            if (objApproval.Is_Forward__c) {
                approvals.add(objApproval);
            }
            else {
                objApproval.Is_Forward__c = !objApproval.Is_Forward__c ? true : objApproval.Is_Forward__c;
                approvalsExtra.add(objApproval);
                //break;
            }
        }
        if (approvals.size() == 0 && approvalsExtra.size() > 0) {
            approvals.add(approvalsExtra[0]);
            approvalsExtra.remove(0);
        }
        

        /**
         * Application can be forwared to user who already has the loan assigned with action required
         * in this case, the existing record will be archived & a new record will be created 
         */
        if( action == APPROVAL_TYPE_FORWARD ){
            for(Loan_Application_Approval__c approvalPendingWithReceiver : [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApplication.Id AND Approver__c =: forwardedTo AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = false ]){
                approvalPendingWithReceiver.Archived__c = true;
                approvalsToUpdate.add( approvalPendingWithReceiver );
            }

        }

        Loan_Application_Approval__c approval = !approvals.isEmpty() ? approvals[0] : NULL;

        if( approvals.isEmpty() && action == APPROVAL_TYPE_REASSIGN ){

            for( Loan_Application_Approval__c existingApproval: [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApplication.Id AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT AND Archived__c = FALSE ]){
                approvalsToUpdate.add(
                    new Loan_Application_Approval__c(
                        Id = existingApproval.Id,
                        Approval_Status__c = GlobalConstants.APPROVAL_STATUS_FORWARDED,
                        Archived__c = true
                    )
                );
            }
            approval = new Loan_Application_Approval__c(
                Loan_Application__c = loanApplication.Id,
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                Approval_Type__c = GlobalConstants.APPROVAL_TYPE_CREDIT,
                Approver__c = forwardedTo,
                Assigned_to_Queue__c = false,
                Is_Assigned_Approver__c = true,
                Approver_Level__c = getApprovalLevel( level ),
                RecordTypeId = approvalTypeToRecordType.get( GlobalConstants.APPROVAL_TYPE_CREDIT )
            );
            insert approval;
        }
        // approval.Is_Assigned_Approver__c = false; //:TODO - verify if the record will get submitted to approval record again??
        approval.Remarks__c = approvalRecord?.Remarks__c;
        // SFAU-5636
        approval.Is_Forward__c = (action == APPROVAL_TYPE_FORWARD);

        Boolean isTwoWheeler = loanApplication.RecordType.Name == GlobalConstants.TWOWHEELER;
        // Forward existing approval to the new user
        if( isTwoWheeler ){
            Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(
                Id = action == APPROVAL_TYPE_REASSIGN || approval.Approver__c == null ? approval.Id : null, // update approval which is in queue
                Remarks__c = approval.Approver__c == null ? approval.Remarks__c : null,
                Is_Assigned_Approver__c = true,
                Loan_Application__c = approval.Loan_Application__c,
                Approval_Type__c = approval.Approval_Type__c,
                Type__c = getFinalApprovalLevel( approverId, forwardedTo, approval, approvalType ),
                // approval.Manually_Assigned_User__c = true; // Sachin - fails entry condition of Approval process & results into an error
                Approver__c = forwardedTo,
                Approver_Level__c = getApprovalLevel( level ),
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                Assigned_to_Queue__c = false,
                RecordTypeId = approvalTypeToRecordType.get( approval.Approval_Type__c )
            );
        
            if(approval.Approver__c != null && action != APPROVAL_TYPE_REASSIGN && ( approvalType == GlobalConstants.APPROVAL_TYPE_CREDIT || isForwardedToHigherAuth( approverId, forwardedTo, approvalType, loanApplication.Id ))){
                approval.Archived__c = true; //Approval of the user who forwarded is no longer required so archive it
                approval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_FORWARDED; //Update Approval Status to Forward for tracking remarks

                approvalsToUpdate.add( approval );
            }
            approvalsToUpdate.add( forwardedApproval );
        } else {

            if((loanApplication.Stage__c == GlobalConstants.STAGE_CREDIT && isForwardedToHigherAuth( approverId, forwardedTo, GlobalConstants.APPROVAL_TYPE_CREDIT, loanApplication.Id )) || (loanApplication.Stage__c == GlobalConstants.STAGE_PRICING && isForwardedToHigherAuth( approverId, forwardedTo, GlobalConstants.APPROVAL_TYPE_PRICING, loanApplication.Id ))){
                approval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_FORWARDED; //Update Approval Status to Forward for tracking remarks
            }

            Set<Id> loanIds = new Set<Id>{ loanApplication.Id };
            // Approval record for the new approver
            approvalsToUpdate.add(
                new Loan_Application_Approval__c(
                    Loan_Application__c = loanApplication.Id,
                    Approver__c = forwardedTo,
                    // SFAU-5677 - Credit Issues - Credit Approval Level
                    Type__c = getApproverApprovalAuthority(
                        [ SELECT Id, Approver_Level__c, Deviation_Level__c, Type__c, Approval_Type__c, Type_Order__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIds AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: approvalType AND Archived__c = FALSE AND Is_Forward__c = false ORDER BY Type_Order__c ],
                        approvalType,
                        level, true, approvals[0]
                    ),
                    // Type__c = getNextLowerApprovalType( new String[]{ approval.Type__c } ),
                    Approval_Type__c = approval.Approval_Type__c,
                    Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                    Approver_Level__c = getApprovalLevel( level ),
                    Deviation_Level__c = loanApplication.Stage__c != GlobalConstants.APPROVAL_TYPE_PRICING ? getDeviationLevel( level ) : null,
                    Is_Assigned_Approver__c = true,
                    Forwarded_By__c = approval.Id,
                    Forwarded_By_Remarks__c = approvalRecord?.Remarks__c,
                    RecordTypeId = approvalTypeToRecordType.get( approval.Approval_Type__c )
                )
            );
            approvalsToUpdate.add( approval );
            approvalsToUpdate.addAll(approvalsExtra);
            
        }

        return approvalsToUpdate;
    }

    public static String getFinalApprovalLevel( Id senderId, Id receiverId, Loan_Application_Approval__c currentApproval, String approvalType ){
        Set<Id> userIds = new Set<Id>{ senderId, receiverId };
        String[] teamRoles = approvalType == GlobalConstants.APPROVAL_TYPE_CREDIT ? new String[]{ GlobalConstants.APPROVAL_TYPE_CREDIT } : Label.PricingTeamMemberRoles.split(','),
            currentLevel = new String[]{ currentApproval.Type__c };
        
        map<Id, String> userAuthorityMap = new map<Id, String>();
        if( approvalType == GlobalConstants.APPROVAL_TYPE_PRICING ){
            for(AccountTeamMember atm: [ SELECT Id, UserId, Approver_Level__c, Deviation_Level__c FROM AccountTeamMember WHERE UserId IN: userIds AND TeamMemberRole IN: teamRoles AND Active__c != FALSE AND User.IsActive = true ]){
                userAuthorityMap.put( atm.UserId, atm.Approver_Level__c );
            }
        } else {
            map<Id, User> userMap = new map<Id, User>([ SELECT Id, Authority_Level__c FROM User WHERE Id IN: userIds ]);
            User sender = userMap.get( senderId),
                receiver = userMap.get( senderId);
            userAuthorityMap.put( senderId, sender.Authority_Level__c );
            userAuthorityMap.put( receiverId, receiver.Authority_Level__c );
        }



        String senderLevel = userAuthorityMap.get( senderId ).split(';')[0],
            receiverLevel = userAuthorityMap.get( receiverId ).split(';')[0];
    
        if( senderLevel == receiverLevel ){
            return currentApproval.Type__c;
        } else if( approvalType == GlobalConstants.APPROVAL_TYPE_CREDIT ){
            return getCreditAuthLevel( senderLevel ) < getCreditAuthLevel( receiverLevel ) ? getNextType( currentLevel ) : getNextLowerApprovalType( currentLevel );
        } else if( approvalType == GlobalConstants.APPROVAL_TYPE_PRICING ){
            return getPricingAuthLevel( senderLevel ) < getPricingAuthLevel( receiverLevel ) ? getNextType( currentLevel ) : getNextLowerApprovalType( currentLevel );
        }
        
        return 'Highest';
    }


    public static String getNextLowerApprovalType( String[] currentLevels ){
        if( currentLevels.contains( 'Highest' ) ){
            return 'Middle';
        } else if( currentLevels.contains( 'Middle' ) || currentLevels.contains( 'Base' ) ){
            return 'Base';
        }
        return null;
    }

    //SFAU-5677 - Credit Issues - Credit Approval Level
    public static String getApproverApprovalAuthority( Loan_Application_Approval__c[] approvals, String approvalType, String selectedApproverLevel, Boolean blnCheckCurrentApprover, Loan_Application_Approval__c objCurrentAppRecord){
        // Loan_Application_Approval__c[] approvals = loanApplicationApprovals.values(); //[ SELECT Id, Approver_Level__c, Deviation_Level__c, Type__c, Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIds AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: approvalType AND Archived__c = FALSE ORDER BY Type__c ];
        System.debug(' === approvals ==> ' + JSON.serializePretty(approvals));
        // map<String, Loan_Application_Approval__c[]> approversByType = Utility.getApprovalsByType( approvals );
        map<String, Loan_Application_Approval__c[]> levelToApprovals = new map<String, Loan_Application_Approval__c[]>();
        for( Loan_Application_Approval__c approval: approvals ){
            String level = approval.Approver_Level__c + (String.isNotBlank(approval.Deviation_Level__c) ? approval.Deviation_Level__c : '');
            if( !levelToApprovals.containsKey(level) ){
                levelToApprovals.put( level, new Loan_Application_Approval__c[0] );
            }
            levelToApprovals.get(level).add( approval );
        }
        System.debug(' == levelToApprovals ==> ' + JSON.serializePretty(levelToApprovals));
        AUSFLoanApplicationAssignmentHelper assignments = new AUSFLoanApplicationAssignmentHelper( approvalType, new map<String, String>() );
        map<String, String> mapOfNextKeys = AUSFLoanApplicationAssignmentHelper.mapOfNextKey;


        String approvalLevel = selectedApproverLevel;
        while( mapOfNextKeys.containsKey(approvalLevel) ){
            if( levelToApprovals.containsKey( approvalLevel ) ){
                String currentLevel = levelToApprovals.get( approvalLevel )[0].Type__c;
                return approvalLevel == selectedApproverLevel ? currentLevel : getNextLowerApprovalType( new String[]{ currentLevel } );
            }
            approvalLevel = mapOfNextKeys.get( approvalLevel );
        }

        // approvalLevel = '', approvalType = 'Pricing', approvals[0].Approver_Level__c = 'L1S3', selectedApproverLevel = 'L2S3'
        if(blnCheckCurrentApprover && String.isNotBlank( approvalLevel ) && objCurrentAppRecord != NULL && !isMovingToHigherAuthority( approvalType, (objCurrentAppRecord.Approver_Level__c + (String.isNotBlank(objCurrentAppRecord.Deviation_Level__c) ? objCurrentAppRecord.Deviation_Level__c : '')), selectedApproverLevel )){
            return getNextLowerApprovalType( new String[]{ objCurrentAppRecord.Type__c } );
        }
        else if(!blnCheckCurrentApprover && String.isNotBlank( approvalLevel ) && !approvals.isEmpty() && !isMovingToHigherAuthority( approvalType, (approvals[0].Approver_Level__c + (String.isNotBlank(approvals[0].Deviation_Level__c) ? approvals[0].Deviation_Level__c : '')), selectedApproverLevel )){
            return getNextLowerApprovalType( new String[]{ approvals[0].Type__c } );
        }
        // return getNextLowerApprovalType( approvals[0].Approver_Level__c );
        return 'Highest';
    }

    public static Boolean isMovingToHigherAuthority( String approvalType, String senderLevel, String receiverLevel ){
        if( approvalType == GlobalConstants.APPROVAL_TYPE_PRICING ){
            return isForwardedToHigherAuth( senderLevel, receiverLevel, GlobalConstants.APPROVAL_TYPE_PRICING,'');
        }
        String senderApproverLevel = getApprovalLevel( senderLevel ), 
            receiverApproverLevel = getApprovalLevel( receiverLevel ),
            senderDeviationLevel = getDeviationLevel( senderLevel ),
            receiverDeviationLevel = getDeviationLevel( receiverLevel );

        System.debug(
            ' === Sender Approval Level ===> ' + getCreditAuthLevel( senderApproverLevel ) +
            '\n Sender Deviation Level ===> ' + getCreditAuthLevel( receiverApproverLevel ) +
            '\n Receiver ' +  getCreditDeviationLevel( senderDeviationLevel ) +
            '\n Receiver Deviation level => ' + getCreditDeviationLevel( receiverDeviationLevel )
        );

            if( getCreditAuthLevel( receiverApproverLevel ) > getCreditAuthLevel( senderApproverLevel ) ||
                (getCreditAuthLevel( senderApproverLevel ) == getCreditAuthLevel( receiverApproverLevel ) &&
                getCreditDeviationLevel( receiverDeviationLevel ) > getCreditDeviationLevel( senderDeviationLevel ))
            ){
                return true;
            }
        return false;
    }

    @AuraEnabled
    public static loanAppWrap getLoanApp(String recordId){
        Boolean runCibilAgain = false;
        Boolean runValuationAgain = false;
        Boolean runFIAgain = false;
        Integer lastCibilRunDays;
        Integer lastFIRunDays;
        Integer lastValuationRunDays;
        Id recordTypeIdTwo = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Id applicantrecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        List<Applicant__c> appList = new List<Applicant__c>();
        X2W_Approval_Assignem_Switch__mdt  sw =X2W_Approval_Assignem_Switch__mdt.getInstance('Queue_Based_Assignment');
        system.debug('sw '+sw);
        loanAppWrap wrap = new loanAppWrap();
        // SFAU-4091
        Loan_Application__c loanApp = [SELECT Id,Pre_Approved_Flag__c,Stage__c,Sub_Stage__c, BRE_ReRun_Required__c, BRE_Run_for_PreApproved_Offer__c, RecordType.Name, RecordType.DeveloperName, Approval_Status__c, BRE_Approval_Level__c, Valuation_Completion_Date__c,FI_Completion_Date__c,recordTypeId,Is_Valuation_Verification_Required__c,isLoanAmtChanged__c, ReTrigger_EMI_Schedule__c, ( select Assigned_to_Queue__c FROM Loan_Application_Approvers__r where Assigned_to_Queue__c=true AND Archived__c = false ) FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED]; // SFAU-5147 added isLoanAmtChanged__c
        wrap.isBreReRunRequired = Utility.getCurrentBREStatus( loanApp );
        appList =[SELECT Id,Last_CIBIL_Run_Date__c  FROM Applicant__c Where Loan__c=:recordId AND recordTypeId=:applicantrecordTypeId AND IsInactive__c = false WITH SECURITY_ENFORCED];
        Date startDate = Date.today();
        if(appList.size()>0 && appList[0].Last_CIBIL_Run_Date__c!=null){
            Date lastCibilRunDate = appList[0].Last_CIBIL_Run_Date__c;
            lastCibilRunDays = lastCibilRunDate.daysBetween(startDate); 
            system.debug('lastCibilRunDays >'+lastCibilRunDays);
            if(lastCibilRunDays>30){
                runCibilAgain =true;
            }
            
        }
        if(loanApp!=null && loanApp.Valuation_Completion_Date__c!=null){
            Date lastValuationRunDate = loanApp.Valuation_Completion_Date__c;
            lastValuationRunDays = lastValuationRunDate.daysBetween(startDate); 
            system.debug('lastValuationRunDays >'+lastValuationRunDays);
            if(lastValuationRunDays>30){
                runValuationAgain =true;
            }
        }
        
        if(loanApp!=null && loanApp.FI_Completion_Date__c!=null){
            Date lastFIRunDate = loanApp.FI_Completion_Date__c;
            lastFIRunDays = lastFIRunDate.daysBetween(startDate); 
            system.debug('lastFIRunDays >'+lastFIRunDays);
            if(lastFIRunDays>30){
                runFIAgain =true;
            }
        }
        
        
        system.debug('runCibilAgain '+runCibilAgain);
        system.debug('runFIAgain '+runFIAgain);
        system.debug('runValuationAgain '+runValuationAgain);
        List<Loan_Application_Approval__c> listOfQueueApprovers=loanApp.Loan_Application_Approvers__r;
        wrap.loanApp = loanApp;
        wrap.isTwoWheeler = loanApp.RecordTypeId==recordTypeIdTwo?true:false;
        wrap.isCreditStage = loanApp.Stage__c=='Credit'?true:false;
        wrap.isPricingStage = loanApp.Stage__c=='Pricing'?true:false;
        wrap.isQueueOwner=listOfQueueApprovers.size()>0?true:false;
        wrap.isGenerateCibilAgain = runCibilAgain;
        wrap.isRunFIAgain =runFIAgain;
        wrap.isRunValuationAgain =runValuationAgain;
        String approvalType;
        if(ELIGIBLE_APPROVAL_STAGES.contains(loanApp.Stage__c)){
            approvalType = 'Credit';
        }
    
        if(loanApp.Stage__c=='Pricing'){
            approvalType = 'Pricing';
        }
        
        List<Loan_Application_Approval__c> approvalList = [
            SELECT Id from Loan_Application_Approval__c 
            Where Loan_Application__c =: loanApp.Id AND
            Approver__c=:Userinfo.getUserId() AND
            Approval_Status__c='Pending' AND
            Approval_Type__c=:approvalType AND
            Archived__c = FALSE
        ];

        wrap.showComp = approvalList.size()>0 || listOfQueueApprovers.size()>0 || loanApp.Stage__c == GlobalConstants.REJECTED;
        wrap.needPreApprovalAction = wrap.isQueueOwner || (loanApp.RecordType.Name != GlobalConstants.TWOWHEELER &&  renderAcceptButton(recordId)); //SFAU-4918
        wrap.allowRevoke = [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: recordId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Delegated_Approval__c != NULL AND Delegated_Approval__r.Approver__c =: UserInfo.getUserId() AND Archived__c = FALSE ] > 0;

        if( loanApp.RecordType.Name == GlobalConstants.TWOWHEELER ){
            wrap.allowReassignment = wrap.isCreditStage && approvalList.isEmpty() && listOfQueueApprovers.isEmpty() && ![ SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId() AND Profile.Name = 'Credit Manager' ].isEmpty();
            wrap.showComp = wrap.showComp || wrap.allowReassignment;
        }
        
        return wrap;
    }

    @AuraEnabled
    public static map<String, Object> acceptApprovalFromQueue(Id loanId){
        Loan_Application__c loanApp = [SELECT Id,Stage__c, RecordType.Name FROM Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED]; //SFAU-4918

        String[] hierarchyBasedApprovalTypes = new String[]{ GlobalConstants.FOURWHEELER, GlobalConstants.TRACTOR, GlobalConstants.COMMERCIALVEHICLE, GlobalConstants.CONSTRUCTIONEQUIP };
        if(loanApp.RecordType.Name == GlobalConstants.TWOWHEELER){ //SFAU-4918
            User creditUser = [ SELECT Authority_Level__c FROM User WHERE Id =: UserInfo.getUserId() ];

            if(String.isBlank(creditUser.Authority_Level__c)) throw new AUSFApproverException('You don\'t have correct Authority to Accept this case');

            Loan_Application_Approval__c[] approvalRecords = [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Status__c IN: ELIGIBLE_ACCEPT_STATUS AND Approver__c = NULL AND Archived__c = FALSE WITH SECURITY_ENFORCED LIMIT 1 ];

            if(approvalRecords.isEmpty()) throw new AUSFApproverException('This Case has been accepted already');

            Loan_Application_Approval__c approvalRecord = approvalRecords[0];
            approvalRecord.Approver__c = UserInfo.getUserId();
            approvalRecord.Assigned_to_Queue__c = false;
            approvalRecord.Is_Assigned_Approver__c = true;
            approvalRecord.Approval_Status__c = 'Pending';
            approvalRecord.Approver_Level__c = creditUser.Authority_Level__c;

            update approvalRecord;

            /* Since the queue only has read only access to the loan application
            * it( + related private sobjects ) has to be shared to the credit user who accepts it
            */
            Utility.shareLoanApplicationsAndRelatedRecords( new Set<Id>{ loanId }, approvalRecord.Approver__c );
        }else if( hierarchyBasedApprovalTypes.contains( loanApp.RecordType.Name ) ){ // START || SFAU-4918
            acceptApprovalHierarchyBased(loanId);
        } // END || SFAU-4918
        return new map<String, Object>{
            'showComp' => true,
            'needPreApprovalAction' => false
        };
    }

    public static String getApprovalLevel(String level){
        if(String.isNotBlank(level)){
            return level.split('S')[0];
        }
        return level;
    }
    public static String getDeviationLevel(String level){
        if(String.isNotBlank(level)){
            return 'S' + level.split('S')[1];
        }
        return level;
    }
    
    @AuraEnabled
    public static Loan_Application_Approval__c revokeDelegatedUserAccess( Id loanId ){
        Loan_Application_Approval__c approvalRecord = [
            SELECT Id, Approver__r.Name, Delegated_Approval__c
            FROM Loan_Application_Approval__c
            WHERE Loan_Application__c =: loanId AND
            Delegated_Approval__c != NULL AND 
            Delegated_Approval__r.Approver__c =: UserInfo.getUserId() AND
            Archived__c = FALSE WITH USER_MODE
        ];

        update new Loan_Application_Approval__c( Id = approvalRecord.Id, Archived__c = true );
        return approvalRecord;
    }

    public static Loan_Application__c[] calculateLoanStagePostRejection( Set<Id> loanIds,  Map<String,String> mapOfLoanIdVsApplicantCaste ){
        Id recordTypeIdTwo = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Loan_Application__c[] loanApplications = new Loan_Application__c[0];
        for(Loan_Application__c loanApp: [ SELECT Id,Approval_Status__c, Stage__c, RecordTypeId,  (SELECT ID,Approval_Status__c,Type__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c ='Rejected' AND Approval_Type__c='Credit' AND Archived__c = FALSE ) FROM Loan_Application__c WHERE Id IN :loanIds WITH SECURITY_ENFORCED]){
            Loan_Application_Approval__c[] rejectedApprovals = loanApp.Loan_Application_Approvers__r;
            // 27th Aug - Ignores multiple rejected from same level, if rejected by base once, application assigned to another base and rejection would not reject the application n-1 has to reject it. 
            Integer rejectedCountByLevel = 0;
            Set<String> rejectedLevels = new Set<String>();
            for( Loan_Application_Approval__c approval: rejectedApprovals ){
                if( !rejectedLevels.contains( approval.Type__c ) ){
                    rejectedLevels.add( approval.Type__c );
                    rejectedCountByLevel++;
                }
            }

            if(mapOfLoanIdVsApplicantCaste.containsKey(loanApp.Id) && (mapOfLoanIdVsApplicantCaste.get(loanApp.Id)=='SC' || mapOfLoanIdVsApplicantCaste.get(loanApp.Id)=='ST' )){

                /*Code Seperated for 2W*/
                if(loanApp.RecordTypeId == recordTypeIdTwo){
                    loanApplications.add(
                        new Loan_Application__c(
                            Id = loanApp.Id,
                            Stage__c = rejectedCountByLevel >= 1 ? GlobalConstants.REJECTED : loanApp.Stage__c,// > changed to >=
                            Approval_Status__c ='Credit Rejected',
                            Sub_Stage__c = 'Rejected'
                        )
                    );
                    
                }
                else{
                    loanApplications.add(
                        new Loan_Application__c(
                            Id = loanApp.Id,
                            Stage__c = rejectedCountByLevel > 1 ? GlobalConstants.REJECTED : loanApp.Stage__c,
                            Approval_Status__c ='Credit Rejected',
                            Sub_Stage__c = null
                        )
                    );
                    
                }
                
            } else { // SFAU-5012 | Application should get rejected one the first rejection if was not SC / ST Case
                loanApplications.add(
                    new Loan_Application__c(
                        Id = loanApp.Id,
                        Stage__c = GlobalConstants.REJECTED,
                        Approval_Status__c ='Credit Rejected',
                        Sub_Stage__c = null
                    )
                );
            }
        }
            
        return loanApplications;
    }

    public static Loan_Application_Approval__c createRCMApproval( Id loanApplicationId ){
        if( loanApplicationId == NULL ) throw new AUSFApproverException( 'Invalid details were passed. Loan Application Id is required to send RCM Approval' );

        Loan_Application__c loanApp = [ SELECT Id, Branch_Master__r.Region__c FROM Loan_Application__c WHERE Id =: loanApplicationId ];

        Set<Id> branchIds = new Set<Id>{
            loanApp.Branch_Master__r.Region__c
        };
        branchIds.remove( null );

        AccountTeamMember regionalCreditManager = getRegionalCreditManager( branchIds );

        if(regionalCreditManager == null || [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Approver__c =: regionalCreditManager.UserId AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Archived__c = FALSE ] > 0) return null;

        Loan_Application_Approval__c rcmApproval =  new Loan_Application_Approval__c(
            Loan_Application__c = loanApplicationId,
            Approver__c = regionalCreditManager.UserId,
            Approver_Level__c = getApprovalLevel( regionalCreditManager.Approver_Level__c ),
            Deviation_Level__c = getDeviationLevel( regionalCreditManager.Deviation_Level__c ),
            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Approval_Type__c = 'Credit',
            Type__c = 'Highest'
        );
        insert rcmApproval;

        return rcmApproval;
    }

    public static AccountTeamMember getRegionalCreditManager(Set<Id> branchIds){
        if( branchIds.isEmpty() ) throw new AUSFApproverException( 'Region not mapped to Loan Application branch.' );


        AccountTeamMember[] teamMembers = [ SELECT Approver_Level__c, Deviation_Level__c, UserId FROM AccountTeamMember WHERE AccountId IN: branchIds AND TeamMemberRole =: 'Credit' AND User.IsActive = TRUE ];
        map<Id, Integer> assigneeVsAssignedCount = getTeamMemberBasedOnRoundRobin( teamMembers );

        if(assigneeVsAssignedCount == null) return null;
        System.debug(' === assigneeVsAssignedCount ==> ' + JSON.serializePretty(assigneeVsAssignedCount));
        AccountTeamMember userWithLeastTasks;
        Integer minCount;
        for(AccountTeamMember atm: teamMembers){
            if(minCount == null && assigneeVsAssignedCount.containsKey(atm.UserId)){
                minCount = assigneeVsAssignedCount.get(atm.UserId);
                userWithLeastTasks = atm;
            }
            if(!assigneeVsAssignedCount.containsKey(atm.UserId) || (assigneeVsAssignedCount.containsKey(atm.UserId) && assigneeVsAssignedCount.get(atm.UserId) == 0)){
                // Team member doesn't have any assigned task
                return atm;
            } else if(minCount != null && assigneeVsAssignedCount.get(atm.UserId) < minCount){
                userWithLeastTasks = atm;
            }
        }
        return userWithLeastTasks;
    }

    public static AccountTeamMember getMemberWithLeastWork( AccountTeamMember[] teamMembers, map<Id, Integer> assigneeVsAssignedCount ){
        AccountTeamMember userWithLeastTasks;
        Integer minCount;
        for(AccountTeamMember atm: teamMembers){
            if(minCount == null && assigneeVsAssignedCount.containsKey(atm.UserId)){
                minCount = assigneeVsAssignedCount.get(atm.UserId);
                userWithLeastTasks = atm;
            }
            if(!assigneeVsAssignedCount.containsKey(atm.UserId) || (assigneeVsAssignedCount.containsKey(atm.UserId) && assigneeVsAssignedCount.get(atm.UserId) == 0)){
                // Team member doesn't have any assigned task
                return atm;
            } else if(minCount != null && assigneeVsAssignedCount.get(atm.UserId) < minCount){
                minCount = assigneeVsAssignedCount.get(atm.UserId);
                userWithLeastTasks = atm;
            }
        }
        return userWithLeastTasks;
    }

    /**
     * @param senderId - UserId of the person currently forwarding the case
     * @param receiverId - UserId of the person currently to whom the case is currently being forwarded
     * @description If the case is being forwarded to a person of higher authority than the sender
     * Valid for Pricing Authorities only
     * eg --  P4(sender) < P5(receiver) returns true
     */
    public static Boolean isForwardedToHigherAuth(Id senderId, Id receiverId, String strApprovalType, String strLoanId){
        Set<Id> approverIds = new Set<Id>{ senderId, receiverId };
        map<Id, String> userAuthority = new map<Id, String>();
        map<Id, String> userDeviation = new map<Id, String>();
        Boolean booltoReturn = false;
        String[] teamRoles = strApprovalType == GlobalConstants.APPROVAL_TYPE_CREDIT ? new String[]{ GlobalConstants.APPROVAL_TYPE_CREDIT } : Label.PricingTeamMemberRoles.split(',');
        if(strLoanId != null && strLoanId != ''){
            Set<Id> setAccId = new Set<Id>();
            Loan_Application__c objLoan = [SELECT Id,Branch_Master__c,Branch_Master__r.State__c,Branch_Master__r.Region__c,Branch_Master__r.Business_HUB__c,Branch_Master__r.Zone__c,Branch_Master__r.National__c from Loan_Application__c where Id = :strLoanId Limit 1];
            setAccId.add(objLoan.Branch_Master__c);
            setAccId.add(objLoan.Branch_Master__r.State__c);
            setAccId.add(objLoan.Branch_Master__r.Region__c);
            setAccId.add(objLoan.Branch_Master__r.Business_HUB__c);
            setAccId.add(objLoan.Branch_Master__r.Zone__c);
            setAccId.add(objLoan.Branch_Master__r.National__c);
            for(AccountTeamMember atm: [ SELECT Approver_Level__c,Deviation_Level__c, UserId,AccountId FROM AccountTeamMember WHERE AccountId IN :setAccId AND UserId IN: approverIds AND Active__c != FALSE AND TeamMemberRole IN: teamRoles AND User.IsActive = true ]){ //GlobalConstants.APPROVAL_TYPE_PRICING
                String[] levels = atm.Approver_Level__c.split(';');
                userAuthority.put( atm.UserId,  levels[ levels.size() - 1 ] );
                userDeviation.put( atm.UserId, atm.Deviation_Level__c );
            }
        }
        else{
            // SFAU-4461 -- Addition of Active and Approval Type filters ( RBM Team member can have same user with Approver level blank )
            for(AccountTeamMember atm: [ SELECT Approver_Level__c,Deviation_Level__c, UserId FROM AccountTeamMember WHERE UserId IN: approverIds AND Active__c != FALSE AND TeamMemberRole IN: teamRoles AND User.IsActive = true ]){ //GlobalConstants.APPROVAL_TYPE_PRICING
                userAuthority.put( atm.UserId, atm.Approver_Level__c );
                userDeviation.put( atm.UserId, atm.Deviation_Level__c );
            }
        }
        if(strApprovalType == GlobalConstants.APPROVAL_TYPE_PRICING){
            system.debug('%%% '+booltoReturn);
            booltoReturn = getPricingAuthLevel(userAuthority.get(senderId)) < getPricingAuthLevel(userAuthority.get(receiverId));
        }
        else{
            booltoReturn = (getCreditAuthLevel( userAuthority.get(receiverId) ) > getCreditAuthLevel( userAuthority.get(senderId) ) ||
                (getCreditAuthLevel( userAuthority.get(senderId) ) == getCreditAuthLevel( userAuthority.get(receiverId) ) &&
                getCreditDeviationLevel( userDeviation.get(receiverId) ) > getCreditDeviationLevel( userDeviation.get(senderId) )));
            
                system.debug('%%% '+booltoReturn);
        }
        System.debug(JSON.serializePretty(userAuthority) + '\n' + JSON.serializePretty(userDeviation));
        //return getPricingAuthLevel(userAuthority.get(senderId)) < getPricingAuthLevel(userAuthority.get(receiverId));
        return booltoReturn;
    }

    public static map<Id, Integer> getTeamMemberBasedOnRoundRobin( AccountTeamMember[] teamMembers ){
        Set<Id> approverIds = new Set<Id>();
        for(AccountTeamMember atm: teamMembers){
            approverIds.add(atm.UserId);
        }
        approverIds.remove( null );

        map<Id, Integer> approverAssignedTasks = new map<Id, Integer>();
        if( approverIds.isEmpty() )
            return approverAssignedTasks;

        for(AggregateResult aggr: [ SELECT COUNT(Id) assignedCount, Approver__c FROM LOAN_APPLICATION_APPROVAL__c WHERE Approver__c IN: approverIds AND Archived__c = FALSE AND Approval_Status__c = 'Pending' AND createddate >= LAST_N_DAYS:30 GROUP BY Approver__c LIMIT 50000 ]){
            approverAssignedTasks.put(
                (Id)aggr.get('Approver__c'),
                (Integer)aggr.get('assignedCount')
            );
        } 
        // if(approverAssignedTasks.isEmpty()) throw new AUSFApproverException( 'Assignment failed! Eligible user not found' );

        return approverAssignedTasks;
    }

    public static String getApproverApprovalAuthority( Set<Id> loanIds, String approvalType, String selectedApproverLevel ){
        Loan_Application_Approval__c[] approvals = [ SELECT Id, Approver_Level__c, Deviation_Level__c, Type__c, Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIds AND Approval_Status__c =: GlobalConstants.APPROVAL_STATUS_PENDING AND Approval_Type__c =: approvalType AND Archived__c = FALSE ORDER BY Type__c ];
        System.debug(' === approvals ==> ' + JSON.serializePretty(approvals));
        // map<String, Loan_Application_Approval__c[]> approversByType = Utility.getApprovalsByType( approvals );

        map<String, Loan_Application_Approval__c[]> levelToApprovals = new map<String, Loan_Application_Approval__c[]>();
        for( Loan_Application_Approval__c approval: approvals ){
            String level = approval.Approver_Level__c + (String.isNotBlank(approval.Deviation_Level__c) ? approval.Deviation_Level__c : '');
            if( !levelToApprovals.containsKey(level) ){
                levelToApprovals.put( level, new Loan_Application_Approval__c[0] );
            }
            levelToApprovals.get(level).add( approval );
        }
        System.debug(' == levelToApprovals ==> ' + JSON.serializePretty(levelToApprovals));
        AUSFLoanApplicationAssignmentHelper assignments = new AUSFLoanApplicationAssignmentHelper( approvalType, new map<String, String>() );
        map<String, String> mapOfNextKeys = AUSFLoanApplicationAssignmentHelper.mapOfNextKey;



        String approvalLevel = selectedApproverLevel;
        while( mapOfNextKeys.containsKey(approvalLevel) ){
            if( levelToApprovals.containsKey( approvalLevel ) ){
                String currentLevel = levelToApprovals.get( approvalLevel )[0].Type__c;
                return approvalLevel == selectedApproverLevel ? currentLevel : getNextLowerApprovalType( new String[]{ currentLevel } );
            }
            approvalLevel = mapOfNextKeys.get( approvalLevel );
        }

        // approvalLevel = '', approvalType = 'Pricing', approvals[0].Approver_Level__c = 'L1S3', selectedApproverLevel = 'L2S3'
        if(String.isBlank( approvalLevel ) && !approvals.isEmpty() && !isMovingToHigherAuthority( approvalType, approvals[0].Approver_Level__c, selectedApproverLevel )){
            return getNextLowerApprovalType( new String[]{ approvals[0].Type__c } );
        }
        
        return 'Highest';
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

    /**
     * SFAU-4091
     * 11th Sept 23
     * Calculates vehicle cost based on the valuation amount received from callback
     * updates Is_Valuation_Verification_Required__c flag that denotes valuation has been verified by Credit
     * decides if BRE re run is required or not based on updates done on collateral
     */
    @AuraEnabled
    public static void updateVehicleCostBasedOnValuationRecieved( Id loanId ){

        Collateral__c collateralRecord = [ SELECT Loan__c, Loan__r.BRE_ReRun_Required__c, Vehicle_Cost__c, Valuation_Amount__c, IBB_Value__c, Certified_Value__c, Other_Funding_Total__c FROM Collateral__c WHERE Loan__c =: loanId AND Is_Deleted__c = false AND RecordTypeId IN: GlobalConstants.colRecordTypeIds LIMIT 1 ],
            updatedCollateral = AUSFVehicleController.calculateVehicleCost( collateralRecord );

        update updatedCollateral;
        update new Loan_Application__c(
            Id = collateralRecord.Loan__c,
            Is_Valuation_Verification_Required__c = false,
            BRE_ReRun_Required__c = collateralRecord.Loan__r.BRE_ReRun_Required__c && updatedCollateral.Vehicle_Cost__c != collateralRecord.Vehicle_Cost__c
        );
    }

    // Call Credit Sanction Notifications
    public static void callCreditSanction(String loanId){
        Notification_Event__e notificationEvent = new Notification_Event__e();
        notificationEvent.sObjectId__c = loanId;
        notificationEvent.Trigger_Point__c = 'Credit Sanction';
        EventBus.publish(notificationEvent);
    }

    public class AUSFApproverException extends Exception{ }

    public class loanAppWrap{
        @AuraEnabled
        public Loan_Application__c loanApp;
        @AuraEnabled
        public Boolean isTwoWheeler;
        @AuraEnabled
        public Boolean isCreditStage;
        @AuraEnabled
        public Boolean isPricingStage;
        @AuraEnabled
        public Boolean isQueueOwner;
        @AuraEnabled
        public Boolean isGenerateCibilAgain;
        @AuraEnabled
        public Boolean isRunFIAgain;
        @AuraEnabled
        public Boolean isRunValuationAgain;
        @AuraEnabled
        public Boolean showComp;
        @AuraEnabled public Boolean needPreApprovalAction;
        @AuraEnabled public Boolean isBreReRunRequired;
        @AuraEnabled public Boolean allowRevoke;
        @AuraEnabled public Boolean allowReassignment;
    }
    
    public class LevelVsLoanApproverWrapper{
        @AuraEnabled
        public List<String> levels;
        @AuraEnabled
        public Map<String,List<Loan_Application_Approval__c>> mapOfApproverLevelVsAccountTeam;
    }
    
    public class LevelApproverWrapper{
        @AuraEnabled public Boolean hasActiveApproval{ get; set; }
        @AuraEnabled
        public List<String> levels;
        @AuraEnabled
        public Map<String,List<SObject>> mapOfApproverLevelVsAccountTeam;
        public LevelApproverWrapper(){
            hasActiveApproval = false;
            levels = new List<STring>();
            mapOfApproverLevelVsAccountTeam = new Map<String,List<SObject>>();
        }
    }
}