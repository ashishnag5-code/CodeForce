public class RuleEngineHandler {
    
    Map<String,Object> response = new Map<String,Object>();
    Set<String> stringOperatorSet = new Set<String> {
        'Equals', 'Not Equals', 'Starts With', 'Contains', 'Does not Contains', 'Includes', 'Excludes'
    };
    String PICKLIST_DELIMITER = ';';    
    List<Rule_Driver__c > ruleDriverLst;
    List<Rule_Driver__c > matchingruleDriverLst;
    List<Rule_Definition__c > matchingruleDefinition;
    Set<String> objectToFields;
    String objectName = '';
    Set<String> sObjectIds;
    public static String FIELD_VALUE = 'Field';
    public static String VALUE = 'Value';
    public List<Map<String,Object>> returnValue;
    public Map<String, List<Map<String,Object>>> finalReturnValue;
    public static String FIRSTMATCH = 'First Match';
    public static String ALLMATCH = 'All Match';
    
    public String main(String sObjectName,Set<String> sObjectIds, Set<String> criteriaStrings,String configurationFor){
        try{
            if(String.isBlank(sObjectName) || sObjectIds.isEmpty()) 
            return 'sObjectName or sObjectId can\'\t be blank';
            
            this.objectName = sObjectName;
            this.sObjectIds = sObjectIds;
            identifyActiveRules(getQueryStringForRuleDriver(sObjectName,criteriaStrings,configurationFor)); 
          	identifyMatchingRules();
            response.put('Status','Success');
            response.put('Value',finalReturnValue);
            
        }catch(Exception e){
            response.put('Status','Error');
            response.put('Reason',e.getMessage() + 'Line Number==='+ e.getLineNumber());
        }    
        return JSON.serialize(response);
    }
    
    public String main(String sObjectName,Set<String> sObjectIds,Set<Id> ruleDriverIds,String configurationFor){
        try{
            if(ruleDriverIds.isEmpty()) 
            return 'Please provide the rule driver Ids';
            
            this.objectName = sObjectName;
            this.sObjectIds = sObjectIds;
            identifyActiveRules(getQueryStringForRuleDriver(ruleDriverIds,configurationFor)); 
            identifyMatchingRules();
            response.put('Status','Success');
            response.put('Value',finalReturnValue);
            
        }catch(Exception e){
            response.put('Status','Error');
            response.put('Reason',e.getMessage() + 'Line Number==='+ e.getLineNumber());
        }    
        return JSON.serialize(response);
    }
    
  	private List<Rule_Driver__c> getQueryStringForRuleDriver(Set<Id> ruleDriverIds,String configurationFor ){
        Date todaysDate = Date.today();
        String setString = '(';
        for(Id each :  ruleDriverIds){
            setString+= '\''+each+'\'';
        }
        setString+= ')';
        String queryString = 'SELECT Id,Logical_Expression__c,Match_Criteria__c,Target_Value__c,(SELECT Id,Rule_ID__r.Rule_Name__c,Rule_ID__r.Sequence__c,Rule_ID__r.Subject_Field__c, Rule_ID__r.Rule_Condition__c, Rule_ID__r.Value_Field__c, Rule_ID__r.Attribute_Fixed_Value__c, Rule_ID__r.Attribute_Lower_Limit__c, Rule_ID__r.Attribute_Upper_Limit__c,Rule_ID__r.Target_Object__c,Rule_ID__r.Target_Object_Record_Type__c,Rule_ID__r.Target_Owner__c,Target_Owner__c FROM Rule_Definition_Driver_Mappings__r Order By Rule_ID__r.Sequence__c ) FROM Rule_Driver__c ';
        String whereClause = 'WHERE Id IN '+setString;
        whereClause += !String.isBlank(configurationFor) ? ' AND Configuring_For__c='+'\''+configurationFor+'\'' : '';
      	whereClause += ' AND Effective_From__c  <= :todaysDate AND Effective_To__c  >= :todaysDate';
        system.debug('query is>>>'+queryString+whereClause);
        return Database.query(queryString+whereClause);
    }
    
    private List<Rule_Driver__c> getQueryStringForRuleDriver(String sObjectName, Set<String> criteriaStrings,String configuringFor){
        Date todaysDate = Date.today(); 
        Set<String> values = new Set<String>();
        String setString = '(';
        for(String each :  criteriaStrings){
            values.add('%'+each+'%');
        }
        setString+= ')';
        system.debug(values);
        String queryString = 'SELECT Id,Logical_Expression__c,Match_Criteria__c,Target_Value__c,(SELECT Id,Rule_ID__r.Rule_Name__c,Rule_ID__r.Sequence__c,Rule_ID__r.Subject_Field__c, Rule_ID__r.Rule_Condition__c, Rule_ID__r.Value_Field__c, Rule_ID__r.Attribute_Fixed_Value__c, Rule_ID__r.Attribute_Lower_Limit__c, Rule_ID__r.Attribute_Upper_Limit__c,Rule_ID__r.Target_Object__c,Rule_ID__r.Target_Object_Record_Type__c,Rule_ID__r.Target_Owner__c,Target_Owner__c FROM Rule_Definition_Driver_Mappings__r Order By Rule_ID__r.Sequence__c ) FROM Rule_Driver__c ';
        String whereClause = 'WHERE Object_Name__c='+'\''+sObjectName+'\'';
        system.debug('whereClause=='+whereClause);
        whereClause += !criteriaStrings.isEmpty() ? ' AND Combine_Key__c LIKE: values':'';
        system.debug('***clause:'+whereClause);
        whereClause += !String.isBlank(configuringFor) ? ' AND Configuring_For__c='+'\''+configuringFor+'\'' : '';
        system.debug('***clause:'+whereClause);
        whereClause += ' AND Effective_From__c  <= :todaysDate AND Effective_To__c  >= :todaysDate';
        system.debug('***clause:'+whereClause);
        system.debug(queryString+whereClause);
        system.debug('***result=='+Database.query(queryString+whereClause));
        return Database.query(queryString+whereClause);
    }
    
    
     // Fetch discount rules that are still active. If a discount rule is exclusive, only use that
    private void identifyActiveRules(List<Rule_Driver__c> ruleDriverList) {
        System.debug('***rule driver list: '+ruleDriverList);
        Date todaysDate = Date.today();
        ruleDriverLst = new List<Rule_Driver__c>();
        objectToFields = new Set<String>();
      
        for(Rule_Driver__c  each : ruleDriverList){
          	ruleDriverLst.add(each);
            system.debug('each==='+each);                          
            for(Rule_Definition_Driver_Mapping__c itr : each.Rule_Definition_Driver_Mappings__r){
                system.debug('field==='+itr?.Rule_ID__r?.Subject_Field__c);  
                if(!String.isBlank(itr?.Rule_ID__r?.Subject_Field__c))
                objectToFields.add(itr?.Rule_ID__r?.Subject_Field__c);                                      
            }                           
            system.debug('objectToFields==='+objectToFields);                                                              
        }
        system.debug('objectToFields==='+objectToFields); 
    }    
     // Rule_ID__r.Attribute_Fixed_Value__c,
    public void identifyMatchingRules(){
        List<sObject> objLst = getsObjectRecords();
        matchingruleDriverLst = new List<Rule_Driver__c>();
        matchingruleDefinition = new List<Rule_Definition__c>();
        returnValue = new List<Map<String,Object>>();
        finalReturnValue = new Map<String,List<Map<String,Object>>>();
        Map<Integer, Boolean> booleanMap = new Map<Integer,Boolean>();
        
        for(sObject obj : objLst){
            for (Rule_Driver__c each: ruleDriverLst) {
                Boolean meetsCriteria = true;
                Boolean logicalFilter = String.isEmpty(each.Logical_Expression__c) ? true : false;
                for (Rule_Definition_Driver_Mapping__c eachCriteria : each.Rule_Definition_Driver_Mappings__r) {
                    meetsCriteria &= evaluateRule(eachCriteria, obj);
                    Map<String,Object> tempVal = new Map<String,Object>();
                    tempVal.put('TO',eachCriteria.Rule_ID__r.Target_Object__c);
                    tempVal.put('TR',eachCriteria.Rule_ID__r.Target_Object_Record_Type__c);
                    //String targetVal = 
                    tempVal.put('TV',!String.isEmpty(eachCriteria?.Target_Owner__c) ? eachCriteria.Target_Owner__c : eachCriteria?.Rule_ID__r?.Target_Owner__c); 
                    tempVal.put('RD',eachCriteria.Id);
                    if(logicalFilter && meetsCriteria){
                       system.debug('each.Match_Criteria__c==='+each.Match_Criteria__c);
                        if(each.Match_Criteria__c == FIRSTMATCH){
                            returnValue.add(tempVal);
                            break;
                        }else if(each.Match_Criteria__c == ALLMATCH ){
                            returnValue.add(tempVal);
                        }
                    }else if(!logicalFilter){
                        booleanMap.put(Integer.valueOf(eachCriteria?.Rule_Id__r?.Sequence__c),meetsCriteria);  
                        if(String.isBlank(each.Target_Value__c)){
                            returnValue.add(tempVal);
                        }
                        
                    }
                }
                
                if(!logicalFilter){
                    system.debug(each.Target_Value__c +' : ' +booleanMap);
                    system.debug(each.Logical_Expression__c);
                    meetsCriteria = RuleEngineHandlerUtility.evaluateAdvanceLogic(each.Logical_Expression__c,booleanMap);
                    if(meetsCriteria && String.isNotBlank(each.Target_Value__c)){
                        Map<String,Object> tempVal = new Map<String,Object>();
                        tempVal.put('TV',each.Target_Value__c);
                        returnValue.add(tempVal);
                    }
                }
            }
            finalReturnValue.put((String)obj.get('Id'),returnValue);
    	}
        system.debug('finalReturnValue==='+finalReturnValue);
    }
    
    private Boolean evaluateRule(Rule_Definition_Driver_Mapping__c criteriaRec,sObject obj) {
        Boolean doesRuleEvaluateToTrue = false;
        Object targetValue;
        Object sourceValue;
        sourceValue = getValueFromSObject(criteriaRec, obj);
        system.debug('sourceValue=='+sourceValue);
        system.debug('criteriaRec=='+criteriaRec);

        if (criteriaRec.Rule_ID__r?.Value_Field__c == VALUE) {
            if(criteriaRec?.Rule_ID__r?.Rule_Condition__c == 'Between' ){
                targetValue = criteriaRec?.Rule_ID__r?.Attribute_Lower_Limit__c + '|' + criteriaRec?.Rule_ID__r?.Attribute_Upper_Limit__c ;
            }else{
                targetValue = criteriaRec?.Rule_ID__r?.Attribute_Fixed_Value__c;
            }
        }
        else if (criteriaRec?.Rule_ID__r?.Value_Field__c == FIELD_VALUE) {
                targetValue = getValueFromSObject(criteriaRec, obj);
        }
        system.debug('targetValue=='+targetValue);         
        boolean bl = evaluateWithOperator(sourceValue, criteriaRec?.Rule_ID__r?.Rule_Condition__c, targetValue);
        system.debug('bl=='+bl);
        return bl;
    }
    
    private Object getValueFromSObject(Rule_Definition_Driver_Mapping__c criteriaRec , sObject objectInstance){
        Object fldValue = null;//sObj.get(filterObj.field_name__c);

        if(criteriaRec?.Rule_ID__r?.Subject_Field__c == 'toLabel(Loan__r.Product__c)'){
            return objectInstance.getSObject('Loan__r').get('Product__c');
        }else if(criteriaRec?.Rule_ID__r?.Subject_Field__c == 'toLabel(Product__c)'){
            return objectInstance.get('Product__c');
        }else if(criteriaRec?.Rule_ID__r?.Subject_Field__c == 'toLabel(Loan_Application__r.Product__c)'){
            return objectInstance.getSObject('Loan_Application__r').get('Product__c');
        }
        List<String> parentList = criteriaRec?.Rule_ID__r?.Subject_Field__c.split('\\.');
        SObject intSObj;
        system.debug('criteriaRec==='+criteriaRec.id);
        system.debug('parentList==='+parentList);
        system.debug('objectInstance==='+objectInstance);
        if(parentList.size() == 1){
            // if(parentList[0].contains('Product__c') && parentList[0].contains('toLabel')){
            //     return objectInstance.get('Product__c');
            // }
            return objectInstance.get(parentList[0]);
        }else if(parentList.size() > 1 && objectInstance.getSObject(parentList[0]) != null){
            return objectInstance.getSObject(parentList[0]).get(parentList[1]);
        }
        return null;
        
    }
     // This method gets all field names and builds query string. Also adds mandatory fields such as ID and other quote line fields required
    // for discount calculation
    private String getQueryString() {
        String queryString;
        List<String> allFields = new List<String>();
        allFields.addAll(objectToFields);
        queryString = 'SELECT ';
        queryString += String.join(allFields, ',');
        queryString += ' FROM ' + objectName;
       // system.debug('queryString=='+queryString);
        return queryString;
    }

    //getsObject Record 
    private List<sObject> getsObjectRecords() {
        String queryString = getQueryString()  + ' WHERE Id IN: sObjectIds';
        system.debug('queryString=='+queryString);
        List<sObject> obj = Database.query(
            String.escapeSingleQuotes(queryString)
        );
        system.debug('queryString=='+queryString);
        system.debug('obj=='+obj);
		return obj;
       
    }
     /* Utility method used by evaluateRule method. This method accepts source, target and operator to evaluate the expression. Uses switch
     * statement to evaluate the rule. Converts the source and target values depending on the operator type. For multi picklist specific
     * operators, uses set methods to evaluate the rules and returns result
     */
    private Boolean evaluateWithOperator(Object sourceValue, String operator, Object targetValue) {
        Boolean meetsCriteria = false;
        String sourceStringVal = sourceValue != null ? String.valueOf(sourceValue) : null;
        String targetStringVal = targetValue != null ? String.valueOf(targetValue) : null;
        system.debug('sourceStringVal=='+sourceStringVal);
        system.debug('operator=='+operator);
        system.debug('targetStringVal=='+targetStringVal);
        if (stringOperatorSet.contains(operator)) {
            switch on operator {
                when 'Equals' {
                    meetsCriteria = sourceStringVal == targetStringVal;
                    system.debug('meetsCriteria=='+meetsCriteria);
                } when 'Not Equals' {
                    meetsCriteria = sourceStringVal != targetStringVal;
                } when 'Starts With' {
                    meetsCriteria = String.isNotBlank(targetStringVal) && String.isNotBlank(sourceStringVal) && targetStringVal.startsWith(sourceStringVal);
                } when 'Contains' {
                    meetsCriteria = String.isNotBlank(targetStringVal) && String.isNotBlank(sourceStringVal) && targetStringVal.contains(sourceStringVal);
                    system.debug('contains : meetsCriteria=='+meetsCriteria);
                } when 'Does not Contains' {
                    meetsCriteria = String.isNotBlank(sourceStringVal) && String.isNotBlank(sourceStringVal) && !targetStringVal.contains(sourceStringVal);
                } when else {
                    if (operator == 'Includes' || operator == 'Excludes') {
                        Set<String> sourceValueSet = new Set<String>();
                        if (String.isNotBlank(sourceStringVal)) {
                            sourceValueSet.addAll(sourceStringVal.split(PICKLIST_DELIMITER));
                        }
                        Set<String> targetValueSet = new Set<String>();
                        if (String.isNotBlank(targetStringVal)) {
                            targetValueSet.addAll(targetStringVal.split(PICKLIST_DELIMITER));
                        }
                        meetsCriteria = (operator == 'Includes' && sourceValueSet.size() > 0) || operator == 'Excludes' ? true : false;
                        for (String each : targetValueSet) {
                            if ((operator == 'Includes' && !sourceValueSet.contains(each))
                               || (operator == 'Excludes' && sourceValueSet.contains(each))) {
                                meetsCriteria = false;
                                break;
                            }
                        }
                    }
                }
            }
        } else {
            Decimal sourceDecimalVal = String.isNotBlank(sourceStringVal) ? Decimal.valueOf(sourceStringVal) : 0;
            Decimal targetDecimalVal = String.isNotBlank(targetStringVal) && !String.isNotBlank('|') ? Decimal.valueOf(targetStringVal) : 0;
            
            switch on operator {
                when 'Less Than' {
                    meetsCriteria = sourceDecimalVal < targetDecimalVal;
                } when 'Greater Than' {
                    meetsCriteria = sourceDecimalVal > targetDecimalVal;
                } when 'Less or equal' {
                    meetsCriteria = sourceDecimalVal <= targetDecimalVal;
                } when 'Greater or equal' {
                    meetsCriteria = sourceDecimalVal >= targetDecimalVal;
                }when 'Between' {
                   	List<String> Values =  targetStringVal.split('\\|');
                    Decimal lowerValue = Values.size() == 2 ? Decimal.valueOf(Values[0]) : 0; 
                    Decimal upperValue = Values.size() == 2 ? Decimal.valueOf(Values[1]) : 0; 
                    meetsCriteria = (lowerValue <= sourceDecimalVal)&&(sourceDecimalVal<=upperValue);
                } 
                when else {
                    meetsCriteria = false;
                }
            }
        }
        return meetsCriteria;
    }
    
   
 }