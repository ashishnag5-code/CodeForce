/*****
 * Class Name: ChargesController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-13-2023          -   Sachin              -   SFAU-5229 Valuation Charges not displayed
 * Sep-25-2023          -   Mohit M             -   SFAU-4471 - validate If LS charges is not taken RBM Approval will be required
 * Oct-26-2023          -   Mohit M             -   SFAU-5392 - LS Charges Deviations and Approval
 * Nov-06-2023          -   Mohit M             -   SFAU-5558 - Charges is not showing only in normal scheme - vintage Logic
 * Nov-06-2023          -   Yash  s             -   SFAU-5778 - ROC-Charges Check Added
 * Nov-18-2023          -   Ajitesh             -   Stamping charge exception in case of tractor
 */
public without sharing class ChargesController {
    
    public static Map<String, Charges_Master__c> scCodeVSChargeMstrMap;
    public static String  loanApplcId;
    public static List<Loan_Application__c>  loanApplcRecList;
    public static String  applcId;
    public static Decimal loanAmount;
    public static String  product;
    public static String  custmerType;
    public static String  custmerCategory;
    public static Decimal burScore;
    public static String  strScreen;
    public static String  collatType;
    public static String  fuelTypeFromColl;
    public static String  vehclUsageFromColl;
    public static Boolean  isVintageChargeApplicable = false; // SFAU-4473
    public static Decimal  idv;
    public static String schemeNameFromLoan;
    public static Map<String, fldsWrapper> scCodeVsfldwrapperMap; 
    public static List<fldsWrapper> sortedChrgeMasterLst;
    public static ChargeWrapper chargeWrapperObj;
    public static Boolean isFromBre = false;    
    public static Decimal processingFee;  
    public static Boolean boolIsChargeChanged = false;  
    public static Boolean boolIsGuarantorAvailable = false;  
    public static Decimal NoofGuarantorAvailable;  
    
    public static String constitutionType; // R2-834 Applicant Constitution types 

    public static String[] APPLICABLE_MI_CHARGE_TYPES = new String[]{ 'Used', 'Cash on Wheels' };

    @AuraEnabled
    public static  List<Stage_Profile_Data_Configuration__mdt> getCustomMetaRecStageProfle() {
        
        List<Stage_Profile_Data_Configuration__mdt> stageprofRecLst = [SELECT id, MasterLabel, Fields__c, Loan_Stage__c, Screen__c
                                                                       FROM Stage_Profile_Data_Configuration__mdt WITH SECURITY_ENFORCED];
        return stageprofRecLst;
    }
    
    
    /**
    * @description Fetching stamping charge to check exception applicablity for tractor
    * @author Ajitesh | 11-18-2023 
    * @param loanAppId 
    * @return Stamping_Charges_Calculation__mdt 
    **/
    @AuraEnabled
    public static Stamping_Charges_Calculation__mdt getStampingChargeApplicableRecord(Id loanAppId){
        try {
            Stamping_Charges_Calculation__mdt stampingCharge = new Stamping_Charges_Calculation__mdt();
            Loan_Application__c loanAppRec = [SELECT Branch_Master__r.State__r.Account_Name__c, Product__c FROM Loan_Application__c WHERE Id =: loanAppId WITH SECURITY_ENFORCED];
            if(loanAppRec != null && loanAppRec.Branch_Master__r != null && loanAppRec.Branch_Master__r.State__r != null &&  loanAppRec.Branch_Master__r.State__r.Account_Name__c != null){
                for(Stamping_Charges_Calculation__mdt tempStampingCharge : [SELECT Applicable_Product__c, IsException__c, Vehicle_Usage__c, Loan_Amount_Not_Applicable_Upto__c, Exception_Stamp_Charge__c FROM Stamping_Charges_Calculation__mdt WHERE State__c = :loanAppRec.Branch_Master__r.State__r.Account_Name__c WITH SECURITY_ENFORCED]){
                    Set<String> applicableProducts = new Set<String>(tempStampingCharge.Applicable_Product__c.split(','));
                    if(applicableProducts.contains(loanAppRec.Product__c)){
                        stampingCharge = tempStampingCharge;
                        break;
                    }
                }
            }
            return stampingCharge;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static  List<Bureau_Results__c> getBurRes(String applcntId, String bureau) {
        
        List<Bureau_Results__c> getBurReslLst = [SELECT id, Bureau_Score__c
                                                 FROM Bureau_Results__c                     
                                                 WHERE (Applicant__c =: applcntId AND Bureau__c =: bureau) WITH SECURITY_ENFORCED                                                    
                                                 ORDER BY createddate DESC LIMIT 1];
        return getBurReslLst;
    }
    
    @AuraEnabled
    public static  List<Collateral__c> getCollateral(String loanApplId) {
        Id existingColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();        
        List<Collateral__c> getCollaterallLst = [SELECT id, toLabel(Collateral_Name__c), Fuel_Type__c, Vehicle_Usage__c, Manufacture_year_month__c, IDV__c
                                                 FROM Collateral__c                     
                                                 WHERE (Loan__c =: loanApplId) AND Is_Deleted__c = false AND recordTypeId!=:existingColRecordTypeId WITH SECURITY_ENFORCED];
        return getCollaterallLst;
    }
    
    static Boolean isValuationCall = false;
    public static List<Charges_Master__c> schemeQuery(String scheme, String chargeName) {
        String strVintageModelFees = 'Vintage Model Fees';
        String condition = '';
        String defaultCategory = 'NA',
            valuationChargeScCode = Label.ValuationChargeScCode,
            valuationChargeMasterName = Label.ValuationChargeMasterName;
        
        if(chargeName != null && String.isNotBlank(chargeName)){
            condition = '(Scheme__r.Scheme_Name__c =: scheme AND Product_Code__c =:product AND '+   
                '((Cibil_MIN__c <:burScore AND Cibil_Max__c >:burScore) OR Cibil_Include__c =: burScore) AND '+
                '(Min_Amount__c <:loanAmount AND Max_Amount__c >:loanAmount) AND '+
                '(Type_of_Loan__c =:strScreen) AND SC_Name__c !=: strVintageModelFees AND SC_Name__c =: chargeName) '+
                ( !isValuationCall ? 'AND SC_Code__c !=: valuationChargeScCode ' : '' ) +
                'WITH SECURITY_ENFORCED LIMIT 1';
            
            /*  condition = '(Scheme__r.Scheme_Name__c =: scheme AND '+
'(Min_Amount__c <:loanAmount AND Max_Amount__c >:loanAmount) AND '+
'(Type_of_Loan__c =:strScreen) AND SC_Name__c !=: strVintageModelFees AND SC_Name__c =: chargeName) '+
'WITH SECURITY_ENFORCED LIMIT 1';
*/
        }
        else{
            condition = '(Scheme__r.Scheme_Name__c =: scheme AND Product_Code__c =:product AND '+   
                '((Cibil_MIN__c <:burScore AND Cibil_Max__c >:burScore) OR Cibil_Include__c =: burScore) AND '+
                '(Min_Amount__c <:loanAmount AND Max_Amount__c >:loanAmount) AND '+
                '(Customer_category__c =:custmerCategory OR Customer_category__c =:defaultCategory) AND '+
                '(Type_of_Loan__c =:strScreen) AND SC_Name__c !=: strVintageModelFees) AND SC_Code__c !=: valuationChargeScCode '+
                'WITH SECURITY_ENFORCED';
        }
        
        String strQuery = 'SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c, '+
            'Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c, '+
            'SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, '+
            'Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, '+ 
            'Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, '+
            'Deviation_Applicable__c, Shown_to_UI__c, Constitution_Type__c FROM Charges_Master__c WHERE' + condition;
        
        system.debug('strQuery'+strQuery);
        
        List<Charges_Master__c> schemeLst = Database.query(strQuery);
        system.debug('schemeLst'+JSON.serialize(schemeLst));

        if( isValuationCall ) return schemeLst;
        // Sachin -- SFAU-4476 - Add Valuation charges only if Valuation is of type Cando
        schemeLst.addAll( addValuationCharges( loanApplcId, valuationChargeMasterName, scheme ) );

        /*
List<Charges_Master__c> schemeLst = [SELECT id, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
Deviation_Applicable__c, Shown_to_UI__c
FROM Charges_Master__c
WHERE (Scheme__r.Scheme_Name__c =: scheme AND 
((Cibil_MIN__c <:burScore AND Cibil_Max__c >:burScore) OR Cibil_Include__c =: burScore) AND 
(Min_Amount__c <:loanAmount AND Max_Amount__c >:loanAmount) AND 
(Type_of_Loan__c =:strScreen) AND SC_Name__c != 'Vintage Fees'
)
WITH SECURITY_ENFORCED];
*/
        
        List<Charges_Master__c> vintageModelRecList = [SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
                                                       Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
                                                       SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                       Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                       Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                       Deviation_Applicable__c, Shown_to_UI__c, Constitution_Type__c
                                                       FROM Charges_Master__c
                                                       WHERE (Scheme__r.Scheme_Name__c =: scheme AND SC_Name__c = 'Vintage Model Fees' AND Product_Code__c=:product)    
                                                       WITH SECURITY_ENFORCED]; 
        
        system.debug('vintageModelRecList--'+vintageModelRecList);
        if(vintageModelRecList.size() > 0) {
            // SFAU-4473 - Vintage charge to be applicable only if age more than 10 years 
            if( isVintageChargeApplicable && idv == 0 ){
                schemeLst.addAll(vintageModelRecList);
            }
        }
        return schemeLst;
    }

    public static Charges_Master__c[] addValuationCharges ( Id loanId, String valuationChargeMasterName, String schemeName ){
        isValuationCall = true;

        Valuation__c[] canDoValuations = [ SELECT Id, Collateral__c FROM Valuation__c WHERE Collateral__r.Loan__c =: loanId AND Valuer_Name_Code__c = 'Cando' ];

        if( !canDoValuations.isEmpty() ){
            Charge__c[] valuationCharges = [ SELECT Id FROM Charge__c WHERE Loan_Application__c =: loanId AND Charges_Name__c =: valuationChargeMasterName ];

            if( !valuationCharges.isEmpty() ) return new Charges_Master__c[0];
    
            Charges_Master__c[] chargeMasters = getApplicableValuationCharges( schemeName, valuationChargeMasterName );

            // Charge__c chargeRecord = createChargeRecord( chargeMasters[0] );
            // chargeRecord.Loan_Application__c = loanId;
            // chargeRecord.Id = !chargeMasters.isEmpty() ? chargeMasters[0].Id : null;
            // chargeRecord.Charges_Name__c = valuationChargeMasterName;
            // return new Charge__c[]{ chargeRecord };
            return chargeMasters;
        }
        isValuationCall = false;
        return new Charges_Master__c[0];
    }

    public static Charges_Master__c[] getApplicableValuationCharges( String schemeName, String valuationChargeMasterName ){
        Charges_Master__c[] chargeMasters = schemeQuery( schemeName, valuationChargeMasterName );
        // if( !chargeMasters.isEmpty() ||  schemeName == Label.BRE_Default_Scheme_for_Master )
        return chargeMasters;

        // Get Charges for Normal scheme if applicable
        // return schemeQuery( Label.BRE_Default_Scheme_for_Master, Label.ValuationChargeMasterName );
    }

    public static Charge__c createChargeRecord(Charges_Master__c chargeMasterRecord){
        Charge__c chargeObj = new Charge__c();
        chargeObj.Master_Name__c               =chargeMasterRecord.SC_Name__c;
        chargeObj.SC_Code__c                   =chargeMasterRecord.SC_Code__c;
        chargeObj.Sequence_NO__c               =chargeMasterRecord.Sequence_NO__c;
        chargeObj.Dedn_Cod__c                  =chargeMasterRecord.Dedn_Cod__c;
        chargeObj.Rate_value_As_per_Policy__c = chargeMasterRecord.Rate_value_As_per_Policy__c;
        chargeObj.Tax_Applicable__c            =chargeMasterRecord.Tax_Applicable__c;
        chargeObj.Tax_Percentage__c            =chargeMasterRecord.Tax_Percentage__c;
        chargeObj.Min_charges__c               =chargeMasterRecord.Min_charges__c;
        chargeObj.Max_Charges_SOC__c           =chargeMasterRecord.Max_Charges_SOC__c;
        chargeObj.Customer_category__c         =chargeMasterRecord.Customer_category__c;
        chargeObj.Model_Age__c                 =chargeMasterRecord.Model_Age__c;
        chargeObj.Deviation_Applicable__c      =chargeMasterRecord.Deviation_Applicable__c;
        chargeObj.Shown_to_UI__c               =chargeMasterRecord.Shown_to_UI__c;
        chargeObj.Value_Type__c                =chargeMasterRecord.Value_Type__c;
        chargeObj.Tax_Amount__c                =chargeObj.Tax_Percentage__c * 100;           
        if(isFromBre){  
            Decimal rateValueAsperPol = (processingFee/loanAmount) * 100;   
            chargeObj.Actual_rate__c   = rateValueAsperPol; 
            chargeObj.Rate_value_As_per_Policy__c = rateValueAsperPol;  
            chargeObj.Charge_Amount__c = processingFee.setscale(0) / ((chargeObj.Tax_Percentage__c/100) + 1); 
            chargeObj.Total_Amount__c = processingFee.setscale(0); 
        }   
        else if(chargeObj.Value_Type__c == 'Fixed') {   
            chargeObj.Actual_rate__c   = chargeObj.Rate_value_As_per_Policy__c; 
            chargeObj.Charge_Amount__c = chargeObj.Rate_value_As_per_Policy__c; 
        }   
        else if(chargeObj.Value_Type__c == 'Percent') { 
            Decimal rateValueAsperPol = chargeObj.Rate_value_As_per_Policy__c * 100;    
            chargeObj.Actual_rate__c   = rateValueAsperPol; 
            chargeObj.Rate_value_As_per_Policy__c = rateValueAsperPol;  
            chargeObj.Charge_Amount__c = loanAmount * (chargeObj.Rate_value_As_per_Policy__c/100);  
        }
        Decimal chargeAmount   = chargeObj.Charge_Amount__c;
        chargeObj.Total_Amount__c   = chargeAmount + (chargeObj.Tax_Percentage__c * chargeAmount);
        chargeObj.Total_Amount__c   = chargeObj.Total_Amount__c.setscale(0);
        return chargeObj;
    } 
    
    /*Collateral Delete Check Added 5457*/ 
    @AuraEnabled
    public static  List<Loan_Application__c> getLoanAppl(String loanApplId) { //SFAU-5147
        
        List<Loan_Application__c> loanApplLst = [SELECT id, Stage__c, Loan_Amount__c, Product__c, Customer_Type__c, Scheme__r.Scheme_Name__c,isLoanAmtChanged__c,
                                                 Branch_Master__c, Branch_Master__r.Account_Code__c, Branch_Master__r.Hub_Code__c,Branch_Master__r.Region_Code__c, 
                                                 Branch_Master__r.State_Code__c, Dealer_Master__c, Dealer_Master__r.Account_Code__c, Dealer_Master__r.Processing_Fees__c, Dealer_Master__r.Document_Charges__c, Branch_Master__r.State__r.Account_Name__c, Total_Loan_Amount__c,
                                                 (SELECT id, Make__c, Model__c, SVSH_SVOH__c, Is_Deleted__c, Vehicle_Usage__c   
                                                  FROM Collaterals__r WHERE Is_Deleted__c = false ORDER BY CreatedDate desc LIMIT 1),   // deleted and Record Type check                                              
                                                 (SELECT id, Existing_Customer__c, Customer_Type__c, Constitution_Type__c
                                                  FROM Applicants__r 
                                                  WHERE RecordType.Name = 'Applicant' LIMIT 1)
                                                 FROM Loan_Application__c
                                                 WHERE id=: loanApplId WITH SECURITY_ENFORCED];
        return loanApplLst;
    }
    
    public static  List<Master_Junction_Mapping__c> getMasterJuncMapping(Set<String> chrmstrIdsSet, String recordTypeName) {
        
        List<Master_Junction_Mapping__c> masterJuncMappingLst = [SELECT id, Charges__r.SC_Code__c, Territory__r.Account_Code__c, Territory__r.RecordType.Name,
                                                                 SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                                 Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                                 Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                                 Deviation_Applicable__c, Shown_to_UI__c, 
                                                                 Make_Model__r.Name, Make_Model__r.RecordType.Name                                                              
                                                                 FROM Master_Junction_Mapping__c                     
                                                                 WHERE (Charges__c in: chrmstrIdsSet AND RecordType.Name =:recordTypeName) WITH SECURITY_ENFORCED];
        return masterJuncMappingLst;
    }
    
    public static String getScreenType(String productValue){
        if(productValue.contains(System.label.AUSFNewScreen) || System.label.AUSFNewScreen.contains(productValue) ){ //R2-2634
            return System.label.AUSFNewScreen;
        }else if(productValue.contains(System.label.AUSFUsedScreen) || System.label.AUSFUsedScreen.contains(productValue)){ //R2-2634
            return System.label.AUSFUsedScreen;
        }else if(productValue!=null && (productValue.contains(System.label.AUSFCowScreen) || System.label.AUSFCowScreen.contains(productValue) || System.label.AUSFCowScreenR2.toUpperCase().contains(productValue.toUpperCase()))){ //R2-2634
            return System.label.COW;
        }
        return null;
    } 
    
    @AuraEnabled
    public static void initialize(String loanId) {
        scCodeVSChargeMstrMap = new Map<String, Charges_Master__c>();
        loanApplcId = loanId;
        List<Loan_Application__c> loanApplLst = getLoanAppl(loanId);
        loanApplcRecList                          = loanApplLst;
        loanAmount                            = loanApplLst[0].Loan_Amount__c;
        product                               = loanApplLst[0].Product__c;
        if(loanApplLst[0].Applicants__r.size() > 0) {
            custmerType = loanApplLst[0].Applicants__r[0].Existing_Customer__c == 'Yes'? 'ETB':'NTB';
            applcId                                = loanApplLst[0].Applicants__r[0].Id;
            custmerCategory = loanApplLst[0].Applicants__r[0].Customer_Type__c;
            constitutionType = loanApplLst[0].Applicants__r[0].Constitution_Type__c; // R2-834 Constitution type filter added
        }
        schemeNameFromLoan                    = loanApplLst[0].Scheme__r.Scheme_Name__c;
        
        List<Bureau_Results__c> burReslLst  = getBurRes(applcId, 'CIBIL');
        if(burReslLst.size() > 0) {
            burScore                        = burReslLst[0].Bureau_Score__c;
        }
        strScreen                           = getScreenType(AUSFVehicleHelper.getPicklistLabel(product));
        
        List<Collateral__c> collaterallLst  = getCollateral(loanId);
        if(collaterallLst.size() > 0) {
            collatType                          = collaterallLst[0].Collateral_Name__c;
            fuelTypeFromColl                    = collaterallLst[0].Fuel_Type__c;
            vehclUsageFromColl                  = collaterallLst[0].Vehicle_Usage__c;
            String yearAndMonth                 = collaterallLst[0].Manufacture_year_month__c;
            idv                                 = String.isNotBlank(collaterallLst[0].IDV__c) ? Decimal.valueOf(collaterallLst[0].IDV__c) : 0; // valid for Used / COW only (Vintage Charges)
            if(!String.isBlank(yearAndMonth)){
                // SFAU-4473 - Vintage charge to be applicable if vehicle age is more than 10 years
                Date TODAY = Date.today();
                Integer manufactureYear                     = Integer.valueOf(yearAndMonth.substring(0, 4));
                Integer manufactureMonth                    = yearAndMonth.length() == 6 ? Integer.valueOf( yearAndMonth.substring( 4, 6 ) ) : TODAY.month();
                isVintageChargeApplicable                   = TODAY.addYears( -10 ) > Date.newInstance( manufactureYear, manufactureMonth, TODAY.day() );
                // manufactureYear                     = String.isNotBlank(manufactureYear) || manufactureYear =='null' ? manufactureYear : '0';
            }
        }  
    }
    
    @AuraEnabled
    public static ChargeWrapper chargesHandler(String loanApplId) {
        List<Charge__c> chrgeList = [SELECT Id, Actual_rate__c, Charge_Amount__c, Tax_Amount__c, Total_Amount__c,
                                     Charges_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                     Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                     Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                     Deviation_Applicable__c, Shown_to_UI__c, Source_Stamping_Charge_Save__c, Agri_and_End_use_of_product_AGRI__c, Is_Stamping_Charge_Not_Applicable__c, Udyam_Certificate_Available__c 
                                     FROM Charge__c where Loan_Application__c =: loanApplId WITH SECURITY_ENFORCED];
        
        ChargeWrapper chargeWrapperObj1 = new ChargeWrapper();
        chargeWrapperObj1.chargesList   = new List<FldsWrapper>();
        chargeWrapperObj1.loanApplList = new List<Loan_Application__c>();
        
        List<Applicant__c> lstApplicant = [Select Id,Name,IsInactive__c,RecordType.Name,Loan__c from Applicant__c 
                                where RecordType.Name = 'Guarantor' and Loan__c=:loanApplId and IsInactive__c = false];
        if(!lstApplicant.isEmpty()){
            boolIsGuarantorAvailable = true;
            NoofGuarantorAvailable = lstApplicant.size();
        }
        else{
            boolIsGuarantorAvailable = false;
        }
        
        // SFAU-5310 - Vintage charges to be applicable only if idv is 0 & vehicle age is > 10 years
        map<String, Charge__c> chargesByCode = Utility.getChargesMappedByScCode( chrgeList );
        if(chrgeList.size() > 0) {
            initialize(loanApplId);

            // SFAU-5310
            if( chargesByCode.containsKey( Label.VintageChargeCode ) && (!isVintageChargeApplicable || idv != 0) ){
                delete chargesByCode.get( Label.VintageChargeCode );
            } else if( !chargesByCode.containsKey( Label.VintageChargeCode ) && isVintageChargeApplicable  && idv == 0){
                /*SFAU-5530 Changes*/
                /* START - SFAU-5558 Change Conditions */
                List<Charges_Master__c> lstNewChargeMaster = new List<Charges_Master__c>();
                lstNewChargeMaster = schemeQuery( schemeNameFromLoan, Label.VintageChargeCodeName);
                if(!lstNewChargeMaster.isEmpty()){// Handling Empty Check for Vintage Models
                    chargeWrapperObj1.chargesList.add(wrapperFldsOfChargeMstr(lstNewChargeMaster[0]));
                }
                /* END - SFAU-5558 */
            }

            for(Charge__c chrge : chrgeList) {
                FldsWrapper chrgeobj = wrapperFldsOfCharge(chrge);
                chargeWrapperObj1.chargesList.add(chrgeobj);   
            }
            // CUG -- 13/09/23 - Valuation charges to be added if Valuatoion was triggered after taking charges - SFAU-5229
            Charges_Master__c[] lstCharges = addValuationCharges( loanApplId, Label.ValuationChargeMasterName, schemeNameFromLoan );
            if(!lstCharges.isEmpty()){
                FldsWrapper chrgeobj1 = wrapperFldsOfChargeMstr(lstCharges[0]);
                chargeWrapperObj1.chargesList.add(chrgeobj1); 
            }
            chargeWrapperObj1.loanApplList = getLoanAppl(loanApplId);
            system.debug('inside chrgeList size-->>');
            return chargeWrapperObj1;
        }
        else {
            initialize(loanApplId);
            makeDefaultValLst();
            overrideDefaultValLst();
            calculateCharges();
            chargeWrapperObj1.loanApplList = loanApplcRecList;
            system.debug('sortedChrgeMasterLst-- '+sortedChrgeMasterLst);
            return chargeWrapperObj;
        }
    }
    
    @AuraEnabled
    public static void makeDefaultValLst() {
        
        List<Charges_Master__c> defaultValLst = schemeQuery('Normal', null);
        system.debug('defaultValLst-- '+JSON.serialize(defaultValLst));

        // Body funding fuel type skip
        Set<String> bodyFundingProductCodes = new Set<String>();
        Boolean isBodyFunding = false;
        String collateralProductCodeApi = '';
        Schema.DescribeFieldResult fieldResult = Collateral__c.Collateral_Name__c.getDescribe(); 
        for( Schema.PicklistEntry v : fieldResult.getPicklistValues()) { 
            if(v.getLabel() == collatType){
                collateralProductCodeApi = v.getValue();
                break;
            }
        }
        for(String tempCode : System.Label.Commercial_Body_Funding_Collateral_Codes.split(',')){
            if(collateralProductCodeApi == tempCode.trim()){
                isBodyFunding = true;
                break;
            }
        }
        // Body funding fuel type skip


        for(Charges_Master__c chrgeMstrRec : defaultValLst) {
            
             // Constituion type filter added R2-834
             boolean isConstitutionTypeValid = true;
             if(chrgeMstrRec.Constitution_Type__c!=null){
                 if(constitutionType == null){
                     isConstitutionTypeValid = false;
                 }
                 else if(!chrgeMstrRec.Constitution_Type__c.containsIgnoreCase(constitutionType)){
                     isConstitutionTypeValid = false;
                 }
             }
             // Constituion type filter added R2-834

            String collateralType = chrgeMstrRec.Collateral_Type__c;
            String customerType   = chrgeMstrRec.Customer_Type__c;
            String fuelType       = chrgeMstrRec.Fuel_Type__c;
            String vehicleUsage   = chrgeMstrRec.Vehicle_Usages__c;
            
            if(collateralType.containsIgnoreCase(collatType) && customerType.containsIgnoreCase(custmerType) && (isBodyFunding || fuelType.containsIgnoreCase(fuelTypeFromColl)) && vehicleUsage.containsIgnoreCase(vehclUsageFromColl) && isConstitutionTypeValid) {
                scCodeVSChargeMstrMap.put(chrgeMstrRec.SC_Code__c, chrgeMstrRec);
            }
        }
        system.debug('Map sc Code '+scCodeVSChargeMstrMap);
        system.debug('scCodeVSChargeMs-->> '+JSON.serialize(scCodeVSChargeMstrMap));
    }
    
    @AuraEnabled
    public static void overrideDefaultValLst() {
        Map<String,Charges_Master__c> mapOfLocationSepcificVsRecord = new Map<String,Charges_Master__c >();
        Map<String,Charges_Master__c> mapOfDealerSepcificVsRecord = new Map<String,Charges_Master__c >();
        Map<String,Charges_Master__c> mapOfMakeModelSepcificVsRecord = new Map<String,Charges_Master__c >();
        Map<String,Charges_Master__c> mapOfChargeMstrIdVsChargeMaster = new Map<String,Charges_Master__c >();
        scCodeVsfldwrapperMap = new Map<String, fldsWrapper>();
        
        List<Charges_Master__c> supremeValLst = schemeQuery(schemeNameFromLoan, null);
        system.debug('supremeValLst-- '+JSON.serialize(supremeValLst));
        for(Charges_Master__c chrgeMstrRec : supremeValLst) {
            
            String collateralType = chrgeMstrRec.Collateral_Type__c;
            String customerType   = chrgeMstrRec.Customer_Type__c;
            String fuelType       = chrgeMstrRec.Fuel_Type__c;
            String vehicleUsage   = chrgeMstrRec.Vehicle_Usages__c;
            
            if(collateralType.containsIgnoreCase(collatType) && customerType.containsIgnoreCase(custmerType) && fuelType.containsIgnoreCase(fuelTypeFromColl) && vehicleUsage.containsIgnoreCase(vehclUsageFromColl)) {
                scCodeVSChargeMstrMap.put(chrgeMstrRec.SC_Code__c, chrgeMstrRec);
            }
        }
        system.debug('scCodeVSChargeMstrMap--'+JSON.serialize(scCodeVSChargeMstrMap));
        for(Charges_Master__c chrgeMstr : scCodeVSChargeMstrMap.values()) {
            if(chrgeMstr.Is_territory_General__c == 'FALSE' && chrgeMstr.Is_Make_model_General__c == 'FALSE' && chrgeMstr.Is_Dealer_General__c == 'FALSE') {
                FldsWrapper chrgeMstrobj              = new FldsWrapper();
                chrgeMstrobj.scName                   = chrgeMstr.SC_Name__c;
                chrgeMstrobj.scCode                   = chrgeMstr.SC_Code__c;
                chrgeMstrobj.valueType                = chrgeMstr.Value_Type__c;
                chrgeMstrobj.sequenceNO               = chrgeMstr.Sequence_NO__c;
                chrgeMstrobj.dednCod                  = chrgeMstr.Dedn_Cod__c;
                chrgeMstrobj.rateValueAsPerPolicy     = chrgeMstr.Rate_value_As_per_Policy__c;
                chrgeMstrobj.taxApplicable            = chrgeMstr.Tax_Applicable__c;
                chrgeMstrobj.taxPercentage            = chrgeMstr.Tax_Percentage__c;
                chrgeMstrobj.minCharges               = chrgeMstr.Min_charges__c;
                chrgeMstrobj.maxChargesSOC            = chrgeMstr.Max_Charges_SOC__c;
                chrgeMstrobj.customerCategory         = chrgeMstr.Customer_category__c;
                chrgeMstrobj.modelAge                 = chrgeMstr.Model_Age__c;
                chrgeMstrobj.deviationApplicable      = chrgeMstr.Deviation_Applicable__c;
                chrgeMstrobj.shownToUI                = chrgeMstr.Shown_to_UI__c;
                chrgeMstrobj.isShownAtUI              = (String.isBlank(chrgeMstr.Shown_to_UI__c))?true:(chrgeMstr.Shown_to_UI__c=='Yes');
                if(chrgeMstr.Deviation_Applicable__c == 'Yes') {
                    chrgeMstrobj.isRaiseDeviation = true;
                }
                else if(chrgeMstr.Deviation_Applicable__c == 'No'){
                    chrgeMstrobj.isRaiseDeviation = false; 
                }
                else if(chrgeMstr.Deviation_Applicable__c == '' || chrgeMstr.Deviation_Applicable__c == null){
                    chrgeMstrobj.allowMinValue = true;
                }
                scCodeVsfldwrapperMap.put(chrgeMstr.SC_Code__c, chrgeMstrobj);
            }
            else {
                if(chrgeMstr.Is_territory_General__c == 'TRUE') {
                    mapOfLocationSepcificVsRecord.put(chrgeMstr.SC_Code__c, chrgeMstr);
                    mapOfChargeMstrIdVsChargeMaster.put(chrgeMstr.Id, chrgeMstr);
                }
                if(chrgeMstr.Is_Dealer_General__c == 'TRUE') {
                    mapOfDealerSepcificVsRecord.put(chrgeMstr.SC_Code__c, chrgeMstr);
                    mapOfChargeMstrIdVsChargeMaster.put(chrgeMstr.Id, chrgeMstr);
                }                
                if(chrgeMstr.Is_Make_model_General__c == 'TRUE') {
                    mapOfMakeModelSepcificVsRecord.put(chrgeMstr.SC_Code__c, chrgeMstr);
                    mapOfChargeMstrIdVsChargeMaster.put(chrgeMstr.Id, chrgeMstr);
                }                                           
            }           
        }
        system.debug('scCodeVsfldwrapperMap--> '+scCodeVsfldwrapperMap);
        
        List<Master_Junction_Mapping__c> masterJuncMappingLst = getMasterJuncMapping(mapOfChargeMstrIdVsChargeMaster.keyset(), 'Charge');
        if(mapOfLocationSepcificVsRecord.keyset().size() > 0) {
            checkLocationWithLoanAppl(masterJuncMappingLst, mapOfLocationSepcificVsRecord);
        }
        if(mapOfDealerSepcificVsRecord.keyset().size() > 0) {
            checkDealerWithLoanAppl(masterJuncMappingLst, mapOfDealerSepcificVsRecord);
        }
        if(mapOfMakeModelSepcificVsRecord.keyset().size() > 0) {
            checkMakeModelWithLoanAppl(masterJuncMappingLst, mapOfMakeModelSepcificVsRecord);
        }
        system.debug('mapOfLocationSepcificVsRecord-- '+mapOfLocationSepcificVsRecord + '  '+ mapOfLocationSepcificVsRecord.keyset().size());
        system.debug('mapOfDealerSepcificVsRecord-- '+mapOfDealerSepcificVsRecord + '  '+ mapOfLocationSepcificVsRecord.keyset().size());
        system.debug('mapOfMakeModelSepcificVsRecord-- '+mapOfMakeModelSepcificVsRecord + '  '+ mapOfLocationSepcificVsRecord.keyset().size());
    }
    
    public static void checkLocationWithLoanAppl(List<Master_Junction_Mapping__c> masterJuncMappingLst, Map<String,Charges_Master__c> mapOfLocationSepcificVsRecord) {
        
        Loan_Application__c loanApplctionRec = loanApplcRecList.size() > 0 ? loanApplcRecList[0] : new Loan_Application__c();
        for(Master_Junction_Mapping__c mstrJuncMappRec : masterJuncMappingLst) {
            String scCodeFromMstrJuncMappRec = mstrJuncMappRec.Charges__r.SC_Code__c;
            FldsWrapper obj = new FldsWrapper();
            if(mstrJuncMappRec.Territory__r.RecordType.Name == 'Branch') {             
                if(mstrJuncMappRec.Territory__r.Account_Code__c == loanApplctionRec.Branch_Master__r.Account_Code__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfLocationSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
            else if (mstrJuncMappRec.Territory__r.RecordType.Name == 'Hub') {
                if(mstrJuncMappRec.Territory__r.Account_Code__c == loanApplctionRec.Branch_Master__r.Hub_Code__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfLocationSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
            else if (mstrJuncMappRec.Territory__r.RecordType.Name == 'State') {
                if(mstrJuncMappRec.Territory__r.Account_Code__c == loanApplctionRec.Branch_Master__r.State_Code__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfLocationSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
            else if (mstrJuncMappRec.Territory__r.RecordType.Name == 'Region') {
                if(mstrJuncMappRec.Territory__r.Account_Code__c == loanApplctionRec.Branch_Master__r.Region_Code__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfLocationSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
        }
        system.debug('inside checkLocationWithLoanAppl  '+scCodeVsfldwrapperMap);
    }
    
    public static void checkDealerWithLoanAppl(List<Master_Junction_Mapping__c> masterJuncMappingLst, Map<String,Charges_Master__c> mapOfDealerSepcificVsRecord) {
        
        Loan_Application__c loanApplctionRec = loanApplcRecList.size() > 0 ? loanApplcRecList[0] : new Loan_Application__c();
        for(Master_Junction_Mapping__c mstrJuncMappRec : masterJuncMappingLst) {
            String scCodeFromMstrJuncMappRec = mstrJuncMappRec.Charges__r.SC_Code__c;
            FldsWrapper obj = new FldsWrapper();           
            if(mstrJuncMappRec.Territory__r.Account_Code__c == loanApplctionRec.Dealer_Master__r.Account_Code__c) {
                obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
            }
            else {                   
                obj = wrapperFldsOfChargeMstr(mapOfDealerSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
            }
            scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
        }
        system.debug('inside checkDealerWithLoanAppl  '+scCodeVsfldwrapperMap);
    }
    
    public static void checkMakeModelWithLoanAppl(List<Master_Junction_Mapping__c> masterJuncMappingLst, Map<String,Charges_Master__c> mapOfMakeModelSepcificVsRecord) {
        Loan_Application__c loanApplctionRec = loanApplcRecList.size() > 0 ? loanApplcRecList[0] : new Loan_Application__c();
        for(Master_Junction_Mapping__c mstrJuncMappRec : masterJuncMappingLst) {
            String scCodeFromMstrJuncMappRec = mstrJuncMappRec.Charges__r.SC_Code__c;
            FldsWrapper obj = new FldsWrapper();           
            if(mstrJuncMappRec.Make_Model__r.RecordType.Name == 'Make') {
                if(mstrJuncMappRec.Make_Model__r.Name == loanApplctionRec.Collaterals__r[0].Make__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfMakeModelSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
            else if(mstrJuncMappRec.Make_Model__r.RecordType.Name == 'Model') {
                if(mstrJuncMappRec.Make_Model__r.Name == loanApplctionRec.Collaterals__r[0].Model__c) {
                    obj = wrapperFldsOfMasterJuncMapp(mstrJuncMappRec);
                }
                else {                   
                    obj = wrapperFldsOfChargeMstr(mapOfMakeModelSepcificVsRecord.get(scCodeFromMstrJuncMappRec));
                }
                scCodeVsfldwrapperMap.put(mstrJuncMappRec.SC_Code__c,obj);
            }
        }
        system.debug('inside checkMakeModelWithLoanAppl  '+scCodeVsfldwrapperMap);
    }
    
    public static  void calculateCharges() {
        
        String state = loanApplcRecList[0].Branch_Master__r.State__r.Account_Name__c;
        String productCode = loanApplcRecList[0].Product__c;
        // Getting the Collateral Record
        List<Collateral__c> collateralRecord = loanApplcRecList[0].Collaterals__r;
        Boolean isSVOH = false;
        if(!collateralRecord.isEmpty()){
            isSVOH = (collateralRecord[0].SVSH_SVOH__c == 'SVOH');
        }
        /*5457 charges changes
        */
        
        /*ROC Charges Test SFAU-5778*/
         Boolean isROCChargeEnabled = false;
         List<Applicant__c> applicantDetail = [SELECT Id, Customer_Type__c, Constitution_Type__c , Loan__c FROM Applicant__c WHERE Loan__c = :loanApplcRecList[0].Id AND RecordType.Name = 'Applicant' AND IsInactive__c = FALSE];
         if(!applicantDetail.isEmpty()){
             if(applicantDetail[0].Customer_Type__c == 'Non Individual' && (applicantDetail[0].Constitution_Type__c == 'Private Limited' || applicantDetail[0].Constitution_Type__c == 'Public Limited')){
                 isROCChargeEnabled = true;
             }
         }
        
        List<Charge_Data__mdt> chrgeMstrDataLst = [SELECT id, Id__c, Name__c, UI_Sequence_No__c
                                                   FROM Charge_Data__mdt WITH SECURITY_ENFORCED];
        
                                                   

        // Product applicable for R1 and R2 products
        //String productCode = loanApplcRecList[0].Product__c;
        List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = new List<Stamping_Charges_Calculation__mdt>();
        
        for(Stamping_Charges_Calculation__mdt stampCharge : [SELECT id, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
                                                                             As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
                                                                             Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
                                                                             Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
                                                            Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c, Applicable_Product__c, IsException__c, Loan_Amount_Not_Applicable_Upto__c, Vehicle_Usage__c
                                                                             FROM Stamping_Charges_Calculation__mdt
                                                            WHERE State__c =: state WITH SECURITY_ENFORCED]){

            Set<String> applicableProductCodeSet = new Set<String>(stampCharge.Applicable_Product__c.split(',')); // Applicable product sets
            if(applicableProductCodeSet.contains(productCode)){
                stampChrgesCalculationLst.add(stampCharge);
            }
            
        }
        // Product applicable for R1 and R2 products

        // R1 Code 
        // List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = [SELECT id, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
        //                                                                      As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
        //                                                                      Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
        //                                                                      Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
        //                                                                      Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c
        //                                                                      FROM Stamping_Charges_Calculation__mdt
        //      
        // R1 Code                                                                 WHERE State__c =: state WITH SECURITY_ENFORCED];
        
        sortedChrgeMasterLst  = new List<fldsWrapper>(chrgeMstrDataLst.size());
        Map<String,Charge_Data__mdt> mapOfLocationSepcificVsRecord = new Map<String,Charge_Data__mdt >();
        
        for(Charge_Data__mdt chrgeMstrDataRec : chrgeMstrDataLst) {
            if(chrgeMstrDataRec.Name__c.contains('Processing Fees')) {
                List<String> ids = (chrgeMstrDataRec.Id__c).split(',');
                for(String id : ids) {
                    mapOfLocationSepcificVsRecord.put(id, chrgeMstrDataRec);
                }
            }
            mapOfLocationSepcificVsRecord.put(chrgeMstrDataRec.Id__c, chrgeMstrDataRec);
        }
        system.debug('scCodeVsfldwrapperMap-- '+scCodeVsfldwrapperMap);
        for(FldsWrapper fldWrapp: scCodeVsfldwrapperMap.values()) {
            
            if(fldWrapp.valueType == 'Fixed') {
                fldWrapp.actualRate   = fldWrapp.rateValueAsPerPolicy;
                fldWrapp.chargeAmount = fldWrapp.rateValueAsPerPolicy;
            }
            else if(fldWrapp.valueType == 'Percent') {
                Decimal rateValueAsperPol = fldWrapp.rateValueAsPerPolicy;
                fldWrapp.actualRate   = rateValueAsperPol;
                fldWrapp.rateValueAsPerPolicy = rateValueAsperPol;
                fldWrapp.chargeAmount = loanAmount * (fldWrapp.rateValueAsPerPolicy/100);
                // if(fldWrapp.maxChargesSOC != null){
                //     fldWrapp.maxChargesSOC = loanAmount * (fldWrapp.maxChargesSOC/100);
                // }
            }
            
            Decimal chargeAmount   = fldWrapp.chargeAmount;
            fldWrapp.totalAmount   = chargeAmount + (fldWrapp.taxPercentage * chargeAmount);

            /*SFAU-5778 Changes*/
            
            if(fldWrapp.scName == 'Roc Charge Creation Expenses'){
                fldWrapp.isShownAtUI = isROCChargeEnabled;
            }
            if(productCode == '10203' && isSVOH && fldWrapp.scName == 'RC Charges'){
                fldWrapp.isRaiseDeviation = false;
                fldWrapp.allowMinValue = false;
            }

            if(fldWrapp.scName == 'Stamp duty') {
                Decimal finalStampingCharge = calculateStampDutyCharge(fldWrapp, stampChrgesCalculationLst);
                fldWrapp.totalAmount = (finalStampingCharge == null ? 0 : finalStampingCharge) + ((fldWrapp.taxPercentage == null ? 0 : fldWrapp.taxPercentage) * (finalStampingCharge == null ? 0 : finalStampingCharge));
            }
           // if(fldWrapp.scName == 'Stamp duty')
            fldWrapp.taxAmount = fldWrapp.chargeAmount * fldWrapp.taxPercentage;
            
            if(fldWrapp.scName.containsIgnoreCase('Documentation Charges') || fldWrapp.scName.containsIgnoreCase('Processing Fees')) {
                overrideChargeAmount(fldWrapp);
            }
            fldWrapp.totalAmount   = (fldWrapp.totalAmount).setScale(2);
            fldWrapp.chargeAmount  = (fldWrapp.chargeAmount).setScale(2);
            fldWrapp.taxAmount     = (fldWrapp.taxAmount!=null)?(fldWrapp.taxAmount).setScale(2):0.00;

            system.debug('after overrideChargeAmount '+sortedChrgeMasterLst);
            if(mapOfLocationSepcificVsRecord.containsKey(fldWrapp.scCode)) {
                Integer pos = Integer.valueOf((mapOfLocationSepcificVsRecord.get(fldWrapp.scCode).UI_Sequence_No__c));
                sortedChrgeMasterLst.add(pos,fldWrapp);
            }
            else{
                Integer pos = chrgeMstrDataLst.size()-1;
                sortedChrgeMasterLst.add(pos,fldWrapp);
            }
            chargeWrapperObj = new ChargeWrapper();
            chargeWrapperObj.loanApplList  = new List<Loan_Application__c>();
            chargeWrapperObj.loanApplList  = loanApplcRecList;
            chargeWrapperObj.chargesList   = new List<FldsWrapper>();
            chargeWrapperObj.chargesList   = sortedChrgeMasterLst;
        }
        system.debug('sortedChrgeMasterLst in sortListBySeqNo--- '+sortedChrgeMasterLst);
    }

    public static Decimal calculateStampDutyCharge(FldsWrapper fldWrapp, List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst) {
        
        Decimal surcharge;
        Decimal stampingCharge;
        Decimal roundOffUpperLimit;
        Decimal poa;
        Decimal guaranteeDeed;
        
        system.debug('stampChrgesCalculationLst--'+JSON.serialize(stampChrgesCalculationLst));
        
        if (stampChrgesCalculationLst != null && !stampChrgesCalculationLst.isEmpty()) {
            for(Stamping_Charges_Calculation__mdt stampChrgesCalculationMetaDt : stampChrgesCalculationLst) {
                system.debug('MasterLabel-- '+stampChrgesCalculationMetaDt.MasterLabel);
                Decimal asPerStampingAct;
                Decimal guaranteeDeedEachGaurantor;
                String asPerStampingActValueType;
                String guaranteeDeedValueType;
                Decimal asPerStampingActLoanCap        = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Loan_Cap__c;
                Boolean isStampingActLoanCapLessThan   = stampChrgesCalculationMetaDt.Is_Stamping_Act_Loan_Cap_Less_than__c;
                Decimal guaranteeDeedLoanCap           = stampChrgesCalculationMetaDt.Guarantee_Deed_Loan_Cap__c;
                Boolean isGuaranteeDeedLoanCapLessThan = stampChrgesCalculationMetaDt.Is_Guarantee_Deed_Loan_Cap_Less_than__c;
                
                if(asPerStampingActLoanCap != null) {
                    if(isStampingActLoanCapLessThan && loanAmount < asPerStampingActLoanCap) {
                        asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                        
                        system.debug('stampingCharge inside if-- '+stampingCharge);
                        asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
                    }
                    else if(isStampingActLoanCapLessThan == false && loanAmount >= asPerStampingActLoanCap){
                        asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                        
                        system.debug('stampingCharge inside else-- '+stampingCharge);
                        asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
                    }
                }
                else {
                    asPerStampingAct = stampChrgesCalculationMetaDt.As_per_Stamping_Act__c;
                    asPerStampingActValueType = stampChrgesCalculationMetaDt.As_per_Stamping_Act_Value_Type__c;
                }
                
                if(guaranteeDeedLoanCap != null) {
                    if(isGuaranteeDeedLoanCapLessThan && loanAmount < guaranteeDeedLoanCap) {
                        guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                        guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
                    }
                    else if(isGuaranteeDeedLoanCapLessThan == false && loanAmount >= guaranteeDeedLoanCap){
                        guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                        guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
                    }
                }
                else {
                    guaranteeDeedEachGaurantor = stampChrgesCalculationMetaDt.Guarantee_Deed_Each_Gaurantor__c;
                    guaranteeDeedValueType     = stampChrgesCalculationMetaDt.Guarantee_Deed_Value_Type__c;
                }
                
                if(asPerStampingActValueType == 'Percent') {
                    stampingCharge = (asPerStampingAct / 100) * loanAmount;
                    system.debug('stampingCharge inside percent-- '+stampingCharge);
                    surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                    roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                    poa = stampChrgesCalculationMetaDt.POA__c;
                }
                else if(asPerStampingActValueType == 'Fixed') {
                    stampingCharge = asPerStampingAct;
                    system.debug('stampingCharge inside fixed-- '+stampingCharge);
                    surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                    roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                    poa = stampChrgesCalculationMetaDt.POA__c;
                }
                if(guaranteeDeedValueType == 'Percent') {
                    guaranteeDeed = (guaranteeDeedEachGaurantor/100) * loanAmount;
                    surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                    roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                    poa = stampChrgesCalculationMetaDt.POA__c;
                }
                else if(guaranteeDeedValueType == 'Fixed'){
                    guaranteeDeed = guaranteeDeedEachGaurantor;
                    surcharge = stampChrgesCalculationMetaDt.Surcharge__c;
                    roundOffUpperLimit = stampChrgesCalculationMetaDt.Round_off_Upper_side_on_A_By_Rs__c;
                    poa = stampChrgesCalculationMetaDt.POA__c;
                }        
            }
        }
        system.debug('stampingCharge-- '+stampingCharge);
        Decimal roundOffStampingCharge;
        Decimal finalStampingCharge;
        
        if(stampingCharge != null) {
            roundOffStampingCharge = (stampingCharge/roundOffUpperLimit).round(System.RoundingMode.CEILING)*roundOffUpperLimit;
            if(boolIsGuarantorAvailable){
                stampingCharge     = roundOffStampingCharge + poa + (guaranteeDeed * NoofGuarantorAvailable);
            }
            else{
                stampingCharge     = roundOffStampingCharge + poa;
            }
            finalStampingCharge = stampingCharge + (surcharge/100) * stampingCharge;
            fldWrapp.chargeAmount = finalStampingCharge;
            system.debug('roundOffStampingCharge--' + roundOffStampingCharge);
            system.debug('stampingCharge--' + stampingCharge);
            system.debug('finalStampingCharge--' + finalStampingCharge);
        }
        return finalStampingCharge;
    }
    
    public static void overrideChargeAmount(FldsWrapper fldWrapp) {
        Loan_Application__c loanapp = new Loan_Application__c();
        loanapp = loanApplcRecList[0];
        String prodct = String.isNotBlank(loanapp.Product__c) ? loanapp.Product__c : '';
        //String dealerMstr = loanapp != null && loanapp.Dealer_Master__c != null && loanapp.Dealer_Master__c != '' ? String.valueOf(loanapp.Dealer_Master__c) : '';
        String productName = AUSFVehicleHelper.getPicklistLabel(prodct);
        system.debug('%%% '+loanapp.Dealer_Master__c);
        if(productName.containsIgnoreCase('Two Wheeler')/* && loanapp != null && loanapp.Dealer_Master__c != null && loanapp.Dealer_Master__c != ''*/ ) {
            if(fldWrapp.scName.contains('Processing Fees') && String.isNotBlank(String.valueOf(loanapp.Dealer_Master__c))) {
                fldWrapp.chargeAmount = loanapp.Dealer_Master__r.Processing_Fees__c != null ? loanapp.Dealer_Master__r.Processing_Fees__c : fldWrapp.chargeAmount;
                Decimal chargeAmount   = fldWrapp.chargeAmount;
                fldWrapp.taxAmount = fldWrapp.chargeAmount * fldWrapp.taxPercentage;
                fldWrapp.totalAmount   = chargeAmount + (fldWrapp.taxPercentage * chargeAmount);
            }
            else if(fldWrapp.scName == 'Documentation Charges'){
                fldWrapp.chargeAmount = loanapp.Dealer_Master__r.Document_Charges__c != null ? loanapp.Dealer_Master__r.Document_Charges__c : fldWrapp.chargeAmount;
                Decimal chargeAmount   = fldWrapp.chargeAmount;
                fldWrapp.taxAmount = fldWrapp.chargeAmount * fldWrapp.taxPercentage;
                fldWrapp.totalAmount   = chargeAmount + (fldWrapp.taxPercentage * chargeAmount);
            } 
        }
    }
    
    @AuraEnabled
    public static SaveChargeWrapper saveCharges(List<Charge__c> chargeList) {
        if(chargeList.size() > 0) {
            SaveChargeWrapper obj = new SaveChargeWrapper();
            obj.chargeList = new List<Charge__c>();
            if (Schema.sObjectType.Charge__c.isCreateable()) {
                Id loanId = chargeList[0].Loan_Application__c;
                // SFAU-4471 - validate If LS charges is not taken RBM Approval will be required
                validateAndRaiseRBMApprovalIfRequired( chargeList, loanId );
                // START - SFAU-5217
                Map<String,Charge__c> mapChargeRecord = new Map<String,Charge__c>();
                Boolean blnIsChargeChanged = false;
                for (Charge__c objCharge : chargeList) {
                    mapChargeRecord.put(objCharge.External_Id_For_Upsert__c,objCharge);
                }
                for (Charge__c objCharge : [Select Id, External_Id_For_Upsert__c, Charge_Amount__c, Rate_value_As_per_Policy__c, Actual_rate__c, Value_Type__c from Charge__c where External_Id_For_Upsert__c in: mapChargeRecord.keySet()]) {
                    if (!mapChargeRecord.containsKey(objCharge.External_Id_For_Upsert__c)) {
                        blnIsChargeChanged = true;
                        break;
                    }
                    else if(mapChargeRecord.containsKey(objCharge.External_Id_For_Upsert__c) && objCharge.Value_Type__c == 'Fixed' && mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Charge_Amount__c != objCharge.Charge_Amount__c && mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Charge_Amount__c < mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Rate_value_As_per_Policy__c){
                        blnIsChargeChanged = true;
                        break;
                    }
                    else if(mapChargeRecord.containsKey(objCharge.External_Id_For_Upsert__c) && objCharge.Value_Type__c == 'Percent' && mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Charge_Amount__c != objCharge.Charge_Amount__c && mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Actual_rate__c < mapChargeRecord.get(objCharge.External_Id_For_Upsert__c).Rate_value_As_per_Policy__c){
                        blnIsChargeChanged = true;
                        break;
                    }
                }

                
                upsert chargeList External_Id_For_Upsert__c;

                ChargesController.boolIsChargeChanged = blnIsChargeChanged ? blnIsChargeChanged : (ChargesController.boolIsChargeChanged==true ? true:false);
                // END - SFAU-5217
                obj = new SaveChargeWrapper();
                obj.chargeList = chargeList;
                obj.message    = 'success';
                updateLoanApplication(loanId);
            }
            else {
                obj.message = 'You Do not have permission to create records of Charge object';
            }
            return obj;         
        }
        return null;
    }

    /**
     * SFAU-4471 - RBM Approval needed is LS is not taken
     * :TODO - validate only if the fields were dirty
    */
    public static void validateAndRaiseRBMApprovalIfRequired( Charge__c[] charges, Id loanId ){
        System.debug(' == All Charges ==> \n' + JSON.serializePretty(charges));
        if( charges.isEmpty() ) return ;

        String[] applicableChargeCodes = Label.LoanSurakshaChargeCode.split(';\\s*'),
            miChargeCodes = Label.MotorInsuranceChargeCode.split(';\\s*');
        // charges are not configured >>> Skip RBM approval
        if( applicableChargeCodes.isEmpty() && miChargeCodes.isEmpty() )
            return;

        map<String, Charge__c> oldChargeCodeMap = Utility.getChargesMappedByScCode( [ SELECT SC_Code__c, Charge_Amount__c FROM Charge__c WHERE Loan_Application__c =: loanId ] );
        Boolean isDirty = false;

        if(!oldChargeCodeMap.isEmpty()){
            String[] fields = new String[]{ 'Charge_Amount__c' };
            for( Charge__c charge: charges ){
                if( !Utility.getSObjectDirtyFields( oldChargeCodeMap.get(charge.SC_Code__c), charge, fields ).isEmpty() ){
                    isDirty = true;
                    break;
                }
            }

            // no need to validate if charges were not changed
            if( !isDirty ) return;
        }

        map<String, Charge__c> chargesByCode = Utility.getChargesMappedByScCode( charges );

        Set<String> lsChargeCodes = new Set<String>( applicableChargeCodes );
        System.debug(' Charge by SC Code ==>' + JSON.serializePretty(chargesByCode ));
        // :TODO confirm if this will be all or just one charge is mandatory
        Decimal totalCharges = 0, miChargeTotal = 0;
        for( String charge: chargesByCode.keySet() ){
            // Atleast one LS charge is taken
            if( chargesByCode.containsKey( charge ) && lsChargeCodes.contains( charge ) && chargesByCode.get( charge ).Charge_Amount__c > 0 ){
                totalCharges += chargesByCode.get( charge ).Charge_Amount__c;
            } else if( chargesByCode.containsKey( charge ) && miChargeCodes.contains( charge ) && chargesByCode.get( charge ).Charge_Amount__c > 0 ){// Applicable for Used / Cow only
                miChargeTotal += chargesByCode.get( charge ).Charge_Amount__c;
            }
        }
        // if( totalCharges == 0 ) return;
        // if( chargesByCode.containsKey( lsChargeCode ) && chargesByCode.get( lsChargeCode ).Total_Amount__c > 0 ) return;

        Collateral__c collateral = [ SELECT Id, LS__c, LS_Value__c, Product__c, Insurance_Value__c  FROM Collateral__c WHERE Loan__c =: loanId AND RecordTypeId IN: GlobalConstants.colRecordTypeIds ORDER BY CreatedDate DESC LIMIT 1];
        System.debug(' == Collateral ==> ' + JSON.serializePretty(collateral));

        String subProductType = Utility.getSubProductName( collateral.Product__c );
        if( collateral.LS_Value__c != null && Decimal.valueOf(collateral.LS_Value__c) > totalCharges ){
            throw new ChargesException( Label.LSChargeAmountExceededMessage );
        } else if( (APPLICABLE_MI_CHARGE_TYPES.contains(subProductType) || System.Label.COW_Product_Names.toUpperCase().contains(subProductType.toUpperCase())) && ( collateral.Insurance_Value__c != null && Decimal.valueOf(collateral.Insurance_Value__c) > miChargeTotal )){ //R2-2634
            throw new ChargesController.ChargesException( String.format( Label.ChargeAmountExceededMessage, new String[]{ 'Motor Insurance' } ) );
        }

        // RO has not taken any LS charge -- RBM approval required for this case
        if( totalCharges == 0 ){
            // Archive existing LS Charge Approvals
            /*Loan_Application_Approval__c[] approvalsToArchive = Utility.archiveRBMApprovals( new Set<Id>{ loanId } );
            AUSFLoanApplication_WithoutSharing.unlockApprovals( approvalsToArchive );
            update approvalsToArchive;

            AUSFRBMApprovalAssignment.requiredApprovalType = Label.LSChargeRequiredApprovalLevel;
            AUSFRBMApprovalAssignment.getListOfRBMApprovals(
                new String[]{ loanId },
                new map<String, String>(),
                null,
                true
            );*/
            Deviation__c[] lsDeviations = [ SELECT Id FROM Deviation__c WHERE Loan_Application__c =: loanId AND Deviation_Type__c = 'LS Charges' AND Archived__c = false ];
            Deviation__c lsDeviation = Utility.getDeviation( !lsDeviations.isEmpty() ? lsDeviations[0].Id : null, 'LS Charges', 'Charges not taken', Label.LSChargeRequiredApprovalLevel, loanId, '', true);
            lsDeviation.Department__c = 'Pricing';
            lsDeviation.Source__c = 'SF';
            
            upsert lsDeviation;
        }
        /* START - SFAU-5392 - LS Charges Deviations and Approval */
        else if (totalCharges > 0) {
            List<Deviation__c> lstArchivedLSDeviations = new List<Deviation__c>();
            for (Deviation__c objDev : [ SELECT Id, Archived__c FROM Deviation__c WHERE Loan_Application__c =: loanId AND Deviation_Type__c = 'LS Charges' AND Archived__c = false ]) {
                objDev.Archived__c = true;
                lstArchivedLSDeviations.add(objDev);
            }
            update lstArchivedLSDeviations;
        }
        /* END - SFAU-5392 - LS Charges Deviations and Approval */

    }

    public static void updateLoanApplication(String strLoanId){
        List<Loan_Application__c> lstLoanApptoUpdate = new List<Loan_Application__c>();
        Loan_Application__c loan = [SELECT Id, BRE_ReRun_Required__c, is_Pricing_Required__c FROM Loan_Application__c WHERE Id=:strLoanId];
        AggregateResult[] groupedResults = [SELECT Loan_Application__c, SUM(Total_Amount__c) FROM Charge__c where Loan_Application__c = :strLoanId WITH SECURITY_ENFORCED GROUP BY Loan_Application__c];
        for (AggregateResult ar : groupedResults)  {
            Loan_Application__c objLoanApptoUpdate = new Loan_Application__c();
            objLoanApptoUpdate.Id = String.valueOf(ar.get('Loan_Application__c'));
            if(!loan.is_Pricing_Required__c){
                objLoanApptoUpdate.Is_Charge_Changed__c = boolIsChargeChanged==null?false:boolIsChargeChanged;
            }
            /*SFAU-4473
                if(loan.BRE_ReRun_Required__c==false){
                objLoanApptoUpdate.BRE_ReRun_Required__c = boolIsChargeChanged==null?false:boolIsChargeChanged;
            }*/

            objLoanApptoUpdate.No_Pricing_Deviation__c = false;
            objLoanApptoUpdate.Total_Charges__c = Decimal.valueOf(String.valueOf(ar.get('expr0')));
            objLoanApptoUpdate.Total_Charges__c = objLoanApptoUpdate.Total_Charges__c.setscale(0);
            lstLoanApptoUpdate.add(objLoanApptoUpdate);
        }
        DatabaseUtility.updateRecords(lstLoanApptoUpdate,'');
    }
    
    public static  FldsWrapper wrapperFldsOfMasterJuncMapp(Master_Junction_Mapping__c mstrJuncMappRecord) {
        FldsWrapper mstrJuncMappobj              = new FldsWrapper();
        mstrJuncMappobj.scName                   = mstrJuncMappRecord.SC_Name__c;
        mstrJuncMappobj.scCode                   = mstrJuncMappRecord.SC_Code__c;
        mstrJuncMappobj.valueType                = mstrJuncMappRecord.Value_Type__c;
        mstrJuncMappobj.sequenceNO               = mstrJuncMappRecord.Sequence_NO__c;
        mstrJuncMappobj.dednCod                  = mstrJuncMappRecord.Dedn_Cod__c;
        mstrJuncMappobj.rateValueAsPerPolicy     = mstrJuncMappRecord.Rate_value_As_per_Policy__c;
        mstrJuncMappobj.taxApplicable            = mstrJuncMappRecord.Tax_Applicable__c;
        mstrJuncMappobj.taxPercentage            = mstrJuncMappRecord.Tax_Percentage__c;
        mstrJuncMappobj.minCharges               = mstrJuncMappRecord.Min_charges__c;
        mstrJuncMappobj.maxChargesSOC            = mstrJuncMappRecord.Max_Charges_SOC__c;
        mstrJuncMappobj.customerCategory         = mstrJuncMappRecord.Customer_category__c;
        mstrJuncMappobj.modelAge                 = mstrJuncMappRecord.Model_Age__c;
        mstrJuncMappobj.deviationApplicable      = mstrJuncMappRecord.Deviation_Applicable__c;
        mstrJuncMappobj.shownToUI                = mstrJuncMappRecord.Shown_to_UI__c;
        mstrJuncMappobj.isShownAtUI              = (String.isBlank(mstrJuncMappRecord.Shown_to_UI__c))?true:(mstrJuncMappRecord.Shown_to_UI__c=='Yes');
        if(mstrJuncMappRecord.Deviation_Applicable__c == 'Yes') {
            mstrJuncMappobj.isRaiseDeviation = true;
        }
        else if(mstrJuncMappRecord.Deviation_Applicable__c == 'No'){
            mstrJuncMappobj.isRaiseDeviation = false; 
        }
        else if(mstrJuncMappRecord.Deviation_Applicable__c == '' || mstrJuncMappRecord.Deviation_Applicable__c == null){
            mstrJuncMappobj.allowMinValue = true;
        }
        return mstrJuncMappobj;
    }
    
    public static  FldsWrapper wrapperFldsOfChargeMstr(Charges_Master__c chrgeMstrRec) {
        FldsWrapper chrgeMstrobj              = new FldsWrapper();
        chrgeMstrobj.scName                   = chrgeMstrRec.SC_Name__c;
        chrgeMstrobj.scCode                   = chrgeMstrRec.SC_Code__c;
        chrgeMstrobj.valueType                = chrgeMstrRec.Value_Type__c;
        chrgeMstrobj.sequenceNO               = chrgeMstrRec.Sequence_NO__c;
        chrgeMstrobj.dednCod                  = chrgeMstrRec.Dedn_Cod__c;
        chrgeMstrobj.rateValueAsPerPolicy     = chrgeMstrRec.Rate_value_As_per_Policy__c;
        chrgeMstrobj.taxApplicable            = chrgeMstrRec.Tax_Applicable__c;
        chrgeMstrobj.taxPercentage            = chrgeMstrRec.Tax_Percentage__c;
        chrgeMstrobj.minCharges               = chrgeMstrRec.Min_charges__c;
        chrgeMstrobj.maxChargesSOC            = chrgeMstrRec.Max_Charges_SOC__c;
        chrgeMstrobj.customerCategory         = chrgeMstrRec.Customer_category__c;
        chrgeMstrobj.modelAge                 = chrgeMstrRec.Model_Age__c;
        chrgeMstrobj.deviationApplicable      = chrgeMstrRec.Deviation_Applicable__c;
        chrgeMstrobj.shownToUI                = chrgeMstrRec.Shown_to_UI__c;
        chrgeMstrobj.isShownAtUI              = (String.isBlank(chrgeMstrRec.Shown_to_UI__c))?true:(chrgeMstrRec.Shown_to_UI__c=='Yes');
        if(chrgeMstrRec.Deviation_Applicable__c == 'Yes') {
            chrgeMstrobj.isRaiseDeviation = true;
        }
        else if(chrgeMstrRec.Deviation_Applicable__c == 'No'){
            chrgeMstrobj.isRaiseDeviation = false; 
        }
        else if(chrgeMstrRec.Deviation_Applicable__c == '' || chrgeMstrRec.Deviation_Applicable__c == null){
            chrgeMstrobj.allowMinValue = true;
        }
        return chrgeMstrobj;
    }
    
    public static  FldsWrapper wrapperFldsOfCharge(Charge__c chrge) {
        FldsWrapper chrgeobj              = new FldsWrapper();
        if(String.isNotBlank(String.valueOf(chrge.Id))) {
            chrgeobj.Id                       = chrge.Id;
        } 
        chrgeobj.scName                   = chrge.Charges_Name__c;
        chrgeobj.scCode                   = chrge.SC_Code__c;
        chrgeobj.valueType                = chrge.Value_Type__c;
        chrgeobj.sequenceNO               = chrge.Sequence_NO__c;
        chrgeobj.dednCod                  = chrge.Dedn_Cod__c;
        chrgeobj.rateValueAsPerPolicy     = chrge.Rate_value_As_per_Policy__c;
        chrgeobj.sourceStampExpenseSave     = chrge.Source_Stamping_Charge_Save__c;
        chrgeobj.agriEndUseOfProduct     = chrge.Agri_and_End_use_of_product_AGRI__c;
        chrgeobj.isStampingChargeNotApplicable     = chrge.Is_Stamping_Charge_Not_Applicable__c;
        chrgeobj.isUdyamCertificateAvailable     = chrge.Udyam_Certificate_Available__c;
        chrgeobj.taxApplicable            = chrge.Tax_Applicable__c;
        chrgeobj.taxPercentage            = chrge.Tax_Percentage__c;
        chrgeobj.minCharges               = chrge.Min_charges__c;
        chrgeobj.maxChargesSOC            = chrge.Max_Charges_SOC__c;
        chrgeobj.customerCategory         = chrge.Customer_category__c;
        chrgeobj.modelAge                 = chrge.Model_Age__c;
        chrgeobj.deviationApplicable      = chrge.Deviation_Applicable__c;
        chrgeobj.shownToUI                = chrge.Shown_to_UI__c;
        chrgeobj.actualRate               = chrge.Actual_rate__c;
        chrgeobj.chargeAmount             = chrge.Charge_Amount__c;
        chrgeobj.taxAmount                = chrge.Tax_Amount__c;
        chrgeobj.totalAmount              = chrge.Total_Amount__c;
        chrgeobj.isShownAtUI              = (String.isBlank(chrge.Shown_to_UI__c))?true:(chrge.Shown_to_UI__c=='Yes');
        if(chrge.Deviation_Applicable__c == 'Yes') {
            chrgeobj.isRaiseDeviation = true;
        }
        else if(chrge.Deviation_Applicable__c == 'No'){
            chrgeobj.isRaiseDeviation = false; 
        }
        else if(chrge.Deviation_Applicable__c == '' || chrge.Deviation_Applicable__c == null){
            chrgeobj.allowMinValue = true;
        }
        return chrgeobj;
    }

    /*
     * Recompute Stamping Charge
     * SFAU-4796
    */
    public static void computeStampDutyCharge(Set<Id> loanAppSet){
        Set<String> stateSet = new Set<String>();
        List<Charge__c> chargeList = new List<Charge__c>();
        Map<String, List<Stamping_Charges_Calculation__mdt>> stateMap = new Map<String, List<Stamping_Charges_Calculation__mdt>>();

        Map<Id, Loan_application__c> lAMap = new Map<ID, Loan_application__c>([select id, Branch_Master__r.State__r.Account_Name__c, loan_amount__c, Product__c,
                                                  (Select id from Applicants__r where recordtype.name = 'Guarantor' and isinactive__c = false),
                                                  (select Id, Actual_rate__c, Charge_Amount__c, Tax_Amount__c, Total_Amount__c,
                                     				Charges_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                     				Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                     				Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                    Deviation_Applicable__c, Shown_to_UI__c,  Source_Stamping_Charge_Save__c, Agri_and_End_use_of_product_AGRI__c, Is_Stamping_Charge_Not_Applicable__c, Udyam_Certificate_Available__c from Charges__r where Charges_Name__c = 'Stamp duty')
                                                  from Loan_application__c where id =:loanAppSet]);
        
        List<Charge_Data__mdt> chrgeMstrDataLst = [SELECT id, Id__c, Name__c, UI_Sequence_No__c
                                                   FROM Charge_Data__mdt WITH SECURITY_ENFORCED];
        
        // Product applicable for R1 and R2 products
        Set<String> productCodes = new Set<String>();
        
        for(Id loanId: lAMap.keySet()){
            Loan_Application__c loan = lAMap.get(loanId);
            productCodes.add(loan.Product__c);
            stateSet.add(loan.Branch_Master__r.State__r.Account_Name__c);
        }
        
        List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = new List<Stamping_Charges_Calculation__mdt>();
        
        for(Stamping_Charges_Calculation__mdt stampCharge : [SELECT id,State__c, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
                                                                             As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
                                                                             Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
                                                                             Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
                                                            Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c, Applicable_Product__c, IsException__c, Loan_Amount_Not_Applicable_Upto__c, Vehicle_Usage__c
                                                                             FROM Stamping_Charges_Calculation__mdt
                                                            WHERE State__c in: stateSet WITH SECURITY_ENFORCED]){

            Set<String> applicableProductCodeSet = new Set<String>(stampCharge.Applicable_Product__c.split(',')); // Applicable product sets
            for(String productCode : productCodes){
                if(applicableProductCodeSet.contains(productCode)){
                    stampChrgesCalculationLst.add(stampCharge);
                }
            }
        }

        // Product applicable for R1 and R2 products
        // R1 code
        // List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = [SELECT id,State__c, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
        //                                                                      As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
        //                                                                      Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
        //                                                                      Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
        //                                                                      Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c
        //                                                                      FROM Stamping_Charges_Calculation__mdt
        //                                                                      WHERE State__c in: stateSet WITH SECURITY_ENFORCED];
        // R1 code

        for(Stamping_Charges_Calculation__mdt stampCharge: stampChrgesCalculationLst){
            if(stateMap.containsKey(stampCharge.State__c)) {
                List<Stamping_Charges_Calculation__mdt> stampList = stateMap.get(stampCharge.State__c);
                stampList.add(stampCharge);
                stateMap.put(stampCharge.State__c, stampList);
            } else {
                stateMap.put(stampCharge.State__c, new List<Stamping_Charges_Calculation__mdt> { stampCharge });
            }
        }   

        for(Id loanId: lAMap.keySet()){
            Loan_Application__c loanApp = lAMap.get(loanId);
            loanAmount = loanApp.loan_amount__c;
            boolIsGuarantorAvailable = loanApp.Applicants__r.size() > 0 ? true : false;  
    		NoofGuarantorAvailable = loanApp.Applicants__r.size();
            
            if(loanApp.Charges__r.size() > 0){
                Charge__c charge = loanApp.Charges__r[0];
                fldsWrapper wrapper = wrapperFldsOfCharge(charge); 
                
                Decimal finalStampingCharge= calculateStampDutyCharge(wrapper, stateMap.get(loanApp.Branch_Master__r.State__r.Account_Name__c));
                Charge__c newCharge = new Charge__c(Id = charge.Id);
                newCharge.Charge_Amount__c = finalStampingCharge;
                newCharge.Total_Amount__c = finalStampingCharge + (charge.Tax_Percentage__c * finalStampingCharge);
                newCharge.Tax_Amount__c = charge.Charge_Amount__c * charge.Tax_Percentage__c;
                
                System.debug('@@@Data:'+newCharge);
                chargeList.add(newCharge);
            }
        }

        if(!chargeList.isEmpty()){
            update chargeList;
        }
        
    }

    public class ChargesException extends Exception{}
    
    public class ChargeWrapper {
        @AuraEnabled public List<Loan_Application__c> loanApplList;
        @AuraEnabled public List<FldsWrapper> chargesList;
        @AuraEnabled public FldsWrapper stampDutyRec;
    }
    
    public class FldsWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String scName;
        @AuraEnabled public String scCode;
        @AuraEnabled public String valueType;
        @AuraEnabled public Decimal sequenceNO;
        @AuraEnabled public Decimal dednCod;
        @AuraEnabled public Decimal rateValueAsPerPolicy;
        @AuraEnabled public String sourceStampExpenseSave; // For Tractor QDE saving stamping expense from charge master
        @AuraEnabled public String taxApplicable;
        @AuraEnabled public Decimal taxPercentage;
        @AuraEnabled public Decimal minCharges;
        @AuraEnabled public Decimal maxChargesSOC;
        @AuraEnabled public String customerCategory;
        @AuraEnabled public String modelAge;
        @AuraEnabled public String deviationApplicable;
        @AuraEnabled public String shownToUI;
        @AuraEnabled public Decimal actualRate;
        @AuraEnabled public Decimal chargeAmount;
        @AuraEnabled public Decimal taxAmount;
        @AuraEnabled public Decimal totalAmount;
        @AuraEnabled public Boolean isRaiseDeviation;
        @AuraEnabled public Boolean allowMinValue;
        @AuraEnabled public Boolean isShownAtUI;
        @AuraEnabled public Boolean agriEndUseOfProduct; // For Tractor Agri usage control for MP
        @AuraEnabled public Boolean isStampingChargeNotApplicable; // For Tractor stamping charge exclusion
        @AuraEnabled public Boolean isUdyamCertificateAvailable; // For Commercial exception for telegana and other Stamp
        public FldsWrapper(){
            this.isShownAtUI = true;
        }
    }
    
    public class SaveChargeWrapper {
        @AuraEnabled public List<Charge__c> chargeList;
        @AuraEnabled public String message;
    }
}