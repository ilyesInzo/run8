public class PMCalculator_US_SamplerPump {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Dispensing Sampler Pump
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   27-MAR-2017  Hasseeb 		    Initial version
 *****************************************************************************/ 
  	// sections
 	public static final String PRODUCT_DEFINITION = 'Product Definition';
 	public static final String COLORATION_UPCHARGE = 'Coloration Upcharge';
 	public static final String BOTTLE_UPCHARGES = 'Bottle Upcharges';
    public static final String PUMP_OPTIONS = 'Pump Options';
 	public static final String OTHERS = 'Others';
        
 	public static final String PUMP = 'Pump';
 	public static final String BOTTLE = 'Bottle';
 	public static final String CAP = 'Cap';
 	
 	public static final String ACTUATOR = 'Actuator Coloration';
 	public static final String INSERTLINE = 'Insert Coloration';
 	public static final String COLLAR = 'Collar Coloration';
 	public static final String CAP_COLORATION = 'Cap Coloration';
 	public static final String BOTTLE_COLORATION = 'Bottle Coloration';
 	
 	public static final String BOTTLE_DECORATION = 'Bottle Decoration';
 	public static final String BOTTLE_PACKAGING = 'Bottle Packaging';
    
    public static final String INSERT_TYPE = 'Insert Type';
 	
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

	public PMCalculator_US_SamplerPump(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_US_SamplerPump start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
       
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
			log('VERSION='+version);
            log('LOCATION='+config.Location__c);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, version);     */
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
        calculateBOTTLE();
        calculateCAP();
        
        calculateACTUATOR();
        calculateINSERT();
        calculateCOLLAR();
        calculateCAP_COLORATION();
        calculateBOTTLE_COLORATION();
        
        calculateBOTTLE_DECORATION();
        calculateBOTTLE_PACKAGING();
        
        calculateINSERT_TYPE();
        
        calculateEND_OF_YEAR_REBATE();
        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
         
        PMCalculatorUtility.calculateTotalMOQPRice(null, config.Id, config.Quote_item__c);
        // Added for Historisation
        if (mapPMDispensingPricing.size()> 0) update mapPMDispensingPricing.values();
    }
    
    public void calculatePUMP() {
    	log('***********calculatePUMP ***********'); 
        if (String.isNotBlank(config.Product_Name__c) && String.isNotBlank(config.Engine_Neck__c) 
            	&& String.isNotBlank(config.Pump_Segmentation__c)) {
            String collarConfiguration = ('Cylindrical'.equalsIgnoreCase(config.Collar_Configuration__c)? 'Cylindrical': '');
            String ref =  config.Product_Name__c + config.Engine_Neck__c + collarConfiguration + config.Pump_Segmentation__c;
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
    
    public void calculateBOTTLE() {
    	log('***********calculateBOTTLE ***********'); 
        if (String.isNotBlank(config.Product_Name__c)) {
            String collarConfiguration = ('Cylindrical'.equalsIgnoreCase(config.Collar_Configuration__c)? 'Cylindrical': '');
            
            String neck = '';
    		for(PM_Dispensing_Config__c pmConfig : [select id, Engine_Type__c, Dosage__c, Neck__c, Engine_Name__c 
                                             from PM_Dispensing_Config__c 
                                             where Product_Segment__c='Sampler pumps' 
                                             and location__c = 'US'  
                                             and Table_name__c='Engine and Neck'
                                             and Engine_Name__c =: config.Engine_Neck__c
	    								limit 1]){
    			neck = pmConfig.Neck__c;
                System.debug('## Nexk : ' + neck);
	    	}            
            
            String ref =  config.Product_Name__c + '_' 
                		+ config.Bottle_Size__c + '_' 
                		+ neck + '_' 
                		+ config.Material__c;
        	system.debug('REF='+ref); 
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
     

    public void calculateCAP() {
    	log('***********calculateCAP ***********'); 
        if (String.isNotBlank(config.Cap__c)) {
            String ref =  config.Product_Name__c + '_' + config.Engine_Neck__c + '_' + config.Cap__c;
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
    
    

    public void calculateACTUATOR() {
    	log('***********calculateACTUATOR ***********'); 
        String actuatorFinishing = '';
        if ('Coloring'.equalsIgnoreCase(config.Actuator_Finishing__c)
           			&& 'Non Std'.equalsIgnoreCase(config.Actuator_Detailed_finishing__c)) {
            actuatorFinishing = 'Per Color Added';
        } else if ('Custom'.equalsIgnoreCase(config.Actuator_Detailed_finishing__c)) {
            actuatorFinishing = 'Custom';            
        } else if ('Metallization'.equalsIgnoreCase(config.Actuator_Finishing__c)) {
            actuatorFinishing = 'Pump Metallization';            
        } else if ('Anodization'.equalsIgnoreCase(config.Actuator_Finishing__c)) {
            actuatorFinishing = 'Custom';            
        } 
        
        if ('Custom'.equalsIgnoreCase(actuatorFinishing)) {
            //Set to specific
			PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, COLORATION_UPCHARGE, ACTUATOR), -1); 
        } else {
           
            String ref =  config.Product_Name__c + 'Pump' + actuatorFinishing;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, ACTUATOR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+ACTUATOR);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = ACTUATOR;
            }
        }
        
    }    
    

    
    public void calculateINSERT() {
    	log('***********calculateINSERT ***********'); 
        String insertFinishing = '';
        if ('Natural'.equalsIgnoreCase(config.Insert_Coloring__c)) {
            insertFinishing = 'Std';
        } else if ('Black'.equalsIgnoreCase(config.Insert_Coloring__c)) {
            insertFinishing = 'For a black insert';            
        } else if ('Not Std'.equalsIgnoreCase(config.Insert_Coloring__c)) {
            insertFinishing = 'Per color added';            
        } 

        if (!''.equalsIgnoreCase(insertFinishing)) {
            
            String ref =  config.Product_Name__c + 'insert' + insertFinishing;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, INSERTLINE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+INSERTLINE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = INSERTLINE;
            }
        }        
	        
    }    
  
    

    public void calculateCOLLAR() {
    	log('***********calculateCOLLAR ***********CF=' + config.Collar_Finishing__c +'=DCF='+config.Collar_Detailed_finishing__c); 
        String collarFinishing = '';
        if ('Coloring'.equalsIgnoreCase(config.Collar_Finishing__c)
           			&& 'Non Std'.equalsIgnoreCase(config.Collar_Detailed_finishing__c)) {
            collarFinishing = 'Per Color Added';
        } else if ('Custom'.equalsIgnoreCase(config.Collar_Detailed_finishing__c)) {
            collarFinishing = 'Custom';            
        } else if ('Metallization'.equalsIgnoreCase(config.Collar_Finishing__c)) {
            collarFinishing = 'Collar Metallization';            
        } else if ('Anodization'.equalsIgnoreCase(config.Collar_Finishing__c)) {
            collarFinishing = 'Custom';            
        } 
        system.debug('COLLARFINISHING=' + collarFinishing);
        if ('Custom'.equalsIgnoreCase(collarFinishing)) {
            
            system.debug('COLLARFINISHING=' + collarFinishing);
            
            //Set to specific 
			listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, COLORATION_UPCHARGE, COLLAR), -1)); 
        } else {
           
            String ref =  config.Product_Name__c + 'Collar' + collarFinishing;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, COLLAR));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+COLLAR);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = COLLAR;
            }
        }
        
        
    }    
  
    

    public void calculateCAP_COLORATION() {
    	log('***********calculateCAP_COLORATION ***********'); 
        String capFinishing = '';
        if ('Coloring'.equalsIgnoreCase(config.Cap_Finishing__c)
           			&& 'Non Std'.equalsIgnoreCase(config.Cap_Detailed_finishing__c)) {
            capFinishing = 'Per Color Added';
        } else if ('Custom'.equalsIgnoreCase(config.Cap_Detailed_finishing__c)) {
            capFinishing = 'Custom';            
        } else if ('Metallization'.equalsIgnoreCase(config.Cap_Finishing__c)) {
            capFinishing = 'Metallization';            
        } else if ('Anodization'.equalsIgnoreCase(config.Cap_Finishing__c)) {
            capFinishing = 'Custom';            
        } 
        if ('Custom'.equalsIgnoreCase(capFinishing)) {
            //Set to specific
			PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, COLORATION_UPCHARGE, CAP_COLORATION), -1); 
        } else {
           
            String ref =  config.Product_Name__c + 'Cap' + capFinishing;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, CAP_COLORATION));             
             // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+CAP_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = CAP_COLORATION;
            }
        }        
        
        
    }    
    
    

    public void calculateBOTTLE_COLORATION() {
    	log('***********calculateBOTTLE_COLORATION ***********'); 
        String bottleFinishing = '';
        if ('Standard'.equalsIgnoreCase(config.Bottle_Finishing__c)
           			&& 'Non Std'.equalsIgnoreCase(config.Plastic_Coloring__c)) {
            bottleFinishing = 'Per Color Added';
		} else if ('Standard'.equalsIgnoreCase(config.Bottle_Finishing__c)
           			&& 'Natural'.equalsIgnoreCase(config.Plastic_Coloring__c)) {                        
             bottleFinishing = 'PP Clear Option';           
        } else if ('Custom'.equalsIgnoreCase(config.Plastic_Coloring__c)) {
            bottleFinishing = 'Custom';            
        } else if ('Metallization'.equalsIgnoreCase(config.Bottle_Finishing__c)) {
            bottleFinishing = 'Metallization';            
        } 
        
        if (!''.equalsIgnoreCase(bottleFinishing)) {
           
            String ref =  config.Product_Name__c + 'Bottle' + bottleFinishing;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, BOTTLE_COLORATION));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+BOTTLE_COLORATION);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_COLORATION;
            }
        }
        
        
    }    
     
    
    public void calculateBOTTLE_DECORATION() {
    	log('***********calculateBOTTLE_DECORATION ***********'); 
        String ref =  config.Product_Name__c + config.Bottle_Size__c + 'Bottle' 
            + config.Bottle_Decoration__c 
            + ('Metallization'.equalsIgnoreCase(config.Bottle_Finishing__c)? 'Metal': '');
        system.debug('REF='+ref); 
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_UPCHARGES, BOTTLE_DECORATION));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
        if( dp != null){
             PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_UPCHARGES+
                                                                          '_'+BOTTLE_DECORATION);
             listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
            mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_UPCHARGES;
            mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_DECORATION;
        }
    }    
    

    public void calculateBOTTLE_PACKAGING() {
    	log('***********calculateBOTTLE_PACKAGING ***********'); 
        if ('Metallization'.equalsIgnoreCase(config.Bottle_Finishing__c) 
            		&& 'Screen-Printing'.equalsIgnoreCase(config.Bottle_Decoration__c)) {

            String ref =  config.Product_Name__c + 'Packaging cost' 
                + config.Bottle_Decoration__c 
                + ('Metallization'.equalsIgnoreCase(config.Bottle_Finishing__c)? 'Metal': '');
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), BOTTLE_UPCHARGES, BOTTLE_DECORATION));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_UPCHARGES+
                                                                          '_'+BOTTLE_DECORATION+'_2');
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = BOTTLE_UPCHARGES;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BOTTLE_DECORATION;
            }
        }        
    }
    
    public void calculateINSERT_TYPE() {
        log('***********calculateINSERT_TYPE ***********'); 
        if (String.isNotBlank(config.Product_Name__c) && String.isNotBlank(config.Engine_Neck__c) 
            && String.isNotBlank(config.Insert_Type__c)) {
                String ref =  config.Product_Type__c + '_' + config.Product_Name__c + '_' + config.Engine_Neck__c + '_' + config.Insert_Type__c;
                
                system.debug('REF='+ref);
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), PUMP_OPTIONS, INSERT_TYPE));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                 Dispensing_Pricing__c = dp.Id, 
                                                                 Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                              '_'+INSERT_TYPE);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                    mapPMDispensingPricing.get(ref.toUppercase()).Section__c = PUMP_OPTIONS;
                    mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = INSERT_TYPE;
                }
            }       
    }        
    
    public void calculateEND_OF_YEAR_REBATE() {
    	log('***********calculateEND_OF_YEAR_REBATE ***********');    
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
  
    
    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));    
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, CAP));

        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, ACTUATOR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, INSERTLINE));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, COLLAR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, CAP_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, BOTTLE_COLORATION));
        
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_UPCHARGES, BOTTLE_DECORATION));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_UPCHARGES, BOTTLE_PACKAGING));
        
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, INSERT_TYPE));
            
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
                
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
				new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0)
                    
			}; 
    	}else{

			Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            
    		listDetails = new List <PM_Price_Detail__c>{
				new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 50, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
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

    public void log(Object message) {
        System.debug(message);
    }
    
}