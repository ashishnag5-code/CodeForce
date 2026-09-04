import { LightningElement,api } from 'lwc';
import verifyVoterId from '@salesforce/apex/AUSFDocumentVerificationController.verifyVoterId';
//import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentRetryChecklist'; // Retry Logic || START || 20 SEP || ASHISH
import getCount from '@salesforce/apex/AUSFDocumentVerificationController.getCount'; // Retry Logic || END || 20 SEP || ASHISH
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mapVoterIdAddress from '@salesforce/apex/AUSFDocumentVerificationController.mapVoterIdAddress';
import updateKYCDetails from '@salesforce/apex/AUSFDocumentVerificationController.updateKYCDetails';

export default class AusfVoterCardVerification extends LightningElement {

    @api documentCheckListRecord={};
    @api applicant={};
    isloading = false;
    response;
    count=0;
    isVerified = false;
    showVoterIdData = false;
    dispType ='';
    isdisableVerifyButton = false;
    identifierDocuments=true
    finalResponse = {};

    connectedCallback(){
        console.log('applicant '+JSON.stringify(this.documentCheckListRecord))
        if(this.documentCheckListRecord.Document_Verification_Status__c==='Verified'){
            this.isVerified=true
        }
        console.log('isvoterCardVerified in child comp '+JSON.stringify(this.isVerified))
    }
    handleVerify(){
        if (this.isInputValid('.voterId')){
            this.verifyVoterCard();
        }
    }

    /*handleValueChange(event){
        let currentObj = Object.assign({}, this.applicant);
        if(currentObj.Voter_Id__c!=event.target.value){
            this.isvoterCardVerified =false;
        }
        if(event.target.name == 'Voter_Id__c'){
            var voterId = event.target.value
            if(voterId){
                voterId = event.target.value.toUpperCase();
            }
            currentObj[event.target.name] = voterId;
        }else{
            currentObj[event.target.name] = event.target.value;
        }
        this.applicant = currentObj;
        if (this.isInputValid('.voterId')){
            this.isdisableVerifyButton = false;
        }else if(!this.isInputValid('.voterId')){
            this.isdisableVerifyButton = true;
        }

        
    }*/

   async verifyVoterCard() { // Retry Logic || START || 20 SEP || ASHISH
        console.log('verify voter id');
        this.isloading = true;        
        let currentCount = await getCount({doc: this.documentCheckListRecord});  // Retry Logic || START || 20 SEP || ASHISH
        //this.updatePANDetails();
        let voterId = this.documentCheckListRecord.Document_Number__c;
        verifyVoterId({ voterId: voterId, objectId: this.applicant.Id, msterRecordName: 'VoterCard API'})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+JSON.stringify(result));
            console.log('result is:'+JSON.stringify(result.Response));
            console.log('result is:'+JSON.stringify(result.metadata));
            this.finalResponse = Object.assign(this.finalResponse, result.Response);
            //this.panVerified = true;
            let resultData = result.Response;
            if(result.statusCode===200){
                if(resultData.epic_no){
                    //this.isVerified = true; added in handleIdentifierVerification
                    this.response = result;
                    this.showVoterIdData=true;
                    //this.dispType ='voterid'
                    this.dispType ='Voter ID'
                    /*const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    obj.next = true;
                    this.dispatchEvent(new CustomEvent('voterverify', {
                        detail: obj
                    }));
                    this.updateDocumentetails('Verified');*///added in handleIdentifierVerification
                    //4291
                    this.documentCheckListRecord = JSON.parse(JSON.stringify(this.documentCheckListRecord))
                    this.documentCheckListRecord.Api_Response__c = JSON.stringify(this.response.Response)
                    //4291
                    var panFullName =  result.Response.name != null ? result.Response.name : '';
                    //4291 - commented validateNameMatch
                    /*validateNameMatch({ strName: panFullName, strType: 'Voter ID Card', strApplicantId: this.documentCheckListRecord.Applicant__c, strRecordId:''})
                    .then(resultNameMatch => {
                        console.log('validateNameMatch result '+resultNameMatch);
                        this.isloading = false;
                    })
                    .catch(error => {
                        console.log('validateNameMatch error'+error);
                        this.isloading = false;
                    })*/
                    
                }else{
                    const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    obj.next = true;
                    this.dispatchEvent(new CustomEvent('voterverify', {
                        detail: obj
                    }));
                    this.updateDocumentetails('Not Verified');
                    this.showError('info','No Match Found for given Voter Id');
                    this.isloading = false;
                   
                }
            }/*else{
                this.count =this.count+1;
                const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    if(this.count<3){
                        obj.next = false;
                    }else{
                        obj.next = true;
                    }
                    this.dispatchEvent(new CustomEvent('voterverify', {
                        detail: obj
                    }));
                    if(this.count<3){
                        this.updateDocumentetails('Not Verified');
                    }
                    this.showError('error',result.errorMessage);
                    
            }*/
            // Retry Logic || START || 20 SEP || ASHISH
             else if(result.statusCode===102 || result.statusCode===103  || result.statusCode===104  || result.statusCode===105  || result.statusCode===106 || result.statusCode===107 || result.statusCode===108 || result.statusCode===109 || result.statusCode ===404 ) {
                 
                this.count = currentCount+1;
                    const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    if(this.count<3){
                        obj.next = false;
                    }else{
                        obj.next = true;
                    }
                    this.dispatchEvent(new CustomEvent('voterverify', {
                        detail: obj
                    }));
                    this.updateDocumentetails('Not Verified');
                    this.showError('error',result.errorMessage);
             
            }
            // Retry Logic || END || 20 SEP || ASHISH

            
            

