public with sharing class BiometricController {
  @AuraEnabled
  public static String getApplicantDetails(String recordId) {
    List<Integration_Checklist__c> checkList =  [SELECT Id,Response__c from Integration_Checklist__c WHERE Id=:recordId];
    system.debug('checkList'+checkList);
    //String value1 = JSONReservedSerializer_AUSF.replaceJSONKeywords(checkList[0]?.Response__c); 
    OCRPanCardRespWrapper ocrResponseParse = OCRPanCardRespWrapper.parse(checkList[0]?.Response__c);
    system.debug('ocrResponseParse'+ocrResponseParse);
    return JSON.serialize(ocrResponseParse);
 }
}