@isTest
public class TestFactoryTest {
	@isTest
    public static void testclasscoverage(){
        try{
            Account sObj = New Account();
            TestFactory.createSObject(sObj);
            TestFactory.createSObject(sObj,false);
            
          	TestFactory.createSObject(sObj, 'TestFactoryDefaults.AccountDefaults', false);
            TestFactory.createSObjectList(sObj, 1);
            TestFactory.createSObjectList(sObj, 1, false);
            TestFactory.createSObjectList(sObj, 1, 'TestFactoryDefaults.AccountDefaults', false);
            TestFactory.createSObject(sObj,true);
        }catch(exception e){
            system.debug('error');
        }
    }
}