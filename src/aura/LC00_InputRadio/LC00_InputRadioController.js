({

    doInit: function(cmp) {
    	
    	var mapopts = cmp.get("v.mapoptions");
    	var keyval = cmp.get("v.group");
    	 
    	if(mapopts){
	    	if(mapopts[keyval]){
	    		cmp.set("v.options", mapopts[keyval]);
	    	}
	    	if(mapopts["disabledfields"]){
	    		if(mapopts["disabledfields"].indexOf(keyval) != -1){
	    			cmp.set("v.disabled", true);
	    			if(cmp.get("v.value") && cmp.get("v.value") != ""){
	    				cmp.set("v.value", "");
	    			}
	    		}
	    	}
    	}
    	
    	if(!cmp.get("v.value")){
    		cmp.set("v.value", "");
    	}
    	
    },
    
	handlechange : function(cmp, event, helper) {
    	if(event.getSource().get("v.text") == cmp.get("v.value")){
			//cmp.set("v.value", "");
			cmp.set("v.value", cmp.get("v.resetvalue"));			
    	}
    	else{    		
			cmp.set("v.value", event.getSource().get("v.text"));
		}
    	
    }
})