/*****
* Class Name: BREHandlerService
* Description: Create BRE Payload
* Test Class Name: BREHandlerTest
* 
* LastModified Date    -   Last Modified By    -   Description / Bug
* May-31-2023          -   Mohit M.            -   
* June-02-2023         -   Mohit M.            -   Filter Source Type != 'CBS' in Address query
* June-8-2023          -   Mohit M.            -   SFAU-2651 - Skip Permanent Address for Non Individual
* June-14-2023         -   Mohit M.            -   SFAU-3078 - Reverse logic for isNegativeArea
* June-29-2023         -   Mohit M.            -   SFAU-3827 - Adding Luxury/Non Luxury check
* July-21-2023         -   Mohit M.            -   Add Applicant - Total_Monthly_Income_Sum__c
* July-27-2023         -   Mohit M.            -   SFAU-2916 - Skipe Address.Type validation for Permanent Address
* July-31-2023         -   Mohit M.            -   SFAU-4429 - add ltvonVehicleCost for Used and Cow Collateral
* Aug-02-2023          -   Mohit M.            -   place validation for locationSubType blank
* Aug-07-2023          -   Mohit M.            -   SFAU-4695 - Add 'Farmer' for Income Data
* Aug-26-2023          -   Mohit M.            -   SFAU-5003 - remove ltvonVehicleCost from Used condition and Add in General
* Aug-26-2023          -   Mohit M.            -   SFAU-4947 - Collateral Registration State Logic - from RTO Master
* Aug-27-2023          -   Mohit M.            -   SFAU-4933 - Prevent to run BRE when Cibi Score is NULL
* Sep-01-2023          -   Mohit M.            -   SFAU-5088 - Change isFinancialApplicant and toBeConsider mapping
* Sep-04-2023          -   Mohit M.            -   SFAU-5102 - Address Ownership
* Sept-06-2023         -   Mohit M.            -   SFAU-5116 - vehicleAgeAtEndOfTenor correction
* Sept-26-2023         -   Mohit M.            -   Where Clause in Bureau Query
* Sept-28-2023         -   Mohit M.            -   SFAU-5291 - isBlackListed fix
* Sept-28-2023         -   Mohit M.            -   BureauResponse Cibil Additional Match - method createCibilBureauMappingRequest
* Oct-10-2023          -   Mohit M.            -   SFAU-5163 - End Use of Vehicle usage
* Nov-09-2023          -   Mohit M.            -   SFAU-5482 - CUG II SFDC II BRE tags Missing for STP
* Dec-01-2023          -   Mohit M.            -   SFAU-5157 - CUG||4W|| SFDC || SVSH & SVOH issue for Branch TOPup
* Dec-05-2023          -   Mohit M.            -   SFAU-5701 - Branch TopUp
* Dec-20-2023          -   Kunal               -   SFAU-5716 - Kunal - Set isResicum for Office Address
* Dec-21-2023          -   Joshna Palla        -   Modified CIBIL segment to match XSD & removed commented code
*/
public class BREHandlerService {
    
    /**
* @method name: getBankAccountRecords
* @param1: loanAppId
*/
    public static List<Bank_Account_Records__c> getBankAccountRecords (String loanAppId) {
        List<Bank_Account_Records__c> lstBAD = new List<Bank_Account_Records__c>();
        try {
            lstBAD = [Select id,Average_12_Month_DPD__c,Highest_12_Month_DPD__c , OD_Limit_Sanctioned__c, Over_Limit_Amount__c, Over_Limit_DPD__c, Drawing_Power__c, Fixed_Interest_Rate__c,
                      Start_Date__c, End_Date__c, Next_Expiry_Date__c, isSecured__c, Renewal_Mode__c, Applicant__r.Name, RecordType.Name, Analysis_Data__c, Bank_Name__c, Account_Type__c,
                      Product_Code__c, Product__c, Branch_Name__c, Loan_Amount__c, POS__c, Applicant_Type__c, Tenure__c, No_of_Emi_Paid__c, EMI_Amount__c, 
                      Loan_Overdue_EMI__c, ROI__c, Current_Status__c, Account_Opening_Date__c, No_of_Bouncing__c, Include_In_Exposure__c, 
                      Next_Due_Date__c, InstallmentsOverDue__c, Sanctioned_Amount__c, DPP_Value__c, Current_Balance__c, ODCC_Limit__c, Last_Statement_Balance__c, Account_Number__c, Maturity_Date__c, Loan_Tenure__c from Bank_Account_Records__c where Applicant__r.Loan__c =: loanAppId and (Applicant__r.RecordType.Name = 'Applicant' OR Applicant__r.RecordType.Name = 'Co-Applicant' OR Applicant__r.RecordType.Name = 'Guarantor') ORDER BY Account_Opening_Date__c];// Applicant__r.RecordType.Name = 'Applicant'];
        }
        catch (Exception ex) {
            throw ex;
        }
        return lstBAD;
    }
    
    /**
* @method name: getDocumentChecklistRecords
* @param1: setApplicantId
*/
    public static Map<Id,Field_Investigation__c> getFieldInvestigationRecords (Set<Id> setApplicantIds) {
        Map<Id,Field_Investigation__c> mapFieldInvestigation = null;
        try {
            mapFieldInvestigation = new Map<Id,Field_Investigation__c>([SELECT Id, Applicant__c, Type_of_address__c, Applicant__r.loan__c,
                                                                        FI_Conducted_Date_Time__c, FI_Status__c, Stage__c, FI_Submission_Date_Time__c, 
                                                                        Applicant__r.Name
                                                                        FROM Field_Investigation__c where Applicant__c in: setApplicantIds and Re_Trigger__c = false]);
        }
        catch (Exception ex) {
            throw ex;
        }
        return mapFieldInvestigation;
    }
    
    /**
* @method name: getDocumentChecklistRecords
* @param1: setApplicantId
*/
    public static Map<Id,Document_Checklist__c> getDocumentChecklistRecords (Set<Id> setApplicantIds) {
        Map<Id,Document_Checklist__c> mapDocumentChecklist = null;
        try {
            mapDocumentChecklist = new Map<Id,Document_Checklist__c>([SELECT Id, Applicant__r.Driving_License_Issue_Date__c,Document__c, Document_Verification_Status__c, Applicant__r.Loan__c,Applicant__r.loan__r.RecordType.DeveloperName,Applicant__r.Driving_License_Expiry_Date__c,
                                                                      Document_Master__c, Document_Number__c, Document_Received_Date__c, Match_Type__c, Match_Percentage__c, 
                                                                      Document_Master__r.Document_Id__c, Document_Master__r.Document_Name__c, Document_Master__r.Document_Sub_Category__c, 
                                                                      Document_Master__r.OCR_Document_Type__c, Applicant__r.Name, Applicant__r.RecordType.DeveloperName, Address_Match_Score__c, 
                                                                      Name_Match_Score__c 
                                                                      FROM Document_Checklist__c where (Document_Number__c != NULL OR Match_Type__c != '') and Applicant__c in: setApplicantIds order by LastModifiedDate desc]);
        }
        catch (Exception ex) {
            throw ex;
        }
        return mapDocumentChecklist;
    }
    
    /**
* @method name: getLoanApplication
* @param1: loanAppRecId
*/
    public static List<Loan_Application__c> getLoanApplication (String loanAppRecId) {
        List<Loan_Application__c> lstLoanApp = new List<Loan_Application__c>();
        try {
            lstLoanApp = [SELECT Id , Dealer_Master__r.Repo_Funding__c ,Dealer_Master__r.Fi_Based__c,Dealer_Master__r.IRR__C,Name ,Expansion_Ratio__c   ,recordType.Name,Application_Id__c, Sourcing_Channel_Name__c, Sourcing_Channel_Name__r.Grading__c, Sourcing_Channel_Name__r.Dealer_Class__c, Application_Number__c, Lead_Id__c, Branch_Master__r.Account_Code__c, Branch_Name__c, Branch_Master__r.Hub_Code__c, 
                          Branch_Master__r.Region__r.Account_Name__c, CreatedDate, Stage__c, QDE_stage_counter__c, DDE_stage_counter__c, Dealer_Master__r.Category__c, Owner.Name,Owner_code__c,
                          Product__c, Scheme__c, Scheme__r.Scheme_Code__c, Scheme__r.Scheme_Name__c, Purpose_of_Loan__c, Nature_of_Loan__c, Emi_Frequency__c, 
                          Schedule_Type__c, Loan_Amount__c, EMI__c, Tenure__c, ROI__c, Type_of_Rate__c, Dealer_Master__r.Outlet_Name__c, Dealer_Master__r.Account_Code__c, Dealer_Master__r.Dealer_Class__c, 
                          Dealer_Master__r.Dealer_State__c, Dealer_Master__r.City__c, Sourcing_channel__c, Source_Name__c, Wheels_Exposure__c, Total_Exposure__c, Vehicle_use__c, Dealer_Master__r.Account_Name__c, Final_Exposure__c, 
                          Dealer_Master__r.Grading__c, toLabel(Product__c) loanproductname, Customer_Type__c, Branch_Master__r.Name,  Dealer_Master__r.Name, Original_Vehicle_Usage__c, // SFAU-5163 
                          Dealer_Master__r.Purchase_State__c, Dealer_Master__r.Purchase_City__c, Sub_Grade__c 
                          FROM Loan_Application__c where Id =: loanAppRecId];
        }
        catch (Exception ex) {
            throw new CustomException(ex);
        }
        return lstLoanApp;
    }
    
    public static boolean isPDSubmitted(String loanAppRecId){
        list<ContentDocumentLink> pdDoclist = [SELECT Id, ContentDocumentId 
                                               FROM ContentDocumentLink 
                                               WHERE ContentDocument.Title = 'Personal Discussion' 
                                               AND LinkedEntityId = :loanAppRecId];
        
        if(pdDoclist!=null && !pdDoclist.isEmpty())
            return true;
        return false;
    }
    
