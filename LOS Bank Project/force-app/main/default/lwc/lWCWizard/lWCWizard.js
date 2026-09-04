import { LightningElement, track, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
 
export default class LWCWizard extends NavigationMixin(LightningElement) {
    @api recordId
    @track currentStep = '1';
 
    handleOnStepClick(event) {
        this.currentStep = event.target.value;
    }
 
    get isStepOne() {
        return this.currentStep === "1";
    }
 
    get isStepTwo() {
        return this.currentStep === "2";
    }
 
    get isStepThree() {
        return this.currentStep === "3";
    }
 
    get isEnableNext() {
        return this.currentStep != "3";
    }
 
    get isEnablePrev() {
        return this.currentStep != "1";
    }
 
    get isEnableFinish() {
        return this.currentStep === "3";
    }
 
    handleNext(){
        if(this.currentStep == "1"){
            this.currentStep = "2";
        }
        else if(this.currentStep = "2"){
            this.currentStep = "3";
        }
    }
 
    handlePrev(){
        if(this.currentStep == "3"){
            this.currentStep = "2";
        }
        else if(this.currentStep = "2"){
            this.currentStep = "1";
        }
    }
 
    handleFinish(){
 
    }

    cancelHandler() {
        console.log('cancel');
        this.navigateToRecordPage(this.recordId);
    }

    navigateToRecordPage(objectRecordid) {
        //this.updateRecordView();
        //getRecordNotifyChange([{recordId: this.recordId}]);
        console.log('objectRecordid', objectRecordid);
        //if(!this.isMobile){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: objectRecordid,
                    actionName: 'view'
                },
            });
        }
}