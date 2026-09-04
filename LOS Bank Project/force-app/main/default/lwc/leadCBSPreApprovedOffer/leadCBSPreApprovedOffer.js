import { LightningElement,api, track } from 'lwc';
import callPreApprovedOfferInt from '@salesforce/apex/LOSPreApprovedOfferInt.callPreApprovedOfferInt';
import callPreApprovedUpdateOfferInt from '@salesforce/apex/LOSPreApprovedOfferUpdateInt.callPreApprovedUpdateOfferInt';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadCRMPreApprovedOffer extends LightningElement {
    @api
    applicantInput;
    @api
    boolIsNPA = false;
    @track
    lstPreApprovedOffer = [];
    @track
    selectDisabled = false;
    @api
    spinnerImage;
    isLoading;
    showOffer = false;
    @api
    boolDPDFound = false;
    //@api
    //strApplicantId;

    connectedCallback(){
        //this.isLoading = true;
        this.dispatchEvent(new CustomEvent('spinnerevent', {detail: true , bubbles :true, composed : true}));
        callPreApprovedOfferInt({ objApplicant : this.applicantInput })
        .then(result => {
            console.log('%%PreApproved '+JSON.stringify(result));
            this.lstPreApprovedOffer = result;
            if(this.lstPreApprovedOffer.length > 0){
                this.lstPreApprovedOffer.forEach(input=>{
                    if(input.Is_Selected__c){
                        this.selectDisabled = true;
                    }
                })
                this.showOffer = true;
            }
            //Id = undefined for Co-App,Guarantor
            if(this.boolIsNPA || this.lstPreApprovedOffer[0].Id == undefined){
                this.selectDisabled = true;
            }
            //this.isLoading = false;
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
        })
        .catch(error => {
            console.log('result is '+error);
            //this.isLoading = false;
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
        })
    }

    markSelected(event){
        //this.isLoading = true;
        if(this.boolIsNPA || this.boolDPDFound){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'NPA or DPD Detected',
                    message: 'NPA or DPD Detected',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else{
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: true , bubbles :true, composed : true}));
            var recordId = event.currentTarget.dataset.id;
            var name = event.currentTarget.dataset.name;
            this.lstPreApprovedOffer.forEach(inputField => {
                if (!inputField.Is_Selected__c && name == 'Avail' && inputField.Offer_Id__c == recordId) {
                    console.log('%%PreApproved '+JSON.stringify(inputField));
                    callPreApprovedUpdateOfferInt({ objPreApproved : inputField ,strApplicantId : this.applicantInput.Id })
                    .then(result => {
                        /* Change - SFAU-5722 - Mohit M. */
                        if (result.blnSuccess == true && result.response != '') {
                            let updatedOffer = JSON.parse(result.response);
                            console.log('%%PreApproved '+JSON.stringify(updatedOffer));
                            if(updatedOffer.TransactionStatus.ResponseMessage == "Success"){
                                inputField.Is_Selected__c = true;
                                this.selectDisabled = true;
                            }
                            else if (result.blnSuccess == true && result.response != '')
                            {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Offer not Availed',
                                        message: updatedOffer.TransactionStatus.ExtendedErrorDetails.messages[0].message,
                                        variant: 'error',
                                        mode: 'dismissable'
                                    }),
                                );
                            }
                            //this.isLoading = false;
                            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
                            //this.lstPreApprovedOffer = result;
                        }
                        else if (result.blnSuccess == false)
                        {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Offer not Availed',
                                    message: result.strMsg,
                                    variant: 'error',
                                    mode: 'dismissable'
                                }),
                            );

                            //Production hotfix
                            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));

                        }
                        
                    })
                    .catch(error => {
                        console.log('result is '+error);
                        //this.isLoading = false;
                        this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
                    })
                }
                else{
                    inputField.Is_Selected__c = false;
                }
            });
        }
        console.log('%%% '+JSON.stringify(this.lstPreApprovedOffer));
    }
}