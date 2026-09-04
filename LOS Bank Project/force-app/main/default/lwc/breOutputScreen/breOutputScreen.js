/*
@ Logs - 
@ Date              :   LastModified by     :       Description
  12-June-2023      :   Mohit M.            :       SFAU-2951 - in BRE response credit level and deviation level is not showing
*/

import { LightningElement, track, api } from 'lwc';
import getBreResponse from '@salesforce/apex/BreOutputScreenController.getBreResponse';
import CibilInterval from '@salesforce/label/c.BRE_Interval';
import CIbilMaxPollLimit from '@salesforce/label/c.BRE_Max_Poll_limit';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';

export default class BreOutputScreen extends LightningElement {

    breOutput = My_Resource + '/ausfIcons/BRE-Output.png';
    @api recordId;
    @api requestid;
     schemeMap = [];
     deviationsMap = [];
     selectSchema=false;
    isloading = false;
    activeSections;
    fiLocation='';
    deviations='';
    applicantDecision = '';
    uwAuthority = '';
    decisionDateTime = '';
    applicantsArray = [];
    applicantArray=[];
    fiDetailsArray = [];
    uwCriteriaArray = [];
    productDecision = '';
    schemeDecisionArray = [];
    schemeDetails=[];
    notEligibleSchemes = [];
    EligibleSchemes = [];
    subjectivityMessagesArray = [];
    deviationDetailsArray = [];
    errorDeatilsArray = [];
    showFiDetails = false;
    showApplicants = false;
    showSchemeDecision = false;
    showSubjectivityMsgs = false;
    showDeviationDetails = false;
    @track isShowDeclineReasons = false;
    @track isShowErrorReasons = false;
    showErrors = false;
    breResponseId;
    breResponse;
    cibilInterval;
    cibilIntervalList = [];
    clearIntCounter = 0;
    clearInterCheck;
    @api showuwcriteria = false;
    @api isFromLoanTab;
    isBreStatusRecieved;
    isBreStatusPending;
    isBreStatusBlank;
    lastBreRunAt;
    isEnableSchemeSelection = true;
    loanAppId;
    schemId;
    loanSchemeCode;
    hideSTP=false;
    schemeAddtDetails={};
    showSubjectivityMsgs=false;
    AppcustGrade;
    showFiInitiated;
    @track renderuwcriteria = false;

    connectedCallback() {
        //console.log('showuwcriteria', this.showuwcriteria);
        this.renderuwcriteria = this.showuwcriteria;
        this.isFromLoanTab = (this.isFromLoanTab == false || this.isFromLoanTab == 'false') ? true : false;
        if (this.isFromLoanTab == true) {
            this.fetchBreResponse();
        }
        else {
            this.refreshBreResponse();
        }

    }



    refreshBreResponse() {
        this.isloading = true;
        // this.clearIntCounter = 0;
        console.log("calling refresh cibil");
        this.cibilInterval = setInterval(() => {
            if (this.clearInterCheck == true) {
                //console.log("inside clearInterCheck", JSON.stringify(this.cibilInterval));
                //console.log("inside clearInterCheckList", JSON.stringify(this.cibilIntervalList));
                this.cibilIntervalList.forEach(inputField => {
                    clearInterval(inputField);
                });
            }
            else {
                this.cibilIntervalList.push(this.cibilInterval);
                //console.log("inside cibilInterval");
                this.clearIntCounter = Number(this.clearIntCounter) + Number(CibilInterval);
                this.fetchBreResponse();
            }

        }, Number(CibilInterval));

    }

    checkCounter() {
        //console.log('clearIntCounter', this.clearIntCounter);
        if (this.clearIntCounter > Number(CIbilMaxPollLimit)) {

            clearInterval(this.cibilInterval);
            //this.clearIntCounter = 0;
            this.isloading = false;
            this.clearInterCheck = true;
            //console.log('Max Polling Limit Reached');
            return true;
        }
        return false;
    }

