public class Manage_Einstein_Security {

    //initialize product segment user multi value

    public static void  InitialLoad(List<User> userToUp)
    {
        //List<Plant_Segment_Users__c> listProductSgUsers=[select id, RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Plant_and_Cluster__r.Cluster_Code__c, User__r.id, User__r.Plant_List__c, User__r.Product_Sub_Segment_List__c, Product__r.ProductCode from Plant_Segment_Users__c];

        //Map<ID,User> userToUp=new Map<ID,User>([select id,Product_Sub_Segment_List__c, Plant_List__c,( select id, RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Product__r.ProductCode from Plant_Segment_Users__r) from User where Profile.Name='Plant' or  Profile.Name='Marketing' limit :limite]);
        //  List<User> userToUp=[select id,Product_Sub_Segment_List__c, Plant_List__c,( select id, RecordType.Name, Plant_and_Cluster__r.Plant_Code__c, Product__r.ProductCode from Plant_Segment_Users__r) from User where Profile.Name='Plant' or  Profile.Name='Marketing'];
        List<User> usersToUpdate=new List<User>();
        System.debug('nbRecords: '+userToUp.size());

        // Map<String,String> listUserPlanToUp=new Map<String,String>();
        // Map<String,String> listUserSubSegToUp=new Map<String,String>();

        //Set<ID> listUsersId=userToUp.keyset();
        //	Set<ID> listID=userToUp.keyset();
        //List<ID> listID=new List<ID>(listUsersId);
        // System.debug(listUsersId);

        for(User u:userToUp)
        {
            //System.debug('UserID: '+userID);
            //User u=userToUp.get(userID);
            List<Plant_Segment_Users__c> listSegUser=u.Plant_Segment_Users__r;

            if(listSegUser.size()>0)
            {
                System.debug('UserID: '+u.id);
                System.debug('nb SegUser: '+listSegUser.size());
                for(Plant_Segment_Users__c seguser: listSegUser)
                {
                    System.debug('RecordName:'+seguser.RecordType.Name);
                    if(seguser.RecordType.Name=='Plant')
                    {
                        if(u.Plant_List__c==null || u.Plant_List__c=='') u.Plant_List__c=seguser.Plant_and_Cluster__r.Plant_Code__c;
                        else
                        {
                            if(!(u.Plant_List__c.contains(seguser.Plant_and_Cluster__r.Plant_Code__c)))
                                u.Plant_List__c=u.Plant_List__c+';'+seguser.Plant_and_Cluster__r.Plant_Code__c;
                        }

                    }
                    else
                    {
                        if(u.Product_Sub_Segment_List__c==null || u.Product_Sub_Segment_List__c=='') u.Product_Sub_Segment_List__c=seguser.Product__r.ProductCode;
                        else
                        {
                            if(!(u.Product_Sub_Segment_List__c.contains(seguser.Product__r.ProductCode)))
                                u.Product_Sub_Segment_List__c=u.Product_Sub_Segment_List__c+';'+seguser.Product__r.ProductCode;
                        }
                    }
                }
                usersToUpdate.add(u);
            }
        }
        if(usersToUpdate.size()>0) update usersToUpdate;
    }

    //when a new record is created in in Prodect segment user
    public static void Plant_Segment_Added(Map<ID,Plant_Segment_Users__c> addedSegmentUsers)
	{
		Set<ID> listSegId=addedSegmentUsers.keySet();
		List<ID> listID=new List<ID>(listSegId); //list id prod SegmentUsers
		List<User> usersToUpdate=new List<User>();
		//Map<String,User> usersMap= new Map<String,User>();
		Map<String,String> userPlant=new Map<String,String>();
		Map<String,String> userMarketing=new Map<String,String>();

        for(String segUserID:listID)
		{
            Plant_Segment_Users__c segUser=addedSegmentUsers.get(segUserID);
			System.debug('subSegID: '+segUser.id);
			if(segUser.RecordType.Name=='Plant') //for users having Plant Profile
			{
                if(userPlant.containsKey(segUser.User__c))
				{
					System.debug('userID: '+segUser.User__c);
					String listplant=userPlant.get(segUser.User__c);
					String newPlantList=listplant+';'+segUser.Plant_and_Cluster__r.Plant_Code__c;
					userPlant.put(segUser.User__c,newPlantList);	
				}
				else userPlant.put(segUser.User__c,segUser.Plant_and_Cluster__r.Plant_Code__c);
				

			}else  //for Users having Marketing Profile
			{
				System.debug('userID: '+segUser.User__c);
                if(userMarketing.containsKey(segUser.User__c))
				{
					String listMark=userMarketing.get(segUser.User__c);
					String newMarkList=listMark+';'+segUser.Product__r.ProductCode;
					userMarketing.put(segUser.User__c,newMarkList);	
				}
				else userMarketing.put(segUser.User__c,segUser.Product__r.ProductCode);
			}
		}
		System.debug('List Users Id: '+userMarketing.KeySet());
		List<User> userToUp=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where id IN :userPlant.keySet() or id IN :userMarketing.keySet()];
        System.debug('nb user to update:'+userToUp.size());
		for(User u:userToUp)
		{
		         if(userPlant.containsKey(u.id))
				 {
					 if(u.Plant_List__c==null) u.Plant_List__c=userPlant.get(u.id);
					 else u.Plant_List__c=u.Plant_List__c+';'+userPlant.get(u.id);
				 }
				 else 
				 {
					if(u.Product_Sub_Segment_List__c==null) u.Product_Sub_Segment_List__c=userMarketing.get(u.id);
					else u.Product_Sub_Segment_List__c=u.Product_Sub_Segment_List__c+';'+userMarketing.get(u.id);
				 }
              
			  usersToUpdate.add(u);
		}
      
