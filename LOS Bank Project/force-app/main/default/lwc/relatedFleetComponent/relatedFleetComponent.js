import { LightningElement, track, wire, api } from 'lwc';
import FLEET_OBJECT from '@salesforce/schema/Fleet__c';
import getFleets from '@salesforce/apex/RelatedFleetController.getFleets';
import saveFleet from '@salesforce/apex/RelatedFleetController.saveFleet';
import updateFleet from '@salesforce/apex/RelatedFleetController.updateFleet';
import getFleet from '@salesforce/apex/RelatedFleetController.getFleet';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
 //R2 SECTION 
import createCSVFleetRecords from '@salesforce/apex/RelatedFleetController.createCSVFleetRecords';
import createCollateralFleetRecords from '@salesforce/apex/RelatedFleetController.createCollateralFleetRecords';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import getBankRecords from '@salesforce/apex/RelatedFleetController.getBankRecords'
import { updateRecord } from 'lightning/uiRecordApi'
import ID_FIELD from '@salesforce/schema/Applicant__c.Id'; 
import CEFETCHED_FIELD from '@salesforce/schema/Applicant__c.isCollateralEnquiryFetched__c';
import downloadLink from '@salesforce/label/c.Fleet_Template_Download_Link';
import { toastWithMessage,validate,getVisibleFields } from 'c/lwcutilities';
import { loadScript } from 'lightning/platformResourceLoader';
import sheetjs from '@salesforce/resourceUrl/SheetJS';

//R2-2848
import TRACTOR_PRODUCT_CODES from '@salesforce/label/c.Tractor_Product_Codes';
import COMMERCIAL_PRODUCT_CODES from '@salesforce/label/c.Commercial_Product_Codes';
//R2-2848

