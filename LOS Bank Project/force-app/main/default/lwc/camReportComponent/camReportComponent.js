import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import runCAMReport from '@salesforce/apex/CAMReportLWCController.runCAMReport'
import getLatestCAMReport from '@salesforce/apex/CAMReportLWCController.getLatestCAMReport'
import {NavigationMixin} from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getSpinnerImage } from 'c/customSpinner';
import setValidationOnDocument from '@salesforce/apex/CreditVerification.setValidationOnDocument'
import getActivePrimaryApplicants from '@salesforce/apex/CAMReportLWCController.getActivePrimaryApplicants'
import CAM_No_APPLICANT_ERROR from '@salesforce/label/c.CAM_No_APPLICANT_ERROR';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
//added LMS event - SFAU-5280

export default class CAMReportComponent extends NavigationMixin(LightningElement) {

    @api recordId
    @track fileUrl
    @track fileExists=false
    @track showBack=false
    @track loadSpinner=false
    @track activeApplicantsPresent=true
    @track loanRecordType
    subscription = null;
    @api
    spinnerImage;
    height;
    @api 
    get heightInRem(){
        return this.height+'rem'
    }
    set heightInRem(value){
        this.height=value
    }

    loadData(){
        this.loadSpinner=false
    }

    async connectedCallback(){
        this.showBack=false
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.subscribeToMessageChannel()
        this.setInitialData()
        /*const activePrimaryApplicants = await getActivePrimaryApplicants({loanId: this.recordId})
        if(!activePrimaryApplicants || activePrimaryApplicants.length<=0){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            this.activeApplicantsPresent=false
            return;
        }
        this.generateLatestCamReport()*/
    }

    async setInitialData(){
        const activePrimaryApplicants = await getActivePrimaryApplicants({loanId: this.recordId})
        if(!activePrimaryApplicants || activePrimaryApplicants.length<=0){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            this.activeApplicantsPresent=false
            return;
        }else{
            this.loanRecordType=activePrimaryApplicants[0].Loan__r.RecordType.DeveloperName
        }
        this.generateLatestCamReport()
    }

    showToastMessage(titleValue, messageValue, variantValue, mode){
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    async runReport(){
        this.loadSpinner=true 
        if(!this.activeApplicantsPresent){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            this.loadSpinner=false
            return;
        }
        this.showBack=true;
        runCAMReport({recordId: this.recordId}).then((data)=>{
            this.fileExists=true

            this.showToastMessage('Success','CAM Report Generated SuccessFully','success')
            setValidationOnDocument({documentType:'CAM',loanApplicationId:this.recordId}).then((data=>{

            })).catch((error=>{
                
            }))
            if(FORM_FACTOR==='Small'){
                
                this[NavigationMixin.Navigate]({
                  type: 'standard__namedPage',
                  attributes: {
                      pageName: 'filePreview'
                  },
                  state : {
                      recordIds: data.ContentDocumentId,
                      selectedRecordId:data.ContentDocumentId
                  }
                })
              
            }else{
                var urlId = data.Id
                //this.fileUrl='https://ausfb2022--dev1.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+urlId
                this.fileUrl='/sfc/servlet.shepherd/version/download/'+urlId
            }
                        
        }).catch((error)=>{
            this.loadSpinner=false
            this.showToastMessage('Error','We encountered an Error while generating CAM Report','error')
        })

        
    }

    goBack(){
        if(!this.activeApplicantsPresent){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            this.showBack=false
            this.fileExists=false
            return;
        }
        this.generateLatestCamReport()
    }

    generateLatestCamReport(){
        this.loadSpinner=true
        this.showBack=false
        this.fileExists=true
        var factor = FORM_FACTOR=='Small'?"1":"3"
        if(this.loanRecordType=='Tractor'){
            this.fileUrl='/apex/TractorCAMSummaryPage?id='+this.recordId+'&factor='+factor
        }else{
            this.fileUrl='/apex/CAMReportVFPage?id='+this.recordId+'&factor='+factor
        }
        //this.fileUrl='https://ausfb2022--dev1.sandbox.lightning.force.com/apex/CAMReportVFPage?id='+this.recordId+'&factor='+factor
        

    }

    viewReport(){
        
        this.loadSpinner=true
        getLatestCAMReport({recordId: this.recordId}).then((data)=>{
            //this.fileUrl='data:application/pdf;base64,'+EncodingUtil.base64Encode(data.VersionData);
            if(data && data.ContentDocumentId){
                this.showToastMessage('Success','Latest CAM Report Fetched SuccessFully','success')
                this.fileExists=true
                this.showBack=true
                if(FORM_FACTOR==='Small'){
                
                    this[NavigationMixin.Navigate]({
                      type: 'standard__namedPage',
                      attributes: {
                          pageName: 'filePreview'
                      },
                      state : {
                          recordIds: data.ContentDocumentId,
                          selectedRecordId:data.ContentDocumentId
                      }
                    })
                  
                }else{
                    var urlId = data.Id
                    //this.fileUrl='https://ausfb2022--dev1.sandbox.file.force.com/sfc/servlet.shepherd/version/download/'+urlId
                    this.fileUrl='/sfc/servlet.shepherd/version/download/'+urlId

                }
            }else{
                this.showToastMessage('Error','No CAM Report was found for the Application. Please click on Generate Latest CAM Report to Proceed','error')
            }
            
            
            

        }).catch((error)=>{
            this.loadSpinner=false
            this.showToastMessage('Error','We encountered an Error while generating CAM Report','error')
        })
        
    }

    messageContext = createMessageContext();
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    
    handleMessage(message){
        if(message.refreshPage=='Yes'){
            this.fileExists=false
            this.setInitialData()
        }
    }  
    
    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}