import { LightningElement, track, api } from 'lwc';
import getEmiDetails from '@salesforce/apex/LoanDetailsController.getEmiDetails';
import upsertData from '@salesforce/apex/LoanDetailsController.upsertData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteEmiDetails from '@salesforce/apex/LoanDetailsController.deleteEmiDetails';
import { refreshApex } from '@salesforce/apex';
export default class IoiVpiSchedule extends LightningElement {

    @track errors={rows:[]}
    validations=new Map()
    viewSchedule=false
    addSchedule=false
    keyIndex=0;
    @track recordCount=0
    stageNumber=1;
    @api loanApp;

    @track draftValues=[]
    keyId=0
    scheduleMap=new Map()
    @track scheduleList=[]
    emiRecord={}

    deleteRecords=[]

    connectedCallback(){
        getEmiDetails({recordId: this.loanApp.Id}).then((data=>{
            if(data && data.length>0){
                //this.keyIndex=0
                this.stageNumber=1
                data.forEach(input => {
                    //input.isSaved=true
                    //input.keyId=this.keyIndex
                    this.scheduleMap.set(input.Id, input)
                    //this.keyIndex++
                    this.stageNumber++
                });
                this.scheduleList = Array.from(this.scheduleMap.values())  
                //this.addSchedule=false
                this.recordCount = this.scheduleList.length
            }
            /*else{
                //this.scheduleMap.set(this.keyIndex, {keyId:this.keyIndex, Stage_Number__c:this.stageNumber, Loan_Application__c:this.loanApp.Id})
                this.addSchedule=false
                //this.scheduleList = Array.from(this.scheduleMap.values()) 
                this.keyId=this.keyIndex;
                this.keyIndex++
            }*/
        }))
           

    }

    getSelectedRows(event){
        this.deleteRecords=[]
        const selectedRows = event.detail.selectedRows;
        selectedRows.forEach(element=>{
            this.deleteRecords.push(element)
        })
        // Display that fieldName of the selected rows
        
    }

    handleDeleteSelectedRows(){
        var updateDeletedRecords=[]
        this.deleteRecords.forEach(element=>{
            if(element.Id){
                updateDeletedRecords.push(element.Id)
            }else{
                this.scheduleMap.delete(element.Id)
            }
        })

        if(updateDeletedRecords.length>0){
            deleteEmiDetails({recordIds: updateDeletedRecords, recordId: this.loanApp.Id}).then((data)=>{
                this.keyIndex=0
                this.stageNumber=1
                //this.stageNumber=1
                    this.showToastMessage('Success','Record Updated Successfully','success')
                    //getRecordNotifyChange(updatedFields);
                    //refreshApex(this.scheduleList);
                    this.scheduleMap=new Map();
                    this.scheduleList = []
                    if(data && data.length>0){
                        //this.keyIndex=0
                        data.forEach(input => {
                            //input.isSaved=true
                            //input.keyId=this.keyIndex;
                            input.Stage_Number__c=this.stageNumber
                            this.scheduleMap.set(input.Id, input)
                            //this.keyIndex++
                            this.stageNumber++
                        });
                        this.scheduleList = Array.from(this.scheduleMap.values())  
                        this.addSchedule=false
                        //this.stageNumber=this.scheduleList.length
                        this.recordCount = this.scheduleList.length
    
                        refreshApex(this.scheduleList);
                    }
            })
        }
        
    }

    handleAddNewSchedule(){

        //this.addSchedule=true
        var Id = 'row-'+this.keyIndex
        this.scheduleMap.set(Id, {Stage_Number__c:this.stageNumber})
        this.scheduleList = Array.from(this.scheduleMap.values())  
        this.stageNumber++
        this.keyIndex++
        //this.keyIndex++
    }

    handleCellChange(event){

        const updatedFields = event.detail.draftValues[0]
        this.validateData(updatedFields)

    }

    validateData(updatedFields){
        var record =this.scheduleMap.get(updatedFields.Id)
        var id=updatedFields.Id
        if(updatedFields.Stage_Number__c){
            record.Stage_Number__c = updatedFields.Stage_Number__c
        }
        if(updatedFields.Installment_Amount__c){
            record.Installment_Amount__c = updatedFields.Installment_Amount__c
        }
        if(updatedFields.Installment_Number__c){
            record.Installment_Number__c = updatedFields.Installment_Number__c
        }

        if(!record.Stage_Number__c){
            this.errors.rows[id]={title:'This field is required',messages:['Stage Number is a Mandatory Field'],fieldNames:['Stage_Number__c']}
            this.validations.set(id,'false')
        }if(!record.Installment_Amount__c){
            this.errors.rows[id]={title:'This field is required',messages:['Installment Amount is a Mandatory Field'],fieldNames:['Installment_Amount__c']}
            this.validations.set(id,'false')
        }if(!record.Installment_Number__c){
            this.errors.rows[id]={title:'This field is required',messages:['Installment Number is a Mandatory Field'],fieldNames:['Installment_Number__c']}
            this.validations.set(id,'false')
        }
        if(record.Stage_Number__c && record.Installment_Amount__c && record.Installment_Number__c){
            this.validations.set(id,'true')
            this.errors.rows[id]={}
            this.scheduleMap.set(updatedFields.Id,record)
            
        }
    }
    
