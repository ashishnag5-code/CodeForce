import { LightningElement, api, wire } from 'lwc';
import getDuplicateLoans from '@salesforce/apex/AUSFLeadDedupeCRMController.getDuplicateLoans';
import leadDedupeTitle from '@salesforce/label/c.LeadDedupeTitle';
import { reduceErrors } from 'c/lwcutilities';
import { getSpinnerImage } from 'c/customSpinner';

export default class AusfLeadDedupeCRM extends LightningElement {

    @api recordId;
    duplicateLoans = [];
    applicant = {};
    applicableDedupeActions = [ 'Partial', /*'Lead - Other Products'*/ ];
    activeSections = [ /*leadDedupeTitle*/ ];
    spinnerImage;
    isLoading = true;
    labels = { leadDedupeTitle };

    @wire(getDuplicateLoans, { leadId: '$recordId' })
    wiredLeadDetails({ error, data }){
        if( error ){
            this.error = reduceErrors(error);
            this.isLoading = false;
        } else if( data ){
            this.duplicateLoans = data.map(item => {
                const _item = { ...item };
                if( !_item.applicant.CreatedBy ){
                    return { ..._item, applicant: { ..._item.applicant, CreatedBy: _item.applicant.Loan__r.CreatedBy } };
                }
                return _item;
            });
            this.setSpinner();
            console.log(' === matching loans ==', data);
        }
    }

    get hasDuplicates(){
        return !!this.duplicateLoans?.length;
    }

    async setSpinner(recordId){
        let data = await getSpinnerImage(recordId);
        console.log(data);
        this.spinnerImage = data;
        this.isLoading = false;
    }

}