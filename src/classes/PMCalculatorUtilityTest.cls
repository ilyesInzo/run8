/** 
* @description TEST CLASS for PMCalculatorUtility
* @author MQ
* @date 11/12/2017
*/
@isTest 
private class PMCalculatorUtilityTest { 
		@Testsetup
	public static void createTestData(){	
		//Create PM Global config test record
    	PM_Global_Config__c testRecord = new PM_Global_Config__c(Country_Name__c ='France',Table_name__c ='SKONTO');	
    	insert testRecord;
    		
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
		for(PM_Price_Detail__c priceDetail :[select id,DataLoaderExtId__c,PM_SELECTED_TUBES_CONFIG__C,PM_SELECTED_DIPSENSING_CONFIG__C,moq_min__c,extid__c,name 
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
			priceDetail.EXTID__C  =configID +priceDetail.Name+priceDetail.moq_min__c;
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
				
		//******* create price RECOS
		List<PM_Price_Recommendation__c> liPriceReco = Test.loadData(PM_Price_Recommendation__c.sObjectType, 'mock_PMPriceReco');	
		
		List<PM_Price_Recommendation__c> liPriceRecoToUpdate = new List<PM_Price_Recommendation__c>();
		for(PM_Price_Recommendation__c reco :[select id,QUOTE_LINE_ITEM__C,DataLoaderExtId__c,PM_SELECTED_TUBES_CONFIG__C,PM_SELECTED_DIPSENSING_CONFIG__C,MOQ__C
											from PM_Price_Recommendation__c]){
			//update the qli
			reco.QUOTE_LINE_ITEM__C = mapKeyToQli.get(mapMockDataQli.get(reco.DataLoaderExtId__c).tolowercase());
			
			//update the selectedConfig
			string conID='';
			if(mapMockDataQli.get(reco.DataLoaderExtId__c).contains('Tubes') ){
				reco.PM_SELECTED_TUBES_CONFIG__C	= mapMockDataConfigToQLi.get(reco.QUOTE_LINE_ITEM__C) ;	
				conID= reco.PM_SELECTED_TUBES_CONFIG__C;			
			}else{
				reco.PM_SELECTED_DIPSENSING_CONFIG__C = mapMockDataConfigToQLi.get(reco.QUOTE_LINE_ITEM__C) ;
				conID= reco.PM_SELECTED_DIPSENSING_CONFIG__C;
			} 
			 
			//update the ext id
			reco.UNIQUE_KEY__C =conID +'_'+ reco.MOQ__C;
			liPriceRecoToUpdate.add(reco);
		}
		update liPriceRecoToUpdate;	
		TriggerHandler.clearBypass('PMSelectedDipsensingconfigTriggerHandler');
		TriggerHandler.clearBypass('PMSelectedTubesConfigTriggerHandler');

	}//end create test data
	/*********************************************/
	 
	 static testMethod void handleCalculatorDispensing_TestEULP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'EU\' and Quote_Product_Segment__c =\'Lotion pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispEULotion')   ;
    }
    
