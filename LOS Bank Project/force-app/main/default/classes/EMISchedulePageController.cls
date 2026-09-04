public without sharing class EMISchedulePageController {

    public static EMIScheduleAPIHandler.EMIScheduleResponseWrapper response;
    public static String recordId{get;set;}
    public static Boolean displayField{get;set;}

    public EMISchedulePageController(){
        system.debug('recordId ');
        recordId = ApexPages.currentPage().getParameters().get('id');      
        system.debug('recordId '+recordId);
  
    }

    public static List<EMIScheduleAPIHandler.ResponseWrapper> getResponse() {
        List<EMIScheduleAPIHandler.ResponseWrapper> responseList=new List<EMIScheduleAPIHandler.ResponseWrapper>();
        Integration_Checklist__c ic = [SELECT ID, Loan_Application__c, Response__c, Integration_Master__r.Name FROM 
            Integration_Checklist__c WHERE Id= :recordId WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc];
        system.debug('ic '+ic);
        if(ic!=null){
            if(ic.Integration_Master__r.Name == 'Disbursement Schedule'){
                EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper response=(EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper) JSON.deserialize(ic.Response__c,EMIScheduleAPIHandler.RepaymentScheduleResponseWrapper.class);
                responseList = response.RepaymentRecords;
                displayField = false;
            }
            if(ic.Integration_Master__r.Name == 'EMI Schedule'){
                EMIScheduleAPIHandler.EMIScheduleResponseWrapper response=(EMIScheduleAPIHandler.EMIScheduleResponseWrapper) JSON.deserialize(ic.Response__c,EMIScheduleAPIHandler.EMIScheduleResponseWrapper.class);
                responseList = response.Response;
                displayField = true;
            }
            system.debug('responseList '+responseList);
            for(EMIScheduleAPIHandler.ResponseWrapper wrap: responseList){
                if(ic.Integration_Master__r.Name == 'EMI Schedule'){
                    wrap.InstallmentStartDate = getFormattedDate(wrap.InstallmentStartDate);
                    wrap.InstallmentDate = getFormattedDate(wrap.InstallmentDate);
                }
                wrap.InterestRate= getTruncatedValue(wrap.InterestRate,2);
                wrap.PrincipalAmount=Integer.valueOf(wrap.PrincipalAmount);
                wrap.InterestAmount=Integer.valueOf(wrap.InterestAmount);
                //wrap.SubsidyAmount=wrap.SubsidyAmount.setScale(2);
                //wrap.PremiumAmount=wrap.PremiumAmount.setScale(2);
                //wrap.ServiceChargeAmount=wrap.ServiceChargeAmount.setScale(2);
                //wrap.CapitalizedAmount=wrap.CapitalizedAmount.setScale(2);
                wrap.InstallmentAmount=Integer.valueOf(wrap.InstallmentAmount);
                wrap.PrincipalBalanceAmount=Integer.valueOf(wrap.PrincipalBalanceAmount);
                if(ic.Integration_Master__r.Name == 'EMI Schedule'){
                    wrap.TotalInstallmentAmount=Integer.valueOf(wrap.TotalInstallmentAmount);
                }
            }
        }
        return responseList;
    }

    public static Decimal getTruncatedValue(Decimal value, Integer decimalPlaces){
        String numToStringValue = String.valueOf(value);
        String truncatedValue;
        Decimal finalValue;
        if(numToStringValue.contains('.')){
            Integer digitsAfterDecimal = numToStringValue.subString(numToStringValue.indexOf('.'),numToStringValue.length()-1).length();
            if(digitsAfterDecimal>decimalPlaces){
            truncatedValue = numToStringValue.subString(0,numToStringValue.indexOf('.')+decimalPlaces+2);
            truncatedValue = String.valueOf( Decimal.valueOf(truncatedValue).setScale(decimalPlaces) );
            }
            if(digitsAfterDecimal==2){
                truncatedValue = numToStringValue;
            }
            if(digitsAfterDecimal==1){
                truncatedValue = numToStringValue+'0';
            }
            finalValue = Decimal.valueOf(truncatedValue);
        }else{
            finalValue=value.setScale(2);
        }
        return finalValue;
    }

    public static String getFormattedDate(String wrapperDate){
        String formattedDate = wrapperDate.subString(6,8)+'-'+wrapperDate.subString(4,6)+'-'+wrapperDate.subString(0,4);
        return formattedDate;
    }
}