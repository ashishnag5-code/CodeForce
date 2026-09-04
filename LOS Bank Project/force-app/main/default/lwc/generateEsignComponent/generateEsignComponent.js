import { LightningElement, api, track } from 'lwc';
import FORMFACTOR from '@salesforce/client/formFactor'
import My_Resource from '@salesforce/resourceUrl/ausfIcons';

export default class GenerateEsignComponent extends LightningElement {

    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';

    @api recordId;
    @api disableButton
    @api esignType
    //@api formFactor
    @track esignOptions=[]
    @track displayButton=false

    connectedCallback(){
        if(FORMFACTOR == 'Large' && this.esignType!='SI'){
            this.displayButton=true
        }
    }

    @api
    handleGenerateEsign(){
        if(this.esignType=='SI'){
            this.template.querySelector('c-sign-desk-esign-component').handleSIJourney()
        }else if(this.esignType == 'Addendum Document'){
            this.template.querySelector('c-sign-desk-esign-component').handleAddendumDocumentJourney()
        }else{
            this.template.querySelector('c-sign-desk-esign-component').checkIfAllDocumentsArePresent()
        }
        this.dispatchEvent(new CustomEvent('generateesignclick'));
    }

    handleReturnToSummary(){
        this.dispatchEvent(new CustomEvent('returntosummary'));
    }

}