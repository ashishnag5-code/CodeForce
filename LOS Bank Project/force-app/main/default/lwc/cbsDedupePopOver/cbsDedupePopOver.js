import { api, LightningElement, track } from 'lwc';
import getApplicants from '@salesforce/apex/Utility.getApplicants'
import getCollaterals from '@salesforce/apex/CAMReportLWCController.getCollaterals'
import updateDedupeCheckForApplicant from '@salesforce/apex/CreditVerification.updateDedupeCheckForApplicant'

export default class CbsDedupePopOver extends LightningElement {
    @api open;
    boolFromCamReport=true
    boolCamReportTypeCBS=false
    boolCamReportTypeLead=false
    boolCamReportTypeVehicle=false
    boolisMobile=false
    applicantName='';
    @track vehicleData
    @api recordId
    @api type
    @api factor

    async connectedCallback(){
        getApplicants({applicantId: this.recordId}).then((data)=>{
            if(data && data.length>0)
                this.applicantName = data[0].First_Name__c+' '+data[0].Last_Name__c;
        })

        if(this.type=='CBS'){
            this.boolCamReportTypeCBS=true
            this.boolCamReportTypeLead=false
            this.boolCamReportTypeVehicle=false
        }else if(this.type=='Lead'){
            this.boolCamReportTypeLead=true
            this.boolCamReportTypeCBS=false
            this.boolCamReportTypeVehicle=false
        }else{
            this.boolCamReportTypeCBS=false
            this.boolCamReportTypeLead=false
            this.getCollateralsDetails();
        }

        if(this.factor=="1"){
            this.boolisMobile=true
        }else{
            this.boolisMobile=false
        }
        if(this.type=='Lead' || this.type=='CBS'){
            await updateDedupeCheckForApplicant({appId: this.recordId, dedupeType: this.type })
        }
    }

    getCollateralsDetails(){
        getCollaterals({recordId: this.recordId}).then((data)=>{
            this.vehicleData = data.collaterals
            this.boolCamReportTypeVehicle=true
        })
    }

    closeData(){
        window.history.back();
    }
}