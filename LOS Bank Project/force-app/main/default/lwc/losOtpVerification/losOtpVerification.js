import { LightningElement, track,wire, api } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import diyCSS from '@salesforce/resourceUrl/DIYCommonStyles';
import communityBasePath from '@salesforce/community/basePath';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { CurrentPageReference } from 'lightning/navigation';
import diyRequestCallbackAssets from '@salesforce/resourceUrl/diyRequestCallbackAssets';
import diyIntlTelInputAssets from '@salesforce/resourceUrl/diyIntlTelInputAssets';
import init from '@salesforce/resourceUrl/init';
//Interset Rate - Custom Label
//import diyInterestRate from "@salesforce/label/c.DIY_HL_Interest_Rate";
//import getApplicantDetails from '@salesforce/apex/DIYRequestController.getApplicantDetails';


export default class DiyMOBDOBLoginPage extends LightningElement {

    bgCopy = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/bg - Copy.png';
    interestIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/interest.png';
    onlineSanctionIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/online.png';
    calendarIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/Calendar.png';
    downArrowIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/down_arrow_icon_small_1.png';
    captchaMobileIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/captcha-mobile.png';
    captchaIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/captcha.png';
    captchaaIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/captchaa.png';
    callIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/call.png';
    iAmNotRobotIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/im-not-a-robot.png';
    checkIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/check.png';
    checkedIcon = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/checked.png';
    bg = diyRequestCallbackAssets + '/diyRequestCallbackAssets/img/bg.png';
    backgroundSet ='background-image:url('+ this.bg +');background-repeat:no-repeat, repeat; height: max-content;';

    //Temporary Code : Google Captcha Visibility Boolean (Need to send google captcha display status from parent component - diyRequestCallback)
    isCaptchaEnabledBool = true;
    isResourceLoading = true;
    //User Input Variables
    loanAmountOptionSelected = 1; //Default : Option 1 (0 - 15 Lakhs)
    productName;
    freezeProduct
    @api product;
    dobDate;
    otpParentDivClass = 'form-group row fieldDisabledParent';
    otpLabelClass = 'did-floating-label fieldDisabledParent';

    @api autoPopulateEncryptedApplicantId;
    toggleDisplayOnResourceLoad = 'display:none;';
    //User Input Validation Variables 
    /* A 10/08/2022 */
    isProductValid = false;
    isDOBValid = false;
    //Amit 28/9
    isDOBInvalid = false;
    isNumberValid = false;
    isOTPValid = false;
    ndncConsent = false;
    whatsappConsent = false;
    isCaptchaValid = '';
    isResend = false;
    sendOTPCount = 0;
    otpEntered = '';
    OTPVerified = false;
    secretOTP = '123987';
    wrongOTP = false;
    otpVerifyCount = 0;
    wrongOTPLimitHit = false;
    wrongOTPLimitHitCounter = 180;
    /* A 10/08/2022 */
    countryCode;
    mobileNumber;
    selectedCountryCountryCodeLength=3;
    productTypeMissing=false;
    DOBMissing = false
    pauseResendOTP = false;
    flagCountryCode='+91';
    resentOTPCounter=30;
    OTPClass ='col-sm-13 col-form-label blue-text otp p-t-14';
    disableOTP = true;
    disableSendOTPButton = true;


    communityBasePath = communityBasePath;
    //Url parameter related variables
    currentPageReference = null;
    urlStateParameters = null;
    @api flow;
    encryptedApplicantId = '';
    isIncorrectOTP = false;

    @track maxDate;
    @track minDate;
    @track isHL = false;
    @track isTU = false;
    @track isBT = false;
    isButtonDisabled = true;
    mobileNumberWithCountryCode = '+91';
    wrongCountryCode = false;
    selectDropdown = 'nice-select';
    counterTimeout;

