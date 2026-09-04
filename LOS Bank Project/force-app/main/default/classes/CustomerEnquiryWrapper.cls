public class CustomerEnquiryWrapper {

    public class CustomerCollateralEnquiryWrapper{
        @AuraEnabled public list<CustomerEnquiryDetailWrapper> collateralList{get;set;}
        @AuraEnabled public String cbsCollateralId{get;set;} // SFAU-5773
        public CustomerCollateralEnquiryWrapper(){
            collateralList = new list<CustomerEnquiryDetailWrapper>();
        }
    }
    
    public class CustomerEnquiryListWrapper{
        @AuraEnabled public String strCollateralId {get;set;}
        @AuraEnabled public String strCollateralName {get;set;}
        @AuraEnabled public String strProductNameCode{get;set;}//AU Mapping is pending
        @AuraEnabled public String strCollateralType{get;set;}
        @AuraEnabled public String strPropertyOwnerName{get;set;}
        @AuraEnabled public String strCustomerId{get;set;}
        @AuraEnabled public String strAccountNumber{get;set;}
        @AuraEnabled public String strAccountCustomerRelation{get;set;}
        @AuraEnabled public String strTotalCollateralValue{get;set;}
    }
    
    public class CustomerEnquiryDetailWrapper{
        @AuraEnabled public String strCollateralId  {get;set;}
        @AuraEnabled public String strCollateralName {get;set;}
        @AuraEnabled public String strCollateralCode {get;set;} //R2 FLEET MAPPING
        @AuraEnabled public String strCollateralType {get;set;}
        @AuraEnabled public String strPropertyOwnerName {get;set;}
        @AuraEnabled public String strProductNameCode{get;set;}
        @AuraEnabled public String strAccountNumber {get;set;}
        @AuraEnabled public Integer strTotalCollateralValue{get;set;}
        @AuraEnabled public Integer strAmountCollValueCollCcy{get;set;}
        @AuraEnabled public Integer strApportionedAmount{get;set;}
        @AuraEnabled public String strPropertyType{get;set;}
        @AuraEnabled public Integer strCollateralUnusedValue{get;set;}
        @AuraEnabled public String strLastValuationDate{get;set;}
        @AuraEnabled public Integer strTotalArea{get;set;}
        @AuraEnabled public String strCustomerId{get;set;}
        @AuraEnabled public String strAccountCustomerRelation{get;set;}
        @AuraEnabled public String strMake{get;set;}
        @AuraEnabled public String strModel{get;set;}
        @AuraEnabled public String strManufactureYear{get;set;} //AU Mapping is pending
        @AuraEnabled public String strChassisNumber{get;set;}
        @AuraEnabled public String strEngineNumber{get;set;}
        @AuraEnabled public String strRegistrationNumber{get;set;}
        @AuraEnabled public String strAddress{get;set;}
        @AuraEnabled public String strTehsilTaluka{get;set;}
        @AuraEnabled public String strVillage{get;set;}
        @AuraEnabled public String strPropertyDesc1{get;set;}
        @AuraEnabled public String strAreaUnit{get;set;}
        @AuraEnabled public String strKhasaraPlotNo{get;set;}
        @AuraEnabled public Integer strCostPrice{get;set;}
        @AuraEnabled public Integer strLastValue{get;set;}
        @AuraEnabled public Boolean boolIsProprtyView{get;set;}
        @AuraEnabled public Boolean boolIsAutomobileView{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isShowApportioned{get;set;}
        @AuraEnabled public Boolean isDisabled{get;set;}
        @AuraEnabled public Integer index;
    }
}