/**
* Parent Class for interacting with Sales Objects
*   
* @author MDK
* @date 09/10/2017
*
*/
public abstract class SalesService {

	public static final Date YESTERDAY_DATE = (Date.today() - 1);
    public static final Date CURRENT_DATE = Date.today();
    public static final Date FUTURE_DATE = Date.newInstance(4000, 12, 31);
    public static final Map<Id,Profile> PROFILESBYID = new Map<Id,Profile>([Select Id,Name From Profile]);

}