    //Added for Country Code Flag Picker
    showMobileNumberLabel = false;
    @api CountryName = '';
    @track inputElem ;
    @api isTrack;
    @api isResume;
    @track iti ;
    allCountries = [ [ "Afghanistan (‫افغانستان‬‎)", "af", "93" ], [ "Albania (Shqipëri)", "al", "355" ], [ "Algeria (‫الجزائر‬‎)", "dz", "213" ], [ "American Samoa", "as", "1", 5, [ "684" ] ], [ "Andorra", "ad", "376" ], [ "Angola", "ao", "244" ], [ "Anguilla", "ai", "1", 6, [ "264" ] ], [ "Antigua and Barbuda", "ag", "1", 7, [ "268" ] ], [ "Argentina", "ar", "54" ], [ "Armenia (Հայաստան)", "am", "374" ], [ "Aruba", "aw", "297" ], [ "Ascension Island", "ac", "247" ], [ "Australia", "au", "61", 0 ], [ "Austria (Österreich)", "at", "43" ], [ "Azerbaijan (Azərbaycan)", "az", "994" ], [ "Bahamas", "bs", "1", 8, [ "242" ] ], [ "Bahrain (‫البحرين‬‎)", "bh", "973" ], [ "Bangladesh (বাংলাদেশ)", "bd", "880" ], [ "Barbados", "bb", "1", 9, [ "246" ] ], [ "Belarus (Беларусь)", "by", "375" ], [ "Belgium (België)", "be", "32" ], [ "Belize", "bz", "501" ], [ "Benin (Bénin)", "bj", "229" ], [ "Bermuda", "bm", "1", 10, [ "441" ] ], [ "Bhutan (འབྲུག)", "bt", "975" ], [ "Bolivia", "bo", "591" ], [ "Bosnia and Herzegovina (Босна и Херцеговина)", "ba", "387" ], [ "Botswana", "bw", "267" ], [ "Brazil (Brasil)", "br", "55" ], [ "British Indian Ocean Territory", "io", "246" ], [ "British Virgin Islands", "vg", "1", 11, [ "284" ] ], [ "Brunei", "bn", "673" ], [ "Bulgaria (България)", "bg", "359" ], [ "Burkina Faso", "bf", "226" ], [ "Burundi (Uburundi)", "bi", "257" ], [ "Cambodia (កម្ពុជា)", "kh", "855" ], [ "Cameroon (Cameroun)", "cm", "237" ], [ "Canada", "ca", "1", 1, [ "204", "226", "236", "249", "250", "289", "306", "343", "365", "387", "403", "416", "418", "431", "437", "438", "450", "506", "514", "519", "548", "579", "581", "587", "604", "613", "639", "647", "672", "705", "709", "742", "778", "780", "782", "807", "819", "825", "867", "873", "902", "905" ] ], [ "Cape Verde (Kabu Verdi)", "cv", "238" ], [ "Caribbean Netherlands", "bq", "599", 1, [ "3", "4", "7" ] ], [ "Cayman Islands", "ky", "1", 12, [ "345" ] ], [ "Central African Republic (République centrafricaine)", "cf", "236" ], [ "Chad (Tchad)", "td", "235" ], [ "Chile", "cl", "56" ], [ "China (中国)", "cn", "86" ], [ "Christmas Island", "cx", "61", 2, [ "89164" ] ], [ "Cocos (Keeling) Islands", "cc", "61", 1, [ "89162" ] ], [ "Colombia", "co", "57" ], [ "Comoros (‫جزر القمر‬‎)", "km", "269" ], [ "Congo (DRC) (Jamhuri ya Kidemokrasia ya Kongo)", "cd", "243" ], [ "Congo (Republic) (Congo-Brazzaville)", "cg", "242" ], [ "Cook Islands", "ck", "682" ], [ "Costa Rica", "cr", "506" ], [ "Côte d’Ivoire", "ci", "225" ], [ "Croatia (Hrvatska)", "hr", "385" ], [ "Cuba", "cu", "53" ], [ "Curaçao", "cw", "599", 0 ], [ "Cyprus (Κύπρος)", "cy", "357" ], [ "Czech Republic (Česká republika)", "cz", "420" ], [ "Denmark (Danmark)", "dk", "45" ], [ "Djibouti", "dj", "253" ], [ "Dominica", "dm", "1", 13, [ "767" ] ], [ "Dominican Republic (República Dominicana)", "do", "1", 2, [ "809", "829", "849" ] ], [ "Ecuador", "ec", "593" ], [ "Egypt (‫مصر‬‎)", "eg", "20" ], [ "El Salvador", "sv", "503" ], [ "Equatorial Guinea (Guinea Ecuatorial)", "gq", "240" ], [ "Eritrea", "er", "291" ], [ "Estonia (Eesti)", "ee", "372" ], [ "Eswatini", "sz", "268" ], [ "Ethiopia", "et", "251" ], [ "Falkland Islands (Islas Malvinas)", "fk", "500" ], [ "Faroe Islands (Føroyar)", "fo", "298" ], [ "Fiji", "fj", "679" ], [ "Finland (Suomi)", "fi", "358", 0 ], [ "France", "fr", "33" ], [ "French Guiana (Guyane française)", "gf", "594" ], [ "French Polynesia (Polynésie française)", "pf", "689" ], [ "Gabon", "ga", "241" ], [ "Gambia", "gm", "220" ], [ "Georgia (საქართველო)", "ge", "995" ], [ "Germany (Deutschland)", "de", "49" ], [ "Ghana (Gaana)", "gh", "233" ], [ "Gibraltar", "gi", "350" ], [ "Greece (Ελλάδα)", "gr", "30" ], [ "Greenland (Kalaallit Nunaat)", "gl", "299" ], [ "Grenada", "gd", "1", 14, [ "473" ] ], [ "Guadeloupe", "gp", "590", 0 ], [ "Guam", "gu", "1", 15, [ "671" ] ], [ "Guatemala", "gt", "502" ], [ "Guernsey", "gg", "44", 1, [ "1481", "7781", "7839", "7911" ] ], [ "Guinea (Guinée)", "gn", "224" ], [ "Guinea-Bissau (Guiné Bissau)", "gw", "245" ], [ "Guyana", "gy", "592" ], [ "Haiti", "ht", "509" ], [ "Honduras", "hn", "504" ], [ "Hong Kong (香港)", "hk", "852" ], [ "Hungary (Magyarország)", "hu", "36" ], [ "Iceland (Ísland)", "is", "354" ], [ "India (भारत)", "in", "91" ], [ "Indonesia", "id", "62" ], [ "Iran (‫ایران‬‎)", "ir", "98" ], [ "Iraq (‫العراق‬‎)", "iq", "964" ], [ "Ireland", "ie", "353" ], [ "Isle of Man", "im", "44", 2, [ "1624", "74576", "7524", "7924", "7624" ] ], [ "Israel (‫ישראל‬‎)", "il", "972" ], [ "Italy (Italia)", "it", "39", 0 ], [ "Jamaica", "jm", "1", 4, [ "876", "658" ] ], [ "Japan (日本)", "jp", "81" ], [ "Jersey", "je", "44", 3, [ "1534", "7509", "7700", "7797", "7829", "7937" ] ], [ "Jordan (‫الأردن‬‎)", "jo", "962" ], [ "Kazakhstan (Казахстан)", "kz", "7", 1, [ "33", "7" ] ], [ "Kenya", "ke", "254" ], [ "Kiribati", "ki", "686" ], [ "Kosovo", "xk", "383" ], [ "Kuwait (‫الكويت‬‎)", "kw", "965" ], [ "Kyrgyzstan (Кыргызстан)", "kg", "996" ], [ "Laos (ລາວ)", "la", "856" ], [ "Latvia (Latvija)", "lv", "371" ], [ "Lebanon (‫لبنان‬‎)", "lb", "961" ], [ "Lesotho", "ls", "266" ], [ "Liberia", "lr", "231" ], [ "Libya (‫ليبيا‬‎)", "ly", "218" ], [ "Liechtenstein", "li", "423" ], [ "Lithuania (Lietuva)", "lt", "370" ], [ "Luxembourg", "lu", "352" ], [ "Macau (澳門)", "mo", "853" ], [ "Macedonia (FYROM) (Македонија)", "mk", "389" ], [ "Madagascar (Madagasikara)", "mg", "261" ], [ "Malawi", "mw", "265" ], [ "Malaysia", "my", "60" ], [ "Maldives", "mv", "960" ], [ "Mali", "ml", "223" ], [ "Malta", "mt", "356" ], [ "Marshall Islands", "mh", "692" ], [ "Martinique", "mq", "596" ], [ "Mauritania (‫موريتانيا‬‎)", "mr", "222" ], [ "Mauritius (Moris)", "mu", "230" ], [ "Mayotte", "yt", "262", 1, [ "269", "639" ] ], [ "Mexico (México)", "mx", "52" ], [ "Micronesia", "fm", "691" ], [ "Moldova (Republica Moldova)", "md", "373" ], [ "Monaco", "mc", "377" ], [ "Mongolia (Монгол)", "mn", "976" ], [ "Montenegro (Crna Gora)", "me", "382" ], [ "Montserrat", "ms", "1", 16, [ "664" ] ], [ "Morocco (‫المغرب‬‎)", "ma", "212", 0 ], [ "Mozambique (Moçambique)", "mz", "258" ], [ "Myanmar (Burma) (မြန်မာ)", "mm", "95" ], [ "Namibia (Namibië)", "na", "264" ], [ "Nauru", "nr", "674" ], [ "Nepal (नेपाल)", "np", "977" ], [ "Netherlands (Nederland)", "nl", "31" ], [ "New Caledonia (Nouvelle-Calédonie)", "nc", "687" ], [ "New Zealand", "nz", "64" ], [ "Nicaragua", "ni", "505" ], [ "Niger (Nijar)", "ne", "227" ], [ "Nigeria", "ng", "234" ], [ "Niue", "nu", "683" ], [ "Norfolk Island", "nf", "672" ], [ "North Korea (조선 민주주의 인민 공화국)", "kp", "850" ], [ "Northern Mariana Islands", "mp", "1", 17, [ "670" ] ], [ "Norway (Norge)", "no", "47", 0 ], [ "Oman (‫عُمان‬‎)", "om", "968" ], [ "Pakistan (‫پاکستان‬‎)", "pk", "92" ], [ "Palau", "pw", "680" ], [ "Palestine (‫فلسطين‬‎)", "ps", "970" ], [ "Panama (Panamá)", "pa", "507" ], [ "Papua New Guinea", "pg", "675" ], [ "Paraguay", "py", "595" ], [ "Peru (Perú)", "pe", "51" ], [ "Philippines", "ph", "63" ], [ "Poland (Polska)", "pl", "48" ], [ "Portugal", "pt", "351" ], [ "Puerto Rico", "pr", "1", 3, [ "787", "939" ] ], [ "Qatar (‫قطر‬‎)", "qa", "974" ], [ "Réunion (La Réunion)", "re", "262", 0 ], [ "Romania (România)", "ro", "40" ], [ "Russia (Россия)", "ru", "7", 0 ], [ "Rwanda", "rw", "250" ], [ "Saint Barthélemy", "bl", "590", 1 ], [ "Saint Helena", "sh", "290" ], [ "Saint Kitts and Nevis", "kn", "1", 18, [ "869" ] ], [ "Saint Lucia", "lc", "1", 19, [ "758" ] ], [ "Saint Martin (Saint-Martin (partie française))", "mf", "590", 2 ], [ "Saint Pierre and Miquelon (Saint-Pierre-et-Miquelon)", "pm", "508" ], [ "Saint Vincent and the Grenadines", "vc", "1", 20, [ "784" ] ], [ "Samoa", "ws", "685" ], [ "San Marino", "sm", "378" ], [ "São Tomé and Príncipe (São Tomé e Príncipe)", "st", "239" ], [ "Saudi Arabia (‫المملكة العربية السعودية‬‎)", "sa", "966" ], [ "Senegal (Sénégal)", "sn", "221" ], [ "Serbia (Србија)", "rs", "381" ], [ "Seychelles", "sc", "248" ], [ "Sierra Leone", "sl", "232" ], [ "Singapore", "sg", "65" ], [ "Sint Maarten", "sx", "1", 21, [ "721" ] ], [ "Slovakia (Slovensko)", "sk", "421" ], [ "Slovenia (Slovenija)", "si", "386" ], [ "Solomon Islands", "sb", "677" ], [ "Somalia (Soomaaliya)", "so", "252" ], [ "South Africa", "za", "27" ], [ "South Korea (대한민국)", "kr", "82" ], [ "South Sudan (‫جنوب السودان‬‎)", "ss", "211" ], [ "Spain (España)", "es", "34" ], [ "Sri Lanka (ශ්‍රී ලංකාව)", "lk", "94" ], [ "Sudan (‫السودان‬‎)", "sd", "249" ], [ "Suriname", "sr", "597" ], [ "Svalbard and Jan Mayen", "sj", "47", 1, [ "79" ] ], [ "Sweden (Sverige)", "se", "46" ], [ "Switzerland (Schweiz)", "ch", "41" ], [ "Syria (‫سوريا‬‎)", "sy", "963" ], [ "Taiwan (台灣)", "tw", "886" ], [ "Tajikistan", "tj", "992" ], [ "Tanzania", "tz", "255" ], [ "Thailand (ไทย)", "th", "66" ], [ "Timor-Leste", "tl", "670" ], [ "Togo", "tg", "228" ], [ "Tokelau", "tk", "690" ], [ "Tonga", "to", "676" ], [ "Trinidad and Tobago", "tt", "1", 22, [ "868" ] ], [ "Tunisia (‫تونس‬‎)", "tn", "216" ], [ "Turkey (Türkiye)", "tr", "90" ], [ "Turkmenistan", "tm", "993" ], [ "Turks and Caicos Islands", "tc", "1", 23, [ "649" ] ], [ "Tuvalu", "tv", "688" ], [ "U.S. Virgin Islands", "vi", "1", 24, [ "340" ] ], [ "Uganda", "ug", "256" ], [ "Ukraine (Україна)", "ua", "380" ], [ "United Arab Emirates (‫الإمارات العربية المتحدة‬‎)", "ae", "971" ], [ "United Kingdom", "gb", "44", 0 ], [ "United States", "us", "1", 0 ], [ "Uruguay", "uy", "598" ], [ "Uzbekistan (Oʻzbekiston)", "uz", "998" ], [ "Vanuatu", "vu", "678" ], [ "Vatican City (Città del Vaticano)", "va", "39", 1, [ "06698" ] ], [ "Venezuela", "ve", "58" ], [ "Vietnam (Việt Nam)", "vn", "84" ], [ "Wallis and Futuna (Wallis-et-Futuna)", "wf", "681" ], [ "Western Sahara (‫الصحراء الغربية‬‎)", "eh", "212", 1, [ "5288", "5289" ] ], [ "Yemen (‫اليمن‬‎)", "ye", "967" ], [ "Zambia", "zm", "260" ], [ "Zimbabwe", "zw", "263" ], [ "Åland Islands", "ax", "358", 1, [ "18" ] ]];

