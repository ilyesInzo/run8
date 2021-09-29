({
    init : function(cmp, event, helper) {
        var _buttonLabels = cmp.get("v.buttons");
        var _numBtns = _buttonLabels.length;
        var _btns = [];
        for (var i = 0; i < _numBtns; i++) {
            _btns.push({
                label : _buttonLabels[i],
                class : 'slds-button--neutral'
            });
        }
        cmp.set("v.btns", _btns);
    },
	handleClick : function(cmp, event, helper) {
        var _btns = cmp.get("v.btns");
        var _numBtns = _btns.length;
        for (var i = 0; i < _numBtns; i++) {
            _btns[i].class = 'slds-button--neutral';
        }
        cmp.set("v.btns", _btns);
		var _btn = event.getSource();
        _btn.set("v.class", "slds-button--brand");
	}
})