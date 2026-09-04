/**
 * Created by ngundurao on 03/11/22.
 */

public  class EmailVerificationHandler implements IntegrationHandlerInterface {

    public static List<String> generateRequest(List<Object> recordList){
     return null;
    }
    public static String generateJSONResponse(List<Object> recordList){
        return null;
    } 

    @AuraEnabled
    public static Applicant__c getApplicant(ID recordId) {
        Applicant__c applicant = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c
                                      FROM Applicant__c WHERE Id =:recordId WITH SECURITY_ENFORCED];
        return applicant;
    }

    public static String applcntName(String applcntId) {
        Applicant__c applicnt = getApplicant(applcntId);

        String firstName = applicnt.First_Name__c != null ? applicnt.First_Name__c : '';
        String middleName = applicnt.Middle_Name__c != null ? applicnt.Middle_Name__c : '';
        String lastname = applicnt.Last_Name__c != null ? applicnt.Last_Name__c : '';

        String fullName = firstName + ' ' + middleName + ' ' + lastname;
        return fullName;
    }

    

    @AuraEnabled  
    public static EmailVerificationResponseWrapper doRestCallout(String strEmail, String applicantId,String status,Id integrationChecklistId) {
        Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord('Email Domain Verification');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId,
            Id = (status == 'Unverified ' || status == 'Verified') ? integrationChecklistId : null);
        String strResponse;
        
        String refId = IntegrationUtility.getReferenceId();
        Map<String, String> mapOfUrlQueryParams = new Map<String, String>{'ReqId' => refId, 'Channel' => objIntMaster.Channel__c, 'email' => strEmail};

        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.urlParamsMap = mapOfUrlQueryParams;
        calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMaster;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        
        EmailVerificationResponseWrapper objEmailVerificationResponse;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        strResponse = calloutResponseWrapper.response;
            
             // 	strResponse=		'{"result":{"meta":{"params":{"email":"meenakshigoyal286@gmail.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":true,"mx_records":true,"email":"meenakshigoyal286@gmail.com"}},"request_id":"822c0fb2-f46e-4184-b7fc-a5eb0d01bda3","status-code":"101"}';
 
        system.debug('resp is >>'+strResponse);
        if(strResponse != null) {
            objEmailVerificationResponse = (EmailVerificationResponseWrapper) JSON.deserialize(strResponse, EmailVerificationResponseWrapper.class);
            if( String.isNotBlank( objEmailVerificationResponse.error ) ){
                throw new AuraHandledException( objEmailVerificationResponse.error );
            }
        }
         System.debug('objEmailVerificationResponse---'+objEmailVerificationResponse);
        return objEmailVerificationResponse;
    }

    @AuraEnabled 
    public static String emailVerificationApi(String strEmail, String applcntRecordId) {
        Integration_Master__c objIntMaster = IntegrationUtility.getIntegrationMasterRecord('Email Verification');
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntRecordId);
        String strResponse;
        
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = generateRequest(strEmail, applcntRecordId, objIntMaster);
        EmailVerificationReqWrapper emailVerObj = (EmailVerificationReqWrapper) JSON.deserialize(calloutRequestWrapper.request, EmailVerificationReqWrapper.class);
        checklistRecord.Request_Id__c = emailVerObj.requestId;
        calloutRequestWrapper.method = objIntMaster.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMaster;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        
        EmailVerificationResponseWrapper objEmailVerificationResponse;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        strResponse = calloutResponseWrapper.response;
        system.debug('calloutRequestWrapper.request---'+calloutRequestWrapper.request);
        system.debug('resp is >>'+strResponse);

         //27 JUL || 1357
         Applicant__c appInstance = new Applicant__c();
         appInstance.Id = applcntRecordId;
         appInstance.Email__c = strEmail;
         appInstance.IsEmailVerified__c = false;
         if(!Test.isRunningTest()){
         update appInstance;
         }
         //end

          //Notification
          Applicant__c app = [SELECT id,Loan__c from Applicant__c where id=:applcntRecordId limit 1];
          NotificationHandler.sendNotification('Successful Email id verification',app.Loan__c,'');
 
        return strResponse;
    }

    public static String generateRequest(String strEmail, String applicantId, Integration_Master__c objIntMster) {
        
        String applcntName = applcntName(applicantId);
        
        EmailVerificationReqWrapper emailVerObj = new EmailVerificationReqWrapper();
        emailVerObj.requestId = IntegrationUtility.getReferenceId();
        emailVerObj.channel   = objIntMster.Channel__c;
        emailVerObj.email     = strEmail;
        emailVerObj.entityId  = 'U74120MH2015PTC265316';
        emailVerObj.employeeName      = applcntName;
        emailVerObj.employerName      = '';
        emailVerObj.verificationType  = 'LINK';
        emailVerObj.templateId        = 'AU_LINK';

        templateVariables tempObj = new templateVariables();
        tempObj.client_name = '';
        tempObj.first_name  = '';

        emailVerObj.templateVariables  = tempObj;

        clientData data = new clientData();
        data.caseId = emailVerObj.requestId;
        emailVerObj.clientData = data;

        config confObj = new config();
        confObj.trackerEnabled  = true;
        confObj.expiryInMinutes = 15;
        confObj.forceLocation   = true;
        emailVerObj.config = confObj;

        notification notfCtnObj = new notification();
        notfCtnObj.emails       = new List<String>();
        //notfCtnObj.emails.add(strEmail);// commenting as asked by AU Team SFAU-5569
        notfCtnObj.webhook = true;
        notfCtnObj.webhookConfig = new webhookConfig();
        notfCtnObj.webhookConfig.url = '';
        emailVerObj.notification = notfCtnObj;

        String jsonBody = JSON.serialize(emailVerObj);
        return jsonBody;

    }

    public class EmailVerificationReqWrapper {
        public templateVariables templateVariables{get;set;}
        public String verificationType{get;set;}
        public String templateId{get;set;}
        public String employerName{get;set;}
        public String entityId{get;set;}
        public String employeeName{get;set;}
        public String email{get;set;}
        public config config{get;set;}
        public String channel{get;set;}
        public notification notification{get;set;}
        public String requestId{get;set;}
        public clientData clientData{get;set;}
    }
    public class clientData{
        public string caseId;
    }
    
	public class webhookConfig{
		public String url{get;set;}
	}
	public class templateVariables{
		public String client_name{get;set;}
		public String first_name{get;set;}
	}
	public class notification{
		public Boolean webhook{get;set;}
		public webhookConfig webhookConfig{get;set;}
		public list<String> emails{get;set;}
	}
	public class config{
		public Boolean trackerEnabled{get;set;}
		public Boolean forceLocation{get;set;}
		public Integer expiryInMinutes{get;set;}
	}
    
}