    static testMethod void handleCalculatorDispensing_TestEUFM() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'EU\' and Quote_Product_Segment__c =\'Fine mist pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispEUFinemist') ;
    }
	
	static testMethod void handleCalculatorDispensing_TestEUFP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'EU\' and Quote_Product_Segment__c =\'Foam pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispEUFoam') ;
    }
    
    static testMethod void handleCalculatorDispensing_TestEUSP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'EU\' and Quote_Product_Segment__c =\'Sampler pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispEUSampler') ;
    }
    
    static testMethod void handleCalculatorDispensing_TestUSLP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'US\' and Quote_Product_Segment__c =\'Lotion pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispUSLotion')   ;
    }
    
    static testMethod void handleCalculatorDispensing_TestUSFM() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'US\' and Quote_Product_Segment__c =\'Fine mist pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispUSFinemist') ;
    }
	
	static testMethod void handleCalculatorDispensing_TestUSFP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'US\' and Quote_Product_Segment__c =\'Foam pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispUSFoam') ;
    }
    
    static testMethod void handleCalculatorDispensing_TestUSSP() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c where location__c =\'US\' and Quote_Product_Segment__c =\'Sampler pumps\' limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculatorDispensing(dispensingConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'DispUSSampler') ;
    }
    
    static testMethod void calculateSKONTO_Test() {
        test.startTest();
    	system.assertEquals(0,PMCalculatorUtility.calculateSKONTO('Espagne','1%'));//negative test
	    system.assertEquals(0.01,PMCalculatorUtility.calculateSKONTO('France','1 %'));//test 0.01
	    system.assertEquals(0.02,PMCalculatorUtility.calculateSKONTO('France','2 %'));//test 0.02
	    system.assertEquals(0.03,PMCalculatorUtility.calculateSKONTO('France','3 %'));//test 0.03
	    system.assertEquals(0,PMCalculatorUtility.calculateSKONTO('France','NO'));//test NO
	    test.stopTest();
    }
    
    static testMethod void calculateMultiplicationOfTwoLists_Test() {
    	list<PM_Price_Detail__c> liste1 = [select moq_min__c,moq_max__c,list_price__c from PM_Price_Detail__c limit 2];
    	list<PM_Price_Detail__c> liste2 = [select moq_min__c,moq_max__c,list_price__c from PM_Price_Detail__c limit 2];
		list<PM_Price_Detail__c> liste3 = new list<PM_Price_Detail__c>();
		
		//TODO : complete logique of multiplication
		
    	system.assertEquals(2,PMCalculatorUtility.calculateMultiplicationOfTwoLists(liste1,liste2).size());	
    }

    static testMethod void getPMTubesPricingReferenceByProductSegment_Test() {
        PM_Tubes_Pricing__c pr1 = new PM_Tubes_Pricing__c(X10__c=10.00, Version__c=1.0, Location__c='EU', Tubes_Segments__c='Laminate', valid_from__c = Date.today(), valid_to__c = Date.today());
        PM_Tubes_Pricing__c pr2 = new PM_Tubes_Pricing__c(X10__c=20.00, Version__c=1.0, Location__c='US', Ref__c='reference_tube', Tubes_Segments__c='Laminate',  valid_from__c = Date.today(), valid_to__c = Date.today());
        insert pr1;
        insert pr2;

        test.startTest();

        Map <String, PM_Tubes_Pricing__c> map1 = new Map <String, PM_Tubes_Pricing__c>();
        map1.put('', pr1);
        Map <String, PM_Tubes_Pricing__c> map2 = new Map <String, PM_Tubes_Pricing__c>();
        map2.put('REFERENCE_TUBE', pr2);
        
    	system.assertNotEquals(map1,PMCalculatorUtility.getPMTubesPricingReference('EU','Laminate', Date.today()));
	    system.assertNotEquals(map2,PMCalculatorUtility.getPMTubesPricingReference('US','Laminate', Date.today()));
	    test.stopTest();
    }

    static testMethod void getPMDispensingPricingReferenceProductSegment_Test() {
        PM_Dispensing_Pricing__c pr1 = new PM_Dispensing_Pricing__c(X10__c=10.00, Version__c=1.0, Location__c='EU', Product_Segment__c='Sampler pumps', valid_to__c = Date.today(), valid_from__c = Date.today());
        PM_Dispensing_Pricing__c pr2 = new PM_Dispensing_Pricing__c(X10__c=20.00, Version__c=1.0, Location__c='US', Ref__c='reference_disp', Product_Segment__c='Sampler pumps', valid_to__c = Date.today(), valid_from__c = Date.today());
        insert pr1;
        insert pr2;

        test.startTest();

        Map <String, PM_Dispensing_Pricing__c> map1 = new Map <String, PM_Dispensing_Pricing__c>();
        map1.put('', pr1);
        Map <String, PM_Dispensing_Pricing__c> map2 = new Map <String, PM_Dispensing_Pricing__c>();
        map2.put('REFERENCE_DISP', pr2);
        
    	system.assertNotEquals(map1,PMCalculatorUtility.getPMDispensingPricingReference('EU','Sampler', Date.today(), false, true));
	    system.assertNotEquals(map2,PMCalculatorUtility.getPMDispensingPricingReference('US','Sampler', Date.today(), false, true));
	    test.stopTest();
    } 

    static testMethod void getLineDetails_Test() {
        string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_config__c limit 1 ';
            
        PM_Selected_Tubes_config__c tubeConfig  = Database.query(query);

        PM_Tubes_Pricing__c pr1 = new PM_Tubes_Pricing__c(X5__c=10.00, Version__c=1.0, Location__c='EU', Tubes_Segments__c='Laminate');
        insert pr1;

      	Test.startTest();
      		System.assertEquals(10,PMCalculatorUtility.getLineDetails(tubeConfig, pr1, 'OTHER', 'TEST')[0].list_price__c);
      		System.assertEquals(0,PMCalculatorUtility.getLineDetails(tubeConfig, null, 'OTHER', 'TEST')[0].list_price__c);
      		System.assertEquals(10,PMCalculatorUtility.getUSLineDetails(tubeConfig, pr1, 'OTHER', 'TEST')[0].list_price__c);
      		System.assertEquals(0,PMCalculatorUtility.getUSLineDetails(tubeConfig, null, 'OTHER', 'TEST')[0].list_price__c);
      	Test.stopTest();      	
     	
    }

    static testMethod void roundListPrice_Test() {
        List<PM_Price_Detail__c> listPMPD = [Select id, List_Price__c from PM_Price_Detail__c limit 1];        

      	Test.startTest();
      		listPMPD[0].list_price__c = 3.6;
      		System.assertEquals(3,PMCalculatorUtility.roundDownListPrice(listPMPD)[0].list_price__c);
      		listPMPD[0].list_price__c = 3.6;
      		System.assertEquals(4,PMCalculatorUtility.roundListPrice(listPMPD)[0].list_price__c);
      	Test.stopTest();      	
     	
    }

    static testMethod void calcGroup_Test() {
        string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_config__c limit 1 ';
            
        PM_Selected_Tubes_config__c tubeConfig  = Database.query(query);
        PM_Price_Detail__c pr0 = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Price_Override__c=1000, Name='Metric', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        upsert pr0;
        PM_Price_Detail__c pr0bis = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Price_Override__c=1000, Name='MetricOver', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        upsert pr0bis;

        PM_Price_Detail__c pr1 = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Name='Metric', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        PM_Price_Detail__c pr2 = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Name='Metric2', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=500);
        PM_Price_Detail__c pr3 = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Name='Metric3', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=500);

        List<PM_Price_Detail__c> lstDetails = new List<PM_Price_Detail__c>();

        lstDetails.add(pr1);
        lstDetails.add(pr2);
        lstDetails.add(pr3);

        PM_Price_Detail__c prexpected = new PM_Price_Detail__c(PM_Selected_Tubes_Config__c=tubeconfig.id, Name='TEST', Section__c='OTHER', moq_min__c=10, moq_max__c=25, list_price__c=300, Quote_item__c=tubeconfig.quote_item__c);

      	Test.startTest();
      		System.assertEquals(prexpected.MOQ_Min__c,PMCalculatorUtility.calcgroupOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, tubeconfig, 0.1, 'OTHER', 'TEST')[0].MOQ_Min__c);
      		System.assertEquals(prexpected.MOQ_Max__c,PMCalculatorUtility.calcgroupOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, tubeconfig, 0.1, 'OTHER', 'TEST')[0].MOQ_Max__c);
      		System.assertEquals(prexpected.Section__c,PMCalculatorUtility.calcgroupOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, tubeconfig, 0.1, 'OTHER', 'TEST')[0].Section__c);
      		System.assertEquals(prexpected.Name,PMCalculatorUtility.calcgroupOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, tubeconfig, 0.1, 'OTHER', 'TEST')[0].Name);
      		System.assertEquals(prexpected.List_Price__c,PMCalculatorUtility.calcgroupOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, tubeconfig, 0.1, 'OTHER', 'TEST')[0].List_price__c);
      	Test.stopTest();      	
     	

    }

    static testMethod void calcGroupDispensing_Test() {
        string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Dipsensing_config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Dipsensing_config__c limit 1 ';
            
        PM_Selected_Dipsensing_config__c dispensingConfig  = Database.query(query);
        PM_Price_Detail__c pr0 = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Price_Override__c=1000, Name='Metric', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        upsert pr0;
        PM_Price_Detail__c pr0bis = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Price_Override__c=1000, Name='MetricOver', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        upsert pr0bis;

        PM_Price_Detail__c pr1 = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Name='Metric', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=10);
        PM_Price_Detail__c pr2 = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Name='Metric2', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=500);
        PM_Price_Detail__c pr3 = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Name='Metric3', Section__c='Main', moq_min__c=10, moq_max__c=25, list_price__c=500);

        List<PM_Price_Detail__c> lstDetails = new List<PM_Price_Detail__c>();

        lstDetails.add(pr1);
        lstDetails.add(pr2);
        lstDetails.add(pr3);

        PM_Price_Detail__c prexpected = new PM_Price_Detail__c(PM_Selected_Dipsensing_config__c=dispensingConfig.id, Name='TEST', Section__c='OTHER', moq_min__c=10, moq_max__c=25, list_price__c=300, Quote_item__c=dispensingConfig.quote_item__c);

      	Test.startTest();
      		System.assertEquals(prexpected.MOQ_Min__c,PMCalculatorUtility.calcgroupDispensingOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, dispensingConfig, 0.1, 'OTHER', 'TEST')[0].MOQ_Min__c);
      		System.assertEquals(prexpected.MOQ_Max__c,PMCalculatorUtility.calcgroupDispensingOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, dispensingConfig, 0.1, 'OTHER', 'TEST')[0].MOQ_Max__c);
      		System.assertEquals(prexpected.Section__c,PMCalculatorUtility.calcgroupDispensingOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, dispensingConfig, 0.1, 'OTHER', 'TEST')[0].Section__c);
      		System.assertEquals(prexpected.Name,PMCalculatorUtility.calcgroupDispensingOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, dispensingConfig, 0.1, 'OTHER', 'TEST')[0].Name);
      		System.assertEquals(prexpected.List_Price__c,PMCalculatorUtility.calcgroupDispensingOther(lstDetails, new Set<String>{'APPLY_ZERO_PERCENT'}, dispensingConfig, 0.1, 'OTHER', 'TEST')[0].List_price__c);
      	Test.stopTest();      	
     	

    }

    static testMethod void setSpecificPriceToZero_Test() {
        List<PM_Price_Detail__c> listPMPD = [Select id, List_Price__c from PM_Price_Detail__c limit 2];
        listPMPD[0].list_price__c = -1;
        listPMPD[1].list_price__c = 2;

      	Test.startTest();
      		System.assertEquals(0,PMCalculatorUtility.setSpecificPriceToZero(listPMPD)[0].list_price__c);
      		System.assertEquals(2,PMCalculatorUtility.setSpecificPriceToZero(listPMPD)[1].list_price__c);
      	Test.stopTest();      	
     	
    }

    static testMethod void setPriceMultiplier_Test() {
        List<PM_Price_Detail__c> listPMPD = [Select id, List_Price__c from PM_Price_Detail__c limit 2];
        listPMPD[0].list_price__c = 2;
        listPMPD[1].list_price__c = -1;

      	Test.startTest();
      		System.assertEquals(4,PMCalculatorUtility.setPriceMultiplier(listPMPD,2)[0].list_price__c);
      		System.assertEquals(-1,PMCalculatorUtility.setPriceMultiplier(listPMPD,2)[1].list_price__c);
      	Test.stopTest();
     	
    }

    static testMethod void handleCalculator_TestEUPL() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_Config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_Config__c where location__c =\'EU\' and Product_segment__c =\'Plastic Tubes\' limit 1 ';
            
        PM_Selected_Tubes_Config__c tubeConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculator(tubeConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'TubeEUPlastic') ;
    }

    static testMethod void handleCalculator_TestEULA() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_Config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_Config__c where location__c =\'EU\' and Product_segment__c =\'Laminate Tubes\' limit 1 ';
            
        PM_Selected_Tubes_Config__c tubeConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculator(tubeConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'TubeEULaminate') ;
    }

    static testMethod void handleCalculator_TestUSPL() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_Config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_Config__c where location__c =\'US\' and Product_segment__c =\'Plastic Tubes\' limit 1 ';
            
        PM_Selected_Tubes_Config__c tubeConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculator(tubeConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'TubeUSPlastic') ;
    }

    static testMethod void handleCalculator_TestUSLA() {
	 	string query  = '';
	 	 Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.PM_Selected_Tubes_Config__c.fields.getMap();
            for (String fieldName: schemaFieldMap.keySet()) {
                    query  += (query == '')? 'Select ' + fieldName : ', ' + fieldName;
            }
            query += ' FROM PM_Selected_Tubes_Config__c where location__c =\'US\' and Product_segment__c =\'Laminate Tubes\' limit 1 ';
            
        PM_Selected_Tubes_Config__c tubeConfig  = Database.query(query);
            
      	Test.startTest();
      		PMCalculatorUtility.handleCalculator(tubeConfig);       		
      	Test.stopTest();
       	
     	System.assertEquals(PMCalculatorUtility.runningConstructor,'TubeUSLaminate') ;
    }
    


        
	/*
	 static testMethod void handleCalculator_Test() {
        // TO DO: implement unit test
        
    }
    
   

    static testMethod void calculateTotalMOQPRice_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMTubesPricingReferenceByProductSegment_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMDispensingPricing_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMDispensingPricingReference_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMDispensingPricingReferenceProductSegment_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMDispensingPricingReferenceProductSegmentOrder_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getPMPricingVersion_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getLineDetails_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void getUSLineDetails_Test() {
        // TO DO: implement unit test
        
    }
    static testMethod void setListPrice_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void roundDownListPrice_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void calcGroup_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void calcGroupDispensing_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void setSpecificPriceToZero_Test() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void setPriceMultiplier_Test() {
        // TO DO: implement unit test
        
    }
    
  
  */  
   
}