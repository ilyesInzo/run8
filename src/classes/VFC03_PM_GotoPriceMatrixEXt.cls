public class VFC03_PM_GotoPriceMatrixEXt {

    public VFC03_PM_GotoPriceMatrixEXt(ApexPages.StandardSetController controller) {

    }

	public VFC03_PM_GotoPriceMatrixEXt(ApexPages.StandardController controller){

    }
     public PageReference redirectToPriceMatrix(){
         String quoteLineItemId = ApexPages.CurrentPage().getParameters().get('Id');
         return new PageReference('/' + quoteLineItemId).setRedirect(true);
     }
}