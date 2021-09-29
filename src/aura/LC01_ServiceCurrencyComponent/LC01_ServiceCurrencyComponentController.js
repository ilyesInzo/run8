({
	init : function(cmp, event, helper) {
    	var val = cmp.get("v.value");
    	var symbol = cmp.get("v.currencysymbol");
    	var position = cmp.get("v.currencyposition");
    	
    	var display = (val)?val:'';
    	
    	if(!isNaN(val)){    		
    		val = (val)?val:0;
    		if(position == 'before'){
    			display = symbol + ' ' + val;
    		}
    		else{
    			display = val + ' ' + symbol;
    		}
    	}
    	/*
    	if(display == "Check with Pricing Manager" || display =="Check feasibility" || display =="Not feasible in ESU"){
    		cmp.set("v.class", "input-pink");
    	}*/
    	
    	cmp.set("v.displayvalue", display);
    }
})