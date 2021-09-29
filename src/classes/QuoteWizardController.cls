public class QuoteWizardController {

    @AuraEnabled
    public static Map<String, Object> getDataOnQuoteWizard(String quoteId) {
        system.debug('QUOTEID'+quoteId);
        Map<String, Object> data = new Map<String, Object>();
        
        Quote quote = [select id, Status, Tech_contract_reminder__c,Opportunity.Account.Country__r.Country_Code__c ,Project_Type__c
        from Quote where Id = : quoteId];
        if (quote.Status == 'Won' || quote.Status == 'Killed By Albea'
           || quote.Status == 'Lost' || quote.Status == 'Killed By Customer') {
            data.put('displayAddProductButton', false);
        } else {
           
            String location = getLocation(quoteId);
            
            //Get the Active PriceBookEntry
            List<PricebookEntry> priceBookEntries = [select id, name, PriceBook2Id, Product2Id, UnitPrice, 
                      Product2.Name, IsActive, Product2.ProductCode,Product2.Description,Product2.Family 
                      from PricebookEntry WHERE IsActive=true and PriceBook2.IsActive=true];        
            
            List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
            Map<String, List<PricebookEntry>> quoteLineItemFamilyMap = new Map<String, List<PricebookEntry>>();
            map<string,Boolean> accessMapPM = QuoteLineItemService.mapAccessToPM();	
            system.Debug('@@qama map '+accessMapPM);
            String pmEligibleSubSegment 	= Label.Label_PM_Eligible_ProductSubSegment;
            
            for (PricebookEntry priceBookEntry : priceBookEntries) {
                
                List<PricebookEntry> quoteItemsFound = quoteLineItemFamilyMap.get(priceBookEntry.Product2.Family);
                if (quoteItemsFound == null) {
                    quoteItemsFound = new List<PricebookEntry>();
                }
                priceBookEntry.IsActive = false;
                quoteItemsFound.add(priceBookEntry);
                quoteLineItemFamilyMap.put(priceBookEntry.Product2.Family, quoteItemsFound);
                
                QuoteLineItem item = new QuoteLineItem();
                item.PricebookEntryId = priceBookEntry.Id;
                item.Product2Id = priceBookEntry.Product2Id;
                item.UnitPrice = priceBookEntry.UnitPrice;
                item.Description = priceBookEntry.Product2.Name;
                item.Quantity = 0;      
                item.Billing_Currency__c = '';
                item.Purefoil_Segment__c = false;
                item.location__c = location;
                
                system.debug('@@qama item av '+item.ispricematrix__c);
                string key = quote.Opportunity.Account.Country__r.Country_Code__c +'_'+priceBookEntry.Product2.Family+'_'+  quote.Project_Type__c;
            	system.debug('@@qama key '+ key);
            	item.isPriceMatrix__c  =false;
            	if(pmEligibleSubSegment.contains(item.Description))
            		item.isPriceMatrix__c =  accessMapPM.get(key) != null  ? accessMapPM.get(key) :false;                  
                
                system.debug('@@qama item ap '+item.ispricematrix__c);
                
                //Shape is used to display purefoil or not
                if ('Plastic Tubes'.equalsIgnoreCase(priceBookEntry.Product2.Name) && 'EU'.equalsIgnoreCase(location)) {
                    item.Shape__c = 'showPurefoil';
                } else {
                  item.Shape__c = 'hidePurefoil';  
                }
                
                                
                //These 2 fields are used for error messages in the component
                item.Description__c = '';
                item.Stamp__c = '';            
                
                quoteLineItems.add(item);            
            } 
            system.debug(quoteLineItems);
            system.debug(priceBookEntries);
            //data.put('priceBookEntries', priceBookEntries);
            data.put('priceBookEntriesMap', quoteLineItemFamilyMap);
            data.put('quoteLineItems', quoteLineItems);        
            
            
            List<String> currencies = getBillingCurrencies();
            String defaultCurrency = currencies.get(0);
            data.put('currencies', currencies);
            data.put('productFamilyItems', getProductFamily());
            data.put('productCluster', getProductionCluster());
            data.put('productPlant', getProductionPlant());
            
            data.put('defaultCurrency', defaultCurrency);       
 			data.put('displayAddProductButton', true);
        }
        
        data.put('displayContractReminder', quote.Tech_contract_reminder__c);
        
        return data; 
        
        
    }
    
    
    /*AuraEnabled
    public static Map<String, Object> getDataOnQuoteWizardOld(String quoteId) {
        
        system.debug('QUOTEID'+quoteId);
         Map<String, Object> data = new Map<String, Object>();
        //If there is a Pricebook exist in the Quote, we do not need to show the Pricebook selection
        String displayPricebook = 'YES';
        Quote quote = [select id,Pricebook2Id from Quote where id = :quoteId];
        
        if (quote.Pricebook2Id != null) {
            displayPricebook = 'NO';
            system.debug('PRICEBOOK ALREADY EXIST....');
            Map<String, Object> existingMap = getProductLine(quote.Pricebook2Id);
            data.put('priceBookEntries', existingMap.get('priceBookEntries'));
           // system.debug('PRICEBOOK BOOK ENTRIES');
           //  system.debug(existingMap.get('priceBookEntries'));
        	//data.put('priceBookEntriesMap', quoteLineItemFamilyMap);
            data.put('quoteLineItems', existingMap.get('quoteLineItems'));
            data.put('selectedPriceBook', quote.Pricebook2Id);
            
        }
        
       
        List<String> currencies = getBillingCurrencies();
        String defaultCurrency = currencies.get(0);
       // data.put('showPriceBookSelection', displayPricebook);
        data.put('currencies', currencies);
        data.put('productFamilyItems', getProductFamily());
        
        data.put('defaultCurrency', defaultCurrency);
        data.put('pricebook', [select id, name from PriceBook2 where IsActive=true]);
		system.debug(data);
/*
        List<PricebookEntry> priceBookEntries = [select id, name, PriceBook2Id, Product2Id, UnitPrice, Product2.Name, Product2.ProductCode,Product2.Description,Product2.Family   from PricebookEntry WHERE IsActive=true];        
         system.debug(priceBookEntries);
        data.put('priceBookEntries', priceBookEntries);
		return data;        
    }*/
    
    private static List<String> getBillingCurrencies() {
       List<String> currencies = new List<String>();
            
       Schema.DescribeFieldResult fieldResult = QuoteLineItem.Billing_Currency__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       //Integer index=0;
       for( Schema.PicklistEntry f : ple) {
           currencies.add(f.getValue());          
       }     
       system.debug(currencies);
       return currencies;
    }
    
    private static List<String> getProductionCluster() {
       List<String> pcluster = new List<String>();
            
       Schema.DescribeFieldResult fieldResult = QuoteLineItem.Production_Cluster__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple) {
           pcluster.add(f.getValue());          
       }     
       system.debug(pcluster);
       return pcluster;
    } 

    private static List<String> getProductFamily() {
       List<String> productFamilyValues = new List<String>();
            
       Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       //Integer index=0;
       for( Schema.PicklistEntry f : ple) {
           productFamilyValues.add(f.getValue());          
       }     
       system.debug(productFamilyValues);
       return productFamilyValues;
    }
  
   private static List<String> getProductionPlant() {
       List<String> pPlant = new List<String>();
       
       pPlant.add('Hong Kong PC');               
       pPlant.add('Shanghai Plastic');               
       pPlant.add('Shanghai dispensing');               
       pPlant.add('Shanghai Metal');               
       pPlant.add('Shenzhen');               
       pPlant.add('Suzhou');               
       pPlant.add('Jundiai');               
       pPlant.add('Mogi das Cruzes');               
       pPlant.add('Baddi');               
       pPlant.add('Goa');               
       pPlant.add('Semarang');               
       pPlant.add('Surabaya');               
       pPlant.add('Surabaya PC');               
       pPlant.add('Bernaville');               
       pPlant.add('Parigne L Eveque');               
       pPlant.add('Plouhinec');               
       pPlant.add('Simandre');               
       pPlant.add('Bottanuco');               
       pPlant.add('Brownsville');               
       pPlant.add('Matamoros');               
       pPlant.add('Morristown');               
       pPlant.add('Water Town (Metal)');               
       pPlant.add('Alkmaar');               
       pPlant.add('Le Treport');               
       pPlant.add('Thomaston');               
       pPlant.add('LACROST');               
       pPlant.add('Colchester UK');               
       pPlant.add('Warsaw Poland');               
       pPlant.add('Lodz');               
       pPlant.add('Lodz PC');               
       pPlant.add('Noginsk');               
       pPlant.add('Schesslitz');               
       pPlant.add('CMI Hong Kong');               
       pPlant.add('Gennevilliers');               
       pPlant.add('New York');               
       pPlant.add('Brampton');               
       pPlant.add('Queretaro');               
       pPlant.add('Reynosa');               
       pPlant.add('Shelbyville');               
       pPlant.add('Washington');               
       system.debug(pPlant);
       return pPlant;
    }     
    
    
    @AuraEnabled
    public static String saveQuoteItems(String jsonQuoteLineItem, String quoteId, String defaultCurrency, String priceBookId) {
         QuoteLineItem[] quoteLineItems = (List<QuoteLineItem>)
             System.JSON.deserializeStrict(jsonQuoteLineItem, List<QuoteLineItem>.Class);

        return saveQuoteItems(quoteLineItems, quoteId, defaultCurrency, priceBookId);
    } 
    
    public static String saveQuoteItems(QuoteLineItem[] quoteLineItems, String quoteId, String defaultCurrency, String priceBookId) {
        String message= 'SUCCESS';
        system.debug('SAVING QUOTE ITEMS....');
        
        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
    	for (QuoteLineItem newQuoteLineItem : quoteLineItems) {
            system.debug('SAVING QUOTE ITEMS....=' + newQuoteLineItem.Quantity + '=' + newQuoteLineItem.Billing_Currency__c);
            if (newQuoteLineItem.Quantity > 0) {
                newQuoteLineItem.QuoteId = quoteId;
                if (String.isBlank(newQuoteLineItem.Billing_Currency__c)) {
                    newQuoteLineItem.Billing_Currency__c = defaultCurrency;
                }
				//Reset the 2 fields used for error message
                newQuoteLineItem.Description__c = '';  
            	newQuoteLineItem.Stamp__c = '';     
                newQuoteLineItem.Shape__c = '';
                newQuoteLineItems.add(newQuoteLineItem);
            }     
        }
        system.debug(newQuoteLineItems);
        try {
            if (newQuoteLineItems.size() > 0) {
                Quote quote = [select id,Pricebook2Id from Quote where id = :quoteId];
                if (quote.Pricebook2Id == null) {
                    Boolean setPriceBook = false;
                    for (PriceBook2 pricebook : [select id from PriceBook2 where isActive=true limit 1]) {
                        quote.Pricebook2Id = priceBook.Id;
                        setPriceBook = true;
                    }
                    if (setPriceBook) {
                       update quote;  
                    } else {
                        message = 'NO Active Pricebook found. You need to set a Pricebook to be able to create Quote Items';
                    }
                    
                    
                }
                insert newQuoteLineItems;
            }
        } catch (Exception e) {
            system.debug(e);
            message = e.getMessage();
			String errorMessage = e.getMessage();
            if (errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                message = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
            }
            if (errorMessage.contains('FIELD_INTEGRITY_EXCEPTION')) {
                message = errorMessage.substringBetween('FIELD_INTEGRITY_EXCEPTION, ' , ': [');
            }            
            
             
        }            
        return message;
    }
    
    @AuraEnabled
    public static Map<String, Object> getProductLine(String priceBookId) {
		Map<String, Object> data = new Map<String, Object>();
        List<PricebookEntry> priceBookEntries = [select id, name, PriceBook2Id, Product2Id, UnitPrice, 
                  Product2.Name, Product2.ProductCode,Product2.Description,Product2.Family 
                  from PricebookEntry WHERE PriceBook2Id=:priceBookId AND IsActive=true];        
        
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        Map<String, List<PricebookEntry>> quoteLineItemFamilyMap = new Map<String, List<PricebookEntry>>();
        for (PricebookEntry priceBookEntry : priceBookEntries) {
            
            List<PricebookEntry> quoteItemsFound = quoteLineItemFamilyMap.get(priceBookEntry.Product2.Family);
            if (quoteItemsFound == null) {
                quoteItemsFound = new List<PricebookEntry>();
            }
            quoteItemsFound.add(priceBookEntry);
            quoteLineItemFamilyMap.put(priceBookEntry.Product2.Family, quoteItemsFound);
            
            QuoteLineItem item = new QuoteLineItem();
            item.PricebookEntryId = priceBookEntry.Id;
            item.Product2Id = priceBookEntry.Product2Id;
            item.UnitPrice = priceBookEntry.UnitPrice;
            item.Description = priceBookEntry.Product2.Name;
            item.Description__c = '';
            item.Quantity = 0;      
            item.Billing_Currency__c = '';
            item.Purefoil_Segment__c = false;
            item.Shape__c = '';
            
            quoteLineItems.add(item);            
        } 
        
        system.debug(priceBookEntries);
        data.put('priceBookEntries', priceBookEntries);
        data.put('priceBookEntriesMap', quoteLineItemFamilyMap);
        data.put('quoteLineItems', quoteLineItems);
		return data;        
        
    }
    
    
    public static Map<String, Object> loadProductLine() {
		Map<String, Object> data = new Map<String, Object>();
        List<PricebookEntry> priceBookEntries = [select id, name, PriceBook2Id, Product2Id, UnitPrice, 
                  Product2.Name, Product2.ProductCode,Product2.Description,Product2.Family 
                  from PricebookEntry WHERE IsActive=true and PriceBook2.IsActive=true];        
        
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        Map<String, List<PricebookEntry>> quoteLineItemFamilyMap = new Map<String, List<PricebookEntry>>();
        for (PricebookEntry priceBookEntry : priceBookEntries) {
            
            List<PricebookEntry> quoteItemsFound = quoteLineItemFamilyMap.get(priceBookEntry.Product2.Family);
            if (quoteItemsFound == null) {
                quoteItemsFound = new List<PricebookEntry>();
            }
            quoteItemsFound.add(priceBookEntry);
            quoteLineItemFamilyMap.put(priceBookEntry.Product2.Family, quoteItemsFound);
            
            QuoteLineItem item = new QuoteLineItem();
            item.PricebookEntryId = priceBookEntry.Id;
            item.Product2Id = priceBookEntry.Product2Id;
            item.UnitPrice = priceBookEntry.UnitPrice;
            item.Description = priceBookEntry.Product2.Name;
            item.Quantity = 0;      
            item.Billing_Currency__c = '';
            item.Purefoil_Segment__c = false;
            item.Shape__c = '';
            
            quoteLineItems.add(item);            
        } 
        
        system.debug(priceBookEntries);
        data.put('priceBookEntries', priceBookEntries);
        data.put('priceBookEntriesMap', quoteLineItemFamilyMap);
        data.put('quoteLineItems', quoteLineItems);
		return data;        
        
    }
    
        @AuraEnabled
    public static String getLocation(String quoteId){
        String location = '';
        
        Quote quote  = [Select Id, Opportunity.Account.Country__r.Country_Code__c, Project_Type__c 
                             FROM Quote WHERE Id = :quoteId Limit 1];
/*        QuoteLineItem qli = [Select Id, Location__c, Quote.Opportunity.Account.Country__r.Country_Code__c, Product_Line__c, Quote.Project_Type__c 
                             FROM QuoteLineItem WHERE Id = :quoteItemId Limit 1 ];
        string countryCode = qli.Quote.Opportunity.Account.Country__r.Country_Code__c;*/
        String countryCode = quote.Opportunity.Account.Country__r.Country_Code__c;
        
       // final String tableName = 'Access to PricematriX by PL,zone, country';
        String PRICEMATRIX_EUROPE = 'PricematriX Europe';
        String PRICEMATRIX_AMERICAS = 'PricematriX Americas';
        //String PRODUCT_LINE_TUBES  = 'Tubes';
        //String PRODUCT_LINE_DISPENSING  = 'Dispensing';
        
        String buildquery = 'SELECT Id,Product_Line_Tubes__c, Product_Line_Dispensing__c FROM PM_Global_Config__c WHERE ';        
        buildquery  += 'Table_Name__c = \'Access to PricematriX by PL,zone, country\' ';
        buildquery  += 'AND Country_code__c =:countryCode ';
//        buildquery  += (qli.Product_Line__c == PRODUCT_LINE_DISPENSING)?'AND (Product_Line_Dispensing__c = \''+PRICEMATRIX_EUROPE+'\' OR Product_Line_Dispensing__c = \''+PRICEMATRIX_AMERICAS+'\') ':'';
//        buildquery  += (qli.Product_Line__c == PRODUCT_LINE_TUBES)?'AND (Product_Line_Tubes__c = \''+PRICEMATRIX_EUROPE+'\' OR Product_Line_Tubes__c = \''+PRICEMATRIX_AMERICAS+'\') ':'';
        buildquery  += (quote.Project_Type__c == 'P0')?'AND PricematriX_used_for_P0__c = true ':'';
        buildquery  += (quote.Project_Type__c == 'P0+')?'AND PricematriX_used_for_P0plus__c = true ':'';
        buildquery  += (quote.Project_Type__c == 'P1')?'AND PricematriX_used_for_P1__c = true ':'';
        
        System.debug('******buildquery  *****' + buildquery  );
        
        List<PM_Global_Config__c> globalconfigLst = Database.Query(buildquery);
        
        if(!globalconfigLst.isEmpty()){
            PM_Global_Config__c gc = globalconfigLst.get(0);
            System.debug('****** gc =' + gc);
            String accessForProductLineTubes = gc.Product_Line_Tubes__c;
            String accessForProductLineDispensing = gc.Product_Line_Dispensing__c;
            
            System.debug('****** accessForProductLineTubes =' + accessForProductLineTubes);
            System.debug('****** accessForProductLineDispensing = ' + accessForProductLineDispensing);
            
            if(accessForProductLineTubes == PRICEMATRIX_EUROPE || accessForProductLineDispensing == PRICEMATRIX_EUROPE ){
                location = 'EU';
            } else if(accessForProductLineTubes == PRICEMATRIX_AMERICAS || accessForProductLineDispensing == PRICEMATRIX_AMERICAS ){
                location = 'US';
            }

            
        }
        return location;
    }
    
    
}