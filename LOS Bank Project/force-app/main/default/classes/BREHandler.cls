/*****
 * Class Name: BREHandler
 * Description: Create BRE Payload
 * Test Class Name: BREHandlerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * May-31-2023          -   Mohit Maheshwari
 * June-5-2023          -   Mohit M.            -   SFAU-2713 - TW Risk Category and FW Risk Category
 * June-7-2023          -   Mohit Maheshwari    -   SFAU-2189
 * June-13-2023         -   Mohit M.            -   SFAU-3099
 * July-12-2023         -   Mohit M.            -   Change in validateToMoveNext - Send Back To RO as per feedback/mail
 * July-21-2023         -   Mohit M.            -   Add Applicant - Total_Monthly_Income_Sum__c
 * Jyly-28-2023         -   Mohit M.            -   SFAU-4382 - Add Applicant Id with Reason Text to avoid confusion in deviations of same with with multiple Applicant
 * Aug-23-2023          -   Mohit M.            -   SFAU-4937 - Avoid Blank Stage
 * Aug-24-2023          -   Mohit M.            -   SFAU-4921 - Add Common Scheme and Deviations for BusinessType
 * Sep-01-2023          -   Mohit M.            -   SFAU-5088 - 
 * Sep-14-2023          -   Mohit M.            -   SFAU-5141 - Save Customer Grade received from BRE on Loan Application Customer Grade
 * Sep-18-2023          -   Mohit M.            -   SFAU-5157 - Default Branch Top Up and linkAccountNumber
 * Sep-26-2023          -   Mohit M.            -   SFAU-5184 - Save CPV Waiver on Applicant field 
 * 4th Oct-2023         -   Sachin              -   Case sent back from Credit or Pricing will be reassigned to all the Credit / Pricing Hierarchy
 * 5th Oct-2023         -   Mohit M.            -   SFAU-5226 and SFAU-5350 - Run BRE for Credit Approval when Loan Amount > Offer Amount
 * Nov-08-2023          -   Mohit M.            -   SFAU-5572 - CUG||4W|| Credit approval record is not created
 * Nov-09-2023          -   Mohit M.            -   SFAU-5482 - CUG II SFDC II BRE tags Missing for STP
 * Nov-21-2023          -   Mohit M.            -   SFAU-5533 - Validate Customer Detail before BRE Run
 * Nov-22-2023          -   Mohit M.            -   SFAU-5609 - Update the current stage from Previous Stage for TW and DDE
 * Nov-22-2023          -   Mohit M.            -   SFAU-5605 - Create Approval Record only when BRE Run is true
 * Nov-24-2023          -   Samridhi            -   SFAU-5639 - Move to Previous Stage only when sent from PSD or Ops Maker
 * Nov-30-2023          -   Mohit M.            -   SFAU-5605 - NSTP credit Send back to RO cases are not reflecting in Credit user "My action" or "All Queue"
 * Nov-30-2023          -   Mohit M.            -   SFAU-5664 - Set uwAuthority Base Level when uwAuthority is NULL
*/
public with sharing class BREHandler {
    /*
    @ methodname : generateBRERequest
    @ param1 :  loanAppRecId - Loan Application Id
    @ param2 :  strRequestId - Integration Checklist RequestId
    */
    public static BRERequestWrapper generateBRERequest(String loanAppRecId, String strRequestId){

        List<Applicant__c> appList = new List<Applicant__c>();
        List<Loan_Application__c> lstLoanApp = new List<Loan_Application__c>();
        List<Charge__c> chargeList = new List<Charge__c>();
        List<Collateral__c> collateralList = new List<Collateral__c>();
        List<Collateral__c> newCollateralList = new List<Collateral__c>();
        List<Collateral__c> usedOrCashOnWheelsCollateralList = new List<Collateral__c>();
        Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues = new Map<String,BRE_Enum_Values__mdt>();
         Map<String,String> mapOfBreCustGrades = new Map<String,String>();
        Map<String,Applicant_Financials_Details__c> mapApplicantIdWithAFD = new Map<String,Applicant_Financials_Details__c>();
        List<Applicant_Financials_Details__c> lstAFD = new List<Applicant_Financials_Details__c>();
        Map<String,Applicant_Financials_Details__c> mapSalDocument = new Map<String,Applicant_Financials_Details__c>();
        Map<String,Applicant_Financials_Details__c> mapFinParent = new Map<String,Applicant_Financials_Details__c>();
        Map<String,Applicant_Financials_Details__c> mapFinAssessed = new Map<String,Applicant_Financials_Details__c>();
        Map<String,Location_Master__c> mapPinCodeWithLocationMaster = new Map<String,Location_Master__c>();
        Map<String,Location_Master__c> mapPinCodeWithLocationMasterSingle = new Map<String,Location_Master__c>();
        Map<String,Location_Master__c> mapCityWithLocationMaster = new Map<String,Location_Master__c>();
        Set<String> setCollateralZip = new Set<String>();
        Map<String,Applicant_Financials_Details__c> mapFinApplication = new Map<String,Applicant_Financials_Details__c>();
        Map<String,BRE_Customer_Risk_Profile_Mapping__mdt> mapTWCustomerRiskProfile = new Map<String,BRE_Customer_Risk_Profile_Mapping__mdt>();
        Map<String,BRE_Customer_Risk_Profile_Mapping__mdt> mapFWCustomerRiskProfile = new Map<String,BRE_Customer_Risk_Profile_Mapping__mdt>();
        List<Fleet__c> lstFleet = new List<Fleet__c>();
        Map<String,ProductRTMap__mdt> mapProductRTMapping = ProductRTMap__mdt.getall();
        Set<Id> setApplicantIds = new Set<Id>();
        Map<Id, Document_Checklist__c> mapDocumentChecklist = new Map<Id, Document_Checklist__c>();
        Map<Id,Field_Investigation__c> mapFieldInvestigation = new Map<Id,Field_Investigation__c>();
        List<Location_Master__c> lstLocationMaster = new List<Location_Master__c>();
        List<Bank_Account_Records__c> lstBAD = new List<Bank_Account_Records__c>();
        Set<String> setCollateralCity = new Set<String>();
        BRERequestWrapper breReqWrapObj = new BRERequestWrapper();
        try {
            for(BRE_Customer_Risk_Profile_Mapping__mdt custRiskProfile : BRE_Customer_Risk_Profile_Mapping__mdt.getall().values()){
                if (custRiskProfile.Product__c == 'Two Wheeler')
                    mapTWCustomerRiskProfile.put(custRiskProfile.Risk_Profile__c,custRiskProfile);
                else if (custRiskProfile.Product__c == 'Four Wheeler')
                    mapTWCustomerRiskProfile.put(custRiskProfile.Risk_Profile__c,custRiskProfile);
            }
    
            lstLoanApp = BREHandlerService.getLoanApplication (loanAppRecId);
            
            lstBAD = BREHandlerService.getBankAccountRecords (loanAppRecId);
            
            ProductRTMap__mdt metaProductRTMap = mapProductRTMapping.containsKey('A_'+lstLoanApp[0].Product__c) ? mapProductRTMapping.get('A_'+lstLoanApp[0].Product__c) : NULL;
    
            
            
    
            lstFleet = [Select Id,Type_of_Vehicle__c  , Name, Vehicle_Make_Model__c, Vehicle_Number__c, Relationship_with_borrower__c, MFG_Year__c, HPN_Status__c, Financial_Institution_Name__c, Loan_Tenure__c, Installment_Paid__c from Fleet__c where Loan_Application__c =: loanAppRecId and Inactive__c = false];
            
            lstAFD = [Select Id,Size_of_Agri_Land__c ,Salary_Received_in_Bank__c,Annual_Net_Profit__c ,Annual_Total_Income__c ,Applicant__r.loan__r.recordtype.developerName,Crop_Details__c ,MSP__c  ,Sowing_Month__c ,Harvesting_Month__c ,Land_Owner_Name__c,No_of_Cattle__c,Sub_Grade__c, Applicant__r.loan__r.recordType.name,Applicant__r.loan__r.Product__c ,Applicant__r.loan__r.Collateral_Type__c,Name, Consider_Fleet_for_Eligibility__c ,Applicant__r.Relationship_with_applicant__c,Applicant__r.loan__r.stage__c,Recordtype.DeveloperName, Monthly_Income__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Monthly_Net_Profit__c, Average_Monthly_Salary__c, Applicant__r.Name,Applicant__r.Type_Of_Employment__c, Type_Of_Employment__c, Sub_Industry__c, Area_under_crop__c, Irrigartion_Source__c, Company_Name__c, Sector__c, Industry__c, Occupation__c, Customer_Grade__c, Company_Master__r.Company_Name__c, Company_Master__r.Company_Code__c, Company_Master__r.Company_Category__c, Applicant__r.Date_of_Establishment__c, No_of_years_in_Business__c, Total_Work_Experience__c, Method_Of_Assesment__c, Applicant__r.Total_Monthly_Income_Sum__c, Applicant__r.Free_Monthly_Cashflow__c, Applicant__r.Total_Monthly_Income__c, Applicant__r.loan__r.Sub_Grade__c FROM Applicant_Financials_Details__c WHERE Applicant__r.Loan__c =: loanAppRecId AND (Applicant__r.RecordType.Name = 'Applicant' OR Applicant__r.RecordType.Name = 'Co-Applicant' OR Applicant__r.RecordType.Name = 'Guarantor')  AND Applicant__r.IsInactive__c = FALSE order by Applicant__r.Name, createddate];
            
    
    
            Integer intAFDCounter = 0;
            for (Applicant_Financials_Details__c objAFD : lstAFD) {
                intAFDCounter++;
                mapFinApplication.put(intAFDCounter+'~'+objAFD.Applicant__r.Name+'~'+objAFD.recordType.DeveloperName,objAFD);
                if (objAFD.recordtype.DeveloperName == 'Salaried_Document' && !mapSalDocument.containsKey(objAFD.Applicant__r.Name)) {
                    //intAFDCounter = mapSalDocument.size() + 1;
                    mapSalDocument.put(objAFD.Applicant__r.Name,objAFD);
                }
                else if (objAFD.recordtype.DeveloperName == 'Financial_Parent' && !mapFinParent.containsKey(objAFD.Applicant__r.Name)) {
                    //intAFDCounter = mapFinParent.size() + 1;
                    mapFinParent.put(objAFD.Applicant__r.Name,objAFD);
                }
                else if (objAFD.recordtype.DeveloperName == 'Assessed_No_Document' && !mapFinAssessed.containsKey(objAFD.Applicant__r.Name)) {
                    //intAFDCounter = mapFinParent.size() + 1;
                    mapFinAssessed.put(objAFD.Applicant__r.Name,objAFD);
                }
            }
            
            for(BRE_Enum_Values__mdt bre : BRE_Enum_Values__mdt.getall().values()){
                mapOfBreEnumvalues.put(bre.Object_Name__c+'~'+bre.Field_Name__c +'~'+bre.SF_Value__c, bre);
            }
            system.debug(LoggingLevel.Info,'Customer type ' + mapOfBreEnumvalues.get('Applicant__c~Cutomer_Type__c~Individual'));
            appList = BREHandlerService.getApplicants(loanAppRecId);
            
            String loanId = appList[0].loan__c;
            
            chargeList = [SELECT Id, Total_Amount__c FROM Charge__c WHERE Charges_Name__c = 'Processing Fees' AND Loan_Application__c =: loanId ORDER BY CreatedDate DESC];
            
            collateralList = BREHandlerService.getCollateralRecords (loanId);
            for (Collateral__c objColleteral : collateralList) {
                if (String.isNotBlank(objColleteral.Pincode__c)) {
                    setCollateralZip.add(objColleteral.Pincode__c);
                }
                if (String.isNotBlank(objColleteral.City__c)) {
                    setCollateralCity.add(objColleteral.City__c);
                }
                if (String.isNotBlank(objColleteral.Registration_City__c)) {
                    setCollateralCity.add(objColleteral.Registration_City__c);
                }
                if(objColleteral.RecordType.Name == 'New')
                    newCollateralList.add(objColleteral);
                else{
                    usedOrCashOnWheelsCollateralList.add(objColleteral);
                }
            }
    
            collateralList = (newCollateralList.size()>0 ? newCollateralList : usedOrCashOnWheelsCollateralList.size()>0 ? usedOrCashOnWheelsCollateralList : new List<Collateral__c>());
            
            
            String requestBody;
            BRERequestWrapper.cls_message messageObj = new BRERequestWrapper.cls_message();
            BRERequestWrapper.cls_application applicationObj = new BRERequestWrapper.cls_application();
            BREApplicationInfo applicationInfoObj = new BREApplicationInfo();
            List<BREApplicants> applicantsList = new List<BREApplicants>();
            
            // applicationInfo data mapping
            Integer qdeCounter = appList[0].Loan__r.QDE_stage_counter__c != null ? Integer.valueOf(appList[0].Loan__r.QDE_stage_counter__c) + 1 : 1;
            Integer ddeCounter = appList[0].Loan__r.DDE_stage_counter__c != null ? Integer.valueOf(appList[0].Loan__r.DDE_stage_counter__c) + 1 : 1;
            applicationInfoObj.applicationId = appList[0].Loan__r.Application_Id__c != null ? appList[0].Loan__r.Application_Id__c : '';
            applicationInfoObj.applicationNumber = appList[0].Loan__r.Name;
            applicationInfoObj.leadId = appList[0].Loan__r.Lead_Id__c != null ? appList[0].Loan__r.Lead_Id__c : '';
            applicationInfoObj.transactionId = strRequestId;//RequestId.left(2) + RequestId.right(RequestId.length()-4);
            applicationInfoObj.branchCode = appList[0].Loan__r.Branch_Master__r.Account_Code__c;
            applicationInfoObj.branchName = appList[0].Loan__r.Branch_Name__c;
            applicationInfoObj.branchHub = appList[0].Loan__r.Branch_Master__r.Hub_Code__c;
            applicationInfoObj.branchRegion = appList[0].Loan__r.Branch_Master__r.Region__r.Account_Name__c;
            applicationInfoObj.applicationDate = appList[0].Loan__r.CreatedDate;
            applicationInfoObj.cityCategory = appList[0].Loan__r.Dealer_Master__r.Category__c != NULL ? appList[0].Loan__r.Dealer_Master__r.Category__c : '';
            applicationInfoObj.applicationStage = appList[0].Loan__r.Stage__c;
            applicationInfoObj.applicationCounter = appList[0].Loan__r.Stage__c == 'QDE' ? qdeCounter : ddeCounter; 
            applicationInfoObj.roName = appList[0].Loan__r.Owner.Name;
            applicationInfoObj.roCode = appList[0].Loan__r.Owner_code__c;
            applicationInfoObj.rmName = appList[0].Loan__r.Owner.Name; // need confirmation on mapping
            applicationInfoObj.rmCode = appList[0].Loan__r.Owner_code__c; // need confirmation on mapping
            applicationObj.applicationInfo = applicationInfoObj;
            
            Map<String,Applicant_Financials_Details__c> mapAppIdWithFinancial = new Map<String,Applicant_Financials_Details__c>();
            Map<String,Address__c> mapAppIdWithAddress = new Map<String,Address__c>();
            Map<String,Document_Checklist__c> mapAppIdWithDocument = new Map<String,Document_Checklist__c>();
            
            Map<String,BREApplicants> mapAppIdWithApplicant = new Map<String,BREApplicants>();
            
            // applicants data mapping
            for(Applicant__c app : appList){
                // Check for Customer Details filled in DDE Stage
                if (app.Loan__r.Stage__c == 'DDE' && !app.Is_Customer_Details_Saved__c && app.Customer_Type__c == 'Individual') {
                    throw new CustomEXception(Label.BRE_Customer_Detail_Missing_Msg);
                }

                // Set Applicant Id
                setApplicantIds.add(app.Id);

                // Set Dealer Master Purchase City
                if (app.Loan__r.Dealer_Master__c != NULL && String.isNotBlank(app.Loan__r.Dealer_Master__r.Purchase_City__c)) {
                    setCollateralZip.add(app.Loan__r.Dealer_Master__r.Purchase_City__c);
                }

                List<BREEmailDetails > emailDetailsList = new List<BREEmailDetails>();
                if(!mapAppIdWithFinancial.containsKey(app.Name) && app.Applicant_Financials__r.size() > 0) {
                    Integer intCounter = 0;
                    for (Applicant_Financials_Details__c objFin : app.Applicant_Financials__r) {
                        mapAppIdWithFinancial.put(app.Name+'~'+intCounter,objFin);
                        intCounter++;
                    }
                }
                if(!mapAppIdWithAddress.containsKey(app.Name) && app.Addresses__r.size() > 0) {
                    Integer intCounter = 0;
                    Integer intCBSCounter = 0;
                    Integer intOtherPermanentCounter = 0;
                    Boolean blnFoundCBS = false;
                    Boolean blnFoundPermOtherCBS = false;
                    for (Address__c objAddress : app.Addresses__r) {
                        if (objAddress.Address_Type__c == 'Permanent' && objAddress.Source_Type__c != 'CBS') {
                            blnFoundPermOtherCBS = true;
                            intOtherPermanentCounter = intCounter;
                        }
                        else if (objAddress.Address_Type__c == 'Permanent' && objAddress.Source_Type__c == 'CBS') {
                            blnFoundCBS = true;
                            intCBSCounter = intCounter;
                        }
                        setCollateralZip.add(objAddress.Pincode__c);
                        mapAppIdWithAddress.put(app.Name+'~'+intCounter,objAddress);
                        intCounter++;
                    }
                    if (blnFoundPermOtherCBS && blnFoundCBS) {
                        mapAppIdWithAddress.remove(app.Name+'~'+intCBSCounter);
                    }
                }
                if(!mapAppIdWithDocument.containsKey(app.Name) && app.Document_Checklists__r.size() > 0) {
                    Integer intCounter = 0;
                    for (Document_Checklist__c objDocCheck : app.Document_Checklists__r) {
                        mapAppIdWithDocument.put(app.Name+'~'+intCounter,objDocCheck);
                        intCounter++;
                    }
                }
                
                BREApplicants applicantsObj = new BREApplicants();
                applicantsObj.applicantType =  mapOfBreEnumvalues.get('Applicant__c~RecordType.Name'+'~'+app.RecordType.Name).Enum_Value__c;
                applicantsObj.applicantId = app.Name;
                applicantsObj.customerType = app.Customer_Type__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~Customer_Type__c'+'~'+app.Customer_Type__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~Customer_Type__c'+'~'+app.Customer_Type__c).Enum_Value__c : '') : '';
                if (String.isBlank(applicantsObj.customerType)) {
                    throw new CustomException(Label.BRE_Customer_Type_Blank_Error_Msg);
                }
                applicantsObj.customerSegment = app.Type_Of_Employment__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~Type_Of_Employment__c'+'~'+app.Type_Of_Employment__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~Type_Of_Employment__c'+'~'+app.Type_Of_Employment__c).Enum_Value__c : app.Type_Of_Employment__c) : '';
                
                    // Updated by kunal for SFAU-5437 --> Always pass Customer Grade from Loan Application
                     applicantsObj.customerGrade = String.isNotBlank(app.Loan__r.Customer_Grade__c) ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~Customer_Grade__c'+'~'+app.Loan__r.Customer_Grade__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~Customer_Grade__c'+'~'+app.Loan__r.Customer_Grade__c).Enum_Value__c : '') : ''; //Default - BANKING_SURROGATE
                if (String.isBlank(applicantsObj.customerGrade)){
                    throw new CustomException(System.Label.BRE_Customer_Grade_Blank_Error_Msg);
                }
                if (app.Customer_Type__c != null && app.Customer_Type__c == 'Individual') {
                    applicantsObj.constitution = Label.BRE_Constitution_Individual;
                }
                else {
                    applicantsObj.constitution = (mapOfBreEnumvalues.containsKey('Applicant__c~Constitution_Type__c'+'~'+app.Constitution_Type__c) ? 
                                                  mapOfBreEnumvalues.get('Applicant__c~Constitution_Type__c'+'~'+app.Constitution_Type__c).Enum_Value__c : '');
                }
                applicantsObj.existingCustomer = app.Existing_Customer__c == 'Yes' ? true : false;
                applicantsObj.dateOfBirth = app.DOB__c != NULL && applicantsObj.customerType == 'I' ? app.DOB__c : NULL;
                applicantsObj.age = app.Age__c != NULL  && applicantsObj.customerType == 'I' ? Integer.valueOf(app.Age__c) * 12 : 0;
                applicantsObj.gender = app.Gender__c;
                applicantsObj.nationality = 'INDIAN';
                applicantsObj.maritalStatus = app.Marital_Status__c != null ? mapOfBreEnumvalues.get('Applicant__c~Marital_Status__c'+'~'+app.Marital_Status__c).Enum_Value__c : 'SINGLE';
                //MM Optional
                applicantsObj.noOfDependents = app.No_of_Dependents__c != null ? Integer.valueOf(app.No_of_Dependents__c) <= 3 ? Integer.valueOf(app.No_of_Dependents__c): 4 : 0;
                
                // ----------- Testing purpose --------------- //
                //String strRelationshipwithApp = app.Relationship_with_applicant__c != NULL ? app.Relationship_with_applicant__c : '';
                String strRelationshipwithApp = '';
                if (app.RecordType.Name == 'Applicant') {
                    strRelationshipwithApp = 'SELF';
                }
                else if (app.RecordType.Name == 'Co-Applicant'){
                    strRelationshipwithApp = 'FATHER';
                }
                else if (app.RecordType.Name == 'Guarantor'){
                    strRelationshipwithApp = 'SPOUSE';
                }
    
                applicantsObj.relationWithApplicant = strRelationshipwithApp != '' ? strRelationshipwithApp.toUpperCase().replaceAll(' ','_').replaceAll('-','_') : '';
                
                applicantsObj.isAUEmployee = app.AU_Employee__c == 'Yes' ? true : false;
                applicantsObj.isPhysicallyChallenged = app.Phsically_challenged__c  == 'Yes' ? true : false;
                applicantsObj.isPDSubmitted = BREHandlerService.isPDSubmitted(app.loan__c);
                
                applicantsObj.internalRiskScore = app.Internal_Risk_Score__c != NULL ? Integer.valueOf(app.Internal_Risk_Score__c) : 0;
                applicantsObj.isBiometricAddressNotChanged = app.Is_Biometric_Address_Changed__c ? false : true; //added new field, needs to implement logic to update
                applicantsObj.isETBAddressNotChanged = app.Is_ETB_Address_Changed__c ? false : true; //added new field, needs to implement logic to update
                applicantsObj.cfrStatus = app.CFR_Status__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~CFR_Status__c'+'~'+app.CFR_Status__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~CFR_Status__c'+'~'+app.CFR_Status__c).Enum_Value__c : '') : ''; //LOV not matching with BRE Request enum
                applicantsObj.relatedPartyStatus = app.Related_Party_Status__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~Related_Party_Status__c'+'~'+app.Related_Party_Status__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~Related_Party_Status__c'+'~'+app.Related_Party_Status__c).Enum_Value__c : '') : ''; //LOV not matching with BRE Request enum
                applicantsObj.negativePartyStatus = app.Negative_Check_Status__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~Negative_Check_Status__c'+'~'+app.Negative_Check_Status__c) ?
                     mapOfBreEnumvalues.get('Applicant__c~Negative_Check_Status__c'+'~'+app.Negative_Check_Status__c).Enum_Value__c : '') : '';
                applicantsObj.amlStatus = app.AML_Status__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~AML_Status__c'+'~'+app.AML_Status__c) ? 
                    mapOfBreEnumvalues.get('Applicant__c~AML_Status__c'+'~'+app.AML_Status__c).Enum_Value__c : '') : ''; //LOV not matching with BRE Request enum
                applicantsObj.isLeadToLeadFullMatch = app.Is_Lead_To_Lead_Full_Match__c;
                applicantsObj.isLeadToLeadPartialMatch = app.Is_Lead_To_Lead_Partial_Match__c;
                applicantsObj.isLeadToCustomerPartialMatch = app.Is_Lead_To_Customer_Partial_Match__c;
                applicantsObj.ekycType = app.KYC_Type__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Applicant__c~KYC_Type__c'+'~'+app.KYC_Type__c) ? 
                     mapOfBreEnumvalues.get('Applicant__c~KYC_Type__c'+'~'+app.KYC_Type__c).Enum_Value__c : '') : '';
                if (String.isBlank(applicantsObj.ekycType) && app.Customer_Type__c == 'Non Individual') {
                    applicantsObj.ekycType = Label.BRE_Non_Individual_Kyc_Default_Value;
                }
                else if (String.isBlank(applicantsObj.ekycType) && applicantsObj.existingCustomer == true) {
                    applicantsObj.ekycType = Label.BRE_ETB_Customer_Default_Kyc_Type;
                }
                else if (String.isBlank(applicantsObj.ekycType)) {
                    throw new CustomException(System.Label.BRE_Customer_KYC_Type_Blank_Error_Msg);
                }

                
                applicantsObj.etbType = 'ROYALE'; // hardcoded as of now, will come from Customer 360 API // need to implement logic for enum
                /* START - SFAU-2713 */
                if (metaProductRTMap != NULL && metaProductRTMap.RecordType__c == 'Two Wheeler') {
                    applicantsObj.customerRiskProfile = app.X2W_Risk_Category__c;
                }
                else if (metaProductRTMap != NULL && metaProductRTMap.RecordType__c == 'Four Wheeler') {
                    applicantsObj.customerRiskProfile = app.X4W_Risk_Category__c;
                }
                applicantsObj.customerRiskProfile = String.isNotBlank(applicantsObj.customerRiskProfile) ? applicantsObj.customerRiskProfile.toUpperCase() : 'NORMAL';
                /* END - SFAU-2713 */

                applicantsObj.totalRelationshipValue = app.Final_Exposure__c != NULL ? Integer.valueOf(app.Final_Exposure__c) : 0; //need confirmation on the field mapping
                
                // auEmployeeDetails data mapping
                if (app.AU_Employee__c == 'Yes') {
                BREAuEmployeeDetails auEmployeeDetailsObj = new BREAuEmployeeDetails();
                auEmployeeDetailsObj.auEmployeeStatus = app.AU_Employment_status__c != null ? mapOfBreEnumvalues.get('Applicant__c~AU_Employment_status__c'+'~'+app.AU_Employment_status__c).Enum_Value__c : '';
                auEmployeeDetailsObj.auEmloyeeGrade = Label.AuEmloyeeGrade;    //'MT'; change as per requested by Himanshu //hardcoded as of now, will come in HCM API // need to implement logic for enum
                auEmployeeDetailsObj.dateOfJoining = app.Date_of_Joining__c != NULL ? app.Date_of_Joining__c : NULL; //will come in HCM API
                // Optional auEmployeeDetailsObj.pmsRating = ''; //will come in HCM API
                applicantsObj.auEmployeeDetails = auEmployeeDetailsObj;
                }
                
                
                
                //MM - Review - Optional
                //applicantsObj.financialDetails = new BREApplicants.cls_FinancialDetails();
                BREApplicants.cls_currentYearFinancials objTempMM4 = new BREApplicants.cls_currentYearFinancials();
                objTempMM4.curFinancialYears = '2021-22';   //2021-22
                objTempMM4.curDateOfFilingITR = System.Today(); //2022-05-04
                objTempMM4.isCurYearFinancialAudited = true;
                objTempMM4.curItrIncome = 1000000;  //1000000
                //applicantsObj.financialDetails.currentYearFinancials = objTempMM4;
                //applicantsObj.financialDetails.currentYearFinancials = NULL;
                
                //MM - Review - Optional END
                
                //MM - Review - Optional
                BREApplicants.cls_previousYearFinancials objTempMM5 = new BREApplicants.cls_previousYearFinancials();
                objTempMM5.prevFinancialYears = '2020-21';  //2020-21
                objTempMM5.prevDateOfFilingITR = System.Today().addYears(-1);   //2021-05-04
                objTempMM5.isPrevYearFinancialAudited = true;
                objTempMM5.prevItrIncome = 600000;  //600000
                //applicantsObj.financialDetails.previousYearFinancials = NULL;
                //applicantsObj.financialDetails = NULL;
                //applicantsObj.financialDetails.previousYearFinancials = objTempMM5;
                
                //MM - Review - Optional END
                
                
                
                
                
                
                String strEducationStatus = String.isNotBlank(app.Education_qualification__c) ? app.Education_qualification__c : '';
                if (String.isNotBlank(strEducationStatus)){
                    String strEduStatus = (mapOfBreEnumvalues.containsKey('Applicant__c~Education_qualification__c'+'~'+app.Education_qualification__c) ? 
                        mapOfBreEnumvalues.get('Applicant__c~Education_qualification__c'+'~'+app.Education_qualification__c).Enum_Value__c : '');
                    if (String.isBlank(strEduStatus)) {
                        throw new CustomException (System.Label.BRE_Applicant_Qualification_Error_Msg);
                    }
                    BREApplicants.cls_EducationDetails objEduDetails = new BREApplicants.cls_EducationDetails();
                    objEduDetails.educationStatus = strEduStatus;
                    applicantsObj.educationDetails = objEduDetails;
                }

                // BREEmailDetails - PERSONAL
                BREEmailDetails emailDetailsObj = new BREEmailDetails();
                emailDetailsObj.emailType = 'PERSONAL';
                emailDetailsObj.isEmailIdVerified = app.IsEmailVerified__c;
                emailDetailsList.add(emailDetailsObj);
                applicantsObj.emailDetails = emailDetailsList;
                mapAppIdWithApplicant.put(app.Name,applicantsObj);
            }
            
            system.debug(LoggingLevel.Info,'Collateral City ' + setCollateralCity);
            system.debug(LoggingLevel.Info,'Collateral PinCode ' + setCollateralZip);
    
            /*
            Create Map City With LocationMaster
            Create Map ZipCode and Area With LocationMaster
            Create Map ZipCode With LocationMaster
            */
            lstLocationMaster = [Select Id, State__c, City__c, Area_Status__c, Area_Type__c, CityType__c, Area_Name__c, Zip_Code__c, Working_Area__c from Location_Master__c where Zip_Code__c in: setCollateralZip or City__c in: setCollateralCity];
            for (Location_Master__c objLocMaster : lstLocationMaster) {
                mapPinCodeWithLocationMasterSingle.put(objLocMaster.Zip_Code__c,objLocMaster);
                mapCityWithLocationMaster.put(objLocMaster.City__c,objLocMaster);
                if (!mapPinCodeWithLocationMaster.containsKey(objLocMaster.Zip_Code__c +'~'+objLocMaster.Area_Name__c.toUpperCase()))
                    mapPinCodeWithLocationMaster.put(objLocMaster.Zip_Code__c +'~'+objLocMaster.Area_Name__c,objLocMaster);
            }

            
            if (setApplicantIds.size() > 0) {
                // Query on DocumentChecklist related to Applicants
                mapDocumentChecklist = BREHandlerService.getDocumentChecklistRecords (setApplicantIds);
                // Query on Field Investigation related to Applicants
                mapFieldInvestigation = BREHandlerService.getFieldInvestigationRecords(setApplicantIds);
            }

            // Query on Verification Report related to Applicants
            if (mapFieldInvestigation != NULL && mapFieldInvestigation.size()>0) {
                mapAppIdWithApplicant = BREHandlerService.getVerificationReportsPayload (mapAppIdWithApplicant,mapFieldInvestigation.values(), mapOfBreEnumvalues);
            }

            // Karza Data and ID Details Payload related to Applicants
            if (mapDocumentChecklist != NULL && mapDocumentChecklist.size()>0) {
                mapAppIdWithApplicant = BREHandlerService.createKarzaDataAndIdDetailsPayload (mapAppIdWithApplicant,mapDocumentChecklist.values(), mapOfBreEnumvalues);
            }
            
            if (mapFinParent.size() > 0) {
                mapAppIdWithApplicant = BREHandlerService.createEmploymentDetailsRequest (lstAFD, mapAppIdWithApplicant, mapOfBreEnumvalues, mapFinParent, mapFinAssessed, mapSalDocument, mapFinApplication);
            }
            
            if (mapAppIdWithAddress.size() > 0) {
                mapAppIdWithApplicant = BREHandlerService.createApplicantAddressRequest (mapAppIdWithApplicant, mapOfBreEnumvalues, mapAppIdWithAddress, mapPinCodeWithLocationMaster, mapPinCodeWithLocationMasterSingle);
            }
            
            // START - Change SFAU-5482 - CUG II SFDC II BRE tags Missing for STP - Mohit
            BREApplicantWrapper objWrapApp = new BREApplicantWrapper();
            objWrapApp = BREHandlerService.createCibilBureauMappingRequest (mapAppIdWithApplicant, mapOfBreEnumvalues, loanAppRecId);
            mapAppIdWithApplicant = objWrapApp.mapWrapBREApplicant;
            Map<String,BREApplicants> mapAppIdWithApplicantTemp = mapAppIdWithApplicant;
            for (BREApplicants breApp : mapAppIdWithApplicantTemp.values()) {
                if (String.isblank(breApp.customerSubGrade)) {
                    breApp.customerSubGrade = ((String.isNotblank(lstLoanApp[0].Sub_Grade__c) && mapOfBreEnumvalues.containsKey('Loan_Application__c~Sub_Grade__c'+'~'+lstLoanApp[0].Sub_Grade__c)) ? 
                         mapOfBreEnumvalues.get('Loan_Application__c~Sub_Grade__c'+'~'+lstLoanApp[0].Sub_Grade__c).Enum_Value__c : 'SFO');
                }
                mapAppIdWithApplicant.put(breApp.ApplicantId,breApp);
                if (objWrapApp.mapWrapAppNameWithBureauResult != NULL && objWrapApp.mapWrapAppNameWithBureauResult.containsKey(breApp.ApplicantId)) {
                    Bureau_Results__c objBR = objWrapApp.mapWrapAppNameWithBureauResult.get(breApp.ApplicantId);
                    String strPhone = objBR.TelephoneNumber__c;
                    String strAppMob = objBR.Applicant__r.Mobile_Number__c;
                    List<String> lstPhone = String.isNotBlank(strPhone) ? strPhone.split(',') : new List<String>();
                    Boolean blnMatch = false;
                    for (String strPh : lstPhone) {
                        blnMatch = (String.isNotBlank(strPh) && (strPh.length() > 10 ? (strPh.subString(strPh.length()-10) == strPhone ? true : strPh == strPhone) : strPh == strPhone) ? true : false);
                        if (blnMatch) {
                            blnMatch=true; 
                            break;
                        }
                    }
                    BREApplicants.cls_karzaData objBREKarza = new BREApplicants.cls_karzaData();
                    objBREKarza.karzaVerificationType = Label.BRE_Cibil_Karza_Phone_Type;
                    objBREKarza.subType = Label.BRE_Cibil_Karza_Phone;
                    objBREKarza.scoreOrValue = blnMatch ? 100 : 0;
                    objBREKarza.matchType = blnMatch ? Label.BRE_Cibil_Phone_Full_Match : Label.BRE_Cibil_Phone_No_Match;
                    objBREKarza.reportedDate = objBR.Bureau_Score_Date__c;
                    breApp.karzaData = breApp.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : breApp.karzaData;
                    breApp.karzaData.add(objBREKarza);
                    mapAppIdWithApplicant.put(breApp.ApplicantId,breApp);
                }
            }
            // END - Change SFAU-5482 - CUG II SFDC II BRE tags Missing for STP - Mohit
            
            mapAppIdWithApplicant = BREHandlerService.createBankAccountDetailRequestPayload (mapAppIdWithApplicant, mapOfBreEnumvalues, loanAppRecId, mapFinParent, lstBAD);
            
            //applicationObj.applicants = applicantsList;
            applicationObj.applicants = mapAppIdWithApplicant.values();
            
            //product data mapping
            List<BREProduct> productList = new List<BREProduct>();
            BREProduct productObj = new BREProduct();
            productObj = BREHandlerService.createBREUVehicleDetailRequest (lstLoanApp, productObj, usedOrCashOnWheelsCollateralList, collateralList, newCollateralList, mapOfBreEnumvalues, chargeList, mapPinCodeWithLocationMaster, mapPinCodeWithLocationMasterSingle, mapCityWithLocationMaster );
            // START - SFAU-5157 - Default Branch Top Up
            productObj.isTopUp = productObj.schemeId == Label.Branch_Topup_Scheme_Id ? true : false;
            for (Bank_Account_Records__c objBank : lstBAD) {
                String strLinkAccountNumber = '';
                if (objBank.RecordType.Name == 'CBS' && objBank.Account_Type__c == 'Loan' && objBank.Maturity_Date__c == NULL) {
                    productObj.linkedAccountNumberForTopUp = objBank.Account_Number__c;
                    break;
                }
                else if (objBank.RecordType.Name == 'CBS' && objBank.Account_Type__c == 'Loan' && objBank.Maturity_Date__c != NULL && objBank.Maturity_Date__c >= System.Today()) {
                    productObj.linkedAccountNumberForTopUp = objBank.Account_Number__c;
                }
            }
            // END - SFAU-5157 - Default Branch Top Up
            productList.add(productObj);
            
            applicationObj.product = productList;
            
            applicationObj.randomNumber = Integer.valueof((Math.random() * 100));
            
            //MM - Review - Optional
            applicationObj.documentsReceived = new List<BRERequestWrapper.cls_documentsReceived>();
            BRERequestWrapper.cls_documentsReceived objTempMM7 = new BRERequestWrapper.cls_documentsReceived();
            objTempMM7.documentName = 'AADHAAR';    //AADHAAR
            objTempMM7.documentDescription = 'AADHAAR CARD';    //AADHAAR CARD
            objTempMM7.documentDate = Date.Today().addMonths(-6);   //2020-05-04
            objTempMM7.isVerified = true;
            objTempMM7.stabilityDate = Date.Today().addYears(1);    //2022-12-30
            //applicationObj.documentsReceived.add(objTempMM7);
            applicationObj.documentsReceived = null;
            
            List<BRERequestWrapper.cls_fleetDetails> fleetDetails = new List<BRERequestWrapper.cls_fleetDetails>();
            for (Fleet__c objFleet : lstFleet) {
                BRERequestWrapper.cls_fleetDetails fleet = new BRERequestWrapper.cls_fleetDetails();
                fleet.ownerName = objFleet.Name;
                fleet.typeOfVehicle =  objFleet.Type_of_Vehicle__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Fleet__c~Type_of_Vehicle__c'+'~'+objFleet.Type_of_Vehicle__c) ? 
                     mapOfBreEnumvalues.get('Fleet__c~Type_of_Vehicle__c'+'~'+objFleet.Type_of_Vehicle__c).Enum_Value__c : objFleet.Type_of_Vehicle__c).toUpperCase() : '';//R2 Change
                
                fleet.relationshipWithBorrower = objFleet.Relationship_with_borrower__c == 'SELF' ? 'SELF' : 'FAMILY'; //objFleet.Relationship_with_borrower__c;//R2 Change
                fleet.vehicleMakeModel = String.isNotBlank(objFleet.Vehicle_Make_Model__c) ? objFleet.Vehicle_Make_Model__c : '';
                if(metaProductRTMap != NULL && metaProductRTMap.RecordType__c == 'Four Wheeler') {
                fleet.typeOfVehicle = 'CAR';
                }
                fleet.vehicleNumber = String.isNotBlank(objFleet.Vehicle_Number__c) ? objFleet.Vehicle_Number__c : '';
                fleet.mfgYear = String.isNotBlank(objFleet.MFG_Year__c) ? objFleet.MFG_Year__c : '';
                fleet.hpnStatus = String.isNotBlank(objFleet.HPN_Status__c) ? objFleet.HPN_Status__c : '';
                fleet.financialInstitutionName = String.isNotBlank(objFleet.Financial_Institution_Name__c) ? objFleet.Financial_Institution_Name__c : '';
                fleet.loanTenure = objFleet.Loan_Tenure__c != NULL ? Integer.valueOf(objFleet.Loan_Tenure__c) : 0;
                fleet.installmentPaid = objFleet.Installment_Paid__c != NULL ? Integer.valueOf(objFleet.Installment_Paid__c) : 0;      
                fleetDetails.add(fleet);
            }
            applicationObj.fleetDetails = (fleetDetails.size()>0 ? fleetDetails : NULL);
            
            
            //MM - Review - Optional END
            
            messageObj.requestTime = String.valueOf(DateTime.now().format('MMM dd, yyyy hh:mm:ss.SSS a z')); // 'May 11, 2023 12:55:00.286 AM UTC';// //'Apr 18, 2023 11:01:00.457 AM UTC'
            messageObj.decisionService = metaProductRTMap != NULL ? metaProductRTMap.BRE_Decision_Service__c : '';
            messageObj.callType = lstLoanApp[0].Stage__c == 'QDE' ? 'DP_ELIGIBILITY' : 'DP_UNDERWRITING';
            messageObj.application = applicationObj;
            // -------------- TESTING -- CHANGE ----------------//
           // messageObj.productType =  metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_TW' ? 'TW' : 'CAR'; // Need to change later and dynamic
       if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_TW'){
                       messageObj.productType = 'TW';
            }
            else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_CAR'){
                  messageObj.productType = 'CAR';
            }
            else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_TRACTOR'){
                  messageObj.productType = 'TRACTOR';
            }
        
             else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_COMMERCIAL' && metaProductRTMap.BRE_Product_Type_Enum__c=='CV_LOADING'){
                  messageObj.productType = 'CV_LOADING';
            }
            else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_COMMERCIAL' && metaProductRTMap.BRE_Product_Type_Enum__c=='CV_PASSENGER'){
                  messageObj.productType = 'CV_PASSENGER';
            }
             else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_COMMERCIAL' && metaProductRTMap.BRE_Product_Type_Enum__c=='CAR_TAXI'){
                  messageObj.productType = 'CAR_TAXI';
            }
             else if(metaProductRTMap != NULL && metaProductRTMap.BRE_Decision_Service__c == 'DS_COMMERCIAL' && metaProductRTMap.BRE_Product_Type_Enum__c=='CONSTRUCTION_EQUIPMENT'){
                  messageObj.productType = 'CONSTRUCTION_EQUIPMENT';
            }
            breReqWrapObj.message = messageObj;
            breReqWrapObj.RequestId = strRequestId;
            breReqWrapObj = BREHandlerService.createApplicationDocumentRequest (mapAppIdWithApplicant, mapOfBreEnumvalues, mapAppIdWithDocument, breReqWrapObj);
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.Error, ex + ' Line Number ' + ex.getLineNumber());
            throw ex;
        }
        return breReqWrapObj;
        
    }

    /*
    @description - Create Integration Checklist Record for BRE Request Payload
    */
    @AuraEnabled
    public static BREWrapper createBREIntegrationChecklistRecord(String loanAppId, String integrationMasterName) {
        BREWrapper objWrapper = new BREWrapper();
        try {
            Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(integrationMasterName);
            String strRequestId = IntegrationUtility.getReferenceId();
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanAppId, Request_Id__c = strRequestId, Integration_Master__c = objIntMapper.Id);
            upsert checklistRecord;
            objWrapper.intChecklistId = checklistRecord.Id;
            objWrapper.strRequestId = strRequestId;
            objWrapper.hasShowCriteriaPermission = FeatureManagement.checkPermission('Display_BRE_UW_Criterias');
            objWrapper.strSuccessMessage = 'BRE Run is in Progress. Request Id is: ' + objWrapper.strRequestId;
            // Update Loan Application BRE Status
            updateBreStatus (loanAppId);
            objWrapper.blnSuccess = true;
        }
        catch (Exception ex){
            objWrapper.strErrorMessage = ex.getMessage();
            Log.error('Error in BREHandler method createBREIntegrationChecklistRecord :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }
        return objWrapper;
    }
    
    /*
    @description - Invoke by breComponent to create BRE request payload
    */
    @AuraEnabled
    public static BREWrapper createBRERequest(String loanAppId, String integrationMasterName, String strIntChecklistRequestId) {
        BREWrapper objWrapper = new BREWrapper();
        objWrapper.blnSuccess = false;
        try {
            Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(integrationMasterName);
            Integration_Checklist__c objIntcheck = [Select id from Integration_CheckList__c where Request_Id__c =: strIntChecklistRequestId];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Id = objIntcheck.Id, Loan_Application__c = loanAppId, Request_Id__c = strIntChecklistRequestId, Integration_Master__c = objIntMapper.Id);
        
            BRERequestWrapper objRequestBody = generateBRERequest(loanAppId, strIntChecklistRequestId);
            objRequestBody.OriginatingChannel = objIntMapper.Channel__c;
            String requestBody = Json.serialize(objRequestBody);
            system.debug(LoggingLevel.Info, 'requestBody Success ');
            String respBody;
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.contentType = 'application/json';
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody = calloutResponseWrapper.response;
            
            // updating Bre Status as In Progress once create BRE request
            if (calloutResponseWrapper.statusCode == 200){
                if (objIntMapper.Disable_api__c == true) {
                    Integration_CheckList__c objTemp = [Select Id, Callback_Request__c, API_Error__c from Integration_CheckList__c where Id =: objIntcheck.Id];
                    objTemp.Callback_Request__c = respBody;
                    objTemp.API_Error__c = 'STUB';
                    update objTemp;
                }
                //updateBreStatus(loanAppId);
            }
            objWrapper.strRequestId = checklistRecord.Request_Id__c;
            objWrapper.strSuccessMessage = 'BRE Run is in Progress. Request Id is: ' + objWrapper.strRequestId;
            User objUser = [Select Id, Name, Profile.Name from User where Id =: UserInfo.getUserId()];
            if ((objUser.Profile.Name != 'Credit Manager' && objUser.Profile.Name != 'System Administrator')) {
                objWrapper.isMobileView = true;
            }
            objWrapper.blnSuccess = true;
        }
        catch (Exception ex) {
            objWrapper.strErrorMessage = 'Error to call BRE System.' + ex.getMessage(); 
            Log.error('Error in BREHandler :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }
        return objWrapper;  
    }
    
    
    public static void updateBreStatus(String loanAppId){
        Loan_Application__c currentLoan = [SELECT Id, Stage__c FROM Loan_Application__c WHERE Id=:loanAppId];//Pricing Approvals Change
        Loan_Application__c loanAppObj = new Loan_Application__c();
        loanAppObj.id = loanAppId;
        loanAppObj.BRE_Status__c = System.Label.BRE_Status_In_Progress;
        loanAppObj.Is_BRE_Credit_Subjectivity__c = false;
        loanAppObj.Is_BRE_Ops_Subjectivity__c = false;
        //Pricing Approvals Change Start
        if(currentLoan.Stage__c=='Credit' || currentLoan.Stage__c=='PSD'){
            loanAppObj.No_Pricing_Deviation__c = false;
        }
        //Pricing Approvals Change END
        //loanAppObj.Is_Confirmed__c = false;
        update loanAppObj;
    }

    /*
    @description - Received BRE Callback and create BRE Response record
    @Change On - June-29 By Mohit M.
    */
    public static void createBRERecord(List < Integration_Checklist__c > newRecordList, Map < Id, Integration_Checklist__c > oldRecordMap, Map < Id, Integration_Checklist__c > newRecordMap){
        List<BRE_Response__c> breResponseList = new List<BRE_Response__c>();
        Id loanAppId = NULL;
        //List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        for(Integration_Checklist__c ic: newRecordList){
            if(ic.Integration_Master_Name__c == 'FICO BRE' && String.isNotBlank(ic.Callback_Request__c) && String.isBlank(oldRecordMap.get(ic.id).Callback_Request__c)) {
                //creating Bre Response record once Callback_Request__c is updated
                BRE_Response__c bre = new BRE_Response__c();
                bre.Loan_Application__c = ic.Loan_Application__c;
                bre.Integration_CheckList__c = ic.id;
                bre.BRE_Request_Id__c = ic.Request_Id__c;
                bre.BRE_Response__c = ic.Callback_Request__c;
                bre.Update_New_Response__c = true;
                breResponseList.add(bre);
                loanAppId = ic.Loan_Application__c;
            }
        }
        if(breResponseList.size() > 0 && loanAppId != NULL){
            //updating the response coming from BRE Callback_Request__c
            //updateBreResponse(breResponseList[0].BRE_Response__c, loanAppId , breResponseList[0]);
            updateBreResponse(breResponseList[0].BRE_Response__c, loanAppId , breResponseList[0]);
        }
    }
    
    /*
    @description - Update BRE Response and Loan Application on BRE Response Received
    @Change On - June-29 By Mohit M.
    */
    public static void updateBreResponse(String responseBody, String loanAppId, BRE_Response__c breRecord){
        String productType;
        Map<String, List<String>> mapAppIdAndFiType = new Map<String, List<String>>();
        List<Applicant__c> applicantList = new List<Applicant__c>();
        List<Deviation__c> deviationLst = new List<Deviation__c>();
        Map<String, String> mapAppNameAndAppId = new Map<String, String>();
        BREResponseWrapper breResWrapObj = NULL;
        Boolean blnParseSuccess = false;
        Boolean blnSchemeEligible = false;
        String strSchemeSelectedByUser = '';
        Map<String,String> mapOfBreCustGrades = new Map<String,String>();
        Loan_Application__c loanApp = [SELECT Id, Product__c, Scheme__c, Scheme__r.Scheme_Code__c, Scheme__r.Scheme_Name__c, Stage__c, 
            Customer_Type__c, BRE_Decision__c, BRE_ReRun_Required__c, BRE_Run_Request_Id__c, QDE_stage_counter__c, DDE_stage_counter__c, 
            Is_BRE_Credit_Subjectivity__c, Is_BRE_Pricing_Deviations__c, BRE_Selected_Scheme__c, BRE_RO_Selected_Scheme__c  
            FROM Loan_Application__c WHERE Id=: loanAppId];
        Loan_Application__c loanAppObj = new Loan_Application__c();
        loanAppObj.BRE_Status__c = System.Label.BRE_Status_Received;
        loanAppObj.BRE_ReRun_Required__c = false;
        loanAppObj.BRE_Run_Request_Id__c = breRecord.BRE_Request_Id__c;
        loanAppObj.Id = loanAppId;
        loanAppObj.Is_BRE_Credit_Subjectivity__c = false;
        loanAppObj.Is_BRE_Pricing_Deviations__c = false;
        loanAppObj.BRE_Selected_Scheme__c = '';
        loanAppObj.BRE_RO_Selected_Scheme__c = loanApp.Scheme__r.Scheme_Code__c;
        strSchemeSelectedByUser = loanApp.Scheme__r.Scheme_Code__c;
        for(BRE_Enum_Values__mdt bre : BRE_Enum_Values__mdt.getall().values()){
            mapOfBreCustGrades.put(bre.Enum_Value__c,bre.SF_Value__c);
        }
        // SFAU-3099
        if (loanApp.Stage__c == 'QDE') {
            loanAppObj.QDE_stage_counter__c = loanAppObj.QDE_stage_counter__c != NULL ? loanAppObj.QDE_stage_counter__c + 1 : 1;
        }
        else if (loanApp.Stage__c == 'DDE') {
            loanAppObj.DDE_stage_counter__c = loanAppObj.DDE_stage_counter__c != NULL ? loanAppObj.DDE_stage_counter__c + 1 : 1;
        }
        
        if(loanApp.Product__c != null){
            productType = LosQuickLoanController.getRecordTypeName(loanApp.Product__c);
        }
        
        for(Applicant__c app : [SELECT Id, Name FROM Applicant__c WHERE Loan__c =: loanAppId AND (RecordType.Name = 'Applicant' OR RecordType.Name = 'Co-Applicant' OR RecordType.Name = 'Guarantor') AND IsInactive__c = FALSE]){
            mapAppNameAndAppId.put(app.Name, app.Id);
        }
        
        try{
            system.debug(LoggingLevel.Info,'blnParseSuccess ' + blnParseSuccess);
            breResWrapObj = BREResponseWrapper.parse(responseBody);
            system.debug(LoggingLevel.Info,'breResWrapObj ' + breResWrapObj);
            system.debug(LoggingLevel.Info,'blnParseSuccess ' + blnParseSuccess);
            blnParseSuccess = true;
            breRecord.Stage__c = loanApp.Stage__c;
            if(breResWrapObj != NULL && breResWrapObj.message != NULL && String.isNotBlank(breResWrapObj.message.responseStatus)){
                breRecord.Request_Time__c  = breResWrapObj.message.requestTime;
                if(breResWrapObj.message.application.applicationDecision != NULL){
                    breRecord.BRE_Decision__c = breResWrapObj.message.application.applicationDecision.systemDecision;
                    loanAppObj.BRE_Decision__c = breResWrapObj.message.application.applicationDecision.systemDecision;
                }
                // SFAU-5664 - Set uwAuthority Base Level when uwAuthority is NULL
                //if(breResWrapObj.message.application.applicationDecision.uwAuthority != null)
                loanAppObj.BRE_Application_Level__c = breResWrapObj.message.application.applicationDecision.uwAuthority != NULL ? breResWrapObj.message.application.applicationDecision.uwAuthority : Label.BRE_Base_Level_UWAuthority;
                if(breResWrapObj.message.responseStatus == System.Label.BRE_Response_Status_Success){
                    // for DECLINE,STP,NSTP
                    if(breResWrapObj.message.application.applicationDecision.systemDecision != null){
                        if(breResWrapObj.message.application.applicants.size() > 0 && breResWrapObj.message.application.applicants != null){
                            for(BREResponseWrapper.cls_applicants app : breResWrapObj.message.application.applicants){
                                Boolean blnFoundApplicant = false;
                                /* START - SFAU-5572 - CUG||4W|| Credit approval record is not created  */
                                Applicant__c appObj = new Applicant__c();
                                    if(mapAppNameAndAppId.containsKey(app.applicantId)){
                                        //if((productType == 'Four Wheeler' || productType == 'Tractor' || productType == 'Commercial Vehicle') && app.customerGrade != null) {
                                        if(System.Label.FW_R2_RecordTypes.contains(productType) && app.customerGrade != null) {                                            

                                            appObj.Id = mapAppNameAndAppId.get(app.applicantId);
                                             System.debug('mapOfBreCustGrades::'+mapOfBreCustGrades);
                                            if(mapOfBreCustGrades.get(app.customerGrade)!=null){
                                                System.debug('mapOfBreCustGrades.get(app.customerGrade)::'+mapOfBreCustGrades.get(app.customerGrade));
                                                 //START - SFAU-5141 - Save Customer Grade received from BRE on Loan Application Customer Grade
                                                appObj.Customer_Grade__c = mapOfBreCustGrades.get(app.customerGrade);
                                                loanAppObj.Customer_Grade__c = mapOfBreCustGrades.get(app.customerGrade);
                                                //END - SFAU-5141 - Save Customer Grade received from BRE on Loan Application Customer Grade
                                            }
                                           
                                          
                                        blnFoundApplicant = true;
                                        }
                                }
                                /* END - SFAU-5572 - CUG||4W|| Credit approval record is not created  */
                                if(app.applicantDecision.uwCriterias.size() > 0 && app.applicantDecision.uwCriterias != null){
                                    breRecord.Applicant_UW_Criterias__c  = String.valueOf(app.applicantDecision.uwCriterias);
                                    if(mapAppNameAndAppId.containsKey(app.applicantId)){
                                        appObj.Id = mapAppNameAndAppId.get(app.applicantId);
                                        //appObj.Loan__c = loanAppId;
                                        appObj.UnderWriting_Criteria__c = String.valueOf(app.applicantDecision.uwCriterias);
                                        //SFAU-2445 - Update CPV Wavier Off Reason on Applicant
                                        for(BREResponseWrapper.cls_UwCriterias uwc : app.applicantDecision.uwCriterias){
                                            /* - SFAU-5184 - Commented
                                            if(uwc.ruleLevel == Label.BRE_FI_Waiver_Rule_Level){
                                                appObj.CPV_Waive_off_Reason__c = uwc.reasonText;
                                            }
                                            */
                                            app.cpvWaivedOff = String.isNotBlank(app.cpvWaivedOff) ? uwc.reasonText + '\n' + app.cpvWaivedOff : uwc.reasonText;
                                            // SFAU-5184
                                            appObj.CPV_Waive_off_Reason__c = uwc.reasonText;
                                        }
                                        blnFoundApplicant = true;
                                    }
                                }
                                if (blnFoundApplicant) {
                                        applicantList.add(appObj);
                                    }
                                if(app.applicantDecision.calculatedVariables.size() > 0 && app.applicantDecision.calculatedVariables != null){
                                    breRecord.Applicant_Calculated_Variable__c = String.valueOf(app.applicantDecision.calculatedVariables);
                                }
                            }
                        }
                        
                        if(breResWrapObj.message.application.applicationDecision.calculatedVariables.size() > 0 && breResWrapObj.message.application.applicationDecision.calculatedVariables != null){
                            breRecord.Application_Calculated_variable__c = String.valueOf(breResWrapObj.message.application.applicationDecision.calculatedVariables);
                        }
                        
                        //for DECLINE
                        if(breResWrapObj.message.application.applicationDecision.systemDecision == System.Label.BRE_Decision_Decline){
                            loanAppObj.Stage__c = 'Rejected';
                        }
                        //for not DECLINE
                        else{
                            if(breResWrapObj.message.application.applicants.size() > 0 && breResWrapObj.message.application.applicants != null){
                                for(BREResponseWrapper.cls_applicants app : breResWrapObj.message.application.applicants){
                                    if(app.applicantDecision.fiInitiationDetails.size() > 0 && app.applicantDecision.fiInitiationDetails != null){
                                        for(BREResponseWrapper.cls_fiInitiationDetails fiIntlDetl : app.applicantDecision.fiInitiationDetails){
                                            if(fiIntlDetl.fiType != null && fiIntlDetl.fiType != '' && fiIntlDetl.isFIRequired){
                                                if(!mapAppIdAndFiType.containsKey(app.applicantId)){
                                                    mapAppIdAndFiType.put(app.applicantId, new List<String>());
                                                }
                                                mapAppIdAndFiType.get(app.applicantId).add(fiIntlDetl.fiType);
                                            }
                                        }
                                    } 
                                }
                                // When no FI Records Created then Waived Off - Feedback - SFAU-2189
                                List<Field_Investigation__c> lstFIRecords = new List<Field_Investigation__c>();
                                lstFIRecords = [Select Id from Field_Investigation__c where Applicant__r.Loan__c =: loanAppId AND Applicant__r.IsInactive__c = FALSE];
                                if (lstFIRecords.isEmpty() && mapAppIdAndFiType.size() == 0) {
                                    loanAppObj.Application_FI_Status__c = Label.FI_Stage_Waived_Off;
                                }
                            }
                            
                            // SFAU-4921 - Add Common Scheme and Deviations for BusinessType (Mohit M.) - Logic
                            if(breResWrapObj.message.application.product[0].productDecision != null){
                                loanAppObj.BRE_Product_Decison__c = String.valueOf(breResWrapObj.message.application.product[0].productDecision);
                                if (breResWrapObj.message.application.product[0].productDecision.schemeDecision != NULL && breResWrapObj.message.application.product[0].productDecision.schemeDecision.size() > 0) {
                                    List<BREResponseWrapper.cls_schemeDecision> lstUpdatedSchemeDecision = new List<BREResponseWrapper.cls_schemeDecision>();
                                    List<BREResponseWrapper.cls_schemeDecision> lstSchemeDecision = breResWrapObj.message.application.product[0].productDecision.schemeDecision;
                                    List<BREResponseWrapper.cls_deviationsDetails> lstBusinessDeviation = new List<BREResponseWrapper.cls_deviationsDetails>();
                                    Boolean blnHasEligibleBusDev = false;
                                    Boolean blnHasCommonDev = false;
                                    for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstSchemeDecision) {
                                        blnHasEligibleBusDev = ((blnHasEligibleBusDev || (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible)) ? true : false); 
                                        // SFAU-4921 - START
                                        if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common && lstBusinessDeviation.size()>0) {
                                            continue;
                                        }
                                        blnHasCommonDev = (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Common && objSchemeDec.schemeName == Label.BRE_Scheme_Name_Common && objSchemeDec.schemeId == Label.BRE_Scheme_Id_Common) ? true : false; 
                                        // SFAU-4921 - END
                                        if (objSchemeDec.schemeId != strSchemeSelectedByUser && objSchemeDec.isEligible == false && !blnHasCommonDev)
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
                                                    //blnFoundVariance = true;
                                                    objDev.variance = policyVal - actualVal;
                                                }
                                            }
                                            /* SFAU-4382 START */
                                            objDev.reasonText = String.isNotBlank(objDev.applicantId) ? objDev.reasonText + ' for Applicant ' + objDev.applicantId : objDev.reasonText;
                                            /* SFAU-4382 END */
                                            if (blnHasCommonDev) {
                                                lstBusinessDeviation.add(objDev); 
                                            }
                                        }
                                        if (blnHasCommonDev) { continue ;}
                                        objSchemeDec.blnSchemeSelectedByRO = objSchemeDec.schemeId == strSchemeSelectedByUser ? true : false;
                                        objSchemeDec.strSchemeNameWithWOEligible = objSchemeDec.schemeName + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                                        objSchemeDec.strSchemeCodeWithWOEligible = objSchemeDec.schemeId + ' ' + (objSchemeDec.isEligible == true ? Label.BRE_Eligible : Label.BRE_Not_Eligible);
                                        lstUpdatedSchemeDecision.add(objSchemeDec);
                                    }
                                    // SFAU-4921 - START
                                    system.debug(LoggingLevel.Info,' :: ' + blnHasEligibleBusDev);
                                    if (blnHasEligibleBusDev) {
                                        for (BREResponseWrapper.cls_schemeDecision objSchemeDec : lstUpdatedSchemeDecision) {
                                            if (objSchemeDec.schemeType == Label.BRE_Scheme_Type_Business && objSchemeDec.isEligible && (objSchemeDec.deviationsDetails == NULL || objSchemeDec.deviationsDetails.size() == 0) && lstBusinessDeviation.size()>0) {
                                                objSchemeDec.deviationsDetails = lstBusinessDeviation;
                                            }
                                            system.debug(LoggingLevel.Info,' :: objSchemeDec :: ' + objSchemeDec);
                                        }
                                    }
                                    // SFAU-4921 - END
                                    breResWrapObj.message.application.product[0].productDecision.schemeDecision = lstUpdatedSchemeDecision;
                                }
                            }
                            breRecord.BRE_Response__c = JSON.serialize(breResWrapObj);
                        }
                    }
                }
                else if( breResWrapObj.message.responseStatus != null && breResWrapObj.message.responseStatus == System.Label.BRE_Response_Status_Error){
                    // Upsert BRE Record
                    upsert breRecord;
                    // Update Loan Application
                    loanAppObj.BRE_ReRun_Required__c = loanApp.BRE_ReRun_Required__c;
                    update loanAppObj;
                }
            }
            else {
                blnParseSuccess = false;
                throw new CustomException(Label.BRE_Response_Error_Message);
            }
        }
        catch (Exception ex) {
            if (!blnParseSuccess) {
                loanAppObj.BRE_ReRun_Required__c = loanApp.BRE_ReRun_Required__c;
                loanAppObj.BRE_Status__c = System.Label.BRE_Decision_Error;
                loanAppObj.BRE_Decision__c = System.Label.BRE_Decision_Error;
                breRecord.BRE_Decision__c = System.Label.BRE_Decision_Error;
            }
            System.debug(LoggingLevel.Error,'Error in BREHandler Class :: ' + ex);
            System.debug(LoggingLevel.Error,'Error in BREHandler Class at line number :: ' + ex.getLineNumber());
            Log.error('Error in BREHandler :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }

        // DM Operations
        try {
            // Upsert BRE Record
            upsert breRecord;
            // Update Loan Application                        
            update loanAppObj;
            if(applicantList.size() > 0){
                update applicantList;
            }
            if(deviationLst.size() > 0){
                insert deviationLst;
            }
        }
        catch (Exception ex){
            System.debug(LoggingLevel.Error,'Error in BREHandler Class :: ' + ex);
            System.debug(LoggingLevel.Error,'Error in BREHandler Class at line number :: ' + ex.getLineNumber());
            Log.error('Error in BREHandler :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }
        try {
            if(mapAppIdAndFiType.keySet().Size() > 0){
                CreateFieldInvestigatiionRecord.fetchBRERelatedApplicantAddress(mapAppIdAndFiType, loanAppId, false, new List<String>());
            }
        }
        catch (Exception ex){
            System.debug(LoggingLevel.Error,'Error in BREHandler Class :: ' + ex);
            System.debug(LoggingLevel.Error,'Error in BREHandler Class at line number :: ' + ex.getLineNumber());
            Log.error('Error in BREHandler :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }
    }

    @AuraEnabled
    public static BREWrapper getBRECurrentLoanStatus (String loanAppId, String strRequestId, Boolean isbrescreen) {
        BREWrapper objBREWrapper = new BREWrapper();
        try{
            List<Loan_Application__c> lstLoanApplication = new List<Loan_Application__c> ();
            lstLoanApplication = [Select Id, BRE_Status__c, BRE_Decision__c, BRE_Run_Request_Id__c, BRE_ReRun_Required__c, Stage__c, Product__c,DDE_stage_counter__c, Send_Back_To_RO_Stage__c, (Select Id, Name, BRE_Decision__c, BRE_Request_Id__c, BRE_Response__c, Is_Confirmed__c, Request_Time__c, Stage__c from BRE_Responses__r order by createddate desc limit 1 ) from Loan_Application__c where Id =: loanAppId];
                if (lstLoanApplication.size() == 0)
                throw new CustomException('Loan Application Record Not Found');
            String prod = 'A_'+lstLoanApplication[0].Product__c;
            String productType = '';
            String productLabel = '';
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productType = prodRecordType.RecordType__c;
                productLabel = prodRecordType.Label;
            }
            if (lstLoanApplication[0].BRE_ReRun_Required__c || String.isBlank(lstLoanApplication[0].BRE_Status__c)) {
                objBREWrapper.blnRunBRE = isbrescreen;
            }
            // SFAU-3099
            else if (lstLoanApplication[0].BRE_Status__c == System.Label.BRE_Status_Received && lstLoanApplication[0].Stage__c == 'DDE' && productType == 'Four Wheeler' && (lstLoanApplication[0].DDE_stage_counter__c == NULL || lstLoanApplication[0].DDE_stage_counter__c == 0)) {
                objBREWrapper.blnRunBRE = isbrescreen;
            }
            else if (lstLoanApplication[0].BRE_Status__c == System.Label.BRE_Status_Received) {
                objBREWrapper.blnRunBRE = false;
                objBREWrapper.blnBREReceived = true;
                objBREWrapper.strRequestId = String.isNotBlank(lstLoanApplication[0].BRE_Run_Request_Id__c) ? lstLoanApplication[0].BRE_Run_Request_Id__c : lstLoanApplication[0].BRE_Responses__r[0].BRE_Request_Id__c;
            }
            
            if ((lstLoanApplication[0].BRE_Status__c == System.Label.BRE_Status_In_Progress || lstLoanApplication[0].BRE_Status__c == System.Label.BRE_Decision_Error)) {
                objBREWrapper.strSuccessMessage = Label.BRE_Response_Error_Message + ' ' + (String.isNotBlank(lstLoanApplication[0].BRE_Run_Request_Id__c) ? lstLoanApplication[0].BRE_Run_Request_Id__c : (lstLoanApplication[0].BRE_Responses__r != NULL && lstLoanApplication[0].BRE_Responses__r.size()>0 ? lstLoanApplication[0].BRE_Responses__r[0].BRE_Request_Id__c : ''));
                objBREWrapper.blnRunBRE = isbrescreen;
                objBREWrapper.blnBREReceived = false;
                objBREWrapper.blnBREError = true;
                objBREWrapper.strRequestId = lstLoanApplication[0].BRE_Run_Request_Id__c;
            }
            
            // Sachin - Send to existing Approver for Rework who has sent back to RO -- 14th Aug 23/ Added DDE stage for 2W - SFAU-4670
            // SFAU-5605 - Create Approval Record only when BRE Run is true and SFAU-5649
            //if(((new String[]{ GlobalConstants.QDE, GlobalConstants.STAGE_DDE }).contains(lstLoanApplication[0].Stage__c) && productType == GlobalConstants.TWOWHEELER) || (!objBREWrapper.blnRunBRE && lstLoanApplication[0].Stage__c == GlobalConstants.STAGE_DDE && (productType == GlobalConstants.FOURWHEELER && lstLoanApplication[0].BRE_Decision__c == GlobalConstants.BRE_DECISION_NSTP))){
            // Sachin - R2-2967 | Rework cases after BRE Run goes to fresh queue
            if((productType == 'Two Wheeler' && (new String[]{ GlobalConstants.QDE, GlobalConstants.STAGE_DDE }).contains(lstLoanApplication[0].Stage__c)) || (!objBREWrapper.blnRunBRE && lstLoanApplication[0].Stage__c == GlobalConstants.STAGE_DDE && (productType == GlobalConstants.FOURWHEELER && lstLoanApplication[0].BRE_Decision__c == GlobalConstants.BRE_DECISION_NSTP))){
                Loan_Application__c loanApplication = lstLoanApplication[0];
                // 4th Oct-2023 | Cases sent back will follow complete Credit / Pricing Hierarchy
                upsert Utility.getApprovalRecordsToRework(
                    loanApplication,
                    loanApplication.Send_Back_To_RO_Stage__c == GlobalConstants.STAGE_PRICING ? GlobalConstants.APPROVAL_TYPE_PRICING : GlobalConstants.APPROVAL_TYPE_CREDIT
                );
            }

            objBREWrapper.hasShowCriteriaPermission = FeatureManagement.checkPermission('Display_BRE_UW_Criterias');
            User objUser = [Select Id, Name, Profile.Name from User where Id =: UserInfo.getUserId()];
            if ((objUser.Profile.Name != 'Credit Manager' && objUser.Profile.Name != 'System Administrator')) {
                objBREWrapper.isMobileView = true;
            }
            objBREWrapper.blnSuccess = true;
        }
        catch (Exception ex) {
            objBREWrapper.blnSuccess = false;
            objBREWrapper.strErrorMessage = 'Error : ' + ex.getMessage() + ' at line number : ' + ex.getLineNumber();
            Log.error('Error in BREHandler :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
        }
        return objBREWrapper;
    }

    /*
    * @description - this method to check BRE run required
    */
    @AuraEnabled
    public static BRENextPageWrapper checkForBRERun (String loanAppId) {
        BRENextPageWrapper objNextWrapper = new BRENextPageWrapper();
        try {
            /* START - SFAU-5533 - Validate Customer Detail before BRE Run */
            List<Applicant__c> lstApp = new List<Applicant__c>();
            lstApp = [Select Id, Name, Is_Customer_Details_Saved__c,RecordType.Name,(Select Id,Sector__c,Industry__c,Sub_Industry__c,RecordType.Name from Applicant_Financials__r where RecordType.Name in ('Financial Parent')) from Applicant__c where RecordType.Name in ('Applicant','Co-Applicant','Guarantor') AND Customer_Type__c = 'Individual' AND Loan__c =: loanAppId AND IsInactive__c = FALSE AND Loan__r.Stage__c = 'DDE'];
            for (Applicant__c objApp : lstApp) {
                if (!objApp.Is_Customer_Details_Saved__c) {
                    throw new CustomEXception(Label.BRE_Customer_Detail_Missing_Msg + ': ' + objApp.Name);
                }
                if (objApp.RecordType.Name == 'Applicant') {
                    for(Applicant_Financials_Details__c objAppFinan : objApp.Applicant_Financials__r){
                        if(String.isBlank(objAppFinan.Sector__c) || String.isBlank(objAppFinan.Industry__c) || String.isBlank(objAppFinan.Sub_Industry__c)){
                            throw new CustomEXception(Label.BRE_Financial_Detail_Missing_Msg + ': ' + objApp.Name);
                        }
                    }
                }

            }
            /* END - SFAU-5533 - Validate Customer Detail before BRE Run */
            AUSFPreApprovedCheckController.PreApprovedWrapper objWrap = AUSFPreApprovedCheckController.getLoanApplicationStage (loanAppId);
            //SFAU-5226 AND SFAU-5350
            if ((objWrap.isPriceStage == NULL || objWrap.isPriceStage == false) || (objWrap.isCreditStage != NULL && objWrap.isCreditStage == true)){
                objNextWrapper.blnSuccess = true;
                objNextWrapper.blnBRERunRequired = true;
                return objNextWrapper;
            }
            List<Loan_Application__c> lstLoanApp = new List<Loan_Application__c>();
            lstLoanApp = [Select Id,ROI__c, Old_ROI__c, Product__c, Stage__c, Is_Charge_Changed__c, Sub_Grade__c from Loan_Application__c where Id =: loanAppId];
            objNextWrapper.strCurrentStage = lstLoanApp[0].Stage__c;
            String prod = 'A_'+lstLoanApp[0].Product__c;
            String productType = '';
            String productLabel = '';
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productType = prodRecordType.RecordType__c;
                productLabel = prodRecordType.Label;
            }
            //SFAU-5226 AND SFAU-5350
            //if(productType == 'Two Wheeler' && (lstLoanApp[0].Stage__c == 'QDE' || lstLoanApp[0].Stage__c == 'DDE') && (lstLoanApp[0].Is_Charge_Changed__c || objWrap.isPriceStage)) {
            if(productType == 'Two Wheeler' && ((lstLoanApp[0].Stage__c == 'QDE' && (lstLoanApp[0].Is_Charge_Changed__c  || objWrap.isPriceStage)) || (lstLoanApp[0].Stage__c == 'DDE' && objWrap.isPriceStage && (lstLoanApp[0].Is_Charge_Changed__c || lstLoanApp[0].ROI__c != lstLoanApp[0].Old_ROI__c)))) {
                objNextWrapper.strNextStage = 'Pricing';
            }
            else if(productType == 'Two Wheeler' && lstLoanApp[0].Stage__c == 'QDE') {
                objNextWrapper.strNextStage = 'DDE';
            }
            else if(productType == 'Two Wheeler' && lstLoanApp[0].Stage__c == 'DDE') {
                objNextWrapper.strNextStage = 'PSD';
            }

             if((productType == 'Four Wheeler'
                || productType == 'Tractor' 
                || productType == 'Commercial Vehicle')
               && lstLoanApp[0].Stage__c == 'QDE') {
                objNextWrapper.strNextStage = 'DDE';
            }
            else if((productType == 'Four Wheeler' || productType == 'Tractor' 
                || productType == 'Commercial Vehicle')
               && lstLoanApp[0].Stage__c == 'DDE') {
                //SFAU-5226 AND SFAU-5350
                objNextWrapper.strNextStage = ((objWrap.isPriceStage || lstLoanApp[0].Is_Charge_Changed__c) ? 'Pricing' : 'PSD');
            }
            // SFAU-4937 - Added a condition to avoid Blank Stage
            else if (String.isBlank(objNextWrapper.strNextStage)) {
                objNextWrapper.blnSuccess = true;
                objNextWrapper.blnBRERunRequired = true;
                return objNextWrapper;
            }
            objNextWrapper.blnSuccess = true;
            objNextWrapper.strMessage = Label.PreApproved_offer_BRE_Run_Skip_Message;
        }
        catch (Exception ex) {
            Log.error('BREHandler method checkForBRERun :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
            objNextWrapper.strMessage = ex.getMessage();
        }
        return objNextWrapper;
    }

    /*
    * @description - updateNexStageForPreApproved method to update Loan Application status when BRE Not Required and Pre-Approved Offer
    */
    @AuraEnabled
    public static BRENextPageWrapper updateNexStageForPreApproved (String loanAppId, String currentstage, String nextstage) {
        BRENextPageWrapper objNextWrapper = new BRENextPageWrapper();
        try {
            Loan_Application__c objLoanApp = [Select Id, ROI__c, Old_ROI__c from Loan_Application__c where Id =: loanAppId ];
            objLoanApp.Id = loanAppId;
            objLoanApp.Stage__c = nextstage;
            objLoanApp.Old_ROI__c = objLoanApp.ROI__c;
            update objLoanApp;
            objNextWrapper.blnSuccess = true;
        }
        catch (Exception ex) {
            Log.error('BREHandler method updateNexStageForPreApproved :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                objNextWrapper.strMessage = ex.getMessage().substringBetween(',',':');
            }
            else{
                objNextWrapper.strMessage = ex.getMessage();
            }
        }
        return objNextWrapper;
    }


    /**
     * @author - Sachin Hooda | 1st June 2023
      * @reference - SFAU-1356
     */
    @AuraEnabled
    public static void evaluateApplicantRiskCategory(Id loanId){
        Applicant__c[] applicants = getApplicantByLoanAppId(loanId);
        if(!applicants.isEmpty()){
            String riskCategory = Utility.getApplicantRiskCategoryBy(applicants[0]);
            //:TODO - confirm if the field can be combined for both 2W / 4W
            if(applicants[0].X2W_Risk_Category__c != riskCategory || applicants[0].X4W_Risk_Category__c != riskCategory){
                applicants[0].X2W_Risk_Category__c = riskCategory;
                applicants[0].X4W_Risk_Category__c = riskCategory;
            update applicants;
            }
        }
    }
    /**
     * @author - Sachin Hooda | 1st June 2023
     * @reference - SFAU-1356
     */
    public static Applicant__c[] getApplicantByLoanAppId(Id loanId){
        return [
            SELECT Id, Type_Of_Employment__c, Risk_Identification__c, High_Risk_Profile__c, X2W_Risk_Category__c, X4W_Risk_Category__c, Loan__r.RecordType.Name
            FROM Applicant__c
            WHERE Loan__c =: loanId AND IsInactive__c = FALSE
            WITH SECURITY_ENFORCED
        ];
    }

    /*
    @ method : this method check - if BRE run and latest status to move to next stage/page
    @ bug/US : SFAU-2669, SFAU-3099
    */
    @AuraEnabled
    public static BRENextPageWrapper validateToMoveNext (String strLoanId, String strRequestId) {
        Savepoint sp = Database.setSavepoint();
        BRENextPageWrapper objNext = new BRENextPageWrapper();
        objNext.blnSuccess = false;
        try {
            List<Loan_Application__c> lstLoan = new List<Loan_Application__c>();
            lstLoan = [Select id, BRE_ReRun_Required__c, BRE_Run_Request_Id__c, Product__c, Bre_Decision__c, Stage__c, Is_BRE_Credit_Subjectivity__c, Is_BRE_Pricing_Deviations__c, BRE_Selected_Scheme__c, DDE_stage_counter__c, Send_Back_To_RO_Stage__c, Previous_Stage__c, (Select Id, Is_Confirmed__c from BRE_Responses__r where BRE_Request_Id__c =: strRequestId order by Createddate desc LIMIT 1) from Loan_Application__c WHERE Id =: strLoanId AND BRE_Run_Request_Id__c =: strRequestId];
            if (lstLoan.isEmpty()) {
                //objNext.strMessage = Label.BRE_Screen_Rerun_Message;
                objNext.blnMoveNext = false;
                return objNext;
            }
            Loan_Application__c loanAppObj = lstLoan[0];
            objNext.blnMoveNext = false;
            
            String prod = 'A_'+loanAppObj.Product__c;
            String productType = '';
            String productLabel = '';
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productType = prodRecordType.RecordType__c;
                productLabel = prodRecordType.Label;
            }
            if (!lstLoan.isEmpty() && (lstLoan[0].BRE_ReRun_Required__c || (lstLoan[0].Stage__c == 'DDE' && (lstLoan[0].DDE_stage_counter__c == NULL || lstLoan[0].DDE_stage_counter__c == 0) && productType == 'Four Wheeler'))) {
                objNext.strMessage = Label.BRE_Screen_Rerun_Message;
                objNext.blnMoveNext = false;
            }
            else if (!lstLoan.isEmpty() && !lstLoan[0].BRE_ReRun_Required__c && lstLoan[0].BRE_Responses__r != NULL && lstLoan[0].BRE_Responses__r.size()>0 && lstLoan[0].BRE_Responses__r[0].Is_Confirmed__c) {
                String strStage = lstLoan[0].Stage__c;
                if(productType == 'Two Wheeler'){
                    if(loanAppObj.Stage__c == 'QDE' && (String.isBlank(loanAppObj.Send_Back_To_RO_Stage__c) || loanAppObj.Send_Back_To_RO_Stage__c == 'Credit')){
                        loanAppObj.Send_Back_To_RO_Stage__c = '';
                        loanAppObj.stage__c = 'CREDIT';
                    }
                    else if(loanAppObj.Stage__c == 'QDE' && loanAppObj.Send_Back_To_RO_Stage__c == 'Pricing'){
                        loanAppObj.Send_Back_To_RO_Stage__c = '';
                        loanAppObj.stage__c = 'PRICING';
                    }
                    else if(loanAppObj.Stage__c == 'DDE'){
                        // 5639 - Updated condition to move back to Previous stage only when case is sent from PSD or Ops Maker
                        // SFAU-5609 - Update the current stage from Previous Stage for TW and DDE

                        if(loanAppObj.Previous_Stage__c == 'PSD' || loanAppObj.Previous_Stage__c == 'Ops Maker'){
                        loanAppObj.stage__c = loanAppObj.Previous_Stage__c;
                        }else{
                            loanAppObj.stage__c = 'PSD';
                        }
                    }
                }
                else if(productType == 'Four Wheeler' || productType == 'Tractor' || productType == 'Commercial Vehicle'){
                    if(loanAppObj.Stage__c == 'QDE'){
                        loanAppObj.stage__c = 'DDE';
                    }
                    else if(loanAppObj.Stage__c == 'DDE' && (String.isBlank(loanAppObj.Send_Back_To_RO_Stage__c) || loanAppObj.Send_Back_To_RO_Stage__c == 'Credit')){
                        loanAppObj.Send_Back_To_RO_Stage__c = '';
                        loanAppObj.stage__c = 'CREDIT';
                    }
                    else if(loanAppObj.Stage__c == 'DDE' && (String.isBlank(loanAppObj.Send_Back_To_RO_Stage__c) || loanAppObj.Send_Back_To_RO_Stage__c == 'Pricing')){
                        loanAppObj.Send_Back_To_RO_Stage__c = '';
                        loanAppObj.stage__c = 'PRICING';
                    }
                }
                // Update Loan Application Stage
                if (strStage != loanAppObj.stage__c) {
                    system.debug(LoggingLevel.Info, 'Next .... ' + loanAppObj );
                    update loanAppObj;
                    objNext.blnMoveNext = true;
                    objNext.blnSuccess = true;
                }
            }
            else {
                objNext.strMessage = Label.BRE_Screen_Next_button_Error_Message;
                objNext.blnMoveNext = false;
            }
        }
        catch (Exception ex) {
            Database.rollback(sp);
            objNext.blnSuccess = false;
            objNext.strMessage = ex.getMessage();
        }
        system.debug(LoggingLevel.Info, 'Next .... ' + objNext );
        return objNext;
    }

    
    public class BRENextPageWrapper {
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage = '';
        @AuraEnabled
        public Boolean blnMoveNext = false;
        @AuraEnabled
        public String strNextStage = '';
        @AuraEnabled
        public String strCurrentStage = '';
        @AuraEnabled
        public Boolean blnBRERunRequired = false;
        @AuraEnabled
        public Boolean isMobileView = false;

    }

    /* Wrapper Class for BRE Run */
    public class BREWrapper {
        @AuraEnabled
        public Boolean hasShowCriteriaPermission = false;
        @AuraEnabled
        public Id intChecklistId {get;set;}
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strSuccessMessage {get;set;}
        @AuraEnabled
        public String strErrorMessage {get;set;}
        @AuraEnabled
        public String strRequestId {get;set;}
        @AuraEnabled
        public String strBREStatus {get;set;}
        @AuraEnabled
        public Boolean blnBREReceived = false;
        @AuraEnabled
        public Boolean blnRunBRE = false;
        @AuraEnabled
        public Boolean blnBREError = false;
        @AuraEnabled
        public Boolean isMobileView = false;

    }

    // Change SFAU-5482 - CUG II SFDC II BRE tags Missing for STP - Mohit
    public class BREApplicantWrapper {
        public Map<String,BREApplicants> mapWrapBREApplicant = NULL;
        public Map<String,Bureau_Results__c> mapWrapAppNameWithBureauResult = NULL;
    }

    public class CustomException extends Exception{}
    
    
}