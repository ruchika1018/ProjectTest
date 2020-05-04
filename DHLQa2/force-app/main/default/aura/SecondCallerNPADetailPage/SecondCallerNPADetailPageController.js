({
	doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        console.log('-->',recId);
        var action = component.get("c.getCustomerDetails");
             
        action.setParams({
            "recordId": recId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('-->state',state);
            component.set("v.isDataChanged", false);
            debugger;
            if (component.isValid() && state === "SUCCESS"){
                if (response.getReturnValue() != null){
                    
                  var responseWrapper = {};
               	  responseWrapper = JSON.parse(response.getReturnValue());  
                    
                  helper.setNPAData(component, event, helper, responseWrapper.nps); 
                  helper.renderSendEmailButton(component, event, helper, responseWrapper); 
                  
                } else{
                   component.set('v.ParentId', null);
                }               
            }            
        }); 
        
        $A.enqueueAction(action);
    },
    
	validateNPAdetails : function(component, event, helper) {
        var isDataChanged= component.get("v.isDataChanged");
        if (isDataChanged) {
            var response = confirm('Warning! Your data is not saved. You may loose data! Are you sure you want to redirect?');
            if (response) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                      "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Second_Caller_List"
                });
                urlEvent.fire(); 
            }
        } else {
            console.log('In else');
          	var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Second_Caller_List"
                });
                urlEvent.fire(); 
        } 
    },
    
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams();
        console.log('====>',JSON.stringify(payload));
        component.set('v.isSaved', true);
        component.set("v.isDataChanged", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                        "type": "Success",
                        "title": "Success",
                        "message": "Saved successfully"
                    });
        toastEvent.fire();
    },
    
    handleError : function(component, event, helper) {
        var payload = event.getParams();
        console.log('====>',JSON.stringify(payload));
        //component.set('v.isSaved', true);
        //component.set("v.isDataChanged", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                        "type": "Error",
                        "title": "Error",
                        "message": "Something went wrong changes are not saved"
                    });
        toastEvent.fire();
    },
    
    openModel : function(component, event, helper) {
        var isSaved = component.get("v.isSaved");
        var sc1 = component.get("v.sc1Sec");
        var sc2 = component.get("v.sc2Sec");
        var sc3 = component.get("v.sc3Sec");
        if(isSaved || (sc1 && sc2 && sc3)){
          component.set("v.isOpen", true);  
        }else{
           alert("Please save the changes before Re-assigning"); 
        }
        
	},
    
    onStatusChange : function(component, event, helper) {
		//helper.renderDisplayRscSection(component, event, helper);
        var statusVal;
        var cmpVal = component.find("NpaStatus");
        if(cmpVal != undefined){
            statusVal = component.find("NpaStatus").get("v.value");
        } else{
            statusVal = component.find("NpaStatus2").get("v.value");
        }
        
        console.log('==>statusVal',statusVal);
        if(statusVal == "SC Reassigned"){
           component.set("v.DisplayRscSection", true); 
        }else{
           component.set("v.DisplayRscSection", false); 
        }
       
	},
    
    validateValueChange : function(component, event, helper) {
		component.set("v.isDataChanged", true); 
        console.log('---->>validateValueChange',component.get("v.isDataChanged"));
    },
    
    handleComponentEvent : function(component, event, helper) {
        var isChanged =event.getParam("valueChanged");// getting the value of event attribute
        console.log('name:::'+JSON.stringify(isChanged));
        component.set("v.DisplayRscSection",isChanged); // Setting the value of parent attribute with event attribute value
    },
    
    closeNpa : function(component, event, helper) {
        var recId = component.get("v.recordId");
        console.log('-->',recId);
        var action = component.get("c.closeNpaRecord");
             
        action.setParams({
            "recordId": recId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('-->state',state);
            if (component.isValid() && state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
        		if(response.getReturnValue()){
                   toastEvent.setParams({
                        "type": "Success",
                        "title": "Success",
                        "message": "Closed successfully"
                    });
                            
                }else{
                   toastEvent.setParams({
                        "type": "Error",
                        "title": "Error",
                        "message": "Something went wrong please try again"
                    });
                }
                console.log('===>',response.getReturnValue());
                toastEvent.fire();
            }
            
        });
        
        $A.enqueueAction(action);
    },
     renderSc1CallBackDate : function(component, event, helper) {
       var sc1StatusId = component.find("sc1StatusId");
       component.set("v.sc1callBackdateValidationError" , false);
        if(sc1StatusId != undefined){
        	var sc1Status = component.find("sc1StatusId").get("v.value");
            if (sc1Status != '' && sc1Status == 'Asked to callback') {
               component.set("v.sc1StatusHasValue", true);  
            } else {
               component.set("v.sc1StatusHasValue", false); 
            }
        }
    },
    renderSc2CallBackDate : function(component, event, helper) {
       var sc2StatusId = component.find("sc2StatusId");
        component.set("v.sc2callBackdateValidationError" , false);
        if(sc2StatusId != undefined){
        	var sc2Status = component.find("sc2StatusId").get("v.value");
            if (sc2Status != '' && sc2Status == 'Asked to callback') {
               component.set("v.sc2StatusHasValue", true);  
            } else {
               component.set("v.sc2StatusHasValue", false); 
            }
        }
        
      component.set("v.isDataChanged", true); 
    },
    
    renderSc3CallBackDate : function(component, event, helper) {
       var sc3StatusId = component.find("sc3StatusId");
        component.set("v.sc3callBackdateValidationError" , false);
        if(sc3StatusId != undefined){
        	var sc3Status = component.find("sc3StatusId").get("v.value");
            if (sc3Status != '' && sc3Status == 'Asked to callback') {
               component.set("v.sc3StatusHasValue", true);  
            } else {
               component.set("v.sc3StatusHasValue", false); 
            }
        }
        
       component.set("v.isDataChanged", true); 
    },
    renderRsc1CallBackDate : function(component, event, helper) {
       var rsc1StatusId = component.find("rsc1StatusId");
        component.set("v.rsc1callBackdateValidationError" , false);
        if(rsc1StatusId != undefined){
        	var rsc1Status = component.find("rsc1StatusId").get("v.value");
            if (rsc1Status != '' && rsc1Status == 'Asked to callback') {
               component.set("v.rsc1StatusHasValue", true);  
            } else {
               component.set("v.rsc1StatusHasValue", false); 
            }
        }
        component.set("v.isDataChanged", true); 
    },
    
    renderRsc2CallBackDate : function(component, event, helper) {
       var rsc2StatusId = component.find("rsc2StatusId");
        component.set("v.rsc2callBackdateValidationError" , false);
        if(rsc2StatusId != undefined){
        	var rsc2Status = component.find("rsc2StatusId").get("v.value");
            if (rsc2Status != '' && rsc2Status == 'Asked to callback') {
               component.set("v.rsc2StatusHasValue", true);  
            } else {
               component.set("v.rsc2StatusHasValue", false); 
            }
        }
        
      component.set("v.isDataChanged", true); 
    },
    
    renderRsc3CallBackDate : function(component, event, helper) {
       var rsc3StatusId = component.find("rsc3StatusId");
        component.set("v.rsc3callBackdateValidationError" , false);
        if(rsc3StatusId != undefined){
        	var rsc3Status = component.find("rsc3StatusId").get("v.value");
            if (rsc3Status != '' && rsc3Status == 'Asked to callback') {
               component.set("v.rsc3StatusHasValue", true);  
            } else {
               component.set("v.rsc3StatusHasValue", false); 
            }
        }
        component.set("v.isDataChanged", true); 
    },
    
    openEmailTemplate : function(component, event, helper) {
        component.set("v.isEmailTemplateOpen", true); 
	},
    
    handleSubmit: function(component, event, helper) {
        var sc1callBackdateValidationError = component.get("v.sc1callBackdateValidationError");
        var sc2callBackdateValidationError = component.get("v.sc2callBackdateValidationError");
        var sc3callBackdateValidationError = component.get("v.sc3callBackdateValidationError");
        var rsc1callBackdateValidationError = component.get("v.rsc1callBackdateValidationError");
        var rsc2callBackdateValidationError = component.get("v.rsc2callBackdateValidationError");
        var rsc3callBackdateValidationError = component.get("v.rsc3callBackdateValidationError");
        
        debugger;
        var fields 		= event.getParam('fields');
       	 if (fields.Sc1_Status__c != 'Asked to callback') {
            	fields.Sc1_Callback_Date__c = null; 
         }
        
         if (fields.Sc2_Status__c != 'Asked to callback') {
            	fields.Sc2_Callback_Date__c = null; 
         }
        
        if (fields.Sc3_Status__c != 'Asked to callback') {
            	fields.Sc3_Callback_Date__c = null; 
         }
        
         if (fields.Rsc1_Status__c != 'Asked to callback') {
            	fields.Rsc1_Callback_Date__c = null; 
         }
        
         if (fields.Rsc2_Status__c != 'Asked to callback') {
            	fields.Rsc2_Callback_Date__c = null; 
         }
        
        if (fields.Rsc3_Status__c != 'Asked to callback') {
            	fields.Rsc3_Callback_Date__c = null; 
         }
         //Validate call back start
        if (			
               
               sc1callBackdateValidationError 
            || sc2callBackdateValidationError 
            || sc3callBackdateValidationError
            || rsc1callBackdateValidationError 
            || rsc2callBackdateValidationError 
            || rsc3callBackdateValidationError
        ) {
                    event.preventDefault();       // stop the form from submitting
                    var displayMsg = 'Data not saved! Please enter valid data in the call back date';           
                    helper.showToastMessage(component, event, helper, 'Error', 'Error', displayMsg);
        } 
        //Validate call back end
        
        
    },
    
    	validatesc1Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("SC1cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.sc1callBackdateValidationError" , response);
    	},
    	
    	validatesc2Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("SC2cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.sc2callBackdateValidationError" , response);
    	},
    
    	validatesc3Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("SC3cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.sc3callBackdateValidationError" , response);
    	},
    	
    	validateRsc1Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("Rsc1cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.rsc1callBackdateValidationError" , response);
    	},
    	
    	validateRsc2Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("Rsc2cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.rsc2callBackdateValidationError" , response);
    	},
    
    	validateRsc3Date : function(component, event, helper) {
            var fc1CallbackDate = component.find("Rsc3cbField").get("v.value");
            var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
            component.set("v.rsc3callBackdateValidationError" , response);
    	},
})