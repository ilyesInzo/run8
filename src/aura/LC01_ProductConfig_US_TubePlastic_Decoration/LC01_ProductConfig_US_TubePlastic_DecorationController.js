({
	handleEvent : function(cmp, event, helper) {
		var name = event.getParam("name");
		if(name == "Printing_type__c" || name == "Diameter_inches__c" || name == "Head_Name__c"){
		
			var action = cmp.get("c.getColors");
			var selconfig = cmp.get("v.selectedconfig");
            var mappreviousval = {"NB_Offset_Colors__c":selconfig.NB_Offset_Colors__c,
                                  "NB_Flexo_Colors__c":selconfig.NB_Flexo_Colors__c,
                                  "NB_SS_Colors__c":selconfig.NB_SS_Colors__c};
            
			selconfig['sobjectType'] = 'PM_Selected_Tubes_Config__c';
			 
	        action.setParams({
	            selcon : selconfig,
	            segment : 'Plastic'
	        });
			action.setCallback(this, function(actionResult) {
	            var state = actionResult.getState();
	            if (state === "SUCCESS") { 
	            	var colors = actionResult.getReturnValue();
                    var keys = Object.keys(colors);
	            	for (var k = 0; k < keys.length; k++) {
	            		var opts=[];
	            		var nb = colors[keys[k]];
	            		cmp.set("v." + keys[k], nb.length);
                        //console.log('******colorname********'+keys[k]);
                        //console.log('******preval********'+mappreviousval[keys[k]]);
                        var getpreval = (mappreviousval[keys[k]])?mappreviousval[keys[k]]:0;
	            		opts.push({"class": "optionClass", label: "--None--", value: 0}); 
	            		for (var i = 0; i < nb.length; i++) {
                            var isselected = (nb[i] == getpreval);                                  
                            opts.push({"class": "optionClass", label: nb[i], value: nb[i], selected: isselected });
	            		}
	            		cmp.find(keys[k]).set("v.options", opts);
                        //cmp.find(keys[k]).set("v.value", getpreval);     
                        //console.log('******getpreval********'+getpreval);
                        helper.printtechnomsg(cmp, event);
	            	}            	
	            	
	            } else {
	                console.log('AN ERROR OCCURED' + state);
	            }          
			});
			$A.enqueueAction(action);
		
		}
	},
	
	refreshmessage : function(cmp, event, helper) {
		helper.printtechnomsg(cmp, event);
	}
})