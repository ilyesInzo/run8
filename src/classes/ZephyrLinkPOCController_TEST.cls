@isTest
public class ZephyrLinkPOCController_TEST {

        @isTest
        static void formatStringValueTest(){
            String nbr1 = '3,333,333.00';
            String nbr2 = '3.333.333,00';
            String nbr3 = '33,..3 33 3 3,00';            
            String nbr4 = '3333333.40';
            String nbr5 = '3.3  333,,330. 0';
            String nbr6 = '3.0';
            String nbr7 = '.00';
            String nbr8 = '4     3,333,5555....004321';
            String nbr9 = '4     3,333,5555....00432,1';
            String nbr10 = '12 00   0';
            // Max of 3 digits for the Decimal part
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr1,3,false),'3333333.00');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr2,3,false),'3333333.00');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr3,3,false),'3333333.00');
            // Integer part only boolean = true
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr4,3,true),'3333333');
            // Max of 3 digits for the Decimal part
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr5,3,false),'33333330.0');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr6,3,false),'30');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr7,3,false),'00');
            // Max of 7 digits for the Decimal part
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr8,7,false),'433335555.004321');
            // Max 3 digits for the Decimal part
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr8,3,false),'433335555004321');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr9,3,false),'43333555500432.1');
            // Test with an Integer
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr10,3,false),'12000');
            system.assertEquals(ZephyrLinkPOCController.formatStringValue(nbr10,3,true),'12000');                                                                                                
        }
		
    	static testmethod void testMethod1(){
    
        	//Create Test Data
        	Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
            insert country;
        	
            //Create Test Distribution Channel
            Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
            insert testDistrib;
            
            //Create Sales Area
            Sales_Area__c testArea = new Sales_Area__c(Name='Test');
            insert testArea;
                
            //Account acc = new Account(Name = 'Test Acc 1', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc = TestFactory.newAccount(country, testDistrib, testArea);
            insert acc;
            
            //Retrieve KAM PRofile
            Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];
            
            //Create Test Users for the Teams
            List<User> users = new List<User>();    
                
            for(integer i=1; i<=10; i++){
                String orgId = 'Albea';
                           
                User tuser = new User(  firstname = 'test',
                                        lastName = 'user'+i,
                                        email = 'test_user'+i+ '@test' + orgId + '.com',
                                        Username = 'test_user'+i+ '@test' + orgId + '.com',
                                        EmailEncodingKey = 'ISO-8859-1',
                                        Alias = 'test'+i,
                                        TimeZoneSidKey = 'America/Los_Angeles',
                                        LocaleSidKey = 'en_US',
                                        LanguageLocaleKey = 'en_US',
                                        Additional__c = true,
                                        Director__c = true,
                                        KAM__c = true,
                                        Matricule_ADS__c = string.valueof(i+1000),
                                        Manager__c = true,
                                        ProfileId = KAM.id);
                users.add(tuser);                               
            }
           
            insert users;  
                
            //Create Test Sales Teams
            Sales_Team__c team1 = new Sales_Team__c();
            team1.KAM__c = users[0].id;
            team1.Manager__c = users[1].id;
            team1.Director__c = users[2].id;
            team1.Additional__c = users[3].id;
            team1.Valid_From__c = Date.today().addYears(-1);
            team1.Valid_To__c = Date.today().addYears(3);
            team1.Sales_Team__c = 'test team 1';
            team1.Sales_Team__c = '1111';
            
            insert team1;
                
           
                
            //Get Standard Pricebook
        	Id pricebookId = Test.getStandardPricebookId();
                Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
     	);
      	insert subProd;
            Product2 prod = new Product2(Name = 'bottle 50ml', 
                                         Family = 'Bottle', Product_Sub_Segment__c = subProd.Id);
            insert prod;
            
        	
        
        	PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
                
             //Create Team Allocation 1
            Sales_Allocations__c alloc1 = new Sales_Allocations__c();
            alloc1.Account__c = acc.id;
            alloc1.Sales_Team__c = team1.id;
            alloc1.Product__c = 'BTL';
            alloc1.Product_Sub_Segment__c = prod.id;
            alloc1.Valid_From__c = Date.today().addYears(-2);
            alloc1.Valid_To__c = Date.today().addYears(1);
            
            insert alloc1;
        	
        	//added by maryem qada ==> because account and opportunity team members are no longer created synchronosly 
            List<Sales_allocations__c> allSalesAllocs = new list<SAles_allocations__c>();
            allSalesAllocs.add(alloc1);
            
            SalesTeamService.processAllocation(allSalesAllocs ,new Set<id>()); 
        	
            System.runAs(users[0]){
                
            Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
            insert opp;
        
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1',CSR__c = 'NO CSR', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today());
            insert q;
            
            
        
        	//Insert QLI
        	QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                                  Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test'
                                                  );
            insert qli;
            }
           
        	//Create test QLI Mappings
        	ZephyrLinkQLI__c map1  = new ZephyrLinkQLI__c();  
        	map1.Name = '0';
        	map1.QuoteLineItem_field__c = 'Ref_RFQ__c';
        	map1.Field_Type__c = 'Text';
        
        	insert map1;

    		ZephyrLinkQLI__c map2  = new ZephyrLinkQLI__c();
        	map2.Name = '1';
        	map2.QuoteLineItem_field__c = 'Minimum_Order_Quantity__c';
        	map2.Field_Type__c = 'Integer';
        
        	insert map2;  
            
            ZephyrLinkQLI__c map3  = new ZephyrLinkQLI__c();
        	map3.Name = '2';
        	map3.QuoteLineItem_field__c = 'CB0__c';
        	map3.Field_Type__c = 'Double';
        
        	insert map3; 
                
            ZephyrLinkQLI__c map4  = new ZephyrLinkQLI__c();
        	map4.Name = '3';
        	map4.QuoteLineItem_field__c = 'Quote.RFQ_Reception_Date__c';
        	map4.Field_Type__c = 'Date';
        
        	insert map4; 
        	
            ZephyrLinkQLI__c map5  = new ZephyrLinkQLI__c();
        	map5.Name = '4';
        	map5.QuoteLineItem_field__c = 'Opportunity.Probability';
        	map5.Field_Type__c = 'Double';
        
        	insert map5; 
        	
        	ZephyrLinkQLI__c map6  = new ZephyrLinkQLI__c();
        	map6.Name = '5';
        	map6.QuoteLineItem_field__c = 'Production_Plant__c';
        	map6.Field_Type__c = 'Text';
        
        	insert map6; 
        	
        	ZephyrLinkQLI__c map7  = new ZephyrLinkQLI__c();
        	map7.Name = '6';
        	map7.QuoteLineItem_field__c = 'Opportunity.CloseDate';
        	map7.Field_Type__c = 'Date';
        
        	insert map7; 
        
        	//Create Test Zephyr Link data
        	String testZepheyrLink ='TestRFQ1	10 000	2.5	2016-01-15	1.5	simandre	2016-01-15';
         	
         	QuoteLineItem qli = [select id from QuotelineItem limit 1];
                
        	String response = ZephyrLinkPOCController.readZephyrData(testZepheyrLink,qli.Id);        
            response = ZephyrLinkPOCController.readZephyrData(testZepheyrLink,qli.Id);
            System.assertEquals(Label.Linkforce_Success_Message,response);

            testZepheyrLink = 'INDIAPricematriXapril2017    TestRFQ1Skincare    2017-7-21   Retention   Laminate Tubes  Laminate Tubes  PGL 19.0    Screw S/XS Full Diameter';
            response = ZephyrLinkPOCController.readZephyrData(testZepheyrLink,qli.Id);
            system.assertEquals(Label.Linkforce_Error_Message,response);
            
            
                        
        }
}