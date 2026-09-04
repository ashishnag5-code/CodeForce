import { LightningElement, api, track } from 'lwc';
import panVerification from '@salesforce/apex/LOSNsdlController.nsdlVerificationHandlerUI';
import verifyVoterId from '@salesforce/apex/AUSFDocumentVerificationController.verifyVoterId';
import verifyPassport from '@salesforce/apex/AUSFDocumentVerificationController.verifyPassport';
import verifyDL from '@salesforce/apex/AUSFDocumentVerificationController.verifyDL';
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
import aadhaar from '@salesforce/resourceUrl/aadhaar';
import ckyc from '@salesforce/resourceUrl/ckyc';
import pan from '@salesforce/resourceUrl/PanCard';
import panVerified from '@salesforce/resourceUrl/panVerified';
import form60Verified from '@salesforce/resourceUrl/form60Verified';
import form60 from '@salesforce/resourceUrl/form60';
import DocumentPan from '@salesforce/label/c.DocumentPan';
import kycNotVerifiedErrorMessage from '@salesforce/label/c.KYCNotVerifiedError';
import updatePAN from '@salesforce/apex/LosKYCController.updatePAN';
import updateDocumentChecklist from '@salesforce/apex/AUSFDocumentVerificationController.updateDocumentChecklist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/AUSFDocumentVerificationController.getDetails'
import getApplicantDetails from '@salesforce/apex/LOSNsdlController.getApplicantDetails'
import updateResponseOnDocument from '@salesforce/apex/AUSFDocumentVerificationController.updateResponseOnDocument'
import getDocumentChecklist from '@salesforce/apex/LOSDocumentUploadController.getDocumentChecklist'
import updateStatus from '@salesforce/apex/LOSNsdlController.updateStatus'
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import { NavigationMixin } from 'lightning/navigation';
import deactivateDocument from '@salesforce/apex/LOSDocumentManagerController.deactivateDocument'
import FORM_FACTOR from '@salesforce/client/formFactor';
import getVersionFilesByChecklist from '@salesforce/apex/LOSDocumentUploadController.getVersionFilesByChecklist'
import InvalidPanMessage from '@salesforce/label/c.InvalidPanMessage';



export default class LosPanVerification extends NavigationMixin(LightningElement) {
    aadhaarIcon = aadhaar;
    ckycIcon = ckyc;
    pan = pan;
    panVerified = panVerified;
    form60Verified = form60Verified;
    form60 = form60;
    verificationType;
    verificationTypePAN = false;
    verificationTypeForm60 = false;
    isloading = false;
    docVerified = false;
    isEnabledVoterId = false;
    isEnabledDrivingLicence = false;
    isEnabledPassport = false;
    isEnabledGst = false;
    isEnabledCin = false;
    isEnabledUdyam = false;
    isShowAdditionalInformationsPicklist = false;
    AdditionalInformationvalue = {};
    showVerificationOptions = false;
    @api applicantRecord = {};
    @track applicant = {};
    @track documentChecklist;
    @api loanAmount;
    docChecklist = {}
    dispType;
    today;
    mandatoryDocCount = 1;
    response;
    showBanner;
    @api isPanMandatory;
    showPANDetails = false;
    voterIdVerified=false
    dlVerified=false
    passportVerified=false
    voterDocumentChecklist;
    passportDocumentChecklist;
    drivingLicenseDocumentChecklist
    gstDocumentChecklist;
    cinDocumentChecklist;
    udyamDocumentChecklist;
    isVoterCardVerified = false;
    isDrivingLicenseVerified = false;
    isPassportVerified = false;
    isform60uploaded = false;
    identifierDocuments = false;
    disableVerifyPanButton = true;
    documentPan = DocumentPan;
    showOCRDetails = false;
    disableOkButton = false;
    trueValue = true;
    isloading = false;
    @track dataValues = [];
        documentChkRecord;
        documentNumber;
        isAadhar;
        contentVersionId;
        eventdocName;
    @track showAdditional;
    isMobile;
    // 'PAN__c' : 'BRRFS1234M',
    //  'Voter_Id__c' : 'ABCDs1234M',
    @api spinnerImage
    showViewResponse = false;
    @track AdditionalInformationoptions = [
        { label: 'Voter Id', value: 'Voter Id' },
        { label: 'Driving Licence', value: 'Driving Licence' },
        { label: 'Passport', value: 'Passport' },
    ];
    @track allAdditionalInformationvalues = [];
    @track inValidPanDetail = false;
    @track invalidPanMessageDetail = InvalidPanMessage;

    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

