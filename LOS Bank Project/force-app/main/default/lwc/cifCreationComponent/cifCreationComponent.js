import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicants from '@salesforce/apex/CIFCreationController.getApplicants'
import { updateRecord } from 'lightning/uiRecordApi';
import getApplicant from '@salesforce/apex/CIFCreationController.getApplicant'
import { NavigationMixin } from 'lightning/navigation';
import getUserType from '@salesforce/apex/CIFCreationController.getUserType'
import handleExposureDPD from '@salesforce/apex/CIFCreationController.handleExposureDPD';
import checkMotorInsurance from '@salesforce/apex/LoanDisbursementOpsController.checkMotorInsurance'
import { getSpinnerImage } from 'c/customSpinner';

export default class CifCreationComponent extends NavigationMixin(LightningElement) {

    @track loanStage ='';// SFAU-2751 
    @api loanId;
    @track applicants = [];
    disableExposureButton=true
    cifPendingApplicantIds = [];
    exposurePendingApplicantIds = [];
    userType;
    @track insCheck
    @api spinnerImage;
    @track isLoading=false

    async connectedCallback() {
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.loanId);
        }
        this.isLoading=true
        this.userType = await getUserType({recordId: this.loanId})
        this.getApplicantDetails();
    }

   async getApplicantDetails() {
        let response =  await this.handleDPDScenario();
        //4473
        let motorInsCheck = await checkMotorInsurance({loanId: this.loanId})
        if(motorInsCheck == 'Failed'){
            this.showToast('','Found Discrepency in Motor Insurance Deviation. Please Send the Application Back to PSD Stage','error')
            this.insCheck = 'Failed'
        }    
        //4473
        getApplicants({ loanId: this.loanId }).then((data => {
            this.applicants = data;
            this.loanStage = data[0].Loan__r.Stage__c; //SFAU-2751
            this.applicants.forEach(element => {
                if(!element.CIF_No__c || element.CIF_No__c==''){
                    this.cifPendingApplicantIds.push(element.Id);
                }
                var newDate = new Date()
                var todaysDate = newDate.getFullYear()+'-'+(newDate.getMonth()+1).toString().padStart(2,'0')+'-'+newDate.getDate().toString().padStart(2, '0');
                console.log('todaysDate '+todaysDate);
             //   if(element.Loan__r.Stage__c!='Ops Author' && (element.Loan__c && ((element.Loan__r.Dpd_Checked_Date__c && element.Loan__r.Dpd_Checked_Date__c!=todaysDate) || !element.Loan__r.Dpd_Checked_Date__c))){
               console.log('response-->' +response);
             if(element.Loan__r.Stage__c!='Ops Author' && (element.Loan__c && response == true) && !element.Loan__r.LAN__c){
                    this.exposurePendingApplicantIds.push(element.Id)
                    //this.disableExposureButton = false
                }else{
                    this.disableExposureButton = true
                }
               /* //START || SFAU-2751 || Ashish
                if( this.loanStage == 'Ops Maker'){
                    this.handleDPDScenario();
                }
                //END*/
            });


            /*if(this.cifPendingApplicantIds.length==0){
                this.dispatchEvent(new CustomEvent('cifcreated'));
            }//uncommented by Neha*/
            this.checkAllChecksDone()
            this.isLoading=false
        })).catch((error => {
            this.isLoading=false
            //this.showToast('Error', error.message.body, 'error')
           console.log('error-->' +error);
        }))
    }

    //START || SFAU-2751 || Ashish
    handleDPDScenario(){
        let response = false;
        return new Promise((resolve, reject) => {
            handleExposureDPD({ loanId: this.loanId}).then((data=>{
                if(data!=null){
                    if(data == true){// button active condition true 
                        this.disableExposureButton = false;
                    } else if(data == false){
                        this.disableExposureButton = true;
                    }
               }
               if( this.disableExposureButton ==false){
                response = true;
               }else{
                response = false;
               }
               
               resolve(response);
            })).catch((error=>{
                //this.showToast('Error',error.message.body,'error')
                reject('');
            }))

        })
    }
    //END
    /*getApplicantDetails(id){
        getApplicant({appId: id}).then((data=>{
            if(data.Credit_Approved_Exposure__c <= data.Total_Exposure__c){
                this.showToast('Warning','Exposure Increased. Returning to DDE','warning')
                const fields = { Id: this.recordId, Stage__c: 'DDE' };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.isLoading = false
                    this.showToast('Success', 'Stage Changed to DDE', 'success')
                });
            }
            this.checkAllChecksDone()
        }))
    }//uncommented by Neha*/

    handleCIFCreationEvent(event) {
        var idToBeRemoved = event.detail.applicantRecordId;
        const index = this.cifPendingApplicantIds.indexOf(idToBeRemoved);
        if (index > -1) { 
            this.cifPendingApplicantIds.splice(index, 1); 
        }
        this.checkAllChecksDone()
        /*if(this.cifPendingApplicantIds.length==0){
            //this.dispatchEvent(new CustomEvent('cifcreated'));
            this.showToast('Success','CIF for all applicants are created','success')
        }*/
    }

    checkAllChecksDone(){
        if(this.cifPendingApplicantIds.length==0 && this.exposurePendingApplicantIds.length==0){
            this.dispatchEvent(new CustomEvent('cifexposurecomplete'));
        }
    }

    getLoanDetails(id){
        getApplicant({appId: id}).then((data=>{
            if(data.Loan__c && data.Loan__r.Dpd_Found__c==true && data.Loan__r.Pre_Approved_Flag__c==true){
                this.showToast('Error','DPD Found. Returning to DDE','error', 'sticky')
            }
            if(data.Credit_Approved_Exposure__c < data.Total_Exposure__c){
                this.showToast('Error','Exposure Increased. Returning to DDE','error', 'sticky')
            }
            if((data.Loan__c && data.Loan__r.Dpd_Found__c==true && data.Loan__r.Pre_Approved_Flag__c==true) || 
                (data.Credit_Approved_Exposure__c < data.Total_Exposure__c)){
                const fields = { Id: this.loanId, Stage__c: 'DDE', Approval_Status__c: 'Ops Send Back to RO' };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.isLoading = false
                    this.showToast('Success', 'Stage Changed to DDE', 'success')
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.loanId,
                            objectApiName: 'Loan_Application__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    })
                });
            }else{
                this.checkAllChecksDone()
            }
        })).catch((error=>{
            this.showToast('Error',error.message.body,'error', 'sticky')
        }))
    }
    

    handleExposureEvent(event) {
        var idToBeRemoved = event.detail.applicantRecordId;
        const index = this.exposurePendingApplicantIds.indexOf(idToBeRemoved);
        if (index > -1) { 
            this.exposurePendingApplicantIds.splice(index, 1); 
        }
        this.getLoanDetails(event.detail.applicantRecordId)
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}