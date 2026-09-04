({
    genPDF : function(component,event,helper) {
        var recId = component.get('v.recordId');
        //var self = this;
        var action = component.get("c.generatePDF");
        action.setParams({ "fiRecID" : recId });
        action.setCallback(this, function(response) {
            var state = response.getState(); //fetch the response state
            //alert('state11 ' + state);
            if (state === "SUCCESS") {
               
                var result = response.getReturnValue();
                component.set("v.docId",result.docId);
                component.set("v.theme",result.formFactor);
                component.set("v.pName",result.profileName);

                //alert('result ' +JSON.stringify(result));
                //$A.get("e.force:closeQuickAction").fire();
                //$A.get('e.force:refreshView').fire();
                
                if(result){       
                    this.displayToast('success', 'success', 'File Created Successfully', 3000);
                    this.openPDFModal(component,event,helper);                           
                }                            
            }
            else {   
                let errorMsg = response.getError()[0];
                alert(JSON.stringify(errorMsg));
            }
        });
        $A.enqueueAction(action); 
    },
    openPDFModal : function(component,event,helper) {
        var dId = component.get("v.docId"); 
        var context = component.get("v.theme");

        if(dId && context == 'Theme4t'){//Theme4t
            $A.createComponent("c:FIPrintReportAuraModal",
                {
                    "documentId" : dId,
                    "theme" : context,
                    "pflName" : component.get("v.pName")
                },
                function(content, status) {
                    if (status === "SUCCESS") {
                        var modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: "FieldInvestigationReportPage.pdf",
                            body: modalBody, 
                            showCloseButton: true,
                            closeCallback: function(ovl) {
                                component.find("overlayLib").notifyClose();
                            }
                        }).then(function(overlay){
                            //console.log("Overlay is made");
                        });
                    }
                }
            );
        }
    },
    displayToast : function(myType,myTitle,myMessage,myDuration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : myTitle,
            message: myMessage,
            duration: myDuration,
            type: myType,
            mode: 'dismissible'
        });
        toastEvent.fire();	
    }
})