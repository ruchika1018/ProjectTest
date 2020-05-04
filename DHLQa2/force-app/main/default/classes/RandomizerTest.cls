@isTest
private class RandomizerTest {
    static testMethod void test_getCustomersForFirstCaller() {
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers('Sales', 10);
        List<Customer__c> lstCECust = TestDataFactory.createCustomers('Customer_Excellence', 10);
        Insert lstsalesCust;
        Insert lstCECust;
        TestDataFactory.createUserTouchpointConf('Sales,Billing','John');
        TestDataFactory.createUserTouchpointConf('Customer Excellence','Jane');
		User_Touchpoint_Mapping__c objConfig = new User_Touchpoint_Mapping__c();
        List<User_Touchpoint_Mapping__c> listObjCong = new List<User_Touchpoint_Mapping__c>();
        objConfig.Caller_Name__c = 'John';
       	objConfig.Touchpoint_Name__c = 'Sales, Billing';
       	listObjCong.add(objConfig);
        insert listObjCong;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'FC In Progress', '8');
        Insert objNps;

        Test.startTest();
            Randomizer classRandomizer = new Randomizer();
            List<Randomizer.WrapperCustomers> lstWrapper = classRandomizer.getCustomerforCurrentuser();
        Test.stopTest();
       System.assertEquals(1, lstWrapper.size());
    }

    static testMethod void test_CustomerWithCallbackDate() {
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers('Sales', 10);
        List<Customer__c> lstCECust = TestDataFactory.createCustomers('Customer_Excellence', 10);
        lstsalesCust[0].Is_Shared__c = true;
        Insert lstsalesCust;
        Insert lstCECust;
		User_Touchpoint_Mapping__c objConfig = new User_Touchpoint_Mapping__c();
        List<User_Touchpoint_Mapping__c> listObjCong = new List<User_Touchpoint_Mapping__c>();
        objConfig.Caller_Name__c = 'John';
       	objConfig.Touchpoint_Name__c = 'Sales,Billing';
       	listObjCong.add(objConfig);
        
        User_Touchpoint_Mapping__c objConfig1 = new User_Touchpoint_Mapping__c();
        objConfig1.Caller_Name__c = 'Jane';
       	objConfig1.Touchpoint_Name__c = 'Sales';
       	listObjCong.add(objConfig1);
        insert listObjCong;
        
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'FC In Progress', '6');
        objNps.Fc1_Callback_Date__c = System.today();
        objNps.Fc1_Status__c = 'Successful';
        Insert objNps;

        //TestDataFactory.createUserTouchpointConf('Sales','Jane');

        Test.startTest();
            Randomizer classRandomizer = new Randomizer();
            List<Randomizer.WrapperCustomers> lstWrapper = classRandomizer.getCustomerforCurrentuser();
            //classRandomizer.getCustomersForFirstCaller('Sales,Operations','Jane');
       Test.stopTest();
       System.assertEquals(3, lstWrapper.size());
    }
    
    static testMethod void test_customersWithPreviousNpaHistory() {
        List<Customer__c> lstBillingCust = TestDataFactory.createCustomers('Billing', 10);
        lstBillingCust[0].EKP__c = '1000001';

        List<Customer__c> lstOlderCustRec = TestDataFactory.createCustomers('Billing', 1);
        lstOlderCustRec[0].EKP__c = '1000001';
        Insert lstOlderCustRec;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(lstOlderCustRec[0].Id, Datetime.now().addDays(-32));
         List<Customer__c> lstqueriedOlderCustRec = [Select Id,CreatedDate From Customer__c Where Id=:lstOlderCustRec[0].Id];
        System.debug('--->***lstOlderCustRec[0]'+lstOlderCustRec[0]);
        System.debug('--->***lstOlderCustRec[0]'+lstqueriedOlderCustRec[0].createdDate);
        
        
        List<Customer__c> lstCECust = TestDataFactory.createCustomers('Customer_Excellence', 10);
        Insert lstBillingCust;
        Insert lstCECust;
        TestDataFactory.createUserTouchpointConf('Billing','John');
        TestDataFactory.createUserTouchpointConf('Customer Excellence,Billing','Jane');
		User_Touchpoint_Mapping__c objConfig = new User_Touchpoint_Mapping__c();
        List<User_Touchpoint_Mapping__c> listObjCong = new List<User_Touchpoint_Mapping__c>();
        objConfig.Caller_Name__c = 'John';
       	objConfig.Touchpoint_Name__c = 'Billing';
       	listObjCong.add(objConfig);
        insert listObjCong;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstOlderCustRec[0].Id, 'FC In Progress', '8');
        objNps.FC2_Status__c = 'Successful';
        objNps.Fc2_Attempted_Date__c = Date.Today().addDays(-31);
        Insert objNps;

        Test.startTest();
            Randomizer classRandomizer = new Randomizer();
            List<Randomizer.WrapperCustomers> lstWrapper = classRandomizer.getCustomerforCurrentuser();
        Test.stopTest();
       System.assertEquals(1, lstWrapper.size());
    }
}