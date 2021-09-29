({
	printtechnomsg : function(cmp, evt) {
        var msg = "";
        var sscolor = Number(cmp.find("NB_SS_Colors__c").get("v.value"));
        var ssnum = (sscolor)?sscolor:0;
        if(cmp.get("v.selectedconfig").Printing_type__c == "Flexo"){
            msg = "Not available in RM";
        }
        else if(ssnum > 2){
            msg = "Not available in WN";            
        }
        else if(ssnum > 0){
            msg = "Not available in WN for 1'' or less";
        }
        else{
            msg = "";
        }
        cmp.set("v.printingtechnomsg", msg);
        //alert(msg);
	}
})