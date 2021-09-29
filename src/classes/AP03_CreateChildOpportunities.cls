global class AP03_CreateChildOpportunities {
	/*
	*This class is used for creating child opportunities with attached Quote and Quotelineitems
	* from a parent opportunity in case of this one has a contract of more than 1 year
	* this class will be called from a process builder on Opportunity Object
	*/
	@InvocableMethod(label='Create Childs' description='Create child opportunities with attached Quote and Quotelineitems')
	public static void createChildOpportunities(List<Opportunity> liParentOpportunity) {
		system.debug('--------- START createChildOpportunities --------------');
		List<Id> ParentOppId = new List<Id>();
        for(Opportunity opp:liParentOpportunity){
            ParentOppId.add(opp.id);
        }
        createChildOpportunitiesFuture(ParentOppId);
    }
    
    @Future    
    public static void createChildOpportunitiesFuture(List<Id> liParentOpportunityId) {
		system.debug('--------- START createChildOpportunities --------------');
        
        List<Opportunity> liParentOpportunity = [select id,Duration_Y__c,Name,CloseDate,ContractId,AccountID,Quote_Type__c,SyncedQuoteId
                                                 from Opportunity where id in :liParentOpportunityId];
		//Variables' declaration
		string idOpps = '(';
		string idQuotes = '(';
		map<id,quote> mapSyncQuotes = new map<id,quote>();
		map<id,Quotelineitem> mapQuotelineitems = new map<id,Quotelineitem>();
		map<id,Integer> mapIdOppToNbYearOfContract = new map<id,Integer>();
		List<Opportunity> liOppToCreate = new List<Opportunity>();
		List<Quote> liQuoteToCreate = new List<Quote>();
		List<QuoteLineItem> liQliToCreate = new List<QuoteLineItem>();
		map<id,Opportunity> mapOppToClone = new map<id,Opportunity>();
		
		//loop through parent opportunities
		for(Opportunity oppToClone : liParentOpportunity){ 
			//Get Opp IDs
			idOpps= idOpps+'\''+oppToClone.id+'\'';
			mapIdOppToNbYearOfContract.put(oppToClone.id, integer.valueof(oppToClone.Duration_Y__c));
			mapOppToClone.put(oppToClone.id,oppToClone);
		}//end for liParentOpportunity 
		idOpps=idOpps+')';
		system.debug('idOpps : ' + idOpps);
		//Get synchronized Quote		
		String querySyncQuotes = DAL.generateSELECTQuery('Quote')+' Where IsSyncing=true AND OpportunityID in  '+idOpps;
		mapSyncQuotes = new Map<Id, Quote>( (List<Quote>) Database.query(querySyncQuotes)) ;
		for(ID idQte : mapSyncQuotes.keyset()){
			//Get Quote IDs
			idQuotes= idQuotes+'\''+idQte+'\'';
		}//end for  
		idQuotes=idQuotes+')';
		//Get Quote line item(s)
		String queryQuotelineitems = DAL.generateSELECTQuery('Quotelineitem')+' Where QuoteID in  '+idQuotes;

		system.Debug('mapSyncQuotes : ' + mapSyncQuotes);
		mapQuotelineitems = new Map<Id, Quotelineitem>( (List<Quotelineitem>) Database.query(queryQuotelineitems)) ;
			
		for(Opportunity opp : liParentOpportunity){
	    	//loop through nmber of years in contract
	    	for(Integer i=2;i<=mapIdOppToNbYearOfContract.get(opp.id); i++){
		    	//create for each year an opportunity
		       	liOppToCreate.add( new Opportunity( 
		       		Name			= opp.Name +' '+i,
		       		stageName		= 'Need Analysis',
		       		CloseDate 		= opp.CloseDate,
		       		Contract__c		= 'Yes' ,
		       		ContractId		= opp.ContractId,
		       		AccountID 		= opp.AccountID,
		       		Quote_Type__c	= opp.Quote_Type__c,
		       		Duration_Y__c   = String.valueOf(Integer.Valueof(opp.Duration_Y__c) - (i-1)),
		       		Parent_Opportunity__c = opp.id));		        
	    	}//end for nbContract
		}//end for opp
		system.debug('opportunity insert : ' + liOppToCreate.size() + ' ' + liOppToCreate);		
		insert liOppToCreate;
		
		//Quote creatio

		Map<String,Quote> mapOldNewQuotes = new Map<String,Quote>();


		for(Opportunity newOpp : [select id,Name,SyncedQuoteID,parent_opportunity__c from Opportunity where parent_opportunity__c in :mapIdOppToNbYearOfContract.keyset()]){
			//attach cloned Opp to quote (with delivery date = N+x)

		    
		    Quote oldQte = mapSyncQuotes.get( mapOppToClone.get(newOpp.parent_opportunity__c).SyncedQuoteID);
		    Quote newQte = mapSyncQuotes.get( mapOppToClone.get(newOpp.parent_opportunity__c).SyncedQuoteID).clone(false,false,false,false);


		    //add Qlis to List (new ids will be set after quotes' insertion)

		    for(Quotelineitem qli : mapQuotelineitems.values()){
		    	if(qli.QuoteID == oldQte.Id){
		    		QuoteLineItem newQli = qli.clone(false,false,false,false);
		    		newQli.Item_name__c = newQli.Item_name__c + 'Year' + newOpp.Name.right(1);
		    		newQli.Contract_Yes_No__c = 'Yes';
		    		liQliToCreate.add(newQli);
		    	}
		    }		    

		    newQte.Name += 'Year' + newOpp.Name.right(1);
		    //newQte.First_Delivery_Date__c = newQte.First_Delivery_Date__c.addYears(Integer.valueOf(newOpp.Name.right(1))-1) ; 
		   	newQte.Status = 'Draft';
		    newQte.opportunityid = newOpp.id;
		    liQuoteToCreate.add(newQte);

		    mapOldNewQuotes.put(newOpp.Name.right(1),newQte);

		    newQte = new Quote();    	
		    	
		    		
		}//end quote

		system.Debug('----liQuoteToCreate---- '+liQuoteToCreate);	
		insert liQuoteToCreate;


		//Attributing qlis the new quotes
		system.debug('laaa : ' + mapOldNewQuotes.size());
		for(QuoteLineItem qli : liQliToCreate){
			qli.QuoteId = mapOldNewQuotes.get(qli.Item_name__c.right(1)).Id;			
		}

		system.Debug('----liQliToCreate---- '+liQliToCreate);
		insert liQliToCreate;

		//Sync Opp and Quote

		Map<String,String> mapQuoteOpp = new Map<String,String>();

		for(Quote qt : liQuoteToCreate){
			mapQuoteOpp.put(qt.OpportunityId, qt.Id);
		}

		List<Opportunity> liOppToSync = new List<Opportunity>();

		for(Opportunity opp : [Select id, SyncedQuoteId from Opportunity Where Id in : mapQuoteOpp.keySet()]){
			opp.SyncedQuoteId = mapQuoteOpp.get(opp.Id);
			liOppToSync.add(opp);
		}
		
		update liOppToSync;

		for(Quote qt : liQuoteToCreate){
			qt.Status = 'Won';
			//Prepare Bypass VR Quote not updatable when won
			qt.First_Delivery_Date__c = qt.First_Delivery_Date__c.addDays(1);			
		}

		update liQuoteToCreate;

		for(Quote qt : liQuoteToCreate){
			qt.date_Quote_Won__c = system.today().addYears(Integer.valueOf(qt.Name.right(1))-1);
			//Bypass VR Quote not updatable when won
			qt.First_Delivery_Date__c = system.today().addYears(Integer.valueOf(qt.Name.right(1))-1);			
		}

		update liQuoteToCreate;

		system.debug('end Create ChildOpportunities');

	    //CLose all Quotes to Won (the opp status will change automatically, standard process!)
	    
	    system.debug('--------- END createChildOpportunities --------------');
	  }//end method createChildOpportunities
}













		/*List<Opportunity> testOpp = [select id, //opportunity fields'
										(select id  , First_Delivery_Date__c//Quote fields'											
										from Quotes) 
									from Opportunity where id = :liParentOpportunity[0].id];
		
		
		system.debug('-------------------');
		system.debug(testOpp);
		system.debug('-------------------');
		*/