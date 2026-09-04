import { LightningElement, wire, track, api } from 'lwc';
import Questionaire from '@salesforce/apex/FieldInvestigationQuestionaireController.Questionaire';
//import getPrintQuestionaire from '@salesforce/apex/FieldInvestigationQuestionaireController.getPrintQuestionaire';
import { NavigationMixin } from 'lightning/navigation';
import fiPhoneFields from '@salesforce/label/c.Fi_Phone_Fields';
import AutoLoanCowLabel from '@salesforce/label/c.AutoLoanCowLabel'; 

//import FORM_FACTOR from '@salesforce/client/formFactor';

export default class FieldInvestigationQuestionaire extends NavigationMixin(LightningElement) {

    @track WrapperDataList = [];
    @track borrowerList = [];
    @track VehicleList = [];
    @track isGuarantorSectionActive = true;
    @track isCoAppSectionActive = true;
    @track isBorrowerSectionActive = true;
    @track checkPermanent;
    @track checkTwoWheelerType;
    @track checkAutoLoan;
    @track checkOffice;
    @track checkCurrent;
    @track checkValidity;
    @track fieldList = {};
    @track activeTab = '1';
    @track booleanRender = false;
    @track blnMandatory;
    @track isMobile = false;
    @api isFiProfile = false;
    @api recordId;
    @api applicantType;
    @api typeOfAddress;
    @api proposedVehicle;
    @api openingRemarks;
    @api fiagentId = '';
    @track isPrintable = true;
    @track currentdatetime = '';
    @track currentdate = '';
    @track currenttime = '';
    @api userwithempcode = '';
    @api ficunducteddatetime = '';
    @track renderApplicantDetails_ApplicantPage = true;
    @track renderApplicantDetails_VehiclePage = false;

    handlePrint() {
        
    }
    handleActive(event) {
        this.activeTab = event.target.value;
    }
    changeTab() {
        this.activeTab == '2' ? this.activeTab = '1' : this.activeTab = '2';
    }
    get checkForNullValues() {
        if (this.applicantType == null || this.typeOfAddress == null || this.proposedVehicle == null) {
            return true;
        }
        else {
            return false;
        }
    }
    get showMessage() {
        if (this.applicantType == null) {
            return 'Applicant type is empty';
        }
        if (this.typeOfAddress == null) {
            return 'Address type is empty';
        }
        if (this.proposedVehicle == null) {
            return 'Proposed Vehicle is empty';
        }
    }
    get getTabLabel() {
        return this.applicantType + ' Detail';
    }
    connectedCallback() {
        console.log('this.applicantType>>>>>>' + this.applicantType);
        console.log('this.typeOfAddress>>>>>>' + this.typeOfAddress);
        console.log('this.openingRemarks>>>>>>' + this.openingRemarks);

        if (this.applicantType == 'Applicant') {
            this.isGuarantorSectionActive = false;
            this.isCoAppSectionActive = false;
            this.isBorrowerSectionActive = true;
        }
        else if (this.applicantType == 'Co-Applicant') {
            this.isGuarantorSectionActive = false;
            this.isCoAppSectionActive = true;
            this.isBorrowerSectionActive = false;

        }
        else if (this.applicantType == 'Guarantor') {
            this.isGuarantorSectionActive = true;
            this.isCoAppSectionActive = false;
            this.isBorrowerSectionActive = false;
        }


        if (this.typeOfAddress == 'Current') {
            this.checkPermanent = false;
            this.checkCurrent = true;
            this.checkOffice = false;
        }
        else if (this.typeOfAddress == 'Permanent') {
            this.checkPermanent = true;
            this.checkCurrent = false;
            this.checkOffice = false;

        }
        else if (this.typeOfAddress == 'Office') {
            this.checkPermanent = false;
            this.checkCurrent = false;
            this.checkOffice = true;
        }


        if (this.proposedVehicle == 'Two Wheeler (New)' || this.proposedVehicle == 'Two Wheeler (Used)'
            || this.proposedVehicle == 'Two Wheeler (Cash on Wheels)' ||  AutoLoanCowLabel.toUpperCase().includes(this.proposedVehicle.toUpperCase())) {
            this.checkTwoWheelerType = true;
            this.checkAutoLoan = false;
        } else {
            // R2 - commented this out as this component is used only for 2W, 4W & Commercial and 4W questions should work for Commercial too
            /*if (this.proposedVehicle == 'Auto Loan (New)' || this.proposedVehicle == 'Auto Loan (Used)'
            || this.proposedVehicle == 'Auto Loan (Cash on Wheels)') {*/
            this.checkTwoWheelerType = false;
            this.checkAutoLoan = true;
            //}
            //else 
        }
        console.log('before call apex 111');
        this.openingRemarks == 'Door Lock' ? this.blnMandatory = false : this.blnMandatory = true;
        if (this.applicantType != null) {
            console.log('before call apex 222');
            Questionaire({ applicantType: this.applicantType, blnMandatory: this.blnMandatory, blnFromMobile: false, proposedVehicle: this.proposedVehicle })
                .then(result => {
                    if (result != null) {
                        this.borrowerList = result.BorrowerList;
                        this.VehicleList = result.VehicleList;
                        let nowtime = Date.now();
                        console.log('nowtime-----' + nowtime);
                        //let datenow = new Date(nowtime).toLocaleDateString("en-IN");
                        //console.log('datenow-----' + datenow);
                        if(this.ficunducteddatetime!=null){
                            this.currentdatetime = this.getCurrentDateTime(this.ficunducteddatetime);

                        }
                        
                        this.booleanRender = true;
                        
                        console.log('blnMandatory-----' + this.blnMandatory);
                        console.log('borrowerList>>>>' + JSON.stringify(this.borrowerList));
                        console.log('VehicleList>>>>' + JSON.stringify(this.VehicleList));
                    }
                })
                .catch(error => {
                    console.log('this.error>>>>>' + JSON.stringify(error));
                    console.log('this.error>>>>>' + JSON.stringify(this.error));

                    this.error = error;
                });
        }

        console.log('recordiD-----' + this.recordId);
    }
    handleBack(event) {
        const storeEvent = new CustomEvent('back',
            {}
        );
        this.dispatchEvent(storeEvent);

        console.log('onsuccess event recordEditForm', event.detail.id)
    }
    handleSuccess(event) {
        const storeEvent = new CustomEvent('save',
            {}
        );
        this.dispatchEvent(storeEvent);

        console.log('onsuccess event recordEditForm', event.detail.id)
    }



