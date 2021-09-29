public class PMCalculator_US_Lotion {
    
 	// sections
 	public static final String PRODUCT_DEFINITION = 'Product Definition';
 	public static final String COLORATION_UPCHARGE = 'Coloration Upcharge';
 	public static final String PUMP_OPTIONS = 'Pump Options';
 	public static final String BOTTLE_DECO = 'Bottle & Pump Decoration Options';  
 	public static final String OTHERS = 'Others';
      
        
 	// SUB-SECTIONS
 	// Product Definition
 	public static final String PUMP = 'Pump'; 	
    public static final String OVERCAP = 'Overcap'; 
 	public static final String BOTTLE = 'Bottle';

    // Coloration Upcharge
 	public static final String ACTUATOR = 'Actuator Coloration';
    public static final String COLLAR = 'Collar Coloration';
    public static final String CAP = 'Cap Coloration';
 	public static final String DECO_INSERT = 'Insert Coloration';
    public static final String BOTTLE_COLORING = 'Bottle Coloration';
    public static final String BOTTLE_RING = 'Bottle Ring Coloration';

    //PUMP OPTIONS
 	public static final String PBT_BODY = 'PBT Body';
    public static final String DIPTUBE_LENGTH = 'Diptube Length';
 	public static final String PLASTIC_PROTECTION = 'Plastic Protection';
 	

    //Bottle & Pump Decoration Options
 	public static final String BOTTLE_HOT_STAMPING = 'Bottle Hot Stamping';
 	public static final String BOTTLE_OFFSET = 'Bottle Offset';
	public static final String BOTTLE_SILK_SCREENING = 'Bottle Silk-Screening'; 
    public static final String CAP_DECORATION = 'Cap Decoration';
    public static final String COLLAR_DECORATION = 'Collar Decoration';
     
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
    
	public PMCalculator_US_Lotion(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_US_Lotion start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
         
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
			log('VERSION'+version);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, version);    */
           // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate); 
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, config.Product_segment__c, dt, false, true);



        }
		
	}

    public void calculate() {
        
        resetAllPMPrice();
        
        createOvercapPM(); // Overcap; Calculate Overcap first as it is dependent upon PumpPM
        createPumpPM(); // Pump;
        createBottlePM(); // Bottle;
    
       
        // Deco Upcharge
        createActuatorPM(); // Actuator;
        createCollarPM(); // Collar;
        createCapPM(); // Cap;
        createDecoInsertPM(); // Insert;
        createBottleColoringPM(); // Bottle Coloring;
        createBottleRingPM(); // Bottle Ring;
    
        
         //PUMP OPTIONS
        createPbtBodyPM(); // PBT Body;        
        createDiptubeLengthPM(); // Diptube Length;
        createPlasticProtectionPM(); // Plastic Protection;
    
     
        
        //Bottle Deco Options
        createBottleHotStampingPM(); // Bottle Hot Stamping;
        createBottleOffsetPM(); // Bottle Offset;
        createBottleSilkScreeningPM(); // Bottle Silk-Screening; 
        createCapDecorationPM();
        createCollarDecorationPM();
        
        //Others
        createEndOfyearRebatePM(); // End of Year Rebate;

        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;

        PMCalculatorUtility.calculateTotalMOQPRice(null, config.Id, config.Quote_item__c);
        // Added for Historisation
        if (mapPMDispensingPricing.size()> 0) update mapPMDispensingPricing.values();
    }
    
    public void resetAllPMPrice() {       
             
        
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, OVERCAP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));
       
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, ACTUATOR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, COLLAR));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, CAP));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, DECO_INSERT));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, BOTTLE_COLORING));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, BOTTLE_RING));
        
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, PBT_BODY));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, PLASTIC_PROTECTION));
        blankPMPrices.addAll(getLineDetails(config, null, PUMP_OPTIONS, DIPTUBE_LENGTH));
 	     
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_HOT_STAMPING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_OFFSET));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, BOTTLE_SILK_SCREENING));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, CAP_DECORATION));
        blankPMPrices.addAll(getLineDetails(config, null, BOTTLE_DECO, COLLAR_DECORATION));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
                
        upsert blankPMPrices ExtId__c;
                
    }    
    
    
    /**
     * KEY = = <>C33&"_"&D33&"_"&E33&"_"&F33&"_"&G33&"_"&H33&"_"&I33&IF(J33<>0,"_"&J33,"")&IF(K33<>0,"_"&K33,"")
     */ 
    public void createPumpPM() {
        log('*********** createPumpPM ***********LINE='+PUMP);
        log(PUMP + '=AC='+config.Actuator__c + '=NF=' + config.Neck_Finish__c
           + '=CL=' + config.Collar__c + '=CAP=' + config.Cap__c);
        if (String.isNotBlank(config.Actuator__c) 
            //&& String.isNotBlank(config.Neck_Finish__c) 
            && String.isNotBlank(config.Collar__c) 
            && String.isNotBlank(config.Cap__c) 
           ) {                
                                
               	String capValue = '';
               	if (overcapPricex250 == 0) {                   
                   capValue =  config.Cap__c;
               	} else {
                    
					String capRef = config.Engine_Name__c + '_' + config.Pump_Segmentation__c + '_' 
                        		+ config.Attachment__c + '_' + config.Lockability__c + '_' 
                    			+ config.Neck_Finish__c + '_' + config.Actuator__c + '_'
                    			+ config.Collar__c;
                   	log(PUMP + 'CAP REF=' + capRef); 
 					for(PM_Dispensing_Config__c  dispensingConfig : [select Cap__c 
	    								from PM_Dispensing_Config__c  
	    								where Concatenate__c = :capRef
                                        and  Table_Name__c ='Cap Alternative'
                                        and Location__c = :config.Location__c
                                        and Product_Segment__c = 'Lotion pumps'
	    								limit 1]){
                                                			
                		log(PUMP + ': CAP FROM CONFIG=' + capRef +  '=' + dispensingConfig.Cap__c);
                        capValue =  dispensingConfig.Cap__c;                    
                     }                     
               } 
				//If not blank, append to Ref                                
               if (capValue != '') {
                     capValue = '_' + capValue;              
               }
                                                               
               String purgeRing = '';
               if (String.isNotBlank(config.Purge_Ring__c) && !'0'.equalsIgnoreCase(config.Purge_Ring__c)) {
                    purgeRing = '_' + config.Purge_Ring__c;                
               } else {
                   if ('No'.equalsIgnoreCase(config.Purge_Ring__c)) {
 						purgeRing = '_No'; 
                   } else {
                        purgeRing = ''; 
                   }
                    
               }
            //**********Ticket Roxana Evol , add Pump Material in REF
            	/*String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c + '_'
                        		+ (config.Attachment__c == null? '0' : config.Attachment__c) 
                    			+ '_' + (config.Lockability__c == null? '0' : config.Lockability__c)  
                    			+ '_' + config.Actuator__c + '_' + config.Neck_Finish__c 
                    			+ '_' + config.Collar__c + capValue + purgeRing;*/
            String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c + '_'
                    + (config.Attachment__c == null? '0' : config.Attachment__c)
                    + '_' + (config.Lockability__c == null? '0' : config.Lockability__c)
                    + '_' + config.Actuator__c + '_' + config.Neck_Finish__c
                    + '_' + config.Collar__c + capValue + purgeRing + '_' + (((config.Pump_material__c == null) || (config.Pump_material__c == ''))? '0' : config.Pump_material__c) ;
            //*********End Modif***************************
               String packRef = config.Product_Type__c + '_' + config.Pack_Name__c;
               if (packRef.endsWithIgnoreCase('Complete Pack_SOF\'Airless') 
                   			|| packRef.endsWithIgnoreCase('Complete Pack_Premia') 
                   			|| packRef.endsWithIgnoreCase('Complete Pack_D.N.Airless ø32')
                  			|| packRef.endsWithIgnoreCase('Complete Pack_SOF\'Atmo')) {
                   packRef = packRef + '_' + ref; 
               }
               
               
                log(PUMP + 'Name Key=' +packRef);
                System.debug('@@@@@ PUMP' + 'ref' +ref );
            PM_Dispensing_Pricing__c pricing = mapPMDispensingPricing.get((packRef != null ? packRef.toUppercase(): null));
               if (pricing == null) {
                   System.debug(PUMP + ': PRICING FOR PACK=' + packRef + '=NULL');
                   pricing = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
                   if (pricing == null) {
                       System.debug(PUMP + ': PRICING=' + ref + '=NULL');
                       listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, pricing, PRODUCT_DEFINITION, PUMP), -1));
                   } else {
                       listDetailsToUpsert.addAll(getLineDetails(config, pricing, PRODUCT_DEFINITION, PUMP));
                   		                       
                   }
               } else {
                 listDetailsToUpsert.addAll(getLineDetails(config, pricing, PRODUCT_DEFINITION, PUMP));  
               }
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
                if (mapPMDispensingPricing.get((packRef != null ? packRef.toUppercase(): null))!= null){
                    mapPMDispensingPricing.get((packRef != null ? packRef.toUppercase(): null)).Section__c = PRODUCT_DEFINITION;
                    mapPMDispensingPricing.get((packRef != null ? packRef.toUppercase(): null)).Line_Name__c = PUMP;
                }
                
             
        }
        
        
        
    }
 
     /**
     * KEY = <ENGINE NAME>_<>_<CAP>
     */ 
    public void createOvercapPM() {
        log('*********** createOvercapPM ***********LINE='+OVERCAP);
        List<PM_Price_Detail__c> overCapLineDetails = null;

        if (String.isNotBlank(config.Cap__c)) {

            String completePack =  config.Product_Type__c + '_' + config.Pack_Name__c;
            String ref= '';
            if ('Complete Pack_Premia'.equalsIgnoreCase(completePack)) {
                ref= completePack + '_' + config.Cap__c; 
            } else {
              ref= config.Engine_Name__c + '_' + config.Pump_Segmentation__c + '_' + config.Cap__c;  
            }           
                         
            log('REF=' + ref);
            PM_Dispensing_Pricing__c pricing = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
            overcapPricex250 = (pricing != null && pricing.X250__c != null) ? pricing.X250__c : 0;            
            overCapLineDetails = getLineDetails(config, pricing, PRODUCT_DEFINITION, OVERCAP); 
            log(overCapLineDetails);
			listDetailsToUpsert.addAll(overCapLineDetails);            
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
            if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
                mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = PRODUCT_DEFINITION;
                mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = OVERCAP;
            }
        } 
        
        
    }
        
    
 	/**
 	 * KEY = 
 	 */ 
    public void createBottlePM() {
    	log('*********** createBottlePM ***********LINE='+ BOTTLE); 
        String ref = null;
    	if (String.isNotBlank(config.Pack_Name__c) 
                    	&& String.isNotBlank(config.Bottle_Volume__c)) {
                            
            ref = config.Pack_Name__c + '_' + config.Bottle_Volume__c; 
                                    
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), PRODUCT_DEFINITION, BOTTLE));             
        // Added for Historisation
        // Create Junction Object
       PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PRODUCT_DEFINITION+
                                                                          '_'+BOTTLE);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = PRODUCT_DEFINITION;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE;
        }
    }
    
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<ACTUATOR FINISHING>_Actuator color
     */ 
    public void createActuatorPM() {
    	log('*********** createActuatorPM ***********LINE='+ACTUATOR);   

    	if (String.isNotBlank(config.Actuator_Finishing__c)) {
            if (!'Custom'.equalsIgnoreCase(config.Actuator_Finishing__c)) {
                /*
                 New Ref Roxana Evol ticket 7624
                 */
               /* String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c
                    + '_' + config.Actuator_Finishing__c + '_Actuator color';*/
                String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c
                        + '_' + config.Actuator_Finishing__c + '_Actuator color'+ '_' +(((config.Pump_material__c == null) || (config.Pump_material__c == ''))? '0' : config.Pump_material__c);
                   /*
                      End Modif Roxana ...
                    */
                log('REF=' + ref);
                listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, ACTUATOR));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                     Dispensing_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                                  '_'+ACTUATOR);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = ACTUATOR;
                }
            } else {
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, COLORATION_UPCHARGE, ACTUATOR), -1));
                
            }
        }        
        
    }
    
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<ACTUATOR FINISHING>_Collar color
     */     
    public void createCollarPM() {
    	log('*********** createCollarPM ***********LINE='+COLLAR);    
    	if (String.isNotBlank(config.Collar_Finishing__c)) {
            
            if (!'Custom'.equalsIgnoreCase(config.Collar_Finishing__c)) {

                /*
                    We need to change This Ref for PCR Evol US Roxana
                    + '_' + (((config.Pump_material__c == null) || (config.Pump_material__c == ''))? '0' : config.Pump_material__c) ;
                 */
         		/*String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c
            		+ '_' + config.Actuator_Finishing__c + '_Collar color';*/
                String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c
                        + '_' + config.Actuator_Finishing__c + '_Collar color' + '_' + (((config.Pump_material__c == null) || (config.Pump_material__c == ''))? '0' : config.Pump_material__c) ;
                /*
                   End Modif Roxana
                 */
                            
            	log('REF=' + ref);
            	listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, COLLAR));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                     Dispensing_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                                  '_'+COLLAR);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = COLLAR;
                }
            } else {
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, COLORATION_UPCHARGE, COLLAR), -1));
            }
        
        }         
        
    }
    
    /**
     * KEY = <ENGINE NAME>_<PUMP CONFIG>_<CAP FINISHING>_Cap color
     */    
    public void createCapPM() {
    	log('*********** createCapPM ***********LINE'+ CAP);    
    	if (String.isNotBlank(config.Cap_Finishing__c)) {
            
         		String ref = config.Engine_Name__c + '_' + config.Pump_Segmentation__c 
            		+ '_' + config.Cap_Finishing__c + '_Cap color';
                            
            	log('REF=' + ref);
            	listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, CAP));             
                // Added for Historisation
                // Create Junction Object
                PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                                     Dispensing_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                                  '_'+CAP);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
                    mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = CAP;
                }
        }
        
    }
 
   /**
     * KEY = <ENGINE NAME>_Insert color
     */     
    public void createDecoInsertPM() {
    	log('*********** createDecoInsertPM ***********LINE'+DECO_INSERT);
        String ref = '';
    	if (String.isNotBlank(config.Insert_Finishing__c) && 'Non Standard'.equalsIgnoreCase(config.Insert_Finishing__c)) {           
        	ref = config.Engine_Name__c + '_Insert color';                                     
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, DECO_INSERT));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+DECO_INSERT);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = DECO_INSERT;
        }
        
    }
    
    public void createBottleColoringPM() {
    	log('*********** createBottleColoringPM ***********LINE='+BOTTLE_COLORING); 
       /* =IF(AS33=0,"",
            IF(VLOOKUP(AS33,'BACKUP - Lotion'!$AE$21:$AF$32,2,0)="STD",
               "",IF($AS$33="PP Clear",AO33&"_"&AP33&"_"&$AS$33&"_Color",AO33&"_"&AP33&"_Color")))
        */
        String ref = ''; 
    	if (String.isNotBlank(config.Coloring__c)) {
			for(PM_Dispensing_Config__c  dispensingConfig : [select Coloring_options__c
	    								from PM_Dispensing_Config__c  
	    								where Color__c  = :config.Coloring__c
                                        and  Table_Name__c ='Coloring options'
                                        and Location__c = 'EU'
	    								limit 1]){
                                                			
                log('## Coloring Options :' + config.Coloring__c +  '=' + dispensingConfig.Coloring_options__c);
                                            
                if (!'STD'.equalsIgnoreCase(dispensingConfig.Coloring_options__c)) {
                    if ('PP Clear (30-50ml)'.equalsIgnoreCase(config.Coloring__c)) {
                        ref = config.Pack_Name__c + '_' + config.Bottle_Volume__c + '_' + config.Coloring__c + '_Color'; //<PACKNAME>_<VOLUME>_<COLORING>_Color",
                    } else {
                        ref =  config.Pack_Name__c + '_' + config.Bottle_Volume__c + '_Color'; //<PACKNAME>_<VOLUME>_Color"
                    }                     
                }
                                            
                                            
	    	}			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, BOTTLE_COLORING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+BOTTLE_COLORING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE_COLORING;
        }
    }
    
    public void createBottleRingPM() {
    	log('*********** createBottleRingPM ***********LINE'+ BOTTLE_RING);    
        String ref = '';
    	if (String.isNotBlank(config.Ring_Coloration__c) && !'Standard'.equalsIgnoreCase(config.Ring_Coloration__c)) {           
        	
            if ('Non Standard (Colored)'.equalsIgnoreCase(config.Ring_Coloration__c) 
                				|| 'Non Standard (Metallized)'.equalsIgnoreCase(config.Ring_Coloration__c)) {
                                    
                ref = 'Bottle ring coloration_' + config.Engine_Name__c; 
            }                                               
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), COLORATION_UPCHARGE, BOTTLE_RING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+BOTTLE_RING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = COLORATION_UPCHARGE;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE_RING;
        }
        
    }
    
    public void createPbtBodyPM() {
    	log('*********** createPbtBodyPM ***********LINE='+ PBT_BODY);    
         String ref = '';
    	if (String.isNotBlank(config.PBT_Body__c) && 'Yes - extra cost'.equalsIgnoreCase(config.PBT_Body__c)) {                                                
                ref = 'PBT body_' + config.Engine_Name__c; 
         
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), PUMP_OPTIONS, PBT_BODY));                     
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+PBT_BODY);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = PUMP_OPTIONS;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = PBT_BODY;
        }
    }
       
    public void createDiptubeLengthPM() {
    	log('*********** createDiptubeLengthPM ***********LINE='+DIPTUBE_LENGTH);    
        
        String ref = '';
    	if (String.isNotBlank(config.Diptube_Length__c) && !'Standard (<120mm)'.equalsIgnoreCase(config.Diptube_Length__c)) {                                            
                ref = 'Diptube length_' + config.Engine_Name__c + '_' + config.Diptube_Length__c;             
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), PUMP_OPTIONS, DIPTUBE_LENGTH));                                    
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+DIPTUBE_LENGTH);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = PUMP_OPTIONS;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = DIPTUBE_LENGTH;
        }
    }
    
    public void createPlasticProtectionPM() {
    	log('*********** createPlasticProtectionPM ***********LINE='+PLASTIC_PROTECTION);    
   
         String ref = '';
    	if (String.isNotBlank(config.Plastic_Protection__c) && 'Plastic Protection'.equalsIgnoreCase(config.Plastic_Protection__c)) {                   	                                 
        	ref = 'Sleevage_' + config.Engine_Name__c;             
        } 
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), PUMP_OPTIONS, PLASTIC_PROTECTION));                            
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+PUMP_OPTIONS+
                                                                          '_'+PLASTIC_PROTECTION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = PUMP_OPTIONS;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = PLASTIC_PROTECTION;
        }
    } 
    
    /**
     * KEY = <PACK NAME>_<HOT STAMPING>_Decoration
     */    
    public void createBottleHotStampingPM() {
    	log('*********** createBottleHotStampingPM ***********LINE='+BOTTLE_HOT_STAMPING);  
        String ref = ''; 
    	if (String.isNotBlank(config.Hot_Stamping__c) && !'No'.equalsIgnoreCase(config.Hot_Stamping__c)) {
            ref =  config.Pack_Name__c + '_' + config.Hot_Stamping__c + '_Decoration';           
			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), BOTTLE_DECO, BOTTLE_HOT_STAMPING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_HOT_STAMPING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = BOTTLE_DECO;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE_HOT_STAMPING;
        }
    }
    
    /**
     * KEY = <PACK NAME>_<OFFSET>_Decoration
     * 
     */ 
    public void createBottleOffsetPM() {
    	log('*********** createBottleOffsetPM ***********LINE='+BOTTLE_OFFSET);    
        String ref = ''; 
    	if (String.isNotBlank(config.Offset__c) && !'No'.equalsIgnoreCase(config.Offset__c)) {
            String offset = (config.Offset__c == 'Offset varnish'? 'Offset Varnish': config.Offset__c);
            
            ref =  config.Pack_Name__c + '_' + offset + '_Decoration';           
			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), BOTTLE_DECO, BOTTLE_OFFSET));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_OFFSET);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = BOTTLE_DECO;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE_OFFSET;
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
            ref =  config.Pack_Name__c + '_' + config.Silk_Screening__c + '_Decoration';           
			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), BOTTLE_DECO, BOTTLE_SILK_SCREENING));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+BOTTLE_SILK_SCREENING);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = BOTTLE_DECO;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = BOTTLE_SILK_SCREENING;
        }
        
    }
    
    public void createCapDecorationPM() {
    	log('*********** createCapDecorationPM ***********LINE='+CAP_DECORATION); 
        
        String ref = ''; 
    	if (String.isNotBlank(config.Cap_Decoration__c) && !'No'.equalsIgnoreCase(config.Cap_Decoration__c)) {
            ref =  config.Pack_Name__c + '_Cap_' +  config.Cap_Decoration__c;           
			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), BOTTLE_DECO, CAP_DECORATION));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+CAP_DECORATION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = BOTTLE_DECO;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = CAP_DECORATION;
        }
        
    }

    public void createCollarDecorationPM() {
    	log('*********** createCollarDecorationPM ***********LINE='+COLLAR_DECORATION);    
        String ref = ''; 
    	if (String.isNotBlank(config.Collar_Decoration__c) && !'No'.equalsIgnoreCase(config.Collar_Decoration__c)) {
            ref =  config.Pack_Name__c + '_Collar_' + config.Collar_Decoration__c;           
			                     
        }
        log('REF=' + ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)), BOTTLE_DECO, COLLAR_DECORATION));             
        // Added for Historisation
        // Create Junction Object
        PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null));
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+BOTTLE_DECO+
                                                                          '_'+COLLAR_DECORATION);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null))!= null){
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Section__c = BOTTLE_DECO;
            mapPMDispensingPricing.get((ref != null ? ref.toUppercase(): null)).Line_Name__c = COLLAR_DECORATION;
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
                    PMCalculatorUtility.setSpecificPriceToZero(
                    	PMCalculatorUtility.calcGroupDispensingOther(listDetailsToUpsert, new Set<String>(), config, 
                                                                dPercent, OTHERS, END_OF_YEAR_REBATE)));
                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }         
        
    }
    
 
    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    public List <PM_Price_Detail__c> getLineDetails(PM_Selected_Dipsensing_config__c config, PM_Dispensing_Pricing__c tp, String section, String name){
    	List <PM_Price_Detail__c> listDetails;
    	if(tp == null){
    		listDetails = new List <PM_Price_Detail__c>{
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
  
    
    public void log(Object message) {
        System.debug(message);
    }    
}