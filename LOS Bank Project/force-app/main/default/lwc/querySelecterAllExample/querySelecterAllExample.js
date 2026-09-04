import { LightningElement } from 'lwc';

export default class QuerySelecterAllExample extends LightningElement {
    firstName ='';
    lastName ='';

    clickMe(event){
        var input1 = this.template.querySelectorAll('lightning-input');
        input1.forEach(function(element){
            if(element.name==='fname'){
                this.firstName =element.value;
            }else if(element.name==='lname'){
                this.lastName =element.value;
            }
        })
    }
}