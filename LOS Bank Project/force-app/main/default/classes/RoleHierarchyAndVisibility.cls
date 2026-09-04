public with sharing class RoleHierarchyAndVisibility {
    
    public static Map<Id, String> getAccessibleProducts(List<Loan_Application__c> loanApps){

        Map<Id, String> loanIdVsProductsAccessible = new Map<Id, String>();
        List<Accessible_Products__mdt> productsAccessible = Accessible_Products__mdt.getAll().values();        
        for(Loan_Application__c loan: loanApps){
            for(Accessible_Products__mdt record: productsAccessible){
                if((record.Product_Codes__c != null && loan.Product__c != null && record.Product_Codes__c.contains(loan.Product__c)) && (record.Collateral_Codes__c==null || (record.Collateral_Codes__c!=null && loan.Collateral_Type__c!=null && record.Collateral_Codes__c.contains(loan.Collateral_Type__c)))){
                    //loan.Product_Applicable_For__c.add(record.DeveloperName);
                    String accessibleProducts;
                    if(loanIdVsProductsAccessible.containsKey(loan.Id)){
                        accessibleProducts = loanIdVsProductsAccessible.get(loan.Id)+';'+record.MasterLabel; 
                    }else{
                        accessibleProducts = record.MasterLabel;
                    }
                    loanIdVsProductsAccessible.put(loan.Id,accessibleProducts);

                }
            }
        }
        return loanIdVsProductsAccessible;
    }
}