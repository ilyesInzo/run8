({
	displayOtherMOQ : function(component, event, priceRecos, otherMoq) {
        
        component.set("v.othermoqDisplay", false);
        //component.set("v.othermoqdisabledLin3", true); 
        //component.set("v.othermoqMaxThreshold", true); 
        for (i=0; i < priceRecos.length; i++) {
            if(otherMoq >= priceRecos[i].moq){
               component.set("v.othermoqDisplay", priceRecos[i].display);
               component.set("v.othermoqdisabledLin3", priceRecos[i].disabledLin3); 
               component.set("v.othermoqMaxThreshold", priceRecos[i].disabledMaxThreshold); 
            }		
        }
 
},
    
    getQuoteType : function(component){
        var qliId = component.get("v.qliId");
        var action = component.get("c.getQLIRecord");
        
        action.setParams({
            qliId : qliId
        });
        
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	console.log(state);
            if(state === "SUCCESS"){
                
            	var qliResponse = response.getReturnValue();
                console.log(qliResponse); 
                component.set("v.isSimulation" ,(qliResponse.Quote.Status == 'Simulation'));
                
           }
        });
        $A.enqueueAction(action);    
    },
    
	getExistingPriceRecohelper : function(component, event) {
        console.log("LC01_PriceRecommendation:getExistingPriceRecommendation ");
        var priceRecoDiv = component.find('priceRecoDiv');
        //$A.util.addClass(priceRecoDiv, "hide");
        var qliId = component.get("v.qliId");
        var qli = component.get("v.qli");
		var otherMOQFound = false;
        console.log(qliId);
        console.log(qli);
        var action = component.get("c.getExistingPriceRecommendation");
        action.setParams({
            qliId : qliId
        });
        action.setCallback(this, function(response) {
        	console.log("PriceReco", response.getReturnValue());
        	console.log('GET COMPONENT RESPONSE.....');
        	console.log(response.getReturnValue());  
            
           // var priceRecos = response.getReturnValue();
            var priceRecos = response.getReturnValue().priceReco;
            console.log('Price Reco');
            var priceRecoDiv = component.find('priceRecoDiv');
            if (priceRecos == null || priceRecos.length == 0) {
                console.log('An unexpected error has occured while loading Price Reco Table..'); 
                component.set("v.priceRecoData", response.getReturnValue());
            } else if (priceRecos != null && priceRecos.length == 1) {
                console.log(priceRecos[0].errorMessage);                
                $A.util.addClass(priceRecoDiv, "hide");
				var toastEvent = $A.get("e.force:showToast");
	    			toastEvent.setParams({
	        		"title": "Calculating Price Recommendation Error!",
                    "type" : "error",
	        		"message": priceRecos[0].errorMessage
	   			});
	    		toastEvent.fire();                
                component.set("v.priceRecoData", response.getReturnValue());
            } else {
                console.log();
                $A.util.removeClass(priceRecoDiv, "hide");
                var priceRecosWithoutOtherMOQ = new Array();
                var index= 0; 
                
                console.log('We get the Other MOQ HEREdd');				
                       
                
                
                for (i=0; i < priceRecos.length; i++) {
                    console.log(priceRecos[i]);
                    console.log(priceRecos[i].otherMoq);
                    
                    if (priceRecos[i].otherMoq >0  
                    || ( priceRecos[i].otherMoq == 0 && priceRecos[i].moq == 999 )
                    ) {
                    	if (otherMOQFound== true ) continue ;
                       
                       otherMOQFound = true;
                       console.log('We get the Other MOQ HERE');				
                       component.set("v.othermoqpriceReco", priceRecos[i]); 
                       component.set("v.othermoqValue", priceRecos[i].otherMoq == 0 ? null : priceRecos[i].otherMoq ); 
                       component.set("v.othermoqTGValue", priceRecos[i].tgValue); 
                       component.set("v.othermoqMinValue", priceRecos[i].minThreshHoldPriceValue); 
                       component.set("v.othermoqLin1Value", priceRecos[i].lin1PriceValue); 
                       component.set("v.othermoqLin2Value", priceRecos[i].lin2PriceValue); 
                       component.set("v.othermoqLin3Value", priceRecos[i].lin3PriceValue); 
                       component.set("v.othermoqMaxValue", priceRecos[i].maxThreshHoldPriceValue); 
                       /*
                       component.set("v.othermoqDisplay", priceRecos[i].display); */
                      // component.set("v.othermoqdisabledLin3", priceRecos[i].disabledLin3); 
                       //component.set("v.othermoqMaxThreshold", priceRecos[i].disabledMaxThreshold);    
                                          
                        console.log(component.get("v.othermoqdisabledLin3"));                   
                       console.log( component.get("v.othermoqMaxThreshold"));    
                                              
                        console.log('We get the Other MOQ HERE');
                    } else /*if( priceRecos[i].moq != 999 )*/{
                       priceRecosWithoutOtherMOQ[index] = priceRecos[i];
                       /*component.set("v.othermoqMinValue", "  "); 
                       component.set("v.othermoqLin1Value", "  "); 
                       component.set("v.othermoqLin2Value", "  "); 
                       component.set("v.othermoqLin3Value", "  "); 
                       component.set("v.othermoqMaxValue", "  "); */

                        index++;
                    }
                }  
                component.set("v.priceRecoData", priceRecosWithoutOtherMOQ);
                component.set("v.moqPrices", response.getReturnValue().prices);
                
                //this.displayOtherMOQ(component, event, priceRecos, component.get("v.othermoqValue"));
                
                //added by maryem QADA to refresh section 6 if quantity is changed in section 2
                var somme = 0;
                var state = response.getState();
                console.log('@@qama=== '+state);
                if( response.getReturnValue().prices != undefined){
                	for(var z =0 ; z< response.getReturnValue().prices.length;z++){
		            	somme = somme + response.getReturnValue().prices[z].List_Price__c ;
		            }
		            
		            if(otherMOQFound == false){
		                  component.set("v.othermoqValue", 0);
                      component.set("v.othermoqTGValue", 0); 
                      component.set("v.othermoqMinValue", 0); 
                      component.set("v.othermoqLin1Value", 0); 
                      component.set("v.othermoqLin2Value", 0); 
                      component.set("v.othermoqLin3Value", 0); 
                      component.set("v.othermoqMaxValue", 0);
		            }
		            console.log('@@qama====1 somme '+somme);
		            if (state === "SUCCESS" /*&& somme >0*/) {
		            	 console.log('@@qama===2 '+state);
		            	 $A.get("e.c:LE00_FinalPrices").fire();	 
		            }
                }
	             
                
                
               // $A.get('e.force:refreshView').fire(); // added by maryem qada 27/12/2017 to get last calculated values of REco records'
            }          
            
        	console.log('OTHER MOQ LOADED=======');
            console.log(component.get("v.othermoqpriceReco"));
            console.log('MOQ PRICES=======');
             console.log(component.get("v.moqPrices"));
        	console.log('=======OTHER MOQ LOADED');
             
        });
        $A.enqueueAction(action);	 
	},
	
	displayFormattedError : function(component, event,response,messageType) {
				var errors = response.getError();
                var message = '';
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                        	if(!message.includes(errors[i].pageErrors[j].message))
                        		message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                	if(!message.includes(thisFieldError[j].message))
                                		message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                        	if(!message.includes(errors[i].message))
                        		message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                }                       
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    type : messageType
                });
                toastEvent.fire();
	}
})