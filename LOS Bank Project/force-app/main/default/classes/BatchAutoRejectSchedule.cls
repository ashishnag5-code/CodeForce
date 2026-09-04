global class BatchAutoRejectSchedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        BatchRejectionLetterGeneration batch = new BatchRejectionLetterGeneration();
        Database.executeBatch(batch,1);
    }
}