let XLS = {};
export default class RelatedFleetComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false;
    @api spinnerImage;
    showMainSection = true;
    addNewFleet = false;
    showFleetInsertion = true;
    editFleet = false;
    fleetsLst = [];
    breReRunFields = [];
    fleetRecord = {};
    rltnshpWthBrwrOptions;
    mfgYearOptions = [];
    hpnStatusOptions;
    recordCount;
    editRecordId;
    errorOnChild;
    tenure = 0;
    @track recordSelected = {};
    label = { downloadLink };
    
    //R2 Section 
    loan;
    currentApplicantId;
    isLoanRecords=false;
    applicantList=[];
    isTractorOrCommercial;
    isTractor;
    isCommercial;
    isConstructionEq;
    @track isTrue = false;
    filesUploaded = [];
    file;
    fileName;
    fileContents;
    fileReader;
    content;
    showRelatedPicklist;
    @track isEditRestricted;
    isCE = false;
    isCV = false;
    MAX_FILE_SIZE = 1500000;
    gradeFleet = new Map();
    //R2-2848
    // productVal =['10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403','10501','10502','10503'];
    // commercialProd = ['10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403'];
    //R2-2848
    @wire(getObjectInfo, { objectApiName: FLEET_OBJECT })
    objectInfo;
    @track acceptedFormats = ['.xls', '.xlsx'];
    parsedData;
    recordStatus;

    // Dynamic Picklist added demo feedback
    typeVehicleOptions;
    // Dynamic Picklist added demo feedback

    // Applicants list 
    applicantListOptions = [];
    // Applicants list 
    applicantValue = '';
    relationDisabled = false;
    showNameField = false;
    showLoanFields = false;
    @wire(getPicklistValuesByRecordType, { objectApiName: FLEET_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            this.rltnshpWthBrwrOptions = data.picklistFieldValues.Relationship_with_borrower__c.values;
            this.hpnStatusOptions = data.picklistFieldValues.HPN_Status__c.values;
            this.typeVehicleOptions = data.picklistFieldValues.Type_of_Vehicle__c.values;
        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    ////R2-2848
    get productVal(){
        let arr = [];
        for(let i of TRACTOR_PRODUCT_CODES.split(',')){
            arr.push(i.trim());
        }
        for(let i of COMMERCIAL_PRODUCT_CODES.split(',')){
            arr.push(i.trim());
        }
        return arr;
    }
    get commercialProd(){
        let arr = [];
        for(let i of COMMERCIAL_PRODUCT_CODES.split(',')){
            arr.push(i.trim());
        }
        return arr;
    }
    ////R2-2848

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0) {   
            this.excelToJSON(uploadedFiles[0])
            this.filesUploaded = uploadedFiles;
            this.fileName = uploadedFiles[0].name;
        }
    }

    excelToJSON(file){
        var reader = new FileReader();
        reader.onload = event => {
            var data=event.target.result;
            var workbook=XLS.read(data, {
                type: 'binary'
            });
            var XL_row_object = XLS.utils.sheet_to_row_object_array(workbook.Sheets["DataUpload"]);
            this.parsedData = JSON.stringify(XL_row_object);
        };
        reader.onerror = function(ex) {
            this.error=ex;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while reading the file',
                    message: ex.message,
                    variant: 'error',
                }),
            );
        };
        reader.readAsBinaryString(file);
    }

    async connectedCallback() {
        this.getFleetRecords();
        this.getLoanBankRecords();
        this.isEditRestricted = await restricAccess({compName: 'relatedFleetComponent', loanId: this.recordId});
        Promise.all([
            loadScript(this, sheetjs)
        ]).then(() => {
            XLS = XLSX
        })
    }

    getLoanBankRecords(){
        getBankRecords({
            loanAppId: this.recordId
        }).then(data => {
            if (data) {
                this.isLoanRecords = data;
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }

    getFleetRecords() {
        getFleets({
            loanAppId: this.recordId
        })
        .then(data => {
            if (data) {
                if (data.hasOwnProperty('fltLst')) {
                    this.fleetsLst = data.fltLst;
                    this.recordCount = data.fltLst.length;
                } else {
                    this.recordCount = 0;
                    this.fleetsLst = undefined;
                }
                if (data.mfgYear.length > 0) {
                    data.mfgYear.sort();
                    this.mfgYearOptions = [];
                    data.mfgYear.forEach(element => {
                        this.mfgYearOptions.push({ label: element, value: element });
                    });
                }
                // R2 Ashish || R2-633 || START 
                if (data.hasOwnProperty('loanInstance')) {
                    if(data.loanInstance.Applicants__r){
                        this.handleApplicantListCreation(data.loanInstance.Applicants__r);
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'ERROR!',
                            message: 'Please create applicants before moving this screen',
                            variant: 'error',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(evt);
                    }

                    if(data.loanInstance.RecordType.Name == 'Construction Equipment'){
                        this.isCE = true;
                    }
                    if(data.loanInstance.RecordType.Name == 'Commercial Vehicle'){
                        this.isCV = true;
                    }
                    this.loan = data.loanInstance;
                    let currentProduct = data.loanInstance.Product__c;
                    let tractorProd =['10501','10502','10503'];
                    let CEProd =['10401','10402','10403'];
                    this.isTractorOrCommercial = this.productVal.includes(currentProduct) ? true : false;
                    this.isCommercial = this.commercialProd.includes(currentProduct) ? true : false;
                    this.isConstructionEq = CEProd.includes(currentProduct) ? true : false;
                    this.isTractor= tractorProd.includes(currentProduct) ? true : false;
                    this.gradeFleet.set('SFO-1','1');
                    this.gradeFleet.set('MFO-2-5','2');
                    this.gradeFleet.set('LFO-6+','6');
                    this.gradeFleet.set('Small','1');
                    this.gradeFleet.set('Medium','2');
                    this.gradeFleet.set('Large','6');
                    this.gradeFleet.set('Small-1','1');
                    this.gradeFleet.set('Medium-2-5','2');
                    this.gradeFleet.set('Large-6+','6');
                }
                if(data.hasOwnProperty('applicantList')){
                    this.applicantList = data.applicantList;
                }
            }
            //this.disableFieldsAsPerMetadata();
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }

    // Applicants list formation
    handleApplicantListCreation(applicants){
        this.applicantListOptions = [];
        for(let i of applicants){
            this.applicantListOptions.push({
                label : `${i.Complete_Name__c} - ${i.RecordType.Name}`,
                value : i.Id
            });
        }
        this.applicantListOptions.push({ label:'Others',value :'Others' });
    }
    // Applicants list formation
   
    handleValueChange(event) {
        //Parse Int removed
        this.fleetRecord[event.target.name] = event.target.value;
        if (event.target.name == 'HPN_Status__c'){
            if (event.target.value == 'Free'){
                this.showLoanFields = false;
                this.fleetRecord['Loan_Tenure__c'] = null;
                this.fleetRecord['Installment_Paid__c'] = null;
            } else{
                this.showLoanFields = true;
            }
        }
        if (this.isTractor || this.isCE || this.isCV){
            if (event.target.name == 'Relationship_with_borrower__c' && event.target.value == 'OTHERS'){
                this.showRelatedPicklist = true;
            }
            if (event.target.name == 'Fleet_owned_by__c'){
                this.breReRunFields.push('Fleet_owned_by__c')
            }
            if (event.target.name == 'Relationship_with_borrower__c'){
                this.breReRunFields.push('Relationship_with_borrower__c')
            }
            if (event.target.name == 'Type_of_Vehicle__c'){
                this.breReRunFields.push('Type_of_Vehicle__c')
            }
              // R2-2593 || Vehicle Number should be combination of alphabets and numbers
            if(event.target.name == 'Vehicle_Number__c'){
                let inputValue = event.target.value;
                if (!(/[a-zA-Z]/.test(inputValue) && /\d/.test(inputValue))) {
                    this.showMessage('Enter a combination of alphabets and numbers.', 'error');
                    return;
                }
            }
            //END
        }
        if(this.isCE || this.isCV){
            if(event.target.name == 'HPN_Status__c'){
                this.breReRunFields.push('HPN_Status__c')
            }
            if(event.target.name == 'Installment_Paid__c'){
                this.breReRunFields.push('Installment_Paid__c')
            }
            if(event.target.name == 'Loan_Tenure__c'){
                this.breReRunFields.push('Loan_Tenure__c')
            }
            if(event.target.name == 'MFG_Year__c'){
                this.breReRunFields.push('MFG_Year__c')
            }
        }
    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Fleet',strLoanId:this.recordId});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
        this.isLoading=false
    }

    handleFleetInformationClick() {
        this.addNewFleet = true;
        this.fleetRecord = {};
    }

    handleRecordInsertionCancel() {
        this.addNewFleet = false;
        this.fleetRecord = {};
    }

    handleRecordInsertionSave() {
        restricAccess({
            compName: 'relatedFleetComponent' ,loanId: this.recordId
        })
        .then(data => {
            if (data) {
                const evt = new ShowToastEvent({
                    title: 'Access Restricted',
                    message: 'You do not have access to save Fleet',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            } else{
                this.saveFleetDetails();
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }

    saveFleetDetails() {
        this.fleetRecord['Loan_Application__c'] = this.recordId;
        //SFAU-5289 - Samridhi
        if (parseInt(this.fleetRecord.Loan_Tenure__c) < parseInt(this.fleetRecord.Installment_Paid__c)) {
            this.showMessage('Installment Paid cannot be greater than Loan Tenure.', 'warning');
        }
        else {
             if (this.isTractor || this.isCE || this.isCV){
            // R2-2593 || Vehicle Number should be combination of alphabets and numbers    
            let inputValue = this.fleetRecord.Vehicle_Number__c;
                if (!(/[a-zA-Z]/.test(inputValue) && /\d/.test(inputValue))) {
                    this.showMessage('Vehicle Number should be a combination of alphabets and numbers.', 'error');
                    return;
                }
            }
            //END

            let inputFields = this.template.querySelectorAll(".validate");
            if (validate(inputFields)) {
                saveFleet({
                    fltRecord: this.fleetRecord
                })
                .then(data => {
                    this.addNewFleet = false;
                    this.getFleetRecords();
                    this.showMessage('Fleet created succesfully.', 'success');
                    this.fleetRecord = {};
                })
                .catch(error => {
                    console.log('error is ' + JSON.stringify(error));
                })
            }
        }
    }

    getFleetDetails(recordId) {
        getFleet({
            fltRecId: recordId
        })
        .then(data => {
            this.dispatchEvent(new CustomEvent('wizardevent', {
                detail: { value: recordId, name: 'Fleet', mode: '' }
            }));
            this.fleetRecord = data;
            let options = JSON.parse(JSON.stringify(this.applicantListOptions));
            const matchedApplicantOption = options.find(option => option.value === data.Applicant__c);
            // Extract the value if a match is found, otherwise set it to null
            const matchedApplicantValue = matchedApplicantOption ? matchedApplicantOption.value : null;
            this.applicantValue = matchedApplicantValue;
            if(this.applicantValue == null){
                this.applicantValue  ='Others';
                this.showNameField = true;
            }else{
                this.showNameField = false;
            }
            this.showMainSection = false;
            this.editFleet = true;
            if(data.Financial_Institution__c){
                setTimeout(() => {
                    this.prePopulateLookupFld();
                }, 200);
            }
            // R2 CHANGE || START
            if(data.HPN_Status__c && data.HPN_Status__c == 'Free'){
                this.showLoanFields = false;
            }else{
                this.showLoanFields = true;
            } 
            // END
            this.disableFieldsAsPerMetadata();

        })
        .catch(error => {
            console.log('error is ' +error);
        })
    }

    handleRowAction(event) {
        const recordId = event.currentTarget.dataset.id;
        const actionType = event.currentTarget.dataset.button;
        this.editRecordId = recordId;
        if (actionType == 'delete') {
            this.updateFleetRecord(recordId, actionType);
        } else if (actionType == 'edit') {
            this.getFleetDetails(recordId);
        }
    }

    updateFleetRecord(fltRecId, context) {
        restricAccess({
            compName: 'relatedFleetComponent' ,loanId: this.recordId
            })
            .then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to update Fleet',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                } else{
                     // R2-2593 || Vehicle Number should be combination of alphabets and numbers
                     if(context!='delete'){
                         if (this.isTractor || this.isCE || this.isCV){
                                let inputValue =this.fleetRecord.Vehicle_Number__c;
                                if (!(/[a-zA-Z]/.test(inputValue) && /\d/.test(inputValue))) {
                                this.showMessage('Vehicle Number should be a combination of alphabets and numbers.', 'error');
                                 return;
                                }
                            }
                        }
                    
                    //END

                    //SFAU-5289 - Samridhi
                    if (parseInt(this.fleetRecord.Loan_Tenure__c) < parseInt(this.fleetRecord.Installment_Paid__c)) {
                        this.showMessage('Installment Paid can not be greater than Loan Tenure.', 'warning');
                    } else {
                        if (this.fleetsLst[0].Loan_Application__r.LAN__c != null){
                            this.showMessage('Loan Has Disbursed Fleets cannot be edited.', 'error');
                        } else{
                            let inputFields = this.template.querySelectorAll(".validate");
                            if (validate(inputFields)) {
                            updateFleet({
                                fltRecId: fltRecId,
                                context: context,
                                fltRec: this.fleetRecord
                            })
                            .then(data => {
                                if (data) {
                                    this.getFleetRecords();
                                    if (context == 'delete') {
                                        this.showMessage('Fleet deleted successfully.', 'success');
                                    }
                                    if (context == 'edit') {
                                        this.showMessage('Fleet updated successfully.', 'success');
                                        this.getFleetRecords();
                                        this.showMainSection = true;
                                        this.editFleet = false;
                                    }
                                    checkMaterialFields({strScreen:'Fleet',strLoanId:this.recordId,lstFieldsAPI: this.breReRunFields}).then((data=>{
                                    })).catch((error=>{
            
                                    }))
                                }
                            })
                            .catch(error => {
                                console.log('error is ' + JSON.stringify(error));
                            })
                        }
                    }
                }
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }

    handleLookupSelect(event) {
        let selectedValue = event.detail.value;
        let fieldName = event.detail.fieldapi;
        if (selectedValue == undefined || selectedValue == '' || selectedValue == null) {
            this.fleetRecord[fieldName] = null;
        }
        else {
            this.fleetRecord[fieldName] = selectedValue;
        }
    }

    handleRecordCancel() {
        this.editFleet = false;
        this.showMainSection = true;
    }

    handleRecordUpdate() {
        this.updateFleetRecord(this.editRecordId, 'edit');
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    navigateToAppRecordPage(event) {
        this.navigateToRecordPage(event.currentTarget.dataset.id);
    }

    navigateToRecordPage(objectRecordid) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                objectApiName: 'Fleet__c',
                actionName: 'view'
            },
        });
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Loan_Application__c',
                relationshipApiName: 'Fleet__r',
                actionName: 'view'
            },
        });
    }

    setSelectedRecord() {
        this.recordSelected.Bank_Name__c = this.fleetRecord.Financial_Institution__r.Bank_Name__c;
    }

    prePopulateLookupFld() {
        this.setSelectedRecord();
        const objChild = this.template.querySelector(`[data-id='Financial_Institution__c']`);
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }

    //R2 || R2-633 || Updated the next handler to handle Tractor or Commercial Validations 
    @api async nextHandler() {
        let count = this.gradeFleet.get(this.loan.Sub_Grade__c)!=undefined ? this.gradeFleet.get(this.loan.Sub_Grade__c) : 1;
                if(this.isLoanRecords){
            let fleets = await getFleets({loanAppId: this.recordId})
            this.applicantList = fleets.applicantList;
            let isfetched =this.applicantList.every(applicant => applicant.isCollateralEnquiryFetched__c === true);
            if(!isfetched){
                this.showMessage('Please ensure that you have clicked the Fetch button for all applicants before proceeding further.', 'error');
                return;
            }
        }

        if(this.isTractor || this.isCommercial){
            if(this.isTractor){
                if(this.handleTractorValidations()){
                    const Obj = {};
                    //Obj.applicantRecord = this.applicantIdInput;
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                } else{
                    this.showMessage('At least one Fleet Record should be added to proceed further', 'error');
                }
            }else if(this.isCommercial){
                if( this.handleCVValidations()){
                    const Obj = {};
                    //Obj.applicantRecord = this.applicantIdInput;
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                }else{
                    this.showMessage('Atleast ' +count+' Fleet Records should be added to proceed further', 'error')
                }
            }
        }else{
           // if( this.fleetsLst!=undefined && this.fleetsLst.length >0 ){ //Existing code added in else part
                const Obj = {};
                //Obj.applicantRecord = this.applicantIdInput;
                this.errorOnChild = '';
                Obj.errorOnChild = this.errorOnChild;
                Obj.next = this.errorOnChild == '' ? true : false;
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
           /* }else{
                this.showMessage('At least one Fleet Record should be added to proceed further', 'error');
            }*/
        }
    }
   
    //R2 || R2-633 || START 
    handleCVValidations(){
        let result = false;
        // LCV/HCV/ICV and the grade is  Transporter
        if( (this.loan.Collateral_Type__c == '10103' || this.loan.Collateral_Type__c == '10104' || this.loan.Collateral_Type__c == '10134')  && this.loan.Customer_Grade__c == 'Transporter'  ){
            if( this.loan.Sub_Grade__c == 'SFO-1' &&   this.fleetsLst!=undefined && this.fleetsLst.length >= 1){
                return true;
            } else if(this.loan.Sub_Grade__c == 'MFO-2-5' &&  this.fleetsLst!=undefined &&  this.fleetsLst.length >= 2 ){
                return  true;
            } else if(this.loan.Sub_Grade__c == 'LFO-6+' &&  this.fleetsLst!=undefined && this.fleetsLst.length >= 6){
                return  true;
            } else {
                return false;
            }
        }
        // 3W,SCV,Car taxi and the grade is  Transporter
        else if((this.loan.Collateral_Type__c == '10106' || this.loan.Collateral_Type__c == '10107' || this.loan.Collateral_Type__c == '10105' || this.loan.Collateral_Type__c == '10108')  && this.loan.Customer_Grade__c == 'Transporter'){
            return  this.fleetsLst!=undefined && this.fleetsLst.length >= 1  ? true : false;
        } 
        // CE Sub grade Part 
        else if( this.isConstructionEq && this.loan.Customer_Grade__c == 'Hirer' ){ //|| this.loan.Customer_Grade__c == 'Contractor' || this.loan.Customer_Grade__c == 'Mine Owner'
            if( (this.loan.Sub_Grade__c == 'Small' || this.loan.Sub_Grade__c =='Small-1')&&  this.fleetsLst!=undefined && this.fleetsLst.length >= 1 ){
                return  true;
            } else if((this.loan.Sub_Grade__c == 'Medium' || this.loan.Sub_Grade__c =='Medium-2-5') &&  this.fleetsLst!=undefined &&  this.fleetsLst.length >= 2 ){
                return  true;
            } else if((this.loan.Sub_Grade__c == 'Large' || this.loan.Sub_Grade__c =='Large-6+') &&  this.fleetsLst!=undefined && this.fleetsLst.length >= 6){
                return  true;
            } else{
                return  false;
            }
        }
        else{
            return  true;
        }
    }

    handleChange(event){
        let picklistName = event.target.name;
        let applicantId = event.target.value;
        let applicantLst = this.applicantList;
        this.fleetRecord.Relationship_with_borrower__c =null;
        this.relationDisabled = false;
        this.showNameField = false;

        // Need to copy the realtionship from selected applicant
        if(applicantId!= 'Others'){
            applicantLst = applicantLst.filter(dataInstance => {
                return dataInstance.Id == applicantId;
              });
            if(applicantLst.length>0 && applicantLst[0].Relationship_with_applicant__c){
                let value= JSON.parse(JSON.stringify(applicantLst[0].Relationship_with_applicant__c));
                //let value = applicantLst[0].Relationship_with_applicant__c!=null ? applicantLst[0].Relationship_with_applicant__c :null;
                this.fleetRecord.Relationship_with_borrower__c = value!=null ? value.toUpperCase() : '';
                this.fleetRecord.Applicant__c = applicantId;
                this.fleetRecord.Name = applicantLst[0].Customer_Name__c+' '+'-'+' '+applicantLst[0].RecordType.Name;
                this.relationDisabled = true;
            }else{
                this.fleetRecord.Relationship_with_borrower__c ='';
                this.fleetRecord.Applicant__c = '';
                this.fleetRecord.Name = '';
                this.relationDisabled = false;
            }
        }else{
            this.showNameField = true;
        }
    }

    handleEnquiry(){
        //Call collateral enquiry api 
        this.createCollateralFleet();
    }

    createCollateralFleet(){
        this.isLoading = true;
        createCollateralFleetRecords({
            loanAppId: this.recordId,
            applicantId : this.currentApplicantId
        })
            .then(data => {
                if(data && data.length >0){
                    this.showMessage('Fetched Successfully', 'success');
                    this.getFleetRecords();
                }else{
                    this.showMessage('No Records Found', 'error');
                }
                this.updateApplicant();
                this.isLoading = false;
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    updateApplicant(){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.currentApplicantId;
        fields[CEFETCHED_FIELD.fieldApiName] = true;
        const recordInput = {
            fields
        };
        updateRecord(recordInput)
        .then(() => {
            console.log('updatedApplicantFetchedStatus');
        })
        .catch(error => {});
    }

    handleTractorValidations(){
        if(this.loan.Customer_Grade__c == 'Transporter' && this.loan.Original_Vehicle_Usage__c == 'Commercial'){
            if(  this.fleetsLst!=undefined && this.fleetsLst.length >0 ){
                return true;
            }else{
                return false;
            }
        }else{
            return true;
        }
    }

    get fleetOwnedOptions() {
        return [
            { label: 'Applicant', value: 'Applicant' },
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Guarantor', value: 'Guarantor' },
            { label: 'Other', value: 'Other' },
        ];
    }

    get relationOptions(){
        return [
            { label: 'Applicant', value: 'Applicant' },
            { label: 'Co-Applicant', value: 'Co-Applicant' },
            { label: 'Guarantor', value: 'Guarantor' }
            
        ];
    }

    handleRelationChange(event){
        let selectedVal = event.target.value;
        let applicantLst = this.applicantList;
        applicantLst = applicantLst.filter(dataInstance => {
            return dataInstance.RecordType.Name == selectedVal;
          });
        if(applicantLst.length>0){
            let value= JSON.parse(JSON.stringify(applicantLst[0].Relationship_with_applicant__c));
            this.fleetRecord.Relationship_with_borrower__c = value!=null ? value.toUpperCase() : '';
            this.showRelatedPicklist = false;
        }
    }

    handleSave() {
        if (this.parsedData) {
            this.uploadHelper();
        } else {
            this.fileName = 'Please select an excel file to upload!!';
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File size is too long',
                    message: 'File size is too long. Please upload another file to proceed',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
            return;
        }

        this.isLoading = true;
        this.saveToFile();
    }

    saveToFile() {
        this.recordStatus = undefined;
        createCSVFleetRecords({ base64Data: this.parsedData?.replaceAll('\\', ''), loanId: this.recordId })
        .then(result => {
            this.getFleetRecords();
            this.filesUploaded ='';
            this.fileName ='';
            this.showMainSection = true;
            this.addNewFleet = false;
            if (result) {
                let hasAtleastOneError = false;
                let recordStatus = JSON.parse(result);
                for (let each in recordStatus) {
                    if (recordStatus[each] != 'Success!') {
                        hasAtleastOneError = true;
                    }
                }
                if (hasAtleastOneError) {
                    this.recordStatus = recordStatus;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Partial or No Success',
                            message: 'One or more fleet rows failed to upload. Please see the detailed status in the table',
                            variant: 'warning',
                            mode: 'sticky'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'All fleet rows were uploaded successfully',
                            variant: 'success',
                            mode: 'dismissable'
                        })
                    );
                }
            }
            this.isLoading = false;
        })
        .catch(error => {
            console.log(error);
            this.showMessage('Please upload a valid file format', 'error');
            this.isLoading = false;
        });
    }
}