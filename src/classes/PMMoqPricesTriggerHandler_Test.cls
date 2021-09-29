@isTest 
private class PMMoqPricesTriggerHandler_Test {
	@testSetup 
    private static void createTestData() {
    	TriggerHandler.bypass('PMSelectedDipsensingconfigTriggerHandler');
		TriggerHandler.bypass('PMSelectedTubesConfigTriggerHandler');
		TriggerHandler.bypass('PMMoqPricesTriggerHandler');  
		
    	//Insert selected Product Config Dispensing
    	PM_Selected_Dipsensing_Config__c selectedDispensing = new PM_Selected_Dipsensing_Config__c(Location__c='EU');
    	insert selectedDispensing;
    	//Insert selected Product Config Tubes
    	 PM_Selected_Tubes_Config__c selectedTube = new PM_Selected_Tubes_Config__c(Location__c='US'); 
    	insert selectedTube;	
    	
    	//Insert PM MOQ Price Records'
    	list<PM_MOQ_price__c> liMoqPricesToInsert = new list<PM_MOQ_price__c>();
    	for(integer i=0; i<101; i++){
    	 	 PM_MOQ_price__c pmMOQTube = new PM_MOQ_price__c(
                    MOQ_Min__c = 10+i,
                    MOQ_Max__c =20,
                    PM_Selected_Tubes_Config__c = selectedTube.ID,
                    List_Price__c = 120);
                    
             PM_MOQ_price__c pmMOQDisp = new PM_MOQ_price__c(
                    MOQ_Min__c = 100+i,
                    MOQ_Max__c =200,
                    PM_Selected_Dipsensing_Config__c = selectedDispensing.ID,
                    List_Price__c = 120);  
                         
    	 	liMoqPricesToInsert.add(pmMOQTube);	
    	 	liMoqPricesToInsert.add(pmMOQDisp);	
    	 }
    	 insert liMoqPricesToInsert;
    	
    }//end createTestData
	
	//Test setUniqueKey implemented in PMMoqPricesService
    static testMethod void setUniqueKey_Disp_Test() {
    	//Get list of Pm Moq Prices
    	map<id,PM_MOQ_price__c> liMoqPricesDisp = new map<id,PM_MOQ_price__c>([select id,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_MOQ_price__c
    												where PM_Selected_Dipsensing_Config__c!=null ]);
    												
    	PMMoqPricesService.setUniqueKey(liMoqPricesDisp.keyset());
    	for(PM_MOQ_price__c pm : [select id,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_MOQ_price__c
    												where PM_Selected_Dipsensing_Config__c!=null ]){
    		system.assertEquals(pm.ExtId__c, pm.MOQ_Min__c+'-'+pm.Config_ID__c)		;										
    	}//end for
        
    }//end setUniqueKey_Test
    
    static testMethod void setUniqueKey_Tube_Test() {
    	//Get list of Pm Moq Prices
    	map<id,PM_MOQ_price__c> liMoqPricesTube = new map<id,PM_MOQ_price__c>([select id,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_MOQ_price__c
    												where PM_Selected_Tubes_Config__c!=null ]);
    												
    	PMMoqPricesService.setUniqueKey(liMoqPricesTube.keyset());
    	for(PM_MOQ_price__c pm : [select id,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_MOQ_price__c
    												where PM_Selected_Tubes_Config__c!=null ]){
    		system.assertEquals(pm.ExtId__c, pm.MOQ_Min__c+'-'+pm.Config_ID__c)		;										
    	}//end for
        
    }//end setUniqueKey_Test
}