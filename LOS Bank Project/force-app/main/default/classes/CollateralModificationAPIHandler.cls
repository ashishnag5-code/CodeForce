/*****
 * Class Name: CollateralModificationAPIController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-06-2023          -   Mohit M.            -   HotFix - CollateralCode in Modification API - replace Attribute mapping for CollateralCode
 * Dec-08-2023          -   Mohit M.            -   SFAU-5665 - Change Final_Cost__c with Vehicle_Cost__c (LastCollateralValue and MarketCollateralValue)
 */
public with sharing class CollateralModificationAPIHandler implements IntegrationHandlerInterface{

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Loan_Application__c> paramsMap=(Map<String,Loan_Application__c>)reqParam;
        
        Loan_Application__c loan = paramsMap.get('LoanApplication');
        Collateral__c collateral = new Collateral__c();
        if(loan.collaterals__r!=null && loan.collaterals__r.size()>0){
            collateral = loan.collaterals__r[0];
        }
        CollateralModificationRequestWrapper wrapper = new CollateralModificationRequestWrapper();
        wrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
        wrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        wrapper.RequestId = wrapper.ReferenceNumber;
        wrapper.OriginatingChannel = System.Label.Integration_Channel;//'HFT';
        //wrapper.CollateralId = String.isNotBlank(collateral.Collateral_Id_in_CBS__c) ? Long.valueOf(collateral.Collateral_Id_in_CBS__c) : null;//Long.valueOf(collateral.Collateral_ID__c);
        wrapper.CollateralId = String.isNotBlank(collateral.Collateral_Id_in_CBS__c) ? String.valueOf(collateral.Collateral_Id_in_CBS__c) : null;//collateralId can contain text
        wrapper.CollateralCode = collateral.Collateral_Code_in_CBS__c; // collateral.Collateral_Name__c;
        wrapper.HomeBranch = String.valueOf(wrapper.TransactionBranch);
        ReportingParamWrapper reportingWrapper = new ReportingParamWrapper();
        reportingWrapper.MISClass = 'DIVISION';
        reportingWrapper.MISCode = '0';
        wrapper.ReportingParam = reportingWrapper;
        ValuationModDetailsWrapper valuationWrapper = new ValuationModDetailsWrapper();
        valuationWrapper.LastCollateralValue = collateral.Vehicle_Cost__c!=null?String.valueOf(collateral.Final_Cost__c):null;//collateral.Valuation_Amount__c; Mapping change 15th Sept
        valuationWrapper.LastValuationDate = collateral.Valuation_date__c!=null?String.valueOf(collateral.Valuation_date__c):String.valueOf(Date.today()).remove('-');
        valuationWrapper.MarketCollateralValue = collateral.Vehicle_Cost__c!=null?String.valueOf(collateral.Final_Cost__c):null;//collateral.Valuation_Amount__c; Mapping change 15th Sept
        wrapper.ValuationModDetails = valuationWrapper;
        lstString.add(JSON.serialize(wrapper));
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class CollateralModificationRequestWrapper{
        public String ReferenceNumber;
        public Integer TransactionBranch;
        public ReportingParamWrapper ReportingParam;
        public String RequestId;
        public String OriginatingChannel;
        public String CollateralId;//Collateral ID can contain text
        //public Long CollateralId;
        public String CollateralCode;
        public String HomeBranch;
        public ValuationModDetailsWrapper ValuationModDetails;
        public AutomobileCollModDetailsWrapper AutomobileCollModDetails;

        /*public String ExternalLocalDateText;
        public String ExternalTaskCode;
        public String ValidationFlag;
        public String CollateralCurrency;
        public String DocumentCode;
        public CollModDetailsWrapper CollModDetails;
        public CollDeedModDetailsWrapper CollDeedModDetails;
        public FinancialCollModDetailsWrapper FinancialCollModDetails;
        public GoldCollModDetailsWrapper GoldCollModDetails;
        public GuaranteeCollModDetailsWrapper GuaranteeCollModDetails;
        public HeaderModDetailsWrapper HeaderModDetails;
        public InsuranceCollModDetailsWrapper InsuranceCollModDetails;
        public NonStandardCollModDetailsWrapper NonStandardCollModDetails;
        public PropertyCollModDetailsWrapper PropertyCollModDetails;*/
    }

    public class ReportingParamWrapper{
        public String MISClass;
        public String MISCode;
    }

    public class ValuationModDetailsWrapper{
        public String LastCollateralValue;
        public String LastValuationDate;
        public String MarketCollateralValue;
        /*public String OriginalCollateralValue;
        public String OriginalValuationDate;
        public String ValuationEdition;
        public String ValuationSource;
        public String ValuationSupplement;
        public String FloatingCollateral;*/
    }

    public class CollateralModificationResponseWrapper{
        @AuraEnabled public String PostingDate{get;set;}
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
        @AuraEnabled public List<ValidationErrorsWrapper> ValidationErrors{get;set;}
        
    }

    public class ValidationErrorsWrapper{
        @AuraEnabled public String AttributeName{get;set;}
        @AuraEnabled public String AttributeValue{get;set;}
        @AuraEnabled public String ErrorCode{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }

    public class MessagesWrapper{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
    }

    public class AutomobileCollModDetailsWrapper{
        public String AutomobileDescription1;
        public String AutomobileDescription2;
        public String ChassisNumber;
        public String EngineNumber;
        public String ManufactureYearMonth;
        public String ModelName;
        public String RegistrationNumber;
    }


    /*public class CollModDetailsWrapper{
        public String AsnAccount;
        public String DateOfDividend;
        public String FifthCertificateNumber;
        public String FirstCertificateNumber;
        public String FourthCertificateNumber;
        public String SecondCertificateNumber;
        public String ThirdCertificateNumber;
        public String TotalNumberOfUnits;
    }



    public class CollDeedModDetailsWrapper{
        public String DateDeedsSent;
        public String DeedDetails;
        public String ExpectedReturnDate;
        public String NameOfCustodian;
        public String RegisteringAuthority;
        public String StatusOfDeed;
    }

    public class FinancialCollModDetailsWrapper{
        public String FinancialSecurityCode;
        public String SeriesNumberOne;
        public String SeriesNumberTwo;
        public String UnitsOfSecurities;
    }

    public class GoldCollModDetailsWrapper{
        public List<GoldCollDetailsWrapper> GoldCollDetails;
    }

    public class GoldCollDetailsWrapper{
        public String GrossWeight;
        public String Karat;
        public String MarketValue;
        public String NetWeight;
        public String NoOfUnits;
        public String OrnaDesc;
        public String OrnamentType;
        public String OtherDtls;
        public String ValAmount;
        public String ValuatorCode;
    }

    public class GuaranteeCollModDetailsWrapper{
        public String CustomerId;
        public String FromDate;
        public String GuaStatus;
        public String Remarks;
        public String ToDate;
    }

    public class HeaderModDetailsWrapper{
        public String AssetClass;
        public String Make;
        public String Model;
        public String NameofLender;
        public String TypeOfCharge;
    }

    public class InsuranceCollModDetailsWrapper{
        public String InsurancePlanCode;
        public String InsurancePolicyNumber;
    }

    public class NonStandardCollModDetailsWrapper{
        public String InvoiceNo;
        public String MachineNo;
        public String Machinery;
        public String ManufacturerName;
        public String NonStandardCollateralId;
        public String PrimaryDescription;
        public String SecondaryDescription;
    }

    public class PropertyCollModDetailsWrapper{
        public String AreaUnit;
        public String DateOfLeaseExpiry;
        public String District;
        public String ForcedSaleValue;
        public String HouseFlatShopNo;
        public String KhasraPlotNo;
        public String Location;
        public String OwnerName;
        public String PropertyDescription1;
        public String PropertyDescription2;
        public String QuitRentValue;
        public String TehsilTaluka;
        public String TotalArea;
        public String TownCity;
        public String TypeOfProperty;
        public String Village;
    }*/

    
}