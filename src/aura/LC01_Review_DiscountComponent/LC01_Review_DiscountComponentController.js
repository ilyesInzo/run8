({
	calcDiscount : function(component, event, helper) {
        
        var sellingPrice = component.get("v.ReviewPriceDetail.Reviewed_price__c");
        var initialPrice = component.get("v.ListPrice");
        var pmReviewPriceDetails = component.get("v.ReviewPriceDetail");
        
        //var calDiscount = document.getElementById("discount").innerHTML ;
        console.log("List Price "+initialPrice);
        console.log("Review Price "+sellingPrice);
        console.log("Review Price details"+pmReviewPriceDetails.Reviewed_price__c);
       
        
        //if(sellingPrice !="" && sellingPrice != null){
            
            //var discount = (initialPrice - sellingPrice)/initialPrice*100; 
            if(initialPrice =="" || initialPrice == null){
                initialPrice=0;
            } 
            
            var discount;
            if (initialPrice != 0){
              discount = -(1-(sellingPrice/initialPrice))*100;
              discount = parseFloat(Math.round(discount )).toFixed(1);
            }else {
              discount = 0.00;
            }

            //discount = discount.toFixed(1);
           // discount = Math.round(discount, 3);
            console.log(" Discount percentage ="+discount+"%");
            
            if(sellingPrice === null){
            	discount = 0; 
        	}    
            
            //Update Review Details Record
            component.set("v.ReviewPriceDetail.Reviewed_price__c",sellingPrice);
            component.set("v.ReviewPriceDetail.Discount__c",discount);
            
            
            
            var UPDpmReviewPriceDetails = component.get("v.ReviewPriceDetail");
            console.log(UPDpmReviewPriceDetails.Discount__c);
            
            //Update review Details
            var action = component.get("c.updateReviewPrice");
        
            action.setParams({
                
                "reviewPriceDetail": UPDpmReviewPriceDetails         
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
    
                	console.log('---- PM review Price Detail Updated ----');
                }
            });
            $A.enqueueAction(action);
            
            //Set Dummy Total To trigger Recalculation
            component.set("v.TotalReviewPrice",discount);
     //   }
       
        
    },
    
    Hide:function (cmp, event,helper){
      
       var id = event.getSource().getLocalId();
       var idInput = id.replace('output','');
       
       console.log('--- ID JS---'+id);
       console.log('--- ID JS---'+idInput);
       var hideOutput = cmp.find(id);
       var selectedInputNumber = cmp.find(idInput);
       
       $A.util.addClass(hideOutput, 'Hide');
       $A.util.removeClass(selectedInputNumber, 'Hide');
    },
    
    unHide:function (cmp, event,helper){
       
       var id = event.getSource().getLocalId();
       var idoutput = id+'output';
       
       console.log('--- ID JS---'+id);
       console.log('--- ID JS---'+idoutput);
        
       var hideOutput = cmp.find(idoutput);
       var selectedInputNumber = cmp.find(id);
       
       $A.util.removeClass(hideOutput, 'Hide');
       $A.util.addClass(selectedInputNumber, 'Hide');
       console.log('---un Hide ---');
    },
    
    
})