import { LightningElement,api } from 'lwc';
import getLoanApplicationDetails from '@salesforce/apex/AUSFVehicleController.getLoanApplicationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import getValuationRecord from '@salesforce/apex/AUSFValuationController.getValuationRecord';
export default class AusfVehicleParent extends LightningElement {
    @api recordId;
    @api state;
    @api spinnerImage;
    loanAppicationData;
    account;
    isUsedScreen = false;
    isNewScreen = false;
    isLoading = false;
    isFourWheeler = false;
    isTwoWheeler = false;
    isTractor = false;
    isCommercial = false;
    isLoanDetailsOpen = false;

    connectedCallback(){
        this.getLoanApplicationDetails()
       

    }

    getLoanApplicationDetails(){
        this.isLoading = true;
        getLoanApplicationDetails({loanAppId:this.recordId })
		.then(data => {
                if(data){
                    console.log('data parant '+JSON.stringify(data))
                    this.loanAppicationData = data.loanApp;
                    this.isUsedScreen =data.screenType.isUsed;
                    this.account = data.loanApp.Branch_Master__r;
                    this.isNewScreen =data.screenType.isNew;
                    this.isFourWheeler = data.typeOfWheeler.isFourWheeler;
                    this.isTwoWheeler = data.typeOfWheeler.isTwoWheeler;
                    this.isTractor = data.typeOfWheeler.isTractor;
                    this.isCommercial = data.typeOfWheeler.isCommercialVehicle;
                } 
                this.isLoading = false;
		})
		.catch(error => {
            console.log('error paraent is '+JSON.stringify(error));
            this.isLoading = false;
            this.loanAppicationData='';
		})
    }
    
    loadValuationDetails(){
         //Added by Ashish for SFAU 2854
         return new Promise((resolve, reject) => {
            let response = false;
            getValuationRecord({ loanId: this.recordId })
            .then(data => {
               console.log('data-->' +JSON.stringify(data));
                if (data == true) {
                    response = true;
                    
                }/*else{
                    let messaage = 'Please Click the Valuation Button and Submit For Valuation'
                    this.showToast(messaage, 'error');
                }*/
                this.isLoaded = false;
                resolve(response);
            })
            .catch(error => {
                this.isLoaded = false;
                //reject('');
                this.showToast(JSON.stringify(error), 'error');
            });
        })
        //End
    }
    
    handleSave(event){
        const obj = event.detail;
        console.log('obj is '+JSON.stringify(obj))
        this.applicantLst = obj.applicantLst;

    }

    @api async nextHandler() {
        //Added by Ashish for SFAU 2854
      if(this.isUsedScreen == true){
          if(this.isLoanDetailsOpen){
              this.errorOnChild = 'You\'re required to update loan amount before proceeding ahead';
          }
          
          if(!this.isLoanDetailsOpen) {
              let response = await this.loadValuationDetails();
              console.log('response-->' +response);
              let vehicleRecord = this.applicantLst;
              console.log('vehicleRecord.length-->' +vehicleRecord?.length);
              if(vehicleRecord== null || vehicleRecord.length==0){
                  this.errorOnChild =  'Please create vehicle record';
              }else if(response == false){
                  this.errorOnChild =  'Please Click the Valuation Button and Submit For Valuation';
              } else{
                this.errorOnChild =  vehicleRecord.length > 0 ? this.allowNext( vehicleRecord ) ? '' : 'Please fill mandatory collateral details' : 'Please create vehicle record';
              }
          }

          const Obj = {};
          Obj.errorOnChild = this.errorOnChild;
          Obj.next = this.errorOnChild === '' ? true : false;
          if(Obj.next===false){
              this.showToast(this.errorOnChild,'error');
          }
          console.log('Obj', Obj);
          this.dispatchEvent(new CustomEvent('next', {
              detail: Obj
          }));
          //}
      }else{   //END
          if(this.isLoanDetailsOpen){
              this.errorOnChild = 'You\'re required to update loan amount before proceeding ahead';
          } else {
              let vehicleRecord = this.applicantLst;
              if(vehicleRecord== null){
                  this.errorOnChild =  'Please create vehicle record';
              }else{
                this.errorOnChild =  vehicleRecord.length > 0 ? this.allowNext( vehicleRecord ) ? '' : 'Please fill mandatory collateral details' : 'Please create vehicle record';
              }
          }
          const Obj = {};
          //this.errorOnChild = '';
          //Obj.applicantRecord = this.applicantIdInput;
          Obj.errorOnChild = this.errorOnChild;
          Obj.next = this.errorOnChild === '' ? true : false;
          if(Obj.next===false){
              this.showToast(this.errorOnChild,'error');
          }
          console.log('Obj', Obj);
          this.dispatchEvent(new CustomEvent('next', {
              detail: Obj
          }));
      }
     

  }

  allowNext = vehicles  => vehicles.reduce( ( isValidSoFar, vehicle ) => isValidSoFar && ( this.loanAppicationData.Stage__c !== 'QDE' || vehicle.Is_Collateral_Updated_Post_Creation__c ), true );

    showToast(message,variant) {
        const event = new ShowToastEvent({
            title: '',
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    handleLoanDetailsSection(){
        console.log(' === Loan details being updated ===');
        this.isLoanDetailsOpen = !this.isLoanDetailsOpen;
    }

     /* @api nextHandler() {
        let vehicleRecord = this.applicantLst;
        if(vehicleRecord== null){
            this.errorOnChild =  'Please create vehicle record';
        }else{
            this.errorOnChild =  vehicleRecord.length>0?'':'Please create vehicle record';
        }
        const Obj = {};
        //this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild === '' ? true : false;
        if(Obj.next===false){
            this.showToast(this.errorOnChild,'error');
        }
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }*/

    
}