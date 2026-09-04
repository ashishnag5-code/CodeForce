import { LightningElement,api } from 'lwc';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';

const MATERIAL_SCREEN_MANUAL_COLLATERAL = 'Existing Collateral - Manual';

export default class AusfAddManualCollateral extends LightningElement {
    @api recordId;
    configurations = {};

    async connectedCallback(){
        const fields = await getMaterialFields({ strScreen: MATERIAL_SCREEN_MANUAL_COLLATERAL, strLoanId: this.recordId }).catch(err => this.showToast('Something went wrong! Please contact System Administrator', 'error'));
        console.log(fields);
        this.configurations = { materialSettings: fields.map( field => field.toLowerCase()) || [] };
    }
}