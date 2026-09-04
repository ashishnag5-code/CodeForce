import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doOpsAssignment from '@salesforce/apex/OpsAssignementUtility.doOpsAssignment'


export default class Ausf_PartiallyDisbButtonsComponent extends LightningElement {
    @api recordId;
    isLoading;

    handleSubmitToMaker(){
        console.log('%% '+this.recordId);
        const fields = { Id: this.recordId };
        doOpsAssignment({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement' , strStage : 'Ops Maker'}).then(data => {
            this.isLoading = false
            //this.checkButtonVisibility('Ops Author');
            this.showMessage('Successfully Submitted to Maker', 'success')
        }).catch((error) => {
            this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
        })
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
}