/*****
 * Class Name: CreditVerification
 * Description: 
 * Test Class Name: CreditVerificationTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-19-2023          -   Mohit M.            -   SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
 */
public with sharing class CreditVerification {
    public CreditVerification() {

    }

    //4733
    @AuraEnabled
    public static CreditVerificationWrapper getLoanDetails(String loanId){
        try {
           List<Loan_Application__c> loans = [SELECT Id, Stage__c, BRE_Decision__c FROM Loan_Application__c WHERE Id=:loanId];
            if(loans!=null && loans.size()>0){
                CreditVerificationWrapper newWrapper = new CreditVerificationWrapper();
                newWrapper.loan = loans[0];
                List<User> users= [SELECT Id, Profile.Name from User WHERE Id=:UserInfo.getUserId()];
                if(users!=null && users.size()>0){
                    newWrapper.user = users[0];
                }
                return newWrapper;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    public class CreditVerificationWrapper{
        @AuraEnabled public Loan_Application__c loan;
        @AuraEnabled public User user;
        @AuraEnabled public List<String> lstDocument;
        // SFAU-5663
        @Auraenabled public Boolean blnSanctionCompleted;
        @AuraEnabled public Boolean blnSuccess = false;
        public CreditVerificationWrapper(){
            loan = new Loan_Application__c();
            user = new User();
            lstDocument = new List<String>();
            blnSanctionCompleted = true;
            blnSuccess = false;
        }
    }
    // START  || SFAU-4930
    @AuraEnabled
    public static string getLoanBREDecision(String loanApplicationId){
        List<Loan_Application__c> loan = [SELECT Id, Bre_Decision__c FROM Loan_Application__c WHERE Id=:loanApplicationId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(loan[0].Bre_Decision__c)){
            return loan[0].Bre_Decision__c;
        }else{
            return null;
        }
    }
    //END

    public static void setBaseCreditVerification(Map<Id, sObject> updatedApplications,Map<Id, sObject> oldApplications){
        Map<Id, Loan_Application__c> loanApplications = (Map<Id, Loan_Application__c>) updatedApplications;
        Map<Id, Loan_Application__c> oldLoanApplications = (Map<Id, Loan_Application__c>) oldApplications;
        Map<String, Boolean> docValidationWrapperTW = new Map<String, Boolean>();
        Map<String, Boolean> docValidationWrapperFW = new Map<String, Boolean>();
        Map<String, Boolean> tractorTabsWrapper = new Map<String, Boolean>();


        List<String> twoWheelerDocuments = System.Label.TwoWheelerDocuments.split(',');
        List<String> fourWheelerDocuments = System.Label.FourWheelerDocuments.split(',');
        List<String> tractorTabsToBeVerified = System.Label.TractorCreditReviewTabs.split(',');

        Id fourWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
        Id twoWheelerRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName();
        for(String doc: twoWheelerDocuments){
            if(doc == 'Deviation'){
                docValidationWrapperTW.put(doc, true);
            }else{
                docValidationWrapperTW.put(doc, false);
            }
        }
        for(String doc: fourWheelerDocuments){
            if(doc == 'Deviation'){
                docValidationWrapperFW.put(doc, true);
            }else{
                docValidationWrapperFW.put(doc, false);
            }
        }
        for(String doc: tractorTabsToBeVerified){
            if(doc == 'Deviation'){
                tractorTabsWrapper.put(doc, true);
            }else{
                tractorTabsWrapper.put(doc, false);
            }
        }
        List<Collateral__c> collaterals = [SELECT Id, Vehicle_Delivery__c, Loan__c FROM Collateral__c WHERE Loan__c IN :loanApplications.keySet() AND RecordTypeId IN :GlobalConstants.colRecordTypeIds AND Loan__r.RecordType.DeveloperName='Tractor'];
        Map<String, Collateral__c> collateralsMap = new Map<String, Collateral__c>();
        for(Collateral__c col: collaterals){
            collateralsMap.put(col.Loan__c, col);
        }

        Map<String, ProductRTMap__mdt> productDetails = ProductRTMap__mdt.getAll();
        for(Loan_Application__c loan: loanApplications.values()){
            if(loan.Stage__c=='Credit' && oldLoanApplications.get(loan.Id).Stage__c!='Credit' && loan.Bre_Decision__c!='STP'){
                String productCode = 'A_'+loan.Product__c;
                String subProduct = productDetails.get(productCode)?.Sub_Product__c;
                if(loan.RecordTypeId == twoWheelerRecordTypeId){
                    if(subProduct=='New'){
                        if(docValidationWrapperTW.containsKey('Valuation')){
                            docValidationWrapperTW.put('Valuation',true);
                        }
                    }
                    if(loan.BSR_PSL_Status__c=='Completed' && docValidationWrapperTW.containsKey('BSR')){
                        docValidationWrapperTW.put('BSR',true);
                    }
                    if(loan.Customer_Grade__c=='NIB' && docValidationWrapperTW.containsKey('Income Docs')){
                        docValidationWrapperTW.put('Income Docs',true);
                    }
                    String twoWheelersDocumentWrapper = JSON.serializePretty(docValidationWrapperTW,false);
                    loan.Base_Credit_Verification__c = twoWheelersDocumentWrapper;
                }
                else if(loan.RecordTypeId == fourWheelerRecordTypeId || loan.RecordTypeId==recordTypes.get('Commercial Vehicle').getRecordTypeId() || loan.RecordTypeId==recordTypes.get('Construction Equipment').getRecordTypeId()){
                    if(subProduct=='New'){
                        if(docValidationWrapperFW.containsKey('Valuation')){
                            docValidationWrapperFW.put('Valuation',true);
                        }
                    }
                    if(loan.BSR_PSL_Status__c=='Completed' && docValidationWrapperFW.containsKey('PSL')){
                        docValidationWrapperFW.put('PSL',true);
                    }
                    String fourWheelersDocumentWrapper = JSON.serializePretty(docValidationWrapperFW,false);
                    loan.Base_Credit_Verification__c = fourWheelersDocumentWrapper;
                }else if(loan.RecordTypeId==Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId() && loan.Base_Credit_Verification__c==null){
                    if(subProduct=='New'){
                        if(tractorTabsWrapper.containsKey('Valuation')){
                            tractorTabsWrapper.put('Valuation',true);
                    }else if(tractorTabsWrapper.containsKey('TAR') && collateralsMap.containsKey(loan.Id) && collateralsMap.get(loan.Id).Vehicle_Delivery__c!='Yes'){
                            tractorTabsWrapper.put('TAR',true);
                        }
                    }else{
                        if(tractorTabsWrapper.containsKey('TAR')){
                            tractorTabsWrapper.put('TAR',true);
                        }
                    }
                    if(loan.BSR_PSL_Status__c=='Completed' && tractorTabsWrapper.containsKey('PSL')){
                        tractorTabsWrapper.put('PSL',true);
                    }
                    loan.Base_Credit_Verification__c = JSON.serializePretty(tractorTabsWrapper,false);
                }
            }
        }
    }

    @AuraEnabled
    public static void setValidationOnDocument(String documentType, String loanApplicationId){
    
        List<Loan_Application__c> loan = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName, Stage__c FROM Loan_Application__c WHERE Id=:loanApplicationId WITH SECURITY_ENFORCED];
        if(loan!=null && loan.size()>0 && loan[0].Stage__c=='Credit' && String.isNotBlank(loan[0].Base_Credit_Verification__c)){ //SFAU-4930
         system.debug('loan[0]===>' + loan[0]);
            Map<String, Boolean> documentWrapper = (Map<String,Boolean>) JSON.deserialize(loan[0].Base_Credit_Verification__c, Map<String,Boolean>.class);
            if(documentType == 'PSL' && loan[0].RecordType.DeveloperName=='Two_Wheeler'){
                documentWrapper.put('BSR', true);
            }else if(documentType == 'Financial (Income Norms)'){
                documentWrapper.put(documentType, true);
                if(documentWrapper.containsKey('Income Docs')){
                    documentWrapper.put('Income Docs', true);
                }
                
            }
            else{
                documentWrapper.put(documentType, true);
            }
            
            /*for(String document: documentWrapper.keySet()){
                documentWrapper.put(document,true);
            }*/
            String serializedDocumentWrapper = JSON.serializePretty(documentWrapper,false);
            loan[0].Base_Credit_Verification__c =  serializedDocumentWrapper;
            update loan[0];
        }
    }

    /*New Credit Check Added for FI and Cibil Check*/ 
    public static void updateCibilCheckForApplicant(String appId){
        List<Applicant__c> applicant = [SELECT Id, Loan__c, Loan__r.Stage__c, Cibil_Report_Verified_by_Credit__c FROM Applicant__c WHERE Id=:appId LIMIT 1];
        if(applicant[0].Loan__r.Stage__c == 'Credit'){
            applicant[0].Cibil_Report_Verified_by_Credit__c = true;
            update applicant;
        }
        
    }

    @AuraEnabled
    public static void updateDedupeCheckForApplicant(String appId, String dedupeType){
        List<Applicant__c> applicant = [SELECT Id, Loan__c, Loan__r.Stage__c, Lead_Dedupe_Verified_By_Credit__c, Customer_Dedupe_Verified_By_Credit__c FROM Applicant__c WHERE Id=:appId WITH SECURITY_ENFORCED LIMIT 1];
        if(applicant[0].Loan__r.Stage__c == 'Credit'){
            if(dedupeType=='Lead'){
                applicant[0].Lead_Dedupe_Verified_By_Credit__c = true;
            }else if(dedupeType=='CBS'){
                applicant[0].Customer_Dedupe_Verified_By_Credit__c = true;
            }
            ApplicantTriggerHandler.byPassApplicantTrigger=true;
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                update applicant;
            }
            
        }
        
    }

    public static void updateFIReportCheckForAddress(String fiId){
        List<Field_Investigation__c> fieldInvestigationRecords = [SELECT Id, Address_lookup__c, Loan_Application__c, Loan_Application__r.Stage__c FROM Field_Investigation__c WHERE Id=:fiId];
        if(fieldInvestigationRecords[0].Loan_Application__r.Stage__c == 'Credit'){
            Address__c address = new Address__c();
            address.Id = fieldInvestigationRecords[0].Address_lookup__c;
            address.FI_Report_Verified__c=true;
            update address;
        }
        
    }

    
    // SFAU-5663 - Check for Sanction Condition
    @AuraEnabled
    public static CreditVerificationWrapper validateCreditVerification(String documentType, String loanApplicationId){
        List<Loan_Application__c> loanApps = [SELECT Id, Stage__c,Base_Credit_Verification__c, RecordType.DeveloperName, Product__c FROM Loan_Application__c WHERE Id=:loanApplicationId];
        // SFAU-5663 - Check for Sanction Condition
        CreditVerificationWrapper objCreditWrap = new CreditVerificationWrapper();
        List<String> documentsNotVerified = new List<String>();
        Boolean cibilDatesVerified = true;
        if(loanApps!=null && loanApps.size()>0 && loanApps[0].Stage__c=='Credit'){
            List<Loan_Application__c> loan = [SELECT Id, Base_Credit_Verification__c, Product__c, Stage__c, BRE_Decision__c, RecordType.Name, Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c, RecordType.DeveloperName, Deal_Background__c,
            (SELECT Id, Cibil_Report_Verified_by_Credit__c, Last_CIBIL_Run_Date__c, First_Name__c, Last_Name__c, RecordType.Name, CIF_No__c, Lead_Dedupe_Verified_By_Credit__c, Customer_Dedupe_Verified_By_Credit__c, DPD_Check_Done_by_Credit__c FROM Applicants__r WHERE RecordType.DeveloperName IN ('Primary_Applicant','Guarantor','Co_Applicant') AND isInactive__c=false),
            (SELECT Id FROM Verifications__r),
            (SELECT Id, Vehicle_Delivery__c FROM Collaterals__r WHERE RecordTypeId IN :GlobalConstants.colRecordTypeIds) FROM Loan_Application__c WHERE Id=:loanApplicationId WITH SECURITY_ENFORCED];
            if(String.isNotBlank(loan[0].Base_Credit_Verification__c)){ //SFAU-4930
                Map<String, ProductRTMap__mdt> productDetails = ProductRTMap__mdt.getAll();//R2-2670
                String productCode = 'A_'+loan[0].Product__c;
                String subProduct = productDetails.get(productCode)?.Sub_Product__c;

                Map<String, Boolean> documentWrapper = (Map<String,Boolean>) JSON.deserialize(loan[0].Base_Credit_Verification__c, Map<String,Boolean>.class);
                for(String docName: documentWrapper.keySet()){
                    if(docName == 'FI report' || docName=='FI'||docName=='CIBIL'){
                        documentWrapper.put(docName,true);
                    }
                    if(loan[0].RecordType.DeveloperName=='Tractor' && docName == 'TAR' && (loan[0].Collaterals__r[0].Vehicle_Delivery__c=='No' || loan[0].Collaterals__r[0].Vehicle_Delivery__c==null || subProduct!='New')){//added sub product check R2-2670
                        documentWrapper.put(docName,true);
                    }//R2-2433
                    if(!documentWrapper.get(docName)){
                        documentsNotVerified.add(docName);
                    }

                }
            } //END
            for(Applicant__c applicant: loan[0].Applicants__r){
String applicantName = (applicant.First_Name__c!=null?applicant.First_Name__c:'')+' '+(applicant.Last_Name__c!=null?applicant.Last_Name__c:'');
                if(!applicant.Cibil_Report_Verified_by_Credit__c){
                    String error = 'CIBIL Report ('+applicant.RecordType.Name+'_'+applicantName+')';
                    documentsNotVerified.add(error);
                }
                if(!applicant.DPD_Check_Done_by_Credit__c && applicant.CIF_No__c!=null){
                    String error = 'Fetch DPD ('+applicant.RecordType.Name+'_'+applicantName+')';
                    documentsNotVerified.add(error);
                }
                if(loan[0].RecordType.Name=='Tractor'){
                    if(!applicant.Lead_Dedupe_Verified_By_Credit__c || !applicant.Customer_Dedupe_Verified_By_Credit__c){
                        String error = 'Lead/Customer Dedupe ('+applicant.RecordType.Name+'_'+applicantName+')';
                        documentsNotVerified.add(error);
                    }
                }
            }
            Set<Id> setFIAddressIds = new Set<Id>();

            List<Field_Investigation__c> lstFieldInvest = new List<Field_Investigation__c>();
            lstFieldInvest = [Select Id, Address_lookup__c, Applicant__c, Address_lookup__r.FI_Report_Verified__c, Address_lookup__r.Address_Type__c, 
                Applicant__r.RecordType.Name, Applicant__r.First_Name__c, Applicant__r.Last_Name__c 
                FROM Field_Investigation__c where Re_Trigger__c = false and Applicant__r.Loan__c =: loanApplicationId and Applicant__r.isInactive__c = false AND FI_Status__c!='Waived Off'];

            for (Field_Investigation__c objFieldInves : lstFieldInvest) {
                if (!objFieldInves.Address_lookup__r.FI_Report_Verified__c) {
                    String error = 'FI Report for '+objFieldInves.Address_lookup__r.Address_Type__c+' Address ('+objFieldInves.Applicant__r.RecordType.Name+'_'+objFieldInves.Applicant__r.First_Name__c+' '+objFieldInves.Applicant__r.Last_Name__c+')';
                    documentsNotVerified.add(error);
                }
            }
            // SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
            List<Sanction_Condition__c> lstSanctionCondition = new List<Sanction_Condition__c>();
            lstSanctionCondition = [SELECT Id, Loan_Application__c, Loan_Application__r.OwnerId, Raised_By__c  FROM Sanction_Condition__c WHERE Loan_Application__c =: loanApplicationId AND Status__c = '' AND Sanction_Type__c = 'Credit'];
            if (lstSanctionCondition.size() > 0)
                objCreditWrap.blnSanctionCompleted = false;
            if(loan[0].BRE_Decision__c=='STP' && (loan[0].Is_BRE_Credit_Subjectivity__c==true || loan[0].Is_BRE_Ops_Subjectivity__c==true)){
                
            }else{
                if(loan[0].Verifications__r==null || loan[0].Verifications__r.size() == 0){
                    documentsNotVerified.add('Atleast one TVR is Mandatory');
                }
            }
            if(loan[0].Deal_Background__c==null){
                documentsNotVerified.add('Please add Deal Background');
            }//R2-2764
            
        }
        objCreditWrap.lstDocument = documentsNotVerified;
        objCreditWrap.blnSuccess = true;
        return objCreditWrap;
    }

    //R2-34
    @AuraEnabled
    public static GenericResponseWrapper isNPAResolvedForTractorApplications(String loanId){
        GenericResponseWrapper response = new GenericResponseWrapper();
        try {
            List<Applicant__c> applicants = [SELECT Id, First_Name__c, Last_Name__c, RecordType.Name FROM Applicant__c WHERE RecordType.DeveloperName IN :GlobalConstants.APPLICANT_RECORD_TYPES AND 
                                                IsInactive__c=false AND is_NPA_Resolved__c=false AND Loan__c=:loanId WITH SECURITY_ENFORCED];
            if(!applicants.isEmpty()){
                response.status='Fail';
                response.errorMessage='NPA Detected for ';
                for(Applicant__c app: applicants){
                    response.errorMessage += app.RecordType.Name+'_'+setDefaultValue(app.First_Name__c)+' '+setDefaultValue(app.Last_Name__c)+'; ';
                }
                response.errorMessage +='Please Re-run Dedupe';
            }else{
                response.status='Success';
            }
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string setDefaultValue(String param){
        return param!=null?param:'';
    }
    
    public static String setCreditBaseVerification(Id loanId, String documentType, Boolean value){
        Loan_Application__c loanApp = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName, Stage__c FROM Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED];
        List<String> stages = new List<String>{'QDE','DDE','Credit'};
        List<String> tabs = new List<String>();
        if(loanApp.RecordType.DeveloperName == 'Tractor'){
            tabs.addAll(System.Label.TractorCreditReviewTabs.split(','));
        }
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        if(System.Label.CreditVerificationRecordTypes.split(',').contains(loanApp.RecordType.DeveloperName) && loanApp.Base_Credit_Verification__c!=null && stages.contains(loanApp.Stage__c) && tabs.contains(documentType)){
            Map<String,Boolean> verificationMap = (Map<String,Boolean>)JSON.deserialize(loanApp.Base_Credit_Verification__c, Map<String,Boolean>.class);
            verificationMap.put(documentType, value);
            return JSON.serialize(verificationMap);
        }
        return loanApp.Base_Credit_Verification__c;      
    }

    @AuraEnabled
    public static void resetCreditVerificationOnLoan(String loanId, String documentType, Boolean value){
        Loan_Application__c loan = new Loan_Application__c();
        loan.Id = loanId;
        loan.Base_Credit_Verification__c = CreditVerification.setCreditBaseVerification(loanId, documentType, value);
        if (Schema.sObjectType.Loan_Application__c.isUpdateable()) {
            update loan;
        }
    }
}