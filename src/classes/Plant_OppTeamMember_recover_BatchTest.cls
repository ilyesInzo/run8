@isTest
public class Plant_OppTeamMember_recover_BatchTest {

     @testSetup 
    private static void init() {

        //Create Some Users
        User u1 = TestFactory.newKamUser(12341);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        u1.By_Pass_VR__c = true;
        insert u1;
		 
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
        acc1.City__c='dorra';
        acc1.Street__c = '555   tCartault';
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
        qli1.Production_Plant__c='SF';
        insert qli1;
        
        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        qli2.Production_Plant__c='AK';
        insert qli2;
        List<Customer_Management_Area__c>  listManagArea=TestFactory.newCustomerManagementArea();
		List<Plant_and_Cluster__c> listPlantClus=TestFactory.newPlantAndCluster(listManagArea);
        insert listPlantClus;
        system.runAs(u1){
		 Plant_Segment_Users__c plantSeg1= TestFactory.newPlant_Segment_Users(listPlantClus.get(0),null,u1,'Plant');//PLant:SF
		Plant_Segment_Users__c plantSeg2= TestFactory.newPlant_Segment_Users(listPlantClus.get(3),null,u1,'Plant');//Plant:AK
		List<Plant_Segment_Users__c> listPlantSegUsers=new List<Plant_Segment_Users__c>();
        listPlantSegUsers.add(plantSeg1);
		listPlantSegUsers.add(plantSeg2);  
		insert listPlantSegUsers;
        }
       
    }

    static testMethod void testMethod1() 
    {
   
        Test.startTest();
        	user usr =[select id from user where Matricule_ADS__c ='12341' limit 1];
        system.debug('check qli plant ' +[select Production_Plant__c from quotelineItem where Production_Plant__c ='SF']);
            Plant_OppTeamMember_recover_Batch obj = new Plant_OppTeamMember_recover_Batch(usr.Id,2021);
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
}