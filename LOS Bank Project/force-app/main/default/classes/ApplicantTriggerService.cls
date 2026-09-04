/*******************************************************************************************
* @Name         ApplicantTriggerService
* @Author       Narasimha Gundarao 
* @Description  Service class for Applicant Trigger - common methods across all portfolios
*               are written in this class
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Narasimha Gundarao        26/10/2022         Initial Creation 
*******************************************************************************************/
public with sharing class ApplicantTriggerService implements ServiceInterface {
    
    public void beforeInsert(List<sObject> newRecordList){        
        for(Applicant__c app : (List<Applicant__c>)newRecordList){
            //SFAU-5205 : Added by Samridhi
            app.First_Name__c = String.isBlank(app.First_Name__c) ? '' : app.First_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');  
            app.Middle_Name__c = String.isBlank(app.Middle_Name__c) ? '' : app.Middle_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');  
            app.Last_Name__c = String.isBlank(app.Last_Name__c) ? '' : app.Last_Name__c.replaceAll('[^a-zA-Z0-9\\s]', ''); 
            
            //SFAU-5241 : Added by Samridhi
            app.Entity_Name__c = String.isBlank(app.Entity_Name__c) ? '' : app.Entity_Name__c.replaceAll('[^a-zA-Z0-9\\s]', ''); 

            app.Customer_Name__c = String.isBlank(app.Customer_Name__c) ? '' : app.Customer_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');
        }
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        system.debug('inapllicantservice>>>');
      
        Set<Id> gtrAddedList = new Set<Id>();
		Id gtrRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Guarantor').getRecordTypeId();
        
        //SFAU-4796
        for(sObject sobjectRec : newRecordList){
            Applicant__c app = (Applicant__c) sobjectRec;
            if( app.IsInactive__c == false && app.recordTypeId == gtrRecordTypeId){
                gtrAddedList.add( app.Loan__c );
            }
        }

        if(!gtrAddedList.isEmpty()){
            ChargesController.computeStampDutyCharge(gtrAddedList);
        }
      
        createChecklists((Map<Id, Applicant__c>) newRecordMap);
            updatePrimaryApplicantOnLoanApplication((Map<Id, Applicant__c>) newRecordMap,null);
        //updateLoanName((List<Applicant__c>)newRecordList, (Map<Id, Applicant__c>) newRecordMap);
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
        Map<Id, Applicant__c> oldAppRecordMap = (Map<Id, Applicant__c>)oldRecordMap;
        Map<Id,Applicant__c> setOfAppIds = new Map<Id,Applicant__c>();
        system.debug('oldAppRecordMap'+oldAppRecordMap);
        //R2-1673 start
        List<String> reVisitScreens = System.Label.Re_Visit_Screens.split(',');
        Map<String,Boolean> screenVsRevisit = new Map<String,Boolean>();
        for(String screen: reVisitScreens){
            screenVsRevisit.put(screen,false);
        }
        Map<Id, Applicant__c> mapOfAdditionalFields = new Map<Id, Applicant__c>([SELECT Id, Loan__r.RecordType.DeveloperName, RecordType.DeveloperName
        FROM Applicant__c WHERE Id IN :newRecordMap.keySet()]);
        //end
        for(Applicant__c app : (List<Applicant__c>)newRecordList){
            system.debug('app.PAN__c'+app.PAN__c);
            system.debug('oldAppRecordMap.get(app.Id).PAN__c'+oldAppRecordMap.get(app.Id).PAN__c);
            // if any of the paramters of Applicant which goes to CIBIL get's updated, set rerun Cibil as true
            if(app.CIBIL_Status__c != null && ((oldAppRecordMap.get(app.Id).First_Name__c != app.First_Name__c) || (oldAppRecordMap.get(app.Id).Middle_Name__c != app.Middle_Name__c) 
                || (oldAppRecordMap.get(app.Id).Last_Name__c != app.Last_Name__c) || (oldAppRecordMap.get(app.Id).Dob__c != app.Dob__c)
                || (oldAppRecordMap.get(app.Id).Mobile_Number__c != app.Mobile_Number__c) || (oldAppRecordMap.get(app.Id).Aadhaar_Number__c != app.Aadhaar_Number__c)
                || (oldAppRecordMap.get(app.Id).PAN__c != app.PAN__c)|| (oldAppRecordMap.get(app.Id).Voter_Id__c != app.Voter_Id__c)
                || (oldAppRecordMap.get(app.Id).Driving_License_Id__c != app.Driving_License_Id__c) || (oldAppRecordMap.get(app.Id).Passport_Number__c != app.Passport_Number__c))){
                    setOfAppIds.put(app.Id,app);
                }
            
            //SFAU-5205 : Added by Samridhi
            app.First_Name__c = String.isBlank(app.First_Name__c) ? '' : app.First_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');  
            app.Middle_Name__c = String.isBlank(app.Middle_Name__c) ? '' : app.Middle_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');  
            app.Last_Name__c = String.isBlank(app.Last_Name__c) ? '' : app.Last_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');  

            //SFAU-5241 : Added by Samridhi
            app.Entity_Name__c = String.isBlank(app.Entity_Name__c) ? '' : app.Entity_Name__c.replaceAll('[^a-zA-Z0-9\\s]', ''); 
        
            app.Customer_Name__c = String.isBlank(app.Customer_Name__c) ? '' : app.Customer_Name__c.replaceAll('[^a-zA-Z0-9\\s]', '');

            system.debug(LoggingLevel.WARN, 'app.Loan__r.RecordType.DeveloperName '+app.Loan__r.RecordType.DeveloperName);
            //R2-1673 and R2-1970 start
            //changes done under R2-1757
            if(((oldAppRecordMap.get(app.Id).Relationship_with_applicant__c!=app.Relationship_with_applicant__c) || 
                (mapOfAdditionalFields.get(app.Id).RecordType.DeveloperName =='Primary_Applicant' && oldAppRecordMap.get(app.Id).Marital_Status__c!=app.Marital_Status__c))
                && (mapOfAdditionalFields.get(app.Id).Loan__r.RecordType.DeveloperName =='Tractor' || mapOfAdditionalFields.get(app.Id).Loan__r.RecordType.DeveloperName =='Commercial_Vehicle' || mapOfAdditionalFields.get(app.Id).Loan__r.RecordType.DeveloperName =='Construction_Equipment' )  ){
                    String reVisitScreensJSON;
                    if(app.Re_Visit_Screens__c==null){
                        screenVsRevisit.put('Financial',true);
                    }else{
                        Map<String,Boolean> screenVsRevisitTemp = (Map<String,Boolean>) JSON.deserialize(app.Re_Visit_Screens__c, Map<String,Boolean>.class);
                        screenVsRevisitTemp.put('Financial',true);
                        screenVsRevisit = screenVsRevisitTemp;
                    }
                    /*if(mapOfAdditionalFields.get(app.Id).Loan__r.RecordType.DeveloperName =='Tractor'){
                        screenVsRevisit.put('LoanDetails',true);
                    }*/
                    reVisitScreensJSON = JSON.serializePretty(screenVsRevisit);
                    app.Re_Visit_Screens__c = reVisitScreensJSON;
            }
            //end


        }
        // Do not set CIBIL Rerun as true of Loan Application is Pre-approved --> Kunal [9th Sept]
        if(!setOfAppIds.keySet().isEmpty()){
                for(Applicant__c app: [SELECT Id, CIBIL_Rerun__c, CIBIL_Status__c, Last_CIBIL_Run_Date__c FROM Applicant__c WHERE Id IN: setOfAppIds.keySet() AND Loan__r.Pre_Approved_Flag__c = False AND CIBIL_Status__c != null WITH SECURITY_ENFORCED]){
                    setOfAppIds.get(app.Id).CIBIL_Rerun__c = true;
                    setOfAppIds.get(app.Id).CIBIL_Status__c = null;
                    setOfAppIds.get(app.Id).Last_CIBIL_Run_Date__c = null;
        }
    }

}
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        makeEYCCCallout(newRecordList,oldRecordMap,newRecordMap);
        updateDocChecklists(newRecordList,oldRecordMap,newRecordMap);// Marking docChecklists as Inactive based on Constitution type
        updatePrimaryApplicantOnLoanApplication((Map<Id, Applicant__c>) newRecordMap,(Map<Id, Applicant__c>) oldRecordMap);
        List<Applicant__c> custGradeUpdateApplicantList = new List<Applicant__c>();
        Set<Id> loanIds = new Set<Id>();
        List<Loan_Application__c> applicationsToUpdate = new List<Loan_Application__c>();
        Set<Id> loansWithInactiveApplicant = new Set<Id>();
        Set<Id> guarantorStageChangeList = new Set<Id>();
		Id gtrRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Guarantor').getRecordTypeId();

        for(sObject sobjectRec : newRecordList){
            Applicant__c newRec = (Applicant__c)sobjectRec;
            Applicant__c oldRec = (Applicant__c)oldRecordMap.get(newRec.Id);
            if(newRec.Customer_Grade__c != oldRec.Customer_Grade__c){
                custGradeUpdateApplicantList.add(newRec);
            }
            if(newRec.AML_Status__c != oldRec.AML_Status__c && newRec.AML_Status__c=='Rejected'){
                loanIds.add(newRec.Loan__c);
            }
            // SFAU-5326
            if( newRec.IsInactive__c != oldRec.IsInactive__c ){
                loansWithInactiveApplicant.add( newRec.Loan__c );
            }
            
            //Stamp Duty recalculation - SFAU-4796
            if( newRec.IsInactive__c != oldRec.IsInactive__c && newRec.recordTypeId == gtrRecordTypeId){
                guarantorStageChangeList.add( newRec.Loan__c );
            }
        }
        if(!loanIds.isEmpty()){
            for(Id loanId : loanIds){
                Loan_Application__c loan = new Loan_Application__c();
                loan.Id=loanId;
                loan.Stage__c='Rejected';
                applicationsToUpdate.add(loan);
            }
            if(!applicationsToUpdate.isEmpty()){
                update applicationsToUpdate;
            }
        }
        if(!custGradeUpdateApplicantList.isEmpty()){
            updateCustomerGradeOnLA(custGradeUpdateApplicantList);
        }

        // SFAU-5326 | When applicant is marked inactive the loan should be updated with details like POS of Active loans, Exposure
        if( !loansWithInactiveApplicant.isEmpty() ){
            LeadDedupeController.updateLoanApplication( new List<Id>( loansWithInactiveApplicant )[0] );
        }
        
        //SFAU-4796 | Recompute Stamp Duty Charge when Guarantor is made inactive or activated
        if(!guarantorStageChangeList.isEmpty()){
            ChargesController.computeStampDutyCharge(guarantorStageChangeList);
        }
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }
    public void updateCustomerGradeOnLA(List<Applicant__c> custGradeUpdateApplicantList){
        Set<String> loanApplicantionIdSet = new Set<String>();
        List<Loan_Application__c> updateLoanList = new List<Loan_Application__c>();
        Map<String, List<Applicant__c>> loanApplicantListMap = new Map<String, List<Applicant__c>>();
        Map<String, Loan_Application__c> loanMap = new Map<String, Loan_Application__c>();
        Map<String, Loan_Application__c> updateLoanMap = new Map<String, Loan_Application__c>();
        for(Applicant__c eachApplicant : custGradeUpdateApplicantList){
            loanApplicantionIdSet.add(eachApplicant.Loan__c);
        }
        List<String> cowProducts = Label.AutoLoanCowProducts.Split(',');
        for(
            Loan_Application__c eachLoan : 
            [
                SELECT Id, Customer_Grade__c,
                (SELECT Id, Customer_Grade__c FROM Applicants__r)
                FROM Loan_Application__c 
                WHERE Id IN: loanApplicantionIdSet AND (Product__c = '10201' OR Product__c = '10202' OR Product__c = '10203' OR Product__c IN: cowProducts) //SFAU-5584
            ]
        ){
            loanApplicantListMap.put(eachLoan.Id, eachLoan.Applicants__r);
            loanMap.put(eachLoan.Id, eachLoan);
        }
        for(Applicant__c eachApplicant : custGradeUpdateApplicantList){
            if(eachApplicant.Customer_Grade__c == 'Premium'){
                if(loanMap.containsKey(eachApplicant.Loan__c) && loanMap.get(eachApplicant.Loan__c).Customer_Grade__c == 'NIB'){
                    updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c, Customer_Grade__c = 'Premium'));
                }
            } else if(eachApplicant.Customer_Grade__c == 'NIB'){
                if(loanMap.containsKey(eachApplicant.Loan__c) && loanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'NIB'){
                    Boolean isIBPresent = false;
                    Boolean isPremiumPresent = false;
                    for(Applicant__c eachChildApplicant : loanApplicantListMap.get(eachApplicant.Loan__c)){
                        if(eachChildApplicant.Customer_Grade__c == 'IB'){
                            isIBPresent = true;
                        }
                        else if(eachChildApplicant.Customer_Grade__c == 'Premium'){
                            isPremiumPresent = true;
                        }
                    }
                    if(!isIBPresent && !isPremiumPresent){
                        if(!updateLoanMap.containsKey(eachApplicant.Loan__c)){
                            updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                             Customer_Grade__c = 'NIB'));
                        }
                    }
                }
            }
            /*if(eachApplicant.Customer_Grade__c == 'IB'){
                if(loanMap.containsKey(eachApplicant.Loan__c) && loanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'IB'){
                    if(updateLoanMap.containsKey(eachApplicant.Loan__c) && updateLoanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'IB'){
                        updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                     Customer_Grade__c = 'IB'));   
                    }
                    else if(!updateLoanMap.containsKey(eachApplicant.Loan__c)){
                        updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                     Customer_Grade__c = 'IB'));
                    }
                }
            }
            else if(eachApplicant.Customer_Grade__c == 'Premium'){
                if(loanMap.containsKey(eachApplicant.Loan__c) && loanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'Premium'){
                    Boolean isIBPresent = false;
                    for(Applicant__c eachChildApplicant : loanApplicantListMap.get(eachApplicant.Loan__c)){
                        if(eachChildApplicant.Customer_Grade__c == 'IB'){
                            isIBPresent = true;
                            break;
                        }
                    }
                    if(isIBPresent){
                        if(loanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'IB'){
                            if(updateLoanMap.containsKey(eachApplicant.Loan__c) && updateLoanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'IB'){
                                updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                                 Customer_Grade__c = 'IB'));   
                            }
                            else if(!updateLoanMap.containsKey(eachApplicant.Loan__c)){
                                updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                                 Customer_Grade__c = 'IB'));
                            }
                        }                            
                    }
                    else{
                        if(updateLoanMap.containsKey(eachApplicant.Loan__c)){
                            if(updateLoanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'Premium' && updateLoanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'IB'){
                                updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                                 Customer_Grade__c = 'Premium'));
                            }
                        }
                        else{
                            updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                             Customer_Grade__c = 'Premium'));
                        }
                    }
                }
            }
            else if(eachApplicant.Customer_Grade__c == 'NIB'){
                if(loanMap.containsKey(eachApplicant.Loan__c) && loanMap.get(eachApplicant.Loan__c).Customer_Grade__c != 'NIB'){
                    Boolean isIBPresent = false;
                    Boolean isPremiumPresent = false;
                    for(Applicant__c eachChildApplicant : loanApplicantListMap.get(eachApplicant.Loan__c)){
                        if(eachChildApplicant.Customer_Grade__c == 'IB'){
                            isIBPresent = true;
                        }
                        else if(eachChildApplicant.Customer_Grade__c == 'Premium'){
                            isPremiumPresent = true;
                        }
                    }
                    if(!isIBPresent && !isPremiumPresent){
                        if(!updateLoanMap.containsKey(eachApplicant.Loan__c)){
                            updateLoanMap.put(eachApplicant.Loan__c, new Loan_Application__c(Id = eachApplicant.Loan__c,
                                                                                             Customer_Grade__c = 'NIB'));
                        }
                    }
                }
            }*/
        }
        if(!updateLoanMap.isEmpty()){
            update updateLoanMap.values();
        }
    }   
    
    public void saveEKYCPdf(List<Applicant__c> newRecordList, Map<Id,Applicant__c> oldRecordMap, Map<Id,Applicant__c> newRecordMap, List<Applicant__c> filtrApplcntRec) {
        String applcntId = newRecordList[0].Id;
        Applicant__c applcantRec   = newRecordList[0];

        if(filtrApplcntRec.size() > 0) {
            PageReference pdf = Page.EKYC_PDF;
            pdf.getParameters().put('id', applcntId);
            
            Blob body;
            
            try {
                if(Test.isRunningTest()) { 
                    body = blob.valueOf('Test EKYC PDF');
                } else {
                    body = pdf.getContent();
                }                           
                system.debug('body-->'+body);
                ApplicantTriggerService applTriggrServObj = new ApplicantTriggerService();
                applTriggrServObj.insertEkycPdf(body, applcntId, applcantRec);                
            }
            catch (VisualforceException e) {
                system.debug('Error Message-->'+e.getMessage() + 'at ' + e.getStackTraceString());
            }            
        }        
    }

    public void makeEYCCCallout(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        system.debug('inapllicantservice after update>>>');
        Map<Id, Applicant__c> oldAppRecordMap = (Map<Id, Applicant__c>)oldRecordMap;
        List<Applicant__c> filtrApplcntRec = new List<Applicant__c>();
        for(Applicant__c app : (List<Applicant__c>)newRecordList){
            if((oldAppRecordMap.get(app.Id).KYC_Status__c != 'Complete' && app.KYC_Status__c == 'Complete') && (app.KYC_Type__c == 'Aadhaar - Biometric' || app.KYC_Type__c == 'Aadhaar - OTP')){
                filtrApplcntRec.add(app);
                
                Queueable_EKYC runJob = new Queueable_EKYC((List<Applicant__c>) newRecordList, (Map<Id,Applicant__c>) oldRecordMap, (Map<Id,Applicant__c>) newRecordMap, filtrApplcntRec);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(runJob);
                system.debug('jobId->>'+jobID);
            }
        }
    }

    // Mark documents Active/Inactive based on Consitution Type.
    public void updateDocChecklists(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        Map<Id, Applicant__c> oldAppRecordMap = (Map<Id, Applicant__c>)oldRecordMap;
        Map<Id,Applicant__c> filtrApplcntRec = new Map<Id,Applicant__c>();

        for(Applicant__c app : (List<Applicant__c>)newRecordList){
            if(oldAppRecordMap.get(app.Id).Constitution_Type__c != app.Constitution_Type__c && app.Constitution_Type__c != null){
                filtrApplcntRec.put(app.Id,app);
            }
        }
        List<Document_Checklist__c> updatedDocCheckLists = new List<Document_Checklist__c>();
        List<Document_Checklist__c> docCheckLists = [SELECT Id,Active__c,Applicant__c,Document_Master__r.Constitiution__c,Category__c,Sub_Category__c FROM Document_Checklist__c
         Where Applicant__c IN: filtrApplcntRec.keySet() AND Document_Master__r.Individual_NI__c = 'NI' AND Document_Master__r.Constitiution__c != null];
        for(Document_Checklist__c docCheck : docCheckLists){
            if( !(docCheck.Document_Master__r.Constitiution__c.contains(filtrApplcntRec.get(docCheck.Applicant__c).Constitution_Type__c)) && docCheck.Active__c ){
                docCheck.Active__c = false;
                updatedDocCheckLists.add(docCheck);
            }else if( docCheck.Document_Master__r.Constitiution__c.contains(filtrApplcntRec.get(docCheck.Applicant__c).Constitution_Type__c) && !docCheck.Active__c ){
                docCheck.Active__c = true;
                updatedDocCheckLists.add(docCheck);
            }
        }
        update updatedDocCheckLists;
    }
    
    public void insertEkycPdf(Blob pdfContent , Id applcntRecId, Applicant__c applcantRec) {
        
        String typeOfApplcnt = ''; 
        List<Document_Checklist__c> getDocCheck = getDocChckRec(applcntRecId);
        
        String applcntFirstName      = String.isNotBlank(applcantRec.First_Name__c) ? applcantRec.First_Name__c : '';
        String applcntMiddleName     = String.isNotBlank(applcantRec.Middle_Name__c) ? applcantRec.Middle_Name__c : '';
        String applcntLastName       = String.isNotBlank(applcantRec.Last_Name__c) ? applcantRec.Last_Name__c : '';
        String applicantFullName     = applcntFirstName + ' ' + applcntMiddleName + ' ' + applcntLastName;
        String applcntEmail          = String.isNotBlank(applcantRec.Email__c) ? applcantRec.Email__c : '';
        
        if(applcantRec.RecordType.Name == 'Applicant') {
            typeOfApplcnt = 'Applicant';
        }
        else if(applcantRec.RecordType.Name == 'Co-Applicant') {
            typeOfApplcnt = 'Co-Applicant';
        }
        else if(applcantRec.RecordType.Name == 'Guarantor') {
            typeOfApplcnt = 'Guarantor';
        }
        
        ContentVersion conVer        = new ContentVersion();
        conVer.ContentLocation       = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient          = 'EKYC.pdf'; // The files name, extension is very important here which will help the file in preview.
        conVer.is_EKYC_pdf__c        = true;
        conVer.Title                 = 'Salesforce_' + typeOfApplcnt + '_' + applicantFullName; // Display name of the files
        conVer.Customer_Full_Name__c = applicantFullName;
        conVer.Customer_Email__c     = applcntEmail;
        conVer.Customer_DOB__c       = applcantRec.Dob__c;
        conVer.VersionData = pdfContent; // converting your binary string to Blog
        if(Schema.sObjectType.ContentVersion.isCreateable()) {
            insert conVer;    //Insert ContentVersion
        }
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = getDocCheck.size() > 0 ? getDocCheck[0].Id : null; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            insert conDocLink;
        }      
    }
    
    public List<Document_Checklist__c> getDocChckRec(String currentRecordId) {
        
        List<Document_Checklist__c> getDocChecklstId = [SELECT Id 
                                                        FROM Document_Checklist__c 
                                                        WHERE Applicant__r.Id =: currentRecordId 
                                                        AND Document_Master__r.Document_Name__c = 'EKYC PDF' WITH SECURITY_ENFORCED];
        
        return getDocChecklstId.size() > 0 ? getDocChecklstId : new List<Document_Checklist__c>();      
    }
    
    public void createChecklists(Map<Id, Applicant__c> newApplicantsMap) {
        system.debug('checklist>>>');
        RuleEngineHandler getDocChecklists = new RuleEngineHandler();
        Set<String> applicantIds = new Set<String>();
        List<Document_Checklist__c> checklistsToInsert = new List<Document_Checklist__c>();
        String applicantId;
        for (Id each : newApplicantsMap.keySet()) {
            if(GlobalConstants.APPLICANTS_RECORD_TYPES_IDS.contains(newApplicantsMap.get(each).RecordTypeId)){
                applicantIds.add(String.valueOf(each));
            }
        }

        if(applicantIds.isEmpty()){
            return;
        }
         applicantId = (new List<String>(applicantIds)[0]);
        
        Map<Id, Set<String>> documentMasterIdsByApplicant = getDocumentIds(getDocChecklists.main('Applicant__c', applicantIds, new Set<String>(), 'Document Checklist'));
        Map<String,Document_Master__c> docMasterMap = new Map<String,Document_Master__c>();
        System.debug('***doc Ids: '+documentMasterIdsByApplicant.keySet());
        
        for(Document_Master__c each : [SELECT Id,Name,
                                       Document_Sub_Category__c 
                                       FROM Document_Master__c
                                       WHERE Document_ID__c IN: documentMasterIdsByApplicant.keySet() WITH SECURITY_ENFORCED]){
                                           docMasterMap.put(each.Document_ID__c,each);                                 
                                       }
        
        for (Id each : documentMasterIdsByApplicant.keySet()) {
            for (String eachMasterId : documentMasterIdsByApplicant.get(each)) {
                Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) : 
                new Document_Master__c(); 
                checklistsToInsert.add(new Document_Checklist__c
                                       (Applicant__c = each, 
                                        Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                        Category__c = currentRec.Document_Sub_Category__c,
                                        Sub_Category__c = currentRec.Name,
                                        Active__c = true
                                       )
                                      );
            }
        }
        
        if(Schema.sObjectType.Document_Checklist__c.isCreateable()) {
            insert checklistsToInsert;
        }       
    }
    
    private Map<Id, Set<String>> getDocumentIds(String breJSONString) {
        Map<Id, Set<String>> returnValue = new Map<Id, Set<String>>();
        Map<String, Object> applicantChecklists = (Map<String, Object>) JSON.deserializeUntyped(breJSONString);
        Map<String, Object> checklists = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if(checklists != null){
            for (String each : checklists.keySet()) {
                Set<String> masterIds = new Set<String>();
                List<Object> checklistsOfApp = (List<Object>) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject : checklistsOfApp) {
                    Map<String, Object> objProperties = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }
    
    public void updateLoanName(List<Applicant__c> newRecordList,Map<Id,Applicant__c> newRecordMap) {
        Id primaryAppRecTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Map<Id, Opportunity> oppListToUpdate = new Map<Id, Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        
        for (Applicant__c each : newRecordList) {
            oppIdSet.add(each.Loan__c);
        }
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id, Name from Opportunity WHERE Id IN :oppIdSet]);
        try{
            for (Applicant__c each : newRecordList) {
                if(each.RecordTypeId == primaryAppRecTypeId){
                    /*Opportunity opp = new Opportunity();
opp.Id = each.Loan__c;
opp.Primary_Borrower__c = each.Id;
opp.Name = (each.Constitution__c == 'Individual' || each.Constitution__c == null ? (each.First_Name__c == null ? '' : (each.First_Name__c + ' - ')) :
(each.Company_Name__c == null ? '' : (each.Company_Name__c + ' - '))) + opportunityMap.get(opp.Id).Name;
oppListToUpdate.put(opp.Id, opp);*/
                }
            }
            if(!oppListToUpdate.isEmpty())
                Database.update(oppListToUpdate.values());
        }catch(Exception ex){
            // Added catch in case we need to add Loggers in later stages
            system.debug('exception-->'+ex.getMessage() + '-' + ex.getStackTraceString());  
        }        
    }
    
    private static void updatePrimaryApplicantOnLoanApplication(Map<Id,Applicant__c> applicantMap, Map<Id,Applicant__c> oldRecordMap) {
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Map<Id,Loan_Application__c> loanApplicationMap = new Map<Id,Loan_Application__c>();
        for(Id applicantId : applicantMap.keySet()) {
            if( (oldRecordMap == null  || oldRecordMap.get(applicantId).RecordTypeId !=  applicantMap.get(applicantId).RecordTypeId ) &&  applicantMap.get(applicantId).RecordTypeId == applicantRecordTypeId) {
                Loan_Application__c applicationRecord = new Loan_Application__c(Id=applicantMap.get(applicantId).Loan__c, Primary_Applicant__c =applicantId);
                loanApplicationMap.put(applicantMap.get(applicantId).Loan__c,applicationRecord);
            }
        }
        if(!loanApplicationMap.isEMpty()){
            update loanApplicationMap.values();
        }
    }
}