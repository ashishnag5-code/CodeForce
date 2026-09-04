import { LightningElement,api } from 'lwc';

export default class AddressInformationDetails extends LightningElement {

    @api addressRecords;
    @api selectedAddress;
    isPermanent = false; //25 JUL
    isOffice = false; //25 JUL
    
    connectedCallback() {
        console.log('selectedAddress' +JSON.stringify(this.selectedAddress));
        //this.showDistance = ((this.selectedAddress[0].Address_Type__c == 'Current') ? true : false);
        this.isPermanent =((this.selectedAddress[0].Address_Type__c == 'Permanent') ? true : false);
        this.isOffice =((this.selectedAddress[0].Address_Type__c == 'Office') ? true : false);
    }
    

    viewAllRecords(event){
        this.dispatchEvent(new CustomEvent('viewall'));
    }
}