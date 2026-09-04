import { LightningElement, api, track } from 'lwc';
import getApplicantRecord from '@salesforce/apex/LosAdditionalMatchController.getApplicant';
import createCibilRequest from '@salesforce/apex/LosAdditionalMatchController.createCibilRequest';
import getUpdatedApplicantCibil from '@salesforce/apex/Aml.getUpdatedApplicantCibil';
import getRelatedFilesByRecordId from '@salesforce/apex/Aml.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation';
import CibilInterval from '@salesforce/label/c.Cibil_Interval';
import CIbilMaxPollLimit from '@salesforce/label/c.CIbil_Max_Poll_Limit';
import CIBIL_Addtional_ByPass from '@salesforce/label/c.CIBIL_Addtional_ByPass';


export default class LosAdditionalMatchCibil extends NavigationMixin(LightningElement) {
    @api recordId;
    @track applicantRecord = [];
    @track integCheckForCibilInd = [];
    cibilIntervalList = [];
    reportIntervalList = [];
    isApplicantVisible = false;
    isModalOpen = false;
    error;
    cibilInterval;
    creditScore = '';
    reportVal = '';
    reportInterval;
    contentDocumentId = '';
    isGetCibilScoreDisabled = false;
    clearInterCheck;
    clearRelatedCheck;
    fetchCibil = true;
    onClick;
    rerunCibil = false;
    CIBIL_Addtional_ByPass = CIBIL_Addtional_ByPass;

    connectedCallback() {
        console.log('In Additonal Match ConnectedCallBack');
        this.getApplicant();
    }

