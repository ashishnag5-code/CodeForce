/*******************************************************************************************
 * @Name         WIRRRecordsCreationController
 * @Author       Yash Shukla
 * @Description   Controller class for Upserting WIRR RECORDS FOR FULLY DISBURSED AND PARTIALLY DISBURSED LOAN APPLICATIONS
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Yash Shukla        19/04/2023         Initial Creation 
 *******************************************************************************************/
public without sharing class WIRRRecordsCreationController {
    
    private static Map<String,WIRR_FieldAPI_Product_Data__mdt> metaDataRecordsMap = new Map<String,WIRR_FieldAPI_Product_Data__mdt>();
    //private static String wirrQueryString = 'SELECT ID,Name,Record_Key__c,Branch__c,User__c ';
    private static Set<String> fieldsAPIName = new Set<STring>();

    private static final String WIRR_TOTAL_LOAN_AMOUNT_FIELD = 'TotalLoanAmount';
    private static final String WIRR_IRR_LOAN_AMOUNT_FIELD = 'IRRxLoanAmount';
    private static final String PRODUCT_LABEL_ENUM_KEY = 'ProductLabel';

    private static map<String, String> collateralTypeCache {
        get {
            if( collateralTypeCache == null ){
                collateralTypeCache = Utility.getPicklistApiToLabel( 'Loan_Application__c', 'Collateral_Type__c' ); 
            }
            return collateralTypeCache;
        }
        private set;
    }

    public static String setMetaDataMap_QueryString() {
        String fieldQueryString = 'SELECT ID,Name,Record_Key__c,Branch__c,User__c, ';
        for(WIRR_FieldAPI_Product_Data__mdt mdtRec : [SELECT Id, Label, Sum_Of_Loan_API_Name__c , Sum_Of_Loan_IRR_API_Name__c, Fallback_Label__c FROM 
                                                      WIRR_FieldAPI_Product_Data__mdt WHERE Sum_Of_Loan_API_Name__c!='' AND Sum_Of_Loan_IRR_API_Name__c!='']) {
                                                        //R2-2634
                                                          //metaDataRecordsMap.put(mdtRec.Label, mdtRec);
                                                          metaDataRecordsMap.put(mdtRec.Fallback_Label__c != null ?  mdtRec.Fallback_Label__c : mdtRec.Label, mdtRec); 
                                                          //R2-2634
                                                        //   fieldQueryString+=','+mdtRec.Sum_Of_Loan_API_Name__c+','+mdtRec.Sum_Of_Loan_IRR_API_Name__c;
                                                          fieldsAPIName.add(mdtRec.Sum_Of_Loan_API_Name__c);fieldsAPIName.add(mdtRec.Sum_Of_Loan_IRR_API_Name__c);
                                                      }
        fieldQueryString += String.join( new List<String>( fieldsAPIName ), ', ' ) + ' FROM WIRR__C';
        return fieldQueryString;
    }
    
    private static Map<String,String> setProductPickListMap(){
        Map<String,String> retMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Loan_Application__c.Product__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            retMap.put(pickListVal.getValue(),pickListVal.getLabel());
        }
        return retMap;
    }
    
    private static WIRR__c setWIRRInstance(String key, String currentMonth, String currentYear, String refId, Boolean isBranch, String rtType) {
        WIRR__c rec = new WIRR__c(Record_Key__c =key,Month__c=currentMonth,Year__c=currentYear,RT__c=rtType);
        for(String str:fieldsAPIName) {
            rec.put(str,0.00);
        }
        if(isBranch){
            rec.put('Branch__c',refId);
        }
        else{
            rec.put('User__c',refId);
        }
        return rec;
    }
    
    public static void handleFullDisbursedWIRRRecordUpsertion(Set<Loan_Application__c> applicationRecords) {
        system.debug('inside');
        Map<String,String> productPickListValue_LabelMap = setProductPickListMap();
        String queryString = setMetaDataMap_QueryString();
        DateTime dt = Datetime.now();
        String currentYear = dt.format('YYYY');
        String currentMonth = dt.format('MMM');
        Map<String, List<Loan_Application__c>> branchLoanApplicationsMap = new Map<String, List<Loan_Application__c>>();
        Map<String, List<Loan_Application__c>> userLoanApplicationsMap = new Map<String, List<Loan_Application__c>>();
        List<WIRR__c> wirrRecords = new List<WIRR__c>();
        Set<Id> branchIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        
        for(Loan_Application__c applRec : applicationRecords) {
            if(String.isNotBlank(String.valueOf(applRec.Branch_Master__c ))) {
                if(!branchLoanApplicationsMap.containsKey(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear)){
                    branchLoanApplicationsMap.put(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear,new List<Loan_Application__c>());
                }
                branchLoanApplicationsMap.get(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear).add(applRec);
                branchIds.add(applRec.Branch_Master__c);
            }
            if(!userLoanApplicationsMap.containsKey(applRec.OwnerId+'_'+currentMonth+'_'+currentYear)) {
                userLoanApplicationsMap.put(applRec.OwnerId+'_'+currentMonth+'_'+currentYear, new List<Loan_Application__c>());
            }
            userLoanApplicationsMap.get(applRec.OwnerId+'_'+currentMonth+'_'+currentYear).add(applRec);
            ownerIds.add(applRec.OwnerId);
        }
        
        Map<String,WIRR__c> upsertedWIRRRecordMap = new Map<String,WIRR__c>();
        Map<String,WIRR__c> existingWIRRRecords = new Map<String,WIRR__c>();
        queryString += ' WHERE Branch__c IN :branchIds OR User__c IN :ownerIds';
        system.debug('quere '+queryString);
        for(WIRR__c wirr : Database.query(queryString)) {
            existingWIRRRecords.put(wirr.Record_Key__c , wirr);
        }
        if(!branchIds.isEmpty()) {
            for(String branchKey : branchLoanApplicationsMap.keySet()) {
                if(!branchLoanApplicationsMap.get(branchKey).isEmpty()) {
                    for(Loan_Application__c appl : branchLoanApplicationsMap.get(branchKey)) {

                        String loanType = productPickListValue_LabelMap.get(appl.Product__c)?.substringBetween( '(', ')' );
                        WIRR_FieldAPI_Product_Data__mdt wirrConfig = metaDataRecordsMap.get( productPickListValue_LabelMap.get(appl.Product__c) );
                        //R2-2634
                        // WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( loanType == 'Cash on Wheels' ? 'COW' : loanType ) );
                        WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( System.Label.COW_Product_Names.contains(loanType) ? 'COW' : loanType ) );
                        //R2-2634
                        if(String.isNotBlank(appl.Product__c) && wirrConfig != null ) {
                            WIRR__c wiirRecord;
                            if(existingWIRRRecords.containsKey(branchKey)) {
                                wiirRecord = existingWIRRRecords.get(branchKey);
                                // WIRR_FieldAPI_Product_Data__mdt wirrConfig = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c));
                                String loanAmountFieldAPIName = wirrConfig.Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = wirrConfig.Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (wiirRecord.get(loanAmountFieldAPIName) != null ? Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountFieldAPIName))) : 0 ) + appl.Total_Loan_Amount__c;
                                Decimal totalIRRAmount = ( wiirRecord.get(loanAmountIRRFieldAPIName) != null ? Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountIRRFieldAPIName))) : 0 ) + ( appl.Total_Loan_Amount__c * appl.ROI__c );


                                evaluateWirrAttributes(
                                    wiirRecord,
                                    appl,
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );
                                System.debug(' == WIRR after Collateral Based =' + JSON.serializePretty(wiirRecord));

                                wiirRecord.put(loanAmountFieldAPIName, loanAmount);
                                wiirRecord.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(branchKey, wiirRecord);
                            }
                            else {
                                if(!upsertedWIRRRecordMap.containsKey(branchKey)) {
                                    String branchId = appl.Branch_Master__c;
                                    upsertedWIRRRecordMap.put(branchKey,setWIRRInstance(branchKey,currentMonth,currentYear,branchId,true,'Branch'));
                                }
                                WIRR__c newWIRRRec = upsertedWIRRRecordMap.get(branchKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (String.valueOf(newWIRRRec.get(loanAmountFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountFieldAPIName)));
                                loanAmount+=appl.Total_Loan_Amount__c;
                                Decimal totalIRRAmount = (String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName)));
                                totalIRRAmount+=(appl.Total_Loan_Amount__c*appl.ROI__c);
            
                                evaluateWirrAttributes(
                                    newWIRRRec,
                                    appl,
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );
                                newWIRRRec.put(loanAmountFieldAPIName, loanAmount);
                                newWIRRRec.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(branchKey, newWIRRRec);
                            }
                        }
                    }
                }
            }
        }
        
        if(!ownerIds.isEmpty()) {
            for(String userKey : userLoanApplicationsMap.keySet()) {
                if(!userLoanApplicationsMap.get(userKey).isEmpty()) {
                    for(Loan_Application__c appl : userLoanApplicationsMap.get(userKey)) {
                        if(String.isNotBlank(appl.Product__c) && metaDataRecordsMap.containsKey(productPickListValue_LabelMap.get(appl.Product__c))) {
                            WIRR__c wiirRecord;
                            String loanType = productPickListValue_LabelMap.get(appl.Product__c)?.substringBetween( '(', ')' );
                            //R2-2634
                            //  WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( loanType == 'Cash on Wheels' ? 'COW' : loanType ) );
                            WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( System.Label.COW_Product_Names.contains(loanType) ? 'COW' : loanType ) );
                            //R2-2634
                            if(existingWIRRRecords.containsKey(userKey)) {
                                wiirRecord = existingWIRRRecords.get(userKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (wiirRecord.get(loanAmountFieldAPIName) != null ? Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountFieldAPIName))) : 0 )+ appl.Total_Loan_Amount__c;
                                Decimal totalIRRAmount = ( wiirRecord.get(loanAmountIRRFieldAPIName) != null ? Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountIRRFieldAPIName))) : 0) + (appl.Total_Loan_Amount__c*appl.ROI__c);

                                evaluateWirrAttributes(
                                    wiirRecord,
                                    appl,
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );

                                wiirRecord.put(loanAmountFieldAPIName, loanAmount);
                                wiirRecord.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(userKey, wiirRecord);
                            }
                            else {
                                if(!upsertedWIRRRecordMap.containsKey(userKey)) {
                                    String onwerId = appl.ownerId;
                                    upsertedWIRRRecordMap.put(userKey,setWIRRInstance(userKey,currentMonth,currentYear,onwerId,false,'User'));
                                }
                                WIRR__c newWIRRRec = upsertedWIRRRecordMap.get(userKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (String.valueOf(newWIRRRec.get(loanAmountFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountFieldAPIName)));
                                loanAmount+=appl.Total_Loan_Amount__c;
                                Decimal totalIRRAmount = (String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName)));
                                totalIRRAmount+=(appl.Total_Loan_Amount__c*appl.ROI__c);

                                evaluateWirrAttributes(
                                    newWIRRRec,
                                    appl,
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );

                                newWIRRRec.put(loanAmountFieldAPIName, loanAmount);
                                newWIRRRec.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(userKey, newWIRRRec);
                            }
                        }
                    }
                }
            }
        }
        
        if(!upsertedWIRRRecordMap.isEmpty()){
            Database.upsert(upsertedWIRRRecordMap.values());
        }
    }
    
    public static void handleTrancheWIRRRecordUpsertion(Set<Id> loanIds) {
        Map<String,String> productPickListValue_LabelMap = setProductPickListMap(); 
        String queryString = setMetaDataMap_QueryString();
        DateTime dt = Datetime.now();
        String currentYear = dt.format('YYYY');
        String currentMonth = dt.format('MMM');
        Map<String, Payment__c> loanIdPaymentRecordMap = new Map<String, Payment__c>();
        Map<String, List<Loan_Application__c>> branchLoanApplicationsMap = new Map<String, List<Loan_Application__c>>();
        Map<String, List<Loan_Application__c>> userLoanApplicationsMap = new Map<String, List<Loan_Application__c>>();
        List<WIRR__c> wirrRecords = new List<WIRR__c>();
        Set<Id> branchIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        List<Loan_Application__c> applicationRecords = [SELECT Id, ROI__c, Branch_Master__c, OwnerId, Disbursed_Tranche__c, Product__c, Collateral_Type__c,
                                                        (SELECT Id, Tranche_Number__c, Disbursement_Amount__c  FROM
                                                         Payments__r WHERE RecordType.Name = 'Tranche') FROM Loan_Application__c WHERE ID IN:loanIds];
        system.debug('yash '+applicationRecords);
        for(Loan_Application__c applRec : applicationRecords) {
            if(!applRec.Payments__r.isEmpty()) {
                for(Payment__c payment : applRec.Payments__r) {
                    if(applRec.Disbursed_Tranche__c == payment.Tranche_Number__c) {
                        loanIdPaymentRecordMap.put(applRec.Id, payment);
                        break;
                    }
                }
            }
            if(String.isNotBlank(String.valueOf(applRec.Branch_Master__c ))) {
                if(!branchLoanApplicationsMap.containsKey(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear)){
                    branchLoanApplicationsMap.put(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear,new List<Loan_Application__c>());
                }
                branchLoanApplicationsMap.get(applRec.Branch_Master__c+'_'+currentMonth+'_'+currentYear).add(applRec);
                branchIds.add(applRec.Branch_Master__c);
            }
            if(!userLoanApplicationsMap.containsKey(applRec.OwnerId+'_'+currentMonth+'_'+currentYear)) {
                userLoanApplicationsMap.put(applRec.OwnerId+'_'+currentMonth+'_'+currentYear, new List<Loan_Application__c>());
            }
            userLoanApplicationsMap.get(applRec.OwnerId+'_'+currentMonth+'_'+currentYear).add(applRec);
            ownerIds.add(applRec.OwnerId);
        }
        
        Map<String,WIRR__c> upsertedWIRRRecordMap = new Map<String,WIRR__c>();
        Map<String,WIRR__c> existingWIRRRecords = new Map<String,WIRR__c>();
        queryString += ' WHERE Branch__c IN :branchIds OR User__c IN :ownerIds';
        for(WIRR__c wirr : Database.query(queryString)) {
            existingWIRRRecords.put(wirr.Record_Key__c , wirr);
        }
        if(!branchIds.isEmpty()) {
            for(String branchKey : branchLoanApplicationsMap.keySet()) {
                if(!branchLoanApplicationsMap.get(branchKey).isEmpty()) {
                    for(Loan_Application__c appl : branchLoanApplicationsMap.get(branchKey)) {
                        if(String.isNotBlank(appl.Product__c) && metaDataRecordsMap.containsKey(productPickListValue_LabelMap.get(appl.Product__c)) && loanIdPaymentRecordMap.containsKey(appl.Id)) {
                            WIRR__c wiirRecord;
                            Payment__c paymentRecord = loanIdPaymentRecordMap.get(appl.Id);
                            String loanType = productPickListValue_LabelMap.get(appl.Product__c)?.substringBetween( '(', ')' );
                            //R2-2634
                            //  WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( loanType == 'Cash on Wheels' ? 'COW' : loanType ) );
                            WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( System.Label.COW_Product_Names.contains(loanType) ? 'COW' : loanType ) );
                            //R2-2634
                            
                            if(existingWIRRRecords.containsKey(branchKey)) {
                                wiirRecord = existingWIRRRecords.get(branchKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountFieldAPIName)))+paymentRecord.Disbursement_Amount__c;
                                Decimal totalIRRAmount = Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountIRRFieldAPIName)))+(paymentRecord.Disbursement_Amount__c*appl.ROI__c);

                                evaluateWirrAttributes(
                                    wiirRecord,
                                    new Loan_Application__c( Total_Loan_Amount__c = paymentRecord.Disbursement_Amount__c, ROI__c = appl.ROI__c ),
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );

                                wiirRecord.put(loanAmountFieldAPIName, loanAmount);
                                wiirRecord.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(branchKey, wiirRecord);
                            }
                            else {
                                if(!upsertedWIRRRecordMap.containsKey(branchKey)) {
                                    String branchId = appl.Branch_Master__c;
                                    upsertedWIRRRecordMap.put(branchKey,setWIRRInstance(branchKey,currentMonth,currentYear,branchId,true,'Branch'));
                                }
                                WIRR__c newWIRRRec = upsertedWIRRRecordMap.get(branchKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (String.valueOf(newWIRRRec.get(loanAmountFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountFieldAPIName)));
                                loanAmount+=paymentRecord.Disbursement_Amount__c;
                                Decimal totalIRRAmount = (String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName)));
                                totalIRRAmount+=(paymentRecord.Disbursement_Amount__c*appl.ROI__c);
                                

                                // Collateral Type based WIRR calculation
                                evaluateWirrAttributes(
                                    newWIRRRec,
                                    new Loan_Application__c( Total_Loan_Amount__c = paymentRecord.Disbursement_Amount__c, ROI__c = appl.ROI__c ),
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );

                                newWIRRRec.put(loanAmountFieldAPIName, loanAmount);
                                newWIRRRec.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(branchKey, newWIRRRec);
                            }
                        }
                    }
                }
            }
        }
        
        if(!ownerIds.isEmpty()) {
            for(String userKey : userLoanApplicationsMap.keySet()) {
                if(!userLoanApplicationsMap.get(userKey).isEmpty()) {
                    for(Loan_Application__c appl : userLoanApplicationsMap.get(userKey)) {
                        if(String.isNotBlank(appl.Product__c) && metaDataRecordsMap.containsKey(productPickListValue_LabelMap.get(appl.Product__c)) && loanIdPaymentRecordMap.containsKey(appl.Id)) {
                            WIRR__c wiirRecord;
                            Payment__c paymentRecord = loanIdPaymentRecordMap.get(appl.Id);
                            String loanType = productPickListValue_LabelMap.get(appl.Product__c)?.substringBetween( '(', ')' );
                            //R2-2634
                            // WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( loanType == 'Cash on Wheels' ? 'COW' : loanType ) );
                            WIRR_FieldAPI_Product_Data__mdt collateralTypeBasedConfig = metaDataRecordsMap.get( collateralTypeCache.get( appl.Collateral_Type__c ) + ' ' + ( System.Label.COW_Product_Names.contains(loanType) ? 'COW' : loanType ) );
                            //R2-2634
                            if(existingWIRRRecords.containsKey(userKey)) {
                                wiirRecord = existingWIRRRecords.get(userKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountFieldAPIName)))+paymentRecord.Disbursement_Amount__c;
                                Decimal totalIRRAmount = Decimal.valueOf(String.valueOf(wiirRecord.get(loanAmountIRRFieldAPIName)))+(paymentRecord.Disbursement_Amount__c*appl.ROI__c);

                                evaluateWirrAttributes(
                                    wiirRecord,
                                    new Loan_Application__c( Total_Loan_Amount__c = paymentRecord.Disbursement_Amount__c, ROI__c = appl.ROI__c ),
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );
            
                                wiirRecord.put(loanAmountFieldAPIName, loanAmount);
                                wiirRecord.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(userKey, wiirRecord);
                            }
                            else {
                                if(!upsertedWIRRRecordMap.containsKey(userKey)) {
                                    String onwerId = appl.ownerId;
                                    upsertedWIRRRecordMap.put(userKey,setWIRRInstance(userKey,currentMonth,currentYear,onwerId,false,'User'));
                                }
                                WIRR__c newWIRRRec = upsertedWIRRRecordMap.get(userKey);
                                String loanAmountFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_API_Name__c;
                                String loanAmountIRRFieldAPIName = metaDataRecordsMap.get(productPickListValue_LabelMap.get(appl.Product__c)).Sum_Of_Loan_IRR_API_Name__c;
                                Decimal loanAmount = (String.valueOf(newWIRRRec.get(loanAmountFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountFieldAPIName)));
                                loanAmount+=paymentRecord.Disbursement_Amount__c;
                                Decimal totalIRRAmount = (String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName))==null)?0.00:Decimal.valueOf(String.valueOf(newWIRRRec.get(loanAmountIRRFieldAPIName)));
                                totalIRRAmount+=(paymentRecord.Disbursement_Amount__c*appl.ROI__c);

                                evaluateWirrAttributes(
                                    newWIRRRec,
                                    new Loan_Application__c( Total_Loan_Amount__c = paymentRecord.Disbursement_Amount__c, ROI__c = appl.ROI__c ),
                                    new map<String, String>{
                                        WIRR_TOTAL_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_API_Name__c,
                                        WIRR_IRR_LOAN_AMOUNT_FIELD => collateralTypeBasedConfig?.Sum_Of_Loan_IRR_API_Name__c,
                                        PRODUCT_LABEL_ENUM_KEY => productPickListValue_LabelMap.get( appl.Product__c )
                                    }
                                );
    
                                newWIRRRec.put(loanAmountFieldAPIName, loanAmount);
                                newWIRRRec.put(loanAmountIRRFieldAPIName, totalIRRAmount);
                                upsertedWIRRRecordMap.put(userKey, newWIRRRec);
                            }
                        }
                    }
                }
            }
        }
        
        if(!upsertedWIRRRecordMap.isEmpty()){
            Database.upsert(upsertedWIRRRecordMap.values());
        }
        
        
        
    }

    public static WIRR__c evaluateWirrAttributes( WIRR__c existingWirr, Loan_Application__c loan, map<String, String> additionalParams ){
        
        String loanAmountFieldApi = additionalParams.get( WIRR_TOTAL_LOAN_AMOUNT_FIELD ),
            irrFieldApi = additionalParams.get( WIRR_IRR_LOAN_AMOUNT_FIELD );

        if( String.isBlank( loanAmountFieldApi ) || String.isBlank( irrFieldApi ) ){
            return existingWirr;
        }

        Decimal existingLoanAmount = existingWirr.get( loanAmountFieldApi ) != null ? (Decimal)existingWirr.get( loanAmountFieldApi ) : 0,
            existingIrr = existingWirr.get( irrFieldApi ) != null ? (Decimal)existingWirr.get( irrFieldApi ) : 0,
            totalLoanAmount = existingLoanAmount + loan.Total_Loan_Amount__c,
            totalIrr = existingIrr + ( loan.Total_Loan_Amount__c * loan.ROI__c );
                                    
        existingWirr.put( loanAmountFieldApi, totalLoanAmount );
        existingWirr.put( irrFieldApi, totalIrr );

        return existingWirr;
    }
    
}