import { LightningElement,api } from 'lwc';

export default class FarmerChildComponent extends LightningElement {
    @api key;
    @api financialId;
    @api applicantId;

    agricultureTypeOptions;
    renderOwnlandTemplate = false;

    connectedCallback(){
        let agricultureOptions=[];
         //Assigning Year Values
         agricultureOptions.push({label: 'Own Land' ,value: 'Own Land'});
         agricultureOptions.push({label: 'Rented Cultivated Land / Consider Documeted Proff / Valid lease Agreement  / Sarpanch Letter / Cultivator name Updated Land Revnue Record' ,value: 'Rented Cultivated Land'});
         agricultureOptions.push({label: 'Commercial/Agri Haulage Income Details' ,value: 'Commercial/Agri Haulage Income Details'});
         agricultureOptions.push({label: 'Dairy Business' ,value: 'Dairy Business'});
        this.agricultureTypeOptions = agricultureOptions;
    }


    handleChange(event){
        let fieldName = event.target.name;
        let fieldValue = event.target.value;

        if(fieldName =='agricultureType'){
            if(fieldValue == 'Own Land'){
                this.renderOwnlandTemplate = true;
            }

        }

    } 
}