/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Dispensing Foam Pump
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   25-Apr-2017  Hasseeb             Initial version
 *****************************************************************************/ 

public class PMCalculator_EU_FoamPump {
    
    //Fill in values between 1-100. The default is zero as in the excel sheet
    public static final Integer AERO_OPTIMIZATION_PERCENTAGE = 0;
    public static final Integer DAYS5_LEAD_TIME_PERCENTAGE = 0;
    
     
    // sections
    public static final String PRODUCT_DEFINITION = 'Product Definition';
    public static final String PUMP_BOTTLE_DECORATION = 'Pump Bottle Decoration';
    public static final String PRINTING_UPCHARGE = 'Printing Upcharge';
    public static final String OTHERS = 'Others';
        
    public static final String PUMP = 'Pump';
    public static final String PUMP_MATERIAL = 'Pump material';
    public static final String BOTTLE = 'Bottle';
    public static final String SLEEVED_PUMP_UPCHARGE = 'Sleeved Pump upcharge';
    public static final String BALL_SPRING = 'Ball & Spring';
    public static final String HIGH_FORCE = 'High Force';
    public static final String CAP = 'Cap';
    public static final String HOLDER_CASING = 'Holder-Casing';
    public static final String CLIP = 'Clip';
    public static final String FOAM_QUALITY = 'Foam Quality'; //Added by maryem qada for Velvet option 06/11/2017
    
    public static final String ACTUATOR = 'Actuator';
    public static final String COLLAR = 'Collar';
    public static final String CAP_HOLDER_CASING = 'Cap / Holder Casing';
    public static final String BOTTLE_COLORATION = 'Bottle Coloration';
    
    public static final String SILK_SCREENING_ROUND_BOTTLE = 'Silk-Screening (Round Bottle)';
    public static final String SILK_SCREENING_BOTTLE_FRONT = 'Silk-Screening (Bottle Front)';
    public static final String SILK_SCREENING_BOTTLE_BACK = 'Silk-Screening (Bottle Back)';
    public static final String HOT_STAMPING_PUMP = 'Hot-Stamping Pump';
    public static final String HOT_STAMPING_BOTTLE = 'Hot-Stamping Bottle';
    
    public static final String DAYS5_LEAD_TIME = '5 days Lead Time';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
    public static final String SKONTO = 'Skonto';
    
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

