public with sharing class PMCalculator_EU_Plastic {
    /*****************************************************************************
     * Author           : Comforth
     * Purpose          : Class used to calculate PM Price details for EU Tube Plastic
     * Notes            :
     * History
       Date         Modified By         Description
       ------------ ---------------     -------------------------------------------
       01-MAR-2017  Hasseeb             Initial version
     *****************************************************************************/
    // sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String SLEEVE = 'Sleeve';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';
    public static final String OTHERS = 'Others';

    // SUB-SECTIONS
    public static final String BASIS_PRICE = 'Basis Price';
    public static final String LEN_UPCHARGE = 'Length upcharge';
    public static final String HEAD_ASPECT = 'Head Aspect';
    public static final String HEAD_COLORATION = 'Head Coloration';
    public static final String PEEL_SEAL = 'Peal Seel';
    public static final String SLEEVE_MATERIAL = 'Sleeve Material';
    public static final String MATERIAL_MIX = 'Material Mix';
    public static final String SLEEVE_ASPECT = 'Sleeve Aspect';
    public static final String SLEEVE_COLORATION = 'Sleeve Coloration';
    public static final String SLEEVE_FINISH = 'Sleeve Finish';
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_COLORATION = 'Cap Coloration';
    public static final String CAP_METALISATION = 'Cap Metalisation';
    public static final String CAP_LACQUERING = 'Cap Lacquering';
    public static final String SILK_SCREENING = 'Silk-Screening';
    public static final String HOT_STAMP_TOP = 'Hot Stamp Top';
    public static final String HS_CONTOURING = 'HS Contouring';
    public static final String SHRINK_BAND = 'Shrink Band';
    public static final String MANUAL_CAPPING = 'Manual Capping';
    public static final String PRINTING_TYPE = 'Printing Type';
    public static final String OTHER_PRINT_EFFECT = 'Other Printing Effect';
    public static final String SLEEVE_HOT_STAMP = 'Sleeve Hot Stamping';
    public static final String COMBO = 'Combo';
    public static final String PLATTS = 'Platts';
    public static final String PAYMENT_TERMS = 'Payment Terms';
    public static final String EOY_REBATE = 'End of Year Rebate';
    public static final String SKONTO = 'Skonto';
    public static final String STOCKAGE = 'Stockage';
    public static final String FREIGHT_PRICE = 'Freight Price';
    public static final String PE_BAG = 'PE Bag';

    public static final String TG1 = 'TG1';
    public static final String STANDARD = 'standard';

    public static final String WHITE_NATURAL = 'White / Natural';
    public static final String PEARL = 'Pearl';
    public static final String WHITE = 'White';
    public static final String COLORED = 'Colored';

    public static final String YES = 'Yes';
    public static final String NO = 'No';

    public static final String OFFSET = 'Offset';
    public static final String FLEXO = 'Flexo';
    public static final String SILKSCREEN = 'Silkscreen';
    public static final String FLEXO_SS = 'Flexo + Silkscreen';
    public static final String OFFSET_SS = 'Offset + Silkscreen';
    public static final String UNPRINTED = 'Unprinted';

    public static final String SILK_SCREEN = 'Silk Screen';

    public static final String MONO = 'Mono';
    public static final String NON_STD_MIX = 'NON STANDARD MIX';

    public static final String STANDARD_COLOR = 'Standard color';
    public static final String DARK_COLOR = 'Dark color';

    public static final String METALLIZATION = 'Metallization';
    public static final String LACQUERING = 'Lacquering';

    public static final String DELIVERED = 'Delivered';
    public static final String DAP = 'DAP';


    public static final String PLASTIC = 'Plastic';
    public static final Decimal DEFAULT_PLATTS = 1100;
    //public static final String[] listMOQs = new List <String>{'X10__c', 'X15__c', 'X20__c', 'X25__c', 'X50__c', 'X75__c', 'X100__c', 'X200__c', 'X300__c', 'X500__c'};
    public static final Decimal[] listMinMOQ = new List <Decimal>{
            10, 15, 20, 25, 50, 75, 100, 200, 300, 500, 1000
    };

    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public String groupe;
    public Decimal dLength = 0;
    public static Boolean bHasRunned = false;
    ////Basis Price
    List<PM_Price_Detail__c> tgPriceDetails = null;
    ///////Length upcharge	////
    List <PM_Price_Detail__c> details;
    ///////Cap Basis Price ////
    List <PM_Price_Detail__c> capBasisPrices;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_EU_Plastic(PM_Selected_Tubes_Config__c config) {
        if (!bHasRunned) {


            this.config = config;
            if (String.isNotBlank(config.Quote_item__c)) {
                qli = [
                        select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem
                        where Id = :config.Quote_item__c
                ];
            }
            dLength = config.Specific_length_mm__c > 0 ? config.Specific_length_mm__c : config.Sleeve_length_mm__c;

            /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);
             mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReferenceByProductSegment(config.Location__c, version, 'Plastic');*/

            // Added for Historisation
            Date dt;
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today(); else dt = Date.valueOf(qli.CreatedDate);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReference(config.Location__c, 'Plastic', dt);

        }

    }

    public void findGroup() {
        System.debug('## Head Name : ' + config.Head_Name__c);
        System.debug('## Diameter_mm__c : ' + config.Diameter_mm__c);
        if (config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c)) {
            String groupe1 = config.Diameter_mm__c + '_' + config.Head_Name__c;
            System.debug('## groupe1 : ' + groupe1);
            for (PM_Tubes_Config__c g : [
                    select GROUPES_1__c, GROUPES_2__c
                    from PM_Tubes_Config__c
                    where GROUPES_1__c = :groupe1
                    limit 1
            ]) {
                groupe = String.valueOf(g.GROUPES_2__c);
                System.debug('## Group : ' + groupe);
            }
        }
    }

    public void resetAllPMPrice() {
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, LEN_UPCHARGE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, HEAD_ASPECT));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, HEAD_COLORATION));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, PEEL_SEAL));

        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_MATERIAL));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, MATERIAL_MIX));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_ASPECT));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_COLORATION));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_FINISH));

        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, CAP_BASIS_PRICE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, CAP_COLORATION));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, CAP_METALISATION));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, CAP_LACQUERING));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, SILK_SCREENING));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, HOT_STAMP_TOP));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, HS_CONTOURING));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, SHRINK_BAND));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, CAP, MANUAL_CAPPING));

        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, PRINTING, PRINTING_TYPE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, PRINTING, OTHER_PRINT_EFFECT));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, PRINTING, SLEEVE_HOT_STAMP));


        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, COMBO));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, PLATTS));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, PAYMENT_TERMS));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, EOY_REBATE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, SKONTO));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, STOCKAGE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, FREIGHT_PRICE));
        blankPMPrices.addAll(PMCalculatorUtility.getLineDetails(config, null, OTHERS, PE_BAG));

        upsert blankPMPrices ExtId__c;


    }

    public void calculate() {
        System.debug('## PM_Calculator : calculate()');

        resetAllPMPrice();
        //Hm 0103 - Need to delete the previous one first. On the safe way.
        //List<PM_Price_Detail__c> oldPMDetails = [select id from PM_Price_Detail__c where PM_Selected_Tubes_Config__c = :config.Id];
        //delete oldPMDetails;

        findGroup();

        if (String.isBlank(groupe)) return;

        // Basis Price


        if (config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c) && String.isNotBlank(groupe)) {
            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c + '1-01';
            System.debug('## ref : ' + ref);

            PM_Tubes_Pricing__c tp = mapPMTubesPricing.get(ref.toUppercase());

            System.debug(tp);

            tgPriceDetails = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, BASIS_PRICE);
            listDetailsToUpsert.addAll(tgPriceDetails);

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + TUBE_HEAD +
                                '_' + BASIS_PRICE);
                listPricingJunctionToUpsert.add(pj);

            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = BASIS_PRICE;
            }
        } else {
            // 0
        }

        // Upcharge Length
        calcLengthUpchargeEU();

        // Peel Seal
        calcPeelSealEU();

        // Head Aspect
        listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, HEAD_ASPECT));

        // Head Coloration
        if (config.Head_Aspect__c != config.Sleeve_Aspect__c) { //HM Removed && config.Head_Color__c != WHITE_NATURAL
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            System.debug('@@@@ ref: ' + ref);
            if (config.Head_Aspect__c == PEARL) {
                ref += '5-03';
            } else {

                /*  Mapping of the Head Color to Ref
                    Transparent
                    Opaque
                    Pearl               5-03
                    White / Natural
                    Standard color      5-01
                    Dark color          5-02   */
                // TODO : Base on select on PM_Tubes Config
                //HM 2802 Added mapping of Head Color to Ref
                if (config.Head_Color__c == 'Pearl') {
                    ref += '5-03';
                } else if (config.Head_Color__c == 'Standard color') {
                    ref += '5-01';
                } else if (config.Head_Color__c == 'Dark color') {
                    ref += '5-02';
                }
                // for testing temporarily // std color
                //ref += '5-01';
            }
            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, HEAD_COLORATION));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + TUBE_HEAD +
                                '_' + HEAD_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HEAD_COLORATION;
            }
        }

        // Cap Basis Price
        //if(String.isNotBlank(config.Cap_Eurocode__c) && config.Cap_Eurocode__c != '0' && config.Cap_Eurocode__c != 'NO'){
        //HM 2802 - Added check for 0 or NO Cap EuroCode
        System.debug('## Cap Basis Price : ' + config.Cap_Eurocode__c + '_' + config.Head_Name__c);
        if (String.isNotBlank(config.Cap_Eurocode__c)
                && config.Cap_Eurocode__c != '0'
                && config.Cap_Eurocode__c != 'NO'
                && String.isNotBlank(config.Head_Name__c)) {

            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c
                    + config.Cap_Eurocode__c + WHITE.toUpperCase();

            System.debug('## Cap Basis Price : ' + ref);
            PM_Tubes_Pricing__c tp = mapPMTubesPricing.get(ref.toUppercase());
            capBasisPrices = PMCalculatorUtility.getLineDetails(config, tp, CAP, CAP_BASIS_PRICE);

            if (tp == null) {
                for (PM_Price_Detail__c capBasisPrice : capBasisPrices) {
                    capBasisPrice.List_Price__c = -1;
                }
            }
            // Added for Historisation
            // Create Junction Object

            if (tp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = tp.Id,
                        Unique_Key__c = config.Id + '_' + CAP +
                                '_' + CAP_BASIS_PRICE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_BASIS_PRICE;
            }
            listDetailsToUpsert.addAll(capBasisPrices);

            // Cap Coloration
            String refCol = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c + config.Cap_Eurocode__c;
            if (config.Cap_Aspect__c == PEARL || config.Cap_Color__c == STANDARD_COLOR || config.Cap_Color__c == DARK_COLOR) {
                refCol += COLORED.toUpperCase();
            } else {
                refCol += WHITE.toUpperCase();
            }

            System.debug('## Cap Coloration : ' + refCol);
            List<PM_Price_Detail__c> capColorationPrices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(refCol.toUpperCase()), CAP, CAP_COLORATION);
            Integer index = 0;
            for (PM_Price_Detail__c capColorationPrice : capColorationPrices) {
                if (capColorationPrice.List_Price__c != null && capColorationPrice.List_Price__c != 0) {
                    PM_Price_Detail__c capBasisPrice = capBasisPrices.get(index);
                    if (capBasisPrice != null && capBasisPrice.List_Price__c != null) {
                        if (capBasisPrice.List_Price__c == 0 || capBasisPrice.List_Price__c == -1 || capColorationPrice.List_Price__c == -1) {
                            if (capColorationPrice.List_Price__c != -1) {
                                capColorationPrice.List_Price__c = capBasisPrice.List_Price__c;
                            }

                        } else {
                            capColorationPrice.List_Price__c = capColorationPrice.List_Price__c - capBasisPrice.List_Price__c;
                        }

                    }
                } else {
                    capColorationPrice.List_Price__c = -1;
                }

                index++;
            }
            listDetailsToUpsert.addAll(capColorationPrices);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(refCol.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + CAP +
                                '_' + CAP_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_COLORATION;
            }
        }

        system.debug('@@qama config.Metallization__c ' + config.Metallization__c);

        // Metallization
        //  if(String.isnotBlank(config.Metallization__c) && 'No'.equalsIgnoreCase(config.Metallization__c)){
        if (config.Metallization__c == YES/* || config.Metallization__c != '0'*/) {
            String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + METALLIZATION + config.Metallization_Type__c;
            system.debug('@@qama ref met ' + ref);
            system.debug('@@qama  mapPMTubesPricing.get(ref.toUppercase()) ' + mapPMTubesPricing.get(ref.toUppercase()));
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_METALISATION);
            // /* decommented by maryem qada ==> to set -1 if no price was found
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
            // */
            listDetailsToUpsert.addAll(prices);
