import { LightningElement,track } from 'lwc';
import getApplicantDetails from'@salesforce/apex/BiometricController.getApplicantDetails';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class BiometricModelPopup extends LightningElement {
     isShowModal = false;
     recordId = 'a0D6s000002iS72EAE';
     fullName='';
     isMobile = false;
     radiovalue = '';
    showModalBox() {
        this.isShowModal = true;
    }
    connectedCallback() {
        if(FORM_FACTOR=='Small'){
            this.isMobile = true;
        }
    }

    get options() {
        return [
            { label: 'Physical Upload', value: 'Physical Upload' },
            { label: 'Smartphone KYC', value: 'Smartphone KYC' },
        ];
    }
    hideModalBox() {  
        this.isShowModal = false;
    }
    getApplicantDetails(event){
		getApplicantDetails({ recordId: this.recordId })
		.then(result => {
            console.log('RESULT###'+result);
            console.log('RESULT###JSON'+JSON.parse(result));
            let finalValue = JSON.parse(result);
            let details = finalValue.result[0].details.name.value;
            this.fullName=details;
            console.log('details'+details);
		})
		.catch(error => {
            console.log('INSIDE ERROR ');
		})
	}
    openBridgeApp(){
        console.log('Radio Butoon Value'+this.radiovalue);

    }
    handleChange(event) {
        this.radiovalue = event.detail.value;
    }
}