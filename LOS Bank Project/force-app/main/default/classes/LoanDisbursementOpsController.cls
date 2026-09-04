/*******************************************************************************************
* @Name         LoanDisbursementOpsController
* @Author       Yash Shukla
* @Description   Payment Beneficial SCreen Controller
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        21/12/2023         SFAU-5774

*******************************************************************************************/
public without sharing class LoanDisbursementOpsController {
    
    @AuraEnabled
    public static LoanDetailsWrapper getLoanDetails(String loanAppId){
        LoanDetailsWrapper loanDetails = new LoanDetailsWrapper();
        List<Loan_Application__c> loanApps = [SELECT Id, Name, RecordTypeId, Collateral_Type__c, is_BSR_PSL_API_successful__c, Product__c, Emi_Frequency__c, Disbursement_Category__c, Narration__c, First_EMI_Date__c,
            Disbursement_Date__c, Total_Loan_Amount__c, Mode_of_Disbursement__c, Schedule_Code__c, Schedule_Name__c, DPD_Found__c, Esign_Type__c,
            ROI__c, EMI_Date__c, Schedule_Type__c, Stage__c, Total_Charges__c, Application_Id__c, Completed_Disbursement_Stage__c,
            Disbursed_Tranche__c, General_Ledger__c, OwnerId, RecordType.DeveloperName, LAN__c, is_Collateral_Linkage_Successful__c, is_Collateral_Creation_Successful__c, 
            (SELECT Id, Customer_Name__c FROM Applicants__r WHERE RecordType.DeveloperName='Primary_Applicant' AND IsInactive__c=false),
            (SELECT Id, Payment_Mode__c, Tranche__r.Inactive__c,Margin_Money_Action__c,Payment_Recipient__c FROM Payments__r WHERE RecordType.DeveloperName='Payment_Favouring' AND Inactive__c=false AND (Tranche__c=null OR Tranche__r.Inactive__c = true))// Inactive check Added for Tranche
            FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];

        if(loanApps!=null && loanApps.size()>0){ 
        List<Address__c> addressList = [SELECT Id, State__c from Address__c WHERE Address_Type__c='Current' AND (Source_Type__c=null OR  Source_Type__c = 'CBS') AND Applicant__c=:loanApps[0].Applicants__r[0].Id];
        loanDetails.stateMappings=new List<State_wise_Mapping__mdt>();
        if(addressList!=null && addressList.size()>0){
            loanDetails.stateMappings = [SELECT State__c,Two_Wheeler_EMI_Date__c,Four_Wheeler_EMI_Date__c,Tractor__c, HCV_LCV_ICV_CE_EMI_Date__c, SCV_CarTaxi_3W_EMI_Date__c FROM State_wise_Mapping__mdt where state__c=:addressList[0].State__c];

        }
        loanDetails.relatedApplicants = [SELECT Id, is_BSR_PSL_API_successful__c FROM Applicant__c WHERE Loan__c =: loanApps[0].Id
                    AND RecordType.DeveloperName != 'Additional_Match'
                    AND RecordType.DeveloperName != 'Nominee' 
                    AND IsInactive__c=false
                    WITH SECURITY_ENFORCED];       
    
        loanDetails.ranges = [SELECT Product_Id__c,Min_Tenure__c,Min_ROI_Value__c,Min_Loan_Value__c,Max_Tenure__c,
            Max_ROI_Value__c,Max_Loan_Value__c FROM Product_vs_Range_Mapping__mdt WHERE Product_Id__c =:loanApps[0].Product__c WITH SECURITY_ENFORCED LIMIT 1];

        List<Generic_Master__c> genericMasterRecords = [SELECT Product__c, Id, Rate_Type__c, Name__c, VPI_or_EPI__c, 
            Schedule_Code__c, Interest_Frequency__c, RecordType.DeveloperName FROM Generic_Master__c WHERE 
            RecordType.DeveloperName = 'EMI_Schedule' AND 
            Product__c=:loanApps[0].Product__c AND Schedule_Code__c=:loanApps[0].Schedule_Code__c WITH SECURITY_ENFORCED];

            List<String> tempList = new List<String>();
            loanDetails.scheduleNames = new List<GLWrapper>();
            for(Generic_Master__c schedule: genericMasterRecords){
                if(!tempList.contains(schedule.Name__c)){
                    loanDetails.scheduleNames.add(new GLWrapper(schedule.Name__c, schedule.Name__c));
                    tempList.add(schedule.Name__c);
                }
            }

            Loan_Application__c currentLoan = loanApps[0];
            loanDetails.loanApp = currentLoan;
            if(currentLoan.Payments__r!=null && currentLoan.Payments__r.size()>0){
                if(currentLoan.Payments__r.size()==1){
                    if(currentLoan.Payments__r[0].Payment_Mode__c == 'TA'){
                        loanDetails.glValues = handleSinglePaymentGLValues(currentLoan.Payments__r[0], currentLoan.Product__c, true);
                    }else{
                        loanDetails.glValues = handleSinglePaymentGLValues(currentLoan.Payments__r[0], currentLoan.Product__c, false);
                    }
                }else{
                    List<Payment__c> paymentFavourings = currentLoan.Payments__r;
                    Integer count=0;
                    for(Payment__c payFav: paymentFavourings){
                        if(payFav.Payment_Mode__c!='TA'){
                            count++;
                        }
                    }
                    if(count==0){
                        loanDetails.glValues = handleSinglePaymentGLValues(currentLoan.Payments__r[0], currentLoan.Product__c, true);
                    }else{
                        loanDetails.glValues = handleSinglePaymentGLValues(currentLoan.Payments__r[0], currentLoan.Product__c, false);
                    }
                }
            }
            return loanDetails;
        }else{
            return null;
        }
    }

    public class LoanDetailsWrapper{
        @AuraEnabled public Loan_Application__c loanApp{get;set;}
        @AuraEnabled public Product_vs_Range_Mapping__mdt ranges{get;set;}
        @AuraEnabled public List<GLWrapper> scheduleNames{get;set;}
        @AuraEnabled public List<GLWrapper> glValues{get;set;}
        @AuraEnabled public List<State_wise_Mapping__mdt> stateMappings{get;set;}
        @AuraEnabled public List<Applicant__c> relatedApplicants{get;set;}
    }

    public class TrancheDetailsWrapper{
        @AuraEnabled public Payment__c tranche{get;set;}
        @AuraEnabled public List<GLWrapper> glValues{get;set;}
    }

    public class GLWrapper{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        public GLWrapper(String labelForGL, String valueForGL){
            label = labelForGL;
            value = valueForGL;
        }
    }

    public static List<GLWrapper> handleSinglePaymentGLValues(Payment__c payFav, String loanProductCode, Boolean isTA){
        List<String> glValues = new List<String>();
        String glMasterValues;
        String productCode = GlobalConstants.PREFIXPRODRTMAP+loanProductCode;
        List<GLWrapper> glList = new List<GLWrapper>();
        if(isTA){
            glMasterValues = General_Ledger_Master__mdt.getInstance(productCode).TA__c;
        }else{
            glMasterValues = General_Ledger_Master__mdt.getInstance(productCode).NON_TA__c;
        }
        if(glMasterValues.contains(',')){
            glValues = glMasterValues.split(',');
        }else{
            glValues.add(glMasterValues);
        } 
        for(String gl: glValues){
            glList.add(new GLWrapper(gl,gl));
        }
        return glList;
    }

    @AuraEnabled
    public static String getUserDetails(){
        List<User> currentUser = [SELECT Id, Profile.Name, Ops_User_Type__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(currentUser!=null && currentUser.size()>0){
            String userType;
            if(currentUser[0].Profile.Name == 'System Administrator'){
                userType='Admin';
            }else if(currentUser[0].Ops_User_Type__c == 'Ops Maker'){
                userType='Ops Maker';
            }else if(currentUser[0].Ops_User_Type__c == 'Ops Author'){
                userType='Ops Author';
            }
            return userType;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static String getRepaymentSchedule(String recordId, String apiName, Decimal netDisbursementAmount){
        List<Loan_Application__c> loanApps = [SELECT Id, Tenure__c, Product__c, First_EMI_Date__c, Schedule_Name__c, Type_of_Rate__c, Rate_Chart_Code__c, Schedule_Code__c,
        ROI__c, Loan_Amount__c, Branch_Master__r.Account_Code__c, Disbursement_Session_Id__c, Schedule_Type__c, EMI_Frequency__c, 
        EMI_Date__c, LAN__c, Disbursement_Date__c, Total_Loan_Amount__c FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
        if(loanApps!=null && loanApps.size()>0){
            String refId;
            if(apiName == 'Disbursement Schedule'){
                refId = EMIScheduleAPIController.callEMIScheduleAPI(loanApps[0], 'DisbursementOpsMaker', netDisbursementAmount);
            }
            if(apiName == 'EMI Schedule'){
                refId = EMIScheduleAPIController.callEMIScheduleAPI(loanApps[0],'', netDisbursementAmount);
            }
            return refId;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static TrancheDetailsWrapper getTrancheDetails(Id recordId, Integer trancheNumber){
        TrancheDetailsWrapper tranchDetails = new TrancheDetailsWrapper();
        List<Payment__c> trancheList = [SELECT Id, Name, RecordTypeId, Tranche_Status__c, Disbursement_Amount__c, 
        Partial_Payment_Condition__c, Tranche_Number__c, Loan_Application__c, Loan_Application__r.Product__c,
        (SELECT Id, Payment_Mode__c,Margin_Money_Action__c,Payment_Recipient__c FROM Payments__r WHERE RecordType.DeveloperName='Payment_Favouring' AND Inactive__c=false)
        FROM Payment__c WHERE Loan_Application__c=:recordId AND RecordType.DeveloperName='Tranche' AND 
        Inactive__c=false AND Tranche_Number__c=:trancheNumber WITH SECURITY_ENFORCED];

        if(trancheList !=null && trancheList.size()>0){
            Payment__c currentTranche = trancheList[0];
            tranchDetails.tranche = currentTranche;
            if(currentTranche.Payments__r!=null && currentTranche.Payments__r.size()>0){
                if(currentTranche.Payments__r.size()==1){
                    if(currentTranche.Payments__r[0].Payment_Mode__c == 'TA'){
                        tranchDetails.glValues = handleSinglePaymentGLValues(currentTranche.Payments__r[0], currentTranche.Loan_Application__r.Product__c, true);
                    }else{
                        tranchDetails.glValues = handleSinglePaymentGLValues(currentTranche.Payments__r[0], currentTranche.Loan_Application__r.Product__c, false);
                    }
                }else{
                    List<Payment__c> paymentFavourings = currentTranche.Payments__r;
                    Integer count=0;
                    for(Payment__c payFav: paymentFavourings){
                        if(payFav.Payment_Mode__c!='TA'){
                            count++;
                        }
                    }
                    if(count==0){
                        tranchDetails.glValues = handleSinglePaymentGLValues(currentTranche.Payments__r[0], currentTranche.Loan_Application__r.Product__c, true);
                    }else{
                        tranchDetails.glValues = handleSinglePaymentGLValues(currentTranche.Payments__r[0], currentTranche.Loan_Application__r.Product__c, false);
                    }
                }
            }

        }  

        return tranchDetails;
    }


    @AuraEnabled
    public static List<Payment__c> getPaymentFavourings(Id recordId){
        List<Payment__c> payments;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Payment__c'){
            payments = [SELECT Id, name, RecordTypeId, Payment_Recipient__c,is_Validated_By_Author__c, UTR_Number__c, Account_Number__c, Name__c, Account_Type__c,  Net_Amount__c, Payment_Favouring_Status__c, 
                Tranche_Status__c, Tranche_Number__c, Tranche__r.Disbursement_Amount__c, is_Payment_Favouring_Modified__c, Is_Payment_Triggered__c,
                Tranche__r.Loan_Application__r.Total_Charges__c, Disbursed__c, Payment_Mode__c,Margin_Money_Action__c, Loan_Application__r.is_Pool_Disbursement_Successful__c,
                Bank_Name_PMT__c, IFSC_Code__c, Beneficiary_Name__c, Loan_Application__c, Loan_Application__r.LAN__c,Is_Pool_Disbursement_Successful__c,Is_Cheque_Pool_Disburse_Successful__c from Payment__c WHERE 
                Tranche__c!=null AND Tranche__c=:recordId AND 
                Inactive__c=false WITH SECURITY_ENFORCED];
            return payments;
        }else if(sObjName == 'Loan_Application__c'){
            payments = [SELECT Id, name, RecordTypeId, Account_Number__c, is_Validated_By_Author__c, UTR_Number__c, Net_Amount__c, Name__c, Payment_Recipient__c, Account_Type__c, Payment_Favouring_Status__c,
                Tranche_Status__c, Tranche_Number__c, Tranche__r.Disbursement_Amount__c, is_Payment_Favouring_Modified__c, Loan_Application__r.is_Pool_Disbursement_Successful__c,
                Tranche__r.Loan_Application__r.Total_Charges__c, Disbursed__c, Payment_Mode__c,Margin_Money_Action__c, Is_Payment_Triggered__c,
                Bank_Name_PMT__c, IFSC_Code__c, Beneficiary_Name__c, Loan_Application__c, Loan_Application__r.LAN__c,Is_Pool_Disbursement_Successful__c,Is_Cheque_Pool_Disburse_Successful__c, Tranche__r.Inactive__c
                from Payment__c WHERE 
                (Tranche__c=null OR Tranche__r.Inactive__c = true) AND Loan_Application__c=:recordId AND // 5774 Inactive Tranche Check Added
                Inactive__c=false AND RecordType.DeveloperName='Payment_Favouring' WITH SECURITY_ENFORCED];
            return payments;
        }else{
            return null;
        }
        
    }

    @AuraEnabled
    public static void updatePaymentParent(Id recordId, Id loanAppId){
        try {
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Payment__c'){

                Payment__c payment = [SELECT Id, Tranche_Number__c, Disbursed__c FROM Payment__c WHERE Id=:recordId];
                payment.Disbursed__c = true;
                if (Schema.sObjectType.Payment__c.isUpdateable()) {
                    update payment;
                }
                generateWelcomeLetter(loanAppId, 'Tranche_Disbursement_'+payment.Tranche_Number__c+'_Welcome_Letter');
            }else if(sObjName == 'Loan_Application__c'){
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id = recordId;
                loan.Is_Loan_Disbursed__c = true;
                if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
                    update loan;
                }
                
                generateWelcomeLetter(loanAppId, 'Loan_Disbursement_Welcome_Letter');

            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void generateWelcomeLetter(Id loanAppId, String title){
        
        PageReference pdf = new pagereference('/apex/WelcomeLetterPDFPage?applicationId='+loanAppId);
        pdf.getParameters().put('id', loanAppId);
        Blob body;
        try {
            // returns page as a PDF
            if(Test.isRunningTest()){
                body = Blob.valueOf('Some Content');
            }else{
                body = pdf.getContent();
            }
        }catch(Exception e){

        }
        List<Loan_Application__c> loanApp = [SELECT Id, Product__c,(SELECT Id FROM Document_Checklists__r WHERE Document_Master__r.Document_Name__c='Welcome Letter') FROM Loan_Application__c WHERE Id=:loanAppId];             
        ContentVersion cv = new ContentVersion();
        cv.VersionData = body;
        cv.Title = title+'.pdf';
        cv.PathOnClient = title+'.pdf';
        cv.isActive__c=true;
        if(SObjectType.ContentVersion.isCreateable() && SObjectType.ContentVersion.isUpdateable()){
            insert cv;
            if(loanApp[0].Document_Checklists__r!=null && loanApp[0].Document_Checklists__r.size()>0){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
                cdl.LinkedEntityId = loanApp[0].Document_Checklists__r[0].Id;
                if(SObjectType.ContentDocumentLink.isCreateable()){
                    insert cdl; 
                }else{
                    throw new AuraHandledException('Object Access Denied');
                }
            }
            ContentVersion lastestRecord = [SELECT Id, Shortend_Public_Url__c, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id];
            insert new ContentDistribution(
                    Name = cv.Title,
                    ContentVersionId = cv.Id,
                    PreferencesAllowViewInBrowser = true
                );
            List<ContentDistribution> contentDistributionList = [SELECT DistributionPublicUrl
                                                            FROM ContentDistribution
                                                            WHERE ContentDocumentId = :lastestRecord.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
            lastestRecord.Shortend_Public_Url__c = contentDistributionList[0].DistributionPublicUrl;
            update lastestRecord;

            String prod = 'A_'+loanApp[0].Product__c;
            String subProduct = ProductRTMap__mdt.getInstance(prod).Sub_Product__c;
            String COWProducts = System.Label.COW_Product_Names;
            if(subProduct == 'New'){
                NotificationHandler.sendNotification('Welcome letter (NEW)',loanAppId,'');
            }else if(subProduct == 'Used'){
                NotificationHandler.sendNotification('Welcome letter (USED)',loanAppId,'');
            }//else if(subProduct == 'Cash on Wheels'){
            else if(COWProducts.toUpperCase().contains(subProduct.toUpperCase())){//R2-2634
                NotificationHandler.sendNotification('Welcome letter (COW)',loanAppId,'');
            }   
        }else{
            throw new AuraHandledException('Object Access Denied');
        }
    }

    @AuraEnabled
    public static void validatePaymentFavouring(Id recordId){
        Payment__c updatePayment = new Payment__c();
        updatePayment.Id = recordId;
        updatePayment.is_Validated_By_Author__c = true;
        update updatePayment;
    }

    @AuraEnabled
    public static string createAddendumDocument(String applicationId, String firstEMIDate, String assignmentRecordId){
        try {
            Assignment__c assignmentRecord = new Assignment__c();
            assignmentRecord.Id = assignmentRecordId;
            assignmentRecord.Addendum_Status__c='Pending';
            update assignmentRecord;
            NotificationHandler.sendNotification('Disbursement Addendum',applicationId,'');
            PageReference pdf = new pagereference('/apex/AddendumDocument');
            pdf.getParameters().put('applicationId', applicationId);
            pdf.getParameters().put('selectedEMIDate', firstEMIDate);
            Blob body;
            if(Test.isRunningTest()){
                body = Blob.valueOf('Some Content');
            }else{
                body = pdf.getContent();
            }
            List<Loan_Application__c> loanApp = [SELECT Id, Product__c,Name, (SELECT Id FROM Document_Checklists__r WHERE Document_Master__r.Document_Name__c='Addendum Document') FROM Loan_Application__c WHERE Id=:applicationId];             
            ContentVersion cv = new ContentVersion();
            cv.VersionData = body;
            cv.Title = 'Addendum Document'+'.pdf';
            cv.PathOnClient = 'Addendum Document'+'.pdf';
            cv.Loan_Application__c = loanApp[0].Name;
            cv.isActive__c=true;
            Document_Checklist__c docCheck;
            if(SObjectType.ContentVersion.isCreateable() && SObjectType.ContentVersion.isUpdateable()){
                insert cv;
                if(loanApp[0].Document_Checklists__r!=null && loanApp[0].Document_Checklists__r.size()>0){
                    docCheck = loanApp[0].Document_Checklists__r[0];            
                }else{
                    List<Document_Master__c> docMaster = [SELECT Id, Document_Name__c, Document_Category__c, Document_Sub_Category__c FROM Document_Master__c WHERE Document_Name__c='Addendum Document'];
                    docCheck = new Document_Checklist__c();
                    docCheck.Loan_Application__c = applicationId;
                    docCheck.Document_Master__c = docMaster[0].Id;
                    docCheck.Document_Name__c = docMaster[0].Document_Name__c;
                    docCheck.Category__c = docMaster[0].Document_Category__c;
                    docCheck.Sub_Category__c = docMaster[0].Document_Sub_Category__c;
                    docCheck.Active__c = true;
                    insert docCheck;
                }
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
                cdl.LinkedEntityId = docCheck.Id;
                if(SObjectType.ContentDocumentLink.isCreateable()){
                    insert cdl; 
                }else{
                    throw new AuraHandledException('Object Access Denied');
                }        
                return 'Success';
            } 
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Assignment__c getAssignmentRecordDetails(String recordId){
        try {
            List<Assignment__c> assignmentRecords = [SELECT Id, Addendum_Status__c, OwnerId FROM Assignment__c WHERE id=:recordId AND RecordType.DeveloperName='Ops_Disbursement'];
            if(assignmentRecords!=null && assignmentRecords.size()>0){
                return assignmentRecords[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    //SFAU-4473
    @AuraEnabled
    public static String checkMotorInsurance(String loanId){
        try {
            Loan_Application__c loanApp = [SELECT Id, Product__c, LAN__c, (SELECT Id, Insurance_Expiry_Date__c FROM Collaterals__r), (SELECT Id, Days_left_for_Insurance_Expiry__c, Return_to_PSD_Motor_Ins__c FROM Deviations__r WHERE Deviation_Type__c = 'Motor Insurance' AND Archived__c=false) from Loan_Application__c WHERE Id=:loanId LIMIT 1];
            if(loanApp.LAN__c!=null){
                return 'Success';
            }
            if(loanApp.Deviations__r!=null && loanApp.Deviations__r.size()>0 && loanApp.Deviations__r[0].Return_to_PSD_Motor_Ins__c){
                return 'Failed';
            }
            List<Id> loanIds = new List<Id>();
            loanIds.add(loanApp.Id);
            Map<String,String> motorInsDevAndAuthority = new Map<String,String>();
            ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+loanApp.Product__c);
            String COWProducts = System.Label.COW_Product_Names;
            if(productRT.Sub_Product__c == 'Used' || COWProducts.toUpperCase().contains(productRT.Sub_Product__c.toUpperCase())){//R2-2634
                //productRT.Sub_Product__c == 'Cash on Wheels'){
                Collateral__c collateral = loanApp.Collaterals__r!=null && loanApp.Collaterals__r.size()>0?loanApp.Collaterals__r[0]:null;
                if(collateral.Insurance_Expiry_Date__c!=null){
                    Integer currentDaysBetweenTodayAndExpiry = Date.today().daysBetween(collateral.Insurance_Expiry_Date__c)+1;
                    if(currentDaysBetweenTodayAndExpiry<0){
                        currentDaysBetweenTodayAndExpiry=0;
                    }
                    Deviation__c deviation = loanApp.Deviations__r!=null && loanApp.Deviations__r.size()>0?loanApp.Deviations__r[0]:null;
                    Map<String, Motor_Insurance_Deviation_Criteria__mdt> motorInsuranceMetadataMapTemp = Motor_Insurance_Deviation_Criteria__mdt.getAll();
                    for(Motor_Insurance_Deviation_Criteria__mdt mti: motorInsuranceMetadataMapTemp.values()){
                        if(currentDaysBetweenTodayAndExpiry>=mti.Minimum_Days__c && currentDaysBetweenTodayAndExpiry<=mti.Maximum_Days__c && (deviation==null || !(deviation.Days_left_for_Insurance_Expiry__c>=mti.Minimum_Days__c && deviation.Days_left_for_Insurance_Expiry__c<=mti.Maximum_Days__c))){
                            Map<Id, Loan_Application__c> loanApplications = new Map<Id, Loan_Application__c>([SELECT Id, Branch_Master__r.Region__c, Branch_Master__r.National__c FROM Loan_Application__c WHERE Id IN :loanIds]);
                            motorInsDevAndAuthority = LosPricingApproval.insertApprovalsForMotorInsurance(LosPricingApproval.createMotorInsuranceDeviations(loanIds), loanApplications, true);    
                            //motorInsDevAndAuthority = LosPricingApproval.createMotorInsuranceDeviations(loanIds);
                            break;
                        }
                    }
                }
            }
            if(motorInsDevAndAuthority!=null && motorInsDevAndAuthority.size()>0){
                updateMotorInsDevRecord(loanApp.Id,true);
                //set is charge changed to true to submit application to pricing stage.
                Loan_Application__c updateLoanApp = new Loan_Application__c();
                updateLoanApp.Id=loanApp.Id;
                updateLoanApp.Is_Charge_Changed__c=true;
                updateLoanApp.is_Pricing_Required__c=true;
                update updateLoanApp;
                return 'Failed';
            }else{
                return 'Success';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateMotorInsDevRecord(String loanId, Boolean value){
        try {
            List<Deviation__c> deviations = [SELECT Id, Days_left_for_Insurance_Expiry__c, Return_to_PSD_Motor_Ins__c FROM Deviation__c WHERE Deviation_Type__c = 'Motor Insurance' AND Archived__c=false AND Loan_Application__c=:loanId];
            if(deviations!=null && deviations.size()>0){
                Deviation__c updateDeviation = new Deviation__c();
                updateDeviation.Id=deviations[0].Id;
                updateDeviation.Return_to_PSD_Motor_Ins__c=value;
                update updateDeviation;
            }    
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //SFAU-4473
    
    @AuraEnabled
    public static Assignment__c getAssignmentRecordDetailsByLoan(String recordId){
        try {
            List<Assignment__c> assignmentRecords = [SELECT Id, Addendum_Status__c, OwnerId FROM Assignment__c WHERE Loan_Application__c=:recordId AND RecordType.DeveloperName='Ops_Disbursement'];
            if(assignmentRecords!=null && assignmentRecords.size()>0){
                return assignmentRecords[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    @AuraEnabled
    public static void sendNotificationToRO(String recordId){
        try {
            NotificationHandler.sendNotification('Disbursement Addendum Complete',recordId,'');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updatePaymentRecord(String paymentId){
        try {
            Payment__c paymentRec = new Payment__c(Id=paymentId,Is_Payment_Triggered__c=true);
            update paymentRec;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Notification 
    @AuraEnabled
    public static void sendPaymentNotification(String loanId){
        try {
            List<Payment__c> paymentList = [SELECT id,Loan_Application__r.Product__c,Payment_Recipient__c
                                            FROM Payment__c
                                            WHERE Loan_Application__c =:loanId
                                            AND (Loan_Application__r.Product__c ='10203' OR  Loan_Application__r.Product__c ='10303')
                                            AND  Payment_Recipient__c ='Customer'];
            if(paymentList!=null && paymentList.size()>0 && !paymentList.isEmpty()){
                NotificationHandler.sendNotification('Disbursement Customer',loanId,'');
                NotificationHandler.sendNotification('Payment release',loanId,'');//COmmented and added as part of Notification Update Yash
            }                                            
            //NotificationHandler.sendNotification('Payment release',loanId,'');
        } catch (Exception e) {
           System.debug('exception-->' +e);
        }
    }
    //END

    @AuraEnabled
    public static Boolean isBSRPSLComplete(String loanId) {

        Map<Id,String> mapOfIdsVsStatus = new Map<Id,String>();
        List<String> applicantIds = new List<String>();
        List<Applicant__c> applicants = [SELECT Id, is_BSR_PSL_API_successful__c FROM Applicant__c WHERE Loan__c = :loanId
                    AND RecordType.DeveloperName != 'Additional_Match'
                    AND RecordType.DeveloperName != 'Nominee' 
                    AND IsInactive__c=false
                    WITH SECURITY_ENFORCED]; 
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
        }   
        List<Integration_Checklist__c> intChecklists = [SELECT Status__c, Applicant__c, Loan_Application__c FROM Integration_Checklist__c WHERE (Loan_Application__c = :loanId OR Applicant__c IN :applicantIds) AND Integration_Master__r.Name = 'CBS PSL/BSR Creation' ORDER BY CreatedDate DESC];
        for(Integration_Checklist__c intCheck: intChecklists){
            if(intCheck.Applicant__c!=null && intCheck.Status__c == 'Completed'){
                mapOfIdsVsStatus.put(intCheck.Applicant__c,intCheck.Status__c);
            }else if(intCheck.Loan_Application__c!=null && intCheck.Status__c == 'Completed'){
                mapOfIdsVsStatus.put(intCheck.Loan_Application__c,intCheck.Status__c);
            }
        }
        if(mapOfIdsVsStatus.keySet()!=null && mapOfIdsVsStatus.keySet().size() == (applicantIds.size()+1)){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled
    public static Payment__c checkIfPaymentAlreadyDisbursed(String paymentId){
        try {
            List<Payment__c> paymentFavourings = [SELECT Id, Payment_Favouring_Status__c, Is_Payment_Triggered__c FROM Payment__c WHERE Id=:paymentId AND RecordType.DeveloperName='Payment_Favouring' AND Inactive__c=false];
            if(paymentFavourings!=null && paymentFavourings.size()>0){
                return paymentFavourings[0];
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> checkIfDibursePaymentDone(String loanId,String disburseBtn){
        try {
            Map<String,Object> response = new Map<String,Object>();
            List<Payment__c> payments;
            Boolean isPoolDisbursementSuccess = true;
            Boolean isChequePoolDisbureSuccess = true;
            String paymentCallType;
           
            List<Loan_Application__c> loanApps = [SELECT Id, is_Pool_Disbursement_Successful__c FROM Loan_Application__c WHERE Id=:loanId];
            if(loanApps!=null && loanApps.size()>0){
                if(loanApps[0].is_Pool_Disbursement_Successful__c){
                    response.put('isPaymentAlreadyDone', true);
                    return response;
                }else{
                    if(disburseBtn == 'disbursePaymentCheque'){
                        paymentCallType = GlobalConstants.PAYMENT_CALL_TYPE_CHEQUE;
                        payments = RelatedPaymentFavouringsController.getChequePaymentFavList(loanId,'Payment Favouring');
                        if(!payments.isEmpty() && payments[0].Is_Cheque_Pool_Disburse_Successful__c){
                            response.put('isPaymentAlreadyDone', true);
                            return response;
                        }
                   }else {
                        paymentCallType = GlobalConstants.PAYMENT_CALL_TYPE_NEFT;
                        payments = RelatedPaymentFavouringsController.getNonChequePaymentFavList(loanId,'Payment Favouring');
                        if(!payments.isEmpty() && payments[0].Is_Pool_Disbursement_Successful__c){
                            response.put('isPaymentAlreadyDone', true);
                            return response;
                        }
                   }
                    List<Integration_Checklist__c> icList = [SELECT Id, Response__c, Request__c from Integration_Checklist__c WHERE Integration_Master__r.Name='Payment IFT' AND Loan_Application__c =:loanId AND Call_Type__c =: paymentCallType Order by CreatedDate Desc];
                    if(icList!=null && icList.size()>0){
                        if(icList[0].Response__c!=null){
                            PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper responseWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper) JSON.deserialize(icList[0].Response__c, PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper.class);
                            PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper requestWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper) JSON.deserialize(icList[0].Request__c, PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper.class);
                            if(responseWrapper.TransactionStatus!=null && responseWrapper.TransactionStatus.ResponseMessage == 'Success'){
                                for(Payment__c payment : payments){
                                    if(disburseBtn == 'disbursePaymentCheque'){
                                        payment.Is_Cheque_Pool_Disburse_Successful__c = true;
                                        payment.Pool_Txn_Cheque_Reference_Number__c = requestWrapper.ReferenceNumber;
                                        isChequePoolDisbureSuccess = true;
                                       // isPoolDisbursementSuccess = payment.Is_Pool_Disbursement_Successful__c;
                                        response.put('isPaymentAlreadyDone', true);
                                    }else{
                                        payment.is_Pool_Disbursement_Successful__c = true;
                                       // isChequePoolDisbureSuccess = payment.Is_Cheque_Pool_Disburse_Successful__c;
                                        payment.Pool_Txn_Reference_Number__c = requestWrapper.ReferenceNumber;
                                        isPoolDisbursementSuccess = true;
                                        response.put('isPaymentAlreadyDone', true);
                                    }
                                }
                                if(isChequePoolDisbureSuccess && isPoolDisbursementSuccess){
                                Loan_Application__c newLoanToUpdate = new Loan_Application__c();
                                newLoanToUpdate.Id=loanId;
                                newLoanToUpdate.is_Pool_Disbursement_Successful__c=true;
                                   // newLoanToUpdate.Pool_Txn_Reference_Number__c=requestWrapper.ReferenceNumber;
                                update newLoanToUpdate;
                                }
                               
                                return response;
                            }
                        }
                    }   
                }
                return null;
                
            }else{
                return null;
            }
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),loanId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateDisbursementDateTime(String currentApi, String loanId){
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Id = loanId;
        DateTime currentDT = DateTime.now();
        if(currentApi == 'Disbursement Details'){
            loanApp.Initiate_Disbursement_Date_Time__c=currentDT;
        }else if(currentApi == 'Do Disbursement'){
            loanApp.Do_Disbursement_Date_Time__c=currentDT;
        }
        update loanApp;
    }

    /*SFAU-5557 Change*/
    @AuraEnabled
    public static UpdateRecordWrapper updateLoanApplicationRecord(String applicationRecord){
        try {
            Loan_Application__c applicationObject = (Loan_Application__c)JSON.deserialize(applicationRecord, Loan_Application__c.class);
            if(String.isBlank(applicationRecord) || String.isBlank(applicationObject.Id)){
                return new UpdateRecordWrapper('Please provide a valid Loan Application to Proceed.',false);
            }
            update applicationObject;
            return new UpdateRecordWrapper('Success in updating the record',true);
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            return new UpdateRecordWrapper('Exception Occured!! '+e.getMessage(),false);
        }
    }

    @AuraEnabled
    public static UpdateRecordWrapper updatePaymentTrancheRecord(String paymentRecord){
        try {
            Payment__c paymentObject = (Payment__c)JSON.deserialize(paymentRecord, Payment__c.class);
            if(String.isBlank(paymentRecord) || String.isBlank(paymentObject.Id)){
                return new UpdateRecordWrapper('Please Re-Check the Payment Tranche record',false);
            }
            update paymentObject;
            return new UpdateRecordWrapper('Success in updating the record',true);
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            return new UpdateRecordWrapper('Exception Occured!! '+e.getMessage(),false);
        }
    }

    public class UpdateRecordWrapper{
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public Boolean isSuccess{get;set;}
        public UpdateRecordWrapper(){
            message = '';
            isSuccess = true;
        }
        public UpdateRecordWrapper(String message, Boolean isSuccess){
            this.message = message;
            this.isSuccess = isSuccess;
        }

    }
}