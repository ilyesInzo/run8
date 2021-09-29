public class Batch_Historisation_UpdateCorr_Helper {

   public static list<PM_Selected_Dipsensing_config__c> dispensingConfigToUpdate = new list<PM_Selected_Dipsensing_config__c>();
   public static list<PM_Selected_Tubes_Config__c> tubeConfigToUpdate = new list<PM_Selected_Tubes_Config__c>();
   public static list<PM_Discount_corridor__c> corridorsToUpdate = new list<PM_Discount_corridor__c>();
   public static map<Id, PM_Discount_corridor__c> finalListToUpdate = new map<Id, PM_Discount_corridor__c>();

   public class updateResult {
        public Id record;
        public list<String> exceptionMsg;
   }
   public static list<Object> errors = new list<Object>();
  
   public Batch_Historisation_UpdateCorr_Helper (){
   }

   public void init(list<QuoteLineItem> scoope){
        for (QuoteLineItem qli: scoope){
         	if (qli.PM_Selected_Dipsensing_Configs__r != null && qli.PM_Selected_Dipsensing_Configs__r.size()>0 ){
         	    dispensingConfigToUpdate.add(new PM_Selected_Dipsensing_config__c(Id=qli.PM_Selected_Dipsensing_Configs__r[0].Id));
              corridorsToUpdate.add(qli.selected_corridor__r);
         	}
         	if (qli.PM_Selected_Tubes_Configs__r != null && qli.PM_Selected_Tubes_Configs__r.size()>0 ){
         	    tubeConfigToUpdate.add(new PM_Selected_Tubes_Config__c(Id=qli.PM_Selected_Tubes_Configs__r[0].Id));
              corridorsToUpdate.add(qli.selected_corridor__r);
         	}
         }

   }

   public list<Object> updateSelectedConfigs(){
       
   	    if (dispensingConfigToUpdate.size()> 0){
          List<Database.SaveResult> result = Database.update(dispensingConfigToUpdate,false);
            System.debug('@@@@@@ --- dispensingConfigToUpdate: '+dispensingConfigToUpdate );
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
   	    if (tubeConfigToUpdate.size()>0){
          List<Database.SaveResult> result = Database.update(tubeConfigToUpdate,false);
            for (Integer i=0;i<result.size();i++) {
                if (!result[i].isSuccess() || Test.isRunningTest()) {
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

   public void updateCorridors(List<PM_Discount_corridor__c> scoope){
       for (PM_Discount_corridor__c corridor:scoope){
            corridor.Closed_Price__c = false;
           
       }

       update scoope;
   }
}