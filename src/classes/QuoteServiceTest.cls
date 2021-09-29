/**
* Test class of QuoteService
*
* @author MDK
* @date 23/11/2017
* @description The aim of this class is to test :
*    - all QuoteService methods
*    - all QuoteLineItemService methods
*/
@isTest
private class QuoteServiceTest {

    private static final Integer TEST_SIZE = 2;

    @testSetup 
    private static void init() {

        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1000));
        User u1 = TestFactory.newKamUser(1234);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        u1.By_Pass_VR__c = true;
        stUsers.add(u1);
        User u2 = TestFactory.newKamUser(4321);
        u2.Bypass_trigger__c = '';
        u1.By_Pass_VR__c = true;
        stUsers.add(u2);
        insert stUsers;

        insert TestFactory.newUser('System Administrator', 1);

        //List<Country__c> countries = TestFactory.newCountry();
        //insert countries;
        // Added by Achraf
        Country__c frCountry = TestFactory.getFrance();
        insert frCountry;
        
        Distribution_Channel__c distChannel = TestFactory.newDistributionChannel();
        insert distChannel;
        
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE','FR');
        state.Country__c = frCountry.id; // Added by Achraf
        insert state;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < TEST_SIZE; i++) {
            productNames.add('name'+i);
        }
        List<Product2> products = TestFactory.newProducts(productNames);
        insert products;

        Id priceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Product2 p : products) {
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = priceBookId, 
                Product2Id = p.Id,
                UnitPrice = 100, 
                IsActive = true);
            pbEntries.add(standardPrice);
        }
        insert pbEntries;

        Account acc1 = TestFactory.newAccount(frCountry.id,distChannel.Id,salesArea.Id, state.Id);
        acc1.Street__c = 'Cartault';
        insert acc1;

        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = u1.Id;
        insert opp1;

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = u1.Id;
        insert quote1;

        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        insert qli1;

        Opportunity opp2 = TestFactory.newOpportunity('Opp2', 'Qualification', null, null, acc1.Id);
        opp2.OwnerId = u2.Id;
        insert opp2;

        Quote quote2 = TestFactory.newQuote(null, Date.today(), 'Draft', opp2.Id);
        quote2.OwnerId = u2.Id;
        quote2.RFQ_Reception_Date__c = Date.today();
        insert quote2;
 
        Sales_Team__c st = TestFactory.newSalesTeam(stUsers[3].Id, stUsers[0].Id, stUsers[1].Id, stUsers[2].Id);
        insert st;

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for(Product2 prod : products) {
            Sales_Allocations__c sa = new Sales_Allocations__c(
                account__c              = acc1.id,
                product_sub_segment__c  = prod.id,
                sales_team__c           = st.id,
                Valid_To__c             = SalesService.FUTURE_DATE
            );
            sas.add(sa);            
        }   
        //insert sas;       
        
    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void transcoPlantNameTest(){

        system.assertEquals('HG', QuoteLineItemService.getInstance().transcoPlantName('Hong Kong PC'));
        system.assertEquals('', QuoteLineItemService.getInstance().transcoPlantName('testStr'));

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void getQuoteLineItemByIdsTest() {

        QuoteLineItem qli = [
            Select Quantity
            From QuoteLineItem
            Limit 1
        ];

        system.assertEquals(qli.Quantity, QuoteLineItemService.getInstance().getQuoteLineItemByIds(new Set<Id> {qli.Id}).get(qli.Id).Quantity);

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void getQuotesInfoTest() {

        Quote q = [
            Select Name
            From Quote
            Limit 1
        ];

        system.assertEquals(q.Name, QuoteService.getQuotesInfo(new Set<Id> {q.Id}).get(q.Id).Name);

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void getQuoteLineItemsInfoTest() {

        QuoteLineItem qli = [
            Select Quantity, QuoteId
            From QuoteLineItem
            Limit 1
        ];

        for (QuoteLineItem qliInfo : QuoteService.getQuoteLineItemsInfo(new Set<Id> {qli.QuoteId}).get(qli.QuoteId)) {
            if (qliInfo.Id == qli.Id) {
                system.assertEquals(qli.Quantity, qliInfo.Quantity);
            }            
        }
        

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void setQuoteLineItemsTest() {

        User kamUser1 = [
            Select Id, FirstName, Bypass_trigger__c
            From User
            Where Matricule_ADS__c = '1234'
        ];

        User kamUser2 = [
            Select Id, FirstName, Bypass_trigger__c
            From User
            Where Matricule_ADS__c = '4321'
        ];

        Quote quote1 = [
            Select Id 
            From Quote 
            Where OwnerId = :kamUser1.Id
        ];

        Quote quote2 = [
            Select Id 
            From Quote 
            Where OwnerId = :kamUser2.Id
        ];

        List<Product2> products = [
            Select Id
            From Product2
        ];

        Map<Object, SObject> pbEntrieIdByProductId = SObjectUtils.toMap([Select Id,Product2Id From PricebookEntry],'Product2Id');



        Test.startTest();
        // Test with user who bypasses the Sales Allocation Error
        System.runAs(kamUser1){
            System.debug(LoggingLevel.ERROR,'Current User: ' + UserInfo.getUserName());
            System.debug(LoggingLevel.ERROR,'Current Profile: ' + UserInfo.getProfileId());
            System.debug(LoggingLevel.ERROR,'Bypass_trigger__c = ' + kamUser1.Bypass_trigger__c);

            quote1.Brand_Positionning__c = 'Mass Market';
            update quote1;

            List<QuoteLineItem> qlis = new List<QuoteLineItem>();
            for(Integer i = 1; i < TEST_SIZE; i++) {
                QuoteLineItem qli = TestFactory.newQuoteLineItem(quote1.Id, products[i].Id, pbEntrieIdByProductId.get(products[i].Id).Id);
                qlis.add(qli);
            }
            insert qlis;

            for (QuoteLineItem qli : [
                Select Brand_Positionning__c, Product2Id
                From QuoteLineItem 
            ]) {
                if (qli.Product2Id == products[0].Id) {
                    System.assertEquals(quote1.Brand_Positionning__c, qli.Brand_Positionning__c);
                } else {
                    System.assertEquals(quote1.Brand_Positionning__c, qli.Brand_Positionning__c);
                }                
            }                          


            // Test with user who does not bypass the Sales Allocation Error
            System.runAs(kamUser2){
                System.debug(LoggingLevel.ERROR,'Current User: ' + UserInfo.getUserName());
                System.debug(LoggingLevel.ERROR,'Current Profile: ' + UserInfo.getProfileId());
                System.debug(LoggingLevel.ERROR,'Bypass_trigger__c = ' + kamUser2.Bypass_trigger__c);
                
                // Reset the Global variable bypassedTriggers. In the real life we should have one Context
                // per user so one Global variable per user.
                TriggerHandler.bypassedTriggers = new Set<String> {''};
               
                try {
                    QuoteLineItem qliWithError = TestFactory.newQuoteLineItem (quote2.Id, products[0].Id, pbEntrieIdByProductId.get(products[0].Id).Id);
                    insert qliWithError;
                } catch (DmlException e) {  
                    System.assertEquals(e.getMessage().contains(System.label.QUOTELINEITEM_SALESALLOCATION_ERRMSG),true);
                }
            }
        }
        Test.stopTest();
        

    }

    /**
     * @description 
     * @param 
     * @return 
     */
    @isTest
    static void setQuotesTest() {

        User kamUser = [
            Select Id, FirstName
            From User
            Where Matricule_ADS__c = '1234'
        ];

        Opportunity opp = [
            Select Total_Sales_Value_k__c 
            From Opportunity 
            Limit 1
        ];

        Quote q = [
            Select Total_Sales_Value_ks__c, IsSyncing 
            From Quote 
            Limit 1
        ];

        List<Product2> products = [
            Select Id
            From Product2
        ];

        Map<Object, SObject> pbEntrieIdByProductId = SObjectUtils.toMap([Select Id,Product2Id From PricebookEntry],'Product2Id');

        Test.startTest();
        System.runAs(kamUser){

            QuoteLineItem qliWithoutProdPlant = TestFactory.newQuoteLineItem (q.Id, products[0].Id, pbEntrieIdByProductId.get(products[0].Id).Id,'','');
            qliWithoutProdPlant.Billing_Currency__c = 'American dollar';
            qliWithoutProdPlant.Sales_price_per_1000_KCur__c = 2;
            qliWithoutProdPlant.Ref_RFQ__c  = 'myRef';               
            insert qliWithoutProdPlant;

            // To calculate the Total Quantity we need to synchronize the Opportunity
            opp.SyncedQuoteId = q.Id;
            opp.CloseDate = Date.Today();
            update opp;

            System.debug(LoggingLevel.ERROR,'Total Sales Value Quote = '+q.Total_Sales_Value_ks__c+' IsSyncing = '+q.IsSyncing);
            System.debug(LoggingLevel.ERROR,'Total Sales Value Oppty = '+opp.Total_Sales_Value_k__c);

            try {
                q.RFQ_Reception_Date__c = Date.today();
                q.Status = 'Presented';
                q.First_Delivery_Date__c = Date.today();
                update q;
            } catch (DmlException e) {
                System.assertEquals(e.getMessage().contains('Production cluster and Plant are mandatory on'),true);
            }

            // Test if Tech_Error_Process__c is reseted
            kamUser.By_Pass_VR__c = true;
            update kamUser;

            q.RFQ_Reception_Date__c = Date.today();
            q.Status = 'Presented';
            update q;

            Quote quoteError = [
                Select Tech_Error_Process__c 
                From Quote
                Where Id = :q.Id
            ];

            System.debug(LoggingLevel.ERROR,'Tech Error Process = '+quoteError.Tech_Error_Process__c);
            //System.assertEquals('ERROR',quoteError.Tech_Error_Process__c);

            kamUser.By_Pass_VR__c = true;
            update kamUser;

            qliWithoutProdPlant.Production_Plant__c = 'Baddi';
            qliWithoutProdPlant.Production_Cluster__c = 'Beauty Solutions';
            qliWithoutProdPlant.Based_on_Alb_a_Concept__c = '';
            update qliWithoutProdPlant;

			q.RFQ_Reception_Date__c = Date.today();
            q.Status = 'Presented';
            update q;
			
            quoteError = [
                Select Tech_Error_Process__c 
                From Quote
                Where Id = :q.Id
            ];

            System.assertNotEquals(quoteError.Tech_Error_Process__c,'ERROR');
            // End test reset field


        }
        Test.stopTest();


    }

    /**
     * @description Test LC01_QuoteLineItemsRelatedListController.getQuoteLineItemsCtrlTest
     * @param 
     * @return 
     */
    @isTest
    static void getQuoteLineItemsCtrlTest() {
        QuoteLineItem qli1 = [
            Select Id,QuoteId From QuoteLineItem Limit 1
        ];

        List<QuoteLineItem> qlis = LC01_QuoteLineItemsRelatedListController.getQuoteLineItems(qli1.QuoteId);

        System.assertEquals(qli1.Id,qlis[0].Id);
    }
    
    
        /**
     * @description Testing QuoteService.checkCLIisPricematrix
     * @param 
     * @return 
     */
    @isTest
    static void checkCLIisPricematrixTest() {
    	
    	 //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FX');
        insert country;

        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        acc.Account_ext_Id__c = TestFactory.generateCodeVAT(10);
        insert acc;
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        acc2.Account_ext_Id__c = TestFactory.generateCodeVAT(10);
        insert acc2;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', 
                                          CloseDate = Date.today());
        insert opp;
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        	Name = 'Lotion pumps'
      	);
      	insert subProd;
        
        
        Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Bottle',
                                     isActive = true, Product_Sub_Segment__c = subProd.Id);
        
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Lotion pumps', 
                                     Family = 'Tubes',
                                     isActive= true, Product_Sub_Segment__c = subProd.Id);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true, UseStandardPrice=false);
        insert standardPrice;
        //standardPrice.UseStandardPrice
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 5000, IsActive = true, UseStandardPrice=false);
        insert standardPrice2;
        
        //Insert productSegmentGlobalConfigs
		PM_Global_Config__c productSegmentGlobalConfigs = new  PM_Global_Config__c();
		productSegmentGlobalConfigs.Table_name__c = 'Access to PricematriX by PL,zone, country';
		productSegmentGlobalConfigs.Product_Segment__c = 'Lotion pumps';
		productSegmentGlobalConfigs.Location__c = 'EU';
		productSegmentGlobalConfigs.Country_code__c = 'FX';
		productSegmentGlobalConfigs.Product_Line_Dispensing__c ='PricematriX Europe';
		productSegmentGlobalConfigs.PricematriX_used_for_P0__c = false;
		productSegmentGlobalConfigs.Product_Line_Tubes__c ='PricematriX Europe';
  
  		insert productSegmentGlobalConfigs;

        //Insert productSegmentGlobalConfigs
		PM_Global_Config__c productSegmentGlobalConfigs2 = new  PM_Global_Config__c();
		productSegmentGlobalConfigs2.Table_name__c = 'Access to PricematriX by PL,zone, country';
		productSegmentGlobalConfigs2.Product_Segment__c = 'Foam pumps';
		productSegmentGlobalConfigs2.Location__c = 'EU';
		productSegmentGlobalConfigs2.Country_code__c = 'FX';
		productSegmentGlobalConfigs2.Product_Line_Dispensing__c ='PricematriX Europe';
		productSegmentGlobalConfigs2.PricematriX_used_for_P1__c = true;
		productSegmentGlobalConfigs2.Product_Line_Tubes__c ='PricematriX Europe';
		  
  		insert productSegmentGlobalConfigs2; 
  		
  		// With the configs added above the accessMap used in QuoteService.checkCLIisPricematrix will have these values {FX_Dispensing_P1=true, FX_Tubes_P1=true}
       
        Test.startTest();
        Opportunity opp1 = new Opportunity(
                Name = 'Test Opp 1', 
                AccountId = acc.Id, 
                StageName = 'Qualification', 
                CloseDate = Date.today()-1
            );
    	insert opp1;    	
        
    	Quote q = new Quote(
            Pricebook2Id = PricebookId, 
            Name = 'Test Quote 1', 
            OpportunityId = opp1.Id,
            Project_TYpe__c ='P0', 
            RFQ_Reception_Date__c = Date.today()
        );
    	insert q;
        
        QuoteLineItem qli = new QuoteLineItem( 
            UnitPrice = 12.0,
            Quantity = 100,
            Sales_price_per_1000_KCur__c = 2,
            Billing_Currency__c = 'American dollar',
            PricebookEntryId= standardPrice.id,
            Product2Id = prod2.id, 
            QuoteId = q.Id,
            Production_Cluster__c = 'Albea China',
            Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
        );
        insert qli;
        
		//we change the quote's project type to 'P1' --> the key generated in the method QuoteService.checkCLIisPricematrix for the qli 
	
        q.Project_TYpe__c ='P1';
        update q;
        QuoteLineItem updatedqli = [
            Select Id,isPriceMatrix__c From QuoteLineItem Where QuoteId = :q.Id Limit 1
        ];
        System.assertEquals(updatedqli.isPriceMatrix__c,false);
        
 		//we change the quote's project type to 'P2' --> the key generated in the method QuoteService.checkCLIisPricematrix for the qli 
 		// will be 'FX_Tubes_P0' --> doesn't exist in the accessMap --> isPriceMatrix__c should be false
        q.Project_TYpe__c ='P0';
        update q;
        QuoteLineItem updated2qli = [
            Select Id,isPriceMatrix__c From QuoteLineItem Where QuoteId = :q.Id Limit 1
        ];
        System.assertEquals(updated2qli.isPriceMatrix__c,false);
 		Test.stopTest();

    }
    
    /** @description Testing QuoteLineItemService.createPMReviewRecords **/
    @isTest 
    static void createPMReviewRecords_Test() {
    	Quotelineitem qli = [select id from quotelineitem limit 1];
    	list<PM_Review_NetPrice_per_MOQ__c> returnedRecords = new list<PM_Review_NetPrice_per_MOQ__c> ();
    	Test.startTest();    												
    		returnedRecords = QuoteLineItemService.createPMReviewRecords(3,qli.id);
    	Test.stopTest();
    	
    	//check that the methode returns 3 PM_Review_NetPrice_per_MOQ__c records  
    	System.assertEquals(returnedRecords.size() ,3);		
    }//end createPMReviewRecords_Test
    
    /** @description Testing QuoteLineItemService.createPMReviewPerMoqRecords **/
    @isTest 
    static void createPMReviewPerMoqRecords_Test() {
    	TriggerHandler.bypass('PMReviewNetPriceperMoqTriggerHandler');
    	List<Quotelineitem> qlis = [select id,isPriceMatrix__c from quotelineitem];
    	qlis[0].ispricematrix__c = true;
    	update qlis[0] ;
    	
    	list<PM_Review_NetPrice_per_MOQ__c> returnedRecords = new list<PM_Review_NetPrice_per_MOQ__c> ();
    	Test.startTest();    												
    		QuoteLineItemService.createPMReviewPerMoqRecords(qlis);
    	Test.stopTest();
    	
    	//check that the methode inserts 7 PM_Review_NetPrice_per_MOQ__c records  
    	System.assertEquals([SELECT Quote_Line_Item__c 
    										FROM PM_Review_NetPrice_per_MOQ__c 
    										where Quote_Line_Item__c = :qlis[0].id ].size(),7);		
    }//end createPMReviewRecords_Test
    
    /**
     * Author Achraf LAMZABI
     * @description Test of Quote Delete
     * @param 
     * @return 
     */
   /* @isTest
    static void deleteQuoteTest() {
    	user u = [select id, Name,Profile.name from user where Profile.Name != 'System Administrator' limit 1];
        Quote q = [select id, Name , Status from Quote limit 1];
        String quoteId = q.id;
        test.startTest();
        
        //System.runas(u){
        	delete q;
        	List<Quote> result = [select id,Name from Quote where id =: quoteId];
        	System.assert(result.size()>0);
        //}        
        
       // q.Status = 'Simulation';
       // update q;
        /*
        System.runas(u){
        	delete q;
        	List<Quote> result = [select id,Name from Quote where id =: quoteId];
        	System.assert(result.size()==0);
        }*/
        
        /*test.stopTest();
    
    }*/
}