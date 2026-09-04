/*****
 * Class Name: CAMReportVFPageController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-03-2023          -   Mohit M.            -   SFAU-5291
 * Oct-10-2023          -   Mohit M.            -   SFAU-5163
 * Nov-09-2023          -   Mohit M.            -   SFAU-5572
 */
public without sharing class CAMReportVFPageController {
    
    public static String recordId{get;set;} //loan Id sent from LWC
    public static String factor{get;set;} //Device size sent from LWC
    
    //objects
    public static Loan_Application__c loan; 
    public static String bureauScore {get;set;}
    public static Applicant__c applicant{get;set;} //Primary Applicant
    public static List<Applicant__c> applicants{get;set;} //Primary Applicant, Co-Applicant, Guarantor
    public static List<Applicant_Financials_Details__c> financial;
    public static List<Applicant_Financials_Details__c> commercialfinancialDetails{get;set;}
    public static List<Applicant_Financials_Details__c> documentedWithOutAuditedFinancial{get;set;}
    public static Collateral__c collateral{get;set;}
    public static Valuation__c valuation{get;set;}
    public static List<Fleet__c> fleetRecords{get;set;}
    public static List<Loan_Application_Approval__c> loanAppApprovalRecords{get;set;}
    public static List<TVR__c> tvrRecords{get;set;}
    public static List<Bank_Account_Records__c> allBankRecords{get;set;}
    public static List<Bank_Account_Records__c> cbsRecordsFD{get;set;}
    public static List<Bank_Account_Records__c> cbsRecords{get;set;}
    public static List<Bank_Account_Records__c> cartRecords{get;set;}
    public static List<Bank_Account_Records__c> cibilRecords{get;set;}
    public static List<Bank_Account_Records__c> applicantExposure{get;set;}
    public static List<Document_Checklist__c> cpvDetails{get;set;}
    public static List<Deviation__c> deviationRecords{get;set;}
    public static List<FISummaryViewWrapper> fiStatusRecords;
    public static List<Sanction_Condition__c> sanctionConditions{get;set;}
    public static List<Query__c> queries{get;set;}
    public static List<Address__c> addressList{get;set;}
    public static ProductRTMap__mdt productRT{get;set;}
    public static List<Applicant_Financials_Details__c> financialsR2;
    public static List<Bank_Account_Records__c> cbsCibilLoanRecords;
    public static List<Address__c> addressListOfCibilAddress{get;set;}
    public static FFRWrapper ffrDetails {get;set;}
    public static List<Work_Order__c> workOrderDetails{get;set;}
    public static User currentUser{get;set;}//4733
    public static Boolean isSectionEnabledForCV_CE_SCV_Product {get;set;}

    public static String caseDealSummaryLTV{get;set;}
    
    
    public static Boolean notverifiedRiskScore{get;set;}
    public static String sentFromPDF{get;set;}
    public static String sentFromVF{get;set;}
    public static String sentFromCredit{get;set;}
    public static String subPage{get;set;}
    public static String productType{get;set;} //R2-1170,1769
    public static User RO{get;set;}
    public static string vahaanPdf{get;set;}
    public static string valReportPdf{get;set;} //R2-1170,1769
    public static string vehiclededupe{get;set;}
    Public static String makeModelVaraint {get;set;}
    Public static Collateral__c dealCollateral {get;set;}
    public static BSR_PSL_Details__c pslDetails {get;set;}
    
    
    public static List<Id> applicantIds{get;set;}
    
    public static String productDetails{get;set;} //Two Wheeler or Four Wheeler
    public static String subProduct{get;set;} // new or used
    public static String dealerNameAndCode{get;set;}
    public static String applicantName{get;set;}
    public static Applicant_Financials_Details__c financialParent{get;set;} //R2-1170,1769
    
    public static Fields_for_Custom_Report__mdt fields{get;set;}
    public static List<String> loanApplicationFields = new List<String>{'ROI__c', 'Total_Loan_Amount__c', 'Loan_Amount__c', 'Wheels_Exposure__c', 'Total_Exposure__c', 'Tenure__c', 'EMI__c'};
    public static List<String> collateralFields = new List<String>{'LTV__c', 'Ex_Showroom_Price__c', 'Discount__c', 'Net_of_Discount_Price__c', 'Insurance__c','On_Road_Price__c','Other_Costs__c','Apportioned_Loan_Amount__c','LTV_offered_Ex_showroom__c','LTV_offered_On_road__c'};
    public static List<String> fleetFields = new List<String>{'Loan_Tenure__c', 'Installment_Paid__c'};
    //R2-1170,1769
    public static List<String> tractorProducts = new List<String>{'10501','10502','10503'};
    public static List<String> commercialProducts = new List<String>{'10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403'};

    public CAMReportVFPageController() {
        recordId  = ApexPages.CurrentPage().getparameters().get('id');
        factor = ApexPages.CurrentPage().getparameters().get('factor');
        sentFromPDF='PDF';
        sentFromVF='VF';
        system.debug('Current URL-- '+ ApexPages.currentPage());
        String pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
        system.debug(pageName+' pageName');
        if(pageName == 'CreditSummary4W'){
            subPage = 'Credit';
        }
        applicant = getApplicant();
        /*R2-1170,1769*/
        if(applicant.loan__r.Product__c != null){
            if(tractorProducts.contains(applicant.loan__r.Product__c)){
                productType = 'Tractor';
            }
            else if(commercialProducts.contains(applicant.loan__r.Product__c)){
                productType = 'Commercial';
            }
        }
        /*R2-1170,1769*/
        if(applicant.Bureau_Score__c!=null){
        Integer Bureau_Score =Integer.valueOf(applicant.Bureau_Score__c);     
        applicant.Bureau_Score__c = Bureau_Score  >= 100 && Bureau_Score <= 200  && 
            Utility.getTypeOfWheeler(applicant.loan__r.Product__c) =='Four Wheeler'?  '-1' : String.valueOf(Bureau_Score);
        }
        else applicant.Bureau_Score__c='0';
            
        applicants = getApplicants();
        for( Applicant__c app: applicants){
        if(app.Bureau_Score__c!=null){
        Integer Bureau_Score =Integer.valueOf(app.Bureau_Score__c); 
        app.Bureau_Score__c = Bureau_Score  >= 100 && Bureau_Score <= 200  && 
            Utility.getTypeOfWheeler(app.loan__r.Product__c) =='Four Wheeler'?  '-1' : String.valueOf(Bureau_Score);            
        }
        else app.Bureau_Score__c = '0';
        }
        setBankRecords();
        currentUser = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];//4733

    }

    public static sObject setDefaultValues(List<String> sObjectFieldList, sObject record){
        Map<String, Object> values = record.getPopulatedFieldsAsMap();
        for(String fieldName: sObjectFieldList){
            if(!values.keySet().contains(fieldName)){
                record.put(fieldName, 0.00);
            }
        }
        return record;
    }

    public static Loan_Application__c getLoan(){
        loan = new Loan_Application__c();
        List<ContentDocumentLink> ConDocLink = new List<ContentDocumentLink>();
        List<ContentDocumentLink> ConDocLinkCol = new List<ContentDocumentLink>();
        commercialfinancialDetails = new List<Applicant_Financials_Details__c>();
        documentedWithOutAuditedFinancial = new List<Applicant_Financials_Details__c>();
        isSectionEnabledForCV_CE_SCV_Product = false;
        workOrderDetails = new List<Work_Order__c>();
        notverifiedRiskScore=true;
        if(recordId != null && String.isNotBlank(recordId)){
            // String query = 'SELECT Id ,Sub_Grade__c , Moratorium_Period__c, Approved_but_not_Disbursed__c, Schedule_Type__c, First_EMI_Date__c, EMI_Frequency__c, Schedule_Name__c, Original_Vehicle_Usage__c, RecordType.DeveloperName, Loan_Amt_Till_Date_all_Running_Loans__c, Loan_Amt_Till_Date_inc_Closed_Loans__c, Customer_Grade__c, POS_of_all_Live_Loans__c, FOIR_Percentage__c, POS_As_On_Date_Two_Wheeler__c, ROI__c, LC_Code__c,RecordType.Name, BRE_Decision__c, Credit_FTR_FTNR__c, Ops_FTR_FTNR__c, FTR_FTNR__c, Final_Exposure__c, Credit_Remarks__c, Base_Credit_Verification__c, Dealer_Master__r.Purchase_State__c, Pre_Approved_Flag__c, OwnerId, BSR_PSL_Status__c, Mobile__c, Customer_Name__c, Purpose_of_Loan__c, Total_Loan_Amount__c, Vehicle_use__c, Loan_Amount__c, Name, CreatedDate, Scheme__c,Scheme__r.Scheme_Name__c, Application_Id__c,toLabel(Product__c), Wheels_Exposure__c, Branch_Master__r.Business_HUB__r.Account_Name__c,Total_Exposure__c, Application_FI_Status__c, Application_Number__c, Stage__c, Branch_Master__r.Account_Name__c, Branch_Master__r.State__r.Account_Name__C, Dealer_Master__c, Dealer_Master__r.Dealer_Type__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Account_Code__c,Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.State__r.Account_Name__c, Purchase_City__c, Sourcing_channel__c,Sourcing_Channel_Name__c ,Sourcing_Channel_Name__r.Account_Name__c,  Sourcing_Channel_Name__r.Name,  Tenure__c, EMI__c,BT_Type__c,Total_Charges__c,'+
            // '(Select Id, End_use_of_Vehicle__c, PSL_Classification_Type__c, RecordType.DeveloperName FROM BSR_PSL_Details__r),'+
            // '(SELECT Id, Completed_By__c, Completed_By__r.Name, Completed_By__r.Employee_Code__c, Date_Time__c, Loan_Application__c, Raised_By__c, Raised_By__r.Name, Raised_By__r.Employee_Code__c, Remarks__c, Sanction_Condition__c, Status__c FROM Sanction_Conditions__r),'+
            // '(SELECT Id, Assigned_To__c, Assigned_To__r.Name, Loan_Application__c, Remarks__c, Resolution_Comments__c, Status__c, Sub_Type__c, Type__c, CreatedDate, LastModifiedDate, CreatedBy.Name FROM Queries__r),'+
            // '(SELECT Name, Relationship_with_borrower__c,Type_of_Vehicle__c, Vehicle_Number__c, Vehicle_Make_Model__c,MFG_Year__c, HPN_Status__c, Financial_Institution_Name__c, Loan_Tenure__c, Installment_Paid__c,Free_No_Hypo__c,Deemed_Free__c,Consider_Fleet__c,Age_Filter__c FROM Fleet__r WHERE Inactive__c=false Order by CreatedDate Desc),'+
            // '(SELECT Name, TVR_Date__c, Name_Of_Employee__c, Employee_ID__c, TVR_Done_With__c, Mobile_Number__c, Remark__c, Loan_Application__c FROM Verifications__r Order by CreatedDate Desc), '+
            // '(SELECT Id, Make__c,Registrable__c, Is_Registerable__c, Attachment__c,Grid_Depreciated_Value__c , LTV__c,SVSH_SVOH__c ,Current_Owner_Name__c ,Blacklist_Details__c ,Owner_Serial_number__c ,HPN_With_Financiers_Name__c ,Registration_Date__c ,Registration_City__c ,Collateral_Name__c ,Final_Vehicle_Cost__c ,Certified_Value__c ,Valuation_Amount__c ,Collateral_Type__c ,Engine_Number__c ,Chasis_Number__c , Vehicle_Usage__c, Final_Cost__c, LTV_offered_On_final_cost__c, IBB_Value__c, IDV__c, Vehicle_Category__c,Vehicle_Cost__c, Accessories__c, LS__c, Model__c, Variant__c, Manufacture_year_month__c, MMV_Master__c, MMV_Master__r.Name, Manufacture_Year__c, RecordType.Name, Fuel_Type__c, Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, Insurance__c, Insurance_Funding__c, Insurance_Value__c, RTO_Tax_Value__c, On_Road_Price__c, Other_Costs__c, Apportioned_Loan_Amount__c, Customer_equity__c,Vehicle_Number__c , Approved_LTV__c, LTV_offered_Ex_showroom__c, LTV_offered_On_road__c, RTO_Taxes__c,LS_Value__c, Challan_Info__c, Original_Vehicle_Usage__c, Hours_Meter_Reading__c, TAR_Status__c,Body_invoice_is_GST_paid__c, Body_Type__c,Insurance_Expiry_Date__c, Cost__c FROM Collaterals__r WHERE RecordType.Developername in (\'New\',\'Used_Cash_on_Wheels\') Order by CreatedDate Desc Limit 1) '+ // SFAU-5291 - Add field Challan_Info__c || SFAU-5163 - Add Original_Vehicle_Usage__c
            // ',(SELECT Id, Name_of_the_Principal__c, Nature_of_Work__c, Contract_start_date__c, Completion_date__c, age_work_completed__c, Value_of_contract_Rs_in_lacs__c, Unexecuted_CIH_Rs_in_Lacs__c, S_No__c From Work_Order_Contract__r)'+
            // 'FROM Loan_Application__c WHERE Id = :recordId';

             //R2-2696
            String query = 'SELECT Id, Deal_Background__c, Sub_Grade__c, Moratorium_Period__c, Approved_but_not_Disbursed__c, Schedule_Type__c, First_EMI_Date__c, EMI_Frequency__c, Schedule_Name__c, Original_Vehicle_Usage__c, RecordType.DeveloperName, Loan_Amt_Till_Date_all_Running_Loans__c, Loan_Amt_Till_Date_inc_Closed_Loans__c, Customer_Grade__c, POS_of_all_Live_Loans__c, FOIR_Percentage__c, POS_As_On_Date_Two_Wheeler__c, ROI__c, LC_Code__c,RecordType.Name, BRE_Decision__c, Credit_FTR_FTNR__c, Ops_FTR_FTNR__c, FTR_FTNR__c, Final_Exposure__c, Credit_Remarks__c, Base_Credit_Verification__c, Dealer_Master__r.Purchase_State__c, Pre_Approved_Flag__c, OwnerId, BSR_PSL_Status__c, Mobile__c, Customer_Name__c, Purpose_of_Loan__c, Total_Loan_Amount__c, Vehicle_use__c, Loan_Amount__c, Name, CreatedDate, Scheme__c,Scheme__r.Scheme_Name__c, Application_Id__c,toLabel(Product__c),toLabel(Collateral_Type__c), Wheels_Exposure__c, Branch_Master__r.Business_HUB__r.Account_Name__c,Total_Exposure__c, Application_FI_Status__c, Application_Number__c, Stage__c, Branch_Master__r.Account_Name__c, Branch_Master__r.State__r.Account_Name__C, Dealer_Master__c, Dealer_Master__r.Dealer_Type__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Account_Code__c,Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.State__r.Account_Name__c, Purchase_City__c, Sourcing_channel__c,Sourcing_Channel_Name__c ,Sourcing_Channel_Name__r.Account_Name__c,  Sourcing_Channel_Name__r.Name,  Tenure__c, EMI__c,BT_Type__c,Total_Charges__c,'+
            '(Select Id, End_use_of_Vehicle__c, PSL_Classification_Type__c, RecordType.DeveloperName FROM BSR_PSL_Details__r),'+
            '(SELECT Id, Completed_By__c, Completed_By__r.Name, Completed_By__r.Employee_Code__c, Date_Time__c, Loan_Application__c, Raised_By__c, Raised_By__r.Name, Raised_By__r.Employee_Code__c, Remarks__c, Sanction_Condition__c, Status__c FROM Sanction_Conditions__r),'+
            '(SELECT Id, Assigned_To__c, Assigned_To__r.Name, Loan_Application__c, Remarks__c, Resolution_Comments__c, Status__c, Sub_Type__c, Type__c, CreatedDate, LastModifiedDate, CreatedBy.Name FROM Queries__r),'+
            '(SELECT Name, Relationship_with_borrower__c,Type_of_Vehicle__c, Vehicle_Number__c, Vehicle_Make_Model__c,MFG_Year__c, HPN_Status__c, Financial_Institution__r.Bank_Name__c, Financial_Institution_Name__c, Loan_Tenure__c, Installment_Paid__c,Free_No_Hypo__c,Deemed_Free__c,Consider_Fleet__c,Age_Filter__c FROM Fleet__r WHERE Inactive__c=false Order by CreatedDate Desc),'+
            '(SELECT Name, TVR_Date__c, Name_Of_Employee__c, Employee_ID__c, TVR_Done_With__c, Mobile_Number__c, Remark__c, Loan_Application__c FROM Verifications__r Order by CreatedDate Desc), '+
            '(SELECT Id, Make__c,Registrable__c, Is_Registerable__c, Attachment__c, Grid_Depreciated_Value__c, IBB_API_Value__c, LTV__c,SVSH_SVOH__c ,Current_Owner_Name__c ,Blacklist_Details__c ,Owner_Serial_number__c ,HPN_With_Financiers_Name__c ,Registration_Date__c ,Registration_City__c ,Collateral_Name__c ,Final_Vehicle_Cost__c ,Certified_Value__c ,Valuation_Amount__c ,Collateral_Type__c ,Engine_Number__c ,Chasis_Number__c , Vehicle_Usage__c, Final_Cost__c, LTV_offered_On_final_cost__c, IBB_Value__c, IDV__c, Vehicle_Category__c,Vehicle_Cost__c, Accessories__c, LS__c, Model__c, Variant__c, Manufacture_year_month__c, MMV_Master__c, MMV_Master__r.Name, Manufacture_Year__c, RecordType.Name, Fuel_Type__c, Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, Insurance__c, Insurance_Funding__c, Insurance_Value__c, RTO_Tax_Value__c, On_Road_Price__c, Other_Costs__c, Apportioned_Loan_Amount__c, Customer_equity__c,Vehicle_Number__c , Approved_LTV__c, LTV_offered_Ex_showroom__c, LTV_offered_On_road__c, RTO_Taxes__c,LS_Value__c, Challan_Info__c, Original_Vehicle_Usage__c, Hours_Meter_Reading__c, TAR_Status__c,Body_invoice_is_GST_paid__c, Body_Type__c,Insurance_Expiry_Date__c, Cost__c, Built__c, Date_of_Delivery__c, Vehicle_Delivery__c  FROM Collaterals__r WHERE RecordType.Developername in (\'New\',\'Used_Cash_on_Wheels\') Order by CreatedDate Desc Limit 1) '+ // SFAU-5291 - Add field Challan_Info__c || SFAU-5163 - Add Original_Vehicle_Usage__c
            ',(SELECT Id, Name_of_the_Principal__c, Nature_of_Work__c, Contract_start_date__c, Completion_date__c, age_work_completed__c, Value_of_contract_Rs_in_lacs__c, Unexecuted_CIH_Rs_in_Lacs__c, S_No__c From Work_Order_Contract__r)'+
            'FROM Loan_Application__c WHERE Id = :recordId';
             //R2-2696

            //SFAU-5131 -- Added Loan_details__c
            //SFAU-5572 -- Add Archived__c filter
            // R2-2573 -- Added Consider_Fleet__c,Age Filter
            //Removed Desc in ORDER BY clause as part of tractor E2E demo feedback - applies for all products
            List<Loan_Application_Approval__c> allLoanApplicationApprovals = [SELECT Name, Decision__c, Remarks__c, Approver__r.Name, Approver__r.Username, Approver__r.Employee_Code__c, Approval_Status__c, Decision_Date_Time__c, Approval_Type__c, Approver_Level__c, Deviation_Level__c, Loan_details__c, LastModifiedDate FROM Loan_Application_Approval__c WHERE Loan_Application__c=:recordId AND Archived__c = false Order by SystemModStamp];
            List<Deviation__c> allDeviations = [SELECT Department__c, Deviation_Type__c, Details__c, Policy_Value__c, Actual_Value__c, Variance__c, Level__c, Mitigates__c FROM Deviation__c WHERE ((Source__c = 'BRE' AND Archived__c=false) OR (Source__c='Manual' AND Archived__c=false) OR (Source__c='SF' AND Archived__c=false)) AND Deviation_Type__c != 'Charges - Min Level Breached' AND Loan_Application__c=:recordId Order by CreatedDate Desc];
            List<Loan_Application__c> loanApp = new List<Loan_Application__c>();
            loanApp = Database.query(query);
            if(loanApp.size()>0){
                loan = loanApp[0];
                List<Loan_Application_Approval__c> creditApprovals = new List<Loan_Application_Approval__c>();
                if(loan.RecordType.Name=='Two Wheeler' && loan.Stage__c == 'Credit'){   
                    if(!allLoanApplicationApprovals.isEmpty()){
                        for(Loan_Application_Approval__c appr : allLoanApplicationApprovals){
                            if(appr.Approval_Type__c == 'Credit'){
                                creditApprovals.add(appr);
                            }
                        }
                    }
                    /*if(!loan.Loan_Application_Approvers__r.isEmpty()){
                        for(Loan_Application_Approval__c appr : loan.Loan_Application_Approvers__r){
                            if(appr.Approval_Type__c == 'Credit'){
                                creditApprovals.add(appr);
                            }
                        }
                    }*/
                }
                pslDetails = new BSR_PSL_Details__c();
                if(loan.BSR_PSL_Details__r!=null && loan.BSR_PSL_Details__r.size()>0){
                    for(BSR_PSL_Details__c psl: loan.BSR_PSL_Details__r){
                        if(psl.RecordType.DeveloperName == 'PSL'){
                            pslDetails = psl;
                        }
                    }
                }
                
                loan = (Loan_Application__c) setDefaultValues(loanApplicationFields, loan);
                List<ProductRTMap__mdt> products= new List<ProductRTMap__mdt>();
                products = [SELECT Product__c, RecordType__c, Sub_Product__c FROM ProductRTMap__mdt where Product_Label__c= :loan.Product__c WITH SECURITY_ENFORCED];//R2-2634 chaged MasterLabel to Product_Label__c
                if(products.size()>0){
                    productRT = products[0];
                    productDetails = products[0].RecordType__c;
                    subProduct = products[0].Sub_Product__c;
                } 
                //Set<String> setOfCEProducts = new Set<String>{'Construction Equipment (New)', 'Construction Equipment (Used)', 'Construction Equipment (Cash on Wheels)', 'Construction Equipment (Agri Loan Secured by Vehicle)', 'Construction Equipment (Business Loan Secured by Vehicle)', 'Construction Equipment (Personal Loan Secured by Vehicle)'};
                //R2-2634 start
                Set<String> setOfCEProducts = new Set<String>();
                setOfCEProducts.addAll(System.Label.ALL_CE_PRODUCTS.split(','));
                //Set<String> setOfCVProducts = new Set<String>{'CV Loading (New)', 'CV Loading (Used)', 'CV Loading (Cash on Wheels)', 'CV Passenger (New)', 'CV Passenger (Used)', 'CV Passenger (Cash on Wheels)'};
                Set<String> setOfCVProducts = new Set<String>();
                setOfCVProducts.addAll(System.Label.ALL_CV_PRODUCTS.split(','));
                Set<String> setOfCarProducts = new Set<String>();
                setOfCarProducts.addAll(System.Label.CAR_TAXI_PRODUCTS.split(','));
                //R2-2634 end
                //Set<String> setOfCarProducts = new Set<String>{'Car Taxi (New)', 'Car Taxi (Used)', 'Car Taxi (Cash on Wheels)'};
                Set<String> setOfCECVSCVCAR = new Set<String>();
                setOfCECVSCVCAR.addAll(setOfCEProducts); setOfCECVSCVCAR.addAll(setOfCVProducts); setOfCECVSCVCAR.addAll(setOfCarProducts);
                if(productDetails == 'Construction Equipment' || setOfCECVSCVCAR.contains(loan.Product__c)){
                    isSectionEnabledForCV_CE_SCV_Product = true;
                }
                if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
                    List<User> owners = [SELECT Id, Name, Employee_Code__c, MobilePhone FROM User WHERE Id=:loan.OwnerId WITH SECURITY_ENFORCED];
                    if(owners!=null && owners.size()>0){
                        RO = owners[0];
                    }
                }  
                sanctionConditions = loan.Sanction_Conditions__r!=null && loan.Sanction_Conditions__r.size()>0?loan.Sanction_Conditions__r:new List<Sanction_Condition__c>();
                queries = loan.Queries__r!=null && loan.Queries__r.size()>0?loan.Queries__r:new List<Query__c>();
                //  fleetRecords = loan.Fleet__r!=null && loan.Fleet__r.size()>0?loan.Fleet__r:new List<Fleet__c>();
              // SFAU-5640
              fleetRecords = new List<Fleet__c>();
               // if(fleetRecords.size()>0){
                    for(Fleet__c fleet: loan.Fleet__r){
                        // commenting out the condition for R2-2719
                        /*if(loan.RecordType.Name=='Commercial Vehicle'){ // Check is applicable only for Commercial fro R2-2573
                            if(fleet.Consider_Fleet__c == 'Yes' && fleet.Age_Filter__c == 'Yes'){
                                fleet = (Fleet__c) setDefaultValues(fleetFields, fleet);
                                fleetRecords.add(fleet);
                            }
                        }else{*/
                            fleet = (Fleet__c) setDefaultValues(fleetFields, fleet);
                            fleetRecords.add(fleet);
                        //}
                        
                    }
              //  }
                ffrDetails = new FFRWrapper();
                ffrDetails.totalNoofVehicle = 0;
                if(fleetRecords.size()>0){
                    integer deemedFree = 0;
                    integer freeNoHypo = 0;
                    integer financedFleets = 0; ////R2-2573
                    for(Fleet__c fleet: fleetRecords){
                        if(( (loan.RecordType.Name=='Commercial Vehicle' || loan.RecordType.Name=='Construction Equipment')  && fleet.Consider_Fleet__c == 'Yes' && fleet.Age_Filter__c == 'Yes') //R2-2859
                            || (loan.RecordType.Name!='Commercial Vehicle'  && loan.RecordType.Name!='Construction Equipment' )){ //R2-2719
                            ffrDetails.totalNoofVehicle++; //R2-2859
                            if(fleet.Deemed_Free__c){
                                deemedFree +=1;
                            }
                            if(fleet.Free_No_Hypo__c){
                                freeNoHypo +=1;
                            }
                            if( String.isNotBlank(fleet.HPN_Status__c) && fleet.HPN_Status__c == 'Financed'){ //R2-2573
                                financedFleets +=1;
                            }
                        }
                        //fleet = (Fleet__c) setDefaultValues(fleetFields, fleet);
                    }
                    ffrDetails.freeWithNoHypoOnRC = freeNoHypo;
                    ffrDetails.deemedFreeVehicle = deemedFree;
                    ffrDetails.financedVehicle = financedFleets - deemedFree; //R2-2573
                }else{
                    ffrDetails.freeWithNoHypoOnRC = 0;
                    ffrDetails.deemedFreeVehicle = 0;
                    ffrDetails.financedVehicle = 0; //R2-2573
                }

                ffrDetails.totalFreeVehicle = ffrDetails.freeWithNoHypoOnRC + ffrDetails.deemedFreeVehicle;
                //ffrDetails.financedVehicle = ffrDetails.totalNoofVehicle - ffrDetails.totalFreeVehicle; 
                ffrDetails.proposed = 1; 
                if(ffrDetails.totalNoofVehicle > 0){ ////R2-2573
                    //Pre Funding 
                    Decimal free = ffrDetails.totalFreeVehicle;
                    Decimal noVehicle = ffrDetails.totalNoofVehicle;
                    Decimal preratio = free/noVehicle;
                    Decimal toRound =  preratio* 100;
                    ffrDetails.preFundingFFR = toRound.setScale(2, RoundingMode.HALF_UP);
                    //Post Funding 
                    Decimal proposed = ffrDetails.proposed;
                    Decimal postratio = free/(noVehicle +proposed) ;
                    Decimal toPRound =  postratio* 100;
                    ffrDetails.postFundingFFR = toPRound.setScale(2, RoundingMode.HALF_UP);
                }else{
                    ffrDetails.preFundingFFR = 0;
                    ffrDetails.postFundingFFR = 0;
                }
               
                //ffrDetails.postFundingFFR = ffrDetails.preFundingFFR - ffrDetails.proposed;
                
                tvrRecords = loan.Verifications__r!=null && loan.Verifications__r.size()>0?loan.Verifications__r:new List<TVR__c>();
                if(allDeviations!=null && allDeviations.size()>0){
                    deviationRecords = new List<Deviation__c>();
                    for(Deviation__c newDeviation: allDeviations){
                        deviationRecords.add(newDeviation);
                    }
                }
                if(allLoanApplicationApprovals!=null && allLoanApplicationApprovals.size()>0){
                    loanAppApprovalRecords = new List<Loan_Application_Approval__c>();
                    for(Loan_Application_Approval__c newApproval: allLoanApplicationApprovals){
                        loanAppApprovalRecords.add(newApproval);
                    }
                }
                if(loan.RecordType.Name=='Two Wheeler' && loan.Stage__c == 'Credit'){
                    loanAppApprovalRecords = creditApprovals;
                }

                
                /*if(collateral.RecordType.Name == 'New'){
                    caseDealSummaryLTV = String.valueOf(collateral.LTV_offered_Ex_showroom__c);
                }
                else{
                    caseDealSummaryLTV = String.valueOf(collateral.LTV_offered_On_road__c);
                }moved to line 203*/
                //deviationRecords = loan.Deviations__r!=null && loan.Deviations__r.size()>0?loan.Deviations__r:new List<Deviation__c>();
                //loanAppApprovalRecords = loan.Loan_Application_Approvers__r!=null && loan.Loan_Application_Approvers__r.size()>0?loan.Loan_Application_Approvers__r:new List<Loan_Application_Approval__c>(); 
                //loanAppApprovalRecords = (loan.RecordType.Name=='Two Wheeler' && loan.Stage__c == 'Credit')?creditApprovals : loanAppApprovalRecords;
                //System.debug(' == Approvals ==' + JSON.serializePretty(loanAppApprovalRecords) + ' === ' + JSON.serializePretty([ SELECT Remarks__c, Approval_Status__c, Approver__r.Name FROM Loan_Application_Approval__c WHERE Loan_Application__c =: recordId WITH SYSTEM_MODE ]));
                
                workOrderDetails = loan.Work_Order_Contract__r !=null && loan.Work_Order_Contract__r.size()>0?loan.Work_Order_Contract__r:new List<Work_Order__c>();
                collateral = loan.Collaterals__r!=null && loan.Collaterals__r.size()>0?loan.Collaterals__r[0]:new Collateral__c(); 
                collateral = (Collateral__c) setDefaultValues(collateralFields, collateral);
                // SFAU-5163
                if (collateral != NULL && String.isNotBlank(collateral.Original_Vehicle_Usage__c)) {
                    collateral.Vehicle_Usage__c = collateral.Original_Vehicle_Usage__c;
                }
                if(collateral.RecordType.Name == 'New'){
                    caseDealSummaryLTV = String.valueOf(collateral.LTV_offered_Ex_showroom__c);
                }
                else{
                    caseDealSummaryLTV = String.valueOf(collateral.LTV_offered_On_road__c);
                }
                List<Valuation__c> valList = New List<Valuation__c>();
                if(collateral.id <> null ){
                    valList = [select id, Collateral__c, Valuer_Name_Code__c, Final_remarks__c,Coordinate_for_valuation_POC__c,
                               Valuation_Amount__c
                               from Valuation__c where 
                               Collateral__c =: collateral.Id limit 1];
                    /*R2-1170,1769*/
                    List<Document_Checklist__c> dcListCol = new List<Document_Checklist__c>();
                    List<Document_Master__c> docMasterCol = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Name__c = 'Valuation Report With Vehicle Photo'];
                    if(!docMasterCol.isEmpty()){
                        dcListCol = [SELECT Id FROM Document_Checklist__c WHERE Collateral__c=:collateral.Id AND Document_Master__c =: docMasterCol[0].Id];
                    }
                    if(dcListCol.size()>0){
                        ConDocLinkCol = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:dcListCol[0].Id order by SystemModstamp desc limit 1];
                        if(ConDocLinkCol.size()>0){
                            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                            String baselightningUrl = baseUrl.replace('my.salesforce','lightning.force');
                            valReportPdf = baselightningUrl+'/lightning/r/ContentDocument/'+ConDocLinkCol[0].ContentDocumentId+'/view';
                        }else{
                            valReportPdf=null;
                        }
                    }
                    /*R2-1170,1769*/                    
                }
                valuation = valList.size() > 0 ?valList[0] : new Valuation__c();
                List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
                List<Document_Master__c> docMaster = [SELECT Id,Document_Name__c,Document_Sub_Category__c,Document_Category__c FROM Document_Master__c Where Document_Name__c = 'Vahaan Master'];
                if(!docMaster.isEmpty()){
                    dcList = [SELECT Id FROM Document_Checklist__c WHERE Loan_Application__c=:loan.Id AND Document_Master__c =: docMaster[0].Id];
                }
                if(dcList.size()>0){
                    ConDocLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:dcList[0].Id and ContentDocument.Title like '%Vahaan%' order by SystemModstamp desc limit 1];
                    if(ConDocLink.size()>0){
                        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                        String baselightningUrl = baseUrl.replace('my.salesforce','lightning.force');
                        vahaanPdf = baselightningUrl+'/lightning/r/ContentDocument/'+ConDocLink[0].ContentDocumentId+'/view';
                        system.debug('@@vahaanPdf'+vahaanPdf);
                    }else{
                        vahaanPdf=null;
                    }
                    //cvList = [Select Id,contentDocumentId,VersionData From ContentVersion WHERE FirstPublishLocationId =: dcList[0].Id and Title = 'Vahaan Report'];
                }
                for(Integration_Checklist__c inc: [select id, Integration_Master__r.Name,Response__c,Status_Code__c,
                    Loan_Application__c   
                    from Integration_Checklist__c where Loan_Application__c =: loan.Id and 
                    Integration_Master__r.Name = 'Collateral Dedupe API' order by createddate desc limit 1]){
                    if(inc.Response__c!=null && inc.Status_Code__c != '400'){
                        Map<String, Object> mas = (Map<String, Object>)JSON.deserializeUntyped(inc.Response__c);
                        if(mas!=null && mas.size()>0 && mas.containsKey('TransactionStatus')){
                            Map<String, Object> txtDetails = (Map<String, Object>)mas.get('TransactionStatus');
                            if(txtDetails!=null && txtDetails.size()>0 && txtDetails.containsKey('ExtendedErrorDetails')){
                                Map<String, Object> extDetails = (Map<String, Object>)txtDetails.get('ExtendedErrorDetails');
                                for ( Object obj : ( List< Object > )extDetails.get('messages') ) {
                                    Map < String, Object > m = ( Map < String, Object > )obj;
                                    if(m.get( 'code' ) == 99){
                                        vehiclededupe= 'No';
                                    }
                                    if(m.get( 'code' ) == 0){
                                        vehiclededupe= 'Yes';
                                    }
                                    system.debug( 'Code Field is ' + m.get( 'code' ) );
                                }
                            }
                            
                        }
                        
                    }
                    
                }
                for(Applicant_Financials_Details__c detail : [Select Id, Annual_Net_Profit__c, Applicant__r.Applicant_Name__c, Applicant__r.Relationship_with_applicant__c, Year__c, Filing_Date__c, Net_worth_to_be_ve__c, Strategic_Secured_Loans__c,Credit_Financial_Date__c,
                                                                Strategic_Fixed_Assets__c, Strategic_Turnover__c,
                                                                Strategic_PBT__c, Strategic_Cash_Profit__c,
                                                                Strategic_YOY_Turnover_to_be_ve__c, Strategic_Cash_Profit_of_current_year_to__c,
                                                                DSCR_should_be_1_1__c, Strategic_Debt_Equity_Ratio_including_p__c,
                                                                Strategic_Drs_Turnover_should_be_90__c, RecordType.DeveloperName
                                                                From Applicant_Financials_Details__c 
                                                                where Applicant__r.Loan__c =: recordId 
                                                                AND RecordType.DeveloperName IN ('Commercial_financial_format', 'Documented_Without_Audited_financial')]){
                    if(detail.RecordType.DeveloperName == 'Commercial_financial_format'){
                        commercialfinancialDetails.add(detail);
                    }else if(detail.RecordType.DeveloperName == 'Documented_Without_Audited_financial'){
                        documentedWithOutAuditedFinancial.add(detail);
                    }
                }
            }
        }
        return loan;
    }

    public static Applicant__c getApplicant(){
        applicant = new Applicant__c();
        if(recordId != null && String.isNotBlank(recordId)){
            List<Applicant__c> tempList = new List<Applicant__c>();
            //R2-1170,1769 - updated query
            String query = 'SELECT Driving_License_Issue_Date__c, Date_of_Establishment__c, Driving_License_Expiry_Date__c, Total_Monthly_Income_Sum__c,RecordTypeId, X2W_Risk_Category__c,loan__r.Product__c, Customer_Type__c, Father_Name__c, Type_Of_Employment__c, Customer_Name__c, CPV_Waive_off_Reason__c, Is_Lead_To_Lead_Full_Match__c, Is_Lead_To_Lead_Partial_Match__c, Is_Lead_To_Customer_Partial_Match__c, Is_Lead_To_Customer_Full_Match__c, Risk_Category__c, Age__c, High_Risk_Profile__c, KYC_Status__c, KYC_Type__c, Internal_Risk_Score__c, RecordType.Name, Id, PAN__c, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, First_Name__c, FOIR__c, Middle_Name__c, Last_Name__c, Constitution_Type__c, Gender__c, Marital_Status__c, Existing_Customer__c, Mobile_Number__c, Relationship_with_applicant__c, Dob__c, CIF_No__c, AML_Status__c, CFR_Status__c, Negative_Check_Status__c,PAN_verification_status__c, Bureau_Score__c, IsEmailVerified__c, Customer_Grade__c, Applicant__c, Applicant__r.Bureau_Score__c,'+
            '(SELECT Id, Latest_Cibil_Address_Match_Score__c, Status__c FROM Addresses__r WHERE Address_Type__c=\'Current\' AND Source_Type__c=null),'+
            ' (SELECT Id, FCF_EMI__c, No_of_years_in_Business__c, toLabel(Total_Work_Experience__c), HireVsBuy_Amt__c, HireVsBuy_Decision__c FROM Applicant_Financials__r WHERE RecordType.DeveloperName = \'Financial_Parent\')'+
            ' FROM Applicant__c WHERE Loan__c= :recordId and RecordType.Developername=\'Primary_Applicant\' AND isInactive__c=false WITH SECURITY_ENFORCED Order By CreatedDate Desc Limit 1';
            tempList = Database.query(query);
            if(tempList.size()>0){
                applicant.First_Name__c = applicant.First_Name__c!=null?applicant.First_Name__c+' ':'';
                applicant.Middle_Name__c = applicant.Middle_Name__c!=null?applicant.Middle_Name__c+' ':'';
                applicant.Last_Name__c = applicant.Last_Name__c!=null?applicant.Last_Name__c:'';
                applicant=tempList[0];
                applicant.CIF_No__c =  applicant.Existing_Customer__c=='Yes'?applicant.CIF_No__c:'';
                applicantName=applicant.First_Name__c+applicant.Middle_Name__c+applicant.Last_Name__c;
                /*R2-1170,1769*/
                financialParent = applicant.Applicant_Financials__r.size()>0?applicant.Applicant_Financials__r[0]:new Applicant_Financials_Details__c();
            }
        }
        return applicant;
    }

    public static void handleCreditVerify(){
        notverifiedRiskScore=false;
    }

    public static List<Applicant__c> getApplicants(){
        applicants = new List<Applicant__c>();
        addressListOfCibilAddress = new List<Address__c>();
        if(recordId != null && String.isNotBlank(recordId)){
            //String query = 'SELECT Id, First_Name__c, Middle_Name__c, FOIR__c, Applicant__r.Bureau_Score__c, Last_Name__c, Constitution_Type__c, Gender__c, RecordType.Name, Marital_Status__c, Existing_Customer__c, Mobile_Number__c, Relationship_with_applicant__c, format(Dob__c), CIF_No__c, AML_Status__c, CFR_Status__c, Negative_Check_Status__c,PAN_verification_status__c, Bureau_Score__c, IsEmailVerified__c, Customer_Grade__c FROM Applicant__c WHERE Loan__c = :recordId AND RecordType.DeveloperName in (\'Primary_Applicant\',\'Co_Applicant\',\'Guarantor\') WITH SECURITY_ENFORCED Order by RecordType.Name, CreatedDate';
            String query = 'SELECT Id,Total_Monthly_Income_Sum__c, Lead_Dedupe_Verified_By_Credit__c, Customer_Dedupe_Verified_By_Credit__c, Cibil_Report_Verified_by_Credit__c, KYC_Status__c, loan__r.Product__c,X2W_Risk_Category__c, Customer_Type__c, Customer_Name__c, CPV_Waive_off_Reason__c, RecordType.DeveloperName, Is_Lead_To_Customer_Partial_Match__c, Is_Lead_To_Customer_Full_Match__c, Is_Lead_To_Lead_Full_Match__c, Is_Lead_To_Lead_Partial_Match__c, Age__c, KYC_Type__c, Risk_Category__c, High_Risk_Profile__c, Negative_Area_Status__c, Type_Of_Employment__c, Internal_Risk_Score__c, PAN__c, Father_Name__c, First_Name__c, Middle_Name__c, FOIR__c, (SELECT Id, Bureau_Score__c, RecordType.Developername FROM Applicants__r WHERE RecordType.Developername=\'Additional_Match\' Order by Createddate Desc LIMIT 1), Last_Name__c, Constitution_Type__c, Gender__c, RecordType.Name, Marital_Status__c, Existing_Customer__c, Mobile_Number__c, Relationship_with_applicant__c, format(Dob__c), CIF_No__c, AML_Status__c, CFR_Status__c, Negative_Check_Status__c,PAN_verification_status__c, Bureau_Score__c, IsEmailVerified__c, Customer_Grade__c,'+
            '(SELECT Id, Document_Master__r.Document_Name__c, Applicant__c, Address_Match_Score__c, Name_Match_Score__c, Match_Percentage__c, Document_Master__r.Name, Document_Received_Date__c, Document_Expiry_Date__c FROM Document_Checklists__r WHERE Document_Master__r.Name in (\'AUWheels0002\',\'AUWheels0005\',\'AUWheels0004\',\'AUWheels0001\',\'AUWheels0093\',\'AUWheels0091\',\'AUWheels0107\', \'AUWheels0137\') Order by Document_Master__r.Document_Name__c, CreatedDate Desc),'+
            '(SELECT Geo_Limit__c, Applicant__c, Applicant__r.RecordType.DeveloperName, toLabel(Stability__c), Distance_from_Branch__c, Address_Type__c, Status__c,'+
            'Address_Line_1__c, Address_Line_2__c, Source_Type__c, Address_Line_3__c, City__c, State__c, Pincode__c, ETB_Address_Match_Score__c, CART_Address_Match_Score__c, Latest_Cibil_Address_Match_Score__c, Taluka__c, District__c,Village__c,Khata_Khasara_Survey_Number__c FROM Addresses__r WHERE Address_Type__c != null '+
            'AND (Source_Type__c = null OR Source_type__c=\'CBS\') Order by Applicant__r.RecordType.Name, CreatedDate Desc), '+
            '(SELECT Id, Agri_Land_in_Acres__c, Applicant__c FROM Applicant_Financials__r WHERE RecordType.DeveloperName=\'Financial_Parent\' AND isActive__c=true) '+

            'FROM Applicant__c WHERE Loan__c = :recordId AND isInactive__c=false AND RecordType.DeveloperName in (\'Primary_Applicant\',\'Co_Applicant\',\'Guarantor\') WITH SECURITY_ENFORCED Order by RecordType.Name, CreatedDate';
            applicants = Database.query(query);
            applicantIds=new List<Id>();
            addressList=new List<Address__c>();
            cpvDetails = new List<Document_Checklist__c>();
            //Get Cibil Address. 
            List<Address__c> cibilAddress = [Select Id, Source_Type__c, Pincode__c, Date_Reported__c, Address_Type__c From Address__c 
                                            where Source_Type__c = 'cibil' 
                                            AND Applicant__r.Loan__c =:recordId 
                                            AND Date_Reported__c != null];
            for(Applicant__c app: applicants){
                app.First_Name__c = app.First_Name__c!=null?app.First_Name__c:'';
                app.Middle_Name__c = app.Middle_Name__c!=null?app.Middle_Name__c:'';
                app.Last_Name__c = app.Last_Name__c!=null?app.Last_Name__c:'';
                applicantIds.add(app.Id);
                if(app.Document_Checklists__r!=null && app.Document_Checklists__r.size()>0){
                    for (Document_Checklist__c each : app.Document_Checklists__r) {
                        if (each.Document_Master__r.Name != 'AUWheels0137') {
                            cpvDetails.add(each);
                        }
                    }
                }if(app.Addresses__r!=null && app.Addresses__r.size()>0){
                    List<Address__c> addressListTemp = new List<Address__c>();
                    Map<String,Address__c> addMap = new Map<String,Address__c>();
                    for(Address__c add: app.Addresses__r){

                        if(!cibilAddress.isEmpty() && add.Address_Type__c == 'Current' && cibilAddress[0].Pincode__c == add.Pincode__c){
                            add.Date_Reported__c = cibilAddress[0].Date_Reported__c;
                            addressListOfCibilAddress.add(add);
                        }
                        String key = add.Source_Type__c!=null?add.Source_Type__c:'SF';
                        addMap.put(key+'_'+add.Address_Type__c, add);
                    }
                    if(addMap.containsKey('SF_Permanent')){
                        addressList.add(addMap.get('SF_Permanent'));
                    }else{
                        if(addMap.containsKey('CBS_Permanent')){
                            addressList.add(addMap.get('CBS_Permanent'));
                        }
                    }
                    if(addMap.containsKey('SF_Current')){
                        addressList.add(addMap.get('SF_Current'));
                    }else{
                        if(addMap.containsKey('CBS_Current')){
                            addressList.add(addMap.get('CBS_Current'));
                        }
                    }
                    if(addMap.containsKey('SF_Touch Point')){
                        addressList.add(addMap.get('SF_Touch Point'));
                    }else{
                        if(addMap.containsKey('CBS_Touch Point')){
                            addressList.add(addMap.get('CBS_Touch Point'));
                        }
                    }
                    if(addMap.containsKey('SF_Office')){
                        addressList.add(addMap.get('SF_Office'));
                    }else{
                        if(addMap.containsKey('CBS_Office')){
                            addressList.add(addMap.get('CBS_Office'));
                        }
                    }
                    if(addMap.containsKey('SF_Land')){
                        addressList.add(addMap.get('SF_Land'));
                    }else{
                        if(addMap.containsKey('CBS_Land')){
                            addressList.add(addMap.get('CBS_Land'));
                        }
                    }

                    
                    
                }
                
            }
            system.debug('addressList '+addressList);
        }
        //setBankRecords();
        if(applicants.size()>0)
            return applicants;
        else{
            applicants.add(new Applicant__c());
            return applicants;
        }
    }

    /*public static Collateral__c getCollateral(){
        List<Collateral__c> tempList = new List<Collateral__c>();
        if(recordId != null && String.isNotBlank(recordId)){
            String query = 'SELECT Id, Make__c, LTV__c, Vehicle_Category__c, Accessories__c, LS__c, Model__c, Variant__c, Manufacture_Year__c, Fuel_Type__c, Ex_Showroom_Price__c, Discount__c, Net_of_Discount_Price__c, Insurance__c, RTO_Tax_Value__c, On_Road_Price__c, Other_Costs__c, Apportioned_Loan_Amount__c, Customer_equity__c, Approved_LTV__c, LTV_offered_Ex_showroom__c,FOIR_Percentage__c , LTV_offered_On_road__c FROM Collateral__c WHERE Loan__c =:recordId AND RecordType.Developername in (\'New\',\'Used_Cash_on_Wheels\') WITH SECURITY_ENFORCED Order by CreatedDate Desc Limit 1';
            tempList = Database.query(query);
        }
        if(tempList.size()>0)
            return tempList[0];
        else{
            return new Collateral__c();
        }

    }*/

    public static List<Applicant_Financials_Details__c> getFinancial(){
        Map<Id, Applicant_Financials_Details__c> newMap= new Map<Id, Applicant_Financials_Details__c>();
        financial=new List<Applicant_Financials_Details__c>();
        if(applicantIds.size()>0){
            //String query = 'SELECT Id,applicant__c, applicant__r.RecordType.Name, Type_Of_Employment__c, Company_Name__c, Monthly_Income__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Average_Monthly_Salary__c,RecordType.DeveloperName, Monthly_Net_Profit__c, Applicant__r.Consolidation_Obligation__c, Applicant__r.FOIR__c FROM Applicant_Financials_Details__c WHERE  applicant__c in :applicantIds and RecordType.DeveloperName in (\'Financial_Parent\',\'Salaried_Document\',\'Assessed_No_Document\') WITH SECURITY_ENFORCED Order by applicant__r.RecordType.Name, CreatedDate';
            String query = 'SELECT Id,applicant__c, applicant__r.RecordType.Name, Type_Of_Employment__c, Monthly_Total_Income__c, Other_Income__c, Company_Name__c, Monthly_Income__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Average_Monthly_Salary__c,RecordType.DeveloperName, Monthly_Net_Profit__c, Applicant__r.Loan__r.Consolidation_Obligation__c, Applicant__r.RecordType.DeveloperName, Applicant__r.Loan__r.FOIR_Percentage__c, Company_Master__r.Company_Name__c FROM Applicant_Financials_Details__c WHERE  applicant__c in :applicantIds and RecordType.DeveloperName in (\'Financial_Parent\',\'Salaried_Document\',\'Assessed_No_Document\') AND Applicant__r.isInactive__c=false WITH SECURITY_ENFORCED Order by applicant__r.RecordType.Name, CreatedDate';

            financial = Database.query(query);
            for(Applicant_Financials_Details__c afd: financial){
                if(afd.RecordType.DeveloperName == 'Financial_Parent'){
                    newMap.put(afd.applicant__c, afd);
                }
                if(afd.Monthly_Income__c==null){
                    afd.Monthly_Income__c=0;
                }
                if(afd.Other_Income__c==null){
                    afd.Other_Income__c=0;
                }
            }  
            for(Applicant_Financials_Details__c afd: financial){
                if(newMap.containsKey(afd.applicant__c)){
                    if(afd.RecordType.DeveloperName == 'Salaried_Document'){
                        newMap.get(afd.applicant__c).Average_Monthly_Salary__c = afd.Average_Monthly_Salary__c;
                    }
                    if(afd.RecordType.DeveloperName == 'Assessed_No_Document'){
                        newMap.get(afd.applicant__c).Monthly_Net_Profit__c = afd.Monthly_Net_Profit__c;
                    }
                    
                }
            }
            if(newMap.values().size()>0){
                financial = newMap.values();
            }else{
                financial=new List<Applicant_Financials_Details__c>();
                financial.add(new Applicant_Financials_Details__c());
            }
            
        }
        if(financial.size()>0)
            return financial;
        else{
            financial=new List<Applicant_Financials_Details__c>();
            financial.add(new Applicant_Financials_Details__c());
            return financial;
        }
    }

    public static List<Applicant_Financials_Details__c> getFinancialsR2(){
        Map<Id, Applicant_Financials_Details__c> newMap= new Map<Id, Applicant_Financials_Details__c>();
        financialsR2=new List<Applicant_Financials_Details__c>();
        if(applicantIds.size()>0){
            //String query = 'SELECT Id,applicant__c, applicant__r.RecordType.Name, Type_Of_Employment__c, Company_Name__c, Monthly_Income__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Average_Monthly_Salary__c,RecordType.DeveloperName, Monthly_Net_Profit__c, Applicant__r.Consolidation_Obligation__c, Applicant__r.FOIR__c FROM Applicant_Financials_Details__c WHERE  applicant__c in :applicantIds and RecordType.DeveloperName in (\'Financial_Parent\',\'Salaried_Document\',\'Assessed_No_Document\') WITH SECURITY_ENFORCED Order by applicant__r.RecordType.Name, CreatedDate';
            String query = 'SELECT Id,applicant__c, applicant__r.RecordType.Name, Type_Of_Employment__c, Monthly_Total_Income__c, Total_Income__c, Other_Income__c, Company_Name__c, Monthly_Income__c, Total_Net_Income__c, Net_Annual_Income__c, Net_Revenue__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Average_Monthly_Salary__c,RecordType.DeveloperName, Monthly_Net_Profit__c, Applicant__r.Loan__r.Consolidation_Obligation__c, Applicant__r.RecordType.DeveloperName, Applicant__r.Loan__r.FOIR_Percentage__c, Company_Master__r.Company_Name__c, Applicant__r.Loan__r.EMI__c, Applicant__r.Loan__r.EMI_Frequency__c, Net_Surplus__c FROM Applicant_Financials_Details__c WHERE  applicant__c in :applicantIds AND Applicant__r.isInactive__c=false AND isActive__c=true WITH SECURITY_ENFORCED Order by applicant__r.RecordType.Name, CreatedDate';
            financialsR2 = Database.query(query);
        }
        if(!financialsR2.isEmpty())
            return financialsR2;
        else{
            financialsR2=new List<Applicant_Financials_Details__c>();
            financialsR2.add(new Applicant_Financials_Details__c());
            return financialsR2;
        }
    }

    public static List<Bank_Account_Records__c> returnAllBankRecords(List<Id> applicantId){
        List<Bank_Account_Records__c> bankRecs = new List<Bank_Account_Records__c>();
        if(applicantId!=null && applicantId.size()>0){
            String query;
            query = 'SELECT Track_Record__c ,OD_Limit_Sanctioned__c, Applicant__r.Applicant_Name__c, Applicant__r.Loan__r.EMI__c, InstallmentsOverDue__c, Is_Enquiry_Type__c, Applicant_Type__c, Average_Monthly_Balance__c, Average_Monthly_Credit__c, No_of_Bouncing__c, Total_Credit__c, Applicant__r.Name, Total_Debit__c, Inward_Cheque_Bounce__c, Current_Balance__c, Outward_Cheque_Bounce__c, Total_Salary__c, Payment_Frequency__c, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, Amount_Overdue__c, Highest_Overall_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Owenership_Indicator__c, Current_Status__c, Loan_Amount__c, Name_of_the_Financier__c, Type_of_Loan__c, Payment_History_Start_Date__c, Payment_History_End_Date__c, Date_Of_Enquiry__c, Customer_Relationship__c, Loan_Number__c, Account_Opening_Date__c,Account_Closing_Date__c, Account_Name__c,Account_Number__c,Bank_Name__c,Branch_Name__c,Account_Type__c,Statement_Start_Date__c,Statement_End_Date__c, EMI_Amount__c,RecordType.DeveloperName, Product__c, Product_Code__c, POS__c, Tenure__c, Applicant__r.First_Name__c, Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Applicant__r.RecordType.DeveloperName FROM Bank_Account_Records__c WHERE applicant__c in :applicantId AND RecordType.DeveloperName = \'CIBIL\' AND  Applicant__r.isInactive__c=false AND IsDeleted=false AND Is_Enquiry_Type__c=false WITH SECURITY_ENFORCED Order by CreatedDate Desc LIMIT '+System.Label.CIBIL_BANK_RECORDS_LIMIT;
            List<Bank_Account_Records__c> bankRecsCibil = new List<Bank_Account_Records__c>();
            bankRecsCibil = Database.query(query);
            String query1;
            List<Bank_Account_Records__c> bankRecsOthers = new List<Bank_Account_Records__c>();
            query1 = 'SELECT Track_Record__c ,OD_Limit_Sanctioned__c, Applicant__r.Applicant_Name__c, Applicant__r.Loan__r.EMI__c, InstallmentsOverDue__c, Is_Enquiry_Type__c, Applicant_Type__c, Average_Monthly_Balance__c, Average_Monthly_Credit__c, No_of_Bouncing__c, Total_Credit__c, Applicant__r.Name, Total_Debit__c, Inward_Cheque_Bounce__c, Current_Balance__c, Outward_Cheque_Bounce__c, Total_Salary__c, Payment_Frequency__c, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, Amount_Overdue__c, Highest_Overall_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Owenership_Indicator__c, Current_Status__c, Loan_Amount__c, Name_of_the_Financier__c, Type_of_Loan__c, Payment_History_Start_Date__c, Payment_History_End_Date__c, Date_Of_Enquiry__c, Customer_Relationship__c, Loan_Number__c, Account_Opening_Date__c,Account_Closing_Date__c, Account_Name__c,Account_Number__c,Bank_Name__c,Branch_Name__c,Account_Type__c,Statement_Start_Date__c,Statement_End_Date__c, EMI_Amount__c,RecordType.DeveloperName, Product__c, Product_Code__c, POS__c, Tenure__c, Applicant__r.First_Name__c, Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Applicant__r.RecordType.DeveloperName FROM Bank_Account_Records__c WHERE applicant__c in :applicantId AND RecordType.DeveloperName in (\'CBS\',\'Cart\') AND  Applicant__r.isInactive__c=false AND IsDeleted=false WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            bankRecsOthers = Database.query(query1);
            if(!bankRecsCibil.isEmpty()){
                bankRecs.addAll(bankRecsCibil);
            }
            if(!bankRecsOthers.isEmpty()){
                bankRecs.addAll(bankRecsOthers);
            }
            //more than 2k cibil records were found for 1 applicant due to which CAM limit size was exceeded. added 100 limit for cibil records
            //String query = 'SELECT Track_Record__c ,OD_Limit_Sanctioned__c, Applicant__r.Applicant_Name__c, Applicant__r.Loan__r.EMI__c, InstallmentsOverDue__c, Is_Enquiry_Type__c, Applicant_Type__c, Average_Monthly_Balance__c, Average_Monthly_Credit__c, No_of_Bouncing__c, Total_Credit__c, Applicant__r.Name, Total_Debit__c, Inward_Cheque_Bounce__c, Current_Balance__c, Outward_Cheque_Bounce__c, Total_Salary__c, Payment_Frequency__c, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, Amount_Overdue__c, Highest_Overall_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Owenership_Indicator__c, Current_Status__c, Loan_Amount__c, Name_of_the_Financier__c, Type_of_Loan__c, Payment_History_Start_Date__c, Payment_History_End_Date__c, Date_Of_Enquiry__c, Customer_Relationship__c, Loan_Number__c, Account_Opening_Date__c,Account_Closing_Date__c, Account_Name__c,Account_Number__c,Bank_Name__c,Branch_Name__c,Account_Type__c,Statement_Start_Date__c,Statement_End_Date__c, EMI_Amount__c,RecordType.DeveloperName, Product__c, Product_Code__c, POS__c, Tenure__c, Applicant__r.First_Name__c, Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Applicant__r.RecordType.DeveloperName FROM Bank_Account_Records__c WHERE applicant__c in :applicantId AND RecordType.DeveloperName in (\'CBS\',\'Cart\',\'CIBIL\') AND  Applicant__r.isInactive__c=false WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            //bankRecs = Database.query(query);   
        }
        return bankRecs;
    }

    public static List<Bank_Account_Records__c> getCbsCibilLoanRecords(){
        List<Bank_Account_Records__c> cbsCibilLoanRecords = new List<Bank_Account_Records__c>();
        if(applicantIds!=null && applicantIds.size()>0){
            String query = 'SELECT Is_Enquiry_Type__c, Applicant__c, EMI_Amount__c FROM Bank_Account_Records__c'+
            ' WHERE applicant__c in :applicantIds AND ((RecordType.DeveloperName = \'CBS\' AND is_CBS_Running_Loan__c=true) OR (RecordType.DeveloperName = \'CIBIL\' AND Is_Enquiry_Type__c=false AND EMI_Considered_for_Obligation__c=\'Yes\')) AND  Applicant__r.isInactive__c=false WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            cbsCibilLoanRecords = Database.query(query);   
        }
        return cbsCibilLoanRecords;
    }

    public static void setBankRecords(){
        allBankRecords= returnAllBankRecords(applicantIds);
        cbsRecordsFD=new List<Bank_Account_Records__c>();
        cbsRecords=new List<Bank_Account_Records__c>();
        cartRecords=new List<Bank_Account_Records__c>();
        cibilRecords=new List<Bank_Account_Records__c>();
        applicantExposure=new List<Bank_Account_Records__c>();
        for(Bank_Account_Records__c bank : allBankRecords){
            //if(bank.Applicant__c == applicant.Id){
                if(bank.RecordType.DeveloperName == 'CBS'){
                    //if(bank.Account_Type__c=='FDRDA'){
                    if(bank.Account_Type__c=='CASA' ||  bank.Account_Type__c == GlobalConstants.FDRD){ //SFAU-4752
                        cbsRecordsFD.add(bank);
                    }
                    if(bank.Applicant__c == applicant.Id){
                        if(bank.Account_Type__c=='Loan' || bank.Account_Type__c=='ODCC'){
                            cbsRecords.add(bank);
                            if(bank.Applicant_Type__c=='Co-Applicant'||bank.Applicant_Type__c=='Guarantor'){
                                applicantExposure.add(bank);
                            }
                        }
                    }
                    
                }
                if(bank.RecordType.DeveloperName == 'Cart'){
                    cartRecords.add(bank);
                }
                if(bank.RecordType.DeveloperName == 'CIBIL' && bank.Is_Enquiry_Type__c==false){
                    bank.EMI_Amount__c = bank.EMI_Amount__c != null ? Integer.valueOf(bank.EMI_Amount__c) : null;
                    cibilRecords.add(bank);
                }  
            //}
        }
    }

    /*public static List<Fleet__c> getFleetRecords(){
        fleetRecords = new List<Fleet__c>();
        if(recordId!=null && String.isNotBlank(recordId)){
            String query = 'SELECT Name, Relationship_with_borrower__c, Vehicle_Number__c, Vehicle_Make_Model__c,MFG_Year__c, HPN_Status__c, Financial_Institution_Name__c, Loan_Tenure__c, Installment_Paid__c FROM Fleet__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            fleetRecords = Database.query(query);
            
        }
        return fleetRecords;
    }

    public static List<TVR__c> getTvrRecords(){
        tvrRecords = new List<TVR__c>();
        if(recordId!=null && String.isNotBlank(recordId)){
            String query = 'SELECT Name, TVR_Date__c, Name_Of_Employee__c, Employee_ID__c, TVR_Done_With__c, Mobile_Number__c, Remark__c, Loan_Application__c FROM TVR__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            tvrRecords = Database.query(query);
            
        }
        return tvrRecords;
    }*/

    /*public static List<Loan_Application_Approval__c> getLoanAppApprovalRecords(){
        loanAppApprovalRecords = new List<Loan_Application_Approval__c>();
        if(recordId!=null && String.isNotBlank(recordId)){
            String query = 'SELECT Name, Decision__c, Remarks__c, Approver__r.Username, Approver__r.Id, Decision_Date_Time__c, Approver_Level__c, Deviation_Level__c FROM Loan_Application_Approval__c WHERE Loan_Application__c = :recordId AND Is_Assigned_Approver__c=true WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            loanAppApprovalRecords = Database.query(query);
            
        }
        return loanAppApprovalRecords;
    }*/
    
    /*public static List<Deviation__c> getDeviationRecords(){
        deviationRecords = new List<Deviation__c>();
        system.debug('recordId '+recordId);
        if(recordId!=null && String.isNotBlank(recordId)){
            String query = 'SELECT Department__c, Deviation_Type__c, Details__c, Policy_Value__c, Actual_Value__c, Variance__c, Level__c FROM Deviation__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED Order by CreatedDate Desc';
            deviationRecords = Database.query(query);
            system.debug('Deviations '+deviationRecords);
        }
        return deviationRecords;
    }*/

    public static List<FISummaryViewWrapper> getFiStatusRecords(){
        fiStatusRecords = new List<FISummaryViewWrapper>();
        if(recordId!=null && String.isNotBlank(recordId)){
            fiStatusRecords=FieldInvestigationUtility.getFISummary(recordId,'');            
        }
        system.debug('fiStatusRecords '+fiStatusRecords);
        return fiStatusRecords;
    }
    
   
}