({
	gotoRecoPage: function(cmp, event, helper) {
	 console.log(cmp.get("v.selectedconfig"));
	 var name = cmp.get("v.selectedconfig").Name;
	  //console.log(cmp.get("v.selectedconfig").Id+'name'+name);
	 if(cmp.get("v.selectedconfig").Product_segment__c == undefined && name ==undefined ){
         console.log('IN Toast'+ cmp.get("v.selectedconfig").Product_segment__c);
		 var toastEventWarning = $A.get("e.force:showToast");
		 toastEventWarning.setParams({
							        message: "Please wait until the page is fully loaded!",
							        type : "warning"
							    });
		 toastEventWarning.fire();	  
		 return;
	 }
	
	 //dont go to reco until the Tube length is filled if the diptube Material (Fine mist) is Invisible or Transparent TPX
	 if(name != undefined && (name.indexOf('SDC') != -1  
		&& (	cmp.get("v.selectedconfig").Diptube_Material__c == 'Optional (Invisible)' 
				||  cmp.get("v.selectedconfig").Diptube_Material__c == 'Optionnal (Invisible)'
				||  cmp.get("v.selectedconfig").Diptube_Material__c == 'Optionnal (Transparent TPX)'
				||  cmp.get("v.selectedconfig").Diptube_Material__c == 'Optional (Transparent TPX)' 
			)
	 	&& (	cmp.get("v.selectedconfig").Diptube_Length__c == undefined 
	 			|| cmp.get("v.selectedconfig").Diptube_Length__c == null 
	 			|| cmp.get("v.selectedconfig").Diptube_Length__c == '' 
	 			|| cmp.get("v.selectedconfig").Diptube_Length__c == ' '
	 			|| cmp.get("v.selectedconfig").Diptube_Length__c == '0'
	 		)	 	
	 	&&( 	cmp.get("v.selectedconfig").Diptube_length_mm__c == undefined 
	 			|| cmp.get("v.selectedconfig").Diptube_length_mm__c == null 
	 			|| cmp.get("v.selectedconfig").Diptube_length_mm__c == '' 
	 			|| cmp.get("v.selectedconfig").Diptube_length_mm__c == ' '
	 			|| cmp.get("v.selectedconfig").Diptube_length_mm__c == '0'
	 		)	
	 	&&( 	cmp.get("v.selectedconfig").Diptube_Material_length_mm__c == undefined 
	 			|| cmp.get("v.selectedconfig").Diptube_Material_length_mm__c == null 
	 			|| cmp.get("v.selectedconfig").Diptube_Material_length_mm__c == '' 
	 			|| cmp.get("v.selectedconfig").Diptube_Material_length_mm__c == ' '
	 			|| cmp.get("v.selectedconfig").Diptube_Material_length_mm__c == '0'	)	)){
		 var toastEventWarning2 = $A.get("e.force:showToast");
			 toastEventWarning2.setParams({
							        message: "Please fill the Diptube Material length to calculate the upcharge.",
							        type : "warning"
							    });
			 toastEventWarning2.fire();
			return;
	 }
	  
	//dont pass to reco until the cap eurocode is filled
	if( cmp.get("v.selectedconfig").Product_segment__c != undefined && (cmp.get("v.selectedconfig").Product_segment__c.toString().indexOf('Tubes') !=-1 //name.indexOf('STC') != -1 
		&& cmp.get("v.selectedconfig").Cap_Eurocode__c != undefined 
		&& cmp.get("v.selectedconfig").Cap_Eurocode__c != null 
		&& cmp.get("v.selectedconfig").Cap_Eurocode__c != '' 
		&& cmp.get("v.selectedconfig").Cap_Eurocode__c != ' ') 
		||
		cmp.get("v.selectedconfig").Cap_Name__c =='No cap'
		||(name != undefined && name.indexOf('STC') == -1)//cmp.get("v.selectedconfig").Product_segment__c.toString().indexOf('Tubes') ==-1  //(name.indexOf('STC') == -1)
      )
    {
	
			if(cmp.get("v.selectedconfig").Id && cmp.get("v.qli").Id){
				if(confirm('Do you want to save the changes?')){
					$A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
					var action = cmp.get("c.saveSelectedConfig");
					action.setParams({
						so : cmp.get("v.selectedconfig")
					});
					action.setCallback(this, function(actionResult) {
						if (actionResult.getState() === "SUCCESS") {
							
				            	var toastEvent = $A.get("e.force:showToast");
							    toastEvent.setParams({
							        message: "Product Configuration was saved successfully.",
							        type : "success"
							    });
							    toastEvent.fire();
							
							
					        var evt = $A.get("e.force:navigateToComponent");
					        evt.setParams({
					            componentDef : "c:LC01_RECO",
					            componentAttributes: {
					                qliId : cmp.get("v.qli").Id
					            }
					        });
					        evt.fire();
			        
							
						} else {
							$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
						    var toastEvent = $A.get("e.force:showToast");
						    toastEvent.setParams({
						        message: "Failed to save Product Configuration.",
						        type : "error"
						    });
						    toastEvent.fire();
							console.log('AN ERROR OCCURED saveSelectedConfig ' + actionResult.getState());
						}	            
					});
					$A.enqueueAction(action); 
				}
				else{
				
					        var evt = $A.get("e.force:navigateToComponent");
					        evt.setParams({
					            componentDef : "c:LC01_RECO",
					            componentAttributes: {
					                qliId : cmp.get("v.qli").Id
					            }
					        });
					        evt.fire();
				}
			}
	
		}//end if cap eurocode is blank
		else{
			 var toastEventWarning2 = $A.get("e.force:showToast");
			 toastEventWarning2.setParams({
							        message: "Please fill the Cap Eurocode before passing to the next step !",
							        type : "warning"
							    });
			 toastEventWarning2.fire();	 
		}	
		
    },
    gotoServiceTubeConfig: function(cmp, event, helper) {
    
		if(cmp.get("v.selectedconfig").Id && cmp.get("v.qli").Id){
		
			if(confirm('Do you want to save the changes?')){
				$A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
				var action = cmp.get("c.saveSelectedConfig");
				action.setParams({
					so : cmp.get("v.selectedconfig")
				});
				action.setCallback(this, function(actionResult) {
					if (actionResult.getState() === "SUCCESS") {
						
			            
		            	var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        message: "Product Configuration was saved successfully.",
					        type : "success"
					    });
					    toastEvent.fire();
						
						
				        if(cmp.get("v.service") == "c:LC01_ServiceTubeConfig"){
				        	if(cmp.get("v.configId")){
						        var evt = $A.get("e.force:navigateToComponent");
						        evt.setParams({
						            componentDef : cmp.get("v.service"),
						            componentAttributes: {
						            	qliId : cmp.get("v.qli").Id,
						                configId : cmp.get("v.configId"),
						                configPageName : cmp.get("v.configPageName")
						            }
						        });
						        evt.fire();
					        }
				        } 
				        else if(cmp.get("v.service")){
				        //if(cmp.get("v.service") == "c:LC01_ServiceDispensing_EU_LotionPump" || cmp.get("v.service") == "c:LC01_ServiceDispensing_US_LotionPump"){
				        	var evt = $A.get("e.force:navigateToComponent");
					        evt.setParams({
					            componentDef : cmp.get("v.service"),
					            componentAttributes: {
						            qliId : cmp.get("v.qli").Id,        
						            configPageName : cmp.get("v.configPageName")
					            }
					        });
					        evt.fire();
				        }
		        
		        
						
					} else {
					
					    var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        message: "Failed to save Product Configuration.",
					        type : "error"
					    });
					    toastEvent.fire();
						$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
						console.log('AN ERROR OCCURED saveSelectedConfig ' + actionResult.getState());
					}	            
				});
				$A.enqueueAction(action); 
			}
			else{
			
				        if(cmp.get("v.service") == "c:LC01_ServiceTubeConfig"){
				        	if(cmp.get("v.configId")){
						        var evt = $A.get("e.force:navigateToComponent");
						        evt.setParams({
						            componentDef : cmp.get("v.service"),
						            componentAttributes: {
						            	qliId : cmp.get("v.qli").Id,
						                configId : cmp.get("v.configId"),
						                configPageName : cmp.get("v.configPageName")
						            }
						        });
						        evt.fire();
					        }
				        } 
				        else if(cmp.get("v.service")){
				        //if(cmp.get("v.service") == "c:LC01_ServiceDispensing_EU_LotionPump" || cmp.get("v.service") == "c:LC01_ServiceDispensing_US_LotionPump"){
				        	var evt = $A.get("e.force:navigateToComponent");
					        evt.setParams({
					            componentDef : cmp.get("v.service"),
					            componentAttributes: {
						            qliId : cmp.get("v.qli").Id,        
						            configPageName : cmp.get("v.configPageName")
					            }
					        });
					        evt.fire();
				        }
			}
		}
    	
    },
    openCombo: function(cmp, event, helper){
    	var appEvent = $A.get("e.c:LE01_Combo");
    	appEvent.fire();
    },
    openLean: function(cmp, event, helper){
    	var appEvent = $A.get("e.c:LE01_Lean");
    	appEvent.fire();
    }
})