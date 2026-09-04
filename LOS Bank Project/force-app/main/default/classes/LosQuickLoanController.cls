/*****
 * Class Name: LosQuickLoanController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-09-2023          -   Mohit M.            -   SFAU-5163 getVehicleUsageList
 * Oct-13-2023          -   Mohit M.            -   SFAU-5383
 * Oct-18-2023          -   Yash                -   SFAU-5429
 * Dec-13-2023          -   Mohit M.            -   SFAU-5608
 */
public without sharing class LosQuickLoanController {
    // method is used get the visible fields for LosAddIndNonInd
    @AuraEnabled
    public static CustomerTypeFieldsWrapper getVisibleFieldsForLosAddIndNonInd(String strScreen, Id recordId, String strCustomerType){
        CustomerTypeFieldsWrapper wrapObj = new CustomerTypeFieldsWrapper();
        String strStage = '';
        Id profileId = userinfo.getProfileId();
        String strProfile = [Select Id,Name from Profile where Id=:profileId].Name;
        //If record id is Loan Application
        Schema.SObjectType LoanApplicationObject = Schema.Loan_Application__c.getSObjectType();
        Schema.SObjectType record = recordId.getsobjecttype();
        If(record == LoanApplicationObject){
            Loan_Application__c loanAppRec = [Select Id, Stage__c, Customer_Type__c  from  Loan_Application__c where Id  =: recordId];
            strStage = loanAppRec.Stage__c;
            if(String.isBlank(strCustomerType))
            strCustomerType = loanAppRec.Customer_Type__c;
        }else
            //If record id is Applicant
        {
            Applicant__c appRec = [Select Id,Loan__r.Stage__c, Customer_Type__c, RecordType.Name  from  Applicant__c where Id  =: recordId];
            strStage = appRec.Loan__r.Stage__c;
            if(String.isBlank(strCustomerType))
            strCustomerType = appRec.Customer_Type__c;
        }
        wrapObj.customerType = strCustomerType;
        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFieldsForCustomer(strScreen, strStage, strProfile, strCustomerType);
        wrapObj.visibleFields = visibleFields;

        return wrapObj;
        
    }
    
    /* method is used get the Loan Application record data on Quick Loan Screen
    * 23/08/23 - Added Lead Status / Lead Priority - R2-15 | R2-19
    */
    @AuraEnabled()
    public static Loan_Application__c getLoanApplication(String recId){
        // FAU-5608 - Add Lead_Id__c
        Loan_Application__c objLoanApp = [Select Id, Customer_Interested__c, Loan_Amount__c, OPS_KYC_Action__c, Loan_Amount_In_Words__c, Product__c,Dealer_Master__c, Dealer_Master__r.Name, Sourcing_channel__c, Sourcing_Channel_Name__c, Sourcing_Channel_Name__r.Name, Sourcing_Channel_Name__r.Account_Code__c, Vehicle_use__c, Customer_Type__c, Mobile__c, Adhar_Card__c, Category__c, Stage__c, Branch__c, Is_Verified_Number__c, Purchase_City__c, Customer_Name__c, Follow_Up_Date__c, Follow_Up_Time__c, LC_Code__c, Remarks__c, Is_Converted_From_Lead__c, RecordType.Name, Original_Vehicle_Usage__c, Collateral_Type__c, Lead_Status__c, Lead_Priority__c, Lead_Id__c from Loan_Application__c where Id =: recId];
        if (objLoanApp != NULL && String.isEmpty(objLoanApp.Original_Vehicle_Usage__c)) {
            objLoanApp.Original_Vehicle_Usage__c = objLoanApp.Vehicle_use__c;
        }
        return objLoanApp;
    }

    // method is used get the Loan Application record data on Quick Loan Screen
    
    @AuraEnabled()
    public static Map<String,object> getLoanApplicationData(String recId){
        Map<String,object> response = new Map<String,object>();
        List<Loan_Application__c> loanApps =  [Select Id, Customer_Interested__c, Loan_Amount__c, OPS_KYC_Action__c, Loan_Amount_In_Words__c, Product__c,Dealer_Master__c, Dealer_Master__r.Name, Sourcing_channel__c, Sourcing_Channel_Name__c, Sourcing_Channel_Name__r.Name, Vehicle_use__c, Customer_Type__c, Mobile__c, Adhar_Card__c, Category__c, Stage__c, Branch__c, Is_Verified_Number__c, Purchase_City__c, Customer_Name__c, Follow_Up_Date__c, Follow_Up_Time__c, LC_Code__c, Remarks__c, Is_Converted_From_Lead__c, RecordType.Name, Original_Vehicle_Usage__c from Loan_Application__c where Id =: recId];
        if(!loanApps.isEmpty()){
            response.put('loanApplication',loanApps[0]);
            response.put('product',AUSFVehicleController.getTypeOfWheeler(loanApps[0].Product__c));
        }
        return response;
    }

    // method is used get the default value on Quick loan Screen
    @AuraEnabled()
    public static Loan_Application__c fetchDefaultValues(){
        return [Select Id, Loan_Amount__c, Loan_Amount_In_Words__c, Product__c,Dealer_Master__c, Sourcing_channel__c, Sourcing_Channel_Name__c, Sourcing_Channel_Name__r.Name, Vehicle_use__c, Customer_Type__c, Mobile__c, Adhar_Card__c, Category__c, Stage__c, Branch__c, Is_Verified_Number__c, Purchase_City__c, Original_Vehicle_Usage__c from Loan_Application__c where CreatedbyId =: UserInfo.getUserId() Order by Createddate desc Limit 1];
    }
    
    // method is used get the Applicant record data on Quick Loan Screen
    @AuraEnabled()
    public static ApplicantWrapper1 getApplicant(String recId){

        ApplicantWrapper1 applcntWrapperObj = new ApplicantWrapper1();

        Applicant__c app = [Select Id, NPR__c, NREGA__c, CKYC__c,Customer_Type__c, KYC_Status__c, KYC_Type__c, Aadhaar_Number__c, PAN__c, CIF_No__c, Voter_Id__c, Driving_License_Id__c, Passport_Number__c, Constitution_Type__c, Reg_No__c, GST_NO__c, UDYAM_Registration_Number__c, TIN__c, CIN__c, CIBIL_Status__c, Trust_Deed__c, HUF_Deed__c, 
        LLP_Agreement__c, Utility_Bills_Electricity__c, Utility_Bills_Landline_Phone__c, Utility_Bills_Water__c,Income_Tax_Return__c,Importer_Exporter_Code_IEC_Certificate__c,Is_BO__c,RecordType.Name,Loan__r.RecordType.Name from Applicant__c where Id =: recId AND RecordType.Name !='Additional Match']; //14 AUG

        List<Document_Checklist__c> docChecklist = [SELECT Id,Applicant__c, Document_Number__c, Document_Master__r.Document_Name__c
                FROM Document_Checklist__c Where Applicant__c=: recId  AND Document_Number__c !=null
                AND Document_Master__r.Document_Name__c in ('Voter id Card','Driving Licence','Passport','NPR document', 'NREGA document')];
        applcntWrapperObj.applcnt = app;
        applcntWrapperObj.docCheckList = docChecklist;

        return applcntWrapperObj;
    }

    public class ApplicantWrapper1 {
        @AuraEnabled
        public Applicant__c applcnt;
        @AuraEnabled
        public  List<Document_Checklist__c> docCheckList;
    }
    
    // method is used to create Loan Application on Quick Loan screen
    @AuraEnabled()
    public static ApplicantWrapper createLoanApplication(Loan_Application__c loanApplication, String applicantId , String customerType){
        system.debug('loanApplication'+JSON.serialize(loanApplication));
        system.debug('customerType'+customerType);
        system.debug('loanApplicationObj.Product__c'+loanApplication.Product__c);
        try{

       
        Loan_Application__c loanApplicationObj = loanApplication;
        String recordTypeName = getRecordTypeName(loanApplicationObj.Product__c);
        if(String.isNotBlank(recordTypeName)){
            String loanRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            if(loanRecordTypeId != null && String.isNotBlank(loanRecordTypeId)){
                loanApplicationObj.RecordTypeId = loanRecordTypeId;
            }
        } 
        if(Utility.fetchBranchMasterRecord() != null) {
            loanApplicationObj.Branch_Master__c = Utility.fetchBranchMasterRecord().Id;
        }
        if(loanApplication.Id == null || String.isBlank(loanApplication.Id)){
            loanApplication.Stage__c = 'QDE';
        }
        
        // SFAU-4729 -- 
     /*   if(loanApplication.Dealer_Master__c == null && (loanApplication.Sourcing_channel__c == 'Dealer New Vehicle' || loanApplication.Sourcing_channel__c == 'Used Car Dealer With Rc Limit' || loanApplication.Sourcing_channel__c == 'Used Car Dealer Without Rc Limit')){
            if(loanApplication.Sourcing_Channel_Name__c!= null){
                loanApplication.Dealer_Master__c = loanApplication.Sourcing_Channel_Name__c;
            }
                loanApplication.Dealer_Channel__c = loanApplication.Sourcing_channel__c;
        } */
        String COWProducts = System.Label.COW_Product_Names;
        String productName =  Utility.getSubProductName(loanApplication.product__c);
        if( productName.equalsIgnoreCase('New')){
            loanApplication.Dealer_Channel__c = 'Dealer New Vehicle';   
            loanApplication.Dealer_Master__c = loanApplication.Sourcing_channel__c == 'Dealer New Vehicle' ? loanApplication.Sourcing_Channel_Name__c : loanApplication.Dealer_Master__c;
        }else if( (productName.equalsIgnoreCase('Used') || /*productName.equalsIgnoreCase('Cash on wheels')*/ COWProducts.toUpperCase().contains(productName.toUpperCase())) && (loanApplication.Sourcing_channel__c == 'Used Car Dealer With Rc Limit' || loanApplication.Sourcing_channel__c == 'Used Car Dealer Without Rc Limit')){
            loanApplication.Dealer_Master__c = loanApplication.Sourcing_Channel_Name__c;
        }

        loanApplicationObj.Total_Loan_Amount__c = loanApplicationObj.Loan_Amount__c;
        upsert loanApplicationObj;
        ApplicantWrapper wrapObj = new ApplicantWrapper();    //wrapper object intatance
        //wrapObj.la = loanApplicationObj;
        wrapObj.la = [Select Id, Customer_Type__c, Loan_Amount__c, Application_Id__c ,Mobile__c,Product__c,RecordTypeId,Sourcing_channel__c,Stage__c,Vehicle_use__c, Original_Vehicle_Usage__c 
                      from Loan_Application__c where Id =:loanApplicationObj.Id limit 1 ];
        
        List<Applicant__c> lstExistingApplicant = [Select Id, Loan__c, RecordType.Name, Customer_Type__c from Applicant__c where Loan__c =:loanApplicationObj.Id and recordtype.Name = 'Applicant' and isInactive__c = false LIMIT 1];
        if(lstExistingApplicant.isEmpty()){
            wrapObj.app = createApplicant(loanApplicationObj, applicantId, customerType);
        }
        else{
            Applicant__c appObj = new Applicant__c();
            appObj.Id = lstExistingApplicant[0].id;
            appObj.Mobile_Number__c = loanApplication.Mobile__c;
            appObj.Customer_Type__c = customerType;
            update appObj;
            wrapObj.app = lstExistingApplicant[0];
        }
        
        //Calling the Otp Notification
        NotificationHandler.sendNotification('On succesfull OTP verification',loanApplicationObj.Id,'');

        /* START - SFAU-5383 */
        List<Collateral__c> lstCollateralUpdate = new List<Collateral__c>();
        List<Collateral__c> lstCollateral = new List<Collateral__c>();
        lstCollateral = [Select Id, Original_Vehicle_Usage__c FROM Collateral__c where Loan__c =: loanApplicationObj.Id and Is_Deleted__c = false];
        for (Collateral__c objCol : lstCollateral) {
            objCol.Original_Vehicle_Usage__c = loanApplicationObj.Original_Vehicle_Usage__c;
            objCol.Vehicle_Usage__c = loanApplicationObj.Vehicle_use__c;
            lstCollateralUpdate.add(objCol);
        }
        update lstCollateralUpdate;
        /* END - SFAU-5383 */

        return wrapObj;
    }catch(Exception objException){
        Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanApplication.Id);
        return null;
    }
    }
    
    // method is used to create Applicant Record on Quick Loan screen
    public static Applicant__c createApplicant(Loan_Application__c loanApplication, String applicantId, String customerType){
        try{
            Applicant__c appObj = new Applicant__c();
            //appObj.Mobile_Number__c = '1021207666'; //loanApplication.Mobile__c;
            appObj.Mobile_Number__c = loanApplication.Mobile__c;
            appObj.Loan__c = loanApplication.Id;
            appObj.Customer_Type__c = customerType;
            appObj.RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            if(applicantId != null && String.isNotBlank(applicantId)){
                appObj.id = applicantId;
            }
            upsert appObj;
            List<Document_Checklist__c> docCheckRecs = [SELECT Id FROM Document_Checklist__c Where Applicant__c =: appObj.Id];
            if(docCheckRecs.isEmpty()){
                throw new AuraHandledException('Something went wrong. Doc checklist records Are Missing.');
            }
            Applicant__c appObjtoReturn = [Select Id,Loan__c,RecordType.Name from Applicant__c where id=:appObj.id];
            return appObjtoReturn;
        }catch(Exception objException){
            Log.error('Error in LosQuickLoanController createApplicant Method in CreateLoanApplication :: ' + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplication.Id);
            return null;
        }

    }
    
    //method is used to get the recordTypeName from the custom metadata ProductRTMap__mdt
    public static String getRecordTypeName(String product){
        String recordTypeName = '';
        ProductRTMap__mdt[] prtList = [Select Product__c, RecordType__c from ProductRTMap__mdt where Product__c  =:  product and Active__c = true];
        if(prtList.size()>0){
            recordTypeName = prtList[0].RecordType__c;
        }
        return recordTypeName;
    }
    
    //method is used to get all the dealerClassName from the custom metadata BRE_Enum_Values__mdt 
    @AuraEnabled
    public static List<BRE_Enum_Values__mdt> getDealerClassNames(){
        BRE_Enum_Values__mdt[] breList = [Select Dealer_Class__c, SF_Value__c from BRE_Enum_Values__mdt where Active__c = true AND Field_Name__c = 'Sourcing_channel__c'];
        return breList;
    }
    
    //method is used to get all the productTypeName from the custom metadata ProductRTMap__mdt
    @AuraEnabled
    public static List<ProductRTMap__mdt> getRecordTypeNames(){
        ProductRTMap__mdt[] prtList = [Select Product__c, Product_Type__c from ProductRTMap__mdt where Active__c = true];
        return prtList;
    }
    
    @AuraEnabled()
    public static Boolean validateMobile(String mobileNo){
        
        List<Blocked_List__c > blockedlistMobile= [SELECT Mobile__c FROM Blocked_List__c where Mobile__c =:mobileNo  ];
        if(blockedlistMobile.size()>0)
            return true;
        
    return false;        
        
    }
    
    //method is used to convert Lead to Loan on ConvertLeadToLoanLwc
    @AuraEnabled
    public static UpdateLeadToLoanWrapper updateLeadToLoan(String loanAppId){
        UpdateLeadToLoanWrapper wrapperData = new UpdateLeadToLoanWrapper();
        try{
            Loan_Application__c loanApp = [SELECT Id, Product__c, OwnerId FROM Loan_Application__c WHERE Id =: loanAppId];
            if(loanApp.OwnerId.getSObjectType() != Schema.User.getSObjectType()){
                wrapperData = setreturnWrapperValues('Please Assign the Lead to a User before converting to Loan', true);
                return wrapperData;
            }
            loanApp.Stage__c = 'QDE';
            String recordTypeName = getRecordTypeName(loanApp.Product__c);
            loanApp.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            update loanApp;
            wrapperData = setreturnWrapperValues('Lead converted Successfully', false);

        }catch(Exception ex){
            wrapperData = setreturnWrapperValues(ex.getMessage(), true);
        }
        return wrapperData;
        
    }
    
    private static UpdateLeadToLoanWrapper setreturnWrapperValues(String messageLocal, Boolean isErrorLocal){
        UpdateLeadToLoanWrapper returWrapper = new UpdateLeadToLoanWrapper();
        returWrapper.message = messageLocal;
        returWrapper.isError = isErrorLocal;
        return returWrapper;
    }

    public class UpdateLeadToLoanWrapper{
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public Boolean isError{get;set;}
        public UpdateLeadToLoanWrapper(){
            this.message = '';
            this.isError = false;
        }
    }
    
    //method is used to get update the Document Checklist Record on the basis of Applicant and Document Name of Document Master.
    @AuraEnabled
    public static void updateDocChecklistRec(Applicant__c applicntRecord, String documentVerification){

        List<String> documentMasterNameLst = new List<String>{'NPR document','NREGA document','Voter ID Card','Passport','Driving Licence','Aadhaar Card',
                                                                'Pan Card/Form 60','CIN Document','TIN Document','Udyam Document','GST', 'CKYC Document', 'Water bill',
                                                                'telephone bill', 'registration certificate', 'Electricity bill', 'ITR'}; //Bug-3866 change
        String applcantId = applicntRecord.id;
        List<Document_Checklist__c> docCheckList = [SELECT id, Document_Number__c, Document_Master__r.Document_Name__c
                                                     FROM Document_Checklist__c
                                                     WHERE (Applicant__c =: applcantId 
                                                     AND Document_Master__r.Document_Name__c IN :documentMasterNameLst)
                                                     WITH SECURITY_ENFORCED];

         if(applicntRecord.Customer_Type__c == 'Non Individual'){
            Set<String> docIds = new Set<String>();
            String ConstitutionType =  '\'' + applicntRecord.Constitution_Type__c + '\''    ;        
            String appId =  '\'' + applcantId + '\''    ;        
            String query = 'SELECT id,Document_Master__c,Document_Master__r.Document_Id__c, Active__c FROM Document_Checklist__c WHere Document_Master__r.Individual_NI__c = \'NI\'  AND Document_Master__r.Constitiution__c includes ( ' + ConstitutionType + ' ) AND Applicant__c = ' + appId + '' ;
            System.debug('Query-->' + query);
            List<Document_Checklist__c> docChecks = Database.query(query);
            for(Document_Checklist__c docCheck : docChecks){
                docIds.add(docCheck.Document_Master__r.Document_Id__c);
            }
            for(Document_Master__c docMaster : [SELECT Id,Constitiution__c,Document_Category__c,Document_Sub_Category__c, Document_Id__c, Document_Name__c FROM Document_Master__c Where Individual_NI__c = 'NI' AND Constitiution__c != null] ){
                if(docMaster.Constitiution__c.contains(applicntRecord.Constitution_Type__c) && !docIds.contains(docMaster.Document_Id__c)){
                    Document_Checklist__c docCheck = new Document_Checklist__c();
                    docCheck.Document_Master__c = docMaster.Id;
                    docCheck.Applicant__c = applicntRecord.Id;
                    docCheck.Category__c = docMaster.Document_Category__c;
                    docCheck.Sub_Category__c = docMaster.Document_Sub_Category__c;
                    docCheck.Active__c = true;
                    docCheckList.add(docCheck);
                }
            }
        }                                            
        for(Document_Checklist__c docCheckRec : docCheckList) {
            if(docCheckRec.Document_Master__r.Document_Name__c == 'NPR document') {
                docCheckRec.Document_Number__c = applicntRecord?.NPR__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'NREGA document') {
                docCheckRec.Document_Number__c = applicntRecord?.NREGA__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Voter ID Card') {
                docCheckRec.Document_Number__c = applicntRecord?.Voter_Id__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Passport') {
                docCheckRec.Document_Number__c = applicntRecord?.Passport_Number__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Driving Licence') {
                docCheckRec.Document_Number__c = applicntRecord?.Driving_License_Id__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Aadhaar Card') {
                docCheckRec.Document_Number__c = applicntRecord?.Aadhaar_Number__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Pan Card/Form 60') {
                docCheckRec.Document_Number__c = applicntRecord?.PAN__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'CIN Document') {
                docCheckRec.Document_Number__c = applicntRecord?.CIN__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'TIN Document') {
                docCheckRec.Document_Number__c = applicntRecord?.TIN__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'GST') { //Bug-3866 change
                docCheckRec.Document_Number__c = applicntRecord?.GST_NO__c;
            }else if(docCheckRec.Document_Master__r.Document_Name__c == 'Udyam Document') {
                docCheckRec.Document_Number__c = applicntRecord?.UDYAM_Registration_Number__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'CKYC Document') {
                docCheckRec.Document_Number__c = applicntRecord?.CKYC__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'Water bill'){
                docCheckRec.Document_Number__c = applicntRecord?.Utility_Bills_Water__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'telephone bill'){
                docCheckRec.Document_Number__c = applicntRecord?.Utility_Bills_Landline_Phone__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'registration certificate'){
                docCheckRec.Document_Number__c = applicntRecord?.Reg_No__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'Electricity bill'){
                docCheckRec.Document_Number__c = applicntRecord?.Utility_Bills_Electricity__c;
            }
            else if(docCheckRec.Document_Master__r.Document_Name__c == 'ITR'){
                docCheckRec.Document_Number__c = applicntRecord?.Income_Tax_Return__c;
            }
        }

        if(docCheckList.size() > 0 && Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
            upsert docCheckList;
        }
    }

    //method is used to get update the Document Checklist Record on the basis of Applicant and Document Name of Document Master.
    @AuraEnabled
    public static void updateDocVerification(Applicant__c applicntRecord, String status){
        
        List<String> documentNameLst = new List<String>{'CIN Document','Udyam Document','GST'};
        String applcantId = applicntRecord.id;
        List<Document_Checklist__c> docCheckList = [SELECT id, Document_Verification_Status__c, Document_Master__r.Document_Name__c
                                                        FROM Document_Checklist__c
                                                        WHERE (Applicant__c =: applcantId 
                                                        AND Document_Master__r.Document_Name__c IN :documentNameLst)
                                                        WITH SECURITY_ENFORCED];
        
        for(Document_Checklist__c docCheckRec : docCheckList) {
            if(status == 'Not Verified') {
                docCheckRec.Document_Verification_Status__c = status;
            }               
        }

        if(docCheckList.size() > 0 && Schema.sObjectType.Document_Checklist__c.isUpdateable()) {
            update docCheckList;
        }
    }

    // SFAU-5163 - method to get vehicle usage based on product and loan type selected by user
    @AuraEnabled
    public static VehicleUsageWrapper getVehicleUsageList(String strProduct, String strLoantype, String loanAppId){
        strProduct = String.isNotBlank(strProduct) ? strProduct.trim() : strProduct;
        strLoantype = String.isNotBlank(strLoantype) ? strLoantype.trim() : strLoantype;
        VehicleUsageWrapper objVehicleUsage = new VehicleUsageWrapper();
        system.debug(LoggingLevel.Info,'strProduct ' + strProduct);
        system.debug(LoggingLevel.Info,'strLoantype ' + strLoantype);
        try {
            List<ProductRTMap__mdt> lstProductRTMap = new List<ProductRTMap__mdt>();
            lstProductRTMap = [Select Id, Product__c, Sub_Product__c, Vehicle_Usage__c FROM ProductRTMap__mdt WHERE Product_Name__c =: strProduct AND Sub_Product__c =: strLoantype];
            system.debug(LoggingLevel.Info,'Vehicle Usage ' + lstProductRTMap);
            List<String> lstVehicleUsage = !lstProductRTMap.isEmpty() && String.isNotBlank(lstProductRTMap[0].Vehicle_Usage__c) ? lstProductRTMap[0].Vehicle_Usage__c.split(';') : new List<String>();
            objVehicleUsage.blnSuccess = true;
            objVehicleUsage.lstVehicleUsage = lstVehicleUsage;
        } catch (Exception ex) {
            objVehicleUsage.strMessage = ex.getMessage();
            Log.error('LosQuickLoanController : ' + ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),String.isNotBlank(loanAppId) ? loanAppId : UserInfo.getUserId());
        }
        return objVehicleUsage;
    }

    @AuraEnabled
    public static Account getDealerDetailsBySourceCode( String sourceCode, String productType, String vehicleUsage, String[] dealerClasses ){
        if( String.isBlank( sourceCode ) ){
            return null;
        }

        Account[] dealerDetails = [
            SELECT Id, Name, Account_Name__c, Purchase_City__c,
            Dealer_Class__c, Dealer_Type__c, Account_Code__c
            FROM Account
            WHERE RecordType.Name = 'Dealer' AND Account_Code__c =: sourceCode
            AND Dealer_Class__c IN: dealerClasses
            AND ( Product__c =: productType OR Product__c = 'ALL')
            AND (Vehicle_use__c =: vehicleUsage OR Vehicle_use__c = 'ALL')
        ];
        return dealerDetails.isEmpty() ? null : dealerDetails[0];
    }


    // Wrapper for Vehicle Usage picklist
    public class VehicleUsageWrapper {
        @AuraEnabled
        public List<String> lstVehicleUsage = null;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage = '';
    }
    
    //wrapper class to bind Loan Application and Applicant record on Quick Loan screen
    public class ApplicantWrapper{
        @AuraEnabled
        public Loan_Application__c la;
        @AuraEnabled
        public Applicant__c app;
    }
    
    //wrapper class to bind the customer type and visible Fields
    public class CustomerTypeFieldsWrapper{
        @AuraEnabled
        public List<String> visibleFields;
        @AuraEnabled
        public String customerType;
        
    }
    
}