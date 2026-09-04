import { LightningElement, track, api } from 'lwc';
import { showToastMessage, setPicklistsValues, validate, getUniqueValue, getApplicantName } from 'c/lwcutilities';
import getLandAddressDetails from '@salesforce/apex/AddressComponentHandler.getLandAddressDetails'
import getCopyToLandAddressDetails from '@salesforce/apex/AddressComponentHandler.getCopyToLandAddressDetails'
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class LandAddressComponent extends LightningElement {

    @api applicantId
    @track landAddress={Address_Type__c:'Land'}
    @track sameAsOptions=[]
    @track isMobileScreen
    @track stateId
    @track districtId
    @track tehsilId
    @track villageId
    @track surveyId
    @track loadComponent
    @api fieldsToBeDisabled
    @api loanApplication;
    @api isNaApplicable;
    lookUpFields = ['State__c','District__c','Tehsil__c','Village__c','Khata_Khasara_Survey_Number__c']
    fieldsOnUI = ['State__c','District__c','Taluka__c','Village__c','Pincode__c','Land_mark__c','Khata_Khasara_Survey_Number__c']


    connectedCallback(){
        if(FORM_FACTOR == 'Small'){
            this.isMobileScreen=true
        }
        this.handleSameAsLogic()
        this.getExistingLandAddressData()
    }

    async getExistingLandAddressData(){
        this.landAddress = await getLandAddressDetails({applicantId: this.applicantId})
        if(this.landAddress && this.landAddress.Survey_Number__c){
            this.stateId = this.landAddress.Survey_Number__r.State__c
            this.districtId = this.landAddress.Survey_Number__r.District__c
            this.tehsilId = this.landAddress.Survey_Number__r.Tehsil__c
            this.villageId = this.landAddress.Survey_Number__r.Village__c
            this.surveyId = this.landAddress.Survey_Number__c
        }else if(!this.landAddress){
            this.landAddress={Address_Type__c:'Land'}
        }
        this.loadComponent=true
        setTimeout(() => {
            let boxes = this.template.querySelectorAll('.chckBox');
            boxes.forEach(checkbox => {
                if (checkbox.value == this.landAddress.Same_As__c) {
                    checkbox.checked = true;
                    let fieldsForSameAsValue=[]
                    if(this.landAddress.Same_As__c=='NA'){
                        fieldsForSameAsValue = ['State__c','District__c','Taluka__c','Village__c','Pincode__c','Land_mark__c','Khata_Khasara_Survey_Number__c']

                    }else{
                        fieldsForSameAsValue = ['State__c','District__c','Taluka__c','Pincode__c','Land_mark__c']
                    }
                    
                    this.disableFieldsAsPerMetadata(fieldsForSameAsValue, true)
                    //this.disableFieldsAsPerMetadata(this.setListofSameAsRelatedFields(), true)
                }
            });  
            this.disableFieldsAsPerMetadata(this.fieldsToBeDisabled, true) 
        }, 300); 
         
    }

    disableFieldsAsPerMetadata(fieldsToBeDisabled, isDisable){
        if(fieldsToBeDisabled && fieldsToBeDisabled.length>0){
            fieldsToBeDisabled.forEach(input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        if(this.lookUpFields.includes(inputToBeDisabled.name)){
                            let recordSelected = {name:inputToBeDisabled.recordTypeName, value: inputToBeDisabled.defaultRecordId}
                            inputToBeDisabled.enableOrDisableLookupFLd(recordSelected, isDisable);
                        }else{
                            inputToBeDisabled.disabled = isDisable
                        }
                    }))
                }
            })
            this.fieldsOnUI.forEach(input=>{
                if(!fieldsToBeDisabled.includes(input)){
                    if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                        this.template.querySelectorAll('[data-name="'+input+'"]').forEach(inputToBeDisabled=>{
                            if(this.lookUpFields.includes(inputToBeDisabled.name)){
                                let recordSelected = {name:inputToBeDisabled.recordTypeName, value: inputToBeDisabled.defaultRecordId}
                                inputToBeDisabled.enableOrDisableLookupFLd(recordSelected, false);
                            }else{
                                inputToBeDisabled.disabled = false
                            }
                        })
                    }
                }
            })
            
        }
        this.isLoading=false
    }

    handleLookupSelect(event){
        console.log(JSON.parse(JSON.stringify(event.detail)))
        let detail = event.detail
        if(detail.context == 'select'){
            if(detail.recordTypeName=='State'){
                this.stateId = detail.value
                this.landAddress.State__c=detail.name
            }else if(detail.recordTypeName=='District'){
                this.districtId = detail.value
                this.landAddress.District__c=detail.name
            }else if(detail.recordTypeName=='Tehsil'){
                this.tehsilId = detail.value
                this.landAddress.Taluka__c=detail.name
            }else if(detail.recordTypeName=='Village'){
                this.villageId = detail.value
                this.landAddress.Village__c=detail.name
            }else if(detail.recordTypeName=='Survey Number'){
                this.surveyId = detail.value
                this.landAddress.Survey_Number__c=this.surveyId
                this.landAddress.Khata_Khasara_Survey_Number__c=detail.name
            }
        }else if(detail.context == 'deselect'){
            let fields=[]
            if(detail.recordTypeName=='State'){
                this.stateId = detail.value
                fields = ['District','Tehsil','Village','Survey Number']
            }else if(detail.recordTypeName=='District'){
                this.districtId = detail.value
                fields = ['Tehsil','Village','Survey Number']
            }else if(detail.recordTypeName=='Tehsil'){
                this.tehsilId = detail.value
                fields = ['Village','Survey Number']
            }else if(detail.recordTypeName=='Village'){
                this.villageId = detail.value
                fields = ['Survey Number']
            }
            if(fields && fields.length>0){
                this.resestValues(fields)
            }
        }
    }

    resestValues(fields){
        if(fields.includes('State')){
            this.landAddress.State__c=''
            this.stateId=undefined
            this.template.querySelector('[data-name="State__c"]').callHandleRemove()
        }
        if(fields.includes('District')){
            this.landAddress.District__c=''
            this.districtId=undefined
            this.template.querySelector('[data-name="District__c"]').callHandleRemove()
        }
        if(fields.includes('Tehsil')){
            this.tehsilId=undefined
            this.landAddress.Taluka__c=''
            this.template.querySelector('[data-name="Taluka__c"]').callHandleRemove()
        }
        if(fields.includes('Village')){
            this.villageId=undefined
            this.landAddress.Village__c=''
            this.template.querySelector('[data-name="Village__c"]').callHandleRemove()
        }
        if(fields.includes('Survey Number')){
            this.surveyId=undefined
            this.landAddress.Khata_Khasara_Survey_Number__c=''
            this.landAddress.Survey_Number__c=''
            this.template.querySelector('[data-name="Khata_Khasara_Survey_Number__c"]').callHandleRemove()
        }
        
    }

    @api
    getLandAddress(){
        this.getExistingLandAddressData()
        return this.landAddress
    }

    @api
    handleValidations() {
        var valid;
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            let classlist = Array.from(inputCmp.classList)
            if(classlist && classlist.includes('validate')){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }else{
                return validSoFar
            }
        }, true);
        if(allValid1){
            valid=true
        }else{
            valid=false
        }
        return valid;
    }

    @api
    isValidateGenericLookup() {
        let isValid = true;
        if(this.landAddress.Same_As__c!='NA'){
            let checkStateOfValid = [];
            const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
            for (let val of objChild) {
                let recordSelected = {name:val.recordTypeName, value: val.defaultRecordId}
                let storeVal = val.validateChildFlds(recordSelected);
                checkStateOfValid.push(storeVal);
            }
            let staeOfValid = checkStateOfValid.includes("false");
            if (staeOfValid) {
                isValid = false;
                showToastMessage(this, "", "error", "Please fill mandatory details", "sticky");
            }
        }
        return isValid;
    }

    handleChange(event){
        let name = event.target.name
        let value = event.target.value
        this.landAddress[name] = value
    }

    handleSameAsLogic() {
        let sameasOptions = [];
        sameasOptions.push(
            {
                label: 'New',
                value: 'New',
                checked: false
            },
            {
                label: 'Permanent',
                value: 'Permanent',
                checked: false
            },
            {
                label: 'Current',
                value: 'Current',
                checked: false
            }

        )
        if( this.isNaApplicable ){
            sameasOptions.push({
                label: 'NA',
                value: 'NA',
                checked: false
            });
        }
        this.sameAsOptions = sameasOptions;
    }

    async handleCopyInfo(event){
        this.handleReset()
        let boxes = this.template.querySelectorAll('.chckBox');
        let selectedValue = event.target.value;
        let ischecked = event.target.checked;
        
        boxes.forEach(checkbox => {
            if (checkbox.value !== selectedValue) {
                checkbox.checked = false;
            }
        });
        let fieldsForSameAsValue = ['State__c','District__c','Taluka__c','Village__c','Pincode__c','Land_mark__c','Khata_Khasara_Survey_Number__c']
        if(ischecked){
            this.landAddress.Same_As__c = selectedValue
            if(selectedValue=='NA'){
                this.disableFieldsAsPerMetadata(fieldsForSameAsValue, true)
            }else if(selectedValue=='New'){
                this.disableFieldsAsPerMetadata(fieldsForSameAsValue, false)
            }else{
                let wrapper = await getCopyToLandAddressDetails({applicantId: this.applicantId, type: this.landAddress.Same_As__c})
                this.stateId = this.getDefaultValue(wrapper.stateId)
                this.landAddress.State__c = this.getDefaultValue(wrapper.state)
                this.districtId = this.getDefaultValue(wrapper.districtId)
                this.landAddress.District__c = this.getDefaultValue(wrapper.district)
                this.tehsilId = this.getDefaultValue(wrapper.tehsilId)
                this.landAddress.Taluka__c = this.getDefaultValue(wrapper.tehsil)
                this.landAddress.Pincode__c = this.getDefaultValue(wrapper.pincode)
                this.landAddress.Land_mark__c = this.getDefaultValue(wrapper.landmark)
                let fields = ['Village','Survey Number']
                let fieldsForSameAsValue = ['State__c','District__c','Taluka__c','Pincode__c','Land_mark__c']
                this.disableFieldsAsPerMetadata(fieldsForSameAsValue, true)
                //this.disableFieldsAsPerMetadata(this.setListofSameAsRelatedFields(), true)
                this.resestValues(fields)
            }
        }else{
            this.landAddress.Same_As__c = ''
            this.disableFieldsAsPerMetadata(fieldsForSameAsValue, false)
        }
        
    }

    setListofSameAsRelatedFields(){
        let fieldsToDisable = []
        fieldsToDisable = this.populateFieldsToDisableList(fieldsToDisable,'State__c',this.stateId)
        fieldsToDisable = this.populateFieldsToDisableList(fieldsToDisable,'District__c',this.districtId)
        fieldsToDisable = this.populateFieldsToDisableList(fieldsToDisable,'Tehsil__c',this.tehsilId)
        fieldsToDisable = this.populateFieldsToDisableList(fieldsToDisable,'Pincode__c',this.landAddress.Pincode__c)
        fieldsToDisable = this.populateFieldsToDisableList(fieldsToDisable,'Land_mark__c',this.landAddress.Land_mark__c)
        return fieldsToDisable;
    }

    populateFieldsToDisableList(list, fieldName, value){
        if(value){
            list.push(fieldName)
        }
        return list
    }
    
    getDefaultValue(value){
        return value?value:undefined
    }

    handleReset(){
        this.landAddress.Same_As__c = ''
        this.landAddress.Land_mark__c = ''
        this.landAddress.Pincode__c = ''
        this.stateId = undefined
        this.landAddress.State__c = ''
        let fields = ['State','District','Tehsil','Village','Survey Number']
        this.resestValues(fields)
    }
}