({	
    init : function(component, event, helper) {
     debugger;
		//if(component.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        if(component.get("v.qli").Id ){
            console.log('Init FinalPrice Offer');       
    
        //On Init, retrieve coresponding Final Review Price Details
        var qli = component.get("v.qli.Id");

        var action = component.get("c.getFinalReviewPrices");
        
            action.setParams({
                
                "quoteLineItemId": qli         
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {    
                	debugger;
                    //console.log('Init Final Review Prices ='+response.getReturnValue());
                    //component.set("v.FinalReviewPrices",response.getReturnValue());    
                    component.set("v.FinalReviewPrices",response.getReturnValue().priceRecos); 
                    //console.log('================== configOK '+response.getReturnValue().configOK);
                    component.set("v.configOK",response.getReturnValue().configOK); 
                    component.set("v.productLine",response.getReturnValue().productLine); 
                    component.set("v.location",response.getReturnValue().location); 
                    var status = response.getReturnValue().quoteStatus;
                    if (status != 'Draft' &&  status != 'Presented' && status != 'Simulation')  {
                            component.set("v.closedQuote",true);
                    }

                   
                   
                }
            });
            $A.enqueueAction(action);
         }
      
    },
    pressEnter2: function(cmp, event,helper){
        
        //console.log('---enter ---'+event.getParams().keyCode);
        if(event.getParams().keyCode == 13){
           // console.log('--- next Focus ---'+cmp.find("QP1"));
            cmp.find("QP1").focus();
        }
    },


    CheckId:function (cmp, event,helper){
        
        console.log('--- check ---');
    },

    Hide2:function (cmp, event,helper){
        
        var target = event.srcElement || event.currentTarget || event.target;
		var id = target.id;
		var idInput = id.replace('output','');
       
        console.log('--- ID JS---'+id);
        console.log('--- ID JS---'+id.replace('output',''));
        
        var hideOutput = cmp.find(id);
        var selectedInputNumber = cmp.find(idInput);
              
        $A.util.addClass(hideOutput, 'Hide')
        $A.util.removeClass(selectedInputNumber, 'Hide')
       // selectedInputNumber.focus();
        //selectedInputNumber.select();
        
        console.log('--- Hide ---');
    },
    
    Hide3:function (cmp, event,helper){
      
       var id = event.getSource().getLocalId();
       var idInput = id.replace('output','');
       
       console.log('--- ID JS---'+id);
       console.log('--- ID JS---'+idInput);
       var hideOutput = cmp.find(id);
       var selectedInputNumber = cmp.find(idInput);
       
       $A.util.addClass(hideOutput, 'Hide');
       $A.util.removeClass(selectedInputNumber, 'Hide');
    },
    
    unHide:function (cmp, event,helper){
       
       var id = event.getSource().getLocalId();
       var idoutput = id+'output';
       
       console.log('--- ID JS---'+id);
       console.log('--- ID JS---'+idoutput);
        
       var hideOutput = cmp.find(idoutput);
       var selectedInputNumber = cmp.find(id);
       
       $A.util.removeClass(hideOutput, 'Hide');
       $A.util.addClass(selectedInputNumber, 'Hide');
       console.log('---un Hide ---');
    },
    
    
    pressEnter: function(cmp, event,helper){
    	
        console.log('---enter ---'+event.getParams().keyCode);
        if(event.getParams().keyCode == 13){
            //alert('MOQ 1');
            var inputFieldId = event.getSource().getLocalId();
            console.log('--- Input Id ---'+inputFieldId);
            if(inputFieldId == "MOQ1"){
               cmp.find("QP1").focus();
            }
            if(inputFieldId == "QP1"){
                cmp.find("MOQ2").getElement().focus();
            }
            if(inputFieldId == "MOQ2"){
                cmp.find("QP2").getElement().focus();
            }
            if(inputFieldId == "QP2"){
                cmp.find("MOQ3").getElement().focus();
            }
            if(inputFieldId == "MOQ3"){
                cmp.find("QP3").getElement().focus();
            }
            if(inputFieldId == "QP3"){
                cmp.find("MOQ4").getElement().focus();
            }
            if(inputFieldId == "MOQ4"){
                cmp.find("QP4").getElement().focus();
            }
            if(inputFieldId == "QP4"){
                cmp.find("MOQ5").getElement().focus();
            }
            if(inputFieldId == "MOQ5"){
                cmp.find("QP5").getElement().focus();
            }
            if(inputFieldId == "QP5"){
                cmp.find("MOQ6").getElement().focus();
            }
            if(inputFieldId == "MOQ6"){
                cmp.find("QP6").getElement().focus();
            }
            if(inputFieldId == "QP6"){
                cmp.find("MOQ7").getElement().focus();
            }
            if(inputFieldId == "MOQ7"){
                cmp.find("QP7").getElement().focus();
            }
            if(inputFieldId == "QP7"){
                cmp.find("MOQ1").getElement().focus();
            }
        }
    },
    
    
    changeColour: function(cmp, event,helper){
    
    		//Colour Test
            var table = document.getElementById('tableID');
            var tbody = table.getElementsByTagName('tbody')[0];
            var cells = tbody.getElementsByTagName('td');
            
            for (var i=0, len=cells.length; i<len; i++){
                 //console.log(cells[i].innerHTML);       
                      //  console.log(cells[i].innerHTML.indexOf("Red"));
                      //  console.log(cells[i].innerHTML.indexOf("Yellow"))
            	if (cells[i].innerHTML.indexOf("Red") != -1){
                    console.log('--- Red ---');
                	cells[i].style.color = "#FF0000";
                }
                else if (cells[i].innerHTML.indexOf("Yellow") != -1){
                    console.log('--- Yellow ---');
                    cells[i].style.color = "#FFD700";
                }
                else if (cells[i].innerHTML.indexOf("Grey") != -1){
                    console.log('--- Grey ---');
                    cells[i].style.color = "#A9A9A9";
                }
                else if (cells[i].innerHTML.indexOf("Light Green") != -1){
                    console.log('--- Light Green ---');
                    cells[i].style.color = "#92d050";
                }
                else if (cells[i].innerHTML.indexOf("Dark Green") != -1){
                    console.log('--- Dark Green ---');
                    cells[i].style.color = "#008000";
                }
            }    
	},

    //Added by Arthur Leriche, reprend calcDelta mais avec un toast en plus en cas de succes

    save: function(cmp, event, helper) {
        alert('ici');
        console.log('@@ dans calcdelta success start');
         
        helper.lockBoxes(cmp);   
     
        var finalReviewPrices = cmp.get("v.FinalReviewPrices");
        //console.log(finalReviewPrices);
        //console.log('@@qama avant if '+finalReviewPrices) ;
        //Added by maryem QADA to delete prices if the corresponding mock isnt set
        if(finalReviewPrices != undefined){
        //console.log('@@qama dans if '+finalReviewPrices) ;
            for(var m=0; m<finalReviewPrices.length;m++){
                if(finalReviewPrices[m].MOQ_Units__c <=0 ){
                    finalReviewPrices[m].Quoted_Price__c=  null;
                    finalReviewPrices[m].Selected__c=  null;
                }
                if(finalReviewPrices[m].Quoted_Price__c <=0){
                    finalReviewPrices[m].Selected__c=  null;
                }
              
            }
        } 
        
        
        var action = cmp.get("c.updateFinalReviewPrices");
        
            action.setParams({
                
                "FinalReviewPricesList": finalReviewPrices         
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                    console.log('@@ dans calcdelta success');
                   // console.log('Updated Final Review Prices ='+response.getReturnValue());
                    cmp.set("v.FinalReviewPrices",response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({ 
                        message: "Prices saved",
                        //message: "Failed to save final price. Please review your data!",
                        type : "success"
                    });
                    toastEvent.fire();                                   
                    helper.unlockBoxes(cmp);     
                      
                } 
                else{
                console.log('@@ dans calcdelta error');
                    console.log(response.getError()[0].pageErrors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({ 
                        message: response.getError()[0].pageErrors[0].message,
                        //message: "Failed to save final price. Please review your data!",
                            type : "error"
                        });
                    toastEvent.fire();                 
                    
                    helper.unlockBoxes(cmp);
                     
               }
               
              // $A.get('e.force:refreshView').fire();//!
            }); 
            $A.enqueueAction(action);
    },
    calcDelta0:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 0);
    },
    calcDelta1:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 1);
    },
    calcDelta2:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 2);
    },
    calcDelta3:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 3);
    },
    calcDelta4:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 4);
    },
    calcDelta5:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 5);
    },
    calcDelta6:function(cmp,event,helper){
       helper.calcdeltaX(cmp,event,helper, 6);
    },

    calcDelta: function(cmp, event, helper) {
        
    	console.log('@@ dans calcdelta success start');
    	 
        helper.round(cmp)   //Arthur : If integer -> no change, else -> tofixed(2)
    	//helper.lockBoxes(cmp);	 
	    cmp.set("v.isActive", false);
        //helper.showspinner(cmp);
    	var finalReviewPrices = cmp.get("v.FinalReviewPrices");

       

    	if(finalReviewPrices != undefined){
    	//console.log('@@qama dans if '+finalReviewPrices) ;
    		for(var m=0; m<finalReviewPrices.length;m++){
                if (finalReviewPrices[m].MOQ_Units__c === undefined){
                    finalReviewPrices[m].MOQ_Units__c = null;
                    finalReviewPrices[m].Quoted_Price__c = null;
                    finalReviewPrices[m].Transport_Price__c = null;
                }
	    		
	    	  
	    	}
    	} 
    	
        
        var action = cmp.get("c.updateFinalReviewPrices");
        
            action.setParams({
                
                "FinalReviewPricesList": finalReviewPrices         
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                	console.log('@@ dans calcdelta success');
                   // console.log('Updated Final Review Prices ='+response.getReturnValue());
                   
                   // Malha
                    cmp.set("v.FinalReviewPrices",response.getReturnValue());     
                    cmp.set("v.isActive", true);
                    //helper.hidespinner3(cmp);                           
                    //helper.unlockBoxes(cmp);	
                   
                      
                } 
                else{
                    console.log('@@ dans calcdelta error');
                	console.log(response.getError()[0].pageErrors[0].message);
					var toastEvent = $A.get("e.force:showToast");
					


                    if(!response.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                        toastEvent.setParams({ 
                        message: response.getError()[0].pageErrors[0].message,
                        //message: "Failed to save final price. Please review your data!",
                            type : "error"
                        });
                        toastEvent.fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                              message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                type : "error"
                            });
                        toastEvent.fire();  
                    }


		            cmp.set("v.isActive", true);
                



		             
               }
               
              // $A.get('e.force:refreshView').fire();//!
            }); 
            $A.enqueueAction(action);
         	
    },
    
    hidespinner: function (cmp, event) {
       
        $A.util.addClass(cmp.find("mySpinner"), "slds-hide");

    },
   
    
    onRadioSelect2: function(cmp, event, helper) {
    	//show spinner
	    //$A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
	    helper.lockBoxes(cmp);	 
        var selectedMOQ = event.getSource();
        var finalReviewPrices = cmp.get("v.FinalReviewPrices");
        var i;
        for(i = 0; i<finalReviewPrices.length; i++){
            if(i == event.getSource().getLocalId().substr(2) - 1){
                finalReviewPrices[i].Selected__c = true;
            }
            else{
                finalReviewPrices[i].Selected__c = false;
            }
        }

        cmp.set("v.FinalReviewPrices",finalReviewPrices);
        helper.unlockBoxes(cmp);
        //console.log('Selected Review Price MOQ '+selectedMOQ.get("v.value"));
      //  console.log('Selected Review Price MOQ label  '+selectedMOQ.get("v.label"));
        
        var finalReviewPrices = cmp.get("v.FinalReviewPrices");
        var selectedFinalPriceId = selectedMOQ.get("v.label");
        
       // console.log('selected Id'+selectedFinalPriceId);
        
        var action = cmp.get("c.selectFinalReview");
        
            action.setParams({
                
                "FinalReviewPricesList": finalReviewPrices,
                "finalReviewPriceId":selectedFinalPriceId
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                	
                    //console.log('Updated Final Review Prices ='+response.getReturnValue());
                    cmp.set("v.FinalReviewPrices",response.getReturnValue());
                    
                     helper.unlockBoxes(cmp);
                }else{
                	var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						message: "Failed to save MOQ price. Please review your data!",
					        type : "error"
					    });
					toastEvent.fire();
		            console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                
                }
            });
            $A.enqueueAction(action);
 
	 },
    
    onRadioSelect: function(cmp, event, helper) {

        var selectedMOQ = event.getSource();
        //console.log('Selected column'+selectedMOQ.get("v.label"));
        var selectColumn = selectedMOQ.get("v.label");
        
        var table = cmp.get("v.tableSelectedColumn");
        
        for (var column in table) {
                
            	///console.log('selected column'+selectColumn);
            	//console.log('table column'+table[column].Column);
                if(table[column].Column == selectColumn){
                   table[column].MostProbable = true;
                }else{
                    
                   table[column].MostProbable = false;
                }
            	//console.log(table[column].MostProbable);
            	//console.log(table[column].Column);
        }
        //Set Table Values
        cmp.set("v.tableSelectedColumn",table);
	 },
    
	openReview : function(cmp, event, helper) {
        
        var finalReviewPrices = cmp.get("v.FinalReviewPrices");
        console.log('--- Final Price for review ---'+finalReviewPrices);
        var finalReviewPrice;
        
        var selectedReview = false;
        for(var i in finalReviewPrices){
            
            if(finalReviewPrices[i].Selected__c == true ){
				
				/*console.log('--- Review Price ---'+finalReviewPrices[i].Selected__c);
            	console.log('--- MOQ ---'+finalReviewPrices[i].MOQ_Units__c);
            	console.log('--- Quoted Price ---'+finalReviewPrices[i].Quoted_Price__c);
                */
                finalReviewPrice = finalReviewPrices[i];
                selectedReview = true;
            }
            
        }
        
        if(selectedReview == false){
            
            alert('Please select a valid MOQ and Quoted Price  for Review.');
        
        }else if (selectedReview == true){
            
            //Get Quote Line Item Info
            var qli = cmp.get("v.qli");
            var productSubSegment = qli.Product_Sub_segment__c;
            //console.log("--- productSubSegment ---", productSubSegment);
            var location = (qli.Location__c == '' || qli.Location__c == null )? 'EU' : qli.Location__c;
            //console.log("--- location ---", location);
            var pageComponentName = "";        
            
            switch (productSubSegment) {
                case "Plastic Tubes":
                    if(location == 'EU' && qli.Purefoil_Segment__c == true){
                        pageComponentName = "c:LC01_Review_" + location + "_TubePurefoil";
                    }else{
                        pageComponentName = "c:LC01_Review_" + location + "_Plastic";   
                    }
                    break;
                case "Laminate Tubes":
                    pageComponentName = "c:LC01_Review_" + location + "_TubeLaminate";
                    break; 
                case "Foam pumps":
                    pageComponentName = "c:LC01_Review_" + location + "_DispensingFoam";
                    break;
                case "Fine mist pumps":
                    pageComponentName = "c:LC01_Review_" + location + "_DispensingFineMist";
                    break;
                case "Lotion pumps":
                    pageComponentName = "c:LC01_Review_" + location + "_Lotion";
                    break;
                case "Sampler pumps":
                    pageComponentName = "c:LC01_Review_" + location + "_DispensingSamplers";
                    break;
                default: 
                    alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
            }
            
            //console.log("--- pageComponentName ---", pageComponentName);
            if(pageComponentName != ""){
                       
                var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                
                    componentDef : pageComponentName,
                    componentAttributes: {
                        qliId : cmp.get("v.qli").Id,
                        FinalReviewPrice : finalReviewPrice
                    }
                });           
                evt.fire();
            }
 
        }
    },

    saveResultJS : function(cmp, event, helper) { 
         var action2 = cmp.get("c.saveResult");
         action2.setParams({                      
                        "FinalReviewPricesList": cmp.get("v.FinalReviewPrices")         
         });

          
    
         action2.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {

                  // helper.hidespinner3(cmp);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: response.getError()[0].pageErrors[0].message,
                            type : "error"
                        });
                    toastEvent.fire();
                    console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                
                }
         });  
         $A.enqueueAction(action2); 
		var selectTubeConfigEvent = $A.get("e.c:LE00_NotifySelectedTubeConfig");
						        selectTubeConfigEvent.setParams({
						            "NetPrice" : cmp.get("v.FinalReviewPrices") });
						 selectTubeConfigEvent.fire(); 
         helper.showspinner(cmp);  
         window.setTimeout(function(){  
           
            //helper.hidespinner3(cmp);
            $A.util.addClass(cmp.find("mySpinner3"), "slds-hide");
            cmp.set("v.displayPopup", true);

            window.setTimeout(function(){ 
                cmp.set("v.displayPopup", false);
            }, 1500);
         }, 3000);

         

      

    }, 

      onChange:function (cmp, event,helper){
        
        var idSelected = event.getSource().get("v.label");
		helper.lockBoxes(cmp);	 

        var finalReviewPrices = cmp.get("v.FinalReviewPrices");
        
        for(var i = 0; i<finalReviewPrices.length; i++){
            if(i != event.getSource().getLocalId().substr(2) - 1){
                finalReviewPrices[i].Selected__c = false;
            }
        }

        cmp.set("v.FinalReviewPrices",finalReviewPrices);
        helper.unlockBoxes(cmp);        
        
    },

    closePopup: function(cmp, event, helper) { 
        cmp.set("v.displayPopup", false);
    }
})