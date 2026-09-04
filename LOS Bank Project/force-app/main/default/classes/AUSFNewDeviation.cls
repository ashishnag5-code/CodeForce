public with sharing class AUSFNewDeviation {
    @AuraEnabled
    public static List<Manual_Deviation_Master__c> getRecords(String loanId,String department){

        try {
            List<Loan_Application__c> loanApps = [SELECT Id,Product__c FROM Loan_Application__c Where Id =: loanId];
            AUSFVehicleController.TypeOfWheeler vehicleType = AUSFVehicleController.getTypeOfWheeler(loanApps[0].Product__c);
            List<Manual_Deviation_Master__c> deviationMasterList = new List<Manual_Deviation_Master__c>();
            if(vehicleType.isTwoWheeler){
                deviationMasterList = [SELECT Id,Department__c,Deviation_Description__c,Deviation_Level__c,Product__c,Rule_Type__c FROM Manual_Deviation_Master__c WHERE Department__c =: department AND Product__c = 'Two Wheeler' WITH SECURITY_ENFORCED];
            }else{
                deviationMasterList = [SELECT Id,Department__c,Deviation_Description__c,Deviation_Level__c,Product__c,Rule_Type__c FROM Manual_Deviation_Master__c WHERE Department__c =: department AND Product__c = 'Four Wheeler' WITH SECURITY_ENFORCED];
            }
            return deviationMasterList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Deviation__c getDeviationRecords(String deviationId){
        try {
            Deviation__c deviationRecord = [SELECT Id,Actual_Value__c,Department__c,Details__c,Deviation_Type__c,Level__c,Policy_Value__c,Variance__c,Loan_Application__c,Mitigates__c,Source__c FROM Deviation__c WHERE Id =: deviationId WITH SECURITY_ENFORCED LIMIT 1][0];
            return deviationRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static User getUserDetails(){
        List<User> currentUser = [SELECT Id, Profile.Name, Ops_User_Type__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(currentUser!=null && currentUser.size()>0){
            return currentUser[0];
        }else{
            return null;
        }
    }

}