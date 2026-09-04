/*******************************************************************************************
* @Name         LoanTriggerService
* @Author       Harshpreet Singh 
* @Description  This is the trigger service for Opportunity/Loan trigger and LoanTriggerHandler.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date               Description
*-------------------------------------------------------------------------------------------
*  1.0          Harshpreet Singh      08/17/2021           Initial Creation
*               Mohit M.              10/31/2023           SFAU-5522 - CUG|| OPS|| GST Wrong Calculated on processing Fees
*               Mohit M.              Mov-10-2023          SFAU-5573 - CUG||4W|| Pricing approval record is not created 
*******************************************************************************************/
public with sharing class LoanTriggerService implements ServiceInterface {
    public static Boolean isFirstTime = true;
    public static boolean isFirstPass= true;
    public static boolean firstExec=true;
    public void beforeInsert(List < sObject > newRecordList) {
        List<Loan_Application__c> newList = (List <Loan_Application__c>) newRecordList;
        Map<Id, String> mapOfIdVsAccessibleProds = RoleHierarchyAndVisibility.getAccessibleProducts(newList);//R2-2139
        for(Loan_Application__c loanApp : newList){
            // SFAU-5573
            loanApp.Old_ROI__c = loanApp.ROI__c;
            //R2-2139
            if(mapOfIdVsAccessibleProds.containsKey(loanApp.Id)){
                loanApp.Product_Applicable_For__c = mapOfIdVsAccessibleProds.get(loanApp.Id);
            }
        }
    }
    
    public void afterInsert(List < sObject > newRecordList, Map < Id, sObject > newRecordMap) {
        Set < String > loanIds = new Set < String > ();
        Id leadRecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), 'Lead' );
        // R2-28
        Loan_Dedupe__e[] leadDedupeEvents = new Loan_Dedupe__e[0];

        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        for (Id each: newRecordMap.keySet()) {
            loanIds.add(String.valueOf(each));
            // added below 4 lines for publishing TAT Events
            Loan_Application__c newRecord = (Loan_Application__c) newRecordMap.get(each);
            Loan_Application__c loanApp = new Loan_Application__c(Id = each, Stage__c = newRecord.Stage__c, Sub_Stage__c = newRecord.Sub_Stage__c,
                                                                  OwnerId = newRecord.OwnerId, Application_FI_Status__c = newRecord.Application_FI_Status__c, Ops_Status__c = newRecord.Ops_Status__c,
                                                                  Remarks__c = newRecord.Remarks__c, ROI__c = newRecord.ROI__c, Total_Loan_Amount__c = newRecord.Total_Loan_Amount__c, Tenure__c = newRecord.Tenure__c,
                                                                  Sanction_Status__c = newRecord.Sanction_Status__c, DO_Status__c = newRecord.DO_Status__c);
            tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(loanApp), Object_API_Name__c = 'Loan_Application__c',
                                                    Event_Date_Time__c = Datetime.now(), Logged_In_User__c = UserInfo.getUserId()));

            // R2-28 - Do Lead Dedupe again existing loans in system
            if( newRecord.RecordTypeId == leadRecordTypeId && newRecord.Mobile__c != null ){
                leadDedupeEvents.add(
                    new Loan_Dedupe__e(
                        Record_Id__c = each,
                        Type__c = 'Mobile'
                    )
                 );
            }
        }
        createChecklists(loanIds);
        shareLoanRecordsWithCOMUsers(loanIds);
        //createBSRAssignment(newRecordList);
        updateNameWithApplicationId((List <Loan_Application__c>) newRecordList);
        ShareRecordsWithUsers.shareLoanBasedOnProductAccess(new Map<Id, sObject>(), newRecordMap,'Insert');
        // no null check here because if this method is running there will always be events
        Eventbus.publish(tatEvents);
        EventBus.publish( leadDedupeEvents );// R2-28
    }
    
    private void shareLoanRecordsWithCOMUsers(Set < String > loanIds) {
        if (!loanIds.isEmpty()) {
            Set < Id > loanIdSet = new Set < Id > ((List < Id > ) new List < String > (loanIds));
            COMShareApplicationRecordHandler.publishCOMPlatformEventRecords(loanIdSet);
        }
    }
    
    public static void createChecklists(Set < String > loanIds) {
        system.debug('*****' + loanIds);
        RuleEngineHandler getDocChecklists = new RuleEngineHandler();
        List < Document_Checklist__c > checklistsToInsert = new List < Document_Checklist__c > ();
        try{
            Map < Id, Set < String >> documentMasterIdsByApp = getDocumentIds(getDocChecklists.main('Loan_Application__c', loanIds, new Set < String > (), 'Document Checklist'));
            System.debug('***doc: ' + documentMasterIdsByApp);
            Map < String, Document_Master__c > docMasterMap = new Map < String, Document_Master__c > ();
            System.debug('***doc Ids: ' + documentMasterIdsByApp.keySet());
            
            for (Document_Master__c each: [SELECT Id, Name,
                                           Document_Sub_Category__c,Document_Name__c, Document_ID__c
                                           FROM Document_Master__c
                                           WHERE Document_ID__c IN: documentMasterIdsByApp.keySet() WITH SECURITY_ENFORCED
                                          ]) {
                                              docMasterMap.put(each.Document_ID__c, each);
                                          }
            for (Id each: documentMasterIdsByApp.keySet()) {
                for (String eachMasterId: documentMasterIdsByApp.get(each)) {
                    Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) :
                    new Document_Master__c();
                    checklistsToInsert.add(new Document_Checklist__c(Loan_Application__c = each,
                                                                     Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                                                     Category__c = currentRec.Document_Sub_Category__c,
                                                                     Sub_Category__c = currentRec.Name,
                                                                     Document_Name__c = currentRec.Document_Name__c,
                                                                     Active__c = true
                                                                    ));
                }
            }
            
            /* Map<Id, Set<String>> interfaceMasterByLoan = new Map<Id, Set<String>>();
Set<String> allMasterStrings = new Set<String>();
try {
Map<String, Object> applicantChecklists = (Map<String, Object>) JSON.deserializeUntyped(applicantMasterString);
Map<String, Object> checklists = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
if (checklists == null) {
return;
}

for (String each : checklists.keySet()) {
Set<String> masterIds = new Set<String>();
List<Object> checklistsOfApp = (List<Object>) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
for (Object eachObject : checklistsOfApp) {
Map<String, Object> objProperties = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachObject));
masterIds.add((String) objProperties.get('TV'));
allMasterStrings.add((String) objProperties.get('TV'));
}
interfaceMasterByLoan.put(each, masterIds);
}

Map<String, Integration_Master__c> integrationMastersByUniqueCode = new Map<String, Integration_Master__c>();
for (Integration_Master__c each : [SELECT Id, Name, Source_of_Entry__c FROM Integration_Master__c WHERE Name IN :allMasterStrings WITH SECURITY_ENFORCED]) {
// replace this with an external ID later instead of name
integrationMastersByUniqueCode.put(each.Name, each);
}
//            for (Loan_Application__c each : [SELECT Id, (SELECT Id FROM VLOS_Applicants__r) FROM Loan_Application__c WHERE Id IN :interfaceMasterByLoan.keySet()]) {

for (Loan_Application__c each : [SELECT Id FROM Loan_Application__c WHERE Id IN :interfaceMasterByLoan.keySet() WITH SECURITY_ENFORCED]) {
for (String eachMasterId : interfaceMasterByLoan.get(each.Id)) {
if (!integrationMastersByUniqueCode.containsKey(eachMasterId)) {
continue;
}
String sourceOfEntry = integrationMastersByUniqueCode.get(eachMasterId).Source_of_Entry__c;
if (sourceOfEntry == 'Loan_Application__c') {
checklistsToInsert.add(new Integration_Checklist__c(Loan__c = each.Id, Integration_Master__c = integrationMastersByUniqueCode.get(eachMasterId).Id, Is_Latest__c = true, Status__c = 'Pending'));
} else if (sourceOfEntry == 'Applicant__c') {

}
}
}
//insert checklistsToInsert;
*/
            DatabaseUtility.createRecords(checklistsToInsert, '');
        } catch (Exception ex) {
            system.debug('****err' + ex.getMessage());
        }
    }
    
    private static void updateNameWithApplicationId(List<Loan_Application__c> applicationRecords){
        Id leadRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Lead').getRecordTypeId();
        Set<Id> leadIds = new Set<Id>();
        // Needs to be fix and deployed to Production
        for(Loan_Application__c application : applicationRecords) {
            leadIds.add(application.Id);
        }
        /*
        for (Loan_Application__c objLoanApp : applicationRecords) {
            leadIds.add(objLoanApp.Id);
        }
        */
        if(!leadIds.isEmpty()){
            List<Loan_Application__c> leadApplications = new List<Loan_Application__c>();
            for (Loan_Application__c objLoanApp : [SELECT Id, RecordTypeId, LeadNumber__c,Application_Id__c, Lead_Id__c, Name FROM Loan_Application__c WHERE ID IN:leadIds]){
                if (objLoanApp.RecordTypeId == leadRecordTypeId) {
                   objLoanApp.Lead_Id__c = objLoanApp.Application_Id__c;
                }
                objLoanApp.Name = objLoanApp.Application_Id__c;
                leadApplications.add(objLoanApp);
            }
            update leadApplications;
        }
        
            /*
            for(Loan_Application__c application : leadApplications){
                application.Name = application.Application_Id__c;
                if(application.RecordTypeId == leadRecordTypeId){
                    application.Lead_Id__c = application.Application_Id__c;
                }
            }
            update leadApplications;
            */
    }
    
    /*
    private static void updateNameWithApplicationIdUpdate(Set<Id> loanIds) {
        List<Loan_Application__c> leadApplications = [SELECT Id, RecordTypeId, LeadNumber__c,Application_Id__c, Lead_Id__c, 
                                                      Name FROM Loan_Application__c WHERE ID IN:loanIds];
        for(Loan_Application__c application : leadApplications){
            application.Name = application.Application_Id__c;
        }
        update leadApplications;
        
    }
    */
    
    public static Map < Id, Set < String >> getDocumentIds(String breJSONString) {
        Map < Id, Set < String >> returnValue = new Map < Id, Set < String >> ();
                Map < String, Object > applicantChecklists = (Map < String, Object > ) JSON.deserializeUntyped(breJSONString);
        Map < String, Object > checklists = (Map < String, Object > ) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if (checklists != null) {
            for (String each: checklists.keySet()) {
                                Set < String > masterIds = new Set < String > ();
                List < Object > checklistsOfApp = (List < Object > ) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject: checklistsOfApp) {
                    Map < String, Object > objProperties = (Map < String, Object > ) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }
    
    
    public void createOpsAssignment(Map < Id, sObject > oldRecordMap, List < sObject > newRecordList, Map < Id, sObject > newRecordMap){
        List<Id> applicantIds = new List<id>();
        Boolean sendNotification =false;
        String loanId = '';
        for(Loan_Application__c loanObj : [SELECT Id,Stage__c,RecordType.Name, (SELECT Id,Customer_Type__c,Existing_Customer__c,KYC_Type__c FROM Applicants__r) FROM Loan_Application__c WHERE Id IN :newRecordMap.keySet()]){
            Boolean isAfterQDE = false;
            Boolean flag = false;
            List<String> r2RecordTypes = new List<String>{'Tractor','Construction Equipment','Commercial Vehicle','Other'};//R2-1990
            if(loanObj.RecordType.Name=='Two Wheeler' && oldRecordMap.get(loanObj.Id).get('Stage__c')=='QDE' && loanObj.Stage__c!='QDE'){
                isAfterQDE=true;
            }
            else if((loanObj.RecordType.Name=='Four Wheeler' || r2RecordTypes.contains(loanObj.RecordType.Name)) && oldRecordMap.get(loanObj.Id).get('Stage__c')=='DDE' && loanObj.Stage__c!='DDE'){//R2-1990
                isAfterQDE=true;
            }
            for(Applicant__c app : loanObj.Applicants__r){
                if(app.Customer_Type__c=='Non Individual'){
                    flag = true;
                }
                else if(app.Customer_Type__c=='Individual' && ( app.KYC_Type__c!=null && (app.KYC_Type__c.contains('OTP') || app.KYC_Type__c.contains('Smartphone KYC') || app.KYC_Type__c.contains('Physical Document')))){
                    flag = true;
                }
            }
            if(isAfterQDE && flag){
                System.debug('insideIFCondition-->');
                sendNotification = true;
                loanId=loanObj.Id;
                OpsAssignementUtility.boolIsCreateROShare = true;
                OpsAssignementUtility.doOpsAssignment((Loan_Application__c)newRecordMap.get(loanObj.Id),'Ops - KYC','');
            }
        }
        if(sendNotification == true){
            System.debug('KYC approval flow');
            Notification_Event__e notificationEvent = new Notification_Event__e();
            notificationEvent.sObjectId__c = loanId;
            notificationEvent.Trigger_Point__c = 'KYC approval flow';
            EventBus.publish(notificationEvent);
            //NotificationHandler.sendNotification('KYC approval flow', loanId, ''); //Notification 
        }
    }
    
    public void beforeUpdate(List < sObject > newRecordList, Map < Id, sObject > oldRecordMap, Map < Id, sObject > newRecordMap) {
        system.debug('Inside Loan Before Update Trigger');
        System.debug(' == Before Update -- newRecordList ==> ' +JSON.serializePretty(newRecordList));
        prepopulateFieldValues((Loan_Application__c[])newRecordList, (map<Id, Loan_Application__c>)oldRecordMap);
        archivePricingApprovals((Loan_Application__c[])newRecordList, (map<Id, Loan_Application__c>)oldRecordMap);
        validateLoanAmountChanged( (Loan_Application__c[])newRecordList, (map<Id, Loan_Application__c>)newRecordMap, (map<Id, Loan_Application__c>)oldRecordMap );
        // updateApplicationsPreviouslySentBackByCM((Loan_Application__c[])newRecordList, (map<Id, Loan_Application__c>)oldRecordMap);
        CAMReportLWCController.createCAMReportOnStageChange(oldRecordMap, newRecordMap);
        PricingApprovalHandler.handleStageChangeIfNoPricingDeviationRaised(newRecordMap,oldRecordMap);
        CreditVerification.setBaseCreditVerification(newRecordMap,oldRecordMap);
        OpsVerificationController.setBaseOpsVerification(oldRecordMap, newRecordMap);
        checkUploadedDocuments(newRecordMap,oldRecordMap);
        updateFTRStatus(newRecordMap,oldRecordMap);
        checkAmlPendingValidationOnCredit(newRecordMap,oldRecordMap);
        skipOpsMakerStage(newRecordMap,oldRecordMap);
        calculateFirstEMIDate(newRecordList, newRecordMap, oldRecordMap);
        setDO_SanctionDateOnApplication(newRecordMap,oldRecordMap);
        handleExposureChange(newRecordList,newRecordMap,oldRecordMap); ///SFAU-3631
        updateCustomerGrade(newRecordMap, oldRecordMap);
        // Commented Mohit calculatePDDStageTAT(newRecordMap, oldRecordMap);
        LoanDetailsController.updateEMIAmount(newRecordMap, oldRecordMap); //EMI Amount Mismatch - Neha
    }
    public void updateCustomerGrade(Map < Id, sObject > newRecordMap, Map < Id, sObject > oldRecordMap){
        List<Loan_Application__c> premiumCheckLoanList = new List<Loan_Application__c>();
        Map<Id, List<Applicant__c>> loanApplicantsMap = new Map<Id, List<Applicant__c>>();
        for(sObject sobjectRec : newRecordMap.values()){
            Loan_Application__c newRec = (Loan_Application__c)sobjectRec;
            Loan_Application__c oldRec = (Loan_Application__c)oldRecordMap.get(newRec.Id);
            //Auto loan
            if(String.isNotBlank(newRec.Product__c)){
                if(newRec.Product__c  == '10201' || newRec.Product__c  == '10202' || newRec.Product__c  == '10203' || Label.AutoLoanCowProducts.contains(newRec.Product__c)){ // SFAU-5584
                if(newRec.Applicant_s_Total_Monthly_Income__c != oldRec.Applicant_s_Total_Monthly_Income__c || newRec.Applicant_s_Total_Monthly_Obligations__c != oldRec.Applicant_s_Total_Monthly_Obligations__c){
                    if(newRec.Applicant_s_Total_Monthly_Income__c > newRec.Applicant_s_Total_Monthly_Obligations__c){
                        newRec.Customer_Grade__c = 'IB';
                    }
                    else{
                        premiumCheckLoanList.add(newRec);
                    }
                }
            }
        }    
        }    
        if(!premiumCheckLoanList.isEmpty()){
            for(Applicant__c eachApplicant : [SELECT Id, Loan__c, Customer_Grade__c FROM Applicant__c WHERE Loan__c In : premiumCheckLoanList]){
                if(loanApplicantsMap.containsKey(eachApplicant.Loan__c)){
                    List<Applicant__c> temp = loanApplicantsMap.get(eachApplicant.Loan__c);
                    temp.add(eachApplicant);
                    loanApplicantsMap.put(eachApplicant.Loan__c, temp);
                }
                else{
                    loanApplicantsMap.put(eachApplicant.Loan__c, new List<Applicant__c>{eachApplicant});
                }
            }
            for(Loan_Application__c loanRec : premiumCheckLoanList){
                Boolean isPremiumCustGradeFound = false;
                for(Applicant__c eachApplicant : loanApplicantsMap.get(loanRec.Id)){
                    if(eachApplicant.Customer_Grade__c == 'Premium'){
                        loanRec.Customer_Grade__c = 'Premium';
                        isPremiumCustGradeFound = true;
                        break;
                    }
                }
                if(!isPremiumCustGradeFound){
                    loanRec.Customer_Grade__c = 'NIB';
                }
            }
        }
    }
    
    /* Commented Mohit
    private void calculatePDDStageTAT(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        
        set<Id> loanAppIds = new set<id>();
        Set<Id> linkedCheckListIds = new Set<Id>();
        set<Id> collIds = new set<id>();
        set<Id> PDDPendingloanIds = new set<id>();
        set<Id> completedloanIds = new set<id>();
        List<Id> loanIds = new List<Id>();
        set<id> docSet = new set<id>();
        map<id, list<Document_Checklist__c>> loanToDocMap = new map<id, list<Document_Checklist__c>>();
        
        list<Document_Checklist__c> docList = new list<Document_Checklist__c>();
        list<Loan_Application__c> PDDAppListWithCollList = new list<Loan_Application__c>();
        
        for(Id loanId: loanApplicationNewMap.keySet()){
            if((loanApplicationNewMap.get(loanId).Stage__c !=loanApplicationOldMap.get(loanId).stage__c && loanApplicationNewMap.get(loanId).Stage__c == 'PDD')){
                loanAppIds.add(loanId);
                loanApplicationNewMap.get(loanId).PDD_stage_start_time__c  = System.today();
            }
            else if((loanApplicationNewMap.get(loanId).Stage__c !=loanApplicationOldMap.get(loanId).stage__c && loanApplicationNewMap.get(loanId).Stage__c == 'Completed')){
                loanAppIds.add(loanId);
            }
            
        }
        
        if(loanAppIds !=null && !loanAppIds.isEmpty()){
            PDDAppListWithCollList = [select id,(select id from Collaterals__r ) from Loan_Application__c where Id IN :loanAppIds];
        }
        
        if(PDDAppListWithCollList !=null && !PDDAppListWithCollList.isEmpty()){
            For(Loan_Application__c lp : PDDAppListWithCollList){
                for(Collateral__c colltemp : lp.Collaterals__r){
                    collIds.add(colltemp.Id);
                }
            }
        }
        
        docList = [select id,Collateral__r.Loan__c from Document_Checklist__c where Collateral__c IN :collIds and PDD_documents_check__c =true];
        system.debug('docList::'+docList);
        
        if(docList.isEmpty())
            return;
        
        for(Document_Checklist__c dc : docList){
            docSet.add(dc.id);
        }
        
        for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docSet AND ContentDocument.LatestPublishedVersion.isActive__c=TRUE WITH SECURITY_ENFORCED]) {
            linkedCheckListIds.add(each.LinkedEntityId);
        }
        
        system.debug('linkedCheckListIds::'+linkedCheckListIds);
        
        for(Document_Checklist__c docTemp : docList){
            if(loanToDocMap.containsKey(docTemp.Collateral__r.Loan__c)){
                loanToDocMap.get(docTemp.Collateral__r.Loan__c).add(docTemp);
            }   
            else{
                doclist = new list<Document_Checklist__c>();
                doclist.add(docTemp);
                loanToDocMap.put(docTemp.Collateral__r.Loan__c,doclist);
            }
        }
        
        system.debug('docLloanToDocMapist::'+loanToDocMap);
        
        if(loanToDocMap!=null && loanToDocMap.values() !=null){  
            for(Id loanId :loanToDocMap.keySet()){
                boolean alldocsNotSubmitted = false;
                list<Document_Checklist__c> dclist = loanToDocMap.get(loanId);
                for(Document_Checklist__c dctemp : dclist){
                    if(!linkedCheckListIds.isEmpty() && linkedCheckListIds.contains(dctemp.id))
                        alldocsNotSubmitted = true;
                    else{
                        alldocsNotSubmitted = false;
                        break;
                    }
                }
                system.debug('alldocsNotSubmitted::'+alldocsNotSubmitted);
                if(!alldocsNotSubmitted){
                    PDDPendingloanIds.add(loanId);
                }
                else{
                    completedloanIds.add(loanId);
                }
            }
        }
        
        system.debug('PDDPendingloanIds::'+PDDPendingloanIds);
        
        Map<id,Loan_Application__c> PDDPendingLoans = new map<id,Loan_Application__c>([select id, PDD_stage_start_time__c from Loan_Application__c where Id IN :PDDPendingloanIds]);
        
        for(Loan_Application__c pdLoan : PDDPendingLoans.values()){
            Loan_Application__c LoanTemp = (Loan_Application__c)loanApplicationNewMap.get(pdLoan.id);
            LoanTemp.PDD_docs_not_submitted__c  = true;
        }
         system.debug('completedloanIds::'+completedloanIds);
        if(completedloanIds!=null && !completedloanIds.isEmpty()){
            
            Map<id,Loan_Application__c> completedLoans = new map<id,Loan_Application__c>([select id, PDD_stage_start_time__c from Loan_Application__c where Id IN :completedloanIds]);
            for(Loan_Application__c pdLoan : completedLoans.values()){
                Loan_Application__c LoanTemp = (Loan_Application__c)loanApplicationNewMap.get(pdLoan.id);
                LoanTemp.PDD_docs_not_submitted__c  = false;
            } 
        }
    }
    */
    
    public void setDO_SanctionDateOnApplication(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        List<Id> loanIds = new List<Id>();
        for(Id loanId: loanApplicationNewMap.keySet()){
            if(loanApplicationNewMap.get(loanId).DO_Status__c == 'Issued' && loanApplicationNewMap.get(loanId).Sanction_Status__c == 'Issued'){
                loanApplicationNewMap.get(loanId).Sanction_DO_Issued_Date__c = System.today();
            }
            else{
                loanApplicationNewMap.get(loanId).Sanction_DO_Issued_Date__c = null;
            }
        }
    }
    
    
    public void updateFTRStatus(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        
        if(isFirstPass){
            Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
            Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
            List<Id> loanIds = new List<Id>();
            for(Id loanId: loanApplicationNewMap.keySet()){
                if((loanApplicationOldMap.get(loanId).Stage__c=='Credit' && loanApplicationNewMap.get(loanId).Stage__c!='Credit') ||
                   (loanApplicationOldMap.get(loanId).Stage__c=='Ops Maker' && loanApplicationNewMap.get(loanId).Stage__c!='Ops Maker')){
                       loanIds.add(loanId);
                   }
            }
            List<Document_Checklist__c> docList = [SELECT Id,Mandatory__c,Credit_FTR_FTNR__c,Loan_Application__c,Ops_FTR_FTNR__c FROM Document_Checklist__c 
                                                   WHERE Loan_Application__c IN :loanIds AND Mandatory__c=true AND (Credit_FTR_FTNR__c='FTNR' OR Ops_FTR_FTNR__c='FTNR')];
            List<Document_Checklist__c> docAppList = [SELECT Id,Credit_FTR_FTNR__c,Mandatory__c,Applicant__c,Applicant__r.Loan__c,Ops_FTR_FTNR__c  FROM Document_Checklist__c 
                                                      WHERE Applicant__r.Loan__c IN :loanIds AND Mandatory__c=true AND (Credit_FTR_FTNR__c='FTNR' OR Ops_FTR_FTNR__c='FTNR')];
            List<Document_Checklist__c> docVehicleList = [SELECT Id,Credit_FTR_FTNR__c,Mandatory__c,Collateral__c,Collateral__r.Loan__c,Ops_FTR_FTNR__c  FROM Document_Checklist__c 
                                                          WHERE Collateral__r.Loan__c IN :loanIds AND Mandatory__c=true AND 
                                                          (Credit_FTR_FTNR__c='FTNR' OR Ops_FTR_FTNR__c='FTNR') AND (Collateral__r.RecordType.Name='Used/Cash on Wheels' 
                                                                                                                     OR Collateral__r.RecordType.Name='New') AND isDeleted=false];
            System.debug('docList '+docList);
            System.debug('docAppList '+docAppList);
            System.debug('docVehicleList '+docVehicleList);
            Set<Id> loanFTNRList = new Set<Id>();
            Set<Id> loanOpsFTNRList = new Set<Id>();
            for(Document_Checklist__c doc :docList){
                if(doc.Credit_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Credit'){
                    loanFTNRList.add(doc.Loan_Application__c);
                }
                else if(doc.Ops_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Ops Maker'){
                    loanOpsFTNRList.add(doc.Loan_Application__c);
                }
            }
            for(Document_Checklist__c doc :docAppList){
                if(doc.Credit_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Credit'){
                    loanFTNRList.add(doc.Loan_Application__c);
                }
                else if(doc.Ops_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Ops Maker'){
                    loanOpsFTNRList.add(doc.Loan_Application__c);
                }
            }
            for(Document_Checklist__c doc :docVehicleList){
                if(doc.Credit_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Credit'){
                    loanFTNRList.add(doc.Loan_Application__c);
                }
                else if(doc.Ops_FTR_FTNR__c=='FTNR' && loanApplicationOldMap.get(doc.Loan_Application__c).Stage__c=='Ops Maker'){
                    loanOpsFTNRList.add(doc.Loan_Application__c);
                }
            }
            System.debug('loanFTNRList '+loanFTNRList);
            System.debug('loanOpsFTNRList '+loanOpsFTNRList);
            for(Id loan: loanIds){
                if(loanFTNRList.contains(loan) && loanApplicationOldMap.get(loan).Stage__c=='Credit'){
                    loanApplicationNewMap.get(loan).Credit_FTR_FTNR__c = 'FTNR';
                }
                else if(loanApplicationOldMap.get(loan).Stage__c=='Credit'){
                    loanApplicationNewMap.get(loan).Credit_FTR_FTNR__c = 'FTR';
                }
                else if(loanOpsFTNRList.contains(loan) && loanApplicationOldMap.get(loan).Stage__c=='Ops Maker'){
                    loanApplicationNewMap.get(loan).Ops_FTR_FTNR__c = 'FTNR';
                }
                else if(loanApplicationOldMap.get(loan).Stage__c=='Ops Maker'){
                    loanApplicationNewMap.get(loan).Ops_FTR_FTNR__c = 'FTR';
                }
                System.debug('loan '+loan);
            }
            isFirstPass=false;
        }
    }
    
    /* Added the Logic for 101 SOQL Error*/
    public void skipOpsMakerStage(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        if(isFirstTime){
            Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
            Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
            List<Id> loanIdList = new List<Id>(); 
            for(Id loanId: loanApplicationNewMap.keySet()){
                if(loanApplicationOldMap.get(loanId).Stage__c=='PSD' && loanApplicationNewMap.get(loanId).Stage__c!='PSD'){
                    Date today = System.today();
                    if(loanApplicationNewMap.get(loanId).Credit_Approval_Date__c!=null && loanApplicationNewMap.get(loanId).Repayment_Mode__c!=null && loanApplicationNewMap.get(loanId).Esign_Type__c !=null && loanApplicationNewMap.get(loanId).Loan_Amount__c!=null){
                        System.debug('days diff '+loanApplicationNewMap.get(loanId).Credit_Approval_Date__c.daysBetween(today));
                        if(loanApplicationNewMap.get(loanId).Credit_Approval_Date__c.daysBetween(today)<= Integer.valueOf(System.Label.Credit_Approval_Days_Limit) && (loanApplicationNewMap.get(loanId).Repayment_Mode__c.contains('E mandate') || loanApplicationNewMap.get(loanId).Repayment_Mode__c.contains('Standing Instructions')) &&
                           loanApplicationNewMap.get(loanId).Esign_Type__c == 'Digital' && loanApplicationNewMap.get(loanId).Loan_Amount__c <= Integer.valueOf(System.Label.Loan_Amount_Limit) && loanApplicationNewMap.get(loanId).Dpd_Found__c==false  ){
                               loanIdList.add(loanId);
                           }
                    }
                }
                
            }
            Map<Id,Loan_Application__c> mapOfIdtoLoan = new Map<Id,Loan_Application__c>([SELECT Id,OPS_KYC_Action__c,Product__c, (SELECT KYC_Type__c,RecordType.Name FROM Applicants__r WHERE RecordType.Name!='Additional Match' AND RecordType.Name!='Nominee' AND isinactive__c = false),(SELECT Id,Payment_Recipient__c,Loan_Application__c FROM Payments__r WHERE RecordType.Name='Payment Favouring'),
                                                                                         (SELECT Id FROM Sanction_Conditions__r) 
                                                                                         FROM Loan_Application__c WHERE Id IN :loanIdList]);
            Map<Id,Applicant__c> mapOfIdtoApp = new Map<Id,Applicant__c>([SELECT Id, (SELECT Id,Same_As__c FROM Addresses__r WHERE Address_Type__c='Current'),(SELECT Id,Match_Percentage__c FROM Document_Checklists__r WHERE Document_Master__r.Document_Name__c='Pan Card/Form 60') FROM Applicant__c WHERE Loan__c IN :loanIdList and isinactive__c = false AND RecordType.Name!='Additional Match' AND RecordType.Name!='Nominee']);
            
            
            System.debug('loanIdList First Filter '+loanIdList);
            
            List<Product_vs_Vehicle_Usage__mdt> productMdt = [Select Product_Code__c,STP__c from Product_vs_Vehicle_Usage__mdt];
            Map<String,String> mapOfProduct = new Map<String,String>();
            for(Product_vs_Vehicle_Usage__mdt obj: productMdt){
                mapOfProduct.put(obj.Product_Code__c,obj.STP__c);
            }
            List<Id> loanAppIdList = new List<Id>();
            for(Id loanId: mapOfIdtoLoan.keySet()){
                Boolean isBiometric=true;
                Boolean isCurrentSame = true;
                Boolean isPaymentFav = true;
                Boolean matchPercentEqual = true;
                for(Applicant__c app: mapOfIdtoLoan.get(loanId).Applicants__r){
                    System.debug('app '+app);
                    if(mapOfIdtoApp.containsKey(app.id) && mapOfIdtoApp.get(app.id).Addresses__r != null && mapOfIdtoApp.get(app.id).Addresses__r.size()>0){
                        System.debug('address '+mapOfIdtoApp.get(app.id).Addresses__r[0]);
                    }
                    if(app.KYC_Type__c!=null && !app?.KYC_Type__c?.contains('Biometric')){
                        isBiometric = false;
                    }
                    if(mapOfIdtoApp.containsKey(app.id) && mapOfIdtoApp.get(app.id).Addresses__r != null && mapOfIdtoApp.get(app.id).Addresses__r.size()>0 && mapOfIdtoApp.get(app.id).Addresses__r[0].Same_As__c!='Permanent'){
                        isCurrentSame = false;
                    }
                    if(mapOfIdtoApp.containsKey(app.id) && !mapOfIdtoApp.get(app.id).Document_Checklists__r.isEmpty()){
                        Decimal matchPercent = (mapOfIdtoApp.get(app.id).Document_Checklists__r[0].Match_Percentage__c == null)?0.00:mapOfIdtoApp.get(app.id).Document_Checklists__r[0].Match_Percentage__c;
                        if(matchPercent*100 != Integer.valueOf(System.Label.STP_Match_Percentage)){
                            matchPercentEqual = false;
                        }
                        
                    }
                    
                }
                
                for(Payment__c payObj: mapOfIdtoLoan.get(loanId).Payments__r){
                    if(payObj.Payment_Recipient__c!='Dealer' && payObj.Payment_Recipient__c!='UCD' && payObj.Payment_Recipient__c!='CA' && payObj.Payment_Recipient__c!='CSD'){
                        isPaymentFav = false;
                        break;
                    }
                }
                
                if((loanApplicationNewMap.get(loanId).OPS_KYC_Action__c=='Approve' || isBiometric) && isCurrentSame && isPaymentFav && mapOfIdtoLoan.get(loanId).Sanction_Conditions__r.size()==0 && mapOfProduct.get(mapOfIdtoLoan.get(loanId).Product__c)=='On' && matchPercentEqual){
                    loanAppIdList.add(loanId);
                }
            }
            System.debug('final list '+loanAppIdList);
            for(Id loanId: loanApplicationNewMap.keySet()){
                if(loanApplicationOldMap.get(loanId).Stage__c=='PSD' && loanApplicationNewMap.get(loanId).Stage__c!='PSD'){
                    if(loanAppIdList.contains(loanId)){
                        loanApplicationNewMap.get(loanId).Ops_Output__c = 'OPS STP';
                    }
                    else{
                        loanApplicationNewMap.get(loanId).Ops_Output__c = 'OPS NSTP';
                    }
                    System.debug('loan in STP ---- '+loanApplicationNewMap.get(loanId));
                }
                
            }
            isFirstTime = false;
        }
        
        
        
    }
    
    //SFAU-3631
    public void handleExposureChange(List < sObject > newRecordList, Map < Id, sObject > newRecordMap, Map < Id, sObject > oldRecordMap){
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        Id twoWheelerRT = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.TWOWHEELER );
        List<Loan_Application__c> newUpdatedList =  new List<Loan_Application__c>();
        List<Loan_Application__c> loanNewRecord = ( List<Loan_Application__c>)newRecordList;
        /* List<Loan_Application__c> loanNewRecord = [SELECT id,Final_Exposure__c, Wheels_Exposure__c,Total_Loan_Amount__c, RecordType.Name 
FROM Loan_Application__c
WHERE id=:newRecordMap.keySet()];*/
        Decimal Count=0;
        for(Loan_Application__c loanInstance : loanNewRecord){
            Count = loanApplicationOldMap.get(loanInstance.Id).Discrepancy_Count__c!=null ? loanApplicationOldMap.get(loanInstance.Id).Discrepancy_Count__c:0;
            if(loanApplicationNewMap.get(loanInstance.Id).Total_Loan_Amount__c != null && loanApplicationOldMap.get(loanInstance.Id).Total_Loan_Amount__c!=null){
                if(loanInstance.Final_Exposure__c != null && loanApplicationNewMap.get(loanInstance.Id).Total_Loan_Amount__c != loanApplicationOldMap.get(loanInstance.Id).Total_Loan_Amount__c){
                    Decimal Exposure = loanInstance.Final_Exposure__c - loanApplicationOldMap.get(loanInstance.Id).Total_Loan_Amount__c;
                    Exposure = Exposure + loanApplicationNewMap.get(loanInstance.Id).Total_Loan_Amount__c;
                    if(Exposure!=null){
                        loanInstance.Final_Exposure__c = Math.Round(Exposure);
                    }   
                    
                    
                }
                
                // recalculate Wheels Exposure based on updated loan amount
                if(loanInstance.RecordTypeId == twoWheelerRT && loanInstance.Wheels_Exposure__c != null && loanApplicationNewMap.get(loanInstance.Id).Total_Loan_Amount__c != loanApplicationOldMap.get(loanInstance.Id).Total_Loan_Amount__c){
                    Decimal wheelsExposure = loanInstance.Wheels_Exposure__c != 0 ? loanInstance.Wheels_Exposure__c - loanApplicationOldMap.get(loanInstance.Id).Total_Loan_Amount__c : 0;
                    wheelsExposure += loanApplicationNewMap.get(loanInstance.Id).Total_Loan_Amount__c;
                    loanInstance.Wheels_Exposure__c = wheelsExposure;
                }
                
                if( (loanApplicationOldMap.get(loanInstance.Id).Ops_Status__c =='' || String.isBlank(loanApplicationOldMap.get(loanInstance.Id).Ops_Status__c)) && loanApplicationNewMap.get(loanInstance.Id).Ops_Status__c == 'Discrepancy' ){
                    Count = Count+1;
                    loanInstance.Discrepancy_Count__c = Count;
                    
                }
                
            }    
        }
        
    }
    private void checkUploadedDocuments(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        
        List<Id> loanIds = new List<Id>(newRecordMap.keySet());
        User u = [SELECT Id,Profile.Name FROM User Where Id =: UserInfo.getUserId()];
        
        if( u.Profile.Name != 'Field Investigator' &&  loanApplicationNewMap.get(loanIds[0]).Stage__c != null && loanApplicationOldMap.get(loanIds[0]).Stage__c != 'PSD'  && loanApplicationNewMap.get(loanIds[0]).Stage__c != loanApplicationOldMap.get(loanIds[0]).Stage__c && (loanApplicationNewMap.get(loanIds[0]).Stage__c!='Rejected' && loanApplicationNewMap.get(loanIds[0]).Sub_Stage__c!='Rejected')){
            Utility.Result res =  Utility.checkUploadedDocs(loanIds[0],loanApplicationOldMap.get(loanIds[0]).Stage__c);
            if(res != null && res.status == 'error'){
                String errorMessage = '';
                String sBreak = '\n';
                for(String msge : res.messages){
                    errorMessage+= msge + sBreak;
                }
                loanApplicationNewMap.get(loanIds[0]).addError(errorMessage,false);
            }
        }
    }
    
    //BUG:SFAU-3126
    private void checkAmlPendingValidationOnCredit(Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        
        if(firstExec){
            Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
            Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
            
            List<Id> loanIds = new List<Id>(newRecordMap.keySet());
            if((loanApplicationNewMap.get(loanIds[0]).Stage__c != null && loanApplicationNewMap.get(loanIds[0]).Stage__c == 'Credit'  && loanApplicationOldMap.get(loanIds[0]).Stage__c != 'Credit') || loanApplicationOldMap.get(loanIds[0]).BRE_Decision__c=='STP'){
                for(Applicant__c app : [SELECT Id, AML_Status__c FROM Applicant__c WHERE Loan__c  =: loanIds[0] AND RecordType.Name !='Additional Match' AND RecordType.Name !='Nominee' AND IsInactive__c = false]){
                    if(app.AML_Status__c == 'Pending'){
                        loanApplicationNewMap.get(loanIds[0]).addError('Application can not move to Credit Stage as AML result is Pending');
                    }
                }
            }
            //SFAU-4848 start
            List<Applicant__c> applicants = [SELECT Id, AML_Status__c FROM Applicant__c WHERE Loan__c  =: loanIds[0] AND RecordType.DeveloperName='Primary_Applicant' AND IsInactive__c = false];
            if(applicants!=null && applicants.size()>0){
                if(applicants[0].AML_Status__c == 'Rejected' && loanApplicationOldMap.get(loanIds[0]).Stage__c=='Rejected' && loanApplicationNewMap.get(loanIds[0]).Stage__c!='Rejected'){
                    loanApplicationNewMap.get(loanIds[0]).addError('Application cannot move ahead as AML result is Rejected');
                }
            }
            firstExec=false;
        }
        //SFAU-4848 end
    }
    
    
    public void afterUpdate(List < sObject > newRecordList, Map < Id, sObject > oldRecordMap, Map < Id, sObject > newRecordMap) {
        Map < Id, Loan_Application__c > loanApplicationOldMap = (Map < Id, Loan_Application__c > ) oldRecordMap;
        Map < Id, Loan_Application__c > loanApplicationNewMap = (Map < Id, Loan_Application__c > ) newRecordMap;
        Set < Id > loanIds = new Set < Id > ();
        Set < Id > loanIdsForApplicationId = new Set < Id > ();
        Set < Id > loanRBMIds = new Set < Id > ();
        Map<Id, Loan_Application__c> psdStageLoanIdMap = new Map<Id, Loan_Application__c>();
        Map<String, Loan_Application__c> mapLoanIdvsApp = new Map<String, Loan_Application__c>();
        Set<String> setProductTractorCommIds = new Set<String>();
        setProductTractorCommIds.addAll(Label.Tractor_Product_Codes.split(','));
        setProductTractorCommIds.addAll(Label.Commercial_Product_Codes.split(','));
        Map<Id, Loan_Application__c> pddStageLoanIdMap = new Map<Id, Loan_Application__c>();
        Map<Id, Loan_Application__c> rejectedStageLoanIdMap = new Map<Id, Loan_Application__c>();
        Set<Id> trancheRelatedLoanIds = new Set<Id>();
        Set<Loan_Application__c> disbursedLoanApplication = new Set<Loan_Application__c>();
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Set<Id> loanAmountApplicationIds = new Set<Id>();
        Set<Id> applicationsWithAssetVerification = new Set<Id>();
        Boolean isInsert = oldRecordMap == NULL;
        List<Loan_Application__c> lstLoanAppForApplicationId = new List<Loan_Application__c>();
        
        //Notification || START
        List<Id> loanNotification = new List<Id>();
        List<Id> loanNotificationSTP = new List<Id>();
        List<Id> loanNotificationPDDRejection = new List<Id>();
        //END 
        for (Id loanId: newRecordMap.keySet()) {
            if(loanApplicationNewMap.get(loanId).Stage__c == 'PSD' && (loanApplicationOldMap.get(loanId).Stage__c != loanApplicationNewMap.get(loanId).Stage__c)){
                psdStageLoanIdMap.put(loanId, loanApplicationNewMap.get(loanId));
            }
            if(loanApplicationNewMap.get(loanId).Stage__c == 'PDD' && (loanApplicationOldMap.get(loanId).Stage__c != loanApplicationNewMap.get(loanId).Stage__c)){
                pddStageLoanIdMap.put(loanId, loanApplicationNewMap.get(loanId));
            }
            if(loanApplicationNewMap.get(loanId).Stage__c == 'Rejected' && (loanApplicationOldMap.get(loanId).Stage__c != loanApplicationNewMap.get(loanId).Stage__c)){
                rejectedStageLoanIdMap.put(loanId, loanApplicationNewMap.get(loanId));
            }
            if (loanApplicationOldMap.get(loanId).Stage__c != loanApplicationNewMap.get(loanId).Stage__c) {
                loanIds.add(loanId);
            }
            if (loanApplicationNewMap.get(loanId).Name != loanApplicationNewMap.get(loanId).Application_Id__c) {
                loanIdsForApplicationId.add(loanId);
                lstLoanAppForApplicationId.add(loanApplicationNewMap.get(loanId));
            }
            /*
            if (loanApplicationOldMap.get(loanId).Stage__c == 'Lead' && loanApplicationOldMap.get(loanId).Stage__c != loanApplicationNewMap.get(loanId).Stage__c) {
                loanIdsForApplicationId.add(loanId);
            }
            */
            if (loanApplicationNewMap.get(loanId).Sanction_Status__c == 'Issued' &&
                loanApplicationOldMap.get(loanId).Sanction_Status__c != loanApplicationNewMap.get(loanId).Sanction_Status__c) {
                    loanRBMIds.add(loanId);
                }
            //Notification Part 
            if (loanApplicationNewMap.get(loanId).E_Mandate_Status__c == 'Accepted' &&
                loanApplicationOldMap.get(loanId).E_Mandate_Status__c != loanApplicationNewMap.get(loanId).E_Mandate_Status__c) {
                    loanNotification.add(loanId);
                }
            if (loanApplicationNewMap.get(loanId).BRE_Decision__c == 'STP' &&
                loanApplicationOldMap.get(loanId).BRE_Decision__c != loanApplicationNewMap.get(loanId).BRE_Decision__c) {
                    loanNotificationSTP.add(loanId);
                }
            if (loanApplicationNewMap.get(loanId).OPS_PDD_Action__c == 'Rework' &&
                loanApplicationOldMap.get(loanId).OPS_PDD_Action__c != loanApplicationNewMap.get(loanId).OPS_PDD_Action__c) {
                    loanNotificationPDDRejection.add(loanId);
                }
            /*WIRR Update*/
            if((loanApplicationOldMap.get(loanId).Disbursement_Status__c != loanApplicationNewMap.get(loanId).Disbursement_Status__c) && (loanApplicationNewMap.get(loanId).Disbursement_Status__c  == 'Fully Disbursed') && (loanApplicationNewMap.get(loanId).Disbursed_Tranche__c == 0 || loanApplicationNewMap.get(loanId).Disbursed_Tranche__c !=null)){
                disbursedLoanApplication.add(loanApplicationNewMap.get(loanId));
            }
            /*
            if (loanApplicationNewMap.get(loanId).Disbursement_Status__c  == 'Fully Disbursed' && 
                String.isBlank(String.valueOf(loanApplicationNewMap.get(loanId).Disbursed_Tranche__c ))) {
                    disbursedLoanApplication.add(loanApplicationNewMap.get(loanId));
                }*/
            if((loanApplicationNewMap.get(loanId).Disbursement_Status__c  == 'Fully Disbursed' || 
                loanApplicationNewMap.get(loanId).Disbursement_Status__c  == 'Partially Disbursed')
               && String.isNotBlank(String.valueOf(loanApplicationNewMap.get(loanId).Disbursed_Tranche__c ))) {
                   trancheRelatedLoanIds.add(loanId);
                   
               }
            /* Commented by - Mohit   
            if( loanApplicationNewMap.get( loanId ).Asset_Verification_Required__c == 'Yes' && ( isInsert || loanApplicationNewMap.get( loanId ).Asset_Verification_Required__c != loanApplicationOldMap.get( loanId ).Asset_Verification_Required__c ) ){
                 // Commented Mohit - applicationsWithAssetVerification.add(loanId );
            }
            */
            // added below if block for publishing TAT Events
            if ((loanApplicationNewMap.get(loanId).Stage__c != loanApplicationOldMap.get(loanId).Stage__c ||
                 //loanApplicationNewMap.get(loanId).Sub_Stage__c != loanApplicationOldMap.get(loanId).Sub_Stage__c ||
                 loanApplicationNewMap.get(loanId).OwnerId != loanApplicationOldMap.get(loanId).OwnerId ||
                 loanApplicationNewMap.get(loanId).Application_FI_Status__c != loanApplicationOldMap.get(loanId).Application_FI_Status__c ||
                 loanApplicationNewMap.get(loanId).Ops_Status__c != loanApplicationOldMap.get(loanId).Ops_Status__c || 
                 loanApplicationNewMap.get(loanId).Submission_Remarks__c != loanApplicationOldMap.get(loanId).Submission_Remarks__c ||
                 loanApplicationNewMap.get(loanId).DO_Status__c != loanApplicationOldMap.get(loanId).DO_Status__c ||
                  loanApplicationNewMap.get(loanId).Sanction_Status__c != loanApplicationOldMap.get(loanId).Sanction_Status__c)) {
                     Loan_Application__c newLoanApp = new Loan_Application__c(Id = loanId, Stage__c = loanApplicationNewMap.get(loanId).Stage__c, Sub_Stage__c = loanApplicationNewMap.get(loanId).Sub_Stage__c,
                                                                              OwnerId = loanApplicationNewMap.get(loanId).OwnerId, Application_FI_Status__c = loanApplicationNewMap.get(loanId).Application_FI_Status__c,
                                                                              Ops_Status__c = loanApplicationNewMap.get(loanId).Ops_Status__c, Remarks__c = loanApplicationNewMap.get(loanId).Remarks__c, 
                                                                              Submission_Remarks__c = loanApplicationNewMap.get(loanId).Submission_Remarks__c, Approval_Status__c = loanApplicationNewMap.get(loanId).Approval_Status__c, 
                                                                              Rejection_Reason__c=loanApplicationNewMap.get(loanId).Rejection_Reason__c,
                                                                              Rejection_Sub_Reason__c = loanApplicationNewMap.get(loanId).Rejection_Sub_Reason__c, 
                                                                              Other_Rejection_Reason__c = loanApplicationNewMap.get(loanId).Other_Rejection_Reason__c, Sanction_Status__c = loanApplicationNewMap.get(loanId).Sanction_Status__c,
                          DO_Status__c = loanApplicationNewMap.get(loanId).DO_Status__c);
                     Loan_Application__c oldLoanApp = new Loan_Application__c(Id = loanId, Stage__c = loanApplicationOldMap.get(loanId).Stage__c, Sub_Stage__c = loanApplicationOldMap.get(loanId).Sub_Stage__c,
                                                                              OwnerId = loanApplicationOldMap.get(loanId).OwnerId, Application_FI_Status__c = loanApplicationOldMap.get(loanId).Application_FI_Status__c,
                                                                              Ops_Status__c = loanApplicationOldMap.get(loanId).Ops_Status__c, Remarks__c = loanApplicationOldMap.get(loanId).Remarks__c, 
                                                                              Submission_Remarks__c = loanApplicationOldMap.get(loanId).Submission_Remarks__c, Approval_Status__c = loanApplicationOldMap.get(loanId).Approval_Status__c, 
                                                                              Rejection_Reason__c=loanApplicationOldMap.get(loanId).Rejection_Reason__c, Rejection_Sub_Reason__c = loanApplicationOldMap.get(loanId).Rejection_Sub_Reason__c,
                          Other_Rejection_Reason__c = loanApplicationOldMap.get(loanId).Other_Rejection_Reason__c, Sanction_Status__c = loanApplicationOldMap.get(loanId).Sanction_Status__c,
                          DO_Status__c = loanApplicationOldMap.get(loanId).DO_Status__c);
                     tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(newLoanApp), Old_Records_Payload__c = JSON.serialize(oldLoanApp),
                                                             Object_API_Name__c = 'Loan_Application__c', Event_Date_Time__c = Datetime.now(), Logged_In_User__c = UserInfo.getUserId()));
                 }
            
            // update Apportioned loan amount when Applicantion Loan Amount is updated
            if(loanApplicationNewMap.get(loanId).Loan_Amount__c != loanApplicationOldMap.get(loanId).Loan_Amount__c){
                loanAmountApplicationIds.add(loanId);
                //handleExposureChange(newRecordList,newRecordMap,oldRecordMap); ///SFAU-3631
            }
            if(setProductTractorCommIds.contains(loanApplicationNewMap.get(loanId).Product__c) && (loanApplicationNewMap.get(loanId).Customer_Grade__c != loanApplicationOldMap.get(loanId).Customer_Grade__c || 
                loanApplicationNewMap.get(loanId).Net_Land_Holding_in_Acre__c != loanApplicationOldMap.get(loanId).Net_Land_Holding_in_Acre__c || loanApplicationNewMap.get(loanId).Original_Vehicle_Usage__c != loanApplicationOldMap.get(loanId).Original_Vehicle_Usage__c)){
                mapLoanIdvsApp.put(loanId, loanApplicationNewMap.get(loanId));
            }
        }
        /*
if(!psdStageLoanIdMap.isEmpty()){
RCLimitController.getValidLoanIdsAndUpdateRCLimit(psdStageLoanIdMap, 'PSD');
}*/
        if(!pddStageLoanIdMap.isEmpty()){
            RCLimitController.releaseRCLimit(pddStageLoanIdMap, 'PDD');
        }
        if(!rejectedStageLoanIdMap.isEmpty()){
            RCLimitController.releaseRCLimit(rejectedStageLoanIdMap, 'Rejected');
            /*Update the FI Records when case is Rejected*/
            FieldInvestigationUtility.handleCaseRejectOnFI(rejectedStageLoanIdMap);
            
        }
        if (!loanRBMIds.isEmpty()) {
            CreditApprovalHandler.createRBMTatkalApprovers(loanRBMIds);
        }
        PricingApprovalHandler.insertPricingApprovalPlatformEvent(newRecordMap, oldRecordMap);
        CreditApprovalHandler.insertCreditApproval(newRecordMap, oldRecordMap);
        if (!loanIds.isEmpty()) {
            COMShareApplicationRecordHandler.publishCOMPlatformEventRecords(loanIds);
        }
        if(!loanIdsForApplicationId.isEmpty()){
            updateNameWithApplicationId (lstLoanAppForApplicationId);
            // updateNameWithApplicationIdUpdate(loanIds);
        }
        if(!disbursedLoanApplication.isEmpty()){
            WIRRRecordsCreationController.handleFullDisbursedWIRRRecordUpsertion(disbursedLoanApplication);
        }
        if(!trancheRelatedLoanIds.isEmpty()) {
            WIRRRecordsCreationController.handleTrancheWIRRRecordUpsertion(trancheRelatedLoanIds);
        }
        if(!loanAmountApplicationIds.isEmpty()){
            evaluateApportionedLoanonCollateral(loanAmountApplicationIds);
            recalculateCharges(loanAmountApplicationIds);
        }
        if(mapLoanIdvsApp != null){
            evaluateApprovedLTV(mapLoanIdvsApp);
        }
        /* Commented by Mohit 
        if( !applicationsWithAssetVerification.isEmpty() ){
            setAssetVerificationRequired( applicationsWithAssetVerification );
        }
        Comment End */ 
        //createBSRAssignment(newRecordList);
        createOpsAssignment(oldRecordMap,newRecordList,newRecordMap);
        ShareRecordsWithUsers.shareLoanBasedOnProductAccess(oldRecordMap, newRecordMap,'Update');
        if (!tatEvents.isEmpty()) {
            Eventbus.publish(tatEvents);
        }
        PDDDocumentChecklistCreate.updateDocChkPDD(oldRecordMap,newRecordList,newRecordMap);
        
        //When stage has been changed call the notification
        List<Notification_Event__e> notificationList = new List<Notification_Event__e>();
        for(Id loanId : loanIds){
            if(loanApplicationNewMap.get(loanId).Stage__c !='Pricing' && loanApplicationNewMap.get(loanId).Stage__c !='PSD' && loanApplicationNewMap.get(loanId).Stage__c !='PDD' && loanApplicationNewMap.get(loanId).Stage__c !='Rejected'){
                Notification_Event__e notificationEvent1 = new Notification_Event__e();
                notificationEvent1.sObjectId__c = loanId;
                notificationEvent1.Trigger_Point__c = 'Stage Movement Trigger';
                //EventBus.publish(notificationEvent1);
                notificationList.add(notificationEvent1);
                
            }
            
            if(loanApplicationNewMap.get(loanId).Stage__c =='PDD'){
                //  NotificationHandler.sendNotification('PDD stage',loanId,'');  
                Notification_Event__e notificationEvent1 = new Notification_Event__e();
                notificationEvent1.sObjectId__c = loanId;
                notificationEvent1.Trigger_Point__c = 'PDD stage';
                //EventBus.publish(notificationEvent1);
                notificationList.add(notificationEvent1);
            }
            
            if(loanApplicationNewMap.get(loanId).Stage__c =='Rejected'){
                Notification_Event__e notificationEvent1 = new Notification_Event__e();
                notificationEvent1.sObjectId__c = loanId;
                notificationEvent1.Trigger_Point__c = 'Case Rejection';
                //EventBus.publish(notificationEvent1);
                notificationList.add(notificationEvent1);
                
            }
            
            String CEProduct = System.label.Construction_Equipment_Product_Codes; //R2 Updated
            String CVProduct =  System.label.Commercial_Product_Codes;//R2 Updated
            String TractorProduct = System.label.Tractor_Product_Codes; //R2 Updated
                if(loanApplicationNewMap.get(loanId).Product__c == '10201' || loanApplicationNewMap.get(loanId).Product__c == '10202' || loanApplicationNewMap.get(loanId).Product__c == '10203' || CEProduct.contains(loanApplicationNewMap.get(loanId).Product__c)  || CVProduct.contains(loanApplicationNewMap.get(loanId).Product__c) || TractorProduct.contains(loanApplicationNewMap.get(loanId).Product__c) || Label.AutoLoanCowProducts.contains(loanApplicationNewMap.get(loanId).Product__c)){ //R2 Updated // SFAU-5584
                if(loanApplicationOldMap.get(loanId).Stage__c == 'Pricing' && loanApplicationNewMap.get(loanId).Stage__c =='PSD' && loanApplicationNewMap.get(loanId).No_Pricing_Deviation__c == false ){
                    //NotificationHandler.sendNotification('Pricing Approval',loanId,'');  
                    Notification_Event__e notificationEvent1 = new Notification_Event__e();
                    notificationEvent1.sObjectId__c = loanId;
                    notificationEvent1.Trigger_Point__c = 'Pricing Approval';
                    EventBus.publish(notificationEvent1);
                }
            }
           if(loanApplicationNewMap.get(loanId).Product__c == '10301' || loanApplicationNewMap.get(loanId).Product__c == '10302' || loanApplicationNewMap.get(loanId).Product__c == '10303' || Label.TWCowProducts.contains(loanApplicationNewMap.get(loanId).Product__c) ){ // SFAU-5584
                if(loanApplicationOldMap.get(loanId).Stage__c == 'Pricing' && loanApplicationNewMap.get(loanId).Stage__c =='DDE' && loanApplicationNewMap.get(loanId).No_Pricing_Deviation__c == false ){
                    // NotificationHandler.sendNotification('Pricing Approval',loanId,'');  
                    Notification_Event__e notificationEvent1 = new Notification_Event__e();
                    notificationEvent1.sObjectId__c = loanId;
                    notificationEvent1.Trigger_Point__c = 'Pricing Approval';
                    EventBus.publish(notificationEvent1);
                }
            }
        }
        
        //E - Mandate and 
        if(loanNotification!=null && !loanNotification.isEmpty() && loanNotification.size()>0){
            for(Id loanId :loanNotification){
                //NotificationHandler.sendNotification('E-mandate/eNach',loanId,'');  
                Notification_Event__e notificationEvent1 = new Notification_Event__e();
                notificationEvent1.sObjectId__c = loanId;
                notificationEvent1.Trigger_Point__c = 'E-mandate/eNach';
                EventBus.publish(notificationEvent1);
            }
        }
        //If Case Under STP  Notification
        if(loanNotificationSTP!=null && !loanNotificationSTP.isEmpty() && loanNotificationSTP.size()>0){
            for(Id loanId :loanNotificationSTP){
                Notification_Event__e notificationEvent1 = new Notification_Event__e();
                notificationEvent1.sObjectId__c = loanId;
                notificationEvent1.Trigger_Point__c = 'if Case under STP';
                EventBus.publish(notificationEvent1);
            }
        }
        // PDD rejection
        if(loanNotificationPDDRejection!=null && !loanNotificationPDDRejection.isEmpty() && loanNotificationPDDRejection.size()>0){
            for(Id loanId :loanNotificationPDDRejection){
                Notification_Event__e notificationEvent2 = new Notification_Event__e();
                notificationEvent2.sObjectId__c = loanId;
                notificationEvent2.Trigger_Point__c = 'PDD Rejection';
                EventBus.publish(notificationEvent2);
                System.debug('publishedPDDReject');
            }
        }
        
        EventBus.publish(notificationList);
        
        //End
    }
    /*
public void updateDocChkPDD(Map < Id, sObject > oldRecordMap, List < sObject > newRecordList, 
Map < Id, sObject > newRecordMap){
Set<Id> loanIDSet = New Set<Id>();
//get all loan application which are changed to PDD
for(Loan_Application__c loan: (List<Loan_Application__c>)newRecordList){
Loan_Application__c oldrec = (Loan_Application__c)oldRecordMap.get(loan.Id);
if(oldrec.Stage__c!=loan.Stage__c && loan.Stage__c =='PDD'){
loanIDSet.add(loan.Id);
}
}
if(loanIDSet.size()>0){
Set<Id> appIDSet = New Set<Id>();
Map<Id,list<Id>> loanAppMap = new Map<Id,list<Id>>();
//get all applicants related to Loan application
for(Applicant__c app: [Select id,Loan__c from Applicant__c where Loan__c in:loanIDSet ]){
appIDSet.add(app.Id);
if(loanAppMap.containsKey(app.Loan__c)) {
List<Id> appId = loanAppMap.get(app.Loan__c);
appId.add(app.Id);
loanAppMap.put(app.Loan__c, appId);
} else {
loanAppMap.put(app.Loan__c, new List<Id> { app.Id });
}
}
Map<Id,list<Id>> loandocmap = new Map<Id,list<Id>>();
Map<Id,list<Id>> appdocmap = new Map<Id,list<Id>>();
//get all documents which are related to loan application and applicant where master stage is PDD
for(Document_Checklist__c doc: [select id,Loan_Application__c, Applicant__c from Document_Checklist__c where 
(Loan_Application__c in:loanIDSet OR Applicant__c in: appIDSet) 
AND Document_Master__r.Stage__c = 'PDD']){
if(doc.Loan_Application__c != null){
if(loandocmap.containsKey(doc.Loan_Application__c)) {
List<Id> docId = loandocmap.get(doc.Loan_Application__c);
docId.add(doc.Id);
loandocmap.put(doc.Loan_Application__c, docId);
} else {
loandocmap.put(doc.Loan_Application__c, new List<Id> { doc.Id });
}
}else {
if(doc.Applicant__c!=null){
if(appdocmap.containsKey(doc.Applicant__c)) {
List<Id> docId = appdocmap.get(doc.Applicant__c);
docId.add(doc.Id);
appdocmap.put(doc.Applicant__c, docId);
} else {
appdocmap.put(doc.Applicant__c, new List<Id> { doc.Id });
}
}
}
}
List<Document_Checklist__c> docChkUpdList = New List<Document_Checklist__c>();
//get all loan records
for(id loanId: loanIDSet){
Integer seqNum = 1;
set<Id> docSet = New Set<Id>();
//get loan record related documents
if(loandocmap.containsKey(loanId)){
for(id doci : loandocmap.get(loanId)){
Document_Checklist__c doc = new Document_Checklist__c();
doc.id = doci;
doc.Sequence__c = seqNum;
seqNum+=seqNum;
docChkUpdList.add(doc);
docSet.add(doci);
}
}
//get all applicants related to loan application
if(loanAppMap.containsKey(loanId)){
for(id appsId: loanAppMap.get(loanId)){
//get all documents related to applicants
if(appdocmap.containsKey(appsId)){
for(id docsI: appdocmap.get(appsId)){
if(!docSet.contains(docsI)){
Document_Checklist__c doc = new Document_Checklist__c();
doc.id = docsI;
doc.Sequence__c = seqNum;
seqNum+=seqNum;
docChkUpdList.add(doc);
docSet.add(docsI);
}
}
}
}
}
}
update docChkUpdList;
}
}
*/
    /**
* SFAU-2435
* Application sent back from Credit Managers have Approval Status -> Credit Sent Back To RO that should be clear when it goes again for Approval to CM 
*/
    /*  public static void updateApplicationsPreviouslySentBackByCM(Loan_Application__c[] newApplications, map<Id, Loan_Application__c> oldApplicationsMap){
for(Loan_Application__c app: newApplications){
if(app.Stage__c == GlobalConstants.STAGE_CREDIT && oldApplicationsMap.get(app.Id).Stage__c != GlobalConstants.STAGE_CREDIT && String.isNotBlank(app.Approval_Status__c) && app.Approval_Status__c.contains('Send Back To RO')){
app.Approval_Status__c = null;
}
}
} */
    
    public static void validateLoanAmountChanged(Loan_Application__c[] loanApplications, map<Id, Loan_Application__c> newLoanApplications, map<Id, Loan_Application__c> oldLoanApplications){
        Set<Id> applicationsToValidate = new Set<Id>();
        for(Loan_Application__c loan: loanApplications){
            if(loan.Loan_Amount__c != oldLoanApplications.get(loan.Id).Loan_Amount__c){
                applicationsToValidate.add(loan.Id);
                loan.isLoanAmtChanged__c = true; //SFAU-5147
            }
        }
        System.debug(' ==== applicationsToValidate ==> ' + JSON.serializePretty(applicationsToValidate));
        String[] vehicleTypes = AUSFVehicleController.VEHICLE_RECORD_TYPES;
        if(!applicationsToValidate.isEmpty()){
            for(Collateral__c collateral: [ SELECT Id, Final_Cost__c, Loan__c,Is_Deleted__c FROM Collateral__c WHERE Is_Deleted__c = false AND Loan__c IN: applicationsToValidate AND RecordType.DeveloperName IN: vehicleTypes ]){
                Decimal newLoanAmount = newLoanApplications.get(collateral.Loan__c).Loan_Amount__c,
                    oldLoanAmount = oldLoanApplications.get(collateral.Loan__c).Loan_Amount__c;
                if(newLoanAmount != null && collateral.Final_Cost__c != null && newLoanAmount > collateral.Final_Cost__c){
                    newLoanApplications.get(collateral.Loan__c).addError(Label.Loan_Amount_Exceeded_Final_Cost);
                }
            }
        }
    }
    public static void evaluateApportionedLoanonCollateral(Set<Id> loanIds){
        Collateral__c[] collateralsToUpdate = new Collateral__c[0];
        String[] vehicleTypes = AUSFVehicleController.VEHICLE_RECORD_TYPES;
        Set<Loan_Application__c> applicationsToUpdate = new Set<Loan_Application__c>();
        
        for(Collateral__c collateral: [ SELECT Id, LTV_Record__c, On_Road_Price__c,Cost_to_be_Consider__c,Collateral_Name__c, Vehicle_Cost__c, Final_Cost__c, LS_Value__c, Approved_LTV__c, Net_of_Discount_Price__c,  Product__c, Other_Funding_Total__c, Loan__r.Loan_Amount__c, Loan__r.Total_Loan_Amount__c, Apportioned_Loan_Amount__c, Loan__r.RecordType.Name FROM Collateral__c WHERE Loan__c IN: loanIds AND RecordType.DeveloperName IN: vehicleTypes AND Is_Deleted__c  = FALSE ]){
            List<String> lstSubProd = new List<String>();
            lstSubProd.add('Used');
            lstSubProd.addAll(Label.COW_Product_Names.split(','));
            Boolean isUsedScreen = lstSubProd.contains(Utility.getSubProductName( collateral.Product__c ));            
            //Boolean isUsedScreen = (new String[]{ 'Used', 'Cash on Wheels' }).contains(Utility.getSubProductName( collateral.Product__c ));
            if(isUsedScreen){
                collateral.Apportioned_Loan_Amount__c = collateral.Loan__r.Loan_Amount__c;
                collateral.LTV_offered_On_road__c = Utility.getLTVOfferedOnRoadPrice( collateral );
                collateral.LTV_offered_On_final_cost__c = Utility.getLTVOfferedOnFinalCost( collateral );
                collateral.Loan_Eligibilty__c = String.valueOf(Utility.getLoanEligibility( collateral ));
                collateral.Customer_equity__c = Utility.getCustomerEquity( collateral );
                
                // SFAU-2970 -- Since LTV Final cost is editable for 2W - the calculations shouldnt be overridden
                if(collateral.Loan__r.RecordType.Name != GlobalConstants.TWOWHEELER){
                    collateral.LTV_offered_On_final_cost__c = Utility.getLTVOfferedOnFinalCost( collateral );
                }
            } else {
                collateral.Apportioned_Loan_Amount__c = collateral.Loan__r.Loan_Amount__c + (collateral.Other_Funding_Total__c != null ? collateral.Other_Funding_Total__c : 0);
                collateral.LTV_offered_On_road__c = Utility.getLTVOfferedOnRoadPriceNew( collateral );
                collateral.LTV_offered_On_final_cost__c = Utility.getLTVOfferedOnFinalCostNew( collateral );
                collateral.Loan_Eligibilty__c = String.valueOf(Utility.getLoanEligibilityNewVehicle( collateral )); //SFAU-4328 -- Populate Loan Eligibility for New Vehicles.
                collateral.LTV_offered_Ex_showroom__c = Utility.getLTVOfferedExshowroomPrice(collateral);
                if(collateral.Loan__r.RecordType.Name == GlobalConstants.TRACTOR){
                    collateral.LTV_offered__c = Utility.getLTVOffered( collateral );
                    collateral.LTV_offered_On_final_cost__c = collateral.LTV_offered__c;
            }
            }

            applicationsToUpdate.add(
                new Loan_Application__c(
                    Id = collateral.Loan__c,
                    Total_Loan_Amount__c = collateral.Apportioned_Loan_Amount__c
                )
            );
            collateralsToUpdate.add(
                collateral
            );
        }
        update collateralsToUpdate;
        update new List<Loan_Application__c>(applicationsToUpdate);
    }
    
    public static void evaluateApprovedLTV(Map<String,Loan_Application__c> mapLoanIdvsLoanRecord){
        List<Collateral__c> collateralsToUpdate = new List<Collateral__c>();
        String[] vehicleTypes = AUSFVehicleController.VEHICLE_RECORD_TYPES;
        //Set<Loan_Application__c> applicationsToUpdate = new Set<Loan_Application__c>();

        for(Collateral__c collateral: [ SELECT Id, Max_Funding_Cap__c, Scheme__c, Vehicle_Usage__c, Vehicle_Category__c, LTV_Record__c, Assessment_Method__c, Loan__c, On_Road_Price__c,Cost_to_be_Consider__c,Collateral_Name__c, Vehicle_Cost__c, Final_Cost__c, LS_Value__c, Approved_LTV__c, Net_of_Discount_Price__c,  Product__c, Other_Funding_Total__c, Loan_Eligibilty__c, Loan__r.Loan_Amount__c, Loan__r.Total_Loan_Amount__c, Apportioned_Loan_Amount__c, Loan__r.RecordType.Name FROM Collateral__c WHERE Loan__c IN: mapLoanIdvsLoanRecord.keySet() AND RecordType.DeveloperName IN: vehicleTypes AND Is_Deleted__c  = FALSE ]){
            List<String> lstSubProd = new List<String>();
            lstSubProd.add('Used');
            lstSubProd.addAll(Label.COW_Product_Names.split(','));
            Boolean isUsedScreen = lstSubProd.contains(Utility.getSubProductName( collateral.Product__c ));  
            //Boolean isUsedScreen = (new String[]{ 'Used', 'Cash on Wheels' }).contains(Utility.getSubProductName( collateral.Product__c ));
            if(collateral.Loan__r.RecordType.Name == GlobalConstants.TRACTOR && !isUsedScreen && collateral!=null && mapLoanIdvsLoanRecord.get(collateral.Loan__c)!=null){
                collateral.Approved_LTV__c = Utility.getLTVOfferedBasedGradeTractorNew( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Loan_Eligibilty__c = Utility.getLoanEligibilityBasedGradeTractor( collateral, collateral.Approved_LTV__c);
            }
            else if(collateral.Loan__r.RecordType.Name == GlobalConstants.TRACTOR && isUsedScreen){
                collateral.Approved_LTV__c = Utility.getLTVOfferedBasedGradeTractorUsed( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Loan_Eligibilty__c = Utility.getLoanEligibilityBasedGradeTractor( collateral, collateral.Approved_LTV__c);
            }
            else if((collateral.Loan__r.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE || 
                collateral.Loan__r.RecordType.Name == GlobalConstants.CONSTRUCTIONEQUIP) && collateral.Assessment_Method__c == 'LTV' && !isUsedScreen){
                collateral.Approved_LTV__c = Utility.getLTVBasedGradeCommercialNew( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Approved_LTV__c = collateral.Approved_LTV__c != null ? collateral.Approved_LTV__c : '0'; 
                collateral.Loan_Eligibilty__c = String.valueOf(Decimal.valueOf(collateral.Approved_LTV__c) / collateral.Net_of_Discount_Price__c);
            }
            else if((collateral.Loan__r.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE || 
                collateral.Loan__r.RecordType.Name == GlobalConstants.CONSTRUCTIONEQUIP) && collateral.Assessment_Method__c == 'LTV' && isUsedScreen){
                collateral.Approved_LTV__c = Utility.getLTVBasedGradeCommercialUsed( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Approved_LTV__c = collateral.Approved_LTV__c != null ? collateral.Approved_LTV__c : '0'; 
                collateral.Loan_Eligibilty__c = String.valueOf((Decimal.valueOf(collateral.Approved_LTV__c) / 100) * collateral.Apportioned_Loan_Amount__c);
            }
            else if((collateral.Loan__r.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE || 
                collateral.Loan__r.RecordType.Name == GlobalConstants.CONSTRUCTIONEQUIP) && collateral.Assessment_Method__c == 'Absolute' && !isUsedScreen){
                collateral.Loan_Eligibilty__c = Utility.getLTVBasedGradeCommercialNew( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Loan_Eligibilty__c = collateral.Loan_Eligibilty__c != null ? collateral.Loan_Eligibilty__c : '0';             
                collateral.Approved_LTV__c = String.valueOf(Decimal.valueOf(collateral.Loan_Eligibilty__c) / collateral.Net_of_Discount_Price__c);
            }
            else if((collateral.Loan__r.RecordType.Name == GlobalConstants.COMMERCIALVEHICLE || 
                collateral.Loan__r.RecordType.Name == GlobalConstants.CONSTRUCTIONEQUIP) && collateral.Assessment_Method__c == 'Absolute' && isUsedScreen){
                collateral.Loan_Eligibilty__c = Utility.getLTVBasedGradeCommercialUsed( collateral, mapLoanIdvsLoanRecord.get(collateral.Loan__c));
                collateral.Loan_Eligibilty__c = collateral.Loan_Eligibilty__c != null ? collateral.Loan_Eligibilty__c : '0';             
                collateral.Approved_LTV__c = String.valueOf(Decimal.valueOf(collateral.Loan_Eligibilty__c) / collateral.Net_of_Discount_Price__c);            
            }
            collateralsToUpdate.add(collateral);
        }
        update collateralsToUpdate;
    }
    
    // START || SFAU-5147
    public static void recalculateCharges(Set<Id> loanIds){
        List<Charge__c> chargeUpdationList = new List<Charge__c>();
        List<Charge__c> stampDutyUpdationList = new List<Charge__c>();
        List<Charge__c> chargeList = [SELECT Id, Actual_rate__c, Charge_Amount__c, Tax_Amount__c, Total_Amount__c,Loan_Application__r.Loan_Amount__c,Loan_Application__c,
                                      Charges_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                      Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                      Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                      Deviation_Applicable__c, Shown_to_UI__c 
                                      FROM Charge__c 
                                      WHERE Loan_Application__c IN :loanIds
                                      AND Value_Type__c='Percent'];
        
        
        if(!chargeList.isEmpty() && chargeList.size()>0){
            String loanId = chargeList[0].Loan_Application__c;
            List<Loan_Application__c> loanApplLst = ChargesController.getLoanAppl(loanId);
            String state = loanApplLst[0].Branch_Master__r.State__r.Account_Name__c;
            Decimal loanAmount = loanApplLst[0].Loan_Amount__c;
           /* List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = [SELECT id, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
                                                                                 As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
                                                                                 Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
                                                                                 Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
                                                                                 Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c
                                                                                 FROM Stamping_Charges_Calculation__mdt
                                                                                 WHERE State__c =: state WITH SECURITY_ENFORCED];
            */
            for(Charge__c chargeInstance : chargeList){
                Charge__c chargeNewInstance =chargeInstance;
                decimal chargeAmount = (chargeInstance.Loan_Application__r.Loan_Amount__c) * (chargeInstance.Actual_rate__c/100);
                chargeNewInstance.Id = chargeInstance.Id;
                chargeNewInstance.Charge_Amount__c = chargeAmount;
                /* START - SFAU-5522 - Change and Update Tax Amount */
                Decimal taxAmount = 0;
                if(chargeInstance.Tax_Percentage__c!=null){
                    taxAmount = (chargeInstance.Tax_Percentage__c * chargeAmount);
                }
                chargeNewInstance.Tax_Amount__c = taxAmount.setScale(2);
                chargeNewInstance.Total_Amount__c = (chargeAmount + taxAmount).setScale(2);
                /* END - SFAU-5522 - Change and Update Tax Amount */
                chargeUpdationList.add(chargeNewInstance);
            }
            
            System.debug('chargeUpdationList-->' +chargeUpdationList);
            if(chargeUpdationList!=null && !chargeUpdationList.isEmpty() && chargeUpdationList.size()>0 ){
                update chargeUpdationList;
            }
            
            /*for(Charge__c chargeInstance : chargeUpdationList){
                if(chargeInstance.Charges_Name__c == 'Stamp duty'){
                    Charge__c chargeNewInstance = new Charge__c();
                    ChargesController.FldsWrapper chrgeobj = ChargesController.wrapperFldsOfCharge(chargeInstance);
                    Decimal finalStampingCharge = calculateStampDutyCharge(chrgeobj,stampChrgesCalculationLst,loanAmount);
                    System.debug('finalStampingCharge-->' +finalStampingCharge); 
                    if(finalStampingCharge!=null){
                        chargeNewInstance.Id = chargeInstance.Id; 
                        chargeNewInstance.Total_Amount__c = finalStampingCharge + (chargeInstance.Tax_Percentage__c * finalStampingCharge);
                        stampDutyUpdationList.add(chargeNewInstance);
                    }
                    System.debug('stampDutyUpdationList-->' +stampDutyUpdationList);
                }
            }
            
            if(stampDutyUpdationList!=null && !stampDutyUpdationList.isEmpty() && stampDutyUpdationList.size()>0 ){
                update stampDutyUpdationList;
            }*/
            // SFAU-4796 - Recompute Stamping Charge
            ChargesController.computeStampDutyCharge(loanIds);
        }
    }
    
    // SFAU-4796 - Recompute Stamping Charge - Commented duplicate code
    /* 
    public static Decimal calculateStampDutyCharge(ChargesController.FldsWrapper fldWrapp, List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst,Decimal loanAmount) {
        
        Decimal surcharge;
        Decimal stampingCharge;
        Decimal roundOffUpperLimit;
        Decimal poa;
        Decimal guaranteeDeed;
        
        system.debug('stampChrgesCalculationLst--'+JSON.serialize(stampChrgesCalculationLst));
        for(Stamping_Charges_Calculation__mdt stampChrgesCalculationMetaDt : stampChrgesCalculationLst) {
            system.debug('MasterLabel-- '+stampChrgesCalculationMetaDt.MasterLabel);
            Decimal asPerStampingAct;
            Decimal guaranteeDeedEachGaurantor;
            String asPerStampingActValueType;
            String guaranteeDeedValueType;
            Decimal asPerStampingActLoanCap        = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Loan_Cap__c;
            Boolean isStampingActLoanCapLessThan   = stampChrgesCalculationMetaDt.Is_Stamping_Act_Loan_Cap_Less_than__c;
            Decimal guaranteeDeedLoanCap           = stampChrgesCalculationMetaDt.Guarantee_Deed_Loan_Cap__c;
            Boolean isGuaranteeDeedLoanCapLessThan = stampChrgesCalculationMetaDt.Is_Guarantee_Deed_Loan_Cap_Less_than__c;
            
            if(asPerStampingActLoanCap != null) {
                System.debug('loanAmount-->' +loanAmount);
                if(isStampingActLoanCapLessThan && loanAmount < asPerStampingActLoanCap) {
                    asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                    
                    system.debug('stampingCharge inside if-- '+stampingCharge);
                    asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
                }
                else if(isStampingActLoanCapLessThan == false && loanAmount >= asPerStampingActLoanCap){
                    asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                    
                    system.debug('stampingCharge inside else-- '+stampingCharge);
                    asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
                }
            }
            else {
                asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
            }
            
            if(guaranteeDeedLoanCap != null) {
                if(isGuaranteeDeedLoanCapLessThan && loanAmount < guaranteeDeedLoanCap) {
                    guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                    guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
                }
                else if(isGuaranteeDeedLoanCapLessThan == false && loanAmount >= guaranteeDeedLoanCap){
                    guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                    guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
                }
            }
            else {
                guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
            }
            
            if(asPerStampingActValueType == 'Percent') {
                stampingCharge = (asPerStampingAct / 100) * loanAmount;
                system.debug('stampingCharge inside percent-- '+stampingCharge);
                surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                poa = stampChrgesCalculationMetaDt.POA__c;
            }
            else if(asPerStampingActValueType == 'Fixed') {
                stampingCharge = asPerStampingAct;
                system.debug('stampingCharge inside fixed-- '+stampingCharge);
                surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                poa = stampChrgesCalculationMetaDt.POA__c;
            }
            if(guaranteeDeedValueType == 'Percent') {
                guaranteeDeed = (guaranteeDeedEachGaurantor/100) * loanAmount;
                surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                poa = stampChrgesCalculationMetaDt.POA__c;
            }
            else if(guaranteeDeedValueType == 'Fixed'){
                guaranteeDeed = guaranteeDeedEachGaurantor;
                surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                poa = stampChrgesCalculationMetaDt.POA__c;
            }        
        }
        system.debug('stampingCharge-- '+stampingCharge);
        Decimal roundOffStampingCharge;
        Decimal finalStampingCharge;
        
        if(stampingCharge != null) {
            roundOffStampingCharge = (stampingCharge/roundOffUpperLimit).round(System.RoundingMode.CEILING)*roundOffUpperLimit;
            stampingCharge     = roundOffStampingCharge + poa + guaranteeDeed;
            finalStampingCharge = stampingCharge + (surcharge/100) * stampingCharge;
            fldWrapp.chargeAmount = finalStampingCharge;
            system.debug('roundOffStampingCharge--' + roundOffStampingCharge);
            system.debug('stampingCharge--' + stampingCharge);
            system.debug('finalStampingCharge--' + finalStampingCharge);
        }
        return finalStampingCharge;
    }
    // END || SFAU-5147
    */

    public void calculateFirstEMIDate(List<SObject> newRecordList, Map<Id, sObject> newRecordMap,Map<Id, sObject> oldRecordMap){
        Set<Id> setLoanAppIds = new Set<Id>();
        Integer addMonths, minDays = 20, maxDays;
        for (Loan_Application__c loanApp : (List<Loan_Application__c>) newRecordList) {
            if(loanApp.Emi_Frequency__c == 'MONTHLY'){
                addMonths = 1;
                maxDays = 60;
            }else if(loanApp.Emi_Frequency__c == 'QUARTERLY'){
                addMonths = 3;
                maxDays = 120;
            }else if(loanApp.Emi_Frequency__c == 'HALF YEARLY'){
                addMonths = 6;
                maxDays = 210;
            }
            Loan_Application__c oldLoanApp = loanApp.Id != null ? (Loan_Application__c)oldRecordMap.get(loanApp.Id) : null ;
            minDays = (loanApp.Stage__c == 'Ops Maker' || loanApp.Stage__c == 'Ops Author') ? Integer.valueOf(Label.minFirstEMIDaysOps) : minDays;
            if(loanApp.First_EMI_Date__c!=null && loanApp.EMI_Date__c!=null && loanApp.Emi_Frequency__c!=null){
                if(loanApp.EMI_Date__c != oldLoanApp.EMI_Date__c || loanApp.Emi_Frequency__c != oldLoanApp.Emi_Frequency__c){              
                    if(loanApp.EMI_Date__c == '10' || loanApp.EMI_Date__c == '18'){
                        Date currentMonthEMIDate = date.newinstance(Date.today().year(), Date.today().month(), Integer.valueOf(loanApp.EMI_Date__c));
                        if(currentMonthEMIDate < Date.today()){
                            Date expectedFirstEMIDate = date.newinstance(Date.today().year(), Date.today().month()+addMonths, Integer.valueOf(loanApp.EMI_Date__c));
                            if(Date.today().daysBetween(expectedFirstEMIDate) > minDays && currentMonthEMIDate.daysBetween(expectedFirstEMIDate) < maxDays){
                                loanApp.First_EMI_Date__c = expectedFirstEMIDate;
                            }else{
                                loanApp.First_EMI_Date__c = date.newinstance(Date.today().year(), Date.today().month()+addMonths+1, Integer.valueOf(loanApp.EMI_Date__c));
                            }
                        }else{
                            if(Date.today().daysBetween(currentMonthEMIDate) > minDays && Date.today().daysBetween(currentMonthEMIDate) < maxDays){
                                loanApp.First_EMI_Date__c = currentMonthEMIDate;
                            }else{
                                loanApp.First_EMI_Date__c = date.newinstance(Date.today().year(), Date.today().month()+addMonths, Integer.valueOf(loanApp.EMI_Date__c));
                            }
                        }
                    } 
                }
                if(loanApp.First_EMI_Date__c != oldLoanApp.First_EMI_Date__c){
                    if(loanApp.First_EMI_Date__c.Day() != Integer.valueOf(loanApp.EMI_Date__c)){
                        loanApp.addError('The First EMI Date should only be '+loanApp.EMI_Date__c+ ' of any month.');
                    }else if(loanApp.First_EMI_Date__c.Day() == Integer.valueOf(loanApp.EMI_Date__c)){
                        if(loanApp.First_EMI_Date__c< Date.today()){
                            loanApp.addError('Entered First EMI Date is a past date. Please enter a valid date');
                        }else{
                            System.debug('Date.today().daysBetween(loanApp.First_EMI_Date__c): '+Date.today().daysBetween(loanApp.First_EMI_Date__c));
                            if(Date.today().daysBetween(loanApp.First_EMI_Date__c) < minDays || Date.today().daysBetween(loanApp.First_EMI_Date__c) > maxDays){
                                loanApp.addError('First EMI Date cannot be more than '+minDays+' days and less than '+maxDays+' days from today. Please enter a valid First EMI Date.');
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    public static void prepopulateFieldValues(Loan_Application__c[] newApplications, map<Id, Loan_Application__c> oldApplicationsMap){
        Set<Id> loanIds = new Set<Id>();
        for(Loan_Application__c application: newApplications){
            if( application.Stage__c != oldApplicationsMap.get(application.Id).Stage__c ){
                application.Previous_Stage__c = oldApplicationsMap?.get( application.Id ).Stage__c;
            }
            // Updated Application eligible for 
            if(application.Is_Rework__c && application.Stage__c == GlobalConstants.STAGE_CREDIT){
                // application.Is_Rework__c = false;
            }
            // // SFAU-5573 - Saving previous RBP value.
            if(application.ROI__c != oldApplicationsMap.get(application.Id).Old_ROI__c){
                application.Old_ROI__c = oldApplicationsMap?.get( application.Id ).ROI__c;
            }
        }       
    }
    // Archive old Pricing approvals when the case the relooked or if it is a send back case
    public static void archivePricingApprovals( Loan_Application__c[] newApplications, map<Id, Loan_Application__c> oldApplicationsMap ){
        Set<Id> loanIds = new Set<Id>();
        Set<Id> loanIdsInSync = new Set<Id>();
        for( Loan_Application__c loan: newApplications ){
            if((loan.Is_Rework__c && loan.Stage__c == GlobalConstants.STAGE_CREDIT && loan.Stage__c != oldApplicationsMap.get(loan.Id).Stage__c)){
                loanIds.add( loan.Id );
            } else if((loan.Stage__c == GlobalConstants.STAGE_CREDIT && loan.Is_Being_Relooked__c && !oldApplicationsMap.get(loan.Id).Is_Being_Relooked__c)){
                loanIdsInSync.add( loan.Id );
            }
        }
        if( !loanIds.isEmpty() ){
            Set<Id> pricingApprovals = new map<Id, Loan_Application_Approval__c>([ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIds AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_PRICING AND Archived__c = FALSE ]).keySet();
            
            if(!pricingApprovals.isEmpty()){
                CreditApprovalHandler.archiveApprovalsAsync(pricingApprovals);
            }
        } else if( !loanIdsInSync.isEmpty() ){
            Loan_Application_Approval__c[] approvalToArchive = [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c IN: loanIdsInSync AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_PRICING AND Archived__c = FALSE ];
            for( Loan_Application_Approval__c approval: approvalToArchive ){
                approval.Archived__c = true;
            }
            AUSFLoanApplication_WithoutSharing.unlockApprovals( approvalToArchive );
            update approvalToArchive;
            
        }
    }
    
    /**
    * SFAU-1241 - Asset Verification
    * 20th Sept 23
    * Commented by Mohit 
    public static void setAssetVerificationRequired( Set<Id> loanIds ){
        Verification__c[] assetVerifications = new Verification__c[0];
        Id assetVerificationRecordTypeId = Utility.getRecordTypeId( SObjectType.Verification__c.getSObjectType(), 'Asset Verification' );
        
        for( Collateral__c collateral: [ SELECT Id, Loan__c, Loan__r.Branch_Master__r.Asset_Verification_Queue__c FROM Collateral__c WHERE Loan__c IN: loanIds AND RecordTypeId IN: GlobalConstants.colRecordTypeIds ] ){
            
            Id queueId = String.isNotBlank( collateral.Loan__r.Branch_Master__r.Asset_Verification_Queue__c ) ? collateral.Loan__r.Branch_Master__r.Asset_Verification_Queue__c : null;
            if( queueId != null ){
                assetVerifications.add(
                    new Verification__c(
                        Collateral__c = collateral.Id,
                        Loan__c = collateral.Loan__c,
                        Status__c = 'Not Started',
                        RecordTypeId = assetVerificationRecordTypeId,
                        OwnerId =  queueId
                    )
                );
            }
        }
        
        // :TODO - these records have to be shared to the branch's Asset Verification queue
        insert assetVerifications;
    }
    */

    /*public void validateTARStatus(Loan_Application__c[] newApplications, map<Id, Loan_Application__c> oldApplicationsMap){
        Set<String> prodApplicable = New Set<String>{'10501','10502','10503'};
        Set<Id> loanIdSet = New Set<Id>();
        Map<Id,Integer> loanColCountMap = New Map<Id,Integer>();
        Map<Id,Integer> loanAppCountMap = New Map<Id,Integer>();
        for(Loan_Application__c la: newApplications){
            if(prodApplicable.contains(la.Product__c) && la.Stage__c == 'Ops Maker' &&  oldApplicationsMap.get(la.Id).Stage__c == 'PSD'){
                loanIdSet.add(la.Id);
                loanColCountMap.put(la.Id,0);
                loanAppCountMap.put(la.Id,0);
            }
        }

        for(AggregateResult aggr: [Select Loan__c, count(id) colCount from Collateral__c where Loan__c =:loanIdSet and 
            TAR_Status__c <> 'Submitted' group by Loan__c]){
                loanColCountMap.put((id)aggr.get('Loan__c'), (Integer)aggr.get('colCount') );
        }

        for(AggregateResult aggr: [Select Loan_Application__c, count(id) colCount from Loan_Application_Approval__c 
            where Loan_Application__c =:loanIdSet and Approval_Status__c = 'Approved' group by Loan_Application__c]){
                loanAppCountMap.put((id)aggr.get('Loan_Application__c'), (Integer)aggr.get('colCount') );
        }

        for(Loan_Application__c la: newApplications){
            if((loanColCountMap.containsKey(la.Id) && loanColCountMap.get(la.Id)>0) && 
            (loanAppCountMap.containsKey(la.Id) && loanAppCountMap.get(la.Id) == 0)){
                la.addError('Please submit TAR to proceed');
            }
        }
    }*/
    
    public void beforeDelete(Map < Id, sObject > oldRecordMap) {}
    
    public void afterDelete(Map < Id, sObject > oldRecordMap) {}
    
    public void afterUndelete(Map < Id, sObject > newRecordList) {}
}