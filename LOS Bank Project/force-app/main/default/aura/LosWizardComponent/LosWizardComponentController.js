({
	doinit : function(component, event, helper) {
        console.log('%%% '+component.get("v.sObjectName"));
        if (component.get("v.sObjectName") == 'Loan_Application__c') {
            var action = component.get("c.fetchDraftStage");
        	action.setParams({ strLoanAppId : component.get("v.recordId") });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert("From server: " + response.getReturnValue());
                    var resp = response.getReturnValue();
                    component.set("v.flowName",resp.strFlowName);
                    component.set("v.childToFlow",resp.strChildtoFlowName);
                    component.set("v.stageName",resp.strStageName);
                    /*
                    if(response.getReturnValue() =='QuickLoan'){
                    	component.set("v.flowName","Parent_Flow_QDE");
                        component.set("v.childToFlow","Parent_Flow_QDE_Default");
                        component.set("v.boolReFetchData",true);
                    }
                    else if(response.getReturnValue() =='RelatedApplicants'){
                        component.set("v.flowName","Parent_Flow_QDE");
            			component.set("v.childToFlow","Parent_Flow_QDE_Related_Applicant");
            			component.set("v.boolReFetchData",true);
                    }
                    else if(response.getReturnValue() =='LoanDetails'){
                        component.set("v.flowName","Parent_Flow_QDE");
            			component.set("v.childToFlow","Parent_Flow_QDE_Edit_LoanDetails");
            			component.set("v.boolReFetchData",true);
                    }
                    else if(response.getReturnValue() =='VehicleDetails'){
                        component.set("v.flowName","Parent_Flow_QDE");
            			component.set("v.childToFlow","Parent_Flow_QDE_Edit_Vehicles");
            			component.set("v.boolReFetchData",true);
                    }
                    else if(response.getReturnValue() =='FinancialDetails'){
                    	component.set("v.flowName","Parent_Flow_QDE");
            			component.set("v.childToFlow","Parent_Flow_QDE_Edit_Financials");
            			component.set("v.boolReFetchData",true); 
                    }
                    else{
                        component.set("v.flowName","Parent_Flow_QDE");
            			component.set("v.childToFlow","Parent_Flow_QDE_Default");
            			component.set("v.boolReFetchData",true);
                    }
                    */
                    component.set("v.boolReFetchData",true);
                    component.set("v.showWizard",true);
                }
        	});
            $A.enqueueAction(action);
        }
		if (component.get("v.sObjectName") == 'Applicant__c') {
            component.set("v.flowName","Edit_Applicant");
            component.set("v.childToFlow","Default");
            component.set("v.boolReFetchData",true);
            component.set("v.showWizard",true);
        }
	}
})