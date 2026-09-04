@isTest
public class RecordAccessExceptionHandlerTest {
    @isTest
    public static void updatePaymentFavouringAtOpsAuthTest(){
        Payment__c payment = new Payment__c(Inactive__c = false);
        insert payment;
        Test.startTest();
        RecordAccessExceptionHandler handler=new RecordAccessExceptionHandler();
        RecordAccessExceptionHandler.updatePaymentFavouringAtOpsAuth(JSON.serialize(payment));
        try{
        RecordAccessExceptionHandler.updatePaymentFavouringAtOpsAuth('');
        RecordAccessExceptionHandler.deleteBankStatement(payment.Id, '');
        }catch(Exception ex){
            System.debug(ex.getCause());
        }
        
        Test.stopTest();
            }

    @isTest
    public static void deleteBankStatementTest(){
        Payment__c payment = new Payment__c(Inactive__c = false);
        insert payment;
        Test.startTest();
        RecordAccessExceptionHandler handler=new RecordAccessExceptionHandler();
        try{
        RecordAccessExceptionHandler.deleteBankStatement(payment.Id, '');
        }catch(Exception ex){
            System.debug(ex.getCause());
        }
        
        Test.stopTest();
    }
            @isTest
    public static void deleteBankStatementTest2(){
        Payment__c payment = new Payment__c(Inactive__c = false);
        insert payment;
        Test.startTest();
        RecordAccessExceptionHandler handler=new RecordAccessExceptionHandler();
        try{
        RecordAccessExceptionHandler.deleteBankStatement(null, '');
        }catch(Exception ex){
            System.debug(ex.getCause());
        }
        
        Test.stopTest();
    }

}