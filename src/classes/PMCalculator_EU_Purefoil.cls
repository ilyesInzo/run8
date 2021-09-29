public class PMCalculator_EU_Purefoil {

/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for EU Tube Purefoil
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   29-MAR-2017  Hasseeb             Initial version
 *****************************************************************************/ 
    
    //Fill in values between 1-100. The default is zero as in the excel sheet
    public static final Integer AERO_OPTIMIZATION_PERCENTAGE = 0;
    public static final Integer DAYS5_LEAD_TIME_PERCENTAGE = 0;
    
    
    // sections
    // sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String SLEEVE = 'Sleeve';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';
    public static final String OTHERS = 'Others';
        
    public static final String BASIS_PRICE = 'Basis Price';
    public static final String LENGTH_UPCHARGE = 'Length upcharge';
    public static final String HEAD_ASPECT = 'Head Aspect';
    public static final String HEAD_COLORATION = 'Head Coloration';
    public static final String PEAL_SEEL = 'Peal Seel';
    
    public static final String SLEEVE_TYPE = 'Sleeve Type';
    public static final String MATERIAL_MIX = 'Material Mix';
    public static final String SLEEVE_ASPECT = 'Sleeve Aspect';
    public static final String SLEEVE_COLORATION = 'Sleeve Coloration';
    public static final String SLEEVE_FINISH = 'Sleeve Finish';
    
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_COLORATION = 'Cap Coloration';
    public static final String METALISATION = 'Metalisation';
    public static final String SILK_SCREENING = 'Silk-Screening';
    public static final String HOT_STAMP_TOP = 'Hot Stamp Top';
    public static final String HS_CONTOURING = 'HS Contouring';
    public static final String SHRINK_BAND = 'Shrink Band';
    public static final String MANUAL_CAPPING = 'Manual Capping';
    
    public static final String PRINTING_TYPE = 'Printing Type';
    public static final String OTHER_PRINTING_EFFECT = 'Other Printing Effect';
    public static final String SLEEVE_HOT_STAMPING = 'Sleeve Hot Stamping';
    
    public static final String COMBO = 'Combo';
    public static final String PLATTS = 'Platt\'s';
    public static final String PAYMENT_TERMS = 'Payment Terms';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
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
    public static final String LACQUERING = 'Lacquering';
    
    public static final String DELIVERED = 'Delivered';
    public static final String DAP = 'DAP';
    
    public static final String PLASTIC = 'Plastic';
    public static final String PUREFOIL = 'Purefoil';

    
    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public String groupe;
    public Decimal dLength = 0;
    
    public static final Decimal DEFAULT_PLATTS = 1100;
    public static final Decimal[] listMinMOQ = new List <Decimal>{10, 15, 20, 25, 50, 75, 100, 200, 300, 500,1000};
    
    public static Boolean bHasRunned = false;
    List<PM_Price_Detail__c> tgPriceDetails = null;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_EU_Purefoil(PM_Selected_Tubes_Config__c  config) {
        
        log('PMCalculator_EU_Purefoil start....');
        if(!bHasRunned){
            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
            dLength = config.Specific_length_mm__c > 0 ? config.Specific_length_mm__c : config.Sleeve_length_mm__c;
            
            /*Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);
            log('VERSION='+version);
            log('LOCATION='+config.Location__c);

            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReferenceByProductSegment(config.Location__c, version, 'Purefoil');  */

            // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReference(config.Location__c, 'Purefoil', dt);
                           
        }
        
    }


    public void calculate() {
        resetAllPMPrice();
        findGroup();
        calculateBASIS_PRICE();
        calculateLENGTH_UPCHARGE();
        calculateHEAD_ASPECT();
        calculateHEAD_COLORATION();
        calculatePEAL_SEEL();
        calculateSLEEVE_TYPE();
        calculateMATERIAL_MIX();
        calculateSLEEVE_ASPECT();
        calculateSLEEVE_COLORATION();
        calculateSLEEVE_FINISH();
        calculateCAP_BASIS_PRICE();
        calculateCAP_COLORATION();
        calculateMETALISATION();
        calculateSILK_SCREENING();
        calculateHOT_STAMP_TOP();
        calculateHS_CONTOURING();
        calculateSHRINK_BAND();
        calculateMANUAL_CAPPING();
        calculatePRINTING_TYPE();
        calculateOTHER_PRINTING_EFFECT();
        calculateSLEEVE_HOT_STAMPING();
        calculateCOMBO();
        calculatePLATTS();
        calculatePAYMENT_TERMS();
        calculateEND_OF_YEAR_REBATE();
        calculateSKONTO();
        calculateSTOCKAGE();
        calculateFREIGHT_PRICE();
        calculatePE_BAG();
        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        
        PMCalculatorUtility.calculateTotalMOQPRice(config.Id, null,  config.Quote_item__c);
        // Added for Historisation
        if (mapPMTubesPricing.size()> 0) update mapPMTubesPricing.values();
    }
    
    public void calculateBASIS_PRICE() {
        log('***********calculateBASIS_PRICE ***********');  
        if(config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c) && String.isNotBlank(groupe)){
            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c + '1-01';
            System.debug('## ref : ' + ref);
            tgPriceDetails = getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, BASIS_PRICE);
            listDetailsToUpsert.addAll(tgPriceDetails);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+BASIS_PRICE);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = BASIS_PRICE;
            }
        }            
            
    }
    
    public void calculateLENGTH_UPCHARGE() {
        log('***********calculateLENGTH_UPCHARGE ***********');   
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
            
            System.debug('LENGTH UPCHARGE=' + ref1);
            // ref1
            if(mapPMTubesPricing.containsKey(ref1.toUppercase())){
                details = getLineDetails(config, mapPMTubesPricing.get(ref1.toUppercase()), TUBE_HEAD, LENGTH_UPCHARGE);

                for(PM_Price_Detail__c detail : details){
                    detail.List_Price__c = detail.List_Price__c * coeff;
                    //Hack to prevent displaying specific
                    if (detail.List_Price__c == -1) {
                        detail.List_Price__c = detail.List_Price__c + 0.00001;
                    }
                }
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref1.toUpperCase());
                if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+LENGTH_UPCHARGE);
                        listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref1.toUppercase())!= null){
                    mapPMTubesPricing.get(ref1.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref1.toUppercase()).Line_Name__c = LENGTH_UPCHARGE;
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
            System.debug('LENGTH UPCHARGE2 =' + ref2);
            if(mapPMTubesPricing.containsKey(ref2.toUppercase()) && details != null){
                List <PM_Price_Detail__c> details2 = getLineDetails(config, mapPMTubesPricing.get(ref2.toUppercase()), TUBE_HEAD, LENGTH_UPCHARGE);

                for(Integer i = 0 ; i < details.size() ; i++){
                    details[i].List_Price__c = details[i].List_Price__c + details2[i].List_Price__c;
                }
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref2.toUpperCase());
                if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+LENGTH_UPCHARGE+'_2');
                        listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref2.toUppercase())!= null){
                    mapPMTubesPricing.get(ref2.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref2.toUppercase()).Line_Name__c = LENGTH_UPCHARGE;
                }
            }

            if(details != null){
                listDetailsToUpsert.addAll(details);
            }
        }
    }

    
    public void calculateHEAD_ASPECT() {
        log('***********calculateHEAD_ASPECT ***********'); 
        //Set to zero as it has not been implemented on the excel sheet
        listDetailsToUpsert.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_ASPECT));
    }
    
    public void calculateHEAD_COLORATION() {
        log('***********calculateHEAD_COLORATION ***********');
        // Head Coloration
        if(config.Head_Aspect__c != config.Sleeve_Aspect__c ){ //HM Removed && config.Head_Color__c != WHITE_NATURAL
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            if(PEARL.equalsIgnoreCase(config.Head_Aspect__c)){
                ref += '5-03';
            } else{
                
            /*  Mapping of the Head Color to Ref
                Transparent 
                Opaque  
                Pearl               5-03
                White / Natural 
                Standard color      5-01
                Dark color          5-02   */             
                // TODO : Base on select on PM_Tubes Config
                //HM 2802 Added mapping of Head Color to Ref
                if ('Pearl'.equalsIgnoreCase(config.Head_Color__c)) {
                    ref += '5-03';
                } else if ('Standard color'.equalsIgnoreCase(config.Head_Color__c)) { 
                    ref += '5-01';
                } else if ('Dark color'.equalsIgnoreCase(config.Head_Color__c)) { 
                    ref += '5-02';
                } 
            }
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, HEAD_COLORATION));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+HEAD_COLORATION);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HEAD_COLORATION;
            }
        }        
    }
    
    public void calculatePEAL_SEEL() {
        log('***********calculatePEAL_SEEL ***********');   
        if (YES.equalsIgnoreCase(config.Peel_Seal__c)) {
            //Start Modif ref ticket 7005
            //roll back this modif
            String ref = config.Diameter_mm__c+config.Cap_Eurocode__c+'Peel seal ';
            if(String.isNotBlank(config.Printing_technologies__c) 
                     && 
               config.Printing_technologies__c.contains(SILKSCREEN)
              )    ref += 'Silkscreen printing';
            else   ref += 'Other printing technology';
            System.debug('## Peel Seal : '+ ref);

            //End Modif Peel Seal
            //comment this one
          /* String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            
            String printingTG = getPrintingTG(config.Printing_technologies__c, config.NB_Offset_Colors__c, config.NB_Flexo_Colors__c, config.NB_SS_Colors__c);
            system.debug(config.Printing_technologies__c + '=PrintingTG=' + printingTG);
            
            //HM 2802 - Retrieve the Code Peel Seal from Priting technology
            for(PM_Tubes_Config__c pm : [select code_peel_seal__c
                                        from PM_Tubes_Config__c
                                        where Printing_TG__c = :printingTG 
                                        and Table_name__c = 'Printing Technology'
                                        and Location__c = :config.Location__c
                                        and Tubes_segment__c = :PUREFOIL
                                        limit 1]){                  
                 ref += pm.code_peel_seal__c;                                                                      
            }
            System.debug('## Peel Seal : ' +  config.Printing_technologies__c +'='+ ref);*/

           // listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()) != null ? mapPMTubesPricing.get(ref.toUppercase()) : null, TUBE_HEAD, PEAL_SEEL));
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()) != null ? mapPMTubesPricing.get(ref.toUppercase()) : mapPMTubesPricing.get(PUREFOIL+'Peel Seal Specific'.toUppercase()) , TUBE_HEAD, PEAL_SEEL));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+PEAL_SEEL);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PEAL_SEEL;
            }
        }else{
            listDetailsToUpsert.addAll(getLineDetails(config, null, TUBE_HEAD, PEAL_SEEL));
        }        
    }

    
    public void calculateSLEEVE_TYPE() {
        log('***********calculateSLEEVE_TYPE ***********');   
        System.debug('## config.Sleeve_Material__c : ' + config.Sleeve_Material__c);
        if(config.Sleeve_Material__c != MONO){
            //=+IF(AV3<>"Mono",
            //$J$3&$G$3&"TG1"&"standard"&VLOOKUP($AV$3,'BACK UP - Plastic'!$HA$4:$HB$11,2,0),"")
            
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '4-06';
            //+ '4-02';
            //HM 2802 - Added lookup to Liste Codes - Purefoil we get the code 4-06 directly as in Excel
            /*for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                        from PM_Tubes_Config__c
                                        where Sleeve_type__c = :config.Sleeve_Material__c
                                        and Table_name__c = 'Sleeve type codes'
                                        and Location__c = :config.Location__c
                                        limit 1]){                  
                 ref += pm.Plastic_Code__c;                                                                      
            } */           
            
            
            System.debug('## Sleeve Material : ' + ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_TYPE));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+SLEEVE+
                                                                                  '_'+SLEEVE_TYPE);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_TYPE;
            }
        }         
        
    }
    
    public void calculateMATERIAL_MIX() {
        log('***********calculateMATERIAL_MIX ***********');   
        if(config.Sleeve_Material_Mix__c == NON_STD_MIX){
            
                String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '4-01';
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, MATERIAL_MIX));                
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+SLEEVE+
                                                                                  '_'+MATERIAL_MIX);
                        listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = MATERIAL_MIX;
                }
        }
        if (config.Sleeve_Material_Mix__c == 'PCR') {
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
        
        }
    
    }
    
    public void calculateSLEEVE_ASPECT() {
        log('***********calculateSLEEVE_ASPECT ***********');   
        listDetailsToUpsert.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_ASPECT));        
        
    }
    
    public void calculateSLEEVE_COLORATION() {
        log('***********calculateSLEEVE_COLORATION ***********');   
        String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
        if(config.Sleeve_Aspect__c == PEARL){
            for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PUREFOIL
                                            and Aspect__c = :config.Sleeve_Aspect__c
                                            and Table_name__c = 'Sleeve / Head / Cap aspect code'
                                            limit 1]){
                ref += pm.Plastic_Code__c;
            }
        }else{
            for(PM_Tubes_Config__c pm : [select Plastic_Code__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PUREFOIL
                                            and Color__c = :config.Sleeve_Color__c
                                            and Table_name__c = 'Sleeve / Head / Cap Color code'
                                            limit 1]){
                ref += pm.Plastic_Code__c;
            }
        }
        System.debug('## Sleeve Coloration : ' + ref);
        List<PM_Price_Detail__c> details =getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_COLORATION);
        system.debug(details);
        listDetailsToUpsert.addAll(details);
        // Added for Historisation
        // Create Junction Object
        PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
        if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+SLEEVE+
                                                                                  '_'+SLEEVE_COLORATION);
                        listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMTubesPricing.get(ref.toUppercase())!= null){
            mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
            mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_COLORATION;
        }
        
    }

    
    public void calculateSLEEVE_FINISH() {
        log('***********calculateSLEEVE_FINISH ***********');   
        listDetailsToUpsert.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_FINISH));   

    }
    
    public void calculateCAP_BASIS_PRICE() {
        log('***********calculateSKONTO ***********');   
        if(String.isNotBlank(config.Cap_Eurocode__c) 
            && config.Cap_Eurocode__c != '0' 
            && config.Cap_Eurocode__c != 'NO'
            && String.isNotBlank(config.Head_Name__c)){
            
            String ref = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c 
                + config.Cap_Eurocode__c + WHITE.toUpperCase();
            
            System.debug('## Cap Basis Price : ' + ref);
            List<PM_Price_Detail__c> capBasisPrices = getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_BASIS_PRICE);
            listDetailsToUpsert.addAll(capBasisPrices);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+CAP_BASIS_PRICE);
                            listPricingJunctionToUpsert.add(pj);
            }

            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_BASIS_PRICE;
            }

            // Cap Coloration 
            String refCol = groupe + config.Diameter_mm__c + TG1 + config.Head_Name__c + config.Cap_Eurocode__c;
            if(config.Cap_Aspect__c == PEARL || config.Cap_Color__c == STANDARD_COLOR || config.Cap_Color__c == DARK_COLOR){
                refCol += COLORED.toUpperCase();
            }else{
                refCol += WHITE.toUpperCase();
            }

            System.debug('## Cap Coloration : ' + refCol);
            log('***********calculateCAP_COLORATION ***********'); 
            List<PM_Price_Detail__c> capColorationPrices = getLineDetails(config, mapPMTubesPricing.get(refCol.toUpperCase()), CAP, CAP_COLORATION);
            Integer index = 0;
            for (PM_Price_Detail__c capColorationPrice :capColorationPrices) {
                if (capColorationPrice.List_Price__c != null) {
                    PM_Price_Detail__c capBasisPrice = capBasisPrices.get(index);
                    if (capBasisPrice != null && capBasisPrice.List_Price__c != null) {
                        if (capBasisPrice.List_Price__c  ==  0 || capBasisPrice.List_Price__c  ==  -1) {
                            capColorationPrice.List_Price__c = capBasisPrice.List_Price__c;
                        } else {
                            capColorationPrice.List_Price__c = capColorationPrice.List_Price__c - capBasisPrice.List_Price__c;
                            if (capColorationPrice.List_Price__c < 0) {
                                capColorationPrice.List_Price__c = -1;
                            }
                        }                        
                         
                    }
                }
                
                index++;
            }
            listDetailsToUpsert.addAll(capColorationPrices);
            // Added for Historisation
            // Create Junction Object
            dp = mapPMTubesPricing.get(refCol.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+CAP_COLORATION);
                            listPricingJunctionToUpsert.add(pj);
            }

            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_COLORATION;
            }
            
       }
        
        
        
    }
    
   public void calculateCAP_COLORATION() {
        log('***********calculateCAP_COLORATION *********** - Done in Cap Basis Price');   
    }
    
    public void calculateMETALISATION() {
        log('***********calculateMETALISATION ***********');
        //if(config.Metallization__c == NO || config.Metallization__c != '0'){
        if(config.Metallization__c == YES ){
            String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + METALLIZATION + config.Metallization_Type__c;
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, METALISATION));//added by maryem qada 
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, METALISATION);        
            //added by maryem qada ==> to set -1 if no price was found
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
        
            listDetailsToUpsert.addAll(prices);        
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+METALISATION);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = METALISATION;
            }
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, METALISATION));
        }     
        
         if(config.Lacquering__c == YES ){
            String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + LACQUERING + config.Lacquering_Type__c;
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, METALISATION));//added by maryem qada 
            List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, LACQUERING);        
            //added by maryem qada ==> to set -1 if no price was found
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
        
            listDetailsToUpsert.addAll(prices);        
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+LACQUERING);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = LACQUERING;
            }
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, METALISATION));
        }
        
    }
    
    public void calculateSILK_SCREENING() {
        log('***********calculateSILK_SCREENING ***********');   
        // Silk-Screening
        if(YES.equalsIgnoreCase(config.Silk_screen__c)){
            calcDecoPrice('Silk Screen', SILK_SCREENING);
        }            
    }
    
    public void calculateHOT_STAMP_TOP() {
        log('***********calculateHOT_STAMP_TOP ***********');   
        if(config.Hot_Stamp_Top__c == YES){
            calcDecoPrice('TOP HS', HOT_STAMP_TOP);            
        }
         
    }
    
    public void calculateHS_CONTOURING() {
        log('***********calculateHS_CONTOURING ***********');  
        if(config.HS_Contouring__c == YES){
            calcDecoPrice('360° HS', HS_CONTOURING);
        }        
        
    }
    
    public void calculateSHRINK_BAND() {
        log('***********calculateSHRINK_BAND ***********');  
        if(config.Shrink_band__c == YES){
            calcDecoPrice('Sleeve', SHRINK_BAND);
        }        
    }
    
    public void calculateMANUAL_CAPPING() {
        log('***********calculateMANUAL_CAPPING ***********');   
        if(config.Manual_Capping__c == YES){
            calcDecoPrice('Manual capping', MANUAL_CAPPING);
        }        
        
    }
    
    public void calculatePRINTING_TYPE() {
        log('***********calculatePRINTING_TYPE ***********');   
        // Printing Type
        if(String.isNotBlank(config.Printing_technologies__c) || config.Printing_technologies__c != UNPRINTED){
            System.debug('PRINTING TYPE CALCULATION...............');
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            String tg = getPrintingTG(config.Printing_technologies__c, config.NB_Offset_Colors__c, config.NB_Flexo_Colors__c, config.NB_SS_Colors__c);
           
            System.debug(config.Printing_technologies__c + '_'+ config.NB_Offset_Colors__c+ '_'+ config.NB_Flexo_Colors__c+ '_'+ config.NB_SS_Colors__c
                         + '## Printing TG : ' + tg);

            // get Code tarification
            for(PM_Tubes_Config__c pm : [select Code_TG__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PUREFOIL
                                            and Printing_TG__c = :tg
                                            and Table_name__c = 'Printing Technology'
                                            limit 1]){
                ref += pm.Code_TG__c;
            }

            System.debug('## Printing Type : ' + ref);

            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_TYPE)); 
           
           // modified by safa J to display specific if the config doesn't exist ------> ticket n°3072                        
            List<PM_Price_Detail__c> prices = getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_TYPE);
            system.debug('prices='+prices);
            for (PM_Price_Detail__c price : prices) {
                if (price.List_Price__c == 0) {
                    price.List_Price__c = -1;
                }
            }
            listDetailsToUpsert.addAll(prices);
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                      '_'+PRINTING_TYPE);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_TYPE;
            }
        }        
        
    }
    
    public void calculateOTHER_PRINTING_EFFECT() {
        log('***********calculateOTHER_PRINTING_EFFECT ***********');  
        // Other Printing Effects
        if(String.isNotBlank(config.Printing_Effects__c)){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;
            
            for(PM_Tubes_Config__c pm : [select Code_printing_effect__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PUREFOIL
                                            and Printing_Effects__c = :config.Printing_Effects__c
                                            and Table_name__c = 'Printing Effects'
                                            limit 1]){
                ref += pm.Code_printing_effect__c;
            }

            System.debug('## Other Printing Effects : ' + ref);

            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, OTHER_PRINTING_EFFECT)); 
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                      '_'+OTHER_PRINTING_EFFECT);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = OTHER_PRINTING_EFFECT;
            }
        }            
            
    }
    
    public void calculateSLEEVE_HOT_STAMPING() {
        log('***********calculateSLEEVE_HOT_STAMPING ***********'); 
        // Sleeve Hot Stamping
        if(String.isNotBlank(config.Deco_Hot_Stamping__c)){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD;

            for(PM_Tubes_Config__c pm : [select Code_hot_stamping__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PUREFOIL
                                            and Hot_Stamping__c = :config.Deco_Hot_Stamping__c
                                            and Table_name__c = 'Hot Stamping'
                                            limit 1]){
                ref += pm.Code_hot_stamping__c;
            }

            System.debug('## Sleeve Hot Stamping : ' + ref);

            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, SLEEVE_HOT_STAMPING)); 
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                      '_'+SLEEVE_HOT_STAMPING);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_HOT_STAMPING;
            }
        }        
    }
    
     public void calculateCOMBO() {
        log('***********calculateCOMBO ***********');  
        if(config.Combo_Num_Versions__c > 1 
            && config.Combo_Num_Tubes_Artwork__c > 0 
            && config.Combo_Num_Plate_Changes__c > 0){

            List <PM_Price_Detail__c> details = getLineDetails(config, null, OTHERS, COMBO);

            for(Integer i = 0 ; i < listMinMOQ.size() ; i++){
                //Decimal moq = listMinMOQ[i];
                Integer moq = listMinMOQ[i].intValue();
                Decimal a = Math.max((moq * 1000 / config.Combo_Num_Tubes_Artwork__c.intValue()),1);
                Decimal b = Math.min(config.Combo_Num_Versions__c, a) - 1;
                
                //HM 2802 - Check customer Country if germany, multily by 180 instead of 280
                Integer costPerChangeOfPrintingPlates = 280;
                if(qli != null 
                    && 
                    (qli.Customer_Country__c == 'Germany' 
                    ||  qli.Customer_Country__c == 'Austria' 
                    ||qli.Customer_Country__c == 'Switzerland'   ) ){
                    costPerChangeOfPrintingPlates = 180;
                } 
                details[i].List_Price__c = (b * config.Combo_Num_Plate_Changes__c * costPerChangeOfPrintingPlates) / moq;
            }
            System.debug('## Combo : ' + details);
            listDetailsToUpsert.addAll(details);
        }
         
         
    }
    
    public void calculatePLATTS() {
        log('***********calculatePLATTS ***********');  
        system.debug('Calculating Platts');
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
                                       
        if(config.Diameter_mm__c > 0 && dLength > 0 && config.Nouveau_Platts__c > 0){
            for(PM_Tubes_Config__c pm : [select Platts_Poids_Jupe_nets__c, Platts_Poids_tete__c, Platts_bouchon__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Tubes_segment__c = :PLASTIC
                                            and Diameter_mm__c = :config.Diameter_mm__c
                                            and Table_name__c = 'Platts'
                                            limit 1]){
                system.debug(pm);                               
               /* Decimal a = (pm.Platts_Poids_Jupe_nets__c/100) * dLength * 1.25;
                Decimal b = pm.Platts_Poids_tete__c * 1.25;
                Decimal c = pm.Platts_bouchon__c * 1.05;
                Decimal dPlatts = ((a + b + c) * (config.Nouveau_Platts__c - DEFAULT_PLATTS)) / 1000;
*/
                                                
                //HM 0103/ Correct calculation  
                Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                //Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                Decimal poidJupeEtTete = ((pm.Platts_Poids_Jupe_nets__c/100) 
                             * dLength + pm.Platts_Poids_tete__c) * 1.25 * plattsDif;                                
                Decimal poidBouchon = pm.Platts_bouchon__c * 1.05 * plattsDif;
                Decimal dPlatts = poidJupeEtTete + poidBouchon;                                                
               System.debug( 'DLENGHT=' + dLength + 'PLATTSDIF=' + plattsDif + '=poidJupeEtTete=' + poidJupeEtTete 
                            + '=poidBouchon=' + poidBouchon + '=dPlatts=' + dPlatts);                                 
                                                
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, OTHERS, PLATTS), dPlatts * currencyRate));
            }
        }
        
        
    }
    
   //modified for Ticket 6654
    public void calculatePAYMENT_TERMS() {
        log('***********calculatePAYMENT_TERMS ***********');   
        System.debug('Payment TERMS START ');
        if(String.isNotBlank(config.Payment_terms__c)){
            /*for(PM_Tubes_Config__c tc : [select Weight_value__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Payment Terms' 
                                            and Location__c = :config.Location__c
                                            and Payment_Terms__c = :config.Payment_terms__c
                                            limit 1]){
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', STOCKAGE, END_OF_YEAR_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, PAYMENT_TERMS));
                                            
            }*/
            String ref='PAYMENT'+ config.Payment_terms__c;
            //------Right values------- 
            
            listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', STOCKAGE, END_OF_YEAR_REBATE, SKONTO}, config,mapPMTubesPricing.get(ref.toUpperCase())!=null ? mapPMTubesPricing.get(ref.toUpperCase()).X10__c : 0, OTHERS, PAYMENT_TERMS));
        } 
        System.debug('Payment TERMS END ');


    }
    
    public void calculateEND_OF_YEAR_REBATE() {
        log('***********calculateEND_OF_YEAR_REBATE ***********');
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
            system.debug('END OF YEAR REBATE' +dPercent);
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', SKONTO}, config, dPercent, OTHERS, END_OF_YEAR_REBATE));

        }        
        
    }
    
    public void calculateSKONTO() {
        log('***********calculateSKONTO ***********');   
        // Skonto
        if(qli.DS_Skonto_for_cash_payment__c != null && qli.DS_Skonto_for_cash_payment__c != 'No'){
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', END_OF_YEAR_REBATE}, config,  PMCalculatorUtility.calculateSKONTO(qli.Customer_Country__c, qli.DS_Skonto_for_cash_payment__c), OTHERS, SKONTO));
        }
    }
    
     //updated ticket 6654
    public void calculateSTOCKAGE() {
        log('***********calculateSKONTO ***********');   
        // Stockage
       if(String.isNotBlank(config.Stockage__c)){
           /* for(PM_Tubes_Config__c tc : [select Weight_value__c
                                            from PM_Tubes_Config__c
                                            where Table_name__c = 'Stockage' 
                                            and Location__c = :config.Location__c
                                            and Stockage__c = :config.Stockage__c
                                            limit 1]){
                                                
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', PAYMENT_TERMS, END_OF_YEAR_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, STOCKAGE));
                                                
            }*/
         String ref='STOCKAGE'+ config.Stockage__c;          
        listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT', PAYMENT_TERMS, END_OF_YEAR_REBATE, SKONTO}, config,mapPMTubesPricing.get(ref.toUpperCase())!= null ? (mapPMTubesPricing.get(ref.toUpperCase())).X10__c : 0, OTHERS, STOCKAGE));
        }     
    }
    
    public void calculateFREIGHT_PRICE() {
        log('***********calculateSKONTO ***********');   
        if(config.Delivery__c == DAP){
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
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, FREIGHT_PRICE));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+OTHERS+
                                                                                      '_'+FREIGHT_PRICE);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = FREIGHT_PRICE;
            }
        }

    }
    
    public void calculatePE_BAG() {
        log('***********calculateSKONTO ***********');   
        if(config.PE_Bag__c == YES){
            String ref = groupe + config.Diameter_mm__c + TG1 + STANDARD + '13-02';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, PE_BAG));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+OTHERS+
                                                                                      '_'+PE_BAG);
                            listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PE_BAG;
            }
        }
    }
       
    
    public static String getPrintingTG(String tech, Decimal iOffset, Decimal iFlexo, Decimal iSilkscreen){
        String returnValue = UNPRINTED;
        if(tech == OFFSET){
            
            //return OFFSET + ' ' + (iOffset > 6 ? '7' : iOffset > 3 ? '4-6' : '1-3');
            //HM 30/04 - Corrected the Priting return
            
            if (iOffset > 0 && iOffset < 4) {
                returnValue = 'Offset 1-3';               
            } else if (iOffset > 3 && iOffset < 7) {
                returnValue = 'Offset 4-6';
            } else if (iOffset == 7) {
                returnValue = 'Offset 7';
            } 
            
        }else if(tech == FLEXO){
            //HM 30/04 - Corrected the Priting return
            if (iFlexo > 0 && iFlexo < 7) {
                returnValue = 'Flexo 1-6';               
            } else if (iFlexo > 6 && iFlexo < 11) {
                returnValue = 'Flexo 7-10';
            } 
            //return FLEXO + ' ' + (iFlexo > 6 ? '7-10' : '1-6');
            
        }else if(tech == SILKSCREEN){
            //HM 30/04 - Corrected the Priting return
            if (iSilkscreen > 0 && iSilkscreen < 4) {
                returnValue = 'Silkscreen 1-3';               
            } else if (iSilkscreen > 3 && iSilkscreen < 7) {
                returnValue = 'Silkscreen 4-6';
            } 
        }else if(tech == FLEXO_SS){
            //HM 13/03 - Corrected the Priting return
            if (iOffset > 0 && iOffset < 5 && iSilkscreen > 0 && iSilkscreen < 3) {
                returnValue = 'Flexo 1-4 + Silkscreen 1-2';
               
            } else if (iOffset > 0 && iOffset < 4 && iSilkscreen == 3) {
                returnValue = 'Flexo 1-3 + Silkscreen 3';
            } 
            
        }else if(tech == OFFSET_SS){
            if(iSilkscreen > 3){
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 4-6' : 'Offset 1-3 + Silkscreen 4-6';
            }else{
                return iOffset > 3 ? 'Offset 4-6 + Silkscreen 1-3' : 'Offset 1-3 + Silkscreen 1-3';
            }
        }
        return returnValue;
    }
    
    
     public void calcDecoPrice(String capFeatureType, String line){
       /* for(PM_Tubes_Config__c pm : [select Cap_feature_price__c
                                        from PM_Tubes_Config__c
                                        where Diameter_mm__c = :config.Diameter_mm__c
                                        and Cap_feature_type__c = :capFeatureType
                                        and Cap_feature_price__c != null
                                        and Table_name__c = 'PRIX DECO / CAP FEATURE'
                                        and Location__c = :config.Location__c
                                        and Tubes_segment__c = :PUREFOIL
                                        limit 1]){
            System.debug('## Silk-Screening : ' + pm.Cap_feature_price__c);
            // We set the currency rate to be 
            Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
                                            
            listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, CAP, line), pm.Cap_feature_price__c * currencyRate));    
        }*/
         String ref = capFeatureType + config.Diameter_mm__c;
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c; 
        listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, CAP, line), mapPMTubesPricing.get(ref.toUpperCase()) != null ? mapPMTubesPricing.get(ref.toUpperCase()).X10__c * currencyRate : 0));
      
    }
    

    public void findGroup(){
        System.debug('## Head Name : ' + config.Head_Name__c);
        System.debug('## Diameter_mm__c : ' + config.Diameter_mm__c);
        if(config.Diameter_mm__c > 0 && String.isNotBlank(config.Head_Name__c)){
            String groupe1 = config.Diameter_mm__c + '_' + config.Head_Name__c;
            System.debug('## groupe1 : ' + groupe1);
            for(PM_Tubes_Config__c g : [select GROUPES_1__c, GROUPES_2__c 
                                        from PM_Tubes_Config__c 
                                        where GROUPES_1__c = :groupe1
                                        and Tubes_segment__c = :PUREFOIL 
                                        limit 1]){
                groupe = String.valueOf(g.GROUPES_2__c);
                System.debug('## Group : ' + groupe);
            }
        }
    }    

    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();

        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, LENGTH_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_ASPECT));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, PEAL_SEEL));
        
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_TYPE));
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, MATERIAL_MIX));
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_ASPECT));
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_FINISH));
        
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, METALISATION));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, SILK_SCREENING));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, HOT_STAMP_TOP));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, HS_CONTOURING));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, SHRINK_BAND));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, MANUAL_CAPPING));
        
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, PRINTING_TYPE));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, OTHER_PRINTING_EFFECT));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, SLEEVE_HOT_STAMPING));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, COMBO));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, PLATTS));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, PAYMENT_TERMS));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, SKONTO));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, STOCKAGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, FREIGHT_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, PE_BAG));
                
        upsert blankPMPrices ExtId__c;
                    
    }    
    
    
    public List <PM_Price_Detail__c> setSpecificPriceToZero(List <PM_Price_Detail__c> listDetails) {
        for(PM_Price_Detail__c detail : listDetails){
            if (detail.List_Price__c == -1) {
                detail.List_Price__c = 0;
            }
        }  
        return listDetails;
    }
  
    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    public static List <PM_Price_Detail__c> getLineDetails(PM_Selected_Tubes_Config__c config, PM_Tubes_Pricing__c tp, String section, String name){
        List <PM_Price_Detail__c> listDetails;
        
        // We set the currency rate to be 
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           

        
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
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = 1000, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 1000, MOQ_Max__c = null, List_Price__c = 0)
            };
        }else{
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = (tp.X15__c == null? 0 : (tp.X15__c == -1 ? -1 : tp.X15__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = (tp.X20__c == null? 0 : (tp.X20__c == -1 ? -1 : tp.X20__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = (tp.X75__c == null? 0 : (tp.X75__c == -1 ? -1 : tp.X75__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = (tp.X200__c == null? 0 : (tp.X200__c == -1 ? -1 : tp.X200__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = (tp.X300__c == null? 0 : (tp.X300__c == -1 ? -1 : tp.X300__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = 10000, List_Price__c = (tp.X500__c == null? 0 : (tp.X500__c == -1 ? -1 : tp.X500__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 1000, MOQ_Max__c = null, List_Price__c = (tp.X1000__c == null? 0 : (tp.X1000__c == -1 ? -1 : tp.X1000__c * currencyRate)))
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
    } 
 

    public void log(Object message) {
        System.debug(message);
    }
    
}