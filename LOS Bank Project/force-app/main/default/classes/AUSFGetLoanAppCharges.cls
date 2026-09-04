public class AUSFGetLoanAppCharges {
    public Id loanApplId {get;set;}
    public List <Charge__c> chrgeList { get; set; }
    public AUSFGetLoanAppCharges() {
        system.debug('loanApplId '+loanApplId);
        chrgeList = [SELECT Id, Actual_rate__c, Charge_Amount__c, Tax_Amount__c, Total_Amount__c,
                     Charges_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                     Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                     Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                     Deviation_Applicable__c, Shown_to_UI__c 
                     FROM Charge__c where Loan_Application__c =:loanApplId];
        
        system.debug('chrgeList '+chrgeList);
        
    }
    
}