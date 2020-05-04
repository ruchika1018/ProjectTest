@isTest
public class SecondCallerNPADetailPageControllerTest {
	static testMethod void test_getNpaRecord() {
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers('Sales', 10);
        lstsalesCust[0].Region__c = 'West';
        Insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'FC In Progress', '8');
        Insert objNps;
        String parentId = lstsalesCust[0].Id;
       Test.startTest();
            Net_Promoter_Score__c result = SecondCallerNPADetailPageController.getNpaRecord(objNps.Id);
       Test.stopTest();
       System.assertNotEquals(null, result);
    }
    
    static testMethod void test_closeNpaRecord() {
        List<Customer__c> lstsalesCust = TestDataFactory.createCustomers('Sales', 10);
        lstsalesCust[0].Region__c = 'West';
        Insert lstsalesCust;
        Net_Promoter_Score__c objNps = TestDataFactory.createNps(lstsalesCust[0].Id, 'FC In Progress', '8');
        objNps.Status__c = 'SC Reassigned';
        Insert objNps;
        
        String parentId = lstsalesCust[0].Id;
       Test.startTest();
            Boolean result = SecondCallerNPADetailPageController.closeNpaRecord(objNps.Id);
       Test.stopTest();
       System.assertEquals(true, result);
    }
}