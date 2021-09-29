({	
	getPrices : function(cmp, event, index){
		var action = cmp.get("c.getDetailPricesByObject");
        action.setParams({
            qliId : cmp.get("v.qli").Id
        });
        action.setCallback(this, function(response) {
        	var _response = response.getReturnValue();
        	console.log("prices", _response);
        	if (index == 0) {
                this.setPriceLines(cmp, "v.tubehead", 'Tube & Head', _response.details);
                this.setPriceLines(cmp, "v.web", 'Web', _response.details);
                this.setPriceLines(cmp, "v.cap", 'Cap', _response.details);
                this.setPriceLines(cmp, "v.printing", 'Printing', _response.details);
                this.setPriceLines(cmp, "v.otherparts", 'Other Parts', _response.details);
                this.setPriceLines(cmp, "v.others", 'Others', _response.details);
                cmp.set("v.total", _response.totalLine);
                 console.log("@@qama total line");
                 console.log(_response.totalLine);
                cmp.set("v.currency", _response.currency);  
                cmp.set("v.currencyPosition", _response.currencyPosition);  
                this.descprice(cmp, "v.cap", "v.cap_desc_price");    
                this.descprice(cmp, "v.others", "v.others_desc_price"); 
                cmp.set("v.specificMOQ",_response.specificMOQ);
                cmp.set("v.totalSpecificMOQ",_response.totalSpecificMOQ);
                cmp.set("v.specificCombo",_response.specificCombo);    			
                
                cmp.find("saveBtn").set("v.disabled", false);
                $A.util.addClass(cmp.find("mySpinner"), "slds-hide");
            }
        
            
        });
        $A.enqueueAction(action);
	},
    setPriceLines : function(cmp, attr, attrName, response){
        //console.log('setPriceLines-----START=' + attr);
        var section = cmp.get(attr);
        //console.log('section=', section);
        var sectionLen = section.length;
        var priceLineSection = [];
        for(var i = 0 ; i < sectionLen ; i++){
            //console.log(section[i]);
            //console.log(response[section[i]]);
            priceLineSection[i] = response[section[i]];
        }
        cmp.set(attr, priceLineSection);
        
        
        //console.log(priceLineSection);
        //console.log('setPriceLines-----END');
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
                _section[i].x10 = (_response[attrName][_title][0] ? _response[attrName][_title][0].List_Price__c : '');
        		_section[i].x15 = (_response[attrName][_title][1] ? _response[attrName][_title][1].List_Price__c : '');
        		_section[i].x20 = (_response[attrName][_title][2] ? _response[attrName][_title][2].List_Price__c : '');
        		_section[i].x25 = (_response[attrName][_title][3] ? _response[attrName][_title][3].List_Price__c : '');
        		_section[i].x50 = (_response[attrName][_title][4] ? _response[attrName][_title][4].List_Price__c : '');
        		_section[i].x75 = (_response[attrName][_title][5] ? _response[attrName][_title][5].List_Price__c : '');
        		_section[i].x100 = (_response[attrName][_title][6] ? _response[attrName][_title][6].List_Price__c : '');
        		_section[i].x200 = (_response[attrName][_title][7] ? _response[attrName][_title][7].List_Price__c : '');
        		_section[i].x300 = (_response[attrName][_title][8] ? _response[attrName][_title][8].List_Price__c : '');
        		_section[i].x500 = (_response[attrName][_title][9] ? _response[attrName][_title][9].List_Price__c : '');
        		_section[i].x1000 = (_response[attrName][_title][10] ? _response[attrName][_title][10].List_Price__c : '');
        		
                _section[i].x10Override = (_response[attrName][_title][0] ? _response[attrName][_title][0].Price_Override__c : '');
        		_section[i].x15Override = (_response[attrName][_title][1] ? _response[attrName][_title][1].Price_Override__c : '');
        		_section[i].x20Override = (_response[attrName][_title][2] ? _response[attrName][_title][2].Price_Override__c : '');
        		_section[i].x25Override = (_response[attrName][_title][3] ? _response[attrName][_title][3].Price_Override__c : '');
        		_section[i].x50Override = (_response[attrName][_title][4] ? _response[attrName][_title][4].Price_Override__c : '');
        		_section[i].x75Override = (_response[attrName][_title][5] ? _response[attrName][_title][5].Price_Override__c : '');
        		_section[i].x100Override = (_response[attrName][_title][6] ? _response[attrName][_title][6].Price_Override__c : '');
        		_section[i].x200Override = (_response[attrName][_title][7] ? _response[attrName][_title][7].Price_Override__c : '');
        		_section[i].x300Override = (_response[attrName][_title][8] ? _response[attrName][_title][8].Price_Override__c : '');
        		_section[i].x500Override = (_response[attrName][_title][9] ? _response[attrName][_title][9].Price_Override__c : '');
        		_section[i].x1000Override = (_response[attrName][_title][10] ? _response[attrName][_title][10].Price_Override__c : '');
		    }
    		//console.log('Result : ' + _title, _section[i]);
    	}
    	cmp.set(attr, _section);
		
	},
	descprice : function(cmp, item, disp){
		
		var itemlst = cmp.get(item);
		var overrideprice = 0;
		for(var i = 0 ; i < itemlst.length ; i++){
			overrideprice += (isNaN(itemlst[i].x10Override))?0:itemlst[i].x10Override;
            overrideprice += (isNaN(itemlst[i].x15Override))?0:itemlst[i].x15Override;
            overrideprice += (isNaN(itemlst[i].x20Override))?0:itemlst[i].x20Override;
			overrideprice += (isNaN(itemlst[i].x25Override))?0:itemlst[i].x25Override;
			overrideprice += (isNaN(itemlst[i].x50Override))?0:itemlst[i].x50Override;
            overrideprice += (isNaN(itemlst[i].x75Override))?0:itemlst[i].x75Override;
			overrideprice += (isNaN(itemlst[i].x100Override))?0:itemlst[i].x100Override;
			overrideprice += (isNaN(itemlst[i].x200Override))?0:itemlst[i].x200Override;
			overrideprice += (isNaN(itemlst[i].x300Override))?0:itemlst[i].x300Override;
			overrideprice += (isNaN(itemlst[i].x500Override))?0:itemlst[i].x500Override;
			overrideprice += (isNaN(itemlst[i].x1000Override))?0:itemlst[i].x1000Override;
            
		}
		var display = (overrideprice > 0)?"":"none";
		cmp.set(disp, display);
	}   ,
	savepricehelper : function(cmp, section, listitems, updatelistitems){
			
    	for(var i = 0; i < listitems.length ; i++){
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
    		if(!isNaN(listitems[i].x50Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=50"] = [listitems[i].x50Override];
    		}	
    		if(!isNaN(listitems[i].x75Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=75"] = [listitems[i].x75Override];
    		}	
    		if(!isNaN(listitems[i].x100Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=100"] = [listitems[i].x100Override];
    		}	
    		if(!isNaN(listitems[i].x200Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=200"] = [listitems[i].x200Override];
    		}	
    		if(!isNaN(listitems[i].x300Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=300"] = [listitems[i].x300Override];
    		}	
    		if(!isNaN(listitems[i].x500Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=500"] = [listitems[i].x500Override];
    		}
    		if(!isNaN(listitems[i].x1000Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=1000"] = [listitems[i].x1000Override];
    		}	
    		
    	} 
    	
    	return updatelistitems;
	
	} 
})