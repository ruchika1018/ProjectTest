@istest public class CustomerTriggerHandlerTest {
    
    public static String BILLING 				= 'Billing';
    public static String CUSTOMER_EXCELLENCE 	= 'Customer Excellence';
    public static String OPERATIONS				= 'Operations';
    public static String SALES 					= 'Sales';
    public static String KEY_ACCOUNT			= 'Key Account';
    public static String ORDER_MANAGEMENT		= 'Order Management';
    
    public static String EAST					= 'EAST';
	public static String WEST					= 'WEST';
    public static String NORTH					= 'NORTH';
    public static String SOUTH					= 'SOUTH';
    
    public static Map<String,String> touchpointRegion_FHEmailMap 			= new Map<String,String>();
    public static Map<String,String> touchpointRegionUsernameMap 			= new Map<String,String>();
    public static Map<String,String> touchpointRegionFunctionalHeadEmailMap = new Map<String,String>();
    
    public static Map<String,Id> 	 username_IdMap				 = new Map<String,Id>(); 
    public static Map<String,id>	 customerRecordTypeNameIdMap = new Map<String,Id>();

    @TestSetup
    public static void initializeTestData () {
        setTouchpointRegion_FHEmailMap();
        setTouchpointRegion_OwnerIdMap();
        setCustomerRecordTypeNameIdMap();
    }
    
   public static void setTouchpointRegion_FHEmailMap() {
       
        for (Touchpoint_Owner_mapping__mdt data : [
            SELECT MasterLabel                
            	 , Functional_Head_Email__c
              FROM Touchpoint_Owner_mapping__mdt
        ]) {
            touchpointRegion_FHEmailMap.put(data.MasterLabel, data.Functional_Head_Email__c);
        }
        system.debug('setTouchpointRegion_FHEmailMap : '+touchpointRegion_FHEmailMap);        
    } 
    
    public static void setTouchpointRegion_OwnerIdMap() {
        touchpointRegionUsernameMap = new  Map<String,String>();
        for (Touchpoint_Owner_mapping__mdt data : [
            SELECT MasterLabel                
            	 , Username__c
                 , Functional_Head_Email__c
              FROM Touchpoint_Owner_mapping__mdt
        ]) {
            touchpointRegionUsernameMap.put(data.MasterLabel, data.Username__c);
            touchpointRegionFunctionalHeadEmailMap.put(data.MasterLabel, data.Functional_Head_Email__c);
        }
         
        for (User usr : [
            SELECT Id
            	 , username
              FROM User
             WHERE Username IN :touchpointRegionUsernameMap.values()
        ]) {
             username_IdMap.put(usr.username, usr.Id);
         } 
    } 
    
    public static void setCustomerRecordTypeNameIdMap(){      
        customerRecordTypeNameIdMap = new Map<String,Id>();
		Map<String,Schema.RecordTypeInfo> recordTypeInfo = Schema.SObjectType.Customer__c.getRecordTypeInfosByName(); 
        for (String recordType : recordTypeInfo.KeySet()) {
            System.debug('recordType : '+recordType);
            System.debug('Value : '+recordTypeInfo.get(recordType));
            customerRecordTypeNameIdMap.put(  recordTypeInfo.get(recordType).getName()
                                            , recordTypeInfo.get(recordType).getRecordTypeId());
        }
		
	System.debug('customerRecordTypeNameIdMap'+customerRecordTypeNameIdMap);
    }    
   
    //------------------------------BILLING----------------------------------------
    
    public static testmethod void testOwnerAssignmentBillingEast () {
        initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingEast');
    }
    
   public static testmethod void testOwnerAssignmentBillingWest () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingWest');
    }
    
    public static testmethod void testOwnerAssignmentBillingNorth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingNorth');
    }
    
    public static testmethod void testOwnerAssignmentBillingSouth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingSouth');
    }
    //---------------------------CUSTOMER EXCELLENCE---------------------------------------------------
    
     public static testmethod void testOwnerAssignmentCESouth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCESouth');
    }
    
     public static testmethod void testOwnerAssignmentCEEast () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCEEast');
    }
    
    public static testmethod void testOwnerAssignmentCEWest () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCEWest');
    }

     public static testmethod void testOwnerAssignmentCENorth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCENorth');
    }
    

    //---------------------------SALES---------------------------------------------------
	public static testmethod void testOwnerAssignmentSalesSouth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesSouth');
    }
    
     public static testmethod void testOwnerAssignmentSalesEast () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesEast');
    }
    
    public static testmethod void testOwnerAssignmentSalesWest () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesWest');
    }

     public static testmethod void testOwnerAssignmentSalesNorth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesNorth');
    }
   
     //---------------------------OPERATIONS---------------------------------------------------
	public static testmethod void testOwnerAssignmentOPSouth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPSouth');
    }
    
     public static testmethod void testOwnerAssignmentOPEast () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPEast');
    }
    
    public static testmethod void testOwnerAssignmentOPWest () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPWest');
    }

     public static testmethod void testOwnerAssignmentOPNorth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPNorth');
    }
    
     //---------------------------ORDER MANAGEMENT---------------------------------------------------
	public static testmethod void testOwnerAssignmentOMSouth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMSouth');
    }
    
     public static testmethod void testOwnerAssignmentOMEast () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMEast');
    }
    
    public static testmethod void testOwnerAssignmentOMWest () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMWest');
    }

     public static testmethod void testOwnerAssignmentOMNorth () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMNorth');
    }
    
    //=========================================KEY ACCOUNT START==============================================
     //------------------------------BILLING----------------------------------------
    
    public static testmethod void testOwnerAssignmentBillingEast_KeyAccount () {
        initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingEast_KeyAccount');
    }
    
     public static testmethod void testOwnerAssignmentBillingWest_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingWest_KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentBillingNorth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingNorth__KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentBillingSouth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(BILLING).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentBillingSouth_KeyAccount');
    }
    //---------------------------CUSTOMER EXCELLENCE---------------------------------------------------
    
     public static testmethod void testOwnerAssignmentCESouth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCESouth_KeyAccount');
    }
    
     public static testmethod void testOwnerAssignmentCEEast_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCEEast_KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentCEWest_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCEWest_KeyAccount');
    }

     public static testmethod void testOwnerAssignmentCENorth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(CUSTOMER_EXCELLENCE).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentCENorth_KeyAccount');
    }
    

    //---------------------------SALES---------------------------------------------------
	public static testmethod void testOwnerAssignmentSalesSouth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesSouth_KeyAccount');
    }
    
     public static testmethod void testOwnerAssignmentSalesEast_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesEast_KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentSalesWest_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesWest_KeyAccount');
    }

     public static testmethod void testOwnerAssignmentSalesNorth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(SALES).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentSalesNorth_KeyAccount');
    }
   
     //---------------------------OPERATIONS---------------------------------------------------
	public static testmethod void testOwnerAssignmentOPSouth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPSouth_KeyAccount');
    }
    
     public static testmethod void testOwnerAssignmentOPEast_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPEast_KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentOPWest_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPWes_KeyAccountt');
    }

     public static testmethod void testOwnerAssignmentOPNorth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(OPERATIONS).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOPNorth_KeyAccount');
    }
    
     //---------------------------ORDER MANAGEMENT---------------------------------------------------
	public static testmethod void testOwnerAssignmentOMSouth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , SOUTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMSouth_KeyAccount');
    }
    
     public static testmethod void testOwnerAssignmentOMEast_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , EAST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMEast_KeyAccount');
    }
    
    public static testmethod void testOwnerAssignmentOMWest_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , WEST
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMWest_KeyAccount');
    }

     public static testmethod void testOwnerAssignmentOMNorth_KeyAccount () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );

       insert customerList;       
              
       assertCustomerRecords('testOwnerAssignmentOMNorth_KeyAccount');
    }
    
    //========================================DEFAULT KEY ACCOUNT START===========================================
 	 public static testmethod void testOwnerAssignmentOM_KeyAccountNullRegion () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , ''
       );

       insert customerList;    
        
        String key = CustomerTriggerHandler.KEYACCOUNT_DEFAULT_MANAGER;
        String username = touchpointRegionUsernameMap.get(key);
        Id ownerId = username_IdMap.get(username);       
        User usr = GetTouchpointOwner.getDefaultUserDetails(); 
         if (String.isBlank(String.valueOf(ownerId))) {
             ownerId = usr.Id;
         } 
         for (Customer__c cust : [
            SELECT Id 
                 , OwnerId
             	 , Is_Key_Account__c
                 , Functional_Head_Email__c
            	 , RecordType.Name
            	 , Region__c
              FROM Customer__c
         ] ) {
              System.assertEquals(  ownerId	
                             , cust.OwnerId
                             , 'testOwnerAssignmentOM_KeyAccountNullRegion : Owner Id for customer is not as expected');
         }
    }
    
    //========================================KEY ACCOUNT END===========================================
    
    //========================================DEFAULT NON KEY ACCOUNT START===========================================
 	 public static testmethod void testOwnerAssignmentOM_NonKeyAccountNullRegion () {
       initializeTestData();
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , ''
       );

       insert customerList;    
        
        String key = CustomerTriggerHandler.KEYACCOUNT_DEFAULT_MANAGER;
        String username = touchpointRegionUsernameMap.get(key);
        Id ownerId = username_IdMap.get(username);       
        User usr = GetTouchpointOwner.getDefaultUserDetails(); 
         if (String.isBlank(String.valueOf(ownerId))) {
             ownerId = usr.Id;
         } 
         for (Customer__c cust : [
            SELECT Id 
                 , OwnerId
             	 , Is_Key_Account__c
                 , Functional_Head_Email__c
            	 , RecordType.Name
            	 , Region__c
              FROM Customer__c
         ] ) {
              System.assertEquals(  ownerId	
                             , cust.OwnerId
                             , 'testOwnerAssignmentOM_NonKeyAccountNullRegion : Owner Id for customer is not as expected');
         }
    }
    
    
    //------------------------ASSERT METHOD-------------------------------------
	
    public static void assertCustomerRecords(String methodName) {
        
		User usr = GetTouchpointOwner.getDefaultUserDetails();
        System.debug('username_IdMap : '+username_IdMap);
         for (Customer__c cust : [
            SELECT Id 
                 , OwnerId
             	 , Is_Key_Account__c
                 , Functional_Head_Email__c
            	 , RecordType.Name
            	 , Region__c
              FROM Customer__c
        ] ) {
            String key = cust.Is_Key_Account__c == true 
                		?  'Key Account' + ' - ' + cust.Region__c 
                		: cust.RecordType.Name + ' - ' + cust.Region__c;
            String username = touchpointRegionUsernameMap.get(key);
            Id ownerId = username_IdMap.get(username);
            
            if (String.isBlank(String.valueOf(ownerId))) {
                ownerId = usr.Id;
            } 
            
           System.assertEquals(  ownerId	
                                , cust.OwnerId
                                , ''+methodName+' : Owner Id for customer is not as expected');
            
        }
    }
    
    //-----------------------------------------STAMP FUNCTIONAL HEAD EMAIL ON CUSTOMER RECORD--------------------------------------------
   
     public static testmethod void testFunctionalHeadEmailAssignmentOMNorth_KeyAccount () {
       initializeTestData();
         
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , true
           							  , NORTH
       );
         
      insert customerList; 
       
              
       assertfunctionalHeadEmailCAssignedRecords('testFunctionalHeadEmailAssignmentOMNorth_KeyAccount');
    }   
    
     public static testmethod void testFunctionalHeadEmailAssignmentOMNorth () {
       initializeTestData();
         
      
       Id recordTypeId = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get(ORDER_MANAGEMENT).getRecordTypeId();
       List<Customer__c> customerList = TestDataFactory.createCustomers(
									    recordTypeId
           							  , 1
           							  , false
           							  , NORTH
       );
         
       insert customerList; 
       
             
              
       assertfunctionalHeadEmailCAssignedRecords('testFunctionalHeadEmailAssignmentOMNorth');
    }
    
    
    
	 public static void assertfunctionalHeadEmailCAssignedRecords(String methodName) { 
       
         for (Customer__c cust : [
            SELECT Id 
                 , OwnerId
             	 , Is_Key_Account__c
                 , Functional_Head_Email__c
            	 , RecordType.Name
            	 , Region__c
              FROM Customer__c
        ] ) {
            String key = cust.Is_Key_Account__c == true 
                		?  'Key Account' + ' - ' + cust.Region__c 
                		: cust.RecordType.Name + ' - ' + cust.Region__c;
            
           String functionalHeadEmail = touchpointRegionFunctionalHeadEmailMap.get(key);
            
           System.assertEquals(  functionalHeadEmail	
                                , cust.Functional_Head_Email__c
                                , ''+methodName+' : Owner Id for customer is not as expected');
            
        }
    } 
}