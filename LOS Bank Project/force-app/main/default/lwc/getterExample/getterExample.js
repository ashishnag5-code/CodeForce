import { LightningElement } from 'lwc';

export default class GetterExample extends LightningElement {
    firstName ='';
    lastName ='';

    handleChange(event){
        if(event.target.name ==='lname'){
            this.lastName = event.target.value;
        }else if(event.target.name ==='fname'){
            this.firstName = event.target.value;
        }
    }


    get upperCasedFullName(){
        return `${this.firstName} ${this.lastName}`.toUpperCase();
    }
}