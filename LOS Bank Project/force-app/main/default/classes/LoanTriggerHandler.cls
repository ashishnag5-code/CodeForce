/*******************************************************************************************
* @Name         LoanTriggerHandler
* @Author       Harshpreet Singh 
* @Description  This is the trigger handler for Opportunity/Loan trigger.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date               Description
*-------------------------------------------------------------------------------------------
*  1.0          Harshpreet Singh      08/17/2021           Initial Creation                                                      
*******************************************************************************************/
public with sharing class LoanTriggerHandler extends TriggerHandler{
    public override void beforeInsert(){
        for(String buStr : this.getBusinessUnitNames()){
            if(this.getBusinessUnitNewList(buStr).isEmpty()){
                continue;
            }
            Type objType=Type.forName(this.getServiceClassName(buStr));
            ServiceInterface objServ=(ServiceInterface)objType.newInstance();
            objServ.beforeInsert(this.getBusinessUnitNewList(buStr));
        }
        
    }

    public override void beforeUpdate(){
        ServiceInterface objServ=new LoanTriggerService();
        objServ.beforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
    }

    public override void afterInsert() {
        for(String buStr : this.getBusinessUnitNames()){
            if(this.getBusinessUnitNewList(buStr).isEmpty()){
                continue;
            }
            Type objType=Type.forName(this.getServiceClassName(buStr));
            ServiceInterface objServ=(ServiceInterface)objType.newInstance();
            objServ.afterInsert(Trigger.new,Trigger.newMap);
        }
    }

    public override void afterUpdate() {
        ServiceInterface objServ = new LoanTriggerService();
        objServ.afterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}