    public static List<Collateral__c> getCollateralRecords (String loanAppRecId) {
        List<Collateral__c> lstCollateral = new List<Collateral__c>();
        try {
            lstCollateral = [SELECT Id,Repo_Sale_Vehicle__c,Assessment_Method__c ,Attachment__c , HP__c  ,Built__c ,Body_Type__c ,Date_of_Delivery__c , Kilometer__c , Hours_Meter_Reading__c    ,Is_Registerable__c ,Body_Linked_with__c ,Repo_Sale_Date__c,Implement_Type__c ,Vehicle_Delivery__c  ,Collateral_Type__c  ,FMP__c ,Cost_to_be_Consider__c ,Approved_Customer_equity__c , toLabel(Collateral_Name__c),Max_Funding_Cap__c ,LTV_offered__c , RecordType.Name,Product__c,LTV__c, Make__c, Model__c, Variant__c, Vehicle_Color__c, Fuel_Type__c, Vehicle_Category__c, Manufacture_Year__c,
                             Engine_Category__c, LTV_offered_Ex_showroom__c, LTV_offered_On_road__c, LTV_offered_On_final_cost__c, HPN_With_Financiers_Name__c, Manufacture_year_month__c,
                             Current_Owner_Name__c, Owner_Serial_number__c, Registration_City__c, Accessories_Funding__c, Ex_Showroom_Price__c, Discount__c, 
                             Net_of_Discount_Price__c, Variance__c, Insurance__c, RTO_Taxes__c, Accessories__c, Other_Costs__c, On_Road_Price__c , Final_Cost__c,
                             Insurance_Value__c, Accessories_Value__c, LS_Value__c, Apportioned_Loan_Amount__c, Certified_Value__c, IBB_Value__c, Valuation_Amount__c,
                             IDV__c, Insurance_Expiry_Date__c, Vehicle_Cost__c, RTO_Tax_Value__c, State__c, Pincode__c, City__c, RC_Status__c, Approved_LTV__c, Luxury_Non_Luxury__c, 
                             Challan_Overdue_Amount__c, Rto_Code__c, Blacklist_Details__c, IsDetailsFromVahaanApi__c 
                             FROM Collateral__c 
                             WHERE (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels') AND Loan__c =: loanAppRecId AND Is_Deleted__c = false
                             ORDER BY CreatedDate DESC];
        }
        catch (Exception ex) {
            throw new CustomException(ex);
        }
        return lstCollateral;
    }
    
    public static List<Applicant__c> getApplicants(String loanAppRecId){
        return [SELECT Id , Driving_License_Issue_Date__c,RecordType.Name, Name, Date_of_Establishment__c,Customer_Type__c, loan__c,Loan__r.Customer_Grade__c, Loan__r.Name, Loan__r.Application_Id__c, Loan__r.Application_Number__c, Loan__r.Lead_Id__c,
                Loan__r.Branch_Master__r.Account_Code__c, Loan__r.Branch_Name__c, Loan__r.Branch_Master__r.Hub_Code__c, 
                Loan__r.Branch_Master__r.Region__r.Account_Name__c, Loan__r.CreatedDate, Loan__r.Stage__c, Loan__r.QDE_stage_counter__c, 
                Loan__r.DDE_stage_counter__c, Loan__r.Dealer_Master__r.Category__c, Loan__r.Owner.Name,Loan__r.Owner_code__c,
                Loan__r.Product__c, Loan__r.Scheme__c, Loan__r.Scheme__r.Scheme_Code__c, Loan__r.Scheme__r.Scheme_Name__c, Loan__r.Purpose_of_Loan__c, Loan__r.Nature_of_Loan__c, Loan__r.Emi_Frequency__c, 
                Loan__r.Schedule_Type__c, Loan__r.Loan_Amount__c, Loan__r.EMI__c, Loan__r.Tenure__c, Loan__r.ROI__c, Loan__r.Type_of_Rate__c,
                Loan__r.Dealer_Master__r.Outlet_Name__c, Loan__r.Dealer_Master__r.Account_Code__c, Loan__r.Dealer_Master__r.Dealer_Class__c, 
                Loan__r.Dealer_Master__r.Dealer_State__c, Loan__r.Dealer_Master__r.City__c, Loan__r.Sourcing_channel__c, Loan__r.Source_Name__c, Loan__r.Customer_Type__c, 
                Loan__r.Wheels_Exposure__c, Loan__r.Total_Exposure__c, Loan__r.Vehicle_use__c, Loan__r.Dealer_Master__r.Account_Name__c, Loan__r.Final_Exposure__c, Loan__r.Original_Vehicle_Usage__c, // SFAU-5163
                Loan__r.Dealer_Master__r.Grading__c, Loan__r.Dealer_Master__r.Purchase_City__c, High_risk_Profile__c, Loan__r.Sourcing_Channel_Name__c, Loan__r.Sourcing_Channel_Name__r.Grading__c, Loan__r.Sourcing_Channel_Name__r.Dealer_Class__c, 
                Education_qualification__c, Customer_Grade__c, Type_Of_Employment__c, Constitution_Type__c, Existing_Customer__c, DOB__c, Age__c, Gender__c, Marital_Status__c,
                No_of_Dependents__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c, Residential_Status__c,
                AU_Employee__c, AU_Employment_status__c, Phsically_challenged__c, Internal_Risk_Score__c, Is_Biometric_Address_Changed__c,
                CFR_Status__c, AML_Status__c, Related_Party_Status__c, Negative_Check_Status__c, Total_Exposure__c, Final_Exposure__c, Is_ETB_Address_Changed__c, 
                Is_Lead_To_Lead_Full_Match__c, Is_Lead_To_Lead_Partial_Match__c, Is_Lead_To_Customer_Partial_Match__c, KYC_Type__c, Email__c,
                IsEmailVerified__c, Date_of_Joining__c, X2W_Risk_Category__c, X4W_Risk_Category__c, Is_Customer_Details_Saved__c, Total_Monthly_Income_Sum__c, Free_Monthly_Cashflow__c, Total_Monthly_Income__c, Loan__r.Sub_Grade__c,    
                (SELECT Id, Name, Type_Of_Employment__c, Sub_Industry__c, Area_under_crop__c, Irrigartion_Source__c, Company_Name__c, Sector__c,
                 Industry__c, Occupation__c, Customer_Grade__c, Consider_Income_for_Eligibility__c, Total_Work_Experience__c, Method_Of_Assesment__c  
                 FROM Applicant_Financials__r WHERE RecordType.Name = 'Financial Parent' Order By CreatedDate DESC LIMIT 1),
                (SELECT Id, Document__c, Document_Verification_Status__c, Document_Master__c, Document_Received_Date__c, 
                 Document_Master__r.Document_Id__c, Document_Master__r.Document_Name__c, Document_Number__c
                 FROM Document_Checklists__r where Document_Number__c != NULL order by createddate desc),
                (SELECT Id, Address_Type__c, Pincode__c, District__c, City__c, State__c, Status__c, Type__c, 
                 Area_Type__c, Distance_from_Branch__c, Taluka__c, Negative_Area_Status__c, Stability__c, Area_Name__c, 
                 Office_Email_address__c, Office_Email_Verification_Status__c, Latest_Cibil_Address_Match_Score__c, Source_Type__c, 
                 Applicant__r.Last_CIBIL_Run_Date__c, Applicant__r.Risk_Identification__c FROM Addresses__r where Source_Type__c != 'Cibil' AND Source_Type__c != 'CART' AND Address_Type__c != '' AND Same_As__c != 'NA' ORDER By Source_Type__c)
                FROM Applicant__c 
                WHERE (RecordType.Name = 'Applicant' OR RecordType.Name = 'Co-Applicant' OR RecordType.Name = 'Guarantor') AND Customer_Type__c != NULL AND Loan__c =: loanAppRecId AND IsInactive__c = FALSE];
    }
    
    
    /* @method : createCibilBureauMappingRequest
* @param1: mapAppIdWithApplicant
* @param2: BRE Enums
* @param3: Loan Id
* will be unncomment for Cibil Additional Match
public static Map<String,BREApplicants> createCibilBureauMappingRequest (Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Id loanAppId) {
List<BREApplicants> lstApplicant = new List<BREApplicants>();
Map<String,String> mapApplicantWithResponse = new Map<String,String>();
Map<String,String> mapBureauWithApplicant = new Map<String,String>();
Map<Id,List<Id>> mapLinkEntityIdWithContentDocId = new Map<Id,List<Id>>();
Map<String,String> mapAdditionalApplResponse = new Map<String,String>();
Map<String,String> mapAdditonalWithApp = new Map<String,String>();
Set<String> setAppName = new Set<String>();
Boolean blnAllNonInd = true;
try{
List<Bureau_Results__c> lstBureauResult = [Select id, Bureau_Response__c, Applicant__c, Applicant__r.Name, Applicant__r.Customer_Type__c, Bureau_Score__c, Applicant__r.CIBIL_Rerun__c, Applicant__r.RecordType.DeveloperName, Applicant__r.Applicant__r.RecordType.DeveloperName, Applicant__r.Applicant__r.Name from Bureau_Results__c where Applicant__r.Loan__c =: loanAppId and Applicant__r.IsInactive__c = false AND (Bureau_Score__c != NULL OR Applicant__r.CIBIL_Rerun__c = true) order by createddate desc];
/*
for (BREApplicants obj : mapAppIdWithApplicant.values()) {
if (obj.customerType == 'I')
blnAllNonInd = false;
}
if (lstBureauResult.isEmpty() && blnAllNonInd == false)
throw new CustomException(System.Label.BRE_Bureau_Result_Error);
* /

for (Bureau_Results__c objBR : lstBureauResult) {
if (objBR.Applicant__r.Customer_Type__c == 'Non Individual') {
setAppName.contains(objBR.Applicant__r.Name);
continue;                    
}
if (objBR.Applicant__r.RecordType.DeveloperName == 'Additional_Match' && objBR.Applicant__r.Applicant__r.RecordType.DeveloperName != 'Additional_Match' && !mapAdditionalApplResponse.containsKey(objBR.Applicant__r.Applicant__r.Name) && objBR.Applicant__r.CIBIL_Rerun__c) {
throw new CustomException(System.Label.BRE_Bureau_Result_Error + ' Additional Match - ' + objBR.Applicant__r.Name); // Additional Cibil Rerun Label
}
if (!mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name) && objBR.Applicant__r.CIBIL_Rerun__c) {
throw new CustomException(System.Label.BRE_Bureau_Result_Error + ' - ' + objBR.Applicant__r.Name);
}
// SFAU-4933
if (!mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name) && objBR.Bureau_Score__c == NULL) {
throw new CustomException(System.Label.BRE_Bureau_Result_Error + ' - ' + objBR.Applicant__r.Name);
}
if (objBR.Bureau_Response__c != NULL && objBR.Applicant__r.RecordType.DeveloperName != 'Additional_Match' && !mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name)) {
mapApplicantWithResponse.put(objBR.Applicant__r.Name,objBR.Bureau_Response__c);
}
else if (objBR.Bureau_Response__c != NULL && objBR.Applicant__r.RecordType.DeveloperName == 'Additional_Match' && !mapAdditionalApplResponse.containsKey(objBR.Applicant__r.Applicant__r.Name)) {
mapApplicantWithResponse.put(objBR.Applicant__r.Name,objBR.Bureau_Response__c);
mapAdditionalApplResponse.put(objBR.Applicant__r.Applicant__r.Name,objBR.Bureau_Response__c);
mapAdditonalWithApp.put(objBR.Applicant__r.Name,objBR.Applicant__r.Applicant__r.Name);
}
else if (objBR.Bureau_Response__c == NULL && objBR.Applicant__r.RecordType.DeveloperName != 'Additional_Match' && !mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name)) {
mapApplicantWithResponse.put(objBR.Applicant__r.Name,'');
mapBureauWithApplicant.put(objBR.Id,objBR.Applicant__r.Name);
}
else if (objBR.Bureau_Response__c == NULL && objBR.Applicant__r.RecordType.DeveloperName == 'Additional_Match' && !mapAdditionalApplResponse.containsKey(objBR.Applicant__r.Applicant__r.Name)) {
mapApplicantWithResponse.put(objBR.Applicant__r.Name,'');
mapBureauWithApplicant.put(objBR.Id,objBR.Applicant__r.Name);
mapAdditonalWithApp.put(objBR.Applicant__r.Name,objBR.Applicant__r.Applicant__r.Name);
}
}

/* Logic to check Cibil Exist for all NI applicants * /
for (BREApplicants obj : mapAppIdWithApplicant.values()) {
if (obj.customerType != 'NI' && !mapApplicantWithResponse.containsKey(obj.applicantId)) {
throw new CustomException(System.Label.BRE_Bureau_Result_Error);
}
}

if (mapBureauWithApplicant.size() > 0) {
// Get record file IDs        
List<ContentDocumentLink> files = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :mapBureauWithApplicant.keySet() and ContentDocument.Title = 'Response'];
for (ContentDocumentLink obj: files) {
if (mapLinkEntityIdWithContentDocId.containsKey(obj.ContentDocumentId)) {
List<Id> lstContDocIdExist =  mapLinkEntityIdWithContentDocId.get(obj.ContentDocumentId);
lstContDocIdExist.add(obj.LinkedEntityId);
}
else {
List<Id> lstContDocIdExist =  new List<Id>();
lstContDocIdExist.add(obj.LinkedEntityId);
mapLinkEntityIdWithContentDocId.put(obj.ContentDocumentId,lstContDocIdExist);
}
}
List<ContentVersion>  docs  = new List<ContentVersion>();
if(files.size() > 0 && mapLinkEntityIdWithContentDocId.size() > 0) {
docs = [SELECT ContentDocumentId, VersionData 
FROM ContentVersion WHERE ContentDocumentId in: mapLinkEntityIdWithContentDocId.keySet() and Title = 'Response'];
for (ContentVersion obj: docs) {
if (mapLinkEntityIdWithContentDocId.containsKey(obj.ContentDocumentId)) {
for (Id objId : mapLinkEntityIdWithContentDocId.get(obj.ContentDocumentId)) {
String strLinkId = '' + objId;
String strAppName = '' + mapBureauWithApplicant.get(strLinkId); 
mapApplicantWithResponse.put(strAppName,obj.VersionData.toString());                
}
}
}
}
}
Map<String, String> mapAppIdWithResponse = new Map<String,String>();
String strResponse = '';
system.debug(LoggingLevel.Info,'In createCibilBureauMapping');
for (String objIntCheckList : mapApplicantWithResponse.keySet()) {
String strValue = mapApplicantWithResponse.get(objIntCheckList);
if (setAppName.contains(objIntCheckList) || (!mapAppIdWithApplicant.containsKey(objIntCheckList) && mapAdditonalWithApp.containsKey(objIntCheckList) && !mapAppIdWithApplicant.containsKey(mapAdditonalWithApp.get(objIntCheckList)))){
continue;
}

if(strValue == '' || strValue == NULL) {
throw new CustomException(System.Label.BRE_Bureau_Result_Error);
}
BREApplicants objAppWrap = mapAppIdWithApplicant.containsKey(objIntCheckList) ? mapAppIdWithApplicant.get(objIntCheckList) : (mapAdditonalWithApp.containsKey(objIntCheckList) && mapAppIdWithApplicant.containsKey(mapAdditonalWithApp.get(objIntCheckList)) ? mapAppIdWithApplicant.get(mapAdditonalWithApp.get(objIntCheckList)) : NULL);
if (objAppWrap == NULL) continue; 
//BREApplicants objAppWrap = mapAppIdWithApplicant.get(objIntCheckList);
BREApplicants.cls_cibilResponse objBureauResponse = new BREApplicants.cls_cibilResponse();
LosCibilResponseWrapper obj = (LosCibilResponseWrapper)JSON.deserialize(strValue, LosCibilResponseWrapper.class);
LosCibilResponseWrapper.cls_SucessResponse objSuccess = obj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.SucessResponse;
system.debug(LoggingLevel.Info,'objSuccess ' + objSuccess);
if (objSuccess == NULL)
continue;
// Account List
//List<LosCibilResponseWrapper.cls_Account> lstAcc = objSuccess.Account;
objBureauResponse.accountList = objSuccess.Account;

// Address List
//List<LosCibilResponseWrapper.cls_Address> lstAdd = objSuccess.Address;
objBureauResponse.addressList = objSuccess.Address;
// Employment List
//LosCibilResponseWrapper.cls_EmploymentSegment objEmpSeg = (objSuccess.EmploymentSegment != NULL && objSuccess.EmploymentSegment.size()>0 ? objSuccess.EmploymentSegment[0] : NULL);
objBureauResponse.employmentList = (objSuccess.EmploymentSegment != NULL && objSuccess.EmploymentSegment.size()>0 ? objSuccess.EmploymentSegment[0] : NULL);
// Enquiry List
//List<LosCibilResponseWrapper.cls_Enquiry> lstEnq = objSuccess.Enquiry;
objBureauResponse.enquiryList = objSuccess.Enquiry;
// Header List
//LosCibilResponseWrapper.cls_Header lstheader = (objSuccess.Header != NULL && objSuccess.Header.size()>0 ? objSuccess.Header[0] : NULL);
objBureauResponse.header = (objSuccess.Header != NULL && objSuccess.Header.size()>0 ? objSuccess.Header[0] : NULL);
// ID List
//List<LosCibilResponseWrapper.cls_IDSegment> lstIDSeg = objSuccess.IDSegment;
objBureauResponse.idList = JSON.serialize(objSuccess.IDSegment);
// NameSegment List
//LosCibilResponseWrapper.cls_NameSegment lstNameSeg = (objSuccess.NameSegment != NULL && objSuccess.NameSegment.size()>0 ? objSuccess.NameSegment[0] : NULL);
objBureauResponse.name = (objSuccess.NameSegment != NULL && objSuccess.NameSegment.size()>0 ? objSuccess.NameSegment[0] : NULL);
// Phone List
//List<LosCibilResponseWrapper.cls_TelephoneSegment> lstphone = objSuccess.TelephoneSegment;
objBureauResponse.phoneList = objSuccess.TelephoneSegment != NULL ? objSuccess.TelephoneSegment : null;
// Score List
//List<LosCibilResponseWrapper.cls_ScoreSegment> lstScore = objSuccess.ScoreSegment;
objBureauResponse.scoreList = objSuccess.ScoreSegment;
//MM - Review
objBureauResponse.isAddtionalMatch = mapAppIdWithApplicant.containsKey(objIntCheckList) ? false : true;
//MM - Review
objBureauResponse.status = 'Success';
system.debug(LoggingLevel.Info,'objBureauResponse.scoreList ' + objBureauResponse.scoreList);
objAppWrap.bureauResponse = objAppWrap.bureauResponse == NULL ? new BREApplicants.cls_bureauResponse() : objAppWrap.bureauResponse;
objAppWrap.bureauResponse.cibilResponse = objAppWrap.bureauResponse.cibilResponse == NULL ? new List<BREApplicants.cls_cibilResponse>() : objAppWrap.bureauResponse.cibilResponse;
objAppWrap.bureauResponse.cibilResponse.add(objBureauResponse);
mapAppIdWithApplicant.put(objIntCheckList,objAppWrap);
setAppName.add(objIntCheckList);
}
}
catch (Exception ex){
system.debug(LoggingLevel.Error, 'BREHandlerService createCibilBureauMappingRequest ' + ex + ' at Line Number ' + ex.getMessage() + ' --- ' + ex.getLineNumber());
Log.error('Error in BREHandlerService :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
throw ex;
}
return mapAppIdWithApplicant;
}
*/
    
    /* @method : createCibilBureauMappingRequest
* @param1: mapAppIdWithApplicant
* @param2: BRE Enums
* @param3: Loan Id 
*/ 
    public static BREHandler.BREApplicantWrapper createCibilBureauMappingRequest (Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Id loanAppId) {
        List<BREApplicants> lstApplicant = new List<BREApplicants>();
        Map<String,String> mapApplicantWithResponse = new Map<String,String>();
        Map<String,String> mapBureauWithApplicant = new Map<String,String>();
        Map<Id,List<Id>> mapLinkEntityIdWithContentDocId = new Map<Id,List<Id>>();
        Set<String> setAppName = new Set<String>();
        /* START - SFAU-5482 */
        Map<String,Bureau_Results__c> mapAppWithBureau = new Map<String,Bureau_Results__c>();
        BREHandler.BREApplicantWrapper objWrapApp = new BREHandler.BREApplicantWrapper();
        /* END - SFAU-5482 */
        Boolean blnAllNonInd = true;
        try{
            List<Bureau_Results__c> lstBureauResult = [Select id, Bureau_Response__c, Applicant__c, Applicant__r.Name, Applicant__r.Customer_Type__c, Bureau_Score__c, Applicant__r.CIBIL_Rerun__c, Applicant__r.RecordType.DeveloperName, Applicant__r.Applicant__r.RecordType.DeveloperName, Applicant__r.Applicant__r.Name, TelephoneNumber__c, Applicant__r.Mobile_Number__c, Bureau_Score_Date__c from Bureau_Results__c where Applicant__r.Loan__c =: loanAppId and Applicant__r.IsInactive__c = false AND (Bureau_Score__c != NULL OR Applicant__r.CIBIL_Rerun__c = true) order by createddate desc];
            
            for (Bureau_Results__c objBR : lstBureauResult) {
                if (objBR.Applicant__r.Customer_Type__c == 'Non Individual') {
                    setAppName.contains(objBR.Applicant__r.Name);
                    continue;                    
                }
                
                if (!mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name) && objBR.Applicant__r.CIBIL_Rerun__c && objBR.Applicant__r.RecordType.DeveloperName != 'Additional_Match') {
                    throw new CustomException(System.Label.BRE_Bureau_Result_Error + ' - ' + objBR.Applicant__r.Name);
                }
                // SFAU-4933
                if (!mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name) && objBR.Bureau_Score__c == NULL) {
                    throw new CustomException(System.Label.BRE_Bureau_Result_Error + ' - ' + objBR.Applicant__r.Name);
                }
                if (objBR.Bureau_Response__c != NULL && objBR.Applicant__r.RecordType.DeveloperName != 'Additional_Match' && !mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name)) {
                    mapApplicantWithResponse.put(objBR.Applicant__r.Name,objBR.Bureau_Response__c);
                    mapAppWithBureau.put(objBR.Applicant__r.Name,objBR);
                }
                else if (objBR.Bureau_Response__c == NULL && objBR.Applicant__r.RecordType.DeveloperName != 'Additional_Match' && !mapApplicantWithResponse.containsKey(objBR.Applicant__r.Name)) {
                    mapApplicantWithResponse.put(objBR.Applicant__r.Name,'');
                    mapBureauWithApplicant.put(objBR.Id,objBR.Applicant__r.Name);
                    mapAppWithBureau.put(objBR.Applicant__r.Name,objBR);
                }
            }
            
            /* Logic to check Cibil Exist for all NI applicants */
            for (BREApplicants obj : mapAppIdWithApplicant.values()) {
                if (obj.customerType != 'NI' && !mapApplicantWithResponse.containsKey(obj.applicantId)) {
                    throw new CustomException(System.Label.BRE_Bureau_Result_Error);
                }
            }
            
