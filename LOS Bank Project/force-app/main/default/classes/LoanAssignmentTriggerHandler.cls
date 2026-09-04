/**
 * @author        Joshna
 * @date          11-Jun-2023
 * @description   Handler for Loan Assignment Trigger
 * @reference     TAT creation
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  11-Jun-2023     Initial creation - added afterInsert & afterUpdate
 * Yash                    25-October-2023 Before Update Added
 */
public without sharing class LoanAssignmentTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
        for(String buStr : this.getBusinessUnitNames()){
            if(this.getBusinessUnitNewList(buStr).isEmpty()){
                continue;
            }
            Type objType=Type.forName(this.getServiceClassName(buStr));
            ServiceInterface objServ=(ServiceInterface)objType.newInstance();
            objServ.afterInsert(Trigger.new, Trigger.newMap);
        }
    }

    public override void afterUpdate() {
        for(String buStr : this.getBusinessUnitNames()){
            if(this.getBusinessUnitNewList(buStr).isEmpty()){
                continue;
            }
            Type objType=Type.forName(this.getServiceClassName(buStr));
            ServiceInterface objServ=(ServiceInterface)objType.newInstance();
            objServ.afterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
    
    public override void beforeUpdate() {
        for(String buStr : this.getBusinessUnitNames()){
            if(this.getBusinessUnitNewList(buStr).isEmpty()){
                continue;
            }
            Type objType=Type.forName(this.getServiceClassName(buStr));
            ServiceInterface objServ=(ServiceInterface)objType.newInstance();
            objServ.beforeUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
}