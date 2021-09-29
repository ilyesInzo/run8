@isTest
public class LC01_SimulatorButtons_TEST {
    
	public testmethod static void deleteConfigurationsTest1(){
    //Create Test Users for the Teams
            List<User> users = new List<User>();

            //Retrieve KAM PRofile
            Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];
    
        
            for(integer i=1; i<=10; i++){
                String orgId = 'Albea';
                           
                User tuser = TestFactory.newUser('test','user'+i, KAM.Name, true, true,true, true, i+1000);
               
                tuser.email = 'test_user'+i+ '@test' + orgId + '.com';
                tuser.Username = 'test_user'+i+ '@test' + orgId + '.com';
                tuser.EmailEncodingKey = 'ISO-8859-1';
                tuser.Alias = 'test'+i;
                tuser.TimeZoneSidKey = 'America/Los_Angeles';
                tuser.LocaleSidKey = 'en_US';
                tuser.LanguageLocaleKey = 'en_US';
                users.add(tuser);                               
            }
            
            users[0].ProfileId = KAM.id;
            users[0].by_pass_vr__c = true;
            users[4].ProfileId = KAM.id;
            insert users;
            	
            	Country__c frCountry = TestFactory.getFrance();
            	insert frCountry;
    
                //Create Distribution Channel
                Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
                insert distCountry1;
                
                //Create Sales Area
                Sales_Area__c salesArea = TestFactory.newSalesArea();
                insert salesArea;
    
                // Create a State
                State__c state = TestFactory.newState('FRANCE','FR');
            	state.Country__c = frCountry.id;
                insert state;
                
                //Create Test Accounts
    
                Account acc = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
            	acc.Street__c = 'Cartault';
                insert acc;
                
                Account acc2 = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
                acc2.Street__c = 'Cartault';
            	insert acc2;
                
                //Create Test Sales Teams
                Sales_Team__c team1 = new Sales_Team__c();
                team1.KAM__c = users[0].id;
                team1.Manager__c = users[1].id;
                team1.Director__c = users[2].id;
                //team1.Additional__c = users[3].id;
                team1.Valid_From__c = Date.today().addYears(-1);
                team1.Valid_To__c = Date.today().addYears(3);
                team1.Sales_Team__c = 'test team 1';
                
                insert team1;
                
                Sales_Team__c team2 = new Sales_Team__c();
                team2.KAM__c = users[4].id;
                team2.Manager__c = users[5].id;
                team2.Director__c = users[6].id;
                //team2.Additional__c = users[7].id;
                team2.Valid_From__c = Date.today().addYears(-1);
                team2.Valid_To__c = Date.today().addYears(3);
                team2.Sales_Team__c = 'test team 2';
                insert team2;
                
                
                //Get Standard Pricebook
                Id pricebookId = Test.getStandardPricebookId();
        		PriceBook2 prc = new PriceBook2(id = pricebookId , isActive = true);	
        		update prc;
            
