public without sharing class EMandateService implements IntegrationHandlerInterface {
    
    public static List<String> generateRequest(List<Object> recordList){
        return null;
    }
    public static String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    @AuraEnabled
    public static Boolean saveDetails(String pdcList,String spdcList,String loanId,String type,String repaymentMode,Integer countOfAchSi){
        try{
            Loan_Application__c loanObj = new Loan_Application__c(Id=loanId);
            System.debug('count '+countOfAchSi);
            if(type!=''){
                System.debug('loanObjId '+loanId+' List '+spdcList);
                if(type=='PDC'){
                    loanObj.PDC_Details__c = pdcList; 
                    loanObj.SPDC_Details__c = spdcList;
                }
                else if(type=='SPDC'){
                    List<Object> fieldList = (List<Object>)JSON.deserializeUntyped(spdcList);
                    Map<String,Object > mapObj = (Map<String,Object >)fieldList[0];
                    if(mapObj.get('bankName') == null){
                        loanObj.Apply_SPDC_Charges__c = true;
                    }
                    loanObj.SPDC_Details__c = spdcList;
                }
                System.debug('spdc '+loanObj.SPDC_Details__c);
                System.debug('pdc '+loanObj.PDC_Details__c);
            }
            if(countOfAchSi!=null || countOfAchSi!=-1){
                loanObj.Count_of_ACH_SI__c = Integer.valueOf(countOfAchSi); 
            }
            loanObj.Repayment_Mode__c = repaymentMode;
            update loanObj;
            return true;
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
        }
        return false;
    }
    @AuraEnabled  
    public static EMandateRegistrationResponseWrapper sendRegistrationDetails(String loanId, String userConfirmation, String paymentType) {
        //System.debug('Note data '+notepadData);
        System.debug('loanId '+loanId);
        Loan_Application__c loanObj =[SELECT Id,EMI__c,Loan_Amount__c,Total_Loan_Amount__c, Emi_Frequency__c,EMI_Date__c, First_EMI_Date__c, Repayment_Account_Number__c, Repayment_Bank_Name__c, Repayment_Mode__c, Repayment_Account_Type__c,Application_Id__c  FROM Loan_Application__c WHERE Id=:loanId]; 
        Applicant__c appObj = [SELECT Id, Email__c, Mobile_Number__c, First_Name__c, Last_Name__c, PAN__c,RecordType.Name,CIF_No__c  FROM Applicant__c WHERE RecordType.DeveloperName='Primary_Applicant' AND Loan__c=:loanId][0];
        Integration_Master__c objIntMaster;
        if(userConfirmation=='Yes'){
            objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.E_Mandate_Registration_Service);
        }
        else{
            objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.E_Mandate_Registration_Service_Without_User); 
        }
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanId);
        checklistRecord.Id = NULL;
        String strResponse;
        EMandateRegistrationResponseWrapper responseWrap;
        try{
            String strRequest = generateRequest(loanObj, appObj, objIntMaster,paymentType,userConfirmation);
            system.debug(LoggingLevel.DEBUG,'Request :: ' + strRequest);
            //EMandateRegistrationRequestWrapper objRequest = JSON.deserialize(strRequest, EMandateRegistrationRequestWrapper.class);
            EMandateRegistrationRequestWrapper objRequestWrap = (EMandateRegistrationRequestWrapper) JSON.deserialize(strRequest, EMandateRegistrationRequestWrapper.class);
            checklistRecord.Request_Id__c = objRequestWrap.requestId;
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = strRequest;
            calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMaster;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            strResponse = calloutResponseWrapper.response;
            if(calloutResponseWrapper.statusCode!=200){
                return null;
            }
            system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
            if(strResponse != null) {
                strResponse = strResponse.replace('[[','[');
                strResponse = strResponse.replace(']]',']');
                strResponse = strResponse.replaceAll('\r\n',' ');
                strResponse = strResponse.replaceAll('\t',' ');
                system.debug(LoggingLevel.Info,'response after parsing ' + strResponse);
                //system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
                //Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(strResponse);
                //System.debug('map '+root.get('Message'));
                responseWrap = (EMandateRegistrationResponseWrapper) JSON.deserialize(strResponse, EMandateRegistrationResponseWrapper.class);
                System.debug('response '+responseWrap);
                loanObj.Emandate_Journey__c = userConfirmation=='Yes'?'By Customer':'By RO';
                loanObj.Emandate_Payment_Type__c = paymentType;
                update loanObj;
                //sendEnquiryDetails(IntegrationUtility.getReferenceId());
            }
        } catch(Exception objException) {
            System.debug(LoggingLevel.Error,'error '+objException.getStackTraceString());
            System.debug(LoggingLevel.Error,'error '+objException.getMessage());
            System.debug(LoggingLevel.Error,'response---'+objException);
            System.debug(LoggingLevel.Error,'response-Line--'+objException.getLineNumber());
        }
        System.debug(LoggingLevel.Info,'response---'+responseWrap);
        
        return responseWrap;  
    }
    
    @testVisible
    private static String generateRequest(Loan_Application__c loanObj, Applicant__c appObj, Integration_Master__c intMaster,String paymentType,String userConfirmation){
        
        EMandateRegistrationRequestWrapper objRequest = new EMandateRegistrationRequestWrapper();
        objRequest.mbSvcProviderName = Label.EMandate_mbSvcProviderName;
        objRequest.channel = intMaster.Channel__c;
        System.debug('Start date '+Date.today());
        Date dToday;
        Date currentDate = Date.today();
        Date newDate;
        User u = [SELECT Id,Employee_Code__c FROM User Where Id =: UserInfo.getUserId()];
        if(loanObj.First_EMI_Date__c!=null){
            /*if(Integer.valueOf(loanObj.EMI_Date__c)<currentDate.day()){
                newDate = Date.newInstance(currentDate.year(), currentDate.month()+1, Integer.valueOf(loanObj.EMI_Date__c));
            }
            else{
                newDate = Date.newInstance(currentDate.year(), currentDate.month(), Integer.valueOf(loanObj.EMI_Date__c));
            }*/
            newDate = loanObj.First_EMI_Date__c;
            dToday = newDate;
            System.debug(newDate);
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            if(userConfirmation=='Yes'){
                String dateStr = dt.format('yyyyMMdd');
                System.debug('dateStr '+dateStr);
                objRequest.mbDateFrom = dateStr;
                //objRequest.mbDateTo = '';
                //SFAU-5156: Added by Samridhi
                objRequest.mbDateTo = DateTime.newInstance(dToday.year()+Integer.valueOf(Label.mbDateTo) , dToday.month(),dToday.day()).format('yyyyMMdd');
            }
            else{
                String dateStr = dt.format('MM/dd/yyyy');
                System.debug('dateStr '+dateStr);
                objRequest.mbDateFrom = dateStr;
                //SFAU-5156: Added by Samridhi
                objRequest.mbDateTo = DateTime.newInstance(dToday.year()+Integer.valueOf(Label.mbDateTo) , dToday.month(),dToday.day()).format('MM/dd/yyyy');//dToday.month() + '/' + dToday.day() + '/' + dToday.year()+40;//String.valueOf(Date.newInstance(System.today().year()+40, System.today().month(), System.today().Day())); //TBC
               // objRequest.mbDateTo = '';
            }
        } 
        
        if(loanObj.Repayment_Bank_Name__c!=null){
            String bankName = loanObj.Repayment_Bank_Name__c;
            System.debug('bank name is: '+bankName);
            Generic_Master__c bankObj = [SELECT Id,Bank_Name__c, Bank_Code__c FROM Generic_Master__c WHERE Bank_Name__c =:bankName AND RecordType.Name='Bank Master' LIMIT 1];
            if(bankObj!=null){
                objRequest.mbDRBankCode = bankObj.Bank_Code__c;
            }
        }
        
        //Moved fixed values to Custom Labels
        System.debug('today '+objRequest.mbDateFrom);
        objRequest.mbCustMailId = appObj.Email__c;
        objRequest.mbCustFonCellNum = appObj.Mobile_Number__c;
        objRequest.mbSvcProviderCode = Label.EMandate_mbSvcProviderCode;
        objRequest.mbSponserBankCode = Label.EMandate_mbSponserBankCode ;
        objRequest.mbFrequencyType = Label.EMandate_mbFrequencyType ;
        objRequest.requestId = IntegrationUtility.getReferenceId();
        //objRequest.responseURL = /*'https://ausfb2022--dev1.sandbox.my.salesforce.com/*/ URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/sobjects/Integration_Checklist__c/Request_Id__c/'+IntegrationUtility.getReferenceId();
        objRequest.mbCustName = appObj.First_Name__c+' '+appObj.Last_Name__c;
        objRequest.mbRefNumber = Label.EMandate_mbRefNumber;
        objRequest.mbMandateCategory = Label.EMandate_mbMandateCategory;
        objRequest.mbDRAccountNumber = loanObj.Repayment_Account_Number__c;//'1961214323579445';
        objRequest.mbMandateType = Label.EMandate_mbMandateType ;
        objRequest.mbRelRefNumber = loanObj.Application_Id__c;
        objRequest.mbCustFonLandNum = '';
        objRequest.callBackURL = Label.Emandate_callback;
        //SFAU-5156 : Added by Samridhi
        objRequest.mbAmount = loanObj.Total_Loan_Amount__c<5000000 ? String.valueOf(loanObj.Total_Loan_Amount__c):'5000000'; //'20000';
        //  objRequest.mbAmount = '500000';
        objRequest.mbPaymentType = paymentType; 
        objRequest.mbDRAccountType = loanObj.Repayment_Account_Type__c ;
        objRequest.mbFrequencyCode = Label.EMandate_mbFrequencyCode ;//Emi_Frequency__c 
        objRequest.mbFixedAmount = Label.EMandate_mbFixedAmount ;
        objRequest.referenceCode = objRequest.requestId.replace('_','');
        objRequest.mbCustPAN = appObj.PAN__c;
        //objRequest.username = u.Employee_Code__c;
        objRequest.username = Label.EMandate_Username;
        System.debug('Request '+JSON.serialize(objRequest));
        return JSON.serialize(objRequest);
    }
    
    /*@AuraEnabled 
public static EMandateRegistrationResponseWrapper.EMandateEnquiryResponseWrapper sendEnquiryDetails(String loanId) {
String regId;
List<Integration_Checklist__c> integChkLst = [SELECT id, Integration_Master_Name__c,Loan_Application__c, Response__c, Request__c
FROM Integration_Checklist__c where Loan_Application__c=:loanId AND Integration_Master_Name__c='E-Mandate Registration Without User'];
System.debug('int checklist '+integChkLst);
for(Integration_Checklist__c ic: integChkLst){
if(ic.Response__c!=null){
Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(ic.Response__c);
System.debug('response '+responseMap);
if(responseMap.get('ResponseMessage')=='Success'){
if(ic.Request__c!=null){
Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(ic.Request__c);
System.debug('request '+requestMap);
regId = String.valueOf(requestMap.get('requestId'));
}
}
}  
}
Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.E_Mandate_Enquiry); 

Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
checklistRecord.Id = NULL;
String strResponse;
EMandateRegistrationResponseWrapper.EMandateEnquiryResponseWrapper responseWrap;
try{
EMandateRegistrationRequestWrapper.EMandateEnquiry objRequest = new EMandateRegistrationRequestWrapper.EMandateEnquiry();
objRequest.channel = objIntMaster.Channel__c;
objRequest.referenceCode = regId;
objRequest.requestId = IntegrationUtility.getReferenceId();
String strRequest = JSON.serialize(objRequest);

system.debug(LoggingLevel.DEBUG,'Request :: ' + strRequest);

IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
calloutRequestWrapper.request = strRequest;
calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
calloutRequestWrapper.masterRecord = objIntMaster;
calloutRequestWrapper.checklistRecord = checklistRecord;
IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
strResponse = calloutResponseWrapper.response;
system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
if(strResponse != null) {
strResponse = strResponse.replace('[[','[');
strResponse = strResponse.replace(']]',']');
responseWrap = (EMandateRegistrationResponseWrapper.EMandateEnquiryResponseWrapper) JSON.deserialize(strResponse, EMandateRegistrationResponseWrapper.EMandateEnquiryResponseWrapper.class);
System.debug('response '+responseWrap);
}
} catch(Exception objException) {
System.debug(LoggingLevel.Error,'error '+objException.getStackTraceString());
System.debug(LoggingLevel.Error,'error '+objException.getMessage());
System.debug(LoggingLevel.Error,'response---'+objException);
System.debug(LoggingLevel.Error,'response-Line--'+objException.getLineNumber());
}
System.debug(LoggingLevel.Info,'response---'+responseWrap);
return responseWrap;  
}*/
    
    /*@AuraEnabled 
public static SIResponseWrapper sendSIDetails(String loanId) {
Loan_Application__c loanObj = [SELECT Branch_master1__r.Region_Code__c FROM Loan_Application__c WHERE Id = :loanId];
Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord(Label.Standard_Instruction_Service); 

Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
checklistRecord.Id = NULL;
String strResponse;
SIResponseWrapper responseWrap;
try{
SIRequestWrapper objRequest = new SIRequestWrapper();
objRequest.ReferenceNumber = IntegrationUtility.getReferenceId();
if(loanObj.Branch_master1__c!=null){
objRequest.TransactionBranch = Integer.valueOf(loanObj.Branch_master1__r.Region_Code__c); 
}
objRequest.RequestId = IntegrationUtility.getReferenceId();
objRequest.OriginatingChannel = objIntMaster.Channel__c;
objRequest.OperationMode = 'A';
objRequest.LoanAccountNumber = '9001250130360662';
objRequest.RemitterAccountNumber = '2301201144357127 ';
objRequest.ArrearTypeDetails = 'cpmin';
String strRequest = JSON.serialize(objRequest);

system.debug(LoggingLevel.DEBUG,'Request :: ' + strRequest);

IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
calloutRequestWrapper.request = strRequest;
calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
calloutRequestWrapper.masterRecord = objIntMaster;
calloutRequestWrapper.checklistRecord = checklistRecord;
IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
strResponse = calloutResponseWrapper.response;
system.debug(LoggingLevel.Info,'resp is >> ' + strResponse);
if(strResponse != null) {
strResponse = strResponse.replace('[[','[');
strResponse = strResponse.replace(']]',']');
responseWrap = (SIResponseWrapper) JSON.deserialize(strResponse, SIResponseWrapper.class);
System.debug('response '+responseWrap);
}
} catch(Exception objException) {
System.debug(LoggingLevel.Error,'error '+objException.getStackTraceString());
System.debug(LoggingLevel.Error,'error '+objException.getMessage());
System.debug(LoggingLevel.Error,'response---'+objException);
System.debug(LoggingLevel.Error,'response-Line--'+objException.getLineNumber());
}
System.debug(LoggingLevel.Info,'response---'+responseWrap);
return responseWrap;  
}*/
}