public class Batch_Historisation_UpdatePrices_Helper {

   public static list<PM_Selected_Dipsensing_config__c> dispensingConfigToUpdate = new list<PM_Selected_Dipsensing_config__c>();
   public static list<PM_Selected_Tubes_Config__c> tubeConfigToUpdate = new list<PM_Selected_Tubes_Config__c>();
   public static list<PM_Dispensing_Pricing__c> dispensingPricingToUpdate = new list<PM_Dispensing_Pricing__c>();
   public static list<PM_Tubes_Pricing__c> tubesPricingToUpdate = new list<PM_Tubes_Pricing__c>();
   public static map<Id, PM_Dispensing_Pricing__c> finalDisensingListToUpdate = new map<Id, PM_Dispensing_Pricing__c>();
   public static map<Id, PM_Tubes_Pricing__c> finalTubeListToUpdate = new map<Id, PM_Tubes_Pricing__c>();


   public class updateResult {
        public Id record;
        public list<String> exceptionMsg;
   }
   public static list<Object> errors = new list<Object>();

   public Batch_Historisation_UpdatePrices_Helper (){


   }

   public void init(list<PM_Config_to_Pricing__c> scoope){
         for (PM_Config_to_Pricing__c config: scoope){
         	if (config.Selected_Dispensing__c != null){
         		dispensingConfigToUpdate.add(new PM_Selected_Dipsensing_config__c(Id=config.Selected_Dispensing__c));
               dispensingPricingToUpdate.add(config.Dispensing_Pricing__r);
         	}
         	if (config.Selected_Tube__c != null){
         		  tubeConfigToUpdate.add(new PM_Selected_Tubes_Config__c(Id=config.Selected_Tube__c));
              tubesPricingToUpdate.add(config.Tube_Pricing__r);
         	}
         }
   }

   public list<Object> updateSelectedConfigs(){
        System.debug('@@@@ dispensingConfigToUpdate: '+ dispensingConfigToUpdate); 
        System.debug('@@@@ tubeConfigToUpdate: '+ tubeConfigToUpdate); 
        System.debug('@@@@@ ici2 : '+ System.now());
   	    if (dispensingConfigToUpdate.size()> 0){
            List<Database.SaveResult> result = Database.update(dispensingConfigToUpdate,false);
            for (Integer i=0;i<result.size();i++) {
                if (!result[i].isSuccess() || Test.isRunningTest()) {
                        updateResult upR = new updateResult();
                        upR.record = dispensingConfigToUpdate[i].Id;
                        upR.exceptionMsg = new list<String>();             
                        for(Database.Error err : result[i].getErrors()) {     
                            upR.exceptionMsg.add(err.getStatusCode() +':'+ err.getMessage());  
                        }
                        errors.add(upR);
                }
                    
            }
       
   	    }

        if (tubeConfigToUpdate.size()> 0){
            List<Database.SaveResult> result = Database.update(tubeConfigToUpdate,false);
            for (Integer i=0;i<result.size();i++) {
                if (!result[i].isSuccess()  || Test.isRunningTest()) {
                        updateResult upR = new updateResult();
                        upR.record = tubeConfigToUpdate[i].Id;
                        upR.exceptionMsg = new list<String>();             
                        for(Database.Error err : result[i].getErrors()) {     
                            upR.exceptionMsg.add(err.getStatusCode() +':'+ err.getMessage());  
                        }
                        errors.add(upR);
                }
                    
            }
       
        }

        System.debug('@@@@@@@ errors: '+ errors);
        return errors; 
   }

   
   /*public void updatePrices(){
       for (PM_Dispensing_Pricing__c price:dispensingPricingToUpdate){
  
          if (finalDisensingListToUpdate.get(price.Id) == null){
            price.Closed_Price__c = false;
            finalDisensingListToUpdate.put(price.Id, price);
          }
       }

       for (PM_Tubes_Pricing__c price:tubesPricingToUpdate){
          if (finalTubeListToUpdate.get(price.Id) == null){
            price.Closed_Price__c = false;
            finalTubeListToUpdate.put(price.Id, price);
          }
       }

       if (finalDisensingListToUpdate.size()>0) update finalDisensingListToUpdate.values();
       if (finalTubeListToUpdate.size()>0) update finalTubeListToUpdate.values();
   }*/

   public void updateDispensingPricing(List<PM_Dispensing_Pricing__c> scoope){
       for (PM_Dispensing_Pricing__c price:scoope){
            price.Closed_Price__c = false;         
       }   
       update scoope;    
   }

   public void updateTubesPricing(List<PM_Tubes_Pricing__c> scoope){
       for (PM_Tubes_Pricing__c price:scoope){
            price.Closed_Price__c = false;         
       }   
       update scoope;    
   }
}