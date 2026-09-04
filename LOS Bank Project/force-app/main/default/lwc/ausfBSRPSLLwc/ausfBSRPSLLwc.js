import { LightningElement,api,track,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import getProfilingMaster from '@salesforce/apex/BSRPSLController.getProfilingMaster';
import getRelatedProfilingMaster from '@salesforce/apex/BSRPSLController.getRelatedProfilingMaster';
import getApplicants from '@salesforce/apex/BSRPSLController.getApplicants';
import getApplicantFinancialInfo from '@salesforce/apex/BSRPSLController.getSectorInfo';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PURPOSE_OF_LOAN from '@salesforce/schema/Loan_Application__c.Purpose_of_Loan__c';
import Loan_Amount__c from '@salesforce/schema/Loan_Application__c.Loan_Amount__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LOAN_APP_OBJECT from '@salesforce/schema/Loan_Application__c';
import Product__c from '@salesforce/schema/Loan_Application__c.Product__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveRecords from '@salesforce/apex/BSRPSLController.saveRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecords from '@salesforce/apex/BSRPSLController.getRecords';
import getRecordInfo from '@salesforce/apex/BSRPSLController.getRecordInfo';
import setValidationOnDocument from '@salesforce/apex/CreditVerification.setValidationOnDocument'
import { refreshApex } from '@salesforce/apex';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
const fields = [PURPOSE_OF_LOAN,Loan_Amount__c,Product__c];
// SFAU-5584
import deleteFunds from '@salesforce/apex/BSRPSLController.deleteFunds'
// SFAU-5584
import upsertData from '@salesforce/apex/BSRPSLController.upsertData'

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class AusfBSRPSLLwc extends LightningElement {

@api recordId;
@api objectName;
@api objectApiName;
isloading = false;
error;
applicantId;
sectorOptions = [];
industryOptions = [];
subIndustryOptions = [];
occupationOptions = [];
pslCodeOptions = [];
pslClassificationTypeOptions = [];
pslClassificationCategoryOptions = [];
pslSegmentOptions = [];
loanPurposeOptions = [{label:'Purchase of Vehicle', value:'Purchase of Vehicle'}];
endUseVehicleOptions = [{label:'Personal', value:'Personal'}];
occupationGroupOptions = [];
subGroupOptions = [];
groupSelectOptions = [];
relativeOptions=[];
udyamStatusValueOptions = [{label:'Received',value:'Received'},{label:'Pending', value:'Pending'}];
sectorEditValue;
industryEditValue;
subIndustryEditValue;
occupationEditValue;
physicallyChallenged;
isMSME=false;
gender;
state;
@track pslCodeValue;
@track pslClassificationTypeValue;
@track pslClassificationCategoryValue;
@track pslSegmentValue;
@track udyamStatusValue;
@track weakerReasonValue;
@track employmentType;
@track sectorValue;
@track industryValue;
@track industrySubtypeValue;
@track occupationValue;
@track caste;
@track religion;
@track udyamRegistrationNo;
@track weakerSectionValue;
@track loanPurposeValue='';
@track landHoldingAcre;
@track landHoldingHector;
@track smallMarginalValue;
@track isAgriLandAvailable;
@track industry;
@track isPMVisible = false;
@track isEquipmentVisible = false;
@track isOthersVisible = false;
@track isActivityVisible = false;
@track isRelativeVisible = false;
@track documnetType;
@track activityValue;
@track landOwnerValue;
@track relativeValue;
@track endOfUse;
@track groupValue;
@track subGroupValue;
@track occupationGroupValue;
@track organisationType;
@track organisation;
@track borrowerCat;
@track investmentPM;
@track investmentEquip;
@track others;
@track bsrRecordId;
@track pslRecordId;
@track relativeValue;
@track recordTypeName;
@track isNotTwoWheeler = true;
assignmentId='';
financeAppData = {};
applicantData = {};
bsrPSLData = {};
loanAppData = {};
//Var for conditional rendering		
showLandHolding = false;		
isReasonForMultipleVisible = false;
@track isUdyamVisible=false;
@track isEditRestricted
// SFAU-5584 declaration start 
endUseOfFundOptions = [{label:'Personal', value:'Personal'}];
endUseOfFundsValue = [] ;
expectedValidationValue;
selectedOptions = [];
showEndUseOfProducts;
isPersonalCOW;
@track isDelete=false
@track recordCount=0
@track hideSection=false
@track endUseOfFunds=[]
displayButtons=true 
keyIndex=0;
fundsMap=new Map()
@track readOnly=true
@track totalAmount=0
// SFAU-5584 declaration End
loadStyles() {
    loadStyle(this, opsAccordion);
}

// NOTE : Renderedcallback() only works for child components to parent DOM
renderedCallback(){
    console.log('inside renderCallback');
    this.loadStyles();
}

@wire(getObjectInfo, { objectApiName: LOAN_APP_OBJECT })loanAppObj;

_loanPurpose;
@wire(getPicklistValues,{
            recordTypeId: '$loanAppObj.data.defaultRecordTypeId', 
            fieldApiName: PURPOSE_OF_LOAN
})loanPurpose({data,error}){
    //R2-2416
    if(data){
        this._loanPurpose = data;
        let key = data.controllerValues[this.productVal];
        this.loanPurposeOptions = data.values.filter(opt => opt.validFor.includes(key));
        if(this.loanPurposeVal){
            this.loanPurposeValue = this.loanPurposeVal;
        } 
    }
    
}

get _loanPurposeOptions(){
    const data = this._loanPurpose;
    const key = this._loanPurpose?.controllerValues?.[this.productVal];
    return !!this.loanPurposeOptions?.length ? this.loanPurposeOptions : data?.values.filter(opt => opt.validFor.includes(key));
}

@wire(getRecord, { recordId: '$recordId', fields})
loanObj;

get loanAmount(){
    return getFieldValue(this.loanObj.data,Loan_Amount__c);
}

get productVal(){
    return getFieldValue(this.loanObj.data,Product__c);
}

get loanPurposeVal(){
    return getFieldValue(this.loanObj.data,PURPOSE_OF_LOAN);
}


// SFAU-5584
get expectedValidationOptions(){
    return [
        {label : 'CA certificate letter',value: 'CA certificate letter'},
        {label : 'Copy of Bank statement',value: 'Copy of Bank statement'},
        {label : 'Bill copies /Invoices',value: 'Bill copies /Invoices'},
        {label : 'Visit Photograph',value: 'Visit Photograph'}
    ]
}
// SFAU-5584    
handleOpenSection(){
    this.hideSection=false
}
// SFAU-5584
handleHideSection(){
    this.hideSection=true
}
// SFAU-5584
handleAddNewFund(){
    this.keyIndex++
    this.key=this.keyIndex;
    var newRecord;
    if(this.isPersonalCOW){
        newRecord = {key:this.key, Loan_Application__c:this.recordId, isChecked:false,Label__c: 'Personal'};
    }else{
        newRecord = {key:this.key, Loan_Application__c:this.recordId, isChecked:false};
}
    this.fundsMap.set(this.keyIndex, newRecord)
    this.endUseOfFunds = Array.from(this.fundsMap.values())
}
// SFAU-5584
handleEdit(){
    this.readOnly=false
}

// SFAU-5584
showToastMessage(titleValue, messageValue, variantValue){

    const event = new ShowToastEvent({
        title: titleValue,
        message: messageValue,
        variant: variantValue
    });
    this.dispatchEvent(event);

}
// SFAU-5584
updateModifiedData(data){
    this.keyIndex=0
    this.showToastMessage('Success','Records Updated Successfully','success')
    this.fundsMap=new Map();
    this.endUseOfFunds = []
    if(data.endUseofFundRecords && data.endUseofFundRecords.length>0){
        this.keyIndex=0
        data.endUseofFundRecords.forEach(input => {
            input.key=this.keyIndex
            input.isChecked=false
            this.fundsMap.set(this.keyIndex, input)
            this.keyIndex++
    });
    this.readOnly=true
    this.endUseOfFunds = Array.from(this.fundsMap.values())  
    this.recordCount = this.endUseOfFunds.length
    refreshApex(this.endUseOfFunds);
    this.calculateTotals()
    }
}
// SFAU-5584
handleDeleteAction(event){

    this.endUseOfFunds=Array.from(this.fundsMap.values())
    this.checkedCount=0
    this.isDelete=false
    var updateDeletedRecordsWithId=[]
    var updateNonDeletedRecordsWithIds=[]
    var updateNonDeletedRecordsWithoutIds=[]

    this.endUseOfFunds.forEach(element=>{
        if(element.isChecked){
            if(element.Id){
                updateDeletedRecordsWithId.push(element.Id)
            }
            this.fundsMap.delete(element.key)
        }else{
            if(element.Id)
                updateNonDeletedRecordsWithIds.push(element)
            else{
                updateNonDeletedRecordsWithoutIds.push(element)
            }
        }
    })

    this.endUseOfFunds=Array.from(this.fundsMap.values())

    if(updateDeletedRecordsWithId.length>0){
        this.isloading = true;
        deleteFunds({recordIds: updateDeletedRecordsWithId, loanId: this.recordId}).then((data)=>{
            this.updateModifiedData(data)
            updateNonDeletedRecordsWithoutIds.forEach(input=>{
                //if(!input.Id)
                this.fundsMap.set(input.key, input)

            })
            this.isloading = false;
            this.endUseOfFunds=Array.from(this.fundsMap.values())
            
        }).catch(error => {
            this.isloading = false;
            console.log('error in sectorInfo-->' + JSON.stringify(error));
        })
    }else{
        this.fundsMap=new Map()
        this.keyIndex=0
        updateNonDeletedRecordsWithIds.forEach(input=>{
            input.key=this.keyIndex
            this.keyIndex++
            this.fundsMap.set(input.key, input)
        })
        updateNonDeletedRecordsWithoutIds.forEach(input=>{
            input.key=this.keyIndex
            this.keyIndex++
            this.fundsMap.set(input.key, input)
        })
        this.endUseOfFunds=Array.from(this.fundsMap.values())
    }
    this.recordCount = this.endUseOfFunds.length
    this.calculateTotals() 
}

// SFAU-5584
calculateTotals(){
    this.totalAmount=0
        this.endUseOfFunds.forEach(element=>{
            if(element.Amount__c)
                this.totalAmount=parseFloat(element.Amount__c)+this.totalAmount
        })
}


 // Custom Spinner settings
 async spinnerImageMethod() {
    if(this.spinnerImage == undefined){
        this.spinnerImage = await getSpinnerImage(this.recordId);
    }
}

async handleImageSpinnerSetting(){
    await this.spinnerImageMethod();
  }

// Custom Spinner settings

connectedCallback(){
    this.handleImageSpinnerSetting();
    console.log('record id '+this.recordId);
    if(this.objectApiName!='Loan_Application__c'){
        getRecordInfo({
            objectName : this.objectApiName,
            id : this.recordId
        })
        .then(data =>{
            this.assignmentId = this.recordId;
            console.log('data '+JSON.stringify(data));
            this.recordId = data;
            this.loanAppData['Id'] = this.recordId;
            this.getApplicantsData(this.recordId);
            this.getRecords();
            this.callRestrictEdit()//4733
            refreshApex(this.loanObj);
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
        })
    }
    else{
        this.loanAppData['Id'] = this.recordId;
        this.getApplicantsData(this.recordId);
        this.getRecords();
        this.callRestrictEdit()//4733
    }

}

callRestrictEdit(){
    restricAccess({
        compName: 'ausfBSRPSLLwc' ,loanId: this.recordId
        })
        .then(data => {
            this.isEditRestricted = data;
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
}

getRecords(){
    getRecords({
        loanId:this.recordId
    })
    .then(response => {
        let data = response.bsrPslDetails;
        this.endUseVehicleOptions = response.vehileUseOptions?.Vehicle_use__c ?? [];
         /*  SFAU-5584 Start */
         this.endUseOfFundOptions = response.endUseOfFundOptions;
         this.showEndUseOfProducts = response.isCowProduct;
         this.isPersonalCOW = response.isPersonalCOW;
         if(this.isPersonalCOW){
            this.showEndUseOfProducts = false;
         }
         this.fundsMap = new Map()
         this.keyIndex=0
         if(response.endUseofFundRecords && response.endUseofFundRecords,length > 0){
             this.keyIndex=0;
             response.endUseofFundRecords.forEach(input => {
                 input.isChecked=false
                 input.key =this.keyIndex;
                 this.fundsMap.set(input.key, input)
                 this.keyIndex++
             });
             this.endUseOfFunds = Array.from(this.fundsMap.values())  
             this.recordCount = this.endUseOfFunds.length
             this.totalRecords=0
             this.calculateTotals()
         }
          /*  SFAU-5584 End */
        //if(JSON.stringify(data).length())
        console.log(JSON.stringify(data));
        if(JSON.stringify(data).includes('Id')){
            console.log('data[0].recordId '+data[0].RecordType.Name);
            if(data[0].RecordType.Name=='BSR'){
                this.bsrRecordId = data[0].Id;
                this.pslRecordId = data[1].Id;
                this.endOfUse = data[1].End_use_of_Vehicle__c;
                
                this.pslCodeValue = data[1].PSL_Code__c;
                console.log('psl classification type '+data[1].PSL_Classification_Type__c);
                this.pslClassificationTypeValue = data[1].PSL_Classification_Type__c;
                this.pslClassificationCategoryValue = data[1].PSL_Classification_Category__c;
                this.pslSegmentValue = data[1].PSL_Segment__c;
                this.weakerSectionValue = data[1].Weaker_Section__c;
                this.weakerReasonValue = data[1].Reasons_for_Multiple_Weaker_Section__c;
                this.landHoldingHector = data[1].Land_Area_in_Hector__c;
                this.relativeValue = data[1].If_Applicant_Relative__c;
                this.landOwnerValue = data[1].Land_Ownership__c;
                
                this.groupValue = data[0].Group__c;
                this.subGroupValue = data[0].Sub_Group__c;
                this.occupationGroupValue = data[0].Occupation_Group__c;
                this.checkConditions('Borrower_Category__c',data[0].Borrower_Category__c);
                if(data[1].Agri_Land_Available__c=='Yes'){
                    this.showLandHolding = true;
                }
            }
            else{
                this.bsrRecordId = data[1].Id;
                this.pslRecordId = data[0].Id;

                this.pslCodeValue = data[0].PSL_Code__c;
                console.log('psl classification type '+data[0].PSL_Classification_Type__c);
                this.pslClassificationTypeValue = data[0].PSL_Classification_Type__c;
                this.pslClassificationCategoryValue = data[0].PSL_Classification_Category__c;
                this.pslSegmentValue = data[0].PSL_Segment__c;
                this.weakerSectionValue = data[0].Weaker_Section__c;
                this.weakerReasonValue = data[0].Reasons_for_Multiple_Weaker_Section__c;
                this.landHoldingHector = data[0].Land_Area_in_Hector__c;
                this.relativeValue = data[0].If_Applicant_Relative__c;
                this.landOwnerValue = data[0].Land_Ownership__c;
               
                this.groupValue = data[1].Group__c;
                this.subGroupValue = data[1].Sub_Group__c;
                this.occupationGroupValue = data[1].Occupation_Group__c;
                this.checkConditions('Borrower_Category__c',data[1].Borrower_Category__c);
                if(data[0].Agri_Land_Available__c=='Yes'){
                    this.showLandHolding = true;
                }
            }
            if(this.weakerReasonValue?.includes('Multiple')){
                this.isReasonForMultipleVisible = true;
            }
            /*if(this.data[1].Agri_Land_Available__c=='Yes'){
                this.showLandHolding = true;
            }*/
            if(this.pslClassificationTypeValue=='PSL-MSME'){
                this.isUdyamVisible = true;
            }
            if(this.pslClassificationTypeValue=='PSL-Agri'){
                this.isActivityVisible = true;
            }
            if(this.landOwnerValue=='Applicant Relative'){
                this.isRelativeVisible = true;
            }
        }
    })
    .catch(error => {
        console.log('error in getrecords' + error);
    })
}
getWeakerSectionInfo(){
    var reasons = '';
    this.weakerReasonValue = '';
    this.weakerSectionValue = '';
    if(this.caste=='SC' || this.caste=='ST'){
        this.weakerSectionValue = 'Weaker By Caste';
        console.log('Weaker section '+this.weakerSectionValue);
        reasons = 'Weaker By Caste; ';
    }
    else if(this.weakerSectionValue == 'Weaker By Caste'){
        this.weakerSectionValue = '';
    }
    if(this.pslClassificationCategoryValue=='SMF-Marginal Farmer' || this.pslClassificationCategoryValue == 'SMF- Small Farmer') {
        this.weakerSectionValue = 'Weaker By Land';
        console.log('Weaker section '+this.weakerSectionValue);
        reasons = reasons + 'Weaker By Land; ';
    }
    if(this.physicallyChallenged=='Yes'){
        this.weakerSectionValue = 'Weaker By Disability';
        console.log('Weaker section '+this.weakerSectionValue);
        reasons = reasons + ' Weaker By Disability; ';
    }
    if(this.religion?.toUpperCase()?.includes('BUDDHIST') || this.religion?.toUpperCase()?.includes('ZOROASTRIAN') || (this.religion?.toUpperCase()?.includes('MUSLIM') && this.state!='Jammu and Kashmir') || 
        (this.religion?.toUpperCase()?.includes('SIKH') && this.state!='Punjab') || (this.religion?.toUpperCase()?.includes('CHRISTIAN') && this.state!='Goa') || 
        (this.gender=='Female' && this.loanAmount<=100000)){
        this.weakerSectionValue = 'Weaker By Minority';
        console.log('Weaker section '+this.weakerSectionValue);
        reasons = reasons + 'Weaker By Minority;';
    }
    console.log('reasons '+reasons +' split '+reasons.split(";").length);
    if(reasons.split(";").length>2){
        this.weakerSectionValue = 'Weaker By Multiple';
        this.weakerReasonValue = reasons;
    }
    if(this.weakerSectionValue?.includes('Multiple')){
        this.isReasonForMultipleVisible = true;
    }
    else{
        this.isReasonForMultipleVisible = false;
    }
    console.log('Udyam reg no '+this.udyamRegistrationNo);
    console.log('Applicant-->' + this.applicantId);
}
getApplicantsData(applId) {
    console.log('applId '+this.recordId);
    getApplicants({
            applicantId: this.recordId
        })
        .then(data => {
            
                console.log('Applicant data '+JSON.stringify(data));
                this.applicantId = data[0].Id;
                this.applicantData['Id'] = this.applicantId;
                this.caste = data[0].Caste__c;
                this.religion = data[0].Religion__c;
                this.udyamRegistrationNo = data[0].UDYAM_Registration_Number__c;
                this.physicallyChallenged = data[0].Phsically_challenged__c;
                this.gender = data[0].Gender__c;
                this.employmentType = data[0].Type_Of_Employment__c;
                if(data[0].Addresses__r!=null){
                    this.state = data[0].Addresses__r[0].State__c;
                    console.log('address '+JSON.stringify(data[0].Addresses__r));
                }
                this.recordTypeName = data[0].Loan__r.RecordType.Name;
                if(this.recordTypeName=='Two Wheeler'){
                    this.isNotTwoWheeler = false;
                }
                console.log('RecordType.Name '+this.recordTypeName);
                console.log('state '+this.state);
                console.log('loan amount '+this.loanAmount);
                console.log('purpose of loan '+this.loanPurposeVal);
                console.log('options '+JSON.stringify(this.loanPurpose));

                /*let key = this.loanPurpose.data.controllerValues[this.productVal];

                this.loanPurposeOptions = this.loanPurpose.data.values.filter(opt => opt.validFor.includes(key));*///R2-2416 - moved the logic to wired method
                //this.loanPurposeOptions = this.loanPurpose.data.values;
               // this.loanPurposeValue = this.loanPurposeVal;

                if(this.loanPurposeVal){
                    this.loanPurposeValue = this.loanPurposeVal;
                } 

              //  console.log('value: ',data[0].Loan__r.Purpose_of_Loan__c);
              //  this.loanPurposeOptions = this.loanPurposeOptions ? this.loanPurposeOptions.add()
               // this.loanPurposeValue = data[0].Loan__r.Purpose_of_Loan__c;

                this.getWeakerSectionInfo();
                console.log('Udyam reg no '+this.udyamRegistrationNo);
                console.log('Applicant-->' + this.applicantId);
                let options = [];
                options.push({
                    label:'Self',
                    value:'Self'
                });
                options.push({
                    label:'Brother',
                    value:'Brother'
                });
                options.push({
                    label:'Son',
                    value:'Son'
                });
                
                if(this.gender=='Male'){
                    options.push({
                        label:'Father',
                        value:'Father'
                    });
                    options.push({
                        label:'Mother',
                        value:'Mother'
                    });
                    options.push({
                        label:'Grand Father',
                        value:'Grand Father'
                    });
                    options.push({
                        label:'Grand Mother',
                        value:'Grand Mother'
                    });
                    options.push({
                        label:'Wife',
                        value:'Wife'
                    });
                }
                else{
                    options.push({
                        label:'Father-In-Law',
                        value:'Father-In-Law'
                    });
                    options.push({
                        label:'Mother-In-Law',
                        value:'Mother-In-Law'
                    });
                    options.push({
                        label:'Husband',
                        value:'Husband'
                    });
                }
                this.relativeOptions = options;
            
            this.getSectorInfo(this.applicantId);
            //this.getApplicantFinancialDetails(this.applicantId);
            
            
        })
        .catch(error => {
            console.log('error in getApplicantsData' + JSON.stringify(error));
            this.getSectorInfo(this.applicantId);
        })
}
getApplicantFinancialDetails(applicantId){
    getApplicantFinancialInfo({
        applicantId: applicantId
    })
    .then(data => {
        if (data) {
            console.log('AppFinanceData-->' + JSON.stringify(this.data));
            this.financeAppData['Id']=data[0].Id;
            this.employmentType = data[0].Type_Of_Employment__c; 
            this.sectorValue = data[0].Sector__c;
            
                this.handlegetRelatedPicklistValues('Sector__c', this.sectorValue, 'RT - Sector', 'RT - Industry',data[0].Type_Of_Employment__c);
                this.industryValue = data[0].Industry__c;
            
                this.handlegetRelatedPicklistValues('Industry__c', this.industryValue, 'RT - Industry', 'RT - Sub Industry',data[0].Type_Of_Employment__c + '~' + data[0].Sector__c);
                this.industrySubtypeValue = data[0].Sub_Industry__c;
            
                this.handlegetRelatedPicklistValues('Sub_Industry__c', this.industrySubtypeValue, 'RT - Sub Industry', 'RT - Occupation',data[0].Type_Of_Employment__c + '~' + data[0].Sector__c + '~' + data[0].Industry__c);
                this.occupationValue = data[0].Occupation__c;  
                
                this.handlegetRelatedPicklistValues('Occupation__c', this.occupationValue, 'RT - Occupation', 'PSL_Code__c',data[0].Type_Of_Employment__c + '~' + data[0].Sector__c + '~' + data[0].Industry__c + '~' + data[0].Sub_Industry__c);
                this.handlegetRelatedPicklistValues('PSL_Code__c', this.pslCodeValue, 'PSL_Code__c', 'PSL_Classification_Type__c','');
                                this.handlegetRelatedPicklistValues('PSL_Classification_Type__c', this.pslClassificationTypeValue,  'PSL_Classification_Type__c', 'Group__c','');
                this.handlegetRelatedPicklistValues('PSL_Classification_Type__c', this.pslClassificationTypeValue, 'PSL_Classification_Type__c', 'PSL_Classification_Category__c','');
//SFAU-5374
                this.handlegetRelatedPicklistValues('PSL_Classification_Category__c', this.pslClassificationCategoryValue,  'PSL_Classification_Category__c', 'PSL_Segment__c','');
                this.handlegetRelatedPicklistValues('Group__c', this.groupValue,  'Group__c', 'Sub_Group__c','');
                this.handlegetRelatedPicklistValues('Sub_Group__c', this.subGroupValue,  'Sub_Group__c', 'Occupation_Group__c','');
        }
    })
    .catch(error => {
        console.log('error in AppFinanceData' + error);

    })
}
    
getSectorInfo(applicantId){
    getProfilingMaster({
        applicantId: applicantId,
        employmentType: this.employmentType
    }).then(data => {
        console.log('sectorInfo-->' + JSON.stringify(data));
        this.recordTypeId = data?.[0]?.RecordTypeId;
        let options = [];
        for (var key in data) {
            options.push({
                label: data[key].Name,
                value: data[key].Name
            });
        }
        this.sectorOptions = options;
        this.getApplicantFinancialDetails(applicantId);
        this.isloading = false;
    })
    .catch(error => {
        this.isloading = false;
        console.log('error in sectorInfo-->' + JSON.stringify(error));
    })
}

    handlegetRelatedPicklistValues(picklistName, picklistValue, passType, retType,queryParams) {
        this.isloading = true;
        getRelatedProfilingMaster({
                selectedValue: picklistValue,
                passingType: passType,
                returnType: retType,
                pslClassType: this.pslClassificationTypeValue,
                recordTypeName: this.recordTypeName,
                queryParams: queryParams
            }).then(data => {
                console.log('Related profiling master-->' + JSON.stringify(data));
                let pslOptions=[];
                if (picklistName == 'Occupation__c') {
                    for (var key in data) {
                        if((pslOptions.length==0 || !pslOptions.find(o => o.label == data[key].PSL_Description__c)) && data[key].PSL_Description__c!=null){
                        pslOptions.push({
                            label: data[key].PSL_Description__c,
                            value: data[key].PSL_Code__c
                        });
                    }
                    }
                    this.pslCodeOptions = pslOptions;
                }
                //let pslOptions=[];
                if (picklistName == 'PSL_Code__c') {
                    for (var key in data) {
                        if((pslOptions.length==0 || !pslOptions.find(o => o.label == data[key].PSL_Classification_Type__c))&&data[key].PSL_Classification_Type__c!=null){
                        pslOptions.push({
                            label: data[key].PSL_Classification_Type__c,
                            value: data[key].PSL_Classification_Type__c
                        });
                    }
                    }
                    this.pslClassificationTypeOptions = pslOptions;
                }
                let categoryOptions = [];
                if (picklistName == 'PSL_Classification_Type__c' && retType=='PSL_Classification_Category__c') {
                    for (var key in data) {
                        if((categoryOptions.length==0 || !categoryOptions.find(o => o.label == data[key].PSL_Classification_Category__c)) && data[key].PSL_Classification_Category__c!=null){
                            categoryOptions.push({
                                label: data[key].PSL_Classification_Category__c,
                                value: data[key].PSL_Classification_Category__c
                            });
                        }
                    }
                    this.pslClassificationCategoryOptions = categoryOptions;
                }
                if (picklistName == 'PSL_Classification_Type__c' && retType=='Group__c'){
                    let groupOptions = [];
                    for (var key in data) {
                        if((groupOptions.length==0 || !groupOptions.find(o => o.label == data[key].Group__c)) && data[key].Group__c!=null){
                            groupOptions.push({
                                label: data[key].Group__c,
                                value: data[key].Group__c
                            })
                        }
                    }
                    this.groupSelectOptions = groupOptions;
                }
                //SFAU-5374
                if (picklistName == 'PSL_Classification_Category__c') {
                    pslOptions = [];
                    for (var key in data) {
                        if((pslOptions.length==0 || !pslOptions.find(o => o.label == data[key].PSL_Segment__c) && data[key].PSL_Segment__c!=null)){
                            pslOptions.push({
                                label: data[key].PSL_Segment__c,
                                value: data[key].PSL_Segment__c
                            });
                        }
                    /*if((groupOptions.length==0 || !groupOptions.find(o => o.label == data[key].Group__c)) && data[key].Group__c!=null){
                        groupOptions.push({
                            label: data[key].Group__c,
                            value: data[key].Group__c
                        })
                    }*/
                    }
                    //this.groupSelectOptions = groupOptions;
                    this.pslSegmentOptions = pslOptions;
                }
                if (picklistName == 'Group__c') {
                    for (var key in data) {
                        if((pslOptions.length==0 || !pslOptions.find(o => o.label == data[key].Sub_Group__c)) && data[key].Sub_Group__c!=null){
                            pslOptions.push({
                                label: data[key].Sub_Group__c,
                                value: data[key].Sub_Group__c
                            });
                        }
                        
                    }
                    this.subGroupOptions = pslOptions;
                }
                if (picklistName == 'Sub_Group__c') {
                    for (var key in data) {
                        if((pslOptions.length==0 || !pslOptions.find(o => o.label == data[key].Occupation_Group__c)) && data[key].Occupation_Group__c!=null){
                            pslOptions.push({
                                label: data[key].Occupation_Group__c,
                                value: data[key].Occupation_Group__c
                            });
                        }
                    }
                    this.occupationGroupOptions = pslOptions;
                }
                let options = [];
                for (var key in data) {
                    if((options.length==0 || !options.find(o => o.label == data[key].Name)) && data[key].Name!=null){
                        options.push({
                            label: data[key].Name,
                            value: data[key].Name
                        });
                    }
                }
                if (picklistName == 'Sector__c') {
                    this.industryOptions = options;
                }
                if (picklistName == 'Industry__c') {
                    this.subIndustryOptions = options;
                }
                if (picklistName == 'Sub_Industry__c') {
                    this.occupationOptions = options;
                }
                this.isloading = false;
            })
            .catch(error => {
                this.isloading = false;
                console.log('error in getRelatedProfilingMaster-->' + JSON.stringify(error));
            })
    }

    //SFAU-5584
    handleFunds(event){
            var accesskey = parseInt(event.target.accessKey)
            var record = this.fundsMap.get(accesskey)
            if(event.target.name==='isChecked'){
                record[event.target.name]=event.target.checked
                this.checkedCount=event.target.checked==true?this.checkedCount+1:this.checkedCount-1
                this.isDelete=this.checkedCount==0?false:true
            }else if(event.target.name==='Label__c'){
                record[event.target.name]=event.target.value
            }else{
                record[event.target.name]=event.target.value
            }
            this.fundsMap.set(accesskey, record)
            this.endUseOfFunds = Array.from(this.fundsMap.values()) 
            if(event.target.name=='Amount__c'){
                this.calculateTotals()
            }
    }

    handleChange(event) {
        console.log('on change '+event.detail.name);
        console.log(JSON.stringify(event.target.fieldname));
        console.log(JSON.stringify(event.detail));
            let picklistName = event.target.name;
            let picklistValue = event.target.value;

            console.log('name ' + event.target.name + 'value ' + event.target.value);
            if(event.target.fieldName=='Weaker_Section__c'){
                this.weakerSectionValue = event.detail.value;
                if(this.weakerSectionValue?.includes('Multiple')){
                    this.isReasonForMultipleVisible = true;
                }
                else{
                    this.isReasonForMultipleVisible = false;
                }
            }
            if(event.target.fieldName=='Land_Ownership__c'){
                if(event.detail.value=='Applicant Relative'){
                    this.isRelativeVisible = true;
                }
                else{
                    this.isRelativeVisible = false;
                }
            }
            if(event.target.name=='Caste__c'){
                this.caste = event.target.value;
                this.getWeakerSectionInfo();
            }
            if(event.target.name=='Religion__c'){
                this.religion = event.target.value;
                this.getWeakerSectionInfo();
            }
            if (picklistName == 'Sector__c') { // now we need to pass the sector name and name of the picklist to get as options
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Sector', 'RT - Industry',this.employmentType);
                this.industryValue = '';
                this.industrySubtypeValue = '';
                this.occupationValue = '';
                this.sectorEditValue = picklistValue;
                this.sectorValue = picklistValue;
            }
            if (picklistName == 'Industry__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Industry', 'RT - Sub Industry',this.employmentType + '~' + this.sectorValue);
                this.industryEditValue = picklistValue;
                this.industryValue = picklistValue;
                this.industrySubtypeValue = '';
                this.occupationValue = '';
            }
            if (picklistName == 'Sub_Industry__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Sub Industry', 'RT - Occupation',this.employmentType + '~' + this.sectorValue + '~' + this.industryValue);
                this.subIndustryEditValue = picklistValue;
                this.industrySubtypeValue = picklistValue;
                this.occupationValue = '';
            }
            if (picklistName == 'Occupation__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Occupation', 'PSL_Code__c',this.employmentType + '~' + this.sectorValue + '~' + this.industryValue + '~' + this.industrySubtypeValue);
                this.occupationEditValue = picklistValue;
                this.occupationValue = picklistValue;
            }
            if (picklistName == 'PSL_Code__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'PSL_Code__c', 'PSL_Classification_Type__c','');
                this.pslCodeValue = picklistValue;
            }
            //SFAU-5374: PSL Segment to be dependent on PSL Classification Category
            if (picklistName == 'PSL_Classification_Category__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'PSL_Classification_Category__c', 'PSL_Segment__c','');
                this.pslClassificationCategoryValue = picklistValue;
            }
            if (picklistName == 'PSL_Classification_Type__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'PSL_Classification_Type__c', 'Group__c','');
                this.pslClassificationTypeValue = picklistValue;
                if(this.pslClassificationTypeValue=='PSL-MSME'){
                    this.isUdyamVisible = true;
                }
                else{
                    this.isUdyamVisible = false;
                }
                if(this.pslClassificationTypeValue=='PSL-Agri'){
                    this.isActivityVisible = true;
                }
                else{
                    this.isActivityVisible = false;
                }
            }
            if (picklistName == 'PSL_Classification_Type__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'PSL_Classification_Type__c', 'PSL_Classification_Category__c','');
                this.pslClassificationTypeValue = picklistValue;
            }
            if (picklistName == 'Group__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'Group__c', 'Sub_Group__c','');
                this.groupValue = picklistValue;
            }
            if (picklistName == 'Sub_Group__c') {
                this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'Sub_Group__c', 'Occupation_Group__c','');
            }
            if (picklistName == 'PSL_Classification_Category__c') {
                this.pslClassificationCategoryValue = picklistValue;
                this.getWeakerSectionInfo();
                /*if(picklistValue=='SMF-Marginal Farmer' || picklistValue == 'SMF- Small Farmer') {
                    if(this.weakerSectionValue == '' ){
                        this.weakerSectionValue = 'Weaker By Land';
                    }
                    else if(!this.weakerSectionValue.includes('Land')){
                        this.weakerSectionValue = 'Weaker By Multiple';
                        this.weakerReasonValue = this.weakerReasonValue + ';Weaker By Multiple';
                    }
                }*/
            }
            if(event.target.fieldName=='Land_Holding_in_acre__c'){
                console.log('here '+event.detail.value);
                if(event.detail.value==''){
                    this.landHoldingAcre = 0.00;
                }
                var hector = (event.detail.value/2.471).toFixed(2);
                this.landHoldingHector = hector;
                if(event.detail.value<=2.47){
                    console.log('< 2.47');
                    this.smallMarginalValue = 'Marginal Farmer';
                }
                if(event.detail.value>2.47 && event.detail.value<=4.94){
                    this.smallMarginalValue = 'Small Farmer';
                }
                if(event.detail.value>4.94){
                    this.smallMarginalValue = 'Other than SMF';
                }

            }
            this.checkConditions(event.target.fieldName,event.detail.value);
        
    }
    checkConditions(fieldName,fieldValue){
        if(fieldName=='Agri_Land_Available__c' && fieldValue=='Yes'){
            this.industry = 'Farmers ( Agriculture and allied activities)';
            this.showLandHolding = true;
        }
        else if(fieldName=='Agri_Land_Available__c'){
            this.showLandHolding = false;
        }
        if(fieldName=='Borrower_Category__c' && (fieldValue=='Micro (Manufacturing ) Enterprises' || fieldValue=='Small (Manufacturing) Enterprises' || fieldValue=='Medium (Manufacturing) Enterprises' || fieldValue=='Large (Manufacturing) Enterprises')){
            this.isPMVisible = true;
        }
        else if(fieldName=='Borrower_Category__c' && (fieldValue=='Micro (Service) Enterprises' || fieldValue=='Small (Service) Enterprises' || fieldValue=='Medium (Service) Enterprises' || fieldValue=='Large (Service) Enterprises')){
            this.isEquipmentVisible = true;
        }
        else if(fieldName=='Borrower_Category__c' && fieldValue=='Others'){
            this.isOthersVisible = true;
        }
        else if(fieldName=='Borrower_Category__c'){
            this.isPMVisible = false;
            this.isEquipmentVisible = false;
            this.isOthersVisible = false;
        }
    }
    saveRecord(){
        if(this.isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to save BSRPSL',
                variant: 'error',
                mode : 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        let isValid=true;
        
        let errors='';
        let valErrors = '';
        //SFAU-5584
        const duaLists = this.template.querySelectorAll('lightning-dual-listbox');
        const elements2 = this.template.querySelectorAll('lightning-combobox');
        duaLists.forEach( input => {
            if(input.name == 'End_Use_Of_Funds__c' && input.value && input.value.length > 0){
                this.bsrPSLData[input.name]=input.value.join(";");
            }else if(input.name == 'End_Use_Of_Funds__c'){
                input.setCustomValidity("Value is required");
                    valErrors = valErrors + input.name;
                    if(errors?.length>0){
                        errors = errors + ','+input.dataset.name;
                    }
                    else{
                        errors = errors+input.dataset.name;
                    }
                    isValid = false;
            }else{
                input.setCustomValidity("");
            }
            input.reportValidity();
        })
        elements2.forEach( input => {
            console.log('lightning-combobox element input-->'+input.name);
            console.log('lightning-combobox element value input-->'+input.value); 
            console.log('input '+JSON.stringify(input.dataset));
            if(input.name=='Sector__c' || input.name=='Industry__c' || input.name=='Sub_Industry__c' || input.name=='Occupation__c'){
                this.financeAppData[input.name] = input.value;
            }
            if(input.name=='PSL_Code__c' ||  input.name=='End_use_of_Vehicle__c' || input.name=='PSL_Classification_Type__c' || input.name=='PSL_Classification_Category__c' || input.name=='PSL_Segment__c' ||
                input.name=='Group__c' || input.name=='Sub_Group__c' || input.name=='Occupation_Group__c' || input.name=='If_Applicant_Relative__c'){
                this.bsrPSLData[input.name]=input.value;
            }
            if(input.name=='Purpose_of_Loan__c'){
                this.loanAppData[input.name]=input.value;
            }
            
            /*if(input.name=='Udyam_Status__c' && this.bsrPSLData['PSL_Classification_Type__c']=='PSL-MSME'){
                console.log('inside validation');
                if(input.value=='' || input.value==null || input.value==='undefined') {
                    input.setCustomValidity("Udyam Status value is required");
                    isValid = false;
                }
                else{
                    input.setCustomValidity('');
                }
                input.reportValidity();
            }*/
            if(input.name=='PSL_Code__c'  || input.name=='PSL_Classification_Type__c' || input.name=='PSL_Classification_Category__c' || input.name=='Purpose_of_Loan__c' || 
            input.name=='Group__c' || input.name=='Sub_Group__c' || input.name=='Occupation_Group__c'){
            console.log('inside validation 4');
            if((this.recordTypeName=='Two Wheeler' && (input.name=='Group__c' || input.name=='Sub_Group__c' || input.name=='Occupation_Group__c')) || 
                this.recordTypeName!='Two Wheeler'){
                if(input.value=='' || input.value==null || input.value==='undefined') {
                    input.setCustomValidity("Value is required");
                    valErrors = valErrors + input.name;
                    if(errors?.length>0){
                        errors = errors + ','+input.dataset.name;
                    }
                    else{
                        errors = errors+input.dataset.name;
                    }
                    isValid = false;
                }
                else{
                    input.setCustomValidity('');
                }
                input.reportValidity();
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
            
        }
            
            
        });
            const elements = this.template.querySelectorAll('lightning-input-field');
            elements.forEach( input => {
                console.log('lightning-input-field element input-->'+input.name);
                console.log('lightning-input-field element value input-->'+input.value);
                console.log('label   '+input.label);
                var name = input.name;
                this.bsrPSLData[name]=input.value;
                if(this.recordTypeName!='Two Wheeler'){
                    if(input.name=='Reasons_for_Multiple_Weaker_Section__c' && this.bsrPSLData['Weaker_Section__c']=='Weaker By Multiple'){
                        console.log('inside validation 2');
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = 'Reasons_for_Multiple_Weaker_Section__c,';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                }
                
                if(this.recordTypeName!='Two Wheeler'){
                    if(input.name=='Land_Holding_in_acre__c' && this.bsrPSLData['Agri_Land_Available__c']=='Yes'){
                        console.log('inside validation 6');
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = valErrors + 'Land_Holding_in_acre__c,';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                }

                if(this.recordTypeName!='Two Wheeler'){
                    if(input.name=='Udyam_Status__c' && this.bsrPSLData['PSL_Classification_Type__c']=='PSL-MSME'){
                        console.log('inside udyam validation');
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = valErrors + 'Udyam_Status__c, ';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                }
                if(input.name=='Organisation_Type__c' || input.name=='Organisation__c' || input.name=='Industry__c' || 
                    input.name=='Borrower_Category__c'  || input.name=='Agri_Land_Available__c'){
                    console.log('inside validation 3');
                    if((this.recordTypeName=='Two Wheeler' && (input.name=='Organisation_Type__c' || input.name=='Organisation__c' || input.name=='Industry__c' || input.name=='Borrower_Category__c'))) 
                    {
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = valErrors + input.name+',';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                    else if(this.recordTypeName!='Two Wheeler'){
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = valErrors + input.name+',';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                }
                
                if((input.name=='Investment_in_P_M__c' && this.bsrPSLData['Industry__c']=='Manufacturing Enterprises (Industries)')) {
                    if((input.name=='Investment_in_Equipment__c' || this.bsrPSLData['Industry__c']=='Business/Trade and Service Enterprises') || 
                        (input.name=='Others__c' || this.bsrPSLData['Industry__c']=='Others')){
                        console.log('inside validation 5');
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            isValid = false;
                            valErrors = valErrors + input.name+',';
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                    }
                }
            });
            console.log('BSR-PSL '+JSON.stringify(this.bsrPSLData));
            const elements1 = this.template.querySelectorAll('lightning-input');
            elements1.forEach( input => {
                console.log('lightning-input element input-->'+input.name);
                console.log('lightning-input element value input-->'+input.value);
                if(input.name=='UDYAM_Registration_Number__c' || input.name=='Caste__c' || input.name=='Religion__c'){
                    this.applicantData[input.name] = input.value;
                }
                if(input.name=='Land_Area_in_Hector__c'){
                    this.bsrPSLData[input.name] = input.value;
                }
                if(this.recordTypeName!='Two Wheeler'){
                    if(input.name=='UDYAM_Registration_Number__c' && this.bsrPSLData['Udyam_Status__c']=='Received'){
                        console.log('inside validation 2');
                        if(input.value=='' || input.value==null || input.value==='undefined') {
                            input.setCustomValidity("Value is required");
                            isValid = false;
                            valErrors = valErrors + input.name;
                            if(errors?.length>0){
                                errors = errors + ','+input.dataset.name;
                            }
                            else{
                                errors = errors+input.dataset.name;
                            }
                        }
                        else{
                            input.setCustomValidity('');
                        }
                        input.reportValidity();
                    }
                }
                /*if(input.name=='Caste__c' || input.name=='Religion__c'){
                    console.log('inside validation 4');
                    if(input.value=='' || input.value==null || input.value==='undefined') {
                        input.setCustomValidity("Value is required");
                        isValid = false;
                        valErrors = valErrors + input.name;
                        if(errors?.length>0){
                            errors = errors + ','+input.dataset.name;
                        }
                        else{
                            errors = errors+input.dataset.name;
                        }
                    }
                    else{
                        input.setCustomValidity('');
                    }
                    input.reportValidity();
                }*/
            });
            console.log('val errors '+valErrors);
            console.log('errors '+errors);
            if(valErrors!=''){
                const event = new ShowToastEvent({
                    title: 'Validation Error',
                    message:'Please fill all the mandatory fields: '+errors,
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            }
            else{
            saveRecords({
                bsrPslData: this.bsrPSLData,
                applicantData: this.applicantData,
                financialAppData: this.financeAppData,
                loanAppData: this.loanAppData,
                assignmentId: this.assignmentId 
            }).then(data => {
                console.log(JSON.stringify(data));
                if(data=='Success'){
                    setValidationOnDocument({documentType:'PSL', loanApplicationId:this.loanAppData.Id}).then((data=>{
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message:'Record Saved Successfully',
                            variant:'Success'
                        });
                        this.dispatchEvent(event);
                    })).catch((error=>{
                        console.log('error '+JSON.stringify(error));
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: error.body.pageErrors[0].message,
                            variant:'Error',
                            mode : 'sticky'
                        });
                        this.dispatchEvent(event);
                    }))
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message:data,
                        variant:'error',
                        mode:'sticky'
                    });
                    this.dispatchEvent(event);
                }
                
                
                
            })
            .catch(error => {
                this.isloading = false;
                message = 'Error in saving record';
                console.log('error in saving record-->' + JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Error in saving record',
                    variant:'Error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            })
        }
            
    }
    handleSave() {
        restricAccess({
            compName: 'ausfBSRPSLLwc' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save BSRPSL',
                        variant: 'error',
                        mode : 'sticky'
                    });
                    this.dispatchEvent(evt);
                }else{
                    //this.saveRecord();
                    //SFAU-5584
                    if(this.handleValidations()){
                        this.isloading = true;
                        this.endUseOfFunds=Array.from(this.fundsMap.values())
                        upsertData({records: this.endUseOfFunds, loanId: this.recordId}).then((data)=>{
                            this.updateModifiedData(data);
                            this.isloading = false;
                        }).catch((error)=>{
                            this.showToastMessage('Error',error.body.message,'error')
                            this.isloading = false;
                        })
                    }else{
                        this.showToastMessage('Error','Total amount should be equal to loan amount. : ' + this.loanAmount,'error')
                    }
                    //SFAU-5584
                }
            })
            .catch(error => {
                this.isloading = false;
                console.log('error is ' + JSON.stringify(error));
            })
    }

    //SFAU-5584
    handleValidations(){
        if(this.loanAmount == this.totalAmount || this.isPersonalCOW){
            return true;
        }
        return false;
    }

}