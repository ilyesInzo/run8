public class LCC01_Scorings_Controller{

    public static String LOG_CLASS_NAME = 'LCC01_Scorings_Controller';


    public static List<Scoring__c> getscoringslists(String scoringname, string billcurrency){
        
        //scoringname => Customer, Deal
        Id scoringRT;
        for(RecordType rt : [select Id from RecordType where SobjectType =:'Scoring__c' and DeveloperName =: scoringname]){
            scoringRT = rt.Id;
        }
        
        return [select Id, Name, Criteria_API_Name__c, Level_1_Key__c,Level_1_Value__c, Level_2_Key__c,Level_2_Value__c, Level_3_Key__c,Level_3_Value__c, 
                Level_4_Key__c,Level_4_Value__c, Level_5_Key__c,Level_5_Value__c, Dispensing__c, Tubes__c, Prospect__c, Existing__c,Weight_w_o_service__c, Weight_w_service__c 
                from Scoring__c where Criteria_API_Name__c != null and RecordTypeId =: scoringRT and Location__c =:billcurrency];
    }
    
    @AuraEnabled
    public static map<String, List<String>> getpicklistvalues(String scoringname, QuoteLineItem qli){
         //Get the list of countries eligible for SKONTO
        list<string> liEligibleCountries = new list<string>();
        for(PM_Global_Config__c gc : [select Country_Name__c from PM_Global_Config__c where Table_name__c ='SKONTO' ])
        	liEligibleCountries.add(gc.Country_Name__c.toUpperCase())	;
        system.debug('liEligibleCountries '+liEligibleCountries);
        
        List<String> disabledlist = new List<String>();
        if(qli.Quote.Opportunity.Account.Type == 'Prospect'){
            disabledlist.add('Customer_EBB_rate__c');
            disabledlist.add('Monthly_overdue_DSO__c');
        }
        if(qli.Location__c == 'EU' && (qli.Product_Sub_segment__c == 'Plastic tubes' || qli.Product_Sub_segment__c == 'Laminate tubes' || (qli.Product_Sub_segment__c == 'Plastic tubes' && qli.Purefoil_segment__c))){
            disabledlist.add('DS_NB_month_of_stock_at_Albea_expenses__c');          
        }
        if(qli.Location__c == 'EU' && !liEligibleCountries.contains(qli.Quote.Opportunity.Account.Country__r.Name) /* != 'GERMANY'*/){          
            disabledlist.add('DS_Skonto_for_cash_payment__c');
        }
    
        
        map<String, List<String>> picklistvalues = new map<String, List<String>>();
        for(Scoring__c score : getscoringslists(scoringname, getlocation(qli.Location__c))){  
        
            
            List<String> values = new List<String>();
            //if(!disabledlist.contains(score.Criteria_API_Name__c)){
                for(integer i = 1 ; i <= 5 ; i ++){
                    String s = (string)score.get('Level_' + i + '_Key__c');
                    if(s != null && s != ''){
                        values.add(s);
                    }
                }
            //}
            
            picklistvalues.put(score.Criteria_API_Name__c, values);
            
            system.debug('***********Criteria_API_Name__c*************' + score.Criteria_API_Name__c + '********values*********' + values);
        }
        
        picklistvalues.put('disabledfields', disabledlist);
        
        return picklistvalues;
    }
    
    
    @AuraEnabled
    public static QuoteLineItem initscorings(QuoteLineItem qli) {
        if(qli.Customer_Scoring__c == null){
            System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initscorings');
            for(Account acc : [select Additional_comments_on_customer_scoring__c,Business_at_other_product_line__c,Customer_EBB_rate__c,
                                 Customer_end_of_year_rebate__c,Customer_Type__c,Monthly_overdue_DSO__c,Payment_terms__c,Quality_requirement__c,Required_level_of_documentation__c 
                                 from Account where Id =:qli.Quote.Opportunity.AccountId]){
                qli.Customer_Type__c = acc.Customer_Type__c;
                qli.Payment_terms__c = acc.Payment_terms__c;
                qli.Business_at_other_product_line__c = acc.Business_at_other_product_line__c;
                qli.Monthly_overdue_DSO__c = acc.Monthly_overdue_DSO__c;
                qli.Required_level_of_documentation__c = acc.Required_level_of_documentation__c;
                qli.Customer_end_of_year_rebate__c = acc.Customer_end_of_year_rebate__c;
                qli.Quality_requirement__c = acc.Quality_requirement__c;
                qli.Additional_comments_on_customer_scoring__c = acc.Additional_comments_on_customer_scoring__c;
                qli.Customer_EBB_rate__c = acc.Customer_EBB_rate__c;
            }
            qli = calculatescore(qli);
            qli = calculatetotalscore(qli);
        }
        return qli;
    }
    
    @AuraEnabled
    public static QuoteLineItem calculatescore(QuoteLineItem qli){
        String typeval = qli.Quote.Opportunity.Account.Type;
        
        System.debug('############### qli.Quote.Opportunity.Account.Type : '+typeval);
        
        List<Scoring__c> custscorelst = getscoringslists('Customer', getlocation(qli.Location__c));
        
        qli.Customer_Scoring__c = 0;
        for(Scoring__c score : custscorelst){
                String selval = (String)qli.get(score.Criteria_API_Name__c);
                decimal weight = 0;
                weight = (typeval == 'Prospect' && score.Prospect__c != null)?score.Prospect__c:weight;
                weight = (typeval == 'Client' && score.Existing__c != null)?score.Existing__c:weight;
                qli.Customer_Scoring__c += (selval != null && score.Level_1_Key__c == selval && score.Level_1_Value__c != null)?((score.Level_1_Value__c * weight)/100):0;
                qli.Customer_Scoring__c += (selval != null && score.Level_2_Key__c == selval && score.Level_2_Value__c != null)?((score.Level_2_Value__c * weight)/100):0;
                qli.Customer_Scoring__c += (selval != null && score.Level_3_Key__c == selval && score.Level_3_Value__c != null)?((score.Level_3_Value__c * weight)/100):0;
                qli.Customer_Scoring__c += (selval != null && score.Level_4_Key__c == selval && score.Level_4_Value__c != null)?((score.Level_4_Value__c * weight)/100):0;
                qli.Customer_Scoring__c += (selval != null && score.Level_5_Key__c == selval && score.Level_5_Value__c != null)?((score.Level_5_Value__c * weight)/100):0;
        }
        
        qli.Customer_Scoring__c = qli.Customer_Scoring__c.setScale(3);
        // Lot 3 (Optimisation du scoring) -> Activation de l'update
        update qli;
        //qli = calculatetotalscore(qli);
        return qli;
    }
    
    
    @AuraEnabled
    public static QuoteLineItem calculatedealscore(QuoteLineItem qli){
        system.debug('*********Method calculatedealscore*************');
        string typeval = qli.Product_Line__c;
        
        system.debug('*********qli.Product_Line__c*************' + qli.Product_Line__c);
        List<Scoring__c> dealscorelst = getscoringslists('Deal', getlocation(qli.Location__c));
        system.debug('********dealscorelst ************' + dealscorelst );
        
        qli.Deal_Scoring__c = 0;
        for(Scoring__c score : dealscorelst){
                String selval = (String)qli.get(score.Criteria_API_Name__c);
                decimal weight = 0;
                weight = (typeval == 'Tubes' && score.Tubes__c != null)?score.Tubes__c:weight;
                weight = (typeval == 'Dispensing' && score.Dispensing__c != null)?score.Dispensing__c:weight;
                system.debug('*******weight ***********' + weight );
                
                qli.Deal_Scoring__c += (selval != null && score.Level_1_Key__c == selval && score.Level_1_Value__c != null)?((score.Level_1_Value__c * weight)/100):0;
                qli.Deal_Scoring__c += (selval != null && score.Level_2_Key__c == selval && score.Level_2_Value__c != null)?((score.Level_2_Value__c * weight)/100):0;
                qli.Deal_Scoring__c += (selval != null && score.Level_3_Key__c == selval && score.Level_3_Value__c != null)?((score.Level_3_Value__c * weight)/100):0;
                qli.Deal_Scoring__c += (selval != null && score.Level_4_Key__c == selval && score.Level_4_Value__c != null)?((score.Level_4_Value__c * weight)/100):0;
                qli.Deal_Scoring__c += (selval != null && score.Level_5_Key__c == selval && score.Level_5_Value__c != null)?((score.Level_5_Value__c * weight)/100):0;
                system.debug('********score ************' + score );
                system.debug('********qli.Quote.Deal_Scoring__c************' + qli.Deal_Scoring__c);
        }
        
       // qli.Quote.Tooling_CAPEX_investment_required__c = (qli.Quote.Tooling_CAPEX_investments_required__c == 'Yes')?qli.Quote.Tooling_CAPEX_investment_required__c:null;
        //HM 20170521 - Deal Scoring is now in Quote Item
        qli.DS_Tooling_CAPEX_investment_required__c = (qli.DS_Tooling_CAPEX_investments_required__c == 'Yes')?qli.DS_Tooling_CAPEX_investment_required__c:null;

        //update qli.Quote;
        
        qli.Deal_Scoring__c = qli.Deal_Scoring__c.setScale(3);
         // Lot 3 (Optimisation du scoring) -> Activation de l'update
        update qli;
        system.debug('********qli.Deal_Scoring__c************' + qli.Deal_Scoring__c);
        //qli = calculatetotalscore(qli);
        return qli;
    }
    
    
    
    
    @AuraEnabled
    public static QuoteLineItem calculateservicescore(QuoteLineItem qli){
        
        List<Scoring__c> dealscorelst = getscoringslists('Service', getlocation(qli.Location__c));
        
        qli.Service_Scoring__c = 0;
        map<String, decimal> mapscorecount = new map<String, decimal>();
        mapscorecount.put(null,0);
        mapscorecount.put('',0);
        mapscorecount.put('Not Applicable',0);
        mapscorecount.put('Not Charged',0);
        mapscorecount.put('Charged',0);

        for(Scoring__c score : dealscorelst){
                String selval = (String)qli.get(score.Criteria_API_Name__c);
                decimal tempint = (mapscorecount.get(selval) == null)?0:mapscorecount.get(selval);
                tempint += 1;
                mapscorecount.put(selval, tempint);
        }       
        
       if(getlocation(qli.Location__c) == 'EU'){    
            
            decimal totalservice = mapscorecount.get('Not Charged') + mapscorecount.get('Charged');
            decimal weight = (totalservice > 0)?100 / totalservice:0;
            weight = mapscorecount.get('Charged') * weight * 0.1;
            qli.Service_Scoring__c = (mapscorecount.get('Not Charged') == 0 && mapscorecount.get('Charged') == 0)?null:weight;
                
        }
        else if(getlocation(qli.Location__c) == 'US'){

                    
            string typeval = qli.Product_Line__c;
            map<String, decimal> mapweight = new map<String, decimal>();
            mapweight.put(null,0);
            mapweight.put('',0);
            mapweight.put('Not Applicable',0);
            mapweight.put('Not Charged',0);
            mapweight.put('Charged',0);
            for(Scoring__c score : dealscorelst){
                    String selval = (String)qli.get(score.Criteria_API_Name__c);
                    decimal weightno = 0;
                    weightno = (typeval == 'Tubes' && score.Tubes__c != null)?score.Tubes__c:weightno;
                    weightno = (typeval == 'Dispensing' && score.Dispensing__c != null)?score.Dispensing__c:weightno;
                    
                    decimal tempdb = mapweight.get(selval);
                    tempdb += weightno;
                    mapweight.put(selval, tempdb);              
            }
            
            decimal totalweight = mapweight.get('Not Charged') + mapweight.get('Charged');
            decimal finalweight = 0;
            
            for(Scoring__c score : dealscorelst){
                    String selval = (String)qli.get(score.Criteria_API_Name__c);
                    decimal weightno = 0;
                    weightno = (typeval == 'Tubes' && score.Tubes__c != null)?score.Tubes__c:weightno;
                    weightno = (typeval == 'Dispensing' && score.Dispensing__c != null)?score.Dispensing__c:weightno;
                    
                    if(selval == 'Charged'){
                        finalweight += (weightno / totalweight);
                    }           
            }
            finalweight  = finalweight * 10;
            
            qli.Service_Scoring__c = (mapscorecount.get('Not Charged') == 0 && mapscorecount.get('Charged') == 0)?null:finalweight;
        }

        system.debug('******qli.Service_Scoring__c******' + qli.Service_Scoring__c);
        qli.Service_Scoring__c = (qli.Service_Scoring__c != null)?qli.Service_Scoring__c.setScale(3):qli.Service_Scoring__c;     
        system.debug('******qli.Service_Scoring__c**setScale****' + qli.Service_Scoring__c);   

         // Lot 3 (Optimisation du scoring) -> Activation de l'update
        update qli;
        qli = calculatetotalscore(qli);
        return qli;
    }
    
    public static QuoteLineItem calculatetotalscore(QuoteLineItem qli){
        
        decimal customerscore = (qli.Customer_Scoring__c != null)?qli.Customer_Scoring__c:0;
        //HM 20170521 - Deal Scoring is now in Quote Item
        decimal dealscore = (qli.Deal_Scoring__c != null)?qli.Deal_Scoring__c:0;
        decimal servicescore = (qli.Service_Scoring__c != null)?qli.Service_Scoring__c:0;
       
        List<Scoring__c> scoringweightlst = getscoringslists('Scoring_weight', getlocation(qli.Location__c));
        //qli.Quote.TOTAL_SCORING_SCORE__c = 0;
        qli.Total_Score__c = 0;
         
        for(Scoring__c score : scoringweightlst){
            if(score.Name == 'Customer Score'){
                customerscore = (qli.Service_Scoring__c == null)?customerscore * score.Weight_w_o_service__c:customerscore * score.Weight_w_service__c;
                customerscore = customerscore / 100;                

            }
            if(score.Name == 'Deal Score'){
                dealscore = (qli.Service_Scoring__c == null)?dealscore * score.Weight_w_o_service__c:dealscore * score.Weight_w_service__c;
                dealscore = dealscore/100;
            }
            if(score.Name == 'Service Score'){
                servicescore = (qli.Service_Scoring__c == null)?servicescore * score.Weight_w_o_service__c:servicescore * score.Weight_w_service__c;
                servicescore = servicescore/100;
            }
        }
       /* qli.Quote.TOTAL_SCORING_SCORE__c = customerscore + dealscore + servicescore;        
        qli.Quote.TOTAL_SCORING_SCORE__c = qli.Quote.TOTAL_SCORING_SCORE__c.setScale(3);
        update qli.Quote;*/
        
        qli.Total_Score__c = customerscore + dealscore + servicescore;        
        qli.Total_Score__c = qli.Total_Score__c.setScale(3);   
        
        List<QuoteLineItem> previousqlilst = [select Payment_terms__c,Customer_end_of_year_rebate__c, DS_Skonto_for_cash_payment__c from QuoteLineItem where Id =: qli.Id];      
        
        update qli;
        
       
        //calculate price details           
        for(QuoteLineItem previousqli : previousqlilst){
            if(previousqli.Payment_terms__c != qli.Payment_terms__c || previousqli.Customer_end_of_year_rebate__c != qli.Customer_end_of_year_rebate__c || previousqli.DS_Skonto_for_cash_payment__c != qli.DS_Skonto_for_cash_payment__c){
                for( PM_Selected_Tubes_Config__c tube : [Select Id from PM_Selected_Tubes_Config__c where Quote_item__c =: qli.Id order by LastModifiedDate desc limit 1]){
                    PM_Selected_Tubes_Config__c seltube = new PM_Selected_Tubes_Config__c();            
                    seltube = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(seltube, new Map<String,String>{'Id' => tube.Id});
                    
                    update seltube;
                }
                
                for(PM_Selected_Dipsensing_config__c disp :[Select Id from PM_Selected_Dipsensing_config__c where Quote_item__c =: qli.Id order by LastModifiedDate desc limit 1]){
                    PM_Selected_Dipsensing_config__c seldisp = new PM_Selected_Dipsensing_config__c();            
                    seldisp = (PM_Selected_Dipsensing_config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(seldisp, new Map<String,String>{'Id' => disp.Id});
                    update seldisp;
                }
           }
       }
        
        
        
        return qli;
    }
    
    
    public static string getlocation(String loc){
        loc = (loc == null || loc == '')?'EU':loc;
        return loc;
    }
    
    
    
}