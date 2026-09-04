public with sharing class CibilNIController {
    

    @AuraEnabled
    public static List<Applicant__c> getApplicants(String loanId){
        try {
            Set<Id> alreadyCibilNIExecutedSet = New Set<Id>();
            List<Applicant__c> appList = New List<Applicant__c>();
            Map<id,Applicant__c> appMap = New Map<id, Applicant__c>([Select id,Customer_Type__c, Entity_Name__c
            from Applicant__c 
            where Loan__c =: loanId and Customer_Type__c = 'Non Individual']);

            if(appMap.size()==0){
                return appList;
            }
            
            for(Integration_Checklist__c ic: [Select createdDate, Status__c,Applicant__c from Integration_Checklist__c 
                where Applicant__c in: appMap.keySet() and Integration_Master__r.Name ='CIBIL NI' 
                and Status__c = 'Completed' order by createddate desc limit 1]){
                if(((Date.valueOf(ic.createdDate)).daysBetween(system.today())) <= 30){
                    alreadyCibilNIExecutedSet.add(ic.Applicant__c);
                }
            }
            
            for(id appId: appMap.keySet()){
                if(!alreadyCibilNIExecutedSet.contains(appId)){
                    appList.add(appMap.get(appId));
                }
            }
            return appList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String cibilNIRequest(String appId){
        String requestBody;
        String respBody;
        Applicant__c appObj = new Applicant__c();
        try{
            if(appId != null){
                appObj = [select id, PAN__c, CIN__c,Total_Loan_Amount__c,Date_of_Establishment__c, Constitution_Type__c,
                Loan__r.Product__c,Entity_Name__c,
                (select id, Address_Line_1__c,Address_Line_2__c,Address_Line_3__c ,Pincode__c, Address_Type__c,City__c,
                State__c,Office_Number__c from addresses__r where Address_Type__c = 'Office')  from Applicant__c  
                where customer_Type__c = 'Non Individual' and Id =: appId WITH SECURITY_ENFORCED];
            }
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CIBIL NI');
            Map<String,Object> reqParam = new Map<String,Object>();
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = appId, 
                Integration_Master__c = objIntMapper.Id);
            String errorMsg = CibilNIHandler.validateData(appObj);
            if(errorMsg<>''){
                checklistRecord.Missing_Pre_requisites__c = errorMsg;
                checklistRecord.Request_Initiated_At__c = system.now();
                checklistRecord.Response_Received_At__c = system.now();
                checklistRecord.Status__c = 'Missing Pre-requisites';
                insert checklistRecord;
                return errorMsg;
            }else{
                requestBody = CibilNIHandler.generatereq(appObj);
                system.debug('+++'+requestBody);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                //calloutRequestWrapper.request ='{"Fields":{"Field":{"Applicants":{"Applicant":{"Addresses":{"Address":{"AddressLine1":"","AddressLine2":"","AddressLine3":"","AddressLine4":"","AddressLine5":"","AddressType":"","City":"","PinCode":"","ResidenceType":"","StateCode":""}},"ApplicantFirstName":"","ApplicantLastName":"","ApplicantMiddleName":"","ApplicantType":"Company","CIN":"","ClassOfActivity":"GROWING OF CEREALS","CompanyName":"AIRTEL INTERNATIONAL LLP","ConsumerBureauCheck":"","CRN":"","DateOfBirth":"","DateOfRegistration":"08-Mar-2005","DIN":"","FacilityCategory":"Overdraft","FacilityType":"NEW LOAN","Gender":"","Identifiers":{"Identifier":{"IdNumber":"","IdType":""}},"IndividualPanCheck":"","MemberReferenceNumber":"","OtherAddresses":{"OtherAddress":{"AddressCity":"","AddressLine1":"","AddressLine2":"","AddressLine3":"","AddressPincode":"","AddressStateCode":"","AddressType":"","Telephone":{"ContactArea":"","ContactPrefix":"","TelephoneNum":"","TelephoneType":""}}},"PAN":"ABOFA6135H","RegisteredAddress":{"AddressCity":"BASAI ROAD","AddressLine1":"Plot No. 5, Sector- 34, Gurugram","AddressLine2":"Haryana, pin","AddressLine3":"122001","AddressPincode":"122001","AddressStateCode":"06","AddressType":"REGISTERED OFFICE","Telephone":{"ContactArea":"","ContactPrefix":"","TelephoneNum":"9158103155","TelephoneType":"01"}},"RelationType":"","Telephones":{"Telephone":{"ContactArea":"","ContactPrefix":"","TelephoneExtension":"","TelephoneNumber":"","TelephoneType":""}},"TIN":"","TypeOfEntity":"ASSOCIATION OF PERSONS"}},"ApplicationData":{"AddtionalTag1":"","AddtionalTag2":"","AddtionalTag3":"","AddtionalTag4":"","Amount":"","CommercialCIR":"true","CompanyPANCheck":"","ConsumerCIR":"true","CustomerConsent":"","FormattedReport":"true","GSTStateCode":"06","LitigationReport":"false","MemberReferenceNumber":"","MSMERank":"true","NoOfDirector":"","RawResponse":""}}},"Key":"","OriginatingChannel":"SFDC","RequestId":"168974676796064","RequestInfo":{"EnvironmentId":"1","ExecutionMode":"NewWithContext","SolutionSetId":"440","SolutionSetVersion":"1"},"UserData":""}';
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                calloutRequestWrapper.captureResponseInAttachment = true;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
                respBody = calloutResponseWrapper.response;
                if(respBody<> null && respBody.contains('rankValue')){
                    string rankVal = respBody.substringBetween('"rankValue" : "', '"');
                    if(rankVal<> null && rankVal <> ''){
                        Applicant__c app = New Applicant__c();
                        app.id = appObj.Id;
                        app.Bureau_Score__c = rankVal;
                        update app;
                    }
                }
                 //Insert Bureau_Results__c record for Cibil
                 Bureau_Results__c objbureauResult = new Bureau_Results__c();
                 objbureauResult.Applicant__c = appId;
                 objbureauResult.Bureau__c = 'CIBIL';
                 objbureauResult.Name = 'CIBIL Score';
                 Insert objbureauResult;
                 ContentVersion cv = new ContentVersion();
                 cv.Title = 'Response';
                 cv.VersionData = Blob.valueOf(respBody);
                 cv.Document_Type__c = 'Callout Response';
                 cv.PathOnClient = 'Response.txt';
                 cv.FirstPublishLocationId = objbureauResult.Id;
                 insert cv;

                if(String.isNotBlank(respBody) && respBody.contains('ApplicationId')){
                    string applicationId = respBody.substringBetween('"ApplicationId" : "', '"');
                    System.enqueueJob(new CibilReportNIQueueable(appObj.Id, applicationId, objbureauResult.Id));
                }
                return 'success';
            }
        }catch(Exception ex){
            system.debug('Error');
        }
        return 'error';
    }
}