/*****
 * Class Name: LANCreationAPIHandler
 * Description: 
 * Test Class Name: LANCreationAPIHandlerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-11-2023          -   Mohit Maheshwari    -   SFAU-5717 - Change CollateralId from Long to String
 * Jan-01-2023          -   Samridhi            -   SFAU-5838 - Change Manufacture Year Logic after Year Change
 */

 public with sharing class LANCreationAPIHandler {
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,String> paramsMap=(Map<String,String>)reqParam;

        List<Loan_Application__c> loanApplicationList = [SELECT Id, Esign_Type__c, Esign_Date__c, Credit_Approved_Exposure__c, Pre_Approved_Flag__c, Rate_Chart_Code__c, Rate_Chart_Code__r.Rate_Chart_Code__c, Rate_Chart_Code__r.CBS_Pricing__c, Name, ROI__c, Branch_Master__c, Branch_Master__r.Account_Code__c, Product__c, Type_of_Rate__c,
                Schedule_Code__c, Purpose_of_Loan__c, Credit_Approval_Date__c, Tenure__c, CreatedDate, Loan_Amount__c, Total_Loan_Amount__c, Application_Id__c, LAN__c, Loan_Number__c, Repayment_Mode__c, 
                (SELECT CIF_No__c, First_Name__c, Middle_Name__c, Last_Name__c, RecordType.Name, RecordType.DeveloperName, Customer_Name__c
                FROM Applicants__r WHERE RecordType.DeveloperName IN ('Primary_Applicant','Co_Applicant','Guarantor','BO') AND IsInactive__c=false),
                (SELECT LTV__c, Apportioned_Loan_Amount__c, LTV_offered_On_final_cost__c, Grid_Depreciated_Value__c,Valuation_Amount__c, Collateral_Name__c, Registration_City__c, IBB_Value__c, Product__c, Estimated_market_value__c, Valuation_date__c, Make__c, Collateral_Value__c, Product_Name_Code__c, Model__c,
                Chasis_Number__c, Engine_Number__c, Vehicle_Number__c, Ex_Showroom_Price__c, Manufacture_year_month__c, Variant__c, Collateral_ID__c, Final_Cost__c,
                MMV_Master__c, MMV_Master__r.Name, Collateral_Id_in_CBS__c,BT_Loan_Status__c ,SVSH_SVOH__c
                FROM Collaterals__r Where Is_Deleted__c = false AND recordTypeId IN: GlobalConstants.colRecordTypeIds Order By CreatedDate Desc) FROM
                Loan_Application__c WHERE id=:paramsMap.get('LoanId') WITH SECURITY_ENFORCED];

        /*Loan_Application__c loan = paramsMap.get('LoanApplication');
        Collateral__c collateral = new Collateral__c();
        Applicant__c applicant = new Applicant__c(); */

        LANCreationApiRequestWrapper lanApiRequestWrapper = new LANCreationApiRequestWrapper();
        Loan_Application__c loan;
        if(loanApplicationList!=null && loanApplicationList.size()>0){
            loan = loanApplicationList[0];//paramsMap.get('LoanApplication');
        }
        
        Collateral__c collateral = new Collateral__c();
        Applicant__c applicant = new Applicant__c();

        String failureReason = paramsMap.get('FailureReason');

        if(loan.collaterals__r!=null && loan.collaterals__r.size()>0){
            collateral = loan.collaterals__r[0];
        }
        system.debug('collateral '+collateral);
        if(loan.applicants__r!=null && loan.applicants__r.size()>0){
            for(Applicant__c applicantTemp : loan.applicants__r){
                if(applicantTemp.RecordType.DeveloperName == 'Primary_Applicant'){
                    applicant = applicantTemp;
                }
            }
            
        }
        system.debug('applicant '+applicant);

        String prod = GlobalConstants.PREFIXPRODRTMAP+loan.Product__c;
        ProductRTMap__mdt prodRecordType = ProductRTMap__mdt.getInstance(prod);

        lanApiRequestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
        lanApiRequestWrapper.Channel = paramsMap.get('Channel');//'LOS';
        if(loan.Branch_Master__c!=null && loan.Branch_Master__r.Account_Code__c!=null){
            lanApiRequestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        ReportingParamWrapper reportingWrapper = new ReportingParamWrapper();
        reportingWrapper.MISClass = GlobalConstants.MISCLASS;//'DIVISION';
        reportingWrapper.MISCode = GlobalConstants.MISCODE;//0;
        lanApiRequestWrapper.ReportingParam = reportingWrapper;

        LoanAccountWrapper newLoanAccWrapper = new LoanAccountWrapper();
        newLoanAccWrapper.AgreementNumber = loan.Loan_Number__c!=null?Integer.valueOf(loan.Loan_Number__c):null;
        newLoanAccWrapper.LtvRatio = collateral.LTV_offered_On_final_cost__c;//collateral.LTV__c;
        newLoanAccWrapper.ProductCode = loan.Product__c!=null?Integer.valueOf(loan.Product__c):null; //commented for Loan Record Not Found Validation

        if(failureReason == 'CollateralCreation' || failureReason == 'CollateralLinkage' || loan.LAN__c!=null){
            newLoanAccWrapper.AccountId = loan.LAN__c;
        }

        if(loan.Rate_Chart_Code__r!=null && loan.Rate_Chart_Code__r.Rate_Chart_Code__c!=null){
            newLoanAccWrapper.RateChartCode = Integer.valueOf(loan.Rate_Chart_Code__r.Rate_Chart_Code__c);
        }

        if(applicant.CIF_No__c!=null){
            newLoanAccWrapper.CustomerId = Integer.valueOf(applicant.CIF_No__c);
        }

        List<Repayment_Mode__mdt> repaymentModes = [SELECT Id, Code__c FROM Repayment_Mode__mdt WHERE Repayment_Mode__c=:loan.Repayment_Mode__c];
        newLoanAccWrapper.RepaymentMode = repaymentModes!=null && repaymentModes.size()>0?Integer.valueOf(repaymentModes[0].Code__c):null;//GlobalConstants.LAN_CREATION_REPAYMENT_MODE;//1;

        newLoanAccWrapper.ScheduleCode = loan.Schedule_Code__c!=null?Integer.valueOf(loan.Schedule_Code__c):null;
        newLoanAccWrapper.LoanPurpose = loan.Purpose_of_Loan__c;
        newLoanAccWrapper.AccountDateBasis = GlobalConstants.ACCOUNT_DATE_BASIS;//2;
        newLoanAccWrapper.LoanTerm = loan.Tenure__c!=null?Integer.valueOf(loan.Tenure__c):null;//Validation in response loan term should be within limit of the product
        
        if(loan.Pre_Approved_Flag__c==true){
            newLoanAccWrapper.LetterOfOfferDate = String.valueOf(Date.today());//.replace('-','');
        }else{
            newLoanAccWrapper.LetterOfOfferDate = loan.Credit_Approval_Date__c!=null?String.valueOf(loan.Credit_Approval_Date__c):String.valueOf(Date.today());
        }
        
        newLoanAccWrapper.AcctOpenDate = String.valueOf(Date.today());
        newLoanAccWrapper.AssetValue = loan.Total_Loan_Amount__c!=null?Integer.valueOf(loan.Total_Loan_Amount__c):null;

        if(loan.Esign_Type__c == 'Digital'){
            newLoanAccWrapper.AgreementSignDate = loan.Esign_Date__c!=null?String.valueOf(loan.Esign_Date__c):String.valueOf(Date.today());
        }else{
            newLoanAccWrapper.AgreementSignDate = String.valueOf(Date.today());
        }

        newLoanAccWrapper.ApplicationId = loan.Loan_Number__c!=null?Integer.valueOf(loan.Loan_Number__c):null;
         
        newLoanAccWrapper.FixedTermInMonths = loan.Tenure__c!=null?Integer.valueOf(loan.Tenure__c):null;//Integer.valueOf(loan.Tenure__c);
        if(loan.applicants__r!=null && loan.applicants__r.size()>1){
            newLoanAccWrapper.FlgJointHolder = 'Y';
        }
        else{
            newLoanAccWrapper.FlgJointHolder = 'N';
        }

        //maintain exact sequence for CustomerRelations
        Map<String, CustomerAndRelationWrapper> newCustRelationMap = new Map<String, CustomerAndRelationWrapper>();
        newCustRelationMap.put('Primary_Applicant',new CustomerAndRelationWrapper());
        newCustRelationMap.put('Co_Applicant',new CustomerAndRelationWrapper());
        newCustRelationMap.put('Guarantor',new CustomerAndRelationWrapper());
        newCustRelationMap.put('BO',new CustomerAndRelationWrapper());

        if(loan.applicants__r!=null && loan.applicants__r.size()>0){
            Map<String, Applicant_Type_Code__mdt> appTypeCodes = Applicant_Type_Code__mdt.getAll();
            //Applicant_Type_Code__mdt appTypeCode = Applicant_Type_Code__mdt.getInstance(applicant.RecordType.Name);

            List<CustomerAndRelationWrapper> customerAndRelationWrapperList = new List<CustomerAndRelationWrapper>();
             for(Applicant__c applicantTemp : loan.applicants__r){
                CustomerAndRelationWrapper newCustomerRelationWrapper = new CustomerAndRelationWrapper();
                newCustomerRelationWrapper.Relation = appTypeCodes.get(applicantTemp.RecordType.DeveloperName)!=null?appTypeCodes.get(applicantTemp.RecordType.DeveloperName).Type_Code__c:'';
                newCustomerRelationWrapper.CustomerId = applicantTemp.CIF_No__c!=null?Integer.valueOf(applicantTemp.CIF_No__c):null;
                if(applicantTemp.RecordType.DeveloperName == 'Nominee'){
                    newCustomerRelationWrapper.CustomerName = applicantTemp.Customer_Name__c;
                }else{
                    newCustomerRelationWrapper.CustomerName = (applicantTemp.First_Name__c!=null?applicantTemp.First_Name__c+' ':'')+(applicantTemp.Middle_Name__c!=null?applicantTemp.Middle_Name__c+' ':'')+(applicantTemp.Last_Name__c!=null?applicantTemp.Last_Name__c:'');
                }
                newCustRelationMap.put(applicantTemp.RecordType.DeveloperName,newCustomerRelationWrapper);
                //customerAndRelationWrapperList.add(newCustomerRelationWrapper);
                
            } 
            for(CustomerAndRelationWrapper wrap: newCustRelationMap.values()){
                if(wrap.Relation!=null){
                    customerAndRelationWrapperList.add(wrap);
                }
            }
            newLoanAccWrapper.CustomerAndRelation = customerAndRelationWrapperList;
        }
    
        lanApiRequestWrapper.LoanAccount = newLoanAccWrapper;
        AccountVarianceWrapper newAccountVarianceWrapper = new AccountVarianceWrapper();
        newAccountVarianceWrapper.rateType = GlobalConstants.RATE_TYPE;//1;
        
        newAccountVarianceWrapper.interestVarianceType = GlobalConstants.INTEREST_VARIANCE_TYPE;//String.valueOf(loan.ROI__c - loan.Rate_Chart_Code__r.CBS_Pricing__c);//'A';
        newAccountVarianceWrapper.rescheduleType = GlobalConstants.RESCHEDULE_TYPE;//'N';

        LoanVarianceDetailsTypeWrapper newLoanVarianceDetailsTypeWrapper = new LoanVarianceDetailsTypeWrapper();
        newLoanVarianceDetailsTypeWrapper.endDate = String.valueOf(Date.today().addMonths(Integer.valueOf(loan.Tenure__c)));
        if(loan.ROI__c != null && loan.Rate_Chart_Code__r.CBS_Pricing__c != null){
            newLoanVarianceDetailsTypeWrapper.variance = loan.ROI__c - loan.Rate_Chart_Code__r.CBS_Pricing__c;
        }
        newLoanVarianceDetailsTypeWrapper.startDate = String.valueOf(Date.today());//'2023-02-06'; //encountered response validation - Backdated transaction not allowed for this date .
    
        newAccountVarianceWrapper.loanVarianceDetailsType = newLoanVarianceDetailsTypeWrapper;

        newLoanAccWrapper.AccountVariance = newAccountVarianceWrapper;

        CollateralDetailWrapper newCollateralDetailWrapper = new CollateralDetailWrapper();
        newCollateralDetailWrapper.PrimaryOrSecondaryCollateral = GlobalConstants.PRIMARY_SECONDARY_COLLATERAL;//'P';

        ValuationDetailsWrapper newValuationDetailsWrapper = new ValuationDetailsWrapper();

        // SFAU-4476 -- 5th-Sept-23 - Final Cost to be send ( vehicle details now has this logic to pick lower value among IBB / Grid )
        newValuationDetailsWrapper.MarketValue = collateral.Final_Cost__c !=null ? collateral.Final_Cost__c : 0;
        newValuationDetailsWrapper.LastValue = newValuationDetailsWrapper.MarketValue;
        newValuationDetailsWrapper.OriginalValue = newValuationDetailsWrapper.MarketValue;

        List<Valuation__c> valuationDetails = [SELECT Valuer_Name_Code__c, Valuation_Amount__c FROM Valuation__c WHERE Collateral__c=:collateral.Id];
        if(valuationDetails!=null && valuationDetails.size()>0){
            if(valuationDetails[0].Valuer_Name_Code__c == 'Other'){
                newValuationDetailsWrapper.ValuationSource = 'Internal';
            }else{
                newValuationDetailsWrapper.ValuationSource = '';
            }
            newValuationDetailsWrapper.ValuationSupplement = valuationDetails[0].Valuer_Name_Code__c;
        }else{
            newValuationDetailsWrapper.ValuationSource = '';
            newValuationDetailsWrapper.ValuationSupplement='';
        }
        newValuationDetailsWrapper.DateOfOrgValuation = collateral.Valuation_date__c!=null?collateral.Valuation_date__c:String.valueOf(Date.today());//'2023-02-06'; //date of org valuation cannot be null 
        
        newValuationDetailsWrapper.DateOfLastValuation = String.valueOf(Date.today());
        
            
        newCollateralDetailWrapper.ValuationDetails = newValuationDetailsWrapper;
        newCollateralDetailWrapper.FlagDeduction = GlobalConstants.FLAG_DEDUCTION;//'Y';

        CollateralDeedDetailsWrapper newCollateralDeedDetailsWrapper = new CollateralDeedDetailsWrapper();
        newCollateralDeedDetailsWrapper.CustodyStatus = GlobalConstants.CUSTODY_STATUS;//0; 
        newCollateralDeedDetailsWrapper.NamRegnAuth = collateral.Registration_City__c;//'Gram Panchayat';
        newCollateralDeedDetailsWrapper.DateReturnExpected = String.valueOf(Date.today().addMonths(Integer.valueOf(loan.Tenure__c)));//'2044-02-14';
        newCollateralDeedDetailsWrapper.DeedDetails = GlobalConstants.DEED_DETAILS;//'AUF';
        newCollateralDeedDetailsWrapper.DateDeedsSent = String.valueOf(Date.today());//'2019-02-14';

        newCollateralDetailWrapper.CollateralDeedDetails = newCollateralDeedDetailsWrapper;

        /*PropertyCollateralDetailsWrapper newPropertyCollateralDetailsWrapper = new PropertyCollateralDetailsWrapper(); 
        newPropertyCollateralDetailsWrapper.TotalArea = 45;
        newPropertyCollateralDetailsWrapper.Description = 'UTTAR PRADESH 271312';
        newPropertyCollateralDetailsWrapper.AreaUnit = 'SqFt';
        newPropertyCollateralDetailsWrapper.TypeOfProperty = 0;
        newPropertyCollateralDetailsWrapper.Location = 'hgkhjk';

        newCollateralDetailWrapper.PropertyCollateralDetails = newPropertyCollateralDetailsWrapper;*/
   
        AutomobileCollateralDetailsWrapper newAutomobileCollateralDetails = new AutomobileCollateralDetailsWrapper();

        if(prodRecordType!=null && prodRecordType.Sub_Product__c !=null){
            if(prodRecordType.Sub_Product__c == 'New'){
                newAutomobileCollateralDetails.ChasisNumber = 'NA';
                newAutomobileCollateralDetails.EngineNumber = 'NA';
                newAutomobileCollateralDetails.RegistrationNo = 'NA';
            }else if(prodRecordType.Sub_Product__c == 'Used' || System.Label.COW_Product_Names.toUpperCase().contains(prodRecordType.Sub_Product__c.toUpperCase()) ){//R2-2634
                if(collateral.Chasis_Number__c!=null){
                    newAutomobileCollateralDetails.ChasisNumber = collateral.Chasis_Number__c;
                }
                if(collateral.Engine_Number__c!=null){
                    newAutomobileCollateralDetails.EngineNumber = collateral.Engine_Number__c;
                }
                if(collateral.Vehicle_Number__c!=null){
                    newAutomobileCollateralDetails.RegistrationNo = collateral.Vehicle_Number__c;
                } 
            }
        }

        
        /*if(collateral.Variant__c!=null){
            newAutomobileCollateralDetails.Description1 = collateral.Variant__c;//
        }else{
           newAutomobileCollateralDetails.Description1 = '';
        }*/

        // SFAU-5634 Updated by Kunal - Dec 1st --- Start
        newAutomobileCollateralDetails.ModelNo = collateral.Make__c; //  collateral.Model__c;
        // SFAU-5634 --- End
        /* START - SFAU-5838 - Change Manufacture Year Logic after Year Change */
        if(collateral.Manufacture_year_month__c!=null && collateral.Manufacture_year_month__c.length()==4 && (Integer.valueOf(collateral.Manufacture_year_month__c)==Date.today().year() || Integer.valueOf(collateral.Manufacture_year_month__c)==Date.today().addYears(-1).year())){
            Date dtManuYear = Date.Parse('01/01/'+collateral.Manufacture_year_month__c);
            String currentMonth = String.valueOf(Date.today().month());
            newAutomobileCollateralDetails.ManufactureYrMon = String.valueOf(dtManuYear.year())+(currentMonth.length()==1?'0'+currentMonth:currentMonth);
        }
        else if(collateral.Manufacture_year_month__c!=null && collateral.Manufacture_year_month__c.length()==6){
            newAutomobileCollateralDetails.ManufactureYrMon = collateral.Manufacture_year_month__c;
        }
        /*
        if(collateral.Manufacture_year_month__c!=null && collateral.Manufacture_year_month__c.length()==4 && Integer.valueOf(collateral.Manufacture_year_month__c)==Date.today().year()){
            String currentMonth = String.valueOf(Date.today().month());
            newAutomobileCollateralDetails.ManufactureYrMon = String.valueOf(Date.today().year())+(currentMonth.length()==1?'0'+currentMonth:currentMonth);
        }else{
            newAutomobileCollateralDetails.ManufactureYrMon = collateral.Manufacture_year_month__c; //validation occurred Invalid String Value in field manufactureYrMon
        }
        */
        /* END - SFAU-5838 - Change Manufacture Year Logic after Year Change */
        newAutomobileCollateralDetails.Description1 = collateral.MMV_Master__c!=null?(collateral.MMV_Master__r.Name.replaceAll('[^a-zA-Z0-9\\s+]', ' ')):'';
        newAutomobileCollateralDetails.Description2 = GlobalConstants.AUTOMOBILE_DESCRIPTION;
        //;

        newCollateralDetailWrapper.AutomobileCollateralDetails = newAutomobileCollateralDetails;

        if(failureReason == 'CollateralLinkage'){ // SFAU-5669 if Existing collateral available then send yes.
            newCollateralDetailWrapper.IsOnlyLinkageRequired = 'Yes';
        }else{
            newCollateralDetailWrapper.IsOnlyLinkageRequired = (String.isBlank(collateral.Collateral_Id_in_CBS__c) || (collateral.BT_Loan_Status__c == GlobalConstants.FORE_CLOSURE_REFINANCE || collateral.SVSH_SVOH__c == 'SVOH' )) ? 'No' : 'Yes';
        }
        //newCollateralDetailWrapper.IsOnlyLinkageRequired = 'Yes';

        newCollateralDetailWrapper.Make = collateral.Make__c!=null?collateral.Make__c:'';
        newCollateralDetailWrapper.CollateralValue = collateral.Apportioned_Loan_Amount__c!=null?Integer.valueOf(collateral.Apportioned_Loan_Amount__c):0;//collateral.Final_Cost__c!=null?Integer.valueOf(collateral.Final_Cost__c):0;
        newCollateralDetailWrapper.CollateralCode = Integer.valueOf(collateral.Collateral_Name__c);//Integer.valueOf(collateral.Product__c);//collateral.Product__c;
        newCollateralDetailWrapper.Model =  collateral.Model__c!=null?collateral.Model__c:'';
        //SFAU-5228 : Commented by Samridhi
        //newCollateralDetailWrapper.CollateralID = collateral.Collateral_ID__c!=null?Long.valueOf(collateral.Collateral_ID__c):null;
        if(loan.Branch_Master__c!=null && loan.Branch_Master__r.Account_Code__c!=null){
            newCollateralDetailWrapper.HomeBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        newCollateralDetailWrapper.TypeOfCharge = GlobalConstants.TYPE_OF_CHARGE;//1;

        

        if(prodRecordType!=null && prodRecordType.Sub_Product__c !=null){
            if(prodRecordType.Sub_Product__c == 'New'){
                newCollateralDetailWrapper.AssetClass = 1;
                //SFAU-5228 : Added by Samridhi
                newCollateralDetailWrapper.CollateralID = collateral.Collateral_ID__c+'';
            }else if(prodRecordType.Sub_Product__c == 'Used' || System.Label.COW_Product_Names.toUpperCase().contains(prodRecordType.Sub_Product__c.toUpperCase())){//R2-2634
                newCollateralDetailWrapper.AssetClass = 2;
                //SFAU-5228 : Added by Samridhi
                //SFAU-5343 : Updated by Kunal
                newCollateralDetailWrapper.CollateralID = String.isBlank(collateral.Collateral_Id_in_CBS__c) || (collateral.BT_Loan_Status__c == GlobalConstants.FORE_CLOSURE_REFINANCE || collateral.SVSH_SVOH__c == 'SVOH' ) ? collateral.Collateral_ID__c + '' : collateral.Collateral_Id_in_CBS__c +'' ;
            }
        }
                    
        lanApiRequestWrapper.CollateralDetail = newCollateralDetailWrapper;
    
        lstString.add(JSON.serializePretty(lanApiRequestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public static Decimal isDecimal(String value){
        Decimal returnValue=null;
        try{
            returnValue = Decimal.valueOf(value);
        }catch(Exception e){
            returnValue = null;
        }
        return returnValue;
    }
        
    public class LANCreationApiRequestWrapper{
        public LoanAccountWrapper LoanAccount;
        public CollateralDetailWrapper CollateralDetail;
        public String ReferenceNumber;
        public String Channel;
        public ReportingParamWrapper ReportingParam;
        public Integer TransactionBranch;
    }
    
    public class LoanAccountWrapper{
        public String AccountId;
        public List<CustomerAndRelationWrapper> CustomerAndRelation;
        public Integer AgreementNumber;
        public Decimal LtvRatio;
        public Integer ProductCode;
        public Integer RateChartCode;
        public Integer CustomerId;
        public Integer RepaymentMode;
        public Integer ScheduleCode;
        public String LoanPurpose;
        public Integer AccountDateBasis;
        public Decimal LoanTerm;
        public String LetterOfOfferDate;
        public String AcctOpenDate;
        public Integer AssetValue;
        public String AgreementSignDate;
        public Integer ApplicationId;
        public Integer FixedTermInMonths;
        public AccountVarianceWrapper AccountVariance;
        public String FlgJointHolder;
    }
    
    public class CustomerAndRelationWrapper{
        public String Relation;
        public Integer CustomerId;
        public String CustomerName;
    }

    public class AccountVarianceWrapper{
        public Integer rateType;
        public LoanVarianceDetailsTypeWrapper loanVarianceDetailsType;
        public String interestVarianceType;
        public String rescheduleType;
    }
    
    public class LoanVarianceDetailsTypeWrapper{
        public String endDate;
        public Decimal variance;
        public String startDate;
    }
    
    public class CollateralDetailWrapper{
        public String IsOnlyLinkageRequired;
        public String PrimaryOrSecondaryCollateral;
        public ValuationDetailsWrapper ValuationDetails;
        public String FlagDeduction;
        public CollateralDeedDetailsWrapper CollateralDeedDetails;
        public String Make;
        public Integer CollateralValue;
        public Integer CollateralCode;
        //public PropertyCollateralDetailsWrapper PropertyCollateralDetails; //cannot be null or blank validation encountered
        public AutomobileCollateralDetailsWrapper AutomobileCollateralDetails;
        public String Model;
        public Integer HomeBranch;
        public Integer TypeOfCharge;
        public Integer AssetClass;
        public String CollateralID; // CollateralId - SFAU-SFAU-5717 - change data type from Long to String
    }
       
    public class AutomobileCollateralDetailsWrapper{
        public String ChasisNumber;
        public String EngineNumber;
        public String RegistrationNo;
        public String ModelNo;
        public String ManufactureYrMon;
        public String Description1;
        public String Description2;
    }

    public class ValuationDetailsWrapper{
        public Decimal LastValue;
        public Decimal MarketValue;
        public String ValuationSource;
        public String DateOfOrgValuation;
        public Decimal OriginalValue;
        public String DateOfLastValuation;
        public String ValuationSupplement;
    }
    
    public class CollateralDeedDetailsWrapper{
        public Integer CustodyStatus;
        public String NamRegnAuth;
        public String DateReturnExpected;
        public String DeedDetails;
        public String DateDeedsSent;   
    }

    public class PropertyCollateralDetailsWrapper{
        public Integer TotalArea;
        public String Description;
        public String AreaUnit;
        public Integer TypeOfProperty;
        public String Location;
    }
    
    public class ReportingParamWrapper{
        public String MISClass;
        public Integer MISCode;
    }

    public class LANCreationApiResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
        @AuraEnabled public String AccountId{get;set;}
    }
    
    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
        @AuraEnabled public List<ValidationErrorsWrapper> ValidationErrors{get;set;}
    }
    
    public class ValidationErrorsWrapper{
        @AuraEnabled public String ErrorMessage{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }
    
    public class MessagesWrapper{
        @AuraEnabled public Integer code{get;set;}
        @AuraEnabled public String message{get;set;}
    }
}