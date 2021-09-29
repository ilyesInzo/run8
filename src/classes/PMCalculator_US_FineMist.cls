/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Dispensing Fine Mist
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   05-MAR-2017  Hasseeb 		    Initial version
 *****************************************************************************/ 

public class PMCalculator_US_FineMist {
 	// sections
 	public static final String PRODUCT_DEFINITION = 'Product Definition';
 	public static final String COLORATION_UPCHARGE = 'Coloration Upcharge';
 	public static final String PUMP_OPTIONS = 'Pump Options';
    public static final String BOTTLE_DECO = 'Bottle Decoration Options';     
 	public static final String DIPTUBE_OPTIONS = 'Diptube Options';  
 	public static final String OTHERS = 'Others';
        
 	// SUB-SECTIONS
 	// Product Definition
 	public static final String PUMP = 'Pump';
 	public static final String PUMP_ACTUATOR = 'Separate Actuator';
    public static final String BOTTLE = 'Bottle'; //Added by zakaria riadi
    
    
    // Pump Decoration
 	public static final String PUMP_DECO_ACTUATOR = 'Actuator';
    public static final String PUMP_DECO_COLLAR = 'Collar / Ferrule / Cup';
    public static final String PUMP_DECO_INSERT = 'Insert';
    public static final String PUMP_DECO_CAP = 'Deco Cap';
    


    //PUMP OPTIONS
 	public static final String PANACHE_OPTION = 'Panache option';
 	public static final String HIGH_DOSAGE = 'High Dosage';
    public static final String GASKET_MATERIAL = 'Gasket Material';
    public static final String CAP = 'Cap';

    //Bottle Deco Options
    public static final String BOTTLE_HOT_STAMPING = 'Bottle Hot Stamping';
    public static final String BOTTLE_METALIZATION = 'Bottle Metalization';
    public static final String BOTTLE_SILK_SCREENING = 'Bottle Silk-Screening';
    public static final String BOTTLE_COLORING = 'Bottle Coloring';
    public static final String BOTTLE_SPRAY = 'Bottle Spray Coating';
    
    
    //Diptube Options
 	public static final String DIPTUBE_MATERIAL = 'Diptube Material';
	public static final String DIPTUBE_COLORATION = 'Diptube Coloration'; 
     
    //Others
 	public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
    
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

