/**
* @author https://github.com/kevinohara80/sfdc-trigger-framework
* @date 
*
* @description Trigger Handler Interface
* <pre>
*
* Overview
* --------
*
* Triggers should (IMO) be logicless. Putting logic into your triggers creates un-testable, difficult-to-maintain code. It's widely accepted
* that a best-practice is to move trigger logic into a handler class.
* This trigger framework bundles a single TriggerHandler base class that you can inherit from in all of your trigger handlers. The base class
* includes context-specific methods that are automatically called when a trigger is executed.
* The base class also provides a secondary role as a supervisor for Trigger execution. It acts like a watchdog, monitoring trigger activity and
* providing an api for controlling certain aspects of execution and control flow.
* But the most important part of this framework is that it's minimal and simple to use.
*
* Usage
* -----
*
* To create a trigger handler, you simply need to create a class that inherits from TriggerHandler.cls. Here is an example for creating an 
* Opportunity trigger handler.
*
*		public class OpportunityTriggerHandler extends TriggerHandler {
*
* In your trigger handler, to add logic to any of the trigger contexts, you only need to override them in your trigger handler. Here is how 
* we would add logic to a beforeUpdate trigger.
*
*		public class OpportunityTriggerHandler extends TriggerHandler {
*
*		  public override void beforeUpdate() {
*		    for(Opportunity o : (List<Opportunity>) Trigger.new) {
*		      // do something
*		    }
*		  }
*
*		  // add overrides for other contexts
*
*		}
*
* Note: When referencing the Trigger statics within a class, SObjects are returned versus SObject subclasses like Opportunity, Account, etc. 
* This means that you must cast when you reference them in your trigger handler. You could do this in your constructor if you wanted.
*
*		public class OpportunityTriggerHandler extends TriggerHandler {
*
*		  private Map<Id, Opportunity> newOppMap;
*
*		  public OpportunityTriggerHandler() {
*		    this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
*		  }
*
*		  public override void afterUpdate() {
*    		//
*		  }
*
*		}
*
* To use the trigger handler, you only need to construct an instance of your trigger handler within the trigger handler itself and call the run() 
* method. Here is an example of the Opportunity trigger.
*
*		trigger OpportunityTrigger on Opportunity (before insert, before update) {
*  				new OpportunityTriggerHandler().run();
*		}
*
* ------------
* Cool Stuff :
* ------------
*
* -> Max Loop Count
*    --------------
*
* To prevent recursion, you can set a max loop count for Trigger Handler. If this max is exceeded, and exception will be thrown. 
* A great use case is when you want to ensure that your trigger runs once and only once within a single execution. Example:
*
*		public class OpportunityTriggerHandler extends TriggerHandler {
*
*		  public OpportunityTriggerHandler() {
*    		 this.setMaxLoopCount(1);
*  		  }
*
*  		  public override void afterUpdate() {
*    		List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Id IN :Trigger.newMap.keySet()];
*    		update opps; // this will throw after this update
*  		  }
*
* 		}
*
* -> Bypass API
*    ----------
*
* What if you want to tell other trigger handlers to halt execution? That's easy with the bypass api. Example.
*
* 		public class OpportunityTriggerHandler extends TriggerHandler {
*
* 			public override void afterUpdate() {
*    			List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :Trigger.newMap.keySet()];
*
*    			Account acc = [SELECT Id, Name FROM Account WHERE Id = :opps.get(0).AccountId];
*
*   			TriggerHandler.bypass('AccountTriggerHandler');
*
*    			acc.Name = 'No Trigger';
*    			update acc; // won't invoke the AccountTriggerHandler
*
*    			TriggerHandler.clearBypass('AccountTriggerHandler');
*
*    			acc.Name = 'With Trigger';
*    			update acc; // will invoke the AccountTriggerHandler
*
*  			}
*
*		}
*
* -> Overridable Methods
*    -------------------
*
* Here are all of the methods that you can override. All of the context possibilities are supported.
*
*    beforeInsert()
*    beforeUpdate()
*    beforeDelete()
*    afterInsert()
*    afterUpdate()
*    afterDelete()
*    afterUndelete()
*
* </pre>
*/
public virtual class TriggerHandler {	

  // static map of handlername, times run() was invoked
  private static Map<String, LoopCount> loopCountMap;
  public static Set<String> bypassedHandlers;
  public static Set<String> bypassedTriggers;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private TriggerContext context;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static {
    // Bypass Trigger From the User. To implemented or not
    User user=[SELECT Bypass_Trigger__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
    system.debug('ICI : ' + user.Bypass_Trigger__c + ' ');
      if (user.Bypass_Trigger__c != null) {
      bypassedTriggers = new set<String>(user.Bypass_Trigger__c.split(';'));
    }  else {
      bypassedTriggers = new set<String>();
    }
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }

  
  // constructor
  public TriggerHandler() {
    this.setTriggerContext();
  }

  /***************************************
   * public instance methods
   ***************************************/

  // main method that will be called during execution
  public void run() {

    if(!validateRun()) return;

    addToLoopCount();

    // dispatch to the correct handler method
    if(this.context == TriggerContext.BEFORE_INSERT) {
      this.beforeInsert();
    } else if(this.context == TriggerContext.BEFORE_UPDATE) {
      this.beforeUpdate();
    } else if(this.context == TriggerContext.BEFORE_DELETE) {
      this.beforeDelete();
    } else if(this.context == TriggerContext.AFTER_INSERT) {
      this.afterInsert();
    } else if(this.context == TriggerContext.AFTER_UPDATE) {
      this.afterUpdate();
    } else if(this.context == TriggerContext.AFTER_DELETE) {
      this.afterDelete();
    } else if(this.context == TriggerContext.AFTER_UNDELETE) {
      this.afterUndelete();
    }

  }

  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
      TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  /***************************************
   * public static methods
   ***************************************/

  public static void bypass(String handlerName) {
    TriggerHandler.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    TriggerHandler.bypassedHandlers.clear();
  }

  /***************************************
   * private instancemethods
   ***************************************/

  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(String ctx, Boolean testMode) {
    if(!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }
    
    if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
        (ctx != null && ctx == 'before insert')) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
        (ctx != null && ctx == 'before update')){
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
        (ctx != null && ctx == 'before delete')) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
        (ctx != null && ctx == 'after insert')) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
        (ctx != null && ctx == 'after update')) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
        (ctx != null && ctx == 'after delete')) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
        (ctx != null && ctx == 'after undelete')) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

  // increment the loop count
  @TestVisible
  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
      if(exceeded) {
        Integer max = TriggerHandler.loopCountMap.get(handlerName).max; return;
        throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
      }
    }
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() {

    if(!this.isTriggerExecuting || this.context == null) {
      throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
    if(TriggerHandler.bypassedHandlers.contains(getHandlerName()) || TriggerHandler.bypassedTriggers.contains(getHandlerName())) {
      return false;
    }
    return true;
  }

  @TestVisible
  private String getHandlerName() {
    return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
  }

  /***************************************
   * context methods
   ***************************************/

  // context-specific methods for override
  @TestVisible
  protected virtual void beforeInsert(){}
  @TestVisible
  protected virtual void beforeUpdate(){}
  @TestVisible
  protected virtual void beforeDelete(){}
  @TestVisible
  protected virtual void afterInsert(){}
  @TestVisible
  protected virtual void afterUpdate(){}
  @TestVisible
  protected virtual void afterDelete(){}
  @TestVisible
  protected virtual void afterUndelete(){}

  /***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
  private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() {
      if(this.max < 0) return false;
      if(this.count > this.max) {
        return true;
      }
      return false;
    }

    public Integer getMax() {
      return this.max;
    }

    public Integer getCount() {
      return this.count;
    }

    public void setMax(Integer max) {
      this.max = max;
    }
  }

  // possible trigger contexts
  @TestVisible
  private enum TriggerContext {
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
  }

  // exception class
  public class TriggerHandlerException extends Exception {}

}