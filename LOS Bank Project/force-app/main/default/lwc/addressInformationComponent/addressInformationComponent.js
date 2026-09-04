import { LightningElement, api,wire,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getStateValues from '@salesforce/apex/AddressComponentHandler.getLocations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicantAddress from '@salesforce/apex/AddressComponentHandler.getApplicantAddress';
import calculateDistance from '@salesforce/apex/AddressComponentHandler.calculateDistance';
import getAddressInfo from '@salesforce/apex/AddressComponentHandler.getAddressInfo';
import getProductMetadataValues from '@salesforce/apex/AddressComponentHandler.getProductMetadataValues';
import NAME_FIELD from '@salesforce/schema/Address__c.Address_Line_1__c';
import ADDRESS_FIELD from '@salesforce/schema/Address__c.Address_Line_2__c';
import STATE_FIELD from '@salesforce/schema/Address__c.State__c';
import CITY_FIELD from '@salesforce/schema/Address__c.City__c';
import DISTRICT_FIELD from '@salesforce/schema/Address__c.District__c';
import ADDRESSTYPE_FIELD from '@salesforce/schema/Address__c.Address_Type__c';
import ADDRESS_OBJECT from '@salesforce/schema/Address__c';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import getApplicantCustomerType from '@salesforce/apex/AddressComponentHandler.getApplicantCustomerType';
import { createRecord, updateRecord,getRecord } from 'lightning/uiRecordApi';
import Applicant_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Applicnat_Deemed_FIELD from '@salesforce/schema/Applicant__c.Deemed_KYC__c';
import BIOMETRIC_ADDRESS_CHANGED_FIELD from '@salesforce/schema/Applicant__c.Is_Biometric_Address_Changed__c';
import ETB_ADDRESS_CHANGED_FIELD from '@salesforce/schema/Applicant__c.Is_ETB_Address_Changed__c';
import Applicant_Risk_FIELD from '@salesforce/schema/Applicant__c.Risk_Identification__c';
import getAddressMatchAPI from '@salesforce/apex/AddressComponentHandler.getAddressMatchAPI';
import APPLICANT_2W_RISK_CATEGORY from '@salesforce/schema/Applicant__c.X2W_Risk_Category__c';
import getRiskCategoryBasedOnRiskIdentification from '@salesforce/apex/AddressComponentHandler.getRiskCategoryBasedOnRiskIdentification';
import getNegativeAreaMasterRecords from '@salesforce/apex/AddressComponentHandler.getNegativeAreaMasterRecords';
import DeemedCurrentAddress from '@salesforce/label/c.DeemedCurrentAddress';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import FORM_FACTOR from "@salesforce/client/formFactor";
import ResidenBRELabel from '@salesforce/label/c.Residence_BRE';
import StabilityBRELabel from '@salesforce/label/c.Stability_BRE';
import DistanceBRELabel from '@salesforce/label/c.Distance_BRE'; 
import getValidTakenFromValues from '@salesforce/apex/AddressComponentHandler.getValidTakenFromValues';  
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit';
import sendDeemedNotification from  '@salesforce/apex/AddressComponentHandler.sendDeemedNotification';
import getLoanApplicationDetails from '@salesforce/apex/AddressComponentHandler.getLoanApplicationDetails';
import { TRACTOR_PRODUCT_CODES as OFFICE_ADDRESS_INELIGIBLE_PRODUCTS } from 'c/lwcutilities'; //Addition of new cow products
// R2-19
import getCVDocumentValidation from '@salesforce/apex/AddressComponentHandler.getCVDocumentValidation';//R2-39

export default class RecordEditFormEditExampleLWC extends NavigationMixin(LightningElement) {
    editAdress = false;
    addinformation = false;
    stateValue = '';
    cityValue = '';
    talukaValue = '';
    areaValue = '';
    addressLine1Value = '';
    addressLine2Value = '';
    addressLine3Value = '';
    addressTypeValue = '';
    PincodeValue = '';
    pinCodeVal = '';
    LandMarkValue = '';
    @api recordId;
    @api applicantId;
    @api loanApplication;
    vehicleUsage;

    verifiedAddressTakenValues = [];
    applicantDetailsToBeUpdated = {}
    stateOptions = [];
    cityOptions = [];
    districtOptions = [];
    talukaOptions = [];
    areaOptions = [];
    areaTypeOptions = [];
    stabilityOptions = [];
    residenceStatusOptions = [];
    residenceTypeOptions = [];
    @track addressTakenFromOptions = [];
    fields = [NAME_FIELD, ADDRESS_FIELD, STATE_FIELD, CITY_FIELD, ADDRESSTYPE_FIELD];
    recordformId = '';
    showrecordform = false;
    addressLst = [];
    editRecordId;
    showAddressInsertion = true;
    addressTypes;
    recordCount;
    @track addressList;
    addressApplicationRecord = {};
    showMainSection = true;
    areNameValue;
    areaTypeValue;
    selectedAddresstype;
    selectedProduct;
    viewMorePartial = false
    residenceStatusTypeValue = '';
    stabilityValue = '';
    addressTakenFromValue = '';
    residenceStatusValue = '';
    isLoading = false;
    @api spinnerImage;
    showOfficeLabels = false;
    sameAsOptions = [];
    counter = 0;
    @track sameasValue = '';
    showSameAsDropDown = true;
    OfficeNoValue = '';
    DistanceFrmBranchValue;
    showingwarningIcon = false;
    appId;
    selectedRecords = {};
    customerType;
    OfficeEmailIdValue = "";
    copyDisabled = false;
    residentialStatus;
    isNRIApplicant = false;

    addressLine1disabled = false;
    addressLine2disabled = false;
    addressLine3disabled = false;
    pincodedisabled = false;
    statedisabled = false;
    citydisabled = false;
    districtdisabled = false;
    areadisabled = false;
    talukdisabled = false;
    areatypedisabled = false;
    landmarkdisabled = false;
    statusdisabled = false;
    typedisabled = false;
    stabilitydisabled = false;
    residenceTypeDisabled = false;
    addresstakendisabled = false;
    maxCharLimit = 35;
    minCharLimit = 1; //R2-2436
    maxPincodeLimit = 6;
    rcoEnabled = false;
    showDistance = false;
    NonIndvidual = false;
    officenumberdisabled=false;
    officeemaildisabled=false;
    addressTypeDisabled = false;
    kycType = '';
    breTrackingFieldList=[];
    constitutionType = '';
    disabledOffice = false;
    loanStage;
    @track isTractorLoan
    @track isCE
    @track isCV
    @track isLandAddress
    @track materialFields

    isPermanentAddress = false; //25 JUL
    @track addressEditRestricted=false //SFAU-4295
    label = {
        ResidenBRELabel,
        StabilityBRELabel,
        DistanceBRELabel
    };
    sameASValueOnEdit ;
    @track blnRestrictEdit = false;
    @track blnGoNext = false;
    //2 Aug || START || SFAU-4494
    areaNewDisabled = false; 
    stabilityNewDisabled=false;
    landmarkNewDisabled=false;
     //2 Aug || END
     restrictCurrentSave = false; //R2-2405
    isNaApplicable; //R2-2352

     addressTakenFromCBS = '';  // SFAU-5716
     isTwoWheeler; // SFAU-5716
    // R2-2808
    isPermanentFormDisabledCalled = false;
    // R2-2808

    
      // R2 2360

      khataSurveyNo;
      village;

      tractorSpecificFieldDisabled = false;

      get addressTakenFromOptionsLand(){
        return  [
            { label: '7/12 Extract  / 8-A / Khasra', value: '7/12 Extract  / 8-A / Khasra' },
            { label: 'Jamabandi / Khatauni / Patta', value: 'Jamabandi / Khatauni / Patta' },
            { label: 'Fard', value: 'Fard' },
            { label: 'Land Nakal / Any other Valid Land Document', value: 'Land Nakal / Any other Valid Land Document' },
            { label: 'Lease Agreement', value: 'Lease Agreement' },
            { label: 'J-Form', value: 'J-Form' },
            { label: 'Kishan Credit Card', value: 'Kishan Credit Card' },
        ];
    }

    // R2 2360

    async connectedCallback() {
        this.isMobileScreen = (FORM_FACTOR == 'Small');
        this.getApplicants();
        let options=[];
        options.push({
            label: '0-1 Year',
            value: '1'
        });
        
        options.push({
            label: '1-2 Year',
            value: '2'
        });

        options.push({
            label: '2-3 Year',
            value: '3'
        });

        options.push({
            label: '3-4 Year',
            value: '4'
        });

        options.push({
            label: '4-5 Year',
            value: '5'
        });

        options.push({
            label: '5-6 Year',
            value: '6'
        });

        options.push({
            label: '6+ Year',
            value: '7'
        });
        this.stabilityOptions = options;
        //SFAU-4295 start
        const applicantLoanDetails = await getLoanApplicationDetails({applicantId: this.appId})
        if(applicantLoanDetails){
            if(applicantLoanDetails.Loan__r.OPS_KYC_Action__c == 'Approve'){
                this.addressEditRestricted=true
            }
            //R2-37
            if(applicantLoanDetails.Loan__r.RecordType.DeveloperName=='Tractor'){
                this.isTractorLoan=true
            }
            if(applicantLoanDetails.Loan__r.RecordType.DeveloperName=='Construction Equipment'){
                this.isCE=true
            }
            if(applicantLoanDetails.Loan__r.RecordType.DeveloperName=='Commercial Vehicle'){
                this.isCV=true
            }
            if(applicantLoanDetails.Loan__r.Stage__c!=''){
                this.loanStage=applicantLoanDetails.Loan__r.Stage__c;
            }
            this.vehicleUsage = applicantLoanDetails.Loan__r.Original_Vehicle_Usage__c;
        }
        //SFAU-4295 end
        //R2-39 start
        if(applicantLoanDetails.Loan__r.RecordType.DeveloperName=='Commercial_Vehicle' && applicantLoanDetails.RecordType.DeveloperName=='Primary_Applicant'){
            const cvValidation = await getCVDocumentValidation({loanId: applicantLoanDetails.Loan__c})
            if(cvValidation){
                this.showToastMessage("", cvValidation, "warning", "sticky");
            }
        }
        //end
        
    }

  
    
    @api
    getApplicants() {
        //let appId;
        if (this.recordId != null) {
            this.appId = this.recordId;
        } else {
            this.appId = this.applicantId.Id;
            this.customerType = this.applicantId.Customer_Type__c;
            this.loanId = this.applicantId.Loan__r ? this.applicantId.Loan__r.Id : this.recordId;
        }


        // if (this.applicantId.Id != undefined && this.applicantId.Id!=null) {
        if (this.appId != undefined && this.appId != null) {
            getApplicantAddress({
                    recId: this.appId
                })
                .then(data => {
                    if(this.customerType == 'Non Individual'){
                        this.constitutionType = data.constitutionType;
                        this.assignAddressOptionsNonInd();
                    }
                    this.addressTakenFromCBS = data.addressTakenFromCBS; // SFAU-5716
                    this.isTwoWheeler = data.isTwoWheeler;
                    this.addressLst = data.applicantAddressList!=null ? data.applicantAddressList :null;
                    if(this.addressLst && this.addressLst.length>0){
                        this.addressLst.forEach(input=>{
                            input.isLandAddress = input.Address_Type__c=='Land'?true:false
                            input.isNotPermanentOrIsTouchPoint = !(input.Address_Type__c === 'Permanent' || input.Address_Type__c === 'Touch Point');
                        })
                    }
                    this.showAddressInsertion = data.boolIsAddressInsertionAllowed;
                    this.addressTypes = data.strAddressTypes;
                    this.recordCount = data.recCount;
                        this.selectedProduct = this.loanApplication?.Product__c ?? data.applicantAddressList?.[0]?.Product__c;
                    this.verifiedAddressTakenValues = data.verifiedAddressTakenSet;
                    this.loanId = this.loanId != undefined ? this.loanId : data.objApplicant.Loan__r.Id;
                   
                    let options = [];
                    this.existingAddress = data.strAddressTypes;
                    this.customerType = data.strCustomerType;
                    let allAddress;
                    if(this.customerType == 'Non Individual'){
                        allAddress = ['Current', 'Office'];
                        this.NonIndvidual = true;
                        //this.constitutionType = data.constitutionType;
                        //this.assignAddressOptionsNonInd();
                    }else{
                        allAddress = ['Permanent', 'Current', 'Office', 'Touch Point', 'Land'];
                    }
                     // R2 - 2360
                    const vehicleUsage = this.loanApplication?.Original_Vehicle_Usage__c ?? this.vehicleUsage;
                    this.isNaApplicable = this.isOfficeAddressApplicable( { ...this.loanApplication, Original_Vehicle_Usage__c: vehicleUsage } );
                    for (var key in allAddress) {
                        console.log('dataVal[key]' + allAddress[key]);
                        // R2-19 & // R2 - 2360
                        if (!this.existingAddress.includes(allAddress[key]) && ((!( OFFICE_ADDRESS_INELIGIBLE_PRODUCTS.includes( this.loanApplication?.Product__c ?? this.selectedProduct ) && (allAddress[key] === 'Office') && this.customerType === 'Individual' && vehicleUsage === 'Agri' ) ))) {
                            options.push({
                                label: allAddress[key],
                                value: allAddress[key]
                            });
                        }
                    }

                    this.addressList = options;


                    this.requiredfieldsValidationCheck();
                    
                    this.residentialStatus = data.strResidentialStatus;
                    this.kycType =  data.applicantAddressList?.[0]?.Applicant__r.KYC_Type__c;
                    this.checkRestrictRecord ();
                })
                .catch(error => {
                    let options = [];
                    this.selectedProduct = '10201';
                    console.log('error is ' + error);
                    options.push({
                        label: 'Permanent',
                        value: 'Permanent'
                    });
                    options.push({
                        label: 'Current',
                        value: 'Current'
                    });
                    options.push({
                        label: 'Office',
                        value: 'Office'
                    });
                    options.push({
                        label: 'Touch Point',
                        value: 'Touch Point'
                    });
                    this.addressList = options;

                    //this.accounts = undefined;
                })
            // check For Restrict Record
            
        } else {
            let options = [];
            options.push({
                label: 'Permanent',
                value: 'Permanent'
            });
            options.push({
                label: 'Current',
                value: 'Current'
            });
            options.push({
                label: 'Office',
                value: 'Office'
            });
            options.push({
                label: 'Touch Point',
                value: 'Touch Point'
            });
            this.addressList = options;
        }

        //Based on Customer Type load the address type options
        getApplicantCustomerType({
            recordId: this.appId
        }).then(data => {
            let options = [];
            if(data == 'Non Individual'){
                this.NonIndvidual = true;
                options.push({
                    label: 'Current',
                    value: 'Current'
                });
                options.push({
                    label: 'Office',
                    value: 'Office'
                });
            }else{
                options.push({
                    label: 'Permanent',
                    value: 'Permanent'
                });
                options.push({
                    label: 'Current',
                    value: 'Current'
                });
                options.push({
                    label: 'Office',
                    value: 'Office'
                });
                options.push({
                    label: 'Touch Point',
                    value: 'Touch Point'
                });
            }
            this.addressList = options;
        })  
        .catch(error => {
            
            //this.accounts = undefined;
        })
    }

    assignAddressOptionsNonInd(){
        let options = [];
        options.push({
            label: 'Utility Bills (Not more than 2 Months old)',
            value: 'Utility Bills (Not more than 2 Months old)'
        });
        options.push({
            label: 'Water Bill',
            value: 'Water Bill'
        });
        options.push({
            label: 'Telephone Bill',
            value: 'Telephone Bill'
        });
        options.push({
            label: 'Electricity Bill',
            value: 'Electricity Bill'
        });
        options.push({
            label: 'Post Paid Mobile Bill',
            value: 'Post Paid Mobile Bill'
        });
        options.push({
            label: 'Piped Gas Bill',
            value: 'Piped Gas Bill'
        });
        options.push({
            label: 'Sale Deed',
            value: 'Sale Deed'
        });

        if(this.constitutionType.includes('Sole')){
            options.push({
                label: 'Bank Statement (Not more than 4 Months old)',
                value: 'Bank Statement (Not more than 4 Months old)'
            });
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'Property Tax receipt',
                value: 'Property Tax receipt'
            });
            
        }
        else if(this.constitutionType.includes('Firm')){
            options.push({
                label: 'Bank Statement (Not more than 4 Months old)',
                value: 'Bank Statement (Not more than 4 Months old)'
            });
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'Property Tax receipt',
                value: 'Property Tax receipt'
            });
            options.push({
                label: 'PAN intimation Letter',
                value: 'PAN intimation Letter'
            });
        }
        else if(this.constitutionType.includes('Trust')){
            options.push({
                label: 'Bank Statement (Not more than 4 Months old)',
                value: 'Bank Statement (Not more than 4 Months old)'
            });
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'Property Tax receipt',
                value: 'Property Tax receipt'
            });
            options.push({
                label: 'PAN intimation Letter',
                value: 'PAN intimation Letter'
            });
        }
        else if(this.constitutionType.includes('Society') || this.constitutionType.includes('AOP')){
            options.push({
                label: 'Bank Statement (Not more than 4 Months old)',
                value: 'Bank Statement (Not more than 4 Months old)'
            });
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'Property Tax receipt',
                value: 'Property Tax receipt'
            });
            options.push({
                label: 'PAN intimation Letter',
                value: 'PAN intimation Letter'
            });
        }
        else if(this.constitutionType.includes('Limited Liability Partnership')){
            options.push({
                label: 'Bank Statement (Not more than 4 Months old)',
                value: 'Bank Statement (Not more than 4 Months old)'
            });
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'Property Tax receipt',
                value: 'Property Tax receipt'
            });
            options.push({
                label: 'PAN intimation Letter',
                value: 'PAN intimation Letter'
            });
            options.push({
                label: 'GST Certificate',
                value: 'GST Certificate'
            });
            options.push({
                label: 'Import/ Export Certificate in the name of LLP',
                value: 'Import/ Export Certificate in the name of LLP'
            });
        }
        else if(this.constitutionType.includes('HUF')){
            options = [];
            options.push({
                label: 'KYC of Karta',
                value: 'KYC of Karta'
            });
        }
        else if(this.constitutionType.includes('Public Limited') || this.constitutionType.includes('Private Limited')){
            options.push({
                label: 'Rent agreement',
                value: 'Rent agreement'
            });
            options.push({
                label: 'INC-22 or Form 18 along with ROC challan',
                value: 'INC-22 or Form 18 along with ROC challan'
            });
            options.push({
                label: 'PAN intimation Letter',
                value: 'PAN intimation Letter'
            });
        }
        this.addressTakenFromOptions = options;
    }

    handleAaadharPermanentAddress(addressDetails) {
        // R2-2808
        this.isPermanentFormDisabledCalled = true;
        // R2-2808
        for (var key in addressDetails) {
            if ((addressDetails[key].Address_Type__c == 'Permanent' && addressDetails[key].Address_Source__c == 'Aadhaar Card') && (this.kycType == 'Aadhaar - Biometric' || this.kycType == 'Aadhaar - OTP' || addressDetails[key].Source_Type__c == 'CBS' )) { //R2-2844
                this.addressTypeDisabled = true;
                if (addressDetails[key].Address_Line_1__c) {
                    this.addressLine1disabled = true;
                }
                if (addressDetails[key].Address_Line_2__c) {
                    this.addressLine2disabled = true;
                }
                if (addressDetails[key].Address_Line_3__c) {
                    this.addressLine3disabled = true;
                }
                if (addressDetails[key].Pincode__c) {
                    this.pincodedisabled = true;
                }
                if (addressDetails[key].State__c) {
                    this.statedisabled = true;
                    this.stateOptions.push({
                        label: addressDetails[key].State__c,
                        value: addressDetails[key].State__c
                    });
                    this.stateValue = addressDetails[key].State__c;
                }
                if (addressDetails[key].City__c) {
                    this.citydisabled = true;
                    this.cityOptions.push({
                        label: addressDetails[key].City__c,
                        value: addressDetails[key].City__c
                    });
                    this.cityValue = addressDetails[key].City__c;
                 
                }
                if (addressDetails[key].District__c) {
                    this.districtdisabled = true;
                    this.districtOptions.push({
                        label: addressDetails[key].District__c,
                        value: addressDetails[key].District__c
                    });
                    this.districtValue = addressDetails[key].District__c;
                }
               
                if (addressDetails[key].Taluka__c) {
                    this.talukdisabled = true;
                    this.talukaOptions.push({
                        label: addressDetails[key].Taluka__c,
                        value: addressDetails[key].Taluka__c
                    });
                    this.talukaValue = addressDetails[key].Taluka__c;
                }
               
                if (addressDetails[key].Land_mark__c) {
                    this.landmarkdisabled = true;
                }
            }else {
                this.addressLine1disabled = false
                this.addressLine2disabled = false;
                this.addressLine3disabled = false;
                this.pincodedisabled = false;
                this.statedisabled = false;
                this.citydisabled = false;
                this.districtdisabled = false;
                this.areadisabled = false;
                this.talukdisabled = false;
                this.areatypedisabled = false;
                this.landmarkdisabled = false;
                this.statusdisabled = false;
                this.typedisabled = false;
                this.stabilitydisabled = false;
                this.addresstakendisabled = false;
                this.officenumberdisabled = false;
                this.residenceTypeDisabled = false;
                this.officeemaildisabled = false;
                this.addressTypeDisabled = false;
                if (addressDetails[key].State__c) {
                    this.stateOptions.push({
                        label: addressDetails[key].State__c,
                        value: addressDetails[key].State__c
                    });
                    this.stateValue = addressDetails[key].State__c;
                }

                if (addressDetails[key].City__c) {
                    this.cityOptions.push({
                        label: addressDetails[key].City__c,
                        value: addressDetails[key].City__c
                    });
                    this.cityValue = addressDetails[key].City__c;
                }

                if (addressDetails[key].District__c) {
                    this.districtOptions.push({
                        label: addressDetails[key].District__c,
                        value: addressDetails[key].District__c
                    });
                    this.districtValue = addressDetails[key].District__c;
                }
                if (addressDetails[key].Taluka__c) {
                    this.talukaOptions.push({
                        label: addressDetails[key].Taluka__c,
                        value: addressDetails[key].Taluka__c
                    });
                    this.talukaValue = addressDetails[key].Taluka__c;
                }

                if (addressDetails[key].Address_Source__c != '') { //june29
                    let addOptions=[];
                    addOptions.push({
                        label: addressDetails[key].Address_Source__c,
                        value: addressDetails[key].Address_Source__c
                    });
                    this.addressTakenFromOptions = this.getUniqueValue(addOptions);
                    this.addressTakenFromValue = addressDetails[key].Address_Source__c;
                }
            }
        }

        // if( (this.addressTypeValue == 'Permanent' && addressDetails[key].Address_Source__c == 'Aadhaar Card') && (this.kycType != 'Aadhaar - Biometric' || this.kycType != 'Aadhaar - OTP') ){
        if ((this.addressTypeValue == 'Permanent')) {
            this.handleLoadOfficeOptions('Permanent');
        }

    }

    requiredfieldsValidationCheck() { //JUl 25
        let addressVal = this.addressLst;
        for (var key in addressVal) {
            if (addressVal[key].Address_Type__c == 'Permanent') {
                let addressline2 = addressVal[key].Address_Line_2__c;
                let areaType = addressVal[key].Area_Type__c;
                let pinCode = addressVal[key].Pincode__c;
                let city = addressVal[key].City__c;
                let type = addressVal[key].Type__c;
                let status = addressVal[key].Status__c;
                let stability = addressVal[key].Stability__c;
                if ((addressline2 == undefined || addressline2 == '') || (areaType == undefined || areaType == '')
                    || (pinCode == undefined || pinCode == '') || (city == undefined || city == '')  || (status == undefined || status == '')) {
                    this.showingwarningIcon = true;
                } else {
                    this.showingwarningIcon = false;
                }
            }
        }
    }

    @track existingAddress = [];
    getInitialValues() {
        getApplicantAddress({
                recId: this.applicantId.Id
            })
            .then(data => {
                this.addressLst = data.applicantAddressList;
                if(this.addressLst && this.addressLst.length>0){
                    this.addressLst.forEach(input=>{
                        input.isLandAddress = input.Address_Type__c=='Land'?true:false
                    })
                }
                
                this.showAddressInsertion = data.boolIsAddressInsertionAllowed;
                this.addressTypes = data.strAddressTypes;
                this.recordCount = data.recCount;
              
                  
            
                this.residentialStatus = data.strResidentialStatus;
                //this.selectedAddresstype = data.applicantAddressList[0].Address_Type__c;
                let options = [];
                this.existingAddress = data.strAddressTypes;

                this.customerType = data.strCustomerType;
                this.setAddressTypeOptions();
                if(data.applicantAddressList.length){
                    let applicantData = data.applicantAddressList[0];
                    if(applicantData.hasOwnProperty('Product__c')){
                        this.selectedProduct = data.applicantAddressList[0].Product__c;
                    }
                    
                }
                
                
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));

                //this.accounts = undefined;
            })
    }


    viewMoreHandler(event) {
        if (event != undefined && event.currentTarget.dataset != undefined) {
            if (event.currentTarget.dataset.recordName == 'ViewMoreInformation') {
                var recordId = event.currentTarget.dataset.id;
                this.viewMorePartial = true;

                let records = this.addressLst;
                let addressrecords = [];

                for (let i = 0; i < this.addressLst.length; i++) {
                    if (this.addressLst[i].Id == recordId) {
                        addressrecords.push(records[i]);
                    }
                }
                this.selectedRecords = addressrecords;
            }
        }
    }

    viewLessHandler(event) {
        this.viewMorePartial = false;
    }
    handleRecordForm(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        let addressValues = event.detail.fields.Address_Type__c;
        if (!this.addressTypes.includes(addressValues)) {
            fields.Applicant__c = this.appId;
            this.template.querySelector('lightning-record-form').submit(fields);
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Address Duplicate',
                    message: 'You cannot insert the ' + addressValues + ' Address',
                    variant: 'error'
                }),
            );
        }
    }
    handlerecordformSuccess(event) {
        console.info("END handleSuccess < ", event.detail.id, " >");
        this.recordformId = event.detail.id;
        this.addinformation = false;
    }
    handleCancelForm(event) {
        this.addinformation = false;
        this.handleReset();
    }

    handleReset() {
        this.addressTypeDisabled = false;
        this.addressLine1Value = null;
        this.addressLine2Value = null;
        this.addressLine3Value = null;
        this.stateValue = null;
        this.cityValue = null;
        this.districtValue = null;
        this.areNameValue = null;
        this.talukaValue = null;
        this.areaTypeValue = null;
        this.residenceStatusValue = null;
        this.residenceStatusTypeValue = null;
        this.stabilityValue = null;
        this.addressTakenFromValue = null;
        this.PincodeValue = null;
        this.pinCodeVal = null; //june29
        this.LandMarkValue = null;
        this.copyDisabled = false;
        this.DistanceFrmBranchValue = 0;
        // this.sameasValue ='';
        this.OfficeEmailIdValue =null; //july 28
        this.OfficeNoValue = null; //july 28
         //2 Aug || START
         this.disabledOffice = false;
         this.residenceTypeDisabled = false;
         this.areaNewDisabled = false; 
         this.stabilityNewDisabled=false;
         this.landmarkNewDisabled=false;
         //END

         // R2 2360
        this.village = null;
        this.khataSurveyNo = null;
         // R2 2360
    }

    handlePicklistChange(event) {
        var locationMetrics = event.currentTarget.dataset.name;
        if (locationMetrics == 'State__c') {
            this.stateValue = event.target.value;
        }
        if (locationMetrics == 'City__c') {
            this.cityValue = event.target.value;
        }
        if (locationMetrics == 'District__c') {
            this.districtValue = event.target.value;
        }
        if (locationMetrics == 'Taluka__c') {
            this.talukaValue = event.target.value;
        }
        if (locationMetrics == 'Area_Name__c') {
            this.areNameValue = event.target.value;
            if (this.selectedAddresstype == 'Permanent' || this.selectedAddresstype == 'Current' || this.addressTypeValue == 'Permanent' || this.addressTypeValue == 'Current') {
                this.breTrackingFieldList.push('Area_Name__c');
            }
        }
        if (locationMetrics == 'Area_Type__c') {
            this.areaTypeValue = event.target.value;
            if (this.selectedAddresstype == 'Permanent' || this.selectedAddresstype == 'Current' || this.addressTypeValue == 'Permanent' || this.addressTypeValue == 'Current') {
                this.breTrackingFieldList.push('Area_Type__c');
            }
        }
        if (locationMetrics == 'Status__c') {
            if (this.residenceStatusValue != this.label.ResidenBRELabel && event.target.value == this.label.ResidenBRELabel) { //ResidenBRELabel (Rented)
                if ( this.selectedAddresstype == 'Permanent' || this.addressTypeValue == 'Permanent' || this.selectedAddresstype == 'Touch Point' || this.addressTypeValue == 'Touch Point' || this.selectedAddresstype == 'Current' || this.addressTypeValue == 'Current') {  // Added for SFAU-3692
                    this.breTrackingFieldList.push('Status__c');   // Added for SFAU-3692
                }
            }
            this.residenceStatusValue = event.target.value;
        }
        if (locationMetrics == 'Type__c') {
            this.residenceStatusTypeValue = event.target.value;
        }
        if (locationMetrics == 'Stability__c') {
            let checkStability = false;
            if(this.selectedAddresstype == 'Office' || this.addressTypeValue == 'Office'){
                checkStability = true;
            }
            else if((!this.isTractorLoan && !this.isCE) && (this.selectedAddresstype == 'Permanent' || this.addressTypeValue == 'Permanent')){
                checkStability = true;
            }
            else if(!this.isTractorLoan && (this.selectedAddresstype == 'Current' || this.addressTypeValue == 'Current')){
                checkStability = true;
            }
            if(checkStability){
                this.breTrackingFieldList.push('Stability__c');
            }
            this.stabilityValue = event.target.value;
        }
        if (locationMetrics == 'Address_Source__c') {
            this.addressTakenFromValue = event.target.value;
            if(DeemedCurrentAddress.includes(this.addressTakenFromValue)){
                this.deemedValue = true;
            }else{
                this.deemedValue = false;
            }
        }
    }

    handleUpdateDeemed(){
        //update deemed kyc checkbox on applicant object
        const FIELDS = {};
        FIELDS[Applicant_ID_FIELD.fieldApiName] = this.appId;
        FIELDS[Applicnat_Deemed_FIELD.fieldApiName] = this.deemedValue; 
         /* SFAU-5716 - Start Kunal */
         if(this.sameasValue == 'Permanent' && this.kycType == 'Aadhaar - Biometric'){
            FIELDS[BIOMETRIC_ADDRESS_CHANGED_FIELD.fieldApiName] = false;
        }else{
            FIELDS[BIOMETRIC_ADDRESS_CHANGED_FIELD.fieldApiName] = true;
        }

        if(this.sameasValue == 'Permanent' && this.addressTakenFromCBS){
            FIELDS[ETB_ADDRESS_CHANGED_FIELD.fieldApiName] = false;
        }else{
            FIELDS[ETB_ADDRESS_CHANGED_FIELD.fieldApiName] = true;
        }
        /* SFAU-5716 - End Kunal */
        const recordInputForUpdate ={fields: FIELDS};
            updateRecord(recordInputForUpdate)
                .then(result => {
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,//error.body.output.fieldErrors,
                            variant: 'error',
                        }),
                    );
                });

    }

    handlePinCodeChange(event) {
        let pinCodeVal = event.target.value;
        this.PincodeValue = pinCodeVal;
        // this.addressApplicationRecord[event.target.name] = event.target.value;
        this.getPicklistOptionsDefault(pinCodeVal,true);
        // this.getDistance(pinCodeVal);
        if(this.selectedAddresstype == 'Current' && this.editAdress == true){//June29
            this.handleLoadOfficeOptions(this.selectedAddresstype);
        }
    }
    getPicklistOptionsDefault(pincodes,calledFromPincode) {
        this.isLoading = true;
        this.districtValue ='';
        this.talukaValue ='';
        getStateValues({
                pinCode: pincodes,
                applicantId: this.appId
            })
            .then(data => {
                if (data) {
                    this.stateOptions = this.getUniqueValue(data['State']);
                    this.cityOptions =this.getUniqueValue(data['City']);
                    this.areaOptions = this.getUniqueValue(data['Areaname']);
                    this.areaTypeOptions =this.getUniqueValue(data['AreaType']);
                    this.talukaOptions =this.getUniqueValue(data['Taluka']);
                    this.districtOptions =this.getUniqueValue(data['City']);
                   // this.stabilityOptions = this.getUniqueValue(data['Stability']);

                    // if there is only one option default the value
                    if (this.stateOptions.length == 1) {
                        this.stateValue = data['State'][0].value;
                    }else if(calledFromPincode){
                        this.stateValue = '';
                    }
                    if (this.cityOptions.length == 1) {
                        this.cityValue = data['City'][0].value;
                    }else if(calledFromPincode){
                        this.cityValue = '';
                    }
                    if (this.cityOptions.length == 1) {
                        this.districtValue = data['City'][0].value;
                   }else if(calledFromPincode){
                        this.districtValue = '';
                    }
                    if (this.talukaOptions.length == 1) {
                          this.talukaValue = data['Taluka'][0].value;
                    }else if(calledFromPincode){
                        this.talukaValue = '';
                    }
                    if (this.areaOptions.length == 1) {
                        this.areNameValue = data['Areaname'][0].value;
                    }else if(calledFromPincode){
                        this.areNameValue = '';
                    }
                    if (this.areaTypeOptions.length == 1) {
                        this.areaTypeValue = data['AreaType'][0].value;
                    }else if(calledFromPincode){
                        this.areaTypeValue = '';
                    }

                     //If pincode changes area name changes so it should be tracked
                     if(this.selectedAddresstype  =='Permanent' || this.selectedAddresstype =='Current' || this.addressTypeValue  =='Permanent' || this.addressTypeValue=='Current' ){
                        this.breTrackingFieldList.push('Area_Name__c');
                    }
                     
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    getPicklistOptions(pincodes) {
        this.isLoading = true;
        getStateValues({
                pinCode: pincodes,
                applicantId: this.appId
            })
            .then(data => {
                if (data) {
                    this.stateOptions = this.getUniqueValue(data['State']);
                   
                    if( this.districtValue!='' && this.districtValue!=null){
                    }else{
                        this.districtOptions =this.getUniqueValue(data['City']);
                    }
                    if( this.talukaValue!='' && this.talukaValue!=null){
                    }else{
                        this.talukaOptions =this.getUniqueValue(data['Taluka']);
                    }
                    
                    if( this.cityValue!='' && this.cityValue!=null){
                    }else{
                        this.cityOptions =this.getUniqueValue(data['City']);
                    }
                   
                    this.areaOptions = this.getUniqueValue(data['Areaname']);
                    this.areaTypeOptions =this.getUniqueValue(data['AreaType']);
                   // this.stabilityOptions = this.getUniqueValue(data['Stability']);

                    // if there is only one option default the value
                    if (this.stateOptions.length == 1) {
                        this.stateValue = data['State'][0].value;
                    }
                    if (this.cityOptions.length == 1) {
                        if(this.cityValue=='' ||this.cityValue ==null ){
                            this.cityValue = data['City'][0].value;
                        }
                    }
                    //if (this.districtOptions.length == 1) {
                        if(this.districtValue == '' || this.districtValue == null){
                              this.districtValue = data['City'][0].value;
                        }
                      
                   // }
                   // if (this.talukaOptions.length == 1) {
                        if(this.talukaValue == null || this.talukaValue ==''){
                             this.talukaValue = data['Taluka'][0].value;
                        }
                  //  }
                    if (this.areaOptions.length == 1) {
                        this.areNameValue = data['Areaname'][0].value;
                    }
                    if (this.areaTypeOptions.length == 1) {
                        this.areaTypeValue = data['AreaType'][0].value;
                    }
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    getUniqueValue(myList){
        let uniqueList = myList.reduce((accumulator, currentValue) => {
            if (!accumulator.find(item => JSON.stringify(item) === JSON.stringify(currentValue))) {
              accumulator.push(currentValue);
            }
            return accumulator;
          }, []);

          return uniqueList;
    }
    getDistance(pincodes) {
        this.isLoading = true;
        calculateDistance({
                toPincode: pincodes,
                strApplicantId: this.appId,
                addressType : this.selectedAddresstype
            })
            .then(data => {
                if (data) {
                    var distanceVal = JSON.parse(data);
                    console.log('response' + JSON.stringify(distanceVal));
                    var distance = distanceVal.result.estDistance;

                    //this.DistanceFrmBranchValue = distance; JUL 24
                    const breDistance = Decimal.valueof(this.label.DistanceBRELabel); 
                    if( distance >breDistance && distance <breDistance){
                       let tracked =[];
                        if((!this.isTractorLoan && !this.isCE) || this.selectedAddresstype  == 'Current'){
                            tracked.push('Distance_from_Branch__c');
                            this.breTrackingFieldList.push(tracked);
                        }
                    }

                    this.breRunMaterialFields();



                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('error in distance ' + JSON.stringify(error));
                this.showMessage('Distance Service is Down', 'warning');
                this.DistanceFrmBranchValue = 0;
                this.isLoading = false;
            })
    }

    allowSave = true;

    handleSubmit(event) {
        this.allowSave = true;
        let fields = event.detail.fields;
        if(this.addressTypeValue=='Land'){
            fields = {Id: this.editRecordId}
        }//R2-37
        //4733 Restrict Edit
        if(this.blnRestrictEdit){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Address Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }//4733 Restrict Edit
        //SFAU-4295 start
        if(this.addressEditRestricted){
            this.showMessage('Address cannot be changed as KYC is already Approved', 'error');
            return
        }
        // Added by kunal for SFAU-5397 --> if Same As Permanent is not checked then current address cannot have same address source as permanent. 
        if((this.addressTypeValue == 'Permanent' || this.addressTypeValue == 'Current') && !this.checkAddressSourceValidation()){
            this.allowSave = false;
            return;
        }
        //SFAU-4295 end
        // R2 2360
    //    if(this.addressTypeValue=='Land' && (!this.template.querySelector('c-land-address-component').isValidateGenericLookup() || !this.template.querySelector('c-land-address-component').handleValidations())){
    //             return
    //     }
       // R2 2360

        event.preventDefault();



        fields.State__c = this.stateValue;
        fields.City__c = this.cityValue;
        fields.District__c = this.districtValue;
        fields.Taluka__c = this.talukaValue;
        fields.Area_Name__c = this.areNameValue;
        fields.Status__c = this.residenceStatusValue;
        fields.Type__c = this.residenceStatusTypeValue;
        fields.Stability__c = this.stabilityValue;
        fields.Address_Source__c = this.addressTakenFromValue;
        fields.Address_Type__c = this.addressTypeValue;
        fields.Address_Line_1__c = this.addressLine1Value;
        fields.Address_Line_2__c = this.addressLine2Value;
        fields.Address_Line_3__c = this.addressLine3Value;
        fields.Area_Type__c = this.areaTypeValue;
        fields.Land_mark__c = this.LandMarkValue;
        fields.Distance_from_Branch__c = this.DistanceFrmBranchValue; //24 JUL
        fields.Pincode__c = this.PincodeValue;
        fields.Office_Number__c = this.OfficeNoValue;
        fields.Office_Email_address__c =this.OfficeEmailIdValue;

        // R2 2360
        fields.Khata_Khasara_Survey_Number__c = this.khataSurveyNo;
        fields.Village__c =this.village;
        // R2 2360

	if(this.addressTypeValue == 'Office' && this.sameasValue == 'NA') // Pooja
            fields.Same_As__c = 'NA';
        else
            fields.Same_As__c = this.sameasValue ; //june29
        if (fields.Address_Type__c == 'Current' && DeemedCurrentAddress.includes(fields.Address_Source__c)) {
            fields['Deemed__c'] = true;
        
	
	
	}

    // R2 2360
    // if(this.addressTypeValue=='Land'){
    //     fields = this.template.querySelector('c-land-address-component').getLandAddress()
	// }
    // R2 2360

        getNegativeAreaMasterRecords({
            pincode: fields.Pincode__c,
            areaName: fields.Area_Name__c
        }).then((data => {
            if (data && data.length > 0) {
                if (data[0].Working_Area__c == 'Yes') {
                    fields.Geo_Limit__c = 'Acceptable';
                }
                if (data[0].Working_Area__c == 'No') {
                    fields.Geo_Limit__c = 'Not Acceptable';
                }
                if (data[0].Area_Status__c == 'Positive') {
                    fields.Negative_Area_Status__c = 'Positive';
                    if(fields.Address_Type__c=='Current'){
                        this.applicantDetailsToBeUpdated.Negative_Area_Status__c = 'Positive'
                    }
                }
                if (data[0].Area_Status__c == 'Negative') {
                    fields.Negative_Area_Status__c = 'Negative';
                    if(fields.Address_Type__c=='Current'){
                        this.applicantDetailsToBeUpdated.Negative_Area_Status__c = 'Negative'
                    }
                }

            }
            if (this.isInputValid()) {
                //getDistance
                if(this.addressTypeValue == 'Current'){
                this.getDistance(this.PincodeValue);
                }
                // end
                //bre run check
                this.breRunMaterialFields();
                //End
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                if(this.selectedAddresstype  == 'Current'){
                    this.handleUpdateDeemed();
                }
                // SFAU-5716
                if(this.selectedAddresstype == 'Office' && this.isTwoWheeler){
                    this.updateRCOonApplicant();
                }
            }


        }))
        /*if (this.isInputValid()) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }*/
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
        // }
        if(this.isInputValid() && this.addressTypeValue=='Land'){
            const recordInputForUpdate ={fields: fields};
            updateRecord(recordInputForUpdate)
                .then(result => {
                    this.handleSuccess()
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,//error.body.output.fieldErrors,
                            variant: 'error',
                        }),
                    );
                });
        }
    }
    // SFAU-5716
    updateRCOonApplicant(){
            const FIELDS = {};
            FIELDS[Applicant_ID_FIELD.fieldApiName] = this.appId;
            FIELDS[Applicant_Risk_FIELD.fieldApiName] = this.rcoEnabled ;
            const recordInputForUpdate ={fields: FIELDS};
            updateRecord(recordInputForUpdate).then(() => {

            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
    }
    calladdressMatch(){
        getAddressMatchAPI({
            applicantId: this.appId
        }).then(result => {
           
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('result is ' + JSON.stringify(error));
        })
    }
    handleSuccess(event) {
        //SFAU-4295 and SFAU-4733 start
        if(this.addressEditRestricted || this.blnRestrictEdit || !this.allowSave){
            return
        }
        //SFAU-4295 end
        this.isLoading = true;
        this.showMessage('Address updated successfully', 'success');
        this.editAdress = false;
        this.showMainSection = true;
        this.addinformation = false;
        if (this.addressTypeValue == 'Current') {
            this.applicantDetailsToBeUpdated.Id = this.appId;
            const fields = this.applicantDetailsToBeUpdated;

            const recordInput = {
                fields
            };
            updateRecord(recordInput).then(() => {

            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
        }
        if(this.addressTypeValue == 'Office'){
            this.calladdressMatch();
        }
        this.handleReset();
        this.getApplicants();
        this.requiredfieldsValidationCheck();
        this.sameasValue =null; //Added for SFAU-2563
        this.isLoading = false;
    }
    handleAdditionalInformationClick(event) {
        this.handleReset();
        //alert('inside');
        this.addinformation = true;
        // this.addressApplicationRecord.Applicant__c =  this.applicantId.Id; 
        this.addressApplicationRecord.Applicant__c = this.appId;
        this.getInitialValues();
        this.sameasValue =null; //Added for SFAU-2563

    }
    cancelMethod(event) {
        this.editAdress = false;
    }
    editMethod(event) {
        this.editAdress = true;
    }
    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
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

    setAddressTypeOptions(){
        let options = [];
        let allAddress;
        if(this.customerType == 'Non Individual'){
            allAddress = ['Current', 'Office'];
            this.NonIndvidual = true;
            //this.constitutionType = data.constitutionType;
            //this.assignAddressOptionsNonInd();
        }else if(this.isTractorLoan){
            allAddress = ['Permanent', 'Current', 'Office', 'Touch Point', 'Land'];
        }else{
            allAddress = ['Permanent', 'Current', 'Office', 'Touch Point'];
        }
        //R2-2360
        const vehicleUsage = this.loanApplication && this.loanApplication.Original_Vehicle_Usage__c ? this.loanApplication.Original_Vehicle_Usage__c :  this.vehicleUsage;
        for (var key in allAddress) {
            console.log('dataVal[key]' + allAddress[key]);
            // R2-19
            
            //R2-2360
            if (!this.existingAddress.includes(allAddress[key]) && !( OFFICE_ADDRESS_INELIGIBLE_PRODUCTS.includes( this.selectedProduct ?? this.loanApplication.Product__c ) && allAddress[key] === 'Office' && this.customerType === 'Individual' && vehicleUsage === 'Agri' ) ) {
                options.push({
                    label: allAddress[key],
                    value: allAddress[key]
                });
            }
        }

        this.addressList = options;
    }

    handleRowAction(event) {
        this.isLoading = true;
        const recordId = event.currentTarget.dataset.id;
        this.selectedProduct = event.currentTarget.alternativeText;
        this.addressTypeValue = event.currentTarget.title;
        this.selectedAddresstype = event.currentTarget.title;
        if(this.addressTypeValue=='Land'){
            this.isLandAddress=true;
        }else{
            this.isLandAddress=false;
        }
        /* this.stateValue = event.currentTarget.alternativeText;
        this.talukaValue =event.currentTarget.title;
        this.areaValue= event.currentTarget.dataset.actionName;*/

        const pincode = event.currentTarget.dataset.recordName

        this.showMainSection = false;
        this.editRecordId = recordId;

        //added new
        if (this.addressTypeValue == 'Office' || this.addressTypeValue == 'Current' || this.addressTypeValue == 'Touch Point') {
            this.handleLoadOfficeOptions(this.addressTypeValue);
        }
        //end

        this.handleSameAsLogic();
        //get the picklist values from the current address record pincode
        //this.getPicklistOptions(pincode);
        getAddressInfo({
            recId: recordId
        })
            .then(data => {
                if (data) {
                    this.districtOptions.push({
                        label: data[0].District__c,
                        value: data[0].District__c
                    });
                    this.talukaOptions.push({
                        label: data[0].Taluka__c,
                        value: data[0].Taluka__c
                    });
                    this.cityOptions.push({
                        label: data[0].City__c,
                        value: data[0].City__c
                    });
                    this.residenceStatusOptions.push({ //june29
                        label: data[0].Status__c,
                        value: data[0].Status__c
                    });
                    this.residenceTypeOptions.push({
                        label: data[0].Type__c,
                        value: data[0].Type__c
                    });
                    this.stateValue = data[0].State__c;
                    this.cityValue = data[0].City__c;
                    this.districtValue = data[0].District__c;
                    this.talukaValue = data[0].Taluka__c;
                    this.areNameValue = data[0].Area_Name__c;
                    this.residenceStatusValue = data[0].Status__c;
                    this.residenceStatusTypeValue = data[0].Type__c;
                    this.stabilityValue = data[0].Stability__c;
                    this.addressTakenFromValue = data[0].Address_Source__c;
                    this.addressTypeValue = data[0].Address_Type__c;
                    this.addressLine1Value = data[0].Address_Line_1__c;
                    this.addressLine2Value = data[0].Address_Line_2__c;
                    this.addressLine3Value = data[0].Address_Line_3__c;
                    // R2 2360
                    this.khataSurveyNo = data[0].Khata_Khasara_Survey_Number__c;
                    this.village = data[0].Village__c;
                    // R2 2360
                    this.pinCodeVal = data[0].Pincode__c;
                    this.PincodeValue = data[0].Pincode__c;
                    this.LandMarkValue = data[0].Land_mark__c;
                    this.OfficeNoValue = data[0].Office_Number__c;
                    this.Office_Email_address__c = data[0].Office_Email_address__c;
                    this.sameasValue = data[0].Same_As__c;
                    this.DistanceFrmBranchValue =  data[0].Distance_from_Branch__c; //24 JUL
                    if(this.addressTypeValue == 'Current' && DeemedCurrentAddress.includes(this.addressTakenFromValue)){
                        this.deemedValue = true;
                    }
        
                   
                    this.sameAsOptions.forEach((option) => {
                        if (option.value === this.sameasValue) {
                            option.checked = true; // Set the "current" option as checked
                        } else {
                            option.checked = false; // Uncheck other options
                        }
                    });

                    this.setAddressTypeOptions();
                    this.addressList.push({
                        label: this.addressTypeValue,
                        value: this.addressTypeValue
                    });

                    this.editAdress = true;

                    if (this.addressTypeValue == 'Permanent' || this.addressTypeValue == 'Office') {
                        this.showSameAsDropDown = false;
                    }
                    this.showOfficeLabels = ((this.addressTypeValue == 'Office') ? true : false);
                    this.isPermanentAddress = ((this.addressTypeValue == 'Permanent') ? true : false); //25 JUL
                    this.showDistance = ((this.addressTypeValue == 'Current') ? true : false);
                    this.isLoading = false;
                    this.getPicklistOptions(pincode);
                   

                    //Aadhar Address Read Only chec
                    let addressDetails = data;
                 
                    if ((this.addressTypeValue == 'Current' && data[0].Same_As__c == 'Permanent' && 
                        data[0].Address_Source__c == 'Aadhaar Card') && (this.kycType == 'Aadhaar - Biometric' || this.kycType == 'Aadhaar - OTP')) {
                        this.addressLine1disabled = true;
                        this.addressLine2disabled = true;
                        this.addressLine3disabled = true;
                        this.pincodedisabled = true;
                        this.statedisabled = true;
                        this.citydisabled = true;
                        this.districtdisabled = true;
                        //this.areadisabled = true;
                        this.talukdisabled = true;
                       // this.areatypedisabled = true; //SFAU-4986
                       // this.landmarkdisabled = true;
                       // this.statusdisabled = true;
                        //this.typedisabled = true;
                        //this.stabilitydisabled = true;
                        this.addresstakendisabled = true;
                    }else if(data[0].Same_As__c){
                        this.handleDisabled();
                    } else {
                        this.addressLine1disabled = false
                        this.addressLine2disabled = false;
                        this.addressLine3disabled = false;
                        this.pincodedisabled = false;
                        this.statedisabled = false;
                        this.citydisabled = false;
                        this.districtdisabled = false;
                        this.areadisabled = false;
                        this.talukdisabled = false;
                        this.areatypedisabled = false;
                        this.landmarkdisabled = false;
                        this.statusdisabled = false;
                        this.typedisabled = false;
                        this.stabilitydisabled = false;
                        this.addresstakendisabled = false;

                    }
                    if (this.addressTypeValue == 'Permanent') {
                        this.handleAaadharPermanentAddress(addressDetails);
                    }

                    if(this.selectedAddresstype == 'Permanent'){ //june29
                        this.setAddressTakenFromValues();
                    }
                    if (this.customerType == 'Non Individual') {
                        this.assignAddressOptionsNonInd();
                    }
                    // R2 2360
                    if(this.selectedAddresstype == 'Office'){ //JUL 27
                        this.showSameAsDropDown = true;
                        // R2-1733
                        this.officeemaildisabled = false;
                        this.officenumberdisabled = false;
                        this.sameAsOptions =null;
                        let sameasOptions=[];
                        if(this.sameasValue =='NA'){
                            this.handleDisabled();
                            sameasOptions.push({
                                label: 'NA',
                                value: 'NA',
                                checked: true
                            });
                        } else{
                            sameasOptions.push({
                                label: 'NA',
                                value: 'NA',
                                checked: false
                            });
                        }
                        this.sameAsOptions = sameasOptions;
                    } //END
                    // R2-2808
                    if (!this.isPermanentFormDisabledCalled) {
                        this.disableFieldsAsPerMetadata(this.selectedAddresstype);
                    }
                    //R2-2808
                    
                    // R2-2278 - START
                    for (let each in this.sameAsOptions) {
                        if (this.sameAsOptions[each].checked) {
                            this.handleDisabled();
                            break;
                        }
                    }
                    // R2-2278 - END
                }
            })
            .catch(error => {
                console.log('result is ' + error)
                this.error = error;
                //this.accounts = undefined;
            })


        this.dispatchEvent(new CustomEvent('editmode', {
            detail: true
        }));

    }
    handleLoadOfficeOptions(addressVal) {
        getProductMetadataValues({
            AddressType: addressVal,
            Product: this.selectedProduct,
            customerType: this.customerType
        })
            .then(data => {
                let residenceOptions = [];
                let residenceTypeOptions = [];
                let addressTakenOptions = [];
                let options = [];
                let typeOptions = [];
                let addresstkFromOptions = [];
                residenceOptions = data['ResidenceStatus'];
                residenceTypeOptions = data['ResidenceType'];
                addressTakenOptions = data['AddressTakenFrom'];

                for (var key in residenceOptions) {
                    options.push({
                        label: residenceOptions[key],
                        value: residenceOptions[key]
                    });
                }
                for (var key in residenceTypeOptions) {
                    typeOptions.push({
                        label: residenceTypeOptions[key],
                        value: residenceTypeOptions[key]
                    });
                }
                this.residenceStatusOptions = options;
                this.residenceTypeOptions = typeOptions;
                if(this.selectedAddresstype == 'Permanent' && this.editAdress == true){ //june29
                    this.setAddressTakenFromValues();
                }else{
                    for (var key in addressTakenOptions) {
                        addresstkFromOptions.push({
                            label: addressTakenOptions[key],
                            value: addressTakenOptions[key]
                        });
                    }
                    
                    this.addressTakenFromOptions = addresstkFromOptions;
                    console.log('test ' + JSON.stringify(this.addressTakenFromOptions));
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.error = error;
                this.isLoading = false;
                //this.accounts = undefined;
            })
    }

    // R2-2350
    get showDistanceFromBranch(){
        return !(this.selectedAddresstype === 'Permanent' || this.selectedAddresstype === 'Touch Point' );
    }
    // R2-2350

    async disableFieldsAsPerMetadata(addressType){
        let emailId='';
        this.isLoading =true;
        let screen ='';
        if(addressType == 'Permanent'){
            screen ='Permanent Address';
            this.handleResetDisabled();
        }else if(addressType == 'Current'){
            screen ='Current Address';
            this.handleResetDisabled();
        }else if(addressType == 'Office'){
            screen ='Office Address';
            let address =  this.addressLst.find(data => data.Address_Type__c == 'Office');
            emailId = address!=null? address.Office_Email_address__c!=null ? address.Office_Email_address__c :'':'';
        }else if(addressType == 'Touch Point'){
            screen ='Touch Point Address';
        }
        else if(addressType == 'Land'){
            screen ='Land Address';
        }
        
        const fieldsToBeDisabled = await getMaterialFields({strScreen:screen,strLoanId:this.loanId});
        this.materialFields = fieldsToBeDisabled
        console.log('fieldsToBeDisabled-->' +JSON.stringify(fieldsToBeDisabled));
       
        if(fieldsToBeDisabled){
            fieldsToBeDisabled.forEach((input=>{
                    if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                        this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                            if(input == 'Office_Email_address__c'){
                                if(emailId!=null && emailId!=''){
                                    inputToBeDisabled.disabled = true
                                }
                            }else{
                                inputToBeDisabled.disabled = true
                            }
                          
                        }))
                        if(addressType == 'Touch Point'){ //addressType == 'Office' || 
                            this.showSameAsDropDown = false;
                        }
                    }
                
            }))
        }
        this.isLoading =false;
    }
    handleofficeDisabled() {
        this.addressLine1disabled = true;
        this.addressLine2disabled = true;
        this.addressLine3disabled = true;
        this.pincodedisabled = true;
        this.statedisabled = true;
        this.citydisabled = true;
        this.districtdisabled = true;
        this.areadisabled = this.areNameValue ? true : false;
        this.talukdisabled = true;
        this.areatypedisabled = this.areaTypeValue ? true : false;
        this.landmarkdisabled = this.LandMarkValue ? true : false;
        this.statusdisabled = this.residenceStatusValue ? true : false;
        this.residenceTypeDisabled = this.residenceStatusTypeValue ? true : false;
        this.typedisabled = true;
        this.stabilitydisabled = this.stabilityValue ? true : false;
        this.addresstakendisabled = true;
        this.officenumberdisabled = true;
        this.officeemaildisabled = true;
    }

    handleResetDisabled() {
        this.copyDisabled = false;
    this.addressTypeDisabled = false;
    this.addressLine1disabled = false;
    this.addressLine2disabled = false;
    this.addressLine3disabled = false;
    this.pincodedisabled = false;
    this.statedisabled = false;
    this.citydisabled = false;
    this.districtdisabled = false;
    this.areadisabled = false;
    this.talukdisabled = false;
    this.areatypedisabled = false;
    this.landmarkdisabled = false;
    this.statusdisabled = false;
    this.residenceTypeDisabled = false;
    this.typedisabled = false;
    this.stabilitydisabled = false;
    this.addresstakendisabled = false;
    this.officenumberdisabled=false;
    this.officeemaildisabled=false;
    //2 Aug || START
    this.disabledOffice = false;
    this.residenceTypeDisabled = false;
    this.areaNewDisabled = false; 
    this.stabilityNewDisabled=false;
    this.landmarkNewDisabled=false;

    // // R2 2360
    // if(this.isLandAddress){
    //     this.landmarkdisabled = false;
    //     this.copyDisabled = false;
    //     this.areaNewDisabled = false;
    //     this.areatypedisabled = false;
    //     this.areadisabled = false;
    // }
    // // R2 2360
    //END
    }
    handleDisabled(){ //jun29
        this.copyDisabled = true;
        this.addressTypeDisabled = true;
        this.addressLine1disabled = true;
        this.addressLine2disabled = true;
        this.addressLine3disabled = true;
        this.pincodedisabled = true;
        this.statedisabled = true;
        this.citydisabled = true;
        this.districtdisabled = true;
        this.areadisabled = this.areNameValue ? true : false;
        this.talukdisabled = true;
        this.areatypedisabled = this.areaTypeValue ? true : false;
        this.landmarkdisabled = this.LandMarkValue ? true : false;
        this.statusdisabled = this.residenceStatusValue ? true : false;
        this.residenceTypeDisabled = this.residenceStatusTypeValue ? true : false;
        this.stabilitydisabled = this.stabilityValue ? true : false;
        this.typedisabled = true;
        // R2 - 2360
        if(this.isLandAddress){
            this.addresstakendisabled = this.addressTakenFromValue ? true : false;
        }
        else{
            this.addresstakendisabled = true;
        }
        // R2 - 2360
        this.officenumberdisabled = true;
        this.officeemaildisabled = true;
        // // R2 2360
        // if(this.isLandAddress){
        //     this.landmarkdisabled = true;
        //     this.copyDisabled = true;
        //     this.areatypedisabled = true;
        //     this.areaNewDisabled = true;
        //     this.areadisabled = true;
        // }
        // // R2 2360
    }


    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value && this.sameasValue != 'NA' ) { //Pooja
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    get getOfficeLabel(){
        return (this.NonIndvidual || this.showOfficeLabels) ? 'Office Type' : 'Residence Type'; 
    }

    handleRecordUpdateCancel() {
        this.editAdress = false;
        this.showMainSection = true;
    }


    handleAddressType(event) {
        let name = event.target.name;
        if (name == 'Address_Line_1__c') {
            //this.addressLine1Value = event.target.value;
            let addressline1 = event.target.value;
            if (addressline1.length <= this.maxCharLimit) {
                this.addressLine1Value = event.target.value;
            } else {
                // Display an error message or take appropriate action when the limit is exceeded
                this.showMessage('Max character limit is 35 characters', 'error');
            }
        }
        if (name == 'Address_Line_2__c') {
            //this.addressLine2Value = event.target.value;
            let addressline2 = event.target.value;
            if (addressline2.length <= this.maxCharLimit) {
                this.addressLine2Value = event.target.value;
            } else {
                // Display an error message or take appropriate action when the limit is exceeded
                this.showMessage('Max character limit is 35 characters', 'error');
            }
        }
        if (name == 'Address_Line_3__c') {
            //this.addressLine3Value = event.target.value;
            let addressline3 = event.target.value;
            if (addressline3.length <= this.maxCharLimit) {
                this.addressLine3Value = event.target.value;
            } else {
                // Display an error message or take appropriate action when the limit is exceeded
                this.showMessage('Max character limit is 35 characters', 'error');
            }
        }
        if (name == 'Office_Number__c') {
            this.OfficeNoValue = event.target.value;
        }
        if (name == 'Office_Email_address__c') {
            this.OfficeEmailIdValue = event.target.value;
        }
        if(name === 'Khata_Khasara_Survey_Number__c' ){
            this.khataSurveyNo = event.target.value;
        }
        if(name === 'Village__c'){
            this.village = event.target.value;
        }
        if (name == 'Land_mark__c') {
           // this.LandMarkValue = event.target.value;
            let landmark = event.target.value;
            if (landmark.length <= this.maxCharLimit) {
                this.LandMarkValue = event.target.value;
            } else {
                // Display an error message or take appropriate action when the limit is exceeded
                this.showMessage('Max character limit is 35 characters', 'error');
            }
        }
         //JUL 24
         if(name =='Distance_from_Branch__c'){
            this.DistanceFrmBranchValue =  event.target.value;
        }
        //END


        /*  if(name =='Address_Type__c'){
              this.addressTypeValue =  event.target.value;
          }
          if(name =='Land_mark__c'){
              this.LandMarkValue =  event.target.value;
          }*/


        this.addressApplicationRecord[event.target.name] = event.target.value;
        //this.selectedAddresstype = event.target.value;
        let residenceOptions = [];
        let residenceTypeOptions = [];
        let addressTakenOptions = [];
        let options = [];
        let typeOptions = [];
        let addresstkFromOptions = [];

        if (event.target.name == 'Address_Type__c') {
            this.sameasValue = null;
            this.selectedAddresstype = event.target.value;
        
            this.handleSameAsLogic();
            this.disableFieldsAsPerMetadata(this.selectedAddresstype);
            this.showOfficeLabels = ((this.selectedAddresstype == 'Office') ? true : false);
            this.showDistance = ((this.selectedAddresstype == 'Current') ? true : false);
            this.isPermanentAddress = ((this.selectedAddresstype == 'Permanent') ? true : false); //25 JUL
            this.isLandAddress = ((this.selectedAddresstype == 'Land') ? true : false);
            this.addressTypeValue = event.target.value;
            this.isLoading = true;
            if (event.target.name == 'Address_Type__c' && this.residentialStatus == 'NRI' && event.target.value != 'Permanent') {
                this.isNRIApplicant = true;
                this.isLoading = false;
            } else {
                this.isNRIApplicant = false;
                getProductMetadataValues({
                        AddressType: this.selectedAddresstype,
                        Product: this.selectedProduct,
                        customerType: this.customerType
                    })
                    .then(data => {
                     
                        residenceOptions = data['ResidenceStatus'];
                        residenceTypeOptions = data['ResidenceType'];
                        addressTakenOptions = data['AddressTakenFrom'];
                        if(this.customerType == 'Individual'){
                            for (var key in residenceOptions) {
                                options.push({
                                    label: residenceOptions[key],
                                    value: residenceOptions[key]
                                });
                            }
                        }else{
                           
                            options.push({
                                label: 'Owned',
                                value: 'Owned'
                            });
                            options.push({
                                label: 'Rented',
                                value: 'Rented'
                            });
                        }
                        if(this.customerType == 'Individual'){
                        for (var key in residenceTypeOptions) {
                           typeOptions.push({
                                label: residenceTypeOptions[key],
                                value: residenceTypeOptions[key]
                            });
                              }
                            }else{
                                typeOptions.push({
                                    label: 'Shop',
                                    value: 'Shop'
                                });
                                typeOptions.push({
                                    label: 'Residential Office',
                                    value: 'Residential Office'
                                });
                                typeOptions.push({
                                    label: 'Commercial Space',
                                    value: 'Commercial Space'
                                });
                            }
                       
                        addresstkFromOptions = [];
                        for (var key in addressTakenOptions) {
                            if(this.recordCount != 0){
                                if(this.selectedAddresstype == 'Permanent'  && (this.kycType == 'Aadhaar - Biometric' || this.kycType == 'Aadhaar - OTP' || this.kycType =='Voter Id' || this.kycType =='Driving License' ||  this.kycType =='Passport')){
                                   if(this.verifiedAddressTakenValues.includes(addressTakenOptions[key])){
                                     addresstkFromOptions.push({
                                        label: addressTakenOptions[key],
                                        value: addressTakenOptions[key]
                                    });
                                   }
                                }
                              else{
                                    addresstkFromOptions.push({
                                        label: addressTakenOptions[key],
                                        value: addressTakenOptions[key]
                                    });

                                   
                                }
                                
                            }
                            if(this.recordCount == 0){
                                if(addressTakenOptions[key] !='Aadhaar Card'){
                                    addresstkFromOptions.push({
                                        label: addressTakenOptions[key],
                                        value: addressTakenOptions[key]
                                    });
                                }
                            }
                           
                        }

                        this.residenceStatusOptions = options;
                        this.residenceTypeOptions = typeOptions;
                        if(this.selectedAddresstype == 'Permanent'){
                            this.setAddressTakenFromValues()
                        }
                        else{
                            this.addressTakenFromOptions = addresstkFromOptions;
                        }
                        if(this.customerType=='Non Individual'){
                            this.assignAddressOptionsNonInd();
                        }
                        
                        this.isLoading = false;

                    })
                    .catch(error => {
                        console.log('error is ' + JSON.stringify(error));
                        this.error = error;
                        this.isLoading = false;
                        //this.accounts = undefined;
                    })
            }

        }
    }

    setAddressTakenFromValues() {
        let appId = this.applicantId && this.applicantId.Id ? this.applicantId.Id : this.appId;
        getValidTakenFromValues({
            applicantId: appId
        })
            .then(res => {
                if (res.length > 0) {
                    let resp = [];
                    res.forEach(addr => {
                        resp.push({
                            label: addr,
                            value: addr
                        })
                    })
                    this.addressTakenFromOptions = this.getUniqueValue(resp);
                } else {
                    let options = [];
                    options.push({
                        label: 'Aadhaar Card',
                        value: 'Aadhaar Card'
                    });
                    this.addressTakenFromOptions = this.getUniqueValue(options);
                }
            })
            .catch(err => {
                this.addressTakenFromOptions = [];
            })

    }
    getUniqueValue(myList){ //june29
        let uniqueList = myList.reduce((accumulator, currentValue) => {
            if (!accumulator.find(item => JSON.stringify(item) === JSON.stringify(currentValue))) {
              accumulator.push(currentValue);
            }
            return accumulator;
          }, []);
          
          return uniqueList;
    }

    handleAddressDependenceValues() {
        getProductMetadataValues({
                AddressType: 'Permanent',
                Product: this.selectedProduct,
                customerType: this.customerType
            })
            .then(data => {
                let residenceOptions = [];
                let residenceTypeOptions = [];
                let addressTakenOptions = [];
                let options = [];
                let typeOptions = [];
                let addresstkFromOptions = [];
                residenceOptions = data['ResidenceStatus'];
                residenceTypeOptions = data['ResidenceType'];
                addressTakenOptions = data['AddressTakenFrom'];

                for (var key in residenceOptions) {
                    options.push({
                        label: residenceOptions[key],
                        value: residenceOptions[key]
                    });
                }
                for (var key in residenceTypeOptions) {
                    typeOptions.push({
                        label: residenceTypeOptions[key],
                        value: residenceTypeOptions[key]
                    });
                }
                //if(!this.addressTakenFromOptions){
                    for (var key in addressTakenOptions) {
                        addresstkFromOptions.push({
                            label: addressTakenOptions[key],
                            value: addressTakenOptions[key]
                        });
                    }
                    this.addressTakenFromOptions = addresstkFromOptions;
              //  }

                this.residenceStatusOptions = options;
                this.residenceTypeOptions = typeOptions;
                this.isLoading = false;

            })
            .catch(error => {
                console.log('error in productvalues ' + JSON.stringify(error));
                this.error = error;
                //this.accounts = undefined;
            })

    }

    handleSameAsLogic() {
        let sameasOptions = [];
        if (this.selectedAddresstype == 'Permanent') {
            sameasOptions.push({
                label: 'New',
                value: 'New',
                checked: false
            });
            this.showSameAsDropDown = false;
        } else if (this.selectedAddresstype == 'Current') {
            /* sameasOptions.push({
                 label: 'New',
                 value: 'New'
             });*/
            if (this.customerType == 'Non Individual') {
               /* sameasOptions.push({
                    label: 'KYC(Udaym/reg)',
                    value: 'KYC(Udaym/reg)',
                    checked: false
                });*/
            } else {
                sameasOptions.push({
                    label: 'Permanent',
                    value: 'Permanent',
                    checked: false
                }
                );
            }
            this.showSameAsDropDown = true;
            // R2 - 2360
        } else if (this.selectedAddresstype == 'Office' || this.selectedAddresstype === 'Land') {
            /* sameasOptions.push({
                 label: 'New',
                 value: 'New'
             });*/
             if(this.customerType == 'Individual' && this.isNaApplicable ){ //pooja
                sameasOptions.push({
                    label: 'NA',
                    value: 'NA',
                    checked: false
                });
             }
            if (this.customerType == 'Non Individual') {
                /*sameasOptions.push({
                    label: 'KYC(Udaym/reg)',
                    value: 'KYC(Udaym/reg)',
                    checked: false
                });*/
            } else {
                sameasOptions.push({
                    label: 'Permanent',//'Permanent',
                    value: 'Permanent',
                    checked: false
                });
            }
            sameasOptions.push({
                label: 'Current',
                value: 'Current',
                checked: false
            });
            this.showSameAsDropDown = true;
            if ((this.selectedAddresstype == 'Office' || this.selectedAddresstype === 'Land') && this.editAdress == true) {
                this.showSameAsDropDown = false;
            }
        } else if (this.selectedAddresstype == 'Touch Point') {
            this.showSameAsDropDown = false;
            // R2-2360
        }  
        this.sameAsOptions = sameasOptions;
        
        console.log('this.sameAsOptions', this.sameAsOptions);
    }

    // R2 2360
    handleCopyInfoLandExtention(event){
        let boxes = this.template.querySelectorAll('.chckBox');
        let selectedValue = event.target.value;
        let selectionOption = event.target.dataset.name;
        let checkedValue = event.target.checked;
        this.sameasValue = event.target.dataset.name;

        let existingValues = this.addressLst;
        for (var key in this.addressLst) {
            if (existingValues[key].Address_Type__c == selectionOption) {
                this.districtOptions.push({
                    label: existingValues[key].District__c,
                    value: existingValues[key].District__c
                });
                this.talukaOptions.push({
                    label: existingValues[key].Taluka__c,
                    value: existingValues[key].Taluka__c
                });
                this.cityOptions.push({
                    label: existingValues[key].City__c,
                    value: existingValues[key].City__c
                });
                // this.addressTakenFromOptions.push({
                //     label: existingValues[key].Address_Source__c,
                //     value: existingValues[key].Address_Source__c
                // });
                //this.sameASValueOnEdit = existingValues[key].Same_As__c;
                this.addressLine1Value = existingValues[key].Address_Line_1__c;
                this.addressLine2Value = existingValues[key].Address_Line_2__c;
                this.addressLine3Value = existingValues[key].Address_Line_3__c;
                this.stateValue = existingValues[key].State__c;
                this.cityValue = existingValues[key].City__c;
                // this.districtValue = existingValues[key].Taluka__c;
                this.districtValue = existingValues[key].District__c;
                this.areNameValue = existingValues[key].Area_Name__c;
                this.talukaValue = existingValues[key].Taluka__c;
                this.areaTypeValue = existingValues[key].Area_Type__c;
                this.residenceStatusValue = existingValues[key].Status__c;
                this.residenceStatusTypeValue = existingValues[key].Type__c;
                this.stabilityValue = existingValues[key].Stability__c;
                //this.addressTakenFromValue = existingValues[key].Address_Source__c;
                this.PincodeValue = existingValues[key].Pincode__c;
                this.pinCodeVal = existingValues[key].Pincode__c;
                this.LandMarkValue = existingValues[key].Land_mark__c;
                this.areNameValue = existingValues[key].Area_Name__c;
            }
        }

        if(checkedValue && selectionOption !== 'NA'){
            this.copyDisabled = true;
            this.getPicklistOptionsDefault(this.PincodeValue,false);
            this.handleDisabled();
            this.tractorSpecificFieldDisabled = false;
        }
        else if(checkedValue && selectionOption === 'NA'){
            this.copyDisabled = true;
            this.disabledOffice = true
            this.residenceTypeDisabled = this.residenceStatusTypeValue ? true : false;
            this.areaNewDisabled = true; //2 Aug
            this.stabilityNewDisabled=true;
            this.landmarkNewDisabled=true;
            if(this.editAdress == true){ //27 JUL
                this.handleDisabled();
                this.handleReset();//27 JUL
            }

            // R2-1712 - Office number and Email to be disabled when NA is chosen
            this.officenumberdisabled = true;
            this.officeemaildisabled = true;
            this.disabledOffice = true;
            this.landmarkdisabled = true;
            this.areatypedisabled = true;        
            this.areaNewDisabled = true;        
            this.addresstakendisabled = true;
            this.areadisabled = true;
            this.tractorSpecificFieldDisabled = true;
        }
        else{
            this.copyDisabled = false;
            this.handleReset();
            this.handleResetDisabled();
            this.getPicklistOptionsDefault('00000',false);
            this.tractorSpecificFieldDisabled = false;
        }
        
        this.handleLWCIssueCheckbox(selectionOption, checkedValue);
        
    }

    handleLWCIssueCheckbox(selectedOption, checkedValue){
        let options = this.sameAsOptions;
        for(let i of options){
            if(i.label === selectedOption){
                i.checked = checkedValue;
            }
            else{
                i.checked = false;
            }
        }
        this.sameAsOptions = [];
        setTimeout(() => {
            this.sameAsOptions = options;
        });
    }
    // R2 2360

    handleCopyInfo(event) {

        // R2 2360
        if(this.selectedAddresstype === 'Land'){
            this.handleCopyInfoLandExtention(event);
            return;
        }
        // R2 2360

        //this.getPicklistOptionsDefault(this.PincodeValue);
        let boxes = this.template.querySelectorAll('.chckBox');
        let selectedValue = event.target.value;
        let selectionOption = event.target.dataset.name;
        this.sameasValue = event.target.dataset.name;

        boxes.forEach(checkbox => {
            if (checkbox.value !== selectedValue) {
                checkbox.checked = false;
            }
            if (checkbox.name == selectionOption && checkbox.checked == false) {
                this.sameasValue = '';
                this.handleResetDisabled(); // june29
                this.handleReset();
            } else if (checkbox.name == selectionOption && checkbox.checked == true) {
                this.sameasValue = selectionOption;
            }
        });
        //let selectionOption = event.target.value;


        if (selectionOption == 'New') {
            this.handleReset();
        }
        boxes.forEach(checkbox => {
            if (checkbox.checked == false) {
                this.copyDisabled = false;
                this.handleReset();

            }
        });

        let existingValues = this.addressLst;
        console.log('existingValues-->' + JSON.stringify(existingValues));
      /*  if (selectionOption == 'Permanent' && this.selectedAddresstype == 'Current') { //june29
            this.handleAddressDependenceValues();
        }*/
       // START || R2-2405 || If Address is Current and Selected Option - Same As Permanent if they havent added Permanent Address then show the toast msg
        if (selectionOption == 'Permanent' && this.selectedAddresstype == 'Current' && existingValues.length == 0 ) {
            this.showMessage('Please Add Permanent Address', 'error');
            this.restrictCurrentSave = true;
        }else{
            this.restrictCurrentSave = false;
        }
        //END

        for (var key in existingValues) {
            if (existingValues[key].Address_Type__c == selectionOption) {
                this.districtOptions.push({
                    label: existingValues[key].District__c,
                    value: existingValues[key].District__c
                });
                this.talukaOptions.push({
                    label: existingValues[key].Taluka__c,
                    value: existingValues[key].Taluka__c
                });
                this.cityOptions.push({
                    label: existingValues[key].City__c,
                    value: existingValues[key].City__c
                });
                this.addressTakenFromOptions.push({
                    label: existingValues[key].Address_Source__c,
                    value: existingValues[key].Address_Source__c
                });
                this.sameASValueOnEdit = existingValues[key].Same_As__c;
                this.addressLine1Value = existingValues[key].Address_Line_1__c;
                this.addressLine2Value = existingValues[key].Address_Line_2__c;
                this.addressLine3Value = existingValues[key].Address_Line_3__c;
                this.stateValue = existingValues[key].State__c;
                this.cityValue = existingValues[key].City__c;
                //this.districtValue = existingValues[key].Taluka__c;
                this.districtValue = existingValues[key].District__c;
                this.areNameValue = existingValues[key].Area_Name__c;
                this.talukaValue = existingValues[key].Taluka__c;
                this.areaTypeValue = existingValues[key].Area_Type__c;
                this.residenceStatusValue = existingValues[key].Status__c;
                this.residenceStatusTypeValue = existingValues[key].Type__c;
                this.stabilityValue = existingValues[key].Stability__c;
                this.addressTakenFromValue = existingValues[key].Address_Source__c;
                this.PincodeValue = existingValues[key].Pincode__c;
                this.pinCodeVal = existingValues[key].Pincode__c;

                if(this.sameASValueOnEdit != 'Permanent'){
                    this.stabilityValue = existingValues[key].Stability__c;
                    this.residenceStatusTypeValue = existingValues[key].Type__c;
                    this.LandMarkValue = existingValues[key].Land_mark__c;
                    this.areNameValue = existingValues[key].Area_Name__c;
                }
            }
        }

        if (selectionOption == 'Permanent' && this.selectedAddresstype == 'Current') {
            this.copyDisabled = true;
            // 2360
        } else if (selectionOption == 'Current' && (this.selectedAddresstype == 'Office' || this.selectedAddresstype === 'Land')) {// Updated the Condition for SFAU-3079 
            this.copyDisabled = true;
        } else {
            this.copyDisabled = false;
        }




        this.getPicklistOptions(this.PincodeValue);
        
        this.dispatchEvent(new CustomEvent('editmode', {
            detail: false
        }));

        //RCO Changes
        //if ((this.selectedAddresstype == 'Office') && (selectionOption == 'Permanent' || selectionOption == 'Current' || selectionOption == 'Touch Point')) {
        if((this.selectedAddresstype == 'Office'  || this.selectedAddresstype === 'Land') &&  selectionOption == 'Current'){  // SFAU-5716
            this.rcoEnabled = true;
        }else if(this.selectedAddresstype == 'Office'){
            this.rcoEnabled = false;
        }
        //Added by Ashish 12 JUNE 2409
        if (selectionOption == 'Permanent') {
            boxes.forEach(checkbox => {
                if (this.selectedAddresstype == 'Current') {
                    if (checkbox.checked == false) {
                        this.copyDisabled = false;
                        this.handleReset();
                        this.getPicklistOptionsDefault('00000',false);
                        this.handleLoadOfficeOptions(this.selectedAddresstype); //June29 
                       
                    }
                    else if (checkbox.checked == true) {
                       // this.getPicklistOptionsDefault(this.PincodeValue);
                       this.getPicklistOptions(this.PincodeValue);//June29 
                    }
                }
            });
        }


        if (this.editAdress == true) {
            this.sameAsOptions.forEach((option) => {
                if (option.value === selectionOption) {
                    option.checked = event.target.checked;
                }
                if (option.checked == false) {
                    this.copyDisabled = false;
                    // R2 2360
                    if(!this.isLandAddress)
                        this.sameasValue = null;
                    // R2 2360
                    this.handleReset();
                    this.getPicklistOptionsDefault('00000',false);
                } else if (option.checked == true) {
                    this.getPicklistOptionsDefault(this.PincodeValue,false);
                    if(selectionOption == 'Permanent' && this.selectedAddresstype == 'Current'){ //June29
                        this.handleDisabled();
                    }
                }
            });
        }


        //END

        //Please dont comment the below part as this for bugs SFAU-3321
        boxes.forEach(checkbox => {
            if ((selectionOption == 'Permanent' || selectionOption == 'Current') && (this.selectedAddresstype == 'Office'  || this.selectedAddresstype === 'Land')) {
                if (checkbox.checked == true && checkbox.name == selectionOption) {
                    this.copyDisabled = true;
                    this.getPicklistOptionsDefault(this.PincodeValue,false);
                }
                else if (checkbox.checked == false && checkbox.name == selectionOption) {
                    this.copyDisabled = false;
                    this.handleReset();
                    this.getPicklistOptionsDefault('00000',false);
                }
            }
        });
        //2 Aug || START // R2 2360
        if(this.selectedAddresstype == 'Office' || this.selectedAddresstype === 'Land'){ 
            if(this.sameasValue == 'NA'){ //pooja
                this.copyDisabled = true;
                this.disabledOffice = true
                this.residenceTypeDisabled = this.residenceStatusTypeValue ? true : false;
                this.areaNewDisabled = true; //2 Aug
                this.stabilityNewDisabled=true;
                this.landmarkNewDisabled=true;
                if(this.editAdress == true){ //27 JUL
                    this.handleDisabled();
                    this.handleReset();//27 JUL
                }
    
                // R2-1712 - Office number and Email to be disabled when NA is chosen
                this.officenumberdisabled = true;
                this.officeemaildisabled = true;
                this.disabledOffice = true;
            }/*else{ //2Aug
                this.copyDisabled = false;
                this.disabledOffice = false;
            }*/
        }
         //2 Aug || END
           
    }
    handleNegativeAreaFieldUpdates(data) {
        if (data && data.length > 0) {
            if (data[0].Working_Area__c == 'Yes') {
                this.addressApplicationRecord.Geo_Limit__c = 'Acceptable';
            }
            if (data[0].Working_Area__c == 'No') {
                this.addressApplicationRecord.Geo_Limit__c = 'Not Acceptable';
            }
            if (data[0].Area_Status__c == 'Positive') {
                this.addressApplicationRecord.Negative_Area_Status__c = 'Positive';
                this.applicantDetailsToBeUpdated.Negative_Area_Status__c = 'Positive'
            }
            if (data[0].Area_Status__c == 'Negative'){
                this.addressApplicationRecord.Negative_Area_Status__c = 'Negative';
                this.applicantDetailsToBeUpdated.Negative_Area_Status__c = 'Negative'
            }

        }
    }

    handleSubmitForm() {
        //4733 Restrict Edit
        this.allowSave = true; 
        if(this.blnRestrictEdit){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Address Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //SFAU-4295 start
        if(this.addressEditRestricted){
            this.showMessage('Address cannot be changed as KYC is already Approved', 'error');
            return
        }

         // Added by kunal for SFAU-5397 --> if Same As Permanent is not checked then current address cannot have same address source as permanent.
        if(!this.checkAddressSourceValidation()){
            this.allowSave = false; 
            return;
        }
        // R2 - 2360
// if(this.addressTypeValue=='Land' && (!this.template.querySelector('c-land-address-component').isValidateGenericLookup() || !this.template.querySelector('c-land-address-component').handleValidations())){
//             return
//         }
        
        //SFAU-4295 end
         // START || R2-2405
       if(this.restrictCurrentSave && this.selectedAddresstype!='Permanent'){
            this.showMessage('Please Add Permanent Address', 'error');
            return;
       }
       //END
        let addressArray = this.addressLst;
        this.isLoading = true;
        let check = 'false';
        for (var i = 0; i < addressArray.length; i++) {
            if (addressArray[i].Address_Type__c == this.addressTypeValue) {
                check = 'true';
                this.addressTypeCheck = 'true';
            } else {
                this.addressTypeCheck = 'false';
            }
        }

        if (check == 'true') {
            this.showMessage('Please change the Address Type to Proceed Further', 'error');
        }
        else if ((this.addressLine1Value != undefined && this.addressLine1Value.length < 1)
             || (this.addressLine2Value != undefined && this.addressLine2Value.length < 1)) { //R2-2436
            this.showMessage('Address Line 1 and 2 should have at least 1 character', 'error'); //R2-2436
        }
        else {
           
            console.log('insubmitform-->' + this.addressLine1Value);
            //  if(this.addressApplicationRecord.City__c ==''){
            this.addressApplicationRecord.Address_Line_1__c = this.addressLine1Value;
            this.addressApplicationRecord.Address_Line_2__c = this.addressLine2Value;
            this.addressApplicationRecord.Address_Line_3__c = this.addressLine3Value;
            this.addressApplicationRecord.City__c = this.cityValue;
            this.addressApplicationRecord.District__c = this.districtValue;
            this.addressApplicationRecord.Area_Type__c = this.areaTypeValue;
            this.addressApplicationRecord.State__c = this.stateValue;
            this.addressApplicationRecord.Taluka__c = this.talukaValue;
            this.addressApplicationRecord.Area_Name__c = this.areNameValue;
            this.addressApplicationRecord.Status__c = this.residenceStatusValue;
            this.addressApplicationRecord.Type__c = this.residenceStatusTypeValue;
            this.addressApplicationRecord.Stability__c = this.stabilityValue;
            this.addressApplicationRecord.Distance_from_Branch__c = parseFloat(this.DistanceFrmBranchValue);
            //this.addressApplicationRecord.Land_mark__c= this.LandMarkValue;
            this.addressApplicationRecord.Pincode__c = this.PincodeValue;
            this.addressApplicationRecord.Address_Source__c = this.addressTakenFromValue;
            this.addressApplicationRecord.Office_Number__c = this.OfficeNoValue;
            this.addressApplicationRecord.Office_Email_address__c = this.OfficeEmailIdValue;
            this.addressApplicationRecord.Same_As__c =  this.sameasValue;

            // R2 - 2360
            this.addressApplicationRecord.Khata_Khasara_Survey_Number__c =  this.khataSurveyNo;
            this.addressApplicationRecord.Village__c =  this.village;
            // R2 - 2360
            
            if(this.addressApplicationRecord.Address_Type__c=='Current' && DeemedCurrentAddress.includes(this.addressApplicationRecord.Address_Source__c)){
                this.addressApplicationRecord['Deemed__c'] = true;
            }

            // if(this.addressTypeValue=='Land'){
            //     this.addressApplicationRecord = this.template.querySelector('c-land-address-component').getLandAddress()
            //     this.addressApplicationRecord.Applicant__c = this.appId;
            // }
            if (this.isInputValid()) {
                if( this.deemedValue == true){ //1 Sep
                    this.sendNotification();
                } //End


                this.addinformation = false;
                 //Distance
                 if(this.addressTypeValue == 'Current'){
                    this.getDistance(this.PincodeValue);
                }
                

                 //bre run check
                 this.breRunMaterialFields();
                 //End
                getNegativeAreaMasterRecords({
                    pincode: this.addressApplicationRecord.Pincode__c,
                    areaName: this.addressApplicationRecord.Area_Name__c
                }).then((data => {

                    this.handleNegativeAreaFieldUpdates(data);
                    const fields = this.addressApplicationRecord;
                    const recordInput = {
                        apiName: ADDRESS_OBJECT.objectApiName,
                        fields
                    };


                    createRecord(recordInput)
                        .then(async address => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Address created',
                                    variant: 'success',
                                }),
                            );
                            this.editAdress = false;
                            this.sameasValue =null;
                            this.addinformation = false;
                            this.showMainSection = true;
                            //new method start
                            if (this.addressTypeValue == 'Current') { //do not change the addressTypeValue here or add any other as we are updating applicant's Negative_Area_Status__c only in case of Current address. related method reference - handleNegativeAreaFieldUpdates
                                this.applicantDetailsToBeUpdated.Id = this.appId;
                                
                                /* SFAU-5716 - Start Kunal */
                                    if(this.addressApplicationRecord.Same_As__c == 'Permanent' && this.kycType == 'Aadhaar - Biometric'){
                                        this.applicantDetailsToBeUpdated['Is_Biometric_Address_Changed__c'] = false;
                                    }else{
                                        this.applicantDetailsToBeUpdated['Is_Biometric_Address_Changed__c'] = true;
                                    }

                                    if(this.addressApplicationRecord.Same_As__c == 'Permanent' && this.addressTakenFromCBS){
                                        this.applicantDetailsToBeUpdated['Is_ETB_Address_Changed__c'] = false;
                                    }else{
                                        this.applicantDetailsToBeUpdated['Is_ETB_Address_Changed__c'] = true;
                                    }
                                    
                                 /* SFAU-5716 - End Kunal */
                                const fields = this.applicantDetailsToBeUpdated;

                                const recordInput = {
                                    fields
                                };
                                updateRecord(recordInput).then(() => {

                                }).catch(error => {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error creating record',
                                            message: error.body.message,
                                            variant: 'error',
                                        }),
                                    );
                                })
                            }
                            //new method end
                             //RCO Applicant Updation
                if(this.selectedAddresstype  == 'Office' || this.selectedAddresstype  == 'Land'){
                    if(this.rcoEnabled == true){
                        const FIELDS = {};
                        FIELDS[Applicant_ID_FIELD.fieldApiName] = this.appId;
                        FIELDS[Applicant_Risk_FIELD.fieldApiName] = true;
                        const recordInputForUpdate ={fields: FIELDS};
    
                        const updatedApplicant = await getRiskCategoryBasedOnRiskIdentification({ draftApplicantRecord: FIELDS, fieldApi: Applicant_Risk_FIELD.fieldApiName }).catch( err => console.error(err) );

                        FIELDS[APPLICANT_2W_RISK_CATEGORY.fieldApiName] = updatedApplicant[APPLICANT_2W_RISK_CATEGORY.fieldApiName];
                        updateRecord(recordInputForUpdate).then(() => {
    
                        }).catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error creating record',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                        })
                    }else{
                        getAddressMatchAPI({
                            applicantId: this.appId
                        }).then(result => {
                           
                        })
                        .catch(error => {
                            this.isLoaded = false;
                            console.log('result is ' + JSON.stringify(error));
                        })
        
        
                    }
                }
                //End
                            this.getApplicants();

                       
                        })
                        .catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error creating record',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                        });


                }))

            }
            this.dispatchEvent(new CustomEvent('editmode', {
                detail: false
            }));
        }
        this.isLoading = false;
    }
    breRunMaterialFields(){
        let screenType= this.selectedAddresstype!=null ? this.selectedAddresstype : this.addressTypeValue!=null ?  this.addressTypeValue:'';
        screenType = screenType +' '+'Address';
        let loan = this.recordId == undefined ? this.loanId : this.recordId;
        checkMaterialFields({
            strScreen: screenType,
            strLoanId: loan, //this.recordId
            lstFieldsAPI : this.breTrackingFieldList

        }).then(data => {

        })
        .catch(error => {
            console.log('error in material' + JSON.stringify(error));
        })
    }

    isCheckValidity() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        for (let inputField of inputFields) {
            if(!inputField.required && !inputField.value){
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
            else if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        };
        return isValid;
    }

    // Check if Current & Permanent address source are same or not.
    checkAddressSourceValidation(){
        let recordPermanentFound = this.addressLst.find((item) => item.Address_Type__c === 'Permanent');
        let recordCurrentFound = this.addressLst.find((item) => item.Address_Type__c === 'Current');
        if (this.customerType == undefined) {
            this.customerType = this.loanApplication.Customer_Type__c;
        }
        if ((recordPermanentFound != undefined) || (recordCurrentFound != undefined)) {
            if((!this.sameasValue || this.sameasValue == 'NA') && (this.addressTypeValue == 'Current' && recordPermanentFound!=undefined && recordPermanentFound.Address_Source__c == this.addressTakenFromValue)){ // Added this check for recordPermanentFound != undefined check for R2-3113
                this.showMessage('Permanent & Current address source cannot be same.', 'error');
                return false;
           }
        }
        return true;
    }

    @api
    nextHandler() {
        if(this.addressEditRestricted || this.blnRestrictEdit){ //4473
            if(this.blnRestrictEdit){
                this.showToastMessage('Access Restricted', 'Address Details were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            }else if(this.addressEditRestricted){
                this.showToastMessage('', 'Address Details were not updated as KYC is already Approved', 'warning', 'sticky');
            }
            const Obj = {};
            Obj.next = true; 
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));  
        }else{
           
            let applcntRec = this.applicantId;
            let recordPermanentFound = this.addressLst.find((item) => item.Address_Type__c === 'Permanent');
            let recordCurrentFound = this.addressLst.find((item) => item.Address_Type__c === 'Current');
            let recordOfficeFound = this.addressLst.find((item) => item.Address_Type__c === 'Office');
            let recordLandFound = this.addressLst.find((item) => item.Address_Type__c === 'Land');

            if(this.isTractorLoan && !recordLandFound && this.customerType=='Individual'){//added individual check for R2-2604
                this.showToastMessage('', 'Land Address Mandatory for Tractor Loans', 'error', 'sticky');
                return
            }
            if(this.isTractorLoan && recordLandFound){
                if(recordLandFound.Same_As__c=='NA' && !recordOfficeFound && this.customerType=='Individual'){//added individual check for R2-2604
                    this.showToastMessage('', 'Please add Office Address since Land Address is marked as NA. ', 'error', 'sticky');
                    return
                }
                
            }
        console.log('recordPermanentFound-->' + JSON.stringify(recordPermanentFound));
        console.log('recordCurrentFound-->' + JSON.stringify(recordCurrentFound));
        console.log('next-->' + JSON.stringify(this.loanApplication));
        const isOfficeAddressApplicable = this.isOfficeAddressApplicable( this.loanApplication );
        if (this.isCheckValidity()) {
            if (this.customerType == undefined) {
                this.customerType = this.loanApplication.Customer_Type__c;
            }

            if (this.customerType == 'Individual') {
                if (this.showingwarningIcon == true) {
                    this.showMessage('Please add required fields in Permanent Address Type to Proceed Further', 'error');
                } else {
                    if ((recordPermanentFound != undefined) && (recordCurrentFound != undefined) && (recordOfficeFound != undefined || !isOfficeAddressApplicable)) {
                            
                            if(!recordCurrentFound.Same_As__c  && recordCurrentFound.Address_Source__c == recordPermanentFound.Address_Source__c){
                                this.showMessage('Permanent & Current address source cannot be same.', 'error');
                                let returnObj = {
                                    'next': false, 
                                    'errorOnChild': 'Please select different address source.',
                                }
                                this.dispatchEvent(new CustomEvent('next', {
                                    detail: returnObj
                                }));
                                
                            }else{
                            let returnObj = {
                                'next': true, //Ashish to check
                                'errorOnChild': '',
                            }

                            this.dispatchEvent(new CustomEvent('next', {
                                detail: returnObj
                            }));
                            }
                           
                        } else if ((recordPermanentFound == undefined) && (recordCurrentFound == undefined) && (recordOfficeFound == undefined && isOfficeAddressApplicable)) { //Pooja
                            this.showMessage('Please add Permanent,Office and Current Addresses to Proceed Further', 'error');
                            let returnObj = {
                                'next': false, //Ashish to check
                                'errorOnChild': 'Please add Permanent, Office and Current Addresses to Proceed Further',
                            }

                            this.dispatchEvent(new CustomEvent('next', {
                                detail: returnObj
                            }));
                        } else { //Pooja
                            let message = '';
                            message = (recordPermanentFound != undefined) ? 'Current Address Type' : 'Permanent Address Type';
                            if((recordOfficeFound == undefined && isOfficeAddressApplicable ) && recordCurrentFound == undefined)
                                message = 'Office , Current Address Type';
                            
                            else if(recordCurrentFound == undefined)
                                message =  'Current Address Type' ;
                            
                            else if(recordOfficeFound == undefined && isOfficeAddressApplicable)
                                message =  'Office Address Type' ;
                            this.showMessage('Please add ' + message + ' to Proceed Further', 'error');
                            /*if(recordPermanentFound != undefined && (recordCurrentFound == undefined) && (recordOfficeFound == undefined))
                                message = 'Current Address Type & Office Address Type';//(recordPermanentFound != undefined) ? 'Current Address Type' : 'Permanent Address Type';
                            if(recordPermanentFound == undefined && (recordCurrentFound != undefined) && (recordOfficeFound == undefined))
                                message = 'Permanent Address Type & Office Address Type';
                            if(recordPermanentFound != undefined && (recordCurrentFound != undefined) && (recordOfficeFound == undefined))
                                message = 'Permanent Office Type';
                            this.showMessage('Please add ' + message + ' to Proceed Further', 'error'); */
                            let returnObj = {
                                'next': false, //Ashish to check
                                'errorOnChild': 'Please add Permanent and Current Addresses to Proceed Further',
                            }

                            this.dispatchEvent(new CustomEvent('next', {
                                detail: returnObj
                            }));
                        }
                    }
                } else if (this.customerType == 'Non Individual') {
                    if (recordCurrentFound == undefined && recordOfficeFound != undefined) {
                        this.showMessage('Please add Current Addresses to Proceed Further', 'error');
                        let returnObj = {
                            'next': false, //Ashish to check
                            'errorOnChild': 'Please add Current Addresses to Proceed Further',
                        }

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: returnObj
                    }));
                }else if(recordCurrentFound != undefined && recordOfficeFound == undefined){
                    this.showMessage('Please add Office Addresses to Proceed Further', 'error');
                    let returnObj = {
                        'next': false, 
                        'errorOnChild': 'Please add Office Addresses to Proceed Further',
                    }

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: returnObj
                    }));
                }else if(recordCurrentFound == undefined && recordOfficeFound == undefined){
                    this.showMessage('Please add Office and Current Addresses to Proceed Further', 'error');
                    let returnObj = {
                        'next': false, 
                        'errorOnChild': 'Please add Office and Current Addresses to Proceed Further',
                    }

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: returnObj
                    }));
                }  else if(recordCurrentFound != undefined && recordOfficeFound != undefined){
                    let returnObj = {
                        'next': true, //Ashish to check
                        'errorOnChild': '',
                    }

                        this.dispatchEvent(new CustomEvent('next', {
                            detail: returnObj
                        }));
                    }
                }
            }
        }   

    }
    
    /*
    @description - to check login user have access to edit record
    */
    checkRestrictRecord () {
        validateRecordEdit({
            compName: 'addressInformationComponent' ,recordId: this.appId
            }).then(data => {
                if (data) {
                    this.blnRestrictEdit = data.blnRestrictEdit;
                    this.blnGoNext = data.blnMoveNext;
                }
            }).catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    /*
    @description - show restrict message
    */
    restrictAccessMessage () {
        const evt = new ShowToastEvent({
            title: 'Access Restricted',
            message: 'You do not have access to change Address Information',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


     //1 Sep added notification 
     sendNotification(){
        sendDeemedNotification({ loanId: this.loanId }).then((data => {
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end

    // R2-19
    isOfficeAddressApplicable = ( { Original_Vehicle_Usage__c: vehicleUsage, Customer_Type__c: customerType, Product__c: productCode } ) => !(OFFICE_ADDRESS_INELIGIBLE_PRODUCTS.includes( productCode ) && (vehicleUsage === 'Agri'  || this.vehicleUsage === 'Agri') && this.customerType === 'Individual');

}