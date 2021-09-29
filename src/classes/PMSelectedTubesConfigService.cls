public with sharing class PMSelectedTubesConfigService {
    /*
    * Prefill values of Resin Index from PM Tubes Config
    */
    public static void fillResinIndexValues(List<PM_Selected_Tubes_Config__c> triggerNew) {
        //get a map by location_sub segment of resinIndex ==> bulk process
        map<string, double> mapConfigToResinIndex = new map<string, double>();
        for (PM_Tubes_Config__c pmTC : [
                select Resin_Index__c,Tubes_segment__c,Location__c
                from PM_Tubes_Config__c
                where Table_Name__c in ('Platts base', 'CDI') AND ActiveValue__c = 'TRUE'
        ]) {
            if (mapConfigToResinIndex.get(pmTC.Location__c + '_' + pmTC.Tubes_segment__c) == null)
                mapConfigToResinIndex.put(pmTC.Location__c + '_' + pmTC.Tubes_segment__c, pmTC.Resin_Index__c) ;
        }//end for PM Tubes config

        //Set the resin Index ==> Bulk processing
        for (PM_Selected_Tubes_Config__c pmSelTC : triggerNew) {
            String key = null;
            //Laminate tubes => Laminate
            if (pmSelTC.Product_segment__c != null) {
                if (pmSelTC.Product_segment__c.contains('Laminate')) {
                    key = pmSelTC.Location__c + '_Laminate';
                } else if (pmSelTC.Product_segment__c.contains('Plastic')
                        && pmSelTC.Purefoil_Segment__c == false) {//Plastic tubes => Plastic
                    key = pmSelTC.Location__c + '_Plastic';
                } else if (pmSelTC.Product_segment__c.contains('Plastic')
                        && pmSelTC.Purefoil_Segment__c == true) {//Purefoil tubes ==> Purefoil
                    key = pmSelTC.Location__c + '_Purefoil';
                }
            }//end if product segment is not blank


            //set the resin Index value
            pmSelTC.Resin_Index__c = pmSelTC.Location__c == 'US' ? mapConfigToResinIndex.get(key) : null;
            pmSelTC.Nouveau_Platts__c = pmSelTC.Location__c == 'EU' ? mapConfigToResinIndex.get(key) : null;
        }//end bulk processing
    }// end method fillResinIndexValues

    public static void copyDataToQuoteItem(List<PM_Selected_Tubes_Config__c> triggerNew) {
        Map<Id, PM_Selected_Tubes_Config__c> stcMap = new Map<Id, PM_Selected_Tubes_Config__c>();
        for (PM_Selected_Tubes_Config__c stc : triggerNew) {
            stcMap.put(stc.quote_Item__c, stc);
        }
        // get QuoteLineItems
        Map<Id, QuoteLineItem> qlisMap = new Map<Id, QuoteLineItem>([
                Select Id
                from QuoteLineItem
                WHERE Id IN :(stcMap.keySet())
        ]);
        // Copy field to QuoteItem
        Map<Id, QuoteLineItem> qlisMapUpdated = new Map<Id, QuoteLineItem>();


        for (Id qliId : qlisMap.keySet()) {
            qlisMapUpdated.put(qliId, PM_CopySelectedConfigToQuoteItem.populateQuoteItemFromTubesConfig(stcMap.get(qliId), qlisMap.get(qliId)));
        }

        Update qlisMapUpdated.values();

    }

    //Chris Rewritten for Bulk Process
    public static void copyDataToQuoteItemVer2(List<PM_Selected_Tubes_Config__c> triggerNew) {

        //Map QuoteLineItems Id with its selected Tube COnfig
        Map<Id, PM_Selected_Tubes_Config__c> qliIDtoselectTubeCFGMap = new Map<Id, PM_Selected_Tubes_Config__c>();

        //Sets for PM to ZEphyr Map
        Set<String> location = new set<String>();

        for (PM_Selected_Tubes_Config__c stc : triggerNew) {
            qliIDtoselectTubeCFGMap.put(stc.quote_Item__c, stc);

            location.add(stc.Location__c);
        }

        //Retrieve list of QuoteLineItems
        list<QuoteLineItem> quoteLineItems = [select id, location__c from QuotelineItem where id in:qliIDtoselectTubeCFGMap.keySet()];

        //Retrieve diameter PM to Zephyr
        Map<String, Double> pmZephyrTableMap_Diameter = new map<String, Double>();
        //for US
        Map<String, Double> pmZephyrTableMap_DiameterInch = new map<String, Double>();
        For (PM_To_Zephyr__c Pm : [select id,PM_Diameter__c,PM_Diameter_inches__c,Table_Name__c,Zyphyr_Diameter__c from PM_To_Zephyr__c where Table_Name__c = 'Diameter']) {
            //system.debug('--- Diameter table----'+String.valueOf(Pm.PM_Diameter__c));
            pmZephyrTableMap_Diameter.put(String.valueOf(Pm.PM_Diameter__c), Pm.Zyphyr_Diameter__c);
            //for US use PM_Diameter_inches__c
            pmZephyrTableMap_DiameterInch.put(Pm.PM_Diameter_inches__c, Pm.Zyphyr_Diameter__c);
        }

        //Retrieve Cap Pm to Zephyr
        Map<String, String> pmZephyrTableMap_Cap = new map<String, String>();
        For (PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,PM_Eurocode__c,Cap_type_Zephyr__c from PM_To_Zephyr__c where Table_Name__c = 'Cap']) {

            pmZephyrTableMap_Cap.put(Pm.PM_Eurocode__c + '_' + Pm.Location__c, Pm.Cap_type_Zephyr__c);
        }

        //REtrieve Material Pm to Zephyr
        Map<String, String> pmZephyrTableMap_Material = new map<String, String>();
        For (PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,Product_Segment__c,Sleeve_Material__c,Sleeve_Material_Mix__c,Material_zephyr__c from PM_To_Zephyr__c where Table_Name__c = 'Material']) {

            pmZephyrTableMap_Material.put(Pm.Sleeve_Material__c + '_' + Pm.Sleeve_Material_Mix__c + '_' + Pm.Product_Segment__c + '_' + Pm.Location__c, Pm.Material_zephyr__c);
        }

        //Retrieve Printing Pm to Zephyr
        Map<String, String> pmZephyrTableMap_Printing = new map<String, String>();
        For (PM_To_Zephyr__c Pm : [select id,Location__c,Table_Name__c,Product_Segment__c,Printing_Zephyr__c,Printing_techno__c,Hot_Stamp__c,Sikscreen__c from PM_To_Zephyr__c where Table_Name__c = 'Printing type']) {

            if (Pm.Location__c == 'EU') {

                pmZephyrTableMap_Printing.put(Pm.Printing_techno__c + '_' + Pm.Hot_Stamp__c + '_' + Pm.Product_Segment__c + '_' + Pm.Location__c, Pm.Printing_Zephyr__c);
            }
            if (Pm.Location__c == 'US') {

                pmZephyrTableMap_Printing.put(Pm.Printing_techno__c + '_' + Pm.Sikscreen__c + '_' + Pm.Product_Segment__c + '_' + Pm.Location__c, Pm.Printing_Zephyr__c);
            }
        }

        For (QuoteLineItem qli : quoteLineItems) {

            //Retrieve Cfg
            PM_Selected_Tubes_Config__c tcfg = qliIDtoselectTubeCFGMap.get(qli.id);

            String ProductSegment = '';
            if (tcfg.Product_segment__c == 'Plastic Tubes' && tcfg.Is_Purefoil__c == 'TRUE') {
                ProductSegment = 'Purefoil Tubes';
            } else {
                ProductSegment = tcfg.Product_segment__c;
            }

            //Sleeve Material Mapping
            String SleeveMaterial;
            if (tcfg.Location__c == 'US') {

                SleeveMaterial = tcfg.Sleeve_type__c;

            } else if (tcfg.Location__c == 'EU') {

                SleeveMaterial = tcfg.Sleeve_Material__c;
            }

            //Printing Type Mapping
            String PrintingType;

            if (tcfg.Location__c == 'EU') {
                if (pmZephyrTableMap_Diameter.containsKey(String.valueOf(tcfg.Diameter_mm__c) + '.0')) {
                    qli.Diameter__c = String.valueOf(pmZephyrTableMap_Diameter.get(String.valueOf(tcfg.Diameter_mm__c) + '.0'));
                }
            }

            if (tcfg.Location__c == 'US') {
                if (pmZephyrTableMap_DiameterInch.containsKey(tcfg.Diameter_inches__c)) {
                    qli.Diameter__c = String.valueOf(pmZephyrTableMap_DiameterInch.get(tcfg.Diameter_inches__c));
                }
            }


            if (pmZephyrTableMap_Cap.containsKey(tcfg.Cap_Eurocode__c + '_' + tcfg.Location__c)) {

                qli.Cap__c = pmZephyrTableMap_Cap.get(tcfg.Cap_Eurocode__c + '_' + tcfg.Location__c);
            }

            if (pmZephyrTableMap_Material.containsKey(SleeveMaterial + '_' + tcfg.Sleeve_Material_Mix__c + '_' + ProductSegment + '_' + tcfg.Location__c)) {

                qli.Material__c = pmZephyrTableMap_Material.get(SleeveMaterial + '_' + tcfg.Sleeve_Material_Mix__c + '_' + ProductSegment + '_' + tcfg.Location__c);
            }

            //  EU
            if (tcfg.Location__c == 'EU') {
                if (pmZephyrTableMap_Printing.containsKey(tcfg.Printing_technologies__c + '_' + tcfg.Deco_Hot_Stamping__c + '_' + ProductSegment + '_' + tcfg.Location__c)) {

                    qli.Printing_type__c = pmZephyrTableMap_Printing.get(tcfg.Printing_technologies__c + '_' + tcfg.Deco_Hot_Stamping__c + '_' + ProductSegment + '_' + tcfg.Location__c);
                }
            }
            //  US
            if (tcfg.Location__c == 'US') {
                if (pmZephyrTableMap_Printing.containsKey(tcfg.Printing_type__c + '_' + tcfg.Silkscreen__c + '_' + ProductSegment + '_' + tcfg.Location__c)) {

                    qli.Printing_type__c = pmZephyrTableMap_Printing.get(tcfg.Printing_type__c + '_' + tcfg.Silkscreen__c + '_' + ProductSegment + '_' + tcfg.Location__c);
                }
            }

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
                    ((tcfg.Hot_Stamp_Top__c == 'YES') ? 'Top HS' + ' / ' : '')
                            + ((tcfg.HS_Contouring__c == 'YES') ? '360° HS' + ' / ' : '')
                            + ((tcfg.Silk_screen__c == 'YES') ? 'Silk Screen' + ' / ' : '')
                            + ((tcfg.Metallization__c == 'YES') ? 'Metallization' + ' / ' : '');

            // M45 --> Shrink Band
            // M46 --> Translate 'Sleeve' si Shrink Band (M45) == YES
            // M47 --> Manual Capping
            // M48 --> Translate 'Manual Capping' si Manual Capping (M47) == YES
            //(M49)qli.Other__c =SI(M46="";"";M46&" / ")&SI(M48="";"";M48)
            qli.Other__c = ((tcfg.Shrink_band__c == 'YES') ? 'Sleeve' + ' / ' : '')
                    + ((tcfg.Manual_Capping__c == 'YES') ? 'Manual Capping' + ' / ' : '');

            qli.Dispensing_family__c = tcfg.Dispensing_system_family__c;
            qli.Reference_head__c = tcfg.Head_Name__c;
            qli.Head_Color__c = tcfg.Head_Color__c;
            qli.Peel_Seal__c = tcfg.Peel_Seal__c;

            if (tcfg.Product_segment__c == 'Laminate Tubes') {
                qli.Rondelle_Insert__c =
                        ((tcfg.insert__c == null || tcfg.insert__c == '' || tcfg.insert__c == 'No') ? '' : 'Insert')
                                + ((tcfg.rondelle__c == null || tcfg.rondelle__c == '' || tcfg.rondelle__c == 'No') ? ' ' : 'Rondelle') ;
                //=SI(OU('PRODUCT - Laminate Tube'!$O$40="";'PRODUCT - Laminate Tube'!$O$40="No");"";"Insert")&SI(OU('PRODUCT - Laminate Tube'!$O$43="";'PRODUCT - Laminate Tube'!$O$43="No");"";"Rondelle")
            }

            qli.Pack_type__c = 'Standard' ; //tcfg.Pack_type__c;
            qli.PE_bag__c = (tcfg.PE_bag__c == null || tcfg.PE_bag__c == '') ? 'No' : tcfg.PE_bag__c ;
            qli.Polysheet__c = (tcfg.Polysheet__c == null || tcfg.Polysheet__c == '') ? 'No' : tcfg.Polysheet__c ;
            qli.Platt_Level__c = tcfg.Nouveau_Platts__c;

            String defaultValueForIncoterm = 'EXW';

            //commented by maryem qada  qli.Incoterms__c = tcfg.Delivery__c + ((tcfg.Destination__c != null)? ': '+tcfg.Destination__c : '' ); //tcfg.Incoterm__c to remove
            if (tcfg.Location__c == 'EU') {
                //qli.Incoterms__c =tcfg.Delivery__c ==null ||tcfg.Delivery__c=='Ex-Works' ?'Ex-Works':'Delivered';//added by maryem qada
                qli.Incoterm__c = tcfg.Delivery__c == null || tcfg.Delivery__c == 'Ex-Works' ? 'EXW' : 'DAP';//added by maryem qada
                system.debug('@@qama qli.Incoterms__c ' + qli.Incoterms__c);
            } else if (tcfg.Location__c == 'US') {
                //qli.Incoterms__c =tcfg.Incoterm__c ==null||tcfg.Incoterm__c=='Ex-Works' ? 'Ex-Works':'Delivered';//added by maryem qada
                qli.Incoterm__c = tcfg.Incoterm__c == null || tcfg.Incoterm__c == 'Ex-Works' ? 'EXW' : 'DAP';//added by maryem qada
                //added by qama
                qli.Incoterm__c = tcfg.Incoterm__c == null ? defaultValueForIncoterm : tcfg.Incoterm__c;

                system.debug('@@qama qli.Incoterms__c ' + qli.Incoterms__c);
            }

            //TODO: not found 
            //qli.Incoterms_Days__c = tcfg.Incoterms_Days__c; 

            qli.Payment_terms__c = tcfg.Payment_terms__c;

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
            PM_Selected_Service_Tubes_Config__c sstcfg = PM_CopySelectedConfigToQuoteItem.getSelectedServiceTubesConfig(tcfg);
            if (sstcfg != null) {
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
            qli.KPI_SKP_Config_OK__c = tcfg.Valid_config__c;//added by maryem to get the SKP KPI
            qli.Specific_length_mm__c = tcfg.Specific_length_mm__c; //added by maryem to get specific length 
            qli.Silkscreen__c = tcfg.Product_segment__c == 'Plastic Tubes' ? tcfg.Silk_screen__c : tcfg.Silkscreen__c; //added by maryem to get silkcreen yes/no
            qli.Metalic_Flexo__c = tcfg.Metalic_Flexo__c ; ////added by maryem to get metalic flexo
            qli.Cold_Hot_Foil__c = tcfg.Cold_Hot_Foil__c;//added by maryem
            qli.Destination__c = tcfg.Destination__c;//added by maryem

            //Map COMBO fields 
            //Number of ref. per run: + Number of tubes per artwork in Ku: //US            
            //Enter the number of tubes per artwork: +  Enter the plate changes: + Enter the number of versions: // EU  

            qli.Minimum_per_artwork_nb_tubes__c = qli.location__c == 'EU' ? string.valueof(tcfg.Combo_Num_Tubes_Artwork__c) : string.valueof(tcfg.Number_of_tubes_per_artwork_in_Ku__c);
            qli.Max_nb_of_ref_per_run__c = qli.location__c == 'EU' ? string.valueof(tcfg.Combo_Num_Versions__c) : string.valueof(tcfg.Number_of_ref_per_run__c);
            qli.Avg_nb_of_plate_print_color_changes_max__c = qli.location__c == 'EU' ? string.valueof(tcfg.Combo_Num_Plate_Changes__c) : null ;

        }

        try {
            update quoteLineItems;
        } catch (DmlException e) {
            System.debug(LoggingLevel.INFO, e);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e);
        }
    }

}