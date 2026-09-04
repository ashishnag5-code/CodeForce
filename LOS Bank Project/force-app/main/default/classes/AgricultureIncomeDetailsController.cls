public with sharing class AgricultureIncomeDetailsController {

    @AuraEnabled
    public static List<Scale_of_Finance__c> getCropsDetails(Id applicantId){
        List<Scale_of_Finance__c> scaleOfFinanceList = new List<Scale_of_Finance__c>();
        system.debug(applicantId);
        //Get the Loan Record Type 
        String addressType;
        Applicant__c applicantInstance = [SELECT id,Name,Loan__r.RecordType.Name,Customer_Type__c FROM Applicant__c WHERE id=:applicantId];
        // If Tractor and Individual Applicant Address will be from Land other wise Current 
        if(applicantInstance.Loan__r.RecordType.Name == 'Tractor' && applicantInstance.Customer_Type__c == 'Individual') {
            addressType = 'Land';
        }else{
            addressType = 'Current';
        }
        Address__c applicantAddress = [SELECT State__c, District__c, Applicant__c FROM ADDRESS__c where Applicant__r.id = :applicantId AND Address_Type__c =:addressType AND Source_Type__c=null
        with SECURITY_ENFORCED order by CreatedDate desc LIMIT 1];
        scaleOfFinanceList = [SELECT Name, Crop__c, ew_Market_Price_Quintal__c, Sowing_Month__c, 
                                    Harvest_Month__c, New_Yield__c, State__c, Location__c, New_Coc_Acres__c
                                    FROM Scale_of_Finance__c where  
                                    State__c = :applicantAddress.State__c AND 
                                    Location__c = :applicantAddress.District__c AND 
                                    RecordType.Name = :GlobalConstants.OWNLAND_RCL_RECORDTYPE_NAME with SECURITY_ENFORCED];
        
        return scaleOfFinanceList;
    }

    @AuraEnabled
    public static List<Scale_of_Finance__c> getIncomeSource(String incomeType){
        List<Scale_of_Finance__c> scaleOfFinanceList = new List<Scale_of_Finance__c>();
        scaleOfFinanceList = [SELECT Name, Income_Source__c, Unit__c, Annual_Income_Unit_Rs__c
                                    FROM Scale_of_Finance__c where  
                                    Type_of_Income__c = :incomeType AND 
                                    RecordType.Name = :GlobalConstants.COMMERCIAL_RECORDTYPE_NAME with SECURITY_ENFORCED];
        
        return scaleOfFinanceList;
    }

    /*@AuraEnabled
    public static Decimal calculateTotals(Id recordId, String type){
        List<Applicant_Financials_Details__c> records = [SELECT Id, Net_Revenue__c, Total_Net_Income__c, Monthly_Total_Income__c, Monthly_Income__c, First_Month__c, Second_Month__c, Third_Month__c,
                                                        RecordType.name, RecordType.DeveloperName, Net_Annual_Income__c, Monthly_Net_Income__c,Monthly_Turnover__c,Monthly_Net_Profit__c
                                                        from Applicant_Financials_Details__c where 
                                                        Applicant_Financials__c=:recordId and RecordType.DeveloperName=:type and isActive__c=true];
                                                        
        Decimal totalMonthlyIncome=0;
        for(Applicant_Financials_Details__c afd: records){
            if(type == 'Farmer_Commercial'){
                totalMonthlyIncome = totalMonthlyIncome + afd.Net_Annual_Income__c;
            }
            if(type == 'Farmer_Dairy_Business'){
                totalMonthlyIncome = totalMonthlyIncome + afd.Total_Net_Income__c;
            }
            if(type == 'Farmer_Agriculture_Own_Land'){
                totalMonthlyIncome = totalMonthlyIncome + afd.Net_Revenue__c;
            }
            if(type == 'Farmer_Agriculture_Rented_Land'){
                totalMonthlyIncome = totalMonthlyIncome + afd.Net_Revenue__c;
            }
        }
        return totalMonthlyIncome;

    }*/

    @AuraEnabled
    public static incomeWrapper getParentFinancialRecord(Id recordId){ //JUL 20 

        List<Applicant_Financials_Details__c> records = [SELECT Id, Monthly_Total_Income__c, Total_Net_Income__c, Any_Other_Income__c, Any_Other_Expense__c, Monthly_Income__c, First_Month__c, Second_Month__c, Third_Month__c,Net_Revenue__c,Method_Of_Assesment__c,
                                                        RecordType.name, RecordType.DeveloperName, Net_Annual_Income__c, Monthly_Net_Income__c,Monthly_Turnover__c,Monthly_Net_Profit__c,Salary_Received_in_Cash__c,Salary_Received_in_Bank__c
                                                        from Applicant_Financials_Details__c where 
                                                        Applicant_Financials__c=:recordId and isActive__c=true with SECURITY_ENFORCED];

     System.debug('records-->' +records);
        
        Decimal totalMonthlyIncome=0;
        incomeWrapper wrapperInstance = new incomeWrapper();
        Decimal documentedIncome=0;
        Decimal assessedIncome=0;
        for(Applicant_Financials_Details__c afd: records){
            if(afd.RecordType.DeveloperName == 'Salaried_Document'){
                Decimal FirstMonth = afd.First_Month__c!=null ? afd.First_Month__c : 0;
                Decimal SecondMonth = afd.Second_Month__c!=null ? afd.Second_Month__c : 0;
                Decimal ThirdMonth = afd.Third_Month__c!=null ? afd.Third_Month__c : 0;

                //totalMonthlyIncome = totalMonthlyIncome + ((afd.First_Month__c + afd.Second_Month__c+ afd.Third_Month__c)/3);
                totalMonthlyIncome = totalMonthlyIncome + ((FirstMonth + SecondMonth + ThirdMonth )/3);
                documentedIncome = afd.Salary_Received_in_Bank__c;
                if(afd.Salary_Received_in_Cash__c!=null){
                     assessedIncome = afd.Salary_Received_in_Cash__c;
				}
               
            }
            if(afd.RecordType.DeveloperName == 'Other_Income'){
               if(afd.Method_Of_Assesment__c == 'Documented'){
                    documentedIncome = documentedIncome +  afd.Monthly_Income__c;
                }else{
                    assessedIncome = assessedIncome +  afd.Monthly_Income__c;
                }
            }
            if(afd.RecordType.DeveloperName == 'Documented_With_Audited_financial'){
                totalMonthlyIncome = totalMonthlyIncome + afd.Monthly_Total_Income__c;
                documentedIncome = documentedIncome + afd.Monthly_Total_Income__c;
            }
            if(afd.RecordType.DeveloperName == 'Farmer_Dairy_Business'){
                //totalMonthlyIncome = totalMonthlyIncome + ((afd.Monthly_Net_Income__c+afd.Any_Other_Income__c)-afd.Any_Other_Expense__c);
                totalMonthlyIncome = totalMonthlyIncome+afd.Total_Net_Income__c;
                assessedIncome = assessedIncome + afd.Total_Net_Income__c;
            }
            if(afd.RecordType.DeveloperName == 'Farmer_Commercial'){
                totalMonthlyIncome = totalMonthlyIncome + (afd.Net_Annual_Income__c/12);
                assessedIncome = assessedIncome + afd.Net_Annual_Income__c;
            }
            if(afd.RecordType.DeveloperName == 'Assessed_No_Document'){
                //totalMonthlyIncome= totalMonthlyIncome + (afd.Monthly_Turnover__c)!=null?afd.Monthly_Turnover__c :0;
                totalMonthlyIncome= totalMonthlyIncome + afd.Monthly_Turnover__c;
                assessedIncome = assessedIncome + afd.Monthly_Turnover__c;
            }
            /*if(afd.RecordType.DeveloperName == 'Documented_Without_Audited_financial'){ //June30
                totalMonthlyIncome=  totalMonthlyIncome + afd.Monthly_Net_Profit__c;
            }*/
            if(afd.RecordType.DeveloperName == 'Farmer_Agriculture_Own_Land'||afd.RecordType.DeveloperName == 'Farmer_Agriculture_Rented_Land'){
                totalMonthlyIncome = totalMonthlyIncome + (afd.Net_Revenue__c/12);
                assessedIncome = assessedIncome +  (afd.Net_Revenue__c/12);
            }

            
        }
        wrapperInstance.documentedIncome = documentedIncome;
        wrapperInstance.assessedIncome = assessedIncome;

        return wrapperInstance;
    }

    @AuraEnabled
    public static void markRecordsInactive(Id afd){
        try{
            Applicant_Financials_Details__c record = [SELECT Id, isActive__c from Applicant_Financials_Details__c where id=:afd with SECURITY_ENFORCED LIMIT 1 ];
            record.isActive__c = false;
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable()){
                update record;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
     @AuraEnabled
    public static void deleteFinancialRecords(Id afd){
        try{
            Applicant_Financials_Details__c record = [SELECT Id, isActive__c from Applicant_Financials_Details__c where id=:afd with SECURITY_ENFORCED LIMIT 1 ];
           
            if(Schema.sObjectType.Applicant_Financials_Details__c.isDeletable()){
                delete record;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
     /*
    @description :  Method to show delete icon for RO in QDE And DDE Stage and Credit User for Credit Stage (Applicable for All products)
    @param :  String LoanId
    @return : Boolean
*/

    @AuraEnabled
    public static Boolean renderDeleteAction(String recordId){
        try {
            Boolean result;
            if(String.isNotBlank(recordId)){
                 // Get Loan Stage
            Loan_Application__c loanInstance = [SELECT id,Stage__c 
                                                FROM Loan_Application__c
                                                WHERE id=:recordId];

            // Get User Profile Details
            User userInstance = [SELECT Id,Name,Profile.Name 
                                 FROM User 
                                 WHERE Id =:UserInfo.getUserId()];
            if(userInstance.Profile.Name == 'System Administrator'){
                result= true;
            } else if(userInstance.Profile.Name == 'Sales' && ( loanInstance.Stage__c == 'QDE' || loanInstance.Stage__c == 'DDE'  )){
                result= true;
            }else if(userInstance.Profile.Name == 'Credit Manager' && ( loanInstance.Stage__c == 'Credit' )){
                result= true;
            }else{
                result= false;
            }
            }

            return result;
        } catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
            return false;
        }
     
    }


    @AuraEnabled
    public static Applicant_Financials_Details__c upsertIncome(Applicant_Financials_Details__c record){
        try {
            if(Schema.sObjectType.Applicant_Financials_Details__c.isUpdateable() && Schema.sObjectType.Applicant_Financials_Details__c.isCreateable()){
                upsert record;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return record;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getVisibleFieldsForLoanDetails(String strScreen, String strStage, String strProfile){
        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile);    
        return visibleFields;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getVisibleFieldsForFinancials(String strScreen, String strStage, String strProfile, String loanId, String customerType){
        List<Loan_Application__c> loanApps = [SELECT Id, RecordType.Name FROM Loan_Application__c WHERE Id=:loanId WITH SECURITY_ENFORCED];
        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile, loanApps[0].RecordType.Name, customerType);    
        return visibleFields;
    }


    public class incomeWrapper{
        @AuraEnabled  public Decimal documentedIncome;
        @AuraEnabled public Decimal assessedIncome;

        public incomeWrapper(){
            documentedIncome=0;
            assessedIncome = 0;
        }
    }

}