	  if(usersToUpdate.size() > 0) update usersToUpdate;
	}
 	
    //add method when a record is deleted in Plant_Segment_User
    public static void Plant_Segment_Deleted(Map<ID,Plant_Segment_Users__c> addedSegmentUsers)
    {
        Set<ID> listSegId=addedSegmentUsers.keySet();
        List<ID> listID=new List<ID>(listSegId); //list id prod SegmentUsers
        List<User> usersToUpdate=new List<User>();

        Map<String,String> userPlant=new Map<String,String>();
        Map<String,String> userMarketing=new Map<String,String>();

        for(String segUserID:listID)
        {
            Plant_Segment_Users__c segUser=addedSegmentUsers.get(segUserID);
            System.debug('subSegID: '+segUser.id);
            if(segUser.RecordType.Name=='Plant') //for users having Plant Profil
            {
                if(userPlant.containsKey(segUser.User__c))
                {
                    System.debug('userID: '+segUser.User__c);
                    String listplant=userPlant.get(segUser.User__c);
                    String newPlantList=listplant+';'+segUser.Plant_and_Cluster__r.Plant_Code__c;
                    userPlant.put(segUser.User__c,newPlantList);
                }
                else userPlant.put(segUser.User__c,segUser.Plant_and_Cluster__r.Plant_Code__c);


            }else  //for Users having Marketing Profil
            {
                System.debug('userID: '+segUser.User__c);
                if(userMarketing.containsKey(segUser.User__c))
                {
                    String listMark=userMarketing.get(segUser.User__c);
                    String newMarkList=listMark+';'+segUser.Product__r.ProductCode;
                    userMarketing.put(segUser.User__c,newMarkList);
                }
                else userMarketing.put(segUser.User__c,segUser.Product__r.ProductCode);
            }
        }
        System.debug('List Users Id: '+userMarketing.KeySet());
        List<User> userToUp=[select id,Product_Sub_Segment_List__c, Plant_List__c from User where id IN :userPlant.keySet() or id IN :userMarketing.keySet()];
        System.debug('nb user to update:'+userToUp.size());
        for(User u:userToUp)
        {
            if(userPlant.containsKey(u.id))
            {

                String newListVal=deletePlantORSegmFromList(u.Plant_List__c,userPlant.get(u.id));
                u.Plant_List__c=newListVal;
            }
            else
            {
                //if(==null) u.Product_Sub_Segment_List__c=userMarketing.get(u.id);
                String newListVal=deletePlantORSegmFromList(u.Product_Sub_Segment_List__c,userMarketing.get(u.id));
                u.Product_Sub_Segment_List__c=newListVal;
            }

            usersToUpdate.add(u);
        }

        if(usersToUpdate.size() > 0) update usersToUpdate;

    }

//need to use this function in order to delete the concerned plant or subsegments for which users
//don't have access any more.
    public static String deletePlantORSegmFromList(String initialList,String listToDel)
    {
        String result;
        if(initialList!=null && listToDel!='')
        {
            result = initialList.deleteWhitespace();
            System.debug('Init List: '+initialList);
            System.debug('List To Delete: '+listToDel);
            List<String> str=listToDel.split(';');

            for(String val:str)
            {
                result=result.remove(';'+val); //the value to delete is in the middle of the list.
                result=result.remove(val+';');
                result=result.remove(val);

            }

            System.debug('result: '+result);

        }
        return result;
    }
}