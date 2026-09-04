public without sharing class JSONReservedSerializer_AUSF {
    
    private Map<String,String> mapReserveKeywordFromMetadata;
    private Object objectResponse;
    private Boolean boolCheckForValues;
    public static Boolean isReserveKeyPresent = false;
    JSONGenerator objJSONGenerator = JSON.createGenerator(true);
    
    JSONReservedSerializer_AUSF(Object objectResponse,Map<String,String> mapReserveKeywordFromMetadata,Boolean boolCheckForValues){
        this.mapReserveKeywordFromMetadata = mapReserveKeywordFromMetadata;
        this.objectResponse = objectResponse;
        this.boolCheckForValues = boolCheckForValues;
        startTravesing();
    }
    
    void startTravesing(){
        if(objectResponse ==null){
            objJSONGenerator.writeNull();
        }else if(objectResponse instanceOf Map<String,Object>){
            traverseMap((Map<String,Object>)objectResponse);
        }else if(objectResponse instanceOf List<Object>){
            traverseList((List<Object>)objectResponse);
        }else {
            objJSONGenerator.writeObject(objectResponse);
        }
    } 
    
    public String convertToString(){
        return objJSONGenerator.getAsString();
    }
    
    void traverseMap(Map<String,Object> mapJSONKeyAndValue){
        List<String> keys = new List<String>(mapJSONKeyAndValue.keySet());
        keys.sort();
        
        objJSONGenerator.writeStartObject();
        for(String key:keys){
            Object value = mapJSONKeyAndValue.get(key);
            if(mapReserveKeywordFromMetadata != null && mapReserveKeywordFromMetadata.get(key) != null){
                key = mapReserveKeywordFromMetadata.get(key);
            }
            
            /*if(boolCheckForValues && mapReserveKeywordFromMetadata !=null && mapReserveKeywordFromMetadata.get(String.valueOf(value)) !=null){
                value = mapReserveKeywordFromMetadata.get(String.valueOf(value));
            }*/
            
            objJSONGenerator.writeFieldName(key);
            
            if(value == null){
                objJSONGenerator.writeNull();
            }else if(value instanceOf Map<String,Object>){
                traverseMap((Map<String,Object>)value);
            }else if(value instanceOf List<Object>){
                traverseList((List<Object>)value);
            }else {
                objJSONGenerator.writeObject(value);
            }
        }
        objJSONGenerator.writeEndObject();
        
    }
    
    void traverseList(List<Object> lstObjects){
        objJSONGenerator.writeStartArray();
        for(Object obj:lstObjects){
            if(obj == null){
                objJSONGenerator.writeNull();
            }else if(obj instanceof Map<String,Object>){
                traverseMap((Map<String,Object>)obj);
            }else if(obj instanceOf List<Object>){
                traverseList((List<Object>)obj);
            }else {
                objJSONGenerator.writeObject(obj);
            }
        }
        objJSONGenerator.writeEndArray();
    }
    
    public static String replaceJSONKeywords(String strJsonResponse){
        String strJson = '';
        Map<String,String> mapReserveKeywordFromMetadata = fetchReserveKeywords(strJsonResponse);
        try{
            if(!String.isEmpty(strJsonResponse)){
                strJson = new JSONReservedSerializer_AUSF(JSON.deserializeUntyped(strJsonResponse),mapReserveKeywordFromMetadata,isReserveKeyPresent).convertToString();
            }else{
                strJson =  strJsonResponse;
            }
        }catch(JSONException objJsonException){
            system.debug('error is'+objJsonException);
        }
        return strJson;
        
    }
    
    public static Map<String, String> fetchReserveKeywords(String strJsonResponse){
        Map<String, String> mapStaticReserveKeywords;
        if(mapStaticReserveKeywords == null){
            mapStaticReserveKeywords = new Map<String, String>();
            //List<Reserve_Keyword_AUSFB__mdt> lstReserveKeywordFromOrg =[SELECT MasterLabel, DeveloperName 
                                                                        //FROM Reserve_Keyword_AUSFB__mdt Where Active_AUSFB__c =true];
			List<Reserve_Keyword_AUSFB__mdt> lstReserveKeywordFromOrg = Reserve_Keyword_AUSFB__mdt.getAll().values();
            for(Reserve_Keyword_AUSFB__mdt objReserveKey :lstReserveKeywordFromOrg){
                if(objReserveKey.Active_AUSFB__c){
                    if(strJsonResponse.contains(objReserveKey.MasterLabel)){
                       isReserveKeyPresent = true; 
                    }
                    mapStaticReserveKeywords.put(objReserveKey.MasterLabel,objReserveKey.DeveloperName);
                }
            }
        }
        return mapStaticReserveKeywords;
    }
    
}