    connectedCallback() {

      /*  if (this.autoPopulateEncryptedApplicantId) {
            this.autoPopulateData(this.autoPopulateEncryptedApplicantId);
        }*/

        Promise.all([
        loadStyle(this, init), 
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/bootstrap.min.css'),
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/style.css'),
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/dark.css'),
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/responsive.css'),
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/font-awesome.css'),
        loadStyle(this, diyRequestCallbackAssets + '/diyRequestCallbackAssets/css/fonts-google-api.css'),
        loadStyle(this, diyIntlTelInputAssets + '/intlTelInputAssets/css/intlTelInput.css')
        ]).then(() => {
            this.inputElem = this.template.querySelector("[data-id=telField]");
            let ul = this.template.querySelector(".iti__country-list");

            for (var i = 0; i < this.allCountries.length; i++) {
            let li = document.createElement("li");
            li.setAttribute('data-country-code',this.allCountries[i][1]);
            li.setAttribute('c-diytestintltelflag_diytestintltelflag','');
            li.setAttribute('data-dial-code',this.allCountries[i][2]);
            li.setAttribute('class','iti__country iti__standard');


            let div1 = document.createElement("div");
            div1.setAttribute('class','iti__flag-box');
            var div2 = document.createElement("div");
            let countryFlagClassName = 'iti__flag iti__' + this.allCountries[i][1];
            div2.setAttribute('class',countryFlagClassName);

            let span1 = document.createElement("span");
            span1.setAttribute('class','iti__country-name');
            var span2 = document.createElement("span");
            span2.setAttribute('class','iti__dial-code');

            let text = document.createTextNode(this.allCountries[i][0]);
            let countryDialCode = '+' +this.allCountries[i][2];
            let text2 = document.createTextNode(countryDialCode);
            span1.appendChild(text);
            span2.appendChild(text2);
            div1.appendChild(div2);
            li.appendChild(div1);
            li.appendChild(span1);
            li.appendChild(span2);
            ul.appendChild(li);
            }
            this.isResourceLoading = false
            this.toggleDisplayOnResourceLoad = 'display:block;'
        })
        .catch(error => {
            console.log( 'error--> ' + error );
        });
    }

