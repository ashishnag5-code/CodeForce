import { LightningElement,api, track } from 'lwc';

export default class DocumentWithoutAuditedComponent extends LightningElement {
    //API Attributes
    @api existingDetails;
    @api applicantId;
    @api spinnerImage;
    @api isMobile;
    @api isR2;
    @api loanAppId;

    finId;
    //Array Attributes
    activeSections = ['A'];
    itemList = [{
        id: 0
    }];

    //Boolean Attributes
    isLoaded = false;
    rendewithoutauditedFinaceTemplate = true;
    showYearIcons = true;

    //Decimal Attributes
    keyIndex = 0;

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
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    passtoparent(event) {
        this.currentKey = event.detail.key
        const selectedEvent = new CustomEvent("withoutdocauditedsubmit", {
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
        const selectedEvent = new CustomEvent("withoutdocauditedupdate", {
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

        this.template.querySelectorAll('c-documented-without-audited-child-component').forEach(element => {

            if (element.keyValue == this.currentKey) {
                console.log('handleDocReadonlyparent');
                element.handledocumentedReadOnly()
            }

        });
    }
    navigateToHome(event) {
        console.log('temp-->' + event.detail.template);
        console.log('redirect-->' + event.detail.redirect);
        this.rendewithoutauditedFinaceTemplate=false;
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                template: 'withoutaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleOtherIncome(event){
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'withoutdoc'
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