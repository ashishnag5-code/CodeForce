@isTest
public with sharing class LifeInsurancePremiumApi {
/*
    public Map<String, String> genderMap;

    public LifeInsurancePremiumApi() {
        genderMap = new Map<String, String>{
            'Male'         => 'M',
            'Female'       => 'F',
            'Transgender'  => 'T'
        };
    }

    @AuraEnabled
    public Static List<Applicant__c> getApplicant(String applcntId) {
        List<Applicant__c> applicantList = [SELECT Id, Loan__r.Loan_Amount__c, Loan__r.Tenure__c, Gender__c, Age__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                            Mobile_Number__c, Email__c, Dob__c, Customer_Type__c
                                            FROM Applicant__c WHERE Id =:applcntId WITH SECURITY_ENFORCED];
        
        return applicantList;
    }
    
    public LifeInsuranceHandlerWrapp lifeInsurancePremiumCallOut(String applicantId, String appplcntIdFromUi, String loanApplCntId, String masterRecord) {
        String respBody;
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanApplCntId);
        
        String requestBody = generateRequest(applicantId);
        LifeInsuranceHandlerWrapp lifeInsObj = new LifeInsuranceHandlerWrapp();
        lifeInsObj.lifeInsuranceReq = requestBody;

        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        system.debug('calloutResponseWrapper '+calloutResponseWrapper);
        respBody = calloutResponseWrapper.response;

        lifeInsObj.lifeInsuranceResp = respBody;
        return lifeInsObj;
    }

    public String generateRequest(String applicantId) {

        Applicant__c applicant   = getApplicant(applicantId).size() > 0 ? getApplicant(applicantId)[0] : new Applicant__c();

        String applcntFirstName  = String.isNotBlank(applicant.First_Name__c) ? applicant.First_Name__c : '';
        String applcntMiddleName = String.isNotBlank(applicant.Middle_Name__c) ? applicant.Middle_Name__c : '';
        String applcntLastName   = String.isNotBlank(applicant.Last_Name__c) ? applicant.Last_Name__c : '';

        String applcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;

        LifePremiumRequestWrapper lifePremReqWrappObj = new LifePremiumRequestWrapper();
        lifePremReqWrappObj.AuthToken                   = 'lIjoiXTRtaW7iLCtJc7N1lXIiOiJOc3N1ZXIiL';
        lifePremReqWrappObj.LifePremiumRequest        = new LifePremiumRequest();

        String applcntGender              = applicant.Gender__c;
        LifePremiumRequest lifePremReqObj = new LifePremiumRequest();
        lifePremReqObj.Mode               = '1';
        lifePremReqObj.Smoker             = '0';
        lifePremReqObj.Input_DOB          = applicant.Dob__c;
        lifePremReqObj.OptionType         = 'SUM ASSURED';
        lifePremReqObj.VerticleID         = '5';
        lifePremReqObj.Amount             = applicant.Loan__r.Loan_Amount__c;
        lifePremReqObj.HasLoanAccountNo   = '1';
        lifePremReqObj.PPT                = '1';
        lifePremReqObj.ProposerFullName   = applcntFullName;
        lifePremReqObj.ProposerGender     = applicant.Gender__c;
        lifePremReqObj.PT                 = '10'; 
        lifePremReqObj.Gender             = genderMap.get(applicant.Gender__c);
        lifePremReqObj.ProposerMobileNo   = applicant.Mobile_Number__c;
        lifePremReqObj.Age                = applicant.Age__c;
        lifePremReqObj.ProposerEmailID    = applicant.Email__c;
        lifePremReqObj.APIKEY             = 'F414278F-E6AC-41DE-912E-9D9DB3BC936IA';
        lifePremReqObj.CustomerType       = 'RLOS';
        lifePremReqObj.regId              = '225';

        lifePremReqWrappObj.LifePremiumRequest = lifePremReqObj;
        String req = JSON.serialize(lifePremReqWrappObj);
        return req;
    }

    public class LifeInsuranceHandlerWrapp {
      @AuraEnabled public String lifeInsuranceReq{get;set;}
      @AuraEnabled public String lifeInsuranceResp{get;set;}
    }

    public class LifeInsurancePremiumHandlerWrapper {
      @AuraEnabled public String toIndentifyApi;  
      @AuraEnabled public LifePremiumRequestWrapper lifePremiumResponseWrappper;  
    }

    public class LifePremiumRequestWrapper {
      public LifePremiumRequest LifePremiumRequest{get;set;}
      public String AuthToken{get;set;}        
    }

    public class LifePremiumRequest{
      @AuraEnabled public String Mode{get;set;}
      @AuraEnabled public String Smoker{get;set;}
      @AuraEnabled public Date Input_DOB{get;set;}
      @AuraEnabled public String OptionType{get;set;}
      @AuraEnabled public String VerticleID{get;set;}
      @AuraEnabled public Decimal Amount{get;set;}
      @AuraEnabled public String HasLoanAccountNo{get;set;}
      @AuraEnabled public String PPT{get;set;}
      @AuraEnabled public String ProposerFullName{get;set;}
      @AuraEnabled public String PT{get;set;}
      @AuraEnabled public String ProposerGender{get;set;}
      @AuraEnabled public String Gender{get;set;}
      @AuraEnabled public String ProposerMobileNo{get;set;}
      @AuraEnabled public Decimal Age{get;set;}
      @AuraEnabled public String ProposerEmailID{get;set;}
      @AuraEnabled public String APIKEY{get;set;}
      @AuraEnabled public String CustomerType{get;set;}
      @AuraEnabled public String regId{get;set;}
	}

    public class LifePremiumResponseWrapper {
      @AuraEnabled public LifePremiumResponse LifePremiumResponse{get;set;}
      @AuraEnabled public String ResponseID{get;set;}
      @AuraEnabled public String Status{get;set;}
      @AuraEnabled public String ErrorMessage{get;set;}
    }
    
    public class LifePremiumResponse{
      @AuraEnabled public String Status{get;set;}
      @AuraEnabled public String ProductName{get;set;}
      @AuraEnabled public Integer SA{get;set;}
      @AuraEnabled public Integer ProductId{get;set;}
      @AuraEnabled public Decimal Tax{get;set;}
      @AuraEnabled public Decimal ModalPremium{get;set;}
      @AuraEnabled public list<prodInputs> prodInputs{get;set;}
      @AuraEnabled public Integer ModalPremWithTax{get;set;}
      @AuraEnabled public String Error{get;set;}
      @AuraEnabled public String CompID{get;set;}
	}

    public class prodInputs{
      @AuraEnabled public String value{get;set;}
      @AuraEnabled public String key{get;set;}
	}
*/
}