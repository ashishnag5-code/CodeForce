import { LightningElement, api, wire, track } from 'lwc';
import getUserValidity from '@salesforce/apex/AUSF_MarkSTPController.checkIfValidLoggedInUser';
import markSTPOk_NotOk from '@salesforce/apex/AUSF_MarkSTPController.markSTPOk_NotOk';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Ausf_MarkSTP_NonSTP extends LightningElement {
    @api recordId
    @track isValidUser = false;
    @track renderComponent = false;
    @track renderSTPModal = false;
    @track renderSTPComponent = false;
    @track remarks = '';

    connectedCallback(){
        this.getIfValidUserLoggedIn();
        console.log('after refresh');
    }

    getIfValidUserLoggedIn(){
        getUserValidity({
            applicationId : this.recordId
        })
        .then(res=>{
        
            console.log('mark val '+res);
            this.renderComponent = res;

        })
        .catch(err=>{
            console.log('err '+err);
            this.renderComponent = false;
        })

    }

    handleSTPClick(){
        this.renderSTPComponent = true;
    }

    cancelSTPModal(){
        this.renderSTPComponent = false;
    }

    markOk_NotOkSTP(evt){
        if(!this.isRemarkFilledCheck())
        {
            markSTPOk_NotOk({
                applicationId : this.recordId,
                response :  evt.currentTarget.dataset.id,
                remarks : this.remarks
            })
            .then(res=>{
                console.log('res '+res)
                if(res=='Success'){
                    this.showMessage('Success in marking the Record','success');
    
                }
                else{
                    this.showMessage(res,'error');
                }
                this.cancelSTPModal();
            })
            .catch(err=>{
                this.showMessage(err.body.message,'error');
                console.log('err '+err);
            })

        }
        
    }

    handleRemarkChange(evt){
        this.remarks = evt.detail.value;
    }

    isRemarkFilledCheck(){
        // let isError = false;
        // let checkTemplate = this.template.querySelector('lightning-textarea[data-id="remarks"]');
        // if(!checkTemplate.value){
        //     checkTemplate.setCustomValidity("Please provide a valid Remark before marking the Case Ok/NotOk");
        //     isError = true;   

        // }
        // else{
        //     checkTemplate.setCustomValidity("");
        // }
        // checkTemplate.reportValidity();
        return false;
    }


    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }

}