    renderedCallback()
    {
        if(this.product == 'HL' && this.isHL == true)
        {
            this.template.querySelector('[data-id ="productField"]').selectedIndex = 1;
            this.freezeProduct = true;
            this.productName = 'Home Loan';
            this.isProductValid = true;
        }
        else if(this.product == 'BT' && this.isBT == true)
        {
            this.template.querySelector('[data-id ="productField"]').selectedIndex = 2;
            this.freezeProduct = true;
            this.productName = 'Balance Transfer';
            this.isProductValid = true;
        }
        else if(this.product == 'TU' && this.isTU == true)
        {
            this.template.querySelector('[data-id ="productField"]').selectedIndex = 3;
            this.freezeProduct = true;
            this.productName = 'Top Up';
            this.isProductValid = true;
        }
        else
        {
            this.template.querySelector('[data-id ="productField"]').selectedIndex = 1;
            this.productName = 'Home Loan';
            this.isProductValid = true;
        }
    }

    @wire(CurrentPageReference) 
    getStateParametersCallBack(currentPageReference) {
        if (currentPageReference) {
            if(this.product == 'BT') {
                this.isBT = true;
            }
            else if(this.product == 'TU') {
                this.isTU = true;
            }
            else if(this.product == 'HL'){
                this.isHL = true;
            }
            if(diyInterestRate) {
                this.interestRate = diyInterestRate;
            }

            this.maxDate = this.getAgeDifferenceDate(18);
            this.minDate = this.getAgeDifferenceDate(65);
        }
    }


