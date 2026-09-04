import { LightningElement, api, track } from 'lwc';
import panVerification from '@salesforce/apex/LOSNsdlController.nsdlVerificationHandlerUI';
import updatePAN from '@salesforce/apex/LosKYCController.updatePAN';
import updateResponseOnDocument from '@salesforce/apex/AUSFDocumentVerificationController.updateResponseOnDocument'
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
import DocumentPan from '@salesforce/label/c.DocumentPan';
import getDocumentChecklist from '@salesforce/apex/LOSDocumentUploadController.getDocumentChecklist'
import { getSpinnerImage } from 'c/customSpinner';

export default class PanVerificationModal extends LightningElement {

    @api applicantRecord
    @track docVerified
    @track dispType
    @track inValidPanDetail
    @track showPANDetails
    @track identifierDocuments
    @track response
    @track applicant
    @track docChecklist={}
    documentPan = DocumentPan;
    spinnerImage
    @track isLoading

    async connectedCallback(){
        this.applicant = JSON.parse(JSON.stringify(this.applicantRecord))
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    handleChange(event){
        let value = event.target.value
        let name = event.target.name
        let pan = value?value.toUpperCase():undefined;
        this.docVerified = name == 'PAN__c' ? false : true;
        
        this.applicant[event.target.name] = pan;   
    }

    isInputValid(document) {
        console.log('in isInputValid method');
        let isValid = true;
        let inputFields = this.template.querySelectorAll(document);
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
                break;
            } else {
                count++;
            }
        };
        console.log('isValid', isValid);
        return (isValid == false) ? false : true;
    }

    verifyPAN(event) {
        this.isLoading=true;
        console.log('verify pan');
        if (!this.isInputValid('.pan'))
            return;
        
        this.isloading = true;
        this.applicant.Pan_Form60__c = 'Pan Card';  
        this.dispType = 'PAN';     
      
        panVerification({ panNumber: this.applicant.PAN__c, applcntId: this.applicant.Id, msterRecordName: 'NSDL - PAN Verification'})
        .then(result => {
            result = JSON.parse(result);
            console.log('result of pan is:'+JSON.stringify(result));
            let panResonse = {};
            panResonse = result.hasOwnProperty('Response')?result.Response:{};
            if((panResonse.Status == 'Not present in Income Tax Department (ITD) database/Invalid PAN' || panResonse.Status.includes('Invalid')) && (panResonse.Seeding == 'N' || panResonse.Seeding == 'R')){
                this.inValidPanDetail = true;
            }
            else{
                this.inValidPanDetail = false;
            }

            let statusOfPanRespMsg = result.headers.responseMsg;
            this.panVerified = true;
            this.isloading = false;
            let panNo = this.applicant.PAN__c;          
            this.response = result;
            this.docChecklist.Api_Response__c = result ? JSON.stringify(result) : '';
            this.response.Response.pan = panNo;

            if(statusOfPanRespMsg == "Success") {

              this.isloading = false;
              this.verificationTypePAN = false;
              
              this.showPopup();
              this.identifierDocuments = true;
              this.docVerified = false;
            }
            else {
                this.showToastMessage("", statusOfPanRespMsg, "error", "sticky");
                this.isloading = false;
            }
            
            var panFullName =  (result.Response.FirstName != null ? result.Response.FirstName : '') + 
                                    (result.Response.MiddleName != null ? result.Response.MiddleName : '') + 
                                    (result.Response.LastName != null ? result.Response.LastName : '');
            validateNameMatch({ strName: panFullName, strType: 'Pan', strApplicantId: this.applicant.Id})
            .then(resultNameMatch => {
                console.log('resultNameMatch-- '+resultNameMatch);
            })
            .catch(error => {
                console.log('error--> '+error.body.message);
                this.isloading = false;
            })
            this.isLoading=false;
        })
        .catch(error => {
            console.log('error'+error);
            this.isLoading=false;
        }) 
    }

    showPopup() {
        this.showPANDetails = true;
    }

    cancel() {
        this.showPANDetails = false;
        if(this.identifierDocuments == false){
            this.identifierDocuments = true;
            this.docVerified = true;
        }else{
            this.docVerified = false;    
        }
    }

    verifyPANDetails() {
        if(this.inValidPanDetail){
            this.showToastMessage("", this.invalidPanMessageDetail, "error", "sticky");
            return;
        }
        this.applicant.PAN_verification_Status__c = 'Verified';
        this.applicant.Aadhaar_Seeding__c = this.response.Response.Seeding;
        this.updatePANDetails();
        this.showPANDetails = false;
        this.docVerified = true;
    }

    updatePANDetails(dispType) {
    
        updatePAN({ applicant: JSON.stringify(this.applicant) })
            .then(result => {
                console.log('result - pan update: ', result);
                this.updateResponseOnDocument();
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            })
    }

    updateResponseOnDocument(){
        console.log('doc checklist '+(this.docChecklist));
        updateResponseOnDocument({ 
            doc : JSON.stringify(this.docChecklist)
         })
         .then(result => {
            this.showViewResponse = true;
         })
         .catch(error => {
            this.error = error;
            console.log('error', error);
         })
    }

    getDocumentChecklist(){
        getDocumentChecklist({
            applicantId : this.applicant.Id,
            docName : this.documentPan,
            loanId : '',
            fieldInvestId : '',
            collateralId : ''
        }).then((result)=>{
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess && parseResult.docChkList){
                this.docChecklist = parseResult.docChkList[0];
            }
        })
    }
}