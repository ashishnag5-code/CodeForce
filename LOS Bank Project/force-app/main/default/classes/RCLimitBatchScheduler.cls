/*******************************************************************************************
* @Name         RCLimitBatchScheduler
* @Author       Yash Shukla
* @Description  Scheduler Class for RC Limit Batch COntroller.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date               Description
*-------------------------------------------------------------------------------------------
*  1.0          Yash Shukla      09/27/2023           Initial Creation                                                      
*******************************************************************************************/
global class RCLimitBatchScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc)
    {
        RCIncreasedLimitBatch btch = new RCIncreasedLimitBatch(); // Your batch class
        database.executeBatch(btch);
    }

}