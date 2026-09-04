@istest
public class LOSKarzaFaceMatchIntHandlerTest {
    
      @istest static void generateRequestMapBank(){
        Map<String,String> objMap = new Map<String,String>();
        objMap.put('name1','test1');
        objMap.put('name2','test2');
        LOSKarzaFaceMatchIntHandler.generateRequest(objMap);
    }
    

}