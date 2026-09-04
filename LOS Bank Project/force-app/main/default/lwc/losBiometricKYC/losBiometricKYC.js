import { LightningElement, api,track } from 'lwc';
import updateRecords from '@salesforce/apex/LOSBiometricKycController.updateRecords';
import { NavigationMixin } from "lightning/navigation";
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BiometricDesktopMessage from '@salesforce/label/c.BiometricDesktopMessage';
import getApplicantDetails from'@salesforce/apex/LOSBiometricKycController.getApplicantDetails';

export default class LosBiometricKYC extends NavigationMixin(LightningElement) {
    @api spinnerImage;
    @api applicant = {};
    @api isVerified;
    @api kyc;
    responseData;
    aadharResponse = {
        'UID': '874983094', //Not storing
        'DOB': '28-02-1995', //Applicant
        'Name': 'Shanaya Kapoor',
        'Gender': 'Female',
        'Care of': 'D/O Anil Kapoor', //D/O - Father's name else W/O- Spouse name
        'Country': 'India', //Country
        'District': 'EAST DELHI', //City
        'Address': 'Chintamani Nagar Waad - 6', //Address line 1
        'Pincode': '110053', 
        'State': 'DELHI',
        'Village Town City': 'NA', //Taluka
    };
    disableButton = true;
    disableOkButton = false;
    isMobile = false;

    consent;
    address;
    isloading= true;
    showBIOMETRICKYC = true;
    showAadhaarDetails = false;

    connectedCallback(){
        this.isloading= false;
        console.log('applicant', JSON.stringify(this.applicant));
        if(this.applicant.KYC_Status__c == 'Complete'){
            this.consent = true;
            this.isVerified = true;
        }
        if(FORM_FACTOR=='Small'){
            this.isMobile = true;
        }else{
            this.showError('Info', BiometricDesktopMessage);
            this.isMobile = false;
        }

    }
    renderedCallback() {
        if(!this.isMobile && this.template.querySelector('[data-id="errorMessage"]')){
            this.template.querySelector('[data-id="errorMessage"]').setError(BiometricDesktopMessage);
            this.template.querySelector('[data-id="errorMessage"]').classList.remove('slds-hide');
        }
    }
    showKYCOptions(){
        console.log('Back to KYC Subtype option selection');
        this.dispatchEvent(new CustomEvent('subkycselection'));
    }
    @api
    updateRecords(){
        this.isloading= true;
        let records = this.populateData();
        console.log('applicant id: ', JSON.stringify(this.applicant));
        this.applicant = {...this.applicant, ...records.applicantRecord};
        this.address = records.address;
        console.log('applicant id: ', JSON.stringify(this.applicant));
        console.log('address: ', JSON.stringify(this.address));
        //update record on controller
        let dobVal = this.responseData.dob ? this.responseData.dob.toString().replaceAll('-','/') : undefined;
        updateRecords({ applicant: JSON.stringify(this.applicant), address: JSON.stringify(this.address),dob: dobVal })
            .then(result => {
                this.isloading= false;
                console.log('result - aadhar update: ', result);
                this.showError('success', 'Aadhaar details updated sucessfully');
                this.disableOkButton = true;
                this.applicant.KYC_Status__c ='Complete';
                this.applicant.KYC_Type__c = this.kyc;
                this.updateParent();
            })
            .catch(error => {
                this.isloading= false;
                this.error = error;
                console.log('error', error);
            })

    }   

    //'Dob__c': '28-02-1995', //Applicant

    updateParent(){
        console.log('Updating Parent');
        this.dispatchEvent(new CustomEvent('updateapplicant', {
            detail: {
                'applicant': this.applicant
            }
        }));
    }

