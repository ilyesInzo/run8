trigger PlantSegUserTrigger_ManageSecuEinstein on Plant_Segment_Users__c (after insert,before delete) 
{

   if(Trigger.isInsert)
   {
       Map<ID,Plant_Segment_Users__c> listAddedSubSeg=new Map<ID,Plant_Segment_Users__c>([select id, User__c, User__r.id,RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Plant_and_Cluster__r.Cluster_Code__c, Product__r.ProductCode from Plant_Segment_Users__c where id IN :Trigger.New]);
    	Manage_Einstein_Security.Plant_Segment_Added(listAddedSubSeg);
   }
   if(Trigger.isDelete)
   {

       Map<ID,Plant_Segment_Users__c> listDeletSubSeg=new Map<ID,Plant_Segment_Users__c>([select id, User__c, User__r.id,RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Plant_and_Cluster__r.Cluster_Code__c, Product__r.ProductCode from Plant_Segment_Users__c where id IN :Trigger.Old]);
       Manage_Einstein_Security.Plant_Segment_Deleted(listDeletSubSeg);
   }
    
}