public class ConfigureTouchpoint_Controller {
    @AuraEnabled
    public static List<User_Touchpoint_Mapping__c> getUsers() {
        List<User> users = new List<User>();
        Profile profiles = [
            				SELECT 
            					Id 
            				From 
            					Profile 
            				Where 
            					Name = 'NPA First Caller'
        				];
        users = [
            SELECT 
                Id
                ,Name 
            FROM 
            	User 
            WHERE 
            	profileId =: profiles.Id
        ];
   		System.debug('Test users' + users);
        List<User_Touchpoint_Mapping__c> userTouchpoints = new List<User_Touchpoint_Mapping__c>();
        List<User_Touchpoint_Mapping__c> existingUserTouchpoints = new List<User_Touchpoint_Mapping__c>();
        existingUserTouchpoints = [
            SELECT Caller_Name__c, Touchpoint_Name__c FROM User_Touchpoint_Mapping__c ORDER By Caller_Name__c ASC
        ];
        Set<String> userNames = new Set<String>();
        for (User_Touchpoint_Mapping__c existingUserTouchpoint : existingUserTouchpoints) {
            userNames.add(existingUserTouchpoint.Caller_Name__c); 
        }
        for (User userData : users) {
            if(userNames.contains(userData.Name) == false ){
                User_Touchpoint_Mapping__c userTouchpointConf = new User_Touchpoint_Mapping__c();
                //userTouchpointConf.Name = userData.Name;
                userTouchpointConf.Caller_Name__c = userData.Name;
                userTouchpointConf.Touchpoint_Name__c = '';
                userTouchpoints.add(userTouchpointConf);
            }
        }
        
        System.debug('Test ' + userTouchpoints);	
        if (! userTouchpoints.isEmpty() && userTouchpoints!=null) {
            insert userTouchpoints;
        }
        userTouchpoints.addAll(existingUserTouchpoints);
        return userTouchpoints;
    }
    
    @AuraEnabled
    public static Boolean saveTouchpointMapping(List<User_Touchpoint_Mapping__c> userTouchpoints){
        System.debug('Test Save TouchPoints' + userTouchpoints);
        Boolean flag = true;
       /*	List<User_Touchpoint_Mapping__c> existingUsers = new List<User_Touchpoint_Mapping__c>();
        existingUsers = getUsers();
        List<User_Touchpoint_Mapping__c> changedMapping = new List<User_Touchpoint_Mapping__c>();
        for (User_Touchpoint_Mapping__c userTouchpoint : userTouchpoints) {
            for (User_Touchpoint_Mapping__c existingInDB : existingUsers) {
                if(userTouchpoint.Touchpoint_Name__c != existingInDB.Touchpoint_Name__c) {
                    changedMapping.add(userTouchpoint);
                }
            }
        } */
         try{
            Database.SaveResult[] srList = Database.update(userTouchpoints, false);
            for (Database.SaveResult sr : srList) {					
   				 if (!sr.isSuccess()) {
                     flag = false;
                 }
                 for(Database.Error err : sr.getErrors()) {
                 	System.debug(err.getStatusCode() + ': ' + err.getMessage());
				 }
			}
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            flag = false;
		}
		//UnshareRecords.unshareCustomers(changedMapping);
        randomizer randmzr = new Randomizer();
        ShareCustomerRecords rec = new ShareCustomerRecords();
        
        rec.shareRecords(randmzr.getCustomerforCurrentuser());
        return flag;
    }
     @AuraEnabled 
    public static List<Configuration__c> getTouchpoints(){
        List<Configuration__c> touchpointNames = new List<Configuration__c>();
        touchpointNames = [SELECT Touchpoint_Name__c FROM Configuration__c];
        return touchpointNames;
    }
}