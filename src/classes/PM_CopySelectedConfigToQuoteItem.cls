public class PM_CopySelectedConfigToQuoteItem {
    
    public static QuoteLineItem populateQuoteItemFromTubesConfig(PM_Selected_Tubes_Config__c tcfg, QuoteLineItem qli) {
        // parameter Tubes EU
        //TODO: Not editable
        //qli.Billing_Currency__c = tcfg.Billing_Currency__c;
        //qli.Quantity = tcfg.Quantity;
        //
        //***************** Sleeve and basic tubes infos *************//
        // New Update for RFQ Details   //
        //Get PM_To_Zyphyr__c Mapping Details
        //Diameter Mapping
        /*
        system.debug('--- Diameter ----'+tcfg.Diameter_mm__c);
        Map<String,Double> pmZephyrTableMap_Diameter = new map<String,Double>();        
        For(PM_To_Zephyr__c Pm : [select id,PM_Diameter__c,Table_Name__c,Zyphyr_Diameter__c from PM_To_Zephyr__c where Table_Name__c='Diameter']){
            system.debug('--- Diameter table----'+String.valueOf(Pm.PM_Diameter__c));
            pmZephyrTableMap_Diameter.put(String.valueOf(Pm.PM_Diameter__c),Pm.Zyphyr_Diameter__c);
        }       
        if(pmZephyrTableMap_Diameter.containsKey(String.valueOf(tcfg.Diameter_mm__c)+'.0')){
            
           qli.Diameter__c =  String.valueOf(pmZephyrTableMap_Diameter.get(String.valueOf(tcfg.Diameter_mm__c)+'.0'));
        }
        //Cap Mapping 
        Map<String,String> pmZephyrTableMap_Cap = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,PM_Eurocode__c,Cap_type_Zephyr__c from PM_To_Zephyr__c where Table_Name__c='Cap' and Location__c=:tcfg.Location__c]){
            
            pmZephyrTableMap_Cap.put(Pm.PM_Eurocode__c,Pm.Cap_type_Zephyr__c);
        }       
        if(pmZephyrTableMap_Cap.containsKey(tcfg.Eurocode__c)){
            
           qli.Cap__c =  pmZephyrTableMap_Cap.get(tcfg.Eurocode__c);
        }
        //Material Mapping
        Map<String,String> pmZephyrTableMap_Material = new map<String,String>();        
        For(PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,Product_Segment__c,Sleeve_Material__c,Sleeve_Material_Mix__c,Material_zephyr__c from PM_To_Zephyr__c where Table_Name__c='Material' and Location__c=:tcfg.Location__c and Product_Segment__c=:tcfg.Product_segment__c and Sleeve_Material__c=:tcfg.Sleeve_Material__c and Sleeve_Material_mix__c=:tcfg.Sleeve_Material_Mix__c ]){
            
            pmZephyrTableMap_Material.put(Pm.Sleeve_Material__c+'_'+Pm.Sleeve_Material_Mix__c,Pm.Material_zephyr__c);
        }       
        if(pmZephyrTableMap_Material.containsKey(tcfg.Sleeve_Material__c+'_'+tcfg.Sleeve_Material_Mix__c)){
           
           qli.Cap__c =  pmZephyrTableMap_Material.get(tcfg.Sleeve_Material__c+'_'+tcfg.Sleeve_Material_Mix__c);
        } 
        //Printing type EU
        if(tcfg.Location__c == 'EU'){
            Map<String,String> pmZephyrTableMap_PrintingEU = new map<String,String>();        
            For(PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,Product_Segment__c,Printing_Zephyr__c from PM_To_Zephyr__c where Table_Name__c='Printing type' and Location__c=:tcfg.Location__c and  Product_Segment__c=:tcfg.Product_segment__c and Printing_techno__c =:tcfg.Printing_technologies__c and Hot_Stamp__c=:tcfg.Hot_Stamp_Top__c]){
                
                pmZephyrTableMap_PrintingEU.put(Pm.Printing_techno__c+'_'+Pm.Hot_Stamp__c,Pm.Printing_Zephyr__c);
            }       
            if(pmZephyrTableMap_PrintingEU.containsKey(tcfg.Printing_technologies__c+'_'+tcfg.Hot_Stamp_Top__c)){
                
               qli.Printing_type__c =  pmZephyrTableMap_PrintingEU.get(tcfg.Printing_technologies__c+'_'+tcfg.Hot_Stamp_Top__c);
            } 
        }
        
        if(tcfg.Location__c == 'US'){
        
            Map<String,String> pmZephyrTableMap_PrintingUS = new map<String,String>();
            For(PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,Product_Segment__c,Printing_Zephyr__c from PM_To_Zephyr__c where Table_Name__c='Printing type' and Location__c=:tcfg.Location__c and  Product_Segment__c=:tcfg.Product_segment__c and Printing_techno__c =:tcfg.Printing_technologies__c and Sikscreen__c=:tcfg.Silkscreen__c]){
                
                pmZephyrTableMap_PrintingUS.put(Pm.Printing_techno__c+'_'+Pm.Sikscreen__c,Pm.Printing_Zephyr__c);
            }
            if(pmZephyrTableMap_PrintingUS.containsKey(tcfg.Printing_technologies__c+'_'+tcfg.Silkscreen__c)){
                
               qli.Printing_type__c =  pmZephyrTableMap_PrintingUS.get(tcfg.Printing_technologies__c+'_'+tcfg.Silkscreen__c);
            } 
        }
        */
        qli.Diameter_mm__c = tcfg.Diameter_mm__c;
        qli.Sleeve_Length_mm__c = tcfg.Sleeve_Length_mm__c;
        qli.Sleeve_type__c = tcfg.Sleeve_type__c;
        qli.Sleeve_material_Mix__c = tcfg.Sleeve_material_Mix__c;
        qli.Shape__c = tcfg.Shape__c;
        qli.Visual_aspect_touch__c = tcfg.Sleeve_Aspect__c;
        qli.Sleeve_Color__c = tcfg.Sleeve_Color__c; // si Laminate alors champs "Metalic Flexo"(à créer) sinon "Sleeve_Color__c"
        qli.of_Flexo_colors__c = tcfg.NB_Flexo_Colors__c; // si vide NB_Flexo_Colors__c est vide alors "-"
        qli.of_Offset_colors__c = tcfg.NB_Offset_Colors__c; // si vide NB_Offset_Colors__c est vide alors "-"
        qli.of_SS_colors__c = tcfg.NB_SS_Colors__c;  // si vide NB_SS_Colors__c est vide alors "-"
        qli.Other_printing_effects__c = tcfg.Printing_Effects__c; // others field in config product
        // TODO: confirm Deco_Hot_Stamping__c or Hot_Stamp_Top__c or Cap_Hot_Stamping__c
        qli.Stamp__c = tcfg.Deco_Hot_Stamping__c;  // Why not Hot_stamping in qli ?
        
        //***************** CAP *************//
        //qli.Reference_Cap__c = tcfg.Eurocode__c;
        qli.Reference_Cap__c = tcfg.Cap_Eurocode__c;  // beter name
        qli.Description__c = tcfg.cap_name__c;
        qli.Color__c = tcfg.Cap_Color__c;
        
        // M35 --> Hot Stamp Top
        // M36 --> translage "Top HS" si Hot Stamp Top(M35)= YES
        // M37 --> HS Contouring
        // M38 --> translage "360° HS" si HS Contouring(M37)= YES
        // M39 --> Silk Screen
        // M40 --> translage "Silk Screen" si Silk Screen(M39)= YES
        // M41 --> Metalisation
        // M42 --> translage "Metallization" si Metalisation(M41)= YES
        // M43 (Cap decoration) --> =SI(M36="";"";M36&" / ")&SI(M38="";"";M38&" / ")&SI(M40="";"";M40&" / ")&SI(M42="";"";M42)
        qli.Cap_decoration__c = 
            ((tcfg.Hot_Stamp_Top__c=='YES') ? 'Top HS'+ ' / ' : '') 
            + ((tcfg.HS_Contouring__c=='YES')? '360° HS'+ ' / ' : '') 
            + ((tcfg.Silk_screen__c=='YES') ? 'Silk Screen'+ ' / ' : '')
            + ((tcfg.Metallization__c=='YES')? 'Metallization'+ ' / ' : '');
        
        // M45 --> Shrink Band
        // M46 --> Translate 'Sleeve' si Shrink Band (M45) == YES
        // M47 --> Manual Capping
        // M48 --> Translate 'Manual Capping' si Manual Capping (M47) == YES
        //(M49)qli.Other__c =SI(M46="";"";M46&" / ")&SI(M48="";"";M48)
        qli.Other__c = ((tcfg.Shrink_band__c=='YES') ? 'Sleeve'+ ' / ' : '') 
            + ((tcfg.Manual_Capping__c=='YES')? 'Manual Capping'+ ' / ' : '');
        
        qli.Dispensing_family__c = tcfg.Dispensing_system_family__c;
        qli.Reference_head__c = tcfg.Head_Name__c;
        qli.Head_Color__c = tcfg.Head_Color__c;
        qli.Peel_Seal__c = tcfg.Peel_Seal__c;
        
        if(tcfg.insert__c=='Laminate Tubes'){
            qli.Rondelle_Insert__c = 
                 ((tcfg.insert__c==null || tcfg.insert__c=='' || tcfg.insert__c=='No') ? '' : 'Insert')
                +((tcfg.rondelle__c==null || tcfg.rondelle__c=='' || tcfg.rondelle__c=='No') ?  '' : 'Rondelle') ;
            //=SI(OU('PRODUCT - Laminate Tube'!$O$40="";'PRODUCT - Laminate Tube'!$O$40="No");"";"Insert")&SI(OU('PRODUCT - Laminate Tube'!$O$43="";'PRODUCT - Laminate Tube'!$O$43="No");"";"Rondelle")
        }
        
        qli.Pack_type__c = 'Standard' ; //tcfg.Pack_type__c;
        qli.PE_bag__c = (tcfg.PE_bag__c == null || tcfg.PE_bag__c == '') ? 'No' : tcfg.PE_bag__c ;
        qli.Polysheet__c = (tcfg.Polysheet__c == null || tcfg.Polysheet__c == '') ? 'No' : tcfg.Polysheet__c ;
        qli.Platt_Level__c = tcfg.Nouveau_Platts__c; 
        
        qli.Incoterms__c = tcfg.Delivery__c + ((tcfg.Destination__c != null)? ': '+tcfg.Destination__c : '' ); //tcfg.Incoterm__c to remove
        //TODO: not found
        //qli.Incoterms_Days__c = tcfg.Incoterms_Days__c; 
        
        //qli.Payment_terms__c = tcfg.Payment_terms__c;
        
        
        qli.Actuator_Type__c = tcfg.Actuator_Type__c;
//        qli.Printing_type__c = tcfg.Printing_type__c;
        
        //*******************COMBO**********************************//
        //fields need to be created in DEV - Exists in UAT
/*        qli.X5_Piece_Price_Currency_per_1000_pieces__c = tcfg.Combo_Num_Tubes_Artwork__c;
        qli.X6_MOQ_per_SKU__c = tcfg.Combo_Num_Versions__c;
        qli.X6_Piece_Price_Currency_per_1000_pieces__c = tcfg.Combo_Num_Plate_Changes__c;
*/
        
        // +++ FROM SERVICE TUBES +++ //
        // TODO Get Service Tubes
        PM_Selected_Service_Tubes_Config__c  sstcfg = getSelectedServiceTubesConfig(tcfg);
        if(sstcfg != null){
            // get from service offer template (free text in template - no field)
            //qli.Comment_on_Price__c = tcfg.Comment_on_Price__c;
            qli.Total_price_for_Artwork__c = sstcfg.Total_price_for_Artwork__c;
            qli.Total_price_for_Samples__c = sstcfg.Total_price_for_Samples__c;
            qli.Regulatory_Affairs__c = sstcfg.Total_amount__c;
            qli.Total_price_for_Preproduction__c = sstcfg.Total_price_for_Preproduction__c;
            
        }
        // +++++++++++++++++++++++++++ // 
        // 
        // parameter Tubes US
        qli.Diameter_inches__c = tcfg.Diameter_inches__c;
        qli.Sleeve_Length_inches__c = tcfg.Sleeve_Length_inches__c;
        qli.Body_Material__c = tcfg.Sleeve_Material__c;
        qli.Sleeve_Finish__c = tcfg.Sleeve_Finish_name__c;
        qli.Cap_Peel_Seal__c = tcfg.Peel_Seal__c;
        qli.Shrink_Band__c = tcfg.Shrink_Band__c;
        qli.Head__c = tcfg.Head_Name__c;
        qli.Head_Aspect__c = tcfg.Head_Aspect__c; 
        
        return qli;
    }
    
    public static QuoteLineItem populateQuoteItemFromDispensingConfig(PM_Selected_Dipsensing_Config__c config, QuoteLineItem qli) {
        qli.Engine__c = config.Engine_Name__c;
        qli.Actuator__c = config.Actuator__c;
        qli.Dosage__c = config.Dosage__c;
        // TODO: not found in config
        //qli.Fixation__c = config.Fixation__c;
        qli.Bottle_neck__c = config.Engine_Neck__c; 
//        qli.Neck__c = config.Neck__c;
//        qli.Cap__c = config.Cap__c;
        // TODO: not found in product config (template ?)
        //qli.Tube_decsription__c = config.Tube_decsription__c;
        
        return qli;
    }
    
    public static PM_Selected_Service_Tubes_Config__c getSelectedServiceTubesConfig(PM_Selected_Tubes_Config__c stc){
        
        Map<String, String> mapfilters = new Map<String, String>();
        mapfilters.put('quote_item__c',stc.quote_item__c);
        List<PM_Selected_Service_Tubes_Config__c> lst =  (List<PM_Selected_Service_Tubes_Config__c>) LC01_SelectedProductConfigCtrl.getsObjectList('PM_Selected_Service_Tubes_Config__c', mapfilters, 'Id');
        if(lst.isEmpty()){
            return null;
        }else{
            return lst.get(0);
        }
        
    }
    
    
}