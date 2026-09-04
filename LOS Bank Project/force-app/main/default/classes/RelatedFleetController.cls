public without Sharing class RelatedFleetController {
    
    //method is used to get the fleets record
    @AuraEnabled
    public static RelatedFleetControllerWrapper getFleets(String loanAppId){
        List<Fleet__c> fltLst = new List<Fleet__c>();
        List<String> mfgYearLst = new List<String>();
        RelatedFleetControllerWrapper wrapObj= new RelatedFleetControllerWrapper();
        fltLst = [Select Id, Name,Type_of_Vehicle__c,Loan_Amount__c, Relationship_with_borrower__c ,Loan_Application__r.Stage__c,Loan_Application__r.LAN__c,
            Vehicle_Make_Model__c, Vehicle_Number__c FROM Fleet__c Where Loan_Application__c =: loanAppId AND Inactive__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate]; // Added extra fields by Ashish R2-633    
        if(!fltLst.isEmpty()){
            wrapObj.fltLst = fltLst;
        }
        Map<String, Manufacturing_Year_Data__mdt> mapMfgYear = Manufacturing_Year_Data__mdt.getAll();
        for(String year: mapMfgYear.keySet()){
            if(mapMfgYear.get(year).active__c == true){
                System.debug(year+' --> '+mapMfgYear.get(year).year__c);
                mfgYearLst.add(String.valueOf(mapMfgYear.get(year).year__c.intValue()));
            }
        }
        if(!mfgYearLst.isEmpty()){
            wrapObj.mfgYear = mfgYearLst;
        }
        wrapObj.loanInstance =[SELECT id,Product__c,Customer_Grade__c,Sub_Grade__c,Original_Vehicle_Usage__c,Collateral_Type__c,RecordType.Name, (SELECT Complete_Name__c, Relationship_with_applicant__c, Id, RecordType.Name  FROM Applicants__r WHERE IsInactive__c = false AND (RecordType.DeveloperName = 'Primary_Applicant' OR RecordType.DeveloperName = 'Co_Applicant' OR  RecordType.DeveloperName = 'Guarantor')  ORDER BY RecordType.Name ASC) FROM Loan_Application__c WHERE id=:loanAppId WITH SECURITY_ENFORCED]; //Added by Ashish R2-633  
        wrapObj.applicantList =  getApplicantList(loanAppId);//Added by Ashish R2-633   
        //START || Added by Ashish R2-633   
        String CEProductCodes= System.label.Construction_Equipment_Product_Codes;
        String CVProductCodes= System.label.Commercial_Product_Codes;
        if(CEProductCodes.contains(wrapObj.loanInstance.Product__c) || CVProductCodes.contains(wrapObj.loanInstance.Product__c) ){
            calculateFreeFinanceRatio(loanAppId);
        }
        return wrapObj;
    }
    
    //method is used to save/add the fleet record
    @AuraEnabled
    public static String saveFleet(Fleet__c fltRecord){
        Insert fltRecord;
        return fltRecord.id;
    }
    
    //method is used to update the fleet record
    @AuraEnabled
    public static Id updateFleet(String fltRecId, String context, Fleet__c fltRec){
        Fleet__c fltObj = new Fleet__c();
        if(context == 'delete'){
            fltObj.Id = fltRecId;
            fltObj.Inactive__c = true;
        }
        if(context == 'edit'){
            fltObj = fltRec;
        }
        Update fltObj;
        return fltObj.Id;
    }
    
    //method is used to get the fleet record
    @AuraEnabled
    public static Fleet__c getFleet(String fltRecId){
        return [Select Id,Type_of_Vehicle__c,Loan_Amount__c, Fleet_owned_by__c, Name, Relationship_with_borrower__c , Vehicle_Number__c, Vehicle_Make_Model__c, MFG_Year__c, HPN_Status__c, Financial_Institution__c, Loan_Tenure__c, Financial_Institution__r.Bank_Name__c, Installment_Paid__c, Applicant__c FROM Fleet__c Where Id =: fltRecId WITH SECURITY_ENFORCED];//R2 Ashish|| Added Fleet_owned_by__c,Type_of_Vehicle__c field in Query || R2-633
    }

    static Decimal getDecimal(Object decimalInstance) {
        try {
            return (Decimal) decimalInstance;
        } catch(Exception ex) {
            return null;
        }
    }

    static String getRelationshipValue(Object valueFromExcel, Applicant__c applicantRecord) {
        if (applicantRecord == null) {
            if (valueFromExcel == null) {
                return null;
            }
            return (String) valueFromExcel;
        }
        if (applicantRecord.RecordType.DeveloperName == 'Primary_Applicant') {
            return 'SELF';
        } else if (applicantRecord.RecordType.DeveloperName == 'Co_Applicant' || applicantRecord.RecordType.DeveloperName == 'Guarantor') {
            return applicantRecord.Relationship_with_applicant__c;
        }
        return (String) valueFromExcel;
    }

    static String getFleetOwnedBy(Applicant__c applicantRecord) {
        Map<String, String> recordTypeToFleetOwnedByMap = new Map<String, String>{'Primary_Applicant' => 'Applicant',
            'Co_Applicant' => 'Co-Applicant', 'Guarantor' => 'Guarantor'};
        if (applicantRecord == null) {
            return 'Other';
        }
        if (recordTypeToFleetOwnedByMap.containsKey(applicantRecord.RecordType.DeveloperName)) {
            return recordTypeToFleetOwnedByMap.get(applicantRecord.RecordType.DeveloperName);
        }
        return 'Other';
    }

    static String getNameValue(Object nameFromExcel, Applicant__c applicantRecord) {
        if (applicantRecord == null && nameFromExcel != null) {
            return String.valueOf(nameFromExcel).left(80);
        }
        if (applicantRecord == null) {
            return 'Other';
        }
        return applicantRecord.Complete_Name__c + ' - ' + applicantRecord.RecordType.Name;
    }

   
    @AuraEnabled
    public static String createCSVFleetRecords(String base64Data, String loanId) {
        List<Object> listOfFleetRecords = (List<Object>) JSON.deserializeUntyped(base64Data.replace('\\', ''));
        List<Fleet__c> fleetList = new List<Fleet__c>();
        Map<String, Applicant__c> applicantNameMap = new Map<String, Applicant__c>();
        Set<String> listOfFinancialInstitutionNames = new Set<String>{'Others'};
        Map<String, Id> financialInstitutionIds = new Map<String, Id>();

        List<String> fleetInsertStatus = new List<String>();

        for (Applicant__c each : [SELECT Id, Complete_Name__c, Relationship_with_applicant__c, RecordType.DeveloperName, RecordType.Name
            FROM Applicant__c WHERE Loan__c = :loanId]) {
            applicantNameMap.put(each.Complete_Name__c, each);
        }

        for (Object each : listOfFleetRecords) {
            Map<String, Object> eachFleetRecord = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(each));
            if (eachFleetRecord.get('Financial_Institution__c') != null) {
                listOfFinancialInstitutionNames.add((String) eachFleetRecord.get('Financial_Institution__c'));
            }
        }

        for (Generic_Master__c each : [SELECT Id, Bank_Name__c FROM Generic_Master__c WHERE RecordType.Name = 'Financial Institution Name'
            AND Bank_Name__c IN :listOfFinancialInstitutionNames WITH SECURITY_ENFORCED]) {
            financialInstitutionIds.put(each.Bank_Name__c, each.Id);
        }
        for (Object each : listOfFleetRecords) {
            Map<String, Object> eachFleetRecord = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(each));
            listOfFinancialInstitutionNames.add((String) eachFleetRecord.get('Financial_Institution__c'));
            fleetList.add(new Fleet__c(
                Name = getNameValue(eachFleetRecord.get('Name'), applicantNameMap.containsKey((String) eachFleetRecord.get('Name')) ? applicantNameMap.get((String) eachFleetRecord.get('Name')) : null),
                Loan_Application__c = loanId,
                Applicant__c = applicantNameMap.containsKey((String) eachFleetRecord.get('Name')) ? applicantNameMap.get((String) eachFleetRecord.get('Name')).Id : null,
                Financial_Institution__c = financialInstitutionIds.containsKey((String) eachFleetRecord.get('Financial_Institution__c'))
                    ? financialInstitutionIds.get((String) eachFleetRecord.get('Financial_Institution__c')) : financialInstitutionIds.get('Others'),
                Relationship_with_borrower__c = getRelationshipValue(eachFleetRecord.get('Relationship_with_borrower__c'),
                    applicantNameMap.containsKey((String) eachFleetRecord.get('Name')) ? applicantNameMap.get((String) eachFleetRecord.get('Name')) : null),
                Vehicle_Number__c = (String) eachFleetRecord.get('Vehicle_Number__c'),
                Fleet_owned_by__c = getFleetOwnedBy(applicantNameMap.containsKey((String) eachFleetRecord.get('Name')) ? applicantNameMap.get((String) eachFleetRecord.get('Name')) : null),
                Vehicle_Make_Model__c = (String) eachFleetRecord.get('Vehicle_Make_Model__c'),
                MFG_Year__c = eachFleetRecord.get('MFG_Year__c') != null ? String.valueOf(eachFleetRecord.get('MFG_Year__c')) : null,
                HPN_Status__c = (String) eachFleetRecord.get('HPN_Status__c'),
                Loan_Tenure__c = ((String) eachFleetRecord.get('HPN_Status__c')) == 'Free' ? null : getDecimal(eachFleetRecord.get('Loan_Tenure__c')),
                Installment_Paid__c = ((String) eachFleetRecord.get('HPN_Status__c')) == 'Free' ? null : getDecimal(eachFleetRecord.get('Installment_Paid__c')),
                Type_of_Vehicle__c = (String) eachFleetRecord.get('Type_of_Vehicle__c'),
                Loan_Amount__c = getDecimal(eachFleetRecord.get('Loan_Amount__c'))
            ));
        }

        Database.SaveResult[] saveResult = Database.insert(fleetList, false);

        Integer successCount = 0;
        for (Database.SaveResult each : saveResult) {
            if (each.isSuccess()) {
                fleetInsertStatus.add('Success!');
                successCount++;
            } else {
                List<String> errorMessageList = new List<String>();
                for (Database.Error err : each.getErrors()) {
                    errorMessageList.add(err.getMessage());
                }
                fleetInsertStatus.add('Fleet creation failed due to following reasons - ' + String.join(errorMessageList, ','));
            }
        }

        // R2-2798 - START
        if (successCount > 0) {
            Loan_Application__c loanRec = [SELECT Id, Product__c FROM Loan_Application__c WHERE Id = :loanId WITH SECURITY_ENFORCED];
            String CEProductCodes= System.label.Construction_Equipment_Product_Codes;
            String CVProductCodes= System.label.Commercial_Product_Codes;
            if (CEProductCodes.contains(loanRec.Product__c) || CVProductCodes.contains(loanRec.Product__c) ){
                calculateFreeFinanceRatio(loanId);
            }
        }
        // R2-2798 - END
        return JSON.serialize(fleetInsertStatus);
    }
    
     /**
      * @description Method to get Applicant List
      * @author //Added by Ashish R2-633    
      * @param loanId
      * @return void
     **/
    @AuraEnabled
    public static List<Applicant__c>  getApplicantList(String loanAppId){
        return [SELECT id,RecordType.Name,CIF_No__c,Complete_Name__c,Customer_Name__c, Relationship_with_applicant__c,Loan__r.Product__c , isCollateralEnquiryFetched__c ,RecordType.DeveloperName
                FROM Applicant__c
                WHERE Loan__c=:loanAppId 
                AND RecordType.DeveloperName != 'Additional_Match'
                AND RecordType.DeveloperName != 'BO'
                AND RecordType.DeveloperName != 'Nominee'
                AND IsInactive__c = false WITH SECURITY_ENFORCED];
    }

     /**
      * @description Method to create the fleet records based on collateral 
      * @author Ashish ||  R2-
      * @param loanId
      * @return void
     **/
    @AuraEnabled
    public static  List<Fleet__c>  createCollateralFleetRecords(String loanAppId,String applicantId){
        CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper response = CustomCollateralEnquiryController.getCollateralEnquiryList(applicantId); //a24HE000000Df0XYAS
        List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper> collaterList = response.collateralList;
        Generic_Master__c bankDetail =[SELECT  id,name,Bank_Name__c ,Recordtype.Name
                                       FROM  Generic_Master__c 
                                       WHERE Recordtype.Name='Financial Institution Name' 
                                       AND Bank_Name__c ='Au Small Finance Bank Limited' WITH SECURITY_ENFORCED];
        
        Map<String,String> collateralAPILabelMap  = getPickListValuesMap();                                       
       /* List<Collateral__c> collateralList = [SELECT id, Linked_Account_Number__c, Collateral_ID__c,Vehicle_Number__c, Make__c,Model__c,Manufacture_Year__c,Manufacture_year_month__c ,Variant__c
                                              FROM  Collateral__c
                                              WHERE  Loan__c =:loanAppId WITH SECURITY_ENFORCED];*/
       
                                              
         Map<String,List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>> accountVSCollateralMap = new Map<String,List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>>();
         if(!collaterList.isEmpty()){
            for(CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper collateralInstance : collaterList){
                if(String.isNotBlank(collateralInstance.strAccountNumber)){
                    if(accountVSCollateralMap.containsKey(collateralInstance.strAccountNumber)){
                        List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper> collateralList1 = accountVSCollateralMap.get(collateralInstance.strAccountNumber);
                        collateralList1.add(collateralInstance);
                        accountVSCollateralMap.put(collateralInstance.strAccountNumber,collateralList1);
                    }else{
                        accountVSCollateralMap.put(collateralInstance.strAccountNumber,new List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>{collateralInstance});
                    }
                }
             }             
         }
        Set<String> accountSet =  new Set<String>();
        //Add Account Numbers of Collaterals from API 
        accountSet.addAll(accountVSCollateralMap.keySet());

         //Check existing fleet records with account number matching
         List<Fleet__c> existingFleet = [SELECT Id, Account_Number__c, Type_of_Vehicle__c,Fleet_owned_by__c, Name, Relationship_with_borrower__c , Vehicle_Number__c, Vehicle_Make_Model__c, MFG_Year__c, HPN_Status__c, Financial_Institution__c, Loan_Tenure__c, Installment_Paid__c,Loan_Amount__c
                                   FROM Fleet__c
                                   WHERE  Account_Number__c IN :accountSet
                                   AND Inactive__c = false WITH SECURITY_ENFORCED];
        Map<String,Fleet__c> accVsFleetMap = new Map<String,Fleet__c>();
        if(!existingFleet.isEmpty()){
            for(Fleet__c fleetInstance : existingFleet){
                if(String.isNotBlank(fleetInstance.Account_Number__c)){
                    accVsFleetMap.put(fleetInstance.Account_Number__c,fleetInstance);
                }
            }
        }         
       //Add existing account numbers of existing fleets 
        accountSet.addAll(accVsFleetMap.keySet());
        
        //Iterate over the account numbers and if there is fleet record update with latest values or create new fleet records
        List<Fleet__c> fleetRecords = new List<Fleet__c>();
        //if it a tractor
        Map<String,Applicant__c> appRelationMap = new Map <String,Applicant__c>();
        Map<String,String> appRecorTypeVSRelationMap = new Map <String,String>();
        for(Applicant__c applInstance : getApplicantList(loanAppId)){
                appRelationMap.put(applInstance.CIF_No__c,applInstance);
                if(String.isNotBlank( applInstance.Relationship_with_applicant__c)){
                    appRecorTypeVSRelationMap.put(applInstance.RecordType.Name, applInstance.Relationship_with_applicant__c);
                }
        }
        
        if(accountSet.size()>0){
            for(String keyInstance : accountSet){
                Fleet__c fleet = new Fleet__c();
                if(accVsFleetMap.containsKey(keyInstance) && accVsFleetMap!=null){
                    fleet = accVsFleetMap.get(keyInstance);
                }
                List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper> collateral = accountVSCollateralMap.get(keyInstance)!=null ? accountVSCollateralMap.get(keyInstance) : new List<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>();
                System.debug('collateralinLoop' +collateral);
                fleet.Loan_Application__c = loanAppId;
                fleet.Account_Number__c = keyInstance;
                if(!collateral.isEmpty()){
                    Applicant__c applicantInstnce = appRelationMap.get(collateral[0].strCustomerId);
                    String loanProduct = applicantInstnce!=null ? applicantInstnce.Loan__r.Product__c!=null ? applicantInstnce.Loan__r.Product__c : '':'';
                    fleet.Vehicle_Number__c =  String.isNotBlank(collateral[0].strRegistrationNumber) ? collateral[0].strRegistrationNumber : '';
                    fleet.Vehicle_Make_Model__c =  String.isNotBlank(collateral[0].strModel) ? collateral[0].strModel : '';
                    String mfgYear = (collateral[0].strManufactureYear!=null) ? collateral[0].strManufactureYear :'';
                    if(String.isNotBlank(mfgYear)){
                        fleet.MFG_Year__c = mfgYear.subString(0,4);
                    }
                    String collateralCode =  String.isNotBlank(collateral[0].strCollateralCode) ? collateral[0].strCollateralCode : '';
                    if(String.isNotBlank(collateralCode)){
                        fleet.Type_of_Vehicle__c =  collateralAPILabelMap.get(collateralCode.subString(0,5));
                    }
                    if(String.isNotBlank(fleet.Relationship_with_borrower__c) 
                    && fleet.Relationship_with_borrower__c == 'OTHERS' && String.isNotBlank(loanProduct)
                    && (loanProduct =='10501'  ||loanProduct =='10502'  || loanProduct =='10503') &&  applicantInstnce!=null){
                        String relation = appRecorTypeVSRelationMap.get(applicantInstnce.RecordType.Name);
                        fleet.Relationship_with_borrower__c =relation.toUpperCase();
                    }
                    if(applicantInstnce!=null){
                        fleet.Fleet_owned_by__c =  String.isNotBlank(applicantInstnce.RecordType.Name) ? applicantInstnce.RecordType.Name : ''; 
                    fleet.Name =  String.isNotBlank(applicantInstnce.Customer_Name__c) ? applicantInstnce.Customer_Name__c : ''; 
                    }

                }
                fleet.HPN_Status__c = 'Financed'; 
                fleet.Loan_Tenure__c = 0; //Added Default 
                fleet.Installment_Paid__c =0;
                if(bankDetail!=null){
                    fleet.Financial_Institution__c = bankDetail.Id;
                }
                fleetRecords.add(fleet);
            }
            System.debug('fleetRecords-->' +fleetRecords);
            if(!fleetRecords.isEmpty()){
                Database.upsert(fleetRecords, AccessLevel.USER_MODE);
            }

            
        }
        //so pending is vahan api one and Type of Vehicle and Relationship
        return fleetRecords;
    }

    public static  Map<String,String> getPickListValuesMap(){
        Map<String,String> labelApiMap = new Map<String,String>();
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Loan_Application__c.Collateral_Type__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            // pickListValuesList.add(pickListVal.getLabel());
            labelApiMap.put(pickListVal.getValue(),pickListVal.getLabel() );
         }     
         return labelApiMap;
     }
      /**
      * @description Method to check Live Bank Records are there or not 
      * @author //Added by Ashish R2-633    
      * @param loanId
      * @return void
     **/
     @AuraEnabled
     public static Boolean getBankRecords(String loanAppId){
        try {
            Set<String> vehicleCodes=new Set<String>();
            String codes = System.label.VehicleCodes;
            for(String str : codes.split(',')){
                vehicleCodes.add(str);
            }

            //CBS Loan Type
            Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
            List<Bank_Account_Records__c> bankRecrdsList = [SELECT id,Name,Account_Type__c,Product__c,Applicant__r.Loan__c,RecordTypeId,is_CBS_Running_Loan__c
                                                            FROM Bank_Account_Records__c
                                                            WHERE Account_Type__c='Loan'
                                                            AND RecordTypeId=:cbsRecordTypeId
                                                            AND Product__c IN :vehicleCodes
                                                            AND is_CBS_Running_Loan__c = true
                                                            AND Applicant__r.Loan__c = :loanAppId WITH SECURITY_ENFORCED]; 
            if(!bankRecrdsList.isEmpty() && bankRecrdsList.size()>0){
                return true;
            }else{
                return false;
            }
                                                                        
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            return false;
        }
     }

     @AuraEnabled
     public static void calculateFreeFinanceRatio(String loanAppId){
        try {
            List<Fleet__c> fleetRecords = [Select Id,Inactive__c,Type_of_Vehicle__c,Loan_Amount__c, Fleet_owned_by__c, Name, Relationship_with_borrower__c , Vehicle_Number__c, Vehicle_Make_Model__c, MFG_Year__c, HPN_Status__c, Financial_Institution__c, Loan_Tenure__c, Financial_Institution__r.Bank_Name__c, Installment_Paid__c,Loan_Application__c,Consider_Fleet__c ,Age_Filter__c
                                          FROM Fleet__c 
                                          WHERE Loan_Application__c =:loanAppId  AND Consider_Fleet__c = 'Yes' AND Age_Filter__c ='Yes'
                                          AND Inactive__c = false WITH SECURITY_ENFORCED];

            Decimal totalCount =0;
            Decimal freeCount = 0;
            Decimal freeNoHypoCount = 0; // this should be consider for status Financed and emipaid / total tenure > 75%
            Decimal financedFleets  = 0;
            Decimal deemedFleets  = 0;
            Decimal financedCount =0; 

            List<Fleet__c> updateFleetList = new List<Fleet__c>();
            Decimal emiPaidLessthan12 = 0;
            Date dat = System.today();
            Integer currentYr = dat.year();
            if(!fleetRecords.isEmpty()){
                for(Fleet__c fleetInstance : fleetRecords ){
                    Integer fleetYr = String.isNotBlank(fleetInstance.MFG_Year__c) ? Integer.valueOf(fleetInstance.MFG_Year__c) : 0;
                    Integer age = currentYr - fleetYr;

                    Fleet__c fleetNewInstance = new Fleet__c();
                    fleetNewInstance.Id = fleetInstance.Id;
                    if(String.isNotBlank(fleetInstance.HPN_Status__c)){
                        Decimal loanTenure = fleetInstance.Loan_Tenure__c !=null ? fleetInstance.Loan_Tenure__c : 0;
                        Decimal emiPaid = fleetInstance.Installment_Paid__c!=null ? fleetInstance.Installment_Paid__c :0 ;
                        Decimal vehicleAge = Decimal.valueof(System.label.Vehicle_Age);
                        if(fleetInstance.HPN_Status__c == 'Free' && age<=vehicleAge){
                            fleetNewInstance.Free_No_Hypo__c = true;
                            freeCount ++;
                        }else{
                            fleetNewInstance.Free_No_Hypo__c = false;
                        }
                        if(loanTenure!=0 && emiPaid!=0){
                            //expansion ratio
                            if(emiPaid <12){
                                emiPaidLessthan12++;
                            }

                            // Financed Seasoning
                            Decimal vehicleSeasoning  = (emiPaid/loanTenure) * 100;
                            Decimal seasoningLimit = Decimal.valueof(System.label.VehicleSeasoning);
                            
                            if(fleetInstance.HPN_Status__c == 'Financed'){
                                financedFleets++;
                                if(vehicleSeasoning >= seasoningLimit  && age<=vehicleAge ){
                                    fleetNewInstance.Deemed_Free__c = true;
                                    deemedFleets++;
                                    freeCount ++;
                                }else{
                                    fleetNewInstance.Deemed_Free__c = false;
                                }
                            }
                        }
                    }
                    totalCount++;
                    updateFleetList.add(fleetNewInstance);
                }

                if(!updateFleetList.isEmpty()){
                    Database.update(updateFleetList, AccessLevel.USER_MODE);
                }
                //Update the free financed ratio on Loan Obj
                financedCount = financedFleets - deemedFleets;
               
                Decimal expansionRatio =0;
                if(emiPaidLessthan12!=0 && totalCount!=0){
                    Decimal emiRemainingCount = totalCount - emiPaidLessthan12;
                    if( emiRemainingCount!=0){
                        expansionRatio = emiPaidLessthan12 / (emiRemainingCount);
                    }
                }
                
                Loan_Application__c loanApplication = new Loan_Application__c();
                loanApplication.Id = loanAppId;
                if(freeCount!=0 && financedCount!=0){
                    Decimal freeFinancedRatio = freeCount/financedCount;
                    loanApplication.Free_Financed_Ratio__c = freeFinancedRatio;
                }
                loanApplication.Expansion_Ratio__c = expansionRatio;
                Database.update(loanApplication, AccessLevel.USER_MODE);
                

            }
           
            
        } catch (Exception e) {
           // throw new AuraHandledException(e.getMessage());
           System.debug('exceptione-->' +e.getLineNumber());
           
        }
     }



    
    //wrapper class
    public Class RelatedFleetControllerWrapper{
        @AuraEnabled
        public List<Fleet__c> fltLst; 
        @AuraEnabled
        public List<String> mfgYear; 
        @AuraEnabled
        public Loan_Application__c loanInstance;  // Added by Ashish || R2-633
        @AuraEnabled
        public List<Applicant__c> applicantList;  // Added by Ashish || R2-633
    }
}