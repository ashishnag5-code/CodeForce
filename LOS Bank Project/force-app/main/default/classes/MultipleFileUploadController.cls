public without sharing class MultipleFileUploadController {
    public class contentVersionType{
        @AuraEnabled public String fileName {get; set;}
        @AuraEnabled public String base64 {get;set;}
        @AuraEnabled public String size {get;set;}
        @AuraEnabled public Integer key {get;set;}     
    }
    
    class AverageSalary{
        @AuraEnabled public Decimal salaryAmount {get; set;}
        @AuraEnabled public String month {get; set;}
        @AuraEnabled public Decimal totalEMIAmount {get; set;}
        @AuraEnabled public String cartError {get; set;}
    }

    class CartError{
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String message {get; set;}
    }
    
    public MultipleFileUploadController() {
        
        
    }
    
    @AuraEnabled
    public static Document_Master__c getDocumentMaster(String strDocumentName){
        Document_Master__c objDocument = [Select Id,Name,Document_Name__c from Document_Master__c where Document_Name__c=:strDocumentName WITH SECURITY_ENFORCED LIMIT 1];
        return objDocument;
    }
    
    @AuraEnabled
    public static List<Document_Master__c> getApplicableDocumentMasters(String documentMaster){
        List<Document_Master__c> objDocuments;
        Document_Master_Name_vs_Code__mdt docMasterVsName = Document_Master_Name_vs_Code__mdt.getInstance(documentMaster);
        system.debug('docMasterVsName '+docMasterVsName);
        List<String> documentTypes = new List<String>(); 
        if(docMasterVsName!=null){
            if(docMasterVsName.Document_Code__c.contains(',')){
                documentTypes = docMasterVsName.Document_Code__c.split(',');
            }else{
                documentTypes.add(docMasterVsName.Document_Code__c);
            }
            try {
                objDocuments = [Select Id,Name,Document_Name__c from Document_Master__c where Name in :documentTypes WITH SECURITY_ENFORCED];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return objDocuments;
    }
    
    @AuraEnabled
    public static List<AverageSalary> calculateAverageSalary(Id recordId){
        List<AverageSalary> returnList=new List<AverageSalary>();
        try {
            List<Bank_Account_Records__c> bankRecord = [SELECT Analysis_Data__c, Cart_Request_Id__c from Bank_Account_Records__c where Applicant__c=:recordId 
                                                        and RecordType.Developername='Cart' order by createddate desc limit 1];
            Decimal totalMonthlySalary = 0;
            Integer count =0;
            
            returnList = new List<AverageSalary>();
            if(bankRecord!=null && bankRecord.size()>0 && bankRecord[0].Analysis_Data__c!=null){
                CART_FileUploadHandler.AnalysisData newList = CART_FileUploadHandler.parseAnalysisData(bankRecord[0].Analysis_Data__c);
                List<Integration_Checklist__c> icList = [SELECT Id, Callback_Request__c FROM Integration_Checklist__c WHERE Request_Id__c=:bankRecord[0].Cart_Request_Id__c AND Applicant__c=:recordId AND Integration_Master__r.Name='Cart Upload Service' ORDER By CreatedDate DESC Limit 1];
                if(icList!=null && icList.size()>0){
                    CartError errorResp = (CartError) JSON.deserialize(icList[0].Callback_Request__c,CartError.class);
                    if(errorResp!=null && errorResp.message!=null && errorResp.message!=''){
                        AverageSalary data = new AverageSalary();
                        data.cartError = 'Cart Callback Status : ';
                        if(errorResp!=null && errorResp.status!=null){
                            data.cartError = data.cartError + errorResp.status;
                        }
                        data.cartError = data.cartError + ' -> '+errorResp.message;
                        returnList.add(data);
                    }
                    
                    
                }
               // for(Integer i=0;i<newList.monthlyCreditsDetails.size(); i++){
                for(Integer i=newList.monthlyCreditsDetails.size()-1 ;i>=0; i--){
                    system.debug('i '+1);
                    AverageSalary data = new AverageSalary();
                    if(newList.monthlyCreditsDetails[i].SalaryCredit==null || newList.monthlyCreditsDetails[i].SalaryCredit==0){
                        data.salaryAmount = newList.monthlyBalancesDetailsGrandTotal!=null && newList.monthlyBalancesDetailsGrandTotal.AMB!=null?newList.monthlyBalancesDetailsGrandTotal.AMB:0;
                    }else{
                        data.salaryAmount = newList.monthlyCreditsDetails[i].SalaryCredit;
                    }
                    data.month = newList.monthlyCreditsDetails[i].MonthYear;
                    //data.totalEMIAmount = newList[i].totalEMIAmount;
                    system.debug('data '+data);
                    returnList.add(data);
                    count++;
                    if(count==3){
                        break;
                    }  
                }
            }else if(bankRecord!=null && bankRecord.size()>0 && bankRecord[0].Analysis_Data__c==null){
                List<Integration_Checklist__c> icList = [SELECT Id, Callback_Request__c from Integration_Checklist__c WHERE Applicant__c=:recordId AND Integration_Master__r.Name='Cart Upload Service' Order By CreatedDate desc LIMIT 1];
                if(icList!=null && icList.size()>0){
                    CartError errorResp = (CartError) JSON.deserialize(icList[0].Callback_Request__c,CartError.class);
                    AverageSalary data = new AverageSalary();
                    data.cartError = 'Cart Callback Status : '+(errorResp!=null?errorResp.status+' -> '+errorResp.message:'');
                    returnList.add(data);
                }
            }
            
            /*List<CART_FileUploadHandler.AnalysisData> newList = 
(List<CART_FileUploadHandler.AnalysisData>) JSON.deserialize(bankRecord.Analysis_Data__c, List<CART_FileUploadHandler.AnalysisData>.class);
system.debug('Obj '+newList);
system.debug('Obj '+newList.size());
for(Integer i=newList.size()-2; i>=0;i--){
system.debug('i '+1);
AverageSalary data = new AverageSalary();
data.salaryAmount = newList[i].salaryAmount;
data.month = newList[i].month;
data.totalEMIAmount = newList[i].totalEMIAmount;
system.debug('data '+data);
returnList.add(data);
count++;
if(count==3){
break;
}  
}*/
            system.debug('returnList '+returnList);
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnList;
    }
    
    @AuraEnabled
    public static String cartCalloutOnSubmitMobile(Id recordId, String password, Decimal amount, String checklistRecordId) {
        List<Document_Checklist__c> lstdoc = [SELECT Id, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE Id =:checklistRecordId WITH SECURITY_ENFORCED limit 1];
        system.debug('%%% '+lstdoc[0].Document_Master__r.Document_Name__c);
        List<ContentDocumentLink> conLink = [SELECT Id,ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId =:checklistRecordId WITH SECURITY_ENFORCED 
                                             Order By  ContentDocument.CreatedDate DESC LIMIT 1];
        List<ContentVersion> contentVersions = [SELECT Id,Title,VersionData from ContentVersion WHERE ContentDocumentId =: conLink[0].ContentDocumentId LIMIT 1]; 
        String cartResponse = cartCalloutOnSubmit(null,recordId,password,lstdoc[0].Document_Master__r.Document_Name__c,amount,contentVersions[0].Id);
        return cartResponse;
    }
    
    @AuraEnabled
    public static String cartCalloutOnSubmit(contentVersionType cvObject, Id recordId, String password, String documentType, Decimal amount, String contentVersionId) {
        String respBody;
        String requestBody;
        String returnValue;
        try{
            if((cvObject != null && !String.isEmpty(cvObject.base64)) || !String.isEmpty(contentVersionId)){
                
                
                if(documentType == 'Bank Statement'){
                    system.debug('Inside if '+documentType);
                    system.debug('cvObject '+cvObject);
                    system.debug('recordId '+recordId);
                    system.debug('password '+password);
                    system.debug('contentVersionId '+contentVersionId);
                    system.debug('documentType '+documentType);
                    ContentVersion conRecord;
                    if(!String.isBlank(contentVersionId)){
                        conRecord = [SELECT Id,VersionData,ContentSize,ContentDocumentId,Title FROM ContentVersion WHERE Id=: contentVersionId WITH SECURITY_ENFORCED LIMIT 1];
                    }
                    //Integration_Master__c intMaster = [SELECT Id, Name from Integration_Master__c WHERE Name = 'Cart Callback'];
                    
                    Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Cart Upload Service');
                    Map<String,Object> reqParam = new Map<String,Object>();
                    
                    if(conRecord != null && conRecord.VersionData != null){
                        String fileName = String.isNotBlank(conRecord.Title) ? conRecord.Title.replaceAll(' ','') : '';
                        reqParam.put('filename',fileName);
                        reqParam.put('base64',EncodingUtil.base64Encode(conRecord.VersionData));
                    }
                    else{
                        String fileName = String.isNotBlank(cvObject.fileName) ? cvObject.fileName.replaceAll(' ','') : '';
                        reqParam.put('filename',fileName);
                        reqParam.put('base64',cvObject.base64);
                    }
                    reqParam.put('password',password);
                    requestBody = CART_FileUploadHandler.generateRequest(reqParam)[0];
                    system.debug('%%'+requestBody);
                    
                    CART_FileUploadHandler.CARTDetailsRequestWrapper cartDetailsRequest = 
                        (CART_FileUploadHandler.CARTDetailsRequestWrapper) JSON.deserialize(requestBody, CART_FileUploadHandler.CARTDetailsRequestWrapper.class);
                    Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
                    checklistRecord.Request_Id__c = cartDetailsRequest.RequestId;
                    String objectId = '';
                    IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                    calloutRequestWrapper.request = requestBody;
                    calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                    calloutRequestWrapper.masterRecord = objIntMapper;
                    calloutRequestWrapper.checklistRecord = checklistRecord;
                    calloutRequestWrapper.captureRequestInAttachment = true;
                    IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
                    respBody = calloutResponseWrapper.response;
                    system.debug(respBody);
                    CART_FileUploadHandler.CARTDetailsResponseWrapper cartDetailsResponse = 
                        (CART_FileUploadHandler.CARTDetailsResponseWrapper) JSON.deserialize(respBody, CART_FileUploadHandler.CARTDetailsResponseWrapper.class);
                    
                    List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Document_Number__c, Document_Master__c,
                                                                       Document_Master__r.Document_Name__c, Applicant__c, Applicant__r.Loan__c,
                                                                       Applicant__r.RecordTypeId, Applicant__r.RecordType.DeveloperName
                                                                       FROM Document_Checklist__c WHERE 
                                                                       Applicant__c=:recordId AND
                                                                       Document_Master__r.Document_Name__c=:documentType
                                                                       ORDER BY CreatedDate DESC LIMIT 1];
                    system.debug('Document Checklist Records '+docCheckListRecords);
                    if(docCheckListRecords!=null && docCheckListRecords.size()>0 && cartDetailsResponse.status=='Submitted'){
                        /*Integration_Checklist__c checklistRecordForCartCallback = new Integration_Checklist__c(Applicant__c = docCheckListRecords[0].Applicant__c, 
Integration_Master__c=intMaster.Id, 
Request_Id__c=cartDetailsRequest.RequestId);

insert checklistRecordForCartCallback;*/
                        
                        docCheckListRecords[0].Document_Number__c = cartDetailsResponse.docId;
                        docCheckListRecords[0].Status__c = 'Received';
                        update docCheckListRecords[0];
                        //uploadFile(cvObject, docCheckListRecords[0].Id);
                        
                        returnValue = cartDetailsResponse.status;
                    }
                    else{
                        returnValue = cartDetailsResponse.status+';;;'+cartDetailsResponse.message;
                    }
                    system.debug(docCheckListRecords[0]);
                    
                }
                else{
                    system.debug('Inside else '+documentType);
                    List<Document_Checklist__c> docCheckListRecords = [SELECT Id, Document_Number__c, Document_Master__c,
                                                                       Document_Master__r.Document_Name__c, Applicant__c, Applicant__r.Loan__c,
                                                                       Applicant__r.RecordTypeId, Applicant__r.RecordType.DeveloperName
                                                                       FROM Document_Checklist__c WHERE 
                                                                       Applicant__c=:recordId AND
                                                                       Document_Master__r.Document_Name__c=:documentType
                                                                       ORDER BY CreatedDate DESC LIMIT 1];
                    //uploadFile(cvObject, docCheckListRecords[0].Id);
                    docCheckListRecords[0].Amount__c = amount;
                    docCheckListRecords[0].Status__c = 'Received';
                    update docCheckListRecords[0];
                    returnValue = 'Submitted';
                    //ITR Part 
                    if(documentType == 'ITR Statement'){
                        
                        ContentVersion conRecord;
                        if(!String.isBlank(contentVersionId)){
                            conRecord = [SELECT Id,VersionData,ContentSize,ContentDocumentId,Title FROM ContentVersion WHERE Id=: contentVersionId WITH SECURITY_ENFORCED LIMIT 1];
                        }
                        
                        Map<String,Object> reqParam = new Map<String,Object>();
                        
                        if(conRecord != null && conRecord.VersionData != null){
                            String fileName = String.isNotBlank(conRecord.Title) ? conRecord.Title.replaceAll(' ','') : '';
                            reqParam.put('filename',fileName);
                            reqParam.put('base64',EncodingUtil.base64Encode(conRecord.VersionData));
                        }
                        else{
                            String fileName = String.isNotBlank(cvObject.fileName) ? cvObject.fileName.replaceAll(' ','') : '';
                            reqParam.put('filename',fileName);
                            reqParam.put('base64',cvObject.base64);
                        }
                        reqParam.put('password',password);
                        requestBody = KarzaITRController.generateRequest(reqParam)[0];
                        //Call the ITR Future Callout
                        ITRCallout(requestBody,recordId);
                        
                    }
                    
                    //END
                    
                    
                }
            }
            
        }
        catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            
        }
        return returnValue;
    }
    
    @future(callout=true)
    public static void ITRCallout(String requestBody,String recordId){
        System.debug('requestBody-->' +requestBody);
        String respBody;
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza ITR Service');
        KarzaITRController.ITRDetailsRequestWrapper itrDetailsRequest = 
            (KarzaITRController.ITRDetailsRequestWrapper) JSON.deserialize(requestBody, KarzaITRController.ITRDetailsRequestWrapper.class);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
        checklistRecord.Request_Id__c = itrDetailsRequest.RequestId;
        String objectId = '';
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        calloutRequestWrapper.captureRequestInAttachment = true;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-->' +respBody);
        if(String.isNotBlank(respBody)){
            Map<string,Object> result = (Map<String, Object>) JSON.deserializeUntyped(respBody);
            Map<string,Object> resultMap = ( Map<string,Object> ) result.get('result');
            if(resultMap!=null){
                String assessmentYear = (String) resultMap.get('Assessment Year');
                Map<String,Object> totalMap =(Map<String,Object>) resultMap.get('Taxable Income details');
                Decimal totalIncome = totalMap.get('Total Income')!=null ?(Decimal)totalMap.get('Total Income') :0;
                System.debug('totalIncome-->' +totalIncome);
                if(totalIncome!=0){
                     List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Monthly_Total_Income__c, Monthly_Income__c, First_Month__c, Second_Month__c, Third_Month__c,Annual_Net_Profit__c,Year__c,Filing_Date__c,Annual_Total_Income__c,Annual_Turnover__c,Annual_Expense__c,Monthly_Expense__c,Salary_Received_in_Cash__c,Monthly_Net_Salary__c,Company_Master__c,Company_Name__c, Total_Work_Experience__c,
                                                                             RecordType.Name, RecordType.DeveloperName
                                                                             FROM Applicant_Financials_Details__c 
                                                                             WHERE (RecordType.DeveloperName ='Documented_With_Audited_financial' OR RecordType.DeveloperName ='Documented_Without_Audited_financial')
                                                                             AND Applicant__c =:recordId
                                                                             AND isActive__c = true];
                
                List<Applicant_Financials_Details__c>  financeUpdateList = new List<Applicant_Financials_Details__c> ();
                for(Applicant_Financials_Details__c applicantFinance : applicantFinancials){
                    Applicant_Financials_Details__c finance = new Applicant_Financials_Details__c();
                    finance.Id= applicantFinance.id;
                    finance.Year__c = assessmentYear;
                    if(applicantFinance.RecordType.DeveloperName =='Documented_With_Audited_financial'){
                        finance.Annual_Total_Income__c = totalIncome;
                    }else if(applicantFinance.RecordType.DeveloperName =='Documented_Without_Audited_financial') {
                        finance.Annual_Net_Profit__c = totalIncome; 
                    }
                    
                    
                    financeUpdateList.add(finance);
                    System.debug('financeUpdateList-->' +financeUpdateList);
                    
                    
                }
                if(financeUpdateList!=null && financeUpdateList.size()>0){
                    update financeUpdateList;
                } 
              }
               
            }
            //List<Map<String, String>> newList = (List<Map<String, String>>) JSON.deserialize(JSON.serialize(transactionStatus), List<Map<String, String>>.class);
        }
        
    }
    
    public static void updateBankAccountStatementDetails(List < Integration_Checklist__c > newRecordList, Map < Id, Integration_Checklist__c > oldRecordMap, Map < Id, Integration_Checklist__c > newRecordMap) {
        
        try {
            if ((newRecordList[0].Integration_Master_Name__c == 'Cart Upload Service' || newRecordList[0].Integration_Master_Name__c == 'Cart Statement Service' ) && String.isNotBlank(newRecordList[0].Callback_Request__c)) {
                String addressData;
                String accountHolderNameForMatch;
                System.debug('newRecordList-->' + newRecordList[0].Callback_Request__c);
                String callBackJSON = newRecordList[0].Callback_Request__c;
                //String replacedString = callBackJSON.replaceAll('\"','');
                String formattedString = callBackJSON.replace('\\', '');
                System.debug('String-->' + formattedString);
                //String trimmedString = formattedString.substring(1, formattedString.length() - 1);
                //System.debug('trimmedString-->' + trimmedString);
                
                Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
                Map < String, Object > jsonData = (Map < String, Object > ) JSON.deserializeUntyped(formattedString);
                String responseStatus;
                responseStatus = (String) jsonData.get('status');
                //List<String> addressData = (List <String>) data.get('address');
                
                if(responseStatus == 'Processed'){
                    List < Object > data = (List < Object > ) jsonData.get('data');
                    List < Bank_Account_Records__c > bankAccountList = new List < Bank_Account_Records__c > ();
                    
                    /*   List<object> monthlyBalancesDetailsList =  new List<object>();
List<object> monthlyBalancesDetailsGrandTotalList =  new List<object>();
List<object> monthlyCreditsDetailsList =  new List<object>();
List<object> monthlyBalancesDetailsList =  new List<object>();*/
                    List<Bank_Account_Records__c> CASA_cartExistingRecords;
                    //SFAU-5278 start
                    if(newRecordList[0].Integration_Master_Name__c == 'Cart Statement Service'){
                        String applicantIdvalue = (newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : '';
                        CASA_cartExistingRecords = [SELECT Id, Account_Number__c FROM Bank_Account_Records__c WHERE RecordTypeId=:cartRecordTypeId AND Applicant__c=:applicantIdvalue AND Applicant__r.Cart_Statement_Service_Done__c=true ORDER By CreatedDate Desc];
                    }
                    //SFAU-5278 end
                    for (Object dataInstance: data) {
                        system.debug('dataInstance '+dataInstance);
                        addressData = (String)((Map < String, Object > ) dataInstance).get('address');
                        system.debug('addressData '+addressData);
                        
                        //Make it to multiple 
                        Map < String, Object > bsaCreditData = (Map < String, Object > )((Map < String, Object > ) dataInstance).get('bsaCreditData');
                        System.debug('bsaCreditData-->' + bsaCreditData);
                        
                        Map < String, Object > responseData = (Map <String,Object>) dataInstance;
                        Bank_Account_Records__c bankInstance = new Bank_Account_Records__c();
                        bankInstance.Account_Name__c = (String) bsaCreditData.get('accountHolderName');
                        accountHolderNameForMatch = bankInstance.Account_Name__c;
                        bankInstance.Account_Number__c = (String) bsaCreditData.get('accountNumber');
                        bankInstance.IFSC_Code__c = (String) bsaCreditData.get('ifsc');
                        bankInstance.Bank_Name__c = (String) bsaCreditData.get('bankName');
                        bankInstance.Branch_Name__c = (String) bsaCreditData.get('branchName');
                        bankInstance.Account_Type__c = (String) bsaCreditData.get('accountType');
                        //bankInstance.Fraud_Score__c = (String)responseData.get('fraudScore');
                        bankInstance.ODCC_Limit__c = (String)responseData.get('odCcLimit');
                        String stDate = (String) bsaCreditData.get('startDate');
                        String stDdDate = (String) bsaCreditData.get('endDate');
                        String[] dateArrray = stDate.split('/');
                        String[] dateArrray1 = stDdDate.split('/');
                        //String stFormated = dateArrray[1] + '/' +dateArrray[0] + '/' +dateArrray[2];
                        String stFormated = dateArrray[2] + '-' + dateArrray[1] + '-' + dateArrray[0];
                        String edFormated = dateArrray1[2] + '-' +dateArrray1[1]  + '-' + dateArrray1[0];
                        bankInstance.Statement_Start_Date__c =  Date.valueOf(stFormated);
                        bankInstance.Statement_End_Date__c =  Date.valueOf(edFormated);
                        
                        bankInstance.Total_Credit__c = (Decimal) bsaCreditData.get('totalCreditCount');
                        bankInstance.Total_Debit__c = (Decimal) bsaCreditData.get('totalDebitCount');
                        bankInstance.Average_Monthly_Balance__c = (Decimal) bsaCreditData.get('avgMonthlyBalance');
                        bankInstance.Average_Monthly_Credit__c = (Decimal) bsaCreditData.get('avgMonthlyCredits');
                        Decimal stInwards = (Decimal) bsaCreditData.get('inwardChequeBounce');
                        Decimal stOutwards = (Decimal) bsaCreditData.get('outwardChequeBounce');
                        bankInstance.Inward_Cheque_Bounce__c = String.valueOf(stInwards);
                        bankInstance.Outward_Cheque_Bounce__c = String.valueOf(stOutwards);
                        bankInstance.No_of_Emi_Paid__c = (Decimal) bsaCreditData.get('totalEMICount');
                        bankInstance.EMI_Amount__c = (Decimal) bsaCreditData.get('totalEMIAmount');
                        bankInstance.Total_Salary__c = (Decimal) bsaCreditData.get('totalSalaryAmount');
                        bankInstance.Cart_Request_Id__c = (newRecordList[0].Request_Id__c != null) ? newRecordList[0].Request_Id__c : '';
                        bankInstance.RecordTypeId = cartRecordTypeId;
                        bankInstance.Applicant__c = (newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : '';
                        bankInstance.Manual_Check__c = false;
                        //SFAU-5278 start
                        if(newRecordList[0].Integration_Master_Name__c == 'Cart Statement Service' && CASA_cartExistingRecords!=null && CASA_cartExistingRecords.size()>0){
                            for(Bank_Account_Records__c bankrec: CASA_cartExistingRecords){
                                if(bankInstance.Account_Number__c == bankrec.Account_Number__c){
                                    bankInstance.Id = bankrec.Id;
                                }
                            }
                            
                        }
                        //SFAU-5278 end
                        Map < String, Object > jsonMap = new Map < String, Object > ();
                        
                        
                        List<Object> monthlyBalanceList =(List<object>) bsaCreditData.get('monthlyBalancesDetails');
                        List<Object> monthlyCreditList = ( List<Object>) bsaCreditData.get('monthlyCreditsDetails');
                        System.debug('monthlyBalanceList-->' +monthlyBalanceList);
                        System.debug('monthlyCreditList-->' +monthlyCreditList);
                        
                        Map < String, Object > monthlyBalancesDetails = new  Map < String, Object >();
                        Map < String, Object > monthlyCreditsDetails = new  Map < String, Object >();
                        /* for( Object objInstance : monthlyBalanceList){
Map<String,Object> mapInstance =  (Map < String, Object > ) objInstance;
monthlyBalancesDetails.putAll(mapInstance);
}
for( Object objInstance : monthlyCreditList){
Map<String,Object> mapInstance =  (Map < String, Object > ) objInstance;
monthlyCreditsDetails.putAll(mapInstance);
}*/
                        
                        System.debug('monthlyBalancesDetails-->' +monthlyBalancesDetails);
                        System.debug('monthlyCreditsDetails-->' +monthlyCreditsDetails);
                        
                        // Map < String, Object > monthlyBalancesDetails = (Map < String, Object > ) bsaCreditData.get('monthlyBalancesDetails');
                        Map < String, Object > monthlyBalancesDetailsGrandTotal = (Map < String, Object > ) bsaCreditData.get('monthlyBalancesDetailsGrandTotal');
                        // Map < String, Object > monthlyCreditsDetails = (Map < String, Object > ) bsaCreditData.get('monthlyCreditsDetails');
                        Map < String, Object > monthlyCreditsDetailsGrandTotal = (Map < String, Object > ) bsaCreditData.get('monthlyCreditsDetailsGrandTotal');
                        
                        
                        // Remove Grand Total Node
                        // monthlyBalancesDetails.remove('Grand Total');
                        // monthlyCreditsDetails.remove('Grand Total');
                        
                        //jsonMap.put('monthlyBalancesDetails', monthlyBalancesDetails);
                        // jsonMap.put('monthlyCreditsDetails', monthlyCreditsDetails);
                        jsonMap.put('monthlyBalancesDetails', monthlyBalanceList);
                        jsonMap.put('monthlyCreditsDetails', monthlyCreditList);
                        jsonMap.put('monthlyBalancesDetailsGrandTotal', monthlyBalancesDetailsGrandTotal);
                        jsonMap.put('monthlyCreditsDetailsGrandTotal', monthlyCreditsDetailsGrandTotal);
                        
                        String jsonStr = JSON.serialize(jsonMap);
                        
                        bankInstance.Analysis_Data__c = jsonStr;
                        bankAccountList.add(bankInstance);
                        
                        
                        
                    }
                    System.debug('bankAccountList-->' +bankAccountList);
                    if (Schema.sObjectType.Bank_Account_Records__c.isCreateable()) {
                        //insert bankAccountList;
                        upsert bankAccountList;//SFAU-5278 used upsert instead of insert
                    }
                    System.debug('bankInstance-->' + bankAccountList[0].Id);
                    CARTAddressMatchCalloutQueueable newQueuableClass1 = new CARTAddressMatchCalloutQueueable(((newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : ''),addressData, 'Address Split',accountHolderNameForMatch);
                    Id jobId1 = System.enqueueJob(newQueuableClass1);
                     //BRE Part || START
                    if(String.isNotBlank(newRecordList[0].Applicant__c)){
                        Applicant__c applicantInstance = [SELECT id,Loan__c FROM Applicant__c WHERE id=:newRecordList[0].Applicant__c];
                        String loanId= applicantInstance.Loan__c;
                        List<Deviation__c> deviationRecord = [SELECT id,name,Source__c,Archived__c,Deviation_Type__c,Loan_Application__c FROM Deviation__c WHERE Loan_Application__c=:loanId AND  Source__c='BRE' AND Archived__c =false AND Deviation_Type__c ='FOIR NORM'];
                        if(deviationRecord!=null){
                            if(deviationRecord.size()>0 && !deviationRecord.isEmpty()){
                                 //BRE Run
                                List<String> fieldList =  new List<String>();
                                fieldList.add('FOIR_Percentage__c');
                                Utility.checkMaterialFields('Financial Details',loanId,fieldList);
                            }
                        }
                    }
                    // END
                }else if(responseStatus=='Rejected'){
                    Bank_Account_Records__c bankInstance = new Bank_Account_Records__c();
                    bankInstance.RecordTypeId = cartRecordTypeId;
                    bankInstance.Applicant__c = (newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : '';
                    insert bankInstance;
                }
                
                /*CARTAddressMatchCalloutQueueable newQueuableClass2 = new CARTAddressMatchCalloutQueueable(((newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : ''),addressData, 'Address Match');
Id jobId2 = System.enqueueJob(newQueuableClass2);*/
                
                //triggerAddressSplitAPI(addressData, (newRecordList[0].Applicant__c != null) ? newRecordList[0].Applicant__c : '');
            }
        } catch (Exception e) {
            System.debug('exception-->' + e);
            System.debug('exception-->' + e.getLineNumber());
            Log.error(e, Log.SeverityType.valueOf('High'), '');
        }
    }
    
    /*public static void triggerAddressSplitAPI(String address, String recordId){
        CARTAddressMatchCalloutQueueable newQueuableClass1 = new CARTAddressMatchCalloutQueueable(recordId, address, 'Address Split');
        Id jobId1 = System.enqueueJob(newQueuableClass1);
        
        Address__c cartAddress = LOSAddressSplitController.callAddressSplitApi(address, recordId);
system.debug('Address__c address '+cartAddress);
LOSKarzaAddressMatchController.addressMatchForCART(JSON.serialize(cartAddress), recordId);
    }*/
    
    public static void futureCalloutForSplit(String address, String recordId, String accHolderName){
        Address__c newAddress = LOSAddressSplitController.callAddressSplitApi(address, recordId);
        newAddress.Source_Type__c = 'Cart';
        newAddress.Applicant__c = recordId;
        newAddress.Address_Type__c = 'Current';
        insert newAddress;   
        CARTAddressMatchCalloutQueueable newQueuableClass2 = new CARTAddressMatchCalloutQueueable(recordId, JSON.serialize(newAddress), 'Address Match',accHolderName);
        if(!Test.isRunningTest())
        Id jobId2 = System.enqueueJob(newQueuableClass2);
    }

    public static void callNameMatchForCart(String address, String recordId, String accHolderName){
        CARTAddressMatchCalloutQueueable newQueuableClass3 = new CARTAddressMatchCalloutQueueable(recordId, '', 'Name Match',accHolderName);
             if(!Test.isRunningTest())
        Id jobId3 = System.enqueueJob(newQueuableClass3);
    }
    
    
    public static void handleCartCallBackResponse(Map<Id, ContentVersion> contentVersionMap){
        
        Map<Id, Integration_Checklist__c> newICMap = new Map<Id, Integration_Checklist__c>();
        Map<String, ContentVersion> newRequestIdVSCVMap = new Map<String, ContentVersion>();
        List<Bank_Account_Records__c> bankrecordsToInsert = new List<Bank_Account_Records__c>();
        Map<Id, ContentDocumentLink> mapIdVScdl = new Map<Id, ContentDocumentLink>();
        List<ContentVersion> cvList = [select Id, Request_id__c,Title, VersionData, ContentDocumentId from ContentVersion where id in :contentVersionMap.keySet()];
        
        
        for(ContentVersion cv: cvList){
            if(cv.Request_id__c!=null && cv.Request_id__c!=''){
                newRequestIdVSCVMap.put(cv.Request_id__c, cv);
                
            }    
        }
        
        system.debug('newRequestIdVSCVMap'+newRequestIdVSCVMap.keySet());
        
        
        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
        List<Integration_Checklist__c> intCheckList = [SELECT Id, Request_Id__c, Applicant__c, Integration_Master__c, Integration_Master__r.name FROM Integration_Checklist__c WHERE  Request_Id__c in :newRequestIdVSCVMap.keySet() and Integration_Master__r.Name='Cart Upload Service' order by createddate desc];
        
        List<Bank_Account_Records__c> bankAccountRecordList  = [SELECT id,Name, Cart_Request_Id__c 
                                                                FROM Bank_Account_Records__c
                                                                WHERE Cart_Request_Id__c IN :newRequestIdVSCVMap.keySet()];
        system.debug('intCheckList '+intCheckList);                                                       
        system.debug('intCheckList '+intCheckList.size());
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdBanklList = new List<ContentDocumentLink>();
        Set<Id> contentDocIDs = new set<ID>();
        for(Integration_Checklist__c ic: intCheckList){
            if(newRequestIdVSCVMap.keySet().contains(ic.Request_Id__c)){
                ContentVersion cvRecord = newRequestIdVSCVMap.get(ic.Request_Id__c);
                ContentDocumentLink cdlRecord = new ContentDocumentLink();
                cdlRecord.ContentDocumentId = cvRecord.ContentDocumentId;
                cdlRecord.LinkedEntityId = ic.Id;
                contentDocIDs.add(cvRecord.ContentDocumentId);
                cdlList.add(cdlRecord);
                //Create a link between bank account record 
                /* Blob mydata = cvRecord.VersionData;
String newString = mydata.toString();
system.debug('newString '+newString);
CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper objWrapper = 
(CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper) 
JSON.deserialize(newString, CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper.class);
system.debug('Obj '+objWrapper);*/
                //Bank_Account_Records__c record = stampDataForBankAccountRecord(objWrapper,ic.Applicant__c, cartRecordTypeId);
                // bankrecordsToInsert.add(record);
            }
        }
        insert cdlList;
        
        //to update the title with extension
        List<ContentDocument> cd = [SELECT Id, Title FROM ContentDocument WHERE Id IN : contentDocIDs];
        List<ContentDocument> cdUpdateList = new  List<ContentDocument>();
        for(ContentDocument cdInstance : cd){
            cdInstance.Title = cdInstance.Title +'.xlsx';
            cdUpdateList.add(cdInstance);
        }
        if (!cdUpdateList.isEmpty()) {
            update cdUpdateList;
        }
        
        //Linking Bank Account Records to Content Document
        for(Bank_Account_Records__c recordInstance : bankAccountRecordList){
            if(newRequestIdVSCVMap.keySet().contains(recordInstance.Cart_Request_Id__c)){
                ContentVersion cvRecord = newRequestIdVSCVMap.get(recordInstance.Cart_Request_Id__c);
                ContentDocumentLink cdlRecord = new ContentDocumentLink();
                cdlRecord.ContentDocumentId = cvRecord.ContentDocumentId;
                cdlRecord.LinkedEntityId = recordInstance.Id;
                cdBanklList.add(cdlRecord);
                
                /*Blob mydata = cvRecord.VersionData;
String newString = mydata.toString();
system.debug('newString '+newString);
CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper objWrapper = 
(CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper) 
JSON.deserialize(newString, CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper.class);
system.debug('Obj '+objWrapper);*/
            }
        }
        
        if(!cdBanklList.isEmpty()){
            if(!Test.isRunningTest()){
                insert cdBanklList;
            }
            
        }
        //insert bankrecordsToInsert;
        
    }
    
    /*  public static Bank_Account_Records__c stampDataForBankAccountRecord(CART_FileUploadHandler.CARTBankStatementDetailsResponseWrapper wrapper, Id applicantId, Id cartRecordTypeId){

Bank_Account_Records__c bankAcc= new Bank_Account_Records__c();
bankAcc.RecordTypeId = cartRecordTypeId;
bankAcc.Applicant__c = applicantId;

//bankAcc.Cart_Request_Id__c = wrapper.request_id;
bankAcc.Document_Id__c = wrapper.docId;
bankAcc.Status__c = wrapper.status;
bankAcc.Bank_Name__c = wrapper.data[0].bankName;
bankAcc.Account_Number__c = wrapper.data[0].accountNumber;
//bankAcc.Account_Type__c = wrapper.data.data[0].accountName;
bankAcc.Account_Name__c = wrapper.data[0].accountName;
bankAcc.Statement_End_Date__c = Date.parse(wrapper.data[0].periodEnd);
bankAcc.Statement_Start_Date__c = Date.parse(wrapper.data[0].periodStart);
bankAcc.Average_Balance__c = wrapper.data[0].camAnalysisData.averageBalance;
bankAcc.Average_Balance_Last_12_Month__c = wrapper.data[0].camAnalysisData.averageBalanceLastSixMonths;
bankAcc.Average_Balance_Last_6_Month__c = wrapper.data[0].camAnalysisData.averageBalanceLastTwelveMonths;
bankAcc.Analysis_Data__c = JSON.serialize(wrapper.data[0].analysisData);
system.debug('bankAcc.Analysis_Data__c '+bankAcc.Analysis_Data__c);
return bankAcc; 

}*/
    
    public static ContentDocumentLink uploadFile(contentVersionType cvObject, Id recordId){
        try {
            system.debug(cvObject);
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(cvObject.base64);
            cv.Title = cvObject.fileName;
            cv.PathOnClient = cvObject.fileName;
            cv = createSingleContentVersion(cv);
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            insert cdl;
            return cdl;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static ContentVersion createSingleContentVersion(ContentVersion cvInsertObject){
        try {
            
            insert cvInsertObject;
            return cvInsertObject;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*@AuraEnabled
public static List<ContentDocumentLink> uploadFiles(List<contentVersionType> cvList, Id recordId){
try {
List<ContentVersion> cvInsertList = new List<ContentVersion>();
for(contentVersionType cvType: cvList){
system.debug('cvType ' +cvType);
ContentVersion cv = new ContentVersion();
cv.VersionData = EncodingUtil.base64Decode(cvType.base64);

cv.Title = cvType.fileName;
cv.PathOnClient = cvType.fileName;
cvInsertList.add(cv);
system.debug('cv '+cv);

}
List<ContentVersion> newCVList = createContentVersion(cvInsertList);
List<Id> cvIds = new List<Id>();
for(ContentVersion cvType: newCVList){
cvIds.add(cvType.Id);
}

List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
newCVList = [select ContentDocumentId from ContentVersion where 
id in :cvIds];

for(ContentVersion cvType: newCVList){
ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = cvType.ContentDocumentId;
cdl.LinkedEntityId = recordId;
cdlList.add(cdl);

}

insert cdlList;
return cdlList;


} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}
}
@AuraEnabled
public static List<ContentVersion> createContentVersion(List<ContentVersion> cvInsertList){
try {

insert cvInsertList;
return cvInsertList;

} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}
}*/
    
    
    
}