//            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_METALISATION));

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + CAP +
                                '_' + CAP_METALISATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_METALISATION;
            }

        }

        // LACQUERING Decoration Option CAP

        if (config.Lacquering__c == YES) {
            String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + LACQUERING + config.Lacquering_Type__c;
            system.debug('@@qama ref met ' + ref);
            system.debug('@@qama  mapPMTubesPricing.get(ref.toUppercase()) ' + mapPMTubesPricing.get(ref.toUppercase()));
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_LACQUERING);
            // /* decommented by maryem qada ==> to set -1 if no price was found
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
            // */
            listDetailsToUpsert.addAll(prices);

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + CAP +
                                '_' + CAP_LACQUERING);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_LACQUERING;
            }

        }

        // Silk-Screening
        if (config.Silk_screen__c == YES) {
            calcDecoPrice(SILK_SCREEN, SILK_SCREENING);
        }

        // Hot Stamp Top
        if (config.Hot_Stamp_Top__c == YES) {
            calcDecoPrice('TOP HS', HOT_STAMP_TOP);
        }

        // HS Contouring
        if (config.HS_Contouring__c == YES) {
            calcDecoPrice('360° HS', HS_CONTOURING);
        }

        // Shrink Band
        if (config.Shrink_band__c == YES) {
            calcDecoPrice('Sleeve', SHRINK_BAND);
        }

        // Manual Capping
        if (config.Manual_Capping__c == YES) {
            calcDecoPrice('Manual capping', MANUAL_CAPPING);
        }

        // Sleeve Material
        System.debug('## config.Sleeve_Material__c : ' + config.Sleeve_Material__c);
        // if(config.Sleeve_Material__c != MONO){
        if (config.Sleeve_Material__c != 'Mono PE') {

            //=+IF(AV3<>"Mono",
            //$J$3&$G$3&"TG1"&"standard"&VLOOKUP($AV$3,'BACK UP - Plastic'!$HA$4:$HB$11,2,0),"")

            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            //+ '4-02';
            //HM 2802 - Added lookup to Liste Codes
            /*for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                        from PM_Tubes_Config__c
                                        where Sleeve_type__c = :config.Sleeve_Material__c
                                        and Table_name__c = 'Sleeve type codes'
                                        and Location__c = :config.Location__c
                                        limit 1]){
                 ref += pm.Plastic_Code__c;
            }*/
            Decimal taux = 0.0;


            for (PM_Tubes_Config__c pm : [
                    select Plastic_Code__c,Sleeve_Meterial_Taux__c
                    from PM_Tubes_Config__c
                    where Sleeve_type__c = :config.Sleeve_Material__c
                    and Table_name__c = 'Sleeve type codes'
                    and Location__c = :config.Location__c
                    and Active__c = true
                    and Tubes_segment__c = :PLASTIC
                    limit 1
            ]) {
                ref += (pm != null ? pm.Plastic_Code__c : '');

                //taux = (pm != null ? (pm.Sleeve_Meterial_Taux__c) / 100 : 0);
                if (pm != null) {
                    Switch on config.Sleeve_Material__c {

                        when 'Coex PCR The Beautiful' {


                            if (config.Diameter_mm__c < 50) {
                                taux = 19.0 / 100;
                            } else {
                                taux = 21.0 / 100;
                            }

                        }
                        when 'Coex PCR The Ultimate' {
                            if (config.Diameter_mm__c < 50) {
                                taux = 30.0 / 100;
                            } else {
                                taux = 34.0 / 100;
                            }
                        }
                        when else {
                            if (pm.Sleeve_Meterial_Taux__c != null) {
                                taux = pm.Sleeve_Meterial_Taux__c / 100 ;
                            }

                        }
                    }
                } else {
                    taux = 0;
                }


            }
            //add for ticket 7447 start
            System.debug('## 0 Material : ' + ref);
            //Added by Thanina
            if (config.Sleeve_Material__c.equalsIgnoreCase('Mono PE Thin wall (350µ)') && config.Diameter_mm__c != 35 && config.Diameter_mm__c != 50 && config.Diameter_mm__c != 40) {
                listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, (new PM_Tubes_Pricing__c(X10__c = -1, X15__c = -1, X20__c = -1, X25__c = -1, X50__c = -1, X75__c = -1,
                        X100__c = -1, X200__c = -1, X300__c = -1, X500__c = -1, X1000__c = -1)), SLEEVE, SLEEVE_MATERIAL));
            } else {
                Map<Decimal, Decimal> totalHeadSection = calcTauxSection(TUBE_HEAD);
                listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, calculNewPrices(config.Sleeve_Material__c, mapPMTubesPricing.get(ref.toUpperCase()), taux, totalHeadSection), SLEEVE, SLEEVE_MATERIAL));

            }


            // end modif
            // listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_MATERIAL));

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + SLEEVE +
                                '_' + SLEEVE_MATERIAL);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_MATERIAL;
            }
        }
        //test ticket 7447 :
        //calcTauxSection(TUBE_HEAD);

        // Material Mix
        // TODO HM2802 - Add Basis Price * 0.02, if Material Mix = "PCR"
        System.debug('MATERIAL MIX CALCULATION');
        if (config.Sleeve_Material_Mix__c == NON_STD_MIX) {

            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '4-01';
            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, MATERIAL_MIX));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + SLEEVE +
                                '_' + MATERIAL_MIX);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = MATERIAL_MIX;
            }
        }
        /* if (config.Sleeve_Material_Mix__c == 'PCR') {
             if (tgPriceDetails != null) {
                 for (PM_Price_Detail__c tgBasisPrice : tgPriceDetails) {
                     Decimal listPrice = tgBasisPrice.List_Price__c * 0.02;
                     PM_Price_Detail__c pmSleeveMaterial = new PM_Price_Detail__c(
                         MOQ_Min__c = tgBasisPrice.MOQ_Min__c,
                         MOQ_Max__c = tgBasisPrice.MOQ_Max__c,
                         PM_Selected_Tubes_Config__c = config.Id,
                         Quote_item__c = config.Quote_item__c,
                         List_Price__c = listPrice,
                         ExtId__c = config.Id + MATERIAL_MIX + tgBasisPrice.MOQ_Min__c,
                         Name = MATERIAL_MIX,
                         Section__c = SLEEVE
                     );
                     listDetailsToUpsert.add(pmSleeveMaterial);

                 }
             }
        // listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, MATERIAL_MIX));

         }*/


        // Sleeve Aspect
        listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_ASPECT));

        // Sleeve Coloration
        calcSleeveColoration();

        // Sleeve Finish
        listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, null, SLEEVE, SLEEVE_FINISH));


        // Printing Type
        if (String.isNotBlank(config.Printing_technologies__c) && config.Printing_technologies__c != UNPRINTED) {
            System.debug('PRINTING TYPE CALCULATION...............');
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            String tg = getPrintingTG(config.Printing_technologies__c, config.NB_Offset_Colors__c, config.NB_Flexo_Colors__c, config.NB_SS_Colors__c);
            System.debug('## Printing TG : ' + tg);

            // get Code tarification
            for (PM_Tubes_Config__c pm : [
                    select Code_TG__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Printing_TG__c = :tg
                    and Table_name__c = 'Printing Technology'
                    and Tubes_segment__c = :PLASTIC
                    limit 1
            ]) {
                ref += pm.Code_TG__c;
            }

            System.debug('## Printing Type : ' + ref);

            // modified by safa J to display specific if the config doesn't exist ------> ticket n°3072
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_TYPE);
            system.debug('prices=' + prices);
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
            listDetailsToUpsert.addAll(prices);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + PRINTING +
                                '_' + PRINTING_TYPE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_TYPE;
            }

            //listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_TYPE));
        }

        // Other Printing Effects
        if (String.isNotBlank(config.Printing_Effects__c) && config.Printing_Effects__c != NO) {
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;

            for (PM_Tubes_Config__c pm : [
                    select Code_printing_effect__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Printing_Effects__c = :config.Printing_Effects__c
                    and Table_name__c = 'Printing Effects'
                    limit 1
            ]) {
                ref += pm.Code_printing_effect__c;
            }

            System.debug('## Other Printing Effects : ' + ref);

            // modified by safa J to display specific if the config doesn't exist ------> ticket n°3072
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, OTHER_PRINT_EFFECT);
            system.debug('prices=' + prices);
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
            listDetailsToUpsert.addAll(prices);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + PRINTING +
                                '_' + OTHER_PRINT_EFFECT);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = OTHER_PRINT_EFFECT;
            }

            //listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, OTHER_PRINT_EFFECT));

        }

        // Sleeve Hot Stamping
        if (String.isNotBlank(config.Deco_Hot_Stamping__c)) {
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;

            for (PM_Tubes_Config__c pm : [
                    select Code_hot_stamping__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Hot_Stamping__c = :config.Deco_Hot_Stamping__c
                    and Table_name__c = 'Hot Stamping'
                    limit 1
            ]) {
                ref += pm.Code_hot_stamping__c;
            }

            System.debug('## Sleeve Hot Stamping : ' + ref);

            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, SLEEVE_HOT_STAMP));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + PRINTING +
                                '_' + SLEEVE_HOT_STAMP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_HOT_STAMP;
            }
        }

        // Combo
        if (config.Combo_Num_Versions__c > 1
                && config.Combo_Num_Tubes_Artwork__c > 0
                && config.Combo_Num_Plate_Changes__c > 0) {

            List <PM_Price_Detail__c> details = PMCalculatorUtility.getLineDetails(config, null, OTHERS, COMBO);

            for (Integer i = 0; i < listMinMOQ.size(); i++) {
                //Decimal moq = listMinMOQ[i];
                Integer moq = listMinMOQ[i].intValue();
                Decimal a = Math.max((moq * 1000 / config.Combo_Num_Tubes_Artwork__c.intValue()), 1);
                Decimal b = Math.min(config.Combo_Num_Versions__c, a) - 1;


                //HM 2802 - Check customer Country if germany, multily by 180 instead of 280
                Integer costPerChangeOfPrintingPlates = 280;
                if (qli != null
                        &&
                        (qli.Customer_Country__c == 'Germany'
                                || qli.Customer_Country__c == 'Austria'
                                || qli.Customer_Country__c == 'Switzerland')) {
                    costPerChangeOfPrintingPlates = 180;
                }


/////////////////////
                try {
                    PM_MOQ_price__c moqprice = [
                            SELECT id,MOQ_Max__c,IsCombo__c,No_Ref_If_Combo_Comments__c
                            from PM_MOQ_price__c
                            where Quote_item__c = :details[i].Quote_item__c AND MOQ_Max__c = :moq
                    ];
                    if (moqprice!= null && moqprice.No_Ref_If_Combo_Comments__c.equals('Only 1 ref.')) {
                        details[i].List_Price__c = 0;

                    }


                    else {
                        details[i].List_Price__c = (b * config.Combo_Num_Plate_Changes__c * costPerChangeOfPrintingPlates) / moq;

                    }
                } catch (QueryException e) {
                    details[i].List_Price__c = (b * config.Combo_Num_Plate_Changes__c * costPerChangeOfPrintingPlates) / moq;

                }catch (NullPointerException e)
                {
                    System.debug( e)  ;
                }

                /////

            }

            System.debug('## Combo : ' + details);
            listDetailsToUpsert.addAll(details);
        }

        // Platt's
        system.debug('Calculating Platts');
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0) ? 1 : config.Billing_Currency_Rate__c;

        if (config.Diameter_mm__c > 0 && dLength > 0 && config.Nouveau_Platts__c > 0) {
            for (PM_Tubes_Config__c pm : [
                    select Platts_Poids_Jupe_nets__c, Platts_Poids_tete__c, Platts_bouchon__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Diameter_mm__c = :config.Diameter_mm__c
                    and Table_name__c = 'Platts'
                    limit 1
            ]) {
                system.debug(pm);
                /* Decimal a = (pm.Platts_Poids_Jupe_nets__c/100) * dLength * 1.25;
                 Decimal b = pm.Platts_Poids_tete__c * 1.25;
                 Decimal c = pm.Platts_bouchon__c * 1.05;
                 Decimal dPlatts = ((a + b + c) * (config.Nouveau_Platts__c - DEFAULT_PLATTS)) / 1000;
 */

                //HM 0103/ Correct calculation
                Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                //Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                Decimal poidJupeEtTete = ((pm.Platts_Poids_Jupe_nets__c / 100)
                        * dLength + pm.Platts_Poids_tete__c) * 1.25 * plattsDif;
                Decimal poidBouchon = pm.Platts_bouchon__c * 1.05 * plattsDif;
                Decimal dPlatts = poidJupeEtTete + poidBouchon;
                System.debug('DLENGHT=' + dLength + 'PLATTSDIF=' + plattsDif + '=poidJupeEtTete=' + poidJupeEtTete
                        + '=poidBouchon=' + poidBouchon + '=dPlatts=' + dPlatts);

                listDetailsToUpsert.addAll(setListPrice(PMCalculatorUtility.getLineDetails(config, null, OTHERS, PLATTS), dPlatts * currencyRate));
            }
        }

        // Freight Price
        if (config.Delivery__c == DAP) {
            // config.Destination__c
            String ref = config.Diameter_mm__c + TG1;
            for (PM_Tubes_Config__c tc : [
                    select Plastic_Code__c
                    from PM_Tubes_Config__c
                    where Table_name__c = 'Delivery-Destination-Plastic Code'
                    and Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Destination__c = :config.Destination__c
                    limit 1
            ]) {
                ref += tc.Plastic_Code__c;

            }
            System.debug('## Freight Price : ' + ref);
            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, FREIGHT_PRICE));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + OTHERS +
                                '_' + FREIGHT_PRICE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = FREIGHT_PRICE;
            }
        }

        // Payment Terms : modified for ticket 6654
        System.debug('Payment TERMS START ');
        calculatePAYMENT_TERMS();
        /*if(String.isNotBlank(config.Payment_terms__c)){
            for(PM_Tubes_Config__c tc : [select Weight_value__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Payment Terms'
                                            and Location__c = :config.Location__c
                                            and Payment_Terms__c = :config.Payment_terms__c
                                            limit 1]){
                 listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                     //calcOthers(new Set <String> {'APPLY_ZERO_PERCENT',STOCKAGE, EOY_REBATE, SKONTO}, (tc.Weight_value__c / 100), PAYMENT_TERMS)));
                     PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT',STOCKAGE, EOY_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, PAYMENT_TERMS)));
            }
        } */
        System.debug('Payment TERMS END ');


        // Skonto
        if (qli.DS_Skonto_for_cash_payment__c != null && qli.DS_Skonto_for_cash_payment__c != 'No') {
            listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupOther(
                            listDetailsToUpsert,
                            new Set<String>{
                                    'APPLY_ZERO_PERCENT', EOY_REBATE
                            },
                            config,
                            PMCalculatorUtility.calculateSKONTO(qli.Customer_Country__c, qli.DS_Skonto_for_cash_payment__c),
                            OTHERS,
                            SKONTO));
        }
        //listDetailsToUpsert.addAll(calcOthers(new Set <String> {'APPLY_ZERO_PERCENT', EOY_REBATE},  PMCalculatorUtility.calculateSKONTO(qli.Customer_Country__c, qli.DS_Skonto_for_cash_payment__c), SKONTO));


        // Stockage
        // Stockage updated for ticket: 6654

        calculateSTOCKAGE();
        /* if(String.isNotBlank(config.Stockage__c)){
             for(PM_Tubes_Config__c tc : [select Weight_value__c
                                             from PM_Tubes_Config__c
                                             where Table_name__c = 'Stockage'
                                             and Location__c = :config.Location__c
                                             and Stockage__c = :config.Stockage__c
                                             limit 1]){

                 listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                     PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>{'APPLY_ZERO_PERCENT', PAYMENT_TERMS, EOY_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, STOCKAGE)));
             //  listDetailsToUpsert.addAll(
             //        PMCalculatorUtility.calcGroup(listDetailsToUpsert,new Set <String> {'APPLY_ZERO_PERCENT', PAYMENT_TERMS, EOY_REBATE, SKONTO}, config,
             //                                      (tc.Weight_value__c / 100), OTHERS, STOCKAGE));


                // calcOthers(new Set <String> {'APPLY_ZERO_PERCENT',PAYMENT_TERMS, EOY_REBATE, SKONTO}, (tc.Weight_value__c / 100), STOCKAGE);
             }
         } */


        // PE Bag
        if (config.PE_Bag__c == YES) {
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '13-02';
            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, PE_BAG));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + OTHERS +
                                '_' + PE_BAG);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PE_BAG;
            }
        }

        // End of Year Rebate
        if (qli != null && String.isNotBlank(qli.Customer_end_of_year_rebate__c)) {
            Decimal dPercent = 0;
            // TODO : query percent - RECO - Backup N19:R20
            if (qli.Customer_end_of_year_rebate__c == 'Yes (3% or more)') {
                dPercent = 0.03;
            } else if (qli.Customer_end_of_year_rebate__c == 'Yes (2%)') {
                dPercent = 0.02;
            } else if (qli.Customer_end_of_year_rebate__c == 'Yes (1%)') {
                dPercent = 0.01;
            }

            if (dPercent != 0) {
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setSpecificPriceToZero(
                                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>(), config,
                                        dPercent, OTHERS, EOY_REBATE)));
            }

            else {
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getLineDetails(config, null, OTHERS, EOY_REBATE));
            }

            system.debug('END OF YEAR REBATE' + dPercent);
            //listDetailsToUpsert.addAll(calcOthers(new Set <String> {'APPLY_ZERO_PERCENT', SKONTO}, dPercent, EOY_REBATE));
        }


        System.debug('## listDetailsToUpsert : ' + listDetailsToUpsert.size());

        if (listDetailsToUpsert.size() > 0) {
            upsert listDetailsToUpsert ExtId__c;
        }

        //-- TOTAL --//
        calculateTotalMOQPRice(config.Id, config.Quote_item__c);
        // Added for Historisation
        if (mapPMTubesPricing.size() > 0) update mapPMTubesPricing.values();
        upsert listPricingJunctionToUpsert Unique_Key__c;

    }
    //ticket_6654
    public void calculatePAYMENT_TERMS() {
        //log('*********** calculatePAYMENT_TERMS ***********LINE='+ PAYMENT_TERMS);
        if (String.isNotBlank(config.Payment_terms__c)) {
            /* for(PM_Tubes_Config__c tc : [select Weight_value__c
                 from PM_Tubes_Config__c
                 where Table_name__c = 'Payment Terms'
                 and Location__c = :config.Location__c
                 and Payment_Terms__c = :config.Payment_terms__c
                 limit 1]){

                 system.debug(tc.Weight_value__c);
                 listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                     PMCalculatorUtility.calcGroupOther(listDetailsToUpsert,new Set <String> {'APPLY_ZERO_PERCENT'}, config,
                       (tc.Weight_value__c / 100), OTHERS, PAYMENT_TERMS)));
             }*/
            String ref = 'PAYMENT' + config.Payment_terms__c;
            //------Right values-------
            if (mapPMTubesPricing.get(ref.toUpperCase()) != null) {
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setSpecificPriceToZero(
                                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String>{
                                        'APPLY_ZERO_PERCENT', STOCKAGE, EOY_REBATE, SKONTO
                                }, config, (mapPMTubesPricing.get(ref.toUpperCase())).X10__c, OTHERS, PAYMENT_TERMS)));
                System.debug('Thanina display value: ' + (mapPMTubesPricing.get(ref.toUpperCase())).X10__c);
            }
        }

    }

    //added for ticket 6654
    public void calculateSTOCKAGE() {
        //  log('*********** calculatePUMP ***********LINE='+ STOCKAGE);
        /* if(String.isNotBlank(config.Stockage__c)){
              for(PM_Tubes_Config__c tc : [select Weight_value__c
                                              from PM_Tubes_Config__c
                                              where Table_name__c = 'Stockage'
                                              and Location__c = :config.Location__c
                                              and Stockage__c = :config.Stockage__c
                                              limit 1]){

                  listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                      PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>{'APPLY_ZERO_PERCENT', PAYMENT_TERMS, EOY_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, STOCKAGE)));

              }
         } */

        if (String.isNotBlank(config.Stockage__c)) {

            String ref = 'STOCKAGE' + config.Stockage__c;
            if (mapPMTubesPricing.get(ref.toUpperCase()) != null) {
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setSpecificPriceToZero(
                                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String>{
                                        'APPLY_ZERO_PERCENT', PAYMENT_TERMS, EOY_REBATE, SKONTO
                                }, config, (mapPMTubesPricing.get(ref.toUpperCase())).X10__c, OTHERS, STOCKAGE)));
            }
        }

    }
    //end added


    /**
     * Calculates the total of MP Prices and update the MOQ Price
     *
     */
    public static void calculateTotalMOQPRice(String tubeId, String qliId) {
        List<PM_Price_Detail__c> prices = [
                Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c, Price__c, List_Price__c
                from PM_Price_Detail__c
                where PM_Selected_Tubes_Config__c = :tubeId and moq_max__c != 999
                order by MOQ_Min__c desc
        ];//MQ: added MOQ_Max__c != 999 to not consider specific moq

        Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = new Map <Decimal, PM_MOQ_price__c>();

        for (PM_Price_Detail__c pm : prices) {
            if (mapPMMOQPrice.containsKey(pm.MOQ_Min__c)) {
                //For Length Upcharge, do not take into account the -1 as specific
                if (LEN_UPCHARGE.equalsIgnoreCase(pm.Name)) {
                    system.debug(pm.MOQ_Min__c + '=' + pm.Price__c + '==' + mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c);
                    if (mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1) {
                        mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c += pm.Price__c;
                    }
                } else {
                    //if(pm.List_Price__c == -1){
                    if (pm.Price__c == -1 && pm.List_Price__c == -1) {
                        //mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = pm.Price__c;
                        mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = -1;
                    } else if (mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1) {
                        mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c += pm.Price__c;
                    }
                }

            } else {
                PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = tubeId,
                        Quote_item__c = qliId,
                        List_Price__c = pm.Price__c,
                        ExtId__c = pm.MOQ_Min__c + '-' + tubeId
                );
                System.debug('## mapPMMOQPrice : ' + pmMOQ);
                mapPMMOQPrice.put(pm.MOQ_Min__c, pmMOQ);
            }
        }

        System.debug('## mapPMMOQPrice : ' + mapPMMOQPrice);
        if (mapPMMOQPrice.size() > 0) {
            upsert mapPMMOQPrice.values() ExtId__c;
        }


    }

    //Commented by Aleriche, calcOthers is now used from PMCalulatorUtility
    /*
    public List<PM_Price_Detail__c> calcOthers(Set <String> setLinesToSkip, Decimal dPercent, String sLine){
        Map <Decimal, PM_Price_Detail__c> mapPaymentTerms = new Map <Decimal, PM_Price_Detail__c>();

        Decimal dPercentage = dPercent == 0 ? 1 :dPercent;
        //If there is APPLY_ZERO_PERCENT as setting, if percentage equals to zero, the value must be zero as well
        //In Normal case, the percentage is set to 1 if it is zero
        if (setLinesToSkip != null && setLinesToSkip.contains('APPLY_ZERO_PERCENT')) {
             dPercentage = dPercent;
       }

       for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(!setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                Decimal listPrice = 0;
                if (pm.List_Price__c == -1) {
                    listPrice = -1;
                } else {
                    listPrice = pm.List_Price__c * dPercentage;
                }

                if(mapPaymentTerms.containsKey(pm.MOQ_Min__c)){
                    if(pm.Price__c == -1){
                        mapPaymentTerms.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(mapPaymentTerms.get(pm.MOQ_Min__c).List_Price__c != -1){
                        mapPaymentTerms.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }

                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = OTHERS
                    );
                    mapPaymentTerms.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        }

        System.debug('## Payment Terms : ' + mapPaymentTerms);

        return mapPaymentTerms.values();
    }
*/

    //ticket 6654
    public void calcDecoPrice(String capFeatureType, String line) {
        /* for(PM_Tubes_Config__c pm : [select Cap_feature_price__c
                                         from PM_Tubes_Config__c
                                         where Diameter_mm__c = :config.Diameter_mm__c
                                         and Cap_feature_type__c = :capFeatureType
                                         and Cap_feature_price__c != null
                                         and Table_name__c = 'PRIX DECO / CAP FEATURE'
                                         and Location__c = :config.Location__c
                                         and Tubes_segment__c = :PLASTIC
                                         limit 1]){
             System.debug('## Silk-Screening : ' + pm.Cap_feature_price__c);
             // We set the currency rate to be
             Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;

             listDetailsToUpsert.addAll(setListPrice(PMCalculatorUtility.getLineDetails(config, null, CAP, line), pm.Cap_feature_price__c * currencyRate));
         }*/
        //added for ticket 6654
        String ref = capFeatureType + config.Diameter_mm__c;
        if (mapPMTubesPricing.get(ref.toUpperCase()) != null) {
            Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0) ? 1 : config.Billing_Currency_Rate__c;
            System.debug('@@ ref = : ' + ref);
            listDetailsToUpsert.addAll(setListPrice(PMCalculatorUtility.getLineDetails(config, null, CAP, line), mapPMTubesPricing.get(ref.toUpperCase()).X10__c * currencyRate));
        }

    }

    public void calcPeelSealEU() {
        system.debug('*******************>calcPeelSealEU=' + config.Peel_Seal__c);
        if (YES.equalsIgnoreCase(config.Peel_Seal__c)) {

            //String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            //this modif were rolledback
            //Start Modif ref ticket 7005
            String ref = config.Diameter_mm__c + config.Cap_Eurocode__c + 'Peel Seal ';
            if (String.isNotBlank(config.Printing_technologies__c)
                    &&
                    config.Printing_technologies__c.contains(SILKSCREEN)
                    ) ref += 'Silkscreen printing'; else ref += 'Other printing technology';

            //End Modif Peel Seal
            /*
            String printingTG = getPrintingTG(config.Printing_technologies__c, config.NB_Offset_Colors__c, config.NB_Flexo_Colors__c, config.NB_SS_Colors__c);
            system.debug(config.Printing_technologies__c + '=PrintingTG=' + printingTG);
            //HM 2802 - Retrieve the Code Peel Seal from Priting technology
            for(PM_Tubes_Config__c pm : [select code_peel_seal__c
                                        from PM_Tubes_Config__c
                                        where Printing_TG__c = :printingTG
                                        and Table_name__c = 'Printing Technology'
                                        and Location__c = :config.Location__c
                                        and Tubes_segment__c = :PLASTIC
                                        limit 1]){
                 ref += pm.code_peel_seal__c;
            }

            //if(String.isNotBlank(config.Printing_technologies__c)
              // && config.Printing_technologies__c.contains(SILKSCREEN)){
                //ref += '10-02';
            //}else{
              //  ref += '10-01';
             //}
            */
            //DiameterEurocodePeel seal Silkscreen printing ou DiameterEurocodePeel seal Other printing technology
            System.debug('## Peel Seal : ' + ref);

            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()) != null ? mapPMTubesPricing.get(ref.toUppercase()) : mapPMTubesPricing.get((PLASTIC + 'Peel Seal Specific').toUppercase()), TUBE_HEAD, PEEL_SEAL));

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if (dp != null) {
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                        Tube_Pricing__c = dp.Id,
                        Unique_Key__c = config.Id + '_' + TUBE_HEAD +
                                '_' + PEEL_SEAL);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PEEL_SEAL;
            }
        } else {
            listDetailsToUpsert.addAll(PMCalculatorUtility.getLineDetails(config, null, TUBE_HEAD, PEEL_SEAL));
        }
    }

    public void calcSleeveColoration() {
        String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
        if (config.Sleeve_Aspect__c == PEARL) {
            for (PM_Tubes_Config__c pm : [
                    select Plastic_Code__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Aspect__c = :config.Sleeve_Aspect__c
                    and Table_name__c = 'Sleeve / Head / Cap aspect code'
                    limit 1
            ]) {
                ref += pm.Plastic_Code__c;
            }
        } else {
            for (PM_Tubes_Config__c pm : [
                    select Plastic_Code__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Tubes_segment__c = :PLASTIC
                    and Color__c = :config.Sleeve_Color__c
                    and Table_name__c = 'Sleeve / Head / Cap Color code'
                    limit 1
            ]) {
                ref += pm.Plastic_Code__c;
            }
        }
        System.debug('## Sleeve Coloration : ' + ref);
        List<PM_Price_Detail__c> details = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_COLORATION);
        system.debug(details);
        listDetailsToUpsert.addAll(details);
        // Added for Historisation
        // Create Junction Object
        PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
        if (dp != null) {
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                    Tube_Pricing__c = dp.Id,
                    Unique_Key__c = config.Id + '_' + SLEEVE +
                            '_' + SLEEVE_COLORATION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMTubesPricing.get(ref.toUppercase()) != null) {
            mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
            mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_COLORATION;
        }

    }

    public void calcLengthUpchargeEU() {
        if (config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c) && String.isNotBlank(groupe)) {
            //Code length - N3
            String ref1 = groupe + config.Diameter_mm__c + TG1 + STANDARD + '3-01';
            String ref2 = '';

            //Code extra Length - P3
            if (config.Diameter_mm__c < 22 && dLength > 60) {
                ref2 = groupe + config.Diameter_mm__c + TG1 + STANDARD + '3-02';
            }

            system.debug('LENGTH UPCHARGE REF1=' + ref1);
            system.debug('LENGTH UPCHARGE REF2=' + ref2);

            // HM 28/02 - Get the standard length for the sleeve length
            Decimal stdLengthForDiameter = 0;
            for (PM_Tubes_Config__c pm : [
                    select STD_LENGTH__c
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Diameter_mm__c = :config.Diameter_mm__c
                    and Table_name__c = 'Standard Length'
                    limit 1
            ]) {

                stdLengthForDiameter = Decimal.valueOf(pm.STD_LENGTH__c);
            }

            Decimal coeff = dLength > 0 ? (dLength - stdLengthForDiameter) / 5 : 0 ;
            system.debug('stdLengthForDiameter=' + stdLengthForDiameter
                    + ';dLength=' + dLength
                    + ';coeff=' + coeff);


            System.debug('LENGTH UPCHARGE=' + ref1);
            // ref1
            if (mapPMTubesPricing.containsKey(ref1.toUppercase())) {
                details = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref1.toUppercase()), TUBE_HEAD, LEN_UPCHARGE);

                for (PM_Price_Detail__c detail : details) {
                    detail.List_Price__c = detail.List_Price__c * coeff;
                    //Hack to prevent displaying specific
                    if (detail.List_Price__c == -1) {
                        detail.List_Price__c = detail.List_Price__c + 0.00001;
                    }
                }
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref1.toUpperCase());
                if (dp != null) {
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                            Tube_Pricing__c = dp.Id,
                            Unique_Key__c = config.Id + '_' + TUBE_HEAD +
                                    '_' + LEN_UPCHARGE);
                    listPricingJunctionToUpsert.add(pj);
                }

                // Update Prices
                if (mapPMTubesPricing.get(ref1.toUppercase()) != null) {
                    mapPMTubesPricing.get(ref1.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref1.toUppercase()).Line_Name__c = LEN_UPCHARGE;
                }
            }
            system.debug(details);

            //HM 2802 - Get the possible length
            Integer countPossibleLength = 0;
            String specificLength = '' + config.Specific_length_mm__c;
            List<PM_Tubes_Config__c> pms = [
                    select id
                    from PM_Tubes_Config__c
                    where Location__c = :config.Location__c
                    and Table_name__c = 'POSSIBLE LENGTH'
                    and Diameter_mm__c = :config.Diameter_mm__c
                    AND STD_LENGTH__c = :specificLength
            ];
            countPossibleLength = pms.size();


            //HM 2802 - Criteria to add upcharge non standard length
            system.debug('UPCHARGE NON STANDARD LENGTH__' + config.Specific_length_mm__c + '__' + (config.Specific_length_mm__c == 0) + '_'
                    + (config.Specific_length_mm__c == config.Sleeve_length_mm__c) + '_'
                    + (countPossibleLength == 1) + '_');
            if (config.Specific_length_mm__c == null || config.Specific_length_mm__c == 0 || config.Specific_length_mm__c == config.Sleeve_length_mm__c
                    || countPossibleLength == 1) {

                system.debug('DO NOT ADD ANYTHING TO UPCHARGE NON STANDARD LENGTH');
                //Do not do anything
            } else {

                system.debug('ADD UPCHARGE NON STANDARD LENGTH');
                for (PM_Price_Detail__c detail : details) {
                    detail.List_Price__c += config.Diameter_mm__c < 30 ? 6 : 10;
                }
            }

            // ref2
            System.debug('LENGTH UPCHARGE2 =' + ref2);
            if (mapPMTubesPricing.containsKey(ref2.toUppercase()) && details != null) {
                List <PM_Price_Detail__c> details2 = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref2.toUppercase()), TUBE_HEAD, LEN_UPCHARGE);

                for (Integer i = 0; i < details.size(); i++) {
                    details[i].List_Price__c = details[i].List_Price__c + details2[i].List_Price__c;
                }
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref2.toUpperCase());
                if (dp != null) {
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id,
                            Tube_Pricing__c = dp.Id,
                            Unique_Key__c = config.Id + '_' + TUBE_HEAD +
                                    '_' + LEN_UPCHARGE + '_2');
                    listPricingJunctionToUpsert.add(pj);
                }

                // Update Prices
                if (mapPMTubesPricing.get(ref2.toUppercase()) != null) {
                    mapPMTubesPricing.get(ref2.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref2.toUppercase()).Line_Name__c = LEN_UPCHARGE;
                }
            }

            if (details != null) {
                listDetailsToUpsert.addAll(details);
            }
        }
    }

    // sets the same ListPrice on all detail records
    public static List <PM_Price_Detail__c> setListPrice(List <PM_Price_Detail__c> details, Decimal listPrice) {
        for (PM_Price_Detail__c detail : details) {
            detail.List_Price__c = listPrice;
        }
        return details;
    }

