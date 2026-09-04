import { LightningElement } from 'lwc';

export default class LifeCycleHook extends LightningElement {

    variable1;

    constructor(){
        super();

        let name = 'Mangesh';
        if(name){
            this.variable1 = 'Mangesh Khandekar';

        }

        
    }

    connectedCallback(){
        let button1 = this.template.querySelector('lightning-button');
        console.log('button1 '+button1)
    } 

    renderedCallback(){
        let button2 = this.template.querySelector('lightning-button');
        console.log('button1 '+button2)
    }

    handleClick(){

    }
}