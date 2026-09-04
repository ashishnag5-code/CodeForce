import { LightningElement, wire, api } from 'lwc';
import LOAN_RECORD_TYPE_NAME from '@salesforce/schema/Loan_Application__c.RecordType.Name';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/lwcutilities';
export default class AusfVehicleListCommercialUsed extends LightningElement {
    @api recordId;
    loanApplication = {};

    @wire( getRecord, { recordId: '$recordId', fields: [ LOAN_RECORD_TYPE_NAME ] } )
    wiredLoanApplication({ data, error }) {
        if (data) {
            this.loanApplication = data;
        } else {
            this.error = reduceErrors(error)?.join(',');
        }
    }

    get isCommercialVehicle(){
        return getFieldValue( this.loanApplication, LOAN_RECORD_TYPE_NAME ) === 'Commercial Vehicle';
    }

    get isConstructionEquipment(){
        return getFieldValue( this.loanApplication, LOAN_RECORD_TYPE_NAME ) === 'Construction Equipment';
    }

    @api nextHandler() {
        let vehicleRecord = this.applicantLst;
        this.errorOnChild = vehicleRecord.length > 0 ? '' : 'Please create vehicle record';
        const Obj = {};
        //this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild === '' ? true : false;
        if (Obj.next === false) {
            this.showToast(this.errorOnChild, 'error');
        }
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }

    closeModal(event) {
        const obj = event.detail;
        console.log('obj is ' + obj)
        this.isModalOpen = obj.isModalOpen;
    }

    showDetails(event) {
        console.log('in show details')
        const obj = event.detail;
        console.log('obj is ' + obj)
        this.showLoanDetails = obj.showLoanDetails;
        this.showVehicle = false;
        this.isModalOpen = obj.isModalOpen;
        this.dispatchEvent(new CustomEvent('updateloandetail'));
    }

    async showVehicleDetail(event) {
        const obj = event.detail;
        console.log('show>> is ' + JSON.stringify(obj))
        if (obj.ROI__c) {
            this.loanApplicationRecord.ROI__c = obj.ROI__c;
        }
        if (obj.Loan_Amount__c) {
            this.loanApplicationRecord.Loan_Amount__c = obj.Loan_Amount__c;
        }
        if (obj.Tenure__c) {
            this.loanApplicationRecord.Tenure__c = obj.Tenure__c;
        }
        this.showVehicle = true;
        this.getVisibleFields();
        this.dispatchEvent(new CustomEvent('updateloandetail'));
        this.showLoanDetails = false;
        await delay(1000); //the updates to loan application cause the entire section to reload
        this.showSection = false;
    }

    getSelectedCollateral(event) {
        this.selectedCollList = event.detail;
        console.log('selected Coll is 123 ' + JSON.stringify(this.selectedCollList))
    }

    populatePricingProperties = (vehicleRecord, { pricing }) => {
        this.desableField = this.disableFieldsRecievedFromApi(this.desableField, pricing);
        const vehicleExShowroomPrice = pricing?.price ?? pricing?.ex_showroom_price;
        return ({
            ...vehicleRecord,
            Ex_Showroom_Price__c: vehicleExShowroomPrice,
            Ex_Showroom_Price_API__c: vehicleExShowroomPrice,
            Final_Cost__c: pricing?.price,
            Insurance__c: pricing?.insurance,
            RTO_Taxes__c: pricing?.rto,
            On_Road_Price__c: pricing?.on_road_price
        });
    }
    disableFieldsRecievedFromApi(disabledFields, pricing) {
        for (const key in API_RESPONSE_TO_FIELD_MAPPING) {
            if (key in pricing) {
                API_RESPONSE_TO_FIELD_MAPPING[key].forEach(item => { disabledFields[item] = true; });
            }
        }
        return disabledFields;
    }
    async getMaterialSettings(strScreen, strLoanId) {
        const fields = await getMaterialFields({ strScreen, strLoanId }).catch(err => this.showToast('Something went wrong! Please contact System Administrator', 'error'));
        console.log(fields);
        this.configurations = { materialSettings: fields.map(field => field.toLowerCase()) || [] };
    }

    async applyMaterialSettings() {
        await Promise.resolve();
        const fieldTokens = this.template.querySelectorAll('lightning-input, lightning-combobox');
        updateDisabledOnFieldTokens([...fieldTokens], this.configurations.materialSettings, true);
    }

    async setDefaultFieldValue(picklistOptions, fieldApi) {
        if (picklistOptions?.length === 1) {
            const [{ value }] = picklistOptions;
            this.desableField = { ...this.desableField, [fieldApi]: true };
            this.handleValueChange({ target: { name: fieldApi, value } });
        }
    }
    // SFAU-4545 - auto-populate vehicle category
    async setDefaultCategoryValue( picklistOptions, fieldApi ) {
        if( picklistOptions?.length === 1 ) {
            const [{ value }] = picklistOptions;
            this.handleCategoryChange({ target: { name: fieldApi, value } });
        }
    }
    async validateMaterialFields(strScreen, strLoanId, lstFieldsAPI) {
        console.log(' == Make Field ==> ', this.isDirtyField(this._vehicleRecord, { [MAKE_FIELD_API]: this.makeOptionValue }, MAKE_FIELD_API));
        if (this.isDirtyField(this._vehicleRecord, { [MAKE_FIELD_API]: this.makeOptionValue }, MAKE_FIELD_API)) {
            await checkMaterialFields({ strScreen, strLoanId, lstFieldsAPI })
                .catch(err => { console.error(err); this.showToast(err.body?.message ?? '(Material Fields)Something went wrong! Please contact System administrator', 'error'); });
        }
    }

    isDirtyField = (oldRecord, newRecord, fieldApi) => oldRecord?.[fieldApi] != newRecord?.[fieldApi];

    setSpinner(hasLoaded) {
        this.isLoaded = hasLoaded
    }
     handleSave(event){
        this.dispatchEvent(new CustomEvent('save', {
            detail:event.detail
        }));
    }
}