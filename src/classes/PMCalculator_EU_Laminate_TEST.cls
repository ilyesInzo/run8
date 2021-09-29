/**
 * <b>Unit Test Class PMCalculator_EU_Laminate_TEST</b>
 * @author EWA
 * @version 1.1 - AssertEquals, and pretty printings
 * @history 1.0 - Version Initiale
 */
@isTest
public class PMCalculator_EU_Laminate_TEST {
 //Methods of the class PMCalculator_EU_Laminate_TEST
 /**
  * [testMethod1 description]
  */
 @isTest
 static void testMethod1(){
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
  //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,
  //                            Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
  Account acc = TestFactory.newAccount(country, testDistrib, testArea);
  insert acc;

  //Get Standard Pricebook
  Id pricebookId = Test.getStandardPricebookId();

  Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
  insert opp;

  Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(),
          date_Quote_Won__c=Date.today(),  Status='Draft',Skonto_for_cash_payment__c='3');
  insert q;

  Product_Sub_segment__c subProd = new Product_Sub_segment__c(
          Name = 'Iron Lotion pumps'
  );
  insert subProd;
  Product2 prod = new Product2(Name = 'Laminate Tubes', Family = 'Tubes',	IsActive=true, Product_Sub_Segment__c = subProd.Id);
  insert prod;

  PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
          UnitPrice = 10000, IsActive = true);
  insert standardPrice;

  //Insert QLI
  QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
          Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');
  qli.Market_Of_Application__c = 'BODY CARE';
  qli.Customer_Type__c = 'Brand Owner';
  qli.Location__c = 'EU';
  qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
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

  //Effective start of the test
  Test.startTest();

  LC01_Review_EU_PlasticController.detailReviewMapClass testMaps = new LC01_Review_EU_PlasticController.detailReviewMapClass();
  testMaps = LC01_Review_EU_PlasticController.getPriceDetails(qli.id, 15);
  testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.setAllDiscounts(200, 250, testMaps.PriceDetailMap,  testMaps.ReviewPriceMap);
  testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.updatedReviewPriceMap(testMaps.ReviewPriceMap);

  System.assertNotEquals(null, testMaps, 'LC01_Review_EU_PlasticController.getPriceDetails did not send back data.');

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

  PM_Tubes_Config__c CDI = new PM_Tubes_Config__c();
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
     
  PM_Tubes_Pricing__c testPricing1 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1Head_Test1-01');
     
  PM_Tubes_Pricing__c testPricing2 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard3-01');
     
     PM_Tubes_Pricing__c testPricing3 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard5-03');
     PM_Tubes_Pricing__c testPricing4 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TestEurocodePeel seal Other printing technology');
     PM_Tubes_Pricing__c testPricing5 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard');
     PM_Tubes_Pricing__c testPricing6 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1Head_TestTestEurocodeWHITE');
     PM_Tubes_Pricing__c testPricing7 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard6-07');
     
     PM_Tubes_Pricing__c testPricing8 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard8-01');
     PM_Tubes_Pricing__c testPricing9 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard7-01');
     PM_Tubes_Pricing__c testPricing10 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard10-02');
     PM_Tubes_Pricing__c testPricing11 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard10-03');
          PM_Tubes_Pricing__c testPricing12 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '5TG1standard13-01');
     
     PM_Tubes_Pricing__c testPricing13 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = 'PAYMENT60 days');
     PM_Tubes_Pricing__c testPricing14 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = 'STOCKAGEYes');
     PM_Tubes_Pricing__c testPricing15 = new PM_Tubes_Pricing__c(Version__c = 3,Location__c = 'EU',
                                                             	Tubes_Segments__c = 'Laminate',X10__c = 5,
      									X15__c = 5,X20__c = 5,Ref__c = '');

     
     insert new List<PM_Tubes_Pricing__c>{testPricing,testPricing1,testPricing2,testPricing3,testPricing4,testPricing5,testPricing6,testPricing7,
         							testPricing8,testPricing9,testPricing10,testPricing11,testPricing12,testPricing13,testPricing14,testPricing15};

  //  insert testSelectedConfig;
  PM_Selected_Tubes_Config__c testSelectConfig = new PM_Selected_Tubes_Config__c();
  testSelectConfig.Quote_item__c = qli.id;
  testSelectConfig.Product_segment__c = 'Laminate';
  testSelectConfig.Location__c = 'EU';
  testSelectConfig.Diameter_mm__c = 5;
  testSelectConfig.Shape__c = 'Cylindrical';
  testSelectConfig.Head_Name__c = 'Head_Test';
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
  testSelectConfig.Payment_terms__c='60 days';
  testSelectConfig.Manual_Packing__c='Yes';
  testSelectConfig.PE_Bag__c='Yes';
  testSelectConfig.Metallization__c='Yes';
  insert testSelectConfig;

  PMCalculator_EU_Laminate pmCalcEULaminate = new PMCalculator_EU_Laminate(testSelectConfig);
  pmCalcEULaminate.calculate();

  Test.stopTest();
 }

}