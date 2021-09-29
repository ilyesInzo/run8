({
	convertList : function(cmp, list) {
		var _list = cmp.get(list);
        var _listLen = _list.length;
        var _listTemp = [];
        for (var i = 0; i < _listLen; i++) {
            _listTemp.push({
            	title 	: _list[i],
            	edit  	: '', //
            	x10   	: 0,
            	x25		: 0,
            	x50		: 0,
            	x100	: 0,
            	x250	: 0,
            	x10Override   	: 0,
            	x25Override		: 0,
            	x50Override		: 0,
            	x100Override	: 0,
            	x250Override	: 0,
                prices	: [0,0,0,0,0]
            });
        }
        cmp.set(list, _listTemp);
	},
	getPrices : function(cmp, event){
		var action = cmp.get("c.getDetailPrices");
        action.setParams({
            qliId : cmp.get("v.qli").Id
        });
        action.setCallback(this, function(response) {
        	var _response = response.getReturnValue();
        	console.log("prices", _response);        
            
        	this.setPrices(cmp, "v.productDef", 'Product Definition', _response.details);
        	this.setPrices(cmp, "v.colorationUpcharge", 'Coloration Upcharge', _response.details);
        	this.setPrices(cmp, "v.pumpOpt", 'Pump Options', _response.details);
        	this.setPrices(cmp, "v.bottlepumpdecOpt", 'Bottle & Pump Decoration Options', _response.details);
        	this.setPrices(cmp, "v.others", 'Others', _response.details);
            cmp.set("v.total", _response.total);
            cmp.set("v.currency", _response.currency);  
 			cmp.set("v.currencyPosition", _response.currencyPosition);  
            
 			this.descprice(cmp, "v.productDef", "v.prod_def_desc_price");     
 			this.descprice(cmp, "v.colorationUpcharge", "v.Coloration_Upcharge_desc_price");    
 			this.descprice(cmp, "v.pumpOpt", "v.Pump_Options_desc_price");    
 			this.descprice(cmp, "v.bottlepumpdecOpt", "v.Bottle_Pump_Decoration_Options_desc_price");      			
 			
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
            
    		if(_response[attrName] && _response[attrName][_title]){
                _section[i].x10 = (_response[attrName][_title][0] ? _response[attrName][_title][0].List_Price__c : '');
        		_section[i].x25 = (_response[attrName][_title][1] ? _response[attrName][_title][1].List_Price__c : '');
        		_section[i].x50 = (_response[attrName][_title][2] ? _response[attrName][_title][2].List_Price__c : '');
        		_section[i].x100 = (_response[attrName][_title][3] ? _response[attrName][_title][3].List_Price__c : '');
        		_section[i].x250 = (_response[attrName][_title][4] ? _response[attrName][_title][4].List_Price__c : '');
                _section[i].x10Override = (_response[attrName][_title][0] ? _response[attrName][_title][0].Price_Override__c : '');
        		_section[i].x25Override = (_response[attrName][_title][1] ? _response[attrName][_title][1].Price_Override__c : '');
        		_section[i].x50Override = (_response[attrName][_title][2] ? _response[attrName][_title][2].Price_Override__c : '');
         		_section[i].x100Override = (_response[attrName][_title][3] ? _response[attrName][_title][3].Price_Override__c : '');
        		_section[i].x250Override = (_response[attrName][_title][4] ? _response[attrName][_title][4].Price_Override__c : '');
		    }
    		
    	}
    	cmp.set(attr, _section);
        console.log(attr);
        console.log(_section);
		
	},
	
	descprice : function(cmp, item, disp){
		
		var itemlst = cmp.get(item);
		var overrideprice = 0;
		for(var i = 0 ; i < itemlst.length ; i++){
			overrideprice += (isNaN(itemlst[i].x10Override))?0:itemlst[i].x10Override;
			overrideprice += (isNaN(itemlst[i].x25Override))?0:itemlst[i].x25Override;
			overrideprice += (isNaN(itemlst[i].x50Override))?0:itemlst[i].x50Override;
			overrideprice += (isNaN(itemlst[i].x100Override))?0:itemlst[i].x100Override;
			overrideprice += (isNaN(itemlst[i].x250Override))?0:itemlst[i].x250Override;
		}
		var display = (overrideprice > 0)?"":"none";
		cmp.set(disp, display);
	},
	savepricehelper : function(cmp, section, listitems, updatelistitems){
			
    	for(var i = 0; i < listitems.length ; i++){
    		if(!isNaN(listitems[i].x10Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=10"] = [listitems[i].x10Override];
    		}	
    		if(!isNaN(listitems[i].x25Override)){
    			updatelistitems[section + "=" + listitems[i].title + "=25"] = [listitems[i].x25Override];
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
    		
    	} 
    	
    	return updatelistitems;
	
	}   
})