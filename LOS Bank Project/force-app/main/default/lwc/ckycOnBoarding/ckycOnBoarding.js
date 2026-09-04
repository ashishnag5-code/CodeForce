import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCkycOptions from '@salesforce/apex/CkycOnBoardingController.getCkycOptions';
import searchCkycResult from '@salesforce/apex/CkycOnBoardingController.searchCkycResult';
import updatAndCallDownApi from '@salesforce/apex/CkycOnBoardingController.updatAndCallDownApi';
import getApplicant from '@salesforce/apex/CkycOnBoardingController.getApplicant';

export default class CkycOnBoarding extends LightningElement {

    @api applicant;
    @api recordId;
    @api spinnerImage;

    @track ckycOptions = [];
    @track ckyc        = {};
    @track ckycSearchResultData;
    @track searchCkycData;

    dispType             = '';
    isShowCkycDetails    = false;
    isloading            = false;
    isShowInp;
    isVerified           = false;
    isSearchbutton       = true;
    isDisableDob         = false;
    docMasterName;
    showBottomIcons;
    dob;
    maxDate;//SFAU-2872

    applcntId = "";

    applcntFldMap = {
        "full_name": "Customer_Name__c",
        "father_name": "Father_Name__c",
        "DOB": "Dob__c",
        "Gender": "Gender__c",
        "age": "Age__c",
        "ckyc_number" : ""
    };

    connectedCallback() {
        this.applcntId = this.applicant.Id;  // this.applicant.Id;
        this.populateCkycOptions();
        this.getKycStatus();
        this.getToday(); //SFAU-2872
    }
    getToday() {
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
    }

    populateCkycOptions() {
        getCkycOptions({ applcntId: this.applcntId })
            .then((result) => {
                console.log("ckyc options-- "+JSON.stringify(result));
                this.ckycOptions = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.ckycOptions = undefined;
            });
    }

