@isTest
public class NotepadRequestWrapperTest{
static testMethod void testEx1(){
       Test.startTest();
        String jsonVal ='{"StartDate":"","AccountID":"","CustomerID":"","MemoText":"","RequestId":"","OriginatingChannel":"","ReasonForMemo":"","MaintenanceMode":"","ReferenceNumber":"","Severity":"","TransactionBranch":"","MemoNumber":"","EndDate":""}'; 
        NotepadRequestWrapper.parse(jsonVal);
       Test.stopTest(); 
     }
}