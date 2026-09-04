/**
 * Created by ngundurao on 20/10/22.
 */

 public without sharing virtual class TriggerHandler {

    /** VARIABLES **/
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap; //Map of handlername to the number of times run() was invoked
    private static Set<String> bypassedHandlers; //Set of handlers who will be bypassed
    @TestVisible
    private List<Business_Unit_Data__mdt> businessUnitDataList; //List of the business unit metadata records for an object
    @TestVisible
    private String objectName; //Api name of the object on which triggger is running
    private Map<String,Map<Id,sObject>> oldBusinessRecordMap; //Map of Business Unit name to the corresponding trigger.oldMap
    private Map<String,Map<Id,sObject>> newBusinessRecordMap; //Map of Business Unit name to the corresponding trigger.newMap
    private Map<String,List<sObject>> businessMap; //Map of Business Unit name to the corresponding trigger.new
    private Map<String,String> serviceClassMap; //Map of Business Unit name to the corresponding service Apex class name
    private static Map<String,List<Business_Unit_Data__mdt>> businessUnitDataMap;
    /** STATIC BLOCKS & CONSTRUCTORS **/
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        businessUnitDataMap=new Map<String,List<Business_Unit_Data__mdt>>();
        for(Business_Unit_Data__mdt bu:[SELECT Id, Apex_Class__c, BU_Logic_Fields__c, BU_Logic_Values__c, Business_Unit_Name__c,Object__c
        FROM Business_Unit_Data__mdt]){
            if(!businessUnitDataMap.containsKey(bu.Object__c)){
                businessUnitDataMap.put(bu.Object__c,new List<Business_Unit_Data__mdt>());
            }
            businessUnitDataMap.get(bu.Object__c).add(bu);
        }
    }

    public TriggerHandler() {
    }


    /** CONTEXT METHODS **/

    @TestVisible
    protected virtual void beforeInsert(){}
    @TestVisible
    protected virtual void beforeUpdate(){}
    @TestVisible
    protected virtual void beforeDelete(){}
    @TestVisible
    protected virtual void afterInsert(){}
    @TestVisible
    protected virtual void afterUpdate(){}
    @TestVisible
    protected virtual void afterDelete(){}
    @TestVisible
    protected virtual void afterUndelete(){}


    /** PUBLIC INSTANCE METHODS **/

    /**
    * Main method to set the BU collections and call context methods
    *
    * @param  objName the api name of the object in context
    * @return         none
    */
    public void run(String objName, String disableField) {
        
        if(!validateRun()) {
            return;
        }
        if(getTriggerDisabledValue(disableField)){
            return;
        }
        this.objectName=objName;
        fetchBusinessUnitData();
        if(!this.businessUnitDataList.isEmpty()){
            populateBusinessUnitMaps();
        }
        if(addToLoopCount()){
            return;
        }
        // dispatch to the correct handler method
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
            when AFTER_UNDELETE {
                this.afterUndelete();
            }
        }
    }

    /**
    * To set the max run count for the current handler
    *
    * @param  max   maximum count for consecutive trigger runs
    * @return       none
    */
    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    /**
    * To clear the max run count for the current handler
    *
    * @param     none
    * @return    none
    */
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /** PUBLIC STATIC METHODS **/

    /**
    * To bypass a specific trigger handler class
    *
    * @param  handlerName    name of the trigger handler apex class to bypass
    * @return                none
    */
    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    /**
    * To remove a bypass of a specific trigger handler class
    *
    * @param  handlerName    name of the trigger handler apex class to bypass
    * @return                none
    */
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    /**
    * To check if a specific trigger handler class is getting bypassed in current context
    *
    * @param  handlerName    name of the trigger handler apex class to bypass
    * @return                True, if bypassed, otherwise False
    */
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    /**
    * To clear all handler bypasses
    *
    * @param     none
    * @return    none
    */
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    /**
    * To increment the loop count
    *
    * @param     none
    * @return    True, if max loop count exceeded, otherwise false
    */
    @TestVisible
    private Boolean addToLoopCount() {
        String handlerName = getHandlerName();
        if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
            return TriggerHandler.loopCountMap.get(handlerName).increment();
        }
        return false;
    }

    /**
    * To validate the trigger context
    *
    * @param     none
    * @return    True, if validated, otherwise False
    */
    @TestVisible
    private Boolean validateRun() {
        if(!Trigger.isExecuting) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }

    /**
    * To clear all handler bypasses
    *
    * @param     none
    * @return    Name of the current trigger handler apex class
    */
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }

    /**
    * To fetch the custom metdata records for business units
    *
    * @param     none
    * @return    none
    */
    private void fetchBusinessUnitData(){
        if(businessUnitDataMap.containsKey(this.objectName)){
            this.businessUnitDataList=businessUnitDataMap.get(this.objectName);
        }else{
            this.businessUnitDataList=new List<Business_Unit_Data__mdt> ();
        }
        /*this.businessUnitDataList=[SELECT Id, Apex_Class__c, BU_Logic_Fields__c, BU_Logic_Values__c, Business_Unit_Name__c,Object__c
                              FROM Business_Unit_Data__mdt
                              WHERE Object__c=:this.objectName];*/
        this.serviceClassMap=new Map<String,String>();
        for(Business_Unit_Data__mdt objBU:this.businessUnitDataList){
            if(objBU.Business_Unit_Name__c=='Default'){
                continue;
            }
            this.serviceClassMap.put(objBU.Business_Unit_Name__c,objBU.Apex_Class__c);
        }
    }

    /**
    * To populate the business unit record maps based on trigger context
    *
    * @param     none
    * @return    none
    */
    @TestVisible
    private void populateBusinessUnitMaps(){
        try{
            this.oldBusinessRecordMap=new Map<String,Map<Id,sObject>>();
            this.newBusinessRecordMap=new Map<String,Map<Id,sObject>>();
            this.businessMap=new Map<String,List<sObject>>();
            if(this.businessUnitDataList.isEmpty()){
                throw new TriggerHandlerException('No business units present.');
            }
            if(this.businessUnitDataList.size()==1){
                handleDefaultType();
                return;
            }
            List<String> buLogicFields=this.businessUnitDataList[0] != null && this.businessUnitDataList[0].BU_Logic_Fields__c != null && this.businessUnitDataList[0].BU_Logic_Fields__c.contains(',') ? this.businessUnitDataList[0].BU_Logic_Fields__c.split(',') : new List<String>{};
            Map<String,List<sObject>> businessUnitMap=new Map<String,List<sObject>>();
            Map<String,String> buValueToBuNameMap=new Map<String,String>();
            for(Business_Unit_Data__mdt objBU:this.businessUnitDataList){
                if(objBU.Business_Unit_Name__c=='Default' && !Test.isRunningTest()){
                    continue;
                }
                this.businessMap.put(objBU.Business_Unit_Name__c,new List<sObject>());
                this.oldBusinessRecordMap.put(objBU.Business_Unit_Name__c,new Map<Id,sObject>());
                this.newBusinessRecordMap.put(objBU.Business_Unit_Name__c,new Map<Id,sObject>());
                buValueToBuNameMap.put(objBU.BU_Logic_Values__c,objBU.Business_Unit_Name__c);
            }
            List<sObject> newTriggerRecordList=Trigger.new != null?Trigger.new:new List<sObject>();
            List<sObject> oldTriggerRecordList=Trigger.old != null?Trigger.old:new List<sObject>();
            for(sObject sObj:newTriggerRecordList){
                String recordValueString='';
                for(String objFld:buLogicFields){
                    String fieldVal='';
                    if(objFld.contains('RecordType.')){
                        fieldVal=getRecordTypeName(objFld,(Id)sObj.get('RecordTypeId'));
                    }else{
                        fieldVal=String.valueOf(sObj.get(objFld));
                    }
                    recordValueString+=(recordValueString=='')?fieldVal:(','+fieldVal);
                }
                String buName=buValueToBuNameMap.get(recordValueString);
                if (this.businessMap.get(buName) != null) {
                    this.businessMap.get(buName).add(sObj);
                }
                if (this.newBusinessRecordMap.get(buName) != null) {
                    this.newBusinessRecordMap.get(buName).put((Id)sObj.get('Id'),sObj);
                }
            }
            for(sObject sObj:oldTriggerRecordList){
                String recordValueString='';
                for(String objFld:buLogicFields){
                    String fieldVal='';
                    if(objFld.contains('RecordType.')){
                        fieldVal=getRecordTypeName(objFld,(Id)sObj.get('RecordTypeId'));
                    }else{
                        fieldVal=String.valueOf(sObj.get(objFld));
                    }
                    recordValueString+=(recordValueString=='')?fieldVal:(','+fieldVal);
                }
                String buName=buValueToBuNameMap.get(recordValueString);
                if (this.oldBusinessRecordMap.get(buName) != null) {
                    this.oldBusinessRecordMap.get(buName).put((Id)sObj.get('Id'),sObj);
                }
            }
        }catch(Exception e){
            System.debug('populateBusinessUnitMaps Exception-> '+e.getLineNumber());
        }
    }

    /**
    * To handle the case of object with single type of records
    *
    * @param     none
    * @return    none
    */
    @TestVisible
    private void handleDefaultType(){
        Business_Unit_Data__mdt defaultObj=this.businessUnitDataList[0];
        this.businessMap.put(defaultObj.Business_Unit_Name__c,new List<sObject>());
        this.oldBusinessRecordMap.put(defaultObj.Business_Unit_Name__c,new Map<Id,sObject>());
        this.newBusinessRecordMap.put(defaultObj.Business_Unit_Name__c,new Map<Id,sObject>());
        this.serviceClassMap.put(defaultObj.Business_Unit_Name__c,defaultObj.Apex_Class__c);
        List<sObject> newTriggerRecordList=Trigger.new != null?Trigger.new:new List<sObject>();
        List<sObject> oldTriggerRecordList=Trigger.old != null?Trigger.old:new List<sObject>();
        for(sObject sObj:newTriggerRecordList){
            this.businessMap.get(defaultObj.Business_Unit_Name__c).add(sObj);
            this.newBusinessRecordMap.get(defaultObj.Business_Unit_Name__c).put((Id)sObj.get('Id'),sObj);
        }
        for(sObject sObj:oldTriggerRecordList){
            this.oldBusinessRecordMap.get(defaultObj.Business_Unit_Name__c).put((Id)sObj.get('Id'),sObj);
        }
    }

    /** GETTER METHODS **/
    /**
    * To get the name of the record type
    *
    * @param     fieldName
    * @param     recordTypeId
    * @return    name of the recordtype
    */
    @TestVisible
    private String getRecordTypeName(String fieldName, Id recordTypeId){
        if(fieldName=='RecordType.DeveloperName'){
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
        }else if(fieldName=='RecordType.Name'){
            return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }
        return null;
    }

    /**
     * To check whether the trigger is disabled or not
     *
     * @param   fieldName
     * @return  True if trigger is disabled, otherwise False
     */
    private Boolean getTriggerDisabledValue(String fieldName){
        Boolean boolToReturn=(Boolean)Trigger_Deactivation_Settings__c.getInstance().get(fieldName);
        return (boolToReturn==null)?false:boolToReturn;
    }

    /**
    * To get the custom metadata records for business units
    *
    * @param     none
    * @return    list of all the custom metadata type records for the current object
    */
    public List<Business_Unit_Data__mdt> getBusinessUnitData(){
        return this.businessUnitDataList;
    }

    /**
    * To get the trigger.oldMap for passed in business unit
    *
    * @param    businessUnitName    name of the business unit to fetch the records for
    * @return                       trigger.oldMap for the passed in business unit
    */
    public Map<Id,sObject> getBusinessUnitOldMap(String businessUnitName){
        if(!this.oldBusinessRecordMap.containsKey(businessUnitName)){
            //throw new TriggerHandlerException('Business Unit not found.');
            return new Map<Id,sObject>();
        }
        return this.oldBusinessRecordMap.get(businessUnitName);
    }

    /**
    * To get the trigger.newMap for passed in business unit
    *
    * @param    businessUnitName    name of the business unit to fetch the records for
    * @return                       trigger.newMap for the passed in business unit
    */
    public Map<Id,sObject> getBusinessUnitNewMap(String businessUnitName){
        if(!this.newBusinessRecordMap.containsKey(businessUnitName)){
            //throw new TriggerHandlerException('Business Unit not found.');
            return new Map<Id,sObject>();
        }
        return this.newBusinessRecordMap.get(businessUnitName);
    }

    /**
    * To get the trigger.new for passed in business unit
    *
    * @param    businessUnitName    name of the business unit to fetch the records for
    * @return                       trigger.new for the passed in business unit
    */
    public List<sObject> getBusinessUnitNewList(String businessUnitName){
        if(!this.businessMap.containsKey(businessUnitName)){
            //throw new TriggerHandlerException('Business Unit not found.');
            return new List<sObject>();
        }
        return this.businessMap.get(businessUnitName);
    }

    /**
    * To get all the business unit names
    *
    * @param    none
    * @return   set of all business unit names present in custom metadata type for the current object
    */
    public Set<String> getBusinessUnitNames(){
        return this.newBusinessRecordMap.keySet();
    }

    /**
    * To get the apex service class for passed in business unit
    *
    * @param    businessUnitName    name of the business unit to fetch the records for
    * @return                       name of the apex service class for the passed in business unit
    */
    public String getServiceClassName(String businessUnitName){
        if(!this.serviceClassMap.containsKey(businessUnitName)){
            throw new TriggerHandlerException('Business Unit not found.');
        }
        return this.serviceClassMap.get(businessUnitName);
    }

    /** INNER CLASSES **/

    /**
    * inner class for managing the loop count per handler
    */
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    /**
    * Custom Exception class
    */
    public class TriggerHandlerException extends Exception {}
}