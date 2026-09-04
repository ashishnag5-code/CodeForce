/*****
 * Class Name: PricingSummaryPageController
 * Description: Test Class for PricingSummaryPageController
 * Test Class: PricingSummaryPageControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description / Bug
 * Dec-06-2023          -   Mohit M.            -   Change for Code coverage
 * Dec-20-2023          -   Mohit M.            -   SFAU-5622 - User IsActive Check
 */
public with sharing class PricingSummaryPageController {
    
    @AuraENabled
    public static SummaryPageWrapperController.PricingApplicantDetails getPricingApplicantDetails(String applicationId) {
        SummaryPageWrapperController.PricingApplicantDetails applicantDetails = new SummaryPageWrapperController.PricingApplicantDetails();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Application_Id__c , Branch_Master__c, Branch_Master__r.Name, Credit_FTR_FTNR__c, Ops_FTR_FTNR__c,
                                                           Branch_Master__r.Business_HUB__r.Name, Branch_Master__r.Region__r.Name, 
                                                            Branch_Master__r.State__r.Name, RecordType.Name,
                                                           (SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Type_Of_Employment__c, 
                                                            Customer_Grade__c, Residential_Status__c from Applicants__r WHERE RecordType.Name = 'Applicant')
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                          ];
            if(!applicationRecord.isEmpty()) {
                List<Bureau_Results__c > bueraueRecord = new List<Bureau_Results__c>();
                List<Address__c> addrRec = new List<Address__c>();
                if(!applicationRecord[0].Applicants__r.isEmpty()) {
                    bueraueRecord = [SELECT Id, Bureau_Score__c, Applicant__c FROM Bureau_Results__c WHERE Applicant__c  =:applicationRecord[0].Applicants__r[0].Id
                                     ORDER BY CreatedDate DESC LIMIT 1];
                    addrRec = [SELECT Id, Status__c, toLabel(Stability__c), Address_Type__c FROM Address__c WHERE Applicant__c=:applicationRecord[0].Applicants__r[0].Id AND Address_Type__c = 'Current' LIMIT 1];
                    
                }
                applicantDetails = setPricingApplicantDetails(applicationRecord[0], bueraueRecord, addrRec);
            }
            
        }catch(exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            system.debug('ex'+objException);
        }
        
        return applicantDetails;
        
    }
    
    private static SummaryPageWrapperController.PricingApplicantDetails setPricingApplicantDetails(
        Loan_Application__c applicationRecord, List<Bureau_Results__c> bueraueRecord, List<Address__c> addrRec
    ) {
        SummaryPageWrapperController.PricingApplicantDetails retWrapper = new SummaryPageWrapperController.PricingApplicantDetails();
        retWrapper.applicationNo = nullCheckAndSetData(String.valueOf(applicationRecord.Application_Id__c));
        retWrapper.branchHub = nullCheckAndSetData(String.valueOf(applicationRecord.Branch_Master__r.Name))+' / '+
            nullCheckAndSetData(String.valueOf(applicationRecord.Branch_Master__r.Business_HUB__r.Name))+' / '+
            +
            nullCheckAndSetData(String.valueOf(applicationRecord.Branch_Master__r.State__r.Name));
        retWrapper.creditFTR = nullCheckAndSetData(String.valueOf(applicationRecord.Credit_FTR_FTNR__c));
        retWrapper.opsFTR = nullCheckAndSetData(String.valueOf(applicationRecord.Ops_FTR_FTNR__c));
        if(!applicationRecord.Applicants__r.isEmpty()) {
            retWrapper.applicantId = nullCheckAndSetData(String.valueOf(applicationRecord.Applicants__r[0].Id));
            retWrapper.customerName = setApplicantName(String.valueOf(applicationRecord.Applicants__r[0].First_Name__c),String.valueOf(applicationRecord.Applicants__r[0].Middle_Name__c),String.valueOf(applicationRecord.Applicants__r[0].Last_Name__c));
            retWrapper.employmentType = nullCheckAndSetData(String.valueOf(applicationRecord.Applicants__r[0].Type_Of_Employment__c));
            retWrapper.customerGrade = nullCheckAndSetData(String.valueOf(applicationRecord.Applicants__r[0].Customer_Grade__c));
            //retWrapper.residenceState = nullCheckAndSetData(String.valueOf(applicationRecord.Applicants__r[0].Residential_Status__c));
        }
        if(!bueraueRecord.isEmpty()) {
            retWrapper.cibil = setCIBILScore(String.valueOf(bueraueRecord[0].Bureau_Score__c),applicationRecord.RecordType.Name);//nullCheckAndSetData(String.valueOf(bueraueRecord[0].Bureau_Score__c));
            retWrapper.cibilUrl = '/apex/CAMReportVFPage?id='+applicationRecord.Id+'&factor=3';
        }
        if(!addrRec.isEmpty()){
            retWrapper.residenceState = nullCheckAndSetData(String.valueOf(addrRec[0].Status__c))+' '+nullCheckAndSetData(String.valueOf(addrRec[0].Stability__c));
        }
        return retWrapper;
        
    }

    private static String setCIBILScore(String cibilScore, String recType){
        if(String.isNotBlank(cibilScore) && recType == 'Four Wheeler'){
            if(Integer.valueOf(cibilScore)>=100 && Integer.valueOf(cibilScore)<=200){
                return '-1';
            }
        }
        if(String.isBlank(cibilScore)){
            return '';
        }
        return String.valueOf(cibilScore);
        
    }
    
    private static String setApplicantName(String firstName, String middleName, String lastName) {
        return ((String.isBlank(firstName) ? '' : firstName+' ') +(String.isBlank(middleName) ? '' : middleName+' ')+(String.isBlank(lastName) ? '' : lastName+' '));
    }
    
    @TestVisible
    private static String setAddress(Address__c addressRecord) {
        String streetName = nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_1__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_2__c))+' '+nullCheckAndSetData(String.valueOf(addressRecord.Address_Line_3__c));
        String city = nullCheckAndSetData(String.valueOf(addressRecord.City__c));
        String state = nullCheckAndSetData(String.valueOf(addressRecord.State__c));
        String pincode = nullCheckAndSetData(String.valueOf(addressRecord.Pincode__c));
        return streetName+' '+city+' '+state+' '+pincode;
    }
    
    private static String nullCheckAndSetData(String dataValue) {
        return (String.isBlank(dataValue)? ' ' : dataValue);
    }
    
    @AuraEnabled
    public static SummaryPageWrapperController.PricingVehicleDetails getPricingVehicleDetails(String applicationId) {
        SummaryPageWrapperController.PricingVehicleDetails vehicleWrapper = new SummaryPageWrapperController.PricingVehicleDetails();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, toLabel(Product__c),
                                                           Vehicle_use__c, 
                                                           (SELECT Id, Model__c, Assessment_Method__c, LTV__c, Make__c , Variant__c, Manufacture_Year__c, Manufacture_year_month__c, MMV_Master__r.Name  FROM Collaterals__r)
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                           ]; 
            if(!applicationRecord.isEmpty()){
                vehicleWrapper = setVehicleWrapper(applicationRecord[0]);
            }
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            system.debug('exception Ex');
        }
        
        return vehicleWrapper;
    }
    
    private static SummaryPageWrapperController.PricingVehicleDetails setVehicleWrapper(Loan_Application__c record) {
        SummaryPageWrapperController.PricingVehicleDetails retWrapper = new SummaryPageWrapperController.PricingVehicleDetails();
        retWrapper.productType = nullCheckAndSetData(String.valueOf(record.Product__c))+' '+nullCheckAndSetData(String.valueOf(record.Vehicle_use__c));
        if(!record.Collaterals__r.isEMpty()) {
            retWrapper.make_model = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Make__c))+' '+
                nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Model__c))+' '+
                nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].MMV_Master__r.Name ));
            if(String.isNotBlank(record.Collaterals__r[0].Manufacture_year_month__c)){
                retWrapper.make_model+= '-'+record.Collaterals__r[0].Manufacture_year_month__c.substring(0,4);
            }
        }
        return retWrapper;
    }
    
    @AuraEnabled
    public static SummaryPageWrapperController.PricingLoanDetails getPricingLoanDetails(String applicationId) {
        SummaryPageWrapperController.PricingLoanDetails loanWrapper = new SummaryPageWrapperController.PricingLoanDetails();
        try {
            if(String.isBlank(applicationId)){
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id,RecordType.Name, Sourcing_channel__c, Total_Loan_Amount__c, Scheme__c, Scheme__r.Scheme_Name__c, toLabel(Product__c),
                                                           Tenure__c, ROI__c , RBP__c,
                                                           Vehicle_use__c, Customer_Type__c, Dealer_Master__c, Dealer_Master__r.Name, Pre_Approved_Flag__c, Campaign__c, 
                                                           (SELECT Id, Model__c, Assessment_Method__c, LTV__c, Make__c , Variant__c, Manufacture_Year__c, LTV_offered_On_road__c 
                                                            FROM Collaterals__r), (SELECT Id, Charges_Name__c, Total_Amount__c  FROM Charges__r )
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                           ]; 
            if(!applicationRecord.isEmpty()) {
                loanWrapper = setPricingLoanDetails(applicationRecord[0]);
                
            }
        }catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            system.debug('yash '+objException.getStackTraceString());
            
        }
        
        return loanWrapper;
    }
    
    private static String setModeOfPaymentValue(String dealerClass){
        if(String.isBlank(dealerClass) || dealerClass != 'TA DEALER'){
            return 'NON-TA';
        }
        else{
            return 'TA';
        }
    }

    
    private static SummaryPageWrapperController.PricingLoanDetails setPricingLoanDetails(Loan_Application__c record) {
        SummaryPageWrapperController.PricingLoanDetails retWrapper = new SummaryPageWrapperController.PricingLoanDetails();
        retWrapper.schemeName = nullCheckAndSetData(String.valueOf(record.Scheme__r.Scheme_Name__c));
        retWrapper.loanAmount = nullCheckAndSetData(String.valueOf(record.Total_Loan_Amount__c))+' / '+nullCheckAndSetData(String.valueOf(record.ROI__c))+'% / '+nullCheckAndSetData(String.valueOf(record.Tenure__c));
        retWrapper.rbp = nullCheckAndSetData(String.valueOf(record.RBP__c));
        system.debug('yash '+retWrapper.loanAmount+' '+retWrapper.rbp);
        if(!record.Collaterals__r.isEmpty()) {
            retWrapper.ltvOnRoad = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].LTV_offered_On_road__c));
        }
        Decimal pf = 0.00, dc = 0.00, ls = 0.00, otherCharges = 0.00;
        if(!record.Charges__r.isEmpty()) {
            for(Charge__c chg : record.Charges__r) {
                String chargeName = chg.Charges_Name__c;
                chg.Total_Amount__c = (String.isBlank(String.valueOf(chg.Total_Amount__c)))?0.00:chg.Total_Amount__c;
                SWITCH ON chargeName {
                    WHEN 'Processing Fees'{
                        pf+= chg.Total_Amount__c;
                    }
                    WHEN 'Documentation Charges'{
                        dc+= chg.Total_Amount__c;
                    }
                    WHEN 'LS Charges'{
                        ls+= chg.Total_Amount__c;
                    }
                    WHEN ELSE {
                        otherCharges+= chg.Total_Amount__c;
                    }
                }
            }
        }
        retWrapper.pf = String.valueOf(pf);
        retWrapper.dc = String.valueOf(dc);
        retWrapper.ls = String.valueOf(ls);
        retWrapper.otherCharges = String.valueOf(otherCharges);
        return retWrapper;
    }
    
    @AuraEnabled
    public static SummaryPageWrapperController.PricingSourcingDetails getPricingSourcingDetails(String applicationId) {
        SummaryPageWrapperController.PricingSourcingDetails sourceWrapper = new SummaryPageWrapperController.PricingSourcingDetails();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Application_Id__c , Branch_Master__c, Branch_Master__r.Name, Product__c,
                                                           Dealer_Master__c, Dealer_Master__r.Name, Sourcing_channel__c,OwnerId,Owner.Name,Dealer_Master__r.Dealer_Class__c,
                                                           (SELECT Id,DSE_Payout__c ,DSM_Payout__c, Dealer_Payout_amt__c,Source_Payout_amt__c,
                                                           RecordType.Name FROM Payments__r WHERE RecordType.Name='Dealer Payout')
                                                           FROM Loan_Application__c
                                                           WHERE Id= :applicationId WITH SECURITY_ENFORCED];
            
            
            if(!applicationRecord.isEmpty()) {
                String branchName = nullCheckAndSetData(String.valueOf(applicationRecord[0].Branch_Master__c));
                if(String.isNotBlank(branchName)) {
                    List<AccountTeamMember> atm  = new List<AccountTeamMember>();
                    // SFAU-5622 - Add User IsActive Check
                    atm = [SELECT Id, UserId, User.Name, User.MobilePhone, TeamMemberRole, Product__c, Is_Primary_BM__c FROM AccountTeamMember
                           WHERE TeamMemberRole = 'Branch Manager' AND AccountId = :branchName AND Is_Primary_BM__c = true AND User.isActive = true 
                           WITH SECURITY_ENFORCED
                          ];// Updated Query with new Product and Primary BM filter
                    sourceWrapper = setSourceWrapper(applicationRecord[0],atm);
                    
                }
            }
            
        }catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            system.debug('ex '+objException.getMessage());
        }
        return sourceWrapper;
    }
    
    private static SummaryPageWrapperController.PricingSourcingDetails setSourceWrapper(
        Loan_Application__c application, List<AccountTeamMember> atmRec
    ) {
        SummaryPageWrapperController.PricingSourcingDetails retWrapper = new SummaryPageWrapperController.PricingSourcingDetails();
        User ownerUserRec = [SELECT Id, MobilePhone FROM USER WHERE ID=:application.OwnerId];
        retWrapper.sourcingChannel = nullCheckAndSetData(String.valueOf(application.Sourcing_channel__c));
        retWrapper.dealerName = nullCheckAndSetData(String.valueOf(application.Dealer_Master__r.Name))+' ('+setModeOfPaymentValue(nullCheckAndSetData(String.valueOf(application.Dealer_Master__r.Dealer_Class__c)))+')';
        retWrapper.roName_Mobile = nullCheckAndSetData(String.valueOf(application.Owner.Name))+' '+nullCheckAndSetData(String.valueOf(ownerUserRec.MobilePhone));
        if(!atmRec.isempty()) {
            for(AccountTeamMember atm : atmRec){
                if(String.isNotBlank(atm.Product__c)){
                    system.debug('atm products '+atm.Product__c+' application product '+application.Product__c);
                    List<STring> atmProdList = atm.Product__c.split(';');
                    if(atmProdList.contains(application.Product__c)){
                        retWrapper.bmName_Mobile = nullCheckAndSetData(String.valueOf(atm.User.Name))+' '+nullCheckAndSetData(String.valueOf(atm.User.MobilePhone));
                    }
                }
            }
            
        }
        if(!application.Payments__r.isEmpty()){
            retWrapper.dealerSchemePayout = nullCheckAndSetData(String.valueOf(application.Payments__r[0].Dealer_Payout_amt__c));
            retWrapper.payOutOnDeal = nullCheckAndSetData(String.valueOf(application.Payments__r[0].Source_Payout_amt__c));
            if(String.valueOf(application.Payments__r[0].DSM_Payout__c)=='Yes'){
                retWrapper.dsmPayout = nullCheckAndSetData(String.valueOf(application.Payments__r[0].Dealer_Payout_amt__c));
            }
            if(String.valueOf(application.Payments__r[0].DSE_Payout__c)=='Yes'){
                retWrapper.dsePayout = nullCheckAndSetData(String.valueOf(application.Payments__r[0].Dealer_Payout_amt__c));
            }
            
        }
        return retWrapper;
    }
    
   /* @AuraEnabled
    public static SummaryPageWrapperController.PricingPerformanceDetails getPricingPerformanceDetails(String applicationId) {
        SummaryPageWrapperController.PricingPerformanceDetails performanceWrapper =
            new SummaryPageWrapperController.PricingPerformanceDetails();
        try{
            if(String.isBlank(applicationId)) {
                return null;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Application_Id__c , Branch_Master__c, Branch_Master__r.Name, Branch_Master__r.Region__r.Name,
                                                           Branch_Master__r.Business_HUB__r.Name,
                                                           Dealer_Master__c, Dealer_Master__r.Name, Sourcing_channel__c FROM Loan_Application__c
                                                           WHERE Id= :applicationId WITH SECURITY_ENFORCED];
            
            if(!applicationRecord.isEmpty()) {
                performanceWrapper = setPricingPerformanceWrapper(applicationRecord[0]);
            }
            
            
        }catch(Exception ex) {
            system.debug('ex '+ex.getMessage());
        }
        return performanceWrapper;
    } 
    
    private static SummaryPageWrapperController.PricingPerformanceDetails setPricingPerformanceWrapper(Loan_Application__c record) {
        SummaryPageWrapperController.PricingPerformanceDetails retWrapper = new SummaryPageWrapperController.PricingPerformanceDetails();
        retWrapper.branch = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.Name));
        retWrapper.hub = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.Business_HUB__r.Name));
        retWrapper.region = nullCheckAndSetData(String.valueOf(record.Branch_Master__r.Region__r.Name));
        retWrapper.performanceObjectDetails = setPerformanceWIRRData(record.Id);
        return retWrapper;
    }
    
    public static SummaryPageWrapperController.PricingPerformanceWrapper setPerformanceWIRRData(String recordId) {
        SummaryPageWrapperController.PricingPerformanceWrapper returnWrapper = new SummaryPageWrapperController.PricingPerformanceWrapper();
        try{
            Map<String,String> name_IdMap = new Map<String,String>();
            List<Loan_Application__c> applicationRecord = [SELECT Id, Application_Id__c ,OwnerId, Branch_Master__c,Branch_Master__r.Name, Branch_Master__r.Region__c,
                                                           Branch_Master__r.Business_HUB__c, toLabel(Product__c) FROM Loan_Application__c WHERE Id=:recordId AND Product__c!='' LIMIT 1];
            if(!applicationRecord.isEmpty()) {
                if(String.isNotBlank(applicationRecord[0].Branch_Master__c)) {
                    name_IdMap.put(applicationRecord[0].Branch_Master__c, 'Branch');
                }
                system.debug('map '+name_IdMap);
                
                if(!name_IdMap.isEmpty()) {
                    WIRR_FieldAPI_Product_Data__mdt metaDataRecord = [SELECT Label,WIRR_FieldAPI_Name__c FROM WIRR_FieldAPI_Product_Data__mdt WHERE 
                                                                     Label =:applicationRecord[0].Product__c];
                    system.debug('metadata record'+metaDataRecord);
                    if(metaDataRecord!=null) {
                        DateTime dt = Datetime.now();
                        String currentYear = dt.format('YYYY');
                        String currentMonth = dt.format('MMM');
                        String lastMonthYear = dt.addMonths(-1).format('YYYY');
                        String lastMonth = dt.addMonths(-1).format('MMM');
                        
                        List<WIRR__c> wirrRecords = [SELECT Id, Name, Branch__c, User__c, User__r.Name, Month__c, Year__c, X2W_COW_WIRR__c, X2W_New_WIRR__c, X2W_Used_WIRR__c,
                                                     X4W_COW_WIRR__c , X4W_New_WIRR__c , X4W_Used_WIRR__c 
                                                     FROM WIRR__c WHERE (Branch__c IN:name_IdMap.keySet() OR User__c=:applicationRecord[0].OwnerId) AND (Month__c IN (:currentMonth,:lastMonth))];
                        if(!wirrRecords.isEMpty()) {
                            for(WIRR__c record : wirrRecords) {
                                system.debug('rcordName '+record.Name);
                                if(record.Month__c == currentMonth && String.isNotBlank(record.Branch__c)) {
                                    if(name_IdMap.get(record.Branch__c)=='Branch'){
                                        returnWrapper.branchCurrentWIRR = nullCheckAndSetData(String.valueOf(record.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                                    }
                                }
                                else if(record.Month__c == lastMonth && String.isNotBlank(record.Branch__c)) {
                                    if(name_IdMap.get(record.Branch__c)=='Branch'){
                                        returnWrapper.branchLastWIRR = nullCheckAndSetData(String.valueOf(record.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                                    }
	                                }
                                else if(String.isBlank(record.Branch__c) && String.isNotBlank(record.User__c)){
                                    if(record.Month__c == currentMonth) {
                                        returnWrapper.roWIRRCurrent = record.User__r.Name+'-'+nullCheckAndSetData(String.valueOf(record.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                                    }
                                    else{
                                        returnWrapper.roWIRRLast = record.User__r.Name+'-'+nullCheckAndSetData(String.valueOf(record.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                                    }
                                }
                            }
                            system.debug('wrapper '+returnWrapper);
                        }
                    }
                }
            }
            
        }catch(Exception ex) {
            
        }
        return returnWRapper;
        
    }*/
    
    
    @AuraEnabled
    public static SummaryPageWrapperController.PSD_DDEPricingInformation getPricingPerformanceDetails(String applicationId){
        SummaryPageWrapperController.PSD_DDEPricingInformation pricingWrapper = new SummaryPageWrapperController.PSD_DDEPricingInformation();
        try{
            if(String.isBlank(applicationId)){
                return pricingWrapper;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, toLabel(Product__c), Branch_Master__c ,ROI__c ,EMI__c ,EMI_Date__c ,Emi_Frequency__c, OwnerId, First_EMI_Date__c
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                           ]; 
            pricingWrapper = setPricingDetailsWrapper(applicationRecord[0]);
            

        }catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            system.debug(objException);
        }
        return pricingWrapper;
        
    }
    
    
    private static SummaryPageWrapperController.PSD_DDEPricingInformation setPricingDetailsWrapper(Loan_Application__c record){
        SummaryPageWrapperController.PSD_DDEPricingInformation returnWrapper = new SummaryPageWrapperController.PSD_DDEPricingInformation();
        //1780,1782- start
        String metadataLabel = record.Product__c;
        if(record.Product__c == 'CV Loading (New)' || record.Product__c == 'CV Passenger (New)'){
            metadataLabel = record.Collateral_Type__c+' New';
        }
        else if(record.Product__c == 'CV Loading (Used)' || record.Product__c == 'CV Passenger (Used)'){
            metadataLabel = record.Collateral_Type__c+' Used';
        }
        //R2-2634
        // else if(record.Product__c == 'CV Loading (Cash on Wheels)' || record.Product__c == 'CV Passenger (Cash on Wheels)'){
        //     metadataLabel = record.Collateral_Type__c+' COW';
        // }     
        else if((record.Product__c.contains('CV Loading') || record.Product__c.contains('CV Passenger') ) && ((System.Label.AUSFCowScreen.toUpperCase().contains(record.Product__c.toUpperCase())) || (System.Label.AUSFCowScreenR2.toUpperCase().contains(record.Product__c.toUpperCase())))){
            metadataLabel = record.Collateral_Type__c+' COW';
        }
        //R2-2634
        WIRR_FieldAPI_Product_Data__mdt metaDataRecord = [SELECT Label,WIRR_FieldAPI_Name__c,VehicleType_Overall_Field_API_Name__c  FROM WIRR_FieldAPI_Product_Data__mdt WHERE 
                                                          Label =:metadataLabel];
        //1780,1782 - end
        returnWrapper.roi = nullCheckAndSetData(String.valueOf(record.ROI__c));
        returnWrapper.emiDate = nullCheckAndSetData(String.valueOf(record.First_EMI_Date__c));
        returnWrapper.emiFrequency = nullCheckAndSetData(String.valueOf(record.Emi_Frequency__c));
        returnWrapper.emiAmount = nullCheckAndSetData(String.valueOf(record.EMI__c));
        DateTime dt = Datetime.now();
        String currentYear = dt.format('YYYY');
        String currentMonth = dt.format('MMM');
        String lastMonthYear = dt.addMonths(-1).format('YYYY');
        String lastMonth = dt.addMonths(-1).format('MMM');
        
        if(metaDataRecord!=null){
            returnWrapper.branchLoanLabel = metaDataRecord.Label;
            //1780,1782 - start
            String vehicleType = metaDataRecord.VehicleType_Overall_Field_API_Name__c;
            //returnWrapper.branchOverallLoanLabel = metaDataRecord.VehicleType_Overall_Field_API_Name__c == 'X4W_WIRR__c'?'4WH Overall':'2WH Overall';
            if(vehicleType == 'X4W_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = '4WH Overall';
            }
            else if(vehicleType == 'X2W_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = '2WH Overall';
            }
            else if(vehicleType == 'Tractor_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'Tractor Overall';
            }
            else if(vehicleType == 'HCV_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'HCV Overall';
            }
            else if(vehicleType == 'ICV_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'ICV Overall';
            }
            else if(vehicleType == 'LCV_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'LCV Overall';
            }
            else if(vehicleType == 'SCV_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'SCV Overall';
            }
            else if(vehicleType == 'CE_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'CE Overall';
            }
            else if(vehicleType == 'Car_Taxi_WIRR__c'){
                returnWrapper.branchOverallLoanLabel = 'Car Taxi Overall';
            }
            List<WIRR__c> wirrRecords = [SELECT Id, Name, Branch__c, User__c, User__r.Name, Month__c, Year__c, X2W_COW_WIRR__c, X2W_New_WIRR__c, X2W_Used_WIRR__c,
                                         X4W_COW_WIRR__c , X4W_New_WIRR__c , X4W_Used_WIRR__c, WIRR_Overall__c, X4W_WIRR__c , X2W_WIRR__c, Tractor_New_WIRR__c ,Tractor_WIRR__c ,Tractor_COW_WIRR__c ,Tractor_Used_WIRR__c , SCV_COW_WIRR__c , SCV_New_WIRR__c , SCV_Used_WIRR__c , SCV_WIRR__c,
                                          CV_COW_WIRR__c , CV_New_WIRR__c , CV_Used_WIRR__c , CV_WIRR__c, HCV_COW_WIRR__c , HCV_New_WIRR__c , HCV_Used_WIRR__c , HCV_WIRR__c, ICV_COW_WIRR__c , ICV_New_WIRR__c , ICV_Used_WIRR__c , ICV_WIRR__c, LCV_COW_WIRR__c , LCV_New_WIRR__c , LCV_Used_WIRR__c ,
                                         LCV_WIRR__c,CE_COW_WIRR__c , CE_New_WIRR__c , CE_Used_WIRR__c , CE_WIRR__c,Car_Taxi_COW_WIRR__c , Car_Taxi_New_WIRR__c , Car_Taxi_Used_WIRR__c , Car_Taxi_WIRR__c
                                         FROM WIRR__c WHERE (Branch__c =:record.Branch_Master__c OR User__c =:record.OwnerId) AND (Month__c IN (:currentMonth,:lastMonth))];
            //1780,1782 - end
            if(!wirrRecords.isEMpty()) {
                for(WIRR__c wirr : wirrRecords) {
                    system.debug('name '+wirr.Name);
                    if(String.isNotBlank(wirr.Branch__c)){
                        if(wirr.Month__c == currentMonth){
                            returnWrapper.wirrCurrentMonth = nullCheckAndSetData(String.valueOf(wirr.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                            returnWrapper.overall4_2WCurrMonth = nullCheckAndSetData(String.valueOf(wirr.get(metaDataRecord.VehicleType_Overall_Field_API_Name__c)));
                            returnWrapper.aggregateBranchWIRRCurrMonth = nullCheckAndSetData(String.valueOf(wirr.WIRR_Overall__c));
                        }
                        else if(wirr.Month__c == lastMonth){
                            returnWrapper.wirrLastMonth = nullCheckAndSetData(String.valueOf(wirr.get(metaDataRecord.WIRR_FieldAPI_Name__c)));
                            returnWrapper.overall4_2WPrevMonth = nullCheckAndSetData(String.valueOf(wirr.get(metaDataRecord.VehicleType_Overall_Field_API_Name__c)));
                            returnWrapper.aggregateBranchWIRRPrevMonth = nullCheckAndSetData(String.valueOf(wirr.WIRR_Overall__c));
                        }
                    }
                    else if(String.isNotBlank(wirr.User__c)){
                        if(wirr.Month__c == currentMonth){
                            returnWrapper.aggregateROWIRRCurrMonth = nullCheckAndSetData(String.valueOf(wirr.WIRR_Overall__c));
                        }
                        else{
                            returnWrapper.aggregateROWIRRPrevMonth = nullCheckAndSetData(String.valueOf(wirr.WIRR_Overall__c));
                        }
                    }
                    
                    
                }
            }
        }
        
        return returnWrapper;
    }
    
    
    
}