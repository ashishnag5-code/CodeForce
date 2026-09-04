import { api, LightningElement } from 'lwc';

export default class CustomerDataDisplayCarousel extends LightningElement {

    @api customerRecord

    handleSelection(){
        this.dispatchEvent(new CustomEvent('selectcif',{
            detail: this.customerRecord.CustomerID
        }));
    }
}