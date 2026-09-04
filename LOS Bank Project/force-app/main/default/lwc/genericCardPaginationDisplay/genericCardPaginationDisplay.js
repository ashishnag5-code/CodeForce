import { LightningElement, api, track } from 'lwc';
import updateSelectedScheme from '@salesforce/apex/BreOutputScreenController.updateSelectedScheme';
//import getAssignedScheme from '@salesforce/apex/BreOutputScreenController.getAssignedScheme';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import LightningConfirm from "lightning/confirm";
import LightningAlert from "lightning/alert";
import { NavigationMixin } from "lightning/navigation";
import LightningPrompt from "lightning/prompt";

export default class GenericCardPaginationDisplay extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectList;
    @api cardTitle;
    @api enableSelection;
    @api isDeclineResponse;
    @api schemeAddDetails;
    @api schemeDeviations;
    @api breResponseId;
    @api loanSchemeCode;
    @api disableshemeselection;
    @track isSchemeUpdated=false;
    objDataList = [];
    counter = 0;
    disbaleNext = false;
    disbalePrev = false;
    fiInitiationDetailsArray = [];
    uwCriteriasArray = [];
    subjectivityMessagesArray = [];
    deviationDetailsArray = [];
    showFiInitiationDetails = false;
    showUwCriterias = false;
    showSubjectivityMsgs = false;
    showDeviationDetails = false;
    @track selectedScheme = [];
    isChecked = false;
    isDisabled = false;
    @api displayuwcriteria = false;
    genericUrlPath = "";
    isSchemeChecked = false;
    @track clickedButtonLabel = 'Show Details';
    @track showHideSchemeButton = false;
    @track showSchemaDetails = false;
    schemeAddvalues;
    showSchemeAdd=false;
    showReasonIsNSTP=false;
    @track showReasonIsSTP = false;
    eligibilityRules = [];
    schemeDecision
    appSchemeDecision
    schemeName;
    loanAmt;
    tenure;
    IRR;
    LTV;
    processingFee;
    schemId;
    otherSchemesArray=[];
    eligibleSchemesArray=[];
 

  /* handleConfirmClick() {
        this.isSchemeChecked = true;
        const result = LightningConfirm.open({
            message: "Please confirm if you want to update the Scheme and move to the next Stage?",
            variant: "default", // headerless
            label: "Update Scheme"
        });

        //Confirm has been closed

        //result is true if OK was clicked
        if (result) {
            this.updateScheme();
            
        } else {
            //and false if cancel was clicked
            this.isSchemeChecked = false;
            //this.handleErrorAlertClick();
        }
    }*/
    handleConfirmClick() {
        const result =  LightningPrompt.open({
          //  message: "Please confirm if you want to update the Scheme and move to the next Stage?",
             message: "Add Remarks",
            variant: "default", // headerless
            label: "Update Scheme"
        }).then((value) => {

            if (value) {
                // do something with the value
                this.handleSuccessAlertClick(value);      
                if (result) {
                    this.updateScheme();             
                } 
            }
            else if(value == ''){
                //and false if cancel was clicked
                this.isSchemeChecked = false;
               this.CheckRemarksValue();
              console.log('value::',value);
              console.log('value::',result);
            } else{
               // this.handleErrorAlertClick();
            }
        });
        //Confirm has been closed

        //result is true if OK was clicked
       
    }

    hideSchemeDetails(){
        this.showSchemeAdd=false;
    }

    displayDetails(event) {


        console.log(event.target.dataset.scheme);
        console.log(this.objectList[this.counter]);
        console.log('schemeAddDetails', this.schemeAddDetails[0].value);

        var clickedScheme = event.target.dataset.scheme;
        this.deviationDetailsArray = [];
        if(clickedScheme.indexOf('(Eligible)')!=-1){

            var splitStr = clickedScheme.split('(Eligible)');
            if(splitStr.length>0)
            clickedScheme = splitStr[0].trim();
        }

        if(clickedScheme.indexOf('(Not Eligible)')!=-1){

            var splitStr = clickedScheme.split('(Not Eligible)');
            if(splitStr.length>0)
            clickedScheme = splitStr[0].trim();
        }


        for(var i = 0; i < this.schemeAddDetails.length; i++){ 

            if(this.schemeAddDetails[i].key != undefined && clickedScheme == this.schemeAddDetails[i].key.trim()){

                this.schemeAddvalues = this.schemeAddDetails[i].value;
                this.schemeName = this.schemeAddvalues["Scheme Name"];
                this.schemeName = this.schemeAddvalues["Scheme Name"];
                this.schemeDecision =  this.schemeAddvalues["Scheme Decision"];
                this.loanAmt = this.schemeAddvalues["Max Eligibile Loan Amount"];
                this.eligibilityRules = this.schemeAddvalues["eligibilityRules"];
                this.tenure = this.schemeAddvalues["Max Eligibile Tenure"]
                this.IRR = this.schemeAddvalues["Final IRR"]
                this.LTV = this.schemeAddvalues["Max LTV"]
                this.processingFee = this.schemeAddvalues["Final Processing Fee"]
                this.appSchemeDecision = this.schemeAddvalues["appSchemeDecision"]
              

            if(this.eligibilityRules !=undefined){

                let tempER = [];
                  for (var j = 0; j < this.eligibilityRules.length; j++) {
                    var tempArr={};
          
                    tempArr['RuleLevel'] = this.eligibilityRules[j]['Rule Level'];
                    tempArr['ReasonText'] = this.eligibilityRules[j]['ReasonText'];
                    tempER.push(tempArr);
                   
                  }

                  if(tempER.length !=0){
                    this.eligibilityRules = tempER;
                  }
                }
                
                if (this.schemeDecision!='undefined' && this.eligibilityRules != undefined && this.eligibilityRules.length>0) {
                    this.showReasonIsSTP=true;
                }
                else {
                    this.showReasonIsSTP=false;
                }

                if((this.previousClickedScheme != this.schemeName) || this.previousClickedScheme==null){
                     this.showSchemeAdd = true;
                     this.previousClickedScheme = this.schemeName;
                }
                else 
                    this.showSchemeAdd =  !this.showSchemeAdd
                 
            }

           
        } 


        for(let index=0;index<this.schemeDeviations.length;index++){

            if(this.schemeDeviations[index].key != undefined && clickedScheme == this.schemeDeviations[index].key.trim()){
                var Wrapperobject = {};
                 let deviationsArray = this.schemeDeviations[index].value;
                 var tempDevArr = {};
                 let tempER = [];
                 for(let j=0;j< deviationsArray.length;j++){
          
                    tempDevArr['DeviationType'] = deviationsArray[j]['Rule Level'];
                    tempDevArr['variance'] = undefined;  
                    if(deviationsArray[index]['variance']!=undefined || deviationsArray[j]['variance']!=null)
                        tempDevArr['variance'] = deviationsArray[j]['variance'];
                    tempDevArr['Level'] = deviationsArray[j]['Override Authority'];
                    let cloneUser = Object.assign({}, tempDevArr);
                    tempER.push(cloneUser);
                    
                }
                if(tempDevArr.length !=0){
                    this.enableSelection=true;
                    this.deviationsDetails = tempER;
                    this.showDeviationDetails = true;
                    this.deviationDetailsArray.push(...this.deviationsDetails);
                }
            }
        }

        if(this.schemeDecision!='undefined' && this.deviationDetailsArray != undefined && this.deviationDetailsArray.length>0) {
            this.showReasonIsNSTP=true;
        }
        else {
            this.showReasonIsNSTP=false;
        }
    
    }


   /* async handleSuccessAlertClick() {
        await LightningAlert.open({
            message: `You clicked "Ok"`,
            theme: "success",
            label: "Success!"
        });
    }*/

    async handleSuccessAlertClick(value) {
        this.remarks = value;
    }
    

     handleErrorAlertClick() {
         LightningAlert.open({
            message: 'You clicked "Cancel"',
            theme: "error",
            label: "Error!"
        });
    }

    CheckRemarksValue() {
         LightningAlert.open({
            message: "Please Enter Remarks",
            theme: "error",
            label: "Error!"
        });
    }

    connectedCallback() {
        console.log('this.objectList', JSON.stringify(this.objectList));
        console.log('isDeclineResponse', this.isDeclineResponse);
        if (this.objectList) {
            this.handleObjDataList();
        }
        console.log('displayuwcriteria' + this.displayuwcriteria);
        this.setUrlPath();
        console.log('this.loanSchemeCode' + this.loanSchemeCode);

       this.isDisabled = this.disableshemeselection;


    }

    getUpdatedScheme(){
        /*
        console.log('getUpdatedScheme');
        getAssignedScheme({recordId: this.recordId}).then((result)=>{
            this.isSchemeUpdated=result[0].scheme_updated__c;
            }).catch(error => {
                this.error = error;
                this.isloading = false;
            });
        */
    }

    setUrlPath() {
        if (this.cardTitle == "Applicant Details") {
            this.genericUrlPath = My_Resource + `/ausfIcons/Applicant-Details.png`;
        }
        else if (this.cardTitle == "FI required at") {
            this.genericUrlPath = My_Resource + `/ausfIcons/FI-Initiated.png`;
        }
        else if (this.cardTitle == "UW Criteria") {
            this.genericUrlPath = My_Resource + `/ausfIcons/UW-Criteria.png`;
        }
        else if (this.cardTitle == "Subjectivity Messages") {
            this.genericUrlPath = My_Resource + `/ausfIcons/Subjectivity-Message.png`;
        }
        else if (this.cardTitle == "Deviation Details") {
            this.genericUrlPath = My_Resource + `/ausfIcons/Deviation-Details.png`;
        }
        else if (this.cardTitle == "Eligible Schemes") {
            this.genericUrlPath = My_Resource + `/ausfIcons/Eligible-Scheme.png`;
            this.showSchemaDetails=true;
            this.getUpdatedScheme();
        }
    }

    handleObjDataList() {
        console.log('this.counter', this.counter);
        console.log('this.objectList', JSON.stringify(this.objectList[this.counter]));
        this.showFiInitiationDetails = false;
        this.showUwCriterias = false;
        this.showSubjectivityMsgs = false;
        this.showDeviationDetails = false;
        this.fiInitiationDetailsArray = [];
        this.uwCriteriasArray = [];
        this.subjectivityMessagesArray = [];
        this.deviationDetailsArray = [];
        console.log('this.subjectivityMessagesArray1', JSON.stringify(this.subjectivityMessagesArray));
        if (this.objectList != undefined && this.objectList != '')
            this.objectList = JSON.parse(JSON.stringify(this.objectList));
        for (const key in this.objectList[this.counter]) {
            const val = typeof this.objectList[this.counter][key] === 'object' ? JSON.stringify(this.objectList[this.counter][key]) : this.objectList[this.counter][key];
            if (key != 'bureauBasedIncomeEstimation' && key != 'bureauBasedCommitmentDTls' && key != 'calculatedVariables' && key != 'fiInitiationDetails' && key != 'uwCriterias' && key != 'subjectivityMessages' && key != 'deviationsDetails' && key != 'eligibilityRules' && key!='OtherEligibleschemes' && key!='Eligibleschemes') {
                const property = {
                    key: key,
                    value: val
                };
                this.objDataList.push(property);
            }
            /* if (key == 'Scheme Id') {
                 if (this.objectList[this.counter][key] == this.loanSchemeCode) {
                     console.log('Hi', this.isChecked);
                     this.isChecked = true;
                     this.isDisabled = true;
                 }
                 else {
                     this.isChecked = false;
                     this.isDisabled = false;
                 }
             }
             */
             if (key == 'OtherEligibleschemes') {

                let tempER = [];
                let schemeSet = new Set();
                
                if( (this.objectList.length>0) && (this.objectList[0]['OtherEligibleschemes'] != 'undefined')){
                    let schemeList = this.objectList[0]['OtherEligibleschemes']
            
                  for (var i = 0; i < schemeList.length; i++) {
              
                    if(!schemeSet.has(schemeList[i].SchemeName)){
                    schemeSet.add(schemeList[i].SchemeName);
                    tempER.push(schemeList[i])
                    }
                   
                  }
        

                  if(schemeSet.size !=0){
                    this.otherSchemesArray = tempER;
                  }
                }

             }
             if (key == 'Eligibleschemes') {

                let tempER = [];
                let schemeSet = new Set();
                
                if( (this.objectList.length>0) && (this.objectList[0]['Eligibleschemes'] != 'undefined')){
                    let schemeList = this.objectList[0]['Eligibleschemes']
            
                  for (var i = 0; i < schemeList.length; i++) {
              
                    if(!schemeSet.has(schemeList[i].SchemeName)){
                    schemeSet.add(schemeList[i].SchemeName);
                    tempER.push(schemeList[i])
                    }
                   
                  }
        

                  if(schemeSet.size !=0){
                    this.eligibleSchemesArray = tempER;
                  }
                }

             }
            if (key == 'fiInitiationDetails') {
                setTimeout(() => {
                    this.showFiInitiationDetails = true;
                }, 300);
                console.log('this.fiInitiationDetails[this.counter][key]', this.objectList[this.counter][key]);

                this.objectList[this.counter][key].forEach(element => {
                    element['Is FI Required'] = (element['Is FI Required'] == false || element['Is FI Required'] == 'false') ? 'Waived' : 'Initiated';
                });
                this.fiInitiationDetailsArray.push(...this.objectList[this.counter][key]);
            }


            if (key == 'uwCriterias') {
                setTimeout(() => {
                    this.showUwCriterias = true;
                }, 300);
                console.log('this.fiInitiationDetails[this.counter][key]', this.objectList[this.counter][key]);
                this.uwCriteriasArray.push(...this.objectList[this.counter][key]);
            }

            if (key == 'subjectivityMessages') {
                setTimeout(() => {
                    this.showSubjectivityMsgs = true;
                }, 300);
                let tempER = [];
                
                if( (this.objectList.length>0) && (this.objectList[0]['subjectivityMessages'] != 'undefined')){
                    let subjList = this.objectList[0]['subjectivityMessages']
            
                  for (var i = 0; i < subjList.length; i++) {
                    var tempArr={};
          
                    tempArr['Subjectivity'] = subjList[i]['message'];
                    tempArr['Owner'] = subjList[i]['type'];
                    tempER.push(tempArr);
                   
                  }

                  if(tempER.length !=0){
                    this.subjectivityMessagesArray = tempER;
                  }
                console.log('this.subjectivityMessages[this.counter][key]', this.objectList[this.counter][key]);
               // this.subjectivityMessagesArray.push(...this.objectList[this.counter][key]);
            }
                
            }
            console.log('this.subjectivityMessagesArray2', JSON.stringify(this.subjectivityMessagesArray));
            if (key == 'DeviationsDetails') {
                setTimeout(() => {
                    this.showDeviationDetails = true;
                 this.enableSelection=true;
                }, 300);
                let tempER = [];
                if( (this.objectList.length>0) && (this.objectList[0]['deviationsDetails'] != 'undefined')){
                let deviationList= this.objectList[0]['deviationsDetails']
                  for (var i = 0; i < deviationList.length; i++) {
                    var tempArr={};
          
                    tempArr['DeviationType'] = deviationList[i]['Rule Level'];
                    tempDevArr['variance'] = undefined;  
                    if(deviationList[i]['variance']!=undefined || deviationList[i]['variance']!=null)
                    tempArr['variance'] = deviationList[i]['variance'];
                    tempArr['Level'] = deviationList[i]['Override Authority'];
                    tempER.push(tempArr);
                   
                  }

                  if(tempER.length !=0){
                    this.deviationsDetails = tempER;
            }
                }
                console.log('this.deviationsDetails[this.counter][key]', this.deviationsDetails);
              //  this.deviationDetailsArray.push(...this.objectList[this.counter][key]);
                
             
            }



        }
        console.log('objDataList', JSON.stringify(this.objDataList));
        this.disableActions();
    }

    handleAction(event) {
        console.log('event', event.target.name);
        this.isChecked = false;
        this.selectedScheme = [];
        if (event.target.name == 'Next')
            this.counter++;
        else
            this.counter--;
        this.objDataList = [];
        this.handleObjDataList();

        /*
        for (const key in this.objectList[this.counter]) {
            const val = typeof this.objectList[this.counter][key] === 'object' ? JSON.stringify(this.objectList[this.counter][key]) : this.objectList[this.counter][key];
            const property = {
                key: key,
                value: val
            };
            this.objDataList.push(property);
        }
        this.disableActions();
        */

    }

    disableActions() {

        if (this.objectList.length == (this.counter) + 1) {
            this.disbaleNext = true;
        }
        else {
            this.disbaleNext = false;
        }
        if (this.counter == 0) {
            this.disbalePrev = true;
        }
        else {
            this.disbalePrev = false;
        }
    }

    selectSchemeHandle(event) {

        console.log('this.eligibleSchemesArray::',this.eligibleSchemesArray);
        console.log('this.event::',event.target.value);
        console.log('event.target.checked ', event.target.checked);
        console.log('this.isChecked ', this.isChecked);
        this.isChecked = event.target.checked;
        this.value = event.target.checked;
        let Wrapperobject={};

        let SelectedschemeName = event.target.value;

        if(SelectedschemeName.indexOf('(Not Eligible)')!=-1){

            var splitStr = SelectedschemeName.split('(Not Eligible)');
            if(splitStr.length>0)
            SelectedschemeName = splitStr[0].trim();
        }


        if(SelectedschemeName.indexOf('(Eligible)')!=-1){

            var splitStr = SelectedschemeName.split('(Eligible)');
            if(splitStr.length>0)
            SelectedschemeName = splitStr[0].trim();
        }


        for(var i = 0; i < this.schemeAddDetails.length; i++){ 

            if(SelectedschemeName == this.schemeAddDetails[i].key){

                this.schemeAddvalues = this.schemeAddDetails[i].value;
               //this.selectedScheme["Scheme Id"] =this.schemeAddvalues["Scheme Id"];
               // this.selectedScheme.push(Object.assign(Wrapperobject, { 'Scheme Id': this.schemeAddvalues["Scheme Id"]}));
                break;
            }

        }   
      
        let schemeName = event.target.value;

        var input = this.template.querySelectorAll('lightning-input');

        var tmpvalue = event.target.checked;
      

        var tmpischecked = event.target.checked;
        
        input.forEach(function(lwcelement){
            if((!tmpvalue && (lwcelement.name!=event.target.value))){
                lwcelement.checked = false;
            }
        });



        //this.isSchemeChecked = true;
        console.log('this.isChecked ', this.isChecked);

        
        if (this.value == true) {
    
          //  this.selectedScheme = event.target.value;
         // let obj = {'Scheme Id': this.schemId};
          //this.selectedScheme.push(obj);
          
            //this.selectedScheme['Scheme Id']= clone(this.schemId);
          //  let EScheme;
           // console.log('this.isChecked ', this.selectedScheme['Eligibleschemes'].indexOf('(Eligible)'));
           
            if(schemeName.indexOf('(Eligible)')!=-1){
                var splitStr = schemeName.split('(Eligible)');
                if(splitStr.length>0)
                schemeName = splitStr[0].trim();
            }
            if(schemeName.indexOf('(not Eligible)')!=-1){
                var splitStr =schemeName.split('(not Eligible)');
                if(splitStr.length>0)
                schemeName = splitStr[0].trim();
            }
           

            for(var i = 0; i < this.schemeAddDetails.length; i++){ 

                if(this.schemeAddDetails[i].key != undefined && schemeName == this.schemeAddDetails[i].key.trim()){
                    this.selectedScheme = this.schemeAddDetails[i].value;
                }

            }
    
            console.log('this.selectedScheme ', JSON.stringify(this.selectedScheme));
            for (const key in this.selectedScheme) {
                if (key == 'Is Eligible' || key == 'isEligible') {
                    if (this.objectList[this.counter][key] == false) {
                        //  alert('')
                        this.showToastMessage("Warning", "The scheme can’t be selected as it’s not eligible.", "warning", "");
                        this.isChecked = false;
                        //   this.isSchemeChecked = false;
                        event.target.checked = false;
                    }
                }
            }
        }
    }

    handleSaveScheme() {
        console.log('this.selectedScheme ', JSON.stringify(this.selectedScheme));
        this.updateScheme();
    }

    updateScheme() {
        this.isSchemeChecked = true;
        updateSelectedScheme({
            loanAppId: this.recordId,
            selectedScheme: JSON.stringify(this.selectedScheme),
            breResponseId: this.breResponseId,
            remarks: this.remarks
        })
            .then(result => {
                if (result.blnSuccess == true) {
                    console.log('result: ', result);
                    this.showToastMessage("Success", result.strMessage, "success", "");
                    //this.isChecked = false;
                    this.isSchemeUpdated=true;
                    this.navigateToRecordPage();
                    //this.handleSuccessAlertClick();
                }
                else if (result.blnSuccess == false){
                    this.showToastMessage("Error", result.strMessage, "error", "");
                    this.isSchemeChecked = false;
                }
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
                this.isSchemeChecked = false;
            })

    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }

    navigateToRecordPage() {
        // window.open('/lightning/r/Loan_Application__c/'+this.recordId+'/view');
        //this.dispatchEvent(new RefreshEvent());
 
         this[NavigationMixin.GenerateUrl]({
             type: "standard__recordPage",
             attributes: {
                 actionName: "view",
                 recordId: this.recordId
             }
         }).then((url) => {
            window.open(url,'_self');
         });
         // START || SFAU-3382 || Added By Ashish
         setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
 
        //END 
     }
 






}