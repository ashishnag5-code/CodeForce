@isTest
public with sharing class HealthInsurancePremiumApi {
/*
  @AuraEnabled
  public Static List<Applicant__c> getApplicant(String applcntId) {
      List<Applicant__c> applicantList = [SELECT Id, Loan__r.Loan_Amount__c, Loan__r.Tenure__c, Gender__c, Age__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                                 Mobile_Number__c, Email__c, Customer_Type__c
                                          FROM Applicant__c 
                                          WHERE Id =:applcntId WITH SECURITY_ENFORCED];
      
      return applicantList;
  }

  
  public Static List<Applicant__c> getApplicant(String loanApplcntId, List<String> recordTypeList) {
      List<Applicant__c> applicantList = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c,Loan__r.Loan_Amount__c, Loan__r.Tenure__c, Gender__c, Age__c,
                                          Mobile_Number__c, Email__c, Customer_Type__c
                                          FROM Applicant__c 
                                          WHERE (Loan__c =: loanApplcntId And RecordType.Name =: recordTypeList) WITH SECURITY_ENFORCED];
      
      return applicantList;
  }

  @AuraEnabled
  public Static List<Address__c> getAddress(String applcntId, String addressType) {
      List<Address__c> addressList = [SELECT Id, Pincode__c
                                      FROM Address__c 
                                      WHERE (Applicant__c =:applcntId AND Address_Type__c = :addressType) WITH SECURITY_ENFORCED];
      return addressList;
  }

  public Static Map<String, String> initGenderMap2() {
    return new Map<String, String>{
        'Male' => 'M',
        'Female'  => 'F',
        'Transgender'  => 'T'
      };
}
  
  public HealthInsuranceHandlerWrapp healthInsuranceCallOut(String applcntId, String appplcntIdFromUi, String loanApplicantId, String masterRecord) {
      String respBody;
      
      Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
      Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanApplicantId);
      
      String requestBody = generateRequest(loanApplicantId, applcntId, appplcntIdFromUi);
      HealthInsuranceHandlerWrapp healthInsObj = new HealthInsuranceHandlerWrapp();
      healthInsObj.healthInsuranceReq          = requestBody; 
      system.debug('%%'+requestBody);
      IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
      calloutRequestWrapper.request = requestBody;
      calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
      calloutRequestWrapper.masterRecord = objIntMapper;
      calloutRequestWrapper.checklistRecord = checklistRecord;
      IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
      system.debug('calloutResponseWrapper '+calloutResponseWrapper);
      respBody = calloutResponseWrapper.response;
      healthInsObj.healthInsuranceResp = respBody;

      return healthInsObj;
  }

  public Static List<CustomerTypeOptions> getApplicantFullName(String applicantId, String loanApplId, List<String> recordTypeList) {
     
    List<Applicant__c> applicant      = getApplicant(loanApplId, recordTypeList).size() > 0 ? getApplicant(loanApplId, recordTypeList) : new List<Applicant__c>();
    List<CustomerTypeOptions>       listOfApplName = new List<CustomerTypeOptions>(); 

    for(Applicant__c appl : applicant) {

      String applcntFirstName  = String.isNotBlank(appl.First_Name__c) ? appl.First_Name__c : '';
      String applcntMiddleName = String.isNotBlank(appl.Middle_Name__c) ? appl.Middle_Name__c : '';
      String applcntLastName   = String.isNotBlank(appl.Last_Name__c) ? appl.Last_Name__c : '';
      String applcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;

      CustomerTypeOptions curtmrTypeOptions = new CustomerTypeOptions();
      curtmrTypeOptions.label               = applcntFullName;
      curtmrTypeOptions.value               = appl.Id;
      listOfApplName.add(curtmrTypeOptions);
    }
    return listOfApplName;
  }

  public String generateRequest(String loanApplicantId, String applcntId, String appplcntIdFromUi) {
     
      List<String> recordTypeList = new List<String>{'Applicant', 'Co-Applicant'}; 
      Applicant__c applicant      = getApplicant(loanApplicantId, recordTypeList).size() > 0 ? getApplicant(loanApplicantId, recordTypeList)[0] : new Applicant__c();
      Applicant__c primaryApplcnt = getApplicant(appplcntIdFromUi).size() > 0 ? getApplicant(appplcntIdFromUi)[0] : new Applicant__c();

      Address__c   getAddress  = getAddress(applcntId, 'Current').size() > 0 ? getAddress(applcntId, 'Current')[0] : new Address__c();     
      String applcntFirstName  = String.isNotBlank(applicant.First_Name__c) ? applicant.First_Name__c : '';
      String applcntMiddleName = String.isNotBlank(applicant.Middle_Name__c) ? applicant.Middle_Name__c : '';
      String applcntLastName   = String.isNotBlank(applicant.Last_Name__c) ? applicant.Last_Name__c : '';

      String applcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;
      system.debug('getAddress-->'+getAddress);
      HealthPremiumRequestWrapper healthPremReqWrappObj = new HealthPremiumRequestWrapper();
      healthPremReqWrappObj.AuthToken                   = 'lIjoiXURtaW4iLCtJc3N1lXIiOiJJc3N1ZXIiL';
      healthPremReqWrappObj.HealthPremiumRequest        = new HealthPremiumRequest();
      healthPremReqWrappObj.OriginatingChannel          = 'SFDC';
      healthPremReqWrappObj.RequestId                   =  IntegrationUtility.getReferenceId();

      Integer age          =  primaryApplcnt.Age__c.intValue();
      Integer coverAmt     = applicant.Loan__r.Loan_Amount__c.intValue();
      Map<String, String> genderMap = initGenderMap2();

      HealthPremiumRequest healthPremReqObj = new HealthPremiumRequest();
      healthPremReqObj.AgentId              = '225';
      healthPremReqObj.apiKey               = 'F414278F-E6AC-41DE-912E-9D9DB3BC936IA';
      healthPremReqObj.CoverAmount          = String.valueOf(coverAmt);
      healthPremReqObj.Pincode              = getAddress.Pincode__c;
      healthPremReqObj.Deductible           = '0';
      healthPremReqObj.PrimaryGender        = genderMap.get(primaryApplcnt.Gender__c);
      healthPremReqObj.PrimaryAge           = String.valueOf(age);
      healthPremReqObj.SpouseAge            = '-1';
      healthPremReqObj.FatherAge            = '-1';
      healthPremReqObj.MotherAge            = '-1';
      healthPremReqObj.FatherinLawAge       = '-1';
      healthPremReqObj.MotherinLawAge       = '-1';
      healthPremReqObj.ChildGender          = '';
      healthPremReqObj.ChildAge             = '-1';
      healthPremReqObj.CategoryID           = '17';
      healthPremReqObj.PolicyTerm           = String.valueOf(applicant.Loan__r.Tenure__c);
      healthPremReqObj.VerticleID           = '2';
      healthPremReqObj.AppID                = '2';
      healthPremReqObj.HasLoanAccountNo     = '0';
      healthPremReqObj.ProposerFullName     = applcntFullName;
      healthPremReqObj.ProposerGender       = applicant.Gender__c; 
      healthPremReqObj.ProposerMobileNo     = applicant.Mobile_Number__c;
      healthPremReqObj.ProposerEmailID      = applicant.Email__c;
      healthPremReqObj.CustomerType         = 'SFDC';  

      healthPremReqWrappObj.HealthPremiumRequest = healthPremReqObj;   
      String req = JSON.serialize(healthPremReqWrappObj); 
      return req; 
  }  

  public class HealthPremiumRequestWrapper {
    @AuraEnabled public HealthPremiumRequest HealthPremiumRequest{get;set;}
    @AuraEnabled public String OriginatingChannel{get;set;}
    @AuraEnabled public String RequestId{get;set;}
    @AuraEnabled public String AuthToken{get;set;}                
  }

  public class CustomerTypeOptions {
    @AuraEnabled public String label{get;set;}
    @AuraEnabled public String value{get;set;}
  }

  public class HealthInsuranceHandlerWrapp {
    @AuraEnabled public String healthInsuranceReq{get;set;}
    @AuraEnabled public String healthInsuranceResp{get;set;}
  }

  public class HealthPremiumRequest {
    @AuraEnabled public String ChildGender{get;set;}
    @AuraEnabled public String MotherinLawAge{get;set;}
    @AuraEnabled public String ChildAge{get;set;}
    @AuraEnabled public String FatherinLawAge{get;set;}
    @AuraEnabled public String CategoryID{get;set;}
    @AuraEnabled public String MotherAge{get;set;}
    @AuraEnabled public String PolicyTerm{get;set;}    // PolT
    @AuraEnabled public String FatherAge{get;set;}
    @AuraEnabled public String VerticleID{get;set;}
    @AuraEnabled public String SpouseAge{get;set;}
    @AuraEnabled public String AppID{get;set;}
    @AuraEnabled public String PrimaryAge{get;set;}   // PA
    @AuraEnabled public String HasLoanAccountNo{get;set;}
    @AuraEnabled public String PrimaryGender{get;set;}
    @AuraEnabled public String ProposerFullName{get;set;}
    @AuraEnabled public String Deductible{get;set;}
    @AuraEnabled public String ProposerGender{get;set;}
    @AuraEnabled public String Pincode{get;set;}
    @AuraEnabled public String ProposerMobileNo{get;set;}
    @AuraEnabled public String CoverAmount{get;set;}  // CA
    @AuraEnabled public String ProposerEmailID{get;set;}
    @AuraEnabled public String apiKey{get;set;}
    @AuraEnabled public String CustomerType{get;set;}
    @AuraEnabled public String AgentId{get;set;}
} 

  public class HealthPremiumResponseWrapper {
    @AuraEnabled public HealthPremiumResponse HealthPremiumResponse{get;set;}
    @AuraEnabled public String Status{get;set;}
    @AuraEnabled public String ErrorMessage{get;set;}    
    @AuraEnabled public String ResponseID{get;set;}    
  }

  public class HealthPremiumResponse{
    @AuraEnabled public String ProductName{get;set;}
    @AuraEnabled public String ProductID{get;set;}
    @AuraEnabled public String Premium{get;set;}
    @AuraEnabled public String PremiumWithTax{get;set;}
    @AuraEnabled public String Status{get;set;}
    @AuraEnabled public String Error{get;set;}
    @AuraEnabled public String Tax{get;set;}
    @AuraEnabled public String CompanyID{get;set;}
    @AuraEnabled public String SA{get;set;}
    @AuraEnabled public String FamilyID{get;set;}
    @AuraEnabled public String TabID{get;set;}
    @AuraEnabled public String CityID{get;set;}
  }

  public class HealthRetunFromPreviousRequest {
    @AuraEnabled public Response Response{get;set;}
		@AuraEnabled public String indentifyApi{get;set;}
		@AuraEnabled public request request{get;set;}
  }

  public class Response{
		@AuraEnabled public String ResponseID{get;set;}
		@AuraEnabled public String Status{get;set;}
		@AuraEnabled public HealthPremiumResponse HealthPremiumResponse{get;set;}
	}
	public class request{
		@AuraEnabled public String RequestId{get;set;}
		@AuraEnabled public HealthPremiumRequest HealthPremiumRequest{get;set;}
		@AuraEnabled public String OriginatingChannel{get;set;}
		@AuraEnabled public String AuthToken{get;set;}
	}
*/
}