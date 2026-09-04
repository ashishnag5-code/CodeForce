@isTest
public class CibilTest {
    testmethod static void main(){
        String json=		''+
		'	{"RequestId": "HYP871237182",'+
		'	"OriginatingChannel": "HYP",'+
		'	"RequestInfo": {'+
		'		"ExecutionMode": "NewWithContext",'+
		'		"SolutionSetId": "50",'+
		'		"SolutionSetVersion": "1"'+
		'	},'+
		'	"ApplicationData": {'+
		'		"Purpose": "10",'+
		'		"Amount": "100",'+
		'		"ScoreType": "08",'+
		'		"GSTStateCode": "08",'+
		'		"CibilBureauFlag": "False",'+
		'		"DSTuNtcFlag": "True",'+
		'		"IDVerificationFlag": "False",'+
		'		"MFIBureauFlag": "True",'+
		'		"NTCProductType": "PL",'+
		'		"ConsumerConsentForUIDAIAuthentication": "N",'+
		'		"MFIEnquiryAmount": null,'+
		'		"MFILoanPurpose": null,'+
		'		"MFICenterReferenceNo": null,'+
		'		"MFIBranchReferenceNo": null,'+
		'		"FormattedReport": "True"'+
		'	},'+
		'	"Applicant": {'+
		'		"ApplicantType": "Main",'+
		'		"ApplicantFirstName": "HITEN",'+
		'		"ApplicantMiddleName": null,'+
		'		"ApplicantLastName": "SHARMA",'+
		'		"DateOfBirth": "03071991",'+
		'		"Gender": "Male",'+
		'		"EmailAddress": null,'+
		'		"CompanyName": null,'+
		'		"Identifiers": {'+
		'			"Identifier": ['+
		'				{'+
		'					"IdNumber": "LFHPS0348G",'+
		'					"IdType": "01"'+
		'				},'+
		'				{'+
		'					"IdNumber": "982219123445",'+
		'					"IdType": "02"'+
		'				}'+
		'			]'+
		'		},'+
		'		"Telephones": {'+
		'			"Telephone": ['+
		'				{'+
		'					"TelephoneNumber": null,'+
		'					"TelephoneType": "01"'+
		'				},'+
		'				{'+
		'					"TelephoneNumber": null,'+
		'					"TelephoneType": "01"'+
		'				}'+
		'			]'+
		'		},'+
		'		"Address": ['+
		'			{'+
		'				"AddressLine1": "5TH",'+
		'				"AddressLine2": "FLOOR",'+
		'				"AddressLine3": "SUNNY",'+
		'				"AddressLine4": null,'+
		'				"AddressLine5": null,'+
		'				"AddressType": "02",'+
		'				"City": "JAIPUR",'+
		'				"PinCode": "302020",'+
		'				"ResidenceType": null,'+
		'				"StateCode": "08"'+
		'			}'+
		'		],'+
		'		"PersonRelation": null,'+
		'		"PersonName": null,'+
		'		"MemberRelationType4": null,'+
		'		"MemberRelationName4": null,'+
		'		"MemberRelationType3": null,'+
		'		"MemberRelationName3": null,'+
		'		"MemberRelationType2": null,'+
		'		"MemberRelationName2": null,'+
		'		"MemberRelationType1": null,'+
		'		"MemberRelationName1": null,'+
		'		"NomineeRelation": null,'+
		'		"NomineeName": null,'+
		'		"KeyPersonRelation": null,'+
		'		"KeyPersonName": null,'+
		'		"MemberOtherId4": null,'+
		'		"MemberOtherId4Type": null,'+
		'		"MemberOtherId3": null,'+
		'		"MemberOtherId3Type": null,'+
		'		"MemberOtherId2": null,'+
		'		"MemberOtherId2Type": null,'+
		'		"MemberOtherId1": null,'+
		'		"MemberOtherId1Type": null,'+
		'		"Accounts": {'+
		'			"Account": {'+
		'				"AccountNumber": null'+
		'			}'+
		'		},'+
		'		"FinalTraceLevel": "2"'+
		'	}'+
		'}';
        Cibil.parse(json);
    }
}