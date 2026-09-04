trigger PricingApprovalEventTrigger on Pricing_Approval_Event__e (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        PricingApprovalHandler.handlePricingApprovalPlatformEvent(Trigger.NewMap);
    }
}