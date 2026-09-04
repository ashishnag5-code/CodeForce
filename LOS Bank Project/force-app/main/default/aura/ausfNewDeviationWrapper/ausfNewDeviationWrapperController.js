({
    reInit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    handlePageRedirection : function(component, event, helper) {
        let deviationId = event.getParam('deviationId');
        console.log('value from aura :'+ deviationId);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": deviationId,
                    "actionName":"view"
                },
                "state": {}
            },
            focus: true
        }).then(function(response) {
            console.log(response)
        }).catch(function(error) {
            console.log(error);
        });

    }
})