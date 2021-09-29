@isTest
public class QuoteLineItemService_Test {

    @testSetup 
    private static void init() {

        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1000));
        User u1 = TestFactory.newKamUser(12341);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        u1.By_Pass_VR__c = true;
        stUsers.add(u1);
        User u2 = TestFactory.newKamUser(43211);
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
           
        productNames.add('Plastic Tubes');
        productNames.add('Laminate Tubes');
        
        
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
        acc1.Customer_Type__c='Brand Owner';
        acc1.Payment_terms__c='60 days';
        acc1.Business_at_other_product_line__c ='Yes';
        acc1.Customer_Group__c = 'a0C0Y000001oGdgUAE';
        insert acc1;

        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = u1.Id;
        insert opp1;

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = u1.Id;
        insert quote1;

        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        insert qli1;
        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        insert qli2;
 
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
        
        // test copy custom scoring 
        
         //test.startTest();
        List<QuoteLineItem> listNewQLI = new List<QuoteLineItem>();
       qli2.Brand_Positionning__c='Mass Market';
        qli2.Location__c='EU';
        qli2.isPriceMatrix__c=True;
        listNewQLI.add(qli2);
        qli1.Location__c='US';
        qli1.isPriceMatrix__c=True;
        listNewQLI.add(qli1);
        /*
                || relatedQuotes.get(qli.QuoteId).Brand_Positionning__c != null
                */
        QuoteLineItemService.copyCustomerScoringFromAccount(listNewQLI);
        QuoteLineItemService.createPMReviewPerMoqRecords(listNewQLI);
        QuoteLineItemService.createPMReviewRecords(2, qli2.id);
        // System.assert(result.size() == 0);
       // test.stopTest();
    }
 @isTest
    static void transcoPlantNameTest(){

        system.assertEquals('HG', QuoteLineItemService.getInstance().transcoPlantName('Hong Kong PC'));
        system.assertEquals('', QuoteLineItemService.getInstance().transcoPlantName('testStr'));

    }
    
    @isTest
    static void getQuoteLineItemByIdsTest() {

        QuoteLineItem qli = [
            Select Quantity
            From QuoteLineItem
            Limit 1
        ];

        system.assertEquals(qli.Quantity, QuoteLineItemService.getInstance().getQuoteLineItemByIds(new Set<Id> {qli.Id}).get(qli.Id).Quantity);

    }
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
     @isTest
    static void deleteQuoteTest() {
    
        QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
        
        PM_Price_Detail__c priceDetail = new PM_Price_Detail__c(Quote_item__c = qli.id);
        insert priceDetail;
    	
        String configId = priceDetail.id;
        
        test.startTest();
        delete qli;
        List<PM_Price_Detail__c> result = [select id from PM_Price_Detail__c where id =: configId];
        System.assert(result.size() == 0);
        test.stopTest();
    }
}