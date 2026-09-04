import { LightningElement,api } from 'lwc';

export default class AusfUpdateLoanApplication extends LightningElement {
    @api isModalOpen =false;
    @api schemeRecord;
    closeModal(){
        const Obj = {};
        Obj.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('closemodal', {
            detail: Obj
        }));
    }

    updateDetails(){
        const Obj = {};
        Obj.showLoanDetails = true;
        Obj.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('showloandetails', {
            detail: Obj
        }));
    }
}