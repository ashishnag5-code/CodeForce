import { LightningElement, api, track } from 'lwc';
import callSignDeskAPi from '@salesforce/apex/SignDeskEsignApiController.callSignDeskAPi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import requiredDocumentsUploadCheck from '@salesforce/apex/SignDeskEsignApiController.requiredDocumentsUploadCheck'
import fieldInvestigationStatusCheck from '@salesforce/apex/SignDeskEsignApiController.fieldInvestigationStatusCheck'
import {NavigationMixin} from 'lightning/navigation';
import { getSpinnerImage } from 'c/customSpinner';

export default class SignDeskEsignComponent extends NavigationMixin(LightningElement) {

    @api loanAppId
    @api formFactor;
    @api esignType
    esignUrl=''
    cvIds=[];
    @track navigateToUrl=false
    @track displayJourneySelection=false
    journeyOptions = [
        { label: 'RO', value: 'RO' },
        { label: 'Customer', value: 'Customer' },
    ]
    selectedJourney=''
    @track signerVsLink = [];
    @track isLoading=false
    @track spinnerImage;

    async connectedCallback(){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }

    @api
    checkIfAllDocumentsArePresent(){
        this.isLoading = true
        requiredDocumentsUploadCheck({recordId: this.loanAppId}).then((data=>{
            this.isLoading = false
            if(data[0].includes('Missing Documents:')){
                this.showToast('Error',data[0],'error', 'sticky');
                this.dispatchEvent(new CustomEvent('returntosummary'));
            }else if(data[0] == 'NA'){
                this.showToast('Error','No Documents are Applicable For Esign','error', 'sticky');
                this.dispatchEvent(new CustomEvent('returntosummary'));
            }else{
                fieldInvestigationStatusCheck({recordId: this.loanAppId}).then((result)=>{
                    if(result){
                        this.showToast('Error','E-Signing is Possible only when FI is Completed','error', 'sticky');
                        this.dispatchEvent(new CustomEvent('returntosummary'));
                    }
                    else{
                        this.cvIds = data;
                        this.displayJourneySelection = true
                    }
                })
                .catch((error=>{
                    this.isLoading = false
                    this.showToast('Error',error.message.body,'error', 'sticky');
                }))
               
            }
        })).catch((error=>{
            this.isLoading = false
            this.showToast('Error',error.message.body,'error', 'sticky');
        }))
    }

    @api
    handleSIJourney(){
        this.displayJourneySelection = true
    }

    @api
    handleAddendumDocumentJourney(){
        this.displayJourneySelection = true
    }
    
    handleChange(event){
        this.selectedJourney = event.target.value
        /*if(this.selectedJourney == 'RO'){
            this.template.querySelectorAll('[data-id="warningMessageToRO"]').forEach(input=>{
                if(input.classList.contains('slds-hide')){
                    input.classList.remove('slds-hide')
                }
            })
        }else{
            this.template.querySelectorAll('[data-id="warningMessageToRO"]').forEach(input=>{
                if(!input.classList.contains('slds-hide')){
                    input.classList.add('slds-hide')
                }
            })
        }*/
    }

    returnToPreviousPage(){
        this.displayJourneySelection=false
        this.dispatchEvent(new CustomEvent('returntosummary'));
    }

    handleBeginJourney(){
        this.isLoading = true
        callSignDeskAPi({recordId: this.loanAppId, cvIds: this.cvIds, journeyType: this.selectedJourney, esignType: this.esignType}).then((data=>{
            this.isLoading = false
            let callOutData = JSON.parse(data)
            if(callOutData && callOutData.statusCode && callOutData.statusCode!=200){
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
            }else{
                data = JSON.parse(data)
                var response = data.response
                var signerMap = data.signerVsName
                var signerDataToBeDisplayed =[]
                if(response.status == 'success'){
                    this.showToast('Success','We are all set to Proceed with Esign','success');
                    if(this.selectedJourney == 'RO'){
                        response.signer_info.forEach(input=>{
                            signerDataToBeDisplayed.push({SignerName: signerMap[input.signer_ref_id], EsignLink:input.invitation_link})
                        })
                        this.template.querySelector('[data-id="documentLinks"]').classList.remove('slds-hide')
                        this.signerVsLink = signerDataToBeDisplayed
                    }
                    if(this.selectedJourney == 'Customer'){
                        this.template.querySelector('[data-id="successMessageForCJ"]').classList.remove('slds-hide')
                    }
                }else{
                    this.showToast('Error',response.error,'error', 'sticky');
                }
            }
            
        })).catch((error=>{
            this.isLoading = false
            this.showToast('Error',JSON.stringify(error),'error', 'sticky');
        }))
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

}