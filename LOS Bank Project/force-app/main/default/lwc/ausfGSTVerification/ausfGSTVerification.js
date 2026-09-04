import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyGST from '@salesforce/apex/AUSFDocumentVerificationController.verifyGST';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import mapAddresses from '@salesforce/apex/AUSFDocumentVerificationController.mapAddresses';

export default class AusfGSTVerification extends LightningElement {

    @api applicant={};
    @api documentCheckListRecord={};
    isVerified;
    identifierDocuments=true
    @track response;
    isloading = false;
    showGSTData = false;   
    dispType;

    @api spinnerImage;


    connectedCallback(){
        if(this.documentCheckListRecord.Document_Verification_Status__c==='Verified'){
            this.isVerified=true
        }
    }

    handleVerify(){
        this.verifyGSTNumber();
    }

    verifyGSTNumber() {
        this.isloading = true;        
        let documentNumber = this.documentCheckListRecord.Document_Number__c;
        verifyGST({ gstNum: documentNumber, applicantId: this.applicant.Id})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+JSON.stringify(result));
            let resultData = result.Response;
            if(resultData){
                this.showGSTData=true;
                //this.isVerified  = true; handled in handleIdentifierVerification
                this.response = result;              
                this.dispType ='GST';
                this.isloading = false;
                //this.updateDocumentetails('Verified');handled in handleIdentifierVerification
            }else{
                this.updateDocumentetails('Not Verified');
                this.showToastMessage('','No Match Found for given GST No', 'info', 'sticky');
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
                console.log('updateDocumentetails result - gst update: ', result);
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log('updateDocumentetails error', error);
            })
    }

    handleIdentifierVerification(){
        mapAddresses({ doc: this.documentCheckListRecord, docStatus:'Verified', address: this.response.Response.pradr.adr, applicantId:this.applicant.Id, docType:'GST'}).then((data)=>{
            console.log('Success')
            this.isVerified = true;        
            this.showGSTData = false;                      
            this.isloading = false;
        }).catch(error=>{
            this.isVerified = false;
            this.showGSTData = false;                      
            this.isloading = false;
            this.showToastMessage('Error','We receieved an Error while Processing your Request','error');
        }) 
    }

    showDetails(){
        this.isVerified = false;
        this.updateDocumentetails('Not Verified');
        this.showGSTData = false;        
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(event);
    }
}