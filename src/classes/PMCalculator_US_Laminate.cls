/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Class used to calculate PM Price details for US Tube Laminate
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   05-MAR-2017  Hasseeb             Initial version
 *****************************************************************************/ 

public class PMCalculator_US_Laminate {
    
    // sections
    public static final String TUBE_HEAD = 'Tube & Head';
    public static final String SLEEVE = 'Sleeve';
    public static final String CAP = 'Cap';
    public static final String PRINTING = 'Printing';  
    public static final String PACKING = 'Packing';  
    public static final String OTHERS = 'Others';
  
    // SUB-SECTIONS
    // sections
    public static final String BASIS_PRICE = 'Tube Basis Price';
    public static final String LENGTH_UPCHARGE = 'Length upcharge';
    public static final String HEAD_ASPECT = 'Head Aspect';
    public static final String HEAD_COLORATION = 'Head Coloration';
    public static final String HEAD_BARRIER = 'Head Barrier';
    public static final String FOIL_SEAL = 'Foil Seal';
    
    public static final String SLEEVE_WEB_TYPE = 'Web Type';
    
    public static final String CAP_BASIS_PRICE = 'Cap Basis Price';
    public static final String CAP_CONSIGN = 'Cap consign';
    public static final String CAP_FEATURE = 'Cap feature';
        
    public static final String OFFSET = 'Offset';
    public static final String FLEXO = 'Flexo';
    public static final String SILKSCREEN = 'Silkscreen';
    public static final String HOLOGRAM = 'Hologram';
    public static final String PRINGING_EFFECT = 'Printing effect';
    public static final String COLDSTAMP = 'Coldstamp';

    
    public static final String PALLET = 'Pallet';
    public static final String POLYSHEET = 'Polysheet';
    
    public static final String COMBO_UPCHARGE = 'Combo Upcharge';
    public static final String QUALITY_UPCHARGE = 'Quality Upcharge';
    public static final String LOT_PREPARATION_UPCHARGE = 'Lot Preparation Upcharge';
    
    public static final String UPHOLD_UPCHARGE = 'Uphold Upcharge';
    public static final String MARKET_SEGMENT_PREMIUM = 'Market Segment Premium';
    public static final String RESIN_ADJUSTMENT = 'Resin Adjustment';
    public static final String END_OF_YEAR_REBATE = 'End of Year Rebate';
    
    //added Ticket 6329
     public static final String MISCELLANEOUS_ADJUSTMENTS = 'Miscellaneous adjustments';
    //***************/
    public static final String CODE = 'CURRENT NA';
    
     public static final double MM_CONVERSION = 1;
    
    public PM_Selected_Tubes_Config__c config;
    public QuoteLineItem qli;
    public Map <String, PM_Tubes_Pricing__c> mapPMTubesPricing;
    public List <PM_Price_Detail__c> listDetailsToUpsert = new List <PM_Price_Detail__c>();
    public String groupe;
    public Decimal dLength = 0;

    public static Boolean bHasRunned = false;
    // Added for Historisation
    public List <PM_Config_to_Pricing__c> listPricingJunctionToUpsert = new List <PM_Config_to_Pricing__c>();

    public PMCalculator_US_Laminate(PM_Selected_Tubes_Config__c  config) {
        
        log('PMCalculator_US_Laminate start....');
        if(!bHasRunned){


            
            this.config = config;
            if(String.isNotBlank(config.Quote_item__c)){
                qli = [select Customer_end_of_year_rebate__c, Customer_Country__c, Quote.Skonto_for_cash_payment__c,
                       Market_Of_Application__c, CreatedDate, Copy_quote_status__c
                        from QuoteLineItem where Id = :config.Quote_item__c];
            }
            
           
          
           /* Decimal version = PMCalculatorUtility.getPMPricingVersion(config.Location__c, 'Tubes', config.Product_segment__c);
            log('VERSION='+version);
            log('LOCATION='+config.Location__c);

            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReferenceByProductSegment(config.Location__c, version, 'Laminate'); */    
            // Added for Historisation
            Date dt; 
            if (qli.Copy_quote_status__c == 'Draft' || qli.Copy_quote_status__c == 'Simulation') dt = Date.today();
            else dt = Date.valueOf(qli.CreatedDate);
            mapPMTubesPricing = PMCalculatorUtility.getPMTubesPricingReference(config.Location__c, 'Laminate', dt);
                      
        }
        
    }    
    