            this.error = undefined;
            this.isloading = false;
            
        })
        .catch(error => {
            console.log('error'+error);
            this.isloading = false;
            this.showError('error','Error found');
            this.updateDocumentetails('Not Verified');
        }) 
    }

    handleIdentifierVerification(){
        this.isloading = true;
        mapVoterIdAddress({doc: this.documentCheckListRecord,docStatus: 'Verified', result: this.response.Response}).then((data=>{
            this.isVerified = true;
            this.isloading = false;
            console.log('final response '+JSON.stringify(this.finalResponse));
            updateKYCDetails({
                result : JSON.stringify(this.finalResponse),
                applicantId : this.documentCheckListRecord.Applicant__c
            }).then(data=>{
                console.log('data '+data);
            })
            .catch(error=>{
                console.log('error '+JSON.stringify(error));
            });
            const obj = {};
            obj.voterIdVerified = this.isVerified;
            obj.next = true;
            this.dispatchEvent(new CustomEvent('voterverify', {
                detail: obj
            }));
            this.showVoterIdData = false;

        })).catch(error=>{
            this.showVoterIdData = false;                      
            this.isloading = false;
            this.showError('We receieved an Error while Processing your Request','error');
        })
        
        
        
                    
    }

    showDetails(){
        this.isVerified = false;
        const obj = {};
        obj.voterIdVerified = this.isVerified;
        obj.next = true;
        this.dispatchEvent(new CustomEvent('voterverify', {
            detail: obj
        }));
        this.updateDocumentetails('Not Verified')
        this.showVoterIdData = false;
    }
    /*updatePANDetails() {
    
        updatePAN({ applicant: JSON.stringify(this.applicant) })
            .then(result => {
                console.log('result - pan update: ', result);
                
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            })
    }*/

    updateDocumentetails(status) {
        this.isloading = true;
        //this.documentCheckListRecord.Document_Verification_Status__c = status;
        console.log('this.applicant '+ JSON.stringify(this.documentCheckListRecord))
        updateDocumentChecklist({ doc: this.documentCheckListRecord,docStatus:status, address:'' })
            .then(result => {
                console.log('updateDocumentetails result - pan update: ', result);
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log('updateDocumentetails error', error);
            })
    }

    showError(variant, error) {
        console.log('show error', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: error,
                variant: variant,
            }),
        );
    }

    isInputValid(document) {
        console.log('in isInputValid method');
        let count = 0;
        let isValid = true;
        let inputFields = this.template.querySelectorAll(document);
        console.log('fields: ', inputFields);
        // inputFields.forEach(inputField => {
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                console.log('input fiel name ' + inputField.name)
                inputField.reportValidity();
                isValid = false;
                break;
            } else {
                inputField.reportValidity();
                count++;
            }
        };
        console.log('isValid', isValid);
        console.log('count', count);

        return (isValid == false) ? false : count;
    }
}