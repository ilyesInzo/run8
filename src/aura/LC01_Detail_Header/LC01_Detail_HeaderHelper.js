({
	getProductConfigCmpNameFromQli : function(qli) {
		var productSubSegment = qli.Product_Sub_segment__c;
        //console.log("## productSubSegment", productSubSegment);
        var location = (qli.Location__c == '' || qli.Location__c == null )? 'EU' : qli.Location__c;
        //console.log("## location", location);
        
		var pageComponentName = "";
		        
        //console.log("## qli.Purefoil_Segment__c", qli.Purefoil_Segment__c );
        //console.log("## qli.Purefoil_Segment__c == true ? ", qli.Purefoil_Segment__c  == true);
        //console.log("## qli.location == 'EU' ",         location == 'EU');

        switch (productSubSegment) {
            case "Plastic Tubes":
                if(location == 'EU' && qli.Purefoil_Segment__c == true){
                    pageComponentName = "c:LC01_ProductConfig_" + location + "_TubePurefoil";
                }else{
                    pageComponentName = "c:LC01_ProductConfig_" + location + "_TubePlastic";   
                }
                break;
            case "Laminate Tubes":
                pageComponentName = "c:LC01_ProductConfig_" + location + "_TubeLaminate";
                break; 
            case "Foam pumps":
                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingFoam";
                break;
            case "Fine mist pumps":
                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingFineMist";
                break;
            case "Lotion pumps":
                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingLotion";
                break;
            case "Sampler pumps":
                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingSamplers";
                break;
            default: 
                alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
        }
        return pageComponentName;
	}
})