/**
* Test class of PriceDetailLine
*
* @author MDK
* @date 23/11/2017
* @description 
*
*/
@isTest
private class PriceDetailLineTest {

    @testSetup 
    private static void init() {
    }
    
    @isTest
	private static void PriceDetailLineTest() {
		PriceDetailLine pdl1 = new PriceDetailLine();
		PriceDetailLine pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,5,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,5,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,10,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,15,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,20,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,25,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,50,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,75,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,100,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,200,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(false,pdl1,300,'10',2,'Yes','comment');
		pdl2 = PriceDetailLine.insertPriceDetailIntoLine(true,pdl1,500,'10',2,'Yes','comment');
    }

}