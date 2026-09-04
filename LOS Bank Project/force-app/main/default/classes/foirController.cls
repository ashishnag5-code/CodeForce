public without sharing class foirController {
    
    @AuraEnabled
    public static foirWrapper getAllApplicantsFoir(String loanId){
        List<Applicant__c> applicantList = new List<Applicant__c>();
        Decimal loanExistingFoirPercentage = 0.00;
        /**SFAU-5632 Changes */
        Boolean loanExistingBreReRun = false;
        foirWrapper wrapperInstance = new foirWrapper();
        try {
            applicantList = [SELECT Id,Loan__c,Loan_Stage__c,Customer_Type__c,Loan__r.EMI__c,Loan__r.Total_Verified_Income__c,Total_Monthly_Income__c,Current_Obligation__c,Free_Monthly_Cashflow__c,Loan__r.Loan_Amount__c,FOIR__c,Loan__r.Product__c,Loan__r.Stage__c,RecordType.DeveloperName,RecordType.Name,IsInactive__c
                             FROM Applicant__c
                             WHERE Loan__c=:loanId
                             AND IsInactive__c=false
                             AND  RecordType.DeveloperName !='Additional_Match'  AND RecordType.DeveloperName != 'Nominee' WITH SECURITY_ENFORCED];

            List<Applicant_Financials_Details__c> applicantFinancials = [SELECT Id, Applicant__r.Loan__c, Monthly_Total_Income__c, Monthly_Income__c, First_Month__c, Second_Month__c, Third_Month__c,Annual_Net_Profit__c,Year__c,Filing_Date__c,Annual_Total_Income__c,Annual_Turnover__c,Annual_Expense__c,Monthly_Expense__c,Salary_Received_in_Cash__c,Monthly_Net_Salary__c,Company_Master__c,RecordType.Name
                                                                         FROM Applicant_Financials_Details__c 
                                                                        WHERE  Applicant__r.Loan__c =:loanId AND  isActive__c=true AND RecordType.Name='Documented With Audited financial'  WITH SECURITY_ENFORCED ORDER By Year__c desc];

            List<Loan_Application__c> loanAppList = [
                                                        SELECT 
                                                            Id, 
                                                            Customer_Grade__c,
                                                            Product__c,
                                                            BRE_ReRun_Required__c,
                                                            FOIR_Percentage__c
                                                        FROM
                                                            Loan_Application__c
                                                        WHERE 
                                                            Id =: loanId
                                                        LIMIT 1
                                                    ];
            
            if(loanAppList != NULL && !loanAppList.isEmpty()){
                loanExistingFoirPercentage = loanAppList[0].FOIR_Percentage__c;
                loanExistingBreReRun = loanAppList[0].BRE_ReRun_Required__c;

                wrapperInstance.showCustGrade = false;
                wrapperInstance.isCustGradeEditable = false;
                if( loanAppList[0].Product__c == '10301'
                    ||loanAppList[0].Product__c == '10302'
                    ||loanAppList[0].Product__c == '10303'){
                    wrapperInstance.isTwoWheeler = true;
                    wrapperInstance.showCustGrade = true;
                    wrapperInstance.isCustGradeEditable = true;
                }
                else if(loanAppList[0].Product__c == '10201'
                        ||loanAppList[0].Product__c == '10202'
                        ||loanAppList[0].Product__c == '10203'){
                    wrapperInstance.isFourWheeler = true;
                    wrapperInstance.showCustGrade = true;
                    wrapperInstance.isCustGradeEditable = false;
                }
                else{
                    wrapperInstance.showCustGrade = false;
                }
                wrapperInstance.custGrade = loanAppList[0].Customer_Grade__c;
            }
            Decimal deductMonthlyIncome=0;
            if(!applicantFinancials.isEmpty() && applicantFinancials.size() >=2){
             
                for(integer i=1;i<=applicantFinancials.size()-1;i++){
                    if(applicantFinancials[i].Monthly_Total_Income__c!=null){
                        System.debug('applicantFinancials[i].Monthly_Total_Income__c-->' +applicantFinancials[i].Monthly_Total_Income__c);
                        deductMonthlyIncome = deductMonthlyIncome + applicantFinancials[i].Monthly_Total_Income__c;
                    }
                }
            }
            
            if(!applicantList.isEmpty()){
                
                Decimal totalMonthlyIncome = 0;
                Decimal monthlyObligation = 0.00;
                Decimal freeCashFlow = 0;
                Decimal consolidationObligation = 0.00;
                Decimal loanEmi = (applicantList[0].Loan__r.EMI__c !=null) ? applicantList[0].Loan__r.EMI__c : 0;
                Decimal loanAmount = (applicantList[0].Loan__r.Loan_Amount__c !=null) ? applicantList[0].Loan__r.Loan_Amount__c : 0;
                Decimal totalVerifiedIncome = (applicantList[0].Loan__r.Total_Verified_Income__c !=null) ? applicantList[0].Loan__r.Total_Verified_Income__c : 0;
                Decimal foir=0;
                 List<Applicant__c> applicantUpdateList = new List<Applicant__c>();
                for(Applicant__c applicantInstance : applicantList){
                    Decimal documented=0;
                    Decimal assessed=0;
                    if( (applicantInstance.Total_Monthly_Income__c!=null) && (applicantInstance.Total_Monthly_Income__c!=0) ){
                        totalMonthlyIncome = totalMonthlyIncome +applicantInstance.Total_Monthly_Income__c;
                        documented = documented + applicantInstance.Total_Monthly_Income__c;
                    }
                    if( (applicantInstance.Current_Obligation__c!=null) && (applicantInstance.Current_Obligation__c!=0) ){
                        monthlyObligation = monthlyObligation +applicantInstance.Current_Obligation__c;
                    }
                    if( (applicantInstance.Free_Monthly_Cashflow__c!=null) && (applicantInstance.Free_Monthly_Cashflow__c!=0) ){
                        freeCashFlow = freeCashFlow + applicantInstance.Free_Monthly_Cashflow__c;
                        assessed = assessed +  applicantInstance.Free_Monthly_Cashflow__c;
                    }
                     // JUL 21
                    Applicant__c applicantNewInstance = new Applicant__c();
                    applicantNewInstance.Id = applicantInstance.Id;
                    applicantNewInstance.Total_Monthly_Income_Sum__c = documented + assessed;
                    applicantUpdateList.add(applicantNewInstance);
                    //END
                }
                //Consolidation Calculation
                consolidationObligation = monthlyObligation + loanEmi;
                
                //totalMonthylIncome
                Decimal totalMonthylIncme =  (totalMonthlyIncome +freeCashFlow) - deductMonthlyIncome;

                 //Foir Calculation
                 foir = (totalMonthylIncme != 0) ? (consolidationObligation/totalMonthylIncme) * 100 : 0;
                
                //Assignment
                wrapperInstance.totalMonthlyIncome =totalMonthylIncme;
                wrapperInstance.currentObligation = monthlyObligation.setScale(2);
                wrapperInstance.freeMonthlyCashflow = freeCashFlow;
                wrapperInstance.proposedEMI = loanEmi;
                wrapperInstance.consolidationObligation = consolidationObligation.setScale(2);
                wrapperInstance.totalLoanAmount = loanAmount;
                wrapperInstance.foirPercentage = foir.setScale(2);
                wrapperInstance.totalVerifiedIncome = totalVerifiedIncome;

                Loan_Application__c loanApplication = new Loan_Application__c();
                loanApplication.Id = loanId;
                loanApplication.Total_Monthly_Income__c = totalMonthylIncme;
                loanApplication.Current_Obligation__c = monthlyObligation.setScale(2);
                loanApplication.Other_Income__c = freeCashFlow;
                loanApplication.Consolidation_Obligation__c = consolidationObligation.setScale(2);
                loanApplication.FOIR_Percentage__c =  foir.setScale(2);
                /*SFAU-5632 Changes*/
                if(!loanExistingBreReRun && (loanExistingFoirPercentage != foir.setScale(2))){
                    loanApplication.BRE_ReRun_Required__c = true;
                }
                /******************* */
                if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                update loanApplication;
                    
                     //JUL 21
                if(applicantUpdateList!=null && applicantUpdateList.size()>0){
                    update applicantUpdateList;
                }
				//END
                }
            }
        }
        
        
        catch (Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),'');
        }
        return wrapperInstance;
    }

    @AuraEnabled
    public static void saveDetails(String loanId, String custGrade){
        update new Loan_Application__c(Id = loanId, Customer_Grade__c = custGrade);
    }

    
    public class foirWrapper{
        @AuraEnabled public Decimal totalMonthlyIncome{get;set;}
        @AuraEnabled public Decimal currentObligation{get;set;}
        @AuraEnabled public Decimal freeMonthlyCashflow{get;set;}
        @AuraEnabled public Decimal proposedEMI{get;set;}
        @AuraEnabled public Decimal consolidationObligation{get;set;}
        @AuraEnabled public Decimal totalLoanAmount{get;set;}
        @AuraEnabled public Decimal foirPercentage{get;set;}
        @AuraEnabled public String custGrade {get;set;}
        @AuraEnabled public Boolean showCustGrade {get;set;}
        @AuraEnabled public Boolean isCustGradeEditable {get;set;}
        @AuraEnabled public Boolean isTwoWheeler {get;set;}
        @AuraEnabled public Boolean isFourWheeler {get;set;}
        @AuraEnabled public Decimal totalVerifiedIncome {get;set;}
        public foirWrapper(){
            totalMonthlyIncome = 0;
            currentObligation = 0;
            freeMonthlyCashflow = 0;
            proposedEMI = 0;
            consolidationObligation = 0;
            totalLoanAmount =0;
            foirPercentage = 0;
            totalVerifiedIncome = 0;
        }
    }
}