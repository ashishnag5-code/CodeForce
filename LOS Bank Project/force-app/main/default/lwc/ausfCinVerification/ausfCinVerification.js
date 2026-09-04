import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyCmpName from '@salesforce/apex/AUSFDocumentVerificationController.verifyCmpName';
import fetchDirectorsData from '@salesforce/apex/AUSFDocumentVerificationController.fetchDirectorsData';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import mapAddresses from '@salesforce/apex/AUSFDocumentVerificationController.mapAddresses';



export default class AusfCinVerification extends LightningElement {

    
 columns = [
         { label: 'DIN/DPIN/PAN', fieldName: 'wheather_dsc_registered' },
         { label: 'full name', fieldName: 'full_name' },
         { label: 'designation', fieldName: 'designation' },
        { label: 'date of appointment', fieldName: 'date_of_appointment'},
        { label: 'wheather dsc registered', fieldName: 'wheather_dsc_registered' },
        { label: 'dsc expiry date', fieldName: 'dsc_expiry_date' },
 
    
    ];
    @api applicant={};
    @api documentCheckListRecord={};
    @track isVerified;
   @track displayVerificationButtons=false
    identifierDocuments=true
    @track response;
    isloading = false;
    showCINData = false;   
    dispType;
    showCinNum=false;
    @track cmpCinNum;
    @track directorDetails=false;
    @track directorsData;
    @track diRresults;


    connectedCallback(){
        if(this.documentCheckListRecord.Document_Verification_Status__c==='Verified'){
            this.isVerified=true;
        }
    }

    handleVerify(){
        this.verifyCINNumber();
    }

   /* verifyCINNumber() {
        this.isloading = true;        
        let documentNumber = this.documentCheckListRecord.Document_Number__c;
        verifyCmpName({ cmpName: documentNumber, applicantId: this.applicant.Id})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+JSON.stringify(result));
            let resultData = result.Response;
            if(resultData){
                this.showCINData=true;
                //this.isVerified  = true; handled in handleIdentifierVerification
                this.response = result;              
                this.dispType ='CIN';
                this.isloading = false;
                //this.updateDocumentetails('Verified'); handled in handleIdentifierVerification
            }else{
                this.updateDocumentetails('Not Verified');
                this.showToastMessage('','No Match Found for given CIN No', 'info', 'sticky');
            }         
        })
        .catch(error => {
            console.log('error'+error);
            this.isloading = false;
            this.showError('Error',error.body.message, 'error', 'sticky');
        }) 
    }*/
async verifyCINNumber() {
    try {
        this.isloading = true;
        let documentNumber = this.documentCheckListRecord.Document_Number__c;
        let cinNum = await verifyCmpName({ cmpName: documentNumber, applicantId: this.applicant.Id });
        console.log('result is:' + cinNum);
        if (cinNum) {
            this.cmpCinNum = cinNum;
            this.showCinNum = true;
            const MCAresponse = await fetchDirectorsData({ cinNumber: cinNum, applicantId: this.applicant.Id });
                if (MCAresponse) {
                    this.directorsData = JSON.parse(MCAresponse);
                    this.diRresults = this.directorsData.result;
                    this.displayVerificationButtons = true;
                    this.directorDetails = true;
                }
         // this.showCINData = true;
           //  this.isVerified = true; // handled in handleIdentifierVerification
          // this.response = MCAresponse;
          // this.dispType = 'MCA';
           this.isloading = false;
            // this.updateDocumentetails('Verified'); // handled in handleIdentifierVerification
        } else {
            this.updateDocumentetails('Not Verified');
            this.showToastMessage('', 'No Match Found for given CIN No', 'info', 'sticky');
        }
         
    } catch (error) {
        console.log('error' + error);
        this.isloading = false;
        this.showError('Error', error.body.message, 'error', 'sticky');
    }
}

    updateDocumentetails(status) {
        this.isloading = true;
        updateDocumentChecklist({ doc: this.documentCheckListRecord,docStatus:status, address:'' })
            .then(result => {
                console.log('updateDocumentetails result - CIN update: ', result);
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log('updateDocumentetails error', error);
            })
    }

    handleIdentifierVerification(){
        mapAddresses({ doc: this.documentCheckListRecord, docStatus:'Verified', address: this.response.Response.registered_Address, applicantId:this.applicant.Id, docType:'CIN'}).then((data)=>{
            console.log('Success')
            this.isVerified = true;        
            this.showCINData = false;                      
            this.isloading = false;
        }).catch(error=>{
            this.isVerified = false;
            this.showCINData = false;                      
            this.isloading = false;
            this.showToastMessage('Error','We receieved an Error while Processing your Request','error', 'sticky');
        })                          
    }

    showDetails(){
        this.isVerified = false;
        this.updateDocumentetails('Not Verified');  
        this.showCINData = false;  
    }
    handleNotVerified(){
        this.displayVerificationButtons=false;
    }
    handleVerified(){
        this.isVerified=true;
        this.displayVerificationButtons=false;
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
}