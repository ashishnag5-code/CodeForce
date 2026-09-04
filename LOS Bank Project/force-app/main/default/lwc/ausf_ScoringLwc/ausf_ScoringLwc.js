import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCibilRequest from '@salesforce/apex/LosAdditionalMatchController.createCibilRequest';
import getApplicant from '@salesforce/apex/CFRNegativeCheckRelatedPartyAMLCheck.getApplicant';
import checkHandler from '@salesforce/apex/CFRNegativeCheckRelatedPartyAMLCheck.checkHandler';
import getUpdatedApplicantCibil from '@salesforce/apex/Aml.getUpdatedApplicantCibil';
import callAmlHandler from '@salesforce/apex/Aml.callAmlHandler';
import getTypeOfWheeler from '@salesforce/apex/Aml.getTypeOfWheeler';
import getRelatedFilesByRecordId from '@salesforce/apex/Aml.getRelatedFilesByRecordId';
import CibilInterval from '@salesforce/label/c.Cibil_Interval';
import CIbilMaxPollLimit from '@salesforce/label/c.CIbil_Max_Poll_Limit';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
const FIELDS = ["ContentVersion.Id", "ContentVersion.Title", "ContentVersion.VersionData"];
import cibilReportMobileView from "c/cibilReportMobileView";
import getLoanDetails from '@salesforce/apex/LosAdditionalMatchController.getLoanDetails'//4733

