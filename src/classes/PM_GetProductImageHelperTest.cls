/**
 * <b>Unit Test Class PM_GetProductImageHelperTest</b>
 * @author EWA
 * @version 1.1 - Adding assert test and creating a @testSetup method
 * @history 1.1 - Adding assert test and creating a @testSetup method
 *          1.0 - Version Initiale
 */
@isTest
public class PM_GetProductImageHelperTest {     
    //Methods for the class test_getProductImage
    @testSetup
    public static void testSetup(){
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
	        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id,
	        //							Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
	        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
            acc.Type = 'Competitor';
	        Database.SaveResult sr = Database.insert(acc, dml);	        
	        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,
	        //							Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
	        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
            acc2.Type = 'Competitor';
	        sr = Database.insert(acc2, dml);
	        
	        //Create 2 Test Sales Teams
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
	        
	        //Create a test opportunity   
	        System.debug('@@@@ AccountId:' + acc.Id); 
	        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
	        insert opp;
	    
	    	//Create a test quote 
	        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), 
	        					date_Quote_Won__c=Date.today(),  Status='Closed Won');
	        insert q;
	        
	        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
      		);
      		insert subProd;
	        
	        //Create 2 product2 for test
	        Product2 prod = new Product2(Name = 'bottle 50ml', Family = 'Bottle', Product_Sub_Segment__c = subProd.Id,ProductCode='Test 1');
	        insert prod;
	        
	        Product2 prod2 = new Product2(Name = 'Tube 50ml', Family = 'Tube', Product_Sub_Segment__c = subProd.Id,ProductCode='Test 2');
	        insert prod2;
	      
	    	//Create 2 PriceBookEntry for test
	        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
	        insert standardPrice;
	        
	        PricebookEntry standardPrice2 = new PricebookEntry(
	            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
	            UnitPrice = 5000, IsActive = true);
	        insert standardPrice2;
	    
	    
	    	//Create 2 Team Allocation for test
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
	        
	        
	        
	        //Insert QLI for test
	        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,Production_Cluster__c = 'Albea China',
	        							Production_Plant__c ='Hong Kong PC', Product2Id = prod.id, QuoteId = q.Id, Location__c = 'EU', Ref_RFQ__c = 'Test');	            
	        insert qli;
	        
	        //Insert stc for test
	        PM_Selected_Tubes_Config__c stc = new PM_Selected_Tubes_Config__c(Quote_item__c=qli.Id);	        
	        stc.Product_Segment__c = 'Plastic Tubes';
			stc.location__c = 'EU';
			stc.shape__c = 'Cylindrical';
			stc.diameter_mm__c = 25;
			stc.Fill_Capacity_ml__c = 30;
			stc.Sleeve_Material__c = 'Mono';
			stc.Sleeve_Material_Mix__c = 'HDPE/LDPE 30/70%';
			stc.sleeve_length_mm__c = 100;
			stc.Dispensing_System_Family__c = 'Screw head';
			stc.head_name__c = 'M11';
			stc.cap_name__c = 'Balm cap';
			stc.Dispensing_System_Name__c = 'M11';
			stc.Cap_Eurocode__c = 'M112528';
        	insert stc;	        
	    }
    }

    /**
     * [getPMStc Description : return the PM_Selected_Tubes_Config record created in the initialisation phase]
     * @return [PM_Selected_Tubes_Config__c : the record created in the initialisation phase]
     */
    private static PM_Selected_Tubes_Config__c getPMStc(){
    	return [SELECT Quote_item__c, Product_Segment__c, location__c, shape__c, diameter_mm__c, 
    					Fill_Capacity_ml__c, Sleeve_Material__c, Sleeve_Material_Mix__c,
						sleeve_length_mm__c, Dispensing_System_Family__c, head_name__c, cap_name__c, 
						Dispensing_System_Name__c, Cap_Eurocode__c 
			   FROM PM_Selected_Tubes_Config__c 
			   LIMIT 1];
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

    /**
     * [test_getProductImage description]
     */
    @isTest
	public static void test_getProductImage(){ 
		PM_Selected_Tubes_Config__c stc = getPMStc();

        // prepare mock for getproductImage
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetProductImage_response_OK');
        mock.setStatusCode(200);
        mock.setStatus('OK');
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        
        Test.startTest();

        //first call to create doc
        String result = PM_GetProductImageHelper.getProductImage(stc);

        //Assert test
        System.assertNotEquals(null, result, 'PM_GetProductImageHelper.getProductImage did not send back data');     

        Test.stopTest();
    }
    
    /**
     * [test_getProductImage2 description]
     */
    @isTest
    public static void test_getProductImage2(){ 
		PM_Selected_Tubes_Config__c stc = getPMStc();

    	Test.startTest();

        stc.Dispensing_System_Family__c = 'Airless pump';
        String result = PM_GetProductImageHelper.getProductImage(stc);

        //Assert test
        System.assertNotEquals(null, result, 'PM_GetProductImageHelper.getProductImage did not send back data');

        Test.stopTest();
    }

    /**
     * [test_getProductImage3 description]
     */
    @isTest
    public static void test_getProductImage3(){ 
		PM_Selected_Tubes_Config__c stc = getPMStc();

    	Test.startTest();

        stc.Dispensing_System_Family__c = 'Applicator';
        String result = PM_GetProductImageHelper.getProductImage(stc);

        //Assert test
        System.assertNotEquals(null, result, 'PM_GetProductImageHelper.getProductImage did not send back data');

        Test.stopTest();
    }

    /**
     * [test_getProductImage4 description]
     */
    @isTest
    public static void test_getProductImage4(){    	 
		PM_Selected_Tubes_Config__c stc = getPMStc();

    	Test.startTest();

        stc.Dispensing_System_Family__c = 'Twist-off';
        String result = PM_GetProductImageHelper.getProductImage(stc);

        //Assert test
        System.assertNotEquals(null, result, 'PM_GetProductImageHelper.getProductImage did not send back data');

        Test.stopTest();
    }
    
    /**
     * [test_getProductImageWS description]
     */
    @isTest
    public static void test_getProductImageWS() {
        // prepare mock
        MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(Label.PM_MM_Auth_Endpoint, 'Auth_response_OK');
        multimock.setStaticResource(Label.PM_MM_GetProductImage_Endpoint, 'GetProductImage_response_OK');
        multimock.setHeader('Content-Type', 'application/json');
        multimock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Test.startTest();      
        
        //call the Mix&Match webservice getProductImage
        PM_MM_Webservices.PM_TubesProductConfigWrapper tubeconfigWrapper = new PM_MM_Webservices.PM_TubesProductConfigWrapper();
        HttpResponse res = PM_MM_Webservices.getProductImage(tubeconfigWrapper, '123ABCXYZ');
        
        //Check
        //// Verify response received contains values returned by
        // the mock response.
        // This is the content of the static resource.
        System.assertNotEquals(null,res.getBody());
        System.assertEquals(200,res.getStatusCode());
        System.assertEquals('application/json', res.getHeader('Content-Type'));  
        
        //Test de-serialize json to PM_getProductImageResponseWraper
        PM_getProductImageResponseWraper getproductsImageResponseWrapper = PM_getProductImageResponseWraper.parse(res.getBody());
        
        Test.stopTest();

        //check parsing result
        System.assertNotEquals(null,getproductsImageResponseWrapper.body,'Enable to parse Body from PM_getProductImageResponseWraper');
        
    }
    
    /**
     * [test_buildDocumentTest description]
     */
    @isTest
    public static void test_buildDocumentTest(){
    	Test.startTest();

        // Get product image folder 
        Folder fl = [SELECT AccessType, DeveloperName, Id, IsReadonly, Name, NamespacePrefix, Type 
                     FROM Folder 
                     WHERE DeveloperName='PricematriX_Product_Images' 
                     AND IsReadonly=true AND Type='Document' LIMIT 1];

        // build document record
        Document doc = PM_GetProductImageHelper.buildDocument('contentBase64', 'docName',fl.Id);
        System.assertNotEquals(null, doc.Id, 'Enable to insert document');

        Test.stopTest();
    }
    
    /**
     * [test_auth description]
     */
    @isTest
    public static void test_auth() {
        // prepare mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Auth_response_OK');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();    

        // get access token
        HttpResponse res = PM_MM_Webservices.getAccessToken();
        
        //Check
        //// Verify response received contains values returned by
        // the mock response.
        // This is the content of the static resource.
        System.assertNotEquals(null, res.getBody());
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('application/json', res.getHeader('Content-Type'));  
        
        //Test de-serialize json to PM_AuthResponseWraper
        PM_AuthResponseWraper authResponseWrapper = PM_AuthResponseWraper.parse(res.getBody());

        Test.stopTest();

        //check parsing result
        System.assertNotEquals(null,authResponseWrapper.token,'Enable to parse Token from authResponseWrapper');
        System.assertNotEquals(null,authResponseWrapper.expireDate, 'Enable to parse expireDate from authResponseWrapper');
        
        
    }
    
    /**
     * [test_fillTubesConfigWrapperFromTubesConfig]
     */
    @isTest
    public static void test_fillTubesConfigWrapperFromTubesConfig() {       
    	QuoteLineItem qli = getQli();

        // create selected PM_Selected_Tubes_Config__c        
        PM_Selected_Tubes_Config__c stc= new PM_Selected_Tubes_Config__c(Quote_item__c=qli.Id);
        insert stc;

        Test.startTest();
        
        PM_MM_Webservices.PM_TubesProductConfigWrapper tubeconfigWrap = new PM_MM_Webservices.PM_TubesProductConfigWrapper();

        //Assert test
        System.assertNotEquals(null, tubeconfigWrap, 'PM_MM_Webservices.PM_TubesProductConfigWrapper did not send back data');

        // fill product config
        tubeconfigWrap.QuoteItemId = stc.quote_Item__c;
        tubeconfigWrap.config = PM_GetProductImageHelper.fillTubesConfigWrapperFromTubesConfig(stc);
        System.debug(' ########## test_fillTubesConfigWrapperFromTubesConfig pmConfig: '+JSON.serialize(tubeconfigWrap));

        Test.stopTest();
    }
}