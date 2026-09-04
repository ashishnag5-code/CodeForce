import { LightningElement, track, api } from 'lwc';

export default class AssignLeadFromRecord extends LightningElement {
    @api recordId;
    @track ids = {};
    @api showassignbtn = false;
    @api lounchflow = false;
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