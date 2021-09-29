/**
* @description Service class for interacting with PMReviewNetPriceperMoq
* @author MQ, EWA
* @date 21/11/2017
*/
public without sharing class PMReviewNetPriceperMoqService {
    /**
     * @description calculatePriceColor : calculate delta prices and the corresponding color for moq prices]
     * @param list<PM_Review_NetPrice_per_MOQ__c>
     * @return void
     */

    public static list<PM_Review_NetPrice_per_MOQ__c> calculatePriceColor(list<PM_Review_NetPrice_per_MOQ__c> newPMReviewNetPriceperMoqs) {
        //***********Util variables **************
        set<id> idQlisInPmReviewPrices = new set<id>();
        for (PM_Review_NetPrice_per_MOQ__c fp : newPMReviewNetPriceperMoqs) {
            idQlisInPmReviewPrices.add(fp.Quote_Line_Item__c) ;
        }
        System.debug('@@@ newPMReviewNetPriceperMoqs: ' + newPMReviewNetPriceperMoqs);

        map<integer, PM_Price_Detail__c> mapFreightPricesByMOQ = new map<integer, PM_Price_Detail__c>();
        for (PM_Price_Detail__c pd : [
                select id, MOQ_Min__c,MOQ_Max__c,Price__c
                from PM_Price_Detail__c
                where Name = 'Freight Price'
                and Quote_item__c = :newPMReviewNetPriceperMoqs[0].Quote_Line_Item__c
                and PM_Selected_Tubes_Config__c != null
                and Location__c = 'EU'
        ]) {
            mapFreightPricesByMOQ.put(integer.valueof(pd.moq_min__c), pd);
        }
        system.debug('@@qama mapFreightPricesByMOQ ' + mapFreightPricesByMOQ);
        //}//end if GET PM Price Details FreightPrice if TUE
        system.debug('@@qama mapFreightPricesByMOQ ' + mapFreightPricesByMOQ);
        //map of qlis related to pm review net prices       
        map<id, quotelineitem> mapQuotelineitem =
                new map<id, quotelineitem>([
                        select id, product_line__c, Product_Sub_segment__c, Market_Of_Application__c, Customer_Type__c, Customer_Size__c, Quantity, Location__c,
                                Total_Score__c, Quote.TOTAL_SCORING_SCORE__c
                        from QuoteLineItem
                        where Id in :idQlisInPmReviewPrices
                ]);

        //added by maryem qada ==> to optimise processing and deal with the max limit
        //map of standard recos related to qlis
        set<Decimal> listOfStandardMOQs = new set<Decimal>();
        //Get info for selecting the right PM Price Detail for Transport Price for Tubes EU
        Integer minMOQ = null;
        String IDSelTubeConfig = null;

        map<id, list<PM_Price_Recommendation__c>> mapIdQliToPriceRecos = new map<id, list<PM_Price_Recommendation__c>>();
        for (PM_Price_Recommendation__c priceReco : [
                select Id,merged_moq__c,Quote_Line_Item__c,List_Price__c,MOQ__c,Other_MOQ__c,PM_Selected_Tubes_Config__c,PM_Selected_Dipsensing_Config__c
                        ,Max_Threshhold_Price__c,Min_Threshhold_Price__c,Lin1_Price__c,Lin2_Price__c,Lin3_Price__c
                        ,round_Max_Threshhold_Price__c,round_Min_Threshhold_Price__c,round_Lin1_Price__c,round_Lin2_Price__c,round_Lin3_Price__c
                from PM_Price_Recommendation__c
                where Quote_line_item__c in :mapQuotelineitem.keyset()
                AND List_Price__c != 0 AND MOQ__c != 999
                ORDER BY MOQ__c DESC
        ]) {
            listOfStandardMOQs.add(priceReco.MOQ__c);
            list<PM_Price_Recommendation__c> liRecos = mapIdQliToPriceRecos.get(priceReco.Quote_line_item__c) == null
                    ? new list<PM_Price_Recommendation__c>()
                    : mapIdQliToPriceRecos.get(priceReco.Quote_line_item__c);
            liRecos.add(priceReco);
            mapIdQliToPriceRecos.put(priceReco.Quote_line_item__c, liRecos);
        }

        System.debug('@@@@ mapIdQliToPriceRecos: ' + mapIdQliToPriceRecos);

        //get recos related to specific moqs    
        set<Decimal> listOfSpecificMOQs = new set<Decimal>();
        map<id, list<PM_Price_Recommendation__c>> mapIdQliToSpecificPriceRecos = new map<id, list<PM_Price_Recommendation__c>>();
        for (PM_Price_Recommendation__c priceReco : [
                select Id,merged_moq__c,Quote_Line_Item__c,List_Price__c,MOQ__c,Other_MOQ__c,PM_Selected_Tubes_Config__c,PM_Selected_Dipsensing_Config__c
                        ,Max_Threshhold_Price__c,Min_Threshhold_Price__c,Lin1_Price__c,Lin2_Price__c,Lin3_Price__c
                        ,round_Max_Threshhold_Price__c,round_Min_Threshhold_Price__c,round_Lin1_Price__c,round_Lin2_Price__c,round_Lin3_Price__c
                from PM_Price_Recommendation__c
                where Quote_line_item__c in :mapQuotelineitem.keyset()
                AND List_Price__c != 0 AND MOQ__c = 999
                ORDER BY MOQ__c DESC
        ]) {
            listOfSpecificMOQs.add(priceReco.merged_moq__c);
            list<PM_Price_Recommendation__c> liSpecificRecos = mapIdQliToSpecificPriceRecos.get(priceReco.Quote_line_item__c) == null
                    ? new list<PM_Price_Recommendation__c>()
                    : mapIdQliToSpecificPriceRecos.get(priceReco.Quote_line_item__c);
            liSpecificRecos.add(priceReco);
            mapIdQliToSpecificPriceRecos.put(priceReco.Quote_line_item__c, liSpecificRecos);
        }
        system.debug('@@qama listOfSpecificMOQs ' + listOfSpecificMOQs);

        //************begin bulk processing***************
        for (PM_Review_NetPrice_per_MOQ__c finalPrice : newPMReviewNetPriceperMoqs) {
            //check if the final price is blank/null
            if (finalPrice.MOQ_Units__c == null) {
                //Reset Delta Calc and color
                finalPrice.MOQ_Units__c = null;
                finalPrice.Delta_vs_List_Price__c = null;
                finalPrice.Quoted_Price_Color__c = null;
                finalPrice.Selected__c = false;
                finalPrice.PriceReco__c = null;
                finalPrice.Transport_Price__c = null;
                finalPrice.EXW_Price__c = null;
                finalPrice.Quoted_Price__c = null;
                finalPrice.Price_Color_For_Interface__c = '';
            }
            //added by maryem to unselect price if no mkt of application is selected
            if (mapQuotelineitem.get(finalPrice.Quote_Line_Item__c) != null) {                //Added by EWA
                if (mapQuotelineitem.get(finalPrice.Quote_Line_Item__c).Market_Of_Application__c == null
                        || mapQuotelineitem.get(finalPrice.Quote_Line_Item__c).Market_Of_Application__c == '') {
                    finalPrice.Selected__c = false;
                }
            }

            //Do not trigger calculation if data is null or equals to zero
            if (finalPrice.MOQ_Units__c != null && finalPrice.MOQ_Units__c != 0) {

                //added by maryem qada ==> to optimise processing and deal with the max limit
                PM_Price_Recommendation__c reco = new PM_Price_Recommendation__c();
                //check if the MOQ corresponds to a specific one
                if (listOfSpecificMOQs.size() > 0
                        && listOfSpecificMOQs.contains(finalPrice.MOQ_Units__c)
                        && !listOfStandardMOQs.contains(finalPrice.MOQ_Units__c)) {
                    //get the correspondant reco from the specific map
                    for (PM_Price_Recommendation__c rec : mapIdQliToSpecificPriceRecos.get(finalPrice.Quote_Line_Item__c)) {
                        if (rec.merged_moq__c == finalPrice.MOQ_Units__c) {
                            reco = rec; break;
                        }//end if < > 
                    }//end for
                } else {
                    //Retrieve Related Price recos from standard recos
                    if (mapIdQliToPriceRecos.size() > 0)
                        for (PM_Price_Recommendation__c rec : mapIdQliToPriceRecos.get(finalPrice.Quote_Line_Item__c)) {
                            if (rec.MOQ__c <= finalPrice.MOQ_Units__c || rec.Other_MOQ__c == finalPrice.MOQ_Units__c) {
                                reco = rec; break;
                            }//end if < > 
                        }//end ofr moqPrices    
                }


                //Retrieve Min MOQ from standard recos to get the correspondant price detail line 
                if (mapIdQliToPriceRecos.size() > 0)
                    for (PM_Price_Recommendation__c rec : mapIdQliToPriceRecos.get(finalPrice.Quote_Line_Item__c)) {
                        if (rec.MOQ__c <= finalPrice.MOQ_Units__c || rec.Other_MOQ__c == finalPrice.MOQ_Units__c) {
                            minMOQ = integer.valueof(rec.MOQ__c); break;
                        }//end if < >
                    }//end ofr moqPrices              


                //************** Color Calculation ***********************************
                QuoteLineItem item = mapQuotelineitem.get(finalPrice.Quote_Line_Item__c);

                //if we find a reco, we calculate the corresponding colors 
                //and csheck if the list price is equals to -1 to display to affect grey COLOR
                system.debug('@@qama transport price ' + finalPrice.Transport_Price__c);
                System.debug('@@@@ reco : ' + reco);
                System.debug('@@@@ reco List_Price__c: ' + reco.List_Price__c);
                if (reco != null
                        && reco.List_Price__c != -1) {
                    //link to priceReco @@qama

                    finalPrice.PriceReco__c = reco.id;
                    IF (!finalPrice.Tech_Update_is_from_AdjustNetPrice__c)

                        if (finalPrice.Quote_Line_Item__r.Product_Line__c == 'Tubes' && finalPrice.Quote_Line_Item__r.Location__c == 'EU') {

                            finalPrice.Transport_Price__c = mapFreightPricesByMOQ.get(integer.valueof(minMOQ)) != null
                                    ? mapFreightPricesByMOQ.get(integer.valueof(minMOQ)).price__c.setscale(0)
                                    : null;
                            finalPrice.Tech_Update_is_from_AdjustNetPrice__c = true;

                        }
                    if (((finalPrice.Quote_Line_Item__r.Product_Line__c == 'Tubes' && finalPrice.Quote_Line_Item__r.Location__c == 'EU')
                            || finalPrice.Quote_Line_Item__r.Location__c == 'US') && finalPrice.Quoted_Price__c != null) {
                        finalPrice.EXW_Price__c = finalPrice.Quoted_Price__c -
                                (finalPrice.Transport_Price__c != null ? finalPrice.Transport_Price__c : 0);
                        finalPrice.Delta_vs_List_Price__c = finalPrice.Quoted_Price__c != null ?
                                (100 * (-1 + (finalPrice.Quoted_Price__c / reco.List_Price__c))).setscale(2) : null;

                    } else if (finalPrice.EXW_Price__c != null) {
                        finalPrice.Quoted_Price__c = finalPrice.EXW_Price__c +
                                (finalPrice.Transport_Price__c != null ? finalPrice.Transport_Price__c : 0);
                        finalPrice.Delta_vs_List_Price__c = finalPrice.EXW_Price__c != null ?
                                (100 * (-1 + (finalPrice.EXW_Price__c / reco.List_Price__c))).setscale(2) : null;

                    }


                } else {

                    finalPrice.PriceReco__c = null ;   //reinit attached pricereco
                    if (reco != null) {//added by maryem to attach a pricereco to a finalreview price even if it is specific
                        finalPrice.PriceReco__c = reco.id;
                        IF (!finalPrice.Tech_Update_is_from_AdjustNetPrice__c) {
                            if (finalPrice.Quote_Line_Item__r.Product_Line__c == 'Tubes' && finalPrice.Quote_Line_Item__r.Location__c == 'EU') {

                                finalPrice.Transport_Price__c = mapFreightPricesByMOQ.get(integer.valueof(minMOQ)) != null
                                        ? mapFreightPricesByMOQ.get(integer.valueof(minMOQ)).price__c.setscale(0)
                                        : null;
                                finalPrice.Tech_Update_is_from_AdjustNetPrice__c = true;
                            }

                        }
                        if (((finalPrice.Quote_Line_Item__r.Product_Line__c == 'Tubes' && finalPrice.Quote_Line_Item__r.Location__c == 'EU')
                                || finalPrice.Quote_Line_Item__r.Location__c == 'US') && finalPrice.Quoted_Price__c != null) {
                            finalPrice.EXW_Price__c = finalPrice.Quoted_Price__c -
                                    (finalPrice.Transport_Price__c != null ? finalPrice.Transport_Price__c : 0);
                        } else if (finalPrice.EXW_Price__c != null) {
                            finalPrice.Quoted_Price__c = finalPrice.EXW_Price__c +
                                    (finalPrice.Transport_Price__c != null ? finalPrice.Transport_Price__c : 0);

                        }


                    }

                }
                System.debug('---- MAM -- Quoted Price: ' + finalPrice.Quoted_Price__c);
                System.debug('---- MAM -- EXW Price: ' + finalPrice.EXW_Price__c);
                System.debug('---- MAM -- Reco: ' + reco.round_max_Threshhold_Price__c);
                System.debug('---- MAM -- Reco2: ' + reco.round_Min_Threshhold_Price__c);
                Decimal realPrice = finalPrice.Quote_Line_Item__r.Product_Line__c == 'Tubes' ?
                        finalPrice.Quoted_Price__c : finalPrice.EXW_Price__c;
                if (realPrice != null) {
                    Decimal ppiFinalPrice = reco.round_Min_Threshhold_Price__c != reco.round_max_Threshhold_Price__c ?
                            (realPrice - reco.round_max_Threshhold_Price__c) * 100
                                    / (reco.round_Min_Threshhold_Price__c - reco.round_max_Threshhold_Price__c) : null;
                    String priceColor;
                    if (finalPrice.Quoted_Price__c == null || finalPrice.Quoted_Price__c == 0) {
                        priceColor = '';
                    } else if (reco == null || reco.List_Price__c == -1) {
                        priceColor = 'Grey';
                    } else {
                        priceColor = ppiFinalPrice >= 100 ? 'DarkGreen' :
                                ppiFinalPrice >= 75 ? 'LightGreen' :
                                        ppiFinalPrice >= 50 ? 'Yellow' :
                                                ppiFinalPrice >= 25 ?
                                                        finalPrice.Quote_Line_Item__r.Total_Score__c > 0 && finalPrice.Quote_Line_Item__r.Total_Score__c < 4 ? 'Grey' : 'Red' :
                                                        ppiFinalPrice < 25 && ppiFinalPrice >= 0 ?
                                                                finalPrice.Quote_Line_Item__r.Total_Score__c > 0 && finalPrice.Quote_Line_Item__r.Total_Score__c < 6 ? 'Grey' : 'Black' : 'Grey';

                    }

                    finalPrice.Price_Color_For_Interface__c = priceColor;

                }


            }//end if the final price is not blank/null                 

        }//end for bulk        
        return newPMReviewNetPriceperMoqs;

    }//end calculatePriceColor


    /**
     * @description updateRelatedQuotelineitem_BULK : updated prices and moq volums on related quote line items ]
     * @param list<PM_Review_NetPrice_per_MOQ__c>
     * @return void
     */
    public static void updateRelatedQuotelineitem_BULK(list<PM_Review_NetPrice_per_MOQ__c> newPMReviewNetPriceperMoqs) {
        //Get QLi ids'


        Set<id> qlis = new set<id>();
        for (PM_Review_NetPrice_per_MOQ__c finalReviewPrice : newPMReviewNetPriceperMoqs) {
            qlis.add(finalReviewPrice.Quote_Line_Item__c);
        }//end for   

        //for pricebook
        map<string, PM_MOQ_price__c> mapIdKeyToPMMOQPRICE = new map<string, PM_MOQ_price__c>();
        for (PM_MOQ_price__c pmMOQ : [select id,List_Price__c,Quote_item__c,MOQ_Max__c,MOQ_Min__c from PM_MOQ_price__c where Quote_item__c in :qlis]) {
            mapIdKeyToPMMOQPRICE.put(pmMOQ.Quote_item__c + '_' + pmMOQ.MOQ_Min__c, pmMOQ);
        }


        list<Quotelineitem> QuotelineitemToUpdate = new list<Quotelineitem>();
        for (Quotelineitem qli : [
                select id, Bypass_VR__c,Selected_Price__c,EXW_Price__c,Transport_Price__c,Sales_price_per_1000_KCur__c,Quoted_price_color__c,Delta_vs_list_price__c,Price_Book__c, Price_book_level_per_1000__c,
                        Market_Of_Application__c,
                        X1_MOQ_per_SKU__c, X1_Piece_Price_Currency_per_1000_pieces__c,X2_MOQ_per_SKU__c, X2_Piece_Price_Currency_per_1000_pieces__c,
                        X3_MOQ_per_SKU__c, X3_Piece_Price_Currency_per_1000_pieces__c,X4_MOQ_per_SKU__c, X4_Piece_Price_Currency_per_1000_pieces__c,
                        X5_MOQ_per_SKU__c, X5_Piece_Price_Currency_per_1000_pieces__c,X6_MOQ_per_SKU__c, X6_Piece_Price_Currency_per_1000_pieces__c,
                        X7_MOQ_per_SKU__c, X7_Piece_Price_Currency_per_1000_pieces__c,
                        KPI_SKP_Price_checked_OK__c, SKP_MOQ_in_Final_Price_OK__c, KPI_SKP_Color_in_Final_Price_OK__c,KPI_SKP_PPI_OK__c,KPI_SKP_Price_Reco_OK__c, (
                        select id,Selected__c,Quoted_Price__c,Quoted_Price_Color__c,EXW_Price__c,Transport_Price__c, Delta_vs_List_Price__c,MOQ_Units__c,
                                KPI_SKP_Price_OK__c,KPI_SKP_MOQ_OK__c,KPI_SKP_Color_OK__c,KPI_SKP_PPI_OK__c,KPI_SKP_Price_Reco_OK__c
                        from PM_Review_NetPrice_per_MOQ__r
                )
                from quotelineitem
                where id in :qlis
                and (not ID_Calculette__c like '%FastTrack%' ) //added to not process Fast Track QLIs

        ]) {
            Integer counter = 0;
            Boolean thereIsASelectedPrice = false;
            QuotelineitemToUpdate.add(qli);
            for (PM_Review_NetPrice_per_MOQ__c finalReviewPrice : qli.PM_Review_NetPrice_per_MOQ__r) {
                if (finalReviewPrice.Selected__c == true
                        && QLI.Market_Of_Application__c != null) {//added by maryem to not updated the price if no mkt of application is selected
                    thereIsASelectedPrice = true;
                    QLI.Bypass_VR__c = true; //to not trigger VR => to autorize sales to update prices on qlis from PM 

                    QLI.Minimum_Order_Quantity__c = finalReviewPrice.MOQ_Units__c;
                    QLI.Selected_Price__c = finalReviewPrice.id;
                    QLI.Sales_price_per_1000_KCur__c = finalReviewPrice.Quoted_Price__c;
                    QLI.Quoted_price_color__c = finalReviewPrice.Quoted_Price_Color__c;
                    //Fields added for BREXIT
                    QLI.EXW_Price__c = finalReviewPrice.EXW_Price__c;
                    QLI.Transport_Price__c = finalReviewPrice.Transport_Price__c;

                    QLI.Delta_vs_list_price__c = finalReviewPrice.Delta_vs_List_Price__c;

                    //KPIs
                    QLI.KPI_SKP_Price_checked_OK__c = true;
                    QLI.KPI_SKP_Price_in_final_price_OK__c = finalReviewPrice.KPI_SKP_Price_OK__c ;
                    QLI.SKP_MOQ_in_Final_Price_OK__c = finalReviewPrice.KPI_SKP_MOQ_OK__c;
                    QLI.KPI_SKP_Color_in_Final_Price_OK__c = finalReviewPrice.KPI_SKP_Color_OK__c ;
                    QLI.KPI_SKP_PPI_OK__c = finalReviewPrice.KPI_SKP_PPI_OK__c ;
                    QLI.KPI_SKP_Price_Reco_OK__c = finalReviewPrice.KPI_SKP_Price_Reco_OK__c ;


                    //Check if it is an existing Price MOQ PRICE
                    PM_MOQ_price__c MOQPrice = mapIdKeyToPMMOQPRICE.get(QLI.id + '_' + finalReviewPrice.MOQ_Units__c);
                    if (MOQPrice != null) {
                        QLI.Price_Book__c = 'Yes';
                        QLI.Price_book_level_per_1000__c = MOQPrice.List_Price__c;
                    } else {
                        QLI.Price_Book__c = 'No';
                        QLI.Price_book_level_per_1000__c = -1;//added to reinit pricebook value
                    }
                }//end if selected is true  

                if (counter == 0) {
                    QLI.X1_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X1_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X1_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X1_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;
                }
                if (counter == 1) {
                    QLI.X2_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X2_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X2_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X2_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;
                }
                if (counter == 2) {
                    QLI.X3_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X3_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X3_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X3_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;
                }
                if (counter == 3) {
                    QLI.X4_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X4_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X4_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X4_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;

                }
                if (counter == 4) {
                    QLI.X5_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X5_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X5_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X5_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;
                }
                if (counter == 5) {
                    QLI.X6_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X6_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X6_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X6_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;

                }
                if (counter == 6) {
                    QLI.X7_MOQ_per_SKU__c = finalReviewPrice.MOQ_Units__c;
                    QLI.X7_Piece_Price_Currency_per_1000_pieces__c = finalReviewPrice.Quoted_Price__c;
                    QLI.QUOTELINEITEM_X7_TRANSPORT_PRICE_PER1000__c = finalReviewPrice.Transport_Price__c;
                    QLI.QUOTELINEITEM_X7_EXW_PRICE_PER_1000_PIEC__c = finalReviewPrice.EXW_Price__c;
                }
                counter++;
            }//end for 2
            //reset QLI
            if (!thereIsASelectedPrice
                    || QLI.Market_Of_Application__c == null || QLI.Market_Of_Application__c == '') {//added by maryem to unselect price if no mkt of application is selected
                QLI.Bypass_VR__c = true; //to not trigger VR => to autorize sales to update prices on QLIs from PM   
                QLI.Minimum_Order_Quantity__c = null;
                QLI.Sales_price_per_1000_KCur__c = null;
                QLI.Quoted_price_color__c = null;
                QLI.Delta_vs_list_price__c = null;
                QLI.Price_Book__c = 'No';
                QLI.Price_book_level_per_1000__c = null;
                QLI.Selected_Price__c = null;
                //reset KPIs
                QLI.KPI_SKP_Price_checked_OK__c = false;
                QLI.KPI_SKP_Price_in_final_price_OK__c = false;
                QLI.SKP_MOQ_in_Final_Price_OK__c = false;
                QLI.KPI_SKP_Color_in_Final_Price_OK__c = false;
                QLI.KPI_SKP_PPI_OK__c = false;
                QLI.KPI_SKP_Price_Reco_OK__c = false;
            }//end reset
        }//end for 1
        try {
            update QuotelineitemToUpdate;
        } catch (DmlException e) {
            System.debug(e);
        } catch (Exception e) {
            System.debug(e);
        }

    }//end updateRelatedQuotelineitem_BULK


}