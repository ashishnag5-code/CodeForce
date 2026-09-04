({
    closeCurrentComponent : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        
        var navService = component.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Home'
            }
        };
        navService.navigate(pageReference);
        dismissActionPanel.fire();
    }
})