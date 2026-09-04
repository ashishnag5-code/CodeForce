trigger NotificationEventTrigger on Notification_Event__e (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        NotificationEventTriggerHandler.handleNotificationPlatformEvent(Trigger.NewMap);
    }
}