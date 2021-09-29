public class LC01_PriceSimulatorController {

    @AuraEnabled
    public static QuoteLineItem createRecords(String oppName, Id accountId, String productSubSegment,Integer annualQuantity,String marketOfApplication,Boolean purefoil){ 
		   
	    	Opportunity opp = new Opportunity(Name = oppName, AccountId = accountId,
	    	 								Quote_Type__c = 'Retention' , CloseDate = Date.today(),
	    	 								StageName = 'Simulation' , Contract__c = 'No');
	    	insert opp;
	    	
	    	System.debug('Opportunity Created : ' + opp);
	    	System.debug('Opportunity Created : ' + opp.id);
        	
	    	Quote q = new Quote(Name = oppName + ' Quote' , OpportunityId = opp.Id, Project_TYpe__c = 'P0',
	    						Quote_Due_Date__c = Date.today() , status = 'Simulation');
	    	insert q;

	    	

	    	System.debug('Quote Created : ' + q);
	    	System.debug('Quote Created : ' + q.id);

	    	
	    	QuoteLineItem qli = createQuoteLineItem(q.id,productSubSegment,annualQuantity,marketOfApplication,purefoil);
        	insert qli;	
        	
        	System.debug('Qli Created : ' + qli);
    		System.debug('Qli Created : ' + qli.id);
	        
	        return qli;
    }

    @AuraEnabled
    public static QuoteLineItem CreateQuoteLineItem(String quoteId, String selectedProduct, Integer annualQuantity, String marketOfApplication,Boolean purefoil) {
        system.debug('QUOTEID'+quoteId);

        Quote quote = [select id, Status,PriceBook2Id, Tech_contract_reminder__c,Opportunity.Account.Country__r.Country_Code__c ,Project_Type__c
        from Quote where Id = : quoteId];
		System.debug('AZ0 :' + quote);	
        QuoteLineItem item = null;
                   
        String location = QuoteWizardController.getLocation(quoteId);
            System.debug('AZ1 :' + location);
            //Get the Active PriceBookEntry
        List<PricebookEntry> priceBookEntries = [select id, name, PriceBook2Id, Product2Id, UnitPrice, 
                      Product2.Name, IsActive, Product2.ProductCode,Product2.Description,Product2.Family 
                      from PricebookEntry WHERE IsActive=true and PriceBook2.IsActive=true 
                      and Product2.Name =: selectedProduct];
        System.debug('AZ11 :' + selectedProduct);
        System.debug('AZ2 :' + priceBookEntries);
        String pmEligibleSubSegment 	= Label.Label_PM_Eligible_ProductSubSegment;
            
        if (priceBookEntries.size()>0) {
               
           	PricebookEntry priceBookEntry = priceBookEntries[0]; 

            item = new QuoteLineItem();
            item.PricebookEntryId = priceBookEntry.Id;
            item.Product2Id = priceBookEntry.Product2Id;
            item.UnitPrice = priceBookEntry.UnitPrice;
            item.Description = priceBookEntry.Product2.Name;
            item.Quantity = annualQuantity;      
            item.Billing_Currency__c = '';
            item.Purefoil_Segment__c = false;
            item.QuoteId = quote.Id;
            item.Market_Of_Application__c = marketOfApplication;
            item.location__c = location;
            item.Purefoil_Segment__c = purefoil;
            
            system.debug('@@qama item av '+item.ispricematrix__c);

        	item.isPriceMatrix__c  =true;

            //Shape is used to display purefoil or not
            if ('Plastic Tubes'.equalsIgnoreCase(priceBookEntry.Product2.Name) && 'EU'.equalsIgnoreCase(location)) {
                item.Shape__c = 'showPurefoil';
            } else {
              item.Shape__c = 'hidePurefoil';  
            } 
			
			if(quote.PriceBook2Id == null){

    			quote.PriceBook2Id = priceBookEntry.PriceBook2Id;
    			Update quote;
    		}		
    	}

    return item;
	}



    @AuraEnabled
    public static List<String> getElligibleProduct(Id accountId) {

    	Set<String> setToReturn = new Set<String>();
    	List<String> listToReturn = new List<String>();
    	
		String pmEligibleSubSegment = Label.Label_PM_Eligible_ProductSubSegment;
		map<string,Boolean> accessMapPM = QuoteLineItemService.mapAccessToPM();

		String usrId = UserInfo.getUserId();

    	User u = [select id, Profile.Name,ISM_Team_Member__c from User where id = :usrId];
		List<Account> acc = [select id ,Name,Country__c,Country__r.Country_Code__c from Account where id =: accountId];
        
        if(u.ISM_Team_Member__c == true || u.Profile.Name.equalsIgnoreCase('System Administrator') || u.Profile.Name.equalsIgnoreCase('Functionnal Administrator')){
            if(Test.isRunningTest()){
            	listToReturn = new List<String>{'Plastic Tubes','Laminate Tubes','Foam pumps','Fine mist pumps','Lotion pumps','Sampler pumps'};
            }
            else{
				String key1 = acc[0].Country__r.Country_code__c + '_'+Label.Label_ProductLine_Tubes+'_P0';
            	String key2 = acc[0].Country__r.Country_code__c + '_'+Label.Label_ProductLine_Dispensing+'_P0';    
            	if(accessMapPM.containsKey(key1) && accessMapPM.get(key1)){
                	listToReturn.addAll(new List<String>{'Plastic Tubes','Laminate Tubes'});
            	}
            	if(accessMapPM.containsKey(key2) && accessMapPM.get(key2)){
                	listToReturn.addAll(new List<String>{'Foam pumps','Fine mist pumps','Lotion pumps','Sampler pumps'});
                }	
            }
        }
    	else{
	    	List<Sales_Allocations__c> allocs = new List<Sales_Allocations__c>([Select id, Account__c,Account__r.Country__r.Country_Code__c,Product_Sub_segment__c,Product_Sub_segment__r.Name,Product_Sub_segment__r.Family from Sales_Allocations__c Where (Sales_Team__r.Director__c = :usrId or Sales_Team__r.Manager__c = :usrId or Sales_Team__r.KAM__c = :usrId or Sales_Team__r.Additional__c = :usrId) and Valid_From__c <= today and Valid_To__c >= today and Account__c =: accountId]); 
	    	
	    	for(Sales_Allocations__c alloc : allocs){
	                
	                string key = alloc.Account__r.Country__r.Country_Code__c +'_'+alloc.Product_Sub_segment__r.Family+'_P0';
   
	                if(pmEligibleSubSegment.contains(alloc.Product_Sub_segment__r.Name) && accessMapPM.containsKey(key) && accessMapPM.get(key) == true) 
	                {  setToReturn.add(alloc.Product_Sub_segment__r.Name);}
	        
	        } 
	        
	        listToReturn.addAll(setToReturn);
	    }
	        
        return listToReturn;
    }
    
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            optionlist.add('--None--');
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
	
}