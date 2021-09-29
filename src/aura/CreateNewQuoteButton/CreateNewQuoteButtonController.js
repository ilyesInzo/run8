({
    newRecord: function(component, event, helper) {
        var recordId = component.get("v.recordId");

        var simpleRecord = component.get("v.simpleRecord");
        //alert(simpleRecord.Name);
        // component.set("v.record", { Name: simpleRecord.Name });

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            entityApiName: "Quote",
            defaultFieldValues: {
                OpportunityId: "" + recordId,
                Name: simpleRecord.Name,
                AccountId: simpleRecord.AccountId

            }
        });
        createRecordEvent.fire();
    }
});