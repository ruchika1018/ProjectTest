({
    doInit : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        
        var cmpTarget = component.find('alertMessage');
        $A.util.addClass(cmpTarget, 'hideMsg');
        var recId = component.get("v.ParentId");
        console.log('-->',recId);
        debugger;
        var action = component.get("c.getNpa");
        
        action.setParams({
            "parentId": recId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('-->state',state);
            if (component.isValid() && state === "SUCCESS"){
                debugger;
                if(response.getReturnValue() != null){
                    component.set('v.NpaRecId', response.getReturnValue().Id);
                    console.log('%%%%%%',response.getReturnValue().Id);
                    var msc = response.getReturnValue().Make_Second_Call__c;

                    var status = response.getReturnValue().Status__c;
                    var secondcall= response.getReturnValue().Make_Second_Call__c
                    if (secondcall) {
                         component.set('v.SecondCallback', ''+response.getReturnValue().Make_Second_Call__c);  
                    } else {
                         component.set('v.SecondCallback', undefined);  
                    }
                    debugger;
                                    
                    component.set('v.RatingValue'	, response.getReturnValue().NPA_Rating__c);                    
                    component.set('v.status'		, response.getReturnValue().Status__c);
                	
                    if(response.getReturnValue().Fc1_Comments__c != null){
                            component.set("v.fc1Sec", true);
                            if(response.getReturnValue().Fc1_Status__c == "Asked to callback"){
                                component.set("v.isFc1cb", true);
                            }
                     }
                    
                    if(response.getReturnValue().Fc2_Comments__c != null){
                        component.set("v.fc2Sec", true);
                        if(response.getReturnValue().Fc2_Status__c == "Asked to callback"){
                            component.set("v.isFc2cb", true);
                        }
                     }
                        
                    if(response.getReturnValue().Fc3_Comments__c != null){
                        component.set("v.fc3Sec", true);
                        if(response.getReturnValue().Fc3_Status__c == "Asked to callback"){
                            component.set("v.isFc3cb", true);
                        }
                     }
                        
                        if(response.getReturnValue().Status__c == "Closed" ||
                           response.getReturnValue().Status__c == "SC Assigned" ||
                           response.getReturnValue().Status__c == "FC Pending"){
                            component.set("v.fc1Sec", true);
                            component.set("v.fc2Sec", true);
                            component.set("v.fc3Sec", true);
                            component.set("v.displaySave", false);
                            component.set("v.disableRatings", true);
                        }
                
                
                
                }else{
                   component.set('v.NpaRecId', null);
                }
                console.log('===>',response.getReturnValue());
            }
            helper.hideSpinner(component, event, helper);

        });
        
        $A.enqueueAction(action);
        
        helper.initializeNPADetails(component, event, helper);
        helper.validateLoggedInUser(component,event,helper,recId);
       // helper.hideSpinner(component, event, helper);
	},
    
    openModel :  function(component, event, helper) {             
            component.set('v.isOpen', true);
    },
    
	validateNPAdetails : function(component, event, helper) {
        var isDataChanged= component.get("v.isDataChanged");
        if (isDataChanged) {
            var response = confirm('Warning! Your data is not saved. You may loose data! Are you sure you want to redirect?');
            if (response) {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Customer_List"
                });
                urlEvent.fire(); 
            }
        } else {
            console.log('In else');
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Customer_List"
            });
            urlEvent.fire(); 
        } 
    },
    
    redirectToCustomerList : function(component, event, helper) {
          var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/Customer_List"
                });
                urlEvent.fire();
    },
    
    saveNPAdetails : function(component, event, helper) {
        debugger;
        
        var npaScore 	= component.get("v.RatingValue");
        var secCallback = component.get("v.SecondCallback");
        var parentId 	= component.get("v.ParentId");
        var fc1Comments = component.get("v.FC1_Comment");
        var fc1usStatus = component.get("v.fc1unsStatus");
        var fc1CbDate 	= component.get("v.fc1CbDate");
       
        var objNpa = {}; 
        if (secCallback) {
            objNpa.secCallback = true; 
        } else {
            objNpa.secCallback = false;  
        }
        
        var action = component.get("c.save");
        action.setParams({
            "rating": npaScore,
            "parentId": parentId,
            "secCallback": objNpa.secCallback,
            "fc1Comment": fc1Comments
            //,"fc1usStatus": fc1usStatus,
            //"fc1CbDate": fc1CbDate,
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
           
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.message', response.getReturnValue());
                component.set('v.RatingValue', '0');
                component.set('v.SecondCallback', '');
                component.set('v.FC1_Comment', '');
                var cmpTarget = component.find('alertMessage');
                $A.util.removeClass(cmpTarget, 'hideMsg');
				$A.util.addClass(cmpTarget, 'displayMsg');
                
                component.set('v.isDataChanged', false);
                component.set('fc1callBackdateValidationError', false); 
         		component.set('fc2callBackdateValidationError', false); 
                component.set('fc3callBackdateValidationError', false);
                helper.hideSpinner(component, event, helper);

         	}            
        });
        $A.enqueueAction(action);
        
    },
    
    setNPA_data : function (component, event, helper) {
        debugger;
        helper.updateNPA_data(component, event, helper);
        /*var isDataChanged 		   = component.get("v.isDataChanged");
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
        } */           
    },
    
    // common reusable function for toggle sections
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
    
    handleSubmit: function(component, event, helper) {
        //helper.showSpinner(component, event, helper);
         var typeError 	 = 'Error';
		//Get rating value 
        var rating = component.get("v.RatingValue"); 
		var fc1Read = component.get("v.fc1Sec");
		var fc2Read = component.get("v.fc2Sec");
		var fc3Read = component.get("v.fc3Sec");
        var fc1callStatus = '';
        var fc2callStatus = '';
        var fc3callStatus = '';
        debugger;
		if(component.find("FC1statusField")){
          	fc1callStatus = component.find("FC1statusField").get("v.value");  
        }
        if(component.find("FC2statusField")){
        	fc2callStatus = component.find("FC2statusField").get("v.value");
        }
        if(component.find("FC3statusField")){           
        	fc3callStatus = component.find("FC3statusField").get("v.value");  
        }
        
		var npaData 		= component.get("v.NPA_Data");
        if ( rating != undefined && rating != "" && rating != npaData.rating ) {
        	var isRatingChanged = true; 
        }        
        
        //========================================================================================
        //Validate call back start
        
        
        //validateStatus
        var fc1callBackdateValidationError = component.get("v.fc1callBackdateValidationError");
        var fc2callBackdateValidationError = component.get("v.fc2callBackdateValidationError");
        var fc3callBackdateValidationError = component.get("v.fc3callBackdateValidationError");  
        debugger;
        
        //Get Make Second call value 
        var secondCallback = component.get("v.SecondCallback");
        var isStatusSuccessful = helper.validateStatus(component, event, helper); 
         debugger;
        if (	
             	fc1callBackdateValidationError 
             || fc2callBackdateValidationError 
             || fc3callBackdateValidationError
        ) {
            event.preventDefault();       // stop the form from submitting
            var displayMsg = 'Data not saved! Please enter valid data in the call back date';           
            helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);
        } 
        //Validate call back end
        //========================================================================================
       
        else if ((rating == undefined || rating == null) && isStatusSuccessful) {
            event.preventDefault();     
            var displayMsg = 'Rating value is blank'; 
            helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);          
        }  /*else if ((secondCallback == undefined || secondCallback == null) && isStatusSuccessful) {
             event.preventDefault();  
             var displayMsg = 'Make second call back value is blank'; 
             helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);
        } */else if(isRatingChanged && !fc1Read && fc1callStatus && fc1callStatus != "Successful"){
            event.preventDefault();
            var displayMsg = '1st Attempt Status should be Successful';
            helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);
        }else if(isRatingChanged && !fc2Read && fc2callStatus && fc2callStatus != "Successful"){
            event.preventDefault();
            var displayMsg = '2nd Attempt Status should be Successful';
            helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);
        }else if(isRatingChanged && !fc3Read && fc3callStatus && fc3callStatus != "Successful"){
            event.preventDefault();
            var displayMsg = '3rd Attempt Status should be Successful'; 
            helper.showToastMessage(component, event, helper, typeError, typeError, displayMsg);
        } else {
			helper.showSpinner(component, event, helper);
            event.preventDefault();
            var fields 		= event.getParam('fields');
            var npaScore 	= component.get("v.RatingValue");
        	var parentId 	= component.get("v.ParentId");
        	var secCallback = component.get("v.SecondCallback");
        
        	fields.NPA_Rating__c = npaScore;
        	if (secCallback === true) {
            	fields.Make_Second_Call__c = true; 
            } else {
                fields.Make_Second_Call__c = false;  
            }
        	fields.Customer__c = parentId;
        	
        	var action = component.get("c.save");
        	action.setParams({
                "objNpa": fields
            });
        	action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var resType = response.getReturnValue();                   
                    var displayMsg = '';
                    if (resType = 'Success') {
                       displayMsg = 'Saved Successfully';                     
                    } else {
                        displayMsg = 'Something went wrong Changes are not saved';
                    }
                  
                    helper.showToastMessage(component, event, helper,resType, resType, displayMsg);
                    component.set('v.isDataChanged', false);
                    component.set('v.fc1callBackdateValidationError', false); 
                    component.set('v.fc2callBackdateValidationError', false); 
                    component.set('v.fc3callBackdateValidationError', false); 
                    helper.hideSpinner(component, event, helper);
               	}
            });
            
            $A.enqueueAction(action);            
        }
    },
    
    renderFc1CallBackDate : function(component, event, helper) {
       var fc1StatusId = component.find("FC1statusField");
        if(fc1StatusId != undefined){
        	var fc1Status = component.find("FC1statusField").get("v.value");
            if (fc1Status != '' && fc1Status == 'Asked to callback') {
               component.set("v.fc1StatusHasValue", true);
               component.set("v.isDataChanged", true);
            } else {
               component.set("v.fc1StatusHasValue", false);                
            }
        }
        //component.set("v.isDataChanged", true); 
    },
    renderFc2CallBackDate : function(component, event, helper) {
        var fc2StatusId = component.find("FC2statusField");
        if(fc2StatusId != undefined){
        	var fc2Status = component.find("FC2statusField").get("v.value");
            if (fc2Status != '' && fc2Status == 'Asked to callback') {
               component.set("v.fc2StatusHasValue", true);
               component.set("v.isDataChanged", true);
            } else {
               component.set("v.fc2StatusHasValue", false); 
            }
        }
        
      //component.set("v.isDataChanged", true); 
    },
    
    renderFc3CallBackDate : function(component, event, helper) {
       var fc3tatusId = component.find("FC3statusField");
        if(fc3tatusId != undefined){
        	var fc3Status = component.find("FC3statusField").get("v.value");
            if (fc3Status != '' && fc3Status == 'Asked to callback') {
               component.set("v.fc3StatusHasValue", true);
               component.set("v.isDataChanged", true);
            } else {
               component.set("v.fc3StatusHasValue", false); 
            }
        }
        
      //component.set("v.isDataChanged", true); 
    },
    
    validatefc1Date : function(component, event, helper) {
        debugger;
        
        var fc1CallbackDate = component.find("FC1cbField").get("v.value");
        var response = helper.dateUpdate(component, event, helper,fc1CallbackDate);
        component.set("v.fc1callBackdateValidationError" , response);
    },
    
    validatefc2Date : function(component, event, helper) {       
        var fc2CallbackDate = component.find("FC2cbField").get("v.value");       
        var response = helper.dateUpdate(component, event, helper,fc2CallbackDate);
        component.set("v.fc2callBackdateValidationError" , response);
    },
    
    validatefc3Date : function(component, event, helper) {        
        var fc3CallbackDate = component.find("FC3cbField").get("v.value");
        var response = helper.dateUpdate(component, event, helper,fc3CallbackDate);
        component.set("v.fc3callBackdateValidationError" , response);
    },
    
    updateStatusforPromoter : function(component, event, helper) {
        debugger;
        helper.updateNPA_data(component, event, helper);
        var rating = component.get("v.RatingValue");
        var fc1Read = component.get("v.fc1Sec");
        var fc2Read = component.get("v.fc2Sec");
        var fc3Read = component.get("v.fc3Sec");
        var isPromoter = false;
        if(rating && rating === '9' || rating === '10'){
            isPromoter = true;
        }else{
            isPromoter = false;
        }
        
        if(isPromoter && !fc1Read){
            if(component.get("v.fc1StatusHasValue")){
               component.set("v.fc1StatusHasValue", false); 
            }
            component.find("FC1statusField").set("v.value", "Successful");
            component.find("FC1commentField").set("v.value", "Successful");
            component.set("v.disableStatusforPromoter",true);
        }else if(isPromoter && !fc2Read){
            if(component.get("v.fc2StatusHasValue")){
               component.set("v.fc2StatusHasValue", false); 
            }
            component.find("FC2statusField").set("v.value", "Successful");
            component.find("FC2commentField").set("v.value", "Successful");
            component.set("v.disableStatusforPromoter",true);
        }else if(isPromoter && !fc3Read){
            if(component.get("v.fc3StatusHasValue")){
               component.set("v.fc3StatusHasValue", false); 
            }
            component.find("FC3statusField").set("v.value", "Successful");
            component.find("FC3commentField").set("v.value", "Successful");
            component.set("v.disableStatusforPromoter",true);
        }else if(!isPromoter){
           if(!fc1Read){
                component.find("FC1statusField").set("v.value", "");
                component.find("FC1commentField").set("v.value", "");
            	component.set("v.disableStatusforPromoter",false);
            }else if(!fc2Read){
                component.find("FC2statusField").set("v.value", "");
                component.find("FC2commentField").set("v.value", "");
                component.set("v.disableStatusforPromoter",false);
            }else if(!fc3Read){
                component.find("FC3statusField").set("v.value", "");
                component.find("FC3commentField").set("v.value", "");
                component.set("v.disableStatusforPromoter",false);
            } 
        }
    }
})