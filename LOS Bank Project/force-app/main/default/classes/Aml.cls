public without sharing class Aml {
    public static List<Applicant__c> applcntRecLst;
    @AuraEnabled public List<Applicant__c> applList;
    public static String applcntId;
    public static String loanApplicationId;
    public static Map<String, String> replacements;
    @AuraEnabled public String additionalMatchId;
    @AuraEnabled public String additionalMatchName;
    public static List<Applicant__c> getApplicant(ID recordId) {
        system.debug('in getApplicant');
        List<Applicant__c> applicantList = [SELECT Id,CIN__c,CKYC__c,Customer_Name__c,Recordtype.Name,PAN__c,Aadhaar_Number__c,CFR_Status__c, Negative_Check_Status__c,AML_Status__c,
                                            Related_Party_Status__c,IsInactive__c, Inactive_reason__c,Passport_Number__c,Mobile_Number__c,Email__c,Customer_Type__c,Loan__r.Application_Id__c,
                                            Voter_Id__c,Loan__c,Loan__r.Remarks__c,Driving_License_Id__c,Dob__c,Gender__c,Loan__r.Pre_Approved_Flag__c,
                                            Last_CIBIL_Run_Date__c, CIBIL_Status__c, CIBIL_Rerun__c, Bureau_Score__c
                                            FROM Applicant__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
        return applicantList;
    }
    @AuraEnabled
    public static Aml getUpdatedApplicantCibil(String applcntId) {
        List<Applicant__c> applWithAddMatch = new List<Applicant__c>();
        List<Applicant__c> applicantLst = [SELECT Id,AML_Status__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                           (SELECT id, API_Error__c, Integration_Master__r.Name, Is_Response_In_Attachment__c
                                            FROM Integration_Checklists__r
                                            WHERE (Integration_Master__r.Name = 'Cibil Individual')
                                            ORDER BY createddate DESC LIMIT 1),
                                           (SELECT id, Bureau_Score__c
                                            FROM Bureau_Results__r
                                            WHERE (Bureau__c = 'CIBIL')
                                            ORDER BY createddate DESC LIMIT 1)
                                           FROM Applicant__c WHERE Id =:applcntId AND IsInactive__c = false];
        if(applicantLst.size() > 0 && applicantLst[0].Bureau_Results__r.size() > 0) {
            applWithAddMatch = [SELECT Id
                                FROM Applicant__c
                                WHERE (RecordType.Name = 'Additional Match' AND Bureau_Results__c =: applicantLst[0].Bureau_Results__r[0].id) AND IsInactive__c = false
                                WITH SECURITY_ENFORCED
                                ORDER BY createddate DESC LIMIT 1];
        }
        String applWithAddMatchId = applWithAddMatch.size() > 0 ? String.valueOf(applWithAddMatch[0].Id) : '';
        Aml amlObj = new Aml();
        amlObj.applList = new List<Applicant__c>();
        amlObj.applList = applicantLst;
        amlObj.additionalMatchId = applWithAddMatchId;
        system.debug('amlObj-- '+JSON.serialize(amlObj));
        return amlObj;
    }
    @AuraEnabled
    public static ContentDocumentWrapper getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
        List<ContentVersion> docs = new List<ContentVersion>();
        Set<Id> cdls = new Set<Id>();
        for(ContentDocumentLink cdl : files ){
            cdls.add(cdl.ContentDocumentId);
        }
        if(files.size() > 0) {
            docs = [SELECT Id, ContentDocumentId, FileExtension, Title
                    FROM ContentVersion WHERE ContentDocumentId IN: cdls and title='Cibil' WITH SECURITY_ENFORCED];
        }
        ContentDocumentWrapper obj = new ContentDocumentWrapper();
        obj.contentDocumentId = docs.size() > 0 ? String.valueOf(docs[0].ContentDocumentId) : '';
        obj.contentVersionId = docs.size() > 0 ? String.valueOf(docs[0].Id) : '';
        system.debug('obj--> '+obj);
        return obj;
    }
    public class ContentDocumentWrapper {
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String contentVersionId;
    }
    public static List<Integration_Checklist__c> getIntegCheckList(String applcntId) {
        List<Integration_Checklist__c> integChcklst = [SELECT id, name, Status__c,Response__c,Callback_Request__c
                                                       FROM Integration_Checklist__c
                                                       WHERE (Integration_Master__r.Name = 'Aml') and Applicant__c =: applcntId WITH SECURITY_ENFORCED
                                                       ORDER BY createddate DESC LIMIT 1];
        return integChcklst;
    }
    @AuraEnabled
    public static CallAmlHandlerWrapper callAmlHandler(String applcntId) {
        applcntRecLst = new List<Applicant__c>(getApplicant(applcntId));
        loanApplicationId =  !applcntRecLst.IsEmpty()  ? applcntRecLst[0].Loan__r.Application_Id__c : '' ;
        CallAmlHandlerWrapper callAmlHandlerObj = new CallAmlHandlerWrapper();
        if(!applcntRecLst.isEmpty() && applcntRecLst[0].AML_Status__c != null){
            callAmlHandlerObj.integChcklst = getIntegCheckList(applcntId);
            callAmlHandlerObj.amldeserializeResponse = callAmlHandlerObj.integChcklst != null && !callAmlHandlerObj.integChcklst.isEmpty() ? (AMLWrapper)JSON.deserialize(callAmlHandlerObj.integChcklst[0].Response__c, AMLWrapper.Class) : new AMLWrapper();
            if(callAmlHandlerObj.integChcklst != null && !callAmlHandlerObj.integChcklst.isEmpty() &&  callAmlHandlerObj.integChcklst[0].Callback_Request__c != null){
                Map<String,Object> callBackResponse = (Map<String,Object>) JSON.deserializeUntyped(callAmlHandlerObj.integChcklst[0].Callback_Request__c);
                callAmlHandlerObj.amldeserializeResponse.AML_ACTION =  (String) callBackResponse.get('AML_ACTION');
            }
            if(String.isBlank(applcntRecLst[0].CIBIL_Status__c) || applcntRecLst[0].Last_CIBIL_Run_Date__c < System.today().addDays(-30)){
                AML.applcntId = applcntId;
                if(!callAmlHandlerObj.integChcklst.isEmpty() && callAmlHandlerObj.integChcklst.size()>0)
                    updateApplcntAferAmlResp( callAmlHandlerObj.integChcklst[0].Response__c ,applcntRecLst[0],false);
            }
        }else{
            String resBody = callAml(applcntId);
            system.debug('resBody-- '+resBody);
            AMLWrapper deserializeResponse = (AMLWrapper)JSON.deserialize(resBody, AMLWrapper.Class);
            system.debug('deserializeResponse-- '+JSON.serialize(deserializeResponse));
            callAmlHandlerObj.amldeserializeResponse = deserializeResponse;
            List<Integration_Checklist__c> integChcklst = getIntegCheckList(applcntId);
            callAmlHandlerObj.integChcklst = integChcklst;   
        }

      //callAmlHandlerObj.applcntList = getApplicant(applcntId); Commented by Kunal (No need to query again)
        callAmlHandlerObj.applcntList = applcntRecLst;
        return callAmlHandlerObj;
    }
    public static String callAml(String applcId) {
        applcntId = applcId;
        AMLWrapper amlObj = generateJSONForAMLReq();
        String body = JSON.serialize(amlObj);
        body = IntegrationUtility.mogrifyJSON(body, replacements);
        system.debug('body of generateJSONForAMLReq --> ' + body);
        Applicant__c app = new Applicant__c();
        app.AML_Verification_Start_Date__c = System.Now();
        String resBody = createAmlRequest(body, amlObj.referenceid);
        app.AML_Verification_End_Date__c = System.Now();
        app.Customer_Type__c = applcntRecLst[0].Customer_Type__c;
        updateApplcntAferAmlResp(resBody,app,true);
        return resBody;
    }
    public class CallAmlHandlerWrapper {
        @AuraEnabled public List<Integration_Checklist__c> integChcklst;
        @AuraEnabled public List<Applicant__c> applcntList;
        @AuraEnabled public AMLWrapper amldeserializeResponse;
    }
    public static Map<String, String> initMap() {
        Map<String, String> fldApiNameTOFldLabel = new Map<String, String> {
            'Customer_Name__c' => 'name',
                'Passport_Number__c' => 'passport',
                'PAN__c' => 'pan',
                'Mobile_Number__c' => 'mobile',
                'Email__c' => 'email',
                'Driving_License_Id__c' => 'driving_license',
                'Aadhaar_Number__c' => 'aadhar_no',
                'CKYC__c' => 'ckyc',
                'Voter_Id__c' => 'vid',
                'address' => 'address',
                'CIN__c' => 'cinno',
                'Identification_id_1' => 'identification_id_1',
                'Identification_id_2' => 'identification_id_2',
                'Identification_id_3' => 'identification_id_3',
                'Dob__c' => 'dob',
                'E/I' => 'e/i',
                'Nationality' => 'nationality',
                'Country' => 'country',
                'Gender__c' => 'gender'
                };
                    return fldApiNameTOFldLabel;
    }
    public static List<Address__c> getApplcntAddress(String applicantId, String addressType) {
        List<Address__c> applcntAddressList = [SELECT id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, Pincode__c
                                               FROM Address__c where (Applicant__c =: applicantId AND Address_Type__c =: addressType) WITH SECURITY_ENFORCED];
        return applcntAddressList;
    }
    public static String getCurrentApplcntAddress(String addressType) {
        String currntApplcntAddrss = '';
        String addrssLn1 = '';
        String addrssLn2 = '';
        String addrssLn3 = '';
        String city = '';
        String pinCode = '';
        List<Address__c> currntApplcntAddrssLst = getApplcntAddress(applcntRecLst[0].Id, addressType);
        if(currntApplcntAddrssLst.size() > 0) {
            addrssLn1 = String.isNotBlank(currntApplcntAddrssLst[0].Address_Line_1__c) ? currntApplcntAddrssLst[0].Address_Line_1__c + ', ' : '';
            addrssLn2 = String.isNotBlank(currntApplcntAddrssLst[0].Address_Line_2__c) ? currntApplcntAddrssLst[0].Address_Line_2__c + ', ' : '';
            addrssLn3 = String.isNotBlank(currntApplcntAddrssLst[0].Address_Line_3__c) ? currntApplcntAddrssLst[0].Address_Line_3__c + ', ' : '';
            city = String.isNotBlank(currntApplcntAddrssLst[0].City__c) ? currntApplcntAddrssLst[0].City__c + ', ' : '';
            pinCode = String.isNotBlank(currntApplcntAddrssLst[0].Pincode__c) ? currntApplcntAddrssLst[0].Pincode__c : '';
            currntApplcntAddrss = addrssLn1 + addrssLn2 + addrssLn3 + city + pinCode;
        }
        return currntApplcntAddrss;
    }
    public static AMLWrapper.fields createFldsForAmlWrapper(String name, String value) {
        AMLWrapper.Fields fldObj = new AMLWrapper.Fields();
        fldObj.name = name;
        fldObj.value = value;
        return fldObj;
    }
    public static AMLWrapper generateFieldsJSON(AMLWrapper amlObj) {
        String currentApplcntAddress = getCurrentApplcntAddress('Current');
        Map<String, String> fldApiNameTOFldLabel = initMap();
        String customerType = applcntRecLst[0].Customer_Type__c;
        for(String fldApiName : fldApiNameTOFldLabel.keySet()) {
            String name = '';
            String value = 'NIL';
            String valueInString = fldApiName.endsWithIgnoreCase('__c') ? String.valueOf(applcntRecLst[0].get(fldApiName)) : '';
            name = fldApiNameTOFldLabel.get(fldApiName);
            if(fldApiName == 'Identification_id_1' || fldApiName == 'Identification_id_2' || fldApiName == 'Identification_id_3') {
                value = 'NIL';
            }
            else if(fldApiName == 'address') {
                value = String.isNotBlank(currentApplcntAddress) ? currentApplcntAddress : 'NIL';
            }
            else if(fldApiName == 'dob__c') {
                Date dob = Date.valueOf(applcntRecLst[0].get(fldApiName));
                valueInString = dob != null ? dob.day() + '-' + dob.month() + '-' + dob.year() : '';
                value = String.isNotBlank(valueInString) ? valueInString : 'NIL';
            }
            else if(fldApiName == 'Gender__c') {
                value = customerType == 'Non Individual' || String.isBlank(customerType) ? 'NIL' : valueInString;
            }
            else if(fldApiName == 'Nationality' || fldApiName == 'Country') {
                value = 'INDIA';
            }
            else if(fldApiName == 'E/I') {
                value = customerType == 'Individual' ? 'I' : 'E';
            }
            else {
                value = String.isNotBlank(valueInString) ? valueInString : 'NIL';
            }
            AMLWrapper.Fields fldObj = createFldsForAmlWrapper(name, value);
            amlObj.fields.add(fldObj);
        }
        return amlObj;
    }
    public static AMLWrapper generateJSONForAMLReq() {
        String currentDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss'));
        replacements = new Map<String, String> {
            'datetimex' => 'datetime',
                'batchmode' => 'batch_mode'
                };
                  //  String refId = IntegrationUtility.getReferenceId();
      //  refId = refId.left(2) + refId.right(refId.length()-4);
        AMLWrapper amlObj = new AMLWrapper();
        amlObj.datetimex = currentDateTime;
        amlObj.systemname = 'SFDC';
        amlObj.batchmode = 'O';
       // amlObj.callbackurl = 'https://osbuat.aubankuat.in/Clari5CallBack/callback';
        amlObj.callbackurl = Label.AML_Callback_URL;
        amlObj.refid = loanApplicationId;
        amlObj.userid = 'SYS';
        amlObj.referenceid = IntegrationUtility.getReferenceId();
        amlObj.fields = new List<AMLWrapper.Fields>();
        generateFieldsJSON(amlObj);
        return amlObj;
    }
    public static String createAmlRequest(String requestBody, String refId) {
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord('AML');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId, request_id__c = refId);
        String respBody;
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();

        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-- ' +respBody);
        return respBody;
    }
    public static void updateApplcntAferAmlResp(String resBody,Applicant__c applcntRec, Boolean updateAML) {
        AMLWrapper deserializeResponse = (AMLWrapper)JSON.deserialize(resBody, AMLWrapper.Class);
        Map<Id,Applicant__c> updateApplcntLst = new Map<Id,Applicant__c>();
        applcntRec.Id  = applcntId;
        Final String AML_ACTION = deserializeResponse.AML_ACTION;
        String match = deserializeResponse.MATCH;
        if(String.isNotBlank(match) && match == 'NO' && updateAML) {
            applcntRec.AML_Status__c = AML_ACTION;
            updateApplcntLst.put(applcntRec.Id,applcntRec);
        }
        else if(String.isNotBlank(match) && match == 'Yes' && updateAML) {
            applcntRec.AML_Status__c = 'Pending';
            updateApplcntLst.put(applcntRec.Id,applcntRec);
        }
        if( (applcntRec.AML_Status__c == 'Approved' || applcntRec.AML_Status__c == 'Pending') && applcntRec.Customer_Type__c == 'Individual' ){
            Applicant__c currntAppCibilWithInLastMonth;
            Applicant__c currntAppCibilBeforeLastMonth;
            Applicant__c othrAppCibilWithInLastMonth;
            Applicant__c othrAppCibilBeforeLastMonth;
            
            
            //Added by Samridhi - start
            appWrapper existingDetailWrapper = checkExistingApplicantCibil(applcntId);
            if(existingDetailWrapper.currentApplicant!= null && existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c!= null){
                if(existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c > System.today().addDays(-30)){
                    currntAppCibilWithInLastMonth = existingDetailWrapper.currentApplicant;
                }else{
                    currntAppCibilBeforeLastMonth = existingDetailWrapper.currentApplicant;
                }
            }else if(existingDetailWrapper.existingApplicant!= null && existingDetailWrapper.existingApplicant.Last_CIBIL_Run_Date__c!= null){
                if(existingDetailWrapper.existingApplicant.Last_CIBIL_Run_Date__c > System.today().addDays(-30)){
                    othrAppCibilWithInLastMonth = existingDetailWrapper.existingApplicant;
                }else{
                    othrAppCibilBeforeLastMonth = existingDetailWrapper.existingApplicant;
                }
            }

            //Added by Samridhi - end
            system.debug('currntAppCibilWithInLastMonth------>'+currntAppCibilWithInLastMonth);
            system.debug('currntAppCibilBeforeLastMonth------>'+currntAppCibilBeforeLastMonth);
            system.debug('othrAppCibilWithInLastMonth------>'+othrAppCibilWithInLastMonth);
            system.debug('othrAppCibilBeforeLastMonth------>'+othrAppCibilBeforeLastMonth);
            // if there is no current and other Applicant having Last CIBIL Run Date Run with in 30 days and more than 30 days, run CibilQueueable
            if(currntAppCibilWithInLastMonth == null && othrAppCibilWithInLastMonth == null && currntAppCibilBeforeLastMonth == null && othrAppCibilBeforeLastMonth == null){
                Id jobId = System.enqueueJob(new CibilQueueable (applcntId));
            }
            // else if there is current Applicant having Last CIBIL Run Date Run with in 30 days, skip rerun CibilQueueable
            else if (currntAppCibilWithInLastMonth != null){
                system.debug('IN currntAppCibilWithInLastMonth---->');
                applcntRec.CIBIL_Status__c = 'Skipped';
                applcntRec.CIBIL_Skip_Reason__c = 'Last run within 30 days';
                updateApplcntLst.put(applcntRec.Id,applcntRec);
                //applcntRec.Bureau_Score__c = currntAppCibilWithInLastMonth.Bureau_Score__c;
                //applcntRec.Last_CIBIL_Run_Date__c = currntAppCibilWithInLastMonth.Last_CIBIL_Run_Date__c;
            }
            // Added by Samridhi - else if there is other Applicant having Last CIBIL Run Date Run over 30 days, reset Cibil rerun as true
            else if(currntAppCibilBeforeLastMonth!= null){
                applcntRec.CIBIL_Rerun__c = true;
                updateApplcntLst.put(applcntRec.Id,applcntRec);
            }
            // else if there is other Applicant having Last CIBIL Run Date Run with in 30 days, skip rerun CibilQueueable and clone the all CIBIL related records under current applicant
            else if (othrAppCibilWithInLastMonth != null && existingDetailWrapper.currentApplicant!=null && existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c == null){
                system.debug('IN othrAppCibilWithInLastMonth---->');
                applcntRec.CIBIL_Status__c = 'Skipped';
                applcntRec.CIBIL_Skip_Reason__c = 'Last run within 30 days';
                applcntRec.Bureau_Score__c = othrAppCibilWithInLastMonth.Bureau_Score__c;
                applcntRec.Last_CIBIL_Run_Date__c = othrAppCibilWithInLastMonth.Last_CIBIL_Run_Date__c;
                updateApplcntLst.put(applcntRec.Id,applcntRec);
                cloneCibilRecords(applcntId, othrAppCibilWithInLastMonth.Id);
            }
            // else if there is current or other Applicant having Last CIBIL Run Date Run before 30 days, reset Cibil rerun as true
            else if (currntAppCibilBeforeLastMonth != null || othrAppCibilBeforeLastMonth != null){
                system.debug('IN currntAppCibilBeforeLastMonth othrAppCibilBeforeLastMonth---->');
                applcntRec.CIBIL_Rerun__c = true;
                if(othrAppCibilBeforeLastMonth != null){
                    applcntRec.Bureau_Score__c = othrAppCibilBeforeLastMonth.Bureau_Score__c;
                    applcntRec.Last_CIBIL_Run_Date__c = othrAppCibilBeforeLastMonth.Last_CIBIL_Run_Date__c;
                }
                updateApplcntLst.put(applcntRec.Id,applcntRec);
            }
            /* }
else{
System.debug('Cibil Input Data Error');
}
*/
        }
        if(updateApplcntLst.values().size() > 0) {
            DatabaseUtility.updateRecords(updateApplcntLst.values(), 'Applicant__c');
        }
    }
    public static appWrapper checkExistingApplicantCibil(String appRecordId){
        Applicant__c appRec = [SELECT Id, Aadhaar_Number__c, PAN__c, Last_CIBIL_Run_Date__c, Bureau_Score__c from Applicant__c where Id =: appRecordId WITH SECURITY_ENFORCED];
        List<Applicant__c> existingAppList = new List<Applicant__c>();
        existingAppList = [SELECT Id, Last_CIBIL_Run_Date__c, Bureau_Score__c,(SELECT Id From Bureau_Results__r Where Bureau_Score__c != null Order by LastModifiedDate desc) // Should be added in query - Kunal
                           FROM Applicant__c
                           WHERE ((Aadhaar_Number__c =: appRec.Aadhaar_Number__c AND Aadhaar_Number__c != null) OR (PAN__c =: appRec.PAN__c AND PAN__c != null))
                           AND Last_CIBIL_Run_Date__c != null
                           AND RecordTypeId IN: GlobalConstants.APPLICANTS_RECORD_TYPES_IDS 
                           WITH SECURITY_ENFORCED
                           ORDER BY Last_CIBIL_Run_Date__c desc];
        appWrapper wrapper;
        if(existingAppList.size() > 0){
            for(Applicant__c applicant : existingAppList){
                if(applicant.Bureau_Results__r != null && !applicant.Bureau_Results__r.isEmpty()){
                    wrapper = new appWrapper(appRec, applicant);
                    return wrapper;
                }
            }
        }
        wrapper = new appWrapper(appRec, null);
        return wrapper;
    }
    public static void cloneCibilRecords(String appRecordId, String othrAppRecordId){
        system.debug('cloneCibilRecords---->'+appRecordId+','+othrAppRecordId);
        List<Bureau_Results__c> bureauResultList = new List<Bureau_Results__c>();
        List<Address__c> addressListCloneCopy = new List<Address__c>();
        List<Bank_Account_Records__c> barListCloneCopy = new List<Bank_Account_Records__c>();
        List<Applicant__c> additionalApplicantList = new List<Applicant__c>();
        List<Address__c> additionalMatchAddressListCloneCopy = new List<Address__c>();
        bureauResultList = [SELECT Id, Bureau__c, Name, Name_of_Applicant__c, DOB__c, TelephoneNumber__c, EmailID__c, Bureau_Score__c,Bureau_Response__c,
                            Bureau_Score_Date__c, Account_High_Credit_Amount__c, Accounts_Overdue_Amount__c, Total_EMI_Amount__c
                            FROM Bureau_Results__c
                            WHERE Applicant__c =: othrAppRecordId AND Bureau__c = 'CIBIL'
                            WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        system.debug('bureauResultList---->'+bureauResultList);
        if(!bureauResultList.isEmpty() && bureauResultList.size() > 0){
            //Cloning the existing Bureau_Results__c Record
            Bureau_Results__c bureauResultCloneCopy = bureauResultList[0].clone(false, false, false, false);
            bureauResultCloneCopy.Applicant__c = appRecordId;
            system.debug('bureauResultCloneCopy---->'+bureauResultCloneCopy);
            Insert bureauResultCloneCopy;
                        //Cloning the existing Bureau_Results__c related Address__c Records
            for(Address__c address : [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, Pincode__c,
                                      Address_Type__c, Date_Reported__c, Enriched_Through_Enquiry__c, Source_Type__c
                                      FROM Address__c
                                      WHERE Bureau_Results__c =: bureauResultList[0].Id]){
                                          Address__c addressCloneCopy = address.clone(false, false, false, false);
                                          addressCloneCopy.Applicant__c = appRecordId;
                                          addressCloneCopy.Bureau_Results__c = bureauResultCloneCopy.Id;
                                          addressListCloneCopy.add(addressCloneCopy);
                                      }
            if(!bureauResultList.isEmpty() && addressListCloneCopy.size() > 0){
                Insert addressListCloneCopy;
                Set<Id> resultIds = (new Map<Id,SObject>(addressListCloneCopy)).keySet();
                LOSKarzaAddressMatchController.callAddressParsingMethod(resultIds, appRecordId);
            }
            //Cloning the existing Bureau_Results__c related Bank_Account_Records__c Records
            for(Bank_Account_Records__c bar : [SELECT Id, Name_of_the_Financier__c, Type_of_Loan__c, ROI__c, No_of_Emi_Paid__c, Tenure__c,
                                               EMI_Amount__c, Amount_Overdue__c, Owenership_Indicator__c, Suit_Filed_Or_Wilful_Default__c,
                                               Written_Off_And_Settled__c, Payment_Frequency__c, Account_Opening_Date__c, Loan_Amount__c,
                                               Last_Payment_Date__c, Total_Outstanding__c, RecordTypeId, Payment_History_Start_Date__c,
                                               Payment_History_End_Date__c, Payment_History__c, Highest_6_Month_DPD__c, Highest_12_Month_DPD__c,
                                               Highest_12_24_Month_DPD__c, Highest_24_36_Month_DPD__c, Highest_Overall_DPD__c, Reported_Date__c,
                                               Is_Enquiry_Type__c, Date_Of_Enquiry__c
                                               FROM Bank_Account_Records__c
                                               WHERE Bureau_Results__c =: bureauResultList[0].Id]){
                                                   Bank_Account_Records__c barCloneCopy = bar.clone(false, false, false, false);
                                                   barCloneCopy.Applicant__c = appRecordId;
                                                   barCloneCopy.Bureau_Results__c = bureauResultCloneCopy.Id;
                                                   barListCloneCopy.add(barCloneCopy);
                                               }
            if(!barListCloneCopy.isEmpty() && barListCloneCopy.size() > 0){
                Insert barListCloneCopy;
            }
            String loanAppId = [Select Id, Loan__c from Applicant__c where Id =: appRecordId]?.Loan__c;
            additionalApplicantList = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Dob__c, Gender__c,
                                       PAN__c, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c,
                                       Mobile_Number__c, Email__c, Bureau_Score__c, Last_CIBIL_Run_Date__c, CIBIL_Status__c, CIBIL_Rerun__c
                                       FROM Applicant__c
                                       WHERE Bureau_Results__c =: bureauResultList[0].Id AND Recordtype.Name ='Additional Match'
                                       ORDER BY CreatedDate DESC];
            cloneRelatedFiles(bureauResultList,bureauResultCloneCopy);
            if(!additionalApplicantList.isEmpty() && additionalApplicantList.size() > 0){
                //Cloning the existing Bureau_Results__c related Additional Match Applicant Record
                Applicant__c applicantCloneCopy = additionalApplicantList[0].clone(false, false, false, false);
                applicantCloneCopy.Applicant__c = appRecordId;
                applicantCloneCopy.Bureau_Results__c = bureauResultCloneCopy.Id;
                applicantCloneCopy.Loan__c = loanAppId;
                system.debug('applicantCloneCopy---->'+applicantCloneCopy);
                Insert applicantCloneCopy;
                //Cloning the existing Bureau_Results__c related Additional Match Applicant's Address Records
                for(Address__c address : [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, Pincode__c, Address_Type__c
                                          FROM Address__c
                                          WHERE Applicant__c =: additionalApplicantList[0].Id]){
                                              Address__c additionalMatchAddressCloneCopy = address.clone(false, false, false, false);
                                              additionalMatchAddressCloneCopy.Applicant__c = applicantCloneCopy.Id;
                                              additionalMatchAddressListCloneCopy.add(additionalMatchAddressCloneCopy);
                                          }
                if(!additionalMatchAddressListCloneCopy.isEmpty() && additionalMatchAddressListCloneCopy.size() > 0){
                    Insert additionalMatchAddressListCloneCopy;
                }
                /* Start : Clone Bureau results for additional match :: Kunal 16th Jan*/
                List<Bureau_Results__c> additionalBureauResultList = [SELECT Id, Bureau__c, Name, Name_of_Applicant__c, DOB__c, TelephoneNumber__c, EmailID__c, Bureau_Score__c,Bureau_Response__c,
                                    Bureau_Score_Date__c, Account_High_Credit_Amount__c, Accounts_Overdue_Amount__c, Total_EMI_Amount__c
                                    FROM Bureau_Results__c
                                    WHERE Applicant__c =: additionalApplicantList[0].id AND Bureau__c = 'CIBIL'
                                    WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];

                if(!additionalBureauResultList.isEmpty()){
                    //Cloning the existing Bureau_Results__c Record for Additional match
                    Bureau_Results__c addBureauResultCloneCopy = additionalBureauResultList[0].clone(false, false, false, false);
                    addBureauResultCloneCopy.Applicant__c = applicantCloneCopy.Id;
                    Insert addBureauResultCloneCopy;
                    cloneRelatedFiles(additionalBureauResultList,addBureauResultCloneCopy);
                }
                /* End : Clone Bureau results for additional match*/                    
            }

                
        }
    }

    public static void cloneRelatedFiles(List<Bureau_Results__c> bureauResultList, Bureau_Results__c bureauResultCloneCopy){
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> ContentDocumentLinkListCloneCopy = new List<ContentDocumentLink>();
        //Cloning the existing Bureau_Results__c related Cibil Report Record
        ContentDocumentLinkList = [SELECT Id, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId =: bureauResultList[0].Id AND ContentDocument.Title = 'Cibil' ORDER BY ContentDocument.createddate desc Limit 1];

        List<ContentDocumentLink> reportLinks  = [SELECT Id, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId =: bureauResultList[0].Id AND ContentDocument.Title = 'Response' ORDER BY ContentDocument.createddate desc Limit 1];

        system.debug('ContentDocumentLinkList'+ContentDocumentLinkList);
        List<ContentVersion> lstContentVersionCibil = [Select Id, Title, VersionData, Document_Type__c, PathOnClient, FirstPublishLocationId from ContentVersion where ContentDocumentId =: reportLinks[0].ContentDocumentId AND PathOnClient = 'Response.txt' order by LastModifiedDate desc Limit 1];
        List<ContentVersion> lstContentVersionReport = [Select Id, Title, VersionData, Document_Type__c, PathOnClient, FirstPublishLocationId from ContentVersion where ContentDocumentId =: ContentDocumentLinkList[0].ContentDocumentId AND PathOnClient = 'Cibil.html' order by LastModifiedDate desc Limit 1];

        List<ContentVersion> lstNewContentVersion = new List<ContentVersion>();
        if (!lstContentVersionCibil.isEmpty()) {
        ContentVersion objClone = lstContentVersionCibil[0].clone(false, false, false, false);
        objClone.ContentBodyId = NULL;
        objClone.Id = NULL;
        objClone.FirstPublishLocationId = bureauResultCloneCopy.Id;
        lstNewContentVersion.add(objClone);
        }
        if (!lstContentVersionReport.isEmpty()) {
        ContentVersion objClone = lstContentVersionReport[0].clone(false, false, false, false);
        objClone.ContentBodyId = NULL;
        objClone.Id = NULL;
        objClone.FirstPublishLocationId = bureauResultCloneCopy.Id;
        lstNewContentVersion.add(objClone);
        }

        if (!lstNewContentVersion.isEmpty()){
        insert lstNewContentVersion;
        }             
    }

    @AuraEnabled(cacheable=true)
	public static String getTypeOfWheeler(String applicantId) {
        List<Applicant__c> applts=[Select Loan__r.Product__c from Applicant__c where id=:applicantId];
        return Utility.getTypeOfWheeler(applts[0].Loan__r.Product__c);
        
    }    
    
    public class appWrapper{
        public Applicant__c currentApplicant;
        public Applicant__c existingApplicant;
        
        
        public appWrapper(Applicant__c currentApplicant, Applicant__c existingApplicant){
            this.currentApplicant = currentApplicant;
            this.existingApplicant = existingApplicant;
        }
    }
}