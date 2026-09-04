import { LightningElement,api,track,wire } from 'lwc';

export default class TestLookUp extends LightningElement {
    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @track selectedName;
    @track records = [{Id: '00G6s000001Uo6YEAS', Name: 'KYC Queue All Product'},{Id: '00G6s000001Uo3PEAS', Name: 'MH RPC - 4WH - Maker'},{Id: '00G6s000001Uo3KEAS', Name: 'MH RPC - TW - Maker'}];
    @track isValueSelected;
    @track blurTimeout;
    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    //@wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    // wiredRecords({ error, data }) {
    //     if (data) {
    //         this.error = undefined;
    //         this.records = data;
    //     } else if (error) {
    //         this.error = error;
    //         this.records = undefined;
    //     }
    // }

    connectedCallback(){
        this.isValueSelected = true;
        this.selectedName = 'KYC Queue All Product';

        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }
}