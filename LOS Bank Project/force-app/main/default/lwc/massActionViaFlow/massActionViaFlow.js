import { LightningElement, api } from 'lwc';

export default class MassActionViaFlow extends LightningElement {
    @api ids;
    @api objectApiName;
    connectedCallback() {
        if (this.ids) {
            this.ids = this.ids.split(',').filter(function (e) {
                return e != null && e != '';
            });
        }
    }
}