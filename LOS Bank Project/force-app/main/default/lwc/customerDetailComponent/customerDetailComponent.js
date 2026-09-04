import { LightningElement, api, track} from 'lwc';
import emailVerificationHandler from '@salesforce/apex/EmailVerificationHandler.doRestCallout';
import restrictedDomain from '@salesforce/apex/CustDetCompController_AUFSB.getRestrictedDomains';
import aadhaar from '@salesforce/resourceUrl/aadhaar';
import ckyc from '@salesforce/resourceUrl/ckyc';
export default class RecordEditFormEditExampleLWC extends LightningElement {
    @api applicantIdInput;
    @api recordId ='a006s0000015TaEAAU';
    strEmail = ''
    isVerify = false;
    showerror = false;
    errorStr = '';
    handleSubmit(event) {
        console.log('onsubmit event recordEditForm'+ event.detail.fields);
    }
    onEmailChange(event){
        this.strEmail = event.target.value;
        
    }
    emailVerificationHandler(){

        emailVerificationHandler({ strEmail:  this.strEmail, recordId: this.recordId})
            .then(result => {
                    this.restrictedDomain();
                
                console.log('result'+JSON.stringify(result));
            })
            .catch(error => {   
                console.log('result is error')
                this.errorStr = 'please input valid email address';
            })    
    }
    restrictedDomain(event){
        restrictedDomain({domainAddress:this.strEmail})
            .then(result => {
                console.log('result is '+result);
                if(result){
                    this.isVerify = true;
                }
                else{
                    this.errorStr = 'please input valid email address';
                    this.showerror = true;
                }
                
                
            })
            .catch(error => {   
                console.log('result is error')
                
            })  
    }
    
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
    }
     @api
    nextHandler(){
        console.log('return------');
        //const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit();
        let returnObj = {
            'next' : true,
        }

    this.dispatchEvent(new CustomEvent('next', {
        detail: returnObj
    }));

      
    }
}