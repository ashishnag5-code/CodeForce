public with sharing class LANCreationController {
    
    public class Details{
        @AuraEnabled public Loan_Application__c loan{get;set;}
        @AuraEnabled public String productType{get;set;}
        @AuraEnabled public String wheels{get;set;}
        @AuraEnabled public List<State_wise_Mapping__mdt> stateMappings{get;set;}
        @AuraEnabled public String userType{get;set;}
        @AuraEnabled public Applicant__c primaryApplicant{get;set;}
    }
    
    @AuraEnabled
    public static Details getLoanApplicationDetails(Id loanAppId){
        Details loanAppDetails = new Details();
        List<Loan_Application__c> loanApplications = new List<Loan_Application__c>();
        try {
            loanApplications = [SELECT Id, Name, OPS_KYC_Action__c, Collateral_Linkage_Used_COW__c, Collateral_Modification_Used_COW__c, Dpd_Found__c, Stage__c, LAN__c, Loan_Number__c, ROI__c, toLabel(Product__c) productName, Product__c, First_EMI_Date__c, 
            (SELECT MMV_Master__c, MMV_Master__r.Make_Model_Variant__c, Vehicle_Number__c,Engine_Number__c,Chasis_Number__c, Collateral_Id_in_CBS__c,BT_Loan_Status__c,SVSH_SVOH__c FROM Collaterals__r Where Is_Deleted__c = false AND RecordTypeId IN: GlobalConstants.colRecordTypeIds Order By CreatedDate Desc),
            Scheme__c, Scheme__r.Scheme_Name__c, Total_Loan_Amount__c, Tenure__c, Risk_Base_Pricing__c, Type_of_Rate__c, Emi_Frequency__c, Schedule_Type__c,
            Disbursement_Category__c, Repayment_Start_Date__c, Repayment_Mode__c, EMI__c, EMI_Date__c, Total_Exposure__c, Credit_Approved_Exposure__c,
            Schedule_Code__c, Esign_Type__c, Esign_Date__c, Loan_Amount__c, Branch_Master__c, Branch_Master__r.Account_Code__c, Pre_Approved_Flag__c, isNoteSynced__c, OwnerId, Owner.Type,
            is_Collateral_Creation_Successful__c, is_Collateral_Linkage_Successful__c
            FROM Loan_Application__c WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
            Applicant__c applicant = [SELECT Id, (Select State__c from Addresses__r where Address_Type__c='Current' AND (Source_Type__c=null OR  Source_Type__c = 'CBS')) FROM Applicant__c WHERE Loan__c=:loanAppId AND RecordType.Developername='Primary_Applicant' AND isInactive__c = false WITH SECURITY_ENFORCED LIMIT 1];
            loanAppDetails.stateMappings = [SELECT State__c,Two_Wheeler_EMI_Date__c,Four_Wheeler_EMI_Date__c FROM State_wise_Mapping__mdt where state__c=:applicant.Addresses__r[0].State__c WITH SECURITY_ENFORCED];
            // Adding Primary Applicant in wrapper - kunal
            loanAppDetails.primaryApplicant = applicant;
            if(loanApplications!=null && loanApplications.size()>0){
                loanAppDetails.loan = loanApplications[0];
                if(loanAppDetails.loan.Owner.Type =='User'){
                    loanAppDetails.userType = 'User';
                }else{
                    loanAppDetails.userType = 'NA';
                }
                List<User> users = [SELECT Id, Ops_User_Type__c FROM User WHERE Id=:UserInfo.getUserId()];
                if(users!=null && users.size()>0){
                    if(users[0].Ops_User_Type__c =='Ops Maker'){
                        loanAppDetails.userType = 'User';
                    }else{
                        loanAppDetails.userType = 'NA';
                    }
                }
                String prod = 'A_'+loanApplications[0].Product__c;
                ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
                if(prodRecordType!=null){
                    loanAppDetails.productType = prodRecordType.Sub_Product__c;
                    loanAppDetails.wheels = prodRecordType.RecordType__c;
                }
            }
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return loanAppDetails;
    }

    @AuraEnabled
    public static List<String> getVisibleFieldsForLoanDetails(String strScreen, String strStage, String strProfile){

        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile);
        return visibleFields;

    }
    
    @AuraEnabled
    public static String callLANCreationCallout(Id recordId, String failureReason){
        LANCreationAPIHandler.LANCreationApiResponseWrapper lanCreationResponseWrapper = new LANCreationAPIHandler.LANCreationApiResponseWrapper();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('LAN Creation');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('FailureReason',failureReason);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody= LANCreationApiHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = [SELECT Id FROM Integration_CheckList__c WHERE Loan_Application__c =: recordId AND Integration_Master_Name__c = 'LAN Creation' AND Status__c = 'Pending' Order by Createddate desc Limit 1];
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            // Added by Kunal - Start [SFAU-5526 - Moving update application logic to apex from lanCreationCardView.js ]
            String respBody = calloutResponseWrapper.response;
            lanCreationResponseWrapper = (LANCreationAPIHandler.LANCreationApiResponseWrapper) JSON.deserialize(respBody, LANCreationAPIHandler.LANCreationApiResponseWrapper.class);
            Loan_Application__c loanApp = new Loan_Application__c();
            if(lanCreationResponseWrapper.AccountId != null && lanCreationResponseWrapper.TransactionStatus.ResponseMessage == 'Success'){
                loanApp.Id = recordId;
                loanApp.LAN__c = lanCreationResponseWrapper.AccountId;
                loanApp.is_Collateral_Linkage_Successful__c = true;
                loanApp.is_Collateral_Creation_Successful__c = true;
                loanApp.LAN_Created_By__c = UserInfo.getUserId();
                loanApp.LAN_Creation_Date__c = Date.today();
            }else if(lanCreationResponseWrapper.AccountId != null){
                loanApp.Id = recordId;
                loanApp.LAN__c = lanCreationResponseWrapper.AccountId;
                loanApp.LAN_Created_By__c = UserInfo.getUserId();
                loanApp.LAN_Creation_Date__c = Date.today();
            }else if(lanCreationResponseWrapper.TransactionStatus.ResponseMessage == 'Success'){
                loanApp.Id = recordId;
                loanApp.is_Collateral_Linkage_Successful__c = true;
                loanApp.is_Collateral_Creation_Successful__c = true;
            }else if(lanCreationResponseWrapper.TransactionStatus.ResponseMessage == 'Incomplete'){
               if(lanCreationResponseWrapper.TransactionStatus.ExtendedErrorDetails.messages != null && lanCreationResponseWrapper.TransactionStatus.ExtendedErrorDetails.messages.size() > 0){
                for( LANCreationAPIHandler.MessagesWrapper element : lanCreationResponseWrapper.TransactionStatus.ExtendedErrorDetails.messages){
                    if(element.code == 0 && element.message.contains('CollateralCreation')){
                        loanApp.Id = recordId;
                        loanApp.is_Collateral_Creation_Successful__c = true;
                    }
                    if(element.code == 0 && element.message.contains('CollateralLinkage')){
                        loanApp.Id = recordId;
                        loanApp.is_Collateral_Linkage_Successful__c = true;
                    }
                }
               }
            }
            if(loanApp.Id != null){
                update loanApp;
            }
            // Added by Kunal - End [SFAU-5526 ]
        }catch(Exception e) {
            Log.error('Error in LanCreationController.callLANCreationCallout LINE NUMBER ' + e.getLineNumber() + ' --  ' + e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(calloutResponseWrapper);
        //return lanCreationResponseWrapper;
    }


    @AuraEnabled
    public static void generateDisbursalVoucher(String loanApplicationId){
        try {
            List<Document_Checklist__c> checkListRecords = [SELECT Id, Document_Master__r.Document_Name__c FROM Document_Checklist__c WHERE Document_Master__r.Name='AUWheels0072' AND Loan_Application__c=:loanApplicationId];
            if(checkListRecords!=null && checkListRecords.size()>0){
                Document_Checklist__c checkListRecord = checkListRecords[0];
                PageReference savepage ;
                savepage = new PageReference('/apex/DisbursementVoucherPDFPage');
                savepage.getParameters().put('applicationId',loanApplicationId);
                ContentVersion cv = new ContentVersion();
                cv.VersionData = savepage.getContentAsPDF();
                cv.Title = 'Disbursement Voucher';
                cv.PathOnClient = 'Disbursement Voucher'+'.pdf';
                insert cv;
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = checkListRecord.Id;
                insert cdl;
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Check if LAN is already Initiated or Created - SFAU-5526 
    @AuraEnabled
    public static string checkIfLANAlreadyExists(String loanId){
        try {
            List<Integration_CheckList__c> records = [SELECT Id FROM Integration_Checklist__c Where Loan_Application__c =: loanId AND Integration_Master_Name__c = 'LAN Creation' AND Status__c = 'Pending'];
            if(records.IsEmpty()){
                Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('LAN Creation');
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=loanId,Integration_Master__c = objIntMapper.Id,Status__c = 'Pending');
                insert checklistRecord;
                return 'Success';
            }else{
                throw new CustomEXception('LAN Creation Already Initiated. Please wait');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
      //Notification 
      @AuraEnabled
      public static void sendSIotification(String loanId){
          try {
              NotificationHandler.sendNotification('SI activation',loanId,'');
          } catch (Exception e) {
             System.debug('exception-->' +e);
          }
      }
      //END
      public class CustomException extends Exception{}

}