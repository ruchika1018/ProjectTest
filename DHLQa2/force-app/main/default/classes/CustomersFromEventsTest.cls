@isTest
private class CustomersFromEventsTest {

	private static testMethod void testBatch() {
        
        User objUser = DHLTestFactory.createUser('System Administrator');
        insert objUser;
        
        Account objAccount = DHLTestFactory.createAccount('Test Account','test@test.com');
        objAccount.DHL_EKP__c = '0000';
        insert objAccount;
        
        Opportunity objOpp = DHLTestFactory.createOpportunity('Test Opp', '1 First Contact/Initial Discussion', Date.today(), objAccount.Id, 
                                                Date.today(), Date.today().addDays(364), objUser.Id,
                                                'Competitive Rates', '0000',  'Other');
        insert objOpp;
        
        Contact objContact = DHLTestFactory.createContact('Test Contact','test@test.com');
        objContact.MobilePhone = '1234567890';
        insert objContact;
	    
        Lead objLead = DHLTestFactory.createLead('Executive', 'Test Lead', 'Test Company', 'DRY', 'Industrial Products',
                                  'Email', 'Goa', '1 Open Not Contacted', 'test@test.com');
	    
        insert objLead;
        
        List<Event> lstEvents = new List<Event>();
        
        Event objEvent1 = DHLTestFactory.createEvent('Email', objUser.Id, objLead.Id, null, 'Completed', 'Sales', 
                                    DateTime.now() , DateTime.now().addHours(2));
        objEvent1.DHL_Event_Completed_Date__c = Date.today();
        lstEvents.add(objEvent1);                          
        
        Event objEvent2 = DHLTestFactory.createEvent('Email', objUser.Id, objContact.Id, objAccount.Id, 'Completed', 'Sales', 
                                    DateTime.now() , DateTime.now().addHours(2));
        objEvent2.DHL_Event_Completed_Date__c = Date.today();
        lstEvents.add(objEvent2);
        
        Event objEvent3 = DHLTestFactory.createEvent('Email', objUser.Id, objContact.Id, objOpp.Id, 'Completed', 'Sales', 
                                    DateTime.now() , DateTime.now().addHours(2));
        objEvent3.DHL_Event_Completed_Date__c = Date.today();
        //objEvent3.AccountId = objAccount.Id;
        lstEvents.add(objEvent3);
        
        insert lstEvents;
        
        Test.startTest();
	    Database.executeBatch(new CustomersFromEvents());
	    Test.stopTest();
	    
	    Integer count = [SELECT count() FROM Customer__c];
	    System.assertEquals(3,count);
	}
	
	private static testMethod void testSchedule(){
	    
	    String sch = '0 0 1 ? * MON *';
	    Test.startTest();
	    System.schedule('Create Customers From Events', sch, new CustomersFromEvents());
	    Test.stopTest();
    }

}