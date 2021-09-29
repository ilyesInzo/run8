({
    init: function(cmp, event, helper) {
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        helper.convertList(cmp, "v.tubehead");
        helper.convertList(cmp, "v.sleeve");
        helper.convertList(cmp, "v.cap");
        helper.convertList(cmp, "v.printing");
        helper.convertList(cmp, "v.packing");
        helper.convertList(cmp, "v.others");
         //added 6329
		helper.getCurrentUserProfileName(cmp,event);
		//***** */
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
    capdescprice :  function(cmp, event, helper) {
        console.log('Cap Override click');
    	cmp.set("v.cap_desc_price","");
    	
    }  ,
    savedescprice :  function(cmp, event, helper) {
    
    
    	if(cmp.get("v.qli").Id){
        cmp.find("saveBtn").set("v.disabled", true);
        $A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
        
    	var updatelistitems = new Map();    	
        //added ticket: 6329 
		if(cmp.get("v.hideLine"))	updatelistitems = helper.savepricehelper(cmp, "Others", cmp.get("v.others"), updatelistitems);	
		// end
    	updatelistitems = helper.savepricehelper(cmp, "Cap", cmp.get("v.cap"), updatelistitems);   	    	
    	
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