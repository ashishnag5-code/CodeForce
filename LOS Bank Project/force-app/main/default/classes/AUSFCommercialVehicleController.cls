public with sharing class AUSFCommercialVehicleController {
    @AuraEnabled( cacheable = true )
    public static Body_Funding_Cap_Master__mdt[] getBodyFundingCapAmount( Id loanId, Collateral__c collateral ){

        Loan_Application__c loanApp = [
            SELECT Id, Customer_Grade__c, Sub_Grade__c, toLabel(Collateral_Type__c) FROM Loan_Application__c
            WHERE Id =: loanId WITH SECURITY_ENFORCED
        ];

        String customerGrade = loanApp.Customer_Grade__c,
            subGrade = loanApp.Sub_Grade__c,
            collateralType = collateral.Collateral_Name__c,
            bodyType = collateral.Body_Type__c;

        return [ //NOPMD - false-positve - Query on Custommdt
            SELECT Cap_Amount__c FROM Body_Funding_Cap_Master__mdt
            WHERE Customer_Grade__c =: customerGrade AND
            ( Sub_Grade__c =: subGrade OR Sub_Grade__c = 'All' ) AND Collateral_Type__c =: collateralType AND
            Body_Type__c =: bodyType //AND Is_Active__c = TRUE
        ];
    }

    @AuraEnabled( cacheable = true )
    public static Depreciated_Grid__c getDepreciatedMaster( Collateral__c collateral, Loan_Application__c loanApp ){
        try {
            Id ltvRecordTypeId = Utility.getRecordTypeId( SObjectType.Depreciated_Grid__c.getSObjectType(), 'LTV' );
            String grade = loanApp.Customer_Grade__c,
                scheme = collateral.Scheme__c,
                vehicleUsage = collateral.Vehicle_Usage__c,
                productType = Utility.getProductNameByCode( loanApp.Product__c );
    
            String[] eligibleSubGrades = new String[]{ loanApp.Sub_Grade__c, 'All' },
                applicableProducts = new String[]{ productType, 'All' };
        
            String whereClause = 'RecordTypeId =: ltvRecordTypeId AND Applicable_Products__c IN: applicableProducts AND Customer_Grade__c =: grade AND Sub_Grade__c IN: eligibleSubGrades AND ( Scheme__c=: scheme OR Scheme__c = NULL ) AND Vehicle_Usage__c =: vehicleUsage AND Category__c INCLUDES (\'' + String.escapeSingleQuotes( collateral.Vehicle_Category__c ) + '\')';
            Depreciated_Grid__c[]  depreciatedMaster = Database.query( String.format( 'SELECT {0} FROM Depreciated_Grid__c WHERE {1}', new String[]{ 'LTV_Approved__c', whereClause } ) );
            
            if( depreciatedMaster.isEmpty() ){
                depreciatedMaster = [
                    SELECT LTV_Approved__c
                    FROM Depreciated_Grid__c
                    WHERE RecordTypeId =: ltvRecordTypeId AND Scheme__r.Scheme_Name__c = 'Normal'
                    WITH SYSTEM_MODE
                ];
            }
                
            return depreciatedMaster[0];
        } catch (Exception ex){
            throw new AuraHandledException( ex.getMessage() );
        }
    }

    @AuraEnabled( cacheable = true )
    public static map<String, Object> validateParentLoan( Loan_Application__c parentLoan ){
        String loanIdentifier = parentLoan.Name;
        Loan_Application__c[] parentLoanApplication = [
            SELECT
            Id, Name, RecordType.Name, Collateral_Type__c, Product__c, Scheme__c, Customer_Grade__c, Sub_Grade__c,
            ( SELECT Id, Vehicle_Type__c, Body_Type__c, Collateral_Name__c FROM Collaterals__r WHERE Is_Deleted__c = FALSE AND RecordTypeId IN: GlobalConstants.colRecordTypeIds )
            FROM Loan_Application__c
            WHERE Name =: loanIdentifier OR Id =: loanIdentifier
            WITH SECURITY_ENFORCED
        ];

        if( parentLoanApplication.isEmpty() ){
            throw new AUSFCommercialVehicleException( String.format( Label.LoanNumberDoesNotExist, new String[]{ parentLoan.Name } ) );
        } else if( Utility.getProductTypeName( parentLoanApplication[0].Product__c ) != 'Commercial' ){
            throw new AUSFCommercialVehicleException( Label.NotCommercialLoanApplicationError );
        } else if( Label.Commercial_Body_Funding_Collateral_Codes.split(',').contains(parentLoanApplication[0].Collateral_Type__c) ){
            throw new AUSFCommercialVehicleException( Label.NotPrimaryAssetLoan );
        } else if( parentLoanApplication[0].Collaterals__r.isEmpty() ){
            throw new AUSFCommercialVehicleException( Label.PrimaryAssetMissingCollateralDetails );
        }

        return new map<String, Object>{
            'parentLoan' => parentLoanApplication[0],
            'variant' => [ SELECT Id, Name, Model__r.Name, Make__r.Name FROM MMV_Master__c WHERE Name =: Label.BodyFundingMMV AND RecordType.Name = 'Variant' ORDER BY CreatedDate DESC LIMIT 1 ]
        };
    }

    @AuraEnabled( cacheable = true )
    public static map<String, Object> validateParentLoanTractor( Loan_Application__c parentLoan ){
        String loanIdentifier = parentLoan.Name;
        Loan_Application__c[] parentLoanApplication = [
            SELECT
            Id, Name, RecordType.Name, Collateral_Type__c, Product__c, Scheme__c, Customer_Grade__c, Sub_Grade__c,
            ( SELECT Id, Vehicle_Type__c, Body_Type__c, Collateral_Name__c FROM Collaterals__r WHERE Is_Deleted__c = FALSE AND RecordTypeId IN: GlobalConstants.colRecordTypeIds )
            FROM Loan_Application__c
            WHERE Name =: loanIdentifier OR Id =: loanIdentifier
            WITH SECURITY_ENFORCED
        ];

        if( parentLoanApplication.isEmpty() ){
            throw new AUSFCommercialVehicleException( String.format( Label.LoanNumberDoesNotExist, new String[]{ parentLoan.Name } ) );
        } else if( parentLoanApplication[0].RecordType.Name != GlobalConstants.TRACTOR ){
            throw new AUSFCommercialVehicleException( Label.NotTractorLoanApplicationError );
        } else if( Label.Tractor_Implement_Collateral_Codes.split(',').contains(parentLoanApplication[0].Collateral_Type__c) ){
            throw new AUSFCommercialVehicleException( Label.NotPrimaryAssetLoan );
        } else if( parentLoanApplication[0].Collaterals__r.isEmpty() ){
            throw new AUSFCommercialVehicleException( Label.PrimaryAssetMissingCollateralDetails );
        }

        return new map<String, Object>{
            'parentLoan' => parentLoanApplication[0]
        };
    }

    public class AUSFCommercialVehicleException extends Exception{}
}