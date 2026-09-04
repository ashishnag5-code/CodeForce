/*
ClassName: FieldInvestigationAgentMappingController
TestClass: 
Description: Assign FI Agents and Owner of Field Investigation record 
*/
public without sharing class FieldInvestigationAgentMappingController {
 
    @AuraEnabled
    public static ResultWrapper  updateOwner(String userId,List<String> lstFi,Id CmId, Id loanId){
        try{
            ResultWrapper result = new ResultWrapper();
            String objectName=String.valueOf(loanId.getsobjecttype());
            String loanApplicationStage = '';
            if(objectName == 'Field_Investigation__c'){
                Field_Investigation__c fiRecord = [SELECT Id,Loan_Application__c, Loan_Application__r.Stage__c FROM Field_Investigation__c WHERE ID=:loanId];
                loanId = fiRecord.Loan_Application__c;
                loanApplicationStage = fiRecord.Loan_Application__r.Stage__c;
            }
            else if(objectName == 'Loan_Application__c'){
                loanApplicationStage = [SELECT Id, Stage__c FROM Loan_Application__c WHERE ID=:loanId].Stage__c;
            }
            List<String> restrictedStage = GlobalConstants.RESTRICTED_STAGES;
            if(String.isNotBlank(loanApplicationStage) && restrictedStage.contains(loanApplicationStage)){
                result.message = 'You cannot Re-Assign FI in the following stage: '+loanApplicationStage;
                result.isSuccess = false;
                return result;
            }
            List<Field_Investigation__c> lstOfFIs = new List<Field_Investigation__c>();
            if(String.isNotBlank(CmId)){
                for(String FiId:lstFi){
                    Field_Investigation__c objFI = new Field_Investigation__c();
                    objFI.Id=FiId;
                    //objFI.Credit_Manager__c = CmId;
                    objFi.ownerId=CmId;
                    objFI.Stage__c = Label.FI_Stage_Assigned;
                    objFI.FI_Status__c = '';
                    objFI.FI_Profile_Status__c = '';
                    objFi.FI_Allocation_Date_Time__c = System.Now();
                    lstOfFIs.add(objFI);   
            }
                update lstOfFIs;
                result.isSuccess = true;
                result.message = 'You\'ve Been Updated as Owner Successfully';
                // Calling FI Notification
                if(objectName=='Loan_Application__c'||objectName == 'Field_Investigation__c'){
                    NotificationHandler.sendNotification('FI Retrigger',loanId,CmId);
                }

                return result;   
            }
            if(String.isNotBlank(userId)){
                for(String FiId:lstFi){
                    Field_Investigation__c objFI = new Field_Investigation__c();
                    objFI.Id=FiId;
                    objFI.FI_Agent__c = userId;
                    objFi.ownerId=userId; 
                    objFI.Stage__c = Label.FI_Stage_Assigned;
                    objFI.FI_Status__c = '';
                    objFI.FI_Profile_Status__c = '';
                    objFi.FI_Allocation_Date_Time__c = System.Now();
                    lstOfFIs.add(objFI);       
                }
                system.debug(LoggingLevel.Info,'lstFi ' + lstFi);
                system.debug(LoggingLevel.Info,'CmId ' + CmId);
                system.debug(LoggingLevel.Info,'userId ' + userId);
                system.debug(LoggingLevel.Info,'lstOfFIs ' + lstOfFIs);
                update lstOfFIs;
                // Calling FI Notification
                if(objectName=='Loan_Application__c'||objectName == 'Field_Investigation__c'){
                    //system.debug('id '+loanId);
                    NotificationHandler.sendNotification('FI Retrigger',loanId,userId);
                }
                
                result.isSuccess = true;
                result.message = 'Successfully Updated FI Agent';
                return result; 
            }
            result.message = 'With this agent code,No user present';
            result.isSuccess = false;
            return result;
            
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            return result;
      }
    }
    

    /*
        26th September new Logic added to remove the Closed FI Records
    */
    @AuraEnabled
    public static ResultWrapper getRelatedFI(Id recordId,String objectName){
        try{

            String strWhereClasuse = '';
            if (objectName == 'Applicant__c') {
                strWhereClasuse = ' Applicant__c =:recordId';
            }
            else if (objectName == 'Loan_Application__c') {
                strWhereClasuse = ' Loan_Application__c =:recordId';
            }
      
            String strquery = 'Select Id,Loan_Application__c,Type_of_address__c,Name,Owner.Name,Address_lookup__r.Pincode__c,Loan_Application__r.Name,Applicant_Type__c,Re_Trigger__c, Stage__c ';
            String strqueryApp = strquery + 'FROM Field_Investigation__c WHERE Re_Trigger__c=false AND Applicant__r.IsInactive__c = false AND Stage__c != \'Closed\'';
            if(String.isNotBlank(strWhereClasuse)){
                strqueryApp = strqueryApp + ' AND ' + strWhereClasuse + ' WITH SECURITY_ENFORCED';
            }
            
            system.debug('Query ' + strqueryApp);
            ResultWrapper result = new ResultWrapper();
            result.lstFI = Database.Query(strqueryApp);

            if(result.lstFI.size()>0){
                result.isSuccess = true;
                result.message = 'Success';
            }
            else{
                result.isSuccess =false;
                result.message = 'No Records Present';
            }
            return result;
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            return result;
      }
    }
    Public class ResultWrapper{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<Field_Investigation__c> lstFI=new List<Field_Investigation__c>();

    }
}