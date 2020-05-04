public class CustomerTriggerHelper {
	
    public static Map<Id, String> recordTypeIdNameMap	= getRecordTypeInfo();    
    
    public static String getRecordTypeNameById(String objectName, Id recordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }   
        
    public static Map<Id, String> getRecordTypeInfo() {
       //set record type map
       Schema.DescribeSObjectResult result 				= Customer__c.SObjectType.getDescribe();
       List<Schema.RecordTypeInfo>  customerRecordTypes = result.getRecordTypeInfos(); 
       recordTypeIdNameMap 								= new Map<Id, String>();
       
       for (Schema.RecordTypeInfo info : customerRecordTypes) {
           recordTypeIdNameMap.put(info.getRecordTypeId(), info.getName());
       }
        
       return recordTypeIdNameMap;
    }  
}