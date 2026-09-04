/*******************************************************************************************
 * @Name         NotificationHandler
 * @Author       Yash Shukla
 * @Description   Controller class for Ops SUmmary Page
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Yash Shukla        04/02/2023         Initial Creation
 *  2.0				Yash Shukla		   24/07/2023		  Deal Approved By comdition added for 2 Wheeler
 *******************************************************************************************/
public with sharing class OpsSummaryPageController {


    private static Set<String> opsSummaryHeader = new Set<String>{'isCaseSummaryVerified','isAssetDetailsVerified','isSourcingVerified'};
    @AuraEnabled
    public static SummaryPageWrapperController.OpsCaseCategory getOpsCategoryDetails(String applicationId) {
        SummaryPageWrapperController.OpsCaseCategory opsWrapper = new SummaryPageWrapperController.OpsCaseCategory();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Application_Id__c	, Branch_Master__c, Branch_Master__r.Name, ROI__c, Ops_Output__c,Discrepancy_Count__c,
                                                           Branch_Master__r.Business_HUB__r.Name, Total_Loan_Amount__c, Interest_Start_Date__c, BRE_Approval_Level__c, RecordType.Name,
                                                           Branch_Master__r.State__r.Name, Credit_Approval_Date__c, Total_Charges__c,
                                                           (SELECT Id, Assigned_RPC__c, RecordType.Name FROM Document_Tracker__r WHERE RecordType.Name = 'Physical File Tracker' LIMIT 1),
                                                           (SELECT Id,DO_Generation_Date__c,RecordTypeId, RecordType.Name FROM Collaterals__r WHERE (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels') AND Is_Deleted__c = false),
                                                           (SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Father_Name__c,Spouse_Name__c,
                                                            Customer_Grade__c, Residential_Status__c from Applicants__r WHERE RecordType.Name = 'Applicant')
                                                           FROM Loan_Application__c WHERE Id = :applicationId LIMIT 1
                                                          ];
            List<Loan_Application_Approval__c > approvalRecords = [SELECT Id, Approver__c, Approver__r.Name, Approver_Level__c, Approval_Type__c, Type__c, Approval_Status__c FROM
                                                                  Loan_Application_Approval__c WHERE Loan_Application__c =:applicationId
                                                                  AND Approval_Type__c IN ('Credit')];
            if(!applicationRecord.isEmpty()){
                system.debug('value '+applicationRecord[0].Document_Tracker__r);
                opsWrapper = setOpsCategoryWrapper(applicationRecord[0],approvalRecords);

            }
        }catch(Exception ex) {
            system.debug('yash ex'+ex.getMessage());
        }
        return opsWrapper;
    }

    private static SummaryPageWrapperController.OpsCaseCategory setOpsCategoryWrapper(Loan_Application__c record, List<Loan_Application_Approval__c > approvalRecord) {
        SummaryPageWrapperController.OpsCaseCategory retWrapper = new SummaryPageWrapperController.OpsCaseCategory();
        retWrapper.applicationId = nullCheckAndSetData(String.valueOf(record.Application_Id__c));
        retWrapper.hub = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.Business_HUB__r.Name));
        retWrapper.state = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.State__r.Name));
        retwrapper.branch = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.Name));
        retWrapper.opsOutput = nullCheckAndSetData(String.valueOf(record.Ops_Output__c));
        if(!record.Collaterals__r.isEmpty()){
            retwrapper.deliveryOrderDate = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].DO_Generation_Date__c));
        }
        //retwrapper.deliveryOrderDate = nullCheckAndSetData(String.valueOf(record.Interest_Start_Date__c));
        retwrapper.irr = nullCheckAndSetData(String.valueOf(record.ROI__c));
        retwrapper.totalCharges = nullCheckAndSetData(String.valueOf(record.Total_Charges__c));
        retwrapper.creditApprovalDate = nullCheckAndSetData(String.valueOf(record.Credit_Approval_Date__c));
        retWrapper.loanAmount = nullCheckAndSetData(String.valueOf(record.Total_Loan_Amount__c));
        retWrapper.irr = nullCheckAndSetData(String.valueOf(record.ROI__c));
        if(!record.Applicants__r.isEmpty()) {
            retWrapper.applicantName = setApplicantName(String.valueOf(record.Applicants__r[0].First_Name__c), String.valueOf(record.Applicants__r[0].Middle_Name__c), String.valueOf(record.Applicants__r[0].Last_Name__c));
            retWrapper.fatherName = nullCheckAndSetData(String.valueOf(record.Applicants__r[0].Father_Name__c));
            retWrapper.spouseName = nullCheckAndSetData(String.valueOf(record.Applicants__r[0].Spouse_Name__c));
        }
        if(!approvalRecord.isEMpty()){
            for(Loan_Application_Approval__c approvalRecs : approvalRecord){
                if(record.RecordType.Name == 'Two Wheeler'){
                    if(approvalRecs.Approver_Level__c == record.BRE_Approval_Level__c || approvalRecs.Approval_Status__c == 'Approved'){
                        retWrapper.dealApprover = nullCheckAndSetData(String.valueOf(approvalRecs.Approver__r.Name));
                        break;
                    }

                }
                else{
                    if(approvalRecs.Type__c == 'Highest'){
                        retWrapper.dealApprover = nullCheckAndSetData(String.valueOf(approvalRecs.Approver__r.Name));
                        break;
                    }
                }
            }
            //retWrapper.dealApprover = nullCheckAndSetData(String.valueOf(approvalRecord[0].Approver__r.Name));
        }
        if(!record.Document_Tracker__r.isEMpty()){
            system.debug('yash '+record.Document_Tracker__r[0]);
            retWrapper.physicalCustodyName = nullCheckAndSetData(String.valueOf(record.Document_Tracker__r[0].Assigned_RPC__c));
        }
        retWrapper.discrepancyCount = record.Discrepancy_Count__c!=null ? record.Discrepancy_Count__c :0; //18 JUl
        return retWrapper;
    }

    @Auraenabled
    public static SummaryPageWrapperController.OpsAssetDetails getOpsAssetDetails(String applicationId) {
        SummaryPageWrapperController.OpsAssetDetails opsWrapper = new SummaryPageWrapperController.OpsAssetDetails();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id,RecordType.Name, Sourcing_channel__c, Total_Loan_Amount__c, Scheme__c, Scheme__r.Name, toLabel(Product__c),
                                                           Tenure__c, ROI__c ,
                                                           Vehicle_use__c, Customer_Type__c, Dealer_Master__c, Dealer_Master__r.Name, Pre_Approved_Flag__c, Campaign__c,
                                                           (SELECT Id, Model__c,Manufacture_year_month__c, Assessment_Method__c, LTV__c, Make__c , Variant__c, Manufacture_Year__c, Vehicle_Number__c, Collateral_Type__c
                                                            FROM Collaterals__r WHERE Is_Deleted__c = false)
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                          ];
            if(!applicationRecord.isEmpty()){
                opsWrapper = setOpsAssetWrapper(applicationRecord[0]);
            }
        }catch(Exception ex) {
            system.debug('exception '+ex.getMessage());

        }
        return opsWrapper;
    }

    private static SummaryPageWrapperController.OpsAssetDetails setOpsAssetWrapper(Loan_Application__c record) {
        system.debug('yash');
        SummaryPageWrapperController.OpsAssetDetails retWrapper = new SummaryPageWrapperController.OpsAssetDetails();
        retWrapper.product = nullCheckAndSetData(String.valueOf(record.Product__c));
        retWrapper.loanType = nullCheckAndSetData(String.valueOf(record.Product__c));

        if(!record.Collaterals__r.isEmpty()) {
            system.debug('here');
            List<Deferral_Register__c> defReg = [SELECT Id, Agent_Name__c, Collateral__c  FROM Deferral_Register__c WHERE Collateral__c=:record.Collaterals__r[0].Id LIMIT 1];
            if(!defReg.isEMpty()){
                retWrapper.defRegister = defReg[0].Agent_Name__c;
            }
            retWrapper.manufacture = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Model__c));
            retWrapper.make = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Make__c));
            retWrapper.vehicleNumber = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Vehicle_Number__c));
            retWrapper.model = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Variant__c));
            retWrapper.year = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Manufacture_year_month__c));
            if(String.isNotBlank(retWrapper.year)){
                retWrapper.year = retWrapper.year.substring(0,4);
            }
            retWrapper.collateralType = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Collateral_Type__c ));
        }
        system.debug('asset info '+retWrapper);
        return retWrapper;
    }

    @AuraEnabled
    public static SummaryPageWrapperController.OpsSourcingDetails getOpsSourcingDetails(String applicationId){
        system.debug('method start');
        SummaryPageWrapperController.OpsSourcingDetails sourcingWrapper =
            new SummaryPageWrapperController.OpsSourcingDetails();
        try {
            if(String.isBlank(applicationId))
            {
                return null;
            }
            List<Applicant__c> applicant = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, RecordType.Name, KYC_Status__c,
                                            Loan__r.BSR_PSL_Status__c,Dob__c, Loan__r.Repayment_Mode__c, Loan__r.OwnerId,
                                            Loan__r.Sourcing_channel__c , Loan__r.Dealer_Master__r.Name, Loan__r.LAN__c,
                                            Loan__r.Owner.Name, Loan__r.Scheme__r.Name, Loan__r.Source_Name__c, Loan__r.Scheme__r.Scheme_Name__c,
                                            Loan__r.Repayment_Bank_Name__c,Loan__r.Esign_Status__c,
                                            (SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c,Source_Type__c,
                                             Pincode__c, Applicant__c, Address_Type__c FROM Addresses__r WHERE Address_Type__c='Current'
                                             AND Address_Type__c != null
                                             AND Source_Type__c != 'Cart'
                                             AND Source_Type__c != 'Cibil')
                                            FROM Applicant__c WHERE Loan__c = :applicationId
                                            AND RecordType.Name ='Applicant'
                                            LIMIT 1]; //AUG 14
            system.debug('data '+applicant.size());
            if(!applicant.isEmpty()) {
                system.debug('test');
                List<Payment__c> paymentRecord = new List<Payment__c>();
                List<User> usrData = new List<User>();
                paymentRecord = [SELECT Id,BT_Type__c ,NOC_before_Disbursement__c, RecordTypeId, RecordType.Name,Loan_Application__c FROM
                                 Payment__c WHERE RecordType.Name = 'Balance Transfer' AND Loan_Application__c = :applicationId LIMIT 1];
                usrData = [SELECT Id, Name, Employee_Id__c FROm User WHERE ID=:applicant[0].Loan__r.OwnerId];
                system.debug('paymentdata '+paymentRecord);
                sourcingWrapper = setOpsSourcingDetails(applicant[0],paymentRecord, usrData[0]);
            }

        } catch (Exception e) {
            system.debug('exception '+e.getMessage()+' '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return sourcingWrapper;
    }

    private static SummaryPageWrapperController.OpsSourcingDetails setOpsSourcingDetails(Applicant__c record, List<Payment__c> balanceTransferData, User usr) {
        system.debug('inside'+balanceTransferData.size());
        SummaryPageWrapperController.OpsSourcingDetails retWrapper = new SummaryPageWrapperController.OpsSourcingDetails();
        retWrapper.sourceChannel = nullCheckAndSetData(String.valueOf(record.Loan__r.Sourcing_channel__c));
        retWrapper.dealerName = nullCheckAndSetData(String.valueOf(record.Loan__r.Dealer_Master__r.Name));
        retWrapper.repaymentMode = nullCheckAndSetData(String.valueOf(record.Loan__r.Repayment_Mode__c));
        retWrapper.psl = nullCheckAndSetData(String.valueOf(record.Loan__r.BSR_PSL_Status__c));
        retWrapper.applicantName = setApplicantName(String.valueOf(record.First_Name__c), String.valueOf(record.Middle_Name__c), String.valueOf(record.Last_Name__c));
        retWrapper.dob = formatDate(record.dob__c);
        if(!record.Addresses__r.isEmpty()){
            retWrapper.applicantAddress = setAddress(record.Addresses__r[0]);
        }
        retWrapper.loanNumber = nullCheckAndSetData(String.valueOf(record.Loan__r.LAN__c));
        retWrapper.kycStatus = nullCheckAndSetData(String.valueOf(record.KYC_Status__c));
        retWrapper.schemeName = nullCheckAndSetData(String.valueOf(record.Loan__r.Scheme__r.Scheme_Name__c));
        retWrapper.roName = nullCheckAndSetData(String.valueOf(record.Loan__r.Owner.Name));
        retWrapper.roCode = nullCheckAndSetData(String.valueOf(usr.Employee_Id__c));
        retWrapper.repaymentBank = nullCheckAndSetData(String.valueOf(record.Loan__r.Repayment_Bank_Name__c));
        if(String.isNotBlank(retWrapper.repaymentMode) && (retWrapper.repaymentMode.contains('NACH')||retWrapper.repaymentMode.contains('E mandate'))){
            retWrapper.nach_si = retWrapper.repaymentMode;
        }
        retWrapper.esignStatus = nullCheckAndSetData(String.valueOf(record.Loan__r.Esign_Status__c));
        retWrapper.sourceName_DealerName = nullCheckAndSetData(String.valueOf(record.Loan__r.Source_Name__c))+'-'+
            nullCheckAndSetData(String.valueOf(record.Loan__r.Dealer_Master__r.Name));
        if(!balanceTransferData.isEMpty()){
            retWrapper.balanceTransfer = nullCheckAndSetData(String.valueOf(balanceTransferData[0].BT_Type__c));
            if(String.isNotBlank(balanceTransferData[0].BT_Type__c) && balanceTransferData[0].BT_Type__c=='External'){
                retWrapper.renderBTNOCStatus = true;
                retWrapper.exteralNOCStatusBT = balanceTransferData[0].NOC_before_Disbursement__c;
            }
        }
        system.debug('i am here');

        return retWrapper;
    }

    private static String formatDate(Date dt){
        String formattedDate = '';
        if(String.isNotBlank(STring.valueOf(dt))){
            formattedDate = DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day()).format('dd/MM/yyyy');
        }
        return formattedDate;
    }

    private static String setApplicantName(String firstName, String middleName, String lastName) {
        return ((String.isBlank(firstName) ? '' : firstName+' ') +(String.isBlank(middleName) ? '' : middleName+' ')+(String.isBlank(lastName) ? '' : lastName+' '));
    }

    private static String setAddress(Address__c addressRecord) {
        String streetName = nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_1__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_2__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_3__c));
        String city = nullCheckAndSetData(String.valueOf(addressRecord.City__c));
        String state = nullCheckAndSetData(String.valueOf(addressRecord.State__c));
        String pincode = nullCheckAndSetData(String.valueOf(addressRecord.Pincode__c));
        return streetName+' '+city+' '+state+' '+pincode;
    }

    private static String nullCheckAndSetData(String dataValue) {
        return (String.isBlank(dataValue)? ' ' : dataValue);
    }

    @AuraEnabled
    public static String getAssignmentRecordLoanId(String assignmentId) {
        try{
            List<Assignment__c> assignmentRecord = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:assignmentId WITH SECURITY_ENFORCED LIMIT 1];
            if(String.isNotBlank(assignmentRecord[0].Loan_Application__c)){
                return assignmentRecord[0].Loan_Application__c;
            }
            else{
                return '';
            }
        }catch(Exception ex){
            return '';
        }
    }

    @AuraENabled
    public static String setVerificationWrapper(String recId){
        try{
            String retWrapper = '';
            Id recordId = (Id)recId;
            String objName = recordId.getSObjectType().getDescribe().getName();
            if(objName == 'Loan_Application__c'){
                system.debug('loan application');
                List<Loan_Application__c> application = [SELECT Id, Ops_Verification__c FROM Loan_Application__c WHERE Id=:recId];
                system.debug('test '+application[0].Ops_Verification__c);
                retWrapper = (String.isNotBlank(application[0].Ops_Verification__c))?application[0].Ops_Verification__c: JSON.serialize(new OpsVerificationController.OpsBaseVerificationWrapper());
            }
            else if(objName == 'Assignment__c'){
                List<Assignment__c> assignment = [SELECT Id, Loan_Application__c, Loan_Application__r.Ops_Verification__c FROM Assignment__c
                                                 WHERE Id=:recId];
                retWrapper = (String.isNotBlank(assignment[0].Loan_Application__r.Ops_Verification__c))?assignment[0].Loan_Application__r.Ops_Verification__c: JSON.serialize(new OpsVerificationController.OpsBaseVerificationWrapper());
            }
            system.debug('wrapper '+retWrapper);
            return retWrapper;

        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void verifyRecordSection(String sectionName, String recordId){
        try{
            OpsVerificationController.OpsBaseVerificationWrapper retWrapper = new OpsVerificationController.OpsBaseVerificationWrapper();
            Map<String, Boolean> verificationMap = new Map<String, Boolean>();
            List<Loan_Application__c> application = [SELECT Id, Ops_Verification__c FROM  Loan_Application__c WHERE Id=:recordId LIMIT 1];
            if(String.isNotBlank(application[0].Ops_Verification__c)){
                retWrapper = (OpsVerificationController.OpsBaseVerificationWrapper)JSON.deserialize(application[0].Ops_Verification__c, OpsVerificationController.OpsBaseVerificationWrapper.class);
            }
            for(String str : opsSummaryHeader){
                if(sectionName == str){
                    if(str == 'isCaseSummaryVerified'){
                        retWrapper.isCaseSummaryVerified = true;
                    }
                    else if(str == 'isAssetDetailsVerified'){
                        retWrapper.isAssetDetailsVerified = true;
                    }
                    else{
                        retWrapper.isSourcingVerified = true;
                    }

                }

            }
            application[0].Ops_Verification__c = JSON.serializePretty(retWrapper,false);
            update application;


        }catch(Exception ex){
            system.debug('string '+ex.getStackTraceString());
            throw new AurahandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static String getValidRecordId(String assignmentId) {
        try{
            Id recId = (Id)assignmentId;
            String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Assignment__c'){
                List<Assignment__c> assignmentRec = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:assignmentId];
                assignmentId = assignmentRec[0].Loan_Application__c;
            }
            return assignmentId;

        }catch(Exception ex){
            return '';
        }
    }


}