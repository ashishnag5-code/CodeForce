import { LightningElement,api } from 'lwc';
import verifyDL from '@salesforce/apex/AUSFDocumentVerificationController.verifyDL';
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
//import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentRetryChecklist'; // Retry Logic || START || 20 SEP || ASHISH
import getCount from '@salesforce/apex/AUSFDocumentVerificationController.getCount'; // Retry Logic || END || 20 SEP || ASHISH
import updatePAN from '@salesforce/apex/LosKYCController.updatePAN';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import mapAddresses from '@salesforce/apex/AUSFDocumentVerificationController.mapAddresses';
import updateDLKYCDetails from '@salesforce/apex/AUSFDocumentVerificationController.updateDLKYCDetails';

export default class AusfDriverLicenceVerification extends LightningElement {

    identifierDocuments=true
    @api applicant={};
    voterId;
    isloading = false;
    response;
    isVerified = false;
    showVoterIdData = false;
    dispType ='';
    isdisableVerifyButton = true;
    count =0;
    docCheckRecord ={};
    todaysDate=''
    dob;

    @api spinnerImage;

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
                this.isdisableVerifyButton = false;  
        }

    }

    connectedCallback(){
        var newDate = new Date()
        this.todaysDate = newDate.getFullYear() + '-' + (newDate.getMonth() + 1).toString().padStart(2, '0') + '-' + newDate.getDate().toString().padStart(2, '0');
        console.log('docCheckRecord '+JSON.stringify(this.docCheckRecord))
        if(this.applicant?.Dob__c){		
            console.log('dob present '+this.applicant.Dob__c);
            this.isdisableVerifyButton = false;		
        }

    }
    handleVerify(){
        if (this.isInputValid('.validate')){
            this.verifyDL();
        }
    }

    handleValueChange(event){
        let currentObj = Object.assign({}, this.docCheckRecord);
        currentObj[event.target.name] = event.target.value;
        /*if(event.target.name == 'Driving_License_Id__c'){
            var drivingLicense = event.target.value
            if(drivingLicense){
                drivingLicense = event.target.value.toUpperCase();
            }
            currentObj[event.target.name] = drivingLicense;
        }else{
            currentObj[event.target.name] = event.target.value;
        }*/
        this.docCheckRecord = currentObj;
        if (this.isInputValid('.validate')){
            this.isdisableVerifyButton = false;
        }/*else if(!this.isInputValid('.validate')){
            this.isdisableVerifyButton = true;
        }*/
    }

    handleDobChange(event){
        //let currentObj = Object.assign({}, this.applicant);
        console.log('value '+event.detail.value);
        this.dob = event.detail.value;
        var date = new Date(event.detail.value);
        var diff_ms = Date.now() - date.getTime();
        var age_dt = new Date(diff_ms); 
        console.log('diff '+diff_ms+' age_dt '+age_dt);
        var age = Math.abs(age_dt.getUTCFullYear() - 1970);
        console.log('age '+age);
        if(age>=18){
            this.isdisableVerifyButton = false;
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Age cannot be less than 18',
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
        }
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

    async verifyDL() {
        console.log('verify Driving License id');
        this.isloading = true;    
        let currentCount = await getCount({doc: this.documentCheckListRecord});  // Retry Logic || START || 20 SEP || ASHISH
        //this.updatePANDetails();
        let currentObj = Object.assign({}, this.applicant);		
        if(!!this.dob){
            currentObj['Dob__c'] = this.dob;		
            this.applicant = currentObj;		
        }
        let temp = this.applicant.Dob__c;
        console.log('this.applicant '+ JSON.stringify(this.applicant));
        //var split_space = temp.split(' ');
        //var date_part = space[0];
        let new_date;
        if(temp){
            let date_explode = temp.split('-');
            console.log('date_explode '+date_explode)
            new_date = date_explode[2]+'-'+date_explode[1]+'-'+date_explode[0];

        }/*else{
            this.isloading = false;
            this.showError('info','Date of birth is required to verify Driving License');
        }*/
        

        verifyDL({ drivingId: this.docCheckRecord.Document_Number__c, objectId: this.applicant.Id,msterRecordName: 'DrivingLicenseVerification',dob: new_date})
        .then(result => {
            result = JSON.parse(result);
            console.log('result is:'+result);
            console.log('result is:'+JSON.stringify(result.Response));
            console.log('result is:'+JSON.stringify(result.metadata));
            //this.panVerified = true;
            let resultData = result.Response;
            if(result.statusCode===200){
                          if(resultData.dl_number){
                    //this.isVerified = true; added in handleIdentifierVerification
                    this.response = result;
                    this.showVoterIdData=true;
                    //this.dispType ='voterid'
                    this.dispType ='Driving Licence'
                        if (result.Response.validity.nontransport !== null) {
                          let expirationDateString = result.Response.validity.nontransport;
                          let date_explode = expirationDateString.split('-');
                          let  newValidatityDate = date_explode[2]+'-'+date_explode[1]+'-'+date_explode[0];
                          let expirationDate = new Date(newValidatityDate);
                          let currentDate = new Date();

                    if (!isNaN(expirationDate) && expirationDate < currentDate) {
                          this.showError("Error", "Driving license is expired. Please update a valid one.");
                          this.showVoterIdData=false;
                          this.isloading = false;    
                          const obj = {};
                          obj.voterIdVerified = this.isVerified;
                          obj.next = false;
                          this.dispatchEvent(new CustomEvent('dlverify', {
                            detail: obj
                          }));
                          return;
  }
}
                    /*const Obj = {};
                    Obj.dlVerified = this.isvoterCardVerified;
                    this.dispatchEvent(new CustomEvent('dlverify', {
                        detail: Obj
                    }));*/
                    /*const obj = {};
                        obj.voterIdVerified = this.isVerified;
                        obj.next = true;
                        this.dispatchEvent(new CustomEvent('dlverify', {
                            detail: obj
                        }));
                    this.updateDocumentetails('Verified');*/ //added in handleIdentifierVerification
                    this.documentCheckListRecord = JSON.parse(JSON.stringify(this.documentCheckListRecord))
                    this.documentCheckListRecord.Api_Response__c = JSON.stringify(this.response.Response)
                    var panFullName =  result.Response.name != null ? result.Response.name : '';
                    //commented validateNameMatch - 4291
                    /*validateNameMatch({ strName: panFullName, strType: 'Driving Licence', strApplicantId: this.applicant.Id, strRecordId:''})
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
                        this.dispatchEvent(new CustomEvent('dlverify', {
                            detail: obj
                        }));
                    this.showError('info','No Match Found for given Driving Licence');
                    this.updateDocumentetails('Not Verified');
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
                        this.dispatchEvent(new CustomEvent('dlverify', {
                            detail: obj
                        }));
                        if(this.count<3){
                            this.updateDocumentetails('Not Verified');
                        }
                        this.showError('error','Something Went Wrong, Please try again.');
                        this.isloading = false;
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
                    this.dispatchEvent(new CustomEvent('dlverify', {
                        detail: obj
                    }));
                    this.updateDocumentetails('Not Verified');
                    this.showError('error',result.errorMessage);
                    this.isloading = false;
            }
            // Retry Logic || END || 20 SEP || ASHISH


            this.error = result.errorMessage;
             this.showError('Error',this.error);
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
        mapAddresses({ doc: this.documentCheckListRecord, docStatus:'Verified', address: this.response.address, applicantId:this.applicant.Id, docType:'DrivingLicence'}).then((data)=>{
            console.log('Success')
            this.isVerified = true;
            console.log('final response '+JSON.stringify(this.response.Result));
            updateDLKYCDetails({
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
            this.dispatchEvent(new CustomEvent('dlverify', {
                detail: obj
            }));
            this.showVoterIdData = false;                      
            this.isloading = false;
        }).catch(error=>{
            this.showVoterIdData = false;                      
            this.isloading = false;
            this.showError('error',result.errorMessage);
        })
    }

    showDetails(){
        this.isVerified = false;
        const obj = {};
        obj.voterIdVerified = this.isVerified;
        obj.next = true;
        this.dispatchEvent(new CustomEvent('dlverify', {
            detail: obj
        }));
        this.updateDocumentetails('Not Verified');           
        this.showVoterIdData = false;  
    }

    updateDocumentetails(status) {
        this.isloading = true;
        updateDocumentChecklist({doc: this.documentCheckListRecord,docStatus:status,address:''})
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
                mode: variant === 'error' ? 'sticky' : 'dismissible'
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
                console.log('input fiel name ' + inputField.value)
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