import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import AUBranding from '@salesforce/resourceUrl/AUBranding';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
/*import Loan_Number from "@salesforce/schema/Loan_Application__c.Loan_Number__c";
import Loan_Amount from "@salesforce/schema/Loan_Application__c.Loan_Amount__c";
import E_Mandate_Status__c from "@salesforce/schema/Loan_Application__c.E_Mandate_Status__c";
import EMI_Date from "@salesforce/schema/Loan_Application__c.EMI_Date__c";
import EMI_Amount from "@salesforce/schema/Loan_Application__c.EMI__c";
import SPDC_Details__c from "@salesforce/schema/Loan_Application__c.SPDC_Details__c";
import PDC_Details__c from "@salesforce/schema/Loan_Application__c.PDC_Details__c";
import Repayment_Mode__c from "@salesforce/schema/Loan_Application__c.Repayment_Mode__c";
import Count_of_ACH_SI__c from "@salesforce/schema/Loan_Application__c.Count_of_ACH_SI__c";
import RecordTypeId from "@salesforce/schema/Loan_Application__c.RecordTypeId";
import Repayment_Bank_Name__c from "@salesforce/schema/Loan_Application__c.Repayment_Bank_Name__c";
import Repayment_Account_Number__c from "@salesforce/schema/Loan_Application__c.Repayment_Account_Number__c";
import TENURE from "@salesforce/schema/Loan_Application__c.Tenure__c";
import Emandate_Journey__c from "@salesforce/schema/Loan_Application__c.Emandate_Journey__c";
import Emandate_Payment_Type__c from "@salesforce/schema/Loan_Application__c.Emandate_Payment_Type__c";
//import sendEnquiryDetails from '@salesforce/apex/EMandateService.sendEnquiryDetails';
import saveDetails from '@salesforce/apex/EMandateService.saveDetails';
import sendRegistrationDetails from '@salesforce/apex/EMandateService.sendRegistrationDetails';
//import getBankAccountRecords from '@salesforce/apex/RepaymentController.getBankAccountRecords';
//import saveRepaymentDetails from '@salesforce/apex/RepaymentController.saveRepaymentDetails';
import AcceptedFileFormate from '@salesforce/label/c.AcceptedFileFormate';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import getCASADetails from '@salesforce/apex/RepaymentController.getCASADetails';
import getDocumentRecordsData from '@salesforce/apex/RepaymentController.getDocumentRecordsData';
import deactivateDocument from '@salesforce/apex/LOSDocumentManagerController.deactivateDocument'
import { NavigationMixin } from "lightning/navigation";
import uploadSIForm from '@salesforce/apex/RepaymentController.uploadSIForm';
import uploadACHForm from '@salesforce/apex/RepaymentController.uploadACHForm';
import checkIfEsignEnabled from '@salesforce/apex/SignDeskEsignApiController.checkIfEsignEnabled'
import FORMFACTOR from '@salesforce/client/formFactor'
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import getBankName from '@salesforce/apex/RepaymentController.getBankName';
import uploadFile from '@salesforce/apex/ChecqueOCRController.chequeOcrCallOut';
import getValidBankNameAndIFSC from '@salesforce/apex/RepaymentController.getValidBankNameAndIFSC'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getValidRecordId from '@salesforce/apex/OpsSummaryPageController.getValidRecordId';*/



const fields = [ 'Assignment__c.Loan_Application__c', 'Assignment__c.Loan_Application__r.Name'];

export default class LosRepaymentComponentAssignment extends LightningElement {
    @api recordId;
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('wire called'+JSON.stringify(data));
            
        }
        if(error){
            console.log('error '+JSON.stringify(error));
        }

    }
    
}