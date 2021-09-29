({
	/*updateTotal : function() {
    
		console.log('---update total---');
		var reviewPriceMap = component.get("v.PM_ReviewPriceDetails_Map");
        var listPriceMap = component.get("v.PM_PriceDetails_Map");
        //Calculate Total Review Price
        var totalReviewPrice = 0;
               for(var key in reviewPriceMap){
                   
                   //Check if New Review Price is set
                   var reviewPrice = ReviewPriceMap[key].Reviewed_price__c;
                   var listPrice = listPriceMap[key].List_Price__c;
                   //console.log('--- Review Price ---'+reviewPrice);
                   //console.log('--- List Price ---'+listPrice);
                   if( reviewPrice == null ){
                       
                      totalReviewPrice = totalReviewPrice + listPrice;                      
                   }else{
                      totalReviewPrice = totalReviewPrice + reviewPrice; 
                   }
               }
               component.set("v.TotalReviewPrice",totalReviewPrice);
    
	}*/
})