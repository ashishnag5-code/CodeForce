({
	init : function(component, event, helper) {
        var recordId = component.get("v.pageReference").state.c__id;
		console.log('%%% '+recordId);
        var action = component.get("c.updateAssignmentOwner");
        action.setParams({ strAssignmentId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var oppId = res.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);        
	}
})