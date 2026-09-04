/** Utility file containing helper methods used across LWCs */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getVisibleField from '@salesforce/apex/Utility.getVisibleFields';
import bodyFundingCollateralCodes from '@salesforce/label/c.Commercial_Body_Funding_Collateral_Codes';
import implementCollateralCodes from '@salesforce/label/c.Tractor_Implement_Collateral_Codes';
import tractorProductCodes from '@salesforce/label/c.TractorProductCodes';
import carTaxiProductCodes from '@salesforce/label/c.CarTaxiProductCodes';
import cvPassengerProductCodes from '@salesforce/label/c.CVPassengerProductCodes';
import cvLoadingProductCodes from '@salesforce/label/c.CVLoadingProductCodes';
import ceProductCodes from '@salesforce/label/c.CEProductCodes';

const REGEX_COMMA_IGNORING_SPACES = /\s*,\s*/;

// R2-30
export const DEBOUNCE_TIMER = 1000;

// R2-788
export const STAGE_FTU = 'FTU';
export const STAGE_FTB = 'FTB';

// R2-19 - :TODO see if the codes can be moved to label
export const TRACTOR_NEW_PRODUCT_CODE = '10501';
export const TRACTOR_USED_PRODUCT_CODE = '10502';
export const TRACTOR_COW_PRODUCT_CODE = '10503';

export const CE_NEW_PRODUCT_CODE = '10401';
export const CE_USED_PRODUCT_CODE = '10402';
export const CE_COW_PRODUCT_CODE = '10403';

export const CV_LOADING_NEW_PRODUCT_CODE = '10104';
export const CV_LOADING_USED_PRODUCT_CODE = '10105';
export const CV_LOADING_COW_PRODUCT_CODE = '10106';

export const CV_PASSENGER_NEW_PRODUCT_CODE = '10101';
export const CV_PASSENGER_USED_PRODUCT_CODE = '10102';
export const CV_PASSENGER_COW_PRODUCT_CODE = '10103';

export const CAR_TAXI_NEW_PRODUCT_CODE = '10204';
export const CAR_TAXI_USED_PRODUCT_CODE = '10205';
export const CAR_TAXI_COW_PRODUCT_CODE = '10206';

export const CV_PASSENGER_PRODUCT_CODES = cvPassengerProductCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const CV_LOADING_PRODUCT_CODES = cvLoadingProductCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const CAR_TAXI_PRODUCT_CODES = carTaxiProductCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const CONSTRUCTION_EQUIPMENT_PRODUCT_CODES = ceProductCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const TRACTOR_PRODUCT_CODES = tractorProductCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const CV_PRODUCT_CODES = [
    ...CV_PASSENGER_PRODUCT_CODES, ...CV_LOADING_PRODUCT_CODES, ...CAR_TAXI_PRODUCT_CODES
];


export const BODY_FUNDING_COLLATERAL_TYPES = bodyFundingCollateralCodes.split( REGEX_COMMA_IGNORING_SPACES );
export const IMPLEMENT_COLLATERAL_TYPES = implementCollateralCodes.split( REGEX_COMMA_IGNORING_SPACES );

export const OLD_BS_OPTIONS = [ 'BS2', 'BS3' ]; //R2-2092

// R2-17
export const TRACTOR_RT_NAME = 'Tractor';

export const COMMERCIAL_VEHICLE_RT_NAME = 'Commercial Vehicle';
export const CONSTRUCTION_EQUIPMENT_RT_NAME = 'Construction Equipment';

export const COMMERCIAL_RECORD_TYPE_NAMES = [
    COMMERCIAL_VEHICLE_RT_NAME,
    CONSTRUCTION_EQUIPMENT_RT_NAME
];

export const CO_APPLICANT_RECORD_TYPE_LABEL = 'Co-Applicant';

// R2-2815 - Other funding if taken should be > 0
export const OTHER_FUNDING_ITEMS_MAPPINGS = {
    Insurance_Funding__c: 'Insurance_Value__c',
    LS__c: 'LS_Value__c',
    Body__c: 'Body_Value__c',
    Accessories_Funding__c: 'Accessories_Value__c',
    RTO_Tax__c: 'RTO_Tax_Value__c',
};

export function toast(cmp, title, variantType) {
    const toastEvent = new ShowToastEvent({
        title,
        variant: variantType,
        mode: "dismissable"
    })
    cmp.dispatchEvent(toastEvent)
}

export function stickyToast(cmp, title, variantType) {
    const toastEvent = new ShowToastEvent({
        title,
        variant: variantType,
        mode: "sticky"
    })
    cmp.dispatchEvent(toastEvent)
}

export function toastWithMessage(cmp, title, variantType, msg) {
    const toastEvent = new ShowToastEvent({
        title,
        message: msg,
        variant: variantType,
        mode: variantType?.toLowerCase() === 'error' ? 'sticky' : 'dismissible',
    })
    cmp.dispatchEvent(toastEvent)
}

export function showToastMessage(cmp, title, variantType, msg, mode) {
    const toastEvent = new ShowToastEvent({
        title,
        message: msg,
        variant: variantType,
        mode: variantType?.toLowerCase() === 'error' ? 'sticky' : mode
    })
    cmp.dispatchEvent(toastEvent)
}


