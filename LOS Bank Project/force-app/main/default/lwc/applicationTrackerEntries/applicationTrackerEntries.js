import { LightningElement, api } from 'lwc';

export default class ApplicationTrackerEntries extends LightningElement {
    className = 'slds-timeline__item_expandable slds-timeline__item_task';
    isExpanded = false;
    @api stepLabel;
    @api ownerDetails = [];
    @api stepStatus;
    @api iconName;

    expandCollapse() {
        if (this.isExpanded) {
            this.isExpanded = false;
            this.className = 'slds-timeline__item_expandable slds-timeline__item_task';
        } else {
            this.isExpanded = true;
            this.className = 'slds-timeline__item_expandable slds-is-open slds-timeline__item_task';
        }
    }
}