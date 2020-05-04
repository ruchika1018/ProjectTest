({
	renderDisplayRscSection : function(component, event, helper) {
		var statusVal = component.find("NpaStatus").get("v.value");
        console.log('==>statusVal',statusVal);
        if(statusVal == "SC Reassigned"){
           component.set("v.DisplayRscSection", true); 
        }else{
           component.set("v.DisplayRscSection", false); 
        }
        
	},
    
    renderSendEmailButton : function(component, event, helper, responseWrapper) {
		 // Hide/Show Send email button based on email value
        var email = responseWrapper.nps.Customer__r.Contact_Email__c;        
        if (email != null && email != undefined && email != '' ) {
            component.set('v.customerEmailHasValue', true);
            component.set('v.customerEmail', email);   
            if (	responseWrapper.isNPA_AnalystLoggedIn != null 
                 && responseWrapper.isNPA_AnalystLoggedIn != undefined
                 && responseWrapper.isNPA_AnalystLoggedIn == true
            ) {
                 component.set('v.renderSendEmailButton', true);                 
            } else {
                component.set('v.renderSendEmailButton', false); 
            }
        }      
	},
    
    setNPAData : function(component, event, helper, nps) {
		
        component.set('v.ParentId',nps.Customer__c);
        component.set('v.CustName', nps.Account_Name__c);
        debugger;   
        if (nps.Status__c=='Closed') {
             component.set('v.renderReassignOwner', false);
        }
        
        if (nps.Reassign_Comments_1__c != undefined) {
            component.set('v.isReassignCom1',false);
        }
        if (nps.Reassign_Comments_2__c != undefined) {
            component.set('v.isReassignCom2',false);
        }
        if (nps.Reassign_Comments_3__c != undefined) {
            component.set('v.isReassignCom3',false);
        }
        if (nps.Reassign_Comments_4__c != undefined) {
            component.set('v.isReassignCom4',false);
        }
        if (nps.Reassign_Comments_5__c != undefined) {
            component.set('v.isReassignCom5',false);
        }
       if(nps.Is_SC_Reassigned__c){
            component.set("v.DisplayRscSection", true);
            if (nps.Rsc1_Comments__c != null){
                component.set("v.rsc1Sec", true);
                if(nps.Rsc1_Status__c == "Asked to callback"){
                    component.set("v.isRsc1cb", true);
                }
            }
            
            if(nps.Rsc2_Comments__c != null){
                component.set("v.rsc2Sec", true);
                if(nps.Rsc2_Status__c == "Asked to callback"){
                    component.set("v.isRsc2cb", true);
                }
            }
            
            if(nps.Rsc3_Comments__c != null){
                component.set("v.rsc3Sec", true);
                if(nps.Rsc3_Status__c == "Asked to callback"){
                    component.set("v.isRsc3cb", true);
                }
            }
            debugger;
            if(nps.Status__c == "Closed"){
                component.set("v.rsc1Sec", true);
                component.set("v.rsc2Sec", true);
                component.set("v.rsc3Sec", true);               
            }
           debugger;
            if (nps.Status__c == "Closed" || nps.Status__c == "SC Pending") {
                 component.set("v.hideSave", false);
            }
        }else{
            component.set("v.DisplayRscSection", false);
            if(nps.Sc1_Comments__c != null){
                component.set("v.sc1Sec", true);
                if(nps.Sc1_Status__c == "Asked to callback"){
                    component.set("v.isSc1cb", true);
                }
            }
            
            if(nps.Sc2_Comments__c != null){
                component.set("v.sc2Sec", true);
                if(nps.Sc2_Status__c == "Asked to callback"){
                    component.set("v.isSc2cb", true);
                }
            }
            
            if(nps.Sc3_Comments__c != null){
                component.set("v.sc3Sec", true);
                if(nps.Sc3_Status__c == "Asked to callback"){
                    component.set("v.isSc3cb", true);
                }
            }
            debugger;
            if(nps.Status__c == "Closed") {
                component.set("v.sc1Sec", true);
                component.set("v.sc2Sec", true);
                component.set("v.sc3Sec", true);
            }
            debugger;
            if (nps.Status__c == "Closed" || nps.Status__c == "SC Pending") {
                 component.set("v.hideSave", false);
            }
        }
	},
    
    showToastMessage : function(component, event, helper,type,title,message) {
         var toastEvent = $A.get("e.force:showToast");
         toastEvent.setParams({
                        "type"		: type,
                        "title"		: title,
                        "message"	: message
                    });
        toastEvent.fire();
    },
    
    /*call dateUpdate function on onchange event on date field*/ 
     dateUpdate : function(component, event, helper,dateValue) {
       	debugger;
        var today 		= new Date();        
        var dd 			= today.getDate();
        var mm 			= today.getMonth() + 1; //January is 0!
        var yyyy 		= today.getFullYear();
        var todayhours 	= today.getHours() 
        var todayTime   = today.getMinutes();
     // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
    // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
     	}
        
     var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        
     //RECEIVED DATE FORMAT
             var receivedDate 		= new Date(dateValue).toLocaleString();
             var datevalueFormated 	= new Date(receivedDate);
             var received_dd 		= datevalueFormated.getDate();
             var received_mm 		= datevalueFormated.getMonth() + 1; //January is 0!
             var received_yyyy 		= datevalueFormated.getFullYear();
             var receivedDateHours 	= datevalueFormated.getHours();
             var receivedDateTime  	= datevalueFormated.getMinutes();
                
            // if date is less then 10, then append 0 before date   
                if(received_dd < 10){
                    received_dd = '0' + received_dd;
                } 
            // if month is less then 10, then append 0 before date    
                if(received_mm < 10){
                    received_mm = '0' + received_mm;
                }
        
     var receivedFormattedDate = received_yyyy+'-'+received_mm+'-'+received_dd; 
        if(dateValue != '' && dateValue < todayFormattedDate){
            return true;
        } else if (dateValue != '' && receivedFormattedDate == todayFormattedDate ){
            
            debugger;
            if (  receivedDateHours <= todayhours && receivedDateTime < todayTime) {
                return true;
            } else {
               return false;
            }     
        } else {
           return false;
        }
    }
})