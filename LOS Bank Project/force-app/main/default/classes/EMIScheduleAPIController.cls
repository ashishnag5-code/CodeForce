public with sharing class EMIScheduleAPIController {
    public EMIScheduleAPIController() {

    }

    @AuraEnabled
    public static String callEMIScheduleAPI(Loan_Application__c loanApp, String callingComponent, Decimal netDisbursementAmount){
        String refId='';
        try{
            Map<String,Object> reqParam = new Map<String,Object>();
            Integration_Master__c objIntMapper;
            if(callingComponent == 'DisbursementOpsMaker'){
                objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Disbursement Schedule');
                reqParam.put('DisbursementScheduleChannel',objIntMapper.Channel__c);
            }else{
                objIntMapper = IntegrationUtility.getIntegrationMasterRecord('EMI Schedule');
                reqParam.put('EMIScheduleChannel',objIntMapper.Channel__c);
            }
            system.debug('objIntMapper==>'+objIntMapper);
            
            reqParam.put('TermMonths',loanApp.Tenure__c);
            reqParam.put('ProductCode',loanApp.Product__c);

            Generic_Master__c rateChartCode = [Select Rate_Chart_Code__c, CBS_Pricing__c from Generic_Master__c where 
            recordtype.DeveloperName='Rate_Chart_Code' and 
            Product__c=:loanApp.Product__c and Rate_Type__c=:loanApp.Type_of_Rate__c WITH SECURITY_ENFORCED];

            refId = IntegrationUtility.getReferenceId();
            reqParam.put('RefId',refId);
            reqParam.put('RateChartCode',rateChartCode.Rate_Chart_Code__c);
            reqParam.put('ScheduleTypeCode',loanApp.Schedule_Code__c);
            reqParam.put('AccountVarianceRate',loanApp.ROI__c-rateChartCode.CBS_Pricing__c);
            //reqParam.put('SanctionedAmount',loanApp.Loan_Amount__c);

            reqParam.put('TransactionBranch',String.valueOf(loanApp.Branch_Master__r.Account_Code__c));

            if(callingComponent == 'DisbursementOpsMaker'){
                reqParam.put('SessionId',Integer.valueOf(loanApp.Disbursement_Session_Id__c));
                //reqParam.put('SanctionedAmount',netDisbursementAmount);
                reqParam.put('SanctionedAmount',loanApp.Total_Loan_Amount__c);
            }else{
                reqParam.put('SanctionedAmount',loanApp.Total_Loan_Amount__c);
            }

            String requestBody= EMIScheduleAPIHandler.generateRequest(reqParam,objIntMapper,loanApp)[0];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=loanApp.Id, Request_Id__c=refId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            if(calloutResponseWrapper.statusCode!=200){
                return ('API Error: ' + calloutResponseWrapper.checklistNumber + ' Response: ' + calloutResponseWrapper.statusCode + '- ' + calloutResponseWrapper.status);
            }
            String respBody = calloutResponseWrapper.response;
            system.debug('respBody '+respBody);
            EMI_Schedule__c emiScheduleRecord;
            if(callingComponent == 'DisbursementOpsMaker'){
                respBody = respBody.replace('[ null ]',JSON.serialize(new List<EMIScheduleAPIHandler.ResponseWrapper>()));

                EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper repaymentScheduleResponse = 
                (EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper) JSON.deserialize(respBody, EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper.class);
                if(repaymentScheduleResponse.TransactionStatus!=null && repaymentScheduleResponse.TransactionStatus.ExtendedErrorDetails!=null && !repaymentScheduleResponse.TransactionStatus.ExtendedErrorDetails.messages.isEmpty() && (repaymentScheduleResponse.RepaymentRecords==null || repaymentScheduleResponse.RepaymentRecords.isEmpty())){
                    return ('API Error: ' + calloutResponseWrapper.checklistNumber + ' Response: ' + repaymentScheduleResponse.TransactionStatus.ExtendedErrorDetails.messages[0].message);
                }
                emiScheduleRecord = new EMI_Schedule__c();
                emiScheduleRecord.EMI_Response__c = JSON.serializePretty(repaymentScheduleResponse, false);
                emiScheduleRecord.Loan_Application__c = loanApp.Id;
                emiScheduleRecord.RecordTypeId = Schema.SObjectType.EMI_Schedule__c.getRecordTypeInfosByDeveloperName().get('Repayment_Schedule').getRecordTypeId();
            }else{
                respBody = respBody.replace('[ null ]',JSON.serialize(new List<EMIScheduleAPIHandler.ResponseWrapper>()));
                system.debug('respBody after replace '+respBody);
                EMIScheduleAPIHandler.EMIScheduleResponseWrapper emiScheduleResponse = 
                (EMIScheduleAPIHandler.EMIScheduleResponseWrapper) JSON.deserialize(respBody, EMIScheduleAPIHandler.EMIScheduleResponseWrapper.class);
                system.debug('emiScheduleResponse '+emiScheduleResponse);
                if(emiScheduleResponse.TransactionStatus!=null && emiScheduleResponse.TransactionStatus.ExtendedErrorDetails!=null && !emiScheduleResponse.TransactionStatus.ExtendedErrorDetails.messages.isEmpty() && emiScheduleResponse.Response.isEmpty()){
                    return ('API Error: ' + calloutResponseWrapper.checklistNumber + ' Response: ' + emiScheduleResponse.TransactionStatus.ExtendedErrorDetails.messages[0].message);
                }
                emiScheduleRecord = new EMI_Schedule__c();
                emiScheduleRecord.EMI_Response__c = JSON.serializePretty(emiScheduleResponse, false);
                emiScheduleRecord.Loan_Application__c = loanApp.Id;
                emiScheduleRecord.RecordTypeId = Schema.SObjectType.EMI_Schedule__c.getRecordTypeInfosByDeveloperName().get('Generated_EMI_Schedule').getRecordTypeId();
                
                if(emiScheduleResponse!=null && emiScheduleResponse.Response!=null && emiScheduleResponse.Response.size()>0 && emiScheduleResponse.Response[1].InstallmentAmount!=null){
                    Loan_Application__c loan = new Loan_Application__c();
                    loan.Id = loanApp.Id;
                    loan.EMI__c = emiScheduleResponse.Response[1].InstallmentAmount;
                    //String instDate = emiScheduleResponse.Response[0].InstallmentDate;
                    //loan.First_EMI_Date__c = Date.newInstance(Integer.valueOf(instDate.subString(0,4)),Integer.valueOf(instDate.subString(4,6)),Integer.valueOf(instDate.subString(6,8)));
                    update loan;
                }
            }
            
            if(emiScheduleRecord!=null && Schema.sObjectType.EMI_Schedule__c.isCreateable()){
                insert emiScheduleRecord;
            }

        }catch(Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),loanApp.Id);
        }
        
        return refId;
    }

    @AuraEnabled
    public static ContentVersion getPDFData(Loan_Application__c loanApp, String refId, String masterName){
        ContentVersion contentVerRecord;
        try {
            system.debug('loanApp '+loanApp);
            system.debug('refId '+refId);

            system.debug('masterName '+masterName);

            List<Integration_Checklist__c> icList = [SELECT Id, Loan_Application__c, Response__c 
            FROM Integration_Checklist__c WHERE Loan_Application__c=:loanApp.Id AND 
            Integration_Master__r.name=:masterName AND Request_Id__c=:refId WITH SECURITY_ENFORCED Order by CreatedDate Desc];
            system.debug('icList '+icList);
            if(icList!=null && icList.size()>0){
                Id checlistId = icList[0].Id;
                PageReference pdf = new pagereference('/apex/EMISchedule?id='+checlistId);
                //pdf.getParameters().put('id', checlistId);
                Blob body;
                try {
                    system.debug('Inside Try');
                    // returns page as a PDF
                    if(Test.isRunningTest()){
                        system.debug('Inside Test');
                        body = Blob.valueOf('Some Content');
                    }else{
                        system.debug('inside else ');
                        //body = pdf.getContentAsPDF();
                        body = pdf.getContent();
                        system.debug('blob '+body);
                    }
                    system.debug('after getContent '+body);
                    ContentVersion cv = new ContentVersion();
                    if(Schema.sObjectType.ContentVersion.isCreateable()){
                        system.debug('inside ContentVersion');
                        cv.VersionData = body;
                        cv.Title = masterName+'.pdf';
                        cv.PathOnClient = masterName+'.pdf';
                        cv.isActive__c=true;
                        cv.Loan_Application__c=loanApp.Name;
                        insert cv;
                    }
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id WITH SECURITY_ENFORCED].ContentDocumentId;
                        cdl.LinkedEntityId = loanApp.Id;
                        cdl.ShareType = 'I';
                        insert cdl; 
                    }
                    contentVerRecord = getLatestEmiSchedule(loanApp, masterName);
    
                } catch (Exception e) {
                    Log.error(e,Log.SeverityType.valueOf('High'),loanApp.Id);
                }
            }
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),loanApp.Id);
        }
        return contentVerRecord;
    }

    @AuraEnabled
    public static ContentVersion getLatestEmiSchedule(Loan_Application__c loanApp, String masterName){
        List<ContentVersion> contentVerRecords = new List<ContentVersion>();
        system.debug('loanApp '+loanApp.Name);
        system.debug('loanApp '+masterName);
        String title = masterName+'.pdf';
        contentVerRecords = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title=:title AND 
        Loan_Application__c=:loanApp.Name WITH SECURITY_ENFORCED Order By CreatedDate Desc];
        if(contentVerRecords!=null && contentVerRecords.size()>0){
            return contentVerRecords[0];
        }else{
            return new ContentVersion();
        }
    }

    @AuraEnabled
    public static String getRepaymentScheduleForAuthor(String loanId){
        List<Integration_Checklist__c> icList = [SELECT Id, Loan_Application__c, Response__c 
            FROM Integration_Checklist__c WHERE Loan_Application__c=:loanId AND 
            Integration_Master__r.name='Disbursement Schedule' WITH SECURITY_ENFORCED Order by CreatedDate Desc];
            system.debug('icList '+icList);
            return icList[0].Id;
    }
    
    @AuraEnabled
    public static String refetchEMI(String loanId){
        List<Loan_Application__c> icList = [SELECT Id, EMI__c from Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED Order by CreatedDate Desc];
            system.debug('icList '+icList);
            return String.valueOf(icList[0].EMI__c);
    }
}