    getAgeDifferenceDate(age) {
        let dateString = '' + (new Date().getFullYear() - age);
        dateString += new Date().getMonth() < 9 ? '-0' +(new Date().getMonth()+1) :  '-' +(new Date().getMonth()+1);
        dateString += new Date().getDate() < 10 ? '-0' +new Date().getDate() :  '-' +new Date().getDate();
        return dateString;
    }

    /* A 10/08/2022 */
    handleCaptchaUpdate(event){
        //Handle captcha
        if (event.detail.response) {
            this.captchaResponse = event.detail.response;
            this.checkInputValidity();
        }
    }

    /* A 10/08/2022 */
    whatsAppConsentHandler(event){
        //Handle Whatsapp Consent
        this.whatsappConsent = event.target.checked;
        this.checkInputValidity();
    }

    /* A 10/08/2022 */
    ndncConsentHandler(event){
        // Handle NDNC Consent
        this.ndncConsent = event.target.checked;
        this.checkInputValidity();
    }

    /* A 10/08/2022 */
    productTypeHandler(event){
        this.productName=event.target.value;
        if(this.productName != ''){
            this.isProductValid = true;
            if(this.productName == 'Home Loan') {
                this.product = 'HL';
            } else if(this.productName == 'Balance Transfer') {
                this.product = 'BT';
            } else if(this.productName == 'Top Up') {
                this.product = 'TU';
            }
        }
        else{
            this.isProductValid = false;
            this.product = '';
        }
        this.checkInputValidity();
    }

