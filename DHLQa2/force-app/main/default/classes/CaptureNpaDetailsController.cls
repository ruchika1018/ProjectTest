public without sharing class CaptureNpaDetailsController {    
  
    public static String TRUE_VALUE      = 'true';
    public static String FALSE_VALUE     = 'false';    
    public static String DEFAULT_MANAGER = 'Default Manager';
    public static String ASKED_TO_CALLBACK = 'Asked to callback';

    
    @AuraEnabled
    public static String save(Net_Promoter_Score__c objNpa){
        Net_Promoter_Score__c existingNpaRec = getNpa(objNpa.Customer__c);
        
        if(objNpa.Fc1_Comments__c != null && objNpa.Fc1_Attempted_Date__c == null){
            objNpa.Fc1_Attempted_By__c = UserInfo.getName();
            objNpa.Fc1_Attempted_Date__c = System.now(); 
        }
        if(objNpa.Fc2_Comments__c != null && objNpa.Fc2_Attempted_Date__c == null) {
            objNpa.Fc2_Attempted_By__c = UserInfo.getName();
            objNpa.Fc2_Attempted_Date__c = System.now();
        }
        if(objNpa.Fc3_Comments__c != null && objNpa.Fc3_Attempted_Date__c == null) {
            objNpa.Fc3_Attempted_By__c = UserInfo.getName();
            objNpa.Fc3_Attempted_Date__c = System.now();
        }
        
        if(objNpa.Fc1_Attempted_By__c != null && objNpa.Fc1_Attempted_By__c != null 
           && objNpa.Fc1_Status__c == 'Successful' && String.IsEmpty(objNpa.NPA_Rating__c) 
           && !objNpa.Make_Second_Call__c){
            objNpa.NPA_Rating__c = '0';    
        }
        
        if(objNpa.Fc1_Status__c != null && (ASKED_TO_CALLBACK.equals(objNpa.Fc1_Status__c) == false) ){
            objNpa.Fc1_Callback_Date__c= null;    
        }
        
        if(objNpa.Fc2_Status__c != null && (ASKED_TO_CALLBACK.equals(objNpa.Fc2_Status__c) == false) ){
            objNpa.Fc2_Callback_Date__c= null;    
        }
        
        if(objNpa.Fc3_Status__c != null && (ASKED_TO_CALLBACK.equals(objNpa.Fc3_Status__c) == false) ){
            objNpa.Fc3_Callback_Date__c= null;    
        }
       
        try{
            if(existingNpaRec != null){
                   objNpa.Id = existingNpaRec.Id;
                   update objNpa;                	
            } else{
                   Insert objNpa;
                
             }            
             return 'success';
        }catch(Exception exp){            
             return 'error';
        }
                    
    }
    
    @AuraEnabled
    public static Net_Promoter_Score__c getNpa(Id parentId) {
      
        Net_Promoter_Score__c objNpa; 
        List<Customer__c> lstCustomer = [Select Id
                                              , Region__c
                                              , (Select Id
                                                      , Make_Second_Call__c
                                                      , NPA_Rating__c
                                                      , Fc1_Callback_Date__c
                                                      , Fc1_Comments__c
                                                      , Fc1_Status__c                                                     
                                                      , Fc2_Callback_Date__c
                                                      , Fc2_Comments__c
                                                      , Fc2_Status__c                                                    
                                                      , Fc3_Callback_Date__c
                                                      , Fc3_Comments__c
                                                      , Fc3_Status__c
                                                 	  , Status__c
                                                 From Net_Promoter_Scores__r
                                                Limit 1)
                                        From Customer__c
                                        Where Id=:parentId];       
        if(lstCustomer != null && !lstCustomer.isEmpty() && 
               lstCustomer[0].Net_Promoter_Scores__r.size() >0){                     
                   objNpa         = lstCustomer[0].Net_Promoter_Scores__r[0];
        }
        
        return objNpa;
    }
    
    @AuraEnabled
    public static String checkIsDefaultManagerLoggedIn(Id parentId) {       
        
         List<Customer__c> lstCustomer = [
             SELECT Id
             	  , Region__c
               FROM Customer__c
              WHERE Id = :parentId
        ];
        
        String customerRegion = '';
        if (!lstCustomer.isEmpty()) {
           customerRegion = lstCustomer[0].Region__c;          
        }
       
        if (String.isBlank(customerRegion)) {            
            Id loggedInuserId = Utils.getLoggedId();
            User usr = [
                SELECT Id
                     , username
                  FROM User
                 WHERE Id =: loggedInuserId
            ];       
            
            String loggedInUserName = usr.username;
            
            List<Touchpoint_Owner_mapping__mdt> metaData = [
                SELECT Username__c
                  FROM Touchpoint_Owner_mapping__mdt
                 WHERE Touchpoint_Name__c = :DEFAULT_MANAGER
            ];
            
            String username = metaData[0].Username__c;           
            if (username.equals(usr.username)) {               
                return TRUE_VALUE;
            } else {                 
                return FALSE_VALUE;
            }
        } else {
           return FALSE_VALUE;
        }
    }
}