    populateData(){
        let gender = ''
        if(this.responseData.gender == 'M'){
            gender= 'Male'
        }else if(this.responseData.gender == 'F'){
            gender= 'Female'
        }else if(this.responseData.gender == 'T'){
            gender= 'Transgender'
        }
        let fName;
        let mName;
        let lName;
        let fatherName = this.responseData && this.responseData.co ? this.responseData.co.replace('C/O: ','') : this.responseData.co;
        let obj = this.responseData.name?.split(' ');
       //SFAU-5247 Start
        if(obj && obj.length > 0){
            fName = obj[0];
        }
        if(obj && obj.length == 2){
            fName = obj[0];
            lName = obj[1];
        }else if(obj && obj.length > 2){
            mName = obj[1];
            obj.splice(0,1);
            obj.splice(0,1);
            lName = obj.join(' ');
        }
        //SFAU-5247 End
        return { applicantRecord: {
            'First_Name__c': fName,
            'Middle_Name__c': mName,
           // 'Dob__c': dobVal,
            'Last_Name__c':lName,
            'Aadhaar_Name__c' : this.responseData.name,
            'Gender__c': gender,
            'Father_Name__c': fatherName ,  //D/O - Father's name else W/O- Spouse name
            'KYC_Type__c': this.kyc,
            'KYC_Status__c': 'Complete',
            'KYC_Completion_Time__c': new Date()
        },
        address: {
            'District__c': this.responseData.dist, //City
            'City__c': this.responseData.dist,
            'Address_Line_1__c': this.responseData.house,
            'Address_Line_2__c': this.responseData.vtc, //Address line 1 // Updating from Street to vtc
            'Pincode__c': this.responseData.pc, 
            'State__c': this.responseData.state,
            'Taluka__c': this.responseData.loc, //'NA', //Taluka
            'Applicant__c': this.applicant.Id,
            'Address_Type__c':'Permanent',
            'Address_Line_3__c':this.responseData.hasOwnProperty('lm')?this.responseData.lm:''
        }
    }
    }

    showDetails(event) {
        console.log('Show user details');
        this.showBIOMETRICKYC = !this.showBIOMETRICKYC;
        this.showAadhaarDetails = !this.showAadhaarDetails;
    }

    updateConsent(event){
        this.consent = event.detail.consent;
        if(this.consent){
            this.disableButton = false;
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url : "aubridge://biometric/" + this.applicant.Id
                },
            });
        }else{
            this.disableButton = true;
        }
        console.log('this.applicant.Id@@@@@'+this.applicant.Id);
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
    @track dataValues = [];
    getApplicantDetails(event){
        this.isloading= true;
		getApplicantDetails({ recordId: this.applicant.Id })
		.then(result => {
            console.log('RESULT###'+result);
            console.log('RESULT###JSON'+JSON.parse(result));
            let finalValue = JSON.parse(result);
            this.responseData = finalValue;
            if(finalValue.status =='SUCCESS'){
                let details = finalValue.co;
                let address = '' ;
                if(finalValue.loc){
                    address = finalValue.house+ ' '+  finalValue.street+' '+finalValue.loc;
                }else{
                    address = finalValue.house+ ' '+  finalValue.street;
                }
                this.aadharResponse = {
                    'UID': finalValue.uid, //Not storing
                    'DOB': finalValue.dob, //Applicant
                    'Name': finalValue.name,
                    'Gender': finalValue.gender,
                    'Care of': finalValue.co, //D/O - Father's name else W/O- Spouse name
                    'Country': finalValue.country, //Country
                    'District': finalValue.dist, //City
                    'Address': address, //Address line 1
                    'Address Line 2': finalValue.vtc,
                    'Address Line 3': finalValue.lm,
                    'Pincode': finalValue.pc, 
                    'State': finalValue.state,
                    'Village Town City': finalValue.vtc //Taluka
                };
                for (var key in this.aadharResponse) {
                    this.dataValues.push({ value: this.aadharResponse[key], label: key, fieldName: key, show: true }); 
                }
                this.showBIOMETRICKYC = !this.showBIOMETRICKYC;
                this.showAadhaarDetails = !this.showAadhaarDetails;
            }else if(finalValue.status =='FAIL'){
                this.showError('Warning', finalValue.message);
            }
            this.isloading= false;
            
		})
		.catch(error => {
            console.log('INSIDE ERROR ');
            this.isloading= false;
		})
	}
    backToBio(){
        this.showBIOMETRICKYC = !this.showBIOMETRICKYC;
        this.showAadhaarDetails = !this.showAadhaarDetails;
    }
}