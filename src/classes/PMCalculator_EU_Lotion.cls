/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-15-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class PMCalculator_EU_Lotion {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for EU Dispensing Lotion
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   05-MAR-2017  Hasseeb             Initial version
 *****************************************************************************/ 
    // sections
    public static final String PRODUCT_DEFINITION = 'Product Definition';
    public static final String UPPER_PART_DECO = 'Upper Part Decoration Upcharge';
    public static final String PUMP_OPTIONS = 'Pump Options';
    public static final String BOTTLE_DECO = 'Bottle Decoration Options';  
    public static final String OTHERS = 'Others';
      
        
    // SUB-SECTIONS
    // Product Definition
    public static final String PUMP = 'Pump';
    public static final String METAL_SLEEVE_ACTUATOR = 'Metal Sleeved Actuator';
    public static final String OVERCAP = 'Overcap'; 
    public static final String BOTTLE = 'Bottle';

    
    // Deco Upcharge
    public static final String ACTUATOR = 'Actuator finishing';
    public static final String COLLAR = 'Collar finishing';
    public static final String CAP = 'Cap finishing';
    public static final String COLLAR_DECO = 'Collar decoration';//COLLAR_DECO  CAP_DECO
    public static final String CAP_DECO = 'Cap decoration';
    public static final String DECO_INSERT = 'Insert coloring';    
    public static final String Cap_HOT_STAMPING         = 'Cap Hot stamping'; 
    public static final String Cap_LACQUERING           = 'Cap lacquering';
    public static final String COLLAR_LACQUERING        = 'Collar lacquering';
    public static final String COLLAR_HOT_STAMPING_BAND = 'Collar Hot stamping band';

    
    //PUMP OPTIONS
    public static final String PBT_BODY = 'PBT Body';
    public static final String PLASTIC_PROTECTION = 'Plastic Protection';
    public static final String DIPTUBE_LENGTH = 'Diptube Length';

 
    
    //Bottle Deco Options
    public static final String BOTTLE_HOT_STAMPING = 'Bottle Hot Stamping';
    public static final String BOTTLE_OFFSET = 'Bottle Offset';
    public static final String BOTTLE_SILK_SCREENING = 'Bottle Silk-Screening';
    public static final String BOTTLE_COLORING = 'Bottle Coloring';
    public static final String BOTTLE_RING = 'Bottle Ring';
    public static final String BOTTLE_DIGITAL_PRINTING = 'Bottle Digital Printing';
     
    //Others
    public static final String LEAN_OPTIMIZATION = 'Lean Optimization';
    public static final String DAYS5_LEAD_TIME = '5 days Lead Time';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
    public static final String SKONTO = 'Skonto';
    
    
    public static final List<String> Names=new List<String> {'Pump','Overcap','Bottle','Actuator finishing','Collar finishing','Collar decoration','Cap finishing','Cap decoration','Insert coloring','PBT Body','Plastic Protection','Diptube Length','Bottle Hot Stamping','Bottle Offset','Bottle Silk-Screening','Bottle Coloring','Bottle Ring'};
    public PM_Selected_Dipsensing_config__c  config;
    public QuoteLineItem qli;
    public Map <String, PM_Dispensing_Pricing__c> mapPMDispensingPricing;    
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public Double dLength = 0;
    public Double stdLength = 0;
    public Decimal overcapPricex250 = 0;

    public static Boolean bHasRunned = false;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_EU_Lotion(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_EU_Lotion start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c,
                       US_rate_to_currency__c,QuoteId
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
       
            /*Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
            log('VERSION='+version);
            log('LOCATION='+config.Location__c);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricing(config.Location__c, version);   */
            // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, config.Product_segment__c, dt, false, true);
            System.debug('mapPMDispensingPricing : '+ mapPMDispensingPricing);
        }
        
    }
    
    public void calculate() {

        resetAllPMPrice();
        createOvercapPM(); // Overcap; Calculate Overcap first as it is dependent upon PumpPM
        createPumpPM(); // Pump;
        //createMetalSleeveActuatorPM(); // Metal Sleeved Actuator;
        
        createBottlePM(); // Bottle;
    
        
        // Deco Upcharge
        createActuatorPM(); // Actuator;
        createCollarPM(); // Collar;
        createCollarDecoPM(); // Collar Decoration;
        createCapPM(); // Cap;
        createCapDecoPM(); // Cap Decoration;
        createDecoInsertPM(); // Insert;
        //createCap_HOT_STAMPING();
       // createCOLLAR_LACQUERING();
       // createCOLLAR_HOT_STAMPING_BAND();
        //createCAP_LACQUERING();
                    
        
        //PUMP OPTIONS
        createPbtBodyPM(); // PBT Body;
        createPlasticProtectionPM(); // Plastic Protection;
        createDiptubeLengthPM(); // Diptube Length;
    
     
        
        //Bottle Deco Options
        createBottleHotStampingPM(); // Bottle Hot Stamping;
        createBottleOffsetPM(); // Bottle Offset;
        createBottleSilkScreeningPM(); // Bottle Silk-Screening;
        createBottleColoringPM(); // Bottle Coloring;
        createBottleRingPM(); // Bottle Ring;
        //createBottleDigitalPrintingPM(); //Digital Printing;
         
        //Others
       // createLeanOptimizationPM(); // Lean Optimization;
       // createDay5LeadTimePM(); // 5 days Lead Time;
       // createEndOfyearRebatePM(); // End of Year Rebate;
        createSkontoPM(); // Skonto;        
        
         System.debug('before exception listDetailsToUpsert  : '+ listDetailsToUpsert);
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        
       // PMCalculatorUtility.calculateTotalMOQPRice(null, config.Id, config.Quote_item__c);
       PMCalculatorUtility.calculateTotalMOQPRice_BIS(null, config.Id, config.Quote_item__c,Names);
        // Added for Historisation
        if (mapPMDispensingPricing.size()> 0) update mapPMDispensingPricing.values();
    }
    
    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
       // blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, METAL_SLEEVE_ACTUATOR));    
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, OVERCAP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));
         
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, ACTUATOR));
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, COLLAR));
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, CAP));
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, DECO_INSERT));
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, COLLAR_DECO));
        blankPMPrices.addAll(getLineDetails(config, null, UPPER_PART_DECO, CAP_DECO));
        
                
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, PBT_BODY));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, PLASTIC_PROTECTION));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, DIPTUBE_LENGTH));
     
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_HOT_STAMPING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_OFFSET));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_SILK_SCREENING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_COLORING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_RING));
        
       /* blankPMPrices.addAll(getLineDetails(config, null, OTHERS, LEAN_OPTIMIZATION));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, DAYS5_LEAD_TIME));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, SKONTO));*/
                
        upsert blankPMPrices ExtId__c;
                
    }    
    
    /**
     * KEY = = <>C33&"_"&D33&"_"&E33&"_"&F33&"_"&G33&"_"&H33&"_"&I33&IF(J33<>0,"_"&J33,"")&IF(K33<>0,"_"&K33,"")
     */ 
    public void createPumpPM() {
        log('*********** createPumpPM ***********LINE='+PUMP);
        if (String.isNotBlank(config.Product_Type__c)) {                
               /* String actuatorValue = '';
                if ('SP34D'.equalsIgnoreCase(config.Engine_Name__c) 
                                && 'Elite'.equalsIgnoreCase(config.Pump_Segmentation__c) 
                                && 'Crimp On'.equalsIgnoreCase(config.Attachment__c) ) {
                     actuatorValue =  'w/o';             
               } else {
                   actuatorValue =  config.Actuator__c;
               }
                                
               String capValue = '';
               if ('Sériplast (Height 40mm)'.equalsIgnoreCase(config.Cap__c)) {
                     capValue =  'Assembled';             
               } else if (overcapPricex250 == 0) {                   
                   capValue =  config.Cap__c;
               } else {
                   capValue =  'w/o';
               } 
                //If not blank, append to Ref                                
               if (capValue != '') {
                     capValue = '_' + capValue;              
               }
               String pumpMaterial = (String.isNotBlank(config.Pump_material__c) ? '_' + config.Pump_material__c : '');                                                
               String purgeRing = '';
               if (String.isNotBlank(config.Purge_Ring__c) && !'0'.equalsIgnoreCase(config.Purge_Ring__c)) {
                    purgeRing = '_'+config.Purge_Ring__c;                
               }
               
            */
                /*String ref = (config.Engine_Name__c == null ? '0' : config.Engine_Name__c) + '_' 
                                + (config.Pump_Segmentation__c == null ? '0' : config.Pump_Segmentation__c) + '_' 
                                + (config.Attachment__c == null ? '0' : config.Attachment__c) + '_' 
                                + (config.Lockability__c == null ? '0' : config.Lockability__c) + '_' 
                                + actuatorValue + '_' + config.Neck_Finish__c + pumpMaterial + '_'
                                + config.Collar__c + capValue + purgeRing;*/
            /*
                String ref = (config.Engine_Name__c == null ? '0' : config.Engine_Name__c) + '_' 
                                + (config.Product_Type__c == null ? '0' : config.Product_Type__c) + '_'
								+ (config.Pack_Name__c == null ? '0' : config.Pack_Name__c) + '_'
								+ (config.Pump_material__c == null ? '0' : config.Pump_material__c) + '_'
								+ (config.Pump_Segmentation__c == null ? '0' : config.Pump_Segmentation__c) + '_' 
                                + (config.Attachment__c == null ? '0' : config.Attachment__c) + '_' 
								+ (config.Neck_Finish__c == null ? '0' : config.Neck_Finish__c) + '_'
								+ (config.Actuator__c == null ? '0' : config.Actuator__c) + '_'
                                + (config.Lockability__c == null ? '0' : config.Lockability__c) + '_' 
								+ (config.Collar__c == null ? '0' :config.Collar__c) + '_'
                                + (config.Purge_Ring__c == null ? '0' :config.Purge_Ring__c ) + '_'
                                + (config.Cap__c == null ? '0' : config.Cap__c );
         new ref Engine name_Product type_Pack name_Material_Pump segmentation_Attachment_Neck finish_Actuator_Lockability_Collar_Purge ring_Cap*/
            String ref = (config.Engine_Name__c == null ? '' : config.Engine_Name__c) + '_' 
                                + (config.Product_Type__c == null ? '' : config.Product_Type__c) + '_'
								+ (config.Pack_Name__c == null ? '' : config.Pack_Name__c) + '_'
								+ (config.Bottle_Material__c == null ? '' : config.Bottle_Material__c) + '_'
                                + (config.Bottle_Volume__c == null ? '' : config.Bottle_Volume__c) + '_'
								+ (config.Pump_Segmentation__c == null ? '' : config.Pump_Segmentation__c) + '_' 
                                + (config.Attachment__c == null ? '' : config.Attachment__c) + '_' 
								+ (config.Neck_Finish__c == null ? '' : config.Neck_Finish__c) + '_'
								+ (config.Actuator__c == null ? '' : config.Actuator__c) + '_'
                                + (config.Lockability__c == null ? '' : config.Lockability__c) + '_' 
								+ (config.Collar__c == null ? '' :config.Collar__c) + '_'
                                + (config.Dosage__c == null ? '' :config.Dosage__c) + '_'
                                + (config.Purge_Ring__c == null ? '' :config.Purge_Ring__c ) + '_'
                                + (config.Cap__c == null ? '' : config.Cap__c );
             //System.debug('before Key = -->' +ref.toUpperCase());
               //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);      
                System.debug('Name Key after verfy= -->' +ref.toUpperCase());  
                                
                PM_Dispensing_Pricing__c pricing = null;
               /* String completePack =  config.Product_Type__c + '_' + config.Pack_Name__c;
                if (String.isNotBlank(config.Pack_Name__c) 
                && (   completePack.endsWithIgnoreCase('Complete Pack_D.N.Airless ø32') 
                    || completePack.endsWithIgnoreCase('Complete Pack_Premia')
                    || completePack.endsWithIgnoreCase('Complete Pack_SOF\'Airless')
                    || completePack.endsWithIgnoreCase('Complete Pack_SOF\'Atmo')
                    || completePack.endsWithIgnoreCase('Complete Pack_D.N.Airless ø41')
                   )) {
                    
                    //log('Complete Pack Key=' + completePack + '_' + ref.toUpperCase());
                    //pricing = mapPMDispensingPricing.get(completePack.toUpperCase() + '_' + ref.toUpperCase());
                       pricing = mapPMDispensingPricing.get( ref.toUpperCase());
                        System.debug('Pricing= -->' +pricing);
                    // Added for Historisation
                    // Create Junction Object
                        
                    if( pricing != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                         Dispensing_Pricing__c = pricing.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                                      '_'+PUMP);
                            listPricingJunctionToUpsert.add(pj);
                    }

                    // Update Prices
                    if (mapPMDispensingPricing.get(completePack.toUpperCase() + '_' + ref.toUpperCase())!= null){
                        mapPMDispensingPricing.get(completePack.toUpperCase() + '_' + ref.toUpperCase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(completePack.toUpperCase() + '_' + ref.toUpperCase()).Line_Name__c = PUMP;
                    }
                }*/
                                
                               
                if (pricing == null) {
                     pricing = mapPMDispensingPricing.get(ref.toUpperCase());   
                      // Added for Historisation
                      // Create Junction Object
                        
                      if( pricing != null){
                            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                         Dispensing_Pricing__c = pricing.Id, 
                                                                         Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                                      '_'+PUMP);
                            listPricingJunctionToUpsert.add(pj);
                      }

                      // Update Prices
                      if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                            mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                                            mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP;
                       }            
                } 

                System.debug('@@@@@ pricing' + pricing);
                listDetailsToUpsert.addAll(getLineDetails(config, pricing, PRODUCT_DEFINITION, PUMP));
               

                
        }
        
              
        
        
    }
 
   /* public void createMetalSleeveActuatorPM() {
      log('*********** createMetalSleeveActuatorPM ***********'); 
        if ('SP34D'.equalsIgnoreCase(config.Engine_Name__c) 
                        && 'Elite'.equalsIgnoreCase(config.Pump_Segmentation__c) 
                        && 'Crimp On'.equalsIgnoreCase(config.Attachment__c) 
                        && !'w/o'.equalsIgnoreCase(config.Actuator__c)) {
                            
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(config.Actuator__c.toUpperCase()), PRODUCT_DEFINITION, METAL_SLEEVE_ACTUATOR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(config.Actuator__c.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+METAL_SLEEVE_ACTUATOR);
                listPricingJunctionToUpsert.add(pj);
            }     
            // Update Prices
            if (mapPMDispensingPricing.get(config.Actuator__c.toUppercase())!= null){
                                    mapPMDispensingPricing.get(config.Actuator__c.toUppercase()).Section__c = PRODUCT_DEFINITION;
                                    mapPMDispensingPricing.get(config.Actuator__c.toUppercase()).Line_Name__c = METAL_SLEEVE_ACTUATOR;
            }          
        
        } 
        
    }*/
    
     /**
     * KEY = <ENGINE NAME>_<>_<CAP>
     */ 
    public void createOvercapPM() {
        log('*********** createOvercapPM ***********LINE='+OVERCAP);
        List<PM_Price_Detail__c> overCapLineDetails = null;
        if (String.isNotBlank(config.Cap__c)) {
             //config.Engine_Name__c + '_' + config.Pump_Segmentation__c + '_' +
            String ref=  config.Cap__c; 
            //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);  
            log('REF=' + ref.toUpperCase());
            PM_Dispensing_Pricing__c pricing = mapPMDispensingPricing.get(ref.toUpperCase());
            overcapPricex250 = (pricing != null && pricing.X250__c != null) ? pricing.X250__c : 0;            
            overCapLineDetails = getLineDetails(config, pricing, PRODUCT_DEFINITION, OVERCAP);    
            // Added for Historisation
            // Create Junction Object
            
            if( pricing != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = pricing.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+OVERCAP);
                listPricingJunctionToUpsert.add(pj);
            }           
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                    mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                                    mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = OVERCAP;
            }  
        } else {
            overCapLineDetails = getLineDetails(config, null, PRODUCT_DEFINITION, OVERCAP);               
            
        }
        log(overCapLineDetails);
        listDetailsToUpsert.addAll(overCapLineDetails);
    }
        
    
    /**
     * KEY = 
     */ 
    public void createBottlePM() {
        log('*********** createBottlePM ***********LINE='+ BOTTLE); 
       /* if (String.isNotBlank(config.Pack_Name__c) 
                        && String.isNotBlank(config.Bottle_Volume__c)) {
                            
            String plant = '';
            if ('SOF\'Airless'.equalsIgnoreCase(config.Pack_Name__c) 
               || 'SOF\'Atmo'.equalsIgnoreCase(config.Pack_Name__c)
               || 'D.N.Airless ø32'.equalsIgnoreCase(config.Pack_Name__c)
               || 'D.N.Airless ø41'.equalsIgnoreCase(config.Pack_Name__c)
               ) {
                   
                   if ('M17-32'.equalsIgnoreCase(config.Neck_Finish__c)) {
                       plant = '_Lacrost';
                   } else {
                      plant = '_Le Tréport';
                   }
                                
            }   */
                            
            //String ref = config.Pack_Name__c + '_' + config.Bottle_Volume__c + plant;
            //Old ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Pump_material__c + '_' + config.Bottle_Volume__c; 
            if(String.isNotBlank(config.Bottle_Volume__c))
            {
            String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c; 
            //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);  
                            
            log('REF=' + ref.toUpperCase());
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, BOTTLE));             
            // Added for Historisation
            // Create Junction Object
           
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+BOTTLE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                    mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                                    mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE;
            } 
        //}        
    }
    }
    
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<ACTUATOR FINISHING>_Actuator color
     */ 
    public void createActuatorPM() {
        log('*********** createActuatorPM ***********LINE='+ACTUATOR);   

       /* if (String.isNotBlank(config.Actuator_Finishing__c)) {
            if (!'Custom'.equalsIgnoreCase(config.Actuator_Finishing__c)) {*/
               /* OLD String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c 
                    + '_' + config.Actuator_Finishing__c + '_Actuator color';*/
                if (String.isNotBlank(config.Actuator_Finishing__c)) {
                String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Actuator_Finishing__c; 
       
               //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);              
                log('REF=' + ref.toUpperCase());
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, ACTUATOR));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                              '_'+ACTUATOR);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = ACTUATOR;
                } 

            /*} else {
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, UPPER_PART_DECO, ACTUATOR), -1));
                
            }*/
        }       
        
    }
    
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<ACTUATOR FINISHING>_Collar color
     */     
    public void createCollarPM() {
        log('*********** createCollarPM ***********LINE='+COLLAR);    
        /*if (String.isNotBlank(config.Collar_Finishing__c)) {
            
            if (!'Custom'.equalsIgnoreCase(config.Collar_Finishing__c)) {
                */
                /* OLD String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c 
                    + '_' + config.Actuator_Finishing__c + '_Collar color';*/
        if (String.isNotBlank(config.Collar_Finishing__c)) {        
        String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Collar_Finishing__c; 
       
                //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);       
                log('REF=' + ref.toUpperCase());
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, COLLAR));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                              '_'+COLLAR);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR;
                } 
            /*} else {
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, UPPER_PART_DECO, COLLAR), -1));
            }*/
        
        }         
        
    }
     public void createCollarDecoPM() {
        log('*********** createCollarDecoPM ***********LINE='+COLLAR_DECO);  
        log('Collar' + config.Collar_Decoration__c+' '+String.isNotBlank(config.Collar_Decoration__c));
       /* if (String.isNotBlank(config.Collar_Decoration__c)) {
            
            if (!'Custom'.equalsIgnoreCase(config.Collar_Decoration__c)) {*/
                //Engine Name_Product Type_Product Name_Material_Volume_Pump Segmentation_Collar decoration
                if (String.isNotBlank(config.Collar_Decoration__c)) {
                String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Collar_Decoration__c; 
       
                 
                ref=VerifyReference(ref);       
                log('REF=' + ref.toUpperCase());
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, COLLAR_DECO));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                              '_'+COLLAR_DECO);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR_DECO;
                } 
           /* } else {
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, UPPER_PART_DECO, COLLAR_DECO), -1));
            }*/
        
        }         
        
    }
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<CAP FINISHING>_Cap color
     */    
    public void createCapPM() {
        log('*********** createCapPM ***********LINE'+ CAP);    
       // if (String.isNotBlank(config.Cap_Finishing__c)) {
            
               /*OLD  String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c 
                    + '_' + config.Cap_Finishing__c + '_Cap color';*/
            if (String.isNotBlank(config.Cap_Finishing__c)) {
            String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Attachment__c
                + '_' + config.Neck_Finish__c+ '_' + config.Actuator__c+ '_' + config.Lockability__c+ '_' + config.Collar__c+ '_' + config.Dosage__c
                + '_' + config.Purge_Ring__c+ '_' + config.Cap__c+ '_' + config.Cap_Finishing__c; 
       
                //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);              
                log('REF=' + ref.toUpperCase());
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, CAP));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                              '_'+CAP);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP;
                } 
       }
        
    }
    public void createCapDecoPM() {
        log('*********** createCapPM ***********LINE'+ CAP_DECO);    
        if (String.isNotBlank(config.Cap_Decoration__c)) {
            
             
            
            String ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Attachment__c
                + '_' + config.Neck_Finish__c+ '_' + config.Actuator__c+ '_' + config.Lockability__c+ '_' + config.Collar__c+ '_' + config.Dosage__c
                + '_' + config.Purge_Ring__c+ '_' + config.Cap__c+ '_' + config.Cap_Decoration__c; 
       
                //added by Amira to eliminate blanc or null values 
                ref=VerifyReference(ref);              
                log('REF=' + ref.toUpperCase());
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, CAP_DECO));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                              '_'+CAP_DECO);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP_DECO;
                } 
        }
        
    }
    /*********************DEBUT MQ ************************************************/     
 /*   public void createCap_HOT_STAMPING() {
        log('*********** createCap_HOT_STAMPING ***********LINE'+ Cap_HOT_STAMPING);
        if(String.isNotBlank(config.Cap_Hot_stamping__c))
        {
        String ref = config.Neck_Finish__c+ config.Cap__c + config.Cap_Hot_stamping__c;
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);  
        log('REF cap hot stamping=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, Cap_HOT_STAMPING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                          '_'+Cap_HOT_STAMPING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = Cap_HOT_STAMPING;
        } 
    }
    }*/
     
     /*
    public void createCOLLAR_LACQUERING() {
        log('*********** createCOLLAR_LACQUERING ***********LINE'+ COLLAR_LACQUERING);
        String ref = config.Neck_Finish__c+ '_' + config.Collar_lacquering__c;
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);  
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, COLLAR_LACQUERING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                          '_'+COLLAR_LACQUERING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR_LACQUERING;
        } 
    }*/
     
    /*
     public void createCOLLAR_HOT_STAMPING_BAND() {
        log('*********** COLLAR_HOT_STAMPING_BAND ***********LINE'+ COLLAR_HOT_STAMPING_BAND);
        String ref = config.Engine_Name__c+config.Neck_Finish__c+config.Collar_Hot_stamping_band__c+'Collar Hot stamping band' ;
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);  
         log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, COLLAR_HOT_STAMPING_BAND));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                          '_'+COLLAR_HOT_STAMPING_BAND);
            listPricingJunctionToUpsert.add(pj);
        }
         // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR_HOT_STAMPING_BAND;
        } 
     }
     */
     /*
     public void createCAP_LACQUERING() {
        log('*********** createCAP_LACQUERING ***********LINE'+ CAP_LACQUERING);
        String ref = config.Neck_Finish__c+ '_' + config.Cap__c + '_' + config.Cap_lacquering__c;
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);  
         log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, CAP_LACQUERING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                          '_'+CAP_LACQUERING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP_LACQUERING;
        } 
     }*/
    /****************************** FIN MQ **********************/
   /**
     * KEY = <ENGINE NAME>_Insert color
     */     
    public void createDecoInsertPM() {
        log('*********** createDecoInsertPM ***********LINE'+DECO_INSERT);
        String ref = '';
        //if (String.isNotBlank(config.Insert_Finishing__c) && 'Non Standard'.equalsIgnoreCase(config.Insert_Finishing__c)) {           
            //OLD ref = config.Engine_Name__c + '_Insert color';   
        if (String.isNotBlank(config.Insert_Coloring__c) ){
            
           log('DecoInsert=' + config.Insert_Coloring__c);
        ref=  config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Pump_Segmentation__c+ '_' + config.Attachment__c
                + '_' + config.Neck_Finish__c+ '_' + config.Actuator__c+ '_' + config.Insert_Coloring__c; 
       
       // } 
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref); 
        
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), UPPER_PART_DECO, DECO_INSERT));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+UPPER_PART_DECO+
                                                                          '_'+DECO_INSERT);
            listPricingJunctionToUpsert.add(pj);
        }    
         // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = UPPER_PART_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = DECO_INSERT;
        } 
        }
    }
    
        
    public void createPbtBodyPM() {
        log('*********** createPbtBodyPM ***********LINE='+ PBT_BODY);    
         String ref = '';
        if (String.isNotBlank(config.PBT_Body__c) && 'Yes - extra cost'.equalsIgnoreCase(config.PBT_Body__c)) {                                                
                ref = 'PBT_BODY_' + config.Engine_Name__c; 
         
        } 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, PBT_BODY));                     
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+PBT_BODY);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PBT_BODY;
        } 
    }
    
    public void createPlasticProtectionPM() {
        log('*********** createPlasticProtectionPM ***********LINE='+PLASTIC_PROTECTION);    
   
         String ref = '';
        if (String.isNotBlank(config.Plastic_Protection__c) && 'Plastic Protection'.equalsIgnoreCase(config.Plastic_Protection__c)) {                                                        
            ref = 'Sleevage_' + config.Engine_Name__c;             
        } 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, PLASTIC_PROTECTION));                            
        // Added for Historisation
        // Create Junction Object 
       
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+PLASTIC_PROTECTION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PLASTIC_PROTECTION;
        } 
    }
    
    public void createDiptubeLengthPM() {
        log('*********** createDiptubeLengthPM ***********LINE='+DIPTUBE_LENGTH);    
        
        String ref = '';
        if (String.isNotBlank(config.Diptube_Length__c) && 'Long tube length (>120mm)'.equalsIgnoreCase(config.Diptube_Length__c)) {           
            
            //=IF(AC33="Yes - extra cost",$C$33,"")                                    
                ref = 'Diptube length_' + config.Engine_Name__c; 
            
        } 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, DIPTUBE_LENGTH));                                    
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+DIPTUBE_LENGTH);
            listPricingJunctionToUpsert.add(pj);
        }
         // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = DIPTUBE_LENGTH;
        } 
    }
    
    /**
     * KEY = <PACK NAME>_<HOT STAMPING>_Decoration
     */    
    public void createBottleHotStampingPM() {
        log('*********** createBottleHotStampingPM ***********LINE='+BOTTLE_HOT_STAMPING);  
        String ref = ''; 
        //if (String.isNotBlank(config.Hot_Stamping__c) && !'No'.equalsIgnoreCase(config.Hot_Stamping__c)) {
           //OLD ref =  config.Pack_Name__c + '_' + config.Hot_Stamping__c + '_Decoration';
        if (String.isNotBlank(config.Hot_Stamping__c))
        {
        ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Hot_Stamping__c;
             
                       
        //}
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref); 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_HOT_STAMPING));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_HOT_STAMPING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_HOT_STAMPING;
        }
        }
    }
    
    /**
     * KEY = <PACK NAME>_<OFFSET>_Decoration
     * 
     */ 
    public void createBottleOffsetPM() {
        log('*********** createBottleOffsetPM ***********LINE='+BOTTLE_OFFSET);    
        String ref = ''; 
        //if (String.isNotBlank(config.Offset__c) && !'No'.equalsIgnoreCase(config.Offset__c)) {
            // OLD ref =  config.Pack_Name__c + '_' + config.Offset__c + '_Decoration';     
             if (String.isNotBlank(config.Offset__c))
             {
           ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Offset__c;
                        
                                                       
        //}
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref); 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_OFFSET));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_OFFSET);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_OFFSET;
        }
             }
    }
    
    /**
     * KEY = <PACK NAME>_<SILK SCREENING>_Decoration
     * 
     */    
    public void createBottleSilkScreeningPM() {
        log('*********** createBottleSilkScreeningPM ***********LINE='+BOTTLE_SILK_SCREENING);    
        String ref = ''; 
       // if (String.isNotBlank(config.Silk_Screening__c) && !'No'.equalsIgnoreCase(config.Silk_Screening__c)) {
            // OLD ref =  config.Pack_Name__c + '_' + config.Silk_Screening__c + '_Decoration';           
            if (String.isNotBlank(config.Silk_Screening__c)){                    
         ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Silk_Screening__c;
                        
                                 
       // }
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_SILK_SCREENING));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_SILK_SCREENING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_SILK_SCREENING;
        }
            }
        
    }

    public void createBottleColoringPM() {
        log('*********** createBottleColoringPM ***********LINE='+BOTTLE_COLORING); 
       /* =IF(AS33=0,"",
            IF(VLOOKUP(AS33,'BACKUP - Lotion'!$AE$21:$AF$32,2,0)="STD",
               "",IF($AS$33="PP Clear",AO33&"_"&AP33&"_"&$AS$33&"_Color",AO33&"_"&AP33&"_Color")))
        */
        String ref = ''; 
       /* if (String.isNotBlank(config.Coloring__c)) {
            for(PM_Dispensing_Config__c  dispensingConfig : [select Coloring_options__c
                                        from PM_Dispensing_Config__c  
                                        where Color__c  = :config.Coloring__c
                                        and  Table_Name__c ='Coloring options'
                                        and Location__c = 'EU'
                                        limit 1]){
                                                            
                log('## Coloring Options :' + config.Coloring__c +  '=' + dispensingConfig.Coloring_options__c);
                                            
                if (!'STD'.equalsIgnoreCase(dispensingConfig.Coloring_options__c)) {
                    if ('PP Clear'.equalsIgnoreCase(config.Coloring__c)) {
                        ref = config.Pack_Name__c + '_' + config.Bottle_Volume__c + '_' + config.Coloring__c + '_Color'; //<PACKNAME>_<VOLUME>_<COLORING>_Color",
                    } else {
                        ref =  config.Pack_Name__c + '_' + config.Bottle_Volume__c + '_Color'; //<PACKNAME>_<VOLUME>_Color"
                    }                     
                }
                                     //       Engine Name_Product Type_Product Name_Material_Volume_Bottle coloring
                          
                                            
            }                                
        }*/
        if (String.isNotBlank(config.Coloring__c)) {
        ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Coloring__c;
                     
        //added by Amira to eliminate blanc or null values 
         ref=VerifyReference(ref);  
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_COLORING));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_COLORING);
            listPricingJunctionToUpsert.add(pj);
        }
         // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_COLORING;
        }
        }
    }
    
    public void createBottleRingPM() {
        log('*********** createBottleRingPM ***********LINE'+ BOTTLE_RING);    
        String ref = '';
       /* if (String.isNotBlank(config.Ring_Coloration__c) && !'Standard'.equalsIgnoreCase(config.Ring_Coloration__c)) {           
            
            if ('Non Standard (Colored)'.equalsIgnoreCase(config.Ring_Coloration__c) 
                                || 'Non Standard (Metallized)'.equalsIgnoreCase(config.Ring_Coloration__c)) {
                                    
                ref = 'Premia'; 
            }      
            
              }*/
        if (String.isNotBlank(config.Ring_Coloration__c))
        {
        ref = config.Engine_Name__c + '_' + config.Product_Type__c + '_' + config.Pack_Name__c + '_' + config.Bottle_Material__c+ '_' + config.Bottle_Volume__c+ '_' + config.Ring_Coloration__c;
        ref=VerifyReference(ref); 
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_RING));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_RING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_RING;
        }
        }
    }
    
    //@Added By riadi zakaria
    
   /* 
    public void createBottleDigitalPrintingPM() {
        log('*********** createBottleDigitalPrinting ***********LINE'+ BOTTLE_DIGITAL_PRINTING);    
        String ref = config.Product_Name__c + '_' + config.Digital_printing__c;
        //        String ref = config.Neck_Finish__c+ '_' + config.Cap__c + '_' + config.Cap_lacquering__c; Product name_Digital printing
        if (String.isNotBlank(config.Digital_printing__c) && !'Standard'.equalsIgnoreCase(config.Digital_printing__c)) {           
            
            if ('Non Standard (Colored)'.equalsIgnoreCase(config.Digital_printing__c) 
                                || 'Non Standard (Metallized)'.equalsIgnoreCase(config.Digital_printing__c)) {
                                    
                ref = 'Premia'; 
            }                                               
        } 
        //added by Amira to eliminate blanc or null values 
        ref=VerifyReference(ref);  
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_DIGITAL_PRINTING));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_DIGITAL_PRINTING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_DIGITAL_PRINTING;
        }
        
    }*/
    /*
    public void createLeanOptimizationPM() {
        log('*********** createLeanOptimizationPM ***********LINE='+LEAN_OPTIMIZATION);  
        if (String.isNotBlank(config.Lean_possibility__c)) {
            for(PM_Dispensing_Config__c  dispensingConfig : [select Upcharge__c 
                                        from PM_Dispensing_Config__c  
                                        where Lean_Possibility__c = :config.Lean_possibility__c
                                        limit 1]){
                                                            
                log('## UPCHARGE : ' + dispensingConfig.Upcharge__c);
                                            
                listDetailsToUpsert.addAll(
                    getLineDetails(config, null, OTHERS, LEAN_OPTIMIZATION));
                    //PMCalculatorUtility.calcGroupDispensing(listDetailsToUpsert, new Set<String>{'APPLY_ZERO_PERCENT'}, config, dispensingConfig.Upcharge__c, OTHERS, LEAN_OPTIMIZATION));
                    //Commented by Arthur Leriche, on met toujours Lean Optimization Ã  zÃ©ro                                             
            }                                
        }
        
    }
    
    public void createDay5LeadTimePM() {
        log('*********** createDay5LeadTimePM ***********LINE='+DAYS5_LEAD_TIME);   
        
        for(PM_Dispensing_Config__c  dispensingConfig : [select Upcharge__c 
                                                         from PM_Dispensing_Config__c  
                                                         where Table_Name__c = '5 Days Lead Time'
                                                         limit 1]){
                                                             
             log('## UPCHARGE : ' + dispensingConfig.Upcharge__c);
            
             if (dispensingConfig.Upcharge__c > 0) {
                listDetailsToUpsert.addAll(setSpecificPriceToZero(
                    PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, dispensingConfig.Upcharge__c, OTHERS, DAYS5_LEAD_TIME)));                                                                                                 
                                                  
             }                                                                                                          
        }                                       
    }
    
    public void createEndOfyearRebatePM() {
        log('*********** createEndOfyearRebatePM ***********');    
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
                    setSpecificPriceToZero(
                        PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, 
                                                                dPercent, OTHERS, END_OF_YEAR_REBATE)));                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }         
        
    }
    */
    public void createSkontoPM() {
        log('*********** calculateSKONTO ***********LINE='+ SKONTO); 
         
       if(qli.DS_Skonto_for_cash_payment__c != null && qli.DS_Skonto_for_cash_payment__c != 'No'){
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupDispensingOther(
                    listDetailsToUpsert, 
                    new Set<String>{'APPLY_ZERO_PERCENT', END_OF_YEAR_REBATE}, 
                    config, 
                    PMCalculatorUtility.calculateSKONTO(qli.Customer_Country__c, qli.DS_Skonto_for_cash_payment__c), 
                    OTHERS, 
                    SKONTO)); 
        }
                                                                                                                                                            
    }//end methode calculateSKONTO        
          
  /*  public List <PM_Price_Detail__c> setSpecificPriceToZero(List <PM_Price_Detail__c> listDetails) {
        for(PM_Price_Detail__c detail : listDetails){
            if (detail.List_Price__c == -1) {
                detail.List_Price__c = 0;
            }
        }  
        return listDetails;
    }*/
  
    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    public List <PM_Price_Detail__c> getLineDetails(PM_Selected_Dipsensing_config__c config, PM_Dispensing_Pricing__c tp, String section, String name){
        List <PM_Price_Detail__c> listDetails;
        if(tp == null){
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0)
            };
        }else{
            
            // Set currency to 1 if zero or blank..
            Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            
            listDetails = new List <PM_Price_Detail__c>{         
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = (tp.X5__c == null? 0 : (tp.X5__c == -1 ? -1 : tp.X5__c * currencyRate))),                
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = (tp.X250__c == null? 0 : (tp.X250__c == -1 ? -1 : tp.X250__c * currencyRate)))
                    
                    
            };
        } 
 
        for(PM_Price_Detail__c detail : listDetails){
            detail.Name = name;
            detail.Section__c = section;
            detail.PM_Selected_Dipsensing_Config__c = config.Id;
            detail.Quote_item__c = config.Quote_item__c;
            detail.ExtId__c = config.Id + name + detail.MOQ_Min__c;
        } 

        return listDetails; 
    } 
 
 public  String VerifyReference(String RefValues)
    { List <String> refVal =RefValues.split('_');
     //System.debug('VERIFY ££££££££££ ' +refVal +' FROM   '+RefValues);
     string ref='';
        for(String refV : refVal)
        {if(refV!='null' && refV!=null && String.isNotBlank(refV))
          {ref=ref+refV+'_';
           //System.debug('INNNNNNNN'+ref);
           }
         }
      
      return ref.removeEnd('_');
    }
    public void log(Object message) {
        System.debug(message);
    }
    
}