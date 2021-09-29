@isTest
public class PM_Calculator_TEST {

    /* static testmethod void testMethod1(){
     
     	String pid = [Select id from Profile where Name='System Administrator'].Id; 
       
    	 //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test',Customer_Size__c='GA');
        insert testArea;
        
        //Create Test Accounts
        Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft',Skonto_for_cash_payment__c='3');
        insert q; 
        
        Product2 prod = new Product2(Name = 'Laminate Tubes', 
                                     Family = 'Tubes',	IsActive=true);
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

    	//Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                                  Product2Id = prod.id, QuoteId = q.Id,ID_Calculette__c='PM'
                                                  );
        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
       // qli.Customer_Country__c = 'Germany';
        insert qli;

    	
        
        
        //Create Price Details
        List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();
        
        for(integer i=1; i<=4; i++){
            
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i+10.50;
            newPriceDetails.Name = 'test'+i;
            
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;
        
        LC01_Review_EU_PlasticController.detailReviewMapClass testMaps = new LC01_Review_EU_PlasticController.detailReviewMapClass();
            
        testMaps = LC01_Review_EU_PlasticController.getPriceDetails(qli.id, 15);
        
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.setAllDiscounts(200, 250, testMaps.PriceDetailMap,  testMaps.ReviewPriceMap);
        
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.updatedReviewPriceMap(testMaps.ReviewPriceMap);
        
        //Insert PM_MOQ_price__c
        PM_MOQ_price__c testMOQPrice = New  PM_MOQ_price__c();
        
        testMOQPrice.Quote_item__c = qli.id;
        testMOQPrice.MOQ_Max__c = 50;
        testMOQPrice.MOQ_Min__c = 25;
        testMOQPrice.List_Price__c = 200.50;
        
        insert testMOQPrice;
        
        
        
        //Insert productSegmentGlobalConfigs
        PM_Global_Config__c productSegmentGlobalConfigs = new  PM_Global_Config__c();
        productSegmentGlobalConfigs.Table_name__c = 'Product Segment';
        productSegmentGlobalConfigs.Product_Segment__c = 'Laminate Tubes';
        productSegmentGlobalConfigs.Location__c = 'EU';
        productSegmentGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_1';
        
        insert productSegmentGlobalConfigs;
        
        //Insert marketAppGlobalConfigs
        PM_Global_Config__c marketAppGlobalConfigs = new  PM_Global_Config__c();
        marketAppGlobalConfigs.Table_name__c = 'Market of Application';
        marketAppGlobalConfigs.Location__c = 'EU';
        marketAppGlobalConfigs.Market_of_Application__c = 'BODY CARE';
        marketAppGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_MARKET';
        
        insert marketAppGlobalConfigs;
        
        //Insert macroMarketAppGlobalConfigs 
        PM_Global_Config__c macroMarketAppGlobalConfigs = new  PM_Global_Config__c();
        macroMarketAppGlobalConfigs.Table_name__c = 'Customer Type';
        macroMarketAppGlobalConfigs.Location__c = 'EU';
        macroMarketAppGlobalConfigs.Customer_Type__c = 'Brand owner';
        macroMarketAppGlobalConfigs.Name_for_discount_corridors__c = '4';
        
        insert macroMarketAppGlobalConfigs;
        //corridorDistributionChannel = FILLERS & DISTRIBUTORS
        
        //Inset PM_Tubes_Config__c groupe
        PM_Tubes_Config__c groupe = new PM_Tubes_Config__c();
        groupe.GROUPES_1__c = '10_Test';
        groupe.GROUPES_2__c = 10;
        groupe.Location__c='EU'; 
        
        insert groupe;
        
        PM_Tubes_Config__c lengthUpcharge =new PM_Tubes_Config__c();
        lengthUpcharge.Location__c = 'EU';
        lengthUpcharge.Diameter_mm__c = 10;
        lengthUpcharge.Table_name__c = 'Standard Length';
        lengthUpcharge.STD_LENGTH__c = '10';
        insert lengthUpcharge;
        
        PM_Tubes_Config__c capFeature =new PM_Tubes_Config__c();
        capFeature.Location__c = 'EU';
        capFeature.Diameter_inches__c = '2';
        capFeature.Table_name__c = 'CAP FEATURE';
        capFeature.Shrink_band__c = '10';
        capFeature.Hot_Stamping__c = '5';
        insert capFeature;
        
        PM_Tubes_Config__c printEffect =new PM_Tubes_Config__c();
        printEffect.Location__c = 'EU';
        printEffect.Table_name__c = 'Print Effect';
        printEffect.Print_Effect_Options__c = 'Test Print';
        insert printEffect;
        
        PM_Tubes_Config__c quality =new PM_Tubes_Config__c();
        quality.Location__c = 'EU';
        quality.Table_name__c = 'Quality Upcharge';
        quality.Quality_Level__c = '2';
        quality.Tubes_segment__c = 'Plastic';
        insert quality;
        
        
         
         
        PM_Tubes_Config__c CDI =new PM_Tubes_Config__c();
        CDI.Location__c = 'EU';
        CDI.Table_name__c = 'CDI Impact Cap / head';
        CDI.Cap_nb__c = 'TestEurocode';
        CDI.Tubes_segment__c = 'Laminate';
        CDI.Cap_wt__c = '2';
        CDI.Concatenate__c = '2Head_Test';
        CDI.Hd_Wt__c = 5;
        insert CDI;
        
        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing = new PM_Tubes_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'EU';
        testPricing.Tubes_Segments__c = 'Laminate';
        testPricing.X10__c = 5;
        testPricing.X15__c = 5;
        testPricing.X20__c = 5;
        testPricing.X25__c = 5;
        testPricing.X30__c = 5;
        testPricing.X50__c = 5;
		testPricing.X75__c = 5;
        testPricing.X100__c = 5;
        testPricing.X200__c = 5;
        testPricing.X250__c = 5;
        testPricing.X300__c = 5;
        testPricing.X500__c = 5;
        testPricing.Ref__c = '1010TG1STANDARD3-01';
        
        insert testPricing;
       
        //  insert testSelectedConfig;
        PM_Selected_Tubes_Config__c testSelectConfig = new PM_Selected_Tubes_Config__c();
        testSelectConfig.Quote_item__c = qli.id;
        testSelectConfig.Product_segment__c = 'Laminate Tubes';
        testSelectConfig.Location__c = 'EU';
        testSelectConfig.Diameter_mm__c = 10;
        testSelectConfig.Shape__c = 'Cylindrical';
        testSelectConfig.Head_Name__c = 'Test';
        testSelectConfig.Sleeve_type__c = 'Sleeve_Test';
        testSelectConfig.Sleeve_Color__c = 'Sleeve_Color_Test';
        testSelectConfig.Nouveau_Platts__c = 5;
        testSelectConfig.Sleeve_Material_Mix__c = 'High Density';
        testSelectConfig.Peel_Seal__c = 'Yes';
        testSelectConfig.Consigned_Cap__c = 'Yes';
        testSelectConfig.Manual_Capping__c = 'Yes';
        testSelectConfig.Cap_Hot_Stamping__c = 'Yes';
        testSelectConfig.Shrink_band__c = 'Yes';
        testSelectConfig.Printing_type__c = 'SILKSCREEN';
        testSelectConfig.NB_Offset_Colors__c = 5;
        testSelectConfig.NB_Flexo_Colors__c = 5;
        testSelectConfig.Deco_Hot_Stamping__c = 'Yes';
        testSelectConfig.Coating__c = 'Matte';
        testSelectConfig.UV_Inhibitor__c = 'Yes';
        testSelectConfig.Double_Pigment__c = 'Yes';
        testSelectConfig.Pallet__c = 'Heat Treated Wooden Pallet';
        testSelectConfig.Polybag__c = 'Yes';
        testSelectConfig.Quality_Level__c = '2';
        testSelectConfig.Number_of_ref_per_run__c = 2;
        testSelectConfig.Number_of_tubes_per_artwork_in_Ku__c = 5;
        testSelectConfig.Cap_Eurocode__c ='TestEurocode';
        testSelectConfig.Printing_Effects__c = '360 degree';
        testSelectConfig.Cap_Name__c='Cap';
        //testSelectConfig.Delivery__c = 'Delivered';
        testSelectConfig.Sleeve_length_mm__c=5;
        testSelectConfig.Head_Color__c='White';
        testSelectConfig.Rondelle__c='Yes';
        testSelectConfig.NB_SS_Colors__c=2;
        testSelectConfig.Hologram__c='Yes';
        testSelectConfig.Cold_Stamping__c='Yes';
        testSelectConfig.Metalic_Flexo__c='Yes';
        testSelectConfig.Silkscreen__c='Yes (1 color)';
        testSelectConfig.Cold_Hot_Foil__c='Yes';
        testSelectConfig.insert__c='Yes';
        testSelectConfig.Combo_Num_Versions__c=2;
        testSelectConfig.Combo_Num_Tubes_Artwork__c=2;
        testSelectConfig.Combo_Num_Plate_Changes__c=2;
        testSelectConfig.Stockage__c='Yes';
        testSelectConfig.Payment_terms__c='Yes';
        testSelectConfig.Manual_Packing__c='Yes';
        testSelectConfig.PE_Bag__c='Yes';
        insert testSelectConfig;
     
        PM_Calculator testPmCalc = new PM_Calculator(testSelectConfig);
        testPmCalc.calculate(); 
         
     }*/
}