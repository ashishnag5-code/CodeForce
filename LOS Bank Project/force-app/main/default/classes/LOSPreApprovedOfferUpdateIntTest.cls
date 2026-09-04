/*****
 * Class Name: LOSPreApprovedOfferUpdateIntTest
 * Description: Test Class for Pre Approved Offer Avail
 * Test Class Name: LOSPreApprovedOfferUpdateInt
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-14-2023          -   Mohit M.            -   SFAU-5722 - Remove Database.update and throw error message in case of any error
 */
@isTest
public with sharing class LOSPreApprovedOfferUpdateIntTest {
 @TestSetup
    public static void makeData(){
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'PreApprovedOfferUpdate',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/SFDCKarzaService/NameMatch',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Product__c='10201'
        ),true); 
         Pre_Approved_Offer__c preApprovedOffer = (Pre_Approved_Offer__c)TestFactory.createSObject(new Pre_Approved_Offer__c(
            Loan_Application__c  = loanAppl.id,
            Offer_Id__c='10201',
             OfferIsActive__c=true
        ),true); 
        
        
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Naruto',
            Loan__c = loanAppl.Id,
            Aadhaar_Name__c='Naruto',
            CBS_Name__c='Naruto',
            CIF_No__c='12332',
            Aadhaar_Number__c='234234'
        ),true); 
        
        
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat'
        ),true);
    }
    @isTest
    public static void testPNGControllerMethod8(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LOSPreApprovedOfferMock.LOSPreApprovedOfferUpdateResponse());  
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
         Pre_Approved_Offer__c offer = [SELECT Id,Loan_Application__c,Offer_Id__c,OfferIsActive__c,Is_Selected__c, FirstOfferAmount__c, MaxLoanTenureinMonths__c, RateofInterest__c FROM Pre_Approved_Offer__c LIMIT 1];
        LOSPreApprovedOfferUpdateIntHandler inthandler=new LOSPreApprovedOfferUpdateIntHandler();
        inthandler.generateJSONResponse(new List<Applicant__c>{applicant});
        LOSPreApprovedOfferUpdateInt.callPreApprovedUpdateOfferInt(offer,applicant.id);
        Test.stopTest();

    }

    @isTest
    public static void testPNGControllerMethodException(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LOSPreApprovedOfferMock.LOSPreApprovedOfferUpdateResponse());  
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
         Pre_Approved_Offer__c offer = [SELECT Id,Loan_Application__c,Offer_Id__c,OfferIsActive__c,Is_Selected__c, FirstOfferAmount__c FROM Pre_Approved_Offer__c LIMIT 1];
        LOSPreApprovedOfferUpdateIntHandler inthandler=new LOSPreApprovedOfferUpdateIntHandler();
        inthandler.generateJSONResponse(new List<Applicant__c>{applicant});
        LOSPreApprovedOfferUpdateInt.callPreApprovedUpdateOfferInt(offer,applicant.id);
        Test.stopTest();

    }
}