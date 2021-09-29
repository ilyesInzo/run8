/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for EU Tube Laminate
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   05-MAR-2017  Hasseeb             Initial version
   *****************************************************************************/ 

   public class PMCalculator_EU_Laminate {
    
    // sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String WEB = 'Web';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';  
    public static final String OTHER_PARTS = 'Other Parts';  
    public static final String OTHERS = 'Others';
    
    // SUB-SECTIONS
    // sections
    public static final String BASIS_PRICE = 'Basis Price';
    public static final String LENGTH_UPCHARGE = 'Length upcharge';
    public static final String HEAD_COLORATION = 'Head Coloration';
    public static final String PEAL_SEEL = 'Peal Seel';
    
    public static final String SLEEVE_MATERIAL = 'Sleeve Material';
    public static final String SLEEVE_ASPECT = 'Sleeve Aspect'; 
    
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_COLORATION = 'Cap Coloration';
    public static final String SHRINK_BAND = 'Shrink Band';
    public static final String CAP_METALISATION = 'Cap Metalisation';
    public static final String HOT_STAMP_TOP = 'Hot Stamp Top';
    public static final String HOT_STAMP_CONTOURING = 'Hot Stamp Contouring';
    public static final String CAP_SILKSCREEN = 'Cap Silkscreen';
    public static final String MANUAL_CAPPING = 'Manual Capping';
    
    public static final String PRINTING_FLEXO_COLORS = 'Printing (Flexo colors)';
    public static final String METALLIC_FLEXO = 'Metallic Flexo';
    public static final String SILK_SCREEN = 'Silk screen';
    public static final String COLD_HOT_FOIL = 'Cold / Hot foil';
    
    public static final String RONDELLE = 'Rondelle';
    public static final String INSERT_LINE = 'Insert';
    
    public static final String COMBO = 'Combo';
    public static final String PLATTS = 'Platt\'s';
    public static final String PAYMENT_TERMS = 'Payment Terms';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
    public static final String SKONTO = 'Skonto';
    public static final String STOCKAGE = 'Stockage';
    public static final String FREIGHT_PRICE = 'Freight Price';
    public static final String MANUAL_PACKING = 'Manual Packing';
    public static final String PE_BAG = 'PE Bag';
    
    public static final String TG1 = 'TG1';
    public static final String STANDARD = 'standard';
    public static final String PRODUCT_SEGMENT = 'Laminate';
    public static final Decimal[] listMinMOQ = new List <Decimal>{10, 15, 20, 25, 50, 75, 100, 200, 300, 500,1000};
    public static final Decimal DEFAULT_PLATTS = 1400;
    public static final String METALLIZATION = 'Metallization';
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    
    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public String groupe;
    public Decimal dLength = 0;

    public static Boolean bHasRunned = false;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_EU_Laminate(PM_Selected_Tubes_Config__c  config) {
        
        log('PMCalculator_EU_Laminate start....');
        if(!bHasRunned){

            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, DS_Skonto_for_cash_payment__c, CreatedDate, Copy_quote_status__c
                from QuoteLineItem where Id = :config.Quote_item__c];
            }
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);
            log('VERSION='+version);
            log('LOCATION='+config.Location__c);

            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReferenceByProductSegment(config.Location__c, version, 'Laminate');   */
            // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReference(config.Location__c, 'Laminate', dt);
                
        }
        
    }

    public void calculate() {
        resetAllPMPrice();
        calculateBASIS_PRICE();
        calculateLENGTH_UPCHARGE();
        calculateHEAD_COLORATION();
        calculatePEAL_SEEL();
        calculateSLEEVE_MATERIAL();
        calculateSLEEVE_ASPECT();
        calculateCAP_BASIS_PRICE();
        //calculateCAP_COLORATION(); //Removed as it depends on Basis Price...Called from there
        calculateSHRINK_BAND();
        calculateCAP_METALISATION();
        calculateHOT_STAMP_TOP();
        calculateHOT_STAMP_CONTOURING();
        calculateCAP_SILKSCREEN();
        calculateMANUAL_CAPPING();
        calculatePRINTING_FLEXO_COLORS();
        calculateMETALLIC_FLEXO();
        calculateSILK_SCREEN();
        calculateCOLD_HOT_FOIL();
        calculateRONDELLE();
        calculateINSERT();
        calculateCOMBO();
        calculatePLATTS();
        calculateMANUAL_PACKING();
        calculatePE_BAG();
        calculateFREIGHT_PRICE();
        
        calculatePAYMENT_TERMS();
        calculateEND_OF_YEAR_REBATE();
        calculateSKONTO();
        calculateSTOCKAGE();
        
        
        upsert listDetailsToUpsert ExtId__c;
        // Added for Historisation
        upsert listPricingJunctionToUpsert Unique_Key__c;
        PMCalculatorUtility.calculateTotalMOQPRice(config.Id, null, config.Quote_item__c);
        // Added for Historisation
        if (mapPMTubesPricing.size()> 0) update mapPMTubesPricing.values();
    }
    
    
    public void calculateBASIS_PRICE() {
        log('*********** calculatePUMP ***********LINE='+ BASIS_PRICE);
        if(String.isNotBlank(config.Head_Name__c)){
            String ref = config.Diameter_mm__c + TG1 + config.Head_Name__c + '1-01';
            system.debug('REF='+ref);
            
            PM_Tubes_Pricing__c pricing =  mapPMTubesPricing.get(ref.toUpperCase());
            if (pricing == null) {
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.setListPrice(
                        getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE), -1));                
                } else {
                    listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, BASIS_PRICE));                             
                    // Added for Historisation
                    // Create Junction Object
                    
                    
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = pricing.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+BASIS_PRICE);
                        listPricingJunctionToUpsert.add(pj);
                        // Update Prices
                        if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = BASIS_PRICE;
                        } 
                }

            }
        }
        public void calculateLENGTH_UPCHARGE() {
            log('*********** calculateLENGTH_UPCHARGE ***********LINE='+ LENGTH_UPCHARGE);
            
            if (config.Sleeve_length_mm__c > 0 || config.Specific_length_mm__c > 0) {
        //if(String.isNotBlank(config.Diameter_mm__c)){
            Decimal length = (config.Specific_length_mm__c > 0)? config.Specific_length_mm__c:config.Sleeve_length_mm__c;

//            Decimal length = (config.Sleeve_length_mm__c > 0)? config.Sleeve_length_mm__c:config.Specific_length_mm__c;
system.debug('SLEEVE=' + config.Sleeve_length_mm__c + '=SPECIFIC=' + config.Specific_length_mm__c);
Double stdLengthForDiameter = 0;
            //stdLengthForDiameter = 25; 
            for(PM_Tubes_Config__c pm : [select Sleeve_length_mm__c
                from PM_Tubes_Config__c
                where Location__c = :config.Location__c
                and Diameter_mm__c  = :config.Diameter_mm__c
                and Tubes_segment__c= :PRODUCT_SEGMENT
                and Table_name__c = 'LENGTH'
                limit 1]) {     
               
               
                stdLengthForDiameter = pm.Sleeve_length_mm__c;
                    //Decimal.valueOf(pm.Sleeve_length_mm__c);
                }   
                Decimal nbAdd5mmvsStd = 0;
                if (length > 0) {
                    nbAdd5mmvsStd = (length - stdLengthForDiameter) /5;
                }
                system.debug('STDLENGTH=' +stdLengthForDiameter + '=LENGTH=' + length + '=MULTIPLIER=' + nbAdd5mmvsStd);
                
                String ref = config.Diameter_mm__c + TG1 + STANDARD + '3-01';
                system.debug('REF='+ref);
                

                List<PM_Price_Detail__c> prices = getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, LENGTH_UPCHARGE);
                for (PM_Price_Detail__c price : prices ) {
                   
                    price.Is_calculated__c = (price.List_Price__c == -1) ?  false : true;
                    price.List_Price__c = (price.List_Price__c == -1) ? price.List_Price__c: price.List_Price__c * nbAdd5mmvsStd;
                    
                    listDetailsToUpsert.add(price); 
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
            //listDetailsToUpsert.addAll();             

        }        
        
    }
    public void calculateHEAD_COLORATION() {
        log('*********** calculateHEAD_COLORATION ***********LINE='+ HEAD_COLORATION + '=' +config.Head_Color__c);
        if(String.isNotBlank(config.Head_Color__c) || String.isNotBlank(config.Head_Aspect__c)){
            String ref = config.Diameter_mm__c + TG1 + STANDARD;
            if ('Pearl'.equalsIgnoreCase(config.Head_Aspect__c) || !'white / natural'.equalsIgnoreCase(config.Head_Color__c)) {
              ref += '5-03'; 
          }
          
          system.debug('REF='+ref);
          listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, HEAD_COLORATION));             
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
    log('*********** calculatePEAL_SEEL ***********LINE='+ PEAL_SEEL);
    if('Yes'.equalsIgnoreCase(config.Peel_Seal__c)){
        //Start Modif ref price Ticket 7005
          //modif peel seal ref rolledback
          //String ref = config.Diameter_mm__c + TG1 + STANDARD + '10-01';
         String ref = config.Diameter_mm__c+config.Cap_Eurocode__c+'Peel seal ';
            if(String.isNotBlank(config.Printing_technologies__c) 
                     && 
               config.Printing_technologies__c.contains('Silkscreen')
              )    ref += 'Silkscreen printing';
        else   ref += 'Other printing technology';
          system.debug('REF='+ref);
        //end Modif 7005
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()) != null ? mapPMTubesPricing.get(ref.toUpperCase()): mapPMTubesPricing.get('LaminatePeel Seal Specific'.toUppercase()), TUBE_HEAD, PEAL_SEEL));
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
    }        
}
public void calculateSLEEVE_MATERIAL() {
    log('*********** calculateSLEEVE_MATERIAL ***********LINE='+ SLEEVE_MATERIAL +'=' + config.Sleeve_Material_Mix__c);
    if(String.isNotBlank(config.Sleeve_Material_Mix__c)){
        
        String sleeveMaterialType = '';
        for(PM_Tubes_Config__c pm : [select MATIERE_JUPE_Type__c 
            from PM_Tubes_Config__c
            where Location__c = :config.Location__c
            and SLEEVE_MATERIAL_MIX__c  = :config.Sleeve_Material_Mix__c
            and Tubes_segment__c= :PRODUCT_SEGMENT
            and Table_name__c = 'MATIERE JUPE'
            limit 1]) {     
           
           
            sleeveMaterialType = pm.MATIERE_JUPE_Type__c;
        }   
        
        
        String ref = config.Diameter_mm__c + TG1 + STANDARD + sleeveMaterialType;
        system.debug('REF='+ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), WEB, SLEEVE_MATERIAL));             
        // Added for Historisation
        // Create Junction Object
        PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
        if( dp != null){
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+WEB+
                                                                                  '_'+SLEEVE_MATERIAL);
            listPricingJunctionToUpsert.add(pj);
        }
        // Update Prices
        if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                    mapPMTubesPricing.get(ref.toUppercase()).Section__c = WEB;
                                    mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_MATERIAL;
        }
    } 
}

