@isTest
public class VFC03_PM_GotoPriceMatrixEXtTest {
 
	  
	  
	@testSetup
	static void testSetup(){
		Id pricebookId = Test.getStandardPricebookId();
		
		//Create Test Users for the Teams
	         List<User> users = new List<User>();
	         String pid = [Select id from Profile where Name='System Administrator'].Id; 
	        
	        //Retrieve KAM PRofile
	        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];
	
	    
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
	        
	        users[0].ProfileId = KAM.id;
	        users[4].ProfileId = KAM.id;
	        insert users;
	        
	      //  System.runAs(users[0]){
	         //Create Test Data
	        Country__c country = TestFactory.getFrance();
	        insert country;
	        //country = [select Id from Country__c where Name = 'France' and Country_Code__c = 'FR'];
	    
	        //Create Test Distribution Channel
	        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
	        insert testDistrib;
	        
	        //Create Sales Area
	        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
	        insert testArea;
	        
	        //Create Test Accounts and allow duplicate
	        Database.DMLOptions dml = new Database.DMLOptions(); 
	        dml.DuplicateRuleHeader.allowSave = true;
	       // acc = new Account(Name = 'Test Acc 1'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
	        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
	        Database.SaveResult sr = Database.insert(acc, dml);
	        
	        //acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
	        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
	        sr = Database.insert(acc2, dml);
	        
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
	        
	            
	        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
	        insert opp;
	    
	        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
	        insert q;
	        
	        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
	        	Name = 'Iron Lotion pumps'
	     	);
	      	insert subProd;
	        
	        Product2 prod = new Product2(Name = 'bottle 50ml', 
	                                     Family = 'Bottle', Product_Sub_Segment__c = subProd.Id,productcode='test 1');
	        insert prod;
	        
	        Product2 prod2 = new Product2(Name = 'Tube 50ml', 
	                                     Family = 'Tube', Product_Sub_Segment__c = subProd.Id,productcode='test 2s');
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
	        
	        Sales_Allocations__c alloc2 = new Sales_Allocations__c();
	        alloc2.Account__c = acc2.id;
	        alloc2.Sales_Team__c = team2.id;
	        alloc2.Product__c = 'BTL';
	        alloc2.Product_Sub_Segment__c = prod2.id;
	        alloc2.Valid_From__c = Date.today().addYears(-1);
	        alloc2.Valid_To__c = Date.today().addYears(1);
	        
	        insert alloc2;
	        
	        
	        
	          //Insert QLI
	         QuoteLineItem  qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',
	                                                  Product2Id = prod.id, QuoteId = q.Id, Location__c = 'EU'
	                                                  );
	           
	            
	        insert qli;
	        
	       // }
	}  
	
	/**
     * [getQli Description : return the QuoteLineItem record created in the initialisation phase]
     * @return [QuoteLineItem : the record created in the initialisation phase]
     */
    private static QuoteLineItem getQli(){
    	return [SELECT UnitPrice, Quantity, PricebookEntryId, Production_Cluster__c, Production_Plant__c,
	        			Product2Id, QuoteId, Location__c
	        	FROM QuoteLineItem
	        	LIMIT 1];
    }
	  
    static testmethod void test_VFC03_PM_GotoPriceMatrixEXt(){
    	QuoteLineItem qli = getQli();
    	
        // cover the constructor with StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(qli);
        
        PageReference pageRef = Page.VF03_PM_GotoPriceMatrixDetails;
        pageRef.getParameters().put('id', String.valueOf(qli.Id));
        Test.setCurrentPage(pageRef);
        
        VFC03_PM_GotoPriceMatrixEXt instanceSC = new VFC03_PM_GotoPriceMatrixEXt(sc);
        // Cover the method
        instanceSC.redirectToPriceMatrix();
        
        // cover the constructor with StandardSetController
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        qliList.add(qli);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(qliList);
        PageReference pageRef2 = Page.VF03_PM_GotoPriceMatrixDetails;
        pageRef2.getParameters().put('id', String.valueOf(qli.Id));
        Test.setCurrentPage(pageRef2);
        VFC03_PM_GotoPriceMatrixEXt instanceSSC = new VFC03_PM_GotoPriceMatrixEXt(ssc);
        instanceSSC.redirectToPriceMatrix();
    }
}