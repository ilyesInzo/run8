@isTest 
public with sharing class AP00_CharacterChecker_Test {	

    @testSetup 
    private static void init() {
        User admUser = TestFactory.newUser('System Administrator', 1);
        admUser.By_Pass_VR__c = true;
        insert admUser;

        List<Country__c> countries = TestFactory.newCountry();
        insert countries;
        
        Distribution_Channel__c distChannel = TestFactory.newDistributionChannel();
        insert distChannel;
        
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;
    }


	/****************************/
	static testmethod void testcontainsIllegalCharsPositive(){
	
		System.assertEquals(true,StringUtils.containsIllegalChars('漢字漢字 漢  TEST TES 121 ù%* '));
		System.assertEquals(true,StringUtils.containsIllegalChars('漢字漢字 漢 TEST TES 12'));
		System.assertEquals(true,StringUtils.containsIllegalChars('漢 字 漢字 漢'));
	}
	/****************************/
	static testmethod void testcontainsIllegalCharsNegative(){
	
		System.assertEquals(false,StringUtils.containsIllegalChars('TEST TES 121 ù%* '));
		System.assertEquals(false,StringUtils.containsIllegalChars('ù%* ^ & < > ! 1 ° N @ '));
	}
	
	/****************************/
	static testmethod void testgetAllFieldsValues(){
		String str = SObjectUtils.getAllFieldsValues(new account(name='12445 Test Name', City__c ='Paris'));
		System.assertEquals(true,str.contains('Paris'));
		System.assertEquals(true,str.contains('12445 Test Name'));
	}
	/****************************/
	//Triggers' tests
    static testmethod void testCharCheckerForAccountTriggerPositive(){
	
        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        User admUser = [Select Id From User Where Matricule_ADS__c = '1'];
        
        //Create Test Accounts
        //Account acc = new Account(
        //    Name = 'Test Acc 1'+datetime.now(), 
        //    Country__c = country.Id,
        //    Distribution_Channel__c = testDistrib.id,
        //    Sales_Area__c = testArea.id,
        //    Account_status__c = 'Active',
        //    Type = 'Client'
        //);
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        acc.Name = 'Test Acc 1'+datetime.now();
       		
		Test.startTest();
        // admUser bypass the validation rule to be sure to have no Exceptions due to Validation Rules
        System.runAs(admUser) {          	
        	Boolean triggersError = false;
        	try{
        		insert acc;
        	}catch(Exception e){
        		triggersError = true;	
        	}

            system.assertEquals(false,triggersError);

            acc.Name = 'New Valid Name';
            try{
                update acc;
            }catch(Exception e){
                triggersError = true;   
            }

            system.assertEquals(false,triggersError);
        }
        Test.stopTest();
			
	}
	
	/*************Account ***************/
	//Triggers' tests
    static testmethod void testCharCheckerForAccountTriggerNegative(){

        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        User admUser = [Select Id From User Where Matricule_ADS__c = '1'];
        
        //Create Test Accounts
        //Account acc = new Account(
        //    Name = 'Test 方饿饭 Acc 1'+datetime.now(), 
        //    Country__c = country.Id,
        //    Distribution_Channel__c = testDistrib.id,
        //    Sales_Area__c = testArea.id,
        //    Account_status__c = 'Active',
        //    Type = 'Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        acc.Name = 'Test 方饿饭 Acc 1'+datetime.now();
       		
		Test.startTest(); 
        // admUser bypass the validation rule to be sure to have no Exceptions due to Validation Rules         	
        System.runAs(admUser) {
            Boolean triggersError = false;
            try{
                insert acc;
            }catch(Exception e){
                triggersError = true;   
            }

            system.assertEquals(true,triggersError);

            acc.Name = 'New 方饿饭 Name';
            try{
                update acc;
            }catch(Exception e){
                triggersError = true;   
            }

            system.assertEquals(true,triggersError);

        }
        Test.stopTest();
		
	}
	
    /********************* Quote *****************************/
    // To move in QuoteServiceTest
    //Triggers' tests
    static testmethod void testCharCheckerForQuoteTriggerPositive(){
		User admUser = [Select Id From User Where Matricule_ADS__c = '1'];
        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        
        //Account acc = new Account(Name = 'Test Acc ab'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        System.runAs(admUser) {          	
        	Boolean triggersError = false;
        	insert acc;
        }        
        Opportunity opp1 = new Opportunity(Name = 'Test Opp 4', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp1;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();     
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp1.Id, RFQ_Reception_Date__c = Date.today());
                
        Test.startTest();           
            Boolean triggersError = false;
            try{
                insert q;
            }catch(Exception e){
                triggersError = true;   
            }
      
        test.stopTest();
        
        //asserts
        system.assertEquals(false,triggersError);
        
    }

	/*************/
    // To move in QuoteServiceTest
	static testmethod void testCharCheckerForQuoteTriggerNegative(){
		User admUser = [Select Id From User Where Matricule_ADS__c = '1'];
        
        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        
        //Account acc = new Account(Name = 'Test Acc abc'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        System.runAs(admUser) {  
        	insert acc;
        }
		Opportunity opp1 = new Opportunity(Name = 'Test Opp 4', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
		insert opp1;
		
		//Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();     
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test 额方饿饭 Quote 1', OpportunityId = opp1.Id, RFQ_Reception_Date__c = Date.today());
                
		Test.startTest();          	
        	Boolean triggersError = false;
        	try{
        		insert q;
        	}catch(Exception e){
        		triggersError = true;	
        	}
      
        Test.stopTest();
        
        //asserts
		system.assertEquals(true,triggersError);
		
	}
	
	/******************** Quote item *************************/
    // To move in QuoteLineItem service Test
	//Triggers' tests
    static testmethod void testCharCheckerForQuoteitemTriggerPositive(){
 		User admUser = [Select Id From User Where Matricule_ADS__c = '1'];	
        
        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        
        //Account acc = new Account(Name = 'Test Acc abc'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        System.runAs(admUser) {  
            insert acc;
        }
		Opportunity opp1 = new Opportunity(Name = 'Test Opp 4', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
		insert opp1;
		
		//Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();     
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'TestQuote 1', OpportunityId = opp1.Id, RFQ_Reception_Date__c = Date.today());
       insert q;
       Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Bottle');
        insert prod;
       PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                              Product2Id = prod.id, QuoteId = q.Id,Production_Cluster__c='Albea China',Production_Plant__c='Hong Kong PC'
                                              ); 
                     
		Test.startTest();          	
        	Boolean triggersError = false;
        	try{
        		insert qli; 
        	}catch(Exception e){
        		triggersError = true;	
        	}
      
        Test.stopTest();
        
        //asserts
		system.assertEquals(true,triggersError);
		
	}
	
	/******/
    // To move in QuoteLineItem service Test
	//Triggers' tests
    static testmethod void testCharCheckerForQuoteitemTriggerNegative(){
         User admUser = [Select Id From User Where Matricule_ADS__c = '1'];
        
        Country__c country = [Select Id From Country__c Limit 1];
        Distribution_Channel__c testDistrib = [Select Id From Distribution_Channel__c Limit 1];
        Sales_Area__c testArea = [Select Id From Sales_Area__c Limit 1];
        
        //Account acc = new Account(Name = 'Test Acc abc'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        System.runAs(admUser) {  
            insert acc;
        }
		Opportunity opp1 = new Opportunity(Name = 'Test Opp 4', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
		insert opp1;
		
		//Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();     
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'TestQuote 1', OpportunityId = opp1.Id, RFQ_Reception_Date__c = Date.today());
       insert q;
       Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Bottle');
        insert prod;
       PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                              Product2Id = prod.id, QuoteId = q.Id,Production_Cluster__c='Albea China',Production_Plant__c='Hong Kong PC',
                                              Description='金额随时来取；饿 '); 
                     
		Test.startTest();          	
        	Boolean triggersError = false;
        	try{
        		insert qli; 
        	}catch(Exception e){
        		triggersError = true;	
        	}
      
        Test.stopTest();
        
        //asserts
		system.assertEquals(true,triggersError);
		
	}
}