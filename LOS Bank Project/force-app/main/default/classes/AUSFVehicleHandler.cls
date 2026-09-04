/*****
 * Class Name: AUSFVehicleHandler
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-06-2023          -   Mohit M.            -   HotFix - Update Collateral Collateral_Code_in_CBS__c
 * Dec-08-2023          -   Mohit M.            -   SFAU-5665 - POS Update - Collateral Linkage
 * Jan-01-2024          -   Mohit M.            -   R2-2547 - Collateral Name
 */
public class AUSFVehicleHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        system.debug('reqParam >> '+reqParam);
        Collateral__c reqParam1 =(Collateral__c)reqParam;
        List<String> lstString = new List<String>();
        
        //if(reqParam instanceof String){
        CollateralSearchRequestWrapper requestWrapper = new CollateralSearchRequestWrapper();
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.OriginatingChannel = Label.AUSFCollateralChannel;
        requestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
        requestWrapper.TransactionBranch = Integer.valueOf(Label.AUSF_Dedupe_Search_Branch);
        cls_CollateralDedupe collateralDedupe = new cls_CollateralDedupe();
        collateralDedupe.CollateralType ='2';
        collateralDedupe.ChassisNumber =reqParam1.Chasis_Number__c;
        collateralDedupe.EngineNumber =reqParam1.Engine_Number__c;
        collateralDedupe.RegistrationNo = reqParam1.Vehicle_Number__c;
        collateralDedupe.AccountDepositNumber = '';
        collateralDedupe.AddressSearch ='';
        collateralDedupe.InsurancePolicyNumber='';
        requestWrapper.CollateralDedupe = collateralDedupe;
        lstString.add(JSON.serialize(requestWrapper));  
        //}
        return lstString;
    }
     //CANDOLEAD/GENNEWLEAD REQUEST
    public static List<String> generateLeadRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        LeadRequestWrapper requestWrapper = new LeadRequestWrapper();
        requestWrapper.requestId = String.valueOf(paramsMap.get('requestId'));
        requestWrapper.channel = String.valueOf(paramsMap.get('channel'));
        requestWrapper.vehicle_cat = Integer.valueof(paramsMap.get('vehicle_cat'));
        requestWrapper.cus_veh_regno = String.valueOf(paramsMap.get('cus_veh_regno'));
        requestWrapper.cus_name = String.valueOf(paramsMap.get('cus_name'));
        requestWrapper.cus_mobile = String.valueOf(paramsMap.get('cus_mobile'));
        requestWrapper.cus_pincode = String.valueOf(paramsMap.get('cus_pincode'));
        requestWrapper.cus_address = String.valueOf(paramsMap.get('cus_address'));
        requestWrapper.executive_name = String.valueOf(paramsMap.get('executive_name'));
        requestWrapper.executive_mobile = String.valueOf(paramsMap.get('executive_mobile'));
        requestWrapper.cus_email = String.valueOf(paramsMap.get('cus_email'));
        requestWrapper.veh_mmv = String.valueOf(paramsMap.get('veh_mmv'));
        requestWrapper.prospect_no = String.valueOf(paramsMap.get('prospect_no'));
        requestWrapper.valuator_name = String.valueOf(paramsMap.get('valuator_name'));
        lstString.add(JSON.serialize(requestWrapper));   
        return lstString;
    }
    //END

    // Can do Reject
    public static List<String> generateRejectRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;

        LeadRejectWrapper requestWrapper = new LeadRejectWrapper();
        requestWrapper.requestId = String.valueOf(paramsMap.get('requestId'));
        requestWrapper.channel = String.valueOf(paramsMap.get('channel'));
        requestWrapper.RequestNo = String.valueof(paramsMap.get('RequestNo'));
        requestWrapper.RejectedRemark = String.valueOf(paramsMap.get('RejectedRemark'));
        lstString.add(JSON.serialize(requestWrapper));   
        return lstString;

    }

    //CANDOLEAD/GENNEWLEAD RESPONSE
    public class leadResponse{
        public String Status;
        public String RequestNo;
    }
     //END

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public List<String> validateInputData(List<Object> recordList){
        return null;
    }
    
    public class CollateralSearchRequestWrapper{
        public String ReferenceNumber;  //SFDC91872839712
        public Integer TransactionBranch;   //2011
        public String RequestId;    //SFDC91872839712
        public String OriginatingChannel;   //SFDC
        public cls_CollateralDedupe CollateralDedupe;
    }   
    
    class cls_CollateralDedupe {
        public String CollateralType;   //1
        public String ChassisNumber;    //
        public String EngineNumber; //
        public String RegistrationNo;   //
        public String AccountDepositNumber; //
        public String AddressSearch;    //jaipur
        public String InsurancePolicyNumber;    //
    }
     
    public static List<Collateral__c> mapSearchIntWraptoUIWrap(CollateralDedupeResponseWrapper wrap){
        //CollateralResponseWrapper wrapRes = new CollateralResponseWrapper();
        List<Collateral__c> listOfCollateral = new List<Collateral__c>();
        Collateral__c col ;
        //Integer i=1;
        system.debug('wrap '+wrap);
        for(CollateralDedupeResponseWrapper.CollateralDetails obj:wrap.CollateralDetails){
            col = new Collateral__c(); 
            // R2-2547 - Collateral Name
            // col.Collateral_Name__c =obj.CollateralCode;//obj.CollateralName;
            /* START - MM - Update Collateral Code in CBS from Collateral Code */
            List<String> lstCollaterCodeSplit = String.isNotBlank(obj.CollateralCode) ? obj.CollateralCode.split('-') : new List<String>();
            col.Collateral_Code_in_CBS__c = !lstCollaterCodeSplit.isEmpty() ? lstCollaterCodeSplit[0] : '';
            /* END - MM - Update Collateral Code in CBS from Collateral Code */
            // R2-2547 - Collateral Name
            col.Collateral_Name__c = col.Collateral_Code_in_CBS__c;
            col.Collateral_ID__c = obj.CollateralId;
            col.Collateral_ID_in_CBS__c = obj.CollateralId;
            col.Collateral_Type__c = obj.CollateralType;
            col.Cost__c = Decimal.valueOf(obj.CostPrice);
            col.Insurance_Funding__c ='No';
            col.LS__c ='No';
            col.Vehicle_Number__c = obj.RegistrationNumber;
            // SFAU-5665 - POS Update - Collateral Linkage - Commented - Will come from LOAN OD and Loan Inquiry
            // col.POS__c = String.valueof(obj.CollateralUnusedValue);
            col.Linked_Account_Number__c =obj.AccountNumber;
            col.Total_Collateral_Value__c = Decimal.valueOf(obj.TotalCollateralValue);
            col.Chasis_Number__c = obj.ChassisNumber;
            col.Engine_Number__c = obj.EngineNumber;
            col.Manufacture_year_month__c = obj.ManufactureYear;
            col.Manual_Variant__c = obj.Model;
            col.Manual_Make__c = obj.Make;
            col.Manual_Model__c = obj.ModelName;
            col.Current_Owner_Name__c = obj.PropertyOwnerName;
			
            listOfCollateral.add(col);
            //i++;
        }
        return listOfCollateral;
    }
    
    public class CollateralResponseWrapper{
        @AuraEnabled
        public List<Collateral__c> collaterals;
        @AuraEnabled
        Public String message;
        @AuraEnabled
        Public Integer responseCode;
        @AuraEnabled
        Public String responseMessage;
        
    }

    public class LeadRequestWrapper{
        public String requestId;
        public String channel;
        public Integer vehicle_cat;
        public String cus_veh_regno;
        public String cus_mobile;
        public String cus_name;
        public String cus_pincode;
        public String cus_address;
        public String executive_name;
        public String executive_mobile;
        public String cus_email;
        public String veh_mmv;
        public String prospect_no;
        public String valuator_name;
        public LeadRequestWrapper(){}
    }

    public class LeadRejectWrapper{
        public String requestId;
        public String channel;
        public String RequestNo;
        public String RejectedRemark;
        public LeadRejectWrapper(){}
        
    }
}