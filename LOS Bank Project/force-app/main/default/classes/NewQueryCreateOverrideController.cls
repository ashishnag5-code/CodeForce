// The class is not needed as the functionality is now handled via flow
public class NewQueryCreateOverrideController {

    @AuraEnabled
    public static void sendPushNotification(String triggerPoint, String loanApplicationId){
        try {
            if(String.isNotBlank(triggerPoint) && String.isNotBlank(loanApplicationId)) {
                NotificationHandler.sendNotification(triggerPoint, loanApplicationId, '');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

}