import { LightningElement, api } from 'lwc';
import copyApplicantfromCBS from '@salesforce/apex/LeadDedupeController.copyApplicantfromCBS';
import FORM_FACTOR from '@salesforce/client/formFactor';
import GenericModel from 'c/genericModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LeadDedupeCRM_details extends LightningElement {
    @api applicantRecord;
    @api applicantODRecord;
    @api applicantCreditCard = {};
    @api
    applicantInput = {};
    @api
    countFullInd;
    @api
    countFullNonInd;
    @api
    boolIsNPA;
    @api
    spinnerImage;
    @api
    boolDPDFound;
    error;
    //isLoading;
    errorOnChild='';
    isLoading = false;
    isMobile = false;
    boolIsAddressChange = false;
    isShowModal = false;
    boolNameNotMatch = false;

    get booleanODCC(){
        let recordFound = this.applicantRecord.lstAccountWrapper.find((item)=>item.boolIsODCCAccount===true)
        return recordFound;
    }

    get booleanLoan(){
        let recordFound = this.applicantRecord.lstAccountWrapper.find((item)=>item.boolIsLoanAccount===true)
        return recordFound;
    }

    get booleanCASA(){
        let recordFound = this.applicantRecord.lstAccountWrapper.find((item)=>item.boolIsCASAAccount===true)
        return recordFound;
    }

    get booleanFDRDA(){
        let recordFound = this.applicantRecord.lstAccountWrapper.find((item)=>item.boolIsFDRDAccount===true)
        return recordFound;
    }

    get booleanCredit(){
        //let recordFound = this.applicantRecord.lstAccountWrapper.find((item)=>item.boolIsCCAccount===true)
        return (this.applicantCreditCard.CreditCardResponse != undefined &&
            this.applicantCreditCard.CreditCardResponse.length > 0 ? true : false);
    }

    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

    connectedCallback() {
        this.setFormFactor();
        console.log('applicantRecord '+JSON.stringify(this.applicantRecord));
        console.log('applicantCreditCard '+JSON.stringify(this.applicantCreditCard));
        console.log('Form factor - Mobile : ', this.isMobile);
    }

    viewAllRecords(event){
        this.dispatchEvent(new CustomEvent('viewall'));
    }

    handleChange(event){
        console.log('%% '+event.target.checked);
        this.boolIsAddressChange = event.target.checked;
        /*if(this.boolIsAddressChange){

        }*/
    }
    /*
    nameNotMatch(event){
        this.isShowModal = true;
        var selectedRecord = event.currentTarget.dataset.id;
    }
    */

    async nameNotMatch() {
        const result = await GenericModel.open({
            size: 'large',
            description: 'Name not matching. Please create SR',
            content: 'Name not matching. Please create SR',
        });
        this.boolNameNotMatch = true;
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }

    handleOkay() {
        this.close('okay');
    }

    copySelected(event){
        var selectedRecord = event.currentTarget.dataset.id;
        //this.isLoading = true;
        this.dispatchEvent(new CustomEvent('spinnerevent', {detail: true , bubbles :true, composed : true}));
        if(this.boolIsNPA){
            //this.isLoading = false;
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'NPA Detected. Application cannot Proceed',
                    message: 'NPA Detected. Application cannot Proceed',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else if(this.boolNameNotMatch){
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Name not Match. Application cannot Proceed',
                    message: 'Name not Match. Application cannot Proceed',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else if(this.applicantRecord.strCustomerType != this.applicantRecord.strInputCustomerType 
            && this.applicantRecord.strCustomerType == 'Individual'){
            var errorMsg;
            if(this.countFullNonInd > 0){
                errorMsg = 'Please select Existing Non Individual';
            }
            else{
                errorMsg = 'Please select Existing Non Individual or skip using next button';
            }
            //this.isLoading = false;
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: errorMsg,
                    message: errorMsg,
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else if(this.applicantRecord.strCustomerType != this.applicantRecord.strInputCustomerType 
            && this.applicantRecord.strCustomerType == 'Non Individual'){
            var errorMsg;
            if(this.countFullInd > 0){
                errorMsg = 'Please select Existing Individual';
            }
            else{
                errorMsg = 'Please select Existing Non Individual or skip using next button';                
            }
            //this.isLoading = false;
            this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: errorMsg,
                    message: errorMsg,
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else{
            copyApplicantfromCBS({ objCustomerDetailWrapper : this.applicantRecord , objCustomerODResponseWrapper : this.applicantODRecord, objCreditCardWrapper : this.applicantCreditCard ,objApplicant : this.applicantInput,boolAddressChange :this.boolIsAddressChange})
            .then(result => {
                console.log('result is '+JSON.stringify(result));
                //this.isLoading = false;
                this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));

                this.applicantInput = result;
                //this.dispatchEvent(new CustomEvent('copyapplicant',{detail:this.applicantInput}));
                this.dispatchEvent(new CustomEvent('copyrecord',{detail:{value:this.applicantInput,tab:'CBS'}, bubbles:true,composed:true}));
                /*const Obj = {};
                Obj.applicantRecord = result;
                Obj.errorOnChild = this.errorOnChild;
                Obj.next = this.errorOnChild == '' ? true : false;
                console.log('Obj', Obj);
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj, bubbles : true, composed : true
                }));*/

                //this.error = undefined;
                //this.isLoading = false;
            })
            .catch(error => {
                console.log('result is '+error)
                //this.error = error;
                //this.isLoading = false;
                //this.accounts = undefined;
            })
        }
    }

}