/*******************************************************************************************
 * @Name         NotificationHandler
 * @Author       Yash Shukla
 * @Description   Controller class for Generating the PDF for CHecklist documents and sending the Notification
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Yash Shukla        04/02/2023         Initial Creation
 *                  Mohit M.           Oct-09-2023        SFAU-5163 
 * 3.0              Yash Shukla        Dec-27-2023        SFAU-5804
 *******************************************************************************************/
public with sharing class SummaryPageController {

    private static final Set<String> APPLICANT_RECTYPE = new Set<String>{'Applicant','Co-Applicant','Guarantor'};
    private static final Map<String, String> DOCUMENTNAME_VALIDATIONNAMEMAP = new Map<String, String>{
        'Voter ID Card' => 'Voter ID',
        'Aadhaar Card' => 'Aadhar',
        'Driving Licence' => 'DL',
        'Passport' => 'Passport',
        'Pan Card/Form 60'=> 'PAN'
    };

    @AuraEnabled
    public static SummaryPageWrapperController.ApplicationDetailWrapper getApplicationDetails(String applicationId) {
        SummaryPageWrapperController.ApplicationDetailWrapper applicationWrapper = new SummaryPageWrapperController.ApplicationDetailWrapper();
        try{
            if(String.isBlank(applicationId)){
                return applicationWrapper;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id,RecordType.Name, Sourcing_channel__c, Total_Loan_Amount__c, Scheme__c, Scheme__r.Name, toLabel(Product__c), Scheme__r.Scheme_Name__c,
                                                           Vehicle_use__c, Customer_Type__c, Dealer_Master__c, Dealer_Master__r.Name, Pre_Approved_Flag__c, Campaign__c, Loan_Amount__c,
                                                           Tenure__c , ROI__c, Credit_FTR_FTNR__c, Ops_FTR_FTNR__c, Application_Id__c, CreatedDate, Dealer_Master__r.Dealer_Class__c, Dealer_Master__r.Dealer_Type__c, Original_Vehicle_Usage__c, //  SFAU-5163
                                                           (SELECT Id, Model__c, Assessment_Method__c, LTV__c, Make__c, Variant__c, MMV_Master__r.Name, Manufacture_Year__c, Approved_LTV__c, LTV_offered_On_road__c FROM Collaterals__r WHERE Is_Deleted__c = false AND (RecordType.Name = 'New' OR RecordType.Name = 'Used/Cash on Wheels'))// Record Type Check Added
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                           ];
            applicationWrapper = setApplicationDetailsWrapper(applicationRecord[0]);


        }catch(Exception ex) {
            system.debug(ex);
        }
        return applicationWrapper;

    }

    private static SummaryPageWrapperController.ApplicationDetailWrapper setApplicationDetailsWrapper(Loan_Application__c record) {
        SummaryPageWrapperController.ApplicationDetailWrapper retWrapper = new SummaryPageWrapperController.ApplicationDetailWrapper();
        retWrapper.applicationId= nullCheckAndSetData(String.valueOf(record.Application_Id__c));
        retWrapper.applicationDate= nullCheckAndSetData(String.valueOf(record.CreatedDate));
        retWrapper.campaign = nullCheckAndSetData(String.valueOf(record.Campaign__c));
        retWrapper.customerType = nullCheckAndSetData(String.valueOf(record.Customer_Type__c));
        retWrapper.sourcingChannel = nullCheckAndSetData(String.valueOf(record.Sourcing_channel__c));
        retWrapper.loanAmount = nullCheckAndSetData(String.valueOf(record.Total_Loan_Amount__c));
        retWrapper.scheme = nullCheckAndSetData(String.valueOf(record.Scheme__r.Scheme_Name__c));
        //String ta_ntaData = ' ('+setModeOfPaymentValue(nullCheckAndSetData(String.valueOf(record.Dealer_Master__r.Dealer_Class__c)))+')';
        String ta_ntaData = ' ('+nullCheckAndSetData(String.valueOf(record.Dealer_Master__r.Dealer_Type__c))+')';
        retWrapper.dealerName = nullCheckAndSetData(String.valueOf(record.Dealer_Master__r.Name))+ ta_ntaData;
        // SFAU-5163
        //retWrapper.vehicleType = nullCheckAndSetData(String.valueOf(record.Vehicle_use__c));
        retWrapper.vehicleType = Label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && nullCheckAndSetData(String.valueOf(record.Original_Vehicle_Usage__c)) != '' ? nullCheckAndSetData(String.valueOf(record.Original_Vehicle_Usage__c)) : nullCheckAndSetData(String.valueOf(record.Vehicle_use__c));
        retWrapper.loanType = nullCheckAndSetData(String.valueOf(record.Product__c));
        retWrapper.opsFTR = nullCheckAndSetData(String.valueOf(record.Ops_FTR_FTNR__c));
        retWrapper.creditFTR = nullCheckAndSetData(String.valueOf(record.Credit_FTR_FTNR__c));

        retWrapper.preapproved = record.Pre_Approved_Flag__c;
        if(record.Collaterals__r.size()>0) {
            retWrapper.model = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Make__c))+' '+nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Model__c))
                +' '+nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].MMV_Master__r.Name));
            retWrapper.methodOfAssessment = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Assessment_Method__c));
            retWrapper.manufacturingYear = nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].Manufacture_Year__c ));
            retWrapper.loanAmount+=' / '+nullCheckAndSetData(String.valueOf(record.Collaterals__r[0].LTV_offered_On_road__c))+'%'; // updated for R2-2626
        }
        retWrapper.loanAmount+=' / '+nullCheckAndSetData(String.valueOf(record.Tenure__c))+' Months'+' @ '+nullCheckAndSetData(String.valueOf(record.ROI__c))+'%';
        return retWrapper;

    }

    @TestVisible
    private static String setModeOfPaymentValue(String dealerClass){
        if(String.isBlank(dealerClass) || dealerClass != 'TA DEALER'){
            return 'NON-TA';
        }
        else{
            return 'TA';
        }
    }


    @AuraEnabled
    public static List<SummaryPageWrapperController.ApplicantDetailWrapper> getApplicantDetails(String applicationId){
        List<SummaryPageWrapperController.ApplicantDetailWrapper> detailsWrapper =
            new List<SummaryPageWrapperController.ApplicantDetailWrapper>();
        try {
            if(String.isBlank(applicationId))
            {
                return null;
            }
            Set<Id> setRecordTypeId = new Set<Id>();
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.APPLICANT));
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.COAPPLICANT));
            setRecordTypeId.add(Utility.getRecordTypeId(Schema.getGlobalDescribe().get('Applicant__c'),GlobalConstants.GUARANTOR));
            List<Applicant__c> applicants = [SELECT Id, First_Name__c, Middle_Name__c, Last_Name__c, Mobile_Number__c, RecordType.Name, CFR_Status__c, AML_Status__c,Father_Name__c,
                                             Constitution_Type__c,Loan__r.BSR_PSL_Status__c,Existing_Customer__c,Loan__r.BRE_Decision__c,toLabel(Loan__r.Product__c),
                                             KYC_Status__c,KYC_Type__c,Pan_Form60__c,PAN_verification_Status__c , Loan__r.RecordType.Name,
                                             Negative_Check_Status__c, Loan__r.Application_FI_Status__c, Loan__r.Valuation_Completion_Date__c , CIF_No__c,
                                             (SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, State__c, City__c,
                                              Pincode__c, Applicant__c, Address_Type__c FROM Addresses__r WHERE Address_Type__c = 'Permanent' AND Source_Type__c != 'Cibil'), // Added additional checks, Showing wrong address on Summary Page.
                                             (SELECT Id, Bureau_Score__c FROM Bureau_Results__r Order by CreatedDate desc LIMIT 1),
                                             (SELECT Id,Applicant__c,Document_Verification_Status__c,Document_Master__c ,Document_Number__c ,Document_Master__r.Document_Name__c
                                             FROM Document_Checklists__r WHERE Document_Master__r.Document_Name__c IN:DOCUMENTNAME_VALIDATIONNAMEMAP.keySet() AND Document_Number__c !='')
                                             FROM Applicant__c WHERE Loan__c = :applicationId
                                             AND RecordType.Name IN:APPLICANT_RECTYPE AND IsInactive__c = false
                                             WITH SECURITY_ENFORCED];
            String strQuery = '';
            strQuery = 'SELECT Id, RecordType.Name, Customer_Name__c, Loan__r.Name, First_Name__c, Middle_Name__c, Last_Name__c,';
            strQuery = strQuery + '(SELECT ';
            strQuery = strQuery + 'Id,FI_Officer_Name_EMP_code_Agency_Name__c,Waive_Off_Reason__c,FI_Office_Name_Code_Agency_Name_Formula__c ,Applicant__r.First_Name__c,Applicant__r.Middle_Name__c,Applicant__r.Last_Name__c, Type_of_address__c,Applicant__c,Applicant__r.Customer_Name__c,Applicant__r.RecordType.Name,Address_lookup__c,FI_Status__c, Stage__c ';
            strQuery = strQuery + 'FROM Field_Investigations__r where Re_Trigger__c = false) ';
            strQuery = strQuery + 'FROM Applicant__c ';
            strQuery = strQuery + 'WHERE RecordTypeId in: setRecordTypeId AND Loan__c = \'' + applicationId + '\' AND Applicant__r.IsInactive__c = false';
            List<Applicant__c> applicantsWithFI = Database.query(strQuery);
            Map<String,FiSummaryViewWrapper> fiSummaryMap = new  Map<String,FiSummaryViewWrapper>();
            if(!applicantsWithFI.isEmpty()){
                fiSummaryMap = FieldInvestigationUtility.createFISummary(applicantsWithFI);
            }
            List<Valuation__c> valuationRecord = new List<Valuation__c>();
            valuationRecord = [SELECT Id,Valuer_Name_Code__c,Collateral__r.Loan__c FROM Valuation__c WHERE Collateral__r.Loan__c=:applicationId LIMIT 1];
            if(!applicants.isEmpty()) {
                for(Applicant__c rec : applicants) {
                    detailsWrapper.add(setApplicantWrapperData(rec,fiSummaryMap.get(rec.Id)));
                }
            }

        } catch (Exception e) {
            system.debug('exception ex'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return detailsWrapper;
    }

    private static SummaryPageWrapperController.ApplicantDetailWrapper setApplicantWrapperData(Applicant__c record, FiSummaryViewWrapper wrapData) {
        SummaryPageWrapperController.ApplicantDetailWrapper retWrapper = new SummaryPageWrapperController.ApplicantDetailWrapper();
        retWrapper.applicantId = record.Id;
        retWrapper.fatherName = nullCheckAndSetData(String.valueOf(record.Father_Name__c));
        retWrapper.psl = nullCheckAndSetData(String.valueOf(record.Loan__r.BSR_PSL_Status__c));
        retWrapper.customerEntity = nullCheckAndSetData(String.valueOf(record.Constitution_Type__c));
        retWrapper.cif = nullCheckAndSetData(String.valueOf(record.CIF_No__c));
        retWrapper.name = setApplicantName(String.valueOf(record.First_Name__c), String.valueOf(record.Middle_Name__c), String.valueOf(record.Last_Name__c));
        retWrapper.mobileNumber = nullCheckAndSetData(String.valueOf(record.Mobile_Number__c));
        retWrapper.type = nullCheckAndSetData(String.valueOf(record.RecordType.Name));
        retWrapper.aml = nullCheckAndSetData(String.valueOf(record.AML_Status__c));
        retWrapper.negativeCheck = nullCheckAndSetData(String.valueOf(record.Negative_Check_Status__c));
        retWrapper.disableFetchButton = String.isBlank(record.CIF_No__c); // SFAU-5341                                                
        retWrapper.cfr = nullCheckAndSetData(String.valueOf(record.CFR_Status__c));
        retWrapper.fi = wrapData.finalStatus;//nullCheckAndSetData(String.valueOf(record.Loan__r.Application_FI_Status__c));
        retWrapper.fiLink = wrapData.fiReportLink;
        retWrapper.fiFieldName = String.valueOf(record.Loan__r.RecordType.Name) == 'Two Wheeler'? 'CPV' : 'FI';
        retWrapper.caseCategory = nullCheckAndSetData(String.valueOf(record.Loan__r.BRE_Decision__c));
        retWrapper.displayValuationStatus = !((record.Loan__r.Product__c=='Auto Loan (New)'||record.Loan__r.Product__c=='Two Wheeler (New)'));
        if(String.isNotBlank(String.valueOf(record.Loan__r.Valuation_Completion_Date__c))){
            retWrapper.valuationStatus =(String.valueOf(record.Loan__r.Valuation_Completion_Date__c)=='')?'':'Completed on '+String.valueOf(record.Loan__r.Valuation_Completion_Date__c);
        }

        if(!record.Addresses__r.isEmpty()){
            retWrapper.address = setAddress(record.Addresses__r[0]);
        }
        if(!record.Bureau_Results__r.isEmpty()){
            retWrapper.cibil = setCIBILScore(String.valueOf(record.Bureau_Results__r[0].Bureau_Score__c),record.Loan__r.RecordType.Name);//nullCheckAndSetData(String.valueOf(record.Bureau_Results__r[0].Bureau_Score__c));
            retWrapper.cibilUrl ='/apex/CIBIL_Summary?id='+record.Id;//record.Bureau_Results__r[0].Id;

        }
        /*
        String kycVerificationText = 'KYC - '+nullCheckAndSetData(String.valueOf(record.KYC_Status__c));
        kycVerificationText += (nullCheckAndSetData(String.valueOf(record.KYC_Status__c))=='Complete')?' '+nullCheckAndSetData(String.valueOf(record.KYC_Type__c)):'';
        kycVerificationText += (nullCheckAndSetData(String.valueOf(record.Pan_Form60__c))=='Pan Card')?(', PAN CARD - '+nullCheckAndSetData(String.valueOf(record.PAN_verification_Status__c))):'';
        retWrapper.allValidation = kycVerificationText;*/
        if(!record.Document_Checklists__r.isEmpty()){
            for(Document_Checklist__c  checklist : record.Document_Checklists__r){
                if(DOCUMENTNAME_VALIDATIONNAMEMAP.containsKey(checklist.Document_Master__r.Document_Name__c)){
                    String status = (String.isBlank(String.valueOf(checklist.Document_Verification_Status__c)))?'Not-Verified':String.valueOf(checklist.Document_Verification_Status__c);
                    retWrapper.allValidation +=(String.isBlank(retWrapper.allValidation))?DOCUMENTNAME_VALIDATIONNAMEMAP.get(checklist.Document_Master__r.Document_Name__c)+' - '+status:
                    ', '+DOCUMENTNAME_VALIDATIONNAMEMAP.get(checklist.Document_Master__r.Document_Name__c)+' - '+status;
                }
            }
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

    @AuraEnabled
    public static SummaryPageWrapperController.PSD_DDEPricingInformation getPricingDetails(String applicationId){
        SummaryPageWrapperController.PSD_DDEPricingInformation pricingWrapper = new SummaryPageWrapperController.PSD_DDEPricingInformation();
        try{
            if(String.isBlank(applicationId)){
                return pricingWrapper;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, toLabel(Product__c), Branch_Master__c ,ROI__c ,EMI__c ,EMI_Date__c , toLabel(Collateral_Type__c) ,Emi_Frequency__c, OwnerId, RBP__c, First_EMI_Date__c
                                                           FROM Loan_Application__c WHERE Id = :applicationId WITH SECURITY_ENFORCED LIMIT 1
                                                           ];
            pricingWrapper = setPricingDetailsWrapper(applicationRecord[0]);


        }catch(Exception ex) {
            system.debug(ex);
        }
        return pricingWrapper;

    }

    private static String setDecimalPlaces(String value, Integer decimalPlaces){
        if(String.isNotBlank(value)){
            return String.valueOf(Decimal.valueOf(value).setScale(decimalPlaces));
        }
        else{
            return '';
        }


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
        returnWrapper.roi = setDecimalPlaces(String.valueOf(record.ROI__c),2);
        returnWrapper.emiDate = nullCheckAndSetData(String.valueOf(record.First_EMI_Date__c));//setDecimalPlaces(String.valueOf(record.EMI_Date__c),0);
        returnWrapper.emiFrequency = nullCheckAndSetData(String.valueOf(record.Emi_Frequency__c));
        returnWrapper.emiAmount = setDecimalPlaces(String.valueOf(record.EMI__c),0);
        returnwrapper.rbp = setDecimalPlaces(String.valueOf(record.RBP__c),2);
        returnwrapper.collateralType = nullCheckAndSetData(String.valueOf(record.Collateral_Type__c)); //1780,1782
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

    @AuraEnabled
    public static SummaryPageWrapperController.ApprovalDetailWrapper getApprovalDetails(String applicationId){
        SummaryPageWrapperController.ApprovalDetailWrapper detailsWrapper =
            new SummaryPageWrapperController.ApprovalDetailWrapper();
        try {
            if(String.isBlank(applicationId))
            {
                return null;
            }
            List<Loan_Application_Approval__c > approvalRecords = [
                SELECT
                Id, Approver__c, Approver__r.Name, Approver_Level__c, Deviation_Level__c, Approval_Type__c, Loan_Type__c, Type__c, Loan_Application__r.BRE_Approval_Level__c
                FROM Loan_Application_Approval__c
                WHERE Loan_Application__c =:applicationId AND Approver__c != null
                AND Approval_Type__c IN ('Credit','Pricing') AND Archived__c = FALSE
            ];

            if(!approvalRecords.isEmpty() && approvalRecords[0].Loan_Type__c == GlobalConstants.TWOWHEELER){
                detailsWrapper.isTwoWheeler = true;
                detailsWrapper.twoWheelerLevel = nullCheckAndSetData(String.valueOf(approvalRecords[0].Loan_Application__r.BRE_Approval_Level__c));
                SummaryPageWrapperController.ApprovalInnerWrapper retWrapper = new SummaryPageWrapperController.ApprovalInnerWrapper();
                retWrapper.approverId='1';
                retWrapper.approverName = '';
                retWrapper.approverLevel = detailsWrapper.twoWheelerLevel;
                detailsWrapper.creditApprover.add(retWrapper);
                for(Loan_Application_Approval__c approval : approvalRecords){
                    if(approval.Type__c == 'Highest' && approval.Approval_Type__c == 'Pricing'){
                        detailsWrapper.pricingApprover.add(
                            setApprovalWrapper(approval)
                        );
                    }
                }
                return detailsWrapper;
                /*map<String, Loan_Application_Approval__c[]> approverTypeVsApprovals = Utility.getApproverTypeToApproval(approvalRecords);
                String creditKey = 'Credit', pricingKey = 'Pricing';
                system.debug('yash '+' '+approverTypeVsApprovals.get(creditKey)+' '+approverTypeVsApprovals.get(creditKey).size());
                if(approverTypeVsApprovals.containsKey(creditKey) && approverTypeVsApprovals.get(creditKey).size()>=1){
                    detailsWrapper.creditApprover.add(

                        setApprovalWrapper(approverTypeVsApprovals.get(creditKey)[0])
                    );
                }
                if(approverTypeVsApprovals.containsKey(pricingKey) && approverTypeVsApprovals.get(pricingKey).size() >=1){
                    detailsWrapper.pricingApprover.add(
                        setApprovalWrapper(approverTypeVsApprovals.get(pricingKey)[0])
                    );
                }
                system.debug('map data '+detailsWrapper);*/
                //return detailsWrapper;
            }
            map<String, Loan_Application_Approval__c[]> finalApprovalsByType = getApplicationFinalApproval(approvalRecords);
            System.debug(' == finalApprovalsByType ==> ' + JSON.serializePretty(finalApprovalsByType));

            if(!approvalRecords.isEmpty()) {
                for(String type : finalApprovalsByType.keySet()) {
                        for(Loan_Application_Approval__c rec: finalApprovalsByType.get(type)){
                        if(type == 'Credit') {
                            detailsWrapper.creditApprover.add(setApprovalWrapper(rec));
                        } else if(type == 'Pricing') {
                            detailsWrapper.pricingApprover.add(setApprovalWrapper(rec));
                        }
                    }
                }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return detailsWrapper;
    }


    private static SummaryPageWrapperController.ApprovalInnerWrapper setApprovalWrapper(Loan_Application_Approval__c record) {
        SummaryPageWrapperController.ApprovalInnerWrapper retWrapper = new SummaryPageWrapperController.ApprovalInnerWrapper();
        retWrapper.approverId = record.Approver__c;
        retWrapper.approverName = record.Approver__r.Name;
        retWrapper.approverLevel = record.Approver_Level__c+' '+nullCheckAndSetData(String.valueOf(record.Deviation_Level__c));
        return retWrapper;
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
        return (String.isBlank(dataValue)? '' : dataValue);
    }

    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen, String strStage, String strProfile) {
        List<Stage_Profile_Data_Configuration__mdt> lstStageProfileData = [Select Id,Fields__c,Loan_Stage__c,Object__c,
                                                                           Profile__c,Screen__c from Stage_Profile_Data_Configuration__mdt where Screen__c=:strScreen
                                                                           AND Loan_Stage__c =:strStage AND Profile__c =:strProfile];
        List<String> strFields = new List<String>();
        if(!lstStageProfileData.isEmpty()){
            strFields.addAll(lstStageProfileData[0].Fields__c.split(','));
        }
        return strFields;
    }

    public static map<String, Loan_Application_Approval__c[]> getApplicationFinalApproval(Loan_Application_Approval__c[] approvalRecords){
        map<String, Loan_Application_Approval__c[]> approverTypeVsApprovals = Utility.getApproverTypeToApproval( approvalRecords );
        return new map<String, Loan_Application_Approval__c[]>{
            GlobalConstants.STAGE_CREDIT => Utility.getFinalApproval( new String[]{ 'Highest', 'Middle', 'Base' }, GlobalConstants.STAGE_CREDIT, approverTypeVsApprovals ),
            GlobalConstants.STAGE_PRICING => Utility.getFinalApproval( new String[]{ 'Highest', 'Middle', 'Base' }, GlobalConstants.STAGE_PRICING, approverTypeVsApprovals )
        };
    }


}