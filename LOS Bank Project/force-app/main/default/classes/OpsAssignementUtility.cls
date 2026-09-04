/**
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Mohit M.                05-Oct-2023     SFAU-5335  
 * Yash S				   04-Dec-2023.    SFAU-5547
 */
public without sharing class OpsAssignementUtility {
    public static boolean boolIsCreateROShare = false;
    public static boolean boolIsSendBackCase = false;
    public static String strCaseTypetoConsider;
    
    @AuraEnabled
    public static void doOpsAssignmentAction(Loan_Application__c objLoanApplication, String strAssignmentType, String strStage, String strCaseType){
        strCaseTypetoConsider = strCaseType;
        system.debug('%% '+strCaseTypetoConsider);
        doOpsAssignment(objLoanApplication, strAssignmentType, strStage);
    }
    
    
    @AuraEnabled
    public static void doOpsAssignment(Loan_Application__c objLoanApplication, String strAssignmentType, String strStage){
        try{
            Boolean boolisKYCPickedUp = false;
            Boolean boolNoKYCRecord = false;
            List<Assignment__c> lstLoanAssignment = new List<Assignment__c>();
            Assignment__c objLoanAssignment = new Assignment__c();
            Loan_Application__c objLoanApp = [Select Id,OwnerId,Application_Id__c,Disbursement_Category__c, Product__c,RecordType.Name, Stage__c, 
                                                    Branch_Master__r.X4WH_Used_COW_Disbursement_Author_Queue__c, 
                                                    Branch_Master__r.Commercial_New_Disbursement_Author_Queue__c, 
                                                    Branch_Master__r.Commercial_Used_COW_Disburse_Auth_Queue__c, Branch_Master__r.Tractor_New_Disbursement_Author_Queue__c, Branch_Master__r.Tractor_Used_COW_Disburse_Author_Queue__c, 
                                                    Branch_Master__r.PDD_Maker_Queue_All_Products__c, Branch_Master__r.PDD_Author_Queue_All_Products__c,  
                                                    Branch_Master__r.KYC_All_Products__c, Branch_Master__r.X4WH_New_Disbursement_Author_Queue__c, Branch_Master__r.TW_Disbursement_Author_Queue__c, 
                                                    Branch_Master__r.Commercial_Used_COW_Disburse_Maker_Queue__c, Branch_Master__r.Commercial_New_Disbursement_Maker_Queue__c, Branch_Master__r.Tractor_Used_COW_Disburse_Maker_Queue__c, 
                                                    Branch_Master__r.Tractor_New_Disbursement_Maker_Queue__c, Branch_Master__r.X4WH_Used_COW_Disbursement_Maker_Queue__c, Branch_Master__r.X4WH_New_Disbursement_Maker_Queue__c, 
                                                    Branch_Master__r.TW_Disbursement_Maker_Queue__c from Loan_Application__c 
                                                    where Id =:objLoanApplication.Id WITH SECURITY_ENFORCED limit 1];
                                                    
            ProductRTMap__mdt objProductRTMap = ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+objLoanApp.Product__c);
            if(strAssignmentType == 'Ops - KYC' && (objLoanApp.Stage__c == 'Ops Maker' || objLoanApp.Stage__c == 'Ops Author' || objLoanApp.Stage__c == 'Partially Disbursed')){
                strAssignmentType = 'Ops - Disbursement';    
                objLoanAssignment.Ops_Submission_Date__c = DateTime.now();   
            }
            
            if(strAssignmentType == 'Ops - PDD'){
                List<Assignment__c> lstPDDAssignment = [Select Id,Recordtype.Name,Loan_Application__c,Status__c,OwnerId, Ops_Submission_Date__c from Assignment__c 
                                            where Recordtype.Name = 'Ops - PDD' AND Status__c = 'Pending' AND Loan_Application__c =:objLoanApplication.Id 
                                            WITH SECURITY_ENFORCED limit 1];
                if(!lstPDDAssignment.isEmpty()){ //&& String.valueof(lstPDDAssignment[0].OwnerId).startsWith('005')
                    objLoanAssignment.Id = lstPDDAssignment[0].Id;
                    objLoanAssignment.Ops_Submission_Date__c = DateTime.now(); // Ops Submission Date Change
                }
                else{
                    objLoanAssignment = new Assignment__c();
                }
            }
            else{
                if(strAssignmentType == 'Ops - Disbursement' || strAssignmentType == 'Ops - KYC' || strAssignmentType == 'Ops - PDD'){
                    List<Assignment__c> lstKYCAssignment = [Select Id,Recordtype.Name,Loan_Application__c,Status__c,OwnerId, Ops_Submission_Date__c from Assignment__c 
                                                where Recordtype.Name = 'Ops - KYC' AND Status__c = 'Pending' AND Loan_Application__c =:objLoanApplication.Id 
                                                WITH SECURITY_ENFORCED limit 1];
                    if(!lstKYCAssignment.isEmpty() && String.valueof(lstKYCAssignment[0].OwnerId).startsWith('005') && strAssignmentType == 'Ops - Disbursement'){
                        boolisKYCPickedUp = true;
                        //objLoanAssignment.Id = lstKYCAssignment[0].Id;
                        //objLoanAssignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId();
                        //lstLoanAssignment.add(objLoanAssignment);
                        objLoanAssignment = new Assignment__c();
                    }
                    else if(!lstKYCAssignment.isEmpty() && String.valueof(lstKYCAssignment[0].OwnerId).startsWith('005') && strAssignmentType == 'Ops - KYC'){
                        objLoanAssignment.Id = lstKYCAssignment[0].Id;
                        //boolisKYCPickedUp = true;
                    }
                    else if(!lstKYCAssignment.isEmpty() && String.valueof(lstKYCAssignment[0].OwnerId).startsWith('00G')){
                        objLoanAssignment.Id = lstKYCAssignment[0].Id;
                        objLoanAssignment.Ops_Submission_Date__c = DateTime.now(); 
                    }
                    else{
                        boolNoKYCRecord = true;
                    }
                    
                    if((boolisKYCPickedUp && strAssignmentType == 'Ops - Disbursement') || boolNoKYCRecord){
                        List<Assignment__c> lstDisbAssignment = [Select Id,Recordtype.Name,Loan_Application__c,Status__c, Ops_Submission_Date__c from Assignment__c 
                                            where Recordtype.Name = 'Ops - Disbursement' AND Status__c = 'Pending' 
                                            AND Loan_Application__c =:objLoanApp.Id WITH SECURITY_ENFORCED limit 1];
                        if(!lstDisbAssignment.isEmpty()){
                            objLoanAssignment.Id = lstDisbAssignment[0].Id;
                            objLoanAssignment.Ops_Submission_Date__c = DateTime.now(); 
                            //objLoanAssignment.Ops_Submission_Date__c = (lstDisbAssignment[0].Ops_Submission_Date__c!=null)?lstDisbAssignment[0].Ops_Submission_Date__c:null;// First Time Submission date check
                            system.debug('%% '+strCaseTypetoConsider);
                            if(strCaseTypetoConsider != 'SendBack' && strCaseTypetoConsider != 'SubmitToAuthor'){
                                objLoanAssignment.Is_ReWork__c = true;
                            }
                        }
                    }
                }
            }
            
            if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.Disbursement_Category__c == 'Partial'){
                List<Payment__c> tranche = [select id, name, Inactive__c, Disbursed__c, Tranche_Status__c,Disbursement_Amount__c, 
                                    Partial_Payment_Condition__c, Tranche_Number__c from Payment__c where  RecordType.Developername='Tranche' 
                                    and Inactive__c = false and Disbursed__c = false and loan_application__c=:objLoanApp.Id WITH SECURITY_ENFORCED order by Tranche_Number__c asc];
                if(!tranche.isEmpty()){
                    objLoanAssignment.Tranche_Number__c = tranche[0].Tranche_Number__c;
                }
                objLoanAssignment.Disbursement_Type__c = 'Partial';
            }
            else{
                objLoanAssignment.Disbursement_Type__c = 'Full';
            }
            
            //objLoanAssignment = checkExistingAssignment(objLoanAssignment, strAssignmentType, objLoanApp.Id);
            if(strStage == 'Ops Maker' || strStage == 'Ops Author'){
                objLoanAssignment.Ops_Stage__c = strStage;
            }
            /*New Check added for First Time date Submission*/
            if(strStage == 'Ops Maker' && objLoanAssignment.Ops_Submission_Date__c==null && strAssignmentType == 'Ops - Disbursement'){
                objLoanAssignment.Ops_Submission_Date__c = DateTime.now();
            }
            /********************************************* */
            objLoanAssignment.Status__c = 'Pending';
            objLoanAssignment.Loan_Application__c = objLoanApp.Id;
            objLoanAssignment.Name = objLoanApp.Application_Id__c;
            objLoanAssignment.Product__c = objProductRTMap.Label;
            objLoanAssignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get(strAssignmentType).getRecordTypeId();
            //objLoanAssignment.Sub_Status__c = (objLoanAssignment.Is_ReWork__c)?'In Progress':'';
            //if(!objLoanAssignment.Is_ReWork__c){// Commenting this Line as Rework case also we will assign back to Queue SFAU-5547
            //system.debug('%%% objLoanAssignment.Is_ReWork__c');
                objLoanAssignment.OwnerId = assignOwnerId(strAssignmentType, objLoanApp, objProductRTMap, strStage);
            if(objLoanAssignment.Is_ReWork__c){
                objLoanAssignment.Sub_Status__c = 'In Progress';
            }
            //}
            //if(!boolisKYCPickedUp){
                lstLoanAssignment.add(objLoanAssignment);
            //}
            if(!lstLoanAssignment.isEmpty()){
                boolIsCreateROShare = true;
                //DatabaseUtility.upsertRecords(lstLoanAssignment, '');
                upsert lstLoanAssignment;
            }
            if(boolIsCreateROShare){
                system.debug('%%% objLoanAssignment.Is_ReWork__c'+boolIsCreateROShare);
                List<Assignment__Share> sharedApplicationRecords = new List<Assignment__Share>();
                Assignment__Share sharedRecord = new Assignment__Share();
                sharedRecord.AccessLevel = 'edit';
                sharedRecord.ParentId = lstLoanAssignment[0].Id;//[Select Id,RecordType.Name from Assignment__c where Loan_Application__c=:objLoanApp.Id AND RecordType.Name = 'Ops - KYC' limit 1].Id;
                sharedRecord.UserOrGroupId = objLoanApp.OwnerId;
                sharedRecord.RowCause = Schema.Assignment__Share.RowCause.Share_to_RO__c;
                sharedApplicationRecords.add(sharedRecord);
                if(!sharedApplicationRecords.isEmpty()) {
                    //SFAU-5335
                    Database.insert(sharedApplicationRecords,false);
                }
            }

            
            
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
    }
    /*
    public static Assignment__c checkExistingAssignment(Assignment__c objAssignment, String strAssignmentType, String strLoanId){
        try{
            if(strAssignmentType == 'Ops - Disbursement' || strAssignmentType == 'Ops - KYC'){
                Assignment__c objKYCAssignment = [Select Id,Recordtype.Name,Loan_Application__c,Status__c,OwnerId from Assignment__c 
                                            where Recordtype.Name = 'Ops - KYC' AND Status__c = 'In Progress' AND Loan_Application__c =:strLoanId limit 1];
                if(objKYCAssignment != null && String.valueof(objKYCAssignment.OwnerId).startsWith('005')){
                    objAssignment.Id = objKYCAssignment.Id;
                }
                else if(objKYCAssignment != null && String.valueof(objKYCAssignment.OwnerId).startsWith('00G')){
                    objAssignment.Id = objKYCAssignment.Id;
                }
                
                if(objKYCAssignment == null && strAssignmentType == 'Ops - Disbursement'){
                    Assignment__c objDisbAssignment = [Select Id,Recordtype.Name,Loan_Application__c,Status__c from Assignment__c where Recordtype.Name = 'Ops - Disbursement' 
                                            AND Status__c = 'In Progress' AND Loan_Application__c =:strLoanId limit 1];
                    if(objDisbAssignment != null){
                        objAssignment.Id = objKYCAssignment.Id;
                    }
                }
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        return objAssignment;
    }
    */
    
    
    public static String assignOwnerId(String strAssignmentType, Loan_Application__c objLoanApp, ProductRTMap__mdt objProductRTMap, String strStage){
        String strOwnerId;
        List<String> products = Label.COW_Product_Names.split(',');
        Set<String> cowProducts = new Set<String>(products);//5584
        if(strAssignmentType == 'Ops - KYC'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.KYC_All_Products__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Four Wheeler' 
            && strStage == 'Ops Maker' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.X4WH_New_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Four Wheeler' 
            && strStage == 'Ops Maker' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.X4WH_Used_COW_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Four Wheeler' 
            && strStage == 'Ops Author' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.X4WH_New_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Four Wheeler' 
            && strStage == 'Ops Author' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.X4WH_Used_COW_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Two Wheeler' 
            && strStage == 'Ops Maker'  && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.TW_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Two Wheeler' 
            && strStage == 'Ops Maker' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.TW_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Two Wheeler' 
            && strStage == 'Ops Author' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.TW_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Two Wheeler' 
            && strStage == 'Ops Author' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.TW_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Tractor' 
            && strStage == 'Ops Maker' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Tractor_New_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Tractor' 
            && strStage == 'Ops Maker' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Tractor_Used_COW_Disburse_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Tractor' 
            && strStage == 'Ops Author' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Tractor_New_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && objLoanApp.RecordType.Name == 'Tractor' 
            && strStage == 'Ops Author' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Tractor_Used_COW_Disburse_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && (objLoanApp.RecordType.Name == 'Commercial Vehicle' || objLoanApp.RecordType.Name == 'Construction Equipment' ) 
            && strStage == 'Ops Maker' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Commercial_New_Disbursement_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && (objLoanApp.RecordType.Name == 'Commercial Vehicle' || objLoanApp.RecordType.Name == 'Construction Equipment') 
            && strStage == 'Ops Maker' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c)) ){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Commercial_Used_COW_Disburse_Maker_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && (objLoanApp.RecordType.Name == 'Commercial Vehicle' || objLoanApp.RecordType.Name == 'Construction Equipment') 
            && strStage == 'Ops Author' && objProductRTMap.Sub_Product__c == 'New'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Commercial_New_Disbursement_Author_Queue__c);
        }
        else if(strAssignmentType == 'Ops - Disbursement' && (objLoanApp.RecordType.Name == 'Commercial Vehicle' || objLoanApp.RecordType.Name == 'Construction Equipment') 
            && strStage == 'Ops Author' && (objProductRTMap.Sub_Product__c == 'Used' || objProductRTMap.Sub_Product__c == 'Cash on Wheels' || cowProducts.contains(objProductRTMap.Sub_Product__c))){ // SFAU-5584
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.Commercial_Used_COW_Disburse_Auth_Queue__c);
        }
        else if(strAssignmentType == 'Ops - PDD' && strStage == 'Ops Maker'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.PDD_Maker_Queue_All_Products__c);
        } 
        else if(strAssignmentType == 'Ops - PDD' && strStage == 'Ops Author'){
            strOwnerId = getAssignedQueueId(objLoanApp.Branch_Master__r.PDD_Author_Queue_All_Products__c);
        } 
        else if(strAssignmentType == 'Credit - BSR/ PSL'){
            //objLoanAssignment.OwnerId = 
        }
        return strOwnerId;
    }
    
    public static string getAssignedQueueId(String strQueueName){
        try{
            List<QueueSobject> lstQueueSobject = [SELECT Id, QueueId, Queue.Name, SobjectType, CreatedById FROM QueueSobject 
                                    where Queue.Name = :strQueueName and SobjectType = 'Assignment__c' WITH SECURITY_ENFORCED Limit 1];
            
            if(!lstQueueSobject.isEmpty()){
                return lstQueueSobject[0].QueueId;
            }
            else{
                return null;
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            return null;
        }
    }

    @AuraEnabled
    public static void updateAssignmentPendingStatus(String assignmentId){
        Assignment__c assignmentRecord = new Assignment__c();
        assignmentRecord.Id = assignmentId;
        assignmentRecord.Sub_Status__c = 'Pending';
        Database.update(assignmentRecord);
    }
    
    @AuraEnabled
    public static void markAssignmentComplete(Assignment__c objAssignment){
        List<Assignment__c> lstLoanAssignment = new List<Assignment__c>();
        objAssignment.Status__c = 'Complete';
        lstLoanAssignment.add(objAssignment);
        DatabaseUtility.upsertRecords(lstLoanAssignment, '');
    }
    
    public static void submittoOpsAuthor(Assignment__c objAssignment){
        List<Assignment__c> lstLoanAssignment = new List<Assignment__c>();
        objAssignment.Ops_Stage__c = 'Ops Author';
        lstLoanAssignment.add(objAssignment);
        DatabaseUtility.upsertRecords(lstLoanAssignment, '');
    }
    
    @AuraEnabled
    public static Boolean updateAssignmentOwner(String strAssignmentId){
        Boolean boolisOwnerAssigned;
        try{
            Boolean boolCreateShareRecord;
            List<Assignment__c> lstLoanAssignment = new List<Assignment__c>();
            List<Assignment__c> objAssignment = [Select Id,OwnerId,Loan_Application__c from Assignment__c where Id = :strAssignmentId 
                                            WITH SECURITY_ENFORCED limit 1 FOR UPDATE];

            if(!objAssignment.isEmpty()){
                objAssignment[0].Ops_Submission_Date__c = DateTime.now();
                if(String.valueof(objAssignment[0].OwnerId).startsWith('00G')){
                    objAssignment[0].OwnerId = UserInfo.getUserId();
                    objAssignment[0].Sub_Status__c = 'In Progress';
                    boolCreateShareRecord = true;
                    boolisOwnerAssigned = true;
                }
                else{
                    boolisOwnerAssigned = false;
                }
                lstLoanAssignment.add(objAssignment[0]);
                DatabaseUtility.updateRecords(lstLoanAssignment, '');
                if(boolCreateShareRecord){
                    List<Loan_Application__Share> sharedApplicationRecords = new List<Loan_Application__Share>();
                    Loan_Application__Share sharedRecord = new Loan_Application__Share();
                    sharedRecord.AccessLevel = 'edit';
                    sharedRecord.ParentId = objAssignment[0].Loan_Application__c;
                    sharedRecord.UserOrGroupId = UserInfo.getUserId();
                    //sharedRecord.RowCause = Schema.Loan_Application__Share.RowCause.Sharing_To_Approver__c;
                    sharedApplicationRecords.add(sharedRecord);
                    if(!sharedApplicationRecords.isEmpty()) {
                        //SFAU-5335
                        Database.insert(sharedApplicationRecords,false);
                    }
                }
            }
        }
        catch (QueryException e) {
            boolisOwnerAssigned = false;
        }
        catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            boolisOwnerAssigned = false;
        }
        return boolisOwnerAssigned;
        
        /*List<Assignment__c> lstLoanAssignment = new List<Assignment__c>();
        objAssignment.Ops_Stage__c = 'Author';
        lstLoanAssignment.add(objAssignment);
        DatabaseUtility.upsertRecords(lstLoanAssignment, '');*/
    }
}