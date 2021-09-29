({
    getmoqprice : function(cmp, event) {
        if(cmp.get("v.selectedConfig").Id && cmp.get("v.qli").Id){ 

            var trPrices = cmp.find("trPrices");
            $A.util.toggleClass(trPrices, 'listprice');
            
            var action = cmp.get("c.getsObjectList");
            var selectedConfigType = cmp.get("v.selectedConfigType");
            var mapfilters = {
                'Quote_item__c' : cmp.get("v.qli").Id
            }
            mapfilters[selectedConfigType] = cmp.get("v.selectedConfig").Id ;
            //console.log('******selectedConfigType*******' + selectedConfigType);
            //console.log('******Header mapfilters*******' + mapfilters['PM_Selected_Tubes_Config__c']);
            
            action.setParams({
                objectname : "PM_MOQ_price__c",
                mapfilters : mapfilters,
                orderby : 'MOQ_Min__c'
            });
            //console.log("********* PriceTable -> getmoqprice Call********** v.selectedConfig = ", JSON.stringify(cmp.get("v.selectedConfig")));
            //console.log("********* PriceTable -> getmoqprice Call********** action.getParams() = ", JSON.stringify(action.getParams()));
            action.setCallback(this, function(response) {
                var state = response.getState();
                //console.log("********* PriceTable -> getmoqprice ********** state = ", state);
                var respVal = response.getReturnValue();
                if (state === "SUCCESS") { 

                    //console.log("********* PriceTable -> getmoqprice SUCCESS********** respVal: ", respVal);
                    cmp.set("v.moqpricelst", respVal);
                    console.log("mooooq");
                    console.log(cmp.get("v.moqpricelst"));
                    $A.util.toggleClass(trPrices, 'listprice');
                } else {
	                console.log('AN ERROR OCCURED' + state);
                    //console.log("********* PriceTable -> getmoqprice ERROR********** respVal", JSON.stringify(respVal));
                } 
                
            });
            $A.enqueueAction(action);
        }  
    }
})