({
	initializeNPADetails : function(component, event, helper) {
        var npaData = {};
        debugger;
        npaData.rating 		   = component.get("v.RatingValue")	   ? component.get("v.RatingValue") 	: 'defaultValue'; 
        npaData.secondCallBack = component.get("v.SecondCallback") ? component.get("v.SecondCallback") 	: 'defaultValue';
        npaData.FC1_Comment    = component.get("v.FC1_Comment")	   ? component.get("v.FC1_Comment") 	: 'defaultValue';
        component.set('v.NPA_Data', npaData);
	},
    validateLoggedInUser : function(component, event, helper,recId) {
         var action = component.get("c.checkIsDefaultManagerLoggedIn");
        action.setParams({
            "parentId": recId
        });
        action.setCallback(this, function(a) {
            debugger;
            var state = a.getState();           
            if (state === "SUCCESS") {
                var status = component.get("v.status");
                    var isDefaultmanagerLoggedIn = a.getReturnValue();	
                
                if (isDefaultmanagerLoggedIn && status && status == 'Closed') {
                     component.set('v.isDefaultManagerLoggedIn', true);
                } else {
                     component.set('v.isDefaultManagerLoggedIn', false);
                }
            }            
        });
        
        $A.enqueueAction(action);
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
    
    validateStatus : function (component, event, helper) {
        debugger;
        var sucessful = 'Successful' ;
        if(component.find("FC1statusField")){
          	var fc1callStatus = component.find("FC1statusField").get("v.value");  
        }
        if(component.find("FC2statusField")){
        	var fc2callStatus = component.find("FC2statusField").get("v.value");
        }
        if(component.find("FC3statusField")){
        	var fc3callStatus = component.find("FC3statusField").get("v.value");
        }
        if (fc3callStatus && fc3callStatus == sucessful) {
        	return true;
        } else if (fc2callStatus && fc2callStatus == sucessful) {
            return true;
        } else if (fc1callStatus && fc1callStatus == sucessful) {
            return true;
        } 
	},
    
   // this function automatic call by aura:waiting event  
   showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
       
        component.set("v.Spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 	
    hideSpinner : function(component,event,helper){
      
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    
    updateNPA_data : function (component, event, helper) {
        debugger;
        var isDataChanged 		   = component.get("v.isDataChanged");
        if (isDataChanged == false) {
            var npaData 		= component.get("v.NPA_Data");
            debugger;
            var isDataChanged 	= false;
            var rating 		   	= component.get("v.RatingValue"); 
            var secondCallBack 	= component.get("v.SecondCallback"); 
            var FC1_Comment    	= component.get("v.FC1_Comment"); 
            
            if ( rating != npaData.rating ) {
                isDataChanged = true;
                component.set('v.isRatingChanged', true);
            }
            
            if ( secondCallBack != npaData.secondCallBack ) {
                isDataChanged = true;
            }
            
            if ( rating != npaData.FC1_Comment ) {
                isDataChanged = true;
            }    
            
            component.set('v.isDataChanged', isDataChanged);
        }            
    }
})