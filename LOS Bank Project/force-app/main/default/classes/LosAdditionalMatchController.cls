public with sharing class LosAdditionalMatchController {
    
    @AuraEnabled
    public static List<Applicant__c> getApplicant(String recordId){
        system.debug('recordId'+recordId);
        List<Applicant__c> appList = new List<Applicant__c>();
        appList = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Applicant__c,
                   Last_CIBIL_Run_Date__c, CIBIL_Status__c, CIBIL_Rerun__c, Bureau_Score__c
                   FROM Applicant__c 
                   WHERE Id =: recordId WITH SECURITY_ENFORCED 
                   ORDER BY createddate DESC LIMIT 1];
        system.debug('appList'+appList);
        return appList;
    }

    //4733
    @AuraEnabled
    public static DetailsWrapper getLoanDetails(String recordId){
        DetailsWrapper newWrapper = new DetailsWrapper();
        List<Applicant__c> applicant = [Select Id, Loan__c,Loan__r.Stage__c,Loan__r.Vehicle_finalised__c from Applicant__c where Id=:recordId limit 1];
        newWrapper.currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        if(applicant!= null & applicant.size() > 0){
        	newWrapper.applicant = applicant[0];
        }
        return newWrapper;
    }

    public class DetailsWrapper{
        @AuraEnabled public Applicant__c applicant;
        @AuraEnabled public User currentUser;
    }
    
    
    @AuraEnabled
    public static Applicant__c createCibilRequest(String recordId){
        //ID jobID = System.enqueueJob(new CibilQueueable(recordId));
        Applicant__c applcntRec = [SELECT Id, CIBIL_Rerun__c, CIBIL_Status__c, Bureau_Score__c, Last_CIBIL_Run_Date__c FROM Applicant__c WHERE Id =: recordId];
        if(applcntRec.CIBIL_Rerun__c == true){
            applcntRec.CIBIL_Rerun__c = false;
            applcntRec.Last_CIBIL_Run_Date__c = system.today();
            Id jobId = System.enqueueJob(new CibilQueueable (recordId));
        }
        Applicant__c currntAppCibilWithInLastMonth;
        Applicant__c currntAppCibilBeforeLastMonth;
        Applicant__c othrAppCibilWithInLastMonth;
        Applicant__c othrAppCibilBeforeLastMonth;
        //Added by Samridhi - start
        AML.appWrapper existingDetailWrapper = AML.checkExistingApplicantCibil(recordId);
        if(existingDetailWrapper.currentApplicant!= null && existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c!= null){
            if(existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c > System.today().addDays(-30)){
                currntAppCibilWithInLastMonth = existingDetailWrapper.currentApplicant;
            }else{
                currntAppCibilBeforeLastMonth = existingDetailWrapper.currentApplicant;
            }
        }else if(existingDetailWrapper.existingApplicant!= null && existingDetailWrapper.existingApplicant.Last_CIBIL_Run_Date__c!= null){
            if(existingDetailWrapper.existingApplicant.Last_CIBIL_Run_Date__c > System.today().addDays(-30)){
                othrAppCibilWithInLastMonth = existingDetailWrapper.existingApplicant;
            }else{
                othrAppCibilBeforeLastMonth = existingDetailWrapper.existingApplicant;
            }
        }
        
        /*
for(Applicant__c app : AML.checkExistingApplicantCibil(recordId)){
if(app.Id == recordId){
if(app.Last_CIBIL_Run_Date__c > System.today().addDays(-30))
currntAppCibilWithInLastMonth = app;
else
currntAppCibilBeforeLastMonth = app; 

}
else{
if(app.Last_CIBIL_Run_Date__c > System.today().addDays(-30))
othrAppCibilWithInLastMonth = app;
else
othrAppCibilBeforeLastMonth = app; 
}
}
*/
        //Added by Samridhi - end
        system.debug('currntAppCibilWithInLastMonth------>'+currntAppCibilWithInLastMonth);
        system.debug('currntAppCibilBeforeLastMonth------>'+currntAppCibilBeforeLastMonth);
        system.debug('othrAppCibilWithInLastMonth------>'+othrAppCibilWithInLastMonth);
        system.debug('othrAppCibilBeforeLastMonth------>'+othrAppCibilBeforeLastMonth);
        
        // if there is no current and other Applicant having Last CIBIL Run Date Run with in 30 days and more than 30 days, rerun CibilQueueable 
        if(currntAppCibilWithInLastMonth == null && othrAppCibilWithInLastMonth == null && currntAppCibilBeforeLastMonth == null && othrAppCibilBeforeLastMonth == null){ 
            Id jobId = System.enqueueJob(new CibilQueueable (recordId));
        }
        
        // else if there is current Applicant having Last CIBIL Run Date Run with in 30 days, skip rerun CibilQueueable 
        else if (currntAppCibilWithInLastMonth != null){
            system.debug('IN currntAppCibilWithInLastMonth---->');
            applcntRec.CIBIL_Rerun__c = false;
            applcntRec.CIBIL_Status__c = 'Skipped';
            applcntRec.CIBIL_Skip_Reason__c = 'Last run within 30 days';
            //applcntRec.Bureau_Score__c = currntAppCibilWithInLastMonth.Bureau_Score__c;
            //applcntRec.Last_CIBIL_Run_Date__c = currntAppCibilWithInLastMonth.Last_CIBIL_Run_Date__c;
        }
        
        // Added by Samridhi - else if there is other Applicant having Last CIBIL Run Date Run over 30 days, reset Cibil rerun as true
        else if(currntAppCibilBeforeLastMonth!= null){
            applcntRec.CIBIL_Rerun__c = true;
        }
        
        // else if there is other Applicant having Last CIBIL Run Date Run with in 30 days, skip rerun CibilQueueable and clone the all CIBIL related records under current applicant
        else if (othrAppCibilWithInLastMonth != null && existingDetailWrapper.currentApplicant!=null && existingDetailWrapper.currentApplicant.Last_CIBIL_Run_Date__c == null){
            system.debug('IN othrAppCibilWithInLastMonth---->');
            applcntRec.CIBIL_Rerun__c = false;
            applcntRec.CIBIL_Status__c = 'Skipped';
            applcntRec.CIBIL_Skip_Reason__c = 'Last run within 30 days';
            applcntRec.Bureau_Score__c = othrAppCibilWithInLastMonth.Bureau_Score__c;
            applcntRec.Last_CIBIL_Run_Date__c = othrAppCibilWithInLastMonth.Last_CIBIL_Run_Date__c;
            AML.cloneCibilRecords(recordId, othrAppCibilWithInLastMonth.Id);
        }
        // else if there is current or other Applicant having Last CIBIL Run Date Run before 30 days, reset Cibil rerun as true
        else if (currntAppCibilBeforeLastMonth != null || othrAppCibilBeforeLastMonth != null){
            system.debug('IN currntAppCibilBeforeLastMonth othrAppCibilBeforeLastMonth---->');
            applcntRec.CIBIL_Rerun__c = true;
            if(othrAppCibilBeforeLastMonth != null){
                applcntRec.Bureau_Score__c = othrAppCibilBeforeLastMonth.Bureau_Score__c;
                applcntRec.Last_CIBIL_Run_Date__c = othrAppCibilBeforeLastMonth.Last_CIBIL_Run_Date__c;
            }
        }
        update applcntRec;
        return applcntRec;
    }
    
    
    
    
}