    getKycStatus() {
        getApplicant({ applcntId: this.applcntId })
            .then((result) => {
                console.log("result--:" + JSON.stringify(result));
                let kycStatus = result[0].KYC_Status__c;
                let dob = result.Dob__c;
                if(kycStatus == "Complete") {
                    this.showIcon();
                    this.isShowInp = true;
                    this.isDisableDob = true;
                    this.dob = dob;
                }
                this.customerType = result[0].Customer_Type__c;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    setDobOrDoe() {
        let customerTyp = this.customerType;
        let getligthtningInp = this.template.querySelector('[data-id="dobOrDoe"]');
        if(getligthtningInp && customerTyp == "Individual") {
            getligthtningInp.label = "Date of Birth";
        }
        else if(getligthtningInp && customerTyp == "Non Individual") {
            getligthtningInp.label = "Date of Establishment";
        }
    }

    renderedCallback() {
        this.setDobOrDoe();
    }

    showIcon() {
        this.isVerified = true;
        this.isSearchbutton = true;
    }

    handleCkycOptionsChange(event) {
        let value  = event.detail.value;
        let fltrOptions = this.fltrCkycOptions(value);
        this.ckyc       = fltrOptions[0];
        this.docMasterName = this.ckyc.docMasterName;
        if(value) {
            this.isShowInp = true;
            this.isSearchbutton = false;
            this.isVerified = false;    
        }
    }

    fltrCkycOptions(value) {
        let fltrResult = this.ckycOptions.filter(opt => opt.value == value);
        return fltrResult;
    }

    searchCkyc() {
        if(this.isInputValid()) {
            this.search();
        }
    }

    search() {
        this.isloading = true;  // isInputValid
        const searchCategoryObj = {};
        searchCkycResult({ applcntId: this.applcntId, searchValue : this.ckyc.docNumber, searchCategory : this.ckyc.searchCategory, docMasterName :  this.docMasterName, dob : this.dob })
            .then((result) => {
                console.log("searchCkycResult-- "+JSON.stringify(result));
                this.searchCkycData     = result
                let message = result.Response.message;
                this.showCkycData(message, result);
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log("Error inside searchCkycResult-- "+error);
                this.isloading = false;
            });
    }

    showCkycData(message, res) {
        this.isloading = false;
        let errCd = res.error_cd;
        if(message == "No record found") {
            this.showMessage("", message, "info", "dismissible");
        }
        else if(message == "Success"){
            this.ckycSearchResultData = res;
            this.isShowCkycDetails    = true;
            this.showBottomIcons      = true;
            this.dispType             = 'CKYC Details'; 
        }
        else if(errCd != 101 && message != "Success") {
            this.showMessage("", message, "error", "sticky");
        }
    }

    handleValueChange(event) {
        let fldName = event.target.name;
        let fldValue = event.detail.value;
        let formattedDate = this.formatDate(fldValue);
        if(fldName == 'dob') {
            this.dob = formattedDate;
            this.dobOnUi = fldValue;
        }     
    }

    // convert date from yyyy-mm-dd to dd-mm-yyyy
    formatDate(input) {
        var datePart = input.match(/\d+/g),
        year = datePart[0], 
        month = datePart[1], 
        day = datePart[2];
      
        return day+'-'+month+'-'+year;
      }

    showDetails() {
        this.isShowCkycDetails = false;
        this.isShowInp = true;      
    }

    showKYCOptions(){
        this.dispatchEvent(new CustomEvent('subkycselection'));
    }

    isInputValid() {
        let isValid = true;
        console.log("isShowInp-- "+this.isShowInp);
        let inputFields = this.template.querySelectorAll(".validate");
        for(let inputField of inputFields)  {
            if(!inputField.checkValidity()) { 
                inputField.reportValidity();
                isValid = false;
            }
        }      
        //START SFAU-2872
        const selectedDate = new Date(this.dobOnUi);
        const currentDate = new Date();
       // currentDate.setHours(0, 0, 0, 0);

        if (selectedDate > currentDate) {
            console.log('futureDate');
            isValid = false;
        } 
        //END

        return isValid;
    }

    handleSaveAfterCkycSearch() {
        let applcntData = {};
        let docNum;
        let ckycData    = this.searchCkycData.Response.ckyc_data[0];

        for(let key in this.applcntFldMap) {
            applcntData[this.applcntFldMap[key]] = ckycData[key];
            if(key == "ckyc_number") {
                docNum = ckycData[key];
            }
        }
        applcntData.Id = this.applcntId;
        this.updateAndCallDownApi(applcntData, docNum);
        this.isloading = true;
    }

    updateAndCallDownApi(applcntData, docNum) {
        let applData = {...applcntData};

        updatAndCallDownApi({ applData: applData, docNum : docNum, docMasterName :  this.docMasterName, dob : this.dob})
        .then((result) => {
            console.log("updatAndCallDownApi-- "+JSON.stringify(result));
            if(result == "Not Found.") {
                this.showMessage("", result, "info", "dismissable");
            }
            else if(result == "Verified") {
                this.showIcon();
                this.isDisableDob = true;
            }
            const selectEvent = new CustomEvent('checkvalidationfromkyccomp');
            this.dispatchEvent(selectEvent);

            this.showDetails(); 
            this.isloading = false;
            this.error = undefined;
        })
        .catch((error) => {
            this.isloading = false;
            this.error = error;
            console.log("Error inside updatAndCallDownApi-- "+JSON.stringify(error));
            this.showMessage("", error.body.message, "error", "sticky");
            this.isloading = false;
        });
    }

    showMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    @api nextHandler() {       
        
         let Obj = {};
         Obj.next = true;
         this.errorOnChild = '';
         Obj.errorOnChild = this.errorOnChild;
         console.log('Obj', Obj);
         this.dispatchEvent(new CustomEvent('next', {
             detail: Obj
         }));
     }
}