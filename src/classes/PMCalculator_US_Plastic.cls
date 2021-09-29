public with sharing class PMCalculator_US_Plastic {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Tube Plastic
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   01-MAR-2017  Hasseeb             Initial version8
 *****************************************************************************/ 
    // sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String SLEEVE = 'Sleeve';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';
    public static final String PACKING = 'Packing';    
    public static final String OTHERS = 'Others';
 
    // SUB-SECTIONS
    // Tube & Head
    public static final String BASIS_PRICE = 'Basis Price';
    public static final String LENGTH_UPCHARGE = 'Length Upcharge';
    public static final String BODY_MATERIAL_UPCHARGE = 'Body Material Upcharge';
    
    // Sleeve
    public static final String SLEEVE_TYPE = 'Sleeve Type';
    public static final String SLEEVE_COLORATION = 'Sleeve Coloration';
    public static final String SLEEVE_PRINTING = 'Sleeve Printing';
    
    //Cap
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_FEATURE = 'Cap Feature';
    public static final String PEEL_SEAL = 'Peel Seal';
    public static final String CONSIGNED_CAP = 'Consigned Cap';
    public static final String MANUAL_CAPPING = 'Manual Capping';
    
    //Printing
    public static final String PRINTING_TECHNO = 'Printing Techno';
    public static final String PRINTING_EFFECT = 'Printing Effect';
    public static final String LABELLING = 'Labelling';
    //added 6329
    public static final String LABELLING_ADJUSTMENTS = 'Labelling adjustments';
    //***************/
    public static final String HOT_STAMPING = 'Hot Stamping';
    public static final String MATTE_COATING = 'Matte Coating';
    public static final String UV_INHIBITOR = 'UV Inhibitor';
    public static final String DOUBLE_PIGMENT = 'Double Pigment';
    
    //Packing
    public static final String PALLET = 'Pallet';
    public static final String POLYBAG = 'Polybag';
    
    //Others
    public static final String COMBO_UPCHARGE = 'Combo Upcharge';
    public static final String QUALITY_UPCHARGE = 'Quality Upcharge';
    public static final String RESIN_ADJUSTMENT = 'Resin Adjustment';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate'; 
    //added 6329
     public static final String MISCELLANEOUS_ADJUSTMENTS = 'Miscellaneous adjustments';
    //***************/

    public static final String CODE = 'CURRENT NA';


    
    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;    
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public Double dLength = 0;
    //public Double dLengthDbl = '';
    public Double stdLength = 0;
    private Decimal currencyRate = 1;
    public static Boolean bHasRunned = false;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_US_Plastic(PM_Selected_Tubes_Config__c config) {
        
        system.debug('PMCalculator_US_Plastic start....');
        if(!bHasRunned){

            
            this.config = config;
            currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
            calculateLength();
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);
            system.debug('VERSION'+version);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReferenceByProductSegment(config.Location__c, version, 'Plastic');  */
           // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReference(config.Location__c, 'Plastic', dt);
                      
        }
        
    }
    
    public void calculateLength() {   
        String lengthDecimal = '';
        if (String.isNotBlank(config.Specific_Length_inches__c)) {
            
            for(PM_Tubes_Config__c pm : [select Sleeve_length_inches_Decimal__c  
                                        from PM_Tubes_Config__c
                                        where Sleeve_Length_inches__c  = :config.Specific_Length_inches__c
                                        and Table_name__c = 'Fill Capacity'
                                        and Location__c = :config.Location__c 
                                        and Tubes_Segment__c = 'Plastic'
                                        limit 1]){
                
                lengthDecimal = pm.Sleeve_length_inches_Decimal__c;    
                system.debug('lengthDecimal' + pm.Sleeve_length_inches_Decimal__c);                            
            }            
            
            dLength = PMCalculator_US_Laminate.convertLengthFractionToDecimal(config.Specific_Length_inches__c);//Double.valueOf(config.Specific_Length_inches__c);
        } else {
            
            Decimal fillCapcity = (config.Fill_Capacity_oz__c == null ? 0:Decimal.valueOf(config.Fill_Capacity_oz__c));
            system.debug('******config.Fill_Capacity_oz__c****' + config.Fill_Capacity_oz__c + '__' + config.Diameter_inches__c);
            for(PM_Tubes_Config__c pm : [select Sleeve_length_inches_Decimal__c  
                                        from PM_Tubes_Config__c
                                        where Diameter_inches__c  = :config.Diameter_inches__c 
                                         and Fill_Capacity_oz__c = :fillCapcity
                                        and Table_name__c = 'Fill Capacity'
                                        and Location__c = :config.Location__c 
                                        and Tubes_Segment__c = 'Plastic'
                                        limit 1]){
                
                lengthDecimal = pm.Sleeve_length_inches_Decimal__c;    
                system.debug('LENGTH DECIMAL'+lengthDecimal);                            
            }    
            
            dLength = (lengthDecimal == null || lengthDecimal == '')?0:Double.valueOf(lengthDecimal);
                       
        }             
        system.debug('*********dLength**********' + dLength);        
    }

    public void calculate() {
        getStdLength();
        
        resetAllPMPrice();
        //String basisCode = ="CURRENT NA"&D3&E3
        createBasisCodePM();
        createLengthUpchargePM();
        createBodyMaterialUpchargePM();
        
        createSleeveTypePM(); 
        createSleeveColorationPM();
        createSleevePrintingPM();//SLEEVE_PRINTING
        
        createCapBasisPM(); //CAP_BASIS_PRICE
        createCapFeaturePM(); //CAP_FEATURE
        createPeelSealPM(); //PEEL_SEAL
        createConsignedCapPM(); // CONSIGNED_CAP
        createManualCappingPM(); // MANUAL_CAPPING
        
        //PRINTING 
        createPrintingTechnoPM(); // PRINTING_TECHNO
        createPrintingEffectPM(); //PRINTING_EFFECT
        createPrintingLabellingPM(); // LABELLING
        //added Ticket 6329
        calculateLABELLING_ADJUSTMENTS();
        // end added
        createPrintingHotStampingPM(); // HOT_STAMPING
        createPrintingMatteCoatingPM(); //  MATTE_COATING
        createPrintingUVInhibitorPM(); // UV_INHIBITOR
        createPrintingDoublePigmentPM(); // DOUBLE_PIGMENT
        
        //PACKING 
        createPackingPalletPM(); // PALLET
        createPackingPolyBagPM(); //POLYBAG
        
        //OTHERS 
        createComboUpchargePM(); //COMBO_UPCHARGE
        createComboQualitychargePM(); //QUALITY_UPCHARGE
        createComboResinAdjustmentPM(); //RESIN_ADJUSTMENT
        createEndOfYearRebatePM(); //END_OF_YEAR_REBATE
         //added Ticket 6329
        calculateMISCELLANEOUS_ADJUSTMENTS();
         // end added
        
        upsert listDetailsToUpsert ExtId__c;
        
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        PMCalculatorUtility.calculateTotalMOQPRice(config.Id, null, config.Quote_item__c);
        // Added for Historisation
        if (mapPMTubesPricing.size()> 0) update mapPMTubesPricing.values();
    }
    
    public void resetAllPMPrice() {       
        
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, LENGTH_UPCHARGE));    
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, BODY_MATERIAL_UPCHARGE));
         
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, SLEEVE, SLEEVE_TYPE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, SLEEVE, SLEEVE_COLORATION));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, SLEEVE, SLEEVE_PRINTING));
        
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, CAP, CAP_BASIS_PRICE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, CAP, CAP_FEATURE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, CAP, PEEL_SEAL));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, CAP, CONSIGNED_CAP));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, CAP, MANUAL_CAPPING));
                    
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, PRINTING_TECHNO));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, PRINTING_EFFECT));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, LABELLING));
        //added ticket 6329
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, LABELLING_ADJUSTMENTS));
        // end added
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, HOT_STAMPING));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, MATTE_COATING));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, UV_INHIBITOR));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, DOUBLE_PIGMENT));

        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PACKING, PALLET));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PACKING, POLYBAG));
        
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, COMBO_UPCHARGE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, QUALITY_UPCHARGE));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, RESIN_ADJUSTMENT));
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        //added ticket 6329
        blankPMPrices.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, MISCELLANEOUS_ADJUSTMENTS)); 
        // end added    
        upsert blankPMPrices ExtId__c;
                
    }
    
    
    
    public void getStdLength() {        
        if (String.isNotBlank(config.Diameter_inches__c)) {
            for(PM_Tubes_Config__c pm : [select Std_Length_min__c 
                                        from PM_Tubes_Config__c
                                        where Diameter_inches__c  = :config.Diameter_inches__c    
                                        and Table_name__c = 'Sleeve Length'
                                        and Location__c = :config.Location__c                                        
                                        limit 1]){
                
                stdLength = Double.valueOf(pm.Std_Length_min__c);                                                                               
            }                        
        } 
    }
    
    
    public void createBasisCodePM() {
        system.debug('PMCalculator_US_Plastic....Create Basis Code...');

        if (String.isNotBlank(config.Shape__c) && String.isNotBlank(config.Head_Name__c)) {
            //All price is -1 (Specific) if Incoterm is Delivered
            if (config.Incoterm__c == null || config.Incoterm__c != 'Delivered') {                          
                String ref = 'CURRENT NA' + config.Diameter_inches__c + config.Head_Name__c;
                System.debug('createBasisCodePM()' + ref);
                system.debug('BASIC CODE='+ref);
                system.debug(mapPMTubesPricing.get(ref.toUppercase()));
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, BASIS_PRICE));
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
            } else {
                if (config.Incoterm__c.equalsIgnoreCase('Delivered')) {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, BASIS_PRICE), -1));                                                               

                }
             }
            
        } else {
            listDetailsToUpsert.addAll(PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        }
               
    }

    /**
     * KEY = "CURRENT NA<DIAMETER>Length <SLEEVE MATERIAL>"
     */     
    public void createLengthUpchargePM() {  
        System.debug('createLengthUpchargePM');
        if (dLength > 0) {         
           String sleeveType = config.Sleeve_type__c == null? '': config.Sleeve_type__c;
            //Fix bug for database ref which has uppercase Aesthetic instead of aesthetic
            if ('Aesthetic Coex'.equalsIgnoreCase(config.Sleeve_type__c)) {
                sleeveType = 'Aesthetic coex';
            } else {
                sleeveType = config.Sleeve_type__c != null?config.Sleeve_type__c.toLowerCase(): '0';
            }
                String ref = CODE + config.Diameter_inches__c + 'Length ' + sleeveType; 
                system.debug('@@ ref:'+ref);
                Decimal price = (Decimal.valueOf(dLength) - stdLength)/0.25;                           
                List<PM_Price_Detail__c> details = PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, LENGTH_UPCHARGE);    
                system.debug(details);
                for (PM_Price_Detail__c pmPrice : details) {
                      if (pmPrice.List_Price__c == 0) {
                        pmPrice.List_Price__c = -1;
                      } else {
                         pmPrice.List_Price__c =  price * pmPrice.List_Price__c;  
                      }                      
                      system.debug('PRICE=' + pmPrice.List_Price__c + '_MULTIPLIER_' + price);
                      listDetailsToUpsert.add(pmPrice);
                                                                    
                }  
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                     PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                      '_'+LENGTH_UPCHARGE);
                     listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = LENGTH_UPCHARGE;
                }
        } else {
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.getUSLineDetails(config, null, TUBE_HEAD, LENGTH_UPCHARGE));
        }
    }
    
    /**
     * KEY = "CURRENT NA<DIAMETER><SLEEVE MATERIAL MIX-SETTING BODY MATERIAL>""
     */ 
    public void createBodyMaterialUpchargePM() {
        System.debug('createBodyMaterialUpchargePM');
       
        if (String.isNotBlank(config.Sleeve_Material_Mix__c)) {
            String materialMix = '';
            
            if ('High Density'.equalsIgnoreCase(config.Sleeve_Material_Mix__c)) {
                materialMix = 'HDPE MONOLAYER';
            } else if ('Medium Density'.equalsIgnoreCase(config.Sleeve_Material_Mix__c)) {
                materialMix = 'MDPE MONOLAYER';
            } else if ('Low Density'.equalsIgnoreCase(config.Sleeve_Material_Mix__c)) {
                materialMix = 'LDPE MONOLAYER';
            }
            if (materialMix != '') {                
                String ref = CODE + config.Diameter_inches__c + materialMix;
                System.debug('createBodyMaterialUpchargePM'+ref);   
                System.debug(PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, BODY_MATERIAL_UPCHARGE));
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), TUBE_HEAD, BODY_MATERIAL_UPCHARGE));
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                      '_'+BODY_MATERIAL_UPCHARGE);
                        listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = BODY_MATERIAL_UPCHARGE;
                }
            } 
        } 
        
    } 
    
    /**
     * KEY ="CURRENT NA<DIAMETER><SLEEVE TYPE>
     */ 
    public void createSleeveTypePM() {
        system.debug('......createSleeveTypePM....'+ config.Sleeve_type__c);
        if (String.isNotBlank(config.Sleeve_type__c)) {
           String ref = CODE + config.Diameter_inches__c + config.Sleeve_type__c;
           listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_TYPE));
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
    
    /**
     * KEY ="CURRENT NA<DIAMETER><SLEEVE COLOR>"
     */ 
    public void createSleeveColorationPM() {
        if (String.isNotBlank(config.Sleeve_Color__c)) {
           String ref = CODE + config.Diameter_inches__c + config.Sleeve_Color__c;
           listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_COLORATION));
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
        
    }
    
    /**
     * KEY ="CURRENT NA<DIAMETER>Sleeve Print"
     * 
     */ 
    public void createSleevePrintingPM() {
        System.debug('.................Start createSleevePrintingPM=' + config.Printing_Effects__c);
        //Set the Sleeve Print to 5
        if ('Sleeve Print'.equalsIgnoreCase(config.Printing_Effects__c)) {
           listDetailsToUpsert.addAll(
                    PMCalculatorUtility.setListPrice(PMCalculatorUtility.getUSLineDetails(config, null, SLEEVE, SLEEVE_PRINTING), 5));                                                               

        } else {
            String ref = CODE + config.Diameter_inches__c + 'Sleeve Print';
            system.debug(ref);
           listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), SLEEVE, SLEEVE_PRINTING));
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+SLEEVE+
                                                                                      '_'+SLEEVE_PRINTING);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_PRINTING;
            }
        }       
        
    }   
    
    /**
     * KEY ="<CAP CODE><CAP COLOR>"
     * 
     */ 
    public void createCapBasisPM() {
        System.debug('.................Start createCapBasisPM');
        String capEuroCode = config.Cap_Eurocode__c; //X3
        String consignedCap = (String.isNotBlank(config.Consigned_Cap__c) ? config.Consigned_Cap__c.toUpperCase(): 'NO'); //AC3
        string sleevematerial = (config.Sleeve_type__c == null)?'':config.Sleeve_type__c;
        
        if (String.isBlank(config.Cap_Eurocode__c) || consignedCap == 'YES' 
                || config.Cap_Eurocode__c == 'CD1' || sleevematerial.startsWith('O')) {
            //Price should be zero here
            System.debug('createCapBasisPM criteria nto matched...');
            
        } else {
            String capColor = '';
           if ('White'.equalsIgnoreCase(config.Cap_Color__c) || 'Natural'.equalsIgnoreCase(config.Cap_Color__c) || 'White/Natural'.equalsIgnoreCase(config.Cap_Color__c)) {
               capColor = 'WHITE/NATURAL';
           } else {
               capColor = 'Standard Color';
           }
            
            String ref = config.Cap_Eurocode__c + capColor;
            System.debug('REF='+ref);
            List<PM_Price_Detail__c> details = PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_BASIS_PRICE);
            Integer index = 0;
            
            //Get the valeu from MOQ 20, because there is no price for MOQ25
            /*for (PM_Price_Detail__c detail: details) {
                PM_Price_Detail__c previousDetail = details.get((index ==0 ? 0 : index -1));
                if (detail.MOQ_Min__c == 25) {
                    detail.List_Price__c = previousDetail.List_Price__c;
                }
                index++;
            }*/
            
            //system.debug(PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref), CAP, CAP_BASIS_PRICE));
            listDetailsToUpsert.addAll(details);  
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
        }         
    }   
 
    /**
     * KEY ="CURRENT NA<DIAMETER>Sleeve Print"
     * 
     */ 
    public void createCapFeaturePM() {
        String feature = '';
                
        for(PM_Tubes_Config__c pm : [select Shrink_band__c, Hot_Stamping__c  
                                     from PM_Tubes_Config__c
                                     where Diameter_inches__c  = :config.Diameter_inches__c    
                                     and Table_name__c = 'CAP FEATURE'
                                     and Location__c = :config.Location__c                                        
                                     limit 1]) {
            Decimal price = 0; 
            Integer index = 0;                            
            if (String.isNotBlank(config.Shrink_band__c) && 'YES'.equalsIgnoreCase(config.Shrink_band__c)) {
                price = Decimal.valueOf(pm.Shrink_band__c);
                index +=1;
            }       
            if (String.isNotBlank(config.Cap_Hot_Stamping__c) && 'YES'.equalsIgnoreCase(config.Cap_Hot_Stamping__c)) {
                price += Decimal.valueOf(pm.Hot_Stamping__c);
                index+=1;
            } 
            if (index == 2) {
                price = price * 1.04;                             
            }
                                                     
                                         
                                         
            listDetailsToUpsert.addAll(
                    PMCalculatorUtility.setListPrice(PMCalculatorUtility.getUSLineDetails(config, null, CAP, CAP_FEATURE), price));                                                               
        }        
            
    }  
    
    /**
     * KEY ="CURRENT NA<DIAMETER>Peel Seal (if available)"
     * 
     */ 
    public void createPeelSealPM() {        
        if (String.isBlank(config.Peel_Seal__c) || 'NA'.equalsIgnorecase(config.Peel_Seal__c)) {
            //Price should be zero here
        } else {
            
             //String ref = CODE + config.Diameter_inches__c + 'Peel Seal (if available)';
            String ref = CODE + config.Diameter_inches__c + config.Peel_Seal__c; 
            
            listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, PEEL_SEAL));                
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+PEEL_SEAL);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PEEL_SEAL;
            }
        }         
    }

    /**
     * KEY ="CURRENT NA<DIAMETER>Consigned Caps"
     * 
     */ 
    public void createConsignedCapPM() {        
        if (String.isNotBlank(config.Consigned_Cap__c) && 'Yes'.equalsIgnorecase(config.Consigned_Cap__c)) {
            String ref = CODE + config.Diameter_inches__c + 'Consigned Caps';
            listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CONSIGNED_CAP));                
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+CONSIGNED_CAP);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CONSIGNED_CAP;
            }
        }         
    }   
    
     /**
     * KEY ="CURRENT NA<DIAMETER>Hand-Apply Caps"
     * 
     */ 
    public void createManualCappingPM() {        
        if (String.isNotBlank(config.Manual_Capping__c) && 'Yes'.equalsIgnorecase(config.Manual_Capping__c)) {
            String ref = CODE + config.Diameter_inches__c + 'Hand-Apply Caps';
            listDetailsToUpsert.addAll(
               PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, MANUAL_CAPPING));                
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+MANUAL_CAPPING);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = MANUAL_CAPPING;
            }
        }         
    }    

     /**
     * KEY ="CURRENT NA<DIAMETER>Hand-Apply Caps"
     * 
     */ 
    public void createPrintingTechnoPM() {   
        System.debug('........................Start createPrintingTechnoPM' + config.Printing_type__c);
        if (String.isNotBlank(config.Printing_type__c)) {
           
            List<PM_Price_Detail__c> details = new List<PM_Price_Detail__c>();
            
            if ('Label'.equalsIgnorecase(config.Printing_type__c)) {
                //Price = 45
            } else {
                String ref= '';
                //get Offset Code
                if (config.NB_Offset_Colors__c > 4) {
                    ref = CODE + config.Diameter_inches__c + 'Offset';
                    
                    if (config.NB_Offset_Colors__c < 7) {
                       ref += ' ' + config.NB_Offset_Colors__c + ' Color Ink';
                    } else {
                        ref += ' 7 or 8 Color Ink';
                    }               
                } else {
                    
                }
                System.debug('OFFSET='+ ref);
                List<PM_Price_Detail__c> offsetLines = PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_TECHNO);                
                details.addAll(offsetLines);   
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+PRINTING_TECHNO);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_TECHNO;
                }
                System.debug(offsetLines);                
               // details.addAll(PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref), PRINTING, PRINTING_TECHNO));
            //  System.debug(details);
                               
                String refFlexo = '';
                //get Flexo Code
                if (config.NB_Flexo_Colors__c > 4) {
                    refFlexo = CODE + config.Diameter_inches__c + 'Flexo';
                    
                    if (config.NB_Flexo_Colors__c < 7) {
                        refFlexo += ' ' + config.NB_Flexo_Colors__c + ' Color Ink';
                    } else {
                        refFlexo += ' 7 or 8 Color Ink';
                    }               
                }  
                System.debug('FLEXO='+ refFlexo);
                if (refFlexo != '') {
                    
                    List<PM_Price_Detail__c> flexoLines = PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(refFlexo.toUppercase()), PRINTING, PRINTING_TECHNO);                
                    details.addAll(flexoLines);                
                    System.debug(flexoLines);
                    // Added for Historisation
                    // Create Junction Object
                    dp = mapPMTubesPricing.get(refFlexo.toUpperCase());
                    if( dp != null){
                                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                                 Tube_Pricing__c = dp.Id, 
                                                                                 Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                              '_'+PRINTING_TECHNO+'_2');
                                listPricingJunctionToUpsert.add(pj);
                    }
                    // Update Prices
                    if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                        mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                        mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_TECHNO;
                    }
                }
                
            
                String refSilkScreen = '';
                if (config.Printing_type__c.toUpperCase().contains('SILKSCREEN')) {
                       refSilkScreen = CODE + config.Diameter_inches__c + 'Silk Screen';
                    //&& Decimal.valueOf(config.Diameter_inches__c) < 1
                    if (config.NB_SS_Colors__c < 3 && stdLength < 1) {
                        refSilkScreen += ' 1-2';
                    } else {
                        refSilkScreen += ' ' + config.NB_SS_Colors__c;
                    }
                    System.debug('SS='+ refSilkScreen);
                    List<PM_Price_Detail__c> ssLines = PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(refSilkScreen.toUppercase()), PRINTING, PRINTING_TECHNO);
                    details.addAll(ssLines);                
                    System.debug(ssLines);
                    // Added for Historisation
                    // Create Junction Object
                    dp = mapPMTubesPricing.get(refSilkScreen.toUpperCase());
                    if( dp != null){
                                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                                 Tube_Pricing__c = dp.Id, 
                                                                                 Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                              '_'+PRINTING_TECHNO+'_3');
                                listPricingJunctionToUpsert.add(pj);
                    }
                    // Update Prices
                    if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                        mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                        mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_TECHNO;
                    }
                }          
              
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroup(details,  new Set<String>(), config, 0, PRINTING, PRINTING_TECHNO));
            }
        }        
    }   
 
     /**
     * KEY ="CURRENT NA<DIAMETER><Printing Effect Config>"
     * 
     */ 
    public void createPrintingEffectPM() {        
        if (String.isNotBlank(config.Printing_Effects__c) && !'Sleeve Print'.equalsIgnorecase(config.Printing_Effects__c)) {
            
            for(PM_Tubes_Config__c pm : [select Print_Effect_Name__c   
                                         from PM_Tubes_Config__c
                                         where Print_Effect_Options__c   = :config.Printing_Effects__c    
                                         and Table_name__c = 'Print Effect'
                                         and Location__c = :config.Location__c                                        
                                         limit 1]) {
                String ref = CODE + config.Diameter_inches__c + pm.Print_Effect_Name__c;
                                             
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, PRINTING_EFFECT));                                                               
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+PRINTING_EFFECT);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_EFFECT;
                }
            }            
            
        }         
    }     
  
      /**
     * Offset + Floxo + SS Colors config lines..
     * 
     */ 
    public void createPrintingLabellingPM() {   
        System.debug('*********** createPrintingLabellingPM ***********LINE='+config.Printing_type__c);
        if (String.isNotBlank(config.Printing_type__c) && 'Label'.equalsIgnorecase(config.Printing_type__c)) {
            List<PM_Price_Detail__c> details = new List<PM_Price_Detail__c>();   
           /* String ref= '';
            //get Offset Code
            if (config.NB_Offset_Colors__c > 4) {
                ref = CODE + config.Diameter_inches__c + 'Offset';
                
                if (config.NB_Offset_Colors__c < 7) {
                    ref += ' ' + config.NB_Offset_Colors__c + ' Color Ink';
                } else {
                    ref += ' 7 or 8 Color Ink';
                }               
            }*/
           // System.debug('OFFSET RED='+ ref);
            //Set 45 as Price if Label
            //Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            Decimal labelPrice = 45 * currencyRate;
            system.debug('LABELPRICE=' + labelPrice);
            details.addAll(PMCalculatorUtility.setListPrice(
                           PMCalculatorUtility.getUSLineDetails(config, null, PRINTING, LABELLING), labelPrice));
                            
            String refFlexo = '';
            //get Flexo Code
            if (config.NB_Flexo_Colors__c > 4) {
                refFlexo = CODE + config.Diameter_inches__c + 'Flexo';
                
                if (config.NB_Flexo_Colors__c < 7) {
                    refFlexo += ' ' + config.NB_Flexo_Colors__c + ' Color Ink';
                } else {
                    refFlexo += ' 7 or 8 Color Ink';
                }               
            }   
            System.debug('FLEXO RED='+ refFlexo);
            if (refFlexo != '') {
                
                details.addAll(PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(refFlexo.toUppercase()), PRINTING, LABELLING));                
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(refFlexo.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+LABELLING);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(refFlexo.toUppercase())!= null){
                    mapPMTubesPricing.get(refFlexo.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(refFlexo.toUppercase()).Line_Name__c = LABELLING;
                }
            }
            
            
            String refSilkScreen = '';
            if (config.Printing_type__c.toUpperCase().contains('SILKSCREEN')) {
                refSilkScreen = CODE + config.Diameter_inches__c + 'Silk Screen';
                //&& Decimal.valueOf(config.Diameter_inches__c) < 1
                if (config.NB_SS_Colors__c < 3 && stdLength < 1) {
                    refSilkScreen += ' 1-2';
                } else {
                    refSilkScreen += ' ' + config.NB_SS_Colors__c;
                }
                System.debug('SILK SCREEN RED='+ refSilkScreen);

                details.addAll(PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(refSilkScreen.toUppercase()), PRINTING, LABELLING));                
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(refSilkScreen.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+LABELLING);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(refSilkScreen.toUppercase())!= null){
                    mapPMTubesPricing.get(refSilkScreen.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(refSilkScreen.toUppercase()).Line_Name__c = LABELLING;
                }
            }          
              
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroup(details,  new Set<String>(), config, 0, PRINTING, LABELLING));
            
        }         
    } 
    
     /**
     * KEY ="CURRENT NA<DIAMETER>Hot Stamp"
     *
     */ 
    public void createPrintingHotStampingPM() {  
        System.debug('.....................Start createPrintingHotStampingPM');
        if (String.isNotBlank(config.Deco_Hot_Stamping__c) && 'Yes'.equalsIgnoreCase(config.Deco_Hot_Stamping__c)) {
                String ref = CODE + config.Diameter_inches__c + 'Hot Stamp';
                System.debug('REF='+ref);                             
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, HOT_STAMPING));                                                                                      
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+HOT_STAMPING);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HOT_STAMPING;
                }
        }         
    }  

     /**
     * KEY ="CURRENT NA<DIAMETER>Matte Coating"
     */ 
    public void createPrintingMatteCoatingPM() {  
        system.debug('.....createPrintingMatteCoatingPM....' + config.Coating__c);

        if (String.isNotBlank(config.Coating__c) && config.Coating__c.containsIgnoreCase('Matte')) {
                String ref = CODE + config.Diameter_inches__c + 'Matte Coating';
                system.debug('.....createPrintingMatteCoatingPM....REF=' + ref +'_=_'+ ref.toUpperCase());                             
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, MATTE_COATING));                                                                                      
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+MATTE_COATING);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = MATTE_COATING;
                }
        }          
    }     

    /**
     * KEY ="CURRENT NA<DIAMETER>U.V. Inhibitor"
     */ 
    public void createPrintingUVInhibitorPM() {        
        if (String.isNotBlank(config.UV_Inhibitor__c) && 'Yes'.equalsIgnoreCase(config.UV_Inhibitor__c)) {
                String ref = CODE + config.Diameter_inches__c + 'U.V. Inhibitor';
                                             
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, UV_INHIBITOR));                                                                                      
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                      '_'+UV_INHIBITOR);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = UV_INHIBITOR;
            }
        }         
    } 

    /**
     * KEY ="CURRENT NA<DIAMETER>Double Pigment"
     */ 
    public void createPrintingDoublePigmentPM() {        
        if (String.isNotBlank(config.Double_Pigment__c) && !'No'.equalsIgnoreCase(config.Double_Pigment__c)) {
                String ref = CODE + config.Diameter_inches__c + 'Double Pigment';
                                             
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PRINTING, DOUBLE_PIGMENT));                                                                                      
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+DOUBLE_PIGMENT);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = DOUBLE_PIGMENT;
                }
        }         
    }    

    /**
     * KEY ="CURRENT NA<DIAMETER>Heat Treated Pallet"
     */ 
    public void createPackingPalletPM() { 
        System.debug('.....................Start createPackingPalletPM');
        if (String.isNotBlank(config.Pallet__c) && 'Heat Treated Wooden Pallet'.equalsIgnoreCase(config.Pallet__c)) {
                String ref = CODE + config.Diameter_inches__c + 'Heat treated pallet';
                System.debug('REF='+ref);                       
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PACKING, PALLET));                                                                                      
            //    listDetailsToUpsert.addAll(
             //       PMCalculatorUtility.roundListPrice(
             //           PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PACKING, PALLET)));                                                                                      

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PACKING+
                                                                                      '_'+PALLET);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PACKING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PALLET;
            }
        }         
    }  
    
    /**
     * KEY ="CURRENT NA<DIAMETER><PolyBag>"
     * 
     */ 
    public void createPackingPolyBagPM() {  
        system.debug('......createPackingPolyBagPM....'+config.Polybag__c);
        if (String.isNotBlank(config.Polybag__c)) {
                String ref = CODE + config.Diameter_inches__c + config.Polybag__c;
                 system.debug('......createPackingPolyBagPM....REF='+ref);                            
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), PACKING, POLYBAG));                                                                                      
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PACKING+
                                                                                          '_'+POLYBAG);
                            listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = PACKING;
                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = POLYBAG;
                }
        }         
    }   
    
     /**
     * KEY ="CURRENT NA<DIAMETER><PolyBag>"
     * 
     */ 
    public void createComboUpchargePM() {  
        system.debug('......createComboUpchargePM....');
        if(config.Number_of_ref_per_run__c >= 2  //$CD$16
                        && config.Number_of_tubes_per_artwork_in_Ku__c > 0) { 
                //B5 = MOQ
              List<PM_Price_Detail__c> details = PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, COMBO_UPCHARGE);
              for (PM_Price_Detail__c pmDetail : details) {
                  Decimal refPerRunByMOQDec =  pmDetail.MOQ_Min__c /config.Number_of_tubes_per_artwork_in_Ku__c;   
                  Long refPerRunByMOQtest = refPerRunByMOQDec.round(System.roundingMode.DOWN);
                  Decimal refPerRunIndex = Math.min(config.Number_of_ref_per_run__c, Math.max(refPerRunByMOQtest, 1)) - 1; 
                 
                  pmDetail.List_Price__c = refPerRunIndex * 600 / pmDetail.MOQ_Min__c; 
                  system.debug('MOQ' + pmDetail.MOQ_Min__c + 'refPerRunByMOQDec=' + refPerRunByMOQDec + '=refPerRunByMOQtest=' + refPerRunByMOQtest
                              + '=refPerRunIndex=' + refPerRunIndex + '=PRICE=' + pmDetail.List_Price__c);
                  
                  
              } 
              listDetailsToUpsert.addAll(details);
        }
         
    } 
 
     /**
     * //=IF($BU$3=0,0,VLOOKUP($BU$3,'BACK UP - Plastic'!$CK$4:$CL$7,2,0))
     * 
     */ 
    public void createComboQualitychargePM() { 
        system.debug('......createComboQualitychargePM....'+config.Quality_Level__c);
        if (String.isNotBlank(config.Quality_Level__c) && !'0'.equalsIgnorecase(config.Quality_Level__c)) {
            
            Boolean found = false;
            for(PM_Tubes_Config__c pm : [select Upcharge__c    
                                         from PM_Tubes_Config__c
                                         where Quality_Level__c    = :config.Quality_Level__c    
                                         and Table_name__c = 'Quality Upcharge'
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Plastic' 
                                         limit 1]) {
                                             
                found = true;  
                system.debug(QUALITY_UPCHARGE + ': FOUND');
                system.debug(QUALITY_UPCHARGE + ':' + pm);
                if (pm.Upcharge__c != null && pm.Upcharge__c.isNumeric()) {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, QUALITY_UPCHARGE), 
                            Double.valueOf(pm.Upcharge__c)));                                                                                                               
                } else {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, QUALITY_UPCHARGE), 
                            -1));                      
                }
                                             
            } 
            
        }         
    }  
    
 
    public void createComboResinAdjustmentPM() {  
        system.debug('*********** createComboResinAdjustmentPM ***********LINE END OF YEAR REBATE='+config.Resin_Index__c);        
        if (config.Resin_Index__c != null && config.Resin_Index__c > 0 
            && dLength > 0 && String.isNotBlank(config.Sleeve_type__c)) {
            
            Double resinAdjustment = config.Resin_Index__c - 0.76;
            Double wtLB = 0;
            for(PM_Tubes_Config__c pm : [select wtLB__c    
                                         from PM_Tubes_Config__c
                                         where Diameter_inches__c  = :config.Diameter_inches__c    
                                         and Table_name__c = 'CDI Impact Diameter'
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Plastic' 
                                         limit 1]) {
                wtLB = pm.wtLB__c;
            }
            
            Double capWt = 0;
            Double hdWT = 0;
            boolean capWTFound = false;
            boolean hdWTFound = false;
            for(PM_Tubes_Config__c pm : [select Cap_nb__c, Cap_wt__c, Hd_Wt__c, Concatenate__c     
                                         from PM_Tubes_Config__c
                                         where (Cap_nb__c  = :config.Cap_Eurocode__c OR
                                         Concatenate__c = :config.Diameter_inches__c + config.Head_Name__c)
                                         and Table_name__c = 'CDI Impact Cap / head'
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Plastic']) {
               system.debug('CONFIG CDI IMPACT=' + pm);
               system.debug('EUROCODE=' + config.Cap_Eurocode__c + '=VS=' + pm.Cap_nb__c); 
               system.debug('DIAMETERHEADNAME=' + config.Diameter_inches__c + config.Head_Name__c +'=VS=' + pm.Concatenate__c);  
               if (pm.Cap_nb__c == config.Cap_Eurocode__c) {
                   capWTFound = true;
                   system.debug('CAP WT IS NUMERIC?' +pm.Cap_wt__c.isNumeric());
                   capWt = ((pm.Cap_wt__c != null)  ? Double.valueOf(pm.Cap_wt__c) : 0);                             
               }
               if (pm.Concatenate__c == config.Diameter_inches__c + config.Head_Name__c) {
                   hdWTFound = true;
                   hdWT = (pm.Cap_wt__c == null ? 0 :pm.Hd_Wt__c);                             
               }                                                            
            }
                
            system.debug('WTLB=' + wtLB + 'RESIN=' + resinAdjustment);
            Decimal price = 0;
            if (capWTFound && hdWTFound) {
                price = resinAdjustment * (((wtLB == null ? 0 : wtLB * dLength) * 1.4) 
                        + (capWt * 1.1)
                        + (hdWT * 1.4));
                system.debug('PRICE=' + price + ':CAPWT=' + capWt +':HDWT='+ hdWT);                    
            }

            if (price != 0) {
                  //price = price.round();
                  listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, RESIN_ADJUSTMENT), 
                            price * currencyRate));
            }
             
        }
    }
    
    public void createEndOfYearRebatePM() {  
        system.debug('*********** createPumpPM ***********LINE END OF YEAR REBATE='+qli.Customer_end_of_year_rebate__c);
        if(qli != null && String.isNotBlank(qli.Customer_end_of_year_rebate__c) 
          && !'No'.equalsIgnoreCase(qli.Customer_end_of_year_rebate__c)){
 
          Decimal dPercent = 0;
            // TODO : query percent - RECO - Backup N19:R20
            if(qli.Customer_end_of_year_rebate__c == 'Yes (3% or more)'){
                dPercent = 0.03;
            }else if(qli.Customer_end_of_year_rebate__c == 'Yes (2%)'){
                dPercent = 0.02;
            }else if(qli.Customer_end_of_year_rebate__c == 'Yes (1%)'){
                dPercent = 0.01;
            }            
            
            if (dPercent != 0) {
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>(), config, dPercent, OTHERS, END_OF_YEAR_REBATE));
                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.getUSLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }        
    }     


    //********* Adde ticket 6329*/ 
    public void calculateMISCELLANEOUS_ADJUSTMENTS(){
      //  log('*********** calculate********: MISCELLANEOUS_ADJUSTMENTS');
        listDetailsToUpsert.addAll(PMCalculatorUtility.getUSLineDetails(config, null, OTHERS,MISCELLANEOUS_ADJUSTMENTS ));  
                          
    }
    public void calculateLABELLING_ADJUSTMENTS(){
        //  log('*********** calculate********: MISCELLANEOUS_ADJUSTMENTS');
        listDetailsToUpsert.addAll(PMCalculatorUtility.getUSLineDetails(config, null, PRINTING,LABELLING_ADJUSTMENTS ));

    }
   //****end  */
    
}