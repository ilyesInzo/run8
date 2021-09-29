/**
 * <b>Unit Test Class LC01_SelectedProductConfigCtrl_TestCase</b>
 * @author EWA
 * @version 1.1 - Delete SeeAllData, @testSetup and Assert
 * @history 1.1 - Delete SeeAllData, @testSetup and Assert
 *          1.0 - Original
 */
@isTest
public class LC01_SelectedProductConfigCtrl_TestCase {
    //Method of the Unit Test Class.
    @testSetup
    public static void testSetup(){    
        //We need to get a standard pricebookId
        Id pricebookId = Test.getStandardPricebookId();

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
                
            Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
            insert opp;
        
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
            insert q;
            
            Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
      		);
      		insert subProd;
            
            Product2 prod = new Product2(Name = 'bottle 50ml', Family = 'Bottle', Product_Sub_Segment__c = subProd.Id);
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Tube 50ml', Family = 'Tube', Product_Sub_Segment__c = subProd.Id);
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
           // insert alloc2;
            
            //Insert QLI
            QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                    Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',
                                    Product2Id = prod.id, QuoteId = q.Id, Location__c = 'EU'); 
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
                        Manager__c, ProfileId, By_Pass_VR__c, IsActive FROM USER where Id =: userId LIMIT 1];
    }

    /**
     * [getQli description : return the QuoteLineItem created in the initialisation phase]
     */
    private static QuoteLineItem getQli(){
        return [SELECT UnitPrice, Quantity, PricebookEntryId, Production_Cluster__c, Production_Plant__c,
                        Product2Id, QuoteId, Location__c, Quote.OwnerId FROM QuoteLineItem LIMIT 1];
    }


    /**
     * [testSelectedProductConfigCtrl]
     */
    @isTest
    public static void testSelectedProductConfigCtrl(){   
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();

        System.runAs(user0){
            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');
            //qli.Location__c = 'EU';
            System.debug('@@@@ qli:'+ qli);
           // update qli;
            
            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'EU');
            
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            
            pms.Diameter_mm__c=50;
            pms.Head_Name__c='ER3';
            update pms;
                    PM_Tubes_Config__c tubeConf = new PM_Tubes_Config__c(Location__c='EU',Active__c = true,Table_Name__c = 'Deco NB Colors Possibility',Tubes_Segment__c='Plastic',Spec__c ='50_ER3');
            insert tubeConf;
            pms.Printing_technologies__c = 'Offset';
            Map <String, List<Integer>> getColors = LC01_SelectedProductConfigCtrl.getPlasticTubeEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Offset + Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPlasticTubeEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Flexo';
            getColors = LC01_SelectedProductConfigCtrl.getPlasticTubeEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Flexo + Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPlasticTubeEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPlasticTubeEUColors(pms, 'Plastic'); 
            
        }

        Test.stopTest();
    }
   
    /**
      * getSelectedConfig simulation Quote Case	
      */
   
        @isTest
    public static void testSelectedProductConfigCtrlSimulationQuote(){   
        QuoteLineItem qli = getQli();
        Quote q = [select id, Status from Quote limit 1];
        q.status = 'Simulation';
        Update q;
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();

        System.runAs(user0){
            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');
            //qli.Location__c = 'EU';
            System.debug('@@@@ qli:'+ qli);
           // update qli;
            
            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'EU');
            
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            system.assert(pms != null && pms.Name != null);
           //(PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.saveSelectedConfig(pms);
            LC01_SelectedProductConfigCtrl.getMOQ(qli.id);
            PM_Selected_Tubes_Config__c pms2 = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');
            LC01_SelectedProductConfigCtrl.saveSelectedConfig(pms2);
            LC01_SelectedProductConfigCtrl.getsObjectList('PM_Selected_Tubes_Config__c',mapfilters,'CreatedDate');
            LC01_SelectedProductConfigCtrl.getColorOptions(3);
        }

        Test.stopTest();
    }
    
    
    /**
     * [testSelectedProductConfigCtrlUS]
     */
    @isTest  
    public static void testSelectedProductConfigCtrlUS(){  
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();
          
        System.runAs(user0){

            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='US');

            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'US');
             PM_Tubes_Config__c tubeConf = new PM_Tubes_Config__c(Location__c='US',Active__c = true,Table_Name__c = 'Deco # Colors Possibility (full path)',Tubes_Segment__c='Plastic',Spec__c ='1_M4ILN');
            insert tubeConf;
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            
            qli.Location__c = 'US';
            qli = LC01_RECO_Ctrl.saveqli(qli);
            pms.Diameter_inches__c='1';
            pms.Head_Name__c='M4ILN';
            pms.Location__c='US';
            update pms;
            pms.Printing_type__c = 'Offset_Flexo_Silkscreen';
            Map <String, List<Integer>> getColors = LC01_SelectedProductConfigCtrl.getColors(pms, 'Plastic');         
        }

        Test.stopTest();
    }
      
    /**
     * [testSelectedProductConfigCtrlLaminateUS]
     */
    @isTest 
    public static void testSelectedProductConfigCtrlLaminateUS(){    
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();

        System.runAs(user0){

            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='US');

            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'US');
            
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            
            qli.Location__c = 'US';
            qli = LC01_RECO_Ctrl.saveqli(qli);
            pms.Diameter_inches__c='1';
            pms.Head_Name__c='M4ILN';
            pms.Location__c='US';
            update pms;
            pms.Printing_type__c = 'Offset';
            Map <String, List<Integer>> getColors = LC01_SelectedProductConfigCtrl.getLaminateUSColors(pms, 'Laminate');
            pms.Printing_type__c = 'Flexo';
            getColors = LC01_SelectedProductConfigCtrl.getLaminateUSColors(pms, 'Laminate');
            pms.Printing_type__c = 'Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getLaminateUSColors(pms, 'Laminate');
        }

        Test.stopTest();
    }
      
    /**
     * [testSelectedProductConfigCtrlPurefoilEU]
     */
    @isTest
    public static void testSelectedProductConfigCtrlPurefoilEU(){
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();

        System.runAs(user0){

            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');
            qli.Location__c = 'EU';
           // update qli;
             PM_Tubes_Config__c tubeConf = new PM_Tubes_Config__c(Location__c='EU',Active__c = true,Table_Name__c = 'Deco NB Colors Possibility',Tubes_Segment__c='Plastic',Spec__c ='25_M11');
            insert tubeConf;
            
            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'EU');
            
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
            
            pms.Diameter_mm__c=25;
            pms.Head_Name__c='M11';
            update pms;
           
            pms.Printing_technologies__c = 'Offset';
            Map <String, List<Integer>> getColors = LC01_SelectedProductConfigCtrl.getPurefoilEUColors(pms, 'Plastic');
            
             pms.Printing_technologies__c = 'Offset + Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPurefoilEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Flexo + Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPurefoilEUColors(pms, 'Plastic');
            pms.Printing_technologies__c = 'Silkscreen';
            getColors = LC01_SelectedProductConfigCtrl.getPurefoilEUColors(pms, 'Plastic');
        }     

        Test.stopTest();     
    }

    /**
     * [testLC01_WizardCtrl]
     */
    @isTest
    public static void testLC01_WizardCtrl(){
        QuoteLineItem qli = getQli();
        User user0 = getUser0(qli.Quote.OwnerId);
        user0.IsActive = true;
        update user0;        

        Test.startTest();

        System.runAs(user0){
			Integer i = LC01_WizardCtrl.getstep(qli.Id);
        }

        Test.stopTest();
    }
    
    /**
     * [testLC01_RECO_Ctrl1]
     */
    @isTest
    public static void testLC01_RECO_Ctrl1(){
        QuoteLineItem qli = getQli();

        Test.startTest();

    	LC01_RECO_Ctrl.saveToQuote(qli.Id, Label.PM_QuoteTemplateId_Tube_EU);

        Test.stopTest();
    	
    	string testblob = LC01_RECO_Ctrl.blobToString(Blob.valueOf('Unit Test Attachment Body'), 'UTF-8');

        System.assertNotEquals('', testblob, 'The method LC01_RECO_Ctrl.blobToString did not send back data');
    }
    
}