                Opportunity opp = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc.Id);
                insert opp;
            
                Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Simulation');
                insert q;
                
                Product_Sub_segment__c subProduct = new Product_Sub_segment__c(
                    Name = 'Laminate Tubes'
                );
            
                insert subProduct;
            
            	Product_Sub_segment__c subProduct2 = new Product_Sub_segment__c(
                    Name = 'Plastic Tubes'
                );
            
            	insert subProduct2;
            
                Product2 prod = new Product2(Name = 'Laminate Tubes', Product_Sub_Segment__c = subProduct.Id,
                                             Family = 'Tubes');
                insert prod;
                
                Product2 prod2 = new Product2(Name = 'Plastic Tubes', Product_Sub_Segment__c = subProduct2.Id,
                                             Family = 'Tubes');
                insert prod2;
              
            	
                PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod.Id,
                    UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                PricebookEntry standardPrice2 = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                    UnitPrice = 5000, IsActive = true);
                insert standardPrice2;
            
            
                //Create Team Allocation 1
                Sales_Allocations__c alloc1 = new Sales_Allocations__c();
                alloc1.Account__c = acc.id;
                alloc1.Sales_Team__c = team1.id;
                alloc1.Product__c = 'BTL';
                alloc1.Product_Sub_Segment__c = prod.id;
                alloc1.Valid_From__c = Date.today().addYears(-2);
                alloc1.Valid_To__c = Date.today().addYears(1);
                
                insert alloc1;
        		
        		PM_Global_Config__c pmConfig= new PM_Global_Config__c();
        		pmConfig.Table_Name__c = 'Access to PricematriX by PL,zone, country';
        		pmConfig.Country_code__c = 'FR';
        		pmConfig.Product_Line_Tubes__c = 'PricematriX Europe';
        		insert pmConfig;
 				
        		test.startTest();
       		 	QuoteLineItem qli = LC01_PriceSimulatorController.CreateQuoteLineItem(q.id,'Laminate Tubes',200,'BABY CARE',false);
        		insert qli;
        		
        		LC01_SimulatorButtons.deleteConfigurations(qli.id, null);
        		
        		List<QuoteLIneItem> qliResult = [select id from QuoteLineItem where id =: qli.id];
        		List<Opportunity> oppResult = [select id from Opportunity where id =: opp.id];
				List<Quote> quoteResult = [select id from Quote where id =:q.id];        
        		system.assert(qliResult.size() == 0);
        		system.assert(oppResult.size() == 0);
        		system.assert(quoteResult.size() == 0);
        		test.stopTest();
                    }
    
    public testmethod static void deleteConfigurationsTest2(){
    //Create Test Users for the Teams
            List<User> users = new List<User>();

            //Retrieve KAM PRofile
            Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];
    
        
            for(integer i=1; i<=10; i++){
                String orgId = 'Albea';
                           
                User tuser = TestFactory.newUser('test','user'+i, KAM.Name, true, true,true, true, i+1000);
               
                tuser.email = 'test_user'+i+ '@test' + orgId + '.com';
                tuser.Username = 'test_user'+i+ '@test' + orgId + '.com';
                tuser.EmailEncodingKey = 'ISO-8859-1';
                tuser.Alias = 'test'+i;
                tuser.TimeZoneSidKey = 'America/Los_Angeles';
                tuser.LocaleSidKey = 'en_US';
                tuser.LanguageLocaleKey = 'en_US';
                users.add(tuser);                               
            }
            
            users[0].ProfileId = KAM.id;
            users[0].by_pass_vr__c = true;
            users[4].ProfileId = KAM.id;
            insert users;
            	
            	Country__c frCountry = TestFactory.getFrance();
            	insert frCountry;
    
                //Create Distribution Channel
                Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
                insert distCountry1;
                
                //Create Sales Area
                Sales_Area__c salesArea = TestFactory.newSalesArea();
                insert salesArea;
    
                // Create a State
                State__c state = TestFactory.newState('FRANCE','FR');
            	state.Country__c = frCountry.id;
                insert state;
                
                //Create Test Accounts
    
                Account acc = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
            	acc.Street__c = 'Cartault';
                insert acc;
                
                Account acc2 = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
                acc2.Street__c = 'Cartault';
            	insert acc2;
                
                //Create Test Sales Teams
                Sales_Team__c team1 = new Sales_Team__c();
                team1.KAM__c = users[0].id;
                team1.Manager__c = users[1].id;
                team1.Director__c = users[2].id;
                //team1.Additional__c = users[3].id;
                team1.Valid_From__c = Date.today().addYears(-1);
                team1.Valid_To__c = Date.today().addYears(3);
                team1.Sales_Team__c = 'test team 1';
                
                insert team1;
                
                Sales_Team__c team2 = new Sales_Team__c();
                team2.KAM__c = users[4].id;
                team2.Manager__c = users[5].id;
                team2.Director__c = users[6].id;
                //team2.Additional__c = users[7].id;
                team2.Valid_From__c = Date.today().addYears(-1);
                team2.Valid_To__c = Date.today().addYears(3);
                team2.Sales_Team__c = 'test team 2';
                insert team2;
                
                
                //Get Standard Pricebook
                Id pricebookId = Test.getStandardPricebookId();
        		PriceBook2 prc = new PriceBook2(id = pricebookId , isActive = true);	
        		update prc;
            
                Opportunity opp = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc.Id);
                insert opp;
            
                Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Simulation');
                insert q;
                
                Product_Sub_segment__c subProduct = new Product_Sub_segment__c(
                    Name = 'Laminate Tubes'
                );
            
                insert subProduct;
            
            	Product_Sub_segment__c subProduct2 = new Product_Sub_segment__c(
                    Name = 'Plastic Tubes'
                );
            
            	insert subProduct2;
            
                Product2 prod = new Product2(Name = 'Laminate Tubes', Product_Sub_Segment__c = subProduct.Id,
                                             Family = 'Tubes');
                insert prod;
                
                Product2 prod2 = new Product2(Name = 'Plastic Tubes', Product_Sub_Segment__c = subProduct2.Id,
                                             Family = 'Tubes');
                insert prod2;
              
            	
                PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod.Id,
                    UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                PricebookEntry standardPrice2 = new PricebookEntry(
                    Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                    UnitPrice = 5000, IsActive = true);
                insert standardPrice2;
            
            
                //Create Team Allocation 1
                Sales_Allocations__c alloc1 = new Sales_Allocations__c();
                alloc1.Account__c = acc.id;
                alloc1.Sales_Team__c = team1.id;
                alloc1.Product__c = 'BTL';
                alloc1.Product_Sub_Segment__c = prod.id;
                alloc1.Valid_From__c = Date.today().addYears(-2);
                alloc1.Valid_To__c = Date.today().addYears(1);
                
                insert alloc1;
        		
        		PM_Global_Config__c pmConfig= new PM_Global_Config__c();
        		pmConfig.Table_Name__c = 'Access to PricematriX by PL,zone, country';
        		pmConfig.Country_code__c = 'FR';
        		pmConfig.Product_Line_Tubes__c = 'PricematriX Europe';
        		insert pmConfig;
 				
        		test.startTest();
       		 	QuoteLineItem qli = LC01_PriceSimulatorController.CreateQuoteLineItem(q.id,'Laminate Tubes',200,'BABY CARE',false);
        		insert qli;
 
        		LC01_SimulatorButtons.deleteConfigurations(null, opp.id);
        		List<QuoteLIneItem> qliResult = [select id from QuoteLineItem where id =: qli.id];
				List<Opportunity> oppResult = [select id from Opportunity where id =: opp.id];
				List<Quote> quoteResult = [select id from Quote where id =:q.id];        
        		system.assert(qliResult.size() == 0);
        		system.assert(oppResult.size() == 0);
        		system.assert(quoteResult.size() == 0);
        		test.stopTest();
                    }
    
    
}