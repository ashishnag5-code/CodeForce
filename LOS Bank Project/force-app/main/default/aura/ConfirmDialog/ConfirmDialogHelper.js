({
   //dynamic toast message alert function
   //It will take dynamic input parameters from controller methods
   //We used this for displaying error and success 
    showToast : function(title, message, error) {
        let toastParams = {
            title: title,
            message: message, // Error message
            type: error
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})