({
    init: function(cmp, event, helper) {
       
    	var action = cmp.get("c.displayCurrencyError");
    	//var action = cmp.get("c.displaybuttonvalidation"); commented for currency needs
        action.setParams({
            quoteItemId : cmp.get("v.recordId")          
        });
		action.setCallback(this, function(actionResult) { 
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
            console.log('=====result');
            console.log(actionResult.getReturnValue());
            
            	 cmp.set("v.display", actionResult.getReturnValue()[0]);//added by maryem qada for currency errors
            	 cmp.set("v.displayErrorCurrency", actionResult.getReturnValue()[1]); //added by maryem qada for currency errors
        		//cmp.set("v.display", actionResult.getReturnValue());//commented by maryem qada for currency errors
            } else {
                console.log("An Error occured" + state);
                //alert("An Error occured" + state);
            }          
		});
		$A.enqueueAction(action); 

        var action2 = cmp.get("c.displayComponent");
        //var action = cmp.get("c.displaybuttonvalidation"); commented for currency needs
        action2.setParams({
            quoteItemId : cmp.get("v.recordId")          
        });
        action2.setCallback(this, function(actionResult) { 
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
            console.log('=====result');
            console.log(actionResult.getReturnValue());
            cmp.set("v.displayComponent", actionResult.getReturnValue());
            } else {
                console.log("An Error occured" + state);
                //alert("An Error occured" + state);
            }          
        });
        $A.enqueueAction(action2); 


    },
    
   
    recordUpdated : function(component, event, helper) {

	    var changeType = event.getParams().changeType;
	
	    if (changeType === "CHANGED") { 
	    //  component.find("forceRecord").reloadRecord();
	    }
    },

    gotoPMHomePage: function(component, event, helper) {
        console.log("LC01_OpenPriceMtrixButton:JsController:gotoPMHomePage  component.get('v.recordId') : " +component.get("v.recordId"));
        
        var action = component.get("c.setIDRFQ");
        action.setParams({
            quoteItemId : component.get("v.recordId")          
        });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            
            if (state === "SUCCESS") {
        		console.log("Set ID RFQ");
            } else {
                console.log("An Error occured" + state);
               
            }          
		});
		$A.enqueueAction(action); 
        var evt = $A.get("e.force:navigateToComponent");
       //console.log('****tube*****' + tube);
        //var tube =false;
 /*******************To be activated to frack better project *********************/
  var action0= component.get("c.getTubeEU");
         action0.setParams({
            quoteItemId : component.get("v.recordId")          
        });
        action0.setCallback(this, function(actionResult) { 
             tube = actionResult.getReturnValue();
            console.log('@@@@tube*****' + tube);
            if(tube)
            {
                evt.setParams({
            componentDef : "c:LC01_RECO",
            componentAttributes: {
                qliId :  component.get("v.recordId")                
            }
        });
            }else
            {
               evt.setParams({
            componentDef : "c:LC01_Home",
            componentAttributes: {
                qliId :  component.get("v.recordId")                
            }
        }); 
            }
             evt.fire();
        }); 
       $A.enqueueAction(action0);       
        
        /*
        evt.setParams({
            componentDef : "c:LC01_Home",
            componentAttributes: {
                qliId :  component.get("v.recordId")                
            }
        }); 
        evt.fire();*/
       
    }
})