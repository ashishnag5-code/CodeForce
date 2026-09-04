import { LightningElement, api, track } from 'lwc';

export default class Ausf_ApplicantInnerLWC extends LightningElement {
    @api applicantData={};
    @api visibleFields=[];
    @api stage = '';
    @api loanId = '';
    @api isTractorCommercial;
    @track renderFetchButton = false;
    @track showCibilReport = false;

    @track displayComponent = false;

    connectedCallback(){    
        this.renderFetchButton = (this.stage == 'PSD');
    }

    handleBackFromCibil(evt){
        this.showCibilReport = false;
    }

    handleClick(evt){
        evt.preventDefault();
        this.showCibilReport = true;
    }

    renderedCallback(){    
        if(this.visibleFields.length){
            this.setFieldsVisibility();
        }
    }

    setFieldsVisibility() {
        this.visibleFields.forEach(input => {
            if(this.template.querySelector('[data-id="'+input+'"]') != null){
                this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
            }
        });
        this.displayComponent = true;

    }

}