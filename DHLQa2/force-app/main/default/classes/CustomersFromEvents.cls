public class CustomersFromEvents implements Database.Batchable<sObject>,Schedulable{
    
    public final Decimal recordsOfPastNdays = [SELECT LAST_N_DAYS__c FROM NPA_Batch_Chunk_Size__mdt 
                                     	WHERE Batch_Name__c = 'CustomersFromEvents'][0].LAST_N_DAYS__c;
    
    public final String query = 'SELECT OwnerId,Owner.Name,Subject,CreatedDate,ActivityDate,'+
    'Type,DHL_Event_Completed_Date__c,WhatId,WhoId,Who.type,What.type,Account.Name,AccountId,Account.DHL_Key_Account__c '+
    'FROM Event WHERE DHL_Meeting_Type__c = \'Sales\' AND Submitted_For_NPA__c = false '+
    'AND DHL_Event_Completed_Date__c = LAST_N_DAYS:' + String.valueOf(recordsOfPastNdays.intValue()); //  
    
    public final Id rtIdOfSales = Schema.SObjectType.Customer__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Event> scope){
        
        List<Customer__c> lstCustomers = new List<Customer__c>();
        
        List<Id> accIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> contIds = new List<Id>();
        List<Id> leadIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        
        for(Event objEvent : scope){
            
            userIds.add(objEvent.OwnerId);
            
            if(objEvent.Who.type == 'Contact'){
                contIds.add(objEvent.WhoId);  
            }else if(objEvent.Who.type == 'Lead'){
                leadIds.add(objEvent.WhoId);  
            }
            
            if(objEvent.What.type == 'Account'){
                accIds.add(objEvent.WhatId);  
            }else if(objEvent.What.type == 'Opportunity'){
                oppIds.add(objEvent.WhatId);  
            }
            
            if(objEvent.AccountId != null){
                accIds.add(objEvent.AccountId);  
            }
        
        }
        
        //Get Zone from user 20 April 2020
        Map<Id,String> mapUserAndZone = new Map<Id,String>();
        Map<Id,String> mapUserAndUserRole = new Map<Id,String>(); 
        Map<Id,Contact> mapContacts = new Map<Id,Contact>();
        Map<Id,Lead> mapLeads = new Map<Id,Lead>();
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        Map<Id,Opportunity> mapOpportunities = new Map<Id,Opportunity>();
        //Get Zone from user 20 April 2020
        for(User objUser : [SELECT Id,UserRole.Name,DHL_Zone__c FROM User WHERE Id IN :userIds]){
            mapUserAndUserRole.put(objUser.Id,objUser.UserRole.Name);
            mapUserAndZone.put(objUser.Id,objUser.DHL_Zone__c);
        }
        
        for(Contact objCont : [SELECT Name,MobilePhone,Email FROM Contact WHERE Id In :contIds]){
            mapContacts.put(objCont.Id,objCont);
        }
        
        for(Lead objLead : [SELECT Name,MobilePhone,Email FROM Lead WHERE Id In :leadIds]){
            mapLeads.put(objLead.Id,objLead);
        }
        
        for(Account objAccount : [SELECT Name FROM Account WHERE Id In :accIds]){
            mapAccounts.put(objAccount.Id,objAccount);
        }
        
        for(Opportunity objOpp : [SELECT Name FROM Opportunity WHERE Id In :oppIds]){
            mapOpportunities.put(objOpp.Id,objOpp);
        }
        
        List<Event> lstEvents = new List<Event>();
        
        for(Event objEvent : scope){
            
            Customer__c objCust = new Customer__c();
            
            if(objEvent.WhatId != null){
                //Commented as per issue SB-269
                // if(objEvent.What.type == 'Account'){
                //     objCust.Account_Name__c = mapAccounts.get(objEvent.WhatId).Name;
                // }else 
                if(objEvent.What.type == 'Opportunity'){
                    objCust.Opportunity_Name__c = mapOpportunities.get(objEvent.WhatId).Name;
                    //Commented as per issue SB-269
                    //objCust.Account_Name__c = objEvent.Account.Name;
                }
            }
            
            if(objEvent.WhoId != null){
                if(objEvent.Who.type == 'Contact'){
                    objCust.Contact_Name__c = mapContacts.get(objEvent.WhoId).Name;
                    objCust.Contact_Mobile__c = mapContacts.get(objEvent.WhoId).MobilePhone;
                    objCust.Contact_Email__c = mapContacts.get(objEvent.WhoId).Email;
                }else if(objEvent.Who.type == 'Lead'){
                    objCust.Lead_Name__c = mapLeads.get(objEvent.WhoId).Name;
                    objCust.Contact_Mobile__c = mapLeads.get(objEvent.WhoId).MobilePhone;
                    objCust.Contact_Email__c = mapLeads.get(objEvent.WhoId).Email;
                    objCust.Lead_Id__c = objEvent.WhoId;
                } 
            }
            
            objCust.Event_Assigned_Role__c = mapUserAndUserRole.get(objEvent.OwnerId);
            //Get Zone from user 20 April 2020
            objCust.Region__c = mapUserAndZone.get(objEvent.OwnerId);
            objCust.Event_Assigned_To__c = objEvent.Owner.Name;
            objCust.Event_Created_Date__c = objEvent.CreatedDate;
            objCust.Subject__c = objEvent.Subject;
            objCust.Activity_Type__c = objEvent.Type;
            objCust.Activity_Date__c = objEvent.ActivityDate;
            objCust.Event_Completed_Date__c = objEvent.DHL_Event_Completed_Date__c;
            objCust.Account_Id__c = objEvent.AccountId;
            //Added this if block for ticket SB-269
            if(objEvent.AccountId != null){
                objCust.Customer_Name__c = objEvent.Account.Name;
                // Added mapping for Key Account Checkbox 22 April 2020 
                objCust.Is_Key_Account__c = objEvent.Account.DHL_Key_Account__c;
            }
            objCust.RecordTypeId = rtIdOfSales;
            
            lstCustomers.add(objCust);
            
            objEvent.Submitted_For_NPA__c = true;
            lstEvents.add(objEvent);
        }
        Database.insert(lstCustomers,false);
        Database.update (lstEvents,false);
    }

    public void finish(Database.BatchableContext BC){
        
    }
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new CustomersFromEvents());
    }
}