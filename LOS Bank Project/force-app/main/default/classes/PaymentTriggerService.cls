/*******************************************************************************************
 * @Name         PaymentTriggerService
 * @Author       Samridhi
 * @Description  Service class for Payment Trigger - common methods across all portfolios
*               are written in this classr
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Samridhi        Oct-19-2023         Initial Creation 
 *  1.0             Samridhi        Oct-19-2023         SFAU-5427 GL Error
*                   Mohit M.        Nov-03-2023         SFAU-5483 - Invalid Account Number - Add before Insert and Before Update
*******************************************************************************************/
public with sharing class PaymentTriggerService implements ServiceInterface {
    
    public void beforeInsert(List<sObject> newRecordList) {
        List<Payment__c> lstPayment = (List<Payment__c>)newRecordList;
        for (Payment__c objPayment : lstPayment) {
            // START - SFAU-5483 - Invalid Account Number
            objPayment.Account_Number__c = String.isNotBlank(objPayment.Account_Number__c) ? objPayment.Account_Number__c.replaceAll('\'','') : objPayment.Account_Number__c;
            // END - SFAU-5483 - Invalid Account Number
        }

    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap) {
        Id pfRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Payment_Favouring').getRecordTypeId();
        List<String> setLoanAppIdOEM = new List<String>();
        Set<Id> setLoanAppIdOEMtoArchive = new Set<Id>();
        for(Payment__c payment : (List<Payment__c>)newRecordList){
            if(payment.Payment_Recipient__c!= null && payment.Payment_Recipient__c != 'OEM' 
                && payment.Inactive__c == false && payment.RecordTypeId == pfRecordTypeId){
                setLoanAppIdOEM.add(payment.Loan_Application__c);
                //setLoanAppIdOEMtoArchive.add(payment.Loan_Application__c);
            }
        }
        /*
        if(setLoanAppIdOEMtoArchive.size() > 0){
            archiveOEMApprovals(setLoanAppIdOEMtoArchive);
        }
        */
        if(setLoanAppIdOEM.size() > 0){
            createOEMApprovals(setLoanAppIdOEM);
        }
    }

    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
        Map<Id, Payment__c> oldPayment = (Map<Id, Payment__c>)oldRecordMap;
        Map<Id, Payment__c> newPayment = (Map<Id, Payment__c>)newRecordMap;
        List<Payment__c> lstPayment = (List<Payment__c>)newRecordList;
        for (Payment__c objPayment : newPayment.values()) {
            // START - SFAU-5483 - Invalid Account Number
            objPayment.Account_Number__c = String.isNotBlank(objPayment.Account_Number__c) ? objPayment.Account_Number__c.replaceAll('\'','') : objPayment.Account_Number__c;
            // END - SFAU-5483 - Invalid Account Number
        }
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
        Map<Id, Payment__c> oldAppRecordMap = (Map<Id, Payment__c>)oldRecordMap;
        Map<Id,Payment__c> setOfAppIds = new Map<Id,Payment__c>();
        Map<Id, Payment__c> paymentModeValue = new Map<Id, Payment__c>();
        List<String> setLoanAppIdOEM = new List<String>();
        //Set<Id> setLoanAppIdOEMtoArchive = new Set<Id>();
        system.debug('oldAppRecordMap'+oldAppRecordMap);
        
        Id pfRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Payment_Favouring').getRecordTypeId();

        for(Payment__c payment : (List<Payment__c>)newRecordList){
            if(payment.Payment_Mode__c!= null && (oldAppRecordMap.get(payment.Id).Payment_Mode__c != payment.Payment_Mode__c) 
               && payment.Payment_Mode__c == 'TA' && payment.Inactive__c == false && payment.RecordTypeId == pfRecordTypeId){
                paymentModeValue.put(payment.Loan_Application__c, payment);
            }
            else if(payment.Payment_Recipient__c!= null && (oldAppRecordMap.get(payment.Id).Payment_Recipient__c != payment.Payment_Recipient__c) 
               && payment.Inactive__c == false && payment.RecordTypeId == pfRecordTypeId){
                setLoanAppIdOEM.add(payment.Loan_Application__c);
                //setLoanAppIdOEMtoArchive.add(payment.Loan_Application__c);
            }
            else if(payment.Payment_Recipient__c!= null && (oldAppRecordMap.get(payment.Id).Inactive__c != payment.Inactive__c) 
                && payment.Inactive__c == true && payment.RecordTypeId == pfRecordTypeId){
                setLoanAppIdOEM.add(payment.Loan_Application__c);
                //setLoanAppIdOEMtoArchive.add(payment.Loan_Application__c);
            }
            /*else if(payment.Payment_Recipient__c!= null && (oldAppRecordMap.get(payment.Id).Payment_Recipient__c != payment.Payment_Recipient__c) 
               && payment.Payment_Recipient__c == 'OEM' && payment.Inactive__c == false && payment.RecordTypeId == pfRecordTypeId){
                setLoanAppIdOEMtoArchive.add(payment.Loan_Application__c);
            }*/
        }
        /*
        if(setLoanAppIdOEMtoArchive.size() > 0){
            archiveOEMApprovals(setLoanAppIdOEMtoArchive);
        }
        */
        if(setLoanAppIdOEM.size() > 0){
            //archiveOEMApprovals(setLoanAppIdOEMtoArchive);
            createOEMApprovals(setLoanAppIdOEM);
        }
        
        
        
        if(paymentModeValue.size() > 0){
            List<loan_application__c> loanList = [Select Product__c, stage__c from loan_application__c where Id in: paymentModeValue.keySet() and stage__c not in ('Ops Author', 'PDD', 'Rejected')];
            List<loan_application__c> updateLoanList = new List<loan_application__c>();
            
            for(loan_application__c loan: loanList){
                Payment__c payment = paymentModeValue.get(loan.Id);
                if(payment.Payment_Mode__c == 'TA'){
                    loan.General_Ledger__c = LoanDisbursementOpsController.handleSinglePaymentGLValues(payment, loan.Product__c, true)[0].value;
                }else{
                    loan.General_Ledger__c = LoanDisbursementOpsController.handleSinglePaymentGLValues(payment, loan.Product__c, false)[0].value;
                }
                
                updateLoanList.add(loan);
            }
            
            
        
        if(!updateLoanList.isEmpty()){
            update updateLoanList;
        }
        }
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }
    
    private static void createOEMApprovals(List<String> applicationRecords){
        Id pfRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Payment_Favouring').getRecordTypeId();    
        String[] vehicleTypes = AUSFVehicleController.VEHICLE_RECORD_TYPES;
        List<String> lstFilteredLoanIds = new List<String>();
        Set<Id> setLoanAppIdOEMtoArchive = new Set<Id>();
        for(Loan_Application__c objLoanApp : [SELECT Id,(SELECT Id,Payment_Recipient__c FROM Payments__r where Inactive__c=false
                                    AND Payment_Recipient__c != 'OEM' AND RecordTypeId = :pfRecordTypeId limit 1),(SELECT Id, Collateral_Name__c, Loan__c FROM Collaterals__r 
                                    WHERE RecordType.DeveloperName IN: vehicleTypes AND Is_Deleted__c  = FALSE) FROM Loan_Application__c where Id IN :applicationRecords]){
            if(objLoanApp.Collaterals__r.size() > 0){
                for(Collateral__c collateral: objLoanApp.Collaterals__r){
                    if(collateral.Collateral_Name__c == Label.Self_Propelled_Collateral_Code){
                        if(objLoanApp.Payments__r.size() > 0){
                            lstFilteredLoanIds.add(collateral.Loan__c);
                            setLoanAppIdOEMtoArchive.add(collateral.Loan__c);
                        }
                        else{
                            setLoanAppIdOEMtoArchive.add(collateral.Loan__c);
                        }
                    }
                }
            }
        }
        /*
        List<String> lstFilteredLoanIds = new List<String>();
        //String[] vehicleTypes = AUSFVehicleController.VEHICLE_RECORD_TYPES;
        for(Collateral__c collateral: [ SELECT Id, Collateral_Name__c, Loan__c FROM Collateral__c WHERE Loan__c IN: applicationRecords 
                                     AND RecordType.DeveloperName IN: vehicleTypes AND Is_Deleted__c  = FALSE WITH SECURITY_ENFORCED ]){
            if(collateral.Collateral_Name__c == Label.Self_Propelled_Collateral_Code){
                lstFilteredLoanIds.add(collateral.Loan__c);
            }
        }*/
        if(setLoanAppIdOEMtoArchive.size() > 0){
            archiveOEMApprovals(setLoanAppIdOEMtoArchive);
        }
        if(!lstFilteredLoanIds.isEmpty()){
            AUSFOEMApprovalAssignment.getListOfRBMApprovals(lstFilteredLoanIds);
        }
    }
    
    public static void archiveOEMApprovals(Set<Id> listOfLoanApp){
        List<Loan_Application_Approval__c> listOfApprovals = new List<Loan_Application_Approval__c>(); 
        For(Loan_Application_Approval__c loanApp:[SELECT Id,Archived__c,Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:listOfLoanApp AND Archived__c=false AND Approval_Type__c='OEMApproval' WITH SECURITY_ENFORCED]){
            loanApp.Archived__c = true;
            listOfApprovals.add(loanApp);
        }
        //update listOfApprovals;
        if(listOfApprovals.size() > 0) {
            DatabaseUtility.updateRecords(listOfApprovals, 'Loan_Application_Approval__c');
        }
    }

}