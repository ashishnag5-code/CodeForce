import { LightningElement } from 'lwc';
const data = [
{ id: 1, noa: 'NEERAJ KAUNDAL JAGTAP', nof: 'AU SFB', tol: 'Auto Loan (Personal)', la : '1,00,000', cop : '40,000', roi : '41.40', noep : '36', tm : '12' , esd : '01-12-2018', eea : '5,000' , stts : 'Closed' , rd : '01-12-2018', ecfo : 'No', rmrk : 'NA'  },
{ id: 2, noa: 'NEERAJ KAUNDAL JAGTAP', nof: 'AU SFB', tol: 'Auto Loan (Personal)', la : '1,00,000', cop : '40,000', roi : '41.40', noep : '36', tm : '12' , esd : '01-12-2018', eea : '5,000' , stts : 'Closed' , rd : '01-12-2018', ecfo : 'No', rmrk : 'NA'  },
{ id: 3, noa: 'NEERAJ KAUNDAL JAGTAP', nof: 'AU SFB', tol: 'Auto Loan (Personal)', la : '1,00,000', cop : '40,000', roi : '41.40', noep : '36', tm : '12' , esd : '01-12-2018', eea : '5,000' , stts : 'Open' , rd : '01-12-2018', ecfo : 'No', rmrk : 'NA'   }

];
const columns = [
{ label: 'Applicant Name', fieldName: 'noa' },
{ label: 'Financier Name', fieldName: 'nof' },
{ label: 'Loan Type', fieldName: 'tol' },
{ label: 'Loan Amount', fieldName: 'la' },
{ label: 'POS', fieldName: 'cop' },
{ label: 'ROI', fieldName: 'roi' },
{ label: 'EMI Paid(No.)', fieldName: 'noep' },
{ label: 'Tenure(Months)', fieldName: 'tm' },
{ label: 'EMI Start Date', fieldName: 'esd' },
{ label: 'Estimated EMI', fieldName: 'eea' },
{ label: 'Status', fieldName: 'stts' },
{ label: 'Reported Date ', fieldName: 'rd' },
{ label: 'EMI(Obligation)', fieldName: 'ecfo' },
{ label: 'Remarks', fieldName: 'rmrk' }
];
export default class RtrStubComponent extends LightningElement {
data = data;
columns = columns;
}