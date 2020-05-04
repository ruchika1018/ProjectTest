@isTest
public class CaptureNpaDetailsControllerTest {
    static testMethod void test_save() {
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers('Sales', 1);
        Insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'FC In Progress', '8');
        objNps.Fc1_Comments__c = 'Test comments1';
        objNps.Fc2_Comments__c = 'Test comments2';
        objNps.Fc3_Comments__c = 'Test comments3';
        Insert objNps;
        String parentId = lstsalesCust[0].Id;
       Test.startTest();
            String result = CaptureNpaDetailsController.save(objNps);
       Test.stopTest();
       Net_Promoter_Score__c resultNpa = [Select Id,Fc1_Attempted_By__c,Fc2_Attempted_By__c,Fc3_Attempted_By__c
                                         From Net_Promoter_Score__c 
                                         Where Id = :objNps.Id];
        System.assertNotEquals(null, resultNpa.Fc1_Attempted_By__c);
        System.assertNotEquals(null, resultNpa.Fc2_Attempted_By__c);
        System.assertNotEquals(null, resultNpa.Fc3_Attempted_By__c);
    }
    
    public static testMethod void test_Isdefaultmanager_Is_Not_LoggedIn() {
        
       Id billingRecordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId();         
      
        List<Profile> profiles = [
            SELECT Id 
            , Name
            FROM Profile
            WHERE Name Like 'Chief Service Officer(DHL)%'
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
            
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers(billingRecordTypeId, 1, true, '');
        insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'Closed', '8');
        insert objNps;
        String parentId = lstsalesCust[0].Id;
        
        System.runAs(users[0]) {
            Test.startTest();
                    Net_Promoter_Score__c npa = CaptureNpaDetailsController.getNpa(parentId);
                    //System.assertEquals(null, CaptureNpaDetailsController.customerRegion, 'test_IsdefaultmanagerLoggedIn : Region is not as expected');
                    //String result = CaptureNpaDetailsController.checkIsDefaultManagerLoggedIn();
                    //System.assertEquals('false', result, 'test_Isdefaultmanager_Is_Not_LoggedIn : Default manager is not logged in');
            Test.stopTest();
        } 
               
    }
     public static testMethod void test_Isdefaultmanager_Is_LoggedIn() {
        
       Id billingRecordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 
       String username ='tushar.kakade@eternussolutions.com.qa';
       List<User> users = [
           SELECT Id
             FROM User
            WHERE Username = :username
       ];
         
         if (users.isEmpty()) {
            List<Profile> profiles = [
                 SELECT Id 
                 , Name
                 FROM Profile
                 WHERE Name Like 'Chief Service Officer(DHL)%'
                 LIMIT 1
            ];
       
            users = TestDataFactory.createUsers(
                                        'standt'
                                       , username
                                       , 'Testing'
                                       , ''+profiles[0].Id
                                       , username
                                       , 1
                                      );
            users[0].username =   username;
            update users;
         }      
        
         
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers(billingRecordTypeId, 1, true, '');
        insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'Closed', '8');
        insert objNps;
        String parentId = lstsalesCust[0].Id;
        
        System.runAs(users[0]) {
            Test.startTest();
                    Net_Promoter_Score__c npa = CaptureNpaDetailsController.getNpa(parentId);
                    //System.assertEquals(null, CaptureNpaDetailsController.customerRegion, 'test_IsdefaultmanagerLoggedIn : Region is not as expected');
                    //String result = CaptureNpaDetailsController.checkIsDefaultManagerLoggedIn();
                    //System.assertEquals('true', result, 'test_Isdefaultmanager_Is_LoggedIn : Default manager is logged in');
            Test.stopTest();
        } 
               
    }
    
    public static testMethod void test_Isdefaultmanager_Region_Is_Not_Blank() {
      Id billingRecordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 

       String username ='noor.rayini@dhl.com.st.qa';
       List<User> users = [
           SELECT Id
             FROM User
            WHERE Username = :username
       ];
         
         if (users.isEmpty()) {
            List<Profile> profiles = [
                 SELECT Id 
                 , Name
                 FROM Profile
                 WHERE Name Like 'Chief Service Officer(DHL)%'
                 LIMIT 1
            ];
       
            users = TestDataFactory.createUsers(
                                        'standt'
                                       , username
                                       , 'Testing'
                                       , ''+profiles[0].Id
                                       , username
                                       , 1
                                      );
            users[0].username =   username;
            update users;
         }      
        
         
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers(billingRecordTypeId, 1, true, '');
        lstsalesCust [0].Region__c = 'East';
        insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'Closed', '8');
        insert objNps;
        String parentId = lstsalesCust[0].Id;
        
        System.runAs(users[0]) {
            Test.startTest();
                    Net_Promoter_Score__c npa = CaptureNpaDetailsController.getNpa(parentId);
                    //System.assertEquals('East', CaptureNpaDetailsController.customerRegion, 'test_IsdefaultmanagerLoggedIn : Region is not as expected');
                    //String result = CaptureNpaDetailsController.checkIsDefaultManagerLoggedIn();
                    //System.assertEquals('false', result, 'test_Isdefaultmanager_Is_LoggedIn : Default manager is logged in');
            Test.stopTest();
        } 
    }
    
    public static testMethod void test_checkIsDefaultManagerLoggedIn() {
      Id billingRecordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Billing').getRecordTypeId(); 

       String username ='noor.rayini@dhl.com.st.qa';
       List<User> users = [
           SELECT Id
             FROM User
            WHERE Username = :username
       ];
         
         if (users.isEmpty()) {
            List<Profile> profiles = [
                 SELECT Id 
                 , Name
                 FROM Profile
                 WHERE Name Like 'Chief Service Officer(DHL)%'
                 LIMIT 1
            ];
       
            users = TestDataFactory.createUsers(
                                        'standt'
                                       , username
                                       , 'Testing'
                                       , ''+profiles[0].Id
                                       , username
                                       , 1
                                      );
            users[0].username =   username;
            update users;
         }      
        
         
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers(billingRecordTypeId, 1, true, 'East');
        //lstsalesCust [0].Region__c = 'East';
        insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'Closed', '8');
        insert objNps;
        String parentId = lstsalesCust[0].Id;
        
        System.runAs(users[0]) {
            Test.startTest();
                    String value = CaptureNpaDetailsController.checkIsDefaultManagerLoggedIn(parentId);
                    //System.assertEquals('East', CaptureNpaDetailsController.customerRegion, 'test_IsdefaultmanagerLoggedIn : Region is not as expected');
                    //String result = CaptureNpaDetailsController.checkIsDefaultManagerLoggedIn();
                    //System.assertEquals('false', result, 'test_Isdefaultmanager_Is_LoggedIn : Default manager is logged in');
            Test.stopTest();
        } 
    }
}