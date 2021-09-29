/**
 * [ LC01_DetailCtrlTest description : Unit Test for LC01_DetailCtrl ]
 * @author Eric Wartelle
 * @version 1.0 - Version Initiale
 */
@isTest
private class LC01_DetailCtrlTest {
	//Attributs of the class LC01_DetailCtrlTest

	//Methods of the class LC01_DetailCtrlTest
	/**
	 * [createTestData description : will create test data for test purpose ]
	 */
	@Testsetup
	public static void createTestData(){		
		insert TestFactory.newCountry();
		insert TestFactory.newState('FRANCE','FR');
		insert TestFactory.newState('NEW JERSEY','US-NJ');
				
		insert TestFactory.newDistributionChannel('MASS MARKET','00002','E');
		
		List<Sales_Area__c> liSalesArea = new list<Sales_Area__c>();
		liSalesArea.add(TestFactory.newSalesArea('Global Accounts','GA','','','E','GBE','G' ));
		liSalesArea.add(TestFactory.newSalesArea('KA Beauty USA','KA','','','E','KBU','R' ));
		
		insert liSalesArea;
		
		//******* Create account *********
		// create two accouts one for US and another for EU with dist channel MASS MARKET for USA and Customer Size PM = SA and KA
		List<Account> liAccount = new list<Account>();
		liAccount.Add(TestFactory.newAccount(
										[select id from country__c where name ='FRANCE' limit 1].id ,
										[select id from Distribution_Channel__c where Name ='MASS MARKET' limit 1].id , 
										[select id from Sales_Area__c where name ='Global Accounts' limit 1].id ,
										[select id from state__c where name ='FRANCE' limit 1].ID
									));
		liAccount.Add(TestFactory.newAccount(
										[select id from country__c where name ='UNITED STATES' limit 1].id ,
										[select id from Distribution_Channel__c where Name ='MASS MARKET' limit 1].id , 
										[select id from Sales_Area__c where name ='KA Beauty USA' limit 1].id ,
										[select id from state__c where name ='NEW JERSEY' limit 1].ID 
									));							
		insert liAccount;
		 
		//******* create opportunities
		List<Opportunity> liOpportunity = new list<Opportunity>();
		liOpportunity.Add(TestFactory.newOpportunity (
											'Opportunity test EU '+String.valueOf(datetime.now().getTime()), 
											'Proposal',  
											'Retention' , 
											null, 
											[select id from Account where country__r.NAme = 'FRANCE' limit 1].id 
										));
		liOpportunity.Add(TestFactory.newOpportunity (
											'Opportunity test US '+String.valueOf(datetime.now().getTime()), 
											'Proposal',  
											'Retention' , 
											null, 
											[select id from Account where country__r.NAme  ='UNITED STATES' limit 1].id 
										));
		insert liOpportunity;	
			
		//******* create quote 
		List<quote> liquote = new list<quote>();
		liquote.add(TestFactory.newQuote( 'P0', 
									 (date) system.today()-1, 
									 'Draft', 
									 [select id from Opportunity where name like '%US%'limit 1].id ));
		liquote.add(TestFactory.newQuote( 'P0', 
									 (date) system.today()-1, 
									 'Draft', 
									 [select id from Opportunity where name like '%EU%'limit 1].id ));
		insert liquote;
		
		//******* Create products
		insert TestFactory.newProducts(new set<String>{'Lotion pumps','Foam pumps','Fine mist pumps', 'Sampler pumps'}, 'Dispensing');
		insert TestFactory.newProducts(new set<String>{'Plastic Tubes','Laminate Tubes'}, 'Tubes');
		

			List<PM_Discount_corridor__c> liCorridors = Test.loadData(PM_Discount_corridor__c.sObjectType, 'mock_PMDiscountCorridor');		
		//}
		map<string, id> mapKeyToCorridor = new map<string, id>();		
		for(PM_Discount_corridor__c corr : [select id, activity__c , location__c from PM_Discount_corridor__c]){
			mapKeyToCorridor.put(corr.activity__c+'_'+corr.location__c,corr.id);	
		}
		
		Id priceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Product2 p : [select id, name from product2]) {
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = priceBookId, 
                Product2Id = p.Id,
                UnitPrice = 100, 
                IsActive = true);
            pbEntries.add(standardPrice);
        }
        insert pbEntries; 
        
        map<id,id> idPbeToProd = new map<id,id>();
        for(PricebookEntry pBE : [select id , Product2Id from PricebookEntry]){
        	idPbeToProd.put(pBE.Product2Id,pBE.id)	;
        }
        
		//******* create qlis
		List<Quotelineitem> liQuotelineitem = new List<Quotelineitem>();	
		for(Product2 prod : [select id, name from product2]){ //US
			Quotelineitem qli = TestFactory.newQuoteLineItem (	[select id from quote where Quote.opportunity.Name like '%US%'  limit 1].id, 
												prod.id, 
												idPbeToProd.get(prod.id), 
												'', 
												'', 
												1, 
												200, 
												'US'
											);
			qli.BILLING_CURRENCY__C = 'American Dollar';
			qli.MARKET_OF_APPLICATION__C = 'BABY CARE';
			qli.Ref_RFQ__c ='PM';
			
			string key ='';
			if(prod.name == 'Lotion pumps'){
				key = 'Lotion' ;	
			}else if(prod.name == 'Fine mist pumps'){
				key = 'Fine Mist' ;
			}else if(prod.name == 'Plastic Tubes'){
				key = 'Plastic' ;
			}else if(prod.name == 'Laminate Tubes'){
				key = 'Laminate Tube' ;
			}else if(prod.name == 'Samplers pumps'){
				key = 'Samplers' ;
			}else if(prod.name == 'Foam pumps'){
				key = 'Foam' ;
			}
			
			key = key+'_'+qli.Location__c;			
			qli.SELECTED_CORRIDOR__C = mapKeyToCorridor.get(key);	
			liQuotelineitem.add(qli);
		}
		system.debug('@@qama pricebookentryid '+Test.getStandardPricebookId());
		for(Product2 prod : [select id, name from product2]){ //EU
			Quotelineitem qli = TestFactory.newQuoteLineItem (	[select id from quote where Quote.opportunity.Name like '%EU%'  limit 1].id, 
												prod.id,
												idPbeToProd.get(prod.id),
												'', 
												'', 
												1, 
												200, 
												'EU'
											);
			qli.BILLING_CURRENCY__C = 'Euro';
			qli.MARKET_OF_APPLICATION__C = 'BABY CARE';
			qli.Ref_RFQ__c ='PM';
						
			liQuotelineitem.add(qli);  
		}
		insert liQuotelineitem;
		system.debug('@@qama liQuotelineitem '+liQuotelineitem);
		
		map<string, id> mapKeyToQli = new map<string, id>();		
		for(QuoteLineItem qli : [select id, Product_Sub_segment__c , location__c from QuoteLineItem]){
			system.debug('@@qama qli.Product_Sub_segment__c '+qli.Product_Sub_segment__c+qli.location__c);
			mapKeyToQli.put((qli.Product_Sub_segment__c+'_'+qli.location__c).tolowercase(),qli.id);	
		}
		
		//******* create dispensing config 		
		//System.runAs(usr){
			 TriggerHandler.bypass('PMSelectedDipsensingconfigTriggerHandler');
			 TriggerHandler.bypass('PMSelectedTubesConfigTriggerHandler');
 			
			List<PM_Selected_Dipsensing_config__c> liSelDisp = Test.loadData(PM_Selected_Dipsensing_config__c.sObjectType, 'mock_PMSelectedDispensing');		
		//}
		List<PM_Selected_Dipsensing_config__c> liSelDispToUpdate = new List<PM_Selected_Dipsensing_config__c>();	
		for(PM_Selected_Dipsensing_config__c selDisp :[select id, quote_item__c, product_segment__c,location__c from PM_Selected_Dipsensing_config__c ]){
			selDisp.Quote_item__c = mapKeyToQli.get((selDisp.PRODUCT_SEGMENT__C+'_'+selDisp.location__c).tolowercase());	
			liSelDispToUpdate.add(selDisp);			
		}
		update liSelDispToUpdate;
		system.debug('@@qama liSelDispToUpdate '+liSelDispToUpdate);
		
		//******* create tube config 
		//System.runAs(usr){
			List<PM_Selected_Tubes_Config__c> liSelTube = Test.loadData(PM_Selected_Tubes_Config__c.sObjectType, 'mock_PMSelectedTube');		
		//}
		List<PM_Selected_Tubes_Config__c> liSelTubeToUpdate = new List<PM_Selected_Tubes_Config__c>();
		for(PM_Selected_Tubes_Config__c selTube :[select id, location__c ,PRODUCT_SEGMENT__C, quote_item__c from PM_Selected_Tubes_Config__c ]){
			selTube.Quote_item__c = mapKeyToQli.get( (selTube.PRODUCT_SEGMENT__C+'_'+selTube.location__c).tolowercase());	
			liSelTubeToUpdate.Add(selTube);
		}
		update liSelTubeToUpdate; 
		system.debug('@@qama liSelTubeToUpdate '+liSelTubeToUpdate);
		
		//******* create price details
		map<id,id> mapMockDataConfigToQLi = new map<id,id>(); //idQli=> idConfig
		for(PM_Selected_Dipsensing_config__c item :[select id,Quote_item__c from PM_Selected_Dipsensing_config__c ]){
			//mapMockDataConfigToQLi.put(item.id,item.Quote_item__c) ;	
			mapMockDataConfigToQLi.put(item.Quote_item__c,item.id) ;	
		}
		for(PM_Selected_Tubes_Config__c item :[select id,Quote_item__c from PM_Selected_Tubes_Config__c ]){
			//mapMockDataConfigToQLi.put(item.id,item.Quote_item__c) ;	
			mapMockDataConfigToQLi.put(item.Quote_item__c,item.id) ;
		}
		system.debug('@@qama mapMockDataConfigToQLi '+mapMockDataConfigToQLi);
				
		map<id,string> mapMockDataQli = new map<id,string>();
		mapMockDataQli.put('0QL26000000Tx7wGAC','Lotion pumps_US');
		mapMockDataQli.put('0QL26000000YzltGAC','Lotion pumps_EU');
		
		mapMockDataQli.put('0QL26000000YzfYGAS','Fine mist pumps_US');
		mapMockDataQli.put('0QL26000000Xg0ZGAS','Fine mist pumps_EU');
		
		mapMockDataQli.put('0QL26000000YX6mGAG','Plastic Tubes_US');
		mapMockDataQli.put('0QL26000000YzlpGAC','Plastic Tubes_EU');
		
		mapMockDataQli.put('0QL26000000YzfOGAS','Laminate Tubes_US');
		mapMockDataQli.put('0QL26000000YzloGAC','Laminate Tubes_EU');
		
		mapMockDataQli.put('0QL26000000YzfZGAS','Sampler pumps_US');
		mapMockDataQli.put('0QL26000000YzmDGAS','Sampler pumps_EU');
		
		mapMockDataQli.put('0QL26000000YzfaGAC','Foam pumps_US');
		mapMockDataQli.put('0QL26000000YzluGAC','Foam pumps_EU');
		
	 	List<PM_Price_Detail__c> liPriceDetails = Test.loadData(PM_Price_Detail__c.sObjectType, 'mock_PMPriceDetail');		
		List<PM_Price_Detail__c> liPriceDetailsToUpdate = new List<PM_Price_Detail__c>();
		for(PM_Price_Detail__c priceDetail :[select id,Section__c,DataLoaderExtId__c,PM_SELECTED_TUBES_CONFIG__C,PM_SELECTED_DIPSENSING_CONFIG__C,moq_min__c,extid__c,name 
											from pm_price_detail__c]){
			//update qliId 
			priceDetail.QUOTE_ITEM__C = mapKeyToQli.get(mapMockDataQli.get(priceDetail.DataLoaderExtId__c ).tolowercase());
			
			//update disp ID or tube id
			String configID='';
			//if(mapMockDataQli.get(priceDetail.DataLoaderExtId__c).contains('Tubes') ){
			if(priceDetail.EXTID__C.left(3) == 'a0u' ){		
				priceDetail.PM_SELECTED_TUBES_CONFIG__C	= mapMockDataConfigToQLi.get(priceDetail.QUOTE_ITEM__C ) ;	
				configID =priceDetail.PM_SELECTED_TUBES_CONFIG__C;			
			}else{
				priceDetail.PM_SELECTED_DIPSENSING_CONFIG__C = mapMockDataConfigToQLi.get(priceDetail.QUOTE_ITEM__C ) ;
				configID =priceDetail.PM_SELECTED_DIPSENSING_CONFIG__C;		
			}
			
			//update extID			
			//priceDetail.EXTID__C  = mapMockDataConfigToQLi.get(priceDetail.DataLoaderExtId__c )+priceDetail.Name+priceDetail.moq_min__c;
			priceDetail.EXTID__C = configID+priceDetail.Name+priceDetail.moq_min__c;
			//system.debug('@@qama priceDetail '+priceDetail);
			liPriceDetailsToUpdate.add(priceDetail);
		}
		update liPriceDetailsToUpdate;
		
		//******* create pm moq prices
		List<PM_MOQ_price__c> liPMOQrices = Test.loadData(PM_MOQ_price__c.sObjectType, 'mock_PMMockPrice');	
		List<PM_MOQ_price__c> liPMOQricesToUpdate = new List<PM_MOQ_price__c>();
		for(PM_MOQ_price__c moq :[select id,QUOTE_ITEM__C, DataLoaderExtId__c,PM_SELECTED_TUBES_CONFIG__C,PM_SELECTED_DIPSENSING_CONFIG__C,extid__c,moq_min__c
								from PM_MOQ_price__c]){
			//update the qli
			moq.QUOTE_ITEM__C = mapKeyToQli.get(mapMockDataQli.get(moq.DataLoaderExtId__c).tolowercase());
			
			//update the selectedConfig
			String confID='';
			if(mapMockDataQli.get(moq.DataLoaderExtId__c).contains('Tubes')  ){
				moq.PM_SELECTED_TUBES_CONFIG__C	= mapMockDataConfigToQLi.get(moq.QUOTE_ITEM__C) ;	
				confID= moq.PM_SELECTED_TUBES_CONFIG__C;			
			}else{
				moq.PM_SELECTED_DIPSENSING_CONFIG__C = mapMockDataConfigToQLi.get(moq.QUOTE_ITEM__C) ;
				confID= moq.PM_SELECTED_DIPSENSING_CONFIG__C;
			} 			
			//update the ext id
			//moq.EXTID__C = moq.moq_min__c+'-'+ mapMockDataConfigToQLi.get(moq.QUOTE_ITEM__C);	
			moq.EXTID__C = moq.moq_min__c+'-'+confID;
			liPMOQricesToUpdate.add(moq);
		}
		update liPMOQricesToUpdate;
				
		
		TriggerHandler.clearBypass('PMSelectedDipsensingconfigTriggerHandler');
		TriggerHandler.clearBypass('PMSelectedTubesConfigTriggerHandler');


	}

	/**
	 * 
	 */
	@isTest
    private static void getDetailPricesTest() {

    	Quotelineitem qli = [
    		Select id 
    		From QuoteLineItem 
			Where Product_Sub_segment__c = 'Plastic Tubes'
			And Location__c ='EU' 
			Limit 1 
		];

		test.startTest();
		Map<String, Object> priceDetails = LC01_DetailCtrl.getDetailPrices(qli.Id);
    	test.stopTest();

    }

    @isTest
    private static void getDetailPricesByObjectTest() {

    	Quotelineitem qli = [
    		Select id 
    		From QuoteLineItem 
			Where Product_Sub_segment__c = 'Plastic Tubes'
			And Location__c ='EU' 
			Limit 1 
		];

		test.startTest();
		Map<String, Object> priceDetails = LC01_DetailCtrl.getDetailPricesByObject(qli.Id);
    	test.stopTest();

    }

    @isTest
    private static void saveDetailPricesTest() {

    	Quotelineitem qli = [
    		Select id 
    		From QuoteLineItem 
			Where Product_Sub_segment__c = 'Plastic Tubes'
			And Location__c ='EU' 
			Limit 1 
		];


    	Map<String, List<Object>> overridePriceList = new Map<String, List<Object>> {
    		'Product Definition=Pump=10' => new List<String>{'10'},
    		'Coloration Upcharge=Actuator Coloration=10' => new List<String>{'10'},
    		'Coloration Upcharge=Actuator Coloration=25' => new List<String>{'25'},
    		'Coloration Upcharge=Actuator Coloration=50' => new List<String>{'50'},
    		'Coloration Upcharge=Actuator Coloration=100' => new List<String>{'100'},
    		'Coloration Upcharge=Actuator Coloration=250' => new List<String>{'250'}
    	};
		LC01_DetailCtrl.saveDetailPrices(overridePriceList,qli.Id);
    	
    }

    @isTest
    private static void getOverridePriceTest() {

    	Quotelineitem qli = [
    		Select id, QuoteId
    		From QuoteLineItem 
			Where  Product_Sub_segment__c = 'Plastic Tubes'
			And Location__c ='EU' 
			Limit 1 
		];

		test.startTest();
		String getPriceDetails = LC01_DetailOverridePMPrice.getOverridePrice(
			'Coloration Upcharge', 
			'Actuator Coloration',
			10, 
			10,
			2,
			qli.Id,
            'tubeId',
            'dispensingId'
        );
    	test.stopTest();
    }

    

}