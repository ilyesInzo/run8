@isTest
public class LC01_RECO_EU_RecapTableCtrl_Test {

    @testSetup
    private static void init() {

        //Create Test Users for the Teams
        //Create Test Users for the Teams
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id;

        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];


        for(integer i=1; i<=10; i++){
            String orgId = 'Albea';

            User tuser = TestFactory.newUser('test','user'+i, KAM.Name, true, true,true, true, i+1000);
            /*new User(  firstname = 'test',
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
                                    ProfileId = KAM.id);*/
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

        //    System.runAs(users[0]){

        //Create country
        List<Country__c> countries = TestFactory.newCountry();
        insert countries;

        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
        insert distCountry1;

        //Create Sales Area
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create Test Accounts

        Account acc = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        insert acc;

        Account acc2 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
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

        /*Sales_Team__c team2 = new Sales_Team__c();
        team2.KAM__c = users[4].id;
        team2.Manager__c = users[5].id;
        team2.Director__c = users[6].id;
        //team2.Additional__c = users[7].id;
        team2.Valid_From__c = Date.today().addYears(-1);
        team2.Valid_To__c = Date.today().addYears(3);
        team2.Sales_Team__c = 'test team 2';
        insert team2;*/


        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();

        

        Product_Sub_segment__c subProduct = new Product_Sub_segment__c(
                Name = 'Iron Lotion pumps'
        );
        insert subProduct;

        Product2 prod = new Product2(Name = 'bottle 50ml', Product_Sub_Segment__c = subProduct.Id,
                Family = 'Bottle');
        insert prod;

        Product2 prod2 = new Product2(Name = 'Tube 50ml', Product_Sub_Segment__c = subProduct.Id,
                Family = 'Tube');
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
        
		Opportunity opp = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc.Id);
       	opp.Sales_Allocation_Id__c=alloc1.Id;
        insert opp;

        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
        insert q;
        /*Sales_Allocations__c alloc2 = new Sales_Allocations__c();
        alloc2.Account__c = acc2.id;
        alloc2.Sales_Team__c = team2.id;
        alloc2.Product__c = 'BTL';
        alloc2.Product_Sub_Segment__c = prod2.id;
        alloc2.Valid_From__c = Date.today().addYears(-1);
        alloc2.Valid_To__c = Date.today().addYears(1);

        insert alloc2;*/

        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                PricebookEntryId= standardPrice.id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c ='Hong Kong PC',
                Product2Id = prod.id,
                QuoteId = q.Id,
                Location__c = 'EU',
                Innovation__c = 'No',
                Sub_Segment_Copy__c = 'Foam pumps',
                Based_on_Alb_a_Concept__c = 'Velvet'
        );

        insert qli;
         QuoteLineItem qli2 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                PricebookEntryId= standardPrice.id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c ='Hong Kong PC',
                Product2Id = prod.id,
                QuoteId = q.Id,
                Location__c = 'EU',
                Innovation__c = 'No',
                Sub_Segment_Copy__c = 'Foam pumps',
                Based_on_Alb_a_Concept__c = 'Velvet'
        );

        insert qli2;
        PM_Selected_Tubes_Config__c pselectTube= TestFactory.newPMSelectedTubeConfig('EU', 'LubeLaminate',  qli.Id );
        insert pselectTube;
        PM_Price_Detail__c pmPriceDetail= TestFactory.getPMPriceDetail(100, 50, 100,pselectTube, 'priceDetail', qli, 'Cap');
        insert pmPriceDetail;
        PM_Price_Recommendation__c pmPriceRecommendation= TestFactory.getPMPriceRecommendation(pselectTube,qli,50, 200, 100, 200,300, 100);
        insert  pmPriceRecommendation;
        PM_Review_NetPrice_per_MOQ__c pricOffer= TestFactory.getPMReviewNetPriceperMOQ(100, 2,50,  pmPriceDetail, pmPriceRecommendation,qli, 'red', 20, true);
        insert pricOffer;
    }
   /* public testmethod static void getSelectedConfig(){
        test.startTest();
        QuoteLineItem qli= [select Id from QuoteLineItem Limit 1];
        PM_Selected_Tubes_Config__c pm= LC01_RECO_EU_RecapTableCtrl.getSelectedConfig(qli.Id);
        System.assert(pm!=null);

        test.stopTest();
    }*/
    public testmethod static void saveSelectedConfig(){
        test.startTest();
        PM_Selected_Tubes_Config__c selectedTube= [select Id from PM_Selected_Tubes_Config__c Limit 1];
        LC01_RECO_EU_RecapTableCtrl.saveSelectedConfig(selectedTube);
        test.stopTest();
    }
    public testmethod static void getFinalPriceOffer(){
        test.startTest();
        QuoteLineItem qli= [select Id from QuoteLineItem Limit 1];
        List<PM_Review_NetPrice_per_MOQ__c> priceOffer= LC01_RECO_EU_RecapTableCtrl.getFinalPriceOffer(qli.Id);
        System.assert(priceOffer !=null);

        test.stopTest();
    }
    public testmethod static void sendEmail(){
        test.startTest();
        QuoteLineItem qli= [select Id from QuoteLineItem Limit 1];
        LC01_RECO_EU_RecapTableCtrl.sendEmail('TEst Class LC01_RECO_EU_RecapTableCtrl Send Mail', qli.Id,UserInfo.getUserEmail(),'test  subject');

        test.stopTest();
    }
    public testmethod static void getKamManagerEMail(){
        test.startTest();
        QuoteLineItem qli= [select Id,QuoteId from QuoteLineItem  Limit 1];        
         String email=LC01_RECO_EU_RecapTableCtrl.getKamManagerEMail(qli.QuoteId);
        System.assert(email !=null);
        test.stopTest();
    }


}