trigger PMPRICEDETAILS_TRIGGER on PM_Price_Detail__c (after update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){    
        new PMPriceDetailsTriggerHandler().run();   
    }
    
}