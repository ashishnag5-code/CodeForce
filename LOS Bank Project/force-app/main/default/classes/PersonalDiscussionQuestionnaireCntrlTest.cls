@isTest
public class PersonalDiscussionQuestionnaireCntrlTest {
	@testSetup
    static void setup(){
        Loan_Application__c loan = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                RC_Limit_On_Hold__c=true,
                Stage__c = 'DDE',
                Final_Exposure__c = 10,
            	Customer_Grade__c='Contractor',
            	Product__c='10501',
                RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSobjectType(), GlobalConstants.TWOWHEELER ),
                Sanction_Status__c = 'Issued'
            ), true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loan.Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual'
                
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
                Pincode__c='110051',
                Land_mark__c='Testing',
                Applicant__c =appl.Id,
                Status__c='Owned',
                Address_Type__c='Permanent',
                Type__c='Bungalow',
                Fi_Required__c = false
            ),true);
        
        Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                Name = appl.Customer_Name__c,
                Loan_Application__c =loan.Id,
                Address_lookup__c=addInstance.id,
                Applicant__c=appl.Id,
                FI_Status__c ='Negative',
                Applicant_Type__c='Applicant',
              	Address_Negative_Reason__c = 'Test1 Negative; Test2 Negative')),true);
        
        String file = 'test';
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = EncodingUtil.base64Decode(file);
        cv2.Title = 'Title';
        cv2.Document_Type__c = 'Personal Discussion';
        cv2.PathOnClient = 'Title.jpeg';
        insert cv2;
    }
    @isTest
    static void getIsUnderWriter(){
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];
        Id contDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        
        Loan_Application__c loan = [SELECT Id, Name from Loan_Application__c LIMIT 1];
        Field_Investigation__c fieldInv = [SELECT Id, Name from Field_Investigation__c LIMIT 1];
        Test.startTest();
        PersonalDiscussionQuestionnaireCntrl.getLatestValues(loan.Id, '');
        PersonalDiscussionQuestionnaireCntrl.displayQuestionnaire(loan.Id);
        PersonalDiscussionQuestionnaireCntrl.displayQuestionnaire(fieldInv.Id);
        PersonalDiscussionQuestionnaireCntrl.insertFileVersion('Test Version Data', loan.Id);
        //PersonalDiscussionQuestionnaireCntrl.getApplicantsAndAssets(loan.Id, new String[]{'Age__c', 'Aadhar_Number__c'}, new String[]{'Accessories__c', 'Accessories_Funding__c'});
        Test.stopTest();
    }
}