    /* A 10/08/2022 */
    handleChangeDOBDate(event) {
        this.dobDate = event.target.value; 
        var dobVal = this.template.querySelector(".dateOfBirth");
        if(event.target.name=='dobField'){
            this.dobDate = event.target.value;
            var today = new Date();
            var age=today.getFullYear()-(new Date(dobVal.value)).getFullYear();
            var m = today.getMonth() - (new Date(dobVal.value)).getMonth();
            if (m < 0 || (m === 0 && today.getDate() < (new Date(dobVal.value)).getDate())) 
            {
                age--;
            }
            //Amit 28/9
            if(this.dobDate=='' || this.dobDate==null){
                this.hideError(event);
                this.isDOBValid = false;
                this.isDOBInvalid = true;
            }
            else if(age<18 || age>65){
                this.showError(event);
                this.isDOBValid = false;
                this.isDOBInvalid = false;
                //dobVal.setCustomValidity("You must be 18 years old and less than 65 years old.");
            }else{
                this.hideError(event);
                this.isDOBValid = true;
                this.isDOBInvalid = false;
            }
        }
        this.checkInputValidity();
    }

    //Added for Country Code Flag Picker
    toggleHighlightOnMouserOver(event)
    {
        if(event.target.classList.contains('iti__highlight'))
        {
            event.target.classList.remove('iti__highlight');
        }
        else
        {
            event.target.classList.add('iti__highlight');
        }
    }

    //Added for Country Code Flag Picker
    toggleIntTelFlagList()
    {
        if(this.OTPVerified == false)
        {
            let ul = this.template.querySelector(".iti__country-list");
            if(ul.classList.contains('iti__hide'))
            {
                ul.classList.remove('iti__hide');
            }
            else
            {
                ul.classList.add('iti__hide');
            }
        }
    }

    //Added for Country Code Flag Picker
    handleCountryChange(event)
    {
        let liElement;
        if(event.target.tagName.toLowerCase() === 'li')
        {
            liElement = event.target;
        }
        else
        {
            liElement = event.target.closest(".iti__country");
        }
        this.selectedCountryCountryCodeLength = liElement.getAttribute('data-dial-code').length + 1;
        this.flagCountryCode='+'+liElement.getAttribute('data-dial-code');
        this.template.querySelector(".selectedFlag").setAttribute('class','selectedFlag iti__flag iti__' +liElement.getAttribute('data-country-code'));
        this.template.querySelector("[data-id=telField]").value='+'+liElement.getAttribute('data-dial-code');
        this.toggleIntTelFlagList();
        this.resetPhoneData();
    }

    //Reset all the existing mobile and OTP inputs if country or mobile number changes
    resetPhoneData()
    {
        this.isNumberValid = false;
        this.OTPVerified = false;
        this.wrongCountryCode = false;
        this.sendOTPCount = 0;
        this.disableSendOTP();
        //this.disableOTPVerify();
    }

    handleChangePhoneNumberOnKeyUp(event) {
        this.wrongCountryCode = false;
        if(event.target.value == '')
        {
            this.template.querySelector("[data-id=telField]").value=this.flagCountryCode; 
        }
        const phoneRegex = /^[6-9]\d{9}$/gi;
        let countryCode = event.target.value.slice(0,this.selectedCountryCountryCodeLength);
        let number = event.target.value.slice(this.selectedCountryCountryCodeLength,14);
        
        if(countryCode!=this.flagCountryCode)
        {
            this.wrongCountryCode = true;
        }
        if(countryCode != '+91' && !this.wrongCountryCode)
        {
            this.hideError(event);
            if(number.length >=7)
            {
                //Change in number will reset 'Resend Otp' status back to 'Send Otp'
                if(number != this.mobileNumber)
                {
                    this.isResend = false;
                    this.sendOTPCount = 0;
                }        
                this.isNumberValid = true;
                this.countryCode = countryCode;
                this.mobileNumber = number;
                if(!this.pauseResendOTP)this.enableSendOTP();
            }
            else
            {
                this.isNumberValid = false;
                this.disableSendOTP();
            }
        }
        else if(countryCode == '+91' && number.match(phoneRegex) && !this.wrongCountryCode) {
            //Change in number will reset 'Resend Otp' status back to 'Send Otp'
            if(number != this.mobileNumber)
            {
                this.isResend = false;
                this.sendOTPCount = 0;
            }        
            this.hideError(event);
            this.isNumberValid = true;
            this.countryCode = countryCode;
            this.mobileNumber = number;
            if(!this.pauseResendOTP)this.enableSendOTP();
        }
        else {
            this.isNumberValid = false;
            this.disableSendOTP();
        }
        this.checkInputValidity();
    }

    handleChangePhoneNumberOnBlur(event) {
        if(!this.isNumberValid)
        {
            this.showError(event);
        }
        else
        {
            this.hideError(event);
        }
    }


    disableSendOTP(){
        //Disabling 'Send OTP Button'
        this.OTPClass = "col-sm-13 col-form-label blue-text otp p-t-14";
        this.disableSendOTPButton = true;
        /*var otpBtn = this.template.querySelector('.otp');
        otpBtn.classList.remove('bluee-text');
        otpBtn.classList.remove('otpClickable');
        otpBtn.classList.add('blue-text');*/
    }

