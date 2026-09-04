@isTest
public with sharing class RedirectToProposalLifeInsurance {
    /*
    @AuraEnabled
    public Static List<Applicant__c> getApplicant(String applcntId) {
        List<Applicant__c> applicantList = [SELECT Id, Loan__r.Loan_Amount__c, Loan__r.LAN__c, Loan__r.Tenure__c, Gender__c, Age__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                                   Mobile_Number__c, Email__c, Customer_Type__c, RecordType.Name, Dob__c, PAN__c, CIF_No__c
                                            FROM Applicant__c 
                                            WHERE Id =:applcntId WITH SECURITY_ENFORCED];
        
       return applicantList;
    }
  
    @AuraEnabled
    public Static List<Address__c> getAddress(String applcntId, String addressType) {
        List<Address__c> addressList = [SELECT Id,Name,Address_Type__c,Applicant__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                          State__c,City__c,Area_Name__c,Area_Type__c,Taluka__c,Pincode__c,Land_mark__c,Product__c,Stability__c,Status__c,
                                          Address_Source__c,Type__c, District__c
                                        FROM Address__c 
                                        WHERE (Applicant__c =:applcntId AND Address_Type__c = :addressType) WITH SECURITY_ENFORCED];
        
        return addressList;
    }
    @AuraEnabled
    public Static RequestWrapper redirectToProposalLife(String applicantId, String docMstrName, String reqAndRespFromApi, String loanAppId) {
        
        RedirectToProposalLifeInsurance redToPropObj          = new RedirectToProposalLifeInsurance();

        Map<String,Object> mapOfLifeReqAndResp = (Map<String, Object>) JSON.deserializeUntyped(reqAndRespFromApi);
        system.debug('reqAndRespFromApi-- '+reqAndRespFromApi);
        system.debug('mapOfLifeReqAndResp-- '+mapOfLifeReqAndResp);
        LifeInsurancePremiumApi.LifePremiumRequestWrapper  lifeRequest = (LifeInsurancePremiumApi.LifePremiumRequestWrapper) JSON.deserialize(JSON.serialize(mapOfLifeReqAndResp.get('request')),LifeInsurancePremiumApi.LifePremiumRequestWrapper.class);
        LifeInsurancePremiumApi.LifePremiumResponseWrapper lifeResp    = (LifeInsurancePremiumApi.LifePremiumResponseWrapper) JSON.deserialize(JSON.serialize(mapOfLifeReqAndResp.get('Response')), LifeInsurancePremiumApi.LifePremiumResponseWrapper.class);
        Map<String,Object> mapOfHealthReq        = new Map<String,Object>();
        Map<String,Object> mapOflifeResp       = new Map<String,Object>();

        RequestWrapper requestForLife= redToPropObj.generateReqForLife(applicantId, docMstrName, lifeRequest, lifeResp, loanAppId);        
        
        return requestForLife;
    }

    public RequestWrapper generateReqForLife(String applicantId, String docMstrName, LifeInsurancePremiumApi.LifePremiumRequestWrapper  lifeRequest, LifeInsurancePremiumApi.LifePremiumResponseWrapper lifeResp, String loanAppId) { 
        system.debug('applicantId--'+applicantId);
        String recorTypeName = '';
        String typeOfProposer = '';
        List<Applicant__c> applicantList = getApplicant(applicantId).size() > 0 ? getApplicant(applicantId) : new List<Applicant__c>();
        
        String userId = UserInfo.getUserId();
        List<User> userInfo = [Select id, Employee_Code__c from User where id = :userId];
        String lanNo = String.isNotBlank(applicantList[0].Loan__r.LAN__c) ? applicantList[0].Loan__r.LAN__c : '';

        Applicant__c applcnt = new Applicant__c();
        if(applicantList.size() > 0) {
            applcnt = applicantList[0];
            recorTypeName = applcnt.RecordType.Name;
        }

        if(recorTypeName == 'Applicant') {
            typeOfProposer = 'Borrower';
        }
        else if(recorTypeName == 'Co-Applicant') {
            typeOfProposer = 'CoBorrower';
        }
        system.debug('applicantList--'+applicantList);
        String applcntFirstName  = String.isNotBlank(applcnt.First_Name__c) ? applcnt.First_Name__c : '';
        String applcntMiddleName = String.isNotBlank(applcnt.Middle_Name__c) ? applcnt.Middle_Name__c : '';
        String applcntLastName   = String.isNotBlank(applcnt.Last_Name__c) ? applcnt.Last_Name__c : '';
        String applcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;

        RequestWrapper reqWrapp  = new RequestWrapper();
        reqWrapp.ResponseID      = lifeResp.ResponseID;
        List<TransactionJson> transationObjLst = new List<TransactionJson>();     
        Map<String, String> mapOfKeyToValue = new Map<String, String>();

        mapOfKeyToValue.put('LoanAccNo',   lanNo);
        mapOfKeyToValue.put('MemberType', typeOfProposer);
        mapOfKeyToValue.put('Name',       applcntFullName);
        mapOfKeyToValue.put('Mobile',     applcnt.Mobile_Number__c);
        mapOfKeyToValue.put('Email',      applcnt.Email__c);
        system.debug('reqWrapp.transactionJson--'+reqWrapp.transactionJson);
        for(String key : mapOfKeyToValue.keySet()) {
            TransactionJson transationObj = new TransactionJson();
            transationObj.key = key;
            transationObj.value = mapOfKeyToValue.get(key);
            transationObjLst.add(transationObj);
        }

        reqWrapp.prodInputs = new List<Object>();
        reqWrapp.prodInputs = lifeResp.LifePremiumResponse.prodInputs;

        reqWrapp.transactionJson = new List<TransactionJson>();
        reqWrapp.transactionJson = transationObjLst;
        system.debug('reqWrapp.transactionJson--'+reqWrapp.transactionJson);
        CustomerInfo cstmrInfo = new CustomerInfo();
        cstmrInfo.Name         = applcntFullName;
        cstmrInfo.Gender       = applcnt.Gender__c;
        cstmrInfo.Email        = applcnt.Email__c;
        cstmrInfo.Mobile       = applcnt.Mobile_Number__c;
        cstmrInfo.DOB          = String.valueOf(applcnt.Dob__c);
        cstmrInfo.PanNo        = applcnt.PAN__c;
        cstmrInfo.CustomerID   = applcnt.CIF_No__c;
        
        reqWrapp.customerInfo = new CustomerInfo();
        reqWrapp.customerInfo = cstmrInfo;
        system.debug('cstmrInfo--'+reqWrapp.customerInfo);
        String otherKey2Val = loanAppId + '_' + applicantId;

        Map<String, String> permanentMap = RedirectToProposal.getPermanentAddress(applicantId);
    
        OtherDetails otherDetObj     = new OtherDetails();
        otherDetObj.FkModuleID       = '2';
        otherDetObj.FkSubModuleID    = '28';
        otherDetObj.PermanentAddress = permanentMap.get('fullPermanentAddress');
        otherDetObj.Pincode          = Integer.valueOf(permanentMap.get('pincode'));
        otherDetObj.UserLoginID      = userInfo[0].Employee_Code__c;
        otherDetObj.OtherKey1        = 'SFDC';
        otherDetObj.OtherKey2        = otherKey2Val;

        system.debug('permanentMap--'+permanentMap);
        reqWrapp.customerInfo.otherDetails = new OtherDetails();
        reqWrapp.customerInfo.otherDetails = otherDetObj;

        return reqWrapp;
    } 

    public class RequestWrapper {
        @AuraEnabled public String ResponseID;
        @AuraEnabled public List<TransactionJson> transactionJson;
        @AuraEnabled public CustomerInfo customerInfo;
        @AuraEnabled public List<Object> prodInputs;
    }
    public class TransactionJson {
        @AuraEnabled public String key;
        @AuraEnabled public String value;
    }

    public class CustomerInfo {
        @AuraEnabled public String CustomerID{get;set;}
		@AuraEnabled public String Mobile{get;set;}
		@AuraEnabled public String DOB{get;set;}
		@AuraEnabled public String Email{get;set;}
		@AuraEnabled public String PanNo{get;set;}
		@AuraEnabled public String Gender{get;set;}
		@AuraEnabled public OtherDetails otherDetails{get;set;}
		@AuraEnabled public String Name{get;set;}
    }

	public class OtherDetails{
		@AuraEnabled public String FkModuleID{get;set;}
		@AuraEnabled public String FkSubModuleID{get;set;}
		@AuraEnabled public String UserLoginID{get;set;}
		@AuraEnabled public String OtherKey1{get;set;}
		@AuraEnabled public Integer Pincode{get;set;}
		@AuraEnabled public String OtherKey2{get;set;}
		@AuraEnabled public String PermanentAddress{get;set;}
	}
*/
}