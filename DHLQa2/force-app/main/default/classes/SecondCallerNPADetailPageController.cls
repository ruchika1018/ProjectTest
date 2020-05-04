public class SecondCallerNPADetailPageController {
    
    public class CustomerDetailsWrapper {
        public Net_Promoter_Score__c nps;
        public Boolean				 isNPA_AnalystLoggedIn;
        
        public CustomerDetailsWrapper() {
            nps = new Net_Promoter_Score__c();
            isNPA_AnalystLoggedIn = false;
        }
    }
    
      @AuraEnabled
    public static String getCustomerDetails(Id recordId) {
        CustomerDetailsWrapper data = new CustomerDetailsWrapper();
        data.nps 					= getNpaRecord(recordId);
        data.isNPA_AnalystLoggedIn	= SecondCallerNPAListController.validate_NPAAnalystLoggedIn();
        return JSON.serialize(data);
    }    
   
    public static Net_Promoter_Score__c getNpaRecord(Id recordId) {
        Net_Promoter_Score__c objNpa; 
        List<Net_Promoter_Score__c> lstNpa = [ Select Id
                                                    , Customer__c
                                                    , Customer__r.Customer_Name__c
                                                    ///Commented as per issue SB-269
                                                    //, Customer__r.Account_Name__c
                                                    , Customer__r.Contact_Mobile__c
                                                    , Customer__r.Contact_Email__c
                                                    , Customer__r.RecordTypeId
                                                    , NPA_Rating__c
                                                    , Fc1_Comments__c
                                                    , Fc2_Comments__c
                                                    , Fc3_Comments__c
                                                    , Sc1_Callback_Date__c
                                                    , Sc1_Comments__c
                                                    , Sc1_Status__c                                                   
                                                    , Sc2_Callback_Date__c
                                                    , Sc2_Comments__c
                                                    , Sc2_Status__c
                                                    , Sc3_Callback_Date__c
                                                    , Sc3_Comments__c
                                                    , Sc3_Status__c
                                                    , Rsc1_Callback_Date__c
                                                    , Rsc1_Comments__c
                                                    , Rsc1_Status__c
                                                    , Rsc2_Callback_Date__c
                                                    , Rsc2_Comments__c
                                                    , Rsc2_Status__c
                                                    , Rsc3_Callback_Date__c
                                                    , Rsc3_Comments__c
                                                    , Rsc3_Status__c
                                                    , Status__c
                                              		, Is_SC_Reassigned__c
                                              		, Reassign_Comments_1__c
                                              		, Reassign_Comments_2__c
                                              		, Reassign_Comments_3__c
                                              		, Reassign_Comments_4__c
                                              		, Reassign_Comments_5__c
                                                 From Net_Promoter_Score__c
                                                Where Id=:recordId];
        if(lstNpa != null && !lstNpa.isEmpty()){
                objNpa = lstNpa[0];
        }
        return objNpa;
    }
    
    @AuraEnabled
    public static Boolean closeNpaRecord(Id recordId) {
        Net_Promoter_Score__c objNpa = new Net_Promoter_Score__c(); 
        objNpa.Id = recordId;
        objNpa.Status__c = 'Closed';
        try{
            update objNpa;
            return true;
        }catch(Exception exp){
            System.debug('---->Exception'+exp);
            return false;
        }
        
    }
    
    
}