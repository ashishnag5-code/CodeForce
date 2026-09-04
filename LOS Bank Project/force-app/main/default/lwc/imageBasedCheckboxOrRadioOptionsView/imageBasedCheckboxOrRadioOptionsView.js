import { LightningElement, api } from 'lwc';
import PDQ_Images from '@salesforce/resourceUrl/PDQ_Images';

export default class ImageBasedCheckboxOrRadioOptionsView extends LightningElement {
    @api item;
    @api finalResult={};
    optionList = [];
    selectedCheckbox = [];
    typeOfInput = '';
    connectedCallback(){
        var options = [];
        var isCheckBox = this.item.isImageCheckBoxes;
        var isRadio = this.item.isImageRadio;
        var staticResourceURL = PDQ_Images;
        if(isCheckBox){
            staticResourceURL += '/checkbox/';
            this.typeOfInput = 'Checkbox';
        }
        if(isRadio){
            staticResourceURL += '/radio/';
            this.typeOfInput = 'Radio';
        }
        JSON.parse(this.item.Table_Definition_LOVs__c).forEach(element => {
            var temp  = element;
            temp.imageName = staticResourceURL + element.imageName;
            if(this.item.value != undefined && this.item.value.includes(temp.value)){
                //temp.selected = true;
                //this.selectedCheckbox.push(temp.value);
                options.push(temp); 
            }
        });
        this.optionList = options;
    }
}