    fetchBreResponse() {


        getBreResponse({
            loanAppId: this.recordId,
        })
            .then(result => {
                //console.log('result BREReponse: ', JSON.stringify(result));
                this.isloading = false;
                this.loanAppId = result.loanAppId;
                if (this.isFromLoanTab == true) {
                    this.isBreStatusRecieved = true;
                    console.log('this.isBreStatusRecieved ' + this.isBreStatusRecieved);
                }
                if (result.blnSuccess == true) {
                     // As per defect - SFAU-2951
                    console.log('UW ' + JSON.stringify(result.hasShowCriteriaPermission));
                    console.log('UW ' + JSON.stringify(result));
                    this.renderuwcriteria = result.hasShowCriteriaPermission;
                    if (result.blnBREError == true) {
                        this.isBreStatusRecieved = true;
                        this.breResponse = false;
                    }
                    if (result.blnBRESuccess == true && (result.breStatus == 'Received' || result.breStatus == 'RECEIVED' || result.breStatus == 'SUCCESS')) {
                        this.isBreStatusRecieved = true;
                        this.breResponse = true;
                    }
                    else if (result.breStatus == 'Pending' || result.breStatus == 'In Progress') {
                        this.isBreStatusPending = true;
                    }
                    else if (result.breStatus == '') {
                        this.isBreStatusNull = true;
                    }
                }
                console.log('this.isBreStatusRecieved' + this.isBreStatusRecieved);
                if (result.blnSuccess == true && result.blnBREError == false && result.breResponse != null) {
                    //console.log('schemeCode: ', result.schemeCode);
                    this.breResponseId = result.breResponse.Id;
                    this.lastBreRunAt = result.breResponse.CreatedDate;
                    this.loanSchemeCode = result.schemeCode;
                    if (this.isFromLoanTab == true && result.breResponse.Is_Confirmed__c == true) {
                        this.isEnableSchemeSelection = true;
                    }
                    else if (this.isFromLoanTab == true && result.breResponse.Is_Confirmed__c == false) {
                        this.isEnableSchemeSelection = false;
                    }
                    else if (this.isFromLoanTab == false) {
                        this.isEnableSchemeSelection = true;
                    }
                    if (result.strBreResponse != null && result.strBreResponse != '') {
                        //console.log('strBreResponse ', JSON.parse(result.strBreResponse));
                        this.clearInterCheck = true;
                        this.breResponse = JSON.parse(result.strBreResponse);
                        //console.log('this.breResponse.message: ', this.breResponse.message);
                        if (this.breResponse.message.responseStatus == 'SUCCESS') {
                            if (this.breResponse.message.application.applicationDecision.systemDecision) {
                                this.applicantDecision = this.breResponse.message.application.applicationDecision.systemDecision;
                                if(this.applicantDecision =='STP with Conditions')
                                this.showSubjectivityMsgs=true;
                            }
                            if(this.breResponse.message.application.product[0].productDecision.schemeDecision.length>0){
                                var subjArrlist =  this.breResponse.message.application.product[0].productDecision.schemeDecision[0].subjectivityMessages;
 
                                var Wrapperobject = {};
 
                                 this.subjectivityMessagesArray.push(Object.assign(Wrapperobject,{ 'subjectivityMessages': subjArrlist}));
                            }
                            if (this.breResponse.message.application.applicationDecision.systemDecision != 'DECLINE') {

                                this.activeSections = ['A', 'B', 'C'];
                                if (this.breResponse.message.application.applicationDecision.uwAuthority)
                                    this.uwAuthority = this.breResponse.message.application.applicationDecision.uwAuthority;

                                if (this.breResponse.message.application.applicationDecision.systemDecisionDate)
                                    this.decisionDateTime = this.breResponse.message.application.applicationDecision.systemDecisionDate;
                                //console.log('app lst', this.breResponse.message.application.applicants);
                                //console.log('app length', this.breResponse.message.application.applicants.length);

                                if (this.breResponse.message.application.applicants.length > 0) {
                                    this.showApplicants = true;
                                    var Wrapperobject = {};
                                    var WrapperNewobject = {};
                                //    var applicantsList = this.breResponse.message.application.applicants;
                                    
                                    // var AppcustGrade ='',coAppcustGrade='',gurantorcustGrade='';

                                    var applicantsFiList = this.breResponse.message.application.applicants;
                                    var applicanttypeFi = '';
                                    this.showFiInitiated=true;
                                   // custGrade =  this.breResponse.message.application.applicants[0].customerGrade; 

                                    applicantsFiList.forEach(currItem => {
                                        var fiLocation = '';
                                        var fiInitiationDetailslist = currItem.applicantDecision.fiInitiationDetails 
                           
                                    fiInitiationDetailslist.forEach(currentItem => {
                                        console.log('currentItem fiInitiationDetailslist', currentItem);
                                        if (currentItem["FI Type"] == "CURRENT" && currentItem["Is FI Required"] == true) {
                                            fiLocation = fiLocation == 'Waived' ? '' : fiLocation;
                                            fiLocation = fiLocation != '' ? (fiLocation + ', Current Address') : 'Current Address';
                                            //fiLocation +=' ,Current Address';
                                        }
                                        else if(currentItem["FI Type"] == "PERMANENT" && currentItem["Is FI Required"] == true){
                                            fiLocation = fiLocation == 'Waived' ? '' : fiLocation;
                                            fiLocation = fiLocation != '' ? (fiLocation + ', Permanent Address') : 'Permanent Address';
                                            //fiLocation +=' ,Permanent Address';
                                        }
                                        else if(currentItem["FI Type"] == "OFFICE" && currentItem["Is FI Required"] == true){
                                            fiLocation = fiLocation == 'Waived' ? '' : fiLocation;
                                            fiLocation = fiLocation != '' ? (fiLocation + ', Office Address') : 'Office Address';
                                            //fiLocation +=' ,Permanent Address';
                                        }
                                        if(fiLocation ==''){
                                            currentItem["FI Type"] = 'Waived';
                                        }
                                        else{
                                            currentItem["FI Type"] = fiLocation;
                                        }

                                         if(currItem["Applicant Type"] == "PRIMARY"){
                                            if (fiLocation == '') {
                                                fiLocation = 'Waived';
                                            }

                                          // if(currItem["cpvWaivedOff"]!=null && currItem["cpvWaivedOff"] !=undefined)
                                            //this.applicantsArray.push(Object.assign(Wrapperobject, { 'Applicant': currItem["cpvWaivedOff"]}));
                                            this.applicantArray.push(Object.assign(WrapperNewobject,{'Applicant':fiLocation}));
                                           this.AppcustGrade = currItem["customerGrade"]
                                           // this.applicantsArray.push(Object.assign(Wrapperobject, { 'Customer Grade': AppcustGrade}));
                                        }
                                        else if(currItem["Applicant Type"]  == "CO_APPLICANT"){
                                            if (fiLocation == '') {
                                                fiLocation = 'Waived';
                                            }
                                            //if(currItem["cpvWaivedOff"]!=null && currItem["cpvWaivedOff"] !=undefined)
                                            //this.applicantsArray.push(Object.assign(Wrapperobject, { 'CO-Applicant': currItem["cpvWaivedOff"]}));
                                            this.applicantArray.push(Object.assign(WrapperNewobject,{'Co-Applicant':fiLocation}));
                                  
                                          //  coAppcustGrade =  currItem["Customer Grade"]
                                           // this.applicantsArray.push(Object.assign(Wrapperobject, { 'Co-Applicant Customer Grade': coAppcustGrade}));
                                        }
                                        else if(currItem["Applicant Type"]  == "GUARANTOR"){
                                            if (fiLocation == '') {
                                                fiLocation = 'Waived';
                                            }
                                          //  if(currItem["cpvWaivedOff"]!=null && currItem["cpvWaivedOff"] !=undefined)
                                           // this.applicantsArray.push(Object.assign(Wrapperobject, { 'GUARANTOR': currItem["cpvWaivedOff"]}));
                                            this.applicantArray.push(Object.assign(WrapperNewobject,{'Guarantor':fiLocation}));
                                          //  gurantorcustGrade = currItem["Customer Grade"]
                                           // this.applicantsArray.push(Object.assign(Wrapperobject, { 'GUARANTOR Customer Grade': gurantorcustGrade}));
                                        }

                                        

                                    });
                                });
                                //¯ console.log("fiInitiationDetailslist::",fiInitiationDetailslist);
                               
                                  //  applicantsList.forEach(currentItem => {
                        
                                        // this.uwCriteriaArray.push(currentItem.applicantDecision.uwCriterias);
                                      //  this.applicantsArray.push(Object.assign(currentItem.applicantDecision,/* { 'Applicant Type': currentItem.applicantType },*/{ 'Customer Grade': currentItem.customerGrade }));

                                   // });
                                    console.log('currentItem applicantsList', this.applicantsArray);
                                }

                                if (this.breResponse.message.application.product[0].productDecision.productDecision) {
                                    this.productDecision = this.breResponse.message.application.product[0].productDecision.productDecision;
                                }
                                //console.log('schemeDecision', this.breResponse.message.application.product[0].productDecision.schemeDecision);
                                if (this.breResponse.message.application.product[0].productDecision.schemeDecision.length > 0) {
                                    this.showSchemeDecision = true;
                                    var Wrapperobject = {};
                                    var Wrappernewobject = {};
                                  //  var schemeObject = {};
                                    var schemeDecisionList = this.breResponse.message.application.product[0].productDecision.schemeDecision;
                                    var deviationList = this.breResponse.message.application.product[0].productDecision.schemeDecision.deviationsDetails;
                                    //var deviationList = this.breResponse.message.application.product[0].productDecision.schemeDecision[0].deviationsDetails;
                                    var schemeSelected = this.breResponse.message.application.product[0].productDecision.schemeDecision[0].strSchemeNameWithWOEligible
                                     var appSchemeDecision =this.breResponse.message.application.applicationDecision.systemDecision;

                                    schemeDecisionList.forEach(currentItem => {
                                        console.log('currentItem:::', currentItem);
                                        console.log('currentItem["blnSchemeSelectedByRO"]:::', currentItem["blnSchemeSelectedByRO"]);
                                       
                                        if(currentItem["blnSchemeSelectedByRO"] == false) {
                                            
                                            var schName='';
                                            if(currentItem["Is Eligible"] == true){
                                            schName = currentItem["Scheme Name"]+' '+'(Eligible)';
                                           // this.selectSchema=true;
                                            }
                                            else
                                            schName = currentItem["Scheme Name"]+' '+'(Not Eligible)';

                                           
                                           this.schemeMap.push({ 'schemeId': currentItem["Scheme Id"]});
                                          // this.schemeMap.push({ 'selectSchema': selectSchema});

                                          var schemeObject = {

                                            SchemeName:schName,
                                            isEligible:currentItem["Is Eligible"],
                                            enableSelection:false
                                          }
                                           
                                      //   this.notEligibleSchemes.push(Object.assign(schemeObject,{ 'isEligible': currentItem["Is Eligible"]}));
                                           this.notEligibleSchemes.push(schemeObject);
                                           // this.notEligibleSchemes.push(Object.assign(Wrapperobject,{ 'Other Eligible scheme': this.notEligibleSchemes}));
                                            this.schemeMap.push({value:currentItem,key:currentItem["Scheme Name"]});
                                            if((currentItem["deviationsDetails"]!=null) && currentItem["deviationsDetails"]!=undefined)
                                                this.deviationsMap.push({value:currentItem["deviationsDetails"],key:currentItem["Scheme Name"]});
                                            // this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'Other Eligible scheme': this.notEligibleSchemes}));

                                        }
                                        if ((currentItem["blnSchemeSelectedByRO"] == true)) {

                                            var schName='';
                                            if(currentItem["Is Eligible"] == true)
                                            schName = currentItem["Scheme Name"]+' '+'(Eligible)';
                                            else
                                            schName = currentItem["Scheme Name"]+' '+'(Not Eligible)';

                                            this.schemeMap.push({ 'schemeId': currentItem["Scheme Id"]});
                                            this.EligibleSchemes.push(Object.assign(Wrappernewobject,{ 'EligibleSchemeName': schName},{ 'isEligible': currentItem["Is Eligible"]},{ 'enableSelection': false}));
                                         //   this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'isEligible': currentItem["Is Eligible"]}));
                                           // this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'schemeId': currentItem["Scheme Id"]}));
                                         //   this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'Eligible': currentItem["Is Eligible"]}));
                                            this.schemeMap.push({value:currentItem,key:currentItem["Scheme Name"]});
                                            if((currentItem["deviationsDetails"]!=null) || currentItem["deviationsDetails"]!=undefined)
                                                this.deviationsMap.push({value:currentItem["deviationsDetails"],key:currentItem["Scheme Name"]});
                                            this.schemeMap.push({value:appSchemeDecision,key:"appSchemeDecision"});
                                          
                                          
                                        }
                                        console.log('schemeDecisionArray', this.schemeDecisionArray);
                                        console.log('schemeMap::', this.schemeMap);
                                    });
                                        
                                    
                                        if(this.deviationsMap != undefined)
                                        this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'deviationsDetails':Array.from(this.deviationsMap)}));
                                        if(this.notEligibleSchemes != undefined)
                                        this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'OtherEligibleschemes':Array.from(this.notEligibleSchemes)}));
                                        if(this.EligibleSchemes != undefined)
                                        this.schemeDecisionArray.push(Object.assign(Wrapperobject,{ 'Eligibleschemes':Array.from(this.EligibleSchemes)}));
                                        
                                        this.showSchemeDecision = true; 
                                    
                                }
                                this.isShowDeclineReasons = false;
                            }
                            else {
                                this.activeSections = ['A', 'B'];
                                if (this.breResponse.message.application.applicationDecision.systemDecisionDate)
                                    this.decisionDateTime = this.breResponse.message.application.applicationDecision.systemDecisionDate;

                                if (this.breResponse.message.application.applicants.length > 0) {
                                    this.showApplicants = true;
                                    var applicantsList = this.breResponse.message.application.applicants;
                                    applicantsList.forEach(currentItem => {
                                        //console.log('currentItem', currentItem);
                                        this.uwCriteriaArray.push(...currentItem.applicantDecision.uwCriterias);
                                    });
                                }
                                this.isShowDeclineReasons = true;
                            }

                        }
                        else if (this.breResponse.message.responseStatus == 'ERROR') {
                            this.activeSections = ['A', 'B'];
                            this.isShowErrorReasons = true;
                            this.showErrors = true;
                            this.errorDeatilsArray = this.breResponse.message.error;
                        }
                    }
                    else {
                        if (this.checkCounter() == false) {
                            this.refreshBreResponse();
                        }
                    }
                }
                else {
                    if (this.checkCounter() == false) {
                        this.refreshBreResponse();
                    }
                }
            })
            .catch(error => {
                this.error = error;
                clearInterval(this.cibilInterval);
                //console.log('error', error);

            })

    }


}