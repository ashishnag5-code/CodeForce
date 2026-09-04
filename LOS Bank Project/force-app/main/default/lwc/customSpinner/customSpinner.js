import { LightningElement ,api, wire} from 'lwc';
import getRecordtypeName from '@salesforce/apex/GenericWizardController.getRecordtypeName';
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";


export function getSpinnerImage(recordId) {
    return new Promise((resolve, reject) => {
        let spinnerImage;
        getRecordtypeName({ strRecordId: recordId })
        .then(result => {
            console.log(JSON.stringify(result));
            if(result != undefined && result.RecordType != undefined && result.RecordType.Name != undefined){
                if (result.RecordType.Name == 'Four Wheeler' || (result.Product__c != undefined && result.Product__c.includes('Car Taxi'))) {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
                }
                else if (result.RecordType.Name == 'Two Wheeler') {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
                }
                else if (result.RecordType.Name == 'Tractor') {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Tractor.gif';
                }
                else if (result.RecordType.Name == 'Commercial Vehicle') {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/CV.gif';
                }
                else if (result.RecordType.Name == 'Construction Equipment') {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/CE.gif';
                }
                else {
                    spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
                }
            }
            else{
                spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';   
            }
            resolve(spinnerImage);
        })
        .catch(error => {
            reject('');
        });
    })
}


export default class CustomSpinner extends LightningElement {
    @api
    showSpinner;
    @api
    recordId;
    @api
    spinnerImage;// = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
}