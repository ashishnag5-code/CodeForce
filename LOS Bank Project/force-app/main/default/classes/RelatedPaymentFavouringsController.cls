public without sharing class RelatedPaymentFavouringsController {

    public static String contextScenario = '';
    public static Decimal totalCharges = 0;

    @AuraEnabled
    public static User getCurrentUserDetails(){
        try {
            List<User> userRecords = [SELECT Id, Profile.Name FROM User WHERE id=:UserInfo.getUserId()];
            if(userRecords!=null && userRecords.size()>0){
                return userRecords[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    //method is used to get existing the Loan Application along with it's child Payment records of Payment Favouring RT
    @AuraEnabled
    public static RelatedPaymentFavouringsWrapper getPaymentFavourings(Id loanAppRecId){
        RelatedPaymentFavouringsWrapper rpfWrapObj = new RelatedPaymentFavouringsWrapper();
        String sObjName = loanAppRecId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Assignment__c'){
            loanAppRecId = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:loanAppRecId LIMIT 1].Loan_Application__c;
        }

        Loan_Application__c loanapp = [SELECT Id, Stage__c,Product__c, Total_Loan_Amount__c, IFSC_Code__c, Disbursement_Category__c,LAN__c, RecordType.DeveloperName, BT_Type__c, (SELECT Id, SVSH_SVOH__c FROM Collaterals__r WHERE RecordType.DeveloperName IN ('New','Used_Cash_on_Wheels') AND Is_Deleted__c=false Order BY CreatedDate Desc),Dealer_Master__c, Dealer_Master__r.Name, Sourcing_Channel_Name__r.Account_Name__c,  Sourcing_Channel_Name__r.Dealer_Type__c, Sourcing_Channel_Name__r.Bank_Name__c, Sourcing_Channel_Name__r.IFSC_Code__c, Sourcing_Channel_Name__r.Benificiary_Account_Number__c, Sourcing_Channel_Name__r.Branch_location_State__c, Sourcing_Channel_Name__r.Dealer_Class__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Dealer_Type__c, Dealer_Master__r.Bank_Name__c, Dealer_Master__r.IFSC_Code__c, Dealer_Master__r.Benificiary_Account_Number__c, Branch_Master__r.Branch_location_State__c, Dealer_Master__r.Dealer_Class__c, Loan_Amount__c, Total_Charges__c, Repayment_Account_Number__c, Repayment_Bank_Name__c, Sourcing_Channel_Name__c, (SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c,Margin_Money_Action__c FROM Payments__r WHERE RecordType.Name = 'Payment Favouring' AND Inactive__c = false ORDER BY CreatedDate) FROM Loan_Application__c WHERE Id =: loanAppRecId];
        rpfWrapObj.loanApp = loanapp;
        if(loanapp.Branch_Master__r.Branch_location_State__c != null){
            List<Generic_Master__c> gnrcMstrLst = new List<Generic_Master__c>();
            gnrcMstrLst = [SELECT Id, Name__c, Bank_Name__c, IFSC__c, Name_of_benificiary__c, Account_number__c  FROM Generic_Master__c WHERE RecordType.Name = 'Payment Favouring' AND Type__c = 'CSD' AND State__c =: loanapp.Branch_Master__r.Branch_location_State__c];
            if(!gnrcMstrLst.isEmpty()){
                rpfWrapObj.pmntFvrngMstr = gnrcMstrLst[0];
            }
        }
        rpfWrapObj.loanType = getSubProductName(loanapp.Product__c) != null ? getSubProductName(loanapp.Product__c) : '';
        rpfWrapObj.netLoanAmount = loanApp.Total_Charges__c != null ? (loanApp.Loan_Amount__c - loanApp.Total_Charges__c) : loanApp.Loan_Amount__c;
        List<Payment__c> btPaymntLst = new List<Payment__c>();
        List<Payment__c> tranchePaymntLst = new List<Payment__c>();

        //SFAU-5260 : Updated by Samridhi
        btPaymntLst = [SELECT Id, BT_Type__c, Loan_Number__c, Financial_Institute_Name__c, Account_Number__c, IFSC_Code__c, POS__c, BT_Loan_Status__c from Payment__c WHERE RecordType.Name = 'Balance Transfer' AND Loan_Application__c =: loanAppRecId AND Inactive__c = false];
        tranchePaymntLst = [SELECT Id, Name, Tranche__c, Tranche_Number__c, Partial_Payment_Condition__c, Disbursement_Amount__c, IFSC_Code__c  from Payment__c 
                            WHERE RecordType.Name = 'Tranche' AND Loan_Application__c =: loanAppRecId AND Disbursed__c = false order by Tranche_Number__c];

        
                            if(loanApp.Dealer_Master__c!=null && loanApp.Dealer_Master__r.Bank_Name__c!=null){
                                List<Generic_Master__c> bankList = [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c LIKE :loanApp.Dealer_Master__r.Bank_Name__c AND RecordType.DeveloperName='Bank_Master'];
                                if(bankList!=null && bankList.size()>0){
                                    rpfWrapObj.defaultBankSelected = bankList[0].Id;
                                }else{
                                    List<IFSC_Master__c> ifscList = [SELECT Id, Bank_Name__c FROM IFSC_Master__c WHERE IFSC__c= :loanApp.Dealer_Master__r.IFSC_Code__c];
                                    if(ifscList!=null && ifscList.size()>0){
                                        List<Generic_Master__c> bankList3 = [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c LIKE :ifscList[0].Bank_Name__c AND RecordType.DeveloperName='Bank_Master'];
                                        if(bankList3!=null && bankList3.size()>0){
                                            rpfWrapObj.defaultBankSelected = bankList3[0].Id;
                                        }
                                    }
                                }
                            }else if(loanApp.Sourcing_Channel_Name__c!=null && loanApp.Sourcing_Channel_Name__r.Bank_Name__c!=null){
                                List<Generic_Master__c> bankList = [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c LIKE :loanApp.Sourcing_Channel_Name__r.Bank_Name__c AND RecordType.DeveloperName='Bank_Master'];
                                if(bankList!=null && bankList.size()>0){
                                    rpfWrapObj.defaultBankSelected = bankList[0].Id;
                                }else{
                                    List<IFSC_Master__c> ifscList = [SELECT Id, Bank_Name__c FROM IFSC_Master__c WHERE IFSC__c= :loanApp.Sourcing_Channel_Name__r.IFSC_Code__c];
                                    if(ifscList!=null && ifscList.size()>0){
                                        List<Generic_Master__c> bankList3 = [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE Bank_Name__c LIKE :ifscList[0].Bank_Name__c AND RecordType.DeveloperName='Bank_Master'];
                                        if(bankList3!=null && bankList3.size()>0){
                                            rpfWrapObj.defaultBankSelected = bankList3[0].Id;
                                        }
                                    }
                                }
                            }
                            
        if(!btPaymntLst.isEmpty()){
            rpfWrapObj.balanceTransferPymntLst = btPaymntLst;
        }
        if(!tranchePaymntLst.isEmpty()) {
            rpfWrapObj.tranchePymntLst = tranchePaymntLst;
        }
        return rpfWrapObj;
    }
    
    //method is used to get the Sub Product Name from the custom metadata ProductRTMap__mdt
    public static String getSubProductName(String product){
        String subProductName = '';
        ProductRTMap__mdt[] prtList = [Select Product__c, Sub_Product__c from ProductRTMap__mdt where Product__c  =:  product and Active__c = true WITH SECURITY_ENFORCED];
        if(prtList.size()>0){
            subProductName = prtList[0].Sub_Product__c;
        }
        return subProductName;
    }
    
    //method is used to get the Payment Favouring record
    @AuraEnabled
    public static Payment__c getPaymentFavouring(String paymentId){
        return [SELECT Id, Tranche__c, Tranche__r.Tranche_Number__c, Account_Type__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Bank_Name_PMT__c, IFSC_Code__c, Account_Number__c, Net_Amount__c,isVerified__c,Beneficiary_Name_Response__c,Margin_Money_Action__c FROM Payment__c where Id =: paymentId WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static Generic_Master__c fetchDefaultRecordForBank(String recordId){
        try {
            List<Generic_Master__c> bankList = [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE id=:recordId ];
            if(bankList!=null && bankList.size()>0){
                return bankList[0];
            }else{
                return null;
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled
    public static IFSC_Master__c validateIFSCWithBank(String ifsc){
        try {
            List<IFSC_Master__c> bankList = [SELECT Id, Bank_Name__c FROM IFSC_Master__c WHERE ifsc__c=:ifsc ];
            if(bankList!=null && bankList.size()>0){
                return bankList[0];
            }else{
                return null;
            }
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
    
    //method is used to update the Payment record
    @AuraEnabled
    public static Id updatePaymentFavouring(String paymentRecId, String context){
        Payment__c paymntObj = new Payment__c();
        paymntObj.Id = paymentRecId;
        if(context == 'delete'){
            paymntObj.Inactive__c = true;
        }
        Update paymntObj;
        return paymntObj.Id;
    }

    public static List<Payment__c> getPaymentFavList2(String payFavId, String loanApplId, String recordTypeName, Boolean isInactive, Decimal tranchNumber) {
        List<Payment__c> paymentFavList = [SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c 
                                            FROM Payment__c 
                                            WHERE id != :payFavId AND Loan_Application__c =:loanApplId AND RecordType.Name =:recordTypeName AND Inactive__c =:isInactive 
                                            AND Tranche__r.Tranche_Number__c =:tranchNumber WITH SECURITY_ENFORCED];
        return paymentFavList;
    }

    @AuraEnabled
    public static List<Payment__c> getPaymentFavourin3(String loanAppId){
        return [SELECT Id, Net_Amount__c FROM Payment__c where Loan_Application__c =: loanAppId and Inactive__c = false AND RecordType.Name='Payment Favouring' WITH SECURITY_ENFORCED];
    }

    public static List<Payment__c> getPaymentFavList4(String payFavId, String loanApplId, String recordTypeName, Boolean isInactive) {
        List<Payment__c> paymentFavList = [SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c 
                                            FROM Payment__c 
                                            WHERE id != :payFavId AND Loan_Application__c =:loanApplId AND RecordType.Name =:recordTypeName AND Inactive__c =:isInactive
                                            WITH SECURITY_ENFORCED];
        return paymentFavList;
    }
    
  /*  public static List<Loan_Application__c> getLoanAppl(String loanApplId) {
        List<Loan_Application__c> loanApplList = [SELECT Id, Disbursement_Category__c
                                            FROM Loan_Application__c 
                                            WHERE id = :loanApplId];
        return loanApplList;
    }  */
    
    //method is used to save the Payment record
    @AuraEnabled
    public static Id savePaymentFavouring(Payment__c paymentRec, String loanType, List<TrancheOptionsWrapper> tranchOptions, String loanApplId, String context, Decimal currentTranchNum){
        system.debug('paymentRec--'+paymentRec);
        paymentRec.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        contextScenario = context;
        List<Loan_Application__c> loanApps= [SELECT Id, Stage__c,Disbursement_Category__c, Total_Loan_Amount__c, Total_Charges__c, Loan_Amount__c 
                                            FROM Loan_Application__c WHERE Id=:paymentRec.Loan_Application__c];
        String disbursementCategory;
        Decimal currTotalAmt = paymentRec.Net_Amount__c != null ? paymentRec.Net_Amount__c : 0;
        Decimal loanAmt, totalChrge, netAmout;

        
        if(loanApps.size() > 0) {
            disbursementCategory = loanApps[0].Disbursement_Category__c;
            loanAmt    = loanApps[0].Loan_Amount__c != null ? loanApps[0].Loan_Amount__c : 0;
            totalChrge = loanApps[0].Total_Charges__c != null ? loanApps[0].Total_Charges__c : 0;
            netAmout   = loanAmt - totalChrge;


        //SFAU-5596 : Added by Samridhi to selectively set Payment Favouring Modified flag
        if(paymentRec != null && String.isNotBlank(paymentRec.Id)){
            String paymentId = paymentRec.Id;
            Payment__c previousPaymentRecord = [Select Bank_Name_PMT__c, Account_Number__c, IFSC_Code__c from payment__c where Id =: paymentId];

            if(loanApps[0].Stage__c==GlobalConstants.STAGE_OPS_MAKER && (previousPaymentRecord.Bank_Name_PMT__c != paymentRec.Bank_Name_PMT__c || previousPaymentRecord.Account_Number__c != paymentRec.Account_Number__c || previousPaymentRecord.IFSC_Code__c != paymentRec.IFSC_Code__c)){
                paymentRec.is_Payment_Favouring_Modified__c = true;// required at OPS Disbursement
            }
        }
        }

        //SFAU-5472
        if(paymentRec != null && String.isNotBlank(paymentRec.IFSC_Code__c)){
            paymentRec.IFSC_Code__c =  paymentRec.IFSC_Code__c.toUpperCase();
        }

       /* if(loanApps!=null && loanApps.size()>0 && loanApps[0].Stage__c==GlobalConstants.STAGE_OPS_MAKER && paymentRec.Id != null){
            paymentRec.is_Payment_Favouring_Modified__c = true;// required at OPS Disbursement
        }  */
        totalCharges = loanApps.size() > 0 && loanApps[0].Total_Charges__c != null ? loanApps[0].Total_Charges__c : 0;

        List<Payment__c> paymntFavList = new List<Payment__c>();
        if(String.isNotBlank(disbursementCategory) &&  disbursementCategory == 'Full') {
            
            //main2(paymentRec, loanApplId, netAmout, currTotalAmt, context);
            main2(paymentRec, loanApplId, (loanApps[0].Total_Loan_Amount__c-loanApps[0].Total_Charges__c), currTotalAmt, context);
        }
        else {
           // Decimal disbursedAmtFor1 = paymentRec.Disbursement_Amount__c - totalChrge;
            if(context == 'update') {

                String paymentFavId = paymentRec.Id;
                Payment__c oldPaymentRec = getPaymentFavouring(paymentFavId);
    
                Decimal currentNetAmt = paymentRec.Net_Amount__c;
                Decimal previousNetAmt = oldPaymentRec.Net_Amount__c;
                
                Decimal previousTrancheNum = oldPaymentRec.Tranche__r.Tranche_Number__c;
                if(currentTranchNum != previousTrancheNum && currentTranchNum > previousTrancheNum) {
                //   validationForTrancheSequence(paymentFavId,tranchOptions, loanApplId, previousTrancheNum, 'Please enter the amount for previous Tranche Number');
                    throw new AuraHandledException('Please fulfill the amount for previous Tranche Number');
                }
                else if(currentTranchNum != previousTrancheNum && currentTranchNum < previousTrancheNum){
                //    validationForTrancheSequence(paymentFavId,tranchOptions, loanApplId, currentTranchNum, 'Not able to edit as amount is already equals to Disburment Amount for Tranche Number');
                    //validationForTrancheSequence2(paymentFavId,tranchOptions, loanApplId, currentTranchNum, 'Not able to edit as amount is already equals to Disburment Amount for Tranche Number', paymentRec);
                    validationForTrancheSequence2(paymentFavId,tranchOptions, loanApplId, currentTranchNum, 'Net Amount of Payment Favourings cannot exceed the Disbursement Amount of Tranche '+currentTranchNum, paymentRec);

                }
                else if(currentNetAmt != previousNetAmt) {
                    paymntFavList = getPaymentFavList2(paymentFavId, loanApplId, 'Payment Favouring', false, currentTranchNum);
                    main(paymntFavList, tranchOptions, paymentRec, currentTranchNum, null);
                }      
            } 
            else if(context == 'insert') {
                if(currentTranchNum == 1) {
                    paymntFavList = getPaymentFavList(loanApplId, 'Payment Favouring', false, currentTranchNum);
                    if(paymntFavList.size() > 0) {
                        main(paymntFavList, tranchOptions, paymentRec, currentTranchNum, null);
                    }
                    else {
                        if(paymentRec.Net_Amount__c > netAmout) {
                            throw new AuraHandledException('Please fill the loan amount less than equals to ' + netAmout);
                        }
                    }
                }
                if(currentTranchNum > 1) {
                    paymntFavList = getPaymentFavList(loanApplId, 'Payment Favouring', false, currentTranchNum);
                    if(paymntFavList.size() == 0) {
                        paymntFavList = getPaymentFavList(loanApplId, 'Payment Favouring', false, currentTranchNum - 1);
                        if(paymntFavList.size() == 0){
                            throw new AuraHandledException('Please fulfill the amount for previous Tranche Number');
                        }
                        else {
                            Decimal trancheNumToCheck = currentTranchNum-1;
                            main(paymntFavList, tranchOptions, paymentRec, currentTranchNum, trancheNumToCheck);
                        }
                    }
                    else {
                        main(paymntFavList, tranchOptions, paymentRec, currentTranchNum, null);
                    }
                }
            }
        }

        Upsert paymentRec;
        return paymentRec.Id;
    }

    public static void main(List<Payment__c> paymntFavList, List<TrancheOptionsWrapper> tranchOptions, Payment__c paymentRec, Decimal tranchNumber, Decimal trancheNumToCheck) {

        Map<String, Decimal> mapOfTranchNumToTotalNetAmt = new Map<String, Decimal>();
        Map<String, Decimal> mapOfTrancheNumbToBisbursementAmt = new Map<String, Decimal>();

        mapOfTranchNumToTotalNetAmt = getMapOfTranchNumToTotalNetAmt(paymntFavList);
        mapOfTrancheNumbToBisbursementAmt = getMapOfTrancheNumbToBisbursementAmt(tranchOptions);

        Decimal netAmt = 0;
        Decimal disbursement = 0;

        if(trancheNumToCheck == null) {
            if(mapOfTranchNumToTotalNetAmt.isEmpty()) {
                netAmt = paymentRec.Net_Amount__c;
            }
            else {
                netAmt = mapOfTranchNumToTotalNetAmt.get(String.valueOf(tranchNumber)) + paymentRec.Net_Amount__c;
            }
            disbursement = mapOfTrancheNumbToBisbursementAmt.get(String.valueOf(tranchNumber));
        }
        else {
            netAmt = mapOfTranchNumToTotalNetAmt.get(String.valueOf(trancheNumToCheck));
            disbursement = mapOfTrancheNumbToBisbursementAmt.get(String.valueOf(trancheNumToCheck));
        }

        if(disbursement!=null && totalCharges!=null && (tranchNumber == 1 || trancheNumToCheck == 1)) {
            disbursement = disbursement - totalCharges;
        }   

        if((disbursement!=null && netAmt!=null) &&(netAmt > disbursement)) {
            //throw new AuraHandledException('Not able to edit as amount is already equals to Disburment Amount for Tranche Number');
            throw new AuraHandledException('Net Amount of Payment Favourings cannot exceed the Disbursement Amount of Tranche');
        }
        if(contextScenario == 'insert' && trancheNumToCheck != null) {
            if(netAmt < disbursement) {
                throw new AuraHandledException('Please fulfill the amount for previous Tranche Number');
            }
        }
    }
   
    public static void main2(Payment__c paymentRec, String loanApplcntionId, Decimal netAmout, Decimal currTotalAmt, String context) {

        
        if(context == 'insert') {
            List<Payment__c> paymFavList = getPaymentFavourin3(loanApplcntionId);
            insUpdateForFull(paymFavList, netAmout, currTotalAmt);
        }
        else if(context == 'update') {
            List<Payment__c> paymentFavList = getPaymentFavList4(paymentRec.Id, loanApplcntionId, 'Payment Favouring', false);
            insUpdateForFull(paymentFavList, netAmout, currTotalAmt);
        }
    }

    public static void insUpdateForFull(List<Payment__c> paymFavList, Decimal netAmout, Decimal currTotalAmt) {

        Decimal totalNetAmt = 0;
        Decimal existingTotalNetAmount = 0;
        for(Payment__c pay : paymFavList) {
            totalNetAmt += pay.Net_Amount__c;
            existingTotalNetAmount = existingTotalNetAmount+pay.Net_Amount__c;
        }
        totalNetAmt += currTotalAmt;      
        if(totalNetAmt > netAmout) {
            //throw new AuraHandledException('Please complete the Total Net Amount');
            throw new AuraHandledException('Net Amount cannot exceed '+(netAmout-existingTotalNetAmount));
        }
    }

    public static Map<String, Decimal> getMapOfTrancheNumbToBisbursementAmt(List<TrancheOptionsWrapper> tranchOptions) {

        Map<String, Decimal> mapOfTrancheNumbToBisbursementAmt = new Map<String, Decimal>();

        for(TrancheOptionsWrapper tranchOpt : tranchOptions) {
            String trancheNum = tranchOpt.trancheNumber;
            if(mapOfTrancheNumbToBisbursementAmt.containsKey(trancheNum)) {
                Decimal disbursementAmt = mapOfTrancheNumbToBisbursementAmt.get(trancheNum);
                disbursementAmt += tranchOpt.disbursementAmount;
                mapOfTrancheNumbToBisbursementAmt.put(trancheNum, disbursementAmt);
            }
            else {
                mapOfTrancheNumbToBisbursementAmt.put(trancheNum, tranchOpt.disbursementAmount);
            }
        } 
        return mapOfTrancheNumbToBisbursementAmt;
    }

    public static Map<String, Decimal> getMapOfTranchNumToTotalNetAmt(List<Payment__c> paymntFavList) {

        Map<String, Decimal> mapOfTranchNumToTotalNetAmt = new Map<String, Decimal>();
        

        for(Payment__c payFacRec : paymntFavList) {
            String trancheNum = String.valueOf(payFacRec.Tranche__r.Tranche_Number__c);
            if(mapOfTranchNumToTotalNetAmt.containsKey(trancheNum)) {
                Decimal netAmount= mapOfTranchNumToTotalNetAmt.get(trancheNum);
                netAmount += payFacRec.Net_Amount__c;
                mapOfTranchNumToTotalNetAmt.put(trancheNum, netAmount);
            }
            else {
                mapOfTranchNumToTotalNetAmt.put(trancheNum, payFacRec.Net_Amount__c);
            }
        }
        return mapOfTranchNumToTotalNetAmt;
    }

    public static List<Payment__c> getPaymentFavList(String loanApplId, String recordTypeName, Boolean isInactive, Decimal tranchNumber) {
        List<Payment__c> paymentFavList = [SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c 
                                            FROM Payment__c 
                                            WHERE Loan_Application__c =:loanApplId AND RecordType.Name =:recordTypeName AND Inactive__c =:isInactive 
                                            AND Tranche__r.Tranche_Number__c =:tranchNumber];
        return paymentFavList;
    }

    // Method to get Cheque related Payment Favs.
    public static List<Payment__c> getChequePaymentFavList(String loanApplId,String recordTypeName) {
        List<Payment__c> paymentFavList = [SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c,Is_Cheque_Pool_Disburse_Successful__c,Is_Pool_Disbursement_Successful__c  
                                            FROM Payment__c 
                                            WHERE Loan_Application__c =:loanApplId AND RecordType.Name =:recordTypeName AND Inactive__c = false
                                            AND Payment_Mode__c = 'Cheque'];
        return paymentFavList;
    }

    // Method to get Cheque related Payment Favs.
    public static List<Payment__c> getNonChequePaymentFavList(String loanApplId,String recordTypeName) {
        List<Payment__c> paymentFavList = [SELECT Id, Name, Tranche__r.Tranche_Number__c, Payment_Recipient__c, Payment_Mode__c, Name__c, Net_Amount__c,Is_Cheque_Pool_Disburse_Successful__c,Is_Pool_Disbursement_Successful__c 
                                            FROM Payment__c 
                                            WHERE Loan_Application__c =:loanApplId AND RecordType.Name =:recordTypeName AND Inactive__c = false
                                            AND Payment_Mode__c != 'Cheque'];
        return paymentFavList;
    }

    public static void validationForTrancheSequence2(String paymentFavId, List<TrancheOptionsWrapper> tranchOptions, String loanApplId, Decimal tranchNumber, String errorMessage, Payment__c paymentRec) {
        Map<String, Decimal> mapOfTranchNumToTotalNetAmt = new Map<String, Decimal>();
        Map<String, Decimal> mapOfTrancheNumbToBisbursementAmt = new Map<String, Decimal>();

        List<Payment__c> paymntFavList = getPaymentFavList(loanApplId, 'Payment Favouring', false, tranchNumber);
        
        mapOfTranchNumToTotalNetAmt = getMapOfTranchNumToTotalNetAmt(paymntFavList);
        mapOfTrancheNumbToBisbursementAmt = getMapOfTrancheNumbToBisbursementAmt(tranchOptions);

        Decimal netAmt = mapOfTranchNumToTotalNetAmt.get(String.valueOf(tranchNumber)) + paymentRec.Net_Amount__c;
        Decimal disbursement = mapOfTrancheNumbToBisbursementAmt.get(String.valueOf(tranchNumber));

        if(tranchNumber == 1) {
            disbursement = disbursement - totalCharges;
        }

        if(netAmt > disbursement) {
            throw new AuraHandledException(errorMessage);
        }
    } 
    
    //method is used to check if there is any deviation on child Payment Favouring records of Loan Application
    @AuraEnabled
    public static void checkDeviationRules(String loanAppRecId){
        List<Deviation__c> deviationLst = new List<Deviation__c>();
        String hpnType = '';
        Collateral__c collateralObj = new Collateral__c(); 
        collateralObj = [Select Id, HPN_With_Financiers_Name__c FROM Collateral__c WHERE Loan__c =: loanAppRecId WITH SECURITY_ENFORCED LIMIT 1];
        if(collateralObj != null && String.IsNotBlank(collateralObj.HPN_With_Financiers_Name__c)){
            if(collateralObj.HPN_With_Financiers_Name__c == 'NA'){
                hpnType = 'No HPN';
            }
            else if(collateralObj.HPN_With_Financiers_Name__c == Label.AU_Bank_Name){
                hpnType = 'AU HPN';
            }
            else{
                hpnType = 'Other HPN';
            }
        }
        else{
            hpnType = 'No HPN';
        }
        
        Map<String, Payment_Favouring_Rule__mdt> mapActivePmntFvrngRule = getActivePaymentFavouringRule();
        Map<String, Deviation__c> mapDeviation = getDeviations(loanAppRecId);
        Loan_Application__c loanApp = [SELECT Id, Product__c, Sourcing_Channel__c, Dealer_Master__r.X100_Payment__c, Loan_Amount__c, Total_Charges__c, (SELECT Id, Payment_Recipient__c, Payment_Mode__c, Net_Amount__c FROM Payments__r WHERE RecordType.Name = 'Payment Favouring' AND Inactive__c = false ORDER BY CreatedDate) FROM Loan_Application__c WHERE Id =: loanAppRecId WITH SECURITY_ENFORCED];
        String loanType = getSubProductName(loanApp.Product__c) != null ? getSubProductName(loanApp.Product__c) : '';
        system.debug('hpnType'+hpnType);
        system.debug('loanType'+loanType);
        system.debug('mapActivePmntFvrngRule'+mapActivePmntFvrngRule);
        system.debug('mapDeviation'+mapDeviation);
        Decimal cowNoHpnCustomerTotalNetAmount = 0;
        Decimal cowNoHpnDealerTotalNetAmount = 0;
        Decimal cowOtherHpnCorporateTotalNetAmount = 0;
        Boolean cowNoHpnCustomer;
        Boolean cowNoHpnDealer;
        Boolean cowOtherHpnCorporate; 
        Decimal netLoanAmount = loanApp.Total_Charges__c != null ? (loanApp.Loan_Amount__c - loanApp.Total_Charges__c) : loanApp.Loan_Amount__c;
        system.debug('netLoanAmount'+netLoanAmount);
        String COWProducts = System.Label.COW_Product_Names;
        for(Payment__c pmntObj : loanApp.payments__r){
            system.debug('pmntObj'+pmntObj);
            //if(loanType == 'Cash on Wheels'){
            if(loanType!=null && COWProducts.toUpperCase().contains(loanType.toUpperCase())){//R2-2634
                if(pmntObj.Payment_Recipient__c == 'Customer'){
                    if(hpnType == 'No HPN'){
                        if(mapActivePmntFvrngRule.containsKey('COW-No HPN-Customer')){
                            if(mapActivePmntFvrngRule.get('COW-No HPN-Customer').Sourcing_Channel__c.contains(loanApp.Sourcing_Channel__c)){
                                cowNoHpnCustomer= true;
                                cowNoHpnCustomerTotalNetAmount += pmntObj.Net_Amount__c;
                            }
                            
                        }
                    }
                }
                else{
                    if(hpnType == 'No HPN'){
                        if(mapActivePmntFvrngRule.containsKey('COW-No HPN-Dealer')){
                            system.debug('PF Rule sourcing channel--->'+mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Sourcing_Channel__c);
                            system.debug('loanApp Sourcing Channel--->'+loanApp.Sourcing_Channel__c);
                            if(mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Sourcing_Channel__c.contains(loanApp.Sourcing_Channel__c)){
                                cowNoHpnDealer = true;
                                cowNoHpnDealerTotalNetAmount += pmntObj.Net_Amount__c;
                            }
                        }
                    }
                    
                    if(hpnType == 'Other HPN'){
                        if(mapActivePmntFvrngRule.containsKey('COW-Other HPN-Corporate')){
                            if(mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Sourcing_Channel__c.contains(loanApp.Sourcing_Channel__c)
                               && loanApp.Dealer_Master__r.X100_Payment__c){
                                   cowOtherHpnCorporate= true;
                                   cowOtherHpnCorporateTotalNetAmount += pmntObj.Net_Amount__c;
                               }
                            
                        }
                    }
                }
            }
        }
        system.debug('cowNoHpnCustomerTotalNetAmount'+cowNoHpnCustomerTotalNetAmount);
        system.debug('cowNoHpnDealerTotalNetAmount'+cowNoHpnDealerTotalNetAmount);
        system.debug('cowOtherHpnCorporateTotalNetAmount'+cowOtherHpnCorporateTotalNetAmount);
        
        //deviation: if Net amount of Payment(Customer) is not equals to Net Amount of Loan
        if(cowNoHpnCustomer == true){
            Deviation__c cowNoHpnCustDevObj = new Deviation__c();
            if(cowNoHpnCustomerTotalNetAmount != netLoanAmount){
                if(mapDeviation.containsKey('COW-No HPN-Customer')){
                    if(mapDeviation.get('COW-No HPN-Customer').Active__c == false){
                        cowNoHpnCustDevObj = Utility.getDeviation(mapDeviation.get('COW-No HPN-Customer').Id, mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_details__c, 'S1', loanAppRecId, '', true);
                        deviationLst.add(cowNoHpnCustDevObj);
                    }
                }
                else{
                    cowNoHpnCustDevObj = Utility.getDeviation('' , mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_details__c, 'S1', loanAppRecId, '', true);
                    deviationLst.add(cowNoHpnCustDevObj);
                }
                
            }
            else{
                if(mapDeviation.containsKey('COW-No HPN-Customer')){
                    if(mapDeviation.get('COW-No HPN-Customer').Active__c == true){
                        cowNoHpnCustDevObj = Utility.getDeviation(mapDeviation.get('COW-No HPN-Customer').Id , mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Customer').Deviation_details__c, 'S1', loanAppRecId, '', false);
                        deviationLst.add(cowNoHpnCustDevObj);
                    }
                }
            }
            
        }
        
        //deviation: if Net amount of Payment(Dealer) is greater than 10% of Net Amount of Loan
        if(cowNoHpnDealer == true){
            Deviation__c cowNoHpnDealDevObj = new Deviation__c();
            if(cowNoHpnDealerTotalNetAmount > (netLoanAmount*0.10)){
                if(mapDeviation.containsKey('COW-No HPN-Dealer')){
                    if(mapDeviation.get('COW-No HPN-Dealer').Active__c == false){
                        cowNoHpnDealDevObj = Utility.getDeviation(mapDeviation.get('COW-No HPN-Dealer').Id, mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_details__c, 'S1', loanAppRecId, '', true);
                        deviationLst.add(cowNoHpnDealDevObj); 
                    }
                }
                else{
                    cowNoHpnDealDevObj = Utility.getDeviation('' , mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_details__c, 'S1', loanAppRecId, '', true);
                    deviationLst.add(cowNoHpnDealDevObj);
                }
                
            }
            else{
                if(mapDeviation.containsKey('COW-No HPN-Dealer')){
                    system.debug('deviation'+mapDeviation.get('COW-No HPN-Dealer'));
                    if(mapDeviation.get('COW-No HPN-Dealer').Active__c == true){
                        cowNoHpnDealDevObj = Utility.getDeviation(mapDeviation.get('COW-No HPN-Dealer').Id , mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-No HPN-Dealer').Deviation_details__c, 'S1', loanAppRecId, '', false);
                        deviationLst.add(cowNoHpnDealDevObj);
                    }
                }
            }
        }
        
        //deviation: if Net amount of Payment(Corporate) is not equals to Net Amount of Loan
        if(cowOtherHpnCorporate == true){
            Deviation__c cowOtherHpnCorpDevObj = new Deviation__c();
            if(cowOtherHpnCorporateTotalNetAmount != netLoanAmount){
                if(mapDeviation.containsKey('COW-Other HPN-Corporate')){
                    if(mapDeviation.get('COW-Other HPN-Corporate').Active__c == false){
                        cowOtherHpnCorpDevObj = Utility.getDeviation(mapDeviation.get('COW-Other HPN-Corporate').Id, mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_details__c, 'S1', loanAppRecId, '', true);
                        deviationLst.add(cowOtherHpnCorpDevObj); 
                    }
                }
                else{
                    cowOtherHpnCorpDevObj = Utility.getDeviation('' , mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_details__c, 'S1', loanAppRecId, '', true);
                    deviationLst.add(cowOtherHpnCorpDevObj);
                }
                
            }
            else{
                if(mapDeviation.containsKey('COW-Other HPN-Corporate')){
                    system.debug('deviation'+mapDeviation.get('COW-Other HPN-Corporate'));
                    if(mapDeviation.get('COW-Other HPN-Corporate').Active__c == true){
                        cowOtherHpnCorpDevObj = Utility.getDeviation(mapDeviation.get('COW-Other HPN-Corporate').Id , mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_Type__c, mapActivePmntFvrngRule.get('COW-Other HPN-Corporate').Deviation_details__c, 'S1', loanAppRecId, '', false);
                        deviationLst.add(cowOtherHpnCorpDevObj);
                    }
                }
            }
        }
        
        
        system.debug('deviationLst'+deviationLst);
        // upsert the deviations under the Loan Application
        if(!deviationLst.isEmpty()){
            //Set Deviation Source to SF start
            if(deviationLst!=null && deviationLst.size()>0){
                for(Deviation__c deviationTemp: deviationLst){
                    deviationTemp.Source__c = 'SF';
                }
            }
            //Set Deviation Source to SF end
            Utility.createDeviation(deviationLst);
        }
        
    }
    
    //method is used to get the map of active Payment Favouring Rules metadata
    public static Map<String, Payment_Favouring_Rule__mdt> getActivePaymentFavouringRule(){
        Map<String, Payment_Favouring_Rule__mdt> mapActivePmntFvrngRule = new Map<String, Payment_Favouring_Rule__mdt>();
        Map<String, Payment_Favouring_Rule__mdt> mapPmntFvrngRule = Payment_Favouring_Rule__mdt.getAll();
        for(String rule: mapPmntFvrngRule.keySet()){
            if(mapPmntFvrngRule.get(rule).active__c == true){
                System.debug(rule+' --> '+mapPmntFvrngRule.get(rule));
                mapActivePmntFvrngRule.put(mapPmntFvrngRule.get(rule).Deviation_Type__c, mapPmntFvrngRule.get(rule));
            }
        }
        return mapActivePmntFvrngRule;
    }
    
    //method is used to get the map of active Deaviations under Loan Application
    public static Map<String, Deviation__c> getDeviations(String loanAppRecId){
        Map<String, Deviation__c> mapDeviation = new Map<String, Deviation__c>();
        for(Deviation__c devObj : [SELECT Id, Deviation_Type__c, Active__c FROM Deviation__c WHERE Loan_Application__c =: loanAppRecId WITH SECURITY_ENFORCED]){
            mapDeviation.put(devObj.Deviation_Type__c, devObj);
        }
        return mapDeviation;
    }

    @AuraEnabled
    public static List<String> internalBTValidation(String recordId){
        try {
            List<String> pendingForeClosureAccs = new List<String>();
            List<Payment__c> paymentFavourings = [SELECT Id, BT_Type__c, Loan_Number__c, Financial_Institute_Name__c, Account_Number__c, 
                IFSC_Code__c, POS__c, BT_Loan_Status__c, RecordType.DeveloperName FROM Payment__c WHERE RecordType.DeveloperName IN ('Balance_Transfer','Payment_Favouring') AND 
                Loan_Application__c =: recordId AND Inactive__c = false WITH SECURITY_ENFORCED];
            Map<String, Payment__c> internalBT = new Map<String, Payment__c>();
            Map<String, Payment__c> pf = new Map<String, Payment__c>();
            for(Payment__c payment: paymentFavourings){
                if(payment.RecordType.DeveloperName=='Balance_Transfer' && payment.BT_Loan_Status__c=='Fore Closure Refinance'){
                    internalBT.put(payment.Loan_Number__c, payment);
                }else if(payment.RecordType.DeveloperName=='Payment_Favouring'){
                    pf.put(payment.Account_Number__c,payment);
                }
            }
            for(String accNo: internalBT.keySet()){
                if(!pf.containsKey(accNo)){
                    pendingForeClosureAccs.add(accNo);
                }
            }
            return pendingForeClosureAccs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Bank_Account_Records__c getCasaDetails(String loanId) {
        try {
            Applicant__c applicantInstance = [SELECT Id,RecordType.Name
                FROM Applicant__c
                WHERE Loan__c =:loanId
                AND RecordType.Name = 'Applicant'
                WITH SECURITY_ENFORCED
            ];
            List < Bank_Account_Records__c > bankRecords = new   List < Bank_Account_Records__c >();
            if(String.isNotBlank(applicantInstance.Id)){
                bankRecords = [SELECT Id, IFSC_Code__c, Bank_Name__c, Account_Type__c	,RecordType.DeveloperName, Account_Number__c,Applicant__r.Customer_Name__c
                FROM Bank_Account_Records__c 
                WHERE RecordType.DeveloperName = 'CBS'
                AND Account_Type__c ='CASA'
                AND Applicant__c =:applicantInstance.Id 
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC ];
    
            }

            if(bankRecords.size()>0 && !bankRecords.isEmpty()){
                return bankRecords[0];
            }else{
                return null;
            }
            



        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //wrapper class
    public Class RelatedPaymentFavouringsWrapper {
        @AuraEnabled
        public Loan_Application__c loanApp;
        @AuraEnabled
        public String loanType;
        @AuraEnabled
        public Decimal netLoanAmount;
        @AuraEnabled
        public Generic_Master__c pmntFvrngMstr;
        @AuraEnabled
        public List<Payment__c> balanceTransferPymntLst;
        @AuraEnabled
        public List<Payment__c> tranchePymntLst;
        @AuraEnabled
        public Id defaultBankSelected;
    }

    public class TrancheOptionsWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String trancheNumber { get; set; }
        @AuraEnabled public Decimal disbursementAmount { get; set; }
    }
    
}