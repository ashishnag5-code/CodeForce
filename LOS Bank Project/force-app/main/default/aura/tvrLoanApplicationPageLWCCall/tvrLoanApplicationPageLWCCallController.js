({
	init : function(component, event, helper) {
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
	},
	cancel : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
	dismissActionPanel.fire();
	}
	
})