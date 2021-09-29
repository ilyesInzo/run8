({
	getvalues : function(cmp) {
		var action = cmp.get("c.getmessagevalueinfo");
        action.setParams({
            value: cmp.get("v.value"),
            tablename: cmp.get("v.tablename"),
            sObjectName: cmp.get("v.sObjectName"),
            fieldvalue: cmp.get("v.fieldvalue"),
            fieldreturnval: cmp.get("v.fieldreturnval"),
            location: cmp.get("v.location"),
            tubesegment: cmp.get("v.tubesegment")
        });

		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
        		cmp.set("v.valuesmap", actionResult.getReturnValue());
        		//this.getmessage(cmp);
        		cmp.set("v.messageresult", '');
            } else {
                console.log('AN ERROR OCCURED getmessagevalueinfo ' + state);
            }          
		});
		$A.enqueueAction(action);		
	},
	/*
	getmessage : function(cmp) {
		var mapv = cmp.get("v.valuesmap");
		var val = cmp.get("v.value");
		var returnval = (mapv[val])?mapv[val]:'';
        cmp.set("v.messageresult", returnval);
	},*/
	
})