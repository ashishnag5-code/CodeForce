/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
/*trigger ContentVersionTrigger on ContentVersion (before insert, after insert, after update, before update, after delete, after undelete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            System.debug('Before Insert');
        }
        when AFTER_INSERT {
            System.debug('After Insert');
            
        }
        when BEFORE_UPDATE {
            System.debug('Before Update');
        }
        when AFTER_UPDATE {
            System.debug('After Update');
            MultipleFileUploadController.handleCartCallBackResponse(Trigger.newMap);
        }
        when else {
            System.debug('Something went wrong');
        }
    }
    
}*/
trigger ContentVersionTrigger on ContentVersion (before insert, after insert, after update, before update, before delete,after undelete) {
    new ContentVersionTriggerHandler().run('ContentVersion', 'ContentVersion_Trigger__c');
}