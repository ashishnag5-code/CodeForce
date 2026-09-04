public class DocumentTrackerHandler extends TriggerHandler {
	public override void afterInsert(){
        DocumentTrackerService serviceInstance = new DocumentTrackerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.newMap);
    }
}