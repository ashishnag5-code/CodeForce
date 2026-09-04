/*******************************************************************************************
* @Name         RCLimitBatchScheduler
* @Author       Yash Shukla
* @Description  Test Controller Scheduler Class for RC Limit Batch COntroller.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date               Description
*-------------------------------------------------------------------------------------------
*  1.0          Yash Shukla      10/31/2023           Initial Creation                                                      
*******************************************************************************************/
@IsTest
public class RCLimitBatchSchedulerTest {
    
    @IsTest
    static void testRCLimitSchedulerTest(){
        Test.StartTest();
		RCLimitBatchScheduler testsche = new RCLimitBatchScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    }

}