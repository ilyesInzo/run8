({
	handleEvent : function(cmp, event, helper) {
		var name = event.getParam("name");
	    var selectedValue = event.getParam("selectedValue");
		if(name == "Printing_type__c" || name == "Diameter_inches__c"){
		
			var action = cmp.get("c.getLaminateUSColors");
			var selconfig = cmp.get("v.selectedconfig");
            var mappreviousval = {"NB_Offset_Colors__c":selconfig.NB_Offset_Colors__c,
                                  "NB_Flexo_Colors__c":selconfig.NB_Flexo_Colors__c,
                                  "NB_SS_Colors__c":selconfig.NB_SS_Colors__c};
            
			selconfig['sobjectType'] = 'PM_Selected_Tubes_Config__c';
			 
	        action.setParams({
	            selcon : selconfig,
	            segment : 'Laminate'
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

                        var getpreval = (mappreviousval[keys[k]])?mappreviousval[keys[k]]:0;
	            		opts.push({"class": "optionClass", label: "--None--", value: 0}); 
	            		for (var i = 0; i < nb.length; i++) {
                            var isselected = (nb[i] == getpreval);                                  
                            opts.push({"class": "optionClass", label: nb[i], value: nb[i], selected: isselected });
	            		}
	            		cmp.find(keys[k]).set("v.options", opts);
	            	}            	
	            	
	            } else {
	                console.log('AN ERROR OCCURED' + state);
	            }          
			});
			$A.enqueueAction(action);
		
		}
		
		//Cold Stamping
		if(name == "Printing_type__c"){
						
			if(!selectedValue || selectedValue == ""){
				 cmp.find("Cold_Stamping").set("v.value","");
			}
			else if(selectedValue.indexOf("Coldstamping") != -1){
				 cmp.find("Cold_Stamping").set("v.value","Yes");
			}
			else{
				 cmp.find("Cold_Stamping").set("v.value","No");			
			}
		
		}
	}
})