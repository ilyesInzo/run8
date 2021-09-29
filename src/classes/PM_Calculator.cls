public with sharing class PM_Calculator {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   20-FEB-2017  Gulshan             Initial version
   01-MAR-2017  Hasseeb             Bug Fixing and Changes
 *****************************************************************************/
    /* sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String SLEEVE = 'Sleeve';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';
    public static final String OTHERS = 'Others';

    // SUB-SECTIONS
    public static final String BASIS_PRICE = 'Basis Price';
    public static final String LEN_UPCHARGE = 'Length upcharge';
    public static final String HEAD_ASPECT = 'Head Aspect';
    public static final String HEAD_COLORATION= 'Head Coloration';
    public static final String PEEL_SEAL = 'Peel Seal';
    public static final String SLEEVE_MATERIAL = 'Sleeve Material';
    public static final String MATERIAL_MIX = 'Material Mix';
    public static final String SLEEVE_ASPECT = 'Sleeve Aspect';
    public static final String SLEEVE_COLORATION = 'Sleeve Coloration';
    public static final String SLEEVE_FINISH = 'Sleeve Finish';
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_COLORATION = 'Cap Coloration';
    public static final String CAP_METALISATION = 'Cap Metalisation';
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

    public static final String OFFSET  = 'Offset';
    public static final String FLEXO  = 'Flexo';
    public static final String SILKSCREEN = 'Silkscreen';
    public static final String FLEXO_SS  = 'Flexo + Silkscreen';
    public static final String OFFSET_SS  = 'Offset + Silkscreen';
    public static final String UNPRINTED = 'Unprinted';

    public static final String SILK_SCREEN = 'Silk Screen';

    public static final String MONO = 'Mono';
    public static final String NON_STD_MIX = 'NON STANDARD MIX';

    public static final String STANDARD_COLOR = 'Standard color';
    public static final String DARK_COLOR = 'Dark color';

    public static final String METALLIZATION = 'Metallization';
    public static final String DELIVERED = 'Delivered';
    

    public static final String PLASTIC = 'Plastic';
    public static final Decimal DEFAULT_PLATTS = 1100;
    //public static final String[] listMOQs = new List <String>{'X10__c', 'X15__c', 'X20__c', 'X25__c', 'X50__c', 'X75__c', 'X100__c', 'X200__c', 'X300__c', 'X500__c'};
    public static final Decimal[] listMinMOQ = new List <Decimal>{10, 15, 20, 25, 50, 75, 100, 200, 300, 500};

    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public String groupe;
    public Decimal dLength = 0;

    public static Boolean bHasRunned = false;*/

    /*public PM_Calculator(PM_Selected_Tubes_Config__c config) {
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
            dLength = config.Specific_length_mm__c > 0 ? config.Specific_length_mm__c : config.Sleeve_length_mm__c;
            Decimal version = getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);

            mapPMTubesPricing = getPMTubesPricing(config.Location__c, version);
            
            
            
            
        }
        
    }*/

    /*public static Map <String, PM_Tubes_Pricing__c> getPMTubesPricing(String location, Decimal version){

        Map <String, PM_Tubes_Pricing__c> mapTubePricing = new Map <String, PM_Tubes_Pricing__c>(); 
        for(PM_Tubes_Pricing__c oPricing : [select X10__c, X15__c, X20__c, X25__c, X50__c, 
                                                    X75__c, X100__c, X200__c, X300__c, X500__c,
                                                    Version__c, Ref__c
                                            from PM_Tubes_Pricing__c
                                            where Version__c = :version
                                            and Location__c = :location]){
            mapTubePricing.put(oPricing.Ref__c, oPricing);
        }
        return mapTubePricing;
    }*/

    /*public static Decimal getPMPricingVersion(String location, String productLine, String productSegment){
        for(PM_pricing_Version__mdt version : [select Version_number__c
                                                from PM_pricing_Version__mdt
                                                where Location__c = :location
                                                and Product_line__c = :productLine
                                                and Product_Segment__c = :productSegment
                                                limit 1]){
            return version.Version_number__c;
        }
        return 1;
    }*/

    /*public void findGroup(){
        System.debug('## Head Name : ' + config.Head_Name__c);
        System.debug('## Diameter_mm__c : ' + config.Diameter_mm__c);
        if(config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c)){
            String groupe1 = config.Diameter_mm__c + '_' + config.Head_Name__c;
            System.debug('## groupe1 : ' + groupe1);
            for(PM_Tubes_Config__c g : [select GROUPES_1__c, GROUPES_2__c 
                                        from PM_Tubes_Config__c 
                                        where GROUPES_1__c = :groupe1
                                        limit 1]){
                groupe = String.valueOf(g.GROUPES_2__c);
                System.debug('## Group : ' + groupe);
            }
        }
    }*/

    /*public void calculate(){
        System.debug('## PM_Calculator : calculate()');

        //Hm 0103 - Need to delete the previous one first. On the safe way.
        //List<PM_Price_Detail__c> oldPMDetails = [select id from PM_Price_Detail__c where PM_Selected_Tubes_Config__c = :config.Id];
        //delete oldPMDetails;       
        
        findGroup();
 
        if(String.isBlank(groupe)) return;

        // Basis Price
        if(config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c) && String.isNotBlank(groupe)){
            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c + '1-01';
            System.debug('## ref : ' + ref);
            
            PM_Tubes_Pricing__c tp = mapPMTubesPricing.get(ref);
            System.debug(tp);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), TUBE_HEAD, BASIS_PRICE));

        }else{
            // 0
        }

        // Upcharge Length
        calcLengthUpchargeEU();

        // Peel Seal
        calcPeelSealEU();
        
        // Head Aspect
        listDetailsToUpsert.addAll(getDetails(config, null, TUBE_HEAD, HEAD_ASPECT));

        // Head Coloration
        if(config.Head_Aspect__c != config.Sleeve_Aspect__c ){ //HM Removed && config.Head_Color__c != WHITE_NATURAL
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            if(config.Head_Aspect__c == PEARL){
                ref += '5-03';
            } else{
                
            //  Mapping of the Head Color to Ref
            //    Transparent 
            //   Opaque  
            //    Pearl               5-03
            //    White / Natural 
            //    Standard color      5-01
            //    Dark color          5-02              
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
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), TUBE_HEAD, HEAD_COLORATION));
        }
        
        // Cap Basis Price
        //if(String.isNotBlank(config.Cap_Eurocode__c) && config.Cap_Eurocode__c != '0' && config.Cap_Eurocode__c != 'NO'){
        //HM 2802 - Added check for 0 or NO Cap EuroCode
        if(String.isNotBlank(config.Cap_Eurocode__c) 
            && config.Cap_Eurocode__c != '0' 
            && config.Cap_Eurocode__c != 'NO'
            && String.isNotBlank(config.Head_Name__c)){
            
            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c 
                + config.Cap_Eurocode__c + WHITE.toUpperCase();
            
            System.debug('## Cap Basis Price : ' + ref);
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), CAP, CAP_BASIS_PRICE));

            // Cap Coloration 
            String refCol = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c;
            if(config.Cap_Aspect__c == PEARL || config.Cap_Color__c == STANDARD_COLOR || config.Cap_Color__c == DARK_COLOR){
                refCol += COLORED.toUpperCase();
            }else{
                refCol += WHITE.toUpperCase();
            }

            System.debug('## Cap Coloration : ' + refCol);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(refCol), CAP, CAP_COLORATION));
        }

        // Metallization
       // if(config.Metallization__c == NO || config.Metallization__c != '0'){
        if(config.Metallization__c == YES ){
        	String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + METALLIZATION + config.Metallization_Type__c;
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), CAP, CAP_METALISATION));
        }

        // Silk-Screening
        if(config.Silk_screen__c == YES){
            calcDecoPrice(SILK_SCREEN, SILK_SCREENING);
        }

        // Hot Stamp Top
        if(config.Hot_Stamp_Top__c == YES){
            calcDecoPrice('TOP HS', HOT_STAMP_TOP);
        }

        // HS Contouring
        if(config.HS_Contouring__c == YES){
            calcDecoPrice('360° HS', HS_CONTOURING);
        }

        // Shrink Band
        if(config.Shrink_band__c == YES){
            calcDecoPrice('Sleeve', SHRINK_BAND);
        }

        // Manual Capping
        if(config.Manual_Capping__c == YES){
            calcDecoPrice('Manual capping', MANUAL_CAPPING);
        }
        
        // Sleeve Material
        System.debug('## config.Sleeve_Material__c : ' + config.Sleeve_Material__c);
        if(config.Sleeve_Material__c != MONO){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            //+ '4-02';
            //HM 2802 - Added lookup to Liste Codes
            for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                        from PM_Tubes_Config__c
                                        where Sleeve_type__c = :config.Sleeve_Material__c
                                        and Table_name__c = 'Sleeve type codes'
                                        and Location__c = :config.Location__c
                                        limit 1]){                  
                 ref += pm.Plastic_Code__c;                                                                      
            }            
            
            
            System.debug('## Sleeve Material : ' + ref);
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), SLEEVE, SLEEVE_MATERIAL));
        }

        // Material Mix
        // TODO HM2802 - Add Basis Price * 0.02, if Material Mix = "PCR"
        if(config.Sleeve_Material_Mix__c == NON_STD_MIX){
            
            //HM 2802 - Added for PCR price..Need to get the basis price
            if (config.Sleeve_Material_Mix__c == 'PCR') {
                listDetailsToUpsert.addAll(getDetails(config, null, SLEEVE, MATERIAL_MIX));                                
            } else {
                String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '4-01';
                listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), SLEEVE, MATERIAL_MIX));                
            }
        }

        // Sleeve Aspect
        listDetailsToUpsert.addAll(getDetails(config, null, SLEEVE, SLEEVE_ASPECT));

        // Sleeve Coloration
        calcSleeveColoration();

        // Sleeve Finish
        listDetailsToUpsert.addAll(getDetails(config, null, SLEEVE, SLEEVE_FINISH));



        // Printing Type
        if(String.isNotBlank(config.Printing_type__c) || config.Printing_type__c != UNPRINTED){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            String tg = getPrintingTG(config.Printing_technologies__c, config.NB_Offset_Colors__c, config.NB_Flexo_Colors__c, config.NB_SS_Colors__c);
            System.debug('## Printing TG : ' + tg);

            // get Code tarification
            for(PM_Tubes_Config__c pm : [select Code_TG__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Printing_TG__c = :tg
                                            and Table_name__c = 'Printing Technology'
                                            limit 1]){
                ref += pm.Code_TG__c;
            }

            System.debug('## Printing Type : ' + ref);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), PRINTING, PRINTING_TYPE)); 
        }

        // Other Printing Effects
        if(String.isNotBlank(config.Printing_Effects__c)){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            
            for(PM_Tubes_Config__c pm : [select Code_printing_effect__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Printing_Effects__c = :config.Printing_Effects__c
                                            and Table_name__c = 'Printing Effects'
                                            limit 1]){
                ref += pm.Code_printing_effect__c;
            }

            System.debug('## Other Printing Effects : ' + ref);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), PRINTING, OTHER_PRINT_EFFECT)); 

        }

        // Sleeve Hot Stamping
        if(String.isNotBlank(config.Deco_Hot_Stamping__c)){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;

            for(PM_Tubes_Config__c pm : [select Code_hot_stamping__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Hot_Stamping__c = :config.Deco_Hot_Stamping__c
                                            and Table_name__c = 'Hot Stamping'
                                            limit 1]){
                ref += pm.Code_hot_stamping__c;
            }

            System.debug('## Sleeve Hot Stamping : ' + ref);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), PRINTING, SLEEVE_HOT_STAMP)); 
        }

        // Combo
        if(config.Combo_Num_Versions__c > 1 
            && config.Combo_Num_Tubes_Artwork__c > 0 
            && config.Combo_Num_Plate_Changes__c > 0){

            List <PM_Price_Detail__c> details = getDetails(config, null, OTHERS, COMBO);

            for(Integer i = 0 ; i < listMinMOQ.size() ; i++){
                //Decimal moq = listMinMOQ[i];
                Integer moq = listMinMOQ[i].intValue();
                Decimal a = Math.max((moq * 1000 / config.Combo_Num_Tubes_Artwork__c.intValue()),1);
                Decimal b = Math.min(config.Combo_Num_Versions__c, a) - 1;
                
                //HM 2802 - Check customer Country if germany, multily by 180 instead of 280
                Integer costPerChangeOfPrintingPlates = 280;
                if(qli != null && qli.Customer_Country__c == 'Germany'){
                    costPerChangeOfPrintingPlates = 180;
                } 
                details[i].List_Price__c = (b * config.Combo_Num_Plate_Changes__c * costPerChangeOfPrintingPlates) / moq;
            }
            System.debug('## Combo : ' + details);
            listDetailsToUpsert.addAll(details);
        }

        // Platt's
        system.debug('Calculating Platts');
        if(config.Diameter_mm__c > 0 && dLength > 0 && config.Nouveau_Platts__c > 0){
            for(PM_Tubes_Config__c pm : [select Platts_Poids_Jupe_nets__c, Platts_Poids_tete__c, Platts_bouchon__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Diameter_mm__c = :config.Diameter_mm__c
                                            and Table_name__c = 'Platts'
                                            limit 1]){
                system.debug(pm);                               
                //Decimal a = (pm.Platts_Poids_Jupe_nets__c/100) * dLength * 1.25;
                //Decimal b = pm.Platts_Poids_tete__c * 1.25;
                //Decimal c = pm.Platts_bouchon__c * 1.05;
                //Decimal dPlatts = ((a + b + c) * (config.Nouveau_Platts__c - DEFAULT_PLATTS)) / 1000;

                                                
                //HM 0103/ Correct calculation  
                Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                Decimal poidJupeEtTete = ((pm.Platts_Poids_Jupe_nets__c/100) 
                             * dLength + pm.Platts_Poids_tete__c) * 1.25 * plattsDif;                                
                Decimal poidBouchon = pm.Platts_bouchon__c * 1.05 * plattsDif;
                Decimal dPlatts = poidJupeEtTete + poidBouchon;                                                
                listDetailsToUpsert.addAll(setListPrice(getDetails(config, null, OTHERS, PLATTS), dPlatts));
            }
        }
        
        // Payment Terms
        System.debug('Payment TERMS START ');
        if(String.isNotBlank(config.Payment_terms__c)){
            for(PM_Tubes_Config__c tc : [select Weight_value__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Payment Terms' 
                                            and Location__c = :config.Location__c
                                            and Payment_Terms__c = :config.Payment_terms__c
                                            limit 1]){
                calcOthers(new Set <String> {STOCKAGE, EOY_REBATE, SKONTO}, (tc.Weight_value__c / 100), PAYMENT_TERMS);
            }
        } 
        System.debug('Payment TERMS END ');

        // End of Year Rebate
        if(qli != null && String.isNotBlank(qli.Customer_end_of_year_rebate__c)){
            Decimal dPercent = 0;
            // TODO : query percent - RECO - Backup N19:R20
            if(qli.Customer_end_of_year_rebate__c == 'Yes (3% or more)'){
                dPercent = 0.03;
            }else if(qli.Customer_end_of_year_rebate__c == 'Yes (2%)'){
                dPercent = 0.02;
            }else if(qli.Customer_end_of_year_rebate__c == 'Yes (1%)'){
                dPercent = 0.01;
            }
            calcOthers(new Set <String> {SKONTO}, dPercent, EOY_REBATE);
        }

        // Skonto
        if(qli != null && qli.Customer_Country__c == 'Germany'){
            // TODO : query percent - RECO - Backup 
            Decimal dPercent = 0;
            if(qli.DS_Skonto_for_cash_payment__c == null){
                dPercent = 0;
            }
            else if(qli.DS_Skonto_for_cash_payment__c.contains('3')){
                dPercent = 0.03;
            }else if(qli.DS_Skonto_for_cash_payment__c.contains('2')){
                dPercent = 0.02;
            }else if(qli.DS_Skonto_for_cash_payment__c.contains('1')){
                dPercent = 0.01;
            }
            calcOthers(new Set <String> {EOY_REBATE}, dPercent, SKONTO);
        }

        // Stockage
        if(String.isNotBlank(config.Payment_terms__c)){
            for(PM_Tubes_Config__c tc : [select Weight_value__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Stockage' 
                                            and Location__c = :config.Location__c
                                            and Stockage__c = :config.Stockage__c
                                            limit 1]){
                calcOthers(new Set <String> {PAYMENT_TERMS, EOY_REBATE, SKONTO}, (tc.Weight_value__c / 100), STOCKAGE);
            }
        } 

        // Freight Price
        if(config.Delivery__c == DELIVERED){
            // config.Destination__c
            String ref = config.Diameter_mm__c + TG1;
            for(PM_Tubes_Config__c tc : [select Plastic_Code__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Delivery-Destination-Plastic Code' 
                                            and Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Destination__c = :config.Destination__c
                                            limit 1]){
                ref += tc.Plastic_Code__c;

            }
            System.debug('## Freight Price : ' + ref);
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), OTHERS, FREIGHT_PRICE));
        }

        // PE Bag
        if(config.PE_Bag__c == YES){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '13-02';
            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), OTHERS, PE_BAG));
        }


        System.debug('## listDetailsToUpsert : ' + listDetailsToUpsert.size());

        if(listDetailsToUpsert.size() > 0){
            upsert listDetailsToUpsert ExtId__c;
        }

        //-- TOTAL --//
        List<PM_Price_Detail__c> prices = null;
     //   if (tubeId != null && tubeId != '') {
        prices = [Select id, Name, Section__c, MOQ_Min__c, Price__c,MOQ_Max__c,List_Price__c
                  from PM_Price_Detail__c 
                  where PM_Selected_Tubes_Config__c = :config.Id order by MOQ_Min__c desc];            
        //  } else {
        //    prices = [Select id, Name, Section__c, MOQ_Min__c, Price__c
        //            from PM_Price_Detail__c 
        //            where PM_Selected_Dipsensing_Config__c = :dispensingId order by MOQ_Min__c desc];
        //}
        Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = new Map <Decimal, PM_MOQ_price__c>();

        for(PM_Price_Detail__c pm : prices){
            if(mapPMMOQPrice.containsKey(pm.MOQ_Min__c)){
                if(pm.List_Price__c == -1){
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = pm.Price__c;
                }else if(mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1){
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c += pm.Price__c;
                }
            }else{
                PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                    MOQ_Min__c = pm.MOQ_Min__c,
                    MOQ_Max__c = pm.MOQ_Max__c,
                    PM_Selected_Tubes_Config__c = config.Id,
                    Quote_item__c = config.Quote_item__c,
                    List_Price__c = pm.Price__c,
                    ExtId__c = pm.MOQ_Min__c + '-' + config.Id
                );
                mapPMMOQPrice.put(pm.MOQ_Min__c, pmMOQ);
            }
        }

        System.debug('## mapPMMOQPrice : ' + mapPMMOQPrice);
        if(mapPMMOQPrice.size() > 0){
            upsert mapPMMOQPrice.values() ExtId__c;
        }
    }*/

    /*public void calcOthers(Set <String> setLinesToSkip, Decimal dPercent, String sLine){
        Map <Decimal, PM_Price_Detail__c> mapPaymentTerms = new Map <Decimal, PM_Price_Detail__c>();

        for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(!setLinesToSkip.contains(pm.Name)){
                System.debug(pm.Name + ' : ' + pm.List_Price__c);
                Decimal listPrice = pm.List_Price__c * dPercent;

                if(mapPaymentTerms.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1){
                        mapPaymentTerms.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    }else if(mapPaymentTerms.get(pm.MOQ_Min__c).List_Price__c != -1){
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

        if(mapPaymentTerms.size() > 0){
            listDetailsToUpsert.addAll(mapPaymentTerms.values());
        }
    }*/

    /*public void calcDecoPrice(String capFeatureType, String line){
        for(PM_Tubes_Config__c pm : [select Cap_feature_price__c
                                        from PM_Tubes_Config__c
                                        where Diameter_mm__c = :config.Diameter_mm__c
                                        and Cap_feature_type__c = :capFeatureType
                                        and Cap_feature_price__c != null
                                        and Table_name__c = 'PRIX DECO / CAP FEATURE'
                                        and Location__c = :config.Location__c
                                        and Tubes_segment__c = :PLASTIC
                                        limit 1]){
            System.debug('## Silk-Screening : ' + pm.Cap_feature_price__c);
            listDetailsToUpsert.addAll(setListPrice(getDetails(config, null, CAP, line), pm.Cap_feature_price__c));    
        }
    }*/

    /*public void calcPeelSealEU(){
        if(config.Peel_Seal__c == YES){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            
            //HM 2802 - Retrieve the Code Peel Seal from Priting technology
            for(PM_Tubes_Config__c pm : [select code_peel_seal__c
                                        from PM_Tubes_Config__c
                                        where Printing_TG__c = :config.Printing_technologies__c
                                        and Table_name__c = 'Printing Technology'
                                        and Location__c = :config.Location__c
                                        limit 1]){                  
                 ref += pm.code_peel_seal__c;                                                                      
            }
                                            
            //if(String.isNotBlank(config.Printing_technologies__c) 
            //   && config.Printing_technologies__c.contains(SILKSCREEN)){
            //    ref += '10-02';
            //}else{
            //    ref += '10-01';
            //}

            System.debug('## Peel Seal : ' + ref);

            listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), TUBE_HEAD, PEEL_SEAL));
        }else{
            listDetailsToUpsert.addAll(getDetails(config, null, TUBE_HEAD, PEEL_SEAL));
        }
    }*/

    /*public void calcSleeveColoration(){
        String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
        if(config.Sleeve_Aspect__c == PEARL){
            for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Aspect__c = :config.Sleeve_Aspect__c
                                            and Table_name__c = 'Sleeve / Head / Cap aspect code'
                                            limit 1]){
                ref += pm.Plastic_Code__c;
            }
        }else{
            for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Color__c = :config.Sleeve_Color__c
                                            and Table_name__c = 'Sleeve / Head / Cap Color code'
                                            limit 1]){
                ref += pm.Plastic_Code__c;
            }
        }
        System.debug('## Sleeve Coloration : ' + ref);
        listDetailsToUpsert.addAll(getDetails(config, mapPMTubesPricing.get(ref), TUBE_HEAD, SLEEVE_COLORATION));
    }*/

    /*public void calcLengthUpchargeEU(){
        if(config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c) && String.isNotBlank(groupe)){
            //Code length - N3
            String ref1 = groupe + config.Diameter_mm__c + TG1 + STANDARD + '3-01';
            String ref2 = '';
            
             //Code extra Length - P3
            if(config.Diameter_mm__c < 22 && dLength > 60){
                ref2 = groupe + config.Diameter_mm__c + TG1 + STANDARD + '3-02';
            }
            
            system.debug('LENGTH UPCHARGE REF1='+ref1);
            system.debug('LENGTH UPCHARGE REF2='+ref2);
            
            // HM 28/02 - Get the standard length for the sleeve length
            Decimal stdLengthForDiameter = 0;
            for(PM_Tubes_Config__c pm : [select STD_LENGTH__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Diameter_mm__c  = :config.Diameter_mm__c
                                            and Table_name__c = 'Standard Length'
                                            limit 1]) {     
                              
                stdLengthForDiameter = Decimal.valueOf(pm.STD_LENGTH__c);
            } 
            
            Decimal coeff = dLength > 0 ? (dLength - stdLengthForDiameter) / 5 : 0 ;
            system.debug('stdLengthForDiameter=' + stdLengthForDiameter 
                         + ';dLength='+ dLength 
                         + ';coeff='+coeff);
            
            List <PM_Price_Detail__c> details;

            // ref1
            if(mapPMTubesPricing.containsKey(ref1)){
                details = getDetails(config, mapPMTubesPricing.get(ref1), TUBE_HEAD, LEN_UPCHARGE);

                for(PM_Price_Detail__c detail : details){
                    detail.List_Price__c = detail.List_Price__c * coeff;
                }
            }
            system.debug(details);

            //HM 2802 - Get the possible length
            Integer countPossibleLength = 0;
            String specificLength = ''+config.Specific_length_mm__c;
            List<PM_Tubes_Config__c> pms = [select id
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c 
                                            and Table_name__c = 'POSSIBLE LENGTH'
                                            and Diameter_mm__c  = :config.Diameter_mm__c
                                            AND STD_LENGTH__c =:specificLength];                
           countPossibleLength = pms.size();
                         
            
            // TODO Complete calculation addUpNonStdSize - Error prone...
            //if(config.Specific_length_mm__c > 0 
            //    && config.Specific_length_mm__c != config.Sleeve_length_mm__c &&
            //    countPossibleLength != 1 /*&& couple Diamètre / Specific length non présent dans la table PLASTIC POSSIBLE LENGTH/
            //    ){
            //
            //    for(PM_Price_Detail__c detail : details){
            //        detail.List_Price__c += config.Diameter_mm__c < 30 ? 6 : 10;
            //    }
            //}

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
                for(PM_Price_Detail__c detail : details){
                    detail.List_Price__c += config.Diameter_mm__c < 30 ? 6 : 10;
                }   
            }
            
            // ref2
            if(mapPMTubesPricing.containsKey(ref2) && details != null){
                List <PM_Price_Detail__c> details2 = getDetails(config, mapPMTubesPricing.get(ref2), TUBE_HEAD, LEN_UPCHARGE);

                for(Integer i = 0 ; i < details.size() ; i++){
                    details[i].List_Price__c = details[i].List_Price__c + details2[i].List_Price__c;
                }
            }

            if(details != null){
                listDetailsToUpsert.addAll(details);
            }
        }
    }*/

    // sets the same ListPrice on all detail records
    /*public static List <PM_Price_Detail__c> setListPrice(List <PM_Price_Detail__c> details, Decimal listPrice){
        for(PM_Price_Detail__c detail : details){
            detail.List_Price__c = listPrice;
        }
        return details;
    }*/

    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    /*public static List <PM_Price_Detail__c> getDetails(PM_Selected_Tubes_Config__c config, PM_Tubes_Pricing__c tp, String section, String name){
        List <PM_Price_Detail__c> listDetails;
        if(tp == null){
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = 0)
            };
        }else{
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = tp.X10__c),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = tp.X15__c),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = tp.X20__c),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = tp.X25__c),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = tp.X50__c),
                new PM_Price_Detail__c(MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = tp.X75__c),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = tp.X100__c),
                new PM_Price_Detail__c(MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = tp.X200__c),
                new PM_Price_Detail__c(MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = tp.X300__c),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = tp.X500__c)
            };
        }

        for(PM_Price_Detail__c detail : listDetails){
            detail.Name = name;
            detail.Section__c = section;
            detail.PM_Selected_Tubes_Config__c = config.Id;
            detail.Quote_item__c = config.Quote_item__c;
            detail.ExtId__c = config.Id + name + detail.MOQ_Min__c;
        }

        return listDetails;
    }*/

    /*public static String getPrintingTG(String tech, Decimal iOffset, Decimal iFlexo, Decimal iSilkscreen){
        if(tech == OFFSET){
            return OFFSET + ' ' + (iOffset > 6 ? '7' : iOffset > 3 ? '4-6' : '1-3');
        }else if(tech == FLEXO){
            return FLEXO + ' ' + (iFlexo > 6 ? '7-10' : '1-6');
        }else if(tech == SILKSCREEN){
            return SILKSCREEN + ' ' + (iSilkscreen > 3 ? '4-6' : '1-3');
        }else if(tech == FLEXO_SS){
            return iSilkscreen > 2 ? 'Flexo 1-3 + Silkscreen 3' : 'Flexo 1-4 + Silkscreen 1-2';
        }else if(tech == OFFSET_SS){
            if(iSilkscreen > 3){
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 4-6' : 'Offset 1-3 + Silkscreen 4-6';
            }else{
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 1-3' : 'Offset 1-3 + Silkscreen 1-3';
            }
        }
        return UNPRINTED;
    }*/
}