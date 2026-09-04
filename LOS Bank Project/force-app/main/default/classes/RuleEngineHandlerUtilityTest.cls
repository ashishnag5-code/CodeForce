@isTest
public with sharing class RuleEngineHandlerUtilityTest {
    @isTest 
    static void GetComplexCriteriaEvaluationTest(){
        String expression = '1 AND 2';
        Map<Integer, Boolean> intBoolMap = new Map<Integer, Boolean>();
        for(Integer i=1; i<=2;i++){
            intBoolMap.put(i,false);
        }
        RuleEngineHandlerUtility REHUtility = new RuleEngineHandlerUtility();
        System.assert(REHUtility.getComplexCriteriaEvaluation(expression, intBoolMap));
    }

    @isTest 
    static void AndLogicTest(){
        String expression = '1 AND 2';
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(true);
        System.assert(RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'True and True condition failed');

        booleanValMap = SameBooleanValue(false);
        System.assertEquals(false, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'False and False condition failed');

        booleanValMap = DiffBooleanValue(false);
        System.assertEquals(false, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'True and False condition failed');

        booleanValMap = DiffBooleanValue(true);
        System.assertEquals(false, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'False and True condition failed');
    }

    @isTest 
    static void OrLogicTest(){
        String expression = '1 OR 2';
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(true);
        System.assert(RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'True OR True condition failed');

        booleanValMap = SameBooleanValue(false);
        System.assertEquals(false, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'False OR False condition failed');

        booleanValMap = DiffBooleanValue(false);
        System.assertEquals(true, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'True OR False condition failed');

        booleanValMap = DiffBooleanValue(true);
        System.assertEquals(true, RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap), 'False OR True condition failed');
    }

    @isTest 
    static void BracesAndLogicTest(){
        String expression = '(1 AND 2)';
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(true);
        System.assertEquals(true,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'Braces True AND True condition failed');

        expression = '(1 AND 2)';
        booleanValMap = DiffBooleanValue(false);
        System.assertEquals(false,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'Braces True AND False condition failed');

    }
    @isTest 
    static void BracesOrLogicTest(){
        String expression = '(1 OR 2)';
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(false);
        System.assertEquals(false,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'Braces False OR False condition failed'); 
        
        expression = '(1 OR 2)';
        booleanValMap = DiffBooleanValue(true);
        System.assertEquals(true,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'Braces False OR True condition failed');

    }

   /* @isTest 
    static void emptyExpressionLogicTest(){
        Test.startTest();
        String expression = ' ';
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(true);
        System.assertEquals(false,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'Empty expression condition failed');
        Test.stopTest();
    }*/
    @isTest 
    static void nullExpressionLogicTest(){
        String expression = null;
        Map<Integer, Boolean> booleanValMap = SameBooleanValue(true);
        System.assertEquals(false,RuleEngineHandlerUtility.evaluateAdvanceLogic(expression,booleanValMap),'null expression condition failed');
    }

    static Map<Integer, Boolean> SameBooleanValue(Boolean bool){
        Map<Integer, Boolean> intBoolMap = new Map<Integer, Boolean>();
        for(Integer i=1; i<=2;i++){
            intBoolMap.put(i,bool);
        }
        return intBoolMap;
    }

    static Map<Integer, Boolean> DiffBooleanValue(Boolean bool){
        Map<Integer, Boolean> intBoolMap = new Map<Integer, Boolean>();
        for(Integer i=1; i<=2;i++){
            Integer rem = Math.mod(i,2);
            if(rem == 0){
                intBoolMap.put(i,bool);
            }else{
                intBoolMap.put(i,!bool);
            }
        }
        return intBoolMap;
    }
}