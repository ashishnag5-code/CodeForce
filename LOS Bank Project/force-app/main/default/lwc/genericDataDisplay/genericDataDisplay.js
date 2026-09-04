import { LightningElement, track, api } from 'lwc';
import getMetadataRecords from '@salesforce/apex/GenericDataDisplayController.getMetadataRecords'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class GenericDataDisplay extends LightningElement {

    @api label
    @api displayVerificationButtons;
    @api isCallFromOpsKYCScreen = false;
    //isVerified=false
    @api cpvDocuments
    @api identifierDocuments
    @track defaultLabelForMatch
    score;
    @api 
    get matchScore(){
        return this.score;
    }
    set matchScore(value){
        this.score=value
        if(!this.score){
            this.noMatch=true
        }
        else if(this.score==-101){
            this.noMatch=true
            this.defaultLabelForMatch='NA'
            /*this.event = setTimeout(() => {
                this.template.querySelector('[data-id="cpvSpinner"]').classList.add('slds-hide')
                this.template.querySelector('[data-id="matchResponse"]').classList.add('slds-text-color_destructive')
            }, 100);*/
            

        }else{
            this.goodMatch = this.score>80?true:false
            this.noMatch=false
        }
    }
    showScore=false
    goodMatch=false
    noMatch=false
    imageCont =false;

    @api apiResponse
    @api aadharResponse = {
        'UID': '874983094', //Not storing
        'DOB': '28-02-1995', //Applicant
        'Name': 'Shanaya Kapoor',
        'Gender': 'Female',
        'Care of': 'D/O Anil Kapoor', //D/O - Father's name else W/O- Spouse name
        'Country': 'India', //Country
        'District': 'EAST DELHI', //City
        'Address': 'Chintamani Nagar Waad - 6', //Address line 1
        'Pincode': '110053', 
        'State': 'DELHI',
        'Village Town City': 'NA', //Taluka
    };

    @api panResponse={};

    panDummyResponse = {
        'Title':'Ms',
        'First Name':'Shanaya',
        'Last Name':'Kapoor',
        'Status':'Existing and Valid',
        'Seeding':'Y',
    };

    breResponse = {
        'STP':'',
        'Scheme' : 'Supreme',
        'Loan Amount' : '500000',
        'Tenure' : '48 months',
        'ROI' : '8%'
    }

    @api displayType;

    @api type;
    @track dataValues = [];
    applicant = [];
    @api defaultMatch ='Address Match';
    
    /*connectedCallback() {
            console.log('displayType:', this.displayType);
            this.response = (this.displayType == 'aadhaar') ? {...this.aadharResponse} : {...this.panDummyResponse};
            console.log('response:', JSON.stringify(this.response));
            for (var key in this.response) {
                this.dataValues.push({ value: this.response[key], key: key }); 
            }
    }*/

    connectedCallback() {
       
        if(this.cpvDocuments && this.matchScore!=-101){
            this.defaultLabelForMatch = this.defaultMatch+' is in Progress';
        }

        if(this.displayType!='Gas Bill Details' && this.displayType!='Electricity Bill Details' && this.displayType!='PNG Bill Details'){
            
            if(!this.displayType){
                this.displayType='Applicant KYC Details'
            }
            console.log('showing data');
            if (this.displayType == 'BRE Details') {  // this.displayType == 'aadhaar' || this.displayType == 'pan'
                // this.response = (this.displayType == 'aadhaar') ? {...this.aadharResponse} : (this.displayType == 'pan' ? {...this.panDummyResponse} : {...this.breResponse});
                this.response   = {...this.breResponse};
                for (var key in this.response) {
                    this.dataValues.push({ value: this.response[key], label: key, fieldName: key, show: true }); 
                }
                console.log('response:', JSON.stringify(this.dataValues));
            }else if(this.displayType =='Match Details'){
                this.showScore=true;
                if(!this.matchScore){
                    this.noMatch=true
                }else{
                    this.goodMatch = this.matchScore>80?true:false
                    this.noMatch=false
    
                }
            }
            else {
                this.response = this.panResponse.Response;
                this.format = this.panResponse.metadata;
//                console.log('Response-- '+JSON.stringify(this.panResponse.Response));
 //               console.log('metadata-- '+this.panResponse.metadata);
    
                for (var key in this.format) {
                    let imageVal = "";
                    let current = this.format[key];
                    console.log('key is '+key);
                    let val = this.response[current.JSON_Key__c];
                    let jsonKey = current.JSON_Key__c;         
                    let checkObj = this.checkInnerKeyOfObj(jsonKey);
                    if(JSON.stringify(checkObj) !== "{}" && checkObj.state == true && ( checkObj.imageCont || checkObj.value)) {
                        val = checkObj.value;
                        imageVal = checkObj.imageCont;
                    }                    
                    this.dataValues.push({ label: current.MasterLabel, value: val, fieldName: current.API_Name__c, show: current.Display_on_UI__c, imageCont : imageVal });
                }
                console.log("this.dataValues-- "+JSON.stringify(this.dataValues));
    
            }
            if(this.displayType == 'aadhaar'){
                this.displayType='Aadhar Card Details'
            }
            if(this.displayType == 'PAN'){
                this.displayType='PAN Card Details'
            }
            if(this.displayType.includes('Voter')){
                this.displayType = 'Voter Card Details'
            }
        }
        else{
            getMetadataRecords({type: this.type}).then((result)=>{
                console.log('bill response '+JSON.stringify(this.apiResponse))
                var billResponse = new Map(Object.entries(this.apiResponse))
                console.log('bill response '+JSON.stringify(billResponse))
                result.forEach(element => {
                    this.dataValues.push({ value: billResponse.get(element.JSON_Key__c), label: element.MasterLabel, fieldName: element.JSON_Key__c, show: true }); 
    
                });
                this.showScore=true
                if(!this.matchScore || this.matchScore==-101){
                    this.noMatch=true
                    /*this.event = setTimeout(() => {
                        this.template.querySelector('[data-id="cpvSpinner"]').classList.add('slds-hide')
                        this.template.querySelector('[data-id="matchResponse"]').classList.add('slds-text-color_destructive')
                    }, 100);*/
                }else{
                    this.goodMatch = this.matchScore>80?true:false
                    this.noMatch=false
    
                }
                
            })
        } 
        
        if(this.cpvDocuments || this.identifierDocuments){
            this.displayVerificationButtons=true
        }
        
    }

    checkInnerKeyOfObj(jsonKey) {
        let checkDotInJSONKey  = jsonKey.includes('.') ? true : false;
        let obj = {};
        if(checkDotInJSONKey) {
            let splitByDot = jsonKey.split('.');
            let firstSplit = splitByDot[0];
            if(this.response.hasOwnProperty(firstSplit)) {
                let secondSplit = splitByDot[1];
                let objCheck    = this.response[firstSplit];
                if(Array.isArray(objCheck)) {
                    for(let innerKey of this.response[firstSplit]) {
                        obj.state = true;
                        if(secondSplit.includes('image')) {
                            obj.imageCont = innerKey[secondSplit];
                        }
                        else {                           
                            obj.value = innerKey[secondSplit];
                            obj.imageCont = "";
                        }
                    } 
                }
                else if(typeof objCheck === 'object' && objCheck !== null) {
                    if(objCheck.hasOwnProperty(secondSplit)) {
                        obj.state = true;
                        if(secondSplit.includes('image')) {
                            obj.imageCont = objCheck[secondSplit];
                        }
                        else {
                            obj.value = objCheck[secondSplit];
                            obj.imageCont = "";
                        }                      
                    }
                }                                     
            }
        }
        else {
            if(jsonKey.includes('image')) {
                obj.state = true;
                obj.imageCont = this.response[jsonKey];
                obj.value = "";
            }
        }       
        return obj;
    }

    handleBack() {
        console.log('back button is clicked');
        // this.dataValues.forEach(setValues);

        //  console.log('applicant: ', this.applicant);
        //  console.log('applicant: ', JSON.stringify(this.applicant));
        this.dispatchEvent(new CustomEvent('back'));
    }

    /*handleChange(event){
        if(event.target.name=='cpvDocVerified'){
            this.isVerified=event.target.checked;
        }
    }*/

    handleNotVerified(){
        if(this.cpvDocuments){
            this.dispatchEvent(new CustomEvent('notverified',{
                detail:false
            }));
        }else{
            this.dispatchEvent(new CustomEvent('back'));
        }
        
    }

    handleVerified(){
        this.dispatchEvent(new CustomEvent('verified',{
            detail:true
        }));
    }

    setValues(current) {
        this.applicant[current.fieldName] = current.value;
        console.log(this.applicant);
    }
}