import { LightningElement, api } from 'lwc';
import validatePaymentFavouring from '@salesforce/apex/LoanDisbursementOpsController.validatePaymentFavouring' 
export default class ValidatePaymentDetailsAtOps extends LightningElement {

    @api paymentFavouring;
    @api paymentFavouringByAuthor={}
    bankName='';
    accountNumber='';
    ifscCode='';


    handleChange(event){
        this.paymentFavouringByAuthor[event.target.name] = event.target.value
    }

    async handleSave(){
        if(this.paymentFavouring.Bank_Name_PMT__c == this.paymentFavouringByAuthor.bankName && 
            this.paymentFavouring.Account_Number__c == this.paymentFavouringByAuthor.accountNumber && 
            this.paymentFavouring.IFSC_Code__c == this.paymentFavouringByAuthor.ifscCode){
            const resp = await validatePaymentFavouring({recordId: this.paymentFavouring.Id})
            
                this.dispatchEvent(new CustomEvent('enablereleasepayment',{
                    detail: {
                        id: this.paymentFavouring.Id,
                        enableButton: true
                    }
                }));
            
        }
        else {
                this.dispatchEvent(new CustomEvent('enablereleasepayment',{
                    detail: {
                        id: this.paymentFavouring.Id,
                        enableButton: false
                    }
                }));
            }
    }

    handleContext(event){
        event.preventDefault(); 
    }

    handlePaste(event){
        event.preventDefault(); 
    }

}