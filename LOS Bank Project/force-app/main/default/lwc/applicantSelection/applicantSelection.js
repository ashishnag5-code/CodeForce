import { LightningElement,api } from 'lwc';
import getApplicants from '@salesforce/apex/Utility.getApplicants';

export default class ApplicantSelection extends LightningElement {
    // API Attributes
    @api key;
    @api recordVal;
    @api labelText;

    // Array Attributes
    applicantOptions = [];
    applicantTypes = [];
    applicantsData = [];
    applicantId;

    connectedCallback() {
        this.getApplicantsData();
    }

    getApplicantsData() {
        getApplicants({
                applicantId: this.recordVal
            })
            .then(data => {
                if (data) {
                    let options = [];
                    let applicantTypes = [];
                    this.applicantsData = data;
                    for (var key in data) {
                        options.push({
                            label: (data[key].First_Name__c ?? '') + ' ' + (data[key].Last_Name__c ?? ''),
                            value: data[key].Id
                        });

                        applicantTypes.push(data[key].RecordType.Name);
                    }
                    this.applicantOptions = options;
                    if(options.length === 1){
                        const [ { value: defaultApplicant } ] = options;
                        this.applicantId = defaultApplicant;
                        this.handleChange({ target: { value: defaultApplicant } });
                    }
                    this.applicantTypes = applicantTypes;
                }
            })
            .catch(error => {
                console.log('error in getApplicantsData' + error);

            })
    }

    handleChange(event) {
        this.dispatchEvent(new CustomEvent('selection', {
            detail: event
        }));
    }
}