	public PMCalculator_US_FineMist(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_EU_FineMist start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select createdDate, Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
       
       		/*Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
			log('VERSION='+version);
            log('LOCATION='+config.Location__c);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, version);  */
         
           // Added for Historisation         
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, config.Product_segment__c, dt, false, true);
        }
		
	}

    public void calculate() {
        resetAllPMPrice();
        calculatePUMP();
        calculatePUMP_ACTUATOR();
        createBottlePM();
        
        calculatePUMP_DECO_ACTUATOR();
        calculatePUMP_DECO_COLLAR();
        calculatePUMP_DECO_INSERT();
        calculatePUMP_DECO_CAP();
        
        calculatePANACHE_OPTION();
        calculateHIGH_DOSAGE();
        calculateGASKET_MATERIAL();     
        calculateCAP(); 
        
        //Bottle Deco Options Added by zakaria riadi
        createBottleHotStampingPM(); // Bottle Hot Stamping;
        createBottleSilkScreeningPM(); // Bottle Silk-Screening;
        createBottleColoringPM(); // Bottle Coloring;
        createBottleSprayCoatingPM(); // Bottle Spray Coating;
        createBottleMetalizationPM(); // Bottle Metalization;
        
        calculateDIPTUBE_MATERIAL();
        calculateDIPTUBE_COLORATION();        
        
        calculateEND_OF_YEAR_REBATE();
        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        PMCalculatorUtility.calculateTotalMOQPRice(null, config.Id, config.Quote_item__c);
        // Added for Historisation
        if (mapPMDispensingPricing.size()> 0) update mapPMDispensingPricing.values();
    }
    
    public void calculatePUMP() {
    	log('*********** calculatePUMP ***********LINE='+ PUMP);
        
        log('config.Product_Type__c='+config.Product_Type__c);
        log('config.Product_Name__c='+config.Product_Name__c);
        
        if (String.isNotBlank(config.Product_Type__c) 
            && String.isNotBlank(config.Product_Name__c)
            && !'Separate actuator'.equalsIgnoreCase(config.Product_Type__c)) { 
            String ref= config.Product_Name__c + '_' 
                + config.Product_Type__c + '_' 
                + config.Pump_Segmentation__c + '_'
                + config.Attachment__c + '_'
                + config.Neck_Finish__c + '_'
                + config.Actuator__c + '_'
                + config.Collar__c;
            
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, PUMP));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
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
        
        
        
        
    }   
    
    public void calculatePUMP_ACTUATOR() {
    	log('*********** calculatePUMP_ACTUATOR ***********LINE='+ PUMP_ACTUATOR); 
        log('config.Product_Type__c='+config.Product_Type__c);
        if ('Full Pump (separate actuator)'.equalsIgnoreCase(config.Product_Type__c)
           || 'Separate actuator'.equalsIgnoreCase(config.Product_Type__c)) { 
            String ref= config.Product_Name__c + '_Separate actuator_'               
                + config.Pump_Segmentation__c + '_'
                + config.Attachment__c + '_'
                + config.Neck_Finish__c + '_'
                + config.Actuator__c + '_'
                + config.Collar__c;
            
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, PUMP_ACTUATOR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
               PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+PUMP_ACTUATOR);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_ACTUATOR;
            }
        }                
    }  
        
    public void calculatePUMP_DECO_ACTUATOR() {
    	log('*********** calculatePUMP_DECO_ACTUATOR ***********LINE='+ PUMP_DECO_ACTUATOR); 
        log('Actuator='+config.Actuator__c + '|ActuatorFinishing='+config.Actuator_Finishing__c );
        if (String.isNotBlank(config.Actuator__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Actuator__c + '_'
                + config.Actuator_Finishing__c;
            
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, PUMP_DECO_ACTUATOR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+PUMP_DECO_ACTUATOR);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_DECO_ACTUATOR;
            }
        } 
    } 
    
    public void calculatePUMP_DECO_COLLAR() {
    	log('*********** calculatePUMP_DECO_COLLAR ***********LINE='+ PUMP_DECO_COLLAR); 
        log('Cap/Collar='+config.Collar__c + '|Colalr or Cup='+config.Collar_or_Cup_Finish__c );
        if (String.isNotBlank(config.Actuator__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Actuator__c + '_'
                + config.Collar__c + '_'
                + config.Collar_or_Cup_Finish__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, PUMP_DECO_COLLAR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+PUMP_DECO_COLLAR);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_DECO_COLLAR;
            }
        }         
        
        
    } 
    
    public void calculatePUMP_DECO_INSERT() {
    	log('*********** calculatePUMP_DECO_INSERT ***********LINE='+ PUMP_DECO_INSERT); 
        log('INSERT='+config.Insert_Type__c + '|INSERTCOLORING='+config.Insert_Coloring__c );
        if (String.isNotBlank(config.Actuator__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Actuator__c + '_'
                + config.Insert_Type__c + '_'
                + config.Insert_Coloring__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, PUMP_DECO_INSERT));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+PUMP_DECO_INSERT);
                listPricingJunctionToUpsert.add(pj); 
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_DECO_INSERT;
            }
        }  


    } 
    
    //Added by zakaria riadi
    public void calculatePUMP_DECO_CAP() {
        log('*********** calculatePUMP_DECO_CAP ***********LINE='+ PUMP_DECO_CAP); 
       log('INSERT='+config.Collar__c + '|INSERTCOLORING='+config.Cap_Finishing__c );
        if (String.isNotBlank(config.Actuator__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Collar__c + '_'
                + config.Cap_Finishing__c;
            system.debug('REF='+ref); 
            PM_Dispensing_Pricing__c oPricing = mapPMDispensingPricing.get(ref.toUpperCase());
            if (oPricing == null) {
                ref= config.Cap_Type__c + '_'               
                            + config.Neck_Finish__c + '_'
                            + config.Cap_Finishing__c;
                system.debug('REF='+ref);
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, PUMP_DECO_CAP));             
            } else {
                listDetailsToUpsert.addAll(getLineDetails(config, oPricing, COLORATION_UPCHARGE, PUMP_DECO_CAP));              
            }            
            
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = oPricing!=null?oPricing:mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+PUMP_DECO_CAP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_DECO_CAP;
            }

            system.debug('REF='+ref);
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, PUMP_DECO_CAP));             
            
        }        
        
    }   

    //PUMP OPTIONS
 
    public void calculatePANACHE_OPTION() {
    	log('*********** calculatePANACHE_OPTION ***********LINE='+ PANACHE_OPTION); 
        if (String.isNotBlank(config.Insert_Type__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Product_Type__c + '_'
                + config.Attachment__c + '_'
                + config.Insert_Type__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, PANACHE_OPTION));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+PANACHE_OPTION);
                listPricingJunctionToUpsert.add(pj); 
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PANACHE_OPTION;
            }
        }         
        
        
    }     
    
    public void calculateHIGH_DOSAGE() {
    	log('*********** calculateHIGH_DOSAGE ***********LINE='+ HIGH_DOSAGE); 
        if (String.isNotBlank(config.Dosage__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Product_Type__c + '_'
                + config.Insert_Type__c + '_'
                + config.Dosage__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, HIGH_DOSAGE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+HIGH_DOSAGE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = HIGH_DOSAGE;
            }
        }         
        
    }  
     
    public void calculateGASKET_MATERIAL() {
    	log('*********** calculateGASKET_MATERIAL ***********LINE='+ GASKET_MATERIAL); 
        if (String.isNotBlank(config.Gasket_Material__c)) { 
            String ref= config.Product_Name__c + '_'               
                + config.Gasket_Material__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, GASKET_MATERIAL));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+GASKET_MATERIAL);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = GASKET_MATERIAL;
            }
        }                 
        
    } 
    
    public void calculateCAP() {
    	log('*********** calculateCAP ***********LINE='+ CAP); 
        if (String.isNotBlank(config.Cap_Type__c)) { 
            String ref = '';
            if ('ABS941'.equalsIgnoreCase(config.Product_Name__c)) {
                ref = 'ABS941';
            } else {
                ref = config.Product_Name__c + '_'               
                + config.Product_Type__c + '_'
                + config.Pump_Segmentation__c + '_'
                + config.Attachment__c + '_'
                + config.Neck_Finish__c + '_'
                + config.Actuator__c + '_'
                + config.Collar__c; 
            }

			ref += '_' + config.Cap_Type__c;            
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, CAP));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+CAP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP;
            }
        }        
        
        
    }      
 
    //@Added By zakaria riadi
        public void createBottlePM() {
        log('*********** createBottlePM ***********LINE='+ BOTTLE); 
        if (String.isNotBlank(config.Product_Name__c) && String.isNotBlank(config.Product_Type__c) 
                        && String.isNotBlank(config.Bottle_Volume__c)) {   
                            
            String ref = config.Product_Name__c + '_' + config.Product_Type__c + '_' + config.Bottle_Volume__c; 
                            
            log('REF=' + ref.toUpperCase());
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, BOTTLE));             
            // Added for Historisation
            // Create Junction Object
           
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+ BOTTLE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                    mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                                    mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE;
            } 
        }        
    }
    
    
    //Bottle Deco Options 
    
    
    
        /**
     * KEY = <PACK NAME>_<HOT STAMPING>_Decoration
     */    
    public void createBottleHotStampingPM() {
        log('*********** createBottleHotStampingPM ***********LINE='+BOTTLE_HOT_STAMPING);  
        String ref = ''; 
        if (String.isNotBlank(config.Hot_Stamping__c) && !'No'.equalsIgnoreCase(config.Hot_Stamping__c)) {
            ref =  config.Product_Name__c + '_' + config.Product_Type__c + '_' + config.Hot_Stamping__c + '_Decoration' ;           
                                 
        }
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_HOT_STAMPING));
        log('AC' + listDetailsToUpsert);
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        log('ACH00:' + dp);
        if( dp != null){
            log('ACH01');
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
    
    /**
     * KEY = <PACK NAME>_<SILK SCREENING>_Decoration
     * 
     */    
    public void createBottleSilkScreeningPM() {
        log('*********** createBottleSilkScreeningPM ***********LINE='+BOTTLE_SILK_SCREENING);    
        String ref = ''; 
        if (String.isNotBlank(config.Silk_Screening__c) && !'No'.equalsIgnoreCase(config.Silk_Screening__c)) {
            ref =  config.Product_Name__c + '_' + config.Product_Type__c + '_' + config.Silk_Screening__c + '_Decoration';           
                                 
        }
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
    
    /**
     * KEY = <PACK NAME>_<Coloring>_Decoration
     * 
     */  

    public void createBottleColoringPM() {
        log('*********** createBottleColoringPM ***********LINE='+BOTTLE_COLORING); 
       /* =IF(AS33=0,"",
            IF(VLOOKUP(AS33,'BACKUP - Lotion'!$AE$21:$AF$32,2,0)="STD",
               "",IF($AS$33="PP Clear",AO33&"_"&AP33&"_"&$AS$33&"_Color",AO33&"_"&AP33&"_Color")))
        */
        String ref = ''; 
        if (String.isNotBlank(config.Coloring__c)) {
            /*for(PM_Dispensing_Config__c  dispensingConfig : [select Coloring_options__c
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
                                            
                                            
            }*/  
            
            ref = config.Product_Name__c + '_' + config.Bottle_Volume__c + '_' + config.Coloring__c + '_Color';
        }
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
    
    /**
     * KEY = <PACK NAME>_<METALIZATION>_Decoration
     * 
     */  
    public void createBottleMetalizationPM() {
        log('*********** createBottleMetalizationPM ***********LINE='+BOTTLE_METALIZATION);    
        String ref = ''; 
        if (String.isNotBlank(config.Bottle_Metalization__c) && !'No'.equalsIgnoreCase(config.Bottle_Metalization__c)) {
            ref =  config.Product_Name__c + '_' + config.Product_Type__c + '_' + config.Bottle_Metalization__c + '_METALIZATION';           
                                 
        }
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_METALIZATION));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_METALIZATION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_METALIZATION;
        }
        
    }
    
    /**
     * KEY = <PACK NAME>_<SPRAY COATING>_Decoration
     * 
     */  
    public void createBottleSprayCoatingPM() {
        log('*********** createBottleSprayCoatingPM ***********LINE='+BOTTLE_SPRAY);    
        String ref = ''; 
        if (String.isNotBlank(config.Spray_Coating__c) && !'No'.equalsIgnoreCase(config.Spray_Coating__c)) {
            ref =  config.Product_Name__c + '_' + config.Product_Type__c + '_' + config.Spray_Coating__c + '_SPRAY';           
                                 
        }
        log('REF=' + ref.toUpperCase());
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_DECO, BOTTLE_SPRAY));             
        // Added for Historisation
        // Create Junction Object 
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_SPRAY);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_DECO;
                                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_SPRAY;
        }
        
    }
    
    
    

    //Diptube Options
    
    public void calculateDIPTUBE_MATERIAL() {
    	log('*********** calculateDIPTUBE_MATERIAL ***********LINE='+ DIPTUBE_MATERIAL); 
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
        
        if (String.isNotBlank(config.Diptube_Material__c)) { 
            
            String ref= '';
            Decimal diptubeLength = 0;
            if (String.isNotBlank(config.Diptube_Length__c)) {
               ref= 'INCH_';
               diptubeLength = Decimal.valueOf(config.Diptube_Length__c);
            } else if (String.isNotBlank(config.Diptube_length_mm__c)) {
            	ref= 'MM_';
                diptubeLength = Decimal.valueOf(config.Diptube_length_mm__c);
                system.debug('Optional (Invisible) - MM');
            }
            
            ref += config.Product_Name__c + '_'               
                + config.Diptube_Material__c;
             
            system.debug('REF='+ref);
            List<PM_Price_Detail__c> details = 
           		getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), DIPTUBE_OPTIONS, DIPTUBE_MATERIAL);             
            
            if ('Optional (Transparent TPX)'.equalsIgnoreCase(config.Diptube_Material__c)) {
                system.debug('Optional (Transparent TPX) - No calculation needed...Just fetch');
                for (PM_Price_Detail__c detail: details) {
                    //If price not found, set to Specific
                    if (detail.List_Price__c == 0) {
                        detail.List_Price__c = -1; 
                    } else {
                    	system.debug(detail.List_Price__c + '__' + diptubeLength);
                    	detail.List_Price__c = detail.List_Price__c * diptubeLength/10;                        
                    }

                }   
                
            } else if ('Optional (Invisible)'.equalsIgnoreCase(config.Diptube_Material__c)) {                
                 //Added by MQ ==> Lot2 Invisible diptube
                //calculate multiplicator
                system.debug('@@qama currencyRate '+currencyRate);
                system.debug('@@qama  config.Merged_Diptube_Material_Length__c  '+ config.Merged_Diptube_Material_Length__c);
                
                Decimal diptubeMaterialprice  =currencyRate * (config.Merged_Diptube_Material_Length__c==null ? 0 :  config.Merged_Diptube_Material_Length__c)/10;
                
                //Get fees from pricing table
                List<PM_Price_Detail__c>  liFees 		 = getLineDetails(config, mapPMDispensingPricing.get('Optionnal (invisible)_Fees'.toUpperCase())        , DIPTUBE_OPTIONS, DIPTUBE_MATERIAL);
                List<PM_Price_Detail__c>  liPricePerUnit = getLineDetails(config, mapPMDispensingPricing.get('Optionnal (invisible)_PricePerUnit'.toUpperCase()), DIPTUBE_OPTIONS, DIPTUBE_MATERIAL);
                liPricePerUnit  = PMCalculatorUtility.setPriceMultiplier(liPricePerUnit, (double)diptubeMaterialprice) ;
                   			    
                System.debug('@@qama liFees '+liFees);
                System.debug('@@qama liPricePerUnit '+liPricePerUnit);   
                                 
                listDetailsToUpsert.addAll( PMCalculatorUtility.calculateMultiplicationOfTwoLists(liFees,liPricePerUnit) );
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get('Optionnal (invisible)_Fees'.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+DIPTUBE_OPTIONS+
                                                                              '_'+DIPTUBE_MATERIAL);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get('Optionnal (invisible)_Fees'.toUppercase())!= null){
                    mapPMDispensingPricing.get('Optionnal (invisible)_Fees'.toUppercase()).Section__c = DIPTUBE_OPTIONS;
                    mapPMDispensingPricing.get('Optionnal (invisible)_Fees'.toUppercase()).Line_Name__c = DIPTUBE_MATERIAL;
                }
                PM_Dispensing_Pricing__c dp2 = mapPMDispensingPricing.get('Optionnal (invisible)_PricePerUnit'.toUpperCase());
                if( dp2 != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp2.Id, 
                                                                 Unique_Key__c = config.Id+'_'+DIPTUBE_OPTIONS+
                                                                              '_'+DIPTUBE_MATERIAL+'_2');
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get('Optionnal (invisible)_PricePerUnit'.toUppercase())!= null){
                    mapPMDispensingPricing.get('Optionnal (invisible)_PricePerUnit'.toUppercase()).Section__c = DIPTUBE_OPTIONS;
                    mapPMDispensingPricing.get('Optionnal (invisible)_PricePerUnit'.toUppercase()).Line_Name__c = DIPTUBE_MATERIAL;
                }
                

                return;
                
                
            }//end if optionnal invisible
            listDetailsToUpsert.addAll(details);
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+DIPTUBE_OPTIONS+
                                                                          '_'+DIPTUBE_MATERIAL);
                listPricingJunctionToUpsert.add(pj);
            }
            system.debug(details);
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = DIPTUBE_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = DIPTUBE_MATERIAL;
            }
            
            
            
        }   
    }

    public void calculateDIPTUBE_COLORATION() {
    	log('*********** calculateDIPTUBE_COLORATION ***********LINE='+ DIPTUBE_COLORATION); 
        if (String.isNotBlank(config.Colored_Diptube__c)) { 
            String ref= config.Product_Name__c + '_'   
                + config.Attachment__c  + '_'
                + config.Colored_Diptube__c;
             
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), DIPTUBE_OPTIONS, DIPTUBE_COLORATION));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+DIPTUBE_OPTIONS+
                                                                          '_'+DIPTUBE_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = DIPTUBE_OPTIONS;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = DIPTUBE_COLORATION;
            }
        } 
    }    
    

    //Others
    public void  calculateEND_OF_YEAR_REBATE() {
    	log('*********** calculateEND_OF_YEAR_REBATE ***********LINE='+ END_OF_YEAR_REBATE);    
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
                    PMCalculatorUtility.setSpecificPriceToZero(
                    	PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, 
                                                                dPercent, OTHERS, END_OF_YEAR_REBATE)));
                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }         
        
    }
    
    

    public void resetAllPMPrice() {       
        
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP_ACTUATOR));  
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));
        
        
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, PUMP_DECO_ACTUATOR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, PUMP_DECO_COLLAR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, PUMP_DECO_INSERT));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, PUMP_DECO_CAP));        

        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_HOT_STAMPING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_METALIZATION));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_SILK_SCREENING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_COLORING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_SPRAY));
        
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, PANACHE_OPTION));    
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, HIGH_DOSAGE));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, GASKET_MATERIAL));
     	blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, CAP));
        
        blankPMPrices.addAll(getLineDetails(config, null, DIPTUBE_OPTIONS, DIPTUBE_MATERIAL));
        blankPMPrices.addAll(getLineDetails(config, null, DIPTUBE_OPTIONS, DIPTUBE_COLORATION));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
         
        for(PM_Price_Detail__c pp:blankPMPrices){
            System.debug('@@@ZakExtid'+pp.ExtId__c);
            
            }
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
    public List <PM_Price_Detail__c> getLineDetails(PM_Selected_Dipsensing_config__c config, PM_Dispensing_Pricing__c tp, String section, String name){
    	List <PM_Price_Detail__c> listDetails;
    	if(tp == null){
    		listDetails = new List <PM_Price_Detail__c>{
				new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0)/*,
				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0)*/
			};
    	}else{
			Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            
    		listDetails = new List <PM_Price_Detail__c>{
				new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
				new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
				new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate)))/*,
				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = (tp.X250__c == null? 0 : (tp.X250__c == -1 ? -1 : tp.X250__c * currencyRate)))       */                         
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

    public void log(Object message) {
        System.debug(message);
    }
    
}