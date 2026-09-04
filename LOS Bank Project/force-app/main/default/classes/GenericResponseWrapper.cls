public with sharing class GenericResponseWrapper {
    
    @AuraEnabled public string status;
    @AuraEnabled public string errorMessage;
}