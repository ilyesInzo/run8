({
    init : function(cmp, event, helper) {
        // Get Quote
        console.log("LC01_Home:JsController:Init ");
        
        // get Quote line item
        var action = cmp.get("c.getQuoteItemById");
        action.setParams({
            quoteItemId : cmp.get("v.qliId")+''
        });
        action.setCallback(this, function(response) {
            var _qli = response.getReturnValue();
            console.log("_qli="+JSON.stringify(_qli));
            var _prod = _qli.Product2;
            console.log("_prod="+JSON.stringify(_prod));
            var _quote = _qli.Quote;
            console.log("_quote="+JSON.stringify(_quote));
            var _opp = _quote.Opportunity;
            console.log("_opp="+JSON.stringify(_opp));
            cmp.set("v.qli",_qli);
            cmp.set("v.quo",_quote);
            cmp.set("v.opp",_opp);
            cmp.set("v.prod",_prod);
            
            //calcul product segment
            var _productSegment = (_qli.Purefoil_Segment__c && _qli.Product_Sub_segment__c=='Plastic Tubes' )? 'Purefoil Tubes' : _qli.Product_Sub_segment__c;
            cmp.set("v.productSegment", _productSegment);
            
            // check if information are filled            
            if(_opp.Account.Country__r.Name && 
               _opp.Account.Type &&
               _opp.Account.Name &&
               _opp.KamFullName__c &&
               _qli.Billing_Currency__c &&
               _opp.CloseDate &&
               _quote.Project_TYpe__c &&
               _productSegment &&
               _opp.Name){
                cmp.set("v.enterPricematriX",true);
            }else{
                cmp.set("v.enterPricematriX",false);
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    enterMatrix : function(cmp, event, helper) {
        
        if(cmp.get("v.enterPricematriX")){
            console.log("LC01_Home:JsController:enterMatrix ");
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:LC01_RECO",
                componentAttributes: {
                    qliId : cmp.get("v.qli").Id
                }
            });
            evt.fire();
            
        }else{
            alert("To start your quotation, please fill in key quotation information");   
        }
        
    },
    // TODO: DELETE AFTER finishin RECO comp    
    enterMatrixHasseeb : function(cmp, event, helper) {
        console.log("LC01_Home:JsController:enterMatrix ");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RECO_Hasseeb",
            componentAttributes: {
                qli : cmp.get("v.qli")
            }
        });
        evt.fire();
    },
    // TODO: DELETE AFTER finishin NetpRice  comp  
    enterMatrixChris : function(cmp, event, helper) {
        console.log("LC01_Home:JsController:enterMatrix ");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:RECO_Chris",
            componentAttributes: {
                qli : cmp.get("v.qli")
            }
        });
        evt.fire();
    }
})