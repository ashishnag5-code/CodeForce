/*
@ Name: CustomerSummaryController
@ TestClass: CustomerSummaryControllerTest
@ Logs
@ Last Modified Date        -       Last Modified By            -       Description
@ Sep-11-2023               -       Mohit M.                    -       Change As per SFAU-4068 - String to Boolean
@ Dec-15-2023               -       Mohit M.                    -       SFAU-5730 - Fix DPD logic

*/
public without sharing class CustomerSummaryController {
    
    public static Decimal TotalExposure=0;
    public static Decimal FinalExposure=0;
    public static  Decimal WheelsExposure=0; 
    public static Boolean boolCreateDeviation = false;
    
    @AuraEnabled
    public static  List<Applicant__c> getApplicantDetails(String loanId){
        try {
            List<Applicant__c> applicantList = [SELECT Id,Customer_Name__c,Father_Name__c,Entity_Name__c,Mobile_Number__c,Negative_Check_Status__c,Type_Of_Employment__c,
                                                Relationship_with_applicant__c, KYC_Status__c, CIF_No__c,RecordType.Name,Loan__r.Stage__c
                                                FROM Applicant__c
                                                WHERE Loan__c =: loanId 
                                                AND RecordType.DeveloperName != 'Additional_Match'
                                                AND RecordType.DeveloperName != 'BO'
                                                AND RecordType.DeveloperName != 'Nominee'
                                                WITH SECURITY_ENFORCED];
            
            if(!applicantList.isEmpty()){
                return applicantList;
            }else{
                return new List<Applicant__c>();
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //SFAU-4993 Updated for elgible customer relationships
    public static Boolean checkInstallmentOverDues(List<Object> loanDetails,String customerRelationShip,List<EMI_Date_Master__mdt> emiMasterList){
        Boolean dpdCheck = false;
        String relationShip = System.label.dpdCustomerRelationship; 
        if(!loanDetails.isEmpty()){
            Date todayDate = Date.today();
            String [] definedRelationShips = relationShip.split(',');
            for(String strInstance : definedRelationShips){
                if(strInstance == customerRelationShip){
                    for(Object objInstance : loanDetails){
                        Map<String,Object> loanMap = ( Map<String,Object> )objInstance;
                        Decimal installmentOverDue = (Decimal)loanMap.get('InstallmentsOverDue');
                        if( installmentOverDue>1){
                            dpdCheck = true;
                            boolCreateDeviation = true;
                            // SFAU-5730
                            break;
                        }else if (installmentOverDue ==0){
                            dpdCheck = false;
                        } else if (installmentOverDue == 1){
                            // START - SFAU-5730
                            Integer todayDateInstance = todayDate.day();
                            String strNextDueDate = loanMap.containsKey('NextDueDate') ? (String)loanMap.get('NextDueDate') : '';
                            Date dtNextDueDate = String.isNotBlank(strNextDueDate) ? Date.valueOf(strNextDueDate) : null; // Expected date format - 'yyyy-mm-dd' as per current prod response
                            if (todayDateInstance != dtNextDueDate.day()) {
                                dpdCheck = true;
                                boolCreateDeviation = true;
                                break;
                            }
                            /* 
                            for(EMI_Date_Master__mdt emiInstance : emiMasterList){
                                Decimal todayDateInstance = todayDate.day();
                                if(emiInstance.Product_Name__c.contains('Wheels')){ // Later need to be changed based on the product as of now in this release we have only wheeler
                                    if(todayDateInstance != emiInstance.Due_Date__c){
                                        dpdCheck = true;
                                        boolCreateDeviation = true;
                                    }else if(todayDateInstance == emiInstance.Due_Date__c ){
                                        dpdCheck = false;
                                        boolCreateDeviation = true;
                                        break;
                                    }
                                }
                            }
                            */
                            // END - SFAU-5730
                        }
                    }  
                }
            }
            
        }
        return dpdCheck;
    }
    //EN
    
    @AuraEnabled
    public static loanDetailsResponseWrapper getLoanODDetails(String strCustomerId, String strApplicantId,Id loanId) {
        String respBody;
        String requestBody;
        try {
            
            List<EMI_Date_Master__mdt> emiMasterList = [SELECT id,Due_Date__c,Product_Name__c 
                                                    FROM EMI_Date_Master__mdt ];

            Loan_Application__c loanApplication = new Loan_Application__c();
            loanApplication.Id = loanId;
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Loan OD Detail');
            Map < String, Object > reqParam = new Map < String, Object > ();
            Decimal TotalExposure=0;
            Decimal FinalExposure=0;
            Decimal WheelsExposure=0; 
            //REQUEST FORMING
            reqParam.put('Channel', Label.Loan_Details_Channel);//LOS June 13
            reqParam.put('TransactionBranch', '9109');
            reqParam.put('CustomerId', strCustomerId); //strCustomerId 22570632  27972650
            requestBody = LoanDetailsHandler.generateLoanODDetails(reqParam)[0];
            
            String recordId = strApplicantId;
            // Loan_Application__c LoanInstance = [SELECT id,Name,Product__c FROM Loan_Application__c WHERE Id=:loanId  WITH SECURITY_ENFORCED];
            String loanRecordId = String.valueOf(loanId);
            Loan_Application__c LoanInstance =   getLoanApplicationInstance(loanRecordId);
            String strProducttoPurchase = (LoanInstance.Product__c!=null) ? LoanInstance.Product__c : '';
            
            Map < String, List < Bank_Account_Records__c >> bankAccountMap = getBankAccountMap(strApplicantId,'');
            
            LoanDetailsHandler.LoanDetailsRequestWrapper odDetailsRequest =
                (LoanDetailsHandler.LoanDetailsRequestWrapper) JSON.deserialize(requestBody, LoanDetailsHandler.LoanDetailsRequestWrapper.class);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            loanDetailsResponseWrapper wrapperInstance = new loanDetailsResponseWrapper();
            Map<String,String> mapProductIdvsRecordType = LeadDedupeController.getRecordTypeMap();
            Boolean dpdChecked = false;
            //UPDATE LOAN AND APPLICANT EXPOSURES
            Set<String> setFourWheeler = new Set<String>();
            setFourWheeler.add(GlobalConstants.FOURWHEELER);
            setFourWheeler.add(GlobalConstants.TRACTOR);
            setFourWheeler.add(GlobalConstants.COMMERCIALVEHICLE);
            setFourWheeler.add(GlobalConstants.CONSTRUCTIONEQUIP);
            if (calloutResponseWrapper.response != null) {
                //Applicant__c applicantInstance =  applicantUpdation(recordId); // atlast of the transaction
                Applicant__c applicantInstance =getApplicantInstance(strApplicantId);
                respBody = calloutResponseWrapper.response;
                Map < String, Object > response = (Map < String, Object > ) JSON.deserializeUntyped(respBody);
               // if(respBody.contains('Account not found')){
                    loanApplication.Dpd_Checked_Date__c = System.today();
               // }
                List < Object > accountDetails = response.get('AccountDetail')!=null ? (List < Object > ) response.get('AccountDetail'):null;
                List < Bank_Account_Records__c > bankUpdateList = new List < Bank_Account_Records__c > ();
                List < Bank_Account_Records__c > bankInsertList = new List < Bank_Account_Records__c > ();
                
                
                List<Boolean> dpdCheckList = new  List<Boolean>();
                if(accountDetails!=null && accountDetails.size()>0){
                    for (Object objInstance: accountDetails) {
                        Map < String, Object > accountDetailMap = (Map < String, Object > ) objInstance;
                        if (accountDetailMap != null) {
                            wrapperInstance.AccountId = (String) accountDetailMap.get('AccountId');
                            String moduleCode = (String) accountDetailMap.get('ModuleCode');
                            String customerRelationShip = (String) accountDetailMap.get('CustomerRelationship'); //SFAU-4993
                            List<Object> loanDetails =  ( List<Object>)accountDetailMap.get('LoanAccountDetails');
                            if(loanDetails!=null){
                                dpdChecked  =checkInstallmentOverDues(loanDetails,customerRelationShip,emiMasterList);
                                dpdCheckList.add(dpdChecked);
                            }
                            //If the account Id exist with the current bank records update the bank records based on the accountype 
                            if (bankAccountMap.keySet().contains(wrapperInstance.AccountId)) {
                                //Get the existing records from accountId
                                List < Bank_Account_Records__c > accountRecords = bankAccountMap.get(wrapperInstance.AccountId);
                                for (Bank_Account_Records__c accountInstance: accountRecords) {
                                    if (accountInstance.Account_Type__c == 'ODCC') {
                                        accountInstance.Over_Limit_Amount__c = accountDetailMap.containsKey('limitAmount') && accountDetailMap.get('limitAmount') != null ? (Integer) accountDetailMap.get('limitAmount') : 0;
                                        //accountInstance.Over_Limit_Amount__c = 100;
                                        if(accountInstance.Include_In_Exposure__c == 'Yes'){
                                            TotalExposure = TotalExposure +  (accountInstance.Over_Limit_Amount__c!=null ? accountInstance.Over_Limit_Amount__c :0  ); 
                                        }
                                    } else if (accountInstance.Account_Type__c == 'Loan') {
                                        accountInstance.EMI_Amount__c = accountDetailMap.get('InstallmentAmount') != null ? (Decimal) accountDetailMap.get('InstallmentAmount') : 0;
                                        //accountInstance.POS__c = accountDetailMap.get('BalPrincipal') != null ? (Decimal) accountDetailMap.get('BalPrincipal') : 0;
                                        accountInstance.POS__c = accountDetailMap.get('PrincipalBalance') != null ? (Decimal) accountDetailMap.get('PrincipalBalance') : 0; //14 Aug
                                        //accountInstance.POS__c = 10;
                                        if( accountInstance.Include_In_Exposure__c == 'Yes'){
                                            TotalExposure = TotalExposure + (accountInstance.POS__c!=null ? accountInstance.POS__c : 0);
                                            if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && 
                                               mapProductIdvsRecordType.get(accountInstance.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                                   WheelsExposure = WheelsExposure + (accountInstance.POS__c!=null ? accountInstance.POS__c : 0);
                                               }
                                            //if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && 
                                            //   mapProductIdvsRecordType.get(accountInstance.Product_Code__c) == GlobalConstants.FOURWHEELER || mapProductIdvsRecordType.get(accountInstance.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                            if(setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c) && 
                                               setFourWheeler.contains(mapProductIdvsRecordType.get(accountInstance.Product_Code__c)) || mapProductIdvsRecordType.get(accountInstance.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                                   WheelsExposure =  WheelsExposure +  (accountInstance.POS__c!=null ? accountInstance.POS__c : 0);
                                               }
                                        }
                                        
                                    }
                                    bankUpdateList.add(accountInstance);
                                }
                            } else { //Create new Bank Account Records based on Module code
                                Bank_Account_Records__c bankAccountRecord = new Bank_Account_Records__c();
                                bankAccountRecord.Applicant__c = strApplicantId;
                                bankAccountRecord.Installment_Paid__c = accountDetailMap.get('PaidInstallment') != null ? (Decimal) accountDetailMap.get('PaidInstallment') : 0; // R2 Updated for Fleet Userstory need this value;
                                bankAccountRecord.Account_Type__c = (ModuleCode == 'C') ? 'ODCC' : (ModuleCode == 'L') ? 'Loan' : '';
                                bankAccountRecord.Loan_Number__c = (accountDetailMap.get('LoanApplicationNumber') != null) ? (String) accountDetailMap.get('LoanApplicationNumber') : '';
                                bankAccountRecord.Account_Number__c = wrapperInstance.AccountId;
                                bankAccountRecord.Product__c = (accountDetailMap.get('ProductName') != null) ? (String) accountDetailMap.get('ProductName') : '';
                                bankAccountRecord.Branch_Name__c = (accountDetailMap.get('BranchName') != null) ? (String) accountDetailMap.get('BranchName') : '';
                                bankAccountRecord.EMI_Amount__c = accountDetailMap.get('InstallmentAmount') != null ? (Decimal) accountDetailMap.get('InstallmentAmount') : 0;
                                //bankAccountRecord.POS__c = accountDetailMap.get('BalPrincipal') != null ? (Decimal) accountDetailMap.get('BalPrincipal') : 0;
                                bankAccountRecord.POS__c = accountDetailMap.get('PrincipalBalance') != null ? (Decimal) accountDetailMap.get('PrincipalBalance') : 0; //14 Aug
                                //bankAccountRecord.OD_Limit_Sanctioned__c = accountDetailMap.get('limitAmount') != null ? (Decimal) accountDetailMap.get('limitAmount') : 0;
                                //bankAccountRecord.OD_Limit_Sanctioned__c =250;
                                bankAccountRecord.Source__c = GlobalConstants.CBS;
                                bankAccountRecord.RecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get(GlobalConstants.BANK_ACCOUNT_RECORDS), GlobalConstants.CBS);
                                bankAccountRecord.Customer_Relationship__c = (accountDetailMap.get('CustomerRelationship') != null) ? (String) accountDetailMap.get('CustomerRelationship') : '';
                                String acctOpening = (accountDetailMap.get('DateAccountOpen') != null) ? (String) accountDetailMap.get('DateAccountOpen') : '';
                                if (String.isNotBlank(acctOpening)) {
                                    bankAccountRecord.Account_Opening_Date__c = Date.valueOf(acctOpening);
                                }
                                bankAccountRecord.Current_Status__c = (accountDetailMap.get('CurrentStatusDescription') != null) ? (String) accountDetailMap.get('CurrentStatusDescription') : '';
                                bankAccountRecord.Total_Outstanding__c = accountDetailMap.get('TotalBalBook') != null ? (Decimal) accountDetailMap.get('TotalBalBook') : 0;
                                bankAccountRecord.ROI__c = accountDetailMap.get('IntRate') != null ? (Decimal) accountDetailMap.get('IntRate') : 0;
                                String MaturityDate = (accountDetailMap.get('MaturityDate') != null) ? (String) accountDetailMap.get('MaturityDate') : '';
                                if (String.isNotBlank(MaturityDate)) {
                                    bankAccountRecord.Account_Opening_Date__c = Date.valueOf(MaturityDate);
                                }
                                //Check Exposure
                                bankAccountRecord =  LeadDedupeController.checkForExposure(bankAccountRecord ,applicantInstance );
                                
                                //Acount Type for Loan 
                                if(bankAccountRecord.Account_Type__c == GlobalConstants.LOAN && bankAccountRecord.Include_In_Exposure__c == 'Yes'){
                                    //TotalExposure = TotalExposure + applicantInstance.Total_Exposure__c + (bankAccountRecord.POS__c!=null ? bankAccountRecord.POS__c : 0);
                                    TotalExposure = TotalExposure + (bankAccountRecord.POS__c!=null ? bankAccountRecord.POS__c : 0);
                                    // FinalExposure = applicantInstance.Total_Exposure__c;
                                    
                                    if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && 
                                       mapProductIdvsRecordType.get(bankAccountRecord.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                           //  WheelsExposure = WheelsExposure + applicantInstance.Wheels_Exposure__c + (bankAccountRecord.POS__c!=null ? bankAccountRecord.POS__c : 0);
                                           WheelsExposure = WheelsExposure + (bankAccountRecord.POS__c!=null ? bankAccountRecord.POS__c : 0);
                                       }
                                    //if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && 
                                    //   mapProductIdvsRecordType.get(bankAccountRecord.Product_Code__c) == GlobalConstants.FOURWHEELER || mapProductIdvsRecordType.get(bankAccountRecord.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                    if(setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c) && 
                                       setFourWheeler.contains(mapProductIdvsRecordType.get(bankAccountRecord.Product_Code__c)) || mapProductIdvsRecordType.get(bankAccountRecord.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                           WheelsExposure =  WheelsExposure +  (bankAccountRecord.POS__c!=null ? bankAccountRecord.POS__c : 0);
                                       }
                                }
                                //Account Type for ODCC 
                                if(bankAccountRecord.Account_Type__c == GlobalConstants.ODCC && bankAccountRecord.Include_In_Exposure__c == 'Yes'){
                                    TotalExposure = TotalExposure +  (bankAccountRecord.OD_Limit_Sanctioned__c!=null ? bankAccountRecord.OD_Limit_Sanctioned__c :0  );
                                    FinalExposure = applicantInstance.Total_Exposure__c; 
                                }
                                bankInsertList.add(bankAccountRecord);
                                // applicantList.add(applicantInstance);
                            }
                        }
                    }
                }
                
                
                Decimal totalLatestExposure =0;
                Decimal totalLatestWheelsExposure=0;
                if (!bankUpdateList.isEmpty() && Schema.SObjectType.Bank_Account_Records__c.isUpdateable()) {
                    update bankUpdateList;
                    //Update Exposure on Applicant with the existing exposure + newly calculated exposure
                    // totalLatestExposure = TotalExposure + applicantInstance.Total_Exposure__c;
                    //totalLatestWheelsExposure= WheelsExposure + applicantInstance.Wheels_Exposure__c;
                }
                
                if (!bankInsertList.isEmpty() && Schema.SObjectType.Bank_Account_Records__c.isCreateable()) {
                    insert bankInsertList;
                    //Update Exposure on Applicant with the newly calculated exposure
                    
                }
                
                // totalLatestExposure = TotalExposure;
                //totalLatestWheelsExposure= WheelsExposure;
                
                Applicant__c applicantUpdatedFinalInstance =  handleExistingLoanDetails(applicantInstance,loanId,strProducttoPurchase,TotalExposure,WheelsExposure);
                
                //Update dpd checbox and date  dpdChecked
                
                //Update the total value on Loan 
                if(dpdCheckList.contains(true) ){
                    loanApplication.Dpd_Found__c = true;
                    wrapperInstance.dpdFound = true;
                }else{
                    loanApplication.Dpd_Found__c = false;
                    wrapperInstance.dpdFound = false;
                }
                
                if( Schema.SObjectType.Loan_Application__c.isUpdateable()){
                    update loanApplication;
                }
                
                if(boolCreateDeviation){
                    createDeviation(loanId);
                }
                
                //Update all the values to loan Application 
                // LeadDedupeController.updateLoanApplication(strloanID);
                
                //Update Exposure on Applicant
                //List<Applicant__c> applicantUpdatedList = handleApplicantExposure(TotalExposure,WheelsExposure,applicantInstance.Id);
                
                
            } else {
                wrapperInstance.error = calloutResponseWrapper.response;
            }
            return wrapperInstance;
            
        } catch (Exception ex) {
            Log.error('Error in CustomerSummaryController :: ' + ex.getLineNumber() + ' ? ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    //Method to check the existing loan details 
    public static Applicant__c handleExistingLoanDetails(Applicant__c applicantInstance1, Id loanId, String strProducttoPurchase, Decimal TotalExposure,Decimal WheelsExposure) {
        
        List < exposureWrapper > wrapperNewList = new List < exposureWrapper > ();
        
        String exposureJSON = applicantInstance1.SF_Exposure_JSON__c;
        String loanRecordType = applicantInstance1.Loan__r.RecordType.Name; 
        Map < String, exposureWrapper > exposureOldMap = exposureJSON!=null ? getExposureMap(exposureJSON) : null;
        
        Applicant__c applicantExposureInstance = LeadDedupeController.checkExistingLoans(applicantInstance1, strProducttoPurchase, String.valueof(loanId));
        String exposureJSONNew = applicantExposureInstance.SF_Exposure_JSON__c;
        //String exposureJSONNew = '[{\"SanctionDate\":null,\"Product\":\"AutoLoan(New)\",\"LoanAmount\":\"500.00\",\"includeInExposure\":\"Yes\",\"customerName\":null,\"creditOverrideAuthority\":true,\"applicationNumber\":\"0000003401\"}]';
        Map < String, exposureWrapper > exposureNewMap = getExposureMap(exposureJSONNew);
        
        Set<String> setFourWheeler = new Set<String>();
        setFourWheeler.add(GlobalConstants.FOURWHEELER);
        setFourWheeler.add(GlobalConstants.TRACTOR);
        setFourWheeler.add(GlobalConstants.COMMERCIALVEHICLE);
        setFourWheeler.add(GlobalConstants.CONSTRUCTIONEQUIP);
        
        // Decimal TotalExposure = 0;
        if(exposureOldMap!=null){
            for (String key: exposureOldMap.keySet()) {
                // If the same key exists in exposureNewMap
                if (exposureNewMap.containsKey(key)) {
                    // Update the LoanAmount 
                    exposureWrapper oldExposure = exposureOldMap.get(key);
                    exposureWrapper newExposure = exposureNewMap.get(key);
                    oldExposure.LoanAmount = newExposure.loanAmount;
                    wrapperNewList.add(oldExposure);
                    if (oldExposure.includeInExposure == 'Yes') {
                        TotalExposure = TotalExposure + Decimal.valueof(oldExposure.LoanAmount);
                        if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && loanRecordType == GlobalConstants.TWOWHEELER) {
                            WheelsExposure = WheelsExposure + Decimal.valueof(oldExposure.LoanAmount);
                            
                        }
                        //if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (loanRecordType == GlobalConstants.FOURWHEELER ||
                        //loanRecordType == GlobalConstants.TWOWHEELER)) {
                        if (setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c) && (setFourWheeler.contains(loanRecordType) ||
                        loanRecordType == GlobalConstants.TWOWHEELER)) {
                            WheelsExposure = WheelsExposure + Decimal.valueof(oldExposure.LoanAmount);
                        }
                    }
                    
                } else {
                    // Add the old exposure to resultMap
                    wrapperNewList.add(exposureOldMap.get(key));
                    if (exposureOldMap.get(key).includeInExposure == 'Yes') {
                        TotalExposure = TotalExposure + Decimal.valueof(exposureOldMap.get(key).LoanAmount);
                        if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && loanRecordType== GlobalConstants.TWOWHEELER) {
                            WheelsExposure = WheelsExposure + Decimal.valueof(exposureOldMap.get(key).LoanAmount);
                            
                        }
                        //if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (loanRecordType == GlobalConstants.FOURWHEELER ||
                        //loanRecordType == GlobalConstants.TWOWHEELER)) {
                        if (setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c) && (setFourWheeler.contains(loanRecordType) ||
                                                                                                                                                                   loanRecordType == GlobalConstants.TWOWHEELER)) {
                                                                                                                                                                       WheelsExposure = WheelsExposure + Decimal.valueof(exposureOldMap.get(key).LoanAmount);
                                                                                                                                                                   }
                    }
                }
            }
        }
        
        
        // Iterate over each key in exposureNewMap
        for (String key: exposureNewMap.keySet()) {
            // If the key does not exist in exposureOldMap
            if(exposureOldMap!=null){
                if (!exposureOldMap.containsKey(key)) {
                    wrapperNewList.add(exposureNewMap.get(key));
                    if (exposureNewMap.get(key).includeInExposure == 'Yes') {
                        TotalExposure = TotalExposure + Decimal.valueof(exposureNewMap.get(key).LoanAmount);
                        if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && loanRecordType == GlobalConstants.TWOWHEELER) {
                            WheelsExposure = WheelsExposure + Decimal.valueof(exposureNewMap.get(key).LoanAmount);
                            
                        }
                        //if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (loanRecordType == GlobalConstants.FOURWHEELER ||
                        //loanRecordType == GlobalConstants.TWOWHEELER)) {
                        if (setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c) && (setFourWheeler.contains(loanRecordType) ||
                                                                                                                                                                   loanRecordType == GlobalConstants.TWOWHEELER)) {
                                                                                                                                                                       WheelsExposure = WheelsExposure + Decimal.valueof(exposureNewMap.get(key).LoanAmount);
                                                                                                                                                                   }
                    }
                    
                }
            }
        }
       // System.debug('finalexposure-->' + JSON.serialize(wrapperNewList));
        User objUser = [Select Id,Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
        Applicant__c applicantFinalInstance = new Applicant__c();
        applicantFinalInstance.Id = applicantInstance1.Id;
        applicantFinalInstance.SF_Exposure_JSON__c = JSON.serialize(wrapperNewList);
        applicantFinalInstance.Total_Exposure__c = TotalExposure;
        applicantFinalInstance.Wheels_Exposure__c = WheelsExposure;
        applicantFinalInstance.isExposureChanged__c = true;
        if(objUser.Profile.Name == 'Credit Manager' && applicantInstance1.Loan__r.Stage__c == 'Credit'){
            applicantFinalInstance.DPD_Check_Done_by_Credit__c = true;
        }
        if( Schema.SObjectType.Applicant__c.isUpdateable()){
            update applicantFinalInstance;
        }
        
        return applicantFinalInstance;
        
    }
    
    //Method to get the map of application number vs json details
    public static  Map<String,exposureWrapper>  getExposureMap(String exposureJSON){
        Map<String,exposureWrapper> exposureMap = new  Map<String,exposureWrapper> ();
        if(exposureJSON != null){
            List<exposureWrapper> exposureList = (List<exposureWrapper>) JSON.deserialize(exposureJSON, List<exposureWrapper>.class);
            for(exposureWrapper exposure : exposureList){
                if(!exposureMap.containsKey(exposure.applicationNumber)){
                    exposureMap.put(exposure.applicationNumber,exposure);
                }
                
            }
        }
        return exposureMap;
    }   
    
    //Method to handle Credit Response Details
    @AuraEnabled
    public static Boolean handleCCExposure(String strCustomerId, String strApplicantId, String creditBankRecords) {
         Boolean breVal = false;
         Boolean blnCCDPDFound = false;
        try {
            Decimal TotalExposure=0;
            Decimal FinalExposure=0;
            Decimal WheelsExposure=0; 
            
            Map < String, List < Bank_Account_Records__c >> bankAccountMap = getBankAccountMap(strApplicantId,'CC');
            List < Bank_Account_Records__c > bankUpdationRecords = new List < Bank_Account_Records__c > ();
            List < Bank_Account_Records__c > bankInsertionRecords = new List < Bank_Account_Records__c > ();
            
            Map < String, Object > creditResponseMap = (Map < String, Object > ) JSON.deserializeUntyped(creditBankRecords);
            List < Object > creditListRecord = (List < Object > ) creditResponseMap.get('CreditCardResponse');
            
            //Update applicant exposurechanged checkbox
            //Applicant__c applicantInstance =  applicantUpdation(strApplicantId);
            /*Applicant__c applicantInstance =   [SELECT id,Total_Exposure__c,Final_Exposure__c,Wheels_Exposure__c,Loan__c,isExposureChanged__c,Credit_Approved_Exposure__c,RecordTypeId,SF_Exposure_JSON__c ,Loan__r.RecordType.Name
FROM Applicant__c 
WHERE id=:strApplicantId WITH SECURITY_ENFORCED];*/
            Applicant__c applicantInstance =getApplicantInstance(strApplicantId);
            TotalExposure=applicantInstance.Total_Exposure__c;
            FinalExposure = TotalExposure;
            WheelsExposure = applicantInstance.Wheels_Exposure__c;
            if(creditListRecord!=null){
                for (Object objInstance: creditListRecord) {
                    Map < String, Object > credtMap = (Map < String, Object > ) objInstance;
                    String accountNumber = credtMap.get('AccountStatus') != null ? (String) credtMap.get('AccountNumber') : '';
                    if (bankAccountMap.containsKey(accountNumber)) {
                        List < Bank_Account_Records__c > records = bankAccountMap.get(accountNumber);
                        
                        for (Bank_Account_Records__c recordInstance: records) {
                            Bank_Account_Records__c bankInstance = new Bank_Account_Records__c();
                            bankInstance.Id = recordInstance.Id;
                            bankInstance.Sanctioned_Amount__c = Decimal.valueof((String) credtMap.get('SanctionedAmount'));
                            if(recordInstance.Include_In_Exposure__c == 'Yes' && bankInstance.Sanctioned_Amount__c!=null){                       
                                TotalExposure =TotalExposure + bankInstance.Sanctioned_Amount__c;
                                //FinalEx= objApplicant.Total_Exposure__c;
                            }
                            //bankInstance.Sanctioned_Amount__c = 2000;
                            bankUpdationRecords.add(bankInstance);
                        }
                    } else {
                        Bank_Account_Records__c recordNewInstance = new Bank_Account_Records__c();
                        recordNewInstance.Account_Number__c = accountNumber;
                        String accountDate = credtMap.get('AccountOpenDate') != null ? (String) credtMap.get('AccountOpenDate') : '';
                        if (String.isNotBlank(accountDate)) {
                            recordNewInstance.Account_Opening_Date__c = Date.valueof(accountDate);
                        }
                        recordNewInstance.Applicant__c = strApplicantId;
                        recordNewInstance.Current_Status__c = credtMap.get('AccountStatus') != null ? (String) credtMap.get('AccountStatus') : '';
                        recordNewInstance.Customer_Relationship__c = credtMap.get('CustomerAccountRelation') != null ? (String) credtMap.get('CustomerAccountRelation') : '';
                        recordNewInstance.Account_Name__c = credtMap.get('CustomerFullName') != null ? (String) credtMap.get('CustomerFullName') : '';
                        recordNewInstance.Customer_Id__c = credtMap.get('CustomerID') != null ? (String) credtMap.get('CustomerID') : '';
                        recordNewInstance.Product__c = credtMap.get('Decode') != null ? (String) credtMap.get('Decode') : '';
                        recordNewInstance.DPP_Value__c = credtMap.get('DPDValue') != null ? (String) credtMap.get('DPDValue') : '';
                        blnCCDPDFound = (blnCCDPDFound ? blnCCDPDFound : ((String.isNotEmpty(recordNewInstance.DPP_Value__c) && Integer.valueOf(recordNewInstance.DPP_Value__c) > 0) ? true : false));
                        recordNewInstance.Last_Statement_Balance__c = credtMap.get('LastStatementBalance') != null ? (String) credtMap.get('LastStatementBalance') : '';
                        recordNewInstance.Status__c = credtMap.get('LoanStatus') != null ? (String) credtMap.get('LoanStatus') : '';
                        recordNewInstance.Sanctioned_Amount__c = credtMap.get('SanctionedAmount') != null ? Decimal.valueof((String) credtMap.get('SanctionedAmount')) : 0;
                        recordNewInstance.RecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get(GlobalConstants.BANK_ACCOUNT_RECORDS), GlobalConstants.CBS);
                        recordNewInstance.Account_Type__c = 'CC';
                        //Check Exposure
                        recordNewInstance =  LeadDedupeController.checkForExposure(recordNewInstance ,applicantInstance );
                        if(recordNewInstance.Include_In_Exposure__c == 'Yes'){                       
                            TotalExposure =TotalExposure + recordNewInstance.Sanctioned_Amount__c;
                            //FinalEx= objApplicant.Total_Exposure__c;
                        }
                        bankInsertionRecords.add(recordNewInstance);
                    }
                }
            }
            
            Decimal totalLatestExposure =0;
            If(!bankUpdationRecords.isEmpty() && Schema.SObjectType.Bank_Account_Records__c.isUpdateable()) {
                update bankUpdationRecords;
                
            }
            
            If(!bankInsertionRecords.isEmpty() && Schema.SObjectType.Bank_Account_Records__c.isCreateable()) {
                insert bankInsertionRecords;
                //totalLatestExposure = TotalExposure;
            }
            //Update Exposure on Applicant with the existing exposure + newly calculated exposure (exposure calculated from odcc and loan)
            totalLatestExposure = TotalExposure + applicantInstance.Total_Exposure__c;
            
            
            //Update newly calculated exposureDetails on applicant
            List<Applicant__c> applicantUpdatedList =  handleApplicantExposure(TotalExposure,applicantInstance.Wheels_Exposure__c,applicantInstance.Id);
            //Update all the values to loan Application 
            LeadDedupeController.blnDPDFoundCC = blnCCDPDFound;
            LeadDedupeController.updateLoanApplication(applicantInstance.Loan__c);
           
            if(handleBRE(applicantUpdatedList) == true){
                breVal=true;
            }else{
                breVal =  false;
            }
            Applicant__c applicantInstance1 =  applicantUpdation(strApplicantId);
            
            
            
            
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
           // throw new AuraHandledException(e.getMessage());
        }
        return breVal;
    }
    
    //Method to shoe BRE or not
    public static Boolean handleBRE(List<Applicant__c> applicantUpdatedList){
        Applicant__c applicant  = new Applicant__c();
        Loan_Application__c LoanInstance = new  Loan_Application__c();
        if(!applicantUpdatedList.isEmpty()){
            
            applicant = getApplicantInstance(applicantUpdatedList[0].Id);
            if(applicant!=null){
                
                LoanInstance =   getLoanApplicationInstance(applicant.Loan__c);                 
            }
            
        }
        if( (applicant.Total_Exposure__c> applicant.Credit_Approved_Exposure__c)  && (LoanInstance.Stage__c == 'PSD')){
            return true;
        }else{
            return false;
        }
        
    } 
    
    //Method to update total exposure on Applicant 
    public static  List < Applicant__c > handleApplicantExposure(Decimal TotalExposure, Decimal WheelsExposure, String applicantId) {
        List < Applicant__c > applicantList = new List < Applicant__c > ();
        Applicant__c applicantNewInstance = new Applicant__c();
        applicantNewInstance.Id = applicantId;
        applicantNewInstance.Total_Exposure__c = TotalExposure;
        applicantNewInstance.Final_Exposure__c = TotalExposure;
        applicantNewInstance.Wheels_Exposure__c = WheelsExposure;
        applicantList.add(applicantNewInstance);
        if (!applicantList.isEmpty() && Schema.SObjectType.Applicant__c.isUpdateable()) {
            update applicantList;
        }
        
        return applicantList;
        
    }
    
    public static Applicant__c applicantUpdation(String recordId){
        try{
            /*Applicant__c applicantInstance =  [SELECT id,Total_Exposure__c,Final_Exposure__c,Wheels_Exposure__c,Loan__c,isExposureChanged__c,Credit_Approved_Exposure__c,RecordTypeId,SF_Exposure_JSON__c ,Loan__r.RecordType.Name
FROM Applicant__c 
WHERE id=:recordId WITH SECURITY_ENFORCED];*/
            
            Applicant__c applicantInstance = getApplicantInstance(recordId);
            
            if(applicantInstance!=null){
                Loan_Application__c loanInstance =   getLoanApplicationInstance(applicantInstance.Loan__c);
                /*Loan_Application__c loanInstance = [SELECT id,Final_Exposure__c,isExposureChanged__c,Credit_Approved_Exposure__c 
FROM Loan_Application__c
WHERE Id=:applicantInstance.Loan__c WITH SECURITY_ENFORCED]; */
                
                Applicant__c applicant = new Applicant__c();
                applicant.Id = applicantInstance.Id;
                //applicant.isExposureChanged__c = true;
                applicant.Credit_Approved_Exposure__c = applicantInstance.Total_Exposure__c;
                if(Schema.SObjectType.Bank_Account_Records__c.isUpdateable()){
                    update applicant;
                }
                
                Loan_Application__c loanApplicant = new Loan_Application__c();
                loanApplicant.Id = loanInstance.Id;
                loanApplicant.isExposureChanged__c = true;
                //loanApplicant.Credit_Approved_Exposure__c = loanInstance.Final_Exposure__c;
                loanApplicant.Credit_Approved_Exposure__c = applicantInstance.Total_Exposure__c;
                if(Schema.SObjectType.Loan_Application__c.isUpdateable()){
                    update loanApplicant;
                }
                
            }
            return applicantInstance;
        }
        catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public static Map < String, List < Bank_Account_Records__c >> getBankAccountMap (String applicantId,String accountType){
        List < Bank_Account_Records__c > bankRecords  = new  List < Bank_Account_Records__c >();
        If(String.isNotBlank(accountType)){
            bankRecords = [SELECT Id, No_of_Emi_Paid__c, Over_Limit_Amount__c, Loan_Overdue_EMI__c, RecordType.DeveloperName, Account_Type__c, Account_Number__c,Include_In_Exposure__c,Sanctioned_Amount__c
                           FROM Bank_Account_Records__c
                           WHERE RecordType.DeveloperName = 'CBS'
                           AND Account_Type__c =: accountType
                           AND Applicant__c =: applicantId WITH SECURITY_ENFORCED
                          ];
        } else{
            bankRecords = [SELECT Id, No_of_Emi_Paid__c, Over_Limit_Amount__c, Loan_Overdue_EMI__c, RecordType.DeveloperName, Account_Type__c, Account_Number__c,Include_In_Exposure__c,Product_Code__c,Sanctioned_Amount__c
                           FROM Bank_Account_Records__c
                           WHERE RecordType.DeveloperName = 'CBS'
                           AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];
        }   
        
        Map < String, List < Bank_Account_Records__c >> bankAccountMap = new Map < String, List < Bank_Account_Records__c >> ();
        for (Bank_Account_Records__c accountNumberInstance: bankRecords) {
            if (bankAccountMap.containsKey(accountNumberInstance.Account_Number__c)) {
                List < Bank_Account_Records__c > bankExistingRecords = bankAccountMap.get(accountNumberInstance.Account_Number__c);
                bankExistingRecords.add(accountNumberInstance);
                bankAccountMap.put(accountNumberInstance.Account_Number__c, bankExistingRecords);
            } else {
                bankAccountMap.put(accountNumberInstance.Account_Number__c, new List < Bank_Account_Records__c > {
                    accountNumberInstance
                        });
            }
        }
        return bankAccountMap;
    }
    
    //Common Method to return applicant based on applicantID
    public static Applicant__c getApplicantInstance(String applicantId) {
        Applicant__c applicantInstance = [SELECT id, Total_Exposure__c, Final_Exposure__c, Wheels_Exposure__c, Loan__c, Loan__r.Stage__c, isExposureChanged__c, Credit_Approved_Exposure__c, RecordTypeId, SF_Exposure_JSON__c, Loan__r.RecordType.Name
                                          FROM Applicant__c
                                          WHERE id =: applicantId WITH SECURITY_ENFORCED];
        
        return applicantInstance;
    }
    
    //Common Method to return loanapplication based on loanId
    public static Loan_Application__c getLoanApplicationInstance(String loanId){
        Loan_Application__c loanInstance = [SELECT id,Final_Exposure__c,isExposureChanged__c,Credit_Approved_Exposure__c,Stage__c,Product__c 
                                            FROM Loan_Application__c
                                            WHERE Id=:loanId WITH SECURITY_ENFORCED]; 
        return loanInstance;
    }
    
    public static void createDeviation(String loanId){
        List<Deviation__c> lstDeviationtoUpdate = new List<Deviation__c>();
        Map<String,Deviation__c> mapTypevsDeviation = new Map<String,Deviation__c>();
        for(Deviation__c objDeviation : [Select Id,Level__c,Details__c,Loan_Application__c,Active__c,Deviation_Type__c, Archived__c From Deviation__c where Loan_Application__c =:loanId AND Archived__c=false AND Active__c=true AND Deviation_Type__c='S5-DPD Deviation' WITH SECURITY_ENFORCED]){
            mapTypevsDeviation.put(objDeviation.Deviation_Type__c,objDeviation);
        }
        Deviation__c objDeviation = mapTypevsDeviation.get('S5-DPD Deviation');
        if(objDeviation == null){
            objDeviation = new Deviation__c();
        }
        objDeviation.Level__c = 'S5';
        objDeviation.Details__c = 'S5-DPD Deviation';
        objDeviation.Loan_Application__c = loanId;
        objDeviation.Deviation_Type__c = 'S5-DPD Deviation';
        objDeviation.Active__c = true;
        objDeviation.Source__c = 'SF';
        lstDeviationtoUpdate.add(objDeviation);
        DatabaseUtility.upsertRecords(lstDeviationtoUpdate,'');
    }
    
    public class loanDetailsResponseWrapper{
        @AuraEnabled public String AccountId {
            get;
            set;
        }
        
        @AuraEnabled public Integer balPrincipal {
            get;
            set;
        }
        
        @AuraEnabled public String error {
            get;
            set;
        }
        @AuraEnabled public Boolean dpdFound{
            get;
            set;
        }
        
        
        public loanDetailsResponseWrapper() {
            AccountId='';
            balPrincipal=0;
            error='';
        }
    }
    
    
    public class exposureWrapper{
        @AuraEnabled public String SanctionDate {
            get;
            set;
        }
        
        @AuraEnabled public String Product {
            get;
            set;
        }
        
        @AuraEnabled public String LoanAmount {
            get;
            set;
        }
        @AuraEnabled public String includeInExposure {
            get;
            set;
        }
        @AuraEnabled public String customerName {
            get;
            set;
        }
        @AuraEnabled public Boolean creditOverrideAuthority { // Change As per SFAU-4068 - String to Boolean
            get;
            set;
        }
        @AuraEnabled public String applicationNumber {
            get;
            set;
        }
        
        
        public exposureWrapper() {
            SanctionDate='';
            Product='';
            LoanAmount='';
            includeInExposure='';
            customerName='';
            creditOverrideAuthority=false; // Change As per SFAU-4068 - String to Boolean
            applicationNumber='';
            
        }
    }
}