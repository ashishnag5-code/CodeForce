public with sharing class ComponentProfileRestrictionController {
    @AuraEnabled
    public static boolean restricAccess(String compName, String loanId){
        /*if (loanId?.substring(0, 3) != Loan_Application__c.SObjectType.getDescribe().getKeyPrefix()) {
            return false;
        }*/
        if (loanId?.substring(0, 3) == Field_Investigation__c.SObjectType.getDescribe().getKeyPrefix()) {
            return false;
        }
        try {
            System.debug('****'+compName);
            User usrInfo = [Select id, profile.Name, Ops_User_Type__c from User where id =: UserInfo.getUserId()];
            if(usrInfo.Profile.Name == 'System Administrator'){
                return false;
            }
            Id recId  = String.isNotBlank(loanId) ? loanId : '';
            String strObjectName = recId.getSObjectType().getDescribe().getName();
            Loan_Application__c loan;
            if(strObjectName=='Loan_Application__c'){
                loan = [Select id, Stage__c from Loan_Application__c where id =:loanId ];
            }else if(strObjectName=='Assignment__c'){
                Assignment__c assignment = [Select id, Loan_Application__c from Assignment__c where id =:loanId ];
                loan = [Select id, Stage__c from Loan_Application__c where id =:assignment.Loan_Application__c ];
            }
            else if(strObjectName=='Deviation__c'){
                Deviation__c record = [SELECT Id, Loan_Application__c FROM Deviation__c WHERE Id=:loanId];
                loan = [Select id, Stage__c from Loan_Application__c where id =:record.Loan_Application__c ];
            }
            usrInfo.Profile.Name = Utility.getRestrictProfile(usrInfo.Profile.Name);
            
            //if(loan.Stage__c=='Ops Maker' || loan.Stage__c=='Ops Author'){
            if(usrInfo.Profile.Name == 'Ops'){
                if(usrInfo.Ops_User_Type__c == 'Ops Maker'){
                    usrInfo.Profile.Name = Utility.getRestrictProfile('Ops Maker');
                }
                else if(usrInfo.Ops_User_Type__c == 'Ops Author'){
                    usrInfo.Profile.Name = Utility.getRestrictProfile('Ops Author');
                }
            }
            
            system.debug('Current User Profile '+usrInfo.Profile.Name);
            // if(usrInfo.Profile.Name == 'Credit Manager'){
            //     usrInfo.Profile.Name = 'Credit';
            // }

            // if(usrInfo.Profile.Name == 'RO'){
            //     usrInfo.Profile.Name = 'Sales';
            // }
            
            //Loan_Application__c loan = [Select id, Stage__c from Loan_Application__c where id =:loanId ];
            for(Component_Profile_Restriction__mdt gpr: Component_Profile_Restriction__mdt.getAll().values()){
                List<String> profileNameList = gpr.Profile_Name__c.split(';');
                /*System.debug('****'+usrInfo.profile.Name);
                System.debug('****'+profileNameList);
                System.debug('****'+ loan?.Stage__c);
                System.debug('****'+gpr.Restrict_Access__c);
                System.debug('**** Is retricted =='+gpr.Component_Name__c == compName && profileNameList.contains(usrInfo.profile.Name) && gpr.Stage__c == loan.Stage__c && gpr.Restrict_Access__c);*/
                if(gpr.Component_Name__c == compName && profileNameList.contains(usrInfo.profile.Name) &&
                gpr.Stage__c == loan.Stage__c && gpr.Restrict_Access__c){
                    return true;
                }else{
                    System.debug('****false condition');
                }
            }
            if(usrInfo.profile.Name == 'Credit'){
                return !Utility.canCreditUserEdit( loan, usrInfo.Id );
            }
            return false;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static RestrictControllerWrapper validateRecordEdit(String compName, String recordId){
        RestrictControllerWrapper objWrap = new RestrictControllerWrapper();
        objWrap.blnRestrictEdit = false;
        objWrap.blnMoveNext = true;
        try {
            User usrInfo = [Select id, profile.Name, Ops_User_Type__c from User where id =: UserInfo.getUserId()];
            
            usrInfo.Profile.Name = Utility.getRestrictProfile(usrInfo.Profile.Name);
            if(usrInfo.Profile.Name == 'System Administrator'){
                objWrap.blnRestrictEdit = false;
                return objWrap;
            }
            
            if(usrInfo.Profile.Name == 'Credit Manager'){
                usrInfo.Profile.Name = 'Credit';
            }

            //4473
            if(usrInfo.Profile.Name == 'Operations' || usrInfo.Profile.Name == 'Ops'){
                usrInfo.Profile.Name = usrInfo.Ops_User_Type__c;
            }
            
            Id recId  = String.isNotBlank(recordId) ? recordId : '';
            
            String strObjectName = recId.getSObjectType().getDescribe().getName();
            String strStage = '';
            Loan_Application__c loan = null;
            if (strObjectName == 'Loan_Application__c') {
                loan = [Select id, Stage__c from Loan_Application__c where id =:recordId];
                strStage = loan.Stage__c;
            }
            else if (strObjectName == 'Applicant__c') {
                Applicant__c objApp = [Select id, Loan__c, Loan__r.Stage__c from Applicant__c where id = :recordId];
                loan = [Select id, Stage__c from Loan_Application__c where id =:objApp.Loan__c];
                strStage = loan.Stage__c;
            }
            else if (strObjectName == 'Address__c') {
                Address__c objAdd = [Select id, Applicant__r.Loan__c, Applicant__r.Loan__r.Stage__c from Address__c where id = :recordId];
                loan = [Select id, Stage__c from Loan_Application__c where id =: objAdd.Applicant__r.Loan__c];
                strStage = loan.Stage__c;
            }
            for(Component_Profile_Restriction__mdt gpr: Component_Profile_Restriction__mdt.getAll().values()){
                List<String> profileNameList = gpr.Profile_Name__c.split(';');
                if(gpr.Component_Name__c == compName && profileNameList.contains(usrInfo.profile.Name) &&
                gpr.Stage__c == strStage && gpr.Restrict_Access__c){
                    objWrap.blnRestrictEdit = true;
                    return objWrap;
                }
            }
            objWrap.blnRestrictEdit = !Utility.canCreditUserEdit( loan, usrInfo.Id );
            //return !Utility.canCreditUserEdit( loan, usrInfo.Id );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return objWrap;
    }
    
    public class RestrictControllerWrapper {
        @AuraEnabled
        public Boolean blnRestrictEdit = true;
        @AuraEnabled
        public Boolean blnMoveNext = true;
    }
}