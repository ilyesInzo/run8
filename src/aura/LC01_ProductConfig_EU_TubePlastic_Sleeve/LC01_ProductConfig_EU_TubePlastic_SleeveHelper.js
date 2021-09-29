({
	loadValues : function(cmp, event) {
		var _savedConfig = cmp.get("v.savedConfig");
        console.log('Specific Length: '+_savedConfig.Specific_length_mm__c);
        if (_savedConfig) {
            if (_savedConfig.Specific_length_mm__c) {
                cmp.set("v.specificLength", _savedConfig.Specific_length_mm__c);
            }
        }
     }
})