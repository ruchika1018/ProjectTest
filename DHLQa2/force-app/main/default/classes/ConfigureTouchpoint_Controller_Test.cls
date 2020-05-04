@isTest
public class ConfigureTouchpoint_Controller_Test {
	@isTest
    public static void testGetUsers(){
        Profile p = [SELECT Id FROM Profile WHERE Name='NPA First Caller']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='npafirstcaller@testorg.com');

        System.runAs(u) {
           ConfigureTouchpoint_Controller.getUsers();
        }
    }
    
    @isTest
    public static void testSaveUsers(){
        User_Touchpoint_Mapping__c userTouchpointConf = new User_Touchpoint_Mapping__c();
        userTouchpointConf.Caller_Name__c = 'Test First Caller';
        userTouchpointConf.Touchpoint_Name__c = 'Sales, Billing';
        insert userTouchpointConf;
        ConfigureTouchpoint_Controller.saveTouchpointMapping(new List<User_Touchpoint_Mapping__c> {userTouchpointConf});
    }
}