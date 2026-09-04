@isTest
public with sharing class InsuranceApi {
/*    
    public static List<Display_Data__mdt> getMetadataRecord(String rType){
        List<Display_Data__mdt> dispData = [SELECT Id, DeveloperName, MasterLabel, Display_on_UI__c, JSON_Key__c, API_Name__c,Order__c
                                            FROM Display_Data__mdt 
                                            WHERE Type__c =: rType WITH SECURITY_ENFORCED 
                                            ORDER BY Order__c asc];
        return dispData;
    }

    @AuraEnabled
    public Static List<Applicant__c> getApplicant(String loanApplcntId, List<String> recordTypeList) {
        List<Applicant__c> applicantList = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c
                                            FROM Applicant__c 
                                            WHERE (Loan__c =: loanApplcntId And RecordType.Name =: recordTypeList) WITH SECURITY_ENFORCED];
        
        return applicantList;
    }

    @AuraEnabled
    public Static InsuranceApiWrapper insuranceHandler(String applcntId, String appplcntIdFromUi, String loanApplCntId, String integMasterName) {

        InsuranceApi insuranceClassObj = new InsuranceApi();
        String request  = '';
        String response = '';
        List<sobject> metaData = new List<sobject>();
        InsuranceApiWrapper insuranceObj                       = new InsuranceApiWrapper(); 
        HealthInsurancePremiumApi healthInsurancePremiumApiObj = new HealthInsurancePremiumApi();
        LifeInsurancePremiumApi   lifeInsurancePremiumApiObj   = new LifeInsurancePremiumApi();

        insuranceObj.metadata =  new List<Sobject>();
        if(integMasterName == 'Health Insurance Premium') {
            HealthInsurancePremiumApi.HealthInsuranceHandlerWrapp healthReqAndRes = healthInsurancePremiumApiObj.healthInsuranceCallOut(applcntId, appplcntIdFromUi, loanApplCntId, integMasterName);
            response = healthReqAndRes.healthInsuranceResp;
            request  = healthReqAndRes.healthInsuranceReq;
            if(response != 'Not Found') {
              HealthInsurancePremiumApi.HealthPremiumResponseWrapper respObj = (HealthInsurancePremiumApi.HealthPremiumResponseWrapper) System.JSON.deserialize(response, HealthInsurancePremiumApi.HealthPremiumResponseWrapper.class);
              HealthInsurancePremiumApi.HealthPremiumRequestWrapper  reqeObj = (HealthInsurancePremiumApi.HealthPremiumRequestWrapper) System.JSON.deserialize(request, HealthInsurancePremiumApi.HealthPremiumRequestWrapper.class);
              insuranceObj.toIndentifyApi   = 'Health Insurance Premium';
              insuranceObj.healthInsuranceRequest  = reqeObj;
              insuranceObj.healthInsuranceResponse = respObj;
              insuranceObj.metadata =  getMetadataRecord('Health Insurance');
            }
            else if(response == 'Not Found') {
              insuranceObj.message = 'Not Found';
            }
        }
        else if(integMasterName == 'Life Insurance Premium') {
     
            LifeInsurancePremiumApi.LifeInsuranceHandlerWrapp lifeReqAndRes= lifeInsurancePremiumApiObj.lifeInsurancePremiumCallOut(applcntId, appplcntIdFromUi, loanApplCntId, integMasterName);
            response = lifeReqAndRes.lifeInsuranceResp;
            request  = lifeReqAndRes.lifeInsuranceReq; 
        //   system.debug('lifeReqAndRes-- '+JSON.serialize(lifeReqAndRes));
            String decodedJson = (String)JSON.deserialize(JSON.serialize(lifeReqAndRes), String.class);
           system.debug('lifeReqAndRes-- ' + decodedJson );
            LifeInsurancePremiumApi.LifePremiumResponseWrapper deserializeObj;
            if(response != 'Not Found') {
                LifeInsurancePremiumApi.LifePremiumResponseWrapper respObj = (LifeInsurancePremiumApi.LifePremiumResponseWrapper) System.JSON.deserialize(response, LifeInsurancePremiumApi.LifePremiumResponseWrapper.class);
                LifeInsurancePremiumApi.LifePremiumRequestWrapper  reqeObj = (LifeInsurancePremiumApi.LifePremiumRequestWrapper) System.JSON.deserialize(request, LifeInsurancePremiumApi.LifePremiumRequestWrapper.class);
                insuranceObj.toIndentifyApi = 'Life Insurance Premium';
                insuranceObj.lifeInsuranceResponse = respObj;
                insuranceObj.lifeInsuranceRequest = reqeObj;
                insuranceObj.metadata =  getMetadataRecord('Life Insurance');
            } else if(response == 'Not Found'){
                insuranceObj.message = 'Not Found';
            }
        }
        return insuranceObj;
      }

      
      public Static List<Insurance__mdt> getInsuranceMetadata(String insuranceType) {
        List<Insurance__mdt> getInsMetadataList = [Select id, Name__c, Insurance_Type__c
                                                  From Insurance__mdt 
                                                  WHERE name__c = :insuranceType WITH SECURITY_ENFORCED];
        return getInsMetadataList;
      }

      @AuraEnabled
      public static InsuranceApiWrapper getApplicantFullName(String loanApplId, List<String> recordTypeList) {
        InsuranceApiWrapper insuranceApiObj = new InsuranceApiWrapper();

        List<Applicant__c> applicant      = getApplicant(loanApplId, recordTypeList).size() > 0 ? getApplicant(loanApplId, recordTypeList) : new List<Applicant__c>();
        List<CustomerTypeOptions> listOfApplName = new List<CustomerTypeOptions>();

        for(Applicant__c appl : applicant) {
  
          String applcntFirstName  = String.isNotBlank(appl.First_Name__c) ? appl.First_Name__c : '';
          String applcntMiddleName = String.isNotBlank(appl.Middle_Name__c) ? appl.Middle_Name__c : '';
          String applcntLastName   = String.isNotBlank(appl.Last_Name__c) ? appl.Last_Name__c : '';
          String appplcntFullName   = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;
  
          CustomerTypeOptions curtmrTypeOptions = new CustomerTypeOptions();
          curtmrTypeOptions.label               = appplcntFullName;
          curtmrTypeOptions.value               = appl.Id;
          listOfApplName.add(curtmrTypeOptions);    
        }
        List<Insurance__mdt> insurMedata = getInsuranceMetadata('Product Vs InsuranceType');
        insuranceApiObj.customerTypeOptions = new List<CustomerTypeOptions>();
        insuranceApiObj.customerTypeOptions = listOfApplName;
        insuranceApiObj.productVsInsuranceTypeMetada = new Insurance__mdt();
        insuranceApiObj.productVsInsuranceTypeMetada = insurMedata.size() > 0 ? insurMedata[0] : new Insurance__mdt();

        return insuranceApiObj;
      }

      public class InsuranceApiWrapper {
        @AuraEnabled public String toIndentifyApi;
        @AuraEnabled public String message;
        @AuraEnabled public List<Sobject> metadata;
        @AuraEnabled public HealthInsurancePremiumApi.HealthPremiumResponseWrapper healthInsuranceResponse;
        @AuraEnabled public HealthInsurancePremiumApi.HealthPremiumRequestWrapper  healthInsuranceRequest;
        @AuraEnabled public LifeInsurancePremiumApi.LifePremiumResponseWrapper     lifeInsuranceResponse;
        @AuraEnabled public LifeInsurancePremiumApi.LifePremiumRequestWrapper     lifeInsuranceRequest;
        @AuraEnabled public List<CustomerTypeOptions> customerTypeOptions;
        @AuraEnabled public Insurance__mdt productVsInsuranceTypeMetada;
      }

      public class CustomerTypeOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
      } 
*/
}