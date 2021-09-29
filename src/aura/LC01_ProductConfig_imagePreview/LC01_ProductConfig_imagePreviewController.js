({
    init : function(cmp, event, helper) {
        // init action
        // call getProduct 
        //helper.getProduct(cmp);

		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        // try get product image if empty
        var qli = cmp.get("v.qli");
        if(qli.Product_Final_Look__c == null ){
            helper.refreshProductImage(cmp)
	        helper.refreshQuoteItem(cmp);     
            
        }else{
            //
        }
        cmp.set("v.showProductImg", true);
        }
    },
    
    refreshProductImg : function(cmp, event, helper) {
        // show loading wheel
        cmp.set("v.showProductImg", false);
        cmp.set("v.errorMessage", '');
        var refreshBtn = cmp.find("refreshBtn");
        refreshBtn.set("v.disabled", true);
        // call getProduct 
        helper.refreshProductImage(cmp)
        helper.refreshQuoteItem(cmp);
    }
})