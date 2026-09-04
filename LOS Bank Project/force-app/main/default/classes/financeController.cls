/*******************************************************************************************
* @Name         financeController
* @Author       Ashish Nag K
* @Description   Controller Class for Income Details Screen
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Ashish Nag K         16/11/2022         Initial Creation
*                  Mohit M.             Oct-7              Decimal differenceInMonths = -(accInstance.Month_Difference__c != NULL ? accInstance.Month_Difference__c : 0);
*******************************************************************************************/
public without sharing class financeController {
    public static final List<String> REC_TYPE_ORDER = new List<String>{'Primary_Applicant', 'Co_Applicant', 'Guarantor', 'BO'};

    public static final String DL_DOCUMENT_NAME = 'Driving Licence';
    public static final Set<String> CUSTOMER_GRADE_FOR_DL_CHECK = new Set<String>{'FTU', 'FTB'};

    
    /*
    @description :  Get Applicants based on Applicant Id or Loan Application Id
    @param :  Id 
    @return :  List<Applicant__c>
    */
    @AuraEnabled
    public static  List<Applicant__c> getApplicants(Id applicantId){
        List<Applicant__c> applicantList = new List<Applicant__c>();
        List<ApplicantListWrapper> applicantWrappers = new List<ApplicantListWrapper>();
        try {
            for(Applicant__c each : [SELECT Id,Existing_Customer__c,Spouse_Name__c ,Bureau_Score__c,Gender__c,Marital_Status__c,First_Name__c,Middle_Name__c,Last_Name__c,Name,Loan__c,Loan_Stage__c,AU_Employee__c,Name_of_Employee_AU__c,Customer_Type__c,Loan__r.EMI__c,Total_Monthly_Income__c,Current_Obligation__c,Free_Monthly_Cashflow__c,Total_Loan_Amount__c,FOIR__c,Loan__r.Product__c,Loan__r.Stage__c,RecordType.DeveloperName,RecordType.Name,IsInactive__c,Customer_Name__c,Loan__r.RecordType.Name,Politically_Exposed_Person__c,High_risk_Profile__c , Loan__r.RecordType.DeveloperName,Relationship_with_applicant__c, AU_Employment_status__c,AU_Employee_ID__c,Loan__r.Total_Verified_Income__c,Loan__r.LAN__c,Financial_Details_Fetched_from_BSA__c,Re_Visit_Screens__c, Driving_License_Issue_Date__c //R2-788
                             FROM Applicant__c
                             WHERE (Loan__c=:applicantId OR Id=:applicantId)
                             AND IsInactive__c=false
                             AND  RecordType.DeveloperName !='Additional_Match'  AND RecordType.DeveloperName != 'Nominee' WITH SECURITY_ENFORCED]) {
                applicantWrappers.add(new ApplicantListWrapper(each));
            }
        //AND RecordType.DeveloperName !='BO'
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        applicantWrappers.sort();
        for (ApplicantListWrapper each : applicantWrappers) {
            applicantList.add(each.applicantRecord);
        }
        return applicantList;
    }

    @AuraEnabled
    public static string getRecordTypeOfApplication(String loanId){
        try {
            return [SELECT RecordType.DeveloperName FROM Loan_Application__c WHERE Id=:loanId][0].RecordType.DeveloperName;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    


    
    /**
    * @description Check for valid product codes for DL toast in case new CE 
    * @author Ajitesh | 10-16-2023 
    * @param applicantId 
    * @return Boolean 
    **/
   @AuraEnabled 
   public static Id checkIfDLNeedsTobeFilledForNewCE(Id applicantId){
        if( applicantId == null ){
            return null;
        }
       try{
           
           Applicant_Financials_Details__c applicantFinanceDetails = [SELECT Customer_Grade__c  from Applicant_Financials_Details__c WHERE Applicant__c = :applicantId LIMIT 1];
           Document_Checklist__c dlDoc = [SELECT Document_Number__c, Id FROM Document_Checklist__c WHERE Applicant__c = :applicantId AND Document__c = :DL_DOCUMENT_NAME];
           
           if(CUSTOMER_GRADE_FOR_DL_CHECK.contains(applicantFinanceDetails.Customer_Grade__c) && dlDoc.Document_Number__c == null){
               return dlDoc.Id;
           }
           return null;
       }
       catch(QueryException e){// If any of the above singleton query fails other system are working unexpectedly
           System.debug('Something went wrong ' + e.getMessage());
           return null;
           //throw new AuraHandledException('Applicant Financial detail or Document checklist not found ' + e.getMessage());
       }
       catch(Exception e){
           throw new AuraHandledException('Something went wrong ' + e.getMessage());
       }
   }
   
    
    /*
@description :  Get Bureau_Results__c Records based on Applicant Id 
@param :  Id 
@return :  List<Bureau_Results__c>
*/
    
    @AuraEnabled
    public static Decimal getBureauResults(Id applicantId){
        List<Bureau_Results__c> bureauList = new List<Bureau_Results__c>();
        Decimal score=0;
        try {
            bureauList = [SELECT Id,Applicant__c,Bureau_Score__c,Bureau_Score_Date__c
                          FROM Bureau_Results__c
                          WHERE Applicant__c =:applicantId 
                           WITH SECURITY_ENFORCED
                          ORDER BY Bureau_Score_Date__c desc 
                          LIMIT 1 ];
            
            score = (bureauList[0].Bureau_Score__c!=null)? bureauList[0].Bureau_Score__c :0;
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return score;
    }
    
    
    /*
@description :  Get Address Records based on Applicant Id 
@param :  Id 
@return :  addressWrapper
*/
    @AuraEnabled
    public static addressWrapper getRelatedAddress(Id applicantId){
        List<Address__c> addressList = new List<Address__c>();
        addressWrapper wrapperInstance = new addressWrapper();
        try {
            addressList =[SELECT id,Pincode__c,Applicant__c,Address_Type__c,Stability__c
                          FROM Address__c
                          WHERE Applicant__c =:applicantId
                           WITH SECURITY_ENFORCED];
            Set<String> permanentAddressPincodeSet = new Set<String>();
            Set<String> currentAddressPincodeSet = new Set<String>();
            String stability;
            if(!addressList.isEmpty()){
                for(Address__c address : addressList){
                    if( address.Address_Type__c!=null && address.Pincode__c!=null){
                        if(address.Address_Type__c == 'Permanent'){
                            permanentAddressPincodeSet.add(address.Pincode__c);
                        }
                        if(address.Address_Type__c == 'Office'){
                            currentAddressPincodeSet.add(address.Pincode__c);
                            if(address.Stability__c!=null){
                                stability = address.Stability__c;
                            }
                        }
                    }
                }
            }
            Boolean areEqual = permanentAddressPincodeSet.equals(currentAddressPincodeSet);
            wrapperInstance.isAddressEqual = areEqual;
            wrapperInstance.jobStability = stability;
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return wrapperInstance;
    }
    
    
    
    /*
@description :  Get Bank Records based on Applicant Id 
@param :  Id 
@return :  bankRecordsWrapper
*/
    @AuraEnabled
    public static bankRecordsWrapper  getBankRecords(Id applicantId, String accountType,Integer minRelationship){
        List<Bank_Account_Records__c> accountList = new List<Bank_Account_Records__c>();
        bankRecordsWrapper wrapperInstance = new bankRecordsWrapper();
        try {
            Decimal applicantLoanEmi = getLoanEmi(applicantId);
            accountList = [SELECT Id,Account_Type__c,Payment_History_End_Date__c,Analysis_Data__c,RecordType.DeveloperName,Applicant__c,Loan_Amount__c,Account_Opening_Date__c,Month_Difference__c,EMI_Amount__c,Highest_6_Month_DPD__c,Track_Record__c,Average_Balance_Last_6_Month__c
                           FROM Bank_Account_Records__c
                           WHERE Applicant__c=:applicantId 
                           WITH SECURITY_ENFORCED
                           ORDER BY CreatedDate desc ];
            Decimal totalCBSLoanAmount=0;
            Decimal totalCIBILAmount =0;
            Decimal latestCIBILAmount =0;
            Decimal emiAmount =0;
            Decimal totalCbsEmiAmount =0;
            Decimal casaSixMonthBalance = 0;
            Boolean isCASARelationship = false;
            Set<Boolean> isCBSChecklist = new Set<Boolean>();
            Set<Boolean> isCASACheckList = new Set<Boolean>();
            Set<Boolean> isETRCheckList = new Set<Boolean>();
            Set<Boolean> isDPDChecklist = new Set<Boolean>();
            List<Bank_Account_Records__c> cartAccount = new List<Bank_Account_Records__c>();
            

            Decimal cbsRelationship=0;//12
            Decimal casaEmiMultiplier=0;//2
            Decimal casaRelationship=0;//6
            Decimal dpdMinMonth =0;//

            List<Premium_Customer_Check__mdt> premiumList = getPremiumMetadata();
            if(!premiumList.isEmpty()){
                for(Premium_Customer_Check__mdt checklist : premiumList){
                        if (checklist.Type__c == 'Exisiting Cust Asset') {
                            if (checklist.Name__c == 'Min Relationship') {
                                cbsRelationship = Decimal.valueof(checklist.Value__c);
                            }
                        }
                        if (checklist.Type__c == 'Exisitng Cust Libilities') {
                            if (checklist.Name__c == 'EMI Multiplier') {
                                casaEmiMultiplier =  Decimal.valueof(checklist.Value__c);
                            }
                            if (checklist.Name__c == 'Min Relationship') {
                                casaRelationship =   Decimal.valueof(checklist.Value__c);
                            }  
                        }
                        if (checklist.Type__c == 'CIBIL') {
                            if (checklist.Name__c == 'DPD Min Month') {
                                dpdMinMonth =   Decimal.valueof(checklist.Value__c);
                            }
                        }
                }
            }
            


            if(!accountList.isEmpty()){
                Decimal counter=0;
                for(Bank_Account_Records__c accInstance : accountList){
                    if(accInstance.Account_Type__c!=null){
                        Decimal differenceInMonths = -(accInstance.Month_Difference__c != NULL ? accInstance.Month_Difference__c : 0);
                        
                        // CBS Account
                        if(accInstance.RecordType.DeveloperName =='CBS' && accInstance.Account_Type__c ==accountType){
                          
                            if(differenceInMonths>=cbsRelationship && accInstance.Loan_Amount__c!=null ){
                                totalCBSLoanAmount = totalCBSLoanAmount + accInstance.Loan_Amount__c;
                            }
                            //sum of emi amount for cbs loan and sum is used for calculation of monthly obligation
                            if(accInstance.EMI_Amount__c!=null){
                                totalCbsEmiAmount =  totalCbsEmiAmount +accInstance.EMI_Amount__c;
                            }
                            
                            if(differenceInMonths>=cbsRelationship ){
                                isCBSChecklist.add(true);
                            }else{
                                isCBSChecklist.add(false);
                            }
                        }

                        // CBS CASA Account
                        if(accInstance.RecordType.DeveloperName =='CBS' && accInstance.Account_Type__c =='CASA'){
                            Decimal emiVal = (casaEmiMultiplier * applicantLoanEmi);
                           if( (differenceInMonths>=casaRelationship)  && (accInstance.Average_Balance_Last_6_Month__c!=null) && (accInstance.Average_Balance_Last_6_Month__c>=emiVal)){
                            isCASACheckList.add(true);
                           }else{
                            isCASACheckList.add(false);
                           }
                           
                        }
                        //CIBIL Account
                        if(accInstance.RecordType.DeveloperName =='CIBIL' && accInstance.Account_Type__c ==accountType){
                            Boolean etrVal = (accInstance.Track_Record__c!=null) ? ((accInstance.Track_Record__c =='ETR') ? true : false) : false;
                            isETRCheckList.add(etrVal);
                            if( accInstance.Loan_Amount__c!=null){
                                totalCIBILAmount = totalCIBILAmount + accInstance.Loan_Amount__c;
                                if( accInstance.Loan_Amount__c > latestCIBILAmount ) {
                                    latestCIBILAmount = accInstance.Loan_Amount__c;
                                   
                                }
                            }
                            Date paymentDate;
                            Date todayDate;
                            Integer monthsBetween=0;
                            Decimal noOfYears =0;
                            if(accInstance.Payment_History_End_Date__c!=null){
                             paymentDate = accInstance.Payment_History_End_Date__c;
                             todayDate = date.today();
                           
                             monthsBetween = todayDate.monthsBetween(paymentDate); 
                             noOfYears = todayDate.monthsBetween(paymentDate) / 12;

                            }

                            if( (accInstance.Highest_6_Month_DPD__c!=null) && (accInstance.Highest_6_Month_DPD__c == '0') && ( monthsBetween > dpdMinMonth || noOfYears>=1) ){
                                isDPDChecklist.add(true);
                            }else{
                                isDPDChecklist.add(false);
                            }
                            
                            
                            // emiAmount = accInstance.EMI_Amount__c;
                        }
                    }else{
                        // CART Account
                        if(accInstance.RecordType.DeveloperName =='Cart'){
                            cartAccount.add(accInstance);
                        }
                    }
                    counter++;
                }
            }
            
            Decimal totalEMIAmount = 0;
            Decimal noOfEmi = 0;
            Decimal salaryAmount =0;
            Decimal sixmonthBalance =0;
            if(!cartAccount.isEmpty()){
                if(cartAccount[0].Average_Balance_Last_6_Month__c!=0){
                    sixmonthBalance = cartAccount[0].Average_Balance_Last_6_Month__c;
                }
                
                /*List<CART_FileUploadHandler.AnalysisData> analysisList = 
                    (List<CART_FileUploadHandler.AnalysisData>) JSON.deserialize(cartAccount[0].Analysis_Data__c, List<CART_FileUploadHandler.AnalysisData>.class);
                */
                CART_FileUploadHandler.AnalysisData analysisList = CART_FileUploadHandler.parseAnalysisData(cartAccount[0].Analysis_Data__c);
                for(Integer i=1; i<=analysisList.monthlyCreditsDetails.size(); i++){
                
                    if(i==1){
                        //totalEMIAmount = analysisList.monthlyBalancesDetails[i-1].totalEMIAmount;
                        //noOfEmi = analysisList.monthlyBalancesDetails[i-1].noOfEMI;
                        salaryAmount = analysisList.monthlyCreditsDetails[i-1].SalaryCredit;
                        
                    }
                }
                /*for(Integer i=1; i<=analysisList.size(); i++){
                
                    if(i==1){
                        totalEMIAmount = analysisList[i].totalEMIAmount;
                        noOfEmi = analysisList[i].noOfEMI;
                        salaryAmount = analysisList[i].salaryAmount;
                        
                    }
                }*/
                
            }
            
            
            List<Bureau_Results__c>  bureauList = [SELECT Id,Applicant__c,Total_EMI_Amount__c,Bureau_Score_Date__c
                                                   FROM Bureau_Results__c
                                                   WHERE Applicant__c =:applicantId
                                                    WITH SECURITY_ENFORCED
                                                   ORDER BY Bureau_Score_Date__c    desc 
                                                   LIMIT 1];
            
            if(!bureauList.isEmpty() && bureauList[0].Total_EMI_Amount__c!=null){
                // Montly Obligation = Total_EMI_Amount__c of Latest Bureau Result of Applicant(sort by Bureau Score Date   ) + Sum of EMI_Amount__c for Recordtype : CBS of Account_Type__c='Loan'
                emiAmount = bureauList[0].Total_EMI_Amount__c + totalCbsEmiAmount;
            }
            
            wrapperInstance.monthlyObligation = emiAmount;
            wrapperInstance.cbsLoanAmount = totalCBSLoanAmount;
            wrapperInstance.cibilLoanAmount = totalCIBILAmount;
            wrapperInstance.cibilLatestLoanAmount = latestCIBILAmount;
            wrapperInstance.totalEMI = totalEMIAmount;
            wrapperInstance.noOfEMI = noOfEmi;
            wrapperInstance.monthAmount = salaryAmount;
            wrapperInstance.bankAccountRecords = accountList;
            wrapperInstance.sixMonthAvgBalance = sixmonthBalance;
            wrapperInstance.isCBSCheck =   ( (isCBSChecklist!=null) ) ? ( (isCBSChecklist.contains(false)) ? false : true) : false ;
            wrapperInstance.isCasaCheck = ( (isCASACheckList!=null) ) ? ( (isCASACheckList.contains(false)) ? false : true) : false ;
            wrapperInstance.isETRCheck = ( (isETRCheckList!=null) ) ? ( (isETRCheckList.contains(false)) ? false : true) : false  ;
            wrapperInstance.isDPDCheck =  ( (isDPDChecklist!=null) ) ? ( (isDPDChecklist.contains(false)) ? false : true) : false  ;
            
           
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return wrapperInstance;
    }
    

    public static Decimal getLoanEmi(Id applicantId){
            Applicant__c app = [SELECT id,Loan__r.EMI__c 
                                FROM Applicant__c
                                WHERE id=:applicantId  WITH SECURITY_ENFORCED];
            
        if(app.Loan__r.EMI__c!=null){
            return app.Loan__r.EMI__c;
        }else{
            return 0;
        }

    }
    /*
@description :  Get Premium_Customer_Check__mdt Metadata Records 
@param :   
@return :   List<Premium_Customer_Check__mdt>
*/
    @AuraEnabled
    public static Loan_Application__c fetchLoanStage(String applicantId){
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        try {
            loanApps = [SELECT Id ,Stage__c FROM Loan_Application__c WHERE Id IN (SELECT Loan__c FROM Applicant__c WHERE Id=:applicantId)];
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return loanApps[0];
    }
    /*
@description :  Get Premium_Customer_Check__mdt Metadata Records 
@param :   
@return :   List<Premium_Customer_Check__mdt>
*/
    @AuraEnabled
    public static List<Premium_Customer_Check__mdt> getPremiumMetadata(){
        List<Premium_Customer_Check__mdt> checklistData = new List<Premium_Customer_Check__mdt>();
        try {
            checklistData = [SELECT Id,Name__c,Type__c,Value__c
                             FROM Premium_Customer_Check__mdt WITH SECURITY_ENFORCED];
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return checklistData;
    }
    
    /*
@description :  Get Applicant Financials Records based on Applicant Id 
@param :  Id 
@return : List<Applicant_Financials_Details__c>
*/
    @AuraEnabled
    public static  List<Applicant_Financials_Details__c> getFinancials(Id applicantId){
        List < Applicant_Financials_Details__c > records = new List<Applicant_Financials_Details__c>();
        try {
            records = [SELECT Id,Name,Applicant__c,Applicant__r.Marital_Status__c,Applicant__r.Loan__c,Type_Of_Employment__c,Method_Of_Assesment__c,Consider_Income_for_Eligibility__c,Customer_Grade__c,Company_Name__c,Monthly_Income__c,Monthly_Obligation__c,Other_Income__c,RecordType.DeveloperName,Applicant_Name__c,Total_Work_Experience__c,Sector__c,Industry__c,Sub_Industry__c,Occupation__c,Applicant__r.IsInactive__c
                       FROM Applicant_Financials_Details__c 
                       WHERE RecordType.DeveloperName ='Financial_Parent' AND Applicant__c =:applicantId AND isActive__c = true AND Applicant__r.IsInactive__c=false WITH SECURITY_ENFORCED];
            
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return records;
    }
    
    /*
@description :  Get Applicant Financials Records and its Child Records based on Applicant Id 
@param :  Id 
@return : List<Applicant_Financials_Details__c>
*/
    @AuraEnabled
    public static  List<Applicant_Financials_Details__c> getFinancialChildDetails(Id recId){
        List<Applicant_Financials_Details__c>  result = new  List<Applicant_Financials_Details__c> ();
        try {
            
            // get the financial parent and its child details
            List<Applicant_Financials_Details__c> records = [SELECT Id, Monthly_Total_Income__c,Verified_Income__c, Monthly_Income__c,
                Other_Income__c, Monthly_Obligation__c,First_Month__c, Second_Month__c, Third_Month__c,Sector__c,Industry__c,
                Sub_Industry__c,Occupation__c,Type_Of_Employment__c,Method_Of_Assesment__c,Consider_Income_for_Eligibility__c,
                Customer_Grade__c,Company_Master__c, Company_Master__r.Company_Name__c,Company_Name__c,Total_Work_Experience__c,
                Applicant__r.Loan__r.Product__c,Applicant__r.Loan__r.Loan_Amount__c,RecordType.Name, RecordType.DeveloperName, 
                Monthly_Net_Income__c,Monthly_Turnover__c,Monthly_Net_Profit__c,Applicant__r.Customer_Type__c
                FROM Applicant_Financials_Details__c 
                WHERE  Id=:recId AND  isActive__c=true  WITH SECURITY_ENFORCED LIMIT 1];
            List<Applicant_Financials_Details__c> childrecords = [SELECT Id, Monthly_Total_Income__c, Monthly_Income__c, 
            First_Month__c, Second_Month__c, Third_Month__c,Annual_Net_Profit__c,Year__c,Filing_Date__c,Annual_Total_Income__c,
            Annual_Turnover__c,Annual_Expense__c,Monthly_Expense__c,Salary_Received_in_Cash__c,Monthly_Net_Salary__c,
            Company_Master__c,Company_Master__r.Company_Name__c,Company_Name__c, Total_Work_Experience__c,
            RecordType.Name, RecordType.DeveloperName, Monthly_Net_Income__c,Monthly_Turnover__c,Monthly_Net_Profit__c,
            Average_Monthly_Salary__c,
            Other_Income_Picklist__c, Other_If_Any__c, Method_Of_Assesment__c, Total_Net_Income__c,Applicant_Financials__c, 
            No_of_Cattle__c, Daily_Supply_of_Milk_Ltrs__c, Average_Sale_Price_Per_Liter__c, Daily_Collection__c, 
            Monthly_Receipts__c, Profit_Margin__c, Any_Other_Income__c, Any_Other_Expense__c, Type_of_Income__c,Income_Source__c,
            Unit__c, Annual_Income_Unit_Rs__c, Proof__c, Document_Type__c, Net_Annual_Income__c, Crop_Details__c, 
            MSP__c, Irrigartion_Source__c, Area_under_crop__c,
            Sowing_Month__c, Harvesting_Month__c,Estimated_Yield__c,Estimated_Sale_Value__c,Net_Revenue__c,Sector__c,
            Industry__c,Sub_Industry__c,Occupation__c,Area_under_Crop_Unit__c,Verified_Income__c, Cost_of_Cultivation__c
            FROM Applicant_Financials_Details__c 
            WHERE  Applicant_Financials__c=:recId AND  isActive__c=true WITH SECURITY_ENFORCED];
            result.addAll(childrecords);
            result.addAll(records);                                                 
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return result;
    }
    @AuraEnabled
    public static  List<Income_Profiling__mdt>  getEmploymentType(String entityType){
        List<Income_Profiling__mdt> profileMasterList = new List<Income_Profiling__mdt>();
        try {
            profileMasterList =[SELECT id,Type_of_Employment__c,Method_Assesment__c,Financial_Template__c,Entity_Type__c
                                FROM Income_Profiling__mdt
                                WHERE Entity_Type__c=:entityType WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return profileMasterList;
    }
    
    /*
@description :  Method to create or update Applicant Financials from LWC
@param :  Id 
@return : updated or inserted Id
*/
    @AuraEnabled 
    public static Id createFinancialRecords(Applicant_Financials_Details__c financeRecord){
        Applicant_Financials_Details__c finObj = new Applicant_Financials_Details__c();
        try{
            
            finObj = financeRecord;
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable()){
                upsert finObj;
            }
            String applicantId= financeRecord.Applicant__c;
            List<Applicant_Financials_Details__c> applicantFinancials= [SELECT Id,Applicant__c,Applicant__r.Loan__c,Type_Of_Employment__c,Method_Of_Assesment__c,Consider_Income_for_Eligibility__c,Customer_Grade__c,Company_Name__c,Monthly_Income__c,Monthly_Obligation__c,Other_Income__c,RecordType.DeveloperName,Applicant_Name__c
                                                                        FROM Applicant_Financials_Details__c where Applicant__c=:applicantId AND RecordType.Name='Financial Parent' ORDER By CreatedDate DESC];

           if(applicantFinancials.size()>1){
            delete applicantFinancials[0];
           }
        }catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
            
        }
        return finObj.Id;
    }
    
    /*
@description :  Method to get Visible fields based on the screen from Stage_Profile_Data_Configuration__mdt Custom Metadata Records
@param :  String  strScreen
@return : List<String>
*/
    @AuraEnabled
    public static List<String> getVisibleFields(String strScreen,String Stage) {
        return Utility.getVisibleFields(strScreen,Stage,'System Administrator');
    }
    
    /*
@description :  Method to get Profiling_Master__c Custom Metadata Records based on Applicant Id
@param :  Id  applicantId
@return : List<Profiling_Master__c> 
*/
    @AuraEnabled
    public static List<Profiling_Master__c> getProfilingMaster(Id applicantId){
        List<Applicant__c> applicantList = getApplicants(applicantId); // will pass the selected applicant id 
        String entityType;
        if(applicantList[0].Customer_Type__c!=null){
            entityType =applicantList[0].Customer_Type__c;
        }
       
        List<Profiling_Master__c> pmList = new List<Profiling_Master__c>();
        try {
            pmList =[SELECT id,Name,Entity_Type__c,Code__c,Employment_Type__c,Industry__c,Occupation__c,Sector__c,Sub_Industry__c
                     FROM Profiling_Master__c
                     WHERE Entity_Type__c =:entityType  WITH SECURITY_ENFORCED];

       
            
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return pmList;
    }
    
    /*
@description :  Method to get Related Profiling_Master__c records based on the selected picklist value
@param :  String selectedValue,String passingType,String returnType
@return : List<Profiling_Master__c> 
*/
    @AuraEnabled
    public static  List<Profiling_Master__c>  getRelatedProfilingMaster(String selectedValue,String passingType,String returnType,String queryParams){
        system.debug('%%% '+queryParams);
        List<Profiling_Master__c> pmList = new List<Profiling_Master__c>();
        List<String> lstQueryParams = new List<String>();
        lstQueryParams = String.isBlank(queryParams) ? new List<String>() : queryParams.split('~');
        //String strname = '';
        system.debug('%%% '+lstQueryParams);
        system.debug('%%% '+selectedValue);
        system.debug('%%% '+passingType);
        system.debug('%%% '+returnType);
        String strEmpType = '';
        String strSector = '';
        String strIndustry = '';
        String strSubIndustry = '';
        for (Integer i = 0;i<lstQueryParams.size();i++) {
            //strname = i == 1 ? lstQueryParams[0] : strname;
            strEmpType = i == 0 ? lstQueryParams[0] : strEmpType;
            strSector = i == 1 ? lstQueryParams[1] : strSector;
            strIndustry = i == 2 ? lstQueryParams[2] : strIndustry;
            strSubIndustry = i == 3 ? lstQueryParams[3] : strSubIndustry;
        }
        try {
            //SFAU-2962
            String strRecordTypeName = 'RT - Employment Type';
            String query,query1,query2,query3,query4,query5;
            if(passingType =='RT - Employment Type' && lstQueryParams.size()==0){ 
                query1 = 'SELECT  Sector__r.Name sectorName  from Profiling_Master__c  WHERE RecordType.Name=:passingType AND Name=:selectedValue GROUP BY Sector__r.Name ';
            }            
            if(passingType =='RT - Sector' && lstQueryParams.size() == 1){
                //query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE RecordType.Name=:strRecordTypeName AND Sector__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + ' WITH SECURITY_ENFORCED';
                query2 = 'SELECT  Industry__r.Name industryName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Sector__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + 'GROUP BY Industry__r.Name ';
            }
            if(passingType =='RT - Industry' && lstQueryParams.size() == 2){
                //query = 'SELECT Name,Code__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,Industry__c,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE RecordType.Name=:strRecordTypeName AND Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + ' WITH SECURITY_ENFORCED';
                query3 = 'SELECT  Sub_Industry__r.Name subindustryName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + 'GROUP BY Sub_Industry__r.Name ';
            }
            if(passingType =='RT - Sub Industry' && lstQueryParams.size() == 3){
                //query = 'SELECT Name,Code__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,Sub_Industry__c,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE RecordType.Name=:strRecordTypeName AND Sub_Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + (String.isNotBlank(strIndustry) ? ' AND Industry__r.Name =: strIndustry ' : '') + '  WITH SECURITY_ENFORCED';
                query4 = 'SELECT  Occupation__r.Name occupationName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Sub_Industry__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + (String.isNotBlank(strIndustry) ? ' AND Industry__r.Name =: strIndustry ' : '') + 'GROUP BY Occupation__r.Name ';
            }
            if(passingType =='RT - Occupation' && lstQueryParams.size() == 4){
                query = 'SELECT Name,Code__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,Occupation__c,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE RecordType.Name=:strRecordTypeName AND Occupation__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + (String.isNotBlank(strSector) ? ' AND Sector__r.Name =: strSector ' : '') + (String.isNotBlank(strIndustry) ? ' AND Industry__r.Name =: strIndustry ' : '') + (String.isNotBlank(strSubIndustry) ? ' AND Sub_Industry__r.Name =: strSubIndustry' : '') + ' WITH SECURITY_ENFORCED';
                //query2 = 'SELECT  Industry__r.Name industryName  from Profiling_Master__c  WHERE RecordType.Name=:strRecordTypeName AND Sector__r.Name=:selectedValue' + (String.isNotBlank(strEmpType) ? ' AND Name =:strEmpType ' : '') + 'GROUP BY Industry__r.Name ';
            }
            
            if(String.isNotBlank(query)){
                pmList = Database.query(query);
            }
            if(String.isNotBlank(query1)){
                List<AggregateResult> agrs = Database.query(query1);
                Set<String> sectorNames= new Set<String>();
                for(AggregateResult ag : agrs)
                    sectorNames.add((String) ag.get('sectorName'));
                query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:sectorNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                pmList = Database.query(query);
            }
            if(String.isNotBlank(query2)){
                List<AggregateResult> agrs = Database.query(query2);
                Set<String> industryNames= new Set<String>();
                for(AggregateResult ag : agrs)
                    industryNames.add((String) ag.get('industryName'));
                query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:industryNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                pmList = Database.query(query);
            }
            if(String.isNotBlank(query3)){
                List<AggregateResult> agrs = Database.query(query3);
                Set<String> subindustryNames= new Set<String>();
                for(AggregateResult ag : agrs)
                    subindustryNames.add((String) ag.get('subindustryName'));
                query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:subindustryNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                pmList = Database.query(query);
            }
            if(String.isNotBlank(query4)){
                List<AggregateResult> agrs = Database.query(query4);
                Set<String> occupationNames= new Set<String>();
                for(AggregateResult ag : agrs)
                    occupationNames.add((String) ag.get('occupationName'));
                query = 'SELECT Name,Code__c,Sector__c,Sector__r.Name,Industry__r.Name,Sub_Industry__r.Name,Occupation__r.Name,RecordType.Name,Risk__c,RecordType.DeveloperName FROM Profiling_Master__c WHERE Name =:occupationNames AND RecordType.Name=:returnType WITH SECURITY_ENFORCED';
                pmList = Database.query(query);
            }
            //SFAU-2962
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return pmList;
    }

    @AuraEnabled
    public static incomeWrapper getOtherIncomeTotal(Id recordId) {
        Decimal totalMonthlyIncome = 0;
        incomeWrapper wrapperInstance = new incomeWrapper();
        try {
          
            List < Applicant_Financials_Details__c > records = [SELECT Id, Monthly_Total_Income__c, Monthly_Income__c, First_Month__c, Second_Month__c, Third_Month__c, Net_Revenue__c, isActive__c,Method_Of_Assesment__c,
                                                                RecordType.name, RecordType.DeveloperName, Net_Annual_Income__c, Monthly_Net_Income__c, Monthly_Turnover__c, Monthly_Net_Profit__c
                                                                FROM Applicant_Financials_Details__c 
                                                                WHERE Applicant_Financials__c =: recordId
                                                                AND  isActive__c = true
                                                                AND RecordType.DeveloperName = 'Other_Income'
                                                                WITH SECURITY_ENFORCED
                                                               ];
            Decimal documentedIncome=0;
            Decimal assessedIncome=0;
            for (Applicant_Financials_Details__c afd: records) {
                totalMonthlyIncome = totalMonthlyIncome + afd.Monthly_Income__c;
                if(afd.Method_Of_Assesment__c == 'Documented' || afd.Method_Of_Assesment__c == 'Documented'){
                    documentedIncome = documentedIncome +  afd.Monthly_Income__c;
                }else{
                    assessedIncome = assessedIncome +  afd.Monthly_Income__c;
                }
            }
            wrapperInstance.documentedIncome = documentedIncome;
            wrapperInstance.assessedIncome = assessedIncome;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrapperInstance;
    }

    @AuraEnabled
    public static void deactivateChildFinancials (Id recordId){
        try{
           List< Applicant_Financials_Details__c >record = [SELECT Id, isActive__c,Applicant_Financials__c 
                                                      FROM Applicant_Financials_Details__c 
                                                     WHERE Applicant_Financials__c=:recordId
                                                     AND   isActive__c=true WITH SECURITY_ENFORCED  ];

            List<Applicant_Financials_Details__c> financialsUpdationRecords = new List<Applicant_Financials_Details__c>();
            for(Applicant_Financials_Details__c childRecord : record){
                childRecord.isActive__c = false;
                financialsUpdationRecords.add(childRecord);
            }
            
          if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable() && !financialsUpdationRecords.isEmpty()){
                update financialsUpdationRecords;
            }
           
            

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean getCompanyCode(String companyName){
        Boolean result = true;
        List<Generic_Master__c> companyList = new  List<Generic_Master__c>();
        try {
             companyList = [SELECT ID,Company_Name__c,Company_Category__c,RecordType.DeveloperName
                                                   FROM Generic_Master__c
                                                   WHERE Company_Name__c=:companyName
                                                   AND (Company_Category__c ='A' OR Company_Category__c ='B')
                                                   AND RecordType.DeveloperName='Company' ];

            if(companyList.size()>0){
                result = true;
            }else{
                result = false;
            }
                

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static List<Bank_Account_Records__c> checkCartFetchButton(String applicantId){
        try {
            List < Bank_Account_Records__c > casaBankRecords = new  List < Bank_Account_Records__c >();
            if(String.isNotBlank(applicantId)){
                casaBankRecords = [SELECT id, RecordType.DeveloperName, Account_Number__c, Account_Name__c, Account_Type__c, Bank_Name__c, Statement_Start_Date__c, Statement_End_Date__c, Product__c
                                    FROM Bank_Account_Records__c
                                    WHERE Applicant__c =: applicantId
                                    AND Account_Type__c = 'CASA'
                                    AND RecordType.DeveloperName = 'CBS'
                                    WITH SECURITY_ENFORCED
                                    ];
            }
            
            if(casaBankRecords!=null && casaBankRecords.size()>0){
                return casaBankRecords;
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void getCartStatement(String applicantId,String accountNumber) {
        if (String.isNotBlank(applicantId)) {
            String requestBody;
            String respBody = '';
            String requestId = IntegrationUtility.getReferenceId();
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Cart Statement Service');

            //CBS Casa Bank Acc records map the request id to the checklist

            //get Casa Records of CBS Type
            List < Bank_Account_Records__c > casaBankRecords = [SELECT id, RecordType.DeveloperName, Account_Number__c, Account_Name__c, Account_Type__c, Bank_Name__c, Statement_Start_Date__c, Statement_End_Date__c, Product__c
                FROM Bank_Account_Records__c
                WHERE Applicant__c =: applicantId
                AND Account_Type__c = 'CASA'
                AND RecordType.DeveloperName = 'CBS'
                AND Account_Number__c =:accountNumber
                WITH SECURITY_ENFORCED
            ];

            if (casaBankRecords != null && casaBankRecords.size() > 0) {
                for (Bank_Account_Records__c bankInstance: casaBankRecords) {
                    Map < String, Object > reqParam = new Map < String, Object > ();
                    reqParam.put('RequestId', requestId);
                    reqParam.put('AccountNumber', bankInstance.Account_Number__c); //bankInstance.Account_Number__c  //'2301201144357097'
                    reqParam.put('CustomerName', bankInstance.Account_Name__c); //bankInstance.Account_Name__c //'VIKRAM CHERI'
                    reqParam.put('EntityName', 'abc');
                    reqParam.put('BankName', 'AU Small Finance Bank');
                    String accountType = bankInstance.Product__c!=null ? bankInstance.Product__c :'';
                    if(String.isNotBlank(accountType)){
                        if (accountType.contains('Current') || accountType.contains('CURRENT')) {
                        reqParam.put('AccountType', 'CURRENT ACCOUNT'); //bankInstance.Account_Type__c
                         } else if (accountType.contains('Savings') || accountType.contains('SAVINGS')) {
                        reqParam.put('AccountType', 'SAVINGS ACCOUNT');
                        }
                    }
                    
                    
                    //reqParam.put('FromDate', System.today().addMonths(-6)); //System.today().addMonths(-6);  '2022-8-16'
                    //reqParam.put('EndDate', System.today()); //System.today()  '2023-02-16'
                    Date dStDate = Date.today().addMonths(-6);
                    Date dToday = Date.today();
                   String dateStr = dToday.year() + '/' + dToday.month() + '/' + dToday.day();
                    DateTime currentDT = System.now();
                    String endMonth=currentDT.format('MMMM');
                    
                    DateTime previousDT = System.now().addMonths(-6);
                    String startMonth=previousDT.format('MMMM');

                    String enddate =  String.valueof(dToday.day()) +'-'+endMonth.substring(0,3)+'-'+String.valueof(dToday.year());
                    String startDate = String.valueof(dStDate.day()) +'-' +startMonth.substring(0,3)+'-'+String.valueof(dStDate.year());
                    System.debug('startDate-->' +startDate);
                    System.debug('enddate-->' +enddate);

                    reqParam.put('FromDate', startDate);
                    reqParam.put('EndDate', enddate);
                    reqParam.put('Channel', Label.Cart_Statement_Channel);

                    /* List < Map < String, String >> transactionList = new List < Map < String, String >> ();
                     Map < String, String > transactionMap = new Map < String, String > ();
                     transactionMap.put('TxnDate', '2022-01-15');
                     transactionMap.put('ValueDate', '2022-01-15');
                     transactionMap.put('Description', 'NEFT/Sample Txn 32423423 transfer');
                     transactionMap.put('ChequeNo', '');
                     transactionMap.put('FlgDrCr', 'Cr');
                     transactionMap.put('Amount', '50000');
                     transactionMap.put('RunningTotal', '250001');
                     transactionList.add(transactionMap);

                     transactionMap.put('TxnDate', '2022-01-18');
                     transactionMap.put('ValueDate', '2022-01-18');
                     transactionMap.put('Description', 'NEFT/Sample Txn 32423423 transfer');
                     transactionMap.put('ChequeNo', '');
                     transactionMap.put('FlgDrCr', 'Cr');
                     transactionMap.put('Amount', '20000');
                     transactionMap.put('RunningTotal', '270001');
                     transactionList.add(transactionMap);

                     reqParam.put('TransactionInquiryDetailsType', JSON.serialize(transactionList));*/


                    requestBody = CartStatementIntegrationHandler.generateCartStatementRequest(reqParam)[0];
                    system.debug('%%' + requestBody);
                    String recordId = applicantId;

                    Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId, Request_Id__c = requestId);
                    IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                    calloutRequestWrapper.request = requestBody;
                    calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                    calloutRequestWrapper.masterRecord = objIntMapper;
                    calloutRequestWrapper.checklistRecord = checklistRecord;
                    IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
                    respBody = calloutResponseWrapper.response;
                    CartStatementIntegrationHandler.CartStatementResponseWrapper responseWrapper;
                    if (String.isNotBlank(respBody)) {
                        responseWrapper = (CartStatementIntegrationHandler.CartStatementResponseWrapper) JSON.deserialize(respBody, CartStatementIntegrationHandler.CartStatementResponseWrapper.class);
                    }

                    System.debug('responseWrapper-->' + responseWrapper);

                }
            }
        }
    }

    @AuraEnabled
    public static validationWrapper getFinancialStatus(String loanId){
        try {
            List<Applicant__c>  applicantList = [SELECT Id,Customer_Name__c,IsInactive__c,Bureau_Score__c,Marital_Status__c,First_Name__c,Middle_Name__c,Last_Name__c,Name,Loan__c,Loan_Stage__c,AU_Employee__c,Name_of_Employee_AU__c,Customer_Type__c,Loan__r.EMI__c,Total_Monthly_Income__c,Current_Obligation__c,Free_Monthly_Cashflow__c,Total_Loan_Amount__c,FOIR__c,Loan__r.Product__c,Loan__r.Stage__c,RecordType.DeveloperName,RecordType.Name,(SELECT Id,Applicant__c,Applicant__r.Loan__c,Sector__c,Industry__c,Sub_Industry__c,Occupation__c
                                                  FROM Applicant_Financials__r WHERE RecordType.Name = 'Financial Parent')
                                                  FROM Applicant__c
                                                 WHERE (Loan__c=:loanId OR Id=:loanId) 
                                                  AND IsInactive__c=false
                                                  AND (RecordType.Name ='Applicant' OR RecordType.Name = 'Co-Applicant' OR RecordType.Name = 'BO'  OR RecordType.Name = 'Guarantor') WITH SECURITY_ENFORCED];
            
            Set<Id> applicantIds = new Set<Id>();
            Map<String,Boolean> appVSFinancialMap = new Map<String,Boolean>();
            Boolean requiredFieldsParameter = false;                             
            for(Applicant__c applicantInstance : applicantList){
               List<Applicant_Financials_Details__c> financeDetails = applicantInstance.Applicant_Financials__r;
               if(applicantInstance.Loan__r.Stage__c == 'DDE'){
                if(financeDetails!=null && financeDetails.size()>0){
                    if(String.isBlank(financeDetails[0].Sector__c) ||  String.isBlank(financeDetails[0].Industry__c) || String.isBlank(financeDetails[0].Sub_Industry__c) ||  String.isBlank(financeDetails[0].Occupation__c)){
                        requiredFieldsParameter = true;
                    }/*else{
                        requiredFieldsParameter = false;
                    }*/
                  }
               }
               if(financeDetails.size()>0 && financeDetails!=null){
                appVSFinancialMap.put(applicantInstance.Customer_Name__c ,true);
               }else{
                appVSFinancialMap.put( applicantInstance.Customer_Name__c ,false);
               }
            }


            /*List<Applicant_Financials_Details__c>  financeDetails = [SELECT Id,Applicant__c,Applicant__r.Loan__c
                                                                     FROM Applicant_Financials_Details__c 
                                                                     WHERE Applicant__c =:applicantIds
                                                                     WITH SECURITY_ENFORCED];*/
            
            List<Boolean> presentListCheck = appVSFinancialMap.values();
            
            System.debug('presentListCheck-->' +presentListCheck);
            validationWrapper wrapperInstance = new validationWrapper();
            List<String> nameFilterList = new  List<String>();
            if(presentListCheck.contains(false)){
                wrapperInstance.resultCheck = false;
                for(String str : appVSFinancialMap.keySet()){
                    if(appVSFinancialMap.get(str)  == false){
                        nameFilterList.add(str);
                    }
                }
                wrapperInstance.validationNames = nameFilterList;
            }else{
                wrapperInstance.resultCheck = true;
            }
            wrapperInstance.mandatoryDDEParameter = requiredFieldsParameter;

            return wrapperInstance;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void applicantEmploymentUpdation(String applicantId ,String typeOfEmployment,String gradeVal){ //,
        try {
            if(String.isNotBlank(applicantId) ){
                Applicant__c appInstance = new Applicant__c();
                appInstance.Id = applicantId;
                if(String.isNotBlank(typeOfEmployment)){
                    appInstance.Type_Of_Employment__c = typeOfEmployment;
                }
                if(String.isNotBlank(gradeVal)){
                    appInstance.Customer_Grade__c = gradeVal;
                }
                

                update appInstance;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

   

    public class bankRecordsWrapper{
        @AuraEnabled public Boolean isCBSCheck{get;set;}
        @AuraEnabled public Boolean isETRCheck{get;set;}
        @AuraEnabled public Boolean isCasaCheck{get;set;}
        @AuraEnabled public Boolean isDPDCheck{get;set;}
        @AuraEnabled public Decimal cbsLoanAmount{get;set;}
        @AuraEnabled public Decimal cibilLoanAmount{get;set;}
        @AuraEnabled public Decimal cibilLatestLoanAmount{get;set;}
        @AuraEnabled public Decimal totalEMI{get;set;}
        @AuraEnabled public Decimal noOfEMI{get;set;}
        @AuraEnabled public Decimal monthAmount{get;set;}
        @AuraEnabled public Decimal monthlyObligation{get;set;}
        @AuraEnabled public Decimal sixMonthAvgBalance{get;set;}
       
        
        @AuraEnabled public List<Bank_Account_Records__c> bankAccountRecords{get;set;}
        
        public bankRecordsWrapper(){
            isCBSCheck = false;
            isDPDCheck = false;
            isETRCheck = false;
            isCasaCheck = false;
            sixMonthAvgBalance =0;
            cbsLoanAmount =0;
            cibilLoanAmount =0;
            cibilLatestLoanAmount=0;
            totalEMI =0;
            noOfEMI =0;
            monthAmount=0;
            monthlyObligation=0;
            bankAccountRecords = new List<Bank_Account_Records__c>();
        }
    }
    
    public class addressWrapper{
        @AuraEnabled public Boolean isAddressEqual{get;set;}
        @AuraEnabled public String jobStability{get;set;}
        public addressWrapper(){
            isAddressEqual =false;
            jobStability ='';
            
        }
    }
    public class validationWrapper{
        @AuraEnabled public List<String> validationNames{get;set;}
        @AuraEnabled public Boolean mandatoryDDEParameter{get;set;}
        @AuraEnabled public Boolean resultCheck{get;set;}

        public validationWrapper(){
            validationNames = new List<String>();
            resultCheck = false;
            mandatoryDDEParameter = false;
            
        }
    }
    
    /*
@description : Update Applicant Records based on Applicant Id 
@param :  Id 
*/
    @AuraEnabled
    public static void updateApplicant(Id applicantId,String wrapper){
        try {
            if(applicantId != null && wrapper != null){
                ApplicantWrapper appWrapper=(ApplicantWrapper)JSON.deserialize(wrapper,ApplicantWrapper.class);
                Applicant__c app = new Applicant__c();
                app.Id = applicantId;
                app.Marital_Status__c = appWrapper.marital;
                app.Residential_Status__c = appWrapper.residential;
                app.Phsically_challenged__c = appWrapper.physical;
                app.AU_Employee__c = appWrapper.auemp;
                app.High_risk_Profile__c = appWrapper.highrisk;
                app.Name_of_Employee_AU__c = appWrapper.auname;
                app.AU_Employee_ID__c = appWrapper.auid;
                app.AU_Employment_status__c = appWrapper.austatus;
                app.Natutre_of_Phsically_challenge__c = appWrapper.nature;
                app.Proof_of_Disablity__c = appWrapper.proof;
                app.Spouse_Name__c  = appWrapper.spouse;
                update app;
            }
            
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
    }
    
    public class ApplicantWrapper
    {
        @AuraEnabled
        public string marital{get;set;}
        @AuraEnabled
        public string residential{get;set;}
        @AuraEnabled
        public string physical{get;set;}
        @AuraEnabled
        public string highrisk{get;set;}
        @AuraEnabled
        public string auemp{get;set;}
        @AuraEnabled
        public string auname{get;set;}
        @AuraEnabled
        public string auid{get;set;}
        @AuraEnabled
        public string austatus{get;set;}
        @AuraEnabled
        public string nature{get;set;}
        @AuraEnabled
        public string proof{get;set;}
        @AuraEnabled
        public string spouse{get;set;}
        
    }
    
    
     /*
@description : get Applicant Records based on Applicant Id 
@param :  Id 
*/
    @AuraEnabled
    public static Applicant__c getApplicant(Id applicantId){
        Applicant__c app = new Applicant__c();
        try {
            if(applicantId != null){
                app = [Select Id,Spouse_Name__c ,Customer_Type__c,Marital_Status__c,Residential_Status__c,Phsically_challenged__c,High_risk_Profile__c,AU_Employee__c,AU_Employment_status__c,Name_of_Employee_AU__c,AU_Employee_ID__c,Natutre_of_Phsically_challenge__c,Proof_of_Disablity__c FROM Applicant__c WHERE Id=:applicantId];
            }
            
            
        } catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        system.debug('@@app'+app);
        return app;
    }
    //pooja
    @AuraEnabled
    public static Boolean validateAddressInfo(String applicantId, String typeOfEmpployment){
        system.debug('applicat id --- '+ applicantId);
        Boolean returnPrama ;
        system.debug('typeOfEmpployment --- '+ typeOfEmpployment);
        List<String> lstTypeOfEmployment = new List<String> {'Unemployed', 'Retired - Pensioner', 'Retired - Non-Pensioner', 'Housewife'};
        List<Address__c> lstAddress= [SELECT ID,Address_Type__c,Same_As__c FROM Address__c WHERE Applicant__c =:applicantId AND Address_Type__c='Office' AND Same_As__c ='NA'] ;
        system.debug('lstAddress-- '+ JSON.serializePretty(lstAddress));
            if(lstAddress.size() > 0 && lstTypeOfEmployment.contains(typeOfEmpployment))
                returnPrama = false;
            else{
                lstAddress= [SELECT ID,Address_Type__c,Same_As__c FROM Address__c WHERE Applicant__c =:applicantId AND Address_Type__c='Office' AND Same_As__c !='NA' ] ; 
                if(lstAddress.size()>0){
                    returnPrama= false;
                }else{
                    if(lstTypeOfEmployment.contains(typeOfEmpployment))
                        returnPrama = false;
                    else 
                        returnPrama = true;
                }
                
            }
                return returnPrama;
    }
    @AuraEnabled( cacheable = true )
    public static Applicant__c getRiskCategoryBasedOnRiskIdentification(Applicant__c draftApplicantRecord, String fieldApi){
        Applicant__c applicantRecord = [ SELECT Id, Type_Of_Employment__c, High_Risk_Profile__c, Risk_Identification__c, Loan__r.RecordType.Name FROM Applicant__c WHERE Id =: draftApplicantRecord.Id WITH SECURITY_ENFORCED ];
        applicantRecord.put(fieldApi, draftApplicantRecord.get(fieldApi));
        
        //:TODO - can single field be used to capture Risk Category
        String riskCategory = Utility.getApplicantRiskCategoryBy(applicantRecord);
        applicantRecord.X2W_Risk_Category__c = riskCategory;
        applicantRecord.X4W_Risk_Category__c = riskCategory;
        return applicantRecord;
    }
    public class incomeWrapper{
        @AuraEnabled  public Decimal documentedIncome;
        @AuraEnabled public Decimal assessedIncome;

        public incomeWrapper(){
            documentedIncome=0;
            assessedIncome = 0;
        }
    }
    
    public class ApplicantListWrapper implements Comparable {
        public Applicant__c applicantRecord;
    
        public ApplicantListWrapper(Applicant__c applicant) {
            applicantRecord = applicant;
        }
    
        public Integer compareTo(Object compareTo) {
            ApplicantListWrapper compareToApp = (ApplicantListWrapper) compareTo;
    
            Integer returnValue = 0;
            if (applicantRecord.RecordType.DeveloperName != null) {
                if (financeController.REC_TYPE_ORDER.indexOf(applicantRecord.RecordType.DeveloperName)
                 > financeController.REC_TYPE_ORDER.indexOf(compareToApp.applicantRecord.RecordType.DeveloperName)) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if (financeController.REC_TYPE_ORDER.indexOf(applicantRecord.RecordType.DeveloperName)
                     < financeController.REC_TYPE_ORDER.indexOf(compareToApp.applicantRecord.RecordType.DeveloperName)) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }
            }
            return returnValue;       
        }
    }

    @AuraEnabled
    public static Collateral__c getCollateralDetails(String loanId){
        try {
            List<Collateral__c> collaterals = [SELECT Id, Variant__c,Is_Deleted__c FROM Collateral__c WHERE Loan__c=:loanId AND Is_Deleted__c = false AND RecordTypeId IN :GlobalConstants.colRecordTypeIds];
            if(!collaterals.isEmpty()){
                return collaterals[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}