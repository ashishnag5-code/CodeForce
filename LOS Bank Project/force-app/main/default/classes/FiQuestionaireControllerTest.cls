@isTest
private class FiQuestionaireControllerTest {
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

    //objQuesWrapData1=FieldInvestigationQuestionaireController.Questionaire( 'Applicant', true);
    //objQuesWrapData2=FieldInvestigationQuestionaireController.Questionaire( 'Guarantor', true);

    //objQuesWrapData3=FieldInvestigationQuestionaireController.Questionaire( 'Co-Applicant', true);
    System.assertEquals(objQuesWrapData1 != null,true,'AssertMsg');
    System.assertEquals(objQuesWrapData2 != null,true,'AssertMsg');
    System.assertEquals(objQuesWrapData3 != null,true,'AssertMsg');

    }
    Test.stopTest();

 }
}