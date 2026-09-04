/*
@ Class Name: BreOutputScreenController
@ Test Class: BreOutputScreenTest
@ Code Coverage: 
@ Description: Read the BRE Response and Display on Screen
@ Logs:
@   Last Modified Date  -   Last Modified By    -   Bug
@   June-1-2023         -   Mohit M.            -   SFAU-2190
@   June-5-2023         -   Mohit M.            -   BRE-Rerun
@   June-12-2023        -   Mohit M.            -   getBreResponse - SFAU-2951 - in BRE response credit level and deviation level is not showing
@   June-13-2023        -   Mohit M.            -   SFAU-3099 - Update Selected Scheme on Loan Application Logic
@   June-24-2023        -   Mohit M.            -   SFAU-3574 - Archived existing Deviation records created from BRE
@   July-04-2023        -   Mohit M.            -   SFAU-3804 - BRE Run and Stage Change Logic - PSD to Credit
@   July-12-2023        -   Mohit M.            -   Set Send_Back_To_RO_Stage__c as Blank on BRE Run
@   July-12-2023        -   Mohit M.            -   Updated SelectedScheme Method - Charge Details - changes as discussed with Mohit and Subha - July-12 Demo Feedback
@   July-31-2023        -   Mohit M.            -   Change as per Email on July-30th and July-31st - Get the Normal Scheme Processing Fees charge from Charge Master when RO selected scheme doesn't have any charge master associated.
@   Aug-08-2023         -   Mohit M.            -   SFAU-3838 - Update Total Verified Income on Loan Application Level received from BRE response
@   Aug-22-2023         -   Mohit M.            -   SFAU-4922 - Add Department as Credit
@   Sept-13-2023        -   Mohit M.            -   SFAU-4474 - Rate Value As per Policy Sep-13 - Mohit
@   Sept-17-2023        -   Mohit M.            -   START - SFAU-5141
@   Sept-29-2023        -   Mohit M.            -   SFAU-4063 - update BRE_Run_for_PreApproved_Offer__c
@   Oct-09-2023         -   Neha                -   SFAU-4473 is_Pricing_Required__c = false
@   Oct-15-2023         -   Mohit M.            -   SFAU-5398 - Change ProcessingFee Charge record - Avoid "Rate Value as per policy" calculation and update from FICO payload "OVERRIDE_PF_RATE" logic
@   Nov-09-2023         -   Mohit M.            -   SFAU-5570 - CUG|| Case is not moving to PSD after pricing approval
@   Nov-30-2023         -   Mohit M.            -   SFAU-5664 - Set uwAuthority Base Level when uwAuthority is NULL
@   Dec-04-2023         -   Yash S              -   SFAU-5624 - Is_DO_Sanction_regerenate Logic added
@   Dec-15-2023         -   Yash S              -   SFAU-5747 - 4Wheeler Approval Level


*/
public class BreOutputScreenController {
    
