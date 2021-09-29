/**
 * <b>Unit class test for the PriceRecoClas</b>
 * @author EWA
 * @version 0.5 - Squelette
 * @history 0.5 - Squelette
 */
@isTest
private class PriceRecoTest {
	//Methods for the Class PriceRecoTest
	/**
	 * testSetup description
	 */
	@testSetup 
	static void testSetup(){
		//Adding a new PM_Discount_corridor__c 
		PM_Discount_corridor__c discountCorridor = TestFactory.newPMDiscountCorridor('EU','TestPeerGroup','DOMESTIC ACCOUNT','Selective Market',
			'Personal, Body & Hair Care', 'Laminate Tube', 'TPG', 100, 'TestCriteria1', 'TestCriteria2', 'TestCriteria3', 'TestCriteria4');
		insert discountCorridor;
	}

	/**
	 * [testConstructor description : will test the 3 constructors of the class]
	 */
	@isTest 
	static void testConstructor() {
		PM_Discount_corridor__c pmdc = [SELECT Location__c, customer_type__c, distribution_channel__c, macro_market__c, activity__c, Peer_Group__c, 
    											SKU__c, Criteria_1__c, Criteria_2__c, Criteria_3__c, Criteria_4__c, P20__c, P50__c, P80__c
		 								FROM PM_Discount_corridor__c
		 								LIMIT 1];

		//Test of the empty constructor
		PriceReco priceReco1 = new PriceReco();

		//Test of the full constructor
		PriceReco priceReco2 = new PriceReco(true, 10.0, true, true, '', 10.0, priceReco1);

		//Test of the last constructor
		PriceReco priceReco3 = new PriceReco('P20', 'P50', pmdc, 10.0);

		//Second Test of the full constructor
		PriceReco priceReco4 = new PriceReco(false, 10.0, false, false, '', 10.0, priceReco3);

	}	

	/**
	 * [testValidateDisplay description : will test the validate dsiplay of the class]
	 */
	@isTest
	static void testValidateDisplay(){
		//Test of the empty constructor
		PriceReco priceReco = new PriceReco();

		//Test validateDisplay;
		priceReco.validateDisplay();
	}
}