            if (mapBureauWithApplicant.size() > 0) {
                // Get record file IDs        
                List<ContentDocumentLink> files = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :mapBureauWithApplicant.keySet() and ContentDocument.Title = 'Response'];
                for (ContentDocumentLink obj: files) {
                    if (mapLinkEntityIdWithContentDocId.containsKey(obj.ContentDocumentId)) {
                        List<Id> lstContDocIdExist =  mapLinkEntityIdWithContentDocId.get(obj.ContentDocumentId);
                        lstContDocIdExist.add(obj.LinkedEntityId);
                    }
                    else {
                        List<Id> lstContDocIdExist =  new List<Id>();
                        lstContDocIdExist.add(obj.LinkedEntityId);
                        mapLinkEntityIdWithContentDocId.put(obj.ContentDocumentId,lstContDocIdExist);
                    }
                }
                List<ContentVersion>  docs  = new List<ContentVersion>();
                if(files.size() > 0 && mapLinkEntityIdWithContentDocId.size() > 0) {
                    docs = [SELECT ContentDocumentId, VersionData 
                            FROM ContentVersion WHERE ContentDocumentId in: mapLinkEntityIdWithContentDocId.keySet() and Title = 'Response'];
                    for (ContentVersion obj: docs) {
                        if (mapLinkEntityIdWithContentDocId.containsKey(obj.ContentDocumentId)) {
                            for (Id objId : mapLinkEntityIdWithContentDocId.get(obj.ContentDocumentId)) {
                                String strLinkId = '' + objId;
                                String strAppName = '' + mapBureauWithApplicant.get(strLinkId); 
                                mapApplicantWithResponse.put(strAppName,obj.VersionData.toString());                
                            }
                        }
                    }
                }
            }
            Map<String, String> mapAppIdWithResponse = new Map<String,String>();
            String strResponse = '';
            system.debug(LoggingLevel.Info,'In createCibilBureauMapping');
            for (String objIntCheckList : mapApplicantWithResponse.keySet()) {
                String strValue = mapApplicantWithResponse.get(objIntCheckList);
                
                if (setAppName.contains(objIntCheckList) || !mapAppIdWithApplicant.containsKey(objIntCheckList)){
                    continue;
                }
                if(strValue == '' || strValue == NULL) {
                    throw new CustomException(System.Label.BRE_Bureau_Result_Error);
                }
                
                BREApplicants objAppWrap = mapAppIdWithApplicant.get(objIntCheckList);
                BREApplicants.cls_cibilResponse objBureauResponse = new BREApplicants.cls_cibilResponse();
                LosCibilResponseWrapper obj = (LosCibilResponseWrapper)JSON.deserialize(strValue, LosCibilResponseWrapper.class);
                LosCibilResponseWrapper.cls_SucessResponse objSuccess = obj.DCResponse.ContextData.Applicants.Applicant.DsCibilBureau.Response.CibilBureauResponse.BureauResponseXml.SucessResponse;
                system.debug(LoggingLevel.Info,'objSuccess ' + objSuccess);
                if (objSuccess == NULL)
                    continue;
                // Account List
                //List<LosCibilResponseWrapper.cls_Account> lstAcc = objSuccess.Account;
                objBureauResponse.accountList = objSuccess.Account;
                
                // Address List
                objBureauResponse.addressList = objSuccess.Address; //new List<BREApplicants.cls_addressList>();//
                /*for (LosCibilResponseWrapper.cls_Address each : objSuccess.Address) {
BREApplicants.cls_addressList eachAddressElem = new BREApplicants.cls_addressList();
eachAddressElem.stateCode = each.StateCode;
eachAddressElem.pinCode = each.PinCode;
eachAddressElem.dateReported = each.DateReported;
eachAddressElem.addressLine3 = each.AddressLine3;
eachAddressElem.addressLine2 = each.AddressLine2;
eachAddressElem.addressLine1 = each.AddressLine1;
eachAddressElem.addressCategory = each.AddressCategory;
objBureauResponse.addressList.add(eachAddressElem);
}*/
                
                // Employment List
                //LosCibilResponseWrapper.cls_EmploymentSegment objEmpSeg = (objSuccess.EmploymentSegment != NULL && objSuccess.EmploymentSegment.size()>0 ? objSuccess.EmploymentSegment[0] : NULL);
                objBureauResponse.employmentList = (objSuccess.EmploymentSegment != NULL && objSuccess.EmploymentSegment.size()>0 ? objSuccess.EmploymentSegment[0] : NULL);
                // Enquiry List
                //List<LosCibilResponseWrapper.cls_Enquiry> lstEnq = objSuccess.Enquiry;
                objBureauResponse.enquiryList = objSuccess.Enquiry;
                // Header List
                objBureauResponse.header = (objSuccess.Header != NULL && objSuccess.Header.size()>0 ? objSuccess.Header[0] : NULL); //new BREApplicants.cls_header(); //
                /*if (objSuccess.Header != NULL && objSuccess.Header.size()>0) {
objBureauResponse.header = new BREApplicants.cls_header(); //(objSuccess.Header != NULL && objSuccess.Header.size()>0 ? objSuccess.Header[0] : NULL);
objBureauResponse.header.version = objSuccess.Header[0]?.Version;
objBureauResponse.header.subjectReturnCode = objSuccess.Header[0]?.SubjectReturnCode;
objBureauResponse.header.memberReferenceNumber = objSuccess.Header[0]?.ReferenceNumber;
objBureauResponse.header.enquiryControlNumber = objSuccess.Header[0]?.EnquiryControlNumber;
}*/
                // ID List
                objBureauResponse.idList = JSON.serialize(objSuccess.IDSegment);
                objBureauResponse.name = (objSuccess.NameSegment != NULL && objSuccess.NameSegment.size()>0 ? objSuccess.NameSegment[0] : NULL);
                // NameSegment List
                /*if (objSuccess.NameSegment != NULL && objSuccess.NameSegment.size()>0) {
objBureauResponse.name = new BREApplicants.cls_name(); //
objBureauResponse.name.gender = objSuccess.NameSegment[0]?.Gender;
objBureauResponse.name.dob = objSuccess.NameSegment[0]?.DateOfBirth;
}*/
                // Phone List
                objBureauResponse.phoneList = objSuccess.TelephoneSegment; /*new List<BREApplicants.cls_phoneList>();
for (LosCibilResponseWrapper.cls_TelephoneSegment each : objSuccess.TelephoneSegment) {
BREApplicants.cls_phoneList eachPhoneElem = new BREApplicants.cls_phoneList();
eachPhoneElem.telephoneType = each.TelephoneType;
eachPhoneElem.telephoneNumber = each.TelephoneNumber;
objBureauResponse.phoneList.add(eachPhoneElem);
}*/
                
                /* START - SFAU-5482 */
                if (objBureauResponse.phoneList != NULL && mapAppWithBureau.containsKey(objAppWrap.applicantId) && (objWrapApp.mapWrapAppNameWithBureauResult == NULL || !objWrapApp.mapWrapAppNameWithBureauResult.containsKey(objAppWrap.applicantId))) {
                    objWrapApp.mapWrapAppNameWithBureauResult = objWrapApp.mapWrapAppNameWithBureauResult == NULL ? new Map<String,Bureau_Results__c>() : objWrapApp.mapWrapAppNameWithBureauResult;
                    objWrapApp.mapWrapAppNameWithBureauResult.put(objAppWrap.applicantId,mapAppWithBureau.get(objAppWrap.applicantId));
                }
                /* END - SFAU-5482 */
                // Score List
                objBureauResponse.scoreList = objSuccess.ScoreSegment;
                /*if (objSuccess.ScoreSegment != null) {
objBureauResponse.scoreList = new List<BREApplicants.cls_scoreList>();//objSuccess.ScoreSegment;
for (LosCibilResponseWrapper.cls_ScoreSegment each : objSuccess.ScoreSegment) {
BREApplicants.cls_scoreList eachScoreElem = new BREApplicants.cls_scoreList();
eachScoreElem.scoreName = each.ScoreName;
eachScoreElem.scoreDate = each.ScoreDate;
eachScoreElem.scoreCardVersion = each.ScoreCardVersion;
eachScoreElem.scoreCardName = each.ScoreCardName;
eachScoreElem.score = each.Score;
eachScoreElem.reasonCode5 = each.ReasonCode5;
eachScoreElem.reasonCode4 = each.ReasonCode4;
eachScoreElem.reasonCode3 = each.ReasonCode3;
eachScoreElem.reasonCode2 = each.ReasonCode2;
eachScoreElem.reasonCode1 = each.ReasonCode1;
objBureauResponse.scoreList.add(eachScoreElem);
}
}*/
                
                //MM - Review
                objBureauResponse.isAddtionalMatch = mapAppIdWithApplicant.containsKey(objIntCheckList) ? false : true;
                //MM - Review
                objBureauResponse.status = 'Success'; // Joshna - updated per enum
                system.debug(LoggingLevel.Info,'objBureauResponse.scoreList ' + objBureauResponse.scoreList);
                objAppWrap.bureauResponse = objAppWrap.bureauResponse == NULL ? new BREApplicants.cls_bureauResponse() : objAppWrap.bureauResponse;
                objAppWrap.bureauResponse.cibilResponse = objAppWrap.bureauResponse.cibilResponse == NULL ? new List<BREApplicants.cls_cibilResponse>() : objAppWrap.bureauResponse.cibilResponse;
                objAppWrap.bureauResponse.cibilResponse.add(objBureauResponse);
                mapAppIdWithApplicant.put(objIntCheckList,objAppWrap);
                setAppName.add(objIntCheckList);
            }
            objWrapApp.mapWrapBREApplicant = mapAppIdWithApplicant;
        }
        catch (Exception ex){
            system.debug(LoggingLevel.Error, 'BREHandlerService createCibilBureauMappingRequest ' + ex + ' at Line Number ' + ex.getMessage() + ' --- ' + ex.getLineNumber());
            Log.error('Error in BREHandlerService :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
            throw ex;
        }
        return objWrapApp;
    }
    
    // 
    public static Map<String,BREApplicants> createBankAccountDetailRequestPayload (Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Id loanAppId, Map<String,Applicant_Financials_Details__c> mapFinParent, List<Bank_Account_Records__c> lstBAD) {
        try {
            List<BREApplicants> lstApplicant = new List<BREApplicants>();
            lstBAD = !lstBAD.isEmpty() ? lstBAD : [Select id, OD_Limit_Sanctioned__c, Over_Limit_Amount__c, Over_Limit_DPD__c, Drawing_Power__c, Fixed_Interest_Rate__c,
                                                   Start_Date__c, End_Date__c, Next_Expiry_Date__c, isSecured__c, Renewal_Mode__c, Applicant__r.Name, RecordType.Name, Analysis_Data__c, Bank_Name__c, Account_Type__c,
                                                   Product_Code__c, Product__c, Branch_Name__c, Loan_Amount__c, POS__c, Applicant_Type__c, Tenure__c, No_of_Emi_Paid__c, EMI_Amount__c, 
                                                   Loan_Overdue_EMI__c, ROI__c, Current_Status__c, Account_Opening_Date__c, No_of_Bouncing__c, Include_In_Exposure__c, 
                                                   Next_Due_Date__c, InstallmentsOverDue__c, Sanctioned_Amount__c, DPP_Value__c, Current_Balance__c, ODCC_Limit__c, Last_Statement_Balance__c, Account_Number__c, Loan_Tenure__c from Bank_Account_Records__c where Applicant__r.Loan__c =: loanAppId and (Applicant__r.RecordType.Name = 'Applicant' OR Applicant__r.RecordType.Name = 'Co-Applicant' OR Applicant__r.RecordType.Name = 'Guarantor')];// Applicant__r.RecordType.Name = 'Applicant'];
                                                       Map<String, String> mapAppIdWithResponse = new Map<String,String>();
            
            Map<String,Bank_Account_Records__c> mapApplicantWithBAD = new Map<String,Bank_Account_Records__c>();
            system.debug(LoggingLevel.Info,'In createBankAccountDetailRequest');
            if (!lstBAD.isEmpty()) {
                for (Bank_Account_Records__c objbankrecord : lstBAD) {
                    if (!mapAppIdWithApplicant.containsKey(objbankrecord.Applicant__r.Name)) {
                        continue;
                    }
                    BREApplicants objAppWrap = mapAppIdWithApplicant.get(objbankrecord.Applicant__r.Name);
                    String strAccountType = objbankrecord.Account_Type__c != null ? 
                        (mapOfBreEnumvalues.containsKey('Bank_Account_Records__c~Account_Type__c'+'~'+objbankrecord.Account_Type__c) ? 
                         mapOfBreEnumvalues.get('Bank_Account_Records__c~Account_Type__c'+'~'+objbankrecord.Account_Type__c).Enum_Value__c : '') : '';            
                    
                    if (objbankrecord.RecordType.Name == 'CART' && String.isNotBlank(objbankrecord.Analysis_Data__c)) {
                        Map<String,Object> mapDeserialize = new Map<String,Object>();
                        objAppWrap.bankAccountDetails = objAppWrap.bankAccountDetails == NULL ? new List<BREBankAccountDetails>() : objAppWrap.bankAccountDetails;
                        BREBankAccountDetails objBAD = new BREBankAccountDetails();
                        mapDeserialize = (Map<String,Object>)JSON.deserializeUntyped(objbankrecord.Analysis_Data__c);
                        objBAD.monthlyBalancesDetails = (Object)mapDeserialize.get('monthlyBalancesDetails');
                        objBAD.monthlyCreditsDetails = (Object)mapDeserialize.get('monthlyCreditsDetails');
                        //MM - Review Start
                        objBAD.bankName = objbankrecord.Bank_Name__c;
                        objBAD.accountType = strAccountType;            
                        // SFAU-5088 - toBeConsidered = true
                        //Boolean blnToBeConsider = (mapFinParent.containsKey(objbankrecord.Applicant__r.Name) ? (mapFinParent.get(objbankrecord.Applicant__r.Name).Consider_Income_for_Eligibility__c == 'Yes' ? true : false) : false);
                        objBAD.toBeConsidered = true;
                        objBAD.odLimit = objbankrecord.ODCC_Limit__c != NULL && objbankrecord.ODCC_Limit__c != '' ? Double.valueOf(objbankrecord.ODCC_Limit__c) : 0;
                        objBAD.status = 'OTHERS';
                        objAppWrap.bankAccountDetails.add(objBAD);
                    }
                    else if (objbankrecord.RecordType.Name == 'CBS' && objbankrecord.Account_Type__c == 'ODCC') {
                        //MM - Review - Optional
                        objAppWrap.existingCCODDetails = objAppWrap.existingCCODDetails == NULL ? new List<BREApplicants.cls_existingCCODDetails>() : objAppWrap.existingCCODDetails;
                        BREApplicants.cls_existingCCODDetails objCCOD = new BREApplicants.cls_existingCCODDetails();
                        objCCOD.accountType = objbankrecord.Account_Type__c != NULL ? objbankrecord.Account_Type__c : '';
                        objCCOD.limitAmount = objbankrecord.OD_Limit_Sanctioned__c != NULL ? objbankrecord.OD_Limit_Sanctioned__c + '' : '';
                        objCCOD.overLimitAmount = objbankrecord.Over_Limit_Amount__c != NULL ? objbankrecord.Over_Limit_Amount__c : 0;
                        objCCOD.overLimitDPD = objbankrecord.Over_Limit_DPD__c != NULL ? Integer.valueOf(objbankrecord.Over_Limit_DPD__c) : 0;
                        objCCOD.drawingPower = objbankrecord.Drawing_Power__c != NULL ? objbankrecord.Drawing_Power__c : 0;
                        objCCOD.fixedInterestRate = objbankrecord.Fixed_Interest_Rate__c != NULL ? objbankrecord.Fixed_Interest_Rate__c : 0;
                        objCCOD.startDate = objbankrecord.Account_Opening_Date__c != NULL ? objbankrecord.Account_Opening_Date__c : NULL;
                        objCCOD.endDate = objbankrecord.End_Date__c;
                        objCCOD.nextExpiryDate = objbankrecord.Next_Expiry_Date__c;
                        objCCOD.isSecured = objbankrecord.isSecured__c == true ? true : false;
                        objCCOD.renewalMode = objbankrecord.Renewal_Mode__c != NULL ? objbankrecord.Renewal_Mode__c : '';
                        objCCOD.ownership = 'SOW';
                        objAppWrap.existingCCODDetails.add(objCCOD);
                        //MM - Review - Optional END
                    }
                    else if (objbankrecord.RecordType.Name == 'CBS' && objbankrecord.Account_Type__c == 'Loan') {
                        objAppWrap.existingLoanAccountDetails = objAppWrap.existingLoanAccountDetails == NULL ? new List<BREApplicants.cls_existingLoanAccountDetails>() : objAppWrap.existingLoanAccountDetails;
                        BREApplicants.cls_existingLoanAccountDetails objLoanAccount = new BREApplicants.cls_existingLoanAccountDetails();
                        objLoanAccount.productCode = objbankrecord.Product_Code__c != NULL ? objbankrecord.Product_Code__c : '';
                        objLoanAccount.productName = objbankrecord.Product__c != NULL ? objbankrecord.Product__c : '';
                        objLoanAccount.branchName = objbankrecord.Branch_Name__c != NULL ? objbankrecord.Branch_Name__c : '';
                        objLoanAccount.loanAmount = objbankrecord.Loan_Amount__c != NULL ? objbankrecord.Loan_Amount__c : 0;
                        objLoanAccount.principalOutstandingBalance = objbankrecord.POS__c != NULL ? objbankrecord.POS__c : 0;
                        //Optional objLoanAccount.ownership = objbankrecord.Applicant_Type__c;
                        //Optional objLoanAccount.tenure = objbankrecord.Tenure__c != NULL ? Integer.valueOf(objbankrecord.Tenure__c) : 0;                        // SFAU-5157 - CUG||4W|| SFDC || SVSH & SVOH issue for Branch TOPup
                        // SFAU-5157 - CUG||4W|| SFDC || SVSH & SVOH issue for Branch TOPup
                        objLoanAccount.noOfEmiPaid = objbankRecord.No_of_Emi_Paid__c != NULL ? Integer.valueOf(objbankRecord.No_of_Emi_Paid__c) : 0;
                        objLoanAccount.emiAmount = objbankrecord.EMI_Amount__c != NULL ? objbankrecord.EMI_Amount__c : 0;
                        objLoanAccount.overdueEMI = objbankrecord.Loan_Overdue_EMI__c != NULL ? objbankrecord.Loan_Overdue_EMI__c : 0;
                        objLoanAccount.interestRate = objbankrecord.ROI__c != NULL ? objbankrecord.ROI__c : 0;
                        objLoanAccount.status = objbankrecord.Current_Status__c != NULL ? objbankrecord.Current_Status__c : '';
                        //Optional objLoanAccount.isNPAL12M = false;
                        objLoanAccount.openDate = objbankrecord.Account_Opening_Date__c != NULL ? objbankrecord.Account_Opening_Date__c : null;
                        objLoanAccount.noOfBounces = objbankrecord.No_of_Bouncing__c != NULL ? Integer.valueOf(objbankrecord.No_of_Bouncing__c) : 0;
                        objLoanAccount.currentDPD = 0;  //0
                        //Optional objLoanAccount.currentPDDRCAgening = 0; // Optional  //0
                        objLoanAccount.avgDelay = objbankrecord.Average_12_Month_DPD__c != null ? Integer.valueOf(objbankrecord.Average_12_Month_DPD__c) : 0;    //0
                        objLoanAccount.peakDelay = objbankrecord.Highest_12_Month_DPD__c != null ? Integer.valueOf(objbankrecord.Highest_12_Month_DPD__c) : 0;   //0
                        objLoanAccount.avgDelayL12M = objbankrecord.Average_12_Month_DPD__c != null ? Integer.valueOf(objbankrecord.Average_12_Month_DPD__c) : 0;    //0
                        objLoanAccount.peakDelayL12M = objbankrecord.Highest_12_Month_DPD__c != null ? Integer.valueOf(objbankrecord.Highest_12_Month_DPD__c) : 0;   //0
                        // SFAU-5088 - toBeConsidered = true
                        //objLoanAccount.toBeConsidered = objbankrecord.Include_In_Exposure__c == 'Yes' ? true : false;
                        objLoanAccount.toBeConsidered = true;
                        objLoanAccount.nextDueDate = objbankrecord.Next_Due_Date__c != NULL ? objbankrecord.Next_Due_Date__c : null;
                        objLoanAccount.installmentOverdue = objbankrecord.InstallmentsOverDue__c != NULL ? objbankrecord.InstallmentsOverDue__c + '' : '';
                        //Optional objLoanAccount.isNPAL6LM = true; // Optional
                        //Optional objLoanAccount.isNPAL3LM = 0; // Optional
                        objLoanAccount.isRCPending = true;
                        //Optinal objLoanAccount.noOfBouncesL6M = true;
                        //Optional objLoanAccount.noOfBouncesL3M = 0;
                        // SFAU-5701 - CUG||4W|| SFDC || SVSH & SVOH issue for Branch TOPup
                        objLoanAccount.accountNumber = String.isNotBlank(objbankrecord.Account_Number__c) ?  objbankrecord.Account_Number__c : '';
                        objLoanAccount.tenure = objbankrecord.Loan_Tenure__c != NULL ? Integer.valueOf(objbankrecord.Loan_Tenure__c) : 0;
                        objAppWrap.existingLoanAccountDetails.add(objLoanAccount);
                        //MM - Review - Optional END
                        
                    }
                    else if (objbankrecord.RecordType.Name == 'CBS' && objbankrecord.Account_Type__c == 'CC') {
                        //MM - Review - Optional
                        objAppWrap.existingCardAccountDetails = objAppWrap.existingCardAccountDetails == NULL ? new List<BREApplicants.cls_existingCardAccountDetails>() : objAppWrap.existingCardAccountDetails;
                        BREApplicants.cls_existingCardAccountDetails objExistCard = new BREApplicants.cls_existingCardAccountDetails();
                        objExistCard.productCode = objbankrecord.Product_Code__c != NULL ? objbankrecord.Product_Code__c : '';
                        objExistCard.cardStatus = objbankrecord.Current_Status__c != NULL ? objbankrecord.Current_Status__c : '';
                        //objTempMM.blockCode1 = 'string';  //blockCode10
                        //objTempMM.blockCode2 = 'string';  //blockCode20
                        objExistCard.accountOpenDate = objbankrecord.Account_Opening_Date__c != NULL ? objbankrecord.Account_Opening_Date__c : null;
                        objExistCard.outsatandingBalance = objbankrecord.Last_Statement_Balance__c != NULL && objbankrecord.Last_Statement_Balance__c != '' ? Double.valueOf(objbankrecord.Last_Statement_Balance__c.replace(',','')) : 0;  //18000
                        objExistCard.creditLimit = objbankrecord.Sanctioned_Amount__c != NULL ? objbankrecord.Sanctioned_Amount__c : 0;
                        //objTempMM.highBalanceUtilization = 0; //0
                        objExistCard.dpdValue = objbankrecord.DPP_Value__c != NULL ? objbankrecord.DPP_Value__c : '';
                        objExistCard.odAmount = '0';
                        objExistCard.ownership = 'SOW';
                        objAppWrap.existingCardAccountDetails.add(objExistCard);
                        
                        //MM - Review - Optional END
                    }
                    else if (objbankrecord.RecordType.Name == 'CBS' && objbankrecord.Account_Type__c == 'CASA') {
                        //MM - Review - Optional
                        objAppWrap.existingCASADetails = objAppWrap.existingCASADetails == NULL ? new List<BREApplicants.cls_existingCASADetails>() : objAppWrap.existingCASADetails;
                        BREApplicants.cls_existingCASADetails objTempMM1 = new BREApplicants.cls_existingCASADetails();
                        objTempMM1.accountType = objbankrecord.Account_Type__c != NULL ? objbankrecord.Account_Type__c : '';
                        objTempMM1.branchName = objbankrecord.Branch_Name__c != NULL ? objbankrecord.Branch_Name__c : '';
                        objTempMM1.accountOpeningDate = objbankrecord.Account_Opening_Date__c != NULL ? objbankrecord.Account_Opening_Date__c : null;
                        objTempMM1.currentBalance = objbankrecord.Current_Balance__c != NULL ? objbankrecord.Current_Balance__c : null;
                        objTempMM1.currentStatus = objbankrecord.Current_Status__c != NULL ? objbankrecord.Current_Status__c : '';
                        objAppWrap.existingCASADetails.add(objTempMM1);
                        //MM - Review - Optional END
                    }
                    mapAppIdWithApplicant.put(objbankrecord.Applicant__r.Name,objAppWrap);
                }
            }            
        }
        catch (Exception ex) {
            system.debug(LoggingLevel.Error, 'BREHandlerService createBankAccountDetailRequestPayload ' + ex + ' at Line Number ' + ' --- ' + ex.getLineNumber());
            Log.error('Error in BREHandlerService createBankAccountDetailRequestPayload :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),loanAppId);
            throw ex;
        }
        return mapAppIdWithApplicant;
    }
    
    
    
    
    // Calling this
    public static Map<String,BREApplicants> createEmploymentDetailsRequest (List<Applicant_Financials_Details__c> lstAFD, Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Map<String,Applicant_Financials_Details__c> mapFinParent,Map<String,Applicant_Financials_Details__c> mapFinAssessed,Map<String,Applicant_Financials_Details__c> mapSalDocument, Map<String,Applicant_Financials_Details__c> mapFinApplication) {
        String strApplicantId = '';
        try {
            for (String strKey : mapFinApplication.keySet()) {
                List<String> lstKeys = strKey.split('~');
                Applicant_Financials_Details__c afd = mapFinApplication.get(strKey);
                strApplicantId = afd.Applicant__c;
                String strTypeOfEmployment = afd.Applicant__r.Type_Of_Employment__c;
                BREApplicants applicantsObj = mapAppIdWithApplicant.get(afd.Applicant__r.Name);
                if (applicantsObj == NULL)
                    continue;
                String strEnumEmploymentType = '';
                if (String.isBlank(strTypeOfEmployment) && mapFinParent.containsKey(afd.Applicant__r.Name) && String.isNotBlank(mapFinParent.get(afd.Applicant__r.Name).Type_Of_Employment__c)) {
                    Applicant_Financials_Details__c afdParent = mapFinParent.get(afd.Applicant__r.Name);
                    strEnumEmploymentType = afdParent.Type_Of_Employment__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_');
                }
                else if (String.isNotBlank(strTypeOfEmployment)){
                    strEnumEmploymentType = strTypeOfEmployment != null ? 
                        (mapOfBreEnumvalues.containsKey('Applicant__c~Type_Of_Employment__c'+'~'+strTypeOfEmployment) ? 
                         mapOfBreEnumvalues.get('Applicant__c~Type_Of_Employment__c'+'~'+strTypeOfEmployment).Enum_Value__c : strTypeOfEmployment) : '';
                }
                else {
                    throw new CustomException (Label.BRE_Type_of_Employment_Missing_Msg);
                }
                if(afd.Applicant__r.loan__r.Collateral_Type__c == '10105' 
                   || afd.Applicant__r.loan__r.Collateral_Type__c == '10107' 
                   || afd.Applicant__r.loan__r.Collateral_Type__c == '10106' 
                   || afd.Applicant__r.loan__r.Collateral_Type__c == '10106'
                   || afd.Applicant__r.loan__r.Product__c  == '10204'
                   || afd.Applicant__r.loan__r.Product__c  == '10205'
                   || afd.Applicant__r.loan__r.Product__c  == '10206')
                    if(afd.Customer_Grade__c == 'Captive' && (afd.Method_Of_Assesment__c == 'Documented - Audited' || afd.Method_Of_Assesment__c == 'Documented - ITR')){
                        applicantsObj.customerSubGrade = 'WITH_FINANCIAL';
                    }
                else if(afd.Customer_Grade__c == 'Captive' && afd.Method_Of_Assesment__c == 'Assessed'){
                    applicantsObj.customerSubGrade = 'WITHOUT_FINANCIAL';
                }
                //applicantsObj.noOfCattle =  afd.No_of_Cattle__c == NULL ? Integer.valueOf(afd.No_of_Cattle__c) : 0;
                
                if (afd.RecordType.DeveloperName == 'Financial_Parent') {
                    
                    Applicant_Financials_Details__c objFinApp = afd;
                    map<String,String> RelationsMap = new map<String,String>();
                    boolean isrelated = false;
                    
                    BREEmployeeDetails employmentDetailsObj = new BREEmployeeDetails();
                    
                    /* START - SFAU-5088 - Change Mapping */
                    
                    //applicantsObj.isFinancialApplicant = (applicantsObj.applicantType == 'APPLICANT' ? true : (objFinApp.Consider_Income_for_Eligibility__c == 'Yes' ? true : false));
                    Common_Picklist__mdt commonPicklist = getCommonPicklistByFldName('Relationship_with_applicant__c').size() > 0 ? getCommonPicklistByFldName('Relationship_with_applicant__c')[0] : new Common_Picklist__mdt();
                    String relationshipWithBorrower = commonPicklist != null ? commonPicklist.Field_Value__c : '';
                    String[] relations = relationshipWithBorrower.split(',');
                    for(String rel :relations){
                        RelationsMap.put(rel,rel);
                    }
                    
                    if(RelationsMap.containskey(objFinApp.Applicant__r.Relationship_with_applicant__c))
                        isrelated = true;
                    
                    if(applicantsObj.applicantType == 'PRIMARY' ){
                        applicantsObj.isFinancialApplicant=true;
                    }
                    else if(applicantsObj.applicantType == 'CO_APPLICANT' && isrelated){
                        applicantsObj.isFinancialApplicant=true;
                    }
                    else if(applicantsObj.applicantType == 'CO_APPLICANT' && !isrelated){
                        applicantsObj.isFinancialApplicant=false;
                    }
                    else if(applicantsObj.applicantType == 'GUARANTOR'){
                        applicantsObj.isFinancialApplicant=false;
                    }
                    
                    
                    if(objFinApp.Applicant__r.loan__r.stage__c == 'Credit' && (objFinApp.Applicant__r.loan__r.recordType.name == 'Commercial Vehicle' || objFinApp.Applicant__r.loan__r.recordType.name == 'Construction Equipment')){
                        
                        if(applicantsObj.applicantType == 'PRIMARY' && ( objFinApp.Consider_Fleet_for_Eligibility__c=='Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        else if(applicantsObj.applicantType == 'CO_APPLICANT' && (objFinApp.Consider_Fleet_for_Eligibility__c=='Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        
                        else if(applicantsObj.applicantType == 'GUARANTOR' && (objFinApp.Consider_Fleet_for_Eligibility__c=='Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        
                    }
                    if(objFinApp.Applicant__r.loan__r.stage__c == 'Credit' && objFinApp.Applicant__r.loan__r.recordType.name =='Tractor'){
                        
                        if(applicantsObj.applicantType == 'PRIMARY' && (objFinApp.Consider_Income_for_Eligibility__c == 'Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        else if(applicantsObj.applicantType == 'CO_APPLICANT' && (objFinApp.Consider_Income_for_Eligibility__c == 'Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        
                        else if(applicantsObj.applicantType == 'GUARANTOR' && (objFinApp.Consider_Income_for_Eligibility__c == 'Yes')){
                            applicantsObj.isFinancialApplicant=true;
                        }
                        
                    }
                    /* END - SFAU-5088 - Change Mapping */
                    
                    
                    BREApplicants.BRECompanyBusinessDetails companyBusObj = new BREApplicants.BRECompanyBusinessDetails();
                    if ((strEnumEmploymentType == 'SALARIED' || strEnumEmploymentType == 'SALARIED_PRIVATE' || strEnumEmploymentType == 'SALARIED_GOVERNMENT') && applicantsObj.employmentDetails == NULL) {
                        if(String.isBlank(afd.Type_Of_Employment__c)) {
                            throw new CustomException (Label.BRE_Type_of_Employment_Missing_Msg);
                        }
                        // MM - REview
                        employmentDetailsObj.employmentType =  afd.Type_Of_Employment__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_');
                        employmentDetailsObj.employerName = objFinApp.Company_Name__c != null ? objFinApp.Company_Name__c : ''; 
                        //employmentDetailsObj.sector = objFinApp.Sector__c != null ? objFinApp.Sector__c : '';
                        //employmentDetailsObj.industry = objFinApp.Industry__c != null ? objFinApp.Industry__c : '';
                        //employmentDetailsObj.subIndustry = objFinApp.Sub_Industry__c != null ? objFinApp.Sub_Industry__c : '';
                        //employmentDetailsObj.occupation = objFinApp.Occupation__c != null ? objFinApp.Occupation__c : '';
                        //MM - Review
                        employmentDetailsObj.timeWithCurrentEmployer = String.isNotBlank(afd.Total_Work_Experience__c) ? Integer.valueOf(afd.Total_Work_Experience__c) : 0;
                        employmentDetailsObj.totalWorkExperience = String.isNotBlank(afd.Total_Work_Experience__c) ? Integer.valueOf(afd.Total_Work_Experience__c) : 0;
                        String strCompanyCategory = objFinApp.Company_Master__c != NULL && objFinApp.Company_Master__r.Company_Category__c != NULL ? objFinApp.Company_Master__r.Company_Category__c : '';
                        employmentDetailsObj.companyCategory = mapOfBreEnumvalues.containsKey('Generic_Master__c~Company_Category__c'+'~'+strCompanyCategory) ? 
                            mapOfBreEnumvalues.get('Generic_Master__c~Company_Category__c'+'~'+strCompanyCategory).Enum_Value__c : 'NON_CAT';
                        applicantsObj.employmentDetails = new BREEmployeeDetails();
                        applicantsObj.employmentDetails = employmentDetailsObj;
                    }
                    else if (applicantsObj.customerType == 'NI' || strEnumEmploymentType == 'SELF_EMPLOYED_NON_PROFESSIONAL' || strEnumEmploymentType == 'SELF_EMPLOYED_PROFESSIONAL'){
                        //companyBusObj.sector = objFinApp.Sector__c != null ? objFinApp.Sector__c : '';
                        //companyBusObj.industry = objFinApp.Industry__c != null ? objFinApp.Industry__c : '';
                        //companyBusObj.subIndustry = objFinApp.Sub_Industry__c != null ? objFinApp.Sub_Industry__c : '';
                        //companyBusObj.occupation = objFinApp.Occupation__c != null ? objFinApp.Occupation__c : '';
                        companyBusObj.dateOfIncorporation = objFinApp.Applicant__r.Date_of_Establishment__c != NULL ? objFinApp.Applicant__r.Date_of_Establishment__c : null;
                        companyBusObj.noOfYearsInBusiness = String.isNotBlank(afd.Total_Work_Experience__c) ? Integer.valueOf(afd.Total_Work_Experience__c) : 0;
                        applicantsObj.companyBusinessDetails = companyBusObj;
                    }
                    // SFAU-4695 - Add 'Farmer' for Income Data
                    if (strEnumEmploymentType == 'SALARIED' || strEnumEmploymentType == 'SALARIED_PRIVATE' || strEnumEmploymentType == 'SALARIED_GOVERNMENT' || strEnumEmploymentType == 'SELF_EMPLOYED_NON_PROFESSIONAL' || strEnumEmploymentType == 'SELF_EMPLOYED_PROFESSIONAL' || strEnumEmploymentType == 'UNEMPLOYED' || strEnumEmploymentType == 'FARMER') {
                        applicantsObj.incomeData = applicantsObj.incomeData == NULL ? new BREIncomeData() : applicantsObj.incomeData;
                        applicantsObj.incomeData.totalMonthlyIncome = objFinApp.Applicant__r.Total_Monthly_Income_Sum__c == NULL ? 0 : objFinApp.Applicant__r.Total_Monthly_Income_Sum__c;
                        applicantsObj.incomeData.monthlyObligation = objFinApp.Monthly_Obligation__c != NULL ? objFinApp.Monthly_Obligation__c : 0;
                        applicantsObj.incomeData.assessedIncome = objFinApp.Applicant__r.Free_Monthly_Cashflow__c == NULL ? 0 : objFinApp.Applicant__r.Free_Monthly_Cashflow__c;
                        applicantsObj.incomeData.documentIncome = objFinApp.Applicant__r.Total_Monthly_Income__c == NULL ? 0 : objFinApp.Applicant__r.Total_Monthly_Income__c;
                        applicantsObj.incomeData.verfiedAgriIncome = 0;
                        //R2 Change
                        applicantsObj.incomeData.documentSalariedIncome = afd.Salary_Received_in_Bank__c == NULL ? 0 : afd.Salary_Received_in_Bank__c;
                        applicantsObj.incomeData.documentITRIncome = afd.Annual_Net_Profit__c  == NULL ? 0 : afd.Annual_Net_Profit__c;
                        applicantsObj.incomeData.totalYearlyIncome = afd.Annual_Total_Income__c   == NULL ? 0 : afd.Annual_Total_Income__c;
                        applicantsObj.incomeData.yearlyObligation = afd.Monthly_Obligation__c    == NULL ? 0 : afd.Monthly_Obligation__c * 12 ;
                        applicantsObj.incomeData.verfiedAgriIncome = 0;
                        
                    }
                    
                    applicantsObj.customerSegment = objFinApp.Type_Of_Employment__c != null ? 
                        (mapOfBreEnumvalues.containsKey('Applicant__c~Type_Of_Employment__c'+'~'+objFinApp.Type_Of_Employment__c) ? 
                         mapOfBreEnumvalues.get('Applicant__c~Type_Of_Employment__c'+'~'+objFinApp.Type_Of_Employment__c).Enum_Value__c : objFinApp.Type_Of_Employment__c) : '';
                    
                    applicantsObj.customerSegmentSubType = String.isNotBlank(afd.Method_Of_Assesment__c) ? afd.Method_Of_Assesment__c.toUpperCase().replaceAll(' - ','_').replaceall('-','_').replaceAll(' ','_') : '';
                    
                }
                else if (afd.RecordType.DeveloperName == 'Assessed_No_Document') {
                    Applicant_Financials_Details__c objAssessed = afd;
                    //MM - Review - Mayur
                    if (strEnumEmploymentType == 'SALARIED' || strEnumEmploymentType == 'SELF_EMPLOYED_NON_PROFESSIONAL' || strEnumEmploymentType == 'SELF_EMPLOYED_PROFESSIONAL') {
                        applicantsObj.incomeData = applicantsObj.incomeData == NULL ? new BREIncomeData() : applicantsObj.incomeData;
                        applicantsObj.incomeData.assessedIncome = objAssessed.Applicant__r.Free_Monthly_Cashflow__c == NULL ? 0 : objAssessed.Applicant__r.Free_Monthly_Cashflow__c;
                        applicantsObj.incomeData.totalMonthlyIncome = objAssessed.Applicant__r.Total_Monthly_Income_Sum__c  == NULL ? 0 : objAssessed.Applicant__r.Total_Monthly_Income_Sum__c;
                        applicantsObj.incomeData.monthlyObligation = applicantsObj.incomeData.monthlyObligation == NULL ? 0 : applicantsObj.incomeData.monthlyObligation;
                        applicantsObj.incomeData.documentIncome = objAssessed.Applicant__r.Total_Monthly_Income__c == NULL ? 0 : objAssessed.Applicant__r.Total_Monthly_Income__c;
                        //R2 Change
                        // applicantsObj.incomeData.documentSalariedIncome = afd.Salary_Received_in_Bank__c == NULL ? 0 : afd.Salary_Received_in_Bank__c;
                        //applicantsObj.incomeData.documentITRIncome = afd.Annual_Net_Profit__c  == NULL ? 0 : afd.Annual_Net_Profit__c;
                        //applicantsObj.incomeData.totalYearlyIncome = afd.Annual_Total_Income__c   == NULL ? 0 : afd.Annual_Total_Income__c;
                        //applicantsObj.incomeData.yearlyObligation = afd.Monthly_Obligation__c    == NULL ? 0 : afd.Monthly_Obligation__c * 12 ;
                        //applicantsObj.incomeData.verfiedAgriIncome = 0;
                    }
                }
                else  if (afd.RecordType.DeveloperName == 'Salaried_Document') {
                    Applicant_Financials_Details__c objSalFin = afd;
                    //MM - Review - Mayur
                    if (strEnumEmploymentType == 'SALARIED' || strEnumEmploymentType == 'SELF_EMPLOYED_NON_PROFESSIONAL' || strEnumEmploymentType == 'SELF_EMPLOYED_PROFESSIONAL') {
                        applicantsObj.incomeData = applicantsObj.incomeData == NULL ? new BREIncomeData() : applicantsObj.incomeData;
                        applicantsObj.incomeData.documentIncome = objSalFin.Applicant__r.Total_Monthly_Income__c == NULL ? 0 : objSalFin.Applicant__r.Total_Monthly_Income__c;
                        applicantsObj.incomeData.assessedIncome = objSalFin.Applicant__r.Free_Monthly_Cashflow__c == NULL ? 0 : objSalFin.Applicant__r.Free_Monthly_Cashflow__c;
                        applicantsObj.incomeData.totalMonthlyIncome = objSalFin.Applicant__r.Total_Monthly_Income_Sum__c == NULL ? 0 : objSalFin.Applicant__r.Total_Monthly_Income_Sum__c;
                        applicantsObj.incomeData.monthlyObligation = applicantsObj.incomeData.monthlyObligation == NULL ? 0 : applicantsObj.incomeData.monthlyObligation;
                        applicantsObj.incomeData.verfiedAgriIncome = 0;
                        //R2 Change
                        applicantsObj.incomeData.documentSalariedIncome = afd.Salary_Received_in_Bank__c == NULL ? 0 : afd.Salary_Received_in_Bank__c;
                        applicantsObj.incomeData.documentITRIncome = afd.Annual_Net_Profit__c  == NULL ? 0 : afd.Annual_Net_Profit__c;
                        applicantsObj.incomeData.totalYearlyIncome = afd.Annual_Total_Income__c   == NULL ? 0 : afd.Annual_Total_Income__c;
                        applicantsObj.incomeData.yearlyObligation = afd.Monthly_Obligation__c    == NULL ? 0 : afd.Monthly_Obligation__c * 12 ;
                        applicantsObj.incomeData.verfiedAgriIncome = 0;
                    }
                }
                
                if ((afd.RecordType.DeveloperName == 'Farmer_Agriculture_Own_Land' || afd.RecordType.DeveloperName == 'Farmer_Agriculture_Rented_Land')) {
                    applicantsObj.landDetails = applicantsObj.landDetails == NULL ? new List<BREApplicants.BRELandDetails>() : applicantsObj.landDetails;
                    BREApplicants.BRELandDetails objLandDetails = new BREApplicants.BRELandDetails();
                    objLandDetails.ownedBy = 'SELF'; // static as per decision on May-3
                    objLandDetails.landSize = afd.Area_under_crop__c != NULL ? Integer.valueOf(afd.Area_under_crop__c) : 0;
                    objLandDetails.irrigationSource = afd.Irrigartion_Source__c != NULL ? afd.Irrigartion_Source__c.toUpperCase() : '';
                    applicantsObj.landDetails.add(objLandDetails);
                }
                
                //R2 Change
                if (afd.Applicant__r.loan__r.recordtype.developerName == 'Tractor') {
                    
                    /*  list<BREApplicants.BRECropDetails> cropList = new list<BREApplicants.BRECropDetails>();
BREApplicants.BRECropDetails   objCropDetails = new BREApplicants.BRECropDetails();
objCropDetails.cropName = afd.Crop_Details__c != null ? afd.Crop_Details__c : '';
objCropDetails.msp = afd.MSP__c != NULL ? Integer.valueOf(afd.MSP__c) : 0;
objCropDetails.areaUnderCrop = afd.Area_under_crop__c != NULL ? Integer.valueOf(afd.Area_under_crop__c) : 0;
objCropDetails.sowingMonth = afd.Sowing_Month__c != NULL ? Integer.valueOf(afd.Sowing_Month__c) : 0;
objCropDetails.harvestingMonth = afd.Harvesting_Month__c != NULL ? Integer.valueOf(afd.Harvesting_Month__c) : 0;
cropList.add(objCropDetails);
if(applicantsObj.landDetails!=null && !applicantsObj.landDetails.isEmpty())
applicantsObj.landDetails[0].cropDetails = cropList;*/
                }
                //MM - Review - Remove default value and confirm
                //applicantsObj.customerSegmentSubType = 'SALARIED';
                //MM - Optional applicantsObj.landInAcres = objFinApp.Area_under_crop__c != null ? 
                //MM - Optional Integer.valueOf(objFinApp.Area_under_crop__c) : null; // need to implement logic for acre conversion based on measure unit
                //MM - Optional applicantsObj.agriLandType = objFinApp.Irrigartion_Source__c != null ? 
                //MM - Optional (mapOfBreEnumvalues.containsKey('Applicant__c~Irrigartion_Source__c'+'~'+objFinApp.Irrigartion_Source__c) ? 
                //MM - Optional mapOfBreEnumvalues.get('Applicant__c~Irrigartion_Source__c'+'~'+objFinApp.Irrigartion_Source__c).Enum_Value__c : objFinApp.Irrigartion_Source__c) : ''; //LOV not matching with BRE Request enum
                
                mapAppIdWithApplicant.put(afd.Applicant__r.Name,applicantsObj);
            }
            system.debug(LoggingLevel.Info,'Applicants in Financial ');
        }
        catch (Exception ex) {
            system.debug(LoggingLevel.Error, 'BREHandlerService createEmploymentDetailsRequest ' + ex + ' at Line Number ' + ' --- ' + ex.getLineNumber());
            Log.error('Error in BREHandlerService createEmploymentDetailsRequest :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strApplicantId);
            throw ex;
        }
        return mapAppIdWithApplicant;
    }
    public static List<Common_Picklist__mdt> getCommonPicklistByFldName(String fldName) {
        
        List<Common_Picklist__mdt> commonPicklistLst = [SELECT id, Field_Value__c
                                                        FROM Common_Picklist__mdt where Field_Name__c =: fldName];
        return commonPicklistLst;
    }
    
    
    
    /**
* method: createApplicantAddressRequest
* description: create Address Request payload for BRE
*/
    public static Map<String,BREApplicants> createApplicantAddressRequest (Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Map<String,Address__c> mapAppIdWithAddress, Map<String,Location_Master__c> mapPinCodeWithLocationMaster, Map<String,Location_Master__c> mapPinCodeWithLocationMasterSingle) {
        String AddressId = '';
        Set<String> setApWithAddType = new Set<String>();
        try{
            for (String strKey : mapAppIdWithAddress.keySet()) {
                List<String> lstKey = strKey.split('~');
                BREApplicants applicantsObj = mapAppIdWithApplicant.get(lstKey[0]);
                if (applicantsObj == NULL)
                    continue;
                applicantsObj.address = applicantsObj.address == NULL ? new List<BREAddress>() : applicantsObj.address;
                Address__c objAddress = mapAppIdWithAddress.get(strKey);
                if(objAddress.Address_Type__c =='Land')
                    continue;
                AddressId = objAddress.Id;
                // START -Changes As per SFAU-2651
                if (applicantsObj.customerType == 'NI' && objAddress.Address_Type__c == System.Label.Address_Type_Permanent) {
                    mapAppIdWithApplicant.put(lstKey[0],applicantsObj);
                    continue;
                }
                // END -Changes As per SFAU-2651
                // Check and By Pass same type of Address under Applicant
                if (setApWithAddType.contains(lstKey[0] + '~' + objAddress.Address_Type__c)){
                    continue;
                }
                setApWithAddType.contains(lstKey[0] + '~' + objAddress.Address_Type__c);
                setApWithAddType.add(lstKey[0] + '~' + objAddress.Address_Type__c);
                BREAddress addressObj = new BREAddress();
                Location_Master__c objLocMaster = null;
                if (objAddress.Area_Name__c != NULL && objAddress.Area_Name__c != '')
                    objLocMaster = mapPinCodeWithLocationMaster.get(objAddress.Pincode__c+'~'+objAddress.Area_Name__c.toUpperCase());
                else {
                    objLocMaster = mapPinCodeWithLocationMasterSingle.get(objAddress.Pincode__c);
                }
                if (String.isBlank(objAddress.Address_Type__c)) {
                    throw new CustomException(System.Label.Address_Type_of_Address_Blank_Error_Msg);
                }
                else {
                    addressObj.addressType = objAddress.Address_Type__c.toUpperCase().replaceAll(' ','_');
                }
                addressObj.pinCode = String.isNotBlank(objAddress.Pincode__c) ? objAddress.Pincode__c : '';
                addressObj.district = String.isNotBlank(objAddress.District__c) ? objAddress.District__c : '';
                if(objAddress.Address_Type__c!='Land')
                    addressObj.city = String.isNotBlank(objAddress.City__c) ? objAddress.City__c : '';
                addressObj.state = objAddress.State__c != null ? 
                    (mapOfBreEnumvalues.containsKey('Address__c~State__c'+'~'+objAddress.State__c) ? 
                     mapOfBreEnumvalues.get('Address__c~State__c'+'~'+objAddress.State__c).Enum_Value__c : objAddress.State__c) : '';
                addressObj.taluka = objAddress.Taluka__c != NULL ? objAddress.Taluka__c : '';
                addressObj.country = 'IN'; //always India
                addressObj.distanceFromBranch = objAddress.Distance_from_Branch__c != null ? Double.valueOf(objAddress.Distance_from_Branch__c) : 0;
                // START - SFAU-3078 - Reverse value
                addressObj.isNegativeArea = String.isNotBlank(objAddress.Negative_Area_Status__c) && objAddress.Negative_Area_Status__c == 'POSITIVE' ? false : true;
                // END - SFAU-3078 - Reverse value
                if (String.isBlank(objAddress.Area_Type__c) && objAddress.Address_Type__c!='Land') {
                    throw new CustomException(System.Label.Address_Area_Type_Blank_Error_Msg);
                }
                if(objAddress.Address_Type__c!='Land')
                    addressObj.locationType = objAddress.Area_Type__c.toUpperCase();
                addressObj.locationSubType =  objLocMaster != NULL && String.isNotBlank(objLocMaster.CityType__c) ? objLocMaster.CityType__c.toUpperCase().replaceAll(' - ','_').replaceAll('-','_').replaceAll(' ','_') : '';//  'METRO';
                // place validation for locationSubType blank
                if (String.isBlank(addressObj.locationSubType) && objAddress.Address_Type__c!='Land') {
                    throw new CustomException(System.Label.BRE_Location_Sub_Type_Blank_Error_Msg);
                }
                /* - As per - SFAU-2916 - Skipe Address.Type validation for Permanent Address */
                if (String.isBlank(objAddress.Type__c)) {
                    objAddress.Type__c = Label.BRE_Default_Address_Type_Flat;
                }
                /*
else if (String.isBlank(objAddress.Type__c) && objAddress.Address_Type__c != System.Label.Address_Type_Permanent) {
throw new CustomException(System.Label.Address_Type_Blank_Error_Msg);
}
*/
                String strPropertyType = objAddress.Type__c != null && objAddress.Type__c != '' ? objAddress.Type__c.toUpperCase().replaceAll(' ','_').replaceAll(' - ','_').replaceAll('-','_') : '';
                addressObj.propertyType = strPropertyType == 'Others(Specify)' || strPropertyType == 'Others' ? 'OTHERS' : strPropertyType;
                
                if (String.isBlank(objAddress.Status__c) && objAddress.Address_Type__c!='Land'){
                    throw new CustomException(System.Label.Address_Ownership_Status_Blank_Error_Msg);
                }
                /* SFAU-5102 - START */
                if(objAddress.Address_Type__c!='Land')
                    addressObj.ownershipStatus = (String.isNotBlank(objAddress.Status__c) ? 
                                                  (mapOfBreEnumvalues.containsKey('Address__c~Status__c'+'~'+objAddress.Status__c) ? 
                                                   mapOfBreEnumvalues.get('Address__c~Status__c'+'~'+objAddress.Status__c).Enum_Value__c : '') : '');
                
                if (String.isBlank(addressObj.ownershipStatus) && objAddress.Address_Type__c!='Land') {
                    throw new CustomException(System.Label.BRE_Address_Ownership_Status_Error);
                }
                //addressObj.ownershipStatus = objAddress.Status__c.toUpperCase().replaceAll(' - ','_').replaceAll('/','_').replaceAll(' ','_');
                /* SFAU-5102 - END */
                
                /* - As per - SFAU-2916
if (String.isBlank(objAddress.Stability__c)) {
throw new CustomException(System.Label.Address_Stability_Blank_Error_Msg);
}
*/
                addressObj.timeAtCurrentAddress = String.isNotBlank(objAddress.Stability__c) ? Integer.valueOf(objAddress.Stability__c) * 12 : 0;
                addressObj.pinCodeCategory = objLocMaster != NULL ? objLocMaster.Working_Area__c == 'Yes' ? 'WORKING' : 'NON_WORKING' : 'NON_WORKING';//'WORKING';
                // SFAU-5716 - Kunal - Set isResicum for Office Address
                addressObj.isResiCumOffice = objAddress.Address_Type__c == 'Office' ? objAddress.Applicant__r.Risk_Identification__c : false;
                applicantsObj.address.add(addressObj);
                mapAppIdWithApplicant.put(lstKey[0],applicantsObj);
                
                // BREEmailDetails - Office
                if (String.isNotBlank(objAddress.Office_Email_address__c) && objAddress.Address_Type__c == 'Office') {
                    BREEmailDetails emailDetailsObj = new BREEmailDetails();
                    emailDetailsObj.emailType = 'OFFICE';
                    emailDetailsObj.isEmailIdVerified = objAddress.Office_Email_Verification_Status__c == 'Verified' ? true : false;
                    applicantsObj.emailDetails = applicantsObj.emailDetails == NULL ? new List<BREEmailDetails>() : applicantsObj.emailDetails;
                    applicantsObj.emailDetails.add(emailDetailsObj);
                    mapAppIdWithApplicant.put(lstKey[0],applicantsObj);
                }
                // BRE Address Karza Data
                if (objAddress.Latest_Cibil_Address_Match_Score__c != NULL && (objAddress.Address_Type__c == 'Current' || objAddress.Address_Type__c == System.Label.Address_Type_Permanent)) {
                    //if ((objAddress.Address_Type__c == 'Current' || objAddress.Address_Type__c == System.Label.Address_Type_Permanent)) {
                    BREApplicants.cls_karzaData objBREKarza = new BREApplicants.cls_karzaData();
                    objBREKarza.karzaVerificationType = Label.BRE_Karza_Verification_Type_Cibil;
                    objBREKarza.subType = objAddress.Address_Type__c == 'Current' ? Label.BRE_Karza_Cibil_Verification_Sub_Type_Current_Address : Label.BRE_Karza_Cibil_Verification_Sub_Type_Permanent_Address;
                    objBREKarza.scoreOrValue = Integer.valueOf(objAddress.Latest_Cibil_Address_Match_Score__c);
                    objBREKarza.matchType = objAddress.Latest_Cibil_Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Full_Match_Score) ? 'FULL_MATCH' :
                    objAddress.Latest_Cibil_Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Partial_Match_Score) ? 'PARTIAL_MATCH' : 'NO_MATCH';
                    objBREKarza.reportedDate = objAddress.Applicant__r.Last_CIBIL_Run_Date__c;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarza);
                    mapAppIdWithApplicant.put(lstKey[0],applicantsObj);
                }
            }
            
        }
        catch (Exception ex){
            System.Debug(LoggingLevel.Error,'Error in Address : ' + ex.getLineNumber());
            Log.error('Error in BRE Address :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),AddressId);
            throw ex;
        }
        return mapAppIdWithApplicant;
    }
    
    // Application Documents Request
    public static BRERequestWrapper createApplicationDocumentRequest(Map<String,BREApplicants> mapAppIdWithApplicant, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, Map<String,Document_Checklist__c> mapAppIdWithDocument, BRERequestWrapper breReqWrapObj) {
        Set<String> setAppAndDocName = new Set<String>();
        for (String strKey : mapAppIdWithDocument.keySet()) {
            List<String> lstKey = strKey.split('~');
            Document_Checklist__c doc = mapAppIdWithDocument.get(strKey);
            if (doc.Document_Number__c != NULL && doc.Document_Number__c != '') {
                BRERequestWrapper.cls_documentsReceived objDocReceived = new BRERequestWrapper.cls_documentsReceived ();
                objDocReceived.documentId = String.isNotBlank(doc.Document_Master__r.Document_ID__c) ? doc.Document_Master__r.Document_ID__c : '';
                objDocReceived.documentName = String.isNotBlank(doc.Document_Master__r.Document_Name__c) ? doc.Document_Master__r.Document_Name__c : '';
                objDocReceived.documentDescription = String.isNotBlank(doc.Document_Master__r.Document_Name__c) ? doc.Document_Master__r.Document_Name__c : '';
                objDocReceived.documentDate = System.today().addDays(-3);//doc.Document_Received_Date__c != NULL ? doc.Document_Received_Date__c : NULL;
                objDocReceived.isVerified = doc.Document_Verification_Status__c == 'Yes' ? true : false;
                objDocReceived.stabilityDate = objDocReceived.documentDate;
                breReqWrapObj.message.application.documentsReceived = breReqWrapObj.message.application.documentsReceived == NULL ? new List<BRERequestWrapper.cls_documentsReceived>() : breReqWrapObj.message.application.documentsReceived;
                breReqWrapObj.message.application.documentsReceived.add(objDocReceived);
            }
        }
        return breReqWrapObj;
    }
    
    // BRE Vehicle Requests
    public static BREProduct createBREUVehicleDetailRequest (List<Loan_Application__c> lstLoanApp, BREProduct productObj, List<Collateral__c> usedOrCashOnWheelsCollateralList,List<Collateral__c> collateralList,List<Collateral__c>  newCollateralList, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues, List<Charge__c> lstCharge, Map<String,Location_Master__c> mapPinCodeWithLocationMaster, Map<String,Location_Master__c> mapPinCodeWithLocationMasterSingle, Map<String,Location_Master__c> mapCityWithLocationMaster) {
        BREProduct.cls_vehicleDetails vehicleDetailsObj = new BREProduct.cls_vehicleDetails();
        BREProduct.cls_ImplementDetails ImplementDetailsObj = new BREProduct.cls_ImplementDetails();
        BREProduct.cls_AttachmentDetails AttachmentDetailsObj = new BREProduct.cls_AttachmentDetails();
        BREProduct.cls_usedVehicleCostDetails usedVehicleCostDetailsObj = new BREProduct.cls_usedVehicleCostDetails();
        BREProduct.cls_otherFundingItemsDetails otherFundingItemsDetailsObj = new BREProduct.cls_otherFundingItemsDetails();
        BREProduct.cls_newVehicleCostDetails newVehicleCostDetailsObj = new BREProduct.cls_newVehicleCostDetails();
        BREProduct.cls_dealerDetails dealerObj = new BREProduct.cls_dealerDetails();
        BREProduct.cls_sourcingDetails sourcingDetailsObj = new BREProduct.cls_sourcingDetails();
        BREProduct.cls_triggerDetails triggerDetailsObj = new BREProduct.cls_triggerDetails();
        system.debug('usedOrCashOnWheelsCollateralList ' + usedOrCashOnWheelsCollateralList.size());
        try {
            // Used Vehicle Request
            if (usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size() > 0) {
                usedVehicleCostDetailsObj.certifiedValue = usedOrCashOnWheelsCollateralList[0].Certified_Value__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].Certified_Value__c) : 0;
                usedVehicleCostDetailsObj.ibb = usedOrCashOnWheelsCollateralList[0].IBB_Value__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].IBB_Value__c) : 0; 
                usedVehicleCostDetailsObj.valuationAmount = usedOrCashOnWheelsCollateralList[0].Valuation_Amount__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].Valuation_Amount__c) : 0; 
                usedVehicleCostDetailsObj.idv = usedOrCashOnWheelsCollateralList[0].IDV__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].IDV__c) : 0; 
                usedVehicleCostDetailsObj.insurance = usedOrCashOnWheelsCollateralList[0].Insurance__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].Insurance__c) : 0; 
                usedVehicleCostDetailsObj.insuranceExpiryDate = usedOrCashOnWheelsCollateralList[0].Insurance_Expiry_Date__c != null ? usedOrCashOnWheelsCollateralList[0].Insurance_Expiry_Date__c : NULL; 
                usedVehicleCostDetailsObj.vehicleCost = usedOrCashOnWheelsCollateralList[0].Vehicle_Cost__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].Vehicle_Cost__c) : 0; 
                usedVehicleCostDetailsObj.finalCost = usedOrCashOnWheelsCollateralList[0].Final_Cost__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].Final_Cost__c) : 0;
                usedVehicleCostDetailsObj.isRepoFundingAllowed = lstLoanApp[0].Dealer_Master__r.Repo_Funding__c == 'Yes' ? true : false;
                usedVehicleCostDetailsObj.isRepoSoldVehicle = usedOrCashOnWheelsCollateralList[0].Repo_Sale_Vehicle__c == 'Yes' ? true : false;
                /* SFAU-4429 START */
                // Commented as per SFAU-5003
                //usedVehicleCostDetailsObj.ltvOnVehicleCost = usedOrCashOnWheelsCollateralList[0].LTV_offered_On_final_cost__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].LTV_offered_On_final_cost__c) : 0;
                /* SFAU-4429 END */
                /* START - SFAU-4947 */
                /*
Location_Master__c objLocMaster = null;
if (usedOrCashOnWheelsCollateralList[0].Registration_City__c != NULL && usedOrCashOnWheelsCollateralList[0].Registration_City__c != ''){
objLocMaster = mapCityWithLocationMaster.get(usedOrCashOnWheelsCollateralList[0].Registration_City__c.toUpperCase());
}
*/
                String strRegistrationState = '';
                if (usedOrCashOnWheelsCollateralList[0].Rto_Code__c != NULL && usedOrCashOnWheelsCollateralList[0].Rto_Code__c != ''){
                    String strRTOCode = usedOrCashOnWheelsCollateralList[0].Rto_Code__c;
                    List<Generic_Master__c> lstGenericMaster = new List<Generic_Master__c>();
                    lstGenericMaster = [Select id, RTOName__c, RTOCode__c, Zone__c, State__c from Generic_Master__c where recordtype.Name = 'RTO' and RTOCode__c =: strRTOCode and State__c != '' limit 1];
                    strRegistrationState = lstGenericMaster != NULL && lstGenericMaster.size() > 0 ? lstGenericMaster[0].State__c : '';
                }
                String prod = 'A_'+lstLoanApp[0].Product__c;
                String productTypeEnum = '';
                String loanTypeEnum = '';
                String ProductType = '';
                ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
                if(prodRecordType!=null){
                    productTypeEnum = prodRecordType.BRE_Product_Type_Enum__c ;
                    loanTypeEnum = prodRecordType.BRE_Loan_Type_Enum__c ;
                    ProductType = prodRecordType.RecordType__c;
                }
                if((System.Label.FW_R2_RecordTypes.contains(productType)&& ProductType!='')){
                     String strRTOCode = usedOrCashOnWheelsCollateralList[0].Rto_Code__c;
                    List<Generic_Master__c> lstGenMaster = new List<Generic_Master__c>();
                    lstGenMaster = [SELECT State__c FROM Generic_Master__c WHERE RTOName__c =:usedOrCashOnWheelsCollateralList[0].Registration_City__c and RTOCode__c =: strRTOCode and State__c != ''];
                    String strRegState = lstGenMaster != NULL && lstGenMaster.size() > 0 ? lstGenMaster[0].State__c : '';
                    usedVehicleCostDetailsObj.vehicleRegistrationState = strRegState;
                }else
                    usedVehicleCostDetailsObj.vehicleRegistrationState = strRegistrationState;
                /* END - SFAU-4947 */
                usedVehicleCostDetailsObj.vehicleRegistrationCity = usedOrCashOnWheelsCollateralList[0].Registration_City__c != null ? usedOrCashOnWheelsCollateralList[0].Registration_City__c  : '';
                String strManufactyear = collateralList[0].Manufacture_year_month__c != NULL && collateralList[0].Manufacture_year_month__c != '' ? collateralList[0].Manufacture_year_month__c.subString(0,4) : '';
                String strManufactMonth = collateralList[0].Manufacture_year_month__c != NULL && collateralList[0].Manufacture_year_month__c != '' ? collateralList[0].Manufacture_year_month__c.subString(4) : '';
                strManufactMonth = String.isNotBlank(strManufactMonth) ? strManufactMonth : '1'; // SFAU-5116
                if (strManufactyear != '' && strManufactMonth != '') {
                    Date newdate = Date.newInstance(Integer.valueOf(strManufactyear), Integer.valueOf(strManufactMonth), 1); // SFAU-5116
                    Integer loantenure = lstLoanApp[0].Tenure__c != NULL ? Integer.valueOf(lstLoanApp[0].Tenure__c) : 0;
                    Date newendtenuredate = System.today().addMonths(loantenure);
                    usedVehicleCostDetailsObj.vehicleAgeAtEndOfTenor = newdate.monthsBetween(newendtenuredate);
                }
                else {
                    usedVehicleCostDetailsObj.vehicleAgeAtEndOfTenor =  0;
                }
                usedVehicleCostDetailsObj.otherCosts = usedOrCashOnWheelsCollateralList[0].Other_Costs__c != null ? usedOrCashOnWheelsCollateralList[0].Other_Costs__c : 0;
                usedVehicleCostDetailsObj.rcExpiryDate = System.today().addYears(12);
                //MM - Review END
            }
            else {
                usedVehicleCostDetailsObj = NULL;
            }
            // Vehicle Other Funding Details
            if (collateralList != NULL && collateralList.size() > 0) {
                otherFundingItemsDetailsObj.insuranceAmount = collateralList[0].Insurance_Value__c != null ? Double.valueOf(collateralList[0].Insurance_Value__c) : 0;
                otherFundingItemsDetailsObj.lsAmount = collateralList[0].LS_Value__c != null ? Double.valueOf(collateralList[0].LS_Value__c) : 0;
                otherFundingItemsDetailsObj.apportionedLoanAmount = collateralList[0].Apportioned_Loan_Amount__c != null ? Double.valueOf(collateralList[0].Apportioned_Loan_Amount__c) : 0;
                otherFundingItemsDetailsObj.assecessoriesAmount = collateralList[0].Accessories_Value__c != null ? Double.valueOf(collateralList[0].Accessories_Value__c) : 0;
                otherFundingItemsDetailsObj.rtoAmount = collateralList[0].RTO_Taxes__c != null ? collateralList[0].RTO_Taxes__c : null; 
                
            }
            else {
                otherFundingItemsDetailsObj = NULL;
            }
            // New Vehicle Cost Details
            if(newCollateralList != NULL && newCollateralList.size() > 0){
                newVehicleCostDetailsObj.exShowroomPrice = newCollateralList[0].Ex_Showroom_Price__c  != null ? newCollateralList[0].Ex_Showroom_Price__c : 0;
                newVehicleCostDetailsObj.discount = newCollateralList[0].Discount__c != null ? newCollateralList[0].Discount__c : 0;
                newVehicleCostDetailsObj.netOfDiscountPrice = newCollateralList[0].Net_of_Discount_Price__c != null ? newCollateralList[0].Net_of_Discount_Price__c : 0;
                newVehicleCostDetailsObj.priceVariance = newCollateralList[0].Variance__c != null ? newCollateralList[0].Variance__c : 0;
                newVehicleCostDetailsObj.insurance = newCollateralList[0].Insurance__c != null ? newCollateralList[0].Insurance__c : 0;
                newVehicleCostDetailsObj.rtoTaxes = newCollateralList[0].RTO_Taxes__c != null ? newCollateralList[0].RTO_Taxes__c : 0;
                newVehicleCostDetailsObj.assecessories = newCollateralList[0].Accessories__c != null ? Double.valueOf(newCollateralList[0].Accessories__c) : 0;
                newVehicleCostDetailsObj.otherCosts = newCollateralList[0].Other_Costs__c != null ? newCollateralList[0].Other_Costs__c : 0;
                newVehicleCostDetailsObj.onRoadPrice = newCollateralList[0].On_Road_Price__c != null ? newCollateralList[0].On_Road_Price__c : 0;
                newVehicleCostDetailsObj.fairMarketValue = newCollateralList[0].FMP__c  != null ? Double.valueOf(newCollateralList[0].FMP__c)  : 0;
                newVehicleCostDetailsObj.costToBeConsidered = newCollateralList[0].Cost_to_be_Consider__c   != null ? Double.valueOf(newCollateralList[0].Cost_to_be_Consider__c)  : 0;
                newVehicleCostDetailsObj.assessmentMethod = collateralList[0].Assessment_Method__c!= null ? 
                    (mapOfBreEnumvalues.containsKey('Collateral__c~Assessment_Method__c'+'~'+collateralList[0].Assessment_Method__c) ? 
                     mapOfBreEnumvalues.get('Collateral__c~Assessment_Method__c'+'~'+collateralList[0].Assessment_Method__c).Enum_Value__c : collateralList[0].Assessment_Method__c) : '';
                newVehicleCostDetailsObj.approvedCustomerEquity = newCollateralList[0].Approved_Customer_equity__c    != null ? Double.valueOf(newCollateralList[0].Approved_Customer_equity__c)  : 0;
                otherFundingItemsDetailsObj.assecessoriesAmount = newCollateralList[0].Accessories_Value__c != null ? Double.valueOf(newCollateralList[0].Accessories_Value__c) : 0;
                otherFundingItemsDetailsObj.rtoAmount = newCollateralList[0].RTO_Taxes__c != null ? newCollateralList[0].RTO_Taxes__c : null; 
                newVehicleCostDetailsObj.finalCost = newCollateralList[0].Final_Cost__c != null ? newCollateralList[0].Final_Cost__c : 0;
                // Double approvedCustEqt = 0.00;
                //if(newCollateralList[0].Approved_Customer_equity__c == null || newCollateralList[0].Approved_Customer_equity__c=='')
                //  approvedCustEqt=0.00;
                //newVehicleCostDetailsObj.absoloutAmount = approvedCustEqt + newCollateralList[0].On_Road_Price__c + newCollateralList[0].LTV_offered__c;
            }
            else {
                newVehicleCostDetailsObj = NULL;
            }
            
            if (collateralList != NULL && collateralList.size() > 0) {
                String colType = collateralList[0].Collateral_Name__c;
                String isAttachment = collateralList[0].Attachment__c;
                if(colType == 'Implement'){
                    ImplementDetailsObj.implementType = collateralList[0].Implement_Type__c  != null ? 
                        (mapOfBreEnumvalues.containsKey('Collateral__c~Implement_Type__c'+'~'+collateralList[0].Implement_Type__c ) ? 
                         mapOfBreEnumvalues.get('Collateral__c~Implement_Type__c'+'~'+collateralList[0].Implement_Type__c).Enum_Value__c : collateralList[0].Implement_Type__c ) : ''; //R2 Change
                    ImplementDetailsObj.make = collateralList[0].make__c != null ? collateralList[0].make__c : '';
                    ImplementDetailsObj.model = collateralList[0].Model__c != null ? collateralList[0].Model__c : '';
                    ImplementDetailsObj.variant = collateralList[0].Variant__c != null ? collateralList[0].Variant__c : '';
                    ImplementDetailsObj.isImplementDeliveryStatus = collateralList[0].Vehicle_Delivery__c == 'Yes' ? true : false;
                    ImplementDetailsObj.exShowroomPrice = newCollateralList[0].Ex_Showroom_Price__c  != null ? newCollateralList[0].Ex_Showroom_Price__c : 0;
                    ImplementDetailsObj.netOfDiscountPrice = newCollateralList[0].Net_of_Discount_Price__c != null ? newCollateralList[0].Net_of_Discount_Price__c : 0;
                    ImplementDetailsObj.ltvOnImplement = collateralList[0].LTV_offered__c  !=null ? collateralList[0].LTV_offered__c : 0;
                    ImplementDetailsObj.discount = newCollateralList[0].Discount__c != null ? newCollateralList[0].Discount__c : 0;
                    ImplementDetailsObj.implementCategory = collateralList[0].Vehicle_Category__c  != null ? collateralList[0].Vehicle_Category__c  : '';                      
                    
                }
                else if(colType.contains('Construction Equipment') && isAttachment == 'Yes'){
                    AttachmentDetailsObj.make = collateralList[0].make__c != null ? collateralList[0].make__c : '';
                    AttachmentDetailsObj.model = collateralList[0].Model__c != null ? collateralList[0].Model__c : '';
                    AttachmentDetailsObj.variant = collateralList[0].Variant__c != null ? collateralList[0].Variant__c : '';
                    AttachmentDetailsObj.exShowroomPrice = collateralList[0].Ex_Showroom_Price__c  != null ? collateralList[0].Ex_Showroom_Price__c : 0;
                    AttachmentDetailsObj.netOfDiscountPrice = collateralList[0].Net_of_Discount_Price__c != null ? collateralList[0].Net_of_Discount_Price__c : 0;
                    AttachmentDetailsObj.ltvOnAttachment = collateralList[0].LTV_offered__c  !=null ? collateralList[0].LTV_offered__c : 0;
                    AttachmentDetailsObj.discount = collateralList[0].Discount__c != null ? collateralList[0].Discount__c : 0;
                    AttachmentDetailsObj.attachmentCategory = collateralList[0].Vehicle_Category__c  != null ? collateralList[0].Vehicle_Category__c  : '';                     
                    
                }
            }
            
            vehicleDetailsObj.make = collateralList[0].make__c != null ? collateralList[0].make__c : '';//'HERO';// for testing purpose - suziki not configured in dev, //collateralList[0].make__c != null ? collateralList[0].make__c : '';
            vehicleDetailsObj.model = collateralList[0].Model__c != null ? collateralList[0].Model__c : '';
            vehicleDetailsObj.variant = collateralList[0].Variant__c != null ? collateralList[0].Variant__c : '';
            vehicleDetailsObj.vehicleColour = collateralList[0].Vehicle_Color__c != null ? collateralList[0].Vehicle_Color__c : '';
            vehicleDetailsObj.fuelType = collateralList[0].Fuel_Type__c != null ? collateralList[0].Fuel_Type__c : ''; // LPG LOV not added in SF
            vehicleDetailsObj.isRegisterable = collateralList[0].Is_Registerable__c  != null ? collateralList[0].Is_Registerable__c  : false; 
            vehicleDetailsObj.maxFundingCap  = collateralList[0].Max_Funding_Cap__c   != null ? Double.valueOf(collateralList[0].Max_Funding_Cap__c) : 0; 
            vehicleDetailsObj.isVehicleDelivered   = collateralList[0].Vehicle_Delivery__c == 'Yes' ? true : false; 
            vehicleDetailsObj.bodyCost = collateralList[0].Final_Cost__c   != null ? collateralList[0].Final_Cost__c   : 0; 
            vehicleDetailsObj.ltvOfferedOnBody  = collateralList[0].LTV_offered__c   != null ? Double.valueOf(collateralList[0].LTV_offered__c ): 0; 
            
            if(collateralList[0].Body_Linked_with__c != null && collateralList[0].Body_Linked_with__c    != '' &&  (mapOfBreEnumvalues.containsKey('Collateral__c~Body_Linked_with__c'+'~'+collateralList[0].Body_Type__c  ) )){
                vehicleDetailsObj.bodyLinkedWith = mapOfBreEnumvalues.get('Collateral__c~Body_Linked_with__c'+'~'+collateralList[0].Body_Linked_with__c).Enum_Value__c; //R2 Change
            }
            vehicleDetailsObj.kmMeterReading = collateralList[0].Kilometer__c   != null ? Double.valueOf(collateralList[0].Kilometer__c)  : 0; 
            vehicleDetailsObj.hoursMeterReading = collateralList[0].Hours_Meter_Reading__c   != null ? collateralList[0].Hours_Meter_Reading__c   : 0; 
            vehicleDetailsObj.horsePower = collateralList[0].HP__c   != null ? Integer.valueOf(collateralList[0].HP__c) : 0; 
            if(collateralList[0].Built__c != null && collateralList[0].Built__c    != '' &&  (mapOfBreEnumvalues.containsKey('Collateral__c~Built__c'+'~'+collateralList[0].Built__c ) ) ){
                vehicleDetailsObj.chassisType = mapOfBreEnumvalues.get('Collateral__c~Built__c'+'~'+collateralList[0].Built__c ).Enum_Value__c; //R2 Change
            }
            if(collateralList[0].Body_Type__c != null && collateralList[0].Body_Type__c    != '' &&  (mapOfBreEnumvalues.containsKey('Collateral__c~Body_Type__c'+'~'+collateralList[0].Body_Type__c))){
                vehicleDetailsObj.bodyType =  mapOfBreEnumvalues.get('Collateral__c~Body_Type__c'+'~'+collateralList[0].Body_Type__c ).Enum_Value__c; //R2 Change
            }
            
            //START - SFAU-5163
            //vehicleDetailsObj.vehicleUsage = lstLoanApp[0].Vehicle_use__c != null ? lstLoanApp[0].Vehicle_use__c.toUpperCase()  : '';
            vehicleDetailsObj.vehicleUsage = String.isNotBlank(lstLoanApp[0].Original_Vehicle_Usage__c) ? lstLoanApp[0].Original_Vehicle_Usage__c.toUpperCase() : String.isNotBlank(lstLoanApp[0].Vehicle_use__c) ? lstLoanApp[0].Vehicle_use__c.toUpperCase() : '';
            //END - SFAU-5163
            vehicleDetailsObj.engineCategory = collateralList[0].Engine_Category__c != null ? collateralList[0].Engine_Category__c : '';
            vehicleDetailsObj.isAccessoriesFunding = collateralList[0].Accessories_Funding__c != null ? (collateralList[0].Accessories_Funding__c == 'Yes' ? true : false) : false;
            if (String.isBlank(vehicleDetailsObj.engineCategory)){
                throw new CustomException(Label.BRE_EngineCategory_Error_Msg);
            }
            //MM - Review - Start
            String strManufacturerYear = collateralList[0].Manufacture_year_month__c != NULL && collateralList[0].Manufacture_year_month__c != '' ? collateralList[0].Manufacture_year_month__c.subString(0,4) : '';
            String strManufacturerMonth = collateralList[0].Manufacture_year_month__c != NULL && collateralList[0].Manufacture_year_month__c != '' ? collateralList[0].Manufacture_year_month__c.subString(4) : '';
            
            
            vehicleDetailsObj.manufactureYear = getIntegerValue(strManufacturerYear);//collateralList[0].Manufacture_Year__c != null ? collateralList[0].Manufacture_Year__c : '';
            vehicleDetailsObj.manufactureMonth = getIntegerValue(strManufacturerMonth);//collateralList[0].Manufacture_year_month__c != null ? collateralList[0].Manufacture_year_month__c : ''; 
            vehicleDetailsObj.challanOverdueAmount = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 && usedOrCashOnWheelsCollateralList[0].Challan_Overdue_Amount__c != NULL ? usedOrCashOnWheelsCollateralList[0].Challan_Overdue_Amount__c : 0;
            vehicleDetailsObj.ltvOnRoad = collateralList[0].LTV_offered_On_road__c != null ? collateralList[0].LTV_offered_On_road__c : 0;
            // Change As per UAT Defect
            vehicleDetailsObj.maxLTV = String.isNotBlank(collateralList[0].Approved_LTV__c) ? Double.valueOf((collateralList[0].Approved_LTV__c).replace('%', '')) : 0;
            /* SFAU-5003 START */
            vehicleDetailsObj.ltvOnVehicleCost = (usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 && usedOrCashOnWheelsCollateralList[0].LTV_offered_On_final_cost__c != null ? Double.valueOf(usedOrCashOnWheelsCollateralList[0].LTV_offered_On_final_cost__c) : (collateralList[0].LTV_offered_On_final_cost__c != NULL ? collateralList[0].LTV_offered_On_final_cost__c : 0));
            /* SFAU-5003 END */
            
            /* START - SFAU-5482 - CUG II SFDC II BRE tags Missing for STP */
            vehicleDetailsObj.isVahanDataFetched = (usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0  ? usedOrCashOnWheelsCollateralList[0].IsDetailsFromVahaanApi__c : collateralList[0].IsDetailsFromVahaanApi__c);
            /* START - SFAU-5482 - CUG II SFDC II BRE tags Missing for STP */
            
            //MM - Review - End
            //Added by Gaurav for productType and loanType
            String prod = 'A_'+lstLoanApp[0].Product__c;
            String productTypeEnum = '';
            String loanTypeEnum = '';
            String strProductType = '';
            ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);
            if(prodRecordType!=null){
                productTypeEnum = prodRecordType.BRE_Product_Type_Enum__c ;
                loanTypeEnum = prodRecordType.BRE_Loan_Type_Enum__c ;
                strProductType = prodRecordType.RecordType__c;
            }
            productObj.productType = productTypeEnum; //'TW_NEW'
            
            //--------------- NEED TO CHANGE -----------ONLY FOR TESTING PURPOSE---/
            productObj.subProductType = String.isNotBlank(collateralList[0].Collateral_Name__c) ? collateralList[0].Collateral_Name__c.toUpperCase().replaceAll(' - ','_').replaceAll('- ','_').replaceAll(' -','_').replaceAll(' ','_') : '';
            
            productObj.productCode = collateralList[0].Product__c;
            
            productObj.loanType = loanTypeEnum; //'NEW'
            productObj.requestedLoanAmount = lstLoanApp[0].Loan_Amount__c != NULL ? lstLoanApp[0].Loan_Amount__c : 0;
            productObj.requestedInstallmentAmount = lstLoanApp[0].EMI__c != NULL ? lstLoanApp[0].EMI__c : 0;
            productObj.requestedTenor = lstLoanApp[0].Tenure__c != NULL ? Integer.valueOf(lstLoanApp[0].Tenure__c) : 0;
            productObj.requestedROI = lstLoanApp[0].ROI__c != NULL ? Double.valueOf(lstLoanApp[0].ROI__c) : 0; 
            productObj.roiAsPerMaster = 0; // Static as per call May-3 MM Review
            productObj.requestedPF = lstCharge != NULL && lstCharge.size() > 0 && lstCharge[0].Total_Amount__c != NULL ? lstCharge[0].Total_Amount__c : 0;  // MM Review
            productObj.existingWheelExposure = lstLoanApp[0].Wheels_Exposure__c != NULL ? lstLoanApp[0].Wheels_Exposure__c : 0;
            productObj.existingTWExposure = lstLoanApp[0].Wheels_Exposure__c != NULL ? lstLoanApp[0].Wheels_Exposure__c : 0;
            productObj.existingTotalExposure = lstLoanApp[0].Final_Exposure__c != NULL ? lstLoanApp[0].Final_Exposure__c : 0;
            productObj.existingGroupExposure = lstLoanApp[0].Final_Exposure__c; // Optional - Temp Comment    //0
            productObj.totalExposure = lstLoanApp[0].Final_Exposure__c;
            productObj.apportionedLoanAmount = collateralList[0].Apportioned_Loan_Amount__c;
            productObj.noOfUnits = collateralList.size();
            /*  if(lstLoanApp[0].EMI_Frequency__c != null && lstLoanApp[0].EMI_Frequency__c != ''){
productObj.instalmentFreq = mapOfBreEnumvalues.get('Loan_Application__c~EMI_Frequency__c'+'~'+lstLoanApp[0].EMI_Frequency__c).Enum_Value__c; //R2 Change
}*/
            
            if(collateralList[0].Date_of_Delivery__c  != null){
                productObj.deliveryDate = String.valueOf(collateralList[0].Date_of_Delivery__c); //R2 Change
            }            
            productObj.schemeId = lstLoanApp[0].Scheme__c != NULL && lstLoanApp[0].Scheme__r.Scheme_Code__c != NULL ? lstLoanApp[0].Scheme__r.Scheme_Code__c : '';
            productObj.rateType = lstLoanApp[0].Type_of_Rate__c != null ? lstLoanApp[0].Type_of_Rate__c.toUpperCase() : '';
            if (String.isBlank(productObj.rateType)) {
                if(strProductType == 'Two Wheeler' && (lstLoanApp[0].Stage__c == 'Credit' || lstLoanApp[0].stage__c == 'Pricing')){
					productObj.rateType = 'FIXED';                    
                }
                else if (lstLoanApp[0].Stage__c == 'QDE') {
                    productObj.rateType = 'FIXED';
                }
            }
            if (String.isBlank(productObj.rateType)) {
                throw new CustomException(Label.BRE_Rate_Type_Error_Message);
            }
            
            //dealerDetails data mapping - Optional
            if (lstLoanApp[0].Dealer_Master__c != NULL) {
                dealerObj.dealerName = lstLoanApp[0].Dealer_Master__c != NULL ? lstLoanApp[0].Dealer_Master__r.Name : '';
                dealerObj.outletName = lstLoanApp[0].Dealer_Master__c != NULL ? lstLoanApp[0].Dealer_Master__r.Name : '';
                dealerObj.dealerCode = lstLoanApp[0].Dealer_Master__c != NULL ? lstLoanApp[0].Dealer_Master__r.Account_Code__c : '';
                dealerObj.dealerCategory = lstLoanApp[0].Dealer_Master__c != NULL && lstLoanApp[0].Dealer_Master__r.Grading__c != NULL && lstLoanApp[0].Dealer_Master__r.Grading__c != System.Label.Master_Grading_NA ? lstLoanApp[0].Dealer_Master__r.Grading__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_') : System.Label.Master_Grading_BRE_NA;
                //---------- TESTING --------- NEED TO CHANGE ---------------------//
                dealerObj.dealerClass = String.isNotBlank(lstLoanApp[0].Dealer_Master__r.Dealer_Class__c) ? lstLoanApp[0].Dealer_Master__r.Dealer_Class__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_').replaceAll('/','_') : 'NON_TA';
                
                //---------- TESTING --------- NEED TO CHANGE ---------------------//
                dealerObj.dealerState = String.isNotBlank(lstLoanApp[0].Dealer_Master__r.Purchase_State__c) ? lstLoanApp[0].Dealer_Master__r.Purchase_State__c : '';
                dealerObj.dealerCity = String.isNotBlank(lstLoanApp[0].Dealer_Master__r.Purchase_City__c) ? lstLoanApp[0].Dealer_Master__r.Purchase_City__c : '';
                dealerObj.isDealerEligibleForFIBased = lstLoanApp[0].Dealer_Master__r.Fi_Based__c == 'Yes' ? true : false; 
                dealerObj.dealerRackRate = lstLoanApp[0].Dealer_Master__r.IRR__c !=null ? lstLoanApp[0].Dealer_Master__r.IRR__c : 0;
            }
            else {
                dealerObj = NULL;
            }
            sourcingDetailsObj.sourcingChannel = String.isNotBlank(lstLoanApp[0].Sourcing_channel__c) ? lstLoanApp[0].Sourcing_channel__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_').replaceAll('/','_') : '';
            sourcingDetailsObj.sourcingCategory = lstLoanApp[0].Sourcing_Channel_Name__c != NULL && lstLoanApp[0].Sourcing_Channel_Name__r.Grading__c != NULL && lstLoanApp[0].Sourcing_Channel_Name__r.Grading__c != System.Label.Master_Grading_NA ? lstLoanApp[0].Sourcing_Channel_Name__r.Grading__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_') : System.Label.Master_Grading_BRE_NA;
            sourcingDetailsObj.sourcingClass = String.isNotBlank(lstLoanApp[0].Sourcing_Channel_Name__r.Dealer_Class__c) ? lstLoanApp[0].Sourcing_Channel_Name__r.Dealer_Class__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_').replaceAll('/','_') : 'NON_TA';
            
            //MM - Review START - Mandatory
            // Trigger Details
            triggerDetailsObj.roTriggerType = 'NA';
            triggerDetailsObj.branchTriggerType = 'NA';
            triggerDetailsObj.dealerTriggerType = 'NA';
            triggerDetailsObj.sourcingTriggerType = 'NA';
            triggerDetailsObj.roTriggerLevel = 'L1';
            triggerDetailsObj.branchTriggerLevel = 'L1';
            triggerDetailsObj.dealerTriggerLevel = 'L1';
            triggerDetailsObj.sourcingTriggerLevel = 'L1';
            //MM - Review START - END
        }
        catch (Exception ex){
            System.debug(LoggingLevel.Error,'BREHandlerService.createBREUsedProductRequest ' + ex + ' Line Number : ' + ex.getLineNumber());
            throw ex;
        }
        
        vehicleDetailsObj.usedVehicleCostDetails = usedVehicleCostDetailsObj;
        vehicleDetailsObj.otherFundingItemsDetails = otherFundingItemsDetailsObj;
        vehicleDetailsObj.newVehicleCostDetails = newVehicleCostDetailsObj;
        //for testing purpose - 2W - NA, and. fW A
        vehicleDetailsObj.vehicleCategory = collateralList[0].Vehicle_Category__c != null ? collateralList[0].Vehicle_Category__c.toUpperCase().replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_') : '';
        vehicleDetailsObj.ltvExShowroom = collateralList[0].LTV_offered_Ex_showroom__c != null ? collateralList[0].LTV_offered_Ex_showroom__c : 0;
        vehicleDetailsObj.ltvOnRoad = collateralList[0].LTV_offered_On_road__c != null ? collateralList[0].LTV_offered_On_road__c : 0;
        vehicleDetailsObj.ltvOnFinalCost = collateralList[0].LTV_offered_On_final_cost__c != null ? collateralList[0].LTV_offered_On_final_cost__c : 0;
        vehicleDetailsObj.HPNFinanciersName = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 &&  usedOrCashOnWheelsCollateralList[0].HPN_With_Financiers_Name__c != null ? usedOrCashOnWheelsCollateralList[0].HPN_With_Financiers_Name__c : '';
        vehicleDetailsObj.currentOwnerName = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 &&  usedOrCashOnWheelsCollateralList[0].Current_Owner_Name__c != null ? usedOrCashOnWheelsCollateralList[0].Current_Owner_Name__c : '';
        vehicleDetailsObj.ownerSerialNumber = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 && usedOrCashOnWheelsCollateralList[0].Owner_Serial_number__c != null ? usedOrCashOnWheelsCollateralList[0].Owner_Serial_number__c : '';
        vehicleDetailsObj.registrationCity = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 && usedOrCashOnWheelsCollateralList[0].Registration_City__c != null ? usedOrCashOnWheelsCollateralList[0].Registration_City__c : '';
        //SFAU-5291
        vehicleDetailsObj.isBlackListed = usedOrCashOnWheelsCollateralList != NULL && usedOrCashOnWheelsCollateralList.size()>0 && String.isNotBlank(usedOrCashOnWheelsCollateralList[0].Blacklist_Details__c) ? true : false;
        //SFAU-3827
        vehicleDetailsObj.isLuxaryVehicle = String.isNotBlank(collateralList[0].Luxury_Non_Luxury__c) && collateralList[0].Luxury_Non_Luxury__c == 'Luxury' ? true : false;
        // Change As per UAT Defect
        vehicleDetailsObj.maxLTV = String.isNotBlank(collateralList[0].Approved_LTV__c) ? Double.valueOf(collateralList[0].Approved_LTV__c.replace('%', '')) : 0;
        
        //vehicleDetailsObj.ltvOnVehicleCost = null; // Need to confirm on mapping of the field
        productObj.vehicleDetails = vehicleDetailsObj;
        productObj.ImplementDetails = ImplementDetailsObj;
        productObj.AttachmentDetails = AttachmentDetailsObj;
        productObj.dealerDetails = dealerObj;
        productObj.sourcingDetails = sourcingDetailsObj;
        productObj.triggerDetails = triggerDetailsObj;
        //Optional productObj.fleetDetails = objFleetDetails;
        
        return productObj;
    }
    
    
    /* method: createKarzaDataAndIdDetailsPayload
* param1: mapAppIdWithApplicant - Applicant Name With BREApplicants Wrapper
* param2: lstDocumentCheckList
* param3: mapOfBreEnumvalues
*/
    public static Map<String,BREApplicants> createKarzaDataAndIdDetailsPayload (Map<String,BREApplicants> mapAppIdWithApplicant, List<Document_Checklist__c> lstDocumentCheckList, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues) {
        String strAppId = '';
        try{
            Set<String> setAppAndDocName = new Set<String>();
            for (Document_Checklist__c objDocCheck : lstDocumentCheckList) {
                BREApplicants applicantsObj = mapAppIdWithApplicant.get(objDocCheck.Applicant__r.Name);
                if (applicantsObj == NULL)
                    continue;
                strAppId = objDocCheck.Applicant__c;
                String strNameAddressSubType = objDocCheck.Applicant__r.RecordType.DeveloperName == 'Primary_Applicant' ? 'APPLICANT_NAME' :
                objDocCheck.Applicant__r.RecordType.DeveloperName == 'Co_Applicant' ? 'FATHER_NAME' : 'SPOUSE_NAME';
                if (objDocCheck.Document_Master__r.Document_Sub_Category__c == Label.BRE_Karza_Verification_Type_KYC &&  String.isNotBlank(objDocCheck.Document_Number__c) && 
                    (
                        objDocCheck.Document_Master__r.OCR_Document_Type__c == Label.KYC_OCR_Type_Aadhaar
                    )
                   ){
                       BREApplicants.cls_karzaData objBREKarza = new BREApplicants.cls_karzaData();
                       objBREKarza.karzaVerificationType = Label.BRE_Karza_Verification_Type_KYC;
                       objBREKarza.subType = strNameAddressSubType;
                       objBREKarza.scoreOrValue = objDocCheck.Name_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Name_Match_Score__c) : 0;
                       objBREKarza.matchtype = (objDocCheck.Name_Match_Score__c != NULL ? 
                                                (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                                 (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                       //******* NEED TO UPDATE */
                       objBREKarza.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                       applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                       applicantsObj.karzaData.add(objBREKarza);
                   }
                else if (objDocCheck.Match_Type__c == Label.Document_Master_Match_Type_Name && objDocCheck.Document_Master__r.Document_Id__c == Label.Document_Master_Document_Id_Live_Photo) {
                    BREApplicants.cls_karzaData objBREKarza = new BREApplicants.cls_karzaData();
                    objBREKarza.karzaVerificationType = Label.BRE_Karza_Verification_Type_KYC;
                    objBREKarza.subType = Label.BRE_Karza_Verification_Live_Photo_SubType_Photo_Match;
                    objBREKarza.scoreOrValue = objDocCheck.Match_Percentage__c != NULL ? Integer.valueOf(objDocCheck.Match_Percentage__c) : 0;
                    objBREkarza.matchtype = (objDocCheck.Match_Percentage__c != NULL ? 
                                             (objDocCheck.Match_Percentage__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                              (objDocCheck.Match_Percentage__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    //******* NEED TO UPDATE */
                    objBREKarza.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarza);
                }
                else if (objDocCheck.Match_Type__c == Label.Document_Master_Match_Type_Name && (objDocCheck.Document_Master__r.Document_Id__c == Label.Document_Master_Document_Id_Bant_Statement_Name && String.isNotBlank(objDocCheck.Document_Number__c))) {
                    // Name Match Score
                    BREApplicants.cls_karzaData objBREKarzaName = new BREApplicants.cls_karzaData();
                    objBREKarzaName.karzaVerificationType = Label.BRE_Karza_Verification_Type_Bank_Statement;
                    objBREKarzaName.subType = strNameAddressSubType;
                    objBREKarzaName.scoreOrValue = objDocCheck.Match_Percentage__c != NULL ? Integer.valueOf(objDocCheck.Match_Percentage__c) : 0;
                    objBREKarzaName.matchtype = (objDocCheck.Match_Percentage__c != NULL ? 
                                                 (objDocCheck.Match_Percentage__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                                  (objDocCheck.Match_Percentage__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    //******* NEED TO UPDATE */
                    objBREKarzaName.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarzaName);
                }
                else if (objDocCheck.Match_Type__c == Label.Document_Master_Match_Type_Name && (objDocCheck.Document_Master__r.Document_Id__c == Label.Document_Master_Document_Id1_Electricity_Bill || objDocCheck.Document_Master__r.Document_Id__c == Label.Document_Master_Document_Id2_Electricity_Bill) && String.isNotBlank(objDocCheck.Document_Number__c)) {
                    // Name Match Score
                    BREApplicants.cls_karzaData objBREKarzaName = new BREApplicants.cls_karzaData();
                    objBREKarzaName.karzaVerificationType = Label.BRE_Karza_Verification_Type_Electricity_Bill;
                    objBREKarzaName.subType = strNameAddressSubType;
                    objBREKarzaName.scoreOrValue = objDocCheck.Name_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Name_Match_Score__c) : 0;
                    objBREKarzaName.matchtype = (objDocCheck.Name_Match_Score__c != NULL ? 
                                                 (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                                  (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    //******* NEED TO UPDATE */
                    objBREKarzaName.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarzaName);
                    
                    // Address Match Score
                    BREApplicants.cls_karzaData objBREKarzaAddress = new BREApplicants.cls_karzaData();
                    objBREKarzaAddress.karzaVerificationType = Label.BRE_Karza_Verification_Type_Electricity_Bill;
                    objBREKarzaAddress.subType = Label.BRE_Karza_Verification_Electricity_Bill_Sub_Type;
                    objBREKarzaAddress.scoreOrValue = objDocCheck.Address_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Address_Match_Score__c) : 0;
                    objBREKarzaAddress.matchtype = (objDocCheck.Address_Match_Score__c != NULL ? 
                                                    (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Full_Match_Score) ? 'FULL_MATCH' :
                                                     (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Partial_Match_Score) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    //******* NEED TO UPDATE */
                    objBREKarzaAddress.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData.add(objBREKarzaAddress);
                }
                else if (objDocCheck.Document_Master__r.Document_Id__c == Label.Document_Master_Document_Id_PNG && String.isNotBlank(objDocCheck.Document_Number__c)) {
                    // Name Match Score
                    BREApplicants.cls_karzaData objBREKarzaName = new BREApplicants.cls_karzaData();
                    objBREKarzaName.karzaVerificationType = Label.BRE_Karza_Verification_Type_PNG;
                    objBREKarzaName.subType = strNameAddressSubType;
                    objBREKarzaName.scoreOrValue = objDocCheck.Name_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Name_Match_Score__c) : 0;
                    objBREKarzaName.matchtype = (objDocCheck.Name_Match_Score__c != NULL ? 
                                                 (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                                  (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    objBREKarzaName.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarzaName);
                    
                    // Address Match Score
                    BREApplicants.cls_karzaData objBREKarzaAddress = new BREApplicants.cls_karzaData();
                    objBREKarzaAddress.karzaVerificationType = Label.BRE_Karza_Verification_Type_PNG;
                    objBREKarzaAddress.subType = Label.BRE_Karza_Verification_Sub_Type_PNG;
                    objBREKarzaAddress.scoreOrValue = objDocCheck.Address_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Address_Match_Score__c) : 0;
                    objBREKarzaAddress.matchtype = (objDocCheck.Address_Match_Score__c != NULL ? 
                                                    (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Full_Match_Score) ? 'FULL_MATCH' :
                                                     (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Partial_Match_Score) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    applicantsObj.karzaData.add(objBREKarzaAddress);
                }
                else if (objDocCheck.Document_Master__r.Document_ID__c == Label.Document_Master_Document_Id_Water_Bill && String.isNotBlank(objDocCheck.Document_Number__c)) {
                    
                    // Name Match Score
                    BREApplicants.cls_karzaData objBREKarzaName = new BREApplicants.cls_karzaData();
                    objBREKarzaName.karzaVerificationType = Label.BRE_Karza_Verification_Type_Water_Bill;
                    objBREKarzaName.subType = strNameAddressSubType;
                    objBREKarzaName.scoreOrValue = objDocCheck.Name_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Name_Match_Score__c) : 0;
                    objBREKarzaName.matchtype = (objDocCheck.Name_Match_Score__c != NULL ? 
                                                 (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Full_Match) ? 'FULL_MATCH' :
                                                  (objDocCheck.Name_Match_Score__c > Integer.valueOf(Label.Name_Match_Score_Partial_Match) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    objBREKarzaName.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarzaName);
                    
                    // Address Match Score
                    BREApplicants.cls_karzaData objBREKarzaAddress = new BREApplicants.cls_karzaData();
                    objBREKarzaAddress.karzaVerificationType = Label.BRE_Karza_Verification_Type_PNG;
                    objBREKarzaAddress.subType = Label.Karza_Verification_Sub_Type_Water_Bill;
                    objBREKarzaAddress.scoreOrValue = objDocCheck.Address_Match_Score__c != NULL ? Integer.valueOf(objDocCheck.Address_Match_Score__c) : 0;
                    objBREKarzaAddress.matchtype = (objDocCheck.Address_Match_Score__c != NULL ? 
                                                    (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Full_Match_Score) ? 'FULL_MATCH' :
                                                     (objDocCheck.Address_Match_Score__c > Integer.valueOf(Label.BRE_Karza_Cibil_Address_Partial_Match_Score) ? 'PARTIAL_MATCH' : 'NO_MATCH')) : 'PENDING');
                    applicantsObj.karzaData.add(objBREKarzaAddress);
                }
                else if(objDocCheck.Document_Master__r.Document_ID__c == Label.DocumentPan && String.isNotBlank(objDocCheck.Document_Number__c)){
                    
                    BREApplicants.cls_karzaData objBREKarzaName = new BREApplicants.cls_karzaData();
                    objBREKarzaName.karzaVerificationType = Label.BRE_Karza_Verification_Type_KYC;
                    objBREKarzaName.subType = 'APPLICANT_NAME';
                    objBREKarzaName.scoreOrValue = objDocCheck.Match_Percentage__c != NULL ? Integer.valueOf(objDocCheck.Match_Percentage__c) : 0;
                    if(objDocCheck.Match_Percentage__c >= Decimal.valueOf(Label.name_match_percentage)){
                        objBREKarzaName.matchtype = 'FULL_MATCH';
                    }
                    else if((objDocCheck.Match_Percentage__c <= Decimal.valueOf(Label.name_match_percentage_Partial))){
                        objBREKarzaName.matchtype = 'PARTIAL_MATCH';
                    }
                    else if(objDocCheck.Match_Percentage__c == Decimal.valueOf(Label.name_No_match_percentage)){
                        objBREKarzaName.matchtype = 'NO_MATCH';
                    }
                    else {
                        objBREKarzaName.matchtype = 'PENDING';
                    }
                    objBREKarzaName.reportedDate = objDocCheck.Document_Received_Date__c != NULL ? objDocCheck.Document_Received_Date__c : NULL;
                    applicantsObj.karzaData = applicantsObj.karzaData == NULL ? new List<BREApplicants.cls_karzaData>() : applicantsObj.karzaData;
                    applicantsObj.karzaData.add(objBREKarzaName);                    
                }
                
                mapAppIdWithApplicant.put(objDocCheck.Applicant__r.Name,applicantsObj);
                
                BREIdDetails idDetaiisObj = new BREIdDetails();
                //Adding Id details for tractor and commercials - R2
                if(objDocCheck.Applicant__r.loan__r.RecordType.DeveloperName == 'Tractor'){
                    idDetaiisObj.idType = 'DL';
                    
                }
                else if(objDocCheck.Applicant__r.loan__r.RecordType.DeveloperName == 'Commercial_Vehicle' || objDocCheck.Applicant__r.loan__r.RecordType.DeveloperName == 'Construction_Equipment'){
                    idDetaiisObj.idType = 'DL_TRANSPORT';
                }
                if(objDocCheck.Applicant__r.Driving_License_Expiry_Date__c!=null){
                    idDetaiisObj.expiryDate = objDocCheck.Applicant__r.Driving_License_Expiry_Date__c;
                }
                if(objDocCheck.Applicant__r.Driving_License_Issue_Date__c!=null){
                    idDetaiisObj.issueDate = objDocCheck.Applicant__r.Driving_License_Issue_Date__c;
                }
                idDetaiisObj.idType = String.isNotBlank(objDocCheck.Document__c) ? 
                    (mapOfBreEnumvalues.containsKey('Document_Checklist__c~Document__c'+'~'+objDocCheck.Document__c) ? 
                     mapOfBreEnumvalues.get('Document_Checklist__c~Document__c'+'~'+objDocCheck.Document__c).Enum_Value__c : '') : '';
                
                idDetaiisObj.isVerified = objDocCheck.Document_Verification_Status__c == 'Verified' ? true : false;
                if (idDetaiisObj.idType == NULL || idDetaiisObj.idType == '' || setAppAndDocName.contains(strAppId+objDocCheck.Document__c)) {
                    continue;
                }
                applicantsObj.idDetaiis = applicantsObj.idDetaiis == NULL ? new List<BREIdDetails>() : applicantsObj.idDetaiis;
                applicantsObj.idDetaiis.add(idDetaiisObj);
                mapAppIdWithApplicant.put(objDocCheck.Applicant__r.Name,applicantsObj);
                setAppAndDocName.add(objDocCheck.Applicant__r.Name+''+objDocCheck.Document__c);
            }
        }
        catch (Exception ex){
            System.Debug(LoggingLevel.Error,'Error in BRE Karza Data : ' + ex.getLineNumber() + ' ::: ' + ex);
            Log.error('Error in BRE Karza Data :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strAppId);
            throw ex;
        }
        return mapAppIdWithApplicant;
    }
    
    /* method: createKarzaDataAndIdDetailsPayload
* param1: mapAppIdWithApplicant - Applicant Name With BREApplicants Wrapper
* param2: lstDocumentCheckList
* param3: mapOfBreEnumvalues
*/
    public static Map<String,BREApplicants> getVerificationReportsPayload (Map<String,BREApplicants> mapAppIdWithApplicant, List<Field_Investigation__c> lstFieldInvestigation, Map<String,BRE_Enum_Values__mdt> mapOfBreEnumvalues) {
        String strAppId = '';
        try{
            Set<String> setAppAndDocName = new Set<String>();
            for (Field_Investigation__c objFI : lstFieldInvestigation) {
                BREApplicants applicantsObj = mapAppIdWithApplicant.get(objFI.Applicant__r.Name);
                if (applicantsObj == NULL || (objFI.FI_Status__c != 'POSITIVE' && objFI.FI_Status__c != 'NEGATIVE'))
                    continue;
                strAppId = objFI.Applicant__c;
                BREApplicants.cls_VerificationReportData objVerReport = new BREApplicants.cls_VerificationReportData();
                objVerReport.verificationType = objFI.Type_of_Address__c.toUpperCase().replaceAll(' ','_');
                objVerReport.verificationStatus = (objFI.FI_Status__c == 'In Progress' || objFI.FI_Status__c == '' || objFI.FI_Status__c == 'Cancelled') ? 'PENDING' : 'VERIFIED';
                objVerReport.verificationRemarks = '';
                objVerReport.verificationDate = objFI.FI_Submission_Date_Time__c != NULL ? Date.newinstance(objFI.FI_Submission_Date_Time__c.year(), objFI.FI_Submission_Date_Time__c.month(), objFI.FI_Submission_Date_Time__c.day()) : NULL;
                objVerReport.verificationResult = (String.isNotBlank(objFI.FI_Status__c) && (objFI.FI_Status__c == 'POSITIVE' || objFI.FI_Status__c == 'Cancelled' || objFI.FI_Status__c == 'Waived off') ? 'POSITIVE' : (objFI.FI_Status__c == 'NEGATIVE' ? objFI.FI_Status__c = 'NEGATIVE' : 'NEGATIVE'));
                applicantsObj.verificationReportData = applicantsObj.verificationReportData == NULL ? new List<BREApplicants.cls_VerificationReportData>() : applicantsObj.verificationReportData;
                applicantsObj.verificationReportData.add(objVerReport);
                mapAppIdWithApplicant.put(objFI.Applicant__r.Name,applicantsObj);
            }
        }
        catch (Exception ex){
            System.Debug(LoggingLevel.Error,'Error in BRE getVerificationReportsPayload : ' + ex);
            Log.error('Error in BRE getVerificationReportsPayload  :: ' + ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),strAppId);
            throw ex;
        }
        return mapAppIdWithApplicant;
    }
    
    public class CustomException extends Exception{}
    
    static Integer getIntegerValue(String strValue) {
        try {
            return Integer.valueOf(strValue);
        } catch (Exception ex) {
            return null;
        }
    }
}