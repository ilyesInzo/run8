public with sharing class LC01_DetailCtrl {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Apex controller for lightning components LC01_Detail_XXX
 * Notes            : e.g. LC01_Detail_EU_TubePlastic
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   17-FEB-2017  Gulshan             Initial version
 *****************************************************************************/ 

    public static final String TG1 = 'TG1';
    public static final String STANDARD = 'standard';


    @AuraEnabled
    public static Map <String, Object> getDetailPrices(Id qliId){

        
        Map <String, Map <String, List <PM_Price_Detail__c >>> mapDetails = new Map <String, Map <String, List <PM_Price_Detail__c >>>();
        PM_Selected_Tubes_Config__c tubeConfig = null;
        PM_Selected_Dipsensing_Config__c dispensingConfig = null;
        List<PM_Selected_Tubes_Config__c> tubeConfigs = [select id, Billing_Currency__c, Billing_Currency_Position__c   
                           from PM_Selected_Tubes_Config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1];        
        if (tubeConfigs != null && tubeConfigs.size() ==1 ){
            tubeConfig = tubeConfigs.get(0);
            
        } else {
            List<PM_Selected_Dipsensing_Config__c> dispensingConfigs = [select id, Billing_Currency__c, Billing_Currency_Position__c  
                          from PM_Selected_Dipsensing_Config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1 ];
            if (dispensingConfigs != null && dispensingConfigs.size() ==1 ){
                dispensingConfig = dispensingConfigs.get(0);
            }
        }
                    
        for(PM_Price_Detail__c pricing : [select List_Price__c, List_Price_Display__c, MOQ_Min__c, Name, Section__c, ExtId__c, Price_Override__c,
                                          PM_Selected_Tubes_Config__c, PM_Selected_Dipsensing_Config__c
                                            from PM_Price_Detail__c
                                            where Quote_item__c = :qliId and moq_max__c != 999
                                            order by CreatedDate desc,MOQ_Min__c asc ]){
                                            //order by MOQ_Min__c ]){
            if(mapDetails.containsKey(pricing.Section__c)){
                Map <String, List <PM_Price_Detail__c >> mapLineInfo = mapDetails.get(pricing.Section__c);
                if(mapLineInfo.containsKey(pricing.Name)){
                    mapLineInfo.get(pricing.Name).add(pricing);
                }else{
                    mapLineInfo.put(pricing.Name, new List <PM_Price_Detail__c>{pricing});
                }
            }else{
                Map <String, List <PM_Price_Detail__c >> mapLineInfo = new Map <String, List <PM_Price_Detail__c >>{
                    pricing.Name => new List <PM_Price_Detail__c>{pricing}
                };
                mapDetails.put(pricing.Section__c, mapLineInfo);
            }
        	system.Debug('pricing===== '+pricing);
        }
		
		
		for(PM_Price_Detail__c pricing : [select List_Price__c, List_Price_Display__c, MOQ_Min__c, Name, Section__c, ExtId__c, Price_Override__c,
                                          PM_Selected_Tubes_Config__c, PM_Selected_Dipsensing_Config__c
                                            from PM_Price_Detail__c
                                            where Quote_item__c = :qliId and moq_max__c = 999
                                            order by CreatedDate desc,MOQ_Min__c asc ]){
                                            //order by MOQ_Min__c ]){
            if(mapDetails.containsKey(pricing.Section__c)){
                Map <String, List <PM_Price_Detail__c >> mapLineInfo = mapDetails.get(pricing.Section__c);
                if(mapLineInfo.containsKey(pricing.Name)){
                    mapLineInfo.get(pricing.Name).add(pricing);
                }else{
                    mapLineInfo.put(pricing.Name, new List <PM_Price_Detail__c>{pricing});
                }
            }else{
                Map <String, List <PM_Price_Detail__c >> mapLineInfo = new Map <String, List <PM_Price_Detail__c >>{
                    pricing.Name => new List <PM_Price_Detail__c>{pricing}
                };
                mapDetails.put(pricing.Section__c, mapLineInfo);
            }
        	system.Debug('pricing===== '+pricing);
        }
		
		
        List <PM_MOQ_price__c> listMOQPrices = [select List_Price__c,Rounded_List_Price__c, MOQ_Min__c ,IsCombo__c,No_Ref_If_Combo_Comments__c
                                                from PM_MOQ_price__c
                                                where Quote_item__c = :qliId AND moq_max__c != 999 //LAST MODIFIED BY MARYEM QADA , to prevent the other moq from displaying 
                                                order by MOQ_Min__c];
		
		PriceDetailLine totalPriceLine = new PriceDetailLine();
        for (PM_MOQ_price__c totalMoqPrice : [select List_Price__c, Rounded_List_Price__c,MOQ_Min__c, List_Price_Display__c, IsCombo__c, No_Ref_If_Combo_Comments__c 
                                                from PM_MOQ_price__c
                                                where Quote_item__c = :qliId AND MOQ_MAx__c !=999 //LAST MODIFIED BY MARYEM QADA , in case of having two records with the same min MOQ 
                                                order by MOQ_Min__c]) {
            totalPriceLine = PriceDetailLine.insertPriceDetailIntoLine(false,totalPriceLine, totalMoqPrice.MOQ_Min__c,  totalMoqPrice.List_Price_Display__c, 0,totalMoqPrice.IsCombo__c, totalMoqPrice.No_Ref_If_Combo_Comments__c);
        }
        //get specific MOQ and its specific total price
		List <PM_MOQ_price__c> specificMOQ = [select List_Price_Display__c, MOQ_Min__c   ,No_Ref_If_Combo_Comments__c
                                                from PM_MOQ_price__c
                                                where Quote_item__c = :qliId AND moq_max__c = 999];
                                                
		return new Map <String, Object>{
			'totalLine' => totalPriceLine,
            'details'   => mapDetails,
            'total'     => listMOQPrices,
            'currency' => (tubeConfig != null? tubeConfig.Billing_Currency__c: dispensingConfig.Billing_Currency__c),
            'currencyPosition' => (tubeConfig != null? tubeConfig.Billing_Currency_Position__c: dispensingConfig.Billing_Currency_Position__c),
        	'specificMOQ' 		=> 	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].MOQ_Min__c)  : null),
            'totalSpecificMOQ' 	=>	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].List_Price_Display__c): null),
            'specificCombo' 	=>	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].No_Ref_If_Combo_Comments__c): null) 
       };
    }
    
    @AuraEnabled
    public static Map <String, Object> getDetailPricesByObject(Id qliId){

        Map <String, List <PriceDetailLine >> mapSectionPriceDetaiLineDetails = new Map <String, List <PriceDetailLine>>();
        Map <String, PriceDetailLine> mapPriceLine = new Map <String, PriceDetailLine>();

        
//        Map <String, Map <String, List <PM_Price_Detail__c >>> mapDetails = new Map <String, Map <String, List <PM_Price_Detail__c >>>();
        PM_Selected_Tubes_Config__c tubeConfig = null;
        PM_Selected_Dipsensing_Config__c dispensingConfig = null;
        List<PM_Selected_Tubes_Config__c> tubeConfigs = [select id, Billing_Currency__c, Billing_Currency_Position__c ,Diameter_inches__c, Diameter_mm__c  
                           from PM_Selected_Tubes_Config__c where Quote_item__c =: qliId order by createddate DESC NULLS Last, LastModifiedDate DESC NULLS Last ];        
        if (tubeConfigs != null && tubeConfigs.size() > 0 ){
            if(tubeConfigs.size() ==1 || tubeConfigs.get(0).Diameter_inches__c!=null || tubeConfigs.get(0).Diameter_mm__c!=null)
            {tubeConfig = tubeConfigs.get(0);
            }
            else
            {
                for(PM_Selected_Tubes_Config__c tub :tubeConfigs)
                {
                     if( tub.Diameter_inches__c!=null || tub.Diameter_mm__c!=null)
                     {tubeConfig =tub;
                      break;
                     }
                }
                if(tubeConfig == null)tubeConfig = tubeConfigs.get(0);
                //tubeConfig = tubeConfigs.get(1);
            }
        } else {
            List<PM_Selected_Dipsensing_Config__c> dispensingConfigs = [select id, Billing_Currency__c, Billing_Currency_Position__c  
                          from PM_Selected_Dipsensing_Config__c where Quote_item__c =: qliId];
            if (dispensingConfigs != null && dispensingConfigs.size() ==1 ){
                dispensingConfig = dispensingConfigs.get(0);
            }
        }
         string pmselectedId =  (tubeConfig != null)?tubeConfig.id:dispensingConfig.id;
        for(PM_Price_Detail__c pricing : [select List_Price__c, List_Price_Display__c, MOQ_Min__c, Name, Section__c, ExtId__c, Price_Override__c,
                                          PM_Selected_Tubes_Config__c, PM_Selected_Dipsensing_Config__c,is_Specific_MOQ__c
                                            from PM_Price_Detail__c
                                            where Quote_item__c = :qliId AND( pm_selected_tubes_config__c =:pmselectedId OR PM_Selected_Dipsensing_config__c=:pmselectedId) 
                                            order by Name, Section__c]){
                                                
             PriceDetailLine priceLine =  mapPriceLine.get(pricing.Name);
             if (priceLine == null) {
                 priceLine = new PriceDetailLine(); 
                 priceLine.title = pricing.Name;
                 priceLine.section = pricing.Section__c;
             }                                                 
             system.Debug('@@qama pricing '+pricing);  
             system.Debug('@@qama priceLine '+priceLine);  
             
             mapPriceLine.put(pricing.Name, PriceDetailLine.insertPriceDetailIntoLine(pricing.is_Specific_MOQ__c, priceLine, pricing.MOQ_Min__c, pricing.List_Price_Display__c, pricing.Price_Override__c,'',''));
        }
 
        PriceDetailLine totalPriceLine = new PriceDetailLine();
        for (PM_MOQ_price__c totalMoqPrice : [select List_Price__c,Rounded_List_Price__c, MOQ_Min__c, List_Price_Display__c, IsCombo__c, No_Ref_If_Combo_Comments__c 
                                                from PM_MOQ_price__c
                                                where Quote_item__c = :qliId AND MOQ_MAx__c !=999 //LAST MODIFIED BY MARYEM QADA , in case of having two records with the same min MOQ 
                                              AND( pm_selected_tubes_config__c =:pmselectedId OR PM_Selected_Dipsensing_config__c=:pmselectedId) 
                                              order by MOQ_Min__c]) {
            totalPriceLine = PriceDetailLine.insertPriceDetailIntoLine(false,totalPriceLine, totalMoqPrice.MOQ_Min__c,  totalMoqPrice.List_Price_Display__c, 0,totalMoqPrice.IsCombo__c, totalMoqPrice.No_Ref_If_Combo_Comments__c);
        }
		//get specific MOQ and its specific total price
		List <PM_MOQ_price__c> specificMOQ = [select List_Price_Display__c, MOQ_Min__c   ,No_Ref_If_Combo_Comments__c
                                                from PM_MOQ_price__c
                                                where Quote_item__c = :qliId AND moq_max__c = 999];
                                                
        //system.debug('mapDetails=' + mapPriceLine);
        //system.debug('listMOQPrices=' + totalPriceLine);
        //system.debug('TUBE=' + tubeConfig);
        //system.debug('DISPENSING=' + dispensingConfig);
           //         'details'   => mapDetails,
        return new Map <String, Object>{
            'details'   => mapPriceLine,
            'totalLine'     => totalPriceLine,
            'currency' => (tubeConfig != null? tubeConfig.Billing_Currency__c: dispensingConfig.Billing_Currency__c),
            'currencyPosition' => (tubeConfig != null? tubeConfig.Billing_Currency_Position__c: dispensingConfig.Billing_Currency_Position__c),
            'specificMOQ' 		=> 	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].MOQ_Min__c)  : null),
            'totalSpecificMOQ' 	=>	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].List_Price_Display__c): null),
            'specificCombo' 	=>	(specificMOQ.size()>0 ? string.valueof(specificMOQ[0].No_Ref_If_Combo_Comments__c): null) 
        };
    }
    

    
    
    @AuraEnabled
    public static void saveDetailPrices(map<String, List<Object>> overridepricelist, String qliId){
        PM_Selected_Tubes_Config__c selectedTube = new PM_Selected_Tubes_Config__c();
        PM_Selected_Dipsensing_config__c selectedDispensingConfig= new PM_Selected_Dipsensing_config__c();    
        
        List<PM_Selected_Tubes_Config__c> tubes = new List<PM_Selected_Tubes_Config__c>();

        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('PM_Selected_Tubes_Config__c').getDescribe().fields.getMap();
        List<String> allFields = new List<String>();
        for(Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            allFields.add(fieldResult.getname());
        }

        String query = 'Select ';
        for(String field : allFields){
            query += field + ', ';
        }
        query = query.left(query.length()-2);
        query += ' from PM_Selected_Tubes_Config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1';

        tubes = Database.query(query);

        for( PM_Selected_Tubes_Config__c tube : tubes){
            selectedTube = tube;
        }

        List<PM_Selected_Dipsensing_config__c> disps = new List<PM_Selected_Dipsensing_config__c>();

        Map<String, Schema.SObjectField> fieldsDisp = Schema.getGlobalDescribe().get('PM_Selected_Dipsensing_config__c').getDescribe().fields.getMap();
        List<String> allFieldsDisp = new List<String>();
        for(Schema.SObjectField fieldRefDisp : fieldsDisp.values()) {
            Schema.DescribeFieldResult fieldResultDisp = fieldRefDisp.getDescribe();
            allFieldsDisp.add(fieldResultDisp.getname());
        }

        String queryDisp = 'Select ';
        for(String fieldDisp : allFieldsDisp){
            queryDisp += fieldDisp + ', ';
        }
        queryDisp = queryDisp.left(queryDisp.length()-2);
        queryDisp += ' from PM_Selected_Dipsensing_config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1';

        disps = Database.query(queryDisp);

        for( PM_Selected_Dipsensing_config__c disp : disps){
            selectedDispensingConfig = disp;
        }

        /*for( PM_Selected_Tubes_Config__c tube : [Select Id, Location__c, Quote_item__c, Product_Segment__c, Billing_Currency_Rate__c, Head_Name__c, Diameter_mm__c, Sleeve_length_mm__c, Specific_length_mm__c, Head_color__c, Head_Aspect__c, Peel_Seal__c, Sleeve_Material_Mix__c, Sleeve_Aspect__c, Sleeve_Finish_name__c, Cap_Eurocode__c, Cap_Aspect__c, Cap_Color__c, Metallization__c, NB_Flexo_Colors__c, Metalic_Flexo__c, Silkscreen__c, Cold_Hot_Foil__c, Rondelle__c, insert__c, Combo_Num_Versions__c, Combo_Num_Tubes_Artwork__c, Combo_Num_Plate_Changes__c, Nouveau_Platts__c, Manual_Packing__c, PE_Bag__c, Delivery__c, Payment_terms__c, Stockage__c from PM_Selected_Tubes_Config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1]){
            selectedTube = tube;
        }
        
        for(PM_Selected_Dipsensing_config__c disp :[Select Id, Location__c, Quote_item__c, Quote_Product_Segment__c, Product_Segment__c, Product_Type__c, Product_Name__c, Pump_Segmentation__c, Attachment__c, Neck_Finish__c, Actuator__c, Collar__c, Cap_Type__c, Actuator_Finishing__c, Collar_or_Cup_Finish__c, Insert_Type__c, Insert_Coloring__c, Insert_Finishing__c, Difficult_Bulk__c, Dosage__c, Gasket_Material__c, Diptube_Length__c, Diptube_Material__c, Diptube_Material_length_mm__c, Colored_Diptube__c, Billing_Currency_Rate__c, Collar_Finishing__c, Cap_Finishing__c, Product_Hierarchy__c, Foam_Quality__c, Bottle_Size__c, Sleeved_Pump__c, Engine_type__c from PM_Selected_Dipsensing_config__c where Quote_item__c =: qliId order by LastModifiedDate desc limit 1]){
            selectedDispensingConfig = disp;
        }*/
        
        set<String> sectionset = new set<String>();
        set<String> titleset = new set<String>();
        set<Integer> moqset = new set<Integer>();
        
        for(String s : overridepricelist.keySet()){
            system.debug('@@qama s '+s);
           	if(s.contains('=')){
           		List<String> kname = s.split('=');
	            sectionset.add(String.ValueOf(kname[0]));
	            titleset.add(String.ValueOf(kname[1]));
	            moqset.add(Integer.ValueOf(kname[2]));	
           	}
                        
            system.debug('*****************' + s);
            system.debug('*****************' + overridepricelist.get(s));
            
        }
        
        string tubequery = '%'+selectedTube.Id +'%';
        string dispquery = '%'+selectedDispensingConfig.Id+'%';
        
        List<PM_Price_Detail__c> pricings = [select List_Price__c, MOQ_Min__c, Name, Section__c, ExtId__c,
                                             PM_Selected_Tubes_Config__c, PM_Selected_Dipsensing_config__c
                                            from PM_Price_Detail__c
                                            where Quote_item__c = :qliId and Section__c in:sectionset 
                                            and Name in:titleset and MOQ_Min__c in:moqset 
                                            and (ExtId__c like:tubequery OR ExtId__c like:dispquery)];
                                            
        List<PM_Price_Detail__c> pricingsUpdatelst = new List<PM_Price_Detail__c>();
        
        for(PM_Price_Detail__c priced : pricings){
            string buildkey = priced.Section__c + '=' + priced.Name + '=' + String.ValueOf(priced.MOQ_Min__c);
            Decimal overrideprice = null;
            if(overridepricelist.get(buildkey) != null){
                overrideprice = (overridepricelist.get(buildkey)[0] == 0)?null:(Decimal)overridepricelist.get(buildkey)[0];
            }
            if(priced.List_Price__c  != overrideprice){
               priced.Price_Override__c = overrideprice;
               pricingsUpdatelst.add(priced);             
            }
        }
        
        if(!pricingsUpdatelst.isEmpty()){
            update pricingsUpdatelst;
            
            //Arthur L : Tous les calculs sont effectués et pas juste le total
            
            //PMCalculatorUtility.calculateTotalMOQPRice(selectedTubeId, selectedDispensingConfigId, qliId);
            if(selectedTube.Id != null){
                PMCalculatorUtility.handleCalculator(selectedTube);
            }
            else if(selectedDispensingConfig.Id != null){
                PMCalculatorUtility.handleCalculatorDispensing(selectedDispensingConfig);
            }            

            LC01_PriceRecommendation.getPriceRecommendation(qliId);
        }
    }
/* *
 * This added part in order to treat ticket num: 6329.
 * Added By Thanina Yaya
 * getUserProfileName(): in order to get the profile of logged user.
 *
 **/   
    @AuraEnabled
    public static Boolean checkCurrentUserProfileName()
    {
           //Label.LoggedUserProfileName
           Profile currentUserProf = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
           if(currentUserProf.Name.equalsIgnoreCase(Label.LoggedUserProfileName) || currentUserProf.Name.equalsIgnoreCase('System Administrator')) return true;
           return false;
    } 

    

}