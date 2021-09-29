@isTest
private class LC00_DependentPicklistCtrl_TEST {
    /*
    static testMethod void saveField_Test(){
             //Create Test Users for the Teams
         List<User> users = new List<User>();
         String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];

    
          for(integer i=1; i<=10; i++){
            String orgId = 'Albea';
                       
            User tuser = new User(  firstname = 'test',
                                    lastName = 'user'+i,
                                    email = 'test_user'+i+ '@test' + orgId + '.com',
                                    Username = 'test_user'+i+ '@test' + orgId + '.com',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = 'test'+i,
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    Additional__c = true,
                                    Director__c = true,
                                    KAM__c = true,
                                    Matricule_ADS__c = string.valueof(i+1000),
                                    Manager__c = true,
                                    ProfileId = KAM.id);
            users.add(tuser);                               
        }
        
        users[0].ProfileId = KAM.id;
        users[4].ProfileId = KAM.id;
        insert users;
        
        System.runAs(users[0]){
         //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
        
        //Create Test Accounts
        Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        insert acc;
        
        Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        insert acc2;
        
        //Create Test Sales Teams
        Sales_Team__c team1 = new Sales_Team__c();
        team1.KAM__c = users[0].id;
        team1.Manager__c = users[1].id;
        team1.Director__c = users[2].id;
        //team1.Additional__c = users[3].id;
        team1.Valid_From__c = Date.today().addYears(-1);
        team1.Valid_To__c = Date.today().addYears(3);
        team1.Sales_Team__c = 'test team 1';
        
        insert team1;
        
        Sales_Team__c team2 = new Sales_Team__c();
        team2.KAM__c = users[4].id;
        team2.Manager__c = users[5].id;
        team2.Director__c = users[6].id;
        //team2.Additional__c = users[7].id;
        team2.Valid_From__c = Date.today().addYears(-1);
        team2.Valid_To__c = Date.today().addYears(3);
        team2.Sales_Team__c = 'test team 2';
        insert team2;
        
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
        insert q;
        
        Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Bottle');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', 
                                     Family = 'Tube');
        insert prod2;
      
    
      PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 5000, IsActive = true);
        insert standardPrice2;
    
    
    //Create Team Allocation 1
        Sales_Allocations__c alloc1 = new Sales_Allocations__c();
        alloc1.Account__c = acc.id;
        alloc1.Sales_Team__c = team1.id;
        alloc1.Product__c = 'BTL';
        alloc1.Product_Sub_Segment__c = prod.id;
        alloc1.Valid_From__c = Date.today().addYears(-2);
        alloc1.Valid_To__c = Date.today().addYears(1);
        
        insert alloc1;
        
        Sales_Allocations__c alloc2 = new Sales_Allocations__c();
        alloc2.Account__c = acc2.id;
        alloc2.Sales_Team__c = team2.id;
        alloc2.Product__c = 'BTL';
        alloc2.Product_Sub_Segment__c = prod2.id;
        alloc2.Valid_From__c = Date.today().addYears(-1);
        alloc2.Valid_To__c = Date.today().addYears(1);
        
        insert alloc2;
        
        
        
      //Insert QLI
      QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                              Product2Id = prod.id, QuoteId = q.Id
                                              );
       
            
        insert qli;
    
    
    
    
        PM_Selected_Tubes_Config__c pms = new PM_Selected_Tubes_Config__c(Cap_Aspect__c='Opaque', Diameter_mm__c=50, Head_Name__c='ER3', Dispensing_System_Family__c='Twist-off', Location__c='EU');
        qli.Location__c = 'EU';
        update qli;
        
        Map<String, String> mapfilters = new Map<String, String>();
        mapfilters.put('Quote_item__c', qli.Id);
        mapfilters.put('Product_Segment__c', 'Plastic');
        mapfilters.put('Location__c', 'EU');
        
        pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
        pms = (PM_Selected_Tubes_Config__c)LC01_SelectedProductConfigCtrl.getSelectedConfig(pms, mapfilters);
                
        Id pmId = pms.Id;
        
        List <PM_Selected_Tubes_Config__c> pmList = [SELECT Id, Cap_Aspect__c
                                                        FROM PM_Selected_Tubes_Config__c
                                                        WHERE Id =:pmId];
                           
            PM_Selected_Tubes_Config__c pmTest = (PM_Selected_Tubes_Config__c)LC00_DependentPicklistCtrl.saveField('PM_Selected_Tubes_Config__c', 'Cap_Aspect__c', 'Opaque', pmId); 
           }                             
        
    }
    
    //Scenario: Testing if the correct diameter_mm__c values are obtained when when 'Oval' value of Shape__c is selected.
    //Expected Value: Diameter values when Shape__c = 'Oval' (30, 35, 40, 50)
    static testMethod void getValuesTest_DependsOnOnlyOne(){
        //30, 35, 40, 50
        List<String> ovalDiameterValues = new List<String>(); 
        ovalDiameterValues.add('30'); 
        ovalDiameterValues.add('35'); 
        ovalDiameterValues.add('40'); 
        ovalDiameterValues.add('50');
        
        PM_Tubes_Config__c pmtc1 = new PM_Tubes_Config__c(Shape__c='Oval', Diameter_mm__c= 30, Location__c='EU', Table_name__c='Diameter');
        PM_Tubes_Config__c pmtc2 = new PM_Tubes_Config__c(Shape__c='Oval', Diameter_mm__c=35, Location__c='EU', Table_name__c='Diameter');
        PM_Tubes_Config__c pmtc3 = new PM_Tubes_Config__c(Shape__c='Oval', Diameter_mm__c=40, Location__c='EU', Table_name__c='Diameter');
        PM_Tubes_Config__c pmtc4 = new PM_Tubes_Config__c(Shape__c='Oval', Diameter_mm__c=50, Location__c='EU', Table_name__c='Diameter');
        System.debug(pmtc1);
        System.debug(pmtc2);
        System.debug(pmtc3);
        System.debug(pmtc4);
        
        List<PM_Tubes_Config__c> listPmtc = new List<PM_Tubes_Config__c>();
        listPmtc.add(pmtc1);
        listPmtc.add(pmtc2);
        listPmtc.add(pmtc3);
        listPmtc.add(pmtc4);
        
        insert listPmtc;
        
        Map<String,String> dependsOnSelectedValues = new Map<String,String>(); //Shape__c = Oval
        dependsOnSelectedValues.put('Shape__c', 'Oval');
        
        Test.startTest();
        List<String> testListValues = new List<String>(LC00_DependentPicklistCtrl.getValues('diameter_mm__c', 'Diameter', 'EU', 'PM_Tubes_Config__c', dependsOnSelectedValues));
        Test.stopTest(); 
        
        System.debug('Test List Values: '+testListvalues);
        System.assertEquals(testListValues, ovalDiameterValues);
    }
    
    //Scenario: Testing if the correct Fill Capacity values are obtained when Shape__c = 'Cylindrical' AND diameter_mm__c = '22', that is, when a field depends on more than one field.
    //Expected Value: Fill capacity values when Shape__c = 'Cylindrical' AND Diameter_mm__c = '22' ('10','15','20','25','30')
    static testMethod void getValuesTest_DependsOnMore(){
        List<String> fillCapacityValues = new List<String>(); 
        fillCapacityValues.add('10'); 
        fillCapacityValues.add('15'); 
        fillCapacityValues.add('20'); 
        fillCapacityValues.add('25');
        fillCapacityValues.add('30');
        
        PM_Tubes_Config__c pmtc1 = new PM_Tubes_Config__c(Shape__c='Cylindrical', Diameter_mm__c= 22, Fill_Capacity_ml__c=10.00, Location__c='EU', Table_name__c='Capacity & length');
        PM_Tubes_Config__c pmtc2 = new PM_Tubes_Config__c(Shape__c='Cylindrical', Diameter_mm__c= 22, Fill_Capacity_ml__c=15.00, Location__c='EU', Table_name__c='Capacity & length');
        PM_Tubes_Config__c pmtc3 = new PM_Tubes_Config__c(Shape__c='Cylindrical', Diameter_mm__c= 22, Fill_Capacity_ml__c=20.00, Location__c='EU', Table_name__c='Capacity & length');
        PM_Tubes_Config__c pmtc4 = new PM_Tubes_Config__c(Shape__c='Cylindrical', Diameter_mm__c= 22, Fill_Capacity_ml__c=25.00, Location__c='EU', Table_name__c='Capacity & length');
        PM_Tubes_Config__c pmtc5 = new PM_Tubes_Config__c(Shape__c='Cylindrical', Diameter_mm__c= 22, Fill_Capacity_ml__c=30.00, Location__c='EU', Table_name__c='Capacity & length');
        System.debug(pmtc1);
        System.debug(pmtc2);
        System.debug(pmtc3);
        System.debug(pmtc4);
        System.debug(pmtc5);
        
        List<PM_Tubes_Config__c> listPmtc = new List<PM_Tubes_Config__c>();
        listPmtc.add(pmtc1);
        listPmtc.add(pmtc2);
        listPmtc.add(pmtc3);
        listPmtc.add(pmtc4);
        listPmtc.add(pmtc5);
        
        insert listPmtc;
        
         
        Map<String,String> dependsOnSelectedValues = new Map<String,String>(); //Shape__c = Oval, Diameter_mm__c = 22
        dependsOnSelectedValues.put('Shape__c', 'Cylindrical');
        dependsOnSelectedValues.put('Diameter_mm__c', '22');
        
        Test.startTest();
        List<String> testListValues = new List<String>(LC00_DependentPicklistCtrl.getValues('Fill_Capacity_ml__c', 'Capacity & length', 'EU', 'PM_Tubes_Config__c', dependsOnSelectedValues));
        Test.stopTest();
        
        System.debug('Test List Values: '+testListValues);
        System.assertEquals(testListValues, fillCapacityValues);
    }
    
    static testMethod void buildWhereConditionTest_CondIsBlank(){
      PM_Tubes_Config__c newObj = new PM_Tubes_Config__c(Shape__c='Oval', Table_name__c='Shape', Location__c='EU' );
      
      insert newObj;
      
      Map<String, String> dependsOnSelectedValues = new Map<String, String>();
      dependsOnSelectedValues.put('Diameter_mm__c', '');
      //empty map
      String expCondition = ' WHERE Diameter_mm__c = null';
      
      Test.startTest();
        String testCondition = LC00_DependentPicklistCtrl.buildWhereCondition('PM_Tubes_Config__c', 'Diameter', 'EU', dependsOnSelectedValues);
      Test.stopTest();
      
      System.debug('Condition statement: '+testCondition);
      System.assertEquals(expCondition, testCondition);
      
    }
    */
}