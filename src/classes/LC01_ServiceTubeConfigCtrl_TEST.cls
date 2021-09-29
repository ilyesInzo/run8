/**
 * <b>Unit Test Class LC01_ServiceTubeConfigCtrl_TEST</b>
 * @author EWA
 * @version 1.0 - Original
 * @history 1.0 - Original
 */
@isTest
public class LC01_ServiceTubeConfigCtrl_TEST {
    //Methods of the class LC01_ServiceTubeConfigCtrl_TEST
    /**
     * [testSetup description : data initialisation for the test]
     */
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
            acc.Type = 'Supplier';
            Database.SaveResult sr = Database.insert(acc, dml);            
            //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
            acc2.Type = 'Supplier';	
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
            
            //Creation of an Opportunity
            Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
            insert opp;
        
            //Creation of a Quote
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
            insert q;
            
            //Creation of 2 Product
            Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
	      	);
	     	insert subProd;
            
            Product2 prod = new Product2(Name = 'bottle 50ml', Family = 'Bottle', Product_Sub_Segment__c = subProd.Id,ProductCode='Test 1');
            insert prod;            
            Product2 prod2 = new Product2(Name = 'Tube 50ml', Family = 'Tube', Product_Sub_Segment__c = subProd.Id,ProductCode='Test 2');
            insert prod2;
        
            //Creation of 2 PricebookEntry
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;            
            PricebookEntry standardPrice2 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                UnitPrice = 5000, IsActive = true);
            insert standardPrice2;        
        
            //Create of 2 Team Allocation
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
                                                      Product2Id = prod.id, QuoteId = q.Id, Location__c = 'EU',Ref_RFQ__c = 'Test'
                                                      );
                  
            insert qli;

            //Insert a new PM_Selected_Tubes_Config__c
            PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');  
            Map<String, String> mapfilters = new Map<String, String>();
            mapfilters.put('Quote_item__c', qli.Id);
            mapfilters.put('Product_Segment__c', 'Plastic Tubes');
            mapfilters.put('Location__c', 'EU');
            pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
                      
            //Insert a new PM_Selected_Service_Tubes_Config__c
            PM_Selected_Service_Tubes_Config__c pmservice = new PM_Selected_Service_Tubes_Config__c(
                Quote_item__c=qli.Id,
                Tube_Segment__c='Plastic Tubes',
                Location__c=qli.Location__c,
                PM_Selected_Tubes_Config__c= pms.Id
            );
            insert pmservice;
        }
    }

    /**
     * [getUser0 description : return the first user created in the initialisation phase]
     */
    private static User getUser0(){
        return [SELECT Id, firstName, lastName, email, Username, EmailEncodingKey,
                        Alias, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey,
                        Additional__c, Director__c, KAM__c, Matricule_ADS__c,
                        Manager__c, ProfileId, By_Pass_VR__c, IsActive FROM USER LIMIT 1];
    }

    /**
     * [getPMService description : return the PMService created in the inialisation phase]
     */
    private static PM_Selected_Service_Tubes_Config__c getPMService(){
        return [SELECT Quote_item__c, Tube_Segment__c, Location__c, PM_Selected_Tubes_Config__c 
                        FROM PM_Selected_Service_Tubes_Config__c LIMIT 1];
    }

    /**
     * [getPMS description : return the PMS created in the initialisation phase] 
     */
    private static PM_Selected_Tubes_Config__c getPMS(){
        return [SELECT Diameter_mm__c, Head_Name__c, Dispensing_System_Family__c, Location__c 
                        FROM PM_Selected_Tubes_Config__c LIMIT 1];
    }

    /**
     * [testServiceTubeConfigCtrl1 description]
     */ 
    @isTest
    public static void testServiceTubeConfigCtrl1(){
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){        
            pmservice.BAG__c = 'Yes';
            pmservice.Plates__c = 'Yes';
            pmservice.BAT_Printing_proof__c = 'Yes';
            pmservice.Plate_HS_dye__c  = 'Texte 1 face';
            pmservice.BAT_Color_Matching_Sleeve__c = 'Yes';
            pmservice.BAT_Color_Matching_Cap__c = 'Specific Cap';
            pmservice.BAT_Color_Matching_Pumps__c = 'Yes';
            pmservice.BAT_Flat_printing_proof__c = 'Yes';
            pmservice.Toner_formulation_w_o_BAT__c = 'Yes';
            pmservice.B_A_T_HS_dye__c = 'Yes';
            pmservice.BAG_modification__c = 'Yes';
            pmservice.Type_of_tube__c = 'Standard tube';
            pmservice = (PM_Selected_Service_Tubes_Config__c)LC01_SelectedProductConfigCtrl.saveSelectedConfig(pmservice);
		                
	        pms.Sleeve_Material__c = 'Mono';
	        pms.Diameter_mm__c = null;
	        pms.Head_Name__c = '';
	        pms.Cap_Eurocode__c='';
	        pms.Cap_Color__c = 'WHITE / NATURAL';
	        pms.Sleeve_Color__c = '';
	        update pms;
	        pms = (PM_Selected_Tubes_Config__c)LC01_RECO_Ctrl.saveproductconfig(pms);    
        }    

        Test.stopTest();     
    }
    
    /**
     * [testServiceTubeConfigCtrl2 description]
     */
    @isTest
    public static void testServiceTubeConfigCtrl2(){  
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){	        
	        pms.Sleeve_Material__c = 'Mono';
	        pms.Diameter_mm__c = null;
	        pms.Head_Name__c = '';
	        pms.Cap_Eurocode__c='';
	        pms.Cap_Color__c = 'WHITE / NATURAL';
	        pms.Sleeve_Color__c = '';
	        update pms;
	        
	        List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new List<PM_Selected_Service_Tubes_Config__c>{pmservice};
	        
	        pmservicelist[0].Plate_HS_dye__c = 'Texte 2 faces';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
	        pmservicelist[0].Type_of_tube__c = 'Standard tube';
	        update pmservicelist;
		}    

        Test.stopTest();           
    }
      
    /**
     * [testServiceTubeConfigCtrl3 description]
     */ 
    @isTest
    public static void testServiceTubeConfigCtrl3(){
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){ 		        
	        List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new List<PM_Selected_Service_Tubes_Config__c>{pmservice};
	        pmservicelist[0].Plate_HS_dye__c = 'Texte 2 faces';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
	        pmservicelist[0].Type_of_tube__c = 'Standard tube';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
		    pmservicelist[0].Type_of_file__c = 'Specific File';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
		    pmservicelist[0].Number_of_items__c = 1;
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
			pmservicelist[0].Number_of_items__c = 2;
		    update pmservicelist;
	    }      

        Test.stopTest();         
    }
    
    /**
     * [testServiceTubeConfigCtrl4 description]
     */
    @isTest
    public static void testServiceTubeConfigCtrl4(){
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){	        		        
	        List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new List<PM_Selected_Service_Tubes_Config__c>{pmservice};
		    pmservicelist[0].Type_of_file__c = 'Specific File';
		    pmservicelist[0].Number_of_items__c = 1;
	        pmservicelist[0].Type_of_tube__c = 'Tube + Pump';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);		        
		}    

        Test.stopTest();           
    }
     
    /**
     * [testServiceTubeConfigCtrl5 description]
     */ 
    @isTest
    public static void testServiceTubeConfigCtrl5(){  
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){
          	pms.Diameter_mm__c = 25;
		    pms.Head_Name__c = 'CF92';
            update pms;
    		
            List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new  List<PM_Selected_Service_Tubes_Config__c>{pmservice};
            
   			pmservicelist[0].Number_of_items__c = null;
   			pmservicelist[0].Amount_per_item__c = '1';
   			pmservicelist[0].Quantity_needed_for_samples__c = 'Max 200 tubes';
            LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
        }   

        Test.stopTest();            
    }
      
    /**
     * [testServiceTubeConfigCtrl6 description]
     */
    @isTest
    public static void testServiceTubeConfigCtrl6(){  
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){
        	pms.Diameter_mm__c = 25;
			pms.Head_Name__c = 'CF92test';
	        update pms;
			
	        List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new  List<PM_Selected_Service_Tubes_Config__c>{pmservice};
	        pmservicelist[0].Quantity_needed_for_samples__c = 'Max 200 tubes';
	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
		}        

        Test.stopTest();     
    }
      
    /**
     * [testServiceTubeConfigCtrl7 description]
     */
    @isTest
    public static void testServiceTubeConfigCtrl7(){
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){
    	    pms.Diameter_mm__c = 25;
		    pms.NB_SS_Colors__c = 2;
            update pms;
        
		    pms.NB_SS_Colors__c = 1;
            update pms;
		
            List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new  List<PM_Selected_Service_Tubes_Config__c>{pmservice};
            pmservicelist[0].Quantity_needed_for_samples__c = 'Max 200 tubes';
            LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
	    }   

        Test.stopTest();            
    }
      
    /**
     * [testServiceTubeConfigCtrl8 description]
     */
    @isTest
    public static void testServiceTubeConfigCtrl8(){
        PM_Selected_Service_Tubes_Config__c pmservice = getPMService();
        PM_Selected_Tubes_Config__c pms = getPMS();
        User user0 = getUser0();
        user0.IsActive = true;
        update user0;

        Test.startTest();

        System.runAs(user0){
          	pms.Diameter_mm__c = 25;
  		    pms.Deco_Hot_Stamping__c = 'Yes';
  	        update pms;
  			
  	        List<PM_Selected_Service_Tubes_Config__c> pmservicelist = new  List<PM_Selected_Service_Tubes_Config__c>{pmservice};
  	        LC01_ServiceTubeConfigCtrl.calculateservicedetail(pmservicelist, pmservicelist);
	    }               

        Test.stopTest();
    }     
}