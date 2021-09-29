({
	backToProductConfig: function(cmp, event, helper) {

		/*
        var evt = $A.get("e.force:navigateToComponent");
        var qli = cmp.get("v.qli");
        var pageComponentName = helper.getProductConfigCmpNameFromQli(qli);        
        console.log("## pageComponentName", pageComponentName);
        if(pageComponentName != ""){
            evt.setParams({
                componentDef : pageComponentName,
                componentAttributes: {
                    qliId : cmp.get("v.qli").Id
                }
            });
            evt.fire();            
        }
		 */
        if(cmp.get("v.qli").Id){
	        var pageComponentName = helper.getProductConfigCmpNameFromQli(cmp.get("v.qli")); 
			if(confirm('Do you want to save the changes?')){
		        if(pageComponentName){
			        var appEvent = $A.get("e.c:LE00_Detailed_Pricing");		
			        appEvent.setParams({
			            componentname: pageComponentName
			        });
			        appEvent.fire();
		        }
	        }
	        else{
            	var evt = $A.get("e.force:navigateToComponent");
		        evt.setParams({
		            componentDef : pageComponentName,
		            componentAttributes: {
		                qliId : cmp.get("v.qli").Id
		            }
		        });
		        evt.fire();		        
	        }
        }
    }
})