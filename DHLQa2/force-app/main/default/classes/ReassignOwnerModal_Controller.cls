public without sharing class ReassignOwnerModal_Controller {
	@AuraEnabled
    public static List<Touchpoint_Owner_mapping__mdt> getTouchpoints(){
        List<Touchpoint_Owner_mapping__mdt> touchpoints = [
                                                     SELECT  
                                                            Username__c,
            												MasterLabel,
                                                            Touchpoint_Name__c,
                                                            Region__c
                                                        FROM 
                                                              Touchpoint_Owner_mapping__mdt
            											ORDER BY MasterLabel ASC
        											];
        return touchpoints;
    }
    
    @AuraEnabled
    public static Boolean changeOwner(String touchpointName,String customerId, String npaString, String recString) {
        System.debug('Test string ' + npaString);
        reassignWrapper wrapperRec = (reassignWrapper) JSON.deserialize(recString, reassignWrapper.class);
        System.debug('Test wrapper :' + wrapperRec);
        System.debug('Test npa in wrapper ' + wrapperRec.npaRec);
        Net_Promoter_Score__c npaRec = (Net_Promoter_Score__c) JSON.deserialize(wrapperRec.npaRec, Net_Promoter_Score__c.Class);
        //Net_Promoter_Score__c npaRec = (Net_Promoter_Score__c) JSON.deserialize(npaString, Net_Promoter_Score__c.Class);
        String userId = GetTouchpointOwner.getOwnerByLabel(touchpointName);
        System.debug('NPA Record :' + npaRec);
        //System.debug('Npa from wrapper ' + npaRec1);
        Boolean flag = true;
        Boolean isStatusChanged = true;
        Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
        Map<String,Schema.RecordTypeInfo> recTypeMapByName = customerDesribe.getRecordTypeInfosByDeveloperName();
        System.debug('Test user ' + userId);
        if (userId == 'No User') {
            flag = false;
        } else { 
            Touchpoint_Owner_mapping__mdt touchpointMapping =  GetTouchpointOwner.getTouchpointMapping(touchpointName);
            System.debug('Touchpoint mapping' + touchpointMapping);
            List<Customer__c> customerRec = [SELECT Id
                                             	  , OwnerId
                                                  , Region__c
                                                  , (Select Id 
                                                       From Net_Promoter_Scores__r
                                                       Limit 1)  
                                               FROM Customer__c 
                                              WHERE Id = :customerId];
            System.debug('Cus ' + customerRec);
            	if (customerRec != null || !customerRec.isEmpty()) {
                    System.debug('Test Cust' + customerRec);
                    customerRec[0].OwnerId = userId;
                    if (touchpointMapping.Region__c != null && touchpointMapping.Region__c != 'All zones') {
                        customerRec[0].Region__c = touchpointMapping.Region__c;
                    }
                    if (touchpointMapping.Touchpoint_Name__c != null ) {
                        	System.debug('Test rt ' +  Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(touchpointMapping.Touchpoint_Name__c).getRecordTypeId());
                           // System.debug('Test record type Id ' + recTypeMapByName.get(touchpointMapping.Touchpoint_Name__c).getRecordTypeId());
                            customerRec[0].recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(touchpointMapping.Touchpoint_Name__c).getRecordTypeId();
                    }
                   
                   // Net_Promoter_Score__c npaRec = customerRec[0].Net_Promoter_Scores__r.size() == 1 ?
                    //                               customerRec[0].Net_Promoter_Scores__r[0] :
                     //                              null;
                    if(npaRec != null){
                        npaRec.Status__c = 'SC Reassigned';
                        npaRec.Is_SC_Reassigned__c = true;
                	}
					                    
                    try{
                       
                       if(npaRec != null){
                       		update npaRec;
                       }
                        
                       update customerRec; 
                    
                    }catch(Exception exp){
                        
                        System.debug('---->Exception'+exp);
                        flag = false;
                    
                    }
                    
                    
                     /*try{
                        Database.SaveResult[] srList = Database.update(customerRec, false);
                        for (Database.SaveResult sr : srList) {					
                             if (!sr.isSuccess()) {
                                 flag = false;
                             }
                            for (Database.Error err : sr.getErrors()) {
                                System.debug('Update error  ' + err.getMessage());
                            }
                        }
                         
                      } catch (DmlException e) {
                            System.debug('The following exception has occurred: ' + e.getMessage());
                            flag = false;
                     }
                   System.debug('Flag  ' + flag);
                   
                   if (flag) {
                       System.debug('Test cusr Id : ' + customerRec[0].Id);
                        List<Net_Promoter_Score__c> npaRec = [
                            SELECT Id, 
                                Status__c 
                            FROM 
                                Net_Promoter_Score__c 
                            WHERE 
                                Customer__c = :customerRec[0].Id
                        ];
                       if(npaRec.isEmpty() || npaRec == null) {
                          isStatusChanged = false; 
                       } else {
                          npaRec[0].Status__c = 'SC Reassigned';
                           npaRec[0].Is_SC_Reassigned__c = true;
                           System.debug('Test  ' + npaRec);
                           //update npaRec;
                           try{
                            Database.SaveResult[] srList = Database.update(npaRec, false);
                               for( Database.SaveResult sr : srList){
                                  if (!sr.isSuccess()) {
                                       isStatusChanged = false;
                                   }  
                                   for (Database.Error s : sr.getErrors()){
                                       System.debug('Error message' + s.getmessage());
                                   }
                               }
                              
                           } catch (DmlException e) {
                                    System.debug('The following exception has occurred: ' + e.getMessage());
                                    isStatusChanged = false;
                           }
                           System.debug('Test Npa  ' + npaRec); 
                      }
                       
                   }*/
              }
             System.debug('Cust ' + customerRec);
        }
        
        return flag;
     }
     
    @AuraEnabled
    public static Net_Promoter_Score__c getComments(String recordId){
        System.debug('Customer : ' + recordId);
        Net_Promoter_Score__c nps = new Net_Promoter_Score__c();
        nps = [
            SELECT Reassign_Comments_1__c
                , Reassign_Comments_2__c
                , Reassign_Comments_3__c
                , Reassign_Comments_4__c
                , Reassign_Comments_5__c 
            FROM Net_Promoter_Score__c
            WHERE Customer__c = :recordId
            LIMIT 1
        ];
        return nps;
    }
    
    public class reassignWrapper{
        @AuraEnabled
        public String touchpointName;
        @AuraEnabled
        public String customerId;
        @AuraEnabled
        public String npaRec;
    }
}