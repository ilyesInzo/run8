/**
* @author MDK
* @date 10/10/17
* @description scheduler for batch to archive the Sales Allocations
*
* <pre>
*
* Values of Cron expression  
* -------------------------
*
* Name          |  Values   | Special Characters
* Seconds       |  0–59     | None
* Minutes       |  0–59     | None
* Hours         |  0–23     | , - * /
* Day_of_month  |  1–31     | , - * ? / L W
* Month         |  1–12     | , - * /
* Day_of_week   |  1–7      | , - * ? / L #
*
* See : https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm
*
* </pre>
*/
global class ArchiveSalesAllocationsSchedulable implements Schedulable {

    /**
     * [execute description]
     * @param  sc [description]
     * @return    [description]
     */
    global void execute(SchedulableContext sc) {
        ArchiveSalesAllocationsBatch archiveSalesAllocations = new ArchiveSalesAllocationsBatch();
        Database.executeBatch(archiveSalesAllocations, Integer.valueOf(System.Label.SALESALLOCATION_ARCHIVE_BATCHSIZE));
    }

    /**
     * [schedule : instancie Prod schedulers]
     *            
     * @return [description]
     */
    global static List<Id> schedule() {
        List<Id> jobIds = new List<Id>();
        ArchiveSalesAllocationsSchedulable scheduler = new ArchiveSalesAllocationsSchedulable();
        Id jobID = System.schedule('ArchiveSalesAllocationsSchedulable - archive Sales Allocations every hour', '0 0 1 * * ?', scheduler); 
        jobIds.add(jobID);       
        return jobIds;
    }    

}