    handleFieldChange(event) {
        console.log('fieldname>>>>' + typeof event.detail.fieldName);
        console.log('Event =>>' + JSON.stringify(event.detail.value));
        console.log('Event =>>123' + JSON.stringify(event.detail.fieldName));
        console.log('fiPhoneFields =>>' + JSON.stringify(fiPhoneFields));
       // var expr = /^(0|91)?[6-9][0-9]{9}$/;
     /*  var expr =  /^\d+$/;
        const myArray = fiPhoneFields.split(",");
        console.log('myArray =>>' + JSON.stringify(myArray));

        for (const key in myArray) {
            if (myArray[key] == event.detail.fieldName) {
                if (!expr.test(event.detail.value)) {
                  //  event.detail.value=null;
                }

            }
        }*/

        
        if (event.detail.fieldName == 'Employment_status__c') {
            if ((event.detail.value == 'Self employed')) {
                this.doMandatory('Office_business_Ownership__c', 'Business_nature__c', 'Year_in_present_Employment_business__c', 'Property_situated_in_a_negative_area__c', null, null, null, true);

            }
            else {
                this.doMandatory('Office_business_Ownership__c', 'Business_nature__c', 'Year_in_present_Employment_business__c', 'Property_situated_in_a_negative_area__c', null, null, null, false);

            }

        }


        if (event.detail.fieldName == 'Employment_status__c') {
            if ((event.detail.value == 'Salaried')) {
                this.doMandatory('Office_FI_Company_Name__c', 'Company_Address__c', 'Contact_No__c', 'No_of_Year_in_present_Employment__c', 'Name_of_reporting_Boss_HR__c', 'Mobile_no_of_Boss_HR__c', null, true);

                console.log('borrowerList>>>>' + JSON.stringify(this.borrowerList));
            }
            else {
                this.doMandatory('Office_FI_Company_Name__c', 'Company_Address__c', 'Contact_No__c', 'No_of_Year_in_present_Employment__c', 'Name_of_reporting_Boss_HR__c', 'Mobile_no_of_Boss_HR__c', null, false);

            }
        }


        //start 
        if (event.detail.fieldName == 'Present_vehicle_in_family__c') {
            if (event.detail.value.includes("NA")) {
                this.doMandatoryVehicle('Vehicle_Make__c', 'Vehicle_Number__c', null, false, true, true);
            }
            else {
                this.doMandatoryVehicle('Vehicle_Make__c', 'Vehicle_Number__c', null, false, true, false);

            }
        }
        //end

        if (event.detail.fieldName == 'Does_Customer_have_Driving_License__c') {
            if ((event.detail.value == 'Yes – Commercial Vehicle License')) {
                this.doMandatoryVehicle('ExperienceOfDrivingWith_Com_vehicle__c', 'Use_of_vehice_for_what_purpose__c', null, true, false, true);
            }
            else {
                this.doMandatoryVehicle('ExperienceOfDrivingWith_Com_vehicle__c', 'Use_of_vehice_for_what_purpose__c', null, true, false, false);

            }
        }

        if (event.detail.fieldName == 'Was_the_vehicle_Re_possessed__c') {

            if ((event.detail.value == 'Yes')) {
                this.doMandatoryVehicle('Detail_of_default__c', 'Who_will_drive_this_vehicle__c', 'Does_Customer_have_Driving_License__c', true, false, true);

            }
            else {
                this.doMandatoryVehicle('Detail_of_default__c', 'Who_will_drive_this_vehicle__c', 'Does_Customer_have_Driving_License__c', true, false, false);

            }
        }
        //start land
        if (event.detail.fieldName == 'Is_the_owner_of_AGRI_land__c') {
            if ((event.detail.value == 'Yes')) {
                this.doMandatory('How_many_acres_Bigha__c', 'Tentative_value_of_the_Land__c', null, null, null, null, null, true);
            }
            else {
                this.doMandatory('How_many_acres_Bigha__c', 'Tentative_value_of_the_Land__c', null, null, null, null, null, false);
            }
        }
        console.log('milk>>>' + event.detail.value);
        //End land
        //start dairy
        if (event.detail.fieldName == 'Source_of_Income_Multiple_Selection__c') {
            if (event.detail.value.includes("Milk Dairy")) {
                this.doMandatory('No_of_cattle_s__c', null, null, null, null, null, null, true);
            }
            else {
                this.doMandatory('No_of_cattle_s__c', null, null, null, null, null, null, false);
            }
        }
        //end dairy

        if (event.detail.fieldName == 'Borrower_or_family_prof_fall_in_negative__c') {
            if ((event.detail.value == 'Yes')) {
                this.doMandatory('Name_of_person__c', 'Profile_of_the_person__c', null, null, null, null, null, true);
                console.log('borrowerList>>>>' + JSON.stringify(this.borrowerList));
            }
            else {
                this.doMandatory('Name_of_person__c', 'Profile_of_the_person__c', null, null, null, null, null, false);
            }
        }


        if (event.detail.fieldName == 'Is_the_Residence_owned_by_the_Borrower__c' || event.detail.fieldName == 'Residence_own_by_borrower_TW__c') {
            if ((event.detail.value == 'Owned – Self/Spouse/parental' || event.detail.value == 'Relative' || event.detail.value == 'Owned' || event.detail.value == 'parental')) {
                this.doMandatory('Name_of_Property_Owner__c', 'Relationship_with_Property_Owner__c', 'Name_of_property_owner_confirmed_from__c', 'Tentative_value_of_the_property__c', null, null, null, true);
                this.doMandatory('Name_of_landlord__c', 'Mobile_Number_of_Landlord__c', 'Amount_of_Rent_in_Rs__c', null, null, null, null, false);
                console.log('borrowerList>>>>' + JSON.stringify(this.borrowerList));
            }
            else if ((event.detail.value == 'Rented – Bachelor accommodation' || event.detail.value == 'Rented with Family')) {
                this.doMandatory('Name_of_landlord__c', 'Mobile_Number_of_Landlord__c', 'Amount_of_Rent_in_Rs__c', null, null, null, null, true);
                this.doMandatory('Name_of_Property_Owner__c', 'Relationship_with_Property_Owner__c', 'Name_of_property_owner_confirmed_from__c', 'Tentative_value_of_the_property__c', null, null, null, false);
            }
            else {
                this.doMandatory('Name_of_Property_Owner__c', 'Relationship_with_Property_Owner__c', 'Name_of_property_owner_confirmed_from__c', 'Tentative_value_of_the_property__c', 'Name_of_landlord__c', 'Mobile_Number_of_Landlord__c', 'Amount_of_Rent_in_Rs__c', false);

            }

        }
        console.log('mapdata>>>>' + JSON.stringify(this.fieldList));
    }