   //********* Adde Ticket 6329*/ 
    public void calculateMISCELLANEOUS_ADJUSTMENTS(){
        log('*********** calculate********: MISCELLANEOUS_ADJUSTMENTS');
        listDetailsToUpsert.addAll(getLineDetails(config, null, OTHERS,MISCELLANEOUS_ADJUSTMENTS ));                    
    }       
    //****end  */

    public void calculate() {
        resetAllPMPrice();
        calculateBASIS_PRICE();
        calculateLENGTH_UPCHARGE();
        calculateHEAD_ASPECT();
        calculateHEAD_COLORATION();
        calculateHEAD_BARRIER();
        calculateFOIL_SEAL();
        
        calculateSLEEVE_WEB_TYPE();
        
        calculateCAP_BASIS_PRICE();
        calculateCAP_CONSIGN();
        calculateCAP_FEATURE();
            
        calculateOFFSET();
        calculateFLEXO();
        calculateSILKSCREEN();
        calculateHOLOGRAM();
        calculatePRINGING_EFFECT();
        calculateCOLDSTAMP();
    
        
        calculatePALLET();
        calculatePOLYSHEET();
        
        calculateCOMBO_UPCHARGE();
        calculateQUALITY_UPCHARGE();
        calculateUPHOLD_UPCHARGE();
        calculateLOT_PREPARATION_UPCHARGE();
        calculateMARKET_SEGMENT_PREMIUM();
        calculateRESIN_ADJUSTMENT();
        calculateEND_OF_YEAR_REBATE();
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
    
    
    public void calculateBASIS_PRICE(){
        //log('*********** calculateBASIS_PRICE ***********LINE='+ BASIS_PRICE);
        if(String.isNotBlank(config.Diameter_inches__c) && !'Delivered'.equalsIgnoreCase(config.Incoterm__c)){
            String ref =  CODE + config.Diameter_inches__c + 'Tube (base listprice)';
            system.debug('REF='+ref); 
            listDetailsToUpsert.addAll(getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, BASIS_PRICE));             
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
        
        if ('Delivered'.equalsIgnoreCase(config.Incoterm__c)) {
             listDetailsToUpsert.addAll(
                 PMCalculatorUtility.setListPrice(
                     getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE), -1));             
     
        }
        
        
    }
    public void calculateLENGTH_UPCHARGE(){
        //log('*********** calculateLENGTH_UPCHARGE ***********LINE='+ LENGTH_UPCHARGE +'='+ config.Sleeve_Length_inches__c);
        log('*********** calculateLENGTH_UPCHARGE ***********LINE='+ config.Sleeve_Length_inches__c + ' ------ ' + config.Specific_Length_inches__c);
        String length = String.isNotBlank(config.Specific_Length_inches__c)? config.Specific_Length_inches__c : config.Sleeve_Length_inches__c;
        log('*********** length ***********LINE='+ length);
        if (String.isNotBlank(length)) {
            double lengthDecimal = convertLengthFractionToDecimal(length);
            double sleeveLengthPlant = 0;
            for(PM_Tubes_Config__c pm : [select Id, Diameter_inches__c, Plant__c, Min_STD_Length_inches__c
                                            from PM_Tubes_Config__c
                                            where Location__c = :config.Location__c
                                            and Diameter_inches__c  = :config.Diameter_inches__c
                                            and Tubes_segment__c= 'Laminate'
                                            and Table_name__c = 'Sleeve Length & Plant'
                                            limit 1]) {     
                 
                sleeveLengthPlant = convertLengthFractionToDecimal(pm.Min_STD_Length_inches__c);                          
                //stdLengthForDiameter = pm.Sleeve_length_mm__c;
                    //Decimal.valueOf(pm.Sleeve_length_mm__c);
            }            
            
            double multiplier = (lengthDecimal - sleeveLengthPlant)/0.25 * MM_CONVERSION; 
            System.debug( 'DIAM=' + config.Diameter_inches__c + '=lengthDecimal=' +lengthDecimal + '=sleeveLengthPlant=' + sleeveLengthPlant); 
            system.debug('MULTIPLIER='+multiplier);
            String ref = CODE + config.Diameter_inches__c + 'Length ' + config.Sleeve_Material_Mix__c;
            System.debug('REF=' +ref);
            List<PM_Price_Detail__c> details = getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, LENGTH_UPCHARGE);
            for (PM_Price_Detail__c priceDetail : details) {
                if (priceDetail.List_Price__c == 0) {
                    priceDetail.List_Price__c = -1;
                } else {
                   priceDetail.List_Price__c = priceDetail.List_Price__c * multiplier;
                }
            }
            listDetailsToUpsert.addAll(details);
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

/*            listDetailsToUpsert.addAll(PMCalculatorUtility.setPriceMultiplier(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, LENGTH_UPCHARGE), multiplier));             
*/           
        }
        
        
        
    }
    
    public static double convertLengthFractionToDecimal(String lengthInches) {
        Double decimalLength = 0;
        if (lengthInches.contains('/') && lengthInches.contains(' ')) {
            String fraction = lengthInches.substringAfter(' ');
            String wholeNumber = lengthInches.substringBefore(' ');
            String denominator = lengthInches.substringAfter('/');
            String numerator = fraction.substringBefore('/');
             decimalLength = Double.valueOf(wholeNumber) + (Double.valueOf(numerator)/Double.valueOf(denominator));
        } else {
            decimalLength = Double.valueOf(lengthInches);
        }
        System.debug('CONVERSION=' + lengthInches + '=CONVERTED=' +decimalLength);
        return decimalLength;
    }
    
    public void calculateHEAD_ASPECT(){
        //log('*********** calculateHEAD_ASPECT ***********LINE='+ HEAD_ASPECT);
        if(String.isNotBlank(config.Head_Name__c)){
            String ref = CODE + config.Diameter_inches__c + config.Head_Name__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, HEAD_ASPECT)); 
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+HEAD_ASPECT);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HEAD_ASPECT;
            }
        }         
    }
    
    
    public void calculateHEAD_COLORATION(){
        //log('*********** calculateHEAD_COLORATION ***********LINE='+ HEAD_COLORATION);
         
        if(String.isNotBlank(config.Head_Color__c)){
            String headColor = '';
            if ('White'.equalsIgnorecase(config.Head_Color__c)/* || 'Natural'.equalsIgnorecase(config.Head_Color__c)*/) {
                headColor = 'White/Natural';
            } else {
                headColor = 'Standard Color';
            }              
            
            String ref = CODE + config.Diameter_inches__c + headColor;
            system.debug('REF='+ref);
            
            List<PM_Price_Detail__c> prices = getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, HEAD_COLORATION);
            
            if(headColor == 'Standard Color') // added by Maryem QADA => to not consider no upcharge as a specific price for white
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
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+HEAD_COLORATION);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HEAD_COLORATION;
            }

            //listDetailsToUpsert.addAll(
            //    getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, HEAD_COLORATION));             
        }         
      
        
    }
    public void calculateHEAD_BARRIER(){
        //log('*********** calculateHEAD_BARRIER ***********LINE='+ HEAD_BARRIER);
        if(String.isNotBlank(config.Rondelle__c)){
            String ref = CODE + config.Diameter_inches__c + config.Rondelle__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, HEAD_BARRIER));   
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+HEAD_BARRIER);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HEAD_BARRIER;
            }
        }         
    }
    
  
    public void calculateFOIL_SEAL(){
       
        //log('*********** calculateFOIL_SEAL ***********LINE='+ FOIL_SEAL);
        // if('Yes'.equalsIgnoreCase(config.Peel_Seal__c)){
           // String ref = CODE + config.Diameter_inches__c + 'Peel Seal';
            String ref = CODE + config.Diameter_inches__c + config.Peel_Seal__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
            getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), TUBE_HEAD, FOIL_SEAL));       
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+TUBE_HEAD+
                                                                                  '_'+FOIL_SEAL);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = TUBE_HEAD;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = FOIL_SEAL;
            }
        //}         
         
    }
    
    public void calculateSLEEVE_WEB_TYPE(){
        //log('*********** calculateSLEEVE_WEB_TYPE ***********LINE='+ SLEEVE_WEB_TYPE);
        if(String.isNotBlank(config.Sleeve_Material_Mix__c)){
            String ref = CODE + config.Diameter_inches__c + config.Sleeve_Material_Mix__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), SLEEVE, SLEEVE_WEB_TYPE));   
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+SLEEVE+
                                                                                  '_'+SLEEVE_WEB_TYPE);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = SLEEVE;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SLEEVE_WEB_TYPE;
            }
        }         
    }
    
    public void calculateCAP_BASIS_PRICE() {
        //log('*********** calculateCAP_BASIS_PRICE ***********LINE='+ CAP_BASIS_PRICE);
        String capEuroCode = config.Cap_Eurocode__c; //X3
        String consignedCap = (String.isNotBlank(config.Consigned_Cap__c) ? config.Consigned_Cap__c.toUpperCase(): 'NO'); //AC3
        string sleevematerial = (config.Sleeve_type__c == null)?'':config.Sleeve_type__c;
        
        if (String.isBlank(config.Cap_Eurocode__c) || consignedCap == 'YES' 
                || config.Cap_Eurocode__c == 'CD1' || sleevematerial.startsWith('O')) {
            //Price should be zero here
            System.debug('createCapBasisPM criteria not matched...');
            
        } else {
            String capColor = '';
           if ('White'.equalsIgnoreCase(config.Cap_Color__c) || 'Natural'.equalsIgnoreCase(config.Cap_Color__c)) {
               capColor = 'WHITE/NATURAL';
           } else {
               capColor = 'Standard Color';
           }
                        
            String ref = config.Cap_Eurocode__c + capColor;
            System.debug('REF='+ref);
            System.debug('REF UPPER='+ref.toUppercase());
            List<PM_Price_Detail__c> details = getLineDetails(config, mapPMTubesPricing.get(ref.toUppercase()), CAP, CAP_BASIS_PRICE);
            system.debug(details);
            Integer index = 0;
            
            //Get the valeu from MOQ 20, because there is no price for MOQ25
            for (PM_Price_Detail__c detail: details) {
                PM_Price_Detail__c previousDetail = details.get((index ==0 ? 0 : index -1));
                if (detail.MOQ_Min__c == 25) {
                    detail.List_Price__c = previousDetail.List_Price__c;
                }
                index++;
            }
            
            system.debug(details);
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
    
    
    public void calculateCAP_CONSIGN(){
        log('*********** calculateCAP_CONSIGN ***********LINE='+ CAP_CONSIGN);
        if('Yes'.equalsIgnoreCase(config.Consigned_Cap__c)){
            String ref = CODE + config.Diameter_inches__c + 'Consigned Caps';
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), CAP, CAP_CONSIGN));    
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+CAP+
                                                                                  '_'+CAP_CONSIGN);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_CONSIGN;
            }
        }         
    }

    public void calculateCAP_FEATURE(){
        log('*********** calculateCAP_FEATURE ***********LINE='+ CAP_FEATURE);
        if(String.isNotBlank(config.Shrink_band__c)){
            String ref = 'CAP_FEATURE_PRICE' + '_' + config.Shrink_band__c + '_' + config.Diameter_inches__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), CAP, CAP_FEATURE));          

            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+CAP+
                                                                                  '_'+CAP_FEATURE);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = CAP;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = CAP_FEATURE;
            }
         
        }
        
        
    }
    
    public void calculateOFFSET(){
        log('*********** calculateOFFSET ***********LINE='+ OFFSET + '='+config.NB_Offset_Colors__c);
        if(config.NB_Offset_Colors__c > 4){
            String ref = CODE + config.Diameter_inches__c + 'Offset ' + config.NB_Offset_Colors__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, OFFSET));     
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                  '_'+OFFSET);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = OFFSET;
            }
            
        }        
    }
    public void calculateFLEXO(){
        log('*********** calculateFLEXO ***********LINE='+ FLEXO);
        if(config.NB_Flexo_Colors__c > 4){
            String ref = CODE + config.Diameter_inches__c + 'Flexo ' + config.NB_Flexo_Colors__c;
            log('REF='+ref);
            system.debug('REF='+ref);

            // modified by safa J to display specific if the config doesn't exist ------> ticket n°3072                        
            List<PM_Price_Detail__c> prices = getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, FLEXO);
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
                                                                                  '_'+FLEXO);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = FLEXO;
            }
            //listDetailsToUpsert.addAll(
           //     getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, FLEXO));             
            
        }     
        
    }
    public void calculateSILKSCREEN(){
        log('*********** calculateSILKSCREEN ***********LINE='+ SILKSCREEN);
        if(config.NB_SS_Colors__c > 0) {
            String ref = CODE + config.Diameter_inches__c + 'Silkscreen' + config.NB_SS_Colors__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, SILKSCREEN));   
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                  '_'+SILKSCREEN);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = SILKSCREEN;
            }
            
        }           
        
    }
    public void calculateHOLOGRAM(){
        log('*********** calculateHOLOGRAM ***********LINE='+ HOLOGRAM);
        if('Yes'.equalsIgnoreCase(config.Hologram__c)){
            String ref = CODE + config.Diameter_inches__c + 'Hologram';
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, HOLOGRAM));     
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                  '_'+HOLOGRAM);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = HOLOGRAM;
            }
        }            
            
        
    }
    public void calculatePRINGING_EFFECT(){
        log('*********** calculatePRINGING_EFFECT ***********LINE='+ PRINGING_EFFECT);
        if('360 degree'.equalsIgnoreCase(config.Printing_Effects__c)){            
            listDetailsToUpsert.addAll(PMCalculatorUtility.setListPrice(
                getLineDetails(config, null, PRINTING, PRINGING_EFFECT), 10));             
        }        
        
    }
    public void calculateCOLDSTAMP(){
        log('*********** calculateCOLDSTAMP ***********LINE='+ COLDSTAMP);
        if('Yes'.equalsIgnoreCase(config.Cold_Stamping__c)){            
            String ref = CODE + config.Diameter_inches__c + 'Coldstamping';
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PRINTING, COLDSTAMP));    
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+PRINTING+
                                                                                  '_'+COLDSTAMP);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PRINTING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = COLDSTAMP;
            }
           
        }         
        
    }

    public void calculatePALLET(){
        log('*********** calculatePALLET ***********LINE='+ PALLET);
        if(!'None'.equalsIgnoreCase(config.Pallet__c) && !'runner'.equalsIgnoreCase(config.Pallet__c)){            
            String ref = CODE + config.Diameter_inches__c + config.Pallet__c;
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PACKING, PALLET));  
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

    public void calculatePOLYSHEET(){
        log('*********** calculatePOLYSHEET ***********LINE='+ POLYSHEET);
        if('Yes'.equalsIgnoreCase(config.Polysheet__c)){            
            String ref = CODE + config.Diameter_inches__c + 'Polysheet';
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), PACKING, POLYSHEET)); 
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+PACKING+
                                                                                  '_'+POLYSHEET);
                        listPricingJunctionToUpsert.add(pj);
            }
            // Update Prices
            if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                mapPMTubesPricing.get(ref.toUppercase()).Section__c = PACKING;
                mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = POLYSHEET;
            }
           
        }          
    }

