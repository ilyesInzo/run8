({
    init : function(cmp, evt, helper) {
        helper.getvalues(cmp);
    },
    /*
    getmessageinfo : function(cmp, evt, helper) {
        helper.getmessage(cmp);
    },
    */
    handleEvent: function(cmp, event, helper) {
    	
        var dependant = cmp.get("v.fieldvalue");
    	if(cmp.get("v.dependentfieldvalue")){
    		dependant = cmp.get("v.dependentfieldvalue");
    	}     	
        var name = event.getParam("name");
        if(dependant == name){
	        var mapv = cmp.get("v.valuesmap");
	        var val = event.getParam("selectedValue");     
			var returnval = (mapv[val])?mapv[val]:'';   
	        cmp.set("v.messageresult", returnval);
        }
    }
})