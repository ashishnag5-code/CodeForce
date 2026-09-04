/**
 * @author        Joshna
 * @date          11-Jun-2023
 * @description   Handler for Asynchronous Events
 * @reference     TAT creation
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  11-Jun-2023     Initial creation - added handleAsyncEvents
 * Yash                    19-Dec-2023     Updated COde

 */
public without sharing class AsynchronousEventTriggerHelper {
    static final Map<String, String> LOAN_APP_FIELD_NAME_MAP = new Map<String, String>{'Loan_Application_Approval__c' => 'Loan_Application__c',
        'Assignment__c' => 'Loan_Application__c', 'Field_Investigation__c' => 'Loan_Application__c'};
    static final Map<String, String> APPROVAL_STATUS_MAP = new Map<String, String>{'Approved' => 'Request Approved', 'Rejected' => 'Request Rejected',
        'Pending' => 'Approval Initiated', 'Send Back To RO' => 'Sent Back from Approval', 'Forwarded' => 'Request Forwarded'};
    static final Map<String, String> OPS_STATUS_MAP = new Map<String, String>{'Complete' => 'Ops Review Completed', 'Pending' => 'Ops Review Initiated'};
    static final Map<String, String> FI_STATUS_MAP = new Map<String, String>{'Positive' => 'FI Completed', 'Negative' => 'FI Completed', 'Waived off' => 'FI Waived Off',
        'Cancelled' => 'FI Cancelled', 'In Progress' => 'FI Initiated'};
    static Map<String, Integer> loanStagesFor2W = new Map<String, Integer>{'QDE' => 1, 'Credit' => 2, 'Pricing' => 3, 'DDE' => 4, 'PSD' => 5, 'Ops - Maker' => 6, 'Ops - Author' => 7, 'PDD' => 8};
    static Map<String, Integer> loanStagesFor4W = new Map<String, Integer>{'QDE' => 1, 'DDE' => 2, 'Credit' => 3, 'Pricing' => 4, 'PSD' => 5, 'Ops - Maker' => 6, 'Ops - Author' => 7, 'PDD' => 8};

    static List<Loan_TAT__c> loanTATRecords = new List<Loan_TAT__c>();
    static Map<Id, Map<String, Loan_TAT__c>> existingLoanTATRecords = new Map<Id, Map<String, Loan_TAT__c>>();
    public static Id defaultBusinessHoursId;
    static Map<Id, Decimal> ltvMap = new Map<Id, Decimal>();
    static Map<String, Integer> stageMap;

    public static void handleAsyncEvents(List<Asynchronous_Event__e> newRecords) {
        List<Asynchronous_Event__e> tatEventsList = new List<Asynchronous_Event__e>();
        for (Asynchronous_Event__e each : newRecords) {
            // adding if block here though right now its only used for TAT so that this can be extended in future for other events
            // when event count increases to more than 3, update this to a switch statement for better performance
            if (each.Event_Type__c == 'TAT') {
                tatEventsList.add(each);
            }
        }
        handleTAT(tatEventsList);
    }

    /* this method accepts records of type Loan Application, Loan Approval, FI, Loan Assignment
     * using the record type, creates TAT on loan application
     * Technical Requirement - 
     * Loan Application - On create (OR) If stage changes (OR) sub-stage changes create a record
     * On new stage change set owner to RM if stage belongs to them, else set it to pending in queue
     * FI Investigation - On create (OR) if owner changes (OR) status changes
     * Loan Approval Comments - On create (OR) if approver changes (OR) assign to queue checkbox changes
     * During this, validate related FI closure status. If open, don't log any numbers
     * Assignment - On create (OR) if owner changes
     */
    public static void handleTAT(List<Asynchronous_Event__e> newRecords) {
        if (newRecords.isEmpty()) {
            return;
        }
        List<Loan_Application__c> loanApplicationRecords = new List<Loan_Application__c>();
        List<Loan_Application_Approval__c> loanApplicationApprovalRecords = new List<Loan_Application_Approval__c>();
        List<Assignment__c> loanApplicationAssignmentRecords = new List<Assignment__c>();
        Loan_Application__c newLoanRecord;
        Loan_Application__c oldLoanRecord;
        Loan_Application_Approval__c newLoanApprovalRecord;
        Loan_Application_Approval__c oldLoanApprovalRecord;
        Assignment__c newLoanAssignmentRecord;
        Assignment__c oldLoanAssignmentRecord;
        Field_Investigation__c newFIRecord;
        Field_Investigation__c oldFIRecord;
        Set<Id> recordIdsForTATQuery = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();

        try {
            for (Asynchronous_Event__e each : newRecords) {
                if (String.isBlank(each.Object_API_Name__c)) {
                    continue;
                }
                if (String.isBlank(each.Old_Records_Payload__c) && each.Object_API_Name__c == 'Loan_Application__c') {
                    newLoanRecord = (Loan_Application__c) JSON.deserialize(each.New_Records_Payload__c, Loan_Application__c.class);
                    loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = newLoanRecord.Id, Start_Date_Time__c = each.Event_Date_Time__c, Stage_Activity__c = newLoanRecord.Stage__c,
                        Owner__c = newLoanRecord.OwnerId, Assigned_To__c = 'User', Decision_Remarks__c = newLoanRecord.Remarks__c, Loan_Amount__c = newLoanRecord.Total_Loan_Amount__c,
                        ROI__c = newLoanRecord.ROI__c, Tenure__c = newLoanRecord.Tenure__c, Action_Type__c = 'Loan Created', Actor__c = each.Logged_In_User__c,
                        DO_Status__c = newLoanRecord.DO_Status__c, Sanction_Status__c = newLoanRecord.Sanction_Status__c));
                } else {
                    
                    SObject recordInstance = (SObject) JSON.deserialize(each.New_Records_Payload__c, SObject.class);
                    if (each.Object_API_Name__c == 'Loan_Application__c') {
                        recordIdsForTATQuery.add(recordInstance.Id);
                    } else if (LOAN_APP_FIELD_NAME_MAP.get(each.Object_API_Name__c) != null && recordInstance.get(LOAN_APP_FIELD_NAME_MAP.get(each.Object_API_Name__c)) != null) {
                        recordIdsForTATQuery.add((Id) recordInstance.get(LOAN_APP_FIELD_NAME_MAP.get(each.Object_API_Name__c)));
                    }
                }
                if (each.Object_API_Name__c == 'Field_Investigation__c') {
                    newFIRecord = (Field_Investigation__c) JSON.deserialize(each.New_Records_Payload__c, Field_Investigation__c.class);
                    userIds.add(newFIRecord.OwnerId);
                }
            }
            if (recordIdsForTATQuery.isEmpty() && loanTATRecords.isEmpty()) {
                return;
            }
            if (!recordIdsForTATQuery.isEmpty()) {
                for (BusinessHours each : [SELECT Id FROM BusinessHours WHERE IsDefault = TRUE]) {
                    defaultBusinessHoursId = each.Id;
                }
    
                Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
                Boolean hasLoanApplications = false;
                String keyForInput;
                for (Loan_Application__c each : [SELECT Id, Stage__c, Branch_Master__r.State__r.Business_Hours__c, Application_FI_Status__c, Ops_Status__c, Total_Loan_Amount__c, Tenure__c, ROI__c,
                    OwnerId, RecordType.DeveloperName, Remarks__c, RO_Discrepancy_Remarks__c, //SFAU-4293 - Discrepancy Remarks not being captured
                    (SELECT Id, Type__c, Field_Investigation__c, Loan_Application__c, Loan_Application_Approval__c, Loan_Application_Assignment__c, Owner__c,
                        Stage_Activity__c, Start_Date_Time__c, Assigned_To__c, End_Date_Time__c FROM Loan_TAT__r WHERE End_Date_Time__c = null),
                    (SELECT Id, Loan_Application__c, Remarks__c, Approver__c, Assigned_to_Queue__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c IN (null, 'Pending')),
                    (SELECT Id, Loan_Application__c, Remarks__c, Status__c, OwnerId FROM Assignments__r WHERE Status__c = 'Pending'),
                    (SELECT LTV__c FROM Collaterals__r WHERE RecordType.DeveloperName IN ('New', 'Used_Cash_on_Wheels') LIMIT 1)
                    FROM Loan_Application__c WHERE Id IN :recordIdsForTATQuery]) {
                    // store a map of loan ID to 
                    // type + parent ID to record map
                    Map<String, Loan_TAT__c> existingTATPerLoan = new Map<String, Loan_TAT__c>();
                    for (Loan_TAT__c eachTAT : each.Loan_TAT__r) {
                        if (eachTAT.Type__c == 'FI') {
                            keyForInput = 'FI' + String.valueOf(eachTAT.Field_Investigation__c);
                        } else if (eachTAT.Type__c == 'Loan Approval') {
                            keyForInput = 'Loan Approval' + String.valueOf(eachTAT.Loan_Application_Approval__c);
                        } else if (eachTAT.Type__c == 'Loan Assignment') {
                            keyForInput = 'Loan Assignment' + String.valueOf(eachTAT.Loan_Application_Assignment__c);
                        } else {
                            keyForInput = 'Loan' + String.valueOf(eachTAT.Loan_Application__c);
                            hasLoanApplications = true;
                        }
                        // the value is only a single record instead of a list of records because for a specific type and parent record there will only be one record
                        // where End Time = null which should be closed before a new record is created
                        existingTATPerLoan.put(keyForInput, eachTAT);
                    }
                    existingLoanTATRecords.put(each.Id, existingTATPerLoan);
                    loanApplicationMap.put(each.Id, each);
                    ltvMap.put(each.Id, null);
                    for (Collateral__c eachColl : each.Collaterals__r) {
                        ltvMap.put(each.Id, eachColl.LTV__c);
                    }
                }
    
                if (!userIds.isEmpty()) {
                    userMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);
                }

                for (Asynchronous_Event__e each : newRecords) {
                    if (String.isBlank(each.Object_API_Name__c)) {
                        continue;
                    }
                    switch on each.Object_API_Name__c {
                        when 'Loan_Application__c' {
                            /* For Loans, only for applicable stages, RO is the owner and only for those stages TAT should originate from Loan Application
                             * The previous record closure logic is only when loan application moves out of these stages or if owner changes
                             * Sub Stage - TODO as that's still under dev
                             */
                            newLoanRecord = (Loan_Application__c) JSON.deserialize(each.New_Records_Payload__c, Loan_Application__c.class);
                            if (String.isNotBlank(each.Old_Records_Payload__c)) {
                                oldLoanRecord = (Loan_Application__c) JSON.deserialize(each.Old_Records_Payload__c, Loan_Application__c.class);
                                if (oldLoanRecord.Application_FI_Status__c == newLoanRecord.Application_FI_Status__c && oldLoanRecord.Ops_Status__c == newLoanRecord.Ops_Status__c && newLoanRecord.Stage__c != 'Rejected') {
                                    String remarksToBeUpdated = (newLoanRecord.Approval_Status__c == 'Pricing Send Back To RO' || newLoanRecord.Approval_Status__c == 'Credit Send Back To RO' || newLoanRecord.Approval_Status__c == 'Credit Approved' || newLoanRecord.Approval_Status__c == 'Pricing Approved')?oldLoanRecord.Remarks__c : newLoanRecord.Remarks__c;
                                    addUpdatedTATRecord('Loan', newLoanRecord.Id, loanApplicationMap.get(newLoanRecord.Id), each.Event_Date_Time__c, null, remarksToBeUpdated);
                                }
                            }
                            if (oldLoanRecord != null && oldLoanRecord.Application_FI_Status__c != newLoanRecord.Application_FI_Status__c && newLoanRecord.Stage__c == 'Credit') {
                                pauseCreditTAT(loanApplicationMap.get(newLoanRecord.Id), each.Event_Date_Time__c, each.Logged_In_User__c, false);
                            } else if (oldLoanRecord != null && oldLoanRecord.Ops_Status__c != newLoanRecord.Ops_Status__c && (oldLoanRecord.Ops_Status__c == 'Discrepancy' || newLoanRecord.Ops_Status__c == 'Discrepancy')) {
                                pauseOpsTAT(loanApplicationMap.get(newLoanRecord.Id), each.Event_Date_Time__c, each.Logged_In_User__c);
                            } else if (oldLoanRecord != null && oldLoanRecord.Ops_Status__c != newLoanRecord.Ops_Status__c && (oldLoanRecord.Ops_Status__c == 'Credit Discrepancy' || newLoanRecord.Ops_Status__c == 'Credit Discrepancy')) {
                                pauseCreditTAT(loanApplicationMap.get(newLoanRecord.Id), each.Event_Date_Time__c, each.Logged_In_User__c, true);
                            } else {
                                if (oldLoanRecord.Application_FI_Status__c == newLoanRecord.Application_FI_Status__c && oldLoanRecord.Ops_Status__c == newLoanRecord.Ops_Status__c) {
                                    stageMap = loanApplicationMap.get(newLoanRecord.Id).RecordType.DeveloperName.contains('Two') ? loanStagesFor2W : loanStagesFor4W;
                                    String actionType = oldLoanRecord.OwnerId != newLoanRecord.OwnerId ? 'Loan Reassigned'
                                        : stageMap.get(oldLoanRecord.Stage__c) < stageMap.get(newLoanRecord.Stage__c) ? 'Loan Submitted' : 'Loan Sent Back';
                                    if (oldLoanRecord.OwnerId != newLoanRecord.OwnerId) {
                                        actionType = 'Loan Reassigned';
                                    } else if (oldLoanRecord.DO_Status__c != newLoanRecord.DO_Status__c) {
                                        actionType = 'DO Letter Generated';
                                    } else if (oldLoanRecord.Sanction_Status__c != newLoanRecord.Sanction_Status__c) {
                                        actionType = 'Sanction Letter Generated';
                                    } else if (stageMap.get(oldLoanRecord.Stage__c) < stageMap.get(newLoanRecord.Stage__c)) {
                                        actionType = 'Loan Submitted';
                                    } else {
                                        actionType = 'Loan Sent Back';
                                    }
                                    String decisionRemarks = '';
                                    system.debug('test app records '+newLoanRecord+' oldRecord '+oldLoanRecord);
                                    if(actionType == 'Loan Submitted' && newLoanRecord.Stage__c == 'DDE'){
                                        decisionRemarks = newLoanRecord.Remarks__c;
                                    }
                                    if(actionType == 'Loan Submitted' && (newLoanRecord.Approval_Status__c == 'Credit Approved' || newLoanRecord.Approval_Status__c == 'Pricing Approved') ){
                                        decisionRemarks = newLoanRecord.Remarks__c;
                                    }
                                    else{
                                        decisionRemarks = (actionType == 'Loan Sent Back')?newLoanRecord.Remarks__c:oldLoanRecord.Remarks__c;
                                        decisionRemarks = (actionType == 'Loan Submitted' && newLoanRecord.Stage__c == 'Credit' && oldLoanRecord.Stage__c == 'DDE')?newLoanRecord.Remarks__c:decisionRemarks;
                                        decisionRemarks = (actionType == 'Loan Sent Back' && newLoanRecord.Stage__c == 'Rejected')?setRejectionDecisionRemarks(newLoanRecord):decisionRemarks;
                                    }
                                    actionType = (newLoanRecord.Stage__c == 'Rejected')?'Rejected':actionType;
                                    if(actionType == 'Loan Submitted' && oldLoanRecord.Stage__c=='PSD' &&  newLoanRecord.Stage__c == 'Ops Maker'){
                                        decisionRemarks = '';
                                    }
                                    loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = newLoanRecord.Id, Start_Date_Time__c = each.Event_Date_Time__c,
                                        Stage_Activity__c = newLoanRecord.Stage__c, Owner__c = newLoanRecord.OwnerId, Assigned_To__c = 'User', Decision_Remarks__c = decisionRemarks,//newLoanRecord.Remarks__c
                                        LTV__c = ltvMap.get(newLoanRecord.Id), Tenure__c = loanApplicationMap?.get(newLoanRecord.Id)?.Tenure__c, ROI__c = loanApplicationMap?.get(newLoanRecord.Id)?.ROI__c,
                                        Loan_Amount__c = loanApplicationMap?.get(newLoanRecord.Id)?.Total_Loan_Amount__c, Action_Type__c = actionType, Actor__c = each.Logged_In_User__c,
                                        DO_Status__c = newLoanRecord.DO_Status__c, Sanction_Status__c = newLoanRecord.Sanction_Status__c));
                                }
                            }
                        } when 'Loan_Application_Approval__c' {
                            /* These records apply for Credit & Pricing stages - as soon as this is created, if its assigned to queue, a queue record is created
                             * when it moves out of queue, the user assignment record is created. If approved, the current record is closed as the loan automatically
                             * moves to the subsequent stages. The record is considered closed when status <> Pending or blank
                             */
                            newLoanApprovalRecord = (Loan_Application_Approval__c) JSON.deserialize(each.New_Records_Payload__c, Loan_Application_Approval__c.class);
                            String approvalActionType = 'Loan Approval Initiated';
                            if(newLoanApprovalRecord.Approval_Type__c == 'Cancellation' || newLoanApprovalRecord.Approval_Type__c == 'RBMTatkal' || newLoanApprovalRecord.Approval_Type__c == 'Sanction Tatkal'){
                                approvalActionType = (String.isNotBlank(newLoanApprovalRecord.Document_Name__c))?newLoanApprovalRecord.Document_Name__c+' Approval Initiated':approvalActionType;
                            }
                            /*Forwarded Application remarkds*/

                            String tobeUpdatedRemarks = (newLoanApprovalRecord.Forwarded_By__c !=null || String.isNotBlank(newLoanApprovalRecord.Forwarded_By_Remarks__c))?newLoanApprovalRecord.Forwarded_By_Remarks__c : newLoanApprovalRecord.Remarks__c;
                            /******** */
                            if (String.isNotBlank(each.Old_Records_Payload__c)) {
                                oldLoanApprovalRecord = (Loan_Application_Approval__c) JSON.deserialize(each.Old_Records_Payload__c, Loan_Application_Approval__c.class);
                                String actionType = oldLoanApprovalRecord.Approver__c != newLoanApprovalRecord.Approver__c ||
                                    oldLoanApprovalRecord.Assigned_to_Queue__c != oldLoanApprovalRecord.Assigned_to_Queue__c ? 'Approval Reassigned'
                                    : (APPROVAL_STATUS_MAP.containsKey(newLoanApprovalRecord.Approval_Status__c) ? APPROVAL_STATUS_MAP.get(newLoanApprovalRecord.Approval_Status__c)
                                        : newLoanApprovalRecord.Approval_Status__c);
                                actionType = newLoanApprovalRecord.Approval_Type__c != null ? newLoanApprovalRecord.Approval_Type__c + ' ' + actionType : actionType;
                                if(String.isNotBlank(newLoanApprovalRecord.Document_Name__c)){
                                    actionType = newLoanApprovalRecord.Document_Name__c+' '+actionType;
                                }
                                
                                addUpdatedTATRecord('Loan Approval', newLoanApprovalRecord.Id, loanApplicationMap.get(newLoanApprovalRecord.Loan_Application__c), each.Event_Date_Time__c,
                                    actionType, tobeUpdatedRemarks);//newLoanApprovalRecord.Remarks__c
                            }
                            if ((String.isBlank(newLoanApprovalRecord.Approval_Status__c) || newLoanApprovalRecord.Approval_Status__c == 'Pending') && newLoanApprovalRecord.Is_Assigned_Approver__c) {
                                Boolean overrideTAT = loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Stage__c == 'Credit' &&
                                    (loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Application_FI_Status__c == 'Assigned' ||
                                    loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Application_FI_Status__c == 'In Progress');
                                loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = newLoanApprovalRecord.Loan_Application__c, Start_Date_Time__c = each.Event_Date_Time__c,
                                    Stage_Activity__c = loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Stage__c,
                                    Owner__c = newLoanApprovalRecord.Approver__c, Assigned_To__c = newLoanApprovalRecord.Assigned_to_Queue__c ? 'Queue' : 'User',
                                    Override_TAT__c = overrideTAT, Remarks__c = overrideTAT ? 'TAT supressed to 0 due to pending FIs' : null,
                                    Loan_Application_Approval__c = newLoanApprovalRecord.Id, Decision_Remarks__c = tobeUpdatedRemarks,
                                    LTV__c = ltvMap.get(newLoanApprovalRecord.Loan_Application__c), Tenure__c = loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Tenure__c,
                                    ROI__c = loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.ROI__c,
                                    Loan_Amount__c = loanApplicationMap?.get(newLoanApprovalRecord.Loan_Application__c)?.Total_Loan_Amount__c, Action_Type__c = approvalActionType,
                                    Actor__c = each.Logged_In_User__c));
                            }
                        } when 'Assignment__c' {
                            /* These records apply for parallel flow for Ops PDD, Ops KYC & sequential flow for Ops Disbursement
                             * Ops disbursement records are closed on loan stage update. The parallel flow records are closed when the record status is marked complete
                             */
                            newLoanAssignmentRecord = (Assignment__c) JSON.deserialize(each.New_Records_Payload__c, Assignment__c.class);
                            oldLoanAssignmentRecord = null;
                            if (String.isNotBlank(each.Old_Records_Payload__c)) {
                                oldLoanAssignmentRecord = (Assignment__c) JSON.deserialize(each.Old_Records_Payload__c, Assignment__c.class);
                                String actionType = oldLoanAssignmentRecord.OwnerId != newLoanAssignmentRecord.OwnerId ? 'Loan Reassigned'
                                    : (OPS_STATUS_MAP.containsKey(newLoanAssignmentRecord.Status__c) ? OPS_STATUS_MAP.get(newLoanAssignmentRecord.Status__c) : newLoanAssignmentRecord.Status__c);
                                if (oldLoanAssignmentRecord.OwnerId != newLoanAssignmentRecord.OwnerId && newLoanAssignmentRecord.OwnerId == loanApplicationMap.get(newLoanAssignmentRecord.Loan_Application__c).OwnerId) {
                                    actionType = 'Loan Sent Back';
                                }
                                addUpdatedTATRecord('Loan Assignment', newLoanAssignmentRecord.Id, loanApplicationMap.get(newLoanAssignmentRecord.Loan_Application__c), each.Event_Date_Time__c,
                                    actionType, newLoanAssignmentRecord.Remarks__c);
                            }
                            Boolean isUser = String.valueOf(newLoanAssignmentRecord.OwnerId).startsWith('005');
                            // For KYC records once closed, no new record creation is required
                            if (newLoanAssignmentRecord.Status__c == 'Complete') {
                                continue;
                            }
                            loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = newLoanAssignmentRecord.Loan_Application__c, Start_Date_Time__c = each.Event_Date_Time__c,
                                Stage_Activity__c = loanApplicationMap?.get(newLoanAssignmentRecord.Loan_Application__c)?.Stage__c, Loan_Application_Assignment__c = newLoanAssignmentRecord.Id,
                                Owner__c = isUser ? newLoanAssignmentRecord.OwnerId : null, Assigned_To__c = isUser ? 'User' : 'Queue', Decision_Remarks__c = newLoanAssignmentRecord.Remarks__c,
                                LTV__c = ltvMap.get(newLoanAssignmentRecord.Loan_Application__c), Tenure__c = loanApplicationMap?.get(newLoanAssignmentRecord.Loan_Application__c)?.Tenure__c,
                                ROI__c = loanApplicationMap?.get(newLoanAssignmentRecord.Loan_Application__c)?.ROI__c,
                                Loan_Amount__c = loanApplicationMap?.get(newLoanAssignmentRecord.Loan_Application__c)?.Total_Loan_Amount__c, Action_Type__c = 'Ops Review Initiated',
                                Actor__c = each.Logged_In_User__c));
                        } when 'Field_Investigation__c' {
                            system.debug('flow in fi');
                            // These records are for parallel FI flow. Record is closed when status is neither In Progress nor blank
                            // When CM is the owner, this is considered to be in queue
                            newFIRecord = (Field_Investigation__c) JSON.deserialize(each.New_Records_Payload__c, Field_Investigation__c.class);
                            if (String.isNotBlank(each.Old_Records_Payload__c)) {
                                //String decisionRemarks = (oldFIRecord.FI_Agent__c != newFIRecord.FI_Agent__c)?'Record is assigned to new agent':'Test Remark';
                                oldFIRecord = (Field_Investigation__c) JSON.deserialize(each.New_Records_Payload__c, Field_Investigation__c.class);
                                String actionType = (oldFIRecord.OwnerId != newFIRecord.OwnerId) || (oldFIRecord.FI_Agent__c != newFIRecord.FI_Agent__c)? 'FI Reassigned' : (FI_STATUS_MAP.containsKey(newFIRecord.FI_Status__c)
                                    ? FI_STATUS_MAP.get(newFIRecord.FI_Status__c) : newFIRecord.FI_Status__c);
                                addUpdatedTATRecord('FI', newFIRecord.Id, loanApplicationMap.get(newFIRecord.Loan_Application__c), each.Event_Date_Time__c, actionType, newFIRecord.Remark__c);
                            }
                            
                            
                            Boolean isUser = String.valueOf(newFIRecord.OwnerId).startsWith('005') && userMap?.get(newFIRecord.OwnerId)?.Profile.Name != 'Credit Manager';
    
                            if (String.isBlank(newFIRecord.FI_Status__c) || newFIRecord.FI_Status__c == 'In Progress') {
                                loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = newFIRecord.Loan_Application__c, Start_Date_Time__c = each.Event_Date_Time__c,
                                    Stage_Activity__c = loanApplicationMap?.get(newFIRecord.Loan_Application__c)?.Stage__c, Field_Investigation__c = newFIRecord.Id,
                                    Owner__c = isUser ? newFIRecord.OwnerId : null, Assigned_To__c = isUser ? 'User' : 'Queue', Decision_Remarks__c = newFIRecord.Remark__c,
                                    LTV__c = ltvMap.get(newFIRecord.Loan_Application__c), Tenure__c = loanApplicationMap?.get(newFIRecord.Loan_Application__c)?.Tenure__c,
                                    ROI__c = loanApplicationMap?.get(newFIRecord.Loan_Application__c)?.ROI__c,
                                    Loan_Amount__c = loanApplicationMap?.get(newFIRecord.Loan_Application__c)?.Total_Loan_Amount__c, Action_Type__c = 'FI Initiated',
                                    Actor__c = each.Logged_In_User__c));
                            }
                        }
                    }
                }
            }
            upsert loanTATRecords;
        } catch (Exception ex) {
            Log.error(ex, JSON.serialize(newRecords));
        }
    }

    public static String setRejectionDecisionRemarks(Loan_Application__c loanRecord){
        String rejectionRemarks = '';
        if(!String.isBlank(loanRecord.Rejection_Reason__c)){
            rejectionRemarks = 'REASON:- '+loanRecord.Rejection_Reason__c+'\n';
        }
        if(!String.isBlank(loanRecord.Rejection_Sub_Reason__c)){
            rejectionRemarks += 'SUB REASON:- '+loanRecord.Rejection_Sub_Reason__c+'\n';
        }
        if(!String.isBlank(loanRecord.Other_Rejection_Reason__c)){
            rejectionRemarks += 'OTHER REASON:- '+loanRecord.Other_Rejection_Reason__c;
        }
        return rejectionRemarks;
    }

    public static void addUpdatedTATRecord(String typeOfTAT, Id relatedRecordId, Loan_Application__c loanRecord, DateTime endDateTime, String actionType, String remarks) {
        Loan_TAT__c existingTATRecord = existingLoanTATRecords?.get(loanRecord.Id)?.get(typeOfTAT + String.valueOf(relatedRecordId));
        if (existingTATRecord == null) {
            return;
        }
        existingTATRecord.Difference_in_Ms_Business_Hours__c = BusinessHours.diff(loanRecord.Branch_Master__r.State__r.Business_Hours__c == null ? 
            defaultBusinessHoursId : loanRecord.Branch_Master__r.State__r.Business_Hours__c, existingTATRecord.Start_Date_Time__c, endDateTime);
        existingTATRecord.End_Date_Time__c = endDateTime;
        existingTATRecord.Decision_Remarks__c = remarks;
        if (String.isNotBlank(actionType)) {
            existingTATRecord.Action_Type__c = actionType;
        }
        loanTATRecords.add(existingTATRecord);
    }

    public static void pauseOpsTAT(Loan_Application__c loanRecord, DateTime endDateTime, String userId) {
        for (Assignment__c each : loanRecord.Assignments__r) {
            Loan_TAT__c existingTATRecord = existingLoanTATRecords?.get(loanRecord.Id)?.get('Loan Assignment' + String.valueOf(each.Id));
            if(Test.isRunningTest()){
                existingTATRecord = new Loan_TAT__c(Start_Date_Time__c = System.Now()-1);
            }
            if (existingTATRecord == null && !Test.isRunningTest()) {
                continue;
            }
            existingTATRecord.Difference_in_Ms_Business_Hours__c = BusinessHours.diff(loanRecord.Branch_Master__r.State__r.Business_Hours__c == null ? 
                defaultBusinessHoursId : loanRecord.Branch_Master__r.State__r.Business_Hours__c, existingTATRecord.Start_Date_Time__c, endDateTime);
            existingTATRecord.End_Date_Time__c = endDateTime;
            loanTATRecords.add(existingTATRecord);
            Boolean overrideTAT = loanRecord?.Ops_Status__c == 'Discrepancy';
            Boolean isUser = String.valueOf(each.OwnerId).startsWith('005');
            loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = each.Loan_Application__c, Start_Date_Time__c = endDateTime,
                Stage_Activity__c = loanRecord?.Stage__c, Owner__c = each.OwnerId, Assigned_To__c = isUser ? 'User' : 'Queue',
                Override_TAT__c = overrideTAT, Remarks__c = overrideTAT ? 'TAT supressed to 0 due to Ops Discrepancy' : null,
                Loan_Application_Assignment__c = each.Id, Decision_Remarks__c = String.isBlank(each.Remarks__c) ? overrideTAT ? loanRecord.Remarks__c : loanRecord.RO_Discrepancy_Remarks__c : each.Remarks__c, LTV__c = ltvMap.get(loanRecord.Id), //SFAU-4293 - Discrepancy Remarks not being captured
                Tenure__c = loanRecord.Tenure__c, ROI__c = loanRecord.ROI__c, Loan_Amount__c = loanRecord.Total_Loan_Amount__c,
                Action_Type__c = overrideTAT ? 'Ops Discrepancy Initiated' : 'Ops Review Initiated', Actor__c = userId));
        }
    }

    public static void pauseCreditTAT(Loan_Application__c loanRecord, DateTime endDateTime, String userId, Boolean isDiscrepancy) {
        String remarks = isDiscrepancy ? 'TAT supressed to 0 due to Credit Discrepancy' : 'TAT supressed to 0 due to pending FIs';
        for (Loan_Application_Approval__c each : loanRecord.Loan_Application_Approvers__r) {
            Loan_TAT__c existingTATRecord = existingLoanTATRecords?.get(loanRecord.Id)?.get('Loan Approval' + String.valueOf(each.Id));
            if(Test.isRunningTest()){
                existingTATRecord = new Loan_TAT__c(Start_Date_Time__c = System.Now()-1);
            }
            if (existingTATRecord == null && !Test.isRunningTest()) {
                continue;
            }
            existingTATRecord.Difference_in_Ms_Business_Hours__c = BusinessHours.diff(loanRecord.Branch_Master__r.State__r.Business_Hours__c == null ? 
                defaultBusinessHoursId : loanRecord.Branch_Master__r.State__r.Business_Hours__c, existingTATRecord.Start_Date_Time__c, endDateTime);
            existingTATRecord.End_Date_Time__c = endDateTime;
            loanTATRecords.add(existingTATRecord);
            Boolean overrideTAT = loanRecord?.Stage__c == 'Credit' && (loanRecord?.Application_FI_Status__c == 'New' || loanRecord?.Application_FI_Status__c == 'Assigned' || loanRecord?.Application_FI_Status__c == 'In Progress');
            if (isDiscrepancy && !overrideTAT) {
                overrideTAT = loanRecord?.Ops_Status__c == 'Credit Discrepancy';
            }
            String actionType;
            if (isDiscrepancy) {
                actionType = overrideTAT ? 'Credit Discrepancy Initiated' : 'Credit Review Resumed';
                System.debug('test the code is here');
                loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = each.Loan_Application__c, Start_Date_Time__c = endDateTime,
                    Stage_Activity__c = loanRecord?.Stage__c, Owner__c = each.Approver__c, Assigned_To__c = each.Assigned_to_Queue__c ? 'Queue' : 'User',
                    Override_TAT__c = overrideTAT, Remarks__c = overrideTAT ? remarks : null,  Actor__c = userId,
                    Loan_Application_Approval__c = each.Id, Decision_Remarks__c = loanRecord?.Remarks__c, LTV__c = ltvMap.get(loanRecord.Id),
                    Tenure__c = loanRecord.Tenure__c, ROI__c = loanRecord.ROI__c, Loan_Amount__c = loanRecord.Total_Loan_Amount__c, Action_Type__c = actionType));
                
            } else {
                actionType = overrideTAT ? 'FI Re-Initiated During Credit Approval' : 'Credit Review Resumed';
                loanTATRecords.add(new Loan_TAT__c(Loan_Application__c = each.Loan_Application__c, Start_Date_Time__c = endDateTime,
                    Stage_Activity__c = loanRecord?.Stage__c, Owner__c = each.Approver__c, Assigned_To__c = each.Assigned_to_Queue__c ? 'Queue' : 'User',
                    Override_TAT__c = overrideTAT, Remarks__c = overrideTAT ? remarks : null,  Actor__c = userId,
                    Loan_Application_Approval__c = each.Id, Decision_Remarks__c = each.Remarks__c, LTV__c = ltvMap.get(loanRecord.Id),
                    Tenure__c = loanRecord.Tenure__c, ROI__c = loanRecord.ROI__c, Loan_Amount__c = loanRecord.Total_Loan_Amount__c, Action_Type__c = actionType));
            }
           
        }
    }
}