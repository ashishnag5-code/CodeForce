import { LightningElement,api,wire } from 'lwc';
//import { loadStyle } from 'lightning/platformResourceLoader';
//import LightningCardCSS from '@salesforce/resourceUrl/LightningCard';
//import getDogPicture from '@salesforce/apex/LeadDedupeController.getDogPictures';
export default class DogApi extends LightningElement() {
   imageResponse ;
   error;
    selectedCountryCountryCodeLength=3;
    boolCheckMobileNumber=true;
    enterOTPValue =''
    currentStep = '1';
    loanAmount ;
    sourceName ;
    indvidualCustomer = false;
    sourcingChannelOptionsValue = '';
    productOptionsValue = '';
    customerTypeOptionsValue = '';
    pancardForm16OptionsValue = '';
    stageOptionsValue = '';
    categoryValue = '';
    categoryChecks = false;
    isEnterOtp = false;
    loanApplicationRecord = {};
    isEnabledPanCard = false;
   
    boolResendButton = false;
    boolRequestOtp = false;
    boolSendOtp = true;
     currentPage = 0;
    totalPage = 3;

    isQuickLoanVisible=true;
    isAddIndOrNoIndVisible=false;

  /*
   renderedCallback() {
        
    Promise.all([
        loadStyle( this, LightningCardCSS )
        ]).then(() => {
            console.log('Files loaded');
        })
        .catch(error => {
            console.log( error.body.message );
    });

}*/
 /* connectedCallback() {
    getDogPicture()
    .then(result => {
        console.log('result---'+result);
        let response = JSON.parse(result);
        this.imageResponse = response.message;
        console.log('response---'+this.imageResponse);
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: this.imageResponse
          });
      
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
    })
    .catch(error => {
        this.error = error;
    });
    
    // Creates the event with the data.
   
  }*/
   /*  imageReady = false;
    loadingSpinner = false;
    pictureUrl;

  @wire(getDogPicture) wiredDogPicture({error,data}){
        this.loadingSpinner = true;
        this.imageReady = false;
        if(data){
            const custEvent = new CustomEvent(
                'callpasstoparent', {
                    detail: event.target.value 
                });
            this.dispatchEvent(custEvent);
            this.pictureUrl = JSON.parse(data).message;
            this.imageReady = true;
            this.loadingSpinner = false;
        }
    } */
    createLead() {

        if (this.isInputValid() && this.isVerified) {
            console.log('in create method');
        this.isloading = true;
        //if(!this.stageOptionsValue){
            this.loanApplicationRecord['Stage__c'] ='QDE';
        //}
        
        const fields = this.loanApplicationRecord;
        const recordInput = { apiName: LOANAPPLICATION_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                console.log('account '+JSON.stringify(account));
                this.handleResetAll();
                this.isloading = false;
                this.isVerified = false;
                this.isVerifiedNumber = false;
                this.oldMobileNumberValue = '';
                this.loanApplicationId = account.id;
                this.isQuickLoanVisible = false;
                this.isAddIndOrNoIndVisible = true;
                console('isQuickLoanVisible',this.isQuickLoanVisible);
                console('isAddIndOrNoIndVisible',this.isAddIndOrNoIndVisible);


                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Loan Application created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {

                this.isloading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });

        } else {
            if(!this.isVerified){
                if(this.boolCheckMobileNumber){
                    let inputField = this.template.querySelector(".mobileButton");
                    inputField.checkValidity();
                }
            }
        }
    }
   
    get disablePrevious(){ 
        return this.currentPage <= 0;
    }

    get disableNext(){ 
        return this.currentPage >= this.totalPage-1;
    }

    previousHandler(){ 
        if(this.currentPage>0){
            this.currentPage = this.currentPage-1;
            this.updateRecords();
        }
    }

    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            console.log('current page is: '+this.currentPage);
            this.updateRecords()
        }
    }

}