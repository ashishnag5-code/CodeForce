/*****
 * Class Name: LeadDedupeController
 * Test Class Name: LeadDedupeController_Test
 * Logs ---- 
 * LastModified Date    -   Last Modified By    -   Description / Bug
 * Aug-26-2023          -   Mohit M.            -   SFAU-4934 - Copy IDDetails from Applicant to DocumentChecklist for CBS
 * Sep-05-2023          -   Mohit M.            -   SFAU-5110 - Fix - objBankAccount.Loan_Overdue_EMI__c = objCustomerOD.InstallmentsOverDue
 * Sep-05-2023          -   Mohit M.            -   SFAU-5168 - CUG||2||Credit||RAJ0000008796 LastModifiedDate added in query
 * Oct-05-2023          -   Mayur S.            -   SFAU-4052 - UAT || Credit || RAJ0000012628
 * Nov-17-2023          -   Mohit M.            -   SFAU-5592 - CIF Modification API  - PAN not to be passed in API if received from CBS
 * Dec-05-2023          -   Mohit M.            -   SFAU-5701 - NoOfEMIPaid for LOAN OD Details
 * Dec-15-2023          -   Mohit M.            -   SFAU-5730 - Fix DPD logic for Credit Card
 * Dec-21-2023          -   Mohit M.            -   SFAU-5783 - This customer is Existing customer but in SFDC showing existing customer NO.
 * 
*/
public without sharing class LeadDedupeController {
    //SFAU-5730 - Fix DPD logic for Credit Card
    public static Boolean blnDPDFoundCC = false;

    @AuraEnabled
    public static List<LeadDedupeWrapper.LeadtoLeadWrapper> getLeadtoLeadAppList(String strApplicantId, Boolean boolIsWizard) {
        LeadDedupeWrapper objWrapper = new LeadDedupeWrapper();
        List<LeadDedupeWrapper.LeadtoLeadWrapper> lstleadtoleadWrapper = new List<LeadDedupeWrapper.LeadtoLeadWrapper>();
        //SFAU-5783
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        try{
            String respBody;
            Applicant__c objApplicant = [SELECT Customer_Name__c,Loan__r.Branch_Master__r.Account_Code__c,Customer_Type__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c,Pan_Form60__c, CIF_No__c, 
                                             Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name FROM Applicant__c where Id=:strApplicantId AND IsInactive__c = false  WITH SECURITY_ENFORCED limit 1];
                
            if(boolIsWizard){
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(GlobalConstants.LEADTOLEADDEDUPE);
                String requestBody = LeadtoLeadIntegrationHandler.generateRequest(objApplicant)[0];
                String objectId = '';
                // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
            }
            else{
                //Integration_Checklist__c checklistRecord = [Select Id,Response__c,Applicant__c,Is_Latest__c,Integration_Master__r.Name from Integration_Checklist__c 
                //                                        where Applicant__c =:strApplicantId and Integration_Master__r.Name = GlobalConstants.CUSTOMERDEDUPE and Is_Latest__c = true WITH SECURITY_ENFORCED limit 1];
                respBody = getResponsefromCheckList(strApplicantId,GlobalConstants.CUSTOMERDEDUPE);
                //respBody = checklistRecord.Response__c;
            }
            //Hardcode for Demo - Start
            /*if(!Test.isRunningTest()){
                List<Integration_Checklist__c> lstIC = [Select Id,Response__c from Integration_Checklist__c where Id='a0D6s000002iZMj' WITH SECURITY_ENFORCED limit 1];
                if(!lstIC.isEmpty()){
                    respBody = lstIC[0].Response__c;
                }
            }*/
            //Hardcode for Demo - End
            LeadtoLeadIntegrationHandler.LeadtoLeadResponseWrapper objResultWrapper
                = (LeadtoLeadIntegrationHandler.LeadtoLeadResponseWrapper) System.JSON.deserialize(respBody, LeadtoLeadIntegrationHandler.LeadtoLeadResponseWrapper.class);
            lstleadtoleadWrapper = LeadtoLeadIntegrationHandler.mapIntWraptoUIWrap(objResultWrapper,objApplicant);
        }
        catch(Exception objException) {
            //SFAU-5783
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL) {
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('LeadDedupeController :: getLeadtoLeadAppList :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return lstleadtoleadWrapper;
    }

    @AuraEnabled
    public static LeadDedupeWrapper.leadCBSDedupeWrapper getCBSApplicantList(String strApplicantId, Boolean boolIsWizard) {
        LeadDedupeWrapper objWrapper = new LeadDedupeWrapper();
        LeadDedupeWrapper.leadCBSDedupeWrapper objCBSWrapper = new LeadDedupeWrapper.leadCBSDedupeWrapper();
        // SFAU-5783
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        try{
            String respBody;
            Applicant__c objApplicant = [SELECT Customer_Name__c,Loan__r.Branch_Master__r.Account_Code__c,Customer_Type__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c ,Pan_Form60__c, CIF_No__c, 
                                             Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name,KYC_Status__c,KYC_Type__c,Bureau_Score__c, Loan__r.Stage__c FROM Applicant__c where Id=:strApplicantId AND IsInactive__c = false   WITH SECURITY_ENFORCED limit 1];
                
            if(boolIsWizard){
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(GlobalConstants.CUSTOMERDEDUPE);
                String requestBody = LeadDedupeIntegrationHandler.generateRequest(objApplicant)[0];
                String objectId = '';
                // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
            }
            else{
                //Integration_Checklist__c checklistRecord = [Select Id,Response__c,Applicant__c,Is_Latest__c,Integration_Master__r.Name from Integration_Checklist__c 
                //                                        where Applicant__c =:strApplicantId and Integration_Master__r.Name = GlobalConstants.CUSTOMERDEDUPE and Is_Latest__c = true WITH SECURITY_ENFORCED limit 1];
                respBody = getResponsefromCheckList(strApplicantId,GlobalConstants.CUSTOMERDEDUPE);
                //respBody = checklistRecord.Response__c;
            }
            //Hardcode for Demo - Start
            /*if(!Test.isRunningTest()){
                List<Integration_Checklist__c> lstIC = [Select Id,Response__c from Integration_Checklist__c where Id='a0D6s000002iZMj' WITH SECURITY_ENFORCED limit 1];
                if(!lstIC.isEmpty()){
                    respBody = lstIC[0].Response__c;
                }
            }*/
            //Hardcode for Demo - End
            LeadDedupeIntegrationHandler.DedupeSearchResultWrapper objResultWrapper
                = (LeadDedupeIntegrationHandler.DedupeSearchResultWrapper) System.JSON.deserialize(respBody, LeadDedupeIntegrationHandler.DedupeSearchResultWrapper.class);
            objCBSWrapper = LeadDedupeIntegrationHandler.mapSearchIntWraptoUIWrap(objResultWrapper,objApplicant);
            if(objCBSWrapper.applicantList_fullMatch.size() > 0){
                objApplicant.Is_Lead_To_Customer_Full_Match__c = true;
            }
            if(objCBSWrapper.applicantList_partialMatch.size() > 0){
                objApplicant.Is_Lead_To_Customer_Partial_Match__c = true;
            }
            update objApplicant;
        }
        catch(Exception objException) {
            //SFAU-5783
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL) {
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('LeadDedupeController :: getCBSApplicantList :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return objCBSWrapper;
    }
    
    @AuraEnabled
    public static LeadDedupeWrapper.CustomerDetailWrapper getCBSApplicantDetail(String strCustomerId, String strApplicantId, String cardName, Integer countFull) {
        LeadDedupeWrapper.CustomerDetailWrapper objDetailWrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        //SFAU-5783
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        try{
            Applicant__c objApplicant = [SELECT Customer_Name__c,Loan__r.Branch_Master__r.Account_Code__c,Customer_Type__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c, Pan_Form60__c, CIF_No__c,CBS_Status__c, 
                                             Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name, Bureau_Score__c, Loan__r.Stage__c FROM Applicant__c where Id=:strApplicantId AND IsInactive__c = false  WITH SECURITY_ENFORCED limit 1];

            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(GlobalConstants.CUSTOMERDEDUPEDETAIL);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            String respBody;
            Map<String,String> mapCustIdvsType = new Map<String,String>();
            mapCustIdvsType.put('Bank Account', strCustomerId);
            mapCustIdvsType.put('TransactionBranch', objApplicant.Loan__r.Branch_Master__r.Account_Code__c);
            String requestBody = LeadDedupeIntegrationHandler.generateRequest(mapCustIdvsType)[0];
            String objectId = '';
            //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
           
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            //Hardcode for Demo - Start
            /*if(!Test.isRunningTest()){
                List<Integration_Checklist__c> lstIC = [Select Id,Response__c from Integration_Checklist__c where Id='a0D6s000002iZMsEAM' WITH SECURITY_ENFORCED limit 1];
                if(!lstIC.isEmpty()){
                    respBody = lstIC[0].Response__c;
                }
            }*/
            //Hardcode for Demo - End
            LeadDedupeIntegrationHandler.DedupeDetailResultWrapper objResultWrapper
                = (LeadDedupeIntegrationHandler.DedupeDetailResultWrapper) System.JSON.deserialize(respBody, LeadDedupeIntegrationHandler.DedupeDetailResultWrapper.class);
            
            
            objDetailWrapper = LeadDedupeIntegrationHandler.mapDetailIntWraptoUIWrap(objResultWrapper, cardName, objApplicant,countFull);
        }
        catch(Exception objException) {
            //SFAU-5783
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL) {
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('LeadDedupeController :: getCBSApplicantDetail :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return objDetailWrapper;
    }
    
    @AuraEnabled
    public static LeadDedupeWrapper.leadCBSCreditCardWrapper getCCResponse(String strCustomerId, String strApplicantId) {
        String respBody;
        LeadDedupeWrapper.leadCBSCreditCardWrapper objDetailWrapper = new LeadDedupeWrapper.leadCBSCreditCardWrapper();
        //SFAU-5783
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        //LeadDedupeWrapper.CustomerDetailWrapper objDetailWrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(GlobalConstants.CUSTOMERDEDUPECREDITCARD);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            //String respBody;
            Map<String,String> mapCustIdvsType = new Map<String,String>();
            mapCustIdvsType.put('Credit Card', strCustomerId);
            String requestBody = LeadDedupeIntegrationHandler.generateRequest(mapCustIdvsType)[0];
            String objectId = '';
            //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
           
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            //respBody = '{"CreditCardResponse":[{"CustomerID":"25479697","CustomerAccountRelation":"Sole Owner","AccountNumber":"0001691023625986272","LoanStatus":"Standard","CustomerFullName":null,"ProductCode":"102","Decode":"ALTURA PLUS","AccountOpenDate":"2021-07-23 00:00:00","AccountStatus":"ACCOUNT OPEN REGULAR","SanctionedAmount":"90000","DPDValue":"0","LastStatementBalance":"12,656.00"}]}';
            //respBody = '';
            objDetailWrapper
                = (LeadDedupeWrapper.leadCBSCreditCardWrapper) System.JSON.deserialize(respBody, LeadDedupeWrapper.leadCBSCreditCardWrapper.class);
        }
        catch(Exception objException) {
            //SFAU-5783
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL) {
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('LeadDedupeController :: getCCResponse :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return objDetailWrapper;
    }
    
    public class CustomerODResponseWrapper {
        @AuraEnabled public Boolean boolIsDPDFound{get;set;}   //25479697
        //@AuraEnabled public LeadDedupeIntegrationHandler.CustomerODResponse objDetailWrapper{get;set;}  //Sole Owner
        @AuraEnabled public String AccountNo{get;set;}
        @AuraEnabled public Integer InstallmentsOverDue{get;set;}
        @AuraEnabled public Decimal PrincipalBalance{get;set;}
        // SFAU-5701 - NoOfEMIPaid Mapping Mohit M.
        @AuraEnabled public Integer TotalNoOfInstallmentsReceived {get;set;}
    }
    
    @AuraEnabled
    public static List<CustomerODResponseWrapper> getCustomerODResponse(String strCustomerId, String strApplicantId) {
        Boolean boolIsDPDFound = false;
        String respBody;
        LeadDedupeIntegrationHandler.CustomerODResponse objDetailWrapper = new LeadDedupeIntegrationHandler.CustomerODResponse();
        List<CustomerODResponseWrapper> lstCustomerODResponseWrapper = new List<CustomerODResponseWrapper>();
        CustomerODResponseWrapper objCustomerODResponseWrapper = new CustomerODResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = NULL;
        //LeadDedupeWrapper.CustomerDetailWrapper objDetailWrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        try{
            Applicant__c objApplicant = [SELECT Customer_Name__c,Loan__r.Branch_Master__r.Account_Code__c,Customer_Type__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c, Pan_Form60__c, CIF_No__c, 
                                             Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name FROM Applicant__c where Id=:strApplicantId  AND IsInactive__c = false  WITH SECURITY_ENFORCED limit 1];

            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Loan OD Detail');
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Map < String, Object > reqParam = new Map < String, Object > ();
            //REQUEST FORMING
            reqParam.put('Channel', Label.Dedup_Channel);
            reqParam.put('TransactionBranch', objApplicant.Loan__r.Branch_Master__r.Account_Code__c);
            reqParam.put('CustomerId', strCustomerId); //strCustomerId 22570632  27972650
            String requestBody = LoanDetailsHandler.generateLoanODDetails(reqParam)[0];
            //String objectId = '';
            //respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,strApplicantId);
           
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            //respBody = '{"CreditCardResponse":[{"CustomerID":"25479697","CustomerAccountRelation":"Sole Owner","AccountNumber":"0001691023625986272","LoanStatus":"Standard","CustomerFullName":null,"ProductCode":"102","Decode":"ALTURA PLUS","AccountOpenDate":"2021-07-23 00:00:00","AccountStatus":"ACCOUNT OPEN REGULAR","SanctionedAmount":"90000","DPDValue":"0","LastStatementBalance":"12,656.00"}]}';
            //respBody = '';
            objDetailWrapper
                = (LeadDedupeIntegrationHandler.CustomerODResponse) System.JSON.deserialize(respBody, LeadDedupeIntegrationHandler.CustomerODResponse.class);

            if(objDetailWrapper != null && objDetailWrapper.AccountDetail != null && !objDetailWrapper.AccountDetail.isEmpty()){
                for(LeadDedupeIntegrationHandler.CustomerODAccountDetail objCustomerODAccountDetail : objDetailWrapper.AccountDetail){
                    if(objCustomerODAccountDetail.LoanAccountDetails != null && !objCustomerODAccountDetail.LoanAccountDetails.isEmpty()){
                        for(LeadDedupeIntegrationHandler.CustomerODLoanAccountDetails objCustomerODLoanAccountDetails : objCustomerODAccountDetail.LoanAccountDetails){
                            objCustomerODResponseWrapper = new CustomerODResponseWrapper();
                            if(objCustomerODLoanAccountDetails.InstallmentsOverDue > 0){
                                 objCustomerODResponseWrapper.boolIsDPDFound = true;
                            }
                            objCustomerODResponseWrapper.AccountNo = objCustomerODLoanAccountDetails.AccountNo;
                            objCustomerODResponseWrapper.InstallmentsOverDue = objCustomerODLoanAccountDetails.InstallmentsOverDue;
                            objCustomerODResponseWrapper.PrincipalBalance = objCustomerODLoanAccountDetails.PrincipalBalance;
                            // SFAU-5701 - NoOfEMIPaid Mapping Mohit M.
                            objCustomerODResponseWrapper.TotalNoOfInstallmentsReceived = objCustomerODLoanAccountDetails.TotalNoOfInstallmentsReceived;
                            lstCustomerODResponseWrapper.add(objCustomerODResponseWrapper);
                        }
                    }
                }
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            if (calloutResponseWrapper != NULL && calloutResponseWrapper.checklistRecord != NULL) {
                upsert calloutResponseWrapper.checklistRecord;
            }
            Log.error('LeadDedupeController :: getCustomerODResponse :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return lstCustomerODResponseWrapper;
    }
    
    @AuraEnabled
    public static list<LeadCRMDedupeWrapper> getCRMApplicantList(String applicantId, Boolean boolIsWizard){
        list<LeadCRMDedupeWrapper> wrapper = new list<LeadCRMDedupeWrapper>();
        try{
            LeadCRMDedupeWrapper objwrapper;
            if(applicantId!=null && boolIsWizard){
                List<Applicant__c> loanList = [ SELECT id,Customer_Type__c,NREGA__c,loan__r.Branch_Name__c,Mobile_Number__c,RecordType.Name,CIF_No__c,Aadhaar_Number__c,PAN__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,toLabel(Loan__r.Product__c),Loan__r.Customer_Name__c, Loan__c
                                               FROM Applicant__c
                                               WHERE id=:applicantId AND IsInactive__c = false 
                                               WITH SECURITY_ENFORCED 
                                               LIMIT 1];
                Applicant__c objApptoUpdate = loanList[0];
                //SFAU-5052
                objApptoUpdate.Is_Lead_To_Lead_Full_Match__c = false;
                objApptoUpdate.Is_Lead_To_Lead_Partial_Match__c = false;
                //get the existing application records for the same product and same customer irrespective of the user
                String coRecordTypeID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get(GlobalConstants.COAPPLICANT).getRecordTypeId();
                String guRecordTypeID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get(GlobalConstants.GUARANTOR).getRecordTypeId();
                String addMatchRecordTypeID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Additional Match').getRecordTypeId();
                String nomineeRecordTypeID = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Nominee').getRecordTypeId();

                
                Boolean sameProductDeviation =false;
                Boolean diffProductSameRO = false;
                Boolean diffProductDifferRO = false; 
                String loggedUserId = Userinfo.getUserID();
                
                String strQuery = createApplicantQuery(loanList,true);
                String strProduct = ((loanList[0].Loan__r.Product__c)!=null)?loanList[0].Loan__r.Product__c:'';
                
                for(Applicant__c record : Database.query(strQuery)){
                    objwrapper = new LeadCRMDedupeWrapper();
                    objwrapper.applicant =  record;
                    List<String> stagesToConsider = System.Label.StagesForExistingWIPApplication.split(',');//R2-33 and R2-32
                    //validations check /*strCustomerName!='' && record.Customer_Name__c == strCustomerName && */
                    if(record.RecordTypeId !=coRecordTypeID && record.RecordTypeId !=guRecordTypeID && record.RecordTypeId !=addMatchRecordTypeID && record.RecordTypeId !=nomineeRecordTypeID && loanList[0].Customer_Type__c == record.Customer_Type__c){
                        if(record.Loan__r.Product__c == strProduct && record.CreatedById == loggedUserId ){
                            objwrapper.boolIsSameProduct = true;
                        }
                        else if(record.Loan__r.Product__c == strProduct && record.CreatedById != loggedUserId && stagesToConsider.contains(record.Loan_Stage__c)){
                        /*(record.Loan_Stage__c ==GlobalConstants.QDE || record.Loan_Stage__c == 'DDE' || 
                                        record.Loan_Stage__c == 'Credit' ||record.Loan_Stage__c == 'Pricing' || record.Loan_Stage__c == 'PSD' || record.Loan_Stage__c == 'Ops Maker' || record.Loan_Stage__c == 'Ops Author' || record.Loan_Stage__c ==GlobalConstants.PDD )){*/
                            //commented above stage checks as per R2-33 and R2-32
                            objwrapper.boolIsSameProduct = true;
                                objwrapper.boolBlockNext = true; //uncommented as a part of R2-33 and R2-32
                                objwrapper.message = getMessage(loanList[0].Loan__c,loanList[0].Loan__r.Customer_Name__c,loanList[0].Loan__r.Branch_Name__c);//uncommented as a part of R2-33 and R2-32
                                //objwrapper.message = ''; commented as a part of R2-33 and R2-32
                            //block
                        }
                        else if(record.Loan__r.Product__c == strProduct && record.CreatedById != loggedUserId && (record.Loan_Stage__c ==GlobalConstants.CANCELLED|| record.Loan_Stage__c ==GlobalConstants.REJECTED )){
                            objwrapper.boolIsSameProduct = true;
                            sameProductDeviation = true;
                        }
                        else if(record.Loan__r.Product__c != strProduct && record.CreatedById ==loggedUserId){
                            objwrapper.boolIsDiffProductSameRO = true;
                            diffProductSameRO = true;
                        }
                        else if(record.Loan__r.Product__c != strProduct && record.CreatedById != loggedUserId){
                            objwrapper.boolIsDiffProductDiffRO = true;
                            diffProductDifferRO = true; 
                        }
                    }
                    //objwrapper.boolBlockNext = true;
                    objwrapper.boolIsSelected = false;
                    if(!String.isBlank(loanList[0].CIF_No__c) && (loanList[0].CIF_No__c == record.CIF_No__c)){ 
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = GlobalConstants.CIF;
                    }
                    else if((!String.isBlank(loanList[0].Aadhaar_Number__c) && loanList[0].Aadhaar_Number__c == record.Aadhaar_Number__c) 
                        && (!String.isBlank(loanList[0].PAN__c) && loanList[0].PAN__c == record.PAN__c)){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = GlobalConstants.AADHAARPAN;
                    }
                    else if(!String.isBlank(loanList[0].Aadhaar_Number__c) && loanList[0].Aadhaar_Number__c == record.Aadhaar_Number__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = GlobalConstants.AADHAAR;
                    }
                    else if(!String.isBlank(loanList[0].PAN__c) && loanList[0].PAN__c == record.PAN__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = GlobalConstants.PAN;
                    }
                    else if(!String.isBlank(loanList[0].Voter_Id__c) && loanList[0].Voter_Id__c == record.Voter_Id__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = 'Voter';
                    }
                    else if(!String.isBlank(loanList[0].Passport_Number__c) && loanList[0].Passport_Number__c == record.Passport_Number__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = 'Passport';
                    }
                    else if(!String.isBlank(loanList[0].Driving_License_Id__c) && loanList[0].Driving_License_Id__c == record.Driving_License_Id__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = 'Driving License';
                    }
                    else if(!String.isBlank(loanList[0].NREGA__c) && loanList[0].NREGA__c == record.NREGA__c){
                        objwrapper.boolIsFullMatch = true;
                        objwrapper.strMatchParam = 'NREGA';
                    }
                    if(loanList[0].Loan__c != record.Loan__c){
                        if(objwrapper.boolIsFullMatch){
                            objApptoUpdate.Is_Lead_To_Lead_Full_Match__c = true;
                        }
                        else{
                            objApptoUpdate.Is_Lead_To_Lead_Partial_Match__c = true;
                        }
                        wrapper.add(objwrapper);
                    }
                }
                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(GlobalConstants.LEADDEDUPESF);
                //Removed for File Storage issue
                IntegrationUtility.updateIntegrationChecklist(loanList[0].id,JSON.serialize(wrapper),200,objIntMapper.Id,strQuery);
                createDeviation(loanList[0].Loan__c, diffProductDifferRO, sameProductDeviation);
                update objApptoUpdate;
            }
            else if(applicantId!=null && !boolIsWizard){
                String respBody = getResponsefromCheckList(applicantId,GlobalConstants.LEADDEDUPESF);
                wrapper = (List<LeadDedupeController.LeadCRMDedupeWrapper>)JSON.deserialize(respBody, List<LeadDedupeController.LeadCRMDedupeWrapper>.class);
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: getCRMApplicantList :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantId);
        }
        return wrapper;
    }
    
    public static string getMessage(String loanId,String customerName,String branchName){
        Id newRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        Id usedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        List<Collateral__c> coll = new List<Collateral__c>();
        coll = [Select MMV_Master__r.Name FROM Collateral__c Where Loan__c=:loanId and (recordtypeid=:newRecordTypeId Or recordtypeid=:usedRecordTypeId)];
        String mmvName;
        If(coll.size()>0){
           mmvName= coll[0].MMV_Master__r.Name;
        }
        
        String message = customerName+ 'has already applied for a '+ mmvName + ' Loan at '+ branchName +'. You cannot proceed until that Loan Application is closed or disbursed.';
        return message;
    }
    private static String getResponsefromCheckList(String strApplicantId, String strEntityName){
        //SFAU-5168
        Integration_Checklist__c checklistRecord = [Select Id,Response__c,Applicant__c,Is_Latest__c,Integration_Master__r.Name,Is_Response_In_Attachment__c from Integration_Checklist__c 
                                                        where Applicant__c =:strApplicantId and Integration_Master__r.Name =:strEntityName and Is_Latest__c = true WITH SECURITY_ENFORCED order by LastModifiedDate desc limit 1];
        String respBody;
        if(checklistRecord.Is_Response_In_Attachment__c){
            ContentDocumentLink objDoc = [SELECT LinkedEntityId, ContentDocumentId, Id FROM ContentDocumentLink where LinkedEntityId = :checklistRecord.Id WITH SECURITY_ENFORCED limit 1];
            ContentVersion objBody = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :objDoc.ContentDocumentId AND IsLatest = true WITH SECURITY_ENFORCED limit 1];
            respBody = objBody.VersionData.tostring();
        }
        else{
            respBody = checklistRecord.Response__c;
        }
        return respBody;
    }
    
    public static String createApplicantQuery(List<Applicant__c> loanList, Boolean boolFormDedupe){
        String strQuery;
        try{
            if(!loanList.isEmpty()){
                strQuery = 'SELECT id, Name, NREGA__c, Customer_Type__c,Aadhaar_Number__c,PAN__c,CIF_No__c,Voter_Id__c,Passport_Number__c,RecordType.Name,Driving_License_Id__c,Loan__r.Account__r.Name,Loan__r.Name,Loan__r.RecordType.Name, RecordTypeId,Loan_Stage__c, Loan__r.Loan_Number__c,Loan__r.Application_Number__c, toLabel(Loan__r.Product__c), Loan__r.CreatedDate, Loan__r.Stage__c, Loan__r.Loan_Amount__c,Loan__r.Total_Loan_Amount__c,Loan__r.Loan_Sanction_date__c, Loan__r.Branch_Name__c,Loan__r.Customer_Name__c, Customer_Name__c, Mobile_Number__c, KYC_Status__c, CreatedById, CreatedBy.MobilePhone,CreatedBy.Name,CreatedDate  FROM Applicant__c ';
                if(boolFormDedupe){
                    //SFAU-5167 - Updated by Samridhi to exclude Additional Match and Nominee
                    strQuery = strQuery + 'WHERE Id != \''+ String.escapeSingleQuotes(loanList[0].id) +'\' AND Recordtype.DeveloperName NOT IN (\'Additional_Match\', \'Nominee\') AND CreatedDate = LAST_N_DAYS:'+Label.SFDedupeDateLiteral+' AND (';
                }
                else{
                    //SFAU-5167 - Updated by Samridhi to exclude Additional Match and Nominee
                    strQuery = strQuery + 'WHERE Id != \''+ String.escapeSingleQuotes(loanList[0].id) +'\'AND Recordtype.DeveloperName NOT IN (\'Additional_Match\', \'Nominee\')  AND (';                
                }
                strQuery = strQuery + 'IsInactive__c = false) AND (';
                //SFAU-4052 - Exclude mobile number from Exposure
                if(!String.isBlank(loanList[0].Mobile_Number__c) && boolFormDedupe){
                    strQuery = strQuery + 'Mobile_Number__c = \''+String.escapeSingleQuotes(loanList[0].Mobile_Number__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].PAN__c)){
                    strQuery = strQuery + 'PAN__c = \''+String.escapeSingleQuotes(loanList[0].PAN__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].CIF_No__c)){
                    strQuery = strQuery + ' CIF_No__c = \''+String.escapeSingleQuotes(loanList[0].CIF_No__c)+'\' OR ';
                }
                if(!String.isBlank(loanList[0].Customer_Type__c) && loanList[0].Customer_Type__c != 'Non Individual'){
                    if(!String.isBlank(loanList[0].Aadhaar_Number__c)){
                        strQuery = strQuery + ' Aadhaar_Number__c = \''+String.escapeSingleQuotes(loanList[0].Aadhaar_Number__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Voter_Id__c)){
                        strQuery = strQuery + ' Voter_Id__c = \''+String.escapeSingleQuotes(loanList[0].Voter_Id__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Passport_Number__c)){
                        strQuery = strQuery + ' Passport_Number__c = \''+String.escapeSingleQuotes(loanList[0].Passport_Number__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].Driving_License_Id__c)){
                        strQuery = strQuery + ' Driving_License_Id__c = \''+String.escapeSingleQuotes(loanList[0].Driving_License_Id__c)+'\' OR ';
                    }
                    if(!String.isBlank(loanList[0].NREGA__c)){
                        strQuery = strQuery + ' NREGA__c = \''+String.escapeSingleQuotes(loanList[0].NREGA__c)+'\' OR ';
                    }
                }
                /*if(!String.isBlank(loanList[0].Customer_Type__c) && loanList[0].Customer_Type__c == 'Non Individual'){
                    if(!String.isBlank(loanList[0].NREGA__c)){
                        strQuery = strQuery + ' NREGA__c = \''+String.escapeSingleQuotes(loanList[0].NREGA__c)+'\' OR ';
                    }
                }*/
                strQuery = strQuery.removeEnd('OR ');
                strQuery = strQuery + ')';
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: createApplicantQuery :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanList[0].Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanList[0].Id);
        }
        return strQuery;
    }
    
    private static void createDeviation(String strLoanId, Boolean diffProductDifferRO, Boolean sameProductDeviation){
        try{
            Map<String,Deviation__c> mapTypevsDeviation = new Map<String,Deviation__c>();
            for(Deviation__c objDeviation : [Select Id,Level__c,Details__c,Loan_Application__c,Active__c,Deviation_Type__c, Archived__c From Deviation__c where Loan_Application__c =:strLoanId AND Archived__c=false AND Active__c=true WITH SECURITY_ENFORCED]){
                mapTypevsDeviation.put(objDeviation.Deviation_Type__c,objDeviation);
            }
            
            List<Deviation__c> lstDeviationtoUpdate = new List<Deviation__c>();
            if(diffProductDifferRO){
                Deviation__c objDeviation = mapTypevsDeviation.get(GlobalConstants.SFDEDUPEDIFFERENTPRODUCT);
                if(objDeviation == null){
                    objDeviation = new Deviation__c();
                }
                objDeviation.Level__c = '';
                objDeviation.Details__c =GlobalConstants.SAMECUSTOMERHASADIFFERENTLEAD1;
                objDeviation.Loan_Application__c = strLoanId;
                objDeviation.Deviation_Type__c = GlobalConstants.SFDEDUPEDIFFERENTPRODUCT;
                objDeviation.Active__c = true;
                objDeviation.Source__c = 'SF';
                lstDeviationtoUpdate.add(objDeviation);
            }
            else {
                Deviation__c objDeviation = mapTypevsDeviation.get(GlobalConstants.SFDEDUPEDIFFERENTPRODUCT);
                if(objDeviation != null){
                    objDeviation.Active__c = false;
                    objDeviation.Archived__c = true;
                    lstDeviationtoUpdate.add(objDeviation);
                }
            }
            
            if(sameProductDeviation){
                Deviation__c objDeviation = mapTypevsDeviation.get(GlobalConstants.SFDEDUPESAMEPRODUCT);
                if(objDeviation == null){
                    objDeviation = new Deviation__c();
                }
                objDeviation.Level__c = '';
                objDeviation.Details__c = GlobalConstants.SAMECUSTOMERHASADIFFERENTLEAD2;
                objDeviation.Loan_Application__c = strLoanId;
                objDeviation.Deviation_Type__c = GlobalConstants.SFDEDUPESAMEPRODUCT;
                objDeviation.Active__c = true;
                objDeviation.Source__c = 'SF';
                lstDeviationtoUpdate.add(objDeviation);
            }
            else {
                Deviation__c objDeviation = mapTypevsDeviation.get(GlobalConstants.SFDEDUPESAMEPRODUCT);
                if(objDeviation != null){
                    objDeviation.Active__c = false;
                    objDeviation.Archived__c = true;
                    lstDeviationtoUpdate.add(objDeviation);
                }
            }
            //upsert lstDeviationtoUpdate;
            //Database.UpsertResult[] results = Database.upsert(lstDeviationtoUpdate);
            DatabaseUtility.upsertRecords(lstDeviationtoUpdate,'');
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: createDeviation :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strLoanId);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strLoanId);
        }
    }
    
    public class LeadCRMDedupeWrapper{
        @AuraEnabled public Applicant__c applicant{get;set;}
        @AuraEnabled public String strMatchParam{get;set;}
        @AuraEnabled public Boolean boolIsSameProduct{get;set;}
        @AuraEnabled public Boolean boolIsDiffProductSameRO{get;set;}
        @AuraEnabled public Boolean boolIsDiffProductDiffRO{get;set;}
        @AuraEnabled public Boolean boolIsSelected{get;set;}
        @AuraEnabled public Boolean boolBlockNext{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public Boolean boolIsFullMatch{get;set;}
        public LeadCRMDedupeWrapper(){
            applicant = new Applicant__c();
            boolIsSameProduct = false;
            boolIsDiffProductSameRO = false;
            boolIsDiffProductDiffRO = false;
            boolIsSelected = false;
            boolBlockNext = false;
            boolIsFullMatch = false;
            strMatchParam = '';
        }
    }
    
    @AuraEnabled
    public static Applicant__c copyApplicantfromCBS( LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper,
                                                        List<CustomerODResponseWrapper> objCustomerODResponseWrapper,
                                                        LeadDedupeWrapper.leadCBSCreditCardWrapper objCreditCardWrapper, 
                                                            Applicant__c objApplicant, 
                                                                Boolean boolAddressChange) {
        try{
            Applicant__c objCurrentApplicant = [Select Id,KYC_Type__c,KYC_Status__c, Mobile_Number__c,PAN__c,Aadhaar_Number__c,Customer_Type__c,Loan__r.Product__c ,Loan__c,RecordTypeId, Bureau_score__c from Applicant__c 
                                        where Id =:objApplicant.Id AND IsInactive__c = false WITH SECURITY_ENFORCED limit 1];
            
            String strLoanId = objCurrentApplicant.Loan__c;
            
            List<Applicant__c> lstApplicanttoUpdate = new List<Applicant__c>();
            objApplicant = copyApplicantDetails(objCurrentApplicant, objCustomerDetailWrapper, objCustomerODResponseWrapper, objCreditCardWrapper, boolAddressChange);
            
            lstApplicanttoUpdate.add(objApplicant);
            //SFAU-5783 - Change to Applicant
            update lstApplicanttoUpdate;
            //DatabaseUtilit.updateRecords(lstApplicanttoUpdate, '');
            if(!String.isBlank(strLoanId)){
                updateLoanApplication(strLoanId);
            }
            String strComplete = objApplicant.CBS_Status__c;
            /* START - SFAU-4934 */
            if(String.isBlank(objApplicant.bureau_score__c)){
               updateCBSDocumentChecklist (objApplicant.Id, objApplicant.Aadhaar_Number__c, GlobalConstants.COMPLETE, objApplicant.PAN__c, GlobalConstants.COMPLETE);
			}
            /* END - SFAU-4934 */
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyApplicantfromCBS :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    }
    
    private static Applicant__c copyApplicantDetails(Applicant__c objCurrentApplicant, LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper, List<CustomerODResponseWrapper> objCustomerODResponseWrapper,
                                                        LeadDedupeWrapper.leadCBSCreditCardWrapper objCreditCardWrapper, Boolean boolAddressChange){ 
            String strProducttoPurchase = objCurrentApplicant.Loan__r.Product__c;
            String strLoanId = objCurrentApplicant.Loan__c;

            Applicant__c objApplicant = new Applicant__c();          
            objApplicant.Id = objCurrentApplicant.Id;                    
            objApplicant.RecordTypeId = objCurrentApplicant.RecordTypeId;
                                                            
            if(objCurrentApplicant.Bureau_Score__c!= null){
               objApplicant.CIF_No__c = objCustomerDetailWrapper.strCustomerID;   
               objApplicant = copyAccountsfromCBS(objCustomerDetailWrapper, objCustomerODResponseWrapper, objApplicant, strProducttoPurchase);
               objApplicant = copyCCfromCBS(objCreditCardWrapper,objApplicant);
               return objApplicant;
            }                                                
                                                            
            objApplicant.Customer_Name__c = objCustomerDetailWrapper.strCustomerName;
            objApplicant.CIF_No__c = objCustomerDetailWrapper.strCustomerID;
            objApplicant.Cbs_Checked__c = true; // 18 Jul 
            objApplicant.Title__c = objCustomerDetailWrapper.strPrefix;
            objApplicant.First_Name__c = objCustomerDetailWrapper.strFirstName;
            objApplicant.Middle_Name__c = objCustomerDetailWrapper.strMiddleName;
            objApplicant.Last_Name__c = objCustomerDetailWrapper.strLastName;
            objApplicant.Customer_Type__c = objCurrentApplicant.Customer_Type__c;
            objApplicant.Is_ETB_Address_Changed__c = boolAddressChange;
            objApplicant.CBS_Name__c = (objCustomerDetailWrapper.strFirstName!=null?objCustomerDetailWrapper.strFirstName:'') + ' ' +(objCustomerDetailWrapper.strMiddleName!=null?objCustomerDetailWrapper.strMiddleName:'')
                                         + ' ' + (objCustomerDetailWrapper.strLastName!=null?objCustomerDetailWrapper.strLastName:'');
            objApplicant.Existing_Customer__c = 'Yes';
            objApplicant.Gender__c = objCustomerDetailWrapper.strSex;
            objApplicant.Mobile_Number__c = objCurrentApplicant.Mobile_Number__c != objCustomerDetailWrapper.strMobileNumber ? objCurrentApplicant.Mobile_Number__c : objCustomerDetailWrapper.strMobileNumber;
            objApplicant.Email__c = objCustomerDetailWrapper.strEmailID;
            objApplicant.Total_Exposure__c = 0.00;
            objApplicant.Final_Exposure__c = 0.00;
            objApplicant.Wheels_Exposure__c = 0.00;
            objApplicant.CBS_Image_Available__c = objCustomerDetailWrapper.boolIsImageAvailable;
            objApplicant.CBS_Signature_Available__c = objCustomerDetailWrapper.boolIsSignatureAvailable;
            objApplicant.is_Non_Compliant_ETB_Customer__c = objCustomerDetailWrapper.strInputCustomerTypeDesc!=null && (objCustomerDetailWrapper.strInputCustomerTypeDesc.contains('MIN KYC') || objCustomerDetailWrapper.strInputCustomerTypeDesc.contains('NO KYC'))?true:false;//R2-41 check if compliant
            if(!String.isBlank(objCustomerDetailWrapper.strDOB)){
                objApplicant.Dob__c = Date.valueOf(objCustomerDetailWrapper.strDOB);
            }
            if(objCustomerDetailWrapper.boolIsKYCDone && !boolAddressChange){
                objApplicant.KYC_Status__c =  GlobalConstants.COMPLETE;
                objApplicant.CBS_Status__c = GlobalConstants.COMPLETE;
                if(objCustomerDetailWrapper.strPAN!=null || objCurrentApplicant.PAN__c!=null){//R2-2279
                objApplicant.PAN_verification_Status__c = 'Verified';
                }
                objApplicant.KYC_Type__c = GlobalConstants.CBS_Aadhaar;
            }
            else{
                objApplicant.KYC_Status__c = objCurrentApplicant.KYC_Status__c != GlobalConstants.COMPLETE ?  GlobalConstants.PENDING : objCurrentApplicant.KYC_Status__c ;
                objApplicant.CBS_Status__c = GlobalConstants.PENDING;
                objApplicant.KYC_Type__c =  objCurrentApplicant.KYC_Status__c != GlobalConstants.COMPLETE ? '' : objCurrentApplicant.KYC_Type__c;
            }
            objApplicant.PAN__c = !String.isBlank(objCustomerDetailWrapper.strPAN) ? objCustomerDetailWrapper.strPAN : objCurrentApplicant.PAN__c; //!String.isBlank(objCustomerDetailWrapper.strPAN;
            // START - SFAU-5592
            objApplicant.CBS_PAN__c = !String.isBlank(objCustomerDetailWrapper.strPAN) ? objCustomerDetailWrapper.strPAN : '';
            // END - SFAU-5592
            objApplicant.Aadhaar_Number__c = !String.isBlank(objCustomerDetailWrapper.strAadhaar) ? objCustomerDetailWrapper.strAadhaar : objCurrentApplicant.Aadhaar_Number__c;

            copyAddressfromCBS(objCustomerDetailWrapper,objApplicant);
            objApplicant = copyAccountsfromCBS(objCustomerDetailWrapper, objCustomerODResponseWrapper, objApplicant, strProducttoPurchase);
            objApplicant = copyCCfromCBS(objCreditCardWrapper,objApplicant);
            objApplicant = checkExistingLoans(objApplicant,strProducttoPurchase,strLoanId);
        
        return objApplicant;
    }

    // START || 22 AUG
    @AuraEnabled
    public static Applicant__c copyApplicantfromCBSExposure( LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper,
                                                        List<CustomerODResponseWrapper> objCustomerODResponseWrapper,
                                                        LeadDedupeWrapper.leadCBSCreditCardWrapper objCreditCardWrapper, 
                                                            Applicant__c objApplicant, 
                                                                Boolean boolAddressChange) {
        try{
            Applicant__c objCurrentApplicant = [Select Id,KYC_Type__c,KYC_Status__c, Mobile_Number__c,PAN__c,Aadhaar_Number__c,Customer_Type__c,Loan__r.Product__c ,Loan__c,RecordTypeId from Applicant__c 
                                        where Id =:objApplicant.Id AND IsInactive__c = false WITH SECURITY_ENFORCED limit 1];
            String strProducttoPurchase = objCurrentApplicant.Loan__r.Product__c;
            String strLoanId = objCurrentApplicant.Loan__c;
            //String strProducttoPurchase = [Select Id,Loan__r.Product__c from Applicant__c where Id =:objApplicant.Id limit 1].Loan__r.Product__c;
            List<Applicant__c> lstApplicanttoUpdate = new List<Applicant__c>();
            objApplicant.RecordTypeId = objCurrentApplicant.RecordTypeId;
            objApplicant.Total_Exposure__c = 0.00;
            objApplicant.Final_Exposure__c = 0.00;
            objApplicant.Wheels_Exposure__c = 0.00;
            objApplicant = copyAccountsfromCBS(objCustomerDetailWrapper, objCustomerODResponseWrapper, objApplicant, strProducttoPurchase);
            objApplicant = copyCCfromCBS(objCreditCardWrapper,objApplicant);
            objApplicant = checkExistingLoans(objApplicant,strProducttoPurchase,strLoanId);
            
            lstApplicanttoUpdate.add(objApplicant);
            // SFAU-5783
            update lstApplicanttoUpdate;
            //DatabaseUtilit.updateRecords(lstApplicanttoUpdate, '');
            if(!String.isBlank(strLoanId)){
                updateLoanApplication(strLoanId);
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyApplicantfromCBSExposure :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    }
    // END
    
    public static Applicant__c checkExistingLoans( Applicant__c objApplicant, String strProducttoPurchase, String strLoanId){
        try{
            List<Applicant__c> lstApplicant = [ SELECT id,NREGA__c,Customer_Type__c,Mobile_Number__c,RecordType.Name,CIF_No__c,Aadhaar_Number__c,PAN__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,toLabel(Loan__r.Product__c),Loan__r.Customer_Name__c, Loan__c
                                               FROM Applicant__c
                                               WHERE id=:objApplicant.Id 
                                               WITH SECURITY_ENFORCED 
                                               LIMIT 1];
            //lstApplicant.add(objApplicant);
            String strCurrentApplicantType = lstApplicant[0].RecordType.Name;
            List<ExistingLoanWrapper> lstExistingLoanWrapper = new List<ExistingLoanWrapper>();
            Set<String> setLoanId = new Set<String>();
            ExistingLoanWrapper objExistingLoanWrapper;
            String strQuery = createApplicantQuery(lstApplicant,false);
            Set<String> setFourWheeler = new Set<String>();
            setFourWheeler.add(GlobalConstants.FOURWHEELER);
            setFourWheeler.add(GlobalConstants.TRACTOR);
            setFourWheeler.add(GlobalConstants.COMMERCIALVEHICLE);
            setFourWheeler.add(GlobalConstants.CONSTRUCTIONEQUIP);
            for(Applicant__c record : Database.query(strQuery)){
                objExistingLoanWrapper = new ExistingLoanWrapper();
                //if(strLoanId != record.Loan__c && record.Loan__r.Stage__c != GlobalConstants.PDD && !setLoanId.contains(record.Loan__c)){ //pricing psd opsmaker opsauthor and in case of two wheeler - DDE also we should include
                if(strLoanId != record.Loan__c && (((record.Loan__r.Stage__c == GlobalConstants.STAGE_PRICING  || record.Loan__r.Stage__c == GlobalConstants.STAGE_PSD || record.Loan__r.Stage__c == 'Ops Maker' || record.Loan__r.Stage__c ==  'Ops Author') && record.Loan__r.RecordType.Name =='Four Wheeler') || ((record.Loan__r.Stage__c == GlobalConstants.STAGE_PRICING  || record.Loan__r.Stage__c == GlobalConstants.STAGE_PSD || record.Loan__r.Stage__c == GlobalConstants.STAGE_OPS_MAKER || record.Loan__r.Stage__c ==  'Ops Author' || record.Loan__r.Stage__c ==  'DDE') && record.Loan__r.RecordType.Name =='Two Wheeler')) && !setLoanId.contains(record.Loan__c)){ //pricing psd opsmaker opsauthor and in case of two wheeler - DDE also we should include                        ((record.Loan__r.Stage__c == GlobalConstants.STAGE_PRICING  || record.Loan__r.Stage__c == GlobalConstants.STAGE_PSD || record.Loan__r.Stage__c == GlobalConstants.STAGE_OPS_MAKER || record.Loan__r.Stage__c ==  'Ops Author' || ) && record.Loan__r.RecordType.Name =='Four Wheeler')(record.Loan__r.RecordType.Name =='Two Wheeler' && record.Loan__r.Stage__c == 'DDE' ) && !setLoanId.contains(record.Loan__c)){ //pricing psd opsmaker opsauthor and in case of two wheeler - DDE also we should include
                    setLoanId.add(record.Loan__c);
                    objExistingLoanWrapper.applicationNumber = record.Loan__r.Loan_Number__c;
                    objExistingLoanWrapper.customerName = record.Loan__r.Customer_Name__c;
                    objExistingLoanWrapper.Product = record.Loan__r.Product__c;
                    objExistingLoanWrapper.LoanAmount = String.valueOf(record.Loan__r.Total_Loan_Amount__c);
                    objExistingLoanWrapper.SanctionDate = String.valueOf(record.Loan__r.Loan_Sanction_date__c);
                    objExistingLoanWrapper.boolIncludedInTotal = false;
                    objExistingLoanWrapper.boolIncludedInWheels = false;
                    if(strCurrentApplicantType == 'Applicant' && record.RecordType.Name == 'Applicant'){
                        objExistingLoanWrapper.includeInExposure = 'Yes';
                        objExistingLoanWrapper.creditOverrideAuthority = false;
                    }
                    else if((strCurrentApplicantType == 'Applicant' || strCurrentApplicantType == 'Co-Applicant') 
                        && (record.RecordType.Name == 'Applicant' || record.RecordType.Name == 'Co-Applicant')){
                        objExistingLoanWrapper.includeInExposure = 'Yes';
                        objExistingLoanWrapper.creditOverrideAuthority = true;
                    }
                    else if((strCurrentApplicantType == 'Applicant' || strCurrentApplicantType == 'Co-Applicant') 
                        && record.RecordType.Name == 'Guarantor'){
                        objExistingLoanWrapper.includeInExposure = 'No';
                        objExistingLoanWrapper.creditOverrideAuthority = true;
                    }
                    else if(strCurrentApplicantType == 'Guarantor'){
                        objExistingLoanWrapper.includeInExposure = 'No';
                        objExistingLoanWrapper.creditOverrideAuthority = true;
                    }
                    
                    if(objExistingLoanWrapper.includeInExposure == 'Yes'){
                        objApplicant.Total_Exposure__c = objApplicant.Total_Exposure__c + record.Loan__r.Total_Loan_Amount__c;
                        objApplicant.Final_Exposure__c = objApplicant.Total_Exposure__c;
                        objExistingLoanWrapper.boolIncludedInTotal = true;
                        if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && record.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER){
                            objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + record.Loan__r.Total_Loan_Amount__c;
                            objExistingLoanWrapper.boolIncludedInWheels = true;
                        }
                        //if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (record.Loan__r.RecordType.Name == GlobalConstants.FOURWHEELER
                        //    || record.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER)){
                        if(setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c) && (setFourWheeler.contains(record.Loan__r.RecordType.Name)
                            || record.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER)){
                            objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + record.Loan__r.Total_Loan_Amount__c;
                            objExistingLoanWrapper.boolIncludedInWheels = true;
                        }
                    }
                    lstExistingLoanWrapper.add(objExistingLoanWrapper);
                }
            }
            objApplicant.SF_Exposure_JSON__c = JSON.serialize(lstExistingLoanWrapper);
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: checkExistingLoans :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    }
    
    public class ExistingLoanWrapper{
        public String applicationNumber;
        public String customerName;
        public String Product;
        public String LoanAmount;
        public String SanctionDate;
        //public Applicant__c objApplicant;
        public String includeInExposure;
        public Boolean creditOverrideAuthority;
        public Boolean boolIncludedInTotal;
        public Boolean boolIncludedInWheels;
    }
    /*
    public static Applicant__c checkExistingLoansExposure( Applicant__c objApplicant, String strProducttoPurchase, String strLoanId){
        try{
            String strQuery = createApplicantQuery(lstApplicant);
            for(Applicant__c record : Database.query(strQuery)){
                if(strLoanId != record.Loan__c && record.Loan__r.Stage__c == GlobalConstants.PDD){
                    objApplicant.Total_Exposure__c = objApplicant.Total_Exposure__c + record.Loan__r.Loan_Amount__c;
                    if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && record.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER){
                        objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + record.Loan__r.Loan_Amount__c;
                    }
                    if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (record.Loan__r.RecordType.Name == GlobalConstants.FOURWHEELER
                        || record.Loan__r.RecordType.Name == GlobalConstants.TWOWHEELER)){
                        objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + record.Loan__r.Loan_Amount__c;
                    }
                }
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
    }
    */
    
    /*
    private static Boolean checkWheelsProduct( String strLoanProduct, String strProducttoPurchase) {
        Map<String,String> pickListValuesMap= new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Loan_Application__c.Product__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
        }
        return pickListValuesMap.values().contains(strProductId);
    }*/
    
    public static Map<String,String> getRecordTypeMap(){
        Map<String,String> mapProductIdvsRecordType = new Map<String,String>();
        for(ProductRTMap__mdt objProduct : [Select Product__c, RecordType__c from ProductRTMap__mdt]){
            mapProductIdvsRecordType.put(objProduct.Product__c , objProduct.RecordType__c);
        }
        return mapProductIdvsRecordType;
    }
        
    
    public static void copyAddressfromCBS( LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper, Applicant__c objApplicant) {
        try{
            List<Address__c> lstExistingAddress = [Select Id from Address__c where Applicant__c =:objApplicant.Id and Source_Type__c='CBS' WITH SECURITY_ENFORCED];
            DatabaseUtility.deleteRecords(lstExistingAddress,'');
            List<Address__c> lstAddress = new List<Address__c>();
            Address__c objAddress = new Address__c();
            objAddress.Address_Line_1__c = objCustomerDetailWrapper.strAddressLine1;
            objAddress.Address_Line_2__c = objCustomerDetailWrapper.strAddressLine2;
            objAddress.Address_Line_3__c = objCustomerDetailWrapper.strAddressLine3;
            objAddress.City__c = objCustomerDetailWrapper.strCity;
            objAddress.District__c = objCustomerDetailWrapper.strCity;
            objAddress.State__c = objCustomerDetailWrapper.strState;
            //objAddress.Country__c = objCustomerDetailWrapper.strCountry;
            objAddress.Address_Type__c = 'Permanent';
            objAddress.Source_Type__c = 'CBS';
            objAddress.Pincode__c = objCustomerDetailWrapper.strPincode;
            objAddress.Address_Line_2__c = objCustomerDetailWrapper.strAddressLine2;
            objAddress.Applicant__c = objApplicant.Id;
            lstAddress.add(objAddress);
            //insert objAddress;
            //Database.SaveResult lstResultAddress = Database.insert(objAddress,false);
            DatabaseUtility.createRecords(lstAddress, '');
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyAddressfromCBS :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
    }
    
    private static Map<String,CustomerODResponseWrapper> getAccountODMap(List<CustomerODResponseWrapper> lstCustomerODResponseWrapper){
        Map<String,CustomerODResponseWrapper> mapAccvsODDetail = new Map<String,CustomerODResponseWrapper>();
        if(lstCustomerODResponseWrapper != null){
            for(CustomerODResponseWrapper objCustomerODResponseWrapper : lstCustomerODResponseWrapper){
                mapAccvsODDetail.put(objCustomerODResponseWrapper.AccountNo,objCustomerODResponseWrapper);
            }
        }
        return mapAccvsODDetail;
    }
    
    private static Applicant__c copyAccountsfromCBS( LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper, List<CustomerODResponseWrapper> objCustomerODResponseWrapper, Applicant__c objApplicant,String strProducttoPurchase){
        List<Bank_Account_Records__c> lstExistingBankAccount = [Select Id from Bank_Account_Records__c where Applicant__c =:objApplicant.Id AND RecordType.Name =:  GlobalConstants.CBS  WITH SECURITY_ENFORCED];
        DatabaseUtility.deleteRecords(lstExistingBankAccount,'');
        Map<String,CustomerODResponseWrapper> mapAccvsODDetail = getAccountODMap(objCustomerODResponseWrapper);
        Map<String,String> mapProductIdvsRecordType = getRecordTypeMap();
        List<Bank_Account_Records__c> lstBankAccount = new List<Bank_Account_Records__c>();
        Bank_Account_Records__c objBankAccount;
        //SFAU-4307
        objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c=0.00;
        objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c=0.00;
        objApplicant.POS_of_all_Live_loans__c=0.00;
        Set<String> setFourWheeler = new Set<String>();
        setFourWheeler.add(GlobalConstants.FOURWHEELER);
        setFourWheeler.add(GlobalConstants.TRACTOR);
        setFourWheeler.add(GlobalConstants.COMMERCIALVEHICLE);
        setFourWheeler.add(GlobalConstants.CONSTRUCTIONEQUIP);
        //SFAU-4307
        for(LeadDedupeWrapper.AccountWrapper objAccount : objCustomerDetailWrapper.lstAccountWrapper){
            objBankAccount = new Bank_Account_Records__c();
            objBankAccount = mapCBSAccounttoSF(objAccount,objBankAccount);
            objBankAccount = checkForExposure(objBankAccount,objApplicant);
            objBankAccount.Applicant__c = objApplicant.Id;
            objBankAccount.Bank_Name__c = objCustomerDetailWrapper.strBankShortName;
            
            CustomerODResponseWrapper objCustomerOD = mapAccvsODDetail.get(objAccount.strLoanTitle);
            if(objCustomerOD!=null){
                objBankAccount.POS__c = objCustomerOD.PrincipalBalance;
                objBankAccount.Loan_Overdue_EMI__c = objCustomerOD.InstallmentsOverDue != NULL ? objCustomerOD.InstallmentsOverDue : 0; // SFAU-5110
                // SFAU-5701 - NoOfEMIPaid Mapping Mohit M.
                objBankAccount.No_of_Emi_Paid__c = objCustomerOD.TotalNoOfInstallmentsReceived != NULL ? objCustomerOD.TotalNoOfInstallmentsReceived : 0;
            }else{
                objBankAccount.POS__c = 0;
                objBankAccount.Loan_Overdue_EMI__c = 0;
            }
            if(objBankAccount.Account_Type__c == GlobalConstants.LOAN && objBankAccount.Include_In_Exposure__c == 'Yes'){
                objApplicant.Total_Exposure__c = (objApplicant.Total_Exposure__c != null ? objApplicant.Total_Exposure__c : 0) + (objBankAccount.POS__c != null ? objBankAccount.POS__c : 0);
                objApplicant.Final_Exposure__c = objApplicant.Total_Exposure__c;
                //SFAU-4307
                objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c = objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c+objBankAccount.Loan_Amount__c;
                if(objBankAccount.Maturity_Date__c>Date.today()){
                    objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c = objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c+objBankAccount.Loan_Amount__c;
                    objApplicant.POS_of_all_Live_loans__c = objApplicant.POS_of_all_Live_loans__c+objBankAccount.POS__c;
                }
                //SFAU-4307
                if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && 
                    mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER){
                        objApplicant.Wheels_Exposure__c = (objApplicant.Wheels_Exposure__c != null ? objApplicant.Wheels_Exposure__c : 0) + (objBankAccount.POS__c != null ? objBankAccount.POS__c : 0);
                    }
                //if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && 
                //    (mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.FOURWHEELER || mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER)){
                if(setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c) && 
                    (setFourWheeler.contains(mapProductIdvsRecordType.get(objBankAccount.Product_Code__c)) || mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER)){
                    objApplicant.Wheels_Exposure__c = (objApplicant.Wheels_Exposure__c != null ? objApplicant.Wheels_Exposure__c : 0) + (objBankAccount.POS__c != null ? objBankAccount.POS__c : 0);
                }
            }
            if(objBankAccount.Account_Type__c == GlobalConstants.ODCC && objBankAccount.Include_In_Exposure__c == 'Yes'){
                objApplicant.Total_Exposure__c = (objApplicant.Total_Exposure__c != NULL ? objApplicant.Total_Exposure__c : 0) + (objBankAccount.OD_Limit_Sanctioned__c != NULL ? objBankAccount.OD_Limit_Sanctioned__c : 0);
                objApplicant.Final_Exposure__c = objApplicant.Total_Exposure__c;
                //SFAU-4307
                objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c = objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c+objBankAccount.OD_Limit_Sanctioned__c;
                if(!objBankAccount.Current_Status__c.contains('CLOSED')){
                    objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c = objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c+objBankAccount.OD_Limit_Sanctioned__c;
                    objApplicant.POS_of_all_Live_loans__c = objApplicant.POS_of_all_Live_loans__c+objBankAccount.OD_Limit_Sanctioned__c;
                }
                //SFAU-4307
                //objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + objBankAccount.OD_Limit_Sanctioned__c;
            }
            if(objBankAccount.Account_Type__c == GlobalConstants.CASA){
                objBankAccount.Bank_Name__c = 'AU SMALL FINANCE BANK LIMITED';
            }
            lstBankAccount.add(objBankAccount);
        }
        try{
            //insert lstBankAccount;
            //List<Database.SaveResult> lstResultAccounts = Database.insert(lstBankAccount,false);
            DatabaseUtility.createRecords(lstBankAccount,'');
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyAccountsfromCBS :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    }
    
    public static Bank_Account_Records__c checkForExposure(Bank_Account_Records__c objBankAccount, Applicant__c objApplicant){
        String strCurrentApplicantType = Utility.getRecordTypeNameById('Applicant__c',objApplicant.RecordTypeId);
        if(strCurrentApplicantType == 'Applicant' && objBankAccount.Customer_Relationship__c == 'SOW'){
            objBankAccount.Include_In_Exposure__c = 'Yes';
            objBankAccount.Credit_Override_authority__c = false;
        }
        else if((strCurrentApplicantType == 'Applicant' || strCurrentApplicantType == 'Co-Applicant') 
            && (objBankAccount.Customer_Relationship__c == 'SOW' || objBankAccount.Customer_Relationship__c == 'COB')){
            objBankAccount.Include_In_Exposure__c = 'Yes';
            objBankAccount.Credit_Override_authority__c = true;
        }
        else if((strCurrentApplicantType == 'Applicant' || strCurrentApplicantType == 'Co-Applicant') 
            && objBankAccount.Customer_Relationship__c == 'GUA'){
            objBankAccount.Include_In_Exposure__c = 'No';
            objBankAccount.Credit_Override_authority__c = true;
        }
        else if(strCurrentApplicantType == 'Guarantor'){
            objBankAccount.Include_In_Exposure__c = 'No';
            objBankAccount.Credit_Override_authority__c = true;
        }
        return objBankAccount;
    }
    
    private static Applicant__c copyCCfromCBS( LeadDedupeWrapper.leadCBSCreditCardWrapper objCreditCardWrapper, Applicant__c objApplicant){
        if(objCreditCardWrapper != null){
            try{
                List<Bank_Account_Records__c> lstBankAccount = new List<Bank_Account_Records__c>();
                Bank_Account_Records__c objBankAccount;
                for(LeadDedupeWrapper.cls_CreditCardResponse objAccount : objCreditCardWrapper.CreditCardResponse){
                    objBankAccount = new Bank_Account_Records__c();
                    objBankAccount.RecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get(GlobalConstants.BANK_ACCOUNT_RECORDS),GlobalConstants.CBS);
                    objBankAccount.Source__c = GlobalConstants.CBS;
                    objBankAccount.Account_Type__c = GlobalConstants.CC;
                    objBankAccount.Customer_Id__c = objAccount.CustomerID;
                    objBankAccount.Customer_Relationship__c = objAccount.CustomerAccountRelation!=null ? objAccount.CustomerAccountRelation.trim() == 'Sole Owner' ? 'SOW' : objAccount.CustomerAccountRelation:'';
                    objBankAccount.Account_Number__c = objAccount.AccountNumber;
                    objBankAccount.Status__c = objAccount.LoanStatus;
                    objBankAccount.Account_Name__c = objAccount.CustomerFullName;
                    //objBankAccount.Account_Type__c = objAccount.ProductCode;
                    objBankAccount.Product__c = objAccount.Decode;
                    objBankAccount.Account_Opening_Date__c = Date.valueOf(objAccount.AccountOpenDate);
                    objBankAccount.Current_Status__c = objAccount.AccountStatus;
                    objBankAccount.Sanctioned_Amount__c = Decimal.valueOf(objAccount.SanctionedAmount);
                    objBankAccount.DPP_Value__c = objAccount.DPDValue;
                    objBankAccount.Last_Statement_Balance__c = objAccount.LastStatementBalance;
                    objBankAccount.Applicant__c = objApplicant.Id;
                    objBankAccount = checkForExposure(objBankAccount,objApplicant);
                    if(objBankAccount.Include_In_Exposure__c == 'Yes'){                    
                        objApplicant.Total_Exposure__c = objApplicant.Total_Exposure__c + objBankAccount.Sanctioned_Amount__c;
                        objApplicant.Final_Exposure__c = objApplicant.Total_Exposure__c;
                        //SFAU-4307
                        objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c = objApplicant.Loan_Amt_Till_Date_inc_Closed_Loans__c+objBankAccount.Sanctioned_Amount__c;
                        if(!objBankAccount.Current_Status__c.contains('CLOSED')){
                            objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c = objApplicant.Loan_Amt_Till_Date_all_Running_Loans__c+objBankAccount.Sanctioned_Amount__c;
                            objApplicant.POS_of_all_Live_loans__c = objApplicant.POS_of_all_Live_loans__c+objBankAccount.Sanctioned_Amount__c;
                        }
                        //SFAU-4307
                    }
                    //objApplicant.Wheels_Exposure__c = objApplicant.Wheels_Exposure__c + objBankAccount.Sanctioned_Amount__c;
                    lstBankAccount.add(objBankAccount);
                }
                DatabaseUtility.createRecords(lstBankAccount,'');
            }
            catch(Exception objException) {
                //SFAU-5783
                Log.error('LeadDedupeController :: copyCCfromCBS :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
                throw objException;
                //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            }
        }
        return objApplicant;
    }

    
    private static Bank_Account_Records__c mapCBSAccounttoSF( LeadDedupeWrapper.AccountWrapper objAccount, Bank_Account_Records__c objBankAccount){
        try{
            objBankAccount.Account_Number__c = objAccount.strLoanTitle;
            objBankAccount.OD_Limit_Sanctioned__c = !String.isBlank(objAccount.strODLimitSactioned) ? Decimal.valueOf(objAccount.strODLimitSactioned) : null;
            objBankAccount.OD_Limit_Utilized__c = !String.isBlank(objAccount.strODLimitUtilized) ? Decimal.valueOf(objAccount.strODLimitUtilized) : null;
            objBankAccount.Loan_Number__c = objAccount.strLoanNumber;
            objBankAccount.Product__c = objAccount.strProduuct;
            objBankAccount.Product_Code__c = objAccount.strProductCode;
            objBankAccount.Branch_Name__c = objAccount.strBranchName;
            objBankAccount.Customer_Relationship__c = objAccount.strCustomerRelationship;
            objBankAccount.Current_Status__c = objAccount.strCurrentStatus;
            objBankAccount.Loan_Amount__c = !String.isBlank(objAccount.strLoanAmount) ? Decimal.valueOf(objAccount.strLoanAmount) : null;   
            objBankAccount.Tenure__c = objAccount.strTenureMonth;
            objBankAccount.Account_Opening_Date__c = !String.isBlank(objAccount.strAccountOpeningDate) ? Date.valueOf(objAccount.strAccountOpeningDate) : null;
            objBankAccount.Maturity_Date__c = !String.isBlank(objAccount.strMaturityDate) ? Date.valueOf(objAccount.strMaturityDate) : null;
            objBankAccount.No_of_Emi_Paid__c = !String.isBlank(objAccount.strNoofEmiPaid) ? Decimal.valueOf(objAccount.strNoofEmiPaid) : null;  
            objBankAccount.Total_Outstanding__c = !String.isBlank(objAccount.strTotalOutstanding) ? Decimal.valueOf(objAccount.strTotalOutstanding) : null;
            objBankAccount.EMI_Amount__c = !String.isBlank(objAccount.strEMIAmount) ? Decimal.valueOf(objAccount.strEMIAmount) : null;  
            objBankAccount.ROI__c = !String.isBlank(objAccount.strROI) ? Decimal.valueOf(objAccount.strROI) : null;
            //objBankAccount.POS__c = !String.isBlank(objAccount.strPOS) ? Decimal.valueOf(objAccount.strPOS) : null;
            objBankAccount.Source__c = GlobalConstants.CBS;
            objBankAccount.RecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get(GlobalConstants.BANK_ACCOUNT_RECORDS),GlobalConstants.CBS);
            if(objAccount.boolIsODCCAccount != null && objAccount.boolIsODCCAccount){
                objBankAccount.Account_Type__c = GlobalConstants.ODCC;
                objBankAccount.CASARelationshipDetails__c = objAccount.strCASARelationShipDetails;            
            }
            else if(objAccount.boolIsLoanAccount != null && objAccount.boolIsLoanAccount){
                objBankAccount.Account_Type__c = GlobalConstants.LOAN;
            }
            else if(objAccount.boolIsCASAAccount != null && objAccount.boolIsCASAAccount){
                objBankAccount.Account_Type__c = GlobalConstants.CASA;
                objBankAccount.CASARelationshipDetails__c = objAccount.strCASARelationShipDetails;
            }
            else if(objAccount.boolIsFDRDAccount != null && objAccount.boolIsFDRDAccount){
                objBankAccount.Account_Type__c = GlobalConstants.FDRD;
                objBankAccount.Current_Balance__c = !String.isBlank(objAccount.strAvailableBalance) ? Decimal.valueOf(objAccount.strAvailableBalance) : null;
            }
            else if(objAccount.boolIsCCAccount != null && objAccount.boolIsCCAccount){
                objBankAccount.Account_Type__c = GlobalConstants.CC;
            }
            if(objBankAccount.Account_Type__c == GlobalConstants.LOAN){
                objBankAccount.Account_Name__c = objAccount.strLoanAccountName;
                objBankAccount.Loan_Tenure__c = !String.isBlank(objAccount.strEmiTenure) ? Decimal.valueOf(objAccount.strEmiTenure) : null;
                //objBankAccount.Loan_Current_DPD__c = objAccount.strEmiTenure;
                objBankAccount.Loan_Overdue_EMI__c = !String.isBlank(objAccount.strInstallmentsOverDue) ? Decimal.valueOf(objAccount.strInstallmentsOverDue) : null;
            }
            if(objBankAccount.Account_Type__c == GlobalConstants.CASA){
                objBankAccount.Account_Name__c = objAccount.strCASAAccountName;
                objBankAccount.Current_Balance__c = !String.isBlank(objAccount.strAvailableBalance) ? Decimal.valueOf(objAccount.strAvailableBalance) : null;
            }
            
            
            //objBankAccount.Applicant__c = objApplicant.Id;
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: mapCBSAccounttoSF :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),NULL);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),null);
        }
        return objBankAccount;
    }
    
    @AuraEnabled
    public static Applicant__c updateKYCPending(String applicantStr){
        Applicant__c objApplicant;
        try{
            if(String.isBlank(applicantStr)){
                return new Applicant__c();
            }
            objApplicant = (Applicant__c) JSON.deserialize(applicantStr,Applicant__c.class);
            //String strProducttoPurchase = [Select Id,Loan__r.Product__c from Applicant__c where Id =:objApplicant.Id limit 1].Loan__r.Product__c;
            Applicant__c objCurrentApplicant = [Select Id, Customer_Type__c, Loan__r.Product__c ,Loan__c,RecordTypeId from Applicant__c where Id =:objApplicant.Id AND IsInactive__c = false WITH SECURITY_ENFORCED limit 1];
            String strProducttoPurchase = objCurrentApplicant.Loan__r.Product__c;
            String strLoanId = objCurrentApplicant.Loan__c;
            
            List<Applicant__c> lstApplicanttoUpdate = new List<Applicant__c>();
            if(objApplicant.KYC_Status__c == GlobalConstants.COMPLETE){
                objApplicant.KYC_Status__c = GlobalConstants.PENDING;
            }
            objApplicant.CBS_Name__c = '';
            objApplicant.Customer_Type__c = objCurrentApplicant.Customer_Type__c;
            objApplicant.Total_Exposure__c = 0.00;
            objApplicant.Wheels_Exposure__c = 0.00;
            objApplicant.Final_Exposure__c = 0.00;
            objApplicant = checkExistingLoans(objApplicant,strProducttoPurchase,strLoanId);
            lstApplicanttoUpdate.add(objApplicant);
            //SFAU-5783 - Remove Database.Utiltiy
            // DatabaseUtilit.updateRecords(lstApplicanttoUpdate,'');
            update lstApplicanttoUpdate;
            if(!String.isBlank(strLoanId)){
                updateLoanApplication(strLoanId);
            }
            objApplicant.RecordType = [Select Id,Name from Recordtype where Id=:objCurrentApplicant.RecordTypeId limit 1];
            //update objApplicant;
            //Database.SaveResult objResult = Database.update(objApplicant,false);
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: updateKYCPending :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    } 
    
    @AuraEnabled
    public static LeadCRMDedupeWrapper copyApplicantfromCRM( LeadCRMDedupeWrapper objApplicanttoCopy, Applicant__c objApplicant) {
        LeadCRMDedupeWrapper objLeadCRMDedupeWrapper = new LeadCRMDedupeWrapper();
        try{
            //String strProducttoPurchase = [Select Id,Loan__r.Product__c from Applicant__c where Id =:objApplicant.Id limit 1].Loan__r.Product__c;
            Applicant__c objCurrentApplicant = [Select Id, Loan__r.Product__c ,Loan__c,Customer_Type__c from Applicant__c where Id =:objApplicant.Id AND IsInactive__c = false WITH SECURITY_ENFORCED limit 1];
            String strProducttoPurchase = objCurrentApplicant.Loan__r.Product__c;
            String strLoanId = objCurrentApplicant.Loan__c;
            List<Applicant__c> lstApplicanttoUpdate = new List<Applicant__c>();
            Applicant__c objApplicanttoUpdate = new Applicant__c();
            objApplicanttoUpdate = objApplicanttoCopy.applicant.clone(false,false,false,false);
            objApplicanttoUpdate.Id = objApplicant.Id;
            objApplicanttoUpdate.CBS_Name__c = '';
            objApplicanttoUpdate.KYC_Status__c = GlobalConstants.PENDING;
            objApplicanttoUpdate.Customer_Type__c = objCurrentApplicant.Customer_Type__c;
            objApplicanttoUpdate.Cbs_Checked__c = true; // 18 Jul 
            objApplicanttoUpdate.Total_Exposure__c = 0.00;
            objApplicanttoUpdate.Wheels_Exposure__c = 0.00;
            objApplicanttoUpdate.Final_Exposure__c = 0.00;
            objApplicanttoUpdate = checkExistingLoans(objApplicanttoUpdate,strProducttoPurchase,strLoanId);
            //update objApplicanttoUpdate;
            lstApplicanttoUpdate.add(objApplicanttoUpdate);
            //SFAU-5783 - Remove Database.utility
            //DatabaseUtilit.updateRecords(lstApplicanttoUpdate,'');
            update lstApplicanttoUpdate;
            //Database.SaveResult objResult = Database.update(objApplicanttoUpdate,false);
            objLeadCRMDedupeWrapper.applicant = objApplicanttoUpdate;
            objLeadCRMDedupeWrapper.boolIsSameProduct=objApplicanttoCopy.boolIsSameProduct;
            objLeadCRMDedupeWrapper.boolIsDiffProductSameRO=objApplicanttoCopy.boolIsDiffProductSameRO;
            objLeadCRMDedupeWrapper.boolIsDiffProductDiffRO=objApplicanttoCopy.boolIsDiffProductDiffRO;
            objLeadCRMDedupeWrapper.boolIsSelected=true;
            if(!String.isBlank(strLoanId)){
                updateLoanApplication(strLoanId);
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyApplicantfromCRM :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objLeadCRMDedupeWrapper;
    }
    
    @AuraEnabled
    public static Applicant__c copyApplicantfromLeadtoLead(LeadDedupeWrapper.LeadtoLeadWrapper objLeadtoLeadWrapper ,Applicant__c objApplicant){
        try{
            Applicant__c objCurrentApplicant = [Select Id, Loan__r.Product__c ,Loan__c from Applicant__c where Id =:objApplicant.Id AND IsInactive__c = false WITH SECURITY_ENFORCED limit 1];
            String strProducttoPurchase = objCurrentApplicant.Loan__r.Product__c;
            String strLoanId = objCurrentApplicant.Loan__c;
            //String strProducttoPurchase = [Select Id,Loan__r.Product__c from Applicant__c where Id =:objApplicant.Id limit 1].Loan__r.Product__c;
            List<Applicant__c> lstApplicanttoUpdate = new List<Applicant__c>();
            objApplicant.Customer_Name__c = objLeadtoLeadWrapper.strCustomerName;
            //objApplicant.First_Name__c = objCustomerDetailWrapper.strFirstName;
            //objApplicant.Middle_Name__c = objCustomerDetailWrapper.strMiddleName;
            //objApplicant.Last_Name__c = objCustomerDetailWrapper.strLastName;
            objApplicant.Existing_Customer__c = 'Yes';
            objApplicant.Mobile_Number__c = objLeadtoLeadWrapper.strCustomerMobileNumber;
            objApplicant.Existing_Lead_Application_Number__c = objLeadtoLeadWrapper.strApplicationNumber;
            objApplicant.Existing_Lead_Application_Status__c = objLeadtoLeadWrapper.strApplicationstatus;
            //objApplicant.Existing_Lead_Creation_Date__c = Date.valueOf(objLeadtoLeadWrapper.strLeadCreationDate);
            objApplicant.Existing_Lead_Id__c = objLeadtoLeadWrapper.strLeadId;
            objApplicant.Existing_Lead_Loan_Amount__c = objLeadtoLeadWrapper.strLoanAmount;
            objApplicant.Existing_Lead_Product__c = objLeadtoLeadWrapper.strProductName;
            objApplicant.Cbs_Checked__c = true; // 18 Jul 
            objApplicant.Total_Exposure__c = 0.00;
            objApplicant.Wheels_Exposure__c = 0.00;
            objApplicant.Final_Exposure__c = 0.00;
            objApplicant.KYC_Status__c = GlobalConstants.PENDING;
            objApplicant.KYC_Type__c = '';
            objApplicant = checkExistingLoans(objApplicant,strProducttoPurchase,strLoanId);

            lstApplicanttoUpdate.add(objApplicant);
            // SFAU-5783 -- Remove Database.Uitlity
            //DatabaseUtilit.updateRecords(lstApplicanttoUpdate, '');
            update lstApplicanttoUpdate;
            if(!String.isBlank(strLoanId)){
                updateLoanApplication(strLoanId);
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: copyApplicantfromLeadtoLead :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
            throw objException;
            //Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant.Id);
        }
        return objApplicant;
    }

    //@future
    public static void updateLoanApplication(String strLoanId){
        if(strLoanId != null){
            // SFAU-5326 -- Inactive applicants to be filtered when calculating POS
            Loan_Application__c objLoanApp = [
                Select Id,Product__c,Total_Exposure__c,Wheels_Exposure__c,Final_Exposure__c,Loan_Amount__c,Total_Loan_Amount__c,RecordType.Name, Dpd_Found__c, // SFAU-5730
                (Select Id, SF_Exposure_JSON__c, Loan__c from Applicants__r WHERE RecordTypeId IN: GlobalConstants.APPLICANTS_RECORD_TYPES_IDS AND IsInactive__c != true )
                from Loan_Application__c where Id = :strLoanId
                WITH SECURITY_ENFORCED limit 1
            ];

            List<Loan_Application__c> lstLoanApptoUpdate = new List<Loan_Application__c>();
            String strProducttoPurchase = objLoanApp.Product__c;
            String loanRecordType = objLoanApp.RecordType.Name;
            Set<String> setExistingLoanApp = new Set<String>();
            Set<String> setApplicantId = new Set<String>();
            Decimal FinalExposure = 0;
            Decimal TotalExposure = 0;
            Decimal WheelsExposure = 0;
            //SFAU-4307
            Decimal LoanAmtTillDateAllLoans = 0;
            Decimal LoanAmtTillDateRunningLoans = 0;
            Decimal PosOfAllLiveLoans = 0;
            Decimal ApprovedButNotDisbursed = 0;
            Set<String> setFourWheeler = new Set<String>();
            setFourWheeler.add(GlobalConstants.FOURWHEELER);
            setFourWheeler.add(GlobalConstants.TRACTOR);
            setFourWheeler.add(GlobalConstants.COMMERCIALVEHICLE);
            setFourWheeler.add(GlobalConstants.CONSTRUCTIONEQUIP);
            //SFAU-4307
            Map<String,String> mapProductvsRT = new Map<String,String>();
            for(ProductRTMap__mdt objProductRTMap : [SELECT MasterLabel,RecordType__c from ProductRTMap__mdt]){
                mapProductvsRT.put(objProductRTMap.MasterLabel , objProductRTMap.RecordType__c);
            }
            if (objLoanApp.Applicants__r != null && !objLoanApp.Applicants__r.isEmpty()) {
                for(Applicant__c objApplicant : objLoanApp.Applicants__r){
                    Map<String, CustomerSummaryController.exposureWrapper> exposureNewMap = CustomerSummaryController.getExposureMap(objApplicant.SF_Exposure_JSON__c);
                    for (String key: exposureNewMap.keySet()) {
                        if(!setExistingLoanApp.contains(key)){
                            setExistingLoanApp.add(key);
                            CustomerSummaryController.exposureWrapper newExposure = exposureNewMap.get(key);
                            if (newExposure.includeInExposure == 'Yes') {
                                TotalExposure = TotalExposure + Decimal.valueof(newExposure.LoanAmount);
                                FinalExposure = TotalExposure;
                                ApprovedButNotDisbursed = ApprovedButNotDisbursed + Decimal.valueof(newExposure.LoanAmount);//SFAU-4307
                                if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && mapProductvsRT.get(newExposure.Product) == GlobalConstants.TWOWHEELER) {
                                    WheelsExposure = WheelsExposure + Decimal.valueof(newExposure.LoanAmount);
                                }
                                //if (ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && (mapProductvsRT.get(newExposure.Product) == GlobalConstants.FOURWHEELER || mapProductvsRT.get(newExposure.Product) == GlobalConstants.TWOWHEELER)) {
                                if (setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP + strProducttoPurchase).RecordType__c) && (setFourWheeler.contains(mapProductvsRT.get(newExposure.Product)) || mapProductvsRT.get(newExposure.Product) == GlobalConstants.TWOWHEELER)) {
                                    WheelsExposure = WheelsExposure + Decimal.valueof(newExposure.LoanAmount);
                                }
                            }
                        }
                    }
                    setApplicantId.add(objApplicant.Id);
                }
            }
            
            Set<String> setAccountNumber = new Set<String>();
            Map<String,String> mapProductIdvsRecordType = getRecordTypeMap();
            if(!setApplicantId.isEmpty()){
                for(Bank_Account_Records__c objBankAccount : [SELECT Id, No_of_Emi_Paid__c, Over_Limit_Amount__c, Loan_Overdue_EMI__c, POS__c,Sanctioned_Amount__c, Loan_Amount__c,Maturity_Date__c,Current_Status__c,
                            RecordType.DeveloperName, Account_Type__c, Account_Number__c,Include_In_Exposure__c,OD_Limit_Sanctioned__c,Product_Code__c
                            FROM Bank_Account_Records__c WHERE RecordType.DeveloperName = 'CBS' AND Applicant__c =: setApplicantId WITH SECURITY_ENFORCED]){
                    if(!setExistingLoanApp.contains(objBankAccount.Account_Number__c)){
                        setExistingLoanApp.add(objBankAccount.Account_Number__c);
                        if(objBankAccount.Account_Type__c == GlobalConstants.LOAN && objBankAccount.Include_In_Exposure__c == 'Yes'){
                            TotalExposure = TotalExposure + objBankAccount.POS__c;
                            FinalExposure = TotalExposure;
                            //SFAU-4307
                            LoanAmtTillDateAllLoans = LoanAmtTillDateAllLoans+objBankAccount.Loan_Amount__c;
                            if(objBankAccount.Maturity_Date__c>Date.today()){
                                LoanAmtTillDateRunningLoans = LoanAmtTillDateRunningLoans+objBankAccount.Loan_Amount__c;
                                PosOfAllLiveLoans = PosOfAllLiveLoans+objBankAccount.POS__c;
                            }
                            //SFAU-4307
                            if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.TWOWHEELER && 
                                mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER){
                                WheelsExposure = WheelsExposure + objBankAccount.POS__c;
                            }
                            //if(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c == GlobalConstants.FOURWHEELER && 
                            //    (mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.FOURWHEELER || mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER)){
                            if(setFourWheeler.contains(ProductRTMap__mdt.getInstance(GlobalConstants.PREFIXPRODRTMAP+strProducttoPurchase).RecordType__c) && 
                                (setFourWheeler.contains(mapProductIdvsRecordType.get(objBankAccount.Product_Code__c)) || mapProductIdvsRecordType.get(objBankAccount.Product_Code__c) == GlobalConstants.TWOWHEELER)){

                                WheelsExposure = WheelsExposure + objBankAccount.POS__c;
                            }
                        }
                        if(objBankAccount.Account_Type__c == GlobalConstants.ODCC && objBankAccount.Include_In_Exposure__c == 'Yes'){
                            TotalExposure = TotalExposure + objBankAccount.OD_Limit_Sanctioned__c;
                            FinalExposure = TotalExposure;
                            //SFAU-4307
                            LoanAmtTillDateAllLoans = LoanAmtTillDateAllLoans+objBankAccount.OD_Limit_Sanctioned__c;
                            if(!objBankAccount.Current_Status__c.contains('CLOSED')){
                                LoanAmtTillDateRunningLoans = LoanAmtTillDateRunningLoans+objBankAccount.OD_Limit_Sanctioned__c;
                                PosOfAllLiveLoans = PosOfAllLiveLoans+objBankAccount.OD_Limit_Sanctioned__c;
                            }
                            //SFAU-4307
                        }
                        if(objBankAccount.Account_Type__c == GlobalConstants.CC && objBankAccount.Include_In_Exposure__c == 'Yes'){                    
                            TotalExposure = TotalExposure + objBankAccount.Sanctioned_Amount__c;
                            FinalExposure = TotalExposure;
                            //if(objBankAccount.Include_In_Exposure__c == 'Yes'){                    
                                //objApplicant.Total_Exposure__c = objApplicant.Total_Exposure__c + objBankAccount.Sanctioned_Amount__c;
                                //objApplicant.Final_Exposure__c = objApplicant.Total_Exposure__c;
                                //SFAU-4307
                                LoanAmtTillDateAllLoans = LoanAmtTillDateAllLoans+objBankAccount.Sanctioned_Amount__c;
                                if(!objBankAccount.Current_Status__c.contains('CLOSED')){
                                    LoanAmtTillDateRunningLoans = LoanAmtTillDateRunningLoans+objBankAccount.Sanctioned_Amount__c;
                                    PosOfAllLiveLoans = PosOfAllLiveLoans+objBankAccount.Sanctioned_Amount__c;
                                }
                                //SFAU-4307
                            //}
                        }
                    }
                }
            }
            
            objLoanApp.Wheels_Exposure__c = WheelsExposure;
            objLoanApp.POS_As_On_Date_Two_Wheeler__c = WheelsExposure;
            objLoanApp.Total_Exposure__c = TotalExposure;
            if(FinalExposure != null && objLoanApp.Total_Loan_Amount__c != null){
                objLoanApp.Final_Exposure__c = FinalExposure +  objLoanApp.Total_Loan_Amount__c;
            }
            //SFAU-4307
            objLoanApp.Loan_Amt_Till_Date_inc_Closed_Loans__c = LoanAmtTillDateAllLoans;
            objLoanApp.Loan_Amt_Till_Date_all_Running_Loans__c = LoanAmtTillDateRunningLoans;
            objLoanApp.POS_of_all_Live_loans__c = PosOfAllLiveLoans;
            objLoanApp.Approved_but_not_Disbursed__c = ApprovedButNotDisbursed;
            //SFAU-4307

            if(objLoanApp.RecordType.Name == 'Two Wheeler' && WheelsExposure != null && objLoanApp.Total_Loan_Amount__c != null){
                objLoanApp.Wheels_Exposure__c = WheelsExposure + objLoanApp.Total_Loan_Amount__c;
            }
            //START - SFAU-5730 - Fix DPD logic - IF DPD Found in Credit Card
            objLoanApp.Dpd_Found__c = (!objLoanApp.Dpd_Found__c && blnDPDFoundCC) ? true : objLoanApp.Dpd_Found__c;
            //END - SFAU-5730 - Fix DPD logic
            lstLoanApptoUpdate.add(objLoanApp);
            //SFAU-5783
            //DatabaseUtilit.updateRecords(lstLoanApptoUpdate,'');
            update lstLoanApptoUpdate;
            /*Loan_Application__c objLoanApp = [Select Id,Loan_Amount__c,Total_Loan_Amount__c,RecordType.Name from Loan_Application__c where Id = :strLoanId WITH SECURITY_ENFORCED limit 1];
            List<Loan_Application__c> lstLoanApptoUpdate = new List<Loan_Application__c>();
            AggregateResult[] groupedResults = [SELECT Loan__c, SUM(Total_Exposure__c), SUM(Wheels_Exposure__c), SUM(Final_Exposure__c) FROM Applicant__c where Loan__c = :strLoanId WITH SECURITY_ENFORCED GROUP BY Loan__c];
            for (AggregateResult ar : groupedResults)  {
                Loan_Application__c objLoanApptoUpdate = new Loan_Application__c();
                objLoanApptoUpdate.Id = String.valueOf(ar.get('Loan__c'));
                if(ar.get('expr0') != null){
                    objLoanApptoUpdate.Total_Exposure__c = Decimal.valueOf(String.valueOf(ar.get('expr0')));
                }
                else{
                    objLoanApptoUpdate.Total_Exposure__c = 0.00;
                }
                if(ar.get('expr1') != null){
                    if(objLoanApp.RecordType.Name == 'Two Wheeler'){
                        objLoanApptoUpdate.Wheels_Exposure__c = Decimal.valueOf(String.valueOf(ar.get('expr1'))) + objLoanApp.Total_Loan_Amount__c;
                    }
                    else{
                        objLoanApptoUpdate.Wheels_Exposure__c = Decimal.valueOf(String.valueOf(ar.get('expr1')));
                    }
                }
                else{
                    objLoanApptoUpdate.Wheels_Exposure__c = 0.00;
                }
                if(ar.get('expr2') != null){
                    objLoanApptoUpdate.Final_Exposure__c = Decimal.valueOf(String.valueOf(ar.get('expr2'))) + objLoanApp.Total_Loan_Amount__c;
                }
                else{
                    objLoanApptoUpdate.Final_Exposure__c = 0.00;
                }
                lstLoanApptoUpdate.add(objLoanApptoUpdate);
            }  
            DatabaseUtilit.updateRecords(lstLoanApptoUpdate,'');*/
        }
    }
    public static Boolean validateLeadDedupe( Loan_Application__c loanApplication ){
        if( loanApplication == null || String.isBlank( loanApplication.Mobile__c ) || String.isBlank( loanApplication.Product__c ) ){
            throw new LeadDedupeException( 'Mandatory details missing for Lead Dedupe' );
        }

        String[] applicableProductsForDedupe = Label.ApplicableProductsForMobileDedupe.split(';\\s*');

        if( !applicableProductsForDedupe.contains( loanApplication.Product__c ) ){
            return false;
        }

        String mobileNumber = loanApplication.Mobile__c;

        return [ SELECT COUNT() FROM Loan_Application__c WHERE Stage__c !=: GlobalConstants.DISBURSED AND Mobile__c =: mobileNumber ] > 0;

    }

    public class LeadDedupeException extends Exception{}


    /* SFAU-4934 - Copy IDDetails from Applicant to DocumentChecklist for CBS */
    public static void updateCBSDocumentChecklist (String applicantId, String strAadhaarNum, String strAadhaarStatus, String strPanNum, String strPanStatus) {
        List<Document_Checklist__c> lstDocumentCheckList = new List<Document_Checklist__c>();
        List<Document_Checklist__c> lstUpdateDocumentCheckList = new List<Document_Checklist__c>();
        List<String> lstCBSDocName = Label.CBS_Document_Name_List.split(',');
        try{
            lstDocumentCheckList = [Select Id, Document_Number__c, Document_Verification_Status__c, Document__c from Document_Checklist__c where Document__c in: lstCBSDocName and Applicant__c =: applicantId];
            for (Document_Checklist__c objDocList : lstDocumentCheckList) {
                if (objDocList.Document__c == Label.CBS_Document_Aadhaar && String.isNotBlank(strAadhaarNum)) {
                    objDocList.Document_Number__c = strAadhaarNum;
                    objDocList.Document_Verification_Status__c = strAadhaarStatus == GlobalConstants.COMPLETE ? 'Verified' : 'Not Verified';
                    lstUpdateDocumentCheckList.add(objDocList);
                }
                else if (objDocList.Document__c == Label.CBS_Document_Pan_Or_Form_60 && String.isNotBlank(strPanNum)) {
                    objDocList.Document_Number__c = strPanNum;
                    objDocList.Document_Verification_Status__c = strPanStatus == GlobalConstants.COMPLETE ? 'Verified' : 'Not Verified';
                    lstUpdateDocumentCheckList.add(objDocList);
                }
            }
            if (!lstUpdateDocumentCheckList.isEmpty()) {
                update lstUpdateDocumentCheckList;
            }
        }
        catch(Exception objException) {
            //SFAU-5783
            Log.error('LeadDedupeController :: updateCBSDocumentChecklist :: at LN ' + objException.getLineNumber()  + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantId);
            throw objException;
            //Log.error('Error in LeadDedupeController ' + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantId);
        }
    }

    //R2-34
    @AuraEnabled
    public static void updateNPAFieldOnApplicant(Id applicantId, Boolean isNPA){
        try {
            if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                ApplicantTriggerHandler.byPassApplicantTrigger = true;
                Applicant__c updateAppl = new Applicant__c();
                updateAppl.Id=applicantId;
                updateAppl.is_NPA_Resolved__c=!isNPA;
                update updateAppl;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //R2-34
    @AuraEnabled
    public static Loan_Application__c getLoanDetails(Id applicationId){
        try {
            List<Loan_Application__c> loanApps = [SELECT Id, RecordType.DeveloperName FROM Loan_Application__c WHERE Id=:applicationId];
            if(!loanApps.isEmpty()){
                return loanApps[0];
            }else{
                return null;
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}