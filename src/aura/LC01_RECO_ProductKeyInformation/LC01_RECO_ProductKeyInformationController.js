({
	doInit: function(cmp, event, helper) {
		/* 
        var action;
        var cmpname;
        var qli = cmp.get("v.qli");
        if(qli.Product_Sub_segment__c =='Plastic Tubes' || qli.Product_Sub_segment__c == 'Laminate Tubes'){
        	action = cmp.get("c.getselectedtube");
        	cmpname = "v.seltubes";
        }
        else{        
        	action = cmp.get("c.getselecteddispensing");
        	cmpname = "v.seldispensing";
        }
        action.setParams({
            quoteid : qli.Id, 
            location : qli.Location__c,
            segment : qli.Product_Sub_segment__c
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
        		cmp.set(cmpname, actionResult.getReturnValue());
            } else {
                alert("An Error occured" + state);
            }          
		});
		$A.enqueueAction(action);
		*/
		
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
		var action = cmp.get("c.getSelectedConfig");		
        var qli = cmp.get("v.qli");
        var cmpname;
        var mapfilters = {
	        'Quote_item__c' : qli.Id,
	        'Product_Segment__c' : qli.Product_Sub_segment__c,
	        'Location__c' : qli.Location__c
	        }    
        if(qli.Product_Sub_segment__c =='Plastic Tubes' || qli.Product_Sub_segment__c == 'Laminate Tubes'){
        	cmpname = "v.seltubes";
        	mapfilters['Purefoil_Segment__c'] = qli.Purefoil_Segment__c;
        }
        else{        
        	cmpname = "v.seldispensing";
        }
        
        action.setParams({
        	so : cmp.get(cmpname),
            mapfilters : mapfilters
        });
        console.log("********* ProductKeyInfos -> doInit ********** qli = ", JSON.stringify(qli));
        console.log("********* ProductKeyInfos -> doInit Call********** action.getParams() = ", JSON.stringify(action.getParams()));
        
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            var result = actionResult.getReturnValue();
            if (state === "SUCCESS") {
                
        		cmp.set(cmpname, result);
                console.log("********* ProductKeyInfos -> doInit CallBack********** action.getParams() = ", JSON.stringify(result));
            } else {
                //alert("An Error occured" + state);
                console.log("********* ProductKeyInfos -> doInit CallBack********** An Error occured state = ", state);
                console.log("********* ProductKeyInfos -> doInit CallBack********** An Error occured result = ", result);
            }          
		});
		$A.enqueueAction(action);
		}
	}
})