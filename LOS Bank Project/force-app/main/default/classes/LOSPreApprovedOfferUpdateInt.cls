/*****
 * Class Name: LOSPreApprovedOfferUpdateInt
 * Description: Pre Approved Offer Avail
 * Test Class Name: LOSPreApprovedOfferUpdateIntTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-14-2023          -   Mohit M.            -   SFAU-5722 - Remove Database.update and throw error message in case of any error
 */
public without sharing class LOSPreApprovedOfferUpdateInt {
    @AuraEnabled
    public static PreApprovedWrapper callPreApprovedUpdateOfferInt(Pre_Approved_Offer__c objPreApproved, String strApplicantId) {
        PreApprovedWrapper objReturnResp = new PreApprovedWrapper();
        String respBody = '';
        try{
            system.debug('%%% '+objPreApproved);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('PreApprovedOfferUpdate');
            Map<String,Object> reqParam = new Map<String,Object>();
            if(objPreApproved.OfferIsActive__c){
                reqParam.put('strOfferActive','Offer Is Active');
            }
            reqParam.put('strItemType','Offer');
            reqParam.put('strItemId',objPreApproved.Offer_Id__c);
            String requestBody = LOSPreApprovedOfferUpdateIntHandler.generateRequest(reqParam)[0];
            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            LOSPreApprovedOfferUpdateIntHandler.PreApprovedResponseWrapper objResultWrapper
                    = (LOSPreApprovedOfferUpdateIntHandler.PreApprovedResponseWrapper) System.JSON.deserialize(respBody, LOSPreApprovedOfferUpdateIntHandler.PreApprovedResponseWrapper.class);
            
            String responseMessage = objResultWrapper.TransactionStatus.ResponseMessage;
            if(responseMessage == 'Success'){
                List<Pre_Approved_Offer__c> lstPreApprovedOffertoInsert = new List<Pre_Approved_Offer__c>();
                objPreApproved.Is_Selected__c = true;
                lstPreApprovedOffertoInsert.add(objPreApproved);
                //SFAU-5722
                update lstPreApprovedOffertoInsert;
                //DatabaseUtility.updateRecords(lstPreApprovedOffertoInsert,'');
                
                List<Loan_Application__c> lstLoanApplicationtoUpdate = new List<Loan_Application__c>();
                Loan_Application__c objLoanApp = [Select Id, Loan_Amount__c, Tenure__c, ROI__c, Pre_Approved_Flag__c from Loan_Application__c where Id=:objPreApproved.Loan_Application__c limit 1];
                objLoanApp.Loan_Amount__c = objPreApproved.FirstOfferAmount__c;
                objLoanApp.Total_Loan_Amount__c = objPreApproved.FirstOfferAmount__c;
                objLoanApp.Tenure__c = objPreApproved.MaxLoanTenureinMonths__c;
                objLoanApp.ROI__c = objPreApproved.RateofInterest__c;
                objLoanApp.Pre_Approved_Flag__c = true;
                lstLoanApplicationtoUpdate.add(objLoanApp);
                //SFAU-5722
                update lstLoanApplicationtoUpdate;
                //DatabaseUtility.updateRecords(lstLoanApplicationtoUpdate,'');
                objReturnResp.blnSuccess = true;
                objReturnResp.response = respBody;
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.Error,'Error in LOSPreApprovedOfferUpdateInt Class :: ' + ex);
            System.debug(LoggingLevel.Error,'Error in LOSPreApprovedOfferUpdateInt Class at line number :: ' + ex.getLineNumber());
            objReturnResp.blnSuccess = false;objReturnResp.strMsg = ex.getMessage();objReturnResp.response = respBody;
            Log.error('Error in LOSPreApprovedOfferUpdateInt :: at line number ' + ex.getLineNumber() + ' - ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
        }
        return objReturnResp;
    }

    public class PreApprovedWrapper {
        @AuraEnabled
        public String response = '';
        @AuraEnabled
        public String strMsg = '';
        @AuraEnabled
        public Boolean blnSuccess = false;
        public PreApprovedWrapper(){}
    }
}