import { LightningElement,api } from 'lwc';
import verifyPassport from '@salesforce/apex/AUSFDocumentVerificationController.verifyPassport';
//import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentRetryChecklist'; //  // Retry Logic || START || 20 SEP || ASHISH
import getCount from '@salesforce/apex/AUSFDocumentVerificationController.getCount'; // Retry Logic || END || 20 SEP || ASHISH
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
import updatePAN from '@salesforce/apex/LosKYCController.updatePAN';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updatePassportKYCDetails from '@salesforce/apex/AUSFDocumentVerificationController.updatePassportKYCDetails';

export default class AusfPassportVerification extends LightningElement {

    //@api documentCheckListRecord={};
    @api applicant;
    identifierDocuments=true
    voterId;
    isloading = false;
    response;
    isVerified = false;
    showVoterIdData = false;
    dispType ='';
    isdisableVerifyButton = true;
    isDisabled=false
    count=0;
    todaysDate=''
    maxDate;

    @api spinnerImage;
    
    docCheckRecord ={};
    @api 
    get documentCheckListRecord(){
        return this.docCheckRecord;
    }
    set documentCheckListRecord(value){
        console.log('in setter '+JSON.stringify(value))
        this.docCheckRecord = value
        if(this.docCheckRecord.Document_Verification_Status__c==='Verified'){
            this.isVerified=true
        }
        if(this.docCheckRecord.Document_Verification_Status__c==='Not Verified'){
            if(this.docCheckRecord.Document_Expiry_Date__c && this.docCheckRecord.Passport_File_Number__c){
                this.isdisableVerifyButton = false;
            }
        }
    }

    connectedCallback(){
        console.log('document checklist record '+JSON.stringify(this.docCheckRecord))
        /*if(this.documentCheckListRecord.Document_Verification_Status__c==='Verified'){
            this.isvoterCardVerified=true
        }*/
        var newDate = new Date()
        this.todaysDate = newDate.getFullYear() + '-' + (newDate.getMonth() + 1).toString().padStart(2, '0') + '-' + newDate.getDate().toString().padStart(2, '0');
        if(this.applicant.Dob__c){
            this.isDisabled=true
        }else{
            this.isDisabled=false
        }
        this.getToday(); //SFAU 2872
    }
    getToday() { //SFAU 2872
        const today = new Date();
        const year = today.getFullYear();
        let month = today.getMonth() + 1;
        let day = today.getDate();

        if (month < 10) {
            month = '0' + month;
        }
        if (day < 10) {
            day = '0' + day;
        }

        this.maxDate = `${year}-${month}-${day}`;
    } //ENd

    handleVerify(){
        if(!this.isDisabled && (this.applicant.Dob__c==null || this.applicant.Dob__c=='')){
            this.showError('error','Please enter date of birth to verify passport');
        }else{
            if (this.isInputValid('.validate')){
                this.verifyPassportNumber();
            }
        }
        
    }

    handleDobChange(event){
        let currentObj = Object.assign({}, this.applicant);
        currentObj[event.target.name] = event.target.value;
        this.applicant = currentObj;
        //this.applicant.Dob__c = event.target.value;
    }

    handleValueChange(event){
        let currentObj = Object.assign({}, this.docCheckRecord);
        currentObj[event.target.name] = event.target.value;
        /*if(event.target.name == 'Passport_Number__c'){
            var passport = event.target.value
            if(passport){
                passport = event.target.value.toUpperCase();
            }
            currentObj[event.target.name] = passport;
        }else{
            currentObj[event.target.name] = event.target.value;
        }*/
        this.docCheckRecord = currentObj;
        if (this.isInputValid('.validate')){
            this.isdisableVerifyButton = false;
        }else if(!this.isInputValid('.validate')){
            this.isdisableVerifyButton = true;
        }
    }

    updatePANDetails() {
    
        updatePAN({ applicant: JSON.stringify(this.applicant) })
            .then(result => {
                this.isloading = false;
                console.log('result - pan update: ', result);
                
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
                this.isloading = false;
            })
    }

