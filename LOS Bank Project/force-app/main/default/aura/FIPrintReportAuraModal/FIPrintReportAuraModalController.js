({
    doInit : function(component, event, helper) {   
        if(component.get("v.pflName") && component.get("v.pflName") == "Field Investigator"){
            component.set("v.isDownload",false);
        }
        else if(component.get("v.pflName") && component.get("v.pflName") != "Field Investigator"){
            component.set("v.isDownload",true);
        }
	},
    handlePreview : function(component, event, helper) {
        // Mobile Form Factor
        if(component.get("v.theme") == 'Theme4t'){ 
            
            var navEvt = $A.get("e.force:navigateToSObject");
            if(navEvt){
                navEvt.setParams({
                    "recordId": component.get("v.documentId") ,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        }
    },
    handleDownload : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "salesforce1://sObject/"+ component.get("v.documentId") +"/download"
        });
        urlEvent.fire();
    }
})