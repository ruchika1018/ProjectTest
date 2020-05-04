@isTest
private class CustomersFromCasesTest {

	private static testMethod void testBatch() {
        
        final Id rtIdOfCeCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CE Case').getRecordTypeId();
        System.debug('rtIdOfCeCase===>'+rtIdOfCeCase);
        
        Account objAccount = DHLTestFactory.createAccount('Test Account','test@test.com');
        objAccount.DHL_EKP__c = '0000';
        insert objAccount;
        
        Contact objContact = DHLTestFactory.createContact('Test Contact','test@test.com');
        objContact.MobilePhone = '1234567890';
        insert objContact;
        
        List<Case> lstTestCases = new List<Case>();
        for(Integer count = 1; count<=10; count++){
            Case objCase = DHLTestFactory.createCase(objContact.Id, 'Complaint','Problem', 'Complaint', 'Closed', 'Test Description');
            
            objCase.AccountId = objAccount.Id;
            
            objCase.DHL_CE_Case_Reason__c = 'Customer Issue';
            objCase.DHL_CE_Case_Sub_type__c = 'Complaint';
            objCase.DHL_Company_Name__c = 'Test Company';
            //objCase.Contact.Name // comes from contact
            objCase.DHL_CE_Subject__c = 'Test CE Subject';
            //objCase.Owner.Name //comes from Owner
            objCase.DHL_CE_Origin__c = 'Noida';
            objCase.DHL_CE_Customer_Ref_No__c = '00000000000000000000000001234567890';
            objCase.DHL_Stage__c = 'New';
            objCase.Subject = 'Test Subject';
            objCase.DHL_Origin__c = 'Origin';
            objCase.DHL_Origin_Hub__c = 'Pune';
            objCase.DHL_Destination__c = 'Destination';
            objCase.DHL_Destination_Hub__c = 'Ahmedabad';
            objCase.Responsible_Hub__c = 'Pune';
            objCase.DHL_Lane__c = 'Test Lane';
            objCase.DHL_Customer_Ref_Number__c = '00000000000000000000000001234567890';
            objCase.DHL_Case_Initated_By__c = 'DHL Admin';
            objCase.DHL_Who_Caused_it__c = 'DHL Admin';
            objCase.DHL_RCA__c = 'Test RCA Test RCA Test RCA Test RCA';
            objCase.RecordTypeId = rtIdOfCeCase;
            //27 April 2020 Added due to validation for CE cases and Region from T4U
            objCase.DHL_Trip_Number__c = '000000';
            objCase.DHL_T4U_Region__c = 'North';
            lstTestCases.add(objCase);
        }
	    insert lstTestCases;
	    
	    for(Case objCase : lstTestCases){
	        objCase.DHL_Stage__c = 'WIP';
	    }
	    update lstTestCases;
	    
	    for(Case objCase : lstTestCases){
	        objCase.DHL_Stage__c = 'Closed';
	    }
	    update lstTestCases;
	    
	    Test.startTest();
	    Database.executeBatch(new CustomersFromCases());
	    Test.stopTest();
	    Integer count = [SELECT count() FROM Customer__c];
	    System.assertEquals(10,count);
	}

    private static testMethod void testSchedule(){
	    
	    String sch = '0 0 1 ? * MON *';
	    Test.startTest();
	    System.schedule('Create Customers From Cases', sch, new CustomersFromCases());
	    Test.stopTest();
    }
    
}