global class BA01_CountObjectifAccount_Schedule implements Schedulable{

    global void execute(SchedulableContext sc){
        
        BA01_CountObjectifAccount ba = new BA01_CountObjectifAccount();
        Database.executeBatch(ba, 200);
    }
    
}