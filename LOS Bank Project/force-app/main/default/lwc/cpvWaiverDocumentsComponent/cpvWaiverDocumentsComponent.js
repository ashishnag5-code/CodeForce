import { LightningElement, track, api } from 'lwc';
import getApplicants from '@salesforce/apex/CPVWaiverDocumentsController.getApplicants'
import getVerifiedRecords from '@salesforce/apex/CPVWaiverDocumentsController.getVerifiedRecords'
import getProductType from '@salesforce/apex/CPVWaiverDocumentsController.getProductType'

export default class CPVWaiverDocuments extends LightningElement {

    @api recordId
    @track selectedDocumentsList=[];
    @track selectedDocumentMap=new Map()
    @track activeSections=[];
    @track applicantOptions=[];
    isLoading;
    @api spinnerImage;
    selectedApplicant=''
    showDocumentSection=false
    removedRecord;
    selectedDocument;
    isOptionElectricityBill=false;
    isOptionWaterBill=false;
    isOptionInsurancePremiumReceipt=false;
    isOptionBankStatement=false;
    isOptionHousetaxReceipt=false;
    isOptionMobileBill=false;
    isOptionGasBill=false;
    isOptionPNGBill=false;
    isOptionPassbook=false;
    errorOnChild='';
    options=['Passbook','Electricity bill','Water Bill','Mobile Bill','Gas bill','PNG bill','Insurance Premuim Receipt','House Tax Receipt','Bank Statement']
    cpvSectionLabel=''

    async connectedCallback(){
        this.isLoading=true
        var productType = await getProductType({recordId: this.recordId})
        /*if(productType == 'Four Wheeler'){
            this.cpvSectionLabel = 'Fast Processing Documents'
        }*/
        if(productType == 'Two Wheeler'){
            this.cpvSectionLabel = 'CPV Waiver Documents'
        }else{
            this.cpvSectionLabel = 'Fast Processing Documents'
        }

        getApplicants({applicantId: this.recordId}).then((data)=>{
            this.isLoading=false
            var options=[];
            data.forEach(element => {
                let fName = element.First_Name__c ? element.First_Name__c : '';
                let lName = element.Last_Name__c ? element.Last_Name__c : '';
                var app = {label: fName+' '+lName, value: element.Id}
                options.push(app)
            });
            this.applicantOptions = options
            this.setPredefinedApplicantData(data);
        }).catch((error=>{
            this.isLoading=false
        }))

    }

    setPredefinedApplicantData(applicantData){
        console.log('predefineddata '+JSON.stringify(applicantData));
        applicantData.forEach(applicant=>{
            if(applicant.RecordType.Name == 'Applicant'){
                this.selectedApplicant = applicant.Id;
            }
        })
        this.setApplicantDocumentList(this.selectedApplicant);
    }

    handleChange(event){
        this.selectedApplicant = event.target.value;
        this.setApplicantDocumentList(this.selectedApplicant);
       
        
        
    }

    setApplicantDocumentList(applicantId){
        this.selectedDocumentMap=new Map()
        this.selectedDocumentsList = []
        getVerifiedRecords({recordId: applicantId, documentType: this.options}).then((data)=>{
            data.forEach(element => {
                this.selectedDocumentMap.set(element.Document_Master__r.Document_Name__c, {val: element.Document_Master__r.Document_Name__c, isVerified: true})
            });
            this.selectedDocumentsList=Array.from(this.selectedDocumentMap.values())
        })
        this.showDocumentSection = true
        this.selectedDocument = ''

    }

    get documentOptions(){
        return [{label:'Electricity Bill',value:'Electricity bill'},
                {label:'Water Bill',value:'Water Bill'},
                {label:'Mobile Bill',value:'Mobile Bill'},
                {label:'Gas Bill',value:'Gas bill'},
                {label:'PNG Bill',value:'PNG bill'},
                {label:'Insurance Premuim Receipt',value:'Insurance Premuim Receipt'},
                {label:'House Tax Receipt',value:'House Tax Receipt'},
                {label:'Bank Statement',value:'Bank Statement'},
                {label:'Passbook',value:'Passbook'}
            ];
    }

    handleSelectedDocumentChange(event){
        this.removedRecord=''
        var value = event.target.value;
        this.selectedDocument = value;
        if(!this.selectedDocumentMap.get(value)){
            this.selectedDocumentMap.set(value, {val: value, isVerified: false})
        }
        this.selectedDocumentsList=Array.from(this.selectedDocumentMap.values())
        /*if(!this.selectedDocumentsList.includes(value)){
            this.selectedDocumentsList.push(value);
        }*/
    }

    handleRemove(event){

        var value = event.target.name;
        this.removedRecord = this.selectedDocumentMap.get(event.target.name).val
        this.selectedDocumentMap.delete(event.target.name)
        this.selectedDocumentsList=Array.from(this.selectedDocumentMap.values())
        /*var list = this.selectedDocumentsList
        var record = list.filter(function (element) {
            return element == value;
        })
        this.removedRecord = record[0];
        this.selectedDocumentsList = list.filter(function (element) {
            return element != value
        })*/
    }

    @api 
    nextHandler() {
        let Obj={};
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
}