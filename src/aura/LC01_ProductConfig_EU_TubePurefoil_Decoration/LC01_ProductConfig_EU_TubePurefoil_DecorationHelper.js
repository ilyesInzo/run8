({

	firecolorvalues : function(cmp, event, fname, val) {    
	
		var val = (val)?val.toString():"";   
		
		var appEvent = $A.get("e.c:LE00_DependentPicklist");		
        appEvent.setParams({
            name: fname,
            selectedValue: val

        });
        appEvent.fire(); 
    }
})