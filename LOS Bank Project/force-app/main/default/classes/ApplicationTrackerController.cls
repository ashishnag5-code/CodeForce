/**
 * @author        Joshna
 * @date          12-Jun-2023
 * @description   Controller class for Application Tracker
 * @reference     Application Tracker
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  12-Jun-2023     Initial creation - added fetchLineItems
 */
public without sharing class ApplicationTrackerController {
    static List<String> loanStagesFor2W = new List<String>{'QDE', 'KYC Approval', 'AML', 'Field Investigation', 'Valuation', 'RC Limit Trigger', 'Credit', 'Pricing', 'DDE', 'PSD', 'Ops - Maker', 'Ops - Author', 'PDD'};
    static List<String> loanStagesFor4W = new List<String>{'QDE', 'KYC Approval', 'AML', 'Field Investigation', 'Valuation', 'RC Limit Trigger', 'DDE', 'Credit', 'Pricing', 'PSD', 'Ops - Maker', 'Ops - Author', 'PDD'};
    static Set<String> typeBasedTAT = new Set<String>{'KYC Approval', 'Field Investigation'};
    static Set<String> approvalBasedTAT = new Set<String>{'Credit', 'Pricing'};
    static Set<String> assignmentBasedTAT = new Set<String>{'Ops - Maker', 'Ops - Author', 'PDD'};
    static Set<String> fieldBasedTAT = new Set<String>{'AML', 'Valuation', 'RC Limit Trigger'};
    static Map<String, String> stageActivityMap = new Map<String, String>{'Ops Maker' => 'Ops - Maker', 'Ops Author' => 'Ops - Author'};
    static String opsKYCRecordType = 'Ops_KYC';
    static String iconBaseURL;
    static List<String> loanStages;

    @AuraEnabled
    public static List<ResponseWrapper> fetchLineItems(String recordId) {
        List<ResponseWrapper> response = new List<ResponseWrapper>();
        Loan_Application__c loanRecord = [SELECT Id, Stage__c, Primary_Applicant__r.AML_Status__c, Primary_Applicant__r.AML_Verification_Start_Date__c,
            Primary_Applicant__r.AML_Verification_End_Date__c, RC_Limit_On_Hold__c, RC_Limit_Applied_Date__c, RC_Limit_Cleared_Date__c, RecordType.DeveloperName,
            (SELECT Id FROM Collaterals__r),
            (SELECT Id, Type__c, Start_Date_Time__c, End_Date_Time__c, Assigned_To__c, Owner__c, Owner__r.Name, Loan_Application_Assignment__r.Ops_Stage__c,
            Stage_Activity__c, Loan_Application_Assignment__r.RecordType.DeveloperName, Loan_Application_Approval__r.Approval_Type__c FROM Loan_TAT__r
            ORDER BY CreatedDate)
            FROM Loan_Application__c WHERE Id = :recordId];
        Map<String, List<Loan_TAT__c>> loanTATRecords = new Map<String, List<Loan_TAT__c>>();
        Map<String, List<Loan_TAT__c>> loanStageTATRecords = new Map<String, List<Loan_TAT__c>>();
        String valuationStatus;
        List<OwnerWrapper> valuationOwners = new List<OwnerWrapper>();
        String previousStageName;

        if (loanRecord.RecordType.DeveloperName.contains('Two')) {
            loanStages = loanStagesFor2W;
        } else {
            loanStages = loanStagesFor4W;
        }
        if (loanRecord.Collaterals__r != null && !loanRecord.Collaterals__r.isEmpty()) {
            valuationStatus = 'Completed';
            for (Valuation__c each : [SELECT Id, Owner.Name, CreatedDate, Completion_Date_Time__c FROM Valuation__c WHERE Collateral__c IN :loanRecord.Collaterals__r]) {
                if (each.Completion_Date_Time__c == null) {
                    valuationStatus = 'In Progress';
                }
                valuationOwners.add(new OwnerWrapper(each.Owner.Name, each.CreatedDate, each.Completion_Date_Time__c));
            }
        }

        for (StaticResource each : [SELECT Id, SystemModStamp FROM StaticResource WHERE Name = 'ApplicationTracker' LIMIT 1]) {
            iconBaseURL = '/resource/' + String.valueOf(((DateTime) each.SystemModStamp).getTime()) + '/ApplicationTracker/';
        }

        for (Loan_TAT__c each : loanRecord.Loan_TAT__r) {
            if (each.Type__c == 'Loan Application') {
                if (loanStageTATRecords.containsKey(each.Stage_Activity__c)) {
                    loanStageTATRecords.get(each.Stage_Activity__c).add(each);
                } else {
                    loanStageTATRecords.put(each.Stage_Activity__c, new List<Loan_TAT__c>{each});
                }
                if (each.End_Date_Time__c != null) {
                    previousStageName = each.Stage_Activity__c;
                }
            } else {
                if (loanTATRecords.containsKey(each.Type__c)) {
                    loanTATRecords.get(each.Type__c).add(each);
                } else {
                    loanTATRecords.put(each.Type__c, new List<Loan_TAT__c>{each});
                }
            }
        }

        // if type or stage is in loanTATRecordsMap or loanStageTATRecords - and all records have end time, then mark it as completed
        // if there is at least one w/o end date time - mark it is as in progress
        // if there is no record, mark it as not-initiated
        // for in progress and completed cases, add the owner (if there are multiple owners, add both owners with start & end time)
        for (String each : loanStages) {
            String statusOfActivity = 'Completed';
            List<OwnerWrapper> ownerList = new List<OwnerWrapper>();
            Boolean checkStage = false;
            Boolean checkApprovalStage = false;
            Boolean checkRecordType = false;
            List<Loan_TAT__c> tatRecordsList;
            if (typeBasedTAT.contains(each)) {
                if (each == 'Field Investigation') {
                    tatRecordsList = loanTATRecords.get('FI');
                } else {
                    checkRecordType = true;
                    tatRecordsList = new List<Loan_TAT__c>();
                    if (loanTATRecords.containsKey('Loan Assignment')) {
                        for (Loan_TAT__c eachTAT : loanTATRecords.get('Loan Assignment')) {
                            if (eachTAT.Loan_Application_Assignment__r.RecordType.DeveloperName != 'Ops_KYC') {
                                continue;
                            }
                            tatRecordsList.add(eachTAT);
                        }
                    }
                }
            } else if (assignmentBasedTAT.contains(each)) {
                checkStage = true;
                tatRecordsList = new List<Loan_TAT__c>();
                if (loanTATRecords.containsKey('Loan Assignment')) {
                    for (Loan_TAT__c eachTAT : loanTATRecords.get('Loan Assignment')) {
                        if (eachTAT.Loan_Application_Assignment__r.RecordType.DeveloperName != 'Ops_Disbursement') {
                            continue;
                        }
                        if ((eachTAT.Loan_Application_Assignment__r.Ops_Stage__c == 'Ops Maker' && each == 'Ops - Maker') || 
                            (eachTAT.Loan_Application_Assignment__r.Ops_Stage__c == 'Ops Author' && each == 'Ops - Author')) {
                            tatRecordsList.add(eachTAT);
                        }
                    }
                }
            } else if (approvalBasedTAT.contains(each)) {
                checkApprovalStage = true;
                tatRecordsList = loanTATRecords.get('Loan Approval');
            } else if (fieldBasedTAT.contains(each)) {
                statusOfActivity = 'Not Initiated';
                if (each == 'AML') {
                    statusOfActivity = loanRecord.Primary_Applicant__r.AML_Status__c == 'Approved' ? 'Completed' : 'Not Initiated';
                    ownerList.add(new OwnerWrapper(null, loanRecord.Primary_Applicant__r.AML_Verification_Start_Date__c,
                        loanRecord.Primary_Applicant__r.AML_Verification_End_Date__c));
                } else if (each == 'Valuation') {
                    if (valuationOwners.isEmpty()) {
                        continue;
                    }
                    statusOfActivity = valuationStatus;
                    ownerList = valuationOwners;
                } else {
                    statusOfActivity = loanRecord.RC_Limit_On_Hold__c ? 'In Progress' : 'Completed';
                    ownerList.add(new OwnerWrapper(null, loanRecord.RC_Limit_Applied_Date__c, loanRecord.RC_Limit_Cleared_Date__c));
                }
            } else {
                tatRecordsList = loanStageTATRecords.get(each);
            }
            if (tatRecordsList != null && !tatRecordsList.isEmpty()) {
                for (Loan_TAT__c eachTAT : tatRecordsList) {
                    if (eachTAT.End_Date_Time__c == null) {
                        statusOfActivity = 'In Progress';
                    }
                    if (eachTAT.Assigned_To__c == 'Queue') {
                        continue;
                    }
                    if (checkStage && (stageActivityMap.get(eachTAT.Stage_Activity__c) != each && eachTAT.Stage_Activity__c != each)) {
                        continue;
                    }
                    if (checkApprovalStage && eachTAT.Loan_Application_Approval__r.Approval_Type__c != each) {
                        continue;
                    }
                    if (checkRecordType && eachTAT.Loan_Application_Assignment__r.RecordType.DeveloperName != opsKYCRecordType) {
                        continue;
                    }
                    ownerList.add(new OwnerWrapper(eachTAT.Owner__r.Name, eachTAT.Start_Date_Time__c, eachTAT.End_Date_Time__c));
                }
            } else if (!fieldBasedTAT.contains(each)) {
                statusOfActivity = 'Not Initiated';
            }
            if (approvalBasedTAT.contains(each)) {
                if (!loanStageTATRecords.containsKey(each) && loanStages.indexOf(each) < loanStages.indexOf(loanRecord.Stage__c)) {
                    statusOfActivity = 'Skipped';
                } else if (!loanStageTATRecords.containsKey(each)) {
                    statusOfActivity = 'Not Initiated';
                } else if (loanStageTATRecords.containsKey(each)) {
                    statusOfActivity = 'Completed';
                    for (Loan_TAT__c eachTAT : loanStageTATRecords.get(each)) {
                        if (eachTAT.End_Date_Time__c == null) {
                            statusOfActivity = 'In Progress';
                        }
                    }
                }
            }
            if (previousStageName == each.replace('- ', '')) {
                system.debug('***** inside returned logic ');
                Integer previousStageIndex = stageActivityMap.containsKey(previousStageName) ? loanStages.indexOf(stageActivityMap.get(previousStageName)) : loanStages.indexOf(previousStageName);
                Integer currentStageIndex = stageActivityMap.containsKey(loanRecord.Stage__c) ? loanStages.indexOf(stageActivityMap.get(loanRecord.Stage__c))
                    : loanStages.indexOf(loanRecord.Stage__c);
                system.debug('***** inside returned logic ' + previousStageIndex + '**' + currentStageIndex);
                if (previousStageIndex > currentStageIndex) {
                    statusOfActivity = 'Returned';
                }
            }

            response.add(new ResponseWrapper(each, statusOfActivity, ownerList, iconBaseURL + each.replace(' ', '').replace('-','') + '.png'));
        }
        return response;
    }

    public class ResponseWrapper {
        @AuraEnabled public String stageName;
        @AuraEnabled public String statusOfActivity;
        @AuraEnabled public List<OwnerWrapper> ownerList;
        @AuraEnabled public String iconName;
        @AuraEnabled public String iconURL;
        Map<String, String> iconMap = new Map<String, String>{'In Progress' => 'standard:data_transforms', 'Completed' => 'standard:task2', 'Not Initiated' => 'standard:incident',
            'Skipped' => 'standard:sales_path', 'Returned' => 'standard:return_order'};

        public ResponseWrapper(String stageName, String statusOfActivity, List<OwnerWrapper> ownerList, String iconURL) {
            this.stageName = stageName;
            this.statusOfActivity = statusOfActivity;
            this.ownerList = ownerList;
            this.iconName = iconMap.get(this.statusOfActivity);
            this.iconURL = iconURL;
        }
    }

    public class OwnerWrapper {
        @AuraEnabled public String ownerName;
        @AuraEnabled public DateTime startDateTime;
        @AuraEnabled public DateTime endDateTime;

        public OwnerWrapper(String ownerName, DateTime startDateTime, DateTime endDateTime) {
            this.ownerName = ownerName;
            this.startDateTime = startDateTime;
            this.endDateTime = endDateTime;
        }
    }
}