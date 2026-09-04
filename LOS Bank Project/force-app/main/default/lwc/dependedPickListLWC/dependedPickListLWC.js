import { LightningElement, wire, track , api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
 
export default class DependedPickListLWC extends LightningElement {
     
    @api objectApiName;
    @api objectRecordTypeId;
    @api controllerFieldApiName;
    @api controllerFieldLabel;
    @api dependentFieldApiName;
    @api dependentFieldLabel;
     
    @track controllerValue;
    @track dependentValue;
 
    controllingPicklist=[];
    dependentPicklist;
    @track finalDependentVal=[];
    @track isDependentValueRequired = true;
    // @track selectedControlling="--None--";
  
    showpicklist = false;
    dependentDisabled=true;
    showdependent = false;
    @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$objectRecordTypeId' })
    fetchPicklist({error,data}){
         
        if(data && data.picklistFieldValues){
          /*  let optionsValue = {}
            optionsValue["label"] = "--None--";
            optionsValue["value"] = "";
            this.controllingPicklist.push(optionsValue);  */
            data.picklistFieldValues[this.controllerFieldApiName].values.forEach(optionData => {
                this.controllingPicklist.push({label : optionData.label, value : optionData.value});
            });
 
            this.dependentPicklist = data.picklistFieldValues[this.dependentFieldApiName];
            this.showpicklist = true;
        } else if(error){
            console.log(error);
        }
    }
 
    fetchDependentValue(event){
        console.log(event.target.value);
        this.dependentDisabled = true;
        this.finalDependentVal=[];
        this.showdependent = false;
        const selectedVal = event.target.value;
        this.controllerValue = selectedVal;
        this.sendControllerValueToParentComponent();
        this.handleMandatoryCheckForDependentPicklist(selectedVal);
      //  this.finalDependentVal.push({label : "--None--", value : ""})
        let controllerValues = this.dependentPicklist.controllerValues;
        this.dependentPicklist.values.forEach(depVal => {
            depVal.validFor.forEach(depKey =>{
                if(depKey === controllerValues[selectedVal]){
                    this.dependentDisabled = false;
                    this.showdependent = true;
                    this.finalDependentVal.push({label : depVal.label, value : depVal.value});
                }
            });
              
        });
    }
 
    handleDependentPicklist(event){
        this.dependentValue = event.target.value;
        // send this to parent 
        let paramData = {controllerValue : this.controllerValue, dependentValue : this.dependentValue};
        //alert('param '+JSON.stringify(paramData));
        let ev = new CustomEvent('childmethod', 
                                 {detail : paramData}
                                );
        this.dispatchEvent(ev); 
    }

    // new method added to pass in the controller value back
    sendControllerValueToParentComponent(evt) {

        let paramData = {controllerValue : this.controllerValue, dependentValue : ''};
        const ev = new CustomEvent('childmethod', 
                                 {detail : paramData}
                                );
        this.dispatchEvent(ev); 

    }

    @api checkInputFordependendComponent() {
        if(this.isInputValid()) {
            let ev = new CustomEvent('validateflds', 
                                 {detail : true}
                                );
        this.dispatchEvent(ev);
        }
    }

    isInputValid() {
        let isValid = true;      
        console.log("isShowInp-- "+this.isShowInp);
        let inputFields = this.template.querySelectorAll(".validate");
        for(let inputField of inputFields)  {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        }    
        return isValid;
    }
    handleMandatoryCheckForDependentPicklist(value){
        this.isDependentValueRequired = (value != 'Other');
    }
    @api
    handleDependedCheck(){
        let isValidReturn = true;
        let inputField = this.template.querySelector('lightning-combobox[data-id="dependedPickVal"]');
        if(!inputField.value && this.controllerValue!='Other' && this.controllerValue!='End use'){
            inputField.setCustomValidity("Please provide a valid Rejection Sub Reason");
            isValidReturn = false;
        }
        else{
            inputField.setCustomValidity("");
            isValidReturn = true;
        }
        inputField.reportValidity();
        return isValidReturn;
    }
}