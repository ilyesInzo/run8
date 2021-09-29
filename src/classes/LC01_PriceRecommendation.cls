public without sharing class LC01_PriceRecommendation {
    @testVisible private static String quoteLineItemId { get; set; }
    @testVisible private static String quoteLineItem { get; set; }
    @testVisible private static String location { get; set; }
    @testVisible private static Integer annualVolume { get; set; }
    @testVisible private static String productSegment { get; set; }
    @testVisible private static QuoteLineItem item { get; set; }
    @testVisible private static PM_Selected_Tubes_Config__c selectedTube { get; set; }
    @testVisible private static PM_Selected_Dipsensing_config__c selectedDispensingConfig { get; set; }
    //Discount + 7 MOQ to Display..
    private static Integer MAX_ROW = 8;
    public static List<PriceReco> priceRecos;
    public static PriceReco errorReco;
    public static PriceReco othermoqpriceReco;
    public static String othermoqValue;
    public static List<PM_MOQ_price__c> moqPrices;
    @testVisible
    private static void initilise() {
        errorReco = new PriceReco();
        errorReco.errorMessage = '';

        item = [
                select Copy_quote_status__c,Customer_Country__c,CreatedDate,quote.Account.Country__r.PricematriX_Region__c, quote.Account.Country__r.Zone_code__c, quote.Account.Country__r.Name,id, Product_Sub_segment__c, Market_Of_Application__c, Purefoil_Segment__c,Product_Line__c,
                        Customer_Type__c, Customer_Size__c, Quantity, Location__c,
                        //Quote.Brand_Positionning__c, Quote.TOTAL_SCORING_SCORE__c
                        Brand_Positionning__c, Total_Score__c
                from QuoteLineItem
                where Id = :quoteLineItemId
        ];
        //productSegment = item.Product_Sub_segment__c; //From Reco
        system.debug('@@qama item.quote.Account.Country__r.Zone_code__c = ' + item.quote.Account.Country__r.Zone_code__c);

        productSegment = ('SAMPLER PUMPS'.equalsIgnoreCase(item.Product_Sub_segment__c) ? 'SAMPLERS' : item.Product_Sub_segment__c);
        location = item.Location__c;
        annualVolume = Integer.valueOf(item.Quantity);

        if (item.Quantity <= 0 || item.Product_Sub_segment__c == null) {
            System.debug('-->test1');
            errorReco.errorMessage = 'Please complete product configuration (Annual Volume) in order to display the pricing tool recommendations';
        }
        productSegment = ('SAMPLER PUMPS'.equalsIgnoreCase(item.Product_Sub_segment__c) ? 'SAMPLERS' : item.Product_Sub_segment__c);
        if (item.Purefoil_Segment__c && 'Plastic Tubes'.equalsIgnoreCase(item.Product_Sub_segment__c)) {
            //isPurefoil = true;
            productSegment = 'Purefoil Tubes';
            System.debug('-->test2');
        }
        //productSegment = item.Product_Sub_segment__c; //From Reco
        if (productSegment.toUpperCase().contains('TUBES')) {
            List<PM_Selected_Tubes_Config__c> selectedTubes = [
                    select id, Diameter_mm__c, Head_Name__c, Cap_Eurocode__c,
                            Cap_Name__c, Sleeve_Material__c, //Laminate
                            Printing_technologies__c,  //Plastic
                            Diameter_inches__c, Sleeve_type__c, Printing_type__c,  //For US
                            Billing_Currency_Rate__c
                    from PM_Selected_Tubes_Config__c
                    where Quote_item__c = :quoteLineItemId
                    order by createdDate DESC, lastModifiedDate DESC NULLS LAST
            ];
            System.debug('-->test3');
            if (selectedTubes != null && selectedTubes.size() > 0) {
                System.debug('-->test4');
                if (selectedTubes.size() == 1 || selectedTubes.get(0).Diameter_mm__c != null || selectedTubes.get(0).Diameter_inches__c != null)
                    selectedTube = selectedTubes.get(0); else {
                    System.debug('-->test5');
                    for (PM_Selected_Tubes_Config__c tub : selectedTubes) {
                        if (tub.Diameter_inches__c != null || tub.Diameter_mm__c != null) {
                            System.debug('-->test6');
                            selectedTube = tub;
                            break;
                        }
                    }
                    if (selectedTube == null)selectedTube = selectedTubes.get(0);

                    //selectedTube = selectedTubes.get(1);
                }
            } else {
                System.debug('-->test7');
                errorReco.errorMessage = Label.LBL_PRICE_RECO_ERROR_NO_DISCOUNT_CORRIDOR;
            }
        } else {

            List<PM_Selected_Dipsensing_config__c> selectedDispensingTubes = [
                    select id, Product_Name__c, Attachment__c, Actuator__c, Pump_Segmentation__c,
                            Collar__c, Engine_Name__c, Product_Hierarchy__c, Engine_Neck__c, Billing_Currency_Rate__c
                    from PM_Selected_Dipsensing_config__c
                    where Quote_item__c = :quoteLineItemId
            ];
            if (selectedDispensingTubes != null && selectedDispensingTubes.size() > 0) {
                selectedDispensingConfig = selectedDispensingTubes.get(0);
            } else {
                errorReco.errorMessage = Label.LBL_PRICE_RECO_ERROR_NO_DISCOUNT_CORRIDOR;
            }
        }

    }

    @AuraEnabled
    public static QuoteLineItem getQLIRecord(String qliId) {
        List<QuoteLineItem> qli = [select id, QuoteId, Quote.Status from QuoteLineItem where id = :qliId];
        if (qli != null && qli.size() > 0) return qli[0]; else return null;
    }

    @AuraEnabled
    public static Map<String, Object> getPriceRecommendation(String qliId) {

        System.debug('#########getPriceRecommendation########');

        Map<String, Object> result = new Map<String, Object>();
        quoteLineItemId = qliId;
        initilise();

        String marketApplication = item.Market_Of_Application__c; //From Reco
        String customerType = item.Customer_Size__c; //From Reco
        String customerScoringType = item.Customer_Type__c;


        System.debug('QLC RECEIVED.....');
        //Use the exisitng one if already created...

        System.debug(item);

        priceRecos = new List<PriceReco>();
        //Step 1: Get Pricing Corridor. //Calculate the three price corridor and get the selected one
        if (selectedTube != null || selectedDispensingConfig != null) {


            //Need to check if the Price Recommendation already exist
            //Else do calculation again
            PM_Discount_corridor__c selectedPriceCorridor = getSelectedPriceCorridor(productSegment, marketApplication, customerType, customerScoringType);
            system.debug('CORRIDOR FOUND');
            system.debug(selectedPriceCorridor);


            //Step 2: Get Volume Threshhold
            PM_Global_Config__c volumeThreshHolds = calculateVolumeThreshhold(productSegment);
            system.debug('VOLUME THRESHHOLD FOUND');
            system.debug(volumeThreshHolds);

            //Step 3: Get the Discount Recommended
            PriceReco priceDiscountRecommended = new PriceReco(
                    volumeThreshHolds == null || volumeThreshHolds.Min_Volume_thresholds__c == null ? null : volumeThreshHolds.Min_Volume_thresholds__c,
                    volumeThreshHolds == null || volumeThreshHolds.Max_Volume_thresholds__c == null ? null : volumeThreshHolds.Max_Volume_thresholds__c,
                    selectedPriceCorridor, item.Total_Score__c);
            system.debug('PRICE DISCOUNT RECOMMENDED FOUND');

            //Step 4: Calculate Price Recommendation Table
            //Get the columns from MOQ Threshold Displayed
            if (productSegment.toUpperCase().contains('TUBES')) {
                priceRecos = getMOQThreshHoldToDisplay(priceDiscountRecommended, productSegment, quoteLineItem, item.Customer_Country__c, selectedTube.Id);
            } else {
                priceRecos = getMOQThreshHoldToDisplay(priceDiscountRecommended, productSegment, quoteLineItem, item.Customer_Country__c, selectedDispensingConfig.Id);
            }

            //TODO : GET OTHER MOQ AND ADD THEM TO THE LIST TO UPDATE
            //Get the list of specific MOQs
            list<PM_Price_Recommendation__c> liSpecificPriceRecos = new list<PM_Price_Recommendation__c>();
            for (PM_Price_Recommendation__c specReco : [
                    select id, Min_Threshhold_Discount__c,Lin1_Discount__c,Lin2_Discount__c,
                            Lin3_Discount__c,Max_Threshhold_Discount__c
                    from PM_Price_Recommendation__c
                    where Quote_Line_Item__c = :qliId and MOQ__c = 999
            ]) {
                //update the discountsMin_Threshhold_Discount__c
                specReco.Min_Threshhold_Discount__c = priceDiscountRecommended.minThreshHoldValue.setScale(3, System.roundingMode.DOWN);
                specReco.Lin1_Discount__c = priceDiscountRecommended.lin1Value.setScale(3, System.roundingMode.DOWN);
                specReco.Lin2_Discount__c = priceDiscountRecommended.lin2Value.setScale(3, System.roundingMode.DOWN);
                specReco.Lin3_Discount__c = priceDiscountRecommended.lin3Value.setScale(3, System.roundingMode.DOWN);
                specReco.Max_Threshhold_Discount__c = priceDiscountRecommended.maxThreshHoldValue.setScale(3, System.roundingMode.DOWN);

                liSpecificPriceRecos.add(specReco);
            }

            if (errorReco.errorMessage == '') {

                String selectedProductId = (selectedTube == null ? selectedDispensingConfig.Id : selectedTube.Id);
                //The price has been found, insert the object
                insertPriceReco(priceRecos, item.Id, selectedProductId, productSegment);
                //update the list of specific price recos
                update liSpecificPriceRecos;
                //Fill the matrix of eight rows if no error
                priceRecos = fillTable(priceRecos, false);
            } else {
                //Return only one Record with ErrorMessage
                priceRecos = new List<PriceReco>();
                priceRecos.add(errorReco);
            }
        }

        result.put('priceReco', priceRecos);

        if (moqPrices == null || moqPrices.size() <= 0)
            moqPrices = new List<PM_MOQ_price__c>();

        result.put('prices', moqPrices);

        return result;
        //return priceRecos;
    }


    @AuraEnabled
    public static Map<String, Object> getExistingPriceRecommendation(String qliId) {
        Map<String, Object> result = new Map<String, Object>();
        List<PriceReco> priceRecoToInsert = new List<PriceReco>();
        String message = 'SUCCESS';
        system.debug('getExistingPriceRecommendation');
        quoteLineItemId = qliId;
        moqPrices = new List<PM_MOQ_price__c>();
        initilise();
        List<PM_Price_Recommendation__c> existingPriceRecoms = null;
        List<PM_Price_Recommendation__c> listSpecificMOQRecom = null;
        String configId = '';
        boolean otherMOQFilled = false;
        map<decimal, PM_MOQ_price__c> mapMoqRecods = new map< decimal, PM_MOQ_price__c> ();

        if (selectedTube != null) {
            system.debug('SELECTED TUBE' + selectedTube);
            configId = selectedTube.id;
            existingPriceRecoms = [
                    Select id, MOQ__c, List_Price__c, Lin1_Discount__c,Display__c,Other_MOQ__c,
                            round_Lin1_Price__c, Lin1_Price__c, Lin2_Discount__c,round_Lin2_Price__c, Lin2_Price__c, Lin3_Discount__c, Lin3_Price__c,
                            round_Lin3_Price__c, Max_Threshhold_Discount__c,round_Max_Threshhold_Price__c, Max_Threshhold_Price__c, Min_Threshhold_Discount__c, Min_Threshhold_Price__c,
                            round_Min_Threshhold_Price__c, PM_Selected_Dipsensing_Config__c, PM_Selected_Tubes_Config__c,PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c, Quote_Line_Item__c,
                            Quote_Line_Item__r.Total_Score__c,Quote_Line_Item__r.selected_corridor__c
                    from PM_Price_Recommendation__c
                    where PM_Selected_Tubes_Config__c = :selectedTube.id
                    and other_moq__c = null //exculude specific moqs
                    order by MOQ__c ASC
            ];
            //get the last modified specific moq and add it to the list to return
            listSpecificMOQRecom = [
                    Select id, MOQ__c, List_Price__c, Lin1_Discount__c,Display__c,Other_MOQ__c,
                            round_Lin1_Price__c, Lin1_Price__c, Lin2_Discount__c,round_Lin2_Price__c, Lin2_Price__c, Lin3_Discount__c, Lin3_Price__c,
                            round_Lin3_Price__c, Max_Threshhold_Discount__c,round_Max_Threshhold_Price__c, Max_Threshhold_Price__c,
                            Min_Threshhold_Discount__c, Min_Threshhold_Price__c,round_Min_Threshhold_Price__c
                            , PM_Selected_Dipsensing_Config__c, PM_Selected_Tubes_Config__c,PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c, Quote_Line_Item__c,
                            Quote_Line_Item__r.Total_Score__c,Quote_Line_Item__r.selected_corridor__c
                    from PM_Price_Recommendation__c
                    where PM_Selected_Tubes_Config__c = :selectedTube.id
                    and other_moq__c != null and other_moq__c != 0
                    order by MOQ__c ASC, lastmodifieddate desc
            ];


            moqPrices = [
                    select id,Show_corresponding_Reco__c, MOQ_Min__c, List_Price__c,MOQ_Max__c
                    from PM_MOQ_price__c
                    where PM_Selected_Tubes_Config__c = :selectedTube.id
                    order by MOQ_Min__c ASC
            ];

        } else if (selectedDispensingConfig != null) {
            system.debug('SELECTED DISPENSING' + selectedDispensingConfig);
            configId = selectedDispensingConfig.id;
            existingPriceRecoms = [
                    Select id, MOQ__c, List_Price__c, Lin1_Discount__c,Display__c,Other_MOQ__c,
                            round_Lin1_Price__c, Lin1_Price__c, Lin2_Discount__c,round_Lin2_Price__c, Lin2_Price__c, Lin3_Discount__c, Lin3_Price__c,
                            round_Lin3_Price__c, Max_Threshhold_Discount__c,round_Max_Threshhold_Price__c, Max_Threshhold_Price__c,
                            Min_Threshhold_Discount__c, Min_Threshhold_Price__c,round_Min_Threshhold_Price__c
                            , PM_Selected_Dipsensing_Config__c, PM_Selected_Tubes_Config__c,PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c, Quote_Line_Item__c,
                            Quote_Line_Item__r.Total_Score__c,Quote_Line_Item__r.selected_corridor__c
                    from PM_Price_Recommendation__c
                    where PM_Selected_Dipsensing_Config__c = :selectedDispensingConfig.Id
                    and other_moq__c = null
                    order by MOQ__c ASC
            ];


            //get the last modified specific moq and add it to the list to return
            listSpecificMOQRecom = [
                    Select id, MOQ__c, List_Price__c, Lin1_Discount__c,Display__c,Other_MOQ__c,
                            round_Lin1_Price__c, Lin1_Price__c, Lin2_Discount__c,round_Lin2_Price__c, Lin2_Price__c, Lin3_Discount__c, Lin3_Price__c,
                            round_Lin3_Price__c, Max_Threshhold_Discount__c,round_Max_Threshhold_Price__c, Max_Threshhold_Price__c,
                            Min_Threshhold_Discount__c, Min_Threshhold_Price__c,round_Min_Threshhold_Price__c
                            , PM_Selected_Dipsensing_Config__c, PM_Selected_Tubes_Config__c,PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c, Quote_Line_Item__c,
                            Quote_Line_Item__r.Total_Score__c,Quote_Line_Item__r.selected_corridor__c
                    from PM_Price_Recommendation__c
                    where PM_Selected_Dipsensing_Config__c = :selectedDispensingConfig.Id
                    and other_moq__c != null and other_moq__c != 0
                    order by MOQ__c ASC, lastmodifieddate desc
            ];

            System.debug('@@qama listSpecificMOQRecom ' + listSpecificMOQRecom);
            moqPrices = [
                    select id,Show_corresponding_Reco__c, MOQ_Min__c, List_Price__c,MOQ_Max__c
                    from PM_MOQ_price__c
                    where PM_Selected_Dipsensing_Config__c = :selectedDispensingConfig.id
                    order by MOQ_Min__c ASC
            ];

        }

        if (listSpecificMOQRecom != null && listSpecificMOQRecom != null && listSpecificMOQRecom.size() > 0) existingPriceRecoms.add(listSpecificMOQRecom[0]);

        //added by maryem
        if (moqPrices != null && moqPrices.size() > 0)
            for (PM_MOQ_price__c moq : moqPrices) {
                mapMoqRecods.put(moq.moq_min__c, moq) ;
            }
        system.debug('@@qama moqPrices ' + moqPrices);
        system.debug('EXISTING.....=' + existingPriceRecoms);
        if (existingPriceRecoms != null && existingPriceRecoms.size() > 0) {
            Integer index = 0;
            Decimal totalScore = 0;

            for (PM_Price_Recommendation__c existingPricereco : existingPriceRecoms) {
                totalScore = existingPricereco.Quote_Line_Item__r.Total_Score__c;
                system.debug('#########totalScore.....=' + totalScore);
                Boolean corridorFound = existingPricereco.Quote_Line_Item__r.selected_corridor__c != null ;//added by maryem qada to correct the displaying of the discount column
                //The first Price Reco must be the discount..
                if (index == 0) {
                    PriceReco recoDiscount = new PriceReco();
                    //lastmodified by maryem  to correct the displaying of the discount column
                    recoDiscount.minThreshHoldPriceValue = !corridorFound ? 'N/A'
                            : (existingPricereco.Min_Threshhold_Discount__c * 100).setScale(1, System.RoundingMode.DOWN) + '%';

                    recoDiscount.lin1PriceValue = !corridorFound ? 'N/A'
                            : (existingPricereco.Lin1_Discount__c * 100).setScale(1, System.RoundingMode.DOWN) + '%';

                    recoDiscount.lin2PriceValue = !corridorFound ? 'N/A'
                            : (existingPricereco.Lin2_Discount__c * 100).setScale(1, System.RoundingMode.DOWN) + '%';

                    recoDiscount.lin3PriceValue = !corridorFound ? 'N/A'
                            : (existingPricereco.Lin3_Discount__c * 100).setScale(1, System.RoundingMode.DOWN) + '%';

                    recoDiscount.maxThreshHoldPriceValue = !corridorFound ? 'N/A'
                            : (existingPricereco.Max_Threshhold_Discount__c * 100).setScale(1, System.RoundingMode.DOWN) + '%';

                    priceRecoToInsert.add(recoDiscount);
                }

                PriceReco reco = new PriceReco();
                System.debug('yousefffff '+ existingPricereco.PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c);
                if (item.Quantity < 100 && item.Location__c == 'EU' && item.Product_Sub_segment__c == 'Laminate Tubes' && existingPricereco.PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c == 'Metamorphosis') {
                    reco.tgValue = 'Specific';
                } else {
                    reco.tgValue = existingPricereco.List_Price__c == null || existingPricereco.List_Price__c == 0 ? ' - ' :
                            (existingPricereco.List_Price__c == -1 ? 'Specific' : '' + existingPricereco.List_Price__c.round());
                }


                //If TG = Specific , all rows must be specific..
                if (reco.tgValue == 'Specific') {
                    if (item.Quantity < 100 && item.Location__c == 'EU' && item.Product_Sub_segment__c == 'Laminate Tubes' && existingPricereco.PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c == 'Metamorphosis') {
                        reco.minThreshHoldPriceValue = 'N/A';
                        reco.lin1PriceValue = 'N/A';
                        reco.lin2PriceValue = 'N/A';
                        reco.lin3PriceValue = 'N/A';
                        reco.maxThreshHoldPriceValue = 'N/A';
                    } else {
                        reco.minThreshHoldPriceValue = 'Specific';
                        reco.lin1PriceValue = 'Specific';
                        reco.lin2PriceValue = 'Specific';
                        reco.lin3PriceValue = 'Specific';
                        reco.maxThreshHoldPriceValue = 'Specific';
                    }


                } else {
                    if (item.Quantity < 100 && item.Location__c == 'EU' && item.Product_Sub_segment__c == 'Laminate Tubes' && existingPricereco.PM_Selected_Tubes_Config__r.Sleeve_Material_Mix__c == 'Metamorphosis') {
                        reco.minThreshHoldPriceValue = 'N/A';
                        reco.lin1PriceValue = 'N/A';
                        reco.lin2PriceValue = 'N/A';
                        reco.lin3PriceValue = 'N/A';
                        reco.maxThreshHoldPriceValue = 'N/A';
                    } else {

                        reco.minThreshHoldPriceValue = existingPricereco.round_Min_Threshhold_Price__c == null || existingPricereco.round_Min_Threshhold_Price__c == 0 ? ' - ' :
                                ((existingPricereco.round_Min_Threshhold_Price__c == -1 || reco.tgValue == 'Specific') ? 'Specific' : '' + existingPricereco.round_Min_Threshhold_Price__c);//.round(System.RoundingMode.round));

                        reco.lin1PriceValue = existingPricereco.round_Lin1_Price__c == null || existingPricereco.round_Lin1_Price__c == 0 ? ' - ' :
                                ((existingPricereco.round_Lin1_Price__c == -1 || reco.tgValue == 'Specific') ? 'Specific' : '' + existingPricereco.round_Lin1_Price__c);//.round(System.RoundingMode.round));

                        reco.lin2PriceValue = existingPricereco.round_Lin2_Price__c == null || existingPricereco.round_Lin2_Price__c == 0 ? ' - ' :
                                ((existingPricereco.round_Lin2_Price__c == -1 || reco.tgValue == 'Specific') ? 'Specific' : '' + existingPricereco.round_Lin2_Price__c);//.round(System.RoundingMode.round));

                        reco.lin3PriceValue = existingPricereco.round_Lin3_Price__c == null || existingPricereco.round_Lin3_Price__c == 0 ? ' - ' :
                                ((existingPricereco.round_Lin3_Price__c == -1 || reco.tgValue == 'Specific') ? 'Specific' : '' + existingPricereco.round_Lin3_Price__c);//.round(System.RoundingMode.round));

                        reco.maxThreshHoldPriceValue = existingPricereco.round_Max_Threshhold_Price__c == null || existingPricereco.round_Max_Threshhold_Price__c == 0 ? ' - ' :
                                ((existingPricereco.round_Max_Threshhold_Price__c == -1 || reco.tgValue == 'Specific') ? 'Specific' : '' + existingPricereco.round_Max_Threshhold_Price__c);//round(System.RoundingMode.round));
                    }


                }
                reco.moq = '' + existingPricereco.MOQ__c;
                reco.display = existingPricereco.Display__c;
                reco.showColumn = mapMoqRecods.get(existingPricereco.MOQ__c) == null ? true : mapMoqRecods.get(existingPricereco.MOQ__c).Show_corresponding_Reco__c; //added by maryem

                //reco.tgValue  = existingPricereco.List_Price__c == null? ' - ' :
                //   (existingPricereco.List_Price__c == -1 ? 'Specific': ''+existingPricereco.List_Price__c.round());

                reco.selectedTubeConfig = existingPricereco.PM_Selected_Tubes_Config__c;
                reco.selectedDispensingConfig = existingPricereco.PM_Selected_Dipsensing_Config__c;
                reco.quoteItem = existingPricereco.Quote_Line_Item__c;
                reco.tg = existingPricereco.List_Price__c;
                reco.lin1Value = existingPricereco.round_Lin1_Price__c;
                reco.lin2Value = existingPricereco.round_Lin2_Price__c;
                reco.lin3Value = existingPricereco.round_Lin3_Price__c;
                reco.maxThreshHoldValue = existingPricereco.round_Max_Threshhold_Price__c;
                reco.minThreshHoldValue = existingPricereco.round_Min_Threshhold_Price__c;

                if ((totalScore <= 4 || reco.display == false) && totalScore > 0 && totalScore != null) { ////modified by maryem qada for null or = to 0 scores
                    reco.disabledLin3 = true;
                    reco.disabledMaxThreshold = true;
                } else if ((totalScore > 4 && totalScore <= 6 || reco.display == false) && totalScore > 0 && totalScore != null) { //modified by maryem qada for null or = to 0 scores
                    reco.disabledLin3 = false;
                    reco.disabledMaxThreshold = true;
                } else if (reco.display == false) {
                    reco.disabledLin3 = true;
                    reco.disabledMaxThreshold = true;

                } else if (reco.display == true) {
                    reco.disabledLin3 = false;
                    reco.disabledMaxThreshold = false;
                }

                system.debug('EXISTING RECO: ' + reco);
                index++;

                //This is the otherMOQ
                if (existingPricereco.Other_MOQ__c >= 0) {
                    reco.otherMoq = existingPricereco.Other_MOQ__c ;
                    otherMOQFilled = true;
/*                    reco.tg =
                    priceRecom.Other_MOQ__c = Integer.valueOf(otherMOQ);
                    priceRecom.List_Price__c   = (Decimal) mapJSON.get('tg');
                    priceRecom.Price__c   = (Decimal) mapJSON.get('tg');
                    priceRecom.Lin1_Price__c   = (Decimal) mapJSON.get('lin1Value');
                    priceRecom.Lin2_Price__c   = (Decimal) mapJSON.get('lin2Value');
                    priceRecom.Lin3_Price__c   = (Decimal) mapJSON.get('lin3Value');
                    priceRecom.Max_Threshhold_Price__c   = (Decimal) mapJSON.get('maxThreshHoldValue');
                    priceRecom.Min_Threshhold_Price__c   = (Decimal) mapJSON.get('minThreshHoldValue');
 */

                } else {
                    reco.otherMoq = 0;

                }
                priceRecoToInsert.add(reco);

            }
            system.debug('EXISTING PRICE RECO=' + priceRecoToInsert.size());
            system.debug(priceRecoToInsert);
            priceRecoToInsert = fillTable(priceRecoToInsert, otherMOQFilled);
            system.debug('EXISTING PRICE RECO=' + priceRecoToInsert.size());
            system.debug(priceRecoToInsert);
        } else {
            system.debug('NO PRICE RECO FOUND...NEED TO DISLAY THE AVAILABLE MOQ COLUMN');
            //TODo, we need to get the available MOQ
            List<PriceReco> priceReco = getMOQThreshHoldToDisplay(new PriceReco(null, null, null, item.Total_Score__c), productSegment, qliId, item.Customer_Country__c, configId);
            System.debug('Available column....');
            system.debug(priceReco);
            priceRecoToInsert = fillTable(priceReco, otherMOQFilled);
            System.debug('Blank Column to Display....');
            system.debug(priceRecoToInsert);

            // message = 'FAIL';
        }
        system.debug('EXISTING PRICE RECO=' + priceRecoToInsert);

        result.put('priceReco', priceRecoToInsert);
        result.put('prices', moqPrices);

        return result;

    }


    //Insert the Price into the selected object
    public static String insertPriceReco(List<PriceReco> priceRecoToInsert, String qlId, String selectedProductId, String productSegmenta) {
        String message = 'SUCCESS';
        system.debug('INSERTING PRICE RECOMMENDATION........');
        //We must clear the previous Price Recommendation
        /*List<PM_Price_Recommendation__c> priceRecomsToDelete = [select id from PM_Price_Recommendation__c where
                                                                PM_Selected_Tubes_Config__c=:selectedProductId
                                                                OR PM_Selected_Dipsensing_Config__c =:selectedProductId];
        ///delete priceRecomsToDelete;
        */
        List<PM_Price_Recommendation__c> priceRecoms = new List<PM_Price_Recommendation__c>();
        PM_Price_Recommendation__c priceRecom = null;
        Integer index = 0;
        PriceReco discountReco = priceRecoToInsert.get(0);
        for (PriceReco priceReco : priceRecoToInsert) {
            priceRecom = new PM_Price_Recommendation__c();

            //Index zero is the discount...Must skip this one...
            if (index != 0 || Test.isRunningTest()) {
                if (priceReco.moq != null && priceReco.moq != '' && priceReco.moq != ' - ') {
                    if (productSegment.toUpperCase().contains('TUBES')) {
                        priceRecom.PM_Selected_Tubes_Config__c = selectedProductId;
                    } else {
                        priceRecom.PM_Selected_Dipsensing_Config__c = selectedProductId;
                    }

                    priceRecom.Quote_Line_Item__c = qlId;
                    priceRecom.MOQ__c = Integer.valueOf(priceReco.moq);
                    priceRecom.Display__c = priceReco.display;
                    priceRecom.List_Price__c = priceReco.tg;
                    priceRecom.Lin1_Discount__c = discountReco.lin1Value;
                    priceRecom.Lin2_Discount__c = discountReco.lin2Value;
                    priceRecom.Lin3_Discount__c = discountReco.lin3Value;
                    priceRecom.Max_Threshhold_Discount__c = discountReco.maxThreshHoldValue;
                    priceRecom.Min_Threshhold_Discount__c = discountReco.minThreshHoldValue;
                    priceRecom.Unique_Key__c = qlId + '_' + priceReco.moq;
                    system.debug(priceRecom);
                    priceRecoms.add(priceRecom);
                }
            }
            index++;

        }
        upsert priceRecoms Unique_Key__c;
        return message;
    }

    public static List<PriceReco> getMOQThreshHoldToDisplay(PriceReco priceDiscountRecommended, String productSegmentold, String qlId, String customerCountry, String tubeId) {

        system.debug('getMOQThreshHoldToDisplay:PRODUCTSEGMENT=' + productSegment + 'LCOATION=' + location);
        //Get the MOQ to display
        List<PM_Global_Config__c> volumeThreshHoldConfigs = [
                select id,
                        MOQ_in_reco__c, Freight__c, MOQ_in_config__c
                from PM_Global_Config__c
                where Table_name__c = 'MOQ thresholds' and Product_Segment__c = :productSegment.toUpperCase()
                and location__c = :location
                order by MOQ_in_reco__c ASC NULLS LAST
        ];

        system.debug('---------- VOLUME THRESHOLD FOUND...');
        system.debug(volumeThreshHoldConfigs);
        //Get the prices calculated in the product Configuration
        Map<String, PM_MOQ_price__c> moqPricesMap = new Map<String, PM_MOQ_price__c>();
        //added by maryem to not call the query if no config is set
        if (tubeId != null) {
            if (productSegment.toUpperCase().contains('TUBES')) {
                for (PM_MOQ_price__c moqPrice : [
                        select id, Show_corresponding_Reco__c,
                                List_Price__c, MOQ__c
                        from PM_MOQ_price__c
                        where PM_Selected_Tubes_Config__c = :tubeId
                        order by MOQ__c DESC
                        limit 20
                ]) {

                    moqPricesMap.put(moqPrice.MOQ__c, moqPrice);
                    if (moqPrice.MOQ__c == '[500 - 0k[') {
                        moqPricesMap.put('> 500k', moqPrice);
                    }


                }//end for
            } else {
                for (PM_MOQ_price__c moqPrice : [
                        select id, Show_corresponding_Reco__c,
                                List_Price__c, MOQ__c, MOQ_Min__c
                        from PM_MOQ_price__c
                        where PM_Selected_Dipsensing_Config__c = :tubeId
                        order by MOQ_Min__c ASC
                        limit 20
                ]) {

                    moqPricesMap.put(moqPrice.MOQ__c, moqPrice);
                    if (moqPrice.MOQ__c == '[500 - 0k[') {
                        moqPricesMap.put('> 500k', moqPrice);

                    }
                    if (moqPrice.MOQ__c == '> 250k') {
                        system.debug('---------- > 250k= [250 - 500k[' + moqPrice);
                        moqPricesMap.put('[250 - 0k[', moqPrice);
                    }


                }
            }
        }//end if tubeId != null


        system.debug('---------- MOQ PRICES.....');
        system.debug(moqPrices);

        system.debug('---------- MOQ moqPricesMap .....');
        system.debug(moqPricesMap);

        //Need to determien the value
        Decimal tg = 0;
        Boolean isSpecific = true; //Specific will be based on the tg
        List<PriceReco> priceRecommendations = new List<PriceReco>();
        //The first line is the discount...
        priceRecommendations.add(priceDiscountRecommended);

        Map<String, String> moqDisplayForDispensing = new Map<String, String>();
        for (PM_Global_Config__c displayConfig : [
                select id,
                        MOQ_name__c
                from PM_Global_Config__c
                where Table_name__c = 'Available MOQ per Annual Volume for Dispensing'
                and Product_Segment__c = :productSegment.toUpperCase()
                and location__c = :location
                and Annual_Volume_min__c <= :annualVolume
                and Annual_Volume_max__c > :annualVolume
                order by MOQ_in_reco__c ASC NULLS LAST
        ]) {
            moqDisplayForDispensing.put('' + displayConfig.MOQ_name__c, 'YES');
        }
        system.debug('DISPLAY COLUMN FOR DISPENSING...');
        system.debug(moqDisplayForDispensing);

        PriceReco priceRecommendation = null;
        Decimal listPrice = 0;
        Boolean display = false;
        Boolean showColumn = true;//added by maryem qada to determine if the reco column should be shown or not

        system.debug('PRICE RECO DISCOUNT=' + priceDiscountRecommended);

        for (PM_Global_Config__c volumeThreshHoldToDisplay : volumeThreshHoldConfigs) {
            listPrice = 0;

            system.debug('MOQ IN CONFIG' + volumeThreshHoldToDisplay.MOQ_in_config__c);
            PM_MOQ_price__c moqPrice = moqPricesMap.get(volumeThreshHoldToDisplay.MOQ_in_config__c);
            system.debug(moqPrice);
            if (moqPrice != null) {
                //listPrice = (moqPrice.List_Price__c != null)? moqPrice.List_Price__c.round():0;
                listPrice = (moqPrice.List_Price__c != null) ? moqPrice.List_Price__c : 0;
                showColumn = moqPrice.Show_corresponding_Reco__c ;
            }

            isSpecific = (listPrice == -1);

            //Verify if the display is yes
            if (productSegment.equalsIgnoreCase('Plastic tubes')
                    || productSegment.equalsIgnoreCase('Laminate tubes')
                    || productSegment.equalsIgnoreCase('Purefoil tubes')
                    ) {

                display = true;
            } else {
                // if (listPrice == 0) {
                //     display = false;
                // } else {
                String moqDisplay = moqDisplayForDispensing.get('' + volumeThreshHoldToDisplay.MOQ_in_reco__c);
                system.debug('DISPLAY==' + volumeThreshHoldToDisplay.MOQ_in_reco__c + '__' + moqDisplay);
                if (moqDisplay != null && moqDisplay == 'YES') {
                    display = true;
                } else {
                    display = false;
                }

                //Griser les corridors < 25 pour Brazil

                if (volumeThreshHoldToDisplay.MOQ_in_reco__c < 25 && customerCountry == 'BRAZIL') {
                    display = false;
                }

                //}
            }


            priceRecommendation = new PriceReco(showColumn, listPrice, isSpecific, display,
                    String.valueOf(volumeThreshHoldToDisplay.MOQ_in_reco__c),
                    volumeThreshHoldToDisplay.Freight__c, priceDiscountRecommended);

            priceRecommendation.selectedTubeConfig = (selectedTube == null ? null : selectedTube.Id);
            priceRecommendation.selectedDispensingConfig = (selectedDispensingConfig == null ? null : selectedDispensingConfig.Id);
            priceRecommendation.quoteItem = item.id;

            priceRecommendations.add(priceRecommendation);
            system.debug('Price Recommendation START');
            system.debug(priceRecommendation);
            system.debug('Price Recommendation END');
        }

        return priceRecommendations;

    }

    public static PM_Global_Config__c calculateVolumeThreshhold(String productSegmentold) {
        system.debug('@@product productSegmentold ' + productSegmentold);
        system.debug('@@product segment ' + productSegment);
        PM_Global_Config__c volumeThreshhold = null;
        List<PM_Global_Config__c> volumeThreshHoldConfigs = null;
        //Get the volume that is nearer to the Annual Volume Threshhold chosen
        volumeThreshHoldConfigs = [
                select id,
                        Annual_Volume_Thresholds__c, Min_Volume_thresholds__c, Max_Volume_thresholds__c
                from PM_Global_Config__c
                where Table_name__c = 'Volume thresholds' and Product_Segment__c = :productSegment
                and Location__c = :location
                and Annual_Volume_Thresholds__c > :annualVolume
                order by Annual_Volume_Thresholds__c ASC
        ];

        if (volumeThreshHoldConfigs != null && volumeThreshHoldConfigs.size() > 0) {
            volumeThreshhold = volumeThreshHoldConfigs.get(0);
        } else {
            volumeThreshHoldConfigs = [
                    select id,
                            Annual_Volume_Thresholds__c, Min_Volume_thresholds__c, Max_Volume_thresholds__c
                    from PM_Global_Config__c
                    where Table_name__c = 'Volume thresholds' and Product_Segment__c = :productSegment
                    and Location__c = :location
                    and Annual_Volume_Thresholds__c < :annualVolume
                    order by Annual_Volume_Thresholds__c DESC
            ];
            if (volumeThreshHoldConfigs != null && volumeThreshHoldConfigs.size() > 0) {
                volumeThreshhold = volumeThreshHoldConfigs.get(0);
            }
        }

        return volumeThreshhold;
    }


    public static PM_Discount_corridor__c getSelectedPriceCorridor(String productSegmentOld, String marketApplication, String customerType,
            String customerScoringType) {
        // = null;


        PM_Discount_corridor__c selectedCorridor = null;

        system.debug('--- productSegment ---' + productSegment);
        system.debug('--- location ---' + location);

        String corridorProductSegment = null;
        List<PM_Global_Config__c> productSegmentGlobalConfigs = [
                Select id, Name_for_discount_corridors__c
                from PM_Global_Config__c
                where Table_name__c = 'Product Segment'
                and Product_Segment__c = :productSegment.toUpperCase()
                and Location__c = :location
        ];

        if (productSegmentGlobalConfigs != null && productSegmentGlobalConfigs.size() > 0) {
            corridorProductSegment = productSegmentGlobalConfigs.get(0).Name_for_discount_corridors__c;
        }

        String corridorMarketApplication = null;
        system.debug('MARKET OF APPLICATION=' + marketApplication);
        String marketOfApplication = (marketApplication != null) ? marketApplication.toUpperCase() : '';
        List<PM_Global_Config__c> marketAppGlobalConfigs = [
                Select id, Name_for_discount_corridors__c
                from PM_Global_Config__c
                where Table_name__c = 'Market of Application'
                and Market_of_Application__c = :marketOfApplication
                and Location__c = :location
        ];
        if (marketAppGlobalConfigs != null && marketAppGlobalConfigs.size() > 0) {
            corridorMarketApplication = marketAppGlobalConfigs.get(0).Name_for_discount_corridors__c;
        }

        String corridorDistributionChannel = null;
        system.debug('CUSTOMER SIZE=' + customerScoringType);
        if ((customerScoringType == 'Brand owner') || (customerScoringType == 'Formulator')) {
            corridorDistributionChannel = (item.Brand_Positionning__c != null) ? item.Brand_Positionning__c.toUpperCase() : '';
        } else if ((customerScoringType == 'Distributor') || (customerScoringType == 'Contract filler')) {
            System.debug('AAA0');
            System.debug('AAA0:' + item.Product_Line__c);
            if (location == 'US' && item.Product_Line__c == 'Tubes') {
                System.debug('AAA1');
                if (customerScoringType == 'Distributor') {
                    System.debug('AAA2');
                    corridorDistributionChannel = 'Distributor';
                } else {
                    System.debug('AAA3');
                    corridorDistributionChannel = 'FILLERS & DISTRIBUTORS';
                }
            } else {
                System.debug('AAA4');
                corridorDistributionChannel = 'FILLERS & DISTRIBUTORS';
            }
        } else if (customerScoringType == 'Direct Seller') {
            corridorDistributionChannel = 'DIRECT DISTRIBUTION';
        }

        //     String corridorDistributionChannel = getDistributionChannel(customerScoringType);

        //If Product = Dispensing and DistributionChannel = Fillers & Distributors and Location = US, set default corridor
/*
        Hasseeb 20-06 - Commented for Distributor
        if (PriceRecommendationUtility.CUSTOMER_TYPE_FILLERS_DISTRIBUTORS.equalsIgnoreCase(corridorDistributionChannel)
            && 'US'.equalsIgnoreCase(location) && !(productSegment.toUpperCase()).contains('TUBES')) {

              for (PM_Discount_corridor__c corridor : [select id, Peer_Group_Name__c, SKU__c,
                                P10__c, P20__c, P30__c, P40__c, P50__c,P60__c, P70__c,P80__c, P90__c
                                from PM_Discount_corridor__c
                                where Peer_Group_Name__c = 'DEFAULT_DISTRIBUTOR_DISPENSING'
                                 and Location__c =:location]) {
                   selectedCorridor =  corridor;

              }

        } else {    */


        //   String TPG = corridorProductSegment + '_'
        //                 + corridorMarketApplication + '_'
        //               + customerType + '_'
        //             + corridorDistributionChannel;

        String SPG = corridorProductSegment + '_' + customerType; //corridor Eastern Europe
        String TPG = corridorProductSegment + '_' + corridorMarketApplication + '_' + customerType + '_' + corridorDistributionChannel;


        String PPG = corridorProductSegment + '_'
                + corridorMarketApplication + '_'
                + customerType + '_'
                + corridorDistributionChannel;

        String MPG = corridorProductSegment + '_' + customerType;

        //Haseeb 09-06: Get the clean Name of the corrdior first
        Map<String, String> corridorCriteriaCleanMap = new Map<String, String>();
        for (PM_Global_Config__c config : [
                select Product_specs__c, Name_for_discount_corridors__c, Table_name__c
                from PM_Global_Config__c
                where Table_name__c = 'Product specs'
                and Location__c = :location
        ]) {
            corridorCriteriaCleanMap.put(config.Product_specs__c, config.Name_for_discount_corridors__c);
        }

        System.debug('Before criteria SPG=' + SPG);
        System.debug('Before criteria TPG=' + TPG);
        System.debug('Before criteria PPG=' + PPG);
        System.debug('Before criteria MPG=' + MPG);

        SPG = getCriteria('SPG', SPG, corridorMarketApplication, corridorCriteriaCleanMap);
        TPG = getCriteria('TPG', TPG, corridorMarketApplication, corridorCriteriaCleanMap);
        PPG = getCriteria('PPG', PPG, corridorMarketApplication, corridorCriteriaCleanMap);
        MPG = getCriteria('MPG', MPG, corridorMarketApplication, corridorCriteriaCleanMap);

        System.debug('PRODUCT SEGMENT=' + productSegment);
        System.debug('SPG=' + SPG);
        System.debug('TPG=' + TPG);
        System.debug('PPG=' + PPG);
        System.debug('MPG=' + MPG);

        //get the SKU for selected location and sub segment    for PPG and TPG corridors
        Map<String, Integer> SKUMap = getCorridorSKU();
        Integer tpgCorridorIndex = 999;
        Integer ppgCorridorIndex = 999;
        String keyForSKU = (location + '_' + productSegment).toUpperCase();
        tpgCorridorIndex = SKUMap.get(keyForSKU + '_TPG') != null ? SKUMap.get(keyForSKU + '_TPG') : tpgCorridorIndex;
        ppgCorridorIndex = SKUMap.get(keyForSKU + '_PPG') != null ? SKUMap.get(keyForSKU + '_PPG') : ppgCorridorIndex;

        system.Debug('@@qama LC01 PRICE RECO ' + tpgCorridorIndex + '_' + ppgCorridorIndex);

        //Find the three corridor that applies
        PM_Discount_corridor__c SPGCorridor = null;
        PM_Discount_corridor__c TPGCorridor = null;
        PM_Discount_corridor__c PPGCorridor = null;
        PM_Discount_corridor__c MPGCorridor = null;
        Date dt;
        if (item.Copy_quote_status__c == 'Draft' || item.Copy_quote_status__c == 'Simulation') dt = Date.today();
        //check if the customer country does not belong to a specific region
        else dt = date.newinstance(item.createdDate.year(), item.createdDate.month(), item.createdDate.day());

        //check if the customer country does not belong to a specific region
        system.debug('@@qama quote line item ITEM = ' + item);

        String query = 'select id, PEER_GROUP__C, Peer_Group_Name__c, SKU__c,P10__c, P20__c, P30__c, P40__c, P50__c,P60__c, P70__c,P80__c, P90__c ';
        query = query + 'from PM_Discount_corridor__c where ( (Peer_Group__c =\'TPG\' AND Peer_Group_Name__c =:TPG AND SKU__c>= :tpgCorridorIndex) ';
        query = query + ' OR  (Peer_Group__c =\'PPG\' AND Peer_Group_Name__c =:PPG AND SKU__c>= :ppgCorridorIndex) OR ( Peer_Group__c =\'MPG\' and Peer_Group_Name__c =:MPG)' ;
        query = query + ' OR (Peer_Group__c =\'SPG\' and Peer_Group_Name__c =:SPG) ) and Location__c =:location ';
        // Added for Historisation
        query = query + '  AND Valid_From__c <= : dt and Valid_To__c >= : dt ';

        //get countries on which we will apply a corridor depending on its region
        list<Pm_Global_config__c> specificCountries = [
                select region__c
                from Pm_Global_config__c
                where country_name__c = :item.quote.Account.Country__r.Name
                AND TABLE_name__c = 'Country by Region'
                and region__c = :item.quote.Account.Country__r.PricematriX_Region__c
        ];

        system.debug('@@qama specificCountries ' + specificCountries + ' dt ' + dt);
        list<PM_Discount_corridor__c> liDiscountCorridors = new list<PM_Discount_corridor__c>();

        if (specificCountries.size() > 0 && specificCountries != null) {
            string region = specificCountries[0].region__c;
            liDiscountCorridors = database.query(query + ' and region__c = :region order by SKU__c ASC');
        }

        if (liDiscountCorridors.size() == 0 || liDiscountCorridors == null || liDiscountCorridors.size() <= 0) {
            system.debug('@@qama query LIDISCount ' + query + ' and region__c = null order by SKU__c ASC');
            liDiscountCorridors = database.query(query + ' and region__c = null order by SKU__c ASC');
        }
        for (PM_Discount_corridor__c corridor : liDiscountCorridors) {
            if (corridor.Peer_Group__c == 'SPG') {
                system.debug('@@qama dans SPG' + SPG);
                SPGCorridor = corridor;
            } else if (corridor.Peer_Group__c == 'TPG') {
                system.debug('@@qama dans TPG' + TPG);
                TPGCorridor = corridor;
            } else if (corridor.Peer_Group__c == 'PPG') {
                system.debug('@@qama dans PPG' + PPG);
                PPGCorridor = corridor;
            } else {
                system.debug('@@qama dans MPG' + MPG);
                MPGCorridor = corridor;
            }

        }

        system.debug('TPGCorridor corridor existing ' + TPGCorridor);
        system.debug('PPGCorridor corridor existing ' + PPGCorridor);
        system.debug('MPGCorridor corridor existing ' + MPGCorridor);

        if (MPGCorridor == null) {
            if ('US'.equalsIgnoreCase(location)) {
                MPG = corridorProductSegment + '_' + customerType;

                System.debug('NO Corridor FOUND for MPG..Query Again by=' + MPG);
                /* for (PM_Discount_corridor__c corridor : [select id, Peer_Group_Name__c, SKU__c,
                           P10__c, P20__c, P30__c, P40__c, P50__c,P60__c, P70__c,P80__c, P90__c
                           from PM_Discount_corridor__c
                           where Peer_Group_Name__c =:MPG and Location__c =:location
                                                          limit 1]) {

                       MPGCorridor = corridor;
                 }*/
                // Added for Historisation
                for (PM_Discount_corridor__c corridor : [
                        select id, Peer_Group_Name__c, SKU__c,
                                P10__c, P20__c, P30__c, P40__c, P50__c,P60__c, P70__c,P80__c, P90__c,region__c
                        from PM_Discount_corridor__c
                        where Peer_Group_Name__c = :MPG and Location__c = :location and Valid_From__c <= :dt and Valid_To__c >= :dt
                        order by region__c NULLS FIRST
                        limit 1
                ]) {

                    MPGCorridor = corridor;
                }
            }
        }

        //Verify which corrider found and filter based on SKU >=10
        if (SPGCorridor != null) {
            system.debug('--- SPG selected');
            selectedCorridor = SPGCorridor;
        } else if (TPGCorridor != null) {
            system.debug('--- TPG selected');
            selectedCorridor = TPGCorridor;
        } else if (PPGCorridor != null) {
            system.debug('--- PPg selected');
            selectedCorridor = PPGCorridor;
        } else {
            system.debug('--- MPG selected');
            selectedCorridor = MPGCorridor;
        }
        //Hasseeb 20-06 - Commented for Distributor
        //  }
        system.debug('SELECTED-CORRIDOR=' + selectedCorridor);
        system.debug('quoteLineItemId' + quoteLineItemId);

        if (quoteLineItemId != null) {
            Quotelineitem qli = [select id, selected_corridor__c from quotelineitem where id = :quoteLineItemId limit 1];

            System.debug(LoggingLevel.INFO, 'LC01_PriceRecommendation - selectedCorridor : ' + selectedCorridor);
            //System.debug(LoggingLevel.INFO, 'LC01_PriceRecommendation - selectedCorridor : ' + selectedCorridor);

            qli.selected_corridor__c = selectedCorridor != null ? selectedCorridor.ID : null;
            try {
                update qli;
            } catch (DmlException e) {
                System.debug(LoggingLevel.INFO, e);
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, e);
            }
        }


        return selectedCorridor;

    }

    public static String getCriteria(String corridorType, String corridor, String marketApp, Map<String, String> corridorCriteriaCleanMap) {
        String criteriae = '';

        criteriae = PriceRecommendationUtility.PRICE_CORRIDOR_FORMULA.get(location + '_' + corridorType + '_' + productSegment.toUpperCase());
        system.debug('CRITERIA KEY===' + location + '_' + corridorType + '_' + productSegment.toUpperCase());
        system.debug('CRITERIA===' + criteriae);
        if (productSegment.toUpperCase().contains('TUBES')) {
            List<String> criteriaList = criteriae != null ? criteriae.split(',') : new List<String>() ;
            for (String criteria : criteriaList) {
                if (!'_'.equalsIgnoreCase(criteria)) {
                    if (criteria.endsWith('__c')) {

                        if (('FINE MIST PUMPS'.equalsIgnoreCase(productSegment) && criteria.equalsIgnoreCase('Actuator__c'))
                                || ('SAMPLERS'.equalsIgnoreCase(productSegment) && criteria.equalsIgnoreCase('Engine_Neck__c'))) {

                            if (selectedTube.get(criteria) == null) {
                                corridor += '_';
                            } else {
                                String value = (String) selectedTube.get(criteria);
                                //Get the clean Name of the value
                                String cleanName = corridorCriteriaCleanMap.get(value);
                                System.debug('CLEAN NAME=' + value + '=' + cleanName);
                                corridor += '_' + (cleanName == null ? value : cleanName);
                            }

                            // corridor += '_' + (selectedTube.get(criteria) ==null? '': selectedTube.get(criteria));
                        } else {
                            corridor += '_' + (selectedTube.get(criteria) == null ? '' : selectedTube.get(criteria));
                        }

                    } else {
                        if (criteria == 'MARKETAPP') {
                            corridor += '_' + marketApp;
                        }
                    }

                }
            }

        } else {
            List<String> criteriaList = criteriae != null ? criteriae.split(',') : new List<String>() ;
            //     List<String> criteriaList = criteriae.split(',');
            for (String criteria : criteriaList) {
                if (!'_'.equalsIgnoreCase(criteria)) {
                    if (criteria.endsWith('__c')) {

                        if (('FINE MIST PUMPS'.equalsIgnoreCase(productSegment) && criteria.equalsIgnoreCase('Actuator__c'))
                                || ('SAMPLERS'.equalsIgnoreCase(productSegment) && criteria.equalsIgnoreCase('Engine_Neck__c'))) {

                            if (selectedDispensingConfig.get(criteria) == null) {
                                corridor += '_';
                            } else {
                                String value = (String) selectedDispensingConfig.get(criteria);
                                //Get the clean Name of the value
                                String cleanName = corridorCriteriaCleanMap.get(value);
                                System.debug('CLEAN NAME=' + value + '=' + cleanName);
                                corridor += '_' + (cleanName == null ? value : cleanName);
                            }

                        } else {
                            corridor += '_' + (selectedDispensingConfig.get(criteria) == null ? '' : selectedDispensingConfig.get(criteria));
                        }

                    } else {
                        if (criteria == 'MARKETAPP') {
                            corridor += '_' + marketApp;
                        }
                    }
                } else {
                    corridor += '_';
                }
                system.debug('CRITERIA SELECTED=' + criteria);
                //corridor += '_' + (selectedDispensingConfig.get(criteria) == null? '':selectedDispensingConfig.get(criteria));
            }

        }

        return corridor;

    }

    public static String getDistributionChannel(String customerScoringType) {
        String distributionChannel;

        String macroMarketCustomerType = '';

        customerScoringType = 'Brand owner'.equalsIgnoreCase(customerScoringType) ? 'Brand owner' : customerScoringType;
        List<PM_Global_Config__c> macroMarketAppGlobalConfigs = [
                Select id, Name_for_discount_corridors__c
                from PM_Global_Config__c
                where Table_name__c = 'Customer Type'
                and Customer_Type__c = :customerScoringType
        ];   // and Location__c = :location
        if (macroMarketAppGlobalConfigs != null && macroMarketAppGlobalConfigs.size() > 0) {
            macroMarketCustomerType = macroMarketAppGlobalConfigs.get(0).Name_for_discount_corridors__c;
        }

        System.debug('customerScoringType=' + customerScoringType + '===' + macroMarketCustomerType);

        // String macroMarketCustomerType = PriceRecommendationUtility.CUSTOMER_TYPE_TO_MACRO_CUSTOMER_TYPE.get(customerScoringType);
        if (macroMarketCustomerType == '4' || macroMarketCustomerType == '5') {
            distributionChannel = PriceRecommendationUtility.CUSTOMER_TYPE_FILLERS_DISTRIBUTORS;
        } else if (macroMarketCustomerType == '2') {
            distributionChannel = PriceRecommendationUtility.CUSTOMER_TYPE_DIRECT_DISTRIBUTION;
        } else {
            //TODO - Get the Brand Positionning from the Price Reco Main Page
            //distributionChannel = 'SELECTIVE MARKET';
            distributionChannel = (item.Brand_Positionning__c == null ? '' : item.Brand_Positionning__c.toUpperCase());
        }

        system.debug('DISTRIBUTION CHANNEL=' + distributionChannel);
        return distributionChannel;

    }

    public static List<PriceReco> fillTable(List<PriceReco> priceRecoMatrix, boolean otherMOQFilled) {
        if (priceRecoMatrix == null) {
            priceRecoMatrix = new List<PriceReco>();
        }
        //If OtherMoq is filled, we need to put one more column as the Other MOQ is considered as a PriceReco
        Integer numberOfColumn = otherMOQFilled ? MAX_ROW + 1 : MAX_ROW;
        Integer priceRecoMatrixSize = priceRecoMatrix.size();

        // numberOfColumn = priceRecoMatrixSize < 9 ? numberOfColumn+1 : numberOfColumn ;


        for (Integer i = priceRecoMatrixSize; i < numberOfColumn; i++) {
            PriceReco reco = new PriceReco();
            reco.moq = ' - ';
            reco.tgValue = ' - ';
            reco.minThreshHoldPriceValue = ' - ';
            reco.lin1PriceValue = ' - ';
            reco.lin2PriceValue = ' - ';
            reco.lin3PriceValue = ' - ';
            reco.maxThreshHoldPriceValue = ' - ';
            reco.showColumn = true;//added by maryem qada to show emptycolumn for dispensing because they have only 4 reco columns!

            priceRecoMatrix.add(reco);
        }
        return priceRecoMatrix;
    }

    @AuraEnabled
    public static List<PriceReco> getPriceRecommendations(String qliId) {
        List<PriceReco> priceRecoMatrix = new List<PriceReco>();
        Integer priceRecoMatrixSize = priceRecoMatrix.size();
        for (Integer i = priceRecoMatrixSize; i < MAX_ROW; i++) {
            PriceReco reco = new PriceReco();
            priceRecoMatrix.add(reco);

        }
        return priceRecoMatrix;
    }

    @AuraEnabled
    public static map<string, string> insertOtherMOQWithCalcul(String otherMOQ, String qliId) {
        Integer otherM = integer.valueof(otherMOQ);
        Decimal moqListPrice ;
        Boolean isCombo = false;

        //get selected tube or dispensing config
        for (PM_Selected_Dipsensing_config__c pmSelDC : [
                select Id
                from PM_Selected_Dipsensing_config__c
                where Quote_item__c = :qliId
        ]) {
            selectedDispensingConfig = pmSelDC;
        }

        list<PM_Selected_Tubes_Config__c> ListpmSelTC = [
                select Id,Is_Combo__c,Diameter_mm__c
                from PM_Selected_Tubes_Config__c
                where Quote_item__c = :qliId
                order by createdDate DESC, LastModifiedDAte DESC
        ];
        for (PM_Selected_Tubes_Config__c pmSelTC : ListpmSelTC) {
            if (pmSelTC.Diameter_mm__c != null || ListpmSelTC.size() == 1) {
                selectedTube = pmSelTC;
                isCombo = selectedTube != null && pmSelTC.Is_Combo__c == 'Yes';

                break;
            }

        }
        if (selectedTube == null && ListpmSelTC.size() > 0) {
            selectedTube = ListpmSelTC.get(0);// if there is duplicated PMSlected Tube and the config is not mentioned yet.
            isCombo = selectedTube != null && selectedTube.Is_Combo__c == 'Yes';
        }

        //get infos from qli
        Quotelineitem qli = [
                select id,Customer_Country__c, Product_Sub_segment__c,Total_Score__c, selected_corridor__c,location__c,quantity
                from quotelineitem
                where id = :qliId
        ];

        location = qli.location__c ;
        annualVolume = Integer.valueOf(qli.quantity);
        productSegment = qli.Product_Sub_segment__c;
        PM_Global_Config__c volumeThreshHolds = calculateVolumeThreshhold(qli.Product_Sub_segment__c);

        //get the selected corridor infos
        list<PM_Discount_corridor__c> selectedPriceCorridor = [
                select id, Peer_Group_Name__c, SKU__c,
                        P10__c, P20__c, P30__c, P40__c, P50__c,P60__c, P70__c,P80__c, P90__c
                from PM_Discount_corridor__c
                where id = :qli.selected_corridor__c
        ];
        //Get the Discount Recommended
        PriceReco priceDiscountRecommended = new PriceReco(
                volumeThreshHolds == null || volumeThreshHolds.Min_Volume_thresholds__c == null ? null : volumeThreshHolds.Min_Volume_thresholds__c,
                volumeThreshHolds == null || volumeThreshHolds.Max_Volume_thresholds__c == null ? null : volumeThreshHolds.Max_Volume_thresholds__c,
                ((selectedPriceCorridor != null && selectedPriceCorridor.size() > 0) ? selectedPriceCorridor.get(0) : null), qli.Total_Score__c);

        //check if the othermoq is a standard hidden Volum
        String PMselectedID = (selectedTube != null && selectedTube != null) ? selectedTube.id : (selectedDispensingConfig != null ? selectedDispensingConfig.id : null);
        List<PM_MOQ_price__c > liMoqPrices ;
        if (PMselectedID != null) {
            liMoqPrices = [
                    select List_Price__c,MOQ_Min__c,pm_selected_tubes_config__c,PM_Selected_Dipsensing_config__c
                    from PM_MOQ_price__c
                    where Quote_item__c = :qli.id and MOQ_Max__c != 999 AND MOQ_Min__c <= :otherM
                    AND (pm_selected_tubes_config__c = :PMselectedID OR PM_Selected_Dipsensing_config__c = :PMselectedID)
                    order by MOQ_Min__c DESC
            ];
        } else {
            liMoqPrices = [
                    select List_Price__c,MOQ_Min__c,pm_selected_tubes_config__c,PM_Selected_Dipsensing_config__c
                    from PM_MOQ_price__c
                    where Quote_item__c = :qli.id and MOQ_Max__c != 999 AND MOQ_Min__c <= :otherM
                    order by MOQ_Min__c DESC
            ];
        }

        PM_MOQ_price__c correspondingMOQ = new PM_MOQ_price__c();
        correspondingMOQ = liMoqPrices.size() > 0 ? liMoqPrices[0] : null;
        moqListPrice = liMoqPrices.size() > 0 ? correspondingMOQ.list_price__c : null ;
        System.debug('@@qama moqListPrice ' + moqListPrice);

        /*********** DEBUT COMBO************** ***    	commenter pour deployer les autres sous lots PM*/
        if (isCombo &&
                correspondingMOQ != null) {
            //copy and recalculate price line details
            List<PM_Price_Detail__c> liNewPriceLineDetails = insertComboPriceLineForSpecificMoq(correspondingMOQ.moq_min__c, qli, otherMOQ);
            upsert liNewPriceLineDetails ExtId__c;

            //calculate the total list price for the specific MOQ
            Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = insertComboPriceLineForSpecificMoq(qli, Decimal.valueof(otherMOQ), 999);
            if (mapPMMOQPrice.size() > 0)
                upsert mapPMMOQPrice.values() ExtId__c;
            if (mapPMMOQPrice.get(otherM) != null)
                moqListPrice = mapPMMOQPrice.get(otherM).list_price__c ;
        }
        /*********** FIN COMBO*****************/

        PriceReco priceRecommendation = new priceReco();

        PM_Price_Recommendation__c priceRecom = new PM_Price_Recommendation__c();

        //	if(isStandardd){
        //get freight
        List<PM_Global_Config__c> volumeThreshHoldToDisplay = [
                select id,
                        MOQ_in_reco__c, Freight__c, MOQ_in_config__c
                from PM_Global_Config__c
                where Table_name__c = 'MOQ thresholds' and Product_Segment__c = :qli.Product_Sub_segment__c.toUpperCase()
                and location__c = :qli.location__c
                and Moq_in_reco__c <= :otherM
                Order by Moq_in_reco__c
        ];
        system.debug('@@qama volumeThreshHoldToDisplay ' + volumeThreshHoldToDisplay.size());
        priceRecommendation = new PriceReco(true, (correspondingMOQ != null ? moqListPrice : 0),
                (correspondingMOQ != null ? moqListPrice == -1 : false),
                true,
                otherMOQ,
                (volumeThreshHoldToDisplay.size() == 0 ? 0 : volumeThreshHoldToDisplay.get(0).Freight__c),
                priceDiscountRecommended
        );
        //prices
        priceRecom.List_Price__c = priceRecommendation.tg ;
        priceRecom.Price__c = priceRecommendation.tg ;
        //discounts
        if (priceDiscountRecommended != null) {
            priceRecom.Lin1_Discount__c = priceDiscountRecommended.lin1Value.setScale(3, System.roundingMode.DOWN) ;
            priceRecom.Lin2_Discount__c = priceDiscountRecommended.lin2Value.setScale(3, System.roundingMode.DOWN) ;
            priceRecom.Lin3_Discount__c = priceDiscountRecommended.lin3Value.setScale(3, System.roundingMode.DOWN) ;
            priceRecom.Max_Threshhold_Discount__c = priceDiscountRecommended.maxThreshHoldValue.setScale(3, System.roundingMode.DOWN) ;
            priceRecom.Min_Threshhold_Discount__c = priceDiscountRecommended.minThreshHoldValue.setScale(3, System.roundingMode.DOWN) ;
        }

        system.debug(priceRecom);

        priceRecom.MOQ__c = 999;
        priceRecom.Other_MOQ__c = otherM;
        priceRecom.Unique_Key__c = qliId + '_' + otherM + '_999' ;
        priceRecom.PM_Selected_Tubes_Config__c = (selectedTube == null ? null : selectedTube.Id);
        priceRecom.PM_Selected_Dipsensing_Config__c = (selectedDispensingConfig == null ? null : selectedDispensingConfig.Id);
        priceRecom.Quote_Line_Item__c = qli.id;
        priceRecom.display__c = true;

        upsert priceRecom Unique_Key__c;

        //Remove duplication records for other MOQ having different Key
        //delete the oldest record (having the old key)
        List<PM_Price_Recommendation__c> liDuplicateRecords = new List<PM_Price_Recommendation__c>();

        for (PM_Price_Recommendation__c pr : [
                select id,Unique_Key__c
                from PM_Price_Recommendation__c
                where MOQ__c = 999 and Other_MOQ__c = :otherM and Quote_Line_Item__c = :qliId
        ]) {
            if ((pr.Unique_Key__c).length() == 22)
                liDuplicateRecords.add(pr);
        }
        delete liDuplicateRecords ;

        //upsert the LAST MOQ MOQ Price
        String idSelectedConfig = priceRecom.PM_Selected_Tubes_Config__c == null ? priceRecom.PM_Selected_Dipsensing_Config__c : priceRecom.PM_Selected_Tubes_Config__c ;

        /*PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                        MOQ_Min__c							= priceRecom.Other_MOQ__c,
                        MOQ_Max__c 							= 999,
                        PM_Selected_Tubes_Config__c 		= priceRecom.PM_Selected_Tubes_Config__c,
                        PM_Selected_Dipsensing_Config__c	= priceRecom.PM_Selected_Dipsensing_Config__c,
                        Quote_item__c 						= priceRecom.Quote_Line_Item__c,
                        List_Price__c 						= priceRecom.List_Price__c ,
                        ExtId__c 							= '999'+ '-' + idSelectedConfig
                    );
        upsert pmMOQ ExtId__c;   */
        // system.debug('@@qama pmMOQ  '+ pmMOQ);

        map<string, string> mapToreturn = new map<string, string>();

        mapToreturn.put('tgValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.List_Price__c.round())));
        mapToreturn.put('minThreshHoldPriceValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.round_Min_Threshhold_Price__c)));
        mapToreturn.put('lin1PriceValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.round_Lin1_Price__c)));
        mapToreturn.put('lin2PriceValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.round_Lin2_Price__c)));
        mapToreturn.put('lin3PriceValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.round_Lin3_Price__c)));
        mapToreturn.put('maxThreshHoldPriceValue', priceRecom.List_Price__c == -1 ? 'Specific' : (priceRecom.List_Price__c == 0 ? '' : string.valueof(priceRecom.round_Max_Threshhold_Price__c)));
        //disable line3 and max threshold if score <=4
        mapToreturn.put('disabledLin3', qli.Total_score__c <= 4 && qli.Total_score__c > 0 ? 'true' : 'false');
        mapToreturn.put('disabledMaxThreshold', qli.Total_score__c <= 4 && qli.Total_score__c > 0 ? 'true' : (qli.Total_score__c <= 6 && qli.Total_score__c > 0 ? 'true' : 'false'));
        return mapToreturn;
        //return string.valueof(priceRecommendation.maxThreshHoldValue);
    }


    /*
    *Get the SKU from the global config for Discount corridors
    */
    public static Map<String, Integer> getCorridorSKU() {
        Map<String, Integer> SKUMap = new Map<String, Integer>();

        //select thresholds from the globalConfig object
        for (PM_Global_Config__c sku : [
                select Location__c, SKU_Product_Sub_Segment__c, TPG__c,PPG__c
                from PM_Global_Config__c
                where Table_name__c = 'TPG/PPG Threshold'
                AND SKU_Activation_Date__c <= :System.today()
                AND SKU_Expiration_Date__c >= :System.today()
                Order by SKU_Expiration_Date__c DESC
        ]) {
            //Fill the PPG
            SKUMap.put((sku.location__c + '_' + sku.SKU_Product_Sub_Segment__c + '_PPG').toUpperCase(), Integer.valueOf(sku.PPG__c));
            //Fill the TPG
            SKUMap.put((sku.location__c + '_' + sku.SKU_Product_Sub_Segment__c + '_TPG').toUpperCase(), Integer.valueOf(sku.TPG__c));
        }
        return SKUMap;
    }

    /*
    *Insert the combo price line details for specific MOQ
    */
    public static List<PM_Price_Detail__c> insertComboPriceLineForSpecificMoq(Decimal moqToCopy, Quotelineitem qli, String specificMOQ) {
        //list to return
        List<PM_Price_Detail__c> liNewPriceLineDetails = new List<PM_Price_Detail__c>();

        for (PM_Price_Detail__c pl : [
                select Price_Override__c,Is_calculated__c, PM_Selected_Tubes_Config__r.ID, PM_Selected_Tubes_Config__r.Number_of_ref_per_run__c,PM_Selected_Tubes_Config__r.Combo_Num_Versions__c, PM_Selected_Tubes_Config__r.Combo_Num_Tubes_Artwork__c, PM_Selected_Tubes_Config__r.Combo_Num_Plate_Changes__c,PM_Selected_Tubes_Config__r.Number_of_tubes_per_artwork_in_Ku__c, name, MOQ_Min__c,Currency__c,is_Specific_MOQ__c,List_Price__c,MOQ_Max__c,PM_Selected_Tubes_Config__c,Quote_item__c,Section__c
                from PM_Price_Detail__c
                where MOQ_Min__c = :moqToCopy and Quote_item__c = :qli.ID
                AND is_Specific_MOQ__c = false AND PM_Selected_Tubes_Config__r.ID = :selectedTube.ID
                order by name asc
        ]) {
            PM_Price_Detail__c line = new PM_Price_Detail__c(
                    Name = pl.Name,
                    Section__c = pl.Section__c,
                    Is_calculated__c = pl.Is_calculated__c,
                    List_Price__c = pl.List_Price__c,
                    PM_Selected_Tubes_Config__c = pl.PM_Selected_Tubes_Config__c,
                    Price_Override__c = pl.Price_Override__c,
                    Quote_item__c = pl.Quote_item__c,
                    is_Specific_MOQ__c = true,
                    moq_min__c = decimal.valueof(specificMOQ),
                    moq_max__c = 999,
                    ExtId__c = pl.PM_Selected_Tubes_Config__r.Id + pl.name + 'Specific'
            );
            //recalculate the price if the section is COMBO
            if (pl.Section__c == 'Others' && pl.name == 'Combo') {
                // Combo EU
                if (pl.PM_Selected_Tubes_Config__r.Combo_Num_Versions__c > 1
                        && pl.PM_Selected_Tubes_Config__r.Combo_Num_Tubes_Artwork__c > 0
                        && pl.PM_Selected_Tubes_Config__r.Combo_Num_Plate_Changes__c > 0) {//moq,3 fields of combo==> returns a decimal

                    Integer moq = integer.valueof(specificMOQ);
                    Decimal a = Math.max((moq * 1000 / pl.PM_Selected_Tubes_Config__r.Combo_Num_Tubes_Artwork__c.intValue()), 1);
                    Decimal b = Math.min(pl.PM_Selected_Tubes_Config__r.Combo_Num_Versions__c, a) - 1;

                    //Check customer Country if germany, multily by 180 instead of 280
                    Integer costPerChangeOfPrintingPlates = 280;
                    if (qli != null
                            && (qli.Customer_Country__c == 'Germany'
                            || qli.Customer_Country__c == 'Austria'
                            || qli.Customer_Country__c == 'Switzerland')) {//country => return integer
                        costPerChangeOfPrintingPlates = 180;
                    }
                    line.List_Price__c = (b * pl.PM_Selected_Tubes_Config__r.Combo_Num_Plate_Changes__c * costPerChangeOfPrintingPlates) / moq;
                }//end if combo eu
                //Combo US
                if (pl.PM_Selected_Tubes_Config__r.Number_of_ref_per_run__c >= 2
                        && pl.PM_Selected_Tubes_Config__r.Number_of_tubes_per_artwork_in_Ku__c > 0) {

                    Decimal refPerRunByMOQDec = line.MOQ_Min__c / pl.PM_Selected_Tubes_Config__r.Number_of_tubes_per_artwork_in_Ku__c;
                    Long refPerRunByMOQtest = refPerRunByMOQDec.round(System.roundingMode.CEILING);
                    Decimal refPerRunIndex = Math.min(pl.PM_Selected_Tubes_Config__r.Number_of_ref_per_run__c, Math.max(refPerRunByMOQtest, 1)) - 1;
                    line.List_Price__c = refPerRunIndex * 600 / line.MOQ_Min__c;
                    system.debug('@@qamaCOMBO line.List_Price__c ' + line.List_Price__c);
                }
            }//end if recalculating combo's priceline
            liNewPriceLineDetails.add(line);
        }//end for PM Price Details

        system.debug('@@qamaCOMBO liNewPriceLineDetails ' + liNewPriceLineDetails);
        return liNewPriceLineDetails;
    }

    /*
    *Calculate the total price for a given MOQ
    */
    public static Map <Decimal, PM_MOQ_price__c> insertComboPriceLineForSpecificMoq(Quotelineitem qli, Decimal moqMin, Decimal moqMax) {
        Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = new Map <Decimal, PM_MOQ_price__c>();

        List<PM_Price_Detail__c> prices = [
                Select Name, Section__c, MOQ_Min__c, MOQ_Max__c, Price__c, List_Price__c,isCalculable__c,Is_calculated__c
                from PM_Price_Detail__c
                where moq_min__c = :moqMin and moq_max__c = :moqMax and Quote_item__c = :qli.id AND PM_Selected_Tubes_Config__r.id = :selectedTube.ID
                order by MOQ_Min__c desc
        ];

        //loop through price lines and calculate the sum
        for (PM_Price_Detail__c pm : prices) {
            if (mapPMMOQPrice.containsKey(pm.MOQ_Min__c)) {
                if (pm.Price__c == -1 && pm.List_Price__c == -1 && !pm.Is_calculated__c) {
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = -1;
                } else if (mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1) {
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c + pm.Price__c;
                }
            } else {
                PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = selectedTube.ID,
                        Quote_item__c = qli.Id,
                        List_Price__c = pm.Price__c,
                        ExtId__c = '999' + '-' + selectedTube.ID
                );
                mapPMMOQPrice.put(pm.MOQ_Min__c, pmMOQ);
            }
        }//end for PM Price Detail

        return mapPMMOQPrice;
    }

    @AuraEnabled
    public static void sendEmail(String message, id qliId) {
        string currentUseremail = UserInfo.getUserEmail();

        String url = 'https://albea--recette.lightning.force.com/lightning/r/QuoteLineItem/' + qliId + '/view' ;//headerdata+
        String msg = message.replaceAll('<p>', '').replaceAll('</p>', '\r');

        system.debug('@@ the email is ' + message + '==> ' + msg + ' Senderemail ' + currentUseremail + ' url' + url);
        String[] toAddresses = Label.EMAIL_ASK_FOR_CONFIR_TOADDRESSES.split(';');//new String[] { 'amira.naimi-external@albea-group.com' };//
        //String senderDisplayName = 'Batch Error: Historisation - Update Prices' ;
        String subject = 'ASK confirmation to use a discount  : ' ;
        String body = msg + '\r the link of the Quote Line Item concerned is : ' + url;//+'the email to : '+Label.EMAIL_ASK_FOR_CONFIR_TOADDRESSES.split(';');
        Messaging.SingleEmailMessage emailMessage = EmailUtils.createEmailMessage(toAddresses, null, null, subject, body);
        //EmailUtils.setFromAddress(null, senderDisplayName, emailMessage);
        EmailUtils.sendEmail(emailMessage);

    }
}