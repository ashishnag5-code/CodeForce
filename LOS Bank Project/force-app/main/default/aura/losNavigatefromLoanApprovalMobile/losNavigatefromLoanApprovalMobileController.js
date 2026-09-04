({
	init : function(component, event, helper) {
        //var recordId = component.get("v.pageReference").state.c__id;
        var recordId = component.get("v.recordId");
		console.log('%%% '+recordId);
        var action = component.get("c.getLoanAppRecord");
        action.setParams({ strApprovalId : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppId = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": oppId
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);        
	}
})