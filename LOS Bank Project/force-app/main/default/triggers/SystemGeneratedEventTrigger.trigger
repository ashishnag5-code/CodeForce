/*******************************************************************************************
* @Name         SystemGeneratedEventTrigger
* @Author       Yash Shukla
* @Description   Trigger to handle the System generated Documents Insert
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        16/10/2023         Initial Creation
*******************************************************************************************/
trigger SystemGeneratedEventTrigger on System_Generated_Document_Event__e (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        SystemGeneratedEventTriggerHandler.handleAfterInsert(Trigger.newMap);
    }
}