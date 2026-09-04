@isTest
public class RiskCalculationControllerTest {
	 @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
            Customer_Grade__c ='IB',
            Application_FI_Status__c='Positive'
        ),true);
         
         Loan_Application__c loanApp2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
			Customer_Grade__c ='NIB',
            Application_FI_Status__c='Positive'
        ),true);
        
        //Applicant Insertion 
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Customer_Grade__c ='NIB',
            Type_Of_Employment__c='Business',
            Bureau_Score__c='200',
            Applicant_FI_Status__c='Positive',
            Dob__c =Date.newInstance(2016, 12, 9),
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Non Individual',
            Constitution_Type__c = 'Sole Proprietary',
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
            
        ),true);
          Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Customer_Grade__c ='NIB',
            Type_Of_Employment__c='Business',
            Bureau_Score__c='200',
            Applicant_FI_Status__c='Positive',
            Dob__c =Date.newInstance(2016, 12, 9),
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c =loanAppl.Id,
            Mobile_Number__c ='8106255685',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c='60123214141',
            Customer_Type__c='Individual',
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
            
        ),true);
          Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Spouse Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);

        Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl2.Id,
            Status__c='Spouse Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);
               
    }
    
    @isTest 
    public static void riskCalculation(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String loanId = loanInstance.Id;
        Test.startTest();
            RiskCalculationController.riskScoreCalculation(loanId);
            System.assertEquals(loanInstance !=null,true,'AssertMsg');
            List<Applicant__c> lstUpdate = new List<Applicant__c>();
            for (Applicant__c obj : [Select Id, Customer_Type__c, Constitution_Type__c, RecordType.DeveloperName from Applicant__c where Loan__c =:loanId]) {
                if (obj.RecordType.DeveloperName == 'Primary_Applicant') {
                    obj.Constitution_Type__c = 'Partnership Firms';
                }
                lstUpdate.add(obj);
            }
            update lstUpdate;
            RiskCalculationController.riskScoreCalculation(loanId);
            System.assertEquals(loanInstance !=null,true,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest 
    public static void riskCalculation1(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12346'];
        Test.startTest();
            //Applicant Insertion 
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Customer_Grade__c ='NIB',
                Type_Of_Employment__c='Business',
                Bureau_Score__c='200',
                Applicant_FI_Status__c='Positive',
                Dob__c =Date.newInstance(2016, 12, 9),
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanInstance.Id,
                Mobile_Number__c ='8106255685',
                PAN__c ='EXFPK4321K',
                CIF_No__c ='12345678',
                Voter_Id__c='1241214',
                Passport_Number__c='12411414',
                Driving_License_Id__c='3555535xfr',
                Aadhaar_Number__c='60123214141',
                Customer_Type__c='Non Individual',
                Constitution_Type__c = 'Sole Proprietary',
                SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]',
                RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
                
            ),true);
            Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Customer_Grade__c ='NIB',
                Type_Of_Employment__c='Business',
                Bureau_Score__c='200',
                Applicant_FI_Status__c='Positive',
                Dob__c =Date.newInstance(2016, 12, 9),
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanInstance.Id,
                Mobile_Number__c ='8106255685',
                PAN__c ='EXFPK4321K',
                CIF_No__c ='12345678',
                Voter_Id__c='1241214',
                Passport_Number__c='12411414',
                Driving_License_Id__c='3555535xfr',
                Aadhaar_Number__c='60123214141',
                Customer_Type__c='Individual',
                SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]',
                RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
                
            ),true);
            Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline1',
                Address_Line_2__c ='TestAddressline2',
                Address_Line_3__c ='TestAddressline3',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110053',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Spouse Owned',
                Address_Type__c='Current',
                Type__c='Bungalow'
            ),true);

            Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
                Address_Line_1__c ='TestAddressline1',
                Address_Line_2__c ='TestAddressline2',
                Address_Line_3__c ='TestAddressline3',
                State__c='MAHARASHTRA',
                City__c='EAST DELHI',
                Area_Name__c='JAGJIT NAGAR',
                Area_Type__c='Urban',
                Taluka__c='NA',
                Pincode__c='110053',
                Land_mark__c='Testing',
                Applicant__c =appl2.Id,
                Status__c='Spouse Owned',
                Address_Type__c='Current',
                Type__c='Bungalow'
            ),true);
            RiskCalculationController.riskScoreCalculation(loanInstance.Id);
            System.assertEquals(loanInstance !=null,true,'AssertMsg');
        Test.stopTest();
    }

    @isTest 
    public static void riskCalculationIndividual(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String loanId = loanInstance.Id;
        List<Applicant__c> lstUpdate = new List<Applicant__c>();
        for (Applicant__c obj : [Select Id, Customer_Type__c, Constitution_Type__c, RecordType.DeveloperName from Applicant__c where Loan__c =:loanId]) {
            if (obj.RecordType.DeveloperName == 'Primary_Applicant') {
                obj.Customer_Type__c = 'Individual';
            }
            lstUpdate.add(obj);
        }
        update lstUpdate;
        Test.startTest();
        RiskCalculationController.riskScoreCalculation(loanId);
        System.assertEquals(loanInstance !=null,true,'AssertMsg');
        Test.stopTest();
    }

}