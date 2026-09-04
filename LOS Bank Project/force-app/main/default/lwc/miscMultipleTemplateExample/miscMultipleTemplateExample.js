import { LightningElement } from 'lwc';
import templateOne from './templateOne.html';
import templateTwo from './templateTwo.html';

export default class MiscMultipleTemplateExample extends LightningElement {
    templateOne = true;

    constructor(){
        super();
        console.log('constructor is called')
    }

    connectedCallback() {
        console.log('connectedCallback is called')
    }

    render(){
        console.log('render is called')
        return this.templateOne ?  templateOne:templateTwo;
    }

    renderedCallback(){
        console.log('renderCallback is called')
    }

    switchTemplate(){
        this.templateOne = this.templateOne === true ? false:true;
    }
}