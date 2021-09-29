/**
* Test class of SalesTeamService
*
* @author MDK, EWA
* @date 12/10/2017
* @description
*
*/
@isTest
private class SalesTeamServiceTest {

    // Some methods are tested in SalesServiceTest Class
   
    // @author EWA
    private static String LOG_CLASS_NAME = 'SalesTeamServiceTest';
    
    private static Integer NB_MAX_USER = 1;
    
    private static Integer NB_MAX_ACCOUNT = 5;
    
    private static Integer NB_MAX_OPPORTUNITY = 5;
    
    private static Integer NB_MAX_QUOTE = 5;
    
    private static Integer NB_MAX_QUOTE_LINE_ITEM = 5;
    
    /**
     * [ testSetup description : data initialisation for the test ]
     */
    @testSetup
    public static void testSetup(){
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testSetup start');
        
        //User needed for the test          
        List<User> newKAMs = new List<User>();
        List<User> newDirectors = new List<User>();
        List<User> newManagers = new List<User>();
        List<User> newAdditionals = new List<User>();

        Profile profile = [
            Select Id 
            From Profile 
            Where Name = 'SALES - KAM'
        ];

        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - User initialisation start');
        
        for(integer index = 0; index < NB_MAX_USER; index++ ){      
            //KAM user
            User newKAM = TestFactory.newKamUser(120*1000+index, profile.Id);
            newKAMs.add(newKAM);
            
            //Director user
            User newDirector = TestFactory.newDirectorUser(121*1000+index, profile.Id);
            newDirectors.add(newDirector);
            
            //Manager user
            User newManager = TestFactory.newManagerUser(122*1000+index, profile.Id);
            newManagers.add(newManager);
            
            //Additionnal user
            User newAdditional = TestFactory.newAdditionalUser(123*1000+index, profile.Id);
            newAdditionals.add(newAdditional);
        }
        
        insert(newKAMs);
        insert(newDirectors);
        insert(newManagers);
        insert(newAdditionals);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - User initialisation stop');
        
       
		//Create List Users
		Profile p2=[select id,Name from Profile where Name='Marketing'];
		Profile p1=[select id,Name from Profile where Name='Plant'];

        User uPlant1=TestFactory.newUser('PlantUser1','Einstein', 'Plant',false,false, false,false,03111992, p1.id);
		User uPlant2=TestFactory.newUser('PlantUser2','Einstein', 'Plant',false,false, false,false,01111992, p1.id);

		User uSeg1=TestFactory.newUser('SubSegUser1','Einstein', 'Marketing',false,false, false,false,24101994, p2.id);
		User uSeg2=TestFactory.newUser('SubSegUser2','Einstein', 'Marketing',false,false, false,false,26101994, p2.id);

        List<User> listUsers=new List<User> {uPlant1,uPlant2,uSeg1,uSeg2};
        insert listUsers;
        
        //Country to be used for test
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Country initialisation start');
        
        List<Country__c> countries = new list<Country__c>();
        Country__c france = TestFactory.getFrance();
        countries.Add(france);
        Country__c germany = TestFactory.getGermany();
        countries.Add(germany);
        Country__c USA = TestFactory.getUSA();
        countries.Add(USA);
        
        insert(countries);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Country initialisation stop');
        
        //Distribution Channel
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Distribution Channel initialisation start');
        
        List<Distribution_Channel__c> distributionChannels = new List<Distribution_Channel__c>();
        Distribution_Channel__c distributionChannel1 = TestFactory.newDistributionChannel('DIRECT SALES', '00001', 'E');
        distributionChannels.add(distributionChannel1);
        Distribution_Channel__c distributionChannel2 = TestFactory.newDistributionChannel('MASS MARKET', '00002', 'E');
        distributionChannels.add(distributionChannel2);
        Distribution_Channel__c distributionChannel3 = TestFactory.newDistributionChannel('SELECTIVE MARKET', '00003', 'E');
        distributionChannels.add(distributionChannel3);
        Distribution_Channel__c distributionChannel4 = TestFactory.newDistributionChannel('DISTRIBUTION', '00004', 'E');
        distributionChannels.add(distributionChannel4);
                
        insert(distributionChannels);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Distribution Channel initialisation stop');
        
        //Sales Area
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Area initialisation start');
        
        List<Sales_Area__c> salesAreas = new List<Sales_Area__c>();
        Sales_Area__c salesArea1 = TestFactory.newSalesArea('Interco Global Accounts', 'GA', 'FRC', 'Interco Global Acocunts', 'E', 'FRC', 'G');
        salesAreas.Add(salesArea1);
        Sales_Area__c salesArea2 = TestFactory.newSalesArea('Interco Key Accounts', 'KA', 'FRE', 'Interco Key Accounts', 'E', 'FRE', 'R');
        salesAreas.Add(salesArea2);
        Sales_Area__c salesArea3 = TestFactory.newSalesArea('Interco Domestic Europe', 'DA', 'FRF', 'Interco Domestic Europe', 'E', 'FRF', 'R');
        salesAreas.Add(salesArea3);
        Sales_Area__c salesArea4 = TestFactory.newSalesArea('Interco Domestic USA', 'DA', 'FRD', 'Interco Domestic USA', 'E', 'FRD', 'R');
        salesAreas.Add(salesArea4);
        Sales_Area__c salesArea5 = TestFactory.newSalesArea('Dom Acc Indonesia','DA','SEA','Dom Acc South East Asia', 'E', 'IDO', 'R');
        salesAreas.Add(salesArea5);
        
        insert(salesAreas);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Area initialisation stop');
        
        //State Region 
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - State Region initialisation Start');
        
        List<State__c> stateRegions = new List<State__c>();
        State__c stateRegion1 = TestFactory.newState('Hebei', 'CN-13');
        stateRegions.Add(stateRegion1);
        State__c stateRegion2 = TestFactory.newState('Western Australia', 'AU-WA');
        stateRegions.Add(stateRegion2);
        State__c stateRegion3 = TestFactory.newState('Azerbaijan', 'AZ');
        stateRegions.Add(stateRegion3);
        State__c stateRegion4 = TestFactory.newState('Enna','IT-EN');
        stateRegions.Add(stateRegion4);
        State__c stateRegion5 = TestFactory.newState('Korea, Republic of', 'KR');
        stateRegions.Add(stateRegion5);
        
        insert(stateRegions);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - State Region initialisation Stop');
        
        //Account
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Account initialisation Start');
        
        List<Account> accounts = new List<Account>();
        
        for(Integer index = 0; index < NB_MAX_ACCOUNT; index++ ){
        	Account newAccount = TestFactory.newAccount(
        		countries.get(Math.mod(index, 3)).Id,
        		distributionChannels.get(Math.mod(index, 4)).Id,
        		salesAreas.get(Math.mod(index,5)).Id,
        		stateRegions.get(Math.mod(index, 5)).Id,
        		TestFactory.generateCodeVAT(10)
        	);
            newAccount.street__c = 'test';
        	accounts.add(newAccount);
        }
        
        insert(accounts);
            
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Account initialisation Stop');
        
        //Product Segment
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Segment initialisation Start');
        
        List<Product_Segment__c> productSegments = new List<Product_Segment__c>();
        Product_Segment__c productSegment1 = TestFactory.newProductSegment('EN','Laminate Tubes','LAM');
        productSegments.add(productSegment1);
        Product_Segment__c productSegment2 = TestFactory.newProductSegment('EN','Pack & Accessories','HARD');
        productSegments.add(productSegment2);
        Product_Segment__c productSegment3 = TestFactory.newProductSegment('EN','Lotion pumps','LOTNP');
        productSegments.add(productSegment3);
        Product_Segment__c productSegment4 = TestFactory.newProductSegment('EN','Full Service','FULL');
        productSegments.add(productSegment4);
        Product_Segment__c productSegment5 = TestFactory.newProductSegment('EN','Promotional','SOFT');
        productSegments.add(productSegment5);
        
        insert(productSegments);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Segment initialisation Stop');
        
        //Product Sub Segment
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment initialisation Start');
        
        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegment1 = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegment1.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegment1);
        Product_Sub_Segment__c productSubSegment2 = TestFactory.newProductSubSegment('CRP', 'E', 'ILNR', productSegment2.Id, 'MASC', 'Eyeliner', 30.0);
        productSubSegments.Add(productSubSegment2);
        Product_Sub_Segment__c productSubSegment3 = TestFactory.newProductSubSegment('CRP', 'E', 'JAR', productSegment3.Id, 'CTNR', 'Jars', 30.0);
        productSubSegments.Add(productSubSegment3);
        Product_Sub_Segment__c productSubSegment4 = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegment4.Id, 'LAM', 'Laminate Tubes', 30.0);
        productSubSegments.Add(productSubSegment4);
        Product_Sub_Segment__c productSubSegment5 = TestFactory.newProductSubSegment('CRP', 'E', 'LIPST', productSegment5.Id, 'LIPST', 'Lipsticks', 30.0);
        productSubSegments.Add(productSubSegment5);
        
        insert(productSubSegments);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment initialisation Stop');
        
        //Product2
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment (Product2) initialisation Start');
        List<Product2> products2 = new List<Product2>();
        Product2 product1 = TestFactory.newProduct('Beauty Solutions', 'Accessories', 'HARD', productSubSegment1.ID, 30.0);
        products2.add(product1);
        Product2 product2 = TestFactory.newProduct('CRP', 'Eyeliner', 'ILNR', productSubSegment2.ID, 30.0);
        products2.add(product2);
        Product2 product3 = TestFactory.newProduct('CRP', 'Jars', 'JAR', productSubSegment3.ID, 30.0);
        products2.add(product3);
        Product2 product4 = TestFactory.newProduct('Tubes', 'Laminate Tubes', 'LAM', productSubSegment4.ID, 20.0);
        products2.add(product4);
        Product2 product5 = TestFactory.newProduct('CRP', 'Lipsticks', 'LIPST', productSubSegment5.ID, 30.0);
        products2.add(product5);
        
        insert(products2);
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment (Product2) initialisation Stop');
        
       
        
        //Opportunity initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' Opportunity initialisation Start');
        
        List<Opportunity> newOpportunities = new List<Opportunity>();
        for(Integer index = 0; index < NB_MAX_OPPORTUNITY; index++){
            Opportunity newOpportunity = TestFactory.newOpportunity(
                'newOpportunity'+index,
                'Retention',
                accounts.get(math.mod(index, NB_MAX_ACCOUNT)).Id
            );
            newOpportunities.add(newOpportunity);
        }
        
        insert(newOpportunities);
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' Opportunity initialisation Stop');
        
        //Quote initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote initialisation Start');
        
        List<Quote> newQuotes = new List<Quote>();
        Id priceBookId = Test.getStandardPricebookId();
        for(Integer index = 0; index < NB_MAX_QUOTE; index++){
            Date quoteDueDate = Date.newInstance(2019,1,Math.mod(index,31));
            Quote newQuote = TestFactory.newQuote(
                'P0',
                quoteDueDate,
                'Draft',
                newOpportunities.get(Math.mod(index, NB_MAX_OPPORTUNITY)).Id,
                priceBookId
            );
            newQuotes.add(newQuote);
        }
        
        insert(newQuotes);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote initialisation Stop');


        //Standard Price
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();

        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product1.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product2.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice2);
        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product3.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice3);
        PricebookEntry standardPrice4 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product4.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice4);
        PricebookEntry standardPrice5 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = product5.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice5);

        insert standardPrices;
        
        //Quote Line Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote Line Initialisation Start');
        
        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();          
        for(Integer index = 0; index < NB_MAX_QUOTE_LINE_ITEM; index++ ){
            QuoteLineItem qli = TestFactory.newQuoteLineItem(
                newQuotes.get(Math.mod(index, NB_MAX_QUOTE)).Id,
                products2.get(Math.mod(index, 5)).Id,
                standardPrices.get(Math.mod(index, 5)).Id
            );
            newQuoteLineItems.add(qli);
        }
        
        //TriggerHandler.bypass('QuoteLineItemTriggerHandler');
        insert(newQuoteLineItems);
        //TriggerHandler.clearBypass('QuoteLineItemTriggerHandler');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote Line Initialisation Stop');

        //Sales Team need for test
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Team initialisation start');
        
        List<Sales_Team__c> salesTeams = new List<Sales_Team__c>();
        
        for(integer index = 0; index < NB_MAX_USER; index++){
            Sales_Team__c newSalesTeam = TestFactory.newSalesTeam(
                newKAMS.get(index).Id,
                newManagers.get(index).Id,
                newAdditionals.get(index).Id,
                newDirectors.get(index).Id,
                'salesTeam'+index,
                String.valueOf(1111+index)
            );
            salesTeams.add(newSalesTeam);
            System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - newSalesTeam');
        }
        
        TriggerHandler.bypass('SalesTeamTriggerHandler');
        insert(salesTeams);
        TriggerHandler.clearBypass('SalesTeamTriggerHandler');
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Team initialisation stop');

        //Sales allocation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Allocation initialisation Start');
        
        List<Sales_Allocations__c> newSalesAllocations = new List<Sales_Allocations__c>();
        Date validFrom = Date.newInstance(1700,1,1);
        Date validTo = Date.newInstance(4000,12,31);
        for(integer index = 0; index < NB_MAX_USER; index++){
            Sales_Allocations__c newSalesAllocation = TestFactory.newSalesAllocations(
                accounts.get(Math.mod(index, NB_MAX_ACCOUNT)),
                salesTeams.get(index),                  
                'HARD',
                products2.get(Math.mod(index, 5)),
                validFrom,
                validTo
            );
            newSalesAllocations.add(newSalesAllocation);
        }
        
        insert(newSalesAllocations);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Allocation initialisation Stop');
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testSetup stop');
    }
    
   /**
    * [ testAffectation description : will test the impact of the script  ]
    */
 /*  @isTest 
   static void testAffectation(){    
        //1. First run of the script
        Test.startTest();
        Database.executeBatch(new BA01_Sales_Team_Sharing_V02());
       Database.executeBatch(new Batch_SalesAlloc_UpdateVisibility());


       Test.stopTest();
        
        //2. Checking if the Sales Team was correctly applied
        //2.1.1  Need to get all Account Team Member 
        Map<Id, AccountTeamMember> accountTeamMembers = 
        		new Map<Id, AccountTeamMember>([SELECT AccountAccessLevel, AccountId, ContactAccessLevel, 
        											   Id, UserId, Title
        									      FROM AccountTeamMember]);
        
        //2.1.2  We're going to check if the accountTeamMembers have value (should have)
        System.assertNotEquals(0, accountTeamMembers.size(), 'No Account Team Members where created.');
        
        //2.2    Order Sales Team by Account
        Map<Id, List<AccountTeamMember>> account2AccountTeamMembersMapping = new Map<Id, List<AccountTeamMember>>();
        for(Id accountTeamMemberId : accountTeamMembers.keySet()){
        	AccountTeamMember accountTeamMember = accountTeamMembers.get(accountTeamMemberId);
            if(! account2AccountTeamMembersMapping.containsKey(accountTeamMember.AccountId)){
                account2AccountTeamMembersMapping.put(accountTeamMember.AccountId, new List<AccountTeamMember>());
            }
            account2AccountTeamMembersMapping.get(accountTeamMember.AccountId).Add(accountTeamMember);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - account2AccountTeamMembersMapping.size() : ' + account2AccountTeamMembersMapping.size());
        
        //2.3    Need to get all Sales Allocation / Sales Team
        Map<Id, Sales_Team__c> salesTeams = new Map<Id, Sales_Team__c>([SELECT KAM__c, Manager__c, Additional__c, Director__c, Id FROM Sales_Team__c]);
        List<Sales_Allocations__c> salesAllocations = [SELECT Id, Account__c, Sales_Team__c, Product_Sub_Segment__c FROM Sales_Allocations__c];
        
        //2.4    Order Account Team Member by account 
        Map<Id, List<Id>> account2SalesTeamMapping = new Map<Id, List<Id>>(); 
        for(Sales_Allocations__c salesAllocation : salesAllocations){
        	if(! account2SalesTeamMapping.containsKey(salesAllocation.Account__c)){
        		account2SalesTeamMapping.put(salesAllocation.Account__c, new List<Id>());	
        	}
        	account2SalesTeamMapping.get(salesAllocation.Account__c).add(salesAllocation.Sales_Team__c);
        }     

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - account2SalesTeamMapping.size() : ' + account2SalesTeamMapping.size());

        //2.5    Compare Account Team Member to the corresponding Sales Allocation / Sales Team
		for(Id account : account2SalesTeamMapping.keySet()){
			List<AccountTeamMember> accountTeamMemberList = account2AccountTeamMembersMapping.get(account);
            if(accountTeamMemberList != null){
    			for(AccountTeamMember atMember : accountTeamMemberList){
    				Boolean flag = false;                
    				List<Id> salesTeamIds = account2SalesTeamMapping.get(account);
    				for(Id salesTeamId : salesTeamIds){
                        Boolean flagTemp = true;
    					Sales_Team__c salesTeam = salesTeams.get(salesTeamId);
                        if(salesTeam != null){
                            if(salesTeam.KAM__c != null)
                                flagTemp = (salesTeam.KAM__c != atMember.userId);
                            if(salesTeam.Manager__c != null)
                                flagTemp = flagTemp || (salesTeam.Manager__c != atMember.userId);
                            if(salesTeam.Additional__c != null)
                                flagTemp = flagTemp || (salesTeam.Additional__c != atMember.userId);
                            if(salesTeam.Director__c != null)
                                flagTemp = flagTemp || (salesTeam.Director__c != atMember.userId);
                        }
    					flag = flag || flagTemp;
    				}
    				System.assertEquals(true, flag, 'The user in the Account Team Member has been define in a Sales Team');				
    			}
            }
		}

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - account2SalesTeamMapping.size() : ' + account2SalesTeamMapping.size());

        //2.6.1  Need to get all Opportunity Team Member
        Map<Id, OpportunityTeamMember> opportunityTeamMembers = 
        		new Map<Id, OpportunityTeamMember>([SELECT OpportunityId, OpportunityAccessLevel, UserId, TeamMemberRole, Id
        									          FROM OpportunityTeamMember]);
        Map<Id, List<OpportunityTeamMember>> opportunity2OpportunityTeamMemberMapping = new Map<Id, List<OpportunityTeamMember>>();
        for(Id opportunityTeamMemberId : opportunityTeamMembers.keySet()){
        	OpportunityTeamMember opportunityTeamMember = opportunityTeamMembers.get(opportunityTeamMemberId);
        	if(! opportunity2OpportunityTeamMemberMapping.containsKey(opportunityTeamMember.OpportunityId)){
        		opportunity2OpportunityTeamMemberMapping.put(opportunityTeamMember.OpportunityId, new List<OpportunityTeamMember>());
        	}
        	opportunity2OpportunityTeamMemberMapping.get(opportunityTeamMember.OpportunityId).Add(opportunityTeamMember);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - opportunity2OpportunityTeamMemberMapping.size() : ' + opportunity2OpportunityTeamMemberMapping.size());
        									      
        //2.6.2  The Map should have at least one item
        System.assertNotEquals(0, opportunityTeamMembers.values().size(), 'We should have at least one Opportunity Member : ' + opportunityTeamMembers.values());
        
        //3.     Modifying some of the sales team 
        List<Sales_Team__c> salesTeamList = new List<Sales_Team__c>([SELECT KAM__c, Manager__c, Additional__c, Director__c, Id FROM Sales_Team__c]);
        List<Sales_Team__c> salesTeams2Update = new List<Sales_Team__c>();
        for(integer index = 0; index < NB_MAX_USER; index++){
            Sales_Team__c currentSalesTeam = salesTeamList.get(index);
            Sales_Team__c futurSalesTeam = salesTeamList.get(Math.mod(index+1, NB_MAX_USER));
            currentSalesTeam.KAM__c = futurSalesTeam.KAM__c;
            currentSalesTeam.Manager__c = futurSalesTeam.Manager__c;
            currentSalesTeam.Additional__c = futurSalesTeam.Additional__c;
            currentSalesTeam.Director__c = futurSalesTeam.Director__c;
            salesTeams2Update.add(currentSalesTeam);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - salesTeamList.size() : ' + salesTeamList.size());

        update(salesTeams2Update);

        //4.     Second run of the script
        //Test.startTest();
        Database.executeBatch(new BA01_Sales_Team_Sharing_V02());
        //Test.stopTest();
        
        //5.     Checking if the new Sales Team was correctly applied
        //5.1.1  Need to get all Account Team Member 
        accountTeamMembers = 
        		new Map<Id, AccountTeamMember>([SELECT AccountAccessLevel, AccountId, ContactAccessLevel, 
        											   Id, UserId, Title
        									      FROM AccountTeamMember]);
        
        //5.1.2  We're going to check if the accountTeamMembers have value (should have)
        System.assertNotEquals(0, accountTeamMembers.size(), 'No Account Team Members where created.');
        
        //5.2    Order Sales Team by Account
        account2AccountTeamMembersMapping = new Map<Id, List<AccountTeamMember>>();
        for(Id accountTeamMemberId : accountTeamMembers.keySet()){
        	AccountTeamMember accountTeamMember = accountTeamMembers.get(accountTeamMemberId);
            if(! account2AccountTeamMembersMapping.containsKey(accountTeamMember.AccountId)){
                account2AccountTeamMembersMapping.put(accountTeamMember.AccountId, new List<AccountTeamMember>());
            }
            account2AccountTeamMembersMapping.get(accountTeamMember.AccountId).Add(accountTeamMember);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - account2AccountTeamMembersMapping.size() : ' + account2AccountTeamMembersMapping.size());
        
        //5.3    Need to get all Sales Allocation / Sales Team
        salesTeams = new Map<Id, Sales_Team__c>([SELECT KAM__c, Manager__c, Additional__c, Director__c, Id FROM Sales_Team__c]);
        salesAllocations = [SELECT Id, Account__c, Sales_Team__c, Product_Sub_Segment__c FROM Sales_Allocations__c];
        
        //5.4    Order Account Team Member by account 
        account2SalesTeamMapping = new Map<Id, List<Id>>(); 
        for(Sales_Allocations__c salesAllocation : salesAllocations){
        	if(! account2SalesTeamMapping.containsKey(salesAllocation.Account__c)){
        		account2SalesTeamMapping.put(salesAllocation.Account__c, new List<Id>());	
        	}
        	account2SalesTeamMapping.get(salesAllocation.Account__c).add(salesAllocation.Sales_Team__c);
        }     

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - account2SalesTeamMapping.size() : ' + account2SalesTeamMapping.size());

        //5.5    Compare Account Team Member to the corresponding Sales Allocation / Sales Team
		for(Id account : account2SalesTeamMapping.keySet()){
			List<AccountTeamMember> accountTeamMemberList = account2AccountTeamMembersMapping.get(account);
			if(accountTeamMemberList != null)
			for(AccountTeamMember atMember : accountTeamMemberList){
				Boolean flag = false;
				List<Id> salesTeamIds = account2SalesTeamMapping.get(account);
				for(Id salesTeamId : salesTeamIds){
					Sales_Team__c salesTeam = salesTeams.get(salesTeamId);
					if(salesTeam != null){
						Boolean flagTemp = (salesTeam.KAM__c != atMember.userId) || (salesTeam.Manager__c != atMember.userId) || 
							(salesTeam.Additional__c != atMember.userId) || (salesTeam.Director__c != atMember.userId);
						flag = flag || flagTemp;	
					}					
				}
				System.assertEquals(true, flag, 'The user in the Account Team Member has been define in a Sales Team');				
			}
		}
        
        //5.6.1  Need to get all Opportunity Team Member
        opportunityTeamMembers = 
                new Map<Id, OpportunityTeamMember>([SELECT OpportunityId, OpportunityAccessLevel, UserId, TeamMemberRole, Id
                                                      FROM OpportunityTeamMember]);
        opportunity2OpportunityTeamMemberMapping = new Map<Id, List<OpportunityTeamMember>>();
        for(Id opportunityTeamMemberId : opportunityTeamMembers.keySet()){
            OpportunityTeamMember opportunityTeamMember = opportunityTeamMembers.get(opportunityTeamMemberId);
            if(! opportunity2OpportunityTeamMemberMapping.containsKey(opportunityTeamMember.OpportunityId)){
                opportunity2OpportunityTeamMemberMapping.put(opportunityTeamMember.OpportunityId, new List<OpportunityTeamMember>());
            }
            opportunity2OpportunityTeamMemberMapping.get(opportunityTeamMember.OpportunityId).Add(opportunityTeamMember);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - opportunity2OpportunityTeamMemberMapping.size() : ' + opportunity2OpportunityTeamMemberMapping.size());
                                                  
        //5.6.2  The Map should have at least one item
        System.assertNotEquals(0, opportunityTeamMembers.size(), 'We should have at least one Opportunity Member');
   }  */ 
    
      @isTest
      public static void createChatterNotifTest(){
        
        
        //creation of Set<String> listUsersToNotif, String body
        Set<String> listuserinit = new Set<String>();
        List<User> listUsers = [select Id from User limit 1];
        for(User usr:listUsers){
            listuserinit.add(usr.Id);
        }
        //insert listuserinit;
        
        String body = 'test test notif';
        Test.startTest();
         
        SalesTeamService.getInstance().createChatterNotif(listuserinit,body);
        list<FeedItem> result = [select Id from FeedItem];
		System.assertNotEquals(result.size(), 0);
		
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void uncheckUsersTest(){
        
        //creation of list user
        Set<String> listuserinit = new Set<String>();
        List<User> listUsers = [select Id, Update_Request_Sales_Team__c from User limit 1];
       
        for(User usr:listUsers){
            usr.Update_Request_Sales_Team__c = true;
            listuserinit.add(usr.Id);
        }
        
        Test.startTest();
        SalesTeamService.getInstance().uncheckUsers(listuserinit);
        User usr= [select Id, Update_Request_Sales_Team__c from user where Id = : listUsers[0].Id ];
        System.assertEquals(usr.Update_Request_Sales_Team__c , false);
        Test.stopTest();
    }
}