/*    public void calculateCOMBO_UPCHARGE(){
        log('*********** calculateCOMBO_UPCHARGE ***********LINE='+ COMBO_UPCHARGE);
        if(config.Number_of_ref_per_run__c >= 2  //$CD$16
                        && config.Combo_Num_Tubes_Artwork__c > 0) { 
              List<PM_Price_Detail__c> details = getLineDetails(config, null, OTHERS, COMBO_UPCHARGE);
              for (PM_Price_Detail__c pmDetail : details) {
                  Decimal refPerRunByMOQ =  pmDetail.MOQ_Min__c /config.Combo_Num_Tubes_Artwork__c;
                  //Get Max of Num Tubes Artwork And 1
                  if (refPerRunByMOQ < 1) {
                      refPerRunByMOQ = 1;
                  }
                  
                  //Get the minimum ref per run and num Artwork
                  refPerRunByMOQ = refPerRunByMOQ -1;
                  if (config.Number_of_ref_per_run__c < refPerRunByMOQ) {
                      refPerRunByMOQ = config.Number_of_ref_per_run__c;
                  }
                  pmDetail.List_Price__c = refPerRunByMOQ * 600 / pmDetail.MOQ_Min__c;                  
              } 
              listDetailsToUpsert.addAll(details);
        }
         
    } */
     
    public void calculateCOMBO_UPCHARGE() {  
        system.debug('......calculateCOMBO_UPCHARGE....');
        if(config.Number_of_ref_per_run__c >= 2  //$CD$16
                        && config.Number_of_tubes_per_artwork_in_Ku__c > 0) { 
                //B5 = MOQ
              List<PM_Price_Detail__c> details = getLineDetails(config, null, OTHERS, COMBO_UPCHARGE);
              for (PM_Price_Detail__c pmDetail : details) {
                 // system.debug('COMBOUPCHARGE=' + pmDetail.MOQ_Min__c + '=' + pmDetail);
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

    public void calculateQUALITY_UPCHARGE(){
        log('*********** calculateQUALITY_UPCHARGE ***********LINE='+ QUALITY_UPCHARGE+config.Quality_Level__c);
        if (String.isNotBlank(config.Quality_Level__c) && !'0'.equalsIgnorecase(config.Quality_Level__c)) {
            
            Boolean found = false;
            for(PM_Tubes_Config__c pm : [select Upcharge__c    
                                         from PM_Tubes_Config__c
                                         where Quality_Level__c    = :config.Quality_Level__c    
                                         and Table_name__c = 'Quality Upcharge'
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Laminate' 
                                         limit 1]) {
                                             
                found = true;  
                system.debug(QUALITY_UPCHARGE + ': FOUND');
                system.debug(QUALITY_UPCHARGE + ':' + pm);
                if (pm.Upcharge__c != null && pm.Upcharge__c.isNumeric()) {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            getLineDetails(config, null, OTHERS, QUALITY_UPCHARGE), Double.valueOf(pm.Upcharge__c)));                                                                                                               
                } else {
                    listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            getLineDetails(config, null, OTHERS, QUALITY_UPCHARGE), -1));                      
                }
                                             
            } 
            
        }         
    }  
    
    
    
    public void calculateLOT_PREPARATION_UPCHARGE(){
        log('*********** calculatePREPARATION_UPCHARGE ***********LINE='+ LOT_PREPARATION_UPCHARGE);
        String headColor = '';
        if (/*'White'.equalsIgnorecase(config.Head_Color__c) ||*/ 'Natural'.equalsIgnorecase(config.Head_Color__c)) {
            headColor = 'White/Natural';
        } else {
            headColor = 'Standard Color';
        }
        
        if (String.isNotBlank(headColor) /* && !'White'.equalsIgnorecase(headColor)*/) {
            List<PM_Price_Detail__c> details = getLineDetails(config, null, OTHERS, LOT_PREPARATION_UPCHARGE);
            for (PM_Price_Detail__c pmDetail : details) {
                if('White'.equalsIgnorecase(config.Head_Color__c)) //added by Maryem QADA to not calculate the priceline if color head=white
                    pmDetail.List_Price__c = 0;
                else    
                    pmDetail.List_Price__c = 400 / pmDetail.MOQ_Min__c;                  
            } 
            listDetailsToUpsert.addAll(details);                        
        }        
    }
    
    public void calculateUPHOLD_UPCHARGE(){
        log('*********** calculateUPHOLD_UPCHARGE ***********LINE='+ UPHOLD_UPCHARGE);
        log('*********** config.Make_and_Ship__c ***********LINE='+ config.Make_and_Ship__c);
        if (!'Yes'.equalsIgnorecase(config.Make_and_Ship__c)) {
                listDetailsToUpsert.addAll(
                    PMCalculatorUtility.calcGroupOther(
                        listDetailsToUpsert, new Set<String>{}, config, 0.02, OTHERS, UPHOLD_UPCHARGE));                          
            
        }
        
    }
    public void calculateMARKET_SEGMENT_PREMIUM(){
        log('*********** calculateSEGMENT_PREMIUM ***********LINE='+ MARKET_SEGMENT_PREMIUM);
         if ('HEALTHCARE & PHARMACY'.equalsIgnorecase( qli.Market_Of_Application__c)) {
            String ref = CODE + config.Diameter_inches__c + 'Health care / Pharmacy';
            system.debug('REF='+ref);
            listDetailsToUpsert.addAll(
                getLineDetails(config, mapPMTubesPricing.get(ref.toUpperCase()), OTHERS, MARKET_SEGMENT_PREMIUM));  
            // Added for Historisation
            // Create Junction Object
            PM_Tubes_Pricing__c dp = mapPMTubesPricing.get(ref.toUpperCase());
            if( dp != null){
                        PM_Config_to_Pricing__c pj = new PM_Config_to_Pricing__c(Selected_Tube__c = config.Id, 
                                                                     Tube_Pricing__c = dp.Id, 
                                                                     Unique_Key__c = config.Id+'_'+OTHERS+
                                                                                  '_'+MARKET_SEGMENT_PREMIUM);
                        listPricingJunctionToUpsert.add(pj);
            }
             // Update Prices
             if (mapPMTubesPricing.get(ref.toUppercase())!= null){
                 mapPMTubesPricing.get(ref.toUppercase()).Section__c = OTHERS;
                 mapPMTubesPricing.get(ref.toUppercase()).Line_Name__c = MARKET_SEGMENT_PREMIUM;
             }
             
         }        
    }
    public void calculateRESIN_ADJUSTMENT(){
        log('*********** calculateRESIN_ADJUSTMENT ***********LINE='+ RESIN_ADJUSTMENT+config.Resin_Index__c);
        String length = String.isNotBlank(config.Sleeve_Length_inches__c)? config.Sleeve_Length_inches__c : config.Specific_Length_inches__c;        
        
        
        if (config.Resin_Index__c != null && config.Resin_Index__c > 0 
            && String.isNotBlank(length) && String.isNotBlank(config.Sleeve_type__c)) {

            Double currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;
                
                
            Double resinAdjustment = config.Resin_Index__c - 0.76;
            Double weightPerInch = 1.20432;
            Double hdWTLength = 0;   
            Double resinPrice = 0;
           
            for(PM_Tubes_Config__c pm : [select Hd_Wt__c    
                                         from PM_Tubes_Config__c
                                         where Diameter_inches__c  = :config.Diameter_inches__c    
                                         and Table_name__c = 'CDI Length wt'
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Laminate' 
                                         limit 1]) {
                hdWTLength = pm.Hd_Wt__c;
            }
             
            double lengthDecimal = convertLengthFractionToDecimal(length);                
                
            Double wtLB = 0;
            Double capWt = 0;
            Double hdWT = 0;
            boolean capWTFound = false;
            boolean hdWTFound = false;
            for(PM_Tubes_Config__c pm : [select Cap_nb__c, Cap_wt__c, Hd_Wt__c, Concatenate__c, Table_name__c     
                                         from PM_Tubes_Config__c
                                         where (Cap_nb__c  = :config.Cap_Eurocode__c OR
                                         Concatenate__c = :config.Diameter_inches__c + config.Head_Name__c)
                                         and (Table_name__c = 'CDI Hd Wt' or Table_name__c = 'CDI Cap wt')
                                         and Location__c = :config.Location__c  
                                         and Tubes_segment__c = 'Laminate']) {
                                                                                           
               system.debug('CONFIG CDI IMPACT=' + pm);
               system.debug('EUROCODE=' + config.Cap_Eurocode__c + '=VS=' + pm.Cap_nb__c); 
               system.debug('DIAMETERHEADNAME=' + config.Diameter_inches__c + config.Head_Name__c +'=VS=' + pm.Concatenate__c);  
               if (pm.Cap_nb__c == config.Cap_Eurocode__c && pm.Table_name__c == 'CDI Cap wt') {
                   capWTFound = true;
                   system.debug('CAP WT IS NUMERIC?' +pm.Cap_wt__c.isNumeric());
                   capWt = ((pm.Cap_wt__c != null)  ? Double.valueOf(pm.Cap_wt__c) : 0);                             
               }
               if (pm.Concatenate__c == config.Diameter_inches__c + config.Head_Name__c && pm.Table_name__c == 'CDI Hd Wt') {
                   hdWTFound = true;
                   hdWT = (pm.Hd_Wt__c == null ? 0 :pm.Hd_Wt__c);                             
               }                                                            
            }
                
            system.debug('WTLB=' + wtLB + 'RESIN=' + resinAdjustment);
            Decimal price = 0;
            if (capWTFound && hdWTFound) {
                price =  resinAdjustment * (((lengthDecimal * weightPerInch) * hdWTLength)
                        + (capWt * 1.07)
                        + (hdWT * 1.05));
                system.debug('PRICE=' + price + ':CAPWT=' + capWt +':HDWT='+ hdWT);                    
            }

            if (price != 0) {
                  //price = price.round();
                  listDetailsToUpsert.addAll(
                        PMCalculatorUtility.setListPrice(
                            getLineDetails(config, null, OTHERS, RESIN_ADJUSTMENT), 
                            price * currencyRate));
            }
             
        }
    }

        
        
    public void calculateEND_OF_YEAR_REBATE(){
        log('*********** calculateEND_OF_YEAR_REBATE ***********LINE='+ END_OF_YEAR_REBATE + qli.Customer_end_of_year_rebate__c);
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
                
                List<PM_Price_Detail__c> eoyRebatePrices = PMCalculatorUtility.calcGroupOther(listDetailsToUpsert, new Set<String>(), config, dPercent, OTHERS, END_OF_YEAR_REBATE);                
                listDetailsToUpsert.addAll(eoyRebatePrices);
                
                
            }
                                             
          } else {
                    listDetailsToUpsert.addAll(
                        getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));              
          }
          system.debug('');        
    }     
  
    
    public void resetAllPMPrice() {       
       
        List<PM_Price_Detail__c> blankPMPrices = new List<PM_Price_Detail__c>();
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, LENGTH_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_ASPECT));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_COLORATION));        
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, HEAD_BARRIER));
        blankPMPrices.addAll(getLineDetails(config, null, TUBE_HEAD, FOIL_SEAL));
        
        blankPMPrices.addAll(getLineDetails(config, null, SLEEVE, SLEEVE_WEB_TYPE));
        
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_BASIS_PRICE));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_CONSIGN));
        blankPMPrices.addAll(getLineDetails(config, null, CAP, CAP_FEATURE));
        
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, OFFSET));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, FLEXO));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, SILKSCREEN));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, HOLOGRAM));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, PRINGING_EFFECT));
        blankPMPrices.addAll(getLineDetails(config, null, PRINTING, COLDSTAMP));
        
        blankPMPrices.addAll(getLineDetails(config, null, PACKING, PALLET));
        blankPMPrices.addAll(getLineDetails(config, null, PACKING, POLYSHEET));
         
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, COMBO_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, QUALITY_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, LOT_PREPARATION_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, UPHOLD_UPCHARGE));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, MARKET_SEGMENT_PREMIUM));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, RESIN_ADJUSTMENT));
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, END_OF_YEAR_REBATE));
        // add ticket 6329
        blankPMPrices.addAll(getLineDetails(config, null, OTHERS, MISCELLANEOUS_ADJUSTMENTS));
        // end ticket 6329
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
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 30, List_Price__c = 0),                    
                new PM_Price_Detail__c(MOQ_Min__c = 30, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = 0)
            };
        }else{ 
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = (tp.X15__c == null? 0 : (tp.X15__c == -1 ? -1 : tp.X15__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = (tp.X20__c == null? 0 : (tp.X20__c == -1 ? -1 : tp.X20__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 30, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 30, MOQ_Max__c = 50, List_Price__c = (tp.X30__c == null? 0 : (tp.X30__c == -1 ? -1 : tp.X30__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500, List_Price__c = (tp.X250__c == null? 0 : (tp.X250__c == -1 ? -1 : tp.X250__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = null, List_Price__c = (tp.X500__c == null? 0 : (tp.X500__c == -1 ? -1 : tp.X500__c * currencyRate)))

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