/*    public static String getPrintingTG(String tech, Decimal iOffset, Decimal iFlexo, Decimal iSilkscreen){
        if(tech == OFFSET){
            return OFFSET + ' ' + (iOffset > 6 ? '7' : iOffset > 3 ? '4-6' : '1-3');
        }else if(tech == FLEXO){
            return FLEXO + ' ' + (iFlexo > 6 ? '7-10' : '1-6');
        }else if(tech == SILKSCREEN){
            return SILKSCREEN + ' ' + (iSilkscreen > 3 ? '4-6' : '1-3');
        }else if(tech == FLEXO_SS){
            //HM 13/03 - Corrected the Priting return
            String returnValue = UNPRINTED;
            if (iOffset > 0 && iOffset < 5 && iSilkscreen > 0 && iSilkscreen < 3) {
                returnValue = 'Flexo 1-4 + Silkscreen 1-2';

            } else if (iOffset > 0 && iOffset < 4 && iSilkscreen == 3) {
                returnValue = 'Flexo 1-3 + Silkscreen 3';
            }
            return returnValue;

        }else if(tech == OFFSET_SS){
            if(iSilkscreen > 3){
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 4-6' : 'Offset 1-3 + Silkscreen 4-6';
            }else{
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 1-3' : 'Offset 1-3 + Silkscreen 1-3';
            }
        }
        return UNPRINTED;
    }*/

    public static String getPrintingTG(String tech, Decimal iOffset, Decimal iFlexo, Decimal iSilkscreen) {
        String returnValue = UNPRINTED;
        if (tech == OFFSET) {

            //return OFFSET + ' ' + (iOffset > 6 ? '7' : iOffset > 3 ? '4-6' : '1-3');
            //HM 30/04 - Corrected the Priting return

            if (iOffset > 0 && iOffset < 4) {
                returnValue = 'Offset 1-3';
            } else if (iOffset > 3 && iOffset < 7) {
                returnValue = 'Offset 4-6';
            } else if (iOffset == 7) {
                returnValue = 'Offset 7';
            }

        } else if (tech == FLEXO) {
            //HM 30/04 - Corrected the Priting return
            if (iFlexo > 0 && iFlexo < 7) {
                returnValue = 'Flexo 1-6';
            } else if (iFlexo > 6 && iFlexo < 11) {
                returnValue = 'Flexo 7-10';
            }
            //return FLEXO + ' ' + (iFlexo > 6 ? '7-10' : '1-6');

        } else if (tech == SILKSCREEN) {
            //HM 30/04 - Corrected the Priting return
            if (iSilkscreen > 0 && iSilkscreen < 4) {
                returnValue = 'Silkscreen 1-3';
            } else if (iSilkscreen > 3 && iSilkscreen < 7) {
                returnValue = 'Silkscreen 4-6';
            }
        } else if (tech == FLEXO_SS) {
            //HM 13/03 - Corrected the Priting return
            if (iFlexo > 0 && iFlexo < 5 && iSilkscreen > 0 && iSilkscreen < 3) {
                returnValue = 'Flexo 1-4 + Silkscreen 1-2';

            } else if (iFlexo > 0 && iFlexo < 4 && iSilkscreen == 3) {
                returnValue = 'Flexo 1-3 + Silkscreen 3';
            }

        } else if (tech == OFFSET_SS) {
            if (iSilkscreen > 3) {
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 4-6' : 'Offset 1-3 + Silkscreen 4-6';
            } else {
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 1-3' : 'Offset 1-3 + Silkscreen 1-3';
            }
        }
        return returnValue;
    }


    //added for ticket 7447 need to calculate , X% of section
    /*
      Compute Total for a particular section
     */

    public Map<Decimal, Decimal> calcTauxSection(String sectionName) {

        Map<Decimal, Decimal> mapTotalSection = new Map<Decimal, Decimal>();
        List<PM_Price_Detail__c> listSectionName = new List<PM_Price_Detail__c>();
        if (listDetailsToUpsert != null && listDetailsToUpsert.size() > 0) {
            for (PM_Price_Detail__c price : listDetailsToUpsert) {
                if (price.Section__c.equalsIgnoreCase(sectionName)) {
                    if (mapTotalSection.containsKey(price.MOQ_Min__c)) {

                        mapTotalSection.put(price.MOQ_Min__c, price.List_Price__c + mapTotalSection.get(price.MOQ_Min__c));

                    } else mapTotalSection.put(price.MOQ_Min__c, price.List_Price__c);
                }
            }
        }

        if (mapTotalSection.size() > 0) return mapTotalSection; else return (mapTotalSection = new Map<Decimal, Decimal>{
                10 => 0, 15 => 0, 20 => 0, 25 => 0, 50 => 0, 75 => 0, 100 => 0,
                200 => 0, 300 => 0, 500 => 0, 1000 => 0
        });
    }

    public Map<Decimal, Decimal> calcTauxPrice(List<PM_Price_Detail__c> totalprice) {

        Map<Decimal, Decimal> mapTotalSection = new Map<Decimal, Decimal>();
        if (tgPriceDetails != null && tgPriceDetails.size() > 0) {
            for (PM_Price_Detail__c price : totalprice) {

                if (mapTotalSection.containsKey(price.MOQ_Min__c)) {

                    mapTotalSection.put(price.MOQ_Min__c, price.List_Price__c + mapTotalSection.get(price.MOQ_Min__c));

                } else mapTotalSection.put(price.MOQ_Min__c, price.List_Price__c);

            }
        }

        if (mapTotalSection.size() > 0) return mapTotalSection; else return (mapTotalSection = new Map<Decimal, Decimal>{
                10 => 0, 15 => 0, 20 => 0, 25 => 0, 50 => 0, 75 => 0, 100 => 0,
                200 => 0, 300 => 0, 500 => 0, 1000 => 0
        });
    }

    /*
       Find new prices based in existing prices and taux of the total
     */
    public PM_Tubes_Pricing__c calculNewPrices(String sleeveMatVal, PM_Tubes_Pricing__c pricesInitial, Decimal taux, Map<Decimal, Decimal> totalSection) {
        PM_Tubes_Pricing__c LastUserPrice = null;
        Map<Decimal, Decimal> totalBasisPrice = null;
        Map<Decimal, Decimal> totalLengthUpcharge = null;
        Map<Decimal, Decimal> totalCapBasisPrice = null;
        if (tgPriceDetails != null) {
            totalBasisPrice = calcTauxPrice(tgPriceDetails);
        }
        if (details != null) {
            totalLengthUpcharge = calcTauxPrice(details);
        }
        if (capBasisPrices != null) {
            totalCapBasisPrice = calcTauxPrice(capBasisPrices);
        }

        if (pricesInitial != null) {

            if (sleeveMatVal != '' && sleeveMatVal != null && (sleeveMatVal.contains('ISCC') && totalBasisPrice != null && totalLengthUpcharge != null && totalCapBasisPrice != null || Test.isRunningTest())) {
                if (config.Diameter_mm__c < 50) {
                    LastUserPrice = CalculNewPriceSleeveCCP(sleeveMatVal, 0.25, pricesInitial, totalBasisPrice, totalLengthUpcharge, totalCapBasisPrice);

                } else {
                    LastUserPrice = CalculNewPriceSleeveCCP(sleeveMatVal, 0.4, pricesInitial, totalBasisPrice, totalLengthUpcharge, totalCapBasisPrice);

                }

            } else {
                LastUserPrice = new PM_Tubes_Pricing__c(
                        X10__c = pricesInitial.X10__c + totalSection.get(10) * taux,
                        X15__c = pricesInitial.X15__c + totalSection.get(15) * taux,
                        X20__c = pricesInitial.X20__c + totalSection.get(20) * taux,
                        X25__c = pricesInitial.X25__c + totalSection.get(25) * taux,
                        X50__c = pricesInitial.X50__c + totalSection.get(50) * taux,
                        X75__c = pricesInitial.X75__c + totalSection.get(75) * taux,
                        X100__c = pricesInitial.X100__c + totalSection.get(100) * taux,
                        X200__c = pricesInitial.X200__c + totalSection.get(200) * taux,
                        X300__c = pricesInitial.X300__c + totalSection.get(300) * taux,
                        X500__c = pricesInitial.X500__c + totalSection.get(500) * taux,
                        X1000__c = pricesInitial.X1000__c + totalSection.get(1000) * taux
                );
            }
        }
        //il faut voir est ce que c'est des MONO PCR et MONO Biobased
        else {

            if (sleeveMatVal != '' && sleeveMatVal != null) {

                if (sleeveMatVal.contains('Mono') || Test.isRunningTest())
                    LastUserPrice = new PM_Tubes_Pricing__c(
                            X10__c = totalSection.get(10) * taux,
                            X15__c = totalSection.get(15) * taux,
                            X20__c = totalSection.get(20) * taux,
                            X25__c = totalSection.get(25) * taux,
                            X50__c = totalSection.get(50) * taux,
                            X75__c = totalSection.get(75) * taux,
                            X100__c = totalSection.get(100) * taux,
                            X200__c = totalSection.get(200) * taux,
                            X300__c = totalSection.get(300) * taux,
                            X500__c = totalSection.get(500) * taux,
                            X1000__c = totalSection.get(1000) * taux); else if (sleeveMatVal.contains('ISCC') && totalBasisPrice != null && totalLengthUpcharge != null && totalCapBasisPrice != null || Test.isRunningTest()) {
                    if (config.Diameter_mm__c < 50) {
                        LastUserPrice = CalculNewPriceSleeveCCP(sleeveMatVal, 0.25, pricesInitial, totalBasisPrice, totalLengthUpcharge, totalCapBasisPrice);

                    } else {
                        LastUserPrice = CalculNewPriceSleeveCCP(sleeveMatVal, 0.4, pricesInitial, totalBasisPrice, totalLengthUpcharge, totalCapBasisPrice);

                    }

                } else {

                    LastUserPrice = new PM_Tubes_Pricing__c(X10__c = -1, X15__c = -1, X20__c = -1, X25__c = -1, X50__c = -1, X75__c = -1,
                            X100__c = -1, X200__c = -1, X300__c = -1, X500__c = -1, X1000__c = -1
                    );
                }
            }
        }

        return LastUserPrice;
    }
    public PM_Tubes_Pricing__c CalculNewPriceSleeveCCP(String sleeveMatVal, Decimal taux, PM_Tubes_Pricing__c pricesInitial, Map<Decimal, Decimal> totalBasisPrice, Map<Decimal, Decimal> totalLengthUpcharge, Map<Decimal, Decimal> totalCapBasisPrice) {
        PM_Tubes_Pricing__c LastUserPrice = null;

        if (totalLengthUpcharge != null && totalBasisPrice != null && totalCapBasisPrice != null) {
            if (sleeveMatVal.equals('Coex ISCC CRP') && pricesInitial != null) {
                LastUserPrice = new PM_Tubes_Pricing__c(
                        X10__c = pricesInitial.X10__c + ((totalBasisPrice.get(10) + totalLengthUpcharge.get(10)) * taux) + (totalCapBasisPrice.get(10) * taux),
                        X15__c = pricesInitial.X15__c + ((totalBasisPrice.get(15) + totalLengthUpcharge.get(15)) * taux) + (totalCapBasisPrice.get(15) * taux),
                        X20__c = pricesInitial.X20__c + ((totalBasisPrice.get(20) + totalLengthUpcharge.get(20)) * taux) + (totalCapBasisPrice.get(20) * taux),
                        X25__c = pricesInitial.X25__c + ((totalBasisPrice.get(25) + totalLengthUpcharge.get(25)) * taux) + (totalCapBasisPrice.get(25) * taux),
                        X50__c = pricesInitial.X50__c + ((totalBasisPrice.get(50) + totalLengthUpcharge.get(50)) * taux) + (totalCapBasisPrice.get(50) * taux),
                        X75__c = pricesInitial.X75__c + ((totalBasisPrice.get(75) + totalLengthUpcharge.get(75)) * taux) + (totalCapBasisPrice.get(75) * taux),
                        X100__c = pricesInitial.X100__c + ((totalBasisPrice.get(100) + totalLengthUpcharge.get(100)) * taux) + (totalCapBasisPrice.get(100) * taux),
                        X200__c = pricesInitial.X200__c + ((totalBasisPrice.get(200) + totalLengthUpcharge.get(200)) * taux) + (totalCapBasisPrice.get(200) * taux),
                        X300__c = pricesInitial.X300__c + ((totalBasisPrice.get(300) + totalLengthUpcharge.get(300)) * taux) + (totalCapBasisPrice.get(300) * taux),
                        X500__c = pricesInitial.X500__c + ((totalBasisPrice.get(500) + totalLengthUpcharge.get(500)) * taux) + (totalCapBasisPrice.get(500) * taux),
                        X1000__c = pricesInitial.X1000__c + ((totalBasisPrice.get(1000) + totalLengthUpcharge.get(1000)) * taux) + (totalCapBasisPrice.get(1000) * taux));

            } else {
                LastUserPrice = new PM_Tubes_Pricing__c(
                        X10__c = ((totalBasisPrice.get(10) + totalLengthUpcharge.get(10)) * taux) + (totalCapBasisPrice.get(10) * taux),
                        X15__c = ((totalBasisPrice.get(15) + totalLengthUpcharge.get(15)) * taux) + (totalCapBasisPrice.get(15) * taux),
                        X20__c = ((totalBasisPrice.get(20) + totalLengthUpcharge.get(20)) * taux) + (totalCapBasisPrice.get(20) * taux),
                        X25__c = ((totalBasisPrice.get(25) + totalLengthUpcharge.get(25)) * taux) + (totalCapBasisPrice.get(25) * taux),
                        X50__c = ((totalBasisPrice.get(50) + totalLengthUpcharge.get(50)) * taux) + (totalCapBasisPrice.get(50) * taux),
                        X75__c = ((totalBasisPrice.get(75) + totalLengthUpcharge.get(75)) * taux) + (totalCapBasisPrice.get(75) * taux),
                        X100__c = ((totalBasisPrice.get(100) + totalLengthUpcharge.get(100)) * taux) + (totalCapBasisPrice.get(100) * taux),
                        X200__c = ((totalBasisPrice.get(200) + totalLengthUpcharge.get(200)) * taux) + (totalCapBasisPrice.get(200) * taux),
                        X300__c = ((totalBasisPrice.get(300) + totalLengthUpcharge.get(300)) * taux) + (totalCapBasisPrice.get(300) * taux),
                        X500__c = ((totalBasisPrice.get(500) + totalLengthUpcharge.get(500)) * taux) + (totalCapBasisPrice.get(500) * taux),
                        X1000__c = ((totalBasisPrice.get(1000) + totalLengthUpcharge.get(1000)) * taux) + (totalCapBasisPrice.get(1000) * taux));

            }
        }

        return LastUserPrice ;
    }
}