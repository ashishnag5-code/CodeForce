import { api, LightningElement, track } from 'lwc';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess'

export default class CpvWaiverDocumentsChild extends LightningElement {

    documentType;
    @track activeSections=[];
    @api loanAppId;
    @api applicantId
    @api
    get type(){
        return this.documentType;
    }
    set type(value){
        this.documentType = value
        if(value){
            this.handleRenderSections(value, true)
        }

    }
    removed;
    @api
    get removedRecord(){
        return this.removed
    }

    set removedRecord(value){
        this.removed = value
        if(value){
            this.handleRenderSections(value,false)
        }
    }

    @track isEditRestricted
    isOptionElectricityBill=false;
    isOptionWaterBill=false;
    isOptionInsurancePremiumReceipt=false;
    isOptionBankStatement=false;
    isOptionHousetaxReceipt=false;
    isOptionMobileBill=false;
    isOptionGasBill=false;
    isOptionPNGBill=false;
    isOptionPassbook=false;

    async connectedCallback(){
        this.isEditRestricted = await restricAccess({compName:'cpvWaiverDocumentsComponent',loanId:this.loanAppId})
    }

    handleRenderSections(type,value){
        if(type === 'Electricity bill'){
            this.isOptionElectricityBill = value;
        }
        else if(type === 'Water Bill'){
            this.isOptionWaterBill = value;
        }
        else if(type === 'Mobile Bill'){
            this.isOptionMobileBill = value;
        }
        else if(type === 'Gas bill'){
            this.isOptionGasBill = value;
        }
        else if(type === 'PNG bill'){
            this.isOptionPNGBill = value;
        }
        else if(type === 'Insurance Premuim Receipt'){
            this.isOptionInsurancePremiumReceipt = value;
        }
        else if(type === 'House Tax Receipt'){
            this.isOptionHousetaxReceipt = value;
        }
        else if(type === 'Bank Statement'){
            this.isOptionBankStatement = value;
        }
        else if(type === 'Passbook'){
            this.isOptionPassbook = value;
        }
        if(value){
            this.activeSections.push(type)
        }
        else{
            this.activeSections.splice(this.activeSections.indexOf(type),1)
        }
    }
}