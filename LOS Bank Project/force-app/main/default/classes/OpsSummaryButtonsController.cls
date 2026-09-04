/**
 * @description       : 
 * @author            : Mayur
 * @group             : 
 * @last modified on  : 12-08-2023
 * @last modified by  : Ajitesh
**/
public with sharing class OpsSummaryButtonsController {

    @AuraEnabled
    public static LoanAssignmentWrapper getLoanId(Id recordId){
        LoanAssignmentWrapper objAssignmentWrapper = new LoanAssignmentWrapper();
        try {
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Assignment__c'){
                User objUser = [Select Id, Ops_User_type__c from User where Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED limit 1];
                objAssignmentWrapper.strLoggedInOpsUserType = objUser.Ops_User_type__c;
                List<Assignment__c> assignmentRecord = [SELECT Id,OwnerId,Status__c, Loan_Application__c, Loan_Application__r.Disbursement_Category__c, RecordType.Name, Stage__c,Ops_Stage__c,Tranche_Number__c FROM Assignment__c 
                                                WHERE id=:recordId WITH SECURITY_ENFORCED];
                if(!assignmentRecord.isEmpty()){
                    objAssignmentWrapper.objAssignment = assignmentRecord[0];
                    objAssignmentWrapper.showButtons = true;
                    system.debug('%% '+assignmentRecord[0].OwnerId);
                    system.debug('%% '+objUser.Id);
                    system.debug('%% '+UserInfo.getUserId());
                    if(String.valueof(assignmentRecord[0].OwnerId).startsWith('00G') && assignmentRecord[0].Status__c == 'Pending'
                         && ((assignmentRecord[0].RecordType.Name == 'Ops - Disbursement' && objUser.Ops_User_type__c == assignmentRecord[0].Ops_Stage__c)
                         || assignmentRecord[0].RecordType.Name == 'Ops - KYC' || assignmentRecord[0].RecordType.Name == 'Ops - PDD')){
                        objAssignmentWrapper.showAcceptButton = true;
                    }
                    else if(String.valueof(assignmentRecord[0].OwnerId).startsWith('005') 
                        && objUser.Id == assignmentRecord[0].OwnerId && assignmentRecord[0].Status__c == 'Pending'){
                        objAssignmentWrapper.showSubmitButtons = true;
                    }
                    if(assignmentRecord[0].Loan_Application__r.Disbursement_Category__c == 'Partial'){
                        List<Payment__c> tranche = [select id, name, Inactive__c, Disbursed__c, Tranche_Status__c,Disbursement_Amount__c, 
                                    Partial_Payment_Condition__c, Tranche_Number__c from Payment__c where  RecordType.Developername='Tranche' 
                                    and Inactive__c = false and Disbursed__c = false and loan_application__c=:assignmentRecord[0].Loan_Application__c WITH SECURITY_ENFORCED order by Tranche_Number__c desc limit 1];
                        if(!tranche.isEmpty() && tranche[0].Tranche_Number__c == assignmentRecord[0].Tranche_Number__c){
                            objAssignmentWrapper.boolIsFinalDisbursement = true;
                        }
                        else{
                            objAssignmentWrapper.boolIsFinalDisbursement = false;
                        }
                    }
                    else{
                        objAssignmentWrapper.boolIsFinalDisbursement = true;
                    }
                }
            }
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            return null;
        }
        system.debug('%% '+objAssignmentWrapper);
        return objAssignmentWrapper;
    }

    @AuraEnabled 
    public static Boolean checkIfDisbursementDone(String recordId){
        Loan_Application__c loanInstance = [SELECT Id, Completed_Disbursement_Stage__c FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
        if(loanInstance.Completed_Disbursement_Stage__c == 'Do Disbursement'){
            return true;
        }else{
            return false;
        }

    }

    @AuraEnabled
    public static string handleOpsValidation(String loanId, String type) {
        try {
            system.debug('%%% '+loanId);
            String returnMessage = 'The below validations checks are missing ';
            Boolean isDpd,isInitiateDisbursement,isCIFValidated,isDocumentCheck,isDocumentCheckPDD = false;
            Boolean isLoanDisbursed = false;
            Boolean returnToPSDCheck = false;
            if (type == 'SubmitToAuthor') {
                Loan_Application__c loanInstance = [SELECT id, Dpd_Found__c, LAN__c, Ops_Verification__c, Completed_Disbursement_Stage__c, Repayment_Schedule_Viewed_by_Maker__c,Stage__c, (SELECT Udyam_Certificate_Available__c FROM Charges__r WHERE SC_Code__c ='1005') 
                    FROM Loan_Application__c
                    WHERE id =: loanId
                ];
                
                List < Applicant__c > applicantList = getAllApplicants(loanId);
                List < Boolean > isBooleanList = new List < Boolean > ();
                List < Boolean > isLANBooleanList = new List < Boolean > ();
                if (applicantList.size() > 0) {
                    for (Applicant__c appInstance: applicantList) {
                        if (String.isNotBlank(appInstance.CIF_No__c)) {
                            isBooleanList.add(true);
                        } else {
                            isBooleanList.add(false);
                        }
                    }
                }

                if (loanInstance.Dpd_Found__c == false) {
                    isDpd = true;
                } else {
                    returnMessage += 'DPD Check ';
                }

                if (loanInstance.Completed_Disbursement_Stage__c == 'Repayment Schedule' && loanInstance.Repayment_Schedule_Viewed_by_Maker__c == true) {
                    isInitiateDisbursement = true;
                } else {
                    //returnMessage += 'Initiate disbursement Check ';
                    returnMessage += 'Please complete initiate disbursement before submitting to Ops';
                }

                if ((isBooleanList.contains(false) || isBooleanList.size() == 0) || (String.isBlank(loanInstance.LAN__c))) {
                    returnMessage += 'CIF/Lan Check ';
                } else {
                    isCIFValidated = true;
                }

                Utility.Result docResult = Utility.checkUploadedDocs(loanId,loanInstance.Stage__c);
                if(docResult.status == 'Success'){
                    isDocumentCheck = true;
                }else{
                    returnMessage +='Document Check ';
                }

                // Udyam Certificate not ok check R2-833
                if(loanInstance!=null && loanInstance.Charges__r.size() > 0) {
                    List<Document_Checklist__c> udyamDocCheck = [SELECT Ops_Action__c FROM Document_Checklist__c WHERE Loan_Application__c = :loanId AND Document_Master__r.Document_ID__c = 'AUWheels0038'];
                    if(udyamDocCheck.size() > 0 && (udyamDocCheck[0].Ops_Action__c != 'Ok' && udyamDocCheck[0].Ops_Action__c != 'ok')) {
                        returnMessage += System.Label.Commercial_Udyam_Certificate_Invalid_Ops_Submit_Message;
                    }
                }  
                // Udyam Certificate not ok check R2-833
                
                returnMessage += 'Please review the below Sections on Ops Summary Page ';
                if(String.isNotBlank(loanInstance.Ops_Verification__c)){
                    OpsVerificationController.OpsBaseVerificationWrapper wrapObj = (OpsVerificationController.OpsBaseVerificationWrapper)JSON.deserialize(loanInstance.Ops_Verification__c, OpsVerificationController.OpsBaseVerificationWrapper.class);
                    if(!wrapObj.isAssetDetailsVerified){
                        returnMessage +='Asset Details Section';
                    }
                    if(!wrapObj.isCaseSummaryVerified){
                         returnMessage +='Case Summary Section ';
                    }
                    if(!wrapObj.isSourcingVerified){
                        returnMessage +='Sourcing Section';
                    }
                }
                else{
                   returnMessage +='Asset Details Section, Case Summary Section, Sourcing Section';
                }


            } else if (type == 'SubmitToPDD' || type == 'SubmitToRO') {
                
                Loan_Application__c loanInstance = [SELECT id, Completed_Disbursement_Stage__c, Disbursement_Category__c, Is_Loan_Disbursed__c,Stage__c
                    FROM Loan_Application__c
                    WHERE Id =: loanId
                    WITH SECURITY_ENFORCED
                ];

                List < Payment__c > paymentList = [SELECT Id, Inactive__c, RecordType.DeveloperName,Payment_Favouring_Status__c, Disbursed__c, Loan_Application__c, Payment_Mode__c 
                    FROM Payment__c
                    WHERE Loan_Application__c =: loanId AND Inactive__c = false 
                    AND (RecordType.DeveloperName = 'Tranche' OR RecordType.DeveloperName = 'Payment_Favouring')
                    WITH SECURITY_ENFORCED
                ];
                // WHERE RecordType.DeveloperName='Tranche'
                List < Boolean > isLoanDisbursedList = new List < Boolean > ();
                List < Boolean > isTrancheDisbursedList = new List < Boolean > ();

                if (loanInstance.Completed_Disbursement_Stage__c == 'Do Disbursement') {
                    if (loanInstance.Disbursement_Category__c == 'Full') {
                        if (paymentList.size() > 0) {
                            for (Payment__c paymentInstance: paymentList) {
                                if (paymentInstance.Payment_Favouring_Status__c == 'Complete' || paymentInstance.Payment_Mode__c == 'TA') {
                                    isLoanDisbursedList.add(true);
                                } else {
                                    isLoanDisbursedList.add(false);
                                }
                            }
                        }
                    } else if (loanInstance.Disbursement_Category__c == 'Partial') {
                        if (paymentList.size() > 0) {
                            for (Payment__c paymentInstance: paymentList) {
                                if (paymentInstance.Disbursed__c == true || paymentInstance.Payment_Mode__c == 'TA') {
                                    isLoanDisbursedList.add(true);
                                } else {
                                    isLoanDisbursedList.add(false);
                                }
                            }
                        }
                    }
                }


                if (isLoanDisbursedList.contains(false) || isLoanDisbursedList.size() == 0) {
                    returnMessage += 'Loan/Tranche Disbursed Check ';
                } else {
                    isLoanDisbursed = true;
                }
                Utility.Result docResult = Utility.checkUploadedDocs(loanId,loanInstance.Stage__c);
                if(docResult.status == 'Success'){
                    isDocumentCheckPDD = true;
                }else{
                    returnMessage +='Document Check ';
                }

            } else if( type == 'ReturnToPSD'){
                Loan_Application__c loanInstance = [SELECT id, Dpd_Found__c, LAN__c, Completed_Disbursement_Stage__c, Repayment_Schedule_Viewed_by_Maker__c,Stage__c
                FROM Loan_Application__c
                WHERE id =: loanId
            ];

                 if(String.isNotBlank(loanInstance.LAN__c)){
                returnToPSDCheck = true;
                 }else{
                    returnToPSDCheck = false;
                 }

                 System.debug('returnToPSDCheck-->' +returnToPSDCheck);
            }
            String response = '';
            if (type == 'SubmitToAuthor') {

                if (isDpd == true && isInitiateDisbursement == true && isCIFValidated == true && isDocumentCheck == true) {
                    response = 'Success';
                } else {
                    response = returnMessage;
                }
            } else if (type == 'SubmitToPDD' || type == 'SubmitToRO') {
                if (isLoanDisbursed == true && isDocumentCheckPDD == true) {
                    response = 'Success';
                } else {
                    response = returnMessage;
                }

            } else if ( type == 'ReturnToPSD'){
                if(returnToPSDCheck == true){
                    response = 'After LAN created case cannot be sent back';
                }else{
                    response = 'Success';
                }
            }
            System.debug('response-->' +response);
            return response;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Applicant__c> getAllApplicants(String loanId){
        List<Applicant__c> applicantLst = [SELECT id,CIF_No__c,IsInactive__c,Loan__c,RecordType.DeveloperName
                                           FROM Applicant__c
                                           WHERE Loan__c=:loanId
                                           AND RecordType.DeveloperName != 'Additional_Match'
                                           AND RecordType.DeveloperName != 'Nominee'
                                            AND IsInactive__c = false//June 13
                                           WITH SECURITY_ENFORCED];


        if(applicantLst.size()>0){
            return applicantLst;
        }else{
            return null;
        }
    }

     //Notification 
     @AuraEnabled
     public static void sendOpsNotification(String loanId){
         try {
             NotificationHandler.sendNotification('Ops submission',loanId,'');
         } catch (Exception e) {
            System.debug('exception-->' +e);
         }
     }
     //END
    
    public class LoanAssignmentWrapper{
        @AuraEnabled public Assignment__c objAssignment{get;set;} 
        @AuraEnabled public Boolean showButtons{get;set;} 
        @AuraEnabled public Boolean showAcceptButton{get;set;} 
        @AuraEnabled public Boolean showSubmitButtons{get;set;} 
        @AuraEnabled public Boolean boolIsFinalDisbursement{get;set;} 
        @AuraEnabled public String strLoggedInOpsUserType{get;set;} 
    }

}