public without sharing class GetTouchpointOwner {
    public static String ALL_ZONES 		 	= 'All Zones';
    public static String DEFAULT_MANAGER 	= 'Default Manager';    
    public static String TOUCHPOINT_MANAGER = 'Touchpoint Manager';
    
    public static String getOwner(String touchpointName, String zone) {
        Touchpoint_Owner_mapping__mdt touchpointMdtRecord;
        User userRec;
     	String userName ;
        if ( zone != null || String.isBlank(zone)){
            userName = System.Label.User_name;
        } else {
            touchpointMdtRecord = [
                SELECT 
                    Username__c,
                    Touchpoint_Name__c,
                    Region__c
                FROM 
                      Touchpoint_Owner_mapping__mdt
                WHERE
                    Touchpoint_Name__c = :touchpointName
                    AND
                    Region__c = :zone
            ]; 
            username = touchpointMdtRecord.Username__c;
        }
		
       	userRec = [
           			SELECT
           				username,
           				Id
           			FROM 
           				User
           			WHERE 
           				username = :username
       				];
       	return userRec.Id;
    }
    public static Touchpoint_Owner_mapping__mdt getTouchpointMapping(String touchpointName) {
        Touchpoint_Owner_mapping__mdt touchpointMdtRecord = new Touchpoint_Owner_mapping__mdt();
        touchpointMdtRecord = [
                SELECT 
                    Username__c,
                    Touchpoint_Name__c,
                    Region__c
                FROM 
                      Touchpoint_Owner_mapping__mdt
                WHERE
                    MasterLabel = :touchpointName
            ]; 
        return touchpointMdtRecord;
    }
    
    public static String getOwnerByLabel(String touchpointName){
        System.debug('Owner Label' + touchpointName);
         Touchpoint_Owner_mapping__mdt touchpointMdtRecord;
         touchpointMdtRecord = [
                SELECT 
                    Username__c,
                    Touchpoint_Name__c,
                    Region__c
                FROM 
                      Touchpoint_Owner_mapping__mdt
                WHERE
                    MasterLabel = :touchpointName
            ]; 
            String userRecName = touchpointMdtRecord.Username__c;
        System.debug('Username' + userRecName);
        String returnString;
        	 List<User> userRec =  new List<User>();
            userRec = [
                SELECT
                	username,
                	Id
                FROM 
                	User
                WHERE 
                	username = :userRecName
            ];
            if(userRec.isEmpty()) {
                returnString = 'No User';
            }else{
               returnString = userRec[0].Id;
            }
            return returnString;
    }
    
     public static Map<String, Map<String, String>> getOwnerMap() {
     	User defaultTouchpointManager = getDefaultUserDetails();
         System.debug('defaultTouchpointManager : '+defaultTouchpointManager);
        Set<String> usernames 	=  new Set<String>();   
     
     	Map<String, String> userMap = new Map<String, String>();  
         
       	Map<String, Map<String, String>> touchpointRegionOwnerIdMap 	= new Map<String, Map<String, String>>();
     
        List<Touchpoint_Owner_mapping__mdt> touchpointMdtRecord = [
                SELECT 
                    Username__c,
                    Touchpoint_Name__c,
            		Functional_Head_Email__c,
                    Region__c
                FROM 
                    Touchpoint_Owner_mapping__mdt
        ];
       
        for (Touchpoint_Owner_mapping__mdt mdtRec : touchpointMdtRecord){
            usernames.add(mdtRec.Username__c);
        }
       
        List<User> users = [
            SELECT 
            	Id,
            	IsActive,
            	username
           FROM User
          WHERE username IN :usernames
        ];        
          System.debug('usernames: '+usernames);
        for (User userRec :  users) {
            IF (userRec.IsActive) {
                userMap.put(userRec.username, userRec.Id);
            } else {
                userMap.put(userRec.username, defaultTouchpointManager.Id); 
            }            
        }
         
        // Add default UserId for incorrect user names returning null userId.
         for (String username : usernames) {
             if (!userMap.containsKey(username)) {
                 userMap.put(username , defaultTouchpointManager.Id);
             }
         }
         
         System.debug('userMap: ====>'+userMap);
        for (Touchpoint_Owner_mapping__mdt mdtRec : touchpointMdtRecord){
            if(!touchpointRegionOwnerIdMap.containsKey(mdtRec.Touchpoint_Name__c)) {
                //Touchpoint Manager Details
                touchpointRegionOwnerIdMap.put(	  mdtRec.Touchpoint_Name__c
                                                , new Map<String, String> {
                                                    						mdtRec.Region__c =>  userMap.get(mdtRec.Username__c)
                                                                          }
                                             ); 
            } else {
                
                touchpointRegionOwnerIdMap.get(mdtRec.Touchpoint_Name__c).put(	 mdtRec.Region__c
                                                                               , userMap.get(mdtRec.Username__c));                 
            }
        }
       
        return touchpointRegionOwnerIdMap;
    }
    
    public static  Map<String, Map<String, String>> getOwnerUsernameMap() {     	
        Map<String, Map<String, String>> touchpointRegionFH_UsernameMap = new Map<String, Map<String, String>>();
        for (Touchpoint_Owner_mapping__mdt mdtRec : [
                SELECT 
                    Username__c,
                    Touchpoint_Name__c,
            		Functional_Head_Email__c,
                    Region__c
                FROM 
                    Touchpoint_Owner_mapping__mdt
        ]) {
            if(!touchpointRegionFH_UsernameMap.containsKey(mdtRec.Touchpoint_Name__c)) {
                
            	//Functional Head Details
                touchpointRegionFH_UsernameMap.put(	 mdtRec.Touchpoint_Name__c
                                                   , new Map<String, String> {
                                                       							mdtRec.Region__c => mdtRec.Functional_Head_Email__c
                                                                             }
                                                  );
            } else {                
                touchpointRegionFH_UsernameMap.get(mdtRec.Touchpoint_Name__c).put(	 mdtRec.Region__c
                                                                                   , mdtRec.Functional_Head_Email__c);
                 
            }
        }
        return touchpointRegionFH_UsernameMap;
    }
    
    public static User getDefaultUserDetails() {
        List<Touchpoint_Owner_mapping__mdt> defaultUserDetails = [
              SELECT Username__c
            	   , Functional_Head_Email__c	
               FROM Touchpoint_Owner_mapping__mdt
              WHERE Region__c 			  = :ALL_ZONES
                AND Touchpoint_Name__c 	  = :DEFAULT_MANAGER
         ];
        
        return  [
            SELECT 
            	Id
            FROM 
            	User
            WHERE 
            	userName = :defaultUserDetails[0].Username__c
            LIMIT 1
        ];
    }
}