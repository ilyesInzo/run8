({	
    
    init : function(component, event, helper) {
        
		if(component.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        console.log("LC01_Review_EU_DispensingSamplers.ctrl:Init ");
        
        //On Init, retrieve coresponding MOQ Pricing Details
        var MOQUnits =  component.get("v.MOQKUnit");
        var qli = component.get("v.qli.Id");
        //var selectedPrice = component.get("v.PriceMOQSelection");
        
        console.log(MOQUnits);   
        console.log(qli);       

        var action = component.get("c.getPriceDetails");
        
        action.setParams({
            "MOQUnits": MOQUnits,
            "quoteLineItemId": qli         
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

               var priceReviewMaps = response.getReturnValue();
                
               //Reset Map
               component.set("v.PM_ReviewPriceDetails_Map","");
                
                
               console.log(priceReviewMaps);
                //Set Price Details
               component.set("v.PM_PriceDetails_Map",response.getReturnValue().PriceDetailMap);
               //Set Review Details
               component.set("v.PM_ReviewPriceDetails_Map",response.getReturnValue().ReviewPriceMap);
               
               //Calculate Total List Price
               var totalListPrice =0;
               for (var key in priceReviewMaps.PriceDetailMap) {
  				   
                   totalListPrice = totalListPrice+ priceReviewMaps.PriceDetailMap[key].List_Price__c;                 
			   }
               totalListPrice = parseFloat(totalListPrice).toFixed(0);
               component.set("v.TotalListPrice",totalListPrice);
               console.log('--- Total List Price ---'+totalListPrice);
                
               //Calculate Total Review Price
               var totalReviewPrice = 0;
               for(var key in priceReviewMaps.ReviewPriceMap){
                   
                   //console.log('--- Map Key ---'+key);
                   //Check if New Review Price is set
                   var reviewPrice = priceReviewMaps.ReviewPriceMap[key].Reviewed_price__c;
                   var listPrice = priceReviewMaps.PriceDetailMap[key].List_Price__c;
                   //console.log('--- Review Price ---'+reviewPrice);
                   console.log('--- isNaN(parseFloat(reviewPrice)) ---'+isNaN(parseFloat(reviewPrice)));
                   if( reviewPrice == null ||  isNaN(parseFloat(reviewPrice))){
                      // totalReviewPrice = totalReviewPrice + listPrice;
                          totalReviewPrice = totalReviewPrice + 0;                      
                   }else{
                      totalReviewPrice = totalReviewPrice + reviewPrice; 
                   }
               }
               var totalReviewPriceDisplay = parseFloat(totalReviewPrice).toFixed(0);
               component.set("v.TotalReviewPrice",totalReviewPriceDisplay);
               console.log('--- Total Review Price ---'+totalReviewPriceDisplay); 
               
               //Set initial Discount
               var initListPrice = component.get("v.TotalListPrice");
               var initReviewPrice = component.get("v.initNetPrice");
              
               console.log('--- Init Net Price ---'+initReviewPrice);
                
               //var initDiscountCalc = (initListPrice - initReviewPrice)/initListPrice*100;               
               //initDiscountCalc = parseFloat(Math.round(initDiscountCalc )).toFixed(0);
                var initDiscountCalc = -(1-(initReviewPrice/initListPrice))*100;
               initDiscountCalc = parseFloat(initDiscountCalc ).toFixed(2);
                                       
               component.set("v.initDiscount",initDiscountCalc);
                
               //Set Current Discount
              // var currentDiscount = (totalListPrice - totalReviewPrice)/totalListPrice*100;
              // currentDiscount = parseFloat(Math.round(currentDiscount )).toFixed(0);
                var currentDiscount = -(1-(totalReviewPrice/totalListPrice))*100;
               currentDiscount = parseFloat(currentDiscount ).toFixed(2); 
                
               component.set("v.TotalDiscount",currentDiscount);

               $A.enqueueAction(component.get('c.SetAllDiscounts'));

            }
        });
        $A.enqueueAction(action);

        //ALE : 2 decimals for initnetprice

        component.set("v.initNetPrice",component.get("v.initNetPrice").toFixed(2));
        
        }
	},
    
    SetAllDiscounts : function(component,event,helper){
        
        console.log("Set All Discounts");
        var initListPrice = component.get("v.TotalListPrice");
        var initListPrice = component.get("v.TotalListPrice");
        var initReviewPrice = component.get("v.initNetPrice");
        var reviewDetailsMap = component.get("v.PM_ReviewPriceDetails_Map");
        var listDetailsMap = component.get("v.PM_PriceDetails_Map");
        var initDiscount = component.get("v.initDiscount");
        
        var action = component.get("c.setAllDiscounts");
        
        action.setParams({
            
            "initListPrice": initListPrice,
            "initReviewPrice":initReviewPrice,
            "PriceDetailMap":listDetailsMap,
            "reviewPriceMap":reviewDetailsMap
        });
        
         action.setCallback(this, function(response){
            var state = response.getState();
             if (component.isValid() && state === "SUCCESS") {
                 
                component.set("v.PM_ReviewPriceDetails_Map",response.getReturnValue());
                component.set("v.TotalDiscount",initDiscount);
             }
          });
        $A.enqueueAction(action);
                            
    },
    
    
    updatePriceDetails : function(component, event, helper) {
    
		console.log("LC01_Review_EU_DispensingSamplers.ctrl:  Update Price Details ");
        var reviewDetailsMap = component.get("v.PM_ReviewPriceDetails_Map");
        
        var FinalTotalPrice = component.get("v.TotalReviewPrice");
        var MOQ = component.get("v.MOQKUnit");
        console.log('--- MOQ ---'+MOQ);
    	console.log('--- FinalTotalPrice ---'+FinalTotalPrice);
        
        //Set Final Price
        component.set("v.FinalReviewPrice.Quoted_Price__c",FinalTotalPrice);
        component.set("v.FinalReviewPrice.MOQ_Units__c",MOQ);
        
        
        var action = component.get("c.updateReviewDetails");
        
        action.setParams({
            
            "reviewDetailsMap": reviewDetailsMap,
            "finalReviewPrice":component.get("v.FinalReviewPrice"),
            "price": component.get("v.FinalReviewPrice").Quoted_Price__c
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

               //Set Review Details
               //component.set("v.PM_ReviewPriceDetails_Map",response.getReturnValue());
               
               //Update PriceMOQSelection 
                
              // component.set("v.PriceMOQSelection.MOQUnits"  ,"v.MOQKUnit")
              // component.set("v.PriceMOQSelection.QuotedPrice","v.TotalReviewPrice")
                
               alert('Final Price has been updated');
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTotal : function(component, event, helper) {
    
		console.log('******    update total *******');
		var OldreviewPriceMap = component.get("v.PM_ReviewPriceDetails_Map");
        
        //Get Updated Values Map
        var action = component.get("c.updatedReviewPriceMap");
        
        action.setParams({
            
            "oldMap": OldreviewPriceMap
        });
        
        var updreviewPriceMap;
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

               
               updreviewPriceMap = response.getReturnValue();
               console.log('---- updated map ----'+updreviewPriceMap);
                
               var listPriceMap = component.get("v.PM_PriceDetails_Map");
                
                //Calculate Total Review Price
                var totalReviewPrice = 0;
                console.log("Updated reviewPriceMap"+updreviewPriceMap);
                for(var key in updreviewPriceMap){
                       
                       //Check if New Review Price is set
                       var reviewPrice = updreviewPriceMap[key].Reviewed_price__c;
                       var listPrice = listPriceMap[key].List_Price__c;
                       console.log('--- Review Price ---'+reviewPrice);
                       console.log('--- isNaN(parseFloat(reviewPrice)) ---'+isNaN(parseFloat(reviewPrice)));
                   	   if( reviewPrice == null ||  isNaN(parseFloat(reviewPrice))){
                           
                          // totalReviewPrice = totalReviewPrice + listPrice;
                          totalReviewPrice = totalReviewPrice + 0;                      
                       }else{
                          totalReviewPrice = totalReviewPrice + reviewPrice; 
                       }
                   }
                    totalReviewPrice = parseFloat(totalReviewPrice ).toFixed(2);
                    console.log('--- New Total Calculated ---'+totalReviewPrice);
                    component.set("v.TotalReviewPrice",totalReviewPrice);
                    var totalListPrice = component.get("v.TotalListPrice");
                    
                    //Set Current Discount
                   // var currentDiscount = (totalListPrice - totalReviewPrice)/totalListPrice*100;
                	 var currentDiscount = -(1-(totalReviewPrice/totalListPrice))*100;
                    currentDiscount = parseFloat(currentDiscount ).toFixed(2);
                           
                    component.set("v.TotalDiscount",currentDiscount);

                    var action2 = component.get("c.getFinalColor");
        
                    action2.setParams({
                          "ReviewId": component.get("v.FinalReviewPrice").Id,
                          "newPrice" : component.get("v.TotalReviewPrice")       
                    });

                    action2.setCallback(this, function(response){
                      var state = response.getState();
                      if (component.isValid() && state === "SUCCESS") {
                        component.set("v.TotalColor",response.getReturnValue());                       

                      }
                    });
                    $A.enqueueAction(action2);
                     
                    }
        });
        $A.enqueueAction(action);
        
        
        
        
    
	}
    
 })