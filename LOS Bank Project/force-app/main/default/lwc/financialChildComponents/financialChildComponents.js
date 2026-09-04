import { LightningElement, track, wire, api } from 'lwc';
import getApplicants from '@salesforce/apex/financeController.getApplicants';
import FORMFACTOR from '@salesforce/client/formFactor'
import getExistingChildFinancialRecords from '@salesforce/apex/FinancialViewTemplateR2Controller.getExistingChildFinancialRecords'
import isPanMandatory from '@salesforce/apex/FinancialViewTemplateR2Controller.isPanMandatory';
import { toastWithMessage} from 'c/lwcutilities';
import getAllApplicantsFoir from '@salesforce/apex/foirController.getAllApplicantsFoir';
import getCommercialFinancialValidations from '@salesforce/apex/FinancialViewTemplateR2Controller.getCommercialFinancialValidations';

export default class FinancialChildComponents extends LightningElement {

    @track isCV = false;
    @track isTractor
    @track childrecord = {};
    @track childrecordId;
    @track applicantId
    applicantsData = []
    mdetailsOptions = [];
    recordType;
    @track isMobile
    @api recordId
    @track childRecords
    initialOption = 'Please select the applicant';

    connectedCallback() {
        if (FORMFACTOR == 'Small') {
            this.isMobile = true
        } else {
            this.isMobile = false
        }
        this.getApplicantsData()
    }

    getApplicantsData() {
        getApplicants({ applicantId: this.recordId })
            .then(data => {
                console.log('data-->' + JSON.stringify(data));
                this.applicantsData = data;
                this.recordType = data[0].Loan__r.RecordType.DeveloperName
                switch (this.recordType) {
                    case 'Tractor': this.isTractor = true; break;
                    case 'Two_Wheeler': this.isTwo_FourWheeler = true; break;
                    case 'Four_Wheeler': this.isTwo_FourWheeler = true; break;
                    case 'Commercial_Vehicle': this.isCV = true; break;
                    case 'Construction_Equipment': this.isCV = true; break;

                }
                let options = [];
                let applicantTypes = [];
                let applicantData = [];

                for (var key in data) {
                    let fName = data[key].First_Name__c ? data[key].First_Name__c : '';
                    let lName = data[key].Last_Name__c ? data[key].Last_Name__c : '';
                    options.push({
                        // label:fName + ' ' + lName,
                        label: data[key].Customer_Name__c + ' - ' + data[key].RecordType.Name,
                        value: data[key].Id,
                        applicantType: data[key].RecordType.Name
                    });

                    applicantTypes.push(data[key].RecordType.Name);
                }
                
                this.mdetailsOptions = options;
                this.setPredefinedDropDownValue(options);
            })
            .catch(error => {
                console.log('error in getApplicantsData' + error);

            })
    }

    async getChildRecords(){
        this.childRecords = await getExistingChildFinancialRecords({applicantId: this.applicantId})
    }
    

    setPredefinedDropDownValue(applicantOptions) {
        console.log('testpredefined ' + JSON.stringify(this.applicantsData))
        if (applicantOptions) {
            applicantOptions.forEach(applicant => {
                if (applicant.applicantType == 'Applicant') {
                    this.applicantId = applicant.value;
                    //this.handleShowComponent(this.applicantId);
                }
            })
            this.getChildRecords()
            if (this.applicantId) {
                let timeout = setTimeout(() => {
                    if (this.isTractor) {
                        this.template.querySelector('c-tractor-financial-child-templates').renderValuesPredefined(this.applicantId, this.applicantsData);
                    } else if (this.isCV) {
                        this.template.querySelector('c-commmercial-financial-child-templates').renderValuesPredefined(this.applicantId, this.applicantsData);
                    }
                }, 150);
            }

        }

    }

    checkCurrentRecordType(){
        switch (this.recordType) {
            case 'Tractor': this.isTractor = true; break;
            case 'Two_Wheeler': this.isTwo_FourWheeler = true; break;
            case 'Four_Wheeler': this.isTwo_FourWheeler = true; break;
            case 'Commercial_Vehicle': this.isCV = true; break;
            case 'Construction_Equipment': this.isCV = true; break;

        }
    }

    handleChange(event) {
        this.isTractor=false
        this.isCV = false
        let picklistName = event.target.name;
        let picklistValue = event.target.value;

        if (picklistValue != this.initialOption) {
            this.applicantId = picklistValue;
            var selectedId = picklistValue;
            if (this.applicantId != '') {
                this.checkCurrentRecordType()
                let timeout = setTimeout(() => {
                    this.handleShowComponent(selectedId);
                }, 150);
                
                //this.template.querySelector('c-financial-view-component').renderValues(selectedId); 
            }
        }
    }

    handleShowComponent(selectedId) {
        this.getChildRecords()
        if (this.isTwo_FourWheeler) {
            this.template.querySelector('c-financial-view-component').renderValues(selectedId);
        } else if (this.isTractor) {
            this.template.querySelector('c-tractor-financial-child-templates').renderValuesPredefined(selectedId, this.applicantsData);
        } else if (this.isCV) {
            this.template.querySelector('c-commmercial-financial-child-templates').renderValuesPredefined(selectedId, this.applicantsData);
        }
    }

    @api async nextHandler() {
        if (this.isTractor) {
            this.template.querySelector('c-tractor-financial-child-templates').nextChildHandler();
        }
        else if (this.isCV) {
            const result = await getCommercialFinancialValidations({loanId: this.recordId})
            if(result && result.length>0){
                result.forEach(input=>{
                    toastWithMessage(this, "", "Error", input);  
                })
                return
            }
           // this.template.querySelector('c-commmercial-financial-child-templates').nextChildHandler();
            await getAllApplicantsFoir({loanId: this.recordId})
            let error= await isPanMandatory({loanId: this.recordId})
            console.log('errorMsg-->' +error);
            if(error.length >0){
                toastWithMessage(this, "", "Error", error[0]);  
                return;   
            }else{
                 const Obj = {};
                 this.errorOnChild = '';
                Obj.errorOnChild = this.errorOnChild;
                Obj.next = this.errorOnChild == '' ? true : false;
                console.log('Obj', Obj);
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));     
            }     
        }
    }

    handleSuccessOnNext(event){
        const Obj = event.detail.Obj
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));  
    }

}