    enableSendOTP(){
        //Enabling 'Send OTP Button'
        this.OTPClass = "col-sm-13 col-form-label bluee-text otp p-t-14 otpClickable";
        this.disableSendOTPButton = false;
        /*var otpBtn = this.template.querySelector('.otp');
        otpBtn.classList.remove('blue-text');
        otpBtn.classList.add('bluee-text');
        otpBtn.classList.add('otpClickable');*/
    }

    disableOTPVerify(){
        let OTPElement = this.template.querySelector("[data-id=verifyOTP]");
        OTPElement.classList.remove("bluee-text");
        OTPElement.classList.remove("verifyClickable");
        OTPElement.classList.add("blue-text");
    }

    enableOTPVerify(){
        let OTPElement = this.template.querySelector("[data-id=verifyOTP]");
        OTPElement.classList.remove("blue-text");
        OTPElement.classList.add("bluee-text");
        OTPElement.classList.add("verifyClickable");
    }

    handleSendOTP(){
        if(this.disableSendOTPButton)
        {
            return;
        }
        //check if product type and DOB is selected
        if(!this.isProductValid)
        {
            this.DOBMissing = false;
            this.productTypeMissing = true;
            return;
        }
        else if(!this.isDOBValid)
        {
            this.productTypeMissing = false;
            this.DOBMissing = true;
            return; 
        }
        else
        {
            this.DOBMissing = false;
            this.productTypeMissing = false;
        }
        //Call Send OTP Apex Method and update otp counter
        this.sendOTPCount++;
        if(this.sendOTPCount == 1){
            this.disableOTP = false;
            this.otpParentDivClass = 'form-group row';
            this.otpLabelClass = 'did-floating-label';
            this.isResend = true;
        }
        if(this.sendOTPCount == 3){
            this.disableSendOTP();
        }
        if(this.sendOTPCount == 1){
            // create Event which wll call the relevant js function in parent component
            const sendOTPEvent = new CustomEvent("handlsendotp", {
                detail:{
                    countryCode: this.countryCode,
                    mobileNumber: this.mobileNumber,
                    dobDate: this.dobDate,
                    product: this.product,
                    productName:this.productName,
                    flow:  this.flow!=null ? this.flow : 'callback',
                    componentName:'c-diy-m-o-b-d-o-b-login-page'
                }
            });

            // dispatch the event
            this.dispatchEvent(sendOTPEvent);
        }else{
            // create Event which wll call the relevant js function in parent component
            const resendOTPEvent = new CustomEvent("handleresendotp", {
            });

            // dispatch the event
            this.dispatchEvent(resendOTPEvent);
        }

        //check whether other fields are populated or not 
        if(this.countryCode != '+91')
        {
            this.isOTPValid = true;
            //this.OTPVerified = true;
        }
        else
        {

        this.disableSendOTP();
        //check whether other fields are populated or not
        this.pauseResendOTP = true;
        this.timedOTPActions = setInterval(() => {
            if(this.resentOTPCounter > 0 && this.pauseResendOTP){
                this.resentOTPCounter--;
                this.template.querySelector("[data-id=sendOTPTimer]").innerHTML = this.resentOTPCounter;
            }
            else{
                this.pauseResendOTP = false;
                this.resentOTPCounter = 30;
                this.template.querySelector("[data-id=sendOTPTimer]").innerHTML = this.resentOTPCounter;
                if (this.sendOTPCount < 3 && !this.OTPVerified)this.enableSendOTP();
                clearInterval(this.timedOTPActions);   
            }
        }, 1000);
        this.counterTimeout = setTimeout(() => { clearInterval(this.timedOTPActions); }, (this.resentOTPCounter + 1) * 1000);
        }
    }
    
    handleOTPChange(event)
    {
        this.otpEntered = event.target.value;
        let OTPRegex = /^[0-9]{6}$$/;
        if(OTPRegex.test(this.otpEntered)) 
        {
            if(this.isNumberValid  && this.sendOTPCount > 0 && this.sendOTPCount < 4)
            {
                this.enableOTPVerify();
                this.isOTPValid = true;
            }
            this.hideError(event);
        }
        else
        {
            this.disableOTPVerify();
            this.isOTPValid = false;
            //this.showError(event);
        }
    }

    handleOTPChangeOnBlur(event)
    {
        if(!this.isOTPValid)
        {
            this.showError(event);
        }
        else
        {
            this.hideError(event);
        }
    }

    //Call parent handleOTP
    handleOTPVerification(event)
    {
        if(this.isOTPValid)
        {
            const handleVerifyOTP = new CustomEvent("handleverifyotp", {
                detail:{
                    otpCode: this.otpEntered,
                    componentName:'c-diy-m-o-b-d-o-b-login-page'
                }
            });
            // dispatch the event
            this.dispatchEvent(handleVerifyOTP);
        }
        else
        {
            return;
        }
    }

    @api handleDuplicateLead(event)
    {
        this.isResend = false;
        this.sendOTPCount = 0;
        clearTimeout(this.counterTimeout);
        this.resentOTPCounter = 2;
    }

