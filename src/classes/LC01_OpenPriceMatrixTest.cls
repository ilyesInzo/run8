@isTest
public class LC01_OpenPriceMatrixTest {
    public static testmethod void testdisplayComponent(){
        //create Accounts
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
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
        insert acc;
                        
        //create opportunities
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today()-1);
        insert opp;
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        	Name = 'Fine mist pumps'
      	);
      	insert subProd;
        
        //create products
        Product2 prod = new Product2(Name = 'Fine mist pumps', isActive=true,Family = 'Dispensing', Product_Sub_Segment__c = subProd.Id);
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', isActive=true,Family = 'Tube', Product_Sub_Segment__c = subProd.Id);
        insert prod2;
            
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert pbe;
        
        //create quotes
        Quote q = new Quote(Total_Sales__c=1,pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(),First_Delivery_Date__c=Date.today());
        insert q;
        
       /* Opportunity op = [select id, syncedQuoteId,Total_Amount__c from opportunity where id = :opp.id];
        op.SyncedQuoteId =  q.Id;
        update op;
        */     
        //create QuoteLineItems
        quotelineitem qli = new Quotelineitem(ID_Calculette__c='XX',Sales_price_per_1000_KCur__c=10,Tooling_sales_price_k_Cur__c=10,QuoteId= q.id, PricebookEntryId=pbe.id,Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',Product2ID=prod.id ,Quantity=20, UnitPrice=10, Ref_RFQ__c = 'Test' 
                                             ,Location__c='EU');
        insert qli;
        
        Test.startTest();
        qli = [Select id, Product_sub_segment__c, ID_Calculette__c from QuoteLineItem where id = :qli.id limit 1];
        
        boolean result = LC01_OpenPriceMatrix.displayComponent(qli.id);
        list<boolean> result2 = LC01_OpenPriceMatrix.displayCurrencyError(qli.id);
        QuoteLineItem result3 = LC01_OpenPriceMatrix.getQuoteItemRecord(qli.id);
        LC01_OpenPriceMatrix.setIDRFQ(qli.id);
        
        System.assertEquals(result, true);    
        System.assertEquals(result2[1], true);    
        System.assertNotEquals(result3, null); 
        System.assertEquals(qli.ID_Calculette__c, 'XX'); 
        //added by Amira 
        LC01_OpenPriceMatrix.getTubeEU(qli.id);
        Test.stopTest();
        
    }
}