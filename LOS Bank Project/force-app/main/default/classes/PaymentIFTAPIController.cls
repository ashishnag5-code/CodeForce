public with sharing class PaymentIFTAPIController {
    
    @AuraEnabled
    public static String doIFTPayment(String recordId, String paymentFavouringId, String isPoolDisbursement, String disbursementAmount,String disburseBtn){
        String respBody;
        PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper responseWrapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        Loan_Application__c loanApp = new Loan_Application__c(Id = recordId);
        List<Payment__c> payments;
        Boolean isCheque = disburseBtn == 'disbursePaymentCheque';
        try{
            String callType = isCheque ? GlobalConstants.PAYMENT_CALL_TYPE_CHEQUE : GlobalConstants.PAYMENT_CALL_TYPE_NEFT;
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId,Call_Type__c = callType,Payment__c = paymentFavouringId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Payment IFT');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('PaymentId',paymentFavouringId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            reqParam.put('IsPoolDisbursement',isPoolDisbursement);
            reqParam.put('DisbursementAmount',disbursementAmount);
            reqParam.put('isCheque',String.valueOf(isCheque));
            String requestBody = PaymentIFTAPIHandler.generateRequest(reqParam)[0];
            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            responseWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper) JSON.deserialize(respBody, PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper.class);
            PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper requestWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper) JSON.deserialize(requestBody, PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper.class);
            // SFAU-5479 - Kunal Start
            if(isPoolDisbursement == 'Yes'){
                payments = isCheque ? RelatedPaymentFavouringsController.getChequePaymentFavList(recordId,'Payment Favouring') : RelatedPaymentFavouringsController.getNonChequePaymentFavList(recordId,'Payment Favouring');
                if(calloutResponseWrapper.statusCode != 200){
                    for(Payment__c payment : payments){
                        if(isCheque){
                            payment.Pool_Txn_Cheque_Reference_Number__c = requestWrapper.ReferenceNumber;
                        }else{
                            payment.Pool_Txn_Reference_Number__c = requestWrapper.ReferenceNumber;
                        }
                    }
                }else if(responseWrapper.TransactionStatus.ResponseMessage == 'Success'){
                    for(Payment__c payment : payments){
                        if(isCheque){
                            payment.Pool_Txn_Cheque_Reference_Number__c = requestWrapper.ReferenceNumber;
                            payment.Is_Cheque_Pool_Disburse_Successful__c = true;
                        }else{
                            payment.Is_Pool_Disbursement_Successful__c = true;
                            payment.Pool_Txn_Reference_Number__c = requestWrapper.ReferenceNumber;
                        }
                    }
                }else{
                    for(Payment__c payment : payments){
                        if(isCheque){
                            payment.Pool_Txn_Cheque_Reference_Number__c = null;
                        }else{
                            payment.Pool_Txn_Reference_Number__c = null;
                        }
                    }
                }
                AUSFLoanApplication_WithoutSharing.updateSObjectRecs(payments);
            }
            // SFAU-5479 - Kunal End
            
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return JSON.serialize(calloutResponseWrapper);//responseWrapper;                      
    }
}