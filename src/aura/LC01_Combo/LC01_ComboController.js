({
    handleEvent: function(cmp, event, helper) {
        helper.openModal(cmp, event);
        
	    var config = cmp.get("v.savedConfig");
	    console.log('*************cmp.get("v.savedConfig")*************' + cmp.get("v.savedConfig")); 
	    console.log('*************cmp.get("v.savedConfig")Id*************' + cmp.get("v.savedConfig").Id);
	    console.log('*************cmp.get("v.savedConfig")Combo_Num_Versions__c*************' + cmp.get("v.savedConfig").Combo_Num_Versions__c);
	    console.log('*************config.Combo_Num_Versions__c*************' + config.Combo_Num_Versions__c);
	    console.log('*************config.Combo_Num_Plate_Changes__c*************' + config.Combo_Num_Plate_Changes__c);
		
        var numverval = (config.Combo_Num_Versions__c)?config.Combo_Num_Versions__c:0;
        var numplateval = (config.Combo_Num_Plate_Changes__c)?config.Combo_Num_Plate_Changes__c:0;
        
        var numver=[];
        if(numverval == 0){            
        	numver.push({"class": "optionClass", label: "--None--", value: 0, selected: "true"});
        }else{
        	numver.push({"class": "optionClass", label: "--None--", value: 0});            
        }
        for(var i=2;i<=50;i++){
            if(numverval == i){
            	numver.push({"class": "optionClass", label: i.toString(), value: i, selected: "true"});                
            }else{                
            	numver.push({"class": "optionClass", label: i.toString(), value: i});
            }
        }
        cmp.find("Combo_Num_Versions__c").set("v.options", numver);
        
        
        var numplate=[];
        if(numplateval == 0){            
        	numplate.push({"class": "optionClass", label: "--None--", value: 0, selected: "true"});
        }else{
        	numplate.push({"class": "optionClass", label: "--None--", value: 0});            
        }
        for(var i=1;i<=10;i++){
            if(numplateval == i){
            	numplate.push({"class": "optionClass", label: i.toString(), value: i, selected: "true"});                
            }else{                
            	numplate.push({"class": "optionClass", label: i.toString(), value: i});
            }
        }
        cmp.find("Combo_Num_Plate_Changes__c").set("v.options", numplate);
	    
	     
    },
    
    savechanges :  function(cmp, event, helper) {
    	var action = cmp.get("c.saveSelectedConfig");
        action.setParams({
            so : cmp.get("v.savedConfig")
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	var config = actionResult.getReturnValue();
            	//config['sobjectType'] = 'PM_Selected_Tubes_Config__c';
            	//cmp.set("v.savedConfig", actionResult.getReturnValue());
            	console.log('*****SAVED*****' + actionResult.getReturnValue());
            	helper.closeModal(cmp, event);
            } else {
	                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
            }     
            
            console.log('*****SelectedTubeEvent*****' + $A.get("e.c:LE00_SelectedTube"));
            $A.get("e.c:LE00_SelectedTube").fire();     
		});
		$A.enqueueAction(action);
    },
    
    cancelchanges :  function(cmp, event, helper) {
    	cmp.find("Combo_Num_Versions__c").set("v.value", 0);
    	cmp.find("Combo_Num_Plate_Changes__c").set("v.value", 0);
    	cmp.find("Combo_Num_Tubes_Artwork__c").set("v.value", 0);
    	var action = cmp.get("c.saveSelectedConfig");
    	var config = cmp.get("v.savedConfig");
        action.setParams({
            so : config
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	var config = actionResult.getReturnValue();
            	console.log('*****CANCELLED*****' + actionResult.getReturnValue());
            	
            	helper.closeModal(cmp, event);
            } else {
	                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
            }          
            console.log('*****SelectedTubeEvent*****' + $A.get("e.c:LE00_SelectedTube"));
            $A.get("e.c:LE00_SelectedTube").fire();
		});
		$A.enqueueAction(action);
    }
})