export function generateTimeStampString() { // Only for group name
    const currentDate = new Date();
    let dateTime;
    const month = ((currentDate.getMonth() + 1) < 10 ? '0' : '') + (currentDate.getMonth() + 1);
    const date = ((currentDate.getDate()) < 10 ? '0' : '') + (currentDate.getDate());
    const hour = ((currentDate.getHours()) < 10 ? '0' : '') + (currentDate.getHours());
    const minute = ((currentDate.getMinutes()) < 10 ? '0' : '') + (currentDate.getMinutes());
    const Second = ((currentDate.getSeconds()) < 10 ? '0' : '') + (currentDate.getSeconds());
    dateTime = (month + date + hour + minute + Second)
    return dateTime.toString().substring(0, 9);
}





export function navigateToWebPage(cmp, url) {
    cmp[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": url
        }
    });
}



//For Currency Changes
export function formatCurrency(currencyType, currencyValue) {
    return currencyValue.includes(".") ? (new Intl.NumberFormat('en-US', { style: 'currency', currency: currencyType }).format((currencyValue.split(".")[0]).replaceAll(',', ''))).split(".")[0] + '.' + currencyValue.split(".")[1] : new Intl.NumberFormat('en-US', { style: 'currency', currency: currencyType }).format(currencyValue);

}
export function extractStringChar(data, substring) {
    let capturedData = data.replaceAll(/[^a-zA-Z0-9]/g, '');
    return capturedData.substring(0, substring);
}

/* Method to check Type of Employment is farmer or not*/
export function farmerCheck(employmentType) {
    if (employmentType === 'Farmer') {
        return true;
    } else {
        return false;
    }
}

/* Method to validate the required fields */
export function validate(inputFields, allowedPattern = {} ){
       let isValid = true;
       inputFields.forEach(inputField => {
            const fieldKey = inputField.name ?? inputField.dataset?.id ?? inputField.dataset?.name;
           if (!inputField.value) {
               inputField.setCustomValidity?.("Complete this field");
               inputField.reportValidity?.();
                isValid = false;
            } else if( allowedPattern.hasOwnProperty( fieldKey ) && validateViaRegex( allowedPattern[fieldKey], inputField.value ) ){
                isValid = inputField.reportValidity();
            } else {
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
        return isValid;
    
}

export function setPicklistsValues(data){
    let options=[]
    data.forEach(input=>{
        options.push({label:input,value:input})
    })
    return options
}

export function getUniqueValue(myList){
    let uniqueList = myList.reduce((accumulator, currentValue) => {
        if (!accumulator.find(item => JSON.stringify(item) === JSON.stringify(currentValue))) {
          accumulator.push(currentValue);
        }
        return accumulator;
      }, []);
      uniqueList.sort((a, b) => a.label.localeCompare(b.label)); 
      return uniqueList;
}

/* Method to get the visible fields based on the screen and profile */
export async function  getVisibleFields(strScreen, strStage,strProfile,strtypeOfWheeler,strcustomerType){
    return  await getVisibleField({strScreen: strScreen,strStage: strStage,strProfile :strProfile,typeOfWheeler: strtypeOfWheeler,customerType:strcustomerType})
}

/**
 * Taken from lwc-recipes
 * https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/lwc/ldsUtils/ldsUtils.js
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
export const reduceErrors = errors => {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // Page level errors
                else if (
                    error?.body?.pageErrors &&
                    error.body.pageErrors.length > 0
                ) {
                    return error.body.pageErrors.map((e) => e.message);
                }
                // Field level errors
                else if (
                    error?.body?.fieldErrors &&
                    Object.keys(error.body.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML page level errors
                else if (
                    error?.body?.output?.errors &&
                    error.body.output.errors.length > 0
                ) {
                    return error.body.output.errors.map((e) => e.message);
                }
                // UI API DML field level errors
                else if (
                    error?.body?.output?.fieldErrors &&
                    Object.keys(error.body.output.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.output.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

export function getApplicantName(applicant){
    return ((applicant.First_Name__c?applicant.First_Name__c:'')+(applicant.Middle_Name__c?' '+applicant.Middle_Name__c:'')+(applicant.Last_Name__c?' '+applicant.Last_Name__c:''))
}

export const getLoanType = product  => [ product.substr( 0, product.indexOf('(') ) , product.slice( product.indexOf('(') + 1, product.lastIndexOf( ')', -1 ) ) ];

export const delay = async timer => new Promise(res => setTimeout( res, timer ) );

/**
 * 
 * @param {Date} date 
 * @param {Number} days 
 * @returns Date
 */
export const addDays = ( date = new Date(), days = 0 ) => new Date( date.setDate( result.getDate() + days ) );

/**
 * 
 * @param {Date} date 
 * @param {Number} months 
 * @returns Date
 */
export const addMonths = ( date = new Date(), months = 0 ) => new Date( date.setMonth( date.getMonth() + months ) );


/**
 * 
 * @param {Number} defaultValue - default value to be passed if none of the args passed has valid values
 * @param {*} args - list of numbers that has to be considered to get least value
 * @returns {Number} - least applicable value
 */
export const getLeastAmount = ( defaultValue, args ) => {
    const values = [
        ...args
    ]
    .map( num => num ? num : Number.POSITIVE_INFINITY )
    .filter( num => !isNaN( num ) )
    .sort(( a,b ) => (a - b) );

    return values.length && values[0] !== Number.POSITIVE_INFINITY ? values[0] : defaultValue;
}

export const validateViaRegex = ( regex, fieldValue ) => !regex.test(fieldValue);


// R2-2815 - Other funding if taken should be > 0
export const validateLoanFunding = ( fundingMappings = {}, collateral = {} ) => {
    let isValid = true;
    for( const key in fundingMappings ){
        if( ( collateral[ key ] || collateral[ key ] === 'Yes' ) && !( +collateral?.[ fundingMappings[ key ] ] > 0 ) ){
            isValid = false;
        }
    }
    return isValid;
};