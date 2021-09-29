({
    init : function(cmp, event, helper) {

        var action = cmp.get("c.getValues");
        action.setParams({
            objectName : cmp.get("v.objectName"),
            fieldName : cmp.get("v.fieldName"),
            parameters : cmp.get("v.parameters")
        });
        action.setCallback(this, function(response) {
        	var values = response.getReturnValue();
        	var listopts = [''];
        	listopts = listopts.concat(values);
        	cmp.set("v.options", listopts);
        	
        });
        $A.enqueueAction(action);
    }
})