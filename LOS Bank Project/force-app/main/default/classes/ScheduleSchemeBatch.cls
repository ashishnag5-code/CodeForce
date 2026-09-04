public class ScheduleSchemeBatch implements Schedulable{
    public void execute(SchedulableContext SC) {
        MarkSchemeInActiveDailyBatch batch = new MarkSchemeInActiveDailyBatch(); 
        Database.executeBatch(batch);
     }
}