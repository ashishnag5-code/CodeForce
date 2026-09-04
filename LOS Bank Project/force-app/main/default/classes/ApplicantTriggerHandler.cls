/*******************************************************************************************
 * @Name         ApplicantTriggerHandler
 * @Author       Mangesh Khandekar
 * @Description  Handler class for Applicant Trigger
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Mangesh Khandekar        27/10/2022         Initial Creation 
*******************************************************************************************/
public with sharing class ApplicantTriggerHandler extends TriggerHandler{

    public static Boolean byPassApplicantTrigger = false; //Bypass incase of single field update - R2-34

    public override void afterInsert(){
        if(byPassApplicantTrigger==false){
            system.debug('intrigger>>> ');
            for(String buStr : this.getBusinessUnitNames()){
                if(this.getBusinessUnitNewList(buStr).isEmpty()){
                    continue;
                }
                Type objType=Type.forName(this.getServiceClassName(buStr));
                ServiceInterface objServ=(ServiceInterface)objType.newInstance();
                objServ.afterInsert(Trigger.new,Trigger.newMap);
            }
        }
            /*ApplicantTriggerService serviceInstance = new ApplicantTriggerService();
            serviceInstance.afterInsert(Trigger.new, Trigger.newMap);*/
        
    }
    public override void beforeInsert(){
        if(byPassApplicantTrigger==false){
            ApplicantTriggerService serviceInstance = new ApplicantTriggerService();
            serviceInstance.beforeInsert(Trigger.new);
        }
        
    }
    public override void beforeUpdate(){
        system.debug(LoggingLevel.WARN, byPassApplicantTrigger);
        if(byPassApplicantTrigger==false){
            ApplicantTriggerService serviceInstance = new ApplicantTriggerService();
            serviceInstance.beforeUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
        }
        
    }
    
    public override void afterUpdate(){
        system.debug(LoggingLevel.WARN, byPassApplicantTrigger);
        if(byPassApplicantTrigger==false){
            ApplicantTriggerService serviceInstance = new ApplicantTriggerService();
            serviceInstance.afterUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
        }
        
    }
}