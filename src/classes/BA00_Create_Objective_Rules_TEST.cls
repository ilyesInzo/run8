/**
 * [ BA00_Create_Objective_Rules_TEST description : Unit Test Class for the script BA00_Create_Objective_Rules ]
 * @author EWA, ...
 * @version 1.0 - Initiale
 */
@isTest
public class BA00_Create_Objective_Rules_TEST {
    // Attributs of the class BA00_Create_Objective_Rules_TEST
    public Static String LOG_CLASS_NAME = 'BA00_Create_Objective_Rules_TEST';

    public static Integer TEST_SIZE = 10;

    // Methods for BA00_Create_Objective_Rules_TEST
    /**
     * [ init description : will initialize data for test purpopse]
     */
    @testSetup 
    private static void init() {
        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newKamUser(1000));
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1004));
        stUsers.add(TestFactory.newDirectorUser(1005));
        stUsers.add(TestFactory.newManagerUser(1006));
        stUsers.add(TestFactory.newAdditionalUser(1007));
        stUsers.add(TestFactory.newDirectorUser(1008));
        stUsers.add(TestFactory.newKamUser(1009));
        stUsers.add(TestFactory.newDirectorUser(1010));
        User admin = TestFactory.newUser('System Administrator',1011);
        admin.By_Pass_VR__c = true;
        stUsers.add(admin);     
        insert stUsers;        

        //Create country
        List<Country__c> countries = TestFactory.newCountry();
        insert countries;
    
        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
        insert distCountry1;
        
        //Create Sales Area
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create one Account for the bulk test
        Account acc1 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        insert acc1;

        //Create one Account for the bulk test
        Account acc2 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
        insert acc2;  

        //Create opportunity
        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = stUsers[0].Id;
        insert opp1;

        //Create opportunity
        Opportunity opp2 = TestFactory.newOpportunity('Opp2', 'Qualification', null, null, acc2.Id);
        opp2.OwnerId = stUsers[4].Id;
        opp2.Quote_Type__c = 'Retention';
        insert opp2;

        //Create opportunity with contract
        Opportunity opp3 = TestFactory.newOpportunity('Opp3', 'Qualification', null, null, acc2.Id);
        opp3.OwnerId = stUsers[0].Id;
        opp3.Quote_Type__c = 'Retention';
        opp3.Contract__c = 'Yes';
        opp3.Duration_Y__c = '3';
        insert opp3;

        //Create a Sales Team
        Sales_Team__c st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[1].id,stUsers[2].id,stUsers[3].id, 'TestSalesTeam1', '1111');
        insert st1;

        //Create a Sales Team
        Sales_Team__c st2 = TestFactory.newSalesTeam(stUsers[4].id,stUsers[6].id,stUsers[7].id,stUsers[8].id, 'TestSalesTeam2', '2222');
        insert st2;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < TEST_SIZE; i++) {
            productNames.add('name'+i);
        }
        List<Product2> products = TestFactory.newProducts(productNames);
        insert products;

        Id priceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Product2 p : products) {
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = priceBookId, 
                Product2Id = p.Id,
                UnitPrice = 100, 
                IsActive = true);
            pbEntries.add(standardPrice);
        }
        insert pbEntries;      

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for(Integer i=0; i < TEST_SIZE; i++) {
            Sales_Allocations__c sa = new Sales_Allocations__c();
            if (Math.mod(i,2) == 0 ) {
                sa = new Sales_Allocations__c(
                    Account__c              = acc1.id,
                    Product_sub_segment__c  = products[i].id,
                    Sales_team__c           = st1.id,
                    Valid_To__c             = SalesService.FUTURE_DATE,
                    Valid_From__c           = Date.today()
                );
            } else {
                sa = new Sales_Allocations__c(
                    Account__c              = acc2.id,
                    Product_sub_segment__c  = products[i].id,
                    Sales_team__c           = st2.id,
                    Valid_To__c             = SalesService.FUTURE_DATE,
                    Valid_From__c           = Date.today()
                );

            }            
            sas.add(sa);            
        }   
        insert sas; 

        //Create Plant Cluster
        List<Customer_Management_Area__c> cusManAreas = TestFactory.newCustomerManagementArea();
        insert cusManAreas;
        insert TestFactory.newPlantAndCluster(cusManAreas);

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = stUsers[0].Id;
        quote1.RFQ_Reception_Date__c = Date.today();
        insert quote1;

        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        qli1.Production_Cluster__c = 'Albea China';
        qli1.Production_Plant__c = 'HG';
        qli1.ID_Calculette__c = 'PM';
        qli1.Billing_Currency__c = 'American dollar';
        qli1.Sales_price_per_1000_KCur__c = 1;
        qli1.Tooling_sales_price_k_Cur__c = 100;
        insert qli1;

        Quote quote2 = TestFactory.newQuote(null, Date.today(), 'Draft', opp2.Id);
        quote2.OwnerId = stUsers[4].Id;
        quote2.RFQ_Reception_Date__c = Date.today();
        insert quote2;

        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote2.id,products[1].Id,pbEntries[1].Id);
        qli2.Production_Cluster__c = 'Rigid Packaging Europe';
        qli2.Production_Plant__c = 'SF';
        qli2.ID_Calculette__c = 'PM';
        qli2.Billing_Currency__c = 'American dollar';
        qli2.Sales_price_per_1000_KCur__c = 1;
        qli2.Tooling_sales_price_k_Cur__c = 100;
        insert qli2;

       /* Quote quote3= TestFactory.newQuote(null, Date.today(), 'Draft', opp3.Id);
        quote3.OwnerId = stUsers[0].Id;
        quote3.RFQ_Reception_Date__c = Date.today();
        insert quote3;

        QuoteLineItem qli3 = TestFactory.newQuoteLineItem(quote3.id,products[0].Id,pbEntries[0].Id);
        qli3.Production_Cluster__c = 'Beauty Solutions';
        qli3.Production_Plant__c = 'LT';
        qli3.ID_Calculette__c = 'PM';
        qli3.Billing_Currency__c = 'American dollar';
        qli3.Sales_price_per_1000_KCur__c = 1;
        qli3.Tooling_sales_price_k_Cur__c = 100;
        insert qli3;      */
    }

    /**
     * [ testMethod1 description : test linked to the plant with the HG code ]
     */
    @isTest
    static void testMethod1(){      
        List<User> users = [
            Select Id
            From User
            Where Matricule_ADS__c In ('1000','1001','1002','1003','1004','1005','1006','1007','1008','1009','1010')
        ];

        User admUsr = [
            Select Id
            From User
            Where Matricule_ADS__c = '1011'
        ];

        Quote quoteHG = [
            Select  AccountId,
                    Id,
                    IsSyncing,
                    Copy_Total_Amount_c__c,
                    Status
            From Quote
            Where Id In (Select QuoteId From QuoteLineItem Where Production_Plant__c = 'HG')
        ];

        List<Opportunity> opportunities = [
            Select  SyncedQuoteId,
                    CloseDate
            From Opportunity
        ];

        QuoteLineItem qliHG = [
            Select Product2Id
            From QuoteLineItem
            Where QuoteId = :quoteHG.Id
        ];     

        Plant_and_Cluster__c pacHG = [
            Select Id
            From Plant_and_Cluster__c
            Where Plant_Code__c = 'HG'
        ];  

        Test.startTest();              

        System.runAs(users[0]){
            // To calculate the Total Quantity we need to synchronize the Opportunity
            opportunities[0].SyncedQuoteId = quoteHG.Id;
            //opportunities[0].CloseDate = Date.;
            update opportunities[0];                   
    
            //Update Synced Quote to Won Status
            quoteHG.Main_compet_1__c = 'APOLLO';
            quoteHG.Raison_for_lost_on_won_quote__c = 'Quality';
            quoteHG.First_Delivery_Date__c = Date.today()-1;
            quoteHG.Date_Quote_Won__c = Date.today();
            quoteHG.Status = 'Won';
            update quoteHG;
        }

        System.runAs(admUsr){
            //Test Create Objective Batch
            Id batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
            //Run a second time to check existing Objectives
            batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
        }
        Test.stopTest();

        List<Objectives__c> objectivesHG = [
            Select  Account__c,
                    Plant__c,
                    Sub_Segment__c,
                    Date__c
            From Objectives__c
            Where Plant__c = :pacHG.Id
        ];

        System.assertEquals(objectivesHG[0].Account__c,quoteHG.AccountId);
        System.assertEquals(objectivesHG[0].Plant__c,pacHG.Id);
        System.assertEquals(objectivesHG[0].Sub_Segment__c,qliHG.Product2Id);
        System.assertEquals(objectivesHG[0].Date__c,date.newInstance(Date.today().year(),Date.today().month(),25));       
    }

    /**
     * [ testMethod2 : test linked to the plant with the SF code]
     */
    @isTest
    static void testMethod2(){   
        List<User> users = [
            Select Id
            From User
            Where Matricule_ADS__c In ('1000','1001','1002','1003','1004','1005','1006','1007','1008','1009','1010')
        ];

        User admUsr = [
            Select Id
            From User
            Where Matricule_ADS__c = '1011'
        ];

        Quote quoteSF = [
            Select  AccountId,
                    Id,
                    IsSyncing,
                    Copy_Total_Amount_c__c,
                    Status
            From Quote
            Where Id In (Select QuoteId From QuoteLineItem Where Production_Plant__c = 'SF')
        ];


        List<Opportunity> opportunities = [
            Select  SyncedQuoteId,
                    CloseDate
            From Opportunity
        ];   

        QuoteLineItem qliSF = [
            Select Product2Id
            From QuoteLineItem
            Where QuoteId = :quoteSF.Id
        ];

        Plant_and_Cluster__c pacSF = [
            Select Id
            From Plant_and_Cluster__c
            Where Plant_Code__c = 'SF'
        ];

        Test.startTest();              

        System.runAs(users[4]){

            opportunities[1].SyncedQuoteId = quoteSF.Id;
            opportunities[1].CloseDate = Date.today();
            update opportunities[1];
            //Update Synced Quote to Lost Status
            quoteSF.Main_compet_1__c = 'APOLLO';
            quoteSF.Raison_for_lost_on_won_quote__c = 'Quality';
            quoteSF.First_Delivery_Date__c = Date.today()-1;
            quoteSF.Date_Quote_for_Lost__c = Date.today();
            quoteSF.Status = 'Lost';
            update quoteSF;                   

        } 

        System.runAs(admUsr){
            //Test Create Objective Batch
            Id batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
            //Run a second time to check existing Objectives
            batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
        }
                

        Test.stopTest();
      
        List<Objectives__c> objectivesSF = [
                    Select  Account__c,
                            Plant__c,
                            Sub_Segment__c,
                            Date__c
                    From Objectives__c
                    Where Plant__c = :pacSF.Id
        ];

        //Check if objectives have been inserted correctly
        System.assertEquals(objectivesSF[0].Account__c,quoteSF.AccountId);
        System.assertEquals(objectivesSF[0].Plant__c,pacSF.Id);
        System.assertEquals(objectivesSF[0].Sub_Segment__c,qliSF.Product2Id);
        System.assertEquals(objectivesSF[0].Date__c,date.newInstance(Date.today().year(),Date.today().month(),25));        
    }

    /**
     * [ testMethod3 description : test for the plant with the LT code ]
     */

     /*Commented by ALE, not the same process now
    @isTest
    static void testMethod3(){        
        List<User> users = [
            Select Id
            From User
            Where Matricule_ADS__c In ('1000','1001','1002','1003','1004','1005','1006','1007','1008','1009','1010')
        ];

        User admUsr = [
            Select Id
            From User
            Where Matricule_ADS__c = '1011'
        ];

        Quote quoteLT = [
            Select  AccountId,
                    Id,
                    IsSyncing,
                    Copy_Total_Amount_c__c,
                    Status
            From Quote
            Where Id In (Select QuoteId From QuoteLineItem Where Production_Plant__c = 'LT')
        ];

        List<Opportunity> opportunities = [
            Select  SyncedQuoteId,
                    CloseDate
            From Opportunity
        ];
    

        QuoteLineItem qliLT = [
            Select Product2Id,
            Total_Sales_value_for_Roll_up__c,
            quote.Date_Quote_Won__c
            From QuoteLineItem
            Where QuoteId = :quoteLT.Id
        ];

        Plant_and_Cluster__c pacLT = [
            Select Id
            From Plant_and_Cluster__c
            Where Plant_Code__c = 'LT'
        ]; 
 

        Test.startTest();              


        System.runAs(admUsr){

            opportunities[2].SyncedQuoteId = quoteLT.Id;
            opportunities[2].CloseDate = date.newInstance(integer.valueof(System.Label.LBL_Reference_Year_For_Objectives_Calculation) - 1, 1 , 25);
            
            update opportunities[2];

            //Update Synced Quote to Lost Status
            quoteLT.Main_compet_1__c = 'APOLLO';
            quoteLT.Raison_for_lost_on_won_quote__c = 'Quality';
            quoteLT.First_Delivery_Date__c = date.newInstance(integer.valueof(System.Label.LBL_Reference_Year_For_Objectives_Calculation) - 1, 1 , 25);
            quoteLT.Status = 'Won';
            quoteLT.Date_Quote_Won__c = system.today();
            update quoteLT;
            //On réupdate pour passer au dessus du workflow qui passe la date a today si quote passe a won
            quoteLT.Date_Quote_Won__c = date.newInstance(integer.valueof(System.Label.LBL_Reference_Year_For_Objectives_Calculation) - 1, 1 , 25);
            update quoteLT; 

        }
        

        System.runAs(admUsr){

            //Test Create Objective Batch
            Id batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
            //Run a second time to check existing Objectives
            batchJobId = Database.executeBatch(new BA00_Create_Objective_Rules());
        }
                
        Test.stopTest();

        List<Objectives__c> objectivesLT = [
            Select  Account__c,
                    Plant__c,
                    Sub_Segment__c,
                    Date__c
            From Objectives__c
            Where Plant__c = :pacLT.Id
        ];

        qliLT = [
            Select Product2Id,
            Total_Sales_value_for_Roll_up__c,
            quote.Date_Quote_Won__c
            From QuoteLineItem
            Where QuoteId = :quoteLT.Id
        ];

        System.assertEquals(objectivesLT[0].Account__c,quoteLT.AccountId);
        System.assertEquals(objectivesLT[0].Plant__c,pacLT.Id);
        System.assertEquals(objectivesLT[0].Sub_Segment__c,qliLT.Product2Id);
        
        System.Debug('objectivesLT size : ' +objectivesLT.size());
        System.assertEquals(objectivesLT.size(), math.min(qliLT.quote.Date_Quote_Won__c.monthsBetween(qliLT.quote.Date_Quote_Won__c.addyears(3)),  Date.newInstance(Integer.valueof(System.Label.LBL_Reference_Year_For_Objectives_Calculation),1,1).monthsBetween(qliLT.quote.Date_Quote_Won__c.addYears(3))) );
  
        
    }*/
}