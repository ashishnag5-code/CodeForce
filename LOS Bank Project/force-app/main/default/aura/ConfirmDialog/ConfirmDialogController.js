({
    handleConfirmDialogYes: function(component, event, helper) {
        // Perform the action upon confirmation
        var action = component.get("c.updateLeadToLoan"); 
        action.setParams({
            loanAppId : component.get("v.recordId")
        }); 
        action.setCallback(this,function(response){
            var state = response.getState();
            //if callback is Success then show toast message and close the modal popup
            if(state === "SUCCESS")
            {
                //pass parameters to helper showToast method  
                let resp = response.getReturnValue();
                if(!resp.isError){
                    helper.showToast('Success !', resp.message, 'success');
                }
                else{
                    helper.showToast('ERROR !', resp.message, 'error');
                }
                //helper.showToast('Success !', 'Lead converted Successfully', 'success');
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    handleConfirmDialogNo: function(component, event, helper) {
        // Close the dialog
        //helper.closeDialog(component);
        $A.get("e.force:closeQuickAction").fire()
    }
})