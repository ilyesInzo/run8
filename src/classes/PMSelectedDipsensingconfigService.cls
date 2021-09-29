/**
* @description Service class for interacting with PMReviewNetPriceperMoq
* @author MQ
* @date 29/11/2017
* @Description : This class was cloned from PM_SelectedDispensingConfigHelper to unify the naming of classes
*/
public class PMSelectedDipsensingconfigService {
	

    public static void copyDataToQuoteItem(List<PM_Selected_Dipsensing_Config__c> triggerNew){
        Map<Id, PM_Selected_Dipsensing_Config__c> stcMap = new Map<Id, PM_Selected_Dipsensing_Config__c>();
        for(PM_Selected_Dipsensing_Config__c stc: triggerNew){
            stcMap.put(stc.quote_Item__c, stc);
        }
        // get QuoteLineItems
        Map<Id, QuoteLineItem> qlisMap =  new Map<Id, QuoteLineItem>([Select Id from QuoteLineItem 
                                          WHERE Id IN :(stcMap.keySet())]);
        // Copy field to QuoteItem
        Map<Id, QuoteLineItem> qlisMapUpdated  = new Map<Id, QuoteLineItem>();
        for(Id qliId : qlisMap.keySet()){
            qlisMapUpdated.put(qliId, PM_CopySelectedConfigToQuoteItem.populateQuoteItemFromDispensingConfig(stcMap.get(qliId), qlisMap.get(qliId)));
        }
        
        Update qlisMapUpdated.values();
        
    }
    
