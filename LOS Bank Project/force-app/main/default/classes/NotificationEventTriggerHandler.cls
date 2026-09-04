public without sharing class NotificationEventTriggerHandler {
    public static void  handleNotificationPlatformEvent(Map<Id, Notification_Event__e> eventsMap) {
        Set<Id> loanApps = new Set<Id>(); 
        String loanId='';
        List<String> triggerPointList= new List<String>();
        for(Notification_Event__e notificationEvent: eventsMap.values()){
            loanApps.add(notificationEvent.sObjectId__c);
            loanId = notificationEvent.sObjectId__c;
            triggerPointList.add(notificationEvent.Trigger_Point__c);
        }

        for(String strTrigger : triggerPointList){
            if(strTrigger == 'KYC approval flow'){
                NotificationHandler.sendNotification('KYC approval flow', loanId, ''); //Notification 
            }
            if(strTrigger == 'Credit Sanction'){
               NotificationHandler.sendNotification('Credit Sanction', loanId, ''); //Notification 
            }
            if(strTrigger == 'if Case under STP'){
                NotificationHandler.sendNotification('if Case under STP', loanId, '');
            }
            if(strTrigger == 'PDD Rejection'){
                NotificationHandler.sendNotification('PDD Rejection', loanId, '');
            }
            if(strTrigger == 'AML REVERT'){
                NotificationHandler.sendNotification('AML REVERT', loanId, '');
            }

            if(strTrigger == 'Stage Movement Trigger'){
                NotificationHandler.sendNotification('Stage Movement Trigger', loanId, '');
            }
            if(strTrigger == 'PDD stage'){
                NotificationHandler.sendNotification('PDD stage', loanId, '');
            }
            if(strTrigger == 'Case Rejection'){
                NotificationHandler.sendNotification('Case Rejection', loanId, '');
            }
            if(strTrigger == 'Pricing Approval'){
                NotificationHandler.sendNotification('Pricing Approval', loanId, '');
            }
            if(strTrigger == 'E-mandate/eNach'){
                NotificationHandler.sendNotification('E-mandate/eNach', loanId, '');
            }
            if(strTrigger == ' DDE Submission'){
                NotificationHandler.sendNotification(' DDE Submission', loanId, '');
            }

           
        }
       
    }
}