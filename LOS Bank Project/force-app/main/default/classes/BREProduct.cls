/*****
* Class Name: BREProduct
* Test Class: 
* Description: Wrapper Class to create BREProduct Payload
* Logs:
*  Last Modified by        -   Last Modified Date  -   Bug/Description
*  Mohit M.                -   Nov-09-2023         -   SFAU-5482 - CUG II SFDC II BRE tags Missing for STP
*/
public class BREProduct {
    public String productType;  //TW_NEW
    public String productCode;  //11703
    public String subProductType;   //BIKE
    public String schemeId = ''; // Optional    //schemeId0
    // public String loanPurpose;   //BUY
    public String loanType; //NEW
    // public String natureOfLoan; // Optional  //BUY
    // public String emiFrequency; // Optional  //12
    // public String scheduleType; // Optional  //12
    public Double requestedLoanAmount = 0;  //100000
    public Double requestedInstallmentAmount = 0;   //5000
    public Integer requestedTenor = 0;  //24
    public Double requestedROI = 0; //10
    public Double roiAsPerMaster = 0; // newly added
    public Double requestedPF = 0; // newly added
    public String rateType; // Optional //VARIABLE
    // public Double noOfTopUp; // Optional //0
    public cls_dealerDetails dealerDetails = new cls_dealerDetails();
    public cls_sourcingDetails sourcingDetails = new cls_sourcingDetails();
    public cls_triggerDetails triggerDetails = new cls_triggerDetails();
    public Double existingWheelExposure; // Optional - Temp Comment //0
    public Double existingTWExposure; // Optional - Temp Comment    //0
    public Double existingTotalExposure; // Optional - Temp Comment //0
    public Double existingGroupExposure; // Optional - Temp Comment //0
    public Double totalExposure;
    public Double apportionedLoanAmount;
    public Integer noOfUnits=0;
    public string deliveryDate {get;set;} 
    public String instalmentFreq {get; set;} 
    public String linkedAccountNumberForTopUp = '';
    
    public cls_vehicleDetails vehicleDetails = new cls_vehicleDetails();
    public cls_ImplementDetails ImplementDetails = new cls_ImplementDetails();
    public cls_AttachmentDetails AttachmentDetails = new  cls_AttachmentDetails();
    //public cls_fleetDetails fleetDetails = new cls_fleetDetails();
    public Boolean isTopUp = false; // SFAU-5157 - Branch Top Up
    
    public class cls_dealerDetails {
        public String dealerName;   //dealerName0
        public String outletName;   //outlet name
        public String dealerCode;   //dealerCode0
        public String dealerCategory;   //FOCUSED
        public String dealerClass;  //WITH_RC_LIMIT
        public String dealerState;  //RAJASTHAN
        public String dealerCity;   //JAIPUR
        public double dealerRackRate=0;
        public boolean isDealerEligibleForFIBased=false;
    }
    public class cls_ImplementDetails {
        
        public String implementType;
        public String make;
        public string model;
        public string variant;
        public string  implementCategory;
        public boolean isImplementDeliveryStatus;
        public Double exShowroomPrice=0;
        public Double discount=0;
        public Double netOfDiscountPrice=0;
        public Double ltvOnImplement=0;
        
    }
    public class cls_AttachmentDetails {
        
