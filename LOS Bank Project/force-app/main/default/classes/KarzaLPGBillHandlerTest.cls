@isTest
private class KarzaLPGBillHandlerTest {
    @isTest
    static void testKarzaLPGBillResponseWrapper_Success() {
        // Create a mock response for a successful request
      //  KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
                      //  response.setBody('{"status-code": 101,"request_id": "73cdbde2-80f7-11e7-8f0c-e7e769f70bd1","result": {"status": "Active","ApproximateSubsidyAvailed": "0.0","SubsidizedRefillConsumed": "10","pin": "","ConsumerEmail": "Not Available","DistributorCode": "186834","BankName": "Not Applicable","IFSCCode": "Not Applicable","city/town": "","AadhaarNo": "**** **** 7460","ConsumerContact": "******9349","DistributorAddress": "SHOP NO 1 MANUSMRITI BLDG GR FLOOR TUKARAM NAGAR, 421201","ConsumerName": "MRS SUSHAMA M SHIRHATTI","ConsumerNo": "50431060","DistributorName": "SHIVSHAKTI BHARATGAS AGENCY","BankAccountNo": "Not Applicable","GivenUpSubsidy": "No","ConsumerAddress": "PLNO 125PUSHPA AJANTA NR NANDIVALI TELEPHONE EX THANA MAHARASHTRA Maharas 421201","LastBookingDate": "24-Feb-2017","TotalRefillConsumed": ""}}');
         KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        response.status_code = '101';
        response.request_id = '73cdbde2-80f7-11e7-8f0c-e7e769f70bd1';
        response.result = new KarzaLPGBillHandler.KarzaLPGBillResult();
        response.result.status = 'Active';
        response.result.ApproximateSubsidyAvailed = '0.0';
        response.result.SubsidizedRefillConsumed = '10';
        response.result.pin = '';
        response.result.ConsumerEmail = 'Not Applicable';
        response.result.DistributorCode = '186834';
        response.result.BankName = 'Not Applicable';
        response.result.IFSCCode = 'Not Applicable';
        response.result.AadhaarNo = '**** **** 7460';
        response.result.ConsumerContact = '******9349';
        response.result.DistributorAddress = 'SHOP NO 1 MANUSMRITI BLDG GR FLOOR TUKARAM NAGAR, 421201';
        response.result.ConsumerName = 'MRS SUSHAMA M SHIRHATTI';
        response.result.ConsumerNo = '50431060';
        response.result.DistributorName = 'SHIVSHAKTI BHARATGAS AGENCY';
        response.result.BankAccountNo = 'Not Applicable';
        response.result.GivenUpSubsidy = 'No';
        response.result.ConsumerAddress = 'PLNO 125PUSHPA AJANTA NR NANDIVALI TELEPHONE EX THANA MAHARASHTRA Maharas 421201';
        response.result.LastBookingDate = '24-Feb-2017';
        response.result.TotalRefillConsumed = '';
        
        // Verify the response properties
        System.assertEquals('101', response.status_code, 'Incorrect status code');
        System.assertEquals('73cdbde2-80f7-11e7-8f0c-e7e769f70bd1', response.request_id, 'Incorrect request ID');
        //System.assertEquals('Success', response.result.status, 'Incorrect status');
        
        System.assertEquals('Active', response.result.status);
        System.assertEquals('0.0', response.result.ApproximateSubsidyAvailed);
        System.assertEquals('10', response.result.SubsidizedRefillConsumed);
        System.assertEquals('', response.result.pin);
        System.assertEquals('Not Applicable', response.result.ConsumerEmail);
        System.assertEquals('186834', response.result.DistributorCode);
        System.assertEquals('Not Applicable', response.result.BankName);
        System.assertEquals('Not Applicable', response.result.IFSCCode);
        //System.assertEquals('', response.result.city/town);
        System.assertEquals('**** **** 7460', response.result.AadhaarNo);
        System.assertEquals('******9349', response.result.ConsumerContact);
        System.assertEquals('SHOP NO 1 MANUSMRITI BLDG GR FLOOR TUKARAM NAGAR, 421201', response.result.DistributorAddress);
        System.assertEquals('MRS SUSHAMA M SHIRHATTI', response.result.ConsumerName);
        System.assertEquals('50431060', response.result.ConsumerNo);
        System.assertEquals('SHIVSHAKTI BHARATGAS AGENCY', response.result.DistributorName);
        System.assertEquals('Not Applicable', response.result.BankAccountNo);
        System.assertEquals('No', response.result.GivenUpSubsidy);
        System.assertEquals('PLNO 125PUSHPA AJANTA NR NANDIVALI TELEPHONE EX THANA MAHARASHTRA Maharas 421201', response.result.ConsumerAddress);
        System.assertEquals('24-Feb-2017', response.result.LastBookingDate);
        System.assertEquals('', response.result.TotalRefillConsumed);
        
    }
    
    @isTest
    static void testKarzaLPGBillResponseWrapper_Failure() {
        // Create a mock response for a failed request
        KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        response.status_code = '101';
        response.request_id = '73cdbde2-80f7-11e7-8f0c-e7e769f70bd1';
        response.result = null;
        
        // Verify the response properties
        System.assertEquals('101', response.status_code, 'Incorrect status code');
        System.assertEquals('73cdbde2-80f7-11e7-8f0c-e7e769f70bd1', response.request_id, 'Incorrect request ID');
        System.assertEquals(null, response.result, 'Result should be null for a failed request');
    }
    /*
    @isTest
    static void testKarzaLPGBillResponseWrapper_NullProperties() {
        // Create a mock response with null property values
        KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        response.status_code = '200';
        response.request_id = 'REQ123456';
        response.result = new KarzaLPGBillHandler.KarzaLPGBillResult();
        response.result.status = null;
        response.result.ApproximateSubsidyAvailed = null;
        response.result.SubsidizedRefillConsumed = null;
        // Set other properties...
        
        // Verify the response properties
        System.assertEquals('200', response.status_code, 'Incorrect status code');
        System.assertEquals('REQ123456', response.request_id, 'Incorrect request ID');
        System.assertNull(response.result.status, 'Status should be null');
        System.assertNull(response.result.ApproximateSubsidyAvailed, 'ApproximateSubsidyAvailed should be null');
        System.assertNull(response.result.SubsidizedRefillConsumed, 'SubsidizedRefillConsumed should be null');
        // Verify other properties...
    }*/
}