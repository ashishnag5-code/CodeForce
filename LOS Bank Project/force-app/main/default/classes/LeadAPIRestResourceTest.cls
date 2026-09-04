/**
* @description       : Test class for LeadAPIRestResource
* @author            : Raviteja Vattikuti
* @group             : 
* @last modified on  : 06-23-2023
* @last modified by  :  Raviteja Vattikuti
**/
@isTest
public class LeadAPIRestResourceTest {
        @TestSetup
    public static void makeData(){
         Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Dummy Digital Lead Record',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/SFDCKarzaService/NameMatch',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        MMV_Master__c objMake=(MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
            recordTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId(),
            Name='Hyundai',
            Active_in_2W_Vehicle__c=true,
            Active_in_4W_Vehicle__c =false,
            Active_in_Used_Vehicle__c=false
        ),true);
        
        MMV_Master__c objModel=(MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
            recordTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId(),
            Name='Venue',
            Active_in_2W_Vehicle__c=true,
            Active_in_4W_Vehicle__c =false,
            Active_in_Used_Vehicle__c=false
        ),true);
        
        MMV_Master__c objMMV=(MMV_Master__c)TestFactory.createSObject(new MMV_Master__c(
            Make__c=objMake.Id,
            Model__c=objModel.Id,
            Make_Model_Variant__c='MARUTI_CIAZ_ALPHA SMART HYBRID_PETROL',
            Active_in_2W_Vehicle__c=true,
            Active_in_4W_Vehicle__c =false,
            Active_in_Used_Vehicle__c=false
        ),true);
        
        Collateral__c objCollateral=(Collateral__c)TestFactory.createSObject(new Collateral__c(
            MMV_Master__c=objMMV.Id,
            loan__c=loanAppl.Id,
            Vehicle_Usage__c='Personal'
        ),true);
        
        Document_Master__c docMaster3 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0003', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
        
        Document_Master__c docMaster4 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0004', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
        
        Document_Master__c docMaster5 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0005', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
                
         Document_Checklist__c docChecklist3 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c = appl.Id, 
            Document_Master__c = docMaster3.Id,
            Loan_Application__c = loanAppl.Id
        ),true);
        
         Document_Checklist__c docChecklist4 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c = appl.Id, 
            Document_Master__c = docMaster4.Id,
            Loan_Application__c = loanAppl.Id
        ),true);
        
        Document_Checklist__c docChecklist5 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c = appl.Id, 
            Document_Master__c = docMaster5.Id,
            Loan_Application__c = loanAppl.Id
        ),true);
        
       
    }
    
    @isTest
    static void testMethodOne(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'apexrest/v1/LeadAPIRestResource';
        req.httpMethod = 'POST';
        String requestBody = '{"leadRecordList":[{"vehicleusage":"Personal","uptoinstallmentnovpi":null,"typeofreate":"Variable","totalloanamount":450000,"tenure":60,"sourcename":"MTV","sourcechannel":"Digital Partner","schemename":null,"schemecode":null,"scheduletype":"Monthly","roi":9.3,"repaymentstartdate":"05/04/2023","repaymentmode":"NACH without PDC","repaymentbankname":"Axis","repaymentaccountnum":"9000000001","purchasecity":"Delhi","promocode":"testpromo","productcode":"10201","pinCode":null,"ownerId":null,"outletname":"TestOutlet","outletcode":null,"nomineerelationship":"Brother","nomineepercentage":100,"hasnominee":true,"nomineename":"Neel Kamal","nomineedob":"05/05/1990","nomineecontact":"8987876565","moratoriumperiod":"1","loanpurpose":"Purchase of Vehicle","loannature":"Secured","loanId":null,"loanamount":450000,"lccode":"lccode","followuptime":"","followupdate":"15/06/2023","emifrequency":"Monthly","emidate":"04/04/2023","disbursementcategory":"Full","detailsvehicle":{"collateraltype":"new","collateralname":"10108","make":"MARUTI","model":"CIAZ","variant":"ALPHA SMART HYBRID_PETROL","color":"BLACK","fueltype":"PETROL","vehiclecategory":"C","vehicleusage":"Personal","vehicleyearmonth":"2-2023","enginecategory":"BS6","exshowroomprice":1000000,"discount":15000,"netdiscountprice":985000,"insurance":25000,"rtotaxes":"30000","isrtotax":"Yes","rtotaxamount":20000,"accessoriesfunding":"No","accessories":"15000","accessoriesvalue":null,"othercost":"50000","onroadprice":"1040000","finalcost":"1105000","insurancefunding":"Yes","insurancevalue":"20000","isLS":"No","lsamount":"490000","apportionedloanamount":490000,"vehiclenumber":"","enginenumber":"","chasisnumber":"","kilometer":"","hpnfinancename":"","currentowner":"","ownerserialnum":"","registrationcity":"","certifiedvalue":"","valuationamount":"","idvinsurancevalue":"","exitpolicyexp{":"","insuranceexpdate":"","existpolicy_insurercompany":"","exist_policytype":"","made_claim_last_year":"","ncb_percentage":null,"vehiclecost":null,"finalvehiclecost":null,"detailsvaluation":[{"referenceid":"487734424547373","product":"Auto Loan (Used)","collateraltype":"New","valuename_code":"Auto Inspect","otherstate_masterlist":"","coordinateforvaluation":"Ashish","contactperson_mobilenumber":"9999999999","allocationdatetime":"","completiondatetime":"","vehicle_number":"DL9CAG4934","make_model":"HMT_4022","enginenumber":"GDFUFU","chasisnumber":"HCHUC","manufacture_year":"02/2018","registration_date":"02/2018","ownerserial_number":"4","hypothication":"CHOLA","color":"Black","odometer":"20","fuel":"Petrol","vehicle_condition":"Running","valuation_amount":100000,"final_remarks":""}]},"detailsreference":[{"name":"ankit kumar","relation":"Brother","address":"Delhi","mobileno":"8888888800","isactive":"true"}],"detailsappdocument":null,"detailscharge":[{"valuetype":"Percent","chargename":"Stamp duty","actualrate":0.03,"chargeamount":1363.65}],"detailsapplicant":[{"existingcustomer":"No","applicanttype":"Co-Applicant","dob":"03/10/1983","aadhaarno":"554444454345","panno":"GBSTS9854M","voterid":"UP15MMMRESE","anform60":"Pan Card","drivinglicense":"UP1234DE1234","passportno":"AMBE233S","npr":"TNPR","nrega":"TNREGA","panverificationstatus":"Not Verified","title":"Mr","fname":"DummyLeadCoApp","mname":"","lname":"Sharma","gender":"Male","fathername":"Boney Kappor","mothername":"Sridevi","maritialstatus":"Single","spousename":"","highriskprofile":"No","residentstatus":"Resident","contactmobile":"8987688886","altmobile":"9999999918","contactemailid":"dummy.m@gmail.com","emailverified":false,"caste":"General","religion":"Hindu","keyperson":"No","riskcategory":"Yes","noofdependent":"2","politicalexposed":"No","relationtype":"Brother","constype":"Sole Proprietary","regno":"420420","gstno":"840840","udyamno":"UI420420","tinno":"TIN840840","cinno":"CIN1230","enityname":"TestEntity","keycontactname":"Amitabh Bachan","eastablishdate":"01/01/2001","physicallychallenge":"No","physicallychallengenature":"","ckycnumber":"","customerhinvip":"","proofdisability":"","directoridentificationnum":"","detailsaddress":[{"addresstype":"Permanent","addressline1":"H. No. 544","addressline2":"Street No. 7","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110053","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Current","addressline1":"","addressline2":"Street No. 5","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110054","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm1@aubank.com","officephone":"8767677545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Office","addressline1":"","addressline2":"Street No. 1","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110055","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm1@aubank.com","officephone":"8767655543","residentofficetype":"Flat","residentstatus":"Rented"}]},{"existingcustomer":"No","applicanttype":"Applicant","dob":"03/10/1982","aadhaarno":"554444454555","panno":"GBSTS9854M","voterid":"UP15MMMRESE","anform60":"Pan Card","drivinglicense":"UP1234DE1234","passportno":"AMBE343S","npr":"TNPR","nrega":"TNREGA","panverificationstatus":"Not Verified","title":"Mr","fname":"DummyLeadApp","mname":"","lname":"Sharma","gender":"Male","fathername":"Boney Kappor","mothername":"Sridevi","maritialstatus":"Single","spousename":"","highriskprofile":"No","residentstatus":"Resident","contactmobile":"8987688886","altmobile":"9999999918","contactemailid":"dummy.m@gmail.com","emailverified":false,"caste":"General","religion":"Hindu","keyperson":"No","riskcategory":"Yes","noofdependent":"2","politicalexposed":"No","relationtype":"NA","constype":"Sole Proprietary","regno":"420420","gstno":"840840","udyamno":"UI420420","tinno":"TIN840840","cinno":"CIN1230","enityname":"TestEntity","keycontactname":"Amitabh Bachan","eastablishdate":"01/01/2001","physicallychallenge":"No","physicallychallengenature":"","ckycnumber":"","customerhinvip":"","proofdisability":"","directoridentificationnum":"","detailsaddress":[{"addresstype":"Permanent","addressline1":"H. No. 544","addressline2":"Street No. 7","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110053","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Current","addressline1":"","addressline2":"Street No. 5","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110054","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Office","addressline1":"","addressline2":"Street No. 1","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110055","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656543","residentofficetype":"Flat","residentstatus":"Rented"}],"detailsapplicantdocument":[{"documentname":"Passport","documentid":"AUWheels0005","category":"KYC Documents","subcategory":"Passport","documentexpiry":"03/09/2027","filenumber":"XYZABC12","documentnumber":"M02343M"},{"documentname":"Aadhaar Card","documentid":"AUWheels0003","category":"KYC Documents","subcategory":"Aadhaar Card","documentnumber":"XXXXXXXX1475"},{"documentname":"Driving Licence","documentid":"AUWheels0004","category":"KYC Documents","subcategory":"Driving Licence","documentexpiry":"03/09/2027"}],"detailsfinance":{"employmenttype":"Salaried - Private","assessmentmethod":"Salaried","companybusinessname":"AU Bank","considerincomeeligible":"Yes","customergrade":"Banking","monthlyincome":"100000","monthlyobligation":"2000","otherincomeamt":"5000.00","sector":"Manufacturer","industry":"Fabricated Metal Products","industrysubtype":"Metal Cutlery","occupation":"Manufacturer","finotherIncome":[{"otherincometype":"Agriculture","otherifany":"","monthlyincome":"5000","assessmentmethod":"Assessed"}],"findairybusiness":[{"noofcattle":"200","dailymilksupplyltr":"20","avgsalepriceltr":"20","dailycollectionrs":"400","monthlyreceiptrs":"12000","profitmarginpercentage":"6","monthlynetincome":"120000","anyotherincome":"0","otherexpense":"0","totalnetincome":"0"}],"finfarmercommercial":[{"typeofincome":"Other Agri","incomesource":"Combine Harvestor","unit":"7","annualincomeunit":"600000","proof":"Documented","documenttype":"45","netannualincome":"600000","areaundercropunit":""}],"finagriownorrentland":[{"landType":"own","cropdetails":"Bajra Summer","marketprice":null,"irrigationsource":"well","areaundercrop":121,"sowingmonth":"Jan-Feb","harvestmonth":"April-May","estimatedyield":13.5,"estimatedsalevalue":1633.5,"netrevenue":1633.5},{"landType":"Rent","cropdetails":"Bajra Summer","marketprice":null,"irrigationsource":"well","areaundercrop":121,"sowingmonth":"Jan-Feb","harvestmonth":"April-May","estimatedyield":13.5,"estimatedsalevalue":1633.5,"netrevenue":1633.5}],"findocumentwithoutaudit":[{"annualnetprofit":12055,"monthlynetprofit":1004.5833333333334,"year":"2022-2021","filingdate":"20/12/2022"}],"findocumentwithaudit":[{"companybusinessname":"Salesforce","year":"2022","annualturnover":"123","monthlyturnover":"10.25","annualnetprofit":"1412","monthlynetprofit":"117.666","annualdepreciation":"124","monthlydepreciation":"10.33","annualinterestonloan":"1241","monthlyinterestonloan":"103.41","annualnoncashexpense":"121","monthlynoncashexpense":"10.8","annualtotalincome":"3021","totalmonthlyincome":"251.75"}],"finaddresswithoutdocument":[{"monthlyturnover":"122","annualturnover":"1464","monthlyexpense":"123","annualexpense":"1476","companybusinessname":"Salesforce","monthlynetprofit":"245","annualnetprofit":"2940"}],"finsalary":{"firstmonthsalary":20000,"secondmonthsalary":20000,"thirdmonthsalary":20000,"avgsalary":20000,"companybusinessname":"AU Bank","monthlygrosssalary":"20000","salaryreceivedbank":"20000","monthlynetsalary":"20000","salaryreceivedcash":"5000"}}}],"dealertype":"2103","dealername":"LIFTECH INDIA PVT LTD_ND007926","dealercode":"2103","customertype":"Individual","customerpincode":"110053","customername":"Mukul Kumar","customermobile":"9876345623","campaignname":"Campaign Test","branchcode":"2103"}]}';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        LeadAPIRestResource.postLeadDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testMethodException(){
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'apexrest/v1/LeadAPIRestResource';
        req.httpMethod = 'POST';
        String requestBody = '{"leadRecordList":[{"vehicleusage":"Personal","uptoinstallmentnovpi":null,"typeofreate":"Variable","totalloanamount":450000,"tenure":60,"sourcename":"MTV","sourcechannel":"Digital Partner","schemename":null,"schemecode":null,"scheduletype":"Monthly","roi":9.3,"repaymentstartdate":"05/04/2023","repaymentmode":"NACH without PDC","repaymentbankname":"Axis","repaymentaccountnum":"9000000001","purchasecity":"Delhi","promocode":"testpromo","productcode":"10201","pinCode":null,"ownerId":null,"outletname":"TestOutlet","outletcode":null,"nomineerelationship":"Brother","nomineepercentage":100,"hasnominee":true,"nomineename":"Neel Kamal","nomineedob":"05/05/1990","nomineecontact":"8987876565","moratoriumperiod":"1","loanpurpose":"Purchase of Vehicle","loannature":"Secured","loanId":null,"loanamount":450000,"lccode":"lccode","followuptime":"","followupdate":"15/15/2023","emifrequency":"Monthly","emidate":"04/04/2023","disbursementcategory":"Full","detailsvehicle":{"collateraltype":"new","collateralname":"10108","make":"MARUTI","model":"CIAZ","variant":"ALPHA SMART HYBRID_PETROL","color":"BLACK","fueltype":"PETROL","vehiclecategory":"C","vehicleusage":"Personal","vehicleyearmonth":"2-2023","enginecategory":"BS6","exshowroomprice":1000000,"discount":15000,"netdiscountprice":985000,"insurance":25000,"rtotaxes":"30000","isrtotax":"Yes","rtotaxamount":20000,"accessoriesfunding":"No","accessories":"15000","accessoriesvalue":null,"othercost":"50000","onroadprice":"1040000","finalcost":"1105000","insurancefunding":"Yes","insurancevalue":"20000","isLS":"No","lsamount":"490000","apportionedloanamount":490000,"vehiclenumber":"","enginenumber":"","chasisnumber":"","kilometer":"","hpnfinancename":"","currentowner":"","ownerserialnum":"","registrationcity":"","certifiedvalue":"","valuationamount":"","idvinsurancevalue":"","exitpolicyexp{":"","insuranceexpdate":"","existpolicy_insurercompany":"","exist_policytype":"","made_claim_last_year":"","ncb_percentage":null,"vehiclecost":null,"finalvehiclecost":null,"detailsvaluation":[{"referenceid":"487734424547373","product":"Auto Loan (Used)","collateraltype":"New","valuename_code":"Auto Inspect","otherstate_masterlist":"","coordinateforvaluation":"Ashish","contactperson_mobilenumber":"9999999999","allocationdatetime":"","completiondatetime":"","vehicle_number":"DL9CAG4934","make_model":"HMT_4022","enginenumber":"GDFUFU","chasisnumber":"HCHUC","manufacture_year":"02/2018","registration_date":"02/2018","ownerserial_number":"4","hypothication":"CHOLA","color":"Black","odometer":"20","fuel":"Petrol","vehicle_condition":"Running","valuation_amount":100000,"final_remarks":""}]},"detailsreference":[{"name":"ankit kumar","relation":"Brother","address":"Delhi","mobileno":"8888888800","isactive":"true"}],"detailsappdocument":null,"detailscharge":[{"valuetype":"Percent","chargename":"Stamp duty","actualrate":0.03,"chargeamount":1363.65}],"detailsapplicant":[{"existingcustomer":"No","applicanttype":"Co-Applicant","dob":"03/10/1983","aadhaarno":"554444454345","panno":"GBSTS9854M","voterid":"UP15MMMRESE","anform60":"Pan Card","drivinglicense":"UP1234DE1234","passportno":"AMBE233S","npr":"TNPR","nrega":"TNREGA","panverificationstatus":"Not Verified","title":"Mr","fname":"DummyLeadCoApp","mname":"","lname":"Sharma","gender":"Male","fathername":"Boney Kappor","mothername":"Sridevi","maritialstatus":"Single","spousename":"","highriskprofile":"No","residentstatus":"Resident","contactmobile":"8987688886","altmobile":"9999999918","contactemailid":"dummy.m@gmail.com","emailverified":false,"caste":"General","religion":"Hindu","keyperson":"No","riskcategory":"Yes","noofdependent":"2","politicalexposed":"No","relationtype":"Brother","constype":"Sole Proprietary","regno":"420420","gstno":"840840","udyamno":"UI420420","tinno":"TIN840840","cinno":"CIN1230","enityname":"TestEntity","keycontactname":"Amitabh Bachan","eastablishdate":"01/01/2001","physicallychallenge":"No","physicallychallengenature":"","ckycnumber":"","customerhinvip":"","proofdisability":"","directoridentificationnum":"","detailsaddress":[{"addresstype":"Permanent","addressline1":"H. No. 544","addressline2":"Street No. 7","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110053","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Current","addressline1":"","addressline2":"Street No. 5","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110054","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm1@aubank.com","officephone":"8767677545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Office","addressline1":"","addressline2":"Street No. 1","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110055","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm1@aubank.com","officephone":"8767655543","residentofficetype":"Flat","residentstatus":"Rented"}]},{"existingcustomer":"No","applicanttype":"Applicant","dob":"03/10/1982","aadhaarno":"554444454555","panno":"GBSTS9854M","voterid":"UP15MMMRESE","anform60":"Pan Card","drivinglicense":"UP1234DE1234","passportno":"AMBE343S","npr":"TNPR","nrega":"TNREGA","panverificationstatus":"Not Verified","title":"Mr","fname":"DummyLeadApp","mname":"","lname":"Sharma","gender":"Male","fathername":"Boney Kappor","mothername":"Sridevi","maritialstatus":"Single","spousename":"","highriskprofile":"No","residentstatus":"Resident","contactmobile":"8987688886","altmobile":"9999999918","contactemailid":"dummy.m@gmail.com","emailverified":false,"caste":"General","religion":"Hindu","keyperson":"No","riskcategory":"Yes","noofdependent":"2","politicalexposed":"No","relationtype":"NA","constype":"Sole Proprietary","regno":"420420","gstno":"840840","udyamno":"UI420420","tinno":"TIN840840","cinno":"CIN1230","enityname":"TestEntity","keycontactname":"Amitabh Bachan","eastablishdate":"01/01/2001","physicallychallenge":"No","physicallychallengenature":"","ckycnumber":"","customerhinvip":"","proofdisability":"","directoridentificationnum":"","detailsaddress":[{"addresstype":"Permanent","addressline1":"H. No. 544","addressline2":"Street No. 7","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110053","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Current","addressline1":"","addressline2":"Street No. 5","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110054","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656545","residentofficetype":"Flat","residentstatus":"Owned"},{"addresstype":"Office","addressline1":"","addressline2":"Street No. 1","addressline3":"","areaname":"Delhi","areaytype":"Urban","city":"Delhi","state":"Delhi","taluka":"Delhi","pincode":"110055","district":"Delhi","stability":"3","landmark":"AU Bank","addresstakenfrom":"Aadhaar Card","officeemail":"mm@aubank.com","officephone":"8767656543","residentofficetype":"Flat","residentstatus":"Rented"}],"detailsapplicantdocument":[{"documentname":"Passport","documentid":"AUWheels0005","category":"KYC Documents","subcategory":"Passport","documentexpiry":"03/09/2027","filenumber":"XYZABC12","documentnumber":"M02343M"},{"documentname":"Aadhaar Card","documentid":"AUWheels0003","category":"KYC Documents","subcategory":"Aadhaar Card","documentnumber":"XXXXXXXX1475"},{"documentname":"Driving Licence","documentid":"AUWheels0004","category":"KYC Documents","subcategory":"Driving Licence","documentexpiry":"03/09/2027"}],"detailsfinance":{"employmenttype":"Salaried - Private","assessmentmethod":"Salaried","companybusinessname":"AU Bank","considerincomeeligible":"Yes","customergrade":"Banking","monthlyincome":"100000","monthlyobligation":"2000","otherincomeamt":"5000.00","sector":"Manufacturer","industry":"Fabricated Metal Products","industrysubtype":"Metal Cutlery","occupation":"Manufacturer","finotherIncome":[{"otherincometype":"Agriculture","otherifany":"","monthlyincome":"5000","assessmentmethod":"Assessed"}],"findairybusiness":[{"noofcattle":"200","dailymilksupplyltr":"20","avgsalepriceltr":"20","dailycollectionrs":"400","monthlyreceiptrs":"12000","profitmarginpercentage":"6","monthlynetincome":"120000","anyotherincome":"0","otherexpense":"0","totalnetincome":"0"}],"finfarmercommercial":[{"typeofincome":"Other Agri","incomesource":"Combine Harvestor","unit":"7","annualincomeunit":"600000","proof":"Documented","documenttype":"45","netannualincome":"600000","areaundercropunit":""}],"finagriownorrentland":[{"landType":"own","cropdetails":"Bajra Summer","marketprice":null,"irrigationsource":"well","areaundercrop":121,"sowingmonth":"Jan-Feb","harvestmonth":"April-May","estimatedyield":13.5,"estimatedsalevalue":1633.5,"netrevenue":1633.5},{"landType":"Rent","cropdetails":"Bajra Summer","marketprice":null,"irrigationsource":"well","areaundercrop":121,"sowingmonth":"Jan-Feb","harvestmonth":"April-May","estimatedyield":13.5,"estimatedsalevalue":1633.5,"netrevenue":1633.5}],"findocumentwithoutaudit":[{"annualnetprofit":12055,"monthlynetprofit":1004.5833333333334,"year":"2022-2021","filingdate":"20/12/2022"}],"findocumentwithaudit":[{"companybusinessname":"Salesforce","year":"2022","annualturnover":"123","monthlyturnover":"10.25","annualnetprofit":"1412","monthlynetprofit":"117.666","annualdepreciation":"124","monthlydepreciation":"10.33","annualinterestonloan":"1241","monthlyinterestonloan":"103.41","annualnoncashexpense":"121","monthlynoncashexpense":"10.8","annualtotalincome":"3021","totalmonthlyincome":"251.75"}],"finaddresswithoutdocument":[{"monthlyturnover":"122","annualturnover":"1464","monthlyexpense":"123","annualexpense":"1476","companybusinessname":"Salesforce","monthlynetprofit":"245","annualnetprofit":"2940"}],"finsalary":{"firstmonthsalary":20000,"secondmonthsalary":20000,"thirdmonthsalary":20000,"avgsalary":20000,"companybusinessname":"AU Bank","monthlygrosssalary":"20000","salaryreceivedbank":"20000","monthlynetsalary":"20000","salaryreceivedcash":"5000"}}}],"dealertype":"2103","dealername":"LIFTECH INDIA PVT LTD_ND007926","dealercode":"2103","customertype":"Individual","customerpincode":"110053","customername":"Mukul Kumar","customermobile":"9876345623","campaignname":"Campaign Test","branchcode":"2103"}]}';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        LeadAPIRestResource.postLeadDetails();
        Test.stopTest();
    }
}