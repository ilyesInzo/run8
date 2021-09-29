/** 
 * <b>Unit Test Class LCC01_Scorings_Controller_TestCase </b>
 * @author EWA
 * @version 1.1 - Delete SeeAllData, @testSetup et assertEqual
 * @history 1.0 - Version Initiale
 */
@isTest
private class LCC01_Scorings_Controller_TestCase{
    //Methods for the class LCC01_Scorings_Controller_TestCase
    /**
     * [testSetup description : Data initialisation for the unit test]
     */
    @testSetup
    static void testSetup(){
        //Getting record type
        Id dealscrRT = [select Id from RecordType where SobjectType =:'Scoring__c' and DeveloperName =: 'Deal'].Id;               
        Id customerscrRT = [select Id from RecordType where SobjectType =:'Scoring__c' and DeveloperName =: 'Customer'].Id;

        //Insert scoring
        Scoring__c dealscr = new Scoring__c(
            Name = 'Quote Name',
            Level_1_Key__c = 'testquote',
            Level_1_Value__c = 50,
            Dispensing__c = 5, 
            Tubes__c = 5,
            RecordTypeId = dealscrRT
        );
        insert dealscr;

        Scoring__c custscr = new Scoring__c(
            Name = 'Account Name',
            Level_1_Key__c = 'TestAcc',
            Level_1_Value__c = 50 ,
            Existing__c = 5,
            Prospect__c = 5,
            RecordTypeId = customerscrRT        
        );
        insert custscr;

        //Create Test Users for the Teams
        List<User> users = new List<User>();    
        for(integer i=1; i<=10; i++){                    
            users.add(TestFactory.newUser('test','user'+i,'SALES - KAM', true, true, true, true, 123+i));                               
        }
        insert users;

        System.runAs(users[0]){
            //Create Test Data
            Country__c country = TestFactory.getFrance();
            insert country;
            
            //Create Test Distribution Channel
            Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
            insert testDistrib;
            
            //Create Sales Area
            Sales_Area__c testArea = new Sales_Area__c(Name='Test');
            insert testArea;
            
            //Create Test Accounts and allow duplicate
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc = TestFactory.newAccount(country, testDistrib, testArea);
            acc.Type = 'Competitor';
            Database.SaveResult sr = Database.insert(acc, dml);
            
            //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
            acc2.Type = 'Competitor';
            sr = Database.insert(acc2, dml);
            
            //Create Test Sales Teams
            Sales_Team__c team1 = new Sales_Team__c();
            team1.KAM__c = users[0].id;
            team1.Manager__c = users[1].id;
            team1.Director__c = users[2].id;
            team1.Valid_From__c = Date.today().addYears(-1);
            team1.Valid_To__c = Date.today().addYears(3);
            team1.Sales_Team__c = 'test team 1';            
            insert team1;
            
            Sales_Team__c team2 = new Sales_Team__c();
            team2.KAM__c = users[4].id;
            team2.Manager__c = users[5].id;
            team2.Director__c = users[6].id;
            team2.Valid_From__c = Date.today().addYears(-1);
            team2.Valid_To__c = Date.today().addYears(3);
            team2.Sales_Team__c = 'test team 2';
            insert team2;
            
            
            //Get Standard Pricebook
            Id pricebookId = Test.getStandardPricebookId();
        
            Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
            insert opp;
        
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
            insert q;
            
            Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
      		);
      		insert subProd;
            
            Product2 prod = new Product2(Name = 'bottle 50ml', Product_Sub_Segment__c = subProd.Id, ProductCode='Test 2',
                                         Family = 'Bottle');
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Tube 50ml', Product_Sub_Segment__c = subProd.Id, ProductCode='Test 3',
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
        
            Sales_Allocations__c alloc2 = new Sales_Allocations__c();
            alloc2.Account__c = acc2.id;
            alloc2.Sales_Team__c = team2.id;
            alloc2.Product__c = 'BTL';
            alloc2.Product_Sub_Segment__c = prod2.id;
            alloc2.Valid_From__c = Date.today().addYears(-1);
            alloc2.Valid_To__c = Date.today().addYears(1);  
            insert alloc2;
        
            //Insert QLI
            QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',
                                                  Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');
            insert qli;  
        }
    }

    /**
     * [getUser0 description : return the first user created in the initialisation phase]
     */
    private static User getUser0(Id userId){
        return [SELECT Id, firstName, lastName, email, Username, EmailEncodingKey,
                        Alias, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey,
                        Additional__c, Director__c, KAM__c, Matricule_ADS__c,
                        Manager__c, ProfileId, By_Pass_VR__c, IsActive FROM USER where Id=: userId LIMIT 1];
    }

    /**
     * [getQli description : return the QuoteLineItem created in the initialisation phase]
     */
    private static QuoteLineItem getQli(){
        return [SELECT UnitPrice, Quantity, PricebookEntryId, Production_Cluster__c, Production_Plant__c,
                        Product2Id, QuoteId, Location__c, Quote.OwnerId FROM QuoteLineItem LIMIT 1];
    }

    /** 
     * [testscoring description]
     */
    @isTest
    static void testscoring() { 
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;
        
        Test.startTest();

        System.runAs(user0){

            QuoteLineItem queryqli = LC01_HomeCtrl.getQuoteItemById(qli.Id);

            System.assertNotEquals(null, queryqli, 'The method LC01_HomeCtrl.getQuoteItemById did not send back data');

            queryqli = LCC01_Scorings_Controller.initscorings(queryqli);
            queryqli = LCC01_Scorings_Controller.calculatescore(queryqli);
            queryqli = LCC01_Scorings_Controller.calculatedealscore(queryqli);
            queryqli = LCC01_Scorings_Controller.calculateservicescore(queryqli);
            map<String, List<String>> pickvalmap = LCC01_Scorings_Controller.getpicklistvalues('Deal', queryqli);
            
            queryqli.Location__c = 'US';
            queryqli = LCC01_Scorings_Controller.calculateservicescore(queryqli);   

        }      

        Test.stopTest();  
    }
    
    /**
     * [testMessage description]
     */
    @isTest
    static void testmessage() {
        map<String, String> getmessagevalueinfo = LC01_Message_Global_Config_Ctrl.getmessagevalueinfo('', 'Sleeve length conversion inches-mm', 'PM_Tubes_Config__c', 'Sleeve_Length_inches__c',
                                                     'Sleeve_Length_mm__c', 'US', 'Plastic');
        
        System.assertNotEquals(null, getmessagevalueinfo, 'The method LC01_Message_Global_Config_Ctrl.getmessagevalueinfo did not send back data');
                  
        Map<String, List<String>> getMapListValues = LC00_DependentFieldsCtrl.getMapListValues('PM_Tubes_Config__c','Diameter_inches__c',
                                                        new Map<String,String>{'Location__c' => 'US', 'Table_Name__c' => 'Diameter', 'Tubes_segment__c' => 'Plastic'},
                                                        new List<String>{'Shape__c'}, 'Diameter_inches__c');

        System.assertNotEquals(null, getMapListValues, 'The method LC00_DependentFieldsCtrl.getMapListValues did not send back data');
                                                        
        List<String> getmarketofapplst = LC01_RECO_Ctrl.getmarketofapplst('EU');

        System.assertNotEquals(null, getmarketofapplst, 'The method LC01_RECO_Ctrl.getmarketofapplst did not send back data');
        
    }    
}