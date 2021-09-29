({
	openModal : function(cmp, event) {
        console.log("## openModal");
        var _super = cmp.getSuper();
        var _modal = _super.find("modal");
        $A.util.toggleClass(_modal, 'slds-hide');
        $A.util.toggleClass(_modal, 'slds-fade-in-open');
        var _backdrop = _super.find("backdrop");
        $A.util.toggleClass(_backdrop, 'slds-backdrop--open');
    },
    closeModal : function(cmp, event) {
        var _super = cmp.getSuper();
		var _modal = _super.find("modal");
        $A.util.toggleClass(_modal, 'slds-hide');
        $A.util.toggleClass(_modal, 'slds-fade-in-open');
        var _backdrop = _super.find("backdrop");
        $A.util.toggleClass(_backdrop, 'slds-backdrop--open');
    }
})