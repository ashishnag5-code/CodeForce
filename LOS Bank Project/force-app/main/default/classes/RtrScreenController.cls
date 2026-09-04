public without sharing class RtrScreenController {
    
    @AuraEnabled
    public static List<Picklist_Value_Mapping__mdt> getPicklistOptions(){
        List<Picklist_Value_Mapping__mdt> picklistValues = [select id, picklist_values__c, masterlabel from Picklist_Value_Mapping__mdt WITH SECURITY_ENFORCED];
        return picklistValues;
    }  
    
    @AuraEnabled(cacheable=true)
    public static Result getBankAccountRecords(String appId){
        system.debug('appId----->'+appId);
        Result res = new Result();
        List<Bureau_Results__c> burResList = new List<Bureau_Results__c>();
        List<Bank_Account_Records__c> barList = new List<Bank_Account_Records__c>();
        burResList =  [SELECT Id, 
                       (SELECT Id, Name_of_the_Financier__c,Owenership_Indicator__c , Type_of_Loan__c, Loan_Amount__c, POS__c, ROI__c, No_of_Emi_Paid__c, Tenure__c, Bureau_Results__c,
                        Payment_History_End_Date__c, EMI_Amount__c, RTR_Status__c, Reported_Date__c, EMI_Considered_for_Obligation__c, Remarks__c, RecordType.Name, Loan_Track_Verified_From__c,
                        Average_12_Month_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Highest_Overall_DPD__c,Track_Record__c
                        FROM Bank_Account_Records__r
                        WHERE Is_Enquiry_Type__c = false ORDER BY CreatedDate ASC)
                       FROM Bureau_Results__c
                       WHERE Applicant__c =: appId AND Bureau__c = 'CIBIL'
                       WITH SECURITY_ENFORCED 
                       ORDER BY CreatedDate Desc];
        if(!burResList.isEmpty() && burResList.size() > 0){
            res.burResId = burResList[0].Id;
            if(!burResList[0].Bank_Account_Records__r.isEmpty() && burResList[0].Bank_Account_Records__r.size() > 0){
                Map<String, Estimated_EMI_Amount_Obligtaion__mdt> estimatedAmountObligationsMap = getEstimatedAmountObligationsMap();
                for(Bank_Account_Records__c bar: burResList[0].Bank_Account_Records__r){
                    if(bar.RecordType.Name == 'CIBIL' && bar.EMI_Amount__c == null && String.isNotBlank(bar.Type_of_Loan__c) && bar.Loan_Amount__c != null){
                        if(estimatedAmountObligationsMap.containsKey(bar.Type_of_Loan__c)){
                            if(bar.ROI__c == null)
                                bar.ROI__c = Decimal.valueOf(estimatedAmountObligationsMap.get(bar.Type_of_Loan__c).ROI__c);
                            if(bar.Tenure__c == null)
                                bar.Tenure__c = estimatedAmountObligationsMap.get(bar.Type_of_Loan__c).Months__c;
                            bar.EMI_Amount__c = getEmiAMount(bar.Loan_Amount__c, bar.ROI__c, bar.Tenure__c);
                        }
                    }
                }
                res.barList = burResList[0].Bank_Account_Records__r;
            }
        }
        return res;
    }
    
    @AuraEnabled
    public static void upsertBankAccountRecords(List<Bank_Account_Records__c> bars, String appId, String burResId) {
        system.debug('bars' + bars);
        if(!bars.isEmpty())
        {
            for(Bank_Account_Records__c bar:bars)
            {
                bar.Applicant__c = appId;
                bar.Bureau_Results__c = burResId;
                bar.RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Manual').getRecordTypeId();
            }
            upsert bars;
            
            
        }
    }
    
    public static Map<String, Estimated_EMI_Amount_Obligtaion__mdt> getEstimatedAmountObligationsMap(){
        Map<String, Estimated_EMI_Amount_Obligtaion__mdt> estimatedAmountObligationsMap = new Map<String, Estimated_EMI_Amount_Obligtaion__mdt>();
        List<Estimated_EMI_Amount_Obligtaion__mdt> eeaoList = [SELECT id, Account_Type__c , Months__c , ROI__c FROM Estimated_EMI_Amount_Obligtaion__mdt WITH SECURITY_ENFORCED];
        for(Estimated_EMI_Amount_Obligtaion__mdt eeao : eeaoList){
            estimatedAmountObligationsMap.put(eeao.Account_Type__c, eeao);
        }
        return estimatedAmountObligationsMap;
    }
    
    public static Decimal getEmiAMount(Decimal loanAmount, Decimal roi, String strloanTenure){
        if(loanAmount != null && roi != null && roi > 0 && strloanTenure != null){
            Decimal loanAmountTotal = Decimal.valueOf(strloanTenure);
            Decimal annualInterestRate = roi;
            Double monthlyInterestRate = annualInterestRate/12;
            Double tenureInMonths = Integer.valueOf(strloanTenure);
            Decimal emiAmount = (loanAmountTotal * monthlyInterestRate * Math.pow((1+monthlyInterestRate), tenureInMonths))/((Math.pow((1+monthlyInterestRate), tenureInMonths))-1);
            return emiAmount;
        }
        else{
            return null;
        }
    }

    // Added by Ashish || for FOIR Changes || START
    @AuraEnabled
    public static void reCalculateFoir(List<String> bankIds){
        List<Bank_Account_Records__c> bankList =[SELECT Id,Name,EMI_Amount__c,Applicant__c, Applicant__r.Loan__c ,EMI_Considered_for_Obligation__c
                                                FROM Bank_Account_Records__c
                                                WHERE Id=:bankIds AND RTR_Status__c != 'Closed' AND Current_Balance__c > 0  ]; // SFAU-5106 (Exclude Closed Bank Records FOIR Calculation) - Kunal 
        Decimal totalEMiAmount = 0;
        Decimal addEMIAmount =0;
        String loanId='';
        if(bankList!=null && bankList.size()>0 && !bankList.isEmpty()){
            for(Bank_Account_Records__c bankInstance : bankList){
                if(bankInstance.EMI_Amount__c!=null && bankInstance.EMI_Amount__c!=0){
                    if(bankInstance.EMI_Considered_for_Obligation__c == 'No'){
                        totalEMiAmount = totalEMiAmount + bankInstance.EMI_Amount__c;
                        loanId = bankInstance.Applicant__r.Loan__c ;
                    }else if(bankInstance.EMI_Considered_for_Obligation__c == 'Yes'){
                        addEMIAmount = addEMIAmount + bankInstance.EMI_Amount__c;
                    }
                }
            }
    
            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id,isActive__c,Applicant__c,Monthly_Obligation__c
                                                                         FROM Applicant_Financials_Details__c 
                                                                         WHERE Applicant__c=:bankList[0].Applicant__c
                                                                         AND  isActive__c=true 
                                                                         AND RecordType.DeveloperName ='Financial_Parent'];
            System.debug('applicantFinancials-->' +applicantFinancials);
            //Reduce the Monthly Obligation from EMI Amount
            if(applicantFinancials!=null && applicantFinancials.size()>0){
                Applicant_Financials_Details__c appFinancials = new Applicant_Financials_Details__c();
                appFinancials.Id = applicantFinancials[0].Id;
                if(applicantFinancials[0].Monthly_Obligation__c!=0 && applicantFinancials[0].Monthly_Obligation__c!=null){
                    Decimal updatedObligation = 0;
                    Decimal monthlyObligation = applicantFinancials[0].Monthly_Obligation__c;
                        updatedObligation =  monthlyObligation +addEMIAmount ;
                        updatedObligation = updatedObligation - totalEMiAmount;
                    
                     appFinancials.Monthly_Obligation__c = updatedObligation;
                     update appFinancials;
                     foirController.getAllApplicantsFoir(loanId);
                }
            }                                                                         
        }
        
    }
    // END

    public Class Result{
        @AuraEnabled public string burResId;
        @AuraEnabled public  List<Bank_Account_Records__c> barList;
    }
    
}