    //Chris Rewritten for Bulk Process
    public static void copyDataToQuoteItemVer2(List<PM_Selected_Dipsensing_Config__c> triggerNew){
    	set<id> configIds = new set<id>();
    	for(PM_Selected_Dipsensing_Config__c conf : triggerNew){
    		configIds.add(conf.id);	
    	}
    	
    	//Map Selected config MOQs
    	map<id,list<PM_MOQ_price__c> > mapPrices = new map<id,list<PM_MOQ_price__c>>();
    	
    	for(PM_MOQ_price__c moqs : [select List_Price__c,PM_Selected_Dipsensing_Config__c from  PM_MOQ_price__c where PM_Selected_Dipsensing_Config__c in :configIds  ]){
    		list<PM_MOQ_price__c> li = new list<PM_MOQ_price__c>();//temporary list
    		if(mapPrices.get(moqs.PM_Selected_Dipsensing_Config__c) == null)	{
    			mapPrices.put(moqs.PM_Selected_Dipsensing_Config__c , new list<PM_MOQ_price__c> {moqs});
    		}
    		else{
    			li = mapPrices.get(moqs.PM_Selected_Dipsensing_Config__c);
	    		li.add(moqs);
	    		mapPrices.put(moqs.PM_Selected_Dipsensing_Config__c ,  li);	
    		}    		    			
    	}
    
    
        //Map QuoteLineItems Id with its selected Tube COnfig
        Map<Id, PM_Selected_Dipsensing_Config__c> qliIDtoselectDispCFGMap = new Map<Id, PM_Selected_Dipsensing_Config__c>();
        
        for(PM_Selected_Dipsensing_Config__c stc: triggerNew){
            qliIDtoselectDispCFGMap.put(stc.quote_Item__c, stc);
                       
        }
        
        //Retrieve list of QuoteLineItems
        list<QuoteLineItem> quoteLineItems = [select id from QuotelineItem where id in:qliIDtoselectDispCFGMap.keySet() ];
        
        //Retrieve ProdHierarchy PM to Zephyr
        Map<String,String> pmZephyrTableMap_ProdHierarchy = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Table_Name__c,Product_hierarchie__c,Zephyr_Product_hierarchy__c,Product_Segment__c from PM_To_Zephyr__c where Table_Name__c='Product Hierarchy']){
            system.debug('--- ProdHierarchy table----'+String.valueOf(Pm.Product_hierarchie__c));
            pmZephyrTableMap_ProdHierarchy.put(Pm.Product_hierarchie__c+'_'+Pm.Product_Segment__c,Pm.Zephyr_Product_hierarchy__c);
        } 
        
        //Retrieve  Fitting Method PM to Zephyr
        Map<String,String> pmZephyrTableMap_FittingMethod = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Table_Name__c,Attachment__c,Zephyr_Fitting_method__c,Product_Segment__c from PM_To_Zephyr__c where Table_Name__c='Fitting Method']){
            system.debug('--- FittingMethod table----'+Pm.Attachment__c);
            pmZephyrTableMap_FittingMethod.put(Pm.Attachment__c+'_'+Pm.Product_Segment__c,Pm.Zephyr_Fitting_method__c);
        } 
        
        //Retrieve  Neck PM to Zephyr
        Map<String,String> pmZephyrTableMap_Neck  = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Table_Name__c,Neck_Finish__c,Zephyr_Neck__c,Product_Segment__c from PM_To_Zephyr__c where Table_Name__c='Neck']){
            system.debug('--- Neck  table----'+Pm.Neck_Finish__c);
            pmZephyrTableMap_Neck .put(Pm.Neck_Finish__c+'_'+Pm.Product_Segment__c,Pm.Zephyr_Neck__c);
        } 
        //Retrieve  Dose PM to Zephyr
        Map<String,String> pmZephyrTableMap_Dose  = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Table_Name__c,Dosage__c,Zephyr_Dose__c,Product_Segment__c from PM_To_Zephyr__c where Table_Name__c='Dose']){
            system.debug('--- Dose  table----'+Pm.Dosage__c);
            pmZephyrTableMap_Dose .put(Pm.Dosage__c+'_'+Pm.Product_Segment__c,Pm.Zephyr_Dose__c);
        }
        
        //Retrieve  Ref Dressing, Finish  et Actuator PM to Zephyr        
        Map<String,PM_To_Zephyr__c> pmZephyrTableMap_Ref  = new map<String,PM_To_Zephyr__c>();
        For(PM_To_Zephyr__c Pm : [select id,Table_Name__c,Product_Segment__c,Zephyr_Finish__c,Zephyr_Dressing__c,Zephyr_Actuator_Type__c,Concatenate__c from PM_To_Zephyr__c where Table_Name__c='Dressing&Finish&ActuatorType']){
            system.debug('--- Ref  table----'+Pm.Concatenate__c);
            string concatstr = (Pm.Concatenate__c == null)?'':Pm.Concatenate__c.toUppercase();
            pmZephyrTableMap_Ref.put(concatstr+'_'+Pm.Product_Segment__c,Pm);
        }
        
        For(QuoteLineItem qli : quoteLineItems){
            
             //Retrieve Cfg
             PM_Selected_Dipsensing_Config__c config = qliIDtoselectDispCFGMap.get(qli.id);
        
             String ProdHierarchy;
             String Dosage;
            
             qli.Bottle_neck__c = config.Engine_Neck__c;
             
             String defaultValueForIncoterm ='EXW'; 
              
             
             if(config.Product_Segment__c=='Fine mist pumps' || config.Product_Segment__c=='Sampler pumps'){
               
                 ProdHierarchy= config.Product_Name__c;
                 Dosage = config.Dosage__c;
                 qli.Product_Name__c= config.Product_Name__c;
                 if(config.Product_Segment__c=='Fine mist pumps'){
                    qli.Neck_Finish__c = config.Neck_Finish__c;
                    qli.Diptube_Material__c = config.Diptube_Material__c;
                 }             
             }else if(config.Product_Segment__c=='Lotion pumps'){
                 
                  ProdHierarchy= config.Engine_Name__c;
                  Dosage = config.Dosage__c;
                  qli.Product_Name__c= config.Engine_Name__c;
                  qli.Attachment__c = config.Attachment__c;
                 
             }else if(config.Product_Segment__c=='Foam pumps'){
                  ProdHierarchy= config.Product_Hierarchy__c;
                  Dosage = config.Engine_Type__c;
                  qli.Ouptut__c = config.Ouptut__c;
                  qli.Bottle_neck__c = config.Neck__c;
                  if(config.Location__c == 'EU'){
                  	qli.PM_Product_Hierarchy__c = config.Product_Hierarchy__c;
                  	//added by qama
                  	defaultValueForIncoterm ='FCA Alkmaar'; 
                  }
                  else if(config.Location__c == 'US'){                    
                    qli.Product_Name__c= config.Product_Name__c;
                  }
             }
             //added by qama
             qli.Incoterm__c = config.Incoterm__c==null ? defaultValueForIncoterm: config.Incoterm__c; 
            
             if(pmZephyrTableMap_ProdHierarchy.containsKey(ProdHierarchy+'_'+config.Product_Segment__c)){
            
                qli.Product_Hierarchy__c =  pmZephyrTableMap_ProdHierarchy.get(ProdHierarchy+'_'+config.Product_Segment__c);
             }
            
             if(pmZephyrTableMap_FittingMethod.containsKey(config.Attachment__c+'_'+config.Product_Segment__c)){
            
                qli.Fitting_Method__c =  pmZephyrTableMap_FittingMethod.get(config.Attachment__c+'_'+config.Product_Segment__c);
             }
            
            if(pmZephyrTableMap_Neck.containsKey(config.Neck_Finish__c+'_'+config.Product_Segment__c)){
            
                qli.Neck__c =  pmZephyrTableMap_Neck.get(config.Neck_Finish__c+'_'+config.Product_Segment__c);
             }
            
            system.debug('--- config Dosage__c----'+Dosage+'_'+config.Product_Segment__c);
            if(pmZephyrTableMap_Dose.containsKey(Dosage+'_'+config.Product_Segment__c)){
            
                qli.Dose__c =  pmZephyrTableMap_Dose.get(Dosage+'_'+config.Product_Segment__c);
             }
            
             //Create Ref for the translation of Finsh,Dressing and Actuator Type fields
             //Ahmed 03-07-2017: Change of the construction formula of the reference used to find the mapping (see the documentation of the Zephyr Mapping)
             //Ahmed 04-07-2017: New version of the documentation (Empty cases)
            String ref='';
             
             if(config.Product_Segment__c == 'Fine Mist pumps'){

                 if (String.isNotBlank(config.Product_Name__c)){
                     ref = config.Product_Name__c;
                 }
                 if(String.isNotBlank(config.Product_Type__c)){
                     ref= ref + '_' + config.Product_Type__c;
                 }
                 if(String.isNotBlank(config.Pump_Segmentation__c)){
                     ref= ref + '_' + config.Pump_Segmentation__c;
                 }
                 if(String.isNotBlank(config.Attachment__c)){
                     ref= ref + '_' + config.Attachment__c;
                 }
                 if(String.isNotBlank(config.Neck_Finish__c)){
                     ref= ref + '_' + config.Neck_Finish__c;
                 }
                 if(String.isNotBlank(config.Actuator__c)){
                     ref= ref + '_' + config.Actuator__c;
                 }
                 if(String.isNotBlank(config.Collar__c)){
                     ref= ref + '_' + config.Collar__c;
                 }
  
             }
            
            if(config.Product_Segment__c == 'Lotion pumps'){
                
                //Specific case
               String purgeRing = '';
               if (String.isNotBlank(config.Purge_Ring__c) && !'0'.equalsIgnoreCase(config.Purge_Ring__c)) {
                    purgeRing = config.Purge_Ring__c;                
               }
                //Specific case
               String actuatorValue = '';
               if ('SP34D'.equalsIgnoreCase(config.Engine_Name__c) 
                   && 'Elite'.equalsIgnoreCase(config.Pump_Segmentation__c) 
                   && 'Crimp On'.equalsIgnoreCase(config.Attachment__c) ) {
                         actuatorValue =  'w/o';             
               } else {
                       actuatorValue =  config.Actuator__c;
               }
               
                //Start with standard case
               if (String.isNotBlank(config.Engine_Name__c)){
                     ref = config.Engine_Name__c;
               }
               if(String.isNotBlank(config.Pump_Segmentation__c)){
                     ref= ref + '_' + config.Pump_Segmentation__c;
               }
               if(String.isNotBlank(config.Attachment__c)){
                     ref= ref + '_' + config.Attachment__c;
               }
               if(String.isNotBlank(config.Lockability__c)){
                     ref= ref + '_' + config.Lockability__c;
               }
               if(String.isNotBlank(actuatorValue)){
                     ref= ref + '_' + actuatorValue;
               }
               if(String.isNotBlank(config.Neck_Finish__c)){
                     ref= ref + '_' + config.Neck_Finish__c;
               }
               if(String.isNotBlank(config.Collar__c)){
                     ref= ref + '_' + config.Collar__c;
               }
               if(String.isNotBlank(config.Cap__c)){
                     ref= ref + '_' + config.Cap__c;
               }
               if(String.isNotBlank(purgeRing)){
                     ref= ref + '_' + purgeRing;
               }

            }
            
            if(config.Product_Segment__c == 'Foam pumps'){
                if(String.isNotBlank(config.Product_Hierarchy__c)){
                     ref= config.Product_Hierarchy__c;
                } 
                if(String.isNotBlank(config.Engine_Type__c)){
                     ref= ref + + '_' + config.Engine_Type__c;
                }
            }
            
            if(config.Product_Segment__c == 'Sampler pumps'){
                
                if(String.isNotBlank(config.Product_Name__c)){
                     ref= config.Product_Name__c;
                } 
                if(String.isNotBlank(config.Engine_Neck__c)){
                     ref= ref + + '_' + config.Engine_Neck__c;
                }
                if(String.isNotBlank(config.Material__c)){
                     ref= ref + + '_' + config.Material__c;
                }
            }
            
             ref = (ref == null)?'':ref;
            
             System.debug('---- REF ----'+ref);
             

             //Retrieve  Ref Dressing, Finish  et Actuator PM to Zephyr  
             if(pmZephyrTableMap_Ref.containsKey(ref.toUpperCase()+'_'+config.Product_Segment__c)){
            
                 qli.Actuator_Type__c = pmZephyrTableMap_Ref.get(ref.toUpperCase()+'_'+config.Product_Segment__c).Zephyr_Actuator_Type__c;
                 //Ahmed 03-06-2017: What is this fields "Actuor_Type__c" ????
                 qli.Actuor_Type__c = pmZephyrTableMap_Ref.get(ref.toUpperCase()+'_'+config.Product_Segment__c).Zephyr_Actuator_Type__c;
                 qli.Finish__c = pmZephyrTableMap_Ref.get(ref.toUpperCase()+'_'+config.Product_Segment__c).Zephyr_Finish__c;
                 qli.Dressing__c = pmZephyrTableMap_Ref.get(ref.toUpperCase()+'_'+config.Product_Segment__c).Zephyr_Dressing__c;
             }
            
             qli.Engine__c = config.Engine_Name__c;
             qli.Actuator__c = config.Actuator__c;
             qli.Dosage__c = config.Dosage__c;
             // TODO: not found in config
             //qli.Fixation__c = config.Fixation__c;
            
            //Added Neck Finish
            qli.Neck_Finish__c = config.Neck_Finish__c;
            try
            {
                qli.KPI_SKP_Config_OK__c = setSKPKPIs(config, mapPrices.get(config.id));//added by maryem to get the SKP KPI

            }catch (NullPointerException e)
            {
                System.debug( e);
            }



        }
        try {
            update quoteLineItems;
        } catch (DmlException e) {
            System.debug(LoggingLevel.INFO, e);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e);
        }
    }
    
    /**
     * @description return SKP config KPI  
     * @param newQuotes : trigger.new
     * @return boolean
     */
    public static boolean setSKPKPIs(PM_Selected_Dipsensing_Config__c config, List<PM_MOQ_price__c> listMoqs) {
    	
    	Decimal totalPricesColumns = 0;
    	for(PM_MOQ_price__c moqPrice : listMoqs){
    		totalPricesColumns = totalPricesColumns +	moqPrice.List_Price__c;
    	}
    	
    	return (totalPricesColumns ==0 ? false : true);
    	
    }

    
    
    
    
    
    
    
}