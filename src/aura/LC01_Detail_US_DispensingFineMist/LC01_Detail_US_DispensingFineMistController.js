({
    init: function(cmp, event, helper) {
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        helper.convertList(cmp, "v.productDef");
        helper.convertList(cmp, "v.colorationUpcharge");
        helper.convertList(cmp, "v.pumpOpt");
        helper.convertList(cmp, "v.diptubeOpt");
        helper.convertList(cmp, "v.others");
        helper.getPrices(cmp, event);
        }
    },
    addRow: function(cmp, event, helper) {
        var _target = event.currentTarget,
        	_dataSet = _target.dataset,
        	_listName = _dataSet.list,
        	_index = _dataSet.index,
        	_list = cmp.get(_listName);
        
        _list[_index].edit = '';
        cmp.set(_listName, _list);
    },
    proddefdescprice :  function(cmp, event, helper) {
        console.log('Product Description override click');
    	cmp.set("v.prod_def_desc_price","");
    	
    },
    
    colorationUpchargedescprice :  function(cmp, event, helper) {
        console.log('Coloration Upcharge override click');
    	cmp.set("v.coloration_upcharge_desc_price","");
    	
    },
    
    pumpOptionsdescprice :  function(cmp, event, helper) {
    	cmp.set("v.pump_Options_desc_price","");
    	
    },
    
    diptubeOptionsdescprice :  function(cmp, event, helper) {
    	cmp.set("v.diptube_Options_desc_price","");
    	
    },
    savedescprice :  function(cmp, event, helper) {
    
    
    	if(cmp.get("v.qli").Id){
        cmp.find("saveBtn").set("v.disabled", true);
        $A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
         			 			
 			
    	var updatelistitems = new Map();    	
    	updatelistitems = helper.savepricehelper(cmp, "Product Definition", cmp.get("v.productDef"), updatelistitems);   
    	updatelistitems = helper.savepricehelper(cmp, "Coloration Upcharge", cmp.get("v.colorationUpcharge"), updatelistitems);  
    	updatelistitems = helper.savepricehelper(cmp, "Pump Options", cmp.get("v.pumpOpt"), updatelistitems);  
    	updatelistitems = helper.savepricehelper(cmp, "Diptube Options", cmp.get("v.diptubeOpt"), updatelistitems);    	
    	
    	var action = cmp.get("c.saveDetailPrices");
        action.setParams({
            overridepricelist : updatelistitems,            
            qliId : cmp.get("v.qli").Id
        });
        action.setCallback(this, function(response) {
        
        		var state = response.getState();
	            if (state === "SUCCESS") {
		            
				        helper.getPrices(cmp, event);
				        
		            	var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        message: "Detailed Pricing was saved successfully.",
					        type : "success"
					    });
					    toastEvent.fire();
					    if(event.getParam("componentname")){
			            	var evt = $A.get("e.force:navigateToComponent");
					        evt.setParams({
					            componentDef : event.getParam("componentname"),
					            componentAttributes: {
					                qliId : cmp.get("v.qli").Id
					            }
					        });
					        evt.fire();	
				        }		    
	            } else {
	            	cmp.find("saveBtn").set("v.disabled", false);
	            	$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
	            	
				    var toastEvent = $A.get("e.force:showToast");
				    toastEvent.setParams({
				        message: "Failed to save Detailed Pricing.",
				        type : "error"
				    });
				    toastEvent.fire();
	            }

        
        });
        $A.enqueueAction(action);
    	}
    	
    },
    hidespinner: function (cmp, event) {
        cmp.find("saveBtn").set("v.disabled", false);
        $A.util.addClass(cmp.find("mySpinner"), "slds-hide");
    }
})