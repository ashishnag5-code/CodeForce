public with sharing class CreditDPDCheckController {
    
    public static boolean cmpParam{get;set;}

    public CreditDPDCheckController(){
        cmpParam=true;
    }

    public static void handleComponentLoadSuccess(){
        cmpParam=false;
    }
}