    /*
    @ description: invoke by LwC Component and display BRE Output
    @ param1: loanAppId
    */
    @AuraEnabled
    public static BreOutputScreenControllerWrapper getBreResponse(Id loanAppId){
        //If record id is Loan Application
        Schema.SObjectType LoanApplicationObject = Schema.Loan_Application__c.getSObjectType();
        Schema.SObjectType record = loanAppId.getsobjecttype();
        BREResponseWrapper breResWrapObj;
        BreOutputScreenControllerWrapper breWrap = new BreOutputScreenControllerWrapper();
        breWrap.blnSuccess = true;
        breWrap.hasShowCriteriaPermission = false;
        breWrap.isCreditManager = false;
        try {
            If(record == LoanApplicationObject){
                String strBREStatus = '';
                Loan_Application__c loanApp = [SELECT Id, Scheme__r.Scheme_Code__c, Bre_Status__c, BRE_Run_Request_Id__c, BRE_RO_Selected_Scheme__c, (SELECT Id, createdDate, BRE_Response__c, Is_Confirmed__c, BRE_Request_Id__c, Update_New_Response__c FROM BRE_Responses__r WHERE Integration_CheckList__r.Integration_Master__r.Name = 'FICO BRE' ORDER BY CreatedDate DESC) FROM Loan_Application__c WHERE ID =: loanAppId ];
                breWrap.strROSelectedSchemeId = String.isNotBlank(loanApp.BRE_RO_Selected_Scheme__c) ? loanApp.BRE_RO_Selected_Scheme__c : '';
                if (loanApp.BRE_Status__c == Label.BRE_Decision_Error) {
                    breWrap.blnBREError = true;
                    strBREStatus = loanApp.BRE_Status__c;
                }
                else if(loanApp.BRE_Status__c == Label.BRE_Status_In_Progress && String.isNotBlank(loanApp.BRE_Run_Request_Id__c) && loanApp.BRE_Responses__r != NULL && loanApp.BRE_Responses__r.size()>0 && loanApp.BRE_Run_Request_Id__c == loanApp.BRE_Responses__r[0].BRE_Request_Id__c) {
                    strBREStatus = Label.BRE_Status_Received;
                    breWrap.breResponse = loanApp.BRE_Responses__r[0];
                    if(loanApp.BRE_Responses__r[0].BRE_Response__c != null){
                        if(loanApp.BRE_Responses__r[0].BRE_Response__c != null && loanApp.BRE_Responses__r[0].Update_New_Response__c){
                            breWrap.strBreResponse = getBreResponseWithLabels(loanApp.BRE_Responses__r[0].BRE_Response__c);
                        }
                        else if (loanApp.BRE_Responses__r[0].BRE_Response__c != null && !loanApp.BRE_Responses__r[0].Update_New_Response__c) {
                            // Hot Fix START - Update BRE Response payload for Old Record and add new attributes
                            breResWrapObj = BREResponseWrapper.parse(loanApp.BRE_Responses__r[0].BRE_Response__c);
                            String strUpdateResp = updateBREResponse(breResWrapObj, breWrap.strROSelectedSchemeId);
                            BRE_Response__c objUpdateBREResp = new BRE_Response__c();
                            objUpdateBREResp.Id = loanApp.BRE_Responses__r[0].Id;
                            objUpdateBREResp.BRE_Response__c = strUpdateResp;
                            objUpdateBREResp.Update_New_Response__c = true;
                            update objUpdateBREResp;
                            loanApp.BRE_Responses__r[0].BRE_Response__c = strUpdateResp;
                            breWrap.strBreResponse = getBreResponseWithLabels(loanApp.BRE_Responses__r[0].BRE_Response__c);
                        }
                        /*
                        if(breResWrapObj.message.application.product[0].productDecision != null){
                            //loanAppObj.BRE_Product_Decison__c = String.valueOf(breResWrapObj.message.application.product[0].productDecision);
                            if (breResWrapObj.message.application.product[0].productDecision.schemeDecision != NULL && breResWrapObj.message.application.product[0].productDecision.schemeDecision.size() > 0) {
                                List<BREResponseWrapper.cls_schemeDecision> lstUpdatedSchemeDecision = new List<BREResponseWrapper.cls_schemeDecision>();
                                List<BREResponseWrapper.cls_schemeDecision> lstSchemeDecision = breResWrapObj.message.application.product[0].productDecision.schemeDecision;
                                List<BREResponseWrapper.cls_deviationsDetails> lstBusinessDeviation = new List<BREResponseWrapper.cls_deviationsDetails>();
                                Boolean blnHasEligibleBusDev = false;
                                Boolean blnHasCommonDev = false;
                                for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstSchemeDecision) {
                                    blnHasEligibleBusDev = ((blnHasEligibleBusDev || (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible)) ? true : false); 
                                    if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common && lstBusinessDeviation.size()>0) {
                                        continue;
                                    }
                                    blnHasCommonDev = (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common) ? true : false; 
                                    if (objSchemeDec.schemeId != breWrap.strROSelectedSchemeId && objSchemeDec.isEligible == false && !blnHasCommonDev)
                                        continue;
                                    List<BREResponseWrapper.cls_deviationsDetails> lstClsDeviations =  objSchemeDec.deviationsDetails != NULL && objSchemeDec.deviationsDetails.size()>0 ? objSchemeDec.deviationsDetails : new List<BREResponseWrapper.cls_deviationsDetails>();
                                    for (BREResponseWrapper.cls_deviationsDetails objDev : lstClsDeviations) {
                                        List<BREResponseWrapper.cls_calculatedVariables> lstClsCalVar = objDev.calculatedVariables != NULL && objDev.calculatedVariables.size() > 0 ? objDev.calculatedVariables : new List<BREResponseWrapper.cls_calculatedVariables>();
                                        Boolean blnFoundPolicyLevel = false;
                                        Boolean blnFoundActualLevel = false;
                                        Decimal policyVal = 0;
                                        Decimal actualVal = 0;
                                        for (BREResponseWrapper.cls_calculatedVariables objCalculated : lstClsCalVar) {
                                            if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Policy && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                                blnFoundPolicyLevel = true;
                                                policyVal = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                                            }
                                            if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Actual && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                                blnFoundActualLevel = true;
                                                actualVal = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                                            }
                                            if (blnFoundPolicyLevel && blnFoundActualLevel) {
                                                objDev.variance = policyVal - actualVal;
                                            }
                                        }
                                        objDev.reasonText = String.isNotBlank(objDev.applicantId) ? objDev.reasonText + ' for Applicant ' + objDev.applicantId : objDev.reasonText;
                                        if (blnHasCommonDev) {
                                            lstBusinessDeviation.add(objDev); 
                                        }
                                    }
                                    if (blnHasCommonDev) { continue ;}
                                    objSchemeDec.blnSchemeSelectedByRO = objSchemeDec.schemeId == breWrap.strROSelectedSchemeId ? true : false;
                                    objSchemeDec.strSchemeNameWithWOEligible = objSchemeDec.schemeName + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                                    objSchemeDec.strSchemeCodeWithWOEligible = objSchemeDec.schemeId + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                                    lstUpdatedSchemeDecision.add(objSchemeDec);
                                }
                                system.debug(LoggingLevel.Info,' :: ' + blnHasEligibleBusDev);
                                if (blnHasEligibleBusDev) {
                                    for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstUpdatedSchemeDecision) {
                                        if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible && (objSchemeDec.deviationsDetails == NULL || objSchemeDec.deviationsDetails.size() == 0) && lstBusinessDeviation.size()>0) {
                                            objSchemeDec.deviationsDetails = lstBusinessDeviation;
                                        }
                                        system.debug(LoggingLevel.Info,' :: objSchemeDec :: ' + objSchemeDec);
                                    }
                                }
                                breResWrapObj.message.application.product[0].productDecision.schemeDecision = lstUpdatedSchemeDecision;
                            }
                        }
                        String strSerializeResp = JSON.serialize(breResWrapObj);
                        // Hot Fix START - Update BRE Response payload for Old Record and add new attributes
                        breWrap.strBreResponse = getBreResponseWithLabels(strSerializeResp);
                        */
                    }
                }
                else if(loanApp.BRE_Status__c == Label.BRE_Status_In_Progress && String.isNotBlank(loanApp.BRE_Run_Request_Id__c) && loanApp.BRE_Responses__r != NULL && loanApp.BRE_Responses__r.size()>0 && loanApp.BRE_Run_Request_Id__c != loanApp.BRE_Responses__r[0].BRE_Request_Id__c) {
                    breWrap.blnBREError = true;
                    strBREStatus = Label.BRE_Decision_Error;
                }
                else if(loanApp.BRE_Status__c == Label.BRE_Status_Received && !loanApp.BRE_Responses__r.isEmpty()){
                    strBREStatus = Label.BRE_Status_Received;
                    breWrap.breResponse = loanApp.BRE_Responses__r[0];
                    if(loanApp.BRE_Responses__r[0].BRE_Response__c != null){
                        if(loanApp.BRE_Responses__r[0].BRE_Response__c != null && loanApp.BRE_Responses__r[0].Update_New_Response__c){
                            breWrap.strBreResponse = getBreResponseWithLabels(loanApp.BRE_Responses__r[0].BRE_Response__c);
                        }
                        else if (loanApp.BRE_Responses__r[0].BRE_Response__c != null && !loanApp.BRE_Responses__r[0].Update_New_Response__c) {
                            // Hot Fix START - Update BRE Response payload for Old Record and add new attributes
                            breResWrapObj = BREResponseWrapper.parse(loanApp.BRE_Responses__r[0].BRE_Response__c);
                            String strUpdateResp = updateBREResponse(breResWrapObj, breWrap.strROSelectedSchemeId);
                            BRE_Response__c objUpdateBREResp = new BRE_Response__c();
                            objUpdateBREResp.Id = loanApp.BRE_Responses__r[0].Id;
                            objUpdateBREResp.BRE_Response__c = strUpdateResp;
                            objUpdateBREResp.Update_New_Response__c = true;
                            update objUpdateBREResp;
                            loanApp.BRE_Responses__r[0].BRE_Response__c = strUpdateResp;
                            breWrap.strBreResponse = getBreResponseWithLabels(loanApp.BRE_Responses__r[0].BRE_Response__c);
                        }
                    }
                }
                breWrap.breStatus = String.isNotBlank(strBREStatus) ? strBREStatus : loanApp.Bre_Status__c;
                breWrap.loanAppId = loanApp.Id;
                breWrap.schemeCode = loanApp.Scheme__r.Scheme_Code__c;
                breWrap.blnBRESuccess = true;
            }
            else{
                BRE_Response__c breResponse = [SELECT Id, createdDate, BRE_Response__c, Is_Confirmed__c, Loan_Application__c, Loan_Application__r.Bre_Status__c, Loan_Application__r.Scheme__r.Scheme_Code__c FROM BRE_Response__c WHERE Id =: loanAppId];
                breWrap.breResponse = breResponse;
                if (breResponse.Loan_Application__r.Bre_Status__c == Label.BRE_Decision_Error || breResponse.Loan_Application__r.Bre_Status__c == Label.BRE_Status_In_Progress) {
                    breWrap.blnBREError = true;
                }
                else if(breResponse.Loan_Application__r.BRE_Status__c == Label.BRE_Status_Received && breResponse.BRE_Response__c != null) {
                    breWrap.strBreResponse = getBreResponseWithLabels(breResponse.BRE_Response__c);
                    breWrap.blnBRESuccess = true;
                }
                breWrap.breStatus = breResponse.Loan_Application__r.Bre_Status__c;
                breWrap.loanAppId = breResponse.Loan_Application__c;
                breWrap.schemeCode = breResponse.Loan_Application__r.Scheme__r.Scheme_Code__c;
            }
            // As per - SFAU-2951
            breWrap.hasShowCriteriaPermission = FeatureManagement.checkPermission('Display_BRE_UW_Criterias');
            breWrap.isCreditManager = FeatureManagement.checkPermission('FiWaiverViewPermission');
            system.debug(LoggingLevel.Info,'::: breWrap ' + breWrap);
        }
        catch (Exception ex) {
            breWrap.blnSuccess = false;
        }
        return breWrap;
    }