    public PMCalculator_EU_FoamPump(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_EU_FoamPump start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
       
            /*Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
            log('VERSION='+version);
            log('LOCATION='+config.Location__c);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReferenceProductSegmentOrder(config.Location__c, version, 'Foam pumps');  */
            
            // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, config.Product_segment__c, dt, true, true);
			
        }
        
    }

    public void calculate() {
        resetAllPMPrice();
        calculatePUMP();
        calculatePUMP_MATERIAL();
        calculateFOAMQUALITY();
        calculateBOTTLE();
        calculateSLEEVED_PUMP_UPCHARGE() ;
        calculateBALL_SPRING ();
        calculateHIGH_FORCE();
        calculateCAP();
        calculateHOLDER_CASING();
        calculateCLIP();
        calculateACTUATOR();
        calculateCOLLAR();
        calculateCAP_HOLDER_CASING();
        calculateBOTTLE_COLORATION();
        calculateSILK_SCREENING_ROUND_BOTTLE();
        calculateSILK_SCREENING_BOTTLE_FRONT();
        calculateSILK_SCREENING_BOTTLE_BACK();
        calculateHOT_STAMPING_PUMP();
        calculateHOT_STAMPING_BOTTLE();
        calculateDAYS5_LEAD_TIME();
        calculateEND_OF_YEAR_REBATE();
        calculateSKONTO();
        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        
        PMCalculatorUtility.calculateTotalMOQPRice(null, config.Id, config.Quote_item__c);
        // Added for Historisation
        if (mapPMDispensingPricing.size()> 0) update mapPMDispensingPricing.values();
    }
    
    public void calculatePUMP() {
        log('*********** calculatePUMP ***********'); 
        if(String.isNotBlank(config.Product_Hierarchy__c)){
            String ref =  config.Product_Hierarchy__c +'_'+ config.pump_material__c;
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
    
    //calculate PUMP MATERIAL==> NEW OPTION 31/08/2018 MQ    
    public void calculatePUMP_MATERIAL() {
        log('*********** calculatePUMP_MATERIAL ***********'); 
        //if(String.isNotBlank(config.pump_material__c)){
            String ref =  config.Product_Hierarchy__c+config.pump_material__c+'Pump material';
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, PUMP_MATERIAL));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+PUMP_MATERIAL);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = PUMP_MATERIAL;
            } 
        //}          
    }
    
    //Added by maryem qada for Velvet option 06/11/2017
    public void calculateFOAMQUALITY() {
        log('*********** calculateFOAMQUALITY ***********'); 
        if(String.isNotBlank(config.Foam_Quality__c)){
            String ref =  config.Product_Hierarchy__c+config.Foam_Quality__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, FOAM_QUALITY));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+FOAM_QUALITY);
                listPricingJunctionToUpsert.add(pj);
            }        
             // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = FOAM_QUALITY;
            } 
        }          
    }
    
    public void calculateBOTTLE() {
        log('*********** calculateBOTTLE ***********'); 
        if(String.isNotBlank(config.Bottle_Size__c) 
                            && String.isNotBlank(config.Material__c) 
                            && String.isNotBlank(config.Bottle_Name__c)){
            String ref =  config.Bottle_Name__c + config.Material__c + config.Bottle_Size__c;
            system.debug('REF='+ref); 
            system.debug('mapPMDispensingPricing='+mapPMDispensingPricing.get(ref.toUpperCase())); 
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
        }                  
        
    }
    public void calculateSLEEVED_PUMP_UPCHARGE() {
        log('*********** calculateSLEEVED_PUMP_UPCHARGE ***********'); 
        if('Yes'.equalsIgnoreCase(config.Sleeved_Pump__c)){
            String ref =  config.Product_Hierarchy__c + 'Sleeved Pump';
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, SLEEVED_PUMP_UPCHARGE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+SLEEVED_PUMP_UPCHARGE);
                listPricingJunctionToUpsert.add(pj);
            }     
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = SLEEVED_PUMP_UPCHARGE;
            } 
        }  

    }
    
    
    public void calculateBALL_SPRING () {
        log('*********** calculateBALL_SPRING ***********'); 
        if(String.isNotBlank(config.Engine_Type__c)){
            //String ref =  config.Product_Hierarchy__c + config.Engine_Type__c + config.Ball_Spring__c;
             String ref =   config.Engine_Type__c + config.Ball_Spring__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, BALL_SPRING));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+BALL_SPRING);
                listPricingJunctionToUpsert.add(pj);
            }   
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BALL_SPRING;
            } 
        }         
        
    }
    public void calculateHIGH_FORCE() {
        log('*********** calculateHIGH_FORCE ***********'); 
        if('Yes'.equalsIgnoreCase(config.High_Force__c)){
            String ref =  config.Product_Hierarchy__c + config.Engine_Type__c + 'High force';
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, HIGH_FORCE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+HIGH_FORCE);
                listPricingJunctionToUpsert.add(pj);
            }       
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = HIGH_FORCE;
            } 
        }         
    }

    public void calculateCAP() {
        log('*********** calculateCAP ***********'); 
        if(String.isNotBlank(config.Cap__c)){
            String ref =  config.Product_Hierarchy__c + 'Overcap' + config.Cap__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, CAP));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+CAP);
                listPricingJunctionToUpsert.add(pj);
            }    
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP;
            }  
        }        
    }

    public void calculateHOLDER_CASING() {
        log('*********** calculateHOLDER_CASING ***********'); 
        if(String.isNotBlank(config.Holder_Casing__c)){
            String ref =  config.Product_Hierarchy__c + config.Holder_Casing__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, HOLDER_CASING));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+HOLDER_CASING);
                listPricingJunctionToUpsert.add(pj);
            }       
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = HOLDER_CASING;
            }  
        }                
    }
    
    public void calculateCLIP() {
        log('*********** calculateCLIP ***********'); 
        if(String.isNotBlank(config.Clip__c) && !'No'.equalsIgnoreCase(config.Clip__c)){
            String ref =  config.Product_Hierarchy__c + config.Clip__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRODUCT_DEFINITION, CLIP));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+CLIP);
                listPricingJunctionToUpsert.add(pj);
            }      
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRODUCT_DEFINITION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CLIP;
            } 
        }                
    }
    
    public void calculateACTUATOR() {
        log('*********** calculateACTUATOR ***********'); 
        if(String.isNotBlank(config.Actuator_coloring__c)){
           // String ref =  config.Product_Hierarchy__c + 'Nozzle' + config.Actuator_coloring__c; //modifier la ref inclure actuator +product hierarchy
            String ref =  config.Product_Hierarchy__c +   config.Actuator__c+ config.Actuator_coloring__c+'Nozzle' ;
           
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_BOTTLE_DECORATION, ACTUATOR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_BOTTLE_DECORATION+
                                                                          '_'+ACTUATOR);
                listPricingJunctionToUpsert.add(pj);
            }      
             // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_BOTTLE_DECORATION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = ACTUATOR;
            } 
        }          
    }

    public void calculateCOLLAR() {
        log('*********** calculateCOLLAR ***********'); 
        if(String.isNotBlank(config.Collar_Decoration__c)){
            String ref =  config.Product_Hierarchy__c + 'Basecap' + config.Collar_Decoration__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_BOTTLE_DECORATION, COLLAR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_BOTTLE_DECORATION+
                                                                          '_'+COLLAR);
                listPricingJunctionToUpsert.add(pj);
            }      
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_BOTTLE_DECORATION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR;
            }  
        }                 
    }
    
    public void calculateCAP_HOLDER_CASING() {
        log('*********** calculateCAP_HOLDER_CASING ***********'); 
        if(String.isNotBlank(config.Cap_Decoration__c)){
            String ref =  config.Product_Hierarchy__c + 'Overcap' + config.Cap_Decoration__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_BOTTLE_DECORATION, CAP_HOLDER_CASING));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_BOTTLE_DECORATION+
                                                                          '_'+CAP_HOLDER_CASING);
                listPricingJunctionToUpsert.add(pj);
            }        
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_BOTTLE_DECORATION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP_HOLDER_CASING;
            }  
        }          
    }

    public void calculateBOTTLE_COLORATION() {
        log('*********** calculateBOTTLE_COLORATION ***********'); 
        if('Custom Color'.equalsIgnoreCase(config.Coloring__c)){
            listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, PUMP_BOTTLE_DECORATION, BOTTLE_COLORATION), -1));
        } else if('Coloured'.equalsIgnoreCase(config.Coloring__c)){
            String ref =  'Bottle' + config.Bottle_Name__c + config.Material__c + config.Bottle_Size__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_BOTTLE_DECORATION, BOTTLE_COLORATION));                         
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_BOTTLE_DECORATION+
                                                                          '_'+BOTTLE_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_BOTTLE_DECORATION;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_COLORATION;
            } 
        }        
    }
    
    
    public void calculateSILK_SCREENING_ROUND_BOTTLE() {
        log('*********** calculateSILK_SCREENING_ROUND_BOTTLE ***********'); 
        if(String.isNotBlank(config.Silk_Screening__c)){
            String ref =  'Bottle_' + config.Silk_Screening__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRINTING_UPCHARGE, SILK_SCREENING_ROUND_BOTTLE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRINTING_UPCHARGE+
                                                                          '_'+SILK_SCREENING_ROUND_BOTTLE);
                listPricingJunctionToUpsert.add(pj);
            }     
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRINTING_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = SILK_SCREENING_ROUND_BOTTLE;
            }  
        }         
        
    }
    public void calculateSILK_SCREENING_BOTTLE_FRONT() {
        log('*********** calculateSILK_SCREENING_BOTTLE_FRONT ***********'); 
        if(String.isNotBlank(config.Silk_Screening_Front__c)){
            String ref =  'Front_' + config.Silk_Screening_Front__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRINTING_UPCHARGE, SILK_SCREENING_BOTTLE_FRONT));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRINTING_UPCHARGE+
                                                                          '_'+SILK_SCREENING_BOTTLE_FRONT);
                listPricingJunctionToUpsert.add(pj);
            }    
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRINTING_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = SILK_SCREENING_BOTTLE_FRONT;
            }   
        }         
        
    }
    public void calculateSILK_SCREENING_BOTTLE_BACK() {
        log('*********** calculateSILK_SCREENING_BOTTLE_BACK ***********'); 
        if(String.isNotBlank(config.Silk_Screening_Back__c)){
            String ref =  'Back_' + config.Silk_Screening_Back__c;
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRINTING_UPCHARGE, SILK_SCREENING_BOTTLE_BACK));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRINTING_UPCHARGE+
                                                                          '_'+SILK_SCREENING_BOTTLE_BACK);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRINTING_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = SILK_SCREENING_BOTTLE_BACK;
            }       
        }         
    }
    public void calculateHOT_STAMPING_PUMP() {
        log('*********** calculateHOT_STAMPING_PUMP ***********');
        if('Yes'.equalsIgnoreCase(config.Hot_Stamping__c)){
            String ref =  config.Product_Hierarchy__c + 'Hot_Stamping_Yes';
            system.debug('REF HS PUMP ='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRINTING_UPCHARGE, HOT_STAMPING_PUMP));
            //PMCalculatorUtility.setListPrice(
            //    getLineDetails(config, null, PRINTING_UPCHARGE, HOT_STAMPING_PUMP), -1);
            
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRINTING_UPCHARGE+
                                                                          '_'+HOT_STAMPING_PUMP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRINTING_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = HOT_STAMPING_PUMP;
            }    
        }        
    }

    public void calculateHOT_STAMPING_BOTTLE() {
        log('*********** calculateHOT_STAMPING_BOTTLE ***********'); 
        if('Yes'.equalsIgnoreCase(config.Bottle_Hot_Stamping__c)){
            String ref =  config.Bottle_Name__c + config.Material__c + config.Bottle_Size__c + 'Hot_Stamping_Yes';
            system.debug('REF HS BOTTLE ='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PRINTING_UPCHARGE, HOT_STAMPING_BOTTLE));
            //PMCalculatorUtility.setListPrice(
            //    getLineDetails(config, null, PRINTING_UPCHARGE, HOT_STAMPING_BOTTLE), -1);
            

            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRINTING_UPCHARGE+
                                                                          '_'+HOT_STAMPING_BOTTLE);
                listPricingJunctionToUpsert.add(pj);
            }      
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                        mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PRINTING_UPCHARGE;
                        mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = HOT_STAMPING_BOTTLE;
            }    
        }         
    }
    
    public void calculateDAYS5_LEAD_TIME() {
        log('*********** calculateDAYS5_LEAD_TIME ***********LINE='+ DAYS5_LEAD_TIME); 
         
        if (DAYS5_LEAD_TIME_PERCENTAGE > 0) { 
            listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, 
                                                                DAYS5_LEAD_TIME_PERCENTAGE/100, OTHERS, DAYS5_LEAD_TIME));            
             
        }        
    }
    public void calculateEND_OF_YEAR_REBATE() {
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
                    setSpecificPriceToZero(
                        PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, 
                                                                dPercent, OTHERS, END_OF_YEAR_REBATE)));                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }         
        
        
    } 

    public void calculateSKONTO() {
        log('*********** calculateSKONTO ***********LINE='+ SKONTO); 
        // Skonto
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
        
    }     




    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, FOAM_QUALITY)); //added by maryem qada for velvet option
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));    
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, SLEEVED_PUMP_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BALL_SPRING));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, HIGH_FORCE));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, CAP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, HOLDER_CASING));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, CLIP));

        blankPMPrices.addAll(getLineDetails(config, null, PUMP_BOTTLE_DECORATION, ACTUATOR));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_BOTTLE_DECORATION, COLLAR));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_BOTTLE_DECORATION, CAP_HOLDER_CASING));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_BOTTLE_DECORATION, BOTTLE_COLORATION));
              
     
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING_UPCHARGE, SILK_SCREENING_ROUND_BOTTLE));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING_UPCHARGE, SILK_SCREENING_BOTTLE_FRONT));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING_UPCHARGE, SILK_SCREENING_BOTTLE_BACK));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING_UPCHARGE, HOT_STAMPING_PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING_UPCHARGE, HOT_STAMPING_BOTTLE));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, DAYS5_LEAD_TIME));     
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, SKONTO));
            
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
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
 				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0),
 				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 0, List_Price__c = 0)
                
            }; 
        }else{

            Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            system.debug('CURRENCYRATE='+currencyRate);
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = (tp.X5__c == null? 0 : (tp.X5__c == -1 ? -1 : tp.X5__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 0, List_Price__c = (tp.X250__c == null? 0 : (tp.X250__c == -1 ? -1 : tp.X250__c * currencyRate)))                
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