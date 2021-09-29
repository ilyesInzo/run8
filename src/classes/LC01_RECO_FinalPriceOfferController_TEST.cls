@isTest
public class LC01_RECO_FinalPriceOfferController_TEST {
    
    static testmethod void testMethod1(){
        
        //String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
        
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test',Customer_Size__c='GA');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
        
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft');
        insert q;
        
        Product2 prod = new Product2(Name = 'Lotion pumps', 
                                     Family = 'Dispensing',	IsActive=true);
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                              Product2Id = prod.id, QuoteId = q.Id
                                             );
        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        insert qli;
        
        PM_MOQ_price__c testMOQPrice = New  PM_MOQ_price__c();
        
        testMOQPrice.Quote_item__c = qli.id;
        testMOQPrice.MOQ_Max__c = 50;
        testMOQPrice.MOQ_Min__c = 25;
        testMOQPrice.List_Price__c = 200.50;
        
        insert testMOQPrice;
        
        PM_Selected_Dipsensing_config__c selDC = new PM_Selected_Dipsensing_config__c(
            location__c = 'EU', 
            Product_segment__c = 'Lotion pumps', 
            Attachment__c = 'Snap On', 
            Actuator__c = 'Prodigio (Clean Point)',
            Engine_Name__c = 'Prodigio',
            Pack_Name__c= 'Prodigio',
            quote_item__c=qli.id);		
        
        insert selDC;
        
