public with sharing class DedupeDetailsVFController {
    
    public static boolean cmpParam{get;set;}

    public DedupeDetailsVFController(){
        cmpParam=true;
    }

    public static void handleComponentLoadSuccess(){
        cmpParam=false;
    }
}