({
	convertList : function(cmp, list) {
		var _list = cmp.get(list);
        var _listLen = _list.length;
        var _listTemp = [];
        for (var i = 0; i < _listLen; i++) {
            _listTemp.push({
            	title 	: _list[i],
            	edit  	: 'slds-hide', //
            	x5   	: 0,
                x10   	: 0,
            	x15		: 0,
            	x20		: 0,
            	x25		: 0,
            	x30		: 0,
            	x50		: 0,
            	x100	: 0,
            	x250	: 0,
            	x500	: 0,
            	x5Override   	: 0,
                x10Override   	: 0,
            	x15Override		: 0,
            	x20Override		: 0,
            	x25Override		: 0,
            	x30Override		: 0,
            	x50Override		: 0,
            	x100Override	: 0,
            	x250Override	: 0,
            	x500Override	: 0,
                prices	: [0,0,0,0,0,0,0,0,0,0]
            });
        }
        cmp.set(list, _listTemp);
	},
//added for ticket 6329.
	getCurrentUserProfileName : function(cmp,event){
				
				var action = cmp.get("c.checkCurrentUserProfileName");
				
				action.setCallback(this, function(response) {
					var _response = response.getReturnValue();
					cmp.set("v.hideLine", _response);
				});
				$A.enqueueAction(action);
		
		},
	// end added ******
	getPrices : function(cmp, event){
		var action = cmp.get("c.getDetailPrices");
        action.setParams({
            qliId : cmp.get("v.qli").Id
        });
        action.setCallback(this, function(response) {
        	var _response = response.getReturnValue();
        	console.log("prices", _response);
        	
        	this.setPrices(cmp, "v.tubehead", 'Tube & Head', _response.details);
        	this.setPrices(cmp, "v.sleeve", 'Sleeve', _response.details);
        	this.setPrices(cmp, "v.cap", 'Cap', _response.details);
        	this.setPrices(cmp, "v.printing", 'Printing', _response.details);
            this.setPrices(cmp, "v.packing", 'Packing', _response.details);
        	this.setPrices(cmp, "v.others", 'Others', _response.details);
            cmp.set("v.total", _response.total);
            //console.log("@@qama  _response.total ");
            //console.log(_response.total[0].No_Ref_If_Combo_Comments__c);
            cmp.set("v.currency", _response.currency);  
 			cmp.set("v.currencyPosition", _response.currencyPosition); 
 			
 			cmp.set("v.isCombo", cmp.get("v.total")[0].IsCombo__c);
 			cmp.set("v.totalLine", _response.totalLine);
 			cmp.set("v.specificMOQ",_response.specificMOQ);
            cmp.set("v.totalSpecificMOQ",_response.totalSpecificMOQ);
            cmp.set("v.specificCombo",_response.specificCombo);
 			
 			this.descprice(cmp, "v.cap", "v.cap_desc_price");            			
 			
        	cmp.find("saveBtn").set("v.disabled", false);
        	$A.util.addClass(cmp.find("mySpinner"), "slds-hide");     
        	 
        });
        $A.enqueueAction(action);
	},
	setPrices : function(cmp, attr, attrName, _response){
		var _section = cmp.get(attr);
        
        var editableLines = cmp.get("v.editable");
        console.log(editableLines);
        
    	var _sectionLen = _section.length;
    	for(var i = 0 ; i < _sectionLen ; i++){
    		var _title = _section[i].title;
            //if (editableLines.includes(_title)) {
            if (editableLines.indexOf(_title) != -1) {
                _section[i].edit  = '';
            }
            
    		//console.log(_title, _response[attrName][_title]);
    		//_section[i].data = _response[attrName][_title];
    		if(_response[attrName] && _response[attrName][_title]){
    			//console.log(_response[attrName][_title][0]);
    			//console.log(_response[attrName][_title][0].List_Price__c);
        		//_section[i].x10 = _response[attrName][_title][0].List_Price__c;
        		_section[i].x5 = (_response[attrName][_title][0] ? _response[attrName][_title][0].List_Price__c : '');
                _section[i].x10 = (_response[attrName][_title][1] ? _response[attrName][_title][1].List_Price__c : '');
        		_section[i].x15 = (_response[attrName][_title][2] ? _response[attrName][_title][2].List_Price__c : '');
        		_section[i].x20 = (_response[attrName][_title][3] ? _response[attrName][_title][3].List_Price__c : '');
        		_section[i].x25 = (_response[attrName][_title][4] ? _response[attrName][_title][4].List_Price__c : '');
        		_section[i].x30 = (_response[attrName][_title][5] ? _response[attrName][_title][5].List_Price__c : '');
        		_section[i].x50 = (_response[attrName][_title][6] ? _response[attrName][_title][6].List_Price__c : '');
        		_section[i].x100 = (_response[attrName][_title][7] ? _response[attrName][_title][7].List_Price__c : '');
        		_section[i].x250 = (_response[attrName][_title][8] ? _response[attrName][_title][8].List_Price__c : '');
        		_section[i].x500 = (_response[attrName][_title][9] ? _response[attrName][_title][9].List_Price__c : '');
               _section[i].xSpecific = (_response[attrName][_title][10] ? _response[attrName][_title][10].List_Price_Display__c : '');
        		
                _section[i].x5Override = (_response[attrName][_title][0] ? _response[attrName][_title][0].Price_Override__c : '');                
                _section[i].x10Override = (_response[attrName][_title][1] ? _response[attrName][_title][1].Price_Override__c : '');
        		_section[i].x15Override = (_response[attrName][_title][2] ? _response[attrName][_title][2].Price_Override__c : '');
        		_section[i].x20Override = (_response[attrName][_title][3] ? _response[attrName][_title][3].Price_Override__c : '');
        		_section[i].x25Override = (_response[attrName][_title][4] ? _response[attrName][_title][4].Price_Override__c : '');
        		_section[i].x30Override = (_response[attrName][_title][5] ? _response[attrName][_title][5].Price_Override__c : '');
        		_section[i].x50Override = (_response[attrName][_title][6] ? _response[attrName][_title][6].Price_Override__c : '');
        		_section[i].x100Override = (_response[attrName][_title][7] ? _response[attrName][_title][7].Price_Override__c : '');
        		_section[i].x250Override = (_response[attrName][_title][8] ? _response[attrName][_title][8].Price_Override__c : '');
        		_section[i].x500Override = (_response[attrName][_title][9] ? _response[attrName][_title][9].Price_Override__c : '');
        		_section[i].xSpecificOverride = (_response[attrName][_title][10] ? _response[attrName][_title][10].Price_Override__c : '');
		    
		    }
    		//console.log('Result : ' + _title, _section[i]);
    	}
    	cmp.set(attr, _section);
		
	},
	
	descprice : function(cmp, item, disp){
		
		var itemlst = cmp.get(item);
		var overrideprice = 0;
		for(var i = 0 ; i < itemlst.length ; i++){
			overrideprice += (isNaN(itemlst[i].x5Override))?0:itemlst[i].x5Override;            
			overrideprice += (isNaN(itemlst[i].x10Override))?0:itemlst[i].x10Override;
			overrideprice += (isNaN(itemlst[i].x15Override))?0:itemlst[i].x15Override;
			overrideprice += (isNaN(itemlst[i].x20Override))?0:itemlst[i].x20Override;
			overrideprice += (isNaN(itemlst[i].x25Override))?0:itemlst[i].x25Override;
			overrideprice += (isNaN(itemlst[i].x30Override))?0:itemlst[i].x30Override;
			overrideprice += (isNaN(itemlst[i].x50Override))?0:itemlst[i].x50Override;
			overrideprice += (isNaN(itemlst[i].x100Override))?0:itemlst[i].x100Override;
			overrideprice += (isNaN(itemlst[i].x250Override))?0:itemlst[i].x250Override;
			overrideprice += (isNaN(itemlst[i].x500Override))?0:itemlst[i].x500Override;
		}
		var display = (overrideprice > 0)?"":"none";
		cmp.set(disp, display);
	}    ,
	savepricehelper : function(cmp, section, listitems, updatelistitems){
			
    	for(var i = 0; i < listitems.length ; i++){
            if(!isNaN(listitems[i].x5Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=5"] = [listitems[i].x5Override];
    		}
    		if(!isNaN(listitems[i].x10Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=10"] = [listitems[i].x10Override];
    		}	
    		if(!isNaN(listitems[i].x15Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=15"] = [listitems[i].x15Override];
    		}	
    		if(!isNaN(listitems[i].x20Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=20"] = [listitems[i].x20Override];
    		}	
    		if(!isNaN(listitems[i].x25Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=25"] = [listitems[i].x25Override];
    		}	
    		if(!isNaN(listitems[i].x30Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=30"] = [listitems[i].x30Override];
    		}	
    		if(!isNaN(listitems[i].x50Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=50"] = [listitems[i].x50Override];
    		}
    		if(!isNaN(listitems[i].x100Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=100"] = [listitems[i].x100Override];
    		}	
    		if(!isNaN(listitems[i].x250Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=250"] = [listitems[i].x250Override];
    		}
    		if(!isNaN(listitems[i].x500Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=500"] = [listitems[i].x500Override];
    		}	
    		
    	} 
    	
    	return updatelistitems;
	
	}    
})