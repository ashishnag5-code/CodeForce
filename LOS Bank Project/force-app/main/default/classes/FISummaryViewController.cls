/**
 * @description       : This class for Field Investigation LWC component
 * @author            : Vikas Singhal | Salesforce
 * @last modified on  : Jan-20-2023
**/
public with sharing class FISummaryViewController {
    @AuraEnabled
    public static List<FiSummaryViewWrapper> fiSummaryView(String loanApplicationId,String applicantId){
        List<FISummaryViewWrapper> lstSummaryWrapper = new List<FISummaryViewWrapper>();
        try{
            lstSummaryWrapper = FieldInvestigationUtility.getFISummary(loanApplicationId,applicantId);

        }
        catch(Exception ex){
            system.debug('Exception>>>>'+ex.getMessage()+'  line number>>>'+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
        return lstSummaryWrapper;
    }
}