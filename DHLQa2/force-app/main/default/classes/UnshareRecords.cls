public without sharing class  UnshareRecords {
    public static void unshareCustomers(List<User_Touchpoint_Mapping__c> userTouchpoints) {
        Set<String> userNames = new Set<String>();
        Map<String, String> userTouchpointMap = new Map<String, String>();
        for (User_Touchpoint_Mapping__c mappingRec : userTouchpoints){
            userTouchpointMap.put(mappingRec.Caller_Name__c, mappingRec.Touchpoint_Name__c);
            userNames.add(mappingRec.Caller_Name__c);
        }
        
        List<User> userData = [
                            SELECT 
                           		 Id
            					 ,Name
                            FROM 
                            	User
                            WHERE 
                            	name IN :userNames 
        				];
        Set<String> userIds = new Set<String>();
        for (User rec : userData){
            String touchpointName;
            touchpointName = userTouchpointMap.get(rec.Name);
            userTouchpointMap.remove(rec.Name);
            userTouchpointMap.put(rec.Id, touchpointName);
            userIds.add(rec.Id);
        }
        List<Customer__Share> sharedCustomers = [
                                                 SELECT 
            										ParentId,
            										UserOrGroupId,
            										RowCause
            									FROM
            										Customer__Share
            									WHERE 
            										UserOrGroupId IN :userIds
                                            ];
        Set<String> customerIds = new Set<String>();
        for (Customer__Share sharedcustomer : sharedCustomers){
            customerIds.add(sharedcustomer.ParentId);
        }
        List<Customer__c> customers =  [
                                         SELECT
            								Id
            								,Name
            								,Is_Shared__c
            								,RecordTypeId
            							FROM
            								Customer__c
            							WHERE 
            								Id IN :customerIds
                                    ];
        //Map<String, Customer__c>> userCustomerMap = new Map<String, List<Customer__c>>();
        List<Customer__c> custRecords = new List<Customer__c>();
        List<Customer__Share> unshareCustomers = new List<Customer__Share>();
        for (Customer__Share sharedcustomer : sharedCustomers){
            for(Customer__c customerRec : customers){
                if (sharedcustomer.ParentId == customerRec.Id) {
                   String touchpointNames = userTouchpointMap.get(sharedcustomer.UserOrGroupId);
                   if (String.isNotBlank(touchpointNames)) {
                       if(touchpointNames.contains(',')) {
                           	String[] touchpoints = touchpointNames.split(',');
                           	String recTypeName = Schema.getGlobalDescribe().get('Customer__c').getDescribe().getRecordTypeInfosById().get(customerRec.recordTypeId).getName();
                           if(!touchpoints.contains(recTypeName)) {
                               if (sharedcustomer.RowCause == 'Manual') {
                                   if(!unshareCustomers.contains(sharedcustomer)){
										unshareCustomers.add(sharedcustomer); 
                                   }
                                    
                                   customerRec.Is_Shared__c = false;
                                   custRecords.add(customerRec);
                               }
                           }
                           	/*for (Integer i = 0; i < touchpoints.size() ; i++) {
                               String recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(touchpoints[i]).getRecordTypeId();
                                if(customerRec.recordTypeId != recordTypeId){
                                    if (sharedcustomer.RowCause == 'Manual') {
                                      unshareCustomers.add(sharedcustomer);  
                                        customerRec.Is_Shared__c = false;
                                        custRecords.add(customerRec);
                                    }
                                }
                           	}*/
                        } else {
                           String recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(touchpointNames).getRecordTypeId();
                            if(customerRec.recordTypeId != recordTypeId){
                                if (sharedcustomer.RowCause == 'Manual') {
                                  unshareCustomers.add(sharedcustomer); 
                                    customerRec.Is_Shared__c = false;
                                    custRecords.add(customerRec);
                                }
                            }
                        }  
                    }
                }
                
            }
        }
        System.debug('Test one' + unshareCustomers);
        if(!unshareCustomers.isEmpty()) {
            delete unshareCustomers;
        }
        if(!custRecords.isEmpty()) {
            update custRecords;
        }
    }
}