    doMandatory(field1, field2, field3, field4, field5, field6, field7, isTrue) {

        for (let i = 0; i < this.borrowerList.length; i++) {
            if (this.borrowerList[i].apiName == field1 || this.borrowerList[i].apiName == field2 || this.borrowerList[i].apiName == field3
                || this.borrowerList[i].apiName == field4 || this.borrowerList[i].apiName == field5 || this.borrowerList[i].apiName == field6 || this.borrowerList[i].apiName == field7) {
                if (isTrue) {
                    this.borrowerList[i].isMandatory = true;
                }
                else {
                    this.borrowerList[i].isMandatory = false;
                }


            }
        }
    }
    doMandatoryVehicle(field1, field2, field3, isMand, isDisab, isTrue) {

        for (let i = 0; i < this.VehicleList.length; i++) {
            if (this.VehicleList[i].apiName == field1 || this.VehicleList[i].apiName == field2 || this.VehicleList[i].apiName == field3) {

                if (isMand) {
                    if (isTrue) {
                        this.VehicleList[i].isMandatory = true;
                    }
                    else {
                        this.VehicleList[i].isMandatory = false;
                    }
                }
                else if (isDisab) {
                    if (isTrue) {
                        this.VehicleList[i].isDisabled = true;
                    }
                    else {
                        this.VehicleList[i].isDisabled = false;
                    }
                }



            }
        }
    }

