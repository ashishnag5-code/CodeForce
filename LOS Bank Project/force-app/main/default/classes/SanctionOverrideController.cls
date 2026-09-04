public without sharing class SanctionOverrideController {
    @AuraEnabled
    public static String returnCurrentUserLoggedInId(String recordId){
        return UserInfo.getUserId();
    }
    
   

}