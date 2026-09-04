public with sharing class LOSPreApprovedOfferInt {
    @AuraEnabled
    public static List<Pre_Approved_Offer__c> callPreApprovedOfferInt(Applicant__c objApplicant) {
        String respBody;
        String strCustomerId;
        String strApplicantId;
        List<Pre_Approved_Offer__c> lstPreApproved = new List<Pre_Approved_Offer__c>();
        try{
            Applicant__c objApp = [SELECT Customer_Name__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c, Pan_Form60__c, CIF_No__c, 
                                                 Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name FROM Applicant__c where Id=:objApplicant.Id limit 1];
            strApplicantId = objApp.Id;
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('PreApprovedOffer');
            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('strCustomerId',objApp.CIF_No__c);
            //reqParam.put('strCustomerId','24083775');
            String requestBody = LOSPreApprovedOfferIntHandler.generateRequest(reqParam)[0];
            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;
            //system.debug('%%'+respBody);
            lstPreApproved = savePreApprovedOfferInt(respBody,objApp);
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),strApplicantId);
        }
        return lstPreApproved;
    }
    
    private static List<Pre_Approved_Offer__c> savePreApprovedOfferInt(String respBody,Applicant__c objApplicant){
        List<Pre_Approved_Offer__c> lstPreApprovedOffertoInsert = new List<Pre_Approved_Offer__c>();
        List<Pre_Approved_Offer__c> lstPreApproved = new List<Pre_Approved_Offer__c>();
        try{
            system.debug('%% in save');
            lstPreApproved = [Select Id, Loan_Application__c, Offer_Id__c, Avail__c, BankBranch__c, BankName__c, CurrencyID__c, 
            Customer_Id__c,
            CustomerNameinBankAccount__c, Employee__c, FirstOfferAmount__c, IFSCcode__c, Image_Offers__c, 
            Location__c,
            MaxLoanTenureinMonths__c, MinLoanTenureinMonths__c, Mobile__c, Occupation__c, off_ex1_8__c, OfferDescription__c, 
            OfferIsActive__c, Offer_Name__c, OfferType__c, Product_Id__c, RateofInterest__c, RatingID__c, RepaymentMode__c, 
            RowNumber__c, Royale__c, Scheme__c, TermsAndCondition__c, ValidFrom__c, ValidTill__c, Is_Selected__c
            from Pre_Approved_Offer__c where Loan_Application__c =:objApplicant.Loan__c WITH SECURITY_ENFORCED];
            Set<String> offersStoredInSF = new Set<String>();
            if(lstPreApproved!=null && lstPreApproved.size()>0){
                for(Pre_Approved_Offer__c tempOffer: lstPreApproved){
                    offersStoredInSF.add(tempOffer.Offer_Id__c);
                }
            }
            //DatabaseUtility.deleteRecords(lstPreApproved,'');

            //String stripJSON = stripJsonNulls(respBody);
            //system.debug('%% in save'+stripJSON);
            LOSPreApprovedOfferIntHandler.PreApprovedResponseWrapper objResultWrapper
                    = (LOSPreApprovedOfferIntHandler.PreApprovedResponseWrapper) System.JSON.deserialize(respBody, LOSPreApprovedOfferIntHandler.PreApprovedResponseWrapper.class);
            //Save logic 
            system.debug('%% in save'+objResultWrapper);
            //Applicant__c objApplicant = [SELECT Customer_Name__c, Aadhaar_Number__c, PAN__c, Loan__c, Loan__r.Product__c, Pan_Form60__c, CIF_No__c, 
            //                                     Mobile_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, Name, Id, RecordType.Name FROM Applicant__c where Id=:applicantId  WITH SECURITY_ENFORCED limit 1];
            
            if(objResultWrapper != null && objResultWrapper.CRMQueryResults != null && !objResultWrapper.CRMQueryResults.isEmpty()){
                Pre_Approved_Offer__c objPreApproved;
                for(LOSPreApprovedOfferIntHandler.cls_CRMQueryResults objApproved : objResultWrapper.CRMQueryResults){
                    if(objApproved.ProductId == Integer.valueOf(objApplicant.Loan__r.Product__c) && (offersStoredInSF.size()==0 || (offersStoredInSF.size()>0 && !offersStoredInSF.contains(objApproved.OfferId)))){
                        objPreApproved = new Pre_Approved_Offer__c();
                        objPreApproved.Avail__c = objApproved.Avail;
                        objPreApproved.BankBranch__c = objApproved.BankBranch;
                        objPreApproved.BankName__c = objApproved.BankName;
                        objPreApproved.CurrencyID__c = objApproved.CurrencyID;
                        objPreApproved.Customer_Id__c = objApproved.CustomerId;
                        objPreApproved.CustomerNameinBankAccount__c = objApproved.CustomerNameinBankAccount;
                        objPreApproved.Employee__c = objApproved.Employee;
                        objPreApproved.FirstOfferAmount__c = objApproved.FirstOfferAmount;
                        objPreApproved.IFSCcode__c = objApproved.IFSCcode;
                        objPreApproved.Image_Offers__c = objApproved.Image_Offers;
                        objPreApproved.Loan_Application__c = objApplicant.Loan__c;
                        objPreApproved.Location__c = objApproved.Location;
                        objPreApproved.MaxLoanTenureinMonths__c = objApproved.MaxLoanTenureinMonths != null ? Decimal.valueOf(objApproved.MaxLoanTenureinMonths) : null;
                        objPreApproved.MinLoanTenureinMonths__c = objApproved.MinLoanTenureinMonths != null ? Decimal.valueOf(objApproved.MinLoanTenureinMonths) : null;
                        objPreApproved.Mobile__c = objApproved.Mobile;
                        objPreApproved.Occupation__c = objApproved.Occupation;
                        objPreApproved.off_ex1_8__c = objApproved.off_ex1_8;
                        objPreApproved.OfferDescription__c = objApproved.OfferDescription;
                        objPreApproved.Offer_Id__c = objApproved.OfferId;
                        objPreApproved.OfferIsActive__c = (objApproved.OfferIsActive == 'true' ? true : false);
                        objPreApproved.Offer_Name__c = objApproved.OfferName;
                        objPreApproved.OfferType__c = objApproved.OfferType;
                        objPreApproved.Product_Id__c = objApproved.ProductId;
                        objPreApproved.RateofInterest__c = objApproved.RateofInterest != null ? Decimal.valueOf(objApproved.RateofInterest) : null;
                        objPreApproved.RatingID__c = objApproved.RatingID;
                        objPreApproved.RepaymentMode__c = objApproved.RepaymentMode;
                        objPreApproved.RowNumber__c = objApproved.RowNumber;
                        objPreApproved.Royale__c = objApproved.Royale;
                        objPreApproved.Scheme__c = objApproved.Scheme;
                        objPreApproved.TermsAndCondition__c = objApproved.TermsAndCondition;
                        objPreApproved.ValidFrom__c = objApproved.ValidFrom != null ? Datetime.valueOf(objApproved.ValidFrom.replace('T',' ')) : null;
                        objPreApproved.ValidTill__c = objApproved.ValidTill != null ? Datetime.valueOf(objApproved.ValidTill.replace('T',' ')) : null;
                        objPreApproved.Is_Selected__c = false;
                        lstPreApprovedOffertoInsert.add(objPreApproved);
                        
                    }
                }
                if(objApplicant.RecordType.Name == 'Applicant' && lstPreApprovedOffertoInsert!=null && lstPreApprovedOffertoInsert.size()>0){
                    //DatabaseUtility.createRecords(lstPreApprovedOffertoInsert,'');
                    Insert lstPreApprovedOffertoInsert;
                    List<Pre_Approved_Offer__c> resultOffers = (new Map<Id,Pre_Approved_Offer__c>(lstPreApprovedOffertoInsert)).values();
                    for(Pre_Approved_Offer__c preOffer: resultOffers){
                        lstPreApproved.add(preOffer);
                    }
                }
            }
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),'');
        }
        return lstPreApproved;//lstPreApprovedOffertoInsert;
    }
    
}