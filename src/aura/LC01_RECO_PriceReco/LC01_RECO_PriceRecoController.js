({
        getPriceReco : function(component, event, helper) {
        console.log("LC01_PriceRecommendation:getPriceReco ");
        var priceRecoDiv = component.find('priceRecoDiv');
        $A.util.addClass(priceRecoDiv, "hide");
        //On Init, retrieve coresponding MOQ Pricing Details
        var qliId = component.get("v.qliId");
        
        console.log("------ Q L I ------");
        console.log(component.get("v.qli"));
         
        var action = component.get("c.getPriceRecommendation");
        action.setParams({
            qliId : qliId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	if(state === "SUCCESS"){
        		console.log("PriceReco", response.getReturnValue());   
	        	console.log('GET COMPONENT RESPONSE.....');
	        	console.log(response.getReturnValue());  
	            
	            
	            var priceRecos = response.getReturnValue().priceReco;
	            
	                         
	            console.log('Price Reco');
	            var priceRecoDiv = component.find('priceRecoDiv');
	            if (priceRecos == null || priceRecos.length == 0) {
	                console.log('An unexpected error has occured while loading Price Reco Table..');  
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
	                
	            } else {
	                console.log();
	                $A.util.removeClass(priceRecoDiv, "hide");
	                for (i=0; i < priceRecos.length; i++) {
	                    if (priceRecos[i].otherMoq > 0) {
	                    	console.log('---------------------------');
	                    	console.log(priceRecos[i]);
	                       component.set("v.othermoqpriceReco", priceRecos[i]); 
	                       component.set("v.othermoqValue", priceRecos[i].otherMoq);
	                    }
	                }	                
	            }          
	        	component.set("v.priceRecoData", priceRecos);
	            component.set("v.moqPrices", response.getReturnValue().prices);
	            helper.getExistingPriceRecohelper(component, event);     
        		
        	}//end if success
        	else {        		
                helper.displayFormattedError(component, event,response,"error"); 
                 $A.get('e.force:refreshView').fire();       	
        	}//end else success
                 
        });
        $A.enqueueAction(action);	 
	},
    
	getExistingPriceReco : function(component, event, helper) {        
       helper.getExistingPriceRecohelper(component, event); 
       helper.getQuoteType(component); 
	},        

	processOtherMOQ : function(component, event, helper) {
      
        console.log('@@qama dans process.....');
        
        var newValue = 0;
        if(component.get("v.othermoqValue") !=null)
        	newValue = component.get("v.othermoqValue") ;
        	
      //  if(component.get("v.othermoqValue") !=null){ 
        	console.log('@@qama dans process ..... v.othermoqValue > 0');
        	var action = component.get("c.insertOtherMOQWithCalcul");
            console.log('@@qama dans process..... newValue '+newValue);
            action.setParams({
			//	otherMOQ :  component.get("v.othermoqValue").toString(),
            	otherMOQ :  newValue.toString(),
				qliId: component.get("v.qliId")
			});
			
			action.setCallback(this, function(response) {
				var state = response.getState();
				console.log('@@qama response ');
				console.log(response);
				
				if (state === "SUCCESS") {
					var priceReco = response.getReturnValue();	
					
					console.log('@@qama resp srvr ');
					console.log(priceReco);
					component.set("v.othermoqTGValue", priceReco.tgValue); 
					component.set("v.othermoqMinValue", priceReco.minThreshHoldPriceValue); 
					component.set("v.othermoqLin1Value", priceReco.lin1PriceValue ); 
					component.set("v.othermoqLin2Value", priceReco.lin2PriceValue); 
					component.set("v.othermoqLin3Value", priceReco.lin3PriceValue); 
					component.set("v.othermoqMaxValue", priceReco.maxThreshHoldPriceValue);
					
					//added by maryem for scoring
					component.set("v.othermoqdisabledLin3 ", priceReco.disabledLin3 );                 
					component.set("v.othermoqMaxThreshold ", priceReco.disabledMaxThreshold ); 
					
					console.log('@@@@@@@@@@@@@@@  qli');
					console.log( component.get("qli"));   
					
					helper.getExistingPriceRecohelper(component, event);    
					//helper.displayOtherMOQ(component, event, priceRecos, component.get("v.othermoqValue"));			
				}else{
					/*var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						message: "Please check Other MOQ value. Failed to GET response from server while loading RECOs.",
						type : "error"
					});
					toastEvent.fire();*/
					helper.displayFormattedError(component, event,response,"info"); 
				}//end else call to server failed
				
								
			}); //end call to action
			
			$A.enqueueAction(action); 
		//}//end if moq >0
          
        /*console.log('processing  Other MOQ...');
    	var otherMOQ = component.get("v.othermoqValue");      
        var priceRecos = component.get('v.priceRecoData');
        
        //The first one is always the discount...
        var discountReco = priceRecos[0];     
        
        var sampleReco = priceRecos[1];
               
        var moqPrices = component.get('v.moqPrices');
        moqPrices = (moqPrices)?moqPrices:[];
        console.log('MOQ PRICES START...');
        console.log(moqPrices);
        console.log('MOQ PRICES END...');
        if (otherMOQ > 0) {
            var greatestMOQ = null;
            var otheMOQFound = false;
            var moqToInsert = null;
           
           for (var i=1; i < priceRecos.length; i++) {
                console.log(priceRecos[i]);
                var moq = priceRecos[i].moq;
                console.log(moq);
                if (moq != undefined && moq != '' && moq != ' - ') {
                    greatestMOQ = priceRecos[i]; 
                    moqToInsert = moqPrices[i];
                    if (moq > otherMOQ) {
                        if (i >= 1) {                        
                            moqToInsert = priceRecos[i-1];
                            otheMOQFound = true;
                        } else {
                           moqToInsert = priceRecos[i]; 
                           otheMOQFound = true;
                        }
                        break; 
                    }
                }
            }
                       
            
            if (!otheMOQFound) {
                component.set("v.othermoqpriceReco", greatestMOQ);
                moqToInsert = greatestMOQ;
            } 
            
            //Get the Price from the MOQ on MOQ Insert           

           if (moqToInsert != null) {
        	   sampleReco=moqTort;
               
                component.set("v.othermoqTGValue", sampleReco.tgValue); 
            	component.set("v.othermoqMinValue", sampleReco.minThreshHoldPriceValue); 
            	component.set("v.othermoqLin1Value", sampleReco.lin1PriceValue ); 
            	component.set("v.othermoqLin2Value", sampleReco.lin2PriceValue); 
            	component.set("v.othermoqLin3Value", sampleReco.lin3PriceValue); 
            	component.set("v.othermoqMaxValue", sampleReco.maxThreshHoldPriceValue);  
                
               
                helper.displayOtherMOQ(component, event, priceRecos, component.get("v.othermoqValue"));
           } 
           
           // moqToInsert.moq = otherMOQ;
            console.log('Other MOQ SELECTED.....');
            console.log(sampleReco);
            var action = component.get("c.insertOtherMOQ");
           
            action.setParams({
                otherMOQ : otherMOQ,
                otherMOQJSON: $A.util.json.encode(sampleReco)
            });
            console.log(action); 
            action.setCallback(this, function(response) {
                console.log("PriceReco=", response.getReturnValue());
                console.log('GET COMPONENT RESPONSE.....');
                console.log(response.getReturnValue());              
                //var priceRecos = response.getReturnValue();
                console.log('Price Reco');
                            
            });
            $A.enqueueAction(action);	 
            
        }      
         
     */   
    },
    newPopup: function (component, event , helper){
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        console.log('The msg is ',window.location.search.substring(1) + ' | '+sPageURL);
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
       
   
    },
  sendEmailBTN  : function(component, event, helper){
   //console.log('The msg is ',component.get('v.msg') + ' | '+component.get("v.pageReference"));
   
   var actionmail = component.get("c.sendEmail");
            
            actionmail.setParams({
				message: component.get("v.msg"),
                qliId : component.get("v.qli").Id
			});
			
			actionmail.setCallback(this, function(response) {
				var state = response.getState();
				
				if (state === "SUCCESS") {
					console.log('SUCCESS ' );//+ response.getReturnValue()
				}else{
					console.log('NOT SUCCESS');
				}//end else call to server failed
				
								
			}); //end call to action
			
			$A.enqueueAction(actionmail);
            component.set('v.msg','');
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
   
  },
    cancel : function(component, event, helper){
        component.set('v.msg','');
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    openProductDetailPage: function(component, event, helper) {
        
        var qli = component.get("v.qli");
        console.log("--- qli---"+qli.Id);
    	var productSubSegment = qli.Product_Sub_segment__c;
        console.log("--- productSubSegment ---", productSubSegment);
        var location = (qli.Location__c == '' || qli.Location__c == null )? 'EU' : qli.Location__c;
        console.log("--- location ---", location);
        var pageComponentName = "";        
        
        switch (productSubSegment) {
            case "Plastic Tubes":
                if(location == 'EU' && qli.Purefoil_Segment__c == true){
                    pageComponentName = "c:LC01_Detail_" + location + "_TubePurefoil";
                }else{
                    pageComponentName = "c:LC01_Detail_" + location + "_TubePlastic";   
                }
                break;
            case "Laminate Tubes":
                pageComponentName = "c:LC01_Detail_" + location + "_TubeLaminate";
                break; 
            case "Foam pumps":
                pageComponentName = "c:LC01_Detail_" + location + "_DispensingFoam";
                break;
            case "Fine mist pumps":
                pageComponentName = "c:LC01_Detail_" + location + "_DispensingFineMist";
                break;
            case "Lotion pumps":
                pageComponentName = "c:LC01_Detail_" + location + "_DispensingLotion";
                break;
            case "Sampler pumps":
                pageComponentName = "c:LC01_Detail_" + location + "_DispensingSampler";
                break;
            default: 
                alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
        }
        
        console.log("--- pageComponentName ---", pageComponentName); 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : pageComponentName,
            componentAttributes: {
                qliId : component.get("v.qli").Id,
		        displayalert : true
            }
        });
        evt.fire();
    }
    
})