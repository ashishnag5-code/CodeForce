public class CustomerEnquiryIntegrationHandler implements IntegrationHandlerInterface {
	public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        if(reqParam instanceof Applicant__c){
            Applicant__c paramsMap=(Applicant__c)reqParam;
            system.debug('%% '+paramsMap);
            CustomerEnquiryRequestWrapper objCustomerEnquiryRequestWrapper = new CustomerEnquiryRequestWrapper();
            objCustomerEnquiryRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
            objCustomerEnquiryRequestWrapper.OriginatingChannel = Label.AUSFCollateralChannel;
            objCustomerEnquiryRequestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
            objCustomerEnquiryRequestWrapper.TransactionBranch = Label.AUSF_Dedupe_Search_Branch;
            if(paramsMap.CIF_No__c != null && paramsMap.CIF_No__c != ''){
                objCustomerEnquiryRequestWrapper.CustomerId = paramsMap.CIF_No__c;
            }
            else{
                System.debug('Customer Id is not present on applicant');
            }
            lstString.add(JSON.serialize(objCustomerEnquiryRequestWrapper));   
        }
        return lstString;
    }
    
    public static CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper mapSearchIntWraptoUIWrap(CollateralCustomerEnquiryResponseWrapper objDedupeSearchWrapper, Applicant__c objApplicant){
        CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper objleadCBSDedupeWrapper = new CustomerEnquiryWrapper.CustomerCollateralEnquiryWrapper();
        objleadCBSDedupeWrapper.collateralList = new list<CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper>();
        system.debug('%%% '+objApplicant);
        list<String> existingIds = getCBSCollateralIds(objApplicant.Loan__c);
        Integer rowIndex = 0;
        //List<LeadDedupeWrapper.CustomerWrapper> lstCustomerWrapper = new List<LeadDedupeWrapper.CustomerWrapper>();
        CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper objCustomerWrapper;
        if(objDedupeSearchWrapper != null){
            for(CollateralCustomerEnquiryResponseWrapper.cls_CollateralDetails objCustomer : objDedupeSearchWrapper.CollateralDetails){
                objCustomerWrapper = new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper();
                objCustomerWrapper.strCollateralId = objCustomer.CollateralId;
                objCustomerWrapper.strCollateralName = objCustomer.CollateralName;
                objCustomerWrapper.strCollateralCode = objCustomer.CollateralCode; //R2 ADDED FOR FLEET MAPPING
                objCustomerWrapper.strCollateralType =  objCustomer.CollateralType;
                objCustomerWrapper.strPropertyOwnerName = objCustomer.PropertyOwnerName;
                objCustomerWrapper.strProductNameCode = objCustomer.AssetClass;
                objCustomerWrapper.strAccountNumber = objCustomer.AccountNumber;
                objCustomerWrapper.strTotalCollateralValue = objCustomer.TotalCollateralValue;
                objCustomerWrapper.strAmountCollValueCollCcy = objCustomer.AmountCollValueCollCcy;
                objCustomerWrapper.strApportionedAmount = 1;
				objCustomerWrapper.strPropertyType = objCustomer.PropertyType;
                objCustomerWrapper.strCollateralUnusedValue = objCustomer.CollateralUnusedValue;
                objCustomerWrapper.strLastValuationDate =  objCustomer.LastValuationDate;
                objCustomerWrapper.strTotalArea = objCustomer.TotalArea;
                objCustomerWrapper.strCustomerId = objCustomer.CustomerId;
                objCustomerWrapper.strAccountCustomerRelation = objCustomer.AccountCustomerRelation;
                objCustomerWrapper.strMake = objCustomer.Make;
                objCustomerWrapper.strModel = objCustomer.Model;
                objCustomerWrapper.strLastValue =objCustomer.LastValue;
                objCustomerWrapper.strKhasaraPlotNo =objCustomer.KhasaraPlotNo;
                objCustomerWrapper.strManufactureYear = objCustomer.ManufactureYear;
                objCustomerWrapper.strChassisNumber = objCustomer.ChassisNumber;
                objCustomerWrapper.strEngineNumber =  objCustomer.EngineNumber;
                objCustomerWrapper.strRegistrationNumber = objCustomer.RegistrationNumber;
                objCustomerWrapper.strAddress = objCustomer.PropertyDesc1 +' '+objCustomer.PropertyDesc2;
                objCustomerWrapper.strTehsilTaluka = objCustomer.TehsilTaluka;
                objCustomerWrapper.strVillage = objCustomer.Village;
                objCustomerWrapper.strPropertyDesc1 = objCustomer.PropertyDesc1;
                objCustomerWrapper.strAreaUnit = objCustomer.AreaUnit;
                objCustomerWrapper.strCostPrice = objCustomer.CostPrice;
                objCustomerWrapper.boolIsProprtyView = objCustomer.CollateralName=='Property'?true:false;
                objCustomerWrapper.boolIsAutomobileView = objCustomer.CollateralName=='Automobile'?true:false;
                
                if(existingIds.contains(objCustomer.CollateralId)){
                  objCustomerWrapper.isSelected = true;
                  objCustomerWrapper.isDisabled = true;  
                  objCustomerWrapper.isShowApportioned = true;
                }else{
                  objCustomerWrapper.isSelected = false;
                  objCustomerWrapper.isDisabled = false;  
                  objCustomerWrapper.isShowApportioned = false;
                }
                
                objCustomerWrapper.index = rowIndex;
                objleadCBSDedupeWrapper.collateralList.add(objCustomerWrapper);
                objleadCBSDedupeWrapper.cbsCollateralId = getCBSCollateralId(objApplicant.Loan__c); // SFAU-5773
                rowIndex++;
            }
        }
        return objleadCBSDedupeWrapper;
    }

    // Get CBS Collateral Id ( SFAU-5773 - Added by Kunal )
    private static String getCBSCollateralId(String loanpAppId){
        List<Collateral__c> collateralList = [SELECT Id,Collateral_Id_in_CBS__c FROM Collateral__c where Loan__c=:loanpAppId and Is_Deleted__c=false AND RecordTypeId IN: GlobalConstants.colRecordTypeIds];
        return collateralList.isEmpty() || String.isBlank(collateralList[0].Collateral_Id_in_CBS__c) ? '' : collateralList[0].Collateral_Id_in_CBS__c;
    }
    
    public static List<String> getCBSCollateralIds(String loanpAppId){
        Set<String> setOfCustomerIds = new Set<String>();
        List<String> listOfCustomerIds = new List<String>();
        for(Collateral__c col:[Select Collateral_ID__c from Collateral__c where loan__c=:loanpAppId and Is_Deleted__c=false WITH SECURITY_ENFORCED]){
            if(col.Collateral_ID__c!=null){
                setOfCustomerIds.add(col.Collateral_ID__c);
            }
        }
        listOfCustomerIds.addAll(setOfCustomerIds);
        return listOfCustomerIds;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class CustomerEnquiryRequestWrapper{
        public String ReferenceNumber;
        public String RequestId;
        public String OriginatingChannel;
        public String TransactionBranch;
        public String CustomerId;
    }
}