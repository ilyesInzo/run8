/**
 * Created by inzo on 23/09/2021.
 */

@IsTest
public with sharing class VisibilityTeamMemberServiceTest {

    // as the visibility update will be executed async we will remove the test setup
    // and insert in start/stop clause, so we can do our test
    @TestSetup
    public static void prepareDataToTest(){

        // Create Some Users
        // we will affect the user as Kam even if kam not checked for test purpose only
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newUser( 'A',  'A', 'SALES - KAM', true,
                true, true, true, 1000));

        stUsers.add(TestFactory.newUser( 'B',  'B', 'SALES - KAM', true,
                true, true, true, 1001));

        stUsers.add(TestFactory.newUser( 'C',  'C', 'SALES - KAM', true,
                true, true, true, 1002));

        stUsers.add(TestFactory.newUser( 'D',  'D', 'SALES - KAM', true,
                true, true, true, 1003));

        insert stUsers;

        //Create country
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;

        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = new Distribution_Channel__c(Name ='Test1',Distribution_Channel_Code__c='Test1',Language_Key__c='Test1');
        insert distCountry1;

        //Create Sales Area
        Sales_Area__c salesArea = new Sales_Area__c(Name='Test');
        insert salesArea;

        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;


        List<Account> accounts = new List<Account>();
        //Create one Account for the bulk test
        Account acc1 = TestFactory.newAccount(country.Id, distCountry1.Id, salesArea.Id, state.Id);
        acc1.Street__c= 'HLIF';
        accounts.add( acc1);

        acc1 = TestFactory.newAccount(country.Id, distCountry1.Id, salesArea.Id, state.Id);
        acc1.Street__c= 'HLIF';
        accounts.add( acc1);

        insert accounts;

        List<Product_Sub_segment__c> productSubSegments = new List<Product_Sub_segment__c>();

        productSubSegments.add( new Product_Sub_segment__c(
                Name = 'LAM'
        ));
        productSubSegments.add( new Product_Sub_segment__c(
                Name = 'PLA'
        ));
        productSubSegments.add( new Product_Sub_segment__c(
                Name = 'TCAP'
        ));

        insert productSubSegments;

        //Create some products
        List<Product2> products = new List<Product2>();

        products.add(new Product2(
                    Name = 'Laminate Tubes',
                    Family = 'Tubes',
                Product_Sub_Segment__c = productSubSegments[0].Id
            ));
        products.add(new Product2(
                Name = 'Plastic Tubes',
                Family = 'Tubes',
                Product_Sub_Segment__c = productSubSegments[1].Id
        ));
        products.add(new Product2(
                Name = 'Tubes Caps',
                Family = 'Tubes',
                Product_Sub_Segment__c = productSubSegments[2].Id
        ));
        products.add(new Product2(
                Name = 'Laminate Tubes',
                Family = 'Tubes',
                Product_Sub_Segment__c = productSubSegments[0].Id
        ));
        products.add(new Product2(
                Name = 'Plastic Tubes',
                Family = 'Tubes',
                Product_Sub_Segment__c = productSubSegments[1].Id
        ));

        insert products;
        List<Sales_Team__c> salesTeams = new List<Sales_Team__c>();
        //Create a Sales Team
        Sales_Team__c st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[0].id,stUsers[1].id,null);
        salesTeams.add(st1);

        st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[2].id,null,stUsers[2].id);
        salesTeams.add(st1);

        st1 = TestFactory.newSalesTeam(stUsers[3].id,stUsers[0].id,null,stUsers[2].id);
        salesTeams.add(st1);

        insert salesTeams;

        List<Sales_Allocations__c> salesAllocations = new List<Sales_Allocations__c>();
        //Create one Sales Allocations
        Sales_Allocations__c sa = new Sales_Allocations__c(
                Account__c				= accounts[0].id,
                Product_Sub_Segment__c 	= products[0].id,
                Sales_Team__c 			= salesTeams[0].id,
                Valid_To__c				= SalesService.FUTURE_DATE
        );
        salesAllocations.add(sa);
        sa = new Sales_Allocations__c(
                Account__c				= accounts[0].id,
                Product_Sub_Segment__c 	= products[1].id,
                Sales_Team__c 			= salesTeams[0].id,
                Valid_To__c				= SalesService.FUTURE_DATE
        );
        salesAllocations.add(sa);
        sa = new Sales_Allocations__c(
                Account__c				= accounts[0].id,
                Product_Sub_Segment__c 	= products[2].id,
                Sales_Team__c 			= salesTeams[1].id,
                Valid_To__c				= SalesService.FUTURE_DATE
        );
        salesAllocations.add(sa);
        sa = new Sales_Allocations__c(
                Account__c				= accounts[1].id,
                Product_Sub_Segment__c 	= products[3].id,
                Sales_Team__c 			= salesTeams[1].id,
                Valid_To__c				= SalesService.FUTURE_DATE
        );
        salesAllocations.add(sa);
        sa = new Sales_Allocations__c(
                Account__c				= accounts[1].id,
                Product_Sub_Segment__c 	= products[4].id,
                Sales_Team__c 			= salesTeams[2].id,
                Valid_To__c				= SalesService.FUTURE_DATE
        );
        salesAllocations.add(sa);
        insert salesAllocations;

        // we will need to add Opportunities also

    }

    @IsTest
    public static void testCheck(){

        // the salesAllocation before update trigger should be executed (if the async are executed)
        // otherwise we can't verify if the accountTeam were created without problem
        Test.startTest();
        List<Sales_Allocations__c> salesAllocations = [SELECT Id FROM Sales_Allocations__c];
        System.assert(salesAllocations.size() == 5);
        Test.stopTest();

    }

}