import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord, getFieldValue } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import ID_FIELD from "@salesforce/schema/Loan_Application__c.Id";
import REFERENCE_FIELD from "@salesforce/schema/Loan_Application__c.References__c";
import LOAN_AMOUNT_FIELD from "@salesforce/schema/Loan_Application__c.Loan_Amount__c";
import STAGE_FIELD from "@salesforce/schema/Loan_Application__c.Stage__c";

import applicantHandler from '@salesforce/apex/RelatedReferencesComponentController.applicantHandler';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';

const fields = [REFERENCE_FIELD, LOAN_AMOUNT_FIELD, STAGE_FIELD];

export default class RelatedReferencesComponent extends LightningElement {

    @api recordId;
    @api spinnerImage;
    @track referncesData;
    @track origWireReferenceData;
    @track referncesFLdParse;
    @track referenceFldVal;
    @track error;
    @track relationshipOfBorrowerOptions = [];

    errorOnChild;
    referencesRecordCount;
    viewRelatedReferences = true;
    checkStateForValidation = false;
    referenceScenario     = '';
    isLoading              = false;
    addIcon               = true;
    NameVal               = '';
    relationshipOfBorrowerValue = '';
    addressVal            = '';
    mobileNoVal           = '';
    mobNoAsAIdForEdit     = ''; 
    referenceArr          = [];
    referenceObj          = {};    
    applicantDet;
    loanStage;
    loanAmount;
    loanRecordTypeName = '';
    showEdit = true

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    loanApplctn(result) {       
        const { error, data } = result;
        this.origWireReferenceData = result;
        if (data) {
            this.referncesData         = data;
            this.loanStage             = this.referncesData.fields.Stage__c.value;
            this.loanAmount            = this.referncesData.fields.Loan_Amount__c.value;
            this.referncesFLdParse     = JSON.parse(this.referncesData.fields.References__c.value);
            if(this.referncesFLdParse !== null) {
                this.referenceFldVal   = this.fltrActiveReference(this.referncesFLdParse);
            }         
            this.referencesRecordCount = this.referenceFldVal !== undefined ? this.referenceFldVal.length : 0;
            console.log("referenceFldVal-- "+JSON.stringify(this.referenceFldVal));
            this.error = undefined;
        } else if (error) {
            this.error         = error;
            this.referncesData = undefined;
        }
    }