    getApplicant() {
        getApplicantRecord({
            recordId: this.recordId
        })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                if (result != null && result.length > 0) {
                    this.isApplicantVisible = true;
                    console.log('result is ' + JSON.stringify(result[0]));
                    this.applicantRecord = result[0];

                    if (this.applicantRecord.CIBIL_Status__c == 'Skipped') {
                        this.fetchLastCibil();
                    }
                    else if (this.applicantRecord.CIBIL_Rerun__c == true) {
                        this.creditScore = this.applicantRecord.Bureau_Score__c;
                        this.rerunCibil = this.applicantRecord.CIBIL_Rerun__c;
                        this.fetchCibil = false;
                    }
                    if(this.CIBIL_Addtional_ByPass != "true"){
                        const selectedEvent = new CustomEvent("clickedgetcibilbutton", { 
                            detail: "true"
                        });
                        this.dispatchEvent(selectedEvent); 
                    }
                   
                }

            })
            .catch(error => {
                this.error = error + ". Some error has occured. Please contact System Administrator";
            })
    }

    inProgressIcon(getLighticon) {
        getLighticon.iconName = "utility:spinner";
        getLighticon.variant = "warning";
    }

    handleCreateCibilRequest() {
        this.isGetCibilScoreDisabled = true;
        this.fetchCibil = false;
        this.onClick = false;
        let iconArr = ["ReportVal"];
        for (let val of iconArr) {
            let lightIcon = this.template.querySelector(`lightning-icon[data-name=${val}]`);
            this.inProgressIcon(lightIcon);
        }
        createCibilRequest({
            recordId: this.recordId
        })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                //this.refreshCibil();
                let applicant = result;
                if (applicant.CIBIL_Status__c == 'Skipped') {
                    this.fetchLastCibil();
                }
                else {
                    this.refreshCibil();
                    this.rerunCibil = false;
                }
                const selectedEvent = new CustomEvent("clickedgetcibilbutton", {
                    detail: "true"
                });
                this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                this.error = error + ". Some error has occured. Please contact System Administrator";
            })
    }



    fetchLastCibil() {
        this.isGetCibilScoreDisabled = true;
        this.fetchCibil = false;
        this.onClick = false;
        getUpdatedApplicantCibil({ applcntId: this.recordId })
            .then((result) => {
                console.log("result--" + JSON.stringify(result));
                let applcntLst = result.applList[0];
                let bureauRes = applcntLst.hasOwnProperty('Bureau_Results__r') ? applcntLst.Bureau_Results__r[0] : "";

                this.creditScore = bureauRes.Bureau_Score__c;

                if (bureauRes !== "") {
                    this.generateInstantUrlForReport(bureauRes);
                    const selectedEvent = new CustomEvent("clickedgetcibilbutton", {
                        detail: "true"
                    });
                    this.dispatchEvent(selectedEvent);
                }

            })
            .catch((error) => {
                this.error = error + ". Some error has occured. Please contact System Administrator";
                console.log('Error inside fetchLastCibil -- ' + JSON.stringify(this.error));
                //clearInterval(this.cibilInterval);
            });
    }

    refreshCibil() {
        let clearIntCounter = 0;
        this.cibilInterval = setInterval(() => {
            if (this.clearInterCheck == true) {
                console.log("inside clearInterCheck");
                console.log("inside clearInterCheck", JSON.stringify(this.cibilInterval));
                console.log("inside clearInterCheckList", JSON.stringify(this.cibilIntervalList));
                this.cibilIntervalList.forEach(inputField => {
                    clearInterval(inputField);
                });
            }
            else {
                this.cibilIntervalList.push(this.cibilInterval);
                clearIntCounter = clearIntCounter + Number(CibilInterval);
                console.log('Calling cibil');
                getUpdatedApplicantCibil({ applcntId: this.recordId })
                    .then((result) => {
                        console.log("result--" + JSON.stringify(result));
                        let applcntLst = result.applList[0];
                        let integrChecklistForCibil = {};
                        if (applcntLst.hasOwnProperty('Integration_Checklists__r')) {
                            integrChecklistForCibil.Response__c = applcntLst.Integration_Checklists__r[0];
                        }
                        else {
                            integrChecklistForCibil.Response__c = "";
                        }
                        let bureauRes = applcntLst.hasOwnProperty('Bureau_Results__r') ? applcntLst.Bureau_Results__r[0] : "";
                        if (this.checkCibilResp(integrChecklistForCibil) === true) {
                            console.log('In If ');
                            this.creditScore = bureauRes.Bureau_Score__c;
                            let apiError = integrChecklistForCibil.Response__c.API_Error__c;
                            if (bureauRes.Bureau_Score__c === "" || apiError !== "") {
                                // this.creditScore = "API Failed";
                                this.error = apiError;
                                this.onClick = true;
                            }
                            if (bureauRes !== "") {
                                this.clearInterCheck = true;
                                this.generateUrlForReport(bureauRes);
                            }
                            // clearInterval(this.cibilInterval);
                            // this.checkCounter(clearIntCounter);
                        }
                        else {
                            console.log('In Else ')
                            if (this.checkCounter(clearIntCounter) == false) {
                                this.refreshCibil();
                            }
                        }
                    })
                    .catch((error) => {
                        this.error = error + ". Some error has occured. Please contact System Administrator";
                        console.log('Error inside getUpdatedApplicantCibil -- ' + JSON.stringify(this.error));
                        clearInterval(this.cibilInterval);
                    });
            }
        }, Number(CibilInterval));
    }

    checkCounter(clearIntCounter) {
        if (clearIntCounter > Number(CIbilMaxPollLimit)) {
            this.creditScore = "Max Polling Limit Reached";
            clearInterval(this.cibilInterval);
            this.clearInterCheck = true;
            return true;
        }
        return false;
    }

    checkCibilResp(integrChecklistForCibil) {
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
                if (contentDocumentId !== "") {
                    this.reportVal = "View";
                    this.isLink = true;
                    this.contentDocumentId = contentDocumentId;
                }
            })
            .catch(error => {
                this.error = error;
                console.log('Error inside getRelatedFilesByRecordId -- ' + JSON.stringify(this.error));
                this.errorMessage = "Some error has occured. Please contact System Administrator";
            });
    }

    generateUrlForReport(bureauRes) {
        let bureauResId = bureauRes.Id;
        this.reportInterval = setInterval(() => {
            if (this.clearRelatedCheck == true) {
                console.log("inside clearRelatedCheck");
                //clearInterval(this.reportInterval);
                this.reportIntervalList.forEach(inputField => {
                    clearInterval(inputField);
                });
            }
            else {
                this.reportIntervalList.push(this.reportInterval);
                getRelatedFilesByRecordId({ recordId: bureauResId })
                    .then(result => {
                        let contentDocumentId = result.contentDocumentId !== "" ? result.contentDocumentId : "";
                        if (contentDocumentId !== "") {
                            this.clearRelatedCheck = true;
                            this.reportVal = "View";
                            this.contentDocumentId = contentDocumentId;
                            clearInterval(this.reportInterval);
                        }
                    })
                    .catch(error => {
                        this.error = error + ". Some error has occured. Please contact System Administrator";
                        this.clearRelatedCheck = true;
                        console.log('Error inside getRelatedFilesByRecordId -- ' + JSON.stringify(this.error));
                        clearInterval(this.reportInterval);
                    });
            }
        }, Number(CibilInterval));
    }

    previewFile() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.contentDocumentId
            }
        })
    }
}