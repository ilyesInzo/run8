({
	fixProductImage : function(cmp) {
		
        //document.getElementsByTagName('head')[0].appendChild('<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">');
        
        var elmnProductImage = cmp.find("productImage");
        //console.log('######## elmnProductImage' + elmnProductImage);
        
        var didScroll = false;
        
        window.onscroll = function() {
            if(document.body.scrollTop>300){
                //console.log('######## document.body.scrollTop >300:  ' + document.body.scrollTop);
                //didScroll = true;
                $A.util.addClass(elmnProductImage, 'fixed');
                //elmnProductImage.set('v.class', 'slds-p-horizontal--small slds-size--1-of-1 slds-medium-size--1-of-3 fixed');
                document.getElementById("productImage").className = 'fixed';
            }else{
                //didScroll = false;
                //console.log('######## document.body.scrollTop < 300:' + document.body.scrollTop);
                //elmnProductImage.set('v.class', 'slds-p-horizontal--small slds-size--1-of-1 slds-medium-size--1-of-3');
                $A.util.removeClass(elmnProductImage, 'fixed');        
                document.getElementById("productImage").className = '';
            }


        };        
		
	}
})