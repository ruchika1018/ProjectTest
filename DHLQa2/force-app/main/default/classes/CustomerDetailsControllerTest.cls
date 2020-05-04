@isTest public class CustomerDetailsControllerTest {
    
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
                response = CustomerDetailsController.getCustomerDetails();
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
                                     , customerDetailsMap.get('firstCallerName')
                                     , 'testCallerName : Caller Name is not as expected');
            }
            
    	}
    
    	
        @isTest public static void testCustomerListData() {
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
            
            Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
            Map<String,Schema.RecordTypeInfo> recTypeMapByName = Schema.SObjectType.Customer__c.getRecordTypeInfosByName();
            
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
            
            List<Customer__c> customersOM = TestDataFactory.createCustomers(
                recTypeMapByName.get('Order Management').getRecordTypeId()
               , 20 
               , true
            );
            
            List<Customer__c> customersSales = TestDataFactory.createCustomers(
                recTypeMapByName.get('Sales').getRecordTypeId()
               , 20 
               , false
            );
            
            List<Customer__c> customersOP = TestDataFactory.createCustomers(
                 recTypeMapByName.get('Operations').getRecordTypeId()
               , 20
               , false
            );
            
            
            System.debug('testing....');
            List<Customer__c> customerAll = new List<Customer__c>();
            customerAll.addAll(customersBilling);
            customerAll.addAll(customersCE);
            customerAll.addAll(customersOP);
            customerAll.addAll(customersOM);
            customerAll.addAll(customersSales);
           
            System.runAs(users[0]) {
                insert customerAll;
                List<Net_Promoter_Score__c> nps = new List<Net_Promoter_Score__c>();
                for (Customer__c cust : customerAll) {
                    nps.add(TestDataFactory.createNps(cust.Id, 'Open', '9'));
                }
                insert nps;
                response = CustomerDetailsController.getCustomerDetails();
                
                
                if (response != '') {
                    Map<String, Object> customerDetailsMap = 
                        (Map<String,  Object>)
                        JSON.deserializeUntyped(response);    
                     List<Object> customerdata = (List<Object>)customerDetailsMap.get('customerData');
                     List<Object> targetData = (List<Object>)customerDetailsMap.get('targetData');
                     System.assertEquals(   false
                                             , customerdata.isEmpty()
                                             , 'testCustomerListData : customer data not found');
                     System.assertEquals(   100
                                             , customerdata.size()
                                             , 'testCustomerListData : customer data not found');
                     System.assertEquals(   false
                                             , targetData.isEmpty()
                                             , 'testCustomerListData : targetData data not found');
                     System.assertEquals(   6
                                             , targetData.size()
                                             , 'testCustomerListData : targetData data not found');
                    }   
                }
    	}
    
    public testmethod static void fetchusers() {
        List<user> users = [
            SELECT Id from User
        ];
        system.debug('users' +users.size());
    }
}