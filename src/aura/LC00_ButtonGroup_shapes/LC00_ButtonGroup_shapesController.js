({
    init : function(cmp, event, helper) {
        var _buttonLabels = cmp.get("v.buttons");
        var _btns = [];
        //for (var i = 0; i < _numBtns; i++) {
        _btns.push({
            label : 'Cylindrical',
            src : '/resource/shape_cylindrical',
            classIcon : 'normal',
            class : 'slds-button--neutral'
        });
        _btns.push({
            label : 'Oval',
            src : '/resource/shape_oval',
            classIcon : 'normal',
            class : 'slds-button--neutral'
        });
        //}
        cmp.set("v.btns", _btns);
    },
    handleClick : function(cmp, event, helper) {
        var _btns = cmp.get("v.btns");
        var _numBtns = _btns.length;
        for (var i = 0; i < _numBtns; i++) {
            _btns[i].class = 'slds-button--neutral normal';
            _btns[i].classIcon = 'normal';
        }
        cmp.set("v.btns", _btns);
        var _btn = event.getSource();
        _btn.set("v.class", "slds-button--brand invert");
        _btn.set("v.classIcon", "invert");
    }
})