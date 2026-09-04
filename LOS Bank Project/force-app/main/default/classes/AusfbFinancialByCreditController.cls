/**
 * @description       : Financial template which is filled by credit team in case of new Comm
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-13-2023
 * @last modified by  : Ajitesh
**/
public with sharing class AusfbFinancialByCreditController {

    // Deviation literals
    public static final String FINANCIAL_TEMPLATE_CREDIT_DEVIATION_TYPE = 'Financial Template - Credit';
    public static final String DEVIATION_SOURCE = 'SF';
    // Deviation Type literals
    
    // Record type values
    public static final String COMMERCIAL_FINANCIAL_RECORD_TYPE = 'Commercial_financial_format';
    public static final String APPLICANT_FINANCIAL_DETAIL_PARENT_RECORD_TYPE = 'Financial_Parent';
    // Record type values

    // Config Setup Literals
    public static final String CONFIG_RECORD_TYPE_APPLICABLE = 'Applicants_Type_visible_Record_Type';
    public static final String CONFIG_PROFILE_EDITABLE = 'Comma_Seperated_Profile_who_can_edit';
    public static final String CONFIG_STAGE_APPLICABLE = 'Comma_Seperated_Stage_Applicable_On';
    public static final String CONFIG_PRODUCT_APPLICABLE = 'FInancial_Template_Product_Applicable';
    public static final String CONFIG_COMPONENT_NAME = 'Financial Template';
    public static final String CONGIF_VALIDATION_ONLY_LITERAL = 'Validation Condition';
    // Config Setup Literals

    // Individual and Non-Individual Mandatory Customer type literals
    public static final String INDIVIDUAL_CUSTOMER_TYPE = 'Individual';
    public static final String NON_INDIVIDUAL_CUSTOMER_TYPE = 'Non Individual';
    // Individual and Non-Individual Mandatory Customer type literals


    /**
    * @description Comparing Loan level fields with metadata config
    * @author Ajitesh | 10-27-2023 
    * @param configMetadata 
    * @param applicantData 
    * @return Boolean 
    **/
    public static Boolean mandatoryCheckForLoanLevelFields(
        AUSFB_Finance_WorkOrder_By_Credit_Config__mdt configMetadata,
        Applicant__c applicantData
    ){
        // Loan Amount check
        if(configMetadata.Amount_Greater_Than_Equal_to_lacs__c != null){
            if(applicantData.Loan__r.Loan_Amount__c <  configMetadata.Amount_Greater_Than_Equal_to_lacs__c) return false;
        }

        // Collateral Type check
        if(configMetadata.Collateral_Type__c != null){
            Boolean isMatched = false;
            for(String collateralType : configMetadata.Collateral_Type__c.split(',')){
                if(applicantData.Loan__r.Collateral_Type__c == collateralType.trim()){
                    isMatched = true;
                    break;
                }
            }
            
            if(!isMatched){
                return false;
            }
        }

        // Customer Grade Type check
        if(configMetadata.Customer_Grade__c != null){
            Boolean isMatched = false;
            for(String customerGrade : configMetadata.Customer_Grade__c.split(',')){
                if(applicantData.Loan__r.Customer_Grade__c == customerGrade.trim()){
                    isMatched = true;
                    break;
                }
            }
            
            if(!isMatched){
                return false;
            }
        }

        // Sub Grade match
        if(configMetadata.Sub_Grade__c != null){
            Boolean isMatched = false;
            for(String subGrade : configMetadata.Sub_Grade__c.split(',')){
                if(applicantData.Loan__r.Sub_Grade__c == subGrade.trim()){
                    isMatched = true;
                    break;
                }
            }
            
            if(!isMatched){
                return false;
            }
        }

        return true;
    }

    /**
    * @description Comparing Applicant level data with Metadata config
    * @author Ajitesh | 10-27-2023 
    * @param configMetadata 
    * @param applicantData 
    * @return Boolean 
    **/
    public static Boolean mandatoryCheckForApplicantLevelFields(
        AUSFB_Finance_WorkOrder_By_Credit_Config__mdt configMetadata,
        Applicant__c applicantData
    ){
        // Customer Type check
        if(configMetadata.Customer_Type__c != null){
            Boolean isMatched = false;
            for(String subGrade : configMetadata.Customer_Type__c.split(',')){
                if(applicantData.Customer_Type__c == subGrade.trim() && applicantData.Constitution_Type__c !='Sole Proprietary'){
                    isMatched = true;
                    break;
                }
            }
            
            if(!isMatched){
                return false;
            }
        }

        // No of months date of establishment check
        if(configMetadata.No_Of_Months_Date_Of_Establishment_more__c != null && applicantData.Date_of_Establishment__c != null){
            Date currentDate = Date.today(); // Current date
            Date dateFieldValue = applicantData.Date_of_Establishment__c;
            Integer monthsDifference = dateFieldValue.monthsBetween(currentDate);
            
            if(monthsDifference < configMetadata.No_Of_Months_Date_Of_Establishment_more__c){
                return false;
            }
        }

        return true;
    
    }

    /**
    * @description check for conditions at Applicant Financial levels
    * @author Ajitesh | 10-27-2023 
    * @param configMetadata 
    * @param applicantData 
    * @return Boolean 
    **/
    public static Boolean mandatoryCheckForApplicantFinancialLevelFields(
        AUSFB_Finance_WorkOrder_By_Credit_Config__mdt configMetadata,
        Applicant__c applicantData
    ){
        // Customer Type check
        if(configMetadata.Method_of_Assessment__c != null){
            Boolean isMatched = false;
            for(String assesmentType : configMetadata.Method_of_Assessment__c.split(',')){
                for(Applicant_Financials_Details__c applicantFinanceDetail : applicantData.Applicant_Financials__r){
                    if(applicantFinanceDetail.Method_Of_Assesment__c == assesmentType.trim()){
                        isMatched = true;
                        break;
                    }
                }
                
            }
            
            if(!isMatched){
                return false;
            }
        }

        return true;
    
    }




    /**
    * @description Check if the applicants are valid for mandatory check
    * @author Ajitesh | 10-27-2023 
    * @return Boolean 
    **/
    public static Boolean isApplicantApplicableForValidation(Applicant__c applicantData){
        AUSFB_Finance_WorkOrder_By_Credit_Config__mdt applicableProductRecords = AUSFB_Finance_WorkOrder_By_Credit_Config__mdt.getInstance('Credit_CV_and_CE_product_validate');

        Boolean isMatched = false;
        for(String applicableProduct : applicableProductRecords.Metadata_Value__c.split(',')){
            if(applicantData.Loan__r.Product__c == applicableProduct.trim()){
                isMatched = true;
                break;
            }
        }
        
        if(!isMatched){
            return false;
        }

        AUSFB_Finance_WorkOrder_By_Credit_Config__mdt applicableRecordType = AUSFB_Finance_WorkOrder_By_Credit_Config__mdt.getInstance('Applicants_Type_visible_Record_Type');

        isMatched = false;
        for(String applicableRecordTypeTemp : applicableRecordType.Metadata_Value__c.split(',')){
            if(applicantData.RecordType.DeveloperName == applicableRecordTypeTemp.trim()){
                isMatched = true;
                break;
            }
        }

        return isMatched;
    } 

    /**
    * @description Financial Template by credit check for mandatory conditions
    * @author Ajitesh | 10-27-2023 
    **/
    @AuraEnabled
    public static String isFinancialTemplateConditionMatchNDataNotFilled(Id loanId){
        try{
            List<AUSFB_Finance_WorkOrder_By_Credit_Config__mdt> configData = AUSFB_Finance_WorkOrder_By_Credit_Config__mdt.getAll().values();
        
            Set<String> applicantAndCoApplicantNames = new Set<String>();
            
            // Query for validation check and error display
            for(Applicant__c applicant : [SELECT Applicant_Name__c, Loan__r.Sub_Grade__c, Loan__r.Product__c, Loan__r.Loan_Amount__c, Date_of_Establishment__c, Loan__r.Collateral_Type__c, Loan__r.Customer_Grade__c, Customer_Type__c, RecordType.DeveloperName, Constitution_Type__c, 
                (SELECT Method_Of_Assesment__c, Capital_Funds__c, Reserves_surplus__c, Add_Less_Profit_Loss_for_the_year__c, 
                Total_Networth__c, Secured_loans__c, Unsecured_loans_from_Family_member_frien__c, 
                Unsecured_loans_from_Others__c, Bank_OD_CC_Limits__c, Deferred_tax_balance__c, Current_Liability_Provisions__c,
                Sundry_Creditors_in_above__c, Total_Liabilities__c, Total_long_term_liabilities__c,
                Fixed_Assets__c, Investment__c, Current_Assets_Loans_Adv_Others__c, Debtors_as_in_Above__c,
                Total_Assets__c, Sales_Income__c, Other_Income_Income_not_relevant_to_key__c,
                Total_Income__c, Administrative_Expenses__c, Depreciation__c, Net_Profit__c,
                Tax_Expense__c, Financial_Expenses_Interest_on_SL_Ban__c, Cash_Profits_Depreciation_Net_Profit__c, 
                PBDIT_Profit_before_depreciation_inter__c, Sundry_Debtors_6_months__c, Sundry_Debtors_less_6_months__c, 
                Total_Sundry_Debtors__c, ICOR_Interest_coverage_ratio__c, DSCR_Debt_Service_Coverage_Ratio__c, 
                Current_Ratio__c, Leverage__c, Long_term_leverage_Debt_Equity_Ratio__c, Debtor_Turnover_Days__c, 
                Creditor_Turnover_Days__c, NW__c, Turnover__c, Change_Net_Profit__c, Change_Cash_Profit__c, 
                Net_worth_to_be_ve__c, Strategic_Secured_Loans__c, Strategic_Fixed_Assets__c, Strategic_Turnover__c, 
                Strategic_PBT__c, Strategic_Cash_Profit__c, Strategic_YOY_Turnover_to_be_ve__c, 
                Strategic_Cash_Profit_of_current_year_to__c, DSCR_should_be_1_1__c, Strategic_Debt_Equity_Ratio_including_p__c, 
                Strategic_Drs_Turnover_should_be_90__c, Id, Credit_Financial_Date__c, RecordType.DeveloperName
                FROM Applicant_Financials__r WHERE RecordType.DeveloperName = :APPLICANT_FINANCIAL_DETAIL_PARENT_RECORD_TYPE OR  RecordType.DeveloperName = :COMMERCIAL_FINANCIAL_RECORD_TYPE) 
                FROM Applicant__c WHERE Loan__c = :loanId AND (RecordType.DeveloperName = 'Primary_Applicant' OR RecordType.DeveloperName = 'Co_Applicant') AND IsInactive__c = false WITH SECURITY_ENFORCED]){
                
                if(isApplicantApplicableForValidation(applicant)){
                    
                    for(AUSFB_Finance_WorkOrder_By_Credit_Config__mdt tempConfig : configData){
                        
                        if(tempConfig.Metadata_Value__c == null && tempConfig.Component__c == CONGIF_VALIDATION_ONLY_LITERAL){
                            if(
                                mandatoryCheckForLoanLevelFields(tempConfig, applicant) &&
                                mandatoryCheckForApplicantLevelFields(tempConfig, applicant) && 
                                mandatoryCheckForApplicantFinancialLevelFields(tempConfig, applicant) &&
                                isFinancialTemplateNotFilledForAllApplicant(applicant)
                            ){
                                applicantAndCoApplicantNames.add(applicant.Applicant_Name__c);
                            }
                        }
                    }
                }
            }
            if(applicantAndCoApplicantNames.size() > 0){
                return String.join((Iterable<String>)applicantAndCoApplicantNames, ', ');
            }
            return 'no-error';
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /**
    * @description Check if template is filled or not
    * @author Ajitesh | 10-27-2023 
    * @param applicantData 
    **/
    public static Boolean isFinancialTemplateNotFilledForAllApplicant(Applicant__c applicantData){

        for(Applicant_Financials_Details__c applicantFinancials : applicantData.Applicant_Financials__r){
            if(applicantFinancials.RecordType.DeveloperName == COMMERCIAL_FINANCIAL_RECORD_TYPE){
                if(checkIfAllTheFieldAreFilled(applicantFinancials)){
                   return false; 
                }
            }
        }
        return true;
    }


    /**
    * @description Check if all the fields for the current year is filled or not
    * @author Ajitesh | 10-27-2023 
    * @param applicantFinanceDetail 
    * @return boolean 
    **/
    public static Boolean checkIfAllTheFieldAreFilled(Applicant_Financials_Details__c applicantFinanceDetail){
        
        Set<String> fieldAPINameSet = new Set<String>{'Capital_Funds__c', 'Reserves_surplus__c', 'Add_Less_Profit_Loss_for_the_year__c', 
            'Total_Networth__c', 'Secured_loans__c', 'Unsecured_loans_from_Family_member_frien__c', 
            'Unsecured_loans_from_Others__c', 'Bank_OD_CC_Limits__c', 'Deferred_tax_balance__c', 'Current_Liability_Provisions__c',
            'Sundry_Creditors_in_above__c', 'Total_Liabilities__c', 'Total_long_term_liabilities__c',
            'Fixed_Assets__c', 'Investment__c', 'Current_Assets_Loans_Adv_Others__c', 'Debtors_as_in_Above__c',
            'Total_Assets__c', 'Sales_Income__c', 'Other_Income_Income_not_relevant_to_key__c',
            'Total_Income__c', 'Administrative_Expenses__c', 'Depreciation__c', 'Net_Profit__c',
            'Tax_Expense__c', 'Financial_Expenses_Interest_on_SL_Ban__c', 'Cash_Profits_Depreciation_Net_Profit__c', 
            'PBDIT_Profit_before_depreciation_inter__c', 'Sundry_Debtors_6_months__c', 'Sundry_Debtors_less_6_months__c', 
            'Total_Sundry_Debtors__c', 'ICOR_Interest_coverage_ratio__c', 'DSCR_Debt_Service_Coverage_Ratio__c', 
            'Current_Ratio__c', 'Leverage__c', 'Long_term_leverage_Debt_Equity_Ratio__c', 'Debtor_Turnover_Days__c', 
            'Creditor_Turnover_Days__c', 'NW__c', 'Turnover__c', 'Change_Net_Profit__c', 'Change_Cash_Profit__c', 
            'Net_worth_to_be_ve__c', 'Strategic_Secured_Loans__c', 'Strategic_Fixed_Assets__c', 'Strategic_Turnover__c', 
            'Strategic_PBT__c', 'Strategic_Cash_Profit__c', 'Strategic_YOY_Turnover_to_be_ve__c', 
            'Strategic_Cash_Profit_of_current_year_to__c', 'DSCR_should_be_1_1__c', 'Strategic_Debt_Equity_Ratio_including_p__c', 
            'Strategic_Drs_Turnover_should_be_90__c', 'Id', 'Credit_Financial_Date__c'};
        
        
        for(String fieldAPI : fieldAPINameSet){
            if(applicantFinanceDetail.get(fieldAPI) == null){
                System.debug(applicantFinanceDetail.get(fieldAPI) + ' fieldAPI ' + fieldAPI + ' applicantFinanceDetail.Id ' + applicantFinanceDetail.Id);
                return false;
            }
        }

        return true;
    }

    

    /**
    * @description Getting the config data to setup up UI
    * @author Ajitesh | 10-24-2023 
    * @return List<AUSFB_Finance_WorkOrder_By_Credit_Config__mdt> 
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String,Boolean> viewAndEditRight(Id applicantId){
        try {
            
            Map<String, Boolean> viewEditRightStore = new Map<String, Boolean>{'visible' => true, 'editable' => true};

            Applicant__c applicantLoanLevelDetail = [SELECT Loan__r.Product__c, Loan__r.Stage__c, RecordType.DeveloperName FROM Applicant__c WHERE Id = :applicantId WITH SECURITY_ENFORCED];

            String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

            for(AUSFB_Finance_WorkOrder_By_Credit_Config__mdt setupData : 
            [SELECT Order__c, MasterLabel, DeveloperName, Amount_Greater_Than_Equal_to_lacs__c, 
            Collateral_Type__c, Customer_Grade__c, Customer_Type__c, Metadata_Value__c, No_Of_Months_Date_Of_Establishment_more__c 
            FROM AUSFB_Finance_WorkOrder_By_Credit_Config__mdt WHERE (NOT Label LIKE 'Condition%') AND Component__c = :CONFIG_COMPONENT_NAME WITH SECURITY_ENFORCED ORDER BY Order__c ASC
            ]
            ){

                // Product check
                if(setupData.DeveloperName == CONFIG_PRODUCT_APPLICABLE ){
                    boolean foundMatch = false;
                    for(String recordType : setupData.Metadata_Value__c.split(',')){
                        if(applicantLoanLevelDetail.Loan__r.Product__c == recordType.trim()){
                            foundMatch = true;
                            break;
                        }
                    }
                    if(!foundMatch){
                        viewEditRightStore.put('visible', false);
                        break;
                    }
                }


                // Record Type check
                if(setupData.DeveloperName == CONFIG_RECORD_TYPE_APPLICABLE ){
                    boolean foundMatch = false;
                    for(String recordType : setupData.Metadata_Value__c.split(',')){
                        if(applicantLoanLevelDetail.RecordType.DeveloperName == recordType.trim()){
                            foundMatch = true;
                            break;
                        }
                    }
                    if(!foundMatch){
                        viewEditRightStore.put('visible', false);
                        break;
                    }
                }

                // Stage Check
                if(setupData.DeveloperName == CONFIG_STAGE_APPLICABLE ){
                    boolean foundMatch = false;
                    for(String stageType : setupData.Metadata_Value__c.split(',')){
                        if(applicantLoanLevelDetail.Loan__r.Stage__c == stageType.trim()){
                            foundMatch = true;
                            break;
                        }
                    }
                    if(!foundMatch){
                        viewEditRightStore.put('visible', false);
                        break;
                    }
                }

                // Editable non editable based on Profiles
                if(setupData.DeveloperName == CONFIG_PROFILE_EDITABLE ){
                    boolean foundMatch = false;
                    for(String profileNameValue : setupData.Metadata_Value__c.split(',')){
                        if(profileName == profileNameValue.trim()){
                            foundMatch = true;
                            break;
                        }
                    }
                    if(!foundMatch){
                        viewEditRightStore.put('editable', false);
                    }
                    
                }
            }
            
            return viewEditRightStore;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Upserting data from the form into DB
    * @author Ajitesh | 10-22-2023 
    * @param applicantFinanceDetails 
    * @param securedLoansJSON 
    * @param totalPOS 
    * @param totalCountOfMonthFY 
    * @param totalBalanceTenor 
    * @param totalPrincipal 
    **/
    @AuraEnabled
    public static void insertFinancialDetails(
        List<Applicant_Financials_Details__c> applicantFinanceDetails,
        String securedLoansJSON,
        Double totalPOS,
        Double totalCountOfMonthFY,
        Double totalBalanceTenor,
        Double totalPrincipal,
        Id parentApplicantDetailId
        ){
        try {

            RecordType commercialRecordType = [
                SELECT Id FROM RecordType WHERE DeveloperName = :COMMERCIAL_FINANCIAL_RECORD_TYPE WITH SECURITY_ENFORCED
                ];

            Applicant_Financials_Details__c parentApplicantDetail = new Applicant_Financials_Details__c(
                Id = parentApplicantDetailId,
                Break_up_of_Secured_loans__c = securedLoansJSON,
                Total_POS__c = totalPOS,
                Total_Count_of_months_in_FY__c = totalCountOfMonthFY,
                Total_Balance_Tenor_years__c = totalBalanceTenor,
                Total_Principal_Paid_liability__c = totalPrincipal
            );

            // Updating RecordType Id
            for(Applicant_Financials_Details__c tempFinancieDetail : applicantFinanceDetails){
                tempFinancieDetail.RecordTypeId = commercialRecordType.Id;
                tempFinancieDetail.Applicant_Financials__c = parentApplicantDetailId;
            }

            List<Sobject> objectToUpdateInsert = new List<SObject>();
            objectToUpdateInsert.add(parentApplicantDetail);
            objectToUpdateInsert.addAll(applicantFinanceDetails);

            Database.upsert(objectToUpdateInsert, AccessLevel.USER_MODE);

        } catch (Exception e) {
            System.debug('Something went wrong ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Getting initial parent applicant finance, 3 child finance detail
    * @author Ajitesh | 10-22-2023 
    * @param applicantId 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static List<Applicant_Financials_Details__c> getInitialData(Id applicantId){
        try {

            List<Applicant_Financials_Details__c> applicantFinancialsList = new List<Applicant_Financials_Details__c>();

            Applicant_Financials_Details__c parentFinanceDetail = [
                SELECT Total_POS__c, Total_Count_of_months_in_FY__c, Total_Balance_Tenor_years__c,
                Total_Principal_Paid_liability__c, Break_up_of_Secured_loans__c, Id, 
                Applicant__r.Loan__r.Total_Loan_Amount__c
                FROM Applicant_Financials_Details__c 
                WHERE Applicant__c = :applicantId AND RecordType.DeveloperName = :APPLICANT_FINANCIAL_DETAIL_PARENT_RECORD_TYPE
                WITH SECURITY_ENFORCED
            ];

            List<Applicant_Financials_Details__c> creditFinancials = [
                SELECT Capital_Funds__c, Reserves_surplus__c, Add_Less_Profit_Loss_for_the_year__c, 
                Total_Networth__c, Secured_loans__c, Unsecured_loans_from_Family_member_frien__c, 
                Unsecured_loans_from_Others__c, Bank_OD_CC_Limits__c, Deferred_tax_balance__c, Current_Liability_Provisions__c,
                Sundry_Creditors_in_above__c, Total_Liabilities__c, Total_long_term_liabilities__c,
                Fixed_Assets__c, Investment__c, Current_Assets_Loans_Adv_Others__c, Debtors_as_in_Above__c,
                Total_Assets__c, Sales_Income__c, Other_Income_Income_not_relevant_to_key__c,
                Total_Income__c, Administrative_Expenses__c, Depreciation__c, Net_Profit__c,
                Tax_Expense__c, Financial_Expenses_Interest_on_SL_Ban__c, Cash_Profits_Depreciation_Net_Profit__c, 
                PBDIT_Profit_before_depreciation_inter__c, Sundry_Debtors_6_months__c, Sundry_Debtors_less_6_months__c, 
                Total_Sundry_Debtors__c, ICOR_Interest_coverage_ratio__c, DSCR_Debt_Service_Coverage_Ratio__c, 
                Current_Ratio__c, Leverage__c, Long_term_leverage_Debt_Equity_Ratio__c, Debtor_Turnover_Days__c, 
                Creditor_Turnover_Days__c, NW__c, Turnover__c, Change_Net_Profit__c, Change_Cash_Profit__c, 
                Net_worth_to_be_ve__c, Strategic_Secured_Loans__c, Strategic_Fixed_Assets__c, Strategic_Turnover__c, 
                Strategic_PBT__c, Strategic_Cash_Profit__c, Strategic_YOY_Turnover_to_be_ve__c, 
                Strategic_Cash_Profit_of_current_year_to__c, DSCR_should_be_1_1__c, Strategic_Debt_Equity_Ratio_including_p__c, 
                Strategic_Drs_Turnover_should_be_90__c, Id, Credit_Financial_Date__c FROM Applicant_Financials_Details__c 
                WHERE Applicant__c = :applicantId AND Applicant_Financials__c = :parentFinanceDetail.Id AND 
                RecordType.DeveloperName = :COMMERCIAL_FINANCIAL_RECORD_TYPE 
                WITH SECURITY_ENFORCED ORDER BY Credit_Financial_Date__c DESC
            ];

            applicantFinancialsList.add(parentFinanceDetail);
            applicantFinancialsList.addAll(creditFinancials);

            return applicantFinancialsList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    /**
    * @description Create or archive existing deviation based on financial template conditions
    * @author Ajitesh | 10-29-2023 
    * @param loanId 
    **/
    @AuraEnabled
    public static void createOrArchiveDeviationFinancialTemplate(Id loanId){
        try {

            Boolean isDeviationCreatedOnce = false;

            for(Applicant__c applicant : [SELECT Id, Loan__c, Applicant_Name__c, 
            (SELECT Strategic_YOY_Turnover_to_be_ve__c, Strategic_Cash_Profit_of_current_year_to__c, 
            DSCR_should_be_1_1__c, Strategic_Debt_Equity_Ratio_including_p__c, Strategic_Drs_Turnover_should_be_90__c 
            FROM Applicant_Financials__r WHERE RecordType.DeveloperName = :COMMERCIAL_FINANCIAL_RECORD_TYPE ORDER BY 
            Credit_Financial_Date__c DESC LIMIT 2 ) FROM Applicant__c WHERE Loan__c = :loanId WITH SECURITY_ENFORCED]){
                
                String deviationDetail = ifDeviationToBeCreated(applicant);
                // If Deviation is to be created, create and break loop
                if(deviationDetail.length() != 0){
                    Id deviationId = checkIfDeviationIsAlreadyCreated(loanId);
                    if(deviationId == null){
                        createNewDeviation(loanId,  deviationDetail);
                    }
                    else{
                        Deviation__c devRec = new Deviation__c(
                            Id = deviationId,
                            Details__c = deviationDetail
                        );
                        Database.update(devRec, AccessLevel.USER_MODE);
                    }
                    isDeviationCreatedOnce = true;
                    break;
                }
            }

            // Check if deviation doesn't need to be create, delet existing one
            if(!isDeviationCreatedOnce){
                Id deviationId = checkIfDeviationIsAlreadyCreated(loanId);
                if(deviationId != null){
                    Deviation__c devRec = new Deviation__c(
                        Id = deviationId,
                        Active__c = false,
                        Archived__c = true
                    );
                    Database.update(devRec, AccessLevel.USER_MODE);
                    return;
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Check if deviation needs to be created
    * @author Ajitesh | 10-29-2023 
    * @param applicant 
    * @return Boolean 
    **/
    public static String ifDeviationToBeCreated(Applicant__c applicant){
        String deviationMessage = '';
        
        Map<String,Schema.SObjectField> mfields = Schema.Applicant_Financials_Details__c.SObjectType.getDescribe().fields.getMap();
        

        for(Applicant_Financials_Details__c applicantFinancial : applicant.Applicant_Financials__r){
            System.debug(applicantFinancial.Strategic_Cash_Profit_of_current_year_to__c + ' Temperature');
            if(applicantFinancial.Strategic_YOY_Turnover_to_be_ve__c < 0){
                Schema.DescribeFieldResult fieldResult = mfields.get('Strategic_YOY_Turnover_to_be_ve__c').getDescribe();
                deviationMessage += fieldResult.getLabel() + ' value is negative,';

            }
            if(applicantFinancial.Strategic_Cash_Profit_of_current_year_to__c < 0){
                Schema.DescribeFieldResult fieldResult = mfields.get('Strategic_Cash_Profit_of_current_year_to__c').getDescribe();
                deviationMessage += fieldResult.getLabel() + ' value is negative,';
            }
            if(applicantFinancial.DSCR_should_be_1_1__c < 0){
                Schema.DescribeFieldResult fieldResult = mfields.get('DSCR_should_be_1_1__c').getDescribe();
                deviationMessage += fieldResult.getLabel() + ' value is negative,';
            }
            if(applicantFinancial.Strategic_Debt_Equity_Ratio_including_p__c < 0){
                Schema.DescribeFieldResult fieldResult = mfields.get('Strategic_Debt_Equity_Ratio_including_p__c').getDescribe();
                deviationMessage += fieldResult.getLabel() + ' value is negative,';
            }
            if(applicantFinancial.Strategic_Drs_Turnover_should_be_90__c < 0){
                Schema.DescribeFieldResult fieldResult = mfields.get('Strategic_Drs_Turnover_should_be_90__c').getDescribe();
                deviationMessage += fieldResult.getLabel() + ' value is negative,';
            }
            
        }

        if(deviationMessage.length() != 0){
            deviationMessage = 'Financial Template by deviation, Applicant Name : ' + applicant.Applicant_Name__c + ' ' + deviationMessage;
        }

        return deviationMessage;
    }

    /**
    * @description Create a new deviation
    * @author Ajitesh | 10-29-2023 
    * @param loanId 
    **/
    public static void createNewDeviation(Id loanId, String deviationDetail){
        Deviation__c devRec = new Deviation__c(
            Loan_Application__c = loanId,
            Active__c = true,
            Archived__c = false,
            Details__c = deviationDetail,
            Source__c = DEVIATION_SOURCE,
            Level__c = System.Label.Financial_Template_By_Credit_Deviation_Level,
            Deviation_Type__c = FINANCIAL_TEMPLATE_CREDIT_DEVIATION_TYPE
        );

        Database.insert(devRec, AccessLevel.USER_MODE);
    }

    /**
    * @description Check for existing deviation for financial template
    * @author Ajitesh | 10-29-2023 
    * @param loanId 
    * @return Id 
    **/
    public static Id checkIfDeviationIsAlreadyCreated(Id loanId){
        try{
            return [SELECT Id FROM Deviation__c WHERE Deviation_Type__c =: FINANCIAL_TEMPLATE_CREDIT_DEVIATION_TYPE AND Loan_Application__c = :loanId AND Archived__c = false AND Active__c = true WITH SECURITY_ENFORCED].Id;
        }
        catch(Exception e){
            return null;
        }
        
    }



}