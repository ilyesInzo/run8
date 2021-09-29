({
    init : function(cmp, event, helper) {
        
    	cmp.set("v.isinit",true);
        cmp.set("v.isDisabledHist", cmp.get("isDisabled"));
        var action = cmp.get("c.getMapListValues");
        action.setParams({
            objectName : cmp.get("v.objectName"),
            fieldName : cmp.get("v.fieldName"),
            parameters : cmp.get("v.parameters"),
            dependentfields : cmp.get("v.dependentfields"),
            savedFieldname : cmp.get("v.savedfieldName")
            
        });
        action.setCallback(this, function(response) {
        	var maplist = response.getReturnValue();

        	maplist = (maplist)?maplist:new Map();
        	cmp.set("v.dependentmaplist", maplist);


        	var valuesmap = {};
        	var dfields = cmp.get("v.saveddependentfields");
        	for(var i = 0; i < dfields.length ; i++){
        		valuesmap[dfields[i]] = 'initload';
        	}
        	cmp.set("v.dependentvaluesmap",valuesmap);
          

        });
        $A.enqueueAction(action);



    },
    handleEvent : function(cmp, event, helper) {

	        var fName = event.getParam("name");
	        var selectedValue = event.getParam("selectedValue");

            var disablelist =cmp.get("v.disablelist");
	        var dfields = cmp.get("v.saveddependentfields");
	        var dvaluesmap = cmp.get("v.dependentvaluesmap");
	        var maplist = cmp.get("v.dependentmaplist");
	        var separator = cmp.get("v.concat");
	        var opts = [];
			var val = (cmp.get("v.value"))?cmp.get("v.value").toString():"";
            var para = cmp.get("v.isNotDef");
	        //cmp.set("v.pickvalue", val);
        // console.log('@@@@ : MAp list is :  '+ maplist);
        //console.log('@@@@ : val /'+ val+'/end');
	       //console.log('@@@@ : '+ cmp.get("v.savedfieldName") + '--' + cmp.get("v.selectedConfig.Is_from_preconfig__c") );
			//dfields.includes(fName)
			if(disablelist.indexOf(selectedValue) != -1 )
            { cmp.set("v.isDisabled","true");
             //console.log('Param : '+ fName +' 36 is '+cmp.get("v.disablefiled"));
            }
        else{
            
          if(cmp.get("v.disablefiled")==fName)
          {cmp.set("v.isDisabled",cmp.get("v.isDisabledHist"));
          }else
          {if(disablelist.length==0 || (disablelist.length>0 && !cmp.get("v.isDisabled")))
          {
	        if(dfields.length > 0 && cmp.get("v.savedfieldName") != fName && (dfields.indexOf(fName) != -1) && dvaluesmap[fName] != selectedValue ){

	        	var checkinit = '';
	        	for(var i = 0; i < dfields.length ; i++){
	        		checkinit += dvaluesmap[dfields[i]];

                    //console.log('in cmp'+cmp.get("v.fieldName")+'@@@@ : dfiled list is :  '+ dfields[i]+' dvaluesmap list is '+dvaluesmap[dfields[i]]);
	        	}

	        	dvaluesmap[fName] = selectedValue;
                
	        	cmp.set("v.dependentvaluesmap",dvaluesmap);

	    		var dvaluestr = '';
	    		for(var i = 0; i < dfields.length ; i++){
	        		dvaluestr += dvaluesmap[dfields[i]];
	        		dvaluestr += (separator[i])?separator[i]:'';
	        	}

	        	if(separator.length > 0){
	        		dvaluestr = (dvaluestr.substr(dvaluestr.length - 1) == "_")?(dvaluestr.substring(0,(dvaluestr.length - 1))):dvaluestr;
	        	}
              //console.log('LOGBEFORE : '+ dvaluestr);
                if(para){ dvaluestr = dvaluestr.replaceAll(/__/g,'_');  }
	    		if(maplist[dvaluestr]){
        			opts = opts.concat(maplist[dvaluestr]);
        		}
                 
              // console.log('The field is '+fName+' Option : '+ dvaluestr+' opts is '+maplist[dvaluestr]+ ' dvaluestr est :' + dvaluestr);
               // console.log('Option opts: '+ opts);
        		var optallval = '';
	    		for(var i = 0; i < opts.length ; i++){
	    			optallval += opts[i];
        		}

	    		var optlength = (cmp.get("v.buttonDisabled") == true) ? 0 : optallval.length;
	    		cmp.set("v.optionslength", optlength);



	    		cmp.set("v.optionssize", opts.length);
	    		cmp.set("v.options", opts);


	    		//if(checkinit.includes("initload")){ not working on IE
	    		if (checkinit.indexOf('initload') != -1 ){
	        		cmp.set("v.pickvalue", val);
                    


	        	}
	        	else{

                    
	        		cmp.set("v.pickvalue", cmp.get("v.value"));
	        		if(cmp.get("v.isDisabled")){

	    				if(opts.length > 0){

		    				for(var i = 0; i < opts.length ; i++){
		    				    cmp.set("v.pickvalue", opts[i]);
		    					cmp.set("v.value", opts[i]);
		    				}
	    				}
	    				else{

                           if (cmp.get("v.selectedConfig.Is_from_preconfig__c") == true){

                                     cmp.set("v.value", val);
                                   //  cmp.set("v.pickvalue", val);

                            }else{
                                cmp.set("v.value", "");
                            }

	    				}
	    			}
	    			else{

                        if (cmp.get("v.selectedConfig.Is_from_preconfig__c") == false){
                        	    			        cmp.set("v.pickvalue", "");
                                                    cmp.set("v.value", "");

                        }

	    				if(cmp.get("v.autoselect")){

	    					if(opts.length == 1){
			    				for(var i = 0; i < opts.length ; i++){
			    					cmp.set("v.pickvalue", opts[i]);
			    					cmp.set("v.value", opts[i]);

			    				}
	    					}
	    				}
                        

	    			}
	        	}


	        }
	        else if(dfields.length == 0 && cmp.get("v.savedfieldName") == fName){

	        	if(maplist[cmp.get("v.savedfieldName")]){
                   
        			opts = opts.concat(maplist[cmp.get("v.savedfieldName")]);
                   
        		}

        		var optallval = '';
	    		for(var i = 0; i < opts.length ; i++){
	    			optallval += opts[i];
        		}
	    		var optlength = (cmp.get("v.buttonDisabled") == true) ? 0 : optallval.length;
	    		cmp.set("v.optionslength", optlength);

	        	cmp.set("v.optionssize", opts.length);
	        	cmp.set("v.options", opts);
	        	if(cmp.get("v.value")){

 
	        			cmp.set("v.pickvalue", cmp.get("v.value").toString());

               //console.log('The field is '+fName+'the value: '+opts+'is true '+ opts.lastIndexOf(cmp.get("v.value").toString())+' Pickis '+cmp.get("v.pickvalue")+ ' length '+cmp.get("v.optionslength")+' Disable '+ cmp.get("v.isDisabled")); 

	        	}
	        }
              
          }
          }

}

    },

    buttonChange : function(cmp, event, helper) {
    	//console.log('******button*value***' + event.getSource().get("v.label"));

         $A.get("e.c:LC00_DependentFieldsEvent").fire();
        //console.log('******Picklist*value***' + cmp.get("v.pickvalue")+' label is '+event.getSource().get("v.label"));
    
    	if(event.getSource().get("v.label") == cmp.get("v.pickvalue") ){
    		cmp.set("v.pickvalue", "");
			cmp.set("v.value", "");
             //console.log('**** IN IF');
            	}
    	else{

			cmp.set("v.pickvalue", event.getSource().get("v.label"));
			cmp.set("v.value", event.getSource().get("v.label"));
            //console.log('**** IN ELSE');
		}

    },

    pickvaluechange : function(cmp, event, helper) {
    	 $A.get("e.c:LC00_DependentFieldsEvent").fire();
    	if(cmp.get("v.pickvalue") || cmp.get("v.pickvalue") == ""){
        	cmp.set("v.value", cmp.get("v.pickvalue"));
    	}
        

    },
    valuechange : function(cmp, event, helper) {

    	//console.log('*********valuechange************' + cmp.get("v.savedfieldName") + ' : ' + cmp.get("v.value"));
		 $A.get("e.c:LC00_DependentFieldsEvent").fire();
		var val = (cmp.get("v.value"))?cmp.get("v.value").toString():"";
		var appEvent = $A.get("e.c:LE00_DependentPicklist");
               
                        if(cmp.get("v.DefaultVal")!= null && val.length == 0){
			    					cmp.set("v.pickvalue", cmp.get("v.DefaultVal"));
			    					cmp.set("v.value", cmp.get("v.DefaultVal"));
                      //console.log('LOG INNN DEfault : ');
                           val=cmp.get("v.DefaultVal");
	    				}
        //console.log('*********valuefire*** '+cmp.get("v.savedfieldName")+' val is '+ val+' get '+cmp.get("v.pickvalue"));
 
        appEvent.setParams({
            name: cmp.get("v.savedfieldName"),
            selectedValue: val

        });
        appEvent.fire(); 
    }
})