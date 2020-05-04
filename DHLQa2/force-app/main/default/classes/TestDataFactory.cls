public class TestDataFactory {
    public static List<Customer__c> createCustomers(String recordTypeName, Integer numCusts) {
        Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
        Map<String,Schema.RecordTypeInfo> recTypeMapByName = customerDesribe.getRecordTypeInfosByDeveloperName();
        List<Customer__c> lstCust = new List<Customer__c>();
        
        for(Integer i=0; i < numCusts; i++) {
            Customer__c customer = new Customer__c();
            //Changed as per Issue SB-269 for NPA
            //customer.Account_Name__c ='TestAccount' + i;
            customer.Customer_Name__c ='Test Data ' + recordTypeName + ' ' +i;
            customer.recordTypeId = recTypeMapByName.get(recordTypeName).getRecordTypeId();
            lstCust.add(customer);
        }
        
        return lstCust;
    }

    public static Net_Promoter_Score__c createNps(String customerId, String status, String rating) {
        //List<Net_Promoter_Score__c> lstCust = new List<Net_Promoter_Score__c>();
        Net_Promoter_Score__c npa = new Net_Promoter_Score__c();
        npa.NPA_Rating__c = rating;
        npa.Customer__c = customerId;
        npa.Status__c = status;
        
        return npa;
    }
    
    public static List<User> createUsers(	String alias
                                          ,	String email
                                          ,	String lastName
                                          ,	Id profileId
                                          ,	String userName
                                          , Integer numberOfRecords
    ) {
        List<User> users = new List<User>();
        
        for (Integer i=0 ; i < numberOfRecords ; i++) {
            User usr = new User(
                  Alias 			= alias + ' ' + i
                , Email 			= email + '' + i
                , EmailEncodingKey  = 'UTF-8'
                , LastName			= lastName + ' ' + i
                , LanguageLocaleKey = 'en_US'
                , LocaleSidKey		='en_US'
                , TimeZoneSidKey	='America/Los_Angeles'
                , ProfileId 		= profileId
                , UserName			= userName + '' + i
            );
            users.add(usr);
         }
         
        
        insert users; 
        
        return users;
    }
    
    
     public static List<Customer__c> createCustomers(Id recordTypeId, Integer numCusts,Boolean isKeyAccount) {         

        List<Customer__c> lstCust = new List<Customer__c>();
        
        for(Integer i=0; i < numCusts; i++) {
            Customer__c customer = new Customer__c();
            customer.Customer_Name__c ='TestAccount' + i;
            customer.Is_Key_Account__c = isKeyAccount;
            customer.recordTypeId =recordTypeId;
            lstCust.add(customer);
        }
        
        return lstCust;
    }
    
    public static List<Customer__c> createCustomers(Id recordTypeId, Integer numCusts,Boolean isKeyAccount, String zone) {         

        List<Customer__c> lstCust = new List<Customer__c>();
        
        for(Integer i=0; i < numCusts; i++) {
            Customer__c customer 		= new Customer__c();
            customer.Customer_Name__c 	= 'TestAccount' + i;
            customer.Is_Key_Account__c 	= isKeyAccount;
            customer.recordTypeId 		= recordTypeId;
            customer.Region__c 			= zone;
            lstCust.add(customer);
        }
        
        return lstCust;
    }

    public static void createUserTouchpointConf(String touchpoints, String Username) {
         
        UserTouchpointConf__c userConfi = new UserTouchpointConf__c();
        userConfi.Name = Username;
        userConfi.Caller_Name__c = Username;
        userConfi.Touchpoints__c = touchpoints;
        
        Insert userConfi;
    }
    
    public static Map<String,Schema.RecordTypeInfo> getCustomerRecordTypeMap() {
         Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
          return Schema.SObjectType.Customer__c.getRecordTypeInfosByName();
    }
    
     public static List<Customer__c> createCustomersTestData(String recordTypeName, Integer numCusts,Boolean isKeyAccount,String region) {
        Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
        Map<String,Schema.RecordTypeInfo> recTypeMapByName = customerDesribe.getRecordTypeInfosByDeveloperName();
        List<Customer__c> lstCust = new List<Customer__c>();
        
        for(Integer i=0; i < numCusts; i++) {
            Customer__c customer = new Customer__c();
            //Changed as per Issue SB-269 for NPA
            //customer.Account_Name__c ='TestAccount' + i;
            customer.Customer_Name__c ='Test Data ' + recordTypeName + ' ' +i;
            customer.recordTypeId = recTypeMapByName.get(recordTypeName).getRecordTypeId();
            customer.Is_Key_Account__c = isKeyAccount;
            customer.Region__c = region;
            lstCust.add(customer);
        }
        
        return lstCust;
    }

}