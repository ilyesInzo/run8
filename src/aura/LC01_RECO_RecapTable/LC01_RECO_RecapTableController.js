({
   doInit : function(component, event, helper) {
        helper.getSelectedTubeConfig( component,event,helper); ; 
        helper.getFinalPriceOffer( component,event,helper);       
    },
    refreshNetPriceOffer: function(component, event, helper) {
        component.set("v.FinalPriceOfferList",event.getParam("NetPrice"));
        helper.refreshPricesAndMOQs(component,event,helper);
        helper.SaveRecapHelper(component, event, helper,false);
    },
    SaveRecap: function(component, event, helper) {
         helper.SaveRecapHelper(component, event, helper,true);
    },
    CopyToClipboard : function(component, event, helper) {     
            var btn =component.find("copyBtn");
            btn.set("v.iconName","utility:check");
        	btn.set("v.variant","success");
			helper.CopyTableToClipBoardHelper(component, event,helper);
            window.setTimeout(function(){
                var btn =component.find("copyBtn");
                btn.set("v.iconName","utility:copy");
                btn.set("v.variant","brand");
            }, 1500);           
    },
    OpenSendMailModal: function (component, event , helper){
        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        console.log('The msg is ',window.location.search.substring(1) + ' | '+sPageURL);
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        helper.getKamManager(component, event);
       
   
    },
    cancel : function(component, event, helper){
        component.set('v.msg','');
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    SendMail: function(component, event, helper) {     
             helper.sendMail(component,event);           
    }
    


})