    getCurrentDateTime(ficondate) {
        console.log('today :: ' + ficondate.value);
        console.log('today :: ' + JSON.stringify(ficondate));
        var today = ficondate.value != '' && ficondate.value != null && ficondate.value != undefined && ficondate.value != 'undefined' ? ficondate.value : new Date();
        console.log('today :: ' + today);
        var todayDate =  String(today.getDate()).padStart(2, '0');
        var todayMonth = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var year = today.getFullYear();
        var currentOffset = today.getTimezoneOffset();

        var ISTOffset = 330;   // IST offset UTC +5:30 

        var ISTTime = new Date(today.getTime() + (ISTOffset + currentOffset) * 60000);

        // ISTTime now represents the time in IST coordinates

        var hh = ISTTime.getHours();
        var m = ISTTime.getMinutes();
        var s = ISTTime.getSeconds();
        var dd = "am";
        var h = hh;
        if (h >= 12) {
            h = hh - 12;
            dd = "pm";
        }
        if (h == 0) {
            h = 12;
        }
        m = m < 10 ? "0" + m : m;

        s = s < 10 ? "0" + s : s;
        var replacement = h + ":" + m;
        replacement += " " + dd;
        console.log('replacement>>>>' + replacement);
        //var currentDateTime = todayDate + '-' + todayMonth + '-' + year + ', ' + replacement;
        var currentDateTime = year + '-' + todayMonth + '-' + todayDate + ', ' + replacement;
        this.currentdate = year + '-' + todayMonth + '-' + todayDate;
        this.currenttime = replacement;
        console.log('this.currentDate>>>>' + this.currentDateTime);
        /*
        console.log('today' + today);
        const options = {
            day: 'numeric', month: '2-digit', year: 'numeric',
            hour: 'numeric', minute: 'numeric', second: 'numeric'
          };
        console.log(' dataParse.today' +  today);
        if ( today ) {
                    
            let dt = new Date( today );
            console.log('dt' + dt);
            let dddd =  new Intl.DateTimeFormat( 'default', options ).format( dt );
            console.log('dddd' + dddd);
            dddd = dddd.replaceAll('/','-');
            dddd = dddd.replaceAll(' ','-');
            dddd = dddd.replaceAll(',-',' ');
            dddd = dddd.replaceAll('-p',' p');
            dddd = dddd.replaceAll('-a',' a');
            dddd = dddd.toString();
            console.log('dddd' + dddd);
            return dddd;
        
        }
        */
        return currentDateTime;


    }

}