@isTest
public with sharing class RedirectToProposal {
/*
    @AuraEnabled
  public Static List<Applicant__c> getApplicant(String applcntId) {
      List<Applicant__c> applicantList = [SELECT Id, Loan__r.Loan_Amount__c, Loan__r.Tenure__c, Gender__c, Age__c, First_Name__c, Middle_Name__c, Last_Name__c,
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
    public Static RequestWrapper redirectToProposalHealth(String applicantId, String docMstrName, Object reqAndRespFromApi, String loanAppId) {

        RedirectToProposal redToPropObj          = new RedirectToProposal();
        system.debug('inside reqAndRespFromApi-->'+ reqAndRespFromApi);
        Map<String,Object> mapOfHealthReqAndResp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqAndRespFromApi));
        HealthInsurancePremiumApi.HealthPremiumRequestWrapper  healthRequest = (HealthInsurancePremiumApi.HealthPremiumRequestWrapper) JSON.deserialize(JSON.serialize(mapOfHealthReqAndResp.get('request')),HealthInsurancePremiumApi.HealthPremiumRequestWrapper.class);
        HealthInsurancePremiumApi.HealthPremiumResponseWrapper reqAndRespFromAInsspi    = (HealthInsurancePremiumApi.HealthPremiumResponseWrapper) JSON.deserialize(JSON.serialize(mapOfHealthReqAndResp.get('Response')), HealthInsurancePremiumApi.HealthPremiumResponseWrapper.class);
        Map<String,Object> mapOfHealthReq        = new Map<String,Object>();
        Map<String,Object> mapOfHealthResp       = new Map<String,Object>();
        system.debug('inside reqAndRespFromAInsspi-->'+ reqAndRespFromAInsspi);
        RequestWrapper requestForHealth= redToPropObj.generateReqForHealth(applicantId, docMstrName, healthRequest, reqAndRespFromAInsspi, loanAppId);        
        
        return requestForHealth;
    }

    public RequestWrapper generateReqForHealth(String applicantId, String docMstrName, HealthInsurancePremiumApi.HealthPremiumRequestWrapper  healthRequest, HealthInsurancePremiumApi.HealthPremiumResponseWrapper reqAndRespFromAInsspi, String loanAppId) { 
        Map<String,Object> mapOfHealthReqAndResp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(reqAndRespFromAInsspi));
        system.debug('inside reqAndRespFromAInsspi-->'+ reqAndRespFromAInsspi);
        system.debug('inside mapOfHealthReqAndResp-->'+ mapOfHealthReqAndResp);

        String userId = UserInfo.getUserId();
        List<User> userInfo = [Select id, Employee_Code__c from User where id = :userId];

        String recorTypeName = '';
        String typeOfProposer = '';
        List<Applicant__c> applicantList      = getApplicant(applicantId).size() > 0 ? getApplicant(applicantId) : new List<Applicant__c>();
        
        Applicant__c applcnt = new Applicant__c();
        if(applicantList.size() > 0) {
            applcnt = applicantList[0];
            recorTypeName = applcnt.RecordType.Name;
        }

        String applcntFirstName  = String.isNotBlank(applcnt.First_Name__c) ? applcnt.First_Name__c : '';
        String applcntMiddleName = String.isNotBlank(applcnt.Middle_Name__c) ? applcnt.Middle_Name__c : '';
        String applcntLastName   = String.isNotBlank(applcnt.Last_Name__c) ? applcnt.Last_Name__c : '';
        String applcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;

        RequestWrapper reqWrapp = new RequestWrapper();
        String responseId = reqAndRespFromAInsspi.ResponseID;
        reqWrapp.ResponseID = responseId;

        if(recorTypeName == 'Applicant') {
            typeOfProposer = 'Borrower';
        }
        else if(recorTypeName == 'Co-Applicant') {
            typeOfProposer = 'CoBorrower';
        }

        List<TransactionJson> transationObjLst = new List<TransactionJson>();

        Map<String, String> mapOfKeyToValue = new Map<String, String>();
        mapOfKeyToValue.put('NetPremium', reqAndRespFromAInsspi.HealthPremiumResponse.Premium);
        mapOfKeyToValue.put('Tax',          reqAndRespFromAInsspi.HealthPremiumResponse.Tax);
        mapOfKeyToValue.put('GrossPremium', reqAndRespFromAInsspi.HealthPremiumResponse.PremiumWithTax);
        mapOfKeyToValue.put('ProductID',   reqAndRespFromAInsspi.HealthPremiumResponse.ProductID);
        mapOfKeyToValue.put('ProductName', (reqAndRespFromAInsspi.HealthPremiumResponse.ProductName).trim());
        mapOfKeyToValue.put('CompanyID',   reqAndRespFromAInsspi.HealthPremiumResponse.CompanyID);
        mapOfKeyToValue.put('CoverAmount', reqAndRespFromAInsspi.HealthPremiumResponse.SA);
        mapOfKeyToValue.put('LoanAccNo',   '');
        mapOfKeyToValue.put('MemberType',  typeOfProposer);
        mapOfKeyToValue.put('PT',          healthRequest.HealthPremiumRequest.PolicyTerm);
        mapOfKeyToValue.put('Deductibleamount','0');
        mapOfKeyToValue.put('Gender',         healthRequest.HealthPremiumRequest.PrimaryGender);
        mapOfKeyToValue.put('SelfAge',        healthRequest.HealthPremiumRequest.PrimaryAge);
        mapOfKeyToValue.put('SpouseAge',      healthRequest.HealthPremiumRequest.SpouseAge);
        mapOfKeyToValue.put('FatherAge',      healthRequest.HealthPremiumRequest.FatherAge);
        mapOfKeyToValue.put('MotherAge',      healthRequest.HealthPremiumRequest.MotherAge);
        mapOfKeyToValue.put('FatherinLawAge', healthRequest.HealthPremiumRequest.FatherinLawAge);
        mapOfKeyToValue.put('MotherinLawAge', healthRequest.HealthPremiumRequest.MotherinLawAge);
        mapOfKeyToValue.put('ChildGender',    '');
        mapOfKeyToValue.put('ChildAge',       healthRequest.HealthPremiumRequest.ChildAge);
        mapOfKeyToValue.put('Geography',      reqAndRespFromAInsspi.HealthPremiumResponse.CityID);
        mapOfKeyToValue.put('Name',           applcntFullName);
        mapOfKeyToValue.put('Mobile',         applcnt.Mobile_Number__c);
        mapOfKeyToValue.put('Email',          applcnt.Email__c);
        mapOfKeyToValue.put('FamilyID',       reqAndRespFromAInsspi.HealthPremiumResponse.FamilyID);
        mapOfKeyToValue.put('TabID',          reqAndRespFromAInsspi.HealthPremiumResponse.TabID);
        mapOfKeyToValue.put('isselfProposer', '1');
        mapOfKeyToValue.put('AddOnDetails',   '[]');
        mapOfKeyToValue.put('Category',       healthRequest.HealthPremiumRequest.CategoryID);
        mapOfKeyToValue.put('VerticleID',     healthRequest.HealthPremiumRequest.VerticleID);
        mapOfKeyToValue.put('FatherinLawAge', healthRequest.HealthPremiumRequest.FatherinLawAge);

        system.debug('serialize +'+ JSON.serializePretty(mapOfKeyToValue));

        for(String key : mapOfKeyToValue.keySet()) {
            TransactionJson transationObj = new TransactionJson();
            transationObj.Key = key;
            transationObj.Value = String.isNotBlank(mapOfKeyToValue.get(key)) ? mapOfKeyToValue.get(key) : '';
            transationObjLst.add(transationObj);
        }
        
        reqWrapp.transactionJson = new List<TransactionJson>();
        reqWrapp.transactionJson = transationObjLst;

        CustomerInfo customerInfo = new CustomerInfo();
        Map<String, String> mapOfCustomerInfoKeyToValue = new Map<String, String>();
            
        customerInfo.Name       =  applcntFullName;
        customerInfo.Gender     = applcnt.Gender__c;
        customerInfo.Email      = applcnt.Email__c;
        customerInfo.Mobile     = applcnt.Mobile_Number__c;
        customerInfo.DOB        =  String.valueOf(applcnt.Dob__c);
        customerInfo.PanNo      =  applcnt.PAN__c;
        customerInfo.CustomerID =  applcnt.CIF_No__c;

        reqWrapp.customerInfo = customerInfo;

        String otherKey2Val = applicantId + '_' + loanAppId;

        Map<String, String> address = getPermanentAddress(applicantId);
        String fullPermanentAddress = address.get('fullPermanentAddress');
        system.debug('address--' +address);
        String pincode              = address.get('pincode');
        OtherDetails otherDetObj = new OtherDetails();

        reqWrapp.customerInfo.OtherDetails = new OtherDetails();
        otherDetObj.FkModuleID        = '3';
        otherDetObj.FkSubModuleID     = '28'; 
        otherDetObj.PermanentAddress  = fullPermanentAddress;
        otherDetObj.Pincode           = Integer.valueOf(pincode);
        otherDetObj.UserLoginID       = userInfo[0].Employee_Code__c;
        otherDetObj.OtherKey1         = 'SFDC';
        otherDetObj.OtherKey2         = otherKey2Val;
        
        reqWrapp.customerInfo.OtherDetails = otherDetObj;
        return reqWrapp;
    }

    public static Map<String, String>  getPermanentAddress(String applicantId) {

        Map<String, String> mapOfaddress = new Map<String,String>();

        List<Address__c> permanentAddress = getAddress(applicantId, 'Permanent');
        if(permanentAddress.size() > 0) {
            Address__c address  = permanentAddress[0];

            String addressLine1 = String.isNotBlank(address.Address_Line_1__c) ? address.Address_Line_1__c : '';
            String addressLine2 = String.isNotBlank(address.Address_Line_2__c) ? address.Address_Line_2__c : '';
            String addressLine3 = String.isNotBlank(address.Address_Line_3__c) ? address.Address_Line_3__c : '';
            String city         = String.isNotBlank(address.City__c)           ? address.City__c : '';
            String pincode      = String.isNotBlank(address.Pincode__c)        ? address.Pincode__c : '';
            String district     = String.isNotBlank(address.District__c)       ? address.District__c : '';
            String state        = String.isNotBlank(address.State__c)         ? address.State__c : '';

            String fullPermanentAddress = addressLine1 + ' ' + addressLine2 + ' ' + addressLine3 + ' ' + city + ' ' + pincode + ' ' + district + ' ' + state;
            mapOfaddress.put('fullPermanentAddress', fullPermanentAddress);
            mapOfaddress.put('pincode', pincode);

            return mapOfaddress;
        }
        return null;
    }

    public class HealthReqAndRespWrapper {
        @AuraEnabled public HealthInsurancePremiumApi.HealthPremiumRequestWrapper request;
        @AuraEnabled public HealthInsurancePremiumApi.HealthPremiumResponseWrapper response;
        @AuraEnabled public String indentifyApi;
        @AuraEnabled public Object metadata;      
    }

    public class RequestWrapper {
        @AuraEnabled public String ResponseID;
        @AuraEnabled public List<TransactionJson> transactionJson;
        @AuraEnabled public CustomerInfo customerInfo;
    }

    public class TransactionJson {
        @AuraEnabled public String Key;
        @AuraEnabled public String Value;
    }

    public class CustomerInfo {
        @AuraEnabled public String CustomerID{get;set;}
        @AuraEnabled public String Mobile{get;set;}
        @AuraEnabled public String DOB{get;set;}
        @AuraEnabled public String Email{get;set;}
        @AuraEnabled public String PanNo{get;set;}
        @AuraEnabled public String Gender{get;set;}
        @AuraEnabled public OtherDetails OtherDetails{get;set;}
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