public with sharing class LC01_RECO_FinalPriceOfferController {

	@AuraEnabled
	//public static list<PM_Review_NetPrice_per_MOQ__c>  getFinalReviewPrices(Id quoteLineItemId){
	public static map<String, Object> getFinalReviewPrices(Id quoteLineItemId) {

		Recordtype finalReviewRecType = [select Id, DeveloperName, sobjecttype from RecordType where DeveloperName = 'Final_Review_Price' and sobjecttype = 'PM_Review_NetPrice_per_MOQ__c' limit 1];
		//GEt Final Review Prices
		List<PM_Review_NetPrice_per_MOQ__c> finalreviewPrices = [select id, EXW_Price__c, Transport_Price__c, Selected__c, 
															     Quote_Line_Item__c, Quoted_Price_Color__c, Price_Color__c, Quoted_Price__c, MOQ_Units__c, Delta_vs_List_Price__c, RecordTypeId, 
															     Quote_Line_Item__r.Product_Line__c, Quote_Line_Item__r.Location__c, Quote_Line_Item__r.Total_Score__c, 
															     Price_Color_For_Interface__c, Quote_Line_Item__r.Copy_Quote_Status__c
															     from PM_Review_NetPrice_per_MOQ__c where Quote_Line_Item__c = :quoteLineItemId and RecordTypeId = :finalReviewRecType.id limit 7];
		system.debug('@@qama getFinalReviewPrices finalreviewPrices ' + finalreviewPrices);
		//If Final Price does not exist ,1st Init
		if(finalreviewPrices.size() == 0) {

			list<PM_Review_NetPrice_per_MOQ__c> initReviewPrices = new list<PM_Review_NetPrice_per_MOQ__c>();

			for(integer i = 0; i < 7; i ++) {

				//create new Final Price
				PM_Review_NetPrice_per_MOQ__c initFinalReviewPrice = new PM_Review_NetPrice_per_MOQ__c();
				initFinalReviewPrice.Quote_Line_Item__c = quoteLineItemId;
				initFinalReviewPrice.RecordTypeId = finalReviewRecType.id;

				initReviewPrices.add(initFinalReviewPrice);
			}


			insert initReviewPrices;

			finalreviewPrices = [select id, EXW_Price__c, Transport_Price__c, Selected__c, Quote_Line_Item__c, 
							     Quoted_Price_Color__c, Price_Color__c, Quoted_Price__c, MOQ_Units__c, 
							     Delta_vs_List_Price__c, RecordTypeId, Quote_Line_Item__r.Copy_Quote_Status__c
							     from PM_Review_NetPrice_per_MOQ__c where Quote_Line_Item__c = :quoteLineItemId and RecordTypeId = :finalReviewRecType.id limit 7];

			system.debug('---Init Final Review Prices ---' + finalreviewPrices);

			//return finalreviewPrices;//commented BY MARYEM QADA

		} else {

			system.debug('---Existing  Final Review Prices ---' + finalreviewPrices);
			//Return existing FinalPrice
			//return finalreviewPrices; //commented BY MARYEM QADA
		}

		//ADDED BY MARYEM QADA to check if the config had been correctly setted => to activate the pricing section ( section 6)
		Boolean configOK = false;
		//check if the prices are filled or not
		for(PM_MOQ_Price__c pr :[select list_price__c from PM_MOQ_Price__c where quote_item__c = :quoteLineItemId]) {
			if(pr.list_price__c != null && pr.list_price__c != 0) {
				configOK = true;
				break;
			}
		}

		Map<String, Object> result = new Map<String, Object>();
		Quotelineitem currentQli = [select id, location__c, product_line__c, Product_Sub_segment__c from quotelineitem where id = :quoteLineItemId limit 1];
		if(currentQli.product_line__c == Label.Label_ProductLine_Tubes) {
            	PM_Selected_Tubes_Config__c     selectedTube = new  PM_Selected_Tubes_Config__c ();
            List <PM_Selected_Tubes_Config__c> stubeList = [select id, Valid_config__c,Diameter_mm__c,Diameter_inches__c from PM_Selected_Tubes_Config__c where quote_item__c = :quoteLineItemId order by createdDate DESC, lastModifiedDate DESC  ];
                if (stubeList != null && stubeList.size() > 0) {
                if(stubeList.size() == 1 ||stubeList.get(0).Diameter_mm__c!=null || stubeList.get(0).Diameter_inches__c != null)
                selectedTube = stubeList.get(0);
                else
                {
                    for(PM_Selected_Tubes_Config__c tub :stubeList)
                {
                     if( tub.Diameter_inches__c!=null || tub.Diameter_mm__c!=null)
                     { selectedTube =tub;
                         break;
                      }
                }
                if(selectedTube == null)selectedTube = stubeList.get(0);
                }
                 //selectedTube = stubeList.get(1);
                } 
		
			configOK = selectedTube.Valid_config__c ? configOK :false;
			result.put('productLine', Label.Label_ProductLine_Tubes);
		} 
		else if(currentQli.product_line__c == Label.Label_ProductLine_Dispensing) {
			PM_Selected_Dipsensing_config__c     selectedDisp = [select id, Valid_config__c from PM_Selected_Dipsensing_config__c where quote_item__c = :quoteLineItemId limit 1];
			configOK = selectedDisp.Valid_config__c ? configOK :false;
			result.put('productLine', Label.Label_ProductLine_Dispensing);
		}
		result.put('location', currentQli.location__c);
		//Added by Arthur Leriche : check if there is a price in the product definition section
		if(currentQli.Product_line__c == 'Dispensing') {
			Decimal sumProductDefinition = 0;
			Decimal sumFineMist = 0;

			for(PM_price_detail__c pd :[Select Section__c, Name, Price__c from PM_price_detail__c Where Quote_item__c = :quoteLineItemId]) {
				if(pd.Section__c == 'Product Definition' && pd.Name == 'Pump') {
					sumProductDefinition += pd.price__c;
					sumFineMist += pd.price__c;
				}
				if(pd.Section__c == 'Product Definition' && pd.Name == 'Actuator (if sold separately)') {
					sumFineMist += pd.price__c;
				}
				if(pd.Section__c == 'Product Definition' && pd.Name == 'Separate Actuator') {
					sumFineMist += pd.price__c;
				}

			}
			if(currentQli.Product_Sub_segment__c != AP00_UtilityConstants.FINEMIST_PRODUCTSEGMENT_NAME && sumProductDefinition == 0) {
				configOK = false;
			}
			if(currentQli.Product_Sub_segment__c == AP00_UtilityConstants.FINEMIST_PRODUCTSEGMENT_NAME && sumFineMist == 0) {
				configOK = false;
			}

		}

		result.put('priceRecos', finalreviewPrices);
		result.put('configOK', configOK);
		result.put('quoteStatus', finalreviewPrices [0].Quote_Line_Item__r.Copy_Quote_Status__c);

		return result;

	}

	@AuraEnabled
	public static list<PM_Review_NetPrice_per_MOQ__c> updateFinalReviewPrices(list<PM_Review_NetPrice_per_MOQ__c> FinalReviewPricesList) {

		system.debug('--- Final Review Prices ---' + FinalReviewPricesList);
		return PMReviewNetPriceperMoqService.calculatePriceColor(FinalReviewPricesList);
		//if (FinalReviewPricesList.size()>0)
			// update FinalReviewPricesList;
		//return FinalReviewPricesList;


		/*Set<Id> reviewsIDs = new set<Id>();
		 For(PM_Review_NetPrice_per_MOQ__c review : FinalReviewPricesList){

		 reviewsIDs.add(review.id);
		 }

		 List<PM_Review_NetPrice_per_MOQ__c> updatedfinalreviewPrices = [select id,EXW_Price__c, Transport_Price__c, Selected__c,Quote_Line_Item__c,Quoted_Price_Color__c,Price_Color__c,Quoted_Price__c,MOQ_Units__c,Delta_vs_List_Price__c,RecordTypeId from PM_Review_NetPrice_per_MOQ__c where id in:reviewsIDs ];


		 return updatedfinalreviewPrices;*/
	}

	/*   @AuraEnabled
	 public static list<PM_Review_NetPrice_per_MOQ__c>  updateFinalReviewPricesX(list<PM_Review_NetPrice_per_MOQ__c> FinalReviewPricesList, integer num){

	 system.debug('--- Final Review Prices ---'+FinalReviewPricesList);

	 if (FinalReviewPricesList.size()>0)
	 update FinalReviewPricesList[num];




	 Set<Id> reviewsIDs = new set<Id>();
	 For(PM_Review_NetPrice_per_MOQ__c review : FinalReviewPricesList){

	 reviewsIDs.add(review.id);
	 }

	 List<PM_Review_NetPrice_per_MOQ__c> updatedfinalreviewPrices = [select id,EXW_Price__c, Transport_Price__c, Selected__c,Quote_Line_Item__c,Quoted_Price_Color__c,Price_Color__c,Quoted_Price__c,MOQ_Units__c,Delta_vs_List_Price__c,RecordTypeId from PM_Review_NetPrice_per_MOQ__c where id in:reviewsIDs ];


	 return updatedfinalreviewPrices;
	 } */

	@AuraEnabled
	public static void saveResult(list<PM_Review_NetPrice_per_MOQ__c> FinalReviewPricesList) {
		for (PM_Review_NetPrice_per_MOQ__c finalPrice :FinalReviewPricesList) {
			if(finalPrice.MOQ_Units__c == null) {
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

		}

		update FinalReviewPricesList;
	}


	@AuraEnabled
	public static list<PM_Review_NetPrice_per_MOQ__c> selectFinalReview(list<PM_Review_NetPrice_per_MOQ__c> FinalReviewPricesList, Id finalReviewPriceId) {

		Set<Id> reviewsIDs = new set<Id>();
		For(PM_Review_NetPrice_per_MOQ__c FinalReview :FinalReviewPricesList) {

			reviewsIDs.add(FinalReview.id);
			if(FinalReview.id == finalReviewPriceId) {

				FinalReview.Selected__c = true;
			} else {

				FinalReview.Selected__c = false;
			}
		}
		update FinalReviewPricesList;

		List<PM_Review_NetPrice_per_MOQ__c> updatedfinalreviewPrices = [select id, EXW_Price__c, Transport_Price__c, Selected__c, Quote_Line_Item__c, Quoted_Price_Color__c, Quoted_Price__c, Price_Color__c, MOQ_Units__c, Delta_vs_List_Price__c, RecordTypeId from PM_Review_NetPrice_per_MOQ__c where id in :reviewsIDs];


		return updatedfinalreviewPrices;

	}

	public static PM_Review_NetPrice_per_MOQ__c calcDelta(Id quoteLineItemId, PM_Review_NetPrice_per_MOQ__c FinalReviewPrice) {

		system.debug('--- Final Review Price for Delta ---' + FinalReviewPrice);

		//Retrieve Related Price MOQ Total
		PM_MOQ_price__c MOQPrice = [select id, List_Price__c, Quote_item__c, MOQ_Max__c, MOQ_Min__c from PM_MOQ_price__c where Quote_item__c = :quoteLineItemId and MOQ_Min__c <= :FinalReviewPrice.MOQ_Units__c and MOQ_Max__c > :FinalReviewPrice.MOQ_Units__c];

		//Do Delta Calculation
		System.debug('--- list Price ---' + MOQPrice.List_Price__c);
		System.debug('--- Quoted Price ---' + FinalReviewPrice.Quoted_Price__c);

		Double Discount = (-1 + (FinalReviewPrice.Quoted_Price__c / MOQPrice.List_Price__c));

		System.debug('--- Discount ---' + Discount);


		return FinalReviewPrice;
	}

	@AuraEnabled
	public static PM_Review_NetPrice_per_MOQ__c selected(list<PM_Review_NetPrice_per_MOQ__c> FinalReviewPricesList) {

		PM_Review_NetPrice_per_MOQ__c selected = new PM_Review_NetPrice_per_MOQ__c();

		For(PM_Review_NetPrice_per_MOQ__c review :FinalReviewPricesList) {

			if(review.Selected__c == true) {
				selected = review;
			}
		}
		system.debug('--- Seleceted ---' + selected);
		return selected;
	}



}