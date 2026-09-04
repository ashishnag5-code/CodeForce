/**
 * @description       : 
 * @author            : Mohit M. | Salesforce
 * @group             : 
 * @last modified on        :   Last Modified By        :       Description
 * 12-June-2023             :   Mohit M.                :       updateApplicationFIStatus - Check Current Loan Application Stage and Move Back WHEN FI STATUS = 'Negative'
 * June-22-2023             :   Mohit M.                :       SFAU-3365 - method - change method updateApplicationFIStatus - as logic was not working as expected
 * June-22-2023             :   Yash                	:       Deviations Logic added
 * Sep-21-2023              :   Yash                    :       SFAU-5179 Change added to track if FI is marked negative again.
 * Sep-25-2023              :   Samridhi                :       SFAU-5261 Reset Draft stage when moving from PSD to QDE Stage in case of FI Negative
 * Sep-25-2023              :   Yash                    :       SFAU-4789 RUpdate FI on pOsitve

**/
public without sharing class FieldInvestigationService implements ServiceInterface {
    
    public static Set<Id> setRecordTypeId;

    /**
    * @description 
    * @author Mohit M | Salesforce | 16-01-2023 
    * @return String 
    **/
    public static String createQuery() {
        return ' Id,FI_Officer_Name_EMP_code_Agency_Name__c,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c';
        
    }

    /**
    * @description 
    * @author Mohit M | Salesforce | 16-01-2023 
    * @param whereClause 
    * @return List<Document_Checklist__c> 
    **/
    public static List<Field_Investigation__c> getFieldInvestigationRecords(String whereClause){
        String queryString ='';
        try{
            if(String.isNotBlank(whereClause)){
                queryString = 'SELECT ' + createQuery() + ' FROM Field_Investigation__c WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
            }else{
                queryString = 'SELECT ' + createQuery() + ' FROM Field_Investigation__c WITH SECURITY_ENFORCED' ;
            }
            system.debug('queryString'+queryString);
            return Database.query(queryString);
        }
        catch(Exception ex){
            System.debug('Excepton ex ' + ex);
        }
        return null;
    }
    
    public void beforeInsert(List<sObject> newRecordList){
        handleCreditManagerSetupOnRecord((List<Field_Investigation__c>)newRecordList);
    
    }
    
    private static void handleCreditManagerSetupOnRecord(List<Field_Investigation__c> investigationRecords){
        for(Field_Investigation__c fiRecord : investigationRecords){
            if(fiRecord.Loan_Application_Product_Type__c == 'Two Wheeler'){
                fiRecord.Credit_Manager__c = null;
            }
        }
        
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        createChecklists((Map<Id, Field_Investigation__c>)newRecordMap);
        updateApplicationFIStatus(null, (Map<Id, Field_Investigation__c>)newRecordMap);// New Code added to archive deviation Records when Retriggered
        checkShareFIRecords (null, (Map<Id, Field_Investigation__c>)newRecordMap);
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        for (Field_Investigation__c each : (List<Field_Investigation__c>) newRecordList) {
            Field_Investigation__c newFI = new Field_Investigation__c(Id = each.Id, FI_Status__c = each.FI_Status__c, OwnerId = each.OwnerId, Loan_Application__c = each.Loan_Application__c,
                Remark__c = each.Remark__c);
            tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(newFI), Object_API_Name__c = 'Field_Investigation__c',
                Event_Date_Time__c = Datetime.now()));
        }
        Eventbus.publish(tatEvents);
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        updateApplicationFIStatus((Map<Id, Field_Investigation__c>)oldRecordMap, (Map<Id, Field_Investigation__c>)newRecordMap);
        updateDeviationsOnRetrigged((Map<Id, Field_Investigation__c>)oldRecordMap, (Map<Id, Field_Investigation__c>)newRecordMap);
        updateDeviationsOnPositiveMarkedFIs((Map<Id, Field_Investigation__c>)oldRecordMap, (Map<Id, Field_Investigation__c>)newRecordMap);
        checkShareFIRecords ((Map<Id, Field_Investigation__c>)oldRecordMap, (Map<Id, Field_Investigation__c>)newRecordMap);
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        for (Field_Investigation__c each : (List<Field_Investigation__c>) newRecordList) {
            Field_Investigation__c oldRecord = (Field_Investigation__c) oldRecordMap.get(each.Id);
            // Adding a new check for FI Agent change
            if (oldRecord.FI_Status__c != each.FI_Status__c || each.OwnerId != oldRecord.OwnerId || oldRecord.FI_Agent__c  != each.FI_Agent__c) {
                Field_Investigation__c newFI = new Field_Investigation__c(Id = each.Id, FI_Status__c = each.FI_Status__c, OwnerId = each.OwnerId, Loan_Application__c = each.Loan_Application__c,
                    Remark__c = each.Remark__c, FI_Agent__c = each.FI_Agent__c);
                Field_Investigation__c oldFI = new Field_Investigation__c(Id = oldRecord.Id, FI_Status__c = oldRecord.FI_Status__c, OwnerId = oldRecord.OwnerId, Loan_Application__c = oldRecord.Loan_Application__c,
                    Remark__c = oldRecord.Remark__c, FI_Agent__c = oldRecord.FI_Agent__c);
                tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(newFI), Object_API_Name__c = 'Field_Investigation__c',
                    Event_Date_Time__c = Datetime.now(), Old_Records_Payload__c = JSON.serialize(oldFI)));
            }
        }
        if (!tatEvents.isEmpty()) {
            Eventbus.publish(tatEvents);
        }
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }
    
    public static void checkShareFIRecords (Map<Id, Field_Investigation__c> oldFIMap, Map<Id, Field_Investigation__c> newFIMap) {
        Map<Id,Id> mapCreditShare = new Map<Id,Id>();
        Map<Id,Id> mapRemoveCreditShare = new Map<Id,Id>();
        
        for (Field_Investigation__c obj: newFIMap.values()){
            system.debug('obj###'+obj);
            if(oldFIMap != NULL && (oldFIMap.get(obj.Id).Credit_Manager__c != obj.Credit_Manager__c)) {
                if (obj.Credit_Manager__c != NULL && obj.Credit_Manager__c != obj.OwnerId)
                    mapCreditShare.put(obj.Id,obj.Credit_Manager__c);
                if (oldFIMap.get(obj.Id).Credit_Manager__c != NULL && oldFIMap.get(obj.Id).Credit_Manager__c != obj.OwnerId)
                    mapRemoveCreditShare.put(obj.Id, oldFIMap.get(obj.Id).Credit_Manager__c);
            }
            if (obj.Credit_Manager__c != obj.OwnerId && obj.Credit_Manager__c!= NULL && !mapCreditShare.containsKey(obj.Id)) {
                mapCreditShare.put(obj.Id,obj.Credit_Manager__c);
            }
        }
        
        if (mapRemoveCreditShare.size()>0) {
            deleteShareFIRecords(mapRemoveCreditShare);
        }
        
        if (mapCreditShare.size()>0) {
            shareFIRecords(mapCreditShare);
        }
    }
    
    public static void shareFIRecords(Map<Id,Id> mapCreditShare) {
        List<Field_Investigation__share> lstFIShare = new List<Field_Investigation__share>();
        for (Id recId : mapCreditShare.keySet()){
            Field_Investigation__share objShare = new Field_Investigation__share();
            objShare.ParentId = recId;
            objShare.UserOrGroupId = mapCreditShare.get(recId);
            objShare.AccessLevel = Label.FI_Credit_Share_Access;
            objShare.RowCause  = Field_Investigation__share.RowCause.FI_Credit_Manager_Share__c;
            lstFIShare.add(objShare);
        }
        if (!lstFIShare.isEmpty()) {
            database.insert(lstFIShare,false);
        }
    }
    
    public static void deleteShareFIRecords(Map<Id,Id> mapRemoveSharing) {
        List<Field_Investigation__share> lstFIShare = new List<Field_Investigation__share>();
        lstFIShare = [Select Id from Field_Investigation__share where parentId in: mapRemoveSharing.keySet() AND UserOrGroupId in: mapRemoveSharing.values()];
        if (!lstFIShare.isEmpty()) {
            //database.delete(lstFIShare,false);
        }
    }
    
    /*
    @ method : updateApplicationFIStatus
    @ description : update FI Status on Loan Application Level
    */
    public static void updateApplicationFIStatus (Map<Id, Field_Investigation__c> oldFIMap, Map<Id, Field_Investigation__c> newFIMap) {
        Set<Id> setApplicationId = new Set<Id>();
        Set<Id> setApplicantId = new Set<Id>();
        Map<String,ProductRTMap__mdt> mapProductRTMapping = ProductRTMap__mdt.getall();
        Set<Id> negativeFIsLoanIds = new Set<Id>();
        for (Field_Investigation__c obj: newFIMap.values()){
            if(oldFIMap != NULL && (oldFIMap.get(obj.Id).Stage__c != obj.Stage__c || oldFIMap.get(obj.Id).FI_Status__c != obj.FI_Status__c))  {
                setApplicationId.add(obj.Loan_Application__c );
                setApplicantId.add(obj.Applicant__c);
                // SFAU-5179 Change added to track if FI is marked negative again.
                if(obj.FI_Status__c == 'Negative'){
                    negativeFIsLoanIds.add(obj.Loan_Application__c);
                }
            }
            else if(oldFIMap == NULL && (String.isNotBlank(obj.Stage__c) || String.isNotBlank(obj.FI_Status__c))) {
                setApplicationId.add(obj.Loan_Application__c );
                setApplicantId.add(obj.Applicant__c);
                // SFAU-5179 Change added to track if FI is marked negative again.
                if(obj.FI_Status__c == 'Negative'){
                    negativeFIsLoanIds.add(obj.Loan_Application__c);
                }
            }
        }
        if (setApplicationId.size()>0){
            Set<Id> setRecordTypeId = new Set<Id>();	
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.APPLICANT));	
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.COAPPLICANT));	
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.GUARANTOR));	
            //String strLAQuery = 'Select id, BRE_Decision__c,Application_FI_Status__c, Stage__c, Product__c FROM Loan_Application__c where Id in: setApplicationId';	
            //List<Loan_Application__c> lstLoanApp = Database.query(strLAQuery);	
            //system.debug(LoggingLevel.DEBUG,'lstLoanApp ' + lstLoanApp);	
            	
            String strQuery = 'SELECT Id, RecordType.Name, Customer_Name__c, IsInactive__c,  Loan__r.Name, Loan__c, Loan__r.BRE_Decision__c, Loan__r.Application_FI_Status__c, Loan__r.Stage__c, Loan__r.Product__c, First_Name__c, Middle_Name__c, Last_Name__c, ';	
            strQuery = strQuery + '(SELECT ';	
            strQuery = strQuery + 'Id,FI_Officer_Name_EMP_code_Agency_Name__c,Waive_Off_Reason__c,FI_Office_Name_Code_Agency_Name_Formula__c,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c ';	
            strQuery = strQuery + 'FROM Field_Investigations__r where Re_Trigger__c = false AND Applicant__r.IsInactive__c = false) ';	
            strQuery = strQuery + 'FROM Applicant__c ';	
            strQuery = strQuery + 'WHERE RecordTypeId in: setRecordTypeId AND Loan__c in: setApplicationId';	
            System.debug('query '+strQuery);	
            List<Applicant__c> lstApplicants = Database.query(strQuery);	
            Map<Id,List<Applicant__c>> mapApplicant = new Map<Id,List<Applicant__c>>();	
            for (Applicant__c objApp : lstApplicants) {	
                List<Applicant__c> lst = new List<Applicant__c>();	
                if (mapApplicant.containsKey(objApp.Loan__c) && objApp.IsInactive__c == false) {	
                    lst = mapApplicant.get(objApp.Loan__c);	
                    lst.add(objApp);	
                }	
                else if (objApp.IsInactive__c == false) {	
                    lst.add(objApp);	
                }
                if (lst.size()>0)	
                    mapApplicant.put(objApp.Loan__c,lst);	
            }
            
            Map<Id,Loan_Application__c> mapUpdateLA = new Map<Id,Loan_Application__c>();
            for (Id loanId  : mapApplicant.keySet()) {
                List<Applicant__c> lstApplicantRecord = mapApplicant.get(loanId);
                String strBeforeAppFIStatus = lstApplicantRecord[0].Loan__r.Application_FI_Status__c;
                Map<String,FiSummaryViewWrapper> mapFISummary = new Map<String,FiSummaryViewWrapper>();
                if (lstApplicantRecord != NULL && lstApplicantRecord.size()>0){
                    mapFISummary = FieldInvestigationUtility.createFISummary (lstApplicantRecord);
                }
                system.debug(LoggingLevel.DEBUG,'mapFISummary ' + mapFISummary);
                if (mapFISummary != NULL && !mapFISummary.isEmpty()) {
                    Loan_Application__c objUpdateLA = new Loan_Application__c();
                    objUpdateLA.Id = lstApplicantRecord[0].Loan__c;
                    if(mapFISummary.containsKey('')){
                        objUpdateLA.Application_FI_Status__c = (mapFISummary.get('').finalStatus == Label.FI_Stage_NA ? '' : mapFISummary.get('').finalStatus);
                    }
                    else{
                        objUpdateLA.Application_FI_Status__c = Label.FI_Stage_NA;
                    }
                    system.debug('test check '+strBeforeAppFIStatus+' '+objUpdateLA.Application_FI_Status__c);
                    // Check Current Loan Application Stage and Move Back WHEN FI STATUS = 'Negative'
                    ProductRTMap__mdt metaProductRTMap = mapProductRTMapping.containsKey('A_'+lstApplicantRecord[0].Loan__r.Product__c) ? mapProductRTMapping.get('A_'+lstApplicantRecord[0].Loan__r.Product__c) : NULL;
                    if ((negativeFIsLoanIds.contains(loanId) || strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c) && objUpdateLA.Application_FI_Status__c == 'Negative' && metaProductRTMap != NULL && metaProductRTMap.RecordType__c == 'Two Wheeler' && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'STP') {
                        objUpdateLA.Stage__c = 'QDE';
                        //SFAU-5261 : Added by Samridhi
                        objUpdateLA.Draft_stage__c = '';
                        objUpdateLA.BRE_ReRun_Required__c = true;
                    }
                    else if ((negativeFIsLoanIds.contains(loanId) || strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c) && objUpdateLA.Application_FI_Status__c == 'Negative' && metaProductRTMap != NULL && metaProductRTMap.RecordType__c == 'Four Wheeler' && lstApplicantRecord[0].Loan__r.Stage__c != 'DDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'STP') {
                        objUpdateLA.Stage__c = 'DDE';
                        //SFAU-5261 : Added by Samridhi
                        objUpdateLA.Draft_stage__c = '';
                        objUpdateLA.BRE_ReRun_Required__c = true;
                    }
                    else if ((negativeFIsLoanIds.contains(loanId) || strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c) && objUpdateLA.Application_FI_Status__c == 'Negative' && (metaProductRTMap.RecordType__c == 'Four Wheeler' || metaProductRTMap.RecordType__c == 'Tractor' || metaProductRTMap.RecordType__c == 'Commercial Vehicle') && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'DDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'Rejected' && lstApplicantRecord[0].Loan__r.Stage__c != 'PDD' && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP') { // CHeck added for Negative Stage 5431 
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                              Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                              Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                              Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                              BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                              Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        //lstLoanApplication[0].Stage__c = 'Credit';
                        //Utility.createBSRAssignment(lstLoanApplication, false);
                        objUpdateLA.Is_Rework__c = false;
                        objUpdateLA.Stage__c = 'Credit';
                    }
                    else if ((negativeFIsLoanIds.contains(loanId) || strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c) && objUpdateLA.Application_FI_Status__c == 'Negative' && metaProductRTMap.RecordType__c == 'Two Wheeler' && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'Rejected' && lstApplicantRecord[0].Loan__r.Stage__c != 'PDD' && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP') {  
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                              Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                              Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                              Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                              BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                              Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        //lstLoanApplication[0].Stage__c = 'Credit';
                        //Utility.createBSRAssignment(lstLoanApplication, false);
                        objUpdateLA.Is_Rework__c = false;
                        objUpdateLA.Stage__c = 'Credit';
                    }
                    else if (strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c && objUpdateLA.Application_FI_Status__c == 'Positive' && (metaProductRTMap.RecordType__c == 'Four Wheeler' || metaProductRTMap.RecordType__c == 'Tractor' || metaProductRTMap.RecordType__c == 'Commercial Vehicle') && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'DDE') { //  && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP'
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                              Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                              Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                              Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                              BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                              Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        lstLoanApplication[0].Stage__c = 'Credit';
                        AUSFLoanApplicationAssignmentHelper.isCalledFromFI = true;
                        Utility.createBSRAssignment(lstLoanApplication, false);
                        //objUpdateLA.Stage__c = 'Credit';
                    }
                    else if (strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c && objUpdateLA.Application_FI_Status__c == 'Positive' && metaProductRTMap.RecordType__c == 'Two Wheeler' && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE') { //  && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP'
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                              Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                              Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                              Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                              BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                              Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        lstLoanApplication[0].Stage__c = 'Credit';
                        AUSFLoanApplicationAssignmentHelper.isCalledFromFI = true;
                        Utility.createBSRAssignment(lstLoanApplication, false);
                        //objUpdateLA.Stage__c = 'Credit';
                    }
                    /*
                    else if (strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c && objUpdateLA.Application_FI_Status__c == 'Positive' && metaProductRTMap.RecordType__c == 'Two Wheeler' && lstApplicantRecord[0].Loan__r.Stage__c != 'QDE' && lstApplicantRecord[0].Loan__r.Stage__c != 'DDE') { //  && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP'
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        lstLoanApplication[0].Stage__c = 'Credit';
                                Utility.createBSRAssignment(lstLoanApplication, false);
                        //objUpdateLA.Stage__c = 'Credit';
                    }

                    else if (strBeforeAppFIStatus != objUpdateLA.Application_FI_Status__c && objUpdateLA.Application_FI_Status__c == 'Positive' && lstApplicantRecord[0].Loan__r.Stage__c != 'CREDIT' && lstApplicantRecord[0].Loan__r.BRE_Decision__c == 'NSTP') {
                        List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                        lstLoanApplication = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                                Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                                Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                                Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, 
                                BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                                Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=: objUpdateLA.Id];
                        lstLoanApplication[0].Stage__c = 'Credit';
                                Utility.createBSRAssignment(lstLoanApplication, false);
                        //objUpdateLA.Stage__c = 'Credit';
                    }
                    */
                    mapUpdateLA.put(objUpdateLA.Id,objUpdateLA);
                    system.debug(LoggingLevel.DEBUG,'objUpdateLA ' + objUpdateLA);
                }
            }
            system.debug(LoggingLevel.DEBUG,'mapUpdateLA ' + mapUpdateLA);
            if (mapUpdateLA != NULL && mapUpdateLA.size() > 0){
                update mapUpdateLa.values();
                //DatabaseUtility.updateRecords(mapUpdateLA.values(), '');
            }
        }
    }
    
    public void createChecklists(Map<Id, Field_Investigation__c> newFIMap) {
        system.debug('checklist>>>');
        RuleEngineHandler getDocChecklists = new RuleEngineHandler();
        Set<String> setFIIds = new Set<String>();
        List<Document_Checklist__c> checklistsToInsert = new List<Document_Checklist__c>();
        
        for (Id each : newFIMap.keySet()) {
            setFIIds.add(String.valueOf(each));
        }
        
        Map<Id, Set<String>> documentMasterIdsByApplicant = getDocumentIds(getDocChecklists.main('Field_Investigation__c', setFIIds, new Set<String>(), 'Document Checklist'));
        Map<String,Document_Master__c> docMasterMap = new Map<String,Document_Master__c>();
        System.debug('***doc Ids: '+documentMasterIdsByApplicant.keySet());
        
        for(Document_Master__c each : [SELECT Id,Name,
                                       Document_Sub_Category__c 
                                       FROM Document_Master__c
                                       WHERE Document_ID__c IN: documentMasterIdsByApplicant.keySet()]){
                                           docMasterMap.put(each.Document_ID__c,each);                                 
                                       }
        for (Id each : documentMasterIdsByApplicant.keySet()) {
            for (String eachMasterId : documentMasterIdsByApplicant.get(each)) {
                Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) : 
                new Document_Master__c(); 
                checklistsToInsert.add(new Document_Checklist__c
                                       (Field_Investigation__c = each, 
                                        Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                        Category__c = currentRec.Document_Sub_Category__c,
                                        Sub_Category__c = currentRec.Name
                                       )
                                      );
            }
        }
        
        if(Schema.sObjectType.Document_Checklist__c.isCreateable()) {
            insert checklistsToInsert;
        }       
    }
    
    
    private Map<Id, Set<String>> getDocumentIds(String breJSONString) {
        Map<Id, Set<String>> returnValue = new Map<Id, Set<String>>();
        Map<String, Object> applicantChecklists = (Map<String, Object>) JSON.deserializeUntyped(breJSONString);
        Map<String, Object> checklists = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if(checklists != null){
            for (String each : checklists.keySet()) {
                Set<String> masterIds = new Set<String>();
                List<Object> checklistsOfApp = (List<Object>) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject : checklistsOfApp) {
                    Map<String, Object> objProperties = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }
    
    
    /*
    @ method : updateDeviationsOnRetrigged
    @ description : Archived Deviation Record
    */
    
    private static void updateDeviationsOnRetrigged(Map<Id, Field_Investigation__c> oldFIRecordMap, Map<Id, Field_Investigation__c> newFIRecordMap){
        List<Deviation__c> deviationsRecords = new List<Deviation__c>();
        Map<String, String> fiApplicantKey_IdMap = new Map<String, String>();
        Set<Id> fiLoanIds = new Set<Id>();
        for(Id fiId : newFIRecordMap.keySet()){
            if((oldFIRecordMap.get(fiId).Stage__c != newFIRecordMap.get(fiId).Stage__c ) && (newFIRecordMap.get(fiId).FI_Profile_Status__c == 'Positive' || newFIRecordMap.get(fiId).FI_Status__c  == 'Positive')){
                fiApplicantKey_IdMap.put(newFIRecordMap.get(fiId).Applicant__c +'-'+newFIRecordMap.get(fiId).Type_of_address__c, fiId);
                fiLoanIds.add(newFIRecordMap.get(fiId).Loan_Application__c);
            }
        }
        Set<Id> toBeArchivedDevRecordsFiIds = new Set<Id>();
        
        if(!fiApplicantKey_IdMap.isEMpty()){
            List<Field_Investigation__c> retrigerredFIRelatedToLoans = [SELECT Id, Applicant__c, Type_of_address__c, Re_Trigger__c, Loan_Application__c  
                                                                        FROM Field_Investigation__c WHERE Loan_Application__c IN:fiLoanIds AND Re_Trigger__c=true AND
                                                                       	(FI_Profile_Status__c = 'Negative' OR FI_Status__c = 'Negative')
                                                                       ];
            if(!retrigerredFIRelatedToLoans.iseMpty()){
                for(Field_Investigation__c firecord : retrigerredFIRelatedToLoans){
                    String key = firecord.Applicant__c+'-'+firecord.Type_of_address__c;
                    if(fiApplicantKey_IdMap.containsKey(key)){
                        toBeArchivedDevRecordsFiIds.add(firecord.Id);
                    }
                }
                if(!toBeArchivedDevRecordsFiIds.isEmpty()){
                    deviationsRecords = [SELECT Id, Archived__c, Field_Investigation__c FROM Deviation__c WHERE Field_Investigation__c IN:toBeArchivedDevRecordsFiIds];
                    if(!deviationsRecords.isEMpty()){
                        for(Deviation__c devRecord : deviationsRecords){
                            devRecord.Archived__c = true;
                        }
                        update deviationsRecords;
                    }
                }
            }
                
        }
        
        
    }
    
    /* 4789 Changes- Yash 11 Dec
    @ method : updateDeviationsOnPositiveMarkedFIs
    @ description : Archived Deviation Record when marked positive
    */

    public static void updateDeviationsOnPositiveMarkedFIs(Map<Id, Field_Investigation__c> oldFIRecordMap, Map<Id, Field_Investigation__c> newFIRecordMap){
        Set<Id> fiIds = new Set<Id>();
        for(Id fiId : newFIRecordMap.keySet()){
            if((oldFIRecordMap.get(fiId).Stage__c != newFIRecordMap.get(fiId).Stage__c ) && (newFIRecordMap.get(fiId).FI_Profile_Status__c == 'Positive' || newFIRecordMap.get(fiId).FI_Status__c  == 'Positive')){
                fiIds.add(fiId);
            }
        }
        if(!fiIds.isEmpty()){
            List<Deviation__c> devRecords = [SELECT Id, Archived__c, Field_Investigation__c
                                             FROM Deviation__c WHERE Field_Investigation__c IN:fiIds AND Archived__c= false];
            if(!devRecords.isEmpty()){
                for(Deviation__c devRecord : devRecords){
                    devRecord.Archived__c = true;
                }
                update devRecords;
            }
        }
    }
    
}