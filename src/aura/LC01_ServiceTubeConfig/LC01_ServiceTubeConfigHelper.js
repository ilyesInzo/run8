({
	refreshattributes : function(cmp, event, config) {
    	cmp.set("v.totalpriceartwork", config.Total_price_for_Artwork__c);
    	cmp.set("v.totalpricesamples", config.Total_price_for_Samples__c);
    	cmp.set("v.totalpricepreproduction", config.Total_price_for_Preproduction__c);
    	cmp.set("v.amoutperitem", config.Amount_per_item__c);
    	cmp.set("v.numoffiles", config.Number_of_files__c);
    	cmp.set("v.totalamount", config.Total_amount__c);        	
    	cmp.set("v.typeoftubemsg", config.Type_Of_Tube_Message_Info__c);
    	cmp.set("v.typeoffilemsg", config.Type_of_file_Message_Info__c);    	
    }
})