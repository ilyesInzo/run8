({	 init : function(cmp, event, helper) {
    
    	 cmp.find("Incoterm__c").set("v.value", "EXW");                
       
    },
    
    openDetails : function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LC01_Detail_US_DispensingFineMist",
            componentAttributes: {
                qli : cmp.get("v.qli")
            }
        });
        evt.fire();
    },
    
    handleEvent : function(cmp, event, helper) {
       
	        var fName = event.getParam("name");
	        var selectedValue = event.getParam("selectedValue");
	        if(fName == 'Product_Name__c'){
	        	if(selectedValue == 'LPP' || selectedValue == 'SLPP' || selectedValue == 'XD11' || selectedValue == ''){	        	
	        		cmp.set("v.pricevalue", "Price : Ex-Works Thomaston delivery");   
	        	}
	        	else if(selectedValue == 'ABS941'){        	
	        		cmp.set("v.pricevalue", "Price : LDP NY");	        	
	        	}
	        	else{
	        		cmp.set("v.pricevalue", "Price : Ex-Works Le Tréport delivery");
	        	}
	        }
	        
	 }, 
    displayDetailsJS: function(cmp, event, helper) {
    	cmp.set("v.displayDetails", !cmp.get("v.displayDetails"));
    	cmp.set("v.open2", !cmp.get("v.open2"));
    	
    	
    }, 

    hideDetailsJS : function(cmp, event, helper) {
        cmp.set("v.displayDetails", false);
        cmp.set("v.open2", false);
        
        
    }
	 
})