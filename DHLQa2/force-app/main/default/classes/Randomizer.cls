public class Randomizer {
	public static String queryLimit = System.Label.Randomizer_Query_Result_Limit;
    public Map<String, List<String>> mapfirstCallerToTouchpoints = new Map<String, List<String>>();
    public Map<String, List<String>> mapTouchpointTofirstCallers = new Map<String, List<String>>();
       
    //Constructor
    public Randomizer(){
		getfirstCallerWithTouchpoints();
        //System.debug('---->mapfirstCallerToTouchpoints'+mapfirstCallerToTouchpoints);
        //System.debug('---->mapTouchpointTofirstCallers'+mapTouchpointTofirstCallers);
    }

    public List<WrapperCustomers> getCustomerforCurrentuser(){
        List<WrapperCustomers> lstCustWrapper = new List<WrapperCustomers>();
       
        for(String username : mapfirstCallerToTouchpoints.keySet()){
            List<String> touchPoints = mapfirstCallerToTouchpoints.get(username);
            lstCustWrapper.add(getCustomersForFirstCaller(touchPoints,username));
        }
        
        for(String touchpoint : mapTouchpointTofirstCallers.keySet()){
            if(mapTouchpointTofirstCallers.get(touchpoint).size() > 1){
                lstCustWrapper.addAll(distributeSameTouchpointData(touchpoint, mapTouchpointTofirstCallers.get(touchpoint)));
            } 
        }
        
        for(WrapperCustomers objwrp : lstCustWrapper){
           System.debug('----->Lst size'+ objwrp.lstCustomer.size()+'user'+objwrp.firstcaller); 
        }
       
        return lstCustWrapper;

    } 
    
    //Method to fetch customer data for 1st caller landing page    
    public WrapperCustomers getCustomersForFirstCaller(List<String> listTouchpoints, String firstCaller){
        System.debug('--?listTouchpoints'+listTouchpoints);
        List<Customer__c> lstCustomersToShare = new List<Customer__c>();
        lstCustomersToShare = getCustomersToShare(listTouchpoints);
        WrapperCustomers objWrapper = new WrapperCustomers();
        objWrapper.lstCustomer = lstCustomersToShare;
        objWrapper.firstCaller = firstCaller;
        return objWrapper;
        
    }

    //Method to fetch touchpoints and its data range from custom metadata type
    public Map<String, Tochpoints_with_Duration__mdt> getTpointsWithDuration(){
        Map<String, Tochpoints_with_Duration__mdt> mapTpointsWithDuration = new Map<String, Tochpoints_with_Duration__mdt>();
                
        for(Tochpoints_with_Duration__mdt recMetadata: [Select MasterLabel,Developername, Duration__c From Tochpoints_with_Duration__mdt]){
            System.debug('--->recMetadata inside for'+recMetadata);
            mapTpointsWithDuration.put(recMetadata.MasterLabel,recMetadata);
        }
		
        //System.debug('--->mapTpointsWithDuration outside for'+mapTpointsWithDuration);
        return mapTpointsWithDuration;
    }

    //Method to fetch first caller and its touchponts from custom object
     public void getfirstCallerWithTouchpoints(){
        List<User_Touchpoint_Mapping__c> lstConfig = [SELECT Caller_Name__c,Touchpoint_Name__c FROM User_Touchpoint_Mapping__c ];       
        
        for(User_Touchpoint_Mapping__c objConfig: lstConfig){
            String strTouchpoint = objConfig.Touchpoint_Name__c;
            List<String> listTouchpoints = new List<String>();
            if(String.isNotBlank(strTouchpoint) && strTouchpoint.contains(',')){
               listTouchpoints = strTouchpoint.split(','); 
            }else if(String.isNotBlank(strTouchpoint) && !strTouchpoint.contains(',')){
               listTouchpoints.add(strTouchpoint);
            }
            for(String touchpoint : listTouchpoints){
                if(!mapTouchpointTofirstCallers.containsKey(touchpoint)){
                    mapTouchpointTofirstCallers.put(touchpoint,new List<String>{objConfig.Caller_Name__c});
                }else{
                    mapTouchpointTofirstCallers.get(touchpoint).add(objConfig.Caller_Name__c);
                }
            }
         }
        
        //Create map for first caller to list of multiple touchpoint  
        for(User_Touchpoint_Mapping__c objConfig: lstConfig){
            String strTouchpoint = objConfig.Touchpoint_Name__c;
            List<String> listTouchpoints = new List<String>();
            if(String.isNotBlank(strTouchpoint) && strTouchpoint.contains(',')){
               listTouchpoints = strTouchpoint.split(','); 
            }else if(String.isNotBlank(strTouchpoint) && !strTouchpoint.contains(',')){
               listTouchpoints.add(strTouchpoint);
            }
            
           	List<String> lstUpdatedTouchpoints = new List<String>();
            for(String touchpoint : listTouchpoints){
              if(mapTouchpointTofirstCallers.get(touchpoint).size() == 1){
                  lstUpdatedTouchpoints.add(touchpoint);
              }
            }
            if(!lstUpdatedTouchpoints.isEmpty()){
            	mapfirstCallerToTouchpoints.put(objConfig.Caller_Name__c,lstUpdatedTouchpoints);    
            }
        	
        } 

    }
    
    public Map<String,Customer__c> getPrevousNpaHistory(List<Customer__c> lstCustomer){
       Set<String> setCustomersEkp = new Set<String>();
       Map<String,Customer__c> mapTpointsToCustomer = new Map<String,Customer__c>();
        for(Customer__c objCust : lstCustomer){
            if(String.isNotBlank(objCust.EKP__c)){
              setCustomersEkp.add(objCust.EKP__c);  
            }else if(String.isNotBlank(objCust.Account_Id__c)){
              setCustomersEkp.add(objCust.Account_Id__c);  
            }else if(String.isNotBlank(objCust.Lead_Id__c)){
              setCustomersEkp.add(objCust.Lead_Id__c);  
            }
            
        }
        
        List<Customer__c> lstprevCustomers = [Select Id
                                              	   , RecordTypeId
                                              	   , EKP__c
                                              	   , Account_Id__c
                                              	   , Lead_Id__c
                                              	   , CreatedDate
                                              	   , Customer_Name__c
                                              	   , (Select Id
                                                   , Name
                                                   , Fc1_Status__c
                                                   , Fc1_Attempted_Date__c
                                                   , Fc2_Status__c
                                                   , Fc2_Attempted_Date__c
                                                   , Fc3_Status__c
                                                   , Fc3_Attempted_Date__c
                                                   , LastmodifiedDate
                                                   , Status__c 
                                                From Net_Promoter_Scores__r 
                                               Where NPA_Rating__c != Null
                                   			   Limit 1)
                                                From Customer__c
                                               Where (EKP__c IN :setCustomersEkp
                                                  OR Account_Id__c IN :setCustomersEkp
                                                  OR Lead_Id__c IN :setCustomersEkp)
                                              	 AND Id NOT IN :lstCustomer
                                                 AND (CreatedDate = LAST_MONTH 
                                              	  OR CreatedDate = THIS_MONTH)
                                            ORDER BY createddate DESC];
        
        System.debug('--->lstprevCustomers'+lstprevCustomers);
                
        for(Customer__c objCust : lstprevCustomers){
            String strekpTpoints = getUniqueKey(objCust);
                        
            //System.debug('--->objCust createddate'+objCust.CreatedDate+' name'+objCust.Customer_Name__c);
            //System.debug('--->strekpTpoints'+strekpTpoints+' NPa rec'+objCust.Net_Promoter_Scores__r.size());
            
            if(String.isNotBlank(strekpTpoints) && 
               !mapTpointsToCustomer.containsKey(strekpTpoints) && 
               objCust.Net_Promoter_Scores__r.size() == 1){
                mapTpointsToCustomer.put(strekpTpoints,objCust);
            }
        }
        
        System.debug('--->mapTpointsToCustomer'+mapTpointsToCustomer);
        return mapTpointsToCustomer;
        
    }
    
    public String getUniqueKey(Customer__c objCustomer){
        Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
        Map<Id,Schema.RecordTypeInfo> recTypeMapById = customerDesribe.getRecordTypeInfosById();
        String uniqueKey = '';
            
            if(String.isNotBlank(objCustomer.Ekp__c) && 
               recTypeMapById.get(objCustomer.RecordTypeId).getName() == 'Operations'){
                uniqueKey = objCustomer.Ekp__c+objCustomer.RecordTypeId;
            }else if(String.isNotBlank(objCustomer.Ekp__c) &&
                     recTypeMapById.get(objCustomer.RecordTypeId).getName() == 'Order Management'){
                uniqueKey = objCustomer.Ekp__c+objCustomer.RecordTypeId;
            }else if((String.isNotBlank(objCustomer.Account_Id__c) || String.isNotBlank(objCustomer.Lead_Id__c)) &&
                     recTypeMapById.get(objCustomer.RecordTypeId).getName() == 'Sales'){
                
                uniqueKey = String.isNotBlank(objCustomer.Account_Id__c) ?
                    			objCustomer.Account_Id__c+objCustomer.RecordTypeId :
                				objCustomer.Lead_Id__c+objCustomer.RecordTypeId;
                                    
            }else if(String.isNotBlank(objCustomer.Account_Id__c) &&
                     recTypeMapById.get(objCustomer.RecordTypeId).getName() == 'Customer Excellence'){
                uniqueKey = objCustomer.Account_Id__c+objCustomer.RecordTypeId;
            }else if(String.isNotBlank(objCustomer.Ekp__c) &&
                     recTypeMapById.get(objCustomer.RecordTypeId).getName() == 'Billing'){
                uniqueKey = objCustomer.Ekp__c+objCustomer.RecordTypeId;
            }
        return uniqueKey;
    }
    
    public List<WrapperCustomers> distributeSameTouchpointData(String touchpoint, List<String> lstUserName){
        List<Customer__c> lstDividedCutomers;
        List<WrapperCustomers> lstWrapper = new List<WrapperCustomers>();
        List<Customer__c> lstCustomersToShare = new List<Customer__c>();
        lstCustomersToShare = getCustomersToShare(new List<String>{touchpoint});
            
            Integer intlimit = 0;
        	//System.debug('--->lstCustomersToShare size'+lstCustomersToShare.size());
        	//System.debug('--->lstUserName size'+lstUserName.size());
        
            if(!lstCustomersToShare.isEmpty() && lstUserName.size() > 0){
               intlimit = lstCustomersToShare.size() / lstUserName.size(); 
            }
            
        	System.debug('--->intlimit'+intlimit);
        	Integer counter = 0;
            //divide final customer list equally within users
            for(String username : lstUserName){
                WrapperCustomers objWrapper = new WrapperCustomers();
                lstDividedCutomers = new List<Customer__c>();
                //System.debug('--->lstCustomersToShare size'+lstCustomersToShare.size());
                
                for(Integer i = intlimit-1 ; i >= 0 ; i--){
                    //System.debug('--->i'+i);
                	lstDividedCutomers.add(lstCustomersToShare[i]);
                    lstCustomersToShare.remove(i);
                    
                }
                
                objWrapper.firstCaller = username;
                objWrapper.lstCustomer = lstDividedCutomers;
                lstWrapper.add(objWrapper);
            }
            
        	System.debug('final *** size'+lstCustomersToShare.size());
        	if(lstCustomersToShare.size() == 1 && lstWrapper.size() > 0){
                lstWrapper[0].lstCustomer.add(lstCustomersToShare[0]);
            }
        
        return lstWrapper;
    }
    
    public List<Customer__c> getCustomersToShare(List<String> listTouchpoints){
    	List<Customer__c> lstCustomersToShare = new List<Customer__c>();
        Set<String> setUniqueKey = new Set<String>();
        Schema.DescribeSObjectResult customerDesribe = Schema.SObjectType.Customer__c;
        Map<String,Schema.RecordTypeInfo> recTypeMapByName = customerDesribe.getRecordTypeInfosByName();
        String strQuery = '';
        System.debug('--->'+recTypeMapByName);
        if(!listTouchpoints.isEmpty()){
                strQuery = 'Select Id'+
                                   ', Name'+
                                   ', RecordTypeId'+
                                   ', Is_Shared__c'+
                                   ', EKP__c'+
                                   ', Account_Id__c'+
                                   ', Lead_Id__c'+
                                   ', Customer_Name__c '+
                                   ', (Select Id'+
                                           ', Fc1_Status__c'+
                                           ', Fc1_Callback_Date__c'+
                                           ', Fc2_Status__c'+
                                           ', Fc2_Callback_Date__c'+
                                           ', Fc3_Status__c'+
                                           ', Fc3_Callback_Date__c '+
                                           ', Status__c '+
                                        'From Net_Promoter_Scores__r '+ 
                                       'Where Status__c ='+'\'FC In Progress\' '+
                                       'Limit 1) '+
                               'From Customer__c '+
                              'Where DND__c = false '+
                              'AND Is_Shared__c = false ';
                              
                              
            Map<String, Tochpoints_with_Duration__mdt> maptouchPointsWithDuration = getTpointsWithDuration();
            System.debug('--->maptouchPointsWithDuration 111'+maptouchPointsWithDuration);
            Integer counter = 0;
            Id recId = null;
            String Duration = '';
            System.debug('--->Query'+lstCustomersToShare);
             System.debug('--->listTouchpoints before for'+listTouchpoints);
            if(listTouchpoints.size() == 1){
                strQuery += 'AND ';
            }else if(listTouchpoints.size() > 1){
                strQuery += 'AND (';
            }
            
            for(String touchPoint : listTouchpoints){
                if(String.isNotBlank(touchPoint) && recTypeMapByName.containsKey(touchPoint)){
                    recId = recTypeMapByName.get(touchPoint).getRecordTypeId();
                }
                if(String.isNotBlank(touchPoint) && maptouchPointsWithDuration.containsKey(touchPoint)){
                    Duration = maptouchPointsWithDuration.get(touchPoint).Duration__c;
                }
                
                strQuery += '(RecordTypeId = \''+ recId+'\' '+
                            'And CreatedDate = '+ Duration+') ';
                counter++;            
                if(counter < listTouchpoints.size()){
                    strQuery += 'OR ';
                }
    
            }
            
            if(listTouchpoints.size() > 1){
                strQuery += ') ';
            }
            strQuery +='Limit '+queryLimit+'';
        }
        System.debug('--->Query 1'+strQuery);
        List<Customer__c> lstCustomers = new List<Customer__c>();
        if(String.isNotBlank(strQuery)){
        	lstCustomers = Database.query(strQuery);    
        }
        
        Map<String,Customer__c> mapPrevNpaHistory = getPrevousNpaHistory(lstCustomers);
        
        System.debug('Map-mapPrevNpaHistory--> '+mapPrevNpaHistory);
        
        for(Customer__c objCustomer : lstCustomers){
            String uniqueKey = getUniqueKey(objCustomer);
            Boolean isSurveyOlder = false;
            Boolean isUnique = false;
            
            System.debug('-->uniqueKey'+uniqueKey);
            if(!setUniqueKey.contains(uniqueKey)){
                if(String.isNotBlank(uniqueKey)){
                	setUniqueKey.add(uniqueKey);    
                }
                isUnique = true;
            }
            
            if(String.isNotBlank(uniqueKey) && mapPrevNpaHistory.containsKey(uniqueKey)){
            	Net_Promoter_Score__c prevNpa = mapPrevNpaHistory.get(uniqueKey).Net_Promoter_Scores__r[0];
                DateTime attemptedDate = String.isNotBlank(prevNpa.Fc3_Status__c) && prevNpa.Fc3_Status__c == 'Successful'
                                                            ? prevNpa.Fc3_Attempted_Date__c 
                                                            : String.isNotBlank(prevNpa.Fc2_Status__c) && prevNpa.Fc2_Status__c == 'Successful'
                                                                    ? prevNpa.Fc2_Attempted_Date__c  
                                                                    : String.isNotBlank(prevNpa.Fc1_Status__c) && prevNpa.Fc1_Status__c == 'Successful'
                                                                            ? prevNpa.Fc1_Attempted_Date__c 
                                                                            : null;
                
                isSurveyOlder = System.today().addDays(-30) > attemptedDate ? true
                    														: false;
                //System.debug('-->Date.today().addDays(30 '+System.today().addDays(-30));
                //System.debug('-->prevNpa.Fc1_Attempted_Date__c '+attemptedDate);
                //System.debug('-->isSurveyOlder'+isSurveyOlder);
                //System.debug('-->prevNpa.Name'+prevNpa.Name);
            }else{
                isSurveyOlder = true;
            }
             

            if((!objCustomer.Is_Shared__c && isSurveyOlder && isUnique)){
                lstCustomersToShare.add(objCustomer);
            }
                        
        }
        return lstCustomersToShare;
    }

    //Wrapper class for customer
    public class WrapperCustomers {
        public List<Customer__c> lstCustomer; 
        public String firstCaller;
 
        //constructor
        public WrapperCustomers() {
            lstCustomer = new List<Customer__c>();
            firstCaller = '';
        }
    }
}