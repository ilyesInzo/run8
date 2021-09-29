({
    init: function(cmp, event, helper) {
    
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
       /* helper.convertList(cmp, "v.tubehead");
        helper.convertList(cmp, "v.sleeve");
        helper.convertList(cmp, "v.cap");
        helper.convertList(cmp, "v.printing");
        helper.convertList(cmp, "v.others");*/
        
        	helper.getPrices(cmp, event, 0);
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
    clickMe : function(cmp, event, helper) {
    	console.log("zzz", cmp.get("v.tubehead"));
    },
    capdescprice :  function(cmp, event, helper) {
    	cmp.set("v.cap_desc_price","");
    	
    },
    printingDescprice :  function(cmp, event, helper) {
    	cmp.set("v.printing_desc_price","");
    	
    },
    othersDescprice :  function(cmp, event, helper) {
    	cmp.set("v.others_desc_price","");
    	
    },
    savedescprice :  function(cmp, event, helper) {
    	console.log('SAVE DESC PRICE---------------------');
    	if(cmp.get("v.qli").Id){
        cmp.find("saveBtn").set("v.disabled", true);
        $A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
        
    	var updatelistitems = new Map();    	
    	updatelistitems = helper.savepricehelper(cmp, "Cap", cmp.get("v.cap"), updatelistitems);   	    	
    	console.log('@@qama savepricehelper updatelistitems');
    	console.log(updatelistitems);
    	console.log(helper.savepricehelper(cmp, "Printing", cmp.get("v.printing"), updatelistitems));
    	helper.savepricehelper(cmp, "Others", cmp.get("v.others"), updatelistitems);
            
    	var action = cmp.get("c.saveDetailPrices");
        action.setParams({
            overridepricelist : updatelistitems,            
            qliId : cmp.get("v.qli").Id
        });
        action.setCallback(this, function(response) {
        
        		var state = response.getState();
	            if (state === "SUCCESS") {
		            
                    	console.log('Saving the data SUCCESS..now getting the prices again...');
				        helper.getPrices(cmp, event, 1);
				        
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