/*import { LightningElement ,api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordtypeName } from '@salesforce/apex/GenericWizardController/getRecordtypeName';
import AUSF_SPINNER_LOGO_URL from '@salesforce/label/c.AUSF_SPINNER_LOGO_URL';
import IMAGES from "@salesforce/resourceUrl/SpinnerLogo";
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";*/

//export function getSpinnerImage(recordId) {
import getRecordtypeName from '@salesforce/apex/GenericWizardController.getRecordtypeName';
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";
const getSpinnerImage = (recordId) => {

    var spinnerImage;
    getRecordtypeName({ strRecordId: recordId })
        .then(result => {
            console.log(JSON.stringify(result));
            if (result == 'Four Wheeler') {
                spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
            }
            else if (result == 'Two Wheeler') {
                spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
            }
            else {
                spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
            }
            return spinnerImage;
        })
        .catch(error => {
            return spinnerImage;
        });

}

//export default { getSpinnerImage };

export function getSpinnerImageExport(recordId) {
    return getSpinnerImage(recordId)
}
/*
export default class CustomSpinner extends LightningElement {
    @api
    showSpinner;

    //@api
    //recordId;
    //spinnerImage = IMAGES;
    //@api
    //spinnerImage;// = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';


    /*get logoUrl(){
        return AUSF_SPINNER_LOGO_URL;
    }*/
/*
@wire(getRecord, { recordId: '$recordId', fields: ['Loan_Application__c.RecordType.Name'] })
getCaseRecord({ data, error }) {
    if (data) {
        console.log('%% in spinner');
        let recordTypeDetails = data.fields['RecordType']; //this line has record type Id and Name.
        if(recordTypeDetails == 'Four Wheeler'){
            this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
        }
        else if(recordTypeDetails == 'Two Wheeler'){
            this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
        }
        else{
            this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
        }
    }
}
*
}*/