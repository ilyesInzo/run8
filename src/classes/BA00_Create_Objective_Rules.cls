/**
 * [ BA00_Create_Objective_Rules description : ]
 * @author EWA, ...
 * @version 1.0 - Initiale
 * @history 1.0 - Initiale
 */
 global class BA00_Create_Objective_Rules implements Database.Batchable<SObject>{
    //Attributs of the class BA00_Create_Objective_Rules
    public String Query;
    private final Integer YEAR = Integer.valueOf(System.Label.LBL_Reference_Year_For_Objectives_Calculation);
    

    //Methods of the class BA00_Create_Objective_Rules
    global Database.QueryLocator start(Database.BatchableContext BC){

        Query = 'Select Quote.AccountId, Quote.Date_Quote_for_Lost__c,Quote.date_Quote_Won__c, Quote.Status,';
              Query += 'Quote.Opportunity.Quote_Type__c, Product2Id, Total_Sales_value_k__c,Production_Plant__c,';
              Query += 'Quote.Decision_date__c, Quote.Opportunity.Duration_Y__c, Quote.Opportunity.Contract__c ';
         Query += 'From QuoteLineItem ';
        Query += 'Where ((CALENDAR_YEAR(Quote.date_Quote_Won__c) >='+YEAR+' ';
          Query += 'AND Quote.Status=\'Won\') ';
           Query += 'OR (CALENDAR_YEAR(Quote.Date_Quote_for_Lost__c) >='+YEAR+' ';
          Query += 'AND Quote.Status=\'Lost\' ';
          Query += 'AND Quote.Opportunity.Quote_Type__c=\'Retention\') ';
           Query += 'OR (Quote.Opportunity.Contract__c= \'Yes\' ';
           Query += 'AND CALENDAR_YEAR(Quote.Decision_Date__c) >='+YEAR+' )) ';
           Query += 'AND (Production_Plant__c !=null ) ';
        Query += 'Order by Quote.date_Quote_Won__c ASC';
        system.debug('--- Query ---'+Query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){

        list<QuoteLineItem> quoteLineItems0 = scope;
        list<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        list<QuoteLineItem> quoteLineItemsContract = new List<QuoteLineItem>();

        for(QuoteLineItem qli : quoteLineItems0){
            if(qli.Quote.Opportunity.Contract__c == 'Yes'){
                quoteLineItemsContract.add(qli);
            }
            else{
                quoteLineItems.add(qli);
            }
        }

        //Process QuoteLineItemsContract
        Set<Id> AccIdsContract = new set<Id>();
        set<Id> product2IdsContract = new set<id>();
        set<String> plantsContract = new set<String>();
        
        For(QuoteLineItem qli : quoteLineItemsContract){

            AccIdsContract.add(qli.Quote.AccountId);           
            product2IdsContract.add(qli.Product2Id);
            plantsContract.add(qli.Production_Plant__c);
        }
        
        //Map valid Sales Allocation on Account
        map<String,Sales_Allocations__c> AccProduct2IdToSalesAllocMapContract = new map<String,Sales_Allocations__c>();
        
        For(Sales_Allocations__c Alloc : [select Id, Account__c, Product_Sub_Segment__c, Valid_To__c, Sales_Team__c, Sales_Team__r.KAM__c,
                                                 Sales_Team__r.Manager__c, Sales_Team__r.Director__c, Sales_Team__r.Additional__c,
                                                 Sales_Team__r.KAM__r.isActive,Sales_Team__r.Manager__r.isActive, Sales_Team__r.Director__r.isActive, Sales_Team__r.Additional__r.isActive 
                                            from Sales_Allocations__c 
                                           where Account__c in: AccIdsContract 
                                             and Product_Sub_Segment__c in: product2IdsContract 
                                             and Valid_To__c >= TODAY ]){
            AccProduct2IdToSalesAllocMapContract.put(Alloc.Account__c+'_'+Alloc.Product_Sub_Segment__c ,Alloc );    
        }
        
        //Map Plant id
        map<String,id> plantCodeMapContract = new map<String,id>();
        
        For(Plant_and_Cluster__c plant : [select id, Cluster_Name__c, Plant_Code__c 
                                            from Plant_and_Cluster__c 
                                           where Plant_Code__c in: plantsContract]){
            plantCodeMapContract.put(plant.Plant_Code__c ,plant.id);
        }
        
        
        
        //Map of Existing Objectives
        map<String,Objectives__c> objmapContract =  new map<String,Objectives__c>();
        
        For(Objectives__c obj : [Select Id, Date__c, Account__c, Sub_Segment__c, Plant__c, Plant__r.Plant_Code__c 
                                   FROM Objectives__c  
                                  Where Account__c in: AccIdsContract 
                                    and Sub_Segment__c in:product2IdsContract 
                                    and Plant__r.Plant_Code__c in:plantsContract] ){
            //Build Key
            String key = obj.Date__c.year()+'_'+obj.Date__c.month()+'_'+obj.Sub_Segment__c+'_'+obj.Account__c+'_'+obj.Plant__r.Plant_Code__c;
            system.Debug('clé objectif contrat : ' + key);
            //system.debug('---OBJ Key---'+key);
            objmapContract.put(key,obj);            
        }

        Set<Objectives__c> newObjectivesSet = new set<Objectives__c>();
        
        //Check objective for each Quoteline item
        For(QuotelineItem qli : quoteLineItemsContract){

            //Create New Objectives for the Contract Duration
            //Integer duration = integer.valueof(qli.Quote.Opportunity.Duration_Y__c);
                for(Integer j=0; j<=11; j++){
                    Objectives__c newObjContract = new Objectives__c();
                    newObjContract.Account__c = qli.Quote.AccountId;
                    newObjContract.Plant__c = plantCodeMapContract.get(qli.Production_Plant__c);
                    newObjContract.Sub_Segment__c = qli.Product2Id;
                    newObjContract.Date__c = qli.Quote.Decision_Date__c.addMonths(j);
                    newObjContract.Date__c = date.newInstance(newObjContract.Date__c.YEAR(), newObjContract.Date__c.MONTH(), 25);
                    //Integer yearDecision = qli.Quote.Decision_date__c.YEAR();
                    String Key = newObjContract.Date__c.YEAR() +'_'+ newObjContract.Date__c.MONTH() +'_'+qli.Product2Id+'_'+qli.Quote.AccountId+'_'+qli.Production_Plant__c;

                    /*if(!objmapContract.containsKey(Key)){
                        if(date.newInstance(yearDecision, j, 25) >= date.newInstance(YEAR, 1, 1) && date.newInstance(yearDecision, j, 25)>= qli.Quote.Decision_Date__c){
                        newObjContract.Date__c = date.newInstance(yearDecision, j, 25);
                    }
                    }
                    if (newObjContract.Date__c !=  null) {

                        if(AccProduct2IdToSalesAllocMapContract.containsKey(qli.Quote.AccountId+'_'+qli.Product2Id)){               
                            newObjContract.Sales_Allocation__c =  AccProduct2IdToSalesAllocMapContract.get(qli.Quote.AccountId+'_'+qli.Product2Id).id;
                        }
                        newObjectivesSet.add(newObjContract);                
                    }*/
                    if (!objmapContract.containsKey(Key)) {

                        if(AccProduct2IdToSalesAllocMapContract.containsKey(qli.Quote.AccountId+'_'+qli.Product2Id)){               
                            newObjContract.Sales_Allocation__c =  AccProduct2IdToSalesAllocMapContract.get(qli.Quote.AccountId+'_'+qli.Product2Id).id;
                        }
                        newObjectivesSet.add(newObjContract);                
                    }
                    

                }


        }//End of Process QuoteLine Items Contract

        Set<Integer> months = new set<Integer>();
        Set<Id> AccIds = new set<Id>();
        set<Id> product2Ids = new set<id>();
        set<String> plants = new set<String>();
        
        For(QuoteLineItem qli : quoteLineItems){
            if(qli.Quote.Status =='Won'){
                months.add(qli.Quote.date_Quote_Won__c.month());
            }
            if(qli.Quote.Status =='Lost'){
                months.add(qli.Quote.Date_Quote_for_Lost__c.month());
            }
            
            AccIds.add(qli.Quote.AccountId);           
            product2Ids.add(qli.Product2Id);
            plants.add(qli.Production_Plant__c);
        }
        
        //Map valid Sales Allocation on Account
        map<String,Sales_Allocations__c> AccProduct2IdToSalesAllocMap = new map<String,Sales_Allocations__c>();
        
        For(Sales_Allocations__c Alloc : [select Id, Account__c, Product_Sub_Segment__c, Valid_To__c, Sales_Team__c, Sales_Team__r.KAM__c,
                                                 Sales_Team__r.Manager__c, Sales_Team__r.Director__c, Sales_Team__r.Additional__c, Sales_Team__r.KAM__r.isActive,
                                                 Sales_Team__r.Manager__r.isActive, Sales_Team__r.Director__r.isActive, Sales_Team__r.Additional__r.isActive
                                            from Sales_Allocations__c 
                                           where Account__c in: AccIds 
                                             and Product_Sub_Segment__c in: product2Ids 
                                             and Valid_To__c >= TODAY ]){
            AccProduct2IdToSalesAllocMap.put(Alloc.Account__c+'_'+Alloc.Product_Sub_Segment__c ,Alloc );    
        }
        
        //Map Plant id
        map<String,id> plantCodeMap = new map<String,id>();
        
        For(Plant_and_Cluster__c plant : [select id,Cluster_Name__c,Plant_Code__c from Plant_and_Cluster__c where Plant_Code__c in:plants]){

            plantCodeMap.put(plant.Plant_Code__c ,plant.id);
        }
        
        
        
        //Map of Existing Objectives
        map<String,Objectives__c> objmap =  new map<String,Objectives__c>();
        
        For(Objectives__c obj : [Select Id, Date__c, Account__c, Sub_Segment__c, Plant__c, Plant__r.Plant_Code__c 
                                   FROM Objectives__c  
                                  Where CALENDAR_YEAR(Date__c) >=:YEAR  
                                    and CALENDAR_MONTH(Date__c) in: months 
                                    and Account__c in: AccIds 
                                    and Sub_Segment__c in: product2Ids 
                                    and Plant__r.Plant_Code__c in:plants ] ){

            //Build Key
            String key = obj.Date__c.year()+'_'+obj.Date__c.month()+'_'+obj.Sub_Segment__c+'_'+obj.Account__c+'_'+obj.Plant__r.Plant_Code__c;
            
            //system.debug('---OBJ Key---'+key);
            objmap.put(key,obj);            
        }

        //Set<Objectives__c> newObjectivesSet = new set<Objectives__c>();
        
        //Check objective for each Quoteline item
        For(QuotelineItem qli : quoteLineItems){

            //Create New Objective
            Objectives__c newObj = new Objectives__c();
            newObj.Account__c = qli.Quote.AccountId;
            newObj.Plant__c = plantCodeMap.get(qli.Production_Plant__c);
            newObj.Sub_Segment__c = qli.Product2Id;

            if (qli.Quote.Status == 'Won'){

                String Key = qli.Quote.date_Quote_Won__c.year()+'_'+qli.Quote.date_Quote_Won__c.month()+'_'+qli.Product2Id+'_'+qli.Quote.AccountId+'_'+qli.Production_Plant__c;
                system.debug('---QLI Key---'+key);
                
                if(!objmap.containsKey(Key)){

                    //Create New Objective
                    newObj.Date__c = date.newInstance(qli.Quote.date_Quote_Won__c.year(), qli.Quote.date_Quote_Won__c.month(), 25);                  
                }               
                
                } else if (qli.Quote.Status == 'Lost'){

                    String Key = qli.Quote.Date_Quote_for_Lost__c.year()+'_'+qli.Quote.Date_Quote_for_Lost__c.month()+'_'+qli.Product2Id+'_'+qli.Quote.AccountId+'_'+qli.Production_Plant__c;
                    system.debug('---QLI Key---'+key);

                    if(!objmap.containsKey(Key)){                                      
                        newObj.Date__c = date.newInstance(qli.Quote.Date_Quote_for_Lost__c.year(), qli.Quote.Date_Quote_for_Lost__c.month(), 25);                   
                    }               
                }

            //Set Sales Allocation 
            if (newObj.Date__c !=  null) {

                if(AccProduct2IdToSalesAllocMap.containsKey(qli.Quote.AccountId+'_'+qli.Product2Id)){               
                    newObj.Sales_Allocation__c =  AccProduct2IdToSalesAllocMap.get(qli.Quote.AccountId+'_'+qli.Product2Id).id;
                }
                newObjectivesSet.add(newObj);                
            }


        }//End of Process QuoteLine Items
        
        //Process New Objectives
        List<Objectives__c> createObjectives = new list<Objectives__c>();
        createObjectives.addAll(newObjectivesSet);
        
        if(createObjectives.size()>0){
            system.Debug('objectives : ' + createObjectives);
            //Create New Objectives
            insert createObjectives;
            
            //Create New Objective Shares
            //AP01_Objective_Rules.kamObjectiveshare(createObjectives);
            
            List<Objectives__Share> objectiveShare = new List<Objectives__Share>();
            
            For(Objectives__c newObj : createObjectives){

                //Check if Allocation Exists
                if(AccProduct2IdToSalesAllocMap.containsKey(newObj.Account__c+'_'+newObj.Sub_Segment__c)){

                    Sales_Allocations__c alloc = AccProduct2IdToSalesAllocMap.get(newObj.Account__c+'_'+newObj.Sub_Segment__c);
                    
                    if(alloc.Sales_Team__r.KAM__c != null && alloc.Sales_Team__r.KAM__r.isActive == true) {
                        Objectives__Share objShr  = new Objectives__Share();
                        objShr.ParentId = newObj.Id;
                        objShr.AccessLevel = 'Edit';
                        objShr.UserOrGroupId = alloc.Sales_Team__r.KAM__c;
                        objShr.RowCause = 'Alloc__c';
                        objectiveShare.add(objShr);
                    }
                    if(alloc.Sales_Team__r.Manager__c != null && alloc.Sales_Team__r.Manager__r.isActive == true) {
                        Objectives__Share objShr  = new Objectives__Share();
                        objShr.ParentId = newObj.Id;
                        objShr.AccessLevel = 'Edit';
                        objShr.UserOrGroupId = alloc.Sales_Team__r.Manager__c;
                        objShr.RowCause = 'Alloc__c';
                        objectiveShare.add(objShr);
                    }
                    if(alloc.Sales_Team__r.Director__c != null && alloc.Sales_Team__r.Director__r.isActive == true) {
                        Objectives__Share objShr  = new Objectives__Share();
                        objShr.ParentId = newObj.Id;
                        objShr.AccessLevel = 'Edit';
                        objShr.UserOrGroupId = alloc.Sales_Team__r.Director__c;
                        objShr.RowCause = 'Alloc__c';
                        objectiveShare.add(objShr);
                    }
                    if(alloc.Sales_Team__r.Additional__c != null && alloc.Sales_Team__r.Additional__r.isActive == true) {
                        Objectives__Share objShr  = new Objectives__Share();
                        objShr.ParentId = newObj.Id;
                        objShr.AccessLevel = 'Edit';
                        objShr.UserOrGroupId = alloc.Sales_Team__r.Additional__c;
                        objShr.RowCause = 'Alloc__c';
                        objectiveShare.add(objShr);
                    }
                }
            }//End of Process Objective Shares
            insert objectiveShare;
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

        //Runs BA01_Objective_Rules to recalculate Objectives just after finish
        Database.executeBatch(new BA01_Objective_Rules());
        
    }
    

}