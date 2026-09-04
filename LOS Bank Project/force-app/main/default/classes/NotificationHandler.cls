/*******************************************************************************************
* @Name         NotificationHandler
* @Author       Ashish Nag K
* @Description   Utility Class for Notification
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Ashish Nag K         04/02/2023         Initial Creation 
*******************************************************************************************/
public without sharing class NotificationHandler {
    
    
/*
@description : Method to send the Notification Trigger Point  
@param :  String notificationName, Id loanApplicationId, String phoneNo
@return :void
*/
    
    @AuraEnabled
    public static void sendNotification(String notificationName, Id loanApplicationId, String phoneNo) {
       
        try {
            List < Notification_Content__mdt > notificationList = getNotificationContent(notificationName);
            //System.debug('notificationList-->' +notificationList);
            List < Notification_Content__mdt > smsList = new List < Notification_Content__mdt > ();
            List < Notification_Content__mdt > mailList = new List < Notification_Content__mdt > ();
            List < Notification_Content__mdt > pushNotificationList = new List < Notification_Content__mdt > ();
            List < Notification_Content__mdt > whatsappNotificationList = new List < Notification_Content__mdt > ();
            //Get all the details required from Objects i.e Loan Application and Collateral Details
            List < Loan_Application__c > loanDetails = getLoanDetais(loanApplicationId);
            List < Collateral__c > collateralList = getCollateralDetails(loanApplicationId);
            List < Applicant__c > applicantList = getApplicant(loanApplicationId);

            /*Anirudh's Change */
            String message = '';
            if(notificationName == 'Marks Discrepancy' || notificationName == 'Resolve Discrepancy'){
                 DiscrepancyButtonController.NotificatioWrapper wrapData = (DiscrepancyButtonController.NotificatioWrapper)JSON.deserialize(phoneNo,DiscrepancyButtonController.NotificatioWrapper.class);
                message = wrapData.remarks;
            }
                        
            
            
            if (!notificationList.isEmpty()) {
                for (Notification_Content__mdt record: notificationList) {
                    if ((record.SMS__c == 'Yes') && (record.SMS__c == record.Notification_Master__r.SMS__c) && (record.isActive__c == true)) {
                        smsList.add(record);
                    }
                    if ((record.Email__c == 'Yes') && (record.Email__c == record.Notification_Master__r.Mail__c) && (record.isActive__c == true)) {
                        mailList.add(record);
                    }
                    if ((record.Push_On_Screen__c == 'Yes') && (record.Push_On_Screen__c == record.Notification_Master__r.Push_Notification__c) && (record.isActive__c == true)) {
                        pushNotificationList.add(record);
                    }
                    if ((record.Whatsapp__c == 'Yes') && (record.Whatsapp__c == record.Notification_Master__r.Whatsapp__c) && (record.isActive__c == true)) {
                        whatsappNotificationList.add(record);
                    }
                }
                
                // Check which feature to go in Future method 
                Boolean smsFutureCheck, mailFutureCheck, whatsappFutureCheck = false;
                mailFutureCheck = true;
                whatsappFutureCheck = true;
                smsFutureCheck = true;
              
                
                //String branch = loanDetails != null ? loanDetails[0].Branch_Master__c != null ? loanDetails[0].Branch_Master__c : '' : '';
                //String branch = '';
                String branch = '';
                if(!loanDetails.isEMpty()){
                    if(String.isNotBlank(String.valueOf(loanDetails[0].Branch_Master__c))){
                        branch = String.valueOf(loanDetails[0].Branch_Master__c);
                    }
                }
                
                List < AccountTeamMember > accountTeamList = getbranchManager(branch, 'Branch Manager');
                List < AccountTeamMember > teamLeadList = getbranchManager(branch, 'Team Lead');
                List < AccountTeamMember > fiExecutiveList = getbranchManager(branch, 'FI');
                List < AccountTeamMember > creditList = getbranchManager(branch, 'Credit');
                
                //Assign team members wrapper 
                accountTeamWrapper wrapperInstance = new accountTeamWrapper();
                wrapperInstance.BMList = accountTeamList != null ? accountTeamList : null;
                wrapperInstance.TLList = teamLeadList != null ? teamLeadList : null;
                wrapperInstance.FIList = fiExecutiveList != null ? fiExecutiveList : null;
                wrapperInstance.CreditList = creditList != null ? creditList : null;
                wrapperInstance.branchAddress = getBranchAddress(branch);
                
                if (!smsList.isEmpty()) {
                    // Call SMS Integration
                    sendSmsNotification(smsList, loanDetails, collateralList, applicantList, smsFutureCheck, phoneNo, wrapperInstance);
                }
                if (!mailList.isEmpty()) {
                    // Call Mail Integration
                    sendMailNotification(mailList, loanDetails, collateralList, applicantList, mailFutureCheck, wrapperInstance, phoneNo);
                }
                if (!pushNotificationList.isEmpty()) {
                    // Call Push Notification Integration
                    sendPushNotification(pushNotificationList, loanDetails, collateralList, applicantList, phoneNo, wrapperInstance, message);
                }
                if (!whatsappNotificationList.isEmpty()) {
                    // Call Whatsapp Notification Integration
                    sendWhatsapp(whatsappNotificationList, loanDetails, collateralList, applicantList, phoneNo, whatsappFutureCheck, wrapperInstance);
                }
            }
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
           // throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    
    /*
@description : Method to get the Notification Metadata records based on the Trigger Point  
@param :  String notificationName
@return : List < Notification_Content__mdt >
*/
    
    public static List < Notification_Content__mdt > getNotificationContent(String notificationName) {
        List < Notification_Content__mdt > notificationContentList = new List < Notification_Content__mdt > ();
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            notificationContentList = [SELECT id, Whatsapp__c, Campign_ID__c, Whatsapp_Parameter_1__c, Whatsapp_Parameter_2__c, Whatsapp_Parameter_3__c, Whatsapp_Parameter_4__c, Whatsapp_Parameter_5__c, Notification_Master__r.Trigger_Point__c, Notification_Master__r.Mail__c, Notification_Master__r.Push_Notification__c, Notification_Master__r.SMS__c, Notification_Master__r.Whatsapp__c, Core__c, Email__c, Email_Body__c, Email_Subject__c, On_Screen_Push_SMS__c, On_Screen_Push_SMSContent__c, Push_On_Screen__c, Retention_Period__c, SMS__c, To__c, Urban__c, isActive__c
                                       FROM Notification_Content__mdt
                                       WHERE Notification_Master__r.Trigger_Point__c =: notificationName 
                                      ];
            
        } catch (Exception e) {
            Log.error(e, Log.SeverityType.valueOf('High'), '');
            
        }
        return notificationContentList;
        
    }
    
    /*
@description : Method to handle the SMS Notification  
@param :  List < Notification_Content__mdt > notificationContentList, Id loanApplicationId, String phoneNo
@return : void
*/
    public static void sendSmsNotification(List < Notification_Content__mdt > notificationContentList, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, Boolean smsFutureCheck, String phoneNo, accountTeamWrapper accountTeam) {
        String respBody;
        String requestBody;
        try {
            // query integration Master 
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('SMS Notification');
            String integrationRecord = JSON.serialize(objIntMapper);
            
            //Applicant Details
            ///List < Applicant__c > applicantList = getApplicant(loanDetails[0].Id);
            String customerRecord = applicantList != null && applicantList.size()>0 ? JSON.serialize(applicantList) : '';
            String loanRecord = JSON.serialize(loanDetails);
            String collateralRecord =collateralList!= null ?collateralList.size()>0? JSON.serialize(collateralList) : '':'';
            String teamRecord = JSON.serialize(accountTeam);
            System.debug('applicantList-->' + applicantList);
            
            if (notificationContentList.size() >= 2) {
                for (Notification_Content__mdt record: notificationContentList) {
                    String notificationRecord = JSON.serialize(record);
                    smsfutureCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, phoneNo, teamRecord);
                }
            } else {
                String notificationRecord = JSON.serialize(notificationContentList[0]);
                if (smsFutureCheck == true) {
                    smsfutureCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, phoneNo, teamRecord);
                } else {
                    smsSingleCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, phoneNo, teamRecord);
                }
                
            }
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void smsSingleCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, String phoneNo, String teamRecord) {
        smsCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, phoneNo, teamRecord);
    }
    
    //SMS Future Callout 
    @future(callout = true)
    public static void smsfutureCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, String phoneNo, String teamRecord) {
        smsCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, phoneNo, teamRecord);
    }
    
    /*
@description : Method to handle the SMS Notification Callout
@param : String customerRecord, String loanApplicationId, String notificationRecord, String integrationRecord, String phoneNo
@return : void
*/
    public static void smsCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, String phoneNo, String teamRecord) {
        List < Applicant__c > applicantList = (List < Applicant__c > ) JSON.deserialize(customerRecord, List < Applicant__c > .class);
        try{
            String respBody;
            String requestBody;
            Integration_Master__c objIntMapper = (Integration_Master__c) JSON.deserialize(integrationRecord, Integration_Master__c.class);
            //Loan Details
            List < Loan_Application__c > loanList = (List < Loan_Application__c > ) JSON.deserialize(loanRecord, List < Loan_Application__c > .class);
            String loanApplicationNo = (loanList != null) ? (loanList[0].Application_Number__c != null) ? (loanList[0].Application_Number__c) : '' : '';
            String loanId = (loanList != null) ? loanList[0].Id : '';
            //Collateral Details
            List < Collateral__c > collateralList =String.isNotBlank(collateralRecord) ? (List < Collateral__c > ) JSON.deserialize(collateralRecord, List < Collateral__c > .class) : new List<Collateral__c>();
            
            //Account Team Member Details
            accountTeamWrapper accountTeamMembers = (accountTeamWrapper) JSON.deserialize(teamRecord, accountTeamWrapper.class);
            
            //Applicant Details
            
            String customerName = (applicantList != null) ? (applicantList[0].Customer_Name__c != null) ? String.valueof(applicantList[0].Customer_Name__c) : '' : '';
            String customerEmail = (applicantList != null) ? (applicantList[0].Email__c != null) ? String.valueof(applicantList[0].Email__c) : '' : '';
            String customerMobile = (applicantList != null) ? (applicantList[0].Mobile_Number__c != null) ? String.valueof(applicantList[0].Mobile_Number__c) : '' : '';
            String applicantId = (applicantList != null) ? (applicantList[0].Id) : '';
            
            System.debug('notificationRecord-->' + notificationRecord);
            //Notification Record Details
            Notification_Content__mdt record = (Notification_Content__mdt) JSON.deserialize(notificationRecord, Notification_Content__mdt.class);
            System.debug('record-->' + record);
            String triggerPoint = record.Notification_Master__r.Trigger_Point__c;
            
            //SMS Request
            Map < String, Object > reqParam = new Map < String, Object > ();
            
            String strMessage = '';
            if(triggerPoint == 'Welcome letter (NEW)' || triggerPoint == 'Welcome letter (USED)' || triggerPoint == 'Welcome letter (COW)'){
                strMessage = record.On_Screen_Push_SMSContent__c;
            }else{
                strMessage = record.Core__c;
            }
          
            String toField = record.To__c;
            String includedCustomerMessage = strMessage.replaceAll('CustomerName', customerName);
            String includedLoanMessage = includedCustomerMessage.replaceAll('XXXXXXXXXX', loanApplicationNo);
            
            //Get the Customer Mapping Details based on Trigger Point
            includedLoanMessage = getMessageMapping(triggerPoint, loanList, collateralList, applicantList, includedLoanMessage, toField, accountTeamMembers);
            
            
            if (triggerPoint == 'Payment release' || triggerPoint == 'Partial Disbursment') {
                //includedLoanMessage = includedLoanMessage.replaceAll('<payment recipient name>', phoneNo);
                includedLoanMessage = includedLoanMessage.replaceAll('<Disbursed to name>', phoneNo);
            } else if (triggerPoint ==  'Credit Submission(L0)' ||  triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)' || triggerPoint == 'Pricing (N-1)' || triggerPoint == 'Pricing (N)'  )  {
                includedLoanMessage = getApproverMessage(phoneNo, triggerPoint,includedLoanMessage,loanId);
            }/*else if( triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)') {
                includedLoanMessage = getApprovePricingMessage(phoneNo, loanRecord,triggerPoint,includedLoanMessage);
            }*/
            
            else if (triggerPoint == 'Consent Initiated') {
                includedLoanMessage = includedLoanMessage.replaceAll('<LINK>', phoneNo); // Added by Yash
            } else if(triggerPoint == 'Credit Manual assignment'){
                User userInstance = [SELECT id,Name,Email from User where id=:phoneNo.split('@')[0]];
                User fromUserInstance =[SELECT id,Name,Email from User where id=:phoneNo.split('@')[2]];
                includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', phoneNo.split('@')[1]);
                includedLoanMessage = includedLoanMessage.replaceAll('< Credit person name>',userInstance.Name);
                includedLoanMessage = includedLoanMessage.replaceAll('<name of person who assigned the case>',fromUserInstance.Name);
                includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>',userInstance.Name);
            }
            
            
            reqParam.put('GroupID', 'AUBANK');
            reqParam.put('ContentType', '1');
            reqParam.put('Channel', Label.SMS_Channel); //objIntMapper.Apiuser__c //HFT June13
            reqParam.put('NationalorInternational', '1');
            reqParam.put('MessageType', 'S');
            reqParam.put('IsOTPMessage', '0');
            reqParam.put('LanguageId', 'en');
            reqParam.put('RequestId', IntegrationUtility.getReferenceId());
            
            requestBody = NotificationIntegrationHandler.generateSMSRequest(reqParam)[0];
            String finalPhoneNo = '';
            //Mobile
            if (toField == 'Customer') {
                finalPhoneNo = customerMobile;
            } else if (toField == 'Valuer') {
                finalPhoneNo = phoneNo;
            } else if ( (triggerPoint == 'Credit Submission(L0)') ||   (triggerPoint == 'Credit Submission (N-1)') || (triggerPoint == 'Credit Submission (N)') || (triggerPoint =='Pricing (N-1)')  || ( triggerPoint == 'Pricing (N)')) {
                if (toField == 'CREDIT' || toField == 'Pricing') {
                    User userInstance = getApproverPhone(phoneNo,loanId,triggerPoint);
                    finalPhoneNo =userInstance!=null? userInstance.MobilePhone!=null ? userInstance.MobilePhone : '':'';
                }
            }else if(triggerPoint == 'FI Retrigger' || triggerPoint =='FI Initiation'){
                if (toField == 'FI EXC' || toField == 'FI agency') {
                    User userInstance = [SELECT id,name,MobilePhone FROM User where id=:phoneNo];
                    finalPhoneNo = userInstance.MobilePhone;
                }
            }else if(triggerPoint == 'KYC approval flow'){
                if(toField == 'Ops'){
                    if( getOpsUser(loanList[0].Id)!=null){
                        User userInstance = getOpsUser(loanList[0].Id);
                        finalPhoneNo = userInstance.MobilePhone;
                    }
                   
                }
            } else {
                finalPhoneNo = getPhoneNo(triggerPoint, toField, loanList, accountTeamMembers);
            }
            
            
            if(triggerPoint == 'RTO Agent Trigger'){
                finalPhoneNo = phoneNo;
            }
            
            System.debug('finalPhoneNo-->' + finalPhoneNo);
            //customerMobile
            string msg = ',"Message": {' +
                '"MobileNumber": "' + finalPhoneNo + '",' +
                '"MessageText": "' + includedLoanMessage + ' "' +
                '}}';
            String msgPart = requestBody.replaceAll('}', msg);
            String finalRequest = msgPart;
            
            String recordId = applicantId; //applicantId;
            //System.debug('smsDetailsRequest-->' + JSON.serialize(reqParam));
            
            System.debug('finalRequest->' + JSON.serialize(finalRequest));
            NotificationIntegrationHandler.SMSDetailsRequestWrapper smsDetailsRequest =
                (NotificationIntegrationHandler.SMSDetailsRequestWrapper) JSON.deserialize(requestBody, NotificationIntegrationHandler.SMSDetailsRequestWrapper.class);
            
            if(String.isNotBlank(finalPhoneNo) && finalPhoneNo!=null){
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = finalRequest;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
                respBody = calloutResponseWrapper.response;
                system.debug('respBody-->' + respBody); 
            }else{
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId,Integration_Master__c = objIntMapper.Id,Request__c ='Mobile Number Not Present in the Request for this Trigger Point-> ' +triggerPoint +' TO Field-> '+ toField);
                insert checklistRecord;
               
            }
        }catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantList[0].Id);
        }        
    }
    
    
    public static User getApproverPhone(String notificationParameter,String loanId,String triggerPoint) {
        User userInstance;
        List<Loan_Application_Approval__c> loanApproval = new List <Loan_Application_Approval__c>();
        if(triggerPoint == 'Credit Submission(L0)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__c,Loan_Application__c 
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Credit'
                           AND Type__c= 'Middle'
                           AND Is_Assigned_Approver__c = true 
                           AND Archived__c =false];
        }else if( triggerPoint == 'Credit Submission (N-1)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__c,Loan_Application__c 
                          FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                          AND Approval_Type__c='Credit'
                          AND Type__c= 'Highest'
                          AND Is_Assigned_Approver__c = true 
                          AND Archived__c =false];

        } else if(triggerPoint == 'Credit Submission (N)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__c,Loan_Application__c 
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Pricing'
                           AND (Type__c= 'Base' OR Type__c ='Middle')
                           AND Is_Assigned_Approver__c = true 
                           AND Archived__c =false];
        }else if (triggerPoint =='Pricing (N-1)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__c,Loan_Application__c 
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Pricing'
                           AND Type__c='Highest'
                           AND Is_Assigned_Approver__c = true 
                           AND Archived__c =false];

        }



        if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
            userInstance = [SELECT id, MobilePhone, Email from User where id =:loanApproval[0].Approver__c];
        }   
       

        
        /*
        if (String.isNotBlank(notificationParameter)) {
            List < Loan_Application_Approval__c > approvalList = (List < Loan_Application_Approval__c > ) JSON.deserialize(notificationParameter, List < Loan_Application_Approval__c > .class);
            Boolean isBase, isMiddle, isHighest = false;
            Map < String, String > ApproverIdMap = new Map < String, String > ();
            //Map < String, String > ApproverLevelMap = new Map < String, String > ();
            
            if (!approvalList.isEmpty()) {
                for (Loan_Application_Approval__c approvalInstance: approvalList) {
                    
                    if (approvalInstance.Type__c == 'Base') {
                        isBase = true;
                    }
                    if (approvalInstance.Type__c == 'Middle') {
                        isMiddle = true;
                    }
                    if (approvalInstance.Type__c == 'Highest') {
                        isHighest = true;
                    }
                    
                    ApproverIdMap.put(approvalInstance.Type__c, approvalInstance.Approver__c);
                }
                
                if (isBase == true && isMiddle == true) {
                    if(ApproverIdMap.get('Middle')!=null){
                        userInstance = [SELECT id, MobilePhone, Email from User where id =: ApproverIdMap.get('Middle')];
                    }   
                    
                } else if (isMiddle == true && isHighest == true) {
                    if( ApproverIdMap.get('Highest')!=null){
                        userInstance = [SELECT id, MobilePhone, Email from User where id =: ApproverIdMap.get('Highest')];
                    }
                    
                }
                
            }
        }*/
        System.debug('userInstance-->' +userInstance);
        return userInstance;
    }
    
    /*
@description : Method to handle the Email Notification 
@param : List < Notification_Content__mdt > notificationContentList, Id loanApplicationId, Boolean mailFutureCheck
@return : void
*/
    public static void sendMailNotification(List < Notification_Content__mdt > notificationContentList, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, Boolean mailFutureCheck, accountTeamWrapper accountTeam, String notificationParameter) {
        try {
            
            //Applicant Details
            //List < Applicant__c > applicantList = getApplicant(loanDetails[0].Id);
            //System.debug('applicantList-->' + applicantList);
            
            String loanRecord = JSON.serialize(loanDetails);
            String collateralRecord = JSON.serialize(collateralList);
            
            String customerRecord = JSON.serialize(applicantList);
            String teamRecord = JSON.serialize(accountTeam);
            String applicantId = (applicantList != null) ? (applicantList[0].Id) : '';
            // query integration Master 
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Email Notification');
            String integrationRecord = JSON.serialize(objIntMapper);
            String successResponse = 'false';
           
                for (Notification_Content__mdt record: notificationContentList) {
                    String notificationRecord = JSON.serialize(record);
                    emailfutureCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, teamRecord, notificationParameter);
                }
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void emailSingleCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String teamRecord, String notificationParameter) {
        emailCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, teamRecord, notificationParameter);
    }
    
    //EMAIL Future Callout 
    @future(callout = true)
    public static void emailfutureCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String teamRecord, String notificationParameter) {
        emailCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, teamRecord, notificationParameter);
    }
    
    
    /*
@description : Method to handle the Email Notification Callout
@param : String customerRecord, String loanApplicationId, String notificationRecord, String integrationRecord, Id applicantId
@return : void
*/
    public static void emailCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String teamRecord, String notificationParameter) {
        List < Applicant__c > applicantList = (List < Applicant__c > ) JSON.deserialize(customerRecord, List < Applicant__c > .class);
        try{
            String respBody;
            String requestBody;
            //Loan Details
            List < Loan_Application__c > loanList = (List < Loan_Application__c > ) JSON.deserialize(loanRecord, List < Loan_Application__c > .class);
            String loanApplicationNo = (loanList != null) ? (loanList[0].Application_Number__c != null) ? (loanList[0].Application_Number__c) : '' : '';
            
            Integration_Master__c objIntMapper = (Integration_Master__c) JSON.deserialize(integrationRecord, Integration_Master__c.class);
            
            //Collateral Details
            List < Collateral__c > collateralList = (List < Collateral__c > ) JSON.deserialize(collateralRecord, List < Collateral__c > .class);
            
            //Account Team Member Details
            accountTeamWrapper accountTeamMembers = (accountTeamWrapper) JSON.deserialize(teamRecord, accountTeamWrapper.class);
            
            
            //Applicant Details
            String customerName = (applicantList != null) ? ( String.isNotBlank(applicantList[0].Customer_Name__c)) ? applicantList[0].Customer_Name__c : '' : '';
            String customerEmail = (applicantList != null) ? ( String.isNotBlank(applicantList[0].Email__c )) ? applicantList[0].Email__c : '' : '';
            String customerMobile = (applicantList != null) ? (applicantList[0].Mobile_Number__c != null) ? String.valueof(applicantList[0].Mobile_Number__c) : '' : '';
            
            //Notification Record Details
            Notification_Content__mdt record = (Notification_Content__mdt) JSON.deserialize(notificationRecord, Notification_Content__mdt.class);
            String subject = record.Email_Subject__c;
            String body = record.Email_Body__c;
            String triggerPoint = record.Notification_Master__r.Trigger_Point__c;
            String toField = record.To__c;
            Map < string, string > attachmentMap = new Map < string, string > ();
            /*attachmentMap.put('FileName', triggerPoint+'.pdf');
    attachmentMap.put('FileMimeType', 'application/pdf');
    attachmentMap.put('FileDataContent', fileContent);*/
            
            
            String finalEmailId = '';
            if (toField == 'Customer') {
                finalEmailId = customerEmail ; //customerEmail
            } else if ((triggerPoint == 'Credit Submission (N-1)') || (triggerPoint == 'Credit Submission(L0)') || (triggerPoint == 'Credit Submission (N)')  || (triggerPoint =='Pricing (N-1)') || ( triggerPoint == 'Pricing (N)')) {
                if (toField == 'CREDIT' || toField  == 'Pricing' ) {
                    User userInstance = getApproverPhone(notificationParameter,loanList[0].Id,triggerPoint);
                    finalEmailId =userInstance!=null? userInstance.Email!=null ? userInstance.Email : '':''; 
                }else{
                    finalEmailId = getEmailId(triggerPoint, toField, loanList, accountTeamMembers);
                }
            } else if(triggerPoint =='Credit Manual assignment'){
                User userInstance = [SELECT id,Name,Email from User where id=:notificationParameter.split('@')[0]];
                finalEmailId = userInstance.Email;
            }else  if(triggerPoint == 'FI Retrigger' || triggerPoint =='FI Initiation'){
                if (toField == 'FI EXC' || toField == 'FI agency') {
                    User userInstance = [SELECT id,name,Email FROM User where id=:notificationParameter];
                    finalEmailId = userInstance.Email;
                }
            }else if(triggerPoint == 'KYC approval flow'){
                if(toField == 'Ops'){
                    if( getOpsUser(loanList[0].Id)!=null){
                    User userInstance = getOpsUser(loanList[0].Id);
                    finalEmailId = userInstance.Email;
                    }
                }
            } else {
                finalEmailId = getEmailId(triggerPoint, toField, loanList, accountTeamMembers);
            }
            
            
            //Email Request
          
                Map < String, Object > reqParam = new Map < String, Object > ();
                Map < String, Object > message = new Map < String, Object > ();
                reqParam.put('Channel', Label.Email_Channel); //NACH June13
                reqParam.put('TO', finalEmailId); //customerEmail
                reqParam.put('CC', '');
                reqParam.put('BCC', Label.BccEmail); //Aug 18
                
                String strSubject = subject!=null ? getEmailSubjectMapping(triggerPoint, loanList, collateralList, applicantList, subject):'';
                if(notificationParameter.contains('@@@') && triggerPoint== 'FI Stage Completion'){
                    strSubject = strSubject.replaceAll('<FI result>',notificationParameter.split('@@@')[1]);
    
                }
                
                
                reqParam.put('Subject', strSubject);
                
                body = body.replaceAll('<Customer Name>', customerName);
                body = body.replaceAll('<App no.>', loanApplicationNo);
                body = body.replaceAll('<Coordinator Name', customerName);
                body = body.replaceAll('Mobile number>', customerMobile);
                
                //Get the Customer Mapping Details based on Trigger Point
                body = getMessageMapping(triggerPoint, loanList, collateralList, applicantList, body, toField, accountTeamMembers);
                
                if (triggerPoint == 'Payment release' || triggerPoint == 'Partial Disbursment') {
                    body = body.replaceAll('<Disbursed to name>', notificationParameter);
                } else if (triggerPoint == 'Credit Submission(L0)' || triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)' || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)') {
                    body = getApproverMessage(notificationParameter, triggerPoint,body,loanList[0].Id);
                }
                else if(triggerPoint == 'FI Stage Completion'){
                    body = body.replaceAll('<Address type>', notificationParameter.split('@@@')[0]);
                    body = body.replaceAll('<Address_type>', notificationParameter.split('@@@')[0]);
                    body = body.replaceAll('<FI result>', notificationParameter.split('@@@')[1]);  
                    String loanURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + loanList[0].Id;
                    body = body.replaceAll('<link>', loanURL);  
                      // Logic added by Yash to pass in FI Values
                } else if(triggerPoint == 'Credit Manual assignment'){
                    User userInstance = [SELECT id,Name,Email from User where id=:notificationParameter.split('@')[0]];
                    User fromUserInstance =[SELECT id,Name,Email from User where id=:notificationParameter.split('@')[2]];
                    body = body.replaceAll('<authoritylevel>', notificationParameter.split('@')[1]);
                    body = body.replaceAll('< Credit person name>',userInstance.Name);
                    body = body.replaceAll('<name of person who assigned the case>',fromUserInstance.Name);
                    body = body.replaceAll('<recipient name>',userInstance.Name);
                }
                
                
                
                reqParam.put('Text', body);
                reqParam.put('Priority', '');
                //reqParam.put('Attachment', JSON.serialize(attachmentMap));
                requestBody = NotificationIntegrationHandler.generateEmailRequest(reqParam)[0];
                String recordId = applicantId; //applicantId;
                
                //Method to get the document name based on the trigger point
                String documentName = getDocumentName(triggerPoint) != '' ? getDocumentName(triggerPoint) : '';
                
                //Method to get the File Details based on document name and loan application id from the document checklist 
                String fileContent = '';
                NotificationHandler.fileWrapper fileDetails;
                if (getFileDetails(documentName, loanList[0].Id) != null) {
                    fileDetails = getFileDetails(documentName, loanList[0].Id);
                    fileContent = fileDetails.baseData;
                }
                //Attachment Part 
                string attachment = ',"Attachment": {' +
                    '"FileDataContent": "' + fileContent + '",' +
                    '"FileName": "' + documentName + '.pdf' + '",' +
                    '"FileMimeType": "' + 'application/pdf' + ' "' +
                    '}}';
                String attachmentFinal = requestBody.replaceAll('}', attachment);
                String finalRequest = attachmentFinal;
            if(String.isNotBlank(finalEmailId)){
                NotificationIntegrationHandler.EmailDetailsRequestWrapper emailDetailsRequest =
                    (NotificationIntegrationHandler.EmailDetailsRequestWrapper) JSON.deserialize(requestBody, NotificationIntegrationHandler.EmailDetailsRequestWrapper.class);
                System.debug('emailDetailsRequest-->' + finalRequest);
                
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = finalRequest; //requestBody
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
                respBody = calloutResponseWrapper.response;
                system.debug('respBody-->' + respBody);
            }
            else{
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId,Integration_Master__c = objIntMapper.Id,Request__c ='Email ID Not Present in the Request for this Trigger Point-> ' +triggerPoint +' TO Field-> '+ toField);
                insert checklistRecord;
            }
            
        }catch(exception objException){
            System.debug('exception--->' + objException.getMessage() + '---' + objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantList[0].Id);
        }
    }
    
    
    /*
@description : Method to handle the Push Notification 
@param : List < Notification_Content__mdt > pushNotificationList, Id loanApplicationId, String notificationParemeter( User Id to send the notification)
@return : void
*/
public static void sendPushNotification(List < Notification_Content__mdt > pushNotificationList, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, String notificationParemeter, accountTeamWrapper teamWrapper, String message) {
    try {
            //Loan Details
            List < Loan_Application__c > loanList = loanDetails;
            String loanRecord = JSON.serialize(loanDetails);
            String loanApplicationNo = (loanList != null) ? (loanList[0].Name != null) ? (loanList[0].Name) : '' : '';
            
            System.debug('pushNotificationList-->' + pushNotificationList);
            List < FeedItem > feedItemList = new List < FeedItem > ();
            
            for (Notification_Content__mdt record: pushNotificationList) {
                //String triggerPoint = record.Notification_Master__r.Trigger_Point__c;
                String body = '';
                String strUser;
                String triggerPoint = record.Notification_Master__r.Trigger_Point__c;
                String toField = record.To__c;
                
                //Get the User Id Based on Trigger Point 
                /*if(triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)'){
                User userInstance = getPricingUser(notificationParemeter, loanRecord,triggerPoint);
                strUser = userInstance!=null ?  userInstance.Id!=null ? userInstance.Id:'' :'';
                }else{*/
                strUser = getUserId(triggerPoint, toField, notificationParemeter, loanList, teamWrapper);
               // }
                
                
                if (record.On_Screen_Push_SMSContent__c != null) {
                    String content = record.On_Screen_Push_SMSContent__c;
                    String includedLoanMessage = getMessageMapping(triggerPoint, loanList, collateralList, applicantList, content, toField, teamWrapper);
                    //Exceptions of Message Mapping
                    if (triggerPoint == 'Payment release' || triggerPoint == 'Partial Disbursment') {
                        includedLoanMessage = includedLoanMessage.replaceAll('<Disbursed to name>', notificationParemeter);
                    } else if (triggerPoint == 'Credit Submission(L0)' || triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)' || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)') {
                        includedLoanMessage = getApproverMessage(notificationParemeter, triggerPoint,includedLoanMessage,loanDetails[0].Id);
                    } else if( triggerPoint == 'FI Stage Completion'){ // SFAU-2996
                        includedLoanMessage = includedLoanMessage.replaceAll('<Application number>', loanApplicationNo);
                        includedLoanMessage = includedLoanMessage.replaceAll('<Address type>',notificationParemeter);
                        if(String.isNotBlank(notificationParemeter)){
                            includedLoanMessage = includedLoanMessage.replaceAll('<Address_type>',notificationParemeter.split('@@@')[0]);
                        }
                    } 
                    //END
                    //UFCE Changes start- sadhana
                    else if( triggerPoint == 'UFCE Certificate' || triggerPoint == 'UFCE Declaration'){ 
                        includedLoanMessage = includedLoanMessage.replaceAll('<loan no>', loanApplicationNo);
                        includedLoanMessage = includedLoanMessage.replaceAll('<customer name>',notificationParemeter);
                    }
                    //UFCE Changes end- sadhana
                    else if( triggerPoint == 'Credit Manual assignment'){
                        User userInstance = [SELECT id,Name,Email from User where id=:notificationParemeter.split('@')[0]];
                        User fromUserInstance =[SELECT id,Name,Email from User where id=:notificationParemeter.split('@')[2]];
                        includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', notificationParemeter.split('@')[1]);
                        includedLoanMessage = includedLoanMessage.replaceAll('< Credit person name>',userInstance.Name);
                        includedLoanMessage = includedLoanMessage.replaceAll('<name of person who assigned the case>',fromUserInstance.Name);
                        includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>',userInstance.Name);
                    }
                    //Jul1
                    String loanURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + loanDetails[0].Id;
                    String msg = ' Please find the Loan Details : - Loan Application Number ' + loanApplicationNo + ' AND Loan Link ' + loanURL;
                    msg += '\n' +  'Remarks- ' + message;
                    includedLoanMessage += msg;
                    //END 
                    
                    String strBody = includedLoanMessage;
                    FeedItem post = new FeedItem();
                    post.ParentId = String.isNotBlank(strUser) ? strUser : UserInfo.getUserId();
                    post.Body = strBody;
                    if( post.Body!=null){
                        feedItemList.add(post);
                    }
                    
                }
            }
            System.debug('feedItemList-->' + feedItemList);
            if (!feedItemList.isEmpty() && Schema.sObjectType.FeedItem.isCreateable()) {
                insert feedItemList;
            }
            
        } catch (Exception e) {
            
            System.debug('exception--->' + e.getMessage() + '---' + e.getLineNumber());
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantList[0].Id);
            
        }
        
    }
    
   /* public static User getPricingUser(String notificationParemeter,String loanRecord,String triggerPoint){
        List<Loan_Application__c> loanList = String.isNotBlank(loanRecord ) ? (List<Loan_Application__c>) JSON.deserialize(loanRecord, List<Loan_Application__c>.class) : new List<Loan_Application__c>();
        List<Loan_Application_Approval__c> loanApprovalList = [SELECT id,Name,Type__c,Approver__c,Approver__r.Name,Approver_Level__c,Approval_Type__c,Loan_Application__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=: loanList[0].Id];
        String stage = loanList.size()>0 ? loanList[0].Stage__c : '';
        Map<String,String> ApproverIdMap = new Map<String,String>();
        User userInstance = new User();
        if(!loanApprovalList.isEmpty() && loanApprovalList.size()>0){
            for (Loan_Application_Approval__c approvalInstance: loanApprovalList) {
                if(triggerPoint == 'Pricing (N-1)'){
                    if(stage == 'Credit'){
                        if(notificationParemeter == 'Highest' && String.isNotBlank( approvalInstance.Approval_Type__c) && String.isNotBlank(approvalInstance.Type__c ) ){
                            if( (approvalInstance.Approval_Type__c =='Credit' && approvalInstance.Type__c =='Highest') || (approvalInstance.Approval_Type__c =='Pricing' &&  (approvalInstance.Type__c =='Base' || approvalInstance.Type__c =='Middle' )) ){
                                ApproverIdMap.put(approvalInstance.Type__c, approvalInstance.Approver__c);
                            }
                        }
                    }
                    
                    
                    if( stage == 'Pricing'){
                        if(notificationParemeter == 'Middle' && String.isNotBlank( approvalInstance.Approval_Type__c) && String.isNotBlank(approvalInstance.Type__c ) ){
                            if( (approvalInstance.Approval_Type__c =='Pricing' && approvalInstance.Type__c =='Middle') || (approvalInstance.Approval_Type__c =='Pricing' &&  approvalInstance.Type__c =='Highest' )){
                                ApproverIdMap.put(approvalInstance.Type__c, approvalInstance.Approver__c);
                            }
                        }
                    }
                } else if(triggerPoint == 'Pricing (N)' && String.isNotBlank( approvalInstance.Approval_Type__c) && String.isNotBlank(approvalInstance.Type__c )){
                    if(notificationParemeter == 'Highest' ){
                        if( (approvalInstance.Approval_Type__c =='Pricing' && approvalInstance.Type__c =='Middle') || (approvalInstance.Approval_Type__c =='Pricing' &&  approvalInstance.Type__c =='Highest' )){
                            ApproverIdMap.put(approvalInstance.Type__c, approvalInstance.Approver__c);
                        }
                    }
                }
            }
            
            if(stage == 'Credit' && notificationParemeter == 'Highest'){
                if(ApproverIdMap.get('Middle')!=null || ApproverIdMap.get('Base')!=null ){
                    String approverId = ApproverIdMap.get('Base')!=null ? ApproverIdMap.get('Base') : ApproverIdMap.get('Middle')!=null ? ApproverIdMap.get('Middle') :'';
                    userInstance = [SELECT id, MobilePhone, Email from User where id =: approverId];
                }   
                
            } else if ( stage =='Pricing' && (notificationParemeter == 'Middle' || notificationParemeter == 'Highest' )) {
                if( ApproverIdMap.get('Middle')!=null || ApproverIdMap.get('Highest')!=null){
                    String approverId = ApproverIdMap.get('Middle')!=null ? ApproverIdMap.get('Middle') : ApproverIdMap.get('Highest')!=null ? ApproverIdMap.get('Highest') :'';
                    userInstance = [SELECT id, MobilePhone, Email from User where id =: approverId];
                }
                
            }
        }
       
        return userInstance;
    }*/
    
    /*
@description : Method to handle the Whatsapp Notification 
@param : List < Notification_Content__mdt > pushNotificationList, Id loanApplicationId, String notificationParemeter( User Id to send the notification),Boolean whatsappFutureCheck(parameter to check whether it qualifies for future callout or not)
@return : void
*/
    public static void sendWhatsapp(List < Notification_Content__mdt > notificationContentList, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, String notificationParemeter, Boolean whatsappFutureCheck, accountTeamWrapper accountTeam) {
        //Loan Details
        List < Loan_Application__c > loanList = loanDetails;
        String loanApplicationNo = (loanList != null) ? (loanList[0].Application_Number__c != null) ? (loanList[0].Application_Number__c) : '' : '';
        
        //Applicant Details
        //  List < Applicant__c > applicantList = getApplicant(loanList[0].Id);
        // System.debug('applicantList-->' + applicantList);
        
        String customerRecord = JSON.serialize(applicantList);
        String applicantId = (applicantList != null) ? (applicantList[0].Id) : '';
        // query integration Master 
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Whatsapp Notification');
        System.debug('objIntMapper-->' +objIntMapper);
        if(IntegrationUtility.getIntegrationMasterRecord('Whatsapp Notification')!=null){
            String integrationRecord = JSON.serialize(objIntMapper);
            System.debug('notificationContentList-->' + notificationContentList.size());
            
            String loanRecord = JSON.serialize(loanDetails);
            String collateralRecord = JSON.serialize(collateralList);
            String accountTeamRecordd = JSON.serialize(accountTeam);
            
            
            
            if (notificationContentList.size() >= 2) {
                for (Notification_Content__mdt record: notificationContentList) {
                    String notificationRecord = JSON.serialize(record);
                    whatsappfutureCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, accountTeamRecordd, notificationParemeter);
                }
            } else {
                String notificationRecord = JSON.serialize(notificationContentList[0]);
                if (whatsappFutureCheck == false) {
                    whatsappSingleCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, accountTeamRecordd, notificationParemeter);
                } else {
                    whatsappfutureCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, accountTeamRecordd, notificationParemeter);
                }
                
            }
        } 
    }
    
    public static void whatsappSingleCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String accountTeamRecordd, String notificationParemeter) {
        whatsappCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, accountTeamRecordd, notificationParemeter);
    }
    
    //Whatsapp Future Callout 
    @future(callout = true)
    public static void whatsappfutureCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String accountTeamRecordd, String notificationParemeter) {
        whatsappCallout(customerRecord, loanRecord, collateralRecord, notificationRecord, integrationRecord, applicantId, accountTeamRecordd, notificationParemeter);
    }
    
    
    /*
@description : Method to send the Whatsapp Notification Callout
@param : String customerRecord, String loanApplicationNo, String notificationRecord, String integrationRecord, Id applicantId
@return : void
*/
    public static void whatsappCallout(String customerRecord, String loanRecord, String collateralRecord, String notificationRecord, String integrationRecord, Id applicantId, String accountTeamRecordd, String notificationParemeter) {
        //Applicant Details
        List < Applicant__c > applicantList = (List < Applicant__c > ) JSON.deserialize(customerRecord, List < Applicant__c > .class);
        try{
            String respBody;
            String requestBody;
            
            Integration_Master__c objIntMapper = (Integration_Master__c) JSON.deserialize(integrationRecord, Integration_Master__c.class);
            
            //Loan Details
            List < Loan_Application__c > loanList = (List < Loan_Application__c > ) JSON.deserialize(loanRecord, List < Loan_Application__c > .class);
            
            //Collateral Details
            List < Collateral__c > collateralList = (List < Collateral__c > ) JSON.deserialize(collateralRecord, List < Collateral__c > .class);
            
            //Account Team Member Details
            accountTeamWrapper accountTeamMembers = (accountTeamWrapper) JSON.deserialize(accountTeamRecordd, accountTeamWrapper.class);
            
            
            String customerName = (applicantList != null) ? (applicantList[0].Customer_Name__c != null) ? String.valueof(applicantList[0].Customer_Name__c) : '' : '';
            String customerEmail = (applicantList != null) ? (applicantList[0].Email__c != null) ? String.valueof(applicantList[0].Email__c) : '' : '';
            String customerMobile = (applicantList != null) ? (applicantList[0].Mobile_Number__c != null) ? String.valueof(applicantList[0].Mobile_Number__c) : '' : '';
            
            //Notification Record Details
            Notification_Content__mdt record = (Notification_Content__mdt) JSON.deserialize(notificationRecord, Notification_Content__mdt.class);
            String body = record.On_Screen_Push_SMSContent__c;
            String triggerPoint = record.Notification_Master__r.Trigger_Point__c;
            String strTo = record.To__c;
            String campaign_id = record.Campign_ID__c != null ? record.Campign_ID__c : '';
            //String finalMessage = getMessageMapping(triggerPoint, loanList, collateralList, applicantList, body, strTo, accountTeamMembers);
            
            //Mobile Number Mappings
            String finalPhoneNo = '';
            if (strTo == 'Customer') {
                finalPhoneNo = customerMobile;
            } else if (strTo == 'Valuer') {
                finalPhoneNo = notificationParemeter;
            } else if ( (triggerPoint == 'Credit Submission (N)') || (triggerPoint == 'Credit Submission (N-1)') || (triggerPoint == 'Credit Submission(L0)') || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)') {
                if (strTo == 'CREDIT' || strTo=='Pricing') {
                    User userInstance = getApproverPhone(notificationParemeter,loanList[0].Id,triggerPoint);
                    finalPhoneNo =userInstance!=null ?userInstance.MobilePhone!=null ?  userInstance.MobilePhone:'':'';
                }
            } else if(triggerPoint == 'FI Retrigger' || triggerPoint =='FI Initiation'){
                if (strTo == 'FI EXC' || strTo == 'FI agency') {
                    User userInstance = [SELECT id,name,MobilePhone FROM User where id=:notificationParemeter];
                    finalPhoneNo = userInstance.MobilePhone;
                }
            }else if(triggerPoint == 'KYC approval flow'){
                if(strTo == 'Ops'){
                    if( getOpsUser(loanList[0].Id)!=null){
                    User userInstance = getOpsUser(loanList[0].Id);
                    finalPhoneNo = userInstance.MobilePhone;
                    }
                }
            }  else {
                finalPhoneNo = getPhoneNo(triggerPoint, strTo, loanList, accountTeamMembers);
            }
            
            if(String.isNotBlank(finalPhoneNo)){
            //Whatsapp Request
            Map < String, Object > requestMap = new Map < String, Object > ();
            requestMap.put('authorization', '0915de5d-a4ed-44ce-896b-8d1f7e1dbcae'); //a404ecc7-aa71-4930-b1c5-64724d5fa563
            
            Map < String, String > clientData = new Map < String, String > ();
            clientData.put('name', customerName);
            clientData.put('phone_number', finalPhoneNo); //customerMobile
            clientData.put('media_url', 'https://helpdesk.aubank.in/assets/FrontEnd/images/banner4.jpg');
            clientData.put('document_filename', 'document_filename1');
            
            Map < String, String > dynamicData = new Map < String, String > ();
            if (String.isNotBlank(record.Whatsapp_Parameter_1__c)) {
                dynamicData.put('key1', getMessageMapping(triggerPoint, loanList, collateralList, applicantList, record.Whatsapp_Parameter_1__c, strTo, accountTeamMembers));
            }
            if (String.isNotBlank(record.Whatsapp_Parameter_2__c)) {
                dynamicData.put('key2', getMessageMapping(triggerPoint, loanList, collateralList, applicantList, record.Whatsapp_Parameter_2__c, strTo, accountTeamMembers));
            }
            if (String.isNotBlank(record.Whatsapp_Parameter_3__c)) {
                dynamicData.put('key3', getMessageMapping(triggerPoint, loanList, collateralList, applicantList, record.Whatsapp_Parameter_3__c, strTo, accountTeamMembers));
            }
            if (String.isNotBlank(record.Whatsapp_Parameter_4__c)) {
                dynamicData.put('key4', getMessageMapping(triggerPoint, loanList, collateralList, applicantList, record.Whatsapp_Parameter_4__c, strTo, accountTeamMembers));
            }
            if (String.isNotBlank(record.Whatsapp_Parameter_5__c)) {
                dynamicData.put('key5', getMessageMapping(triggerPoint, loanList, collateralList, applicantList, record.Whatsapp_Parameter_5__c, strTo, accountTeamMembers));
            }
            
            
            
            clientData.put('dynamic_data', JSON.serialize(dynamicData));
            
            requestMap.put('client_data', JSON.serialize(clientData));
            requestMap.put('requestId', '');
            requestMap.put('whatsapp_bsp', '1');
            requestMap.put('channel', Label.Whatsapp_Channel); //INS June13
            requestMap.put('campaign_id', campaign_id); //176
            
            requestBody = NotificationIntegrationHandler.generateWhatsappRequest(requestMap)[0];
            String recordId = applicantId; //applicantId;
            System.debug('notificationRequest-->' + requestBody);
            ///
            
            //Integration
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody.replace('\\', '').replace('\"{', '{').replace('}\"', '}');
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody = calloutResponseWrapper.response;
            system.debug('respBody-->' + respBody);
            }else{
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId,Integration_Master__c = objIntMapper.Id,Request__c ='Mobile Number Not Present in the Request for this Trigger Point-> ' +triggerPoint +' Campaign Id-> '+campaign_id +' TO Field-> '+ strTo);
                insert checklistRecord;
            }
        } catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantList[0].Id);
        }
    }
    /*
@description : Method to Get User Id Based on TriggerPoint
@param : String triggerPoint, String notificationParemeter, List < Loan_Application__c > loanList
@return : String userID
*/
    public static String getUserId(String triggerPoint, String strTo, String notificationParemeter, List < Loan_Application__c > loanList, accountTeamWrapper teamWrapper) {
        String userId = '';
        //String ROName = loanDetails[0].Owner.Name != null ? loanDetails[0].Owner.Name : '';
        List < AccountTeamMember > accountTeamList = teamWrapper.BMList;
        List < AccountTeamMember > teamLeadList = teamWrapper.TLList;
        List < AccountTeamMember > fiExecutiveList = teamWrapper.FIList;
        
        System.debug('teamWrapper-->' + teamWrapper);
        String tlId = '';
        String fiId = '';
        String bmId = '';
        
        //String strROId = loanList.size() > 0 ? loanList[0].Owner.Id != null ? loanList[0].Owner.Id : '' : '';
        String strROId = loanList.size() > 0 ? loanList[0].Owner.Id : '' ;
        if (teamWrapper.BMList != null || teamWrapper.TLList != null || teamWrapper.FIList != null) {
            if (teamWrapper.TLList != null && teamWrapper.TLList.size() > 0  && !teamWrapper.TLList.isEmpty()) {
                tlId = teamLeadList[0].User.Id;
            }
            if ( teamWrapper.FIList != null && teamWrapper.FIList.size() > 0 && !teamWrapper.FIList.isEmpty()) {
                fiId = fiExecutiveList[0].User.Id;
            }
            if ( teamWrapper.BMList != null && teamWrapper.BMList.size() > 0 && !teamWrapper.BMList.isEmpty()) {
                bmId = accountTeamList[0].User.Id;
            }
        }
        
        
        //tlId = teamLeadList != null ? teamLeadList[0].User != null ? teamLeadList[0].User.Id != null ? teamLeadList[0].User.Id : '' : '' : '';
        //fiId = fiExecutiveList != null ? fiExecutiveList[0].User != null ? fiExecutiveList[0].User.Id != null ? fiExecutiveList[0].User.Id : '' : '' : '';
        // bmId = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Id != null ? accountTeamList[0].User.Id : '' : '' : '';
        
        
        if (strTo == 'RO') {
            userId = strROId;
        } else if (strTo == 'TL') {
            userId = tlId;
        } else if (strTo == 'FI EXC' || strTo == 'FI agency') {
            if(triggerPoint == 'FI Retrigger' ||  triggerPoint =='FI Initiation'){
                userId = notificationParemeter;
            }else{
                userId = fiId;
            }
        }else if (strTo == 'BM') {
            userId = bmId;
        } else if (strTo == 'CREDIT' || strTo=='Pricing') {
            if ((triggerPoint == 'Credit Submission (N-1)') || (triggerPoint == 'Credit Submission(L0)') || (triggerPoint == 'Credit Submission (N)') || triggerPoint == 'Pricing (N-1)' ) {
                User userInstance = getApproverPhone(notificationParemeter,loanList[0].Id,triggerPoint);
                System.debug('User-->' +userInstance);
                if( userInstance!=null){
                    userId = userInstance.Id!=null ?userInstance.Id : '';
                }
                
            } else if(triggerPoint == 'Credit Manual assignment'){
                userId = notificationParemeter.split('@')[0];
            }  else if(triggerPoint == 'Valuation Submission'){
                if(getCreditBaseApprovalRecord(loanList[0].id)!=null ){
                    List<Loan_Application_Approval__c> loanApprovalList = getCreditBaseApprovalRecord(loanList[0].id);
                    userId = loanApprovalList[0].Approver__r!=null ?loanApprovalList[0].Approver__r.Id :'';
                }
            } else {
                userId = UserInfo.getUserId(); 
            }
        } 
        else if(strTo == 'Ops Maker'){
            if(triggerPoint == 'Resolve Discrepancy'){
                DiscrepancyButtonController.NotificatioWrapper wrapData = (DiscrepancyButtonController.NotificatioWrapper)JSON.deserialize(notificationParemeter,DiscrepancyButtonController.NotificatioWrapper.class);
                userId = wrapData.ownerId;
            }
        }else if(triggerPoint == 'KYC approval flow'){
            if(strTo == 'Ops'){
                if( getOpsUser(loanList[0].Id)!=null){
                User userInstance = getOpsUser(loanList[0].Id);
                userId = userInstance.Id;
                }
            }
        } 
        return userId;
    }
    
    public static String getPhoneNo(String triggerPoint, String strTo, List < Loan_Application__c > loanList, accountTeamWrapper teamWrapper) {
        String phoneNo = '';
        List < AccountTeamMember > accountTeamList = teamWrapper.BMList;
        List < AccountTeamMember > teamLeadList = teamWrapper.TLList;
        List < AccountTeamMember > fiExecutiveList = teamWrapper.FIList;
        
        String strROPhone = loanList.size() > 0 ? loanList[0].Owner.Phone != null ? loanList[0].Owner.Phone : '' : '';
        String dealerPhone = loanList.size() > 0 ? loanList[0].Dealer_Master__c != null ? loanList[0].Dealer_Master__r.Phone != null ? loanList[0].Dealer_Master__r.Phone : '' : '' : '';
        String tlPhone = teamLeadList != null ? teamLeadList[0].User != null ? teamLeadList[0].User.MobilePhone != null ? teamLeadList[0].User.MobilePhone : '' : '' : '';
        String fiPhone = fiExecutiveList != null ? fiExecutiveList[0].User != null ? fiExecutiveList[0].User.MobilePhone != null ? fiExecutiveList[0].User.MobilePhone : '' : '' : '';
        String bmPhone = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.MobilePhone != null ? accountTeamList[0].User.MobilePhone : '' : '' : '';
        
        if (strTo == 'RO') { 
            phoneNo = strROPhone;
            
        } else if (strTo == 'Dealer' || strTo == 'channel') {
            phoneNo = dealerPhone;
        } else if (strTo == 'TL') {
            phoneNo = tlPhone;
            
        } else if (strTo == 'FI EXC' || strTo == 'FI agency') {
            if(triggerPoint!='FI Initiation' || triggerPoint!='FI Retrigger' ){
                phoneNo = fiPhone;
            }
        } else if (strTo == 'BM') {
            phoneNo = bmPhone;
        } else if(strTo == 'Credit'){
            if(getCreditBaseApprovalRecord(loanList[0].id)!=null ){
                List<Loan_Application_Approval__c> loanApprovalList = getCreditBaseApprovalRecord(loanList[0].id);
                phoneNo = loanApprovalList[0].Approver__r!=null ? loanApprovalList[0].Approver__r.MobilePhone!=null ? loanApprovalList[0].Approver__r.MobilePhone :'':'';
            }
        }
        
        /*else if (strTo == 'FI agency') {
phoneNo = '8190008108'; // mapping pending
} else if (strTo == 'CREDIT') {
// phoneNo = '8296853716'; // mapping pending
}*/
        
        System.debug('ingetPhoneNo-->' + phoneNo);
        return phoneNo;
    }

    public static List<Loan_Application_Approval__c> getCreditBaseApprovalRecord(String loanId){
        List<Loan_Application_Approval__c> loanApprovalList = [SELECT id,Name,Type__c,Approver__r.Name,Approver__r.ID,Approver__r.Phone,Approver__r.MobilePhone,Approver__r.Email,Approver_Level__c,Approval_Type__c,Loan_Application__c,Remarks__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:loanId AND (Type__c = 'Base' OR Type__c = ''  )AND Approval_Type__c ='Credit' ORDER BY CreatedDate DESC LIMIT 1];
        if(!loanApprovalList.isEmpty() && loanApprovalList.size()>0){
            return loanApprovalList;
        }else{
            return null;
        }
    }

    public static String getEmailId(String triggerPoint, String strTo, List < Loan_Application__c > loanList, accountTeamWrapper teamWrapper) {
        String emailID = '';
        List < AccountTeamMember > accountTeamList = teamWrapper.BMList;
        List < AccountTeamMember > teamLeadList = teamWrapper.TLList;
        List < AccountTeamMember > fiExecutiveList = teamWrapper.FIList;
        
        String strROEmail = loanList.size() > 0 ? loanList[0].Owner.Email != null ? loanList[0].Owner.Email : '' : '';
        String dealerEmail = loanList.size() > 0 ? loanList[0].Dealer_Master__c != null ? loanList[0].Dealer_Master__r.Email__c != null ? loanList[0].Dealer_Master__r.Email__c : '' : '' : '';
        String tlEmail = teamLeadList != null ? teamLeadList[0].User != null ? teamLeadList[0].User.Email != null ? teamLeadList[0].User.Email : '' : '' : '';
        String fiEmail = fiExecutiveList != null ? fiExecutiveList[0].User != null ? fiExecutiveList[0].User.Email != null ? fiExecutiveList[0].User.Email : '' : '' : '';
        String bmEmail = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Email != null ? accountTeamList[0].User.Email : '' : '' : '';
        
        if (strTo == 'RO') {
            emailID = strROEmail;
            
        } else if (strTo == 'TL') {
            emailID = tlEmail;
            
        } else if (strTo == 'Dealer' || strTo == 'channel') {
            emailID = dealerEmail;
            
        } else if (strTo == 'FI EXC' || strTo == 'FI agency') {
            emailID = fiEmail;
            
        } else if (strTo == 'BM') {
            emailID = bmEmail;
            
        }  else if (strTo == 'Valuer') {
            emailID = strROEmail;
        } else if (strTo == 'CREDIT') {
            if(getCreditBaseApprovalRecord(loanList[0].id)!=null ){
                    List<Loan_Application_Approval__c> loanApprovalList = getCreditBaseApprovalRecord(loanList[0].id);
                    emailID = loanApprovalList[0].Approver__r!=null ? loanApprovalList[0].Approver__r.Email!=null ? loanApprovalList[0].Approver__r.Email :'':'';
                }else{
                    emailID = strROEmail;
                }
        }
        
        
        System.debug('ingetPhoneNo-->' + emailID);
        return emailID;
    }
    
    /*
@description : Method to Get applicant list based on loanId
@param : String loanApplicationId
@return :  List < Applicant__c >
*/
    public static List < Applicant__c > getApplicant(String loanApplicationId) {
        
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            List < Applicant__c > applicantList = [SELECT id, Customer_Name__c, First_Name__c, Middle_Name__c, Last_Name__c, Mobile_Number__c, Email__c, Loan__c, RecordType.Name, CIF_No__c,Bureau_Score__c
                                                   FROM Applicant__c
                                                   WHERE Loan__c =: loanApplicationId
                                                   AND RecordType.Name = 'Applicant'
                                                   
                                                  ];
            if (!applicantList.isEmpty()) {
                return applicantList;
            } else {
                return null;
            }
            
        }catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            return null;
        }
    }
    
    /*
@description : Method to Get Loan Details Based on LoanId
@param : String loanApplicationId
@return : List < Loan_Application__c > 
*/
    public static List < Loan_Application__c > getLoanDetais(String loanApplicationId) {
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            List < Loan_Application__c > loanList = [SELECT Id,Name,Stage__c, Loan_Amount__c,Repayment_Account_Number__c, Application_Number__c, Application_Id__c, Loan_Amount_In_Words__c, RecordType.Name, Rejection_Reason__c, Branch_Master__c, EMI__c, Owner.Name, Owner.Phone, Owner.Id, Owner.Email, Owner_code__c, Dealer_Master__r.Name, Dealer_Master__r.City__c, tolabel(Product__c), Sourcing_channel__c, Dealer_Master__r.Email__c, Dealer_Master__r.Phone, Repayment_Mode__c,Tenure__c,First_EMI_Date__c
                                                     FROM Loan_Application__c
                                                     WHERE Id =: loanApplicationId
                                                     
                                                    ];
            if (!loanList.isEmpty()) {
                return loanList;
            } else {
                return null;
            }
            
        } catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            return null;
        }
    }
    
    public static String getWelcomeLetter(String loanApplicationId) {
        String resultPublicUrl = '';
        List < Document_Checklist__c > docCheckList = [SELECT id, Name, Document_Master__r.Document_Name__c, Document_Name__c, Loan_Application__c, (SELECT Id, ContentDocumentId, ContentDocument.title, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1)
                                                       FROM Document_Checklist__c
                                                       WHERE(Document_Master__r.Document_Name__c = 'Welcome Letter'
                                                             OR Document_Name__c = 'Welcome Letter')
                                                       AND Loan_Application__c =: loanApplicationId
                                                      ];
        
        
        String contentDocumentId = '';
        if (docCheckList.size() > 0) {
            if (!(docCheckList[0].ContentDocumentLinks).isEmpty()) {
                contentDocumentId = docCheckList[0].ContentDocumentLinks[0].ContentDocumentId;
            }
        }
        
        if (String.isNotBlank(contentDocumentId)) {
            /*  List<ContentDistribution> ContentDistributionList = [SELECT DistributionPublicUrl 
FROM ContentDistribution
WHERE ContentDocumentId = :contentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
if(ContentDistributionList.size()>0){
wrapperInstance.documentURL = ContentDistributionList[0].DistributionPublicUrl != null ?  ContentDistributionList[0].DistributionPublicUrl : '';
}*/
            ContentVersion cv = [SELECT VersionData, Shortend_Public_Url__c
                                 FROM ContentVersion
                                 WHERE ContentDocumentId =: contentDocumentId
                                 ORDER BY CreatedDate DESC LIMIT 1
                                ];
            
            resultPublicUrl = cv.Shortend_Public_Url__c != null ? cv.Shortend_Public_Url__c : '';
        }
        
        return resultPublicUrl;
    }
    
    /*
@description : Method to Get Collateral Details Based on LoanId
@param : String loanApplicationId
@return : List < Collateral__c > 
*/
    public static List < Collateral__c > getCollateralDetails(String loanApplicationId) {
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            List < Collateral__c > collateralList = [SELECT Id, Loan__c, CreatedDate, Original_RC_Details__c, Vehicle_Number__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Loan__r.Application_Id__c, Loan__r.Application_Number__c, MMV_Master__r.Name, DO_Generation_Date__c, Loan__r.Loan_Amount_In_Words__c, Loan__r.EMI__c, Variant__c, Loan__r.Rejection_Reason__c, Loan__r.Owner.Name, Loan__r.Owner.Phone, Manufacture_Year__c, Valuation_Amount__c
                                                     FROM Collateral__c
                                                     WHERE Loan__c =: loanApplicationId
                                                     AND Variant__c!=null
                                                     ORDER BY CreatedDate DESC LIMIT 1
                                                    ];
            if (!collateralList.isEmpty()) {
                return collateralList;
            } else {
                return null;
            }
            
        }catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            return null;
        }
    }
    
    public static valuationWrapper getValuationDetails(String loanApplicationId) {
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            valuationWrapper wrapperInstance = new valuationWrapper();
            List < Valuation__c > valuationList = [SELECT id, Valuation_Amount__c, Collateral__r.Loan__c, Coordinate_for_valuation_POC__c, Contact_Person_Mobile_Number__c, Final_remarks__c, (SELECT Id, ContentDocumentId, ContentDocument.title, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1)
                                                   FROM Valuation__c
                                                   WHERE Collateral__r.Loan__c =: loanApplicationId
                                                   ORDER BY CreatedDate DESC LIMIT 1
                                                  ];
            System.debug('valuationList-->' + valuationList);
            wrapperInstance.valuationList = valuationList;
            String contentDocumentId = '';
            if (valuationList.size() > 0) {
                if (!(valuationList[0].ContentDocumentLinks).isEmpty()) {
                    contentDocumentId = valuationList[0].ContentDocumentLinks[0].ContentDocumentId;
                }
            }
            
            if (String.isNotBlank(contentDocumentId)) {
                /*  List<ContentDistribution> ContentDistributionList = [SELECT DistributionPublicUrl 
FROM ContentDistribution
WHERE ContentDocumentId = :contentDocumentId ORDER BY CreatedDate DESC LIMIT 1];
if(ContentDistributionList.size()>0){
wrapperInstance.documentURL = ContentDistributionList[0].DistributionPublicUrl != null ?  ContentDistributionList[0].DistributionPublicUrl : '';
}*/
                ContentVersion cv = [SELECT VersionData, Shortend_Public_Url__c
                                     FROM ContentVersion
                                     WHERE ContentDocumentId =: contentDocumentId
                                     ORDER BY CreatedDate DESC LIMIT 1
                                    ];
                
                wrapperInstance.documentURL = cv.Shortend_Public_Url__c != null ? cv.Shortend_Public_Url__c : '';
            }
            
            
            if (valuationList.size() > 0) {
                return wrapperInstance;
            } else {
                return null;
            }
        } catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            return null;
        }
    }
    
    public static List < AccountTeamMember > getbranchManager(String accountId, String role) {
        try {
            //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
            if (accountId != null && String.isNotBlank(accountId)) {
                 List < AccountTeamMember > teamMemberList = new List <AccountTeamMember>();
                if(role == 'Branch Manager'){
                    teamMemberList = [SELECT id, TeamMemberRole,Is_Primary_BM__c, User.Name, User.Phone, UserId, User.MobilePhone, User.Email
                                                             FROM AccountTeamMember
                                                             WHERE TeamMemberRole =: role
                                                             AND AccountId =: accountId 
                                                             AND Is_Primary_BM__c = true
                                                             ORDER BY CreatedDate DESC LIMIT 1
                                                            ];
                }else if(role == 'Credit'){
                    teamMemberList = [SELECT id, TeamMemberRole, User.Name, User.Phone, UserId, User.MobilePhone, User.Email,Approver_Level__c
                                      FROM AccountTeamMember
                                      WHERE TeamMemberRole =: role
                                      AND AccountId =: accountId 
                                      AND Approver_Level__c ='L0'
                                      ORDER BY CreatedDate DESC LIMIT 1
                                      ];
                } else{
                     teamMemberList = [SELECT id, TeamMemberRole, User.Name, User.Phone, UserId, User.MobilePhone, User.Email
                                                             FROM AccountTeamMember
                                                             WHERE TeamMemberRole =: role
                                                             AND AccountId =: accountId 
                                                             ORDER BY CreatedDate DESC LIMIT 1
                                                            ];
                }
               
                if (teamMemberList.size() > 0 && !teamMemberList.isEmpty()) {
                    return teamMemberList;
                } else {
                    return null;
                }
                
            } else {
                return null;
            }
            
        }catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),accountId);
            return null;
        }
    }

    public static String getBranchAddress(String accountId){
        Account accInstance = [SELECT id,Address__c FROM Account WHERE Id=:accountId];
        String address='';
        if(accInstance!=null){
            return (String.isNotBlank(accInstance.Address__c)?accInstance.Address__c : '');
        }else{
            return null;
        }
    }

    public static STring getApprovalRecord(String loanId, String docName){
        List<Loan_Application_Approval__c> approvalList = [SELECT Id, Remarks__c, Document_Name__c, Approver__c, Loan_Application__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:loanId AND 
                                                           Document_Name__c = :docName AND Approver__c = :UserInfo.getUserId()
                                                          ];
        if(!approvalList.isEmpty()){
            return (STring.isNotBlank(approvalList[0].Remarks__c)?approvalList[0].Remarks__c : 'Invalid Data');
        }
        else{
            return 'Invalid Data';
        }
    }
    
    
    
    /*
@description : Method to Get  Message Details Mapping based on the trigger point
@param : String triggerPoint, String loanApplicationId, String includedLoanMessage
@return :string
*/
    public static string getMessageMapping(String triggerPoint, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, String includedLoanMessage, String strTo, accountTeamWrapper teamMembers) {
        String firstName = applicantList[0].First_Name__c != null ? applicantList[0].First_Name__c : '';
        String customerName = applicantList[0].Customer_Name__c != null ? applicantList[0].Customer_Name__c : '';
        String cifNo = applicantList[0].CIF_No__c != null ? applicantList[0].CIF_No__c : '';
        String ROName = loanDetails[0].Owner.Name != null ? loanDetails[0].Owner.Name : '';
        String ROPhone = loanDetails[0].Owner.Phone != null ? loanDetails[0].Owner.Phone : '';
        String empCode = loanDetails[0].Owner_code__c != null ? loanDetails[0].Owner_code__c : '';
        String mmv = collateralList!=null ?collateralList.size()>0 ? String.isNotBlank(collateralList[0].Variant__c)  ? collateralList[0].Variant__c : '' : '' :'';
        String loanApplicationNo = loanDetails[0].Name != null ? loanDetails[0].Name : '';
        String loanApplicationId = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
        String applId = applicantList[0].Id != null ? applicantList[0].Id : '';
        String productName = (loanDetails[0].Product__c) != null ? loanDetails[0].Product__c : '';
        String loanType = loanDetails[0].RecordType.Name != null ? loanDetails[0].RecordType.Name : '';
        String loanAmount = loanDetails[0].Loan_Amount__c != null ? String.valueof(loanDetails[0].Loan_Amount__c) : '';
        String loanEmi = (loanDetails[0].EMI__c) != null ? String.valueof(loanDetails[0].EMI__c) : '';
        String loanFirstEmi = loanDetails[0].First_EMI_Date__c != null ? String.valueof(loanDetails[0].First_EMI_Date__c) : '';
        String tenure = loanDetails[0].Tenure__c != null ? String.valueof(loanDetails[0].Tenure__c) : '';
        String branch ='';
        String doCancelReason = getApprovalRecord(loanDetails[0].Id,'DO Cancelled letter');
        String loanStage = loanDetails[0].Stage__c != null ? loanDetails[0].Stage__c : '';
        String score = applicantList[0].Bureau_Score__c!=null ? applicantList[0].Bureau_Score__c : '';
        if(!loanDetails.isEMpty()){
            if(String.isNotBlank(String.valueOf(loanDetails[0].Branch_Master__c))){
                branch = String.valueOf(loanDetails[0].Branch_Master__c);
            }
        }
        //loanDetails[0].Branch_Master__c != null ? loanDetails[0].Branch_Master__c : '';
        String vehicleName =  collateralList!=null ?  collateralList.size()>0 ?  String.isNotBlank(collateralList[0].Variant__c)? collateralList[0].Variant__c : '' : '':'';
        
        String channelName = String.isNotBlank(loanDetails[0].Sourcing_channel__c) ? loanDetails[0].Sourcing_channel__c : '';
        String rcDetails = collateralList!=null ?  collateralList.size()>0 ?  String.isNotBlank(collateralList[0].Original_RC_Details__c)? collateralList[0].Original_RC_Details__c : '' : '' : '';
        String manufactureYear = collateralList!=null ?  collateralList.size()>0 ? String.isNotBlank(collateralList[0].Manufacture_Year__c) ? collateralList[0].Manufacture_Year__c : '' : '' : '';
        List < Address__c > addressLst = new List<Address__c>();
        if( getApplicantAddress(applicantList[0].Id)!=null){
            addressLst = getApplicantAddress(applicantList[0].Id);
        }
        String addressline1 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_1__c != null ? addressLst[0].Address_Line_1__c : '' : '';
        String addressline2 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_2__c != null ? addressLst[0].Address_Line_2__c : '' : '';
        String addressline3 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_3__c != null ? addressLst[0].Address_Line_3__c : '' : '';
        valuationWrapper wrapper = getValuationDetails(loanDetails[0].Id);
        List < Valuation__c > valuationList = wrapper != null ? wrapper.valuationList != null ? wrapper.valuationList : null : null;
        String valuationContactPerson = wrapper != null ? wrapper.valuationList != null ? valuationList[0].Coordinate_for_valuation_POC__c != null ? valuationList[0].Coordinate_for_valuation_POC__c : '' : '' : '';
        String valuationContactPhone = wrapper != null ? wrapper.valuationList != null ? valuationList[0].Contact_Person_Mobile_Number__c != null ? valuationList[0].Contact_Person_Mobile_Number__c : '' : '' : '';
        String valuationAmt = wrapper != null ? wrapper.valuationList != null ? valuationList[0].Valuation_Amount__c != null ? String.valueof(valuationList[0].Valuation_Amount__c) : '' : '' : '';
        String valuationRemark = wrapper != null ? wrapper.valuationList != null ? valuationList[0].Final_remarks__c != null ? valuationList[0].Final_remarks__c : '' : '' : '';
        List < AccountTeamMember > accountTeamList = teamMembers.BMList;
        List < AccountTeamMember > teamLeadList = teamMembers.TLList;
        List < AccountTeamMember > fiExecutiveList = teamMembers.FIList;
        List < AccountTeamMember > creditList = teamMembers.CreditList;
        
        String TLName = teamLeadList != null ? teamLeadList[0].User != null ? teamLeadList[0].User.Name != null ? teamLeadList[0].User.Name : '' : '' : '';
        String FIName = fiExecutiveList != null ? fiExecutiveList[0].User != null ? fiExecutiveList[0].User.Name != null ? fiExecutiveList[0].User.Name : '' : '' : '';
        String BMName = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Name != null ? accountTeamList[0].User.Name : '' : '' : '';
        String bmPhone = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.MobilePhone != null ? accountTeamList[0].User.MobilePhone : '' : '' : '';
        String DealerName = loanDetails.size() > 0 ? loanDetails[0].Dealer_Master__c != null ? loanDetails[0].Dealer_Master__r.Name != null ? loanDetails[0].Dealer_Master__r.Name : '' : '' : '';
        String CreditName = creditList != null ? creditList[0].User != null ? creditList[0].User.Name != null ? creditList[0].User.Name : '' : '' : '';
        String branchAddress= teamMembers.branchAddress!=null ? teamMembers.branchAddress :'';
        String rcNo  = String.isNotBlank(rcDetails) ? rcDetails : 'rcDetails';
        //Links 
        String loanURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + loanDetails[0].Id;
        String applink = '<br/>' + loanURL + '&nbsp;';
        String valuationDocLink = wrapper != null ? wrapper.documentURL != null ? wrapper.documentURL : '' : '';
        String valDocLink = valuationDocLink != null ? '<br/>' + valuationDocLink + '&nbsp;' : '';
        String roEmployeeCode = ROName + '_' + empCode;
        
        String documentName = getDocumentName(triggerPoint) != '' ? getDocumentName(triggerPoint) : '';
        String publicURL = '';
        NotificationHandler.fileWrapper fileDetails;
        if (getFileDetails(documentName, loanDetails[0].Id) != null) {
            fileDetails = getFileDetails(documentName, loanDetails[0].Id);
            publicURL = fileDetails.publicURL;
        }
        String documentURL = '<br/>' + publicURL + '&nbsp;';
        String repaymentAccNumber = '';
        if (loanDetails[0].Repayment_Mode__c == 'Standing Instructions') {
            repaymentAccNumber = loanDetails[0].Repayment_Account_Number__c;
        }
   
        
        
        //Recipient's Mapping
        if (strTo == 'RO') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', ROName);
        } else if (strTo == 'BM') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', BMName);
        } else if (strTo == 'TL') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', TLName);
        } else if (strTo == 'Dealer' || strTo == 'channel') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', DealerName);
        } else if (strTo == 'FI EXC' || strTo == 'FI agency') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', FIName);
        } else if (strTo == 'Credit' || strTo == 'CREDIT') {
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', CreditName); //mapping pending
        }
        
        
        
        // Meessage Details Mapping based on the trigger point
        if (triggerPoint == 'Lead Create') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Channel name>', channelName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Lead id>', loanApplicationId);
            
        } else if(triggerPoint == 'Marks Discrepancy' || triggerPoint == 'Resolve Discrepancy') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan Application No>', loanApplicationNo);
        }
        else if (triggerPoint == 'Lead assigned to RO') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<contact number>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<Application ID>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan application no>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<var loan>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<Lead id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            
        } else if (triggerPoint == 'FI Initiation') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer details: Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<link>', applink);
        } else if (triggerPoint == 'FI Query') {
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<APP No>', loanApplicationNo);
        } else if (triggerPoint == 'FI Retrigger') {
            List <Field_Investigation__c> fiRecordList = getFIRetrigger(loanDetails[0].Id);
            String location = (fiRecordList!=null && fiRecordList.size()>0) ?  String.isNotBlank(fiRecordList[0].Area_Name__c) ? fiRecordList[0].Area_Name__c : '':'';
            String addressType = (fiRecordList!=null && fiRecordList.size()>0) ?  String.isNotBlank(fiRecordList[0].Type_of_address__c) ? fiRecordList[0].Type_of_address__c : '':'';
            String address = (fiRecordList!=null && fiRecordList.size()>0) ?  String.isNotBlank(fiRecordList[0].Address__c) ? fiRecordList[0].Address__c : '':'';
            String relation = (fiRecordList!=null && fiRecordList.size()>0) ?  String.isNotBlank(fiRecordList[0].Applicant_Type__c) ? fiRecordList[0].Applicant_Type__c : '':'';
            
            includedLoanMessage = includedLoanMessage.replaceAll('<app no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<FI location>', location);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer details: Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Relation type- Borrower/Co-B/ Gua>', relation);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<ROname>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>',address);
            includedLoanMessage = includedLoanMessage.replaceAll('< Link to FI application>',applink);
            
        } else if (triggerPoint == 'FI Revoke') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Application number>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer details: Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>', addressline1 + ',' + addressline2 + ',' + addressline3);
        } else if (triggerPoint == 'FI Stage Completion') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Application number>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            //includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', ROName);

        } else if (triggerPoint == 'Valuation initiate') {
            String loanApplicatonId = collateralList != null ? collateralList[0].Loan__r.Application_Id__c != null ? collateralList[0].Loan__r.Application_Id__c : '' : '';
            String combinedMsg = valuationContactPerson + '@' + valuationContactPhone;
            
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Vehicle name>', vehicleName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC No.>', rcNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', addressline1 + addressline2 + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<id>', loanApplicatonId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC Number>', rcNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address of valuation>', addressline1 + addressline2 + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Contact name and phone number entered by RO in valuation request>', combinedMsg);
            
        } else if (triggerPoint == 'Other Valuation initiate') {
            String combinedMsg = valuationContactPerson + '@' + valuationContactPhone;
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC No.>', rcNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<MFG year>', manufactureYear);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address of valuation>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Contact name and phone number entered by RO in valuation request>', combinedMsg);
        } else if (triggerPoint == 'Valuation Submission') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<App No.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<valuation amount>', valuationAmt);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC Number>', rcNo);
            
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            
        } else if (triggerPoint == 'Valuation Query') {
            includedLoanMessage = includedLoanMessage.replaceAll('<APP No>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'Valuation Retrigger') { 
            User user =[SELECT id,Username from User where id=:Userinfo.getUserId()];
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<vehicle address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Valuation address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Value of vehicle>',valuationAmt );
            includedLoanMessage = includedLoanMessage.replaceAll('<valuationRemark>',valuationRemark );
            includedLoanMessage = includedLoanMessage.replaceAll('<re trigger remark>',valuationRemark );
            includedLoanMessage = includedLoanMessage.replaceAll('<re trigger raiser designation>',user.Username );
            
           
        } else if (triggerPoint == 'Valuation Revoke') {
            User user =[SELECT id,Username from User where id=:Userinfo.getUserId()];
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Address of valuation>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<Valuation address>', addressline1 + ',' + addressline2 + ',' + addressline3);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC no.>', rcNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<MFG year>', manufactureYear);
            includedLoanMessage = includedLoanMessage.replaceAll('<Valuation revoke remark>', valuationRemark);
            includedLoanMessage = includedLoanMessage.replaceAll('<revoke raiser designation>',user.Username );
        } else if (triggerPoint == 'Trigger Approval') {
            includedLoanMessage = includedLoanMessage.replaceAll('<APP No>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<channel/RO/Branch/dealer names >', ROName);
        } else if (triggerPoint == 'DDE Submission') {
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Application ID>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<contact number>', ROPhone);
        } else if (triggerPoint == 'if Case under STP') {
            includedLoanMessage = includedLoanMessage.replaceAll('<app no>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan amount>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<contact number>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link>',applink );
            
        } else if (triggerPoint == 'AML REVERT') {
            includedLoanMessage = includedLoanMessage.replaceAll('< Application id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('link',applink );
            
        } else if (triggerPoint == 'Pricing Approval') {
            //List < Loan_Application__c > loanDetails = getLoanDetais(loanApplicationId);
            String loanApplication = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
            
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan var>', loanApplication);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<varamount>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<app id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('link',applink );
            
           
        } else if (triggerPoint == 'Case Rejection') {
            String rejectionReason = loanDetails[0].Rejection_Reason__c != null ? loanDetails[0].Rejection_Reason__c : '';
            String managerName = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Name : '' : '';
            String managerContact = accountTeamList != null ? accountTeamList[0].User.Phone != null ? accountTeamList[0].User.Phone : '' : '';
            String authority = loanStage+' '+'authority';
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<reason for rejection>', rejectionReason);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM name>', managerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact details>', managerContact);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            String combinedMsg = managerName + managerContact + ROName + ROPhone;
            includedLoanMessage = includedLoanMessage.replaceAll('<Name and contact numbers of BM & RO>', combinedMsg);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name_EMployee code>', roEmployeeCode);
            includedLoanMessage = includedLoanMessage.replaceAll('<Remark of rejection>', rejectionReason);
            includedLoanMessage = includedLoanMessage.replaceAll('<Rejection authority>', authority);
            includedLoanMessage = includedLoanMessage.replaceAll('< dealer name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            
        } else if (triggerPoint == 'DO generation') {
            Date doGeneration = collateralList != null ? collateralList[0].DO_Generation_Date__c != null ? collateralList[0].DO_Generation_Date__c : null : null;
            
            includedLoanMessage = includedLoanMessage.replaceAll('<make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Vehicle details-Make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Dealer name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<dealer name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan Number>', loanApplicationNo);
            if(doGeneration!=null){
                includedLoanMessage = includedLoanMessage.replaceAll('<DO generation date>', string.valueof(doGeneration));
                includedLoanMessage = includedLoanMessage.replaceAll('<Date of do generation>', string.valueof(doGeneration));
            }
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink); //documentURL
            
        } else if (triggerPoint == 'DO Cancellation') {
            Date doGeneration = collateralList != null ? collateralList[0].DO_Generation_Date__c != null ? collateralList[0].DO_Generation_Date__c : null : null;
            String rejectionReason = collateralList != null ? collateralList[0].Loan__r.Rejection_Reason__c != null ? collateralList[0].Loan__r.Rejection_Reason__c : '' : '';
            String managerName = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Name : '' : '';
            String managerContact = accountTeamList != null ? accountTeamList[0].User.Phone != null ? accountTeamList[0].User.Phone : '' : '';
            if(String.isBlank(managerContact)){
                managerContact = '1800 1200 1200';
            }
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            if(doGeneration!=null){
              includedLoanMessage = includedLoanMessage.replaceAll('<Date of do generation>', string.valueof(doGeneration));  
            }
            includedLoanMessage = includedLoanMessage.replaceAll('<make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<MNV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<dealer name>', dealerName);  
            includedLoanMessage = includedLoanMessage.replaceAll('<BM name>', managerName);//managerName
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact number>', managerContact);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<date>',doGeneration != null ? String.valueof(doGeneration) : '');//doGeneration != null ? String.valueof(doGeneration) : ''
            includedLoanMessage = includedLoanMessage.replaceAll('< no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<reason>', doCancelReason);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cancellation remark>', doCancelReason);

            String combinedMsg = managerName + managerContact + ROName + ROPhone;
            includedLoanMessage = includedLoanMessage.replaceAll('<user who canceled the DO>', managerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Name and contact numbers of BM & RO>', combinedMsg);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name_Employee coee>', roEmployeeCode);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact no.>', managerContact);//managerContact
            includedLoanMessage = includedLoanMessage.replaceAll('<product>', productName);
            
        } else if (triggerPoint == 'Ops submission') {
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<contact no.>', ROPhone);
        } else if (triggerPoint == 'E-mandate/eNach' || triggerPoint == 'Bank account validation for auto payment') {
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('< Product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', ROPhone);
            
        } else if (triggerPoint == 'PDD stage') {
            includedLoanMessage = includedLoanMessage.replaceAll('<App no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan account no>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('< MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('< link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);

        } else if (triggerPoint == 'PDD Pending') {
            pddDocumentsWrapper documentWrapper = getPDDPendingDocs(collateralList[0].Id);
            String pendingDocumentName = documentWrapper != null ? documentWrapper.pendingDocs != null ?  documentWrapper.pendingDocs :'':'';
            String completedDocumentName = documentWrapper != null ? documentWrapper.completedDocs != null ?  documentWrapper.completedDocs :'':'';
            Date doGeneration = collateralList != null ? collateralList[0].DO_Generation_Date__c != null ? collateralList[0].DO_Generation_Date__c : null : null;
        
            includedLoanMessage = includedLoanMessage.replaceAll('<product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<dealer name>', dealerName);  
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<App no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RC, Insurance>', rcDetails);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan number>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<list of completed documents>', completedDocumentName);
            includedLoanMessage = includedLoanMessage.replaceAll('<list of pending documents>', pendingDocumentName);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
            if(doGeneration!=null){
                includedLoanMessage = includedLoanMessage.replaceAll('<date of DO generation/ date of disbursement>', string.valueof(doGeneration));
                includedLoanMessage = includedLoanMessage.replaceAll('<Date of do generation>', string.valueof(doGeneration));
            }
            
        } else if (triggerPoint == 'PDD COMPLETION') {
            includedLoanMessage = includedLoanMessage.replaceAll('< dealer name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('< App no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust. Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('< app id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
            
        } else if (triggerPoint == 'PDD Rejection') {
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust. Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('< Loan no>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM/RO>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM/RO contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
        } else if (triggerPoint == 'ON loan sanction') {
            includedLoanMessage = includedLoanMessage.replaceAll('<app no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<vehicle details- Make, Model, variant>', vehicleName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan amount>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<Tenure in months>', String.valueof(tenure));
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Corresponding contact number>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Application id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Application ID>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('link', documentURL);
        } else if (triggerPoint == 'Partial Disbursment') {
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<amt>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Ro contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<App id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('< App id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Application ID>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<date>', String.valueof(System.today()));
            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
        } else if (triggerPoint == 'Email id verification Initiation') {
            //  List < Loan_Application__c > loanDetails = getLoanDetais(loanApplicationId);
            String loanApplication = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
            // String loanApplicationNo = loanDetails[0].Application_Number__c != null ? loanDetails[0].Application_Number__c : '';
            
            includedLoanMessage = includedLoanMessage.replaceAll('<loan var>', loanApplication);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanApplicationNo);
            
        } else if (triggerPoint == 'RTO Agent Trigger') {
            List < Deferral_Register__c > deferralRegisters = [SELECT Id FROM Deferral_Register__c Where Collateral__c =: collateralList[0].Id AND Confirmation_Recieved__c != 'Yes'];
            Site mySite = [select Id from Site where Name = 'RTO_Agent'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId =: mySite.Id];
            includedLoanMessage = includedLoanMessage.replaceAll('<baseURL>', mySiteDetail.SecureURL);
            if(!deferralRegisters.isEmpty()){
                includedLoanMessage = includedLoanMessage.replaceAll('<reqId>', deferralRegisters[0].Id);
            }
            
        } else if (triggerPoint == 'Generation of OTP') {
            // String firstName = applicantList[0].First_Name__c != null ? applicantList[0].First_Name__c : '';
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            
        } else if (triggerPoint == 'On succesfull OTP verification') {
            // String firstName = applicantList[0].First_Name__c != null ? applicantList[0].First_Name__c : '';
            String loanApplication = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('< ID no>', loanApplication);
            
        } else if (triggerPoint == 'Email id verification' || triggerPoint == 'Successful Email id verification') {
            
            String loanApplication = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
            
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<App id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan var>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanApplication);
        } else if (triggerPoint == 'Cross sale') {
            
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('< Product name> ', productName);
            
            
        } else if (triggerPoint == 'ON Disbursement') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<vehicle name>', vehicleName);
            includedLoanMessage = includedLoanMessage.replaceAll('< Application id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<dealer name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('< BM name>', BMName);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact number>', bmPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO Name_RO employee code>', roEmployeeCode);
            includedLoanMessage = includedLoanMessage.replaceAll('<product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<name of bank loan disbursed>', 'AU Bank');
            string cmbMsg = applink + 'to view the application';
            includedLoanMessage = includedLoanMessage.replaceAll('to view the application', cmbMsg);
        } else if (triggerPoint == 'Payment release' || triggerPoint =='Disbursement Customer') {
            List<Payment__c> paymentRecord =  getPayment(loanDetails[0].Id);
            String utrNumber = (paymentRecord!=null && paymentRecord.size()>0) ?  String.isNotBlank(paymentRecord[0].UTR_Number__c) ? paymentRecord[0].UTR_Number__c : '':'';
            String paymentMode = (paymentRecord!=null && paymentRecord.size()>0) ?  String.isNotBlank(paymentRecord[0].Payment_Mode__c) ? paymentRecord[0].Payment_Mode__c : '':'';
            String bankName = (paymentRecord!=null && paymentRecord.size()>0) ?  String.isNotBlank(paymentRecord[0].Bank_Name_PMT__c) ? paymentRecord[0].Bank_Name_PMT__c : '':'';
            String paymentRecepientName = (paymentRecord!=null && paymentRecord.size()>0) ?  String.isNotBlank(paymentRecord[0].Payment_Recipient__c) ? paymentRecord[0].Payment_Recipient__c : '':'';
            String paymentAccountNo = (paymentRecord!=null && paymentRecord.size()>0) ?  String.isNotBlank(paymentRecord[0].Account_Number__c) ? paymentRecord[0].Account_Number__c : '':'';
            String combinedMsg = ROName + '_' + empCode;
            
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<vehicle name>', vehicleName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<LAN>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('< Application id>', loanApplicationId);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO NAME_Employee id>', combinedMsg);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<disbursed amt.>', loanAmount); // 29 AUG
            includedLoanMessage = includedLoanMessage.replaceAll('<UTR number>', utrNumber); 
            includedLoanMessage = includedLoanMessage.replaceAll('<Recipient bank name>', bankName); 
            includedLoanMessage = includedLoanMessage.replaceAll('<payment type>', paymentMode); 
            includedLoanMessage = includedLoanMessage.replaceAll('<dealer/Channel name>', dealerName); 
            includedLoanMessage = includedLoanMessage.replaceAll('<RO NAME_Employee id>', combinedMsg); 
            includedLoanMessage = includedLoanMessage.replaceAll('<xxx>', paymentAccountNo); 
            includedLoanMessage = includedLoanMessage.replaceAll('{var}', ROPhone); 
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            if(paymentRecepientName == 'Dealer'){
                includedLoanMessage = includedLoanMessage.replaceAll('<payment recipient name>', dealerName);
                includedLoanMessage = includedLoanMessage.replaceAll('<Payment recipient name name>', dealerName);
            }else if(paymentRecepientName == 'Customer'){
                includedLoanMessage = includedLoanMessage.replaceAll('<payment recipient name>', customerName);
                includedLoanMessage = includedLoanMessage.replaceAll('<Payment recipient name name>', customerName);
            }
            
            
        } else if (triggerPoint == 'eNach activation') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
        } else if (triggerPoint == 'SI intiation' || triggerPoint == 'SI activation') {
            String managerName = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Name : '' : '';
            String managerContact = accountTeamList != null ? accountTeamList[0].User.Phone != null ? accountTeamList[0].User.Phone : '' : '';
            includedLoanMessage = includedLoanMessage.replaceAll('<BM name>', managerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact number>', managerContact);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<acc number>', repaymentAccNumber);
            includedLoanMessage = includedLoanMessage.replaceAll('< Product name>', productName);
            
        } else if (triggerPoint == 'E-sign initiation') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<app no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO contact no.>', ROPhone);
        } else if (triggerPoint == 'E sign') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<app no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('< Product name>', productName);
            includedLoanMessage = includedLoanMessage.replaceAll('<make model variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO Name_RO employee code>', roEmployeeCode);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name_RO employee code>', roEmployeeCode);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
        } else if (triggerPoint == 'Deemed KYC') {
            includedLoanMessage = includedLoanMessage.replaceAll('<cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust id>', cifNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('< link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust id>', cifNo);
            
        } else if (triggerPoint == 'KYC approval flow') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Cust name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<App name>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('< link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<Branch Name>', branch);
            
            
        } else if (triggerPoint == 'RC Pending' || triggerPoint == 'Insurance Pending') {
            
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<COM/ RO name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<COM/RO contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<link>', applink);
           
        } else if (triggerPoint == 'ON vehicle delivery') {
            //  String dealerName = loanDetails[0].Dealer_Master__c != null ? loanDetails[0].Dealer_Master__r.Name : '';
            String place = loanDetails[0].Dealer_Master__c != null ? loanDetails[0].Dealer_Master__r.City__c != null ? loanDetails[0].Dealer_Master__r.City__c : '' : '';
            String managerName = accountTeamList != null ? accountTeamList[0].User != null ? accountTeamList[0].User.Name : '' : '';
            String managerContact = accountTeamList != null ? accountTeamList[0].User.Phone != null ? accountTeamList[0].User.Phone : '' : '';
            
            includedLoanMessage = includedLoanMessage.replaceAll('<BM name>', managerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<BM contact number>', managerContact);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<vehicle name - make model - variant>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<name>', dealerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<place>', place);
            
        } else if (triggerPoint == 'Welcome letter (NEW)' || triggerPoint == 'Welcome letter (USED)' || triggerPoint == 'Welcome letter (COW)') {
            String welcomeLetterUrl = getWelcomeLetter(loanDetails[0].Id);
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', loanType);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan A/C No.>', loanApplicationNo);
            includedLoanMessage = includedLoanMessage.replaceAll('<Loan Amount>', loanAmount);
            includedLoanMessage = includedLoanMessage.replaceAll('<Tenure>', tenure);
            includedLoanMessage = includedLoanMessage.replaceAll('<EMI Amount>', loanEmi);
            includedLoanMessage = includedLoanMessage.replaceAll('<First EMI Date>', loanFirstEmi);
            includedLoanMessage = includedLoanMessage.replaceAll('< Branch address>', branchAddress);
            if(String.isNotBlank(loanDetails[0].Repayment_Mode__c)){
                includedLoanMessage = includedLoanMessage.replaceAll('<SI, E-mandate, eNach>', loanDetails[0].Repayment_Mode__c);
            }
            includedLoanMessage = includedLoanMessage.replaceAll('<link>', welcomeLetterUrl);
            
        } else if (triggerPoint == 'Before 1st due date') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
        } else if (triggerPoint == 'ON generation of Customer CIBIL') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer first name>', firstName);
            includedLoanMessage = includedLoanMessage.replaceAll('<var>', score);
        } else if (triggerPoint == 'Credit Submission(L0)' || triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)'  || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)' || triggerPoint =='Credit Sanction') {
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust. Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<app no>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO Name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<Ph no>', ROPhone);
            
        }else if(triggerPoint  == 'Credit Manual assignment'){
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<link>', applink);
        }
        
        else if( triggerPoint == 'Credit sendback' || triggerPoint =='Pricing send back'){ // Added by SFAU-2567 Start
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('link', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM name>', ROName);
            includedLoanMessage = includedLoanMessage.replaceAll('<RO/BM contact no.>', ROPhone);
            includedLoanMessage = includedLoanMessage.replaceAll('<cust. Name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<loan no.>', loanApplicationNo);
            if(loanDetails[0]!=null && loanDetails.size()>0){
                List<Loan_Application_Approval__c> loanApprovalList = [SELECT id,Name,Type__c,Approver__r.Name,Approver_Level__c,Approval_Type__c,Loan_Application__c,Remarks__c FROM Loan_Application_Approval__c WHERE Loan_Application__c=:loanDetails[0].Id  ORDER BY CreatedDate DESC];
                if(loanApprovalList!=null && loanApprovalList.size()>0){
                    for(Loan_Application_Approval__c approval : loanApprovalList){
                        String remark = approval.Remarks__c != null ? approval.Remarks__c : '';
                        if(String.isNotBlank(remark)){
                            includedLoanMessage = includedLoanMessage.replaceAll('<Credit remark>', remark);
                            if( approval.Approver__r.Name!=null){
                                includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>',  approval.Approver__r.Name+'_'+empCode);
                            }
                        }
                    }
                }
            }    
        } //END 
         else if(triggerPoint == 'Disbursement Addendum'){
            includedLoanMessage = includedLoanMessage.replaceAll('<Application_Id__c>', loanApplicationNo);
        }
        else if(triggerPoint == 'Disbursement Addendum Complete'){
            includedLoanMessage = includedLoanMessage.replaceAll('<Application_Id__c>', loanApplicationNo);
        }
        else if(triggerPoint == 'Stage Movement Trigger'){
            includedLoanMessage = includedLoanMessage.replaceAll('<Customer name>', customerName);
            includedLoanMessage = includedLoanMessage.replaceAll('<stage it has been moved to>', loanStage);
            includedLoanMessage = includedLoanMessage.replaceAll('<Link to application>', applink);
            includedLoanMessage = includedLoanMessage.replaceAll('<MMV>', mmv);
            includedLoanMessage = includedLoanMessage.replaceAll('<Product name>', productName);
        }
        
        
        
        return includedLoanMessage;
    }
    
    
    public static string getEmailSubjectMapping(String triggerPoint, List < Loan_Application__c > loanDetails, List < Collateral__c > collateralList, List < Applicant__c > applicantList, String subMessage) {
        String loanApplicationNo = loanDetails[0].Name != null ? loanDetails[0].Name : '';
        String loanApplicationId = loanDetails[0].Application_Id__c != null ? loanDetails[0].Application_Id__c : '';
        String mmv = collateralList != null ? collateralList[0].Variant__c != null ? collateralList[0].Variant__c : '' : '';
        String ROName = loanDetails[0].Owner.Name != null ? loanDetails[0].Owner.Name : '';
        String empCode = loanDetails[0].Owner_code__c != null ? loanDetails[0].Owner_code__c : '';
        String customerName = applicantList[0].Customer_Name__c != null ? applicantList[0].Customer_Name__c : '';
        String vehicleName = collateralList != null ? collateralList[0].Variant__c != null ? collateralList[0].Variant__c : '' : '';
        String rcDetails = collateralList != null ? collateralList[0].Original_RC_Details__c != null ? collateralList[0].Original_RC_Details__c : '' : '';
        String productName = (loanDetails[0].Product__c) != null ? loanDetails[0].Product__c : '';
        String applId = applicantList[0].Id != null ? applicantList[0].Id : '';
        String DealerName = loanDetails.size() > 0 ? loanDetails[0].Dealer_Master__c != null ? loanDetails[0].Dealer_Master__r.Name != null ? loanDetails[0].Dealer_Master__r.Name : '' : '' : '';
        
        if (triggerPoint == 'Lead assigned to RO') {
            subMessage = subMessage.replaceAll('<RO name>', ROName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<Lead id>', loanApplicationId);
        } else if (triggerPoint == 'FI Initiation') {
            subMessage = subMessage.replaceAll('<customer name>', customerName);
        } else if (triggerPoint == 'FI Revoke') {
            subMessage = subMessage.replaceAll('<cust name>', customerName);
        }else if (triggerPoint == 'FI Retrigger') {
            List <Field_Investigation__c> fiRecordList = getFIRetrigger(loanDetails[0].Id);
            String location = (fiRecordList!=null && fiRecordList.size()>0) ?  String.isNotBlank(fiRecordList[0].Area_Name__c) ? fiRecordList[0].Area_Name__c : '':'';
            subMessage = subMessage.replaceAll('<location>', location);
        } else if (triggerPoint == 'FI Stage Completion') {
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'eNach activation') {
            subMessage = subMessage.replaceAll('<app no.>', loanApplicationNo);
        } else if (triggerPoint == 'SI intiation' || triggerPoint == 'SI activation' || triggerPoint == 'Before 1st due date') {
            subMessage = subMessage.replaceAll('<loan no.>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'Email id verification' || triggerPoint == 'Successful Email id verification') {
            subMessage = subMessage.replaceAll('<var>', loanApplicationNo);
        } else if (triggerPoint == 'Valuation initiate') {
            List<Address__c> addressLst = new List<Address__c>();
            if( getApplicantAddress(applicantList[0].Id)!=null){
                addressLst = getApplicantAddress(applicantList[0].Id);
            }
            String addressline1 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_1__c != null ? addressLst[0].Address_Line_1__c : '' : '';
            String addressline2 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_2__c != null ? addressLst[0].Address_Line_2__c : '' : '';
            String addressline3 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_3__c != null ? addressLst[0].Address_Line_3__c : '' : '';
            subMessage = subMessage.replaceAll('<Vehicle name>', vehicleName);
            subMessage = subMessage.replaceAll('<RC No.>', rcDetails);
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<valuation location>', addressline1 + ',' + addressline2 + ',' + addressline3);
        } else if (triggerPoint == 'Other Valuation initiate') {
            List<Address__c> addressLst = new List<Address__c>();
            if( getApplicantAddress(applicantList[0].Id)!=null){
                addressLst = getApplicantAddress(applicantList[0].Id);
            }
            String addressline1 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_1__c != null ? addressLst[0].Address_Line_1__c : '' : '';
            String addressline2 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_2__c != null ? addressLst[0].Address_Line_2__c : '' : '';
            String addressline3 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_3__c != null ? addressLst[0].Address_Line_3__c : '' : '';
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<valuation location>', addressline1 + ',' + addressline2 + ',' + addressline3);
        } else if (triggerPoint == 'Valuation Submission' || triggerPoint == 'Valuation Retrigger' || triggerPoint == 'Valuation Revoke') {
            User user =[SELECT id,Username from User where id=:Userinfo.getUserId()];
            List<Address__c> addressLst = new List<Address__c>();
            if( getApplicantAddress(applicantList[0].Id)!=null){
                addressLst = getApplicantAddress(applicantList[0].Id);
            }
            String addressline1 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_1__c != null ? addressLst[0].Address_Line_1__c : '' : '';
            String addressline2 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_2__c != null ? addressLst[0].Address_Line_2__c : '' : '';
            String addressline3 = (addressLst != null &&  addressLst.size()>0 ) ? addressLst[0].Address_Line_3__c != null ? addressLst[0].Address_Line_3__c : '' : '';
            valuationWrapper wrapper = getValuationDetails(loanDetails[0].Id);
            List < Valuation__c > valuationList = wrapper.valuationList;
            String valuationAmount = valuationList[0].Valuation_Amount__c != null ? String.valueof(valuationList[0].Valuation_Amount__c) : '';
            String valuationRemark = wrapper != null ? wrapper.valuationList != null ? valuationList[0].Final_remarks__c != null ? valuationList[0].Final_remarks__c : '' : '' : '';
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<RC Number>', rcDetails);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<Value in valuation report>', valuationAmount);
            subMessage = subMessage.replaceAll('<valuation location>', addressline1 + ',' + addressline2 + ',' + addressline3);
            subMessage = subMessage.replaceAll('<re trigger remark>',valuationRemark );
            subMessage = subMessage.replaceAll('<re trigger raiser designation>',user.Username );
            subMessage = subMessage.replaceAll('<revoke raiser designation>',user.Username );
            
        } else if (triggerPoint == 'Trigger Approval') {
            subMessage = subMessage.replaceAll('<branch, RO,Dealer>', ROName);
        } else if (triggerPoint == 'DDE Submission') {
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'if Case under STP') {
            String combinedMsg = ROName + '_' + empCode;
            subMessage = subMessage.replaceAll('<RO name>', ROName);
            subMessage = subMessage.replaceAll('<RO name_ emp code>', combinedMsg);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<App name>', loanApplicationNo);
        } else if (triggerPoint == 'AML REVERT') {
            subMessage = subMessage.replaceAll('<cust name>', customerName);
        } else if (triggerPoint == 'ON Disbursement' || triggerPoint == 'Payment release' || triggerPoint == 'Case Rejection' || triggerPoint == 'DO generation' || triggerPoint == 'DO Cancellation' || triggerPoint == 'E-mandate/eNach' || triggerPoint == 'Bank account validation for auto payment') {
            subMessage = subMessage.replaceAll('<var>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<Customer name>', customerName);
            subMessage = subMessage.replaceAll('<Cust. Name>', customerName);
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<product>', productName);
            subMessage = subMessage.replaceAll('<Product>', productName);
            subMessage = subMessage.replaceAll('<app no.>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<payment recipient name>', DealerName);
            subMessage = subMessage.replaceAll('<dealer name>', DealerName);
            
        } else if (triggerPoint == 'E-sign initiation' || triggerPoint == 'E sign') {
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<app no.>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'RC Pending' || triggerPoint == 'Insurance Pending' || triggerPoint == 'PDD COMPLETION' || triggerPoint == 'PDD Rejection' || triggerPoint == 'ON loan sanction' || triggerPoint == 'ON vehicle delivery' || triggerPoint == 'Welcome letter (USED)' || triggerPoint == 'Welcome letter (COW)') {
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<Cust. Name>', customerName);
            subMessage = subMessage.replaceAll('<var>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<product>', productName);
        } else if (triggerPoint == 'Ops submission' || triggerPoint == 'Deemed KYC') {
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<Customer name>', customerName);
        } else if (triggerPoint == 'KYC approval flow') {
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<Product>', productName);
            subMessage = subMessage.replaceAll('<App id>', loanApplicationId);
        } else if (triggerPoint == 'PDD stage' || triggerPoint == 'PDD Pending') {
            pddDocumentsWrapper documentWrapper = getPDDPendingDocs(collateralList[0].Id);
            String pendingDocumentName = documentWrapper != null ? documentWrapper.pendingDocs != null ?  documentWrapper.pendingDocs :'':'';
            String completedDocumentName = documentWrapper != null ? documentWrapper.completedDocs != null ?  documentWrapper.completedDocs :'':'';
        
            subMessage = subMessage.replaceAll('<Customer name>', customerName);
            subMessage = subMessage.replaceAll('<Cust name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<list of pending documents>', pendingDocumentName);
        } else if (triggerPoint == 'Partial Disbursment') {
            subMessage = subMessage.replaceAll('<customer name>', customerName);
            subMessage = subMessage.replaceAll('<Cust name>', customerName);
            subMessage = subMessage.replaceAll('<cust name>', customerName);
            subMessage = subMessage.replaceAll('<recepient name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
        } else if (triggerPoint == 'Credit Submission(L0)' || triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)' || triggerPoint == 'Credit sendback' || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)' || triggerPoint == 'Pricing send back' || triggerPoint == 'Credit Sanction' || triggerPoint == 'Pricing Approval') {
            if(String.isNotBlank(customerName)){
                subMessage = subMessage.replaceAll('<cust. Name>', customerName);
                subMessage = subMessage.replaceAll('<Customer name>', customerName);
                subMessage = subMessage.replaceAll('<customer name>', customerName);
                subMessage = subMessage.replaceAll('<Cust name>', customerName);
            }
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<App no.>', loanApplicationNo);
            subMessage = subMessage.replaceAll('<app no>', loanApplicationNo);
            
        }else if(triggerPoint  == 'Credit Manual assignment'){
            subMessage = subMessage.replaceAll('<cust. Name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<App no.>', loanApplicationNo);
        }else if(triggerPoint == 'Stage Movement Trigger'){
            subMessage = subMessage.replaceAll('<Cust. Name>', customerName);
            subMessage = subMessage.replaceAll('<MMV>', mmv);
            subMessage = subMessage.replaceAll('<product>', productName);
        }
        
        return subMessage;
    }
    
    //Method to get the document name based on the trigger point
    public static String getDocumentName(String triggerPoint) {
        try {
            String documentName = '';
            if (triggerPoint == 'DO generation') {
                documentName = 'Delivery Order';
            } else if (triggerPoint == 'DO Cancellation') {
                documentName = 'DO Cancelled letter';
            } else if (triggerPoint == 'ON loan sanction') {
                documentName = 'Sanction letter';
            }
            else if (triggerPoint == 'Case Rejection') {
                documentName = 'Rejection letter';
            }
            return documentName;
        } catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),null);
            return null;
        }
    }
    
    public static  List<Payment__c> getPayment(String loanId){
        List<Payment__c> paymentRecordList = [SELECT id,UTR_Number__c,Beneficiary_Name__c,Bank_Name_PMT__c,Payment_Mode__c,Payment_Recipient__c,Loan_Application__c,Account_Number__c
                                              FROM Payment__c
                                              WHERE Loan_Application__c =:loanId
                                              ORDER BY CreatedDate DESC 
                                              LIMIT 1];

        if(paymentRecordList!=null && paymentRecordList.size()>0 && !paymentRecordList.isEmpty() ){
            return paymentRecordList;
        }else{
            return null;
        }
    }

    public static  List<Field_Investigation__c> getFIRetrigger(String loanId){
        List<Field_Investigation__c> fieldRecordList = [SELECT id,Loan_Application__c, Re_Trigger__c,CreatedDate,Type_of_address__c ,Area_Name__c,Address__c,Applicant_Type__c 
                                              FROM Field_Investigation__c 
                                              WHERE Re_Trigger__c =true 
                                              AND Loan_Application__c =:loanId
                                              ORDER BY CreatedDate DESC 
                                              LIMIT 1];

        if(fieldRecordList!=null && fieldRecordList.size()>0 && !fieldRecordList.isEmpty() ){
            return fieldRecordList;
        }else{
            return null;
        }
    }

    //Method to get the File Details based on document name and loan application id from the document checklist 
    public static NotificationHandler.fileWrapper getFileDetails(String documentName, String loanApplicationId) {
        fileWrapper wrapperInstance = new fileWrapper();
        try {
            if(String.isBlank(documentName)){
                return null;
            }
            List < Document_Checklist__c > documentList = [SELECT id, Loan_Application__c, Document_Master__r.Document_Name__c, Document_Name__c, (SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1)
                                                           FROM Document_Checklist__c
                                                           WHERE Loan_Application__c =: loanApplicationId
                                                           AND(Document_Name__c =: documentName OR Document_Master__r.Document_Name__c =: documentName)
                                                           ORDER BY CreatedDate DESC LIMIT 1
                                                          ];
            
            
            String contentDocumentId;
            String base64Data = '';
            if (documentList != null && documentList.size() > 0 && !documentList.isEmpty()) {
                if (!(documentList[0].ContentDocumentLinks).isEmpty()) {
                    contentDocumentId = documentList[0].ContentDocumentLinks[0].ContentDocumentId;
                }
            }
            
            
            if (String.isNotBlank(contentDocumentId)) {
                ContentVersion cv = [SELECT VersionData, Shortend_Public_Url__c
                                     FROM ContentVersion
                                     WHERE ContentDocumentId =: contentDocumentId
                                     ORDER BY CreatedDate DESC LIMIT 1
                                    ];
                
                
                base64Data = EncodingUtil.base64Encode(cv.VersionData);
                
                wrapperInstance.baseData = base64Data != null ? base64Data : '';
                //wrapperInstance.publicURL = cv.Shortend_Public_Url__c != null ? cv.Shortend_Public_Url__c : '';
                
                if (String.isNotBlank(contentDocumentId)) {
                    List<ContentDistribution> ContentDistributionList = [SELECT DistributionPublicUrl 
                                                                         FROM ContentDistribution
                                                                         WHERE ContentDocumentId = :contentDocumentId  ORDER BY CreatedDate DESC LIMIT 1];
                    if(ContentDistributionList.size()>0){
                        wrapperInstance.publicURL = ContentDistributionList[0].DistributionPublicUrl != null ?  ContentDistributionList[0].DistributionPublicUrl : '';
                    }
                    
                }
                
            }
            
            return wrapperInstance;
        } catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanApplicationId);
            return null;
        }
    }
    
    public static List < Address__c > getApplicantAddress(String applicantId) {
        //Removed WITH SECURITY_ENFORCED as this class is getting called by multiple places and multiple personas and they might not be having access to it 
        List < Address__c > addressList  = new List< Address__c>();
        if(applicantId!=null){
            addressList = [SELECT id, Name, Distance_from_Branch__c, Address_Type__c, Applicant__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c, Area_Name__c, Area_Type__c, Taluka__c, Pincode__c, Land_mark__c, Product__c, Stability__c, Status__c, Address_Source__c, Type__c
                           FROM Address__c
                           WHERE Applicant__c =: applicantId
                           AND Address_Type__c = 'Permanent'
                           AND Source_Type__c != 'Cibil'
                           
                          ];
        }
        
        if(addressList!=null && addressList.size()>0 ){
            return addressList;
        }else{
            return null;
        }
        
        
        // return addressList;
    }
    
     public static string getApproverMessage(String record, String triggerPoint,String includedLoanMessage,String loanId) {
        // String includedLoanMessage;
       /* if (String.isNotBlank(record)) {
            List < Loan_Application_Approval__c > approvalList = (List < Loan_Application_Approval__c > ) JSON.deserialize(record, List < Loan_Application_Approval__c > .class);
            System.debug('approvalList-->' +approvalList);
            Boolean isBase, isMiddle, isHighest = false;
            Map < String, String > ApproverNameMap = new Map < String, String > ();
            Map < String, String > ApproverLevelMap = new Map < String, String > ();
            if (!approvalList.isEmpty()) {
                for (Loan_Application_Approval__c approvalInstance: approvalList) {
                    String remark = approvalInstance.Remarks__c != null ? approvalInstance.Remarks__c : '';
                    if(String.isNotBlank(remark)){
                        includedLoanMessage = includedLoanMessage.replaceAll('<Credit remark>', remark);
                    }
                    
                    if(String.isNotBlank(approvalInstance.Type__c)){
                        if (approvalInstance.Type__c == 'Base') {
                            isBase = true;
                        }
                        if (approvalInstance.Type__c == 'Middle') {
                            isMiddle = true;
                        }
                        if (approvalInstance.Type__c == 'Highest') {
                            isHighest = true;
                        }
                        
                        
                        ApproverNameMap.put(approvalInstance.Type__c, approvalInstance.Approver__r.Name);
                        //ApproverLevelMap.put(approvalInstance.Type__c, approvalInstance.Approver_Level__c);
                        ApproverLevelMap.put(approvalInstance.Type__c, 'L2');
                    }
                }
                
                System.debug('isBase-->' +isBase);
                System.debug('isMiddle-->' +isMiddle);
                System.debug('ApproverNameMap-->' +ApproverNameMap);
                System.debug('ApproverLevelMap-->' +ApproverLevelMap);
                
                if (isBase == true && isMiddle == true) {
                    if( ApproverLevelMap.get('Base')!=null && ApproverNameMap.get('Middle')!=null){
                        includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', ApproverLevelMap.get('Base'));
                        includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>', ApproverNameMap.get('Base'));
                        includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', ApproverNameMap.get('Base'));
                        includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', ApproverLevelMap.get('Middle'));
                        includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>', ApproverNameMap.get('Middle'));
                    }
                    
                } else if (isMiddle == true && isHighest == true) {
                    if(ApproverLevelMap.get('Middle')!=null && ApproverLevelMap.get('Highest')!=null){
                        includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', ApproverLevelMap.get('Middle'));
                        includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', ApproverLevelMap.get('Highest'));
                        
                    }
                    if(ApproverNameMap.get('Highest')!=null && ApproverNameMap.get('Middle')!=null){
                    includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>', ApproverNameMap.get('Highest'));
                    includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>', ApproverNameMap.get('Middle'));
                     includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', ApproverNameMap.get('Middle'));
                    }
                        
                    
                }
                
                //Receipient Mapping
                if ( triggerPoint == 'Credit Submission(L0)' ||  triggerPoint == 'Credit Submission (N-1)' || triggerPoint == 'Credit Submission (N)' || triggerPoint =='Pricing (N-1)' || triggerPoint == 'Pricing (N)') {
                    if (isBase == true && isMiddle == true) {
                        if(ApproverNameMap.get('Middle')!=null){
                            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', ApproverNameMap.get('Middle')); 
                        }
                        
                    }else if (isMiddle == true && isHighest == true) {  
                        if(ApproverNameMap.get('Highest')!=null){
                            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', ApproverNameMap.get('Highest')); 
                        }
                    }
                }
                
                
            }
        }*/
        Map < String, String > ApproverNameMap = new Map < String, String > ();
        Map < String, String > ApproverLevelMap = new Map < String, String > ();
        List<Loan_Application_Approval__c> loanApproval = new List<Loan_Application_Approval__c>();
        if(triggerPoint == 'Credit Submission(L0)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__r.Name,Loan_Application__c ,Approver_Level__c,Is_Approved_Record__c
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Credit'
                           AND  (Type__c= 'Base' OR Type__c= 'Middle')
                           AND Archived__c =false
                           LIMIT 2];
            if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
                for(Loan_Application_Approval__c approvalInstance : loanApproval){
                        //ApproverNameMap.put(approvalInstance.Type__c,approvalInstance.Approver__r.Name);
                        //ApproverLevelMap.put(approvalInstance.Type__c,approvalInstance.Approver_Level__c);
                        if( approvalInstance.Type__c == 'Base'&& approvalInstance.Is_Approved_Record__c == true ){
                            includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', approvalInstance.Approver_Level__c);
                            includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>', approvalInstance.Approver__r.Name);
                            includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', approvalInstance.Approver__r.Name);
                        }
                        if( approvalInstance.Type__c == 'Middle'&& approvalInstance.Is_Assigned_Approver__c == true ){
                            includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', approvalInstance.Approver_Level__c);
                            includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>', approvalInstance.Approver__r.Name); 
                            includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', approvalInstance.Approver__r.Name); 
                        }
                }
            }
                           
        }else if( triggerPoint == 'Credit Submission (N-1)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__r.Name,Loan_Application__c ,Approver_Level__c,Is_Approved_Record__c
                          FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                          AND Approval_Type__c='Credit'
                          AND  (Type__c= 'Middle' OR Type__c= 'Highest')
                          AND Archived__c =false
                          LIMIT 2];
             if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
                for(Loan_Application_Approval__c approvalInstance : loanApproval){
                       // ApproverNameMap.put(approvalInstance.Type__c,approvalInstance.Approver__r.Name);
                       // ApproverLevelMap.put(approvalInstance.Type__c,approvalInstance.Approver_Level__c);
                if( approvalInstance.Type__c == 'Middle'&& approvalInstance.Is_Approved_Record__c == true ){
                includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', approvalInstance.Approver_Level__c);
                includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>', approvalInstance.Approver__r.Name);
                includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', approvalInstance.Approver__r.Name);
                }
                if(approvalInstance.Type__c == 'Highest'&& approvalInstance.Is_Assigned_Approver__c == true){
                includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', approvalInstance.Approver_Level__c);
                includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>', approvalInstance.Approver__r.Name); 
                includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>', approvalInstance.Approver__r.Name); 
                }
                }
                /*String middleApproverlevel=  ApproverLevelMap.get('Middle')!=null ? ApproverLevelMap.get('Middle') :'';
                String middleApproverName= ApproverNameMap.get('Middle')!=null ? ApproverNameMap.get('Middle') :'';
                String highestApproverlevel=  ApproverLevelMap.get('Highest')!=null ? ApproverLevelMap.get('Highest') :'';
                String highestApproverName= ApproverNameMap.get('Highest')!=null ? ApproverNameMap.get('Highest') :'';*/
            }

        } else if(triggerPoint == 'Credit Submission (N)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__r.Name,Loan_Application__c ,Approver_Level__c,Is_Approved_Record__c
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId
                           AND  (Approval_Type__c='Credit' OR Approval_Type__c='Pricing')
                           AND (Type__c= 'Base' OR Type__c ='Middle' OR Type__c ='Highest')
                           AND Archived__c =false];

             if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
                for(Loan_Application_Approval__c approvalInstance : loanApproval){
                        if( (approvalInstance.Approval_Type__c =='Credit' && approvalInstance.Type__c == 'Highest') && approvalInstance.Is_Approved_Record__c == true ){
                            includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', approvalInstance.Approver_Level__c);
                            includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>',approvalInstance.Approver__r.Name);
                            includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', approvalInstance.Approver__r.Name);
                        }
                        if( approvalInstance.Approval_Type__c =='Pricing'){
                            if( (approvalInstance.Type__c == 'Base' || approvalInstance.Type__c == 'Middle') && approvalInstance.Is_Assigned_Approver__c == true){
                                includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', approvalInstance.Approver_Level__c);
                                includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>',approvalInstance.Approver__r.Name); 
                                includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>',approvalInstance.Approver__r.Name); 
                            }
                        }        
                }
               
            }
        }else if (triggerPoint =='Pricing (N-1)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__r.Name,Loan_Application__c ,Approver_Level__c,Is_Approved_Record__c
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Pricing'
                           AND ( Type__c ='Base' OR Type__c ='Middle' OR Type__c='Highest')
                           AND Archived__c =false];
            if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
                for(Loan_Application_Approval__c approvalInstance : loanApproval){
                        if( (approvalInstance.Type__c == 'Base' || approvalInstance.Type__c == 'Middle') && approvalInstance.Is_Approved_Record__c == true  ){
                            includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', approvalInstance.Approver_Level__c);
                            includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>',approvalInstance.Approver__r.Name);
                            includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', approvalInstance.Approver__r.Name);
                        }
                        if(approvalInstance.Type__c == 'Highest' && approvalInstance.Is_Assigned_Approver__c == true ){
                                includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', approvalInstance.Approver_Level__c);
                                includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>',approvalInstance.Approver__r.Name); 
                                includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>',approvalInstance.Approver__r.Name); 
                        }  
                }
            }
        }else if (triggerPoint =='Pricing (N)'){
            loanApproval =[SELECT id,Type__c,Archived__c,Approval_Type__c,Is_Assigned_Approver__c ,Approver__r.Name,Loan_Application__c ,Approver_Level__c
                           FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                           AND Approval_Type__c='Pricing'
                           AND Type__c='Highest' AND Is_Approved_Record__c=true
                           AND Archived__c =false];
            if(loanApproval!=null && !loanApproval.isEmpty() && loanApproval.size()>0){
                for(Loan_Application_Approval__c approvalInstance : loanApproval){
                        if( approvalInstance.Type__c == 'Highest'){
                            includedLoanMessage = includedLoanMessage.replaceAll('<authoritylevel>', approvalInstance.Approver_Level__c);
                            includedLoanMessage = includedLoanMessage.replaceAll('<Credit person name>',approvalInstance.Approver__r.Name);
                            includedLoanMessage = includedLoanMessage.replaceAll('<authority name_Emp code>', approvalInstance.Approver__r.Name);
                        }
                       /* if(approvalInstance.Type__c == 'Highest' ){
                                includedLoanMessage = includedLoanMessage.replaceAll('<next authority level>', approvalInstance.Approver_Level__c);
                                includedLoanMessage = includedLoanMessage.replaceAll('<next Credit person name>',approvalInstance.Approver__r.Name); 
                                includedLoanMessage = includedLoanMessage.replaceAll('<recipient name>',approvalInstance.Approver__r.Name); 
                        }  */
                }
            }
        }
        

        
        System.debug('ApproverMessage-->' +includedLoanMessage);
        return includedLoanMessage;
    }
   
    
    
    /*  public static String generateKarixRequest(String phoneNo ,String publicURL,String applicantId){
Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karix URL Shortner');
Map<String,Object> reqParam = new Map<String,Object>();
reqParam.put('MobileNumber',phoneNo);
reqParam.put('Channel',objIntMapper.Apiuser__c);
reqParam.put('RequestId',IntegrationUtility.getReferenceId());
reqParam.put('LongURL',publicURL); //https://ausfb2022--dev1.sandbox.my.salesforce.com/sfc/p/6s0000004XUL/a/6s000000GsJ7/qLK57zm2lqdhBwDC9fBVZmNZfX2004EYZfzQzpzE1a0
String recordId =applicantId;
String requestBody =  NotificationIntegrationHandler.generateShortenURLServiceRequest(reqParam)[0];
Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
calloutRequestWrapper.request = requestBody;
calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
calloutRequestWrapper.masterRecord = objIntMapper;
calloutRequestWrapper.checklistRecord = checklistRecord;
IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
String respBody = calloutResponseWrapper.response;
system.debug('respBody-->' +respBody);
NotificationIntegrationHandler.KarixResponseWrapper response;
if(respBody!=null){
response =(NotificationIntegrationHandler.KarixResponseWrapper) JSON.deserialize(respBody,NotificationIntegrationHandler.KarixResponseWrapper.class);
}


String shortURL = (String)response.shortUrl;
return respBody;
}*/
    
    /*  public static String getShortendURL(String triggerPoint ,String loanId ,String applicantId,String phoneNumber ){
//String documentName = getDocumentName(triggerPoint) != '' ? getDocumentName(triggerPoint) : '';
String documentName = 'Do letter';
String publicURL='https://ausfb2022--dev1.sandbox.my.salesforce.com/sfc/p/6s0000004XUL/a/6s000000GsJC/2Tp4pTFUWO3.0vMnYWCEA7J34R0qgvdreal64C4tUrc';
fileWrapper fileDetails;
if( getFileDetails(documentName, loanId) != null){
fileDetails= getFileDetails(documentName,loanId);
// publicURL = fileDetails.publicURL;
}
String shortendUrl =  generateKarixRequest('8190008108' ,publicURL,applicantId);
System.debug('shortendUrl-->' +shortendUrl);
return shortendUrl;
}*/
    
    public Static User getOpsUser(String LoanId){
        List<Assignment__c> assignmentRecord = [SELECT Id,Name ,OwnerId,Loan_Application__c,RecordType.DeveloperName 
                                                FROM Assignment__c 
                                                WHERE Loan_Application__c=:LoanId
                                                AND RecordType.DeveloperName ='Ops_Disbursement'
                                                LIMIT 1 ];
          User userDetail;
        if(assignmentRecord!=null && !assignmentRecord.isEmpty() && assignmentRecord.size()>0){
            userDetail  = [SELECT id,Name,Email,MobilePhone,Ops_User_Type__c FROM User where id=:assignmentRecord[0].OwnerId AND   (Ops_User_Type__c = 'Ops Maker' OR Ops_User_Type__c='Ops Author')];
        }
        return userDetail;
    }

    public Static pddDocumentsWrapper getPDDPendingDocs(String collateralId){
      
      List<Document_Checklist__c> docList =[SELECT id,Collateral__c,Document_Verification_Status__c,Document_Master__r.Document_Name__c,Collateral__r.Loan__r.Stage__c 
                                            FROM Document_Checklist__c 
                                            WHERE Collateral__c =:collateralId
                                            AND Collateral__r.Loan__r.Stage__c = 'PDD'];
       String pendingDocs='';
       String completedDocs='';
        for(Document_Checklist__c docInstance : docList){
            String docName= docInstance.Document_Master__r.Document_Name__c;
                if(docInstance.Document_Verification_Status__c=='Verified'){
                    completedDocs = completedDocs + ',' + docName;
                }else{
                    pendingDocs = pendingDocs +',' + docName;
                }
                
        }

        pddDocumentsWrapper wrapperInstance = new pddDocumentsWrapper();
        wrapperInstance.pendingDocs = String.isNotBlank(pendingDocs) ? pendingDocs.substring(1) :'';
        wrapperInstance.completedDocs = String.isNotBlank(completedDocs) ? completedDocs.substring(1):'';
       
        
        return wrapperInstance;
    }
    
    public class pddDocumentsWrapper{
        @AuraEnabled public String pendingDocs {
            get;
            set;
        }
        
        @AuraEnabled public String completedDocs {
            get;
            set;
        }
        public pddDocumentsWrapper() {
            pendingDocs = '';
            completedDocs = '';
        }
        
    }
    public class accountTeamWrapper {
        @AuraEnabled public List < AccountTeamMember > BMList {
            get;
            set;
        }
        @AuraEnabled public List < AccountTeamMember > TLList {
            get;
            set;
        }
        @AuraEnabled public List < AccountTeamMember > FIList {
            get;
            set;
        }
        @AuraEnabled public List < AccountTeamMember > CreditList {
            get;
            set;
        }
        @AuraEnabled public String branchAddress {
            get;
            set;
        }
        
        
        
        public accountTeamWrapper() {
            BMList = new List < AccountTeamMember > ();
            TLList = new List < AccountTeamMember > ();
            FIList = new List < AccountTeamMember > ();
            CreditList = new List < AccountTeamMember >();
            branchAddress = '';
            
        }
        
    }
    
    public class valuationWrapper {
        @AuraEnabled public List < Valuation__c > valuationList {
            get;
            set;
        }
        
        @AuraEnabled public String documentURL {
            get;
            set;
        }
        
        public valuationWrapper() {
            valuationList = new List < Valuation__c > ();
            documentURL = '';
            
            
        }
    }
    
    public class fileWrapper {
        @AuraEnabled public String baseData {
            get;
            set;
        }
        
        @AuraEnabled public String publicURL {
            get;
            set;
        }
        
        
        public fileWrapper() {
            baseData = '';
            publicURL = '';
            
        }
        
    }
    
}