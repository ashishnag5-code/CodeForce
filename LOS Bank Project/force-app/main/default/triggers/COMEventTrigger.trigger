trigger COMEventTrigger on COM_Share_Record_Event__e (after insert) {
    
    if(Trigger.isInsert) {
        COMShareApplicationRecordHandler.handleCOMPlatformRecordInsert(Trigger.newMap);
        
    }
    
}