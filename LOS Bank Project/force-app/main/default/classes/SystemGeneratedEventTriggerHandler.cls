/*******************************************************************************************
* @Name         SystemGeneratedEventTriggerHandler
* @Author       Yash Shukla
* @Description   Handler Class to handle the System generated Documents Insert
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        16/10/2023         Initial Creation
*******************************************************************************************/
public class SystemGeneratedEventTriggerHandler {
    
    public static void handleAfterInsert(Map<Id,System_Generated_Document_Event__e> systemDocsEventRecordsMap){
        SystemGeneratedEventTriggerHelper.handleLoanandCollateralUpdate(systemDocsEventRecordsMap);
    }

}