    public static String updateBREResponse(BREResponseWrapper breResWrapObj, String strROSelectedSchemeId) {
        String strSerializeResp = '';
        try {
            if(breResWrapObj.message.application.product[0].productDecision != null){
                //loanAppObj.BRE_Product_Decison__c = String.valueOf(breResWrapObj.message.application.product[0].productDecision);
                if (breResWrapObj.message.application.product[0].productDecision.schemeDecision != NULL && breResWrapObj.message.application.product[0].productDecision.schemeDecision.size() > 0) {
                    List<BREResponseWrapper.cls_schemeDecision> lstUpdatedSchemeDecision = new List<BREResponseWrapper.cls_schemeDecision>();
                    List<BREResponseWrapper.cls_schemeDecision> lstSchemeDecision = breResWrapObj.message.application.product[0].productDecision.schemeDecision;
                    List<BREResponseWrapper.cls_deviationsDetails> lstBusinessDeviation = new List<BREResponseWrapper.cls_deviationsDetails>();
                    Boolean blnHasEligibleBusDev = false;
                    Boolean blnHasCommonDev = false;
                    for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstSchemeDecision) {
                        blnHasEligibleBusDev = ((blnHasEligibleBusDev || (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible)) ? true : false); 
                        if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common && lstBusinessDeviation.size()>0) {
                            continue;
                        }
                        blnHasCommonDev = (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common) ? true : false; 
                        if (objSchemeDec.schemeId != strROSelectedSchemeId && objSchemeDec.isEligible == false && !blnHasCommonDev)
                            continue;
                        List<BREResponseWrapper.cls_deviationsDetails> lstClsDeviations =  objSchemeDec.deviationsDetails != NULL && objSchemeDec.deviationsDetails.size()>0 ? objSchemeDec.deviationsDetails : new List<BREResponseWrapper.cls_deviationsDetails>();
                        for (BREResponseWrapper.cls_deviationsDetails objDev : lstClsDeviations) {
                            List<BREResponseWrapper.cls_calculatedVariables> lstClsCalVar = objDev.calculatedVariables != NULL && objDev.calculatedVariables.size() > 0 ? objDev.calculatedVariables : new List<BREResponseWrapper.cls_calculatedVariables>();
                            Boolean blnFoundPolicyLevel = false;
                            Boolean blnFoundActualLevel = false;
                            Decimal policyVal = 0;
                            Decimal actualVal = 0;
                            for (BREResponseWrapper.cls_calculatedVariables objCalculated : lstClsCalVar) {
                                if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Policy && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                    blnFoundPolicyLevel = true;
                                    policyVal = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                                }
                                if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Actual && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                    blnFoundActualLevel = true;
                                    actualVal = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                                }
                                if (blnFoundPolicyLevel && blnFoundActualLevel) {
                                    objDev.variance = policyVal - actualVal;
                                }
                            }
                            objDev.reasonText = String.isNotBlank(objDev.applicantId) ? objDev.reasonText + ' for Applicant ' + objDev.applicantId : objDev.reasonText;
                            if (blnHasCommonDev) {
                                lstBusinessDeviation.add(objDev); 
                            }
                        }
                        if (blnHasCommonDev) { continue ;}
                        objSchemeDec.blnSchemeSelectedByRO = objSchemeDec.schemeId == strROSelectedSchemeId ? true : false;
                        objSchemeDec.strSchemeNameWithWOEligible = objSchemeDec.schemeName + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                        objSchemeDec.strSchemeCodeWithWOEligible = objSchemeDec.schemeId + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                        lstUpdatedSchemeDecision.add(objSchemeDec);
                    }
                    system.debug(LoggingLevel.Info,' :: ' + blnHasEligibleBusDev);
                    if (blnHasEligibleBusDev) {
                        for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstUpdatedSchemeDecision) {
                            if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible && (objSchemeDec.deviationsDetails == NULL || objSchemeDec.deviationsDetails.size() == 0) && lstBusinessDeviation.size()>0) {
                                objSchemeDec.deviationsDetails = lstBusinessDeviation;
                            }
                            system.debug(LoggingLevel.Info,' :: objSchemeDec :: ' + objSchemeDec);
                        }
                    }
                    breResWrapObj.message.application.product[0].productDecision.schemeDecision = lstUpdatedSchemeDecision;
                }
            }
            strSerializeResp = JSON.serialize(breResWrapObj);
        }
        catch (Exception ex) {
            throw ex;
        }
        return strSerializeResp;
    }
    
    @AuraEnabled
    public static BREOutputUpdate updateSelectedScheme(String loanAppId, String selectedScheme, String breResponseId,String remarks){
        Savepoint sp = Database.setSavepoint();
        system.debug('selectedScheme'+selectedScheme);
        selectedScheme = getBreResponseWithKeys(selectedScheme);
        system.debug('loanAppId'+loanAppId);
        system.debug('selectedScheme'+selectedScheme);
        Loan_Application__c loanAppObj = null;
        BREOutputUpdate objUpdateScreen = new BREOutputUpdate();
        objUpdateScreen.blnSuccess = false;
        try {
            List<Collateral__c> coltrlLst = new List<Collateral__c>();
            List<Deviation__c> deviationLst = new List<Deviation__c>();
            List<Deviation__c> highestPriorityDeviationLst = new List<Deviation__c>();
            List<Deviation__c> deviationLstToUpdate = new List<Deviation__c>();
            List<Charge__c> ChargeLstToDelete = new List<Charge__c>();
            Set<String> SubjectivityMsgTypeSet = new  Set<String>();
            Boolean isProcessingFeeDeviation = false;
            Double dblProcessingFeeRate = 0;
            Boolean blnProcessingFeeRate = false;

            
            loanAppObj = [SELECT Id, Remarks__c, Submission_Remarks__c,RecordTypeId, RecordType.Name, RecordType.DeveloperName, Scheme__c, RBP__c, 
                Deviation__c, BRE_Application_Level__c, Bre_Status__c, Bre_Decision__c, Product__c, 
                Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
                Branch_Master__r.Zone__c, Branch_Master__r.National__c, Branch_Master__r.State__c, Stage__c, Previous_Stage__c, // update Is_Being_Relooked__c flag if previous stage was rejected
                BRE_Approval_Level__c, BRE_Selected_Scheme__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Ops_Subjectivity__c, 
                Is_BRE_Pricing_Deviations__c, Is_Charge_Changed__c, Total_Loan_Amount__c, Sanction_Status__c, DO_Status__c, 
                Send_Back_To_RO_Stage__c, Is_ReWork__c, Total_Verified_Income__c, Is_Being_Relooked__c, Customer_Grade__c, BRE_Run_for_PreApproved_Offer__c, is_Pricing_Required__c,
                Is_DO_Sanction_Regenerate_Required__c// New Field Added for 5264
                FROM Loan_Application__c WHERE Id=: loanAppId];

            //START - SFAU-5141
            List<Applicant__c> lstApplicant = new List<Applicant__c>();
            lstApplicant = [Select Id, Customer_Grade__c from Applicant__c where RecordType.Name = 'Applicant' AND IsInactive__c = FALSE AND Loan__c =: loanAppId];

            /* START - SFAU-3838 */
            List<BRE_Response__c> lstBREResponse = new List<BRE_Response__c>();
            
            lstBREResponse = [Select Id, BRE_Response__c from BRE_Response__c where Id =: breResponseId];
            
            if (String.isNotBlank(lstBREResponse[0].BRE_Response__c)) {
                BREResponseWrapper objBREResp = (BREResponseWrapper)JSON.deserialize(lstBREResponse[0].BRE_Response__c, BREResponseWrapper.class);
                if (objBREResp != NULL && objBREResp.message != NULL && objBREResp.message.application != NULL && objBREResp.message.application.applicationDecision != NULL && objBREResp.message.application.applicationDecision.calculatedVariables != NULL && objBREResp.message.application.applicationDecision.calculatedVariables.size()>0) {
                    for (BREResponseWrapper.cls_calculatedVariables objAppCalVar : objBREResp.message.application.applicationDecision.calculatedVariables) {
                        if (objAppCalVar.fieldName == 'TOTAL_VERIFIED_INCOME' && (objAppCalVar.fieldType == 'real' || objAppCalVar.fieldType == 'Integer')){
                            loanAppObj.Total_Verified_Income__c = String.isNotBlank(objAppCalVar.fieldValue) ? Decimal.valueOf(objAppCalVar.fieldValue).setScale(2) : 0;
                        }
                        if (objAppCalVar.fieldName == 'OVERRIDE_PF_RATE' && (objAppCalVar.fieldType == 'real' || objAppCalVar.fieldType == 'Integer')){
                            blnProcessingFeeRate = true;
                            dblProcessingFeeRate = String.isNotBlank(objAppCalVar.fieldValue) ? Decimal.valueOf(objAppCalVar.fieldValue).setScale(2) : 0;
                        }
                    }
                }
            }
            /* END - SFAU-3838 */
            
            String prod = 'A_'+loanAppObj.Product__c;
            String productType = '';
            String productLabel = '';
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productType = prodRecordType.RecordType__c;
                productLabel = prodRecordType.Label;
            }
            BREResponseWrapper.cls_schemeDecision productResponse =
                (BREResponseWrapper.cls_schemeDecision) JSON.deserialize(selectedScheme, BREResponseWrapper.cls_schemeDecision.class);
            system.debug('productResponse'+productResponse);
            String schemeId = '';
            String schemeName = '';
            List<Scheme_Master__c> schmLst = new List<Scheme_Master__c>();
            if(productResponse.schemeId != null){
                schmLst = [Select Id, Scheme_Name__c FROM Scheme_Master__c WHERE Scheme_Code__c =: productResponse.schemeId];
            }
            if(schmLst.size() > 0){
                schemeId = schmLst[0].Id;
                schemeName = schmLst[0].Scheme_Name__c;
            }
            else {
                throw new CustomException(Label.BRE_Selected_Scheme_Not_Exist_Msg);
            }
            
            loanAppObj.BRE_Selected_Scheme__c = selectedScheme;
            if(String.isNotBlank(remarks)) {
                loanAppObj.Submission_Remarks__c = remarks;
                loanAppObj.Remarks__c = remarks;
            }

            system.debug(LoggingLevel.Info, 'finalIRR :: ' + productResponse.finalIRR);
            if(String.isNotBlank(schemeId)){
                loanAppObj.Scheme__c = schemeId;
                //loanAppObj.scheme_updated__c=true;
            }
            if(productResponse.finalIRR != null)
                loanAppObj.RBP__c = productResponse.finalIRR;
            if(productResponse.maxLTV != null){
                coltrlLst = [SELECT Id FROM Collateral__c WHERE Loan__c =: loanAppId AND (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels') AND Is_Deleted__c = false ORDER BY CreatedDate DESC];
            }
            if(coltrlLst.size() > 0){
                Collateral__c coltrlObj = new Collateral__c();
                coltrlObj.Id = coltrlLst[0].Id;
                coltrlObj.Approved_LTV__c = String.valueOf(productResponse.maxLTV);
                update coltrlObj;
            }
            
            /* START - SFAU-5398 */
            /* Commented as part of SFAU-5570
            if(productResponse.finalProcessingFee != null){
                ChargeLstToDelete =  [SELECT id,Charges_Name__c, Tax_Amount__c, Charge_Amount__c, SC_Code__c, External_Id_For_Upsert__c, Actual_rate__c, Tax_Applicable__c, Tax_Percentage__c, Total_Amount__c, Rate_value_As_per_Policy__c FROM Charge__c WHERE Charges_Name__c = 'Processing Fees' AND Loan_Application__c =: loanAppId];
                //delete the existing charges under Loan Application
                if(ChargeLstToDelete.size() > 0){
                    //if there is no deviation in processing fee
                    if(ChargeLstToDelete[0].Charge_Amount__c != productResponse.finalProcessingFee){
                        isProcessingFeeDeviation = true;
                    }
                }
            }
            */
            if (blnProcessingFeeRate || Test.isRunningTest()) {
                // Query Processing Fee
                ChargeLstToDelete =  [SELECT id,Charges_Name__c, Tax_Amount__c, Charge_Amount__c, SC_Code__c, External_Id_For_Upsert__c, Actual_rate__c, Tax_Applicable__c, Tax_Percentage__c, Total_Amount__c, Rate_value_As_per_Policy__c FROM Charge__c WHERE Charges_Name__c = 'Processing Fees' AND Loan_Application__c =: loanAppId];
                // Add Comparison as part of SFAU-5570
                if (!ChargeLstToDelete.isEmpty() && ChargeLstToDelete[0].Rate_value_As_per_Policy__c != dblProcessingFeeRate) {
                    Charge__c chargeObj = new Charge__c();
                    chargeObj = ChargeLstToDelete[0];
                    chargeObj.Rate_value_As_per_Policy__c = dblProcessingFeeRate;
                    chargeObj.External_Id_For_Upsert__c = String.isBlank(chargeObj.External_Id_For_Upsert__c) ? chargeObj.SC_Code__c + loanAppObj.Id : chargeObj.External_Id_For_Upsert__c;  // To avoid duplicate records
                    upsert chargeObj;
                    isProcessingFeeDeviation = true;
                }
            }
            /* END - SFAU-5398 */
            
            /* Commented as per new logic -  SFAU-5398
            if(productResponse.finalProcessingFee != null){
                ChargeLstToDelete =  [SELECT id,Charges_Name__c, Tax_Amount__c, Charge_Amount__c, SC_Code__c, External_Id_For_Upsert__c, Actual_rate__c, Tax_Applicable__c, Tax_Percentage__c, Total_Amount__c FROM Charge__c WHERE Charges_Name__c = 'Processing Fees' AND Loan_Application__c =: loanAppId];
                //delete the existing charges under Loan Application
                if(ChargeLstToDelete.size() > 0){
                    //if there is no deviation in processing fee
                    if(ChargeLstToDelete[0].Charge_Amount__c != productResponse.finalProcessingFee){
                        isProcessingFeeDeviation = true;
                        delete ChargeLstToDelete;
                    }
                }
                Charge__c chargeObj = new Charge__c();
                ChargesController.initialize(loanAppId);
                ChargesController.isFromBre = true;
                ChargesController.processingFee = productResponse.finalProcessingFee;
                system.debug('schemeName'+schemeName);
                system.debug('productLabel'+productLabel);
                if(String.isNotBlank(schemeName) && String.isNotBlank(productLabel)){
                    List<Charges_Master__c> chargeMasterLst = ChargesController.schemeQuery(schemeName,'Processing Fees '+productLabel);
                    system.debug('chargeMasterLst'+chargeMasterLst);
                    // Change as per Email on July-30th and July-31st
                    // Get the Normal Scheme Processing Fees charge from Charge Master when RO selected scheme doesn't have any charge master associated. 
                    if (chargeMasterLst.isEmpty()) {
                        chargeMasterLst = ChargesController.schemeQuery(Label.BRE_Default_Scheme_for_Master,'Processing Fees '+productLabel);
                    }
                    if(!chargeMasterLst.isEmpty()){
                        chargeObj = ChargesController.createChargeRecord(chargeMasterLst[0]);
                        //as per discussion keeping Actual_rate__c same as Charge amount of deleted/previous PF(Bug : 3174)
                        if(ChargeLstToDelete.size() > 0){
                            /*
                            chargeObj.Actual_rate__c = ChargeLstToDelete[0].Actual_rate__c;
                            chargeObj.Total_Amount__c = productResponse.finalProcessingFee;
                            Double dblTax = 0;
                            if (String.isNotBlank(ChargeLstToDelete[0].Tax_Applicable__c) && ChargeLstToDelete[0].Tax_Applicable__c == 'Yes') {
                                dblTax = ChargeLstToDelete[0].Tax_Percentage__c != NULL ? ChargeLstToDelete[0].Tax_Percentage__c : 0;
                            }
                            chargeObj.Charge_Amount__c = (chargeObj.Total_Amount__c / (1+dblTax)).setScale(2);
                            chargeObj.Tax_Amount__c = ((chargeObj.Charge_Amount__c * dblTax)).setScale(2);
                            chargeObj.Total_Amount__c = productResponse.finalProcessingFee;
                            chargeObj.Rate_value_As_per_Policy__c = ((chargeObj.Charge_Amount__c/loanAppObj.Total_Loan_Amount__c) * 100).setScale(2);
                            * /
                            //changes as discussed with Mohit and Subha - July-12 Demo Feedback
                            Double dblTotalAmnt = productResponse.finalProcessingFee;
                            chargeObj.Actual_rate__c = ChargeLstToDelete[0].Actual_rate__c;
                            chargeObj.Total_Amount__c = (ChargeLstToDelete[0].Total_Amount__c).setScale(0); 
                            Double dblTax = 0;
                            
                            if (String.isNotBlank(ChargeLstToDelete[0].Tax_Applicable__c) && ChargeLstToDelete[0].Tax_Applicable__c == 'Yes') {
                                dblTax = ChargeLstToDelete[0].Tax_Percentage__c != NULL ? ChargeLstToDelete[0].Tax_Percentage__c : 0;
                            }
                            Double dblChargeAmnt = dblTotalAmnt;
                            chargeObj.Charge_Amount__c = (ChargeLstToDelete[0].Charge_Amount__c).setScale(2);
                            chargeObj.Tax_Amount__c = (ChargeLstToDelete[0].Tax_Amount__c).setScale(2);
                            //chargeObj.Total_Amount__c = productResponse.finalProcessingFee;
                            //chargeObj.Rate_value_As_per_Policy__c = ((chargeObj.Charge_Amount__c/loanAppObj.Total_Loan_Amount__c) * 100).setScale(2);
                            chargeObj.Rate_value_As_per_Policy__c = ((dblChargeAmnt/loanAppObj.Total_Loan_Amount__c) * 100).setScale(2); // Change as per SFAU-4474 - Sep-13 - Mohit
                            chargeObj.External_Id_For_Upsert__c = chargeObj.SC_Code__c + loanAppObj.Id;  // To avoid duplicate records
                            chargeObj.Id = !isProcessingFeeDeviation ? ChargeLstToDelete[0].Id : NULL;
                        }
                        chargeObj.Charges_Name__c = 'Processing Fees';
                        chargeObj.Loan_Application__c = loanAppId;
                        upsert chargeObj;
                        ChargesController.updateLoanApplication(loanAppId);
                    }
                    else {
                        if (!Test.isRunningTest())
                        throw new CustomException('Charges are not exist respective to selected Scheme.');
                    }
                }
            }
            */
            
            //Check the Deviations if exists process them
            if(productResponse.deviationsDetails != null && productResponse.deviationsDetails.size() > 0){
                loanAppObj.Deviation__c =  String.valueOf(productResponse.deviationsDetails);
                // breRecord.Scheme_Deviation_Rules__c = String.valueOf(productResponse.deviationsDetails);
                for(BREResponseWrapper.cls_deviationsDetails deviation : productResponse.deviationsDetails){
                    Deviation__c deviationObj = new Deviation__c();
                    deviationObj.Source__c = 'BRE';
                    //Added the below line of code as per SFAU-4307 | SFAU-4922
                    deviationObj.Department__c = System.label.Deviations_Credit;
                    deviationObj.Deviation_Type__c = deviation.ruleLevel;
                    deviationObj.Details__c = deviation.ruleDescription;
                    deviationObj.Level__c = deviation.overrideAuthority;
                    deviationObj.Loan_Application__c = loanAppId;
                    deviationObj.BRE_Response__c = breResponseId;
                    deviationObj.Details__c = deviation.reasonText;
                    Boolean blnFoundPolicyLevel = false;
                    Boolean blnFoundActualLevel = false;
                    if (deviation.calculatedVariables != NULL && deviation.calculatedVariables.size()>0) {
                        for (BREResponseWrapper.cls_calculatedVariables objCalculated : deviation.calculatedVariables) {
                            if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Policy && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                blnFoundPolicyLevel = true;
                                deviationObj.Policy_Value__c = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                            }
                            if (objCalculated.level == Label.BRE_Deviation_Calculated_Level_Actual && (objCalculated.fieldType == 'real' || objCalculated.fieldType == 'Integer')) {
                                blnFoundActualLevel = true;
                                deviationObj.Actual_Value__c = String.isNotBlank(objCalculated.fieldValue) ? Decimal.valueOf(objCalculated.fieldValue).setScale(2) : 0;
                            }
                        }
                        if (blnFoundPolicyLevel && blnFoundActualLevel) {
                            deviationObj.Variance__c = deviationObj.Policy_Value__c - deviationObj.Actual_Value__c;
                        }
                    }
                    // deviationObj.Stage__c = loanAppObj.Stage__c; 
                    deviationLst.add(deviationObj);
                }
            }
            //SFAU-3574 - Archived existing Deviation records created from BRE
            List<Deviation__c> lstDeleteDeviation = new List<Deviation__c>();
            for (Deviation__c objDev : [Select id, Archived__c from Deviation__c where Loan_Application__c =: loanAppId and Source__c = 'BRE' and Archived__c = false]) {
                objDev.Archived__c = true;
                lstDeleteDeviation.add(objDev);
            }
            if (lstDeleteDeviation != NULL && lstDeleteDeviation.size()>0){
                update lstDeleteDeviation;
            }
            
            if(deviationLst.size() > 0){
                insert deviationLst;
            }
            
            //Update BRE Approval Level
            //Integer breApplicationLevel = 0;
            // SFAU-5664 - Set uwAuthority Base Level when uwAuthority is NULL
            loanAppObj.BRE_Application_Level__c = String.isNotBlank(loanAppObj.BRE_Application_Level__c) ? loanAppObj.BRE_Application_Level__c : Label.BRE_Base_Level_UWAuthority;
            Integer breApplicationLevel = Integer.ValueOf(loanAppObj.BRE_Application_Level__c.substring(1));
            /*
            if(String.isNotBlank(loanAppObj.BRE_Application_Level__c)){
                breApplicationLevel = Integer.ValueOf(loanAppObj.BRE_Application_Level__c.substring(1));
            }
            */
            highestPriorityDeviationLst = [SELECT Id, Level__c, Level_Priority__c FROM Deviation__c WHERE Loan_Application__c =: loanAppId AND Level__c != null AND Department__c != 'Pricing' AND Archived__c = false  ORDER BY Level_Priority__c DESC];
            if(!highestPriorityDeviationLst.isEmpty()){
                if(productType == 'Two Wheeler'){
                    if(breApplicationLevel > highestPriorityDeviationLst[0].Level_Priority__c){
                        loanAppObj.BRE_Approval_Level__c = loanAppObj.BRE_Application_Level__c;
                    }
                    else{
                        loanAppObj.BRE_Approval_Level__c = highestPriorityDeviationLst[0].Level__c;
                    }
                }
                else if (productType == 'Four Wheeler' || productType == 'Tractor' || productType == 'Commercial Vehicle' || productType=='Construction Equipment'){
                    loanAppObj.BRE_Approval_Level__c = (String.isNotBlank(loanAppObj.BRE_Application_Level__c) ? loanAppObj.BRE_Application_Level__c : '' ) + highestPriorityDeviationLst[0].Level__c;
                }
                
            }
            else if (productType == 'Two Wheeler' || productType == 'Four Wheeler') {// 5747 CHanges added new Product Type l1
                loanAppObj.BRE_Approval_Level__c = String.isNotBlank(loanAppObj.BRE_Application_Level__c) ? loanAppObj.BRE_Application_Level__c : '';
                loanAppObj.BRE_Approval_Level__c+= (productType == 'Four Wheeler')?System.Label.Base_Level_Deviation:'';
            }
            
            
            Boolean blnCreateBSRPSL = false;
            Boolean blnBSRPSLCredit = false;
            List<Sanction_Condition__c> lstSanctionCondition = new List<Sanction_Condition__c>();
            Boolean blnInsertSanctionRecords = false;
            
            //Check for STP WITH SUBJECTIVITY
            if(productResponse.subjectivityMessages != null && productResponse.subjectivityMessages.size() > 0){
                for(BREResponseWrapper.cls_subjectivityMessages subjectivityMsg : productResponse.subjectivityMessages){
                    if(String.isNotBlank(subjectivityMsg.type)) {
                        SubjectivityMsgTypeSet.add(subjectivityMsg.type);
                        Sanction_Condition__c objSanCondition = new Sanction_Condition__c();
                        objSanCondition.Date_Time__c = System.Today();
                        objSanCondition.Loan_Application__c = loanAppObj.Id;
                        objSanCondition.Raised_By__c = UserInfo.getUserId();
                        objSanCondition.Sanction_Condition__c = subjectivityMsg.message;
                        objSanCondition.Sanction_Type__c = subjectivityMsg.type;
                        lstSanctionCondition.add(objSanCondition);
                    }
                }
            }
            
            /*
            4WH - Current Stage = DDE; Next Stage != Credit -> Create BSR/PSl record
            2WH - Current Stage is QDE; Next Stage != Credit -> Create BSR/ PSL
            */
            // Check for Pre-Approved Offer
            /*
            Boolean blnGoToPricing = false;
            AUSFPreApprovedCheckController.PreApprovedWrapper objPreApproved = AUSFPreApprovedCheckController.getLoanApplicationStage (loanAppObj.Id);
            if (objPreApproved.isPriceStage != NULL && objPreApproved.isPriceStage == true)
                blnGoToPricing = true;
            */
            String strCurrentStage = loanAppObj.Stage__c;
            // Changes Current Stage PSD conditions - SFAU-3804
            //Update Loan Application Stage stage - bug/US : SFAU-2669, SFAU-3099
            if(productType == 'Two Wheeler'){
                if(loanAppObj.Bre_Decision__c == 'STP' && (loanAppObj.Stage__c == 'QDE' || loanAppObj.Stage__c == 'PSD' || loanAppObj.Stage__c == 'Pricing')){
                    if(SubjectivityMsgTypeSet.contains('OPS')){
                        loanAppObj.Is_BRE_Ops_Subjectivity__c = true;
                    }
                    if(SubjectivityMsgTypeSet.contains('CREDIT')){
                        loanAppObj.stage__c = 'CREDIT';
                        loanAppObj.Is_BRE_Credit_Subjectivity__c = true;
                        blnBSRPSLCredit = true;
                    }
                    else if (isProcessingFeeDeviation){
                        loanAppObj.stage__c = 'Pricing';
                        loanAppObj.Is_BRE_Pricing_Deviations__c = true;
                        loanAppObj.Is_Charge_Changed__c = false;
                        blnCreateBSRPSL = true;
                    }
                    else {
                        blnCreateBSRPSL = true;
                        loanAppObj.stage__c = 'Pricing'; // Change from DDE
                        loanAppObj.Is_Charge_Changed__c = false;
                    }
                    if (SubjectivityMsgTypeSet.size()>0)
                        blnInsertSanctionRecords = true;
                }
                // START - Changes as per TW - Loan Current Stage - Credit and BRE Decistion
                else if(loanAppObj.Bre_Decision__c == 'NSTP' && (loanAppObj.Stage__c == 'QDE' || loanAppObj.Stage__c == 'PSD' || loanAppObj.Stage__c == 'Pricing')){
                    loanAppObj.stage__c = 'Credit';
                }
                else if((loanAppObj.Bre_Decision__c == 'STP') && loanAppObj.Stage__c == 'Credit'){
                    loanAppObj.stage__c = 'Pricing';
                    if(SubjectivityMsgTypeSet.contains('OPS')){
                        loanAppObj.Is_BRE_Ops_Subjectivity__c = true;
                    }
                    if(SubjectivityMsgTypeSet.contains('CREDIT')){
                        loanAppObj.stage__c = 'CREDIT';
                        loanAppObj.Is_BRE_Credit_Subjectivity__c = true;
                    }
                    loanAppObj.Is_Charge_Changed__c = loanAppObj.stage__c == 'Pricing' ? false : loanAppObj.Is_Charge_Changed__c;
                }
                else if((loanAppObj.Bre_Decision__c == 'NSTP') && loanAppObj.Stage__c == 'Credit'){
                    loanAppObj.stage__c = 'CREDIT';
                    // CUG -- Case gets stuck on Pricing when it was relooked
                    loanAppObj.Is_Being_Relooked__c = loanAppObj.Previous_Stage__c == GlobalConstants.REJECTED;
                }
                // END - Changes as per TW - Loan Current Stage - Credit and BRE Decistion
                else if(loanAppObj.Bre_Decision__c == 'NSTP' && loanAppObj.Stage__c == 'DDE'){
                    loanAppObj.stage__c = 'Credit';
                }
                else if(loanAppObj.Bre_Decision__c == 'STP' && loanAppObj.Stage__c == 'DDE' && loanAppObj.Is_Charge_Changed__c){
                    loanAppObj.Is_Charge_Changed__c = false;
                    loanAppObj.stage__c = 'Pricing';
                }
                else if(loanAppObj.Bre_Decision__c == 'STP' && loanAppObj.Stage__c == 'DDE'){
                    loanAppObj.stage__c = 'PSD';
                }
            }
            else if(productType == 'Four Wheeler' || productType == 'Commercial Vehicle' || productType == 'Tractor' || productType == 'Construction Equipment'){
                if(loanAppObj.Bre_Decision__c == 'STP' && loanAppObj.Stage__c == 'QDE'){
                    loanAppObj.stage__c = 'DDE';
                }
                else if(loanAppObj.Bre_Decision__c == 'NSTP' && loanAppObj.Stage__c == 'QDE'){
                    loanAppObj.stage__c = 'DDE';
                }
                else if(loanAppObj.Bre_Decision__c == 'STP' && (loanAppObj.Stage__c == 'DDE' || loanAppObj.Stage__c == 'Credit' || loanAppObj.Stage__c == 'Pricing' || loanAppObj.Stage__c == 'PSD')){
                    if(SubjectivityMsgTypeSet.contains('OPS')){
                        loanAppObj.Is_BRE_Ops_Subjectivity__c = true;
                    }
                    if(SubjectivityMsgTypeSet.contains('CREDIT')){
                        loanAppObj.stage__c = 'CREDIT';
                        loanAppObj.Is_BRE_Credit_Subjectivity__c = true;
                        blnCreateBSRPSL = true;
                        blnBSRPSLCredit = true;
                    }
                    else {
                        loanAppObj.stage__c = 'PRICING';
                        loanAppObj.Is_Charge_Changed__c = false;
                        blnCreateBSRPSL = true;
                    }
                    if (SubjectivityMsgTypeSet.size()>0)
                        blnInsertSanctionRecords = true;
                }
                else if(loanAppObj.Bre_Decision__c == 'NSTP' && (loanAppObj.Stage__c == 'DDE' || loanAppObj.Stage__c == 'Credit' || loanAppObj.Stage__c == 'Pricing' || loanAppObj.Stage__c == 'PSD')){
                    loanAppObj.stage__c = 'Credit';
                }

                //START - SFAU-5141
                loanAppObj.Customer_Grade__c = lstApplicant[0].Customer_Grade__c;
            }

            // SFAU-4063
            loanAppObj.BRE_Run_for_PreApproved_Offer__c = strCurrentStage == 'PSD' && loanAppObj.BRE_Run_for_PreApproved_Offer__c ? false : loanAppObj.BRE_Run_for_PreApproved_Offer__c;

            if (strCurrentStage == 'PSD' && strCurrentStage != loanAppObj.Stage__c && (loanAppObj.Sanction_Status__c == 'Cancellation In Progress' || loanAppObj.DO_Status__c == 'Cancellation In Progress')) {
                throw new CustomException(Label.BRE_Stage_Change_DO_And_Sanctioned_Cancel_Pending_Msg);
            }

            // Update Loan Application
            loanAppObj.BRE_ReRun_Required__c = false;
            loanAppObj.Send_Back_To_RO_Stage__c = '';
            loanAppObj.Is_ReWork__c = productType == 'Two Wheeler' ? loanAppObj.Is_ReWork__c : false;
            // SFAU-4473 - Neha
            loanAppObj.is_Pricing_Required__c = false;
            /**SFAU-5264 Chnages */
            loanAppObj.Is_DO_Sanction_Regenerate_Required__c = (loanAppObj.DO_Status__c == 'Issued' || loanAppObj.Sanction_Status__c == 'Issued');

            /******************** */

            update loanAppObj;
            
            // Create BSR Assignments
            if (loanAppObj.Is_BRE_Credit_Subjectivity__c) {
                system.debug(LoggingLevel.Info,'Create BSR Assignments');
                List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c>();
                lstLoanApplication.add(loanAppObj);
                Utility.createBSRAssignment(lstLoanApplication, blnBSRPSLCredit);
            }
            
            // Insert Sanction Condition Records
            if (blnInsertSanctionRecords && lstSanctionCondition.size()>0) {
                insert lstSanctionCondition;
            }
            if(strCurrentStage == 'DDE' || strCurrentStage == 'Credit' ){
            Bre_Response__c breResponseObj = new Bre_response__c();
            breResponseObj.Id = breResponseId;
            breResponseObj.Is_Confirmed__c = true;
            update breResponseObj;
            }
            
            objUpdateScreen.blnSuccess = true;
            objUpdateScreen.strMessage = 'Scheme has been updated.';
        }
        catch (Exception ex) {
            Database.rollback(sp);
            Log.error('BREOutputScreenConteroller :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppObj.Id);
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                objUpdateScreen.strMessage = ex.getMessage().substringBetween(',',':');
            }
            else{
                objUpdateScreen.strMessage = ex.getMessage();
            }
        }
        return objUpdateScreen;
    }
    
    
    public static String getBreResponseWithLabels(String jsonString) {
        Map<String, String> labelMap = new Map<String, String>();
        Map<String, BRE_Output_Screen_Labels__mdt > mapKeysWithLabels = BRE_Output_Screen_Labels__mdt.getAll();
        for(String key : mapKeysWithLabels.keySet()){
            System.debug('----->'+mapKeysWithLabels.get(key).Label__c);
            labelMap.put(key, mapKeysWithLabels.get(key).Label__c);
        }
        
        system.debug('mapKeysWithLabels'+mapKeysWithLabels);
        // Deserialize the JSON string into a Map<String, Object>
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        return replaceKeysWithMetadataLabels(jsonMap, labelMap, mapKeysWithLabels);
        
    }
    
    public static String getBreResponseWithKeys(String jsonString){
        Map<String, String> labelMap = new Map<String, String>();
        Map<String, BRE_Output_Screen_Labels__mdt > mapKeysWithLabels = BRE_Output_Screen_Labels__mdt.getAll();
        for(String key : mapKeysWithLabels.keySet()){
            System.debug('----->'+mapKeysWithLabels.get(key).Label__c);
            labelMap.put(mapKeysWithLabels.get(key).Label__c, key);
        }
        
        
        system.debug('mapKeysWithLabels'+mapKeysWithLabels);
        // Deserialize the JSON string into a Map<String, Object>
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        return replaceKeysWithMetadataLabels(jsonMap, labelMap, mapKeysWithLabels);
        
        
    }
    
    private static String replaceKeysWithMetadataLabels(Map<String, Object> jsonMap, Map<String, String> metadataMap, Map<String, BRE_Output_Screen_Labels__mdt> mapKeysWithLabels) {
        for (String key : jsonMap.keySet()) {
            if (metadataMap.containsKey(key)) {
                if (mapKeysWithLabels.containsKey(key) && mapKeysWithLabels.get(key).Is_Active__c == false) {
                    jsonMap.remove(key);
                    continue;
                }
                String label = metadataMap.get(key);
                jsonMap.put(label, jsonMap.get(key));
                jsonMap.remove(key);
            }
        }
        for (Object value : jsonMap.values()) {
            if (value instanceof Map<String, Object>) {
                replaceKeysWithMetadataLabels((Map<String, Object>) value, metadataMap, mapKeysWithLabels);
            } else if (value instanceof List<Object>) {
                replaceKeysWithMetadataLabels((List<Object>) value, metadataMap, mapKeysWithLabels);
            }
        }
        return JSON.serialize(jsonMap);
    }
    
    private static void replaceKeysWithMetadataLabels(List<Object> jsonList, Map<String, String> metadataMap, Map<String, BRE_Output_Screen_Labels__mdt> mapKeysWithLabels) {
        for (Object value : jsonList) {
            if (value instanceof Map<String, Object>) {
                replaceKeysWithMetadataLabels((Map<String, Object>) value, metadataMap, mapKeysWithLabels);
            } else if (value instanceof List<Object>) {
                replaceKeysWithMetadataLabels((List<Object>) value, metadataMap, mapKeysWithLabels);
            }
        }
    }
    
    
    /*****
* BRE Output Wrapper Class
*/
    public class BreOutputScreenControllerWrapper{
        @AuraEnabled
        public BRE_Response__c breResponse;
        @AuraEnabled
        public String strBreResponse;
        @AuraEnabled
        public String breStatus;
        @AuraEnabled
        public String loanAppId;
        @AuraEnabled
        public String schemeCode;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public Boolean blnBREError = false;
        @AuraEnabled
        public Boolean blnBRESuccess = false;
        @AuraEnabled
        public Boolean hasShowCriteriaPermission = false;
        @AuraEnabled
        public String strROSelectedSchemeId = '';
        @AuraEnabled
        public Boolean isCreditManager = false;
    }
    
    /*****
* BRE Update Wrapper Class
*/
    public class BREOutputUpdate{
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage = '';
    }
    
    public class CustomException extends Exception{}
}