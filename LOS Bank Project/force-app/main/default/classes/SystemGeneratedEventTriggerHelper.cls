/*******************************************************************************************
* @Name         SystemGeneratedEventTriggerHelper
* @Author       Yash Shukla
* @Description   Helper Class to handle the System generated Documents Insert
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        16/10/2023         Initial Creation
*******************************************************************************************/
public class SystemGeneratedEventTriggerHelper {
    private static final Map<String, String> DOCUMENTNAME_TO_FIELDNAME = new Map<String, String>{
        'SANCTION LETTER' => 'Sanction_Status__c',
        'DELIVERY ORDER' => 'DO_Status__c',
        'SANCTION CANCELLED LETTER' => 'Sanction_Status__c',
        'DO CANCELLED LETTER' => 'DO_Status__c',
        'DO LETTER' => 'DO_Status__c'
    };
    public static void handleLoanandCollateralUpdate(Map<Id,System_Generated_Document_Event__e> systemDocsEventRecordsMap){
        Map<String, String> applicationId_FieldMap = new Map<String, String>();
        Set<Id> loanIds = new Set<Id>();
        Map<Id, Loan_Application__c> loanApplicationMap = new Map<Id, Loan_Application__c>();
        Map<Id, String> loanLetterNameMap = new Map<Id, String>();
        for(System_Generated_Document_Event__e eventRec : systemDocsEventRecordsMap.values()){
            String letterName = eventRec.Letter_Type__c;
            Loan_Application__c application = new Loan_Application__c(Id = eventRec.Loan_Application_Id__c);
            if(DOCUMENTNAME_TO_FIELDNAME.containsKey(letterName)){
                if(letterName.contains('CANCELLED')){
                    application.put(DOCUMENTNAME_TO_FIELDNAME.get(letterName),'Cancelled');
                }
                else{
                    application.put(DOCUMENTNAME_TO_FIELDNAME.get(letterName),'Issued');
                }
                if(letterName == 'DO LETTER'||letterName == 'DELIVERY ORDER') {
                    application.put('Interest_Start_Date__c',System.today());
                }
                loanApplicationMap.put(eventRec.Loan_Application_Id__c, application);
                loanLetterNameMap.put(eventRec.Loan_Application_Id__c, letterName);
            }
        }
        if(!loanApplicationMap.isEmpty()){
            update loanApplicationMap.values(); 
            handleCollateralUpdate(loanApplicationMap, loanLetterNameMap);   
        }
        
    }
    
    public static void handleCollateralUpdate(Map<Id, Loan_Application__c> loanMap, Map<Id, String> loanLetterNameMap){
        List<Collateral__c> loanAssociatedCollateral = [SELECT Id, DO_Generation_Date__c, DO_Cancellation_Date__c, Loan__c FROM Collateral__c 
                                                        WHERE Loan__c IN :loanMap.keySet() AND Is_Deleted__c = false];
        Map<Id,Collateral__c> collateralIdMap = new Map<Id,Collateral__c>();
        for(Collateral__c record : loanAssociatedCollateral){
            if(loanLetterNameMap.containsKey(record.Loan__c)){
                String letterName = loanLetterNameMap.get(record.Loan__c);
                if(letterName == 'DO LETTER' || letterName == 'DELIVERY ORDER'){
                    record.DO_Generation_Date__c = System.Today();
                }
                else if(letterName == 'DO CANCELLED LETTER'){
                    record.DO_Cancellation_Date__c = System.Today();
                }
                collateralIdMap.put(record.Id, record);
            }
        }
        if(!collateralIdMap.isEmpty()){
            update collateralIdMap.values();
            system.debug('  '+Limits.getQueries());
        }
        
    }

}