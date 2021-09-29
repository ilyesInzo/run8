({
	initLayout : function(cmp,event) {
     
        if(cmp.get("v.LayoutEUTube"))
        {
            this.initEULayout(cmp,event);
        }
        else
        {
            this.initUSLayout(cmp,event);
        }
    },
    initUSLayout : function(cmp,event)
    {
         this.create_Header(cmp,event,"header4","5.",$A.get("$Label.c.LBL_DealContextComments"),"","");
         this.create_FinalPriceOffer(cmp,event,"position5");
         this.create_Header(cmp,event,"header5","6.",$A.get("$Label.c.LBL_FinalPriceOfferProposedMOQ"),$A.get("$Label.c.HT_Quoted_Price"),"200px");
            
   },
    initEULayout : function(cmp,event)
    {
        this.create_Header(cmp,event,"header4","4.",$A.get("$Label.c.LBL_DealContextComments"),"","");
        this.create_PriceReco(cmp,event,"position5");
        this.create_Header(cmp,event,"header5","5.",$A.get("$Label.c.LBL_PriceRecoProduct"),$A.get("$Label.c.HT_Price_Reco"),"200px");
      
              
        this.create_FinalPriceOffer(cmp,event,"position6");
        this.create_Header(cmp,event,"header6","6.",$A.get("$Label.c.LBL_FinalPriceOfferProposedMOQ"),$A.get("$Label.c.HT_Quoted_Price"),"200px");
      
    },
    create_Header: function(cmp,event, position,Number,Name,helpText,width) {
        $A.createComponent(
           "c:LC00_RECO_Header",
            {
                "headerNumber": Number,
                "headerName":Name,
                "helpText":helpText,
                    "width":width
            },
            function(headerCMP, status, errorMessage){
               if (status === "SUCCESS") {
                    var body = cmp.get("v."+position);
                        body.push(headerCMP);
                        cmp.set("v."+position, body);
                  }         
            }
        );
    },
    create_PriceReco: function(cmp,event, position) {
        $A.createComponent(
            "c:LC01_RECO_PriceReco",
            {
                "qli": cmp.get("v.qli"),
                "qliId":cmp.get("v.qliId"),
                "qliCurrency":cmp.get("v.qli.Billing_Currency_Symbol__c"),
            },
            function(priceCMP, status, errorMessage){
               if (status === "SUCCESS") {
                    var body = cmp.get("v."+position);
                        body.push(priceCMP);
                        cmp.set("v."+position, body); 
               }         
            }
        );
    },
    create_FinalPriceOffer: function(cmp,event,position) {
        $A.createComponent(
            "c:LC01_RECO_FinalPriceOffer",
            {"qli": cmp.get("v.qli")},
            function(finalPriceCMP, status, errorMessage){
               if (status === "SUCCESS") { 
                   var body = cmp.get("v."+position);
                        body.push(finalPriceCMP);
                        cmp.set("v."+position, body); 
               }             
            }
        );
    }
    
})