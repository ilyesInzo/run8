@isTest
public class LC01_PriceRecommendation_Test {
    @testSetup 
    private static void init() {
       //Create Some Users  
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1000));
        User u1 = TestFactory.newKamUser(12341);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        u1.By_Pass_VR__c = true;
        stUsers.add(u1);
        User u2 = TestFactory.newKamUser(43211);
        u2.Bypass_trigger__c = '';
        u1.By_Pass_VR__c = true;
        stUsers.add(u2);
        insert stUsers;

        insert TestFactory.newUser('System Administrator', 1);

        //List<Country__c> countries = TestFactory.newCountry();
        //insert countries;
List<Country__c> countries = new List<Country__c>();
        Country__c france = TestFactory.getFrance();
        countries.add(france);
        Country__c germany = TestFactory.getGermany();
        countries.add(germany);

        insert(countries);
        
        //Distribution Channel Data Initialisation
       
        List<Distribution_Channel__c> distributionChannels = new List<Distribution_Channel__c>();
        Distribution_Channel__c distributionChannel1 = TestFactory.newDistributionChannel('DIRECT SALES', '00001', 'E');
        distributionChannels.add(distributionChannel1);
        Distribution_Channel__c distributionChannel2 = TestFactory.newDistributionChannel('MASS MARKET', '00002', 'E');
        distributionChannels.add(distributionChannel2);

        insert(distributionChannels);

        
        //Sales Area Data Initialisation
        
        List<Sales_Area__c> salesAreas = new List<Sales_Area__c>();
        Sales_Area__c salesArea1 = TestFactory.newSalesArea('Interco Global Accounts', 'GA', 'FRC', 'Interco Global Acocunts', 'E', 'FRC', 'G');
        salesAreas.Add(salesArea1);
        Sales_Area__c salesArea2 = TestFactory.newSalesArea('Interco Key Accounts', 'KA', 'FRE', 'Interco Key Accounts', 'E', 'FRE', 'R');
        salesAreas.Add(salesArea2);
        insert(salesAreas);
        
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE','FR');
        state.Country__c = france.id; // Added by Achraf
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

        Account acc1 = TestFactory.newAccount(france.id,distributionChannel1.Id,salesArea.Id, state.Id);
        acc1.Street__c = 'Cartault';
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
        insert qli1;
        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        qli2.Total_Score__c=5;
        insert qli2;
 
        Sales_Team__c st = TestFactory.newSalesTeam(stUsers[3].Id, stUsers[0].Id, stUsers[1].Id, stUsers[2].Id);
        insert st;

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for(Product2 prod : products) {
            Sales_Allocations__c sa = new Sales_Allocations__c(
                account__c              = acc1.id,
                product_sub_segment__c  = prod.id,
                sales_team__c           = st.id,
                Valid_To__c             = SalesService.FUTURE_DATE
            );
            sas.add(sa);            
        }
      
        
       

        
       

        
        //State Data Initialisation
        

        List<State__c> stateRegions = new List<State__c>();
        State__c stateRegion1 = TestFactory.newState('Hebei', 'CN-13');
        stateRegions.Add(stateRegion1);
        State__c stateRegion2 = TestFactory.newState('Western Australia', 'AU-WA');
        stateRegions.Add(stateRegion2);
        insert(stateRegions);

        
        //Account Data Initialisation
        
        List<Account> accounts = new List<Account>();
        Account newAccount1 = TestFactory.newAccount(countries.get(0).Id, distributionChannels.get(0).Id,
                salesAreas.get(0).Id, stateRegions.get(0).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount1);    
        Account newAccount2 = TestFactory.newAccount(countries.get(1).Id, distributionChannels.get(1).Id,
                salesAreas.get(1).Id, stateRegions.get(1).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount2);    
        
        insert(accounts);

        
        //Product Segement Data initialisation      
        
        
        List<Product_Segment__c> productSegments = new List<Product_Segment__c>();
        Product_Segment__c productSegmentTube = TestFactory.newProductSegment('EN','Laminate Tubes','LAM');
        productSegments.add(productSegmentTube);
        Product_Segment__c productSegmentDisp = TestFactory.newProductSegment('EN','Sampler pumps','SAM');
        productSegments.add(productSegmentDisp);
        Product_Segment__c productSegmentOther = TestFactory.newProductSegment('EN','Pack & Accessories','HARD');
        productSegments.add(productSegmentOther);

        insert(productSegments);

        
        //Product Sub Segment Data Initialisation
                
        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegmentTube = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegmentTube.Id, 'LAM', 'Laminate Tubes', 20.0);
        productSubSegments.Add(productSubSegmentTube);
        Product_Sub_Segment__c productSubSegmentDisp = TestFactory.newProductSubSegment('DIS', 'E', 'SAM', productSegmentDisp.Id, 'LAM', 'Laminate Tubes', 10.0);
        productSubSegments.Add(productSubSegmentDisp);
        Product_Sub_Segment__c productSubSegmentOther = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegmentOther.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegmentOther);

        insert(productSubSegments);

        
        //Product2 Data Initialisation
        
        List<Product2> products2 = new List<Product2>();
        Product2 productPriceMatrix = TestFactory.newProduct('Tubes', 'Laminated Tubes', 'LAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix);
        Product2 productPriceMatrix2 = TestFactory.newProduct('Dispensing', 'Sampler pumps', 'SAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix2);
        Product2 productLinkforce = TestFactory.newProduct('Beauty Solutions', 'Accessories', 'HARD', productSubSegmentOther.ID, 30.0);
        products2.add(productLinkforce);
        insert(products2);

        
        //Opportunity Data Initialisation
        
        List<Opportunity> newOpportunities = new List<Opportunity>();        
        Opportunity newOpportunityPriceMatrix = TestFactory.newOpportunity('newOpportunityPriceMatrix', 'Retention',
            accounts.get(0).Id);
        newOpportunities.add(newOpportunityPriceMatrix);    
        Opportunity newOpportunityLinkforce = TestFactory.newOpportunity('newOpportunityLinkforce', 'Retention',
            accounts.get(1).Id);
        newOpportunities.add(newOpportunityLinkforce);  
        insert(newOpportunities);
        
        

        //Quote Data initialisation
        
        List<Quote> newQuotes = new List<Quote>();
        //Id priceBookId = Test.getStandardPricebookId();       
        Date quoteDueDate1 = Date.newInstance(2019,1,1);
        Quote newQuote1 = TestFactory.newQuote('P0', quoteDueDate1, 'Draft', newOpportunities.get(0).Id,
            priceBookId);
        newQuotes.add(newQuote1);
        Date quoteDueDate2 = Date.newInstance(2019,1,1);
        Quote newQuote2 = TestFactory.newQuote('P0', quoteDueDate2, 'Draft', newOpportunities.get(1).Id,
            priceBookId);
        newQuotes.add(newQuote2);       
        
        insert(newQuotes);
        
        
        //Standard Price
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();

        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productPriceMatrix.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = productLinkforce.Id,
            UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice2);

        insert standardPrices;

        //Quote Line Data Initialisation
        
        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();   
        QuoteLineItem qliPriceMatrix = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(0).Id, standardPrices.get(0).Id );
        newQuoteLineItems.add(qliPriceMatrix);

        QuoteLineItem qliPriceMatrix2 = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(1).Id, standardPrices.get(0).Id );
          qliPriceMatrix2.Total_Score__c=5.0;        
        newQuoteLineItems.add(qliPriceMatrix2);

        QuoteLineItem qliLinkForce = TestFactory.newQuoteLineItem(newQuotes.get(1).Id,
            products2.get(2).Id, standardPrices.get(1).Id );
        newQuoteLineItems.add(qliLinkForce);

        insert(newQuoteLineItems);

        
        //PM Selected Tubes Config Data Initialisation
        
        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//Combo_Num_Plate_Changes__c,Combo_Num_Tubes_Artwork__c,Combo_Num_Versions__c
        newPMSelectedTubesConfig.Quote_item__c = qliPriceMatrix.id;
        newPMSelectedTubesConfig.Is_Combo__c='Yes';
        newPMSelectedTubesConfig.Combo_Num_Versions__c =2;
            newPMSelectedTubesConfig.Combo_Num_Tubes_Artwork__c =10000;
            newPMSelectedTubesConfig.Combo_Num_Plate_Changes__c=6;
            newPMSelectedTubesConfig.Number_of_ref_per_run__c =6;
        newPMSelectedTubesConfig.Number_of_tubes_per_artwork_in_Ku__c=10;
            
        insert(newPMSelectedTubesConfig);
 PM_Selected_Tubes_Config__c newPMSelectedTubesConfig22 = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//Combo_Num_Plate_Changes__c,Combo_Num_Tubes_Artwork__c,Combo_Num_Versions__c
        newPMSelectedTubesConfig.Quote_item__c = qli2.id;
        
        insert(newPMSelectedTubesConfig22);
         PM_Selected_Tubes_Config__c newPMSelectedTubesConfig2 = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//,,
        newPMSelectedTubesConfig2.Quote_item__c = qliPriceMatrix.id;
        newPMSelectedTubesConfig2.Combo_Num_Plate_Changes__c=4.0;
        newPMSelectedTubesConfig2.Combo_Num_Tubes_Artwork__c=1000.0;
        newPMSelectedTubesConfig2.Is_Combo__c='Yes';
        newPMSelectedTubesConfig2.Combo_Num_Versions__c=2.0;
        newPMSelectedTubesConfig2.Number_of_ref_per_run__c=4.0;
        newPMSelectedTubesConfig2.Number_of_tubes_per_artwork_in_Ku__c=44.0;
        insert(newPMSelectedTubesConfig2);
           PM_Selected_Tubes_Config__c newPMSelectedTubesConfig11 = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//,,
        newPMSelectedTubesConfig11.Quote_item__c = qliPriceMatrix.id;
        newPMSelectedTubesConfig11.Combo_Num_Plate_Changes__c=4.0;
        newPMSelectedTubesConfig11.Combo_Num_Tubes_Artwork__c=1000.0;
        newPMSelectedTubesConfig11.Is_Combo__c='Yes';
        newPMSelectedTubesConfig11.Combo_Num_Versions__c=2.0;
        newPMSelectedTubesConfig11.Number_of_ref_per_run__c=4.0;
        newPMSelectedTubesConfig11.Number_of_tubes_per_artwork_in_Ku__c=44.0;
        insert(newPMSelectedTubesConfig11);

        //PM Price Recommendation Data Initialisation
        
        PM_Price_Recommendation__c newPMPriceRecommendation = TestFactory.getPMPriceRecommendation(
            newPMSelectedTubesConfig, qliPriceMatrix, 10, 100, 150, 250, 400, 300
        );
        newPMPriceRecommendation.Discount__c = 10;
        newPMPriceRecommendation.Min_Threshhold_Discount__c = 5;
        newPMPriceRecommendation.Max_Threshhold_Discount__c = 20;
        insert(newPMPriceRecommendation);
         PM_Price_Recommendation__c newPMPriceRecommendation22 = TestFactory.getPMPriceRecommendation(
            newPMSelectedTubesConfig, qli2, 10, 100, 150, 250, 400, 300
        );
        newPMPriceRecommendation22.Discount__c = 10;
        newPMPriceRecommendation22.Min_Threshhold_Discount__c = 5;
        newPMPriceRecommendation22.Max_Threshhold_Discount__c = 20;
        insert(newPMPriceRecommendation22);
        
        //PM Price Detail Data Initialisation
        
        PM_Price_Detail__c newPMPriceDetail = TestFactory.getPMPriceDetail(
                77, 75, 50, newPMSelectedTubesConfig, 'Basis Price', qliPriceMatrix, 'Tube & Head'
        );
        insert(newPMPriceDetail);
 PM_Price_Detail__c newPMPriceDetail22 = TestFactory.getPMPriceDetail(
                77, 75, 50, newPMSelectedTubesConfig, 'Basis Price', qli2, 'Tube & Head'
        );
        insert(newPMPriceDetail22);
        PM_Price_Detail__c newPMPriceDetail1 = TestFactory.getPMPriceDetail(
                70, 65, 40, newPMSelectedTubesConfig2, 'Combo', qliPriceMatrix, 'Others'
        );
        insert(newPMPriceDetail1);
        PM_Price_Detail__c newPMPriceDetail31 = TestFactory.getPMPriceDetail(
                70, 65, 40, newPMSelectedTubesConfig, 'Combo', qliPriceMatrix, 'Others'
        );
        insert(newPMPriceDetail31);
        //PM MOQ Price Data Initialisation
       
        PM_MOQ_Price__c newPMMOQPrice = TestFactory.newMoqPrice(
                300.0, 999, 'Tubes', newPMSelectedTubesConfig.Id, qliPriceMatrix.Id, 347.08 
        );
        insert(newPMMOQPrice);
        PM_MOQ_Price__c newPMMOQPrice11 = TestFactory.newMoqPrice(
                300.0, 999, 'Tubes', newPMSelectedTubesConfig11.Id, qliPriceMatrix.Id, 347.08 
        );
        insert(newPMMOQPrice11);
        PM_MOQ_Price__c newPMMOQPrice22 = TestFactory.newMoqPrice(
                300.0, 500.0, 'Tubes', newPMSelectedTubesConfig22.Id, qli2.Id, 347.08 
        );
        insert(newPMMOQPrice22);
        

        //PM Review NetPrice per MOQ Data Initialisation
        

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ = TestFactory.getPMReviewNetPriceperMOQ(
            8.3,
            0.0,
            100,
            newPMPriceDetail,
            newPMPriceRecommendation,
            qliPriceMatrix,
            'Yellow',
            0,
            False
            );
        insert(newPMReviewNetPricePerMOQ);
PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ22 = TestFactory.getPMReviewNetPriceperMOQ(
            8.3,
            0.0,
            100,
            newPMPriceDetail22,
            newPMPriceRecommendation22,
            qli2,
            'Yellow',
            0,
            False
            );
        insert(newPMReviewNetPricePerMOQ22);
        Id scoringRT;
        for(RecordType rt : [select Id from RecordType where SobjectType =:'Scoring__c' and DeveloperName = 'Customer']){
            scoringRT = rt.Id;
        }
        Scoring__c score = new Scoring__c(name='testScore', RecordTypeId = scoringRT, location__c = 'EU', Criteria_API_Name__c='Description');
        insert score;

        

        //SelectedTubeService
        PM_Selected_Service_Tubes_Config__c newPMSelectedSrvTubesConfig = new PM_Selected_Service_Tubes_Config__c(Quote_item__c = qliPriceMatrix.id, Location__c = 'EU', PM_Selected_Tubes_Config__c = newPMSelectedTubesConfig.id);
        insert(newPMSelectedSrvTubesConfig);
        //LC01_PriceRecommendation.getSelectedPriceCorridor('', 'PET CARE','ICN2' ,'Brand owner');
        PM_Selected_Service_Tubes_Config__c newPMSelectedSrvTubesConfig22 = new PM_Selected_Service_Tubes_Config__c(Quote_item__c = qli2.id, Location__c = 'EU', PM_Selected_Tubes_Config__c = newPMSelectedTubesConfig22.id);
        insert(newPMSelectedSrvTubesConfig22);
        //PM_Selected_Tubes_Config__c
        LC01_PriceRecommendation.location='EU';
        LC01_PriceRecommendation.quoteLineItemId =qli1.id;
       LC01_PriceRecommendation.selectedTube= newPMSelectedTubesConfig;
        
        LC01_PriceRecommendation.initilise();
        LC01_PriceRecommendation.getSelectedPriceCorridor('', 'PET CARE','ICN2' ,'Brand owner');
       //PM Selected Dispensing Config Data Initialisation
      //PM_Selected_Dipsensing_config__c selectedDispensingConfig =[select id,Quote_item__c from PM_Selected_Dipsensing_config__c  limit 1];

        Test.startTest();

        
        PM_Selected_Dipsensing_Config__c newPMSelectedDispensingConfig = TestFactory.newPMSelectedDispConfig(
            'EU', 'Sampler pumps', qliPriceMatrix2.id
        );
        newPMSelectedDispensingConfig.Quote_item__c = qliPriceMatrix2.id;
        insert(newPMSelectedDispensingConfig);
        LC01_PriceRecommendation.selectedDispensingConfig=newPMSelectedDispensingConfig;
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(100.0,qliPriceMatrix,'100.0');
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(50.0,qliPriceMatrix,'51');
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(40.0,qliPriceMatrix,'51');
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(qliPriceMatrix,40,65);
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(qliPriceMatrix,50,75);
        LC01_PriceRecommendation.insertOtherMOQWithCalcul('400',qliPriceMatrix.id);
        LC01_PriceRecommendation.insertOtherMOQWithCalcul('300',qliPriceMatrix.id);
        LC01_PriceRecommendation.productSegment='Lotion pumps';
        LC01_PriceRecommendation.quoteLineItem=newPMSelectedDispensingConfig.name;
        
        LC01_PriceRecommendation.item=qliPriceMatrix;
        LC01_PriceRecommendation.getPriceRecommendations(qliPriceMatrix.id);
        LC01_PriceRecommendation.selectedTube=newPMSelectedTubesConfig;
           LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(100.0,qliPriceMatrix,'100.0');
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(50.0,qliPriceMatrix,'51');
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(40.0,qliPriceMatrix,'51');
        
       // LC01_PriceRecommendation.getExistingPriceRecommendation(qli2.id);
        //LC01_PriceRecommendation.selectedDispensingConfig=selectedDispensingConfig ;
       // LC01_PriceRecommendation.getSelectedPriceCorridor('', 'PET CARE','ICN2' ,'Brand owner');
        Test.stopTest();
       
       
        
        
        
    }
      @isTest
    static void getExistingTest() {
        //QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
        
        PM_Selected_Tubes_Config__c PMSelectedTubesConfig = [select id,Quote_item__c from  PM_Selected_Tubes_Config__c  limit 1];
        LC01_PriceRecommendation.selectedTube= PMSelectedTubesConfig;
        LC01_PriceRecommendation.quoteLineItemId =PMSelectedTubesConfig.Quote_item__c;
        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', null, null, null, null
        );
      newPMSelectedTubesConfig.Quote_item__c=PMSelectedTubesConfig.Quote_item__c;
       insert newPMSelectedTubesConfig;
       test.startTest();
      LC01_PriceRecommendation.getExistingPriceRecommendation(PMSelectedTubesConfig.Quote_item__c);
        
          test.stopTest();              
    }
    @isTest
    static void insertComboPriceLineForSpecificMoqTest() {
       // 
         PM_Selected_Tubes_Config__c PMSelectedTubesConfig = [select id,Quote_item__c from  PM_Selected_Tubes_Config__c  limit 1];
        QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem where id =:PMSelectedTubesConfig.Quote_item__c limit 1];
        //PMSelectedTubesConfig.Is_Combo__c='Yes';
       
       
            
        
        test.startTest();
       //update PMSelectedTubesConfig;
        LC01_PriceRecommendation.selectedTube= PMSelectedTubesConfig;
        LC01_PriceRecommendation.selectedDispensingConfig=null;
        LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(qli,100,200);
        
        //LC01_PriceRecommendation.insertComboPriceLineForSpecificMoq(qli,70,75);
        test.stopTest(); 
    }
    
          @isTest
    static void getExistingDispensingTest() {
        //QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
        
       PM_Selected_Dipsensing_config__c selectedDispensingConfig =[select id,Quote_item__c,Product_segment__c from PM_Selected_Dipsensing_config__c  limit 1];
         PriceReco priceReco1 = new PriceReco();
        PriceReco priceReco3 = new PriceReco(true, 10.0, true, true, '5', 10.0, priceReco1);      
        List<PriceReco> priceRecoToInsert = new List<PriceReco>();
        priceRecoToInsert.add(priceReco1);
       
        priceRecoToInsert.add(priceReco3);
        
       test.startTest();
          PM_Global_Config__c gb = new PM_Global_Config__c();
        gb.Table_name__c='TPG/PPG Threshold';
        gb.SKU_Activation_Date__c=System.today();
        gb.SKU_Expiration_Date__c=System.today();
        gb.TPG__c=4.0;
        gb.PPG__c=5.0;
        gb.Location__c='EU';
        insert (gb);
         PM_Global_Config__c gb1 = new PM_Global_Config__c();
        gb1.Table_name__c='Product Segment';
        gb1.Product_Segment__c='PLASTIC TUBES';
        gb1.Name_for_discount_corridors__c='Personal, Body & Hair Care';
        gb1.Location__c='EU';
        //insert (gb1);
        LC01_PriceRecommendation.quoteLineItemId =selectedDispensingConfig.Quote_item__c;
        LC01_PriceRecommendation.selectedDispensingConfig=selectedDispensingConfig;
       LC01_PriceRecommendation.getExistingPriceRecommendation(selectedDispensingConfig.Quote_item__c);
        LC01_PriceRecommendation.getPriceRecommendations(selectedDispensingConfig.Quote_item__c);
        LC01_PriceRecommendation.insertPriceReco( priceRecoToInsert, selectedDispensingConfig.Quote_item__c, selectedDispensingConfig.id, selectedDispensingConfig.Product_segment__c);
        
          test.stopTest();              
    }
    
      @isTest
    static void insertPriceRecoTest() {
       //insertPriceReco(List<PriceReco> priceRecoToInsert, String qlId, String selectedProductId, String productSegmenta) {
      
        PriceReco priceReco1 = new PriceReco();
        PriceReco priceReco3 = new PriceReco(true, 10.0, true, true, '5', 10.0, priceReco1);      
        List<PriceReco> priceRecoToInsert = new List<PriceReco>();
        priceRecoToInsert.add(priceReco1);
       
        priceRecoToInsert.add(priceReco3);
        
        LC01_PriceRecommendation.productSegment='Plastic Tubes';//'Brand owner'
        QuoteLineItem qli = [select id,QuoteId,Quote.Name,Brand_Positionning__c from QuoteLineItem limit 1];
        LC01_PriceRecommendation.item=qli;
        
        PM_Selected_Tubes_Config__c PMSelectedTubesConfig = [select id,Quote_item__c,Product_segment__c,Is_Combo__c  from  PM_Selected_Tubes_Config__c  limit 1];

        test.startTest();
        if(PMSelectedTubesConfig.Is_Combo__c!='Yes')
        {PMSelectedTubesConfig.Is_Combo__c='Yes';
            update PMSelectedTubesConfig;}
         LC01_PriceRecommendation.selectedTube=PMSelectedTubesConfig;
        LC01_PriceRecommendation.productSegment='Plastic Tubes';//'Brand owner'
        LC01_PriceRecommendation.insertPriceReco( priceRecoToInsert, PMSelectedTubesConfig.Quote_item__c, PMSelectedTubesConfig.id, PMSelectedTubesConfig.Product_segment__c);
        
        LC01_PriceRecommendation.calculateVolumeThreshhold( 'Plastic Tubes');
        LC01_PriceRecommendation.getDistributionChannel('Brand owner');
        
        LC01_PriceRecommendation.getPriceRecommendations(PMSelectedTubesConfig.Quote_item__c);
        LC01_PriceRecommendation.productSegment='Plastic Tubes';
//perfole then getPriceRecommendation
         LC01_PriceRecommendation.location='EU';
        LC01_PriceRecommendation.getMOQThreshHoldToDisplay(priceReco1,'Plastic Tubes' , PMSelectedTubesConfig.Quote_item__c, 'BRAZIL', PMSelectedTubesConfig.id);
       
        LC01_PriceRecommendation.insertOtherMOQWithCalcul('5',PMSelectedTubesConfig.Quote_item__c);
        LC01_PriceRecommendation.insertOtherMOQWithCalcul('300',PMSelectedTubesConfig.Quote_item__c);
      
        test.stopTest();
        
    } 
    @isTest
    static void getPriceTest() {
        //QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
        PM_Selected_Tubes_Config__c PMSelectedTubesConfig = [select id,Quote_item__c,Product_segment__c,Is_Combo__c  from  PM_Selected_Tubes_Config__c  limit 1];

        if(PMSelectedTubesConfig.Is_Combo__c!='Yes')
        {PMSelectedTubesConfig.Is_Combo__c='Yes';
            update PMSelectedTubesConfig;}
       test.startTest();
    LC01_PriceRecommendation.getPriceRecommendation(PMSelectedTubesConfig.Quote_item__c);
          test.stopTest();              
    }
    @isTest
    static void sendEmailTest() {
         QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
       test.startTest();
        LC01_PriceRecommendation.sendEmail('message', qli.Id);
        
       // System.assert(result.size() == 0);
        test.stopTest();              
    }
    @isTest
    static void getQLIRecordTest() {
        QuoteLineItem qli = [select id,QuoteId,Quote.Name from QuoteLineItem limit 1];
        
        test.startTest();
        LC01_PriceRecommendation.getQLIRecord(qli.id);
        PM_Global_Config__c gb = new PM_Global_Config__c();
        gb.Table_name__c='TPG/PPG Threshold';
        gb.SKU_Activation_Date__c=System.today();
        gb.SKU_Expiration_Date__c=System.today();
        gb.TPG__c=4.0;
        gb.PPG__c=5.0;
        gb.Location__c='EU';
        insert (gb);
        LC01_PriceRecommendation.getCorridorSKU();
       // System.assert(result.size() == 0);
        test.stopTest();
    }
}