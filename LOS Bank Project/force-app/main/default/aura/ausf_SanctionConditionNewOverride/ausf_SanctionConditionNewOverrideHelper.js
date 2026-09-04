({
    getCurrentUserId : function(component,event,helper) {
        var action = component.get("c.returnCurrentUserLoggedInId");
        action.setParams({recordId : component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.createSanctionRecord(response.getReturnValue(),component.get('v.recordId'));
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    createSanctionRecord : function(userId, loanId){
        var windowHash = window.location.hash;
        if(userId!=null || userId!=''){
            var createRecordEvent = $A.get('e.force:createRecord');
            let todaysDate = new Date();
            createRecordEvent.setParams({
                'entityApiName': 'Sanction_Condition__c',
                'defaultFieldValues':{
                    'Raised_By__c':userId,
                    'Date_Time__c':todaysDate.toISOString(),
                    'Loan_Application__c':loanId
                },
                'panelOnDestroyCallback': function(event) {
                    window.location.href = 'https://ausfb2022--uat.sandbox.lightning.force.com/lightning/r/Loan_Application__c/a2b71000000B5h8AAC/view';
                }
                
                
            });
            createRecordEvent.fire();
        }
    }
})