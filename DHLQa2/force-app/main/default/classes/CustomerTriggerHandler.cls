public class CustomerTriggerHandler {
    
    public static Boolean ownerAssignmentExecuted 				 = false;
    public static Boolean functionalHeadEmailAssignmentExecuted  = false;
    
    public static String  KEYACCOUNT 	 			 	= 'Key Account';
    public static String  KEYACCOUNT_DEFAULT_MANAGER 	= 'Key Account Default Manager';
    public static String  DEFAULT_MANAGER 				= 'Default Manager';
    public static String  ALL_ZONES	     				= 'All zones';
    
    public static void assignOwnerToCustomers(List<Customer__c> customerRecords) {
        
        Map<String, Map<String, String>> touchpointRegionOwnerMap = GetTouchpointOwner.getOwnerMap();
        Map<Id,String> 					 customerRecordTypeOwnerMap = CustomerTriggerHelper.getRecordTypeInfo();
        
        System.debug('touchpointRegionOwnerMap : '+touchpointRegionOwnerMap);
        for ( Customer__c customerRecord : customerRecords) {
			Id ownerId ;
            Map<String, String> regionOwnerIdMap = new Map<String, String>();
            String touchpointName =  customerRecordTypeOwnerMap.get(customerRecord.RecordTypeId);
            String region		  =  customerRecord.Region__c;
            System.debug('touchpointName : '+touchpointName);
            System.debug('region : '+region);
    		String key = '';
            
            if (customerRecord.Is_Key_Account__c ) {
                if ( String.isNotBlank(touchpointName) && String.isNotBlank(region) ) {
              		 key = KEYACCOUNT; 
                } else {
                     key 		= KEYACCOUNT_DEFAULT_MANAGER;
                     region 	= ALL_ZONES;
                }
            } else if (String.isNotBlank(touchpointName) && String.isNotBlank(region)) {
               key = touchpointName;                     
            } else if(String.isNotBlank(touchpointName) || String.isBlank(region)){
               key 		= DEFAULT_MANAGER; 
               region 	= ALL_ZONES;
            }   
            
            System.debug('key : '+key);
            if(touchpointRegionOwnerMap.containsKey(key)) {
                 regionOwnerIdMap = touchpointRegionOwnerMap.get(key);
                 System.debug('regionOwnerIdMap : '+regionOwnerIdMap);
                 if (regionOwnerIdMap.containsKey(region)) {
                     ownerId = regionOwnerIdMap.get(region);
                      System.debug('ownerId : '+ownerId);
                     if (String.isNotBlank(ownerId)) {
                        customerRecord.OwnerId = ownerId;
                     } 
                 }
             }       
        }        
        ownerAssignmentExecuted = true;
    }    
    public static void assignEmailToFunctionalHead(List<Customer__c> customerRecords) {
        
        Map<String, Map<String, String>> touchpointRegionUsernameMap = GetTouchpointOwner.getOwnerUsernameMap();
        Map<Id,String> 					 customerRecordTypeOwnerMap = CustomerTriggerHelper.getRecordTypeInfo();
        
        System.debug('touchpointRegionUsernameMap : '+touchpointRegionUsernameMap);
        for ( Customer__c customerRecord : customerRecords) {
            Map<String, String> regionOwnerIdMap = new Map<String, String>();
            String touchpointName =  customerRecordTypeOwnerMap.get(customerRecord.RecordTypeId);
            String region		  =  customerRecord.Region__c;
            String key = '';
            if (customerRecord.Is_Key_Account__c && String.isNotBlank(touchpointName) && String.isNotBlank(region) ) {
               key = KEYACCOUNT;               
            } else if (String.isNotBlank(touchpointName) && String.isNotBlank(region)) {
               key = touchpointName;                     
            }
           
            if(touchpointRegionUsernameMap.containsKey(key)) {
                 regionOwnerIdMap = touchpointRegionUsernameMap.get(key);
                 if (regionOwnerIdMap.containsKey(region)) {
                     String functionalHeadEmail = regionOwnerIdMap.get(region);
                     if (String.isNotBlank(functionalHeadEmail)) {
                          customerRecord.Functional_Head_Email__c = regionOwnerIdMap.get(region);
                     }                    
                 }
             }       
        }        
        functionalHeadEmailAssignmentExecuted = true;
    }
}