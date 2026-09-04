/*
@Name: FieldInvestigationUtility
@Test Class:
@Description: Field Investigation Utility Class to create FI records, Query FI Agents from Master
@Logs
    Last Modified By        :       Last Modified Date      :       Bug/US/Description
    Mohit M.                :       June-06-2023            :       method - getZipCodeWithAssignFIAgent - query FI Agents from Master based on Loan Record Type
    Mohit M.                :       June-22-2023            :       SFAU-3365 - method - rebuild methid createFISummary - as logic was not working as expected
    Mohit M.                :       June-27-2023            :       SFAU-3465 And SFAU-2801 - method - rebuild methid createFISummary - When FI Not Triggered update 'Not Applicable'
    Mohit M.                :       Oct-19-2023             :       SFAU-5433 - Add Filter of 'Field Investigator Profile'
	Yash S.                 :       Oct-31-2023             :       SFAU-5459 - Reject Handle of Loan Application
    Yash S.                 :       Dec-18-2023             :       SFAU-5751 - To retrieve the CM based on Product
 */
public without sharing class FieldInvestigationUtility {
    /**
    * @description       : This method is for the summary view of Field Investigation on Loan Application or Applicant
    * @author            : Vikas Singhal | Salesforce
    * @last modified on  : Jan-20-2023
    **/
    public static List<FISummaryViewWrapper> getFISummary(String loanApplicationId, String applicantId){
        try {
            // Create Set of Applicant RecordTypeId
            Set<Id> setRecordTypeId = new Set<Id>();
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.APPLICANT));
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.COAPPLICANT));
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.GUARANTOR));
            // Query on FI records
            List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
            FieldInvestigationService.setRecordTypeId = setRecordTypeId;
            String strQuery = '';
            // START - SFAU-3365
            if (loanApplicationId != '') {
                strQuery = 'SELECT Id, RecordType.Name, Customer_Name__c, Loan__r.Name, First_Name__c, Middle_Name__c, Last_Name__c, ';
                strQuery = strQuery + '(SELECT ';
                strQuery = strQuery + 'Id,FI_Officer_Name_EMP_code_Agency_Name__c,Waive_Off_Reason__c , FI_Office_Name_Code_Agency_Name_Formula__c ,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c ';
                strQuery = strQuery + 'FROM Field_Investigations__r where Re_Trigger__c = false AND Applicant__r.IsInactive__c = false )';
                strQuery = strQuery + 'FROM Applicant__c ';
                strQuery = strQuery + 'WHERE RecordTypeId in: setRecordTypeId AND Loan__c = \'' + loanApplicationId + '\' AND IsInactive__c = false ';
            }
            else {
                strQuery = 'SELECT Id, RecordType.Name, Customer_Name__c, Loan__r.Name, First_Name__c, Middle_Name__c, Last_Name__c, ';
                strQuery = strQuery + '(SELECT ';
                strQuery = strQuery + 'Id,FI_Officer_Name_EMP_code_Agency_Name__c,Waive_Off_Reason__c , FI_Office_Name_Code_Agency_Name_Formula__c ,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c ';
                strQuery = strQuery + 'FROM Field_Investigations__r where Re_Trigger__c = false AND Applicant__r.IsInactive__c = false ) ';
                strQuery = strQuery + 'FROM Applicant__c ';
                strQuery = strQuery + 'WHERE RecordTypeId in: setRecordTypeId AND Id = \'' + applicantId + '\' AND IsInactive__c = false ';
            }
            // END - SFAU-3365
            system.debug(LoggingLevel.Info,'Query ... ' + strQuery);
            List<Applicant__c> recordsList = Database.query(strQuery);
            system.debug(LoggingLevel.Info,'recordsList ... ' + recordsList.size());

            //List<Field_Investigation__c> recordsList =  FieldInvestigationService.getFieldInvestigationRecords(strWhereClause);
            // Create Wrapper for Summary
            system.debug('record length '+recordsList.size());
            Map<String,FiSummaryViewWrapper> mapSummary  = createFISummary(recordsList);
            return mapSummary.values();
        } catch (Exception ex) {
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            system.debug('Exception>>>>'+ex.getMessage()+'  line number>>>'+ex.getLineNumber());
            throw new CustomException(ex);
        }
    }

    

    /*
    @ descrition : createFISummary - Create FI Summary Table - Change as per SFAU-3365
    @ param1 : recordsList
    @ return : Map of FiSummaryViewWrapper
    */
    public static Map<String,FiSummaryViewWrapper> createFISummary (List<Applicant__c> recordsList){
        // Create Wrapper for Summary
        Map<String,FiSummaryViewWrapper> mapSummary  = new Map<String,FiSummaryViewWrapper>();
        try{
            //Select Id, Applicant__c, Applicant__r.RecordType.Name, Address_lookup__r.Address_Type__c, Stage__c, FI_Status__c from Field_Investigation__c where Applicant__r.Loan__c = 'a2b710000008VUsAAM' group by Applicant__c, applicant__r.RecordType.name, Address_lookup__r.Address_Type__c, Stage__c, FI_Status__c order by applicant__r.RecordType.name
            Boolean blnFinalNegative = false;
            Boolean blnFinalInProgress = false;
            Integer intCounter = 0;
            Integer intAllPositive = 0;
            Integer intAllWaivedOff = 0;
            Integer intAllCancelled = 0;
            Integer intAllStageNew = 0;
            Integer ingAllAssigned = 0;
            

            Set<String> setForPositive = new Set<String>();
            setForPositive.add(Label.FI_Status_Positive.toUpperCase());
            setForPositive.add(Label.FI_Stage_Waived_Off.toUpperCase());
            setForPositive.add(Label.FI_Status_Cancelled.toUpperCase());

            Set<String> setForAssigned = new Set<String>();
            //setForAssigned.add(Label.FI_Status_Positive);
            setForAssigned.add(Label.FI_Stage_Assigned.toUpperCase());
            

            Set<String> setForNewStage = new Set<String>();
            
            setForNewStage.add(Label.FI_Summary_New_Stage.toUpperCase());


            Set<String> setForCancelled = new Set<String>();
            //setForCancelled.add(Label.FI_Stage_Waived_Off);
            setForCancelled.add(Label.FI_Status_Cancelled.toUpperCase());

            Set<String> setForWaivedOff = new Set<String>();
            setForWaivedOff.add(Label.FI_Stage_Waived_Off.toUpperCase());
            setForWaivedOff.add(Label.FI_Status_Cancelled.toUpperCase());
            Boolean blnFINotExist = true;
            for (Applicant__c objApplicant : recordsList) {
                String finalStatus = '';
                FiSummaryViewWrapper objSummary = new FiSummaryViewWrapper();
                FiSummaryViewWrapper objSummaryFinal = new FiSummaryViewWrapper();
                objSummary.entity = objApplicant.RecordType.Name;
                objSummary.partyName = objApplicant.Customer_Name__c;
                Boolean blnCurrentWaivedOff = true;
                Boolean blnPermanentWaivedOff = true;
                Boolean blnTPWaivedOff = true;
                Boolean blnOfficeWaivedOff = true;
                Boolean blnApplicantLeveInNegative = false;
                Boolean blnApplicantLeveInProgress = false;
                if(objApplicant.Middle_Name__c!=null){
                    objSummary.applicantName = objApplicant.First_Name__c+' '+objApplicant.Middle_Name__c+' '+objApplicant.Last_Name__c;
                }else{
                    objSummary.applicantName = objApplicant.First_Name__c+' '+objApplicant.Last_Name__c;
                }
                if (objApplicant.Field_Investigations__r != NULL && objApplicant.Field_Investigations__r.size() > 0) {
                    for (Field_Investigation__c objFI : objApplicant.Field_Investigations__r) {
                        blnFINotExist = false;
                        objSummary.fiRecordId = objFI.Id;
                        objSummary.fiReportLink = '/apex/FIPrintReportPage?recId='+objFI.Id;
                        objSummary.waivedOffReason = (String.isNotBlank(objFI.Waive_Off_Reason__c ))?objFI.Waive_Off_Reason__c:'';
                        // Added for SUmmary Page By Yash
                        if(objFI.Applicant__r.Middle_Name__c!=null){
                            objSummary.applicantName = objFI.Applicant__r.First_Name__c+' '+objFI.Applicant__r.Middle_Name__c+' '+objFI.Applicant__r.Last_Name__c;
                        }else{
                            objSummary.applicantName = objFI.Applicant__r.First_Name__c+' '+objFI.Applicant__r.Last_Name__c;
                        }
                        objFI.FI_Status__c = String.isEmpty(objFI.FI_Status__c) ? '' : objFI.FI_Status__c;
                        objFI.Stage__c = String.isEmpty(objFI.Stage__c) ? '' : objFI.Stage__c;
                        if(objFI.Type_of_address__c ==GlobalConstants.CURRENT){
                            blnCurrentWaivedOff = false;
                            objSummary.currentAddress = objFI.FI_Status__c != '' ? objFI.FI_Status__c : (objFI.Stage__c == 'New' ? Label.FI_Summary_New_Stage : objFI.Stage__c);
                            objSummary.reportLinkForCurrentAddress = '/apex/FIPrintReportPage?recId='+objFI.Id;
                            objSummary.currentAddressAgency = (objFI.Stage__c != 'Waived off')?objFI.FI_Office_Name_Code_Agency_Name_Formula__c:'';
                        }
                        else if(objFI.Type_of_address__c ==GlobalConstants.PERMANENT){
                            blnPermanentWaivedOff = false;
                            objSummary.permanentAddress = objFI.FI_Status__c != '' ? objFI.FI_Status__c : (objFI.Stage__c == 'New' ? Label.FI_Summary_New_Stage : objFI.Stage__c);
                            objSummary.reportLinkForPermanentAddress = '/apex/FIPrintReportPage?recId='+objFI.Id;
                            objSummary.permanentAddressAgency = (objFI.Stage__c != 'Waived off')?objFI.FI_Office_Name_Code_Agency_Name_Formula__c:'';

                        }
                        else if(objFI.Type_of_address__c ==GlobalConstants.OFFICE){
                            blnOfficeWaivedOff = false;
                            objSummary.officeAddress = objFI.FI_Status__c != '' ? objFI.FI_Status__c : (objFI.Stage__c == 'New' ? Label.FI_Summary_New_Stage : objFI.Stage__c);
                            objSummary.reportLinkForOfficeAddress = '/apex/FIPrintReportPage?recId='+objFI.Id;
                            objSummary.officeAddressAgency = (objFI.Stage__c != 'Waived off')?objFI.FI_Office_Name_Code_Agency_Name_Formula__c:'';
                        }
                        else if(objFI.Type_of_address__c ==GlobalConstants.TOUCHPOINT){
                            blnTPWaivedOff = false;
                            objSummary.tpAddress =  objFI.FI_Status__c != '' ? objFI.FI_Status__c : (objFI.Stage__c == 'New' ? Label.FI_Summary_New_Stage : objFI.Stage__c);
                            //objSummary.tpAddress = objFI.FI_Status__c != '' ? objFI.FI_Status__c : objFI.Stage__c != Label.FI_Stage_Closed ? Label.FI_Stage_In_Progress  : Label.FI_Stage_NA ;
                            objSummary.reportLinkForTPAddress = '/apex/FIPrintReportPage?recId='+objFI.Id;
                            objSummary.tpAddressAgency = (objFI.Stage__c != 'Waived off')?objFI.FI_Office_Name_Code_Agency_Name_Formula__c:'';
                        }
                        if (!blnApplicantLeveInNegative && objFI.FI_Status__c == 'Negative') {
                            SYSTEM.debug('negative '+objFI);
                            blnApplicantLeveInNegative = true;
                            objSummary.finalStatus = Label.FI_Status_Negative;
                            blnFinalNegative = true;
                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Stage_In_Progress || objSummary.permanentAddress == Label.FI_Stage_In_Progress || objSummary.officeAddress == Label.FI_Stage_In_Progress || objSummary.tpAddress == Label.FI_Stage_In_Progress)){
                            objSummary.finalStatus = Label.FI_Stage_In_Progress;
                            blnApplicantLeveInProgress = true;
                            blnFinalInProgress = true;
                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Stage_Waived_Off && objSummary.permanentAddress == Label.FI_Stage_Waived_Off && objSummary.officeAddress == Label.FI_Stage_Waived_Off && objSummary.tpAddress == Label.FI_Stage_Waived_Off)){
                            objSummary.finalStatus = Label.FI_Stage_Waived_Off;
                            intAllWaivedOff++;
                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Stage_Assigned && objSummary.permanentAddress == Label.FI_Stage_Assigned && objSummary.officeAddress == Label.FI_Stage_Assigned && objSummary.tpAddress == Label.FI_Stage_Assigned)){
                            objSummary.finalStatus = Label.FI_Stage_Assigned;
                            ingAllAssigned++;
                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Summary_New_Stage && objSummary.permanentAddress == Label.FI_Summary_New_Stage && objSummary.officeAddress == Label.FI_Summary_New_Stage && objSummary.tpAddress == Label.FI_Summary_New_Stage)){
                            objSummary.finalStatus = Label.FI_Summary_New_Stage;
                            intAllStageNew++;
                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Status_Cancelled && objSummary.permanentAddress == Label.FI_Status_Cancelled && objSummary.officeAddress == Label.FI_Status_Cancelled && objSummary.tpAddress == Label.FI_Status_Cancelled)){
                            objSummary.finalStatus = Label.FI_Status_Cancelled;
                            intAllCancelled++;

                        }
                        else if (!blnApplicantLeveInNegative && !blnApplicantLeveInProgress && (objSummary.currentAddress == Label.FI_Status_Positive && objSummary.permanentAddress == Label.FI_Status_Positive && objSummary.officeAddress == Label.FI_Status_Positive && objSummary.tpAddress == Label.FI_Status_Positive)){
                            objSummary.finalStatus = Label.FI_Status_Positive;
                            intAllPositive++;
                        }
                    }
                }
                system.debug(LoggingLevel.Info,'intCounter and ' + recordsList.size());
                system.debug(LoggingLevel.Info,'setForAssigned and ' + setForAssigned);
                system.debug(LoggingLevel.Info,'objSummary.currentAddress and ' + objSummary.currentAddress);
                system.debug(LoggingLevel.Info,'intCounter and ' + recordsList.size());
                if (intCounter != recordsList.size()){
                    //objSummary.currentAddress = blnCurrentWaivedOff ? Label.FI_Stage_NA : objSummary.currentAddress;
                    objSummary.currentAddress = blnCurrentWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.currentAddress;

                    objSummary.bkcurrentAddress = blnCurrentWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.currentAddress;

                    //objSummary.permanentAddress = blnPermanentWaivedOff ? Label.FI_Stage_NA : objSummary.permanentAddress;
                    objSummary.permanentAddress = blnPermanentWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.permanentAddress;

                    objSummary.bkpermanentAddress = blnPermanentWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.permanentAddress;

                    //objSummary.officeAddress = blnOfficeWaivedOff ? Label.FI_Stage_NA : objSummary.officeAddress;
                    objSummary.officeAddress = blnOfficeWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.officeAddress;

                    objSummary.bkofficeAddress = blnOfficeWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.officeAddress;

                    //objSummary.tpAddress = blnTPWaivedOff ? Label.FI_Stage_NA : objSummary.tpAddress;
                    objSummary.tpAddress = blnTPWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.tpAddress;

                    objSummary.bktpAddress = blnTPWaivedOff ? Label.FI_Stage_Waived_Off : objSummary.tpAddress;
                    system.debug(LoggingLevel.Info,'objSummary --- ' + objSummary);
                    if (objSummary.bkcurrentAddress == Label.FI_Stage_Waived_Off && objSummary.bkpermanentAddress == Label.FI_Stage_Waived_Off && objSummary.bkofficeAddress == Label.FI_Stage_Waived_Off && objSummary.bktpAddress == Label.FI_Stage_Waived_Off) {
                        objSummary.finalStatus = Label.FI_Stage_Waived_Off;
                    }
                    else if ((objSummary.bktpAddress == Label.FI_Summary_New_Stage ||
                        objSummary.bkpermanentAddress == Label.FI_Summary_New_Stage ||
                        objSummary.bkcurrentAddress == Label.FI_Summary_New_Stage ||
                        objSummary.bkofficeAddress == Label.FI_Summary_New_Stage) &&
                        !blnApplicantLeveInNegative && !blnApplicantLeveInProgress &&
                        (setForNewStage.contains(objSummary.bktpAddress.toUpperCase()) ||
                        setForNewStage.contains(objSummary.bkpermanentAddress.toUpperCase()) ||
                        setForNewStage.contains(objSummary.bkcurrentAddress.toUpperCase()) ||
                        setForNewStage.contains(objSummary.bkofficeAddress.toUpperCase()))) {
                            objSummary.finalStatus = Label.FI_Summary_New_Stage;
                    }
                    
                    else if ((objSummary.bktpAddress == Label.FI_Stage_Assigned ||
                        objSummary.bkpermanentAddress == Label.FI_Stage_Assigned ||
                        objSummary.bkcurrentAddress == Label.FI_Stage_Assigned ||
                        objSummary.bkofficeAddress == Label.FI_Stage_Assigned) &&
                        !blnApplicantLeveInNegative && !blnApplicantLeveInProgress &&
                        (setForAssigned.contains(objSummary.bktpAddress.toUpperCase()) ||
                        setForAssigned.contains(objSummary.bkpermanentAddress.toUpperCase()) ||
                        setForAssigned.contains(objSummary.bkcurrentAddress.toUpperCase()) ||
                        setForAssigned.contains(objSummary.bkofficeAddress.toUpperCase()))) {
                            objSummary.finalStatus = Label.FI_Stage_Assigned;
                    }
                    
                    else if ((objSummary.bktpAddress == Label.FI_Status_Cancelled ||
                        objSummary.bkpermanentAddress == Label.FI_Status_Cancelled ||
                        objSummary.bkcurrentAddress == Label.FI_Status_Cancelled ||
                        objSummary.bkofficeAddress == Label.FI_Status_Cancelled) &&
                        !blnApplicantLeveInNegative && !blnApplicantLeveInProgress &&
                        setForCancelled.contains(objSummary.bktpAddress.toUpperCase()) &&
                        setForCancelled.contains(objSummary.bkpermanentAddress.toUpperCase()) &&
                        setForCancelled.contains(objSummary.bkcurrentAddress.toUpperCase()) &&
                        setForCancelled.contains(objSummary.bkofficeAddress.toUpperCase())) {
                            objSummary.finalStatus = Label.FI_Status_Cancelled;
                    }
                    
                    else if ((objSummary.bktpAddress == Label.FI_Status_Positive ||
                        objSummary.bkpermanentAddress == Label.FI_Status_Positive ||
                        objSummary.bkcurrentAddress == Label.FI_Status_Positive ||
                        objSummary.bkofficeAddress == Label.FI_Status_Positive) &&
                        !blnApplicantLeveInNegative && !blnApplicantLeveInProgress &&
                        setForPositive.contains(objSummary.bktpAddress.toUpperCase()) &&
                        setForPositive.contains(objSummary.bkpermanentAddress.toUpperCase()) &&
                        setForPositive.contains(objSummary.bkcurrentAddress.toUpperCase()) &&
                        setForPositive.contains(objSummary.bkofficeAddress.toUpperCase())) {
                            objSummary.finalStatus = Label.FI_Status_Positive;
                        
                    }
                    else if ((objSummary.bktpAddress == Label.FI_Stage_Waived_Off ||
                        objSummary.bkpermanentAddress == Label.FI_Stage_Waived_Off ||
                        objSummary.bkcurrentAddress == Label.FI_Stage_Waived_Off ||
                        objSummary.bkofficeAddress == Label.FI_Stage_Waived_Off) &&
                        !blnApplicantLeveInNegative && !blnApplicantLeveInProgress &&
                        setForWaivedOff.contains(objSummary.bktpAddress.toUpperCase()) &&
                        setForWaivedOff.contains(objSummary.bkpermanentAddress.toUpperCase()) &&
                        setForWaivedOff.contains(objSummary.bkcurrentAddress.toUpperCase()) &&
                        setForWaivedOff.contains(objSummary.bkofficeAddress.toUpperCase())) {
                            objSummary.finalStatus = Label.FI_Stage_Waived_Off;
                    }
                    
                }
                intCounter++;
                mapSummary.put(objApplicant.Id,objSummary);
                if ((blnFINotExist && intCounter == recordsList.size()) || (intCounter == recordsList.size())) {

                    objSummaryFinal.entity = '';
                    objSummaryFinal.partyName = '';
                    objSummaryFinal.currentAddress = '';
                    objSummaryFinal.permanentAddress = '';
                    objSummaryFinal.officeAddress = '';
                    objSummaryFinal.tpAddress = Label.FI_Summary_Final_Status_Label;
                    objSummaryFinal.finalStatus = '';
                    system.debug(LoggingLevel.Info,'ingAllAssigned ' + ingAllAssigned + ' intAllStageNew ' + intAllStageNew + ' intAllCancelled ' + ' intAllWaivedOff ' + intAllWaivedOff + ' intAllPositive  ' + intAllPositive);
                    if (blnFINotExist) {
                        objSummaryFinal.finalStatus = Label.FI_Stage_Waived_Off;
                    }
                    else if (ingAllAssigned == intCounter) {
                        objSummaryFinal.finalStatus = Label.FI_Stage_Assigned;
                    }
                    else if (intAllStageNew == intCounter) {
                        objSummaryFinal.finalStatus = Label.FI_Summary_New_Stage;
                    }
                    else if (intAllCancelled == intCounter) {
                        objSummaryFinal.finalStatus = Label.FI_Status_Cancelled;
                    }
                    else if (intAllWaivedOff == intCounter) {
                        objSummaryFinal.finalStatus = Label.FI_Stage_Waived_Off;
                    }
                    else if (intAllPositive == intCounter) {
                        objSummaryFinal.finalStatus = Label.FI_Status_Positive;
                    }
                    else if (blnFinalNegative || blnFinalInProgress) {
                        objSummaryFinal.finalStatus = blnFinalNegative ? Label.FI_Status_Negative : Label.FI_Stage_In_Progress;
                    }
                    else {
                        Integer intSummaryCounter = 0;
                        for (FISummaryViewWrapper mapVal : mapSummary.values()) {
                            intSummaryCounter ++;
                            if (mapVal.finalStatus == Label.FI_Summary_New_Stage) {
                                objSummaryFinal.finalStatus = Label.FI_Summary_New_Stage;
                                break;
                            }
                            else if (mapVal.finalStatus == Label.FI_Stage_Assigned) {
                                objSummaryFinal.finalStatus = Label.FI_Stage_Assigned;
                                break;
                            }
                            else if (mapVal.finalStatus == Label.FI_Status_Cancelled && ((String.isNotBlank(objSummaryFinal.finalStatus) && setForCancelled.contains(objSummaryFinal.finalStatus.toUpperCase())) || (mapSummary.size() == intSummaryCounter && String.isEmpty(objSummaryFinal.finalStatus)))) {
                                objSummaryFinal.finalStatus = Label.FI_Status_Cancelled;
                            }
                            else if (mapVal.finalStatus == Label.FI_Stage_Waived_Off && (objSummaryFinal.finalStatus == mapVal.finalStatus || (mapSummary.size() == intSummaryCounter && String.isEmpty(objSummaryFinal.finalStatus)))) {
                                objSummaryFinal.finalStatus = Label.FI_Stage_Waived_Off;
                            }
                            else if (mapVal.finalStatus == Label.FI_Status_Positive && (objSummaryFinal.finalStatus == mapVal.finalStatus || (mapSummary.size() == intSummaryCounter && String.isEmpty(objSummaryFinal.finalStatus)) || (String.isNotBlank(mapVal.finalStatus) && setForPositive.contains(mapVal.finalStatus)))) {
                                objSummaryFinal.finalStatus = Label.FI_Status_Positive;
                            }
                        }
                    }
                    mapSummary.put('',objSummaryFinal);
                }

            }
        }
        catch (Exception ex) {
            system.debug('Exception>>>>'+ex.getMessage()+ '  line number>>>'+ex.getLineNumber());
            throw new CustomException(ex);
        }
        return mapSummary;
    }

    /**
    * @description       : To create Fi Records
    * @author            : Vikas Singhal | Salesforce
    * @last modified on  : Jan-20-2023
    **/
    public static  Field_Investigation__c createFiRecord(Address__c addressObject ,Collateral__c  collateralObj,Map<String,String> applicantIdVsBussinessNameMap){
        try {
            Id applicantRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Field_Investigation__c'),GlobalConstants.APPLICANT);
            Id coApplicantRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Field_Investigation__c'),GlobalConstants.COAPPLICANT);
            Id guarantorRecordTypeId = Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Field_Investigation__c'),GlobalConstants.GUARANTOR);
            Field_Investigation__c fieldInvestigationObj = new Field_Investigation__c();
            fieldInvestigationObj.Name = String.isNotBlank(addressObject.Applicant__r.Customer_Name__c) ? addressObject.Applicant__r.Customer_Name__c : 'FI-'+addressObject.Applicant__r.Name;
            fieldInvestigationObj.Loan_Application__c =addressObject.Applicant__r.Loan__c;
            fieldInvestigationObj.Name_of_Party__c =addressObject.Applicant__r.Customer_Name__c;
            fieldInvestigationObj.Address_lookup__c=addressObject.Id;
            fieldInvestigationObj.DOB__c =addressObject.Applicant__r.DOB__c;
            fieldInvestigationObj.Gender__c =addressObject.Applicant__r.Gender__c;
            fieldInvestigationObj.Father_Husband_Name__c =addressObject.Applicant__r.Father_Name__c;
            fieldInvestigationObj.Mobile_No__c =addressObject.Applicant__r.Mobile_Number__c;
            fieldInvestigationObj.Applicant__c=addressObject.Applicant__c;
            fieldInvestigationObj.Branch_Name__c=addressObject.Applicant__r.Loan__r.Branch_Master__c;
            fieldInvestigationObj.Loan_Application_Rec_Type__c = addressObject.Applicant__r.Loan__r.RecordType.DeveloperName;//Newly added fie
            fieldInvestigationObj.Branch_Name_Code__c =addressObject.Applicant__r.Loan__r.Branch_Master__r.Account_Code__c;
            //  if(collateralObj != null){
            //   fieldInvestigationObj.Proposed_vehicle__c =collateralObj.Variant__c;
            fieldInvestigationObj.Proposed_vehicle__c =  addressObject.Applicant__r.Loan__r.Product__c;
            //}
            fieldInvestigationObj.Loan_Amount__c =addressObject.Applicant__r.Loan__r.Loan_Amount__c;
            //fieldInvestigationObj.Loan_Type__c = addressObject.Applicant__r.Customer_Type__c;
            String strLoanType = addressObject.Applicant__r.Loan__r.Product__c.substringBetween('(',')');
            fieldInvestigationObj.Loan_Type__c = strLoanType;
            fieldInvestigationObj.Type_of_address__c =addressObject.Address_Type__c;
            fieldInvestigationObj.Allocated_Address__c =addressObject.Address_Type__c;
            fieldInvestigationObj.Pin_Code__c =addressObject.Pincode__c;
            fieldInvestigationObj.Applicant_Type__c=addressObject.Applicant__r.RecordType.Name;
            String fullAddress = '';
            if(!String.isEmpty(addressObject.Address_Line_1__c)){
                fullAddress=addressObject.Address_Line_1__c;
            }
            if(!String.isEmpty(addressObject.Address_Line_2__c)){
                fullAddress+='%';
                fullAddress+=addressObject.Address_Line_2__c;
            }
            if(!String.isEmpty(addressObject.Address_Line_3__c)){
                fullAddress+='%';
                fullAddress+=addressObject.Address_Line_3__c;
            }
            if(!String.isEmpty(addressObject.City__c)){
                fullAddress+='%';
                fullAddress+=addressObject.City__c;
            }
            if(!String.isEmpty(addressObject.State__c)){
                fullAddress+='%';
                fullAddress+=addressObject.State__c;
            }
            if(!String.isEmpty(addressObject.District__c)){
                fullAddress+='%';
                fullAddress+=addressObject.District__c;
            }
            if(!String.isEmpty(addressObject.Pincode__c)){
                fullAddress+='%';
                fullAddress+=addressObject.Pincode__c;
            }
            fullAddress = fullAddress.replaceAll('%',', ');
            fieldInvestigationObj.Full_Allocated_Address__c= fullAddress;
            fieldInvestigationObj.Company_Name__c =applicantIdVsBussinessNameMap.get(addressObject.Applicant__c);
            fieldInvestigationObj.Business_Name__c =applicantIdVsBussinessNameMap.get(addressObject.Applicant__c);
            fieldInvestigationObj.Area_Name__c =addressObject.Area_Name__c;
            fieldInvestigationObj.Date_of_Establishment__c=addressObject.Applicant__r.Date_of_Establishment__c;
            fieldInvestigationObj.Key_Contact_Name__c=addressObject.Applicant__r.Key_Contact_Name__c;
            return fieldInvestigationObj;
        } catch (Exception e) {
            system.debug('Exception>>>>'+e.getMessage()+'  line number>>>'+e.getLineNumber());
            throw new CustomException(e);
        }
    }

    /**
    * @description       : This method is to match address based
    * @author            : Vikas Singhal | Salesforce
    * @last modified on  : Jan-20-2023
    **/
    public static Boolean matchAddress(Address__c addressObject ,Address__c addressMapObject){
        try {
            if(addressObject.Address_Line_1__c == addressMapObject.Address_Line_1__c &&
                addressObject.Address_Line_2__c == addressMapObject.Address_Line_2__c &&
                addressObject.Address_Line_3__c == addressMapObject.Address_Line_3__c &&
                addressObject.State__c == addressMapObject.State__c &&
                addressObject.District__c == addressMapObject.District__c
                && addressObject.Pincode__c == addressMapObject.Pincode__c)
            {
                return true;
            }

            return false;
        } catch (Exception e) {
            system.debug('Exception>>>>'+e.getMessage()+'  line number>>>'+e.getLineNumber());
            throw new CustomException(e);
        }
    }

    

    /*
    * method getZipCodeWithAssignUserCreditManager
    * param1: strObjectName - Object API name to assign ownershit
    * param2: strRoleName - ATM Role Name
    * param3: strAssignToField - Record OwnerId
    * param4: setAccountId - Set of Loan Applicantion Branch Ids
    * param5: isRoundRobin - Boolean - RoundRobin Required or Not (always true)
    * param6: productCode - String - Product Code to retrieve on the basis of Product 5751
    */
    public static Map<String,Id> getZipCodeWithAssignUserCreditManager(String strObjectName, String strRoleName, String strAssignToField, Set<String> setAccountId, Boolean isRoundRobin, String productCode){
        // Map of zipcode with userId
        //
        Map<String,String> branchCodeWithCreditMap = new Map<String,String>();
        List<AccountTeamMember> lstAccountTeamMember = new List<AccountTeamMember>();
        String productValue = '(\'' + productCode + '\')';

        AccountTeamMemberService.userDesignation = strRoleName;
        AccountTeamMemberService.setAccountId = setAccountId;
        String strWhereClause = ' WHERE TeamMemberRole =: userDesignation AND Account.Account_Code__c in: setAccountId AND Active__c = true AND Product__c INCLUDES '+productValue;// New Query Parameter added
        //strWhereClause = strWhereClause + (strRoleName == Label.AccountTeamMemberRole_Credit ? ' AND Approver_Level__c IN (\'L1\')' : '');
        system.debug('recordsList>>>>>'+lstAccountTeamMember.size());
        lstAccountTeamMember =  AccountTeamMemberService.getAccountTeamMember(strWhereClause);
        system.debug('recordsList>>>>>'+lstAccountTeamMember.size());
        Map<String, CMAccountTeamWrapper> accountCodeBaseCMApproverMap = setBaseCMApproverMap(lstAccountTeamMember);
        for (AccountTeamMember objATM : lstAccountTeamMember) {
            if (objATM.Account.Account_Code__c != NULL && setAccountId.contains(objATM.Account.Account_Code__c)) {
                if(accountCodeBaseCMApproverMap.containsKey(objATM.Account.Account_Code__c)){
                    branchCodeWithCreditMap.put(objATM.Account.Account_Code__c,accountCodeBaseCMApproverMap.get(objATM.Account.Account_Code__c).userId);
                }
                else{
                    branchCodeWithCreditMap.put(objATM.Account.Account_Code__c,objATM.UserId);
                }

            }
        }
        return branchCodeWithCreditMap;
    }


    public class CMAccountTeamWrapper{
        public String actId{get;set;}
        public String userId{get;set;}
        public String baseApproverLevel{get;set;}
    }

    private static Map<String, CMAccountTeamWrapper> setBaseCMApproverMap(List<AccountTeamMember> actmembers){
        Map<String, CMAccountTeamWrapper> wrapperBaseCMMap = new Map<String, CMAccountTeamWrapper>();
        for(AccountTeamMember act : actmembers){
            if(!wrapperBaseCMMap.containsKey(act.Account.Account_Code__c)){
                List<String> approverLevelList = act.Approver_Level__c.split(';');
                String baseApprover = approverLevelList[0];
                CMAccountTeamWrapper actWrap = new CMAccountTeamWrapper();
                actWrap.actId = act.Id;
                actWrap.userId = act.UserId;
                actWrap.baseApproverLevel = baseApprover;
                wrapperBaseCMMap.put(act.Account.Account_Code__c, actWrap);
            }
            else{
                CMAccountTeamWrapper actTeamWrap = wrapperBaseCMMap.get(act.Account.Account_Code__c);
                List<String> approverLevelList = act.Approver_Level__c.split(';');
                String baseApprover = approverLevelList[0];
                if(actTeamWrap.baseApproverLevel > baseApprover){
                    actTeamWrap.actId = act.Id;
                    actTeamWrap.userId = act.UserId;
                    actTeamWrap.baseApproverLevel = baseApprover;
                    wrapperBaseCMMap.put(act.Account.Account_Code__c, actTeamWrap);
                }
            }
        }
        return wrapperBaseCMMap;
    }

    /* NOT IN USE
    * method getZipCodeWithAssignFIAgent
    * param1: strObjectName - Object API name to assign ownershit
    * param2: setZipCode - Set of Customer Current address Zip Code
    * param3: strAssignToField - Record OwnerId
    * param4: setAccountId - Set of Loan Applicantion Branch Ids
    * param5: isRoundRobin - Boolean - RoundRobin Required or Not (always true)
    */
    public static Map<String,Id> getZipCodeWithAssignFIAgent(String strObjectName, Set<String> setZipCode, String strAssignToField, Set<String> setAccountId, Boolean isRoundRobin){
        // SFAU-5433
        List<String> lstFIAgentProfiles = Label.FI_Agent_All_Profiles.split(';');
        // Map of zipcode with userId
        Map<String,String> pincodeVsOwnerMap = new Map<String,String>();
        // Get Branch and Field Investigation Mapping records
        List<Branch_Field_Investigation_Master__c> lstBFIMapping = new List<Branch_Field_Investigation_Master__c>();
        if (setAccountId.size() > 0)
            lstBFIMapping = [Select Id, Branch_Name__c, Branch_Name__r.Account_Code__c, FI_Agent__c, Is_Active__c, Pin_Code__c from Branch_Field_Investigation_Master__c where Pin_Code__c in: setZipCode and Branch_Name__r.Account_Code__c in: setAccountId AND FI_Agent__r.IsActive = true AND Is_Active__c = true AND FI_Agent__r.Profile.Name in: lstFIAgentProfiles];
        else
            lstBFIMapping = [Select Id, Branch_Name__c, Branch_Name__r.Account_Code__c, FI_Agent__c, Is_Active__c, Pin_Code__c from Branch_Field_Investigation_Master__c where Pin_Code__c in: setZipCode AND FI_Agent__r.IsActive = true AND Is_Active__c = true AND FI_Agent__r.Profile.Name in: lstFIAgentProfiles];

        system.debug(LoggingLevel.DEBUG,':: Brand and Field Investigation Master ' + lstBFIMapping.size());
        if (lstBFIMapping.isEmpty())
            return pincodeVsOwnerMap;
        AdvancedRecordAssignment.isRoundRobin = isRoundRobin;
        AdvancedRecordAssignment.lstBranchAndFIMapping = lstBFIMapping;

        // Round Robin
        List<AdvancedRecordAssignment.ZipCodeUserIdWrapper> zipCodeUserDataList = new List<AdvancedRecordAssignment.ZipCodeUserIdWrapper>();
        zipCodeUserDataList = AdvancedRecordAssignment.roundRobingAssigFieldInvestigation(strObjectName,setZipCode,strAssignToField);
        system.debug('zipCodeUserDataList>>>>>'+zipCodeUserDataList);
        for(AdvancedRecordAssignment.ZipCodeUserIdWrapper zipCodeUserData:zipCodeUserDataList){
            if (zipCodeUserData.userId != NULL && zipCodeUserData.zipCodeAndProduct != NULL)
                pincodeVsOwnerMap.put(zipCodeUserData.zipCodeAndProduct,zipCodeUserData.userId);
        }
        return pincodeVsOwnerMap;
    }

    /*
    * method getZipCodeWithAssignFIAgent
    * description - method two query on FI Agents from Master respective to Product (Record Type)
    * param1: strObjectName - Object API name to assign ownershit
    * param2: setZipCode - Set of Customer Current address Zip Code
    * param3: strAssignToField - Record OwnerId
    * param4: setAccountId - Set of Loan Applicantion Branch Ids
    * param5: isRoundRobin - Boolean - RoundRobin Required or Not (always true)
    * param6: strLoanRecordType - Loan Record Type to filter Branch Field Investigation Master based on Product type
    */
    public static Map<String,Id> getZipCodeWithAssignFIAgent(String strObjectName, Set<String> setZipCode, String strAssignToField, Set<String> setAccountId, Boolean isRoundRobin, String strLoanRecordType){
        //SFAU-5433
        List<String> lstFIAgentProfiles = Label.FI_Agent_All_Profiles.split(';');
        // Map of zipcode with userId
        Map<String,String> pincodeVsOwnerMap = new Map<String,String>();
        try {
            // Get Branch and Field Investigation Mapping records
            List<Branch_Field_Investigation_Master__c> lstBFIMapping = new List<Branch_Field_Investigation_Master__c>();

            if(strLoanRecordType == 'Tractor' || strLoanRecordType == 'Commercial_Vehicle' || strLoanRecordType == 'Construction_Equipment')
                strLoanRecordType = 'Four_Wheeler';

            if (setAccountId.size() > 0)
                lstBFIMapping = [Select Id, Branch_Name__c, Branch_Name__r.Account_Code__c, FI_Agent__c, Is_Active__c, Pin_Code__c from Branch_Field_Investigation_Master__c where Pin_Code__c in: setZipCode and Branch_Name__r.Account_Code__c in: setAccountId AND FI_Agent__r.IsActive = true AND Is_Active__c = true AND RecordType.DeveloperName =: strLoanRecordType  AND FI_Agent__r.Profile.Name in: lstFIAgentProfiles];
            else
                lstBFIMapping = [Select Id, Branch_Name__c, Branch_Name__r.Account_Code__c, FI_Agent__c, Is_Active__c, Pin_Code__c from Branch_Field_Investigation_Master__c where Pin_Code__c in: setZipCode AND FI_Agent__r.IsActive = true AND Is_Active__c = true AND RecordType.DeveloperName =: strLoanRecordType AND FI_Agent__r.Profile.Name in: lstFIAgentProfiles];
            system.debug(LoggingLevel.DEBUG,':: Branch and Field Investigation Master ' + lstBFIMapping.size());
            if (lstBFIMapping.isEmpty())
                return pincodeVsOwnerMap;
            AdvancedRecordAssignment.isRoundRobin = isRoundRobin;
            AdvancedRecordAssignment.lstBranchAndFIMapping = lstBFIMapping;

            // Round Robin
            List<AdvancedRecordAssignment.ZipCodeUserIdWrapper> zipCodeUserDataList = new List<AdvancedRecordAssignment.ZipCodeUserIdWrapper>();
            zipCodeUserDataList = AdvancedRecordAssignment.roundRobingAssigFieldInvestigation(strObjectName,setZipCode,strAssignToField);
            system.debug('zipCodeUserDataList>>>>>'+zipCodeUserDataList);
            for(AdvancedRecordAssignment.ZipCodeUserIdWrapper zipCodeUserData:zipCodeUserDataList){
                if (zipCodeUserData.userId != NULL && zipCodeUserData.zipCodeAndProduct != NULL)
                    pincodeVsOwnerMap.put(zipCodeUserData.zipCodeAndProduct,zipCodeUserData.userId);
            }
        }
        catch (Exception ex) {
            throw ex;
        }
        return pincodeVsOwnerMap;
    }
    
    /*
     * method handleCaseRejectOnFI
     * param1 rejectLoanMap
     * SFAU-5459
    */
    public static void handleCaseRejectOnFI(Map<Id,Loan_Application__c> rejectedLoanMap){
        try{
            List<STring> inProgressStages = new List<String>{'New','Assigned','In Progress'};
            if(!rejectedLoanMap.isEmpty()){
                List<Field_Investigation__c> rejectedLoanFIList = new List<Field_Investigation__c>();
                rejectedLoanFIList = [SELECT Id, Stage__c, Remark__c , Remarks__c, Applicant__c, Type_of_address__c, Loan_Application__c FROM Field_Investigation__c WHERE Loan_Application__c IN:rejectedLoanMap.keySet()
                                      AND Stage__c IN:inProgressStages];
                if(!rejectedLoanFIList.isEmpty()){
                    for(Field_Investigation__c firec : rejectedLoanFIList){
                        fiRec.Stage__c = 'Cancelled';
                        fiRec.Remark__c = System.Label.RejectedLoanFILabel;
                        fiRec.Remarks__c = System.Label.RejectedLoanFILabel;
                    }
                    update rejectedLoanFIList;
                    updateDeviationsOnCancelled(rejectedLoanFIList);
                }
            }
        }catch(exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
        
    }

    public static void updateDeviationsOnCancelled(List<Field_Investigation__c> rejectedLoanFIList){
        try{
            Map<String, Field_Investigation__c> fiRecordMap = new Map<String, Field_Investigation__c>();
            Set<Id> loanIds = new Set<Id>();
            Set<Id> toBeArchivedDevRecordsFiIds = new Set<Id>();
            List<Deviation__c> deviationsRecords = new List<Deviation__c>();
            for(Field_Investigation__c fiRecord : rejectedLoanFIList){
                fiRecordMap.put(fiRecord.Applicant__c+'_'+fiRecord.Type_of_address__c, fiRecord);
                loanIds.add(fiRecord.Loan_Application__c);
            }
            if(!loanIds.isEmpty()){
                deviationsRecords = [SELECT Id, Archived__c, Field_Investigation__c, Field_Investigation__r.Loan_Application__c FROM Deviation__c WHERE
                                    Field_Investigation__r.Loan_Application__c IN:loanIds AND Archived__c = false
                ];
                if(!deviationsRecords.isEmpty()){
                    for(Deviation__c devRecord : deviationsRecords){
                        devRecord.Archived__c = true;
                    }
                    update deviationsRecords;
                }
            }
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
        
    }
    /*SFAU-5459 End******************************************/


    public class CustomException extends Exception {}

}