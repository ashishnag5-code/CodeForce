import { LightningElement, api, wire, track } from 'lwc';
import getApplicants from '@salesforce/apex/financeController.getApplicants';
import getSummaryDetails from '@salesforce/apex/financeSummaryClass.getSummaryDetails';
import { NavigationMixin } from 'lightning/navigation';

// DL Popup functionality
// Product codes 
import PRODUCT_CODES_FOR_DL_POP_UP from '@salesforce/label/c.DL_Required_Pop_Up_For_Commerical_Products';
//Stage value
import STAGE_FOR_DL_POP_UP from '@salesforce/label/c.DL_Required_Pop_Up_For_Commercial_Stage';
// DL Popup functionality
export default class FinancialInformation extends LightningElement {
    // API Attributes
    @api key;
    @api recordVal;
    @api spinnerImage;
    @api insideRecordPage

    // Array Attributes
    applicantsData = [];
    mdetailsOptions = [];
    applicantsSummaryData;
    applicantTypes = [];
    @track screenHeading='Financial Details'
    //String Attributes
    applicantId;
    accesskey;
    applicantType;
    initialOption = 'Please select the applicant';
    labelVal = 'Choose Applicant from Drop down';
    recordTypeVal;

    // Decimal Attributes
    keyIndex = 0;
    itemList = [
        {
            id: 0
        }
    ];

    // Boolean Attributes
    isLoading = false;
    showViewForm = false;
    disableButtons = false;
    showSummary = false;
    isTwo_FourWheeler = false
    isTractor = false
    isCV = false

    connectedCallback() {
        this.showViewForm = true;
        this.getApplicantsData();
        // this.getApplicantSummaryData();
    }

    addNewRow(event) {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
        this.showViewForm = false;
    }

    removeRow(event) {
        this.accesskey = event.target.accessKey;

        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
            //this.template.querySelector('c-financial-view-component').handleDeletion();
        }
    }
    handleButtons(event) {
        this.disableButtons = true;
    }

    async getApplicantsData() {
        try{
            let data = await getApplicants({applicantId: this.recordVal });
            
            // Check for valid product codes for DL toast in case new CE 

            let applicant = data.find(ele => ele.RecordType.DeveloperName === 'Primary_Applicant');
            
            let dlMandatoryProductCode = new Set();
            let dlMandatoryStage = new Set();

            // Populating from product codes from custom labels
            for(let product of PRODUCT_CODES_FOR_DL_POP_UP.split(',')){
                dlMandatoryProductCode.add(product.trim());
            }

            // Populating from Stages from custom labels
            for(let stage of STAGE_FOR_DL_POP_UP.split(',')){
                dlMandatoryStage.add(stage.trim());
            }

            

            if(dlMandatoryProductCode.has(applicant.Loan__r.Product__c) && dlMandatoryStage.has(applicant.Loan__r.Stage__c)){
                this.dispatchEvent(new CustomEvent('producteligblefordlcheck' , {detail : {mainApplicantId : applicant.Id}}));
                
            }
            // Check for valid product codes for DL toast in case new CE 
            console.log('data-->' +JSON.stringify(data));
            this.applicantsData = data;
            const recordType = data[0].Loan__r.RecordType.DeveloperName
            this.recordTypeVal = recordType;
            switch(recordType){
                case 'Tractor' : this.isTractor = true; this.screenHeading='Land Details';break;
                case 'Two_Wheeler' : this.isTwo_FourWheeler = true; break;
                case 'Four_Wheeler' : this.isTwo_FourWheeler = true; break;
                case 'Commercial_Vehicle' : this.isCV = true; this.screenHeading='Customer Details'; break;
                case 'Construction_Equipment' : this.isCV = true;this.screenHeading='Customer Details'; break;
                
            }
            this.showViewForm = true;
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

            this.applicantTypes = applicantTypes;
            this.setPredefinedDropDownValue(options);

        }
        catch (e) {
            console.log('error in getApplicantsData' + e);
        }
        
    }


    setPredefinedDropDownValue(applicantOptions) {
        console.log('testpredefined ' + JSON.stringify(this.applicantsData))
        if (applicantOptions) {
            applicantOptions.forEach(applicant => {
                if (applicant.applicantType == 'Applicant') {
                    this.applicantId = applicant.value;
                    this.showViewForm = true;

                    //this.handleShowComponent(this.applicantId);
                }
            })
            if (this.applicantId) {
                let timeout = setTimeout(() => { //june29
                    if (this.isTractor) {
                        this.template.querySelector('c-r2_-land-details').renderValuesPredefined(this.applicantId, this.applicantsData);
                    }else if(this.isTwo_FourWheeler){
                        this.template.querySelector('c-financial-view-component').renderValuesPredefined(this.applicantId, this.applicantsData);
                    }else if(this.isCV){
                        this.template.querySelector('c-financial-view-template-commercial').renderValuesPredefined(this.applicantId, this.applicantsData);
                    }
                }, 150);
            }

        }

    }


    handleChange(event) {
        this.showSummary = false;
        this.showViewForm = true;
        let selected = event.detail;

        //let picklistName = selected.target.name;
        //  let picklistValue = selected.target.value;
        let picklistName = event.target.name;
        let picklistValue = event.target.value;

        if (picklistValue != this.initialOption) {
            this.applicantId = picklistValue;
            var selectedId = picklistValue;
            if (this.applicantId != '') {
                this.handleShowComponent(selectedId);
                //this.template.querySelector('c-financial-view-component').renderValues(selectedId); 
            }
        } else {
            this.showViewForm = false;
            this.showSummary = true;
        }
    }

    async handleShowComponent(selectedId) {
        let data = await getApplicants({applicantId: this.recordVal });
        if (this.isTwo_FourWheeler) {
            this.template.querySelector('c-financial-view-component').renderValues(selectedId);
        } else if (this.isTractor) {
            this.template.querySelector('c-r2_-land-details').renderValuesPredefined(selectedId, data);
        } else if (this.isCV) {
            this.template.querySelector('c-financial-view-template-commercial').renderValuesPredefined(selectedId, data);
        }
    }

    /* navigateToAppRecordPage(event) {
         console.log('App Id', event.currentTarget.dataset.id);
         this.navigateToRecordPage(event.currentTarget.dataset.id);
 
     }
 
     navigateToRecordPage(objectRecordid) {
         this[NavigationMixin.Navigate]({
             type: 'standard__recordPage',
             attributes: {
                 recordId: objectRecordid,
                 objectApiName: 'Applicant__c',
                 actionName: 'view'
             },
         });
     }*/

    @api
    checkCustomerGradeValidation() {
        if (this.template.querySelector('c-financial-view-component').checkforCustomerGradeUpdate()) {
            return true
        } else {
            return false
        }
    }

    //Method to get the record type that is used for on click of next validation
    @api
    getLoanRecordType(){
        return this.recordTypeVal;
    }

    @api
    nextHandlerChild(recordTypeName){
        if(recordTypeName == 'Tractor'){
            return (this.template.querySelector('c-r2_-land-details').nextHandlerChild());
        }
    }

    nextFromTractorTemp(event){
        const Obj = {};
        //Obj.applicantRecord = this.applicantIdInput;
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));                
    }


}