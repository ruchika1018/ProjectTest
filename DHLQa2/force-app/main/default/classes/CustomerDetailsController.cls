public class CustomerDetailsController {  
    
    public static Map<Id,Customer__c> customerDataMap = new Map<Id,Customer__c>();
    public class TargetData {
        public String  			touchpoint;
        public Integer 			nonKeyAccounts;
        public Integer 			keyAccounts;
        
        public TargetData() {
            touchpoint	  	= '';            
            nonKeyAccounts 	= 0;
            keyAccounts	  	= 0;
        }
    }
    
	public class CustomerDetailsWrapper {
        public String firstCallerName;
        public String callNotAttemptedLabel;
        public String callStatusDone;
        public String callStatusOpen;
        public String createdDateFilter;
        public Boolean isNpaAnalystLoggedIn;
        public Id 	  callerId;
    	public List<String> 				  targetTableKeyNonkeyLabels;
        public List<String> 				  targetTableColumnLabels;
        public List<String> 				  customerTableColumnLabels;
        public List<Customer__c> 			  customerData;
    	public List<TargetData> 		 	  targetData;        
        public Map<String, Integer> 		  recordType_nonKeyAccountsMap;
        public Map<String, Integer> 		  recordType_KeyAccountsMap;
        public Map<Id, Schema.RecordTypeInfo> recordTypeIdNameMap;
        public Map<Id, String>				  customerIdStatusMap;
        public Map<Id, String>				  customerIdCallAttemptsMap;
        public Map<Id, String>				  customerIdRatingMap;
        public Map<Id, Net_Promoter_Score__c> customerIdNPSRecordMap;
        
        
        public CustomerDetailsWrapper () {
            System.debug('here');
            firstCallerName 			 = '';
            callNotAttemptedLabel 		 = Label.DHL_Customer_Customer_table_Call_Not_Attempted_Label;
            callStatusDone				 = Label.DHL_Customer_Customer_table_First_Caller_Call_Status_Done_Label;
            callStatusOpen				 = Label.DHL_Customer_Customer_table_First_Caller_Call_Status_Open_Label;
            createdDateFilter            = Label.DHL_Customer_Customer_table_Created_Date_Filter;
            isNpaAnalystLoggedIn    	 = false;
            callerId					 = null;
            customerData				 = new List<Customer__c>();
            recordType_nonKeyAccountsMap = new Map<String, Integer>();
            recordType_KeyAccountsMap 	 = new Map<String, Integer>();
            recordTypeIdNameMap			 = getRecordTypeInfo();
            targetData					 = initalizeTargetData(recordTypeIdNameMap);
            customerIdStatusMap			 = new Map<Id, String>();
            targetTableKeyNonkeyLabels   = new List<String>();
            targetTableColumnLabels      = new List<String>();
            customerTableColumnLabels 	 = new List<String>();
            customerIdRatingMap			 = new Map<Id, String>();
            customerIdCallAttemptsMap	 = new Map<Id, String>();
            customerIdNPSRecordMap	 	 = new Map<Id, Net_Promoter_Score__c>();
        }
    
    	public Map<Id,Schema.RecordTypeInfo> getRecordTypeInfo() { 
            system.debug('In getRecordTypeInfo');
			return Schema.SObjectType.Customer__c.getRecordTypeInfosById();
    	}
        
        public List<TargetData> initalizeTargetData( Map<Id, Schema.RecordTypeInfo> recordTypeIdNameMap) {
            system.debug('In initalizeTargetData');
            List<TargetData> targetData = new List<TargetData>();
            
            for (Id recordTypeId : recordTypeIdNameMap.keySet()) {
                TargetData data 	= new TargetData();
                data.touchpoint 	= recordTypeIdNameMap.get(recordTypeId).getName();
                data.keyAccounts 	= 0;
                data.nonKeyAccounts = 0;
                targetData.add(data);
        	}
            return targetData;
    	}
    }
    
    @AuraEnabled(cacheable=false)
    public static String getCustomerDetails() {        
        CustomerDetailsWrapper data 	= new CustomerDetailsWrapper();
        data.firstCallerName			= getFirstCallerName();  
        data.callerId					= getFirstCallerId();
        data.customerData				= getCustomerRecords(data.createdDateFilter);
        data.isNpaAnalystLoggedIn   	= SecondCallerNPAListController.validate_NPAAnalystLoggedIn();
		data 							= setcustomerNPADetails(data);        
        data							= setTargetData(data);
        data.targetTableKeyNonkeyLabels = setTargetTableKeyNonKeyLabels(data);
        data.targetTableColumnLabels    = setTargetTableColumnLabels(data);
        data.customerTableColumnLabels  = setCustomerTableColumnLabels(data);
        return JSON.serialize(data);
    }
    
    public static List<String> setCustomerTableColumnLabels(CustomerDetailsWrapper data) {
            data.customerTableColumnLabels = new List<String>();
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_table_Customer_Name_Label);
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_Table_Touchpoint_Label);
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_table_Call_Status_Label);
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_table_Call_Attempts_Label);
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_Table_Rating_Label);
        	data.customerTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Next_Callback_Date_Label);
        	data.customerTableColumnLabels.add(Label.DHL_Net_Promoter_Score_NPS_Table_Owner_Name_Label);
        	data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_table_LastModifiedDate_Label); 
            data.customerTableColumnLabels.add(Label.DHL_Customer_Customer_table_Customer_Id_Label); 
        return data.customerTableColumnLabels;
    }
    
    public static List<String> setTargetTableColumnLabels(CustomerDetailsWrapper data) {
            data.targetTableColumnLabels = new List<String>();
            data.targetTableColumnLabels.add(Label.DHL_Customer_Target_table_Customer_Excellence_Label);
            data.targetTableColumnLabels.add(Label.DHL_Customer_Target_table_Operations_Label);
            data.targetTableColumnLabels.add(Label.DHL_Customer_Target_table_Order_Management_Label);
            data.targetTableColumnLabels.add(Label.DHL_Customer_Target_table_Sales_Label);
        	data.targetTableColumnLabels.add(Label.DHL_Customer_Target_table_Billing_Label);
        return data.targetTableColumnLabels;
    }
    
    public static List<String> setTargetTableKeyNonKeyLabels(CustomerDetailsWrapper data) {
            data.targetTableKeyNonkeyLabels = new List<String>();
            data.targetTableKeyNonkeyLabels.add(Label.DHL_Customer_Target_table_Key_Label);
            data.targetTableKeyNonkeyLabels.add(Label.DHL_Customer_Target_table_Non_Key_Label);
        return data.targetTableKeyNonkeyLabels;
    }
  
   public static List < Customer__c > getCustomerRecords(String createdDateFilter) { 
       List<Customer__c> customerRecords = new  List<Customer__c>();
       List<Customer__c> customerRecordsToReturn = new  List<Customer__c>();
       String query = ''+
           			'SELECT Id'+
                    ', Name'+
                    ', Customer_Name__c'+  
                    ', Is_Key_Account__c'+
                    ', RecordType.Name'+   
                    ', Owner.Name'+
           			', LastModifiedDate'+
           			', Is_Shared__c '+
                 ' FROM Customer__c'+
           		' WHERE CreatedDate >= '+createdDateFilter+' '+ 
             ' ORDER BY CreatedDate DESC'+
                ' LIMIT 1000';		
     
       customerRecords = Database.query(query);      
       return customerRecords;
   }
    
    public static String getFirstCallerName() {
        return UserInfo.getName();
    }
    
    public static String getFirstCallerId() {
        return UserInfo.getUserId();
    }
    
    public static CustomerDetailsWrapper setcustomerNPADetails (CustomerDetailsWrapper data) {
        List<Customer__c> customerData		  			= new List<Customer__c>();       
        
        for( Net_Promoter_Score__c nps: [
            SELECT Id
            	 , Status__c
            	 , NPA_Rating__c
            	 , Customer__c
                 , Customer__r.Id
                 , Customer__r.Customer_Name__c 
                 , Customer__r.RecordType.Name
            	 , Customer__r.Is_Key_Account__c
            	 , Customer__r.RecordTypeId
                 , Customer__r.OwnerId
             	 , Call_Attempts__c
            	 , Fc1_Callback_Date__c
           		 , Fc2_Callback_Date__c
           		 , Fc3_Callback_Date__c
              FROM Net_Promoter_Score__c
             WHERE Customer__c IN :data.customerData    

        ]) {
              String customerRecordType = String.valueOf( data.recordTypeIdNameMap.get(nps.Customer__r.RecordTypeId).getName() );
               System.debug('customerRecordType'+customerRecordType);
               if ( nps.Customer__r.Is_Key_Account__c ) {                    
                    if (data.recordType_KeyAccountsMap.isEmpty()) {
                         System.debug('In here 1111');
                         data.recordType_KeyAccountsMap.put(customerRecordType, 1);
                    } else {
                        
                       Integer keyAccountsCount = 0;
                       keyAccountsCount =  data.recordType_KeyAccountsMap.get(customerRecordType) == null 
                             					   ? 0
                                                   : data.recordType_KeyAccountsMap.get(customerRecordType);
                        
                        keyAccountsCount = keyAccountsCount +1;
                         data.recordType_KeyAccountsMap.put(   customerRecordType
                                                             ,  keyAccountsCount
                                                           ); 
                    }
                } else {
                   if (data.recordType_nonKeyAccountsMap.isEmpty()) {
                         data.recordType_nonKeyAccountsMap.put(customerRecordType, 1);
                    } else {
                         Integer nonkeyAccountsCount =  data.recordType_nonKeyAccountsMap.get(customerRecordType) == null
                             						 ? 0
                                                     : data.recordType_nonKeyAccountsMap.get(customerRecordType);
                         data.recordType_nonKeyAccountsMap.put(   customerRecordType
                                                             	,  ++nonkeyAccountsCount
                                                           ); 
                    }
                }
            
            //create map of CustomerId and status.            
            if( 	String.isNotBlank(nps.Status__c) ) {
                data.customerIdStatusMap.put(nps.Customer__c, nps.Status__c);
            }
            if( 	String.isNotBlank(nps.NPA_Rating__c) ) {              
                data.customerIdRatingMap.put(nps.Customer__c, nps.NPA_Rating__c);
            }
            
            //map of customer Id and call atempts
            data.customerIdCallAttemptsMap.put(nps.Customer__c, String.valueOf(nps.Call_Attempts__c));       
            
            //Map of customer Id nps record
            data.customerIdNPSRecordMap.put(nps.Customer__c, nps);   
        }
      
        return data;
    }
    
    public static CustomerDetailsWrapper setTargetData( CustomerDetailsWrapper data) {
        
        List<TargetData> targetData = new List<TargetData>();
        
        for (TargetData targetDetails : data.targetData) {
            targetDetails.keyAccounts	 = data.recordType_KeyAccountsMap.get(targetDetails.touchpoint) == null 
                						 ? 0 :  data.recordType_KeyAccountsMap.get(targetDetails.touchpoint);
            targetDetails.nonKeyAccounts = data.recordType_nonKeyAccountsMap.get(targetDetails.touchpoint) == null 
                						 ? 0 :  data.recordType_nonKeyAccountsMap.get(targetDetails.touchpoint);
            targetData.add(targetDetails); 
        }
        data.targetData = targetData; 
        
        return  data;
    }
}