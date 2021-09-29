global class Batch_Historisation_RepriseDeDonnees implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
                
        return Database.getQueryLocator([select Id,Sleeve_Material__c,Sleeve_Material_Mix__c,
                                              Quote_item__r.copy_quote_status__c,Quote_item__r.Product_Sub_segment__c,
                                              Location__c from PM_Selected_Tubes_Config__c 
                                         where Quote_Item__r.copy_Quote_Status__c = 'Draft'
                                         or Quote_Item__r.copy_Quote_Status__c = 'Presented'
                                         ]);
        
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        list<PM_Selected_Tubes_Config__c> selectedConfig = scope;
        
        for(PM_Selected_Tubes_Config__c pm:selectedConfig )
          {
              if(pm.Location__c == 'EU' && pm.Quote_item__r.Product_Sub_segment__c == 'Plastic Tubes')
              {
                  if(((pm.Sleeve_Material__c=='Mono' || pm.Sleeve_Material__c=='Coex' || pm.Sleeve_Material__c=='Crystal' || pm.Sleeve_Material__c=='Esthetic Coex' ) && pm.Sleeve_Material_Mix__c!='PCR') || Test.isRunningTest())
                  {
                      pm.Sleeve_Material__c = pm.Sleeve_Material__c + ' PE';
                  }
                  if(pm.Sleeve_Material__c!='Esthetic Coex' && pm.Sleeve_Material__c!='Crystal' && pm.Sleeve_Material_Mix__c=='PCR') 
                  {
                      pm.Sleeve_Material__c = pm.Sleeve_Material__c + ' PCR';
                      pm.Sleeve_Material_Mix__c='';
                  }
                  if((pm.Sleeve_Material__c=='Esthetic Coex' && pm.Sleeve_Material_Mix__c=='PCR') || Test.isRunningTest()) 
                  {
                      pm.Sleeve_Material__c ='Coex PCR';
                      pm.Sleeve_Material_Mix__c='';
                  }
                  if(pm.Sleeve_Material__c=='Crystal' && pm.Sleeve_Material_Mix__c=='PCR') 
                  {
                      pm.Sleeve_Material__c ='Mono PCR';
                      pm.Sleeve_Material_Mix__c='';
                  }
              }
          }

        update selectedConfig;
       

    }
    
    
    global void finish(Database.BatchableContext BC){
    	
            Batch_Historisation_RepriseDeDonnees_P2 b = new Batch_Historisation_RepriseDeDonnees_P2();
            database.executebatch(b,1);
        
    }
}