    connectedCallback() {
        this.getApplcnt();
        this.disableFieldsAsPerMetadata();
    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'References',strLoanId:this.recordId});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                this.showEdit = false;
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
        this.isLoading=false
    }

    getApplcnt() {
        applicantHandler({ loanApplId : this.recordId })
            .then((result) => {
                this.applicantDet = result;
                this.loanRecordTypeName = result.recordTypeName;
                this.removeSelfFromRelationshipWithApplOptions(result.relationshipWithBorrower);
                this.error = undefined;        
            })
            .catch((error) => {
                this.error = error;
                console.log("Error inside applicantHandler--> "+error);
                this.applicantDet = undefined;
            });
    } 

    removeSelfFromRelationshipWithApplOptions(relationShipWithBorrowerOptions) {
        let splitString = relationShipWithBorrowerOptions.split(",");
        let result = splitString.filter(Opt => Opt != 'Self');
        let mapOptions = result.map(opt => ({ label: opt, value: opt }));
        this.relationshipOfBorrowerOptions = mapOptions;

    }
    
    validationForReference() {
        refreshApex(this.origWireReferenceData);
        let resStatus       = this.applicantDet.residenceStatus;
        let industry        = this.applicantDet.industry;
        let referenceFldVal = [];
        if(this.referncesFLdParse != null) {
            referenceFldVal = this.fltrActiveReference(this.referncesFLdParse);
        }
        if(this.loanStage == "QDE") {
            let inclueLoanRecordTypes = ["Two Wheeler"]
            //if(this.loanRecordTypeName != "Four Wheeler") {
            if(inclueLoanRecordTypes.includes(this.loanRecordTypeName)) {
                //200000
                if((this.loanAmount > this.applicantDet.twLoanAmountLimit || resStatus == 'Rented' || industry == "Defence/Police/Paramilitary")) {
                    if((referenceFldVal.length < 2)) {
                        this.showMessage("", "Adding Two Reference is Mandatory", "error", "sticky");
                        this.checkStateForValidation = true;
                    }
                    else {
                        this.checkStateForValidation = false;
                    }                     
                }
                else {
                    this.checkStateForValidation = false;
                }
            }
        }
        else if(this.loanStage == "DDE") {
                if(referenceFldVal.length < 2) {
                    this.showMessage("", "Adding Two Reference is Mandatory", "error", "sticky");
                    this.checkStateForValidation = true;
                }
                else {
                    this.checkStateForValidation = false;
                }
        }
    }

    addReferenceIcon(event) {       
        this.addReferencesScreen   = true;
        this.addIcon               = false;
        this.viewRelatedReferences = false;
    }

    handleCancel(event) {
        this.addReferencesScreen   = false;
        this.addIcon               = true;
        this.viewRelatedReferences = true;
        this.handleReset();
        this.referenceScenario     = ""; 
    }

    handleReset() {
        this.NameVal              =  '';
        this.addressVal           =  '';
        this.mobileNoVal          =  '';
        this.relationshipOfBorrowerValue = '';
    }

    handleReferenceEdit(evt) {
        let mobNo = evt.currentTarget.dataset.id;
        this.mobNoAsAIdForEdit     = mobNo;
        let referenceData          = this.referenceFldVal.filter( obj => obj.Mobile_Number === mobNo);
        this.NameVal               = referenceData[0].Name !== null || referenceData[0].Name !== "" ? referenceData[0].Name : "";
        this.relationshipOfBorrowerValue = referenceData[0].Relationship_With_Borrower != null || referenceData[0].Relationship_With_Borrower != "" ? referenceData[0].Relationship_With_Borrower : '';
        this.addressVal            = referenceData[0].Address !== null || referenceData[0].Address !== "" ? referenceData[0].Address : "";
        this.mobileNoVal           = referenceData[0].Mobile_Number !== null || referenceData[0].Mobile_Number !== "" ? referenceData[0].Mobile_Number : "";
        this.referenceScenario     = "referenceEdit";      
        this.addReferencesScreen   = true;
        this.addIcon               = false;
        this.viewRelatedReferences = false;
        this.disableFieldsAsPerMetadata();
    }

    handleReferenceDelete(evt) {
        let evtId = evt.currentTarget.dataset.id
        restricAccess({
            compName: 'relatedReferencesComponent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to delete Reference',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    let mobNo                = evtId//evt.currentTarget.dataset.id;        
                    let referenceData        = this.updateReferenceDataAfterDelete(this.referncesFLdParse, mobNo);
                    let referenceArrTOString = JSON.stringify(referenceData);
                    this.genericUpdateForReferenceFld(this.recordId, referenceArrTOString, 'Delete Reference'); 
                    this.referenceFldVal    = this.fltrActiveReference(this.referenceFldVal);
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    fltrActiveReference(referenceFldVal) {
        let referenceData        = referenceFldVal.filter( refData => refData.IsActive === "true");
        console.log('referenceData in fltrActiveReference--  ' + JSON.stringify(referenceData));
        return referenceData;
    }

    updateReferenceDataAfterDelete(referenceData, mobNo) {
        let reference        = referenceData.filter( refData => {
            if(refData.Mobile_Number === mobNo) {
                refData.IsActive = "false";
                return refData;
            } 
            else {
                return refData;
            } 
        });
        return reference;
    }

    handleChange(e) {
        let targetAttr = e.target.name;
        let targetVal  = e.target.value !== null ? e.target.value : "";
        if(targetAttr == "Name") {
            this.referenceObj.Name = targetVal;
        }
        else if (targetAttr == "Address") {
            this.referenceObj.Address = targetVal;
        }
        else if (targetAttr == "Mobile_Number") {
            this.referenceObj.Mobile_Number = targetVal;
        }
        else if (targetAttr == "Relationship_With_Borrower") {
            this.referenceObj.Relationship_With_Borrower = targetVal;
        }                  
    }

    handleSave(event) {
        restricAccess({
            compName: 'relatedReferencesComponent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Reference',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    if(this.validateInputValidation(event)){
                        this.updateReferenceFld();          
                    } 
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    validateInputValidation(evt) {
        const allValid = [
            ...this.template.querySelectorAll('.validate'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    updateReferenceFld() {
        try {
            let messageForScenario = "";
            let referenceArrTOString = "";
            let fetchedReferenceFieldVal = getFieldValue(this.referncesData, REFERENCE_FIELD);
            console.log("fetchedReferenceFieldVal--"+fetchedReferenceFieldVal);       

            if(fetchedReferenceFieldVal === null || fetchedReferenceFieldVal === "") {
                messageForScenario = "Add Reference";
                this.referenceObj.IsActive = "true";
                this.referenceArr.push(this.referenceObj);
                referenceArrTOString = JSON.stringify(this.referenceArr);
            }
            else {
                let parseReferenceFldVal = JSON.parse(fetchedReferenceFieldVal);
                if(this.referenceScenario === "referenceEdit") {
                    let  editObj = this.editReference(parseReferenceFldVal);
                    messageForScenario  = "Edit Reference";
                    referenceArrTOString = JSON.stringify(editObj);
                    this.referenceScenario = "";
                }
                else {
                    this.referenceObj.IsActive = "true";
                    parseReferenceFldVal.push(this.referenceObj);
                    messageForScenario = "Add Reference";
                    referenceArrTOString = JSON.stringify(parseReferenceFldVal);
                }                  
            }   
            console.log('referenceArrTOString--'+referenceArrTOString);
        
            this.genericUpdateForReferenceFld(this.recordId, referenceArrTOString, messageForScenario);

            this.referenceArr          = [];
            this.referenceObj          = {};      
            this.addReferencesScreen   = false;
            this.addIcon               = true;
            this.viewRelatedReferences = true;
        }
        catch(e){
            console.error(e);
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
        
    }

    editReference(parseReferenceFldVal) {
        let editRef = parseReferenceFldVal.filter(oldRefData => {
            if(oldRefData.Mobile_Number === this.mobNoAsAIdForEdit) {
                let updRefData            =  oldRefData;
                updRefData.Name           =  this.referenceObj.hasOwnProperty('Name') ? this.referenceObj.Name : updRefData.Name ;
                updRefData.Address        =  this.referenceObj.hasOwnProperty('Address')  ? this.referenceObj.Address : updRefData.Address ;
                updRefData.Mobile_Number  =  this.referenceObj.hasOwnProperty('Mobile_Number') ? this.referenceObj.Mobile_Number : updRefData.Mobile_Number ;
                updRefData.Relationship_With_Borrower  =  this.referenceObj.hasOwnProperty('Relationship_With_Borrower') ? this.referenceObj.Relationship_With_Borrower : updRefData.Relationship_With_Borrower ;
                this.mobNoAsAIdForEdit    =  '';
                this.handleReset();
                return updRefData;
            } 
            else {
                return oldRefData;
            }          
        });
        return editRef;
    } 

    genericUpdateForReferenceFld(recordId, referenceArrTOString, scenario) {
        const fields = {};

        fields[ID_FIELD.fieldApiName]        = recordId;
        fields[REFERENCE_FIELD.fieldApiName] = referenceArrTOString;

        const recordInput = {
        fields: fields
        };

        updateRecord(recordInput).then(() => {
            let message = '';
            if(scenario === "Delete Reference") {
                message = "Reference Deleted Successfully";
            }
            else if(scenario === "Add Reference") {
                message = "Reference added Successfully";
            }
            else if(scenario === "Edit Reference") {
                message = "Reference updated Successfully";
            }
            this.showMessage('', message,'success', 'dismissable');
        })
        .catch(error => {     
            this.showMessage('Error updating record', error.body.message,'error', 'sticky');
        });
    }

    showMessage(title, message, variant, mode) {
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(event);
    }

    @api nextHandler() {       
       this.validationForReference();
        let Obj = {};
        if(this.checkStateForValidation) {
            Obj.next = false;
        }
        else {
            Obj.next = true;
        }
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
}