/*****
 * Class Name: AUSFPSDButtonsController
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-22-2023          -   Mohit Maheshwari    -   SFAU-5249 - make class without sharing due to approval records are locked and avoid exception
 * Nov-03-2023          -   Yash Shukla.        -   SFAU-5459 - FI Negative check
 * Dec-06-2023          -   Yash Shukla         -   SFAU-5264 - Regenerate Letter Check
 */
public without sharing class AUSFPSDButtonsController {
    
    @AuraEnabled
    public static buttonsWrapper getLoanApplication(Id recordId){
        Id loanId;
        buttonsWrapper wrap = new buttonsWrapper();
        Loan_Application__c loanApp;
        try {
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Assignment__c'){
                List<Assignment__c> assignmentRecord = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE id=:recordId WITH SECURITY_ENFORCED];
                loanId = assignmentRecord[0].Loan_Application__c;
            }
            if(sObjName == 'Loan_Application__c'){
                loanId = recordId;
            }   
            if(loanId!=null){
                List<Loan_Application__c> loanAppList = [SELECT Id, DO_Status__c, Sanction_Status__c, Stage__c,RC_Limit_On_Hold__c, total_charges__c, total_loan_amount__c , Application_FI_Status__c, Esign_Status__c, OPS_KYC_Action__c, 
                (Select id, Net_amount__c from Payments__r where recordtype.developerName = 'Payment_Favouring' and Inactive__c = false)
                    FROM Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED];
                if(loanAppList!=null && loanAppList.size()>0){
                    loanApp = loanAppList[0];
                    Decimal netAmt = 0;
                    if(loanApp.Payments__r!=null && loanApp.Payments__r.size()>0){
                        for(Payment__c payment: loanApp.Payments__r){
                            netAmt+= payment.Net_amount__c;
                        }
                    }
                    
                    if(loanApp.Total_Loan_Amount__c!=null && loanApp.Total_Charges__c!=null){
                        System.debug('amount: '+netAmt);
                        System.debug(loanApp.Total_Loan_Amount__c - loanApp.Total_Charges__c);
                        
                        if(netAmt != loanApp.Total_Loan_Amount__c - loanApp.Total_Charges__c){
                            wrap.isPFmismatched = true;
                        }
                    }
                   
                    
                    System.debug('pf mismatched: '+wrap.isPFmismatched);
                }
               
                Loan_Application__c loanApp1 = [SELECT Id,Stage__c,Is_Valuation_Verification_Required__c,Application_FI_Status__c, BRE_Run_for_PreApproved_Offer__c, Esign_Status__c,RC_Limit_On_Hold__c, DO_Status__c, Sanction_Status__c, BRE_ReRun_Required__c, Approval_Status__c, BRE_Approval_Level__c, Valuation_Completion_Date__c,FI_Completion_Date__c,recordTypeId, Pre_Approved_Flag__c,isLoanAmtChanged__c, OPS_KYC_Action__c, 
                (select Assigned_to_Queue__c FROM Loan_Application_Approvers__r where Assigned_to_Queue__c=true) FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED]; //added Is_Valuation_Verification_Required__c for  SFAU-4091 and //SFAU-5147 added isLoanAmtChanged__c field
                wrap.isBreReRunRequired = Utility.getCurrentBREStatus( loanApp1 );
                wrap.isSizeIssue = Utility.checkCifDocSize(loanApp1);
                wrap.loanApplication = loanApp1;

            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        //return loanApp;
        return wrap;
    }

    @AuraEnabled
    public static String handleSendBackToRO(String loanId, String Stage){
        try{
            update new Loan_Application__c(Id = loanId, Stage__c = Stage);
            return 'success';
        } catch(DMLException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String handlePSDValidation(String loanId) { 
        try {
            Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
            Loan_Application__c loanInstance = [SELECT id,Customer_Type__c, ReTrigger_EMI_Schedule__c, isExposureChanged__c,Stage__c,Product__c, Dealer_Master__c,RC_Limit_On_Hold__c,PSD_Submission_Date__c,Total_Loan_Amount__c ,Application_FI_Status__c ,Esign_Type__c,Esign_Date__c,Dpd_Checked_Date__c,Repayment_Mode__c,E_Mandate_Status__c,
                                                (SELECT id, Status__c FROM Sanction_Conditions__r), Sourcing_Channel_Name__c, 
                                                (SELECT id, isVerified__c,Payment_Recipient__c,Inactive__c FROM Payments__r WHERE  Payment_Recipient__c ='Customer' AND Inactive__c = false AND RecordType.DeveloperName = 'Payment_Favouring'), //SFAU-3289
                                                DO_Status__c, Sanction_Status__c, Is_DO_Sanction_Regenerate_Required__c// SFAU-5264
                                                FROM Loan_Application__c
                                                WHERE Id =: loanId
                                                
                                               ];
            
            loanApplicationMap.put(loanInstance.Id,loanInstance);
            //calling RC Limit deferral
            //

            //10 jul
            List<Loan_Application_Approval__c> approvalList = [SELECT id,Name,Approval_Status__c FROM Loan_Application_Approval__c WHERE Approval_Status__c ='Pending' AND Loan_Application__c =:loanInstance.Id and Archived__c = false];
            
            String rcLimitMessage = RCLimitController.getValidLoanIdsAndUpdateRCLimit(loanApplicationMap,'PSD');
            if(rcLimitMessage!='Success' && !Test.isRunningTest()){
                return rcLimitMessage;
            }
            
            /***************SFAU-5264**************************** */
            if((loanInstance.DO_Status__c == 'Issued' || loanInstance.Sanction_Status__c == 'Issued') && loanInstance.Is_DO_Sanction_Regenerate_Required__c){
                return System.Label.Regenerate_System_Letters_Message;
            }
            if((loanInstance.DO_Status__c != 'Issued' && loanInstance.Sanction_Status__c != 'Issued')){
                return 'Please Generate DO and Sanction Letters to Proceed';
            }
            /************ */

            

           
            String loanApplicantFI = String.isNotBlank(loanInstance.Application_FI_Status__c) ? loanInstance.Application_FI_Status__c :'';   
            List< Collateral__c> collateralInstance = [SELECT id, Loan__c,Vehicle_Delivery__c
                FROM Collateral__c
                WHERE Loan__c =: loanId AND  Is_Deleted__c=false AND RecordTypeId IN: GlobalConstants.colRecordTypeIds
            ];
            List < Valuation__c > valuationInstance = new List < Valuation__c > ();
            Collateral__c collateralRec = collateralInstance.isEmpty() ? null : collateralInstance[0];

            if (collateralInstance.size()>0) { //AND Completion_Date_Time__c != null
                valuationInstance = [SELECT id, Completion_Date_Time__c, Collateral__r.Loan__c
                    FROM Valuation__c
                    WHERE Collateral__r.Loan__c =: loanId
                    
                ];

            }
            //FI Validation  
            List<Field_Investigation__c> fiList = [SELECT id,Name,Loan_Application__c,FI_Status__c
                                                   FROM Field_Investigation__c
                                                   WHERE FI_Status__c='Positive'
                                                   AND Loan_Application__c=:loanId];
                    

            Boolean isExpValidated = true;
            Boolean isSancValidated = false;
            Boolean isPaymValidated = true;
            Boolean isValValidated = false;
            Boolean isCustomerSign = true;
            Boolean isDocumentCheck = false;
            Boolean isEsignCheck = false;
            Boolean isFICheck = true;
            //EMI Amount mismatch in EMI Schedule and on Loan - Neha
            Boolean isEMIScheduleDone = loanInstance.ReTrigger_EMI_Schedule__c?false:true;
            Boolean isVehicleDelivered = collateralRec == null ? false : String.isNotBlank(collateralRec.Vehicle_Delivery__c);
            Boolean emandateCheck = true; //25 JUL
            List<Boolean> isCustomerSignList = new List<Boolean>();
            List<Boolean> isSanctionList = new List<Boolean>();
            List<Boolean> isPaymentList = new List<Boolean>();
            String returnMessage = 'The below validations checks are missing ';
            List<Sanction_Condition__c> sanctionList = loanInstance.Sanction_Conditions__r;
            List<Payment__c> pyamentList = loanInstance.Payments__r;

            //Get Applicants for the loan
            List<Applicant__c>applicantList =  getAllApplicants(loanId);


            Set<Id> docInstanceIds = new Set<Id>();
            Map<Id,List<Id>> mapApplvsDocIdlist = new  Map<Id,List<Id>>();
            Map<Id,Id> mapDocIdvsApplId = new  Map<Id,Id>();
            for (Applicant__c applicantInstance: applicantList) {
                List < Document_Checklist__c > docList = applicantInstance.Document_Checklists__r;
                system.debug('docList:::'+docList);
                if (docList.size() > 0) {
                    for (Document_Checklist__c docInstance: docList) {
                        if (mapApplvsDocIdlist.containskey(applicantInstance.id)) {
                            List < Id > docIdList = mapApplvsDocIdlist.get(applicantInstance.id);
                            docIdList.add(docInstance.Id);
                            mapApplvsDocIdlist.put(applicantInstance.Id, docIdList);
                        } else {
                            List<Id> docNewId = new List<Id>();
                            docNewId.add(docInstance.Id);
                            mapApplvsDocIdlist.put(applicantInstance.Id,docNewId);
                        }
                        mapDocIdvsApplId.put(docInstance.Id,applicantInstance.Id);
                        docInstanceIds.add(docInstance.Id);
                    }
                }
            }
            List<ContentDocumentLink> documentLinkList = new   List<ContentDocumentLink>();
           if(docInstanceIds!=null && docInstanceIds.size()>0){
            documentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: docInstanceIds];
           }
            

            //Applicant -ContentDoclinkId
            Map<Id,List<Id>> mapApplvsContentList = new  Map<Id,List<Id>>();
           if(documentLinkList.size()>0){
            for(ContentDocumentLink contLink : documentLinkList){
                String applicantId =  mapDocIdvsApplId.get(contLink.LinkedEntityId);
                if(mapApplvsContentList.containsKey(applicantId)){
                    List<Id> contIdlist = mapApplvsContentList.get(applicantId);
                    contIdlist.add(contLink.Id);
                    mapApplvsContentList.put(applicantId,contIdlist);
                }else{
                     List<Id> docNewId = new List<Id>();
                            docNewId.add(contLink.Id);
                    mapApplvsContentList.put(applicantId,docNewId);
                }
            }
           }
           system.debug('mapApplvsContentList::'+mapApplvsContentList);
           if(applicantList.size()>0){
            for(Applicant__c applicantInstance : applicantList){
              
                if(applicantInstance.Customer_Type__c !='Non Individual'){
                 if(String.isNotBlank(applicantInstance.CIF_No__c) && applicantInstance.CBS_Signature_Available__c == false){
                     if(mapApplvsContentList.get(applicantInstance.Id)!=null){
                         isCustomerSignList.add(true);
                     }else{
                         
                         isCustomerSignList.add(false);
                     }
                 }else{
                     if(mapApplvsContentList.get(applicantInstance.Id)!=null){
                         isCustomerSignList.add(true);
                     }else{
                         isCustomerSignList.add(false);
                     }
                 }
             }
            }
 
           }
        if (sanctionList.size()>0) {
            for(Sanction_Condition__c sanctionInstance :sanctionList){
                if(sanctionInstance.Status__c == 'Compliant'){
                   // isSancValidated = true;  
                   isSanctionList.add(true);
                }else{
                    isSanctionList.add(false);
                 //   returnMessage +='Sanction Check ';
                }
            }
         }

         if (pyamentList.size()>0) {
            for(Payment__c  paymentInstance :pyamentList){
                if(paymentInstance.isVerified__c == true  ){
                    isPaymentList.add(true);
                }else{
                    isPaymentList.add(false);
                }
            }
         }

         

           Utility.Result docResult = Utility.checkUploadedDocs(loanId,loanInstance.Stage__c);
           System.debug('docResut-->' +docResult);
            Boolean isExposuredValid =false;
           for(Applicant__c applicantINstance : applicantList){
                if(applicantINstance.Existing_Customer__c == 'Yes'){
                    isExposuredValid = true;
                }
           }
           List<EMI_Date_Master__mdt> emiMasterList = [SELECT id,Due_Date__c,Product_Name__c 
           FROM EMI_Date_Master__mdt ];
           Date checkedDate = loanInstance.Dpd_Checked_Date__c!= null ? loanInstance.Dpd_Checked_Date__c : null;
           Date todayDate = Date.today();
           for(EMI_Date_Master__mdt emiInstance : emiMasterList){
            if(emiInstance.Product_Name__c.contains('Wheels')){ // Later need to be changed based on the product as of now in this release we have only wheeler
                if(checkedDate!=null){
                    Decimal DateInstance = checkedDate.day();
                    Decimal todayDateInstance = todayDate.day();
                    if(DateInstance <= emiInstance.Due_Date__c && todayDateInstance >= emiInstance.Due_Date__c){
                        isExpValidated = true;
                    }
                }
            }
            }


             //Conditions to check
           if(loanInstance.Dpd_Checked_Date__c!=null){
            if(isExposuredValid == true){
                if (loanInstance.isExposureChanged__c == true) {
                    isExpValidated = true;
                }else{
                    isExpValidated = false;
                    returnMessage +='Exposure Check '+'\n';
                }
            }
            }
           
            
            if(isSanctionList.size()>0){
                if(isSanctionList.contains(false)){
                    returnMessage +='Sanction Check '+'\n';
                }else{
                    isSancValidated = true;
                }
            }else{
                isSancValidated = true;
            }

            if (isPaymentList.size()>0) {
                if(isPaymentList.contains(false)){
                    returnMessage +='Payment Check '+'\n';
                    isPaymValidated = false;
                }else{
                    isPaymValidated = true;
                }
            }

            //Product should be of Used Type oly then only valuation check is valid
            if(loanInstance.Product__c == '10202' || loanInstance.Product__c == '10203' ||loanInstance.Product__c == '10302'|| loanInstance.Product__c == '10303' || loanInstance.Product__c == '10205'|| loanInstance.Product__c == '10402' || loanInstance.Product__c == '10105' || loanInstance.Product__c == '10102' || loanInstance.Product__c == '10502' ){
                Boolean recordCheck = AUSFValuationController.getValuationRecord(loanInstance.Id); // updated check for SFAU-4476
                if (valuationInstance.size()>0 || recordCheck == true ) {
                    isValValidated = true;
                }else{
                    returnMessage +='Valuation Check \\n' ;
                     isValValidated = false;
                }
            }else{
                 isValValidated = true;
            }
            system.debug('isCustomerSignList::'+isCustomerSignList);
            if(isCustomerSignList!=null && !isCustomerSignList.isempty() && (isCustomerSignList.contains(false) || isCustomerSignList.size()==0) && loanInstance.Customer_Type__c !='Non Individual'){
                returnMessage +='CustomerSign Check \\n';
                isCustomerSign = false;
            }else{
                isCustomerSign = true;
            }

            //Esign check
            if( ( loanInstance.Esign_Type__c == 'Digital' ||  loanInstance.Esign_Type__c == 'Physical') &&  ( loanInstance.Esign_Date__c <= System.today() )){ //loanInstance.Esign_Date__c == System.today() ||
                isEsignCheck = true;
            }else if(loanInstance.Customer_Type__c!='Non Individual'){
                isEsignCheck=false;
                returnMessage +='E Sign Check \\n';
            }

            
            Boolean isPaymentFavouringCheck = true;
            if(checkPaymentFavouringApproval(loanId)){
                isPaymentFavouringCheck = false;
                returnMessage +='Payment Favouring Approval Pending \\n';
            }
            
            /*SFAU-5459 Changes********************/
            isFICheck = true;
            List<Loan_Application_Approval__c> creditApprovals = [SELECT Id,Name,Approval_Status__c FROM Loan_Application_Approval__c WHERE Approval_Status__c ='Pending' AND Loan_Application__c =:loanInstance.Id and Archived__c = false AND Approval_Type__c = 'Credit'];

            List<AggregateResult> relatedFiCount = [SELECT Count(Id) RecordCount, FI_Status__c FROM 
                                                    Field_Investigation__c WHERE Loan_Application__c = :loanId AND Re_Trigger__c = FALSE GROUP BY FI_Status__c];
            for(AggregateResult resultRec : relatedFiCount){
                Integer recordCount = Integer.valueOf(resultRec.get('RecordCount'));
                String statusName = String.valueOf(resultRec.get('FI_Status__c'));
                if(statusName == 'Negative' && !creditApprovals.isEmpty()){
                    isFICheck = false;
                    returnMessage +='FI Check \\n';
                    break;
                }
                else if((statusName == 'In Progress' || statusName == 'Assigned' || statusName == 'New' || statusName == null || statusName == '') && recordCount>0){
                    isFICheck = false;
                    returnMessage +='FI Check \\n';
                    break;
                }
                else if((statusName == 'Positive' || statusName == 'Waived Off' || statusName == 'Cancelled')){
                    isFICheck = true;
                }
            }
            /************************************ */

            
            // /*
            // if((fiList!=null && fiList.size()>0 ) || (loanApplicantFI == 'Waived Off')){
            //     isFICheck = true;
            //  }*/
            //  if(loanApplicantFI == 'Positive' || loanApplicantFI == 'Waived Off' || loanApplicantFI == 'Cancelled' || loanApplicantFI == 'Negative') { // || loanApplicantFI == 'Negative' 
            //     isFICheck = true;
            //  }
            //  /*Commented By Yash post discussing with Mohit 31 August*/ 
            //  //else if(loanApplicantFI == 'In Progress' || loanApplicantFI == 'Assigned' || loanApplicantFI == 'New' || (loanApplicantFI=='Negative' && approvalList!=null && approvalList.size()>0)){ 
            //     //loan application fi - status - inprogress - error 
            //     //loan application fi - status - neg - loan application approval - pending - error
            // else if(loanApplicantFI == 'In Progress' || loanApplicantFI == 'Assigned' || loanApplicantFI == 'New'){
            //     isFICheck = false;
            //     returnMessage +='FI Check \\n';
            //  }
            
             //JUL 25
             if(String.isNotBlank(loanInstance.Repayment_Mode__c)){
                if(loanInstance.Repayment_Mode__c == 'E mandate without PDC' || loanInstance.Repayment_Mode__c == 'E mandate with PDC' ){
                    if(loanInstance.E_Mandate_Status__c == 'Accepted'){
                        emandateCheck = true;
                    }else{
                        emandateCheck = false;
                        returnMessage +='E Mandate Check \\n';
                    }
                }
            }else{
                emandateCheck = true;
            }
            
            //END

            if(docResult.status == 'Success'){
                isDocumentCheck = true;
            }else{
                returnMessage +='Document Check \\n'+'-'+ docResult.messages ;
            }



            if(isVehicleDelivered == true){
               
            }else{
                returnMessage +='Vehicle Delivery is Required.'+'\n';
            }
            
            //EMI Amount mismatch in EMI Schedule and on Loan - Neha
            if(isEMIScheduleDone==false){
                returnMessage +='Re-initiate EMI Schedule \\n';
            }
            
            // Tractor TAR Validation check R2-2153
            Boolean isTARValid = true;
            try{
                ProductRTMap__mdt productRT = ProductRTMap__mdt.getInstance('A_'+loanInstance.Product__c);
                if(productRT.Product_Type__c == 'Tractor' && productRT.Sub_Product__c == 'New' && loanInstance.Stage__c == 'PSD'){
                    String tarValidity = AusfbTractorTarContainerController.validateTARSubmitOrApproval(loanInstance.Id);
                    if(tarValidity == 'throwerror'){
                        isTARValid = false;
                        returnMessage += System.Label.TAR_PSD_Validation_Error_Message + '\\n';
                    }
                }
            }
            catch(Exception e){
                System.debug('Exception occured while validating TAR ' + e.getMessage());
            }
            // Tractor TAR Validation check R2-2153

            System.debug('isExpValidated-->' +isExpValidated);
            System.debug('isFICheck-->' +isFICheck);
            System.debug('isSancValidated-->' +isSancValidated);
            System.debug('isPaymValidated-->' +isPaymValidated);
            System.debug('isValValidated-->' +isValValidated);
            System.debug('isCustomerSign-->' +isCustomerSign);
            System.debug('isDocumentCheck-->' +isDocumentCheck);
            System.debug('emandateCheck-->' +emandateCheck);
            System.debug('isVehicleDelivered-->' +isVehicleDelivered);
            System.debug('isEsignCheck-->' +isEsignCheck);
            System.debug('returnMessage-->' +returnMessage);
                
            if(isExpValidated == true && isSancValidated == true &&  isPaymValidated == true && isValValidated == true && isCustomerSign == true && isDocumentCheck == true &&  isFICheck == true && emandateCheck == true && isEsignCheck == true && isVehicleDelivered == true && isEMIScheduleDone == true && isPaymentFavouringCheck == true && isTARValid == true){
                return 'Success';
            }else{
                return returnMessage;
            }

           

        } catch (Exception e) {
            System.debug('exception-->' + e.getMessage());
            System.debug('exception-->' + e.getLineNumber()+' '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean checkPaymentFavouringApproval(String loanId){
        List<Loan_Application_Approval__c> lstLoanApp = [SELECT Id,Archived__c,Approval_Type__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =:loanId 
                                                        AND Archived__c=false AND Approval_Type__c='OEMApproval' AND Approval_Status__c = 'Pending' WITH SECURITY_ENFORCED];
        if(!lstLoanApp.isEmpty()){
            return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static String checkIfPricingApprovalRequired(String loanId){
        try {
            Loan_Application__c loan = [SELECT Id, Is_Charge_Changed__c FROM Loan_Application__c WHERE Id=:loanId];
            List<Sobject> sobjectsToUpdate = new List<Sobject>();
            if(loan.Is_Charge_Changed__c==true){
                List<Loan_Application_Approval__c> pricingApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c= :loanId AND Approval_Type__c=:GlobalConstants.APPROVAL_TYPE_PRICING AND Archived__c=false];
                if(pricingApprovals!=null && pricingApprovals.size()>0){
                    for(Loan_Application_Approval__c pricingApproval: pricingApprovals){
                        pricingApproval.Archived__c=true;
                        sobjectsToUpdate.add(pricingApproval);
                    }
                }
                Loan_Application__c updateLoan = new Loan_Application__c();
                updateLoan.Id=loan.Id;
                updateLoan.Stage__c='Pricing';
                updateLoan.No_Pricing_Deviation__c=false;
                updateLoan.Is_Charge_Changed__c=false;
                updateLoan.is_Pricing_Required__c=false;
                sobjectsToUpdate.add(updateLoan);
                if(sobjectsToUpdate!=null && sobjectsToUpdate.size()>0){
                    update sobjectsToUpdate;
                }
                return 'Failed';
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Error message --> ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Get applicants for the loan
    public static List<Applicant__c> getAllApplicants(String loanId){
        List<Applicant__c> applicantLst = [SELECT id,CIF_No__c,Loan__c,Customer_Type__c,IsInactive__c,CBS_Signature_Available__c,Existing_Customer__c,RecordType.DeveloperName,(SELECT id,Name,Document_Master__r.Document_Name__c,Document_Name__c FROM Document_Checklists__r WHERE (Document_Master__r.Document_Name__c='Customers Signature' OR Document_Name__c='Customers Signature' ))
                                           FROM Applicant__c
                                           WHERE Loan__c=:loanId
                                           AND IsInactive__c = false//June 13
                                           AND RecordType.DeveloperName != 'Additional_Match'
                                           AND RecordType.DeveloperName != 'BO'
                                           AND RecordType.DeveloperName != 'Nominee'
                                           AND  RecordType.DeveloperName != 'Non_Individual'
                                           WITH SECURITY_ENFORCED];
        System.debug('applicantLst-->' +applicantLst);

        if(applicantLst.size()>0){
            return applicantLst;
        }else{
            return null;
        }
    }

    public class buttonsWrapper{
        @AuraEnabled public Boolean isBreReRunRequired{get;set;}
        @AuraEnabled public Boolean isSizeIssue{get;set;}
        @AuraEnabled public Boolean isPFmismatched{get;set;}
        @AuraEnabled public Loan_Application__c loanApplication{get;set;}
        
    }

}