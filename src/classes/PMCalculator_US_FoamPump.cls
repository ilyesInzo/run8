/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Dispensing Foam Pump
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   05-MAR-2017  Hasseeb 		    Initial version
 *****************************************************************************/ 

public class PMCalculator_US_FoamPump {
    
    //Fill in values between 1-100. The default is zero as in the excel sheet
    public static final Integer AERO_OPTIMIZATION_PERCENTAGE = 0;
    public static final Integer DAYS5_LEAD_TIME_PERCENTAGE = 0;
    
    
 	// sections
 	public static final String PRODUCT_DEFINITION = 'Product Definition';
 	public static final String COLORATION_UPCHARGE = 'Coloration Upcharge';
 	public static final String DECORATION_UPCHARGE = 'Decoration Upcharge';
 	public static final String OTHERS = 'Others';
        
  	public static final String PUMP = 'Pump';
  	public static final String PUMP_MATERIAL = 'Pump material';
  	public static final String FOAM_QUALITY = 'Foam Quality'; //Added by maryem qada for Velvet option 15/03/2018
 	public static final String BOTTLE = 'Bottle';
 	public static final String BALL_SPRING = 'Ball & Spring';
 	public static final String HIGH_FORCE = 'High Force';
 	public static final String CAP = 'Cap';
    
 	public static final String NOZZLE = 'Nozzle';
 	public static final String BASE_CAP = 'Base Cap';
 	public static final String OVERCAP = 'Overcap';
    
 	public static final String HOT_STAMPING_PUMP = 'Hot-Stamping Pump';
 	public static final String SILKSCREENING_PUMP = 'Silkscreening Pump';
    
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