public void calculateSLEEVE_ASPECT() {
    log('*********** calculateSLEEVE_ASPECT ***********LINE='+ SLEEVE_ASPECT +'=' + config.Sleeve_Aspect__c);
   /* if('Matte'.equalsIgnoreCase(config.Sleeve_Finish_name__c) || 'Matte & Gloss'.equalsIgnoreCase(config.Sleeve_Finish_name__c)){
        String ref = config.Diameter_mm__c + TG1 + STANDARD + '10-04';
        system.debug('REF='+ref);
        listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), WEB, SLEEVE_ASPECT));             

    }   */
    if(String.isNotBlank(config.Sleeve_Finish_name__c))
    {
        String ref='';
        list<PM_Tubes_Config__c> pm=[select MATIERE_JUPE_Type__c 
            from PM_Tubes_Config__c
            where Location__c = :config.Location__c
            and Sleeve_Finish_name__c  = :config.Sleeve_Finish_name__c
            and Tubes_segment__c= :PRODUCT_SEGMENT
            and Table_name__c = 'Code Sleeve Finish'
            and (MATIERE_JUPE_Type__c != '' or MATIERE_JUPE_Type__c != null)
            limit 1];
        
        if (pm.size()>0) ref = config.Diameter_mm__c + TG1 + STANDARD + pm.get(0).MATIERE_JUPE_Type__c;
        system.debug('REF='+ref);
        if(ref != '') 
        {
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), WEB, SLEEVE_ASPECT));    
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = dp.Id, 
                                                                         Unique_Key__c = config.Id+'_'+WEB+
                                                                                      '_'+SLEEVE_ASPECT);
                listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                        mapPMTubesPricing.get(ref.toUppercase()).Section__c = WEB;
                                        mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_ASPECT;
            }
        }         
        
    }      
    
}

