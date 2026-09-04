({
	scriptsLoaded : function(component, event, helper) {
        component.set("v.isLoaded", true);
        setTimeout(function(){
            window.print();
        }, 2000);
    },
    doInit : function(component, event, helper) {
    	var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var i;
        var componentName;
        var recordId;
        var integrationStatusRecordId;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
			if (sParameterName[0] === "componentName") {
                componentName = sParameterName[1];
            } else if (sParameterName[0] === "recordId") {
                recordId = sParameterName[1];
            } else if (sParameterName[0] === "integrationStatusRecordId") {
                integrationStatusRecordId = sParameterName[1];
            }
        }
        $A.createComponent(
            componentName,{
                "aura:id": "componentContainer",
                "recordId": recordId,
                "integrationStatusRecordId": integrationStatusRecordId
            },
            function (modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    var body = component.get("v.componentContainer");
                    body = [];
                    body.push(modalComponent);
                    component.set("v.componentContainer", body);
                } else {
                    throw new Error(errorMessage);
                }
            }
        );
    }
})