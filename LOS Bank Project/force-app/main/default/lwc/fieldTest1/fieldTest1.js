import { LightningElement } from 'lwc';

export default class FieldTest1 extends LightningElement {
    handlePrint(){
        window.print();
    }
}