        //Final Price Offer Controller Test
        LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id);
        
        //Arthur Leriche : Test configOK, if Product Def Section, pump row is empty, configOK is false
        System.assertEquals(LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id).get('configOK'), false);
        
        PM_price_detail__c pdetail = new PM_price_detail__c();
        pdetail.Quote_item__c = qli.id;
        pdetail.Section__c = 'Product Definition';
        pdetail.MOQ_Min__c = 20;
        pdetail.MOQ_Max__c = 30;
        pdetail.List_Price__c = 10;
        pdetail.Name = 'Pump';

        insert pdetail;
        
        System.assertEquals(LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id).get('configOK'), true);
      
        PM_Review_NetPrice_per_MOQ__c testFinalReview = new PM_Review_NetPrice_per_MOQ__c();
        testFinalReview.Selected__c = true;
        testFinalReview.Quote_Line_Item__c = qli.id;
        
        insert testFinalReview;
        testFinalReview.Quoted_Price__c = 150;
        testFinalReview.MOQ_Units__c =30;
        // update testFinalReview;
        
        List<PM_Review_NetPrice_per_MOQ__c> reviewPrices = [
            Select Id,
            Selected__c,
            Quote_Line_Item__c,
            Quoted_Price__c , 
            MOQ_Units__c 
            From PM_Review_NetPrice_per_MOQ__c 
            Where Quote_Line_Item__c = :qli.Id  
        ];
        
        PM_Review_NetPrice_per_MOQ__c selected = LC01_RECO_FinalPriceOfferController.selected(reviewPrices);
       //System.assertEquals(reviewPrices[0].Quote_Line_Item__c, selected.Quote_Line_Item__c); method not used
        TriggerHandler.bypass('PMReviewNetPriceperMoqTriggerHandler');
        reviewPrices[0].Quoted_Price__c = 100;
        List<PM_Review_NetPrice_per_MOQ__c> reviewPricesUpdated = LC01_RECO_FinalPriceOfferController.updateFinalReviewPrices(reviewPrices);
        reviewPrices[0].MOQ_Units__c = null;
        LC01_RECO_FinalPriceOfferController.saveResult(reviewPrices);
        LC01_RECO_FinalPriceOfferController.selectFinalReview(reviewPrices, reviewPrices[0].Id);
       // System.assertEquals(100,reviewPricesUpdated[0].Quoted_Price__c);
        
        reviewPrices = LC01_RECO_FinalPriceOfferController.selectFinalReview(reviewPrices, testFinalReview.id);
        System.assertEquals(false,reviewPrices[0].Selected__c);
        
        Boolean display = LC01_OpenPriceMatrix.displaybuttonvalidation(qli.id);
        System.assertEquals(false,display);
        
        QuoteLineItem qli2 = LC01_OpenPriceMatrix.getQuoteItemRecord(qli.id);
        
    }
    
     static testmethod void testMethod2(){
        
        //String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
        
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test',Customer_Size__c='GA');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
        
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft');
        insert q;
        
        Product2 prod = new Product2(Name = 'Fine mist pumps', 
                                     Family = 'Dispensing',	IsActive=true);
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                              Product2Id = prod.id, QuoteId = q.Id
                                             );
        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        insert qli;
        
        PM_MOQ_price__c testMOQPrice = New  PM_MOQ_price__c();
        
        testMOQPrice.Quote_item__c = qli.id;
        testMOQPrice.MOQ_Max__c = 50;
        testMOQPrice.MOQ_Min__c = 25;
        testMOQPrice.List_Price__c = 200.50;
        
        insert testMOQPrice;
        
        PM_Selected_Dipsensing_config__c selDC = new PM_Selected_Dipsensing_config__c(
            location__c = 'EU', 
            Product_segment__c = 'Fine mist pumps', 
            Attachment__c = 'Snap On', 
            Actuator__c = 'Prodigio (Clean Point)',
            Engine_Name__c = 'Prodigio',
            Pack_Name__c= 'Prodigio',
            quote_item__c=qli.id);		
        
        insert selDC;
        
        //Final Price Offer Controller Test
        LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id);
        
        //Arthur Leriche : Test configOK, if Product Def Section, pump row is empty, configOK is false
        System.assertEquals(LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id).get('configOK'), false);
        
        PM_price_detail__c pdetail = new PM_price_detail__c();
        pdetail.Quote_item__c = qli.id;
        pdetail.Section__c = 'Product Definition';
        pdetail.MOQ_Min__c = 20;
        pdetail.MOQ_Max__c = 30;
        pdetail.List_Price__c = 10;
        pdetail.Name = 'Pump';

        insert pdetail;
        
        System.assertEquals(LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id).get('configOK'), true);
         
        PM_Review_NetPrice_per_MOQ__c testFinalReview = new PM_Review_NetPrice_per_MOQ__c();
        testFinalReview.Selected__c = true;
        testFinalReview.Quote_Line_Item__c = qli.id;
        testFinalReview.Quoted_Price__c = 150;
        testFinalReview.MOQ_Units__c =30;

		PM_Review_NetPrice_per_MOQ__c testFinalReview2 = new PM_Review_NetPrice_per_MOQ__c();
        testFinalReview2.Selected__c = true;
        testFinalReview2.Quote_Line_Item__c = qli.id;
        testFinalReview2.Quoted_Price__c = 180;
        testFinalReview2.MOQ_Units__c =60;

		insert new List<PM_Review_NetPrice_per_MOQ__c>{testFinalReview,testFinalReview2};
            
            testFinalReview2.MOQ_Units__c=100;
         	testFinalReview.MOQ_Units__c =null;
         	LC01_RECO_FinalPriceOfferController.saveResult(new List<PM_Review_NetPrice_per_MOQ__c>{testFinalReview2,testFinalReview});
        	
            List<PM_Review_NetPrice_per_MOQ__c> reviewPrices = [
            Select Id,
            Selected__c,
            Quote_Line_Item__c,
            Quoted_Price__c , 
            MOQ_Units__c 
            From PM_Review_NetPrice_per_MOQ__c 
            Where Quote_Line_Item__c = :qli.Id  
        ];
        
        System.assert(reviewPrices.size() > 0 ,reviewPrices);
        PM_Review_NetPrice_per_MOQ__c selected = LC01_RECO_FinalPriceOfferController.selected(reviewPrices);
        System.assert(selected.Quoted_Price__c == 180 ,selected);
    }
}