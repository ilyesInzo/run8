trigger PMMOQPRICE_TRIGGER on PM_MOQ_price__c (after update) {
  	
	if(Trigger.isUpdate && Trigger.isAfter){		
		new PMMoqPricesTriggerHandler().run();				   
	}	  
}