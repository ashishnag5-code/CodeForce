@isTest
private class FieldInvestigationQuestionaireTest {
    static testMethod void testQuestionaire() {
        Test.startTest();
        
        Profile prof = [select Id,Name from profile where name ='Field Investigator'];
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = prof.id,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        system.runAs(usr){
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData1 = new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData2 = new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData3= new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData4 = new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData5 = new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            
            FieldInvestigationQuestionaireController.QuestionaireWrapperListData objQuesWrapData6= new FieldInvestigationQuestionaireController.QuestionaireWrapperListData();
            
            objQuesWrapData1=FieldInvestigationQuestionaireController.Questionaire(GlobalConstants.AUTOLOANNEW, GlobalConstants.APPLICANT , true,false);
            objQuesWrapData2=FieldInvestigationQuestionaireController.Questionaire( GlobalConstants.AUTOLOANUSED ,GlobalConstants.COAPPLICANT , true,false);
            
            objQuesWrapData3=FieldInvestigationQuestionaireController.Questionaire( GlobalConstants.AUTOLOANCASH ,GlobalConstants.GUARANTOR, true,false);
            
            objQuesWrapData4=FieldInvestigationQuestionaireController.Questionaire(GlobalConstants.TWOWHEELERNEW, GlobalConstants.APPLICANT , true,false);
            objQuesWrapData5=FieldInvestigationQuestionaireController.Questionaire( GlobalConstants.TWOWHEELERNEW ,GlobalConstants.COAPPLICANT , true,false);
            
            objQuesWrapData6=FieldInvestigationQuestionaireController.Questionaire( GlobalConstants.TWOWHEELERNEW ,GlobalConstants.GUARANTOR, true,false);
            System.assertEquals(objQuesWrapData1 != null,true,'AssertMsg');
            System.assertEquals(objQuesWrapData2 != null,true,'AssertMsg');
            System.assertEquals(objQuesWrapData3 != null,true,'AssertMsg');
            System.assertEquals(objQuesWrapData4 != null,true,'AssertMsg');
            System.assertEquals(objQuesWrapData5 != null,true,'AssertMsg');
            System.assertEquals(objQuesWrapData6 != null,true,'AssertMsg');
            
        }
        Test.stopTest();
        
    }
}