trigger CustomerTrigger on Customer__c (before insert) {
 	
    if (Trigger.isBefore && Trigger.isInsert) {
        if (!CustomerTriggerHandler.ownerAssignmentExecuted) {
            CustomerTriggerHandler.assignOwnerToCustomers(Trigger.new); 
        }   
        if (!CustomerTriggerHandler.functionalHeadEmailAssignmentExecuted) {
            CustomerTriggerHandler.assignEmailToFunctionalHead(Trigger.new); 
        }
    }
}