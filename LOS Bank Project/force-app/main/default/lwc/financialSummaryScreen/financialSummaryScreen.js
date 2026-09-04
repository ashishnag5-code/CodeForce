import { LightningElement,api } from 'lwc';

export default class FinancialSummaryScreen extends LightningElement {
    @api applicantsSummaryData;
    activeSections = ['A', 'B'];
    activeSubSections = ['B', 'C']


}