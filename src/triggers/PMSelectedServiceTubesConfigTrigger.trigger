trigger PMSelectedServiceTubesConfigTrigger on PM_Selected_Service_Tubes_Config__c (before update) {
    new PMSelectedServiceTubesConfigTriggHandler().run();
}