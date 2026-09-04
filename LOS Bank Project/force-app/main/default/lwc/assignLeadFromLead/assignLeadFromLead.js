import { LightningElement, api, track } from 'lwc';

export default class AssignLeadFromLead extends LightningElement {

    @api recordId;
    @track ids = {};
    @track showassignbtn = false;
    @track lounchflow = false;
    @api directlaunch = false;
    connectedCallback (){
        if(this.directlaunch == true) {
            this.ids = [{
                name: 'RecordIds',
                type: 'String',
                value: this.recordId
            }],
            this.lounchflow = true;
        }
        else {
            this.showassignbtn = true;
            this.lounchflow = false;
        }
    }

    handleStatusChange (event){
        if (event.detail.status === 'FINISHED') {
            
        }
    }

    handleLaunchFlow(){
        this.ids = [{
            name: 'RecordIds',
            type: 'String',
            value: this.recordId
        }],
        this.lounchflow = true;
    }
}