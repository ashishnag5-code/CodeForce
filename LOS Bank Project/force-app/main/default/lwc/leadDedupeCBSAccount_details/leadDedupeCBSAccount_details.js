import { LightningElement,api } from 'lwc';

export default class LeadDedupeCBSAccount_details extends LightningElement {
    @api 
    objAccountRecord;
    @api
    spinnerImage;
    @api applicantODRecord;
    isLoading;
    posVal;


    connectedCallback(){
        if(this.applicantODRecord!=undefined){
            console.log('inApplicantODRecord-->' +JSON.stringify(this.applicantODRecord));
        this.applicantODRecord.forEach(recordWrapper => {
            if (recordWrapper.AccountNo == this.objAccountRecord.strLoanTitle) {
                this.posVal = recordWrapper.PrincipalBalance;
            }
        });
        }
        
    }
}