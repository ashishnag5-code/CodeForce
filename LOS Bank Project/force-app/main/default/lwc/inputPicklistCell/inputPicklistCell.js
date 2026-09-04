import { LightningElement, track,wire, api } from 'lwc';
import getPickList from '@salesforce/apex/RtrScreenController.getPicklistOptions';


export default class InputPickListCell extends LightningElement {
    @api options=[];
    value;
    @api record;
    @api field;
    @api fieldType;
    @api objectName;

    value;
    label;
    connectedCallback() {
        this.value = this.record[this.field];
        this.label = this.field;
        if(this.objectName!==undefined && this.isPickList)
        {
            this.getPicklist(this.objectName,this.field);
        }
    }
    getPicklist(obj,field)
    {
        getPickList({ objectName : obj, fieldName :field})
        .then(result => {
           if(result)
           {
                for(let i=0; i<result.length; i++) {
                    console.log('id=' + result[i]);
                    this.options = [...this.options ,{value: result[i] , label: result[i]}];                                   
                }     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }
    handleChange(event) {
        this.value = event.target.value; 
    }
    get isPickList() {
        if(this.fieldType)
        {
            return this.fieldType.toLowerCase()=='picklist';
        }
        return false;
    }
    
    @api
    inputValue() {
        return { value : this.value, field: this.field };
    }
}