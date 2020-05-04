public class SecondCallerNPAListController {
	
   public static Integer RATING_QUERY_FILTER 		= 9;
   public static String  CLOSED_STATUS 				= 'Closed';
   public static String  NPA_ANALYST_PROFILE_NAME	= 'Chief Service Officer(DHL)'; 
   public static String  FC_PENDING					= 'FC Pending';
   public static String  FC_IN_PROGRESS   		    = 'FC In Progress';

       
    public class NPADetailsWrapper {
        public String secondCallerName;
        public String npsTableName;
        
        public Boolean isNpaAnalystLoggedIn;
        
        public Integer targetCount;
        
        public List<Net_Promoter_Score__c> 		npsData;
        public List<String> 				  	npsTableColumnLabels;
        
        public NPADetailsWrapper () {
            secondCallerName 		= '';
            npsData 		 		= new List<Net_Promoter_Score__c>();
            npsTableColumnLabels 	= new List<String>();
            npsTableName			= '';
            targetCount				= 0;
            isNpaAnalystLoggedIn    = false;
        }
    }
    
     @AuraEnabled(cacheable=false)
    public static String getNPADetails() { 
        new NPADetailsWrapper();
        NPADetailsWrapper data 		= new NPADetailsWrapper();
        data.secondCallerName 		= Utils.getLoggedInUserName();
        data.isNpaAnalystLoggedIn   = validate_NPAAnalystLoggedIn();
        data.npsData		   		= getNPS_Data(data.isNpaAnalystLoggedIn);
        data.npsTableName 			= Label.DHL_Net_Promoter_Score_NPS_Table_Label;
        data.npsTableColumnLabels	= setNPSTableColumnLabels(data);
        data.targetCount			= getTargetTableCount(data.npsData); 
        return JSON.serialize(data);
    }
    
    public static Integer getTargetTableCount(List<Net_Promoter_Score__c> npsdata) {
        return [
            SELECT COUNT()
              FROM Net_Promoter_Score__c
             WHERE Status__c = :CLOSED_STATUS
               AND Id IN :npsdata
        ];
    }
    
    public static List<String> setNPSTableColumnLabels(NPADetailsWrapper data) {
        	data.npsTableColumnLabels = new List<String>();
            data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Customer_Name_Label);
            data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Status_Label);
            data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Rating_Label);
            data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Days_Since_Assigned_Label);
        	data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Next_Callback_Date_Label);
        	data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Is_Reassigned_Label);
        	data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Owner_Name_Label);
        	data.npsTableColumnLabels.add(Label.DHL_Net_Promoter_Score_Table_LastModifiedDate_Label);
        	data.npsTableColumnLabels.add(Label.DHL_Customer_Customer_Table_Touchpoint_Label);
            data.npsTableColumnLabels.add(Label.DHL_Customer_Customer_table_Customer_Id_Label);        
        return data.npsTableColumnLabels;
    }
    
   
    public static List<Net_Promoter_Score__c> getNPS_Data(Boolean isNpaAnalystLoggedIn) {
        List<Net_Promoter_Score__c> npsRecords = new List<Net_Promoter_Score__c>();
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
		
        for (Net_Promoter_Score__c nps :  [
            SELECT Id
            	 , Name
                 , Status__c
            	 , NPA_Rating__c
                 , Customer__r.Customer_Name__c
            	 , Days_since_SC_Assignment__c
            	 , Sc1_Callback_Date__c
            	 , Sc2_Callback_Date__c
            	 , Sc3_Callback_Date__c
            	 , Is_SC_Reassigned__c
            	 , Rsc3_Callback_Date__c
             	 , Rsc2_Callback_Date__c
            	 , Rsc1_Callback_Date__c
            	 , SC_Assignment_Date__c
            	 , Make_Second_Call__c
            	 , Customer__r.Name
            	 , Customer__r.Owner.Name
            	 , Customer__r.RecordType.Name
            	 , LastModifiedDate 
              FROM Net_Promoter_Score__c
             WHERE NPA_Rating__c != NULL
            ORDER BY CreatedDate DESC
            LIMIT 1000
        ]) {            
            
            if (   CLOSED_STATUS.equals(nps.Status__c)) {
                if (isNpaAnalystLoggedIn) {
                    npsRecords.add(nps);
                } else if (
                       !isNpaAnalystLoggedIn  
                	&& nps.SC_Assignment_Date__c != NULL
                    && nps.SC_Assignment_Date__c >= firstDayOfMonth
                    && nps.SC_Assignment_Date__c <= lastDayOfMonth 
                ) {
                    npsRecords.add(nps);
                }             
            }  else if (!CLOSED_STATUS.equals(nps.Status__c) ) {                   
                if ( 	!isNpaAnalystLoggedIn 
                    && 	Integer.valueOf(nps.NPA_Rating__c) < RATING_QUERY_FILTER
                    &&  nps.Make_Second_Call__c
                    &&  nps.Status__c != FC_PENDING
                    &&  nps.Status__c != FC_IN_PROGRESS
                   ) {                      
                       npsRecords.add(nps);
                   } else if (isNpaAnalystLoggedIn && !FC_IN_PROGRESS.equals(nps.Status__c )) {                      
                       npsRecords.add(nps);
                   }                  
            }
        }
                
        return npsRecords;
    }    
    
    public static Boolean validate_NPAAnalystLoggedIn() {
       Boolean isNpaAnalystLoggedIn = false;
        List<User> loggedInUser = [
            SELECT Id
            	 , profile.Name
              FROM User
             WHERE Id = :Utils.getLoggedId()
        ];
        
        if (!loggedInUser.isEmpty() && loggedInUser.size() == 1) {
            if (NPA_ANALYST_PROFILE_NAME.equals(loggedInUser[0].profile.Name)) {
               	isNpaAnalystLoggedIn = true;
            } else {
               	 isNpaAnalystLoggedIn = false;
            }
        } 
        System.debug('isNpaAnalystLoggedIn :'+isNpaAnalystLoggedIn);
        return isNpaAnalystLoggedIn;
    }
}