import { LightningElement, api } from 'lwc';
export default class TodoItem extends LightningElement {

    get itemName() {
        return Math.random() * 100;
    }
    /*
    set itemName(value) {
       this.uppercaseItemName = value.toUpperCase();
    }
    */

}