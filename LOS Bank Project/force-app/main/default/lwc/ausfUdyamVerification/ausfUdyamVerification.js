import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyUdyam from '@salesforce/apex/AUSFDocumentVerificationController.verifyUdyam';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import mapUdhyamAddress from '@salesforce/apex/AUSFDocumentVerificationController.mapUdhyamAddress';
import fetchUdyamCertificate from '@salesforce/apex/FetchUdyamCertController.fetchUdyamCertificate'
import { NavigationMixin } from "lightning/navigation";
import getUdyamCertificate from '@salesforce/apex/FetchUdyamCertController.getUdyamCertificate'
import getLoanDetails from '@salesforce/apex/AUSFDocumentVerificationController.getLoanDetails'

export default class AusfUdyamVerification extends NavigationMixin(LightningElement) {

    @api applicant={};
    @api documentCheckListRecord={};
    isVerified;
    identifierDocuments=true
    @track response;
    isloading = false;
    showUdyamData = false;   
    dispType;
    @track displayCertificate
    @track contentDocument
    @track udyamCertificate
    @track showSuccessIcon
    @track loan
    @track isTractorLoan


    async connectedCallback(){
        let resp = await getLoanDetails({applicantId: this.applicant.Id});
        this.isTractorLoan = resp && resp[0].Loan__r.RecordType.Name=='Tractor'?true:false
        if(this.documentCheckListRecord.Document_Verification_Status__c==='Verified'){
            this.isVerified=true;
            if(this.isTractorLoan){
                this.udyamCertificate = await getUdyamCertificate({applicantId: this.applicant.Id})
                if(this.udyamCertificate && this.udyamCertificate.ContentDocumentId){
                    this.showSuccessIcon=true
                    this.displayCertificate=true
                }
            }else{
                this.showSuccessIcon=true
            }
            
        }
    }

    handleVerify(){
        this.verifyUdyamNumber();
    }

    verifyUdyamNumber() {
        this.isloading = true;        
        let documentNumber = this.documentCheckListRecord.Document_Number__c;
        verifyUdyam({ udyamNum: documentNumber, applicantId: this.applicant.Id})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+JSON.stringify(result));
            let resultData = result.Response;
            if(resultData){
                this.showUdyamData=true;
                //this.isVerified  = true; handled in handleIdentifierVerification
                this.response = result;              
                this.dispType ='Udyam';
                this.isloading = false;
                //this.updateDocumentetails('Verified'); handled in handleIdentifierVerification
            }else{
                this.updateDocumentetails('Not Verified');
                this.showToastMessage('','No Match Found for given Udyam No', 'info', 'sticky');
            }         
        })
        .catch(error => {
            console.log('error'+error);
            this.isloading = false;
            this.showToastMessage('Error',error.body.message, 'error', 'sticky');
        }) 
    }

    updateDocumentetails(status) {
        this.isloading = true;
        updateDocumentChecklist({ doc: this.documentCheckListRecord,docStatus:status })
            .then(result => {
                console.log('updateDocumentetails result - Udyam update: ', result);
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log('updateDocumentetails error', error);
            })
    }

    handleIdentifierVerification(){
        this.isVerified = true;
        this.isloading = true;
        mapUdhyamAddress({ doc: this.documentCheckListRecord, docStatus:'Verified', address: this.response.Response.officialAddress}).then((data)=>{
            console.log('Success')
            this.showUdyamData = false;
            if(this.isTractorLoan){
                this.showSuccessIcon=false
            }else{
                this.showSuccessIcon=true
            }
            this.isloading = false;
        }).catch(error=>{
            this.showToastMessage('Error','We receieved an Error while Processing your Request','error', 'sticky');
        })
        //this.updateDocumentetails('Verified'); 
                              
    }

    showDetails(){
        this.isVerified = false;
        this.isloading = true;
        if(this.isTractor){
            if(this.udyamCertificate && this.udyamCertificate.ContentDocumentId){
                this.showSuccessIcon=true
                this.displayCertificate=true
            }else{
                this.showSuccessIcon=false
                this.displayCertificate=false
            }
        }else{
            this.showSuccessIcon=true
            this.displayCertificate=false
        }
        mapUdhyamAddress({ doc: this.documentCheckListRecord, docStatus:'Not Verified', address: this.response.Response.officialAddress}).then((data)=>{
            console.log('Success')
            this.showUdyamData = false;
            this.isloading = false;
        }).catch(error=>{
            this.showToastMessage('Error','We receieved an Error while Processing your Request','error', 'sticky');
        })
        //this.showUdyamData = false;        
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    //R2-662
    handleFetchCertificate(event){
        this.isloading = true;
        fetchUdyamCertificate({applicantId: this.applicant.Id}).then(resp=>{
            let data = JSON.parse(resp)
            let callOutData = data.calloutResponseWrapper
            this.udyamCertificate = data.contentDocument
            data = JSON.parse(callOutData.response)
            if(callOutData.statusCode!=200){
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
            }else{
                if(this.udyamCertificate && this.udyamCertificate.ContentDocumentId){
                    this.displayCertificate=true
                    this.showSuccessIcon=true
                    this.showToastMessage('Success','Udyam Certificate Fetched Successfully','success', 'dismissible');
                }else{
                    this.displayCertificate=false
                }
            }
            this.isloading = false;
        }).catch(error=>{
            this.isloading = false;
        })
    }

    handlePreviewClick(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: this.udyamCertificate.ContentDocumentId,
                selectedRecordId: this.udyamCertificate.ContentDocumentId
            }
        })
    }

   
}