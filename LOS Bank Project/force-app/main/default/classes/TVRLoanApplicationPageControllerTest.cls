@isTest
private with sharing class TVRLoanApplicationPageControllerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
		Group grp = (Group )TestFactory.createSObject(new Group(Name ='Group1',Type='Queue'),true); 

        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
        	Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
                           	Name ='110053',Area_Name__c ='JAGJIT NAGAR',Area_Type__c ='Urban',City__c ='EAST DELHI',
            				State__c ='MAHARASHTRA',Taluka__c ='NA'),true);
        	Account accInstance = (Account)TestFactory.createSObject(new Account (
            				Name ='TestAccount',Pincode__c = lcMaster.Id),true);
       		Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                            Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,Loan_Amount__c = 1000,Product__c='10201',
            				Branch_Master__c =accInstance.Id),true);
       		Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanAppl.Id,
            				Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);
       		Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
                            Address_Line_1__c ='TestAddressline1',Address_Line_2__c ='TestAddressline2',
            				Address_Line_3__c ='TestAddressline3',State__c='MAHARASHTRA',City__c='EAST DELHI',
            				Area_Name__c='JAGJIT NAGAR',Area_Type__c='Urban',Taluka__c='NA',Pincode__c='110054',
            				Land_mark__c='Testing',Applicant__c =appl.Id,Status__c='Owned',Address_Type__c='Permanent',
            				Type__c='Bungalow',Stability__c='2',District__c='Meerut'),true);
       		Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
                            Address_Line_1__c ='TestAddressline11',Address_Line_2__c ='TestAddressline22',
                            Address_Line_3__c ='TestAddressline34',State__c='MAHARASHTRA',City__c='EAST DELHI',
                           	Area_Name__c='JAGJIT NAGAR',Area_Type__c='Urban',Taluka__c='NA',Pincode__c='110053',
                            Land_mark__c='Testing',Applicant__c =appl.Id,Status__c='Owned',Address_Type__c='Current',
							Type__c='Bungalow',Stability__c='2',District__c='Meerut'),true);
       		Address__c addInstanc2 = (Address__c)TestFactory.createSObject(new Address__c(
                            Address_Line_1__c ='TestAddressline112',Address_Line_2__c ='TestAddressline222',
                            Address_Line_3__c ='TestAddressline332',State__c='MAHARASHTRA',City__c='EAST DELHI',
                            Area_Name__c='JAGJIT NAGAR',Area_Type__c='Urban',Taluka__c='NA',Pincode__c='110053',
                            Land_mark__c='Testing',Applicant__c =appl.Id,Status__c='Owned',Address_Type__c='Office',
                            Type__c='Bungalow',Stability__c='2',District__c='Meerut'),true);
      		Address__c  addInstanc3 = (Address__c)TestFactory.createSObject(new Address__c(
             				Address_Line_1__c ='TestAddressline112',Address_Line_2__c ='TestAddressline222',
                            Address_Line_3__c ='TestAddressline333',State__c='MAHARASHTRA',City__c='EAST DELHI',
                            Area_Name__c='JAGJIT NAGAR',Area_Type__c='Urban',Taluka__c='NA',Pincode__c='110054',
                            Land_mark__c='Testing',Applicant__c =appl.Id,Status__c='Owned',Address_Type__c='Touch Point',
                            Type__c='Bungalow',Stability__c='2',District__c='Meerut'),true);
       	 	Id recId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
			Id makeId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
			Id modelId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
			Id variantId = Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Variant').getRecordTypeId();

			MMV_Master__c objMake=(MMV_Master__c)TestFactory.createSObject((new MMV_Master__c(
                			recordTypeId=makeId,Name='Hundai',Active_in_2W_Vehicle__c=true,Active_in_4W_Vehicle__c	=false,
                			Active_in_Used_Vehicle__c=false)),true);   
			MMV_Master__c objModel=(MMV_Master__c)TestFactory.createSObject((new MMV_Master__c(
                			recordTypeId=modelId,Name='Venue',Active_in_2W_Vehicle__c=true,Active_in_4W_Vehicle__c	=false,
                			Active_in_Used_Vehicle__c=false)),true);   
			MMV_Master__c objMMV=(MMV_Master__c)TestFactory.createSObject((new MMV_Master__c(
                			Make__c=objMake.Id,Model__c=objModel.Id,Make_Model_Variant__c='HYUNDAI_VENUE_VENUE E',
                			Active_in_2W_Vehicle__c=true,Active_in_4W_Vehicle__c	=false,Active_in_Used_Vehicle__c=false)),true);   
			Collateral__c objCollateral=(Collateral__c)TestFactory.createSObject(new Collateral__c(
                			MMV_Master__c=objMMV.Id,loan__c=loanAppl.Id,Vehicle_Usage__c='Personal'),true);   
			Applicant_Financials_Details__c applFinancialInsta=(Applicant_Financials_Details__c)TestFactory.createSObject((new Applicant_Financials_Details__c(
                			Type_Of_Employment__c='Salaried - Private',Monthly_Obligation__c=1000,RecordTypeId=recId,
                			Company_Name__c='AU',Method_Of_Assesment__c='Salaried', Applicant__c=appl.Id,
                			Occupation__c='developer',Monthly_Income__c=10290)),true);
            User usr = (User)TestFactory.createSObject(new User(
                			firstName = 'test1',lastName = 'test2',profileId = prof.id,Branch_Code__c  = '1111', 
                			username = 'test'+UserInfo.getOrganizationId()+'@test.com',email = 'test@test.com',
            				Product_Accessible__c = 'All New'),true);
			TVR__c objTVR = (TVR__c)TestFactory.createSObject((new TVR__c(
            				Name_Of_Employee__c = 'Credit user',Mobile_Number__c ='8787878767',Loan_Application__c=loanAppl.Id,
            				Remark__c='Test',TVR_Date__c =date.today(),TVR_Done_With__c='Applicant',
                			Employee_ID__c='credit.user')),true);
        }
    }
    
    @isTest static void fetchTVRTest() {
        Loan_Application__c loanApplication =[SELECT id FROM Loan_Application__c Limit 1];
        Test.startTest();
        TVRLoanApplicationPageController.ReturnWrapper result=TVRLoanApplicationPageController.fetchTVR(loanApplication.Id);
        System.assertEquals(result.lstTvr.size()!= 0,true,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void deleteTVRTest() {        
        Test.startTest();
        TVR__c objTVR =[SELECT id  FROM TVR__c limit 1];
        TVRLoanApplicationPageController.resultWrapper result=TVRLoanApplicationPageController.deleteTVR(objTVR.Id);
        System.assertEquals(result.isSuccess,true,'AssertMsg');      
        Test.stopTest();
    }
}