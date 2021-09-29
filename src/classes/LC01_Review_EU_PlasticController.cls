/**
 * [Class LC01_Review_EU_PlasticController ]
 * @author Eric Wartelle
 * @version 0.5 - Squelette
 * @history 0.5 - Squelette
 */
public with sharing class LC01_Review_EU_PlasticController {
	//Attributs for the class LC01_Review_EU_PlasticController
    private static String LOG_CLASS_NAME = 'LC01_Review_EU_PlasticController';
    
    //Internal Class for the class LC01_Review_EU_PlasticController
    /**
     * [detailReviewMapClass ]
     */
    public class detailReviewMapClass{
       @AuraEnabled
       public Map<String,PM_price_detail__c> PriceDetailMap;
       @AuraEnabled
       public Map<String,PM_Review_NetPrice_per_MOQ__c> ReviewPriceMap;
	}
    
    //Methods for the class LC01_Review_EU_PlasticController
    /**
     * [getPriceDetails ]
     * @param  quoteLineItemId [Id                   : Id for a quote line item]
     * @param  MOQUnits        [Integer              :                         ]
     * @return                 [detailReviewMapClass :                         ]
     */
    @AuraEnabled
    public static detailReviewMapClass getPriceDetails(Id quoteLineItemId,Integer MOQUnits){

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- QLI id --- '+quoteLineItemId);
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- MOQ Units --- '+MOQUnits);
        
        //Get List of Price Details for this MOQ Range
        List<PM_price_detail__c> priceDetails = [select id,Name,Section__c,Quote_item__c,Price__c,Price_Override__c,Currency__c,List_Price__c,MOQ_Max__c,MOQ_Min__c From PM_price_detail__c where  Quote_item__c=:quoteLineItemId and MOQ_Min__c<=:MOQUnits and MOQ_Max__c >:MOQUnits];
        
        //Map Price Detail Name to PriceDetail Object
        Map<String,PM_price_detail__c> NameToPriceMap = new Map<String,PM_price_detail__c>();
        
        Set<id> PriceDetailIds = new set<id>();
        
        For(PM_price_detail__c detail : priceDetails){
            
            PriceDetailIds.add(detail.id);
            
           /* String NameNoSpace = detail.Name.remove(' ');
            NameNoSpace = NameNoSpace.remove('-');
            NameNoSpace = NameNoSpace.remove('\'');
            NameNoSpace = NameNoSpace.remove('(');
            NameNoSpace = NameNoSpace.remove(')');
            NameNoSpace = NameNoSpace.remove('/');
            NameNoSpace = NameNoSpace.remove('&');
            
            if(NameNoSpace.startsWith('5')){
              NameNoSpace =  NameNoSpace.replaceFirst('5', 'Five');
            }*/

            String NameNoSpace = SObjectUtils.cleanString(detail.Name);  
            
            NameToPriceMap.put(NameNoSpace ,detail);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- '+NameToPriceMap);
        
        //Retrieve ReviesPrice
        List<PM_Review_NetPrice_per_MOQ__c> existingReviewPrice = [select id,Discount__c,Discount_auto__c,Name,PM_Price_Detail__c,PM_Price_Detail__r.Name,PM_Price_Detail__r.List_Price__c,Reviewed_price__c from PM_Review_NetPrice_per_MOQ__c where PM_Price_Detail__c in:PriceDetailIds];
        
        //Map Price Detail Name to PriceDetail Object
        Map<String,PM_Review_NetPrice_per_MOQ__c> NameToReviewPriceMap = new Map<String,PM_Review_NetPrice_per_MOQ__c>();

        for(PM_Review_NetPrice_per_MOQ__c review : existingReviewPrice){
            
           /* String NameNoSpace = review.PM_Price_Detail__r.Name.remove(' ');
            NameNoSpace = NameNoSpace.remove('-');
            NameNoSpace = NameNoSpace.remove('\'');
            NameNoSpace = NameNoSpace.remove('(');
            NameNoSpace = NameNoSpace.remove(')');
            NameNoSpace = NameNoSpace.remove('/');
            NameNoSpace = NameNoSpace.remove('&'); 
            
            if(NameNoSpace.startsWith('5')){
              NameNoSpace =  NameNoSpace.replaceFirst('5', 'Five');
            }*/
            
            String NameNoSpace = SObjectUtils.cleanString(review.PM_Price_Detail__r.Name);       

			NameToReviewPriceMap.put(NameNoSpace,review);			            
        }
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Existing Review Map --- '+NameToReviewPriceMap);
        
        //Check if review exists else create new ones
        List<PM_Review_NetPrice_per_MOQ__c> newInitReviews = new list<PM_Review_NetPrice_per_MOQ__c>();
        
        For(PM_price_detail__c detail : priceDetails){
            
			/*String NameNoSpace = detail.Name.remove(' ');
            NameNoSpace = NameNoSpace.remove('-');
            NameNoSpace = NameNoSpace.remove('\'');
            NameNoSpace = NameNoSpace.remove('(');
            NameNoSpace = NameNoSpace.remove(')');
            NameNoSpace = NameNoSpace.remove('/');
            NameNoSpace = NameNoSpace.remove('&');
            
            if(NameNoSpace.startsWith('5')){
              NameNoSpace =  NameNoSpace.replaceFirst('5', 'Five');
            }*/

            String NameNoSpace = SObjectUtils.cleanString(detail.Name);
                                                  
            if(!NameToReviewPriceMap.containsKey(NameNoSpace)){
                //No REview Price attached, create a new one
                PM_Review_NetPrice_per_MOQ__c newInitREview = new PM_Review_NetPrice_per_MOQ__c();
                newInitREview.PM_Price_Detail__c = detail.id;
                
                
                newInitReviews.add(newInitREview);
                
                //Add to Review Price Map
                NameToReviewPriceMap.put(NameNoSpace,newInitREview);
            }
        }
        system.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Updated Review Map --- '+NameToReviewPriceMap);
        
        insert newInitReviews;
		
        //Create Response :
        detailReviewMapClass pricesMap = new detailReviewMapClass();
        //SEt Detail Map
        pricesMap.PriceDetailMap = NameToPriceMap;
        pricesMap.ReviewPriceMap = NameToReviewPriceMap;
        
        //return priceDetails;
        return pricesMap;
    }
    
    /**
     * [setAllDiscounts]
     * @param  initListPrice   [Decimal                                   :                     ] 
     * @param  initReviewPrice [Decimal                                   :                     ] 
     * @param  PriceDetailMap  [Map<String,PM_price_detail__c>            :                     ] 
     * @param  reviewPriceMap  [Map<String,PM_Review_NetPrice_per_MOQ__c> :                     ] 
     * @return Map<String,PM_Review_NetPrice_per_MOQ__c>
     */
    @AuraEnabled
    public static Map<String,PM_Review_NetPrice_per_MOQ__c> setAllDiscounts(Decimal initListPrice,Decimal initReviewPrice,Map<String,PM_price_detail__c> PriceDetailMap,Map<String,PM_Review_NetPrice_per_MOQ__c> reviewPriceMap){
    
        
        Decimal  initDiscount = (initReviewPrice/initListPrice)-1;
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Initial Discount --- '+initDiscount);
        
        list<PM_Review_NetPrice_per_MOQ__c> reviewPriceUpdates = new list<PM_Review_NetPrice_per_MOQ__c>();
        
        //Set Discount on all lines of Review Net Prices
        For(String   keyListPrice : PriceDetailMap.keySet()){
            
            //Retrieve PM Review Price
            PM_Review_NetPrice_per_MOQ__c reviewPrice = reviewPriceMap.get(keyListPrice);
            System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Initial Review Price --- '+reviewPrice);
                
            //Set Discount to Review Price
            //
            if(PriceDetailMap.get(keyListPrice).List_Price__c > 0){
                reviewPrice.Reviewed_price__c = ((1+initDiscount) * (PriceDetailMap.get(keyListPrice).List_Price__c)).setScale(3);
                
                System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Init Discount Review Price --- '+reviewPrice.Reviewed_price__c);
                
                //Set Discount
                reviewPrice.Discount__c = (initDiscount*100).setScale(2);
                
                System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Set Scale Discount Review --- '+ reviewPrice.Discount__c);                
            }
            if(PriceDetailMap.get(keyListPrice).List_Price__c == 0){
                
				reviewPrice.Reviewed_price__c = 0;
                reviewPrice.Discount__c = 0;
            }
            
            reviewPriceUpdates.add(reviewPrice);
        }

        //update Review Prices 
        update reviewPriceUpdates;
        
        //return reviewPriceMap;
        return updatedReviewPriceMap(reviewPriceMap);
    }

    /**
     * [updateReviewDetails ]
     * @param  reviewDetailsMap [Map<String,PM_Review_NetPrice_per_MOQ__c> :              ] 
     * @param  finalReviewPrice [PM_Review_NetPrice_per_MOQ__c             :              ] 
     * @return                  [Map<String,PM_Review_NetPrice_per_MOQ__c> :              ]
     */
    @AuraEnabled
    public static Map<String,PM_Review_NetPrice_per_MOQ__c> updateReviewDetails(Map<String,PM_Review_NetPrice_per_MOQ__c> reviewDetailsMap,PM_Review_NetPrice_per_MOQ__c finalReviewPrice, Decimal price){

        System.debug(LoggingLevel.INFO, ' --- Review Details Map --- '+reviewDetailsMap);
        System.debug(LoggingLevel.INFO, ' --- Final Review Price --- '+finalReviewPrice);
        
        finalReviewPrice.Quoted_Price__c = price;
        
        List<PM_Review_NetPrice_per_MOQ__c> updateReviews = new list<PM_Review_NetPrice_per_MOQ__c>();
        
        For(PM_Review_NetPrice_per_MOQ__c reviewPrice : reviewDetailsMap.values() ){
            
            System.debug(LoggingLevel.INFO, ' --- Discount Percentage --- '+reviewPrice.Discount__c);
            System.debug(LoggingLevel.INFO, ' --- Reviewed Price --- '+reviewPrice.Reviewed_price__c);
        
            updateReviews.add(reviewPrice);
        }
        
        update finalReviewPrice;
        
        return reviewDetailsMap;
    }
    
    /**
     * [updatedReviewPriceMap ]
     * @param  oldMap [Map<String,PM_Review_NetPrice_per_MOQ__c>:                   ]
     * @return        [Map<String,PM_Review_NetPrice_per_MOQ__c>:                   ] 
     */
    @AuraEnabled
    public static Map<String,PM_Review_NetPrice_per_MOQ__c> updatedReviewPriceMap(Map<String,PM_Review_NetPrice_per_MOQ__c> oldMap){
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Old Map --- '+oldMap);
        
        Set<id> ids = new set <id>();        
        For(PM_Review_NetPrice_per_MOQ__c review : oldMap.values()){
            ids.add(review.Id);
        }
        
        List<PM_Review_NetPrice_per_MOQ__c> updatedReviewPrices = [select id,Discount__c,Discount_auto__c,Name,PM_Price_Detail__c,PM_Price_Detail__r.Name,PM_Price_Detail__r.List_Price__c,Reviewed_price__c from PM_Review_NetPrice_per_MOQ__c where id in:ids];
        Map<id,PM_Review_NetPrice_per_MOQ__c> IdReviewMap = New Map<id,PM_Review_NetPrice_per_MOQ__c> ();
        For(PM_Review_NetPrice_per_MOQ__c rev : updatedReviewPrices){            
            IdReviewMap.put(rev.id,rev);            
        }     

        Map<String,PM_Review_NetPrice_per_MOQ__c> updatedMap = New Map<String,PM_Review_NetPrice_per_MOQ__c> ();  
        For(String key : oldMap.keySet()){            
            updatedMap.put(key,IdReviewMap.get(oldMap.get(key).id));
        }
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- Updated Map --- '+updatedMap);
        
        return updatedMap;
    }

    @AuraEnabled
    public static String getFinalColor(String ReviewId, Decimal newPrice){
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- ReviewId --- '+ReviewId + ' ---newPrice --- ' + newPrice);
        
        String color = '';

        if(ReviewId != null && ReviewId != ''){
            //PM_Review_NetPrice_per_MOQ__c review = [Select Price_color__c, PriceReco__r.round_max_Threshhold_Price__c, PriceReco__r.round_Min_Threshhold_Price__c, Quote_Line_Item__r.Total_Score__c  from PM_Review_NetPrice_per_MOQ__c Where id = :ReviewId limit 1];
            PM_Review_NetPrice_per_MOQ__c review = [Select MOQ_Units__c, Quote_Line_Item__c, Price_color__c, PriceReco__c, Quoted_Price__c, PM_Price_Detail__c, PPI_Final_Price__c from PM_Review_NetPrice_per_MOQ__c Where id = :ReviewId limit 1];
            system.Debug(review.PriceReco__c);
            review.Quoted_Price__c = newPrice;

            PM_Review_NetPrice_per_MOQ__c review2 = new PM_Review_NetPrice_per_MOQ__c(MOQ_Units__c = review.MOQ_Units__c, Quote_Line_Item__c = review.Quote_Line_Item__c, PriceReco__c = review.PriceReco__c, PM_Price_Detail__c = review.PM_Price_Detail__c, Quoted_Price__c = review.Quoted_Price__c);
            insert review2;
            color = [Select Price_color__c from PM_Review_NetPrice_per_MOQ__c Where id = :review2.id limit 1].Price_color__c;
            delete review2;
        }


        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- color ColorInfos --- '+color);
        
        return color;

    }




}