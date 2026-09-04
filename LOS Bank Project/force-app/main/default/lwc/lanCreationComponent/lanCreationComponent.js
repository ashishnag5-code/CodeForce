import { LightningElement, api } from 'lwc';
import getLoanApplicationDetails from '@salesforce/apex/LANCreationController.getLoanApplicationDetails'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LanCreationComponent extends LightningElement {

    @api loanId;
    userType;
    connectedCallback() {
        this.getLoanDetails();
    }

    getLoanDetails() {
        getLoanApplicationDetails({ loanAppId: this.loanId }).then((data => {
            this.loanAppRecord = data      
            if(this.loanAppRecord.Owner.Type=='User'){
                this.userType='User'
            }else{
                this.userType=''
            }
        })).catch((error => {
            this.showToast('Error', error.message.body, 'error')
        }))
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
}