	public PMCalculator_US_FoamPump(PM_Selected_Dipsensing_config__c  config) {
        
        log('PMCalculator_US_FoamPump start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c, createdDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
       
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Dispensing', config.Product_segment__c);
			log('VERSION='+version);
            log('LOCATION='+config.Location__c);
            mapPMDispensingPricing = PMCalculatorUtility.getPMDispensingPricingReference(config.Location__c, version); */
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
        //calculatePUMP_MATERIAL();
        calculateFOAMQUALITY();//added by maryem qada for Velvet option 15/03/2018
        calculateBOTTLE(); 
        calculateBALL_SPRING();
        calculateHIGH_FORCE();
        calculateCAP();
        
        calculateNOZZLE();
        calculateBASE_CAP();
        calculateOVERCAP();
        
        calculateHOT_STAMPING_PUMP();
        calculateSILKSCREENING_PUMP();
        
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
        if(String.isNotBlank(config.Product_Hierarchy__c)){
            //String ref =  config.Product_Hierarchy__c + '_' + config.Engine_Type__c; old ref
            //String ref =  config.Product_Hierarchy__c + '_' + config.Engine_Type__c+'_'+config.pump_material__c; 
            String ref = '';
            if(String.isNotBlank(config.Pump_Segmentation__c)){
                 ref =  config.Product_Hierarchy__c + '_' + config.Engine_Type__c+'_'+config.pump_material__c+'_'+ config.Pump_Segmentation__c;
            }
            else{ 
                 ref =  config.Product_Hierarchy__c + '_' + config.Engine_Type__c+'_'+config.pump_material__c;
            }
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
            
    //Added by maryem qada for Velvet option 15/03/2018
    public void calculateFOAMQUALITY() {
        log('*********** calculateFOAMQUALITY ***********'); 
        if(String.isNotBlank(config.Foam_Quality__c)){
            String ref =  config.Product_Hierarchy__c+ '_' + config.Foam_Quality__c;
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
    	log('***********calculateBOTTLE ***********'); 
        //Bottle_Name__c = 18 = I14
        //Material__c = 16 = H14
        //Bottle_Size__c = 17 = G14
        //Coloring__c = 19 = J14

        if(String.isNotBlank(config.Bottle_Size__c) 
           					&& String.isNotBlank(config.Material__c) 
           					&& String.isNotBlank(config.Bottle_Name__c)
          					&& String.isNotBlank(config.Coloring__c)){
            String ref =  config.Product_Hierarchy__c + '_' 
                		 	+ config.Material__c  + '_' 
                		 	+ config.Bottle_Size__c + '_' 
                			+ config.Bottle_Name__c + '_'
                			+ config.Coloring__c ;
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
    

    public void calculateBALL_SPRING() {
    	log('********** calculateBALL_SPRING ***********'); 
        if(String.isNotBlank(config.Ball_Spring__c)){
                                
            String ref =  config.Product_Hierarchy__c + '_' 
                		 	+ config.Engine_Type__c  + '_' 
                		 	+ config.Ball_Spring__c;// + '_' + config.Metal_Upcharge__c
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
    	log('**********calculateHIGH_FORCE ***********'); 
        if('Yes'.equalsIgnoreCase(config.High_Force__c)){
            String ref =  config.Product_Hierarchy__c + '_' 
                + config.Engine_Type__c + '_'
                + config.Ball_Spring__c + '_'
                + 'High force';
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
    	log('***********calculateCAP ***********'); 
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
    

    public void calculateNOZZLE() {
    	log('***********calculateNOZZLE ***********'); 
        if(String.isNotBlank(config.Actuator_coloring__c)){
            //String ref =  config.Product_Hierarchy__c + '_Nozzle_' + config.Actuator_coloring__c;
        	//String ref =  config.Product_Hierarchy__c +   config.Actuator__c+ config.Actuator_coloring__c+'Nozzle' ;
        	String ref =  config.Product_Hierarchy__c +   config.Pump_material__c+'Nozzle' + config.Actuator_coloring__c ;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, NOZZLE));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+NOZZLE);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = NOZZLE;
            }
        }          
    }
    

    public void calculateBASE_CAP() {
    	log('***********calculateBASE_CAP ***********'); 
        if(String.isNotBlank(config.Basecap_coloring__c)){
            String ref =  config.Product_Hierarchy__c + '_' + config.Pump_material__c+'_BaseCap_' + config.Basecap_coloring__c;
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, BASE_CAP));             
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+BASE_CAP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = BASE_CAP;
            }
        } 
    }
    

    public void calculateOVERCAP() {
    	log('***********  public void calculateOVERCAP ***********'); 
        String ref =  config.Product_Hierarchy__c + '_' + config.Pump_material__c 
            + config.Actuator__c + '_'
            + config.Cap__c + '_'
            + config.Overcap_coloring__c;        
        	system.debug('REF='+ref); 
       		listDetailsToUpsert.addAll(getLineDetails(config, mapPMDispensingPricing.get(ref.toUpperCase()), COLORATION_UPCHARGE, OVERCAP));                     
            // Added for Historisation
            // Create Junction Object
            PM_Dispensing_Pricing__c dp = mapPMDispensingPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Dispensing__c = config.Id, 
                                                             Dispensing_Pricing__c = dp.Id, 
                                                             Unique_Key__c = config.Id+'_'+COLORATION_UPCHARGE+
                                                                          '_'+OVERCAP);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMDispensingPricing.get(ref.toUppercase())!= null){
                mapPMDispensingPricing.get(ref.toUppercase()).Section__c = COLORATION_UPCHARGE;
                mapPMDispensingPricing.get(ref.toUppercase()).Line_Name__c = OVERCAP;
            }
    }
    

    public void calculateHOT_STAMPING_PUMP() {
    	log('***********calculateHOT_STAMPING_PUMP ***********'); 
        if('Yes'.equalsIgnoreCase(config.Hot_Stamping__c)){
            listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, DECORATION_UPCHARGE, HOT_STAMPING_PUMP),-1));
            
           // PMCalculatorUtility.setListPrice(
           //     getLineDetails(config, null, DECORATION_UPCHARGE, HOT_STAMPING_PUMP), -1);
        }         
        
    }
    
    public void calculateSILKSCREENING_PUMP() {
    	log('***********calculateSILKSCREENING_PUMP ***********'); 
        if('Yes'.equalsIgnoreCase(config.Silk_Screening__c)){
            
            listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, DECORATION_UPCHARGE, SILKSCREENING_PUMP),-1));
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

    

    
 
    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BOTTLE));    
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, BALL_SPRING));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, HIGH_FORCE));
        blankPMPrices.addAll(getLineDetails(config, null, PRODUCT_DEFINITION, CAP));
                
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, NOZZLE));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, BASE_CAP));
        blankPMPrices.addAll(getLineDetails(config, null, COLORATION_UPCHARGE, OVERCAP));
        
        blankPMPrices.addAll(getLineDetails(config, null, DECORATION_UPCHARGE, HOT_STAMPING_PUMP));
        blankPMPrices.addAll(getLineDetails(config, null, DECORATION_UPCHARGE, SILKSCREENING_PUMP));
            
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
				new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 25, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0),
				new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 0, List_Price__c = 0)
                    
			}; 
    	}else{

			Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
            
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