public class PMCalculatorUtility {
	public static String runningConstructor;
    
    /**
     * Calculates the total of MP Prices and update the MOQ Price
     * 
     */ 
    public static void calculateTotalMOQPRice(String tubeId, String dispensingId, String qliId) {
        List<PM_Price_Detail__c> prices = null;
        if (String.isNotBlank(tubeId)){
            prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c, Price__c, List_Price__c ,isCalculable__c ,Is_calculated__c
                  from PM_Price_Detail__c 
                  where PM_Selected_Tubes_Config__c = :tubeId AND MOQ_Max__c != 999 order by MOQ_Min__c desc];//MQ: added MOQ_Max__c != 999 to not consider specific moq    
        } else {
            prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c,List_Price__c, Price__c,isCalculable__c,Is_calculated__c
                    from PM_Price_Detail__c 
                    where PM_Selected_Dipsensing_Config__c = :dispensingId order by MOQ_Min__c desc];
        }
        Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = new Map <Decimal, PM_MOQ_price__c>();

		system.debug('---------&&prices:'+prices);
        for(PM_Price_Detail__c pm : prices){
            if(mapPMMOQPrice.containsKey(pm.MOQ_Min__c)){
                if(pm.Price__c == -1 && pm.List_Price__c == -1 && !pm.Is_calculated__c  ){
                	system.debug('@@qama dans if'+pm.Name);
                    //mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = pm.Price__c;
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = -1;
                }else if(mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1){
                	system.debug('@@qama dans else'+pm.Name);
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c+ pm.Price__c;
                }
            }else{ 
                PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                    MOQ_Min__c = pm.MOQ_Min__c,
                    MOQ_Max__c = pm.MOQ_Max__c,
                    PM_Selected_Tubes_Config__c = tubeId,
                    PM_Selected_Dipsensing_Config__c = dispensingId,
                    Quote_item__c = qliId,
                    List_Price__c = pm.Price__c,
                    ExtId__c = pm.MOQ_Min__c + '-' + (tubeId == null ? dispensingId:tubeId)
                );                               
                mapPMMOQPrice.put(pm.MOQ_Min__c, pmMOQ);
            }
        	System.debug('## mapPMMOQPrice.get(pm.MOQ_Min__c) : ' +pm.Name+'__'+ pm.MOQ_Min__c+'=='+mapPMMOQPrice.get(pm.MOQ_Min__c));     
        }

        System.debug('## mapPMMOQPrice : ' + mapPMMOQPrice);
        if(mapPMMOQPrice.size() > 0){
            upsert mapPMMOQPrice.values() ExtId__c;
        }
        
        
    }
    /**
     * Calculates the total of MP Prices and update the MOQ Price With a specific list of ligne (to be changed after the reforme of the Tube & dispensing)
     * IT is created to eliminate all PM Prices details that are no longer used in the total price 
     * (result of the reforme and changes and because there is a cleaning phase required in the database)
     */ 
    public static void calculateTotalMOQPRice_BIS(String tubeId, String dispensingId, String qliId, List<String> Names) {
        List<PM_Price_Detail__c> prices = null;
        if (String.isNotBlank(tubeId)){
            prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c, Price__c, List_Price__c ,isCalculable__c ,Is_calculated__c
                  from PM_Price_Detail__c 
                  where PM_Selected_Tubes_Config__c = :tubeId AND MOQ_Max__c != 999  AND Name IN :Names order by MOQ_Min__c desc];//MQ: added MOQ_Max__c != 999 to not consider specific moq    
        } else {
            prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c,List_Price__c, Price__c,isCalculable__c,Is_calculated__c
                    from PM_Price_Detail__c 
                    where PM_Selected_Dipsensing_Config__c = :dispensingId AND Name IN :Names order by MOQ_Min__c desc];
        }
        Map <Decimal, PM_MOQ_price__c> mapPMMOQPrice = new Map <Decimal, PM_MOQ_price__c>();

		system.debug('---------&&prices:'+prices);
        for(PM_Price_Detail__c pm : prices){
            if(mapPMMOQPrice.containsKey(pm.MOQ_Min__c)){
                if(pm.Price__c == -1 && pm.List_Price__c == -1 && !pm.Is_calculated__c  ){
                	system.debug('@@qama dans if'+pm.Name);
                    //mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = pm.Price__c;
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = -1;
                }else if(mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c != -1){
                	system.debug('@@qama dans else'+pm.Name);
                    mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c = mapPMMOQPrice.get(pm.MOQ_Min__c).List_Price__c+ pm.Price__c;
                }
            }else{ 
                PM_MOQ_price__c pmMOQ = new PM_MOQ_price__c(
                    MOQ_Min__c = pm.MOQ_Min__c,
                    MOQ_Max__c = pm.MOQ_Max__c,
                    PM_Selected_Tubes_Config__c = tubeId,
                    PM_Selected_Dipsensing_Config__c = dispensingId,
                    Quote_item__c = qliId,
                    List_Price__c = pm.Price__c,
                    ExtId__c = pm.MOQ_Min__c + '-' + (tubeId == null ? dispensingId:tubeId)
                );                               
                mapPMMOQPrice.put(pm.MOQ_Min__c, pmMOQ);
            }
        	System.debug('## mapPMMOQPrice.get(pm.MOQ_Min__c) : ' +pm.Name+'__'+ pm.MOQ_Min__c+'=='+mapPMMOQPrice.get(pm.MOQ_Min__c));     
        }

        System.debug('## mapPMMOQPrice : ' + mapPMMOQPrice);
        if(mapPMMOQPrice.size() > 0){
            upsert mapPMMOQPrice.values() ExtId__c;
        }
        
        
    }
    
    /**
     * Gets all the Tubes Pricing Setting to be used to avoid repeated Query
     * 
     */ 
    /*public static Map <String, PM_Tubes_Pricing__c> getPMTubesPricingReferenceByProductSegment(String location, Decimal version, String productSegment){

        Map <String, PM_Tubes_Pricing__c> mapTubePricing = new Map <String, PM_Tubes_Pricing__c>(); 
        for(PM_Tubes_Pricing__c oPricing : [select X10__c, X15__c, X20__c, X25__c, X30__c, X50__c, 
                                                    X75__c, X100__c, X200__c, X250__c, X300__c, X500__c,x1000__c,//added by maryem qada 27/06/2018 ==> adding moq 1000
                                                    Version__c, Ref__c, Tubes_Segments__c, Location__c
                                            from PM_Tubes_Pricing__c
                                            where Version__c = :version
                                            and Tubes_Segments__c =:productSegment
                                            and Location__c = :location]){
            mapTubePricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);
        }
        return mapTubePricing;
    }   */
    
    /**
     * Gets all the Tubes Pricing Setting to be used to avoid repeated Query
     * 
     */ 
  /*  public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricing(String location, Decimal version){

        Map <String, PM_Dispensing_Pricing__c > mapTubePricing = new Map <String, PM_Dispensing_Pricing__c>(); 
        for(PM_Dispensing_Pricing__c oPricing : [select X10__c, X25__c, X50__c, 
                                                    X100__c, X250__c, X500__c,
                                                    Version__c, Ref__c
                                            from PM_Dispensing_Pricing__c
                                            where Version__c = :version
                                            and Location__c = :location]){
            mapTubePricing.put(oPricing.Ref__c.toUppercase(), oPricing);
        }
        return mapTubePricing;
    } */

    /**
     * Gets all the Tubes Pricing Setting to be used to avoid repeated Query
     * 
     */ 
   /* public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricingReference(String location, Decimal version){

        Map <String, PM_Dispensing_Pricing__c > mapTubePricing = new Map <String, PM_Dispensing_Pricing__c>(); 
        for(PM_Dispensing_Pricing__c oPricing : [select X5__c, X10__c, X25__c, X50__c, 
                                                    X100__c, X250__c, X500__c,
                                                    Version__c, Ref__c
                                            from PM_Dispensing_Pricing__c
                                            where Version__c = :version
                                            and Location__c = :location]){
            mapTubePricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);                                                
            //mapTubePricing.put(oPricing.Ref__c, oPricing);
        }
        return mapTubePricing;
    } */
 
    /**
     * Gets all the Tubes Pricing Setting to be used to avoid repeated Query
     * Added the ProductSegment to prevent getting the pricing for all dispensing segment
     */ 
    /*public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricingReferenceProductSegment(String location, Decimal version, String productSegment){

        Map <String, PM_Dispensing_Pricing__c > mapDispensingPricing = new Map <String, PM_Dispensing_Pricing__c>(); 
        for(PM_Dispensing_Pricing__c oPricing : [select X5__c, X10__c, X25__c, X50__c, 
                                                    X100__c, X250__c, X500__c,
                                                    Version__c, Ref__c, Product_Segment__c, Location__c
                                            from PM_Dispensing_Pricing__c
                                            where Version__c = :version
                                            and Product_Segment__c =:productSegment
                                            and Location__c = :location]){
                                                
                                                
            mapDispensingPricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);                                                
            //mapTubePricing.put(oPricing.Ref__c, oPricing);
        }
        return mapDispensingPricing;
    }   */
    
    /**
     * Gets all the Tubes Pricing Setting to be used to avoid repeated Query
     * Added the ProductSegment to prevent getting the pricing for all dispensing segment
     * Specific for Foam Segment, to get the largest price last in the map
     */ 
  /*  public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricingReferenceProductSegmentOrder(String location, Decimal version, String productSegment){

        Map <String, PM_Dispensing_Pricing__c > mapDispensingPricing = new Map <String, PM_Dispensing_Pricing__c>(); 
        for(PM_Dispensing_Pricing__c oPricing : [select X5__c, X10__c, X25__c, X50__c, 
                                                    X100__c, X250__c, X500__c,
                                                    Version__c, Ref__c, Product_Segment__c, Location__c
                                            from PM_Dispensing_Pricing__c
                                            where Version__c = :version
                                            and Product_Segment__c =:productSegment
                                            and Location__c = :location
                                            order by X10__c ASC]){
                                                
                                                
            mapDispensingPricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);                                                
            //mapTubePricing.put(oPricing.Ref__c, oPricing);
        }
        return mapDispensingPricing;
    }    */
    
 
   /* public static Decimal getPMPricingVersion(String location, String productLine, String productSegment){
        for(PM_pricing_Version__mdt version : [select Version_number__c
                                                from PM_pricing_Version__mdt
                                                where Location__c = :location
                                                and Product_line__c = :productLine
                                                and Product_Segment__c = :productSegment
                                                limit 1]){
            return version.Version_number__c;
        }
        return 1;
    } */
    
    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    public static List <PM_Price_Detail__c> getLineDetails(PM_Selected_Tubes_Config__c config, PM_Tubes_Pricing__c tp, String section, String name){
        List <PM_Price_Detail__c> listDetails;
        
        // We set the currency rate to be 
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           

        
        if(tp == null){
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = 0),//added by riadi zakaria 30/03/2020 ==> adding moq 5k
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = 0),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = 1000, List_Price__c = 0),//last modified by maryem qada max was assigned to null=>27/06/2018 ==> adding moq 1000
                new PM_Price_Detail__c(MOQ_Min__c = 1000, MOQ_Max__c = null, List_Price__c = 0)//added by maryem qada 27/06/2018 ==> adding moq 1000
            };
        }else{
            listDetails = new List <PM_Price_Detail__c>{
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = (tp.X5__c == null? 0 : (tp.X5__c == -1 ? -1 : tp.X5__c * currencyRate))),                
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15, List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20, List_Price__c = (tp.X15__c == null? 0 : (tp.X15__c == -1 ? -1 : tp.X15__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25, List_Price__c = (tp.X20__c == null? 0 : (tp.X20__c == -1 ? -1 : tp.X20__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 50, List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 75, List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 75, MOQ_Max__c = 100, List_Price__c = (tp.X75__c == null? 0 : (tp.X75__c == -1 ? -1 : tp.X75__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 200, List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 200, MOQ_Max__c = 300, List_Price__c = (tp.X200__c == null? 0 : (tp.X200__c == -1 ? -1 : tp.X200__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 300, MOQ_Max__c = 500, List_Price__c = (tp.X300__c == null? 0 : (tp.X300__c == -1 ? -1 : tp.X300__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 500, MOQ_Max__c = 1000, List_Price__c = (tp.X500__c == null? 0 : (tp.X500__c == -1 ? -1 : tp.X500__c * currencyRate))),//last modified by maryem qada max was assigned to null=>27/06/2018 ==> adding moq 1000
                new PM_Price_Detail__c(MOQ_Min__c = 1000,MOQ_Max__c = null, List_Price__c = (tp.X1000__c == null? 0 : (tp.X1000__c == -1 ? -1 : tp.X1000__c * currencyRate)))//added by maryem qada 27/06/2018 ==> adding moq 1000
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
    
    // returns all the details for a given line; if tp == null, return 0 for all List Prices
    public static List <PM_Price_Detail__c> getUSLineDetails(PM_Selected_Tubes_Config__c config, PM_Tubes_Pricing__c tp, String section, String name){
        List <PM_Price_Detail__c> listDetails;
        // We set the currency rate to be 
        Decimal currencyRate = (config.Billing_Currency_Rate__c == null || config.Billing_Currency_Rate__c == 0)? 1 : config.Billing_Currency_Rate__c;           

        if(tp == null){
            listDetails = new List <PM_Price_Detail__c>{
				new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10, List_Price__c = 0),                
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
                new PM_Price_Detail__c(MOQ_Min__c = 5, MOQ_Max__c = 10,    List_Price__c = (tp.X5__c == null? 0 : (tp.X5__c == -1 ? -1 : tp.X5__c * currencyRate))),                
                new PM_Price_Detail__c(MOQ_Min__c = 10, MOQ_Max__c = 15,    List_Price__c = (tp.X10__c == null? 0 : (tp.X10__c == -1 ? -1 : tp.X10__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 15, MOQ_Max__c = 20,    List_Price__c = (tp.X15__c == null? 0 : (tp.X15__c == -1 ? -1 : tp.X15__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 20, MOQ_Max__c = 25,    List_Price__c = (tp.X20__c == null? 0 : (tp.X20__c == -1 ? -1 : tp.X20__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 25, MOQ_Max__c = 30,    List_Price__c = (tp.X25__c == null? 0 : (tp.X25__c == -1 ? -1 : tp.X25__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 30, MOQ_Max__c = 50,    List_Price__c = (tp.X30__c == null? 0 : (tp.X30__c == -1 ? -1 : tp.X30__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 50, MOQ_Max__c = 100,   List_Price__c = (tp.X50__c == null? 0 : (tp.X50__c == -1 ? -1 : tp.X50__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 100, MOQ_Max__c = 250,  List_Price__c = (tp.X100__c == null? 0 : (tp.X100__c == -1 ? -1 : tp.X100__c * currencyRate))),
                new PM_Price_Detail__c(MOQ_Min__c = 250, MOQ_Max__c = 500,  List_Price__c = (tp.X250__c == null? 0 : (tp.X250__c == -1 ? -1 : tp.X250__c * currencyRate))),
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
    
    
    
    // sets the same ListPrice on all detail records
    public static List <PM_Price_Detail__c> setListPrice(List <PM_Price_Detail__c> details, Decimal listPrice){
        for(PM_Price_Detail__c detail : details){
            detail.List_Price__c = listPrice;
        }
        return details;
    }    
  
    // sets the same ListPrice on all detail records
    public static List <PM_Price_Detail__c> roundDownListPrice(List <PM_Price_Detail__c> details){
        for(PM_Price_Detail__c detail : details){
            detail.List_Price__c = (detail.List_Price__c != null ? detail.List_Price__c.round(System.RoundingMode.DOWN):detail.List_Price__c);
        }
        return details;
    }    
    
    public static List <PM_Price_Detail__c> roundListPrice(List <PM_Price_Detail__c> details){
        for(PM_Price_Detail__c detail : details){
            detail.List_Price__c = (detail.List_Price__c != null ? detail.List_Price__c.round():detail.List_Price__c);
        }
        return details;
    }     


    //DeCommented by A.Leriche, method reused in PMCalculator_US_Plastic
    
    public static List<PM_Price_Detail__c> calcGroup(List<PM_Price_Detail__c> listDetailsToUpsert, Set <String> setLinesToSkip, 
                          PM_Selected_Tubes_Config__c config, Decimal dPercent,
                          String section, String sLine){
        Map <Decimal, PM_Price_Detail__c> totalPMs = new Map <Decimal, PM_Price_Detail__c>();
                              
        Decimal dPercentage = dPercent == 0 ? 1 :dPercent;
        //If there is APPLY_ZERO_PERCENT as setting, if percentage equals to zero, the value must be zero as well
        //In Normal case, the percentage is set to 1 if it is zero                              
        if (setLinesToSkip != null && setLinesToSkip.size()>0 
            && 'APPLY_ZERO_PERCENT'.equalsIgnoreCase((String)setLinesToSkip.iterator().next())) {
             dPercentage = dPercent;                      
       }                              

        for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                Decimal listPrice = 0;
                if (pm.List_Price__c == -1 && pm.Is_calculated__c == false) {
                    listPrice = -1;
                } else {                    
                    listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                }          
                //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
                system.Debug('TESTTEST : ' + ListPrice);

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1 && pm.Is_calculated__c == false){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        } 

        System.debug('## Payment Terms : ' + totalPMs);
        return totalPMs.values();
        //if(mapPaymentTerms.size() > 0){
        //   listDetailsToUpsert.addAll(mapPaymentTerms.values());
        //}
    }
    

    //Added by Arthur Leriche, this methods calculates prices in the 'other' section and checks if prices are overrided 
    public static List<PM_Price_Detail__c> calcGroupOther(List<PM_Price_Detail__c> listDetailsToUpsert, Set <String> setLinesToSkip, 
                          PM_Selected_Tubes_Config__c config, Decimal dPercent,
                          String section, String sLine){
        Map <Decimal, PM_Price_Detail__c> totalPMs = new Map <Decimal, PM_Price_Detail__c>();
                              
        Decimal dPercentage = dPercent == 0 ? 1 :dPercent;

        List<PM_Price_Detail__c> prices = new List<PM_Price_Detail__c>();
        prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c,List_Price__c, Price__c,isCalculable__c,Is_calculated__c, Price_Override__c
                    from PM_Price_Detail__c 
                    where PM_Selected_Tubes_Config__c = :config.Id and Price_Override__c != null and Price_Override__c != 0 order by MOQ_Min__c desc];

        List<PM_Price_Detail__c> ListDetailsToUpsert2 = new List<PM_Price_Detail__c>();
        for(PM_Price_Detail__c pmOverride : prices){
            boolean traite = false;
            for(PM_Price_Detail__c pm : listDetailsToUpsert){
                if(pmOverride.Name == pm.Name && pmOverride.Section__c == pm.Section__c && pmOverride.MOQ_Min__c == pm.MOQ_Min__c){
                    system.debug('on est la 2' + pmOverride.Price_Override__c);
                    pm.Price_Override__c = pmOverride.Price_Override__c;
                    traite=true;
                }            
            }
            if(traite == false){
                    ListDetailsToUpsert2.add(new PM_Price_Detail__c(Name=pmOverride.Name, Section__c=pmOverride.Section__c, MOQ_Min__c=pmOverride.MOQ_Min__c, MOQ_Max__c=pmOverride.MOQ_Max__c, Price_Override__c = pmOverride.Price_Override__c));
            }
        }

        system.Debug('ListDetailsToUpsert : ' + ListDetailsToUpsert);
        system.Debug('ListDetailsToUpsert2 : ' + ListDetailsToUpsert2);

        //If there is APPLY_ZERO_PERCENT as setting, if percentage equals to zero, the value must be zero as well
        //In Normal case, the percentage is set to 1 if it is zero                              
        if (setLinesToSkip != null && setLinesToSkip.size()>0 
            && 'APPLY_ZERO_PERCENT'.equalsIgnoreCase((String)setLinesToSkip.iterator().next())) {
             dPercentage = dPercent;                      
       }                              

        for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                
                Decimal listPrice = 0;

                if(pm.Price_Override__c != null){                    
                    listPrice = pm.Price_Override__c * dPercentage;
                }

                else{
                    if (pm.List_Price__c == -1) {
                        listPrice = -1;
                    } else {                    
                        listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                    }          
                    //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
                }
 

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1 && pm.Is_calculated__c == false){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1 /*&& totalPMs.get(pm.MOQ_Min__c).Is_calculated__c == true*/){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        }
        for(PM_Price_Detail__c pm : listDetailsToUpsert2){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                
                Decimal listPrice = 0;

                if(pm.Price_Override__c != null){                    
                    listPrice = pm.Price_Override__c * dPercentage;
                }

                else{
                    if (pm.List_Price__c == -1) {
                        listPrice = -1;
                    } else {                    
                        listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                    }          
                    //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
                }
 

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1 && pm.Is_calculated__c == false){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1 /*&& totalPMs.get(pm.MOQ_Min__c).Is_calculated__c == true*/){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        } 

        System.debug('## Payment Terms : ' + totalPMs);
        return totalPMs.values();
        /*if(mapPaymentTerms.size() > 0){
            listDetailsToUpsert.addAll(mapPaymentTerms.values());
        }*/
    }

    //Commented by A.Leriche, method replaced by CalcGroupDispensingOther
    /*
    public static List<PM_Price_Detail__c> calcGroupDispensing(List<PM_Price_Detail__c> listDetailsToUpsert, Set <String> setLinesToSkip, 
                          PM_Selected_Dipsensing_config__c config, Decimal dPercent,
                          String section, String sLine){
        
        Decimal dPercentage = dPercent == 0 ? 1 :dPercent;
        //If there is APPLY_ZERO_PERCENT as setting, if percentage equals to zero, the value must be zero as well
        //In Normal case, the percentage is set to 1 if it is zero                              
        if (setLinesToSkip != null && setLinesToSkip.size()>0 
            && 'APPLY_ZERO_PERCENT'.equalsIgnoreCase((String)setLinesToSkip.iterator().next())) {
             dPercentage = dPercent;                      
       }
                                      
        Map <Decimal, PM_Price_Detail__c> totalPMs = new Map <Decimal, PM_Price_Detail__c>();

        for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                Decimal listPrice = 0;
                if (pm.List_Price__c == -1) {
                    listPrice = -1;
                } else {                    
                    listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                }          
                //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
 

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Dipsensing_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        } 

        System.debug('## Payment Terms : ' + totalPMs);
        return totalPMs.values();  

    }
    */

    //Added by Arthur Leriche, this methods calculates prices in the 'other' section and checks if prices are overrided 
    public static List<PM_Price_Detail__c> calcGroupDispensingOther(List<PM_Price_Detail__c> listDetailsToUpsert, Set <String> setLinesToSkip, 
                          PM_Selected_Dipsensing_config__c config, Decimal dPercent,
                          String section, String sLine){
        
        Decimal dPercentage = dPercent == 0 ? 1 :dPercent;
        
        List<PM_Price_Detail__c> prices = new List<PM_Price_Detail__c>();
        prices = [Select id, Name, Section__c, MOQ_Min__c, MOQ_Max__c,List_Price__c, Price__c,isCalculable__c,Is_calculated__c, Price_Override__c
                    from PM_Price_Detail__c 
                    where PM_Selected_Dipsensing_Config__c = :config.Id and Price_Override__c != null and Price_Override__c != 0 order by MOQ_Min__c desc];


        List<PM_Price_Detail__c> listDetailsToUpsert2 = new List<PM_Price_Detail__c>();
        for(PM_Price_Detail__c pmOverride : prices){
            boolean traite = false;
            for(PM_Price_Detail__c pm : listDetailsToUpsert){
                if(pmOverride.Name == pm.Name && pmOverride.Section__c == pm.Section__c && pmOverride.MOQ_Min__c == pm.MOQ_Min__c){
                    system.debug('on est la 2' + pmOverride.Price_Override__c);
                    pm.Price_Override__c = pmOverride.Price_Override__c;
                    traite=true;
                }            
            }
            if(traite == false){
                    listDetailsToUpsert2.add(new PM_Price_Detail__c(Name=pmOverride.Name, Section__c=pmOverride.Section__c, MOQ_Min__c=pmOverride.MOQ_Min__c, MOQ_Max__c=pmOverride.MOQ_Max__c, Price_Override__c = pmOverride.Price_Override__c));
            }
        }

        //If there is APPLY_ZERO_PERCENT as setting, if percentage equals to zero, the value must be zero as well
        //In Normal case, the percentage is set to 1 if it is zero                              
        if (setLinesToSkip != null && setLinesToSkip.size()>0 
            && 'APPLY_ZERO_PERCENT'.equalsIgnoreCase((String)setLinesToSkip.iterator().next())) {
             dPercentage = dPercent;                      
       }
                                      
        Map <Decimal, PM_Price_Detail__c> totalPMs = new Map <Decimal, PM_Price_Detail__c>();

        for(PM_Price_Detail__c pm : listDetailsToUpsert){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                
                Decimal listPrice = 0;

                if(pm.Price_Override__c != null){                    
                    listPrice = pm.Price_Override__c * dPercentage;
                }

                else{
                    if (pm.List_Price__c == -1) {
                        listPrice = -1;
                    } else {                    
                        listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                    }          
                    //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
                }

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Dipsensing_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        }

        for(PM_Price_Detail__c pm : listDetailsToUpsert2){
            if(pm != null && setLinesToSkip != null 
                    && !setLinesToSkip.contains(pm.Name)){
                //System.debug(pm.Name + ' : ' + pm.List_Price__c);
                
                Decimal listPrice = 0;

                if(pm.Price_Override__c != null){                    
                    listPrice = pm.Price_Override__c * dPercentage;
                }

                else{
                    if (pm.List_Price__c == -1) {
                        listPrice = -1;
                    } else {                    
                        listPrice = ((pm != null && pm.List_Price__c != null) ? (pm.List_Price__c * dPercentage) : 0);
                    }          
                    //Decimal listPrice = pm.List_Price__c == -1 ? pm.List_Price__c : (pm.List_Price__c * (dPercent == 0 ? 1 :dPercent));
                }
 

                if(totalPMs.containsKey(pm.MOQ_Min__c)){
                    if(pm.List_Price__c == -1 && pm.Is_calculated__c == false){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c = pm.List_Price__c;
                    } else if(totalPMs.get(pm.MOQ_Min__c).List_Price__c != -1 /*&& totalPMs.get(pm.MOQ_Min__c).Is_calculated__c == true*/){
                        totalPMs.get(pm.MOQ_Min__c).List_Price__c += listPrice;
                    }
                }else{
                    PM_Price_Detail__c pmMOQ = new PM_Price_Detail__c(
                        MOQ_Min__c = pm.MOQ_Min__c,
                        MOQ_Max__c = pm.MOQ_Max__c,
                        PM_Selected_Tubes_Config__c = config.Id,
                        Quote_item__c = config.Quote_item__c,
                        List_Price__c = listPrice,
                        ExtId__c = config.Id + sLine + pm.MOQ_Min__c,
                        Name = sLine,
                        Section__c = section
                    );
                    totalPMs.put(pm.MOQ_Min__c, pmMOQ);
                }
            }
        } 

        System.debug('## Payment Terms : ' + totalPMs);
        return totalPMs.values(); 
       

    }
    
    public static List <PM_Price_Detail__c> setSpecificPriceToZero(List <PM_Price_Detail__c> listDetails) {
        for(PM_Price_Detail__c detail : listDetails){
            system.debug('LIST PRICE ' + detail.MOQ_Min__c + '=' + detail.List_Price__c);
            if (detail.List_Price__c == -1) {
                detail.List_Price__c = 0;
            } 
        }  
        return listDetails;
    }   
    
    public static List <PM_Price_Detail__c> setPriceMultiplier(List <PM_Price_Detail__c> listDetails, double multiplier) {
        for(PM_Price_Detail__c detail : listDetails){
            if (detail.List_Price__c != -1) {
                detail.List_Price__c = detail.List_Price__c * multiplier;
            } 
        }  
        return listDetails;
    }     
    
    public static void handleCalculator(PM_Selected_Tubes_Config__c tubeConfig) {
        //TODO Handler for After insert trigger for PM_Selected_Tubes_Config__c
        if (tubeConfig.Location__c == 'EU') {
            if (tubeConfig.Product_segment__c == 'Plastic Tubes') {
                //For Purefoil Segment...
                if (tubeConfig.Purefoil_Segment__c) {
                    runningConstructor = 'TubeEUPurefoil';
                    PMCalculator_EU_Purefoil calculator = new PMCalculator_EU_Purefoil(tubeConfig);
                    calculator.calculate(); 
                } else {
                    runningConstructor = 'TubeEUPlastic';
                    PMCalculator_EU_Plastic calculator = new PMCalculator_EU_Plastic(tubeConfig);
                    calculator.calculate();   
                }
                
            } else if (tubeConfig.Product_segment__c == 'Laminate Tubes') {
                runningConstructor = 'TubeEULaminate';
                PMCalculator_EU_Laminate calculator = new PMCalculator_EU_Laminate(tubeConfig);
                calculator.calculate();   
            }
       } else if (tubeConfig.Location__c == 'US') { 
            if (tubeConfig.Product_segment__c == 'Plastic Tubes') {
                runningConstructor = 'TubeUSPlastic';
                PMCalculator_US_Plastic calculator = new PMCalculator_US_Plastic(tubeConfig);
                calculator.calculate();  
            } else if (tubeConfig.Product_segment__c == 'Laminate Tubes') {
                runningConstructor = 'TubeUSLaminate';
                PMCalculator_US_Laminate calculator = new PMCalculator_US_Laminate(tubeConfig);
                calculator.calculate();   
            }
            
        }  
        
        LC01_PriceRecommendation.getPriceRecommendation(tubeConfig.Quote_item__c);
         List<PM_Price_Recommendation__c> priceRecomsToDelete = [select id from PM_Price_Recommendation__c where 
                                                                Quote_Line_Item__c =: tubeConfig.Quote_item__c and MOQ__c = 999];
        delete priceRecomsToDelete; 
       
         
    }
    
    public static void handleCalculatorDispensing(PM_Selected_Dipsensing_config__c dispensingConfig) {
        
        if (dispensingConfig.Location__c == 'EU') {
            if ('Lotion pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispEULotion';
                PMCalculator_EU_Lotion calculator = new PMCalculator_EU_Lotion(dispensingConfig);
                calculator.calculate();                 
            } else if ('Fine mist pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispEUFinemist';
                PMCalculator_EU_FineMist calculator = new PMCalculator_EU_FineMist(dispensingConfig);
                calculator.calculate();                 
            } else if ('Foam pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispEUFoam';
                PMCalculator_EU_FoamPump calculator = new PMCalculator_EU_FoamPump(dispensingConfig);
                calculator.calculate();                 
            } else if ('Sampler pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispEUSampler';
                PMCalculator_EU_SamplerPump calculator = new PMCalculator_EU_SamplerPump(dispensingConfig);
                calculator.calculate();                 
            }
            
        
        } else if (dispensingConfig.Location__c == 'US') {
            if ('Lotion pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispUSLotion';
                PMCalculator_US_Lotion calculator = new PMCalculator_US_Lotion(dispensingConfig);
                calculator.calculate();                 
            } else if ('Fine mist pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispUSFinemist';
                PMCalculator_US_FineMist calculator = new PMCalculator_US_FineMist(dispensingConfig);
                calculator.calculate();                 
            }  else if ('Foam pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispUSFoam';
                PMCalculator_US_FoamPump calculator = new PMCalculator_US_FoamPump(dispensingConfig);
                calculator.calculate();                 
            } else if ('Sampler pumps'.equalsIgnoreCase(dispensingConfig.Quote_Product_Segment__c)) {
            	runningConstructor = 'DispUSSampler';
                PMCalculator_US_SamplerPump calculator = new PMCalculator_US_SamplerPump(dispensingConfig);
                calculator.calculate();                 
            }
            
            
        } 
        LC01_PriceRecommendation.getPriceRecommendation(dispensingConfig.Quote_item__c);
         List<PM_Price_Recommendation__c> priceRecomsToDelete = [select id from PM_Price_Recommendation__c where 
                                                                Quote_Line_Item__c =: dispensingConfig.Quote_item__c and MOQ__c = 999];
        delete priceRecomsToDelete; 
       
    }  
    
    /*
    * Method which returns the multiplication of two lists of PM Price Detail object
    */  
     public static List<PM_Price_Detail__c> calculateMultiplicationOfTwoLists(List<PM_Price_Detail__c> list1 ,  List<PM_Price_Detail__c> list2) {
     	//Result list
     	List<PM_Price_Detail__c> resultList = new List<PM_Price_Detail__c>();
     	//construct two maps with key = range and value = price list
     	map<string,decimal> mapFromList1 = new map<string,decimal>();
     	map<string,decimal> mapFromList2 = new map<string,decimal>();
     	map<string,decimal> resultMapFromSum = new map<string,decimal>();
     	
     	//Fill the maps     	
     	for(Integer i=0; i< list1.size(); i++){      		
     		mapFromList1.put(list1[i].moq_min__c+'_'+list1[i].moq_max__c,list1[i].list_price__c);		
     		mapFromList2.put(list2[i].moq_min__c+'_'+list2[i].moq_max__c,list2[i].list_price__c);
     	}     	
     	
     	//Calculate the sum of the two maps
     	for(String key :mapFromList1.keyset()){ 
            if(mapFromList1.get(key) != -1 && mapFromList2.get(key) != -1)          
                resultMapFromSum.put(key,mapFromList1.get(key)+mapFromList2.get(key) ); 
            else
                resultMapFromSum.put(key,-1);   
        }
     	
     	//fill the result list
     	for(Integer j=0; j< list1.size(); j++){     
     		PM_Price_Detail__c result = list1[j];
     		result.list_price__c =  result.list_price__c = resultMapFromSum.get(list1[j].moq_min__c+'_'+list1[j].moq_max__c); 
     		resultList.add(result);
     	}
     	
     	system.debug('@@qama resultList '+resultList);
     	
     	return resultList;
     }
     
     /*
     * Methode which calculate the percentage value for skonto
     */
      public static Decimal calculateSKONTO(String country, String dsSkonto){
        //Get the list of countries eligible for SKONTO
        list<string> liEligibleCountries = new list<string>();
        for(PM_Global_Config__c gc : [select Country_Name__c from PM_Global_Config__c where Table_name__c ='SKONTO' ])
        	liEligibleCountries.add(gc.Country_Name__c.toUpperCase())	;
        system.debug(liEligibleCountries);
        Decimal dPercent =0;
        // Skonto
        if(liEligibleCountries.contains(country.toUpperCase())
           && dsSkonto != null){
           system.debug(dsskonto);	
            dPercent = 
           	dsSkonto.contains('3')
            	? 0.03
            	: (dsSkonto.contains('2') 
            		?0.02 
            		: (dsSkonto.contains('1') 
            			? 0.01 
            			: 0 )
            		)
            	
            ;
           }//end if
           system.debug('@@qama SKONTO '+dPercent);
           return dPercent; 
      }//end calculate SKONTO   
		
	
	 /*NEW METHODE : USING PRICE HISTORISATION
     * Gets all the Dispensing Pricing having Date Valid From <=QLI CreatedDate <= Valid To 
     */ 
   /* public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricingReference(String location, Date qliCreatedDate){

        Map <String, PM_Dispensing_Pricing__c > mapTubePricing = new Map <String, PM_Dispensing_Pricing__c>(); 
        for(PM_Dispensing_Pricing__c oPricing : [select X5__c, X10__c, X25__c, X50__c, 
                                                    X100__c, X250__c, X500__c,
                                                    Version__c, Ref__c
                                            from PM_Dispensing_Pricing__c
                                            where Valid_From__c <= :qliCreatedDate
                                            and Valid_To__c >= :qliCreatedDate
                                            and Location__c = :location]){
            mapTubePricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);                                                
            //mapTubePricing.put(oPricing.Ref__c, oPricing);
        }
        return mapTubePricing;
    }   */

 
     /*NEW METHODE : USING PRICE HISTORISATION. 
     * Gets all the Dispensing Pricing having Date Valid From <=QLI CreatedDate <= Valid To 
     */ 
    public static Map <String, PM_Dispensing_Pricing__c > getPMDispensingPricingReference(String location, String productSegment, Date qliCreatedDate, boolean order, boolean upperCase){

        Map <String, PM_Dispensing_Pricing__c > mapDispensingPricing = new Map <String, PM_Dispensing_Pricing__c>();
        String query = DAL.generateSELECTQuery('PM_Dispensing_Pricing__c')+' where Valid_From__c <= : qliCreatedDate and Valid_To__c >= : qliCreatedDate and Location__c = :location and Product_Segment__c = : productSegment';
        System.debug('@@@@ '+ query);
        if (order == true ) query += ' order by X10__c ASC';
        list<PM_Dispensing_Pricing__c> result = Database.query(query);
        for(PM_Dispensing_Pricing__c oPricing : result){
            if (upperCase == true){
                mapDispensingPricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);
            }else{
                mapDispensingPricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c), oPricing);
            }

        }
        return mapDispensingPricing;


    }   


     /*NEW METHODE : USING PRICE HISTORISATION
     * Gets all the Tubes Pricing having Date Valid From <=QLI CreatedDate <= Valid To 
     */ 
    public static Map <String, PM_Tubes_Pricing__c > getPMTubesPricingReference(String location, String tubeSegment, Date qliCreatedDate){

        Map <String, PM_Tubes_Pricing__c > mapTubesPricing = new Map <String, PM_Tubes_Pricing__c>();
        String query = DAL.generateSELECTQuery('PM_Tubes_Pricing__c')+' where Valid_From__c <= : qliCreatedDate and Valid_To__c >= :qliCreatedDate  and Location__c = :location  and Tubes_Segments__c = :tubeSegment' ;
        list<PM_Tubes_Pricing__c> result = Database.query(query);
        System.debug('@@@ Result: '+ result);
        for(PM_Tubes_Pricing__c oPricing : result){
              mapTubesPricing.put((oPricing.Ref__c == null ? '' : oPricing.Ref__c.toUppercase()), oPricing);                                                
        }
        return mapTubesPricing;

    }   
   
}