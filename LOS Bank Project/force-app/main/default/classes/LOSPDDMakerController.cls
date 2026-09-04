/*****
 * Class Name: LOSPDDMakerController
 * Description: 
 * Test Class Name: LOSPDDMakerControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-12-2023          -   Mohit M.            -   SFAU-5711 - Deffral Issue
* Dec-12-2023          -   Ajitesh 
 * Dec-20-2023          -   Mohit M.            -   SFAU-5622 - Add User.IsActive check
 */
public without sharing class LOSPDDMakerController {
    
    public static Id newColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
    public static Id usedColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
    public static Set<Id> colRecordTypeIds = new Set<Id>{newColRecordTypeId,usedColRecordTypeId};
        public static String INVOICE_EXSHOWROOM_DEVIATION = 'Invoice_Exshowroom_Variance';
    public static Map<String,List<SelectOptionWrapper>> fetchPicklistValues(){
        Map<String,List<SelectOptionWrapper>> result = new Map<String,List<SelectOptionWrapper>>();
        result.put('vehicleDelivery',fetchPicklist('Collateral__c','Vehicle_Delivery__c'));
        result.put('caseDeferral',fetchPicklist('Collateral__c','Case_In_Deferral__c'));
        result.put('deferralCategory',fetchPicklist('Collateral__c','Deferral_Category__c'));
        result.put('invoiceStatus',fetchPicklist('Collateral__c','Invoice_Status__c'));
        result.put('assignmentCaseOptions',fetchPicklist('Collateral__c','Assignment_Case__c'));
        result.put('hpnInvoice',fetchPicklist('Collateral__c','HPN_On_Invoice__c'));
        result.put('insuranceStatus',fetchPicklist('Insurance_Details__c','Insurance_Status__c'));
        result.put('hpnInsurance',fetchPicklist('Insurance_Details__c','HPN_On_Insurance__c'));
        result.put('thirdPartyInsurance',fetchPicklist('Insurance_Details__c','Third_Party_Insurance__c'));
        result.put('insuranceType',fetchPicklist('Insurance_Details__c','Insurance_Type__c'));
        result.put('insuranceEndorsement',fetchPicklist('Insurance_Details__c','Insurance_Endorsement__c'));
        result.put('insuranceDoneBy',fetchPicklist('Insurance_Details__c','Insurance_Done_By__c'));
        result.put('ownershipInsurance',fetchPicklist('Insurance_Details__c','Ownership_Insurance__c'));
        result.put('rCStatus',fetchPicklist('Collateral__c','RC_Status__c'));
        result.put('rcType',fetchPicklist('Collateral__c','RC_Type__c'));
        result.put('hpnOnRC',fetchPicklist('Collateral__c','HPN_On_RC__c'));
        result.put('ownershipTransferOnRC',fetchPicklist('Collateral__c','Ownership_Transfer_On_RC__c'));
        result.put('taxReceiptStatus',fetchPicklist('Collateral__c','Tax_Receipt_Status__c'));
        result.put('originalNocStatus',fetchPicklist('Collateral__c','PDD_Original_NOC_Status__c'));
        result.put('subStatus',fetchPicklist('Collateral__c','Sub_Status__c'));//R2-879
        return result;
    }
    
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName) {
        List<SelectOptionWrapper> opts = new List <SelectOptionWrapper> ();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map <String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List <Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal: ple) {
            opts.add(new SelectOptionWrapper(pickListVal.getValue(), pickListVal.getLabel()));
        }
        return opts;
    }
    
    private static Id getLoanId(Id recId){
        Schema.SObjectType assignmentObject = Schema.Assignment__c.getSObjectType();
        if(recId.getsobjecttype() == assignmentObject){
            List<Assignment__c> assignments = [SELECT Id,Loan_Application__c FROM Assignment__c Where Id =: recId WITH SECURITY_ENFORCED];
            if(!assignments.isEmpty()){
                return assignments[0].Loan_Application__c;
            }
        }
        return recId;
    }
    
    @AuraEnabled
    public static Map<String,object> getData(String loanAppId){    
        Map<String,object> response = new Map<String,object>();
        PDDMakerWrapper wrapper;
        if(String.isblank(loanAppId)){
            return response;
        }
        
        Id loanId = getLoanId(loanAppId) ;
        // SFAU-5711 - Add RC_is_on_name_of_Applicant__c
        List<Collateral__c> listOfColl = [SELECT Id,Vahaan_Response__c,Ex_Showroom_Price__c,Assignment_Case__c,Tax_Receipt_Status__c,Vehicle_Delivery__c,toLabel(Collateral_Name__c),Original_RC_Details__c,Case_In_Deferral__c,Invoice_Status__c,Deferral_Category__c,Invoice_Number__c,Invoice_Date__c,Invoice_Amount__c,HPN_On_Invoice__c,Engine_Number__c,Chasis_Number__c,
                                          Receipt_No__c,Receipt_Amount__c,Temp_Vehicle_No__c,RC_Status__c,Vehicle_Number__c,Registration_Date__c,HPN_On_RC__c,Ownership_Transfer_On_RC__c,Sourcing_Detail__c,HPN_With_Financiers_Name__c,Loan__r.Source_Name__c,Loan__r.Sourcing_channel__c,
                                          Loan__r.Product__c,Loan__r.Branch_Master__c,Loan__r.Branch_Master__r.Business_HUB__c,Loan__r.Name,Loan__r.Name_of_Customer__c ,Loan__r.Total_Loan_Amount__c,Final_Cost__c,Manufacture_year_month__c,Make__c,Model__c,Loan__r.Dealer_Master__r.Name,Loan__r.Stage__c, RC_is_on_name_of_Applicant__c,Sub_Status__c,Loan__r.RecordType.DeveloperName, PDD_Implement_Serial_No__c, PDD_Original_NOC_Status__c, PDD_Financier_Name__c,
                                          Father_s_Name__c, Registration_City__c,RC_Type__c // New Fields Added for 5598
                                          FROM Collateral__c WHERE Loan__c=:loanId AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true];
        
        List<Insurance_Details__c> listOfInsurance = [SELECT Id,Createddate, Insurance_Status__c,Insurance_Policy_Number__c,Insurance_Start_Date__c,Insurance_End_Date__c,Insurance_IDV__c,HPN_On_Insurance__c,Ownership_Insurance__c,
                                                      Insurance_Agent_Name__c,Insurance_Company_Name__c,Third_Party_Insurance__c,Insurance_Type__c,Insurance_Endorsement__c,Insurance_Done_By__c,Premium__c FROM Insurance_Details__c WHERE Loan_Application__c =:loanId];
        
        Collateral__c collateral = listOfColl.isEmpty() ? new Collateral__c() : listOfColl[0];
        Insurance_Details__c insuranceDetail = listOfInsurance.isEmpty() ? new Insurance_Details__c() : listOfInsurance[0];
        Date minInsuranceEndDate = listOfInsurance.isEmpty() ? Date.today() : Date.valueOf(insuranceDetail.Createddate);
        wrapper = new PDDMakerWrapper(collateral,insuranceDetail);
        wrapper.vahanData =  String.isNotBlank(collateral.Vahaan_Response__c) ? (VahaanWrapper) JSON.deserialize(collateral.Vahaan_Response__c, VahaanWrapper.class) : new VahaanWrapper();
        
        
        Id branchMasterId = collateral.Loan__r.Branch_Master__c;
        Id businessHubId =  collateral.Loan__r.Branch_Master__r?.Business_HUB__c;
        // SFAU-5622 - Add IsActive check
        List<AccountTeamMember> accTeamMembers = [SELECT Id,UserId,User.MobilePhone,User.Name,TeamMemberRole,Employee_Code__c FROM AccountTeamMember Where AccountId =: branchMasterId AND User.IsActive = true];
        
        
        Map<String,AccountTeamMember> accountRoleToNameMap = new Map<String,AccountTeamMember>();
        for(AccountTeamMember accTeamMember : accTeamMembers){
            accountRoleToNameMap.put(accTeamMember.TeamMemberRole,accTeamMember);
        }
        
        List<Deferral_Register__c> deferralRegisters = [SELECT Id,Agent_Id__c,Agent_Name__c,Collateral__c,Commitment_Date__c,Confirmation_Recieved__c,Confirmation_Recieved_Date__c,
                                                        Document_Handed_Over_date__c,Document_Handed_Over_to__c ,Original_Doc_Collected_Date__c ,Remark__c,Status__c,Agent_No__c FROM Deferral_Register__c Where Collateral__c =: listOfColl[0].Id AND Confirmation_Recieved__c != 'Yes'];
        
        if(!deferralRegisters.isEmpty()){
            wrapper.deferralRegister = new DeferralRegisterWrapper(deferralRegisters[0]);
        }else{
            wrapper.deferralRegister = new DeferralRegisterWrapper();
        }
        
        User u = [SELECT Id,Profile.Name FROM User Where Id =: UserInfo.getUserId() Limit 1];
        List<String> editAllowedProfiles = new List<String>();
        editAllowedProfiles = Label.PDDMakerEditProfiles.split(',');
        Boolean allowEdit = (u.Profile.Name == 'Operations' && (collateral.Loan__r.Stage__c == 'Ops Maker' || collateral.Loan__r.Stage__c == 'Ops Author' || collateral.Loan__r.Stage__c == 'PDD')) || (editAllowedProfiles.contains(u.Profile.Name) && (collateral.Loan__r.Stage__c == 'PSD' || collateral.Loan__r.Stage__c == 'PDD'));
        
        List<Applicant__c> applicantList =  LOSDocumentManagerController.getApplicants(loanId);
        response.put('isOpsUser',u.Profile.Name == 'Operations');
        response.put('profileName',u.Profile.Name);
        response.put('applicant',applicantList[0]);
        response.put('allowEdit',allowEdit);
        response.put('AccountTeamMember',accountRoleToNameMap);
        response.put('minInsuranceEndDate',minInsuranceEndDate);
        response.put('rtoAgentInfo',getRTOAgentInfo(branchMasterId,businessHubId));
        response.put('wrapper',JSON.serialize(wrapper));
        response.put('picklistValues', fetchPicklistValues());
        response.put('stage',  collateral.Loan__r.Stage__c);
        response.put('documentChecklist',LOSDocumentManagerController.getDocumentChecklist(loanId,'pddMaker'));
response.put('loanRecordType',collateral.Loan__r.RecordType.DeveloperName);
        response.put('loan',collateral.Loan__r.RecordType.DeveloperName);

        // Adding tractor and Commercial related features
        if(collateral.Loan__r.RecordType.DeveloperName == 'Tractor' || collateral.Loan__r.RecordType.DeveloperName == 'Commercial_Vehicle' || collateral.Loan__r.RecordType.DeveloperName == 'Construction_Equipment'){
            List<Collateral__c> collateralList = [SELECT Collateral_Name__c, Registrable__c, Attachment__c, Loan__r.Total_Loan_Amount__c FROM Collateral__c WHERE Loan__c = :loanId WITH SECURITY_ENFORCED];
            response.put('collateralData',collateralList[0]);
        }
        // Adding tractor and Commercial related features

        return response;
        
    }
    
    /* Commented - Mohit - ROC CHarge Data Apex Update Starts* / 
    @AuraEnabled
    public static ROCChargeWrapperData getROCChargesData(String loanId){
        try {
            ROCChargeWrapperData returndata = new ROCChargeWrapperData();
            User u = [SELECT Id,Profile.Name FROM User Where Id =: UserInfo.getUserId() Limit 1];
            List<Loan_Application__c> applicationRecordList = [SELECT Id, ROC_Charge__c, ROC_Charge_Status__c, ROC_Creation_Status__c,
                                                           ROC_Remarks__c, Stage__c FROM Loan_Application__c WHERE Id=:loanId LIMIT 1];
            system.debug('Id '+applicationRecordList+' '+loanId);                                            
            if(!applicationRecordList.isEmpty()){
                returndata.applicationRecord = applicationRecordList[0];
                returndata.isEditable = (applicationRecordList[0].Stage__c == 'Ops Author' && u.Profile.Name == 'Operations');
                Schema.DescribeFieldResult fieldDescription = Loan_Application__c.ROC_Creation_Status__c.getDescribe();
                List<PickListWrapper> pickListOptions = new List<PickListWrapper>();
                List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
                for (Schema.PicklistEntry entry : entries) {
                    pickListOptions.add(new PickListWrapper(entry.getLabel(), entry.getValue()));
                }
                returndata.rocCreationStatusOptions = pickListOptions;
            }
            return returndata;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ROCChargeWrapperData{
        @AuraEnabled public Loan_Application__c applicationrecord{get;set;}
        @AuraEnabled public List<PickListWrapper> rocCreationStatusOptions{get;set;}
        @AuraEnabled public Boolean isEditable{get;set;}
        public ROCChargeWrapperData(){
            applicationrecord = new Loan_Application__c();
            rocCreationStatusOptions = new List<PickListWrapper>();
            isEditable = true;
        }
    }

    public class PickListWrapper{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        public PickListWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    */


    
    private static Contact getRTOAgentInfo(Id branchMasterId,Id businessHubId){
        if(branchMasterId == null){
            return null;
        }
        List<Contact> contacts = [SELECT Id,Name,Agent_Code__c,MobilePhone FROM Contact Where AccountId =: branchMasterId AND Type__c = 'RTO Agent' Order by Createddate desc];
        if(contacts.isEmpty()){
            contacts =  [SELECT Id,Name,Agent_Code__c,MobilePhone FROM Contact Where AccountId =: businessHubId AND Type__c = 'RTO Agent' order by Createddate desc];
            return contacts.isEmpty() ? null : contacts[0];
        }else{
            return contacts.isEmpty() ? null : contacts[0];
        }
        
    }
    
    @AuraEnabled
    public static Boolean getDealerRCDetails(String loanId) {
        Boolean isRCCategoryEnabled = false;
        try{
            if(String.isBlank(loanId)){
                return false;
            }
            loanId = getLoanId(loanId);
            List<Loan_Application__c> getApplicationDetails = [SELECT Id, Dealer_Master__c, Dealer_Master__r.Dealer_Class__c FROM Loan_Application__c
                                                               WHERE Id=:loanId AND Dealer_Master__c!=NULL LIMIT 1];
            if(!getApplicationDetails.isEmpty()) {
                if(String.isNotBlank(String.valueOf(getApplicationDetails[0].Dealer_Master__c))){
                    if(String.isNotBlank(getApplicationDetails[0].Dealer_Master__r.Dealer_Class__c)) {
                        String dealerClass = getApplicationDetails[0].Dealer_Master__r.Dealer_Class__c;
                        isRCCategoryEnabled = dealerClass.containsIgnoreCase('WITH RC LIMIT');
                    }
                }
            }
            
        }catch(Exception ex){
            system.debug('exception here '+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        return isRCCategoryEnabled;
    }
    
    
    @AuraEnabled
    public static Map<String,Object> saveData(String jsonString,String objectName){
        Map<String,Object> response = new Map<String,Object>();
        
        if(String.isblank(jsonString)){
            return response;
        }
        
        PDDMakerWrapper wrapper = (PDDMakerWrapper) JSON.deserialize(jsonString,PDDMakerWrapper.Class);
        Id loanId = getLoanId(wrapper.loanAppId) ;
        List<Collateral__c> listOfColl = [SELECT Id,Vehicle_Delivery__c,RC_Status__c,RC_Type__c FROM Collateral__c WHERE Loan__c=:loanId AND recordTypeId IN: colRecordTypeIds AND Is_Deleted__c != true]; // Added fields for notification
        List<Insurance_Details__c> listOfInsurance = [SELECT Id,Insurance_Status__c FROM Insurance_Details__c WHERE Loan_Application__c =:loanId];
        //Collateral Details
        Collateral__c collateral = new Collateral__c();
        collateral.Vehicle_Delivery__c = wrapper.vehicleDelivery;
        // collateral.Case_In_Deferral__c = wrapper.caseDeferral;
        collateral.Invoice_Status__c = wrapper.invoiceStatus;
        collateral.Tax_Receipt_Status__c =  wrapper.taxReceiptStatus;
        collateral.Assignment_Case__c = wrapper.assignmentCase;
        collateral.Deferral_Category__c = wrapper.deferralCategory;
        collateral.Invoice_Number__c = wrapper.invoiceNumber;
        collateral.Invoice_Date__c = wrapper.invoiceDate;
        collateral.Invoice_Amount__c = wrapper.invoiceAmount;
        collateral.HPN_On_Invoice__c = wrapper.hpnInvoice;
        collateral.Engine_Number__c = wrapper.engineNo;
        collateral.Chasis_Number__c = wrapper.chasisNumber;
collateral.PDD_Implement_Serial_No__c = wrapper.serialNoImplement; // Tractor Serial No. Implement
        collateral.PDD_Original_NOC_Status__c = wrapper.originalNocStatus; // CE NOC Requirement
        collateral.PDD_Financier_Name__c = wrapper.financierName; // CE NOC Requirement
        collateral.Receipt_No__c = wrapper.recieptNo;
        collateral.Receipt_Amount__c = wrapper.receiptAmount;
        collateral.Temp_Vehicle_No__c = wrapper.tempVehicleNo;
        collateral.RC_Status__c = wrapper.rCStatus;
        collateral.RC_Type__c = wrapper.rcType;
        collateral.Sub_Status__c = wrapper.subStatus;//R2-879
        collateral.Vehicle_Number__c = wrapper.registrationNumber;
        collateral.Vahaan_Response__c = JSON.serialize(wrapper.vahanData);
        wrapper.registrationDate = String.isNotBlank(wrapper.registrationDate) ? wrapper.registrationDate.replaceAll('/','-') : '';
        collateral.Registration_Date__c = String.isNotBlank(wrapper.registrationDate) ?  Date.valueOf(wrapper.registrationDate) : null;
        collateral.HPN_On_RC__c = wrapper.hpnOnRC;
        collateral.Ownership_Transfer_On_RC__c = wrapper.ownershipTransferOnRC;
        collateral.Sourcing_Detail__c = wrapper.sourcingDetail;
        collateral.Original_RC_Details__c = wrapper.originalRCValue;
        collateral.Case_In_Deferral__c = wrapper.caseDeferral;

        collateral.Father_s_Name__c = wrapper.fatherNameVahaan;
        if(listOfColl != null && !listOfColl.isEmpty()){
            collateral.Id = listOfColl[0].Id;
        }else{
            collateral.Loan__c = loanId;
        }
        
        // Insurance Details
        Insurance_Details__c insuranceDetail = new Insurance_Details__c();
        insuranceDetail.Insurance_Status__c = wrapper.insuranceStatus;
        insuranceDetail.Insurance_Policy_Number__c = wrapper.insuranceNumber;
        insuranceDetail.Insurance_Start_Date__c = wrapper.insuranceStartDate;
        insuranceDetail.Insurance_End_Date__c = wrapper.insuranceEndDate;
        insuranceDetail.Insurance_IDV__c = wrapper.insuranceIDV;
        insuranceDetail.HPN_On_Insurance__c = wrapper.hpnInsurance;
        insuranceDetail.Ownership_Insurance__c = wrapper.ownershipInsurance;
        insuranceDetail.Insurance_Agent_Name__c = wrapper.insuranceAgentName;
        insuranceDetail.Insurance_Company_Name__c = wrapper.insuranceCompanyName;
        insuranceDetail.Third_Party_Insurance__c = wrapper.thirdPartyInsurance;
        insuranceDetail.Insurance_Type__c = wrapper.insuranceType;
        insuranceDetail.Insurance_Endorsement__c = wrapper.insuranceEndorsement;
        insuranceDetail.Insurance_Done_By__c = wrapper.insuranceDoneBy;
        insuranceDetail.Premium__c = wrapper.premium;
        
        if(listOfInsurance != null && !listOfInsurance.isEmpty()){
            insuranceDetail.Id = listOfInsurance[0].Id;
        }else{
            insuranceDetail.Loan_Application__c = loanId;
        }
        // Added Notification 30 Aug
        if(!listOfColl.isEmpty() && listOfColl.size()>0){
            if( (listOfColl[0].Vehicle_Delivery__c == 'No' || String.isBlank(listOfColl[0].Vehicle_Delivery__c)) && collateral.Vehicle_Delivery__c == 'Yes' ){
                NotificationHandler.sendNotification('ON vehicle delivery',loanId,'');
            }
            if( (listOfColl[0].RC_Status__c == '' || String.isBlank(listOfColl[0].RC_Status__c)) && collateral.RC_Status__c == 'Pending' ){
                NotificationHandler.sendNotification('RC Pending',loanId,'');
            }
        }
        
        if(!listOfInsurance.isEmpty() && listOfInsurance.size()>0){
            if(String.isBlank(listOfInsurance[0].Insurance_Status__c) && insuranceDetail.Insurance_Status__c =='Pending'){
                NotificationHandler.sendNotification('Insurance Pending',loanId,'');
            }
        }
        
        
        upsert collateral;
        upsert insuranceDetail;
        Deferral_Register__c deferralRegister;
        if(wrapper.isUsedOrCOW){
            DeferralRegisterWrapper registerWrapper = wrapper.deferralRegister;
            deferralRegister = new Deferral_Register__c();
            deferralRegister.Original_Doc_Collected_Date__c = registerWrapper.originalDocumentDate;
            deferralRegister.Document_Handed_Over_to__c = registerWrapper.documentHandoverto; 
            deferralRegister.Agent_Name__c = registerWrapper.rtoAgentName;
            deferralRegister.Agent_Id__c = registerWrapper.rtoAgentID;
            deferralRegister.Agent_No__c = registerWrapper.rtoAgentNumber;
            deferralRegister.Document_Handed_Over_date__c = registerWrapper.documentHandedOverDate;
            deferralRegister.Status__c = registerWrapper.status;
            deferralRegister.Commitment_Date__c = registerWrapper.commitmentDate;
            deferralRegister.Remark__c = registerWrapper.remarks;
            deferralRegister.Id = registerWrapper.recordId;
            deferralRegister.Collateral__c = listOfColl[0].Id;
            if(deferralRegister.Document_Handed_Over_to__c != 'RTO agent'){
                deferralRegister.Confirmation_Recieved__c = registerWrapper.confirmationRecieved;
                deferralRegister.Confirmation_Recieved_Date__c = registerWrapper.confirmationRecieved == 'Yes' ? Date.today() : null;
                upsert deferralRegister;
            }else{
                upsert deferralRegister;
                if(String.isBlank(registerWrapper.recordId)){
                    sendNotification(loanId,deferralRegister.Agent_No__c);
                }
            }
        }
        User u = [SELECT Id,Profile.Name FROM User Where Id =: UserInfo.getUserId() Limit 1];
        
        
        List<Document_Checklist__c> docChecksToUpdate = new List<Document_Checklist__c>();
        for(LOSDocumentManagerController.DocumentCheckListRecord record : wrapper.docChkRecords){
            Document_Checklist__c docCheckList = new Document_Checklist__c();
            docCheckList.Id = record.docName.Id;
            docCheckList.Deferral_Register__c = deferralRegister != null ? deferralRegister.Id : null;
            // if(record.isReceived == 'Received'){
            docCheckList.Document_Verification_Status__c =  record.isReceived == 'Received' ? 'Verified' : '' ;
            //}
            if(u.Profile.Name == 'Operations'){
                docCheckList.Ops_Action__c = record.opsAction;
                docCheckList.Ops_Remark__c = record.opsRemark;
            }
            
            docChecksToUpdate.add(docCheckList);
            
        } 
        
        /*Added to Remove Duplicate List Error 06th September*/ 
        Map<Id,Document_Checklist__c> docCheckListMap = new Map<Id,Document_Checklist__c>();
        for(Document_Checklist__c docCheckList : docChecksToUpdate){
            docCheckListMap.put(docCheckList.Id, docCheckList);
        }
        update docCheckListMap.values();
        
        Deviation__c  dev = new Deviation__c();
        List<Deviation__c> deviations = new List<Deviation__c>();
        List<Deviation__c> existing = [SELECT Id FROM Deviation__c Where Loan_Application__c =: loanId AND Deviation_Type__c =: INVOICE_EXSHOWROOM_DEVIATION];
        if(wrapper.deviationNeeded == true && existing.isEmpty()){
            dev.Loan_Application__c = loanId;
            dev.Details__c ='Invoice value lower < asset cost (2% Or 10000)';
            dev.Actual_Value__c = wrapper.invoiceAmount;
            dev.Policy_Value__c = wrapper.exShowRoomPrice;
            dev.Variance__c = wrapper.deviationAmount;
            dev.Deviation_Type__c = INVOICE_EXSHOWROOM_DEVIATION;
            dev.Department__c = GlobalConstants.STAGE_PSD;
            dev.Source__c = 'SF';
            deviations.add(dev);
            AUSFApproverController.createRCMApproval(loanId);
        }else if(wrapper.deviationNeeded == true && !existing.isEmpty()){
            dev.Id = existing[0].Id;
            dev.Archived__c = false;
            dev.Actual_Value__c = wrapper.invoiceAmount;
            dev.Policy_Value__c = wrapper.exShowRoomPrice;
            dev.Variance__c = wrapper.deviationAmount;
            deviations.add(dev);
            AUSFApproverController.createRCMApproval(loanId);
        }else if(!wrapper.deviationNeeded && !existing.isEmpty()) {
            dev.Id = existing[0].Id;
            dev.Archived__c = true;
            deviations.add(dev);
        }
        
        upsert deviations;
        
        response.put('status','success');
        // if(objectName!='Assignment__c'){
        //     OpsAssignementUtility.doOpsAssignment(new Loan_Application__c(Id=loanId),'Ops - PDD','Ops Author');
        // }
        
        
        
        
        return response;
    }
    
    @AuraEnabled
    public static String saveOpsDetailsOnLoan(String loanId, String opsAction, String opsRemark, String opsAssignmentId){
        Loan_Application__c loanObj = [SELECT Id,Application_Id__c, OwnerId, OPS_PDD_Action__c, OPS_PDD_Remark__c FROM Loan_Application__c WHERE Id=:loanId];
        Assignment__c assignment = [SELECT RecordType.Name FROM Assignment__c WHERE Id=:opsAssignmentId];
        loanObj.OPS_PDD_Action__c = opsAction;
        loanObj.OPS_PDD_Remark__c = opsRemark;
        Assignment__c opsAssignment = new Assignment__c(Id=opsAssignmentId);
        try{
            if(opsAction=='Rework'){
                if(assignment.RecordType.Name=='Ops - PDD'){
                    opsAssignment.ownerId = loanObj.OwnerId;
                    update opsAssignment;
                }else if(assignment.RecordType.Name=='Ops - Disbursement'){
                    List<Assignment__c> pendingPDDAssignments = [SELECT Id FROM Assignment__c Where  Loan_Application__c =: loanId  AND RecordType.Name = 'Ops - PDD'];
                    if(pendingPDDAssignments.isEmpty()){
                        Assignment__c assignObj = new Assignment__c();
                        assignObj.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - PDD').getRecordTypeId();
                        assignObj.Loan_Application__c = loanId;
                        assignObj.ownerId = loanObj.OwnerId;
                        assignObj.Status__c = 'Pending';
                        assignObj.Name = loanObj.Application_Id__c;
                        insert assignObj;
                    }else{
                        pendingPDDAssignments[0].OwnerId = loanObj.OwnerId;
                        pendingPDDAssignments[0].Status__c = 'Pending';
                        update pendingPDDAssignments[0];
                    }
                    //Notification added
                    NotificationHandler.sendNotification('PDD Pending',loanId,'');
                }
            }
            else if(opsAction=='Approve' && assignment.RecordType.Name=='Ops - PDD'){
                opsAssignment.Status__c = 'Complete';
                update opsAssignment;
                //  sendVehicleDatatoCBS(loanId);
                //Notification added
                NotificationHandler.sendNotification('PDD COMPLETION',loanId,'');
            }
            update loanObj;
            return 'Success: Record updated successfully';
        }
        catch(Exception e){
            return 'The following exception has occurred: ' + e.getMessage();  
        }
    }
    
    
    @AuraEnabled 
    public static Contact getAgentInfobyId(String loanId,String agentId){
        
        List<Loan_Application__c> loanApps = [SELECT Id, Branch_Master__c, Branch_Master__r.Business_HUB__c FROM Loan_Application__c Where Id =: loanId];
        
        if(loanApps.isEmpty()){
            return null;
        }
        Id branchMasterId = loanApps[0].Branch_Master__c;
        Id businessHubId =  loanApps[0].Branch_Master__r?.Business_HUB__c;
        
        if(branchMasterId == null){
            return null;
        }
        String agentIdtoLook = '%' + agentId + '%';
        List<Contact> contacts = [SELECT Id,Name,Agent_Code__c,MobilePhone FROM Contact Where AccountId =: branchMasterId AND Type__c = 'RTO Agent' AND Agent_Code__c =: agentId Order by Createddate desc];
        if(contacts.isEmpty()){
            contacts =  [SELECT Id,Name,Agent_Code__c,MobilePhone FROM Contact Where AccountId =: businessHubId AND Type__c = 'RTO Agent' AND Agent_Code__c =: agentId order by Createddate desc];
            return contacts.isEmpty() ? null : contacts[0];
        }else{
            return contacts.isEmpty() ? null : contacts[0];
        }
    }
    
    /*    @future(callout=true)
public static void sendVehicleDatatoCBS(String loanId){
if(String.isBlank(loanId)){
return ;
}
String serializedResponse = CollateralModificationAPIController.callCollateralModificationCallout(loanId,'pddMaker');
CollateralModificationAPIHandler.CollateralModificationResponseWrapper response = (CollateralModificationAPIHandler.CollateralModificationResponseWrapper) JSON.deserialize(serializedResponse,CollateralModificationAPIHandler.CollateralModificationResponseWrapper.class);
} */
    
    @AuraEnabled
    public static String reSubmitRecord(String loanId, String assignmentId){
        Loan_Application__c loanObj = [SELECT Id, OwnerId FROM Loan_Application__c WHERE Id=:loanId];
        try{
            List<Assignment__c> assignDisbursementObj = [SELECT Id,Status__c,RecordType.Name,Loan_Application__c FROM Assignment__c 
                                                         WHERE RecordType.Name='Ops - Disbursement' AND Status__c='Pending' AND Loan_Application__c=:loanId];
            List<Assignment__c> assignObjRecs = [SELECT RecordType.Name FROM Assignment__c WHERE Id=:assignmentId];
            if(!assignObjRecs.isEmpty()){
                assignObjRecs[0].Status__c = 'Complete';
                update assignObjRecs[0];
                //Notification added
                NotificationHandler.sendNotification('PDD COMPLETION',loanId,'');
            }
            else{
                OpsAssignementUtility.doOpsAssignment(loanObj,'Ops - PDD','Ops Author');
            }
            
            return 'Success: Record submitted successfully';
        }
        catch(Exception e){
            return 'Error '+e.getMessage();
        }
    }

    @AuraEnabled
    public static Boolean updateReportOnRc(String loanId){
        try {
                List<Document_Checklist__c> vahaanRecords = [SELECT Id FROM Document_Checklist__c Where Document_Master__r.Document_Name__c = 'Vahaan Master' AND Loan_Application__c =: loanId];
                List<ContentVersion> cvList = [Select Id,contentDocumentId,VersionData From ContentVersion WHERE FirstPublishLocationId =: vahaanRecords[0].Id and Title = 'Vahaan Report'];
                List<Document_Checklist__c> rcDoc = [SELECT Id FROM Document_Checklist__c Where Document_Master__r.Document_Name__c = 'RC Copy (Registration Certificate)' AND Collateral__r.Is_Deleted__c = false AND Collateral__r.Loan__c =: loanId AND Collateral__r.RecordTypeId IN: GlobalConstants.colRecordTypeIds]; 
                if(cvList.isEmpty()){
                    return false;
                }
                ContentVersion cv = new ContentVersion();
                cv.VersionData =cvList[0].VersionData;
                cv.Title = 'Vahaan Report';
                cv.PathOnClient = '.pdf';
                if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
                }
                if (cv.Id == null || rcDoc.isEmpty()) { return false; }
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id =: cv.Id
                ].ContentDocumentId;
                cdl.LinkedEntityId = rcDoc[0].Id;
                // ShareType is either 'V', 'C', or 'I'
                // V = Viewer, C = Collaborator, I = Inferred
                cdl.ShareType = 'V';
                if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert cdl;
                }
                return true;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
    }
    
    @AuraEnabled
    public static String getRecordInfo(String id){
        String query = 'SELECT Loan_Application__c FROM Assignment__c WHERE Id=:id';
        sObject record = Database.query(query);
        return (Id)record.get('Loan_Application__c');
    }
    
    public static void sendNotification(String loanAppId, String phone){
        //NotificationHandler.sendNotification('RTO Agent Trigger',loanAppId,phone,'');
        NotificationHandler.sendNotification('RTO Agent Trigger',loanAppId,phone);
    }
    
    public class PDDMakerWrapper{
        
        public String loanAppId;
        public  String vehicleDelivery;
        public  String caseDeferral;
        public  String deferralCategory;
        public  String invoiceStatus;
        public  String invoiceNumber;
        public  Date invoiceDate;
        public  Decimal invoiceAmount;
        public  String hpnInvoice;
        public  String chasisNumber;
public String serialNoImplement; // Tractor Implement Serial No.
        public String originalNocStatus; // CE NOC Requirement
        public String financierName; // CE NOC Requirement
        public  String taxReceiptStatus;
        public String assignmentCase;
        public Decimal exShowRoomPrice;
        public Boolean deviationNeeded;
        public Decimal deviationAmount;
        public  String insuranceStatus;
        public  String insuranceNumber;
        public  Date insuranceStartDate;
        public  Date insuranceEndDate;
        public  String insuranceIDV;
        public  String hpnInsurance;
        public  String ownershipInsurance;
        public  String insuranceAgentName;
        public  String insuranceCompanyName;
        public  String thirdPartyInsurance;
        public  String insuranceType;
        public  String insuranceEndorsement;
        public  String insuranceDoneBy;
        public  String premium;
        
        public  String recieptNo;
        public  Decimal receiptAmount;
        public  String engineNo;
        public  String tempVehicleNo;
        public  String rCStatus;
        public String subStatus;//R2-879
        public String rcType;
        public  String registrationNumber;
        public  String registrationDate;
        public  String hpnOnRC;
        public  String ownershipTransferOnRC;
        public  String sourcingDetail;
        public  Boolean isUsedOrCOW = false;
        public String originalRCValue;
        public Boolean updatedEngine;
        public Boolean updatedChasis;
        public List<LOSDocumentManagerController.DocumentCheckListRecord> docChkRecords;
        public DeferralRegisterWrapper deferralRegister;
        
        // ops PDD Maker
        public String product;
// Product code addition for Product biforcation
        public String productCode;
        // Product code addition for Product biforcation
        public String dealerName;
        public String loanNumber;
        public String customerName;
        public Decimal loanAmount;
        public Decimal assetCost;
        public String loanType;
        public String loanSubType;
        public String manufacturingYear;
        public String maker;
        public String model;

        /*5598 Wrapper data*/
        public String fatherNameVahaan;
        public String registrationCityVahaan;
        
        public VahaanWrapper vahanData;
        
        
        
        public PDDMakerWrapper(){}
        
        public PDDMakerWrapper(Collateral__c collateral, Insurance_Details__c insuranceDetail){
            this.vehicleDelivery = collateral.Vehicle_Delivery__c;
            //this.caseDeferral = String.isNotBlank(collateral.HPN_With_Financiers_Name__c) && collateral.HPN_With_Financiers_Name__c?.containsIgnoreCase('AU') ? 'Yes' : 'No';
            // SFAU-5711 - Deffral Issue
            //this.caseDeferral = String.isNotBlank(collateral.HPN_With_Financiers_Name__c) && collateral.HPN_With_Financiers_Name__c?.containsIgnoreCase('AU') ? 'No' : 'Yes';
            this.caseDeferral = (collateral.RC_is_on_name_of_Applicant__c == 'Yes' && String.isNotBlank(collateral.HPN_With_Financiers_Name__c) && collateral.HPN_With_Financiers_Name__c.containsIgnoreCase('AU') && collateral.HPN_With_Financiers_Name__c.startsWith('AU')  ? 'No' : 'Yes');
            this.invoiceStatus = collateral.Invoice_Status__c ;
            this.taxReceiptStatus = collateral.Tax_Receipt_Status__c;
            this.assignmentCase = collateral.Assignment_Case__c;
            this.exShowRoomPrice = collateral.Ex_Showroom_Price__c;
            this.deferralCategory = collateral.Deferral_Category__c;
            this.invoiceNumber = collateral.Invoice_Number__c;
            this.invoiceDate =  collateral.Invoice_Date__c; 
            this.invoiceAmount = collateral.Invoice_Amount__c;
            this.hpnInvoice = collateral.HPN_On_Invoice__c;
            this.engineNo = collateral.Engine_Number__c;
            this.chasisNumber = collateral.Chasis_Number__c;
            this.serialNoImplement = collateral.PDD_Implement_Serial_No__c; // Tractor Serial No Implement
            this.originalNocStatus = collateral.PDD_Original_NOC_Status__c ; // CE NOC Requirement
            this.financierName = collateral.PDD_Original_NOC_Status__c ; // CE NOC Requirement
            this.recieptNo = collateral.Receipt_No__c;
            this.receiptAmount = collateral.Receipt_Amount__c;
            this.tempVehicleNo = collateral.Temp_Vehicle_No__c;
            this.rCStatus = collateral.RC_Status__c;
            this.subStatus = collateral.Sub_Status__c;//R2-879
            this.rcType = collateral.RC_Type__c;
            this.registrationNumber = collateral.Vehicle_Number__c;
            this.registrationDate =  collateral.Registration_Date__c != null ? String.valueOf(collateral.Registration_Date__c) : '';
            this.hpnOnRC = collateral.HPN_On_RC__c;
            this.ownershipTransferOnRC = collateral.Ownership_Transfer_On_RC__c;
            this.sourcingDetail = collateral.Loan__r.Sourcing_channel__c;
            this.originalRCValue = collateral.Original_RC_Details__c;
            
            if(String.isNotBlank(this.originalRCValue)){
                Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(this.originalRCValue);
                this.updatedEngine = this.engineNo == (String) obj.get('Engine No') ? false : true;
                this.updatedChasis = this.engineNo == (String) obj.get('Chassis No') ? false : true;
            }
            
            this.insuranceStatus = insuranceDetail.Insurance_Status__c;
            this.insuranceNumber = insuranceDetail.Insurance_Policy_Number__c;
            this.insuranceStartDate =  insuranceDetail.Insurance_Start_Date__c;
            this.insuranceEndDate = insuranceDetail.Insurance_End_Date__c;
            this.insuranceIDV = insuranceDetail.Insurance_IDV__c;
            this.hpnInsurance = insuranceDetail.HPN_On_Insurance__c;
            this.ownershipInsurance = insuranceDetail.Ownership_Insurance__c;
            this.insuranceAgentName = insuranceDetail.Insurance_Agent_Name__c;
            this.insuranceCompanyName = insuranceDetail.Insurance_Company_Name__c;
            this.thirdPartyInsurance = insuranceDetail.Third_Party_Insurance__c;
            this.insuranceType = insuranceDetail.Insurance_Type__c;
            this.insuranceEndorsement = insuranceDetail.Insurance_Endorsement__c;
            this.insuranceDoneBy = insuranceDetail.Insurance_Done_By__c;
            this.premium = insuranceDetail.Premium__c;
            
            String product = AUSFVehicleHelper.getPicklistLabel(collateral.Loan__r.Product__c);
            this.isUsedOrCOW =  String.isNotBlank(product) &&
                (product.ContainsIgnoreCase('Used') || (System.Label.AUSFCowScreen.toUpperCase().contains(product.toUpperCase()))); //R2-2634
            
            // ops PDD Maker
            this.product = product;
            this.productCode = collateral.Loan__r.Product__c;
            this.dealerName = collateral.Loan__r.Dealer_Master__r.Name;
            this.loanNumber = collateral.Loan__r.Name;
            this.customerName =collateral.Loan__r.Name_of_Customer__c ;
            this.loanAmount = collateral.Loan__r.Total_Loan_Amount__c;
            this.assetCost = collateral.Final_Cost__c;
            this.loanType = this.isUsedOrCOW ? 'Used/Cow' : 'New';
            this.loanSubType = collateral.Collateral_Name__c;
            this.manufacturingYear = collateral.Manufacture_year_month__c != null ? collateral.Manufacture_year_month__c.subString(0,4) : '';
            this.maker  = collateral.Make__c;
            this.model = collateral.Model__c;

            /*5598 Wrapper data*/
            this.fatherNameVahaan = String.isNotBlank(collateral.Father_s_Name__c)? collateral.Father_s_Name__c : '';
            this.registrationCityVahaan = String.isNotBlank(collateral.Registration_City__c)? collateral.Registration_City__c : '';

            
        }
        
    }
    
    public class VahaanWrapper{
        public String hpnFinancer;
        public String currentOwnerName;
        public String ownerSerialNumber;
        public String registrationCity;
        public String engineNo;
        public String chasisNumber;
        public String registrationNumber;
        
        public VahaanWrapper(){}
    }
    
    public class DeferralRegisterWrapper{
        public  String recordId;
        public String collateralId;
        public  Date originalDocumentDate;
        public  String documentHandoverto;
        public  String rtoAgentName;
        public  String rtoAgentID;
        public  String rtoAgentNumber;
        public  Date documentHandedOverDate;
        public  String confirmationRecieved;
        public  Date confirmationRecievedDate;
        public  String status;
        public  Date commitmentDate;
        public  String remarks;
        
        public DeferralRegisterWrapper(){}
        
        public DeferralRegisterWrapper(Deferral_Register__c deferralRegister){
            this.originalDocumentDate = deferralRegister.Original_Doc_Collected_Date__c;
            this.documentHandoverto = deferralRegister.Document_Handed_Over_to__c;
            this.rtoAgentName = deferralRegister.Agent_Name__c;
            this.rtoAgentID = deferralRegister.Agent_Id__c;
            this.rtoAgentNumber = deferralRegister.Agent_No__c;
            this.documentHandedOverDate = deferralRegister.Document_Handed_Over_date__c;
            this.confirmationRecieved = deferralRegister.Confirmation_Recieved__c;
            this.confirmationRecievedDate = deferralRegister.Confirmation_Recieved_Date__c;
            this.status = deferralRegister.Status__c;
            this.commitmentDate = deferralRegister.Commitment_Date__c;
            this.remarks = deferralRegister.Remark__c;
            this.recordId = deferralRegister.Id;
        }
    }
    
    public class ResponseListWrapper{
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String docName{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String downloadurl{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String contentDocId{get;set;}
        @AuraEnabled
        public String contentVerId{get;set;}
    }
    
    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        
        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }
    
}