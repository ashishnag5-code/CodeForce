import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRelatedApplicantAddress from '@salesforce/apex/CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress';


export default class CreateFIRecord extends LightningElement {
    @track fiList ;
    @api recordId;
    @api objectApiName;
    @api blnRetriggerFI = false;
    

    handleClick(){
    console.log('this.objectApiName>>>'+this.objectApiName);
    console.log('this.recordId>>>'+this.recordId);
       
        fetchRelatedApplicantAddress({recordId:this.recordId, blnRetriggerFI: this.blnRetriggerFI})
        .then(result => {
            if (result != null) {
                this.fiList = result;
                console.log('this.result1>>>>>++' + JSON.stringify(result));
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Successflly Created',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            console.log('this.error>>>>>' + JSON.stringify(this.error));
            let errormsg = error.body.message;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: errormsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.error = error;
        });
    
    
}
}