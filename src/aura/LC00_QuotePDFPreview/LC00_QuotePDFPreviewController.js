({
    init : function(cmp, event, helper) {
        
        var qli = cmp.get("v.qli");
        //Use Sub Segment to show the configuration page
        var productSubSegment = qli.Product_Sub_segment__c;
        console.log("## productSubSegment: ", productSubSegment);
        console.log("## qli.Purefoil_Segment__c: ", qli.Purefoil_Segment__c );
        
        var location = (qli.Location__c == '' || qli.Location__c == null )? 'EU' : qli.Location__c;
        console.log("## location: ", location);
        
        var quoteTemplateId = $A.get("$Label.c.PM_QuoteTemplateId_Tube_EU");;
        console.log("## $Label.c.QuoteTemplateId: ", quoteTemplateId);
        
        var customlabelname = "";
        if(productSubSegment == 'Plastic Tubes' || productSubSegment == 'Laminate Tubes'){
        	customlabelname = "$Label.c.PM_QuoteTemplateId_Tube_" + location;
        }
        else if(productSubSegment == 'Foam pumps' || productSubSegment == 'Fine mist pumps' || productSubSegment == 'Lotion pumps' || productSubSegment == 'Sampler pumps'){
        	customlabelname = "$Label.c.PM_QuoteTemplateId_Dispensing_" + location;        
        }
        else{
        	alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
        }
        quoteTemplateId = $A.get(customlabelname);
        /*
        switch (productSubSegment) {
            case "Plastic Tubes":
            case "Laminate Tubes":
                if(location == 'EU'){
                    quoteTemplateId = $A.get("$Label.c.PM_QuoteTemplateId_Tube_EU");
                }
                if(location == 'US'){
                    quoteTemplateId = $A.get("$Label.c.PM_QuoteTemplateId_Tube_US");
                }
                break;
            case "Foam pumps":
            case "Fine mist pumps":
            case "Lotion pumps":
            case "Sampler pumps":
                if(location == 'EU'){
                    quoteTemplateId = $A.get("$Label.c.PM_QuoteTemplateId_Dispensing_EU");
                }
                if(location == 'US'){
                    quoteTemplateId = $A.get("$Label.c.PM_QuoteTemplateId_Dispensing_US");
                }
                break;
            default: 
                alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
        }
        */
        console.log("## quoteTemplateId", quoteTemplateId);
        cmp.set("v.quoteTemplateId",quoteTemplateId);
        
        // open modal
        helper.openModal(cmp, event);
    },
    handleSaveToQuote: function(cmp, event, helper) {
        
        var closeBtn = cmp.find("saveToQuoteBtn");
        closeBtn.set("v.disabled",true);//Disable the button
        
        var action = cmp.get("c.saveToQuote");
        var qli = cmp.get("v.qli");
        var quoteTemplateId = cmp.get("v.quoteTemplateId");
        action.setParams({
            quoteId : qli.QuoteId,
            quoteTemplateId: quoteTemplateId
            
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                
                //var result = actionResult.getReturnValue();
                //cmp.set("v.errorMessage",result);   		
			    var toastEvent = $A.get("e.force:showToast");
			    toastEvent.setParams({
			        message: "PDF was saved successfully to quote.",
			        type : "success"
			    });
			    toastEvent.fire();
                
            } else {
             		
			    var toastEvent = $A.get("e.force:showToast");
			    toastEvent.setParams({
			        message: "Failed to save PDF to quote.",
			        type : "error"
			    });
			    toastEvent.fire();
                //alert("An Error occured" + state);
                console.log("An Error occured state: ", state);
            }          
        });
        $A.enqueueAction(action);
    },
    
    handleClose: function(cmp, event, helper) {
        // dismiss
        
        var actionClose = cmp.get("c.dismissModal");
        actionClose.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                closeBtn.set("v.disabled",false);//Enable the button
            } else {
                alert("An Error occured" + state);
            }          
        });
        
        $A.enqueueAction(actionClose);
        
    }
})