({
	doInit : function(component, event, helper) {
		var action = component.get("c.getScript");
		 action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Test response' + response.getReturnValue());
                component.set('v.scriptData', response.getReturnValue());
            }
         });
        $A.enqueueAction(action);
	},
    
    openModal: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   	},
  
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    saveData : function(component, event, helper) {
       var script =  component.get('v.scriptData');
        console.log('Test data' + JSON.stringify(script));
       var action = component.get("c.saveScript");
        action.setParams({
            scriptData : script
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Test response' + response.getReturnValue());
                var returnValue = response.getReturnValue();
                component.set("v.isModalOpen", false);
                 var toastEvent = $A.get("e.force:showToast");
                if (returnValue) {
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Script Updated.",
                        "type": "success"
                    });
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Script cannot be update failed.",
                        "type": "error"
                    });
                }
                toastEvent.fire();
            }
         });
        $A.enqueueAction(action);
    }
})