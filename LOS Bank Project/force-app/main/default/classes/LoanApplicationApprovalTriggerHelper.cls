/*****
 * Class Name: LoanApplicationApprovalTriggerHelper
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-18-2023          -   Mohit M.            -   SFAU-5179 change sharing control due to FI Agent getting error
 * Sep-28-2023          -   Sachin              -   SFAU-5131 Added Loan_details__c on Approval record
 */
public without sharing class LoanApplicationApprovalTriggerHelper {

    public static map<Id, String> loanApplicationStageMap = new map<Id, String>(); 
    public static map<String, Integer> APPROVERS_PREFERENCES = new map<String, Integer>{
        null => 0,
        'Base' => 1,
        'Middle' => 2,
        'Highest' => 3
    };

    static map<String, String> productToLtvFieldMapping = new map<String, String>{
        GlobalConstants.FOURWHEELER => AUSFVehicleController.LTV_ON_ROAD_FIELD_API,
        GlobalConstants.TWOWHEELER => AUSFVehicleController.LTV_ON_ROAD_FIELD_API,
        GlobalConstants.COMMERCIALVEHICLE => AUSFVehicleController.LTV_ON_ROAD_FIELD_API,
        GlobalConstants.CONSTRUCTIONEQUIP => AUSFVehicleController.LTV_ON_ROAD_FIELD_API,
        GlobalConstants.TRACTOR => AUSFVehicleController.LTV_OFFERED_FIELD_API
    };

    public static void updateBaseApprover(map<String, Loan_Application_Approval__c[]> applicationToApprovals){
        String loanId ='';
        for(Id applicationId: applicationToApprovals.keySet()){
            map<Integer, Loan_Application_Approval__c> approversOrderMap = new map<Integer, Loan_Application_Approval__c>();
            Integer[] approversOrder = new Integer[0];
            Loan_Application_Approval__c[] approvals = applicationToApprovals.get(applicationId);
            for(Integer i = 0; i < approvals.size(); i++){
                Loan_Application_Approval__c approval = approvals[i];
                Integer preference = APPROVERS_PREFERENCES.get(approval.Type__c) != null ? APPROVERS_PREFERENCES.get(approval.Type__c) : 0;

                approversOrder.add(preference);
                approversOrderMap.put(preference, approval);
            }

            approversOrder.sort();
            Loan_Application_Approval__c baseApproval = approversOrderMap.get(approversOrder[0]);
            baseApproval.Is_Assigned_Approver__c = true;
            // baseApproval.Approval_Status__c = 'Pending';
            System.debug(' === Base Approval ==> ' +JSON.serializePretty(baseApproval));
        }
        // for(loan_Application_Approval__c appr:listToUpdate){
        //         loanId = String.isNotBlank(appr.Loan_Application__c) ? appr.Loan_Application__c : '';
        //         appr.Is_Assigned_Approver__c = true;
        //         appr.Approval_Status__c ='Pending';
        //         system.debug('appr '+appr);
        //         //Call the Notification Handler
        //         //NotificationHandler.sendNotification('Credit Submission(L0)',loanId,appr.Approver__c);
        // }
         
    }
    
    public static void populateAdditionalFieldsFromLoanApp(Loan_Application_Approval__c[] approvals){
        map<Id, map<String, Object>> loanIdDetails = new map<Id, map<String, Object>>();
        for(Loan_Application_Approval__c approval: approvals){
            loanIdDetails.put(approval.Loan_Application__c, new map<String, Object>());
        }

        for(Loan_Application__c loanApplication: [
            SELECT Id, Name, toLabel(Product__c), Loan_Amount__c, Tenure__c, ROI__c, RecordType.Name,
                ( SELECT MMV_Master__r.Make__r.Name, LTV_offered_On_road__c, LTV_offered__c FROM Collaterals__r WHERE MMV_Master__c != NULL AND RecordTypeId IN: GlobalConstants.colRecordTypeIds AND Is_Deleted__c = false  ORDER BY CreatedDate DESC LIMIT 1 ),
                ( SELECT Id FROM Applicants__r WHERE RecordType.Name =: GlobalConstants.APPLICANT LIMIT 1 )
            FROM Loan_Application__c
            WHERE Id IN: loanIdDetails.keySet() ]
        ){
            String applicableLtvField = productToLtvFieldMapping.get( loanApplication.RecordType.Name ),
                evaluatedLtv = applicableLtvField != null && !loanApplication.Collaterals__r.isEmpty() && loanApplication.Collaterals__r[0].get( applicableLtvField ) != null ? ' / ' + loanApplication.Collaterals__r[0].get( applicableLtvField ) + ' % ' : '';
            loanIdDetails.get( loanApplication.Id ).putAll(
                new map<String, Object>{
                    'Product__c' => loanApplication.Product__c,
                    'Loan_Application_Number__c' => loanApplication.Name,
                    'Vehicle_MFG__c' => !loanApplication.Collaterals__r.isEmpty() ? loanApplication.Collaterals__r[0].MMV_Master__r.Make__r.Name : null,
                    'Applicant__c' => !loanApplication.Applicants__r.isEmpty() ? loanApplication.Applicants__r[0].Id : null,
                    'Loan_details__c' => loanApplication.Loan_Amount__c?.setScale(0) + ' / ' + ( loanApplication.Tenure__c != null ? loanApplication.Tenure__c : 0 ) + ' months / '  + loanApplication.ROI__c + ' % ' + evaluatedLtv//SFAU-5131
                }
            );
        }

        populateValuesFromApplication(approvals, loanIdDetails);
    }
    

    public static void shareLoanApplicationWithApprover(List<Loan_Application_Approval__c> newLoanApprList) {
        System.debug(' === newLoanApprList ==> ' + JSON.serializePretty(newLoanApprList));
        List<Loan_Application__Share> loanAppShareList = new List<Loan_Application__Share>();
        Id twoWheelerRecordType = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        X2W_Approval_Assignem_Switch__mdt  sw =X2W_Approval_Assignem_Switch__mdt.getInstance('Queue_Based_Assignment');
        system.debug('sw '+sw);
        for(loan_Application_Approval__c curreObj:newLoanApprList){
            Loan_Application__Share shareObj = new Loan_Application__Share();
            shareObj.parentId = curreObj.Loan_Application__c;

            if( curreObj.Approver__c == null ){
                shareObj.AccessLevel = 'Read';
                shareObj.UserOrGroupId = sw.PublicGroupId__c;
            } else {
                shareObj.AccessLevel = 'Edit';
                shareObj.UserOrGroupId = curreObj.Approver__c;  
            }
            shareObj.RowCause = Schema.Loan_Application__Share.RowCause.Sharing_To_Approver__c;
            loanAppShareList.add(shareObj);
        }
        System.debug(' === loanAppShareList ==> ' + JSON.serializePretty(loanAppShareList));
        if(loanAppShareList.size()>0 && !loanAppShareList.isEmpty()){
            Database.insert(loanAppShareList,false);
        }
        
        System.debug(' === loanAppShareList After ==> ' + JSON.serializePretty(loanAppShareList));
    }
    
    public static void updateLoanApplications(Set<String> newListOfIds,String approvalStatus,String Stage,String approvalType){
        List<Loan_Application__c> updateLoanApplications = new List<Loan_Application__c>();
        if(newListOfIds.size()>0){
            // Changes as per SFAU-3335 - Change Query where Clause to avoid record Lock Issue from BRE - Mohit
            for(Loan_Application__c loanApp:[SELECT Id,Approval_Status__c, Remarks__c, (SELECT ID,Approval_Status__c, Remarks__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c =: GlobalConstants.PENDING AND Approval_Type__c=: approvalType AND Archived__c = FALSE) FROM Loan_Application__c WHERE Id In :newListOfIds WITH SECURITY_ENFORCED]){
                system.debug(LoggingLevel.Info,'loanApp ___ ' +  loanApp);
                List<Loan_Application_Approval__c> loanApprovals = new List<Loan_Application_Approval__c>();
                loanApprovals = loanApp.Loan_Application_Approvers__r;
                if(loanApprovals.size()==0){
                    loanApp.Approval_Status__c =approvalStatus;
                    loanApp.Stage__c = Stage;
                    if(approvalStatus =='Credit Approved'){
                       loanApp.Credit_Approval_Date__c = Date.today();
                       loanApp.Remarks__c = 'Credit Approved Check';
                    }
                    if(approvalStatus =='Pricing Approved'){
                        loanApp.Pricing_Approval_Date__c = Date.today();
                        loanApp.Remarks__c = 'Pricing Approved Check New';
                    }
                    updateLoanApplications.add(loanApp);
                }
            }
            
            if(updateLoanApplications.size()>0){
                update updateLoanApplications;
            }
        }
    }
    
    /*Method overloaded to handle the Remarks Stamping back on the Loan Record*/
    public static void updateLoanApplications(Set<String> newListOfIds,String approvalStatus,String Stage,String approvalType, Map<String,String> approvedRecordsRemarks){
        List<Loan_Application__c> updateLoanApplications = new List<Loan_Application__c>();
        if(newListOfIds.size()>0){
            // Changes as per SFAU-3335 - Change Query where Clause to avoid record Lock Issue from BRE - Mohit
            for(Loan_Application__c loanApp:[SELECT Id,Approval_Status__c, Remarks__c, (SELECT ID,Approval_Status__c, Remarks__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c =: GlobalConstants.PENDING AND Approval_Type__c=: approvalType AND Archived__c = FALSE) FROM Loan_Application__c WHERE Id In :newListOfIds WITH SECURITY_ENFORCED]){
                system.debug(LoggingLevel.Info,'loanApp ___ ' +  loanApp);
                List<Loan_Application_Approval__c> loanApprovals = new List<Loan_Application_Approval__c>();
                loanApprovals = loanApp.Loan_Application_Approvers__r;
                if(loanApprovals.size()==0){
                    loanApp.Approval_Status__c =approvalStatus;
                    loanApp.Stage__c = Stage;
                    if(approvalStatus =='Credit Approved'){
                        loanApp.Credit_Approval_Date__c = Date.today();
                        loanApp.Remarks__c = (approvedRecordsRemarks.containsKey(loanApp.Id))? approvedRecordsRemarks.get(loanApp.Id):'Credit Approved';
                    }
                    if(approvalStatus =='Pricing Approved'){
                        loanApp.Pricing_Approval_Date__c = Date.today();
                        
                        loanApp.Remarks__c = (approvedRecordsRemarks.containsKey(loanApp.Id))? approvedRecordsRemarks.get(loanApp.Id):'Pricing Approved';
                    }
                }
                System.debug('Test Yash '+loanApp);
                updateLoanApplications.add(loanApp);
            }
        }
        
        if(updateLoanApplications.size()>0){
            update updateLoanApplications;
        }
    }

    
    public static void rejectLoanApplications(Set<String> newListOfIds){
        List<Loan_Application__c> updateLoanApplications = new List<Loan_Application__c>();
        if(newListOfIds.size()>0){
            Map<String,String> mapOfLoanIdVsApplicantCaste = new Map<String,String>();
            mapOfLoanIdVsApplicantCaste = getMapLoanIdVsApplicantCaste(newListOfIds);
            System.debug(' == Id To Caste ==> ' + JSON.serializePretty(mapOfLoanIdVsApplicantCaste));
            for(Loan_Application__c loanApp:[SELECT Id,Approval_Status__c,(SELECT ID,Approval_Status__c FROM Loan_Application_Approvers__r WHERE Approval_Status__c = 'Pending' AND Approval_Type__c='Credit' AND Archived__c = FALSE ) FROM Loan_Application__c WHERE Id In :newListOfIds WITH SECURITY_ENFORCED]){
                System.debug(' == Loan Application ==> ' + JSON.serializePretty(loanApp));
                System.debug(' == Approvals ==> ' + loanApp.Loan_Application_Approvers__r.size());
                List<Loan_Application_Approval__c> loanApprovals = new List<Loan_Application_Approval__c>();
                loanApprovals = loanApp.Loan_Application_Approvers__r;
                if(mapOfLoanIdVsApplicantCaste.containsKey(loanApp.Id) && (mapOfLoanIdVsApplicantCaste.get(loanApp.Id)=='SC' || mapOfLoanIdVsApplicantCaste.get(loanApp.Id)=='ST' ) && loanApprovals.size() > 1){
                    loanApp.Approval_Status__c ='Credit Rejected';
                    updateLoanApplications.add(loanApp);
                }else if(loanApprovals.isEmpty() || loanApprovals.size() == 1){
                    loanApp.Stage__c = GlobalConstants.REJECTED;
                    loanApplicationStageMap.put(loanApp.Id, GlobalConstants.REJECTED);
                    loanApp.Approval_Status__c ='Credit Rejected';
                    updateLoanApplications.add(loanApp);
                }
            }
            
            if(updateLoanApplications.size()>0){
                // update updateLoanApplications;
            }
        }
    }
    
    public static Map<String,String> getMapLoanIdVsApplicantCaste(Set<String> newListOfIds){
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Map<String,String> mapOfLoanIdVsApplicantCaste = new Map<String,String>();
        for(Applicant__c app:[SELECT Id,Loan__c,Caste__c FROM Applicant__c where Loan__c=:newListOfIds AND recordTypeId=:applicantRecordTypeId WITH SECURITY_ENFORCED]){
            if(app.Caste__c!=null){
                mapOfLoanIdVsApplicantCaste.put(app.Loan__c,app.Caste__c);
            }
        }
        return mapOfLoanIdVsApplicantCaste;
    }
     
    public static void assignNextApprover(Map<Id,Loan_Application_Approval__c> oldListMap, List<Loan_Application_Approval__c> newList){
        
        Map<Id,String> mapOfLoanIdVsType = new Map<Id,String>();
        Map<Id,String> mapOfLoanIdVsApprovalType = new Map<Id,String>();
        for(Loan_Application_Approval__c obj:newList){
            if(oldListMap.get(obj.Id).Approval_Status__c!=obj.Approval_Status__c && obj.Approval_Status__c=='Approved' && obj.Button_Approval__c==false){
                mapOfLoanIdVsType.put(obj.Loan_Application__c,obj.Type__c);
                mapOfLoanIdVsApprovalType.put(obj.Loan_Application__c,obj.Approval_Type__c);
                
            }
        }
        if(mapOfLoanIdVsType.size()>0){
           updateLoanApplicationApproval(mapOfLoanIdVsType,mapOfLoanIdVsApprovalType); 
        }
    }
    
    @future
    public static void updateLoanApplicationApproval(Map<Id,String> mapOfLoanIdVsType,Map<Id,String> mapOfLoanIdVsApprovalType){
        List<Loan_Application_Approval__c> updateApprovals = new List<Loan_Application_Approval__c>();
        
        for(Loan_Application_Approval__c obj:[SELECT Id,Type__c,Approval_Type__c ,Loan_Application__c,Is_Assigned_Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:mapOfLoanIdVsType.keySet() AND Approval_Status__c ='pending']){
            if(mapOfLoanIdVsType.get(obj.Loan_Application__c)=='Base' && obj.Type__c=='Middle' && mapOfLoanIdVsApprovalType.get(obj.Loan_Application__c)==obj.Approval_Type__c){
               obj.Is_Assigned_Approver__c = true;
               updateApprovals.add(obj);
            }else if(mapOfLoanIdVsType.get(obj.Loan_Application__c)=='Middle' && obj.Type__c=='Highest' && mapOfLoanIdVsApprovalType.get(obj.Loan_Application__c)==obj.Approval_Type__c){
               obj.Is_Assigned_Approver__c = true;
               updateApprovals.add(obj);
            }/*else if(mapOfLoanIdVsType.get(obj.Loan_Application__c)=='Highest' && obj.Approval_Type__c='pricing' &&(obj.Type__c='Base'||obj.Type__c='Base')){
                obj.Is_Assigned_Approver__c = true;
                updateApprovals.add(obj);
            }*/
        }
        update updateApprovals;
    }

    public static void updateComments(List<Loan_Application_Approval__c> newList){
        List<String> approvalIds = new List<String>();
        Map<Id,String> mapOfApprovalIdVsComments = new Map<Id,String>();
        Set<Id> tarProcessSet = new Set<Id>();
        for(Loan_Application_Approval__c obj:newList){
            if(obj.Approval_Status__c=='Approved' && !obj.Button_Approval__c){
                approvalIds.add(obj.Id);
            }
            
        }
        for(ProcessInstanceStep proc:[SELECT Id,ProcessInstance.TargetObjectId,Comments,ProcessInstance.ProcessDefinition.Name FROM ProcessInstanceStep 
                                      WHERE ProcessInstance.TargetObjectId=:approvalIds AND StepStatus='Approved']){
            mapOfApprovalIdVsComments.put(proc.ProcessInstance.TargetObjectId,proc.Comments);
            if (proc.ProcessInstance.ProcessDefinition.Name == 'Tar_Approval_Process') {
                tarProcessSet.add(proc.ProcessInstance.TargetObjectId);
            }
        }
        
        for(Loan_Application_Approval__c obj:newList){
            if(obj.Approval_Status__c=='Approved' && !tarProcessSet.contains(obj.id)){
                obj.Remarks__c = mapOfApprovalIdVsComments.get(obj.id);
            }
        }
    }
    
    public static final String[] STATUS_TO_COPY_COMMENTS = new String[]{ GlobalConstants.APPROVAL_STATUS_APPROVED, GlobalConstants.REJECTED };

    public static void populateComments(List<Loan_Application_Approval__c> newList, map<Id, Loan_Application_Approval__c> oldApprovals){
        List<String> approvalIds = new List<String>();
        Map<Id,String> mapOfApprovalIdVsComments = new Map<Id,String>();
        Boolean isAfter = oldApprovals != NULL;
        Set<Id> tarProcessSet = new Set<Id>();
        for(Loan_Application_Approval__c obj:newList){
            if(!obj.Button_Approval__c && STATUS_TO_COPY_COMMENTS.contains(obj.Approval_Status__c) && obj.Approval_Status__c != oldApprovals.get(obj.Id).Approval_Status__c ){
                approvalIds.add(obj.Id);
            }
        }
        system.debug('approval ids '+approvalIds);
        for(ProcessInstanceStep proc:[
                SELECT Id, ProcessInstance.TargetObjectId,Comments, ProcessInstance.ProcessDefinition.Name
                FROM ProcessInstanceStep 
                WHERE ProcessInstance.TargetObjectId=:approvalIds AND
                StepStatus IN: STATUS_TO_COPY_COMMENTS
        ]){
            mapOfApprovalIdVsComments.put( proc.ProcessInstance.TargetObjectId, proc.Comments );
            if (proc.ProcessInstance.ProcessDefinition.Name == 'Tar_Approval_Process') {
                tarProcessSet.add(proc.ProcessInstance.TargetObjectId);
            }
        }
        Loan_Application_Approval__c[] approvalsToUpdate = new Loan_Application_Approval__c[0];
        Set<Loan_Application__c> applicationsToUpdate = new Set<Loan_Application__c>();
        for( Loan_Application_Approval__c obj: newList ){
            if( approvalIds.contains(obj.Id) && !tarProcessSet.contains(obj.id)){
                // SFAU-3821 -- 05/09/23 -- If rejected via email on Pricing stage it should be Sent Back to RO instead of Reject
                Boolean isPricingRejection = obj.Loan_Application_Stage__c == 'Pricing' && obj.Approval_Status__c == GlobalConstants.REJECTED;
                approvalsToUpdate.add(
                    new Loan_Application_Approval__c(
                        Id = obj.Id,
                        Remarks__c = obj.Remarks__c == null ? mapOfApprovalIdVsComments.get(obj.id) : obj.Remarks__c,
                        Approval_Status__c = isPricingRejection ? 'Send Back To RO' : obj.Approval_Status__c
                    )
                );

                // SFAU-3821 - Reject action from Pricing to be considered as Send back to RO
                if(isPricingRejection){

                    applicationsToUpdate.add(
                        new Loan_Application__c(
                            Id = obj.Loan_Application__c,
                            Approval_Status__c = 'Pricing Send Back To RO',
                            Send_Back_To_RO_Stage__c = 'Pricing',
                            Stage__c =  obj.Loan_Type__c == GlobalConstants.TWOWHEELER ? GlobalConstants.QDE : GlobalConstants.STAGE_DDE
                        )
                    );
                }
            }
            
        }
        update approvalsToUpdate;
        update new List<Loan_Application__c>( applicationsToUpdate );
        
    }
    
    public static void submitToApprovalProcess( Loan_Application_Approval__c[] approvals, map<Id, Loan_Application_Approval__c> oldApplications ){
        Set<String> approvalIds = new Set<String>();
        Set<Id> setLoanAppId = new Set<Id>();
        Id tarRecType = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('TAR').getRecordTypeId();
        for( Loan_Application_Approval__c approval: approvals ){
            if( approval.Approval_Status__c == GlobalConstants.APPROVAL_STATUS_PENDING && !approval.Archived__c 
            && !approval.Assigned_to_Queue__c && approval.Is_Assigned_Approver__c && approval.RecordTypeId !=tarRecType){
                approvalIds.add( approval.Id );
                setLoanAppId.add(approval.Loan_Application__c);
            }
        }
        if(!approvalIds.isEmpty()){
            //SFAU-5179
            submitForApproval( approvalIds, setLoanAppId );
        }
    }

    public static void submitForApproval(Set<String> newApprovalIds, Set<Id> setLoanAppId){  
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        // STARTS SFAU-5179
        List<Loan_Application__Share> lstLstShare = new List<Loan_Application__Share>();
        List<Loan_Application__Share> lstAlreadyShared = new List<Loan_Application__Share>();
        Id loginUserId = UserInfo.getUserId();
        User objUser = [Select Id, Profile.Name from User where Id =: loginUserId];
        if (objUser.Profile.Name == 'Field Investigator') {
            for (Id loanId : setLoanAppId) {
                Loan_Application__Share objShare = new Loan_Application__Share();
                objShare.UserOrGroupId = UserInfo.getUserId();
                objShare.ParentId = loanId;
                objShare.AccessLevel = 'edit';
                lstLstShare.add(objShare);
            }
            if (lstLstShare.size()>0){
                Database.insert(lstLstShare,false);
            }
        }
        // END SFAU-5179
        

        for(String loanApprId:newApprovalIds){
            // Create an approval request for  Opportunity        
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request using Trigger');   
            req.setProcessDefinitionNameOrId('Loan_Application_Approval_Process_Flow');
            req.setObjectId(loanApprId);  
            requests.add(req);
        }
        
        // Submit the approval request for the Opportunity        
        Approval.ProcessResult[] result = Approval.process(requests);
        for(Approval.ProcessResult res: result){
            if(!res.isSuccess())
                System.debug(res.getErrors());
        }

        if (lstLstShare.size()>0){
            Database.delete(lstLstShare,false);
        }
    }

    public static void sendLoanApplicationForReWork(Loan_Application_Approval__c[] approvals){
        Loan_Application__c[] loanApplications = new Loan_Application__c[0];
        Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
        for(Loan_Application_Approval__c approval: approvals){
            if(!approval.Archived__c && approval.Approval_Status__c == GlobalConstants.APPROVAL_STATUS_PENDING && approval.Is_Rework__c){
                if(!loanApplicationMap.containsKey(approval.Loan_Application__c)){
                    loanApplicationMap.put(approval.Loan_Application__c, new Loan_Application__c(Id = approval.Loan_Application__c,Is_Rework__c = true));
                }
                /*
                loanApplications.add(
                    new Loan_Application__c(
                        Id = approval.Loan_Application__c,
                        Is_Rework__c = true
                    )
                );*/
            }
        }
        if (loanApplicationMap.size()>0)
            update loanApplicationMap.values();
    }
    
    public static Loan_Application_Approval__c[] populateValuesFromApplication(Loan_Application_Approval__c[] approvals, map<Id, map<String, Object>> loanIdDetails){
        for(Loan_Application_Approval__c approval: approvals){
            map<String, Object> additionalFieldValues = loanIdDetails.get(approval.Loan_Application__c);
            for(String field: additionalFieldValues.keySet()){
                approval.put(field, additionalFieldValues.get(field));
            }
        }
        return approvals;
    }

    //3838
    public static void callShareRecordsWithCreditApprovers(List<Loan_Application_Approval__c> approvals){
        Loan_Application_Approval__c[] approvalsToShare = new Loan_Application_Approval__c[0];
        Set<Id> loanId4WSet = new Set<Id>();
        Set<String> loanTypesToMovePSDAfterBMApproval = LoanApplicationApprovalTriggerHandler.loanTypesToMovePSDAfterBMApproval;
        List<Loan_Application_Approval__c> approvals4W = new List<Loan_Application_Approval__c>();
        for(Loan_Application_Approval__c approval: approvals){
            if( approval.Approval_Type__c == GlobalConstants.APPROVAL_TYPE_CREDIT && loanTypesToMovePSDAfterBMApproval.contains( approval.Loan_Type__c ) ){
                loanId4WSet.add(approval.Loan_Application__c);
                approvals4W.add(approval);
            }
        }
        if(!approvals4W.isEmpty()){
            try{
                LoanApplicationApprovalTriggerHelper.shareRecordsWithCreditApprovers(loanId4WSet,approvals4W);
            }catch(Exception objException){
                Log.error(objException,Log.SeverityType.valueOf('High'),null);
            }
            
        }
    }

    //3838
    public static void shareRecordsWithCreditApprovers(Set<Id> loanIds, List<Loan_Application_Approval__c> newLoanApprList){
        Map<Id,Applicant__c> applicantIds = new Map<Id,Applicant__c>([SELECT Id FROM Applicant__c WHERE Loan__c IN :loanIds AND RecordType.DeveloperName IN 
            ('Primary_Applicant','Co-Applicant','BO','Guarantor') AND IsInactive__c=false]);
        List<Document_Checklist__c> documentChecklists = [SELECT Id, Loan_Application__c, Applicant__c, Applicant__r.Loan__c FROM Document_Checklist__c WHERE Loan_Application__c IN :loanIds
            OR Applicant__c IN :applicantIds.keySet()];
        Map<Id,List<Document_Checklist__c>> mapIdVsDocChecklist = new Map<Id,List<Document_Checklist__c>>();
        for(Document_Checklist__c doc: documentChecklists){
            String currentId;
            if(doc.Loan_Application__c!=null){
                currentId = doc.Loan_Application__c;
            }else if(doc.Applicant__c!=null){
                currentId = doc.Applicant__r.Loan__c;
            }
            if(currentId!=null){
                if(mapIdVsDocChecklist.containsKey(currentId)){
                    mapIdVsDocChecklist.get(currentId).add(doc);
                }else{
                    List<Document_Checklist__c> tempList = new List<Document_Checklist__c>();
                    tempList.add(doc);
                    mapIdVsDocChecklist.put(currentId,tempList);
                }
            }
        }
        List<Document_Checklist__Share> docChecklistShares = new List<Document_Checklist__Share>();
        if(mapIdVsDocChecklist!=null && mapIdVsDocChecklist.size()>0){
            for(Loan_Application_Approval__c approval: newLoanApprList){
                if(mapIdVsDocChecklist.containsKey(approval.Loan_Application__c)){
                    for(Document_Checklist__c docCheckList: mapIdVsDocChecklist.get(approval.Loan_Application__c)){
                        docChecklistShares.add(
                            new Document_Checklist__share(
                                ParentId = docCheckList.Id,
                                UserOrGroupId = approval.Approver__c,
                                AccessLevel = 'edit'
                            )
                        );
                    }
                }
            }  
        }

        // SFAU-5208 - Share BSR PSL records
        BSR_PSL_Details__share[] bsrPslShares = new BSR_PSL_Details__share[0];
        map<Id, Id[]> loanToApproverIds = new map<Id, Id[]>();

        for( Loan_Application_Approval__c approval: newLoanApprList ){
            if( !loanToApproverIds.containsKey( approval.Loan_Application__c ) ){
                loanToApproverIds.put( approval.Loan_Application__c,  new Id[0] );
            }
            loanToApproverIds.get(  approval.Loan_Application__c ).add( approval.Approver__c );   
        }

        for( Id loanId: loanToApproverIds.keySet() ){
            for( Id approverId: loanToApproverIds.get( loanId ) ){
                bsrPslShares.add(
                    new BSR_PSL_Details__share(
                        ParentId = loanId,
                        UserOrGroupId = approverId,
                        AccessLevel = 'edit'
                    )
                );
            }
        }

        if(docChecklistShares!=null && docChecklistShares.size()>0){
            database.insert (docChecklistShares, false);
        }
        database.insert (bsrPslShares, false);
    }

    Public static void updateTarstatusonCollateral(List<Loan_Application_Approval__c> newLoanApprList, 
        map<Id, Loan_Application_Approval__c> oldLOanAppMap){
        Set<Id> loanIdSet = New Set<Id>();
        Map<id,String> loanStatusMap = New Map<Id,String>();
        Map<String,String> pickListValMap = New Map<String,String>{
            'Pending' => 'Not Initiated','Approved'=>'Approved', 'Submitted for Approval' => 'Initiated',
            'Rejected' => 'Rejected'
        };
        id RecTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('TAR').getRecordTypeId();
        for(Loan_Application_Approval__c laa: newLoanApprList){
            if(laa.RecordTypeId == RecTypeId && (oldLOanAppMap==null || (oldLOanAppMap<> null && laa.Approval_Status__c <> oldLOanAppMap.get(laa.Id).Approval_Status__c)) ){
                loanIdSet.add(laa.Loan_Application__c);
                loanStatusMap.put(laa.Loan_Application__c,laa.Approval_Status__c);
            }
        }
        List<Collateral__c> colList = new List<Collateral__c>();
        for(Collateral__c col: [select id, Loan__c from Collateral__c where Loan__c =: loanIdSet]){
            col.TAR_Approval_Status__c = pickListValMap.get(loanStatusMap.get(col.Loan__c));
            colList.add(col);
        }
        update colList;
    }
}