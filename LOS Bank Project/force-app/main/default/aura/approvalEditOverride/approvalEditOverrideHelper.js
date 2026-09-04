({
    doInit : function(comp) {
        const action = comp.get('c.getApplicationFromApproval'),
            approvalId = comp.get('v.recordId');
        action.setParams({ approvalId });
        action.setCallback(this, (response) => {
            const state = response.getState();
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                comp.set('v.applicationId', response.getReturnValue());
            } else if(state === 'ERROR'){
                console.error(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})