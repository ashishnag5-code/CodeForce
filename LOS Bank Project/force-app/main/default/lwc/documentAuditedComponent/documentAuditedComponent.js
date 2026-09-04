import { LightningElement,wire,api,track } from 'lwc';

export default class DocumentAuditedComponent extends LightningElement {
    //API Attributes
    @api existingDetails;
    @api applicantId;
    @api spinnerImage;
    @api loanAppId;
    @api isMobile;
    @api isR2;

    //Array Attributes
    documentedfinancialRecord = {};
    activeSections = ['A'];
    itemList = [{
        id: 0
    }];


    currentKey;
    finId;
    yearLabel = '';

    //Decimal Attributes
    turnOver = 0;
    grossturnoverMonthly = 0;
    annualNetProfit = 0;
    monthlyNetProfit = 0;
    annualDepreciation = 0;
    monthlyDepreciation = 0;
    annualInterestLoan = 0;
    monthlyInterestLoan = 0;
    annualnonchash = 0;
    monthlynoncash = 0;
    annualtotalIncome = 0;
    monthlytotalIncome = 0;
    keyIndex = 0;

    //Boolean Attributes
    rendeauditedFinaceTemplate = true;
    saveDetails = false;
    isLoaded = false;
    showYearIcons = true;

    @api
    get financialId() {
        return this.finId;
    }

    set financialId(value) {
        this.finId = value;
        /*if(this.finId){
            this.showModal = true;        
        }*/
    }

    connectedCallback(){
        
        if(this.existingDetails!='' && this.existingDetails!=null){
            this.showYearIcons =false;
         }else{
            this.showYearIcons =true;
         }
        
    }
    handleSubmitOtherIncome() {
        this.saveDetails = true;

    }

    addNewRow(event) {
        this.showFinancialScreen = true;
        ++this.keyIndex;

        var newItem = [{
            id: this.keyIndex
        }];
        this.itemList = this.itemList.concat(newItem);
    }

    removeRow(event) {
        console.log('key-->' + event.target.accessKey);
        var deletedItem = this.itemList.filter(function (element) {
            return parseInt(element.id) == parseInt(event.target.accessKey);
        });
        console.log('Deleted Audited Item ' + JSON.stringify(deletedItem));
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    passtoparent(event) {
        this.currentKey = event.detail.key
        const selectedEvent = new CustomEvent("docauditedsubmit", {
            // detail: this.salaryfinancialRecord
            detail: {
                record: event.detail.record,
                template: event.detail.template
            }

        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handlepasstoparentUpdate(event) {
        this.currentKey = event.detail.key
        const selectedEvent = new CustomEvent("auditedupdate", {
            //detail: event.detail
            detail: {
                record: event.detail.record,
                template: event.detail.template
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

    @api
    handledocReadOnly() {

        this.template.querySelectorAll('c-documented-audited-child-component').forEach(element => {

            if (element.keyValue == this.currentKey) {
                element.handledocumentedReadOnly()
            }

        });

    }

    navigateToHome(event) {
        console.log('temp-->' + event.detail.template);
        console.log('redirect-->' + event.detail.redirect);
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                template: 'documentaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleOtherIncome(event){
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'documentaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    //R2
    handleDeleteRecord(event){
        this.dispatchEvent(new CustomEvent('deletedrecord',{
            detail: ''
        }));
     }
}