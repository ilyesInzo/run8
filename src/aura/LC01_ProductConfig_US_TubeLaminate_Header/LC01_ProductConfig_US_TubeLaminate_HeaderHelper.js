({
    checkEmpty : function(component, auraId, emptyErrorMsg) {
        var inputSelect = component.find(auraId);
        var stockageValue = inputSelect.get("v.value");
        if (stockageValue==='') {
            // Set error
            inputSelect.set("v.errors", [{message: emptyErrorMsg}]);
        } else {
            // Clear error
            inputSelect.set("v.errors", null);
        }
    },
    updateDistanceFromDelivery : function(component, deliveryId, distanceId) {
        var inputSelectDelivery = component.find(deliveryId);
        var inputTextDistance = component.find(distanceId);
        // copy value of 
        inputTextDistance.set("v.value", inputSelectDelivery.get("v.value"));
    }
})