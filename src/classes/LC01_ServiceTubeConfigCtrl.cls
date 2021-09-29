public with sharing class LC01_ServiceTubeConfigCtrl {

    
    public static void calculateservicedetail(List<PM_Selected_Service_Tubes_Config__c> newselservicetube, List<PM_Selected_Service_Tubes_Config__c> oldselservicetube){

        
        for(integer i = 0; i < newselservicetube.size() ; i++){
            system.debug('***************newselservicetube[i].Tube_Segment__c********************' + newselservicetube[i].Tube_Segment__c);
            PM_Selected_Tubes_Config__c seltube = new PM_Selected_Tubes_Config__c();            
            seltube = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(seltube, new Map<String,String>{'Id' => newselservicetube[i].PM_Selected_Tubes_Config__c});
            
            decimal currencyeuro = (seltube.Billing_Currency_Rate__c == null || seltube.Billing_Currency_Rate__c == 0 )?1:seltube.Billing_Currency_Rate__c;
            
        
            //BAG
            //if(newselservicetube[i].BAG__c != oldselservicetube[i].BAG__c){
                newselservicetube[i].BAG_Detail__c = 0;
                if(newselservicetube[i].BAG__c == 'Yes'){
                   List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'BAG', 'Service_type__c' => 'Artwork', 'BAG__c' => 'B.A.G./Bromide (2 copies)'});
                   system.debug('*****BAG__c price values ********' + values );
                   newselservicetube[i].BAG_Detail__c = (values.size() > 0)?convStrToNum(values[0]) * currencyeuro:0;
                   newselservicetube[i].BAG_Detail__c = newselservicetube[i].BAG_Detail__c.setScale(2);
                }
            //}
            //Plates
            //if(newselservicetube[i].Plates__c != oldselservicetube[i].Plates__c){
            
                newselservicetube[i].Plates_Detail__c = 0;
                if((newselservicetube[i].Tube_Segment__c == 'Plastic Tubes' || newselservicetube[i].Tube_Segment__c == 'Purefoil Tubes') && newselservicetube[i].Plates__c == 'Yes'){
                                        
                        Decimal flexo = (newselservicetube[i].Tube_Segment__c == 'Purefoil Tubes')?0:seltube.NB_Flexo_Colors__c;     
                        
                        newselservicetube[i].Plates_Detail__c += (seltube.NB_Offset_Colors__c == null)?0:seltube.NB_Offset_Colors__c;
                        newselservicetube[i].Plates_Detail__c += (flexo == null)?0:seltube.NB_Flexo_Colors__c;
                        newselservicetube[i].Plates_Detail__c += (seltube.NB_SS_Colors__c == null)?0:seltube.NB_SS_Colors__c;
                        
                        List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                                                new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Offset_or_Flexo_or_Silkscreen', 'Service_type__c' => 'Artwork', 'Offset_or_Flexo_or_Silkscreen__c' => '1 colors'});
                        system.debug('*****plates price values ********' + values );
                        newselservicetube[i].Plates_Detail__c =(values.size() > 0)?convStrToNum(values[0]) * currencyeuro * newselservicetube[i].Plates_Detail__c:0;
                        newselservicetube[i].Plates_Detail__c = newselservicetube[i].Plates_Detail__c.setScale(2);
                }
            //}
            //BAT Printing proof            
            //if(newselservicetube[i].BAT_Printing_proof__c != oldselservicetube[i].BAT_Printing_proof__c){
                newselservicetube[i].BAT_Printing_proof_Detail__c = 0;
                if((newselservicetube[i].Tube_Segment__c == 'Plastic Tubes' || newselservicetube[i].Tube_Segment__c == 'Purefoil Tubes') && newselservicetube[i].BAT_Printing_proof__c == 'Yes'){
                
                        Decimal flexo = (newselservicetube[i].Tube_Segment__c == 'Purefoil Tubes')?0:seltube.NB_Flexo_Colors__c;                     
                        
                        List<String> prices = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c,NB_Color__c', 
                                                new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'B.A.T / Decoration Printing', 'Service_type__c' => 'Artwork', 'Printing_type__c' => 'Offset ou EDS (LAB PPP)'});
                        system.debug('***BAT_Printing_proof__c****prices values ********' + prices);
                        
                        
                        Decimal price = get_Artwork_Prices(flexo, seltube.NB_Offset_Colors__c, seltube.NB_SS_Colors__c, prices);
                        
                        newselservicetube[i].BAT_Printing_proof_Detail__c = price * currencyeuro;
                        newselservicetube[i].BAT_Printing_proof_Detail__c = newselservicetube[i].BAT_Printing_proof_Detail__c.setScale(2);
                }
            //}
            //Plate HS dye          
            //if(newselservicetube[i].Plate_HS_dye__c != oldselservicetube[i].Plate_HS_dye__c){
                newselservicetube[i].Plate_HS_dye_Detail__c = 0;
                if((newselservicetube[i].Tube_Segment__c == 'Plastic Tubes' || newselservicetube[i].Tube_Segment__c == 'Purefoil Tubes') && newselservicetube[i].Plate_HS_dye__c != 'No'&& newselservicetube[i].Plate_HS_dye__c != '' && newselservicetube[i].Plate_HS_dye__c != null){
                    string hotstamping = '';
                    if(seltube.Deco_Hot_Stamping__c=='120°' || newselservicetube[i].Plate_HS_dye__c  == 'Texte 1 face'){
                        hotstamping = 'HS one Dye Texte 1 face';
                    }
                    else if(seltube.Deco_Hot_Stamping__c=='360°' ||newselservicetube[i].Plate_HS_dye__c  == 'Texte 2 faces'){
                        hotstamping = 'HS one Dye Texte 2 faces';
                    }
                    else{
                        hotstamping = 'HS one Dye Logo 20% 1 face';
                    }                   
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Hot Stamping', 'Service_type__c' => 'Artwork', 'Hot_Stamping__c' => hotstamping});
                    system.debug('*****Plate HS dye  price values ********' + values );
                    
                    newselservicetube[i].Plate_HS_dye_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0;  
                        newselservicetube[i].Plate_HS_dye_Detail__c = newselservicetube[i].Plate_HS_dye_Detail__c.setScale(2);               
                }               
            //}
            
            //BAT_Color_Matching_Sleeve__c
            //if(newselservicetube[i].BAT_Color_Matching_Sleeve__c != oldselservicetube[i].BAT_Color_Matching_Sleeve__c){
                newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c = 0;                                 
                if(newselservicetube[i].BAT_Color_Matching_Sleeve__c == 'Yes'){
                    string sleevmaterial = '';
                    if(seltube.Sleeve_Material__c == 'Mono'){
                        sleevmaterial = 'Sleeve, monolayer';
                    }
                    else{
                        sleevmaterial = 'Sleeve, Coex';
                    }
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'B.A.T / Tube Color matching', 'Service_type__c' => 'Artwork', 'Part_of_the_tube__c' => 'Sleeve', 'Type_of_the_part__c' => sleevmaterial});
                    system.debug('*****BAT_Color_Matching_Sleeve__c  price values ********' + values );
                    
                    newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c = newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c.setScale(2);  
                    
                }                                
            //}
            //BAT_Color_Matching_Cap__c             
            //if(newselservicetube[i].BAT_Color_Matching_Cap__c != oldselservicetube[i].BAT_Color_Matching_Cap__c){
                newselservicetube[i].BAT_Color_Matching_Cap_Detail__c = 0;              
                
                if(newselservicetube[i].BAT_Color_Matching_Cap__c != 'No' && newselservicetube[i].BAT_Color_Matching_Cap__c != '' && newselservicetube[i].BAT_Color_Matching_Cap__c != null){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'B.A.T / Tube Color matching', 'Service_type__c' => 'Artwork', 'Part_of_the_tube__c' => 'Cap', 'Type_of_the_part__c' => newselservicetube[i].BAT_Color_Matching_Cap__c});
                    system.debug('*****BAT_Color_Matching_Cap__c  price values ********' + values );
                    
                    newselservicetube[i].BAT_Color_Matching_Cap_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].BAT_Color_Matching_Cap_Detail__c = newselservicetube[i].BAT_Color_Matching_Cap_Detail__c.setScale(2);
                                        
                }               
            //}
            //BAT_Color_Matching_Pumps__c
            //if(newselservicetube[i].BAT_Color_Matching_Pumps__c != oldselservicetube[i].BAT_Color_Matching_Pumps__c){
                newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c = 0;              
                                
                if(newselservicetube[i].BAT_Color_Matching_Pumps__c == 'Yes'){                  
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'B.A.T / Tube Color matching', 'Service_type__c' => 'Artwork', 'Part_of_the_tube__c' => 'Pumps', 'Type_of_the_part__c' => 'Color matching on pump (indus. Mold)'});
                    system.debug('*****BAT_Color_Matching_Pumps__c  price values ********' + values );
                    
                    newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c = newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c.setScale(2);
                }                                               
            //}           
            //BAT_Flat_printing_proof__c
            //if(newselservicetube[i].BAT_Flat_printing_proof__c != oldselservicetube[i].BAT_Flat_printing_proof__c){
                newselservicetube[i].BAT_Flat_printing_proof_Detail__c = 0;              
                                
                if(newselservicetube[i].BAT_Flat_printing_proof__c == 'Yes'){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Other artwork option', 'Service_type__c' => 'Artwork', 'Options__c' => 'Flat Printing Proof'});
                    system.debug('*****BAT_Flat_printing_proof__c  price values ********' + values );
                    
                    newselservicetube[i].BAT_Flat_printing_proof_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0;
                        newselservicetube[i].BAT_Flat_printing_proof_Detail__c = newselservicetube[i].BAT_Flat_printing_proof_Detail__c.setScale(2); 
                }                                               
            //}           
            //Toner_formulation_w_o_BAT__c            
            //if(newselservicetube[i].Toner_formulation_w_o_BAT__c != oldselservicetube[i].Toner_formulation_w_o_BAT__c){
                newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c = 0;              
                if(newselservicetube[i].Toner_formulation_w_o_BAT__c == 'Yes'){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Other artwork option', 'Service_type__c' => 'Artwork', 'Options__c' => 'Toner formulation without B.A.T'});
                    system.debug('*****Toner_formulation_w_o_BAT__c  price values ********' + values );
                    
                    newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c = newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c.setScale(2);
                }                                               
            //}
            //B_A_T_HS_dye__c                     
            //if(newselservicetube[i].B_A_T_HS_dye__c != oldselservicetube[i].B_A_T_HS_dye__c){
                newselservicetube[i].B_A_T_HS_dye_Detail__c = 0;              
                if(newselservicetube[i].B_A_T_HS_dye__c == 'Yes'){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Other artwork option', 'Service_type__c' => 'Artwork', 'Options__c' => 'B.A.T HS dye'});
                    system.debug('*****B_A_T_HS_dye__c  price values ********' + values );
                    
                    newselservicetube[i].B_A_T_HS_dye_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].B_A_T_HS_dye_Detail__c = newselservicetube[i].B_A_T_HS_dye_Detail__c.setScale(2);
                }                                               
            //}
            //BAG_modification__c                  
            //if(newselservicetube[i].BAG_modification__c != oldselservicetube[i].BAG_modification__c){
                newselservicetube[i].BAG_modification_Detail__c = 0;              
                if(newselservicetube[i].BAG_modification__c == 'Yes'){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'BAG', 'Service_type__c' => 'Artwork', 'BAG__c' => 'Modification B.A.G. (by submission of  New Target)'});
                    system.debug('*****BAG_modification__c  price values ********' + values );
                    
                    newselservicetube[i].BAG_modification_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].BAG_modification_Detail__c = newselservicetube[i].BAG_modification_Detail__c.setScale(2);
                }                                               
            //}

        

              //BAT_for_metallized_cap__c            
            //if(newselservicetube[i].BAT_for_metallized_cap__c != oldselservicetube[i].BAT_for_metallized_cap__c){
                newselservicetube[i].BAT_for_metallized_cap_Detail__c = 0;              
                
                if(newselservicetube[i].BAT_for_metallized_cap__c != '' && newselservicetube[i].BAT_for_metallized_cap__c != null){
                    
                    List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Price__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'BAT for metallized cap Price', 'Service_type__c' => 'Artwork', 'BAT_for_metallized_cap__c' => newselservicetube[i].BAT_for_metallized_cap__c});
                   
                    newselservicetube[i].BAT_for_metallized_cap_Detail__c = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                        newselservicetube[i].BAT_for_metallized_cap_Detail__c = newselservicetube[i].BAT_for_metallized_cap_Detail__c.setScale(2);
                                        
                }               
            //}   
            
            
            newselservicetube[i].Total_price_for_Artwork__c = 0;
            if (newselservicetube[i].BAT_for_metallized_cap_Detail__c == -1){
                newselservicetube[i].Total_price_for_Artwork__c = -1;
            }else{
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].B_A_T_HS_dye_Detail__c == null)?0:newselservicetube[i].B_A_T_HS_dye_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAG_Detail__c == null)?0:newselservicetube[i].BAG_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAG_modification_Detail__c == null)?0:newselservicetube[i].BAG_modification_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_Color_Matching_Cap_Detail__c == null)?0:newselservicetube[i].BAT_Color_Matching_Cap_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c == null)?0:newselservicetube[i].BAT_Color_Matching_Pumps_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c == null)?0:newselservicetube[i].BAT_Color_Matching_Sleeve_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_Flat_printing_proof_Detail__c == null)?0:newselservicetube[i].BAT_Flat_printing_proof_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_Printing_proof_Detail__c == null)?0:newselservicetube[i].BAT_Printing_proof_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].Plate_HS_dye_Detail__c == null)?0:newselservicetube[i].Plate_HS_dye_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].Plates_Detail__c == null)?0:newselservicetube[i].Plates_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c == null)?0:newselservicetube[i].Toner_formulation_w_o_BAT_Detail__c;
                newselservicetube[i].Total_price_for_Artwork__c += (newselservicetube[i].BAT_for_metallized_cap_Detail__c == null)?0:newselservicetube[i].BAT_for_metallized_cap_Detail__c;
            }
            
            newselservicetube[i].Total_price_for_Artwork__c = newselservicetube[i].Total_price_for_Artwork__c.setScale(2);
            
            
            newselservicetube[i].Amount_per_item__c = '';
            if(newselservicetube[i].Type_of_tube__c == null || newselservicetube[i].Type_of_file__c == null || newselservicetube[i].Number_of_items__c == null){
                newselservicetube[i].Amount_per_item__c = '';
            }
            else if(newselservicetube[i].Number_of_items__c > 1){
                newselservicetube[i].Amount_per_item__c = 'Please contact Veronique.W';
            }
            else if(newselservicetube[i].Number_of_items__c == null){
                newselservicetube[i].Amount_per_item__c = 'NA';
            }
            else if(newselservicetube[i].Type_of_tube__c == '' || newselservicetube[i].Type_of_tube__c == null){
                newselservicetube[i].Amount_per_item__c = '0';
            }
            else if(newselservicetube[i].Type_of_tube__c == 'Standard tube'){
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Standard_Tubes__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Gouping + Comments by type of file', 'Service_type__c' => 'Preproduction', 'Type_of_file__c' => newselservicetube[i].Type_of_file__c});
                    system.debug('*****Amount_per_item__c  price values ********' + values );
                    
                Decimal tempqmount = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                tempqmount = (newselservicetube[i].Market_Of_Application__c == 'Food & Beverage')?0:tempqmount;
                //newselservicetube[i].Amount_per_item__c = String.ValueOf(tempqmount.setScale(2));
                newselservicetube[i].Amount_per_item__c = String.ValueOf(tempqmount.setScale(0));
            }
            else{
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Tubes_PumpApplicators__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Gouping + Comments by type of file', 'Service_type__c' => 'Preproduction', 'Type_of_file__c' => newselservicetube[i].Type_of_file__c});
                    system.debug('*****Amount_per_item__c  price values ********' + values );
                    
                Decimal tempqmount = (values.size() > 0)?convStrToNum(values[0])*currencyeuro:0; 
                tempqmount = (newselservicetube[i].Market_Of_Application__c == 'Food & Beverage')?0:tempqmount;
               // newselservicetube[i].Amount_per_item__c = String.ValueOf(tempqmount.setScale(2)); //commented by maryem qada 16/03/2018 because 1.0 is not considered as numeric
                newselservicetube[i].Amount_per_item__c = String.ValueOf(tempqmount.setScale(0)); 
            }
            
            newselservicetube[i].Number_of_files__c = '';
            if(newselservicetube[i].Type_of_tube__c == '' || newselservicetube[i].Number_of_items__c == null){              
                newselservicetube[i].Number_of_files__c = '-';              
            }
            else if((newselservicetube[i].Type_of_tube__c == 'Standard tube' || newselservicetube[i].Type_of_tube__c == 'Tube + pump' || newselservicetube[i].Type_of_tube__c == 'Tube + Applicator') && newselservicetube[i].Number_of_items__c > 1){              
                newselservicetube[i].Number_of_files__c = 'To be defined';
            }
            else{
                newselservicetube[i].Number_of_files__c = '1';
            }
           
                
            newselservicetube[i].Total_amount__c = '';
            if(newselservicetube[i].Amount_per_item__c == '' || newselservicetube[i].Amount_per_item__c == null || newselservicetube[i].Number_of_files__c == ''|| newselservicetube[i].Number_of_files__c == null){
                newselservicetube[i].Total_amount__c = '0';
            }
            else if(newselservicetube[i].Amount_per_item__c.isNumeric() && newselservicetube[i].Number_of_files__c.isNumeric()){
                newselservicetube[i].Total_amount__c = String.ValueOf(convStrToNum(newselservicetube[i].Amount_per_item__c) * convStrToNum(newselservicetube[i].Number_of_files__c));
            }
            else{
                newselservicetube[i].Total_amount__c = 'To be defined';             
            }
            
            string fldQtyNeededSamples = (newselservicetube[i].Quantity_needed_for_samples__c == '' || newselservicetube[i].Quantity_needed_for_samples__c == null)?'Max_0_tubes__c'
                                        :(newselservicetube[i].Quantity_needed_for_samples__c.replace(' ', '_') + '__c');

            system.debug('******************fldQtyNeededSamples*************************' + fldQtyNeededSamples);   
            /**************************************************************************Samples_Head__c**********************************************************************************************************/
            string esu_head = '';
            if(seltube.Diameter_mm__c == null && (seltube.Head_Name__c == '' || seltube.Head_Name__c == null)){
                esu_head = '';
            }
            else if(
                LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Concatenate__c', 
                    new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'European Sampling Unit - Practical Guide', 'Service_type__c' => 'Samples', 'Concatenate__c' => seltube.Diameter_mm__c + '_' + seltube.Head_Name__c}).size() == 0
                ){
                esu_head = 'NA';
            }
            else if(                
                LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Group_1__c', 
                    new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'group 1', 'Service_type__c' => 'Samples', 'Group_1__c' => seltube.Diameter_mm__c + '_' + seltube.Head_Name__c}).size() == 0
                ){
                esu_head = 'E-01';
            }
            else{                   
                esu_head = 'E-02';
            }
            
            
            //Samples_Head__c
            if(seltube.Diameter_mm__c == null){                  
                newselservicetube[i].Samples_Head__c = '';
            }
            else if(esu_head  == 'NA'){                             
                newselservicetube[i].Samples_Head__c = 'Not feasible in ESU';
            }
            else if(newselservicetube[i].Quantity_needed_for_samples__c != null && newselservicetube[i].Quantity_needed_for_samples__c != ''){
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_head});
                system.debug('*****Samples_Head__c***values**************' + values);
            
                newselservicetube[i].Samples_Head__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }
            
            /******************************************************************************Samples_Head__c******************************************************************************************************/
            
            
            
            /**************************************************************************Samples_Cap__c**********************************************************************************************************/
            string esu_Cap = '';            
            List<String> valuesCap = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Code_3__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Lists for Samples', 'Service_type__c' => 'Samples', 'Eurocode__c' => seltube.Cap_Eurocode__c});
            system.debug('*****esu_Cap********' + valuesCap );
            esu_Cap = (valuesCap.size() > 0)?valuesCap[0]:'';
            
            if(esu_Cap=='' || seltube.Cap_Eurocode__c=='' || esu_Cap==null || seltube.Cap_Eurocode__c==null){
                newselservicetube[i].Samples_Cap__c = '';
            }
            else if(esu_Cap=='NA'){             
                newselservicetube[i].Samples_Cap__c = 'Check with Pricing Manager';
            }
            else{
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_Cap});
                system.debug('*****Samples_Cap__c***values**************' + values);
            
                newselservicetube[i].Samples_Cap__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }
                
            /**************************************************************************Samples_Cap__c**********************************************************************************************************/
                
                
            /**************************************************************************Samples_Cap_decoration__c**********************************************************************************************************/
                        
            string capdecoration = (seltube.Metallization__c == 'Yes' || seltube.Silk_screen__c == 'Yes' || seltube.Hot_Stamp_Top__c == 'Yes')?'Yes':'No';
            newselservicetube[i].Samples_Cap_decoration__c = (seltube.Diameter_mm__c == null || capdecoration == 'No') ? '' : 'Check with Pricing Manager';
            
            /**************************************************************************Samples_Cap_decoration__c**********************************************************************************************************/
                
                
                
                
            string capdesc = '';
            List<String> valuescapdesc = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Cap_Name_full_path__c', 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'Cap Description',
                                               'Service_type__c' => 'Samples',
                                               'Concatenate__c' => seltube.Diameter_mm__c + '' + seltube.Cap_Eurocode__c});
            system.debug('*****capdesc********' + valuescapdesc );
            capdesc = (valuescapdesc.size() > 0)?valuescapdesc[0]:'';
            
            

            
            /**************************************************************************Samples_Cap_color__c**********************************************************************************************************/
            string esu_CapColor = '';   
            if((capdesc == '' || capdesc == null) && (seltube.Service_Sleeve_Length_mm__c == '' || seltube.Service_Sleeve_Length_mm__c == null)){                
                esu_CapColor = '';  
            }
            else if(seltube.Cap_Color__c != 'WHITE / NATURAL' || capdesc == 'Active Cap'){          
                esu_CapColor = 'E-14';
            }
            else{           
                esu_CapColor = '';                  
            }
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Cap_color__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_CapColor});
                system.debug('*****Samples_Cap_color__c***values**************' + values);
            
                newselservicetube[i].Samples_Cap_color__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';              
            }           
            /**************************************************************************Samples_Cap_color__c**********************************************************************************************************/
                        
                        
                       
            /**************************************************************************Samples_Sleeve_length__c**********************************************************************************************************/
            system.debug('*****seltube.Service_Sleeve_Length_mm__c**************' + seltube.Service_Sleeve_Length_mm__c);
            string esu_SleeveLength = '';
            Decimal sleevelengthnum = (seltube.Service_Sleeve_Length_mm__c.isNumeric())?convStrToNum(seltube.Service_Sleeve_Length_mm__c):0;
            
            List<String> valuesslength = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Length_Mini__c,Length_Maxi__c', 
                                  new Map<String,String>{'Location__c' => 'EU', 
                                                         'Table_Name__c' => 'European Sampling Unit - Practical Guide', 
                                                         'Service_type__c' => 'Samples', 
                                                         'Concatenate__c' => seltube.Diameter_mm__c + '_' + seltube.Head_Name__c});
            if( valuesslength.size() == 0 || seltube.Service_Sleeve_Length_mm__c == '' || seltube.Service_Sleeve_Length_mm__c == null){
                esu_SleeveLength = 'OK';
            }
            else{
                Decimal mini = 0;
                Decimal maxi = 0;
                if(valuesslength.size() > 0){
                    mini = convStrToNum(valuesslength[0].split(';')[0]);
                    maxi = convStrToNum(valuesslength[0].split(';')[1]);
                }
                
                if(sleevelengthnum < mini){
                    esu_SleeveLength = 'NA';
                }
                else if(sleevelengthnum > maxi){
                    esu_SleeveLength = 'NA';
                }
                else{
                    esu_SleeveLength = 'OK';
                }               
            }            
                        
            newselservicetube[i].Samples_Sleeve_length__c = (esu_SleeveLength == 'OK')?'':'Not feasible in ESU';
            /**************************************************************************Samples_Sleeve_length__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Samples_Sleeve_type__c**********************************************************************************************************/
            string esu_SleeveType = (seltube.Sleeve_Material__c != 'Mono' && (seltube.Sleeve_Material__c != '' && seltube.Sleeve_Material__c != null))?'E-09':'';
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Sleeve_type__c = '';
            }
            else{
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_SleeveType});
                system.debug('*****Samples_Sleeve_type__c***values**************' + values);
            
                newselservicetube[i].Samples_Sleeve_type__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';                
            }   
            /**************************************************************************Samples_Sleeve_type__c**********************************************************************************************************/
            
            
            /******************************************************************************Samples_Sleeve_Material_Mix__c******************************************************************************************************/
            string esu_SleeveMatMix = (seltube.Sleeve_Material_Mix__c == 'NON STANDARD MIX')?'E-03':'';   

            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Sleeve_Material_Mix__c = '';
            }
            else{
                                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_SleeveMatMix});
                system.debug('*****Samples_Sleeve_Material_Mix__c***values**************' + values);
            
                newselservicetube[i].Samples_Sleeve_Material_Mix__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';                
            }               
            /**************************************************************************Samples_Sleeve_Material_Mix__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_Shape__c**********************************************************************************************************/
            string esu_Shape = (seltube.Shape__c != 'CYLINDRICAL' && (seltube.Shape__c != '' && seltube.Shape__c != null))?'E-11':'';   
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Shape__c = '';
            }
            else{
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_Shape});
                system.debug('*****Samples_Shape__c***values**************' + values);
            
                newselservicetube[i].Samples_Shape__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';              
            }       
            /**************************************************************************Samples_Shape__c**********************************************************************************************************/  
            
            
            /**************************************************************************Samples_Sleeve_color__c**********************************************************************************************************/
            string esu_SleeveColor = '';
            if(seltube.Sleeve_Color__c == '' || seltube.Sleeve_Color__c == null){
                esu_SleeveColor = '';
            }
            else if(seltube.Sleeve_Color__c != 'WHITE / NATURAL' && seltube.Sleeve_Material__c == 'MONO'){
                esu_SleeveColor = 'E-12';
            }
            else if(seltube.Sleeve_Color__c != 'WHITE / NATURAL' && seltube.Sleeve_Material__c != 'MONO'){
                esu_SleeveColor = 'E-13';
            }
            else{
                esu_SleeveColor = '';
            }
            
            
            system.debug('*********esu_SleeveColor***********' + esu_SleeveColor);
            
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Sleeve_color__c = '';
            }
            else{
                
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_SleeveColor});
                system.debug('*****Samples_Sleeve_color__c***values**************' + values);
            
                newselservicetube[i].Samples_Sleeve_color__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';               
            }       
            
            /**************************************************************************Samples_Sleeve_color__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_of_Flexo_colors__c**********************************************************************************************************/
                newselservicetube[i].Samples_of_Flexo_colors__c = (seltube.NB_Flexo_Colors__c != null && seltube.NB_Flexo_Colors__c != 0 )?'Not feasible in ESU':'';
            /**************************************************************************Samples_of_Flexo_colors__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_of_Offset_colors__c**********************************************************************************************************/
            string esu_offsetcolor = 'E-15';
            
            if(seltube.Diameter_mm__c == null || seltube.NB_Offset_Colors__c == null || seltube.NB_Offset_Colors__c == 0){
                newselservicetube[i].Samples_of_Offset_colors__c = '';
            }
            else if(seltube.NB_Offset_Colors__c > 6){               
                newselservicetube[i].Samples_of_Offset_colors__c = 'Not feasible in ESU';
            }
            else if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_of_Offset_colors__c = '';              
            }
            else{               
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_offsetcolor});
                system.debug('*****Samples_of_Offset_colors__c***values**************' + values);
            
                newselservicetube[i].Samples_of_Offset_colors__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';     
                system.debug('*****newselservicetube[i].Samples_of_Offset_colors__c**************' + newselservicetube[i].Samples_of_Offset_colors__c);              
            }           
            /**************************************************************************Samples_of_Offset_colors__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_of_SS_colors__c**********************************************************************************************************/
            string esu_sscolor = 'E-17';
            if(seltube.Diameter_mm__c == null || seltube.NB_SS_Colors__c == null || seltube.NB_SS_Colors__c == 0){
                newselservicetube[i].Samples_of_SS_colors__c = '';
            }
            else if(seltube.NB_SS_Colors__c > 1){
                newselservicetube[i].Samples_of_SS_colors__c = 'Not feasible in ESU';
            }
            else if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_of_SS_colors__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_sscolor});
                system.debug('*****Samples_of_SS_colors__c***values**************' + values);
                if(values.size() > 0){                  
            
                    newselservicetube[i].Samples_of_SS_colors__c = (values[0].isNumeric())?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):values[0];        
                }
            }
            /**************************************************************************Samples_of_SS_colors__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_Hot_stamp__c**********************************************************************************************************/
            string esu_HotStamp = 'E-16';
                
            if(seltube.Diameter_mm__c == null || seltube.Deco_Hot_Stamping__c == '' || seltube.Deco_Hot_Stamping__c == 'No' || seltube.Deco_Hot_Stamping__c == null){
                newselservicetube[i].Samples_Hot_stamp__c = '';
            }
            else{
                 List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_HotStamp});
                system.debug('*****Samples_Hot_stamp__c***values**************' + values);
            
                newselservicetube[i].Samples_Hot_stamp__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }           
            /**************************************************************************Samples_Hot_stamp__c**********************************************************************************************************/
            
            
            /**************************************************************************Samples_Peel_Seal__c**********************************************************************************************************/
            string esu_PeelSeal = (seltube.Peel_Seal__c == null || seltube.Peel_Seal__c == '' || seltube.Peel_Seal__c == 'No')?'':'E-10';
                
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Samples_Peel_Seal__c = '';
            }
            else{
                system.debug('****************fldQtyNeededSamples****************' + fldQtyNeededSamples);
                system.debug('****************esu_PeelSeal****************' + esu_PeelSeal);
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Samples',
                                               'Tarif_Guide_code__c' => esu_PeelSeal});
                system.debug('*****Samples_Peel_Seal__c***values**************' + values);
            
                newselservicetube[i].Samples_Peel_Seal__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }
            
            /**************************************************************************Samples_Peel_Seal__c**********************************************************************************************************/
            
            newselservicetube[i].Total_price_for_Samples__c = 0;            
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Head__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Cap__c);   
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Cap_decoration__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Cap_color__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Sleeve_length__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Sleeve_type__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Sleeve_Material_Mix__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Shape__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Sleeve_color__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_of_Flexo_colors__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_of_Offset_colors__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_of_SS_colors__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Hot_stamp__c);
            newselservicetube[i].Total_price_for_Samples__c += convStrToNum(newselservicetube[i].Samples_Peel_Seal__c);
            newselservicetube[i].Total_price_for_Samples__c = newselservicetube[i].Total_price_for_Samples__c.setScale(2);
            
            
            string fldQtyNeededPreprod = (newselservicetube[i].Quantity_needed_for_Preproduction__c == '' || newselservicetube[i].Quantity_needed_for_Preproduction__c == null)?'Max_0_tubes__c'
                                        :('X' + newselservicetube[i].Quantity_needed_for_Preproduction__c.replace(' ', '_') + '__c');
                                        
                                        
            /**************************************************************************Preproduction_Diameter__c**********************************************************************************************************/
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Diameter__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => 'P-01'});
                system.debug('*****Preproduction_Diameter__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Diameter__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';             
            }   
            
            /**************************************************************************Preproduction_Diameter__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Cap__c**********************************************************************************************************/
                    
            string pre_Cap = '';            
            List<String> valuespreCap = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Code__c', 
                        new Map<String,String>{'Location__c' => 'EU', 'Table_Name__c' => 'Lists for Samples', 'Service_type__c' => 'Samples', 'Eurocode__c' => seltube.Cap_Eurocode__c});
            system.debug('*****pre_Cap********' + valuespreCap );
            pre_Cap = (valuespreCap.size() > 0)?valuespreCap[0]:'';
            
            if(pre_Cap =='' || seltube.Cap_Eurocode__c=='' || pre_Cap ==null || seltube.Cap_Eurocode__c==null){
                newselservicetube[i].Preproduction_Cap__c = '';
            }
            else if(pre_Cap =='NA'){                
                newselservicetube[i].Preproduction_Cap__c = 'Check with Pricing Manager';
            }
            else{               
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_Cap});
                system.debug('*****Preproduction_Cap__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Cap__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }
                
            /**************************************************************************Preproduction_Cap__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Cap_decoration__c**********************************************************************************************************/
            newselservicetube[i].Preproduction_Cap_decoration__c = (seltube.Diameter_mm__c == null || capdecoration == 'No') ? '' : 'Check with Pricing Manager';         
            /**************************************************************************Preproduction_Cap_decoration__c**********************************************************************************************************/
            
            
            
            
            /**************************************************************************Preproduction_Cap_color__c**********************************************************************************************************/
            string pre_CapColor = '';   
            if((capdesc == '' || capdesc == null) && (seltube.Service_Sleeve_Length_mm__c == '' || seltube.Service_Sleeve_Length_mm__c == null)){                
                pre_CapColor = '';  
            }
            else if(seltube.Cap_Color__c != 'WHITE / NATURAL' || capdesc == 'Active Cap'){          
                pre_CapColor = 'P-18';
            }
            else{           
                pre_CapColor = '';                  
            }
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Cap_color__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_CapColor});
                system.debug('*****Preproduction_Cap_color__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Cap_color__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';                
            }           
            /**************************************************************************Preproduction_Cap_color__c**********************************************************************************************************/
            
            
            /**************************************************************************Preproduction_Sleeve_type__c**********************************************************************************************************/
            string pre_SleeveType = (seltube.Sleeve_Material__c != 'Mono')?'P-09':'';
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Sleeve_type__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_SleeveType});
                system.debug('*****Preproduction_Sleeve_type__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Sleeve_type__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';              
            }   
            /**************************************************************************Preproduction_Sleeve_type__c**********************************************************************************************************/
            
            
            
            
            /******************************************************************************Preproduction_Sleeve_Material_Mix__c******************************************************************************************************/
            string pre_SleeveMatMix = (seltube.Sleeve_Material_Mix__c == 'NON STANDARD MIX')?'P-02':'';   

            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Sleeve_Material_Mix__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_SleeveMatMix});
                system.debug('*****Preproduction_Sleeve_Material_Mix__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Sleeve_Material_Mix__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';              
            }               
            /**************************************************************************Preproduction_Sleeve_Material_Mix__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Shape__c**********************************************************************************************************/
            string pre_Shape = (seltube.Shape__c != 'CYLINDRICAL' && (seltube.Shape__c != '' && seltube.Shape__c != null))?'P-11':'';   
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Shape__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_Shape});
                system.debug('*****Preproduction_Shape__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Shape__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';                
            }       
            /**************************************************************************Preproduction_Shape__c**********************************************************************************************************/  
            
            
            
            
            /**************************************************************************Preproduction_Sleeve_color__c**********************************************************************************************************/
            string pre_SleeveColor = '';
            
            if(seltube.Sleeve_Color__c != 'WHITE / NATURAL' && seltube.Sleeve_Material__c == 'MONO'){
                pre_SleeveColor = 'P-15';
            }
            else if(seltube.Sleeve_Color__c != 'WHITE / NATURAL' && seltube.Sleeve_Material__c != 'MONO'){
                pre_SleeveColor = 'P-16';
            }
            else{
                pre_SleeveColor = '';
            }
            
            
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Sleeve_color__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_SleeveColor});
                system.debug('*****Preproduction_Sleeve_color__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Sleeve_color__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';             
            }       
            
            /**************************************************************************Preproduction_Sleeve_color__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Head_color__c**********************************************************************************************************/
            string pre_HeadColor = (seltube.Head_Color__c != '' && seltube.Head_Color__c != null && seltube.Head_Color__c != 'WHITE / NATURAL')?'P-17':'';
            
            List<String> valuesHead_color = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_HeadColor});
            system.debug('*****Preproduction_Head_color__c***values**************' + valuesHead_color);
            
            newselservicetube[i].Preproduction_Head_color__c = (valuesHead_color.size() > 0)?String.ValueOf((convStrToNum(valuesHead_color[0]) * currencyeuro).setScale(2)):'';               
            
            /**************************************************************************Preproduction_Head_color__c**********************************************************************************************************/
            
            
            /**************************************************************************Preproduction_of_Flexo_colors__c**********************************************************************************************************/
                
            if(seltube.Diameter_mm__c == null || seltube.NB_Flexo_Colors__c == null || seltube.NB_Flexo_Colors__c == 0){
                    newselservicetube[i].Preproduction_of_Flexo_colors__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => 'P-19'});
                system.debug('*****Preproduction_of_Flexo_colors__c***values**************' + values);
            
                newselservicetube[i].Preproduction_of_Flexo_colors__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * seltube.NB_Flexo_Colors__c * currencyeuro).setScale(2)):'';
            }
            /**************************************************************************Preproduction_of_Flexo_colors__c**********************************************************************************************************/
            
            
            /**************************************************************************Preproduction_of_Offset_colors__c**********************************************************************************************************/
            
            if(seltube.Diameter_mm__c == null || seltube.NB_Offset_Colors__c == null || seltube.NB_Offset_Colors__c == 0){
                newselservicetube[i].Preproduction_of_Offset_colors__c = '';
            }
            else{       
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => 'P-19'});
                system.debug('*****Preproduction_of_Offset_colors__c***values**************' + values);
            
                newselservicetube[i].Preproduction_of_Offset_colors__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * seltube.NB_Offset_Colors__c * currencyeuro).setScale(2)):'';                 
            }           
            /**************************************************************************Preproduction_of_Offset_colors__c**********************************************************************************************************/
            
            
            /**************************************************************************Preproduction_of_SS_colors__c**********************************************************************************************************/

            if(seltube.Diameter_mm__c == null || seltube.NB_SS_Colors__c == null || seltube.NB_SS_Colors__c == 0){
                newselservicetube[i].Preproduction_of_SS_colors__c = '';
            }
            else{   
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => 'P-21'});
                system.debug('*****Preproduction_of_SS_colors__c***values**************' + values);
            
                newselservicetube[i].Preproduction_of_SS_colors__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * seltube.NB_SS_Colors__c * currencyeuro).setScale(2)):''; 
            }
            
            /**************************************************************************Preproduction_of_SS_colors__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Hot_stamp__c**********************************************************************************************************/
    
            if(seltube.Diameter_mm__c == null || seltube.Deco_Hot_Stamping__c == '' || seltube.Deco_Hot_Stamping__c == null || seltube.Deco_Hot_Stamping__c == 'No'){
                newselservicetube[i].Preproduction_Hot_stamp__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededPreprod, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE PRE-SERIE - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => 'P-20'});
                system.debug('*****Preproduction_Hot_stamp__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Hot_stamp__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }           
            /**************************************************************************Preproduction_Hot_stamp__c**********************************************************************************************************/
            
            
            
            /**************************************************************************Preproduction_Peel_Seal__c**********************************************************************************************************/
            string pre_PeelSeal = (seltube.Peel_Seal__c == '' || seltube.Peel_Seal__c == null || seltube.Peel_Seal__c == 'No')?'':'P-10';
                
            if(seltube.Diameter_mm__c == null){
                newselservicetube[i].Preproduction_Peel_Seal__c = '';
            }
            else{
                List<String> values = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', fldQtyNeededSamples, 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'TARIF GUIDE ECHANTILLON ESU - 2015',
                                               'Service_type__c' => 'Preproduction',
                                               'Tarif_Guide_code__c' => pre_PeelSeal});
                system.debug('*****Preproduction_Peel_Seal__c***values**************' + values);
            
                newselservicetube[i].Preproduction_Peel_Seal__c = (values.size() > 0)?String.ValueOf((convStrToNum(values[0]) * currencyeuro).setScale(2)):'';
            }
            
            /**************************************************************************Preproduction_Peel_Seal__c**********************************************************************************************************/
            
            
            
            
            newselservicetube[i].Total_price_for_Preproduction__c = 0;
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Diameter__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Cap__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Cap_decoration__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Cap_color__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Sleeve_type__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Sleeve_Material_Mix__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Shape__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Sleeve_color__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Head_color__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_of_Flexo_colors__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_of_Offset_colors__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_of_SS_colors__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Hot_stamp__c);
            newselservicetube[i].Total_price_for_Preproduction__c += convStrToNum(newselservicetube[i].Preproduction_Peel_Seal__c);
            newselservicetube[i].Total_price_for_Preproduction__c = newselservicetube[i].Total_price_for_Preproduction__c.setScale(2);
            
            List<String> typefilemsgvalues = LC00_ServicePicklistCtrl.getValues('PM_Service_Tubes_Config__c', 'Comments__c', 
                        new Map<String,String>{'Location__c' => 'EU',
                                               'Table_Name__c' => 'Gouping + Comments by type of file',
                                               'Service_type__c' => 'Preproduction',
                                               'Type_of_file__c' => newselservicetube[i].Type_of_file__c});
            newselservicetube[i].Type_of_file_Message_Info__c = (typefilemsgvalues.size() > 0)?typefilemsgvalues[0]:'';
            
        }
    
    }
    
    
    public static Decimal convStrToNum(String s){
        try{
            s = (s == null)?'':s;
            return Decimal.valueOf(s);
        }
        catch(TypeException e){
           return 0;
        }
    }
    
    public static Decimal get_Artwork_Prices(Decimal flexo, Decimal offset, Decimal silkscreen, List<String> prices){
        
        flexo = (flexo == null)?0:flexo;
        offset = (offset == null)?0:offset;
        silkscreen = (silkscreen == null)?0:silkscreen;
        
        Decimal nbtotal = 0 ;
        nbtotal += flexo;
        nbtotal += offset;
        nbtotal += silkscreen;
        
        if(nbtotal == 0){
            return 0;           
        }
        else if((flexo == 0 && silkscreen == 0) || (flexo == 0 && offset == 0)){
            for(integer i = 0 ; i <=1 ; i++){               
                if(convStrToNum(prices[i].split(';')[1].substring(2, 3)) >= nbtotal ){
                    return convStrToNum(prices[i].split(';')[0]);                 
                }
            }
        }
        
        else if(flexo == 0 && offset == 0){
            for(integer i = 0 ; i <=1 ; i++){               
                if(convStrToNum(prices[i].split(';')[1].substring(2, 3)) >= nbtotal ){
                    return convStrToNum(prices[i].split(';')[0]);                 
                }
            }
        }
        else{
            
            for(integer i = 2 ; i < prices.size() ; i++){               
                if(convStrToNum(prices[i].split(';')[1].substring(2, 3)) >= nbtotal ){
                    return convStrToNum(prices[i].split(';')[0]);
                }
            }
        }

    
        return convStrToNum(prices[prices.size() - 1].split(';')[0]);
    }
    
    
    /*
    
    
    @AuraEnabled
    public static PM_Selected_Service_Tubes_Config__c getServiceTubeConfig(Id qliId, Id tubeid, QuoteLineItem qli){
        
        String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Service_Tubes_Config__c');
        
        if(sQuery != null){
            sQuery += ' WHERE Quote_item__c = :qliId and PM_Selected_Tubes_Config__c =:tubeid LIMIT 1';
            for(PM_Selected_Service_Tubes_Config__c config : (List <PM_Selected_Service_Tubes_Config__c>) Database.query(sQuery)){
                return config;                                           
            }
        }
        
        PM_Selected_Service_Tubes_Config__c config = new PM_Selected_Service_Tubes_Config__c(
                                                        Quote_item__c = qliId, 
                                                        PM_Selected_Tubes_Config__c = tubeid,
                                                        Location__c = qli.Location__c,
                                                        Tube_Segment__c = qli.Product_Sub_segment__c
                                                        );
        insert config;
        return config;
    }
    
    @AuraEnabled
    public static Sobject saveproductconfig(Sobject so){
        upsert so;        
        Id soId = so.Id;
        if(String.ValueOf(so.getSObjectType()) == 'PM_Selected_Service_Tubes_Config__c'){
            String sQuery = AP00_PM_UtilityMethods.getAllFieldsForSOQL('PM_Selected_Service_Tubes_Config__c');
            sQuery += ' WHERE Id =: soId';
            for(SObject updatedso : Database.query(sQuery)){
                return updatedso;
            }            
        }                
        
        return so;
    }
    
    
    
    */
    
}