public class CustomersFromCases implements Database.Batchable<sObject>,Schedulable{
    
    public final Decimal recordsOfPastNdays = [SELECT LAST_N_DAYS__c FROM NPA_Batch_Chunk_Size__mdt 
                                     	WHERE Batch_Name__c = 'CustomersFromCases'][0].LAST_N_DAYS__c;
    
    public final Id rtIdOfCeCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.DHL_CE_case_record_type).getRecordTypeId();
    
    public final String query = 'SELECT CaseNumber,DHL_CE_Case_Reason__c,'+
    'DHL_Case_SubType__c,Account.DHL_EKP__c,DHL_Vehicle_Number__c,Account.Name,Account.DHL_Key_Account__c,DHL_T4U_Region__c,'+
    'DHL_Company_Name__c,DHL_CE_Subject__c,ContactEmail,ContactMobile,'+
    'Owner.Name,DHL_CE_Origin__c,DHL_CE_Customer_Ref_No__c,DHL_Stage__c,CreatedDate,'+
    'ClosedDate,Contact.Name,AccountId FROM Case WHERE RecordTypeId = :rtIdOfCeCase '+
    'AND DHL_Stage__c = \'Closed\' AND Submitted_For_NPA__c = false AND DHL_T4U_Region__c != null '+ 
    'AND ClosedDate = LAST_N_DAYS:'+ String.valueOf(recordsOfPastNdays.intValue());   
    
    public final Id rtIdOfCe = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Customer Excellence').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope){
        
        System.debug('Cases--->'+scope);
        List<Customer__c> lstCustomers = new List<Customer__c>();
        List<Case> lstCases = new List<Case>();
        
        for(Case objCase : scope){
            Customer__c objCust = new Customer__c();
            objCust.Case_Number__c = objCase.CaseNumber;
            objCust.Case_Reason__c = objCase.DHL_CE_Case_Reason__c;
            objCust.Case_Sub_Type__c = objCase.DHL_Case_SubType__c;
            objCust.EKP__c = objCase.Account.DHL_EKP__c;
            ///Commented as per issue SB-269
            //objCust.Company_Name__c = objCase.DHL_Company_Name__c;
            objCust.Contact_Name__c = objCase.Contact.Name;
            objCust.Subject__c = objCase.DHL_CE_Subject__c;
            objCust.Contact_Email__c = objCase.ContactEmail;
            objCust.Contact_Mobile__c = objCase.ContactMobile;
            objCust.Case_Owner__c = objCase.Owner.Name;
            objCust.Case_Origin__c = objCase.DHL_CE_Origin__c;
            objCust.Customer_Ref_Number__c = objCase.DHL_CE_Customer_Ref_No__c;
            objCust.Stage__c = objCase.DHL_Stage__c;
            objCust.Date_Time_Opened__c = objCase.CreatedDate;
            objCust.Date_Time_Closed__c = objCase.ClosedDate;
            objCust.Account_Id__c = objCase.AccountId;
            objCust.RecordTypeId = rtIdOfCe;
            lstCustomers.add(objCust);
            
            //Added as per ticket SB-269
            objCust.Customer_Name__c = objCase.DHL_Company_Name__c;
            // Added mapping for Region and Key Account Checkbox 22 April 2020
            objCust.Region__c = objCase.DHL_T4U_Region__c;
            objCust.Is_Key_Account__c = objCase.Account.DHL_Key_Account__c;
            objCase.Submitted_For_NPA__c = true;
            lstCases.add(objCase);
        }
        Database.insert(lstCustomers,false);
        Database.update (lstCases,false);
    }

    public void finish(Database.BatchableContext BC){
    
    }
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CustomersFromCases());
    }
}