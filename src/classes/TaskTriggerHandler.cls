public class TaskTriggerHandler extends TriggerHandler{
   
    private Map<Id,Task> oldTasksById;
    private Map<Id,Task> newTasksById;
    private List<Task> newTasks; 
    private List<Task> oldTasks;

    public TaskTriggerHandler() {
        this.oldTasksById = (Map<Id, Task>) Trigger.oldMap;
        this.newTasksById = (Map<Id, Task>) Trigger.newMap;
        this.newTasks = (List<Task>) Trigger.new;
        this.oldTasks = (List<Task>) Trigger.old; 
    }
 
    public override void afterInsert() {
        TaskService.EditTasksCountInObjectifLine(newTasks);
        TaskService.calculateGame(newTasks);
    }
    
    public override void afterUpdate() {
        
        List<Task> tasksToProcess = new List<Task>();
        tasksToProcess.addAll(newTasks);
        tasksToProcess.addAll(oldTasks);
        TaskService.EditTasksCountInObjectifLine(tasksToProcess);
    }
    
    public override void beforeInsert() {
        TaskService.createObjectifLine(newTasks);
    }
    
    public override void beforeUpdate() {
        TaskService.createObjectifLine(newTasks,oldTasksById);
    }
}