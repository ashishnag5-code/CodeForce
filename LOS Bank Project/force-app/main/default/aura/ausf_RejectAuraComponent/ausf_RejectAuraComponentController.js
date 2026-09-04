({
    handleExit : function(component, event, helper) {
        console.log('test id '+component.get('v.recordId'));
        $A.get("e.force:closeQuickAction").fire()
        component.find("navigation")
        .navigate({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : component.get('v.recordId'),
                "actionName"    :  "view"   //clone, edit, view
            }
        }, true);
        
        
    }


})