    connectedCallback() {
        this.setFormFactor();
        const verificationStatus = this.applicant?.PAN_verification_Status__c ?? this.applicantRecord?.PAN_verification_Status__c;//R2-2422 - the public property coming from generic wizard will not have Verification status - Verified ( if we come back from other screen Verification status will get Un verified since parent did not have it)
        this.applicant = Object.assign(this.applicant, this.applicantRecord, { PAN_verification_Status__c: verificationStatus });
        if(this.applicant && this.applicant.Pan_Form60__c=='Form 60'){
            this.verificationTypeForm60 = true;
            this.getVersionFiles();
        }
        this.today = new Date().toISOString().split('T')[0];
        console.log('pan component:');
        console.log('this.isPanRequired'+this.isPanRequired);
        console.log('applicant last name:'+JSON.stringify(this.applicant));
        console.log('applicant last name:'+this.applicant.Last_Name__c);
        /* SFAU-5538 - CIF Number related change - Move this server call before */
        getApplicantDetails({recordId: this.applicant.Id}).then((data)=>{
            this.applicant.Dob__c = data.Dob__c;
            this.applicant.Customer_Type__c = data.Customer_Type__c;
            this.applicant.NPR__c = data.NPR__c;
            this.applicant.NREGA__c = data.NREGA__c;
            this.applicant.Voter_Id__c = data.Voter_Id__c;
            this.applicant.Driving_License_Id__c = data.Driving_License_Id__c;
            this.applicant.Passport_Number__c = data.Passport_Number__c;
            this.applicant.First_Name__c = data.First_Name__c;
            this.applicant.Last_Name__c = data.Last_Name__c;
            this.applicant.KYC_Status__c = data.KYC_Status__c;
            this.applicant.KYC_Type__c = data.KYC_Type__c;
            this.applicant.Existing_Customer__c = data.Existing_Customer__c;
            this.applicant.PAN__c = data.PAN__c;
            this.applicant.CIF_No__c = data.CIF_No__c;
            this.setIcons(data.Pan_Form60__c);
            this.getDocumentChecklist();
            this.initializeVerificationData ();
        }).catch(error => {
            console.log('error'+error);
            this.initializeVerificationData ();
        }) 

        
    }