        public string attachmentType;
        public String make;
        public String model;
        public String variant;
        public String attachmentCategory;
        public Double exShowroomPrice=0;
        public Double discount=0;
        public Double netOfDiscountPrice=0;
        public double ltvOnAttachment=0;
        
    }
    public class cls_sourcingDetails {
        public String sourcingChannel = ''; //DEALER
        // public String sourceName; // Optional    //dealerName0
        // public String sourceCode; // Optional    //dealerCode0
        public String sourcingCategory = ''; // Optional    //FOCUSED
        public String sourcingClass = ''; // Optional   //WITH_RC_LIMIT
    }
    public class cls_triggerDetails {
        public String roTriggerType {get;set;}
        public String branchTriggerType {get;set;}
        public String dealerTriggerType {get;set;}
        public String sourcingTriggerType {get;set;}
        public String roTriggerLevel {get;set;}
        public String branchTriggerLevel {get;set;}
        public String dealerTriggerLevel {get;set;}
        public String sourcingTriggerLevel {get;set;}
    }
    public class cls_vehicleDetails {
        public String make = '';    //JAWA
        public String model = '';   //110
        public String variant = ''; //variant0
        public String vehicleColour = '';   //BLUE
        public String fuelType = '';    //DIESEL
        public String vehicleCategory = ''; // Optional;    //A
        public String vehicleUsage = '';    //PERSONAL
        public Integer manufactureMonth;
        public Integer manufactureYear;
        public String engineCategory = '';  //BS4
        public Double ltvExShowroom = 0; // Optional    //90
        public Double ltvOnRoad = 0; // Optional    //80
        public Double ltvOnFinalCost = 0; //Optional    //70
        public String HPNFinanciersName = ''; // Optional   //HPNFinanciersName0
        public String currentOwnerName = ''; // Optional    //currentOwnerName0
        public String ownerSerialNumber = ''; // Optional   //123247239497234
        public String registrationCity = ''; // Optional    //DELHI
        public boolean isBlackListed = false; // Optional
        public Double challanOverdueAmount = 0;
        public boolean isLuxaryVehicle = false; // Optional
        public Double maxLTV = 0; // Optional
        public Double ltvOnVehicleCost; // Optional
        public boolean isAccessoriesFunding = false;
        public boolean isRegisterable=false;
        public String bodyLinkedWith { get; set; }
        public Double kmMeterReading = 0;
        public Double hoursMeterReading=0;
        public Integer horsePower=0;
        public string chassisType { get; set; }
        public String bodyType { get; set; }
        public cls_newVehicleCostDetails newVehicleCostDetails = new cls_newVehicleCostDetails();
        public cls_otherFundingItemsDetails otherFundingItemsDetails = new cls_otherFundingItemsDetails();
        public cls_usedVehicleCostDetails usedVehicleCostDetails = new cls_usedVehicleCostDetails();
        //SFAU-5482
        public boolean isVahanDataFetched = false;
        public double maxFundingCap=0.0;
        public boolean isVehicleDelivered=false;
        public boolean isTARSubmitted=false;
        public double bodyCost=0;
        public double ltvOfferedOnBody=0;
     
   /*
        public boolean isFieldNullorEmpty() {
            
            if (bodyLinkedWith != null && bodyLinkedWith != '') {
                return true;
            }
            if (chassisType != null && chassisType != '') {
                 return true;
            }
            if (bodyType != null && bodyType !='') {
                 return true;
            }
            
            return false;
        }*/
    }
    public class cls_newVehicleCostDetails {
        public Double exShowroomPrice = 0;  //100000
        public Double discount = 0; //10000
        public Double netOfDiscountPrice = 0;   //90000
        public Double priceVariance = 0;    //10000
        public Double insurance = 0;    //100000
        public Double rtoTaxes = 0; //0
        public Double assecessories = 0;    //0
        public Double otherCosts = 0;   //0
        public Double onRoadPrice = 0;  //0
        public Double finalCost = 0;    //100000
        public Double fairMarketValue=0;
        public Double costToBeConsidered=0;
        public String assessmentMethod='';
        public Double approvedCustomerEquity = 0;
        public Double absoloutAmount=0;
    }
    public class cls_otherFundingItemsDetails {
        public Double insuranceAmount = 0;  //100000
        public Double rtoAmount = 0;    //0
        public Double assecessoriesAmount = 0;  //0
        public Double otherCosts = 0; // Optional
        public Double lsAmount = 0; //0
        public Double apportionedLoanAmount = 0;    //0
    }
    public class cls_usedVehicleCostDetails{
        public Double certifiedValue = 0;
        public Double ibb = 0;
        public Double valuationAmount = 0;
        public Double idv = 0;
        public Double insurance = 0;
        public Date insuranceExpiryDate = NULL;
        public Double vehicleCost = 0;
        public Double finalCost = 0;
        public String vehicleRegistrationState = '';
        public String vehicleRegistrationCity = '';
        public Date rcExpiryDate = NULL;
        public Integer vehicleAgeAtEndOfTenor = 0;
        public Double otherCosts = 0;
        public boolean isRepoFundingAllowed=false;
        public String valuationRemarks=null;
        public boolean isRepoSoldVehicle=false;
        //public Double ltvOnVehicleCost = 0; // As per - SFAU-4429
    }
    
}