    listToUpdate=[]

    handleEditSave(event){
        const updatedFields = event.detail.draftValues;
        var valid=true
        updatedFields.forEach(element=>{
            this.validateData(element)
        })
        
        if(Array.from(this.validations.values()).includes('false')){
            valid=false
        }
        if(valid){
            var map=new Map()
            var list=[]
            list=Array.from(this.scheduleMap.values())
            this.listToUpdate=[]
            list.forEach(element=>{
                element.Loan_Application__c=this.loanApp.Id
                this.listToUpdate.push(element)
                map.set(element.Stage_Number__c, element.Installment_Number__c)
            })
            var mapAsc = new Map([...map.entries()].reverse());
            var total=this.loanApp.Tenure__c-1;
            var a=true
            Array.from(mapAsc.values()).forEach(input=>{
                if(input<=total){
                    total=input
                }else{
                    a=false
                }
            })

            if(a){
                upsertData({schedule: this.listToUpdate, recordId: this.loanApp.Id, tenure: this.loanApp.Tenure__c}).then((data)=>{
                    //this.emiSchedule=data
                    this.keyIndex=0
                    this.stageNumber=1
                    this.showToastMessage('Success','Record Updated Successfully','success')
                    this.scheduleMap=new Map();
                    this.scheduleList = []
                    if(data && data.length>0){
                        data.forEach(input => {
                            this.scheduleMap.set(input.Id, input)
                            this.stageNumber++
                        });
                        this.scheduleList = Array.from(this.scheduleMap.values())  
                        this.addSchedule=false
                        this.recordCount = this.scheduleList.length
                        refreshApex(this.scheduleList);
                    }
                    this.draftValues = [];
                }).catch((error)=>{
                    this.showToastMessage('Error',error.body.message,'error')
                })
            }else{
                this.showToastMessage('Error','Please check the Installment Numbers','error')
            }
            
        }else{
            this.showToastMessage('Error','Mandatory Details Missing','error')
        }
        
    }

    showToastMessage(titleValue, messageValue, variantValue){

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);

    }

    navigateToEditAccountPage(event){
        console.log('event '+JSON.parse(JSON.stringify(event.target)))
        this.addSchedule=true
    }
    /*handleSave(event){
        console.log('event.data '+JSON.parse(JSON.stringify(event.detail.data)))
        event.detail.data.isSaved = event.detail.isSaved
        this.scheduleMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.keyId=event.detail.key;
        this.scheduleList = Array.from(this.scheduleMap.values())
        this.recordCount = this.scheduleList.length
        console.log('Schedule list '+JSON.stringify(this.scheduleList))
        this.addSchedule=false
    }*/

    /*handleRowAction(event){
        this.addSchedule=event.detail.isAdd
        event.detail.data.isSaved=event.detail.isSaved
        this.scheduleMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.scheduleList = Array.from(this.scheduleMap.values())
        if(this.addSchedule){
            this.emiRecord =this.scheduleMap.get(event.detail.key)
            this.keyId=event.detail.key;

        }
    }*/

    get columns(){
        return [{
            type:"button-icon",
            fixedWidth: 150,
            typeAttributes: {
                label: 'Edit',
                name: 'edit',
                variant: 'brand',
                iconName:'utility:edit'
            }
        },   
        {
            label: 'Stage',
            fieldName: 'Stage_Number__c',
            editable: true,
            initialWidth:50,
            typeAttributes:{
                required:true
            }
        },
        {
            label: 'Upto Installment',
            fieldName: 'Installment_Number__c',
            editable: true,
            initialWidth:150,
            typeAttributes:{
                required:true
            }
        },
        { 
            label: 'Amount', 
            fieldName: 'Installment_Amount__c', 
            editable: true,
            initialWidth:120,
            type:'text',
            typeAttributes:{
                required:true
            },
            hideDefaultActions: true
        },
        

        ]
    }
}