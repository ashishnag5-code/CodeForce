import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import { CloseActionScreenEvent } from 'lightning/actions';
import updateLeadToLoan from '@salesforce/apex/LosQuickLoanController.updateLeadToLoan';

export default class ConvertToLoanLwc extends LightningElement {
    @api recordId;
    connectedCallback() {
        //code
        this.handleConfirmClick();
    }
   async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: "Please confirm if you want to convert the Lead to the Loan?",
            variant: "default", // headerless
            label: "Convert To Loan"
        });

        //Confirm has been closed

        //result is true if OK was clicked
        if (result) {
            console.log('Ok')
           this.updateLeadToLoan();
           //this.closeQuickAction();
            
        } else {
            console.log('Cancel')
            //and false if cancel was clicked
           // this.closeQuickAction();
            eval("$A.get('e.force:refreshView').fire();");
        }
    }

    

     updateLeadToLoan() {
        updateLeadToLoan({
            loanAppId: this.recordId
        })
            .then(result => {
                console.log('result: ', result);
                this.showToastMessage("Success", "Lead has been converted to Loan.", "success", "");
               // this.closeQuickAction();
                eval("$A.get('e.force:refreshView').fire();");
                //this.updateRecordView();
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            })

    }


   

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

     showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }
}