    initializeVerificationData () {
        if ((this.applicant && this.applicant.PAN__c) || this.isPanMandatory) {
            if(this.applicant && this.applicant.PAN__c){
                this.disableVerifyPanButton = false;
            }
            this.showVerificationOptions = false;
            this.verificationTypeForm60 = false;
            this.verificationTypePAN = true;
            this.showAdditional = true;
            this.showBanner = false;
            this.applicant.Pan_Form60__c = 'PAN';
            console.log('banner:', this.showBanner);
            // document.getElementsByClassName('.banner').addClass('.slds-hide');
        } else {
           // this.showVerificationOptions = true;
            this.verificationTypeForm60 = false;
            this.verificationTypePAN = true;
            this.showAdditional = true;
            this.showBanner = true;
            this.applicant.Pan_Form60__c = 'Form 60';
            //this.returnToParent();
            console.log('banner2:', this.showBanner);
        }

        if (this.applicant && !this.applicant.Last_Name__c)
            this.mandatoryDocCount = 2;

        if(this.applicant.PAN_verification_Status__c == 'Verified')
            this.docVerified = true;
        /*
        getApplicantDetails({recordId: this.applicant.Id}).then((data)=>{
            this.applicant.Dob__c = data.Dob__c;
            this.applicant.Customer_Type__c = data.Customer_Type__c;
            this.applicant.NPR__c = data.NPR__c;
            this.applicant.NREGA__c = data.NREGA__c;
            this.applicant.Voter_Id__c = data.Voter_Id__c;
            this.applicant.Driving_License_Id__c = data.Driving_License_Id__c;
            this.applicant.Passport_Number__c = data.Passport_Number__c;
            this.applicant.First_Name__c = data.First_Name__c;
            this.applicant.Last_Name__c = data.Last_Name__c;
            this.applicant.KYC_Status__c = data.KYC_Status__c;
            this.applicant.KYC_Type__c = data.KYC_Type__c;
            this.applicant.Existing_Customer__c = data.Existing_Customer__c;
            console.log('applicant DOB '+this.applicant.Dob__c);
            this.setIcons(data.Pan_Form60__c);
            this.getDocumentChecklist();
        })
        */
        this.handleAdditionalInformationClick();
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
                 if(this.docChecklist && this.docChecklist.Api_Response__c && this.docVerified){
                    this.showViewResponse = true;
                    this.response = JSON.parse(this.docChecklist.Api_Response__c);
                 }
            }
        })
    }
    showResponse(){
        this.showPANDetails = true;
        this.identifierDocuments = false;
        this.showVerificationOptions = false;
        this.verificationTypePAN = false;
        this.docVerified = false;
    }

    setIcons(pan_Form){
        switch(pan_Form){
            case 'Pan Card':
                this.pan = this.panVerified;
                break;
            case 'Form 60':
                this.form60 = this.form60Verified;
                break;  
            default:
                console.log("pan_Form is --" + pan_Form);
        }
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        if(uploadedFiles.length>0){
            this.isform60uploaded = true;
        }
    }

    selectVerificationType(event) {

        this.verificationType = event.target.dataset.id;
        this.showVerificationOptions = false;
        if (event.target.dataset.id == 'Pan Card') {
            this.verificationTypePAN = true;
            this.docVerified = false;
            this.showAdditional = true;
        } else {
            this.verificationTypeForm60 = true;
            this.showAdditional = true;
            //this.docVerified = true;
        }

    }

    resetVerificationType() {
        this.showVerificationOptions = true;
        this.verificationTypeForm60 = false;
        this.verificationTypePAN = false;
        this.docVerified = false;
        this.showAdditional = false;
    }

    handleValueChange(event) {
        let pan = event.target.value;
        if (pan)
            pan = pan.toUpperCase();

        console.log('Document number modified');
        console.log('pan value: ', pan);
       
        this.docVerified = event.target.name == 'PAN__c' ? false : true;
        this.applicant[event.target.name] = pan;        

    }

    handleAdditionalInformationClick() {
        //console.log('this.isShowAdditionalInformationsPicklist', this.isShowAdditionalInformationsPicklist);
        //this.isShowAdditionalInformationsPicklist = true;
        getDetails({applicantId: this.applicant.Id}).then((data)=>{
            if(data && data.length>0){
                console.log('data '+JSON.stringify(data))
                this.documentChecklist = data;
                data.forEach(element => {
                    if(element.Document_Master__r.Document_Name__c === 'Voter ID Card'){
                        //if(!this.allAdditionalInformationvalues.includes('Voter Id')){
                            //this.allAdditionalInformationvalues.push('Voter Id')
                            this.voterDocumentChecklist = element;
                            console.log('voter card '+JSON.stringify(this.voterDocumentChecklist))
                            this.isEnabledVoterId = true
                            if(element.Document_Verification_Status__c=='Verified'){
                                this.isVoterCardVerified = true;
                            }
                             /*this.applicant.Voter_Id__c = element.Document_Number__c
                                if(element.Document_Verification_Status__c==='Verified'){
                                this.voterIdVerified=true
                            }*/
                            
                        //}
                    }
                    else if(element.Document_Master__r.Document_Name__c === 'Driving Licence'){
                        //if(!this.allAdditionalInformationvalues.includes('Driving Licence')){
                            //this.allAdditionalInformationvalues.push('Driving Licence')
                            
                            this.drivingLicenseDocumentChecklist = element;
                            console.log('dl card '+JSON.stringify(this.drivingLicenseDocumentChecklist))
                            this.isEnabledDrivingLicence = true
                            if(element.Document_Verification_Status__c=='Verified'){
                                this.isDrivingLicenseVerified = true;
                            }
                            
                            /*this.applicant.Driving_License_Id__c = element.Document_Number__c
                            this.applicant.Driving_License_Expiry_Date__c= element.Driving_License_Expiry_Date__c
                                if(element.Document_Verification_Status__c==='Verified'){
                                this.dlVerified=true
                            }*/
                        //}
                    }else if(element.Document_Master__r.Document_Name__c === 'Passport'){
                        //if(!this.allAdditionalInformationvalues.includes('Passport')){
                            //this.allAdditionalInformationvalues.push('Passport')
                            
                            this.passportDocumentChecklist = element;
                            console.log('Passport '+JSON.stringify(this.passportDocumentChecklist))
                            this.isEnabledPassport = true
                            if(element.Document_Verification_Status__c=='Verified'){
                                this.isPassportVerified = true;
                            }
                            /*this.applicant.Passport_Number__c = element.Document_Number__c
                            this.applicant.Passport_File_Number__c=element.Passport_File_Number__c
                            this.applicant.Passport_Expiry_Date__c=element.Passport_Expiry_Date__c
                            /*if(element.Document_Verification_Status__c==='Verified'){
                                this.passportVerified=true
                            }*/
                        //}
                    }
                    else if(element.Document_Master__r.Document_Name__c === 'GST Document') {                           
                            this.gstDocumentChecklist = element;
                            console.log('GST Document  '+JSON.stringify(this.gstDocumentChecklist));
                            this.isEnabledGst = true;
                    }
                    else if(element.Document_Master__r.Document_Name__c === 'CIN Document') {                           
                            this.cinDocumentChecklist = element;
                            this.isEnabledCin = true;
                    }
                    else if(element.Document_Master__r.Document_Name__c === 'Udyam Document') {                           
                            this.udyamDocumentChecklist = element;
                            this.isEnabledUdyam = true;
                    }
                });
            }else{
                this.showError('Info', 'Additional documents are not added to add please visit Applicant Details screen');
            }
            
        })
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('wizardevent', {
            detail: { name: 'EditKYC', mode: 'edit' }
            //detail: { name: 'EditKYC', mode: 'edit',value: this.applicant.Id }
        }));
    }

    handleAdditionalInformationChange(event) {
        if (!this.allAdditionalInformationvalues.includes(event.target.value)) {
            this.allAdditionalInformationvalues.push(event.target.value);
        }
        console.log('this.allAdditionalInformationvalues', JSON.stringify(this.allAdditionalInformationvalues));
        if (event.target.value === 'Voter Id') {
            this.isEnabledVoterId = true;
        }
        else if (event.target.value === 'Driving Licence') {
            this.isEnabledDrivingLicence = true;
        }
        else if (event.target.value === 'Passport') {
            this.isEnabledPassport = true;
        }
    }

    // {'label': 'Driving License', 'apiName': 'Driving_License__c', 'enable': 'isEnableDrivingLicense', }

    handleRemove(event) {
        const valueRemoved = event.target.name;
        console.log('valueRemoved', valueRemoved);
        this.allAdditionalInformationvalues.splice(this.allAdditionalInformationvalues.indexOf(valueRemoved), 1);
        console.log('this.allAdditionalInformationvalues', this.allAdditionalInformationvalues);
        if (valueRemoved === 'Voter Id') {
            this.isEnabledVoterId = false;
        }
        else if (valueRemoved === 'Driving Licence') {
            this.isEnabledDrivingLicence = false;
        }
        else if (valueRemoved === 'Passport') {
            this.isEnabledPassport = false;
        }
    }

    handlePassVerify(event){
        let obj = event.detail;
        console.log('obj is '+JSON.stringify(obj))
        this.isPassportVerified = obj.next;
        //this.isPassportNext = obj.next
    }

    handleVoterVerify(event){
        let obj = event.detail;
        console.log('obj is '+JSON.stringify(obj))
        this.isVoterCardVerified = obj.next;
        //this.isvo = obj.next;
    }

    handleDlVerify(event){
        let obj = event.detail;
        console.log('obj is '+JSON.stringify(obj))
        this.isDrivingLicenseVerified = obj.next;
        //this.isDrivingLicenseNext = obj.next;
    }

    verifyPAN(event) {
        console.log('verify pan');
       
        if (!this.isInputValid('.pan'))
            return;
        
        this.isloading = true;
        this.verificationTypePAN = false;
        this.verificationTypeForm60 = false;
     //   this.applicant.PAN_verification_Status__c = 'Verified';
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
            this.error = undefined;
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
             // this.updatePANDetails();
            }
            else {
                this.showToastMessage("", statusOfPanRespMsg, "error", "sticky");
                this.isloading = false;
            }
            
            var panFullName =  (result.Response.FirstName != null ? result.Response.FirstName : '') + 
                                    (result.Response.MiddleName != null ? result.Response.MiddleName : '') + 
                                    (result.Response.LastName != null ? result.Response.LastName : '');
            //4291 - commented validateNameMatch
            /*validateNameMatch({ strName: panFullName, strType: 'Pan', strApplicantId: this.applicant.Id})
            .then(resultNameMatch => {
                console.log('resultNameMatch-- '+resultNameMatch);
            })
            .catch(error => {
                console.log('error--> '+error.body.message);
                this.isloading = false;
            }) */ 
            
        })
        .catch(error => {
            console.log('error'+error);
            this.isloading = false;
        }) 
    }

    verifyPANDetails() {
        //console.log('I am here');
        if(this.inValidPanDetail){
            this.showToastMessage("", this.invalidPanMessageDetail, "error", "sticky");
            return;
        }
        this.applicant.PAN_verification_Status__c = 'Verified';
        this.applicant.Aadhaar_Seeding__c = this.response.Response.Seeding;
        this.updatePANDetails();
        this.verificationTypePAN = true;
        this.showPANDetails = false;
        this.docVerified = true;
    }

    cancel() {
        this.showPANDetails = false;
        this.verificationTypePAN = true;
        if(this.identifierDocuments == false){
            this.identifierDocuments = true;
            this.docVerified = true;
        }else{
            this.docVerified = false;    
        }
    }

    handleVerify(event) {
        if(event.target.name=='Voter_Id__c'){
            //this.isvoterCardVerified = true;
            if (this.isInputValid('.voterId')){
                this.verifyVoterCard();
            }
            
        }
        if(event.target.name=='Driving_License_Id__c'){
            if (this.isInputValid('.drivingLicense')){
            this.verifyDrivingLicense();
            }
        }
        if(event.target.name=='Passport_Number__c'){
            if (this.isInputValid('.passportNum')){
            this.verifyPassportNumber();
            }
        }
        
    }

    updateDocumentetails(status,docName) {
        this.isloading = true;
        updateDocumentChecklist({ app: this.applicant,documentName:docName,verificationStatus:status })
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
           // this.updateResponseOnDocument();
         })
         .catch(error => {
            this.error = error;
            console.log('error', error);
         })
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
                count++;
            }
        };
        console.log('isValid', isValid);
        console.log('count', count);

        return (isValid == false) ? false : count;
    }

    showPopup() {
        
        this.showPANDetails = true;
        this.showVerificationOptions = false;
    }

    showDetails(event) {
        console.log('Show user details');
        this.verificationTypePAN = true;
        this.showPANDetails = false;
        this.showVerificationOptions = false;
        this.docVerified = true;
    }

    /* checkDate(event){
         let selectedDate = event.target.value;
         if(selectedDate < this.today){
             inputCmp.setCustomValidity("Select correct date range1");
         }
     }*/

    @api
    async nextHandler() {
         // START SFAU-4077
         const verifiedData = await getDetails({applicantId: this.applicant.Id});
         verifiedData.forEach(element => {
         if(element.Document_Master__r.Document_Name__c === 'Voter ID Card'){
         this.isEnabledVoterId = true
         if(element.Document_Verification_Status__c=='Verified' || element.Retry_Count__c >= 3 ){ // Retry Logic || START || 20 SEP || ASHISH
                 this.isVoterCardVerified = true;
                 this.voterIdVerified = true;
              
             }
             
         }
         else if(element.Document_Master__r.Document_Name__c === 'Driving Licence'){
         this.isEnabledDrivingLicence = true
         if(element.Document_Verification_Status__c=='Verified'  || element.Retry_Count__c >= 3 ){ // Retry Logic || START || 20 SEP || ASHISH
                 this.isDrivingLicenseVerified = true;
                 this.dlVerified = true;
                
             }
             
         }else if(element.Document_Master__r.Document_Name__c === 'Passport'){
         this.isEnabledPassport = true
          if(element.Document_Verification_Status__c=='Verified'  || element.Retry_Count__c >= 3 ){ // Retry Logic || START || 20 SEP || ASHISH
                 this.isPassportVerified = true;
                this.passportVerified = true;
                 
             }
         }
     
         });
         //END SFAU-4077

        if(this.inValidPanDetail){
            this.showToastMessage("", this.invalidPanMessageDetail, "error", "sticky");
            return;
        }
        console.log('applicant: ', JSON.stringify(this.applicant));

            if(this.applicant.Customer_Type__c=='Individual' && ( this.applicant.KYC_Status__c!= 'Complete'  || this.applicant.KYC_Type__c == null) && (!this.passportVerified && !this.voterIdVerified && !this.dlVerified && !this.applicant.NPR__c && !this.applicant.NREGA__c)){
            this.showError('Info', kycNotVerifiedErrorMessage);//SFAU-1979
           // this.showError('Info', 'Please verify at least three times to proceed further');//updating the error message || START || 20 SEP || ASHISH
            return;
        } 
        

        this.applicant.Pan_Form60__c== this.verificationTypeForm60 ? 'Form 60' : this.applicant.Pan_Form60__c;
        console.log('applicant in next handler '+JSON.stringify(this.applicant));
        let flag = false;
        if(this.response && (this.response.Response.FirstName && (!this.response.Response.LastName))){
            flag = true;
        }
        let nonexistingCust = true;
        if(this.applicant.Existing_Customer__c && this.applicant.Existing_Customer__c == 'Yes'){
            nonexistingCust = false;
        }
        console.log('docChecklist--- '+JSON.stringify(this.docChecklist));
        // Commenting below logic for 2 kys docs in case of single name -- (Kunal) [SFAU-4247]
     /*   if(nonexistingCust && this.applicant.Customer_Type__c=='Individual' && ((this.applicant.First_Name__c && !this.applicant.Last_Name__c) || flag )) {
            let fldsToCheck = ["Aadhaar_Number__c", "Voter_Id__c", "Driving_License_Id__c", "Passport_Number__c"];
            let counterCheck = 0;
            for (let i = 0; i < fldsToCheck.length; i++) {
                let value = this.applicant[fldsToCheck[i]];
                if (value) {
                    counterCheck++;
                }
            }
            if(counterCheck<2){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please fill atleast 2 KYC details',
                        variant: 'error',
                    }),
                );
                return;
            }
        } */
       // const validDocs = this.isInputValid('.validate');
        console.log('status:',this.applicant.PAN_verification_Status__c);
        console.log('mandatory: ', this.mandatoryDocCount);
        console.log('Applicant details '+this.applicantRecord);
        console.log('Applicant  '+JSON.stringify(this.applicant));
        //Below lines added as per Bug-2515
        if(!this.applicant.Aadhaar_Number__c && !this.applicant.Voter_Id__c && !this.applicant.Driving_License_Id__c
            && !this.applicant.Passport_Number__c){
                if(this.applicant.NPR__c){
                    console.log('in npr');
                    //this.applicant['KYC_Status__c'] = 'Complete';
                    //this.applicant['KYC_Type__c'] = 'NPR';
                    this.updateStatus('NPR');
                }
                else if(this.applicant.NREGA__c){
                    console.log('in nrega');
                    //this.applicant['KYC_Status__c'] = 'Complete';
                    //this.applicant['KYC_Type__c'] = 'NREGA';
                    this.updateStatus('NREGA');
                }
        }
        /*if(this.isInputValid('.pan'))
            this.returnToParent();*/

    
        // First, check if Form60 - proceed even if not uploaded (can be uploaded till PSD)
        // If PAN - PAN Verification Status - Verified : Individual, Non-Individual
            //Single Name: Applicant Last name is blank - upload one more document to proceed
            //Individual - VoterID, DL, Passport
            //Non-Individual - GST, Udyam, CIN


        //&& this.isform60uploaded
        /*if(!this.isform60uploaded){
            this.showToastEvent('', 'Form 60 document is required!', 'error');
            return;
        }*/

        if(this.verificationTypeForm60 || (this.applicant && this.applicant.Pan_Form60__c=='Form 60')){
            this.returnToParent();
            return;
        }
        
        if(this.applicant.PAN_verification_Status__c == 'Verified' || !this.applicant.PAN__c ){
            if(this.applicant.Customer_Type__c == 'Non Individual'){
                //Udyam,GST,CIN validations
                this.returnToParent();
            }else{
                 

                //VoterID, DL,Passport validations
                if(this.isEnabledVoterId || this.isEnabledDrivingLicence || this.isEnabledPassport){
                    let allVerified = false;
                    let documentName ='';
                    if(this.isEnabledVoterId){
                        if(this.isVoterCardVerified){
                            allVerified = true;
                        }else{
                            documentName = 'Voter Card';
                        }
                    }

                    if(this.isEnabledDrivingLicence){
                        if(this.isDrivingLicenseVerified){
                            allVerified = true;
                        }else{
                            allVerified = false;
                            documentName = documentName+ ' DL ';
                        }
                    }

                    if(this.isEnabledPassport){
                        if(this.isPassportVerified){
                            allVerified = true;
                        }else{
                            allVerified = false;
                            documentName = documentName + ' Passport ';
                        }
                    }

                    if(allVerified){
                        this.returnToParent();
                    }else{
                        //this.showError('Info', 'Please complete ' +documentName+' verification before proceeding ahead');
                        this.showError('Info', 'Please verify ' +documentName+' at least three times before proceeding ahead'); // Retry Logic || START || 20 SEP || ASHISH
                    }
                    
                }else{
                    this.returnToParent();
                }
                
            }
        }else{
            this.showError('Info', kycNotVerifiedErrorMessage);//SFAU-1979
        } 

      /*  if(this.isVoterCardNext && this.isDrivingLicenseNext && this.isPassportNext){
            if (this.applicant.PAN_verification_Status__c == 'Verified'){// && (this.mandatoryDocCount == 1 ||  this.mandatoryDocCount == 2 && (this.passportVerified || this.voterIdVerified || this.dlVerified))) {
                this.returnToParent();
            }else {
               //  this.showError('Info', 'Please complete verification before proceeding ahead');
             }
           /* else if (this.mandatoryDocCount == 2) {
                this.showError('Info', 'Please add atleast 2 documents for Customers with Single Name');
            } else {
               // this.showError('Info', 'Please complete verification before proceeding ahead');
            }*/
       /* }else{
            if(!this.isVoterCardNext){
                this.showError('Info', 'Please try to validate voter id again');
            }

            if(!this.isDrivingLicenseNext){
                this.showError('Info', 'Please try to validate driving license again');
            }

            if(!this.isPassportNext){
                this.showError('Info', 'Please try to validate passport number again');
            }
        }
        */

        /*  if (!this.isInputValid('.pan'))
              return;
  
              let validDocs = this.isInputValid('.validate');
  
              //Single name validation
              if( validDocs && validDocs >= this.mandatoryDocCount )
                  this.returnToParent();*/
    }

    returnToParent() {
        console.log('returning to parent', JSON.stringify(this.applicant));
        let returnObj = {
            'next': true,
            'applicantRecord': this.applicant,
            'error': '',
            isPanMandatory: true
        }

        console.log('return: ', returnObj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: returnObj
        }));
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

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }


    okClick() {
        this.updateRecords(true);
    }


    downloadurl;
    setDownloadURL(docId){
        this.downloadurl='/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + docId;
    }
    handleSuccessUpload(event) {
        if (event.detail.isSuccess && event.detail.showOCRInParent) {
            console.log('Inside Final Success!!!!');
            this.dataValues = event.detail.ocrData;
            this.applicant = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
            this.isform60uploaded = true;
            this.showToastEvent('Success', 'Form 60 Uploaded Successfully', 'success');
        } else if (event.detail.isSuccess && event.detail.showGreenTick) {
       //     this.getVersionFiles();
            this.showUploadComponent = false;
            this.isform60uploaded = true;
            this.contentVersionId = event.detail.versionId;
            this.setDownloadURL(this.contentVersionId);
            this.applicant.Pan_Form60__c = 'Form 60';
            this.showToastEvent('Success', 'Form 60 Uploaded Successfully', 'success');
        } else if (event.detail.isSuccess) {
            this.isform60uploaded = true;
            this.applicant.Pan_Form60__c = 'Form 60';
            this.showToastEvent('Success', 'Form 60 Uploaded Successfully', 'success');
            console.log('losAddIndNonIndClone NO OCR & Success');
            this.contentVersionId = event.detail.versionId;
            this.setDownloadURL(this.contentVersionId);
       //     this.getVersionFiles();
            this.showUploadComponent = false;
        } else {
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
            //this.showUploadComponent = false;
        }
    }

    updateRecords(isOkBoolean) {
        this.isloading = true;
        this.disableOkButton = true;
        console.log('Before ... ' + JSON.stringify(this.applicant));
        //this.applicant['KYC_Status__c'] = 'Complete';
        let obj = JSON.parse(this.applicant);
        console.log('After ... 1 ');
        console.log('After ... 2 ' );
        console.log('After ... 3 ');
        
        updateOCRDate({ applicantRec: this.applicant, documentChkRecord: this.documentChkRecord, isAadhar: this.isAadhar, isOk: isOkBoolean, contentVersionId: this.contentVersionId })
            .then(result => {
                this.isloading = false;
                let parseResult = JSON.parse(result);
                if (parseResult.isSuccess) {
                    console.log(' this.documentNumber ' + this.documentNumber + '  ' + JSON.stringify(this.documentNumber));
                    this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
                    this.showUploadComponent = false;
                    obj['KYC_Status__c'] = 'Complete';
                    //const resultEvent = { isSuccess: true };
                    if (this.eventdocName == DocumentPan) {
                        //this.applicant.PAN__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentVoter) {
                        //this.applicant.Voter_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentAadhaar) {
                        obj['Aadhaar_Number__c'] = this.documentNumber;
                        obj['KYC_Status__c'] = 'Complete';
                        //this.applicant.Aadhaar_Number__c = this.documentNumber;
                        if (this.documentNumber != this.oldAadhaarValue) {
                            //this.generateAadhaarToken(this.documentNumber);
                        }
                    } else if (this.eventdocName == DocumentDL) {
                        //this.applicant.Driving_License_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentPassport) {
                        //this.applicant.Passport_Number__c = this.documentNumber;
                    }
                    console.log('object update ' + JSON.stringify(obj));
                    this.applicant = obj;
                    console.log('this.applicant update ' + JSON.stringify(this.applicant));

                    const documentHandlerEvent = new CustomEvent('updateapplicant', {
                        detail: {
                            'applicant': this.applicant
                        }
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                    setTimeout(() => {
                        this.getVersionFiles();
                    }, 1000);
                } else {
                    this.showToastEvent('Error', 'We Encountered an Error while updating details!!', 'error');
                    this.showUploadComponent = false;
                    const resultEvent = { isSuccess: false };
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail: resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                }
            })
            .catch(error => {
                this.disableOkButton = false;
                this.isloading = false;
                this.error = error;
                console.log('error', error);
                alert('Error ' + JSON.stringify(error));
                this.showUploadComponent = false;
            })
    }

    showToastEvent(titleValue, messageValue, variantValue) {
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    updateStatus(type){
        updateStatus({
            applicantId : this.applicant.Id,
            type: type
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));

        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    handlePreviewClick(event) {
        let dataValue = event.target.dataset.id
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: dataValue
            }
        })
    }

    handleClickDelete(event){
        let id = event.currentTarget.name;
        console.log('ContentVersionid'+id);
        deactivateDocument({ recordId : id})
        .then((result) => {
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess ){
            this.isform60uploaded = false;
            this.contentVersionId = undefined;
            this.showToastEvent('Success', 'File Deleted Successfully', 'success');
            }else{
                this.showToastEvent('Error','Something went wrong!', 'error');
            }
        }
        )
        .catch(error => {
            this.error = error;
            this.isloading = false;
        });
    }

    getVersionFiles(){
        getVersionFilesByChecklist({
            recordId: this.applicant.Id
        }).then((result) => {
            if(result && result.length > 0){
                this.contentVersionId = result[0].contentVerId;
                this.setDownloadURL();
            }
        }).catch(error => {
            this.error = error;
            this.isloading = false;
        });
    }
}