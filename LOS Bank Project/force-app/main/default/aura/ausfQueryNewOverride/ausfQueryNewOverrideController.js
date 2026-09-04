({
    doInit : function(component,event,helper) {
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        var state = pageRef.state; // state holds any query params
        console.log('state = '+JSON.stringify(state));
        var base64Context = state.inContextOfRef;
        console.log('base64Context = '+base64Context);
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
            console.log('base64Context = '+base64Context);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        var applicationId = addressableContext.attributes.recordId == undefined ? '' : addressableContext.attributes.recordId;
        component.set('v.applicationId', applicationId);
        
    },
    
    handleCreateLoad : function(component, event, helper) {
        var defaultFieldValues = {};
        defaultFieldValues = {'type':'','applicationId':component.get('v.applicationId'),
                              'subtype':'','remarks':'', 'assignedToId':''};
        component.set('v.defaultFieldObject', defaultFieldValues);
    },
    
    handleRecordSubmit : function(component, event, handler) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        component.find('recordEditForm').submit(fields);	
    },
    
    handleSuccess : function(component,event,helper) {
        var record = event.getParams();  
        console.log(JSON.stringify(record.response.id));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": record.response.id
        });
        navEvt.fire();
        
    },
    
    handleError : function(component,event,helper) {
        var errors = event.getParams('error');
    },
    
    handleCancel : function(component,event,helper) {
        window.history.go(-1);
    }
})