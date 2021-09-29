({
	printtechnomsg : function(cmp, evt) {
        var msg = "";
        var _printTech = (cmp.get("v.selectedconfig").Printing_technologies__c)?cmp.get("v.selectedconfig").Printing_technologies__c:"";
		//console.log('*****_printTech******' + _printTech);
        
        var _offsetOptions = cmp.get("v.NB_Offset_Colors__c");
        var _flexoOptions = cmp.get("v.NB_Flexo_Colors__c");
        var _ssOptions = cmp.get("v.NB_SS_Colors__c");
		//console.log('*****_offsetOptions******' + _offsetOptions);
		//console.log('*****_flexoOptions******' + _flexoOptions);
		//console.log('*****_ssOptions******' + _ssOptions);
		
		var compareval = 0;
		
		//_printTech.includes('Silkscreen')  not working on IE		
		
		if(_printTech.indexOf('Silkscreen') != -1){
			compareval = _ssOptions;
		}
		else if(_printTech.indexOf('Flexo') != -1){
			compareval = _flexoOptions;
		}
		else if(_printTech.indexOf('Offset') != -1){
			compareval = _offsetOptions;
		}
        
        if(_printTech != 'Unprinted' && (compareval == 0) && _printTech.length != 0){
			msg = 'Not possible with specs!';
		}else if(_printTech == 'Flexo + Silkscreen' && _flexoOptions == 4 && _ssOptions == 3 ){
			msg = 'Max 4FL + 2SS or 3FL+3SS';
		}
		//console.log('**********' + msg);
        cmp.set("v.printingtechnomsg", msg);
	},
	
	firecolorvalues : function(cmp, event, fname, val) {    
	
		var val = (val)?val.toString():"";   
		
		var appEvent = $A.get("e.c:LE00_DependentPicklist");		
        appEvent.setParams({
            name: fname,
            selectedValue: val

        });
        appEvent.fire(); 
    }
})