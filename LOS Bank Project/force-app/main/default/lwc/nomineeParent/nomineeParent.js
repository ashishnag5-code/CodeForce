import { LightningElement, api, track } from 'lwc';
import getNomineeDetails from '@salesforce/apex/NomineeController.getNomineeDetails'
import getRelationOptions from '@salesforce/apex/NomineeController.getRelationOptions'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NomineeParent extends LightningElement {

    addNominee=false;
    hideDetails=false
    keyIndex=0;
    @track recordCount=0
    @api loanApp;

    keyId=0
    nomineeMap=new Map()
    @track nomineeList=[]
    nomineeRecord={}
    relationOptions
    @track isEditRestricted//4733

    async connectedCallback(){
        getNomineeDetails({recordId: this.loanApp.Id}).then((data=>{
            this.nomineeMap = new Map()
            if(data && data.length>0){
                this.keyIndex=0
                data.forEach(input => {
                    input.isSaved=true
                    input.keyId =this.keyIndex
                    this.nomineeMap.set(this.keyIndex, input)
                    this.keyIndex++
                });
                this.nomineeList = Array.from(this.nomineeMap.values())  
                this.addNominee=false
                this.recordCount = this.nomineeList.length
            }
            /*else{
                this.nomineeMap.set(this.keyIndex, {})
                this.nomineeList = Array.from(this.nomineeMap.values()) 
                this.keyId=this.keyIndex;
                this.keyIndex++
            }*/
        }))
        console.log('initial details '+JSON.stringify(this.nomineeList))
        this.relationOptions=[];
        var options=[];
        getRelationOptions().then((data)=>{
            if(data && data[0] && data[0].Picklist_Values__c.includes(',')){
                options=data[0].Picklist_Values__c.split(',');
                options.forEach(element => {
                    if(element.toUpperCase()!='SELF'){
                        this.relationOptions.push({label: element, value: element})
                    }
                })
            }
        })
        
        this.isEditRestricted = await restricAccess({compName: 'loanDetails' ,loanId: this.loanApp.Id})
            /*else{
                this.nomineeMap.set(this.keyIndex, {})
                this.nomineeList = Array.from(this.nomineeMap.values()) 
                this.keyId=this.keyIndex;
                this.keyIndex++
            }*/
        

    }

    handleAddNewNominee(){
        if(this.isEditRestricted){//4733
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to add Nominee Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        this.keyIndex++
        this.keyId=this.keyIndex;
        this.addNominee=true
        this.nomineeMap.set(this.keyIndex, {})
        this.nomineeList = Array.from(this.nomineeMap.values())
        console.log('Schedule list '+JSON.stringify(this.nomineeList))
        this.nomineeRecord={}
        
    }

    @api
    getTotalPercent(){
        var isUnsaved; 
        var netPercent=0;
        this.nomineeList.forEach(input => {
            if(input.isSaved==false){
                isUnsaved=true
            }
            netPercent = input.Percentage_Share_for_Nomination__c+netPercent

        });
        this.dispatchEvent(new CustomEvent('nominee',{
            detail: {
                template:'Nominee',
                isUnsaved: isUnsaved,
                value: netPercent
            }
        }));
        /*var netPercent=0;
        this.nomineeList.forEach(input => {
            netPercent = input.Percentage_Share_for_Nomination__c+netPercent
        });
        if(this.nomineeList.length>0 && netPercent!=100){
            return false
        }else{
            return true
        }*/
        
            
    }

    hideNomineeDetails(){
        this.hideDetails=true
    }

    handleSave(event){
        console.log('event.data '+JSON.parse(JSON.stringify(event.detail.data)))
        event.detail.data.isSaved = event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.nomineeMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        //this.keyId=event.detail.key;
        this.nomineeList = Array.from(this.nomineeMap.values())
        this.recordCount = this.nomineeList.length
        console.log('Schedule list '+JSON.stringify(this.nomineeList))
        this.addNominee=false
    }

    handleRowAction(event){
        this.addNominee=event.detail.isAdd
        event.detail.data.isSaved=event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.nomineeMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.nomineeList = Array.from(this.nomineeMap.values())
        if(this.addNominee){
            this.nomineeRecord =this.nomineeMap.get(event.detail.key)
            //this.keyId=event.detail.key;

        }
    }

    handleDeleteAction(event){
        this.nomineeMap.delete(event.detail.key)
        this.nomineeList = Array.from(this.nomineeMap.values())
        this.recordCount = this.nomineeList.length
        this.addNominee=false
    }
}