public void calculateCAP_BASIS_PRICE() {
    log('*********** calculateCAP_BASIS_PRICE ***********LINE='+ CAP_BASIS_PRICE +'=' + config.Cap_Eurocode__c);
    if(String.isNotBlank(config.Cap_Eurocode__c) &&  !'NO'.equalsIgnoreCase(config.Cap_Eurocode__c)){        
        String ref = config.Diameter_mm__c + TG1 + config.Head_Name__c + config.Cap_Eurocode__c + 'WHITE';
        system.debug('REF='+ref);
        PM_Tubes_Pricing__c pricing = mapPMTubesPricing.get(ref.toUpperCase());
        List<PM_Price_Detail__c> capBasisPriceDetails = null;
        if (pricing == null) {
           capBasisPriceDetails = PMCalculatorUtility.setListPrice(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), CAP, CAP_BASIS_PRICE), -1);
           
        } else {
            capBasisPriceDetails = getLineDetails(config, pricing, CAP, CAP_BASIS_PRICE);     
            // Added for Historisation
            // Create Junction Object
            
            PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                         Tube_Pricing__c = pricing.Id, 
                                                                         Unique_Key__c = config.Id+'_'+CAP+
                                                                                      '_'+CAP_BASIS_PRICE);
            listPricingJunctionToUpsert.add(pj);
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                        mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                                        mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_BASIS_PRICE;
            }        
        }
        listDetailsToUpsert.addAll(capBasisPriceDetails);
        calculateCAP_COLORATION(capBasisPriceDetails);
    }
}
public void calculateCAP_COLORATION(List<PM_Price_Detail__c> capBasisPriceDetails) {
    log('*********** calculateCAP_COLORATION ***********LINE='+ CAP_COLORATION);
    if(String.isNotBlank(config.Cap_Eurocode__c) &&  !'NO'.equalsIgnoreCase(config.Cap_Eurocode__c)){
        String ref = config.Diameter_mm__c + TG1 + config.Head_Name__c + config.Cap_Eurocode__c;
        
        if ('Pearl'.equalsIgnoreCase(config.Cap_Aspect__c) || 'Standard color'.equalsIgnoreCase(config.Cap_Color__c)
            || 'Dark color'.equalsIgnoreCase(config.Cap_Color__c)) {
            ref += 'COLORED';
            } else {
                ref += 'WHITE';                         
            }
            system.debug('REF='+ref);
            
            PM_Tubes_Pricing__c pricing = mapPMTubesPricing.get(ref.toUpperCase());
            if (pricing == null) {
                PMCalculatorUtility.setListPrice(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), CAP, CAP_COLORATION), -1);
                } else {
                    List<PM_Price_Detail__c> capColorationDetails =  getLineDetails(config, pricing, CAP, CAP_COLORATION);              
                    // Added for Historisation
                    // Create Junction Object
                    
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                                 Tube_Pricing__c = pricing.Id, 
                                                                                 Unique_Key__c = config.Id+'_'+CAP+
                                                                                              '_'+CAP_COLORATION);
                    listPricingJunctionToUpsert.add(pj);
                    // Update Prices
                    if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_COLORATION;
                    } 
                    for (PM_Price_Detail__c capColorationDetail : capColorationDetails) {
                        for (PM_Price_Detail__c capBasisPriceDetail : capBasisPriceDetails) {
                            if (capColorationDetail.MOQ_Min__c == capBasisPriceDetail.MOQ_Min__c) {
                                system.debug(capColorationDetail.MOQ_Min__c + '=' +capColorationDetail.List_Price__c+ '-'+capBasisPriceDetail.List_Price__c);
                                capColorationDetail.List_Price__c = (capColorationDetail.List_Price__c == -1)
                                ? capColorationDetail.List_Price__c
                                : capColorationDetail.List_Price__c - capBasisPriceDetail.List_Price__c;
                            }
                        }
                    }
                    listDetailsToUpsert.addAll(capColorationDetails);
                    
                }
                
            }
        }
        public void calculateSHRINK_BAND() {
            log('*********** calculateSHRINK_BAND='+ SHRINK_BAND + 'NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
            system.debug('NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
        }
        public void calculateCAP_METALISATION() {
            log('*********** calculateCAP_METALISATION ***********LINE='+ CAP_METALISATION);
            if(config.Metallization__c == YES/* || config.Metallization__c != '0'*/){
                String ref = TG1 + config.Head_Name__c + config.Cap_Eurocode__c + METALLIZATION + config.Metallization_Type__c;
                system.debug('@@qama ref met '+ref);
                system.debug('@@qama  mapPMTubesPricing.get(ref.toUppercase()) '+ mapPMTubesPricing.get(ref.toUppercase()));
                List<PM_Price_Detail__c> prices = PMCalculatorUtility.getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_METALISATION);
                // Added for Historisation
                // Create Junction Object
                PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
                if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+CAP+
                                                                                          '_'+CAP_METALISATION);
                    listPricingJunctionToUpsert.add(pj);
                }
                // Update Prices
                if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_METALISATION;
                } 
           // /* decommented by maryem qada ==> to set -1 if no price was found
           for (PM_Price_Detail__c price : prices) {
            if (price.List_Price__c == 0) {
                price.List_Price__c = -1;
            }
        }
           // */
           listDetailsToUpsert.addAll(prices);
       }
   }
   public void calculateHOT_STAMP_TOP() {
    log('*********** calculateHOT_STAMP_TOP ***********LINE='+ HOT_STAMP_TOP + 'NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
}
public void calculateHOT_STAMP_CONTOURING() {
    log('*********** calculateHOT_STAMP_CONTOURING ***********LINE='+ HOT_STAMP_CONTOURING + 'NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
}
public void calculateCAP_SILKSCREEN() {
    log('*********** calculateCAP_SILKSCREEN ***********LINE='+ CAP_SILKSCREEN + 'NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
}
public void calculateMANUAL_CAPPING() {
    log('*********** calculateMANUAL_CAPPING ***********LINE='+ MANUAL_CAPPING+ 'NOT IMPLEMENTED IN EXCEL SHEET...ALWAYS ZERO');
    
    
}
public void calculatePRINTING_FLEXO_COLORS() {
    log('*********** calculatePRINTING_FLEXO_COLORS ***********LINE='+ PRINTING_FLEXO_COLORS);
    
    if (config.NB_Flexo_Colors__c > 0) {
        
        String ref = config.Diameter_mm__c + TG1 + STANDARD;
        
        if (config.NB_Flexo_Colors__c < 7) {
            ref += '6-07';
            } else {
                ref += '6-09';
            }
            
            // modified by safa J to display specific if the config doesn't exist ------> ticket n°3072                        
            List<PM_Price_Detail__c> prices = getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, PRINTING_FLEXO_COLORS);
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
                                                                                          '_'+PRINTING_FLEXO_COLORS);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = PRINTING_FLEXO_COLORS;
            } 
            //listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, PRINTING_FLEXO_COLORS));             
            
        }
        
    }
    
    public void calculateMETALLIC_FLEXO() {
        log('*********** calculateMETALLIC_FLEXO ***********LINE='+ METALLIC_FLEXO);
        if ('Yes'.equalsIgnoreCase(config.Metalic_Flexo__c)) {
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '8-01';
            
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, METALLIC_FLEXO));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+METALLIC_FLEXO);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = METALLIC_FLEXO;
            } 
        }        
        
    }
    
    public void calculateSILK_SCREEN() {
        log('*********** calculateSILK_SCREEN ***********LINE='+ SILK_SCREEN);
        if ('Yes (1 color)'.equalsIgnoreCase(config.Silkscreen__c)) {
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '7-01';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, SILK_SCREEN));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+SILK_SCREEN);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SILK_SCREEN;
            } 
        }        
    }

    public void calculateCOLD_HOT_FOIL() {
        log('*********** calculateCOLD_HOT_FOIL ***********LINE='+ COLD_HOT_FOIL);
       /* if ('Standard'.equalsIgnoreCase(config.Cold_Hot_Foil__c)) {
        //if ('Yes'.equalsIgnoreCase(config.Cold_Hot_Foil__c)) { Commented by maryem qada ==> new values yes -> standard
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '9-01';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, COLD_HOT_FOIL));                         
        } */
        if(String.isNotBlank(config.Cold_Hot_Foil__c))
     {
        String ref='';
        List<PM_Tubes_Config__c> pm=[select MATIERE_JUPE_Type__c 
            from PM_Tubes_Config__c
            where Location__c = :config.Location__c
            and Cold_Hot_Foil__c  = :config.Cold_Hot_Foil__c
            and Tubes_segment__c= :PRODUCT_SEGMENT
            and Table_name__c = 'Code Cold Foil'
            and (MATIERE_JUPE_Type__c != '' or MATIERE_JUPE_Type__c != null)
            limit 1];
        
        if (pm.size()>0) ref = config.Diameter_mm__c + TG1 + STANDARD + pm.get(0).MATIERE_JUPE_Type__c;
        system.debug('REF='+ref);
        if(ref!='')
        {
           listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, COLD_HOT_FOIL));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                          '_'+COLD_HOT_FOIL);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = COLD_HOT_FOIL;
            }
        }
     }        
        
    }
    public void calculateRONDELLE() {
        log('*********** calculateRONDELLE ***********LINE='+ RONDELLE);
        if ('Yes'.equalsIgnoreCase(config.Rondelle__c)) {
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '10-02';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), OTHER_PARTS, RONDELLE));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+OTHER_PARTS+
                                                                                          '_'+RONDELLE);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHER_PARTS;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = RONDELLE;
            } 
        }          
    }
    public void calculateINSERT() {
        log('*********** calculatePUMP ***********LINE='+ INSERT_LINE);
        if ('Yes'.equalsIgnoreCase(config.insert__c)) {
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '10-03';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), OTHER_PARTS, INSERT_LINE));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+OTHER_PARTS+
                                                                                          '_'+INSERT_LINE);
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHER_PARTS;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = INSERT_LINE;
            } 
        } 
    }
    public void calculateCOMBO() {
        log('*********** calculateCOMBO ***********LINE='+ COMBO);
        System.debug('Versions=' + config.Combo_Num_Versions__c + ';Artwork='+config.Combo_Num_Tubes_Artwork__c + ';PlateChanges='+ config.Combo_Num_Plate_Changes__c);
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
        log('*********** calculatePUMP ***********LINE='+ PLATTS);
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
        Decimal length = (config.Sleeve_length_mm__c > 0)? config.Sleeve_length_mm__c:config.Specific_length_mm__c; 
        
        if(config.Diameter_mm__c > 0 && length > 0 && config.Nouveau_Platts__c > 0){
            for(PM_Tubes_Config__c pm : [select Platts_Poids_Jupe_nets__c, Platts_Poids_tete__c, Platts_bouchon__c
                from PM_Tubes_Config__c
                where Location__c = :config.Location__c
                and Tubes_segment__c = :PRODUCT_SEGMENT
                and Diameter_mm__c = :config.Diameter_mm__c
                and Table_name__c = 'Platts'
                limit 1]){
                system.debug(pm);                               
                Decimal poidJupe   = ((pm.Platts_Poids_Jupe_nets__c * length)/100) * 1.25;
                Decimal poidTete    = pm.Platts_Poids_tete__c  * 1.25; 
                Decimal poidBouchon    = pm.Platts_bouchon__c  * 1.05;
                Decimal totalPoids = poidJupe + poidTete + poidBouchon;
                Decimal plattsDif = (config.Nouveau_Platts__c - DEFAULT_PLATTS) / 1000;
                Decimal dPlatts = totalPoids * plattsDif;                                
                
                System.debug( 'DLENGHT=' + dLength + 'PLATTSDIF=' + plattsDif + '=poidJupe=' + poidJupe 
                    + '=poidTete=' + poidTete + '=poidBouchon=' + poidBouchon + '=dPlatts=' + dPlatts);                                 
                
                listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(getLineDetails(config, null, OTHERS, PLATTS), dPlatts * currencyRate));
            }
        }
        
        
    }
    

    //modified for ticket 6654----
    public void calculateSTOCKAGE() {
        log('*********** calculatePUMP ***********LINE='+ STOCKAGE);
        if(String.isNotBlank(config.Stockage__c)){
            /*for(PM_Tubes_Config__c tc : [select Weight_value__c
                from PM_Tubes_Config__c
                where Table_name__c = 'Stockage' 
                and Location__c = :config.Location__c
                and Stockage__c = :config.Stockage__c
                limit 1]){
                listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                    PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>{'APPLY_ZERO_PERCENT', PAYMENT_TERMS, END_OF_YEAR_REBATE, SKONTO}, config, (tc.Weight_value__c / 100), OTHERS, STOCKAGE)));                          
            }*/
                String ref='STOCKAGE'+ config.Stockage__c;
            if(mapPMTubesPricing.get(ref.toUpperCase())!= null) {
                listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setSpecificPriceToZero(
                                PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String>{
                                        'APPLY_ZERO_PERCENT', PAYMENT_TERMS, END_OF_YEAR_REBATE, SKONTO
                                }, config, (mapPMTubesPricing.get(ref.toUpperCase())).X10__c, OTHERS, STOCKAGE)));
            }
            }
        
    }    
    
    
     public void calculatePAYMENT_TERMS() {
        log('*********** calculatePAYMENT_TERMS ***********LINE='+ PAYMENT_TERMS);
        if(String.isNotBlank(config.Payment_terms__c)){
            /*for(PM_Tubes_Config__c tc : [select Weight_value__c
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
            String ref='PAYMENT'+ config.Payment_terms__c;
            //added by thanina 26/03
            if(mapPMTubesPricing.get(ref.toUpperCase())!= null)
            {
            listDetailsToUpsert.addAll(
            PMCalculatorUtility.setSpecificPriceToZero(
            PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set <String> {'APPLY_ZERO_PERCENT'
            }, config,(mapPMTubesPricing.get(ref.toUpperCase())).X10__c, OTHERS, PAYMENT_TERMS)));
        }
        }

        
    }
    //end Modif Ticket 6654-----
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
                    
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>{'APPLY_ZERO_PERCENT'}, config, dPercent, OTHERS, END_OF_YEAR_REBATE));
                    
                }        
                
            }
   /* */
    public void calculateSKONTO() {
        log('*********** calculateSKONTO ***********LINE='+ SKONTO);
         if(qli.DS_Skonto_for_cash_payment__c != null && qli.DS_Skonto_for_cash_payment__c != 'No'){
            listDetailsToUpsert.addAll(
                PMCalculatorUtility.calcGroupOther(
                listDetailsToUpsert, 
                new Set<String>{'APPLY_ZERO_PERCENT', END_OF_YEAR_REBATE}, 
                config, 
                PMCalculatorUtility.calculateSKONTO(qli.Customer_Country__c, qli.DS_Skonto_for_cash_payment__c), 
                OTHERS, 
                SKONTO));   
         }
                                          
    }//end method calculateSKONTO



    public void calculateFREIGHT_PRICE() {
        log('*********** calculateFREIGHT_PRICE ***********LINE='+ FREIGHT_PRICE);
        // Freight Price
        if('DAP'.equalsIgnoreCase(config.Delivery__c)){
            // config.Destination__c
            String ref = config.Diameter_mm__c + TG1;
            for(PM_Tubes_Config__c tc : [select Plastic_Code__c
                from PM_Tubes_Config__c
                where Table_name__c = 'Delivery-Destination-Plastic Code' 
                and Location__c = :config.Location__c                                            
                and Destination__c = :config.Destination__c
                limit 1]){
                ref += tc.Plastic_Code__c;

            }
            System.debug('## Freight Price : ' + ref);
            listDetailsToUpsert.addAll(PMCalculatorUtility.setSpecificPriceToZero(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, FREIGHT_PRICE)));
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
        
        
        if ('Yes'.equalsIgnoreCase(config.insert__c)) {
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '10-03';
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), OTHERS, FREIGHT_PRICE));                         
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                    PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                             Tube_Pricing__c = dp.Id, 
                                                                             Unique_Key__c = config.Id+'_'+OTHERS+
                                                                                          '_'+FREIGHT_PRICE+'_2');
                    listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                                                mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                                                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = FREIGHT_PRICE;
            } 
        }        
        
    }
    public void calculateMANUAL_PACKING() {
        log('*********** calculateMANUAL_PACKING ***********LINE='+ MANUAL_PACKING);        
        if('Yes'.equalsIgnoreCase(config.Manual_Packing__c)){
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '3-02';
            system.debug(ref);
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), OTHERS, MANUAL_PACKING));
        }         
    }
    public void calculatePE_BAG() {
        log('*********** calculatePE_BAG ***********LINE='+ PE_BAG);
        if('Yes'.equalsIgnoreCase(config.PE_Bag__c)){
            String ref = config.Diameter_mm__c + TG1 + STANDARD + '13-01';
            system.debug(ref);
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
    
    
    public void resetAllPMPrice() {       
     
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, LENGTH_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, PEAL_SEEL));
        
        blankPMPrices.addAll(getLineDetails(config, null, WEB, SLEEVE_MATERIAL));
        blankPMPrices.addAll(getLineDetails(config, null, WEB, SLEEVE_ASPECT));
        
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_COLORATION));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, SHRINK_BAND));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_METALISATION));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, HOT_STAMP_TOP));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, HOT_STAMP_CONTOURING));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_SILKSCREEN));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, MANUAL_CAPPING));
        
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, PRINTING_FLEXO_COLORS));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, METALLIC_FLEXO));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, SILK_SCREEN));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, COLD_HOT_FOIL));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHER_PARTS, RONDELLE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHER_PARTS, INSERT_LINE));
        
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, COMBO));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, PLATTS));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, PAYMENT_TERMS));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, SKONTO));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, STOCKAGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, FREIGHT_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, MANUAL_PACKING));
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
    public List <PM_Price_Detail__c> getLineDetails(PM_Selected_Tubes_config__c config, PM_Tubes_Pricing__c tp, String section, String name){
        
        // We set the currency rate to be 
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           
        
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
                    new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = 1000, List_Price__c = (tp.X500__c == null? 0 : (tp.X500__c == -1 ? -1 : tp.X500__c * currencyRate))),
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