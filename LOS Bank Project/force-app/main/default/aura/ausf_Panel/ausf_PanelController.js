/**
 * Created by ngundurao on 25/09/22.
 */

({
    closePopup : function(component, event, helper) {
            component.set("v.isModalOpen", false);
            $A.get('e.force:refreshView').fire();
            var event = component.getEvent("refreshEvent");
            event.fire();
        },


     openPopup : function(component, event, helper) {
            component.set("v.isModalOpen", true);
            let componentName = "c:cibil_lwc";
            $A.createComponent(
                componentName,{
                    "aura:id": "componentContainer",
                    "recordId": component.get("v.recordId"),
                    "integrationChecklistRecordId": "a525i0000005kzCAAQ",
                    "isOwner": component.get("v.isOwner")
                },
                function (modalComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var body = component.get("v.componentContainer");
                        body = [];
                        body.push(modalComponent);
                        component.set("v.componentContainer", body);
                        component.set("v.buttonLabel", 'Refresh');
                        var modalComponent = component.find("modalContainer");
                        $A.util.removeClass(modalComponent, "fullDeviceWidth");
                        $A.util.addClass(modalComponent, "standardDeviceWidth");
                    } else {
                        throw new Error(errorMessage);
                    }
                }
            );
        }
});