    async verifyPassportNumber() {   // Retry Logic || START || 20 SEP || ASHISH
        console.log('verify passport');
        let currentCount = await getCount({doc: this.documentCheckListRecord});  // Retry Logic || START || 20 SEP || ASHISH
        this.isloading = true; 
        if(!this.isDisabled){
            this.updatePANDetails();
        }       
        let temp = this.applicant.Dob__c;
        let new_date;
        if(temp){
            console.log('applicant '+ JSON.stringify(this.applicant));
            let date_explode = temp.split('-');
            new_date = date_explode[2]+'/'+date_explode[1]+'/'+date_explode[0];
            console.log('new_date is in Passport >'+new_date)
        }
        
        verifyPassport({ fileNum: this.docCheckRecord.Passport_File_Number__c, passportNum: this.docCheckRecord.Document_Number__c,dob: new_date,objectId: this.applicant.Id, msterRecordName: 'PassportVerification'})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+result);
            console.log('result is:'+JSON.stringify(result.Response));
            console.log('result is:'+JSON.stringify(result.metadata));
            //this.panVerified = true;
            let resultData = result.Response;
            if(result.statusCode===200){
                if(resultData.passportNumberFromSource){
                    //this.isVerified = true; handled in handleIdentifierVerification
                    this.response = result;
                    this.showVoterIdData=true;
                    //this.dispType ='voterid'
                    this.dispType ='Passport'
                    /*const Obj = {};
                    Obj.passportVerified = this.isVerified;
                    this.dispatchEvent(new CustomEvent('passportverify', {
                        detail: Obj
                    }));*/

                    /*const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    obj.next = true;
                    this.dispatchEvent(new CustomEvent('passportverify', {
                        detail: obj
                    }));
                    
                    this.updateDocumentetails('Verified'); *///handled in handleIdentifierVerification
                    //4291
                    this.documentCheckListRecord = JSON.parse(JSON.stringify(this.documentCheckListRecord))
                    this.documentCheckListRecord.Api_Response__c = JSON.stringify(this.response.Response)
                    //4291
                    var panFullName =  (result.Response.nameFromPassport != null ? result.Response.nameFromPassport : '') + 
                                        (result.Response.surnameFromPassport != null ? result.Response.surnameFromPassport : '');
                    //commented validateNameMatch - 4291
                    /*validateNameMatch({ strName: panFullName, strType: 'Passport', strApplicantId: this.applicant.Id, strRecordId:''})
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
                    this.dispatchEvent(new CustomEvent('passportverify', {
                        detail: obj
                    }));
                    this.showError('info','No Match Found for given Passport Number');
                    this.updateDocumentetails('Not Verified');
                   
                    this.isloading = false;
                }
            }else if(result.statusCode===102 || result.statusCode===103  || result.statusCode===104  || result.statusCode===105  || result.statusCode===106 || result.statusCode===107 || result.statusCode===108 || result.statusCode===109 || result.statusCode ===404 ) { // Retry Logic || START || 20 SEP || ASHISH
                 this.count = currentCount+1;
                    const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    if(this.count<3){
                        obj.next = false;
                    }else{
                        obj.next = true;
                    }
                    this.dispatchEvent(new CustomEvent('passportverify', {
                        detail: obj
                    }));
                    this.updateDocumentetails('Not Verified');
                    this.showError('error',result.errorMessage);
                    this.isloading = false;  // Retry Logic || END || 20 SEP || ASHISH
            }/*else{
                this.count =this.count+1;
                    const obj = {};
                    obj.voterIdVerified = this.isVerified;
                    if(this.count<3){
                        obj.next = false;
                    }else{
                        obj.next = true;
                    }
                    this.dispatchEvent(new CustomEvent('passportverify', {
                        detail: obj
                    }));
                    if(this.count<3){
                        this.updateDocumentetails('Not Verified');
                    }
                    this.showError('error',result.errorMessage);
                    
                    this.isloading = false;
            }*/
            

            this.error = undefined;
            this.isloading = false;
            
        })
        .catch(error => {
            console.log('error'+error);
            this.isloading = false;
            this.showError('error','Error found');
            this.updateDocumentetails('Not Verified');
            //this.updateDocumentetails('Verified Bad','AUWheels0002');
        }) 
    }

    handleIdentifierVerification(){
        this.isVerified = true;
        //Below lines added as per Bug-2439
        console.log('final response '+JSON.stringify(this.response.Response));
        updatePassportKYCDetails({
            result : JSON.stringify(this.response.Response),
            applicantId : this.applicant.Id
        }).then(data=>{
            console.log('data '+data);
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        });
        const obj = {};
        obj.voterIdVerified = this.isVerified;
        obj.next = true;
        this.dispatchEvent(new CustomEvent('passportverify', {
            detail: obj
        }));
        this.updateDocumentetails('Verified');    
        this.showVoterIdData = false;                              
    }

    showDetails(){
        this.isVerified = false;
        const obj = {};
        obj.voterIdVerified = this.isVerified;
        obj.next = true;
        this.dispatchEvent(new CustomEvent('passportverify', {
            detail: obj
        }));
        this.updateDocumentetails('Not Verified');    
        this.showVoterIdData = false; 
    }

    updateDocumentetails(status) {
        this.isloading = true;
        updateDocumentChecklist({doc: this.documentCheckListRecord,docStatus:status})
            .then(result => {
                console.log('result - pan update: ', result);
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log('error', error);
            })
    }

    showError(variant, error) {
        console.log('show error', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: error,
                variant: variant,
                mode :'sticky'
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