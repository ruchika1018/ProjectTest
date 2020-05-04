({
    doInit : function(component, event, helper) {
       var action = component.get("c.getTouchpoints");
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Test response' + response.getReturnValue());
                component.set('v.touchpointMap', response.getReturnValue());
            }
         });
        $A.enqueueAction(action); 
        var action2 = component.get("c.getComments");
        action2.setParams({
            recordId : component.get('v.customerId')
        });
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Test npa rec init' + JSON.stringify(response.getReturnValue()));
                component.set("v.NPARecord", response.getReturnValue());
                var record = component.get('v.NPARecord');
                console.log('Test if ' + record.Reassign_Comments_1__c);
                
                if (component.get('v.NPARecord.Reassign_Comments_1__c') != undefined) {
                    component.set('v.isReassignCom1',false);
                }
                if (component.get('v.NPARecord.Reassign_Comments_2__c') != undefined){
                    component.set('v.isReassignCom2',false);
                }
                if (component.get('v.NPARecord.Reassign_Comments_3__c') != undefined) {
                    component.set('v.isReassignCom3',false);
                }
                if (component.get('v.NPARecord.Reassign_Comments_4__c') != undefined) {
                    component.set('v.isReassignCom4',false);
                }
                if (component.get('v.NPARecord.Reassign_Comments_5__c') != undefined) {
                    component.set('v.isReassignCom5',false);
                }
                
            }
        });
        $A.enqueueAction(action2);
    },
    
	openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isSave", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        debugger;
        component.set("v.isOpen", false);
    },
    
    onCheckboxChange : function(component, event, helper) {
        //Gets the checkbox group based on the checkbox id
		var availableCheckboxes = component.find('rowSelectionCheckboxId');
        var resetCheckboxValue  = false;
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
            availableCheckboxes.forEach(function(checkbox) {
                checkbox.set('v.value', resetCheckboxValue);
                console.log('Checkbox ' + checkbox.get('v.text'));
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        //mark the current checkbox selection as checked
        event.getSource().set("v.value",true); 
        var selectedRows = event.getParam("text"); 
        console.log('Test' + JSON.stringify(event.getSource().get("v.text")));
	},
    
    saveData : function (component, event, helper) {
       /* var availableCheckboxes = component.find('rowSelectionCheckboxId');
        availableCheckboxes.forEach(function(checkbox) {
            	console.log('checkbox' + checkbox.get("v.text"));   
        }); 
        */
       	var custId = component.get('v.customerId');
        console.log('Customer Id' + custId);
        var valueSelected = component.get('v.valueSelected');
        console.log('valueSelected Id' + valueSelected);
        console.log('Test npa ' + JSON.stringify(component.get("v.NPARecord"))  );
        var npaData = JSON.stringify(component.get("v.NPARecord"));
        var npaRecord = component.get("v.NPARecord");
        var action = component.get("c.changeOwner");
        
        var reassignWrapper = {
            touchpointName  :'' + valueSelected
            ,customerId     : '' + custId
            ,npaRec		: '' + JSON.stringify(npaRecord)
        };
        debugger;
        var wrapperString = JSON.stringify(reassignWrapper);
        debugger;
         action.setParams({ 
             touchpointName : valueSelected,
             customerId : custId,
             npaRec : JSON.stringify(npaRecord),
             recString : wrapperString
         });
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Test reassign ' + component.get('v.isChange'));
                var test = response.getReturnValue();
                component.set('v.isChange', test);
                console.log('Test' + component.get('v.isChange'));
                helper.fireEvent(component, event);
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue()){
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Second Caller reassigned.",
                        "type": "success"
                    });
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Second_Caller_List"
                    });
                    urlEvent.fire(); 
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Second Caller not assigned. Check if user is present or active.",
                        "type": "error"
                    });
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Second_Caller_List"
                        });
                        urlEvent.fire(); 
                    }
                toastEvent.fire();
                component.set("v.isOpen", false);
            } else {
                component.set('v.isSCAssigned', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        "title": "Error!",
                        "message": "Second Caller not assigned. Check if user is present or active.",
                        "type": "error"
                    });
                 toastEvent.fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://dhlsmartrucking--qa.lightning.force.com/lightning/n/Second_Caller_List"
                });
                urlEvent.fire(); 
            }
         });
        $A.enqueueAction(action); 
        
    },
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})