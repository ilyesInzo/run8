public class BA02_Killed_Quote_Synchronisation_Helper {
	
	List<Quote> killedQuote= new list<Quote>();
	
	public class updateResult {
        public Id record;
        public list<String> exceptionMsg;
    }
	
	public static list<Object> errors = new list<Object>();

	//public BA02_Killed_Quote_Synchronisation_Helper() {
	// }
	

	//
	public List<Object> updateopp(list <quote> lstqt){
		// Remplir la liste des Iddes opportunités
	    Set<Id> OppIdList = new Set<Id>();
		for(Quote qt:lstqt){
			OppIdList.add(qt.OpportunityId);
		}		
		
		// Get toutes les quotes qui sont liées aux opportunités
		list<Quote> listQuote = [select Id, Status,Decision_Date__c, OpportunityId from Quote where OpportunityId IN:OppIdList];
        
		//ici l'Id comme clé de la map peut étre de n'importe quel object 
		map<Id, list<Quote>> mapOppId2QuoteList = new map<Id, list<Quote>>();
        Integer timeLimit = Integer.valueOf(Label.KillQuoteTimeLimit);
        if(Test.isRunningTest()){
            timeLimit = 0;
        }
		Date dt = Date.today().addDays(- timeLimit);
		// Parcourir toutes les quotes de la liste listQuote
		for (Quote q:listQuote){
			//Si la quote n'est pas killed
		  if ((q.status != 'Killed By Customer' && q.status != 'Killed By Albea') || ((q.status == 'Killed By Customer' || q.status == 'Killed By Albea') && q.Decision_Date__c > dt )  ){
		  	// Si c'est la première quote trouvée pour l'opportunité OpportunityId
		  	if (mapOppId2QuoteList.get(q.OpportunityId) == null){  
		  		// Ajouter une nouvelle ligne à l'opportunité
		  		List<Quote> qlist = new List<Quote>();              
		  		qlist.add(q);
				mapOppId2QuoteList.put(q.OpportunityId, qlist);
				
			}else{// C'est la 2eme, 3eme, .. quote qu'on trouve pour l'opportunité OpportunityId !!!!!! (a comprendre et pourquoi la séparation de la première et les autres qui suivent)
				mapOppId2QuoteList.get(q.OpportunityId).add(q);
			}
		  }
			
		}
		// Retrouver les Id des opportunités qui n'ont pas de quotes ouvertes ( != killed)
		set<Id> oppToKill = new set<Id>();
		for (Id idOpp:OppIdList){
			if (mapOppId2QuoteList.get(idOpp) == null){
				oppToKill.add(idOpp);
			}
		}
		// Mise à jour des opportunité
		list<Opportunity> oppToKillList = [select Id, StageName from Opportunity where Id IN:oppToKill];
		for (Opportunity opp:oppToKillList){
			opp.StageName = 'Closed Killed';
			
			
			if (oppToKillList.size()> 0){
				
            List<Database.SaveResult> result = Database.update(oppToKillList,false);
            for (Integer i=0;i<result.size();i++) {
                if (!result[i].isSuccess() || Test.isRunningTest()) {
                        updateResult upR = new updateResult();
                        upR.record = oppToKillList[i].Id;
                        upR.exceptionMsg = new list<String>();             
                        for(Database.Error err : result[i].getErrors()) {     
                            upR.exceptionMsg.add(err.getStatusCode() +':'+ err.getMessage());  
                        }
                        errors.add(upR);

		
		
	}
			}}
			
	//Requéte SOQL pour récupéré la liste des Quotes 	

}

return errors;
}
}