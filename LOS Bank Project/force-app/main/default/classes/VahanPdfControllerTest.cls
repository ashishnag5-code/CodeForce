@isTest
public class VahanPdfControllerTest {
    @testSetup static void setup(){
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
        system.debug('@@'+loanAppl.Id);
        Integration_Master__c vahanIntMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Vahaan API',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/Karza/VahanPaid',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Integration_Checklist__c ic = new Integration_Checklist__c();
        ic.Integration_Master__c = vahanIntMaster.Id;
        ic.Loan_Application__c = loanAppl.Id;
        ic.Response__c = '{"result":{"metadata":{"amountBeforePayment":650,"searchBy":"reg_no","amountAfterPayment":650,"user":"278747"},"pdf":"https://download.karza.in","nocCcDetails":{"officeCode":"","details":""},"ownerDetails":{"fathersName":"RAMESH CHAND","presentAddress":"10674 PRATAP NAGAR 9 PRATAP NAGAR,SADAR BAZAR PRATAP NAGAR METRO,91, STATION-110007","ownersName":"BACHAN SINGH","permanentAddress":"10674 PRATAP NAGAR 9 PRATAP NAGAR,SADAR BAZAR PRATAP NAGAR METRO,91, STATION-110007"},"vehicleDetails":{"bodyType":"SALOON","horsePower":"","color":"","registrationDt":"16-Mar-2013","fuel":"","purchaseDt":"","noOfCylinders":"","fitnessUpto":"15-Mar-2028","manufacturer":"MARUTI SUZUKI INDIA LTD","cubicCap":"","seatingCap":"","vehicleClass":"Motor Car","makerModel":"WAGON R VXI M BS4","panGirNo":"","ownerSrNo":"2","saleAmount":"","engineNo":"K10BN4486796","gvw":"","standingCap":"","wheelbase":"","registrationNo":"DL9CAG4933","chassisNo":"MA3EWDE1S00522075","dealer":"MAGIC_AUTO","wtUnladen":"","blackListDetails":""},"financersDetails":{"address":"-","financersName":"AU SMALL FINANCE BANK LIMITED","withEffectFrom":""},"insuranceDetails":{"company":"Tata AIG General Insurance Co. Ltd.","validity":"upto 31-Jul-2023","type":""},"challanDetails":[{"totalAmount":1500,"violatorName":"RAMRATAN SANGWA","challanNo":"RJ137716230507091958","dlRcNumber":"RJ19CL1050","offenceDetails":[{"penalty":1000,"offenceName":"Driver or passenger without seat belt 194B(1) बिना सीट बेल्ट के चालक या यात्री (194B(1)"},{"penalty":500,"offenceName":"Disobedience of any direction or obstruction of any function by a driver 179(1) किसी चालक द्वारा किसी भी दिशा या किसी भी कार्य की रुकावट की अवज्ञा 179(1)"}],"paymentSource":null,"paymentDateAndTime":null,"state":"Rajasthan","challanDate":"2023-05-07 09:19:58","transactionId":null,"status":"PENDING"}]},"status-code":"101","request_id":"8e60b0f5-cae7-4fee-a361-3ebe74565a65"}';
        ic.Status__c = 'Completed';
        insert ic;
    }
    
    @isTest
    public static void getLADetailsTest(){
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        system.debug('@@'+loan.Id);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(loan);
        ApexPages.currentPage().getParameters().put('loanid', loan.Id);
        VahanPdfController form = new VahanPdfController(sc);
        form.pageLoadAction();
        Test.stopTest();
    }

}