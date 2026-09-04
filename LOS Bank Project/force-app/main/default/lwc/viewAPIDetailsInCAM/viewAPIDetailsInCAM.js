import { LightningElement, api, track } from 'lwc';
import getAPIResponse from '@salesforce/apex/CAMReportLWCController.getAPIResponse'

export default class ViewAPIDetailsInCAM extends LightningElement {

    @api open;
    applicantName='';
    @track apiResponse
    @api recordId
    @api applicantId
    @api type
    @api factor
    identifierDocuments = false
    @track loadCmp=false
    documentsResponsesToBeModified = ['AUWheels0005','AUWheels0002','AUWheels0004']
    @track matchScore
    @track type

    async connectedCallback(){
        const response = await getAPIResponse({recordId: this.recordId})
        let parsedResp = JSON.parse(response.documentChecklist.Api_Response__c)
        let documentMasterName = response.documentChecklist.Document_Master__r.Name
        if(documentMasterName=='AUWheels0001'){
            this.apiResponse = parsedResp
            this.dispType = 'PAN'
        }else if(this.documentsResponsesToBeModified.includes(documentMasterName)){
            this.apiResponse = {Response: parsedResp, metadata:response.displayMetadata}
            if(documentMasterName=='AUWheels0005'){
                this.dispType = 'Passport'
            }else if(documentMasterName=='AUWheels0002'){
                this.dispType = 'Voter ID'
            }else if(documentMasterName=='AUWheels0004'){
                this.dispType = 'Driving Licence'
            }
        }else{
            this.apiResponse = parsedResp
            if(documentMasterName=='AUWheels0093'){
                this.dispType = 'Electricity Bill Details'
                this.type="Electricity Bill"
                this.matchScore = response.documentChecklist.Address_Match_Score__c?response.documentChecklist.Address_Match_Score__c:-101
            }else if(documentMasterName=='AUWheels0091'){
                this.dispType = 'PNG Bill Details'
                this.type="PNG Bill"
                this.matchScore = response.documentChecklist.Address_Match_Score__c?response.documentChecklist.Address_Match_Score__c:-101
            }  
        }
        this.applicantName=response.documentChecklist.Applicant__r.First_Name__c+' '+response.documentChecklist.Applicant__r.Last_Name__c
        this.loadCmp=true
    }

    closeData(){
        window.history.back();
    }
}