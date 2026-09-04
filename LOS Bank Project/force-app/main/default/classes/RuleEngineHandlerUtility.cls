public class RuleEngineHandlerUtility {
    
    static Map<String, Map<String, String>> expressionLogic = new Map<String, Map<String, String>>();
    public boolean getComplexCriteriaEvaluation(String expression, Map<Integer, Boolean> booleanValMap){
        expression = substituteValues(expression, booleanValMap);
        expression = trimExpression(expression);
        expression = expression.toUpperCase();
        prepareExpressionLogic();
        
        return true;
    }  
    public static Boolean evaluateAdvanceLogic(String expression, Map<Integer, Boolean> values) {
        if(expression != null){
            expression = substituteValues(expression, values);
            expression = trimExpression(expression);
            expression = expression.toUpperCase();
            prepareExpressionLogic();
         
            do{
         		if(expression.contains('AND')){
                    Map<String,String> andLogicMap = expressionLogic.get('AND');
                    for(String replaceableStr : andLogicMap.keySet()){
                        expression = expression.replace(replaceableStr,andLogicMap.get(replaceableStr));
                    }
                }
                if(expression.contains('OR')){
                    Map<String,String> orLogicMap = expressionLogic.get('OR');
                    for(String replaceableStr : orLogicMap.keySet()){
                        expression = expression.replace(replaceableStr,orLogicMap.get(replaceableStr));
                    }
                }
                if(expression.contains('(') ){
                    Map<String,String> braceLogicMap = expressionLogic.get('BRACES');
                   
                    for(String replaceableStr : braceLogicMap.keySet()){
						expression = expression.replace(replaceableStr,braceLogicMap.get(replaceableStr));
                        
                    }
                }
               
                expression = trimExpression(expression);
                if(expression.equals('TRUE') || expression.equals('FALSE'))
                break;
              
            }while(true);  
            return Boolean.valueOf(expression);
        }
        return false;
        
    }
    
    private static String substituteValues(String expression, Map<Integer, Boolean> booleanValMap) {
        if(expression != null){
            for(Integer i = 1;i<=booleanValMap.keySet().size();i++){
                expression = expression.replaceAll(''+(i), ''+booleanValMap.get(i));
            }
        }
        
        return expression;
    }
    private static string trimExpression(String expression){
        if(expression != null){
            expression = expression.replaceAll(' ','');
            expression = expression.replaceAll('OR',' OR ');
            expression = expression.replaceAll('AND',' AND ');
        }
        return expression;
    }
    
    
    public static void prepareExpressionLogic() {
        Map<String, String> ANDLogic = new Map<String, String>();
        Map<String, String> ORLogic = new Map<String, String>();
        Map<String, String> BRACELogic = new Map<String, String>();
        
        // AND Logic
        ANDLogic.put('TRUE AND TRUE', 'TRUE');
        ANDLogic.put('TRUE AND FALSE', 'FALSE');
        ANDLogic.put('FALSE AND TRUE', 'FALSE');
        ANDLogic.put('FALSE AND FALSE', 'FALSE');
        expressionLogic.put('AND', ANDLogic);
        
        // OR Logic
        ORLogic.put('TRUE OR TRUE', 'TRUE');
        ORLogic.put('TRUE OR FALSE', 'TRUE');
        ORLogic.put('FALSE OR TRUE', 'TRUE');
        ORLogic.put('FALSE OR FALSE', 'FALSE');
        expressionLogic.put('OR', ORLogic);
        
        // Braces Logic
        BRACELogic.put('(TRUE)', 'TRUE');
        BRACELogic.put('(FALSE)', 'FALSE');
        expressionLogic.put('BRACES', BRACELogic);
    }
}