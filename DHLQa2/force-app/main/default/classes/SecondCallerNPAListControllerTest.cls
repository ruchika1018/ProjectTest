@isTest public class SecondCallerNPAListControllerTest {
   
    @isTest
    public static void testCallerName() {
        List<Profile> profiles = [
            SELECT Id 
            , Name
            FROM Profile
            WHERE Name Like 'System Administrator%'
            LIMIT 1
        ];
        
        List<User> users = TestDataFactory.createUsers(
            'standt'
            , 'user@testorg.com'
            , 'Testing'
            , ''+profiles[0].Id
            , 'user@testorg.com'
            , 1
        );
        String response = '';
        System.runAs(users[0]) {
            response = SecondCallerNPAListController.getNPADetails();
        }
        System.assertNotEquals(	''
                               , response
                               , 'testCallerName : Resopnse is blank');
        System.debug('response '+response);
        if (response != '') {
            Map<String, Object> customerDetailsMap = 
                (Map<String,  Object>)
                JSON.deserializeUntyped(response);                
            
            System.assertEquals(   'Testing 0'
                                , customerDetailsMap.get('secondCallerName')
                                , 'testCallerName : Caller Name is not as expected');
        }
        
    }
    
     @isTest
     public static void testnpsData() {
        	List<Profile> profiles = [
                SELECT Id 
                     , Name
                  FROM Profile
                 WHERE Name Like 'System Administrator%'
                 LIMIT 1
            ];
       
        List<User> users = TestDataFactory.createUsers(
           							'standt'
           						   , 'user@testorg.com'
                                   , 'Testing'
                                   , ''+profiles[0].Id
                                   , 'user@testorg.com'
                                   , 1
                                  );
            String response = '';
            
            Map<String,Schema.RecordTypeInfo> recTypeMapByName = TestDataFactory.getCustomerRecordTypeMap();
            
            List<Customer__c> customerAll = new List<Customer__c>();
            List<Customer__c> customersBilling = new List<Customer__c>();
            customersBilling = TestDataFactory.createCustomers(
                recTypeMapByName.get('Billing').getRecordTypeId()
               , 20 
               , true
            );
            
            List<Customer__c> customersCE = TestDataFactory.createCustomers(
                recTypeMapByName.get('Customer Excellence').getRecordTypeId()
               , 20 
               , true
            );
            customerAll.addAll(customersBilling);
            customerAll.addAll(customersCE);
            insert customerAll;
            
            List<Net_Promoter_Score__c> npsList = new List<Net_Promoter_Score__c>();
            for (Integer i=0 ; i < customerAll.size() ; i++) {
                 Net_Promoter_Score__c nps = new  Net_Promoter_Score__c ();
                if (i < 20) {
                     nps = TestDataFactory.createNps(customerAll[i].Id, 'FC In Progress', '8');
                	 nps.Make_Second_Call__c = true;
                } else if (i < 30){
                    nps = TestDataFactory.createNps(customerAll[i].Id, 'Closed', '8');
                	nps.Make_Second_Call__c = true;
                }  else if (i < 40){
                    nps = TestDataFactory.createNps(customerAll[i].Id, 'FC In Progress', '8');
                	nps.Make_Second_Call__c = false;
                }
                
                npsList.add(nps);
               
            }
            insert npsList;
            System.runAs(users[0]) {
                response = SecondCallerNPAListController.getNPADetails();
            }
            System.assertNotEquals(	''
                                   , response
                                   , 'testCallerName : Resopnse is blank');
            System.debug('response '+response);
            if (response != '') {
                Map<String, Object> npsDetailsMap = 
                           (Map<String,  Object>)
                              JSON.deserializeUntyped(response);    
             List<Object> npsData = (List<Object>)npsDetailsMap.get('npsData');
                
             System.assertEquals(   'Testing 0'
                                     , npsDetailsMap.get('secondCallerName')
                                     , 'testnpsData : Caller Name is not as expected');
             System.assertEquals(   30
                                     , npsData.size()
                                     , 'testnpsData : NPS Data is not as expected');           
            }

        }  
    
    @isTest
    public static void testisANPAAnalystLoggedIn() {
        	List<Profile> profiles = [
                SELECT Id 
                     , Name
                  FROM Profile
                 WHERE Name = :SecondCallerNPAListController.NPA_ANALYST_PROFILE_NAME
                 LIMIT 1
            ];
       
        List<User> users = TestDataFactory.createUsers(
           							'standt'
           						   , 'user@testorg.com'
                                   , 'Testing'
                                   , ''+profiles[0].Id
                                   , 'user@testorg.com'
                                   , 1
                                  );
            Boolean response = false;
            System.runAs(users[0]) {
                response = SecondCallerNPAListController.validate_NPAAnalystLoggedIn();
            }
            System.assertNotEquals(	null
                                   , response
                                   , 'testisANPAAnalystLoggedIn : Response is blank');           
                          
            System.assertEquals(  true
                                , response
                                , 'testisANPAAnalystLoggedIn : Response value should be true as NPA analyst is logged in');
            

        }
    
     @isTest
     public static void testClosedRecords() {
        	List<Profile> profiles = [
                SELECT Id 
                     , Name
                  FROM Profile
                 WHERE Name Like 'System Administrator%'
                 LIMIT 1
            ];
       
        List<User> users = TestDataFactory.createUsers(
           							'standt'
           						   , 'user@testorg.com'
                                   , 'Testing'
                                   , ''+profiles[0].Id
                                   , 'user@testorg.com'
                                   , 1
                                  );
            String response = '';
            
            Map<String,Schema.RecordTypeInfo> recTypeMapByName = TestDataFactory.getCustomerRecordTypeMap();
            
            List<Customer__c> customerAll = new List<Customer__c>();
            List<Customer__c> customersBilling = new List<Customer__c>();
            customersBilling = TestDataFactory.createCustomers(
                recTypeMapByName.get('Billing').getRecordTypeId()
               , 20 
               , true
            );
            
            List<Customer__c> customersCE = TestDataFactory.createCustomers(
                recTypeMapByName.get('Customer Excellence').getRecordTypeId()
               , 20 
               , true
            );
            customerAll.addAll(customersBilling);
            customerAll.addAll(customersCE);
            insert customerAll;
            
            List<Net_Promoter_Score__c> npsList = new List<Net_Promoter_Score__c>();
            for (Integer i=0 ; i < customerAll.size() ; i++) {
                 Net_Promoter_Score__c nps = new  Net_Promoter_Score__c ();
                if (i < 20) {
                     nps = TestDataFactory.createNps(customerAll[i].Id, 'FC In Progress', '8');
                	 nps.Make_Second_Call__c = true;
                } else if (i < 30){
                    nps = TestDataFactory.createNps(customerAll[i].Id, 'Closed', '8');
                	nps.Make_Second_Call__c = true;
                    nps.SC_Assignment_Date__c = System.today();                    
                }  else if (i < 40){
                    nps = TestDataFactory.createNps(customerAll[i].Id, 'FC In Progress', '8');
                	nps.Make_Second_Call__c = false;
                }
                
                npsList.add(nps);
               
            }
            insert npsList;
            System.runAs(users[0]) {
                response = SecondCallerNPAListController.getNPADetails();
            }
            System.assertNotEquals(	''
                                   , response
                                   , 'testClosedRecords : Response is blank');
            System.debug('response '+response);
            if (response != '') {
                Map<String, Object> npsDetailsMap = 
                           (Map<String,  Object>)
                              JSON.deserializeUntyped(response);    
             List<Object> npsData = (List<Object>)npsDetailsMap.get('npsData');
                
             System.assertEquals(   'Testing 0'
                                     , npsDetailsMap.get('secondCallerName')
                                     , 'testClosedRecords : Caller Name is not as expected');
             System.assertEquals(   40
                                     , npsData.size()
                                     , 'testClosedRecords : NPS Data is not as expected');           
            }

        }  
   
}