export default class Ausf_ScoringLwc extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;
    @api insideRecordPage = false;
    error;
    additionalMatchRecId = "";
    cibilInterval;
    cibilIntervalList = [];
    reportIntervalList = [];
    reportInterval;
    @track applcntRec = [];
    contentDocumentId = "";
    contentVersionId = "";
    @track creditScore = "";
    @track amlStatusVal = "";
    @track applcntList = [];
    preApprovedApplication = false;
    relPartyVal = "";
    negatCheckVal = "";
    cfrStatusVal = "";
    reportVal = "";
    view = "";
    isLink = true;
    isCibil = false;
    onClick;
    cibilOnClick = false;
    isGetCibilScoreDisabled = false;
    // showReportLink = "";
    errorOnChild;
    errorMessage = "";
    noDataFoundMessage = "";
    matchRecordUrl = "";
    matchRecordLabel = "";
    checkCibilButton = "";
    clearIntCounter = 0;
    clearInterCheck;
    clearRelatedCheck;
    isModalOpen;
    rerunCibil = false;
        isLoading;
    @api spinnerImage;
    applcCustomerType;
    cibilCustomMeta;
    cibilHTMLString;
    @track isCibilReRunAllowed//4733
    stagesForRO = ['QDE','DDE','PSD']
    stagesForCredit = ['Credit']
    loanApp = {};
    connectedCallback() {
        this.checkHandle();
        //4733
        this.getLoanAppDetails()
    }
    loanStage = '';
    userProfile = ''
    getLoanAppDetails(){
        getLoanDetails({recordId: this.recordId}).then((data=>{
            let stage = data.applicant?data.applicant.Loan__r.Stage__c:'';
            let profile = data.currentUser?data.currentUser.Profile.Name:'';
            this.loanStage = stage;
            this.loanApp['Id'] = data.applicant ? data.applicant.Loan__c : '';
            this.loanApp['Vehicle_finalised__c'] = data.applicant ? data.applicant.Loan__r.Vehicle_finalised__c : '';
            this.userProfile = profile;
            this.isCibilReRunAllowed = (this.stagesForRO.includes(stage) && profile=='Sales') || (this.stagesForCredit.includes(stage) && profile=='Credit Manager')?true:false
        })).catch((error=>{

        }))
    }

    get showVehicleFinanlize(){
        return this.stagesForRO.includes(this.loanStage) &&  (this.userProfile=='Sales' || this.userProfile=='COM' || this.userProfile == 'System Administrator') && this.applcntList && this.applcntList.length > 0 && this.applcntList[0].RecordType.Name == 'Applicant';
    }
    handleValuChange(event){
        this.loanApp['Vehicle_finalised__c'] = event.target.checked;
    }

    checkHandle() {
        this.isLoading = true;
        checkHandler({ applcntId: this.recordId })
            .then((result) => {
                this.isLoading = false;
                console.log("messag--> " + JSON.stringify(result));
                let message = result.messag;
                this.cibilCustomMeta = result.cibilCutomMetaDataLst;
                let matchedRec = result.recMatchList;
                this.applcntList = result.applcntList;
                let cfrStatusLightningIcon = this.template.querySelector(`lightning-icon[data-name="CfrStatus"]`);
                if(this.applcntList[0].AML_Status__c==null && this.objectApiName=='Applicant__c'){
                    this.noDataFoundMessage = 'Please run the wizard to get the scores';
                    return;
                }
                if (message === "CFR Match" || message === "NP Match" || message === "RP Match") {
                    this.showErrorForMatchRec("Rejected due to matched record " , matchedRec);
                    this.getApplicantafterUpdate();
                    this.utilityClose(cfrStatusLightningIcon);
                    if(!this.insideRecordPage){
                        if(message === "CFR Match"){
                            this.showToastMessage("", "Case is rejected due to match with fraud registry", "error", "dismissible");
                        }
                        else if(message === "NP Match"){
                            this.showToastMessage("", "Case is rejected due to match with Negative Check", "error", "dismissible");
                        }
                        else if(message === "RP Match"){
                            this.showToastMessage("", "Cases is rejected due to match with Related Party", "error", "dismissible");
                        }
                    }
                }else if(message == 'Partial Match'){
                    this.showErrorForMatchRec("Partial matched record found ", matchedRec);
                    this.updatePropMessage(cfrStatusLightningIcon, "Partial Match");
                    this.refreshCreditScoreHandler();
                }
                else if (message === "No Match Found" ) {
                    this.refreshCreditScoreHandler();
                }
            })
            .catch((error) => {
                this.isLoading = false;
                this.error = error;
                console.log('Error inside checkHandle-- ' + JSON.stringify(this.error));
                this.errorMessage = "Some error has occured. Please contact System Administrator";
            });
    }

    renderedCallback() {
    //     setTimeout(() => {
    //    }, 100); 
    //         this.cibilColorRange();
    }

    cibilColorRange() {
            let dataId = this.template.querySelector('[data-id="cibilColor"]');
            let creditScoreInNumber = this.creditScore;
            for(let cibilRange in this.cibilCustomMeta) {
                let cibilRangeInNumber = Number(cibilRange);
               
                if(cibilRange == "650-724" ||  cibilRange == '-1') {
                    let lowValue = Number(cibilRange.split('-')[0]);
                    let maxValue = Number(cibilRange.split('-')[1]);
                    if((creditScoreInNumber > lowValue && creditScoreInNumber < maxValue)) {
    
                       // dataId.classList.add(cibil_650_724_or_minusOne);
                    }
                }
                else if(cibilRangeInNumber >= 725) {
                   // dataId.classList.add(cibil_moreThan_725);
                }
                else if(cibilRangeInNumber < 650) {
                  //  dataId.classList.add(cibil_below_650);
                }
    
            }

    }

    showErrorForMatchRec(message, matchedRec) {
        let recId = matchedRec[0].Id;
        let name = matchedRec[0].Name;
        this.errorMessage = message;
        this.matchRecordLabel = name;
        this.generateUrl('standard__recordPage', recId, "view");
    }

    generateUrl(type, recordId, actionName) {
        //1. Generate a URL
        this[NavigationMixin.GenerateUrl]({
            type: type,
            attributes: {
                recordId: recordId,
                actionName: actionName,
            },
        }).then(url => {
            //2. Assign it to the prop
            this.matchRecordUrl = url;
        });
    }

    genericNavigateToPage(type, recordId, actionName) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: type,
            attributes: {
                recordId: recordId,
                actionName: actionName
            }
        });
    }

    getApplicantafterUpdate() {
this.isLoading = true;
        this.setCreditScore('Cancelled');
     //   this.creditScore = "Cancelled";
        this.amlStatusVal = "Cancelled";
        this.reportVal = "true";
        this.isLink = false;
        this.view = "Cancelled";
        getApplicant({ recordId: this.recordId })
            .then((result) => {
                this.isLoading = false;
                this.applcntRec = result;
                let applcnt = result;
                console.log('applcnt  in getApplicantafterUpdate -- ' + JSON.stringify(this.applcntRec));
                this.showUpdatedData(applcnt);
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.applcntRec = undefined;
                console.log('Error inside getApplicantafterUpdate -- ' + JSON.stringify(this.error));
                this.errorMessage = "Some error has occured. Please contact System Administrator";
            });
    }

    showUpdatedData(applcnt) {
        let status = "";
        if (applcnt[0].CFR_Status__c !== "" && applcnt[0].CFR_Status__c === "Rejected due to match with fraud registry") {
            status = "CfrStatus";
        }
        else if (applcnt[0].Negative_Check_Status__c !== "" && applcnt[0].Negative_Check_Status__c === "Rejected due to match with fraud registry") {
            status = "NegCheckStatus";
        }
        else if (applcnt[0].Related_Party_Status__c !== "" && applcnt[0].Related_Party_Status__c === "Rejected due to match with fraud registry") {
            status = "RelPartyStatus";
        }
        if (status != "") {
            this.updateCheckForAmlNpRp(status);
        }
    }

    updateCheckForAmlNpRp(statusCriteria) {
        let getLighticon = this.template.querySelector(`lightning-icon[data-name=${statusCriteria}]`);
        this.utilityClose(getLighticon);
        let currentDataId = Number(getLighticon.dataset.id);
        let getAllLighticon = this.template.querySelectorAll(`lightning-icon[data-name]`);
        console.dir(getLighticon);
        console.log("getLighticon-- " + JSON.stringify(getLighticon));
        let iconsToInclude = ["CfrStatus", "NegCheckStatus", "RelPartyStatus", "AmlStatus"];
        for (let lightningIcon of getAllLighticon) {
            if (1 === currentDataId) {
                this.updatePropVal("Cancelled");
            }
            else if (Number(lightningIcon.dataset.id) > currentDataId) {
                this.updatePropMessage(lightningIcon, "Cancelled");
            }
            else if (Number(lightningIcon.dataset.id) < currentDataId && (iconsToInclude.includes(lightningIcon.dataset.name))) {
                this.utilityCheck(lightningIcon);
            }
        }
    }

    utilityClose(getLighticon) {
        getLighticon.iconName = "action:close";
        getLighticon.variant = "error";
        getLighticon.size = "x-small";
    }

    utilityCheck(getLighticon) {
        getLighticon.iconName = "action:check";
        getLighticon.variant = "success";
        getLighticon.size = "x-small";
    }

    inProgressIcon(getLighticon) {
        getLighticon.iconName = "utility:spinner";
        getLighticon.variant = "warning";
        getLighticon.size = "medium";
    }

    inPendingIcon(getLighticon, variant, size) {
        getLighticon.iconName = "utility:pause";
        getLighticon.variant = variant;
        getLighticon.size = size;
    }

    updatePropMessage(lightningIcon, message) {
        let datasetName = lightningIcon.dataset.name;
        if (datasetName === "CfrStatus") {
            this.cfrStatusVal = message;
        }
        else if (datasetName === "NegCheckStatus") {
            this.negatCheckVal = message;
        }
        else if (datasetName === "RelPartyStatus") {
            this.relPartyVal = message;
        }
        else if (datasetName === "AmlStatus") {
            this.amlStatusVal = message;
        }
        else if (datasetName === "CreditScore") {
           // this.creditScore = message;
            this.setCreditScore(message);

        }
    }

    updatePropVal(val) {
        this.negatCheckVal = val;
        this.relPartyVal = val;
        this.amlStatusVal = val;
      //  this.creditScore = val;
        this.setCreditScore(val);

    }

    fltrLigthningIcon(iconsToExcludeArr) {
        let getAllLighticon = this.template.querySelectorAll(`lightning-icon[data-name]`);
        let filterLighIcon = [];
        for (let val of getAllLighticon) {
            if (!iconsToExcludeArr.includes(val.dataset.name)) {
                filterLighIcon.push(val);
            }
        }
        return filterLighIcon;
    }

    refreshCreditScoreHandler() {
        this.errorMessage = undefined;
        let iconsToExcludeArr = ["CreditScore", "ReportVal", "AmlStatus"];
        let filterLighIcons = this.fltrLigthningIcon(iconsToExcludeArr);
        for (let lightIcon of filterLighIcons) {
            this.utilityCheck(lightIcon);
        }

        let getLighticon = this.template.querySelector(`lightning-icon[data-name="AmlStatus"]`);
        this.inProgressIcon(getLighticon);
     //   if(this.applcntList[0].AML_Status__c==null){
            this.isLoading = true;
            callAmlHandler({ applcntId: this.recordId })
                .then((result) => {
                    this.isLoading = false;
                    console.log("response-- " + JSON.stringify(result));
                    if (JSON.stringify(result) !== '{}') {
                        this.applcntRec = result.applcntList;
                        let amlResponse = result.amldeserializeResponse;
                        let integChcklstOfAml = result.integChcklst;
                        let status = amlResponse.status.status;
                        this.applcCustomerType = result.applcntList[0].Customer_Type__c;
                        this.preApprovedApplication = result.applcntList[0].Loan__r.Pre_Approved_Flag__c;
                        if (this.applcCustomerType == "Non Individual" || this.preApprovedApplication) {
                            this.isCibil = true;
                            this.additionalMatchRecId = "";
                        }
                        if (status !== "success" || integChcklstOfAml[0].Status__c == "Failed") {
                            this.onClick = true;
                            this.errorMessage = "AML API Failed";
                        //  this.creditScore = "Cancelled";
                            this.setCreditScore('Cancelled');

                            this.reportVal = "true";
                        }
                        else {
                            this.onClick = false;
                            this.creditScore = "";
                        // this.setCreditScore('');
                            this.reportVal = "";
                            let amlStatus = amlResponse.AML_ACTION;
                            this.amlSatusSuccess(amlStatus, "", integChcklstOfAml, "");
                        }
                    }
                })
                .catch((error) => {
                    this.isLoading = false;
                    this.error = error.message || error.body.message;
                    console.log('Error inside callAmlHandler -- ' + this.error);
                    this.errorMessage = "Some error has occured. Please contact System Administrator";
                });
      //  }
    }

    @wire
    ( getTypeOfWheeler,{applicantId : '$recordId'})
    typeOfWheeler;

    amlSatusSuccess(status, applcntLst, integrChecklist, bureauRes) {
        console.log('this.applcntRec[0].CIBIL_Status__c', this.applcntRec[0].CIBIL_Status__c);
        console.log('this.applcntRec[0].CIBIL_Rerun__c', this.applcntRec[0].CIBIL_Rerun__c);

        let lighticonAmlStatus, lightIconCreditScore, LighticonReportVal;
        let lateexec = setTimeout(() => {
            lighticonAmlStatus = this.template.querySelector(`lightning-icon[data-name="AmlStatus"]`);
            lightIconCreditScore = this.template.querySelector(`lightning-icon[data-name="CreditScore"]`);
            LighticonReportVal = this.template.querySelector(`lightning-icon[data-name="ReportVal"]`);



            console.log('date', this.applcntRec[0].Last_CIBIL_Run_Date__c);
            let daysBetweenDates;
            if(this.applcntRec[0].Last_CIBIL_Run_Date__c){
                const then = new Date(this.applcntRec[0].Last_CIBIL_Run_Date__c);
                const now = new Date();
    
                const msBetweenDates = Math.abs(then.getTime() - now.getTime());
    
                // 👇️ convert ms to days                 hour   min  sec   ms
                 daysBetweenDates = msBetweenDates / (24 * 60 * 60 * 1000);
    
                if (daysBetweenDates < 30) {
                    console.log('date is within 30 days');
                }
            }


            if (status === "Hold") {
                this.amlStatusVal = 'Pending';
                this.inPendingIcon(lighticonAmlStatus, "", "small");
                lighticonAmlStatus.classList.add('pendingIcon');
                if(lightIconCreditScore){
                    this.inProgressIcon(lightIconCreditScore);
                }
                if(LighticonReportVal){
                    this.inProgressIcon(LighticonReportVal);
                }
                if(this.applcCustomerType == "Individual" && !this.preApprovedApplication){
                    if (this.applcntRec[0].CIBIL_Status__c == 'Skipped' && daysBetweenDates < 30) {
                        /*  if(this.applcntRec[0].Bureau_Score__c) {
                              this.creditScore = this.applcntRec[0].Bureau_Score__c;
                          } */
                        this.fetchLastCibil();
                    }
                    else if (this.applcntRec[0].CIBIL_Rerun__c == true) {
                      //  this.creditScore = this.applcntRec[0].Bureau_Score__c;
                      let creditScore = this.applcntRec[0].Bureau_Score__c ?  this.applcntRec[0].Bureau_Score__c :'0';
                        this.setCreditScore(creditScore);
                        this.rerunCibil = this.applcntRec[0].CIBIL_Rerun__c;
                    }
                    else {
                        this.refreshCibil();
                    }
                }


            }
            else if (status == "Approved") {
                this.utilityCheck(lighticonAmlStatus);
                if(lightIconCreditScore){
                    this.inProgressIcon(lightIconCreditScore);
                }
                if(LighticonReportVal){
                    this.inProgressIcon(LighticonReportVal);
                }

              if(this.applcCustomerType == "Individual" && !this.preApprovedApplication){
                
               if (this.applcntRec[0].CIBIL_Status__c == 'Skipped' && daysBetweenDates < 30) {
                    /* if(this.applcntRec[0].Bureau_Score__c) {
                         this.creditScore = this.applcntRec[0].Bureau_Score__c;
                     }  */
                    this.fetchLastCibil();
                }
                else if (this.applcntRec[0].CIBIL_Rerun__c == true) {
                  //  this.creditScore = this.applcntRec[0].Bureau_Score__c;
                  console.log('this.applcntRec[0].Bureau_Score__c--->' + this.applcntRec[0].Bureau_Score__c);
                  let creditScore = this.applcntRec[0].Bureau_Score__c ?  this.applcntRec[0].Bureau_Score__c :'0';
                  this.setCreditScore(creditScore);
                    this.rerunCibil = this.applcntRec[0].CIBIL_Rerun__c;
                }
                else {
                    this.refreshCibil();
                }
            }


            }
            else if (status === "Rejected") {
                this.errorMessage = "Rejected due to matched record"
                this.matchRecordLabel = integrChecklist[0].name;
                this.generateUrl("standard__recordPage", integrChecklist[0].Id, "view");
                this.utilityClose(lighticonAmlStatus);
                this.creditScore = "Cancelled";
                this.setCreditScore('Cancelled');
                this.reportVal = "true";
                this.isLink = false;
                this.view = "Cancelled";
                clearInterval(this.cibilInterval);
            }

        }, 200);

    }

    fetchLastCibil() {
        getUpdatedApplicantCibil({ applcntId: this.recordId })
            .then((result) => {
                console.log("result--" + JSON.stringify(result));
                let applcntLst = result.applList[0];
                let additionalMatchRecId = result.additionalMatchId !== "" ? result.additionalMatchId : "";
                let bureauRes = applcntLst.hasOwnProperty('Bureau_Results__r') ? applcntLst.Bureau_Results__r[0] : "";
                // this.creditScore = bureauRes.Bureau_Score__c;
                this.setCreditScore(bureauRes.Bureau_Score__c);
                if (additionalMatchRecId !== "") {
                    this.additionalMatchRecId = additionalMatchRecId;
                }
                if (bureauRes !== "") {
                    //this.clearInterCheck = true;
                    this.generateInstantUrlForReport(bureauRes);
                }
            })
            .catch((error) => {
                this.error = error;
                console.log('Error inside fetchLastCibil -- ' + JSON.stringify(this.error));
                //clearInterval(this.cibilInterval);
                this.errorMessage = "Some error has occured. Please contact System Administrator";
            });
    }

    refreshCibil() {
       // this.clearIntCounter = 0;
        console.log("calling refresh cibil");
        this.cibilInterval = setInterval(() => {
            if (this.clearInterCheck == true) {
                console.log("inside clearInterCheck", JSON.stringify(this.cibilInterval));
                console.log("inside clearInterCheckList", JSON.stringify(this.cibilIntervalList));
                this.cibilIntervalList.forEach(inputField => {
                    clearInterval(inputField);
                });
            }
            else {
                this.cibilIntervalList.push(this.cibilInterval);
                console.log("inside cibilInterval");
                this.clearIntCounter = this.clearIntCounter + Number(CibilInterval);
                getUpdatedApplicantCibil({ applcntId: this.recordId })
                    .then((result) => {
                        console.log("result--" + JSON.stringify(result));
                        let applcntLst = result.applList[0];
                        let additionalMatchRecId = result.additionalMatchId !== "" ? result.additionalMatchId : "";
                        let integrChecklistForCibil = {};
                        if (applcntLst.hasOwnProperty('Integration_Checklists__r')) {
                            integrChecklistForCibil.Response__c = applcntLst.Integration_Checklists__r[0];
                        }
                        else {
                            integrChecklistForCibil.Response__c = "";
                        }
                        let bureauRes = applcntLst.hasOwnProperty('Bureau_Results__r') ? applcntLst.Bureau_Results__r[0] : "";
                        if (this.checkCibilResp(integrChecklistForCibil) === true) {
                            let cibilApiError = integrChecklistForCibil.Response__c.API_Error__c;
                            console.log('cibilApiError', cibilApiError);
                            console.log('bureauRes.Bureau_Score__c', bureauRes.Bureau_Score__c);
                            this.setCreditScore(bureauRes.Bureau_Score__c);
                            if (additionalMatchRecId !== "") {
                                this.additionalMatchRecId = additionalMatchRecId;
                            }
                            if (cibilApiError) {
                                this.errorMessage = cibilApiError;
                                this.cibilOnClick = true;
                            }
                            if (bureauRes !== "") {
                                this.clearInterCheck = true;
                                this.generateUrlForReport(bureauRes);
                            }
                        }
                        else {
                            if (this.checkCounter() == false) {
                                this.refreshCibil();
                            }
                        }
                    })
                    .catch((error) => {
                        this.error = error;
                        console.log('Error inside getUpdatedApplicantCibil -- ' + JSON.stringify(this.error));
                        clearInterval(this.cibilInterval);
                        this.errorMessage = "Some error has occured. Please contact System Administrator";
                    });
            }

        }, Number(CibilInterval));
    }

    handleCreateCibilRequest() {
/*
        if(!this.isCibilReRunAllowed){//4733
            this.showToastMessage('Access Restricted','You do not have the access to Re-Run Cibil','error','sticky')
            return
        }*/
        this.errorMessage = undefined;
        console.log('In handleCreateCibilRequest--->', this.applcntList[0].Id);
        this.creditScore = '';
       // this.setCreditScore('');
        this.isGetCibilScoreDisabled = true;
        this.cibilOnClick = false;
        let iconArr = ["ReportVal"];
        for (let val of iconArr) {
            let lightIcon = this.template.querySelector(`lightning-icon[data-name=${val}]`);
            this.inProgressIcon(lightIcon);
        }
        createCibilRequest({
            recordId: this.applcntList[0].Id
        })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                this.refreshCibil();
                this.rerunCibil = false;
            })
            .catch(error => {
                this.error = error + ". Some error has occured. Please contact System Administrator";
            })
    }

    checkCounter() {
        let maxLimit = Number(CIbilMaxPollLimit);
        if (this.clearIntCounter > maxLimit) {
          //  this.creditScore = "Max Polling Limit Reached";
            this.setCreditScore('No response found. Please try later');
            clearInterval(this.cibilInterval);
         //   this.clearIntCounter = 0;
            this.clearInterCheck = true;
            return true;
        }
        return false;
    }

    checkCibilResp(integrChecklistForCibil) {
        console.log('JSON integrChecklistForCibil:' + JSON.stringify(integrChecklistForCibil));
        if (integrChecklistForCibil.Response__c !== "" || integrChecklistForCibil.Is_Response_In_Attachment__c == true) {
            return true;
        }
        else {
            return false;
        }

    }

    generateInstantUrlForReport(bureauRes) {
        let bureauResId = bureauRes.Id;
        getRelatedFilesByRecordId({ recordId: bureauResId })
            .then(result => {
                console.log('generateInstantUrlForReport result', result);
                let contentDocumentId = result.contentDocumentId !== "" ? result.contentDocumentId : "";
                let contentVersionId = result.contentVersionId !== "" ? result.contentVersionId : "";
                if (contentDocumentId !== "") {
                    this.reportVal = "View";
                    this.isLink = true;
                    this.contentDocumentId = contentDocumentId;
                    this.contentVersionId = contentVersionId;
                }
            })
            .catch(error => {
                this.error = error;
                console.log('Error inside getRelatedFilesByRecordId -- ' + JSON.stringify(this.error));
                this.errorMessage = "Some error has occured. Please contact System Administrator";
            });
    }

    clearRelatedCheck2 = false
    generateUrlForReport(bureauRes) {
        let bureauResId = bureauRes.Id;
        this.reportInterval = setInterval(() => {
            if (this.clearRelatedCheck2 == true) {
                console.log("inside clearRelatedCheck2");
                this.reportIntervalList.forEach(inputField => {
                    clearInterval(inputField);
                });
            }
            else {
                this.reportIntervalList.push(this.reportInterval);
                getRelatedFilesByRecordId({ recordId: bureauResId })
                    .then(result => {
                        let contentDocumentId = result.contentDocumentId !== "" ? result.contentDocumentId : "";
                        let contentVersionId = result.contentVersionId !== "" ? result.contentVersionId : "";
                        if (contentDocumentId !== "") {
                            this.clearRelatedCheck2 = true;
                            this.reportVal = "View";
                            this.isLink = true;
                            this.contentDocumentId = contentDocumentId;
                            this.contentVersionId = contentVersionId;
                            clearInterval(this.reportInterval);
                        }
                    })
                    .catch(error => {
                        this.error = error;
                        this.clearRelatedCheck2 = true;
                        console.log('Error inside getRelatedFilesByRecordId -- ' + JSON.stringify(this.error));
                        clearInterval(this.reportInterval);
                        this.errorMessage = "Some error has occured. Please contact System Administrator";
                    });
            }
        }, Number(CibilInterval));
    }

    previewFile() {
        cibilReportMobileView.open({
            domString : this.cibilHTMLString,
            contentDocumentId: this.contentDocumentId,
            size: 'full'
        }).then((result) => {
        });
    }

    shareOrDownloadFile() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.contentDocumentId
            }
        });
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            // mode: mode,
            mode: variant === 'error' ? 'sticky' : 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    clickedGetCibilButton(event) {
        this.checkCibilButton = event.detail;
    }

    @api nextHandler() {
        let applRec = this.applcntRec;
        const Obj = {};
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        let checkCreditScore = Number(this.creditScore);
        Obj.next = false;
        if (((this.errorMessage == "" || this.errorMessage == undefined) && (checkCreditScore != NaN && checkCreditScore != 0))
             && ((this.additionalMatchRecId === "") || (this.additionalMatchRecId !== "" && this.checkCibilButton === "true"))) {
            Obj.next = true;
        }
        else if(this.applcCustomerType == "Non Individual" || this.preApprovedApplication) {
            Obj.next = true;
        }
        else if (((this.errorMessage && this.errorMessage != undefined && this.errorMessage != "")) && applRec[0].RecordType.Name === "Applicant") {
            let loanApplId = applRec[0].Loan__r.Id;
            this.genericNavigateToPage('standard__recordPage', loanApplId, "view");
        }
        else if ((this.errorMessage && this.errorMessage != undefined && this.errorMessage != "") && (applRec[0].RecordType.Name === "Co-Applicant" || applRec[0].Recordtype.Name === "Guarantor" || applRec[0].RecordType.Name === "BO")) {
            Obj.next = true;
        }
        else if (this.checkCibilButton == "" && this.additionalMatchRecId != "") {
            this.showToastMessage("", "Please fetch details for Additional match before proceeding", "info", "dismissible");
        }
        console.log('Obj', Obj);
        if(Obj.next){
            const fields = this.loanApp;
            console.log('fields', fields);
            const recordInput = { fields };
            updateRecord(recordInput).then((data)=>{
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
            }).catch((error)=>{
                console.error('error is '+JSON.stringify(error))
            })
        }else{
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
       
    }

    setCreditScore(score){
        this.creditScore = score >=100 && score <=200 && (this.typeOfWheeler.data === "Four Wheeler" || this.typeOfWheeler.data === "Tractor"  || this.typeOfWheeler.data === "Commercial Vehicle" || this.typeOfWheeler.data ==='Construction Equipment') ? "-1" : score;
        if(score){
            setTimeout(() => {
                this.cibilColorRange();
             }, 100);
        }
            }

    @wire(getRecord, { recordId: "$contentVersionId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            let versionData = data.fields && data.fields.VersionData ? data.fields.VersionData.value : "";
            this.cibilHTMLString = atob(versionData);
            //this.template.querySelector('.elementHoldingHTMLContent').innerHTML = atob(versionData);
        } else if (error) {
            console.log("Error" + error);
        }
    }
}