    //Function to be called from parent for successful otp verification
    @api successfulOTP(event)
    {
        this.OTPVerified = true;
        this.wrongOTP = false;
        //if OTP is correct, don't allow edit at number and OTP
        this.template.querySelector("[data-id=OTPInput]").disabled = true;
        this.template.querySelector("[data-id=telField]").disabled = true;
        this.template.querySelector("[data-id=productField]").disabled = true;
        this.template.querySelector("[data-id=dobField]").disabled = true;
        this.disableSendOTP();
        this.checkInputValidity();    
    }

    //Function to be called from parent for unsuccessful otp verification
    @api unsuccessfulOTP(event)
    {
        this.disableOTPVerify();
        this.isOTPValid = false;
        this.otpEntered = null;
        this.OTPVerified = false;
        this.otpVerifyCount = event;
        this.wrongOTP = true;
        if(this.otpVerifyCount == 2){
            this.isIncorrectOTP = true;
            this.wrongOTP = false;
        }
        else if(this.otpVerifyCount == 3){
            this.wrongOTP = false;
            this.wrongOTPLimitHit = true;
            this.disableOTP = true;
            this.disableOTPVerify();
            this.timedActions = setInterval(() => {
                if(this.wrongOTPLimitHitCounter > 0){
                    this.wrongOTPLimitHitCounter--;
                }
                else{
                    this.wrongOTPLimitHit = false;
                    this.wrongOTPLimitHitCounter = 180;
                    this.otpVerifyCount = 0;
                    this.disableOTP = false;
                    this.enableOTPVerify();
                }
            }, 1000);
            setTimeout(() => { clearInterval(this.timedActions); }, (this.wrongOTPLimitHitCounter + 1) * 1000);
        }
        this.checkInputValidity();
    }

    autoPopulateData(applicantId) {
        if (applicantId) {
            if(this.flow == 'calculate') {
                /*getApplicantDetails({
                    encryptedApplicantId: applicantId,
                    flow: this.flow,
                }).then(
                    result => {
                        if(result!=null) {
                            let appData = JSON.parse(JSON.stringify(result));
                            if(appData!=null && Object.keys(appData).length != 0) {
                                this.dobDate = appData.appDOB;
                                this.mobileNumber = appData.appPhone;
                                this.countryCode = appData.appCountryCode;
                                this.template.querySelector("[data-id=telField]").value = '' + this.countryCode + this.mobileNumber;
                                this.isNumberValid = true;
                                this.isDOBValid = true;
                                if(!this.pauseResendOTP)this.enableSendOTP();                
                        
                            }
                        }
                    })
                    .catch(error => {
                        console.log('Fetch Applicant Error->', error);
                    })*/
            }
        }
    }


    /* A 10/08/2022 */
    checkInputValidity(){
        var buttonElement = this.template.querySelector('.applyButton');
        if(this.isProductValid && this.isDOBValid && this.whatsappConsent && this.ndncConsent && this.captchaResponse 
            && this.isNumberValid && this.isNumberValid && this.OTPVerified){
            buttonElement.classList.remove('red-btn');
            buttonElement.classList.add('redd-btn');
            this.isButtonDisabled = false;
        }
        else{
            buttonElement.classList.remove('redd-btn');
            buttonElement.classList.add('red-btn');
            this.isButtonDisabled = true;
        }
    }

    //Generic method to show error
    showError(event)
    {
        let elementName = event.target.name;
        let errorOutputElementName = elementName+'ValidationError';
        let errorOutputElement = this.template.querySelector("[data-id="+errorOutputElementName+"]");
        errorOutputElement.style.display = "block";
        event.target.closest(".row").classList.add("red");
        event.target.closest(".row").style.marginBottom = '0px';
        event.target.nextElementSibling.classList.add("red-text");
    }

    //Generic method to hide error message
    hideError(event)
    {
        let elementName = event.target.name;
        let errorOutputElementName = elementName+'ValidationError';
        let errorOutputElement = this.template.querySelector("[data-id="+errorOutputElementName+"]");
        errorOutputElement.style.display = "none";
        event.target.closest(".row").classList.remove("red");
        event.target.closest(".row").style.marginBottom = null;
        event.target.nextElementSibling.classList.remove("red-text");
    }

    closeModal(){
        this.isIncorrectOTP = false;
    }

    handleApplyNow() {

        const applyNowEvent = new CustomEvent("handleapplynow", {
                detail:{
                    countryCode: this.countryCode,
                    mobileNumber: this.mobileNumber,
                    dobDate: this.dobDate,
                    product: this.product,
                    productName:this.productName,
                    boolIsCheckboxTermCondition:this.ndncConsent,
                    booleanWhatsappNotification:this.whatsappConsent,
                    flow:  this.flow!=null ? this.flow : 'callback',
                    navigateToSorry:false,
                    pageName:'loginDetail'
                }
            });

            // dispatch the event
            this.dispatchEvent(applyNowEvent);

    }
}