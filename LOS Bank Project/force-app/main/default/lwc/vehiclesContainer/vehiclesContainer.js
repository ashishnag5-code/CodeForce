import { LightningElement,api } from 'lwc';
import getVehicle from '@salesforce/apex/VehiclesController.getVehicleData';

export default class VehiclesContainer extends LightningElement {
    @api recordId;

    connectedCallback(){
        
    }

    getVehicleData(){
        getVehicle({
            recId: this.recordId
        })
        .then(data => {
           /* this.addressLst = data.applicantAddressList;
            this.showAddressInsertion = data.boolIsAddressInsertionAllowed;
            this.addressTypes = data.strAddressTypes;
            this.recordCount = data.recCount;
            this.selectedProduct =data.applicantAddressList[0].Product__c;

            console.log('addressData-->' + JSON.stringify(data));
            console.log('bool-->' +  this.selectedProduct);
            let options = [];
            let existingAddress = data.strAddressTypes;
           
            let allAddress = ['Permanent','Current', 'Office','Touch Point'];
            for (var key in allAddress) {
                console.log('dataVal[key]' + allAddress[key]);
                if (!existingAddress.includes(allAddress[key])) {
                    options.push({
                        label: allAddress[key],
                        value: allAddress[key]
                    });
                }
            }
            this.addressList = options;*/
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
          
            //this.accounts = undefined;
        })
    }
}