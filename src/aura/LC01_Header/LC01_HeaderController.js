({
    init : function(cmp, event, helper) {
    },
    gotoCustomerScoringPage : function(cmp, event, helper) {
        if(cmp.get("v.qli").Id){
        var cmpqli = cmp.get("v.qli");
        var cmpdef = "c:LC01_CustomerScorings_";
        cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmpdef,
            componentAttributes: {
                qliId : cmpqli.Id
            }
        });
        evt.fire();
        }

        
    },
   
    gotoDealScoringPage : function(cmp, event, helper) {
        var pageName = cmp.get("v.pageName"); 
        
        if (pageName === "Service Scoring" ){
             
             spinner = cmp.find("mySpinner2");
             $A.util.addClass(spinner, "slds-hide");
                    if(cmp.get("v.qli").Id){
                        if(cmp.get("v.scorevalidation") == true){
                            var cmpqli = cmp.get("v.qli");
                            var cmpdef = "c:LC01_DealScoring_";
                            cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
                            
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : cmpdef,
                                componentAttributes: {
                                    qliId : cmpqli.Id
                                }
                            });
                            evt.fire();
                            }
                            else{
                                alert("Please finish Customer Scoring before going to the Deal Scoring");
                            }
                    }
        }else{
            if(cmp.get("v.qli").Id){
                 if(cmp.get("v.scorevalidation") == true){
                        var spinner = cmp.find("mySpinner2");
                        $A.util.removeClass(spinner, "slds-hide");
                        var action = cmp.get("c.calculatescore");
                            action.setParams({
                                qli : cmp.get("v.qli")
                            });
                            action.setCallback(this, function(actionResult) {
                                //---------------------
                                spinner = cmp.find("mySpinner2");
                                $A.util.addClass(spinner, "slds-hide");
                                var cmpqli = cmp.get("v.qli");
                                var cmpdef = "c:LC01_DealScoring_";
                                cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
                                        
                                var evt = $A.get("e.force:navigateToComponent");
                                evt.setParams({
                                            componentDef : cmpdef,
                                            componentAttributes: {
                                                qliId : cmpqli.Id
                                            }
                                });
                                evt.fire();
                                        
                                
                                //------------------------
                                var state = actionResult.getState();
                                if (state === "SUCCESS") {
                                    cmp.set("v.qli", actionResult.getReturnValue());    
                                    console.log('Customer Scoring SAVE Success');                   
                                } else {
                                        console.log('AN ERROR OCCURED' + state);
                                        if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                    message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                                    type : "error"
                                                });
                                            toastEvent.fire();
                                            console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                            $A.get('e.force:refreshView').fire();
                                        }
                                }   

                            });
                    $A.enqueueAction(action);
                 }
                 else{
                                alert("Please finish Customer Scoring before going to the Deal Scoring");
                 }
            }
           
        }
        
    },
    
    gotoServiceScoringPage: function(cmp, event, helper) {
        if(cmp.get("v.qli").Id){
            if(cmp.get("v.scorevalidation") == true){
                 var spinner = cmp.find("mySpinner2");
                $A.util.removeClass(spinner, "slds-hide");
                var action = cmp.get("c.calculatedealscore");
                action.setParams({
                    qli : cmp.get("v.qli")
                });
                action.setCallback(this, function(actionResult) {
                    //---------------------
                    
                            var cmpqli = cmp.get("v.qli");
                            var cmpdef = "c:LC01_ServiceScoring_";
                            cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
                            
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : cmpdef,
                                componentAttributes: {
                                    qliId : cmpqli.Id
                                }
                            });
                            evt.fire();
                        
                    //------------------------
                    var state = actionResult.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.qli", actionResult.getReturnValue());    
                        console.log('Customer Scoring SAVE Success');                   
                    } else {
                            console.log('AN ERROR OCCURED' + state);
                            if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                $A.get('e.force:refreshView').fire();
                            }
                    }   

                });
              $A.enqueueAction(action);
           }
           else{
                alert("Please finish Deal Scoring before going to the Service Scoring");
         }
        }
        
    },
    gotoRecoPage: function(cmp, event, helper) {
        var spinner = cmp.find("mySpinner2");
        $A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.calculateservicescore");
                action.setParams({
                    qli : cmp.get("v.qli")
                });
                action.setCallback(this, function(actionResult) {
                    //---------------------
                    if(cmp.get("v.qli").Id){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:LC01_RECO",
                        componentAttributes: {
                            qliId : cmp.get("v.qli").Id
                        }
                    });
                    evt.fire();
                    }
                    //------------------------
                    var state = actionResult.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.qli", actionResult.getReturnValue());    
                        console.log('Customer Scoring SAVE Success'); 
                        // 2 Lines added by Achraf LAMZABI
                        if(cmp.get("v.pagename") == 'Service Scoring'){
                            $A.get("e.c:LE00_PriceReco").fire();
                        }
                    } else {
                            console.log('AN ERROR OCCURED' + state);
                            if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                $A.get('e.force:refreshView').fire();
                            }
                    }   

                });
        $A.enqueueAction(action);
        
        
    },
    gotoHomePage: function(cmp, event, helper) {
        if(cmp.get("v.qli").Id){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC01_Home",
            componentAttributes: {
                qliId : cmp.get("v.qli.Id")
            }
        });
        evt.fire();
        }
    },
    backToQuoteLineItemDetailsPage: function(cmp, event, helper) {
    
        if(cmp.get("v.qli").Id){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.qli.Id"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        }
    },
    gotoServiceTubeConfig: function(cmp, event, helper) {
         var spinner = cmp.find("mySpinner2");
        $A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.calculatescore");
                action.setParams({
                    qli : cmp.get("v.qli")
                });
                action.setCallback(this, function(actionResult) {
                    //---------------------
                   if(cmp.get("v.qli").Id){
                    var _pageName = cmp.get("v.pageName");
                    var _component;
                    if(_pageName == 'Product Configuration: Plastic Tube'){
                        _component = 'c:LC01_ServiceTubeConfig';
                    }else if(_pageName == 'Product Configuration: Foam'){
                        _component = 'c:LC01_ServiceTubeConfig';
                    }
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:LC01_ServiceTubeConfig",
                        componentAttributes: {
                            qliId : cmp.get("v.qli").Id
                        }
                    });
                    evt.fire();
                    }
                    //------------------------
                    var state = actionResult.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.qli", actionResult.getReturnValue());    
                        console.log('Customer Scoring SAVE Success');                   
                    } else {
                            console.log('AN ERROR OCCURED' + state);
                            if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                $A.get('e.force:refreshView').fire();
                            }
                    }   

                });
        $A.enqueueAction(action);
        
        
    },
    backToProductConfig: function(cmp, event, helper) {
    
        if(cmp.get("v.qli").Id){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC01_ProductConfig_EU_TubePlastic",
            componentAttributes: {
                qliId : cmp.get("v.qli").Id
            }
        });
        evt.fire();
        }
    },
    gotoServiceTubeDetails : function(cmp, event, helper) {
        
        if(cmp.get("v.qli").Id){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC01_ServiceTubeDetails",
            componentAttributes: {
                qliId : cmp.get("v.qli").Id
            }
        });
        evt.fire();
        }
    },
    gotoServiceDispensingDetails : function(cmp, event, helper) {
        
        if(cmp.get("v.qli").Id){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC01_ServiceDispensing_EU_FoamPump",
            componentAttributes: {
                qliId : cmp.get("v.qli").Id
            }
        });
        evt.fire();
        }
    },
    openQuotePDFTemplatePDF : function(cmp, event, helper) {
        /*
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC00_QuotePDFPreview",
            componentAttributes: {
                quoteId : cmp.get("v.qli"),
                quoteTemplateId : cmp.get("v.qli")
            }
        });
        evt.fire();
        */ 
        // //Create the PDF viewer component
        
        if(cmp.get("v.qli").Id){
        var qli = cmp.get("v.qli");

        
        $A.createComponent(
            "c:LC00_QuotePDFPreview",
            {
                qli : qli
            },
            function(pdfViewer, status, errorMessage){
                if (status === "SUCCESS") {
                    var pdfContainer = cmp.get("v.pdfContainer");
                    pdfContainer.push(pdfViewer);
                    cmp.set("v.pdfContainer", pdfContainer);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    throw new Error("No response from server or client is offline.");
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        throw new Error("Error: " + errorMessage);
                    }
            }
        );
        }
    }
})