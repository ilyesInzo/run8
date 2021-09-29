@isTest
private class PMPriceDetailsTriggerHandler_Test {

    @testSetup 
    private static void createTestData() {
    	TriggerHandler.bypass('PMSelectedDipsensingconfigTriggerHandler');
		TriggerHandler.bypass('PMSelectedTubesConfigTriggerHandler');
		TriggerHandler.bypass('PMPriceDetailsTriggerHandler');  
		TriggerHandler.bypass('PMMoqPricesTriggerHandler');
		 		 
    	//Insert selected Product Config Dispensing
    	PM_Selected_Dipsensing_Config__c selectedDispensing = new PM_Selected_Dipsensing_Config__c(Location__c='EU');
    	insert selectedDispensing;
    	//Insert selected Product Config Tubes
    	 PM_Selected_Tubes_Config__c selectedTube = new PM_Selected_Tubes_Config__c(Location__c='US'); 
    	insert selectedTube;	
    	
    	//Insert PM MOQ Price Records'
    	list<PM_Price_Detail__c> liPricesToInsert = new list<PM_Price_Detail__c>();
    	for(integer i=0; i<101; i++){
    	 	 PM_Price_Detail__c pmMOQTube = new PM_Price_Detail__c(
    	 	 		Name='Section Name',
                    MOQ_Min__c = 10+i,
                    MOQ_Max__c =20,
                    PM_Selected_Tubes_Config__c = selectedTube.ID,
                    List_Price__c = 120);
                    
             PM_Price_Detail__c pmMOQDisp = new PM_Price_Detail__c(
             		Name='Section Name',
                    MOQ_Min__c = 100+i,
                    MOQ_Max__c =200,
                    PM_Selected_Dipsensing_Config__c = selectedDispensing.ID,
                    List_Price__c = 120);  
                         
    	 	liPricesToInsert.add(pmMOQTube);	
    	 	liPricesToInsert.add(pmMOQDisp);	
    	 }
    	 insert liPricesToInsert;
    	
    }//end createTestData
	
	//Test setUniqueKey implemented in PMMoqPricesService
    static testMethod void setUniqueKey_Disp_Test() {
    	//Get list of Pm Moq Prices
    	map<id,PM_Price_Detail__c> liMoqPricesDisp = new map<id,PM_Price_Detail__c>([select id,name, ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_Price_Detail__c
    												where PM_Selected_Dipsensing_Config__c!=null ]);
    	TEst.startTest();    												
    		PMPriceDetailsService.setUniqueKey(liMoqPricesDisp.keyset());
    	Test.stopTest();
    	
    	for(PM_Price_Detail__c pm : [select id,name, ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_Price_Detail__c
    												where PM_Selected_Dipsensing_Config__c!=null ]){
    		system.assertEquals(pm.ExtId__c, pm.Config_ID__c+pm.Name+integer.valueof(pm.MOQ_Min__c))		;										
    	}//end for
        
    }//end setUniqueKey_Test
    
    static testMethod void setUniqueKey_Tube_Test() {
    	//Get list of Pm Moq Prices
    	map<id,PM_Price_Detail__c> liPriceDetailsTube = new map<id,PM_Price_Detail__c>([select id,name,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_Price_Detail__c
    												where PM_Selected_Tubes_Config__c!=null ]);
    	TEst.startTest();    											
    		PMPriceDetailsService.setUniqueKey(liPriceDetailsTube.keyset());
    	Test.stopTest();
    	
    	for(PM_Price_Detail__c pm : [select id,name,ExtId__c,Config_ID__c,MOQ_Min__c 
    												from PM_Price_Detail__c
    												where PM_Selected_Tubes_Config__c!=null ]){
    		system.assertEquals(pm.ExtId__c, pm.Config_ID__c+pm.Name+integer.valueof(pm.MOQ_Min__c))		;										
    	}//end for
        
    }//end setUniqueKey_Test
}