/**
* @author MDK
* @date 10/10/17
* @description Batch to archive the Sales Allocations
* <pre>
* </pre>
*/
global class ArchiveSalesAllocationsBatch extends ParentBatch implements Database.Batchable<sObject>, Database.Stateful {

    // Query to select the Sales Allocations
    private String query = ''
            + 'SELECT '
            + '    Sales_Team__c,'
            + '    ToArchiveWithValidFrom__c,'
            + '    ToArchiveWithValidTo__c,'
            + '    Account__c,'
            + '    Product_Sub_Segment__c,'
            + '    Tech_SalesTeam_Overlap__c,'
            + '    Sales_Team__r.Kam__c '                                  
            + 'FROM '
            + '    Sales_Allocations__c '
            + 'WHERE '
            + '     ToArchiveWithValidTo__c != null '
            + ' AND ToArchiveWithValidFrom__c != null';
     
    global archiveSalesAllocationsBatch() {
     
    }
    
    global archiveSalesAllocationsBatch(String query) {
        this.query = query;
    }

    global override String getBatchName() {
        return 'archiveSalesAllocationsBatch';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sales_Allocations__c> mySalesAllocations) {

        Savepoint sp = Database.setSavepoint();
        Boolean dmlIsSuccess = true;

        List<Database.SaveResult> updateResults = new List<Database.SaveResult>();        
        List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
        try {
            System.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute - debut de partie 1');
            system.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute : nbr Sales Allocations to insert = '+mySalesAllocations.size());
            insertResults = SalesAllocationsService.getInstance().archiveSalesAllocations(mySalesAllocations);
            updateResults = OpportunityService.getInstance().updateOpptyOwnerId(new Map<Id,Sales_Allocations__c>(mySalesAllocations)); 
            System.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute - fin de partie 1');
        } catch (DMLException e) {
            addErrors(mySalesAllocations, insertResults, 'Insert on Sales Allocations error : ');
            addErrors(mySalesAllocations, updateResults, 'Update on Opportunity error : ');           
            Database.rollback(sp);//added to rollback the transaction if the update failed
            throw e;
            dmlIsSuccess = false;
        }

        if (dmlIsSuccess) {
            try {
                System.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute - debut de partie 2');
                system.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute : nbr Sales Allocations to update = '+mySalesAllocations.size());
                updateResults = SalesAllocationsService.getInstance().resetSalesAllocationsArchivedDate(mySalesAllocations);
                System.debug(LoggingLevel.INFO, 'archiveSalesAllocationsBatch.execute - fin de partie 2');
            } catch (DMLException e) {
                addErrors(mySalesAllocations, updateResults, 'Update on Sales Allocations error : ');
                Database.rollback(sp);
                throw e;
            }
        }

    }

}